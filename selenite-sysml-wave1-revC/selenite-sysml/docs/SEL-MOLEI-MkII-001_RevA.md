<!-- Markdown extract of docs/sources/SEL-MOLEI-MkII-001_RevA.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
MOLE-I Mk II — Deep Drill Retrofit Kit
Engineering Design Specification
Reference: SEL-MOLEI-MkII-001 Rev A
Source Documents: SEL_MOLEI_DESIGN v5 (Mk I baseline), SEL_ROBOT_FLEET v9 (§4), ECN-019 Rev C, SEL-ISRU-001 Rev D (pipeline interface). Heritage: ESA PROSPECT (lunar drill, TRL 5–6), IODP/DSDP (deep ocean floor drilling, segmented drill string, TRL 9), terrestrial diamond core drilling (segmented auger, 10–50 m depth in permafrost, TRL 9), Mars InSight HP³ (percussive mole, TRL 7).
# 1. Overview
The MOLE-I Mk II is a field-retrofit kit that upgrades existing MOLE-I Mk I ice extraction rovers from 0.3–0.5 m drilling depth to 10 m. The retrofit addresses ice depletion at shallow depth: after decades of continuous extraction, the near-surface ice layer (top 0.5 m) in heavily-worked substation sectors becomes depleted. Deeper ice deposits (1–10 m) remain accessible but require a drill system that the Mk I was not designed to reach.
The retrofit kit consists of four components installed on the existing MOLE-I chassis by ARM-D at the SPA IZ maintenance bay: (1) a telescoping drill guide mast that stows horizontally and pivots to vertical for drilling, (2) a segmented auger drill string that extends incrementally as the borehole deepens, (3) a 4-leg outrigger stabilisation system that prevents tipping during deep drill operations, and (4) a bellows dust shroud that seals the borehole collar from regolith contamination. The existing mini-VEX thermal extraction system is retained unchanged — the drill string is hollow, and sublimated water vapour rises through the auger bore to the existing condensation system.
The Mk II retrofit does not change the MOLE-I’s mobility, navigation, tether interface, power interface, or operational concept. It changes only the drilling subsystem and adds outrigger stabilisation. A retrofitted unit operates identically to a Mk I in all respects except drill depth capability. Both Mk I and Mk II units coexist in the same fleet — Mk II units are deployed to sectors with confirmed deep ice and depleted surface ice.
# 2. Drill Guide Mast
## 2.1 Configuration
| Parameter | Specification |
|---|---|
| Type | Telescoping 3-section guide mast. Titanium Grade 5 (Ti-6Al-4V) tubing. Outer section: 120 mm OD × 2 mm wall. Middle section: 100 mm OD. Inner section: 80 mm OD. Each section ~3.5 m long. Extended height: 10.2 m (3 × 3.4 m active travel). Retracted length: ~3.6 m. |
| Stowed position | Horizontal, cradled along the MOLE-I chassis top rail (existing equipment rail). Secured by 3× spring-loaded clamps. Mast CG at ~1.8 m from pivot — within the rover’s wheelbase. Does NOT extend beyond the existing chassis footprint when stowed. |
| Deployment | Single pivot hinge at chassis rear (above rear axle). Motorised: 28 VDC gear motor (10 W, 90° rotation in ~60 s). Mast swings from horizontal stow (0°) to vertical drilling position (90°). Telescoping sections extend under motor drive after mast reaches vertical: rack-and-pinion linear actuator inside each section, 10 W per section. Full deployment (horizontal → vertical → fully extended): ~5 min. |
| Retraction | Reverse sequence: sections retract (inner first, then middle), mast pivots to horizontal. Full retraction: ~5 min. MOLE-I does NOT drive with mast deployed — mast must be fully retracted and clamped before transit. |
| Mass | Mast assembly: ~45 kg (3 Ti sections ~30 kg + pivot hinge ~5 kg + linear actuators ~8 kg + clamps ~2 kg). |
| Drill guide bore | Inner section terminates in a precision bore guide (80 mm ID) that centres the auger drill string and constrains lateral deflection. Guide bearing: PTFE-lined bushing (cryogenic-rated, no lubrication required at 40–90 K). Auger runs inside the guide bore for the full mast length, preventing buckling. |
| Cryogenic compatibility | All Ti Grade 5 — ductile to 20 K. No embrittlement concern. Actuator motors: SmCo brushless DC (same as MOLE-I wheel motors). Grease-free bearings (MoS₂ dry lubricant, vacuum-rated, cryo-compatible). |

