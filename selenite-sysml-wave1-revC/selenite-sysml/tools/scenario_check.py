#!/usr/bin/env python3
"""scenario_check.py - the scenario register: decisions under uncertainty.

Wave 4A (6 Nov 2026). Reads ``model/Scenarios.sysml`` (the uncertainty
register, the decision catalogue D1-D8, the trade studies and the named
scenarios) and ``model/Parameters.sysml`` through ``selenite.scenarios``,
samples the register with common random numbers under a fixed seed,
evaluates every alternative of every decision on the same samples and prints
``docs/SCENARIO_REGISTER.md``:

1. the uncertainty register (entry, nominal, low, high, distribution,
   source, sampled or point) and the evaluator's declared assumptions;
2. per decision, alternatives x measures of value as mean / P10 / P50 / P90,
   the recommended alternative under each criterion with its win
   probability, and for D1 the declared versus derived eclipse-critical
   fraction, the two worlds (SPA MSR available or not) and the break-even
   availability probability;
3. gate-year distributions for every gate the catalogue touches (P10 / P50 /
   P90 and P(met by its declared year));
4. the named scenarios at a reduced sample size;
5. a convergence line (n, seed, largest standard error relative to the mean).

Structural checks (exit 1): every variation in the catalogue has an
evaluator or a declared stub; every register entry is sampled or a point
and binds to an existing parameter; every decision's uncertain inputs are
register entries; every #moe of an option type is reported; every trade
study names an existing Python entry point; the configuration's selections
name variants of the catalogue; the VERIFY-transcribed parameters equal
verify.workspace(). Findings never fail the run.

Usage:  python tools/scenario_check.py [--markdown OUT.md] [--quiet] [--n N] [--seed S]
                                       [--method lhs|sobol] [--scenario NAME] [--scenario-n N]
                                       [--no-scenarios] [--decisions D1,D2]
"""
from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
REPO = ROOT.parent.parent

try:
    from selenite.scenarios import criteria, eclipse, run as runner, space as spacemod
except ImportError:  # the package is not installed: fall back to the in-repo source
    sys.path.insert(0, str(REPO / "selenite-compute"))
    for _name in [m for m in sys.modules if m == "selenite" or m.startswith("selenite.")]:
        del sys.modules[_name]
    from selenite.scenarios import criteria, eclipse, run as runner, space as spacemod

import numpy as np

MOE_LABELS = {
    "earthLaunchedMassTonnes": "Earth-launched mass (t)",
    "earthMassSpaPowerTonnes": "SPA power-side Earth mass (t)",
    "npvUsdB": "NPV with externalities ($B)",
    "directBcr": "direct BCR",
    "milestoneSlipYears": "gate slip (yr)",
    "launchCo2Tonnes": "launch CO2 (t)",
    "fspUnits": "FSP units (non-nuclear fallback)",
    "batteryMassTonnes": "battery mass (t)",
    "throughputLostFraction": "throughput lost",
    "throughputPenaltyTonnes": "throughput penalty, Earth mass (t)",
    "oversizeMassTonnes": "oversize plant mass (t)",
    "spaMsrFirstYear": "SPA MSR first year",
    "probabilityMsrBeforeY105": "P(MSR before Y105)",
    "annualEarthImportCostUsdB": "annual Earth import cost ($B/yr, DF s.9)",
    "canisterEarthMassTonnes": "canister Earth mass (t)",
    "probabilityRealisedAsChosen": "P(realised as chosen)",
    "circuitsNeeded": "circuits at Y200",
    "pktPowerGw": "PKT power at Y200 (GW)",
    "mdFourYear": "MD-4 year",
    "probabilityOperationalByY85": "P(MD-4 by Y85)",
    "dgEightSevenYear": "DG-8.7 year",
    "thoriumHydroxideAtY43Tonnes": "Th(OH)4 stockpile at Y43 (t)",
    "thoriumToReoMassRatio": "Th(OH)4 per t REO",
    "probabilityCapacityForced": "P(capacity-forced)",
    "mkIiiFleetEarthMassTonnes": "Mk III fleet Earth mass (t, LEO)",
    "mkIiiTransitionYear": "Mk III transition year",
    "probabilityDgThirteenSevenMetByY120": "P(DG-13.7 by Y120)",
    "haulerEarthMassTonnes": "hauler Earth mass (t)",
}
DECISION_MOES = {
    "D1": ("earthLaunchedMassTonnes", "earthMassSpaPowerTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes",
           "fspUnits", "batteryMassTonnes", "oversizeMassTonnes", "throughputLostFraction", "throughputPenaltyTonnes", "spaMsrFirstYear"),
    "D2": ("earthLaunchedMassTonnes", "earthMassSpaPowerTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes",
           "spaMsrFirstYear", "probabilityMsrBeforeY105"),
    "D3": ("earthLaunchedMassTonnes", "canisterEarthMassTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes",
           "annualEarthImportCostUsdB", "probabilityRealisedAsChosen"),
    "D4": ("earthLaunchedMassTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes", "circuitsNeeded", "pktPowerGw"),
    "D5": ("earthLaunchedMassTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes", "mdFourYear", "probabilityOperationalByY85"),
    "D6": ("earthLaunchedMassTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes", "dgEightSevenYear",
           "thoriumHydroxideAtY43Tonnes", "thoriumToReoMassRatio"),
    "D7": ("earthLaunchedMassTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes", "probabilityCapacityForced",
           "mkIiiTransitionYear", "mkIiiFleetEarthMassTonnes"),
    "D8": ("earthLaunchedMassTonnes", "haulerEarthMassTonnes", "npvUsdB", "directBcr", "milestoneSlipYears", "launchCo2Tonnes",
           "probabilityDgThirteenSevenMetByY120"),
}
# Model #moe name -> result key where they differ.
MOE_ALIASES = {"earthLaunchedMassP90Tonnes": ("earthLaunchedMassTonnes", "p90"), "npvCvar90UsdB": ("npvUsdB", "cvar90")}


