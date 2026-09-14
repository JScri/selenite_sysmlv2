"""Golden oracle loader.

Canonical oracle (14 Sep 2026): the runner v2.1 capture under MATLAB R2025a,
``selenite-goldens-runner-v2_1/goldens_20260914_224703/<script>.csv``
(columns ``key,value``). It restores the vectors runner v2.0 dropped. The
8 Sep merged oracle (``selenite-goldens-oracle/oracle/oracle/<script>.csv``,
columns ``key,value,source,comparable``) is read only for its tags: rows it
marks ``platform_dependent_ode`` keep that tag; every other row is
``comparable = yes`` with ``source = matlab_r2025a_v2.1``.

Values are parsed from the MATLAB ``mat2str`` / ``num2str`` forms the capture
runner wrote:

* scalars ``347.679221721``  -> float (ints stay int-valued floats)
* arrays  ``[19962 39924 66540]`` / ``[1 2;3 4]`` -> numpy array (1-D or 2-D)
* ``NaN`` / ``Inf`` / ``-Inf``       -> float('nan') etc.
* anything else                       -> str (labels, option names)
"""
from __future__ import annotations

import csv
import math
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterator

import numpy as np

_REPO = Path(__file__).resolve().parents[2]
# Override either with SELENITE_ORACLE / SELENITE_ORACLE_TAGS for a stand-alone checkout.
_DEFAULT_ORACLE = _REPO / "selenite-goldens-runner-v2_1" / "goldens_20260914_224703"
_DEFAULT_TAGS = _REPO / "selenite-goldens-oracle" / "oracle" / "oracle"

#: current-baseline scripts (chains of RUN_GOLDENS.m); historical versions are not oracle targets
CURRENT_SCRIPTS = (
    "sabatier", "SELENITE_VERIFY_v5_0", "scaling_v1_3", "SELENITE_ECON_V1_3",
    "SELENITE_ECON_V1_4", "MOLEI_THERMAL_v1_3", "SELENITE_VISUALIZE_v3_3",
)

#: oracle script stem -> python module that must reproduce it
SCRIPT_TO_MODULE = {
    "sabatier": "selenite.eclss",
    "SELENITE_VERIFY_v5_0": "selenite.verify",  # facade over power/fleet/isru
    "MOLEI_THERMAL_v1_3": "selenite.thermal",
    "SELENITE_ECON_V1_3": "selenite.econ",
    "SELENITE_ECON_V1_4": "selenite.econ",
    "scaling_v1_3": "selenite.historical.scale_v1_3",
    "SELENITE_VISUALIZE_v3_3": "selenite.psr_layout",
}

#: tolerance rules from docs/SESSION_BRIEF_python_port.md
REL_TOL_SCALAR = 1e-9
REL_TOL_ARRAY = 1e-9
ABS_TOL_ODE_KELVIN = 0.05
ODE_COMPARED_KEY_FRAGMENTS = ("24h", "72h", "200h", "eq", "equil", "T_final", "Tss")


@dataclass(frozen=True)
class GoldenRow:
    script: str
    key: str
    value: Any
    raw: str
    source: str
    comparable: str

    @property
    def is_array(self) -> bool:
        return isinstance(self.value, np.ndarray)

    @property
    def is_nan(self) -> bool:
        return isinstance(self.value, float) and math.isnan(self.value)

    @property
    def is_ode(self) -> bool:
        return self.comparable == "platform_dependent_ode"

    @property
    def module(self) -> str:
        return SCRIPT_TO_MODULE[self.script]

    @property
    def id(self) -> str:
        return f"{self.script}::{self.key}"


def parse_value(raw: str) -> Any:
    s = raw.strip()
    if s == "":
        return ""
    low = s.lower()
    if low in ("nan",):
        return float("nan")
    if low in ("inf", "+inf"):
        return float("inf")
    if low == "-inf":
        return float("-inf")
    if s.startswith("[") and s.endswith("]"):
        body = s[1:-1].strip()
        if body == "":
            return np.array([])
        rows = [r for r in body.split(";")]
        try:
            mat = [[_num(tok) for tok in r.replace(",", " ").split()] for r in rows]
        except ValueError:
            return s  # a cell/string array we do not model numerically
        arr = np.array(mat, dtype=float)
        return arr[0] if arr.shape[0] == 1 else arr
    try:
        return _num(s)
    except ValueError:
        return s


def _num(tok: str) -> float:
    t = tok.lower()
    if t == "nan":
        return float("nan")
    if t in ("inf", "+inf"):
        return float("inf")
    if t == "-inf":
        return float("-inf")
    return float(tok)


def oracle_dir() -> Path:
    return Path(os.environ.get("SELENITE_ORACLE", _DEFAULT_ORACLE))


def tags_dir() -> Path:
    return Path(os.environ.get("SELENITE_ORACLE_TAGS", _DEFAULT_TAGS))


