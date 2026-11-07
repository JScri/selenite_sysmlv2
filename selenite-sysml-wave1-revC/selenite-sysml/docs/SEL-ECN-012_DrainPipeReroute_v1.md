<!-- Markdown extract of docs/sources/SEL-ECN-012_DrainPipeReroute_v1.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
Engineering Change Notice
MOLE-I Rear Drain Pipe Reroute and Substation Interface Confirmation
| ECN Reference | SEL-ECN-012 |
|---|---|
| Date | March 2026 |
| Originator | Jason (Systems Engineering Lead) |
| Classification | DESIGN CHANGE — Interface and routing modification |
| Priority | HIGH — affects MOLE-I / substation physical interface |

# 1. Affected Documents
| Document | Current Rev | New Rev | Change Type |
|---|---|---|---|
| SEL_MOLEI_DESIGN | v3 | v4 | Drain pipe routing, dump cycle |
| SEL-SW-MOLEI-001 | Rev B | Rev C | Piping assembly, Phase 8 rewrite |
| SEL_SUBSTATION_DESIGN | v2 | v3 | Drum height, funnel confirmed |
| SEL-SW-SUB-001 | Rev A | Rev B | Drum z-height, Phase 5 update |
| SEL-ISRU-001 | Rev C | Rev D | Dump cycle timing, pipe purge step |
| SEL_ROBOT_FLEET | v6 | v7 | MOLE-I drain spec, sub-station §10.4 |

# 2. Change Summary
The MOLE-I water drain pipe is rerouted from a vertical exit at mid-chassis bottom (position 1,300 mm) to a rear-exit nozzle near the tether receptacle (position ~2,650 mm). This eliminates the geometric mismatch between the MOLE-I drain point and the substation docking funnel position, removing the need for 1.5 m extending collection arms on the substation. The substation reverts to short docking funnels on each pentagonal face, now confirmed at z = 160 mm below the raised cable drums at z = 380 mm.
The rerouted pipe runs ~1,350 mm along the chassis bottom rail from the WEB wall to the rear nozzle. It is trace-heated at ~15 W, activated when the tank level reaches ~90% (before retraction begins). A post-dump purge cycle keeps the heater running for 2–3 minutes after valve closure to expel residual water before the pipe returns to ambient 40 K.
# 3. Change 1 — MOLE-I Drain Pipe Reroute
## 3.1 Previous Design
Drain pipe exits vertically from tank bottom through WEB floor, through PEEK thermal coupler, through chassis bottom at position 1,300 mm (mid-chassis). Water falls through open gap into substation funnel positioned directly below. Three-part pipe assembly: SEL-MI-PIP-001 (Ti section 1), SEL-MI-PIP-002 (PEEK coupler), SEL-MI-PIP-003 (Ti section 2). Total path ~200 mm (S-bend for thermal isolation).
## 3.2 New Design
Drain pipe exits vertically from tank bottom through WEB floor as before (PIP-001 + PIP-002 unchanged). Below the PEEK coupler, the pipe turns horizontal and runs along the chassis bottom rail to the rear of the rover, exiting through a downward-pointing nozzle at position ~2,650 mm (adjacent to tether receptacle boss). New parts added:
| Part | Specification |
|---|---|
| SEL-MI-PIP-003 | Ti tube, 20 mm OD × 1 mm wall, ~1,350 mm horizontal run along chassis bottom rail. Routed inside MLI shroud envelope. Secured to chassis rail with Ti saddle clips at ~300 mm spacing. |
| SEL-MI-PIP-004 (new) | Ti elbow (90°) at rear transition, 20 mm OD. Connects horizontal run to downward nozzle. |
| SEL-MI-PIP-005 (new) | Rear drain nozzle, Ti, 20 mm OD tapering to 25 mm exit cone (directs stream downward into funnel). ~50 mm protrusion below chassis bottom face. Exit point at ~200 mm above ground (above funnel capture cone when docked). |
| SEL-MI-PIP-030 (new) | Kapton film trace heater, 15 W rated, wrapped around PIP-003/004/005 full length. AWG 22 power leads to WEB avionics via 100 mm Manganin transition at WEB wall (adds 2 conductors to harness count: total 51 → 53). |

