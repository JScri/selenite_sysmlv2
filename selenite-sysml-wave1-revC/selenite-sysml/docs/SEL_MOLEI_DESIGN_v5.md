<!-- Markdown extract of docs/sources/SEL_MOLEI_DESIGN_v5.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

# Selenite Programme
# MOLE-I PSR Ice Extraction Rover — Engineering Design Specification
Reference: SEL_ROBOT_FLEET v3.2 §4 | SELENITE_VERIFY v4 | March 2026
Status: v1 DRAFT — for refinement in SolidWorks. All dimensions nominal; tolerances TBD.

## 1. Overview
MOLE-I is a purpose-built ice extraction rover for permanent operation inside Shackleton Crater's Permanently Shadowed Region (PSR). It drills icy permafrost, processes water vapour in-situ via an integrated mini-VEX sublimation chamber, stores liquid water in an onboard 50 L tank, and periodically retracts to its sub-station to dump water via gravity drain. It is permanently tethered to the sub-station for power and never leaves the PSR. Fleet scales from 10 (P3, 2 nodes) to 170 (P7+, 34 nodes) — the largest and most mission-critical robot class. Each unit yields 5,692 kg propellant per year.
## 2. Operating Environment
| Parameter | Specification | Conf |
|---|---|---|
| Location | Shackleton PSR floor. Design baseline: 40 K (10 K below Diviner minimum 50 K). | HIGH |
| Transit (descent) | ≤25 K on crater wall. ~4.7 hr at 0.5 m/s over 8,400 m slope (30°). | HIGH |
| Atmosphere | Hard vacuum. No convection. | HIGH |
| Gravity | 1.62 m/s² (1/6 g). Effective dry mass: ~60 kg. | HIGH |
| Regolith | Icy permafrost, 4.46% ice fraction, ~10–12 MPa compressive strength at 40 K. | MED |
| Power | Continuously tethered to sub-station via 200 m cable (1,000 VDC). Transit battery for descent and inter-node movement only. | HIGH |
| Operational lifetime | Permanent PSR resident. Never retrieved to surface. Replacement units descend from rim when needed. | HIGH |

## 3. Physical Configuration
| Parameter | Specification | Conf |
|---|---|---|
| Body dimensions | ~2,800 × 1,600 × 1,200 mm (L × W × H, excluding wheels and antenna). | MED |
| Dry mass | 360 kg (base platform 370 − 18 kg drum (on substation) + 5 kg water tank + 3 kg extra wheels (6 vs 4)). | MED |
| Wet mass (full tank) | 410 kg (360 dry + 50 kg water). | HIGH |
| Chassis | Welded Ti-6Al-4V frame. 6-wheel rocker-bogie suspension with titanium flexure pivots (no springs, no dampers, no hydraulics, no lubricant — pure linkage geometry, ±15° range, JWST heritage). | HIGH |
| MLI shell | 20+ layer aluminised Mylar / Dacron net spacers. ~2 m² exterior surface. Real-world heat leak ~0.5–1.5 W/m² at 40 K. | MED |
| Dust mitigation | Spring-loaded PTFE labyrinth seals on all rotating shafts (>1M cycles, NASA tested). EDS on optics. Tungsten carbide drill tips. | MED |

## 4. Subsystem Breakdown
### 4.1 Warm Electronics Box (WEB)
| Parameter | Specification | Conf |
|---|---|---|
| Mass | ~15 kg (enclosure + contents, excluding tank and battery) | MED |
| Operating temp | 273 K setpoint (always). Required for Li-ion charging (minimum 253 K). | HIGH |
| Heater | 15 W electric resistance (floor, 40 K ambient, MOLEI_THERMAL v1.3 bottom-up: 11.6 W WEB loss + 3.1 W VEX strap = 14.7 W). Includes wax-actuated thermal shunt (n-tetradecane, 278 K, passive) to prevent drilling overheating. 8× LWRHU provide extended survival (>200 hr above 253 K). 108 conductors through WEB wall (all Manganin 100 mm transition). VEX heater: 1000 VDC direct via SiC MOSFET (833 Ω nichrome), eliminating 25 W standby heater via Cu braid thermal strap. 18 W transit (≤25 K wall). MUST NEVER SWITCH OFF — loss of WEB is immediately fatal. | HIGH |
| Cold-start | 8× LWRHU (1.1 W each, 42 g each, Pu-238). Provides ~8.8 W continuous — sufficient to maintain WEB above 250 K indefinitely even with complete power loss. | HIGH |
| Insulation | 20+ layer MLI. 10-layer was 5–8× too optimistic per Dye et al. 2010 / NASA KSC data. | MED |
| Contents | Avionics, port controller, comms hub, health sensors. Houses transit battery and 50 L water tank within thermal envelope. | MED |

