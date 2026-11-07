<!-- Markdown extract of docs/sources/SEL-SW-SUB-001_RevC.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
PSR Substation Node
SolidWorks CAD Modelling Sequence
Reference: SEL-SW-SUB-001 Rev A
Source Documents:
SEL_SUBSTATION_DESIGN v2 — Engineering Design Specification
SEL_ROBOT_FLEET v6 — Robot Fleet and Infrastructure Specification
MOLEI_THERMAL v1.3 — Substation WEB thermal audit (§S10–S13)
SELENITE_VERIFY v4.5 — Fleet power model (node total 9.77 kW)
SEL-SW-MOLEI-001 Rev B — MOLE-I SolidWorks guide (docking interface)
VISUALIZE v3.3 — Bilateral fishbone layout (junction geometry)
# 1. Scope and Purpose
This document provides the phase-by-phase SolidWorks modelling sequence for the PSR substation node — the infrastructure unit that distributes power and collects water from up to 5 MOLE-I rovers in the Selenite bilateral fishbone mining network. It is the companion document to SEL-SW-MOLEI-001 Rev B (MOLE-I modelling guide) and must be cross-referenced for docking interface geometry.
The substation has a fundamentally different character from the MOLE-I: it is a static node (no wheels, no drill, no suspension) built around a pentagonal prism frame with five radial cable drum assemblies, a central WEB, a water collection manifold, and a 3 m support mast carrying the riser pipe to the branch pipeline. It is deployed on a cable-guided sled and anchored in place permanently.
⚠ The substation WEB thermal audit (MOLEI_THERMAL v1.3 §S10–S12) revealed the original 80 W heater spec was 8× oversized. All thermal parameters in this document use the audited values: 10.5 W heater, 3× LWRHU (33 hr survival), 63 conductors through WEB wall with Manganin bus bar transitions.
# 2. Conventions
## 2.1 Part Numbering
SEL-SUB-{system}-{seq}  e.g. SEL-SUB-FRM-001 (frame base plate)
System codes: FRM (frame/structure), WEB (warm electronics box), DRM (cable drum), BUS (power distribution), WAT (water handling), COM (communications), MLI (thermal insulation), HRN (harness), SLD (sled/deployment).
## 2.2 Units and Coordinate System
All dimensions in mm. Origin at geometric centre of pentagonal base, Z up. The primary vertex (Face 1 centre) is at 0° (positive Y axis). Subsequent faces at 72°, 144°, 216°, 288° anticlockwise viewed from above. Face numbering matches MOLE-I port numbering (Port 1–Port 5, Port 6 = spare).
## 2.3 Materials Library
| Material | Application | Notes |
|---|---|---|
| Ti-6Al-4V | Frame, anchors, riser pipe, brackets | No ductile-brittle transition. Flight heritage. |
| OFHC Cu | Bus bars (cold side), tether conductors | Conductivity improves at cryo. Mn transition at WEB wall. |
| Manganin (Cu-Mn-Ni) | Bus bar WEB wall transitions (20 mm), signal harness (100 mm) | k = 10–20 W/mK. Prevents thermal short. |
| PEEK | WEB standoffs, funnel sleeves, pipe couplers | k = 0.25 W/mK. Structural at cryo. |
| 316L SS | Water manifold, riser inner pipe, bellows | Food-grade. Electropolished where silver contact. |
| Kapton | Tether insulation, MLI substrate | Radiation-tolerant. Flexible at cryo. |
| DAM / Dacron | 20-layer MLI blanket | Aluminised Mylar + Dacron net spacers. |
| PTFE | Sled runners | Low friction on regolith at cryo. |

# 3. Assembly Structure
Top-level assembly: SEL-SUB-TOP-ASM
| Phase | Sub-assembly |
|---|---|
| 1 | Frame and Anchoring (SEL-SUB-FRM-ASM) |
| 2 | Cable Drum Assemblies ×5 (SEL-SUB-DRM-ASM) |
| 3 | Power Distribution Bus (SEL-SUB-BUS-ASM) |
| 4 | Warm Electronics Box (SEL-SUB-WEB-ASM) |
| 5 | Water Handling: Manifold + Riser (SEL-SUB-WAT-ASM) |
| 6 | Communications + Antenna (SEL-SUB-COM-ASM) |
| 7 | Support Mast (SEL-SUB-MST-ASM) |
| 8 | MLI + Dust Shroud (SEL-SUB-MLI-ASM) |
| 9 | Harness Assembly (SEL-SUB-HRN-ASM) |
| 10 | Sled + Deployment Hardware (SEL-SUB-SLD-ASM) |

