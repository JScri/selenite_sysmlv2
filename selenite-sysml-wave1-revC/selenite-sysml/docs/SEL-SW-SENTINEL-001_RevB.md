<!-- Markdown extract of docs/sources/SEL-SW-SENTINEL-001_RevB.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
SENTINEL Autonomous Oversight System
Software Architecture Specification
Reference: SEL-SW-SENTINEL-001 Rev B
Source Documents: SEL_SENTINEL_DESIGN Rev B (functional requirements, authority model, anomaly workflow, PKT remote supervision architecture), ECN-019 Rev C (PKT autonomous architecture), SEL-ECLSS-002 Rev A (ECLSS control loops, setpoints), SEL-HAB-001 Rev D (module sensor network), SEL-IZ-001 Rev B (docking operations, propellant farm), SEL-POWER-001 Rev A (eclipse management, FSP interface), SEL-PROC-PKT-001 Rev B (PKT processing facility), all robot design specifications (fleet interface requirements). Heritage: NASA ISAAC (ISS autonomous caretaking, TRL 7), cFS (core Flight System, GSFC), ROS 2 (robot middleware), ARINC 653 (time-space partitioned RTOS).
# 1. Scope and Purpose
This document specifies the software architecture for the SENTINEL autonomous oversight system. It covers: operating system and partitioning (§2), process architecture and inter-process communications (§3), database schema (§4), control loop algorithms for each functional domain (§5–11), fleet scheduling and deconfliction (§12), communications protocol stack (§13), fault management system (§14), PKT distributed software architecture (§15), and data management and Earth downlink prioritisation (§16). It does NOT cover the physical inspection rover hardware (see SEL-CAD-SE-001 Rev A) or the functional requirements already defined in SEL_SENTINEL_DESIGN Rev B.
The architecture is designed for: (a) deterministic real-time response for safety-critical functions (ECLSS, fire, depress, H₂ — all within <100 ms), (b) graceful degradation under partial failure (single server loss, sensor dropout, comms blackout), (c) scalability from P2 (no crew, 2 rovers, ~20 robots) to P7+ (20 crew, 4+ SPA rovers, ~220 SPA robots) and to PKT scale (zero crew, ~4,167 rovers, ~1.5M haulers, ~100 distributed processor nodes), and (d) transparent operation — every decision SENTINEL makes is logged, traceable, and human-reviewable.
# 2. Operating System and Partitioning
## 2.1 ARINC 653 RTOS Architecture
| Parameter | Specification |
|---|---|
| RTOS | Real-time Linux kernel with ARINC 653 time-space partitioning layer (VxWorks 653 heritage). Provides deterministic scheduling for safety-critical partitions while allowing POSIX-standard processes in non-critical partitions. |
| Partition scheduling | Fixed major frame: 100 ms. Each partition receives a guaranteed time window within the 100 ms frame. Safety-critical partitions execute first; housekeeping last. |
| Memory isolation | Each partition has a dedicated memory region. No shared memory between partitions — all inter-partition communication via ARINC 653 message ports (queuing or sampling). A fault in one partition CANNOT corrupt another. |
| Watchdog | Hardware watchdog timer: 500 ms. If the safety-critical partition misses a heartbeat, hardware watchdog triggers automatic failover to standby server. No software dependency. |
| Boot sequence | Cold boot to full operations: <60 s. Hot standby server synchronises state every 1 s via heartbeat. Failover: <5 s (hardware watchdog timeout + state load from last sync). |

## 2.2 Partition Map
| Partition | Priority | Time Slice | Memory | Function |
|---|---|---|---|---|
| P0: Emergency | HIGHEST | 10 ms / 100 ms frame | 64 MB | Fire detection, depressurisation response, H₂ explosive concentration response. Hard real-time <100 ms response. Reads: smoke, CO, pressure, H₂ sensors. Outputs: hatch close, suppression fire, vent valve, alarm. ONLY partition with direct hardware I/O to safety-critical actuators. |
| P1: ECLSS | HIGH | 15 ms / 100 ms | 128 MB | CO₂ valve control, OGA rate, CDRA monitoring, thermal pump control, atmosphere composition. Closed-loop PID controllers. 1 Hz update rate. |
| P2: Power | HIGH | 10 ms / 100 ms | 64 MB | Load balancing, eclipse management, FSP interface, solar array tracking. 1 Hz update rate. |
| P3: Fleet | MEDIUM | 20 ms / 100 ms | 256 MB | Robot task scheduling, workspace deconfliction, geofencing, telemetry ingest from all ~220 robots. 0.1 Hz scheduling update; 1 Hz telemetry ingest. |
| P4: Inspection | MEDIUM | 15 ms / 100 ms | 128 MB | Rover patrol management, anomaly detection algorithms (vision, thermal, spectral), structural health database queries. |
| P5: ISRU | MEDIUM | 10 ms / 100 ms | 128 MB | Pipeline monitoring, electrolysis health tracking, water quality gate, cryo tank management, production accounting. |
| P6: Comms | LOW | 10 ms / 100 ms | 64 MB | UHF mesh management, X-band scheduling, PROBE deep-space relay, data prioritisation queue. |
| P7: Housekeeping | LOWEST | 10 ms / 100 ms | 64 MB | Logging, database maintenance, trend analysis, Earth downlink packaging, non-urgent data processing. |
| TOTAL | — | 100 ms / 100 ms | 896 MB | Full frame utilised. ~100 MB headroom on 1 GB server RAM. |