### 4.2 Drive System (6-Wheel)
| Parameter | Specification | Conf |
|---|---|---|
| Wheels | 6× spring-steel mesh, 450 mm diameter. Independently driven and steered. | HIGH |
| Motors | SmCo BLDC hub motors (samarium-cobalt magnets — NdFeB excluded due to spin reorientation at 135 K causing ~14% flux loss). All actuation electromechanical — no hydraulics viable below 200 K. | HIGH |
| Suspension | Rocker-bogie with titanium flexure pivots. No bearings, no springs, no dampers, no lubricant at pivot points. PEEK bushings as fallback if flexures prove insufficient. ±15° range. JWST heritage for cryogenic flexure mechanisms. | HIGH |
| Gearboxes | MoS₂ lubricated (pure or lightly doped — not heavily doped). Acceptable friction increase ~2.5× at 77–90 K vs room temp. Catastrophic wear regime only below ~20 K. | MED |
| Gearbox heaters | 30 W total (6 × 5 W per wheel). Continuous. Maintains gearbox above ~150 K. | HIGH |
| Drive power | 300 W total for locomotion (all 6 wheels). | HIGH |
| Speed | 0.5 m/s maximum. 25° grade capability. | MED |
| Traction | Spring-steel mesh on icy permafrost at 40 K. Coefficient ~0.3–0.4 (sufficient for 27 kg effective weight + sled towing). | LOW |

### 4.3 Rotary-Percussive Drill
| Parameter | Specification | Conf |
|---|---|---|
| Mass | ~25 kg | MED |
| Power | 200 W (operating). | HIGH |
| Type | Rotary-percussive. ESA PROSPECT heritage (TRL 5–6). Designed for icy regolith at cryogenic temperatures. | HIGH |
| Drilling rate | 25 kg/hr in icy permafrost at 40 K (4.46% ice fraction, ~10–12 MPa). Rate-limited vs MOLE-S 50 kg/hr on loose regolith. | MED |
| Drill tip | Tungsten carbide. Replaceable (but not in-situ — replacement requires new MOLE-I unit). | MED |
| Bearing heater | 15 W continuous. Maintains drill bearing above ~100 K. | MED |
| Thermal break | Ceramic (alumina or zirconia) thermal isolator between drill assembly and chassis. Prevents drill heat from leaking into WEB or chassis conductively. | MED |
| Mounting | Front-centre of chassis. Bit extends ~400 mm below chassis during operation. | MED |

### 4.4 mini-VEX Sublimation Chamber
| Parameter | Specification | Conf |
|---|---|---|
| Mass | ~20 kg | MED |
| Operating power | 1,200 W. CRITICAL UPRATE from prior 100 W (which was standby-only). LOW confidence pending FEA thermal model. | LOW |
| Standby power | 0 W (eliminated: Cu braid thermal strap from WEB provides passive heating; was 25 W). VEX heater now 1000 VDC direct via SiC MOSFET (833 Ω nichrome). Ref: MOLEI_THERMAL v1.3. | MED |
| Thermodynamic minimum | ~935 W: 77 W sensible heat (ice 40→273 K) + 745 W sublimation (L_sub 2,830 kJ/kg, VERIFIED) + 212 W regolith heating − 100 W drill heat recovery. 1,200 W design = 28% margin. | LOW |
| Process | Sealed chamber receives drilled icy regolith. Heats to sublimate water ice. Condenses vapour to liquid water. Outputs liquid to 50 L tank inside WEB. Dry tailings ejected. | MED |
| Recovery efficiency | 85% (hardware specification — net effective rate already accounts for this in the 25 kg/hr figure). | MED |
| Feed from drill | Direct mechanical feed path from drill assembly to chamber. Adjacent mounting. | MED |

### 4.5 Water Tank & Dump System
| Parameter | Specification | Conf |
|---|---|---|
| Mass (empty) | ~5 kg | MED |
| Capacity | 50 L (50 kg water). | HIGH |
| Material | Stainless steel, insulated. Inside WEB thermal envelope — water stays liquid at 273 K passively. | HIGH |
| Fill time | ~44.8 hr at 1.115 kg/hr water rate (from mini-VEX output). | HIGH |
| Dump mechanism | Bottom-drain valve. MOLE-I drives onto sub-station docking cradle, valve opens, water flows through rear-routed heated pipe (15 W, ECN-012) to rear nozzle adjacent to tether receptacle, drops into substation docking funnel. No precision fluid coupling. | MED |
| Dump time | ~15 min drain + 33 min retraction each way (200 m at 0.1 m/s) = ~1.4 hr total cycle. | MED |
| Cycle availability | 97.1% (44.8 hr drilling / 46.2 hr total cycle). | HIGH |

