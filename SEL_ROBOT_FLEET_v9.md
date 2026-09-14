# SELENITE PROGRAMME — Robotic Fleet Engineering Specifications

**SEL_ROBOT_FLEET v9.0 — All ECNs Applied (ECN-012 through ECN-019 Rev C)**

**200-Year Programme Architecture — 2.5 Mt/yr REO Committed Target**

REF: SEL_ROBOT_FLEET v8 + ECN-012/013/014/015/016/017/019 Rev C. Lead: Jason (Systems Engineering). Status: DRAFT. April 2026.

This document is the single authoritative reference for ALL robotic fleet specifications, fleet scaling, and supporting infrastructure in the Selenite Programme. It supersedes v8 and all ECN amendments. Individual robot design documents (SEL_MOLEI_DESIGN_v5, SEL_PROBE_DESIGN_RevA, SEL-HAULER-001_RevB, etc.) provide manufacturing-level detail; this document provides the integrated fleet-level architecture.

---

## 1. Fleet Overview

The Selenite robotic fleet comprises twelve vehicle classes. SPA vehicles are Earth-manufactured throughout. PKT vehicles transition to ~57% in-situ manufacture from P10.

| Class | Type | Primary Role | Base | Initial | Peak |
|-------|------|-------------|------|---------|------|
| PROBE Mk I | Spacecraft | Round-trip Ni-Fe/PGM return (chemical) | SPA | 3 | 96 (P8) |
| PROBE Mk II | Spacecraft | Heavy asteroid processor, in-situ beneficiation | SPA | — | 260 (P11) |
| PROBE Mk III | Spacecraft | Ion SEP, never lands, EM anchoring, bulk mining | Orbit | — | 1,714 |
| MOLE-S | Surface rover | Rim/surface excavation & construction (SPA ONLY) | SPA | 4 | 6 |
| MOLE-I | PSR rover | Shackleton PSR ice extraction (permanent) | SPA | 10 | 355→~50 |
| SINTER | Construction | Regolith sintering, roads, pads, structures | Both | 3 | 200+ |
| SURVEY | Prospector | Geological mapping (surface + orbital) | SPA | 1 | 2 |
| SKIP | Sub-orbital | SPA Basin KREEP collection (RETIRED P9) | SPA | 1 | 8 |
| DART | Orbital transfer | PKT collector via LLO (pathfinder) | SPA | — | 1 |
| ARM-C / ARM-D | Manipulator | Construction, docking, cargo, maintenance | Both | 2 | 200+ |
| SENTINEL | Inspection | Structural validation, fleet monitoring, safety | Both | 2 | 4,000+ |
| Hauler | Surface vehicle | PKT mining, transport, grading, trenching | PKT | — | 1,488,096 |

**Key architectural constraints:** (1) NO SKIPs AT PKT — EVER. (2) MOLE-S deploys to SPA ONLY. (3) Haulers are PKT-only. (4) PKT is fully autonomous (zero permanent crew). (5) PROBEs base permanently at SPA (propellant constraint). (6) All asteroid processing at SPA (not PKT).

Cold spare requirement: 1 unit per robot class on-surface at all times. Resupply cadence ~2-yearly.

---

## 2. PROBE — Asteroid Survey & Return Spacecraft

### 2.1 PROBE-Scout (One-Way Survey, Expendable)

| Parameter | Specification |
|-----------|--------------|
| Role | One-way NEA survey and XRF confirmation. Expendable — stays at target. |
| Dry mass | ~101 kg (body + instruments) |
| Wet mass | 243 kg (101 dry + 142 kg Earth-supplied LH₂/LOX) |
| ΔV | ~3,876 m/s one-way (Tsiolkovsky verified) |
| ISRU propellant | NO — Earth-supplied only; arrives before ISRU operational |
| Docking collar | NO — provisional surface capture only (M32 collar, ARM surface transfer) |
| Fleet count | Not counted in operational fleet. Secondary payloads on cargo launches. |
| Dispatch strategy | 3–5 scouts simultaneously to different candidates; best-confirmed target selected |

### 2.2 PROBE Mk I — Chemical Return Vehicle (P3–P11)

| Parameter | Specification |
|-----------|--------------|
| Dry mass (Ops) | ~800 kg (body + payload instruments + enlarged tanks) |
| Wet mass (ISRU) | 8,950 kg (800 dry + 1,500 payload + 6,654 ISRU LH₂/LOX) |
| Propellant/mission | 6,654 kg LH₂/LOX (6 km/s round-trip ΔV to low-ΔV NEA) |
| Isp | ~450 s (LH₂/LOX bipropellant); methalox fallback 310 s |
| Payload target | 1,500 kg Ni-Fe/PGM semi-raw (no beneficiation) |
| Mission cadence | 1 mission/craft/yr (Ryugu-class ~3–4 km/s one-way from LLO) |
| MOLE-I equivalence | 0.855 PROBE missions per MOLE-I per year (5,692 ÷ 6,654) |
| Docking interface | PROBE collar: soft-capture + conductive charging pins, SpaceWire data |
| Navigation | Terrain-relative (SLIM heritage, 55 m accuracy) + star tracker + IMU + radar altimeter |
| Targeting | Preferentially target low-ΔV NEAs to maximise missions per tonne ISRU |
| Fleet scaling | P3: 3 → P4: 6 → P5: 10 → P6: 15 → P7: 30 → P8: 96 → P9: 30 (phased to Mk II) |

Do NOT attempt REE extraction from asteroid payloads. NEA REE ~5 ppm vs 1,000+ ppm economic ore — 200–5,000× below viable grade.

### 2.3 PROBE Mk II Heavy — Asteroid Processor (P9–P11+)

| Parameter | Specification |
|-----------|--------------|
| Dry mass | ~5,000 kg (vs 800 kg Mk I) |
| Propellant capacity | 40,000 kg LH₂/LOX |
| In-situ beneficiation | On-asteroid: magnetic drum separator + centrifuge. Processes 500 t of asteroid regolith on-site. Returns 10 t of 50× PGM-concentrated material. ~17.5 kg PGM per mission. |
| Dwell time | Weeks to months (vs days for Mk I) for in-situ processing |
| Mission profile | Same orbital mechanics as Mk I but longer on-asteroid dwell |
| Fleet scaling | P9: 190 → P10: 230 → P11: 260 (peak) → phasedown to 30 |

### 2.4 PROBE Mk III SEP — Ion Bulk Miner (P11+, DG-11.6)

| Parameter | Specification |
|-----------|--------------|
| Dry mass | ~1,200 kg. Larger solar arrays than Mk I/II (no landing loads, no dust). |
| Propulsion | Ion (xenon/argon from asteroid volatiles or Earth supply). Zero ISRU LH₂/LOX. |
| Landing | NEVER lands on the Moon. Stays in orbit permanently. |
| Payload delivery | Ejects 10 t Fe-Ni/PGM canisters from LLO on ballistic deorbit trajectory. |
| EM catcher | SPA receives at ~1,680 m/s — same YBCO coil technology as mass drivers, run in reverse. PKT→SPA receiver (built P9–P10) serves double duty. |
| Canister | Fe-Ni shell (ferromagnetic, compatible with EM braking) + cold-gas kick motor (~5–10 kg) for trajectory shaping. |
| Anchoring | Electromagnetic anchor pads on M-type asteroid Fe-Ni surface. No harpoons, no drills. Attachment force enormous relative to ~0.0001 m/s² surface gravity. Heritage: Northrop Grumman MEV-1 (2020). |
| Fleet build-out | ~86/yr from Y60–Y80 → ~1,714 peak. Reduces to ~300 after all asteroid captures complete (Y115+). |
| Missions | 0.5 missions/yr per unit |

**Mk III operational sequence:** (1) Ion thrust transit 3–8 months. (2) Velocity matching to cm/s. (3) LiDAR surface mapping at 100 m. (4) Terminal approach at 2–5 cm/s. (5) EM anchor engagement (3–4 pads). (6) Scraper mining 6–12 months. (7) Disengage (cut current), cold-gas separation, ion return.

