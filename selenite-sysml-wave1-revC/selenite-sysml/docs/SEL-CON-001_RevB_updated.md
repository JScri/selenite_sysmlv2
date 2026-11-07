<!-- Markdown extract of docs/sources/SEL-CON-001_RevB_updated.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
PSR Construction Logistics Specification
Winch Scheduling, Material Manifest, Construction MOLE-I Interfaces, and Deployment Procedures
| Reference | SEL-CON-001 Rev A |
|---|---|
| Date | March 2026 |
| Author | Jason (Systems Engineering Lead) |
| Source Docs | SEL_ROBOT_FLEET v7, SEL_MOLEI_DESIGN v4, SEL_SUBSTATION_DESIGN v3, SEL-SW-SUB-001 Rev B, SEL-ISRU-001 Rev D, W2_T1_1_JS_MTL_GUIDE v16, SEL-ECN-012 |
| Status | DRAFT — for review |

This document specifies the construction logistics for deploying and commissioning the bilateral fishbone mining network inside Shackleton Crater’s Permanently Shadowed Region (PSR). It closes six identified gaps in the existing documentation: winch scheduling and capacity, construction material descent manifest, construction MOLE-I mechanical interfaces, trunk pipe vs spine cable sequencing, branch pipe pressure rating, and substation guy wire installation. All procedures are autonomous with remote human approval gates.
# 1. Rim Winch System — Capacity and Scheduling
## 1.1 Winch Types
Two distinct winch types are required. Existing documentation conflates these under a single “descent winch” label, but the load profiles and duty cycles are fundamentally different.
| Parameter | Infrastructure Winch (IW-1) | Unit Winch (UW-series) |
|---|---|---|
| Function | Lower cable/pipe bundles, substation sleds, construction material pallets to CLP | Lower individual MOLE-I units to CLP |
| Speed | 0.1 m/s (23 hr for 8.4 km) | 0.5 m/s (4.7 hr for 8.4 km) |
| Max payload | 500 kg (substation sled + margin) | 420 kg (MOLE-I wet + margin) |
| Cable | Kevlar, 8.5 km, 12 mm dia | Kevlar, 8.5 km, 8 mm dia (one per unit) |
| Qty at rim | 2 (redundancy + parallel ops) | 1 per MOLE-I at initial deployment (P3: 10; P4: 25) |
| Power | 0.82 kW at 500 kg (1/6 g) | 0.43 kW per unit (FLEET v7) |
| Rim anchor | 4× Ti screw anchors in regolith + sintered pad (SINTER-built) | Individual anchor per winch, installed by MOLE-S |

## 1.2 Winch Scheduling — P3 Initial Deployment
P3 configuration requires: 1 trunk cable/pipe bundle, 2 branch cable/pipe bundles, 2 substations, 10 MOLE-I units, plus construction material pallets. With 2 infrastructure winches and 10 unit winches, the bottleneck is the infrastructure winch.
| # | Payload | Winch | Duration | Mass | Notes |
|---|---|---|---|---|---|
| 1 | Trunk cable+pipe bundle (2 km initial) | IW-1 | ~5.5 hr | ~180 kg | Partial trunk, SATS at end |
| 2 | SATS+WEB integrated at trunk cable end | IW-1 | ~5.5 hr | ~35 kg | SATS+WEB pre-integrated (arrives with trunk) |
| 3 | Construction material pallet 1 (Branch A stock) | IW-1 | ~23 hr | ~480 kg | Posts, stakes, cable, pipe, rail |
| 4 | Construction material pallet 2 (Branch B stock) | IW-2 | ~23 hr | ~480 kg | Parallel with #3 |
| 5 | First MOLE-I (construction unit) | UW-1 | 4.7 hr | 360 kg | Descends while IW loads deploy |
| 6 | Substation 1 (on sled) | IW-1 | ~23 hr | ~160 kg | After pallet 1 lowered |
| 7 | Substation 2 (on sled) | IW-2 | ~23 hr | ~160 kg | After pallet 2 lowered |
| 8–17 | MOLE-I units #2–10 (sequential) | UW-2–10 | 4.7 hr each | 360 kg ea. | Parallel; 1–2 per day |

