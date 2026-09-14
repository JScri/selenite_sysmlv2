# SELENITE PROGRAMME — Decision Framework & Manufacturing Strategy

**SEL-DECISION-001 Rev D | April 2026 | DRAFT**

**References:** All updated_ prefix docs (ECN-012 through ECN-017 applied), ECN-019 Rev C (programme-wide design revision including 2.5 Mt/yr target, optimised circuits, PROBE Mk III, base specialisation, diversified asteroids, laser ablation truss, environmental accounting, construction fleet scaling), SEL-ECON-001 Rev A (economic evaluation report, SELENITE_ECON v1.3/v1.4), all robot design specs (Rev A), SEL-HAULER-001 Rev B, SEL-CATAPULT-001 Rev A (superseded for ore transport), selenite_extended_timeline_v2.html, SELENITE_SCALE v1.3 (corrected), programme scope doc.

**Changes from Rev C:** PKT base positioning principle added: processing spine at PKT boundary, MSR/foundry on non-KREEP side, ore area maximised. Resource adequacy analysis: ~1–3 Bt total KREEP REE, ~220–660 Mt accessible to 200 m depth at PKT, ~88–264 years at 2.5 Mt/yr from Y180. Tiered depth mining architecture (Tier 1: 0–20 m, Tier 2: 20–100 m, Tier 3: 100–200 m) with relocatable relay depots and swappable hauler attachments. Post-P14 decision gates DG-POST.1/POST.2 for depth transitions. "225,000+ years" reserve life corrected to 400–1,300 years (prior figure derived from debunked 225–450 Bt total KREEP REE claim; corrected to ~1–3 Bt at 300–500 ppm in 5–9% lunar mass KREEP layer). ECON 500 ppm grade clarified as DART-selected site / post-beneficiation concentrate (bulk PKT regolith 50–200 ppm). Open items updated: SEL-HAULER-001 Rev B, PKT boundary site selection criteria.

---

## 1. Eight critical transitions to self-sufficiency

| # | Transition | Phase | What it eliminates |
|---|-----------|-------|--------------------|
| 1 | Propellant ISRU | P3 (Y5) | Earth-supplied LH₂/LOX |
| 2 | Sintered construction | P2–P3 (Y4–7) | Imported structural materials for hab/roads/pads |
| 3 | Reagent self-sufficiency | P5–P10 (Y9–55) | H₂SO₄ from troilite, Ca(OH)₂ from anorthite → 98% in-situ |
| 4 | D2EHPA elimination | P7 (Y15) | ALL organic solvent extraction — split value chain replaces SX |
| 5 | In-situ fabrication | P10 (Y45) | Earth-launched haulers, canisters, infrastructure → 55–60% in-situ |
| 6 | Uranium → thorium MSR | P9–P10 (Y35–55) | HALEU fuel imports → self-breeding Th cycle from KREEP waste |
| 7 | Propulsive → EM logistics + conveyor | P8–P10 (Y25–55) | Chemical propulsion for transport → mass drivers (5 baseline) + steel conveyor network |
| 8 | Asteroid material independence | P12–P14 (Y85–Y180) | Earth-sourced polymers, silicon, copper → C-type and S-type asteroid resources; circuit Earth frac 10%→0.8% |

---

## 2. Phase-by-phase decision gates

### P0 — Pre-deployment (Y0–Y3)

**Gates:** DG-0.1 Programme GO. DG-0.2 Relay architecture. DG-0.3 Robot fleet design freeze. DG-0.4 FSP spec lock.

**Manufacturing: 100% Earth.** All robots, hab modules, ISRU plant, solar arrays, FSP units, relay satellites Earth-built and launched.

---

### P1–P3 — Launch, construction, early ISRU (Y2–Y7)

**Gates:**
- DG-1.1 (Y2): Relay validated → cargo launch clearance
- DG-2.1 (Y4): MOLE-I extraction rate ≥5,692 kg/yr/unit confirmed
- DG-2.2 (Y5): ISRU loop closed → SKIP first hop cleared (M70)
- DG-3.1 (Y5.5): SENTINEL structural sweep → hab pressurisation cleared
- DG-3.2 (Y6): ISRU steady state → PROBE fleet ISRU-fuelled (>70%)

**Manufacturing: 100% Earth hardware + sintered regolith construction.** SINTER produces hab shells, radiation shielding, landing pads, roadways from bulk regolith. All mechanisms, electronics, pressure vessels, solar cells, thermal hardware Earth-supplied.

**Earth logistics:** ~5 cargo Starship flights over P1–P3 delivering initial fleet (~140 t robots + ~60 t ISRU/solar + ~40 t hab modules + spares).

---

### P4 — Crew arrival (Y7–Y9)

**Gates:**
- DG-4.1 (Y7): SENTINEL crew sign-off → crew launch authorised
- DG-4.2 (Y7): Life support commissioning (3–4 weeks)
- DG-4.3 (Y8): PROBE fleet fully ISRU-fuelled

**Manufacturing: unchanged.** Crew enables EVA maintenance but no fabrication capability. MOLE-I to 24, PROBE to 6. Solar to ~1,218 m² (346 kW).

**Earth logistics:** ~4 cargo + 2 crew flights over P4.

---

### P5 — Fleet expansion + first exports (Y9–Y12)

**Gates:**
- DG-5.1 (Y9): DART first PKT mission via LLO (M127)
- DG-5.2 (Y10): Beneficiation online (M105)
- **DG-5.3 (Y10): Troilite H₂SO₄ pilot commissioned (M115)** — first in-situ chemical production. 5,000 kg pilot equipment, 50 kW, 1–5 t/yr H₂SO₄.
- DG-5.4 (Y10): First export batch dispatched (M116)

**Manufacturing: first in-situ chemistry (pilot H₂SO₄).** All hardware still Earth-supplied. MOLE-I to 47, PROBE to 10, SKIP to 2.

**Earth logistics:** ~6 cargo + 2 crew flights over P5. Reagent pilot package (5,000 kg) on Cargo Launch 4.

---

### P6 — Processing commissioning (Y12–Y15)

**Gates:**
- **DG-6.1 (Y12): Processing facility commissioning readiness review** — NOTE: per ECN-015, the Y12 processing gate is RETIRED. Processing is a core programme element, not conditional. This review confirms readiness, it does not decide whether to build.
- DG-6.2 (Y12): Ca(OH)₂ pilot commissioned (2,500 kg, 30 kW) → NaOH substitution validated
- DG-6.3 (Y13–14): DART PKT missions 2–3 → PKT grade confirmation
- DG-6.4 (Y12): Crew-1 rotation begins (staggered 4× swaps, M136–M145)

**Manufacturing: reagent pilots operational.** H₂SO₄ at ~10 t/yr, Ca(OH)₂ at ~5–10 t/yr. Processing facility construction begins. All processing equipment Earth-supplied.

**Earth logistics:** ~6 cargo + 2 crew flights. Processing facility prefab on Cargo Launch 5 (~Y13).

---

### P7 — Proof of concept (Y18–Y25)

