<!-- Markdown extract of docs/sources/SEL_SENTINEL_DESIGN_RevA_updated.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
SENTINEL Autonomous Oversight System
Engineering Design Specification — Software Platform + Inspection Rovers
Reference: SEL_SENTINEL_DESIGN Rev A
Source Documents: SEL_ROBOT_FLEET v9 (§9.2), all robot design specs (MOLE-S, MOLE-I, SINTER, ARM-C/D, PROBE, SKIP, DART, HARVEST), SEL-HAB-001 Rev D (ECLSS interface), SEL-ECLSS-002 Rev A (Sabatier/OGA/CDRA), SEL-ISRU-001 Rev D (ISRU process chain), SEL-IZ-001 Rev A (docking ops, propellant farm). Heritage: ISS SPHERES/Astrobee (intra-hab inspection, TRL 9), NASA ISAAC (Integrated System for Autonomous and Adaptive Caretaking, ISS, TRL 7), JPL Mars Relay/TDRSS (deep-space comms relay architecture).
# 1. Overview
SENTINEL is the Selenite Programme's autonomous oversight system. It is two things: (1) a distributed software platform that coordinates, monitors, and manages every robot, subsystem, and process across the entire base, and (2) a fleet of physical inspection rovers that provide mobile sensor access to all surface infrastructure. The software platform is the programme's central nervous system — it runs on redundant servers in the Ops Hub and manages all robot tasking, ECLSS control loops, ISRU process monitoring, power load balancing, crew safety geofencing, Earth communications relay, and anomaly detection. The physical rovers are SENTINEL's mobile eyes and hands for tasks that fixed sensors cannot reach.
SENTINEL's authority model: it MONITORS autonomously, RECOMMENDS actions, and EXECUTES pre-approved routines. It does NOT make irreversible decisions without human approval. All high-consequence actions (crew EVA clearance, PROBE departure, ARM heavy lift, reactor operations) require explicit human go/no-go from either the on-site crew (P4+) or Earth mission control (P2–P3). This is a monitored-autonomy architecture, not full artificial general autonomy.
# 2. System Architecture
## 2.1 Software Platform (Ops Hub Servers)
| Parameter | Specification | Conf |
|---|---|---|
| Hardware | 2× redundant flight-grade server blades in Ops Hub ECLSS rack. Hot standby with automatic failover (<5 s). Rad-tolerant (Shackleton rim GCR environment). ~50 kg total (2× 25 kg including chassis, cooling, power supply). | MED |
| Processing | ~100 GFLOPS per blade (current space-grade GPU/FPGA hybrid). Sufficient for: all robot fleet coordination, computer vision (HARVEST plant health, ARM-D inspection anomaly detection), orbital mechanics (PROBE/SKIP/DART trajectory planning), ECLSS closed-loop control. | MED |
| Storage | 2× 10 TB NVMe SSD (RAID-1 mirror). Stores: all robot workspace grids, plant health databases, inspection imagery archives, ISRU production logs, maintenance histories. ~5 yr data retention at current generation rates. | MED |
| Operating system | Real-time Linux with ARINC 653 partitioning. Safety-critical functions (ECLSS, geofencing, emergency response) in isolated partitions. Robot coordination in separate partition. Data analysis in lowest-priority partition. | HIGH |
| Network | Base-wide Ethernet backbone (Cat6, fibre for long runs). UHF mesh relay for surface robots. X-band for deep-space comms (PROBE). Wired Ethernet within hab modules (HARVEST, ECLSS sensors). | HIGH |
| Power | 120 VDC from hab power bus. ~300 W continuous (both blades). UPS: 30 min battery backup for graceful shutdown during power anomalies. | HIGH |

