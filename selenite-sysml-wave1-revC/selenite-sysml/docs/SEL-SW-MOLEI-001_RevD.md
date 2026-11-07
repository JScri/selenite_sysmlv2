<!-- Markdown extract of docs/sources/SEL-SW-MOLEI-001_RevD.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
MOLE-I PSR Ice Extraction Rover
SolidWorks CAD Modelling Sequence
Reference: SEL-SW-MOLEI-001 Rev B
| Field | Value |
|---|---|
| Document | SEL-SW-MOLEI-001 Rev A |
| Programme | Selenite — Permanent Lunar Base |
| Subject | MOLE-I 6-Wheel PSR Rover: Complete CAD Modelling Sequence |
| Author | Jason Stewart (Systems Engineering Lead) |
| Date | March 2026 |
| Status | DRAFT — For CAD Development |
| Classification | Selenite Programme Internal |

Source Documents:
SEL_MOLEI_DESIGN v2 — Engineering Design Specification
SEL_ROBOT_FLEET v5 — Robot Fleet Specification
W2_T1_1_JS_MTL_GUIDE v16 — Mission Guide
SEL-T1_1-STRATEGY v2.4 — Strategic Governance Document
MOLEI_THERMAL v1.3 — MATLAB Thermal Verification Script
SELENITE_VERIFY v4.5 — MATLAB Supply Chain Verification Script
mole_i_design_v3.jsx — Interactive Schematic (React/SVG)

# 1. Scope and Purpose
This document provides a complete, step-by-step SolidWorks modelling sequence for the MOLE-I PSR Ice Extraction Rover. It is written so that any competent SolidWorks operator can build the CAD assembly from scratch without requiring additional technical input. Every dimension, material assignment, mate relationship, and design rationale is specified.
The MOLE-I is the programme’s most numerous and mission-critical robot class, scaling from 10 units at Phase 3 to 170 at Phase 7+. It operates permanently inside the Permanently Shadowed Region (PSR) of Shackleton Crater at 40 K, drilling icy permafrost, extracting water via an integrated mini-VEX sublimation chamber, and delivering liquid water to sub-station collection manifolds via periodic batch dumps. Each unit yields 5,692 kg of propellant per year.
The thermal design has been verified by a bottom-up MATLAB model (MOLEI_THERMAL v1.3) covering all conduction paths, MLI radiation, LWRHU sizing, multi-mode transient behaviour, and the wax-actuated thermal shunt. All thermal hardware specified in this document is derived from that verified model.
# 2. Conventions
## 2.1 Part Numbering
All parts follow the naming convention: SEL-MI-PPP-NNN where SEL = Selenite, MI = MOLE-I, PPP = three-letter subsystem code, NNN = sequential number. Assemblies use .SLDASM, parts use .SLDPRT.
| Code | Subsystem | Example |
|---|---|---|
| CHS | Chassis frame | SEL-MI-CHS-001 |
| SUS | Suspension (rocker-bogie) | SEL-MI-SUS-001 |
| WHL | Wheel and drive motor | SEL-MI-WHL-001 |
| DRL | Drill assembly | SEL-MI-DRL-001 |
| VEX | mini-VEX sublimation chamber | SEL-MI-VEX-001 |
| WEB | Warm Electronics Box | SEL-MI-WEB-001 |
| TNK | Water tank | SEL-MI-TNK-001 |
| BAT | Transit battery | SEL-MI-BAT-001 |
| PWR | Power receptacle and tether | SEL-MI-PWR-001 |
| COM | Communications antenna | SEL-MI-COM-001 |
| MLI | Multi-layer insulation | SEL-MI-MLI-001 |
| THR | Thermal hardware (shunt, straps) | SEL-MI-THR-001 |
| SNS | Sensors (Pt100 RTDs) | SEL-MI-SNS-001 |
| HRN | Harness and connectors | SEL-MI-HRN-001 |
| PIP | Piping (drain, VEX tube) | SEL-MI-PIP-001 |

## 2.2 Units and Coordinate System
All dimensions in millimetres unless stated. Mass in kilograms. SolidWorks units: MMGS (mm, g, s). Origin at geometric centre of chassis footprint, X = forward (drive direction), Y = port (left), Z = up. Front of rover faces +X.
## 2.3 Materials Library
Create a custom materials library (Selenite_Materials.sldmat) with the following. Assign to every part — mass properties depend on correct material assignment.
| Material | Density (g/cm³) | Application | Notes |
|---|---|---|---|
| Ti-6Al-4V | 4.43 | Chassis, bolts, suspension arms, drill housing | k varies 0.9–5.9 W/m·K (40–273 K) |
| PEEK (Victrex 450G) | 1.30 | Thermal standoffs, pipe couplers, washers, bushings | k ≈ 0.20–0.25 W/m·K. Load-bearing polymer. |
| Manganin (Cu-Mn-Ni) | 8.40 | Cable harness transition sections (100 mm at WEB) | k ≈ 12–20 W/m·K. Resistance alloy. |
| OFHC Copper | 8.96 | Thermal strap braids, internal WEB wiring | k ≈ 470–500 W/m·K. Highest cryo conductor. |
| SS 304 | 8.00 | Water tank, valve bodies, feed chute sections | k ≈ 1.7–13 W/m·K (40–273 K) |
| SmCo (Sm₂Co₁₇) | 8.40 | Wheel hub motor permanent magnets | No SRT at 135 K (unlike NdFeB) |
| Spring steel (301 SS) | 7.90 | Wheel mesh, shunt return spring | Retains elasticity at cryogenic temps |
| Tungsten carbide (WC) | 15.63 | Drill bit tips | Hardness for 10–30 MPa icy regolith |
| Alumina (Al₂O₃ 99.5%) | 3.90 | Ceramic thermal break (drill–chassis) | k drops steeply at cryo: ~1 W/m·K at 40 K |
| Aluminised Mylar | 1.39 | MLI layers (20+ layer blankets) | DAM with Dacron net spacers |
| n-Tetradecane (C₁₄H₃₀) | 0.76 | Wax thermal shunt actuator | Melting point 278.7 K |
| Pu-238 (in Pt-Rh clad) | 19.84 | LWRHU fuel pellet (encapsulated) | 1.1 W thermal, 42 g max, 25.95 mm dia |

