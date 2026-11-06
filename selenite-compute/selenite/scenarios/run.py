"""The catalogue run: one ``DecisionResult`` per decision.

Wave 4A extension (6 Nov 2026), NOT a port, no golden. ``run(space, n, seed)``
samples the uncertainty register once (``sample``, Latin hypercube by
default, fixed seed, common random numbers), runs the parametrised ECON on
every sample (``trades.run_econ``), evaluates every alternative of every
decision on those same samples (``eclipse.evaluate_strategy`` for D1,
``trades.evaluate_d2`` ... ``evaluate_d8``), summarises every measure of
value (mean / P10 / P50 / P90 / standard error), scores the alternatives
under every criterion (``criteria``) and leads with the recommendation under
``ProgrammeParameters.decisionCriterion``. Named scenarios
(``SeleniteScenarios::ScenarioSet``) hold the overridden entries constant and
leave the rest sampled.

Two-stage structure: a here-and-now decision is one alternative evaluated on
every sample; a recourse decision is re-evaluated per sample from the
information the sample contains (the MSR year from the trade, the realised
canister architecture after the test, the Mk III trigger from capacity or
test). Results are quantiles, never single numbers; every recommendation
carries its criterion and win probability.
"""
from __future__ import annotations

import importlib
from dataclasses import dataclass, field

import numpy as np

from .. import econ, verify
from . import criteria, eclipse, trades
from .modelio import parse_gates, read_model
from .sample import Dist, Samples, sample
from .space import Space, load_space

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

DEFAULT_N = 2000
DEFAULT_SEED = 20260920

# Auxiliary uniform draws for the sampled test outcomes (part of the common
# random numbers, so the same test passes or fails for every alternative).
EVENT_DRAWS = ("u:msrAvailable", "u:impactSurvival1b", "u:impactSurvival2", "u:mkIiiTest")

# Which criterion leads for each ProgrammeParameters.decisionCriterion value
# and in which sense the objective is read.
CRITERION_MAP = {
    "expectedEarthMassWithSlipChance": ("chanceConstrained", "earthLaunchedMassTonnes", "min"),
    "expectedNpv": ("expectedValue", "npvUsdB", "max"),
    "lexicographicMassThenNpv": ("expectedValue", "earthLaunchedMassTonnes", "min"),
}

# Gates whose declared year ECN-022 superseded: reported, excluded from the slip.
SUPERSEDED_GATES = {"DG-10.5": "ECN-022 s.2.3 (Y50 superseded)", "DG-11.3": "ECN-022 s.2.3 (Y70 superseded)"}


@dataclass
class DecisionResult:
    decision_id: str
    variation: str
    title: str
    stage: str
    alternatives: list[str]
    moes: dict[str, dict[str, np.ndarray]]              # alt -> moe -> (n,)
    summaries: dict[str, dict[str, dict[str, float]]]   # alt -> moe -> summarise()
    recommendations: dict[str, criteria.Recommendation] # criterion -> recommendation
    lead_criterion: str
    lead: criteria.Recommendation
    objective_moe: str
    sense: str
    gate_years: dict[str, dict[str, np.ndarray]]       # gate -> alt -> years (n,), NaN never
    gate_declared: dict[str, float | None]
    feasible: dict[str, np.ndarray]                     # alt -> bool (n,)
    evaluator_status: str
    notes: list[str] = field(default_factory=list)
    extras: dict[str, object] = field(default_factory=dict)


@dataclass
class RunResult:
    space: Space
    samples: Samples
    n: int
    seed: int
    method: str
    scenario: str
    overrides: dict[str, float]
    decisions: list[DecisionResult]
    econ_runs: trades.EconRuns
    assumptions: dict[str, object]
    convergence: dict[str, float]

    def decision(self, decision_id: str) -> DecisionResult:
        for d in self.decisions:
            if d.decision_id == decision_id:
                return d
        raise KeyError(decision_id)


# --------------------------------------------------------------------------
# Sampling with scenario overrides
# --------------------------------------------------------------------------


