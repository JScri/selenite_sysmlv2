# Session Brief — Python port of the Selenite computational layer (revised 9 Sep 2026)

**Status 14 Sep 2026: BLOCKED on sources — scaffold in place.** The MATLAB
scripts are not in the repository (only `RUN_GOLDENS.m`, `gold_run_chain.m`
and the goldens). Put the six current-baseline `.m` files in
`selenite-compute/matlab_sources/` (hashes checked by `tests/test_sources.py`
against `manifest.json`); the scaffold, loader and per-row test suite in
`selenite-compute/` are ready and CI runs them. Previously:
**Status: UNBLOCKED.** Goldens captured under MATLAB R2025a (canonical) and
cross-checked under Octave 8.4: every common scalar bit-identical. Oracle in
`selenite-goldens-oracle.zip` → unpack as `selenite-compute/goldens/`.

## Read first
1. `goldens/README.md` — three folders, the `source` and `comparable` tags.
2. `docs/VALUE_CONFLICTS.md` (sysml repo) — where documents and goldens
   disagree. **The port reproduces the goldens, never the documents.**
3. `docs/DOCUMENT_FAMILIES.md` — SCALE v1.3 is pre-ECN-019 (VC-14); port it
   as `historical/scale_v1_3.py`, not as the current scaling model. ECON
   v1.3/v1.4's bottom-up infrastructure derivation is the current authority.

## Port targets (current baseline) and oracle rows
| Script | Module | Oracle rows |
|---|---|---|
| sabatier.m | `selenite/eclss.py` | 107 |
| SELENITE_VERIFY_v5_0.m | `selenite/power.py`, `fleet.py`, `isru.py` | 214 |
| MOLEI_THERMAL_v1_3.m | `selenite/thermal.py` | 240 (26 ODE rows not diffed) |
| SELENITE_ECON_V1_3.m → V1_4.m | `selenite/econ.py` (one module; v1.4 is the report layer) | 139 + 179 |
| scaling_v1_3.m | `selenite/historical/scale_v1_3.py` | 137 |
| SELENITE_VISUALIZE_v3_3.m | `selenite/psr_layout.py` (geometry only; 47 rows) | 47 |

## Test rules
- `tests/test_goldens.py` parametrises over every oracle row with
  `comparable == yes`. Scalars: `rel_tol=1e-9`. Arrays (`mat2str` strings):
  parse and compare elementwise at `rel_tol=1e-9`.
- Rows tagged `platform_dependent_ode`: compare `T@24h`, `T@72h`, `T@200h`
  and equilibrium temperatures at `abs_tol=0.05 K`, using `scipy.integrate.
  solve_ivp(method="RK45", rtol=1e-6, atol=1e-4)` to mirror the ODE45 options.
- Rows tagged `octave_8_4_only(matlab_v2.0_dropped)` are valid targets (they
  are the per-phase fleet vectors the v2.0 runner lost under MATLAB). A rerun
  with runner v2.1 will promote them to `matlab_r2025a`.
- `irr_direct` is NaN in the oracle; assert `math.isnan`.
- ECON v1.4 depends on v1.3's workspace: implement as one module whose
  `run()` returns the v1.3 state and a `report()` that computes v1.4 on it.

## Known source defects (reproduce, then fix in a separate commit with a new golden)
- `scaling_v1_3.m` line 584: `92%` unescaped (print only).
- `SELENITE_AUDIT_RESOLVE.m`: `P_OGA_B` undefined — sabatier.m is the working copy; do not port AUDIT_RESOLVE.

## Structure
```
selenite-compute/
  selenite/
    constants.py        # physical + programme constants, single definition
    eclss.py            # Sabatier, WRS, OGA mass balance
    power.py            # solar, FSP, eclipse survival, battery sizing
    fleet.py            # MOLE-I/S, hauler, PROBE demand-driven scaling
    isru.py             # electrolysis, cryo, propellant
    econ.py             # NPV, BCR, externalities  [needs SELENITE_ECON]
    scale.py            # circuits, MSR units, canisters  [needs SELENITE_SCALE]
    report.py           # regenerates the console output the .m files printed
  tests/
    test_goldens.py     # parametrised over every goldens CSV row
    test_invariants.py  # architectural constraints, not just numbers
  goldens/              # committed, immutable
  pyproject.toml
```

**Libraries:** numpy, scipy, `numpy-financial` (NPV/IRR — scipy dropped them),
pandas for the audit tables, matplotlib to replace SELENITE_VISUALIZE, pytest.

---

## Order of work

1. **Golden loader.** Read the CSVs into a comparison fixture. Tolerance:
   relative `1e-9` for pure arithmetic, `1e-6` where iteration or
   accumulation is involved. Set tolerance per value, not globally — a single
   loose global tolerance hides real regressions.
2. **Port bottom-up.** Constants first, then ECLSS (smallest, fully covered by
   the `sabatier.m` goldens), then power, fleet, ISRU. Economics last, since
   it depends on scale outputs.
3. **Test as you go.** Each module lands with its goldens passing before the
   next starts. Do not port everything then debug — the failure surface
   becomes untraceable.
4. **Investigate every mismatch, never paper over one.** A disagreement is
   either a port bug or a latent MATLAB bug. The `P_OGA_B` defect in
   `SELENITE_AUDIT_RESOLVE.m` was found exactly this way. If a golden turns
   out to be wrong, fix the Python, record the discrepancy in the change log,
   and flag it — a golden is evidence, not scripture.
5. **CI.** Extend `.github/workflows/validate.yml` with a pytest job so
   `sysml-validate` and the numeric suite gate the same push.

---

## Rules carried over

- **The computational layer is authoritative for quantitative values.** After
  the port, Python replaces MATLAB in that role. SysML and the documents stay
  downstream and never originate figures.
- **Flow stays one-way:** compute → documents → model. Never model → compute.
- **Provenance on every constant** — a comment citing source document and
  revision, same discipline as the `.sysml` doc comments.
- **Baseline:** ECN-019 Rev C + ECN-020. ECN-021 stays out until its source
  documents are revised.
- Australian spelling; markdown authoritative over docx.

---

## Explicitly out of scope

Wave 5 SysML parametrics (separate session, needs this done first); the novel;
re-deriving any engineering result. This session *reproduces* current results
and nothing more — a port that improves the model while moving it cannot be
verified, because a mismatch becomes ambiguous.

---

## Done when

- Every golden value reproduced within tolerance, or the discrepancy is
  explained and logged.
- `pytest` green in CI alongside `sysml-validate`.
- `report.py` reproduces the console output the `.m` scripts printed, so the
  documents can still be regenerated from the same numbers.
- A short change log in ECN style listing anything the port revealed.
