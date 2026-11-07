<!-- Markdown extract of docs/sources/updated_SEL-CAD-ISRU-001_RevA.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
ISRU Plant CAD Reference
Process Layout • Equipment Positions • Pipeline Entry • Cryo Tanks • Plant-to-IZ Interface
Reference: SEL-CAD-ISRU-001 Rev A
# 1. ISRU Plant Coordinate System
Origin: centre of electrolysis module array. X-axis: toward habitat (W). Y-axis: vertical (up). Z-axis: toward IZ propellant farm (S). Plant footprint: ~80 × 40 m. Located 200–500 m east of habitat complex on crater rim.
# 2. Plant Layout — Process Flow (West to East)
The ISRU plant is arranged in a linear process flow from pipeline entry (W side, facing crater) through processing to cryogenic output (E side, toward IZ). All modules are unpressurised (vacuum-rated). Crew access for maintenance via pressurised rover from hab or EVA.
| Station | Position (from origin) | Equipment | Dimensions | Mass | Power |
|---|---|---|---|---|---|
| Pipeline entry + trunk valve | X = −35 m | Trunk pipeline terminus. Isolation valve. Pressure relief. Flow meter. | 2 × 2 × 3 m shelter (sintered) | ~200 kg valve assembly | ~50 W controls |
| Surface VEX array (×10) | X = −25 to −15 m | Secondary polishing VEX units (5 kW each). Not primary processing — MOLE-I mini-VEX does primary in-crater. | 1.0 × 0.5 × 0.5 m each. 10 m row. | ~80 kg each, 800 kg total | 50 kW total |
| Purification train | X = −10 to −5 m | Stage 4A–4D: degasser → particle filter → activated carbon → ion exchange. + Stage 4E potable branch. | 5 × 3 × 2.5 m enclosed module (sintered walls, 500 mm) | ~500 kg equipment + sintered enclosure | ~500 W + 200 W regen |
| Electrolysis array (×19) | X = 0 (origin) | 19 PEM stacks (17 active + 2 N+1 spare). 50 kW each. 5.5 kW per kg/hr H₂O. | Each stack: 0.8 × 0.8 × 1.5 m. Array: 8 × 12 m footprint (2 rows of 10, gap between). | ~200 kg per stack, ~3,800 kg total | 850 kW (17 active) |
| Gas separation + compression | X = +5 to +10 m | H₂/O₂ separators. H₂ compressor for cryo feed. O₂ buffer tank. | 3 × 5 × 3 m | ~1,000 kg | ~30 kW |
| LOX cryocooler | X = +15 m, Z = +5 m | Pulse-tube cryocooler, 90 K. LOX accumulator. | 2 × 2 × 2 m | ~300 kg | ~54 kW |
| LH₂ cryocooler | X = +15 m, Z = −5 m | Closed-loop He Brayton, 20 K. LH₂ accumulator. CRITICAL: largest single cryogenic challenge. | 3 × 3 × 3 m (includes He compressor) | ~500 kg | ~200 kW |
| LOX buffer tank | X = +25 m, Z = +5 m | 5.0 m dia sphere. VJ insulated. ~65 m³. | 5,000 mm dia | ~2,000 kg (tank + MLI) | ~1 kW ZBO |
| LH₂ buffer tanks (×3) | X = +25 m, Z = −5 m | 3 × 5.0 m dia spheres. VJ + MLI. ~196 m³ total. 15 m between LH₂ and LOX. | 5,000 mm dia each, triangular cluster | ~2,500 kg each, ~7,500 kg total | ~7–10 kW ZBO |
| Transfer manifold | X = +30 m | Cryo distribution valves. LH₂ + LOX output to IZ propellant farm via VJ lines. | 2 × 3 × 2 m shelter | ~500 kg | ~100 W |

★ LH₂ and LOX tank clusters separated by ≥15 m with sintered blast berm between them. All cryo equipment on sintered foundation pads.

# 3. Pipeline Entry from Crater
The heated water pipeline arrives from the PSR floor (CLP) via the western crater wall. It enters the ISRU plant at the W boundary.
| Parameter | Specification |
|---|---|
| Pipeline terminus | Surface-level entry at plant W boundary. Pipe transitions from buried crater-wall routing to above-ground manifold. |
| Entry valve station | Manual isolation + remote-actuated shutoff + pressure relief + flow meter + temperature sensor. All within a sintered shelter (2 × 2 × 3 m, 500 mm walls). |
| Water quality check | Inline conductivity sensor before purification input. Auto-divert to waste if >50 µS/cm. |
| Trace heating transition | Pipeline 7 W/m heating terminates at entry valve station. Surface piping within plant is short (<50 m total) and maintained above 5°C by waste heat from electrolysis. |