## 2.2 Structural Analysis
At 10 m extension with the auger drilling at depth, the mast experiences: (a) axial compression from drill thrust (~50 N downforce via drill motor), (b) lateral vibration from rotary-percussive action, and (c) gravitational load (mast weight in 1/6 g: ~45 kg × 1.62 m/s² = ~73 N, acting as compression). Total axial load: ~123 N. Ti Grade 5 column at 10 m with 80 mm OD × 2 mm wall: Euler buckling load ~2,400 N (pinned-pinned, E=114 GPa, I=π/64×(0.08⁴−0.076⁴)). Safety factor: ~20×. The telescoping sections reduce this (joints are weak points), but with PTFE guide bearings at each joint constraining lateral deflection, effective buckling length is reduced to ~3.5 m per section, yielding buckling load >10,000 N per section. Structural margin is ample.
Tipping moment: mast CG when vertical is at ~5 m above chassis (~5 m × 73 N = 365 N·m tipping moment). MOLE-I wheelbase: ~1.2 m. Vehicle weight: ~575 kg × 1.62/6 ≈ 155 N per side. Restoring moment from vehicle weight alone: 155 × 0.6 m = 93 N·m. INSUFFICIENT — vehicle would tip without outriggers. The outrigger system (§4) is therefore a HARD REQUIREMENT, not optional.
# 3. Segmented Auger Drill String
| Parameter | Specification |
|---|---|
| Type | Hollow segmented auger. Each segment: 500 mm long, 60 mm OD, 30 mm ID (hollow bore for water vapour extraction). WC (tungsten carbide) cutting teeth on leading segment only (remaining segments are flighted auger for cuttings removal). Quick-connect bayonet coupling between segments (same SEL-MI-CON-001 bayonet profile as construction tap connectors — standardised 20 mm twist-lock, scaled to 60 mm). |
| Segments carried | 20 segments × 500 mm = 10 m total depth. Stored in a vertical rack on the mast structure (segments clip into spring-loaded slots along the outer mast section when stowed). When mast deploys to vertical, rack is accessible to the auto-feed mechanism. |
| Segment mass | ~2.5 kg each (auger flight + steel tube + bayonet coupling). 20 segments: 50 kg total. Leading segment with WC teeth: ~3.5 kg. Spare leading segment: 1 carried. |
| Auto-feed mechanism | Motorised segment feeder at mast top. When the current leading segment has drilled its 500 mm stroke, the drill motor retracts the string 100 mm (clearing the bayonet), the feeder rotates the next segment from the rack into alignment, engages the bayonet coupling (motorised twist, same SEL-MI-CON-001 mechanism), and the drill resumes. Cycle time: ~90 s per segment addition. Fully autonomous — SENTINEL commands segment addition when drill depth sensor indicates 500 mm advance. |
| Cuttings removal | Auger flights lift cuttings upward through the borehole. In 1/6 g, the reduced gravitational settling helps — cuttings are more easily lofted by auger rotation. At 10 m depth, the auger flight path is 10 m long. Rotation at 200 RPM with 60 mm flight pitch: upward velocity ~0.2 m/s. Transit time surface to bottom: ~50 s. Cuttings discharge at surface collar into the existing mini-VEX feed chute via a deflector plate. |
| Water vapour extraction | The auger bore (30 mm ID) serves as the vapour extraction conduit. Mini-VEX heating at the drill bit sublimes ice; vapour rises through the hollow bore (driven by sublimation pressure differential + 1/6 g buoyancy in the borehole atmosphere). At 10 m depth, the vapour path is longer than the current 0.3–0.5 m, but the mini-VEX’s 1,200 W heating power creates sufficient pressure differential to drive vapour extraction. Recovery rate may decrease ~10–15% vs surface drilling due to heat loss along the 10 m bore — accepted. |
| Drill motor | Existing 200 W rotary-percussive motor retained. Torque transmitted through auger string via bayonet couplings. At 10 m depth, torsional compliance in 20 bayonet joints may reduce percussive energy transmission. Mitigation: percussive action is primarily at the WC bit (self-contained percussive mechanism in the leading segment, powered by 200 W motor via the auger shaft). The leading segment contains a cam-driven percussive hammer (50 Hz) that operates independently of string length. |
| Drill rate at depth | Surface rate: 25 kg/hr (Mk I). At 10 m depth: estimated 15–20 kg/hr (reduced by cuttings transit time, slight energy loss in joints, increased heat loss). Accepted — deep ice is accessed only when surface ice is depleted, so reduced rate is better than no ice. |

