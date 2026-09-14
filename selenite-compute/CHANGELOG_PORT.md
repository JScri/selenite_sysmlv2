# Python port — change log

```
CHANGE LOG — 14 September 2026 (Python port session)
Scope: port the six current-baseline MATLAB scripts to selenite-compute,
       reproducing the runner v2.1 goldens row by row and the captured
       console text line by line.
Baseline in:  Wave 3 kick-off merged to main (PR #2, b816592): scaffold,
              loader, sources, v2.1 goldens.
Baseline out: 1,437 golden rows compared (1,404 pass, 33 declared skips);
              7 console captures reproduced; CI job green.
```

## Delivered

- `selenite/eclss.py` (sabatier.m), `verify.py` (VERIFY v5.0),
  `thermal.py` (THERMAL v1.3), `econ.py` (ECON v1.3 + v1.4),
  `historical/scale_v1_3.py` (SCALE v1.3), `psr_layout.py` (VISUALIZE
  v3.3): each mirrors its script variable for variable, including the loop
  leftovers the harness captured (`i`, `y`, `idx`, `ef`, `sort_idx` …).
- `selenite/capture.py`: the `gold_flatten` rules (column-major
  linearisation, struct arrays → `ARRAY_OF_STRUCTS_SKIPPED`, >2000 elements
  → numel/sum/min/max/mean, empty → `zeros(1,0)`).
- `selenite/goldens.py`: per-row comparison rules; modules declare
  `ODE_TEMPERATURE_KEYS`, `ODE_TIME_STRING_KEYS`, `ODE_ARRAY_STEMS`,
  `ODE_SKIP_KEYS`, `SKIP_KEYS` with reasons.
- `selenite/report.py`: MATLAB `fprintf` emulation and one console
  reproduction per script; `tests/test_console.py` diffs them against the
  `console_*.txt` captures.
- `tests/conftest.py`: a module porting several scripts in one workspace
  exposes `run_script(name)`.
- Removed the unused `pandas` and `numpy-financial` dependencies (IRR is
  a re-implementation of MATLAB `fzero`, see below).

## Declared skips (33 rows)

- **THERMAL, 32 rows:** `numel`, `sum`, `mean` of `tAll/TAll`, `tNS/TNS`,
  `tWS/TWS`, `tp/Tp`, `ts/Ts` (ode45 output grids: MATLAB's Refine=4 step
  sequence is not reproducible by another solver; `min`/`max` and the
  sampled temperatures are compared at 0.05 K and pass), `i253` (a step
  index) and `yl` (a figure's automatic y-limits). The 8 Sep oracle tagged
  only the temperature stems; the time grids carry the same dependence and
  are declared in `thermal.ODE_ARRAY_STEMS`.
- **VISUALIZE, 1 row:** `h_leg` — MATLAB graphics handles assigned into a
  double array (values like 0.0001220703125 are session dependent).

## What the port revealed (recorded, not fixed)

1. **R2025a `fzero` does not throw when no sign change is found.** It prints
   "Exiting fzero: aborting search for an interval containing a sign
   change …" and returns NaN, so ECON v1.4's `try/catch` around
   `irr_direct` is never taken and the console shows `NaN%`, not the
   "UNDEFINED" branch the script intended. `econ._fzero` reproduces the
   R2025a behaviour (bracket expansion by √2 from `x0/50`, abort on a
   non-finite point or value, Brent on the bracket). `irr_total` and
   `dr_breakeven` are −2.54 %: the programme's discount rate for BCR = 1 is
   negative.
2. **ECON v1.3 §9 (circuit throughput sensitivity) uses a 2 % maintenance
   rate** (`cd.mass_kg * 0.02`) while the baseline and v1.4 use
   `circuit.maint_frac = 0.005`. The three "NPV delta from batch" figures
   therefore mix two maintenance assumptions. Reproduced as written.
3. **ECON v1.4 maintenance sensitivity floors the Earth fraction at 0.008
   instead of 0.10** (`max(0.008, 1.0-(Y-25)*0.03)` where every other
   formula uses `max(0.10, …)`). Reproduced as written.
4. **ECON v1.3 never breaks even undiscounted within 200 years**
   (`be_total` is empty; console "NOT REACHED") although annual net is
   positive from Y181. Documents quoting a break-even year are not backed
   by this script.
5. **ECON v1.3 assigns `insitu_circuits(i)` inside the C-type loop before
   defining it** (`insitu_circuits = zeros(N,1)` follows). Harmless: the
   later definition overwrites it; the golden holds the later values.
6. **scaling_v1_3.m line 584 `92%`** is parsed by MATLAB as a `% h`
   conversion: the line is cut after "92" and the next rule joins it.
   `report.scaling_v1_3` reproduces the truncation; the file's last line
   (no trailing newline) is a closing rule.
7. **MATLAB `lines` colours** captured in THERMAL (`cols`) are the R2025a
   "gem" map ([0.0660 0.4430 0.7450] …), not the pre-R2025a values.
8. **VISUALIZE junction lookup:** `jid = find(abs(junctions(:,1)-jx) < 1)`
   is a 1-based index kept as a value; the port keeps every such index
   1-based (`idx`, `sort_idx`, `ph_id`).
9. The `octave_8_4_only` rows of the 8 Sep oracle are all promoted by the
   v2.1 capture; no Octave-only value remains a target.

## Validation

`pytest selenite-compute`: 1,443 passed, 33 skipped (4 s). The compute CI
job in `.github/workflows/validate.yml` runs the same suite next to
`sysml-validate`.
