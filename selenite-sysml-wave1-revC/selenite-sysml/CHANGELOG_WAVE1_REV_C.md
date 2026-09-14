# Wave 1 — Revision C (consolidation of the full document corpus)

**Date:** 8 September 2026. **Trigger:** 408 files uploaded across 26 dated
batches; precedence and scope agreed with Jason.

## Added
- `mapping/UPLOAD_LEDGER.csv` — every uploaded file with batch date, family,
  revision and status (AUTHORITATIVE / SUPERSEDED / DUPLICATE / HISTORICAL /
  FIGURE / AMENDMENT / TEAM_INPUT / REFERENCE / OUT_OF_SCOPE / EXCLUDED).
- `mapping/DOCUMENT_FAMILIES.csv` + `mapping/build_ledger.py` — 188 families,
  112 authoritative winners; regenerable.
- `docs/DOCUMENT_FAMILIES.md` — precedence rule, winners by tier, flags F1–F10.
- `docs/ARCHITECTURE_BASELINE.md` — what/how/when skeleton for all phases.
- `docs/SESSION_BRIEF_wave2_architecture.md`.

## Changed
- `mapping/document_map.csv` rebuilt from families: 82 rows (was 43), keyed
  to family winners, with `family` column. Fleet v9 → v9.1, MTL Guide v18 →
  v18 revised, PROC-PKT/HAULER/POWER/IZ/PROC-001/ECLSS ×3/SENTINEL → Rev B,
  new families (CAP, CONVEYOR, FAB, REAGENT, NAV, CON, PIPE, substation,
  software specs, GIS, floor plan, LH₂ transport, final report).
- `docs/CLAUDE_SYSML_CONTEXT.md` rules 5/5a/5b: precedence source, final
  report as integrator, team inputs, architecture-before-quantities, flags
  recorded not resolved.
- `docs/MIGRATION_PLAN.md`: Wave 2 is now the architecture/temporal wave;
  quantities move to Wave 5 behind the Python port.

## Unchanged
- All `.sysml` model files. `sysml-validate` exit 0, zero hints.

## Excluded on Jason's instruction
- `selenite_briefing_scene_v2.md` (novel), `Cochlear_form-f17b.docx`.

## Tooling note
`sysml-validate` moved 0.20.0 → 0.36.0 between sessions and introduced hint
SSM021, which flags enum-typed attributes carrying a default
(`attribute activeFrom : Phase = Phase::P9`) as typed by an abstract
definition. Eight such hints now appear; validation still exits 0 with zero
errors. The version is now **pinned to 0.36.0** in CI, the bootstrap and the
quickstart so hints cannot drift silently again. Wave 2 must decide the
phase-attribute idiom before adding `introducedIn`/`retiredIn` everywhere:
keep `= Phase::Px` value binding, or switch to `:> Phase::Px` subsetting.

## Addendum 9 Sep 2026 — goldens captured
- MATLAB R2025a golden capture received (20 scripts, SHA-256 verified against
  sources); cross-checked against Octave 8.4: all common scalars bit-identical,
  ODE45 arrays differ in step sequence only. Merged tagged oracle published as
  `selenite-goldens-oracle.zip` (1,016 rows, six current-baseline scripts).
- Runner defect found and fixed (v2.1): `gold_keep` used `isgraphics()` on
  numerics; MATLAB dropped scalars equal to open figure handles (1–10) and
  arrays containing them, including the per-phase fleet vectors. Octave rows
  fill the gap in the oracle until a v2.1 rerun promotes them.
- `docs/VALUE_CONFLICTS.md` added: 14 goldens-vs-documents conflicts
  (VC-01…VC-14) for Wave 5. Notable: VERIFY v5.0 fleet profile ≠ every
  document; SCALE v1.3 is pre-ECN-019 (reclassified HISTORICAL); ECON v1.3
  resolves the MOLE-I post-P7 trajectory (F4); MSR/GW and conveyor-km totals
  in PROC-PKT Rev B do not match ECON v1.3.
- `docs/SESSION_BRIEF_python_port.md` revised: unblocked, oracle rules, ODE
  comparison rule, SCALE v1.3 as historical module.
