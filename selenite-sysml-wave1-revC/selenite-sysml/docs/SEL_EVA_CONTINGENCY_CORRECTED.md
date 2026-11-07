<!-- Markdown extract of docs/sources/SEL_EVA_CONTINGENCY_CORRECTED.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

Emergency Crater EVA Contingency
Thermal Engineering Requirements & Crater Access Pod Concept
Audited and corrected from original synthesis  |  March 2026
This document contains the factually corrected content from the original EVA contingency analysis. All claims flagged in the technical audit have been corrected or caveated. Figures confirmed by primary sources are marked as VERIFIED. Figures requiring further research before programme commitment are marked as CAVEAT. This material is intended for integration into the GUIDE, FLEET, and STRATEGY documents.
# 1. The PSR Thermal Environment
## 1.1 Radiative Heat Transfer in PSRs
In Earth orbit and at equatorial lunar latitudes, the dominant heat exchange between a spacesuit and its environment is radiative. Radiative power follows the Stefan-Boltzmann law, scaling with T⁴ (a quartic relationship, not logarithmic as previously stated). However, the practical consequence of this T⁴ dependence is that once the environment drops below roughly half the emitter’s temperature, further cooling yields diminishing returns in net radiative flux.
Quantitatively: at Tenv = 144 K, the cold environment’s T⁴ contribution is only ~5.3% of a 300 K emitter’s output. This means net radiative heat loss is already ~95% of its theoretical maximum. Going from 144 K down to absolute zero gains only that remaining ~5%. The 144 K threshold cited in the original text is therefore defensible as a practical inflection point, but the mechanism is quartic, not logarithmic.
Source: Stefan-Boltzmann law; CERN Accelerator School lectures on Heat Transfer (Baudouy, CERN-2014-005).
## 1.2 Conductive Heat Transfer: The Real Threat
The critical threat in PSRs is conductive heat transfer through direct contact: boots on frozen regolith and gloves on tools or cable. Fourier’s law (q = k · A · ΔT / d) shows conduction scales linearly with the temperature difference (ΔT) between the suit contact surface and the ground, not with the absolute temperature of either surface.
Critical nuance: The thermal conductivity (k) of lunar regolith is not constant across temperature. It drops dramatically at cryogenic temperatures. Chang’E-4 surface measurements gave k ≈ 1.53 × 10⁻³ W/m·K at the surface. Woods-Robinson et al. (2019, JGR:Planets 124:1989–2011) found conductivities could fall to 10⁻⁵ to 10⁻⁴ W/m·K below 50 K. Martinez & Siegler (2021, JGR:Planets 126:e2021JE006829) confirmed lunar regolith is substantially more insulating at low temperatures than previously assumed.
This means simple ΔT scaling overestimates actual conductive heat loss in PSRs. The regolith itself becomes an increasingly effective insulator as it gets colder, partially offsetting the larger temperature difference. However, conduction through metallic hardware (tools, cable, WEB module housings) does not benefit from this effect — metal thermal conductivity remains high at cryogenic temperatures, making tool and cable contact the dominant conductive threat.
CAVEAT: The original conduction multipliers (7× at 40 K, 10× at 25 K) were internally inconsistent — no single suit contact temperature produces both ratios. The correct framing is: the temperature difference driving conductive loss increases by a factor of ~7–8× compared to a 273 K surface (for any consistent boot sole temperature assumption), but actual heat flux increase is less than this due to the drop in regolith thermal conductivity at cryogenic temperatures. Olthoff et al. (2022) found the effective thermal environment changes less than surface temperature alone suggests. Quantitative modelling using PSR-specific regolith conductivity data is required before programme-specific conductive loss rates can be committed.
# 2. Spacesuit Requirements for PSR Operations
## 2.1 xEMU / AxEMU Design Envelope
VERIFIED: The xEMU (now developed as AxEMU by Axiom Space under NASA contract) has a design target of two-hour exposure duration in a PSR where temperatures are estimated to be 40 K. This figure comes from NASA’s ICES-2024 paper (NTRS 20240004528). Axiom Space confirmed the AxEMU enables work in PSRs for at least two hours. The broader xEMU thermal range spans 93 K (cold south pole) to 378 K (hot lunar crater), with 40 K specifically for boot contact duration in PSRs.
CAVEAT: The 2-hour limit is a design target, not a tested and validated result. Boot testing at JPL’s CITADEL chamber has been conducted but results have not been fully published. The programme should not assert a confirmed EVA duration for 25 K wall descent until post-CITADEL data is available. For 25 K wall sections, no design target exists in the public literature — xEMU is sized for 40 K. The ~90-minute estimate for 25 K operations in the original text is a reasonable conservative assumption but is not sourced.
## 2.2 CITADEL Testing Facility
VERIFIED: JPL’s CITADEL (Cryogenic Ice Testing, Acquisition Development, and Excavation Laboratory) chamber uses compressed helium to reach as low as −370°F (−223°C, ~50 K). The chamber is 4 ft tall × 5 ft diameter with four load locks. Originally built for ocean-worlds spacecraft testing, it is now used for spacesuit glove and boot evaluations under NASA’s NESC programme.
VERIFIED: Testing in CITADEL at −352°F confirmed the legacy ISS EMU glove does not meet thermal requirements for the lunar south pole environment. Testing was conducted October 2023 – March 2024.
## 2.3 Cryogenic Fabric Testing
VERIFIED with correction: NASA’s ICES-2025-56 paper (“Artemis Suit Material Project Overview,” NTRS 20250003726) confirms the University of Illinois tested suit fabrics at cryogenic temperatures targeting approximately 83 K, 47 K, and 30 K. Key failure modes include coefficient of thermal expansion mismatch between coatings and fabric, flex cracking, and delamination. Finding a coating that remains flexible at cryogenic temperatures while adhering to fabric remains an open challenge.
CORRECTION: The original text stated the lowest test temperature as “−297°C (30 K).” This conversion is physically impossible — −297°C equals −23.85 K, which is below absolute zero. The correct Celsius equivalent of 30 K is −243°C. This error appears to originate in the NASA source paper itself (likely a unit confusion where −297 was intended as °F, which would equal ~90 K, or the °C figure was miscalculated). For programme documents, state the test points as 83 K, ~47 K, and ~30 K without Celsius conversions from the source paper.
## 2.4 Verified Temperature Conversions
| Stated Value | Kelvin | Correct? | Note |
|---|---|---|---|
| −370°F | 49.8 K | ✓ Yes | CITADEL min temp |
| −190°C | 83.15 K | ✓ Yes | Fabric test point 1 |
| −226°C | 47.15 K | ≈ Off by 1 K | Stated as 48 K; actual 47 K |
| −297°C | −23.85 K | ✗ IMPOSSIBLE | Below absolute zero. 30 K = −243°C |

