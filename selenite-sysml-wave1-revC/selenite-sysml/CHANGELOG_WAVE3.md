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

### Blocked (Jason to unblock)
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

### Validation
`sysml-validate` 0.36.0: 15 files checked, no problems found. `pytest
selenite-compute`: loader and invariant tests pass, 1,035 rows skipped with
reasons, 2 expected failures (missing arbiters).