Total infrastructure winch time: ~104 hr (4.3 days) using 2 winches in parallel. MOLE-I unit descents run concurrently on separate winches and are not on the critical path.
Critical path: Payload #3 + #6 (pallet 1 + sub 1) = ~46 hr sequential on IW-1. With IW-2 handling pallet 2 + sub 2 in parallel, the infrastructure is CLP-ready in ~46 hr (~2 days). Construction MOLE-I begins branch build-out immediately after pallet arrives.
⚠ Winch turnaround time (cable retrieval to surface, hook new payload) estimated at 2–4 hr per cycle. Add ~24 hr total overhead for 8 IW cycles. Revised critical path: ~3 days for infrastructure, ~5 days including all MOLE-I descents.
# 2. Construction Material Manifest — Per Branch
Each bilateral fishbone branch consists of support posts, cable, pipe, T-junctions, temporary guide rail, stakes, and guy wire hardware. The following manifest is for a single 450 m branch with 1 substation node (minimum configuration). Longer branches or multiple nodes scale linearly.
| Item | Qty | Unit kg | Total kg | Notes |
|---|---|---|---|---|
| Support posts (3 m Al tube) | 90 | 3.0 | 270 | 1 per 5 m spacing over 450 m |
| Post cross-arms | 90 | 1.0 | 90 | Ti T-bracket + PEEK standoffs + C-clips |
| Branch cable (AWG14 Kapton Cu) | 450 m | 0.07/m | 32 | On spool, factory-assembled w/ construction taps every 100 m |
| Branch pipe (VJ SS, 20 mm OD) | 450 m | 3.5/m | 1,575 kg | Heaviest item. Pre-joined 10 m sections with bayonet couplers. Includes trace heater wire. |
| T-junctions (capped bayonet) | 1 | 2.0 | 2 | 1 per substation position. Pressure-rated 200 bar burst (2.5× on 80 bar working). |
| Temporary guide rail (C-channel) | 450 m | 0.8/m | 360 | Ti C-channel, 40×30 mm. Reusable: recovered after substation deployment. |
| Stakes (Ti screw, 500 mm) | 180 | 0.5 | 90 | 2 per post position (guy anchor + base clamp) |
| Guy wire sets (Kevlar, 3×) | 1 | 3.0 | 3 | For 1 substation mast. Pre-measured with turnbuckles. |
| BRANCH TOTAL |  |  | ~2,422 kg | For 450 m branch with 1 substation |
| SUBSTATION | 1 | 160 | 160 kg | Separate winch descent on sled |
| GRAND TOTAL |  |  | ~2,582 kg | Per 450 m branch + 1 substation |