## 2.5 Layer-by-Layer Suit Requirements (Corrected)
### 2.5.1 Thermal Micrometeoroid Garment (TMG)
The final suit design will likely combine specialised fabrics rather than a single solution: thinner, more dexterous materials in gloves for mobility and tactility, with high-durability abrasion-resistant fabrics for high-wear regions (knees, lower torso). CTE mismatch, flex cracking, and delamination remain the primary failure modes at cryogenic temperatures.
### 2.5.2 Boots
Boots are the thermal sizing case for crater operations. They require multi-layer insulation with a low-conductivity sole that does not rely on air gaps (vacuum eliminates convection), plus structural capacity for the descent traverse on a ~30° regolith slope. Integrated knee pads are under consideration for both thermal and cut protection in AxEMU, addressing the conductive contact area if a crew member kneels to work on a connector or WEB module.
Source: Texas Tech University xEMU xPGS design requirements; JPL CITADEL boot testing programme.
### 2.5.3 Gloves
Gloves remain the most problematic suit element. Bulky thermal layers cause significant dexterity loss, and astronauts cannot gauge how much force they are applying when gripping. In a PSR maintenance scenario, this directly impacts the ability to remove fasteners, swap a WEB module, or re-engage an ARM connector at 40 K. Cryogenic gloves that also preserve useful dexterity are an open research problem, not a solved one.
CAVEAT: Any contingency scenario requiring fine manipulation (connector engagement, fastener removal, electronics swaps) must acknowledge that glove dexterity will be substantially degraded at 40 K. Task design for human intervention should favour coarse operations (physical disconnection, module extraction/insertion by handle) rather than fine assembly.
### 2.5.4 PLSS Thermal Control
The cooling problem in PSRs inverts the standard EVA thermal control paradigm. In sunlit conditions, the suit must aggressively reject metabolic heat. In a PSR at 40 K, the environment extracts heat from the astronaut through conduction while radiative rejection becomes negligible. The PLSS thermal control loop must actively add heat, not reject it. The system must adapt to changing heat loads to maintain the suit’s internal temperature within the narrow band safe for human occupation.
# 3. The Crater Wall Descent
A contingency EVA is not simply a walk across the PSR floor. It involves descending the crater wall on the ARM winch or a dedicated crew descent line. This creates distinct requirements beyond those of floor-level EVA:
- Sustained glove contact with a cryogenic cable at potentially 25 K during rappel (~8.3 km traverse at ~30° slope), though a powered winch substantially changes the contact profile
- Suit mobility requirements for a 30° slope on icy regolith without slipping (boot traction on regolith-ice composite)
- No radiation shelter during descent — crater wall sections receive scattered galactic cosmic radiation without the thermal mass of the base above
Design requirement: A powered winch descent with the astronaut as passenger (harness interface, not continuous gripping) is far preferable to rappelling. This should be treated as a design requirement for the ARM infrastructure: crew-safe descent mode with harness interface, not just cargo/robot transport.