# --------------------------------------------------------------------------
# Formatting
# --------------------------------------------------------------------------


def fmt(x, digits: int = 4) -> str:
    if x is None:
        return "-"
    if isinstance(x, str):
        return x
    if isinstance(x, (bool, np.bool_)):
        return "true" if x else "false"
    if isinstance(x, (int, np.integer)):
        return f"{int(x):,}"
    x = float(x)
    if math.isnan(x):
        return "never"
    if x == 0:
        return "0"
    if abs(x) >= 1000:
        return f"{x:,.0f}"
    if abs(x) >= 10:
        return f"{x:,.{digits - 2}g}" if abs(x) < 100 else f"{x:,.0f}"
    return f"{x:.{digits}g}"


def fmt_year(x) -> str:
    if x is None or (isinstance(x, float) and math.isnan(x)):
        return "never"
    return f"Y{x:.0f}" if float(x).is_integer() else f"Y{x:.1f}"


def md_table(headers, rows) -> str:
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c).replace("|", "\\|") for c in r) + " |")
    return "\n".join(out)


def quantiles_cell(s: dict[str, float]) -> str:
    cell = f"{fmt(s['mean'])} / {fmt(s['p10'])} / {fmt(s['p50'])} / {fmt(s['p90'])}"
    if s.get("pNever", 0.0) and not math.isnan(s["pNever"]) and s["pNever"] < 1.0:
        cell += f" (never in {100 * s['pNever']:.0f} %)"
    return cell


# --------------------------------------------------------------------------
# Structural checks
# --------------------------------------------------------------------------