### 4.6 Transit Battery
| Parameter | Specification | Conf |
|---|---|---|
| Capacity | 334 Wh / 1.3 kg. Space-grade Li-ion at 250 Wh/kg. (65 W keep-alive × 4.7 hr × 1.10 margin). Ref: MOLEI_THERMAL v1.3. | HIGH |
| Sizing | 65 W keep-alive × 4.7 hr descent × 1.10 margin = 334 Wh. Ref: MOLEI_THERMAL v1.3. | HIGH |
| Range on battery | ~8.3 km at 0.5 m/s (422 W driving + keep-alive). Sufficient for transit from CLP to any node in the fishbone network. | MED |
| Construction hop | 100 m hop between branch cable taps: ~23 Wh. Battery cycles 96–100%. Never depletes during construction work. | MED |
| Location | Inside WEB at 273 K. Standard Li-ion chemistry acceptable at this temperature. | HIGH |
| Charging | Via sub-station tether whenever docked. No separate charging cycle needed — charges continuously during drilling operations. | HIGH |

### 4.7 Power Receptacle & Tether Interface
| Parameter | Specification | Conf |
|---|---|---|
| Mass | ~2 kg | MED |
| Heater | 5 W continuous. Maintains connector above ~100 K to prevent thermal seizure. | MED |
| Connector | Bayonet quick-connect, 1,000 VDC rated. MoS₂/PEEK coated — cold-weld prevention via coating (not dissimilar-metal pairing, per Holzbauer et al. 2024). | HIGH |
| Location | Rear-centre of chassis. Tether trails behind during drilling, managed by sub-station constant-tension drum. | MED |
| Power-line comms | Superimposed on power tether. Used for batch dump coordination and telemetry to sub-station. | MED |

### 4.8 Communications
| Parameter | Specification | Conf |
|---|---|---|
| Mass | ~2 kg (inside WEB) | MED |
| Power | 20 W continuous. | HIGH |
| Primary | Power-line comms on tether to sub-station → sub-station relays via spine network to base ops hub. | MED |
| Backup | RF relay for off-tether situations (transit, construction work with temporary tether). | MED |
| Latency to Earth | 2.56 s round-trip. Sufficient for monitoring and exception handling; not real-time control. | HIGH |

## 5. Complete Power Budget
| Subsystem | Power | Duty | Conf |
|---|---|---|---|
| Drive motors (6 wheels) | 300 W | Operating only | HIGH |
| Drill (rotary-percussive) | 200 W | Operating only | HIGH |
| mini-VEX sublimation | 1,200 W | Operating only | LOW |
| WEB heater (273 K) | 15 W | ALWAYS ON | HIGH |
| Communications | 20 W | ALWAYS ON | HIGH |
| Gearbox heaters (6×5 W) | 30 W | ALWAYS ON | HIGH |
| Drill bearing heater | 15 W | ALWAYS ON | MED |
| Power receptacle heater | 5 W | ALWAYS ON | MED |
| mini-VEX standby | 25 W | ALWAYS ON | MED |
| TOTAL OPERATING | 1,785 W (1,934 W at tether incl DC-DC losses) |  |  |
| TOTAL KEEP-ALIVE | 65 W (WEB 15 + gearbox 30 + drill htr 15 + recept 5 + VEX stby 0). Tether draw 1,934 W (load 1,785 + DC-DC 99 + batt 50). 1000 VDC end-to-end architecture. Ref: MOLEI_THERMAL v1.3, VERIFY v4.5. |  |  |

## 6. Production & Yield
| Parameter | Specification | Conf |
|---|---|---|
| Water extraction rate | 25 kg/hr (net effective, includes 85% mini-VEX recovery). Rate-limited by icy substrate hardness at 40 K. | MED |
| Water per year | 7,818 kg/yr (25 × 4.46% ice × 80% availability × 8,760 hr). | HIGH |
| Propellant yield | 5,692 kg/yr per unit (7,818 × 0.722 electrolysis efficiency). LOCKED from v2. | HIGH |
| Electrolysis ratio | 0.722 (H₂:O₂ mass ratio for LH₂/LOX at 6:1 mixture ratio via PEM). | HIGH |
| PROBE equivalence | ~0.855 PROBE missions per MOLE-I per year (5,692 / 6,654 kg per mission). | HIGH |
| Fleet at P7+ | 170 units × 5,692 = 967,640 kg/yr (967.6 t/yr). Demand 867.6 t/yr. Margin +100 t/yr (+11.6%). | HIGH |