# 4. Crater Access Pod (CAP) Concept
The CAP is a pressurised, thermally insulated crew pod riding a dedicated descent winch down the crater wall on its own guide cable, independent from the ARM trunk cable and propellant line. Crew transit in a warm, pressurised environment and arrive at the basin floor operational, rather than having spent 45+ minutes in a thermally stressed EVA suit. The pod then functions as a surface shelter and suit donning/doffing station.
## 4.1 What the CAP Solves
The 25 K transit problem is the right one to eliminate at the architectural level. During descent, the dominant thermal threat is conductive (through boots/gloves to cable and contact surfaces), and there is no fully validated solution for a suit that handles 25 K contact while remaining dexterous enough for maintenance work. The pod removes this problem entirely for the ~45-minute transit each way. It also provides radiation shielding geometry (crater regolith above and laterally attenuates GCR during descent) and a pressurised staging area at the floor.
## 4.2 Pressure Vessel
A ~4–6 m³ usable internal volume fits two crew in IVA suits, plus tools and a suit donning area. The construction would be aluminium alloy, designed for 101 kPa at sea-level atmospheric composition or 65 kPa at a reduced-O₂ exploration mix.
CORRECTION: The original text used the ISS Quest Joint Airlock as a sizing analogue with dimensions of “~2.3 m diameter × 3.9 m length.” These dimensions are incorrect. The Quest Joint Airlock is 4.0 m diameter × 5.5 m overall length, with a total volume of 34 m³ and mass of ~6,064 kg. It contains two compartments: the Equipment Lock (25.7 m³) and the Crew Lock (8.8 m³). No known Quest dimension corresponds to the figures originally cited. The CAP’s 4–6 m³ volume target is smaller than either Quest compartment and represents a purpose-built design rather than an airlock derivative.
## 4.3 Thermal Management
In vacuum with no convection, MLI performs well. Published data from Fesmire et al. (NASA KSC / CERN, ICEC19) shows 30-layer perforated MLI at 0.87 W/m² and 80-layer systems at 0.30 W/m² under high vacuum at 293–78 K boundaries. NASA’s VDMLI achieved 0.22 W/m² at 305 K to ~20 K.
CORRECTION: The original text stated the pod’s total heat loss through MLI would be 5–10 W for a ~10 m² surface. While the MLI-only arithmetic (0.5–1 W/m² × 10 m²) is valid for ideal laboratory conditions, this neglects what NASA KSC’s Fesmire et al. (2019, NTRS 20190030314) call the “Cold Triangle” of cryogenic heat leak: insulation losses, structural support conduction, and piping/penetration losses. Hatches, electrical feedthroughs, viewport frames, and mounting struts each create thermal short-circuits. Real-world installed MLI performance is typically 2–3× worse than lab values due to seams, penetrations, and compression. Realistic total heat loss for a CAP-sized pod is likely 20–50+ W.
The qualitative conclusion — that crew metabolic heat exceeds total losses — remains valid (see corrected metabolic figures below). The safety margin is roughly 6–15×, not the 30–60× implied by the original analysis. Thermal isolation of mechanical suspension points (guide cable attachments, mounting brackets) requires PEEK or Torlon structural thermal break inserts at every contact point to prevent conductive short-circuits to the 25 K wall.
## 4.4 Metabolic Heat Output (Corrected)
CORRECTION: The original text stated “~300 W combined” for two crew (~150 W per person). This figure is appropriate only for resting or seated light work in a shirtsleeve environment. NASA’s EMU design metabolic rate is 293 W per person (1,000 BTU/hr), with actual Shuttle EVA averages of ~220 W (Campbell, NTRS 20000081742). Apollo lunar EVAs reached up to 700 W per person during high activity. For the programme, use the following:
| Activity State | Per Person | Two Crew Combined |
|---|---|---|
| Resting inside pressurised pod | ~150 W | ~300 W |
| Light IVA work (suit donning, monitoring) | ~200 W | ~400 W |
| EVA work on basin floor | 220–300 W | 440–600 W |
| Peak EVA activity (Apollo analogue) | up to 700 W | up to 1,400 W |

