<!-- Markdown extract of docs/sources/SEL-ISRU-001_RevD_updated.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
ISRU Process Flow Specification
Ice Prospecting • Extraction • Water Purification • Electrolysis • Cryogenics • Storage
Reference: SEL-ISRU-001 Rev B
| Field | Value |
|---|---|
| Document | SEL-ISRU-001 Rev A |
| Programme | Selenite — Permanent Lunar Base, Shackleton Crater |
| Subject | Complete ISRU chain: PSR ice prospecting through propellant delivery |
| Author | Jason Stewart (Systems Engineering Lead) |
| Date | March 2026 |
| Status | DRAFT — For team review and competition submission |
| Scope | End-to-end process flow, mass/energy balance, water purification spec, adaptive fishbone layout, prospecting decision gates |

Source Documents:
SEL_MOLEI_DESIGN v5
SEL_ROBOT_FLEET v9
W2_T1_1_JS_MTL_GUIDE v18
SEL-T1_1-STRATEGY v3.0
MOLEI_THERMAL v1.3 (MATLAB)
SELENITE_VERIFY v5.0 (MATLAB)
SEL-SW-MOLEI-001 Rev B (SolidWorks sequence)
LCROSS mission data (Colaprete et al. 2010)
Luchsinger et al. 2021 (Cabeus reanalysis)
Zuber et al. 2012 (Shackleton ice assessment)
Mini-RF/LRO radar data

# 1. Scope
This document specifies the complete In-Situ Resource Utilisation (ISRU) process chain for the Selenite Programme, from ice prospecting in the Permanently Shadowed Region (PSR) through to delivered LH₂/LOX propellant at the docking zone. It covers seven process stages, the adaptive infrastructure layout driven by ice concentration mapping, water purification requirements for PEM electrolysis, and the decision gates that govern site selection and infrastructure commitment.
The ISRU chain is the programme’s economic engine. Every PROBE asteroid mining mission, every SKIP KREEP collection hop, every life support oxygen molecule, and every crew return vehicle fuelling depends on this chain producing propellant reliably and at scale. A failure or shortfall anywhere in the chain cascades into reduced mission cadence, stockpile drawdown, and ultimately programme viability.
# 2. Ice Prospecting and Site Selection
## 2.1 The Heterogeneity Problem
The programme’s ice concentration design value of 4.46 wt% is extrapolated from Cabeus crater LCROSS impact data (Colaprete et al. 2010: 5.6 ± 2.9 wt%; Luchsinger et al. 2021 reanalysis: 4.3 wt%) to Shackleton crater, which has never been directly sampled. This extrapolation carries substantial uncertainty.
Lunar PSR ice deposits are almost certainly heterogeneous. Ice accumulated over billions of years from cometary impacts, solar wind implantation, and volcanic outgassing, then migrated thermally between cold traps. The resulting distribution is patchy, depth-variable, and crater-specific. Zuber et al. (2012) assessed Shackleton and concluded ice content “can also be much less, conceivably as little as zero.” Mini-RF radar from LRO sets an upper bound of ≤5–10 wt% for Shackleton but cannot distinguish ice from surface roughness effects — the lower bound is genuinely zero.
The programme must not commit irreversible infrastructure (trunk cable, pipeline, sub-stations) to a crater until ice presence and concentration have been confirmed by ground-truth measurement. This is a hard prerequisite.
## 2.2 Dual-Crater Prospecting Strategy
SURVEY robots will prospect both Shackleton and Cabeus craters during Phase 0–1 (pre-infrastructure), producing ice concentration maps for each. The programme concept is modelled on a Shackleton location (82–89% solar illumination at rim, well-characterised geometry, extensive orbital data). However, the infrastructure design is portable to Cabeus with the following concessions:
| Parameter | Shackleton (baseline) | Cabeus (contingency) | Impact of switch |
|---|---|---|---|
| Solar illumination (rim) | 82–89% (Glas̈er 2014, Mazarico 2011) | ∼60–70% (less favourable geometry) | Larger solar array or additional FSP unit required. Power budget scales ~1.2–1.4×. |
| Crater depth | 4.2 km (Zuber 2012) | ∼3.0 km | Shorter trunk cable, lower pipeline head pressure. Infrastructure mass ∼30% less. |
| Wall slope | 30° (Haruyama 2008) | ∼20–25° | Easier descent, but longer traverse at shallower angle. |
| Ice confirmation | UNCONFIRMED (orbital only) | CONFIRMED (LCROSS impact) | Cabeus has ground-truth; Shackleton does not. |
| Floor temperature | 50–90 K (Diviner) | ∼40–60 K (colder floor) | Slightly higher thermal loads on MOLE-I. Keep-alive budget adequate (designed for 40 K). |
| Trunk cable + pipeline | 8.4 km, 45.7 t Cu, 93–139 kW heating (variable with layout, VERIFY v4.5) | ∼6 km, ∼33 t Cu, ∼42 kW heating | Significant mass and power saving. |

Decision rule: If Shackleton prospecting confirms ≥3% ice over ≥50% of planned mining area, proceed at Shackleton. If below threshold, relocate to Cabeus (confirmed ice source) and accept the solar penalty. If both craters fall below 3%, the programme requires fundamental re-scoping.
## 2.3 SURVEY Phase 0 Prospecting Protocol
SURVEY (120 kg polar LLO spacecraft, collimated neutron spectrometer) conducts orbital ice mapping before any infrastructure descends into the crater. Ground-truth confirmation is performed by the first MOLE-I units at each new branch (drill mass input ÷ water output = wt% ice concentration). The orbital mapping determines not just whether to build, but approximately where to place every trunk segment, branch, and sub-station node.
### 2.3.1 Instruments
| Instrument | Measurement | Spatial Resolution | Purpose |
|---|---|---|---|
| Ground-Penetrating Radar (GPR) | Dielectric contrast at 0.1–2 m depth | ∼0.5 m lateral, ∼0.1 m vertical | Identify ice-bearing layers and estimate volumetric ice fraction |
| Neutron Spectrometer (portable) | Epithermal neutron flux depression | ∼2–5 m footprint | Hydrogen abundance proxy (ice wt%). Calibrate against GPR. |
| Portable XRF (pXRF) | Elemental composition of drill cuttings | Point measurement | Confirm H₂O vs other hydrogen sources (e.g. solar wind H in glass) |
| Drill core sampling | Physical ice content at discrete depths | Point, depth-resolved | Ground-truth calibration for GPR and neutron data |