⚠ The hollow auger bore simultaneously serves two functions: (1) cuttings removal via auger flights on the exterior, and (2) water vapour extraction via the hollow interior. This dual-function design eliminates the need for a separate vapour extraction pipe alongside the auger, simplifying the drill string and reducing borehole diameter requirements.
# 4. Outrigger Stabilisation System
| Parameter | Specification |
|---|---|
| Configuration | 4× deployable outrigger legs, mounted at the 4 corners of the MOLE-I chassis. Each leg: telescoping Ti tube, 40 mm OD, extends 1,500 mm laterally from chassis + 500 mm downward. Foot: 200 mm dia sintered-surface pad with 3× regolith-engaging spikes (50 mm depth, prevents lateral sliding). |
| Deployment | Motorised: 28 VDC SmCo BLDC motor per leg (5 W, 30 s to deploy). Extends laterally first (horizontal), then downward (vertical). Foot presses into regolith surface with ~50 N preload per leg (spring-loaded final 50 mm of stroke). Total footprint with outriggers deployed: ~4.2 m × 4.2 m (vs ~1.2 m × 0.8 m chassis). |
| Stabilisation moment | With 4 outriggers at 2.1 m from chassis centre, each providing 50 N downforce: restoring moment = 4 × 50 N × 2.1 m = 420 N·m. Mast tipping moment: 365 N·m. Safety factor: 420/365 = 1.15× from outriggers alone. Combined with vehicle weight restoring moment (93 N·m): total restoring = 513 N·m vs 365 N·m tipping. Safety factor: 1.4×. Additionally, the tether provides ~20–50 N downward tension at the substation end, adding ~30–75 N·m restoring (tether attaches at rear, ~1.5 m from tipping axis). Effective safety factor: ~1.5×. Sufficient for drilling operations (static loads; no dynamic shocks at 50 Hz percussive). |
| Retraction | Full retraction in ~30 s. MOLE-I does NOT drive with outriggers deployed. Sequence: retract outriggers → retract mast → transit. |
| Mass | 4 legs: ~32 kg total (8 kg each including motor, tube, foot, spikes). Chassis mounting brackets: ~8 kg. Total outrigger system: ~40 kg. |
| Cryogenic compatibility | Ti Grade 5 tubes, SmCo motors, MoS₂ dry bearings. All rated to 20 K. Regolith spikes: hardened steel (cryogenically stable). |

Operational note: the outriggers also serve as anti-tip protection during the mast pivot sequence (horizontal → vertical). The tipping moment is highest during the pivot at ~45° (maximum horizontal CG offset). SENTINEL commands outrigger deployment BEFORE mast pivot begins. Sequence: park → deploy outriggers → pivot mast → extend telescope → drill.
# 5. Dust Shroud and Borehole Collar
| Parameter | Specification |
|---|---|
| Bellows shroud | Flexible PTFE bellows seal, 150 mm OD × 300 mm retracted / 3,000 mm extended. Mounts at the mast base (pivot hinge level) and seals around the mast outer section. As the mast extends through the surface, the bellows extends with it, preventing regolith dust from entering the mechanism from the top. |
| Borehole collar | Rigid Ti collar ring (150 mm ID, 200 mm OD, 100 mm tall) placed on the regolith surface at the drill point before drilling begins. MOLE-I’s existing scraper/placement arm (mini-VEX feed arm) positions the collar. The collar prevents borehole wall collapse at the surface and provides a seal seat for the bellows bottom edge. Collar mass: ~0.8 kg. 5 carried as consumables (left at each drill site). |
| Dust protection | The bellows + collar system creates a sealed annulus around the drill string from surface to mast base. Prevents: (a) regolith dust from fouling the telescoping mast sections and guide bearings, (b) sublimated water vapour from escaping the borehole before reaching the mini-VEX condenser, (c) thermal radiation from entering the borehole (maintains colder temperature at depth for better ice preservation during drilling). |
| Cryogenic compatibility | PTFE bellows: rated to 20 K, >1M flex cycles. Same material as MOLE-I wheel labyrinth seals (proven in Mk I). Ti collar: standard cryogenic material. |
| Mass | Bellows: ~2 kg. 5 collars: ~4 kg. Total: ~6 kg. |