### 2.5 Fleet Phasedown and Propellant Cascade

| Year | Mk I/II fleet | Mk III fleet | Chemical propellant demand | MOLE-I needed |
|------|---------------|-------------|---------------------------|---------------|
| Y45 (P10) | 230 | 0 | 1,530 t/yr | ~280 |
| Y60 (P11 start) | 260 | 0 | 1,730 t/yr | ~320 |
| Y70 | 150 | ~860 | 998 t/yr | ~190 |
| Y80 (P11 end) | 50 | ~1,714 | 333 t/yr | ~70 |
| Y85 | 30 | ~1,714 | 200 t/yr | **~50** |
| Y110+ | 30 | 1,714→300 | ~0 from lunar ice (C-type water) | ~50 (ECLSS only) |

Mk III uses ZERO ISRU propellant — the architectural change that drops MOLE-I from ~355 peak to ~50 from Y85. Decommissioned Mk I/II salvaged at SPA — Fe-Ni frames, motors, electronics recycled (~184 t recovered).

**Captured asteroids do NOT use PROBEs.** Dedicated Laser Ablation Truss + mass driver (MD-5). Architecturally independent systems.

---

## 3. MOLE-S — Surface Excavation Rover (SPA Only)

**MOLE-S deploys to SPA ONLY. Not deployed to PKT under any circumstance.** At PKT, all excavation, grading, trenching, and material handling is performed by mining-capable haulers (SEL-HAULER-001 Rev B).

| Parameter | Specification |
|-----------|--------------|
| Dry mass | ~350 kg (5× RASSOR 2.0 at 67 kg — scaled for industrial throughput) |
| Dimensions (stowed) | 2.8 × 1.6 × 1.2 m |
| Excavation mechanism | Dual counterrotating bucket drums — zero net horizontal reaction force (RASSOR patent heritage). Drum: 0.45 m dia × 0.50 m. |
| Excavation rate | 50 kg/hr (loose regolith, standard surface temp range) |
| Regolith payload | 350 kg per dump cycle |
| Locomotion | 6 independently driven/steered spring-steel mesh wheels (0.45 m dia); symmetric self-righting; rocker-bogie suspension with Ti flexure pivots (no springs, no dampers, no hydraulics — pure linkage geometry, JWST heritage) |
| Speed | 0.2 m/s loaded / 0.5 m/s unloaded |
| Grade capability | 25° |
| Power | 800 W excavation / 250 W transit / 50 W standby |
| Battery | 5,000 Wh Li-ion dual-redundant; ~6 hr continuous excavation |
| Charging | 1,500 W / 120 VDC at docking station; ~3.5 hr full recharge |
| Drill head (optional) | Vibratory auger for compacted substrate >30 cm depth |
| Autonomy | SAE Level 4; auto-dig PID via drum current control; visual SLAM + LiDAR + UWB |
| Dust mitigation | PTFE labyrinth seals (>1M cycles, NASA tested); EDS optics; WC drum tips |
| Thermal range | −55°C to +70°C; no PSR hardening |
| Dump interface | Z-position vertical dump into hopper (1.0 × 1.0 m aperture) |
| Fleet role | Construction support (P2–3) → rim maintenance (P4+) → regolith supply to SINTER (P5+) → SPA-only steady state (P7+) |
| Fleet count | 4 (P3) → 6 (P6+). Constant thereafter. |

---

## 4. MOLE-I — PSR Ice Extraction Rover (Demand-Driven Scaling)

### 4.1 Core Specification

| Parameter | Specification |
|-----------|--------------|
| Dry mass | ~360.65 kg (post ECN-013 Rev 2: +NAV-001 IMU +bayonet adapter CON-001) |
| Dimensions (stowed) | 1.8 × 1.2 × 0.8 m |
| Propellant yield | 5,692 kg/yr per unit (7,818 kg/yr water × 0.722 electrolysis efficiency) |
| Wheels | 6 independently driven Ti-6Al-4V mesh wheels, 0.3 m dia. Symmetric self-righting. Rocker-bogie with Ti flexure pivots. |
| Speed | 0.5 m/s transit (battery only) / 0.2 m/s during drill operations |
| Grade capability | ≤5° (PSR floor approximately flat; cannot ascend crater wall) |
| Drill (Mk I) | Rotary-percussive, 200 W, 800 mm operational depth. WC-tipped auger bits. ESA PROSPECT heritage (CDR complete, TRL 5–6, tested <123 K). |
| Mini-VEX (integrated) | Thermal extraction, ~85% water recovery. 1,200 W operational (sublimation ~885 W + sensible heat ~116 W + bulk regolith ~300 W, minus ~100 W drill heat recovery). All actuation electromechanical — no hydraulics at 40 K. |
| Power (operating) | ~1,934 W at tether: 300 W drive + 200 W drill + 1,200 W mini-VEX (1000 VDC direct, SiC MOSFET, 833 Ω nichrome) + 15 W WEB + 20 W comms + 50 W mechanical thermal keep-alive (30 W gearbox heaters 6×5 W + 15 W drill bearing + 5 W receptacle) + 99 W DC-DC losses + 50 W battery charge |
| Power (standby) | ~65 W total: 15 W WEB (273 K setpoint) + 30 W gearbox heaters + 15 W drill bearing + 5 W receptacle + 0 W mini-VEX (eliminated by Cu thermal strap) |
| WEB | Warm Electronics Box, 273 K setpoint, Cu braid thermal strap from mini-VEX waste heat. 20+ layer MLI. 3× LWRHU (1.1 W each, 3.3 W total) for extended survival (>200 hr above 253 K). Wax thermal shunt (n-tetradecane, 278 K, passive) prevents drill overheating. **WEB loss is immediately fatal — electronics freeze permanently at 90 K.** |
| Transit battery | ~334 Wh (1.3 kg). 65 W keep-alive × 4.7 hr × 1.10 margin. 250 Wh/kg space-grade Li-ion inside WEB at 273 K. Sufficient for 8.3 km intra-floor transit at 0.5 m/s. |
| Navigation (ECN-013) | Three-layer: (1) Tether-based polar fix (drum payout range + DRM-040 2-axis angle encoder on substation guide roller, ±0.5 m at 200 m). (2) Wheel odometry (6× existing encoders). (3) MEMS IMU (SEL-MI-NAV-001, 0.05 kg, 0.3 W, inside WEB). Kalman filter fusion on existing PLC at 10 Hz. Workspace drill grid: 3,600 cells per sector (polar grid, 2 m radial × 2° angular bins), stored in non-volatile flash (50 kB). Enables systematic mining with no gaps over 15+ year service life. |
| Bayonet adapter (ECN-013 R2) | Motorised (SEL-MI-CON-001), mounted on chassis underside. 28 V DC motor inside WEB, 0.3 kg, 2 W intermittent (0.5 s per cycle). 90° twist-lock engagement with construction tap sockets. Passive detent hold (zero power). Same adapter engages SATS taps, branch cable taps, substation taps — standardised 20 mm bayonet profile programme-wide. |
| Drain pipe (ECN-012) | Rear nozzle (rerouted from vertical mid-chassis exit). Trace-heated 15 W during dump retraction only (11.5% duty, 1.7 W average). Heating sequence: pre-heat at 90% tank → heater on during retraction (33 min) + dump (15 min) + post-dump purge (3 min). |
| Mini-VEX water path | Batch dump: 50 L insulated tank → substation manifold (ground level, inside WEB) → 10 W transfer pump lifts ~3 m into elevated branch pipe → branch pipe gravity-feeds to trunk junction → trunk pipe at floor level → 408 W trunk pump at CLP (68 bar, 0.042 kg/s) → rim ISRU facility |
| Cable drum heater | 8 W, on substation (NOT on MOLE-I). Prevents cable freeze-bond to drum. |
| Deployment | Rim-anchored descent winch; Kevlar or Vectran cable ONLY (Dyneema excluded: Tg ~123–153 K → brittle embrittlement, snap-failure risk; Kevlar retains tensile to <4 K: +4% strength, +13% modulus at 77 K). 0.5 m/s, ~4.7 hr over 8,400 m slope. |
| Permanent PSR residence | MOLE-I stays in PSR permanently; never retrieved during programme |
| Harness | 57 conductors through WEB wall (all Manganin 100 mm transition). Post ECN-013 R2. |
| Cargo manifest rate | ~4 MOLE-I per cargo launch (~360 kg/unit dry; ~1,440 kg/launch allocation) |

