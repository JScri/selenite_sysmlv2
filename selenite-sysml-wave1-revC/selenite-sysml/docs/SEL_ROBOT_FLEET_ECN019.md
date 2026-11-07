<!-- Markdown extract of docs/sources/SEL_ROBOT_FLEET_ECN019.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

# SELENITE PROGRAMME
## ECN-019 Amendment to SEL_ROBOT_FLEET v8
Programme-Wide Fleet Revision: SKIP Retirement · Demand-Driven MOLE-I · PROBE Mk III SEP · Hauler Mining Capability · Conveyor Replacement of Catapults · Base Specialisation · Construction Fleet Scaling
Reference: ECN-019 Rev C, SEL-DECISION-001 Rev C, SEL-ECON-001 Rev A, SEL-HAULER-001 Rev B, SELENITE_SCALE v1.3 (corrected). April 2026.
This amendment supersedes ECN-016 §1 (SKIP phase-out), §4 (hauler in-situ fraction), §5 (EM catapult scaling), §7 (fleet summary table), and ECN-017 addendum in their entirety. ECN-016 §2 (MOLE-I Mk II drill retrofit) and §3 (PROBE Mk II) are retained with modifications noted below.

## 1. SKIP — Retirement Timeline and Architectural Correction
### 1.1 Operational Scope
SKIPs operate at SPA ONLY. Operating range: 100 km sub-orbital hop from Shackleton to SPA Basin KREEP exposures. 8 units through P7–P8. SKIPs were NEVER deployed to PKT — the old SEL-PROC-PKT-001 §3 reference to “PKT SKIPs” was an architectural error. PKT is 3,300 km from SPA, reachable only via DART’s LLO orbital transfer or mass driver. Sub-orbital hops cannot reach PKT from SPA at any physically achievable propellant budget.
NO SKIPs AT PKT — EVER.
### 1.2 Revised Phase-Out Schedule
| Phase | SPA SKIPs | Status | Notes |
|---|---|---|---|
| P3–P6 | 1→1→2→4 | Operational | SPA Basin KREEP collection, SURVEY-targeted sites |
| P7 | 8 | Operational (peak fleet) | Last expansion. 877 t/yr raw KREEP to SPA beneficiation. Propellant demand: ~664 t/yr (58 MOLE-I equivalent). |
| P8 | 8 | Operational (continuing) | SPA KREEP research continues while PKT ramps to 125 t/yr REO from 308 circuits. |
| P9 | 0 | Retired | PKT produces 1,000 t/yr REO from 2,500 circuits — far exceeding SPA’s 5-circuit research output of 0.4 t/yr. SKIP propellant freed for growing PROBE fleet. |
| P10+ | 0 | Decommissioned | Pads repurposed. Heritage retained for nav/landing systems. |

### 1.3 ECN-016 §1 Corrections
ECN-016 §1 specified 3,559 chemical SKIPs at PKT (P8) and 28,509 at PKT (P9). These figures are eliminated. They were driven by the erroneous assumption that KREEP ore transport at PKT would use chemical sub-orbital hops. PKT surface operations use mining-capable haulers (SEL-HAULER-001 Rev B) from P8 day one. Chemical propulsion is not used for any PKT surface transport at any phase.

