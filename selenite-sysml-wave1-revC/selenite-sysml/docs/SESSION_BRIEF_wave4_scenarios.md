# Session Brief — Wave 4A: Scenarios, uncertainty and decision analysis

> **Status: kick-off 20 Sep 2026, not started.** Wave 4 is split: **4A** is this
> brief; **4B** (behaviour, interfaces, software) is the original Wave 4 scope
> in `docs/MIGRATION_PLAN.md`, unchanged, for a separate session.

**Scope:** one session, two if the parametrised economics take longer than
expected. Turn the deterministic derived plan of Wave 3 into a *decision
engine*. The model declares the decisions, their alternatives, the uncertain
inputs and the measures of value; the Python layer samples the uncertainty,
evaluates every alternative on the same samples, and a register reports which
alternative wins under which criterion and how confident that is. Paste into a
fresh Claude Code session on the repository; the model folder is
`selenite-sysml-wave1-revC/selenite-sysml/`, the Python layer is
`selenite-compute/`.

**Decision (Jason, 20 Sep 2026), paraphrased from the Wave 3 close-out:** the
model must be dynamic — parameterise per scenario and arrive at the most
economical decision for that scenario; compute and compare scenarios to guide
selection; and where an input is not deterministic, carry its variability
(stochastic optimisation) rather than a point value.

**Why now — the case that triggered it.** SEL-ECN-022 §2.4 bound
`spaAsteroidLoadCriticalFraction = 1.0`: the asteroid-processing loads
(C-type pyrolysis and Fischer–Tropsch from Y105, S-type Czochralski silicon
from Y125, Decision Framework Rev D §10.1) are treated as loads that must be
carried through the 72 h SPA eclipse design case. Jason's reading (20 Sep):
that is fine *if the power-intensive work is done while the eclipse is not
present*. That makes the fraction an **operating strategy**, not a constant:
schedule the pausable steps in sunlight and only the hold loads are
eclipse-critical. The right value falls out of a trade between strategies
under uncertainty, which is exactly what this wave builds. The symptom in the
current register is the DG-10.5 / DG-13.4 detail "eclipse-critical load
132–250,120 kW, 6,254 FSP max"; the derived MSR year (Y105, incremental basis)
does not move, but the FSP count, battery mass and Earth-launched mass do.

## Start-up (mandatory, in order)

1. `npm install -g sysml-validate@0.36.0 sysml-diagram`; `tools/validate.sh` →
   exit 0, zero hints. `pip install -e "selenite-compute[test]"`;
   `pytest selenite-compute` → 1,456 passed, 33 skipped;
   `python tools/plan_check.py --quiet` → exit 0. Nothing below starts until
   all three are clean.
2. Read, in this order: `docs/CLAUDE_SYSML_CONTEXT.md` (rules 3, 5a–5c, §4
   idioms), `docs/MIGRATION_PLAN.md` (Wave 4A / 4B / 5), `CHANGELOG_WAVE3.md`
   ("Wave 3 delivery", the three 19 Sep addenda, "Close-out"),
   `docs/SEL-ECN-022_DecisionFramework_Wave3.md` (§2 decisions, §4 open
   findings), `docs/PLAN_REGISTER.md` rows DG-8.7, DG-9.6, DG-10.5, DG-12.4,
   DG-13.4, `docs/VALUE_CONFLICTS.md`; then `model/Parameters.sysml` (the
   thorium range block and `spaMsrDoc`), `model/ThroughputCalcs.sysml`
   (`SpaMsrIntroductionGate`), `selenite/plan_vectors.py` (`spa_power`,
   `spa_critical_power`, `fsp_msr_trade`, `thorium_ratio`), `tools/plan_check.py`
   (`Ctx`, `EVALUATORS`, `ev_spa_msr`, the parsers at the top), and
   `selenite/econ.py` lines 80–140 (every economic parameter is hard-coded
   there; `econ.run(**params)` ignores its arguments).
3. Library check: `sysml-validate` 0.36.0 resolves `TradeStudies`,
   `AnalysisTooling`, `ParametersOfInterestMetadata` and `RiskMetadata` and
   parses `variation` / `variant` (probed 20 Sep 2026). The idioms in the
   last section validate with zero hints — use them as given.

## What the wave must be able to compare — the decision catalogue

Stage: **now** = a design choice made before the information arrives (a
here-and-now decision); **recourse** = decided when a gate's information
arrives and therefore re-evaluated per sample (a wait-and-see decision). The
two-stage structure is the point: a plan is a *policy*, not a date list.

