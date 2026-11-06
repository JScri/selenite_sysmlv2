# SEL-ECN-026 — Gate thresholds carried verbatim from Decision Framework Rev D although ECN-020 / ECN-022 correct them (DG-12.3 783/day, DG-8.5 308 circuits)

**Reference:** `model/Parameters.sysml` `GateThresholds.canistersPerDaySteadyState = 783.0` (doc t123) and `GateThresholds.circuitsP8Complete = 308.0` (doc t85); `model/Gates.sysml` DG-12.3, DG-8.5; SEL-ECN-020 §4; SEL-ECN-022 §3.1 and §3.2; `docs/PLAN_REGISTER.md` rows DG-8.5 (W3-R4) and DG-12.3 (W3-R22); W3-N3, W3-N6; `CHANGELOG_VERIFICATION.md` (V-N, item 9)

**Date:** 6 November 2026 | **Status:** **DRAFT — for Jason's decision; not applied.** | **Author:** verification session for Jason (Systems Engineering Lead)

---

## 1. Problem statement

Wave 3 transcribed every numeric gate criterion of Decision Framework Rev D into `GateThresholds` "as written", and recorded two of them as known-stale:

| Threshold | Rev D text | What the baseline says | Recorded at |
|---|---|---|---|
| `canistersPerDaySteadyState = 783` (DG-12.3 "783/day at P14+ steady state") | 783/day | ECN-020 §4: 783/day is the stale 1.0 Mt/yr cadence (285,715/yr); the 2.5 Mt/yr cadence is ~694,444/yr ≈ **1,903/day** at 3.6 t (1,957/day at ECON's 3.5 t, VC-22) | W3-N6; ECN-022 §3.2 "correction Rev D needs" |
| `circuitsP8Complete = 308` (DG-8.5 "308 processing circuits complete; 125 t/yr REO") | 308 circuits | 308 is the batch-design count (0.4 t/yr); the committed 1.2 t/yr circuit (DG-8.X, SEL-REQ-015) needs **105** for 125 t/yr (ECON `circuits_needed` at Y28) | W3-N3; ECN-022 §3.1 |

ECN-022 §3 lists both as corrections for Rev E of the document, but the *model thresholds* were left at the Rev D figures ("threshold carried as written"), so the plan register evaluates DG-12.3 against 783/day (met Y141) and DG-8.5's circuit count against 308 (met Y41) — criteria the baseline itself says are wrong. Changing a threshold is a decision ("a threshold change is an ECN to the Decision Framework", `GateThresholds` doc), so the verification session records it here and does not apply it.

## 2. What would change

| | Today | If 2a |
|---|---|---|
| `canistersPerDaySteadyState` | 783 | 1,903 (ECN-020 §4 at 3.6 t) — or derived from `reoPayloadPerCanisterTonnes` once VC-22 is adjudicated (2,500,000 / 365 / payload) |
| DG-12.3 derived year (`canisters_yr / 365`) | Y141 | later (the register will say; ECON's 1,957/day at Y200 exceeds 1,903, so the gate is still met on the horizon) |
| `circuitsP8Complete` | 308 | 105 (committed design) — or the circuit-count criterion dropped, leaving REO ≥ 125 t/yr (ECN-022 §3.1 "state the REO rate only, or 105 circuits") |
| DG-8.5 derived year | REO Y28 / circuits Y41 (split, W3-R4) | REO Y28 / circuits Y28 — the split disappears |
| Goldens, ECON, VERIFY | unchanged | unchanged (thresholds are model inputs to the calcs; `plan_check` reads them by name) |

## 3. Options

- **2a — Align both thresholds to the baseline now (RECOMMENDED).** Rev D's numbers are superseded by documents the model treats as higher in the source hierarchy (ECN-020 is the applied baseline; ECN-022 is signed). Keeping them "as written" makes the register report two gates against criteria nobody intends to hold. Record the Rev D originals in the threshold docs (they already are).
- **2b — Keep as written until Rev E is rendered**, so the register keeps measuring the document that exists; the correction then lands with Rev E (Wave 5) and the thresholds move with it.
- **2c — Derive rather than type the cadence**: bind `canistersPerDaySteadyState` as an expression of `steadyStateReoTonnesPerYear` and `reoPayloadPerCanisterTonnes` (rule 3 "calc defs mirror relationships") — only after VC-22 (3.5 vs 3.6 t) is adjudicated, since the unbound payload is what the cadence turns on.

## 4. If 2a is signed

`model/Parameters.sysml` t123 → 1903.0 with the doc stating the ECN-020 basis and the 1,957/day ECON figure; t85 → 105.0 (or remove the `CircuitCountGate` calc from DG-8.5 and keep `ReoOutputGate`); `docs/PLAN_REGISTER.md` regenerated and the plan_check fixture re-cut; `CHANGELOG_WAVE3.md` W3-N3 / W3-N6 closed by addendum; ECN-022 §3.1 / §3.2 marked "applied in the model". Validate, `plan_check --quiet`, pytest.

## 5. Related, not decided here

- VC-22 (3.5 t ECON vs 3.6 t ECN-020) — the cadence's other factor; sampled two-point for D3 at Wave 4A.
- The other ECN-022 §3 corrections (REO gate years W3-N4, DG-7.5 placement W3-N15, P12/P13 re-sectioning W3-N16, DG-14.3/14.6 alias W3-N14, YBCO 280 → 523 t) change declared years and document text, not thresholds; they stay Rev E rendering items (Wave 5).

---

*— End of SEL-ECN-026 (DRAFT) —*