## 2. MOLE-I Fleet Scaling — Demand-Driven (Replaces Exponential Model)
### 2.1 Correction from Previous Architecture
Previous SELENITE_SCALE v1.3 specified MOLE-I counts of 48,990 (P8) and 390,790 (P9). These figures were driven by propellant demand for chemical tanker flights from SPA to PKT to fuel PKT-based SKIPs. This architecture is eliminated by ECN-019: mass driver at P8 replaces chemical tanker transport, and no SKIPs operate at PKT.
Additionally, the Shackleton crater floor physically accommodates ~310 MOLE-I (~62 substations on ~8.5 km² usable flat area, accounting for central mound, landslides, and boulder fields occupying ~50% of the 34.2 km² floor). The P9 figure of 390,790 exceeds total south pole PSR capacity by ~10× and was never physically achievable.
Old figures (48,990/390,790) were driven by chemical tanker flights SPA→PKT to fuel PKT-based SKIPs. This architecture is eliminated by ECN-019 (mass driver at P8, no SKIPs at PKT).
### 2.2 Revised MOLE-I Scaling Table
Each MOLE-I produces 5,692 kg/yr propellant (7,818 kg/yr water × 0.722 electrolysis efficiency). Each PROBE mission consumes 6,654 kg propellant. PROBE equivalence: 0.855 PROBE missions per MOLE-I per year.
| Phase | Years | MOLE-I | PROBE fleet | SKIP fleet | Other demand | Supply (t/yr) | Demand (t/yr) | Margin |
|---|---|---|---|---|---|---|---|---|
| P3 | Y4–7 | 10 | 3 | 1 | Stockpile | 56.9 | ~0 | Stockpile |
| P4 | Y7–9 | 25 | 6 | 1 | Crew arrival | 142.3 | 124.1 | +14.7% |
| P5 | Y9–12 | 50 | 10 | 2 | DART + crew | 284.6 | 237.9 | +19.6% |
| P6 | Y12–15 | 85 | 15 | 4 | Crew rotation | 483.8 | 433.8 | +11.5% |
| P7 | Y18–25 | 170 | 30 | 8 (SPA) | DART + crew | 968 | 868 | +11.5% |
| P8 | Y25–35 | ~247 | 96 | 8 (continuing) | Crew only | 1,406 | 1,403 | +0.2% |
| P9 | Y35–45 | ~240 | ~190 | 0 (retired) | Crew only | 1,367 | 1,364 | +0.2% |
| P10 | Y45–60 | ~280 | ~230 | 0 | Crew only | 1,594 | 1,630 | −2.3% |
| P11 | Y60–80 | ~320 | ~260 Mk I/II (phasing down) | 0 | Crew only | 1,822 | 1,830 | −0.4% |
| P12 | Y80–100 | ~355 | 286 Mk I/II (peak, then phasedown) | 0 | Crew only | 2,021 | 2,023 | −0.1% |
| Y85+ | Y85+ | ~50 | 30 Mk I/II only (Mk III uses zero ISRU propellant) | 0 | Crew ECLSS | ~285 | ~300 | C-type water supplements |

### 2.3 Demand Drivers
- PROBE propellant (6,654 kg/mission): Primary demand driver P3–P12. Mk III SEP (P11+) uses ion propulsion (xenon/argon, NOT ISRU LH₂/LOX) — eliminates ISRU demand for bulk PROBE operations.
- SKIP propellant (664 t/yr for 8 units): Significant demand P7–P8 only. Retired at P9.
- Crew rotation (~100 t/yr): Constant from P4+.
- ECLSS (~3 t/yr): Constant from P4+.
- DART propellant: Zero from P8 onward — DART operates at PKT on surface power, delivered by mass driver.
### 2.4 Spatial Constraints
- Maximum ~355 MOLE-I at Shackleton crater (~310 positions on ~8.5 km² usable floor)
- Optional de Gerlache extension (~45 units, 5–10 km via Connecting Ridge) if ice fraction is at conservative 4.46% design point
- At LCROSS-measured 5.6%+, Shackleton alone is sufficient
- De Gerlache expansion beyond ~400 MOLE-I is a P13+ decision gate only if PROBE fleet exceeds ~370 units (rendered moot by Mk III transition)
### 2.5 Economic Impact of Correction
| Item | Old architecture (SCALE v1.3) | New architecture | Saving |
|---|---|---|---|
| P8 MOLE-I | 48,990 units × 360 kg = 17,636 t | ~77 new units × 360 kg = 28 t | ~$70B |
| P9 MOLE-I | 341,800 units × 360 kg = 123,048 t | 0 new (SKIP retirement frees capacity) | ~$492B |
| P9 substations | ~68,360 nodes | ~14 new nodes | ~$37B |
| P9 FSP (for MOLE-I power) | ~9,851 FSP | ~0 additional | ~$200B |
| Multi-crater infrastructure | 7+ craters | Shackleton only (+ de Gerlache P13+ if needed) | ~$50B+ |
| Total saving |  |  | ~$850B |