**Gates:**
- **DG-7.1 (Y20): PKT base commitment** — requires DART XRF from ≥3 PKT sites confirming ≥200 ppm REE + 5-circuit processing facility producing ≥0.4 t/yr REO
- **DG-7.2 (Y20): Thorium recovery begins** — 300°C acid bake ThP₂O₇ mechanism automatically separates Th from REE. Th(OH)₄ stockpiled for future MSR fuel. U separated by oxidation + pH 6.5 precipitation. Zero additional reagents needed.
- **DG-7.3 (Y20): PGM source comparison** — DART/SURVEY data vs actual PROBE returns. If lunar >10 g/t → third-base study. If <5 g/t → asteroid only.
- DG-7.4 (Y22): Progressive reagent substitution at SPA (10% → 50% in-situ H₂SO₄, Ca(OH)₂ replaces NaOH)
- **DG-7.5 (~2040): Thorium MSR decision** — commit only if terrestrial MSR demonstrates sustained BR >1.0

**Manufacturing: chemical production operational, Th recovery begins, hardware 100% Earth.** Processing flowsheet uses NO D2EHPA — split value chain (group separation on Moon, Earth final SX). Ce oxidation, Eu reduction, double sulfate LREE/HREE split — all zero-carbon. Optional EDTA chromatography polish (~200–500 kg imported, recyclable).

P7 end-state: 170 MOLE-I, 30 PROBE Mk I, 8 SKIP, 5 circuits, 12–20 crew, 0.4 t/yr REO. **Last phase with SKIP chemical transport for SPA KREEP research.** 170 MOLE-I provides 968 t/yr propellant against 868 t/yr demand (PROBE + SKIP + DART prospecting + crew). Mass driver YBCO (~60 t for SPA→PKT) must be delivered during P7 for P8 commissioning.

**Earth logistics:** ~12 cargo + 2 crew flights over P7. ~60 t/yr reagent (50% in-situ by end).

---

### P8 — Mass driver + PKT base online (Y25–Y35)

**No SKIPs at PKT — ever. No MOLE-S at PKT.** Haulers (with front bucket/blade, ~1,450 kg dry) handle ALL PKT surface operations: mining (self-load 5 t KREEP in ~25 min), transport, grading, trenching, foundation prep, and SINTER regolith supply. One vehicle class replaces both SKIP and MOLE-S at PKT. Haulers operate off-road at 0.3 m/s from P8 day one, improving to 1.0 m/s as SINTER builds roads. MOLE-S remains SPA-only (crater rim construction).

**Mass driver TRL at P8 (~Y25, ~2050):** EMALS operational on USS Gerald R. Ford since 2017 (TRL 9, 45 t at ~100 m/s). Linear induction maglev TRL 9 (Shanghai, Chuo Shinkansen). SPA→PKT at 1,800 m/s with 50g cargo acceleration requires ~3.3 km track. With ~30–60 t YBCO imported during P7 and 33 years of heritage development, TRL 7–8 by 2050 is defensible. Catapult demonstrator at P8 (500 m/s, shorter track) validates coilgun physics before committing to escape-velocity PKT→Earth driver at P9.

**Gates:**
- **DG-8.0 (Y25): SPA→PKT mass driver operational** — ~1,800 m/s, ~3.3 km track at SPA. Carries Fe-Ni from PROBE returns, Th(OH)₄, spares. ~30–60 t YBCO installed during P7. CRITICAL PATH ITEM.
- DG-8.1 (Y25): PKT construction begins — Wave 1 Starships deliver SINTER + haulers (w/ bucket) + ARM-C + FSP directly to PKT (Earth→PKT, NOT via SPA)
- DG-8.2 (Y27): First 100 processing circuits operational
- **DG-8.3 (Y25): PKT reagent plant commissioned** — 80 t, 500 kW, 85% self-sufficiency from day one
- DG-8.4 (Y26): First 50 haulers operational at PKT (Earth-built, off-road initially, Na-S battery, SRM motors)
- DG-8.5 (Y28): 308 processing circuits complete; 125 t/yr REO
- **DG-8.6 (Y28): PKT temporary commissioning crew arrives** — 3–4 specialists, 6–12 months (Wave 3). Tasks: commission foundry pilot, build MSR cold structure, tune processing circuits with real regolith. Crew departs before MSR fuel loading.
- DG-8.7 (Y30): Thorium stockpile assessment (~40 t Th(OH)₄ accumulated)
- **DG-8.8 (Y30): EM catapult demonstrator hub** — 500 m/s, ~23 t YBCO. Proving ground for PKT→Earth mass driver.
- DG-8.9 (Y32): First MSR cold structure complete. Fuel loading autonomous after crew departure. HALEU startup charge from Earth (sealed, shielded).
- **DG-8.X (Y28): Circuit throughput validation** — target ≥1.0 t/yr REO per circuit before committing to full-scale PKT build-out. Optimised continuous-flow design at 1.2 t/yr, 28,000 kg, 400 kW is the committed baseline. This is the single highest-value design decision in the programme ($22T cost reduction over 200 years vs batch at 0.4 t/yr).

**PKT construction manifest (Earth→PKT Starship delivery):**

| Wave | Years | Cargo | Mass (t) | Flights |
|------|-------|-------|----------|---------|
| 1 — Pioneer | Y25 | 20 SINTER, 10 haulers (w/ bucket/blade), 5 ARM-C, 2 SENTINEL, 4 FSP, reagent plant, beacons | ~200 | 2 |
| 2 — Processing | Y26–28 | 100 circuits, 36 FSP, 50 haulers, 4 charging hubs, spine conveyor, reagent (3 yr) | ~8,700 | 87 |
| 3 — Commissioning | Y28–30 | Crew hab, MSR vessels + turbomachinery, foundry pilot, catapult demo, 200 circuits, FSP, reagent (2 yr) | ~8,200 | 82 |
| 4 — Scale-up | Y30–35 | Remaining circuits, hauler expansion, MSR fuel loading equipment, HALEU, conveyor, reagent (5 yr) | ~12,900 | 129 |
| **P8 Total** | **Y25–35** | | **~30,000** | **~300** |

Average: ~3,000 t/yr = ~30 flights/yr. Peak: Y28–30 at ~41 flights/yr during commissioning.

**Manufacturing: in-situ reagents at PKT (85%); pilot foundry from Y28.** MOLE-I scales from 170 to ~247 (PROBE fleet triples to 96 while 8 SKIPs continue SPA KREEP collection). PROBE Mk I to 96. Haulers at PKT from Earth-build + emerging in-situ fraction. 125 t/yr REO by Y28.

**Earth logistics (revised):** ~3,000 t/yr average to PKT (30 flights/yr). Plus SPA steady-state (~12 cargo + 2 crew flights). Total P8 Earth logistics: ~3,200 t/yr = ~32 flights/yr average.

---

### P9 — Mass driver scaling + foundry ramp (Y35–Y45)

**Gates:**
- **DG-9.1 (Y35): PKT→Earth mass driver operational** — REO canisters at ~2,400 m/s. First exports by mass driver. **Canister recovery architecture decision (DG-10.3 from Rev A, brought forward):**
  - Option 1a: Full parachute (73 kg Earth content/canister)
  - Option 1b: Minimal drag chute + hardened canister (28 kg Earth/canister) ← **RECOMMENDED**
  - Option 2: Shuttlecock design, no fabric (8 kg Earth/canister) — requires impact survival validation
- DG-9.2 (Y38): Hauler fleet scaling at PKT — 1,000+ haulers operational
- **DG-9.3 (Y40): Thorium MSR first power** — if BR >1.0 confirmed, commit to fleet expansion
- DG-9.4 (Y42): PKT foundry at 100+ t/yr metal production (MRE + WAAM/EB welding)
- DG-9.5 (Y42): Oxalic acid pilot at PKT (CO₂ electroreduction)
- **DG-9.6 (Y43): PKT→SPA mass driver operational** — ThCl₄ fuel for SPA MSR
- DG-9.7 (Y40): Steel conveyor pilot — first 500 km trunk from Fe-Ni + MRE iron

