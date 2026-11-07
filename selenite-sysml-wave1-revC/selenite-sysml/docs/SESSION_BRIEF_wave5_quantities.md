# Session Brief — Wave 5: Quantities, parametrics and the first derived timeline

> **Status: drafted 7 Nov 2026 at the end of Wave 4B (`CHANGELOG_WAVE4B.md`,
> PR open), not started.** This is the Wave 5 of `docs/MIGRATION_PLAN.md`:
> every quantity the model needs is bound from the Python layer
> (`selenite-compute/`), never typed from a document; `derivedPhase` is bound
> for every gate the planner evaluates; the phase year windows become
> outputs; the derived-versus-document register replaces the hand-kept lists;
> the Decision Framework Rev E and Strategy v3.2 are rendered from the model.
> It starts from `CHANGELOG_VERIFICATION.md` §4 "Wave 5 must start from" and
> `CHANGELOG_WAVE4B.md` §6 / §8.

Paste into a fresh Claude Code session on `JScri/selenite_sysmlv2`, branch
from `main`. Model folder `selenite-sysml-wave1-revC/selenite-sysml/`, Python
layer `selenite-compute/`. First commit: set this banner to "started
<date>".

## 0. What Wave 4B left for this wave (7 Nov 2026)

- **Counts at start-up.** 18 model files; `tools/validate.sh` exit 0, zero
  hints; `tools/connect_check.py` 796 endpoints resolved; `pytest
  selenite-compute` 1,565 passed, 33 skipped; `plan_check --quiet` exit 0
  with 94 element bindings and the default output byte-identical to
  `selenite-compute/tests/fixtures/plan_check_stdout_wave3.txt` (re-cut 7 Nov
  2026; unchanged by the addendum); `scenario_check --n 200 --quiet` exit 0;
  32 diagrams.
- **Unbound by design, for this wave to bind:** every `ratedPower`,
  `dryMass`, `peakPower`, `throughputTonnesPerYear` and
  `holdLoadFraction.nominal`; the ECN-014 monitor thresholds and timings
  (`ValveStationMonitor`, `O2SupplyLineMonitoringFunction` — **W4B-N6**:
  these are document constants with no Python source, so this wave needs a
  rule for them: a `DocumentConstants` block in `Parameters.sysml` with the
  citation per value, or an ECN that makes them committed parameters);
  `NavigationFusion.fusionRateHz`; the MOLE-I `preHeatTankFraction`,
  `tankFullFraction` and `purgeHoldMinutes` (ECN-012 §3.3.2: 90 %, full, 3
  min); `SentinelSystem.noContactThresholdHours` (SW-SENTINEL §12.2: 24 hr);
  `Cap.floorWorkLimitHours` (CAP-001 §2: 2 h design target) — all document
  constants under the W4B-N6 rule; the
  `EclipseGatedPowerSupply` interface attributes once `holdLoadFraction` has
  a source (W4A-N3); the stream quantities (masses, rates per phase) on the
  `SeleniteBehaviour` action parameters, from `econ.workspace()` and
  `verify` vectors.
- **Elements this wave may re-source:** `L1OxygenDepot` and the MD-2 O2 loft
  (W4B-N4 / W4B-N18 — no repository document names them, and ECN-019 Rev C,
  now in `docs/`, gives MD-2 the single purpose "REO canisters"; Jason's
  call whether SEL-REQ-005 stands);
  `SpaPgmHydromet` (W4B-N5, bound to DG-5.4 from Decision Framework s.10.1 /
  s.3.2 and M6); the SENTINEL first phase (W4B-N8); the SPA P7 Th(OH)4
  destination before MD-1 (W4B-N9).
- **Transitions with unbound triggers (W4B-N7) — mostly closed by the
  addendum.** The Wave 4B winners are in `docs/` since 7 Nov 2026 and the
  triggers they give are bound (`CHANGELOG_WAVE4B.md` §9). Two stay unbound
  because the sources are silent: the SENTINEL mode transitions
  `toLocalAi` / `backToPlan` (W4B-N21 — the documents carry an authority
  model, not a mode table; a Wave 5 option is to retire the three-mode
  machine in favour of `AuthorityLevel`) and the MOLE-I `offsetOnResistance` drill-resistance offset (W4B-N22,
  re-stated after verification: the cell-complete depth rule of NAV-001
  §3.2 is bound). W4B-N18 (ECN-019 Rev C names no L1 O2 depot)
  and W4B-N19 / N20 (SENTINEL first phase, value-chain conflicts) are
  questions for Jason, not bindings.
- **`prerequisites` / `gatedElements` promotion (W4B-N12)** is this wave's
  call: if promoted, use one `connection` usage per edge with `attribute
  kind : PrerequisiteKind` (`direct | via | partial | chained`) so DG-7.1
  "via", DG-3.2 "partial" and the DG-9.1 / DG-12.4 chains through `md2` /
  `md4.operationalFrom` keep their meaning, update
  `selenite.scenarios.modelio.parse_gates` to read the links, and keep the
  plan register byte-identical by a test before and after.