# 3. Assembly Structure
The top-level assembly is SEL-MI-000-ASM.SLDASM. Sub-assemblies are shown indented. Model in the order listed — each phase depends on the previous.
| Part / Assembly | Description | Phase |
|---|---|---|
| SEL-MI-000-ASM | MOLE-I Top-Level Assembly |  |
| │─ SEL-MI-CHS-ASM | Chassis + Standoffs | Phase 1 |
| │  │─ SEL-MI-CHS-001 | Ti-6Al-4V weldment frame |  |
| │  │─ SEL-MI-CHS-010 (x4) | PEEK WEB standoff |  |
| │  │─ SEL-MI-CHS-011 (x8) | PEEK washer (M6) |  |
| │  │─ SEL-MI-CHS-020 (x4) | PEEK VEX standoff |  |
| │  └─ SEL-MI-CHS-030 | PEEK connector spacer |  |
| │─ SEL-MI-SUS-ASM | Suspension (per side, x2) | Phase 2 |
| │  │─ SEL-MI-SUS-001 | Rocker arm (Ti) |  |
| │  │─ SEL-MI-SUS-002 | Bogie arm (Ti) |  |
| │  └─ SEL-MI-SUS-010 (x2) | Ti flexure pivot blade |  |
| │─ SEL-MI-WHL-ASM (x6) | Wheel + Drive Unit | Phase 2 |
| │  │─ SEL-MI-WHL-001 | Spring-steel mesh wheel (Ø450) |  |
| │  │─ SEL-MI-WHL-010 | SmCo BLDC hub motor |  |
| │  └─ SEL-MI-WHL-020 | MoS₂ gearbox housing |  |
| │─ SEL-MI-DRL-ASM | Drill Assembly | Phase 3 |
| │  │─ SEL-MI-DRL-001 | Drill housing (Ti) |  |
| │  │─ SEL-MI-DRL-010 | WC drill bit |  |
| │  └─ SEL-MI-DRL-020 | Alumina thermal break disc |  |
| │─ SEL-MI-VEX-ASM | mini-VEX + Strap | Phase 4 |
| │  │─ SEL-MI-VEX-001 | VEX chamber body (SS/Inconel) |  |
| │  └─ SEL-MI-THR-010 | Cu braid thermal strap (WEB→VEX) |  |
| │─ SEL-MI-WEB-ASM | Warm Electronics Box | Phase 5 |
| │  │─ SEL-MI-WEB-001 | WEB enclosure (sheet Ti) |  |
| │  │─ SEL-MI-TNK-001 | 50 L water tank (SS) |  |
| │  │─ SEL-MI-BAT-001 | 334 Wh battery pack |  |
| │  │─ SEL-MI-WEB-010 (x8) | LWRHU capsule |  |
| │  │─ SEL-MI-WEB-020 | 15 W kapton heater element |  |
| │  └─ SEL-MI-THR-001 | Wax thermal shunt assembly |  |
| │─ SEL-MI-PWR-ASM | Power Receptacle | Phase 6 |
| │  │─ SEL-MI-PWR-001 | Bayonet connector body |  |
| │  └─ SEL-MI-PWR-010 | PEEK mount spacer (Ø40 x 5) |  |
| │─ SEL-MI-COM-001 | Comms antenna mast | Phase 7 |
| │─ SEL-MI-PIP-ASM | Piping Assembly | Phase 8 |
| │  │─ SEL-MI-PIP-001 | Drain pipe Ti section 1 |  |
| │  │─ SEL-MI-PIP-002 | Drain pipe PEEK coupler |  |
| │  │─ SEL-MI-PIP-003 | Drain pipe Ti section 2 |  |
| │  │─ SEL-MI-PIP-010 | Feed chute Ti section |  |
| │  │─ SEL-MI-PIP-011 | Feed chute PEEK coupler |  |
| │  └─ SEL-MI-PIP-020 | VEX water tube + PEEK coupler |  |
| │─ SEL-MI-MLI-ASM | MLI Blankets | Phase 9 |
| │  │─ SEL-MI-MLI-001 | WEB MLI shell (20-layer) |  |
| │  │─ SEL-MI-MLI-010 | VEX MLI wrap (10-layer) |  |
| │  └─ SEL-MI-MLI-020 (x5) | MLI penetration collar |  |
| └─ SEL-MI-HRN-ASM | Harness Assembly | Phase 10 |
| │─ SEL-MI-HRN-001 | WEB bulkhead connector |  |
| │─ SEL-MI-HRN-010 | Power harness (AWG 20 Mn trans.) |  |
| │─ SEL-MI-HRN-020 | Wheel motor harness (AWG 22 Mn) |  |
| └─ SEL-MI-HRN-030 | Signal harness (AWG 28 Mn) |  |