def dists_for(space: Space) -> list[Dist]:
    dists = space.dists
    for name in EVENT_DRAWS:
        dists.append(Dist(name, "uniform", 0.5, 0.0, 1.0, source="event draw (common random numbers)"))
    return dists


def integer_entries(space: Space) -> set[str]:
    """Register entries whose nominal ProgrammeParameters attribute is an
    Integer (years): their samples are rounded to whole years."""
    out = set()
    for e in space.register:
        attr = e.bindings.get("nominal")
        v = space.params.get(attr) if attr else None
        if isinstance(v, int) and not isinstance(v, bool):
            out.add(e.name)
    return out


def draw(space: Space, n: int, seed: int, method: str = "lhs", overrides: dict[str, float] | None = None) -> Samples:
    s = sample(dists_for(space), n, seed, method)
    for name in integer_entries(space):
        s.values[name][:] = np.round(s.values[name])
    for name, value in (overrides or {}).items():
        if name in s.values:
            s.values[name][:] = float(value)
    return s


def nominal_samples(space: Space, overrides: dict[str, float] | None = None) -> Samples:
    """One 'sample' with every register entry at its nominal value and every
    test outcome passing (event draws at 0): the committed plan."""
    dists = dists_for(space)
    values = {d.name: np.array([0.0 if d.name in EVENT_DRAWS else float(d.nominal)]) for d in dists}
    for name, value in (overrides or {}).items():
        if name in values:
            values[name][:] = float(value)
    return Samples(1, 0, "nominal", tuple(), np.zeros((1, 0)), values, tuple(d.name for d in dists), "")


def circuit_earth_fraction_by_year(p: trades.econ_param.Params) -> np.ndarray:
    """ECON v1.3's circuit Earth-fraction trajectory with the C-type and
    S-type reductions on the sampled arrival years (the proxy for the
    Earth-launched share of oversize asteroid plant)."""
    Y = trades.YEARS
    ef = np.minimum(1.0, np.maximum(p.circuit_earth_frac_floor, 1.0 - (Y - p.circuit_earth_frac_start_year) * p.circuit_earth_frac_slope))
    c_on = p.ctype_capture_year + p.asteroid_online_lag
    s_on = p.stype_capture_year + p.asteroid_online_lag
    ramp_c = np.clip((Y - c_on) / p.reduction_ramp_years, 0.0, 1.0)
    ef = np.where(Y >= c_on, np.maximum(p.ctype_floor, ef - p.ctype_reduction * ramp_c), ef)
    ramp_s = np.clip((Y - s_on) / p.reduction_ramp_years, 0.0, 1.0)
    ef = np.where(Y >= s_on, np.maximum(p.stype_floor, ef - p.stype_reduction * ramp_s), ef)
    return ef


# --------------------------------------------------------------------------
# D1
# --------------------------------------------------------------------------


_LOSS_RUN_CACHE: dict[tuple, dict[str, np.ndarray]] = {}