## 3.3 Heating Strategy
### 3.3.1 Thermal Sizing
Ti pipe mass (1.35 m × 20 mm OD × 1 mm wall): ~0.38 kg. Cp of Ti averaged 40→280 K: ~300 J/kg·K. Energy to heat pipe from 40 K to 280 K: 0.38 × 300 × 240 = 27.4 kJ. At 15 W continuous: 27,400 / 15 = 1,827 s = ~30.5 minutes.
### 3.3.2 Activation Sequence
| Step | Trigger | Action |
|---|---|---|
| 1: Pre-heat | Tank level ≥ 90%
(~45 L / ~40.5 hr) | WEB controller activates PIP-030 trace heater at 15 W. Pipe begins warming from 40 K while MOLE-I continues drilling for final ~4.5 hours of fill. By the time the tank is full, the pipe has been heating for ~4.5 hr (16.2 kJ delivered) — well past the 27.4 kJ requirement. Pipe reaches thermal equilibrium at ~280 K. |
| 2: Retract | Tank full
(50 L / ~45 hr) | MOLE-I reverses toward substation at 0.1 m/s. Drum reels in tether. Heater remains on continuously. Retraction: 33 min (200 m). Pipe at 280 K — well above 273 K water freeze point. |
| 3: Dump | Docked at
substation | Bottom-drain valve opens. 273 K water flows from tank through WEB interior section (warm), through PEEK coupler, into heated pipe (280 K), out rear nozzle, into substation funnel below. Gravity-fed at 1/6 g. Dump duration: ~15 min for 50 L. |
| 4: Purge | Drain valve
closes | Heater remains on for 3 minutes after valve closure. Residual water in pipe continues flowing under gravity and/or boils off in the vacuum-exposed nozzle section. After 3 min, pipe interior is clear. Heater shuts off. Pipe cools to 40 K within ~30 min (passive radiation). No ice plug risk — pipe is empty. |
| 5: Resume | Purge complete | MOLE-I drives forward to resume drilling. Drum pays out tether. Pipe returns to 40 K ambient (empty, no thermal risk). Next heating cycle begins at step 1 when tank reaches 90% again (~40.5 hr later). |

