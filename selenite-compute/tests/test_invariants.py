"""Architectural invariants checked against the oracle today.

These read golden values only, so they run now. Each links a SysML model
commitment or a VALUE_CONFLICTS.md row to the number the computational
authority produced. Known gaps and conflicts are xfail with their id so the
register is live rather than prose.
"""
import numpy as np
import pytest

from selenite import goldens


def _val(rows, script, key):
    return next(r.value for r in rows if r.script == script and r.key == key)


def test_econ_reo_demand_reaches_programme_target(oracle_rows):
    # SEL-REQ-001 / SeleniteParameters.steadyStateReoTonnesPerYear: 2.5 Mt/yr.
    reo = _val(oracle_rows, "SELENITE_ECON_V1_3", "reo_demand")
    assert reo.size == 201 and reo[-1] == pytest.approx(2_500_000.0)
    assert _val(oracle_rows, "SELENITE_ECON_V1_3", "reo_final") == pytest.approx(2_500_000.0)


def test_econ_headline_figures(oracle_rows):
    # Final report Fig. 48 / CHANGELOG: NPV -$0.49 T, +$121.8 B/yr net at steady state.
    assert _val(oracle_rows, "SELENITE_ECON_V1_3", "baseline_npv") == pytest.approx(-0.49099449094, rel=1e-9)
    net = _val(oracle_rows, "SELENITE_ECON_V1_3", "net_total")
    assert net[-1] == pytest.approx(121_777, rel=1e-3)


def test_econ_molei_profile_is_vc07(oracle_rows):
    # VC-07 / F4: ECON v1.3 peak 357 (Y35), 53 from Y100 - the profile the documents do not carry.
    mi = _val(oracle_rows, "SELENITE_ECON_V1_3", "molei_needed")
    assert int(mi.max()) == 357 and int(mi[-1]) == 53


def test_verify_moleI_p3_profile_is_v5_0(oracle_rows):
    # VC-01: VERIFY v5.0 profile 5/30/55/90/180 (documents carry 10/25/50/85/170).
    mi = _val(oracle_rows, "SELENITE_VERIFY_v5_0", "ph.mi")
    np.testing.assert_array_equal(mi, [5, 30, 55, 90, 180])


@pytest.mark.xfail(strict=True, reason="VC-09 arbiter missing: ECON circuit/MSR-count vectors were dropped by golden runner v2.0 (console shows 2,083,334 circuits and 8,334 MSR at Y200); recapture with runner v2.1 or the port")
def test_econ_msr_count_vector_captured(oracle_rows):
    keys = {r.key for r in oracle_rows if r.script == "SELENITE_ECON_V1_3"}
    assert any(k.startswith(("msr_needed", "circuits_needed")) for k in keys)


@pytest.mark.xfail(strict=True, reason="F5 arbiter missing: ECON cargo_spa_msr vector dropped by golden runner v2.0")
def test_econ_spa_msr_cargo_vector_captured(oracle_rows):
    keys = {r.key for r in oracle_rows if r.script in ("SELENITE_ECON_V1_3", "SELENITE_ECON_V1_4")}
    assert "cargo_spa_msr" in keys
