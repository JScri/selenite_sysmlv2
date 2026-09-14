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
