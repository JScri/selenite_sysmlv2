# Session Brief — Verification of the model after Wave 4B (before Wave 5)

> **Status: drafted 7 Nov 2026, not started.** Scope: one session. This is
> an *audit*, not a build. It verifies the model as it stands on `main`
> after Waves 1–3, the Python port, Wave 4A (SEL-ECN-023), the post-4A
> verification (SEL-ECN-024 … 026) and **Wave 4B with its same-day addendum
> (PR #13, merged 7 Nov 2026; SEL-ECN-027 signed and applied)**. It is the
> gate before **Wave 5** (`docs/SESSION_BRIEF_wave5_quantities.md`:
> quantities bound from the Python layer, `derivedPhase` bound, the derived
> timeline). A **Wave 6** now exists in `docs/MIGRATION_PLAN.md` — the
> control behaviour the twelve primary sources describe beyond Wave 4B's
> build steps (`CHANGELOG_WAVE4B.md` §9.8) — and this session must keep it
> in view: anything that belongs to Wave 6 is recorded for Wave 6, not
> modelled here. Findings are numbered observations (V2-N1 …); fixes that
> change no value are applied; anything that changes a committed value, a
> threshold, a selection or a decision is a draft ECN (SEL-ECN-028 onward)
> for Jason, never applied.

Paste into a fresh Claude Code session on `JScri/selenite_sysmlv2`, branch
from `main`. Model folder `selenite-sysml-wave1-revC/selenite-sysml/`, Python
layer `selenite-compute/`. First commit: set this banner to "started
<date>".

## Start-up (mandatory, in order)

1. `npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0` (both pinned);
   `tools/validate.sh` → 18 files, exit 0, zero hints;
   `python3 tools/connect_check.py` → 806 endpoints, 0 unresolved;
   `pip install -e "./selenite-compute[test]"`; `pytest selenite-compute` →
   1,565 passed, 33 skipped; `python3 tools/plan_check.py --quiet` → exit 0
   and the default output byte-identical to
   `selenite-compute/tests/fixtures/plan_check_stdout_wave3.txt` (94
   element bindings); `python3 tools/scenario_check.py --n 200 --quiet` →
   exit 0; `tools/render_diagrams.sh` → 32 SVGs. Nothing below starts until
   all are clean. Use absolute paths in every shell call — the working
   directory does not persist between calls in the cloud session.
2. Read, in this order: `docs/CLAUDE_SYSML_CONTEXT.md` (all of it — rules
   3, 5a–5d, the §4 idioms incl. the Wave 4B interface / behaviour / state
   idioms, the §7 validator quirks, §8 state), `docs/MIGRATION_PLAN.md`
   (Waves 4B delivered, 5 next, **6 planned**), `docs/ARCHITECTURE_BASELINE.md`,
   `docs/DOCUMENT_FAMILIES.md` (precedence, "Primary sources in the
   repository", flags), `docs/VALUE_CONFLICTS.md`, `CHANGELOG_VERIFICATION.md`
   (§4 open items — the state Wave 4B started from), `CHANGELOG_WAVE4B.md`
   in full (§0–§8 delivery; **§9 addendum: §9.2 what the sources changed,
   §9.4 W4B-N18 … N28, §9.5 the adversarial verification and its
   reversals, §9.8 the Wave 6 backlog, §9.9 Jason's decisions**),
   `docs/SEL-ECN-027_draft_ByProductOxygenStorePolicy.md` (signed),
   `docs/SESSION_BRIEF_wave4b_behaviour.md` (rules the wave worked to),
   `docs/SESSION_BRIEF_wave5_quantities.md` (what Wave 5 expects to find),
   `docs/PLAN_REGISTER.md`, `docs/SCENARIO_REGISTER.md`,
   `mapping/document_map.csv` (110 + 1 rows).
3. Know the primary sources are now in the repository: originals under
   `docs/sources/`, markdown extracts in `docs/` named after the docx
   (`docs/SEL-SW-SENTINEL-001_RevB.md` …), `docs/selenite_value_chain_v14_1
   / v15 / v16.html`, `docs/ECN-019_Programme_Wide_Design_Revision.md`
   (Rev C, PROPOSED), `docs/SEL-ECON-001_RevA_revised.md`. The docx is the
   source of record; cite section numbers from the extract.

## What to verify (each item: method, then pass or finding)

1. **Model integrity, as before.** One package per file, flat `model/`,
   alphabetised private imports, every definition with a `doc` naming its
   source and revision (W4B-N17: 41 definitions in `Gates.sysml`,
   `Scenarios.sysml`, `ThroughputCalcs.sysml` and `ProgrammeParameters`
   were still unsourced at Wave 4B — count them now and cite them where the
   source is obvious), no SSM021 idiom violations (`abstract attribute` for
   unbound enum-typed values), no stale "not in the repository" or TODO
   that names a file now in `docs/` (grep with line-wrap tolerance). Look at
   every SVG in `diagrams/` for orphans and duplicates, including the ten
   state-transition and seven action-flow views.
2. **Interfaces and connections (new).** Every `port` in `model/` is typed
   by `SeleniteInterfaces`; every `connect` is an `interface` usage with a
   definition whose flow direction matches the port conjugation; every
   boundary port of a usage is delegated with `bind`; `connect_check.py`
   resolves every endpoint (it exists because the validator accepts
   unresolved feature chains silently — W4B-N2). Check the three places the
   addendum re-typed: `TetherPort.fix` (the polar fix is computed on the
   substation — ECN-013 §3.2), `ConstructionRadioPort` (position reports,
   power status, gate requests; no encoder), `DrumSensingPort`.
3. **Behaviour mirrors the documents (new, the core of this audit).** For
   every state machine and action flow in `model/Software.sysml` (and the
   `exhibit` / `perform` in `RobotFleet`, `PsrNetwork`, `Habitat`,
   `ProgrammeConfiguration`): each transition's trigger and guard is either
   quoted from a named section of a document in `docs/` or declared
   UNBOUND with the sources read named as silent. The addendum's
   adversarial verification (`CHANGELOG_WAVE4B.md` §9.5) already reversed
   seven bindings; re-verify the ones it left bound and the ones it did not
   cover: the seven `SeleniteBehaviour` streams and their 40 step defs
   against value chain v14.1 / v15 / v16 and fleet v9; `SupervisionLocation`
   (gate-id triggers DG-4.1, DG-8.1); `CryoValveStationStates` transitions
   #201–#206 against ISRU-001 Rev D §7.4 and fleet v9 §9.2;
   `CapMissionStates` after its ingress rework; `TetherPortStates` after
   the branch-connector correction (W4B-N25). Invented control logic is a
   finding; a bound trigger the source gives differently is a finding; an
   UNBOUND trigger the source actually gives is a finding. Do not bind
   anything that belongs to the Wave 6 backlog — record it under Wave 6.
4. **Rule 3 (no quantities typed from documents).** Grep every attribute
   value in `model/` (`= <number>`) and trace each to the Python layer or a
   cited parameter; the addendum removed one breach (`o2LineIndependentBarriers
   = 4`) — look for others of the same shape (counts, fractions, hours typed
   into Boolean-looking facts). The W4B-N6 list of document constants left
   UNBOUND (ECN-014 thresholds, `preHeatTankFraction`, `tankFullFraction`,
   `purgeHoldMinutes`, `cellTargetDepthMm`, `noContactThresholdHours`,
   `floorWorkLimitHours`, `ByProductOxygenStore.storageCapacity`) must still
   be unbound; confirm, and confirm the Wave 5 brief names each.
5. **Provenance of every bound value** in `model/Parameters.sysml`
   (`ProgrammeParameters`, `GateThresholds` after SEL-ECN-026) against the
   cited sources, as in the post-4A audit; the Low / High twins per rule 5d.
6. **Gate catalogue, configuration bindings, requirements.** All 81 gate
   ids once; the ten-gate hand spot-check against
   `docs/SELENITE_DECISION_FRAMEWORK_v4.md`; every `derivedPhase` binding
   to an existing gate; the derived chains (`StarshipReturnLink.retiredIn`,
   `l1OxygenDepot.existsFrom = md2.operationalFrom` — W4B-N27 records that
   ECON §8.4 puts the depot at P14+ / DG-14.4; it is Wave 5's to settle,
   record only); SEL-REQ-001 … 018 each with a subject, a `satisfy` and a
   machine-checkable constraint where claimed — in particular SEL-REQ-017
   on the three asteroid lines and SEL-REQ-018 on both oxygen stores
   (SEL-ECN-027); every `assert constraint` evaluates true on the bound
   values.
7. **Python layer and scenario layer**, as in the post-4A audit: goldens
   compare all rows with the declared skips; `econ_param.v1_3(Params())`
   bit-identical to `econ._v1_3()`; `plan_check` byte-identical; scenario
   register deterministic at `--n 2000 --seed 20260920`, robust at
   `--seed 1`, `--method sobol` runs. Wave 4B changed no Python; confirm the
   diff of `selenite-compute/` since `0a2794e` is the fixture re-cut only.
8. **Registers versus documents.** Every W2-N, W3-N, W4A-N, V-N and
   **W4B-N1 … N28** observation and every VC row: still true, resolved, or
   superseded (by SEL-ECN-027 for W4B-N4 / N18 / N27; the SENTINEL P2
   decision for W4B-N8 / N19). Check the addendum's own claims in
   `CHANGELOG_WAVE4B.md` §9.2 against the model as merged — the section was
   written across three commits and the verification reversed some of
   what it first said; any sentence that no longer matches the model is a
   finding. Produce the consolidated open-items list for Wave 5 and Wave 6.
9. **Document map, families and sources.** Every file in `docs/`,
   `docs/sources/` and `mapping/` has a map row with the right status
   (`behaviour_modelled`, `folded`, `superseded`, `applied` …); every docx
   under `docs/sources/` has its extract and the extract's headings match
   the docx; the families table's winners match what the model cites;
   `UPLOAD_LEDGER.csv` and `DOCUMENT_FAMILIES.csv` still agree with the
   map. The two superseded copies kept (SENTINEL design Rev A+, CAP-001
   Rev A) are not cited anywhere.
10. **Wave 6 scope check.** Read `CHANGELOG_WAVE4B.md` §9.8 against the
    sources and the model: is each backlog item (a) truly absent from the
    model, (b) truly in the source it names, and (c) behaviour (states,
    transitions, sequences, interlocks, authority rules) rather than a Wave
    5 quantity? Correct the list where it is wrong, add what the critic
    missed, and leave the result as the Wave 6 starting list in
    `docs/MIGRATION_PLAN.md`. Do not model any of it.

## Rules

Goldens, `econ.py`, `verify.py`, `thermal.py`, `psr_layout.py` and their
tests untouched. Fixes that change no value (a wrong citation, a stale
status, a missing `satisfy`, a doc sentence the model no longer matches) may
be applied with a changelog entry (`CHANGELOG_VERIFICATION_4B.md`, ECN
style, V2-N numbering); anything that would change a bound value, a
threshold, a selection, a decision or a trigger the documents do not give is
a draft ECN (SEL-ECN-028 onward), never applied. Behaviour mirrors the
documents; no control logic invented; conflicts recorded, not resolved.
Nothing from the Wave 6 backlog is modelled. ECN-021 stays out. Novel stays
out. Australian spelling. Flat `model/`. Validate to exit 0, zero hints;
`connect_check` 0 unresolved; `plan_check --quiet` byte-identical to the
fixture unless a value-neutral fix changes a register row (then regenerate
`docs/PLAN_REGISTER.md`, re-cut the fixture in the same commit, list the
rows); `scenario_check --quiet` exit 0; `pytest` green; diagrams
regenerated. Commit on the designated branch, open a PR, do not merge.

## Done when

- `CHANGELOG_VERIFICATION_4B.md` lists every item above as pass or finding
  (V2-N1 …) with the method used, the fixes applied, the ECN drafts raised,
  and the consolidated open-items lists for **Wave 5** and **Wave 6**.
- `docs/SESSION_BRIEF_wave5_quantities.md` §0 amended with what moved;
  `docs/MIGRATION_PLAN.md` Wave 6 entry carries the checked backlog;
  `docs/CLAUDE_SYSML_CONTEXT.md` §8 states the verified-after-4B state;
  this brief's banner set to "delivered <date>".
- All checks clean; PR open; nothing merged by the session.