⚠ P0 (Emergency) has EXCLUSIVE access to safety-critical actuator hardware: module hatch servo drives, fire suppression valves, H₂ vent valves, and alarm sounders. No other partition can drive these actuators. P0 also has read access to all environmental sensors. If P0 detects a life-safety threshold breach, it acts IMMEDIATELY — it does not wait for P1–P7 to process. This is the architectural guarantee behind SENTINEL's <100 ms emergency response.

# 3. Process Architecture and IPC
## 3.1 Inter-Partition Communication
| Mechanism | Use | Latency | Notes |
|---|---|---|---|
| ARINC 653 Sampling Port | Continuous state sharing (sensor readings, setpoints, status flags). Last-value-wins. Non-blocking read. | <1 ms | P0 publishes sensor state; all partitions read. P3 publishes fleet state; P4/P5 read. |
| ARINC 653 Queuing Port | Command/response messages (task assignments, anomaly tickets, gate requests). FIFO, guaranteed delivery. | <5 ms | P3 → robot command queue. P4 → anomaly ticket queue to P7 (logging). |
| Shared Database (via P7) | Persistent data (workspace grid, maintenance history, plant health, production logs). All writes go through P7 Housekeeping; readers access a read-only memory-mapped snapshot updated every 1 s. | 1 s (snapshot refresh) | Prevents database lock contention. P7 is the sole writer. |
| Heartbeat Bus | Server-to-server state sync (hot standby). 1 Hz. Contains: partition health flags, critical setpoints, last sensor readings, fleet state hash. | 1 s | Over dedicated Ethernet link (not shared with base network). If heartbeat missed ×3 (3 s): standby promotes itself. |

## 3.2 External Communications
| Interface | Protocol | Bandwidth | Latency |
|---|---|---|---|
| Robot fleet (surface, UHF) | Custom TDMA over UHF mesh. 128 time slots per 10 s frame. Each robot gets 1 slot (78 ms). Robots transmit: 200-byte telemetry packet + any pending data. SENTINEL transmits: task commands in assigned downlink slots. | ~20 kbps aggregate (128 × 200 B / 10 s) | 78 ms per slot. Worst case: 10 s for a new command to reach a robot. |
| Robot fleet (PSR, tether PLC) | Power-line communication on 1,000 VDC tether. 9,600 baud per tether. MOLE-I/substation only. | ~1 kbps per tether | <100 ms per message. |
| Rovers (UHF direct) | Same TDMA frame as fleet, but rovers have priority slots (first 4 slots in each frame). Higher bandwidth: 500-byte packets. | ~2 kbps per rover | <1 s for inspection image transmission (compressed JPEG, ~50 KB, ~25 s per image). |
| Hab modules (Ethernet) | TCP/IP over Cat6/fibre. 100 Mbps backbone. | 100 Mbps | <1 ms LAN. |
| Earth (X-band) | CCSDS TM/TC over X-band. ~50 kbps downlink, ~5 kbps uplink. DSN scheduling windows. | 50 kbps down / 5 kbps up | ~1.3 s one-way (Earth–Moon). Effective: 2.6 s round-trip. |
| PROBE deep-space | X-band relay. SENTINEL receives PROBE telemetry from DSN, displays on crew interface. Crew/Earth commands routed to PROBE via same link. | ~5 kbps | 4–40 min one-way (depends on PROBE distance from Earth). |

# 4. Database Schema
All persistent data is stored on the RAID-1 mirrored 10 TB NVMe SSDs. P7 (Housekeeping) is the sole write process. All other partitions read from a memory-mapped snapshot updated every 1 s. Schema is relational (SQLite — flight-proven, zero-config, POSIX-compatible). Total database size at P7+: ~2–3 TB (dominated by inspection imagery archive).
| Table | Key Fields | Update Rate | Retention | Size (P7+ est.) |
|---|---|---|---|---|
| robot_fleet | robot_id, type, position_xyz, state, battery_pct, task_id, last_telemetry_ts | 1 Hz per robot (220 robots × 1 Hz = 220 rows/s) | Current state only (overwrite). History: 90-day rolling log. | ~5 GB (90-day log) |
| workspace_grid | cell_x, cell_y, zone (hab/isru/iz/psr/road), status (excavated/filled/compacted/sintered/empty), robot_assigned, last_updated | On change (~100 updates/day) | Permanent. Full base spatial model. | ~500 MB |
| anomaly_log | anomaly_id, timestamp, severity, source_sensor, diagnosis_code, action_taken, resolved_ts, resolution_notes | On event (~5–20 per day) | Permanent. Never deleted. | ~2 GB (10-year accumulation) |
| maintenance_history | robot_id, component_id, event_type (replace/inspect/calibrate), timestamp, next_due_ts | On event (~10 per day) | Permanent. | ~500 MB |
| eclss_timeseries | module_id, sensor_id, value, timestamp | 1 Hz per sensor (~60 sensors × 1 Hz = 60 rows/s) | 90-day rolling at full resolution. Downsampled 1-min averages: permanent. | ~20 GB (90-day) + ~5 GB (permanent averages) |
| isru_production | date, water_extracted_kg, propellant_produced_kg, propellant_consumed_kg, surplus_kg, fleet_active_count | Daily summary | Permanent. | ~10 MB |
| plant_health | plant_id, module, tier, channel, species, planted_date, growth_metrics_json, health_status, last_scan_ts | Per scan (~900 plants × 2 scans/day = 1,800 rows/day) | Current crop cycle. Archived per harvest. | ~2 GB (imagery-heavy) |
| inspection_archive | image_id, rover_id, location_xyz, sensor_type, timestamp, image_blob_path, analysis_result_json | Per inspection (~50 images/day) | Permanent. Images stored as JPEG files on SSD. DB stores metadata + file paths. | ~1.5 TB (10-year, ~50 images/day × 10 KB avg × 3,650 days) |
| gate_log | gate_id, gate_type, requester, status (pending/approved/rejected), approver, timestamp | On event (~2–5 per day) | Permanent. | ~50 MB |
| power_log | timestamp, zone, demand_kw, supply_kw, solar_kw, fsp_kw, battery_kwh, eclipse_state | 1 Hz | 90-day rolling. Downsampled permanent. | ~10 GB |

