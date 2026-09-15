# Session Brief — Wave 3: Gates and the derived programme plan

> **Status: delivered 15 Sep 2026** — see `CHANGELOG_WAVE3.md` ("Wave 3 delivery") and `docs/PLAN_REGISTER.md`.

**Scope:** one session (two if the Decision Framework is long). Turn the
phase skeleton of Wave 2 into a plan that is *derived* from declared inputs
and gate criteria rather than transcribed from documents. Paste into a fresh
Claude Code session on the repository; the model folder is
`selenite-sysml-wave1-revC/selenite-sysml/`.

**The Python port has landed (PR #3, 14 Sep 2026).** `selenite-compute/` is
the computational authority: `pip install -e "selenite-compute[test]"`, then
`from selenite import econ, verify, thermal, psr_layout` and call
`econ.workspace()` (year vectors `reo_target`, `circuits_needed`,
`msr_count`, `cargo_spa_msr`, `supply_frac` …, indexed Y0..Y200),
`verify.workspace()["ph"]` (per-phase fleet/power), `psr_layout.workspace()`
(`n_total` = 124 nodes for W2-N18). `pytest selenite-compute` must stay
green (1,443 passed, 33 declared skips). Read
`selenite-compute/CHANGELOG_PORT.md` for what the port revealed before
quoting any economics figure.

## Start-up (mandatory, in order)
1. `npm install -g sysml-validate@0.36.0 sysml-diagram`; `tools/validate.sh` → exit 0, zero hints.
2. Read `docs/CLAUDE_SYSML_CONTEXT.md` (rules 5a/5b/5c), `docs/MIGRATION_PLAN.md`
   (Wave 3 section), `docs/DOCUMENT_FAMILIES.md` (flags + W2-N1…N18),
   `CHANGELOG_WAVE2.md`, `CHANGELOG_WAVE3.md` (kick-off + addenda), then `model/Gates.sysml`, `model/Parameters.sysml`,
   `model/ThroughputCalcs.sysml` (`SpaMsrIntroductionGate`).
3. Sources are in `docs/`: `SELENITE_DECISION_FRAMEWORK_v4.md` (SEL-DECISION-001 Rev D,
   82 gates DG-0.1…DG-14.9 + DG-POST.1/2, with years), `SELENITE_DECISION_FRAMEWORK_v3_historical.md`
   (Rev C, kept for the diff record), `SEL-T1_1-STRATEGY-v3_1.md`. Fourteen gates are
   already in `Gates.sysml`; the rest are this wave's first job.

## Build (validate after each step)
1. **Gate catalogue.** From the Decision Framework: every DG-x.y and DG-POST.x
   as a `DecisionGate` in `Gates.sysml` — `gateId`, `criterion` (verbatim),
   `evaluability` (derivable / testOutcome / exogenous), `declaredPhase`,
   `prerequisites`, `gatedElements`. Resolve the DG-14.3 / DG-14.6 and DG-7.5
   questions. Leave `derivedPhase` unbound. Add milestones M0–M8 (final report
   Fig. 2) as a `Milestone` def with declared years.
2. **Criteria as constraints.** Where a criterion is a comparison on quantities,
   write it as a `calc def` in `SeleniteAnalysis` (pattern: `SpaMsrIntroductionGate`)
   and reference it from the gate. Where it is a test outcome, add a
   `assumedOutcome : Boolean` attribute defaulting to true with a doc — the plan
   is conditional on declared assumptions and says so.
3. **Rebind every phase attribute.** For each `introducedIn` / `retiredIn` /
   `operationalFrom` in the model decide: (a) consequence of a gate → bind the
   attribute in `ProgrammeConfiguration.sysml` to the gate outcome the way
   `StarshipReturnLink.retiredIn = massDriverNetwork.md4.operationalFrom` is
   bound, keeping the definition-level document value as `declaredPhase`
   candidate; (b) exogenous → reference the `ProgrammeParameters` attribute;
   (c) genuinely fixed by architecture (e.g. relay constellation P1) → leave.
   Record the classification in a table in `CHANGELOG_WAVE3.md`.
4. **Parameters.** Complete `SeleniteParameters` from the Decision Framework
   and Strategy (owner, kind, provenance). Bind only committed decisions.
   Rule W2-N18: PSR MOLE-I capacity comes from `psr_layout.py`, not a document.
5. **Requirements.** SEL-REQ-0xx from ECN-019 Rev C, ECN-020, Strategy v3.1
   with concrete subjects and `satisfy` links; make "no ARM below the rim",
   "no catapult for ore", "no D2EHPA" machine-checkable (the constraints exist
   in `RobotFleet.sysml`; wire them to requirements).
6. **`tools/plan_check.py`.** Reads the model (regex over `.sysml` is enough
   for `declaredPhase` / `derivedPhase` / `introducedIn`) and the Python
   layer (`selenite.econ.workspace()` etc.); evaluates every `derivable`
   gate criterion against the year vectors and prints the derived-vs-declared
   register in the W2-N table format. Wire into the `compute` CI job.
7. Diagrams: add a `gates_view` (gv of `Gates.sysml`) to `tools/render_diagrams.sh`.
8. `mapping/document_map.csv` statuses; `CHANGELOG_WAVE3.md` in ECN style.

## Rules
- No values from documents into attributes except committed decisions in
  `SeleniteParameters` (each one an ECN to change).
- Conflicts recorded, not resolved; a gate with two declared phases carries both.
- ECN-021 stays out. Novel stays out. Australian spelling. Flat `model/`.
- Phase-typed attributes use the Wave 2 idiom (abstract attribute + `redefines` binding).
- Validate to exit 0, zero hints, before delivery. Commit on the designated branch, open a PR.

## Done when
Every gate in the Decision Framework is a `DecisionGate` with criterion and
evaluability; every phase attribute in the model is classified (consequence /
exogenous / fixed) and the consequences are bound to gates; `plan_check.py`
prints the register; validation exit 0; five diagrams plus `gates_view`;
`CHANGELOG_WAVE3.md` lists every F-flag and W2-N item touched.