### 3.3.3 Power Budget Impact
Duty cycle: heater on for ~5.3 hr per 46 hr cycle (4.5 hr pre-heat + 0.55 hr dump + 0.05 hr purge). Duty: 11.5%. Average continuous draw: 15 × 0.115 = 1.7 W. This is negligible against the 1,934 W tether draw. The heater only runs during non-drilling phases (retraction and dump), so it does not compete with drilling power. No power budget revision required.
⚠ Conductor count increases from 51 to 53 (2× AWG 22 for pipe heater, 100 mm Manganin transition). Update harness thermal load: +0.004 W (negligible). Update MOLEI_THERMAL v1.3 conductor table.
# 4. Change 2 — Substation Interface Confirmation
## 4.1 Drum Height
Cable drums raised from z = 280 mm to z = 380 mm. This matches the MOLE-I tether receptacle height (chassis bottom clearance ~200 mm + ~150 mm chassis depth to receptacle boss at mid-chassis height). Tether exit guide rollers also raised to z = 380 mm. No change to drum mass, motor, gearbox, or tether specifications.
## 4.2 Docking Funnels Confirmed
Short docking funnels confirmed at z = 160 mm on each pentagonal face. The MOLE-I rear drain reroute means the nozzle exit sits directly above the funnel when the rover reverses in and docks. Funnel specifications unchanged from v2: 200 mm capture cone, ±50 mm positional tolerance, 3 W heated lip (active during dump cycle only), gravity drain to manifold through PEEK thermal sleeve.
Vertical separation between drums (z = 380 mm) and funnels (z = 160 mm) is 220 mm — sufficient clearance for the tether cable to exit above the funnel without fouling.
## 4.3 Drum Axis Correction
Drum spool axis corrected to parallel-to-face (tangential), not perpendicular. Cable wraps around the spool and unspools radially outward through the face guide roller. The specification text in SEL-SW-SUB-001 Rev A §5 ("Drum axis horizontal, perpendicular to pentagonal face") must be corrected to: "Drum axis horizontal, parallel to pentagonal face (tangential). Tether exits radially outward through PEEK guide roller on the face."
# 5. Change 3 — ISRU Process Update
## 5.1 Dump Cycle Timing (SEL-ISRU-001 §6.1)
Update the batch dump description in §6.1 to include the pre-heat and purge phases. The total dump cycle time increases from ~1.4 hr to ~1.45 hr (additional 3 min purge). Cycle availability decreases negligibly from 97.1% to 96.8%.
## 5.2 New Process Step: Pipe Purge
Add the following step to the MOLE-I dump cycle sequence in ISRU-001 §6.1, after the existing "valve closes" step:
Step F (new) — Pipe purge: After the drain valve closes, the rear drain pipe trace heater (15 W) remains active for 3 minutes. Residual water in the 1,350 mm horizontal pipe section drains under gravity (1/6 g, pipe slopes ~2° toward rear nozzle) and any remaining film evaporates in the vacuum at the nozzle exit. After 3 minutes the pipe interior is confirmed clear (no capacitive level feedback required — the pipe geometry and heating time are deterministic). The trace heater is then de-energised and the pipe returns to ambient 40 K passively.
⚠ If the post-dump purge is interrupted (e.g. power glitch), residual water in the pipe will freeze. This is recoverable: the next pre-heat cycle (step 1, 15 W for ~30 min) will melt any ice plug before the next dump. However, repeated freeze-thaw cycling on the Ti pipe walls should be assessed for fatigue — flag for materials review.
# 6. Document-Level Change Instructions
## 6.1 SEL_MOLEI_DESIGN v3 → v4
- §4.5 Water Tank & Dump System: Replace "Bottom-drain valve. MOLE-I drives onto sub-station docking cradle, valve opens, water gravity-feeds (1/6 g) through heated funnel" with description of rear-routed pipe, nozzle exit, and heated dump cycle (steps 1–5 above).
- §4.7 Power Receptacle & Tether Interface: Add note that the drain nozzle (PIP-005) exits ~80 mm lateral to the receptacle boss. No interference — receptacle is rear-centre, nozzle is rear-offset.
- Power budget table: Add row — "Rear drain pipe heater | 15 W | INTERMITTENT (dump cycle only) | ~1.7 W average". Update total keep-alive (unchanged — heater off during keep-alive).
- Add PIP-004, PIP-005, PIP-030 to parts list with masses: elbow ~0.1 kg, nozzle ~0.15 kg, heater ~0.05 kg. Total dry mass: +0.3 kg → 360.3 kg.
## 6.2 SEL-SW-MOLEI-001 Rev B → Rev C
- §11.1 Drain Pipe: Rewrite routing description. PIP-001 (vertical, WEB interior) and PIP-002 (PEEK coupler) unchanged. PIP-003 becomes 1,350 mm horizontal run along chassis bottom rail. Add PIP-004 (elbow), PIP-005 (nozzle), PIP-030 (heater).
- §11.1 Add SolidWorks routing instructions: Swept Boss along chassis bottom rail reference plane, Ti material, saddle clip mates at 300 mm intervals.
- §13 Harness Assembly: Update conductor count 51 → 53. Add 2× AWG 22 (pipe heater) to harness table with 100 mm Manganin transition.
- §8.2 WEB Internal Components: Add pipe heater control circuit to avionics description (tank level sensor threshold at 90% triggers heater relay).
## 6.3 SEL_SUBSTATION_DESIGN v2 → v3
- §4.2 Cable Drum Assemblies: Update mounting height from z = 280 mm to z = 380 mm. Add rationale (matches MOLE-I receptacle height).
- §4.2 Drum axis: Correct "perpendicular to pentagonal face" to "parallel to pentagonal face (tangential)".
- §4.4 Water Handling — Docking Cradles: Confirm funnel at z = 160 mm. Note 220 mm vertical clearance to drums above. Update interface description to reference MOLE-I rear drain nozzle (not mid-chassis bottom exit).
- Add note: "MOLE-I drain exits at rear of rover, adjacent to tether receptacle. Funnel captures water from rear nozzle, not chassis underside."
## 6.4 SEL-SW-SUB-001 Rev A → Rev B
- §5 Phase 2 — Cable Drum Assemblies: Update drum centre height dimension to 380 mm. Update top ring bearing hole position if affected.
- §5 Drum axis: Correct mounting description — spool axis tangential to face.
- §8 Phase 5 — Water Handling: Update docking cradle funnel position to z = 160 mm. Note interface with MOLE-I Rev C rear drain nozzle.
## 6.5 SEL-ISRU-001 Rev C → Rev D
- §6.1 Batch Dump: Add pre-heat trigger (tank ≥ 90%) and post-dump purge (3 min heater hold after valve close). Update cycle timing: 1.4 hr → 1.45 hr. Update cycle availability: 97.1% → 96.8%.
- §6.1 Add Step F (pipe purge) after current Step E (valve close).
- §12 End-to-End Energy Balance: Add 1.7 W average to MOLE-I continuous draw (negligible — note for completeness).
## 6.6 SEL_ROBOT_FLEET v6 → v7
- §4.1 MOLE-I: Update dump mechanism description to rear-exit nozzle with heated pipe.
- §10.4 PSR Charging Station / Sub-station: Update drum height and funnel position. Confirm interface with MOLE-I rear drain.
- MOLE-I dry mass: 360 → 360.3 kg (pipe additions). Wet mass: 410 → 410.3 kg. Negligible — no fleet scaling impact.
# 7. Verification Actions
| # | Action | Owner | Status |
|---|---|---|---|
| 1 | Run MOLEI_THERMAL v1.3 with PIP-030 heater as new thermal path. Verify WEB steady-state unaffected (heater off during drilling). | Abhijay / Jason | OPEN |
| 2 | Verify 15 W heater reaches 280 K within 30 min from 40 K on the 1.35 m pipe. Confirm with ODE45 transient. | Jason (MATLAB) | OPEN |
| 3 | Confirm 3-min purge clears pipe. Estimate residual water mass after valve close (film + drainage lag). Verify evaporation rate in vacuum at 280 K. | Jason | OPEN |
| 4 | Ti fatigue assessment for freeze-thaw cycling on drain pipe (contingency case where purge fails). 15+ year service life target. | Abhijay | OPEN — flag for review |
| 5 | Update substation_3d_render.html and mole_i_3d_render_v2.html to match confirmed geometry. Propagate to substation_design_v3.jsx schematic. | Jason / Vincent | DONE |
| 6 | Update SELENITE_VERIFY v4.5 if MOLE-I average draw changes (expect negligible — 1.7 W on 1,934 W base). | Jason (MATLAB) | OPEN |

# 8. Document History
| Revision | Description |
|---|---|
| ECN-012 v1 | Initial release. Rear drain pipe reroute, substation interface confirmation, dump cycle heating strategy with pre-heat at 90% tank and post-dump purge. March 2026. |

— End of Document —