## 3. MOLE-S — SPA-Only Deployment Constraint
MOLE-S deploys to SPA ONLY. Not deployed to PKT under any circumstance. At PKT, all excavation, grading, trenching, and material handling is performed by mining-capable haulers (SEL-HAULER-001 Rev B).
MOLE-S roles remain unchanged at SPA: - Crater rim construction support - Surface regolith supply to SINTER - Site levelling and landing pad preparation - Surface staging operations
Fleet count unchanged: 4 (P3) → 6 (P7+) at SPA. No scaling beyond 6 units required — SPA construction demand is modest and steady.

## 4. Surface Hauler — SEL-HAULER-001 Rev B Reference
### 4.1 Key Changes from Rev A
The Surface Hauler is redesigned per ECN-019 for in-situ manufacturability and mining capability:
| Parameter | Rev A | Rev B (ECN-019) |
|---|---|---|
| Dry mass | ~1,200 kg | ~1,450 kg |
| Battery | 200 kg Li-ion, 50 kWh | ~300 kg Na-S, 50 kWh, 300–350°C operating |
| Motors | 4× SmCo BLDC hub motors | 4× SRM (switched reluctance), Fe-Si laminations, Al windings |
| Mining capability | None — hauler transport only | Front bucket/blade mechanism (~150 kg), self-load 5 t KREEP in ~25 min |
| Introduction | P10 | P8 |
| In-situ fraction | 92% | ~57% |
| Operating modes | Transport only | Mine mode (200 kg/min loose regolith), Grade mode (blade, 0.3 m/s), Trench mode (deeper bucket passes), Transport mode |

### 4.2 Operational Role at PKT
Replaces both SKIP and MOLE-S at PKT. One vehicle class handles all PKT surface operations. From P8 day one: - Mining: Self-load 5 t KREEP regolith (~25 min dig cycle) via front bucket/blade - Transport: Drive loaded to processing spine at 0.8–1.0 m/s on sintered road (0.3 m/s off-road initially) - Grading: Blade-down terrain preparation for SINTER road construction - Trenching: Deeper bucket passes for utility conduit installation - SINTER supply: Deliver regolith to SINTER input hoppers
### 4.3 Fleet Scaling (Revised from ECN-016)
| Phase | Haulers | Introduction | Notes |
|---|---|---|---|
| P7 | 0 | — | Not yet deployed |
| P8 | 200 | Y25 | First deployment — Earth-built, off-road initially |
| P9 | 1,000+ | Y35 | Foundry starts producing in-situ fraction |
| P10 | 14,881 | Y45 | ~57% in-situ manufacture |
| P11 | 148,810 | Y60 | Full industrial scale |
| P12 | 1,488,096 | Y80 | 2.5 Mt/yr REO steady state target |
| P14+ SS | ~1,500,000 | Y180 | Maintenance replacement only |

### 4.4 Canister Return
Empty canisters are NOT returned by hauler or catapult. Steel apron conveyors (§6) handle all Tier 3 transport including canister logistics. Haulers operate mine-to-hub and mine-to-spine only.
Full specification: SEL-HAULER-001 Rev B.

## 5. EM Catapult — Superseded for Ore Transport
### 5.1 Status
SEL-CATAPULT-001 Rev A is SUPERSEDED for ore transport. The 9,084 ore catapult hubs specified in ECN-016/ECN-017 are eliminated entirely. YBCO (YBa₂Cu₃O₇) requires copper at 286 g per kg; lunar Cu availability (~15 ppm basalt, ~100–300 ppm meteoritic) cannot support 209,000 t YBCO for ore catapults. Annual YBCO import cost: ~$12B/yr at P12 — unjustifiable when a 95% in-situ alternative exists.
### 5.2 Replacement: Steel Apron Conveyor Network
All Tier 3 ore transport (50–150 km) replaced by steel apron conveyors — interlocking Fe-Ni steel pans on roller chains. Zero YBCO, zero copper, zero carbon. ~95% in-situ manufactured from asteroid Fe-Ni + MRE iron/silicon/aluminium.
| Parameter | EM Catapult (superseded) | Steel Conveyor (baseline) |
|---|---|---|
| Total infrastructure (P12) | ~1.82 Mt | ~7–9 Mt |
| Annual Earth import | ~6,140 t/yr (~61 flights) | ~300–430 t/yr (~3–4 flights) |
| YBCO required | ~209,000 t | 0 |
| Continuous power | ~13.6 GW | ~0.44 GW |
| In-situ fraction | ~0% of critical components | ~95–97% |