# 4. Phase 1 — Chassis Skeleton (SEL-MI-CHS-ASM)
The chassis is the master reference for all other subsystems. Every mounting interface, hard point, and datum is defined here. Model this first and mate everything else to it.
## 4.1 Main Frame (SEL-MI-CHS-001)
Create as a weldment part. Insert → Weldments → Structural Member. Material: Ti-6Al-4V.
| Parameter | Value | Notes |
|---|---|---|
| Overall footprint | 2,800 × 1,600 mm (L × W) | Sketch on Top Plane |
| Main rail section | 50 × 50 × 3 mm rectangular tube | Two longitudinal rails, 1,400 mm apart (centre-to-centre) |
| Cross-members | 40 × 40 × 2 mm rectangular tube | 5 cross-members at 0, 700, 1,000, 1,800, 2,500 mm from front |
| Suspension rail | 60 × 30 × 3 mm channel | Runs full length outside main rails; hard points mount here |
| Target mass | ∼30 kg | Check with SolidWorks mass properties |
| Height (rail top) | ∼200 mm above wheel contact plane | Sets body ground clearance for 450 mm wheels |

### Mounting Interfaces (cut into frame)
Create these features on the chassis frame. Each is a datum for a sub-assembly mate. Use reference planes at each location.
| Feature | Location (from front, mm) | Geometry | Purpose |
|---|---|---|---|
| WEB standoff pads (4×) | 1,100–1,500 centre | 4× flat boss pad, 30 mm dia, 4× M6 through-holes on 160×100 mm bolt rectangle | PEEK standoff mounting (Phase 5) |
| VEX standoff pads (4×) | 500–800 centre-left | 4× flat boss pad, 22 mm dia, 4× M5 through-holes on 80×60 mm rectangle | PEEK VEX standoffs (Phase 4) |
| Drill mount pad | 100–200 front-centre | Flat pad 100×80 mm, 4× M8 bolt holes + Ø50 through-hole for bit clearance | Drill assembly + ceramic break |
| Receptacle boss | 2,650–2,750 rear-centre | Flat pad 50×40 mm, 2× M6 bolt holes + Ø35 central bore | Power connector + PEEK spacer |
| Drain valve aperture | 1,300 centre (bottom face) | Ø25 mm through-hole + flange ring (4× M4 tapped) | Bottom-drain valve from WEB tank |
| Suspension hard points (6×) | See Phase 2 table | Boss pad with 4× M8 bolt circle on suspension rail | Rocker-bogie pivot mounts |
| Shunt thermal pad | 1,200 bottom rail surface | Flat machined pad 15×10 mm, polished surface | Wax shunt Cu strap contact |
| VEX strap chassis pad | 800 bottom rail surface | Flat machined pad 30×5 mm, polished surface | VEX thermal strap (if routed to chassis) |

## 4.2 PEEK Thermal Standoffs
These are the thermal isolation components between the WEB/VEX and the chassis. They are separate parts mated to the chassis pads.
### WEB Standoffs (SEL-MI-CHS-010, qty 4)
| Parameter | Value |
|---|---|
| Material | PEEK (Victrex 450G) |
| Outer diameter | 20 mm |
| Bore diameter | 7 mm (M6 clearance) |
| Height | 50 mm |
| Profile | Solid cylinder, chamfer 0.5 mm top and bottom edges |
| Mass (each) | ∼14 g |
| Thermal conductance | G = 0.0297 W/K per standoff (from MOLEI_THERMAL v1.3) |

### PEEK Washers (SEL-MI-CHS-011, qty 8 — 2 per standoff)
| Parameter | Value |
|---|---|
| Material | PEEK |
| Outer diameter | 10 mm (bolt head footprint) |
| Inner diameter | 6.5 mm (M6 clearance) |
| Thickness | 5 mm |
| Purpose | Isolate Ti bolt head/nut from PEEK standoff ends. Bolt floats in 7 mm bore (vacuum gap). No metal-to-metal through-path. |

⚠ CRITICAL: The Ti M6 bolt must NOT contact the PEEK bore wall. The 7 mm bore provides 0.5 mm annular vacuum gap around the 6 mm shank. This vacuum gap is essential for thermal isolation. The bolt bears ONLY on the PEEK washers at each end.
### VEX Standoffs (SEL-MI-CHS-020, qty 4)
Same concept as WEB standoffs, smaller dimensions: 15 mm OD, 6 mm bore (M5 clearance), 30 mm tall, PEEK. Same washer approach (4 mm thick PEEK washers).
### Connector Spacer (SEL-MI-CHS-030, qty 1)
PEEK disc: 40 mm diameter, 5 mm thick, 2× M6 clearance holes at 30 mm spacing. Sits between power receptacle flange and chassis rear boss.

# 5. Phase 2 — Rocker-Bogie Suspension (SEL-MI-SUS-ASM)
Two mirrored sub-assemblies, one per side. Each contains a rocker arm, bogie arm, and two Ti flexure pivot blades. No bearings, springs, dampers, or lubricant at pivot points — JWST heritage for cryogenic flexure mechanisms.
## 5.1 Wheel Positions (from front of chassis)
| Wheel | X Position (mm) | Y Offset (mm) | Pair |
|---|---|---|---|
| W1 (front-left) | 185 | +800 (port) | Front |
| W2 (front-right) | 185 | –800 (stbd) | Front |
| W3 (mid-left) | 1,050 | +800 | Middle |
| W4 (mid-right) | 1,050 | –800 | Middle |
| W5 (rear-left) | 2,300 | +800 | Rear |
| W6 (rear-right) | 2,300 | –800 | Rear |

## 5.2 Ti Flexure Pivots (SEL-MI-SUS-010)
These replace conventional bearings. Model as a thin-wall titanium blade with necked-down cross-section at the flex point.
| Parameter | Value |
|---|---|
| Material | Ti-6Al-4V |
| Blade thickness at flex point | 2 mm |
| Blade width | 25 mm |
| Total length | 60 mm (20 mm flange – 20 mm flex zone – 20 mm flange) |
| Mounting flanges | 4× M6 bolt holes each end |
| Angular range | ±15° |
| Fatigue note | Verify with SolidWorks Simulation: must survive >10⁸ cycles at ±15° in Ti-6Al-4V at 40 K |

