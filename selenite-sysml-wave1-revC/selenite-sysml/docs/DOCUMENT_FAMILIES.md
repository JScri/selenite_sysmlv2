# Selenite — Document Families and Precedence (consolidated 8 Sep 2026)

Generated from `build_ledger.py` over the 408 files uploaded across 26 dated
batches. Full per-file detail is in `UPLOAD_LEDGER.csv`; per-family winners in
`DOCUMENT_FAMILIES.csv`. The batch→date mapping came from Jason's upload
labels and exists nowhere else, which is why this was written down first.

## Precedence rule (agreed)

1. **Revision identifier wins** within a family: v9.1 > v9, Rev B > Rev A,
   `_revised` / `_updated` / `updated_` > base.
2. **Folder date only breaks ties** between identically-labelled files. Folder
   dates reflect copying, not authorship (v9-1 sat in an "early April" folder
   while v9 sat in the "April 12" folder; the revision number is what counts).
3. **Architectural baseline: ECN-019 Rev C + ECN-020.** ECN-021 is drafted and
   deliberately excluded until PROC-PKT-001 Rev C, PROC-001 Rev C, ISRU-001
   Rev E, MTL Guide v19 and Strategy v3.2 exist.
4. **Markdown over docx** at equal revision.
5. **`SEL_FINAL_REPORT_v4.docx` is the integrating reference.** Team inputs
   (W2_T1_6, W5_Task_4_1, W5_T4_6, W6_T5_4, W7_T6_1) carry design weight
   through it. Transcribed into the repo 16 Sep 2026 as `docs/SEL_FINAL_REPORT_v4.md`
   (narrative + all 64 figures, `docs/final_report_figures/`); its
   Leadership Reflections section is course-assessment content and was not
   transcribed. Historical reference only — see the status note at the top
   of that file and W2-N8…N17 below before citing a figure from it.
6. Documents your own inventory marks STALE (pre-ECN-019 `programme_scope`,
   catapults for ore, SKIPs at PKT, 2.5M circuits at P12, 1 Mt/yr at Y100) are
   historical context only.

## Authoritative set by tier

**Tier 1 — programme architecture**
| Family | Winner | Note |
|---|---|---|
| ECN-019 | `ECN-019_Programme_Wide_Design_Revision.md` | Rev C — baseline |
| ECN-020 | `SEL-ECN-020_MassDriver_ParallelTracks.md` | DRAFT, applied |
| Decision Framework | `SELENITE_DECISION_FRAMEWORK_v4.md` | assumed = "Rev D" (see flags) |
| Strategy | `SEL-T1_1-STRATEGY-v3_1.md` | |
| Robot Fleet | `SEL_ROBOT_FLEET_v9.md` | **Corrected 14 Sep 2026 (F2).** `v9-1.docx` is an earlier v9.0 draft, not a revision above v9 |
| MTL Guide | `MTL_GUIDE_v18_revised.docx` | v18.md is last markdown |
| Extended timeline | `selenite_extended_timeline_v3_revised.html` | P7–P14+ |
| MTL interactive | `W2_T1_1_JS_MTL_v8_5.html` | P0–P7 |
| Programme scope | `selenite_programme_scope.md` (ECN-019 rewrite, April-12 folder) | three older same-named copies are pre-ECN-019 |
| Final report | `SEL_FINAL_REPORT_v4.docx` → `docs/SEL_FINAL_REPORT_v4.md` | integrator, in repo from 16 Sep 2026 |
| Economics | `SEL-ECON-001_RevA_revised.docx`, `SEL-ECON-001_Economic_Evaluation_Report.md` | |
| Value chain | `v14_1` (P0–P7) + `v15` (P7–P12) + `v16` (P13+) | scope split, all three current |
| Site selection | `W4_T3_3_JS_Selenite_site_selection_v1` | GIS, LOLA 5 m |

**Tier 2 — computation (goldens baseline)**
`sabatier.m` (working AUDIT_RESOLVE), `SELENITE_VERIFY_v5_0.m`,
`SELENITE_ECON_V1_3.m` → `_V1_4.m` (chain; also the current scaling authority),
`MOLEI_THERMAL_v1_3.m`, `SELENITE_VISUALIZE_v3_3.m`. All earlier `.m` versions
are HISTORICAL: kept so stale document figures can be traced to the script
that produced them. **`scaling_v1_3.m` (SCALE v1.3) is also HISTORICAL** —
its console shows PKT SKIPs, tankers and 48,990 MOLE-I at P8: pre-ECN-019
architecture (see `VALUE_CONFLICTS.md` VC-14).