### 2.3.2 Mapping Grid
SURVEY maps the PSR floor from a 15 × 50 km elliptical polar orbit (perilune over south pole). The collimated neutron spectrometer achieves ~1.5 km effective resolution after 10+ pass deconvolution. The orbital map covers the planned mining area (∼500 × 500 m initially, expandable) at 50 m spacing. At each grid point: GPR scan (2 min), neutron measurement (5 min), optional drill core if GPR anomaly detected (30 min). Total survey time for 100-point grid: ∼12–40 hours depending on drill core frequency.
Output: an ice concentration heat map with ∼50 m resolution covering the planned mining area. This map directly drives the fishbone layout (Section 11).
### 2.3.3 Decision Gates
◆ GATE: GATE 0 (Y3.8): SURVEY completes orbital PSR ice mapping (≥385 days for full Shackleton floor at 500 m grid). Ice concentration data transmitted to Earth for analysis.
◆ GATE: GATE 1 (Y3.9): Programme director reviews orbital ice map. GO/NO-GO for Shackleton infrastructure. Decision criteria: ≥3 wt% ice over ≥50% of planned area. If NO-GO: SURVEY continues mapping Cabeus PSR from same orbit (∼2 months additional). Cabeus GATE 1B at Y4.1.
◆ GATE: GATE 2 (Y4.0): Fishbone layout finalised based on ice map. Trunk route, branch directions, and initial node locations committed. Stage 2 trunk cable descent authorised.
Between Gate 0 and Gate 2, the programme is in a hold state — no irreversible infrastructure actions. MOLE-S and SINTER continue surface construction (landing pad, hab foundation) during this hold. The hold costs schedule time but no hardware.

# 3. ISRU Process Chain Overview
The complete chain from ice-bearing regolith to delivered propellant has seven stages. Each stage is a physical location with distinct hardware, operating conditions, and failure modes.
| Stage | Location | Process | Hardware | Output |
|---|---|---|---|---|
| 1. Drilling | PSR floor (∼40 K) | Rotary-percussive fragmentation of icy permafrost | MOLE-I drill head (200 W) | Fragmented icy regolith (4.46% ice) at 25 kg/hr |
| 2. In-situ sublimation | MOLE-I mini-VEX (273 K sealed) | Heat regolith → sublimate ice → condense to liquid | mini-VEX chamber (1,200 W) | Liquid water (∼85% recovery) + dry tailings |
| 3. Collection & transport | Substation → pipeline → rim | Batch dump to manifold, pump up pipeline | 50 L tank, heated pipeline (93–139 kW variable, VERIFY v4.5), pump (408 W) | Liquid water at surface ISRU zone |
| 4. Water purification | Surface ISRU zone (∼200 K) | Distillation + deionisation + filtration | Surface VEX (5 kW) + purification module | Clean water (<1 ppm TDS, <0.1 μm particulate) |
| 5. Electrolysis | Surface ISRU zone | PEM water splitting: H₂O → H₂ + O₂ | PEM electrolyser stack (883 kW at P7+) | Gaseous H₂ and O₂ at ∼30 bar |
| 6. Liquefaction | Surface ISRU zone | Compress + cool to cryogenic liquid | Cryocoolers (256 kW at P7+) | LH₂ (20 K) and LOX (90 K) |
| 7. Storage & delivery | ISRU zone → docking zone | Buffer storage, propellant transfer | Cryo tanks + transfer lines | LH₂/LOX at docking collars for PROBE/SKIP |

# 4. Stage 1 — Drilling and Extraction
MOLE-I’s rotary-percussive drill fragments icy permafrost at 25 kg/hr. The substrate at 40 K has an estimated compressive strength of 10–30 MPa (icy permafrost at ∼4.5% ice fraction; pure ice at 40 K would be ∼70 MPa per Arakawa & Maeno 1997, but the low ice fraction yields a composite dominated by grain-boundary cementation). The drill is ESA PROSPECT heritage (TRL 5–6, tested to <123 K).
## 4.1 Drilling Parameters
| Parameter | Value | Confidence |
|---|---|---|
| Drill type | Rotary-percussive (NOT bucket drum) | HIGH |
| Drill rate | 25 kg/hr in icy permafrost at 40 K | MED |
| Drill power | 200 W | HIGH |
| Bit material | Tungsten carbide, non-replaceable in-situ | MED |
| Drilling depth | ∼0.3–0.5 m per position (shallow surface ice layer) | LOW |
| Repositioning | MOLE-I drives 1–2 m between drill positions within 72° sector | MED |
| Ice fraction (design) | 4.46 wt% (extrapolated from Cabeus LCROSS data) | MED |
| Ice fraction (range) | 0–10 wt% (heterogeneous, site-dependent) | LOW |

## 4.2 Tailings Management
For every 25 kg of regolith drilled per hour, only ∼1.1 kg is ice. The remaining ∼23.9 kg/hr is dry mineral tailings ejected from the mini-VEX bottom port back onto the PSR floor.
| Parameter | Value |
|---|---|
| Tailings rate | 23.9 kg/hr per MOLE-I (∼167 t/yr at 80% availability) |
| P7+ total (170 units) | ∼28,400 t/yr of dry regolith redeposited |
| 15-year accumulation | ∼426,000 t total |
| Sector area per unit | ∼25,130 m² (72° sector, 200 m radius) |
| Sector exhaustion time | ∼113 years at 0.5 m depth (not a near-term concern) |
| Ejection direction (45° directional chute on VEX underside, fixed stainless ~150 mm, ~0.3 kg) | Downward and lateral, AWAY from retraction path to substation |
| Operational constraint | MOLE-I advances in radial mowing pattern (outward from substation, step sideways, work inward). Tailings accumulate behind working front. After ~10 yr, re-drilling areas have ~0.1–0.2 m dry tailings layer on top (∼5–10% yield reduction from penetrating loose overburden) |

