# SELENITE PROGRAMME

## Operational Strategy & Key Decisions Register

**SEL-T1.1-STRATEGY v3.1 · April 2026**

*Jason · Systems Engineering Lead · Source: Fleet Spec v9 · Guide v18 · Decision Framework v4 (Rev D) · ECON-001 Rev A · ECN-019 Rev C · ECN-020 · CATAPULT-001 Rev B*

This document records the operational decisions, problem resolutions, and physics-constrained strategies that define the Selenite Programme architecture. It is the single authoritative reference for *why things are done the way they are*. All ECN amendments (ECN-012 through ECN-019 Rev C) are integrated into the body text — there are no appendix amendment sections.

**Programme target: 2.5 Mt/yr REO — full replacement of terrestrial REE mining by ~Y180 (~2205).**

---

# 1. Binding Constraint: ISRU Propellant Production

The fundamental constraint governing every phase configuration from P3 through P11 is ISRU propellant production — the MOLE-I → mini-VEX → pipeline → electrolyser → cryocooler chain. All fleet sizing decisions flow from this single bottleneck. No other subsystem is the binding limit until the PROBE Mk III transition at P11, when ion propulsion eliminates ISRU propellant as the fleet constraint.

| Parameter | Value | Derivation |
|-----------|-------|------------|
| MOLE-I annual propellant yield | 5,692 kg LH₂/LOX | 25 kg/hr × 4.46% ice × 80% avail × 8,760 hr × 0.722 electrolysis eff. |
| PROBE-Ops missions per MOLE-I | 0.855 missions/yr | 5,692 ÷ 6,654 kg/mission |
| SKIP craft sustained per MOLE-I | 0.069 craft (at 1 hop/day) | 5,692 ÷ 83,050 kg/yr per SKIP |
| Min MOLE-I formula | ceil[(nP×6654 + nS×83050 + nD×6185 + crew×249) / 5692] | All water ISRU exclusively MOLE-I |

## 1.1 Phase-by-Phase Propellant Balance (Demand-Driven MOLE-I)

Previous architecture (SELENITE_SCALE v1.3) specified 48,990 MOLE-I at P8 and 390,790 at P9. **These figures are eliminated.** They were driven by chemical tanker flights SPA→PKT to fuel PKT-based SKIPs — an architecture removed by ECN-019 (mass driver at P8, no SKIPs at PKT). The Shackleton crater floor physically accommodates ~310 MOLE-I maximum. Correction saves ~$850B in eliminated hardware.

| Phase | Fleet config | MOLE-I | Supply (t/yr) | Demand (t/yr) | Margin |
|-------|-------------|--------|---------------|---------------|--------|
| P3 Y4–7 | 3 PROBE, 1 SKIP, Earth-fuelled P3 | 10 | 56.9 | ~0 | Stockpile |
| P4 Y7–9 | 6 PROBE, 1 SKIP, 4 crew | 25 | 142.3 | 124.1 | +14.7% |
| P5 Y9–12 | 10 PROBE, 2 SKIP, 1 DART, 4 crew | 50 | 284.6 | 237.9 | +19.6% |
| P6 Y12–15 | 15 PROBE, 4 SKIP, 1 DART, 6 crew | 85 | 483.8 | 433.8 | +11.5% |
| P7 Y18–25 | 30 PROBE, 8 SKIP, 12 crew | 170 | 967.6 | 867.6 | +11.5% |
| P8 Y25–35 | 96 PROBE Mk I, 8 SKIP (SPA), crew | ~247 | 1,406 | 1,403 | +0.2% |
| P9 Y35–45 | ~190 PROBE (Mk I→II), **0 SKIP (retired)** | ~240 | 1,367 | 1,364 | +0.2% |
| P10 Y45–60 | ~230 PROBE Mk II | ~280 | 1,594 | 1,630 | −2% (de Gerlache ext.) |
| P11 Y60–80 | 260→30 Mk I/II + **0→1,714 Mk III (ion, zero ISRU)** | ~320→~50 | 1,822→285 | variable | Mk III transition |
| P12+ Y80+ | 30 Mk I/II + 1,714 Mk III | **~50** | ~285 | ~300 | C-type water supplements |

> *Decision: MOLE-I count is a continuous design variable, not a step-change. Any cargo manifest slip immediately degrades margins. The Mk III transition at P11 fundamentally changes the constraint — MOLE-I drops from ~355 peak to ~50, serving only crew ECLSS and the 30-unit specialist chemical fleet.*

---

# 2. PROBE Fleet Strategy

## 2.1 PROBE-Scout vs PROBE-Ops

Two distinct vehicles with incompatible mass budgets:

| | PROBE-Scout | PROBE-Ops (Mk I) |
|-|-------------|-------------------|
| Role | One-way NEA survey, expendable | Round-trip Ni-Fe/PGM return |
| Wet mass | 243 kg (101 dry + 142 Earth propellant) | 8,950 kg (800 dry + 1,500 payload + 6,654 ISRU propellant) |
| ΔV | ~3,876 m/s one-way | 6,000 m/s round-trip |
| ISRU propellant? | NO — Earth-supplied only | YES — ISRU from Y8+ |
| Docking collar? | NO — provisional surface capture only | YES — pressurised collars from M68 |
| Fleet count? | Not counted in operational fleet | 3→6→10→15→30→96 (P3–P8) |

Multi-scout dispatch strategy: 3–5 scouts simultaneously to different candidates; best-confirmed target selected for PROBE-Ops commitment.