⚠ Branch pipe is 65% of total branch mass. Pipe descent requires multiple winch cycles: at 500 kg per pallet, a 1,575 kg pipe stock requires 4 descents (×10 m sections per pallet). This is the dominant logistics bottleneck for branch build-out.
At P3 (2 branches): ~5,164 kg construction material + 320 kg substations + ~180 kg trunk + 3,600 kg MOLE-I fleet = ~9,264 kg total descent mass. At P7+ (34 branches, 170 MOLE-I): ~88,000 kg construction material across all phases. Spread over 15 years, this is ~5.9 t/yr of construction material descents — well within the 10+ t/yr Starship cargo cadence.
# 3. Construction MOLE-I — Mechanical Interfaces
The first MOLE-I on each branch doubles as the construction unit. It is a standard MOLE-I (no specialised hardware) that uses the following built-in or attachable interfaces. All construction tooling must be launchable as part of the construction material pallet and attachable/detachable by the rover autonomously.
## 3.1 Cable/Pipe Pulling
Interface: Rear tow cleat. A passive Ti hook (clevis pin, ~0.3 kg) bolted to the chassis rear boss adjacent to the power receptacle. The construction material pallet includes pre-cut cable and pipe sections with pulling eyes (loops) at the leading end. MOLE-I reverses to the pallet, a cable pulling eye is placed over the tow cleat (by gravity drop from a pallet dispenser rack), and the rover drives forward pulling the cable/pipe along the ground.
Force: At 1/6 g, a 3.5 kg/m pipe section (450 m = 1,575 kg) weighs ~257 N on the surface. Friction coefficient of SS on icy regolith at 40 K is ~0.1–0.2 (estimated; no published data for this exact pair). Pulling force: ~26–51 N. MOLE-I drive motors are rated for 300 W × 6 wheels; at 0.1 m/s this gives ~1,800 N traction. More than sufficient.
Procedure: MOLE-I pulls cable/pipe from the construction pallet staging area along the planned branch route. Cable and pipe are co-pulled (bundled at 1 m intervals with Ti wire ties, pre-installed at factory). The bundle is laid flat on the regolith surface. Construction taps on the cable every 100 m allow the MOLE-I to plug in its temporary tether and draw grid power for the next 100 m hop.
## 3.2 Stake Driving
Interface: Front push plate (drill housing base). The MOLE-I’s drill retracts fully, exposing a flat circular face (~80 mm dia) at the bottom of the drill housing. Stakes are pre-loaded into the regolith surface by a stake dispenser on the construction pallet (gravity-dropped into pilot holes at marked positions). The MOLE-I drives over the stake position and lowers the drill housing onto the stake cap, pressing it into the icy permafrost. At 1/6 g, the rover’s 360 kg provides ~588 N downforce. With the drill’s percussive mode engaged (zero rotation, impacts only), the stake is driven to 500 mm depth. Compressive strength of icy permafrost at 40 K is 10–30 MPa; a 20 mm dia stake tip requires ~3–9 kN to drive — the percussive mechanism provides this through impulse loading.
## 3.3 Mast Erection (Tilt-Up)
Interface: Front push contact. The 3 m Al support post lies flat on the ground with its base pinned in a hinge socket (the stake-mounted base clamp). The MOLE-I approaches the top end of the post, pushes it with the drill housing face at ~0.05 m/s. The post rotates about the hinge until vertical, where a gravity latch clicks (spring-loaded detent at 85–90°). Required push force: post mass 3 kg × 1/6 g × 1.5 m moment arm / 0.2 m contact height = ~3.7 N. Trivial.
Sequence: Posts are erected sequentially from the junction outward. Cable/pipe threaded through C-clips at ground level before erection. As each post tilts up, the cable/pipe rises with it to 3 m elevation. MOLE-I pushes, confirms latch (force feedback via wheel current spike), moves to next post.
## 3.4 Substation Towing
Interface: Front push plate against substation sled push plate. The MOLE-I’s flat drill housing base contacts the sled’s rear push plate (200 × 150 mm Ti plate on the sled frame). MOLE-I pushes the sled along the spine cable, then along the branch guide rail, at ~0.2 m/s. Required force: 160 kg sled × 1/6 g × μ_PTFE≈ 0.04 = ~1.1 N. MOLE-I can provide >100 N sustained push force.
⚠ The tow cleat and push plate are the only construction-specific mechanical interfaces on the MOLE-I. They are passive Ti fittings (≤0.5 kg total) that can remain permanently attached or be designed as removable pins. No manipulator arms, no actuated tooling, no dexterous grip is required for any construction task.
# 4. Trunk vs Branch Infrastructure Sequencing
## 4.1 Spine Power Cable (Phase 2–3)
The spine is a 1,000 VDC power cable (OFHC Cu, AWG14, Kapton+FEP jacket) running from the rim power zone to the CLP and then along the PSR floor. It is deployed in Stage A as part of the trunk bundle. The Self-Anchoring Terminal Station (SATS) at the cable end provides the first powered node at CLP. The spine extends incrementally as the construction MOLE-I pulls additional cable sections to new junction positions (Stage C hop-scotch pattern). The spine is a power-only cable at this stage — no water pipe.
## 4.2 Branch Cable and Pipe (Phase 3)
At each junction, the construction MOLE-I deploys a bilateral branch consisting of co-routed cable (1,000 VDC, tapped from the spine junction) and pipe (VJ SS, 20 mm OD, for water collection). These are pulled from the CLP construction material pallet, co-bundled. The branch pipe is GRAVITY-FED and LOW-PRESSURE at this stage — it collects water from substations and flows toward the trunk junction under a ≤2° slope. No pressurisation until the trunk pipeline connects (Phase 4+).
## 4.3 Heated Trunk Pipeline (Phase 4+)
The heated trunk pipeline is a SEPARATE infrastructure item from the spine power cable. It runs from the PSR floor operating zone UP to the surface ISRU plant along the crater wall (~8.5 km, 7 W/m trace heating, 59.5 kW). It is installed in Phase 4+ (Y5.5–7.0 per GUIDE v18) AFTER water production is confirmed. Before the trunk pipeline, water is transported via the cable tramway (Phase 3).
When the trunk pipeline is commissioned, it connects to the lowest point of the fishbone branch network. The branch junction pipe feeds into the trunk pipeline via a pressure-rated coupling. At this point, the 68 bar hydrostatic head from the 4.2 km elevation difference pressurises the entire trunk. The branch pipes remain low-pressure (gravity-fed toward the junction) and are NOT exposed to the 68 bar trunk pressure — the check valve at each substation riser top prevents backflow from the pressurised trunk into the branch network.
⚠ The 68 bar head pressure acts on the trunk pipeline, the trunk pump, and the junction coupling between trunk and branch network. It does NOT propagate into the branch pipes or substation risers (blocked by check valves). The branch T-junctions at substation positions do not need 200 bar burst rating — they operate at near-ambient pressure (water column from substation to junction: 3 m × 1/6 g × 1000 kg/m³ = 0.005 bar). Only the trunk-to-branch junction coupling at the spine requires the full 200 bar burst spec. This resolves the pressure rating gap identified in SEL-ISRU-001 Rev C §6.3.
# 5. Substation Guy Wire Installation
Each substation has a 3 m mast guyed by 3× Kevlar lines at 120° spacing, anchored to base plate vertices. The guy wires cannot be pre-installed before the mast is erected (they would tangle during sled transit). They must be attached after the mast is vertical and the substation is anchored in its final position.
## 5.1 Pre-Rigged Guy Wire System
The solution is a pre-rigged system that deploys passively during mast erection, requiring no manipulation by the construction MOLE-I.
- Guy wires are pre-attached to the mast at the factory. Each wire is coiled and secured to the mast tube with fusible Kapton tape wraps (rated to hold at 40 K, release under 5 N tension).
- Anchor stakes are driven at 3 designated positions (120° spacing, at pentagon vertices) BEFORE the mast is erected. Each stake has a capture hook (open C-hook facing upward) at its top.
- The mast lies flat with its base in the hinge socket. Guy wires are coiled near the mast top, with pendant weights (small Ti slugs, ~50 g each) at the free ends.
- As the MOLE-I pushes the mast vertical, the coiled wires hang free under 1/6 g. The pendant weights drop and swing outward as the mast passes ~60°. Each weight is attached to a Kevlar loop sized to land in the vicinity of its target stake.
- At 90° (vertical), the gravity latch engages. The pendant weights hang below the mast top at a radius approximately matching the stake positions (~0.7 m). The MOLE-I makes 3 passes, one per guy wire: it drives over each pendant weight, dragging it toward the stake until the Kevlar loop catches the C-hook. Cable tension snaps the fusible Kapton tape, releasing the remaining coil.
- Turnbuckles (pre-threaded on each wire at factory) are tensioned by the MOLE-I pressing the turnbuckle body against a stake flange. Each quarter-turn advances the screw ~2 mm. 5–10 press cycles per wire gives ~10–20 mm take-up, sufficient for nominal pre-tension.
⚠ This system has LOW confidence. The pendant weight trajectory at 1/6 g is deterministic but the loop-to-hook capture has ±50 mm tolerance, similar to the docking funnel. The C-hook must be open-topped and generous. Alternative: skip guy wires entirely and stiffen the mast base socket (larger diameter bayonet with 3× pin) to carry the lateral loads from MOLE-I docking impacts. The docking force is ~5 N at 0.1 m/s — minimal. Guy wires may be over-engineering for the actual load case. Flag for structural analysis.
# 6. P3 Deployment Timeline — Day-by-Day
| Day | Activity | Winch | PSR Floor |
|---|---|---|---|
| D0 | Trunk bundle descent (2 km) | IW-1: trunk (5.5 hr) | — |
| D0–D1 | SATS+WEB (part of trunk descent) | SATS+WEB on trunk (no separate descent) | SATS anchored, CLP powered |
| D1–D2 | Pallet 1 (Branch A) descent | IW-1: pallet (23 hr) | MOLE-I plugs into SATS+WEB tap |
| D1–D2 | Pallet 2 (Branch B) descent | IW-2: pallet (23 hr) | (parallel with above) |
| D1 | Construction MOLE-I descent | UW-1 (4.7 hr) | Transits to CLP, docks |
| D2–D5 | GATE 1. Spine pull to J1. Branch A build-out (cable/pipe pull, stake, erect posts, rail) | IW-1: Sub-1 descent (23 hr) | Const. MOLE-I building Branch A |
| D3–D6 | Branch B build-out (2nd MOLE-I borrowed or sequential) | IW-2: Sub-2 descent (23 hr) | Branch B build-out |
| D5–D6 | GATE 2. Sub-1 installed (pushed to position, anchored, riser erected, WEB powered) | — | Sub-1 operational |
| D6–D7 | Sub-2 installed | — | Sub-2 operational |
| D2–D7 | MOLE-I units #2–10 descend (parallel, 1–2/day) | UW-2 through UW-10 | Transit to subs, dock |
| D7–D8 | GATE 3. P3 fleet operational. GATE 4 after 48 hr production verification. | — | All 10 MOLE-I producing |