- **A stream register (W4B-N15)** is optional: the performed streams bind
  their phase to their performer with `:>>` and plan_check does not list
  them; a `--streams` table would show each stream's performer-derived phase
  beside its definition phase.

## Start-up (mandatory, in order)

1. `npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0` (pinned,
   W4A-N2); `tools/validate.sh` → exit 0, zero hints; `python
   tools/connect_check.py` → 0 unresolved; `pip install -e
   "./selenite-compute[test]"`; `pytest selenite-compute` → 1,565 passed, 33
   skipped; `python tools/plan_check.py --quiet` → exit 0; `python
   tools/scenario_check.py --n 200 --quiet` → exit 0. Nothing starts until
   all are clean.
2. Read, in order: `docs/CLAUDE_SYSML_CONTEXT.md` (rules 3, 5a–5d, §4
   idioms incl. the Wave 4B ones), `docs/MIGRATION_PLAN.md`,
   `docs/ARCHITECTURE_BASELINE.md`, `CHANGELOG_VERIFICATION.md` §4,
   `CHANGELOG_WAVE4B.md` (§1, §6, §8), `CHANGELOG_WAVE4A.md` §5 and the
   addenda, `CHANGELOG_WAVE3.md` §3 (the phase-attribute classification),
   `docs/SEL-ECN-022_DecisionFramework_Wave3.md`, `docs/SEL-ECN-023 …`
   (signed), `docs/SEL-ECN-024 …`, `025 …`, `026 …` (signed),
   `docs/VALUE_CONFLICTS.md`, `docs/PLAN_REGISTER.md`,
   `docs/SCENARIO_REGISTER.md`; then `model/Parameters.sysml`,
   `model/ThroughputCalcs.sysml`, `model/Gates.sysml`,
   `model/ProgrammeConfiguration.sysml`, `model/Behaviour.sysml`,
   `model/Interfaces.sysml`; `selenite/econ.py`, `selenite/verify.py`,
   `selenite/plan_vectors.py`, `selenite/scenarios/` (all), `tools/plan_check.py`
   (`EVALUATORS`, `ELEMENT_VECTORS`), `selenite-compute/CHANGELOG_PORT.md`.

## Build (validate after each step; bind from Python, never from a document)

1. **Bind `derivedPhase`.** For the 94 bindings in the configuration, the
   planner (`tools/plan_check.py` → a `selenite.plan` module) binds each
   gate usage's `derivedPhase` (and `derivedYear` where unbound) from its
   evaluator at the nominal inputs; the W2-N1/2/3/4, W3-N9/10 and W3-R42–56
   definition-versus-gate rows become derived outputs of the register, not
   hand-kept notes. The SPA MSR owner is settled (SEL-ECN-025 → DG-13.4).
   Rewrite `SeleniteAnalysis::SpaMsrIntroductionGate` to mirror
   `plan_vectors.fsp_msr_trade` (V-N24). Decide the `declaredPhaseAlternate`
   rule (V-N30: store the year-implied phase for DG-13.5 / 13.6 / 14.5 /
   14.9 or compute it for DG-13.4 / 14.4 too). Bind
   `UncertaintyRegister.parameters` to `seleniteProgramme.parameters` (V-N10)
   before any quantity is read through it.
2. **Quantities from the Python layer.** A `selenite.bind` module (or an
   extension of `modelio`) produces a `model/Quantities.sysml` package —
   `SeleniteQuantities` — of value bindings generated from
   `econ.workspace()`, `verify.workspace()`, `psr_layout.workspace()` and
   `plan_vectors`: per-phase fleet counts, masses, powers, throughputs,
   economics, on the existing attributes (`ratedPower`, `dryMass`,
   `peakPower`, `circuitCountAtP14` → the vector, `msrUnitCountAtP14`,
   `throughputTonnesPerYear`, the stream parameters). Generated, never
   hand-typed; a checker asserts model == Python within tolerance in
   `pytest`. The phase year windows in `Phases.sysml` become outputs of the
   derived timeline. The Wave 4A gate-year distributions feed the bound
   phases as probabilities beside the point values (`plan_check
   --with-scenarios`).
3. **Document constants (W4B-N6).** Decide and apply the rule for values
   that have a document but no computation (the ECN-014 thresholds and
   timings, NAV-001 rates and accuracies, the ECN-012 pre-heat fraction, the
   canister payload 3.6 t of ECN-020): a `DocumentConstants` part in
   `Parameters.sysml` with `source` per attribute, bound by the generator
   from a hand-maintained citation table, or committed by ECN. Then bind the
   monitors' thresholds and the `EclipseGatedPowerSupply` attributes.
