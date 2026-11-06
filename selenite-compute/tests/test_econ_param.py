"""``selenite.scenarios.econ_param`` reproduces ``selenite.econ`` at its
defaults (Wave 4A extension; the goldens stay with ``econ.py``)."""
import dataclasses
import math
import time

import numpy as np
import pytest

from selenite import econ
from selenite.scenarios import econ_param as ep

RTOL = 1e-9


def _assert_same(ref, got, path):
    """Recursive workspace comparison: callables skipped, dicts recursed,
    arrays at rtol 1e-9 (atol 0, nan == nan), scalars rel 1e-9, strings and
    list / StructArray elements compared one by one."""
    if callable(ref):
        return
    if isinstance(ref, dict):
        assert isinstance(got, dict), f"{path}: expected a dict, got {type(got).__name__}"
        for k, v in ref.items():
            assert k in got, f"{path}.{k} missing"
            _assert_same(v, got[k], f"{path}.{k}")
    elif isinstance(ref, str):
        assert got == ref, f"{path}: {ref!r} != {got!r}"
    elif isinstance(ref, np.ndarray):
        got = np.asarray(got)
        assert got.shape == ref.shape, f"{path}: shape {ref.shape} != {got.shape}"
        np.testing.assert_allclose(got, ref, rtol=RTOL, atol=0, equal_nan=True, err_msg=path)
    elif isinstance(ref, (list, tuple)):
        assert len(got) == len(ref), f"{path}: length {len(ref)} != {len(got)}"
        for j, (a, b) in enumerate(zip(ref, got)):
            _assert_same(a, b, f"{path}[{j}]")
    elif ref is None:
        assert got is None, f"{path}: expected None, got {got!r}"
    elif isinstance(ref, (bool, int, float, np.generic)):
        a, b = float(ref), float(got)
        if math.isnan(a):
            assert math.isnan(b), f"{path}: nan != {b}"
        else:
            assert math.isclose(a, b, rel_tol=RTOL, abs_tol=0), f"{path}: {a} != {b}"
    else:
        pytest.fail(f"{path}: unhandled type {type(ref).__name__}")


@pytest.fixture(scope="module")
def ref_v13():
    return econ.workspace("SELENITE_ECON_V1_3")


@pytest.fixture(scope="module")
def ref_v14():
    return econ.workspace()


def test_module_is_an_extension():
    assert ep.PORTED is False
    assert "Wave 4A" in ep.SOURCE_SCRIPT and "no golden" in ep.SOURCE_SCRIPT
    assert "Wave 4A" in ep.__doc__ and "no golden" in ep.__doc__


def test_v1_3_workspace_equals_econ(ref_v13):
    got = ep.v1_3(ep.Params())
    for key, value in ref_v13.items():
        assert key in got, f"{key} missing from v1_3(Params())"
        _assert_same(value, got[key], key)


def test_full_workspace_equals_econ(ref_v14):
    got = ep.workspace()
    for key, value in ref_v14.items():
        assert key in got, f"{key} missing from workspace()"
        _assert_same(value, got[key], key)
    assert got["params"] == ep.Params()


def test_metrics_match_v1_4(ref_v14):
    m = ep.metrics(ep.v1_3(ep.Params()))
    assert set(m) == {"pv_cost", "pv_rev_direct", "pv_rev_total", "bcr_direct", "bcr_total",
                      "npv_total_usd_b", "npv_direct_usd_b", "cum_earth_cargo_t", "cum_co2_rockets_t",
                      "cum_launches"}
    for key in ("pv_cost", "pv_rev_direct", "pv_rev_total", "bcr_direct", "bcr_total"):
        assert math.isclose(m[key], float(ref_v14[key]), rel_tol=RTOL), key
    assert math.isclose(m["npv_total_usd_b"], ref_v14["npv_total"][-1] / 1e3, rel_tol=RTOL)
    assert math.isclose(m["npv_direct_usd_b"], ref_v14["npv_direct"][-1] / 1e3, rel_tol=RTOL)
    assert math.isclose(m["cum_earth_cargo_t"], ref_v14["earth_cargo"].sum(), rel_tol=RTOL)
    assert math.isclose(m["cum_co2_rockets_t"], ref_v14["co2_rockets"].sum(), rel_tol=RTOL)
    assert math.isclose(m["cum_launches"], ref_v14["total_launches"].sum(), rel_tol=RTOL)
    assert all(isinstance(v, float) for v in m.values())


def test_launch_cost_multiplier_scales_cost_launch_only():
    base = ep.v1_3(ep.Params())
    hi = ep.v1_3(ep.Params(launch_cost_multiplier=1.5))
    np.testing.assert_allclose(hi["launch_cost"], 1.5 * base["launch_cost"], rtol=1e-12, atol=0)
    np.testing.assert_allclose(hi["cost_launch"], 1.5 * base["cost_launch"], rtol=1e-12, atol=0)
    assert np.array_equal(hi["reo_target"], base["reo_target"])
    assert np.array_equal(hi["earth_cargo"], base["earth_cargo"])
    assert np.array_equal(hi["cost_mkiii"], base["cost_mkiii"])  # LEO cost is a separate knob
    assert hi["npv_total"][-1] < base["npv_total"][-1]