def structural_checks(sp: spacemod.Space, result: runner.RunResult | None) -> list[str]:
    errors = []
    names = {e.name for e in sp.register}
    for e in sp.register:
        if e.status.startswith("point") or e.status == "sampled":
            pass
        else:
            errors.append(f"UncertaintyRegister.{e.name}: status {e.status!r} is neither sampled nor point")
        for slot, attr in e.bindings.items():
            if attr not in sp.params:
                errors.append(f"UncertaintyRegister.{e.name}.{slot} binds to unknown ProgrammeParameters.{attr}")
    for d in sp.decisions:
        if d.evaluator_status not in ("evaluated", "stub"):
            errors.append(f"{d.decision_id}: evaluatorStatus {d.evaluator_status!r} must be 'evaluated' or 'stub'")
        if d.evaluator_status == "evaluated" and not runner.evaluator_exists(d.evaluator):
            errors.append(f"{d.decision_id}: evaluator {d.evaluator} not found")
        if not d.alternatives:
            errors.append(f"{d.decision_id}: variation {d.variation} has no variants")
        for u in d.uncertain_inputs:
            if u not in names:
                errors.append(f"{d.decision_id}: uncertain input {u} is not an UncertaintyRegister entry")
        if not any(a.option_type == d.option_type for a in sp.analyses):
            errors.append(f"{d.decision_id}: no analysis def with subject {d.option_type}[*]")
    for a in sp.analyses:
        if not a.uri or not (REPO / a.uri).exists():
            errors.append(f"analysis {a.name}: @ToolExecution uri {a.uri!r} does not exist")
        if a.tool_name != "selenite.scenarios":
            errors.append(f"analysis {a.name}: toolName {a.tool_name!r} is not selenite.scenarios")
    by_id = {d.decision_id.lower(): d for d in sp.decisions}
    for key, sel in sp.selections.items():
        d = by_id.get(key)
        if d is None:
            errors.append(f"configuration selects unknown decision {key}")
            continue
        if sel is None:
            continue
        var, alt = sel.split("::")
        if var != d.variation or alt not in [x.name for x in d.alternatives]:
            errors.append(f"configuration {key} selects {sel}, not a variant of {d.variation}")
    for d in sp.decisions:
        if d.decision_id.lower() not in sp.selections:
            errors.append(f"configuration has no selection (or abstract part) for {d.decision_id}")
    errors.extend(eclipse.verify_transcription(sp.params))
    if result is not None:
        for d in result.decisions:
            spec = sp.decision(d.decision_id)
            moes = sp.moes.get(spec.option_type, [])
            for alt in d.alternatives:
                for moe in moes:
                    key = MOE_ALIASES.get(moe, (moe, None))[0]
                    if key not in d.moes[alt]:
                        errors.append(f"{d.decision_id}/{alt}: #moe {moe} is not reported")
            if d.evaluator_status == "evaluated" and not d.alternatives:
                errors.append(f"{d.decision_id}: evaluated but no alternatives")
    return errors


# --------------------------------------------------------------------------
# Rendering
# --------------------------------------------------------------------------


def render_register(sp: spacemod.Space, result: runner.RunResult) -> str:
    rows = []
    for e in sp.register:
        rows.append([e.name, e.kind, fmt(e.nominal), fmt(e.low), fmt(e.high), e.status, e.source])
    lines = ["## 1. Uncertainty register (the U-set)", "",
             "Every entry binds to a ProgrammeParameters attribute and its Low / High twins; "
             "an entry without a sourced range is a point at nominal (rule 5d). Two-point discrete "
             "entries carry equal weights (uninformative, stated per row).", "",
             md_table(["Entry", "Distribution", "Nominal", "Low", "High", "Status", "Source"], rows), ""]
    a = result.assumptions
    lines.append("Evaluator working assumptions (ASSUMED - no process source; an ECN to "
                 "`selenite/scenarios/eclipse.py` or a bound parameter replaces them): hold-load fractions "
                 + ", ".join(f"{k} {v:.2f}" for k, v in a["holdLoadFraction"].items())
                 + f"; restart loss {a['restartLossDays']:.2f} day of output per eclipse; oversize plant Earth share "
                 + ("the ECON circuit Earth-fraction trajectory" if a["asteroidPlantEarthFraction"] is None
                    else f"{a['asteroidPlantEarthFraction']:.2f} (scenario)")
                 + f". Sampled dimensions: {result.samples.d}; sample hash {result.samples.hash[:12]} (common random numbers).")
    lines.append("")
    return "\n".join(lines)


