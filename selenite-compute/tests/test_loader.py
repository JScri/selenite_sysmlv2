"""The loader itself is tested for real today; it does not depend on the port."""
import math

import numpy as np

from selenite import goldens


def test_all_rows_load(oracle_rows):
    scripts = {r.script for r in oracle_rows}
    # The merged, tagged oracle carries six scripts (1,016 rows). VISUALIZE's
    # 47 geometry rows exist only in the raw matlab_r2025a capture.
    assert scripts <= set(goldens.SCRIPT_TO_MODULE), scripts
    assert "SELENITE_VISUALIZE_v3_3" not in scripts
    assert len(oracle_rows) == 1016, len(oracle_rows)


def test_row_counts_match_oracle_manifest(oracle_rows):
    import json
    manifest = json.loads((goldens.oracle_dir() / "ORACLE_MANIFEST.json").read_text())
    expected = {s["script"]: s["rows"] for s in manifest["scripts"]}
    got = {}
    for r in oracle_rows:
        got[r.script] = got.get(r.script, 0) + 1
    assert got == expected


def test_arrays_parse_to_numpy(oracle_rows):
    arrays = [r for r in oracle_rows if r.raw.startswith("[") and r.is_array]
    assert arrays, "no arrays parsed"
    ph_isru = next(r for r in arrays if r.id == "SELENITE_VERIFY_v5_0::ph.isru")
    np.testing.assert_array_equal(ph_isru.value, [28460, 170760, 313060, 512280, 1024560])


def test_nan_row_is_irr_direct(oracle_rows):
    nans = [r for r in oracle_rows if r.is_nan]
    assert [r.id for r in nans] == ["SELENITE_ECON_V1_4::irr_direct"]
    assert math.isnan(nans[0].value)


def test_tag_vocabulary(oracle_rows):
    assert {r.comparable for r in oracle_rows} == {"yes", "platform_dependent_ode"}
    ode = [r for r in oracle_rows if r.is_ode]
    assert len(ode) == 26 and all(r.script == "MOLEI_THERMAL_v1_3" for r in ode)
    assert sum(r.octave_only for r in oracle_rows) == 35 + 3 + 8 + 15 + 17
