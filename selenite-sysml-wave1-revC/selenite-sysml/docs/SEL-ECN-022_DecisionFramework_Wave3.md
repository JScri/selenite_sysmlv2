# SEL-ECN-022 — Decision Framework Rev D: Wave 3 gate decisions and corrections

**Reference:** SEL-DECISION-001 Rev D (`docs/SELENITE_DECISION_FRAMEWORK_v4.md`), `model/Gates.sysml`, `model/Parameters.sysml`, `docs/PLAN_REGISTER.md`, `CHANGELOG_WAVE3.md`

**Date:** 19 September 2026 | **Status:** APPLIED (model) — Rev E of the Decision Framework is a rendering task, not a rewrite (Wave 3 reframe, 14 Sep 2026: the model plus the Python layer are the source of decisions; documents follow) | **Author:** Jason (Systems Engineering Lead)

---

## 1. Problem statement

Wave 3 catalogued all 81 Rev D gates as `DecisionGate`s and evaluated every derivable criterion on the ported computational layer (`tools/plan_check.py`). The register found gates whose criteria cannot be met by the programme's own production figures, gate years that disagree with the milestones the final report's Fig. 2 draws, and figures Rev D carried forward from superseded revisions. This ECN records the decisions taken on them and the corrections Rev D needs. Nothing here alters a golden; every value is either a committed decision in `SeleniteParameters` or a derived output of `selenite-compute`.

## 2. Decisions (applied in the model)

| # | Decision | Applied where | Supersedes in Rev D |
|---|---|---|---|
| 2.1 | **MD-4 SPA→Earth is a consequence of the M-type arrival (DG-12.4, Y85 = P12)**, not of a PGM-volume trigger. Rationale: the 100 t/yr trigger was sized from iridium demand for PEM electrolysers, while Rev D's own PGM production is 36.5 t/yr (M-type) + ~15 t/yr (Mk III); the trigger is unreachable under the document as written. Consequence through the Wave 2 chain: Starship SPA→Earth returns retire at Y85. | `ProgrammeConfiguration.sysml` (`md4` bound to `dgTwelveFour.derivedPhase`); DG-11.6 / DG-12.4 gated elements | §3 MD-4 row "P11 (Y70)"; DG-11.6 sentence "triggered when PGM concentrate volume exceeds ~100 t/yr"; §3.2 step 5 "P11+ if DG-11.6 approved" |
| 2.2 | **Thorium ratio bound with ranges:** Th grade at DART-selected processing sites 12.5 ppm (range 10–15; fleet v9 §11; Lunar Prospector GRS Fra Mauro / Apollo 14 soils 12–13 ppm, Lawrence et al. 2000, 2003; KREEP basalt ~15 ppm), acid-bake capture 0.92 (0.90–0.95, DG-7.2), REE processing grade 500 ppm (Rev D "Changes from Rev C"). `thoriumToReoMassRatio` is derived: ~0.030 t Th(OH)₄ per t REO. | `Parameters.sysml` | DG-11.2 "387–773 t/yr production": at 100,000 t/yr REO that implies 0.004–0.008, about four times too low (W3-N22). DG-8.7 "~40 t by Y30": derived Y37 (Y36–39). |
| 2.3 | **SPA MSR (F5) is decided by a cargo-mass trade**, not by a phase label: FSP units for the eclipse-critical load plus the solar array for the total load (Earth → SPA) against SPA MSR units sized to the total load (Earth fraction Earth → SPA; in-situ Ni-201 fraction PKT foundry → SPA via MD-3), justified when the non-nuclear cargo beyond the P7 as-built fleet exceeds the MSR's Earth cargo and ThCl₄ is available (MD-3). Result: **first SPA MSR at Y105 (P12)**, when the asteroid-processing loads arrive. | `plan_vectors.fsp_msr_trade`; `SpaMsrIntroductionGate`; `Parameters.sysml` (`spaEclipseCriticalCoverageOnly`, `spaMsrFirstUnitRatedKw`) | DG-10.5 (Y50) and DG-11.3 (Y70) as commissioning gates — superseded; DG-13.4 (Y105) stands as unit #1; DG-14.4 / DG-14.7 stand as #2 / #3. Strategy v3.1 §12.1 "SPA MSR from Y50" superseded; §5.1 "from Y105" stands. |
| 2.4 | **Asteroid-processing loads are eclipse-critical** (`spaAsteroidLoadCriticalFraction = 1.0`): pyrolysis, Fischer–Tropsch and Czochralski growth are continuous thermal processes that cannot cold-soak through the 72 h eclipse. The derived year is insensitive (Y105 at 0 or 1). | `Parameters.sysml` | — (new parameter) |
| 2.5 | **Milestones M0–M8** are the MTL v8.5 definitions (`docs/W5_T4_4_JS_milestone_reference.html`), confirmed against final report Fig. 2. | `Gates.sysml` `MilestoneSet` | Where Rev D gates date the same events differently: DG-2.2 Y5 vs M4 Y6; DG-5.1 Y9 vs M8 Y11; DG-6.4 Y12 vs M7 Y11.5; DG-5.2 Y10 vs M5 Y9 (W3-N21). Milestone years are the reference for these events; the gate years should be aligned at Rev E. |
| 2.6 | **PSR MOLE-I capacity is the layout computation:** 620 positions (124 nodes × 5, `psr_layout.py`), SEL-REQ-016. The Mk III transition is not capacity-forced (ECON MOLE-I peak 357); it rests on the DG-11.6 test outcome. | `Parameters.sysml`, `RobotFleet` bindings | §6 "~310 usable floor positions"; Strategy §4.4 "~310". |