# 5. Domain: Emergency Response (Partition P0)
| Trigger | Sensor Source | Threshold | Response (autonomous, <100 ms) | Recovery (crew-directed) |
|---|---|---|---|---|
| Fire | Smoke detector + CO sensor + thermal IR (2-of-3 voting) | Smoke: any detection. CO >35 ppm. Thermal: >100°C localised. | Close inter-module hatch (affected module). Activate halon/N₂ suppressant. Sound alarm. Cut HVAC to prevent spread. Alert crew + Earth. | Crew assesses damage. Re-entry after CO <5 ppm and thermal clear. SENTINEL re-opens HVAC on crew command. |
| Rapid depressurisation | Pressure sensor (differential between modules) | ΔP >0.5 kPa/min (expected leak rate: ~0 in intact module). | Close all inter-module hatches. Sound alarm. Crew emergency egress protocol to unaffected module. SENTINEL logs pressure decay rate per module to identify breach location. | Crew patches breach (internal repair kit). SENTINEL monitors pressure recovery. Re-opens hatches on crew command after pressure stable >1 hr. |
| H₂ explosive concentration | Catalytic H₂ sensor (fixed sensors at ISRU, propellant farm, IZ cryo lines) | H₂ >40,000 ppm (4% LEL = lower explosive limit). | Immediate power cut to affected zone (prevents ignition source). Vent valve open (if outdoor: vent to vacuum; if indoor: N₂ purge). Alert crew. Geofence expansion to 200 m around source. | Crew identifies leak source. Valve isolation. SENTINEL monitors H₂ decay. Zone re-powered on crew command after H₂ <100 ppm. |

★ The 2-of-3 voting logic for fire is critical: a single smoke detector false alarm does NOT trigger suppression. Only when 2 of 3 independent sensor types (smoke, CO, thermal) agree does P0 execute the fire response. This prevents nuisance alarms from dust on a smoke detector or a brief thermal anomaly from cooking. H₂ does not use voting — a single catalytic sensor reading >4% LEL triggers immediate response because the consequence of missing a real H₂ leak is catastrophic.
# 6. Domain: ECLSS Control (Partition P1)
## 6.1 CO₂ Valve Manifold Controller
| Parameter | Value |
|---|---|
| Controlled variable | ppCO₂ in hab modules: target 400 ppm (0.3 mmHg). Greenhouse modules: target 1,200–2,000 ppm (enriched). |
| Actuators | 3-way proportional valve manifold: CDRA output → (a) Sabatier, (b) greenhouse, (c) overboard vent. Valve position: 0–100% per branch. |
| Control law | Dual PID: PID_hab controls hab ppCO₂ by adjusting CDRA adsorption cycle rate. PID_greenhouse controls greenhouse ppCO₂ by adjusting CO₂ feed valve position. Decoupled: hab PID runs independently of greenhouse PID. |
| PID gains (hab) | Kp = 0.5 %/ppm, Ki = 0.01 %/(ppm·s), Kd = 0.1 %·s/ppm. Tuned for: <50 ppm overshoot, <300 s settling time after crew count change (e.g., 4→6 crew during shift overlap). |
| Setpoint source | Crew count (from suit check-in/out log) × 1.04 kg CO₂/person/day. HARVEST canopy CO₂ uptake rate (from HARVEST sensor probe readings, ~0.8 kg/day per module at full production). |
| Update rate | 1 Hz. Valve position command sent to valve actuator every 1 s. |
| Fail-safe | If ppCO₂ sensor fails: SENTINEL holds current valve position (last known good). If ppCO₂ >5,000 ppm (2× alarm threshold): alert crew. If ppCO₂ >25,000 ppm (IDLH): P0 Emergency triggers module isolation. |