Mate each flexure to the chassis suspension hard point with Coincident + Concentric constraints. Use angle limits (±15°) in the mate properties.
## 5.3 Wheels (SEL-MI-WHL-ASM, qty 6)
| Parameter | Value |
|---|---|
| Wheel diameter | 450 mm |
| Wheel type | Spring-steel mesh (open weave, cosmetic pattern on tyre surface) |
| Hub motor | SmCo BLDC, ∼80 mm dia × 60 mm deep cylinder, integrated in hub |
| Gearbox | MoS₂-lubricated planetary, housing ∼60 mm dia × 40 mm |
| Gearbox heater | 5 W resistive band (kapton film) around gearbox housing |
| Steering actuator | Vertical shaft above hub, rotary SmCo motor, ±180° |
| Pt100 RTD sensor | Bonded to gearbox housing exterior, AWG 28 lead to harness |
| Mass per wheel unit | ∼7 kg (wheel 2.5 + motor 2.0 + gearbox 1.5 + steering 1.0) |

# 6. Phase 3 — Drill Assembly (SEL-MI-DRL-ASM)
| Parameter | Value |
|---|---|
| Housing | ∼65 × 100 × 90 mm (W×H×D), Ti-6Al-4V, ∼25 kg total |
| Motor | SmCo BLDC, rotary-percussive mechanism (ESA PROSPECT heritage, TRL 5–6) |
| Bit extension | 400 mm below chassis during operation, retracts for transit |
| Bit material | Tungsten carbide, replaceable (not in-situ — requires new MOLE-I unit) |
| Ceramic thermal break | Alumina (Al₂O₃) disc, 80 mm dia, 10 mm thick, sandwiched between drill housing base flange and chassis drill pad. 4× M8 through-bolts pass through all three layers. |
| Bearing heater | 15 W kapton film, bonded to bearing housing. Pt100 sensor adjacent. |
| Feed chute exit | Port on rear face of drill housing, 30 mm OD tube stub, connects to mini-VEX intake |
| Mounting | 4× M8 bolts through: chassis pad → ceramic break → drill housing flange |

⚠ The ceramic thermal break is SAFETY-CRITICAL. Without it, 200 W of drill waste heat conducts directly into the chassis and ultimately into the WEB, causing thermal runaway. The break reduces drill-to-chassis coupling to approximately 5% of generated waste heat.

# 7. Phase 4 — mini-VEX Chamber (SEL-MI-VEX-ASM)
| Parameter | Value |
|---|---|
| Chamber body | ∼95 × 70 × 55 mm exterior, ∼3 mm wall, SS 304 or Inconel |
| Mass | ∼20 kg |
| Operating power | 1,200 W (electric heating elements: nichrome wire wound to 833 Ω, powered at 1000 VDC direct from PDU bus via SiC MOSFET switch inside WEB. At 1000 V: 1.2 A through AWG22 Manganin transition. No local voltage conversion needed.) |
| Standby power | 0 W electric (was 25 W — eliminated by thermal strap from WEB) |
| Mounting | 4× PEEK standoffs (15 mm OD, 30 mm tall) to chassis VEX pads. M5 Ti bolts with PEEK washers. Same vacuum-gap isolation as WEB standoffs. |
| Intake port | Front face (drill-side), 30 mm OD tube connection from drill feed chute |
| Water outlet port | Rear face (WEB-side), 10 mm OD tube to WEB tank inlet |
| Tailings ejection (45° directional chute, ~150 mm SS, fixed lateral) | Bottom port with gate valve, dry regolith drops to ground |
| MLI | 10-layer aluminised Mylar wrap, separate from WEB MLI |

## 7.1 Thermal Strap: WEB → VEX (SEL-MI-THR-010)
This passive copper braid strap transfers excess LWRHU/heater heat from the WEB to the VEX, maintaining the VEX above 200 K without any electric standby heater.
| Parameter | Value |
|---|---|
| Material | OFHC copper braided strap, 40% fill factor |
| Cross-section | 25 × 3 mm (75 mm² gross, 30 mm² effective) |
| Length | 150 mm (flexible, follows gentle curve between WEB and VEX) |
| Attachment — WEB end | Bolted to WEB exterior shell via M4 × 2 stud pad (10 × 25 mm flat) |
| Attachment — VEX end | Bolted to VEX housing via M4 × 2 stud pad |
| Thermal capacity | 7.24 W across 73 K gradient (WEB 273 K → VEX 200 K) |
| VEX heat loss (at 200 K) | 3.07 W — strap capacity exceeds need by 2.4× |
| Mass | ∼40 g |
| Clearance | Must not contact MLI blankets. Route through gap between WEB and VEX MLI shells. |

# 8. Phase 5 — Warm Electronics Box (SEL-MI-WEB-ASM)
The WEB is the thermal heart of the MOLE-I. It maintains all electronics, the battery, and the water tank at 273 K. Every penetration through the WEB wall is a thermal leak path and must be designed with explicit thermal isolation.
## 8.1 WEB Enclosure (SEL-MI-WEB-001)
| Parameter | Value |
|---|---|
| External dimensions | 550 × 350 × 350 mm (L×W×H) |
| Wall material | Ti-6Al-4V sheet, 1.5 mm thick |
| Construction | Sheet metal part: 6 faces, welded seams, removable top panel (24× M3 fasteners) |
| Surface area | 1.015 m² |
| Wall penetrations | 5 groups: drain pipe, VEX tube, power harness, signal harness, antenna feedthrough |
| Target WEB mass (empty) | ∼10 kg (enclosure only, excluding contents) |