**Manufacturing: reagents 90% in-situ; foundry operational; first haulers manufactured with in-situ fraction.** MOLE-I at ~240 (8 SKIPs retired — PKT's 2,500 circuits produce 1,000 t/yr REO, far exceeding SPA's 5-circuit research output of 0.4 t/yr; SKIP propellant freed for growing PROBE fleet). 2,500 circuits. 1,000 t/yr REO. Haulers increasingly in-situ manufactured (55–60%).

**Earth logistics:** ~8,000 t/yr new hardware (circuits, hauler Earth fraction, foundry expansion) + ~5,500 t/yr reagent + mass driver canister Earth components ramp. Total ~15,000 t/yr = ~150 flights/yr.

Note: previous architecture specified ~35,000 t/yr at P9, of which ~23,000 t/yr was MOLE-I + FSP for MOLE-I power. The 310 cap eliminates this.

---

### P10 — Full-scale operations (Y45–60)

**Gates:**
- **DG-10.1 (Y45): Hauler fleet at scale** — 14,881 mining-capable haulers (Na-S battery, SRM motors, bucket/blade, ~57% in-situ)
- **DG-10.2 (Y48): Steel conveyor network expanding** — 5,000+ km, replacing hauler Tier 3 routes (50–150 km), 95% in-situ manufactured
- **DG-10.3 (Y45): PKT foundry at industrial scale** — MRE cells, WAAM/EB welding, Fe-Si and Al production. 1,000+ t/yr formed metal.
- **DG-10.4 (Y50): Thorium MSR fleet expansion** — ~74 × 100 MWe units at PKT. Construction: temp crew builds cold structure, fuel loading autonomous.
- **DG-10.5 (Y50): SPA MSR commissioning** — ThCl₄ mass-driven from PKT. Enables scaled PROBE/PGM ops.

**Manufacturing: 55–65% in-situ by mass for new builds.**

| Item | In-situ % | In-situ source | Earth-supplied |
|------|-----------|----------------|----------------|
| Hauler (×14,881) | ~57% | Al frame, Fe-Si hopper + bucket, SRM laminations/windings, Na-S battery Na/S/Al₂O₃ | Avionics, BMS, bearings, motor electronics, actuators |
| Conveyor (5,000+ km) | 95% | Fe-Ni chain/pans, Fe-Si rollers, Al frames | Drive station electronics, bearings |
| Mass driver canisters | 85% | Fe-Ni shell, Al₂O₃/SiO₂ TPS | Drag chute, electronics |
| Processing enclosures | 50–70% | Sintered walls, steel framing | Acid-resistant linings, sensors, pumps |
| MSR shielding | 100% | Regolith fill | — |
| MSR vessels | 0% initially | — | Hastelloy-N from Earth (→ Ni-201 in-situ at P11+) |
| Roads | 100% | Sintered regolith | — |
| Reagents | 95% | Troilite H₂SO₄, anorthite Ca(OH)₂ | V₂O₅ catalyst, EDTA |

MOLE-I: ~280 (demand-driven by PROBE fleet ~230). PROBE Mk II: expanding toward 260. 25,000 circuits. 10,000 t/yr REO.

**Earth logistics:** ~12,000 t/yr (hauler spares + circuit parts + canister recovery + MSR vessels + foundry expansion). ~12,500 t/yr reagent. Total ~25,000 t/yr = ~250 flights/yr. Declining as in-situ fraction grows.

---

### P11 — 10% global displacement + PROBE Mk III transition (Y60–80)

**Gates:**
- DG-11.1 (Y60): 100,000 t/yr REO → market impact assessment
- DG-11.2 (Y65): Thorium MSR fleet at ~679 × 100 MWe. Annual Th consumption ~54 t/yr vs 387–773 t/yr production (massive surplus for stockpiling/SPA fuel).
- DG-11.3 (Y70): SPA MSR commissioning — ThCl₄ mass-driven from PKT. Enables scaled PGM processing.
- DG-11.4 (Y75): In-situ Ni-201 MSR vessels replace Hastelloy-N for new builds → reduces single largest specialty import.
- DG-11.5: Conveyor network scales to ~15,000 km
- **DG-11.6 (Y65–75): PROBE Mk III SEP commissioning + SPA→Earth mass driver for PGM exports.** Mk III architecture:
  - Ion propulsion (xenon/argon). ~1,200 kg dry. Never lands on the Moon — stays in orbit permanently.
  - Ejects 10 t Fe-Ni/PGM payload canisters from LLO on ballistic deorbit trajectory. EM catcher at SPA receives at ~1,680 m/s (same YBCO coil technology as mass drivers, run in reverse).
  - Electromagnetic anchoring on M-type asteroid Fe-Ni surface. No harpoons, no drills. Heritage: Northrop Grumman MEV-1 (2020).
  - Canister: Fe-Ni shell (ferromagnetic, compatible with EM braking) + small cold-gas kick motor (~5–10 kg) for trajectory shaping.
  - Build-out: ~86 Mk III/yr from Y60–Y80 → ~1,714 units for bulk operations. Reduces to ~300 after all asteroid captures complete (Y115+, prospecting only). 0.5 missions/yr per unit.
  - Mk I/II phasedown: 260→50 (Y60–Y80), then →30 (Y85+). Decommissioned units salvaged at SPA — Fe-Ni frames, motors, electronics recycled (~184 t recovered).
  - SPA→Earth mass driver triggered when PGM concentrate volume exceeds ~100 t/yr. Key driver: iridium demand for PEM electrolysers projected at 34+ t/yr by 2040 vs current global production of 7.5–9 t/yr. ~60 t YBCO for 4th mass driver.
- DG-11.7: PROBE fleet scaling — docking collars and ARM-D units at SPA IZ scale linearly with fleet growth (same 1:1 collar:ARM-D ratio established P3–P7). SPA IZ gantry rail extendable by design (SEL-CAD-IZ-001).
- **DG-11.8 (Y75): M-type asteroid redirect initiated** — SEP/NEP redirect tug (~50,000 kg, 2 units) captures ~200 m M-type asteroid and transfers to DRO. Does NOT consume ISRU propellant (xenon/krypton from Earth). Self-transfer via ion drive from LEO. Arrival Y85.

**PROBE Mk III propellant demand cascade:**

| Year | Mk I/II fleet | Chemical propellant demand | MOLE-I needed |
|------|---------------|---------------------------|---------------|
| Y45 | 230 | 1,530 t/yr | ~280 |
| Y70 | 150 | 998 t/yr | ~190 |
| Y85 | 30 | 200 t/yr | ~50 |
| Y110+ | 30 (C-type water supplements) | ~0 from lunar ice | ~50 (crew ECLSS only) |

Mk III uses zero ISRU propellant (ion drive). MOLE-I fleet drops to ~50 from Y85, irrespective of Mk III fleet size.

**Manufacturing: 60–65% in-situ by mass.** 148,810 haulers, 250,000 circuits, ~15,000 km conveyor.

**Earth logistics (audit-based):**

