<!-- Markdown extract of docs/sources/SEL-NAV-001_MOLEI_Navigation_RevA.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
MOLE-I Navigation and Workspace Management
Tether-Based Polar Positioning, Dead-Reckoning, and Drill Grid Mapping
| Reference | SEL-NAV-001 Rev A |
|---|---|
| Date | March 2026 |
| Author | Jason (Systems Engineering Lead) |
| Source Docs | SEL_MOLEI_DESIGN v4, SEL-SW-MOLEI-001 Rev C, SEL_SUBSTATION_DESIGN v3, SEL_ROBOT_FLEET v7 |

This document specifies the navigation, localisation, and workspace management system for the MOLE-I PSR ice extraction rover. The PSR is in permanent darkness with no GPS, no visible horizon, and no external positioning infrastructure. The MOLE-I has no cameras. All positioning is derived from the power tether geometry, wheel encoders, and an onboard IMU, fused into a workspace grid that tracks where the rover has drilled and where it needs to drill next.
# 1. Navigation Problem Statement
Each MOLE-I operates within a 72° × 200 m radial sector radiating outward from its substation face. Over a 15+ year service life, it must systematically drill every accessible point in its sector without gaps or re-drilling. At 25 kg/hr excavation rate and a ~1 m² drill footprint per position, a single MOLE-I processes roughly 200 drill positions per year. Over 15 years that is ~3,000 unique positions across its ~25,000 m² sector. The rover must navigate to each position, drill, retract for water dump every ~46 hours, and return to precisely where it left off.
There are no external navigation aids in the PSR. No sunlight (cameras useless without illumination, and no lighting system is specified), no GPS constellation, no surface beacons, no star visibility from the crater floor. The rover’s only spatial references are its own wheels, its power tether, and the substation at the tether’s far end.
# 2. Positioning Architecture
## 2.1 Primary: Tether-Based Polar Fix
The constant-tension cable drum on the substation continuously tracks tether payout length via a rotary encoder on the drum shaft. This gives range (r) from the substation face to the MOLE-I with ~±0.1 m precision (encoder resolution on a 200 mm dia spool: 1 encoder tick ≈ 0.6 mm linear).
A new 2-axis angle encoder (SEL-SUB-DRM-040) is added to the tether guide roller at each pentagonal face. As the tether exits through the PEEK-bushed roller, the roller assembly deflects on 2 axes (azimuth within the 72° sector, and elevation). This gives bearing (θ) within the sector to ~±1°.
Combined polar fix: (r, θ) from substation. At 200 m range, ±1° azimuth = ±3.5 m cross-track. At 50 m (typical drilling radius), ±1° = ±0.87 m. This is the coarse position fix, available whenever the tether is taut (which it always is during drilling — the constant-tension motor maintains 50 N).
⚠ The tether polar fix degrades when the tether is slack (during tight manoeuvres near the substation). For the final 5 m of docking approach, the 2× rear proximity sensors take over (IR/ultrasonic, 100 mm spacing, existing spec).
## 2.2 Secondary: Wheel Odometry (Dead Reckoning)
The MOLE-I has 6× wheel encoders and 6× steering feedback sensors (existing spec, AWG 28, in the SolidWorks harness table). These provide dead-reckoning odometry: distance travelled and heading change from encoder tick counts and steering angles.
Drift estimate: On flat icy regolith with spring-steel mesh wheels, odometry drift is typically 2–5% of distance travelled. Over a 200 m traverse, that’s 4–10 m position uncertainty. Over a 5 m drill-advance increment, drift is 0.1–0.25 m — well within the 1 m drill footprint.
Odometry is used for fine positioning between tether polar fixes: short advances from one drill position to the next (typically 1–5 m), heading corrections, and obstacle avoidance (if the drill encounters unexpected resistance, the rover reverses and offsets laterally).
## 2.3 Tertiary: MEMS IMU
A single MEMS IMU (3-axis accelerometer + 3-axis gyroscope) is added inside the WEB. This provides heading reference during manoeuvres when the tether may be slack or when the rover is driving laterally (cross-track) and the tether angle is not a reliable heading indicator.
| Parameter | Specification |
|---|---|
| Part number | SEL-MI-NAV-001 |
| Type | MEMS 6-DOF IMU (e.g. Honeywell HG4930, space-qualified, or equivalent) |
| Mass | ~0.05 kg (board-level, inside WEB) |
| Power | ~0.3 W continuous |
| Location | Inside WEB, mounted on avionics board. Thermally stable at 273 K. |
| Gyro drift | ~0.5°/hr (MEMS grade). Corrected every tether retraction cycle (~46 hr max between fixes). |
| Accel range | ±2 g. Sufficient for 1/6 g lunar + dynamic loads during drilling. |
| Interface | SPI to WEB avionics. 2× AWG 28 leads (adds to harness count: 53 → 55 conductors). |