| ID | Decision | Alternatives | Uncertain inputs (sampled) | Value measures | Gates | Stage |
|---|---|---|---|---|---|---|
| **D1** | **SPA eclipse operating strategy** for the asteroid-processing loads (lead case) | A carry-through (all loads eclipse-critical, ECN-022 §2.4); B sunlit duty cycle (pausable steps scheduled outside eclipse, plant oversized to keep annual throughput, hold loads only through eclipse); C hot standby (thermal storage / insulation holds process heat, electrical hold fraction per process); D hybrid (battery or thermal storage carries a chosen fraction) | dark fraction of time at the SPA site (VERIFY `solar.illum` 0.85 → 0.15; range needs a source, see open question 2); longest eclipse (72 h design case, Strategy v3.1 §12.1); hold-load fraction per process (pyrolysis, F–T, Czochralski); Czochralski minimum continuous run; plant oversize mass penalty per kW; restart loss per eclipse; FSP mass per kW (VERIFY 6,600 kg / 40 kW); MSR Earth fraction schedule | Earth-launched mass; FSP count; battery mass; throughput lost; SPA MSR first year; NPV delta | DG-10.5, DG-11.3, DG-13.4, DG-14.4, DG-14.7 | now (design), with the FSP/MSR count as recourse |
| D2 | SPA power supply mix: FSP vs SPA MSR vs a-Si solar in-situ timing (deterministic today in `fsp_msr_trade`) | as the function's bases and options | MSR unit mass, MSR Earth-fraction schedule (ECON floor 0.3 from Y80), launch cost per kg by era, ThCl₄ availability year (MD-3, DG-9.6), panel mass per m², solar in-situ start year | Earth-launched mass; first MSR year; P(MSR before Y105) | DG-9.6, DG-10.5, DG-13.4 | recourse |
| D3 | Canister recovery architecture (DG-9.1; Decision Framework §9) | 1a full parachute (73 kg Earth per canister); 1b minimal drag chute (28 kg, recommended); 2 shuttlecock (8 kg, needs impact-survival validation) | Earth content per canister (as listed); impact-survival test outcome as a probability (`assumedOutcome` becomes a sampled Boolean); canister count per year (VC-22: 694,444 vs 714,286) | Earth-launched mass; annual Earth import cost ($4.6 B / $16 B / $42 B per yr per §9); NPV | DG-9.1, DG-14.6 | now |
| D4 | Processing circuit design (DG-8.5, W3-N3) | batch 0.4 t/yr; continuous 0.8; optimised 1.2 (ECON `circuit_designs`) | circuit mass and power per design; circuit Earth-fraction schedule; maintenance rate (ECON tornado) | circuits needed; PKT power; Earth-launched mass; NPV | DG-8.5, DG-9.2, DG-10.2 | now |
| D5 | MD-4 and Starship-return retirement timing (ECN-022 §2.1: consequence of the M-type arrival) | none — a pure consequence, included so its year has a distribution | M-type capture year (75, nominal) and the asteroid-online lag (10) as ranges | P(MD-4 operational by Y85); Starship return flights avoided | DG-11.8, DG-12.4 | recourse |
| D6 | Thorium stream sizing (W3-N22) | none — sizing consequence | Th grade 10–15 ppm, acid-bake capture 0.90–0.95 (already ranges in `Parameters.sysml`), processing REE grade | DG-8.7 year distribution; ThCl₄ available for D1/D2 | DG-8.7, DG-9.6 | recourse |
| D7 | Mk III transition trigger (W3-N2, ECN-022 §2.6) | capacity-forced by PSR positions vs DG-11.6 test outcome | MOLE-I peak need (ECON 357) as a range against 620 positions; PGM yield test outcome probability | P(capacity-forced); Mk III fleet Earth mass | DG-11.6, DG-11.7 | recourse |
| D8 | Hauler in-situ fraction policy (F3, DG-13.7) | ECON floor 0.43 with the 0.10 M-type bonus vs the 0.20 target as a scenario | floor value as a range; M-type bonus timing | P(DG-13.7 met by Y120); hauler Earth mass | DG-10.1, DG-13.7 | recourse |

D1, D2, D4, D5 and D6 are the minimum this wave evaluates stochastically. D3,
D7 and D8 may be catalogued with evaluators stubbed if time runs out, and the
register must then say so per row.