The pod’s thermal balance should be modelled against the resting/light IVA case (300–400 W input vs. 20–50 W loss), which still gives a comfortable positive heat balance. The PLSS cooling system, however, must be sized for the EVA case once crew exit the pod.
## 4.5 Transit Mechanics
At 30° slope and 8.2 km traverse distance, assuming a conservative 3 m/s descent speed (consistent with mine personnel cage practice): transit time is approximately 45 minutes each way. Total mission profile: ~45 min descent → 2–4 hr work window at floor → ~45 min ascent. Total pod occupancy time of ~4–5 hours is within standard life support sizing for a 2-person system.
## 4.6 Cable Tension and Winch Requirements
VERIFIED: The cable tension calculation is arithmetically correct:
T = m × gmoon × sin(θ) = 1,300 × 1.62 × sin(30°) = 1,300 × 1.62 × 0.5 = 1,053 N
With a 5× safety factor for crew transport: design winch tension of ~5,300 N. This is a modest cable and winch specification. However, given crew safety criticality, the CAP must use a completely independent dedicated winch: separate cable, separate mounting structure at the rim, separate power feed. It may tap the trunk cable for electrical power but nothing in its mechanical chain touches the MOLE-I infrastructure.
## 4.7 Mass Budget (Corrected)
| Component | Mass (kg) | Confidence |
|---|---|---|
| Pressure vessel (Al alloy) | 300–400 | MED |
| MLI + internal thermal hardware | 60 | MED |
| Life support (2 crew × 5 hr) | 120 | MED |
| EVA egress hatch + sealing system | 80 | MED |
| Guide rail interface + suspension brackets | 100 | LOW |
| Internal lighting, comms, monitoring | 30 | MED |
| Structure margins + contingency | 60 | LOW |
| Dry pod total | ~800 |  |
| 2 crew (100 kg each) | 200 | HIGH |
| 2 EVA suits (est. ~130 kg each) | 260 | LOW |
| Tools + equipment | 100 | LOW |
| Loaded total | ~1,360 |  |