**Tier 3 — vehicle specifications**
| Family | Winner |
|---|---|
| MOLE-I | `SEL_MOLEI_DESIGN_v5.docx` + `SEL-MOLEI-MkII-001_RevA.docx` |
| MOLE-S | `SEL_MOLES_DESIGN_RevA_updated.docx` |
| PROBE | `SEL_PROBE_DESIGN_RevB.docx` + `SEL-PROBE-MkII-001_RevA` + `SEL-PROBE-MkIII-001_RevA` |
| SKIP | `SEL_SKIP_DESIGN_RevA_updated.docx` (SPA only; retired P9) |
| DART | `SEL_DART_DESIGN_RevA_updated.docx` |
| ARM | `SEL_ARM_DESIGN_RevA_updated.docx` (ARM-C + ARM-D) |
| SENTINEL rover | `SEL_SENTINEL_DESIGN_RevB.docx` |
| SENTINEL software | `SEL-SW-SENTINEL-001_RevB.docx` (ECN-014 folded in) |
| SINTER | `SEL_SINTER_DESIGN_RevA_updated.docx` |
| SURVEY | `SEL_SURVEY_DESIGN_RevA_updated.docx` |
| HARVEST | `SEL_HARVEST_DESIGN_RevA_updated.docx` |
| Hauler | `SEL-HAULER-001_RevB.docx` (+ `HAULER_SPEC_UPDATE_BRIEF.md` as its rationale) |
| CAP | `SEL-CAP-001_RevA_updated.docx` |
| Substation | `SEL_SUBSTATION_DESIGN_v4.docx`, `SEL-SW-SUB-001_RevC.docx` |
| MOLE-I software | `SEL-SW-MOLEI-001_RevD.docx`, `SEL-NAV-001_MOLEI_Navigation_RevA.docx` |
| Catapult | `SEL-CATAPULT-001_RevB.docx` — **heritage for mass drivers only**; superseded for ore transport. **Rev C outstanding** — ECN-020 §6 requires a §5.1 parallel-track section (VC-21) |
| Conveyor | `SEL-CONVEYOR-001_RevA.docx` |

**Tier 4 — facilities and infrastructure**
HAB-001 Rev D · HAB-WALL-XSECTION-001 · FP-HAB-001 Rev B · ECLSS-001 Rev B ·
ECLSS-002 Rev B · ECLSS-SCALING-001 Rev B · ISRU-001 Rev D (updated) · IZ-001
Rev B · ELZ-001 Rev A · POWER-001 Rev B · PIPE-001 Rev A · CON-001 Rev B
(updated) · PROC-001 Rev B · PROC-PKT-001 Rev B · REAGENT-001 Rev A · FAB-001
Rev A · Base Floor Plan v2.1 · LH₂ transport v4 · EVA contingency (corrected).

**Tier 5 — CAD references** — all 14 `SEL-CAD-*-001_RevA`; for ISRU the
`updated_` copy carries the ECN-014 valve-station amendment.

**Tier 6 — ECN records** — ECN-012, -013, -014 (as amendments), -018, -019,
-020. ECN-015/-016/-017 exist only as folder names and the fleet ECN-016
amendment doc; their content is folded into fleet v9 and Hauler/Catapult Rev B.

## Excluded / out of scope
- `SEL-ECN-021_PKT_ProcessWater.md` — source recovered 14 Sep 2026, now in
  `docs/`. Still **excluded from the baseline** pending its five source-document
  revisions. Carries three arithmetic defects (VC-15/16/17) that must be
  resolved before propagation.
- `selenite_briefing_scene_v2.md` — novel. Never enters the repo.
- `Cochlear_form-f17b.docx` — accidental.
- Course admin PDFs, lecture slides, pitch decks, legal PDFs, HØW artefacts:
  context for the report, not model sources.

## Flags needing Jason's decision

