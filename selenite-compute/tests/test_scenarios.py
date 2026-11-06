"""Wave 4A: the scenario layer (space, D1 physics, trades, run, tools).

The sampler, criteria and parametrised ECON have their own test files
(test_sample.py, test_criteria.py, test_econ_param.py); the model-reading
move has test_modelio.py. This file covers what the brief lists for the
subpackage as a whole: the register read from the model, common random
numbers across alternatives, D1 monotonicity, the evaluator / stub
declaration of every catalogued decision, every #moe reported, and the two
tools (scenario_check.py, plan_check.py --with-scenarios) end to end at a
small sample size.
"""
import importlib.util
import io
import sys
from contextlib import redirect_stdout
from pathlib import Path

import numpy as np
import pytest

from selenite import verify
from selenite.scenarios import criteria, eclipse, run as runner, sample as sampler, space as spacemod, trades

TOOLS = Path(__file__).resolve().parents[2] / "selenite-sysml-wave1-revC" / "selenite-sysml" / "tools"
DOCS = TOOLS.parent / "docs"


def _load_tool(name: str):
    spec = importlib.util.spec_from_file_location(name, TOOLS / f"{name}.py")
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


@pytest.fixture(scope="module")
def space():
    return spacemod.load_space()


@pytest.fixture(scope="module")
def small_run(space):
    return runner.run(space, n=24, seed=7)


# --------------------------------------------------------------------------
# The space read from the model
# --------------------------------------------------------------------------


def test_register_binds_only_to_existing_parameters(space):
    assert len(space.register) >= 30
    for e in space.register:
        for slot, attr in e.bindings.items():
            assert attr in space.params, (e.name, slot, attr)
        assert e.status in ("sampled", "point (range unbound)", "point (nominal unbound, evaluator assumption)",
                            "point (range recorded, kind pointValue)")


def test_wave3_ranges_are_sampled_and_unsourced_entries_are_points(space):
    assert space.entry("thoriumGradePpm").sampled and space.entry("thoriumGradePpm").low == 10.0
    assert space.entry("spaDarkFraction").sampled and abs(space.entry("spaDarkFraction").nominal - 0.15) < 1e-12
    assert not space.entry("mTypeCaptureYear").sampled          # range unbound -> point
    assert not space.entry("spaMsrAvailabilityProbability").sampled
    assert space.entry("eclipseRestartLossDaysPerEclipse").nominal is None   # evaluator assumption


def test_derived_parameter_expressions_are_evaluated(space):
    assert abs(space.params["spaDarkFraction"] - (1.0 - space.params["spaIlluminatedFraction"])) < 1e-12
    assert 0.029 < space.params["thoriumToReoMassRatio"] < 0.031
    assert space.params["decisionCriterion"] == "DecisionCriterion::expectedEarthMassWithSlipChance"


def test_catalogue_d1_to_d8_with_alternatives_and_evaluators(space):
    ids = [d.decision_id for d in space.decisions]
    assert ids == [f"D{i}" for i in range(1, 9)]
    names = {e.name for e in space.register}
    for d in space.decisions:
        assert d.alternatives, d.decision_id
        assert d.evaluator_status in ("evaluated", "stub")
        assert runner.evaluator_exists(d.evaluator), d.evaluator
        assert set(d.uncertain_inputs) <= names, d.decision_id
        assert d.stage in ("now", "recourse")
    d1 = space.decision("D1")
    assert [a.name for a in d1.alternatives] == list(eclipse.STRATEGIES)


def test_baseline_selections_match_the_catalogue(space):
    assert space.selections["d1"] == "EclipseOperatingStrategy::sunlitDutyCycle"   # SEL-ECN-023
    assert space.selections["d3"] is None      # open decision stays abstract
    for key, sel in space.selections.items():
        d = space.decision(key.upper())
        if sel is not None:
            var, alt = sel.split("::")
            assert var == d.variation and alt in [a.name for a in d.alternatives]