The IMU drift of ~0.5°/hr accumulates to ~23° over a worst-case 46-hour drilling cycle. This is corrected on every retraction: when the MOLE-I reverses toward the substation and the tether goes taut, the polar fix re-establishes absolute position and heading. The IMU is reset to the polar-derived heading at each dock cycle. Between docks, odometry + IMU fusion keeps the heading estimate within ~2°.
## 2.4 Sensor Fusion
The WEB avionics board runs a lightweight Kalman filter fusing three inputs: tether polar fix (absolute, low rate, available when tether is taut), wheel odometry (relative, high rate, always available), and IMU heading (relative, high rate, drifts). The filter output is a (x, y) position estimate in the substation-centred coordinate frame (origin at substation face centre, x-axis along sector centreline, y-axis cross-track). The position estimate is updated at 10 Hz and has an estimated steady-state accuracy of ±0.5 m during drilling operations.
This is a simple, well-understood sensor fusion problem. No vision, no SLAM, no neural networks. The computational load is negligible — a 32-bit microcontroller running at 1 MHz could handle it. The WEB avionics board (PLC-based, 5 W) has ample capacity.
# 3. Workspace Grid Management
## 3.1 Drill Grid
Each MOLE-I’s 72° × 200 m sector is discretised into a polar grid: radial bins of 2 m spacing (100 bins from 2 m to 200 m) × angular bins of 2° spacing (36 bins across the 72° sector). Total: 3,600 grid cells. Each cell stores: drilled (boolean), drill depth (mm), estimated ice yield (kg), timestamp, and position quality flag.
The grid is stored in non-volatile memory inside the WEB avionics board (~50 kB for 3,600 cells at 14 bytes each). The grid is uploaded to the substation via PLC after each dump cycle (50 kB at 1 kbps PLC = ~6.5 minutes — fits within the 15-min dump window). The substation relays the grid to SENTINEL via the spine network for fleet-wide coordination.
## 3.2 Drilling Strategy
The MOLE-I advances radially outward from the substation along its sector centreline, drilling at each grid position until the tether limit is reached (~200 m). It then offsets laterally by one grid cell (2° ≈ 3.5 m at 100 m range) and works inward. This lawn-mower pattern ensures complete sector coverage with no gaps.
At each drill position: the rover stops, lowers the drill, excavates to depth (400 mm extension, ~25 kg/hr for ~1 hour per position), retracts the drill, advances 2 m to the next position, and repeats. When the 50 L tank is full (~45 hr, ~45 positions), the rover retracts to the substation for dump and then returns to the exact grid cell where it left off (position stored in non-volatile memory, tether polar fix confirms return accuracy).
## 3.3 Sector Boundary Coordination
Adjacent MOLE-I units on the same substation share the substation’s coordinate frame. The port allocation controller (inside WEB) tracks which grid cells belong to which MOLE-I. At sector boundaries (every 72°), a 2 m exclusion zone prevents tether crossings. SENTINEL monitors for conflicts fleet-wide — if a MOLE-I’s tether path would cross another unit’s tether, the controller holds the advancing unit until the path is clear.
# 4. Construction Navigation
During construction operations (Stage C/D in SEL-CON-001), the MOLE-I uses its RF antenna (20 W UHF, existing spec) to communicate with the substation UHF relay network. This provides the only comms link when the construction MOLE-I is operating on a temporary tether (100 m, plugged into construction tap points) rather than its permanent drum tether.
Construction navigation is simpler than drilling navigation: the construction MOLE-I follows the cable/pipe it is pulling (a physical guide on the ground), and its position along the branch is determined by counting construction tap points (every 100 m, known fixed positions). No precision workspace grid is needed — just linear position along the branch route.
The UHF link carries: position reports (tap point number + odometry offset), power status (temporary tether voltage), and construction gate requests (human approval for irreversible steps like stake driving). Earth round-trip delay is 2.56 s — acceptable for monitored-autonomy construction but not real-time teleoperation.
# 5. Hardware Additions Summary
| Item | Mass | Power | Integration |
|---|---|---|---|
| MEMS IMU (SEL-MI-NAV-001) | 0.05 kg | 0.3 W | Inside WEB on avionics board. SPI interface. 2× AWG 28 leads through WEB wall (Manganin transition). Harness count: 53 → 55. |
| Tether angle encoder (SEL-SUB-DRM-040) | 0.1 kg | 0.1 W | On substation guide roller, one per face (5 total, 0.5 kg). 2-axis potentiometric or magnetic. Signal fed to substation WEB via AWG 28 pair. Substation harness: 63 → 73 conductors (+10: 5 faces × 2 leads). |
| Navigation firmware | — | ~0.1 W | Kalman filter on existing WEB PLC. No new hardware. Firmware update only. |

Total mass addition: 0.55 kg across MOLE-I and substation. Total power: 0.4 W per MOLE-I (continuous, negligible).
# 6. Document History
| Rev | Description |
|---|---|
| Rev A | Initial release. Tether-based polar positioning, wheel odometry, MEMS IMU, Kalman filter fusion, workspace grid, construction navigation via UHF. March 2026. |

— End of Document —