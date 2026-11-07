<!-- Markdown extract of docs/sources/SEL-CAP-001_CraterAccessPod_RevA.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
Crater Access Pod (CAP)
Pressurised Crew Descent Vehicle for Contingency PSR Access
| Reference | SEL-CAP-001 Rev A |
|---|---|
| Date | March 2026 |
| Author | Jason (Systems Engineering Lead) |
| Phase | Phase 2+ (crew resident). Phase 1 anchor point reservation only. |
| Classification | CONTINGENCY SYSTEM — last-resort human access to PSR |
| Source Docs | SEL_ROBOT_FLEET v8, SEL-CON-001 Rev B, W2_T1_1_JS_MTL_GUIDE v17, NASA xEMU PSR thermal data (ICES-2024-219, ICES-2025-56), JPL CITADEL chamber test reports |

This document specifies the Crater Access Pod (CAP): a pressurised, thermally insulated crew descent vehicle that travels on a dedicated winch system down the Shackleton crater wall, enabling contingency human access to the PSR mining network. The CAP eliminates the need for a 25 K-rated EVA suit during the ~45-minute wall transit, allowing crew to arrive at the basin floor rested, warm, and in an operational state. Once at the floor, crew don xEMU-generation suits (rated to 40 K) for a 2-hour work window before ascending.
# 1. Problem Statement
The Selenite PSR mining network is designed for fully autonomous operation. However, certain failure modes — trunk-to-branch junction leaks, SATS structural failures, spine cable damage, substation WEB replacement in a location where the sled system cannot reach — may require human dexterity to resolve. The programme’s design philosophy is “replace, don’t repair” (dispatch replacement hardware via the winch system), but there exist infrastructure-level failures where the fixturing itself is the failed component and cannot be replaced without disassembly.
The thermal environment presents two distinct challenges. The basin floor operates at 40–90 K — within the xEMU design envelope (NASA: 2-hour exposure limit at 40 K, boot and glove conduction as the sizing cases). The crater wall transit, however, passes through shadow geometries as cold as ≤25 K. At 25 K, conductive heat loss through boot soles and glove contact surfaces scales to roughly 10× the rate at 273 K. The xEMU is not designed for this temperature. Descending the 8.2 km wall in a 25 K-rated suit while maintaining the dexterity needed for repair work is an unsolved engineering problem.
The CAP resolves this by separating the transit problem from the work problem. Crew transit the wall inside a pressurised, heated pod (shirt-sleeve or IVA suit environment). They arrive at the floor, don their 40 K-rated EVA suits, and perform the required work within the 2-hour thermal window. The pod functions as transit vehicle, staging area, shelter, and abort refuge.
# 2. Concept of Operations
| Phase | Activity |
|---|---|
| Pre-descent | Crew board CAP at rim station. Verify pressure seal, life support, comms. EVA suits stowed inside pod. Tools and replacement hardware loaded. Storm weather check (SPE forecast clear for 8+ hours). GATE: Go/No-Go from mission control. |
| Descent | CAP descends on dedicated guide cable at ~3 m/s. Transit time: ~45 minutes for 8.2 km at 30° slope. Crew in IVA suits (shirt-sleeve optional for transit). Pod heated by crew metabolic output + internal electronics (~400 W total vs ~5–10 W MLI loss). Interior at 293 K throughout. Continuous comms via UHF relay to surface. |
| Arrival | CAP docks at floor station (anchor pad adjacent to SATS/CLP node, connected to 1000 VDC trunk for supplemental power). Crew don xEMU suits inside pod. Egress through EVA hatch. |
| Floor ops | Crew perform maintenance/repair in 40 K environment. 2-hour hard limit (xEMU thermal design point). Pod remains pressurised as shelter — crew can return if suit issue arises. Tools pre-positioned by MOLE-I if possible. |
| Ingress | Crew return to pod. Doff EVA suits. Repressurize if needed. Stow equipment. |
| Ascent | CAP ascends at ~3 m/s. ~45 min transit. Crew in warm, pressurised environment. |
| Total | ~4–5 hours rim-to-rim (45 min down + 30 min suit-up + 2 hr work + 30 min de-suit + 45 min up + margins). Life support sized for 6 hours × 2 crew with 50% reserve. |