## 2.2 PROBE Mk I / II / III Lifecycle

| Class | Era | Fleet | Propulsion | Lands? | Role |
|-------|-----|-------|------------|--------|------|
| Mk I | P5–P8 | 30→96 | Chemical LH₂/LOX, Isp ~450 s | Yes (SPA IZ) | Basic scraper, 1,500 kg Fe-Ni/PGM per mission |
| Mk II Heavy | P9–P11 | 190→260 | Chemical LH₂/LOX | Yes (SPA IZ) | In-situ beneficiation: 500 t processed on-asteroid, 10 t returned, ~17.5 kg PGM/mission |
| Mk I/II phasedown | P11+ | 260→50→30 | Chemical | Yes | Specialist SPA short-range ops. Decommissioned units salvaged (~184 t recovered). |
| **Mk III SEP** | **P11+** | **0→1,714→300** | **Ion (Xe/Ar)** | **NEVER** | **Bulk remote mining. ~1,200 kg dry. Ejects 10 t canisters from LLO → EM catcher at SPA. EM anchoring on M-type Fe-Ni surface. Heritage: MEV-1.** |

Mk III uses zero ISRU propellant — the architectural change that drops MOLE-I from ~355 to ~50 at Y85.

## 2.3 Docking Collars and IZ Architecture

Collars required = (annual missions × turnaround) ÷ (hours/yr × utilisation). At 30 PROBE × 60 hr turnaround ÷ (8,760 × 0.70) = 4 collars. The 8-collar plan provides 2× resilience.

- Collars: horizontal cylinders (5 m OD × 4.5 m), single linear row. ARM-D 1:1 ratio per collar. Scale: 2→4→6→8 (P3–P7), extending to 30+ at P11 (linear with PROBE fleet). Gantry rail extendable by design (SEL-CAD-IZ-001).
- Mk III PROBEs never dock at IZ (never land). Their canisters arrive via EM catcher — separate system.
- SKIP landing pad SEPARATE from PROBE collars (incompatible descent profile).

## 2.4 PROBE Basing and Fe-Ni Material Flow

PROBEs base permanently at SPA (propellant constraint — SPA produces all LH₂/LOX; PKT has no water ice). Rebasing to PKT would require mass-driving cryogenic propellant + duplicating all IZ infrastructure.

**Mk I/II flow:** PROBE departs SPA → asteroid → returns to SPA IZ → ore extracted → PGM separated (chlorination) → Earth return. Fe-Ni bulk mass-driven SPA→PKT as foundry feedstock.

**Mk III flow:** Ion transit to remote asteroid → EM anchor → scraper mining → eject 10 t canister from LLO → EM catcher at SPA → PGM separated → Fe-Ni to PKT foundry. Mk III never returns to surface.

**Captured asteroid flow (separate system):** Laser Ablation Truss at DRO → concentrate to DRO→SPA mass driver (MD-5) → SPA processing → products to PKT if needed.

---

# 3. DART Logistics — LLO Architecture

The direct ballistic arc to PKT was definitively ruled out: 3,300 km great-circle distance requires ~72° launch angle → ~13,200 m/s ΔV → 30+ t propellant. Physically impractical. LLO orbital transfer is the only viable architecture.

| Parameter | Value |
|-----------|-------|
| Transfer method | LLO orbital transfer. Ascent ~1,800 m/s → coast → deorbit ~1,900 m/s per leg. Distance-independent. |
| Round-trip ΔV | 7,400–8,900 m/s (15% contingency in upper bound) |
| Propellant per mission | ~12,370 kg LH₂/LOX at planning ΔV ~8,200 m/s |
| Mission cadence | Biennial. Limited by ISRU stockpile (~4 months to accumulate at P5 surplus). |
| Minimum economic payload | 1,200 kg PKT material (≈ 10,000 kg SPA-equivalent after beneficiation) |
| Primary purpose | Ground-truth XRF for PKT grade confirmation + LLO autonomous orbital transfer demonstration. Pathfinder for P8 PKT base decision. |
| P8+ role | DART propellant demand zero from P8 — operates at PKT on surface power via mass driver. |

---

# 4. MOLE-I and MOLE-S — Architecture and Corrections

## 4.1 Two-MOLE Architecture

| | MOLE-S (Surface) | MOLE-I (PSR) |
|-|-------------------|--------------|
| Environment | Surface/rim; −173°C to +127°C | PSR interior; design baseline 40 K |
| Mechanism | Dual counterrotating bucket drums (RASSOR heritage) | Rotary-percussive drill (ESA PROSPECT heritage) |
| Throughput | 50 kg/hr loose regolith | 25 kg/hr icy permafrost |
| ISRU role | ZERO contribution to water ISRU. Construction only. | Sole source of ALL water ISRU |
| Fleet | 4–6, constant. **SPA ONLY — not deployed to PKT.** | 10→170→~355 peak→~50 (demand-driven) |
| Deployment | At PKT, all excavation by mining-capable haulers (Rev B) | PSR-permanent, tethered, never retrieved |

## 4.2 MOLE-I Key Specifications (Per ECN-012/013)