CAVEAT: EVA suit mass of 130 kg each is estimated but unverified. Axiom Space has not publicly disclosed AxEMU mass. Legacy ISS EMU weighs ~127 kg. Scientific American (2025) reported the AxEMU is “more than” previous suits. The 130 kg figure is within the expected 100–150 kg range but cannot be confirmed from any public source. This is a LOW confidence figure.
## 4.8 Space Weather Warning Times
CORRECTION: The original text stated NOAA/ESA systems provide 30–60 minutes of warning for solar particle events. This is oversimplified and potentially dangerous if relied upon for mission planning. Warning times vary enormously by particle energy and event type:
- Highest-energy protons (>500 MeV) can arrive in as little as ~10 minutes with essentially no advance warning (NOAA SWPC)
- REleASE concept (Posner, 2007) uses relativistic electron precursors to warn of slower proton arrival — this may be the source of the 30–60 minute figure
- ESPERTA model gives a median 4.8 hours but a minimum of only 24 minutes for ≥S1 events
- CME plasma itself takes 1–3 days to arrive
For programme documentation, state: “Solar particle event warning times range from minutes to hours depending on particle energy. The highest-energy protons may arrive with as little as ~10 minutes of warning. CAP operations require a standing abort protocol that triggers immediate ascent upon any SPE forecast, with the pod itself serving as a partial radiation shelter during emergency ascent.”
# 5. Remaining Requirements After CAP
The pod handles transit, not work. Once crew exit the pod at the basin floor, they are in the 40 K PSR environment and still need AxEMU-generation 40 K-rated suits with full boot and glove thermal protection. The pod functions as:
- A transit vehicle (eliminates 25 K suit requirement for descent/ascent)
- A pressurised staging base at the floor (crew can warm up, swap O₂, rest)
- An emergency shelter — if a suit failure occurs during floor operations, crew can retreat inside without completing ascent in a compromised suit
Net effect: Suit requirements change from “25 K wall-rated” to “40 K floor-rated,” which is a materially easier specification and one that AxEMU is already designed toward.
# 6. Infrastructure & Phasing Implications
The CAP requires its own independent winch station at the crater rim: a surface installation with powered winch drum, cable guide, and structural anchor. This is Phase 2+ infrastructure (no resident crew during Phase 1). However, the guide cable anchor points should be designed into the crater wall traverse infrastructure during initial ARM deployment in Phase 1. Retrofitting anchor points later is substantially harder. This is a design reservation in the ARM infrastructure spec: designate anchor locations during Phase 1 construction even if the winch equipment is not installed until Phase 2.
The pod is also a dual-use logistics asset: before crew arrival, it can descend empty as an equipment carrier, delivering tools and replacement WEB modules to the basin floor without requiring MOLE-I to bring them. This makes it useful even before any human enters it.
# 7. Recommended Programme Framing
For the GUIDE, FLEET, and STRATEGY documents, the following framing is recommended:
“Contingency human crater access is architecturally supported by the ARM winch infrastructure and the Crater Access Pod (CAP), a dedicated pressurised descent vehicle independent from the trunk cable and propellant line. The CAP eliminates the requirement for a 25 K-rated EVA suit during the ~45-minute wall transit. On arrival at the basin floor, crew operate in AxEMU-generation 40 K-rated suits within the validated 2-hour PSR exposure envelope. The CAP also serves as a pressurised staging base, tool transport vehicle, and emergency shelter. Autonomous systems remain the primary contingency response; human descent via CAP is a last-resort option with a hard time limit set by suit thermal margins (~2 hours at 40 K, design target) and limited fine manipulation capability due to cryogenic glove constraints. CAP infrastructure is Phase 2+; Phase 1 reserves guide cable anchor points on the ARM structure.”
# 8. Resource Implications for Mission Planning
The following resource demands should be considered when integrating the CAP and EVA contingency into fuel, power, and material budgets:
## 8.1 Mass to Lunar Surface
CAP dry mass of ~800 kg plus winch infrastructure (estimated ~200–400 kg for drum, cable, motor, anchor structure) requires delivery of approximately 1,000–1,200 kg to the crater rim in Phase 2. This is within a single Starship cargo manifest allocation but must be planned.
## 8.2 Power
The CAP winch motor must haul ~1,360 kg loaded mass up a 30° slope at 3 m/s. Mechanical power required: P = F × v = 1,053 N × 3 m/s ≈ 3.2 kW mechanical. At ~80% motor efficiency, electrical demand is ~4 kW during ascent. This is drawn from the trunk cable power supply over the ~45-minute ascent, totalling ~3 kWh per ascent. Pod internal systems (life support, lighting, comms) draw an estimated 0.5–1 kW continuous. Total peak power demand during ascent: ~5 kW. This should be added to the Phase 2 power budget as a contingency allocation (not baseload).
## 8.3 Life Support Consumables
For a 5-hour mission (transit + work + return): O₂ consumption at ~0.84 kg/person/day (NASA ISS rate) = ~0.18 kg O₂ per person for 5 hours, or ~0.35 kg for two crew. CO₂ scrubbing via LiOH canisters: ~0.5 kg per canister, 1–2 canisters per mission. Water for cooling: ~2–4 kg. Total consumables per CAP mission: ~3–5 kg, drawn from base stores. This is negligible in the context of overall ECLSS budgets but must be tracked and restocked.
## 8.4 Propellant Impact
The CAP itself has no propellant requirement (it is winch-driven, not rocket-powered). However, any EVA work at the basin floor that involves topping up MOLE-I propellant reserves or servicing the propellant line draws from the same propellant budget. The programme should reserve a contingency allocation of propellant stores equivalent to one SKIP hop (~TBD, dependent on SKIP ΔV correction from the technical audit) for any floor operations that might require emergency propellant transfer.
## 8.5 Materials
Key materials for CAP construction: aluminium alloy (pressure vessel, ~300–400 kg), MLI blankets (~30–40 m² of layered aluminised Mylar/Dacron netting), PEEK or Torlon thermal break inserts (all mechanical contact points), high-strength steel or Vectran cable for the descent line (must be rated for cryogenic temperatures; Dyneema excluded below ~100 K per programme materials policy), and polyethylene radiation shielding panels (optional, ~50–100 kg if SPE protection is added to the pod walls).