# 6. Mass and Power Impact
## 6.1 Mass Budget
| Component | Mk I Baseline | Mk II Retrofit Addition |
|---|---|---|
| Drill system | ~15 kg (drill motor + bit + chute) | ~15 kg existing + 50 kg auger segments + 3.5 kg leading segment + 5 kg auto-feed mechanism = +58.5 kg |
| Drill guide mast | N/A (no mast) | ~45 kg (mast + pivot + actuators + clamps) |
| Outrigger system | N/A | ~40 kg (4 legs + brackets) |
| Dust shroud | N/A | ~6 kg (bellows + 5 collars) |
| Counterweight | N/A | ~15 kg (ballast block at chassis front, opposite mast pivot, further improves restoring moment by +24 N·m) |
| TOTAL | ~360.65 kg | ~360.65 + 164.5 = ~525 kg |

Mass increase: +164.5 kg (+46%). The MOLE-I’s mobility system (6-wheel rocker-bogie, SmCo motors) is rated for 500 kg loaded mass (360 kg dry + 140 kg margin for regolith in hopper and drill cuttings). At 525 kg the vehicle is within the mobility envelope but with reduced margin. In 1/6 g, the ground pressure increase is small (~0.3 kPa → ~0.4 kPa on sintered surface). No wheel or suspension modifications required. Tether power draw is unchanged (all new motors are low-duty intermittent: mast deploy/retract ~5 min per drill site, outriggers ~30 s).
## 6.2 Power Budget
| Parameter | Specification |
|---|---|
| Drill motor | 200 W (unchanged — existing motor retained) |
| Mast deployment | 10 W pivot + 10 W per telescope section = 30 W peak (intermittent, ~5 min per deployment) |
| Outrigger deployment | 5 W per leg × 4 = 20 W peak (intermittent, ~30 s) |
| Auto-feed mechanism | 10 W (intermittent, ~90 s per segment addition, 20 events per 10 m borehole) |
| Continuous drilling | 200 W (same as Mk I — drill motor is the only continuous power consumer) |
| Impact on tether load | Mk I: ~1,934 W at tether. Mk II: ~1,934 W during continuous drilling (unchanged). Peak during mast deployment: ~1,964 W (+30 W, <2% increase). Within substation power budget. |

# 7. Operational Concept
## 7.1 When to Deploy Mk II
Mk II retrofit is applied to MOLE-I units assigned to substation sectors where SENTINEL’s drill grid database shows surface ice depletion (measured yield <50% of initial yield across >80% of the sector’s 3,600 drill grid cells at 0.3–0.5 m depth). This indicates the shallow ice layer has been substantially extracted and deeper reserves must be accessed. SENTINEL recommends Mk II retrofit; SPA crew approves. The unit is winched to the surface, transported to IZ maintenance bay, retrofitted by ARM-D (~8 hr), returned to the rim, and redeployed to its substation.
## 7.2 Deep Drill Cycle
| Step | Duration | Details |
|---|---|---|
| 1. Position at drill point | ~10 min | Same as Mk I. Drive to next grid cell within 200 m sector. |
| 2. Deploy outriggers | ~30 s | 4 legs extend and engage regolith. Vehicle stabilised. |
| 3. Place borehole collar | ~5 min | Mini-VEX feed arm places Ti collar ring on surface at drill point. Collar seated by gentle press (~20 N). |
| 4. Pivot mast to vertical | ~60 s | Mast swings from horizontal stow to 90° vertical. Bellows shroud engages collar. |
| 5. Extend first telescope section | ~30 s | Inner mast section lowers through collar. First auger segment (WC cutting head) engages surface. |
| 6. Drill first 500 mm | ~20 min | Rotary-percussive at 200 W. Mini-VEX heating activates. Cuttings removed via auger flight. Water vapour rises through hollow bore to condenser. |
| 7. Add next auger segment | ~90 s | Auto-feed: retract string 100 mm, rotate next segment from rack, engage bayonet, resume drilling. |
| 8. Repeat steps 6–7 | ~7 hr total | 19 more segments × (20 min drill + 1.5 min add) = ~7 hr to reach 10 m. Drill rate decreases slightly with depth (~25 kg/hr at surface → ~15 kg/hr at 10 m). Average: ~20 kg/hr. |
| 9. Extract water at depth | ~4 hr | Mini-VEX heating continues at full 1,200 W at final depth. Sublimation + vapour extraction through 10 m bore. Rate: ~80% of surface rate (~6.3 kg/hr water vs ~7.8 kg/hr Mk I surface). Run until water yield drops <50% of initial (indicating local ice depleted at this depth). Duration: typically 3–5 hr. |
| 10. Retract drill string | ~30 min | Auger segments retracted and disconnected one at a time (reverse of step 7). Segments returned to rack. String fully retracted. |
| 11. Retract mast + outriggers | ~6 min | Telescope retracted. Mast pivots to horizontal. Outriggers retracted. Collar left in place (consumable). |
| 12. Transit to next position | ~10 min | Drive to next grid cell. Repeat from step 2. |
| TOTAL per deep drill cycle | ~12–14 hr | Vs ~46 hr for Mk I shallow cycle (which includes 44.8 hr continuous drilling at 0.3–0.5 m). Mk II cycles faster per position but extracts ice from deeper, less-depleted reserves. Net throughput per unit: similar to Mk I on fresh surface ice. |

