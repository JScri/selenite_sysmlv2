<!-- Markdown extract of docs/sources/SEL-ECN-013_Navigation_ARMfix_RFconstruction_v1.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
Engineering Change Notice
MOLE-I Navigation Subsystem, CLP WEB Delivery Fix, and Construction RF Comms
| ECN Reference | SEL-ECN-013 |
|---|---|
| Date | March 2026 |
| Originator | Jason (Systems Engineering Lead) |
| Classification | DESIGN CHANGE — Navigation addition + deployment sequence correction |

# 1. Change Summary
Three changes are bundled in this ECN:
- Change A: MOLE-I navigation and workspace management subsystem (new capability, specified in SEL-NAV-001 Rev A). Adds MEMS IMU to MOLE-I, 2-axis angle encoder to substation guide roller, Kalman filter firmware on existing avionics, and persistent drill grid.
- Change B: CLP WEB module delivery corrected. ARM robot CANNOT descend into the PSR (no WEB, no cryogenic hardening — electronics dead within minutes at 40 K). The CLP WEB module is pre-mounted onto the SATS frame at the rim (by ARM in comfortable surface conditions), creating a pre-integrated SATS+WEB assembly. This is lowered at the trunk cable terminal end during Stage A. The CLP node arrives already powered and operational. The first construction MOLE-I plugs into the SATS+WEB construction tap via its motorised bayonet adapter (SEL-MI-CON-001).
- Change C: Construction MOLE-I RF comms role formalised. The MOLE-I’s existing 20 W UHF radio and antenna communicate with the substation UHF relay network during branch construction operations when using temporary tethers (no PLC available on temporary tether). This is an operational role for existing hardware, not a hardware change.
# 2. Affected Documents
| Document | Current | New | Change |
|---|---|---|---|
| SEL_MOLEI_DESIGN | v4 | v5 | A: Add nav subsystem. C: RF construction role. |
| SEL-SW-MOLEI-001 | Rev C | Rev D | A: IMU part, harness 55 conductors |
| SEL_SUBSTATION_DESIGN | v3 | v4 | A: Angle encoder on guide roller |
| SEL-SW-SUB-001 | Rev B | Rev C | A: DRM-040 angle encoder part |
| SEL_ROBOT_FLEET | v7 | v8 | A+B+C: Nav, ARM fix, RF construction |
| SEL-CON-001 | Rev A | Rev B | B: CLP WEB delivery by MOLE-I |
| W2_T1_1_JS_MTL_GUIDE | v16 | v17 | B: Remove ARM from PSR deployment |