**Programme-wide uncertain inputs (U-set), sampled jointly with every
decision:** the ECON v1.4 tornado set (launch cost $/kg by era 6,000 / 4,000 /
2,000 with ±50 %; discount rate schedule 3 / 2.5 / 2 % with the 1.4 % and
3.5 % bounds; REO externality $50–90 k/t; H₂ attribution 25–100 %; geo
insurance $0–25 B/yr; maintenance rate 0.25–0.5 %), the Wave 3 ranges
(thorium grade and capture), the capture years and the asteroid lag, the REO
ramp knot shift (W3-N4: Decision Framework one knot earlier than ECON), and
the SPA dark fraction. Every distribution's parameters come from an existing
Low/High pair or a cited source, or the parameter stays a point at nominal
with the register saying "range unbound".

**Measures of value (`#moe`), reported for every alternative:** cumulative
Earth-launched mass (t) — the programme's own Earth-independence criterion
(DG-14.6); NPV with externalities and direct BCR (ECON v1.4); milestone slip
against MTL v8.5 (M5, M6, M8) and first-export year; P(gate met by its
declared year) for every gate the decision touches; lifetime launch CO₂; and a
risk measure (P90 of Earth mass, CVaR₉₀ of NPV). **Decision criteria,
reported side by side:** expected value, P90 / CVaR, minimax regret, and a
chance constraint (P(milestone not slipped) ≥ 0.8). The recommended
alternative under the *default* criterion is what the register leads with;
the default is proposed in open question 1 and is itself a parameter
(`decisionCriterion`) under ECN discipline.

## Build (validate after each step)

1. **`model/Scenarios.sysml` — package `SeleniteScenarios`.** `enum def
   DistributionKind { pointValue; uniform; triangular; pert; logNormal;
   discrete; }`; `abstract attribute def UncertainReal` with `nominal`,
   `low`, `high`, `source : String` and `abstract attribute distribution :
   DistributionKind`, bound in concrete subtypes (`TriangularReal`,
   `PertReal`, `UniformReal`, `LogNormalReal`, `PointReal`) with `attribute
   redefines distribution = DistributionKind::triangular` — the Wave 2 phase
   idiom, it clears SSM021. An `UncertaintyRegister` part lists every
   uncertain parameter as an `UncertainReal` whose `nominal` / `low` / `high`
   are **bound to the existing `ProgrammeParameters` attributes** (for
   example `thoriumGradePpm`, `thoriumGradePpmLow`, `thoriumGradePpmHigh`),
   never retyped; where no range exists, `low` / `high` stay unbound with a
   `doc` naming what source would bind them. A `DecisionCatalogue` holds
   D1–D8 as `variation part def`s whose `variant`s are the alternatives, each
   variant carrying a `doc` with its source; the alternative currently
   assumed by the baseline is selected in `ProgrammeConfiguration.sysml` by
   `part d1 : EclipseOperatingStrategy = EclipseOperatingStrategy::
   carryThroughEclipse;` (or `:> …::carryThroughEclipse`; both clear
   SSM021), and a decision the baseline leaves open stays `abstract part`.
   One `analysis def` per trade extends `TradeStudies::TradeStudy` with a
   `MinimizeObjective` / `MaximizeObjective` whose `fn` reads a `#moe`
   attribute, and carries `@ToolExecution { toolName = "selenite.scenarios";
   uri = "…"; }` naming the Python entry point. A `ScenarioDef` is a named
   set of parameter overrides; model at least `baseline`, `lowLaunchCost`,
   `lateMType` and `highThorium` as named scenarios beside the sampled space.
2. **Eclipse operating strategy in the model (D1).** On the asteroid
   processing stages in `Processing.sysml` (C-type pyrolysis / F–T, S-type
   Czochralski and electrolysis, M-type hydromet) add `pausableThroughEclipse
   : Boolean`, `holdLoadFraction : UncertainReal` and
   `minimumContinuousRunHours : Real` — **unbound** unless Decision Framework
   §10.1, Strategy v3.1 §5.1 or a process source gives a value; Czochralski
   growth cannot pause mid-crystal, so its alternative is scheduling whole
   batches between eclipses, not a hold. Parameters: `spaDarkFraction`
   (derived as `1 − illumination`, VERIFY `solar.illum` 0.85),
   `spaDesignEclipseHours = 72` (Strategy §12.1, VERIFY `eclipse_hr`),
   `plantOversizeMassPenaltyKgPerKw` and `eclipseRestartLossFraction`
   (unbound with provenance). `spaAsteroidLoadCriticalFraction` **keeps its
   ECN-022 value 1.0** as the declared assumption; the configuration gains a
   derived twin (`calc def EclipseCriticalFraction` in `SeleniteAnalysis`,
   evaluated per strategy) and the register shows both. Rebinding it is
   ECN-023, Jason's call. PKT is out of D1: its 14-day night is why it is
   MSR-powered by design (Strategy §12.2). The PKT P8 FSP-to-MSR handover
   (DG-9.3 / DG-10.4) is the same FSP-versus-MSR trade as D2 and may be
   added as D2b if time allows.