### 4.2 MOLE-I Mk II Deep Drill Retrofit (ECN-016 §2, Retained)

The Mk II is NOT a new vehicle — it is a field retrofit of the existing Mk I chassis. Only the drill module is replaced.

| Parameter | Specification |
|-----------|--------------|
| Drill type | Telescoping segmented auger. 3 nested sections (outer 200 mm OD, mid 150 mm, inner 100 mm). Retracted: 1,200 mm (same as Mk I). Extended: 5,000 mm. Future Mk IIb: 10,000 mm with 4 sections. |
| Extension mechanism | Electric lead-screw actuator, sequential section extension with spring detent locks. Full cycle: ~5 min. |
| MLI thermal integrity | CRITICAL: Inconel 718 corrugated bellows at chassis penetration (cryogenically stable to 20 K, fatigue life >100,000 cycles). Heat leak <0.5 W. Single most critical thermal component in the Mk II upgrade. |
| Counterbalance | Mk II drill assembly ~15 kg heavier. 20 kg tungsten slug at aft chassis rail. Total: +35 kg. CG within 5 mm of Mk I position. Standardised ORU. |
| Power compatibility | Same 200 W motor. Actuator: +50 W intermittent (~5 min/cycle). <3% total increase. No substation modifications required. |
| Rollover schedule | P8–P9: gradual retrofit at scheduled drill replacement (every ~2 yr). 10–20 units/month at rim station. Full fleet Mk II by end P9. |

### 4.3 Demand-Driven Scaling (Corrected)

**Old figures 48,990 (P8) / 390,790 (P9) MOLE-I ELIMINATED.** Driven by chemical tanker flights SPA→PKT to fuel PKT-based SKIPs — architecture removed by ECN-019 (mass driver at P8, no SKIPs at PKT). Shackleton crater floor physically accommodates ~310 MOLE-I maximum (~62 substations on ~8.5 km² usable flat area). Correction saves ~$850B.

| Phase | Years | MOLE-I | PROBE fleet | SKIP (SPA) | Supply (t/yr) | Demand (t/yr) | Margin | Notes |
|-------|-------|--------|-------------|------------|---------------|---------------|--------|-------|
| P3 | Y4–7 | 10 | 3 | 1 | 56.9 | ~0 | Stockpile | Accumulation |
| P4 | Y7–9 | 25 | 6 | 1 | 142 | 124 | +14.7% | Crew arrival |
| P5 | Y9–12 | 50 | 10 | 2 | 285 | 238 | +19.6% | DART begins |
| P6 | Y12–15 | 85 | 15 | 4 | 484 | 434 | +11.5% | Processing online |
| P7 | Y18–25 | 170 | 30 | 8 | 968 | 868 | +11.5% | Peak SKIP fleet |
| P8 | Y25–35 | ~247 | 96 | 8 | 1,406 | 1,403 | +0.2% | Mass driver online |
| P9 | Y35–45 | ~240 | ~190 | 0 (retired) | 1,367 | 1,364 | +0.2% | SKIPs retired |
| P10 | Y45–60 | ~280 | ~230 | 0 | 1,594 | 1,630 | −2% | de Gerlache extension |
| P11 | Y60–80 | ~320→~50 | 260→30 | 0 | var | var | var | Mk III transition |
| P12+ | Y80+ | ~50 | 30 chem | 0 | ~285 | ~300 | C-type water | Ion fleet dominates |

Spatial constraints: ~310 positions at Shackleton, ~45 at de Gerlache (5–10 km via Connecting Ridge). At LCROSS 5.6%+ ice, Shackleton alone sufficient. De Gerlache expansion is a P13+ decision gate only if chemical PROBE fleet exceeds ~370 — rendered moot by Mk III transition.

---

## 5. SINTER — Regolith Sintering Construction Rover

| Parameter | Specification |
|-----------|--------------|
| Dry mass | ~2,200 kg (ATHLETE mobility platform + sintering payload + 10 kWe onboard fission reactor) |
| Dimensions (stowed) | 4.0 × 3.2 × 2.8 m |
| Mobility | 6-limbed ATHLETE wheel-on-limb; rolls 1–5 km/hr transit; locks for 0.5–5 mm/s sintering raster |
| Wheel spec | Michelin composite lunar wheels, 0.6 m dia, validated over 5,000 km in liquid nitrogen |
| Grade capability | 25° soft regolith / 35° sintered surface |
| Sintering method 1 (primary) | Concentrated solar: 2.37 m² Fresnel lens → 188 W/cm² at 45 mm spot → 1,000–1,100°C; 10–15 cm²/min; daytime only |
| Sintering method 2 | CO₂ laser 5 kW @ 10.6 μm; night operations + solar-inaccessible areas |
| Sintering method 3 | Microwave 2×1 kW magnetrons @ 2.45 GHz; volumetric/subsurface; 286 mm penetration |
| Energy efficiency | Solar: ~15 kWh/m³ vs Microwave: ~615 kWh/m³ — use solar where possible |
| Cooling rate constraint | Must not exceed 15°C/min — exceeding causes cracking in sintered material |
| Primary power | 10 kWe onboard fission reactor (Kilopower KRUSTY derivative, ~1,500 kg) — self-powered, NOT connected to base grid |
| Supplementary power | 2.5 kW solar panels (daytime boost) |
| Energy storage | 40 kWh Li-ion (4 × 10 kWh modules) on 120 VDC bus |
| Onboard hopper | 500 kg (0.33 m³); 2.5–10 hr continuous operation |
| Robotic arm | 3.0 m reach, 7-DOF, 150 kg payload at tip; quick-disconnect tool adapters |
| Positioning precision | ±0.5 mm beam, ±2 mm layer registration, ±5 mm surface flatness over 1 m² |
| Road output | ~100 m/day per unit (Mode A sintering, 3 m width, 100 mm depth) |
| Operational range | 20 km from base (nuclear power; not energy-limited) |
| Fleet scaling | 3 (P3) → 3+ (P7) → 20+ (P8) → 50+ (P10) → 200+ (P12) → ~50 (P14+ maintenance) |
| Mandate | NEVER decommission all SINTER units. Ongoing hab expansion and road maintenance require sintering throughout programme. |

Solar sintering achieves <5 MPa compressive strength; structural applications require ≥6 MPa. Use solar for paving/roads; laser for structural load-bearing. Risk: real lunar regolith contains nanophase metallic Fe⁰ from space weathering — causes different microwave behaviour vs simulant.

---

## 6. SURVEY — Geological Prospector

| Parameter | Specification |
|-----------|--------------|
| Mass | ~180 kg (small rover with instrument payload) |
| Mobility | 4-wheel rocker-bogie; ~10 km range from base |
| Power | ~200 W solar + 500 Wh Li-ion buffer |
| Instrument 1: GPR | Ground-penetrating radar: subsurface structure to ~3 m depth; maps ice distribution, regolith stratigraphy |
| Instrument 2: pXRF | Portable X-ray fluorescence: in-situ elemental analysis; identifies KREEP zone boundaries (K, REE, P, Th) |
| Instrument 3: Seismic | Deploy-and-retrieve geophones; characterises subsurface bulk density and compaction for MOLE planning |
| Navigation cameras | Stereo pair for terrain mapping; feeds SKIP target coordinate database |
| Data output | KREEP grade map → SKIP target prioritisation AI pipeline |
| SURVEY surface mission | SPA Basin KREEP zone mapping; ongoing target queue for SKIP-1 from P3 |
| SURVEY orbital mission | Process LRO/Lunar Prospector thorium orbital maps; rank high-grade PKT sites for DART routing |
| Fleet | 1 (P3) → 2 (P5+, 1 surface + 1 orbital). Constant. |
| Prerequisites | Must characterise min 20 SKIP target sites before SKIP-1 authorised. Must rank PKT targets before DART P5 mission planning. |