# 5. Stage 2 — In-Situ Sublimation (mini-VEX)
## 5.1 Process Physics
At 40 K and hard vacuum, water ice cannot exist as liquid. The triple point of water is 273.16 K / 611.73 Pa. Below this, ice sublimates directly to vapour. The mini-VEX exploits this: it heats icy regolith inside a sealed chamber, sublimating the ice fraction to water vapour while the dry mineral grains remain solid. The vapour then condenses to liquid on a cold-finger surface maintained at ∼273 K and modest pressure (∼1–10 kPa from the evolved steam).
### 5.1.1 Thermodynamic Energy Budget
| Energy Component | Power (W) | Derivation |
|---|---|---|
| Sensible heat: ice 40 → 273 K | 77 | 1.1 kg/hr × 2,090 J/kg·K × 233 K / 3,600 s |
| Latent heat: sublimation | 885 | 1.1 kg/hr × 2,830 kJ/kg / 3.6 |
| Sensible heat: bulk regolith 40 → ∼200 K | 300 | 23.9 kg/hr × ∼800 J/kg·K × 160 K / 3,600 s (regolith exits warm) |
| Drill heat recovery (credit) | –100 | Drill waste heat captured via adjacent mounting (MED confidence) |
| SUBTOTAL (thermodynamic minimum) | 1,162 |  |
| Design value (28% margin) | 1,200 | Range 800–1,600 W. LOW confidence pending FEA thermal model. |

### 5.1.2 Process Steps Inside Chamber
Step A — Feed intake: Fragmented icy regolith enters through the 30 mm feed chute from the drill. The chute has a simple gate valve that opens during drilling and closes during the sublimation heating cycle.
Step B — Heating: Electric resistance elements on the chamber interior walls heat the sealed charge. Temperature rises from ∼40 K to ∼200–300 K over ∼5–10 minutes. Ice sublimates progressively as temperature increases.
Step C — Vapour migration: Water vapour (plus trace volatiles: CO₂, H₂S, SO₂, NH₃, CH₄ — all detected in LCROSS Cabeus plume) migrates from the hot regolith to the condenser section at the opposite end of the chamber.
Step D — Condensation: The condenser surface is maintained at ∼273 K (thermally coupled to the WEB via the 10 mm water outlet tube). At this temperature and the chamber’s internal pressure (∼1–10 kPa from evolved steam), water vapour condenses to liquid. Trace volatiles with lower boiling points (CO₂, H₂S, CH₄) remain gaseous and are vented when the tailings port opens.
Step E — Liquid collection: Condensed liquid water flows via gravity (1/6 g) through the 10 mm water outlet tube, through the PEEK thermal coupler, into the 50 L tank inside the WEB.
Step F — Tailings ejection: After the sublimation cycle, the bottom tailings gate opens. Dry, warm (∼200 K) regolith falls out under gravity. Residual trace volatiles vent to vacuum. Gate closes, next charge enters.
⚠ The condensed water is NOT pure. It contains dissolved volatiles (particularly H₂S and NH₃ which are water-soluble), fine suspended regolith particulates that were entrained in the vapour stream, and potentially dissolved metallic ions from regolith contact. This water requires purification before electrolysis (see Stage 4).
## 5.2 Recovery Efficiency
Design recovery: 85% of ice mass. The 15% loss comprises: vapour that escapes when the tailings port opens (∼5%), vapour that condenses on non-collection surfaces inside the chamber (∼5%), and ice retained in regolith pore spaces that doesn’t fully sublimate (∼5%). These estimates are LOW confidence and require experimental validation. Heritage: ESA PROSPECT demonstrated in-situ volatile extraction at laboratory scale; no flight data exists for this specific process at scale.

# 6. Stage 3 — Collection and Pipeline Transport
## 6.1 Batch Dump
MOLE-I’s 50 L tank fills in ∼45 hours. The unit reverses to its substation (tether stays connected, drum reels in), the bottom-drain valve opens, and water gravity-feeds through a heated funnel into the substation’s collection manifold. Dump takes ∼15 min. The unit then drives forward to resume drilling. Total dump cycle: ∼1.4 hr including retraction and redeployment. Cycle availability: 97.1%.
## 6.2 Substation Water Handling
Each substation collects water from 5 MOLE-I units. With each unit dumping ∼50 kg every ∼46 hours, the substation accumulates ∼130 L/day. The collection manifold feeds into the branch pipe, which slopes toward the trunk junction (gravity-fed, no branch pump needed). A small transfer pump at each substation (∼10 W) lifts water ∼3 m into the elevated branch pipe.
## 6.3 Heated Trunk Pipeline
| Parameter | Value | Notes |
|---|---|---|
| Total length | ∼8,500 m (rim to PSR floor) | 30° wall slope, 4.2 km vertical |
| Trace heating (7 W/m trunk+spine ground-contact, 1.5 W/m elevated branches in vacuum+MLI; scales with deployed length per phase: 93–139 kW at P7+) | 7 W/m → 59.5 kW total | Must never lose power; freeze = full replacement |
| Pipe material | Ti or SS, insulated | PEEK thermal breaks at junctions |
| Trunk pump (CLP) | 408 W | 68 bar head pressure (4,200 m at 1.62 m/s²) |
| Pipeline rated 80 bar working / 200 bar burst (2.5× SF). Ti-6Al-4V, 1 mm wall. Check valve at each riser junction. Pipe pressure rating | ≥80 bar | 68 bar static + flow losses + safety factor. Gap: not previously specified. |
| Flow rate (P7+) | ∼0.042 kg/s (∼151 L/hr) | 170 MOLE-I × 1.1 kg/hr water each, averaged |
| Pipe ID | ∼20 mm (laminar flow at this rate) | Reynolds number ∼2,700 at 20 mm ID — marginal turbulent |
| Redundancy | Dual parallel pipe from Phase 5 | Single-pipe failure is mission-critical |
| Freeze protection | Continuous trace heating + SENTINEL thermal monitoring | Pipe freeze = 2–4 week replacement campaign |

⚠ The 68 bar head pressure is significant. Standard lunar surface equipment is not designed for this. The pipeline, all fittings, the trunk pump, and every branch junction must be pressure-rated. This has not been addressed in previous programme documents and represents a design gap. Recommend burst-pressure testing specification of 200 bar (2.5× safety factor on 80 bar working pressure).