# 3. Physical Specification
| Parameter | Specification |
|---|---|
| Pressure vessel | Aluminium alloy (Al 7075-T6) cylindrical shell, ~2.0 m diameter × 2.5 m length. Internal volume ~6 m³ (2 crew + suit donning space). 101 kPa N₂/O₂ atmosphere or 65 kPa exploration mix. |
| Thermal insulation | 30+ layer MLI (aluminised Mylar / Dacron). ~10 m² external surface. Radiative + residual conductive loss: ~5–10 W total at 25 K ambient. Crew metabolic heat (~150 W/person × 2 = 300 W) + electronics (~100 W) far exceeds loss. Pod retains heat passively — no active heating required during transit. |
| Contact point isolation | All mechanical suspension interfaces (guide cable brackets, rail contact points) use PEEK or Torlon structural thermal breaks. Design target: <0.5 W conductive leak per contact point. ~4 contact points = ~2 W total. Negligible. |
| Radiation shielding | Crater wall geometry provides directional GCR attenuation during descent (regolith above and lateral). 10 mm polyethylene liner on pod walls for SPE mitigation. Total shielding: ~10–15 g/cm² (vessel wall + PE). SPE abort protocol: ascend immediately if CME forecast (30–60 min NOAA/ESA warning). Dose during 5-hour mission: <0.5 mSv (below daily ISS rate of ~0.5–1 mSv). |
| EVA hatch | Side-mounted, ~0.8 m diameter, inward-opening. Dual O-ring seal. Crew egress/ingress in xEMU suits (xEMU suit width ~0.7 m at shoulders). Hatch faces away from crater wall toward open floor. |
| Life support | 6 person-hours × 2 crew = 12 person-hours with 50% reserve = 18 person-hour capacity. O₂ supply: high-pressure bottles (~4 kg O₂). CO₂ scrubbing: LiOH canisters (2 kg). Temperature: passive retention + small fan circulator. Humidity: condensing heat exchanger. Total ECLSS mass: ~120 kg. |
| Comms | UHF relay to surface via substation network (existing infrastructure). Hardline comm through guide cable (backup). Video feed from internal + external cameras to surface ops hub. |
| Power (transit) | Battery: ~2 kWh Li-ion (inside pod, 293 K). Powers lighting, comms, fans, monitoring during descent/ascent. Mass: ~8 kg at 250 Wh/kg. |
| Power (floor ops) | 1000 VDC tap from SATS/CLP trunk cable via umbilical. DC-DC converter in pod floor station provides 28 V for pod systems + EVA suit recharge. Unlimited duration at floor (power not the constraint — suit thermal is). |
| Guide cable | Dedicated Kevlar guide cable, 8.5 km, ~12 mm diameter. Separate from trunk power cable and pipeline. Rim-anchored with dedicated powered winch (IW-CAP). Cable tension at full load: ~1,050 N. Design with 5× safety factor: 5,250 N. |
| Descent speed | ~3 m/s (crew transport standard, comparable to mine cage practice). Transit: 8,200 m ÷ 3 m/s = 2,733 s ≈ 45 min each way. |
| Winch | Dedicated IW-CAP winch at rim. ~1.7 kW at 3 m/s and 1,400 kg loaded. Redundant braking: mechanical failsafe + regenerative. Independent from all MOLE-I and infrastructure winches. Crew-rated: design, test, and certification to human spaceflight standards. |

# 4. Mass Budget
| Component | Mass (kg) | Notes |
|---|---|---|
| Pressure vessel (Al 7075) | 350 | Cylindrical, 2.0 × 2.5 m |
| MLI + internal thermal | 60 | 30-layer, 10 m² |
| Life support (18 person-hr) | 120 | O₂, LiOH, fans, HX |
| EVA hatch + sealing | 80 | Dual O-ring, inward |
| Guide cable interface + suspension | 100 | PEEK thermal breaks |
| Radiation shielding (PE liner) | 40 | 10 mm polyethylene |
| Comms, lighting, monitoring | 30 | UHF + cameras + displays |
| Transit battery (2 kWh) | 8 | Li-ion at 250 Wh/kg |
| Structure margins + contingency (8%) | 60 |  |
| DRY POD TOTAL | ~848 kg |  |
| 2 crew (suited IVA) | 200 | 100 kg each |
| 2 xEMU suits (stowed) | 260 | 130 kg each |
| Tools + replacement hardware | 100 | Mission-dependent |
| LOADED TOTAL | ~1,408 kg | Within IW-CAP capacity |