## 2.2 Physical Inspection Rovers
| Parameter | Specification | Conf |
|---|---|---|
| Count | 2 (P3) → 4 (P6+) | HIGH |
| Dry mass | ~80 kg per unit | MED |
| Dimensions | 1,200 × 800 × 600 mm (L × W × H body, excluding sensor mast) | MED |
| Mobility | 4-wheel rocker-bogie (smaller than MOLE-S — inspection only, no excavation loads). 400 mm dia spring-steel mesh wheels. SmCo BLDC hub motors. | MED |
| Speed | 0.5 m/s. 15° grade. Operational range: entire base campus (hab → ISRU → IZ → Earth LZ → FSP perimeter). | MED |
| Battery | 3,000 Wh Li-ion. ~15 hr continuous at 200 W average. Charges at any MOLE-S-compatible charging station (120 VDC). | MED |
| Sensor mast | Telescoping mast, 800 mm retracted → 2,000 mm extended above chassis. Carries sensor head. | MED |
| Dust mitigation | PTFE labyrinth seals. EDS on optics. SENTINEL rovers are clean-critical — dust on sensors degrades inspection quality. Auto-retreat to charging station for crew sensor cleaning if EDS cannot restore. | HIGH |

## 2.3 Inspection Sensor Suite (Per Rover)
| Sensor | Mass | Function | Resolution |
|---|---|---|---|
| HD visual camera | ~0.5 kg | Surface crack detection, corrosion monitoring, weld inspection, general structural survey. 360° panoramic (motorised pan-tilt head). | 0.1 mm at 1 m working distance. |
| Thermal IR camera | ~0.3 kg | Heat leak detection (hab berm integrity). Cryo line insulation failure (hot spots on VJ pipe). SINTER shell quality verification. Propellant tank thermal mapping. | ±0.1°C. 640 × 480 px. |
| Ultrasonic thickness gauge | ~0.5 kg (contact probe on articulated mini-arm) | Sintered shell thickness measurement. Pressure vessel wall thinning detection. Weld integrity (pulse-echo). Requires physical contact with structure. | ±0.05 mm wall thickness. |
| Catalytic H₂ sensor | ~0.2 kg | LH₂ leak detection at ISRU plant, propellant farm, IZ cryo lines. CRITICAL SAFETY SENSOR — LH₂ is invisible, odourless, and explosive at 4–75% concentration in O₂. Leak terminates all propellant ops immediately. | 10 ppm detection limit. <5 s response. |
| Mass spectrometer (miniature) | ~1 kg | Trace gas analysis in vacuum environment. Detects: H₂ (leak), He (pressurant leak), CH₄ (hab Sabatier vent verification), H₂O (pipeline leak). Sniffs surface outgassing. | 1 ppb for H₂. 10 ppb for other species. |
| XRF spectrometer (contact) | ~0.8 kg | Elemental analysis of sintered structures (verify composition matches design). Landing pad surface degradation assessment (post-launch erosion depth). | Same unit as SURVEY/SKIP/DART XRF. |
| Vibration sensor | ~0.2 kg (contact accelerometer) | Rotating machinery health: electrolysis pumps, cryocooler compressors, CCAA fans. Bearing wear detection. Mounted via magnetic clamp on equipment housing. | 0.01 g resolution. 10 Hz–20 kHz. |

# 3. Functional Domains
SENTINEL manages seven distinct functional domains across the programme. Each domain has defined authority levels: MONITOR (continuous, autonomous), RECOMMEND (flag to crew/Earth), EXECUTE (carry out pre-approved routines), and GATE (hard prerequisite requiring human approval before proceeding).
## 3.1 Robot Fleet Coordination
| Function | Authority | Subsystems Managed |
|---|---|---|
| Task scheduling | EXECUTE | All robots. Assigns daily work plans based on construction schedule, ISRU demand, and maintenance needs. Prioritises: safety-critical (H₂ leak patrol) > production (MOLE-I/SKIP/PROBE) > construction (MOLE-S/SINTER) > inspection. |
| Workspace deconfliction | EXECUTE | Maintains geofence maps for all active robots. Enforces ≥20 m MOLE-S/SINTER separation. 50 m SINTER reactor exclusion. 20 m ARM-C boom exclusion. Crew EVA exclusion zones around all active robots. |
| Fleet health monitoring | MONITOR | Receives telemetry from all robots (power, thermal, drive motor current, sensor status). Tracks maintenance histories. Predicts failures using vibration trend analysis and power draw anomalies. |
| Anomaly escalation | RECOMMEND | If a robot reports an anomaly it cannot self-resolve: SENTINEL alerts crew/Earth with diagnosis and recommended action. Does NOT dispatch repair autonomously (ARM-D ORU swaps are pre-scheduled, not reactive). |
| PROBE/SKIP/DART mission management | GATE | Computes trajectories. Uploads target coordinates. Manages go/no-go gates. All departures require explicit human approval through SENTINEL interface. SENTINEL can HALT a departure autonomously (safety override) but cannot AUTHORISE one. |