P3 total deployment: ~8 days from first winch cycle to full fleet operational. Critical path is branch build-out (3–5 days per branch) and substation install (1 day each). MOLE-I unit descents are fully parallel and not on the critical path.
# 7. Scaling Procedures (P4–P7+)
After P3, the PSR already has a powered spine, operational branches, and a construction-capable MOLE-I fleet. Scaling is incremental and operationally simpler than initial deployment.
- Spine extension: An existing MOLE-I is temporarily borrowed from drilling (1 unit, 2–3 days per new junction). It plugs into the furthest live junction, hops on battery to the extension point (100 m, ~23 Wh — trivial), and pulls the next cable section. Production loss: ~0.3% of fleet output per extension.
- Branch build-out: Same procedure as P3 Stage C, using the borrowed MOLE-I. Construction materials pre-descended to CLP staging area via IW-1/IW-2 during normal cargo cycles.
- Substation deployment: Pre-assembled sled lowered to CLP, pushed by construction MOLE-I along spine to target junction, then along branch to position. ~48 hr from rim dispatch to first water.
- MOLE-I fleet additions: New units descend on their own UW winches (one per unit), transit on battery to assigned substation, dock. No construction required — the branch infrastructure is already in place.
- Guide rail recycling: Rail sections from completed branches are lowered to CLP staging area for reuse. No re-manufacturing needed. Rail stock for P7+ (34 branches) is ~4 sets in rotation, not 34 sets.
# 8. Open Items and Verification
| # | Item | Owner | Status |
|---|---|---|---|
| 1 | SS-on-icy-regolith friction coefficient at 40 K. No published data. Conservative estimate 0.1–0.2 used for pipe pulling force. Requires analogue testing or simulation. | Abhijay | OPEN |
| 2 | Guy wire passive deployment confidence. Pendant weight + C-hook capture at 1/6 g. Alternative: stiffen mast base socket, eliminate guys. Structural analysis required. | Jason / Grant | OPEN — flag for review |
| 3 | Pipe descent logistics: 1,575 kg per 450 m branch at 500 kg/pallet = 4 winch cycles per branch pipe stock. Confirm IW payload capacity with pipe section length (10 m × 3.5 kg/m = 35 kg per section, 14 sections per pallet = 490 kg). | Jason | OPEN |
| 4 | Construction MOLE-I tow cleat design. Passive Ti clevis, ~0.3 kg. Add to SEL-SW-MOLEI-001 Rev C as optional attachment. Verify drill housing face can serve as push plate for stake driving and mast erection. | Abhijay | OPEN |
| 5 | Trunk-to-branch junction pressure coupling design. Must handle 68 bar trunk pressure on trunk side, near-ambient on branch side. Check valve integration at junction level (in addition to substation riser check valves). | Jason / Grant | OPEN |
| 6 | Update SELENITE_VERIFY v4.5 with construction material mass in Starship manifest model. ~5.9 t/yr average across 15-year programme. | Jason (MATLAB) | OPEN |