---

## 7. SKIP — Sub-Orbital KREEP Hopper (SPA Only, Retired P9)

**NO SKIPs AT PKT — EVER.** SKIPs operate at SPA only (100 km hop range to SPA Basin KREEP exposures). The old SEL-PROC-PKT-001 §3 reference to "PKT SKIPs" was an architectural error corrected by ECN-019.

| Parameter | Specification |
|-----------|--------------|
| Vehicle class | Sub-orbital hopper; stronger ascent/descent engines than PROBE for rapid hops |
| Mass | ~300 kg dry; ~400 kg wet per hop |
| Propellant per hop | 303 kg LH₂/LOX (100 km range, 1,690 m/s round-trip ΔV). Original 94.6 kg / 600 m/s was incorrect — achievable range only 12.6 km. |
| Payload | 400 kg KREEP regolith per hop |
| Cadence | 1 hop/day max (limited by MOLE-S pre-excavation: 50 kg/hr × 7 hr = 350 kg ready per hop). 274 hops/yr at 75% avail. |
| KREEP yield per craft/yr | 109.6 t raw KREEP (274 hops × 400 kg) |
| Fleet aggregate demand (8 SKIPs) | ~664 t/yr LH₂/LOX propellant (58 MOLE-I equivalent) |
| Landing site | Unimproved natural terrain; autonomous precision landing (JAXA SLIM heritage, 100 m-class) |
| Landing pad | Dedicated SKIP pad — SEPARATE from all PROBE docking collars |
| Refuelling | ISRU cryogenic quick-disconnect; LH₂/LOX from ISRU tanks only. CANNOT fly on Earth-supplied propellant. |
| Guidance | Tighter autonomous loop than MOLE — flight dynamics require faster exception handling |
| First hop | Month 70 (Y5.8) — SKIP-1 first sub-orbital KREEP collection |
| Fleet scaling | P3: 1 → P4: 1 → P5: 2 → P6: 4 → P7: 8 (peak) → P8: 8 → **P9: 0 (RETIRED)** |
| Retirement reason | PKT 2,500 circuits produce 1,000 t/yr REO; SPA's 5-circuit 0.4 t/yr is irrelevant |

---

## 8. DART — Deep-Range Autonomous Return Transport

| Parameter | Specification |
|-----------|--------------|
| Transfer architecture | LLO orbital transfer — NOT ballistic arc (3,300 km requires ~72° launch angle → ~13,200 m/s ΔV → 30+ t propellant. Physically impractical.) |
| Round-trip ΔV | ~7,400–8,900 m/s (15% contingency) |
| Propellant per mission | ~12,370 kg LH₂/LOX at planning ΔV ~8,200 m/s |
| Minimum economic payload | 1,200 kg PKT material (≈ 10,000 kg SPA-equivalent after beneficiation) |
| PKT ore grade advantage | 5–10× SPA Basin; 10–15 ppm Th vs 1–3 ppm SPA |
| Mission cadence | Biennial (limited by ISRU stockpile: ~4 months accumulation at P5 surplus) |
| Onboard instruments | XRF spectrometer + autonomous rotary-percussive sample drill |
| Landing site | Autonomous precision landing at unimproved PKT site — no pad, no infrastructure |
| Guidance | Full orbital mechanics autonomy: ascent → LLO coast → deorbit → powered descent |
| Comms | Relay satellite coverage required. 3 EML-2 for continuous. Blackout possible during far-side transit. |
| Arrival | Cargo Launch 4 (M108, Y9). First PKT mission: M127 (Y10.6). |
| Fleet | 1 unit. Pathfinder for P5–P6. DART propellant demand zero from P8 (operates on PKT surface power via mass driver). |
| Phase 7+ role | DART missions absorbed by PKT base infrastructure; DART retained for recon/repurposed |

---

## 9. ARM & SENTINEL — Support Fleet

### 9.1 ARM — Docking & Maintenance Manipulator

| Parameter | Specification |
|-----------|--------------|
| ARM-D (SPA IZ) | 1:1 ratio with docking collars. Scales lockstep with collar expansion: 2→4→6→8 (P3–P7), extending to 30+ at P11. |
| ARM-C (PKT) | Construction/maintenance variant. Scales 1 per 500 circuits/yr build rate. Hub station maintenance: wheel swap, battery swap, motor swap, bucket/blade replacement. All components ORU. |
| Primary handling arm | 6 m reach; 7-DOF; 2,000 kg payload capacity in 1/6 g |
| Dexterous maintenance arm | 2.5 m reach; dual 7-DOF (14 total DOF); ±1 mm positioning; end-effector carousel (gripper, ORU tool, torque driver, camera) |
| Rail gantry | Overhead gantry spans all bays; primary arm rail-mounted for full bay coverage |
| Heritage | ESA European Robotic Arm (620 kg, 11.3 m, 5 mm accuracy); CSA Dextre (dual-arm component servicing) |
| Capture sequence | PROBE collar: conical guide alignment → magnetic pre-alignment → spring-loaded cam lock; tolerates ±5 cm position error |
| Turnaround | 48–72 hr per PROBE service cycle (dock, ore extract via dust vestibule, refuel, inspect, release) |
| ORU philosophy | All robot components packaged as Orbital Replacement Units for rapid ARM-performed swap-out; ~2,000 kg initial spare parts on-surface |
| Power | Grid-supplied via gantry rail; no onboard battery requirement |
| PSR access | ARM CANNOT enter PSR (no WEB, no cryogenic hardening — electronics rated to −55°C vs 40 K operating). ARM operations rim-and-surface only. |
| Collar geometry | Horizontal cylinders (5 m OD × 4.5 m length, axis along X) in single linear row. Gantry rail extendable by design (SEL-CAD-IZ-001). |

### 9.2 SENTINEL — Inspection & Safety Monitor

| Parameter | Specification |
|-----------|--------------|
| Mass | ~80 kg, 4-wheel rover, all-access including beneficiation module exterior |
| Count | 2 initial (P3) → 4 (P6+) at SPA. PKT: 1 per 500 circuits total (4,167+ at P12). |
| Structural validation | Full sweep of all sintered structures before crew arrival clearance — no crew until SENTINEL signs off |
| ISRU monitoring | VEX thermal performance; electrolyser membrane condition; cryocooler pressures; tank ullage and boil-off rate |
| H₂ leak detection | Catalytic + mass-spectrometry H₂ sniffer sensors; any LH₂ leak terminates all propellant operations immediately |
| Sensor suite | Visual + thermal cameras; ultrasonic thickness gauging; contact-probe XRF; vibration sensors |
| Comms | Full mesh connectivity; reports to Earth control and onboard AI; autonomous alert escalation |

**ECN-014 — Cryo Transfer Line Monitoring:**

SENTINEL monitors 4× isolation valve stations on ISRU–IZ cryo transfer lines (2× ISRU manifold exit, 2× IZ propellant farm entry). Sensors per station: 2× catalytic H₂ (10 ppm threshold, cross-checked), 1× UV flame detector (solar-blind, <1 s response), 1× pressure transducer (0–50 bar, 0.1% FS). Data polling: 10 Hz pressure, 1 Hz H₂/UV.

| Condition | Level | Action |
|-----------|-------|--------|
| H₂ ≥100 ppm | Alert | Ops Hub notification. Increase polling to 100 Hz. |
| H₂ ≥1,000 ppm | Auto-close | Close both valves at affected station. Tier 2. 100 m geofence. |
| Pressure ≥5 bar | Auto-close | Close both valves. Tier 2. Log 1 s pre-trigger buffer. |
| UV flame detected | Auto-close | Close ALL 4 cryo stations. Tier 1 emergency. Full IZ+ISRU geofence. |
| Comms loss >60 s | Dead-man | Valve fails closed (spring return). Tier 2 on restoration. |

