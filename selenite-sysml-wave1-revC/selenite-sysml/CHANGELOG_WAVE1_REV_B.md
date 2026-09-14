# Wave 1 — Revision B (baseline reference correction)

**Date:** 1 September 2026
**Trigger:** Source-revision audit against project chat history.

## Finding

The Wave 1 scaffold cited ECN-019 Rev C as the sole baseline and referenced
Strategy v3.0 / Decision Framework v3. Both labels were stale:

- **ECN-020** (mass driver parallel tracks) post-dates ECN-019 Rev C and is
  propagated across Strategy v3.1, Decision Framework Rev D, Fleet v9 and
  MTL Guide v18. Its technical content was already correct in the model
  (`Transport.sysml`, `ProgrammeConfiguration.sysml`); only the baseline
  label was wrong.
- **ECN-021** (PKT process water supply chain) is drafted but deliberately
  unpropagated pending PROC-PKT-001 Rev C, PROC-001 Rev C, ISRU-001 Rev E,
  MTL Guide v19 and Strategy v3.2. It is now recorded as a known-excluded
  source so a later session cannot adopt it by accident.
- **Decision Framework** is at **Rev D**, not v3/Rev C.
- **Strategy** is at **v3.1**, not v3.0.

## Changes

| Area | Change |
|---|---|
| `README.md` | Baseline restated as ECN-019 Rev C + ECN-020; ECN-021 exclusion note added |
| `docs/CLAUDE_SYSML_CONTEXT.md` | §1 baseline + §5 source hierarchy updated; explicit ECN-021 prohibition |
| `docs/MIGRATION_PLAN.md` | Wave 3 sources corrected; ECN-021 exit-criterion carve-out |
| `docs/HUMAN_QUICKSTART.md` | Commit message updated; `git init` step restored |
| `model/SeleniteProgramme.sysml` | Root baseline doc comment |
| `model/ProgrammeConfiguration.sysml` | Configuration baseline doc comment |
| `model/Phases.sysml`, `Sites.sysml`, `Transport.sysml`, `Power.sysml`, `Processing.sysml`, `ProgrammeRequirements.sysml` | Strategy v3.0 → v3.1; Decision Framework v3 → Rev D |
| `mapping/document_map.csv` | DF row → Rev D; Strategy row → v3.1; +2 rows (ECN-020 skeleton/Wave 2, ECN-021 planned/Wave 4, marked do-not-model) |

**No quantitative values changed.** MATLAB remains the authority for all
figures; this revision touches provenance labels only.

## Verification

- `sysml-validate model --workspace . --format compact --all` → exit 0, zero errors, zero hints
- All 4 diagrams re-rendered without error
- CSV: 43 rows (was 41)