def test_batch_circuit_design_needs_6_25_million_circuits():
    ws = ep.v1_3(ep.Params(circuit_design=1))
    assert ws["circuits_needed"][-1] == 6_250_000
    assert ws["circuit"]["reo_yr"] == 0.4 and ws["circuit"]["mass_kg"] == 15000
    assert ws["CIRCUIT_DESIGN"] == 1
    with pytest.raises(ValueError):
        ep.Params(circuit_design=4)


def test_decision_framework_ramp_knots():
    ws = ep.v1_3(ep.Params(reo_ramp="decisionFramework"))
    reo = ws["reo_target"]
    assert reo[60] == pytest.approx(100000, rel=1e-12)
    assert reo[80] == pytest.approx(500000, rel=1e-12)
    assert reo[120] == pytest.approx(1250000, rel=1e-12)
    assert reo[180] == 2500000 and reo[200] == 2500000
    assert reo[:19].sum() == 0
    assert np.all(np.diff(reo) >= 0)
    econ_reo = ep.v1_3(ep.Params())["reo_target"]
    assert econ_reo[60] == pytest.approx(10000, rel=1e-12)
    with pytest.raises(KeyError):
        ep.Params(reo_ramp="noSuchRamp")
    # a custom ramp is accepted as (knots_y, knots_v)
    custom = ep.v1_3(ep.Params(reo_ramp=((0, 18, 50, 200), (0, 0, 1000, 1000))))["reo_target"]
    assert custom[50] == pytest.approx(1000, rel=1e-12) and custom[200] == 1000


def test_flat_discount_rate():
    ws = ep.v1_3(ep.Params(discount_rate_flat=0.035))
    assert np.all(ws["dr"] == 0.035)
    np.testing.assert_allclose(ws["df"], np.cumprod(np.full(201, 1 / 1.035)), rtol=1e-12)
    base = ep.v1_3(ep.Params())
    assert np.array_equal(ws["cost_total"], base["cost_total"])
    assert ws["npv_total"][-1] != base["npv_total"][-1]


def test_capture_years_drive_the_year_indexed_switches():
    base = ep.v1_3(ep.Params())
    assert base["mtype_online"] == 85 and base["ctype_online"] == 105 and base["stype_online"] == 125
    assert np.flatnonzero(base["captured_asteroid_pgm"])[0] == 85
    assert np.flatnonzero(base["cost_dro_ops"])[0] == 85
    assert np.flatnonzero(base["cost_asteroid_processing"])[0] == 105
    assert np.flatnonzero(base["cargo_dro_infra"]).tolist() == [70, 80, 85, 95, 105, 115, 125]
    assert np.flatnonzero(base["tug_fleet"])[0] == 65
    assert base["mkiii_active"][114] == 1714 and base["mkiii_active"][115] == 300

    late = ep.v1_3(ep.Params(mtype_capture_year=80, ctype_capture_year=100, stype_capture_year=120))
    assert np.flatnonzero(late["captured_asteroid_pgm"])[0] == 90
    assert np.flatnonzero(late["cost_dro_ops"])[0] == 90
    assert np.flatnonzero(late["cost_asteroid_processing"])[0] == 110
    assert np.flatnonzero(late["cargo_dro_infra"]).tolist() == [75, 85, 90, 100, 110, 120, 130]
    assert np.flatnonzero(late["tug_fleet"])[0] == 70
    assert late["spa_msr_count"][109] == 0 and late["spa_msr_count"][110] == 1
    assert late["mkiii_active"][119] == 1714 and late["mkiii_active"][120] == 300
    assert np.flatnonzero(late["maint_molei_saving"])[0] == 115
    assert np.array_equal(late["reo_target"], base["reo_target"])


def test_params_are_frozen_and_hashable():
    p = ep.Params()
    with pytest.raises(dataclasses.FrozenInstanceError):
        p.scc = 200
    assert hash(p) == hash(ep.Params())
    assert hash(dataclasses.replace(p, scc=200)) != hash(p)
    # the workspace copies the circuit table, so a consumer cannot corrupt the defaults
    ws = ep.v1_3(p)
    ws["circuit_designs"][0]["mass_kg"] = 1
    assert ep.Params().circuit_designs[0]["mass_kg"] == 15000


def test_v1_3_speed():
    p = ep.Params()
    ep.v1_3(p)  # warm-up
    best = min(_timed(p) for _ in range(5))
    assert best <= 0.060, f"v1_3(Params()) took {best * 1e3:.1f} ms (limit 60 ms)"


def _timed(p):
    t0 = time.perf_counter()
    ep.v1_3(p)
    return time.perf_counter() - t0