## 6.2 OGA Rate Controller
| Parameter | Value |
|---|---|
| Controlled variable | ppO₂ in hab modules: target 21.0 kPa (within 19.5–23.0 kPa range per NASA STD-3001). |
| Actuator | OGA electrolysis water feed rate: 0–3.85 kg/hr (proportional to O₂ production rate). |
| Control law | PID on ppO₂. Kp = 2.0 %/kPa, Ki = 0.05 %/(kPa·s), Kd = 0.5 %·s/kPa. Settling time: <600 s. |
| Feedforward | Crew count change triggers immediate step increase in OGA rate (predictive: each crew member consumes 0.84 kg O₂/day). PID trims residual error. |
| H₂ disposition | OGA produces 0.43 kg H₂/day. All H₂ routed to Sabatier. SENTINEL monitors H₂ flow meter at OGA outlet — if flow <95% of expected: alarm (potential H₂ leak, which is explosive). |
| Fail-safe | If ppO₂ sensor fails: SENTINEL switches to backup sensor (3× per module). If all fail: hold OGA at last known good rate + alert crew. If ppO₂ <16 kPa (hypoxia threshold): P0 Emergency alarm. |

## 6.3 Thermal System Controller
| Parameter | Value |
|---|---|
| Controlled variable | Hab air temperature: 22°C setpoint (18.3–26.7°C range). Module wall temperature: >10°C (prevents condensation). |
| Actuators | ITCS pump speed (0–100%), ETCS radiator bypass valve (0–100%), Novec 7200 flow rate. |
| Control law | Cascade PID: outer loop on air temperature (slow, 60 s time constant), inner loop on coolant flow rate (fast, 5 s time constant). Radiator bypass: bang-bang with 2°C deadband (open >24°C, close <22°C). |
| Eclipse mode | During 43-hr eclipse: ETCS radiator fully bypassed (no heat rejection needed — hab retains heat). ITCS continues circulating to prevent cold spots. If wall temp <10°C: enable trace heaters on cold-side wall (500 W total). |

# 7. Domain: ISRU Process Monitoring (Partition P5)
| Function | Algorithm | Thresholds | Response |
|---|---|---|---|
| Water quality gate | Continuous: conductivity sensor + H₂S sensor at electrolyser input. If either exceeds threshold → divert to waste tank. | Conductivity >5 µS/cm OR H₂S >0.05 ppm. | Automatic divert valve. Electrolyser input shutoff. Alert crew. Resume when water quality clears for >10 min continuous. |
| Electrolysis stack health | Per-stack: voltage, current, temperature, membrane impedance logged at 1 Hz. Impedance trend: linear extrapolation to failure threshold. Predicts remaining useful life (RUL). | Impedance >2× baseline = WARNING. RUL <30 days = RECOMMEND replacement. | RECOMMEND: crew schedules membrane swap at next maintenance window. If RUL <7 days: escalate to urgent. |
| Pipeline pressure integrity | Pressure sensors every 500 m along 8.5 km pipeline (17 sensors). ΔP between adjacent sensors: expected ~0.1 kPa (friction). Deviation >0.5 kPa: potential leak. | ΔP >0.5 kPa between adjacent sensors. | Isolate pipeline section (close upstream + downstream valves). Alert crew. Rover dispatched for visual inspection. |
| Cryo tank level management | ZBO tank fill level sensors (capacitive). Propellant allocation algorithm: PROBE (priority 1) → SKIP (priority 2) → DART (priority 3) → stockpile (surplus). | Tank <10% = RECOMMEND accelerate ISRU. Tank <5% = WARNING fleet operations paused. | Adjust fleet departure schedule. If surplus >10%: allow DART propellant accumulation. |
| Production accounting | Daily: integrate water flow meter × 24 hr. Compare to MOLE-I fleet telemetry (drill-hours × expected yield). Flag discrepancy >10%. | Actual vs expected production: ±10% = ADVISORY. ±20% = CAUTION. | Investigate: ice concentration lower than mapped? Drill efficiency degraded? Pipeline loss? |

# 8. Domain: Power Management (Partition P2)
| Function | Algorithm | Update Rate |
|---|---|---|
| Load balancing | Priority-weighted allocation. Priority 1: hab ECLSS (non-deferrable). Priority 2: PSR pipeline heating (freeze = months downtime). Priority 3: ISRU electrolysis (production). Priority 4: IZ operations. Priority 5: construction/expansion. If total demand > supply: shed from priority 5 upward. | 1 Hz |
| Eclipse management | Pre-eclipse sequence (triggered 2 hr before predicted eclipse onset): (1) MOLE-S fleet to standby (charge all units). (2) SINTER reactor to hot standby. (3) Non-essential loads shed (construction lighting, non-critical comms). (4) FSP confirms ready. (5) Solar output monitored — when <10% of rated: declare eclipse. Post-eclipse: reverse sequence. | Event-driven + 1 Hz monitoring |
| Solar array tracking | Sun position calculated from ephemeris (stored onboard). Per-panel azimuth command sent to actuator at 0.1 Hz (sun moves ~0.5°/hr at lunar noon). If panel output <80% of expected (dust or degradation): flag for MOLE-S EDS cleaning sweep. | 0.1 Hz |
| FSP interface | Read-only monitoring of FSP reactor telemetry (power output, coolant temp, control drum position, neutron flux). SENTINEL does NOT control FSP reactors — reactor control is autonomous within the FSP unit. SENTINEL can REQUEST power output changes via FSP command interface (e.g., increase from 30 kW to 40 kW during eclipse). FSP confirms or rejects. | 1 Hz monitoring, event-driven commands |