Conveyor network topology: dendritic (trunk + branch), ~87,500 km total at P12. ~500 trunk lines averaging 75 km + ~5,000 branches averaging 10 km. Drive stations (SRM, Fe-Si + Al, in-situ) every 1–2 km. MoS₂ lubricated rollers.
New document required: SEL-CONVEYOR-001 Rev A.
### 5.3 Mass Driver Heritage Retained
EM catapult coilgun technology is retained as heritage for the programme’s 5 mass drivers (see SEL-DECISION-001 Rev C §3). One catapult demonstrator hub at P8 (~23 t YBCO, 500 m/s) validates coilgun physics before committing to escape-velocity mass drivers.
Total programme YBCO: ~280 t lifetime (5 mass drivers + 1 demonstrator) — vs 209,000 t for 9,084 catapult hubs. 99.9% reduction.

## 6. PROBE Fleet Lifecycle — Mk I / Mk II / Mk III Classification
### 6.1 Mk Classification Table
| Class | Era | Fleet size | Propulsion | Lands on Moon? | Missions/yr | Role |
|---|---|---|---|---|---|---|
| Mk I | P5–P8 | 30→96 | Chemical (LH₂/LOX) | Yes (SPA IZ collars) | 1 | Basic scraper collection. 1,500 kg Fe-Ni/PGM per mission. |
| Mk II Heavy | P9–P11 | 190→260 | Chemical (LH₂/LOX) | Yes (SPA IZ collars) | 1 | In-situ beneficiation on asteroid (500 t processed, 10 t returned). ~17.5 kg PGM per mission. |
| Mk I/II phasedown | P11+ | 260→50→30 | Chemical | Yes | 1 | Specialist SPA short-range ops only. |
| Mk III SEP | P11+ | 0→1,714→300 | Ion (xenon/argon) | NEVER | 0.5 | Bulk remote mining → prospecting after all captures complete |

### 6.2 Mk III SEP Architecture (DG-11.6)
- Ion propulsion (xenon/argon from asteroid volatiles or Earth supply). ~1,200 kg dry. Larger solar arrays than Mk I/II (no landing loads, no dust exposure).
- Never lands on the Moon. Stays in orbit permanently. Ejects 10 t Fe-Ni/PGM payload canisters from LLO on ballistic deorbit trajectory.
- EM catcher at SPA receives canisters at ~1,680 m/s — same YBCO coil technology as mass drivers, run in reverse. The PKT→SPA mass driver receiver (built P9–P10 for ThCl₄ delivery) serves double duty.
- Canister: Fe-Ni shell (ferromagnetic, compatible with EM braking) + small cold-gas kick motor (~5–10 kg) for trajectory shaping.
- Electromagnetic anchoring on M-type asteroids: Fe-Ni surface is ferromagnetic → powered electromagnet pads, no harpoons or drills. Attachment force enormous relative to ~0.0001 m/s² surface gravity. Heritage: Northrop Grumman MEV-1 (2020).
- Operational sequence: (1) Ion thrust transit 3–8 months. (2) Velocity matching to cm/s. (3) LiDAR surface mapping at 100 m. (4) Terminal approach at 2–5 cm/s. (5) EM anchor engagement (3–4 pads). (6) Scraper mining 6–12 months. (7) Disengage (cut current), cold-gas separation, ion return.
### 6.3 Fleet Phasedown
| Year range | Mk I/II fleet | Mk III fleet | MOLE-I needed | Notes |
|---|---|---|---|---|
| Y45 (P10) | 230 | 0 | ~280 | Peak chemical PROBE demand |
| Y60–Y80 (P11) | 260→50 | 0→1,714 (~86/yr) | 320→190 | Mk III build-out, Mk I/II phasedown |
| Y85 | 30 | ~1,714 | ~50 | Mk III at full scale; chemical fleet minimal |
| Y115+ | 30 | 1,714→300 | ~50 | All 3 asteroid captures complete; Mk III reduces to prospecting only |