# 7. Stage 4 — Water Purification
This stage has not been previously specified in programme documentation. It is critical because PEM electrolysis membranes are sensitive to contaminants. Unpurified PSR water will damage the electrolyser within hours to days of operation, causing membrane poisoning, electrode fouling, and irreversible performance degradation.
## 7.1 Contaminant Profile of PSR Water
Water produced by the mini-VEX sublimation-condensation process contains contaminants from three sources:
### 7.1.1 Dissolved Volatiles (from LCROSS Cabeus plume analysis)
| Species | LCROSS Detection | Solubility in Water | PEM Impact |
|---|---|---|---|
| CO₂ | Yes (abundant) | Moderate (1.5 g/L at 273 K, 1 atm) | Forms carbonic acid, lowers pH, degrades membrane |
| H₂S | Yes | High (3.85 g/L at 293 K) | CRITICAL: poisons Pt catalyst at ppm levels. Must be <0.01 ppm. |
| SO₂ | Yes | Very high (94 g/L) | Forms sulphuric acid, destroys membrane |
| NH₃ | Yes | Very high (900 g/L) | Forms ammonium ions, contaminates membrane |
| CH₄ | Yes | Very low (0.023 g/L) | Low risk — mostly remains gaseous |
| Hg (mercury) | Yes (trace) | Insoluble as metal; soluble as Hg²⁺ | Catalyst poison. Must be <0.001 ppm. |
| Na, Ca, Mg ions | Expected (regolith contact) | Moderate | Scale formation on electrodes and membranes |

⚠ H₂S and Hg are the critical PEM poisons. Even trace amounts (single-digit ppm for H₂S, sub-ppm for Hg) irreversibly deactivate the platinum catalyst on PEM electrodes. The purification system must reduce these to near-zero levels.
### 7.1.2 Suspended Particulates
Fine regolith particles (∼1–100 μm) entrained in the water vapour stream during sublimation and carried through to the condensate. Lunar regolith contains nanophase metallic iron (Fe⁰) from space weathering, which is chemically reactive. Suspended particulates above ∼0.1 μm will physically clog PEM membrane pores.
### 7.1.3 Dissolved Ions
Contact between condensed water and hot regolith surfaces (∼200–300 K) inside the VEX chamber dissolves trace quantities of metallic ions (Fe, Ca, Mg, Na, K, Al). PEM membranes require feedwater with total dissolved solids (TDS) below ∼1 ppm and conductivity below ∼1 μS/cm — comparable to semiconductor-grade deionised water.
## 7.2 Purification Process Train
The purification system is located at the surface ISRU zone, receiving water from the pipeline terminus. It consists of four treatment stages in series:
### 7.2.1 Stage 4A — Degassing (Volatile Stripping)
| Parameter | Value |
|---|---|
| Process | Vacuum flash degassing. Water enters at ∼1–10 kPa pipeline pressure; pressure is dropped to ∼100 Pa in a flash chamber. Dissolved gases (CO₂, H₂S, SO₂, NH₃, CH₄) rapidly evolve from solution. |
| Operating temperature | 273–280 K (just above freezing) |
| Vacuum source | Lunar ambient (∼0 Pa). Vent to vacuum via controlled orifice. |
| Heritage | Standard industrial vacuum degassing. Simplified on Moon: free vacuum. |
| H₂S removal target | <0.1 ppm after degassing (bulk removal). Polishing in Stage 4C. |
| Power | ∼50 W (valve actuation, instrumentation). No pump needed — vacuum is free. |
| Mass | ∼15 kg (chamber + valves + sensors) |
| Residual risk | H₂S has high water solubility. Vacuum degassing removes ∼90–95% but trace levels persist. Polishing required. |

### 7.2.2 Stage 4B — Particulate Filtration
| Parameter | Value |
|---|---|
| Process | Two-stage filtration: 10 μm pre-filter (sintered Ti mesh, backflushable) followed by 0.1 μm ceramic membrane (Al₂O₃ or ZrO₂) |
| Target | <0.1 μm particulate, including nanophase Fe⁰ |
| Flow rate | ∼2.5 L/min at P7+ steady state |
| Backflush | Pre-filter: automated backflush every ∼24 hr using clean water reserve. Ceramic membrane: chemical-free backflush using heated water pulse. |
| Consumables | None. Sintered Ti and ceramic are indefinite-life components. No filter cartridge replacement needed. |
| Power | ∼100 W (backflush pump + instrumentation) |
| Mass | ∼25 kg (filters + housing + valves) |

### 7.2.3 Stage 4C — Activated Carbon + Sulphur Scavenger
| Parameter | Value |
|---|---|
| Process | Packed bed: activated carbon (removes organics, residual H₂S, Hg) followed by iron oxide granules (sulphur scavenger, removes H₂S to <0.01 ppm) |
| Bed life | Activated carbon: ∼5,000–10,000 L per kg of carbon (depends on contaminant loading). Iron oxide: ∼2,000 L per kg. Both are consumed over time. |
| Consumable replacement | This is the only consumable in the purification train. Carbon + iron oxide must be resupplied from Earth. At P7+ flow rates (∼1,325,000 L/yr), need ∼130–265 kg carbon + ∼660 kg iron oxide per year. ∼1 t/yr total consumables. |
| Target | H₂S < 0.01 ppm, Hg < 0.001 ppm, total organics < 1 ppm |
| Power | ∼20 W (monitoring only, passive flow-through) |
| Mass (beds) | ∼50 kg initial charge + annual resupply |

⚠ The ∼1 t/yr consumable requirement for carbon and iron oxide is the only ongoing Earth-supply dependency in the ISRU chain. All other components are indefinite-life or maintainable in-situ. This consumable mass is small relative to cargo launch capacity but must be explicitly manifested.
### 7.2.4 Stage 4D — Ion Exchange Deionisation
| Parameter | Value |
|---|---|
| Process | Mixed-bed ion exchange resin (cation + anion). Removes dissolved metal ions (Fe, Ca, Mg, Na, K, Al) and residual ionic species. |
| Target | TDS < 1 ppm, conductivity < 1 μS/cm |
| Resin life | Regenerable in-situ using electrochemical regeneration (CDI — capacitive deionisation) or acid/base wash from minor Earth-supplied reagent stock |
| Regeneration | Electrochemical CDI preferred (no consumable chemicals). Regeneration cycle every ∼48–72 hr at P7+ rates. Power: ∼200 W during regen cycle. |
| Power | ∼50 W average (monitoring + periodic regeneration) |
| Mass | ∼30 kg (resin bed + CDI module + sensors) |