def render_decision(sp: spacemod.Space, d: runner.DecisionResult, result: runner.RunResult) -> str:
    spec = sp.decision(d.decision_id)
    lines = [f"### {d.decision_id} - {d.title}", ""]
    sel = sp.selections.get(d.decision_id.lower())
    lines.append(f"Stage: {d.stage}; gates: {', '.join(spec.gates)}; evaluator: `{spec.evaluator}` ({d.evaluator_status}); "
                 f"baseline selection: {sel.split('::')[1] if sel else 'open (abstract part)'}; objective: "
                 f"{'minimise' if d.sense == 'min' else 'maximise'} {MOE_LABELS.get(d.objective_moe, d.objective_moe)}.")
    lines.append("")
    lead = d.lead
    default = d.extras.get("defaultCriterion", d.lead_criterion)
    how = default if d.lead_criterion == default else f"{default}, fell back to {d.lead_criterion}"
    if lead.alternative is not None:
        lines.append(f"**Recommended under the default criterion ({how}): `{lead.alternative}`** - "
                     f"P(win) {lead.win_probability:.2f}, P(no slip) {lead.feasible_probability:.2f}.")
    else:
        lines.append(f"**No alternative admissible under {how}.**")
    lines.append("")
    moes = [m for m in DECISION_MOES.get(d.decision_id, ()) if any(m in d.moes[a] for a in d.alternatives)]
    headers = ["Alternative"] + [f"{MOE_LABELS.get(m, m)} mean / P10 / P50 / P90" for m in moes]
    rows = []
    for alt in d.alternatives:
        row = [alt]
        for m in moes:
            s = d.summaries[alt].get(m)
            row.append(quantiles_cell(s) if s else "-")
        rows.append(row)
    lines.append(md_table(headers, rows))
    lines.append("")
    # risk measures the model names as #moe
    rows = []
    for alt in d.alternatives:
        em = d.moes[alt]["earthLaunchedMassTonnes"]
        npv = d.moes[alt]["npvUsdB"]
        rows.append([alt, fmt(float(np.quantile(em, 0.9))), fmt(criteria.cvar(npv, 0.9, "lower")),
                     fmt(d.summaries[alt]["earthLaunchedMassTonnes"]["se"]),
                     f"{np.mean(d.feasible[alt]):.2f}"])
    lines.append(md_table(["Alternative", "Earth mass P90 (t)", "NPV CVaR90 ($B)", "Earth mass SE (t)", "P(no slip)"], rows))
    lines.append("")
    rows = []
    for crit, rec in d.recommendations.items():
        rows.append([crit, rec.alternative or "none admissible",
                     "-" if rec.win_probability is None else f"{rec.win_probability:.2f}",
                     "-" if rec.feasible_probability is None else f"{rec.feasible_probability:.2f}"])
    lines.append(md_table(["Criterion", "Recommended", "P(win)", "P(no slip)"], rows))
    lines.append("")
    if d.decision_id == "D1":
        lines.extend(render_d1_extras(sp, d, result))
    if d.notes:
        lines.append("Notes: " + "; ".join(d.notes) + ".")
        lines.append("")
    return "\n".join(lines)


def render_d1_extras(sp: spacemod.Space, d: runner.DecisionResult, result: runner.RunResult) -> list[str]:
    lines = []
    declared = sp.params.get("spaAsteroidLoadCriticalFraction")
    rows = []
    for alt in d.alternatives:
        s = d.summaries[alt]
        rows.append([alt, fmt(declared), quantiles_cell(s["derivedCriticalFraction"]), fmt(s["fspUnits"]["mean"]),
                     fmt(s["criticalLoadMaxKw"]["mean"])])
    lines.append("Declared versus derived eclipse-critical fraction of the asteroid-processing loads "
                 "(ECN-022 s.2.4 declared 1.0; `SeleniteAnalysis::EclipseCriticalFraction` per strategy):")
    lines.append("")
    lines.append(md_table(["Strategy", "Declared", "Derived mean / P10 / P50 / P90", "FSP units (fallback, max)",
                           "critical load max (kW)"], rows))
    lines.append("")
    worlds = d.extras.get("worlds", {})
    be = d.extras.get("breakEvenProbability", {})
    if worlds:
        rows = []
        for alt in d.alternatives:
            wa = worlds["msrAvailable"][alt]
            wu = worlds["msrUnavailable"][alt]
            b = be.get(alt)
            btxt = "reference" if alt == "carryThroughEclipse" else ("always" if b == 1.0 else ("never" if b is None or (isinstance(b, float) and math.isnan(b)) else f"{b:.4f}"))
            rows.append([alt, fmt(wa["earthMassSpaPowerTonnes"]["mean"]), fmt(wa["earthLaunchedMassTonnes"]["mean"]),
                         fmt(wu["earthMassSpaPowerTonnes"]["mean"]), fmt(wu["earthLaunchedMassTonnes"]["mean"]), btxt])
        p = sp.params.get("spaMsrAvailabilityProbability")
        lines.append(f"The two worlds D1 turns on (same samples; `spaMsrAvailabilityProbability` = {fmt(p)} in the committed plan, "
                     f"scenario override {result.overrides.get('spaMsrAvailabilityProbability', 'none')}): the SPA MSR carries "
                     "the asteroid loads through every eclipse when it is available at the C-type arrival; without it the "
                     "strategy sizes the FSP fleet. Break-even: the availability probability below which the strategy beats "
                     "carry-through on expected Earth-launched mass.")
        lines.append("")
        lines.append(md_table(["Strategy", "MSR available: SPA power mass (t)", "MSR available: total Earth mass (t)",
                               "MSR unavailable: SPA power mass (t)", "MSR unavailable: total Earth mass (t)",
                               "break-even P(MSR available)"], rows))
        lines.append("")
    return lines


