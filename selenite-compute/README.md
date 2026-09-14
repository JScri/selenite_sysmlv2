# selenite-compute — Python port of the Selenite computational layer

**Status (14 Sep 2026, evening): unblocked — sources and the canonical oracle are in the repository; no module ported yet.**

- Sources: all 20 MATLAB scripts in `selenite-goldens-runner-v2_1/`, SHA-256 verified
  against the goldens manifest by `tests/test_sources.py`.
- Canonical oracle: `selenite-goldens-runner-v2_1/goldens_20260914_224703/` (runner v2.1,
  MATLAB R2025a). It restores the vectors runner v2.0 dropped. The 8 Sep merged oracle
  under `selenite-goldens-oracle/` is kept for its `platform_dependent_ode` tags and history.

| Script | Port target | Oracle rows (v2.1) |
|---|---|---|
| `sabatier.m` | `selenite/eclss.py` | 107 |
| `SELENITE_VERIFY_v5_0.m` | `selenite/verify.py` over `power.py`, `fleet.py`, `isru.py` | 237 |
| `MOLEI_THERMAL_v1_3.m` | `selenite/thermal.py` | 274 (26 ODE rows compared at 0.05 K) |
| `SELENITE_ECON_V1_3.m` + `SELENITE_ECON_V1_4.m` | `selenite/econ.py` (one module; v1.4 is `report()`) | 269 + 313 |
| `scaling_v1_3.m` | `selenite/historical/scale_v1_3.py` (pre-ECN-019, historical) | 171 |
| `SELENITE_VISUALIZE_v3_3.m` | `selenite/psr_layout.py` (geometry only) | 66 |

## What works today

- `selenite/goldens.py` loads every oracle row, parses MATLAB `mat2str`
  arrays, strings, `NaN`/`Inf`, and carries the `source` / `comparable` tags.
- `tests/test_loader.py` proves the loader reads all rows (runs green now).
- `tests/test_goldens.py` is parametrised over every comparable row. Each
  test resolves the row's port module; while a module is unported the test
  **skips with the reason**, so the suite is green-by-skip today and turns
  into the real regression suite module by module as sources land.
- `tests/test_invariants.py` pins the golden side of every document-versus-
  golden conflict the model records (VC-01/07/08/09/10, F5), so the register
  in `docs/VALUE_CONFLICTS.md` is live.

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