## 3.2 ECLSS Control
| Function | Authority | Mechanism |
|---|---|---|
| CO₂ valve manifold | EXECUTE | Adjusts Sabatier/greenhouse CO₂ split based on: crew count, greenhouse CO₂ uptake rate (from HARVEST canopy sensors), and Sabatier reactor demand. Scenario C balanced (59/41 at P5) — adjusts dynamically per Section 6.1 of HAB-001 Rev D. |
| OGA rate control | EXECUTE | Throttles OGA electrolysis rate to match O₂ demand and H₂ supply to Sabatier. Closed-loop: ppO₂ sensor → SENTINEL → OGA power setpoint. |
| N₂ inventory management | MONITOR + RECOMMEND | Tracks N₂ tank pressure, atmospheric ppN₂, leak rate calculation. Alerts crew when resupply threshold reached (reserves < 2 repressurisation events). |
| CDRA health | MONITOR | Zeolite bed pressure drop, CO₂ removal efficiency, valve cycle count. Predicts bed replacement date. |
| Thermal system | EXECUTE | Controls ITCS/ETCS pump speeds, radiator bypass valves, Novec 7200 flow rate. Maintains hab interior 295 ± 2 K. |
| Fire detection + response | EXECUTE (autonomous) | Smoke detector + CO spike + thermal IR anomaly → automatic: isolate affected module (close inter-module hatches), suppress (CO₂ PFE or FWM depending on module), alarm crew. SENTINEL's ONLY fully autonomous irreversible action — fire response cannot wait for human approval. |

## 3.3 ISRU Process Monitoring
| Function | Authority | Mechanism |
|---|---|---|
| Pipeline integrity | MONITOR | Flow rate + pressure + temperature sensors along 8.5 km pipeline. Leak detection: pressure drop >0.5% over 10 min → alarm. Section isolation valves (every 500 m) auto-close on confirmed leak. |
| Electrolysis health | MONITOR + RECOMMEND | Per-stack voltage, current, temperature, membrane impedance. Tracks degradation curve. Predicts membrane replacement date. Recommends switching to spare stack when active stack reaches 80% efficiency. |
| Water quality gate | GATE | Conductivity >5 µS/cm or H₂S >0.05 ppm at electrolyser input → automatic divert to waste. Electrolyser does NOT receive unpurified water — SENTINEL enforces this as a hard interlock. |
| Cryo tank management | EXECUTE | ZBO cryocooler setpoints. Tank fill level monitoring. Propellant allocation: PROBE vs SKIP vs DART vs reserve. Eclipse-mode: reduce ISRU throughput to match reduced power. |
| Production accounting | MONITOR | Tracks daily/monthly/annual: water extracted, propellant produced, propellant consumed, surplus/deficit. Reports to programme economics model. Flags if production rate drops below demand curve. |

## 3.4 Power Management
| Function | Authority | Mechanism |
|---|---|---|
| Load balancing | EXECUTE | Distributes power across base zones: hab, ISRU, IZ, PSR fleet. Priority: (1) hab life support, (2) PSR pipeline heating (freeze = catastrophic), (3) ISRU electrolysis, (4) IZ, (5) construction. During eclipse or power shortfall: sheds loads in reverse priority order. |
| Eclipse management | EXECUTE | 43 hr max eclipse. SENTINEL pre-positions all systems: MOLE-S to standby, SINTER reactor to hot standby (self-powered), SKIP ground hold, ISRU to reduced throughput, hab to eclipse thermal mode. FSP reactors to full output. Battery SOC monitoring with 10% reserve hard floor. |
| Solar array tracking | EXECUTE | Manages sun-tracking actuators on GaAs array field. Monitors per-panel output. Flags degraded panels for crew inspection. |
| FSP interface | MONITOR + EXECUTE | Monitors 4–5 FSP reactor status: power output, coolant temperature, control drum position. Does NOT control reactor nuclear parameters directly — each FSP has its own autonomous reactor controller. SENTINEL sets the power demand setpoint. |