def evaluate_d1(space: Space, samples: Samples, runs: trades.EconRuns, assumptions: dict[str, object]) -> dict[str, dict[str, np.ndarray]]:
    v = samples.values
    n = samples.n
    w = econ.workspace("SELENITE_ECON_V1_3")
    vv = verify.workspace()
    site = eclipse.site_constants(w, vv, float(space.params["spaMsrFirstUnitRatedKw"]))
    hold = dict(assumptions["holdLoadFraction"])
    restart = float(assumptions["restartLossDays"])
    plant_ef_override = assumptions.get("asteroidPlantEarthFraction")
    stored = float(space.params["hybridStoredLoadFraction"])
    design_h = float(space.params["spaDesignEclipseHours"])
    base = trades.programme_moes(runs)
    out: dict[str, dict[str, list[float]]] = {s: {} for s in eclipse.STRATEGIES}
    for i in range(n):
        g = lambda name: float(v[name][i])  # noqa: E731
        p = runs.params[i]
        plant_ef = (np.full(201, float(plant_ef_override)) if plant_ef_override is not None
                    else circuit_earth_fraction_by_year(p))
        x = eclipse.SampleInputs(
            dark=g("spaDarkFraction"), longest_eclipse_h=g("spaLongestEclipseHours"), design_eclipse_h=design_h,
            batch_hours=g("czochralskiBatchHours"), oversize_kg_per_kw=g("plantOversizeMassPenaltyKgPerKw"),
            restart_days=restart, hold=hold, stored=stored,
            msr_available=bool(v["u:msrAvailable"][i] < g("spaMsrAvailabilityProbability")),
            fsp_kw=g("fspUnitPowerKw"), fsp_kg=g("fspUnitMassKg"), batt_wh_kg=g("batterySpecificEnergyWhPerKg"),
            batt_margin=float(space.params["batteryMarginFactor"]), panel_kg_m2=g("solarPanelMassKgPerM2"),
            thcl4_year=g("thcl4AvailableYear"), solar_in_situ_year=g("solarInSituStartYear"),
            solar_in_situ_ef=float(space.params["solarInSituEarthFraction"]),
            msr_mass_kg=g("msrUnitMassKg"), msr_ef_floor=g("msrEarthFractionFloor"),
            c_online=p.ctype_capture_year + p.asteroid_online_lag, s_online=p.stype_capture_year + p.asteroid_online_lag,
            plant_earth_fraction=plant_ef, launch_cost=runs.vectors["launch_cost"][i],
            contingency=runs.vectors["contingency"][i], df=runs.vectors["df"][i])
        for strategy in eclipse.STRATEGIES:
            r = eclipse.evaluate_strategy(strategy, x, site)
            for k, val in r.items():
                out[strategy].setdefault(k, []).append(val)
    result: dict[str, dict[str, np.ndarray]] = {}
    for strategy, cols in out.items():
        m = {k: np.asarray(val, dtype=float) for k, val in cols.items()}
        lost_c, lost_s = m["throughputLostCTypeLine"], m["throughputLostSTypeLine"]
        if np.any(lost_c > 0) or np.any(lost_s > 0):
            # Lost output scales the circuit Earth-fraction reductions the lines
            # enable; the loss does not depend on the MSR world, so the re-run
            # is cached across the worlds of one sample set.
            key = (samples.hash, strategy, lost_c.tobytes(), lost_s.tobytes(), runs.n)
            if key not in _LOSS_RUN_CACHE:
                _LOSS_RUN_CACHE.clear() if len(_LOSS_RUN_CACHE) > 16 else None
                _LOSS_RUN_CACHE[key] = trades.programme_moes(trades.run_econ(
                    v, n, base=runs,
                    per_sample={"ctype_reduction": 0.07 * (1.0 - lost_c), "stype_reduction": 0.022 * (1.0 - lost_s)}))
            prog = _LOSS_RUN_CACHE[key]
        else:
            prog = base
        m["earthLaunchedMassTonnes"] = prog["earthLaunchedMassTonnes"] + m["earthMassSpaPowerTonnes"]
        m["npvUsdB"] = prog["npvUsdB"] + m["npvDeltaUsdM"] / 1000.0
        m["directBcr"] = prog["directBcr"]
        m["launchCo2Tonnes"] = prog["launchCo2Tonnes"]
        m["throughputPenaltyTonnes"] = prog["earthLaunchedMassTonnes"] - base["earthLaunchedMassTonnes"]
        first, u2, u3 = m["spaMsrFirstYear"], m["spaMsrUnit2Year"], m["spaMsrUnit3Year"]
        m["gateYear:DG-10.5"] = first
        m["gateYear:DG-11.3"] = first
        m["gateYear:DG-13.4"] = first
        m["gateYear:DG-14.4"] = u2
        m["gateYear:DG-14.7"] = u3
        m["milestoneSlipYears"] = np.maximum.reduce([
            np.maximum(0.0, np.nan_to_num(first, nan=eclipse.NEVER) - 105.0),
            np.maximum(0.0, np.nan_to_num(u2, nan=eclipse.NEVER) - 125.0),
            np.maximum(0.0, np.nan_to_num(u3, nan=eclipse.NEVER) - 140.0)])
        result[strategy] = m
    return result