Auto-close: hardwired 24 VDC signal to pneumatic actuator (NOT CAN bus or SpaceWire). Closure confirmed by limit switch within 3 s. Re-open requires crew command with 4 pre-conditions (H₂ <10 ppm 5 min, pressure <3 bar, no UV 10 min, verbal confirmation).

O₂ supply line: 2× pressure transducers, 1 Hz. Auto-close on >200 kPa hab-end or >2× normal flow. Hab O₂ on 90-day reserve until resolved.

VALVE_STATE database table (11th table): 8 rows, 10 Hz cryo / 1 Hz O₂, 90-day rolling retention. Fault patterns #201–#206 (H₂ leak, overpressure, UV flame, O₂ overpressure, O₂ high flow, comms timeout).

---

## 10. Surface Hauler — Mining-Capable (SEL-HAULER-001 Rev B)

**Replaces both SKIP and MOLE-S at PKT.** One vehicle class handles all PKT surface operations from P8 day one.

### 10.1 Vehicle Specification

| Parameter | Specification |
|-----------|--------------|
| Mass (dry) | ~1,450 kg. Chassis: 400 kg (Al frame). Drive: 200 kg (4× SRM hub motors + gearboxes). Hopper: 250 kg (Fe-Si open-top bin, 3.2 m³). Battery: ~300 kg (50 kWh Na-S, 300–350°C). Bucket/blade: ~150 kg. Avionics: 100 kg. Thermal: 50 kg. |
| Payload | 5,000 kg (5 t) KREEP regolith per trip. Fill density ~1,550 kg/m³. |
| Dimensions | 4,800 × 2,400 × 1,800 mm. Ground clearance 350 mm. |
| Wheels | 6: 4× driven (SRM hub motors, front+mid), 2× passive trailing (rear castering). 600 mm dia, 200 mm width, Ti mesh, 15 mm chevron grousers. |
| Drive | 4× switched reluctance motors, 1.5 kW each (6 kW peak). Fe-Si laminations (MRE), Al windings (no permanent magnets). Planetary gearbox 80:1. Max 1.5 m/s sintered road, 0.3 m/s off-road. 15° grade sintered, 8° off-road. |
| Battery | 50 kWh Na-S (sodium-sulfur). 300–350°C operating. Beta-alumina electrolyte (Na₂O·11Al₂O₃). Self-heating on discharge. >2,000 cycles. ORU — ARM-swappable <30 min. In-situ fraction: ~60% (Na, S, Al₂O₃). Must never freeze (<270°C solidification non-recoverable). |
| Mining mechanism | Front bucket/blade: electric linear actuators (2× 500 N, 300 mm stroke). Bucket: Fe-Ni steel, 0.4 m³, ~200 kg/min in loose regolith. Blade: Fe-Ni, 2,400 mm width. |
| Navigation | SENTINEL-supervised. LiDAR (360°, 200 m) + stereo cameras + radar beacons (every 100 m on roads) + SLAM (off-road). UHF relay to PKT SENTINEL node. |
| Thermal | Na-S waste heat for night heating. Passive radiators (0.3 m² silverised Teflon). Operates 24/7. |
| Loading | Self-loading via bucket: ~25 passes for 5 t fill (~25 min). No external excavator required. |
| Unloading | Electric linear actuator tilts hopper 45°, regolith slides (1/6 g). ~5 min. Or bottom-dump gate (~2 min). |
| Dust management | Retractable PTFE dust cover over hopper during transit. |

### 10.2 Operational Modes

- **Mine mode:** Bucket engages regolith face at 0.1 m/s, ~100 mm depth/pass. 200 kg/min. 5 t in ~25 min.
- **Grade mode:** Blade at surface, 0.3 m/s, ±50 mm tolerance. Blade angles ±15° for side-cast.
- **Trench mode:** Bucket at 200–300 mm depth, 0.05 m/s. ~400 mm wide × 300 mm deep profile.
- **Transport mode:** Bucket/blade raised and locked. Standard loaded/unloaded transit.

### 10.3 Operational Loop

| Step | Duration | Description |
|------|----------|-------------|
| Dispatch | ~1 min | SENTINEL assigns route |
| Transit out | ~4–8 hr | 15–30 km at 1 m/s on sintered road |
| Self-load | ~25 min | Bucket self-load 5 t KREEP |
| Transit back | ~4–8 hr | Loaded, 0.8–1.0 m/s |
| Unload | ~5 min | Tip hopper at spine input |
| Charge | ~2 hr | 25 kW at hub station. Na-S thermal check. |
| **TOTAL** | **~10–20 hr** | **~15 hr avg. ~250 trips/yr at 80% avail. ~1,250 t/yr per hauler.** |

### 10.4 In-Situ Manufacturing

| Component | Mass (kg) | In-situ % | Source | Earth-supplied |
|-----------|-----------|-----------|--------|----------------|
| Al frame | 400 | 85% | MRE Al-Si, WAAM/casting | Fasteners, precision interfaces |
| SRM motors (×4) | 200 | 70% | Fe-Si laminations, Al windings | Power electronics, sensors, bearings |
| Fe-Si hopper | 250 | 90% | MRE iron + silicon | Wear liners |
| Na-S battery | 300 | 60% | Na, S, Al₂O₃ electrolyte | Current collectors, seals, BMS |
| Bucket/blade | 150 | 80% | Fe-Ni (asteroid/foundry) | Actuator electronics |
| Avionics/nav | 100 | 0% | — | All Earth-supplied |
| Thermal | 50 | 50% | Al radiators | MLI film, coatings |
| **TOTAL** | **~1,450** | **~57%** | **~830 kg** | **~620 kg** |

Earth fraction trajectory: 100% (P8) → 70% (P9) → 43% (P10) → 33% (P12) → 20% floor (post S-type Y125).

### 10.5 Failure Modes

| Failure | Response | Impact |
|---------|----------|--------|
| Na-S thermal (<280°C) | Route to hub for recovery. If solidified (<270°C): battery ORU swap (non-recoverable). | MED |
| SRM motor failure | 3 motors at 0.5 m/s (graceful degradation). ARM ORU swap at maintenance hub. | LOW |
| Bucket actuator jam | Locked. Continue transport mode. ARM repair at hub. | LOW |
| Blade wear | Progressive — SENTINEL monitors. Replace at ~500 hr. In-situ Fe-Ni edges. | LOW |
| Battery depletion | Park, keep-alive (15 W). SENTINEL dispatches replacement + tow. | LOW |
| Nav sensor failure | Redundant (LiDAR + cameras + radar). Dual-sensor loss: stop, ARM dispatch. | LOW |

### 10.6 Fleet Scaling

| Phase | Haulers | Hubs | Road km | Conveyor km |
|-------|---------|------|---------|-------------|
| P8 | 200 | 2 | ~500 | 0 |
| P9 | 1,000+ | 10 | ~2,000 | 500 |
| P10 | 14,881 | ~150 | ~15,000 | 5,000+ |
| P11 | 148,810 | ~1,500 | ~50,000 | 15,000 |
| P12 | 1,488,096 | ~15,000 | ~200,000 | 87,500 |
| P14+ SS | ~1,500,000 | ~15,000 | ~200,000 | 87,500 |

Charging hubs: 1 per 100 haulers. 25 kW DC charger per berth. Na-S thermal management pad at each berth. Maintenance hub every 5th station with ARM for ORU swaps.

---

## 11. Steel Conveyor Network (Replaces EM Catapults)

**SEL-CATAPULT-001 Rev A SUPERSEDED for ore transport.** 9,084 catapult hubs eliminated. YBCO: 209,000 t → 0 for ore transport. Coilgun heritage retained for 5 mass drivers (8 tracks per ECN-020).

| Parameter | EM Catapult (superseded) | Steel Conveyor (baseline) |
|-----------|------------------------|--------------------------|
| Total infrastructure (P12) | ~1.82 Mt | ~7–9 Mt |
| Annual Earth import | ~6,140 t/yr (~61 flights) | ~300–430 t/yr (~3–4 flights) |
| YBCO required | ~209,000 t | 0 |
| Continuous power | ~13.6 GW | ~0.44 GW |
| In-situ fraction | ~0% critical | ~95–97% |
| Throughput per route | 720 t/day (batch) | 48,000 t/day (continuous) |