## 3.5 Structural Inspection (Physical Rovers)
| Function | Authority | Mechanism |
|---|---|---|
| Pre-crew structural clearance | GATE | Before crew arrival (P4 gate): SENTINEL rovers perform full sweep of all sintered structures (hab berms, IZ collars, roads, pads). Ultrasonic thickness on all sintered shells. Thermal survey of berm integrity (heat leak = void in fill). Visual crack detection on all structural joints. Report: PASS/FAIL per structure. NO crew arrival until all structures PASS. This is a HARD programme gate. |
| Periodic structural survey | EXECUTE | Quarterly full survey of all sintered structures. Annual deep survey with ultrasonic + vibration. Post-event surveys after: any landing within 500 m, seismic event (if detectable), eclipse thermal cycling (cumulative fatigue check). |
| H₂ leak patrol | EXECUTE | Daily patrol route: ISRU plant → cryo transfer lines → propellant farm → IZ collar refuelling ports → SKIP/DART pad umbilicals. H₂ catalytic sensor + mass spectrometer sniffing at every cryo joint and valve. ANY detection >100 ppm → immediate halt of all propellant operations + crew alert. |
| Landing pad assessment | EXECUTE | Post-landing survey of each pad within 4 hr: surface erosion depth measurement (ultrasonic), ejecta damage to berms (visual + thermal), structural integrity of sintered surface (crack detection). Reports pad serviceability for next landing. |
| Pipeline surface inspection | EXECUTE | Monthly patrol of accessible pipeline sections (rim + surface run to ISRU). Visual + thermal of MLI condition, support pylon integrity, trace heater function (thermal IR shows cold spots = heater failure). |

## 3.6 Crew Safety
| Function | Authority | Mechanism |
|---|---|---|
| Geofence enforcement | EXECUTE | Real-time tracking of all crew EVA positions (via suit UWB transponder). Enforces exclusion zones: 50 m around active SINTER reactor, 20 m around ARM-C boom operations, 100 m from active PROBE/SKIP pads during departure countdown. Audio + visual warning in suit HUD at 120% exclusion radius. Hard suit lockout at 100% radius (suit navigation refuses to path through exclusion zone). |
| Atmosphere monitoring | EXECUTE | Continuous: ppO₂, ppCO₂, ppN₂, trace contaminants (CO, NH₃, formaldehyde, H₂S). Per-module. If any parameter exceeds SMAC limits: alarm + recommended action (module isolation, PBA donning, medication if toxic exposure). |
| Radiation monitoring | MONITOR + RECOMMEND | Per-module dosimeter network. Cumulative dose tracking per crew member. Alert at 80% of annual limit (500 mSv occupational). SPE (Solar Particle Event) warning: if radiation spike detected, SENTINEL alerts crew to shelter in hab (berms provide shielding). HAB is the SPE shelter — crew must be inside within 30 min of warning. |
| Medical telemetry | MONITOR | Crew health monitors (HR, SpO₂, activity level) during EVA. Flags anomalies to crew medical officer. Does NOT diagnose — flags for human medical assessment. |
| Emergency coordination | EXECUTE (autonomous) | Fire, depress, medical emergency response sequences pre-programmed. SENTINEL executes: hatch closure, atmosphere management, crew notification, Earth alert. These are the ONLY fully autonomous irreversible actions — emergency response cannot wait. |

## 3.7 Earth Communications Relay
| Function | Authority | Mechanism |
|---|---|---|
| Hab ↔ Earth | EXECUTE | 2× X-band transponders in Ops Hub (redundant). 2 m HGA on hab roof (above berm, motorised tracking). ~50 kbps downlink to DSN 34 m stations. Voice, video, telemetry, medical data. |
| PROBE deep-space relay | EXECUTE | SENTINEL relays PROBE telemetry from DSN to Ops Hub crew display. Crew/Earth send commands to PROBE via SENTINEL → DSN → PROBE X-band. SENTINEL manages DSN contact scheduling. |
| Autonomous ops (no-contact periods) | EXECUTE | If Earth comms lost >24 hr: SENTINEL continues all autonomous functions. All production continues. All safety monitoring continues. Only GATE functions (departure approvals, structural clearance) are suspended until comms restored. Crew on-site (P4+) can approve gates locally. |
| Data prioritisation | EXECUTE | Limited bandwidth (~50 kbps). SENTINEL prioritises: (1) emergency alerts, (2) crew health/safety, (3) production summaries, (4) engineering telemetry, (5) science data (HARVEST plant data, XRF readings), (6) imagery (lowest priority, sent during idle periods). |