## 3. Corrections Rev D needs (carried forward from superseded revisions or internally inconsistent)

| # | Rev D text | Correction | Source |
|---|---|---|---|
| 3.1 | DG-8.5 "308 processing circuits complete; 125 t/yr REO" | 308 is the batch-design (0.4 t/yr) count; the committed 1.2 t/yr circuit needs 105 for 125 t/yr. State the REO rate only, or 105 circuits. | ECON `circuits_needed` at Y28 (W3-N3) |
| 3.2 | DG-12.3 "783/day at P14+ steady state" and §14+ "285,715 canisters/yr, ~783/day" | Stale 1.0 Mt/yr cadence; ECN-020 §4 corrected the 2.5 Mt/yr cadence to ~694,444/yr, ~1,903/day. | ECN-020 (W3-N6) |
| 3.3 | DG-14.6 "(DG-14.3 from ECN-019)"; Strategy §16 "DG-14.3, Y140" | Rev D numbering carried; Strategy §16 should read DG-14.6 (its §15.1 already does). | W3-N14 |
| 3.4 | DG-7.5 "~2040" listed under P7 | 2040 = Y15, inside the F7 gap (P6 ends Y15, P7 starts Y18); list under P6 or state the year. §1 transition 4 "P7 (Y15)" has the same drift. | W3-N15 |
| 3.5 | DG-13.5 (Y110), DG-13.6 (Y115), DG-14.1 (Y95), DG-14.2 (Y115), DG-14.9 (Y115) listed under P13/P14; DG-14.5 (Y130) under P14 | By the phase year table these are P12 and P13 respectively (W2-N7: years authoritative). Re-section at Rev E. | W3-N16 |
| 3.6 | DG-11.1 100,000 t/yr at Y60; DG-12.1 500,000 t/yr at Y80; DG-13.1 1,250,000 t/yr at Y120 | The economics ramp (`reo_target`) reaches these at Y80 / Y121 / Y152; Rev D's own P12 end-state (~500,000 at ~Y120) and Strategy §15.1 agree with the economics, not with the gates. Align the gate years to the ramp or ECN the ramp. | W3-N4 |
| 3.7 | §3 "Total YBCO ~280 t"; §8 "~280 t lifetime total" | ECN-020: 523 t (5 drivers, 8 tracks). | ECN-020 (W3-N12 also notes ECON ships only 140 t) |

## 4. Open findings (recorded, not decided — Wave 5 economics)

- DG-14.6 target (< 0.5 % of infrastructure mass from Earth) is not met in any year to Y200 on the annual-flow proxy (minimum 4.8 % at Y139) — W3-N1.
- DG-13.7 hauler Earth-fraction floor of 20 % is never reached (ECON floors at 0.33 with the M-type bonus) — W3-N5.
- Infrastructure scaling gates (DG-9.7, 10.1, 10.2, 10.4, 11.2, 11.5, 12.2, 12.3) run 15–90 years later on the economics than Rev D declares; VC-08 / VC-09 / VC-10 lineage.
- REO canister payload 3.5 t (ECON) vs 3.6 t (ECN-020) — W3-N7.
- MD-3 canister payload for the PKT→SPA in-situ MSR fraction is unspecified in ECN-020.

## 5. Affected documents

| Document | Change |
|---|---|
| SEL-DECISION-001 Rev D → Rev E | §2 gates per §2–§3 above; §3 MD-4 row; §10.1 SPA MSR fleet text ("from Y105" stands); YBCO totals |
| SEL-T1.1-STRATEGY v3.1 → v3.2 | §12.1 SPA MSR "from Y50" → Y105; §16 DG-14.3 → DG-14.6; §4.4 310 → 620 positions |
| SEL_ROBOT_FLEET v9 | §18.1 P10 "SPA MSR from Y50" → Y105; §4.1 310 → 620 |
| MTL Guide v18 / extended timeline v3 | MD-4 Y70 → Y85; "DG-14.3 (Y140)" → DG-14.6 |

Rev E of the Decision Framework is produced as a rendering from the model at Wave 5, not by hand.

---

*— End of SEL-ECN-022 —*