# 9. Document History
| Rev | Description |
|---|---|
| Rev A | Initial release. Closes 6 gaps identified in PSR deployment documentation: winch types and scheduling, construction material manifest, construction MOLE-I mechanical interfaces, trunk/branch sequencing, branch pressure rating, and guy wire installation. March 2026. |

— End of Document —
ECN-013 Amendments — ARM Fix and Construction Comms (March 2026)
§1.2 P3 Timeline — Payload #2 corrected:
CLP WEB module is pre-mounted onto the SATS frame at the rim, creating an integrated SATS+WEB assembly. This assembly is lowered at the trunk cable end during Stage A on IW-1 (not accompanied by ARM). The WEB is pre-heated to 293 K and equipped with 3× LWRHU for cold-start insurance during 23 hr descent. On arrival at CLP, the first construction MOLE-I (descending in parallel on UW-1) transits to the SATS on battery and pushes the WEB into its mounting position.
ARM robot removed from all PSR operations. ARM has no WEB and cannot survive the cryogenic environment. ARM operations are restricted to the crater rim and surface zones.

§3 Construction MOLE-I — RF comms role added:
During branch build-out on temporary tethers (construction taps every 100 m), the MOLE-I uses its 20 W UHF radio as primary comms. PLC is unavailable on temporary tethers. Automatic switchover: permanent drum port = PLC; construction tap = UHF. The nearest operational substation or spine junction UHF relay provides uplink to SENTINEL.
ECN-013 Rev 2: SATS+WEB Pre-Integration and Bayonet Adapter (March 2026)
Stage A revised: The trunk cable descent now includes the pre-integrated SATS+WEB at the cable terminal. ARM (or crew) mounts the WEB to the SATS frame and connects the power bayonet on the rim before descent. The assembly is pre-heated to 293 K; 3× LWRHU maintain ≥268 K during 23-hr descent.
Stage B revised: No longer a separate payload descent. Stage B is now a GATE ONLY — confirm trunk tension nominal, SATS anchored, WEB powered, comms live. Duration: minutes, not hours.
P3 Timeline impact: Payload #2 (previously CLP WEB + ARM) is REMOVED. The SATS+WEB is part of Payload #1 (trunk cable descent). This frees one IW cycle (~5.5 hr) from the critical path.
Construction MOLE-I interface: Uses motorised bayonet adapter (SEL-MI-CON-001) to engage/disengage construction taps. Push-and-twist via DC motor (2 W, 0.5 s per cycle). Passive detent holds connection with zero power. Same adapter used for all construction tap connections during branch build-out.
ECN-013 Rev 3: Construction Tap Retraction Spools (March 2026)
ECN-013 Rev 3: Construction Tap Retraction Spools

