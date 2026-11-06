# Session Brief — Verification of the model after Wave 4A

> **Status: delivered 6 Nov 2026** — see `CHANGELOG_VERIFICATION.md` (V-N observations, value-neutral fixes, SEL-ECN-024 and 025 signed, SEL-ECN-026 draft, open items for Waves 4B and 5). Scope: one session. This is an
> *audit*, not a build. It verifies the model as it stands after Waves 1–3,
> the Python port and Wave 4A (SEL-ECN-023 signed). It is not the final
> verification: **Wave 4B** (behaviour, interfaces, software — the original
> Wave 4 scope in `docs/MIGRATION_PLAN.md`) and **Wave 5** (quantities bound
> from the Python layer, the derived timeline, `derivedPhase` bound) are still
> ahead. Findings are recorded as numbered observations (V-N1 …) and, where a
> fix is unambiguous and value-neutral, applied; anything that changes a
> committed value or a decision is an ECN draft for Jason.

Paste into a fresh Claude Code session on `JScri/selenite_sysmlv2`, branch
from `main`. Model folder `selenite-sysml-wave1-revC/selenite-sysml/`, Python
layer `selenite-compute/`.

## Start-up (mandatory, in order)

1. `npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0` (the diagram
   CLI is pinned — W4A-N2); `tools/validate.sh` → exit 0, zero hints;
   `pip install -e "./selenite-compute[test]"`; `pytest selenite-compute` →
   1,565 passed, 33 skipped; `python tools/plan_check.py --quiet` → exit 0;
   `python tools/scenario_check.py --n 200 --quiet` → exit 0. Nothing below
   starts until all are clean.
2. Read, in this order: `docs/CLAUDE_SYSML_CONTEXT.md` (all of it, rules 3,
   5a–5d), `docs/MIGRATION_PLAN.md`, `docs/ARCHITECTURE_BASELINE.md`,
   `docs/DOCUMENT_FAMILIES.md` (flags F1–F10, W2-N, W3-N, W4A-N),
   `docs/VALUE_CONFLICTS.md`, `CHANGELOG_WAVE2.md`, `CHANGELOG_WAVE3.md`
   (delivery, addenda, close-out), `CHANGELOG_WAVE4A.md`,
   `docs/SEL-ECN-022_DecisionFramework_Wave3.md`,
   `docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md` (signed),
   `docs/PLAN_REGISTER.md`, `docs/SCENARIO_REGISTER.md`,
   `selenite-compute/CHANGELOG_PORT.md`.

## What to verify (each item: method, then finding or pass)

1. **Model integrity.** Every `.sysml` file: one package per file, flat
   `model/`, `private import` alphabetised, every definition with a `doc`
   citing source + revision, no shadowed library names, no `SSM021` idiom
   violations (`abstract attribute` + `redefines` for enum-typed values).
   Cross-check `mapping/document_map.csv` status against what the model
   actually contains (a row marked `architected` whose elements are absent
   is a finding). Render every view in `tools/render_diagrams.sh` and look at
   the SVGs for orphan or duplicated elements.
2. **Provenance audit.** For every bound value in `model/Parameters.sysml`
   (`ProgrammeParameters` and `GateThresholds`) open the cited source in
   `docs/` and confirm the number; list every value whose citation does not
   support it. Do the same for the Low/High twins the Wave 4A register
   samples (rule 5d: no range without an existing pair or a cited source).
3. **Rule-3 audit (no independently derived quantities).** Every numeric
   literal in a `calc def` or a model attribute must be transcribed from the
   Python layer or a cited document; grep the model for literals and trace
   each. `spaAsteroidLoadCriticalFraction = 0.18` is derived (ECN-023) —
   confirm the derivation reproduces from `tools/scenario_check.py`.
4. **Gate catalogue versus Decision Framework Rev D.** All 81 gate ids
   present once (plan_check structural checks), criterion text verbatim
   modulo the stated transliteration, declared phases and years as the
   document lists them, prerequisites and gated elements consistent with the
   configuration bindings. Spot-check ten gates by hand against
   `docs/SELENITE_DECISION_FRAMEWORK_v4.md`.
5. **Configuration bindings.** Every `attribute redefines x = gates.y.derivedPhase`
   binds to an existing gate usage; every element whose phase is a
   consequence is bound (compare with the CHANGELOG_WAVE3 §3 classification
   table); `temporaryCrewHab.retiredIn = introducedIn` and the Wave 2 chain
   (`StarshipReturnLink.retiredIn = md4.operationalFrom`) still hold.
6. **Requirements.** SEL-REQ-001..016: each has a subject, a `satisfy` link
   in the configuration, and its constraint is machine-checkable where the
   changelog says so. Confirm the asserted constraints evaluate true on the
   bound values (D2EHPA, PSR capacity product, track budget, circuit design).
7. **Python layer.** The goldens are the oracle: confirm `tests/test_goldens.py`
   still compares all 1,437 rows and that the 33 skips are the declared ones;
   `econ_param.v1_3(Params())` equals `econ._v1_3()` bit-for-bit (the test
   uses rtol 1e-9 — check exact equality too); `plan_check` default output
   byte-identical (fixture); `plan_vectors` and `scenarios` carry
   `PORTED = False` and name every assumption as a constant.
8. **Scenario layer.** Re-run `scenario_check.py --n 2000 --seed 20260920`
   and diff against the committed `docs/SCENARIO_REGISTER.md` (must be
   identical — determinism); re-run with `--seed 1` and confirm no
   recommendation changes (robustness); run `--method sobol`; check every
   register entry's "sampled / point" status against its Parameters.sysml
   doc; check the D1 two-world table and the break-even by hand from the
   printed means.
9. **Registers versus documents.** Every W2-N, W3-N, W4A-N observation and
   every VC row: still true, resolved, or superseded by an ECN? Produce the
   consolidated open-items list for Waves 4B and 5.
10. **Document-map and families.** Every file in `docs/` and `mapping/` has
    a map row with the right status; the families table's winners match
    what the model cites.

## Rules

Goldens, `econ.py`, `verify.py`, `thermal.py`, `psr_layout.py` and their tests
are untouched. Fixes that change no value (a wrong citation string, a stale
status, a missing `satisfy`) may be applied with a changelog entry
(`CHANGELOG_VERIFICATION.md` in the ECN style); anything that would change a
bound value, a threshold, a selection or a decision is a draft ECN (SEL-ECN-024
onward), never applied. Conflicts recorded, not resolved. ECN-021 stays out.
Novel stays out. Australian spelling. Flat `model/`. Validate to exit 0, zero
hints; `plan_check --quiet` and `scenario_check --quiet` exit 0; `pytest`
green; diagrams regenerated. Commit on the designated branch, open a PR, do
not merge.

## Done when

- `CHANGELOG_VERIFICATION.md` lists every check above as pass or finding
  (V-N1 …), with the method used, and the consolidated open-items list for
  Waves 4B and 5.
- Value-neutral fixes applied and validated; every value-changing finding is
  a draft ECN in `docs/`.
- `docs/MIGRATION_PLAN.md` and `docs/CLAUDE_SYSML_CONTEXT.md` §8 updated with
  the verified state and what 4B must start from.
