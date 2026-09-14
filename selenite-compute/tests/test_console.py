"""report.console(script) must reproduce the console_<script>.txt the golden
runner captured with evalc, line for line.

Loosened lines (all declared here, nothing else):
- ECON v1.3 line 2 carries datestr(now): the prefix is compared.
- THERMAL lines printing ode45-derived temperatures or times are compared
  numerically: kelvin values within 0.11 (0.05 K rule + 0.1 K print
  resolution), hour values within 1 h (the port brief's rule).
"""
import math
import re

import pytest

from selenite import goldens, report

_NUM = re.compile(r"[-+]?\d+(?:\.\d+)?")

# THERMAL lines whose numbers come out of the ODE solver.
_THERMAL_ODE = [
    re.compile(r"^    (DRILL|DUMP|FAIL): "),
    re.compile(r"^  +\d+ \| [\d.]+K \| "),
    re.compile(r"^    LWRHU: recommend 3x \(t_253K="),
]


def _loose(script, line):
    if script == "SELENITE_ECON_V1_3" and line.startswith("ECN-019 Rev B | "):
        return "prefix"
    if script == "MOLEI_THERMAL_v1_3" and any(r.match(line) for r in _THERMAL_ODE):
        return "ode"
    return None


def _assert_ode_line(exp, got, where):
    assert _NUM.sub("#", exp) == _NUM.sub("#", got), where
    for e, g in zip(_NUM.findall(exp), _NUM.findall(got)):
        tol = 1.0 if ("hr" in exp and e in exp.split("hr")[0][-6:]) else 0.11
        assert math.isclose(float(e), float(g), abs_tol=tol), f"{where}: {exp!r} vs {got!r}"


@pytest.mark.parametrize("script", list(report.CONSOLE))
def test_console_matches_golden(script):
    path = goldens.oracle_dir() / f"console_{script}.txt"
    assert path.exists(), path
    expected = path.read_text(encoding="utf-8").splitlines()
    actual = report.console(script).splitlines()
    for n, (exp, got) in enumerate(zip(expected, actual), start=1):
        where = f"{script} line {n}"
        mode = _loose(script, exp)
        if mode == "prefix":
            assert got.startswith("ECN-019 Rev B | "), where
        elif mode == "ode":
            _assert_ode_line(exp, got, where)
        else:
            assert got == exp, f"{where}\n  expected: {exp!r}\n  got:      {got!r}"
    assert len(actual) == len(expected), f"{script}: {len(actual)} lines vs {len(expected)} in golden"