| # | Flag | My default until told otherwise |
|---|---|---|
| F1 | Is `SELENITE_DECISION_FRAMEWORK_v4.md` the document referred to as "Rev D" in earlier sessions? **Confirmed 14 Sep 2026:** its header reads "SEL-DECISION-001 Rev D"; v3 is Rev C. Diff v3→v4 (both now in `docs/`): only the "Changes from" paragraph, §10.2 (PKT base positioning principle table, resource adequacy 220–660 Mt / 88–264 yr, tiered depth mining Tier 1–3 with DG-POST.1 ~Y280+ and DG-POST.2 ~Y380+), the "Beyond Y200" paragraph (400–1,300 yr reserve replacing "millions of years"), open item 4 wording, and open items 13–14 added. **No gate in §2 changed between the two revisions.** | Yes — resolved |
| F2 | **Diffed 14 Sep 2026 (Wave 2).** `v9-1.docx` is internally titled v9.0, was created 15 minutes *before* `v9.docx` (docx metadata 13:12 vs 13:27, 5 Apr 2026), is the shortest of the three copies (237 / 295 / 730 extracted lines) and contains **no ECN-020 content** (no §16 mass driver network, no parallel tracks, no 523 t, no 694,444/yr; document history ends at v9/ECN-019). `v9.md` is the only copy carrying ECN-020 §16, PROBE-Scout §2.1, the Mk II retrofit §4.2, ISRU §12, crater access §13 incl. CAP, power §18 and IZ §19. Detail in `CHANGELOG_WAVE2.md`. | **`v9.md` wins; `v9-1.docx` reclassified HISTORICAL** (precedence rule 1 misfired on a filename that was never a revision label). Jason to confirm. |
| F3 | Hauler in-situ fraction: fleet v9 / hauler brief say **92 %**; the update-session prompts and strategy items say **~57 %**. | Model as an attribute with both values flagged; do not pick |
| F4 | MOLE-I peak and decline: **~355 at P12** (hauler brief, scope material-flow) vs **320→~50 during P11** (scope P11) vs **~355 (P10)** (final report Fig. 29) vs ECON v1.3 357 at Y35 (VC-07). Which phase does the Mk III–driven drop occur in? | Attribute per phase, conflict recorded |
| F5 | SPA MSR: **commissioned at P10 (DG-10.5)** in scope P10 vs **SPA MSR #1 at P13** in scope P13. Tally 14 Sep 2026: P10 has four supports (scope P10, DG-10.x numbering, fleet v9 §18.1 P10 row "from Y50", fleet v9 App. C P10 row, MD-3 ThCl₄ link at P10); P13 has two (scope P13, fleet v9 §18.1 unit list Y105/Y125/Y140 sized to asteroid loads). | **Demand-gated (Jason, 14 Sep 2026).** `introducedIn` unbound; gate modelled as `SeleniteAnalysis::SpaMsrIntroductionGate` (demand vs non-MSR capability vs ThCl₄ supply vs feasibility), evaluated at Wave 5. Final report v4 carries both readings (Fig. 33 P10 "commissioned DG-10.5"; Fig. 34 P13 "#1", P14 "#2/#3") and Decision Framework Rev D carries three commissioning gates (W2-N20). **ECON v1.3/v1.4 golden (runner v2.1, 14 Sep 2026): `cargo_spa_msr` is first non-zero at Y105, then Y125 and Y140 — the economics assumed the #1/#2/#3 series, not Y50 or Y70.** Recorded as `SpaThoriumMSR.econAssumedIntroductionYear = 105`; `introducedIn` stays demand-gated. |
| F6 | Scope P11 says "SPA→Earth mass driver (MD-3)"; ECN-020 defines MD-3 = PKT→SPA, MD-4 = SPA→Earth. | ECN-020 numbering wins; scope label is stale |
| F7 | Year gap: P6 ends Y15, P7 starts Y18. Intentional slack or drift? **Wave 3:** DG-7.5 ("~2040" = Y15) is the one gate the Decision Framework dates inside the gap (W3-N15). | Model P7 as Y18–25 with the gap explicit |
| F8 | Audit AUD-001…012 (MOLE-S 350 vs ~205 kg; SINTER 2,200 vs ~1,418 kg; SKIP 350 vs 400 kg/hop; ISRU 1,090/1,139/1,171 kW). Do the Rev B / v9 documents resolve any? Unknown until read. | Carry into Wave 2 as a value-conflict register; ISRU 1,171 kW appears adopted in CAD-ISRU |
| F9 | `SEL_FINAL_REPORT_v4.docx` date not given. | Treat as April 2026, post-ECN-020 |
| F11–F14 | See `VALUE_CONFLICTS.md` VC-01…VC-14 — goldens vs documents, surfaced by the MATLAB run. | Recorded, adjudicate at Wave 5 |
| F10 | `scaling_v1_3.m` line 584 `92%` → `92%%`; `SELENITE_AUDIT_RESOLVE.m` P_OGA_B defect. | Fix in source before Python port |