# 4. Potable Water Branch
Stage 4E diverts a fraction of purified water through remineralisation and sterilisation for crew consumption. This branch exits the purification train and routes to the hab utility conduit.
| Parameter | Specification |
|---|---|
| Diversion point | After Stage 4D (ion exchange) output. Tee junction with flow control valve. |
| Remineralisation | Calcite/dolomite contactor column (~300 mm dia × 1,000 mm tall). CO₂ injection for calcium dissolution. KCl cartridge. NaOH dosing pump. |
| Sterilisation | Electrolytic Ag⁺ generator (200–400 µg/L) + UV-C lamp (254 nm, ≥40 mJ/cm²). |
| Output line | 25 mm OD 316L SS to hab utility conduit. ~200–500 m to hab entry. UV steriliser at hab end (redundant barrier). |
| Flow rate | ~4–30 kg/day (P4–P7+). Trivially small vs main ISRU throughput (~3,641 kg/day). |
| Module mass | <50 kg total. <100 W power. |

# 5. Power Distribution Within Plant
| Parameter | Specification |
|---|---|
| Grid entry | ±2,800 VDC bipolar from FSP/solar grid. Entry at plant E boundary (near cryo section). |
| Primary bus | 1,000 VDC distribution within plant. DC-DC converter at entry point. |
| Electrolysis feed | Dedicated 1,000 VDC bus to stack array. Individual stack controllers step down to PEM operating voltage (~1.8 V per cell, series stacks). |
| Cryo feed | Dedicated 1,000 VDC bus to cryocooler compressors. |
| Controls/instrumentation | 120 VDC secondary bus for sensors, valves, SENTINEL interface, data comms. |
| Total plant power | ~1,171 kW (850 electrolysis + 256 cryo + 50 VEX + 15 other). Per ISRU-001 Rev D. |
| Cable routing | Buried in sintered trench between modules. Cable tray on sintered pylons for above-ground runs. |

# 6. Radiation Protection
The ISRU plant is unpressurised and normally uncrewed. Crew visit for maintenance via pressurised rover or EVA. All enclosed modules (purification, valve stations) have 500 mm sintered walls providing ~85 g/cm² areal density (~240–300 mSv/yr if occupied full-time). Crew maintenance visits limited to <20 hr/month. Electrolysis array is open-frame (no enclosure) — EVA maintenance only, with xEMU suit providing personal shielding.
# 7. ISRU Plant ↔ IZ Interface
| Interface | Route | Specification |
|---|---|---|
| LH₂ to IZ propellant farm | From transfer manifold (X = +30 m) to IZ farm (200–500 m S/SE) | 100 mm ID VJ line. MLI-wrapped. Sintered pylon supports every 10 m. |
| LOX to IZ propellant farm | Same route, parallel line | 100 mm ID VJ line. Same supports. |
| O₂ to hab | From gas separation (X = +5 m) to hab utility conduit (200–500 m W) | 25 mm OD 316L SS. Buried in utility trench. |
| Potable water to hab | From Stage 4E (X = −5 m) to hab utility conduit | 25 mm OD 316L SS. Same trench. |
| Data | Fibre optic to hab Ops Hub + UHF relay to SENTINEL | Same trench + wireless backup. |
| Crew access | Sintered road to hab (200–500 m W) and to IZ (200–500 m S/SE) | 3 m wide sintered surface. Pressurised rover route. |

ECN-014 Amendment — Valve Station Geometry (March 2026)
Reference: SEL-PIPE-001 Rev A
Transfer manifold exit (X = +30 m): Add 2× valve station shelters at manifold LH₂ and LOX output stubs. Each shelter: sintered regolith, 2,000 × 2,000 × 2,000 mm (SINTER-built, 500 mm walls). Position: immediately downstream of manifold output, before VJ lines exit the ISRU plant footprint. Shelter contains: pneumatic ball valve (100 mm bore, fail-closed, GN₂ actuator + spring return), excess flow check valve (inline, 100 mm bore), burst disc (10 bar, directed vent nozzle pointing upward away from plant), 2× catalytic H₂ sensors + UV flame detector, SENTINEL data link. GN₂ pressurant bottle (2 L, 200 bar) mounted on shelter exterior wall with pressure gauge.
Gas separation output (X = +5 m): Add 1× dome-loaded pressure regulator (300 kPa set, 30 bar inlet, 25 mm bore, oxygen-cleaned) + 1× relief valve (500 kPa, 25 mm, directed vent) + 1× pneumatic isolation valve (25 mm bore, fail-closed). Mount on regulator bracket adjacent to gas separation module east face. Total footprint: ~400 × 300 × 500 mm. SENTINEL pressure transducer downstream of regulator (4–20 mA, 0–1,000 kPa range).
CAD parts: SEL-ISRU-VLV-001 (LH₂ valve station assembly), SEL-ISRU-VLV-002 (LOX valve station assembly), SEL-ISRU-REG-001 (O₂ regulator + relief + isolation assembly). Add to Phase 7 of ISRU CAD build sequence.
— End of Document —