def d1_worlds(space: Space, samples: Samples, runs: trades.EconRuns, assumptions: dict[str, object],
              main: dict[str, dict[str, np.ndarray]] | None = None) -> dict[str, object]:
    """The two worlds D1 turns on, evaluated on the same samples: the SPA
    MSR available at the asteroid arrival, and unavailable. Returns the
    expected SPA power-side Earth mass per strategy in each and the
    break-even availability probability of every strategy against
    carry-through."""
    worlds = {}
    p_main = samples.values["spaMsrAvailabilityProbability"]
    for name, available in (("msrAvailable", 1.0), ("msrUnavailable", 0.0)):
        if main is not None and np.all(p_main == available):
            r = main                      # the main run already is this world
        else:
            s = Samples(samples.n, samples.seed, samples.method, samples.names, samples.u,
                        {k: val.copy() for k, val in samples.values.items()}, samples.point_names, samples.warning)
            s.values["spaMsrAvailabilityProbability"][:] = available
            r = evaluate_d1(space, s, runs, assumptions)
        worlds[name] = {alt: {k: criteria.summarise(val) for k, val in m.items()} for alt, m in r.items()}
    mass_msr = {alt: worlds["msrAvailable"][alt]["earthMassSpaPowerTonnes"]["mean"] for alt in eclipse.STRATEGIES}
    mass_fsp = {alt: worlds["msrUnavailable"][alt]["earthMassSpaPowerTonnes"]["mean"] for alt in eclipse.STRATEGIES}
    return {"worlds": worlds, "breakEvenProbability": eclipse.break_even_probability(mass_msr, mass_fsp)}


# --------------------------------------------------------------------------
# Assembly
# --------------------------------------------------------------------------


def summarise_measure(x: np.ndarray) -> dict[str, float]:
    """``criteria.summarise`` for finite measures; a year-valued measure that
    uses NaN for 'never' is summarised over the finite samples with the
    share of 'never' samples added as ``pNever`` (all-NaN gives NaN)."""
    x = np.asarray(x, dtype=float)
    nan = np.isnan(x)
    if not nan.any():
        return criteria.summarise(x)
    finite = x[~nan]
    if finite.size == 0:
        return {"mean": np.nan, "std": np.nan, "se": np.nan, "p10": np.nan, "p50": np.nan, "p90": np.nan,
                "min": np.nan, "max": np.nan, "pNever": 1.0}
    s = criteria.summarise(finite)
    s["pNever"] = float(nan.mean())
    return s


def _summaries(moes: dict[str, dict[str, np.ndarray]]) -> dict[str, dict[str, dict[str, float]]]:
    return {alt: {k: summarise_measure(val) for k, val in m.items() if val.dtype.kind == "f"} for alt, m in moes.items()}


def slip_years(spec, moes: dict[str, dict[str, np.ndarray]], gates: dict[str, float | None],
               kinds: dict[str, str], reference: dict[str, float]) -> dict[str, np.ndarray]:
    """Milestone slip per alternative and sample: the largest lateness of the
    decision's derivable gates (ECN-022 standing years) against the plan's
    own date - the declared year, or the Wave 3 derived year at nominal
    where the deterministic register already derives the gate later
    (W3-R rows). Exogenous gates (declared policy years) are excluded: an
    uncertainty every alternative shares cannot separate them."""
    out = {}
    for alt, m in moes.items():
        n = len(next(iter(m.values())))
        slip = np.zeros(n)
        for gate in spec.gates:
            key = f"gateYear:{gate}"
            if key not in m or gate in SUPERSEDED_GATES or kinds.get(gate) != "derivable":
                continue
            declared = gates.get(gate)
            if declared is None:
                continue
            ref = max(float(declared), float(reference.get(gate, declared)))
            slip = np.maximum(slip, np.maximum(0.0, np.nan_to_num(m[key], nan=eclipse.NEVER) - ref))
        out[alt] = slip
    return out