def test_verify_transcription_matches(space):
    assert eclipse.verify_transcription(space.params) == []
    v = verify.workspace()
    assert space.params["fspUnitMassKg"] == v["fsp"]["mass_kg"]


def test_sunlit_window_fits_every_sampled_batch(space):
    s = sampler.sample(space.dists, 500, 3)
    fits = eclipse.sunlit_window_fits(s.values["czochralskiBatchHours"], float(space.params["lunarSynodicPeriodHours"]),
                                      s.values["spaLongestEclipseHours"])
    assert fits.all()


# --------------------------------------------------------------------------
# Common random numbers and determinism
# --------------------------------------------------------------------------


def test_run_is_deterministic_under_seed(space):
    a = runner.run(space, n=12, seed=11, decisions=("D1", "D5"))
    b = runner.run(space, n=12, seed=11, decisions=("D1", "D5"))
    assert a.samples.hash == b.samples.hash
    for da, db in zip(a.decisions, b.decisions):
        for alt in da.alternatives:
            np.testing.assert_array_equal(da.moes[alt]["earthLaunchedMassTonnes"], db.moes[alt]["earthLaunchedMassTonnes"])
    c = runner.run(space, n=12, seed=12, decisions=("D5",))
    assert c.samples.hash != a.samples.hash


def test_alternatives_are_paired_on_the_same_samples(small_run):
    # Every alternative of every decision has one value per sample on the
    # same (n,) index; the programme-wide base is identical across the
    # alternatives of a decision that does not change ECON inputs.
    n = small_run.n
    for d in small_run.decisions:
        for alt in d.alternatives:
            assert d.moes[alt]["earthLaunchedMassTonnes"].shape == (n,)
    d5 = small_run.decision("D5")
    d1 = small_run.decision("D1")
    np.testing.assert_allclose(d5.moes["consequenceOfMTypeArrival"]["launchCo2Tonnes"],
                               d1.moes["carryThroughEclipse"]["launchCo2Tonnes"])


# --------------------------------------------------------------------------
# D1 physics
# --------------------------------------------------------------------------


def _inputs(hold: float, msr: bool = False, stored: float = 0.5) -> eclipse.SampleInputs:
    Y = trades.YEARS
    return eclipse.SampleInputs(
        dark=0.15, longest_eclipse_h=72.0, design_eclipse_h=72.0, batch_hours=48.0, oversize_kg_per_kw=70.0,
        restart_days=0.5, hold={"cTypeLine": hold, "sTypeLine": hold, "scaledOperations": hold}, stored=stored,
        msr_available=msr, fsp_kw=40.0, fsp_kg=6600.0, batt_wh_kg=250.0, batt_margin=1.2, panel_kg_m2=3.0,
        thcl4_year=43.0, solar_in_situ_year=60.0, solar_in_situ_ef=0.3, msr_mass_kg=50000.0, msr_ef_floor=0.3,
        c_online=105, s_online=125, plant_earth_fraction=np.full(201, 0.03),
        launch_cost=np.full(201, 2000.0), contingency=np.full(201, 1.25), df=np.ones(201))


@pytest.fixture(scope="module")
def site():
    return eclipse.site_constants(None, None, 50000.0)


def test_carry_through_reproduces_the_wave3_fallback(site):
    r = eclipse.evaluate_strategy("carryThroughEclipse", _inputs(0.25), site)
    assert r["derivedCriticalFraction"] == 1.0
    assert 6240 <= r["fspUnits"] <= 6260          # the register's "6,254 FSP max" family
    assert r["throughputLostFraction"] == 0.0 and r["batteryMassTonnes"] == 0.0