| Category | t/yr | Flights/yr |
|----------|------|-----------|
| Hauler spares (avionics, BMS, bearings) | ~5,000 | ~50 |
| Canister recovery (minimal chute option) | ~3,000 | ~30 |
| Processing circuit maintenance | ~1,500 | ~15 |
| MSR maintenance (Hastelloy-N declining) | ~1,500 | ~15 |
| Conveyor spares | ~500 | ~5 |
| SPA base + crew | ~350 | ~4 |
| Lubricants, catalysts, other | ~700 | ~7 |
| **Total** | **~12,500** | **~126** |

---

### P12 — Scaling + M-type asteroid online (Y80–120)

**Gates:**
- DG-12.1 (Y80): 500,000 t/yr REO → 40% global displacement (revised from 1,000,000 at Rev B — build-out extended to 2.5 Mt/yr at Y180)
- DG-12.2 (Y85): Thorium MSR fleet at ~6,890 × 100 MWe (689 GW) at PKT full-scale
- DG-12.3 (Y85): PKT→Earth mass driver: scaling toward 783/day at P14+ steady state
- **DG-12.4 (Y85): M-type asteroid arrives in DRO** — ~200 m Fe-Ni body. Dedicated Laser Ablation Truss + mass driver (MD-5, DRO→SPA) installed.
- **DG-12.5 (Y85): MD-5 (DRO→SPA) mass driver operational** — ~800 m/s, ~500 m track, ~30 t YBCO. Delivers asteroid concentrate to SPA EM catcher.
- DG-12.6 (Y90): M-type PGM yield: 36.5 t/yr PGM at 100 ppm in Fe-Ni matrix. 1,000 t/day laser ablation throughput.
- **DG-12.7 (Y95): Programme status assessment — P13+ scope decision.** 500k→1.25 Mt/yr build-out commitment. Hauler Earth fraction dropping from 43% to ~33% as M-type Fe-Ni supplements foundry feedstock.

**Laser Ablation Truss (DG-13.2 concept, deployed Y85):**
- Linear rigid truss with dual high-power laser heads at each end. Truss rotates slowly around asteroid's long axis.
- ~350 MW total power (3–4 MSR units or ~1.2 km² solar array at DRO). ~1,000 t/day throughput = ~365,000 t/yr.
- Surface ablation in spiral pattern (~1 m depth channel). No mechanical contact — avoids microgravity reaction force problems.
- Ejecta captured by electrostatic/magnetic collectors behind each laser head. Continuous feed of sublimated metal vapour + spalled fragments.
- Heritage: DE-STAR programme (Lubin, UCSB) demonstrated laser ablation rates in vacuum.
- **Captured asteroids do NOT use PROBEs.** Dedicated permanent infrastructure. PROBEs are for remote uncaptured asteroids only. The two systems are architecturally independent.

P12 end-state (~Y120): 1,488,096 haulers, 2,083,334 circuits (optimised at 1.2 t/yr), ~87,500 km conveyor, 6,890 MSR units, PROBE fleet: ~30 Mk I/II (specialist SPA ops) + ~1,714 Mk III (bulk remote mining → transitioning to prospecting), 5 mass drivers (SPA→PKT, PKT→Earth, PKT→SPA, SPA→Earth, DRO→SPA), 20 crew at SPA, ~50 MOLE-I (demand-driven, chemical PROBE fleet reduced to 30). M-type asteroid producing 36.5 t/yr PGM. ~500,000 t/yr REO scaling toward 1.25 Mt/yr.

**Earth logistics (audit-based, minimal chute option, P12 full-scale):**

| Category | t/yr | Flights/yr | Driver |
|----------|------|-----------|--------|
| Hauler spares | ~13,000–19,000 | ~130–190 | 1.49M units × ~3 kg/yr avionics + battery BMS + bearings |
| Canister recovery | ~8,000 | ~80 | 285,715/yr × ~28 kg (minimal chute + electronics) |
| Processing circuits | ~5,000 | ~50 | 2.08M circuits × ~2 kg/yr replacement parts |
| MSR maintenance | ~1,500 | ~15 | Ni-201 in-situ vessels by P11+; turbomachinery spares |
| Conveyor network | ~1,250 | ~13 | 50,000 drive stations × electronics/bearings |
| SPA base + crew | ~350 | ~4 | Robot spares, biologicals, crew supplies |
| Lubricants + catalysts + other | ~1,200 | ~12 | MoS₂, V₂O₅, seals, gaskets, EDTA |
| **Total** | **~30,000–36,000** | **~300–360** | |

Note: this is lower than the 40,000–49,000 t/yr estimated in ECN-019 Rev A because (a) YBCO eliminated by conveyor substitution, (b) Hastelloy-N replaced by in-situ Ni-201 at P11+, (c) minimal chute option for canisters.

---

### P13 — 50% replacement + C-type asteroid (Y120–Y140)

**Gates:**
- **DG-13.1 (Y120): 1,250,000 t/yr REO** — 50% of projected global demand. P13 milestone, not final target. Programme proceeds to 2.5 Mt/yr.
- **DG-13.2 (Y95, executed during P12): C-type asteroid redirect initiated** — ~100 m carbonaceous body. SEP/NEP redirect tug (3 units now in fleet). Arrival in DRO at Y105.
- **DG-14.1 (Y95): C-type asteroid targeting decision gate** — selects target optimising for water ice content + carbon/nitrogen fraction + accessible orbit.
- DG-13.3 (Y105): C-type processing facilities commissioned at SPA:
  - Pyrolysis + Fischer-Tropsch for polymer precursors (PTFE, Kapton-equivalent)
  - Water extraction → propellant independence from lunar ice (MOLE-I drops to ~50 for crew ECLSS only)
  - Carbon + nitrogen for organic chemistry
  - C-type thermal blanket: reflective MLI over unmined surfaces to preserve subsurface ice in continuous DRO solar exposure
- **DG-13.4 (Y105): SPA MSR #1 commissioned** — 50 MWe, ThCl₄ fuel from PKT→SPA mass driver. Powers C-type processing.
- DG-13.5 (Y110): Circuit Earth fraction drops from 10% to 3% — C-type carbon replaces PTFE/polymer imports.
- **DG-13.6 (Y115): S-type asteroid redirect initiated** — ~100 m silicaceous body. Fleet now includes 5 redirect tugs (redundancy).
- DG-13.7 (Y120): M-type Fe-Ni reduces hauler Earth fraction from 43% to 20% floor (avionics, BMS, bearings irreducible).

**Manufacturing:** Circuit and hauler production continuing at steady rate. C-type resources begin reducing Earth dependency for polymers, seals, and thermal materials. PROBE Mk III fleet at ~1,714, transitioning from bulk mining to prospecting as all 3 asteroid captures approach completion.

**Earth logistics:** Declining from P12 levels as C-type materials substitute for imports. Hauler spares and canister recovery remain dominant categories.

---

### P14 — Full replacement + S-type asteroid + Earth independence (Y140–Y180)

**Gates:**
- **DG-14.2 (Y115, executed during P13): S-type asteroid targeting decision gate** — selects target optimising for silicon content + enstatite sulfide copper fraction.
- DG-14.3 (Y125): S-type processing facilities commissioned at SPA:
  - Czochralski silicon refining (semiconductor-grade Si using C-type carbon for carbothermic reduction)
  - Copper electrolysis from enstatite sulfides
  - Products mass-driven SPA→PKT for circuit fabrication