## 7.3 Mixed Fleet Operations
Mk I and Mk II units coexist in the same fleet. Typical deployment: a substation with 5 MOLE-I units might have 3× Mk I (surface drilling in un-depleted grid cells) and 2× Mk II (deep drilling in depleted cells). SENTINEL assigns drill targets based on grid cell depletion status: fresh cells → Mk I, depleted cells → Mk II. As a sector ages, the ratio shifts toward more Mk II. All units share the same substation, tether infrastructure, and SENTINEL fleet management — no infrastructure changes required.
# 8. Retrofit Installation
| Parameter | Specification |
|---|---|
| Location | SPA IZ maintenance bay (same facility used for MOLE-I routine maintenance and ORU swaps). |
| Performed by | ARM-D. Standard ORU swap procedures. No crew EVA required. |
| Duration | ~8 hr: (1) remove existing drill head and chute (~30 min), (2) install mast pivot hinge on chassis rear rail (~1 hr), (3) mount mast assembly and clamps (~1 hr), (4) install outrigger brackets and legs (~2 hr), (5) mount auger segment rack and auto-feed mechanism (~1 hr), (6) install bellows shroud (~30 min), (7) mount counterweight block (~30 min), (8) functional test: deploy/retract mast, deploy/retract outriggers, spin drill motor with test segment (~1 hr). |
| Reversibility | Fully reversible. Retrofit kit can be removed and MOLE-I returned to Mk I configuration in ~4 hr. Useful if deep drilling is no longer needed at a particular substation (ice survey finds better surface deposits elsewhere). |
| Retrofit rate | ~1 unit per day with single ARM-D bay. Multiple bays can work in parallel. |
| First retrofit | Estimated ~Y30 (P7+). Surface ice at earliest-worked substations (P3-era deployment, ~26 years of continuous extraction) may approach depletion at 0.3–0.5 m depth by this time. Exact timing depends on ice concentration heterogeneity and extraction rate per sector. |

# 9. Failure Modes
| Failure Mode | Response | Impact |
|---|---|---|
| Mast pivot motor failure | Mast stuck in current position. If vertical: complete current borehole, then retract auger manually (SENTINEL commands segment-by-segment reverse). ARM-C dispatched to assist mast retraction if motor replacement not possible in-situ. If horizontal (stowed): unit operates as Mk I (surface drilling only) until next maintenance window. | MED — unit reverts to Mk I capability. |
| Auger segment bayonet jam | Auto-feed mechanism cannot engage/disengage segment. Drill operations halted at current depth. Retract all segments above the jam. Stuck segment remains in borehole (abandoned). Move to next drill position with reduced segment count (e.g., 18 segments = 9 m max depth). ARM-D replacement of jammed segment at next surface maintenance. | LOW — degraded depth, operations continue. |
| Outrigger failure (1 leg) | 3 remaining legs provide reduced stability. Tipping safety factor drops from 1.5× to ~1.15× (marginal). SENTINEL restricts drilling to 7 m max depth (reduced mast extension → reduced tipping moment). Full depth restored after leg replacement. | LOW — reduced depth. |
| Outrigger failure (2+ legs) | Insufficient stabilisation for any mast deployment. Unit reverts to Mk I surface drilling only until repaired. SENTINEL flags for maintenance. | MED — reverts to Mk I. |
| Bellows rupture | Dust ingress into mast mechanism. Water vapour escapes borehole (reduced recovery). Continue current borehole at reduced efficiency. Replace bellows at next maintenance window (~30 min ARM-D swap). Carry 1 spare bellows per unit. | LOW — degraded efficiency. |
| Drill string buckling at depth | Unlikely (safety factor >20×). If observed: retract immediately, inspect mast guide bearings for wear. Replace worn bearing bushings (ORU). | VERY LOW — design margin. |

