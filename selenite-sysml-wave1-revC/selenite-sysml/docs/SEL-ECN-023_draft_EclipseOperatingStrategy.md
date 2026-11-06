# SEL-ECN-023 — SPA eclipse operating strategy for the asteroid-processing loads

**Reference:** SEL-ECN-022 §2.4 (`spaAsteroidLoadCriticalFraction = 1.0`), `model/Scenarios.sysml` (D1 `EclipseOperatingStrategy`), `model/Parameters.sysml`, `model/Processing.sysml`, `model/ThroughputCalcs.sysml` (`EclipseCriticalFraction`), `docs/SCENARIO_REGISTER.md` §2 D1, `docs/SESSION_BRIEF_wave4_scenarios.md`, `CHANGELOG_WAVE4A.md`

**Date:** 6 November 2026 | **Status:** **SIGNED and APPLIED (Jason, 6 Nov 2026): option 3b.** `spaAsteroidLoadCriticalFraction` 1.0 → 0.18; `seleniteProgramme.d1` selects `sunlitDutyCycle`; supersedes SEL-ECN-022 §2.4. The file keeps its draft name for the document map. | **Author:** Wave 4A session for Jason (Systems Engineering Lead)

---

## 1. Problem statement

ECN-022 §2.4 bound the asteroid-processing loads (C-type pyrolysis and Fischer–Tropsch from the C-type arrival, S-type Czochralski silicon from the S-type arrival, +100 MWe scaled operations at Y140; Decision Framework Rev D §10.1) as fully eclipse-critical: `spaAsteroidLoadCriticalFraction = 1.0`, on the reasoning that continuous thermal processes cannot cold-soak through the 72 h SPA eclipse. Jason's reading (19 Sep 2026) is that this is fine *only if the power-intensive work cannot be scheduled outside the eclipse*; if it can, only the hold loads are eclipse-critical and the fraction is a property of the operating strategy, not a constant. The symptom in the plan register is the DG-10.5 / DG-13.4 detail "eclipse-critical load 132–250,120 kW, 6,254 FSP max".

Wave 4A modelled the strategy as a decision (D1) with four alternatives, evaluated on 2,000 Latin-hypercube samples of the uncertainty register (common random numbers, seed 20260920), and derived the critical fraction per strategy (`SeleniteAnalysis::EclipseCriticalFraction`). This ECN carries the result and the recommendation; it changes no committed value.

## 2. What the trade found (register §2 D1, n = 2,000)

The four strategies, each with the FSP-versus-MSR count as the recourse per sample (ECN-022 §2.3 trade on the sampled inputs):

| Strategy | Derived critical fraction | FSP units the non-nuclear fallback needs at Y140 | SPA power-side Earth mass, MSR available (t) | SPA power-side Earth mass, MSR unavailable (t) | Throughput kept |
|---|---|---|---|---|---|
| A carryThroughEclipse (ECN-022 §2.4) | **1.00** | 6,254 | 131 | ~42,100 | yes |
| B sunlitDutyCycle | **0.18** (hold loads as a share of the plant oversized ×1.21) | 1,156 | 302 | ~8,800 | yes (plant oversized 1 / ((1 − dark)(1 − restart loss))) |
| C hotStandby | 0.15 | 941 | 131 | ~7,000 | no: 17–25 % lost, charged at ~0.97 Mt of Earth cargo through the circuit Earth-fraction reductions the lines enable |
| D hybridStorage (half the load on battery) | 0.59 | 580 | 53,009 | ~57,600 | yes |

Total expected cumulative Earth-launched mass (programme, t): A 6,935,154; B 6,935,326 (+172); C 7,909,452 (+974 kt); D 6,988,033 (+52.9 kt). P(no gate slip) is 1.00 for every strategy; the SPA MSR's first unit is Y105 under every strategy, matching ECN-022 §2.3 and DG-13.4.