- **DG-14.4 (Y125): SPA MSR #2 commissioned** — 100 MWe for S-type Si refinery power.
- DG-14.5 (Y130): Circuit Earth fraction drops from 3% to **0.8%** — only advanced ICs remain Earth-sourced.
- **DG-14.6 (Y140): Earth independence assessment (DG-14.3 from ECN-019)** — comprehensive audit of remaining Earth dependencies. Target: <0.5% of total infrastructure mass from Earth.
- **DG-14.7 (Y140): SPA MSR #3 commissioned** — scaled operations, full asteroid processing hub.
- DG-14.8 (Y180): **2,500,000 t/yr REO achieved** — full replacement of terrestrial REE mining.
- **DG-14.9 (Y115+): Mk III PROBE fleet reduction** — all 3 asteroid captures complete by Y125. Fleet reduces from ~1,714 to ~300 (prospecting for future targets only). Decommissioned Mk III units: ion drives and solar arrays salvaged at SPA.

**P14 end-state (Y180):** 2.5 Mt/yr REO steady state. Programme transitions from build-out to maintenance. Circuit Earth fraction 0.8%. Hauler Earth fraction 20% (avionics floor). Near-complete cislunar industrial self-sufficiency.

**Earth fraction trajectory:**

| Year | Circuit | Hauler | MSR | Earth dependency |
|------|---------|--------|-----|------------------|
| P8 (Y25) | 100% | 100% | 100% | Everything from Earth |
| P10 (Y55) | 10% | 43% | 30% | Foundry produces steel, Al |
| P12 (Y85) | 10% | 33% | 30% | M-type Fe-Ni improves hauler |
| Post C-type (Y115) | 3% | 25% | 30% | PTFE, polymers in-situ |
| Post S-type (Y135) | **0.8%** | **20%** | 30% | Si sensors, Cu wiring in-situ |

---

### P14+ — Steady state + indefinite operation (Y180+)

**Programme transitions from "betterment of Earth" to "self-sustaining cislunar industrial civilisation."**

Steady-state operations:
- 2,500,000 t/yr REO exported to Earth via PKT→Earth mass driver (285,715 canisters/yr, ~783/day)
- M-type asteroid PGM campaign continues (80+ yr duration, ~36.5 t/yr PGM)
- SPA operates as deep-space hub — ISRU propellant production revives for interplanetary mission support
- ~300 PROBE Mk III prospecting for future asteroid targets
- MOLE-I at ~50 (crew ECLSS only; C-type water supplements all propellant needs)
- Maintenance-only fleet replacement at PKT

**Remaining Earth dependencies at Y135:**
- Advanced integrated circuits (processors, FPGAs)
- Specialty optical components (LiDAR optics)
- Some precision bearings (ceramic hybrids)
- Estimated: <0.5% of total infrastructure mass

**Beyond Y200:** With M-type (Fe-Ni, PGM), C-type (water, carbon, nitrogen), and S-type (silicon, copper) resources combined, the programme becomes functionally independent of Earth supply. Infrastructure supports indefinite operation and growth without Earth resupply. PKT resource adequacy: 400–1,300 years of total KREEP REE at rate (~1–3 Bt total in KREEP layer); accessible PKT resource to 200 m depth provides ~88–264 years from Y180. Post-P14 hauler upgrades (depth mining attachments, relay depot chains for Tier 2/3 open-pit operations), fleet expansion across PKT's 6.1M km², and new extraction methods extend operations indefinitely. See §10.2 for tiered depth mining architecture.

---

## 3. Mass driver configuration (5 baseline)

| # | Route | Purpose | Velocity | YBCO (t) | Build phase |
|---|-------|---------|----------|----------|-------------|
| 1 | SPA→PKT | Fe-Ni foundry feedstock from PROBE returns + ThCl₄ + construction supplies | ~1,800 m/s | ~60 | **P8 (Y25)** |
| 2 | PKT→Earth | REO canisters, 783/day at P14+ steady state | ~2,400 m/s | ~100 | **P9 (Y35)** |
| 3 | PKT→SPA | ThCl₄ fuel for SPA MSR + spares/samples | ~1,800 m/s | ~30 | P9–P10 (Y43) |
| 4 | SPA→Earth | PGM concentrate — triggered when export >100 t/yr (DG-11.6) | ~2,400 m/s | ~60 | P11 (Y70) |
| **5** | **DRO→SPA** | **Captured asteroid concentrate from laser ablation truss** | **~800 m/s** | **~30** | **P12+ (Y85)** |
| | **Total YBCO** | | | **~280 t** | **~3 Starship flights lifetime** |

One catapult demonstrator hub at **P8** (~23 t YBCO) validates coilgun physics at 500 m/s before committing to escape-velocity mass drivers (PKT→Earth at P9). Total programme YBCO including demonstrator: ~300 t.

### 3.1 EM Catchers

SPA operates EM catchers for three inbound streams:
- PKT→SPA mass driver canisters (ThCl₄ fuel, spares)
- DRO→SPA mass driver canisters (asteroid concentrate from laser ablation truss)
- Mk III PROBE LLO canister ejections (~1,680 m/s, decelerated by EM catcher)

Same YBCO coil technology as mass drivers, run in reverse.

### 3.2 PROBE Fleet Logistics — Fe-Ni from Asteroids to PKT Foundry

PROBEs are based permanently at SPA, not PKT. This is a propellant constraint: SPA produces all LH₂/LOX from Shackleton PSR ice via the ISRU chain. PKT has no extractable water ice and no propellant production capability. Rebasing PROBEs to PKT would require mass-driving cryogenic propellant TO PKT for refuelling — adding logistics complexity and requiring full duplication of IZ infrastructure (docking collars, ARM-D gantry, cryo propellant farm, SENTINEL servicing systems).

**Mk I/II Fe-Ni material flow (P5–P11):**

1. PROBE departs SPA → M-type asteroid (6–12 month mission)
2. Collects 1,500 kg Fe-Ni/PGM ore per mission (Mk II: 500 t processed in-situ, 10 t returned)
3. Returns to SPA → docks at IZ collar, serviced by ARM-D (48–72 hr turnaround)
4. Ore containers extracted through dust vestibule → SPA beneficiation
5. PGM concentrate separated (chlorination) → Earth return (Starship P8–P10; SPA→Earth mass driver P11+ if DG-11.6 approved)
6. **Fe-Ni bulk → loaded into SPA→PKT mass driver canisters → mass-driven to PKT → PKT foundry feedstock**
7. PROBE refuelled from SPA ISRU → next mission

**Mk III Fe-Ni material flow (P11+):**

1. Mk III PROBE departs SPA via ion thrust → remote M-type asteroid (3–8 month transit)
2. EM anchor engagement on Fe-Ni surface → scraper mining 6–12 months
3. Ejects 10 t Fe-Ni/PGM payload canisters from LLO on ballistic deorbit trajectory
4. EM catcher at SPA receives canisters at ~1,680 m/s → SPA beneficiation
5. PGM separated → SPA→Earth mass driver or Starship
6. Fe-Ni bulk → SPA→PKT mass driver → PKT foundry feedstock
7. Mk III continues to next target (never returns to surface)

**Captured asteroid material flow (P12+, separate system):**

1. Laser Ablation Truss operates at captured asteroid in DRO
2. Ejecta collected, concentrated, loaded into DRO→SPA mass driver canisters
3. MD-5 fires to SPA at ~800 m/s → SPA EM catcher receives
4. Processing at SPA: M-type PGM hydromet, C-type pyrolysis/Fischer-Tropsch, S-type Czochralski/electrolysis
5. Products mass-driven SPA→PKT where needed for circuit fabrication