# 4. Phase 1 — Frame and Anchoring (SEL-SUB-FRM-ASM)
The pentagonal prism frame is the structural backbone. Five faces at 72° spacing, each aligned with one MOLE-I operating sector.
## 4.1 Base Plate (SEL-SUB-FRM-001)
| Geometry | Regular pentagon, 1,400 mm face-to-face inscribed diameter (~808 mm face length). 8 mm Ti-6Al-4V plate. 5× central mounting holes (drum pivots). Central hole for riser pipe pass-through. |
|---|---|
| Mounting | 5× drum cradle bolt patterns (M8 ×4 per face). Central manifold mounting ring (6× M6). 4× anchor boss locations (through-holes for Ti screw anchors). |
| PTFE runners | 2× PTFE strips (25×10 mm cross-section, full face length) bonded to underside for sled transit. Sacrifice material — not structural. |

## 4.2 Top Ring (SEL-SUB-FRM-002)
| Geometry | Pentagonal ring, same inscribed diameter as base plate. 6 mm Ti plate, 80 mm ring width. Open centre for WEB access and riser pipe. |
|---|---|
| Mounting | 5× drum top bearing holes. Mast socket (60 mm OD tube receiver). Antenna bracket. |

## 4.3 Vertical Struts (SEL-SUB-FRM-010, qty 5)
Ti-6Al-4V tube, 30 mm OD × 2 mm wall × 450 mm tall. One at each vertex of the pentagon, connecting base plate to top ring. Welded. These define the overall height of the main body (excluding mast).
## 4.4 Screw Anchors (SEL-SUB-FRM-020, qty 4)
Ti-6Al-4V, 500 mm penetration depth, spring-loaded deployment. Activated after sled reaches final position. 4 anchors at alternating vertices (not all 5 — one vertex left clear for riser pipe routing). Anchor force: ~200 N each at 1/6 g. Total hold-down: ~800 N vs ~260 N gravity load.
# 5. Phase 2 — Cable Drum Assemblies (SEL-SUB-DRM-ASM)
Five identical drum units, one per pentagonal face. Each manages a 200 m tether to one MOLE-I.
| Drum body | SEL-SUB-DRM-001. Cylindrical spool, ~200 mm dia × 120 mm wide. Ti-6Al-4V flanges, Al core. 200 m of AWG14 Kapton-insulated OFHC Cu tether (~3.2 kg Cu + 1.8 kg insulation per drum). |
|---|---|
| Motor | SEL-SUB-DRM-010. SmCo DC constant-tension motor, 28 V, ~1A max. Gearbox with MoS₂ dry lubrication. 50 N tension feedback loop (prevents slack or snag). |
| Gearbox heater | SEL-SUB-DRM-020. 8 W Kapton film heater on gearbox housing. Continuous during operations. MLI wrap over motor+gearbox. |
| Docking cradle | SEL-SUB-DRM-030. Conical guide funnel (200 mm capture cone, ±50 mm position tolerance). Gravity-drain water port at funnel base → manifold pipe (through PEEK thermal sleeve). Funnel lip heater: 3 W Kapton (active during dump only). |
| Tether exit | Guide roller (PEEK bushing) at frame face. Prevents tether abrasion on Ti edge. Tether exits radially outward toward MOLE-I sector. |
| Mounting | 4× M8 bolts to base plate drum cradle. Top bearing journal in top ring hole. Drum axis horizontal (parallel to base plate), parallel to pentagonal face (tangential). Tether exits radially outward through PEEK guide roller on the face. |