def render_gates(sp: spacemod.Space, result: runner.RunResult) -> str:
    gp = runner.gate_probabilities(result)
    rows = []
    for gate in sorted(gp, key=_gate_key):
        g = gp[gate]
        note = g["superseded"] or ""
        if g["declared"] is None:
            note = (note + "; " if note else "") + "no declared year (exogenous)"
        rows.append([gate, f"{g['decision']} / {g['alternative']}", fmt_year(g["declared"]) if g["declared"] is not None else "-",
                     fmt_year(g["p10"]), fmt_year(g["p50"]), fmt_year(g["p90"]),
                     "-" if math.isnan(g["p_met"]) else f"{g['p_met']:.2f}", note])
    lines = ["## 3. Gate-year distributions", "",
             "Every gate in the catalogue's Gates column, on the baseline's selected alternative (the lead "
             "recommendation where the baseline leaves the decision open). P(met) is the share of samples "
             "whose derived year is no later than the declared year; 'never' quantiles mean the criterion "
             "is not met on the horizon.", "",
             md_table(["Gate", "Decision / alternative", "Declared", "P10", "P50", "P90", "P(met by declared year)", "Note"], rows), ""]
    return "\n".join(lines)


def _gate_key(gid: str):
    if gid.startswith("DG-POST"):
        return (99, int(gid.split(".")[1]))
    major, minor = gid[3:].split(".")
    return (int(major), 99 if minor == "X" else int(minor))


def render_scenarios(sp: spacemod.Space, baseline: runner.RunResult, scenario_runs: dict[str, runner.RunResult], n_s: int) -> str:
    if not scenario_runs:
        return "## 4. Named scenarios\n\nSkipped (--no-scenarios).\n"
    ids = [d.decision_id for d in baseline.decisions]
    headers = ["Scenario", "Overrides"] + [f"{i} lead (P win)" for i in ids] + ["D1 SPA power mass by strategy (t)"]
    rows = []
    for name, r in scenario_runs.items():
        row = [name, ", ".join(f"{k}={fmt(v)}" for k, v in r.overrides.items()) or "none"]
        for i in ids:
            d = r.decision(i)
            row.append(f"{d.lead.alternative} ({d.lead.win_probability:.2f})" if d.lead.alternative else "none")
        try:
            d1 = r.decision("D1")
            row.append("; ".join(f"{alt} {fmt(d1.summaries[alt]['earthMassSpaPowerTonnes']['mean'])}" for alt in d1.alternatives))
        except KeyError:
            row.append("-")
        rows.append(row)
    lines = ["## 4. Named scenarios", "",
             f"Each scenario holds its overrides constant and samples everything else (n = {n_s:,} per scenario, seed "
             f"{baseline.seed}); the lead recommendation under the default criterion per decision.", "",
             md_table(headers, rows), ""]
    return "\n".join(lines)