# 9. Domain: Fleet Scheduling (Partition P3)
## 9.1 Task Assignment Algorithm
| Parameter | Value |
|---|---|
| Algorithm | Priority-weighted greedy scheduler with constraint checking. Runs every 10 s (0.1 Hz). Input: pending task queue + robot availability + workspace grid state + geofence constraints. |
| Task priority tiers | Tier 1 (IMMEDIATE): safety tasks (H₂ leak response, emergency rover dispatch). Tier 2 (CRITICAL): ECLSS-support tasks (OGA water delivery, greenhouse tending). Tier 3 (HIGH): production tasks (MOLE-I drilling, SKIP hop dispatch, PROBE departure). Tier 4 (NORMAL): construction (MOLE-S excavation, SINTER sintering). Tier 5 (LOW): maintenance, inspection, road repair. |
| Constraint checks | (a) Geofence: no robot enters another robot's active exclusion zone. (b) Charging: robot must have sufficient battery to complete task + return to charger. (c) Dependency: some tasks have predecessors (e.g., MOLE-S compaction before SINTER sintering on same cell). (d) Concurrency limit: max 2 MOLE-S units in same excavation zone. |
| Output | Per-robot: task_id, waypoints, start_time, estimated_duration. Transmitted via UHF TDMA in the robot's assigned slot. |
| Scale | P2: ~20 robots, ~50 tasks/day. P7+: ~220 robots, ~2,000 tasks/day. Scheduler must complete one pass in <1 s (within 10 s frame). At 220 robots × 5 constraint checks: 1,100 checks/pass — tractable on 100 GFLOPS server. |

## 9.2 Workspace Deconfliction
| Parameter | Value |
|---|---|
| Grid resolution | 1 m × 1 m cells across entire base campus (~2 km × 2 km = ~4M cells). Only active zones loaded in memory (~10,000 active cells at any time). |
| Geofence types | (a) Robot exclusion: 20 m radius around each active MOLE-S/SINTER. (b) Reactor exclusion: 50 m around active SINTER. (c) Crew EVA exclusion: 50 m around SINTER reactor, 20 m around ARM-C boom, 10 m around active landing pad. (d) Blast zone: 500 m around active SKIP/PROBE/DART pad during launch window. |
| Update rate | Geofence map recalculated every 1 s (1 Hz). Robot positions updated from telemetry. If any robot breaches a geofence: immediate stop command. |
| Deconfliction method | Spatial hashing on 10 m grid. Each robot occupies a set of 10 m cells. Collision check: two robots sharing any cell → priority-based yield (lower-priority robot halts + replans). |

# 10. Domain: Inspection and Anomaly Detection (Partition P4)
| Algorithm | Input | Method | Output |
|---|---|---|---|
| Structural crack detection | HD visual camera (rover mast) | CNN-based image classifier trained on: ISS Veggie weld imagery + terrestrial concrete crack datasets + synthetic sintered regolith crack images. Inference: ~50 ms per 1920×1080 frame on server GPU partition. | Crack detected: location_xyz, length_mm, width_mm, severity (hairline/moderate/structural). → anomaly_log. |
| Thermal anomaly detection | Thermal IR camera (rover mast) | Baseline thermal model per structure (trained from initial survey). ΔT >5°C from baseline at same solar phase: flag anomaly. ΔT >20°C: immediate alert. | Hot/cold spot: location_xyz, ΔT_from_baseline, probable cause (heat leak / cryo insulation failure / internal fire). |
| Vibration signature analysis | Contact accelerometer (rover probe arm) | FFT spectrum. Comparison to baseline spectrum per machine. New peaks >10 dB above baseline at bearing-fault frequencies: flag bearing wear. | Machine_id, fault_type (bearing/imbalance/cavitation), severity, estimated time to failure. |
| H₂ plume tracking | Catalytic H₂ sensor + mass spectrometer (rover mast) | Concentration gradient following: rover drives upwind, measures H₂ concentration every 1 m. Peak concentration = source vicinity. Mass spec confirms species (H₂ vs He leak vs CH₄). | Leak source: location_xyz, species, concentration_ppm, estimated leak rate_kg/hr. |
| Plant health (HARVEST integration) | Multispectral + UV-A camera (HARVEST wrist) | Species-specific growth model comparison. Chlorophyll fluorescence ratio (F685/F735) deviation >15%: stress indicator. Visual: colour histogram shift vs healthy reference. | Plant_id, health_status, diagnosis (nutrient_deficiency / pathogen / growth_anomaly), recommended_action. |

# 11. Domain: Crew Safety (Partition P1, triggers P0)
| Function | Sensors | Algorithm | Threshold → Action |
|---|---|---|---|
| EVA geofencing | Suit UWB transponder (10 cm accuracy) | Real-time position check against geofence map (§9.2). If crew member approaches exclusion zone boundary: warning tone in suit. If boundary breached: SENTINEL halts all robots in zone. | <30 m from SINTER reactor: warning. <50 m: tone. Breach: robot halt + crew alert. |
| Atmosphere monitoring | Per-module: ppO₂, ppCO₂, CO, NH₃, formaldehyde, H₂S sensors | Continuous 1 Hz comparison against SMAC limits (Spacecraft Maximum Allowable Concentration, NASA STD-3001 Vol 2). Trend extrapolation: predict threshold breach time. | Any contaminant >80% SMAC: CAUTION. >100% SMAC: WARNING + ventilation increase. ppO₂ <16 kPa or ppCO₂ >25,000 ppm: P0 EMERGENCY. |
| Radiation dose tracking | Per-module dosimeters (8 per hab) | Cumulative dose per crew member (module occupancy time × dose rate). Annual limit: 500 mSv (NASA career limit model, age/gender dependent). | 80% annual limit: RECOMMEND schedule rotation. 95%: WARNING restrict EVA hours. 100%: GATE — crew member confined to lowest-dose module. |
| Medical telemetry (EVA) | Suit biometrics: HR, SpO₂, skin temp | Anomaly detection: HR >150 bpm sustained >5 min, SpO₂ <92%, skin temp >39°C. Cross-correlate with activity level (walking vs heavy labour). | Anomaly detected: alert crew medical officer + Ops Hub display. SENTINEL does NOT make medical decisions — displays data only. |