⚠ The 6th port (spare) has a drum position but no drum installed at initial deployment. The cradle, manifold pipe, and circuit breaker are present. A replacement drum can be installed by a construction MOLE-I if any drum fails.
# 6. Phase 3 — Power Distribution Bus (SEL-SUB-BUS-ASM)
The substation is a passive 1000 VDC bus bar — no voltage conversion for the MOLE-I tethers. An internal DC-DC converter (1000→28 V) powers the substation’s own heaters, motors, and sensors.
| Bus bar | SEL-SUB-BUS-001. OFHC Cu, 2× input bars (AWG14, ~10 A from branch cable) + 12× output bars (AWG14, ~2 A per port). Cold-side Cu. At WEB wall penetration: 20 mm Manganin (Cu-Mn-Ni) transition to prevent thermal short circuit. Without Manganin: >160 W thermal leak. |
|---|---|
| Breakers | SEL-SUB-BUS-010, qty 6. Solenoid-actuated mechanical breakers inside WEB (273 K). One per port. Normally open; close on command from port allocation controller. Fail-safe: power loss = breaker opens. |
| Branch connector | SEL-SUB-BUS-020. Bayonet power socket on exterior frame. 1000 VDC, ~10 A rated. PEEK spacer ring for thermal isolation. Make-before-break protocol (solenoid closes AFTER connector fully seated). |
| Construction tap | SEL-SUB-BUS-030. Secondary bayonet socket on exterior, same spec. For construction MOLE-I temporary tether during deployment phase. |
| Internal DC-DC | SEL-SUB-BUS-040. 1000→28 V converter, ~93% efficiency, inside WEB. Powers all substation own loads (heaters, motors, controller, sensors). ~100 W capacity. |

# 7. Phase 4 — Warm Electronics Box (SEL-SUB-WEB-ASM)
Central thermal enclosure mounted on the base plate inside the pentagonal frame. Protects electronics, breakers, controller, and manifold from 40–90 K environment.
## 7.1 WEB Enclosure (SEL-SUB-WEB-001)
| Geometry | 350 × 250 × 250 mm (L×W×H). 1.5 mm Ti-6Al-4V welded box. Surface area: 0.475 m². Ref: MOLEI_THERMAL v1.3 §S10. |
|---|---|
| Thermal mass | C = 25,830 J/K (5 kg water in manifold + 3 kg electronics + 5 kg structure). |
| Standoffs | 4× PEEK standoffs (15 mm OD, 6 mm bore, 30 mm tall) at corners. Vacuum-gap Ti bolt through PEEK washer. Q = 2.007 W total. |
| Heater | 10.5 W resistance element (MOLEI_THERMAL v1.3 audit). Bang-bang thermostat, 273±2 K setpoint. |
| LWRHU | 3× (1.1 W each, 42 g Pu-238 each, 126 g total). Provides 33 hr survival to 253 K on power failure. Mounted on rear WEB wall in row. |

## 7.2 Internal Components
| Port controller | Allocates power to tether ports based on MOLE-I docking status. PLC-based. 5 W continuous. |
|---|---|
| Circuit breakers ×6 | Inside WEB at 273 K (solenoid coils need >200 K). Solenoid-actuated mechanical switches. 1000 VDC rated. |
| DC-DC converter | 1000→28 V, ~100 W capacity, 93% efficiency. Powers own heaters, motors, comms. |
| PLC modem | Power-line communications on each tether. Coordinates MOLE-I dump cycles, relays telemetry. |
| Health monitoring hub | Aggregates all sensor channels (drum temps, WEB temp, riser temp, manifold level, bus V/I). |
| RF relay | Backup comms to adjacent nodes and spine. 2–3 W. Antenna on mast top. |

## 7.3 Thermal Isolation Details
The substation WEB uses identical thermal isolation patterns to the MOLE-I WEB:
| Path | Q (W) and Design |
|---|---|
| A: Structural mounts | 2.007 W. 4× PEEK standoffs + vacuum-gap bolts. |
| B: Bus bar transitions | 1.928 W. 2× AWG14 input + 12× AWG20 output, 20 mm Manganin at WEB wall. |
| C: Signal harness | 0.266 W. 49 non-bus conductors (AWG22 + AWG28), 100 mm Manganin. |
| D: Riser pipe | 0.092 W. Ti S-bend + 30 mm PEEK coupler. |
| E: MLI penetrations | 2.000 W. 4 groups × 0.5 W (Gilmore 2002). |
| F: Funnel inlet tubes | 1.587 W. 5× through WEB floor, PEEK sleeved. Without PEEK: 56 W. |
| G: MLI blanket | 0.183 W. 20-layer DAM/Dacron, 2× degrade factor. |
| SUBTOTAL | 8.063 W |
| 30% margin | 2.419 W |
| TOTAL | 10.482 W → heater spec 10.5 W. G_sub = 0.045 W/K. |