## 8.2 Internal Components
### Water Tank (SEL-MI-TNK-001)
50 L stainless steel (SS 304). Cylindrical or rectangular vessel. Bottom-drain valve fitting protrudes through WEB floor and chassis drain aperture. Mass: ∼5 kg empty, 55 kg full.
### Transit Battery (SEL-MI-BAT-001)
334 Wh / 1.3 kg. Space-grade Li-ion at 250 Wh/kg. Model as rectangular block ∼120 × 80 × 40 mm with terminal connectors on one end. Located adjacent to tank inside WEB.
### 8× LWRHU Capsules (SEL-MI-WEB-010, qty 8)
| Parameter | Value (from Pu-238 datasheet) |
|---|---|
| Thermal output | 1.1 ± 0.03 W each (8.8 W total) |
| Mass (max) | 42.00 g each |
| Diameter | 25.95 ± 0.05 mm |
| Length | 31.95 ± 0.05 mm |
| Arrangement | 2 rows of 4, evenly spaced along WEB floor panel |
| Role | Extended power-loss survival (>200 hr above 253 K). NOT indefinite hold. |

### 15 W Heater Element (SEL-MI-WEB-020)
Kapton film serpentine heater, ∼100 × 50 mm, bonded to WEB interior floor panel between LWRHU rows. Thermostat-controlled: bang-bang at 273 ± 2 K. Connected to WEB avionics via 2× AWG 20 leads.
⚠ The heater’s role is fine temperature regulation and transient recovery, not bulk heating. At steady state with 8 LWRHU and the thermal strap draw, the heater runs at ∼5.6 W average during drilling (thermostat cycles between 0 and 15 W). During dump retraction (no waste heat coupling), the heater runs near-continuously at ∼14.4 W.
## 8.3 Wax-Actuated Thermal Shunt (SEL-MI-THR-001)
This is a completely passive variable-conductance device that prevents WEB overheating during drilling. It has no power, no electronics, and no control logic. It was identified as a necessary design element by the multi-mode transient model (MOLEI_THERMAL v1.3, Section 8) which showed the WEB climbing to >300 K without it.
| Parameter | Value |
|---|---|
| Wax material | n-Tetradecane (C₁₄H₃₀), melting point 278.7 K |
| Engagement temperature | ∼278 K (wax melts, piston extends, Cu pad contacts chassis) |
| Disengagement temperature | ∼275 K (wax solidifies, spring retracts pad) |
| Hysteresis | ∼3 K (inherent from wax thermal mass) |
| Copper strap | Flat strip 10 × 1.6 mm, 100 mm long (OFHC Cu). Oversized to 1.5× for waste heat uncertainty. |
| Conductance (shunt ON) | G_shunt = 0.077 W/K (1.5× oversized) |
| Mounting — WEB end | Bolted to WEB exterior shell near bottom, M3 × 2 stud pad |
| Mounting — chassis end | Piston contact pad presses against chassis shunt thermal pad (polished, 15×10 mm) |
| Mass | ∼50–80 g total (capsule + strap + spring + housing) |
| Physical envelope | Capsule: ∼10 mm dia × 20 mm. Piston stroke: ∼3 mm. Total housing: ∼15 × 15 × 30 mm. |

In SolidWorks: model as a small rectangular housing bolted to the WEB shell bottom face, with the Cu flat strip exiting from the bottom face of the housing and running to the chassis shunt pad. The piston is internal (not visible in normal assembly view). Include in exploded view.
⚠ The shunt MUST disengage below 275 K. During power failure, the WEB cools and the shunt opens automatically, restoring full thermal isolation and preserving LWRHU survival performance. If the shunt stuck closed, the effective conductance would double and LWRHU survival time would halve.
## 8.4 WEB Sensor Array (8 channels)
| Sensor | Location | Type | Lead |
|---|---|---|---|
| T_web_1 (primary) | Interior wall, mid-height | Pt100 RTD | AWG 28 |
| T_web_2 (redundant) | Opposite interior wall | Pt100 RTD | AWG 28 |
| T_tank | Tank exterior surface | Pt100 RTD | AWG 28 |
| T_batt | Battery pack top surface | Pt100 RTD | AWG 28 |
| T_lwrhu_1–4 | LWRHU mount brackets (4 of 8) | Type K thermocouple | AWG 30 |

# 9. Phase 6 — Power Receptacle (SEL-MI-PWR-ASM)
| Parameter | Value |
|---|---|
| Connector body | Cylindrical, ∼30 mm dia × 40 mm long, Ti-6Al-4V housing |
| Type | Bayonet quick-connect (push-to-lock, twist-to-release) |
| Rating | 1,000 VDC |
| Pins | 2× power (1,000 V main), 2× PLC signal |
| Coating | MoS₂/PEEK on mating surfaces (cold-weld prevention, Holzbauer 2024) |
| Heater | 5 W resistive band around connector body (Pt100 sensor adjacent) |
| PEEK spacer | 40 mm dia, 5 mm thick disc between connector flange and chassis boss |
| Tether cable | AWG 14 Cu main conductors, 200 m to substation drum. 100 mm Manganin transition at connector end. |
| Location | Rear-centre of chassis. Connector axis aligned with –X (facing backward). |
| Protrusion | Connector face protrudes 10–15 mm beyond chassis rear face (for funnel-cradle engagement) |

## 9.1 Docking Interface
The MOLE-I docks by reversing into a passive funnel-cradle on the substation (or construction tether drum). No arm or manipulator is required. The cradle geometry is defined on the substation side, but the MOLE-I rear profile must be compatible:
• Rear face flat and clear of protrusions except the connector stub.
• Two rear proximity sensors (IR or ultrasonic) at 100 mm spacing, connected to WEB avionics.
• Connector centreline on chassis centreline (±2 mm tolerance).
• Chassis rear corners have 20 mm chamfers to avoid snagging on funnel guide rails.

