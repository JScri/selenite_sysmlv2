# selenite-compute — Python port of the Selenite computational layer

**Status (14 Sep 2026, night): PORTED. Every current-baseline script is
reproduced against the runner v2.1 goldens; `pytest` runs 1,443 checks in
about four seconds.**

The MATLAB scripts remain in `selenite-goldens-runner-v2_1/` as the record
of what was ported; the Python here is now the computational authority for
quantitative values (flow: compute → documents → model, never the reverse).

| Script | Module | Golden rows | Result |
|---|---|---|---|
| `sabatier.m` | `selenite/eclss.py` | 107 | 107 exact |
| `SELENITE_VERIFY_v5_0.m` | `selenite/verify.py` (+ `power.py`, `fleet.py`, `isru.py` views) | 237 | 237 exact |
| `MOLEI_THERMAL_v1_3.m` | `selenite/thermal.py` | 274 | 242 exact or within the ODE rules; 32 declared skips |
| `SELENITE_ECON_V1_3.m` | `selenite/econ.py` (`workspace("SELENITE_ECON_V1_3")`) | 269 | 269 exact |
| `SELENITE_ECON_V1_4.m` | `selenite/econ.py` (v1.4 layered on the v1.3 workspace) | 313 | 313 exact |
| `scaling_v1_3.m` | `selenite/historical/scale_v1_3.py` (pre-ECN-019, historical) | 171 | 171 exact |
| `SELENITE_VISUALIZE_v3_3.m` | `selenite/psr_layout.py` (geometry only) | 66 | 65 exact; 1 declared skip |

"Exact" means the brief's tolerances: scalars and array elements at
relative 1e-9, strings byte-equal, `irr_direct` NaN. The declared skips are
listed in `CHANGELOG_PORT.md` (ode45 step-count statistics and a MATLAB
graphics-handle array); nothing else is loosened.

`selenite/report.py` regenerates the console text each script printed, and
`tests/test_console.py` compares it line by line with the `console_*.txt`
files the golden runner captured (only the ECON v1.3 timestamp and the
ode45-derived temperatures in THERMAL are compared loosely).

## Layout

```
selenite/
  capture.py      mirrors gold_flatten: column-major arrays, struct arrays
                  skipped, >2000-element arrays summarised, "zeros(1,0)"
  goldens.py      oracle loader + comparison rules (ODE keys, skips)
  report.py       console reproduction (MATLAB fprintf emulation)
  eclss.py verify.py thermal.py econ.py psr_layout.py historical/scale_v1_3.py
  power.py fleet.py isru.py   typed per-phase views over verify.workspace()
  constants.py    shared constants with provenance
tests/
  test_goldens.py     one test per comparable golden row (1,437 rows)
  test_console.py     console text vs console_*.txt
  test_invariants.py  golden values behind the model's VC-xx / F5 arbiters
  test_loader.py      oracle loader
  test_sources.py     SHA-256 of the .m sources vs the goldens manifest
```

Every port module exposes `workspace()` (the script's final variables as
Python objects, loop leftovers included) and `run()` (the same, flattened
with the harness's rules so keys match the CSV). `econ` takes the script
name because v1.4 overwrites some v1.3 names.

## Oracle

Canonical: `selenite-goldens-runner-v2_1/goldens_20260914_224703/` (runner
v2.1, MATLAB R2025a). The 8 Sep merged oracle under
`selenite-goldens-oracle/` supplies only the `platform_dependent_ode` tags.
Override with `SELENITE_ORACLE` / `SELENITE_ORACLE_TAGS`.

## Rules (from `docs/SESSION_BRIEF_python_port.md`)

The port reproduces the goldens, never the documents. MATLAB `integral` →
`scipy.integrate.quad(epsabs=0, epsrel=1e-13)`; `ode45` → `solve_ivp(RK45,
rtol=1e-6, atol=1e-4, max_step=300)`, compared at 0.05 K and ±1 h; MATLAB
`fzero` is re-implemented (R2025a semantics: NaN and a notice when no sign
change is found). Every mismatch was investigated; what the port revealed
is in `CHANGELOG_PORT.md`.

```bash
pip install -e "selenite-compute[test]"
pytest selenite-compute                 # 1,443 passed, 33 skipped
python -m selenite.report               # all console outputs
python -m selenite.report SELENITE_ECON_V1_4
```