def _assemble(space: Space, spec, moes: dict[str, dict[str, np.ndarray]], lead_criterion: str, objective: str,
              sense: str, threshold: float, gates: dict[str, float | None], notes: list[str] | None = None,
              extras: dict[str, object] | None = None, kinds: dict[str, str] | None = None,
              reference: dict[str, float] | None = None) -> DecisionResult:
    alts = [a.name for a in spec.alternatives]
    values = {alt: moes[alt][objective] for alt in alts}
    slips = slip_years(spec, moes, gates, kinds or {}, reference or {})
    for alt in alts:
        moes[alt]["milestoneSlipYears"] = slips[alt]
    feasible = {alt: slips[alt] <= 0.0 for alt in alts}
    recs = {}
    for crit in criteria.CRITERIA:
        recs[crit] = criteria.recommend(values, sense, feasible, crit, threshold=threshold)
    lead = recs[lead_criterion]
    lead_used = lead_criterion
    if lead.alternative is None:
        # No alternative meets the chance constraint: fall back to expected value and say so.
        notes = list(notes or []) + [f"no alternative meets P(no slip) >= {threshold:.2f}; the lead falls back to expectedValue"]
        lead = recs["expectedValue"]
        lead_used = "expectedValue"
    gate_years = {}
    for gate in spec.gates:
        key = f"gateYear:{gate}"
        gate_years[gate] = {alt: moes[alt][key] for alt in alts if key in moes[alt]}
    ex = dict(extras or {})
    ex["defaultCriterion"] = lead_criterion
    return DecisionResult(spec.decision_id, spec.variation, spec.title, spec.stage, alts, moes, _summaries(moes),
                          recs, lead_used, lead, objective, sense, gate_years,
                          {g: gates.get(g) for g in spec.gates}, feasible, spec.evaluator_status, list(notes or []), ex)


def generic_gate_years(space: Space, samples: Samples, runs: trades.EconRuns) -> dict[str, np.ndarray]:
    """Derived years, per sample, for the catalogue gates no evaluator owns:
    the same derivations plan_check uses on the sampled ECON vectors."""
    v = runs.vectors
    T = space.thresholds
    earth = v["earth_cargo"]
    total = earth + v["insitu_total"]
    with np.errstate(divide="ignore", invalid="ignore"):
        frac = np.where(total > 0, earth / total, np.nan)
    return {
        "DG-9.1": trades.first_year_matrix(v["canisters_yr"] > 0),
        "DG-9.6": samples.values["thcl4AvailableYear"].astype(float),
        "DG-14.6": trades.first_year_matrix(np.nan_to_num(frac, nan=1.0) < T["earthDependencyMaximumFraction"]),
        "DG-11.7": np.full(samples.n, np.nan),
    }