## Wave 2 observations (not F-flags; recorded in model `doc` comments)
| # | Observation | Where |
|---|---|---|
| W2-N1 | MOLE-I Mk II retrofit start: baseline says "from P7"; fleet v9 §4.2 says rollover P8–P9, full fleet by end P9. Model binds Mk II `introducedIn = P7`, Mk I `retiredIn = P9`. Final report Fig. 32 P7 card "MOLE-I Mk II retrofit begins" supports P7. | `RobotFleet.sysml` |
| W2-N2 | MD-3 PKT→SPA: baseline P10; fleet v9 §16 "P9–P10 (Y43)" (Y43 is in P9). Model binds P10. | `Transport.sysml` |
| W2-N3 | SPA EM catcher: baseline P11; fleet v9 §2.4 says the MD-3 receiver "built P9–P10 serves double duty". Model binds P11. | `Transport.sysml` |
| W2-N4 | CAP: baseline "P4+ (anchors reserved P1)"; fleet v9 §13.5 heading "Phase 2+ Contingency". Model binds P4, `anchorsReservedFrom = P1`. | `RobotFleet.sysml` |
| W2-N5 | P0 window: baseline Y1–3; fleet v9 App. C Y0–3. Model carries Y1–3; final report Fig. 1 arc ("Foundation P0–P7 · Y1–25") agrees. | `Phases.sysml` |
| W2-N6 | The intermediate `v9.docx` quotes "5 mass drivers (~280 t YBCO lifetime)" — a third pre-ECN-020 total beside 303 t (ECN-020 §3) and 523 t. Historical only. | ledger |
| W2-N7 | Asteroid "online" years do not sit in the phases the tables put them in: C-type online **Y105** is listed under P13 (Y120–140) and S-type online **Y125** under P14 (Y140–180) in both `ARCHITECTURE_BASELINE.md` §1 and fleet v9 App. C, yet by the year windows Y105 and Y125 are both inside P12 (Y80–120). M-type Y85 in P12 is consistent. **Resolved 14 Sep 2026: years authoritative** (M/C/S 20 years apart, redirect→arrive cadence). C-type line → P12, S-type line → P13, P14 has no new arrival. Corrected in the model and `ARCHITECTURE_BASELINE.md`; source documents left as-is (obsolete by policy: the model is the source of truth). | `Processing.sysml`, `Sites.sysml` |
| W2-N8 | `SEL_FINAL_REPORT_v4` Fig. 34 P14 card, Fig. 29 conveyor card and Fig. 46 all give "~303 t YBCO lifetime" — pre-ECN-020 (523 t, 8 tracks). Fig. 54 §05 also says Earth-return mass drivers operate "at both locations" by P9 (ECN-020: SPA→Earth MD-4 is P11). The report is only partially ECN-020-propagated (F9). | report |
| W2-N9 | `SEL_FINAL_REPORT_v4` Fig. 34 P11 card: "SPA→Earth mass driver (MD-3)" — the F6 stale label; ECN-020 numbering has MD-4 = SPA→Earth. | report |
| W2-N10 | `SEL_FINAL_REPORT_v4` p.2: "PKT circuit commissioning is phased with the retirement of SPA's chemical hopper fleet, redirecting water production from propellant to process supply via mass driver" — this is ECN-021 content (PKT process water), which is excluded from the baseline pending VC-15/16/17. | report |
| W2-N11 | `SEL_FINAL_REPORT_v4` Fig. 33 P8 card: "First MSR prototype if DG-7.5 met" — a conditional P8 PKT MSR prototype that no baseline row carries (PKT first MSR is P9, DG-9.3). Not modelled. | report |
| W2-N12 | SURVEY concept: final report Fig. 28 ("polar LLO prospector, ~120 kg") and Fig. 32 ("dual orbital prospector coverage" at P5) and the baseline treat SURVEY as orbital-only; fleet v9 §6 is a ~180 kg surface rover (GPR, pXRF, seismic) plus an orbital mission. Which is current? `homeSite` left at `spa`. | `RobotFleet.sysml` |
| W2-N13 | First FSP at SPA: fleet v9 §18.1 has P1–P3 solar-only, FSP from P4; final report Gantt (Fig. 25) hauls FSP-1 to the power zone at ~M33 and commissions the hub at M36 (Y3), Fig. 32 has FSP-2 with Crew-1 at P4. Model keeps P4, `candidateIntroductionEarly = P2` recorded. | `Power.sysml` |
| W2-N14 | Minor count/phase drifts in the final report: "14 vehicle classes" (Fig. 28) vs "twelve" (fleet v9 §1) vs "11 classes" (Fig. 1); MOLE-S 6 units "P7+" (Fig. 29) vs P6 (fleet v9 §3, Fig. 31); ARM-D "P3: 2" (Fig. 29) vs 1 provisional at P3 (Fig. 31 footnote, baseline); ELZ shows three pads on the GIS map (Fig. 3) vs four in ELZ-001 / Fig. 32; report carries both 6,890 MSR (Fig. 1, 46) and 8,334 MSR (Fig. 44 Sankey) — VC-09 inside one document. | report |
| W2-N15 | **Missing element found:** ISRU LH₂/LOX Earth-return capsule (SEL-TRANSPORT-001C, "LH₂ transport v4"), SPA→Earth batch payload P5–P8, superseded by mass drivers at P9 (Fig. 54; value chain v14.1 "Starship return P7–P9"). Absent from `ARCHITECTURE_BASELINE.md` §5. **Ruled 14 Sep 2026: SPA→Earth returns are Starship flights.** Modelled as `StarshipReturnLink` from P5; its `retiredIn` is *derived* in the configuration as `massDriverNetwork.md4.operationalFrom` (currently P11), so the P9–P11 gap closes and the Fig. 54 "superseded at P9" label is moot. First element whose phase is computed from another element rather than read from a document. | `Transport.sysml`, `ProgrammeConfiguration.sysml` |
| W2-N16 | `SEL_FINAL_REPORT_v4` Fig. 3 caption expands CLP = "central logistics point (one at crater rim and one at floor)" and CAP = "crew access point (rim and floor)"; fleet v9 §13.5 has CAP = "Crater Access Pod". Both expansions now in the model docs; a rim CLP element added (`RimLogisticsPoint`). | `PsrNetwork.sysml` |
| W2-N18 | PSR MOLE-I capacity: fleet v9 §4.1 and Strategy v3.1 §4.4 "~310 MOLE-I positions (~8.5 km² usable floor, 62 substations)"; Strategy v3.1 §4.3 "62 junctions (620 MOLE-I max)"; final report Fig. 12 (VISUALIZE v3.3) "124 nodes (620 MOLE-I) in 33.2 km² floor"; Fig. 11 "~17.5 km² feasible". One document (Strategy) carries both 310 and 620. This cap drives the Mk III transition gate (DG-11.6). **Bound at Wave 3:** `ProgrammeParameters.psrMoleICapacityUnits = 620` (124 nodes × 5 from `psr_layout.py`, SEL-REQ-016); the ECON MOLE-I peak of 357 never exceeds it, so the Mk III transition is not capacity-forced (W3-N2). | `Parameters.sysml` |
| W2-N19 | DG-13.2 has two meanings: Decision Framework Rev D §2 defines it as "C-type asteroid redirect initiated (Y95, executed during P12)", while the same document's P12 section says "Laser Ablation Truss (DG-13.2 concept, deployed Y85)" and fleet v9 §17.2 calls the truss method selection DG-13.2. Model carries the gate-list definition. | `Gates.sysml` |
| W2-N20 | Decision Framework Rev D carries three SPA MSR commissioning gates (DG-10.5 Y50, DG-11.3 Y70, DG-13.4 Y105 "#1") plus #2 (DG-14.4 Y125) and #3 (DG-14.7 Y140); Strategy v3.1 §12.1 says "from Y50" and §5.1 "from Y105". Confirms F5 as a genuinely undecided item, now demand-gated. | `Gates.sysml`, `Power.sysml` |
| W2-N17 | **Missing element found:** SPA mass driver demonstrator / test track (ECN-020 §5 "Demo" 23 t YBCO; report Fig. 27 "mass driver prototype on crater rim, P9 test track 100 m → 500 m at P9–P10", listed under Key P7 additions; baseline P7 "YBCO for MD-1 delivered"). Added as `MassDriverDemonstrator`, bound P7; P9–P10 wording recorded. | `Transport.sysml` |

## Wave 3 observations
W3-N1 … W3-N20 (Decision Framework gate years versus the ECON ramp, gates
never met on current vectors, the 308-circuit batch count, the canister
payload 3.5 vs 3.6 t, the demonstrator location, the Fig. 2 milestone proxy,
VERIFY element vectors versus definitions) are tabled in
`CHANGELOG_WAVE3.md` §5; the machine-generated register is
`docs/PLAN_REGISTER.md`.

## Conflicts already resolved by the rule
- Temporary commissioning crew at PKT (3–4, P8, 6–12 months) **is** baseline;
  the older "no temporary crews, ever" scope text is superseded. Zero
  *permanent* crew still holds.
- YBCO lifetime total **523 t** (ECN-020), not 303 t (scope P14, value chain v15).
- Canister cadence **~694,444/yr** (ECN-020), not 285,715.
- Steady state **2.5 Mt/yr at ~Y180** (P14+), not 1 Mt/yr at Y100 (P12).
- Catapults never carry ore; steel apron conveyors do. No SKIPs at PKT, ever.