## 7. Fleet Scaling (Demand-Driven)
| Phase | MOLE-I | Nodes | Supply (t/yr) | Demand (t/yr) | Margin |
|---|---|---|---|---|---|
| P3 Y4–7 | 10 | 2 | 56.9 | 0 | +56.9 (stockpile) |
| P4 Y7–9 | 25 | 5 | 142.3 | 124.1 | +18.2 |
| P5 Y9–12 | 50 | 10 | 284.6 | 237.9 | +46.7 |
| P6 Y12–15 | 85 | 17 | 483.8 | 433.8 | +50.0 |
| P7+ Y20+ | 170 | 34 | 967.6 | 867.6 | +100.0 |

MATLAB v4 verified. Fleet = ceil(demand × 1.10 / 5,692), rounded to ×5 (full nodes). Bilateral fishbone sub-stations from CLP.
## 8. Deployment
MOLE-I units descend from the rim via the trunk cable winch one at a time (4.7 hr each at 0.5 m/s). On arrival at the CLP staging area, each unit transits on battery to its assigned sub-station and docks at a permanent tether port. The first MOLE-I on each branch doubles as the construction unit — it pulls spine/branch cables, drives stakes, erects support posts (tilt-up method), and tows sub-station sleds into position before transitioning to permanent drilling operations. No dedicated construction robots needed in the PSR.
Cold spares: 21 units (12% of P7+ fleet) maintained on the surface at all times. Resupply every 2 years with regular cargo launches. ~4 MOLE-I per cargo launch at 360 kg/unit.
## 9. Failure Response
| Parameter | Specification | Conf |
|---|---|---|
| Tier 1 — Single unit | Dead unit sits in place (inert 360 kg obstacle). Sub-station retracts tether. Replacement descends from surface spares, docks at spare port. | HIGH |
| Tier 2 — Multi-failure at node | Investigate before deploying more (terrain hazard? thermal anomaly? batch defect?). Other nodes absorb shortfall. | MED |
| Tier 3 — Node loss | Abandon node. Deploy replacement at different location via standard sequence. | MED |
| Tier 4 — Fleet degradation | Draw propellant stockpile (997 t at programme end = 27.6 months P6 reserve). Reduce PROBE cadence. Suspend SKIP. Emergency Earth propellant. If <50% fleet for 18 months → orderly wind-down. | MED |

