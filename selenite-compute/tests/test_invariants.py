"""Architectural invariants checked against the oracle today.

These read golden values only, so they run now. Each links a SysML model
commitment or a VALUE_CONFLICTS.md / DOCUMENT_FAMILIES.md row to the number
the computational authority produced.
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


def test_econ_headline_figures(oracle_rows):
    # Final report Fig. 48: NPV -$0.49 T, +$121.8 B/yr net at steady state.
    assert _val(oracle_rows, "SELENITE_ECON_V1_3", "baseline_npv") == pytest.approx(-0.49099449094, rel=1e-9)
    assert _val(oracle_rows, "SELENITE_ECON_V1_3", "net_total")[-1] == pytest.approx(121_777, rel=1e-3)


def test_econ_circuits_at_steady_state(oracle_rows):
    # "Consistent" per VALUE_CONFLICTS.md: 2,083,334 circuits at 2.5 Mt/yr.
    assert int(_val(oracle_rows, "SELENITE_ECON_V1_3", "circuits_needed").max()) == 2_083_334


def test_vc09_msr_count_is_econ_not_document(oracle_rows):
    # VC-09: documents say 6,890 MSR at P14; ECON v1.3 gives 8,334 at Y200. The model
    # still carries the Wave 1 document value (ProgrammeConfiguration.msrUnitCountAtP14)
    # pending Wave 5 adjudication. This test pins the golden side of the conflict.
    msr = _val(oracle_rows, "SELENITE_ECON_V1_3", "msr_count")
    assert int(msr[-1]) == 8_334
    assert int(msr[-1]) != 6_890


def test_f5_econ_assumed_spa_msr_at_y105(oracle_rows):
    # F5 arbiter: SelenitePower::SpaThoriumMSR.econAssumedIntroductionYear = 105.
    for script in ("SELENITE_ECON_V1_3", "SELENITE_ECON_V1_4"):
        cargo = _val(oracle_rows, script, "cargo_spa_msr")
        nz = np.flatnonzero(cargo)
        assert nz[0] == 105 and list(nz[:3]) == [105, 125, 140], (script, nz[:5])


def test_econ_molei_profile_is_vc07(oracle_rows):
    # VC-07 / F4: ECON v1.3 peak 357, 53 from Y100.
    mi = _val(oracle_rows, "SELENITE_ECON_V1_3", "molei_needed")
    assert int(mi.max()) == 357 and int(mi[-1]) == 53


def test_econ_steady_state_fleet(oracle_rows):
    # VC-08 / VC-10 golden side: 1.5 M haulers and 137,500 km conveyor at Y200.
    assert int(_val(oracle_rows, "SELENITE_ECON_V1_3", "haulers_needed")[-1]) == 1_500_000
    assert _val(oracle_rows, "SELENITE_ECON_V1_3", "conv_km_needed")[-1] == pytest.approx(137_500.0)


def test_verify_moleI_p3_profile_is_v5_0(oracle_rows):
    # VC-01: VERIFY v5.0 profile 5/30/55/90/180 (documents carry 10/25/50/85/170).
    np.testing.assert_array_equal(_val(oracle_rows, "SELENITE_VERIFY_v5_0", "ph.mi"), [5, 30, 55, 90, 180])