### 7.2.5 Stage 4E — Potable Water Branch
A controlled fraction of Stage 4D output water is diverted to produce potable (drinking) quality water for the crew habitat. The Stage 4D output (TDS <1 ppm, conductivity <1 µS/cm) is too pure for human consumption — demineralised water leaches calcium from bone and disrupts electrolyte balance (WHO, 2005). The potable branch adds minerals back and sterilises the water before delivery to the habitat.
| Function | Remineralise deionised water to WHO/NASA potable standard. Sterilise. Deliver to habitat potable bus. |
|---|---|
| Process | CO₂ injection → calcite/dolomite upflow contactor (adds Ca²⁺, Mg²⁺, HCO₃⁻) → NaOH pH trim to 7.5–8.0 → KCl dosing (K⁺) → ionic silver generator (Ag⁺ 200–400 µg/L residual biocide) → UV-C steriliser (254 nm, ≥40 mJ/cm²) → potable buffer tank → food-grade SS pipe to habitat at 230–280 kPa. |
| Output quality | TDS 150–300 mg/L. pH 7.0–8.0. Ca²⁺ 40–80 mg/L. Mg²⁺ 10–30 mg/L. TOC <0.5 mg/L. Bacteria <1 CFU/mL. Ag⁺ 200–400 µg/L. Meets SSP 41000 + 1,000-day SWEGs (JSC 63414). |
| Flow rate | P4 (4 crew): 1.4–6.0 kg/day potable makeup + 4.0 kg/day O₂ electrolysis = ~10 kg/day total life support. P7+ (12 crew): 4.2–18 kg/day potable + 12 kg/day electrolysis = ~30 kg/day. This is 0.08–0.22% of total ISRU water output. |
| Hardware | Calcite/dolomite contactor column (~0.3 m dia × 1.0 m tall, 10–20 min EBCT). NaOH dosing pump. KCl cartridge. Electrolytic Ag⁺ generator. UV-C lamp (254 nm, ≥40 mJ/cm²). Total mass <50 kg. Power <100 W. |
| Consumables | Calcite/dolomite media: ~50 kg/yr (P4) to ~150 kg/yr (P7+), Earth-supplied. CO₂ from Sabatier reactor or crew metabolic output (available in-situ). NaOH + KCl: ~5 kg/yr. Silver electrodes: negligible. UV lamp: 1/yr replacement. Combined with Stage 4C carbon/iron oxide, total Earth-supply consumables for ISRU purification + potable branch: ~1.2 t/yr (P7+). |
| ECLSS interface | Potable water enters hab via food-grade 316L SS pipe (electropolished, separate from ISRU trunk). UV steriliser at hab entry point. Inside hab, an ISS-heritage Water Recovery System (WRS: UPA + WPA + BPA) recycles urine, humidity condensate, and hygiene greywater at 93–98% recovery. ISRU branch tops up the potable bus on demand. Emergency reserve: 900 L (P4, 4 crew × 90 days × 2.5 kg/day survival) to 2,700 L (P7+, 12 crew). See SEL-ECLSS-001 for full hab water recycling specification. |

⚠ The potable water branch is trivially small relative to the ISRU production budget. At P7+ with 12 crew, total life support water demand (potable makeup + O₂ electrolysis) is ~30 kg/day — less than 0.25% of the ISRU plant’s 13,277 kg/day water output. The remineralisation module is a single compact column. The engineering challenge is not the potable branch itself but the upstream ISRU extraction and the downstream hab ECLSS recycling loop, which are each specified in their own documents.
## 7.3 Purification Module Summary
| Parameter | Total |
|---|---|
| Total mass | ∼120 kg (degasser 15 + filters 25 + carbon/FeOx beds 50 + DI module 30) |
| Total power | ∼420 W average (included in surface VEX 5 kW budget) |
| Output water quality: TDS <1 ppm, conductivity <1 µS/cm (for PEM electrolysis). Potable water branch (Stage 4E) diverts a fraction through remineralisation and sterilisation for crew consumption. See §7.2.5. | TDS < 1 ppm, conductivity < 1 μS/cm, H₂S < 0.01 ppm, Hg < 0.001 ppm, particulate < 0.1 μm |
| Annual consumables | ∼1 t/yr carbon + iron oxide (Earth-supplied) |
| Maintenance | Automated backflush (filters), automated regen (DI). Manual carbon/FeOx bed swap ∼ annually (crew EVA task, ∼2 hr). |

The purification module is installed as part of the surface VEX unit or as an adjacent standalone module connected by short piping. It is fully automated with SENTINEL monitoring of output water quality. If conductivity exceeds 5 μS/cm or H₂S exceeds 0.05 ppm, the electrolyser input valve automatically closes and an alert is sent to ops.

# 8. Stage 5 — PEM Electrolysis
| Parameter | Value | Notes |
|---|---|---|
| Technology | PEM (Proton Exchange Membrane) water electrolysis | ISS OGA heritage (PEM, operational since 2007) |
| Reaction | 2H₂O → 2H₂ + O₂ | Requires clean water feedstock (Stage 4 output) |
| Specific power | ∼5.5 kW per kg/hr H₂O processed | Includes balance-of-plant losses |
| P7+ throughput | 151.6 kg/hr water | 170 MOLE-I × 1.1 kg/hr × 0.811 recovery |
| P7+ electrical load | 883 kW | Dominant power consumer (∼46% of total programme power) |
| PEM stack count | 17 modules (∼50 kW each) | Modular: add stacks as fleet scales |
| Output pressure | ∼30 bar (differential pressure PEM) | Eliminates need for separate H₂ compressor |
| Output ratio | H₂ : O₂ = 2 : 16 by mass (1 : 8) | 0.722 propellant conversion factor for 6:1 LH₂/LOX mixture |
| Membrane life | ∼40,000–80,000 hours (5–10 years) | Replacement membrane stacks manifested in cargo launches |
| Feedwater requirement | TDS < 1 ppm, conductivity < 1 μS/cm | Stage 4 output specification |