# 10. Phase 7 — Communications Antenna (SEL-MI-COM-001)
Simple mast: ∼22 mm tall above chassis top surface, 6 mm dia Ti rod, dome or dipole element at top. Mounted on WEB top panel or chassis top rail, offset from centreline to clear drill assembly. 20 W radio is inside the WEB; this is the external RF element only. Mass: ∼0.2 kg. Antenna feedthrough through WEB/MLI is one of the 5 penetration groups.
# 11. Phase 8 — Piping Assembly (SEL-MI-PIP-ASM)
All pipes that cross from the WEB interior (273 K) to the exterior (40 K) must include PEEK thermal couplers to break the conduction path. The MOLEI_THERMAL v1.3 model showed that uninsulated SS pipes contribute 2–3 W each.
## 11.1 Drain Pipe — Rear-Routed (SEL-MI-PIP-001 through PIP-005, PIP-030)
| Parameter | Value |
|---|---|
| Configuration | Three-part series: Ti section 1 (75 mm) → PEEK coupler (50 mm) → Ti section 2 (75 mm) |
| Tube OD / ID | 20 / 18 mm (1 mm wall Ti sections) |
| PEEK coupler | 20 / 18 mm, 50 mm long, compression fittings at both ends |
| Routing | S-bend geometry to increase total path length (∼200 mm) |
| Thermal conductance | 0.054 W (PEEK section dominates — 84% of total resistance) |
| Valve | Bottom-drain ball or gate valve at lowest point. SS body, M4 bolts to chassis drain flange. |
| Actuator rod | 6 mm dia SS, 30 mm through WEB floor. Conducts 1.8 W — flagged as significant. Consider PEEK rod if load permits. |

## 11.2 Feed Chute: Drill → VEX (SEL-MI-PIP-010/011)
| Parameter | Value |
|---|---|
| Configuration | Two-part: SS tube section + PEEK coupler inline |
| Tube dimensions | 30 mm OD, 26 mm ID (2 mm wall), ∼60 mm SS + 40 mm PEEK = 100 mm total |
| Purpose | Gravity/auger feed of drilled icy regolith from drill housing to VEX intake |
| Thermal note | Without PEEK coupler, this path conducts 3.35 W. With coupler: ∼1.67 W (50% reduction). |

## 11.3 VEX Water Tube (SEL-MI-PIP-020)
10 mm OD, 8 mm ID tube from VEX condensation outlet to WEB tank inlet. Includes 40 mm PEEK inline coupler. Total conductance: 0.038 W (negligible).

# 12. Phase 9 — MLI Blankets (SEL-MI-MLI-ASM)
## 12.1 WEB MLI Shell (SEL-MI-MLI-001)
20+ layer aluminised Mylar with Dacron net spacers. Model as a surface offset ∼15 mm from WEB enclosure exterior, thickened to 2 mm. Apply gold Mylar appearance. Do NOT model individual layers — that is manufacturing detail.
| Parameter | Value |
|---|---|
| Layers | 20 minimum (Dye et al. 2010: 10-layer was 5–8× too optimistic) |
| Installed heat flux | ∼0.39 W/m² at 273/40 K (Lockheed model, 2× degradation factor) |
| Total MLI loss | 0.39 W (smallest contributor to WEB heat budget) |

## 12.2 Penetration Collars (SEL-MI-MLI-020, qty 5)
Each cable/pipe feedthrough compresses MLI locally, creating thermal short circuits. Industry figure (Gilmore, Spacecraft Thermal Control Handbook, 3rd ed): 0.3–1.0 W per penetration group. Design at 0.5 W average. These 5 penetrations collectively contribute 2.5 W — the single largest heat leak category in the optimised design.
Model each collar as a multi-layer ring (OD = feedthrough hole + 30 mm overlap, ID = feedthrough hole) with overlap flaps. In SolidWorks: a thin-wall revolved boss with split line for flap edges.
## 12.3 VEX MLI Wrap (SEL-MI-MLI-010)
10-layer, smaller blanket, 2.5× degradation factor (more edges and seams per unit area). Covers VEX housing exterior except port faces. ∼0.15 m² area.

# 13. Phase 10 — Harness Assembly (SEL-MI-HRN-ASM)
The MOLE-I has ∼49 individual conductors passing through the WEB wall. All conductors use a 100 mm Manganin (Cu-Mn-Ni alloy) transition section at the WEB penetration point. Inside the WEB: standard copper. Outside: standard copper to subsystems. Only the 100 mm crossing through the MLI/wall uses Manganin to minimise thermal conduction.
| Group | Gauge | Count | Destination | Manganin Section Loss |
|---|---|---|---|---|
| Tether power in | AWG 20 | 2 | From power receptacle to WEB bus | 0.039 W |
| Drill motor power | AWG 20 | 2 | WEB bus to drill SmCo motor | 0.039 W |
| VEX heater power | AWG 20 | 2 | WEB bus to VEX heating elements | 0.039 W |
| Wheel motor power | AWG 22 | 12 | WEB bus to 6× hub motors (2 per wheel) | 0.158 W |
| Power-line comms | AWG 28 | 2 | WEB comms hub to tether PLC | 0.006 W |
| Drill sensors | AWG 28 | 4 | Drill Pt100 + torque + vibration | 0.012 W |
| VEX control/sensors | AWG 28 | 4 | VEX thermocouples + valve control | 0.012 W |
| Wheel encoders + steering | AWG 28 | 12 | 6× encoder + 6× steering feedback | 0.036 W |
| Health sensors | AWG 28 | 4 | External Pt100 RTDs (drill, conn, VEX, strap) | 0.012 W |
| LWRHU monitoring | AWG 30 | 4 | 4× LWRHU thermocouples | 0.008 W |
| Antenna feedthrough | AWG 22 (coax) | 1 | RF coax to antenna element | 0.012 W |
|  | TOTAL | 49 |  | 0.359 W |

