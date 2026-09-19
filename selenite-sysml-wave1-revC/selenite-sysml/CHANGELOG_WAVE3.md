# Wave 3 — Gates and the derived programme plan

## Kick-off — 14 September 2026 (same session as Wave 2 delivery)

```
CHANGE LOG — 14 September 2026 (Wave 3 kick-off)
Scope: reframe Wave 3 around derived timing (Jason's ruling), lay the
       structural skeleton, scaffold the Python port, brief the next session.
Baseline in:  Wave 2 merged to main (PR #1, c987e47)
Baseline out: Wave 3 skeleton, validation exit 0, zero hints; six diagrams
```

### Decision recorded
Timing is not gated on a predetermined phase where a condition on model data
decides it (rule 5c). Documents are inconsistent with one another
(W2-N1…N18); the model plus the Python layer become the single source of
decisions and the documents become renderings. Three kinds of "when":
consequences (derivable), decision gates with criteria (outcome assumed,
declared), exogenous inputs (declared parameters).

### Added
- `model/Parameters.sysml` — `SeleniteParameters::ProgrammeParameters`: the
  exogenous inputs with owner/kind/provenance. Bound: REO target, steady-state
  year, capture years Y75/Y95/Y115, crew policy. Unbound (Wave 5 / Python):
  PSR MOLE-I capacity (**W2-N18**: 310 vs 620 units, 8.5 / 17.5 / 33.2 km²),
  REO ramp vector, CO₂ per launch (VC-20), launch cost.
- `model/Gates.sysml` — `SeleniteGates`: `DecisionGate` base (gateId,
  criterion, evaluability derivable/testOutcome/exogenous, declaredPhase,
  derivedPhase unbound, prerequisites, gatedElements) and 14 gates the read
  sources name: DG-7.1, 7.5, 8.0, 8.X, 9.1, 9.3, 10.4, 10.5, 11.6, 13.2,
  14.3, 14.6, POST.1, POST.2; `GateCatalogue`. Open: DG-7.5 criterion,
  DG-14.3 vs DG-14.6, DG-13.2 numbering vs first truss at P12.
- `SeleniteConfigurations::seleniteProgramme` gains `parameters` and `gates`.
- `diagrams/gates_view.svg` (render script updated).
- `selenite-compute/` — Python port scaffold: `goldens.py` loader (all 1,016
  oracle rows, mat2str arrays, tags), `tests/test_goldens.py` (one test per
  comparable row, skips until the module is ported), `tests/test_loader.py`
  (green now), `tests/test_invariants.py` (oracle vs model commitments; VC-09
  and F5 arbiters are strict xfails because the runner v2.0 dropped those
  vectors), `tests/test_sources.py` (SHA-256 of sources vs manifest), module
  stubs per the port brief, `pyproject.toml`, README. CI job `compute` added
  to `.github/workflows/validate.yml`.
- `docs/SESSION_BRIEF_wave3_gates.md` — the next session's brief.

### Changed
- `docs/MIGRATION_PLAN.md` — Python port as a prerequisite track (blocked);
  Wave 3 reframed; Wave 5 gains the first derived timeline.
- `docs/SESSION_BRIEF_python_port.md` — status: blocked on sources, scaffold ready.
- `mapping/document_map.csv` — Decision Framework v4 and Strategy v3.1 rows
  flagged NOT IN REPO; Decision Framework retargeted to `Gates.sysml`.

## Addendum — 14 September 2026, evening (Jason's uploads)

**Unblocked.** All 20 MATLAB scripts are now in `selenite-goldens-runner-v2_1/`
and every SHA-256 matches the 8 Sep goldens manifest. A runner v2.1 capture
(`goldens_20260914_224703/`, MATLAB R2025a) is in the same folder and is the
new **canonical oracle**: it restores the vectors runner v2.0 dropped
(`circuits_needed`, `haulers_needed`, `conv_km_needed`, `msr_count`,
`cargo_spa_msr`, `spa_msr_count`, the VERIFY `ph.*` fleet vectors), and adds
VISUALIZE (66 rows). Rows: 107 / 237 / 171 / 269 / 313 / 274 / 66 = 1,437
for the seven current-baseline scripts (was 1,016 in the merged oracle).
`goldens_20260914_224604/` is an aborted run (manifest only) and can be deleted.
`selenite/goldens.py` reads the v2.1 capture and takes only the
`platform_dependent_ode` tags from the 8 Sep merged oracle. The two strict
xfails became real tests.

**Arbiters read from the goldens:**
- **F5:** `cargo_spa_msr` is first non-zero at **Y105**, then Y125 and Y140 —
  the economics assumed the SPA MSR #1/#2/#3 series (Decision Framework Rev D
  DG-13.4 / 14.4 / 14.7), not the Y50 (DG-10.5) or Y70 (DG-11.3) gates the same
  document also lists. Recorded as `SpaThoriumMSR.econAssumedIntroductionYear
  = 105`; `introducedIn` stays demand-gated per Jason's rule.
- **VC-09:** `msr_count` at Y200 = 8,334 and `circuits_needed` = 2,083,334 —
  the golden side is pinned by `test_invariants.py`; the model still carries
  the document's 6,890 pending Wave 5.
- **VC-01 / 07 / 08 / 10:** pinned likewise (5/30/55/90/180; 357 → 53;
  1.5 M haulers; 137,500 km).

**Documents added to `docs/`:** `SEL-T1_1-STRATEGY-v3_1.md`,
`SELENITE_DECISION_FRAMEWORK_v4.md` (SEL-DECISION-001 Rev D — F1 confirmed),
`SELENITE_DECISION_FRAMEWORK_v3_historical.md` (Rev C, for the diff record).
**Rev C → Rev D diff:** only the "Changes from" paragraph, §10.2 (PKT base
positioning table, resource adequacy 220–660 Mt / 88–264 yr, tiered depth
mining with DG-POST.1 ~Y280+ and DG-POST.2 ~Y380+), the "Beyond Y200"
paragraph (400–1,300 yr reserve replacing "millions of years"), open item 4
wording, open items 13–14. **No gate in §2 changed.**

**Gates filled from Rev D:** DG-7.5 (terrestrial MSR BR > 1.0, ~2040 = Y15,
inside the F7 gap), DG-13.2 (C-type redirect Y95, executed in P12 — W2-N19:
the id is also used for the laser truss), DG-14.3 (S-type processing at SPA
Y125; the Earth-independence gate is DG-14.6, "DG-14.3 from ECN-019"),
DG-POST.1/2 (Y280+/Y380+, P14plus), DG-10.5 doc (three SPA MSR gates, W2-N20).
Full catalogue (82 gates) remains Wave 3's first job.

**Housekeeping:** `.gitignore` added; `__pycache__` and `egg-info` untracked;
`selenite-compute/matlab_sources/` retired (sources stay with the runner).

