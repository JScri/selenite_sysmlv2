# Session Brief — Wave 4B: Behaviour, interfaces and software

> **Status: started 7 Nov 2026 (amended 7 Nov 2026 after the verification
> session merged, PR #12 / 4e78eee).** This is the original Wave 4 scope of
> `docs/MIGRATION_PLAN.md`; Wave 5 (quantities bound from the Python layer,
> the derived timeline) follows it. The verification's `CHANGELOG_VERIFICATION.md`
> records V-N1 … V-N46 and the consolidated open-items list in its §4;
> SEL-ECN-024, 025 and 026 were signed (option 2a each) and applied in the
> same PR. The amendments in §0 below carry what moved since the brief was
> drafted; the build steps, rules and done-when are unchanged.

Paste into a fresh Claude Code session on `JScri/selenite_sysmlv2`, branch
from `main`. Model folder `selenite-sysml-wave1-revC/selenite-sysml/`, Python
layer `selenite-compute/`. First commit: set this banner to "started
<date>".

## 0. Amendments after the verification session (7 Nov 2026)

- **Start-up counts.** `pytest selenite-compute` is 1,565 passed, 33 skipped.
  `plan_check --quiet` and `scenario_check --n 200 --quiet` exit 0. The
  plan_check default output is byte-identical to
  `selenite-compute/tests/fixtures/plan_check_stdout_wave3.txt` (re-cut on
  7 Nov 2026 after ECN-026); `docs/PLAN_REGISTER.md` has 55 W3-R rows.
- **Reading list additions**, after `CHANGELOG_VERIFICATION.md`: the three
  signed ECNs `docs/SEL-ECN-024_draft_HaulerInSituFractionCandidates.md`
  (flag F3 closed; the hauler floor a point at the ECON 0.43),
  `docs/SEL-ECN-025_draft_SpaMsrUnitOneBinding.md` (SPA MSR unit #1 bound to
  DG-13.4), `docs/SEL-ECN-026_draft_RevDThresholdsCarriedVerbatim.md`
  (DG-12.3 1,903/day, DG-8.5 105 circuits). They keep their draft file names
  for the document map; their status lines say SIGNED.
- **ECN numbering.** Anything that would change a bound value, threshold,
  selection or decision is a draft ECN from **SEL-ECN-027** onward, never
  applied.
- **Decisions still open for Jason** (carry as recorded, do not resolve):
  the D8 hauler policy (after ECN-024 the register recommends `targetFloor`,
  the DG-13.7 20 % floor, over the baseline's `econFloor`; the selection
  `d8 :> econFloor` stands); the default decision criterion
  (`decisionCriterion` PROPOSED); `spaMsrAvailabilityProbability` 1.0; the
  hold-load fractions 0.25 and restart loss 0.5 day (W4A-N3; SEL-REQ-017
  cites them as declared assumptions); VC-22 canister payload 3.5 vs 3.6 t;
  the W3-N4 REO ramp; D7; D3. `CHANGELOG_VERIFICATION.md` §4 "Needs Jason's
  decision now" is the list.
- **Verification carry-overs that belong to this wave**
  (`CHANGELOG_VERIFICATION.md` §4 "Wave 4B must start from"), in addition
  to build steps 1–7:
  (a) SEL-REQ-017 is build step 5; `AsteroidProcessStep.pausableThroughEclipse`
  already exists on the C/S-type steps — make the constraint read it.
  (b) SEL-REQ-005 keeps `ProgrammeContext` until an L1 / EML-2 O₂ depot
  element exists — add the element in step 1 (the O₂ stream to MD-2) and
  rebind the subject.
  (c) Gated elements that do not exist and carry "TODO Wave 4" strings in
  `Gates.sysml`: the SPA reagent pilot / production (DG-5.3, DG-7.4), the
  PKT oxalic-acid line (DG-9.5), the SEL-CON-001 MOLE-I bayonet connector
  (document_map row now `4B, planned`) — create them or re-mark the TODOs
  with the source needed.
  (d) The ECN-014 literals in `Software.sysml` and `Habitat.sysml` (valve
  stations 4, monitors 4, preconditions 4, table 11, patterns 201–206) cite
  a document that is not in `docs/` (V-N19): bring SEL-SW-SENTINEL-001
  Rev B's ECN-014 extract into `docs/` with a document_map row, or state
  that it cannot be and keep the TODO.
  (e) Hygiene: about 44 definitions carry a doc with no named source and
  12 name a source without a revision (V-N3) — cite as you touch those
  files; `Milestone` is a concrete part def holding an abstract attribute
  (V-N8) — make it abstract or record why not; the ten model files without
  a view (V-N9) get views where this wave adds behaviour; the "App. C"
  citations in `Phases.sysml` (×3), `docs/ARCHITECTURE_BASELINE.md` and
  `docs/DOCUMENT_FAMILIES.md` read fleet v9 s.20.3 (V-N27: the markdown
  authority has no appendix); the "Wave 4" placeholders in
  `Software.sysml`, `Processing.sysml` and `Gates.sysml` are re-labelled
  4B as you reach them.
  (f) `prerequisites` and `gatedElements` are strings today ("Wave 4 may
  promote them"): if you promote them to semantic links, keep the designed
  indirect cases (DG-7.1 "via", the DG-9.1 / DG-12.4 chained retirements
  through `md2` / `md4.operationalFrom`, DG-3.2 "partial") and say how in
  the changelog.
  (g) Decide where `SEL_EVA_CONTINGENCY_CORRECTED.docx` (map row wave 4,
  `planned`, named in no brief) is consumed — this wave or Wave 5.
- **Conventions made explicit at verification** (`docs/CLAUDE_SYSML_CONTEXT.md`
  §8): cite the fleet authority `SEL_ROBOT_FLEET_v9.md` by section (s.20.3,
  not "App. C"); `mapping/DOCUMENT_FAMILIES.csv` and `UPLOAD_LEDGER.csv` are
  hand-maintained since the F2 correction and repo-authored records are
  indexed in `document_map.csv` only; the document_map status vocabulary is
  the list in `docs/MIGRATION_PLAN.md` — add `behaviour_modelled` to that
  sentence when you first use it.
- **plan_check byte-identity.** The DEFAULT output does not change unless
  this wave adds or moves a phase binding or a gated element; if it does (a
  new phase-gated element bound to a gate, or a promoted `gatedElements`
  link that plan_check reads through `selenite/scenarios/modelio.py`),
  regenerate `docs/PLAN_REGISTER.md`, re-cut the fixture in the same commit
  and list the changed rows in `CHANGELOG_WAVE4B.md`.
  `docs/SCENARIO_REGISTER.md` is regenerated only if `Scenarios.sysml` or
  `Parameters.sysml` change (n = 2,000, seed 20260920, about five minutes;
  CI runs n = 500) — dropping or adding a sampled entry re-draws the common
  random numbers, which moves every mean by a few hundred tonnes; say so if
  it happens.
- **Diagrams.** `sysml-diagram` 0.42.0 is pinned (0.54.0 rejects the
  gate-binding idiom, W4A-N2). Use the views it supports for the new
  packages (gv for `Behaviour.sysml` / `Interfaces.sysml` at least); if it
  has no action-flow or state view, say so in the changelog rather than
  skipping the view silently.
- **Step 7's Wave 5 brief** (`docs/SESSION_BRIEF_wave5_quantities.md`)
  starts from `CHANGELOG_VERIFICATION.md` §4 "Wave 5 must start from": bind
  `derivedPhase` for the 89 bindings, rewrite `SpaMsrIntroductionGate` to
  mirror `plan_vectors.fsp_msr_trade` (V-N24), bind
  `UncertaintyRegister.parameters` to the programme instance (V-N10), the
  `declaredPhaseAlternate` rule (V-N30), DG-POST.1/2 tier tonnages, the
  never-met gates DG-14.6 and DG-13.7, the VC adjudications, the Rev E
  rendering, the unbound Python-supplied inputs, and the ECON items by ECN
  plus new golden.

## Start-up (mandatory, in order)

1. `npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0` (pinned,
   W4A-N2); `tools/validate.sh` → exit 0, zero hints; `pip install -e
   "./selenite-compute[test]"`; `pytest selenite-compute` green (count as at
   the end of the verification session); `python tools/plan_check.py --quiet`
   → exit 0; `python tools/scenario_check.py --n 200 --quiet` → exit 0.
2. Read, in order: `docs/CLAUDE_SYSML_CONTEXT.md` (all rules, 5a–5d),
   `docs/MIGRATION_PLAN.md`, `docs/ARCHITECTURE_BASELINE.md`,
   `CHANGELOG_VERIFICATION.md` (open items), `CHANGELOG_WAVE4A.md`,
   `docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md` (signed),
   `docs/DOCUMENT_FAMILIES.md` (flags and W-N observations),
   `model/Software.sysml`, `model/Habitat.sysml`, `model/Processing.sysml`,
   `model/Transport.sysml`, `model/RobotFleet.sysml`; then the sources for
   this wave: the value-chain family (v14.1 P0–P7, v15 P7–P12, v16 P13+),
   SEL-SW-SENTINEL-001 Rev B (ECN-014 folded in), SEL-SW-MOLEI-001 Rev D,
   SEL-SW-SUB-001 Rev C, SEL-NAV-001 Rev A, SEL-CON-001 Rev B, the ISRU-001
   Rev D valve-station amendment (ECN-014). Documents not in `docs/` are
   located through `mapping/UPLOAD_LEDGER.csv` and the
   `DOCUMENT_FAMILIES.csv` winners; if a winner is not in the repository,
   say so and model what the repo documents support, with a `TODO` naming
   the file.

## Build (validate after each step; structure before quantities, rule 5a)

1. **Value-chain behaviour.** Action defs and action flows for the material
   streams by phase: PSR ice → ISRU propellant; KREEP → beneficiation →
   SPA/PKT circuits → REO canisters → MD-2 → Earth; thorium → ThCl₄ → MSR;
   the asteroid streams M/C/S at SPA. Every flow's items typed, allocated to
   the parts that perform them, phase-gated like everything else. No
   throughput numbers (Wave 5).
2. **Ports and interfaces.** Replace the bare ports of Wave 2 with typed
   port defs and interface defs (power bus, propellant, water, ore, reagent,
   canister, data/supervision); every `connect` in
   `ProgrammeConfiguration.sysml` goes through an interface; the SPA power
   zone's eclipse behaviour (ECN-023: duty cycle, hold loads) as an
   interface constraint on the asteroid lines.
3. **SENTINEL states and modes.** A state def for the supervision tiers
   (Earth → SPA Ops Hub → PKT at 0.5 s), fault patterns #201–#206 as
   transitions, the ECN-014 cryo-valve auto-close as a state machine with the
   hardwired 24 VDC dead-man fail-closed logic as asserted constraints
   (`Software.sysml`, `Habitat.sysml`).
4. **NAV-001.** The MOLE-I three-layer navigation fusion as a behaviour (an
   action flow with the sensor inputs and the estimate output), allocated to
   the MOLE-I software; the ECN-013 UHF construction link where the
   navigation behaviour depends on it.
5. **ECN-023 requirement.** SEL-REQ-017 "asteroid processing pausable
   through eclipse; plant oversized for the dark fraction and restart
   losses; hold loads only through eclipse", subject the asteroid lines,
   `satisfy` links in the configuration, machine-checkable on
   `pausableThroughEclipse`.
6. **Out of scope, recorded not modelled.** The Th/U separation stage (waits
   on the preprint — `ThUSeparationStage` stays OPEN); ECN-021 (enters only
   when PROC-PKT-001 Rev C, PROC-001 Rev C, ISRU-001 Rev E, MTL Guide v19
   and Strategy v3.2 exist — VC-15/16/17 stand).
7. **Diagrams, docs.** Action-flow, state and interface views added to
   `tools/render_diagrams.sh`; `CHANGELOG_WAVE4B.md` in ECN style with
   W4B-N observations; `mapping/document_map.csv` rows (the Software / NAV /
   CON rows `skeleton` → `behaviour_modelled`); `docs/MIGRATION_PLAN.md` and
   `docs/CLAUDE_SYSML_CONTEXT.md` §8 updated; a Wave 5 brief drafted at the
   end (`docs/SESSION_BRIEF_wave5_quantities.md`).

## Rules

No quantitative values from documents into attributes (rule 3; Wave 5 binds
them from the Python layer). Behaviour mirrors the documents, it does not
invent control logic: where a document is silent, leave the transition or
guard unbound with a `doc` naming the source needed. No committed parameter
rebound, no decision changed — anything of that kind is a draft ECN
(SEL-ECN-027 onward) for Jason. Conflicts recorded, not resolved. Goldens,
`econ.py`, `verify.py`, `thermal.py`, `psr_layout.py` and their tests
untouched; `plan_check` default output byte-identical. Australian spelling.
Flat `model/` (new files only where a new top-level package needs one, e.g.
`Behaviour.sysml`, `Interfaces.sysml`). Validate to exit 0, zero hints;
`plan_check` and `scenario_check` exit 0; `pytest` green; diagrams
regenerated. Commit on the designated branch, open a PR, do not merge.

## Done when

- Every element of the value chain has a typed flow; every `connect` goes
  through an interface; SENTINEL and the valve auto-close are state machines
  with asserted constraints; NAV-001 fusion is a behaviour; SEL-REQ-017
  exists and is satisfied.
- `CHANGELOG_WAVE4B.md`, the document map and the plans are updated; the
  Wave 5 brief is drafted; PR open.
