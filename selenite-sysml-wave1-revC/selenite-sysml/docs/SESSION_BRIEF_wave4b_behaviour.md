# Session Brief — Wave 4B: Behaviour, interfaces and software

> **Status: drafted 6 Nov 2026, not started.** Starts once the post-Wave-4A
> verification session (`docs/SESSION_BRIEF_verification_post_wave4a.md`) is
> merged and its `CHANGELOG_VERIFICATION.md` open-items list exists. This is
> the original Wave 4 scope of `docs/MIGRATION_PLAN.md`; Wave 5 (quantities
> bound from the Python layer, the derived timeline) follows it.

Paste into a fresh Claude Code session on `JScri/selenite_sysmlv2`, branch
from `main`. Model folder `selenite-sysml-wave1-revC/selenite-sysml/`, Python
layer `selenite-compute/`. If the verification session raised ECNs Jason has
not yet decided, the first message says so and the session carries them as
recorded, not applied.

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
(SEL-ECN-024 onward) for Jason. Conflicts recorded, not resolved. Goldens,
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
