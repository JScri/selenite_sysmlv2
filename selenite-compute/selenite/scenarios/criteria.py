"""criteria.py - scoring alternatives under uncertainty (decision criteria).

Wave 4A extension (no golden): this module is not a port of any MATLAB
script and has no oracle. Pure numpy over plain Python inputs: nothing
here reads the model or imports ``econ``.

Inputs are ``values: dict[str, np.ndarray]``, one ``(n,)`` array of a
measure of value per alternative, evaluated on the SAME sample matrix
(common random numbers), so sample ``i`` of one alternative pairs with
sample ``i`` of every other. ``sense`` is ``"min"`` (a cost such as
cumulative Earth-launched mass) or ``"max"`` (a value such as NPV).
Alternative order is the dict's insertion order and every tie is broken
deterministically by that order (the first alternative wins).

Criteria (``CRITERIA``), each a ``choose_*`` function returning
``(alternative, detail)``:

* ``expectedValue`` - best mean.
* ``p90`` - best 0.9-quantile for ``min`` (0.1-quantile for ``max``).
* ``cvar90`` - best conditional value at risk at alpha = 0.9: for ``min``
  the mean of the values at or above the 0.9-quantile (the expensive
  tail), for ``max`` the mean of the values at or below the 0.1-quantile.
* ``minimaxRegret`` - the regret of an alternative on a sample is its
  distance from the best alternative on that sample; choose the smallest
  maximum regret. The detail carries the regret summary (max, mean, P90).
* ``chanceConstrained`` - best mean among the alternatives whose
  probability of feasibility (a boolean array per alternative, e.g. "no
  milestone slipped") is at least ``threshold``; ``None`` when none
  qualifies, with the largest feasible probability reported.

``recommend`` wraps the criterion of choice into a ``Recommendation`` that
always carries the criterion, the win probability (fraction of samples on
which the alternative is best, ties split equally) and the feasible
probability, as the brief requires of every recommendation.

Two helpers serve the gate-year register: ``probability_by_year`` is the
fraction of samples whose year is a number ``<=`` the declared year (NaN or
``None`` means "never"), and ``quantile_year`` is a quantile over the
non-NaN years (NaN if there are none).
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping, Sequence

import numpy as np

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

CRITERIA = ("expectedValue", "p90", "cvar90", "minimaxRegret", "chanceConstrained")
SENSES = ("min", "max")


@dataclass(frozen=True)
class Recommendation:
    """A recommended alternative and the evidence it rests on.

    ``alternative`` is ``None`` when the criterion found no admissible
    alternative (chance constraint not met); ``detail`` is the criterion's
    own per-alternative statistics.
    """
    alternative: str | None
    criterion: str
    win_probability: float | None
    feasible_probability: float | None
    detail: dict[str, Any]


# --------------------------------------------------------------------------
# Summaries of one array
# --------------------------------------------------------------------------


def summarise(x: np.ndarray) -> dict[str, float]:
    """Mean, sample standard deviation (ddof = 1), Monte Carlo standard
    error of the mean, P10 / P50 / P90 (linear interpolation), min, max."""
    x = np.asarray(x, dtype=float).ravel()
    if x.size == 0:
        raise ValueError("summarise: empty array")
    std = float(np.std(x, ddof=1)) if x.size > 1 else 0.0
    p10, p50, p90 = np.quantile(x, [0.1, 0.5, 0.9])
    return {
        "mean": float(np.mean(x)), "std": std, "se": std / float(np.sqrt(x.size)),
        "p10": float(p10), "p50": float(p50), "p90": float(p90),
        "min": float(np.min(x)), "max": float(np.max(x)),
    }


def cvar(x: np.ndarray, alpha: float = 0.9, tail: str = "upper") -> float:
    """Conditional value at risk: ``tail="upper"`` is the mean of the values
    at or above the ``alpha``-quantile (the bad tail of a cost);
    ``tail="lower"`` is the mean of the values at or below the
    ``(1 - alpha)``-quantile (the bad tail of a value to maximise)."""
    x = np.asarray(x, dtype=float).ravel()
    if x.size == 0:
        raise ValueError("cvar: empty array")
    if not 0.0 < alpha < 1.0:
        raise ValueError(f"cvar: alpha must be in (0, 1), got {alpha}")
    if tail == "upper":
        return float(np.mean(x[x >= np.quantile(x, alpha)]))
    if tail == "lower":
        return float(np.mean(x[x <= np.quantile(x, 1.0 - alpha)]))
    raise ValueError(f"cvar: tail must be 'upper' or 'lower', got {tail!r}")


# --------------------------------------------------------------------------
# Alternatives on a common sample
# --------------------------------------------------------------------------


def _check_sense(sense: str) -> str:
    if sense not in SENSES:
        raise ValueError(f"sense must be one of {SENSES}, got {sense!r}")
    return sense


def _matrix(values: Mapping[str, np.ndarray]) -> tuple[list[str], np.ndarray]:
    """Alternatives in order and the ``(k, n)`` matrix of their values."""
    if not values:
        raise ValueError("no alternatives")
    names = list(values)
    columns = [np.asarray(values[name], dtype=float).ravel() for name in names]
    n = columns[0].size
    if n == 0:
        raise ValueError("alternatives have no samples")
    if any(c.size != n for c in columns):
        raise ValueError("every alternative must have the same number of samples: "
                         + ", ".join(f"{name}={c.size}" for name, c in zip(names, columns)))
    bad = [name for name, c in zip(names, columns) if not np.isfinite(c).all()]
    if bad:
        raise ValueError(f"non-finite values in alternatives {bad}; a criterion needs finite measures "
                         "(gate years use NaN for 'never' and are summarised with quantile_year, not scored)")
    return names, np.vstack(columns)


def _argbest(score: Mapping[str, float], sense: str) -> str:
    """The key with the best score; ties go to the first key in order."""
    return min(score, key=score.__getitem__) if sense == "min" else max(score, key=score.__getitem__)


def _feasible_matrix(names: Sequence[str], feasible: Mapping[str, np.ndarray] | None, n: int) -> np.ndarray:
    if feasible is None:
        return np.ones((len(names), n), dtype=bool)
    rows = []
    for name in names:
        if name not in feasible:
            raise KeyError(f"feasible has no entry for alternative {name!r}")
        f = np.asarray(feasible[name], dtype=bool).ravel()
        if f.size != n:
            raise ValueError(f"feasible[{name!r}] has {f.size} samples, expected {n}")
        rows.append(f)
    return np.vstack(rows)


def feasible_probability(feasible: Mapping[str, np.ndarray] | None, names: Sequence[str] | None = None,
                         n: int | None = None) -> dict[str, float]:
    """P(feasible) per alternative; 1.0 for every name when ``feasible`` is None."""
    if feasible is None:
        return {name: 1.0 for name in (names or ())}
    names = list(feasible) if names is None else list(names)
    if n is None:
        n = int(np.asarray(feasible[names[0]]).size) if names else 0
    f = _feasible_matrix(names, feasible, n)
    return {name: float(np.mean(f[i])) for i, name in enumerate(names)}


def win_probability(values: Mapping[str, np.ndarray], sense: str) -> dict[str, float]:
    """Fraction of samples on which each alternative is the best (paired by
    sample index); a sample tied between ``m`` alternatives gives each
    ``1 / m``, so the probabilities sum to one."""
    sense = _check_sense(sense)
    names, m = _matrix(values)
    best = m.min(axis=0) if sense == "min" else m.max(axis=0)
    winners = m == best[None, :]
    share = winners / winners.sum(axis=0)[None, :]
    return {name: float(share[i].mean()) for i, name in enumerate(names)}


def regret_matrix(values: Mapping[str, np.ndarray], sense: str) -> tuple[list[str], np.ndarray]:
    """``(names, regret)`` with ``regret[i, j] >= 0`` the distance of
    alternative ``i`` from the best alternative on sample ``j``."""
    sense = _check_sense(sense)
    names, m = _matrix(values)
    regret = m - m.min(axis=0)[None, :] if sense == "min" else m.max(axis=0)[None, :] - m
    return names, regret


def choose_expected(values: Mapping[str, np.ndarray], sense: str) -> tuple[str, dict[str, Any]]:
    """Best mean. ``detail["score"]`` is the mean per alternative."""
    sense = _check_sense(sense)
    names, m = _matrix(values)
    score = {name: float(m[i].mean()) for i, name in enumerate(names)}
    return _argbest(score, sense), {"score": score, "statistic": "mean", "sense": sense}


def choose_quantile(values: Mapping[str, np.ndarray], sense: str, q: float = 0.9) -> tuple[str, dict[str, Any]]:
    """Best ``q``-quantile for ``min`` (the ``(1 - q)``-quantile for ``max``):
    with the default ``q = 0.9`` that is P90 of a cost or P10 of a value."""
    sense = _check_sense(sense)
    if not 0.0 <= q <= 1.0:
        raise ValueError(f"q must be in [0, 1], got {q}")
    names, m = _matrix(values)
    level = q if sense == "min" else 1.0 - q
    score = {name: float(np.quantile(m[i], level)) for i, name in enumerate(names)}
    return _argbest(score, sense), {"score": score, "statistic": f"p{round(level * 100):d}", "sense": sense}


def choose_cvar(values: Mapping[str, np.ndarray], sense: str, alpha: float = 0.9) -> tuple[str, dict[str, Any]]:
    """Best CVaR at ``alpha``: the upper tail for ``min``, the lower tail
    for ``max``."""
    sense = _check_sense(sense)
    names, m = _matrix(values)
    tail = "upper" if sense == "min" else "lower"
    score = {name: cvar(m[i], alpha=alpha, tail=tail) for i, name in enumerate(names)}
    return _argbest(score, sense), {"score": score, "statistic": f"cvar{round(alpha * 100):d}_{tail}", "sense": sense}


def choose_minimax_regret(values: Mapping[str, np.ndarray], sense: str) -> tuple[str, dict[str, Any]]:
    """Smallest maximum regret over the samples. ``detail["score"]`` is the
    maximum regret per alternative and ``detail["regret"]`` its summary
    (``max``, ``mean``, ``p90`` per alternative)."""
    names, regret = regret_matrix(values, sense)
    score = {name: float(regret[i].max()) for i, name in enumerate(names)}
    summary = {
        "max": score,
        "mean": {name: float(regret[i].mean()) for i, name in enumerate(names)},
        "p90": {name: float(np.quantile(regret[i], 0.9)) for i, name in enumerate(names)},
    }
    return _argbest(score, "min"), {"score": score, "statistic": "max_regret", "sense": sense, "regret": summary}


def choose_chance_constrained(values: Mapping[str, np.ndarray], feasible: Mapping[str, np.ndarray] | None,
                              sense: str, threshold: float = 0.8) -> tuple[str | None, dict[str, Any]]:
    """Best mean among the alternatives with ``P(feasible) >= threshold``;
    ``None`` when none qualifies. ``detail["feasible_probability"]`` is
    P(feasible) per alternative, ``detail["qualifying"]`` the admissible
    ones in order and ``detail["max_feasible_probability"]`` the largest
    P(feasible) seen (what to report when nothing qualifies)."""
    sense = _check_sense(sense)
    if not 0.0 <= threshold <= 1.0:
        raise ValueError(f"threshold must be in [0, 1], got {threshold}")
    names, m = _matrix(values)
    f = _feasible_matrix(names, feasible, m.shape[1])
    prob = {name: float(f[i].mean()) for i, name in enumerate(names)}
    score = {name: float(m[i].mean()) for i, name in enumerate(names)}
    qualifying = [name for name in names if prob[name] >= threshold]
    choice = _argbest({name: score[name] for name in qualifying}, sense) if qualifying else None
    return choice, {
        "score": score, "statistic": "mean", "sense": sense, "threshold": float(threshold),
        "feasible_probability": prob, "qualifying": qualifying,
        "max_feasible_probability": max(prob.values()),
    }


def recommend(values: Mapping[str, np.ndarray], sense: str, feasible: Mapping[str, np.ndarray] | None,
              criterion: str, threshold: float = 0.8) -> Recommendation:
    """Apply one criterion of ``CRITERIA`` and return a ``Recommendation``
    carrying the win probability and P(feasible) of the chosen alternative
    (``feasible=None`` means every alternative is always feasible)."""
    sense = _check_sense(sense)
    if criterion == "expectedValue":
        choice, detail = choose_expected(values, sense)
    elif criterion == "p90":
        choice, detail = choose_quantile(values, sense, q=0.9)
    elif criterion == "cvar90":
        choice, detail = choose_cvar(values, sense, alpha=0.9)
    elif criterion == "minimaxRegret":
        choice, detail = choose_minimax_regret(values, sense)
    elif criterion == "chanceConstrained":
        choice, detail = choose_chance_constrained(values, feasible, sense, threshold=threshold)
    else:
        raise ValueError(f"unknown criterion {criterion!r}; expected one of {CRITERIA}")
    names, m = _matrix(values)
    wins = win_probability(values, sense)
    prob = feasible_probability(feasible, names, m.shape[1])
    detail = dict(detail, win_probability=wins)
    if "feasible_probability" not in detail:
        detail["feasible_probability"] = prob
    return Recommendation(
        alternative=choice, criterion=criterion,
        win_probability=None if choice is None else wins[choice],
        feasible_probability=None if choice is None else prob[choice],
        detail=detail,
    )


# --------------------------------------------------------------------------
# Gate / milestone years
# --------------------------------------------------------------------------


def _years(years) -> np.ndarray:
    """Years as a float array with ``None`` and NaN both meaning "never"."""
    arr = np.asarray(years, dtype=object).ravel()
    return np.array([np.nan if y is None else float(y) for y in arr], dtype=float)


def probability_by_year(years, declared: float) -> float:
    """Fraction of samples whose year is a number ``<= declared``; NaN or
    ``None`` counts as never met. NaN for an empty input."""
    y = _years(years)
    if y.size == 0:
        return float("nan")
    with np.errstate(invalid="ignore"):
        met = np.isfinite(y) & (y <= float(declared))
    return float(met.mean())


def quantile_year(years, q):
    """Quantile ``q`` (scalar or sequence) of the non-NaN years; NaN when
    every year is NaN / ``None``."""
    y = _years(years)
    y = y[np.isfinite(y)]
    if y.size == 0:
        return float("nan") if np.ndim(q) == 0 else np.full(np.shape(q), np.nan)
    out = np.quantile(y, q)
    return float(out) if np.ndim(q) == 0 else out