# 5. Phase 1 Reservations
The CAP itself is Phase 2+ infrastructure (requires resident crew). However, Phase 1 construction must reserve the following to avoid costly retrofitting:
- Guide cable anchor points on the crater wall traverse: 4–6 intermediate anchor positions (every ~1.5 km along the 8.2 km descent route). These are Ti screw anchors driven by the construction MOLE-I during Phase 1 branch build-out, at designated coordinates offset from the trunk cable route. No cable installed — just the anchor sockets.
- Rim winch pad: A prepared, levelled pad adjacent to the IW-1/IW-2 infrastructure winch stations. SINTER builds this during Phase 1 surface construction. No winch installed — just the foundation.
- Floor docking pad: A flat anchor plate at the CLP adjacent to the SATS+WEB, with 4× Ti screw anchors and a 1000 VDC power tap bayonet socket. Installed during Phase 1 SATS deployment. Mass: ~5 kg.
- Cable routing clearance: The trunk cable, pipeline, and branch infrastructure must leave a ~2 m lateral corridor for the future CAP guide cable. This is a layout constraint, not hardware.
⚠ If Phase 1 anchor points are not reserved, retrofitting them in Phase 2 requires sending a MOLE-I back along the completed crater wall infrastructure to drive new stakes — feasible but disruptive to ongoing mining operations. The Phase 1 reservation adds <10 kg of hardware and zero schedule impact.
# 6. What the CAP Does Not Solve
- Floor EVA thermal limits: Crew still need 40 K-rated xEMU suits for basin floor work. The CAP provides transit and shelter, not floor thermal protection. The 2-hour xEMU limit at 40 K is the hard constraint on work duration.
- Glove dexterity: Current xEMU gloves at 40 K provide substantially degraded fine manipulation. Task design for human intervention should favour coarse operations (physical disconnection, module extraction/insertion, bayonet engagement) rather than fine assembly (soldering, small fastener manipulation).
- 25 K wall EVA: If a failure occurs on the wall itself (not the floor), crew cannot exit the pod at 25 K. Wall-mounted infrastructure must be either accessible from inside the pod via a manipulator arm extension (future upgrade) or replaced by lowering new hardware from the rim on the trunk cable.
# 7. Dual-Use Before Crew Arrival
Before Phase 2 crew arrival, the CAP descent infrastructure (guide cable + floor docking pad) can be used as a logistics path. An unpressurised cargo frame riding the same guide cable could deliver replacement WEB modules, substation components, or construction material pallets to the PSR floor without consuming IW winch cycles. This would deconflict the infrastructure winch schedule during Phase 4+ scaling when multiple branches are being built simultaneously.
# 8. Open Items
| # | Item | Owner | Status |
|---|---|---|---|
| 1 | xEMU boot sole thermal performance data from JPL CITADEL chamber testing. Results not yet published. Required to confirm 2-hour floor limit at 40 K. | Jason (monitor NASA) | OPEN — awaiting NASA |
| 2 | Detailed thermal model of CAP contact points at 25 K. Verify PEEK thermal break performance at guide cable bracket. | Jason (MATLAB) | OPEN |
| 3 | SPE abort timeline: confirm 45-min ascent + 30-min warning provides adequate dose margin. Model GCR + SPE accumulated dose for 5-hour mission profile. | Oluchi / Rahnuma | OPEN |
| 4 | Floor docking pad design: anchor pattern, power tap, pod retention mechanism. Must survive 40 K permanently with zero maintenance. | Grant | OPEN |
| 5 | Crew-rated winch certification requirements. Mining cage standards (AS/NZS 3785, EN 14502) as starting point, adapted for lunar vacuum + cryogenic cable. | Jason / Grant | OPEN |

# 9. Document History
| Rev | Description |
|---|---|
| Rev A | Initial release. Pressurised crew descent pod for contingency PSR access. Concept, specifications, mass budget, Phase 1 reservations, open items. March 2026. |

— End of Document —