Network: dendritic (trunk + branch), ~87,500 km at P12. ~500 trunk lines averaging 75 km + ~5,000 branches averaging 10 km. SRM drive stations (Fe-Si + Al, in-situ) every 1–2 km. MoS₂ lubricated rollers. New document required: SEL-CONVEYOR-001 Rev A.

---

## 12. ISRU Plant Specifications (Fixed Infrastructure)

### 12.1 VEX — Volatile Extraction Unit

| Parameter | Specification |
|-----------|--------------|
| Function | Extract water from icy regolith (piped from PSR P4+, cable tramway P3) |
| Process | Thermal desorption ~150–200°C in vacuum. Volatiles condensed in cold trap. |
| Mass | ~80 kg (prefabricated on Earth, positioned by ARM) |
| Throughput | Matched to MOLE-I fleet. P7+: ~968 t/yr water input. |
| Power | ~5 kW per unit. Fully automated, remote-monitored. |
| Heritage | ESA PROSPECT; NASA PILOT concept |

### 12.2 Electrolyser

| Parameter | Specification |
|-----------|--------------|
| Function | Split water → H₂ + O₂ via PEM electrolysis |
| Power | ~10–20 kW per stack. P7+: 17 active + 2 spare stacks. |
| Efficiency | ~72.2% mass basis; ~4.5 kWh/kg H₂ |
| Heritage | ISS OGA (PEM, operational since 2007); NASA MOXIE (Mars CO₂, 2021–2023) |

### 12.3 Cryocooler & Liquefaction

| Parameter | Specification |
|-----------|--------------|
| Function | Liquefy H₂ (20 K) and O₂ (90 K) |
| Power | ~15–25 kW at P7+ scale (~12 kWh/kg LH₂) |
| Technology | Turbo-Brayton or pulse-tube. NASA ZBO heritage. |
| LH₂ boil-off | ~0.1–0.5%/day. MLI + sunshade. Boil-off recycled. |

### 12.4 Cryogenic Storage

| Parameter | Specification |
|-----------|--------------|
| Tanks | Al 2219-T87, 10–50 m³ each, 35 bar MAWP. 60+ layer MLI. Permanent shadow preferred. |
| Capacity | Min 2 PROBE mission stockpile (~13,300 kg) before first mission authorised |
| Propellant farm | Adjacent to IZ. Connected via cryo transfer lines (4× isolation valve stations, ECN-014). |
| DART buffer | Accommodates ~9–15 t over ~4–10 months without interrupting PROBE/SKIP cycles |

---

## 13. Crater Access Infrastructure

### 13.1 Descent Winch System

| Parameter | Specification |
|-----------|--------------|
| Function | Lower MOLE-I into PSR; optional retrieval for major maintenance |
| Power | 0.43 kW motorised; rim-anchored |
| Cable | Kevlar or Vectran ONLY. Dyneema excluded: Tg ~123–153 K → brittle snap-failure. Kevlar retains tensile to <4 K (+4% strength, +13% modulus at 77 K). |
| Speed | 0.5 m/s → ~4.7 hr over 8,400 m slope |
| Configuration | 1 winch per MOLE-I unit |

### 13.2 Cable Tramway (Phase 3)

| Parameter | Specification |
|-----------|--------------|
| Function | Transport MOLE-I product (icy regolith) from PSR to surface (P3 only) |
| Capacity | 350 kg/container, 2 m/s, ~19 trips/day → ~2,379 t/yr |
| Power | 0.55 kW lift. Aerial tramway, no moving parts at crater floor. |
| Lifetime | P3 primary → retained as backup once pipeline operational |

### 13.3 Heated Water Pipeline (Phase 4+)

| Parameter | Specification |
|-----------|--------------|
| Length | 8,500 m (rim to PSR operating zone) |
| Trace heating | 7 W/m → 59.5 kW total continuous. **MUST NEVER LOSE POWER — freeze = complete replacement.** |
| Pump | 408 W trunk pump at CLP (68 bar static, 80 bar working / 200 bar burst, 0.042 kg/s at P7+ flow rate) + 34 branch transfer pumps (~10 W each, lift ~3 m) |
| Material | Ti-6Al-4V, 1 mm wall (structural; pressure needs only 0.23 mm) |
| Redundancy | Dual parallel pipe from P5 (single failure is mission-critical) |
| Pipe heating detail | Trunk + spine: 7 W/m (ground-contact). Branches: 1.5 W/m (elevated vacuum+MLI). Total: 93–139 kW variable with deployed length. |

### 13.4 PSR Charging Network

Bilateral fishbone sub-station network. Adaptive layout driven by SURVEY ice mapping. Trunk enters crater at CLP on western wall base, extends along highest-concentration zones. Branches extend toward confirmed ice zones only (≥3 wt%). Incrementally extendable.

| Parameter | Specification |
|-----------|--------------|
| Trunk cable | 1,000 VDC OFHC Cu (Kapton insulated, 304 mm² at P7+, 45.7 t) |
| Branch infrastructure | Elevated ~3 m above floor on sintered regolith stakes (10–15 m spacing). Cables + pipes co-routed on shared brackets with PEEK/G-10 standoffs. |
| Junctions | 12 junctions support up to 124 nodes (620 MOLE-I). P7+ uses 4–5 junctions for 34 nodes (170 MOLE-I). |
| Each node | 5 MOLE-I + 1 spare port, WEB (80 W), 5 constant-tension cable drum motors (8 W heater each), passive bus bars, water collection manifold with transfer pump (10 W) |
| SATS+WEB assembly | Pre-integrated (ECN-013 R2). ~25 kg total. Pre-heated to 293 K, lowered at trunk cable end. 3× LWRHU maintain ≥268 K during 23-hr descent. Arrives operational — no PSR-floor assembly. |
| Construction spools | Spring-loaded retraction spools (ECN-013 R3) at every 100 m construction tap. Clock spring (301 SS), ~5 N tension, no power. ~1 kg each, ~9 per 450 m branch. |

### 13.5 CAP — Crater Access Pod (Phase 2+ Contingency)

| Parameter | Specification |
|-----------|--------------|
| Function | Contingency human PSR access; crew transits wall in pressurised pod |
| Mass | ~850 kg dry, ~1,400 kg loaded (2 crew + 2 EVA suits + tools) |
| Volume | 6 m³ internal. 30+ layer MLI. |
| Life support | 18 person-hours |
| Transit | ~3 m/s on dedicated guide cable → ~45 min over 8.2 km crater wall |
| Floor EVA | xEMU-generation suits (40 K rated, 2-hour thermal limit) |
| Winch | Dedicated crew-rated (IW-CAP, 1.7 kW, 5× safety factor) |
| Phase 1 reservations | Guide cable anchors (4–6 positions), rim winch pad, floor docking pad at CLP, 2 m lateral corridor. <10 kg, zero schedule impact. |
| Limitations | Does NOT solve floor EVA thermal limits (2 hr at 40 K), glove dexterity at cryo temps, or wall EVA (crew cannot exit pod at 25 K) |

---

## 14. Processing Circuit Design

| Design | REO/yr | Mass (kg) | Power (kW) | Circuits for 2.5 Mt/yr | Total mass |
|--------|--------|-----------|------------|------------------------|------------|
| Batch (rejected) | 0.4 t | 15,000 | 180 | 6,250,000 | 93.8 Mt |
| Continuous-flow | 0.8 t | 22,000 | 300 | 3,125,000 | 68.8 Mt |
| **Optimised (committed)** | **1.2 t** | **28,000** | **400** | **2,083,334** | **58.3 Mt** |

Circuit throughput optimisation is the single highest-value R&D investment ($22T cost reduction over 200 years vs batch). Maintenance: 0.5% mass/yr. Decision gate DG-8.X: validate ≥1.0 t/yr before full PKT commitment. Earth fraction: 100% (P8) → 10% (P10) → 3% (post C-type Y105) → 0.8% (post S-type Y125).

---

## 15. Construction Fleet Scaling