def run(space: Space | None = None, n: int = DEFAULT_N, seed: int = DEFAULT_SEED, method: str = "lhs",
        scenario: str = "baseline", decisions: tuple[str, ...] | None = None) -> RunResult:
    space = space or load_space()
    overrides = {}
    for s in space.scenarios:
        if s.name == scenario:
            overrides = dict(s.overrides)
            break
    else:
        raise KeyError(f"unknown scenario {scenario!r}; model scenarios: {[s.name for s in space.scenarios]}")
    assumptions: dict[str, object] = {
        "holdLoadFraction": dict(eclipse.ASSUMED_HOLD_LOAD_FRACTION),
        "restartLossDays": eclipse.ASSUMED_RESTART_LOSS_DAYS,
        "asteroidPlantEarthFraction": None,
    }
    if "holdLoadFraction" in overrides:
        assumptions["holdLoadFraction"] = {k: float(overrides["holdLoadFraction"]) for k in eclipse.ASSUMED_HOLD_LOAD_FRACTION}
    if "asteroidPlantEarthFraction" in overrides:
        assumptions["asteroidPlantEarthFraction"] = float(overrides["asteroidPlantEarthFraction"])
    restart_param = space.params.get("eclipseRestartLossDaysPerEclipse")
    if restart_param is not None:
        assumptions["restartLossDays"] = float(restart_param)

    crit_value = str(space.params.get("decisionCriterion", "")).split("::")[-1]
    lead_criterion, objective, sense = CRITERION_MAP.get(crit_value, CRITERION_MAP["expectedEarthMassWithSlipChance"])
    threshold = float(space.params.get("chanceConstraintThreshold") or 0.8)
    gates, _ = parse_gates(read_model()["Gates.sysml"])
    declared = {gid: g.declared_year for gid, g in gates.items()}
    kinds = {gid: g.evaluability for gid, g in gates.items()}
    wanted = set(decisions or [d.decision_id for d in space.decisions])

    # The committed plan at nominal: the reference dates the slips are measured against.
    nominal = nominal_samples(space, overrides)
    nominal_runs = trades.run_econ(nominal.values, 1)
    reference = reference_years(space, nominal, nominal_runs, assumptions, wanted)

    samples = draw(space, n, seed, method, overrides)
    runs = trades.run_econ(samples.values, n)
    evaluated = evaluate_all(space, samples, runs, assumptions, wanted)
    results = []
    for spec in space.decisions:
        if spec.decision_id not in wanted:
            continue
        moes, notes, extras = evaluated[spec.decision_id]
        if spec.decision_id == "D1":
            extras = d1_worlds(space, samples, runs, assumptions, main=moes)
        for gate in spec.gates:
            if gate in SUPERSEDED_GATES:
                notes.append(f"{gate} declared year superseded by {SUPERSEDED_GATES[gate]}; reported, excluded from the slip")
        results.append(_assemble(space, spec, moes, lead_criterion, objective, sense, threshold, declared, notes, extras,
                                 kinds, reference))
    convergence = convergence_line(results, objective)
    return RunResult(space, samples, n, seed, method, scenario, overrides, results, runs, assumptions, convergence)


def evaluate_all(space: Space, samples: Samples, runs: trades.EconRuns, assumptions: dict[str, object],
                 wanted: set[str]) -> dict[str, tuple[dict, list[str], dict]]:
    """Every wanted decision's alternatives on the given samples:
    decision id -> (moes, notes, extras)."""
    n = samples.n
    generic = generic_gate_years(space, samples, runs)
    w = econ.workspace("SELENITE_ECON_V1_3")
    vv = verify.workspace()
    site = eclipse.site_constants(w, vv, float(space.params["spaMsrFirstUnitRatedKw"]))
    content = {"fullParachute": float(space.params["canisterEarthContentFullParachuteKg"]),
               "minimalDragChute": float(space.params["canisterEarthContentDragChuteKg"]),
               "shuttlecock": float(space.params["canisterEarthContentShuttlecockKg"])}
    out = {}
    for spec in space.decisions:
        if spec.decision_id not in wanted:
            continue
        notes: list[str] = []
        extras: dict[str, object] = {}
        if spec.decision_id == "D1":
            moes = evaluate_d1(space, samples, runs, assumptions)
            notes.append("hold-load fractions ASSUMED (no process source): " + ", ".join(f"{k} {v:.2f}" for k, v in assumptions["holdLoadFraction"].items()))
            notes.append(f"restart loss ASSUMED {assumptions['restartLossDays']:.2f} day per eclipse")
        elif spec.decision_id == "D2":
            moes = trades.evaluate_d2(samples.values, runs, site, float(space.params["spaMsrFirstUnitRatedKw"]))
        elif spec.decision_id == "D3":
            moes = trades.evaluate_d3(samples.values, runs, content,
                                      {"impactSurvival1b": samples.values["u:impactSurvival1b"],
                                       "impactSurvival2": samples.values["u:impactSurvival2"]})
            notes.append("impact-survival pass probability uninformative 0.5 (range unbound); a failed test falls back 2 -> 1b -> 1a")
        elif spec.decision_id == "D4":
            moes = trades.evaluate_d4(samples.values, runs, space.thresholds)
        elif spec.decision_id == "D5":
            moes = trades.evaluate_d5(samples.values, runs)
            notes.append("capture-year ranges unbound: the distribution is a point unless the scenario moves it")
        elif spec.decision_id == "D6":
            moes = trades.evaluate_d6(samples.values, runs, space.params, space.thresholds)
        elif spec.decision_id == "D7":
            moes = trades.evaluate_d7(samples.values, runs, samples.values["u:mkIiiTest"])
            notes.append("Mk III validation pass probability uninformative 0.5 (range unbound)")
        elif spec.decision_id == "D8":
            moes = trades.evaluate_d8(samples.values, runs, space.thresholds)
        else:
            raise KeyError(spec.decision_id)
        for alt in moes:
            for gate in spec.gates:
                key = f"gateYear:{gate}"
                if key not in moes[alt] and gate in generic:
                    moes[alt][key] = generic[gate]
            moes[alt].setdefault("milestoneSlipYears", np.zeros(n))
        out[spec.decision_id] = (moes, notes, extras)
    return out