4. **The unbound Python-supplied inputs**: `reoTonnesPerYearByYear`,
   `reoDemandBaseline…`, `spaElectricalDemandByYear`,
   `spaNonMsrCapabilityByYear`, `thoriumHydroxideStockpileByYear`,
   `mkIiiPeakFleetUnits`, `redirectTugFleetUnits`, `canisterEarthContentKg`,
   `reoPayloadPerCanisterTonnes`, `co2PerLaunchTonnes`,
   `launchCostPerFlightUsd` (W3-N18 basis); the capture-year ranges (W4A-N5);
   the test-outcome probabilities (W4A-N4). DG-POST.1/2:
   `tier1ResourceTonnes` / `tier2ResourceTonnes` (ECON stops at Y200 — extend
   or declare). The never-met gates DG-14.6 (needs a cumulative
   infrastructure-mass vector) and DG-13.7 (hauler floor 0.33 vs 0.20; F3
   closed by ECN-024, the threshold stands — Jason's D8 decision first).
5. **VC adjudications by ECN + new golden**: VC-01…14, 18, 19, 20, 22
   (VC-09 carried in `msrUnitsP12` / `msrUnitCountAtP14` = 6,890,
   `circuitCountAtP14` 2.08 M; VC-20 `co2PerLaunchTonnes`); VC-03 / VC-11
   model doc records (V-N39); the ECON items — `cargo_ybco` 140 t pre-ECN-020
   (W3-N12), the hauler artefact (W3-N8), the lost-throughput gearing
   (W4A-N6), the eclipse count (W4A-N7), VERIFY vectors vs definition phases
   (W3-N17), F4 / VC-07 MOLE-I profile, F8 AUD masses and powers (VC-04).
   Each is a draft ECN (SEL-ECN-027 onward) with the golden change it needs;
   none applied without Jason's signature; `econ.py`, `verify.py`,
   `thermal.py`, `psr_layout.py` and the goldens untouched until then.
6. **Renderings.** Decision Framework Rev E (ECN-022 §3 and §5, ECN-023 §5,
   ECN-026): the MD-4 row, DG-11.2 thorium figures (W3-N22), DG-10.5 / 11.3
   superseded, milestone alignment (W3-N21), 310 → 620, 308 / 783 / the
   DG-14.3 alias / DG-7.5 placement / P12–P13 re-sectioning / REO gate years
   / YBCO 280 → 523, DG-13.2 double use (W2-N19); Strategy v3.2 and fleet v9
   follow-ons; the timeline figures rendered from the model. Rendered from
   the registers, not hand-written.
7. **Diagrams, docs.** Views for `Quantities.sysml`, Parameters, Phases and
   ThroughputCalcs (the three V-N9 files Wave 4B left); `CHANGELOG_WAVE5.md`
   in ECN style with W5-N observations; `mapping/document_map.csv` rows
   (`planned` → `python_port` / `applied` / `generated` as each lands);
   `docs/MIGRATION_PLAN.md` and `docs/CLAUDE_SYSML_CONTEXT.md` §8 updated.

## Rules

Rule 3 is the wave: no quantitative value is typed from a document; every
bound value is generated from the Python layer or committed by a signed ECN
with its golden. Rule 5d holds for every uncertain input. No committed
parameter rebound, no decision changed without a signed ECN (SEL-ECN-027
onward). Conflicts recorded, not resolved. Goldens, `econ.py`, `verify.py`,
`thermal.py`, `psr_layout.py` and their tests untouched unless an ECN is
signed; `plan_check` default output byte-identical unless a binding or gated
element moves (then regenerate the register, re-cut the fixture in the same
commit and list the rows); `scenario_check` byte-identical at n = 2,000
unless `Scenarios.sysml` or `Parameters.sysml` changes (say so if a sampled
entry is added or dropped). sysml-validate 0.36.0 and sysml-diagram 0.42.0
pinned (W4A-N2). Australian spelling. Flat `model/`. Validate to exit 0,
zero hints; `connect_check` 0 unresolved; `plan_check` and `scenario_check`
exit 0; `pytest` green; diagrams regenerated. Commit on the designated
branch, open a PR, do not merge.

## Open questions for Jason (carried; answer in the session or leave recorded)

The eight of `CHANGELOG_VERIFICATION.md` §4 "Needs Jason's decision now"
(default criterion; `spaMsrAvailabilityProbability`; hold-load 0.25 and
restart loss 0.5 day; VC-22 3.5 vs 3.6 t; W3-N4 REO ramp; D8 hauler policy;
D7 / D3; W3-N11 / F7 / F9 / F2 / W4A-N1 / VC-21 / DG-2.1 / V-N37 / V-N38),
plus from Wave 4B: W4B-N4 (the L1 O2 depot's source), W4B-N8 (SENTINEL's
first phase), W4B-N6 (the document-constants rule), and whether the missing
Wave 4B winners can be added to `docs/`.

## Done when

- Every derivable gate has `derivedPhase` bound from the planner; the
  register's definition-versus-gate rows are outputs; `SpaMsrIntroductionGate`
  mirrors `fsp_msr_trade`; `UncertaintyRegister.parameters` is the programme
  instance.
- `model/Quantities.sysml` is generated from the Python layer and a test
  asserts model == Python within tolerance; no attribute in the model
  carries a hand-typed document quantity except through the document-
  constants rule, cited.
- The VC and ECON items are draft ECNs with their goldens; Rev E and
  Strategy v3.2 are rendered from the registers; `CHANGELOG_WAVE5.md`, the
  map and the plans are updated; PR open.
