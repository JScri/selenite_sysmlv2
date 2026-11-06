# Wave 4A — Scenarios, uncertainty and decision analysis

## Delivery — 6 November 2026

```
CHANGE LOG — 6 November 2026 (Wave 4A: scenarios, uncertainty and decision analysis)
Scope: turn the deterministic derived plan of Wave 3 into a decision engine —
       the model declares the decisions (D1–D8), their alternatives, the
       uncertain inputs and the measures of value; the Python layer samples
       the uncertainty, evaluates every alternative on the same samples and
       prints a register of which alternative wins under which criterion.
       Lead case D1: the SPA eclipse operating strategy behind
       spaAsteroidLoadCriticalFraction (ECN-022 §2.4).
Baseline in:  Wave 4 kick-off merged (PR #8, 6203db4); 15 model files, exit 0,
              zero hints; pytest 1,456 passed, 33 skipped; plan_check exit 0.
Baseline out: 16 model files, exit 0, zero hints; seven diagrams; pytest
              1,565 passed, 33 skipped; plan_check exit 0 and
              byte-identical by default; scenario_check exit 0,
              docs/SCENARIO_REGISTER.md at n = 2,000; SEL-ECN-023 DRAFT
              awaiting Jason. No committed parameter rebound.
```

### 0. Start-up findings

- `tools/validate.sh` on the inherited tree: 15 files, exit 0, zero hints.
  `pytest selenite-compute`: 1,456 passed, 33 skipped. `plan_check.py
  --quiet`: exit 0. The brief's idioms (`variation` / `variant`,
  `TradeStudies`, `AnalysisTooling`, `ParametersOfInterestMetadata`,
  `RiskMetadata`, `@ToolExecution`, `#moe`) validate on sysml-validate
  0.36.0 with zero hints, with two corrections recorded in §1.
- **W4A-N2 — the unpinned diagram CLI broke.** `npm install -g sysml-diagram`
  now installs 0.54.0, which rejects the Wave 3 gate-binding idiom
  (`attribute redefines introducedIn = gates.x.derivedPhase`, SSM079
  "redefinition replaces a fixed value", 87 errors in
  `ProgrammeConfiguration.sysml`) on the untouched main model, while
  sysml-validate 0.36.0 accepts it. Wave 3 rendered with 0.42.0, which
  renders every view cleanly (exit 0). Pinned to 0.42.0 in CI, the context
  doc and the brief; CI on main had not run since 28 Sep and would have
  failed its render step on the next push.
- The Wave 3 transcript (reviewed for open question 1) shows Jason never
  named a criterion — "the most economical decision", "compute and compare
  different scenarios", "stochastic optimisation" (20 Sep 2026) — and that
  the one trade Wave 3 decided (the SPA MSR, ECN-022 §2.3) was decided on
  Earth-launched cargo mass. The brief's proposed default is consistent with
  that practice; it is carried as a **proposal** (`decisionCriterion`,
  Parameters.sysml), not a decision.

### 1. Decisions and resolutions recorded

