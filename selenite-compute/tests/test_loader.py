"""The loader itself is tested for real today; it does not depend on the port."""
import json
import math

import numpy as np

from selenite import goldens


def test_all_current_scripts_load(oracle_rows):
    scripts = {r.script for r in oracle_rows}
    assert scripts == set(goldens.CURRENT_SCRIPTS), scripts
    manifest = json.loads((goldens.oracle_dir() / "manifest.json").read_text())
    expected = {s["file"][:-2]: s["n_values"] for s in manifest["scripts"] if s["status"] == "ok"}
    got = {}
    for r in oracle_rows:
        got[r.script] = got.get(r.script, 0) + 1
    for stem in goldens.CURRENT_SCRIPTS:
        assert got[stem] == expected[stem], (stem, got[stem], expected[stem])
    assert len(oracle_rows) == sum(expected[s] for s in goldens.CURRENT_SCRIPTS)


def test_v2_1_restores_dropped_vectors(oracle_rows):
    keys = {(r.script, r.key) for r in oracle_rows}
    for k in ("circuits_needed", "haulers_needed", "conv_km_needed", "cargo_spa_msr", "msr_count", "spa_msr_count"):
        assert ("SELENITE_ECON_V1_3", k) in keys, k
    for k in ("ph.mi", "ph.nd", "ph.nARMC", "ph.p_tot"):
        assert ("SELENITE_VERIFY_v5_0", k) in keys, k


def test_arrays_parse_to_numpy(oracle_rows):
    ph_isru = next(r for r in oracle_rows if r.id == "SELENITE_VERIFY_v5_0::ph.isru")
    assert ph_isru.is_array
    np.testing.assert_array_equal(ph_isru.value, [28460, 170760, 313060, 512280, 1024560])


def test_nan_row_is_irr_direct(oracle_rows):
    nans = [r for r in oracle_rows if r.is_nan]
    assert {r.id for r in nans} == {"SELENITE_ECON_V1_4::irr_direct"}, {r.id for r in nans}
    assert math.isnan(nans[0].value)


def test_ode_tags_carried_from_merged_oracle(oracle_rows):
    ode = [r for r in oracle_rows if r.is_ode]
    assert ode and all(r.script == "MOLEI_THERMAL_v1_3" for r in ode)
    assert {r.comparable for r in oracle_rows} == {"yes", "platform_dependent_ode"}