Each construction tap point (every 100 m on the branch cable) is factory-equipped with a spring-loaded retraction spool (SEL-SUB-TAP-010) that manages the 100 m construction tether during branch build-out.

Specification:
Part: SEL-SUB-TAP-010 — Spring-Loaded Construction Tether Retraction Spool
Function: Automatically reels in slack construction tether as the MOLE-I moves within its 100 m work radius. Keeps tether off the regolith surface and clear of stakes, posts, and infrastructure being erected.
Mechanism: Clock spring (spring steel, 301 SS — retains elasticity at cryogenic temperatures, same alloy as MOLE-I wheel mesh). No motor, no power, no WEB. Purely mechanical constant-tension rewind.
Tension: ~5 N (sufficient to lift 100 m of tether off the ground at 1/6 g; light enough not to impede the 360 kg rover — represents <1% of traction force).
Mass: ~1.0 kg (spool housing 0.4 kg Ti + clock spring 0.3 kg SS + cable guide 0.1 kg PEEK + tether 0.2 kg). The tether itself is pre-wound on the spool at the factory.
Tether: 100 m, 1000 VDC rated, AWG 16 Kapton-insulated OFHC Cu (~0.2 kg for 100 m — lighter than the permanent AWG 14 drum tethers because the construction tether carries lower current and is temporary).
Bayonet plug: Integrated at the free end of the tether. Compatible with MOLE-I motorised bayonet adapter (SEL-MI-CON-001). Same 20 mm bore, 2× L-slot, spring detent profile.
Housing: Sealed Ti drum, ~120 mm dia × 60 mm wide. PEEK cable guide slot prevents cross-winding. MoS₂ on all internal bearing surfaces.
Mounting: Factory-installed on the branch cable at each construction tap point. The spool housing is bonded to the cable jacket with Ti saddle clips and sits flat on the ground alongside the cable during the ground-level phase of branch construction. When the masts are tilted up and the cable rises to 3 m, the spool hangs below the cable at the tap point (suspended by the saddle clips).