Decommissioned Mk I/II units salvaged at SPA — Fe-Ni frames, motors, electronics recycled (~184 t recovered). Salvage operation performed by ARM at IZ.
### 6.4 Mk III Propellant Impact
Mk III uses zero ISRU propellant (ion drive, xenon/argon). This is the key architectural change: MOLE-I fleet drops from ~355 (peak at P12 under all-chemical architecture) to ~50 from Y85, irrespective of Mk III fleet size. The ~50 remaining MOLE-I serve crew ECLSS and the 30-unit Mk I/II specialist fleet only.
C-type asteroid water (from Y105, DG-14.1) further supplements propellant supply, potentially eliminating MOLE-I demand entirely except for crew consumables.
### 6.5 Captured Asteroids vs PROBEs
Captured asteroids do NOT use PROBEs. They have dedicated permanent infrastructure: - Laser Ablation Truss: Linear rigid truss with dual laser heads, ~350 MW, 1,000 t/day throughput. Surface ablation in spiral pattern. No mechanical contact. Ejecta captured by electrostatic/magnetic collectors. Heritage: DE-STAR programme (Lubin, UCSB). - Mass driver (MD-5, DRO→SPA): ~800 m/s, ~500 m track, ~30 t YBCO. Delivers asteroid concentrate to SPA EM catcher.
PROBEs are for remote uncaptured asteroids only. The two systems are architecturally independent.
### 6.6 ECN-016 §3 (PROBE Mk II) Status
ECN-016 §3 PROBE Mk II specification is retained but reclassified as “Mk II Heavy” within the lifecycle framework above. Key correction: ECN-016 specified 286 Mk II PROBEs at P12 delivering ~5 t/yr PGM. Under ECN-019 Rev C, the Mk II fleet peaks at 260 (not 286) and begins phasedown at P11 as Mk III takes over bulk operations. The 286 figure in ECN-016 §7 fleet summary is superseded.

## 7. Processing Circuit Note
The programme commits to an optimised continuous-flow processing circuit design:
| Parameter | Specification |
|---|---|
| REO throughput | 1.2 t/yr per circuit |
| Circuit mass | 28,000 kg |
| Power draw | 400 kW |
| Circuits for 2.5 Mt/yr | 2,083,334 |
| Maintenance rate | 0.5% of mass/yr as Earth-sourced spares |

This reduces total circuit count from 6.25M (batch at 0.4 t/yr) to 2.08M for the 2.5 Mt/yr target. R&D into circuit throughput optimisation is the single highest-value investment the programme can make ($22T cost reduction over 200 years vs batch design).
Decision gate DG-8.X: Circuit throughput validation — target ≥1.0 t/yr REO per circuit before committing to full-scale PKT build-out.

## 8. Construction Fleet Scaling (New)
Construction fleet scales with circuit build rate and total circuit count:
| Vehicle | Scales with | Unit mass | Replacement cycle | Notes |
|---|---|---|---|---|
| ARM-C (assembly) | 1 per 500 circuits/yr build rate | 1,500 kg | 10-yr life | Circuit installation at PKT |
| SINTER (construction) | 1 per 200 circuits/yr build rate | 2,200 kg | 15-yr life | Road, pad, enclosure construction |
| SENTINEL (monitoring) | 1 per 500 circuits total | 80 kg | 10-yr life | Circuit + infrastructure monitoring |
| Charging hubs | 1 per 100 haulers | 5,000 kg (95% in-situ) | Long life | Na-S battery charging infrastructure |