### Blocked (Jason to unblock) — superseded by the addendum above
1. **MATLAB sources** are in the Claude.ai project knowledge, not in git. Copy
   `sabatier.m`, `SELENITE_VERIFY_v5_0.m`, `MOLEI_THERMAL_v1_3.m`,
   `SELENITE_ECON_V1_3.m`, `SELENITE_ECON_V1_4.m`, `scaling_v1_3.m`,
   `SELENITE_VISUALIZE_v3_3.m` into `selenite-compute/matlab_sources/`
   (`tests/test_sources.py` checks their hashes against the goldens manifest).
2. **Decision Framework v4 and Strategy v3.1** into the repo (`docs/` or root)
   for the Wave 3 gate catalogue.
3. Optional but valuable: rerun `RUN_GOLDENS.m` v2.1 while MATLAB access lasts
   so the dropped vectors (circuits, MSR count, `cargo_spa_msr`) are captured;
   two xfails in `test_invariants.py` turn green when they are.

## Addendum 2 — 14 September 2026, night (Python port delivered)

The port session ran on this branch after PR #2 merged: all six
current-baseline scripts are in `selenite-compute/` and reproduce the v2.1
goldens (1,404 rows, 33 declared skips) and the seven console captures.
Details and the findings the port revealed (R2025a `fzero` returns NaN
instead of throwing, ECON sensitivity-section inconsistencies, no
undiscounted break-even within 200 years) are in
`selenite-compute/CHANGELOG_PORT.md`. `docs/SESSION_BRIEF_python_port.md`,
`docs/MIGRATION_PLAN.md` and `docs/CLAUDE_SYSML_CONTEXT.md` carry the new
status. The model itself is unchanged by this addendum.

### Validation (after the addendum)
`sysml-validate` 0.36.0: 15 files checked, no problems found. `pytest
selenite-compute`: loader, invariant and source-hash tests pass; per-row
golden tests skip until each module is ported.

## Wave 3 delivery — 15 September 2026

```
CHANGE LOG — 15 September 2026 (Wave 3: gates and the derived programme plan)
Scope: every Decision Framework Rev D gate as a DecisionGate with criterion,
       evaluability, thresholds and calc; every phase attribute classified
       (consequence / exogenous / fixed) and the consequences bound to gates;
       SeleniteParameters completed; SEL-REQ-001..016 with checkable subjects;
       tools/plan_check.py prints the derived-vs-declared register and runs in CI.
Baseline in:  Python port merged (PR #3) + brief update (PR #4), main c65dcb1;
              15 model files, exit 0, zero hints; 14 gates.
Baseline out: 15 model files, exit 0, zero hints; 81 gates + 9 milestones;
              30 calc defs; 16 requirements; six diagrams; pytest 1,449 passed,
              33 skipped; plan_check exit 0, 55 register rows (docs/PLAN_REGISTER.md).
```

### 0. Start-up findings