★ This is a v1 design specification for refinement in SolidWorks. Connector detail, weld specifications, MLI layup, suspension hard points, drill integration geometry, and harness routing require CAD development.
## ECN-012 Additions — Rear Drain Pipe (March 2026)
New parts added per SEL-ECN-012:
SEL-MI-PIP-003 (revised): Ti tube, 20 mm OD × 1 mm wall, ~1,350 mm horizontal run along chassis bottom rail from WEB wall to rear. Secured with Ti saddle clips at 300 mm spacing. Routed inside MLI shroud envelope.
SEL-MI-PIP-004 (new): Ti 90° elbow at rear transition, 20 mm OD. Connects horizontal run to downward nozzle.
SEL-MI-PIP-005 (new): Rear drain nozzle, Ti, 20 mm OD tapering to 25 mm exit cone. ~50 mm protrusion below chassis bottom face. Exit at ~200 mm above ground.
SEL-MI-PIP-030 (new): Kapton film trace heater, 15 W rated, full length of PIP-003/004/005. AWG 22 leads, 100 mm Manganin transition at WEB wall. Adds 2 conductors to harness (51 → 53 total).
Mass impact: +0.3 kg (elbow 0.1 + nozzle 0.15 + heater 0.05). Dry mass 360 → 360.3 kg.
Power impact: 15 W × 11.5% duty = 1.7 W average. Negligible against 1,934 W tether draw. No power budget revision required.
Heating strategy: (1) Pre-heat at tank ≥90%, ~4.5 hr before dump. (2) Heater on during retraction (33 min). (3) Heater on during dump (15 min). (4) Purge: heater holds 3 min after valve close. (5) Heater off, pipe cools to 40 K passively (empty, no freeze risk).
# ECN-013: Navigation Subsystem and Construction RF Comms (March 2026)
§4 (new) Navigation and Workspace Management:
The MOLE-I navigates using a three-layer positioning system. Primary: tether-based polar fix from the substation (range from drum payout encoder, bearing from new 2-axis angle encoder SEL-SUB-DRM-040 on guide roller). Secondary: wheel odometry from 6× wheel encoders + 6× steering sensors (existing hardware). Tertiary: MEMS 6-DOF IMU (SEL-MI-NAV-001, 0.05 kg, 0.3 W, inside WEB). A Kalman filter on the WEB avionics board fuses all three inputs at 10 Hz, providing ±0.5 m position accuracy during drilling.
Workspace grid: The rover's 72° × 200 m sector is discretised into 3,600 cells (2 m radial × 2° angular bins). Each cell stores drill status, depth, yield, and timestamp. Grid stored in non-volatile flash on WEB avionics (~50 kB). Uploaded to substation via PLC after each dump cycle. Grid enables systematic lawn-mower drilling with no gaps or re-drilling.
Hardware additions: SEL-MI-NAV-001 (MEMS IMU, 0.05 kg, 0.3 W, SPI interface). Harness count: 53 → 55 conductors (+2× AWG 28 for IMU). Dry mass: 360.3 → 360.35 kg.
§4.7 (amended) Construction RF Comms:
During construction operations on temporary tethers (100 m, construction tap points), the MOLE-I switches from PLC to UHF comms automatically. The 20 W UHF radio (existing SEL-MI-COM-001) communicates with the substation UHF relay mesh for position reports, power status, and construction gate requests. PLC/UHF switchover is managed by WEB avionics based on tether connection type (permanent drum port = PLC; construction tap = UHF).
Full navigation specification: SEL-NAV-001 Rev A.
# ECN-013 Rev 2: Motorised Bayonet Adapter (March 2026)
ECN-013 Rev 2: Motorised Bayonet Adapter (SEL-MI-CON-001)

The MOLE-I requires active bayonet engagement for construction tap connections during branch build-out (hop-scotch pattern, plug/unplug every 100 m). The permanent tether receptacle at the rear is passive (substation drum tether plugs into the rover). Construction taps are fixed sockets on the branch cable — the rover must actively engage and disengage them.
Hardware: A motorised bayonet adapter mounted on the chassis underside near the rear. A small DC motor (28 V, ~2 W, inside WEB thermal envelope) drives an actuator rod through the WEB wall (via Manganin transition, PEEK thermal sleeve) to a bayonet plug below the chassis. The plug has two L-slot pins matching the construction tap socket profile.
Engagement sequence: (1) MOLE-I positions over construction tap (navigation via tether polar fix + odometry). (2) Rover lowers chassis onto the tap socket using suspension compliance (~20 mm travel). Chassis weight at 1/6 g provides ~98 N downforce — sufficient to seat the bayonet pins in the axial slots. (3) Motor rotates actuator 90° (twist-lock). Detent clicks. Motor de-energises. Connection is passively held by detent — no power needed to maintain lock.
Disengagement: Motor re-energises, rotates 90° back (untwist). Detent releases. Rover drives forward, pulling the bayonet free from the axial slot.
Specifications: SEL-MI-CON-001. Mass: ~0.3 kg (motor 0.15 + actuator rod 0.1 + plug body 0.05). Power: 2 W during rotation only (~0.5 s per engage/disengage cycle). Standby: 0 W (detent holds passively). Interface: 2× AWG 22 motor leads through WEB wall (Manganin transition). Harness count: 55 → 57 conductors.
Dry mass impact: 360.35 → 360.65 kg. Negligible.
The same adapter can engage the SATS construction tap at the CLP, substation construction taps during branch build-out, and any future junction box requiring active connection. When the MOLE-I returns to its permanent drum tether (passive receptacle at rear), the bayonet adapter is stowed (retracted, motor de-energised).
# ECN-013 Rev 3: Construction Tether Interface (March 2026)
During branch construction, the MOLE-I draws power from spring-loaded retraction spools (SEL-SUB-TAP-010) at construction tap points every 100 m on the branch cable. The spool pays out and retracts the 100 m construction tether automatically at ~5 N tension (clock spring, no power), keeping the cable off the ground and clear of stakes, posts, and construction work.
The MOLE-I engages and disengages the spool’s bayonet plug via its motorised bayonet adapter (SEL-MI-CON-001, 2 W intermittent, 90° twist). The tether carries 1000 VDC power and PLC is NOT available on construction tethers — the MOLE-I automatically switches to UHF comms when connected to a construction tap (ECN-013).