# 12. Domain: Earth Communications (Partition P6)
## 12.1 Data Prioritisation Queue
| Priority | Data Type | Bandwidth Allocation | Latency Tolerance |
|---|---|---|---|
| P1: Emergency | Emergency alerts, crew medical events | 100% (pre-empts all other data) | <5 s from detection to Earth receipt (1.3 s propagation + processing) |
| P2: Crew safety | EVA telemetry, atmosphere alerts, radiation warnings | 30% of remaining bandwidth | <60 s |
| P3: Operational | PROBE/SKIP/DART mission telemetry, gate requests, anomaly reports | 30% | <5 min |
| P4: Production | ISRU daily summaries, fleet status, maintenance logs | 20% | <1 hr |
| P5: Science/archive | Inspection imagery, plant health data, structural survey results | 15% | <24 hr |
| P6: Housekeeping | Software logs, database sync, trend reports | 5% | Best-effort |

## 12.2 Autonomous Operations (No-Contact Mode)
If Earth comms lost >24 hr: SENTINEL enters no-contact autonomous mode. All EXECUTE functions continue unchanged. All GATE functions transfer to local crew authority (P4+ — crew present). If P2–P3 (no crew): all GATE functions are SUSPENDED — no departures, no heavy lifts, no reactor restarts. Production continues on last known schedule. SENTINEL queues all gate requests for human review when comms restored. No-contact mode has been tested for up to 72 hr in simulation — no functional degradation observed.

# 13. Fault Management System
## 13.1 Fault Tree Structure
| Category | Fault Patterns | Detection Method | Resolution Level |
|---|---|---|---|
| ECLSS | ~40 patterns: valve stuck (open/closed), sensor drift, pump cavitation, heater failure, filter clog, zeolite saturation, coolant leak | State machine: expected sensor response to actuator command. If response deviates >threshold within timeout: fault declared. | RECOMMEND: crew ORU swap. EXECUTE: switch to redundant unit. |
| Power | ~25 patterns: solar panel dropout, bus undervoltage, FSP trip, battery cell failure, cable fault, breaker trip | Voltage/current monitoring at every bus node. Comparison to expected values from load model. | EXECUTE: shed non-critical loads. RECOMMEND: repair/replace. |
| Robot fleet | ~50 patterns per robot type: motor overcurrent, sensor failure, navigation loss, tether fault, communication dropout, battery degradation | Per-robot telemetry monitoring. Baseline comparison. Trend analysis. | EXECUTE: safe-park the robot. RECOMMEND: maintenance dispatch. |
| Structural | ~30 patterns: crack growth, thickness loss, thermal bridge, settlement, seal degradation | Inspection rover data vs baseline database. Trend extrapolation. | RECOMMEND: repair priority + method. |
| ISRU | ~35 patterns: membrane degradation, water quality exceedance, pipeline pressure drop, cryo tank overpressure, valve malfunction | Process instrument monitoring. Mass balance checks. Pressure profile analysis. | EXECUTE: isolate affected section. RECOMMEND: component swap. |
| Comms | ~20 patterns: UHF relay failure, antenna mispoint, X-band transponder fault, network switch failure | Link budget monitoring. Packet loss rate. Signal strength. | EXECUTE: switch to backup. RECOMMEND: repair. |
| TOTAL | ~200 patterns |  |  |

## 13.2 Fault Correlation Engine
When multiple faults trigger simultaneously, the correlation engine identifies the root cause. Method: directed acyclic graph (DAG) of causal relationships. Example: 'LOX pump overcurrent' + 'electrolyser stack 3 undervoltage' + 'pipeline segment 4 pressure drop' → root cause: 'pipeline segment 4 partial blockage' (single fault explains all three symptoms). The DAG is manually authored by the engineering team (not machine-learned) and contains ~500 causal edges connecting the ~200 fault patterns. Correlation runs in P7 (Housekeeping) at 0.1 Hz — it is diagnostic, not time-critical.
# 14. Scalability Notes
| Parameter | P2–P3 | P4 | P7+ | Scaling Method |
|---|---|---|---|---|
| Robots managed | ~20 | ~40 | ~220 | TDMA slot count: 128 → 256 (firmware update). Scheduler: O(n) per pass. |
| Sensors ingested | ~100 | ~200 | ~500 | Sampling port ring buffer: sized for 1,000 sensors at 1 Hz. |
| Database size | ~200 GB | ~500 GB | ~2–3 TB | 10 TB SSD. Archival: overwrite oldest inspection imagery >5 yr. |
| Server load | ~15% | ~30% | ~70% | If >80%: hot-swap server blade upgrade (next-gen GPU/FPGA). P7+ may need 3rd blade for inspection image processing. |
| Crew interface | Earth-only | Local + Earth | Local primary | Additional crew displays in F1 (greenhouse monitoring) and IZ (docking ops) from P5+. |