- `tools/validate.sh` on the inherited tree: 15 files, exit 0, zero hints.
  `pytest selenite-compute`: 1,443 passed, 33 skipped (the brief's figures).
- The Decision Framework Rev D carries **81 unique gate identifiers**, not
  82: the brief's count includes the Rev A DG-10.3 canister-recovery decision
  that Rev D "brought forward" into DG-9.1. Carried on DG-9.1 as
  `formerGateId` and the recovery-option attributes, not as a gate (W3-N20).
- `SEL_FINAL_REPORT_v4.docx` (the Fig. 2 milestones the brief asks for) is
  not in the repository and its milestone list was never transcribed into any
  repo document. See W3-N13 and `SeleniteGates::MilestoneSet`.
- `ECN-019 Rev C` is likewise not in the repository; its committed decisions
  are cited through Strategy v3.1, which integrates them in its body text.
- The Python layer, read before quoting any figure (`CHANGELOG_PORT.md`):
  the ECON REO ramp, MSR, hauler, conveyor and PGM vectors are the arbiters
  below; `psr_layout.workspace()` gives 124 nodes × 5 = 620 MOLE-I positions.

### 1. Decisions and resolutions recorded

| Item | Resolution |
|---|---|
| DG-7.5 criterion (kick-off open item) | "commit only if terrestrial MSR demonstrates sustained BR >1.0" — a **testOutcome** gate (`assumedOutcome = true`, `BreedingRatioGate`, threshold `breedingRatioMinimum = 1.0`), gating the whole PKT MSR line (DG-8.9 → DG-9.3 → DG-10.4). Its year "~2040" is Y15 with `programmeStartCalendarYear = 2025`, i.e. inside the F7 gap while the document lists it under P7 (W3-N15). |
| DG-14.3 vs DG-14.6 (kick-off open item) | Rev D numbering carried: DG-14.3 = S-type processing at SPA (Y125); DG-14.6 = Earth-independence assessment, with `formerGateId = "DG-14.3 (ECN-019 …)"`. Strategy v3.1 uses both numbers for the assessment (s.16 vs s.15.1) — W3-N14. |
| DG-13.2 (W2-N19) | Gate-list definition carried (C-type redirect); listed under P13, "executed during P12" → `declaredPhase = P13`, `declaredPhaseAlternate = P12`, `derivedYear = cTypeCaptureYear`. The laser-truss use of the id stays a doc note. |
| declaredPhase convention | Now **mechanical**: the phase section the Decision Framework lists the gate under; `declaredYear` the year it gives; `declaredPhaseAlternate` a second phase the document itself states. The year-implied phase is computed by `plan_check`, never stored. This changes DG-13.2 (P12 → P13, alt P12) and DG-14.3 (P13 → P14, alt P13) from the kick-off values; the register shows the year-table drift explicitly instead of baking W2-N7 into `declaredPhase`. |
| Evaluability | Three abstract subtypes `DerivableGate` / `TestOutcomeGate` / `ExogenousGate` bind `evaluability`; classification is by the nature of the criterion, and a derivable gate whose vector does not exist yet prints "unevaluated" (DG-8.7, the five SPA MSR gates, DG-POST.1/2). Counts: derivable 39, testOutcome 13, exogenous 29. |
| Thresholds | Every numeric criterion is one attribute of `SeleniteParameters::GateThresholds` (38 values, each an ECN to the Decision Framework); calc defs take them as inputs and hold no literals. |
| Milestones M0–M8 | Modelled as `Milestone` / `MilestoneSet` with declared years and phases. **Proxy**: M0 = programme GO, M1–M8 = Decision Framework Rev D s.1 "eight critical transitions", ending at the Fig. 2 "Mission achieved Y180"; `confirmedAgainstFigure2 = false` on every row (W3-N13). |
| Gate binding idiom | An element's phase attribute is re-bound in the configuration to `gates.<usage>.derivedPhase` (unbound until Wave 5); the definition keeps the document value. Validated clean; the register reads both sides. |
| PSR capacity (W2-N18) | `psrMoleICapacityUnits = 620` bound from `psr_layout.py` (124 nodes × 5), with `psrMoleINodeCount` / `psrMoleIUnitsPerNode` and SEL-REQ-016 asserting the product; the fleet v9 figure 310 is a doc note and a plan_check sensitivity line only. |

### 2. Changes by file

- **`model/Gates.sysml`** — rewritten: `DecisionGate` gains `formerGateId`,
  `criterionAsModelled`, `declaredPhaseAlternate`, `declaredYear`,
  `declaredYearEnd`, `derivedYear`, `assumedOutcome`, `consequenceIfNotMet`
  (Strategy v3.1 s.16 wording); abstract `DerivableGate` / `TestOutcomeGate`
  / `ExogenousGate`; 81 gates DG-0.1 … DG-14.9, DG-POST.1/2 with criterion
  verbatim (ASCII transliteration stated in the package doc), prerequisites,
  gated elements, calc usages on derivable gates and the ECON-transcribed
  assumptions (`econYbcoCargoYears`, `canisterRecoveryOptionEconAssumed`,
  `econAssumedYear`); `Milestone`, `MilestoneSet` (M0–M8); `GateCatalogue`
  in Decision Framework order. `derivedPhase` unbound everywhere.
- **`model/ThroughputCalcs.sysml`** — 27 new calc defs (30 in all), one per criterion
  family (`IsruSupplyMarginGate`, `PktCommitmentGate`, `ReoOutputGate`,
  `MarketShareGate`, `MsrFleetGate`, `PktFspRetirementGate`,
  `MkIiiTransitionGate`, `PgmExportDriverGate`, `EarthIndependenceGate`,
  `TierDepletionGate`, …), all Boolean-returning with thresholds as inputs;
  `SpaMsrIntroductionGate` kept and documented as serving five gates.
- **`model/Parameters.sysml`** — every parameter documented as
  `owner | kind | source`; new bound (committed): `programmeStartCalendarYear`,
  `asteroidOnlineLagYears`, `pktTemporaryCommissioningCrewMax/MonthsMax`,
  `circuitReoTonnesPerYear/MassKg/PowerKw` (DF s.4 committed design),
  `psrMoleICapacityUnits = 620` + node count and units per node
  (psr_layout); new unbound with provenance: `tier1/2ResourceTonnes`,
  `reoDemandBaseline…/GrowthRate`, `spaElectricalDemandByYear`,
  `spaNonMsrCapabilityByYear`, `thoriumHydroxideStockpileByYear`,
  `reoPayloadPerCanisterTonnes` (W3-N7), `canisterEarthContentKg`,
  `mkIiiPeakFleetUnits`, `redirectTugFleetUnits`; `GateThresholds` part
  (38 attributes) instanced as `parameters.gateThresholds`.
- **`model/ProgrammeConfiguration.sysml`** — 89 phase-attribute bindings (85
  to gate outcomes, four through another element's derived phase; table in §3), nine `derivedYear` bindings on exogenous gate
  usages (asteroid captures and arrivals from `mTypeCaptureYear` …
  `+ asteroidOnlineLagYears`), `temporaryCrewHab.retiredIn = introducedIn`,
  and 21 requirement usages with `satisfy` links (SEL-REQ-001 … 016).
- **`model/ProgrammeRequirements.sysml`** — SEL-REQ-001 (subject
  `ProgrammeParameters`, checkable), 004 (subject `ZeroCarbonFlowsheet.
  usesD2ehpa`), 006 (subject `ConveyorNetwork`: `oreCatapultHubCount == 0`
  and trunk `oreTransportMode == conveyor`) made machine-checkable; new
  007 NoArmBelowRim (`abstract subject arm : Arm`, `canEnterPsr == false`),
  008 NoMoleSAtPkt, 009 HaulerPktOnly, 010 MkIiiNeverLands,
  011 MassDriverTrackBudget (ECN-020), 012 PktTemporaryCrewOnlyInP8,
  013 AsteroidProcessingAtSpa, 014 ProbesBasedAtSpa, 015 CircuitDesignCommitted
  (1.2 ≥ 1.0), 016 PsrCapacityFromLayout. 005 keeps `ProgrammeContext` (no
  L1 depot element yet). Idiom note: a subject typed by an abstract def is
  declared `abstract subject` to stay hint-free (SSM021).
- **`model/Transport.sysml`** — `OreTransportMode` enum, abstract
  `oreTransportMode` on `LogisticsLink` bound on the conveyor, hauler road
  and SKIP links; `ConveyorNetwork.oreCatapultHubCount = 0`; Wave 3 binding
  notes on MD-3 and the EM catcher.
- **`model/Processing.sysml`** — `usesD2ehpa = false` with an assert
  constraint on `ZeroCarbonFlowsheet` and `ThUSeparationStage`; `RelayDepot`
  Wave 2 TODO closed (bound to DG-POST.1 in the configuration).
- **`model/Power.sysml`** — `SpaThoriumMSR` doc: bound to DG-10.5.
- **`tools/plan_check.py`** (new) — reads the model by regex (gates,
  thresholds, parameters, phase windows, definition-level phase attributes,
  configuration bindings), loads `econ` / `verify` / `psr_layout`
  workspaces, evaluates every derivable gate (39 evaluators) and 25 element vectors, prints
  the gate register, the element register and the W3-R discrepancy register
  (W2-N table format), and fails (exit 1) on structural drift: DF ids ≠
  model ids, derivable gate without calc or evaluator, unknown calc def,
  unknown gate usage in a binding, missing threshold, PSR capacity ≠
  psr_layout. `--markdown`, `--quiet`, `--no-python`.
- **`selenite-compute/tests/test_plan_check.py`** (new) — six tests loading
  the tool by path so `pytest selenite-compute` covers it (1,449 passed).
- **`.github/workflows/validate.yml`** — `compute` job runs `plan_check.py
  --markdown plan_register.md --quiet` and uploads the register.
- **`docs/PLAN_REGISTER.md`** (new, generated) — the full register as of
  this delivery; regenerate with `python tools/plan_check.py --markdown
  docs/PLAN_REGISTER.md`.
- **`diagrams/`** — all six regenerated (`gates_view.svg` now the 81-gate
  catalogue). `tools/render_diagrams.sh` already carried `gates_view`.
- **`mapping/document_map.csv`**, **`docs/MIGRATION_PLAN.md`**,
  **`docs/CLAUDE_SYSML_CONTEXT.md`**, **`docs/DOCUMENT_FAMILIES.md`**,
  **`README.md`**, **`model/SeleniteProgramme.sysml`** — wave state,
  idioms, flag rows (F5, F7, W2-N18), W3-N pointer.

### 3. Phase-attribute classification (every phase attribute in the model)

Class: **C** consequence of a gate (bound in the configuration to that
gate's `derivedPhase`, or to another element's derived phase); **E**
exogenous (the gate's year is a `ProgrammeParameters` attribute,
`derivedYear` bound); **F** fixed by architecture or policy (left as
defined). Definition values are the document phases the definitions keep.

| Element.attribute | Def value | Class | Bound to / reason |
|---|---|---|---|
| EarthNode.existsFrom | P0 | F | origin node (DG-0.1) |
| RelayConstellation.existsFrom / builtIn | P1 / P0 | F | first deployment; DG-0.2 decides the architecture, DG-1.1 validates it |
| CrewedHub.existsFrom | P1 | C | DG-1.1 (first cargo landing) |
| CrewedHub.crewedFrom, opsHubFrom | P4 | C | DG-4.1 |
| CrewedHub.fullConfigurationFrom | P7 | F | HØW target phase |
| PsrFloor.existsFrom | P3 | F | built with the network; MOLE-I descend P3 |
| PsrFloor.contingencyCrewAccessFrom | P4 | C | DG-4.1 |
| AutonomousFactory.existsFrom | P8 | C | DG-8.1 (consequence of DG-7.1) |
| AutonomousFactory.siteConfirmedIn | P7 | C | DG-6.3 (register: Y13–14 = P6, W3-N10) |
| AutonomousFactory.temporaryCrewOnlyIn | P8 | C | DG-8.6 |
| PktRelaySatellite.existsFrom | P8 | C | DG-8.1 |
| DroStation.existsFrom | P12 | C/E | DG-12.4, `derivedYear = mTypeCaptureYear + lag` |
| ProbeScout.introducedIn | P1 | C | DG-1.1 |
| ProbeMkI.introducedIn | P3 | F | initial Earth-fuelled trio (manifest) |
| ProbeMkI.isruFuelledFrom | P4 | C | DG-4.3 (VERIFY says P3 covers it, W3-R47) |
| ProbeMkI.retiredIn | P11 | C | DG-11.6 |
| ProbeMkI.peakFleetIn | P8 | F | fleet v9 Mk I era; ECON does not separate marks |
| ProbeMkII.introducedIn, peakFleetIn | P9, P11 | F | generation change per fleet v9; ECON probe_fleet peaks Y60 (P11) |
| ProbeMkIII.introducedIn | P11 | C | DG-11.6 |
| ProbeMkIII.prospectingRoleFrom | P13 | C | DG-14.9 (register: Y115 = P12, W3-R48/49) |
| Survey.introducedIn | P1 | C | DG-1.1 |
| Survey.orbitalUnitFrom | P5 | F | fleet plan |
| MoleI.introducedIn | P3 | F | with the PSR floor; VERIFY ph.mi = 5 at P3 |
| MoleIMkI.retiredIn, retrofitToMkIIFrom | P9, P7 | F | retrofit programme (W2-N1, both readings kept) |
| MoleIMkII.introducedIn | P7 | F | W2-N1 |
| MoleIMkII.declineDrivenByMkIIIFrom | P11 | C | DG-11.6 |
| MoleS.introducedIn | P2 | F | site preparation |
| Sinter / ArmC / SentinelRover.introducedIn | P2 | F | site preparation |
| Sinter / ArmC / SentinelRover.pktFrom | P8 | C | DG-8.1 |
| ArmD.introducedIn | P3 | F | 1:1 with IZ collars (DG-11.7 rule) |
| Skip.introducedIn | P4 | C | DG-2.2 (register: Y5 = P2/P3; VERIFY nS = 1 at P4, W3-N9) |
| Skip.retiredIn | P9 | C | `massDriverNetwork.md2.operationalFrom` (DG-9.1) |
| Skip.peakFleetIn | P7 | F | Strategy s.6 (VERIFY nS = 8 at P7) |
| Dart.introducedIn | P5 | C | DG-5.1 |
| Dart.pktSiteConfirmationIn | P7 | C | DG-6.3 (W3-N10) |
| Dart.pktBasedFrom | P8 | C | DG-8.1 |
| Harvest.introducedIn | P6 | F | with the greenhouse |
| Cap.introducedIn | P4 | C | DG-4.1 (VERIFY p_cap from P6, W3-R52) |
| Cap.anchorsReservedFrom | P1 | F | reserved with the first landing |
| HaulerRevB.introducedIn | P8 | C | DG-8.1 |
| RedirectTug.introducedIn, firstCaptureIn | P11 | C/E | DG-11.8, `derivedYear = mTypeCaptureYear` |
| RedirectTug.developmentFrom | P10 | F | fleet plan (ECON tug_fleet from Y65) |
| LaserAblationTruss.introducedIn | P12 | C/E | DG-12.4 |
| DescentWinch, CableTramway, TrunkCable, RimLogisticsPoint, ClpJunction, Spine, Branch, Substation, PsrNetwork.introducedIn | P3 | F | the network is the floor node |
| CableTramway.primaryRoleUntil | P3 | F | pipeline supersedes it P4 |
| CrewWinch, CapGuideCable.introducedIn | P4 | C | DG-4.1 |
| CrewWinch.anchorsReservedFrom | P1 | F | as Cap |
| HeatedPipeline.introducedIn, dualParallelTrunkFrom | P4, P5 | F | construction sequence (PIPE-001) |
| HabitatComplex.introducedIn | P3 | F | shells printed before crew |
| HabitatComplex.crewedFrom | P4 | C | DG-4.1 |
| HabitatComplex.h3ModuleFrom | P7 | F | full configuration |
| Eclss.introducedIn | P4 | C | DG-4.2 |
| IsruPlant.introducedIn | P3 | F | first output with the floor |
| IsruPlant.selfSufficientFrom | P4 | C | DG-4.3 (VERIFY margin positive from P3, W3-R43) |
| IndustrialZone.introducedIn | P3 | F | with the PROBE trio |
| BeneficiationPlant.introducedIn | P5 | C | DG-5.2 |
| SpaLandingZone.introducedIn, padsThreeAndFourFrom | P4, P6 | F | pads precede Crew-1; ELZ-001 |
| Greenhouse.introducedIn | P6 | F | baseline (VERIFY p_hab carries the greenhouse only at P7+, W3-N17) |
| CrewReturnVehicle.introducedIn | P4 | C | DG-4.1 |
| PktTemporaryCrewHab.introducedIn | P8 | C | DG-8.6; `retiredIn = introducedIn` (SEL-REQ-012) |
| PktLandingZone.introducedIn | P8 | C | DG-8.1 |
| SolarArray.introducedIn | P3 | F | with the floor power feed |
| FissionSurfacePower.introducedIn | P4 | F | W2-N13 kept (VERIFY ecl.nfsp = 1 at P3, W3-N17) |
| EclipseBattery.introducedIn | P4 | F | W2-N13 (VERIFY ecl.bkWh = 0: FSP covers eclipse) |
| ThoriumMSR.introducedIn | P9 | C | DG-9.3 (ECON msr_count > 0 from Y38) |
| ThoriumMSR.replacesPktFspFrom | P10 | C | DG-10.4 |
| ThoriumMSR.inSituVesselsFrom | P11 | C | DG-11.4 |
| SpaThoriumMSR.introducedIn | unbound (F5) | C | DG-10.5 (ECON assumed Y105) |
| SpaThoriumMSR.asteroidProcessingUnitsFrom | P12 | F | candidate note (DG-13.4/14.4/14.7 carry the units) |
| PktFspField.introducedIn | P8 | C | DG-8.1 |
| PktFspField.retiredIn | P10 | C | DG-10.4 (ECON: MSR power ≥ FSP power at Y36; FSP floor at Y45) |
| HubChargingStation.introducedIn | P8 | C | DG-8.1 |
| SpaPowerZone.introducedIn | P3 | F | with the array |
| PktPowerSystem.introducedIn | P8 | C | DG-8.1 |
| ProcessingCircuit.introducedIn | P7 (PKT ref P8) | F | with the SPA facility; PKT reference with the spine |
| SpaProcessingFacility.introducedIn | P7 | F | ECN-015: core element, not conditional (DG-6.1 retired) |
| PktProcessingSpine.introducedIn | P8 | C | DG-8.1 (ECON ≥ 100 circuits at Y28) |
| ReagentPlant.introducedIn | P8 | C | DG-8.3 |
| Foundry.introducedIn | P8 | C | DG-8.6 (pilot commissioned by the temporary crew) |
| Foundry.atScaleFrom | P9 | C | DG-9.4 |
| RelayDepot.introducedIn | unbound | C | DG-POST.1 (Wave 2 TODO closed) |
| MTypeProcessingLine.introducedIn | P12 | C/E | DG-12.4 |
| CTypeProcessingLine.introducedIn | P12 | C/E | DG-13.3, `derivedYear = cTypeCaptureYear + lag` |
| STypeProcessingLine.introducedIn | P13 | C/E | DG-14.3, `derivedYear = sTypeCaptureYear + lag` |
| MassDriverNetwork.introducedIn | P8 | C | DG-8.0 |
| MassDriverMd1.introducedIn/operationalFrom | P8 | C | DG-8.0 |
| MassDriverMd2.introducedIn/operationalFrom | P9 | C | DG-9.1 |
| MassDriverMd3.introducedIn/operationalFrom | P10 | C | DG-9.6 (declared P9, alt P10; W2-N2) |
| MassDriverMd4.introducedIn/operationalFrom | P11 | C | DG-11.6 (MD-4 trigger never met on ECON, W3-N2) |
| MassDriverMd5.introducedIn/operationalFrom | P12 | C/E | DG-12.5 |
| EmCatcher.introducedIn/operationalFrom | P11 | C | DG-9.6 (receiver for MD-3; W2-N3, W3-R44) |
| SteelApronConveyor.introducedIn/operationalFrom | P9 | C | DG-9.7 (ECON 500 km at Y66, W3-R7) |
| ConveyorNetwork.introducedIn | P9 | C | DG-9.7 |
| ConveyorNetwork.deployingFrom | P10 | C | DG-10.2 |
| HaulerRoadNetwork.introducedIn/operationalFrom | P8 | C | DG-8.1 |
| SkipHopLink.introducedIn/operationalFrom | P4 | C | DG-2.2 |
| SkipHopLink.retiredIn | P9 | C | `md2.operationalFrom` |
| StarshipCargoLink.introducedIn/operationalFrom | P1 | C | DG-1.1 |
| StarshipCargoLink.pktDeliveriesFrom | P8 | C | DG-8.1 |
| StarshipReturnLink.introducedIn/operationalFrom | P5 | C | DG-5.4 |
| StarshipReturnLink.retiredIn | derived | C | `md4.operationalFrom` (Wave 2) — never retires on the current ECON PGM vector (W3-N2) |
| MassDriverDemonstrator.introducedIn | P7 | F | final report Fig. 27 rim test track; DG-8.8's PKT demonstrator conflicts (W3-N11) — not bound |
| ProbeReturnLink.introducedIn/operationalFrom | P3 | F | with Mk I |
| ProbeReturnLink.mkIiiCanisterStreamFrom | P11 | C | DG-11.6 |
| PsrAccessLink.introducedIn/operationalFrom | P3 | F | with the floor |
| EarthOpsHubTier.introducedIn | P0 | F | exists before launch |
| EarthOpsHubTier.directSupervisionOfSpaUntil | P3 | F | mirror of SentinelEdgeTier.supervisedFromSpaFrom |
| SentinelEdgeTier.introducedIn, SentinelSystem.introducedIn | P2 | F | with the first rovers |
| SentinelEdgeTier.supervisedFromEarthUntil | P3 | F | mirror of the next row |
| SentinelEdgeTier.supervisedFromSpaFrom | P4 | C | DG-4.1 |
| SentinelEdgeTier.pktSupervisedFromSpaFrom | P8 | C | DG-8.1 |
| FleetTier.introducedIn | P1 | F | with the first vehicles |
| CryoValveMonitoringFunction, MoleINavigation, MoleIFlightSoftware, SubstationController.introducedIn | P3 | F | with their hardware |
| O2SupplyLineMonitoringFunction.introducedIn | P4 | C | DG-4.2 |

### 4. Register — what the derived plan says (plan_check, 15 Sep 2026)

Full tables in `docs/PLAN_REGISTER.md`. Headline findings (recorded, not
resolved; every one is a register row):

1. **The economics' REO ramp is one knot later than the Decision Framework's
   REO gates** (W3-N4): 100 kt/yr at Y80 not Y60 (DG-11.1), 500 kt/yr at
   Y121 not Y80 (DG-12.1 — the same document's P12 end-state says ~Y120),
   1.25 Mt/yr at Y152 not Y120 (DG-13.1). Only the 2.5 Mt/yr endpoint
   (DG-14.8, Y180) agrees. Strategy v3.1 s.15.1 agrees with ECON at P12.
2. **Two gates are never met on the current vectors**: DG-11.6's MD-4
   trigger (PGM concentrate > 100 t/yr; ECON `total_pgm` peaks near 52 t/yr)
   and DG-14.6 (Earth mass < 0.5 %; the annual-flow proxy bottoms at 4.8 %
   at Y139), plus DG-13.7 (hauler Earth fraction 20 % floor; ECON reaches
   0.33). Because `StarshipReturnLink.retiredIn = md4.operationalFrom`, the
   derived plan **never retires the SPA→Earth Starship returns** unless the
   PGM vector, the threshold or the trigger definition changes (W3-N2).
3. **The Mk III transition is not forced by PSR capacity** on the layout's
   620 positions (ECON MOLE-I peak 357 at Y35); on the fleet v9 figure of 310
   it would be forced at Y31 (P8). The transition therefore rests on the
   DG-11.6 test outcome, not on the capacity comparison (W2-N18, W3-R18).
4. **Infrastructure scaling gates run late against ECON**: 14,881 haulers at
   Y64 not Y45 (DG-10.1, VC-08), 5,000 km conveyor at Y84 not Y48
   (DG-10.2), the 500 km pilot at Y66 not Y40 (DG-9.7), ~74 MSR at Y67 not
   Y50 (DG-10.4), ~679 MSR at Y96 not Y65 (DG-11.2), ~6,890 MSR at Y173 not
   Y85 (DG-12.2, VC-09), 783 canisters/day at Y141 not Y85 (DG-12.3).
5. **Year-table drift** is now mechanical: every P13/P14-listed gate whose
   year falls in P12/P13 by `ProgrammeTimeline` is a row (DG-13.5, 13.6,
   14.1, 14.2, 14.5, 14.9; the W2-N7 family) and DG-7.5's Y15 sits in the
   F7 gap (W3-N15).
6. **Element-level**: SKIP (definition P4) is bound to a P2/P3 clearance
   gate (W3-N9); the DART site confirmation (P7) to a P6 gate (W3-N10); the
   EM catcher (P11) to MD-3's Y43 gate (W2-N3); ISRU self-sufficiency and
   PROBE ISRU fuelling (P4) have positive VERIFY margins from P3; CAP standby
   power appears at P6 in VERIFY (definition P4); the SPA MSR's economics
   assumption is Y105 (F5).
7. **Unevaluated derivable gates** (vectors to add at Wave 5): DG-8.7
   (thorium stockpile), DG-10.5 / 11.3 / 13.4 / 14.4 / 14.7 (SPA demand
   beyond P7), DG-POST.1/2 (tier resource, ECON beyond Y200).

Proxy caveats stated in the calcs: DG-9.4 / DG-10.3 use ECON `insitu_total`
(in-situ manufactured mass, which starts with the first in-situ circuit
fraction at Y28, before any foundry) and DG-14.6 an annual-flow ratio, not a
cumulative infrastructure-mass audit.

### 5. Observations W3-N1 … W3-N20 (recorded in model docs; none resolved)

| # | Observation | Where |
|---|---|---|
| W3-N1 | DG-14.6 target (<0.5 % Earth mass) is not met in any year to Y200 on the ECON annual-flow proxy (minimum 4.8 % at Y139). | `Gates.sysml`, register |
| W3-N2 | DG-11.6 MD-4 trigger (PGM > 100 t/yr) never met on ECON `total_pgm` (peak ~52 t/yr) → MD-4 never operational → `StarshipReturnLink` never retires; Mk III not forced by the 620-position PSR capacity (peak need 357), forced at Y31 with 310. | `Gates.sysml`, `ProgrammeConfiguration.sysml` |
| W3-N3 | DG-8.5 "308 circuits; 125 t/yr" mixes designs: 308 × 0.4 (batch) ≈ 123 t/yr; the committed 1.2 t/yr circuit needs 105 (ECON `circuits_needed` at Y28). | `Gates.sysml`, `Parameters.sysml` |
| W3-N4 | Decision Framework REO gate years (DG-11.1 Y60, DG-12.1 Y80, DG-13.1 Y120) are one knot earlier than ECON `reo_target` (Y80 / Y121 / Y152); DG-12.1 also contradicts the document's own P12 end-state (~500 kt at ~Y120). | `Gates.sysml`, register |
| W3-N5 | DG-13.7 hauler Earth-fraction floor 20 % never reached: ECON floors at 0.43 less a 0.10 M-type bonus (0.33). F3 lineage. | `Gates.sysml`, `Parameters.sysml` |
| W3-N6 | DG-12.3 "783/day" is the stale 1.0 Mt/yr cadence per ECN-020 s.4 (corrected ~1,903/day); Rev D gate text not updated. Threshold carried as written. | `Parameters.sysml` |
| W3-N7 | REO canister payload: ECN-020 3.6 t vs ECON `can.reo_payload_t` 3.5 t (714,286 vs 694,444 canisters/yr). Candidate VC-22. | `Parameters.sysml` |
| W3-N8 | ECON derives `regolith_yr` and haulers from `reo_target / 500 ppm` irrespective of site, so haulers exist from Y20 for SPA's research output; thresholds (≥ 10 / ≥ 50) hide the artefact. | `Gates.sysml` DG-8.4, plan_check |
| W3-N9 | SKIP first hop: DG-2.2 Y5 (M70) and Strategy s.6 "P3 (M70+) 1 SKIP" vs model P4 (fleet v9; VERIFY `ph.nS` = 0 at P3, 1 at P4). | `Gates.sysml`, register |
| W3-N10 | PKT grade confirmation: DG-6.3 Y13–14 (P6) vs baseline "DART confirms PKT site (Y22)" (P7; `Dart.pktSiteConfirmationIn`, `AutonomousFactory.siteConfirmedIn`). | `Gates.sysml`, register |
| W3-N11 | Mass-driver demonstrator: DG-8.8 / Strategy s.7.2 place a 23 t, 500 m/s demonstrator at PKT in Y28–30; the model's `MassDriverDemonstrator` is on the SPA rim at P7 (final report Fig. 27, W2-N17). Not bound. | `Gates.sysml`, `ProgrammeConfiguration.sysml` |
| W3-N12 | ECON `cargo_ybco` ships 30 + 30 (Y22–23), 50 (Y35), 30 (Y43) = 140 t: pre-ECN-020 (523 t) and no MD-4 / MD-5 line. Recorded on DG-8.0 / 9.1 / 9.6 as `econYbcoCargoYears`. | `Gates.sysml` |
| W3-N13 | Milestones M0–M8: final report Fig. 2 not in the repository; `MilestoneSet` is a proxy from Decision Framework s.1 with `confirmedAgainstFigure2 = false`. Jason to confirm or correct against the figure. | `Gates.sysml` |
| W3-N14 | Strategy v3.1 numbers the Earth-independence gate DG-14.3 in s.16 and DG-14.6 in s.15.1; fleet v9 App. C uses DG-14.3. Rev D numbering carried, alias on `DgFourteenSix.formerGateId`. | `Gates.sysml` |
| W3-N15 | DG-7.5 "~2040" = Y15 lies in the F7 gap (P6 ends Y15, P7 starts Y18) while the document lists it under P7; also M4 "P7 (Y15)" in the s.1 table. | `Gates.sysml`, `Phases.sysml` |
| W3-N16 | Year-table drift for P13/P14-listed gates: DG-13.5 (Y110), 13.6 (Y115), 14.1 (Y95), 14.2 (Y115), 14.9 (Y115) are P12 and DG-14.5 (Y130) is P13 by `ProgrammeTimeline` — the W2-N7 family, now mechanical in the register. | register |
| W3-N17 | VERIFY v5.0 element vectors vs definitions: FSP from P3 (`ecl.nfsp` = 1,2,3,4,5) vs P4 (W2-N13); CAP standby power from P6 (`ph.p_cap`) vs P4; greenhouse power only at P7+ (`ph.p_hab` = `with_GH` at index P7+) vs P6; ISRU covers PROBE and total demand from P3 (`ph.isru` ≥ `ph.dP`, `ph.dT`) vs P4; eclipse battery `ecl.bkWh` = 0 in every phase. | register, `Power.sysml` |
| W3-N18 | `launchCostPerFlightUsd` is per flight; ECON v1.3 `launch_cost` is $/kg (6,000 / 4,000 / 2,000 by era). Left unbound with both noted. | `Parameters.sysml` |
| W3-N19 | DG-6.1 is retired by ECN-015 (processing is core, not conditional): `SpaProcessingFacility.introducedIn` classified fixed, not bound. | `Gates.sysml` |
| W3-N20 | "82 gates" = 81 unique Rev D ids + the Rev A DG-10.3 canister-recovery decision inside DG-9.1. | `Gates.sysml` |

### 6. Flags and Wave 2 items touched

| Flag / item | This wave |
|---|---|
| F1 | Confirmed at kick-off; catalogue built from Rev D; no s.2 gate differs from Rev C. |
| F3 | Hauler in-situ fraction: DG-10.1 text "~57 % in-situ", DG-13.7 20 % floor never reached on ECON (W3-N5). No fraction bound. |
| F4 / VC-07 | ECON MOLE-I peak 357 at Y35 is the input to `MkIiiTransitionGate` (DG-11.6). |
| F5 | `SpaThoriumMSR.introducedIn` bound to DG-10.5 `derivedPhase`; the five commissioning gates share `SpaMsrIntroductionGate`; unevaluated (no SPA demand vector beyond P7); ECON assumption Y105 printed. |
| F6 | ECN-020 numbering in DG-9.6 (MD-3) and DG-11.6 (MD-4). |
| F7 | DG-7.5 (Y15) lies in the gap (W3-N15); `ProgrammeTimeline` unchanged. |
| F9 | Final report date still unknown; Fig. 2 milestones a proxy (W3-N13). |
| W2-N1 | MOLE-I Mk I/II retrofit phases classified fixed (both readings kept). |
| W2-N2 | MD-3 bound to DG-9.6 (declared P9, alt P10). |
| W2-N3 | EM catcher bound to DG-9.6 (register W3-R44/45). |
| W2-N4 | CAP bound to DG-4.1; VERIFY p_cap from P6 (W3-N17). |
| W2-N7 | Years authoritative — now the register's year-phase column (W3-N16). |
| W2-N11 | DG-7.5 → DG-8.9 cold structure chain models the conditional P8 prototype. |
| W2-N13 | FSP P4 kept fixed; VERIFY nfsp = 1 at P3 recorded (W3-N17). |
| W2-N15 | `StarshipReturnLink` introduced by DG-5.4; retirement via MD-4 never occurs on current ECON (W3-N2). |
| W2-N17 | Demonstrator conflict with DG-8.8 (W3-N11). |
| W2-N18 | Resolved by rule: 620 positions bound from `psr_layout.py`; SEL-REQ-016. |
| W2-N19 | DG-13.2 carried with alternate phase P12. |
| W2-N20 | Five SPA MSR gates modelled, one calc. |
| VC-08, VC-09, VC-10 | The document series appear as gate thresholds (14,881 haulers; 6,890 MSR; 15,000 km) and the register shows the ECON years. |
| VC-20, VC-21 | Unchanged (parameters unbound; CATAPULT Rev C outstanding). |

### 7. Validation

`sysml-validate model --workspace . --all` (0.36.0): **15 files checked, no
problems found** — exit 0, zero hints. `tools/render_diagrams.sh`
(sysml-diagram 0.42.0): six SVGs. `pytest selenite-compute`: **1,449 passed,
33 skipped** (1,443 + 6 plan_check tests). `tools/plan_check.py`: exit 0,
all structural checks passed, 55 register rows.

### 8. Map updates

`mapping/document_map.csv`: Decision Framework v4 → `gated`; Strategy v3.1
→ `gated`; ECN-019 row → `gated` (requirements via Strategy; file not in
repo); ECN-020 note (SEL-REQ-011); VERIFY / ECON / VISUALIZE rows note
`plan_check` consumption.

### 9. Open for Jason

1. Confirm or correct M0–M8 against `SEL_FINAL_REPORT_v4` Fig. 2 (W3-N13).
2. The MD-4 trigger as written (PGM > 100 t/yr) is never met on the current
   economics; decide whether the threshold, the PGM model or the trigger
   definition is the ECN (W3-N2).
3. The SPA demand vector beyond P7 (F5 evaluation) and the thorium stockpile
   vector are the two Python additions that would evaluate the remaining
   derivable gates.

## Addendum — 18 September 2026 (final report in repo; milestones settled; MD-4 trigger)

- **Merged main** (PR #6: `docs/SEL_FINAL_REPORT_v4.md` and 64 figure pages)
  into the Wave 3 branch; `document_map.csv` conflict resolved (Strategy row
  `gated`, final report row now the `.md` transcription).
- **W3-N13 closed.** `SeleniteGates::MilestoneSet` rebuilt from
  `docs/W5_T4_4_JS_milestone_reference.html` ("Programme Milestones (from
  MTL v8.5)"): M0 Relay Network Live M20/Y2, M1 First PROBE Landing M36/Y3,
  M2 First SINTER Print M54/Y5, M3 Crew-1 M82/Y7, M4 First SKIP Hop M70/Y6,
  M5 Beneficiation Online M105/Y9, M6 First Export M116/Y10, M7 Crew
  Rotation M136/Y11.5, M8 First DART PKT M130/Y11. Final report Fig. 2
  (`docs/final_report_figures/page-05.jpg`) agrees on every diamond it draws
  (it omits M5). `Milestone` gains `declaredMonth`; `confirmedAgainstFigure2`
  is now true. The Decision Framework s.1 proxy is gone.
- **W3-N21 (new).** Three milestone years differ from the Decision Framework
  gate years for the same events: M4 SKIP hop Y6 vs DG-2.2 Y5; M8 DART PKT
  Y11 vs DG-5.1 Y9; M7 crew rotation Y11.5 vs DG-6.4 Y12 (also M5 Y9 vs
  DG-5.2 Y10, a ceiling-of-month artefact). Recorded on the milestones, not
  resolved.
- **Sources added to `docs/`:** `selenite_extended_timeline_v3_revised.html`
  (family winner, P7–P14+), `W5_T4_4_JS_milestone_reference.html`,
  `W5_T4_4_JS_scaling_P7_P14.html`, `W5_T4_3_JS_fleet_specs_summary.html`.
  Notable while reading them: the scaling page labels the SPA→Earth driver
  "MD-3" (F6 stale label) and the extended timeline labels Earth independence
  "DG-14.3" (W3-N14 family); the scaling page also carries "~417k circuits" at
  P12 against 2,083,334 on the extended timeline (VC-09 family).
- **MD-4 trigger (W3-N2) — decision proposal, awaiting Jason.** The 100 t/yr
  PGM trigger was set from iridium demand (PEM electrolysers, 34+ t/yr by
  2040), not from the programme's own PGM production, which the Decision
  Framework itself puts at 36.5 t/yr from the M-type capture plus ~15 t/yr
  from the Mk III fleet: the trigger is unreachable under the documents as
  written, not only under ECON. Proposed ECN: bind MD-4 to the M-type
  arrival (DG-12.4, Y85) or lower `GateThresholds.pgmExportTriggerTonnesPerYear`
  to a value the plan reaches (30 t/yr crosses at Y85 on ECON `total_pgm`);
  either makes MD-4 a P12 element and retires the Starship returns at Y85.
  Not applied.

## Addendum — 19 September 2026 (ECN: MD-4 bound to the M-type arrival)

Decision (Jason, 19 Sep 2026): the SPA→Earth mass driver MD-4 is a
consequence of DG-12.4 (M-type asteroid arrives in DRO, Y85), not of the
DG-11.6 PGM-volume trigger, which the programme's own production (36.5 t/yr
M-type + ~15 t/yr Mk III) never reaches. Applied: `massDriverNetwork.md4`
re-bound to `gates.dgTwelveFour.derivedPhase` in the configuration; DG-11.6
and DG-12.4 gated-element lists and docs updated; MD-4 definition keeps the
document's P11 with a pointer. `PgmExportDriverGate` stays on DG-11.6 so the
register keeps reporting the trigger against ECON `total_pgm`. Consequence
through the Wave 2 chain: `StarshipReturnLink.retiredIn` now derives from the
M-type arrival (register row W3-R for MD-4: definition P11, bound to DG-12.4
P12/Y85). W3-N2 closed as a decision; the Decision Framework s.3 MD-4 row
("P11 (Y70)") and DG-11.6 text are now superseded by this ECN and should be
updated at the next Rev.

## Addendum — 19 September 2026 (extension vectors for the unevaluated gates)

`selenite-compute/selenite/plan_vectors.py` (NOT a port, no golden,
`PORTED = False`; goldens untouched): `spa_power()` extends SPA electrical
demand beyond P7 by scaling VERIFY v5.0's P7 per-unit loads (MOLE-I tether
and node overhead, ISRU per MOLE-I, IZ per chemical PROBE, habitat with
greenhouse, other base loads, 20 % contingency) with the ECON fleet vectors,
optionally adding the Decision Framework s.10.1 asteroid-processing loads;
`thorium_stockpile(ratio)` is cumulative ECON `reo_target` times a Th:REO
mass ratio, with the DG-11.2-implied bounds 0.0039–0.0077 as constants. Two
new unbound parameters: `spaNonMsrCapabilityCeilingKw` (no source states
the solar + FSP + battery ceiling) and `thoriumToReoMassRatio`. plan_check
now reports DG-8.7 at both ratio bounds and the SPA demand trajectory for the
five F5 gates; both stay "unevaluated" until the parameters are bound, by
design. Four tests in `tests/test_plan_vectors.py`. DG-POST.1/2 remain
unevaluated (tier resource tonnages have no source).

## Addendum — 19 September 2026 (ECNs: thorium ratio bound; SPA MSR as an FSP-versus-MSR trade)

- **Thorium (Jason, 19 Sep 2026).** `thoriumGradePpm = 12.5` (range 10–15,
  fleet v9 s.11; Lunar Prospector GRS Fra Mauro / Apollo 14 soils 12–13 ppm,
  Lawrence et al. 2000, 2003; KREEP basalt ~15 ppm), `acidBakeThoriumCapture
  = 0.92` (range 0.90–0.95, DG-7.2), `processingReeGradePpm = 500` (Decision
  Framework Rev D), Th(OH)4/Th 1.293; `thoriumToReoMassRatio` is now a
  derived expression (~0.030 t/t). **W3-N22 (new):** this is about four
  times the 0.004–0.008 the Decision Framework's DG-11.2 figures imply, so
  its 387–773 t/yr Th production at P11 understates its own ore grades.
  plan_check evaluates DG-8.7 at the nominal and both range corners
  (`plan_vectors.thorium_ratio`).
- **SPA MSR (Jason, 19 Sep 2026): "when demand builds beyond what it is worth
  bringing more FSP units for, the MSR becomes worth it."** Modelled as
  VERIFY sizes SPA power: solar carries the day load, FSP + battery the
  eclipse-critical loads. `plan_vectors.spa_critical_power` scales VERIFY's
  ecl.* budget (MOLE-I keep-alive and node overhead per ECON MOLE-I; pipeline
  heating, habitat, SENTINEL, farm ZBO, misc at P7); `fsp_msr_trade`
  compares the Earth mass of the FSP fleet that load needs (40 kW, 6,600 kg
  each) with one SPA MSR (50,000 kg × ECON earth_frac(y)), and the gate is
  justified when the FSP fleet is dearer *and* ThCl4 is available (MD-3,
  DG-9.6 Y43). The unbound `spaNonMsrCapabilityCeilingKw` is withdrawn
  (illuminated area is not the constraint: a tenth of the 17.5 km² Gläser
  2018 site at VERIFY's 0.32 kW/m² is ~560 MW); replaced by
  `spaEclipseCriticalCoverageOnly = true`, `spaMsrFirstUnitRatedKw = 50000`
  and the one open assumption `spaAsteroidLoadCriticalFraction` (unbound;
  plan_check reports 0 and 1). Result: the eclipse-critical load stays at
  120–146 kW (pipeline heating dominates), four FSP units cover it
  throughout, and the MSR wins on Earth mass only once Ni-201 in-situ
  vessels cut its Earth fraction — the register row gives the year. Jason's
  hypothesis (later phases, not P10) is what the numbers show.