3. **Python `selenite/scenarios/` (new subpackage, `PORTED = False`, no
   golden).** `modelio.py` at package level: move the regex parsers out of
   `tools/plan_check.py` (`read_model`, `parse_gates`, `parse_phase_windows`,
   `parse_numeric_attributes`, `parse_configuration` …) so both tools read
   the model through one module; `plan_check` keeps its CLI and its output
   byte-identical (a test diffs `--markdown` before and after). Then:
   `space.py` (the parameter space read from `UncertaintyRegister`);
   `sample.py` (Latin hypercube or Sobol via `scipy.stats.qmc`, fixed seed,
   `n` declared; **common random numbers**: every alternative of every
   decision is evaluated on the same sample matrix so comparisons are
   paired); `econ_param.py` (a parametrised ECON: a `Params` dataclass
   holding every value hard-coded in `econ.py` lines 80–140 plus the tornado
   knobs; `econ_param.workspace(Params())` must equal `econ.workspace()` on
   every golden key at `rel_tol=1e-9` — a test asserts it; `econ.py` and the
   goldens are not touched); `eclipse.py` (D1: per strategy and sample, the
   critical-load vector, FSP count, battery mass, oversize mass, throughput
   lost, then `fsp_msr_trade` with the resulting critical fraction);
   `trades.py` (D2–D8 wrapping `plan_vectors` and `econ_param`);
   `criteria.py` (expected value, quantiles, CVaR, regret, chance
   constraint); `run.py` (the catalogue → one `DecisionResult` per decision:
   per alternative per MOE mean / P10 / P50 / P90, win probability under
   each criterion, the recommended alternative, and the Monte Carlo standard
   error). Tests: sampler determinism under seed; CRN pairing; `econ_param`
   equality at defaults; D1 monotonicity (more pausable load → no more FSP
   units); every catalogued decision has an evaluator or a declared stub.
4. **`tools/scenario_check.py`** — prints `docs/SCENARIO_REGISTER.md` with
   `--markdown`, `--quiet`, `--n`, `--seed`: (a) the uncertainty register
   (parameter, nominal, low, high, distribution, source, bound or point);
   (b) per decision, alternatives × MOEs with mean / P10 / P50 / P90, the
   recommended alternative under each criterion and its win probability; (c)
   gate-year distributions for every gate in the catalogue's "Gates" column
   (P10 / P50 / P90 year and P(met by declared year)); (d) a convergence line
   (n, seed, largest standard error relative to the mean). Structural checks
   exit 1: every `variation` in the catalogue has an evaluator or a stub;
   every `UncertainReal` in the register is sampled or declared a point;
   every `#moe` is reported. Wire into the `compute` CI job after
   `plan_check` with `--n 500 --seed 20260920` and upload the register as an
   artefact; the default `--n` is 2,000 for local runs.
5. **Probabilities into the plan register.** `plan_check.py --with-scenarios`
   adds one column, "P(met by declared year)", to the gate table from the
   scenario run; the deterministic columns are unchanged (the byte-identity
   test above covers the default invocation).
6. **Diagrams, docs, ECN draft.** Add `scenarios_view` to
   `tools/render_diagrams.sh`. `CHANGELOG_WAVE4A.md` in ECN style with the
   catalogue, the uncertainty register and the D1 result. Draft
   `docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md`: the recommended
   strategy, its win probability and criterion, the derived
   `spaAsteroidLoadCriticalFraction` under it, and what it changes in the
   Decision Framework — **awaiting Jason**, not applied. `mapping/
   document_map.csv` rows for the new files; `docs/DOCUMENT_FAMILIES.md`
   Tier 6 gains the ECN-023 draft; `docs/CLAUDE_SYSML_CONTEXT.md` gains rule
   5d (uncertain values and the scenario discipline) and a §8 update.

## Rules (in addition to Wave 3's, which all still hold)

- Goldens, `econ.py`, `verify.py`, `thermal.py`, `psr_layout.py` and their
  tests are untouched. Parametrisation lives in a wrapper that must equal the
  port at defaults, proven by a test.
- No distribution parameter is typed from a document unless it is an existing
  Low/High pair or a cited source. Otherwise the parameter is a point at
  nominal, the range is unbound with provenance, and the register says so.