# 10. Retrofit Kit Parts List
| Item | Description | Qty | Mass ea. | Total kg | Source |
|---|---|---|---|---|---|
| SEL-MI-MST-001 | Telescoping drill mast (3 Ti sections + guide bearings) | 1 | 30 kg | 30 | Earth |
| SEL-MI-PIV-001 | Mast pivot hinge + 28 VDC motor | 1 | 5 kg | 5 | Earth |
| SEL-MI-ACT-001 | Telescope linear actuator (rack-and-pinion) | 3 | 2.7 kg | 8 | Earth |
| SEL-MI-CLP-001 | Mast stow clamp (spring-loaded) | 3 | 0.7 kg | 2 | In-situ (P10+) |
| SEL-MI-AUG-001 | Auger segment (flighted, 500 mm, hollow bore) | 19 | 2.5 kg | 47.5 | In-situ (P10+) |
| SEL-MI-AUG-002 | Leading auger segment (WC cutting head) | 2 | 3.5 kg | 7 | Earth |
| SEL-MI-AFD-001 | Auto-feed mechanism (motorised, with segment rack) | 1 | 5 kg | 5 | Earth |
| SEL-MI-OLG-001 | Outrigger leg assembly (tube + motor + foot + spikes) | 4 | 8 kg | 32 | In-situ (P10+) |
| SEL-MI-OBR-001 | Outrigger chassis bracket | 4 | 2 kg | 8 | In-situ (P10+) |
| SEL-MI-BEL-001 | PTFE bellows shroud (150 mm, 3 m extended) | 2 | 1 kg | 2 | Earth |
| SEL-MI-COL-001 | Ti borehole collar ring (150 mm ID) | 5 | 0.8 kg | 4 | In-situ (P10+) |
| SEL-MI-BAL-001 | Counterweight ballast block (sintered Fe-Ni) | 1 | 15 kg | 15 | In-situ |
|  |  |  | TOTAL | 165.5 |  |

In-situ manufactured components (P10+): auger segments (lunar steel), outrigger legs (lunar Ti), brackets (lunar Al), collars (lunar Ti), counterweight (asteroid Fe-Ni or sintered regolith). Earth-supplied: WC cutting heads, precision actuators, auto-feed mechanism, bellows. Earth fraction: ~57 kg / 165.5 kg = ~34% by mass. At P10+ in-situ manufacturing maturity, only precision/specialty items require Earth supply.
# 11. Document History
| Rev | Description |
|---|---|
| A | Initial release. MOLE-I Mk II deep drill retrofit kit specification. Upgrades drilling depth from 0.3–0.5 m to 10 m. Telescoping 3-section Ti drill guide mast (3.6 m stowed horizontal, 10.2 m deployed vertical, pivot hinge at chassis rear). Segmented hollow auger drill string (20 × 500 mm segments, WC cutting head, bayonet quick-connect, auto-feed mechanism, ~90 s per segment addition). 4-leg outrigger stabilisation system (4.2 m deployed footprint, ~420 N·m restoring moment, safety factor 1.5×). PTFE bellows dust shroud + Ti borehole collar. Mass: +164.5 kg (360 → 525 kg). Power: +30 W peak intermittent (deployment only; drilling unchanged at 200 W). Deep drill cycle: ~12–14 hr per 10 m borehole. Drill rate at depth: ~15–20 kg/hr (vs 25 kg/hr surface). Retrofit by ARM-D in ~8 hr, fully reversible. Mixed Mk I/Mk II fleet operations on shared substations. First retrofit estimated ~Y30 (P7+). 10 retrofit kit components, ~34% Earth-supplied by mass. April 2026. |

— End of Document —