# 3. Change A — Navigation Subsystem
Full specification in SEL-NAV-001 Rev A. Summary of hardware changes:
## 3.1 MOLE-I Additions
- SEL-MI-NAV-001: MEMS 6-DOF IMU, 0.05 kg, 0.3 W, inside WEB on avionics board. SPI interface.
- Harness count: 53 → 55 conductors (+2× AWG 28 for IMU SPI, 100 mm Manganin transition at WEB wall).
- Firmware: Kalman filter on existing PLC. Fuses tether polar fix + wheel odometry + IMU. 10 Hz output. ~0.1 W additional compute.
- Non-volatile workspace grid: 3,600 cells × 14 bytes = ~50 kB. Stored on avionics board flash memory (existing hardware, no addition needed).
- Dry mass: 360.3 → 360.35 kg (negligible).
## 3.2 Substation Additions
- SEL-SUB-DRM-040: 2-axis angle encoder on tether guide roller. One per face (5 total). 0.1 kg each, 0.5 kg total. 0.1 W each, 0.5 W total.
- Substation harness: 63 → 73 conductors (+10: 5 faces × 2× AWG 28). Manganin transitions. Thermal load increase: +0.02 W (negligible).
- Substation mass: 135 → 135.5 kg. Power: 95.5 → 96.0 W.
- Port allocation controller firmware update: receives angle encoder data, calculates polar fix for each MOLE-I, relays to SENTINEL.
# 4. Change B — CLP WEB Delivery Fix
## 4.1 Problem
FLEET v7 §13 Stage B states: “ARM robot descends on winch, connects WEB module to SATS power bus.” ARM is a surface robot (operates at rim, 200–290 K day/night cycle). It has no WEB, no MLI, no cryogenic hardening. Its electronics, lubricants, and actuators are rated to a minimum of −55°C (218 K). The PSR operates at 40–90 K. ARM cannot survive descent through the ≤25 K crater wall zone, let alone operate on the 40 K PSR floor.
The same issue applies to the P3 deployment timeline in SEL-CON-001 Rev A, which shows “CLP WEB + ARM descent” as payload #2.
## 4.2 Corrected Procedure
The CLP WEB module is lowered to the PSR floor as a PASSIVE PAYLOAD on the infrastructure winch, bundled with or immediately after the trunk cable. The WEB is pre-heated to 293 K at the rim and its 3× LWRHU (3.3 W total) maintain ≥268 K throughout the ~23 hr descent (per substation transit thermal analysis — identical thermal mass and insulation).
On arrival at the CLP, the first construction MOLE-I (payload #3 on a unit winch, descending in parallel) transits on battery to the SATS position and physically pushes the WEB module into its mounting position on the SATS frame. The MOLE-I then plugs in its own temporary construction tether (100 m, bayonet connector) to a construction tap on the SATS, providing grid power. From grid power, the MOLE-I uses its drill housing push-plate to seat the WEB’s bayonet power connector into the SATS bus bar socket.
No ARM robot enters the PSR at any stage. ARM operations are exclusively on the crater rim and surface.
## 4.3 Document Corrections
- SEL_ROBOT_FLEET v7 → v8, §13 Stage B: Replace “ARM robot descends on winch, connects WEB module to SATS power bus” with “CLP WEB module lowered as passive payload on IW-1 (pre-heated, LWRHU cold-start insurance). First construction MOLE-I pushes WEB into SATS mounting position and connects power bayonet.”
- SEL-CON-001 Rev A → Rev B, §1.2 P3 Timeline: Payload #2 changes from “CLP WEB + ARM descent” to “CLP WEB module (passive, on IW-1, 23 hr).” Remove ARM from all PSR deployment references.
- W2_T1_1_JS_MTL_GUIDE v16 → v17, §Y4.2 Stage 3: Replace ARM WEB connection step with MOLE-I WEB connection step.
⚠ Verify ALL programme documents for any other references to ARM operating below the crater rim. ARM’s operating envelope is explicitly rim-and-surface only. No ARM variant has cryogenic hardening, and adding a WEB to ARM would fundamentally change its mass, power, and thermal budget — a different robot class entirely.
# 5. Change C — Construction RF Comms
During branch build-out (SEL-CON-001 Stages C/D), the construction MOLE-I operates on a temporary 100 m tether plugged into construction tap points. These temporary tethers carry 1,000 VDC power but the PLC modem on the MOLE-I is configured for its permanent drum tether — it may not handshake with the construction tap’s simpler junction box.
The MOLE-I’s 20 W UHF radio (existing hardware, SEL-MI-COM-001) communicates directly with the substation UHF relay network during construction. The nearest operational substation or spine junction with a UHF relay provides the uplink to SENTINEL. This is the construction MOLE-I’s primary comms path during branch build-out.
No hardware change required. Operational procedure: when the MOLE-I disconnects from its permanent drum tether and plugs into a construction tap, the avionics automatically switches comms from PLC mode to UHF mode. On return to the permanent tether, it switches back to PLC.
Add to SEL_MOLEI_DESIGN v5 §4.7: “During construction operations, the MOLE-I uses its UHF radio as the primary comms link, communicating with the substation UHF relay mesh. PLC comms are unavailable on temporary construction tethers. Automatic PLC/UHF switchover is managed by the WEB avionics based on tether connection type (permanent drum port = PLC; construction tap = UHF).”
# 6. Verification Actions
| # | Action | Owner | Status |
|---|---|---|---|
| 1 | Confirm MEMS IMU performance at 273 K (WEB internal). Space-qualified units (e.g. Honeywell HG4930) are rated to this range. | Abhijay | OPEN |
| 2 | Design 2-axis angle encoder mount for substation guide roller. Must survive 40 K, MoS₂ lubricated pivot, potentiometric or magnetic sensing. | Abhijay / Jason | OPEN |
| 3 | Kalman filter simulation: generate synthetic tether polar + odometry + IMU data, verify ±0.5 m steady-state accuracy over 46-hr drilling cycle. | Jason (MATLAB) | OPEN |
| 4 | Confirm CLP WEB module can be lowered as passive payload on IW-1 cable. Verify LWRHU thermal survival without external power during 23 hr descent. | Jason | OPEN |
| 5 | UHF range test: confirm 20 W UHF from construction MOLE-I reaches nearest substation relay across 500 m+ in PSR (line-of-sight, no atmosphere, should be trivial). | Nikhil / Vincent | OPEN |
| 6 | Sweep ALL programme documents for ARM-in-PSR references. Ensure ARM operating envelope is explicitly rim-and-surface only in every document. | Jason | OPEN |

# 7. Document History
| Rev | Description |
|---|---|
| ECN-013 v1 | Initial release. MOLE-I navigation subsystem (tether polar + odometry + IMU + workspace grid). CLP WEB delivery corrected (MOLE-I replaces ARM). Construction RF comms formalised. March 2026. |

— End of Document —