# 9. Stage 6 — Cryogenic Liquefaction
## 9.1 LOX Production (90 K)
Oxygen liquefaction at 90 K is relatively straightforward. The lunar surface temperature at Shackleton rim (∼200–290 K day, ∼100 K night) provides partial passive cooling. TRL 6+ cryocoolers at 90 K exist (Sunpower, Thales, Northrop). Power requirement: ∼0.4 kW per kg/hr O₂ liquefied. At P7+ rates (∼134 kg/hr O₂), that’s ∼54 kW for LOX.
## 9.2 LH₂ Production (20 K) — CRITICAL CHALLENGE
LH₂ liquefaction at 20 K is the programme’s most technically challenging ISRU step. The electrical-to-thermal coefficient of performance (COP) at 20 K is ∼0.01 — meaning ∼100 W of electrical power is needed to remove 1 W of heat at 20 K. NASA’s 20 K cryocoolers are TRL 4–5, delivering <1 W cooling at 20 K for flight-rated systems.
| Parameter | Value |
|---|---|
| LH₂ boiling point | 20.28 K (–252.87°C) |
| P7+ H₂ production rate | ∼16.8 kg/hr gaseous |
| Latent heat of liquefaction | 448.7 kJ/kg H₂ |
| Sensible cooling (273 → 20 K) | ∼3,600 kJ/kg H₂ (c_p varies significantly) |
| Total cooling load | ∼4,050 kJ/kg × 16.8 kg/hr = ∼18.9 kW thermal |
| Electrical power (∼100:1 COP) | ∼200 kW for LH₂ alone at P7+ |
| Staging approach | Pre-cool with 80 K cryocooler (COP ∼0.1), then 20 K final stage |
| Total cryo electrical load (P7+) | ∼256 kW (LH₂ 200 + LOX 54 + margin) |

⚠ The 20 K cryocooler TRL is the longest-lead technology risk in the ISRU chain. If flight-rated 20 K coolers are not available at programme scale, the fallback is oxygen-first ISRU: produce LOX (90 K, high TRL) and import LH₂ from Earth until 20 K technology matures. This fallback reduces ISRU independence but keeps the programme operational.

# 10. Stage 7 — Cryogenic Storage and Propellant Delivery
| Parameter | Value |
|---|---|
| Tank location | ISRU zone, 200–500 m from habitat (LH₂ explosion hazard) |
| LH₂ tank sizing | Sized for DART accumulation cycle: ∼9–15 t accumulated over ∼10 months |
| LOX tank sizing | Sized for same accumulation cycle at 8:1 O₂:H₂ mass ratio: ∼72–120 t |
| Boil-off management | Continuous re-liquefaction loop. SENTINEL monitors ullage and boil-off rate. |
| Transfer to docking zone | Vacuum-insulated transfer lines, ∼100–300 m. Cryogenic quick-disconnect at each PROBE/SKIP collar. |
| PROBE refuelling | ∼6,654 kg propellant per mission. ARM robot connects transfer lines. ∼4–8 hr fill per vehicle. |
| SKIP refuelling | ∼95–303 kg per hop (range-dependent). Rapid turnaround: ∼1–2 hr fill. |
| Safety | H₂ leak detection (SENTINEL H₂ sniffers). No pressurised connections to habitat. Crew EVA only in non-transfer periods. |

# 11. Adaptive Fishbone Layout
The bilateral fishbone sub-station network is not a fixed geometry. Its layout is driven by the ice concentration map produced by SURVEY orbital mapping during Phase 0/P2 (refined by MOLE-I ground-truth at each new branch) (Section 2.3). This section describes how the map translates into infrastructure placement.
## 11.1 Layout Rules
Rule 1 — Trunk route follows ice: The spine cable enters the crater at CLP and extends along the PSR floor. Its route is chosen to traverse the highest-concentration ice zones identified by the SURVEY map, not simply the geometric centre of the crater.
Rule 2 — Branches target confirmed ice: Bilateral branches extend perpendicular to the spine. Branch length and direction are set to reach confirmed ice zones (≥3% wt). If the ice map shows a high-concentration patch 300 m north of the spine but low concentration to the south, the branch extends north only — no southern branch at that junction.
Rule 3 — Nodes placed on ice, not on grid: Sub-station nodes are placed at the specific locations along each branch where ice concentration justifies the cost of drilling. If a branch has high ice at 100 m and 300 m from the spine but a dry patch at 200 m, nodes are placed at 100 m and 300 m. The 200 m position is skipped. This creates gaps along branches where no sub-station exists.
Rule 4 — Minimum concentration threshold: A node is only placed where the SURVEY map shows ≥3 wt% ice over the 72° × 200 m sector (∼25,000 m²) that the 5 MOLE-I units will mine. Below 3%, the yield per MOLE-I drops below the operational break-even point (where the cost of operating and maintaining the node exceeds the propellant value).
Rule 5 — Trunk initial length is ice-determined: The trunk cable is not deployed to a fixed length. It extends only as far as confirmed ice zones require. If the SURVEY map shows all viable ice within 2 km of the CLP, the trunk is 2 km — not the full 8.4 km to the opposite wall. This saves cable mass, pipeline heating power, and deployment time. The trunk is designed to be extended later if new ice zones are identified further from the CLP.
## 11.2 Implications for Infrastructure
| Infrastructure | Fixed-Grid Assumption | Adaptive Layout Reality |
|---|---|---|
| Trunk cable length | 8.4 km (full crater traverse) | Variable: as short as ∼2 km if ice is concentrated near CLP |
| Number of branch junctions | 12 at 500 m spacing | Variable: only where branches are needed to reach ice zones |
| Nodes per branch | Evenly spaced to branch end | Irregular: nodes only at confirmed ice locations |
| Total MOLE-I count | Unchanged (demand-driven) | Same demand, but distributed differently across fewer/more nodes |
| Pipeline heating | 93–139 kW (7 W/m trunk+spine, 1.5 W/m branches; variable with deployed length) | Proportional to actual deployed pipe length. Could be ∼20–40 kW. |
| Trunk cable mass | 45.7 t (full length) | Proportional to actual length. Could be ∼10–30 t. |
| Deployment time | Fixed sequence | Phased: deploy trunk incrementally as ice zones are confirmed |