In SolidWorks Routing: define a single bulkhead connector on the WEB wall (or two: power and signal separated). Fan-out harness routes along chassis rails to each subsystem. Mark the 100 mm Manganin transition zone with a colour-coded segment at the WEB penetration.

# 14. Assembly-Level Verification
## 14.1 Mass Budget
| Subsystem | Target Mass | Check Method |
|---|---|---|
| Chassis frame | ∼30 kg | Weldment cut list mass properties |
| Suspension + wheels (6×) | ∼42 kg + 25 kg linkage | Sub-assembly mass |
| Drill assembly | ∼25 kg | Including ceramic break |
| mini-VEX | ∼20 kg | Including PEEK standoffs |
| WEB (empty enclosure) | ∼10 kg | Sheet metal part |
| Water tank (empty) | ∼5 kg | SS 304 |
| Battery pack | ∼1.3 kg | 334 Wh at 250 Wh/kg |
| LWRHU (8×) | ∼0.34 kg | 8 × 42 g |
| Thermal hardware (shunt + straps) | ∼0.13 kg | Shunt 80 g + VEX strap 40 g |
| Power receptacle + tether stub | ∼2 kg | Including PEEK spacer |
| Comms antenna | ∼0.2 kg |  |
| Piping + valves | ∼3 kg | All drain, chute, VEX tube |
| MLI blankets | ∼5 kg | WEB + VEX + collars |
| Harness | ∼3 kg | 108 conductors + connectors |
| Dust mitigation (seals etc.) | ∼3 kg | PTFE labyrinth seals on all shafts |
| TOTAL DRY | ∼360 kg | Must match spec. Iterate section sizes if over/under. |
| TOTAL WET (full tank) | ∼410 kg | 360 + 50 kg water |

## 14.2 Display States
Create four display states in the top-level assembly:
1. Full Assembly — all components visible, MLI blankets shown with gold Mylar appearance.
2. MLI Hidden — MLI blankets suppressed, shows internal WEB layout, piping, thermal hardware.
3. Thermal Paths — colour-code by thermal zone: red = 273 K (WEB interior), blue = 40 K (chassis/exterior), yellow = PEEK isolation boundaries, green = thermal straps/shunt.
4. Exploded View — standard exploded with callout balloons referencing part numbers from Section 3.
## 14.3 Custom Properties (on every part)
Add the following custom properties to every .SLDPRT file. These populate the BOM and maintain traceability to the design documentation.
| Property Name | Type | Example Value |
|---|---|---|
| Part Number | Text | SEL-MI-CHS-010 |
| Description | Text | PEEK WEB Standoff |
| Material | Text | PEEK Victrex 450G |
| Mass Target (kg) | Number | 0.014 |
| Operating Temp (K) | Number | 40–273 |
| Thermal Power (W) | Text | N/A or 15 W |
| Confidence | Text | HIGH / MED / LOW |
| Source Document | Text | MOLEI_THERMAL v1.3 §S2 |
| Notes | Text | Vacuum gap bolt isolation required |

## 14.4 Interference Check
Run Evaluate → Interference Detection on the full assembly after completing all phases. Key clearances to verify:
• PEEK standoff bore vs Ti bolt shank: 0.5 mm minimum annular gap (vacuum isolation).
• Thermal strap (WEB→VEX) vs MLI blankets: no contact anywhere along the 150 mm run.
• Wax shunt piston stroke (3 mm) vs chassis pad: contact at full extension, ≥3 mm clear at retraction.
• Drill bit at full extension (400 mm below chassis) vs wheel W1/W2 positions and ground plane.
• Tether cable exit from receptacle vs chassis rear face: clear path, no sharp bends.
• Feed chute path from drill rear face to VEX front face: check PEEK coupler sits between the two subsystems without fouling the WEB MLI.

# 15. Thermal and Power Summary
This section consolidates all thermal design parameters for quick reference during CAD review. All values are from MOLEI_THERMAL v1.3, verified by MATLAB ODE45 transient simulation and cross-checked in Python.
## 15.1 WEB Heat Loss Budget
| Path | Q (W) | Design Detail |
|---|---|---|
| A: PEEK standoffs (4×) | 1.94 | 20 mm OD, 7 mm bore, 50 mm tall, vacuum-gap bolt |
| B: Drain pipe (Ti + PEEK) | 0.05 | S-bend + 50 mm PEEK coupler |
| C: Cable harness (108 cond Mn, v1.3) | 0.36 | All Manganin 100 mm transition at WEB wall |
| D: VEX water tube | 0.04 | PEEK coupler 40 mm |
| E: MLI penetrations (5×) | 2.50 | 0.5 W per group (Gilmore 2002) |
| F: Drain valve actuator | 1.79 | SS rod 6 mm, 30 mm path |
| G: Feed chute (50% PEEK) | 1.67 | SS 30 mm tube + partial PEEK coupler |
| H: MLI blanket (20-layer) | 0.39 | 2× installed degradation factor |
| SUBTOTAL | 8.75 |  |
| 30% design margin | 2.62 |  |
| TOTAL | 11.37 | G_web = 0.0488 W/K |

## 15.2 Power Budget
| Subsystem | Operating (W) | Keep-Alive (W) | Notes |
|---|---|---|---|
| Drive motors (6×) | 300 | — | On during driving only |
| Drill (rotary-percussive) | 200 | — | On during drilling only |
| mini-VEX sublimation | 1,200 | — | 1,200 W op. 0 W standby (thermal strap). |
| WEB heater | 15 | 15 | Thermostat-controlled. Includes VEX strap draw. |
| Communications | 20 | 20 | Always on |
| Gearbox heaters (6×5 W) | 30 | 30 | Always on. Target 150 K. |
| Drill bearing heater | 15 | 15 | Always on standby. Redundant during drilling (waste heat). |
| Power receptacle heater | 5 | 5 | Always on. Could pulse-heat instead (future optimisation). |
| Thermal shunt | 0 | 0 | Fully passive. No electric power. |
| TOTAL | 1,785 | 65 |  |