def render(sp: spacemod.Space, result: runner.RunResult, scenario_runs: dict[str, runner.RunResult], n_s: int,
           errors: list[str]) -> str:
    crit = str(sp.params.get("decisionCriterion", "")).split("::")[-1]
    conv = result.convergence
    lines = ["# Selenite scenario register - decisions under uncertainty (Wave 4A)", ""]
    lines.append(f"Run: n = {result.n:,} samples, seed {result.seed}, {('Latin hypercube' if result.method == 'lhs' else 'Sobol')}, "
                 f"scenario `{result.scenario}`; common random numbers (every alternative of every decision on the same samples). "
                 f"ECON v1.3 parametrised (`econ_param`, equal to the port at defaults). Default criterion "
                 f"`{crit}`: minimise expected cumulative Earth-launched mass subject to P(no gate slip) >= "
                 f"{float(sp.params.get('chanceConstraintThreshold') or 0.8):.2f} (PROPOSED, open question 1, awaiting Jason); "
                 f"expected value, P90, CVaR90 and minimax regret are reported beside it.")
    lines.append("")
    lines.append(f"Convergence: largest standard error {100 * conv['largestRelativeSe']:.2f} % of the mean "
                 f"({conv['largestRelativeSeAt']}); largest win-probability standard error {conv['largestWinProbabilitySe']:.3f}.")
    lines.append("")
    lines.append("Slip is measured against the plan's own date: the declared year, or the Wave 3 derived year at nominal "
                 "where the deterministic register already derives the gate later (W3-R rows); exogenous gates and the "
                 "years ECN-022 superseded are excluded. MTL v8.5 milestones M5 / M6 / M8 and the first-export year are not "
                 "derivable from the Python layer and are not modelled as slips.")
    lines.append("")
    lines.append(render_register(sp, result))
    lines.append("## 2. Decisions")
    lines.append("")
    for d in result.decisions:
        lines.append(render_decision(sp, d, result))
    lines.append(render_gates(sp, result))
    lines.append(render_scenarios(sp, result, scenario_runs, n_s))
    lines.append("## 5. Structural checks")
    lines.append("")
    lines.append("All structural checks passed." if not errors else "\n".join(f"- ERROR: {e}" for e in errors))
    lines.append("")
    return "\n".join(lines)


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--markdown", type=Path, help="write the register to this file as well as stdout")
    ap.add_argument("--quiet", action="store_true", help="print only the D1 lead, the convergence line and the check result")
    ap.add_argument("--n", type=int, default=runner.DEFAULT_N, help=f"samples (default {runner.DEFAULT_N:,}; CI uses 500)")
    ap.add_argument("--seed", type=int, default=runner.DEFAULT_SEED)
    ap.add_argument("--method", choices=("lhs", "sobol"), default="lhs")
    ap.add_argument("--scenario", default="baseline", help="named scenario of ScenarioSet to run as the main run")
    ap.add_argument("--scenario-n", type=int, default=None, help="samples per named scenario (default max(100, n // 20))")
    ap.add_argument("--no-scenarios", action="store_true", help="skip the named-scenario sweep")
    ap.add_argument("--decisions", default=None, help="comma-separated decision ids to evaluate (default all)")
    args = ap.parse_args(argv)

    sp = spacemod.load_space()
    errors = structural_checks(sp, None)
    wanted = tuple(x.strip() for x in args.decisions.split(",")) if args.decisions else None
    result = runner.run(sp, n=args.n, seed=args.seed, method=args.method, scenario=args.scenario, decisions=wanted)
    errors = structural_checks(sp, result)
    n_s = args.scenario_n or max(100, args.n // 20)
    scenario_runs: dict[str, runner.RunResult] = {}
    if not args.no_scenarios:
        for s in sp.scenarios:
            if s.name == args.scenario:
                scenario_runs[s.name] = result if args.n == n_s else runner.run(sp, n=n_s, seed=args.seed, method=args.method,
                                                                                scenario=s.name, decisions=wanted)
            else:
                scenario_runs[s.name] = runner.run(sp, n=n_s, seed=args.seed, method=args.method, scenario=s.name, decisions=wanted)
    text = render(sp, result, scenario_runs, n_s, errors)
    if args.markdown:
        args.markdown.write_text(text, encoding="utf-8")
    if args.quiet:
        for d in result.decisions:
            lead = d.lead
            print(f"{d.decision_id}: {lead.alternative} under {lead.criterion} "
                  f"(P(win) {lead.win_probability if lead.win_probability is None else round(lead.win_probability, 2)})")
        c = result.convergence
        print(f"n = {result.n}, seed {result.seed}: largest SE {100 * c['largestRelativeSe']:.2f} % of the mean at {c['largestRelativeSeAt']}")
        print("All structural checks passed." if not errors else "\n".join(f"ERROR: {e}" for e in errors))
    else:
        print(text)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