# 8. Phase 5 — Water Handling (SEL-SUB-WAT-ASM)
| Collection manifold | SEL-SUB-WAT-001. 316L SS, inside WEB at 273 K. ~5 L capacity. 5× inlet ports from funnel drain pipes + 1× outlet to pump. Welded fittings. Manifold water level sensor (capacitive). |
|---|---|
| Funnel drain pipes | SEL-SUB-WAT-010, qty 5. Ti tubes from docking cradle funnel base through WEB floor. Each has 30 mm PEEK thermal sleeve at WEB wall penetration. Gravity-driven: MOLE-I dumps 50 L, water flows down through funnel into manifold. |
| Transfer pump | SEL-SUB-WAT-020. 10 W peristaltic/diaphragm pump, inside WEB. Lifts water ~3 m from manifold up through riser to branch pipe junction. Flow rate ~0.1 L/min. Intermittent (~1 cycle per 9 hr average). |
| Riser pipe | SEL-SUB-WAT-030. 3 m vertical Ti tube (20 mm OD, 1 mm wall), vacuum-jacketed for thermal isolation. Trace heater at 7 W/m × 3 m = 21 W continuous. Routed up through support mast. Check valve at top prevents 68 bar trunk pressure backflow. |
| Bellows coupling | SEL-SUB-WAT-040. Corrugated 316L SS bellows at riser-to-branch-pipe junction. Accommodates ±20 mm thermal contraction and ±5° angular misalignment. Sealed with metal C-ring. |

# 9. Phase 6 — Communications (SEL-SUB-COM-ASM)
| PLC modem | SEL-SUB-COM-001. Power-line comms on each of 5 tethers. Data rate ~1 kbps. Batch dump coordination, telemetry relay, MOLE-I health status. Inside WEB. |
|---|---|
| RF relay | SEL-SUB-COM-010. UHF backup radio, 2–3 W. Reaches adjacent substations and spine relay. Antenna on mast top. |
| Antenna | SEL-SUB-COM-020. Omnidirectional UHF whip, ~300 mm, mounted on mast top bracket above riser pipe exit. |

# 10. Phase 7 — Support Mast (SEL-SUB-MST-ASM)
| Mast tube | SEL-SUB-MST-001. 3 m aluminium tube, 60 mm OD × 2 mm wall. Sockets into top ring receiver. Pinned after erection. Carries riser pipe internally (concentric). |
|---|---|
| Cross-arm | SEL-SUB-MST-010. T-bracket at mast top. Supports branch pipe junction on one side, antenna on the other. Bellows coupling attaches here. |
| Guy wires | SEL-SUB-MST-020, qty 3. Kevlar lines, 120° spacing, anchored to base plate vertices. Tensioned by turnbuckles. Prevent mast sway during MOLE-I docking impacts. |
| Deployment | Mast stowed horizontal during sled transit. Erected by construction MOLE-I using winch. Hinged at base socket. Guy wires attached after erection. |

# 11. Phase 8 — MLI and Dust Shroud (SEL-SUB-MLI-ASM)
| WEB MLI | SEL-SUB-MLI-001. 20-layer DAM/Dacron blanket, closely conformal to WEB box. Penetration collars (sealed grommets) at: 4× funnel inlet pipes, 1× riser pipe, bus bar transitions, signal harness bundle. 2× degrade factor for dust contamination. |
|---|---|
| Dust shroud | SEL-SUB-MLI-010. 0.5–1.0 mm Ti sheet formed to closely follow WEB MLI contour. Sealed at edges. Prevents regolith dust ingress into MLI layers. Mass: ~0.5–1 kg. |
| Drum MLI | SEL-SUB-MLI-020, qty 5. Wrap around each drum motor + gearbox housing. Smaller blankets, ~5 layers. Secured with Velcro tabs. |
| Riser insulation | SEL-SUB-MLI-030. Vacuum jacket around riser pipe is the primary thermal barrier. External MLI wrap over vacuum jacket for radiation protection. |

