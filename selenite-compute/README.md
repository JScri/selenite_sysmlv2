# selenite-compute — Python port of the Selenite computational layer

**Status (14 Sep 2026): scaffold only. The port is BLOCKED on source scripts.**

The regression oracle is in the repository
(`selenite-goldens-oracle/oracle/oracle/*.csv`, 1,016 tagged rows across six
current-baseline scripts) but the MATLAB scripts that produced it are not:
only `RUN_GOLDENS.m` and `gold_run_chain.m` were uploaded. A port cannot be
written from outputs. To unblock, copy these into `selenite-compute/matlab_sources/`
(their SHA-256 must match `selenite-goldens-oracle/oracle/matlab_r2025a/manifest.json`):

| Script | Port target | Oracle rows |
|---|---|---|
| `sabatier.m` | `selenite/eclss.py` | 107 |
| `SELENITE_VERIFY_v5_0.m` | `selenite/power.py`, `fleet.py`, `isru.py` | 214 |
| `MOLEI_THERMAL_v1_3.m` | `selenite/thermal.py` | 240 (26 ODE rows compared at 0.05 K) |
| `SELENITE_ECON_V1_3.m` + `SELENITE_ECON_V1_4.m` | `selenite/econ.py` (one module; v1.4 is `report()`) | 139 + 179 |
| `scaling_v1_3.m` | `selenite/historical/scale_v1_3.py` (pre-ECN-019, historical) | 137 |
| `SELENITE_VISUALIZE_v3_3.m` | `selenite/psr_layout.py` (geometry only) | 47 (raw `matlab_r2025a/` capture only; not in the merged oracle) |

## What works today

- `selenite/goldens.py` loads every oracle row, parses MATLAB `mat2str`
  arrays, strings, `NaN`/`Inf`, and carries the `source` / `comparable` tags.
- `tests/test_loader.py` proves the loader reads all rows (runs green now).
- `tests/test_goldens.py` is parametrised over every comparable row. Each
  test resolves the row's port module; while a module is unported the test
  **skips with the reason**, so the suite is green-by-skip today and turns
  into the real regression suite module by module as sources land.
- `tests/test_invariants.py` checks the oracle against counts the SysML
  model commits to. Known document-versus-golden conflicts are `xfail`
  with their VC number, so the register in `docs/VALUE_CONFLICTS.md` is live.

## Rules (from `docs/SESSION_BRIEF_python_port.md`)

The port reproduces the goldens, never the documents. Scalars `rel_tol=1e-9`;
arrays elementwise `rel_tol=1e-9`; `platform_dependent_ode` rows at
`abs_tol=0.05 K` via `solve_ivp(method="RK45", rtol=1e-6, atol=1e-4)`;
`irr_direct` is NaN; `octave_8_4_only` rows are valid targets. Every constant
carries provenance. Flow is compute → documents → model, never the reverse.

```bash
pip install -e "selenite-compute[test]"
pytest selenite-compute            # or: SELENITE_ORACLE=/path/to/oracle pytest
```