Operational sequence:
(1) Branch cable laid flat on ground with spools at every 100 m, tethers pre-wound.
(2) Construction MOLE-I arrives at a tap, engages the bayonet plug via motorised adapter.
(3) MOLE-I drives forward to work. Spool pays out tether under ~5 N spring tension — tether stays taut and off the ground.
(4) MOLE-I reverses or moves laterally. Spool retracts slack automatically.
(5) When work at this 100 m section is complete, MOLE-I disengages bayonet, drives to next tap on battery (~23 Wh hop). Spring fully retracts tether onto spool.
(6) After all branch construction is complete: spools remain in place at the elevated 3 m cable. They are passive dead-weight (~1 kg each) and can remain permanently or be recovered for reuse on the next branch (same as temporary guide rail).

Manifest impact: ~9 spools per 450 m branch (one per 100 m tap, minus the junction tap which uses the SATS/substation construction tap). At 1.0 kg each: +9 kg per branch. P3 total (2 branches): +18 kg. P7+ total (34 branches): +306 kg across all phases. Negligible against the 2,422 kg per branch construction material budget.

Cryogenic qualification: The clock spring is the only moving part. Spring steel (301 SS) is cryogenically stable — it is the same alloy used for the MOLE-I wheel mesh, which operates continuously at 40 K under cyclic load. MoS₂ on the bearing surface provides adequate dry lubrication at 40 K (same lubricant used throughout the programme). No sealed lubricants, no elastomers, no temperature-sensitive components.
CAP Phase 1 Reservations — Construction Actions (SEL-CAP-001)
The following Phase 1 construction actions are required to support the Phase 2+ Crater Access Pod (CAP). These impose no schedule impact and add <10 kg of hardware.

1. Guide cable anchor sockets: During Phase 1 branch build-out (Stage C), the construction MOLE-I drives 4–6 additional Ti screw anchor stakes at designated positions along the crater wall descent route, offset ~2 m laterally from the trunk cable. These are empty sockets — no cable installed. Coordinates specified by the rim winch pad survey before trunk descent.
2. Rim winch pad: SINTER prepares a levelled ~4 m² pad adjacent to the IW-1/IW-2 stations during Phase 1 surface construction. No winch equipment installed — just the sintered foundation.
3. Floor docking pad: A flat Ti anchor plate (4× screw anchors + 1000 VDC bayonet power tap socket) installed adjacent to the SATS+WEB at CLP during Stage A. The construction MOLE-I drives the anchors using the same percussive mechanism used for substation anchoring. Mass: ~5 kg.
4. Cable routing corridor: The trunk cable, pipeline, and branch infrastructure layout must maintain a 2 m lateral clearance corridor on one side of the trunk route. This is enforced during Stage A/C layout planning — no hardware, just a design constraint.
5. Manifest addition: Add 6× anchor sockets (~0.5 kg each = 3 kg) + 1× floor docking pad (5 kg) = 8 kg to the Phase 1 construction material pallet. Fits within existing pallet mass margin.