# 12. Phase 9 — Harness Assembly (SEL-SUB-HRN-ASM)
63 conductors pass through the WEB wall. All use Manganin transition sections at the wall penetration.
| Conductor Group | Detail |
|---|---|
| Bus bars (14× AWG14) | 2× input + 12× port output. 20 mm Manganin transition at WEB wall. OFHC Cu on both sides. |
| Drum motors (10× AWG22) | 5× motor +/− pairs. 100 mm Manganin transition. |
| Pump + coax (3× AWG22) | Pump motor +/− + RF coax centre conductor. |
| Drum heaters (10× AWG28) | 5× gearbox heater +/− pairs. |
| Funnel heaters (10× AWG28) | 5× funnel lip heater +/− pairs. |
| Riser heater (2× AWG28) | Trace heat +/−. |
| Sensors (14× AWG28) | 5× drum Pt100 +/−, riser Pt100 +/−, pump feedback +/−. |
| TOTAL | 73 conductors (ECN-013: +10 angle encoder leads). Harness thermal load: bus 1.928 W + signal 0.266 W = 2.194 W. |

# 13. Phase 10 — Sled and Deployment Hardware (SEL-SUB-SLD-ASM)
| Sled frame | SEL-SUB-SLD-001. Sacrificial cradle frame. Ti tube construction. Captive roller clips engage spine/branch ground cable. Substation sits in cradle with 4× explosive bolts (release after anchoring). |
|---|---|
| Roller clips | SEL-SUB-SLD-010, qty 4. PEEK-bushed rollers that ride the pre-installed ground cable. 2× for spine transit, 2× for branch transit. |
| Transit sequence | Lowered from rim on trunk cable winch to CLP staging area. Transfers to spine ground cable. At junction, transfers to branch ground cable. Deployed outside-in (farthest position first). |
| Anchoring | After sled reaches position: (1) deploy 4× screw anchors, (2) fire explosive bolts to release sled cradle, (3) sled frame removed by construction MOLE-I. Substation now freestanding on anchors. |

# 14. Assembly-Level Verification
## 14.1 Mass Budget
| System | Mass (kg) |
|---|---|
| Frame + anchors | ~25 kg (base plate ~12, top ring ~6, struts ~4, anchors ~3) |
| Cable drums ×5 | ~60 kg (12 kg each: spool 4 + tether 5 + motor+gearbox 3) |
| Power bus | ~8 kg (bus bars + breakers + connectors) |
| WEB (enclosure + contents) | ~15 kg (box 3 + controller 2 + DC-DC 1 + breakers 3 + manifold 3 + sensors 1 + LWRHU 0.13 + heater 0.2) |
| Water handling (pump + riser) | ~10 kg (pump 2 + riser 5 + bellows 1 + pipes 2) |
| Communications | ~2 kg |
| Support mast | ~8 kg (tube 5 + cross-arm 1 + guy wires 1 + hardware 1) |
| MLI + dust shroud | ~4 kg |
| Harness | ~3 kg |
| Sled + deployment | ~15 kg (removed after deployment) |
| TOTAL (deployed) | ~135 kg (within 140–160 kg allocation) |
| TOTAL (with sled) | ~150 kg (within 200 kg sled allocation) |

## 14.2 Display States
Configure the following SolidWorks Display States for design review:
| Full assembly | All components visible. MLI and shroud semi-transparent. |
|---|---|
| Structural only | Frame, struts, anchors, mast. Everything else suppressed. |
| Thermal | WEB highlighted. MLI visible. Standoffs, Manganin transitions, PEEK sleeves highlighted in colour. Heat paths annotated. |
| Electrical | Bus bars, breakers, harness highlighted. Conductor routing visible. |
| Water flow | Manifold, drain pipes, riser, bellows, pump highlighted. Flow path annotated. |
| Deployment | Sled frame, roller clips, mast stowed. Shows transit configuration. |