Steady-state minimum fleet (P14+ maintenance only): ~20 ARM-C, ~50 SINTER, SENTINEL scales with circuit count. Construction fleet cargo: ~0.3% of total Earth cargo.

## 9. Revised Fleet Summary Table (Supersedes ECN-016 §7)
| Vehicle | P7 | P8 | P9 | P10 | P11 | P12 | P14+ SS | Notes |
|---|---|---|---|---|---|---|---|---|
| PROBE Mk I | 30 | 96 | 30 | 30 | — | — | — | Phased to Mk II at P9 |
| PROBE Mk II Heavy | — | — | 190 | 230 | 260→50 | 30 | 30 | Phasedown during P11 |
| PROBE Mk III SEP | — | — | — | — | 0→1,714 | 1,714 | 300 | Ion; never lands; EM anchoring |
| SKIP (SPA only) | 8 | 8 | 0 | 0 | 0 | 0 | 0 | Retired P9 — NO PKT SKIPs EVER |
| MOLE-I | 170 | ~247 | ~240 | ~280 | 320→50 | ~50 | ~50 | Demand-driven; drops at Mk III transition |
| MOLE-S (SPA only) | 6 | 6 | 6 | 6 | 6 | 6 | 6 | SPA only — not at PKT |
| Hauler (PKT only) | 0 | 200 | 1,000+ | 14,881 | 148,810 | 1,488,096 | ~1,500,000 | Mining-capable, Na-S, SRM |
| Conveyor (PKT, km) | 0 | 0 | 500 | 5,000+ | 15,000 | 87,500 | ~87,500 | Replaces catapults |
| DART | 1 | 1 | 1 | 1 | 1 | 1 | 1 | Recon only |
| SINTER | 3+ | 20+ | 30+ | 50+ | 100+ | 200+ | ~50 | Scales with construction rate |
| ARM-C/D | 8 | 15+ | 30+ | 50+ | 100+ | 200+ | ~20 | IZ + PKT construction + maintenance |
| SENTINEL | 4+ | 10+ | 20+ | 50+ | 200+ | 4,000+ | maint | 1 per 500 circuits |
| SURVEY | 2 | 2 | 2 | 2 | 2 | 2 | 2 | SPA + orbital |
| Redirect tug | — | — | — | — | 2 | 3–5 | 5 | Asteroid capture SEP/NEP |
| Laser Ablation Truss | — | — | — | — | — | 1 | 1–3 | DRO, per captured asteroid |

## 10. ECN-016 Disposition
| ECN-016 Section | Status | Disposition |
|---|---|---|
| §1 SKIP Phase-Out | SUPERSEDED | Replaced by ECN-019 §1 above. PKT SKIPs eliminated entirely. SPA SKIPs retire at P9 (not P10). |
| §2 MOLE-I Mk II | Retained | Drill retrofit specification unchanged. Rollover schedule adjusted: P8–P9 as specified. |
| §3 PROBE Mk II | Modified | Reclassified as “Mk II Heavy” within Mk I/II/III lifecycle (ECN-019 §6). Peak fleet revised from 286 to 260. Phasedown at P11 (not indefinite scaling). |
| §4 Hauler (in-situ fraction) | SUPERSEDED | In-situ fraction revised from 92% to ~57%. Na-S battery (not Li-ion), SRM motors (not SmCo BLDC). See SEL-HAULER-001 Rev B. |
| §5 EM Catapult | SUPERSEDED | Catapults eliminated for ore transport. Replaced by steel conveyors. See ECN-019 §5 above. |
| §6 Asteroid Capture | Modified | Retained with revisions: diversified captures (M/C/S-type, not multiple M-types), laser ablation truss (not orbital refinery platform), tugs ~50,000 kg (not ~2,000 kg). See SEL-DECISION-001 Rev C. |
| §7 Fleet Summary | SUPERSEDED | Replaced by ECN-019 §9 above. |
| ECN-017 Addendum | SUPERSEDED | 92% in-situ fraction and catapult scaling eliminated. |

— End of ECN-019 Amendment to SEL_ROBOT_FLEET v8 —