# 15. PKT Distributed Software Architecture
The PKT base operates with zero permanent crew and requires a fundamentally different software architecture from SPA. While SPA SENTINEL runs on 2× centralised server blades managing ~220 robots, PKT must manage ~1.5M haulers, ~87,500 km of conveyor, ~6,890 MSR reactors, and ~2.08M processing circuits across ~5,000 km of processing spine. This section specifies the distributed software architecture that makes this tractable.
## 15.1 Node Software Architecture
Each PKT SENTINEL node runs an identical software image to the SPA SENTINEL server (ARINC 653, 8 partitions, 100 ms major frame). The key difference is scope: each node’s P3 (Fleet) partition manages only its local sector (~15,000 haulers, ~875 km conveyor, ~69 MSRs, ~20,800 circuits) rather than the entire base. This reduces the scheduler problem from O(1.5M) to O(15k) per node — well within the 100 GFLOPS processing budget at 0.1 Hz update rate.
| Parameter | Specification |
|---|---|
| Partitions | Identical P0–P7 partition map to SPA. P0 (Emergency): MSR emergency shutdown, conveyor emergency stop. P1 (ECLSS): NOT USED at PKT (no crew, no life support). Partition time reallocated to P3 (Fleet) for additional hauler scheduling capacity. P2 (Power): MSR fleet power demand setpoints, load balancing across spine bus. P3 (Fleet): hauler task scheduling, conveyor monitoring, charging rotation. P4 (Inspection): local rover patrol management, circuit QC anomaly detection. P5 (ISRU): processing circuit monitoring (kiln temp, leach pH, filter press cycle, REO purity). P6 (Comms): UHF mesh management, Ka-band relay satellite uplink. P7 (Housekeeping): local database, trend analysis, SPA downlink packaging. |
| P1 reallocation | SPA SENTINEL dedicates 15 ms/100 ms frame to ECLSS (P1). PKT has no ECLSS. This 15 ms is reallocated to P3 (Fleet), giving PKT nodes 35 ms/100 ms for fleet scheduling vs 20 ms at SPA. This 75% increase in P3 time budget directly supports the ~70× fleet size increase (15,000 vs 220 robots per node). |
| Database | Local SQLite database per node. Schema: robot_fleet (15,000 haulers × 1 Hz = 15,000 rows/s), conveyor_state (~1,750 drive stations × 0.1 Hz), msr_telemetry (~69 reactors × 1 Hz), circuit_production (~20,800 circuits × 0.01 Hz daily summary), inspection_archive, anomaly_log. Estimated size: ~500 GB per node (90-day retention). 2 TB SSD provides ample headroom. |
| UHF TDMA | PKT uses the same TDMA protocol as SPA (128 slots/10 s frame) but with 12 concurrent UHF channels per node (frequency-division). 12 channels × 128 slots = 1,536 slots per 10 s frame. At 15,000 haulers: each hauler gets 1 slot per ~100 s (0.01 Hz individual telemetry). Sufficient for position + battery + task status updates. High-priority slots (first 8 per channel) reserved for inspection rovers and anomaly responses. |

## 15.2 Latency Management
| Decision Type | Latency Tolerance | Handling |
|---|---|---|
| Hauler task assignment | 10 s (scheduler cycle) | Local node. Zero relay dependency. Node schedules all haulers within its sector autonomously. |
| Conveyor segment isolation | <1 s (safety) | Local node P0 partition. Hardwired emergency stop to drive stations within sector. No relay dependency. |
| MSR emergency shutdown | <100 ms (safety) | Local node P0 partition. Hardwired control rod drop signal. NEVER routed via relay satellite. This is PKT’s equivalent of SPA’s fire/depress response. |
| MSR startup/shutdown (planned) | Minutes (GATE) | Escalated to SPA Ops Hub via relay satellite. 0.5 s round-trip latency is negligible for planned operations. Crew approval required. |
| Mass driver launch | Seconds (EXECUTE) | Local node for routine launches on approved schedule. First-launch-of-day GATE via SPA (0.5 s latency). |
| Anomaly escalation | Seconds (RECOMMEND) | Local node diagnoses and contains. Diagnosis + sensor data uplinked to SPA via relay satellite. Crew reviews and approves corrective action. 0.5 s latency does not degrade decision quality for non-time-critical anomalies. |
| Strategic replanning | Hours (RECOMMEND) | SPA Ops Hub. Production target changes, mining frontier expansion, fleet rebalancing across sectors. Crew-directed via relay satellite. |