**The decision turns on one assumption.** In the committed plan the SPA MSR is available when the asteroid loads arrive (`spaMsrAvailabilityProbability = 1.0`, the Wave 3 `assumedOutcome = true` of DG-7.5 and DG-9.3 restated), and an MSR sized to the total load carries the asteroid loads through every eclipse. In that world carry-through costs nothing extra and every other strategy pays its oversize plant (B, +172 t), its battery (D, +52.9 kt: half of 250 MW through a 72–120 h eclipse at 250 Wh/kg is 45–63 kt) or its lost throughput (C). If the MSR is not there — the thorium line fails its tests, or ThCl₄ never ships — the strategy sizes the FSP fleet: carry-through needs 6,254 units (about 41 kt of FSP) where the duty cycle needs 1,156 (7.6 kt); total Earth-launched mass A 6,977,110 t against B 6,943,821 t, a 33.3 kt saving.

**Break-even.** The duty cycle (B) beats carry-through on expected Earth-launched mass whenever P(MSR available at the C-type arrival) < **0.995**; at 0.9 (scenario `msrUncertain`, n = 2,000) B's expected SPA power-side mass is 1,154 t against A's 4,326 t (totals 6,936,177 against 6,939,349 t). Minimax regret says the same: A's worst regret is 33.3 kt, B's is 172 t. Hot standby (C) and hybrid storage (D) are never better than carry-through on this measure.

**Under the default criterion as proposed** (minimise expected Earth-launched mass, P(no slip) ≥ 0.8) **at the committed availability of 1.0, the register recommends A, carryThroughEclipse, with P(win) 1.00** — by 172 t, 0.002 % of the programme's Earth-launched mass. Every other criterion agrees at 1.0. The recommendation flips to B at any availability below 0.995 (0.993–0.996 across the hold-load scenarios; 0.87 if the oversize plant were launched from Earth in full).

## 3. Recommendation (for Jason's decision)

Choose between two readings of the same numbers:

- **3a — Keep ECN-022 §2.4 as bound (A).** `spaAsteroidLoadCriticalFraction` stays 1.0 and the derived twin reports 1.0. This is optimal only if the SPA MSR is as certain as the plan assumes; its cost of being wrong is 33.3 kt of Earth-launched mass (about 330 Starship cargo flights at ECON's 100 t a flight) and a 6,254-unit FSP haul up the ridge.
- **3b — Adopt the sunlit duty cycle (B) as the operating rule and rebind the fraction to its derived value, 0.18 (RECOMMENDED).** The asteroid plant is designed to run in sunlight, oversized by 1 / ((1 − dark fraction)(1 − restart loss)) ≈ 1.21 to keep its annual output, with only the hold loads carried through eclipse (C-type lines held warm at an assumed quarter of the oversized plant's rated load; the Czochralski furnace batch-scheduled between eclipses and cold through them). It costs 172 t in the committed plan and insures 33.3 kt against the MSR being late or absent; it is the robust choice (minimax regret) and the expected-value choice at any MSR availability below 99.5 %. The fallback FSP fleet becomes 1,156 units, not 6,254, and the register's "6,254 FSP max" detail becomes 1,156.

If 3b: `Parameters.sysml` `spaAsteroidLoadCriticalFraction` 1.0 → **0.18** (derived, not typed: `EclipseCriticalFraction` on the ASSUMED hold-load fractions, the oversize factor and the Decision Framework §10.1 loads; 0.04–0.37 across the hold-load scenarios), `ProgrammeConfiguration.sysml` `d1 :> EclipseOperatingStrategy::sunlitDutyCycle`, and the operating rule "pausable steps outside the eclipse; plant oversized for the dark fraction and restart losses" recorded as a requirement on the SPA asteroid processing lines (Wave 4B). The derived MSR year does not move (Y105 under every strategy); the FSP count, battery mass and Earth-launched mass do as tabled above.

## 4. What the value rests on (declared, not sourced — Jason to bind or accept)

| Input | Value used | Status |
|---|---|---|
| Hold-load fraction per line (C-type pyrolysis / F–T, scaled operations) | 0.25 of the plant's rated (oversized) load | **ASSUMED** (`eclipse.ASSUMED_HOLD_LOAD_FRACTION`); no process source; conservative against B (external analogues sit at 0.07–0.10); scenarios `holdLoadLow` 0.05 / `holdLoadHigh` 0.50 give derived fractions 0.04 / 0.37 (fallback 234 / 2,308 FSP) and the same ranking and break-even (W4A-N3) |
| Czochralski (S-type) | batch-scheduled, hold 0, half a batch of slack per eclipse | Jason, 6 Nov 2026: a batch takes 1–3 days; the sunlit window is ≥ 589 h (`SunlitWindowGate`), so every batch fits with at least eight times margin (open question 3: yes) |
| Restart loss | 0.5 day of output per eclipse, 11–18 eclipses/yr (dark fraction over the sampled longest eclipse) | ASSUMED (W4A-N3); eclipse count W4A-N7 |
| Dark fraction | 0.15 (0.12–0.23) | VERIFY `solar.illum` 0.85; Gläser et al. 2014 77.1–88.0 % (open question 2 — the NASA SPA basin page carries no illumination figure) |
| Longest eclipse | 72 h (72–120 h) | Strategy v3.1 §12.1 / VERIFY; Gläser et al. 2014 "3–5 days" (W4A-N1) |
| Oversize plant mass | 70 kg/kW (70–83.3), Earth share per the ECON circuit Earth-fraction trajectory | PROXY: Decision Framework §4 circuit designs; scenario `earthBuiltAsteroidPlant` (all from Earth) raises B's cost to 4,629 t and the break-even to 0.87 — still far below the 33.3 kt insured |
| SPA MSR availability at the C-type arrival | 1.0 | Wave 3 assumed test outcomes (DG-7.5, DG-9.3); range unbound; the break-even is 0.995. ECON's own SPA MSR deliveries (15 t units at Y105 / Y125 / Y140) are replaced by the trade's units in the D1 totals |
| Lost-throughput value | circuit Earth-fraction reductions scaled by delivered output | ECON's own substitution model; strong gearing (W4A-N6) — affects C only |

## 5. What it changes in the Decision Framework (if 3b)

| Document | Change |
|---|---|
| SEL-DECISION-001 Rev D → Rev E | §10.1 SPA MSR fleet text: the asteroid lines run on a sunlit duty cycle, plant oversized ×1.21; the MSRs are sized to the total load (unchanged); the eclipse-critical share of the asteroid loads is 0.18, carried by FSP in the non-nuclear fallback |
| SEL-T1.1-STRATEGY v3.1 → v3.2 | §12.1: "FSP covers all critical loads during 72-hr eclipse design case" gains "asteroid processing paused and held through eclipse; Czochralski batches scheduled between eclipses"; note the Gläser 3–5 day longest darkness against the 72 h case (W4A-N1) |
| SEL-ECN-022 | §2.4 superseded by this ECN |
| `docs/PLAN_REGISTER.md` | DG-10.5 / DG-11.3 / DG-13.4 / DG-14.4 / DG-14.7 detail "6,254 FSP max" → 1,156 |

## 5a. Decision (Jason, 6 November 2026)

**Option 3b adopted and applied in the same session:** the sunlit duty cycle is the operating rule; `spaAsteroidLoadCriticalFraction` rebound to the derived 0.18; `d1 :> EclipseOperatingStrategy::sunlitDutyCycle`; the plan register's DG-10.5 / 11.3 / 13.4 / 14.4 / 14.7 detail now reads 1,156 FSP max; the scenario register's baseline selection is the duty cycle. The §4 assumptions (hold loads 0.25, restart loss 0.5 day) remain declared, not sourced (W4A-N3); the requirement on the asteroid lines is Wave 4B.

## 6. Open questions this ECN also records (brief §"Open questions")

1. **Default decision criterion** — PROPOSED and carried as `ProgrammeParameters.decisionCriterion = expectedEarthMassWithSlipChance` with `chanceConstraintThreshold = 0.8`; the register prints expected value, P90, CVaR90, minimax regret and the chance constraint side by side for every decision so the choice can be made on its effect. Jason: confirm, or choose `expectedNpv` / `lexicographicMassThenNpv`.
2. **Dark-fraction source** — Gläser et al. 2014 (bound, §4 above).
3. **Czochralski window** — yes, a 1–3 day batch fits (bound, §4 above).
4. **D3 in scope** — yes; the register recommends the shuttlecock (option 2) with P(win) 0.71 on an uninformative 0.5 impact-survival probability and the fallback 2 → 1b → 1a — a sourced test probability (Decision Framework §11 item 9) is the input that would settle it.

---

*— End of SEL-ECN-023 — signed 6 Nov 2026 (option 3b applied) —*