| Vehicle | Scales with | Unit mass | Replacement | Notes |
|---------|------------|-----------|-------------|-------|
| ARM-C | 1 per 500 circuits/yr build rate | 1,500 kg | 10-yr life | Circuit installation at PKT |
| SINTER | 1 per 200 circuits/yr build rate | 2,200 kg | 15-yr life | Roads, pads, enclosures |
| SENTINEL | 1 per 500 circuits total | 80 kg | 10-yr life | Monitoring + safety |
| Charging hub | 1 per 100 haulers | 5,000 kg (95% in-situ) | Long life | Na-S thermal management |

Steady-state minimum (P14+): ~20 ARM-C, ~50 SINTER, SENTINEL scales with circuit count.

---

## 16. Mass Driver Network — 5 Drivers, 8 Tracks (ECN-020)

| ID | Route | Velocity | Tracks | YBCO/track (t) | Total YBCO (t) | Operational | Purpose |
|----|-------|----------|--------|----------------|----------------|-------------|---------|
| MD-1 | SPA→PKT | ~1,800 m/s | **2** (primary + redundant) | 60 | **120** | P8 (Y25) | Fe-Ni, Th(OH)₄, spares. Sole inter-site link. |
| MD-2 | PKT→Earth | ~2,400 m/s | **3** (round-robin) | 80 | **240** | P9 (Y35) | REO canisters: **~694,444/yr (~1,903/day system, ~634/day per track)**. |
| MD-3 | PKT→SPA | ~1,800 m/s | 1 | 55 | 55 | P9–P10 (Y43) | ThCl₄ for SPA MSR. ~42 launches/yr. |
| MD-4 | SPA→Earth | ~2,400 m/s | 1 | 70 | 70 | P11 (Y70) | PGM exports (DG-11.6). Foundation for future parallel. |
| MD-5 | DRO→SPA | ~800 m/s | 1 | 38 | 38 | P12+ (Y85) | Asteroid concentrate. ~200/day — comfortable single track. |

**Total YBCO: ~523 t lifetime** (~5 Starship flights) vs 209,000 t for 9,084 catapult hubs. +220 t over single-track baseline (~$220M, 0.001% of programme cost) provides maintenance rotation and eliminates single-point logistics failures. Per-driver YBCO per SEL-CATAPULT-001 Rev B (authoritative). Parallel track rationale: ECN-020. TRL basis: EMALS (USS Gerald R. Ford, TRL 9, 45 t at ~100 m/s). Linear induction maglev (Shanghai, TRL 9).

EM catchers at SPA: coilgun in reverse, ~60–70% regenerative. Three inbound streams: PKT→SPA canisters (ThCl₄), DRO→SPA concentrate, Mk III PROBE LLO canister ejections (~1,680 m/s). Catcher track ~2× launcher length for gentler deceleration.

Construction: SINTER sinters foundation (±2 mm over 500 m). ARM-C installs Al guide rails and YBCO coils on bobbins. 250 coils per 500 m track, ~20 kg each. Cryocooler per section (~500 W, 77 K). Supercapacitor bank: 10 MJ, ~500 kg, ~5 MW peak per launch.

---

## 17. Asteroid Capture Infrastructure

### 17.1 Redirect Tugs