# 4. Inspection Rover Operations
## 4.1 Patrol Routes
| Route | Frequency | Duration | Priority |
|---|---|---|---|
| H₂ leak patrol (ISRU → farm → IZ cryo) | Daily | ~4 hr (6 km round-trip at 0.5 m/s + 30 min sensor dwell per inspection point) | CRITICAL — safety. |
| Hab berm thermal survey | Weekly | ~2 hr (circumnavigation of hab complex) | HIGH — structural. |
| IZ collar + gantry visual | Weekly | ~3 hr (all 8 collar positions + gantry columns) | HIGH — operational. |
| Landing pad post-landing | Per event | ~1 hr per pad | HIGH — operational. |
| Pipeline surface section | Monthly | ~4 hr (200 m surface run + connections) | MEDIUM — maintenance. |
| Road surface condition | Monthly | ~6 hr (full 3 km road network) | LOW — maintenance. |
| Earth LZ survey | Per event | ~2 hr per pad | MEDIUM — post-landing. |

## 4.2 Rover Fleet Allocation
| Phase | Rovers | Assignment |
|---|---|---|
| P3 (Y4–7) | 2 | Rover-1: construction zone (hab + ISRU). Rover-2: IZ construction zone. Both rovers perform pre-crew structural clearance at P3/P4 boundary. |
| P4 (Y7–9) | 2 | Rover-1: hab + ISRU daily patrol. Rover-2: IZ + propellant farm patrol (H₂ leak route). Alternating weekly: deep structural survey. |
| P5–P6 (Y9–15) | 3 | Rover-1: hab. Rover-2: ISRU + propellant farm (dedicated H₂ patrol). Rover-3: IZ + Earth LZ. |
| P7+ (Y20+) | 4 | Rover-1: hab. Rover-2: ISRU. Rover-3: IZ. Rover-4: Earth LZ + roads + expansion construction. |