SPA IZ scales linearly with PROBE fleet: docking collars and ARM-D units maintain the 1:1 ratio established in P3–P7 (2→4→6→8 collars). Gantry rail extendable by design (SEL-CAD-IZ-001).

---

## 4. Processing circuit architecture

The programme commits to an **optimised continuous-flow design** — the single highest-value design decision ($22T cost reduction over 200 years vs batch).

| Design | REO/yr | Mass (kg) | Power (kW) | Circuits for 2.5 Mt/yr | Total mass |
|--------|--------|-----------|------------|------------------------|------------|
| Batch (rejected) | 0.4 | 15,000 | 180 | 6,250,000 | 93.8 Mt |
| Continuous-flow | 0.8 | 22,000 | 300 | 3,125,000 | 68.8 Mt |
| **Optimised (committed)** | **1.2** | **28,000** | **400** | **2,083,334** | **58.3 Mt** |

Physics basis: continuous-flow reactors eliminate batch dead time (~30% of cycle). Acid bake (2–4 hr), leaching (4–8 hr), precipitation (1–2 hr per stage) operate simultaneously in sequence. Larger vessels follow cube-square law (~1.5× mass for 2× volume).

**Maintenance rate:** 0.5% of mass per year as Earth-sourced spare parts (revised from 2%). Justified by: mature foundry producing replacement vessels/piping in-situ from Y45, 130+ years of foundry operating experience by steady state, and asteroid-sourced materials (C-type PTFE, S-type sensors) reducing Earth fraction to 0.8%.

**Circuit Earth fraction trajectory:**

| Era | Earth fraction | Driver |
|-----|---------------|--------|
| P8 (Y25) | 100% | All from Earth |
| P10+ (Y45) | 10% | Foundry produces vessels, piping, frames |
| Post C-type (Y105) | 3% | PTFE, polymers, thermal materials in-situ |
| Post S-type (Y125) | **0.8%** | Si sensors, Cu wiring in-situ |

**Decision gate DG-8.X:** Circuit throughput validation — target ≥1.0 t/yr REO per circuit before committing to full-scale PKT build-out.

---

## 5. Construction fleet scaling

| Vehicle | Scales with | Unit mass | Replacement |
|---------|------------|-----------|-------------|
| ARM-C (assembly) | 1 per 500 circuits/yr build rate | 1,500 kg | 10-yr life |
| SINTER (construction) | 1 per 200 circuits/yr build rate | 2,200 kg | 15-yr life |
| SENTINEL (monitoring) | 1 per 500 circuits total | 80 kg | 10-yr life |
| Charging hubs | 1 per 100 haulers | 5,000 kg (95% in-situ) | Long life |

**During build-out (P8–P14):** Fleet scales with circuit construction rate. Peak demand during P10–P12 when circuit installation rate is highest.

**Steady-state minimum fleet (P14+ maintenance only):** ~20 ARM-C, ~50 SINTER for road/enclosure repairs, SENTINEL scales with circuit count. Total construction fleet cargo: ~0.3% of total Earth cargo — small but present for completeness.

---

## 6. Year-by-year manufacturing capability progression

This table maps what is manufactured WHERE at each phase — the key input for the economic evaluation.

| Phase | Years | What Earth manufactures | What Moon manufactures | Moon capability |
|-------|-------|------------------------|----------------------|-----------------|
| P0–P3 | Y0–Y7 | ALL robots, ALL infrastructure, ALL consumables | Sintered regolith (hab shells, roads, pads) | SINTER only |
| P4 | Y7–Y9 | ALL robots, fleet additions, hab expansion, ISRU expansion | Sintered construction continues | SINTER + crew EVA maintenance |
| P5 | Y9–Y12 | ALL robots, beneficiation module, fleet scaling | Sintered construction + H₂SO₄ pilot (1–5 t/yr) | First in-situ chemistry |
| P6 | Y12–Y15 | ALL robots, processing facility prefab, fleet scaling | H₂SO₄ (~10 t/yr) + Ca(OH)₂ (~5 t/yr) | Reagent pilots operational |
| P7 | Y15–Y25 | ALL robots, processing circuits, fleet scaling | H₂SO₄ (50%+ in-situ), Ca(OH)₂ (all), Th(OH)₄ stockpiling, 0.4 t/yr REO | Processing + reagent production |
| P8 | Y25–Y35 | Construction fleet for PKT, 308 circuits, FSP for PKT, mass driver YBCO (~90 t) | PKT reagents (85% in-situ), sintered PKT spine + roads, pilot foundry, SPA→PKT mass driver operational | Mass driver + reagent ISRU + foundry pilot |
| P9 | Y35–Y45 | 2,192 circuits, hauler Earth fraction, foundry expansion, PKT→Earth mass driver YBCO (~100 t) | Reagents (90%), first haulers (55–60% in-situ), conveyor pilot (500 km), first MRE metal parts, canister production begins | Foundry at scale + hauler manufacturing + REO export begins |
| **P10** | **Y45–60** | **Hauler Earth fraction (~620 kg × 14,881), canister Earth fraction, MSR Hastelloy-N vessels, all avionics** | **Hauler in-situ fraction (~830 kg × 14,881), canister shells + TPS, conveyor network (5,000+ km), road network, MSR regolith shielding, reagents (95%)** | **Full industrial scale — Fe-Ni, Al, Fe-Si alloys. WAAM/EB welding. Distributed canister production.** |
| P11 | Y60–80 | Hauler spares, canister recovery systems, circuit maintenance parts, turbomachinery, lubricants, Mk III PROBEs (LEO launch, self-transfer) | Everything in P10 at 10× scale + Ni-201 MSR vessels (replacing Hastelloy-N), conveyor expansion, a-Si solar panels | In-situ Ni superalloy. Approaching 65% self-sufficiency. |
| P12 | Y80–120 | Hauler spares (~13–19 kt/yr), canister recovery (~8 kt/yr), circuit parts (~5 kt/yr), MSR turbomachinery, SPA robot spares, laser ablation truss (DRO) | All structural metals, all reagents, MSR vessels, conveyor network, canisters, road network — ~97% of operational mass throughput. M-type Fe-Ni at scale. | Near-complete self-sufficiency for bulk items. M-type PGM + Fe-Ni online. |
| P13 | Y120–140 | Declining — C-type polymers replace PTFE/Kapton imports; hauler spares + canisters remain | C-type: water, carbon polymers, nitrogen chemistry. Circuit Earth frac drops to 3%. Propellant independence. | C-type materials online. Polymer in-situ. |
| P14 | Y140–180 | Minimal — S-type Si/Cu replace sensor + wiring imports; only advanced ICs from Earth | S-type: semiconductor Si (Czochralski), Cu wiring. Circuit Earth frac 0.8%. | Near-complete Earth independence (<0.5% mass). |
| P14+ | Y180+ | Advanced ICs, specialty optics, precision bearings only | Everything else. Self-sustaining cislunar industrial civilisation. | Indefinite operation without Earth resupply. |