## 15.3 Transit Battery
334 Wh / 1.3 kg. Sized: 65 W keep-alive × 4.7 hr descent × 1.10 margin. Floor transit range: ∼4.8 km at 0.5 m/s on keep-alive + drive power.
## 15.4 LWRHU Performance
8× LWRHU (8.8 W total). Equilibrium temperature (LWRHU-only, no electric heater): 220 K at 40 K floor, 205 K at 25 K wall. Does NOT hold 250 K indefinitely. Provides >200 hr above 253 K from 273 K starting point (50 L water thermal mass = 223 kJ/K). Role: cooldown rate reducer, not survival heater.
## 15.5 Thermal Shunt Performance
Without shunt: drilling cycles cause WEB to climb >300 K (thermal runaway). With 1.5× oversized shunt (G = 0.077 W/K): drilling equilibrium stable at ∼278 K. Shunt auto-disengages below 275 K during power failure — no impact on LWRHU survival.

# 16. Document History
| Rev | Date | Description |
|---|---|---|
| A | March 2026 | Initial release. Incorporates all findings from MOLEI_THERMAL v1.3, SELENITE_VERIFY v4.5, and programme document set (DESIGN v3, FLEET v6, GUIDE v17, STRATEGY v2.5). |

— End of Document —
ECN-012: §11.1 Rear Drain Pipe Routing (Rev C)
The drain pipe is rerouted from a vertical exit at mid-chassis bottom to a rear-exit nozzle adjacent to the tether receptacle. This change ensures the drain point aligns with the substation docking funnel position when the rover reverses in.
Routing: PIP-001 (Ti vertical section, WEB interior, unchanged) → PIP-002 (50 mm PEEK coupler at WEB wall, unchanged) → PIP-003 (revised: 1,350 mm Ti horizontal run along chassis bottom rail, 20 mm OD × 1 mm wall, secured with Ti saddle clips at 300 mm spacing) → PIP-004 (new: Ti 90° elbow) → PIP-005 (new: tapered drain nozzle, 25 mm exit cone, ~50 mm below chassis).
SolidWorks modelling: Use Swept Boss/Base along a 3D sketch path following the chassis bottom rail from the WEB drain aperture (position 1,300 mm) to the rear boss (position ~2,650 mm). The path runs parallel to the chassis side rail, offset inward by 30 mm. Mate the PIP-004 elbow with Concentric + Coincident to the pipe end and the PIP-005 nozzle.
PIP-030 trace heater: Model as a cosmetic wrap (orange Kapton appearance) along the full external length of PIP-003/004/005. Power leads (2× AWG 22) route to the WEB via 100 mm Manganin transition — add to harness group in Phase 10.
§13 Harness Assembly update: Conductor count increases from 51 to 53. Add pipe heater group: 2× AWG 22 (PIP-030 +/−), 100 mm Manganin transition. Thermal load: +0.004 W (negligible). Update MOLEI_THERMAL conductor table.
§8.2 WEB avionics update: Add pipe heater relay circuit to port controller. Trigger: tank level sensor ≥ 90% activates PIP-030 heater at 15 W. Deactivate: 3 min after drain valve closure signal.
ECN-013: IMU Part and Harness Update (March 2026)
§8.2 WEB Internal Components — add:
SEL-MI-NAV-001: MEMS 6-DOF IMU (e.g. Honeywell HG4930 or equivalent space-qualified unit). 0.05 kg. Board-mounted on WEB avionics PCB. SPI interface to PLC. 0.3 W continuous. Model as a small IC package (~20 × 20 × 5 mm) on the avionics board surface — no separate enclosure needed.
§13 Harness Assembly — update conductor count: 53 → 55. Add IMU group: 2× AWG 28 (SPI CLK + DATA), 100 mm Manganin transition at WEB wall. Thermal load increase: +0.004 W (negligible).
§8.2 Firmware addition: Kalman filter for navigation (tether polar + odometry + IMU fusion). Runs on existing PLC at 10 Hz. ~0.1 W additional compute. No hardware addition — firmware update only.
Navigation firmware receives tether polar fix from substation via PLC (range + bearing), fuses with 6× wheel encoder odometry and IMU heading. Outputs (x, y) position in substation-centred frame. Manages workspace drill grid (3,600 cells, 50 kB non-volatile storage on existing flash).
ECN-013 Rev 2: Bayonet Adapter SolidWorks (March 2026)
New part: SEL-MI-CON-001 — Motorised Bayonet Adapter.
Model as: Cylindrical housing (~30 mm dia × 40 mm tall) mounted on chassis underside, rear quadrant, offset from centreline to clear drain pipe routing. The housing contains the DC motor (inside WEB portion) and the actuator rod extending through the chassis floor. The bayonet plug (Ti, 20 mm dia, 2× L-slot pins) protrudes ~15 mm below chassis bottom face.
SolidWorks: (1) Create SEL-MI-CON-001 as a revolved part with motor housing (top, inside WEB) and plug body (bottom, outside). (2) Mate Concentric + Coincident to a new chassis boss at position ~2,400 mm, 50 mm offset from centreline. (3) Add PEEK thermal sleeve at WEB wall penetration (same approach as drain pipe PIP-002).
Harness: Add 2× AWG 22 motor leads to harness group. Conductor count: 55 → 57. Manganin transition 100 mm at WEB wall.
Actuator range: 90° rotation. Model as a cylindrical cam with 2× radial pins. In SolidWorks: use a Revolve Cut on the plug body for the L-slots, and a circular pattern of 2× Boss-Extrude for the pins.