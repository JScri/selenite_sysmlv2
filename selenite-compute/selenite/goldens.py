"""Golden oracle loader.

Reads the merged, tagged oracle (``oracle/<script>.csv`` with columns
``key,value,source,comparable``) into typed rows. Values are parsed from the
MATLAB ``mat2str`` / ``num2str`` forms the capture runner wrote:

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

# Default oracle location relative to this repository layout; override with
# SELENITE_ORACLE for a stand-alone checkout of the goldens.
_DEFAULT_ORACLE = Path(__file__).resolve().parents[2] / "selenite-goldens-oracle" / "oracle" / "oracle"

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
    def octave_only(self) -> bool:
        return self.source.startswith("octave_8_4_only")

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


def load(script: str | None = None, root: Path | None = None) -> list[GoldenRow]:
    root = root or oracle_dir()
    files = sorted(root.glob("*.csv"))
    if script is not None:
        files = [f for f in files if f.stem == script]
    rows: list[GoldenRow] = []
    for f in files:
        with f.open(newline="", encoding="utf-8") as fh:
            for rec in csv.DictReader(fh):
                rows.append(GoldenRow(
                    script=f.stem, key=rec["key"], value=parse_value(rec["value"]),
                    raw=rec["value"], source=rec.get("source", ""), comparable=rec.get("comparable", ""),
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


def ode_row_is_compared(row: GoldenRow) -> bool:
    """Only the temperatures the brief names are compared for ODE-tagged rows."""
    return row.is_ode and any(frag in row.key for frag in ODE_COMPARED_KEY_FRAGMENTS)