**Key insight for economic model:** MOLE-I fleet scales with propellant demand (PROBE + SKIP + ECLSS + crew rotation), NOT with PKT ore transport. SKIPs continue at SPA through P8 for KREEP research (877 t/yr raw regolith to SPA beneficiation), then retire at P9 when PKT output dominates. The mass driver at P8 eliminates chemical tanker transport demand — the driver behind the old 48,990+ MOLE-I figures. Fleet scales gently: 170 (P7) → ~247 (P8, PROBE + SKIP) → ~240 (P9, SKIP retired) → ~355 (P12, peak chemical PROBE demand) → ~50 (Y85+, Mk III replaces bulk chemical operations). All within Shackleton crater (~310 usable floor positions) plus modest de Gerlache extension (~45 units, 5–10 km via Connecting Ridge) if ice fraction is at the conservative 4.46% design point. At LCROSS-measured 5.6%+, Shackleton alone is sufficient. De Gerlache expansion beyond ~400 MOLE-I is a P13+ decision gate only if chemical PROBE fleet exceeds ~370 units (rendered moot by Mk III transition). Earth→Moon mass flow peaks at P9–P10 (~15,000 t/yr) during circuit and hauler scaling, then declines as in-situ fraction grows. By P12, Earth supplies ~30,000–36,000 t/yr despite operating at 1,000× the scale of P8.

---

## 7. Economic evaluation summary

From SEL-ECON-001 Rev A (SELENITE_ECON v1.3/v1.4):

| Metric | Value |
|--------|-------|
| Total programme cost (200 yr) | $21.3 T |
| Total revenue + externalities (200 yr) | $15.6 T |
| Average annual programme cost | $106 B/yr (4.7% of global military spending) |
| NPV (all externalities, declining 3/2.5/2%) | −$0.49 T |
| BCR (200-year, all externalities) | 0.50 |
| BCR (annual, steady state Y180+) | 2.06 |
| Steady-state net surplus (Y180+) | +$121.8 B/yr |
| CO₂ avoided at steady state | 182 Mt/yr |
| Lifetime rocket CO₂ | 52 Mt (0.03% of benefits) |
| IRR (all externalities) | −2.54% (requires intergenerational weighting) |

**The programme is NOT commercially viable on direct revenue alone** ($1.48 T revenue vs $21.3 T cost). The economic case rests entirely on internalised externalities:

| Externality stream | 200-yr value |
|--------------------|-------------|
| Avoided terrestrial REE mining damage | $10.4 T |
| H₂ economy enabling via iridium (50% attribution) | $2.6 T |
| Geopolitical supply-chain insurance | $1.2 T |
| Rocket emissions (negative) | −$0.01 T |

This requires government-consortium funding — consistent with Arrow et al. (2014) recommendations for intergenerational public goods and comparable to ITER, ISS, and climate mitigation programmes.

At steady state (Y180+), the programme generates **$2.06 in benefits for every $1 in cost** — comparable to mature highway and power infrastructure. The 200-year BCR of 0.50 reflects the mathematical limitation of discounted analysis applied to multi-century timescales, not a fundamental economic weakness.

**Dominant sensitivities:**
- Discount rate: $1.17T NPV range (1.4% vs 3.5%) — the economic case is fundamentally a question of intergenerational ethics, not engineering economics
- Launch cost: $0.67T range (±50%)
- Circuit throughput: $22T total cost difference between batch (0.4 t/yr) and optimised (1.2 t/yr) designs — highest-value R&D investment
- H₂ attribution: $0.19T range (25% vs 100%)

**Environmental CO₂ balance at steady state (Y200):**

| Stream | Mt CO₂/yr | Direction |
|--------|-----------|-----------|
| REE mining lifecycle avoided | 75.0 | Positive |
| H₂ via Ir (PEM → green steel/ammonia) | 107.1 | Positive |
| Rocket emissions (5% fossil frac) | 0.3 | Negative |
| **NET** | **181.7** | **Strongly positive** |

DAC methane timeline: fossil propellant fraction 100% (Y0–Y30) → 80% (Y45) → 30% (Y60) → 5% (Y80+). Peak rocket emissions ~3 Mt CO₂/yr at Y45–50 during P9–P10 build-out. Near carbon-neutral from P11+. Lifetime: 52 Mt CO₂ — equivalent to ~6 days of current global emissions.

---

## 8. Items that MUST come from Earth — all phases, irreducible

| Category | Why | Approximate P12 rate |
|----------|-----|---------------------|
| Radiation-hardened electronics | Semiconductor fab at nm scale: TRL 0 on Moon | ~4,500 t/yr |
| LiDAR, cameras, star trackers | Precision optics, detector arrays | ~2,000 t/yr |
| Precision bearings, seals, O-rings | Sub-micron tolerances, specialty elastomers | ~3,000 t/yr |
| Motor power electronics | IGBTs, gate drivers, current sensors | ~2,500 t/yr |
| Battery BMS + Earth fraction | BMS circuits, insulation, some seals | ~4,000–9,000 t/yr |
| Parachute/drag chute fabric | Nomex/Kevlar aramid — carbon + nitrogen polymer (→ C-type substitute P13+) | ~3,000–10,000 t/yr |
| Turbomachinery (MSR) | Precision casting, blade metallurgy, balancing | ~1,000 t/yr |
| Hastelloy-N (early MSR fleet) | Mo at ~1 ppm on Moon — cannot alloy | Declining (→ Ni-201 at P11+) |
| Lubricants | MoS₂ dry lube: Mo scarce on Moon | ~500 t/yr |
| PTFE, Kapton, specialty polymers | Carbon-based polymers (→ C-type substitute P13+) | ~500 t/yr |
| Biological supplies | Seeds, pharmaceuticals, growth media | ~100 t/yr |
| V₂O₅ catalyst | Vanadium at ~50 ppm — extractable but low priority | ~200 t/yr |
| EDTA (recyclable) | Complex organic — one-time inventory + replenishment | ~10 t/yr |
| YBCO tape (mass drivers only) | Cu at ~15 ppm — hard showstopper | ~280 t lifetime total (5 drivers + 1 demonstrator) |

**Note:** Several categories marked with → are targeted for asteroid-sourced substitution at P13+ (C-type carbon for polymers/fabric, S-type silicon for sensors). By Y135, only advanced ICs, specialty optics, and precision bearings remain irreducible.

---

## 9. Canister recovery architecture — DG-9.1 decision options

At P14+ steady state, 285,715 canisters/year enter Earth's atmosphere at ~11 km/s. After re-entry heating (ablative TPS handles this), the canister decelerates through the atmosphere. The question is how it reaches the ocean surface.

| Option | Earth content/canister | P14+ Earth import | P14+ cost | Risk |
|--------|----------------------|-----------------|----------|------|
| 1a. Full parachute | ~73 kg | ~20,900 t/yr (~209 flights) | ~$42B/yr | LOW — proven technology |
| **1b. Minimal drag chute** | **~28 kg** | **~8,000 t/yr (~80 flights)** | **~$16B/yr** | **MED — needs impact survival validation** |
| 2. Shuttlecock (no fabric) | ~8 kg | ~2,300 t/yr (~23 flights) | ~$4.6B/yr | HIGH — unproven at scale |

**Recommended baseline for economic model: Option 1b (minimal drag chute).** Canister wall thickness increased from 4 mm to 8 mm Fe-Ni (in-situ steel, zero Earth import penalty) to survive ~50 m/s water impact. Drag chute is small (~5 m diameter, ~10 kg fabric) vs full parachute (~35 kg). Deploy mechanism + electronics + pyrotechnics add ~18 kg.

**Sensitivity range:** Model all three options. Best case (shuttlecock): $4.6B/yr. Baseline (minimal chute): $16B/yr. Worst case (full chute): $42B/yr.

---

## 10. Base specialisation architecture