## 14.3 Interference Check
Run SolidWorks Interference Detection on SEL-SUB-TOP-ASM. Critical checks:
(1) Drum clearance: verify 5 drums fit within pentagonal frame without interference. (2) Riser pipe vs manifold: verify concentric routing through mast. (3) WEB vs funnel drain pipes: verify 5 pipes clear WEB standoffs. (4) Mast vs guy wires: verify 120° spacing clears all drums. (5) Tether exit vs adjacent drum: verify tethers route outward without crossing. (6) MOLE-I docking envelope: verify 200 mm capture cone clears frame face at all 5 positions.
# 15. Thermal and Power Summary
## 15.1 WEB Heat Loss Budget
Total: 10.482 W (8.063 W paths + 30% margin). G_sub = 0.045 W/K. See §7.3 for path-by-path breakdown. All values from MOLEI_THERMAL v1.3 §S10, verified by MATLAB ODE45 transient simulation.
## 15.2 Power Budget
Substation own demand: 95.5 W continuous (WEB 10.5 + drums 40 + pump 10 + riser 21 + funnels 3 + comms 3 + controller 5 + solenoids 3). Node total: 9,767 W (sub 95.5 + 5×1,934 W MOLE-I tether draw). Eclipse: 420.5 W. Ref: VERIFY v4.5.
## 15.3 LWRHU Performance
3× LWRHU (3.3 W total). T_eq on LWRHU alone: 113 K (too low for indefinite survival). With heater: 273 K nominal. Power failure: 33 hr above 253 K (vs MOLE-I 200 hr — smaller thermal mass). Adding to 4× LWRHU would extend to 44 hr but is not currently specified.
# 16. Document History
| Revision | Description |
|---|---|
| Rev A | Initial release. 10-phase modelling sequence for pentagonal substation. Incorporates MOLEI_THERMAL v1.3 substation audit (WEB 80→10.5 W, 3× LWRHU, 73 conductors (ECN-013), Manganin bus transitions, PEEK funnel sleeves). Compatible with SEL-SW-MOLEI-001 Rev B docking interface. Ref: VERIFY v4.5. |

— End of Document —
ECN-012 Amendments — SolidWorks Sequence (March 2026)
§5 Phase 2 — Cable Drum Assemblies: Drum centre height updated to z = 380 mm (from 280 mm). Update the drum cradle bolt pattern on base plate and top bearing hole on top ring to reflect new vertical position. Drum axis is tangential (parallel to face), not perpendicular. In SolidWorks: rotate the drum sub-assembly 90° about the radial axis so the spool axis runs along the pentagonal face edge.
§8 Phase 5 — Water Handling: Docking cradle funnel position confirmed at z = 160 mm. Update funnel support bracket mates to new height. Note 220 mm vertical clearance between funnel mouth (z = 260 mm top of cone) and drum bottom (z = 280 mm minimum). Interface with MOLE-I: the rover's rear drain nozzle (SEL-MI-PIP-005, per SEL-SW-MOLEI-001 Rev C) exits at ~200 mm above ground at the rear of the chassis. The funnel captures this stream when the rover is reversed into the docking position.
§14.3 Interference Check: Add check — drum bottom clearance to funnel top. Minimum 220 mm required. Verify tether exit roller at z = 380 mm does not interfere with funnel support brackets below.
ECN-013: Angle Encoder SolidWorks Addition (March 2026)
§5 Phase 2 — Cable Drum Assemblies — add per face:
SEL-SUB-DRM-040: 2-axis angle encoder. Model as a small cylindrical housing (~20 mm dia × 15 mm tall) mounted on the tether guide roller axle. Concentric mate with guide roller axis. The encoder body is fixed to the frame bracket; the sensing element reads the roller deflection angles. Material: Ti housing, ceramic sensing element.
SolidWorks: Create DRM-040 as a simple part (revolved cylinder + mounting flange). Mate Concentric + Coincident to guide roller axle at each face. Pattern 5× with the drum pattern.
§12 Harness Assembly: Substation conductor count 63 → 73 (+10 angle encoder leads). Update harness routing drawing to show 2× AWG 28 per face from guide roller to WEB penetration.
§14.1 Mass Budget: Substation deployed mass 135 → 135.5 kg (+0.5 kg encoders).
ECN-013 Rev 3: Construction Tap Spool Part (March 2026)
New part: SEL-SUB-TAP-010 — Spring-Loaded Construction Tether Retraction Spool.
Model as a sealed cylindrical drum: 120 mm dia × 60 mm wide. Ti housing (1 mm wall, revolved shell). Internal clock spring (301 SS, ~0.3 kg). PEEK cable guide slot (3 mm wide) at the drum rim. Bayonet plug (20 mm, 2× L-slot pins) at the free end of the wound tether.
Mounting: Ti saddle clip bonded to branch cable jacket. The spool hangs below the cable at 3 m elevation after mast tilt-up. Mate to branch cable context part using Coincident constraint at each 100 m tap position.
The spool is part of the construction material manifest, not the substation assembly. Include in the branch infrastructure context model for interference checking (verify spool clearance vs support post cross-arm brackets).