## 4.3 Anomaly Response Workflow
When SENTINEL (software platform or physical rover) detects an anomaly, the following 6-step workflow executes. The workflow applies to all anomaly types (structural, thermal, chemical, operational). Authority level escalates automatically based on severity classification.
Step 1 — Detect. Sensor reading exceeds threshold or trend analysis predicts threshold breach within 24 hr. Sources: rover inspection sensors, fixed environmental sensors, robot fleet telemetry, ECLSS monitors, ISRU process instruments. Detection is autonomous and continuous.
Step 2 — Classify. SENTINEL assigns severity: (a) ADVISORY — parameter drifting but within limits (e.g., electrolysis membrane impedance rising). Log only. (b) CAUTION — parameter at limit or single-sensor anomaly (e.g., one temperature sensor reading high). Cross-check with adjacent sensors. (c) WARNING — confirmed anomaly affecting operations (e.g., H₂ detected at >10 ppm). Immediate response required. (d) EMERGENCY — immediate life-safety threat (fire, depress, explosive H₂ concentration). Autonomous response, no human approval wait.
Step 3 — Isolate. For WARNING and EMERGENCY: SENTINEL automatically isolates the affected zone. Pipeline section valve closure (≤30 s). Module hatch closure (≤10 s for EMERGENCY). Robot geofence expansion around anomaly location. Power circuit breaker trip if electrical fault. Isolation is autonomous — SENTINEL does not wait for human approval to contain a spreading hazard.
Step 4 — Diagnose + recommend. SENTINEL correlates the anomaly with known failure signatures (lookup table of ~200 pre-programmed fault patterns covering all subsystems). Generates a diagnosis (probable cause, affected components, estimated severity trend) and recommended corrective action. For ADVISORY/CAUTION: recommendation displayed on crew SENTINEL interface and downlinked to Earth. For WARNING: recommendation + isolation status reported with URGENT flag. For EMERGENCY: response already executing; report is post-facto notification.
Step 5 — Respond. Crew or Earth mission control reviews diagnosis and approves, modifies, or rejects recommended action. For ADVISORY: no action required (monitoring continues). For CAUTION: crew schedules inspection (rover dispatch or next EVA). For WARNING: crew executes corrective action within 24 hr (e.g., ORU swap, valve replacement, cable repair). For EMERGENCY: response already complete; crew assesses damage and plans recovery.
Step 6 — Verify + close. After corrective action: SENTINEL re-inspects (rover dispatch or sensor re-read). Confirms anomaly resolved. Closes anomaly ticket in maintenance database. If anomaly persists: escalate to next severity level and repeat from Step 3. All anomaly records are permanently logged (timestamp, classification, diagnosis, action taken, resolution status) for trend analysis and Earth engineering review.
# 5. Authority Model Summary
| Authority Level | Description | Examples | Human Override |
|---|---|---|---|
| MONITOR | Continuous autonomous data collection and trend analysis. No system state changes. | Fleet telemetry, ECLSS atmospheric readings, ISRU production logs, radiation dosimetry. | None needed — passive observation. |
| RECOMMEND | SENTINEL flags an anomaly and suggests a response. Does NOT execute until human approves. | Electrolysis membrane replacement timing. MOLE-I fleet rebalancing. Nutrient solution adjustment exceeding ±20%. | Crew or Earth reviews recommendation, approves/modifies/rejects. |
| EXECUTE | SENTINEL carries out pre-approved routine actions autonomously. | ECLSS thermal setpoints. Power load balancing. Eclipse management. Robot task scheduling. Geofence enforcement. Inspection patrol routes. | Crew can override any EXECUTE function from Ops Hub interface. |
| GATE | Hard prerequisite requiring explicit human approval before proceeding. SENTINEL CANNOT bypass. | Pre-crew structural clearance. PROBE/SKIP/DART departure. ARM-C heavy lift. SINTER reactor restart. Crew EVA authorisation. | MANDATORY human approval. No timeout — gate remains closed until approved. |
| EMERGENCY | Fully autonomous irreversible action. ONLY for immediate life-safety threats. | Fire response (hatch closure + suppression). Rapid depressurisation response (auto-hatch closure). H₂ leak detected at explosive concentration (all propellant ops halt). | Crew can override post-facto but SENTINEL acts first. This is the ONLY authority level where SENTINEL does not wait for human approval. |

⚠ SENTINEL's EMERGENCY authority is deliberately narrow: fire, depressurisation, and explosive-concentration H₂ detection. These are the ONLY situations where SENTINEL takes irreversible action without human approval. Everything else — including stopping a PROBE launch, halting construction, or changing ECLSS setpoints — goes through RECOMMEND or GATE. This is a design choice: the programme values human oversight over response speed for all non-immediate-life-safety situations.

# 6. Hardware — Ops Hub Installation
| Component | Location | Mass | Power | Notes |
|---|---|---|---|---|
| Server blades (×2) | ECLSS rack, Ops Hub E wall (adjacent to ECLSS-D rack). 4U rack space. | ~50 kg | ~300 W | Hot standby failover. UPS: 500 Wh (30 min). |
| Crew display | Ops Hub central wall (between Port 1/Port 2 corridor). 2× 27-inch touchscreen displays + keyboard/trackball. | ~15 kg | ~80 W | Primary crew interface. Shows: base status overview, robot fleet map, ECLSS dashboard, alarm panel, comm console. |
| UHF base relay | Antenna mast on Ops Hub berm crown (above radiator array). 50 W transmitter. | ~10 kg (mast + antenna + transceiver) | ~50 W | Relays to/from all surface robots. 360° coverage. Range: 20+ km line-of-sight. |
| X-band Earth link | 2 m HGA on motorised mount. Ops Hub roof (above berm). 20 W TWTA. | ~40 kg (dish + mount + TWTA + feed) | ~100 W TX / 20 W RX | DSN compatible. ~50 kbps downlink at lunar distance. |
| Network switches | 1× per module (Ops, H1, H2, F1). Backbone fibre. | ~2 kg per switch | ~10 W each | Wired infrastructure. No wireless dependency for critical functions. |
| Environmental sensors | Per-module: ppO₂, ppCO₂, ppN₂, temperature, humidity, smoke, CO, radiation. ~15 sensors per module. | ~0.5 kg per sensor | ~1 W each | ~60 sensors total across 4 P4 modules. Data aggregated to SENTINEL server. |
| TOTAL (Ops Hub) |  | ~130 kg | ~600 W | Excludes inspection rovers (separate manifesting). |