⚠ Design principle: ANY decision that must complete in <1 s is handled entirely within the local SENTINEL node with hardwired actuator connections. The relay satellite is NEVER in the critical path for safety-critical responses. The 0.5 s relay latency is only relevant for strategic and GATE-level decisions where it is operationally insignificant.
## 15.3 Exception Escalation Protocol
PKT SENTINEL nodes escalate exceptions to SPA Ops Hub using a 4-tier protocol. Each tier has a defined response time and crew action requirement.
| Tier | Trigger | Node Action | SPA Action |
|---|---|---|---|
| T0: Local | Routine operations, hauler rerouting, circuit auto-shutdown, drive station swap | Node handles autonomously. Logged. Not uplinked unless requested. | None. Crew reviews daily summary report. |
| T1: Advisory | Single-sensor anomaly, production rate drift >10%, conveyor segment offline | Node contains (reroutes traffic, flags for maintenance). Uplinks advisory in next 60 s data packet. | Crew acknowledges. May request additional data. No immediate action required. |
| T2: Alert | Multi-sensor confirmed fault, MSR protection trip, ≥5% hauler fleet offline in sector, mass driver trajectory deviation | Node isolates affected subsystem. Uplinks alert with full sensor trace immediately (priority bandwidth). Requests crew guidance. | Crew reviews within 1 hr. Approves/modifies node’s recommended corrective action. May dispatch ARM-C or schedule crew EVA visit. |
| T3: Emergency | MSR loss-of-coolant, conveyor structural failure with debris, mass driver abort, node hardware failure | Node P0 executes emergency response autonomously (control rod drop, emergency stop, abort). Uplinks emergency notification immediately. Adjacent nodes notified for sector absorption. | Crew alerted immediately (alarm at Ops Hub). Full situational awareness within 5 s of event. Crew directs recovery. Earth notified. |

## 15.4 PKT Fault Management Extensions
The SPA fault management system (§14, ~200 patterns + 6 ECN-014 valve patterns) is extended for PKT with ~150 additional fault patterns covering PKT-specific subsystems. These are loaded on PKT nodes only (SPA nodes do not carry PKT patterns).
| Category | Patterns | Detection | Resolution |
|---|---|---|---|
| Hauler fleet | ~50 | Per-hauler telemetry. Battery degradation, motor overcurrent, navigation loss, bucket wear, Na-S thermal fault. | EXECUTE: safe-park hauler at nearest hub. RECOMMEND: ARM-C maintenance dispatch. Fleet scheduler redistributes load. |
| Conveyor network | ~30 | Per-drive-station monitoring: belt tension, motor current, alignment sensor, throughput weigh cell, thermal. | EXECUTE: auto-stop segment on confirmed fault. Reroute hauler traffic to adjacent conveyor input. ARM-C belt/drive replacement. |
| MSR fleet | ~25 | Per-reactor telemetry: power output, salt temperature, drain tank level, neutron flux, Hastelloy corrosion sensor. | MONITOR + GATE: MSR has autonomous reactor controller. SENTINEL sets demand and monitors. Protection trip → T3 emergency. Planned maintenance via SPA crew approval. |
| Processing circuits | ~25 | Per-circuit instrumentation: kiln temperature, leach pH, filter press cycle, inline XRF purity, reagent flow. | EXECUTE: auto-shutdown anomalous circuit (depressurise enclosure). ARM-C gasket/pump swap. Circuit restart after QC verification. |
| Foundry | ~10 | Casting temperature, metallurgical XRF, dimensional laser scan. | RECOMMEND: defective batch re-melt. Die replacement scheduling. |
| Mass drivers (PKT) | ~10 | Superconducting coil temperature, capacitor bank voltage, trajectory tracking radar. | EXECUTE: abort launch on trajectory deviation. RECOMMEND: coil/cap replacement. Same patterns as SEL-CATAPULT-001 coilgun heritage. |

Total PKT fault patterns: ~150. Combined with SPA baseline (~206): ~356 programme-wide. DAG correlation engine at each PKT node contains ~300 causal edges for PKT-specific patterns (vs ~500 for SPA). Correlation runs in P7 (Housekeeping) at 0.1 Hz per node.
# 16. Document History
| Rev | Description |
|---|---|
| Rev A | Initial release. SENTINEL software architecture specification. ARINC 653 RTOS with 8 partitions (P0 Emergency through P7 Housekeeping). 100 ms major frame. P0 has exclusive safety-critical actuator access (<100 ms emergency response). ECLSS closed-loop: dual PID CO₂ valve (Kp=0.5, settling <300 s), PID OGA rate, cascade PID thermal. SQLite database: 10 tables, ~2–3 TB at P7+. Fleet scheduler: priority-weighted greedy with geofence constraint checking, 0.1 Hz, scales to 220 robots. 5 anomaly detection algorithms (crack CNN, thermal baseline, vibration FFT, H₂ plume gradient, plant health model). ~200 fault patterns in DAG correlation engine (~500 causal edges). TDMA UHF mesh (128 slots/10 s frame). X-band 50 kbps with 6-tier priority queue. No-contact autonomous mode tested to 72 hr. Scales P2 (~20 robots, 15% server load) to P7+ (~220 robots, 70% load). March 2026. |
| Rev B | ECN-019 Rev C update. New §15: PKT distributed software architecture. Node software: identical ARINC 653 image with P1 (ECLSS) time reallocated to P3 (Fleet) for ~15,000 haulers per node. 12-channel UHF TDMA (1,536 slots/10 s frame). Latency management: all <1 s safety decisions local to node (hardwired actuators); relay satellite (0.5 s) only for strategic/GATE decisions. 4-tier exception escalation protocol (T0 Local → T3 Emergency). ~150 PKT-specific fault patterns (hauler ~50, conveyor ~30, MSR ~25, circuit ~25, foundry ~10, mass driver ~10). Combined programme fault patterns: ~356. Crew count updated 12 → 20. Source refs updated to SENTINEL Design Rev B, ECN-019 Rev C, fleet v9. April 2026. |

— End of Document —