## 11.3 Phased Trunk Deployment
The trunk cable need not be deployed in a single campaign. Initial deployment extends the trunk to the nearest confirmed ice zone (∼500–2,000 m from CLP), installs the first 2–4 branches, and begins operations with 10–20 MOLE-I. As operations proceed and additional SURVEY mapping extends the known ice distribution, the trunk is incrementally extended and new branches are added. This phased approach:
✓ Reduces initial infrastructure mass and deployment risk
✓ Defers cable and pipe investment until ice is confirmed in each zone
✓ Allows operational experience to inform subsequent layout decisions
✓ Matches the fleet scaling profile (10 → 25 → 50 → 85 → 170 MOLE-I)

# 12. End-to-End Mass and Energy Balance
This section traces 1 kg of drilled regolith through the complete chain to delivered propellant.
12.1 P7+ Annual Production Summary (MATLAB v5.0 Verified)
At P7+ full scale (170 MOLE-I across 34 substation nodes, 80% fleet availability): 170 × 190 cycles/yr × 50 kg water/cycle × 0.722 propellant conversion = 967.6 t/yr LH₂/LOX propellant. Demand: PROBE 30 × 6,654 kg = 199.6 t/yr + SKIP 8 × 303 kg × 274 hops = 664.8 t/yr + life support 3.2 t/yr = 867.6 t/yr. Surplus: +100 t/yr (+11.6%), directed to DART propellant accumulation and strategic stockpile (925 t target by P7+). Electrolysis: 17 active + 2 spare PEM stacks at 49.1 kW each = 883 kW total (40–56% of base power demand at every phase). Cryogenic liquefaction: 256 kW (passive cooling) to 412 kW (full active cooling per MATLAB v5.0). Total ISRU plant power: 1,139–1,295 kW at P7+.
12.2 KREEP Beneficiation (Physical Concentration, Stage 1 Only)
The beneficiation module is co-located at the ISRU zone. It performs Stage 1 physical concentration of raw KREEP regolith delivered by SKIP (877 t/yr at P7+, 8 SKIPs × 274 hops × 400 kg) and Ni-Fe/PGM ore delivered by PROBE (45 t/yr at P7+). Three-stage process: (1) jaw crusher (reduces to <10 mm), (2) vibrating screens (size classification), (3) magnetic drum separators (exploits paramagnetic REE-bearing minerals). Mass recovery: ~4% (877 t/yr KREEP input → ~35 t/yr concentrate + ~842 t/yr tailings to stockpile). No hydrometallurgy — physical separation only. Future hydromet facility (sulfuric acid bake-leach for REE, chloride/ozone for PGM) is a Phase 6+ decision gate (SEL-IZ-001 Rev A §17). Power: ~50 kW. Dust-contained: enclosed N₂ atmosphere, PTFE seals.
★ Programme KREEP output figures represent Stage 1 physical beneficiation only. No hydromet processing, no PKT second-base operations included in current figures. DART is a pathfinder for PKT ground-truth data, not a production vehicle.
12.3 Original End-to-End Mass Trace (1 kg regolith)
| Stage | Input | Output | Waste/Loss | Energy |
|---|---|---|---|---|
| 1. Drill | 1.000 kg icy regolith | 1.000 kg fragmented | 0 (mechanical only) | 200 W shared across 25 kg/hr |
| 2. mini-VEX | 1.000 kg fragmented | 0.038 kg liquid water + 0.955 kg dry tailings | 0.007 kg ice loss (15%) | 1,200 W for 25 kg/hr batch |
| 3. Pipeline | 0.038 kg water | 0.038 kg water (at surface) | Negligible evap loss in sealed pipe | 0.6 W pumping share per kg/hr |
| 4. Purify | 0.038 kg raw water | 0.037 kg clean water | ∼0.001 kg waste (backflush) | 0.4 kW total plant |
| 5. Electrolyse | 0.037 kg water | 0.004 kg H₂ + 0.033 kg O₂ | Negligible | 5.5 kW per kg/hr water |
| 6. Liquefy | 0.004 kg H₂ + 0.033 kg O₂ | 0.004 kg LH₂ + 0.033 kg LOX | Boil-off (re-liquefied) | ∼12 kW per kg/hr H₂ |
| 7. Deliver | 0.037 kg propellant | 0.027 kg usable (0.722 × 0.037) | Transfer losses ∼2% | Negligible |

Bottom line: 1 kg of drilled regolith yields ∼0.027 kg of usable propellant (∼2.7% mass recovery). The 95.5% dry tailings and 15% ice loss are the dominant mass sinks. Energy cost: ∼74 W per kg/hr of regolith drilled, or ∼2,700 W per kg/hr of propellant produced. At P7+ scale (170 MOLE-I), this is ∼1,785 kW continuous — dominated by electrolysis (883 kW) and cryogenics (256 kW).

# 13. Contingencies and Failure Modes
| Failure | Impact | Mitigation |
|---|---|---|
| Ice fraction < 3% at Shackleton | Yield below break-even. Programme unviable at this site. | GATE 1: Relocate to Cabeus (confirmed ice). Accept solar penalty (∼1.3× power budget). Cabeus infrastructure is ∼30% less mass (shorter trunk). |
| Ice heterogeneity (dry patches) | Some nodes under-produce; others over-produce | Adaptive layout (Section 11). Move MOLE-I from depleted sectors to productive ones. Reassign nodes between branches. |
| Pipeline freeze | Water supply interrupted. 2–4 week replacement. | Dual pipeline from Phase 5. SENTINEL continuous thermal monitoring. UPS on trace heating circuit. |
| PEM membrane contamination | Electrolyser output drops; membrane replacement needed | Stage 4 purification with automated quality monitoring. Spare membrane stacks in cargo manifest. |
| 20 K cryocooler TRL gap | Cannot produce LH₂ at programme scale | Oxygen-first fallback: produce LOX (90 K, high TRL) on-site. Import LH₂ from Earth until 20 K tech matures. Reduces ISRU independence but keeps programme running. |
| Carbon/FeOx consumable resupply failure | Purification beds exhausted; electrolyser feed degrades | ∼6-month bed life margin at rated capacity. Stockpile 2 years of consumables on-site. ∼2 t buffer. |
| Trunk pump failure | No water flow to surface | Dual pump at CLP (one active, one cold spare). Pump is small (∼15 kg) — spare is cheap insurance. |