def test_d1_monotonic_more_pausable_load_no_more_fsp(site):
    # A lower hold-load fraction (more of the load pausable) never needs more FSP units.
    units = [eclipse.evaluate_strategy("sunlitDutyCycle", _inputs(h), site)["fspUnits"] for h in (1.0, 0.5, 0.25, 0.05, 0.0)]
    assert units == sorted(units, reverse=True)
    # Even a 100 % hold under the duty cycle never exceeds carry-through: the
    # Czochralski line is batch-scheduled between eclipses, not held.
    assert units[0] <= eclipse.evaluate_strategy("carryThroughEclipse", _inputs(0.25), site)["fspUnits"]
    assert units[-1] < 10


def test_duty_cycle_keeps_throughput_hot_standby_does_not(site):
    b = eclipse.evaluate_strategy("sunlitDutyCycle", _inputs(0.25), site)
    c = eclipse.evaluate_strategy("hotStandby", _inputs(0.25), site)
    assert b["throughputLostFraction"] == 0.0 and b["oversizeMassTonnes"] > 0
    assert c["throughputLostFraction"] > 0.15 and c["oversizeMassTonnes"] == 0
    # The duty cycle's hold load is a share of the oversized plant, so its derived fraction is higher.
    assert b["derivedCriticalFraction"] > c["derivedCriticalFraction"]
    assert abs(c["derivedCriticalFraction"] - 0.25 * 150.0 / 250.0) < 1e-9


def test_hybrid_battery_follows_the_verify_rule(site):
    d = eclipse.evaluate_strategy("hybridStorage", _inputs(0.25, stored=0.5), site)
    expected_kwh = 0.5 * 250_000.0 * 72.0 * 1.2
    assert abs(d["batteryMassTonnes"] - expected_kwh * 1000.0 / 250.0 / 1000.0) < 1e-6
    assert 0.5 < d["derivedCriticalFraction"] < 1.0


def test_msr_world_makes_carry_through_free(site):
    with_msr = eclipse.evaluate_strategy("carryThroughEclipse", _inputs(0.25, msr=True), site)
    without = eclipse.evaluate_strategy("carryThroughEclipse", _inputs(0.25, msr=False), site)
    assert with_msr["spaMsrFirstYear"] == 105.0 and np.isnan(without["spaMsrFirstYear"])
    assert without["earthMassSpaPowerTonnes"] > 100 * with_msr["earthMassSpaPowerTonnes"]


def test_break_even_probability_shape():
    be = eclipse.break_even_probability({"a": 100.0, "b": 200.0, "c": 100.0, "d": 1000.0, "e": 50.0},
                                        {"a": 10000.0, "b": 1000.0, "c": 1000.0, "d": 20000.0, "e": 12000.0}, reference="a")
    assert be["b"]["wins"] == "below" and abs(be["b"]["p"] - 9000.0 / 9100.0) < 1e-12
    assert be["c"]["wins"] == "always"                       # no worse in either world
    assert be["d"]["wins"] == "never" and np.isnan(be["d"]["p"])   # no better in either world
    assert be["e"]["wins"] == "above" and abs(be["e"]["p"] - 2000.0 / 2050.0) < 1e-12


def test_d1_register_run_recommends_and_reports_the_derived_fraction(small_run):
    d = small_run.decision("D1")
    assert d.lead.alternative in eclipse.STRATEGIES and d.lead.win_probability is not None
    for alt in d.alternatives:
        assert "derivedCriticalFraction" in d.summaries[alt]
    assert d.summaries["carryThroughEclipse"]["derivedCriticalFraction"]["mean"] == 1.0
    assert d.summaries["sunlitDutyCycle"]["derivedCriticalFraction"]["mean"] < 0.5
    assert "breakEvenProbability" in d.extras and "msrUnavailable" in d.extras["worlds"]
    # In the committed plan (MSR available) carry-through costs nothing extra; without the MSR the duty cycle wins.
    w = d.extras["worlds"]
    assert w["msrAvailable"]["carryThroughEclipse"]["earthMassSpaPowerTonnes"]["mean"] <= w["msrAvailable"]["sunlitDutyCycle"]["earthMassSpaPowerTonnes"]["mean"]
    assert w["msrUnavailable"]["sunlitDutyCycle"]["earthMassSpaPowerTonnes"]["mean"] < w["msrUnavailable"]["carryThroughEclipse"]["earthMassSpaPowerTonnes"]["mean"]