# Appendix: Audit Corrections Summary
| Original Claim | Verdict | Correction Applied |
|---|---|---|
| Radiative flux is “logarithmic” | INCORRECT | Changed to “quartic (T⁴)” per Stefan-Boltzmann law. 144 K threshold retained. |
| Conduction “scales linearly with temperature” | IMPRECISE | Corrected to “scales linearly with ΔT”; added regolith k drop at cryo temps. |
| 7× / 10× conduction multipliers | INCONSISTENT | Replaced with correct ΔT-based framing; caveated for regolith k uncertainty. |
| xEMU 2-hr / 40 K rating | VERIFIED | Retained. Added caveat that it is a design target, not tested result. |
| CITADEL uses helium, reaches 50 K | VERIFIED | Retained as-is. |
| ISS glove fails at lunar south pole | VERIFIED | Retained as-is. |
| −297°C = 30 K | IMPOSSIBLE | Corrected: 30 K = −243°C. Error likely in NASA source paper itself. |
| MLI heat loss 5–10 W total | OPTIMISTIC | Corrected to 20–50+ W including structural conduction and penetrations. |
| Quest Airlock 2.3 m × 3.9 m | INCORRECT | Corrected to 4.0 m diameter × 5.5 m length. Analogue removed; CAP is purpose-built. |
| 150 W/person metabolic rate | TOO LOW | Added table: 150 W resting, 220–300 W EVA, up to 700 W peak. |
| EVA suit mass 130 kg | UNVERIFIED | Retained with LOW confidence caveat. AxEMU mass not publicly disclosed. |
| SPE warning 30–60 minutes | OVERSIMPLIFIED | Corrected: ranges from ~10 min to hours. Standing abort protocol required. |
| Cable tension = 1,053 N | VERIFIED | Retained as-is. Arithmetic confirmed. |