# 14. Document History
| Rev | Date | Description |
|---|---|---|
| A | March 2026 | Initial release. Comprehensive ISRU process flow specification addressing gaps identified during thermal verification campaign. Includes: water purification process train (new), ice heterogeneity and dual-crater prospecting strategy (new), adaptive fishbone layout rules (new), pipeline pressure rating gap (flagged), 20 K cryocooler TRL risk (flagged), consumable resupply requirement quantified. |

ECN-014 Amendment — Inter-Zone Transfer Line Isolation (March 2026)
Reference: SEL-PIPE-001 Rev A
§7.4 Cryo Transfer Line Isolation Valves (NEW): The LH₂ and LOX vacuum-jacketed transfer lines from the ISRU transfer manifold (X = +30 m) to the IZ propellant farm (200–500 m) shall be fitted with isolation valves at both ends. Each end: 1× pneumatically actuated cryogenic ball valve (fail-closed, spring return, <2 s closure, PTFE/Vespel seats rated 20 K/90 K) + 1× passive excess flow check valve (spring-loaded, trip at 3× normal flow, <100 ms response). ISRU end includes burst disc (10 bar, venting to vacuum via directed nozzle). Each valve station enclosed in sintered shelter (500 mm walls, 2×2×2 m). H₂ leak detection: 2× catalytic sensors (10 ppm threshold) + UV flame detector per station. SENTINEL auto-close at 1,000 ppm H₂ or UV flame or pressure >5 bar or comms loss >60 s. Total mass: ~140 kg (4 valve stations). Valves remain open during normal continuous flow — no chilldown penalty in steady state.
§8.2 O₂ Supply Pressure Regulation (NEW): The gaseous O₂ line from gas separation (X = +5 m) to the hab utility conduit shall be fitted with: (1) dome-loaded pressure regulator at ISRU exit, set 300 kPa, fail-closed, inlet rated 30 bar, oxygen-cleaned per ASTM G93; (2) spring-loaded relief valve downstream of regulator, set 500 kPa, venting to vacuum; (3) pneumatically actuated isolation valve, fail-closed, <5 s closure, SENTINEL-triggered. These are in addition to the existing double-block-and-bleed at hab entry (HAB-001 §10). The combined system provides four independent barriers between 30 bar PEM output and 101.3 kPa hab atmosphere. A check valve at hab entry (upstream of double-block-and-bleed) prevents reverse flow during hab depressurisation. Total mass: ~23 kg.
§12 Energy balance addendum: Isolation valve actuation power is negligible (GN₂ pneumatic, no continuous electrical draw). SENTINEL monitoring adds <5 W per station (included in existing SENTINEL power budget). No impact on ISRU plant power total.
⚠ Residual risk: Initial pressure wave from ISRU tank rupture arrives at IZ in ~0.45 s (speed of sound in LH₂ ~1,100 m/s over 500 m), before any active valve can close. Excess flow check valve provides passive first response. Pressure wave attenuation analysis over 500 m in 100 mm VJ pipe is a verification item (SEL-PIPE-001 §6, item 3, owner: Grant).
ECN-015 Amendment — Multi-Crater Scaling + PKT Demand (March 2026)
Reference: SELENITE_SCALE v1.1
§11 Adaptive Layout addendum — Multi-Crater Operations: At P8+, Shackleton alone cannot meet the propellant demand for tanker/mass driver operations supplying PKT. ISRU operations expand to additional permanently shadowed regions: Cabeus (estimated 5.6% ice by mass, ~10 km diameter floor), Haworth (~4% ice, adjacent to Shackleton), Faustini (~4% ice). Each new crater follows the same fishbone pipeline + substation architecture as Shackleton. MOLE-I fleet, substations, and trunk cable are replicated per crater. Water from all craters is pumped to the Shackleton rim ISRU plant (or to dedicated electrolysis units at each crater rim). SELENITE_SCALE v1.1 estimates: 1 ice site at P7, 31 at P8, 242 at P9, 1,819 at P10, 12,061 at P11, 120,608 at P12.
§12 Energy Balance addendum: At P12, ISRU electrolysis + cryo power at Shackleton alone reaches ~590 GW. This vastly exceeds solar array capacity on any single crater rim. Power at this scale transitions from solar+FSP to dedicated fusion or advanced nuclear (speculative beyond P10). For P7–P9, the existing solar + 5× FSP architecture remains valid. P10+ power architecture is flagged as requiring a dedicated power scaling study (SEL-POWER-002, future document).
— End of Document —
ECN-012 Amendment — Dump Cycle Update (March 2026)
§6.1 Batch Dump: Process steps updated per ECN-012 rear drain pipe reroute.
Step D (revised) — Pre-heat: When the MOLE-I tank level reaches 90% (~45 L), the WEB controller activates the rear drain pipe trace heater (SEL-MI-PIP-030) at 15 W. The 1,350 mm Ti pipe heats from 40 K to ~280 K during the remaining ~4.5 hr of fill time. Drilling continues normally — the heater draws from the tether (1,934 W budget) and does not affect drilling power.
Step E (revised) — Retraction and dump: MOLE-I reverses to substation (33 min at 0.1 m/s). Heater remains on. On docking, bottom-drain valve opens. Water flows through heated pipe (280 K) to rear nozzle, drops into substation funnel. Dump: ~15 min.
Step F (new) — Pipe purge: After valve closure, heater holds for 3 minutes. Residual water drains under 1/6 g gravity (pipe slopes ~2° to rear) and evaporates at the vacuum-exposed nozzle. After 3 min the pipe is confirmed clear (deterministic geometry — no sensor feedback required). Heater deactivates. Pipe cools to 40 K passively (~30 min).
Timing impact: Cycle time 1.40 → 1.45 hr (+3 min purge). Availability 97.1% → 96.8%. Negligible impact on annual propellant yield.
§12 Energy balance: Add 1.7 W average per MOLE-I to continuous draw (15 W × 11.5% duty). At P7+ scale (170 MOLE-I): +289 W programme-wide. Negligible against 1,785 kW total ISRU demand.
⚠ If purge is interrupted (power glitch), residual water freezes in pipe. Recoverable: next pre-heat cycle (30 min at 15 W) melts any ice plug. Repeated freeze-thaw cycling flagged for Ti fatigue review (SEL-ECN-012 §7, verification item 4).