~50,000 kg each (vs ECN-016's ~2,000 kg), 20-yr replacement cycle. Hall-effect/ion thrusters, 5,000+ s Isp. Earth-built, LEO launch at $500/kg, self-transfer via ion drive. Fleet: 2 (Y65, M-type) → 3 (C-type) → 5 (S-type + redundancy). Safety: planetary defence review (UN COPUOS), Earth-impact probability <10⁻⁸ at all points, multiple abort windows.

### 17.2 Laser Ablation Truss

1 per captured asteroid in DRO. Linear rigid truss with dual high-power laser heads at each end. Truss rotates slowly around asteroid's long axis.

| Parameter | Specification |
|-----------|--------------|
| Power | ~350 MW total (3–4 MSR units or ~1.2 km² solar array at DRO) |
| Throughput | ~1,000 t/day = ~365,000 t/yr |
| PGM yield | At 100 ppm PGM in Fe-Ni matrix → 36.5 t/yr per asteroid |
| Method | Surface ablation in spiral pattern (~1 m depth channel). No mechanical contact. |
| Ejecta capture | Electrostatic/magnetic collectors behind each laser head |
| Heritage | DE-STAR programme (Lubin, UCSB) |
| DG-13.2 | Asteroid mining method selection (laser vs mechanical vs hybrid) |

### 17.3 Diversified Captures

| # | Type | Size | Capture→Online | Provides | Impact |
|---|------|------|----------------|----------|--------|
| 1 | M-type | ~200 m | Y75→Y85 | 36.5 t/yr PGM, Fe-Ni for foundry | 80+ yr campaign; hauler Earth frac →20% |
| 2 | C-type | ~100 m | Y95→Y105 | Water, carbon, nitrogen | Circuit frac 10%→3%; propellant independence; PTFE in-situ |
| 3 | S-type | ~100 m | Y115→Y125 | Silicon, copper | Circuit frac 3%→0.8%; sensors + wiring in-situ |

All processing at SPA: M-type PGM hydromet, C-type pyrolysis + Fischer-Tropsch, S-type Czochralski Si + Cu electrolysis. Products mass-driven SPA→PKT where needed. C-type surfaces covered with reflective MLI blanket (preserve subsurface ice in DRO solar). C-type carbon enables S-type Si refining (carbothermic reduction). Each capture enables the next. Combined exploitation achieves near-complete Earth independence by ~Y135.

**Captured asteroids do NOT use PROBEs** — dedicated permanent infrastructure (laser truss + mass driver). PROBEs for remote uncaptured asteroids only. Architecturally independent.

---

## 18. Power Architecture

### 18.1 SPA Power

| Phase | Source | Capacity | Dominant consumers |
|-------|--------|----------|--------------------|
| P1–P3 | Solar (~1,218 m² by P4) | ~346 kW | MOLE-I (19.3 kW at 10 units), ISRU (~50 kW), SINTER (self-powered) |
| P4–P6 | Solar + 4–8 FSP (40 kW each) | ~506–666 kW | 25–85 MOLE-I, ISRU (702 kW at P6), hab ECLSS |
| P7 | Solar (~1,825 kW) + 11 FSP | ~2,265 kW | 170 MOLE-I (329 kW), ISRU (1,171–1,360 kW), pipeline (59.5 kW), 5 circuits (2 MW staggered) |
| P10+ | Solar + FSP + SPA MSR (from Y50) | Growing | PGM processing, Mk III EM catcher, asteroid processing (Y105+) |

Pipeline heating (59.5 kW continuous) is mission-critical. FSP covers all critical loads during 72-hr eclipse design case. SPA MSR fleet: 1 unit Y105 (C-type, 50 MWe) + 1 unit Y125 (S-type, 100 MWe) + 1 unit Y140. ThCl₄ from PKT→SPA mass driver.

### 18.2 PKT Power

| Phase | Source | Capacity | Key consumers |
|-------|--------|----------|---------------|
| P8 W1 | 4 FSP | ~160 kW | Hauler charging, ARM-C, reagent plant |
| P8 W2–4 | 1,386 FSP | ~55 MW | 308 circuits (staggered), haulers, spine conveyor |
| P9 | FSP + first MSRs | ~100 MW | 2,500 circuits (1 GW — MSR is critical path) |
| P10 | ~74 MSR × 100 MWe | 7.4 GW | 25,000 circuits (10 GW), 14,881 haulers |
| P11 | ~679 MSR | 67.9 GW | 250,000 circuits, 148,810 haulers |
| P12 | ~6,890 MSR | 689 GW | 2.08M circuits (~833 GW), 1.49M haulers (~1.3 GW), conveyors (~0.5 GW) |

Circuits dominate power demand (~400 kW each). MSR process heat (200–300°C) dual-purposed for acid baking.

---

## 19. SPA Industrial Zone — Docking Architecture

Docking collars: horizontal cylinders (5 m OD × 4.5 m length, axis along X) in a single linear row. ARM-D ratio: 1:1 per collar. Scale: P3: 2 → P5: 6 → P7: 8 → P11: 30+. Gantry rail extendable (SEL-CAD-IZ-001). At 286 PROBEs with ~1 mission/yr and 48–72 hr turnaround, 30 collars give ~8% utilisation.

Mk III PROBEs never dock at IZ (never land). Their canisters arrive via EM catcher — separate from docking gantry. SPA IZ handles Mk I/II servicing only.

PROBE material flow: Mk I/II returns to SPA → ore extracted via dust vestibule → PGM separated (chlorination) → Earth return. Fe-Ni bulk mass-driven SPA→PKT as foundry feedstock. Mk III ejects canisters from LLO → EM catcher at SPA. Captured asteroid material: laser truss at DRO → MD-5 → SPA EM catcher.

---

## 20. Complete Fleet Scaling — All Phases

### 20.1 Operational Vehicles

| Vehicle | P0–P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | P13 | P14 | P14+ |
|---------|------:|---:|---:|---:|---:|---:|---:|----:|----:|----:|----:|----:|-----:|
| PROBE Mk I | 3 | 6 | 10 | 15 | 30 | 96 | 30 | 30 | →0 | — | — | — | — |
| PROBE Mk II | — | — | — | — | — | — | 190 | 230 | 260→30 | 30 | 30 | 30 | 30 |
| PROBE Mk III | — | — | — | — | — | — | — | — | 0→1,714 | 1,714 | 1,714 | 1,714→300 | 300 |
| SKIP (SPA) | 1 | 1 | 2 | 4 | 8 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| MOLE-I | 10 | 25 | 50 | 85 | 170 | ~247 | ~240 | ~280 | ~320→~50 | ~50 | ~50 | ~50 | ~50 |
| MOLE-S | 4 | 4 | 4 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | 6 |
| DART | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| SURVEY | 1 | 1 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |
| Hauler (PKT) | 0 | 0 | 0 | 0 | 0 | 200 | 1k+ | 14,881 | 148,810 | 1.49M | ~1.5M | ~1.5M | ~1.5M |
| Redirect tug | — | — | — | — | — | — | — | — | 2 | 3 | 3–5 | 5 | 5 |
| Laser truss | — | — | — | — | — | — | — | — | — | 1 | 1–2 | 2–3 | 3 |

### 20.2 Infrastructure & Construction

| System | P0–P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | P13 | P14 | P14+ |
|--------|------:|---:|---:|---:|---:|---:|---:|----:|----:|----:|----:|----:|-----:|
| SINTER | 3 | 3 | 3 | 3 | 3+ | 20+ | 30+ | 50+ | 100+ | 200+ | 200+ | 100+ | ~50 |
| ARM-C (PKT) | 0 | 0 | 0 | 0 | 0 | 5+ | 15+ | 30+ | 100+ | 200+ | 150+ | 100+ | ~20 |
| ARM-D (SPA) | 2 | 4 | 6 | 8 | 8 | 10 | 15 | 20 | 30+ | 30+ | 30+ | 30+ | 30+ |
| SENTINEL (SPA) | 2 | 2 | 3 | 4 | 4+ | 6+ | 10+ | 15+ | 20+ | 20+ | 20+ | 20+ | 20+ |
| SENTINEL (PKT) | 0 | 0 | 0 | 0 | 0 | 5+ | 10+ | 50+ | 500+ | 4,167+ | maint | maint | maint |
| Conveyor km | 0 | 0 | 0 | 0 | 0 | 0 | 500 | 5k+ | 15k | 87,500 | 87,500 | 87,500 | 87,500 |
| Mass drivers | 0 | 0 | 0 | 0 | 0 | 1 | 2 | 3 | 4 | 5 | 5 | 5 | 5 |
| Circuits | 0 | 0 | 0 | 0 | 5 | 308 | 2,500 | 25k | 250k | 2.08M | 2.08M | 2.08M | 2.08M |
| MSR (100 MWe) | 0 | 0 | 0 | 0 | 0 | 0 | 1–3 | ~74 | ~679 | ~6,890 | ~6,890 | ~6,893 | ~6,893 |
| REO t/yr | 0 | 0 | 0 | 0 | 0.4 | 125 | 1,000 | 10k | 100k | 500k | 1.25M | 2.5M | 2.5M |

### 20.3 Phase Timeline

| Phase | Years | Calendar (~) | REO t/yr | Key milestones |
|-------|-------|-------------|----------|----------------|
| P0 | Y0–3 | ~2025–28 | 0 | Programme GO, relay, design freeze |
| P1–3 | Y2–7 | ~2027–32 | 0 | Cargo landing, ISRU, MOLE-I deployment |
| P4 | Y7–9 | ~2032–34 | 0 | Crew arrival (4–8), ECLSS, PROBE ISRU-fuelled |
| P5 | Y9–12 | ~2034–37 | 0 | DART first PKT mission, beneficiation, first exports |
| P6 | Y12–15 | ~2037–40 | 0 | Processing facility, Ca(OH)₂ pilot, crew rotation |
| P7 | Y18–25 | ~2043–50 | 0.4 | PKT commitment (DG-7.1), Th recovery, 5 circuits, 8 SKIPs |
| P8 | Y25–35 | ~2050–60 | 125 | MD-1, PKT 4 waves (~300 flights), DG-8.X, 308 circuits |
| P9 | Y35–45 | ~2060–70 | 1,000 | MD-2, SKIP retired, first MSR, foundry, conveyor pilot |
| P10 | Y45–60 | ~2070–85 | 10,000 | 14,881 haulers, 74 MSR, full industrial scale |
| P11 | Y60–80 | ~2085–2105 | 100,000 | Mk III PROBE, MOLE-I →50, M-type redirect, MD-4 |
| P12 | Y80–120 | ~2105–45 | 100k→500k | M-type online (Y85), laser truss, MD-5, C-type redirect |
| P13 | Y120–140 | ~2145–65 | 500k→1.25M | C-type online (Y105), circuit frac →3%, S-type redirect |
| P14 | Y140–180 | ~2165–2205 | 1.25M→2.5M | S-type online (Y125), circuit frac →0.8%, DG-14.3 |
| P14+ | Y180+ | ~2205+ | 2,500,000 | Steady state. +$121.8B/yr. 182 Mt CO₂/yr avoided. |

---

## 21. Document History

| Version | Description |
|---------|-------------|
| v8 | 17×5 architecture, separated ISRU, 9 robot classes. March 2026. |
| ECN-012 | MOLE-I drain pipe reroute to rear nozzle. Heated pipeline integration. |
| ECN-013 | MOLE-I 3-layer navigation. ARM removed from PSR. SATS+WEB pre-integrated. Motorised bayonet adapter (CON-001). Construction tether retraction spools. |
| ECN-014 | SENTINEL cryo transfer line monitoring. Auto-close protocol (hardwired 24 VDC). Valve DB table. Fault patterns #201–#206. |
| ECN-016 | SKIP phase-out, MOLE-I Mk II drill, PROBE Mk II heavy, hauler intro, catapult, asteroid capture. (Partially superseded.) |
| ECN-017 | In-situ manufacturing, catapult scaling. (Superseded.) |
| **v9** | **All ECNs integrated. ECN-019 Rev C: 2.5 Mt/yr, demand-driven MOLE-I, SKIP retired P9, PROBE Mk III SEP, hauler Rev B at P8, catapults→conveyors, D2EHPA eliminated, thorium MSR, optimised circuits (1.2 t/yr, 2.08M), base specialisation, diversified asteroids (M/C/S), laser ablation truss, construction fleet scaling, P13/P14/P14+, Earth independence (0.8% circuit frac by Y135), economic evaluation ($21.3T, BCR 0.50/2.06). ECN-020: MD-2 3× parallel tracks, MD-1 2× redundant, total YBCO ~523 t (per-driver per CATAPULT-001 Rev B). Corrected canister cadence ~694,444/yr (~1,903/day) at 2.5 Mt/yr. April 2026.** |

---

*— End of SEL_ROBOT_FLEET v9 —*
