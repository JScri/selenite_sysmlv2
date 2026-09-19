"""Wave 3 extension vectors (no golden): shape, monotonicity and the
VERIFY splice are the invariants; the numbers are assumptions by design."""
import numpy as np
import pytest

from selenite import plan_vectors as pv, verify


def test_spa_power_shape_and_p7_splice():
    sp = pv.spa_power()
    assert sp["p_tot"].shape == (201,)
    ph = verify.workspace()["ph"]
    # Y18..Y24 of the spliced reference vector equal VERIFY's P7 sizing.
    assert np.allclose(sp["p_ref_to_p7"][18:25], ph["p_tot"][4])
    assert sp["p7_sized_capability_kw"] == pytest.approx(float(ph["p_tot"][4]))
    # At Y25 (247 MOLE-I vs 180 sized) the scaled demand exceeds the P7 sizing.
    assert sp["p_tot"][25] > sp["p7_sized_capability_kw"]


def test_asteroid_loads_only_from_y105():
    a = pv.spa_power(with_asteroid_loads=True)["p_asteroid"]
    assert a[104] == 0 and a[105] == 50_000 and a[125] == 150_000 and a[140] == 250_000


def test_thorium_stockpile_monotone_and_bounds():
    lo = pv.thorium_stockpile(pv.TH_TO_REO_RATIO_LOW)
    hi = pv.thorium_stockpile(pv.TH_TO_REO_RATIO_HIGH)
    assert np.all(np.diff(lo) >= 0) and np.all(hi >= lo)
    assert pv.first_year_stockpile_reaches(40.0, pv.TH_TO_REO_RATIO_HIGH) is not None


def test_not_a_port():
    assert pv.PORTED is False


def test_thorium_ratio_from_grades():
    r = pv.thorium_ratio(12.5, 500.0, 0.92)
    assert 0.028 < r < 0.031
    assert pv.thorium_ratio(10.0, 500.0, 0.90) < r < pv.thorium_ratio(15.0, 500.0, 0.95)


def test_critical_load_is_a_small_fraction_of_total():
    cp = pv.spa_critical_power()
    sp = pv.spa_power()
    assert np.all(cp["p_critical"][18:] < 0.2 * sp["p_tot"][18:])


def test_fsp_msr_trade_bases_and_routes():
    inc = pv.fsp_msr_trade(md3_year=43, basis="incremental")
    asb = pv.fsp_msr_trade(md3_year=43, basis="asbuilt")
    assert set(inc["routes"]) == {"fsp", "solar", "msr_earth_fraction", "msr_in_situ_fraction"}
    # As-built counts the whole array, so it can only make the MSR worth it earlier.
    assert asb["first_justified_year"] <= inc["first_justified_year"]
    assert inc["first_justified_year"] >= 43
    # Solar is the dominant non-nuclear cargo once asteroid loads arrive.
    assert inc["solar_earth_mass_kg"][105] > inc["fsp_earth_mass_kg"][105]
    with pytest.raises(ValueError):
        pv.fsp_msr_trade(43, basis="wrong")