- Every comparison uses common random numbers and a fixed seed; `n` and the
  seed are printed in the register; results are quantiles, never single
  numbers; a recommendation always carries its criterion and win probability.
- Stochastic optimisation is sample-average approximation over discrete
  alternatives, with recourse decisions re-evaluated per sample (two-stage).
  numpy and scipy only — no solver dependencies. A continuous decision (none
  in the catalogue today) would use `scipy.optimize` on the SAA objective
  with the seed fixed.
- The wave produces recommendations and draft ECNs. It never rebinds a
  committed parameter: ECN-022 values stand until Jason signs ECN-023.
- Conflicts recorded, not resolved. ECN-021 stays out. Novel stays out.
  Australian spelling. Flat `model/`. Validate to exit 0, zero hints;
  `plan_check.py --quiet` exit 0; `pytest` green. Commit on the designated
  branch, open a PR.

## Idioms (probed against sysml-validate 0.36.0 on 20 Sep 2026, zero hints)

```sysml
package SeleniteScenarios {
    private import AnalysisTooling::*;
    private import ParametersOfInterestMetadata::*;
    private import ScalarValues::*;
    private import TradeStudies::*;

    enum def DistributionKind { pointValue; uniform; triangular; pert; logNormal; discrete; }

    abstract attribute def UncertainReal {
        attribute nominal : Real;
        attribute low : Real;
        attribute high : Real;
        attribute source : String;
        abstract attribute distribution : DistributionKind;
    }
    attribute def TriangularReal :> UncertainReal {
        attribute redefines distribution = DistributionKind::triangular;
    }

    part def PowerOption {
        #moe attribute earthMassTonnes : Real;
        attribute thoriumGradePpm : TriangularReal;
    }

    variation part def EclipseOperatingStrategy :> PowerOption {
        variant part carryThroughEclipse : PowerOption;
        variant part sunlitDutyCycle : PowerOption;
        variant part hotStandby : PowerOption;
        variant part hybridStorage : PowerOption;
    }

    analysis def ScenarioTrade :> TradeStudy {
        subject options : PowerOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : PowerOption;
                return :>> result = option.earthMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/eclipse.py";
        }
    }
    analysis eclipseTrade : ScenarioTrade;
}

// In ProgrammeConfiguration.sysml — the baseline's selection, and an open one:
//   part d1 : PowerOption = EclipseOperatingStrategy::carryThroughEclipse;
//   part d1Alt :> EclipseOperatingStrategy::carryThroughEclipse;
//   abstract part d3 : CanisterRecoveryOption;
```

Do not name a nested calc `EvaluationFunction` (RES016: it shadows the
library element); redefine `fn` as above.

## Open questions for Jason (answer in the session, or leave recorded)

1. **Default decision criterion.** Proposed: minimise expected cumulative
   Earth-launched mass subject to P(no milestone slip) ≥ 0.8, with NPV and
   CVaR reported beside it. Alternative: maximise expected NPV. Lexicographic
   (mass, then NPV) is a third option.
2. **Dark-fraction source.** VERIFY's 0.85 illumination is an annual average
   for the site. Is there an eclipse-duration distribution (Gläser et al.
   2014 / 2018, or a final-report figure) in the project files? If not, the
   wave declares a triangular 0.10–0.20 with the source unbound.
3. **Czochralski minimum run.** Can an S-type silicon batch (Decision
   Framework §10.1) be sized to complete within a sunlit window? If not,
   Czochralski is never pausable and its hold load is a furnace hold.
4. **Canister option (D3).** In scope for 4A, or does it wait for
   SEL-CANISTER-001 Rev A (Decision Framework §12 item 2)?

## Done when

- `Scenarios.sysml` validates at zero hints with D1–D8 catalogued as
  variations, the uncertainty register bound to existing parameter ranges,
  trade-study analyses with `@ToolExecution`, and the baseline selections in
  `ProgrammeConfiguration.sysml`.
- `selenite/scenarios/` evaluates D1, D2, D4, D5 and D6 stochastically with
  common random numbers under a fixed seed; `econ_param` equals the port at
  defaults; `plan_check` output is byte-identical by default.
- `tools/scenario_check.py` prints `docs/SCENARIO_REGISTER.md` in CI with the
  convergence line; D1 has a recommended strategy with its win probability,
  and `docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md` states the derived
  `spaAsteroidLoadCriticalFraction` under it, awaiting Jason.
- `pytest` green, validation exit 0 zero hints, diagrams regenerated with
  `scenarios_view`, `CHANGELOG_WAVE4A.md` in ECN style, PR opened.