- **Dry mass:** ~360.65 kg (post ECN-013: +NAV-001 IMU, +bayonet adapter CON-001)
- **Propellant yield:** 5,692 kg/yr per unit
- **Operating power:** ~1,934 W at tether (300 drive + 200 drill + 1,200 mini-VEX + 15 WEB + 20 comms + 50 thermal + 99 DC-DC + 50 charge)
- **Standby power:** ~65 W (15 WEB + 30 gearbox heaters + 15 drill bearing + 5 receptacle)
- **WEB:** 273 K setpoint, Cu braid thermal strap, LWRHU backup (3×3.3 W). WEB loss is immediately fatal.
- **Transit battery:** 334 Wh (1.3 kg), 65 W × 4.7 hr × 1.10 margin
- **Navigation (ECN-013):** 3-layer (tether polar fix + wheel odometry + MEMS IMU), Kalman filter ±0.5 m, 3,600-cell drill grid
- **Bayonet adapter (ECN-013 R2):** Motorised, 0.3 kg, 2 W, passive detent hold. Standardised 20 mm profile.
- **Drain pipe (ECN-012):** Rear nozzle, trace-heated 15 W during dump only.
- **Mk II drill retrofit (ECN-016 §2):** Telescoping auger to 5,000 mm (vs 800 mm Mk I). Inconel 718 bellows seal. +35 kg with tungsten counterbalance. P8–P9 rollover at scheduled maintenance.

## 4.3 Crater Access Infrastructure

- **Descent winch:** Kevlar or Vectran cable ONLY (Dyneema excluded: Tg ~123–153 K → brittle failure). 0.5 m/s, ~4.7 hr over 8,400 m slope.
- **Cable tramway (P3):** 350 kg containers, ~2,379 t/yr capacity. Retained as backup.
- **Heated pipeline (P4+):** 8,500 m, 7 W/m trace heating (59.5 kW continuous). Ti-6Al-4V, 68 bar trunk pump at CLP (408 W). 34 branch transfer pumps (~10 W each). Redundant parallel pipe from P5. **Must never lose power — freeze = total replacement.**
- **PSR network:** Bilateral fishbone, 62 junctions (620 MOLE-I max), P7+ uses 34 nodes (170 units). 1,000 VDC OFHC Cu trunk. Branches elevated ~3 m on sintered stakes. SATS+WEB pre-integrated assembly (ECN-013 R2) — arrives powered via LWRHU during 23-hr descent. Construction tether retraction spools (ECN-013 R3) at every 100 m tap point.
- **CAP (contingency):** Pressurised crew descent pod, ~850 kg dry, 2 crew, 18 person-hr life support. Does NOT solve floor EVA thermal limits (2 hr at 40 K). Last-resort access.

## 4.4 Spatial Constraints

~310 MOLE-I positions at Shackleton (~8.5 km² usable floor). De Gerlache extension: ~45 positions, 5–10 km via Connecting Ridge. At LCROSS 5.6%+ ice fraction, Shackleton alone sufficient through P12. De Gerlache expansion is a P13+ decision gate only if chemical PROBE fleet exceeds ~370 units — rendered moot by Mk III transition.

---

# 5. Base Architecture — Layout and Safety

## 5.1 SPA Five-Zone Campus

Linear branching corridor design — safety architecture, not aesthetic. Dead-ends can be sealed; loops cannot.