# --------------------------------------------------------------------------
# Every decision, every #moe, the criteria
# --------------------------------------------------------------------------


def test_every_moe_of_every_decision_is_reported(space, small_run):
    sc = _load_tool("scenario_check")
    errors = sc.structural_checks(space, small_run)
    assert errors == []
    for d in small_run.decisions:
        for alt in d.alternatives:
            for crit, rec in d.recommendations.items():
                assert rec.criterion == crit


def test_recourse_decisions_are_re_evaluated_per_sample(small_run):
    d3 = small_run.decision("D3")
    realised = d3.moes["shuttlecock"]["probabilityRealisedAsChosen"]
    assert set(np.unique(realised)) <= {0.0, 1.0}
    d7 = small_run.decision("D7")
    assert set(np.unique(d7.moes["capacityForced"]["probabilityCapacityForced"])) <= {0.0, 1.0}


def test_named_scenarios_move_what_they_override(space):
    late = runner.run(space, n=8, seed=5, scenario="lateMType", decisions=("D5",))
    base = runner.run(space, n=8, seed=5, scenario="baseline", decisions=("D5",))
    assert late.decision("D5").summaries["consequenceOfMTypeArrival"]["mdFourYear"]["mean"] == 95.0
    assert base.decision("D5").summaries["consequenceOfMTypeArrival"]["mdFourYear"]["mean"] == 85.0
    unavailable = runner.run(space, n=8, seed=5, scenario="msrUnavailable", decisions=("D1",))
    assert unavailable.decision("D1").lead.alternative in ("sunlitDutyCycle", "hotStandby")


# --------------------------------------------------------------------------
# The tools
# --------------------------------------------------------------------------


def test_scenario_check_prints_the_register_sections(tmp_path):
    sc = _load_tool("scenario_check")
    out = tmp_path / "reg.md"
    buf = io.StringIO()
    with redirect_stdout(buf):
        rc = sc.main(["--n", "12", "--seed", "3", "--scenario-n", "6", "--markdown", str(out), "--quiet"])
    assert rc == 0
    text = out.read_text(encoding="utf-8")
    for section in ("## 1. Uncertainty register", "## 2. Decisions", "### D1", "### D8", "## 3. Gate-year distributions",
                    "## 4. Named scenarios", "## 5. Structural checks", "All structural checks passed.",
                    "Declared versus derived eclipse-critical fraction", "break-even"):
        assert section in text, section
    assert "n = 12 samples, seed 3" in text
    assert "D1:" in buf.getvalue() and "largest SE" in buf.getvalue()


def test_plan_check_with_scenarios_adds_one_column_and_default_is_unchanged(tmp_path):
    pc = _load_tool("plan_check")
    default = tmp_path / "default.md"
    with redirect_stdout(io.StringIO()):
        assert pc.main(["--markdown", str(default), "--quiet"]) == 0
    assert default.read_bytes() == (DOCS / "PLAN_REGISTER.md").read_bytes()
    withs = tmp_path / "with.md"
    with redirect_stdout(io.StringIO()):
        assert pc.main(["--markdown", str(withs), "--quiet", "--with-scenarios", "--scenario-samples", "8"]) == 0
    a = default.read_text(encoding="utf-8").splitlines()
    b = withs.read_text(encoding="utf-8").splitlines()
    assert len(a) == len(b)
    header_a = next(l for l in a if l.startswith("| Gate | Kind |"))
    header_b = next(l for l in b if l.startswith("| Gate | Kind |"))
    assert header_b == header_a + " P(met by declared year) |"
    # rows outside the gate table are unchanged
    tail_a = a[a.index("## 2. Element register (configuration bindings)"):]
    tail_b = b[b.index("## 2. Element register (configuration bindings)"):]
    assert tail_a == tail_b
