"""sample.py - sampling the uncertainty register (Latin hypercube or Sobol).

Wave 4A extension (no golden): this module is not a port of any MATLAB
script and has no oracle. It turns the uncertainty register, a sequence of
``Dist`` records read from the model, into one sample matrix that every
alternative of every decision is evaluated on (common random numbers, so
comparisons between alternatives are paired by sample index).

Pure numpy + scipy over plain Python inputs: nothing here reads the model
or imports ``econ``.

How the uniform matrix is drawn
-------------------------------
``sample(dists, n, seed, method)`` draws an ``n x d`` matrix ``u`` of
uniforms on (0, 1), one column per *sampled* distribution, with
``scipy.stats.qmc.LatinHypercube`` (``method="lhs"``, scrambled) or
``scipy.stats.qmc.Sobol`` (``method="sobol"``, scrambled; ``n`` is rounded
up to the next power of two, drawn, then truncated to ``n``, and the
``Samples.warning`` field says so because the balance properties of a Sobol
set hold only at powers of two). The same ``seed`` always gives the same
``u`` (``Samples.hash`` is the SHA-256 of its bytes).

Every column is then mapped to its marginal by inverse CDF:

* ``uniform``: ``low + u (high - low)``.
* ``triangular``: ``scipy.stats.triang.ppf`` with ``c = (nominal - low) /
  (high - low)``, ``loc = low``, ``scale = high - low``.
* ``pert`` (lambda = 4): the beta distribution ``a = 1 + 4 (nominal - low) /
  (high - low)``, ``b = 1 + 4 (high - nominal) / (high - low)`` scaled to
  ``[low, high]``. Its mean is ``(low + 4 nominal + high) / 6``; this is the
  classical PERT shape, not the modified PERT with a free lambda.
* ``logNormal``: the median is ``nominal`` and ``low`` / ``high`` are read
  as the P10 / P90 of the distribution, so ``sigma = (ln high - ln low) /
  (2 z90)`` with ``z90 = 1.2815515655446004`` (the standard normal 0.9
  quantile). The P90 / P10 ratio therefore equals ``high / low`` exactly;
  the quantiles themselves equal ``low`` and ``high`` only when ``nominal``
  is their geometric mean, because the median is pinned at ``nominal``.
* ``discrete``: ``values`` with ``weights`` (uniform when ``weights`` is
  empty); ``u`` is placed against the cumulative weights with
  ``numpy.searchsorted``.
* ``pointValue``, and any distribution whose range is unbound (``low`` or
  ``high`` missing, or no ``values`` for a discrete): a constant column at
  ``nominal``. This is the brief's rule that a parameter without an
  existing Low/High pair or a cited source stays a point at nominal.

``Samples.values`` holds one ``(n,)`` array for EVERY ``Dist``, sampled or
constant, so downstream code never has to ask which is which;
``Samples.names`` lists only the sampled ones, in register order, matching
the columns of ``u``.
"""
from __future__ import annotations

import hashlib
import math
from dataclasses import dataclass, field
from typing import Sequence

import numpy as np
from scipy.stats import beta, norm, qmc, triang

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

KINDS = ("pointValue", "uniform", "triangular", "pert", "logNormal", "discrete")
METHODS = ("lhs", "sobol")
PERT_LAMBDA = 4.0
Z90 = 1.2815515655446004  # standard normal 0.9 quantile (norm.ppf(0.9))


@dataclass(frozen=True)
class Dist:
    """One row of the uncertainty register.

    ``kind`` is a ``DistributionKind`` literal of ``model/Scenarios.sysml``;
    ``nominal`` is the committed value; ``low`` / ``high`` bound the range
    (``None`` when the model leaves it unbound); ``values`` / ``weights``
    describe a ``discrete`` distribution; ``source`` is provenance text.
    """
    name: str
    kind: str
    nominal: float
    low: float | None = None
    high: float | None = None
    values: tuple[float, ...] = ()
    weights: tuple[float, ...] = ()
    source: str = ""

    def __post_init__(self) -> None:
        if self.kind not in KINDS:
            raise ValueError(f"{self.name}: unknown distribution kind {self.kind!r}; expected one of {KINDS}")
        if len(self.weights) not in (0, len(self.values)):
            raise ValueError(f"{self.name}: {len(self.weights)} weights for {len(self.values)} values")

    @property
    def sampled(self) -> bool:
        """True when the distribution is not a point and its range is bound
        (``low`` and ``high`` for the continuous kinds, ``values`` for a
        discrete one); otherwise the parameter is a constant at ``nominal``."""
        if self.kind == "pointValue":
            return False
        if self.kind == "discrete":
            return len(self.values) > 0
        return self.low is not None and self.high is not None


@dataclass(frozen=True)
class Samples:
    """The sample matrix and every parameter's sampled (or constant) column.

    ``names`` are the sampled distributions in register order (the columns
    of ``u``); ``values`` has an ``(n,)`` array for every ``Dist`` passed
    to ``sample``; ``point_names`` are the ones held constant. ``warning``
    is non-empty when the Sobol draw was rounded up and truncated.
    """
    n: int
    seed: int
    method: str
    names: tuple[str, ...]
    u: np.ndarray = field(repr=False)
    values: dict[str, np.ndarray] = field(repr=False)
    point_names: tuple[str, ...] = ()
    warning: str = ""

    @property
    def d(self) -> int:
        """Number of sampled dimensions (columns of ``u``)."""
        return len(self.names)

    @property
    def hash(self) -> str:
        """SHA-256 of the uniform matrix bytes: equal hashes mean the same
        common random numbers (the CRN pairing test uses this)."""
        return hashlib.sha256(np.ascontiguousarray(self.u, dtype=float).tobytes()).hexdigest()