1. **Habitat** — crew quarters, ECLSS, science labs. 4–8 crew (P4), 12–20 crew (P6+).
2. **ISRU plant** — 200–500 m from habitat (LH₂ hazard). VEX, electrolyser, cryocooler, cryo storage. Fully automated.
3. **Industrial Zone (IZ)** — adjacent to ISRU. Docking collars, ARM-D gantry, PROBE servicing, dust vestibule. SENTINEL cryo valve monitoring (ECN-014: 4× isolation valve stations, H₂/pressure/UV flame sensors, hardwired 24 VDC auto-close, dead-man fail-closed, fault patterns #201–#206).
4. **Beneficiation** — 1 km separation (dust hazard). Jaw crusher + screens + magnetic drums. Stage 1 physical only. ~810 t/yr at P7+.
5. **Power** — Shackleton ridge. Solar arrays + FSP. SPA MSR from Y105 (asteroid processing power).

O₂ to habitat via low-pressure stainless line with double-block-and-bleed isolation.

## 5.2 Base Specialisation (ECN-019)

**SPA (Shackleton) = Asteroid Processing Hub + Crew Base.** All asteroid material (M/C/S-type) processed at SPA. ISRU propellant. PROBE operations. Deep-space hub P14+.

**PKT (Procellarum) = KREEP REO Processing ONLY.** Every km² of PKT surface is valuable ore — no non-KREEP infrastructure. Fully autonomous (zero permanent crew; temporary 3–4 person commissioning crew P8 Wave 3 only). Processing circuits, haulers, conveyors, SINTER, MSR.

---

# 6. SKIP KREEP Operations — SPA Only, Retired P9

**NO SKIPs AT PKT — EVER.** SKIPs operate at SPA only (100 km hop range to SPA Basin KREEP exposures). The old reference to "PKT SKIPs" was an architectural error corrected by ECN-019.

| Phase | SKIPs | Raw KREEP (t/yr) | Stage 1 concentrate (t/yr) | Notes |
|-------|-------|-------------------|---------------------------|-------|
| P3 (M70+) | 1 | ~45 (pro-rated) | ~1.8 | ISRU prerequisite gate |
| P4 | 1 | 95.8 | 3.8 | |
| P5 | 2 | 191.6 | 7.7 | |
| P6 | 4 | 383.2 | 15.3 | Stage 2 hydromet gate |
| P7 | 8 (peak) | 766.4 | 30.7 | Last SKIP expansion |
| P8 | 8 (continuing) | 766.4 | 30.7 | SPA KREEP research while PKT ramps |
| **P9** | **0 (retired)** | **0** | **0** | **PKT 1,000 t/yr REO from 2,500 circuits** |

Fleet demand at 8 SKIPs: ~664 t/yr LH₂/LOX (58 MOLE-I equivalent). Retirement at P9 frees this propellant capacity for the growing PROBE fleet.

---

# 7. PKT Base Architecture (ECN-019)

## 7.1 No SKIPs, No MOLE-S at PKT

All PKT surface operations handled by mining-capable haulers (SEL-HAULER-001 Rev B) from P8 day one: ~1,450 kg dry, Na-S battery (300–350°C), SRM motors (Fe-Si laminations, Al windings), front bucket/blade (~150 kg, 200 kg/min). Self-load 5 t KREEP in ~25 min. ~57% in-situ fraction (was 92%). One vehicle class replaces both SKIP and MOLE-S at PKT.

Hauler fleet: 200 (P8) → 1,000+ (P9) → 14,881 (P10) → 148,810 (P11) → 1,488,096 (P12) → ~1,500,000 (P14+ SS).

**PKT base positioning principle:** Processing spine sited at the PKT/highlands boundary — one side faces inward to the ore field (hauler/conveyor input), the other faces outward to non-KREEP terrain where MSR fleet, foundry, and ELZ are placed. This maximises accessible ore area by keeping non-mining infrastructure off minable ground. Spine NEVER bisects a rich deposit. MSRs don't need to sit on ore — power distributed via buried Al bus cable (in-situ, ≤10 km runs at 1,000 VDC). DART pathfinder (P5–P7) selects the base site optimising for: (1) ore grade ≥200 ppm (target >500 ppm), (2) terrain flatness for spine construction, (3) proximity to PKT boundary contact. Ideal site: high-grade zone abutting the PKT/highlands boundary.

## 7.2 Construction Manifest — 4 Waves (~30,000 t, ~300 Starship flights)

All deliveries Earth→PKT direct (NOT via SPA):

**Wave 1 — Pioneer (Y25, ~200 t, 2 flights):** 20 SINTER sinter spine road + ELZ pad. 10 haulers grade terrain, supply regolith. 5 ARM-C unload cargo, position FSP. 2 SENTINEL commission power, verify construction. 4 FSP (~160 kW). Reagent plant. All autonomous, supervised from SPA at 0.5s latency.

**Wave 2 — Processing (Y26–28, ~8,700 t, 87 flights):** First 100 circuits (phased commissioning ~10/month). 36 FSP. 50 haulers. 4 charging hubs. Spine conveyor. Reagent supply (3 yr).

**Wave 3 — Commissioning (Y28–30, ~8,200 t, 82 flights):** **Temporary crew arrives (3–4 specialists, 6–12 months).** Tasks: commission foundry pilot (MRE cells, 25 t/yr), build first MSR cold structure (see §8), tune 200 circuits with real regolith, install catapult demonstrator (500 m/s, 23 t YBCO). Crew departs before MSR fuel loading.

**Wave 4 — Scale-up (Y30–35, ~12,900 t, 129 flights):** Remaining circuits to 308 total. Hauler expansion to 200. MSR autonomous fuel loading + first criticality. Conveyor spine pilot (~50 km). Road network to ~500 km.

Average: ~3,000 t/yr = ~30 flights/yr. Peak: Y28–30 at ~41 flights/yr.

## 7.3 Steel Conveyor Network (Replaces EM Catapults)

SEL-CATAPULT-001 Rev A **SUPERSEDED** for ore transport. 9,084 catapult hubs → 0. YBCO: 209,000 t → 0 for ore transport. Steel apron conveyors (~95% in-situ Fe-Ni + MRE iron) handle all Tier 3 transport (50–150 km).

| Parameter | EM Catapult (superseded) | Steel Conveyor (baseline) |
|-----------|------------------------|--------------------------|
| Annual Earth import (P12) | ~6,140 t/yr (~61 flights) | ~300–430 t/yr (~3–4 flights) |
| YBCO required | ~209,000 t | 0 |
| In-situ fraction | ~0% critical | ~95–97% |

Network: dendritic, ~87,500 km at P12. SRM drive stations every 1–2 km. Coilgun heritage retained for mass drivers only.

## 7.4 Tiered Depth Mining Architecture

Surface regolith (Tier 1, 0–20 m) supports the first ~50–100+ years at full rate using standard hauler bucket excavation. Beyond this, the hauler fleet transitions to progressively deeper open-pit mining with relocatable relay depots:

| Tier | Depth | Material | Method | Decision gate |
|------|-------|----------|--------|---------------|
| 1 | 0–20 m | Loose regolith + megaregolith | Standard hauler bucket | Current baseline |
| 2 | 20–100 m | Megaregolith + fractured basalt | Ripper/breaker hauler attachment, benched terraces, relocatable relay depots every 15–20 m vertical | DG-POST.1 (~Y280+) |
| 3 | 100–200 m | Competent fractured basalt | Heavy breaker or dedicated rock-breaking unit, multiple relay depots in series, sintered ramp network | DG-POST.2 (~Y380+) |

Each relay depot is a relocatable intermediate transfer station on a bench: receiving hopper + short inclined conveyor (20–25 m, 15–20° angle), towed into position by hauler, FSP- or MSR-powered. Beyond 200 m, entirely new extraction methods (in-situ leaching, deep boring, or technologies not yet conceived) become decision items. The PKT mare basalt column is 1–7 km thick (Kaguya/GRAIL), so KREEP-bearing material extends far deeper than any realistic mining horizon. Combined with projected 90%+ terrestrial REE recycling by the 23rd century reducing demand, the programme has no foreseeable resource constraint.

---

# 8. Thorium MSR Power Strategy

## 8.1 Why MSR

Processing circuits consume ~400 kW each. At P12 with 2.08M circuits: ~833 GW. Solar is insufficient for PKT (14-day lunar night). FSP is Earth-imported and doesn't scale. Thorium MSR uses fuel that is a free byproduct of REE processing.

## 8.2 Fuel Cycle

- **Th source:** Automatic byproduct — 300°C acid bake locks ~90–95% of Th into insoluble ThP₂O₇. Zero additional reagents.
- **Fuel:** ThCl₄ via carbothermic chlorination. Carrier salt: NaCl-KCl-MgCl₂ (all lunar-available).
- **Spectrum:** Fast neutron (no graphite — carbon scarce). BR 1.01–1.08.
- **Startup:** HALEU charge from Earth (one-time per MSR, sealed shielded cask).
- **Th budget:** ~54 t/yr consumed at P10 (74 MSR) vs ~387–773 t/yr produced → massive surplus.

## 8.3 MSR Construction — How Robots Build Nuclear Reactors

**Phase 1 — Cold structure (temp crew + ARM-C, 6–12 months):** Entirely non-radioactive. SINTER sintering foundation pad. ARM-C positions Hastelloy-N (or Ni-201 from P11+) vessel sections. Crew bolts reactor, installs heat exchangers, turbomachinery, piping. ARM-C positions radiator panels. SINTER + haulers fill 1–2 m regolith shielding berm. SENTINEL structural verification.

**Phase 2 — Crew departure.** Radiation hazard begins only at Phase 3.

**Phase 3 — Fuel loading (autonomous).** ThCl₄ from SPA via mass driver (or prepared at PKT). HALEU startup charge from Earth. Remote pumping, SENTINEL monitoring. Controlled from SPA Ops Hub at 0.5s latency.

**Phase 4 — First criticality.** Controlled from SPA. Automated load following.

**Scaling:** ~5 MSR/yr at P10 (2–3 crew rotations/yr). By P11+, ARM-C handles cold structure autonomously (20+ years of assembly experience).

## 8.4 MSR Fleet Progression

| Phase | PKT power | Source | MSR count | Key milestone |
|-------|-----------|--------|-----------|---------------|
| P8 | ~55 MW | 1,386 FSP (Earth) | 0 | ~40 t Th(OH)₄ stockpiled |
| P9 | ~100 MW | FSP + first MSRs | 1–3 | DG-9.3: confirm BR >1.0 |
| P10 | 7.4 GW | MSR fleet | ~74 × 100 MWe | MSR expansion, U-233 bootstrap |
| P11 | 67.9 GW | MSR fleet | ~679 × 100 MWe | Ni-201 in-situ vessels replace Hastelloy-N |
| P12 | 689 GW | MSR fleet | ~6,890 × 100 MWe | Self-sustaining fuel cycle |

SPA MSR fleet (asteroid processing): 1 unit Y105 (C-type, 50 MWe) + 1 unit Y125 (S-type, 100 MWe) + 1 unit Y140. ThCl₄ from PKT→SPA mass driver.

---

# 9. Mass Driver Network — 5 Drivers, 8 Tracks (ECN-020)

| ID | Route | Velocity | Tracks | YBCO/track (t) | Total YBCO (t) | Operational | Purpose |
|----|-------|----------|--------|----------------|----------------|-------------|---------|
| MD-1 | SPA→PKT | ~1,800 m/s | **2** (primary + redundant) | 60 | **120** | P8 (Y25) | Fe-Ni, Th(OH)₄, spares. Sole inter-site link — cannot afford single-point failure. |
| MD-2 | PKT→Earth | ~2,400 m/s | **3** (round-robin) | 80 | **240** | P9 (Y35) | REO canisters: **~694,444/yr (~1,903/day system, ~634/day per track, 1 every 136 s)**. 1 track offline for maintenance at any time — 2 tracks sustain ~1.67 Mt/yr. |
| MD-3 | PKT→SPA | ~1,800 m/s | 1 | 55 | 55 | P9–P10 (Y43) | ThCl₄ for SPA MSR. ~42 launches/yr. |
| MD-4 | SPA→Earth | ~2,400 m/s | 1 | 70 | 70 | P11 (Y70) | PGM exports. Foundation designed for future parallel track. |
| MD-5 | DRO→SPA | ~800 m/s | 1 | 38 | 38 | P12+ (Y85) | Asteroid concentrate. ~200 launches/day — comfortable single track. |

**Total YBCO: ~523 t lifetime** (~5 Starship flights) vs 209,000 t for 9,084 catapult hubs. The +220 t over single-track baseline (~$220M, 0.001% of programme cost) provides maintenance rotation and eliminates single-point logistics failures. Per-driver YBCO per SEL-CATAPULT-001 Rev B (authoritative).

**Parallel track rationale (ECN-020):** MD-2 single-track cadence of 1 launch every 45 s leaves zero margin for coil maintenance, thermal management, or canister feed failures. 3-track round-robin provides 136 s intervals per track with 1 offline for maintenance at any time. MD-1 redundant track prevents single-point inter-site logistics failure. All parallel tracks share a sintered foundation corridor (~50 m lateral spacing, independent cryocoolers and supercapacitor banks per track — no shared single points of failure).

TRL basis: EMALS (USS Gerald R. Ford, TRL 9, 45 t at ~100 m/s). Linear induction maglev (Shanghai, Chuo Shinkansen, TRL 9). With 33 years of heritage development, TRL 7–8 by ~2050 is defensible.

EM catchers at SPA: coilgun in reverse, ~60–70% regenerative. Three inbound streams: PKT→SPA canisters (ThCl₄), DRO→SPA concentrate, Mk III PROBE LLO canister ejections (~1,680 m/s). SPA EM catcher is shared infrastructure — separate from IZ docking gantry. Supports both Al canisters (eddy-current) and Fe-Ni canisters (ferromagnetic + eddy-current, dual timing profiles).

**Canister recovery (PKT→Earth):** Fe-Ni shell (ferromagnetic, from M-type asteroid Fe-Ni Y85+), ablative TPS (in-situ Al₂O₃/SiO₂). Recommended Option 1b: minimal drag chute (~28 kg Earth content/canister). Wall 8 mm Fe-Ni for ~50 m/s ocean impact survival.

---

# 10. Processing Architecture — Split Value Chain

## 10.1 D2EHPA Elimination

D2EHPA (C₁₆H₃₅O₄P) eliminated entirely. At P12 scale: 2.5 Mt/yr Earth supply → 0. The programme does NOT need to separate individual REEs on the Moon — the magnet industry accepts didymium (mixed NdPr) at $65–112/kg.

**Revised lunar flowsheet (zero ongoing carbon):** (1) Acid bake (H₂SO₄, in-situ, 300°C — auto-separates ~90% Th as ThP₂O₇). (2) Staged Ca(OH)₂ precipitation (in-situ, pH 3.8 — removes Th/Fe/Al). (3) U separation (H₂O₂ oxidation + pH 6.5). (4) Ce oxidation (electrochemical, zero reagent). (5) Eu reduction (Fe metal reductant from MRE/asteroid). (6) LREE/HREE split (Na₂SO₄ double sulfate, in-situ Na). (7) Concentrate shipment to Earth. (8) Earth-side final SX in existing overcapacity plants.

## 10.2 Optimised Processing Circuit

| Design | REO/yr | Mass (kg) | Power (kW) | Circuits for 2.5 Mt/yr |
|--------|--------|-----------|------------|------------------------|
| Batch (rejected) | 0.4 t | 15,000 | 180 | 6,250,000 |
| **Optimised (committed)** | **1.2 t** | **28,000** | **400** | **2,083,334** |

Circuit throughput optimisation is the single highest-value R&D investment ($22T cost reduction vs batch). Maintenance: 0.5% mass/yr. Earth fraction: 100% (P8) → 10% (P10) → 3% (post C-type Y105) → 0.8% (post S-type Y125). **Gate DG-8.X: validate ≥1.0 t/yr before full PKT commitment.**

*Note: 500 ppm processing grade (used in ECON modelling) refers to DART-selected high-grade site average and/or post-beneficiation concentrate grade. Bulk undifferentiated PKT regolith is 50–200 ppm. This is why DART site selection (DG-7.1/M127) and physical beneficiation (10× concentration) are prerequisites for economic operation.*

---

# 11. NEA Resource Strategy — Diversified Asteroid Captures

Published NEA resource estimates (~10 Mt REEs, ~500 kt PGMs, ~100 Gt Fe/Ni) appear to challenge the strategy. Concentration analysis confirms the opposite:

- **Asteroid REE:** ~5 ppm vs 1,000+ ppm economic ore. 200–5,000× below viable grade. NO asteroid REE extraction.
- **KREEP REE:** 50–2,000 ppm. The only space-accessible REE source with a viable extraction path.
- **Asteroid PGM:** 30–100 g/t vs 3–5 g/t best Earth mines. 6–33× grade advantage. PROBE fleet targets M-type exclusively.

## 11.1 Three Captures, Each Enabling the Next

The programme captures ONE of each type — not multiple M-types:

| # | Type | Capture | Processing | Provides | Impact |
|---|------|---------|------------|----------|--------|
| 1 | M-type (~200 m) | Y75→Y85 | PGM hydromet at SPA | 36.5 t/yr PGM, Fe-Ni | Hauler Earth frac →20%; 80+ yr campaign |
| 2 | C-type (~100 m) | Y95→Y105 | Pyrolysis + Fischer-Tropsch at SPA | Water, carbon, nitrogen | Circuit frac 10%→3%; propellant independence; PTFE in-situ |
| 3 | S-type (~100 m) | Y115→Y125 | Czochralski Si + Cu electrolysis at SPA | Silicon, copper | Circuit frac 3%→0.8%; sensors/wiring in-situ |

**All processing at SPA.** Products mass-driven SPA→PKT where needed. C-type surfaces covered with reflective MLI blanket (preserve subsurface ice in DRO solar exposure).

## 11.2 Infrastructure

- **Redirect tugs:** ~50,000 kg SEP/NEP, 20-yr life. Fleet: 2→3→5. Earth-built at $500/kg LEO. Safety: planetary defence review (UN COPUOS), impact probability <10⁻⁸, multiple abort windows.
- **Laser Ablation Truss:** 1 per captured asteroid in DRO. Dual laser heads, ~350 MW, 1,000 t/day. Spiral surface ablation (no mechanical contact). Heritage: DE-STAR (Lubin, UCSB). DG-13.2.
- **Captured asteroids do NOT use PROBEs** — dedicated permanent infrastructure. Architecturally independent.

---

# 12. Power Architecture

## 12.1 SPA Power

| Phase | Source | Capacity | Dominant consumers |
|-------|--------|----------|--------------------|
| P1–P3 | Solar (~1,218 m² by P4) | ~346 kW | MOLE-I network, ISRU plant, SINTER (self-powered) |
| P4–P6 | Solar + 4–8 FSP | ~506–666 kW | 25–85 MOLE-I, ISRU, hab life support, PROBE ops |
| P7 | Solar (~1,825 kW) + 11 FSP | ~2,265 kW | 170 MOLE-I, 5 circuits (2 MW staggered), pipeline (59.5 kW), 8 SKIP refuelling |
| P10+ | Solar + FSP + SPA MSR (from Y50) | Growing | PGM processing, Mk III EM catcher, asteroid processing (Y105+) |

Pipeline heating (59.5 kW continuous) is mission-critical load. FSP covers all critical loads during 72-hr eclipse design case.

## 12.2 PKT Power

| Phase | Source | Capacity | Dominant consumers |
|-------|--------|----------|--------------------|
| P8 Wave 1 | 4 FSP | ~160 kW | 20 SINTER (self-powered), hauler charging, ARM-C |
| P8 Wave 2–4 | 1,386 FSP | ~55 MW | 308 circuits (staggered), haulers, reagent plant |
| P9 | FSP + first MSRs | ~100 MW | 2,500 circuits (1 GW — MSR critical path), foundry, conveyors |
| P10 | ~74 MSR × 100 MWe | 7.4 GW | 25,000 circuits (10 GW), 14,881 haulers, 5,000+ km conveyor |
| P11 | ~679 MSR | 67.9 GW | 250,000 circuits, 148,810 haulers |
| P12 | ~6,890 MSR | 689 GW | 2,083,334 circuits (~833 GW), 1.49M haulers (~1.3 GW), conveyors (~0.5 GW) |

**Circuits dominate power demand** (~400 kW each). MSR process heat (200–300°C waste heat) dual-purposed for acid baking — reduces circuit electrical demand.

---

# 13. Life Support O₂ — Free Co-Product

O₂ surplus from ISRU electrolysis exceeds crew demand by 20–45× across all phases. Life support O₂ is effectively free.

| Phase | O₂ surplus (t/yr) | Crew demand (t/yr) | Coverage |
|-------|-------------------|-------------------|----------|
| P4 (25 MOLE-I, 4 crew) | 26.0 | 1.2 | ~22× |
| P6 (85 MOLE-I, 6 crew) | 82.2 | 1.8 | ~45× |
| P7+ (170 MOLE-I, 12 crew) | 158.0 | 3.7 | ~43× |

---

# 14. Economic Evaluation Summary

From SEL-ECON-001 Rev A (SELENITE_ECON v1.3/v1.4):

| Metric | Value |
|--------|-------|
| Total programme cost (200 yr) | $21.3 T |
| Average annual cost | $106 B/yr (4.7% of global military spending) |
| BCR (200-year, all externalities) | 0.50 |
| BCR (annual, steady state Y180+) | 2.06 |
| Steady-state net surplus | +$121.8 B/yr from Y181 |
| NPV (declining 3/2.5/2%) | −$0.49 T |
| CO₂ avoided at steady state | 182 Mt/yr |

**The programme is NOT commercially viable on direct revenue** ($1.48 T vs $21.3 T cost). The economic case rests on internalised externalities: avoided mining damage ($10.4 T), H₂ enabling via iridium ($2.6 T), geopolitical insurance ($1.2 T). Requires government-consortium funding per Arrow et al. (2014).

**Dominant sensitivity:** Discount rate ($1.17T NPV range) — the economic case is fundamentally a question of intergenerational ethics. Circuit throughput is highest-value R&D ($22T cost difference batch vs optimised).

**CO₂ balance at steady state:** 75 Mt/yr mining avoided + 107 Mt/yr H₂ via Ir − 0.3 Mt/yr rockets = **181.7 Mt/yr net positive.** DAC methane: 100% fossil (Y0–30) → 5% (Y80+).

---

# 15. P13/P14/P14+ — Earth Independence

## 15.1 Timeline

| Phase | Years | REO t/yr | Milestone |
|-------|-------|----------|-----------|
| P12 | Y80–120 | 100k→500k | M-type asteroid online; 36.5 t/yr PGM |
| P13 | Y120–140 | 500k→1.25M | C-type online; propellant independence; circuit frac →3% |
| P14 | Y140–180 | 1.25M→2.5M | S-type online; circuit frac →0.8%; Earth independence assessment (DG-14.6) |
| P14+ | Y180+ | 2,500,000 (SS) | Maintenance only. +$121.8B/yr surplus. |

**PKT resource adequacy:** Total accessible KREEP REE at PKT to 200 m depth: ~220–660 Mt (at 100–300 ppm bulk grade, 1,800 kg/m³ megaregolith). At 2.5 Mt/yr from Y180: ~88–264 years of supply (to ~Y268–Y444). DART-selected high-grade sites (300+ ppm) extend this further. Post-P14 expansion via tiered depth mining (§7.4): hauler upgrades (ripper/breaker attachments, relay depot chains), fleet expansion across PKT's 6.1M km², or new extraction methods beyond 200 m. PKT mare basalt column is 1–7 km thick — KREEP-bearing material extends far deeper than any mining horizon. Earth REE recycling (projected 90%+ by 23rd century) progressively reduces demand. Resource depletion is not a binding constraint on any programme-relevant timescale.

## 15.2 Earth Fraction Trajectory

| Year | Circuit | Hauler | MSR | Dependency |
|------|---------|--------|-----|------------|
| P8 (Y25) | 100% | 100% | 100% | Everything from Earth |
| P10 (Y55) | 10% | 43% | 30% | Foundry produces steel, Al |
| P12 (Y85) | 10% | 33% | 30% | M-type Fe-Ni improves hauler |
| Post C-type (Y115) | 3% | 25% | 30% | PTFE, polymers in-situ |
| Post S-type (Y135) | **0.8%** | **20%** | 30% | Si sensors, Cu wiring in-situ |

By Y135: only advanced ICs, specialty optics, and precision bearings from Earth (<0.5% of infrastructure mass). The programme becomes a self-sustaining cislunar industrial civilisation.

---

# 16. Open Items and Phase Gates

| Gate | Trigger | Consequence if not met |
|------|---------|----------------------|
| PSR ice fraction (SURVEY-1) | In-situ characterisation before drilling | Pessimistic 3.0% → −33% yield → +10 MOLE-I at P7+ |
| ISRU verification (Y5.5) | Cryogenic LH₂/LOX available M64+ | SKIP delayed; P3/P4 slip |
| DART PKT ground truth (M127) | XRF confirms 5–10× SPA grade | PKT base does not proceed |
| Thorium MSR decision (DG-7.5, ~2040) | Terrestrial MSR demonstrates sustained BR >1.0 | Continue FSP-only (limits PKT scaling) |
| **Circuit throughput (DG-8.X)** | **Validate ≥1.0 t/yr before full PKT build-out** | **Batch design costs +$22T over 200 years** |
| PKT→Earth mass driver (DG-9.1) | Canister recovery architecture decision | Full parachute (+$26B/yr vs minimal chute) |
| **Mk III PROBE (DG-11.6)** | **Ion SEP validated; EM catcher operational** | **Chemical-only fleet caps at ~355 MOLE-I** |
| C-type asteroid (DG-14.1, Y95) | Target selection for polymer precursors | Circuit Earth frac stays at 10% |
| S-type asteroid (DG-14.2, Y115) | Target selection for Si/Cu feedstock | Circuit Earth frac stays at 3% |
| **Earth independence (DG-14.3, Y140)** | **Comprehensive Earth dependency audit** | **Identifies remaining irreducible imports** |
| DG-POST.1 (~Y280+) | Tier 1 surface regolith approaching depletion at active sites | Commit hauler ripper/breaker attachments + relay depots for Tier 2 (20–100 m) |
| DG-POST.2 (~Y380+) | Tier 2 megaregolith approaching depletion | Commit heavy breaker units + sintered ramp network for Tier 3 (100–200 m) |

---

# 17. Document History

| Version | Description |
|---------|-------------|
| v2.3 | Initial strategy register. ISRU constraint, PROBE/SKIP/DART logistics, MOLE architecture, base layout, NEA resource strategy, life support O₂, SKIP KREEP scope. March 2026. |
| v2.6 | ECN-012 (drain pipe), ECN-013 (navigation, SATS+WEB, bayonet adapter, spools), ECN-014 (SENTINEL valve monitoring), ECN-015 (100-year scaling, dual-base), ECN-016 (haulers, Mk II PROBE, catapults), ECN-017 (in-situ manufacturing, catapult scaling) applied as appendices. March 2026. |
| **v3.0** | **All ECNs integrated into body (no appendices). ECN-019 Rev C: 2.5 Mt/yr target, demand-driven MOLE-I (48,990/390,790 eliminated), SKIP retired P9 (NO PKT SKIPs), PROBE Mk III SEP (ion, never-lands, EM anchoring), hauler Rev B at P8 (Na-S, SRM, mining bucket, ~57% in-situ), catapults→conveyors, D2EHPA eliminated (split value chain), thorium MSR for PKT power, optimised circuits (1.2 t/yr, 2.08M), 5 mass drivers (~303 t YBCO lifetime), base specialisation (SPA=asteroid, PKT=KREEP), diversified asteroids (M/C/S-type), laser ablation truss, P13/P14/P14+ phases, Earth independence trajectory (0.8% circuit frac by Y135), economic evaluation ($21.3T cost, BCR 0.50/2.06, +$121.8B/yr SS surplus). April 2026.** |
| **v3.1** | **ECN-020 applied: MD-2 parallel tracks (3×, round-robin, ~694,444 canisters/yr at 2.5 Mt/yr — was 285,715 at stale 1.0 Mt/yr). MD-1 redundant track (2×). Total YBCO ~523 t (was ~303 t single-track; per-driver allocations corrected per SEL-CATAPULT-001 Rev B). PKT base positioning principle (spine at PKT/highlands boundary). Resource adequacy (220–660 Mt accessible, ~88–264 yr at rate — corrected from debunked 225,000+ yr). Tiered depth mining (Tier 1/2/3 + DG-POST.1/POST.2). 500 ppm grade clarified as DART-selected/beneficiated. April 2026.** |

---

*— End of SEL-T1.1-STRATEGY v3.1 —*