| Item | Resolution |
|---|---|
| Open question 1 — default criterion | **Proposed, not decided:** minimise expected cumulative Earth-launched mass subject to P(no gate slip) ≥ 0.8 (`ProgrammeParameters.decisionCriterion = DecisionCriterion::expectedEarthMassWithSlipChance`, `chanceConstraintThreshold = 0.8`); expected NPV, P90, CVaR90 and minimax regret reported beside it on every decision. Jason confirms or changes it in ECN-023. |
| Open question 2 — dark-fraction source | The NASA South Pole–Aitken basin page Jason offered describes the basin's geology and carries no illumination figure (checked through search; the host is outside this session's network allow-list, so it could not be fetched directly) — not a source. **Gläser et al. 2014** (Icarus 243, 78–90; EPSC 2014-136), already cited by `Power.sysml` for the array: 77.1–88.0 % average illumination at the Shackleton-rim and Connecting Ridge candidate sites → `spaDarkFractionLow = 0.12`, `spaDarkFractionHigh = 0.229`, VERIFY's 0.15 (`solar.illum` 0.85) nominal and inside the range; longest continuous darkness "typically 3–5 days" → `spaLongestEclipseHoursHigh = 120` against the 72 h design case (**W4A-N1**). The brief's fallback (triangular 0.10–0.20, source unbound) is superseded. |
| Open question 3 — Czochralski window | **Yes, a batch fits.** Jason's reading "a batch takes 1–3 days" → `czochralskiBatchHours` 48 (24–72, source: Jason, 6 Nov 2026); the sunlit window between successive eclipses is at least the synodic month less the longest eclipse (`lunarSynodicPeriodHours` 708.7 − 72…120 h = 589–637 h), so every sampled batch fits with about nine times margin (`SeleniteAnalysis::SunlitWindowGate`, a test asserts it on 500 samples). Czochralski is therefore batch-scheduled between eclipses, cold between batches (hold load nil); its eclipse cost is half a batch of scheduling slack per eclipse, covered by the duty cycle's oversize. External figures found (200 mm cycles ~1–2 days; 300 mm pulls 60–100 h, vendor data) are recorded, not bound. |
| Open question 4 — D3 | **In scope** (Jason, 6 Nov 2026): evaluated, not stubbed, with the impact-survival test as the recourse (a failed test falls back 2 → 1b → 1a). |
| D1 as a trade, not a constant | `spaAsteroidLoadCriticalFraction` **keeps 1.0** (ECN-022 §2.4); its derived twin `SeleniteAnalysis::EclipseCriticalFraction` is evaluated per strategy and per sample and the register prints both. Rebinding it is SEL-ECN-023 (draft). |
| Variation idiom (SSM030) | Every usage nested in a `variation part def` is a variant, so catalogue metadata (`decisionId`, `title`, `stage`, `gates`, `uncertainInputs`, `evaluator`, `evaluatorStatus`) lives in a `…Decision` supertype (`abstract part def Decision`) that the variation specialises beside its option type. Recorded as rule 5d. |
| Selection idiom (SSM021) | `part d1 : EclipseStrategyOption = EclipseOperatingStrategy::carryThroughEclipse;` raises SSM021 in the real model (the variant carries the abstract variation's type); the subsetting form `part d1 :> EclipseOperatingStrategy::carryThroughEclipse;` is clean and is what the configuration uses; the catalogue's own `part dN : Variation` usages are `abstract`. |
| Unsourced quantities | Hold-load fraction per process and the restart loss per eclipse have no process source (SEL-PROC-C-001 / SEL-PROC-S-001 do not exist): UNBOUND in the model (`AsteroidProcessStep.holdLoadFraction : PointReal`, `eclipseRestartLossDaysPerEclipse`), **ASSUMED** in the evaluator (`eclipse.ASSUMED_HOLD_LOAD_FRACTION` 0.25 per line, `ASSUMED_RESTART_LOSS_DAYS` 0.5) and printed as such; the named scenarios `holdLoadLow` (0.05) and `holdLoadHigh` (0.50) carry the sensitivity (rule 5d: sensitivities without a source are scenarios, not distributions) — **W4A-N3**. |
| Proxy ranges | `plantOversizeMassPenaltyKgPerKw` 70 (70–83.3) is the Decision Framework §4 circuit-design table (28,000 kg / 400 kW … 15,000 / 180), a plant of the same kind, flagged PROXY; its Earth-launched share follows the ECON circuit Earth-fraction trajectory, with `earthBuiltAsteroidPlant` (1.0) as a scenario. |
| Two-point conflicts sampled | Rule 5b candidates become `DiscreteReal` entries with equal weights (uninformative, stated): REO ramp knots (W3-N4), canister payload 3.5 / 3.6 t (W3-N7 / VC-22), PSR capacity 620 / 310 (W2-N18), hauler floor 0.43 / 0.08 (F3). Test outcomes (impact survival, Mk III validation) are sampled Booleans at an uninformative 0.5, range unbound — **W4A-N4**. |
| Capture years | No document states a range for the capture years or the redirect-to-arrival lag; they stay points (`mTypeCaptureYearLow/High`, `asteroidOnlineLagYearsLow/High` unbound) and the `lateMType` scenario carries the sensitivity — **W4A-N5**. |
| ECON tornado as ranges | Launch cost ±50 %, discount rate 1.4–3.5 % (as a multiplier on the 3 / 2.5 / 2 % schedule, 0.4667–1.1667), REO externality $50–90 k/t, H₂ attribution 25–100 %, geo insurance $0–25 B/yr, circuit maintenance 0.25–0.5 %: triangular on the v1.4 bounds with the v1.3 value nominal. `thcl4AvailableYear` 43–60 (DG-9.6's two declared phases) and `solarInSituStartYear` 60–80 (DF §6, P11) are the remaining sourced ranges. |
| Slip definition | Gate slip is measured against the plan's own date: the declared year, or the Wave 3 derived year at nominal where the deterministic register already derives the gate later (W3-R rows); exogenous gates and the years ECN-022 superseded (DG-10.5 Y50, DG-11.3 Y70) are excluded. MTL v8.5 milestones M5 / M6 / M8 and the first-export year are not derivable from the Python layer and are reported as not modelled. |
| Lost throughput | A strategy that delivers less than the planned asteroid output is charged where ECON values the lines: the circuit Earth-fraction reductions (0.07 after the C-type, 0.022 after the S-type) scale with the delivered fraction, so hot standby's 15–20 % loss costs about 1 Mt of Earth cargo; the duty-cycle strategies oversize for the dark fraction and the restart losses and keep the planned output. |

### 2. Changes by file

- **`model/Scenarios.sysml`** (new) — package `SeleniteScenarios`:
  `DistributionKind`; `abstract attribute def UncertainReal` with
  `PointReal`, `UniformReal`, `TriangularReal`, `PertReal`, `LogNormalReal`,
  `DiscreteReal` (the Wave 2 redefines idiom); `UncertaintyRegister` with 32
  entries, each bound to a `ProgrammeParameters` attribute and its Low /
  High twins (18 sampled, 14 points with the reason stated);
  `DecisionOption` and eight option definitions with `#moe` attributes;
  `Decision` metadata supertype, `DecisionStage`; eight `variation part
  def`s D1–D8 with their variants and sources; `DecisionCatalogue`; eight
  `analysis def … :> TradeStudy` with `MinimizeObjective` on the default
  measure and `@ToolExecution { toolName = "selenite.scenarios"; uri = … }`;
  `TradeStudySet`; `ScenarioDef` and `ScenarioSet` with ten named scenarios
  (`baseline`, `lowLaunchCost`, `lateMType`, `highThorium`, `msrUnavailable`,
  `msrUncertain`, `earthBuiltAsteroidPlant`, `holdLoadLow`, `holdLoadHigh`,
  `darkSite`).
- **`model/Parameters.sysml`** — `enum def DecisionCriterion`;
  `decisionCriterion` (PROPOSED) and `chanceConstraintThreshold`; the D1
  parameters (`spaIlluminatedFraction` 0.85, `spaDarkFraction` derived,
  `spaDarkFractionLow/High`, `spaDesignEclipseHours` 72,
  `spaLongestEclipseHoursLow/High`, `lunarSynodicPeriodHours`,
  `czochralskiBatchHours` + range, `plantOversizeMassPenaltyKgPerKw` + range,
  `eclipseRestartLossDaysPerEclipse` unbound, `hybridStoredLoadFraction`
  0.5, `spaMsrAvailabilityProbability` 1.0, the VERIFY / ECON transcriptions
  `batterySpecificEnergyWhPerKg`, `batteryMarginFactor`, `fspUnitPowerKw`,
  `fspUnitMassKg`, `solarPanelMassKgPerM2`, `msrUnitMassKg`,
  `msrEarthFractionFloor`); the sampled scenario inputs
  (`thcl4AvailableYear`, `solarInSituStartYear` + `solarInSituEarthFraction`,
  `launchCostMultiplier`, `discountRateMultiplier`,
  `reoExternalityUsdPerTonne`, `h2AttributionFraction`,
  `geoInsuranceUsdMPerYear`, `circuitMaintenanceFractionPerYear`,
  `reoRampKnotShift`, each with Low / High); the rule 5b candidates
  (`reoPayloadPerCanisterTonnesEcon/Ecn020`, `canisterEarthContent…` ×3,
  `impactSurvivalPassProbability`, `psrMoleICapacityUnitsDocument`,
  `mkIiiTestPassProbability`, `haulerEarthFractionFloorEcon/FleetV9`); the
  unbound capture-year ranges. `spaMsrDoc` gains the derived-twin note.
  **Every pre-existing bound value is unchanged** (the review diffs it).
- **`model/ThroughputCalcs.sysml`** — `EclipseCriticalFraction` (the D1
  derived twin), `PlantOversizeFactor`, `EclipseBatteryMass` (the VERIFY
  rule), `SunlitWindowGate`, `FspUnitsForLoad`.
- **`model/Processing.sysml`** — `AsteroidProcessStep` (`stepName`,
  `pausableThroughEclipse`, `holdLoadFraction : PointReal`,
  `minimumContinuousRunHours`); `AsteroidProcessingLine` gains the same
  three attributes; `MTypeProcessingLine.hydromet`,
  `CTypeProcessingLine.pyrolysis` / `fischerTropsch`,
  `STypeProcessingLine.czochralski` / `copperElectrolysis`, each pausable,
  hold fractions unbound with the source named; imports `SeleniteScenarios`.
- **`model/ProgrammeConfiguration.sysml`** — `uncertainty :
  UncertaintyRegister`, `decisions : DecisionCatalogue`, `trades :
  TradeStudySet`, `scenarios : ScenarioSet`; the baseline's selections
  `d1 :> …::carryThroughEclipse` (ECN-022 §2.4), `d2 :> …::msrWhenJustified`
  (§2.3), `abstract part d3` (DG-9.1 open), `d4 :> …::optimisedDesign`,
  `d5`, `d6` (consequences), `d7 :> …::testOutcomeDriven` (§2.6),
  `d8 :> …::econFloor`; `sTypeLine.minimumContinuousRunHours` and its
  `czochralski` step bound to `parameters.czochralskiBatchHours`.
- **`selenite-compute/selenite/scenarios/`** (new subpackage, `PORTED =
  False`, no golden): `modelio.py` (the regex parsers moved verbatim out of
  `plan_check.py`, `read_model(model_dir)`), `space.py` (the register, the
  catalogue, the MOEs, the analyses, the scenarios and the selections read
  from the model; parameter expressions evaluated), `sample.py` (Latin
  hypercube / Sobol via `scipy.stats.qmc`, fixed seed, inverse-CDF
  marginals, common random numbers, `Samples.hash`), `econ_param.py`
  (`Params` with every ECON v1.3 literal as a field; `v1_3(Params())`
  equals `econ._v1_3()` bit-for-bit — 292 workspace keys at rtol 1e-9, the
  goldens untouched; `workspace(p)` runs v1.4 on it; `metrics(ws)`),
  `eclipse.py` (D1: the four strategy profiles, the critical-load vector,
  FSP count, battery, oversize, throughput, the FSP-versus-MSR recourse per
  sample, the two worlds and the break-even probability,
  `verify_transcription`), `trades.py` (D2–D8 on `plan_vectors` and
  `econ_param`, base-run reuse where a sample's `Params` are unchanged),
  `criteria.py` (summaries, CVaR, win probability, expected value, P90,
  CVaR90, minimax regret, chance constraint, `recommend`), `run.py` (the
  catalogue run: one `DecisionResult` per decision with mean / P10 / P50 /
  P90 per MOE, every criterion's recommendation and the lead, gate-year
  distributions, slips against the plan's reference dates, the convergence
  line, named scenarios, `gate_probabilities` for plan_check).
- **`tools/scenario_check.py`** (new) — prints `docs/SCENARIO_REGISTER.md`
  (`--markdown`, `--quiet`, `--n`, `--seed`, `--method`, `--scenario`,
  `--scenario-n`, `--no-scenarios`, `--decisions`): the uncertainty register
  and the assumptions; per decision the alternatives × MOEs, the risk
  measures, every criterion's recommendation, for D1 the declared versus
  derived critical fraction, the two worlds and the break-even
  probabilities; gate-year distributions with P(met by declared year); the
  named scenarios at max(100, n / 20) samples; structural checks (exit 1).
- **`tools/plan_check.py`** — the model-reading layer imported from
  `selenite.scenarios.modelio` (sys.path fallback to the checkout); output
  byte-identical by default (two tests diff it against
  `docs/PLAN_REGISTER.md` and the pre-refactor stdout capture
  `tests/fixtures/plan_check_stdout_wave3.txt`); `--with-scenarios`
  appends one column, "P(met by declared year)".
- **`tools/render_diagrams.sh`** — `scenarios_view`; `diagrams/
  scenarios_view.svg` (new), the six others regenerated with 0.42.0.
- **`.github/workflows/validate.yml`** — `sysml-diagram@0.42.0` pinned
  (W4A-N2); `compute` job runs `scenario_check.py --n 500 --seed 20260920
  --markdown scenario_register.md --quiet` after `plan_check` and uploads
  the register.
- **`selenite-compute/tests/`** — `test_econ_param.py` (equality at
  defaults, knob effects, speed), `test_modelio.py` (byte-identity,
  parsers, fallback), `test_sample.py`, `test_criteria.py`,
  `test_scenarios.py` (the register from the model, determinism under
  seed, CRN pairing, D1 reproduces the Wave 3 fallback, D1 monotonicity,
  duty cycle keeps throughput, the VERIFY battery rule, the two worlds,
  break-even, every decision evaluated and every `#moe` reported, named
  scenarios, both tools end to end).
- **`docs/SCENARIO_REGISTER.md`** (new, generated at n = 2,000, seed
  20260920), **`docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md`** (new,
  DRAFT), **`docs/CLAUDE_SYSML_CONTEXT.md`** (rule 5d, the scenario
  register and the diagram pin in §4, SSM030 / SSM079 in §7, §8),
  **`docs/MIGRATION_PLAN.md`**, **`docs/DOCUMENT_FAMILIES.md`** (Tier 6,
  Wave 4A observations), **`mapping/document_map.csv`** (four rows),
  **`README.md`**, **`docs/SESSION_BRIEF_wave4_scenarios.md`** (status).

### 3. The catalogue

| ID | Decision | Alternatives (variants) | Stage | Evaluator |
|---|---|---|---|---|
| D1 | SPA eclipse operating strategy | carryThroughEclipse (ECN-022 §2.4), sunlitDutyCycle, hotStandby, hybridStorage | now (FSP/MSR count as recourse) | `eclipse.evaluate_d1` |
| D2 | SPA power supply mix | nonNuclearOnly, msrWhenJustified (ECN-022 §2.3), msrAtThcl4Availability | recourse | `trades.evaluate_d2` |
| D3 | Canister recovery architecture (DG-9.1) | fullParachute, minimalDragChute, shuttlecock | now (test as recourse) | `trades.evaluate_d3` |
| D4 | Processing circuit design | batchDesign, continuousFlowDesign, optimisedDesign | now | `trades.evaluate_d4` |
| D5 | MD-4 / Starship-return retirement timing | consequenceOfMTypeArrival | recourse | `trades.evaluate_d5` |
| D6 | Thorium stream sizing | consequenceOfGradeAndCapture | recourse | `trades.evaluate_d6` |
| D7 | Mk III transition trigger | capacityForced, testOutcomeDriven | recourse | `trades.evaluate_d7` |
| D8 | Hauler in-situ fraction policy | econFloor, targetFloor | recourse | `trades.evaluate_d8` |

None stubbed. The uncertainty register and the full tables are in
`docs/SCENARIO_REGISTER.md`.

### 4. The D1 result (n = 2,000, seed 20260920; register §2 D1)

Four strategies on the same 2,000 samples, the FSP-versus-MSR count as the
recourse per sample. Derived eclipse-critical fraction: A carryThroughEclipse
1.00 (declared), B sunlitDutyCycle 0.15, C hotStandby 0.15, D hybridStorage
0.575. SPA power-side Earth mass with the MSR available at the C-type
arrival (the committed plan, `spaMsrAvailabilityProbability` 1.0): A 135 t,
B 313 t, C 135 t, D 53,017 t (half of 250 MW on battery through a 72–120 h
eclipse); without it: A 42,117 t (6,254 FSP), B 7,425 t (941 FSP), C
7,051 t, D 56,943 t. Hot standby loses 17–25 % of asteroid output, charged
at about 1.0 Mt of Earth cargo through the circuit Earth-fraction
reductions the lines enable. Total expected Earth-launched mass: A
6,935,204 t; B +178 t; C +1.01 Mt; D +52.9 kt; P(no slip) 1.00 for every
strategy; the SPA MSR's first unit is Y105 under every strategy (matches
ECN-022 §2.3 / DG-13.4).

**Under the default criterion at the committed availability of 1.0 the
register recommends A, carryThroughEclipse, P(win) 1.00 — by 178 t
(0.003 % of the programme's Earth-launched mass).** The recommendation
flips to B at any MSR availability below **0.995** (break-even; at 0.9 B's
expected SPA power-side mass is 1,025 t against A's 4,334 t), and minimax
regret prefers B (worst regret 178 t against A's 34.7 kt). C is never
better than B; D never beats A. SEL-ECN-023 (draft) puts both readings to
Jason and recommends B with the fraction rebound to its derived 0.15.

Headline results of the other decisions (expected cumulative Earth-launched
mass, default criterion): D2 msrWhenJustified (ECN-022 §2.3 policy) P(win) 1.00, first MSR Y105;
D3 shuttlecock P(win) 0.71 on an uninformative 0.5 impact-survival
probability with the 2 → 1b → 1a fallback (1a 9.08 Mt, 1b 8.01 Mt, 2 6.98
Mt expected); D4 optimisedDesign P(win) 1.00 (batch +2.03 Mt,
continuous-flow +0.59 Mt); D5 MD-4 Y85 (a point, W4A-N5); D6 DG-8.7 at
Y37–38 (P10–P90), never by its declared Y30; D7 a 0.50 / 0.50 tie between
capacity-forced (never on 620 positions, Y31 on 310) and the test outcome
(0.5); D8 a 0.50 / 0.50 tie that is exactly F3 (floor 0.08 beats the 0.20
target, 0.43 loses to it), DG-13.7 met by Y120 with probability 0.50.

### 5. Observations W4A-N1 … W4A-N6 (recorded, not resolved)

| # | Observation | Where |
|---|---|---|
| W4A-N1 | Gläser et al. 2014 give the longest continuous darkness at the candidate sites as "typically 3–5 days"; Strategy v3.1 §12.1 and VERIFY design for 72 h. The FSP count is sized on power and does not move; the hybrid strategy's battery and the hold energy are sized on the sampled 72–120 h. A five-day eclipse exceeds the design case. | `Parameters.sysml` eclipseDoc |
| W4A-N2 | `sysml-diagram` 0.54.0 (the unpinned latest) rejects the Wave 3 gate-binding idiom with SSM079 on the untouched main model; sysml-validate 0.36.0 accepts it. Pinned to 0.42.0; the idiom itself is unchanged. Revisit if the validator adopts the same rule. | `validate.yml`, context doc §4, §7 |
| W4A-N3 | Hold-load fractions (0.25 per line) and the restart loss (0.5 day per eclipse) are evaluator working assumptions without a process source; the register prints them ASSUMED and the `holdLoadLow` / `holdLoadHigh` scenarios bracket them (0.05–0.50). Binding them is an ECN with a process source. | `eclipse.py`, `Processing.sysml`, register §1 |
| W4A-N4 | Two-point conflicts (REO ramp knots, canister payload, PSR capacity, hauler floor) and the test outcomes (impact survival, Mk III validation) are sampled with equal / 0.5 weights, uninformative; the register says so per row. A sourced probability replaces the weight. | register §1 |
| W4A-N5 | No document states a range for the capture years or the redirect-to-arrival lag, so D5's "year distribution" is a point; `lateMType` carries the sensitivity. | `Parameters.sysml` captureRangeDoc |
| W4A-N6 | The value of lost asteroid throughput is not in ECON (no revenue line for C/S-type products); it is charged through the circuit Earth-fraction reductions the lines enable, which makes 1 % of planned output worth roughly 30 kt of Earth cargo — a strong gearing that rests on ECON's own substitution model. | `eclipse.py`, `run.evaluate_d1` |

### 6. Validation

`sysml-validate model --workspace . --all` (0.36.0): **16 files checked, no
problems found** — exit 0, zero hints. `tools/render_diagrams.sh`
(sysml-diagram 0.42.0): seven SVGs, exit 0. `pytest selenite-compute`:
**1,565 passed, 33 skipped** (1,456 + the Wave 4A tests; the
1,404 golden rows unchanged). `tools/plan_check.py --quiet`: exit 0, output
byte-identical. `tools/scenario_check.py --quiet` (n = 2,000, seed 20260920):
exit 0, all structural checks passed; largest standard error 0.59 % of the mean (D3/shuttlecock), largest win-probability standard error 0.011; sampled dimensions 18.

### 7. Map updates

`mapping/document_map.csv`: the Wave 4A brief → `delivered`; SEL-ECN-023
draft → `draft_awaiting_decision`; `SCENARIO_REGISTER.md` → `generated`;
Gläser et al. 2014 → `cited_external`.

### 8. Open for Jason

1. **SEL-ECN-023** — the eclipse operating strategy and the derived
   `spaAsteroidLoadCriticalFraction` (docs/SEL-ECN-023_draft_…): sign,
   amend or reject.
2. **The default decision criterion** (open question 1): the proposal is
   carried in `ProgrammeParameters.decisionCriterion`; the register shows
   every criterion side by side so the choice can be made on its effect.
3. **`spaMsrAvailabilityProbability`**: the committed 1.0 restates Wave 3's
   assumed test outcomes; the D1 recommendation turns on it (break-even in
   ECN-023). A sourced probability for the thorium line (DG-7.5, DG-9.3)
   would settle D1.
4. **Hold-load fractions and the restart loss** (W4A-N3): a process source
   or a declared value by ECN.