def _load_tags(root: Path) -> dict[tuple[str, str], str]:
    tags: dict[tuple[str, str], str] = {}
    if not root.exists():
        return tags
    for f in sorted(root.glob("*.csv")):
        with f.open(newline="", encoding="utf-8") as fh:
            for rec in csv.DictReader(fh):
                if rec.get("comparable") == "platform_dependent_ode":
                    tags[(f.stem, rec["key"])] = "platform_dependent_ode"
    return tags


def load(script: str | None = None, root: Path | None = None, tags_root: Path | None = None) -> list[GoldenRow]:
    root = root or oracle_dir()
    tags = _load_tags(tags_root or tags_dir())
    stems = [script] if script else list(CURRENT_SCRIPTS)
    rows: list[GoldenRow] = []
    for stem in stems:
        f = root / f"{stem}.csv"
        if not f.exists():
            continue
        with f.open(newline="", encoding="utf-8") as fh:
            for rec in csv.DictReader(fh):
                comparable = tags.get((stem, rec["key"]), "yes")
                rows.append(GoldenRow(
                    script=stem, key=rec["key"], value=parse_value(rec["value"]),
                    raw=rec["value"], source="matlab_r2025a_v2.1", comparable=comparable,
                ))
    return rows


def iter_comparable(root: Path | None = None) -> Iterator[GoldenRow]:
    for r in load(root=root):
        if r.comparable in ("yes", "platform_dependent_ode"):
            yield r


def assert_matches(row: GoldenRow, actual: Any) -> None:
    """Compare a port result against one golden row with the brief's rules."""
    if row.is_nan:
        assert isinstance(actual, float) and math.isnan(actual), f"{row.id}: expected NaN, got {actual!r}"
        return
    if isinstance(row.value, str):
        assert str(actual) == row.value, f"{row.id}: expected {row.value!r}, got {actual!r}"
        return
    if row.is_ode:
        assert abs(float(actual) - float(row.value)) <= ABS_TOL_ODE_KELVIN, (
            f"{row.id}: ODE value {actual} vs {row.value} exceeds {ABS_TOL_ODE_KELVIN} K")
        return
    if row.is_array:
        got = np.asarray(actual, dtype=float)
        assert got.shape == row.value.shape, f"{row.id}: shape {got.shape} vs {row.value.shape}"
        np.testing.assert_allclose(got, row.value, rtol=REL_TOL_ARRAY, atol=0.0, err_msg=row.id)
        return
    exp = float(row.value)
    assert math.isclose(float(actual), exp, rel_tol=REL_TOL_SCALAR, abs_tol=0.0 if exp != 0 else 1e-12), (
        f"{row.id}: {actual} vs {exp}")


ABS_TOL_ODE_HOURS = 1.0


def compare_rule(row: GoldenRow, module) -> tuple:
    """How to compare one row, honouring the port brief's ODE rules and any
    ODE_* key sets a port module declares.

    Returns ('skip', reason) | ('exact',) | ('kelvin', tol) | ('hours', tol).
    """
    key = row.key
    skips = getattr(module, "SKIP_KEYS", {})
    if key in skips:
        return ("skip", skips[key])
    if key in getattr(module, "ODE_SKIP_KEYS", ()):
        return ("skip", "ODE step-sequence dependent (index or figure auto-limit)")
    if key in getattr(module, "ODE_TEMPERATURE_KEYS", ()):
        return ("kelvin", ABS_TOL_ODE_KELVIN)
    if key in getattr(module, "ODE_TIME_STRING_KEYS", ()):
        return ("hours", ABS_TOL_ODE_HOURS)
    stem, _, stat = key.rpartition(".")
    if row.is_ode or stem in getattr(module, "ODE_ARRAY_STEMS", ()):
        if stat in ("numel", "sum", "mean"):
            return ("skip", "ODE step-sequence dependent statistic")
        if stat in ("min", "max"):
            # temperature arrays at 0.05 K; time grids are exact (span endpoints)
            return ("kelvin", ABS_TOL_ODE_KELVIN) if stem[:1].isupper() else ("exact",)
        return ("skip", "ODE step-sequence dependent")
    return ("exact",)


def assert_with_rule(row: GoldenRow, actual: Any, rule: tuple) -> None:
    if rule[0] == "kelvin":
        assert abs(float(actual) - float(row.value)) <= rule[1], (
            f"{row.id}: {actual} vs {row.value} exceeds {rule[1]} K")
    elif rule[0] == "hours":
        exp, got = str(row.value), str(actual)
        if exp == "NEVER" or got == "NEVER":
            assert exp == got, f"{row.id}: {got!r} vs {exp!r}"
        else:
            assert abs(float(got.rstrip("hr")) - float(exp.rstrip("hr"))) <= rule[1], f"{row.id}: {got} vs {exp}"
    else:
        assert_matches(row, actual)