# 7. Scalability
| Phase | Software Capability | Hardware |
|---|---|---|
| P2–P3 (pre-crew) | Full autonomous base management. Robot fleet coordination. Construction monitoring. Pre-crew structural clearance. All GATE functions held by Earth mission control. | 2× server blades + 2× inspection rovers + UHF relay + X-band link. No crew displays (installed but unpowered until P4). |
| P4 (crew arrival) | Crew interface activated. GATE authority transfers from Earth to local crew (with Earth backup). HARVEST integration. Expanded ECLSS control loops. | Crew displays powered. HARVEST data link active. Same servers. |
| P5–P6 | PROBE/SKIP fleet management at scale. IZ docking scheduling. Multi-module ECLSS management. | 3rd inspection rover. Software updates for fleet scaling. |
| P7+ | Full 30-PROBE + 8-SKIP + DART management. 170 MOLE-I coordination. 12-crew life support. Power management across 4–5 FSP + 7,300 m² solar. | 4th inspection rover. Server upgrade if processing headroom <20% (hot-swap blade replacement). Potential edge compute nodes at ISRU and IZ to reduce UHF bandwidth demands. |

# 8. Failure Modes
| Failure Mode | Response | Impact |
|---|---|---|
| Primary server failure | Hot standby takes over in <5 s. All functions continue. Failed blade flagged for crew replacement (ORU, ~1 hr). | NONE — transparent failover. |
| Both servers fail | Base continues on pre-programmed robot schedules for ~24 hr (all robots have local autonomy for current task). ECLSS reverts to local PID controllers (pre-SENTINEL heritage). Crew manages manually from local module controls. Server restoration is highest-priority crew task. | HIGH — crew workload surge. All GATE functions suspended. |
| UHF relay failure | Surface robots switch to direct UHF to Ops Hub (reduced range, some robots may lose contact). Inspection rovers return to hab vicinity. PROBE/SKIP deep-field comms via X-band relay if available. | MEDIUM — reduced robot coverage beyond ~5 km. |
| X-band Earth link failure | Base continues autonomously. All GATE functions transfer to local crew authority. No Earth oversight until restored. Crew has full local authority under emergency comms protocol. | MEDIUM — autonomy increases. Crew has all tools needed for independent operation. |
| Inspection rover loss | Remaining rovers absorb patrol routes (increased cycle time). At minimum 2 rovers: H₂ leak patrol maintained (critical), structural survey frequency reduced. | LOW — degraded inspection coverage. |
| Environmental sensor failure | Cross-module sensor redundancy (~15 per module). Single sensor failure: SENTINEL interpolates from neighbours. >3 sensor failures in same module: crew alert for manual portable sensor verification. | LOW — redundant sensors. |

# 9. Document History
| Rev | Description |
|---|---|
| Rev A | Initial release. SENTINEL autonomous oversight system. Dual architecture: distributed software platform (2× redundant server blades, 130 kg Ops Hub installation, 600 W) + physical inspection rovers (4× 80 kg 4-wheel rovers with 7-sensor suite including H₂ leak detection). Seven functional domains: robot fleet coordination, ECLSS control, ISRU monitoring, power management, structural inspection, crew safety, Earth comms relay. Five-tier authority model: MONITOR → RECOMMEND → EXECUTE → GATE → EMERGENCY. Pre-crew structural clearance as hard programme gate. Fire/depress/H₂ leak as only autonomous irreversible actions. 2 rovers (P3) → 4 (P7+). March 2026. |

— End of Document —