# --------------------------------------------------------------------------
# Inverse-CDF transforms
# --------------------------------------------------------------------------


def _check_range(dist: Dist) -> tuple[float, float]:
    low, high = dist.low, dist.high
    if low is None or high is None:
        raise ValueError(f"{dist.name}: {dist.kind} needs both low and high")
    low, high = float(low), float(high)
    if not (math.isfinite(low) and math.isfinite(high)) or not low < high:
        raise ValueError(f"{dist.name}: need low < high, got low={low}, high={high}")
    return low, high


def _check_mode(dist: Dist, low: float, high: float) -> float:
    nominal = float(dist.nominal)
    if not low <= nominal <= high:
        raise ValueError(f"{dist.name}: {dist.kind} needs low <= nominal <= high, got "
                         f"low={low}, nominal={nominal}, high={high}")
    return nominal


def transform(dist: Dist, u: np.ndarray) -> np.ndarray:
    """Map uniforms ``u`` in [0, 1] to ``dist``'s marginal by inverse CDF.

    A point, or a distribution with an unbound range, returns a constant
    array at ``nominal`` of the same shape as ``u``.
    """
    u = np.asarray(u, dtype=float)
    if not dist.sampled:
        return np.full(u.shape, float(dist.nominal))
    kind = dist.kind
    if kind == "discrete":
        values = np.asarray(dist.values, dtype=float)
        if dist.weights:
            weights = np.asarray(dist.weights, dtype=float)
            if np.any(weights < 0) or not np.isfinite(weights).all() or weights.sum() <= 0:
                raise ValueError(f"{dist.name}: discrete weights must be non-negative with a positive sum")
        else:
            weights = np.ones(values.size)
        cumulative = np.cumsum(weights) / weights.sum()
        cumulative[-1] = 1.0  # guard the rounding of the last partial sum
        idx = np.searchsorted(cumulative, u, side="right")
        return values[np.minimum(idx, values.size - 1)]
    low, high = _check_range(dist)
    if kind == "uniform":
        return low + u * (high - low)
    if kind == "triangular":
        nominal = _check_mode(dist, low, high)
        return triang.ppf(u, (nominal - low) / (high - low), loc=low, scale=high - low)
    if kind == "pert":
        nominal = _check_mode(dist, low, high)
        a = 1.0 + PERT_LAMBDA * (nominal - low) / (high - low)
        b = 1.0 + PERT_LAMBDA * (high - nominal) / (high - low)
        return beta.ppf(u, a, b, loc=low, scale=high - low)
    if kind == "logNormal":
        nominal = float(dist.nominal)
        if low <= 0.0 or nominal <= 0.0:
            raise ValueError(f"{dist.name}: logNormal needs low > 0 and nominal > 0")
        sigma = (math.log(high) - math.log(low)) / (2.0 * Z90)
        return nominal * np.exp(sigma * norm.ppf(u))
    raise ValueError(f"{dist.name}: unknown distribution kind {kind!r}")  # pragma: no cover - guarded in Dist


# --------------------------------------------------------------------------
# Sampling
# --------------------------------------------------------------------------


def _uniform_matrix(d: int, n: int, seed: int, method: str) -> tuple[np.ndarray, str]:
    if d == 0:
        return np.zeros((n, 0)), ""
    if method == "lhs":
        return qmc.LatinHypercube(d=d, scramble=True, rng=seed).random(n), ""
    if method == "sobol":
        m = max(0, math.ceil(math.log2(n)))
        u = qmc.Sobol(d=d, scramble=True, rng=seed).random_base2(m)[:n]
        warning = ""
        if 2 ** m != n:
            warning = (f"sobol: n={n} is not a power of two; drew {2 ** m} points and truncated to {n}, "
                       "so the set's balance properties are approximate")
        return u, warning
    raise ValueError(f"unknown sampling method {method!r}; expected one of {METHODS}")


def sample(dists: Sequence[Dist], n: int, seed: int, method: str = "lhs") -> Samples:
    """Draw ``n`` samples of every distribution in ``dists`` with one
    ``seed`` (common random numbers across alternatives).

    Sampled distributions take one column each of the ``n x d`` uniform
    matrix, in the order given; points and unbound ranges are constant at
    ``nominal``. ``d == 0`` gives an ``(n, 0)`` matrix and only constants.
    """
    dists = list(dists)
    if int(n) != n or n < 1:
        raise ValueError(f"n must be a positive integer, got {n!r}")
    n = int(n)
    if method not in METHODS:
        raise ValueError(f"unknown sampling method {method!r}; expected one of {METHODS}")
    names = [dist.name for dist in dists]
    if len(set(names)) != len(names):
        dup = sorted({name for name in names if names.count(name) > 1})
        raise ValueError(f"duplicate distribution names: {dup}")
    sampled = [dist for dist in dists if dist.sampled]
    u, warning = _uniform_matrix(len(sampled), n, seed, method)
    values: dict[str, np.ndarray] = {}
    column = 0
    for dist in dists:
        if dist.sampled:
            values[dist.name] = transform(dist, u[:, column])
            column += 1
        else:
            values[dist.name] = np.full(n, float(dist.nominal))
    return Samples(
        n=n, seed=int(seed), method=method,
        names=tuple(dist.name for dist in sampled), u=u, values=values,
        point_names=tuple(dist.name for dist in dists if not dist.sampled),
        warning=warning,
    )