def reference_years(space: Space, nominal: Samples, nominal_runs: trades.EconRuns, assumptions: dict[str, object],
                    wanted: set[str]) -> dict[str, float]:
    """gate -> the committed plan's derived year at nominal for the baseline's
    selected alternative (NEVER when never met)."""
    evaluated = evaluate_all(space, nominal, nominal_runs, assumptions, wanted)
    ref: dict[str, float] = {}
    for spec in space.decisions:
        if spec.decision_id not in evaluated:
            continue
        moes, _, _ = evaluated[spec.decision_id]
        sel = space.selections.get(spec.decision_id.lower())
        alt = sel.split("::")[1] if sel else spec.alternatives[0].name
        if alt not in moes:
            alt = next(iter(moes))
        for gate in spec.gates:
            key = f"gateYear:{gate}"
            if key in moes[alt] and gate not in ref:
                y = float(moes[alt][key][0])
                ref[gate] = eclipse.NEVER if np.isnan(y) else y
    return ref


def convergence_line(results: list[DecisionResult], objective: str) -> dict[str, float]:
    """The largest Monte Carlo standard error of the objective relative to its
    mean over every alternative of every decision, and of the win
    probabilities (sqrt(p(1-p)/n))."""
    worst = 0.0
    worst_label = ""
    worst_p = 0.0
    for d in results:
        for alt in d.alternatives:
            s = d.summaries[alt].get(objective)
            if s and s["mean"]:
                rel = abs(s["se"] / s["mean"])
                if rel > worst:
                    worst, worst_label = rel, f"{d.decision_id}/{alt}"
        p = d.lead.win_probability
        if p is not None:
            n = len(d.moes[d.alternatives[0]][objective])
            se_p = float(np.sqrt(max(p * (1 - p), 0.0) / n))
            worst_p = max(worst_p, se_p)
    return {"largestRelativeSe": worst, "largestRelativeSeAt": worst_label, "largestWinProbabilitySe": worst_p}


def evaluator_exists(dotted: str) -> bool:
    module, _, func = dotted.rpartition(".")
    try:
        mod = importlib.import_module(module)
    except ImportError:
        return False
    return callable(getattr(mod, func, None))


def gate_probabilities(result: RunResult, selection_only: bool = True) -> dict[str, dict[str, float]]:
    """gate -> {p_met, p10, p50, p90, alternative}: P(met by its declared year)
    and the year quantiles, for the baseline's selected alternative (or the
    lead recommendation where the baseline leaves the decision open)."""
    out: dict[str, dict[str, float]] = {}
    for d in result.decisions:
        sel = result.space.selections.get(d.decision_id.lower())
        alt = sel.split("::")[1] if sel else d.lead.alternative
        if alt not in d.alternatives:
            alt = d.alternatives[0]
        for gate, years_by_alt in d.gate_years.items():
            if alt not in years_by_alt:
                continue
            years = years_by_alt[alt]
            declared = d.gate_declared.get(gate)
            if gate in out:          # the first decision in catalogue order owns the gate's row
                continue
            out[gate] = {
                "p_met": criteria.probability_by_year(years, declared) if declared is not None else float("nan"),
                "p10": criteria.quantile_year(years, 0.10), "p50": criteria.quantile_year(years, 0.50),
                "p90": criteria.quantile_year(years, 0.90), "alternative": alt, "decision": d.decision_id,
                "declared": declared, "superseded": SUPERSEDED_GATES.get(gate, ""),
            }
    return out