### 10.1 SPA (Shackleton) = Asteroid Processing Hub + Crew Base

**ALL asteroid material (M/C/S-type) processed at SPA.** SPA has existing PGM hydromet from P5+ PROBE heritage. C-type and S-type processing facilities built at SPA from Y105/Y125. Products shipped SPA→PKT via mass driver where needed for circuit fabrication (PTFE, Si, Cu).

SPA role evolution:
- P0–P10: ISRU propellant hub + crew base + PROBE launch/recovery
- P11+: PGM processing hub (Mk III canisters via EM catcher)
- P12+: Full asteroid hub (M/C/S-type processing via DRO→SPA mass driver)
- P14+: Deep-space launch hub (ISRU propellant revives for interplanetary missions)

**SPA MSR fleet** for asteroid processing power:
- Y105: 1 MSR (~50 MWe) — C-type pyrolysis + Fischer-Tropsch
- Y125: +1 MSR (~100 MWe) — S-type Si refinery (Czochralski)
- Y140: +1 MSR — scaled operations
- ThCl₄ fuel from PKT→SPA mass driver (MD-3, operational from Y43)

### 10.2 PKT (Procellarum) = KREEP REO Processing ONLY

**Every km² of PKT surface is valuable KREEP ore.** No non-KREEP infrastructure is built on minable ground unnecessarily. PKT has: processing circuits, haulers, conveyors, SINTER, MSR for KREEP power. No PROBE operations, no asteroid processing, no PGM. PKT is fully autonomous — zero permanent crew. Temporary 3–4 person commissioning crew at P8 only (Wave 3, 6–12 months for foundry/MSR commissioning, departs before fuel loading).

**PKT base positioning — ore area maximisation:**

The processing spine, MSR fleet, foundry, and charging hubs are non-mining infrastructure that permanently sterilises the ground beneath them. At P14 scale (~5,000 km spine, 6,890 MSRs, ~15,000 hub stations), the total infrastructure footprint is <0.1% of PKT's 6.1 million km² — but the principle of positioning non-productive assets OFF the ore field prevents compounding sterilisation over centuries.

| Infrastructure | Positioning rule |
|----------------|-----------------|
| Processing spine | Along the PKT boundary — one side faces inward to ore field (hauler/conveyor input), the other faces outward to non-KREEP terrain. Spine NEVER bisects a rich deposit. |
| MSR fleet | Placed on the non-KREEP side of the spine boundary. MSRs do not need to sit on ore — power distributed via buried Al bus cable (in-situ manufactured, ≤10 km runs at 1,000 VDC). Regolith shielding uses non-KREEP material. |
| Foundry / fabrication | Co-located with MSR fleet on boundary side. Feedstock (Fe-Ni from SPA, scrap from decommissioned haulers) arrives via spine, not from local regolith. |
| Hub charging stations | Distributed within the ore field (unavoidable — haulers must charge near mining sites). Minimised footprint: 20 × 10 m sintered pad per hub. Relocatable as mining front advances. |
| Conveyor network | Runs from ore field to spine input hoppers. Linear footprint (~3 m wide) is negligible relative to mining area served. |
| Roads | Sintered in-situ from local regolith. Footprint small (3–5 m width). Roads are abandoned and re-mined as mining front moves — sintered regolith is re-processable. |

DART pathfinder (P5–P7) selects the PKT base site optimising for: (1) ore grade (≥200 ppm REE, target >500 ppm), (2) terrain flatness for spine construction, and (3) proximity to PKT boundary so spine can be positioned at the edge. The ideal site is a high-grade zone abutting the PKT/highlands boundary — spine runs along the contact, MSRs sit on the highlands side, haulers mine inward toward the PKT interior.

**PKT resource adequacy:**

Total accessible KREEP REE at PKT to 200 m depth: ~220–660 Mt (at 100–300 ppm bulk grade, 1,800 kg/m³ megaregolith). At 2.5 Mt/yr steady-state demand from Y180, this provides ~88–264 years of supply. DART-selected high-grade sites (300+ ppm) extend this toward the upper end. The PKT mare basalt column is 1–7 km thick (Kaguya/GRAIL) — KREEP-bearing material extends far deeper than any realistic mining horizon. Resource depletion is not a binding constraint on any programme-relevant timescale.

**Hauler depth mining — tiered expansion (post-P14):**

Surface regolith (Tier 1, 0–20 m) supports the first ~50–100+ years at full rate. Beyond this, the hauler fleet transitions to progressively deeper open-pit mining with relay depots:

| Tier | Depth | Material | Hauler config | Decision gate |
|------|-------|----------|---------------|---------------|
| 1 | 0–20 m | Loose regolith + upper megaregolith | Standard bucket/scoop | P8 baseline |
| 2 | 20–100 m | Megaregolith + fractured basalt | Ripper/breaker attachment, benched terraces, relay depots every 15–20 m vertical | DG-POST.1 (~Y280+) |
| 3 | 100–200 m | Competent fractured basalt | Heavy breaker or dedicated rock-breaking unit, multiple relay depots in series, sintered ramp network | DG-POST.2 (~Y380+) |

Each relay depot is a relocatable intermediate transfer station on a bench: receiving hopper + short inclined conveyor (20–25 m, 15–20° angle), towed into position by hauler, FSP- or MSR-powered. Beyond 200 m, entirely new extraction methods (in-situ leaching, deep boring, or technologies not yet conceived) become decision items. Combined with projected 90%+ terrestrial REE recycling by the 23rd century reducing demand, the programme has no foreseeable resource constraint.

---

## 11. Open items for further analysis

1. **SEL-CONVEYOR-001 Rev A** — new document required: steel apron conveyor specification for PKT Tier 3 transport
2. **SEL-CANISTER-001 Rev A** — new document required: mass driver return canister spec including recovery architecture options
3. **SEL-FAB-001 Rev A** — new document required: PKT foundry/fabrication facility specification
4. **SEL-POWER-PKT-001 Rev A** — new document required: PKT thorium MSR power architecture (including boundary positioning for ore area maximisation)
5. **SEL-REAGENT-001 Rev A** — new document required: in-situ reagent production system
6. **SEL-PROBE-MkIII-001 Rev A** — new document required: Mk III SEP PROBE design specification (ion propulsion, EM anchoring, canister ejection)
7. **SEL-LASER-TRUSS-001 Rev A** — new document required: Laser Ablation Truss specification for captured asteroid mining
8. **SEL-REDIRECT-001 Rev A** — new document required: SEP/NEP redirect tug specification
9. **Impact survival testing** — validate Fe-Ni canister at 8 mm wall survives 50 m/s ocean impact (Option 1b)
10. **Na-S battery lunar qualification** — beta-alumina electrolyte fabrication from lunar Al₂O₃
11. **SRM motor lunar qualification** — Fe-Si lamination quality from MRE iron/silicon vs Earth spec
12. **Circuit throughput R&D programme** — highest-value investment ($22T cost impact); target ≥1.0 t/yr validated before P8 PKT commitment
13. **SEL-HAULER-001 Rev B** — hauler update required: Na-S battery, mining-capable (bucket/ripper/breaker attachments), tiered depth mining architecture (0–200 m) with relocatable relay depots, resource adequacy analysis
14. **PKT boundary site selection criteria** — DART pathfinder must evaluate PKT/highlands contact zones for spine positioning that maximises inward ore access while placing MSR/foundry off-ore

---

*— End of SEL-DECISION-001 Rev D —*
