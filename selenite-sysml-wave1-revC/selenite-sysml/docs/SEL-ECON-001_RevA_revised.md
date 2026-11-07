<!-- Markdown extract of docs/sources/SEL-ECON-001_RevA_revised.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->


SELENITE PROGRAMME
Economic Evaluation Report
200-Year Cost-Benefit Analysis with Environmental Externalities
SEL-ECON-001 Rev A
April 2026
| Field | Value |
|---|---|
| Document | SEL-ECON-001 Rev A |
| Reference | SELENITE_ECON v1.3/v1.4, SELENITE_DECISION_FRAMEWORK v3 |
| Author | Jason Stewart — Systems Engineering Lead |
| Model | Bottom-up infrastructure derivation (MATLAB) |
| Horizon | 200 years (Y0–Y200) |
| Target | 2.5 Mt/yr REO — full replacement of terrestrial REE mining |

# Abbreviations
| Abbreviation | Definition |
|---|---|
| BCR | Benefit-Cost Ratio |
| DAC | Direct Air Capture (for carbon-neutral methane production) |
| DG | Decision Gate |
| DRO | Distant Retrograde Orbit (stable lunar orbit for captured asteroids) |
| ECLSS | Environmental Control and Life Support System |
| EM | Electromagnetic (as in EM catcher, EM anchoring) |
| FSP | Fission Surface Power (NASA Kilopower heritage, 40 kWe) |
| IRR | Internal Rate of Return |
| ISRU | In-Situ Resource Utilisation |
| IZ | Industrial Zone (docking/processing area at SPA) |
| KREEP | Potassium (K), Rare Earth Elements, Phosphorus — lunar geochemical signature |
| LEO | Low Earth Orbit |
| LLO | Low Lunar Orbit |
| MLI | Multi-Layer Insulation |
| MSR | Molten Salt Reactor (thorium chloride, 100 MWe) |
| NPV | Net Present Value |
| PEM | Proton Exchange Membrane (electrolyser for H₂ production) |
| PGM | Platinum Group Metals (Pt, Pd, Ir, Ru, Rh, Os) |
| PKT | Procellarum KREEP Terrane (nearside lunar mare) |
| REE | Rare Earth Elements |
| REO | Rare Earth Oxide(s) |
| SCC | Social Cost of Carbon |
| SEP | Solar Electric Propulsion |
| SPA | South Pole–Aitken (basin); refers to Shackleton Crater base |
| SRM | Switched Reluctance Motor |
| SS | Steady State (post build-out, maintenance operations only) |
| YBCO | Yttrium Barium Copper Oxide (high-temperature superconductor for mass drivers) |

# Executive Summary
The Selenite Programme is a 200-year lunar rare-earth extraction and asteroid mining initiative designed to fully replace terrestrial REE mining by approximately 2205 (Y180). This economic evaluation uses a bottom-up model (SELENITE_ECON v1.3) that derives all infrastructure requirements and Earth cargo from REO production targets and unit specifications, with no hard-coded cargo values.

| Metric | Value |
|---|---|
| Total programme cost (200 yr) | $21.3 T |
| Total revenue + externalities | $15.6 T |
| NPV (all externalities, declining 3/2.5/2%) | −$0.49 T |
| BCR (200-year, all externalities) | 0.50 |
| BCR (annual, steady state Y180+) | 2.06 |
| Steady-state net surplus (Y180+) | +$121.8 B/yr |
| Average annual programme cost | $106 B/yr (4.7% of global military spending) |
| CO₂ avoided at steady state | 182 Mt/yr |
| Lifetime rocket CO₂ | 52 Mt (0.03% of benefits) |
| Earth cargo (200 yr) | 5.6 Mt |
| IRR (all externalities) | −2.54% (requires intergenerational weighting) |

The programme is not commercially viable on direct revenue alone ($1.48 T revenue versus $21.3 T cost). The economic case rests entirely on internalised externalities: avoided terrestrial mining damage ($10.4 T), hydrogen-economy enabling via iridium ($2.6 T), and geopolitical supply-chain insurance ($1.2 T). This requires government-consortium funding, consistent with Arrow et al. (2014) recommendations for intergenerational public goods and comparable to ITER, ISS, and climate mitigation programmes.
At steady state (Y180+), the programme generates $2.06 in benefits for every $1 in cost, comparable to mature highway and power infrastructure. The 200-year BCR of 0.50 reflects the mathematical limitation of discounted analysis applied to multi-century timescales, not a fundamental economic weakness.

# 1. Programme Architecture
## 1.1 Base Specialisation
SPA (Shackleton Crater, South Pole–Aitken Basin): Asteroid processing hub for all captured asteroid types (M-type PGM/Fe-Ni, C-type water/carbon/nitrogen, S-type silicon/copper). Serves as crew base (20 personnel), PROBE operations centre, ISRU propellant depot, and deep-space launch hub (P14+). All asteroid-derived material is processed at SPA — PGM hydromet, pyrolysis, Fischer-Tropsch polymer synthesis, Czochralski silicon refining, copper electrolysis. Products shipped to PKT via mass driver where needed for circuit fabrication.
PKT (Procellarum KREEP Terrane): KREEP REO processing only. Every square kilometre of PKT surface is valuable KREEP ore — non-mining infrastructure (processing spine, MSR fleet, foundry) is positioned at the PKT/highlands boundary to maximise accessible ore area. Spine faces inward to the ore field; MSRs and foundry sit on the non-KREEP side. PKT houses processing circuits, haulers, conveyors, SINTER construction fleet, and thorium MSR power plant. Fully autonomous (zero permanent crew; temporary 3–4 person commissioning crew at P8 only).
## 1.2 Mass Driver Network
| ID | Route | Velocity | Track | YBCO | Year |
|---|---|---|---|---|---|
| MD-1 | SPA→PKT | ~1,800 m/s | ~3.3 km | ~60 t | Y25 (P8) |
| MD-2 | PKT→Earth | ~2,400 m/s | ~5 km | ~100 t | Y35 (P9) |
| MD-3 | PKT→SPA | ~1,800 m/s | ~3.3 km | ~30 t | Y43 (P9–P10) |
| MD-4 | SPA→Earth | ~2,400 m/s | ~5 km | ~60 t | Y70 (P11) |
| MD-5 | DRO→SPA | ~800 m/s | ~500 m | ~30 t | Y85 (P12+) |

Total YBCO: ~280 t lifetime (compared with ~209,000 t for the 9,084 catapult hubs in the original architecture).
## 1.3 PROBE Fleet Lifecycle
| Class | Era | Fleet | Propulsion | Lands? | Missions/yr |
|---|---|---|---|---|---|
| Mk I | P5–P8 | 30→96 | Chemical | Yes (SPA IZ) | 1 |
| Mk II Heavy | P9–P11 | 190→260 | Chemical | Yes (SPA IZ) | 1 |
| Mk I/II phasedown | P11+ | 260→30 | Chemical | Yes | 1 |
| Mk III SEP | P11+ | 0→1,714→300 | Ion | Never | 0.5 |

Mk III PROBEs never land on the Moon. They eject Fe-Ni/PGM payload canisters from low lunar orbit on ballistic deorbit trajectory, received by an electromagnetic catcher at SPA (~1,680 m/s, same YBCO technology as mass drivers). Mk III uses electromagnetic anchoring on M-type asteroid surfaces (ferromagnetic Fe-Ni), eliminating harpoons or drills. Decommissioned Mk I/II units are salvaged at SPA for Fe-Ni recycling (~184 t recovered). Recovered Pu-238 from MOLE-I radioisotope thermoelectric generators is stockpiled at SPA for future deep-space mission power supplies (P15+).
## 1.4 Diversified Asteroid Strategy
| Capture | Type | Year | Provides | Impact |
|---|---|---|---|---|
| 1 | M-type (200 m) | Y75→Y85+ | 36.5 t/yr PGM, Fe-Ni for foundry | 80+ yr campaign; $1.8 B/yr PGM |
| 2 | C-type (~100 m) | Y95→Y105+ | Water, carbon, nitrogen | Circuit Earth frac 10%→3%; propellant independence |
| 3 | S-type (~100 m) | Y115→Y125+ | Silicon, copper | Circuit Earth frac 3%→0.8%; in-situ electronics |

All processing facilities are at SPA (not PKT). One M-type asteroid provides 80+ years of PGM supply — no need for multiple M-type captures. C-type carbon enables S-type silicon refining (carbothermic reduction). Combined M/C/S-type exploitation achieves near-complete Earth independence by ~Y135 (only advanced integrated circuits remain Earth-sourced).
Mining method: Laser Ablation Truss — linear rigid truss with dual laser heads performing surface ablation in spiral pattern (~350 MW, 1,000 t/day). Ejecta captured by electrostatic/magnetic collectors. No mechanical contact with asteroid surface. C-type surfaces covered with reflective MLI blanket to preserve subsurface ice in DRO solar exposure.

# 2. Model Methodology
## 2.1 Infrastructure Derivation (Bottom-Up)
Every infrastructure requirement and Earth cargo figure is derived from the REO production target and unit specifications. No values are hard-coded. The derivation chain is:
1. REO target (exogenous, programme plan) — log-linear ramp from 0.4 t/yr (Y25) to 2,500,000 t/yr (Y180), steady state thereafter.
2. Circuits needed = ceil(REO / 1.2 t/yr per circuit) — optimised continuous-flow design, 28,000 kg, 400 kW.
3. Regolith throughput = REO / 500 ppm (DART-selected PKT site grade; bulk PKT regolith averages 50–200 ppm, physical beneficiation concentrates to 500+ ppm at ~4% mass recovery).
4. Haulers needed = regolith × (1 − Tier 3 fraction) / 1,500 t/yr per hauler.
5. Conveyor km = regolith × Tier 3 fraction / 20,000 t/yr per km.
6. Power = circuits × 400 kW → MSR count = power / 100 MWe per MSR (from P9+).
7. MOLE-I = propellant demand / 5,692 kg/yr per unit — demand-driven by PROBE fleet + crew.
8. Canisters/yr = REO / 3.5 t per canister (from P9+ mass driver era).
## 2.2 Earth Cargo Derivation
For each infrastructure type, cargo is computed as new-build (year-on-year fleet delta × unit mass × Earth fraction) plus maintenance (fleet count × unit mass × maintenance rate × Earth fraction). Earth fractions decline over time as the foundry matures and asteroid resources come online:
| Component | P8 (Y25) | P10+ (Y45) | Post C-type (Y105) | Post S-type (Y125) |
|---|---|---|---|---|
| Processing circuit | 100% | 10% | 3% | 0.8% |
| Hauler | 100% | 43% | 33% (M-type Fe-Ni) | 20% floor |
| MSR vessel | 100% | 100% | 30% (Ni-201) | 30% |
| Conveyor | 5% | 5% | 5% | 5% |

## 2.3 Cost Model
| Category | Basis | Parameters |
|---|---|---|
| Earth launch | Cargo × $/kg × contingency | $6,000 (P0–P7), $4,000 (P8–P9), $2,000 (P10+); contingency 50/35/25% |
| In-situ fabrication | Mass × $100/kg | Midpoint of $50–200 range |
| Mk III PROBEs | LEO launch at $500/kg | Self-transfer to LLO via ion drive |
| Redirect tugs | LEO launch at $500/kg | Self-transfer via SEP |
| Asteroid processing | $500M/yr + $800M/yr | C-type pyrolysis + S-type Si refinery |
| R&D | $500M–$2,000M/yr | Scaling with programme maturity |

## 2.4 Environmental Externalities
1. REO mining displacement: $73,700/t REO displaced. Source: Lee and Wen (2018) EEIO environmental costs ($63,000–83,000/t) plus EPA Social Cost of Carbon at $190/t CO₂ (~$5,700/t for 30 t CO₂-eq/t REO lifecycle).
2. H₂ enabling via iridium: 50% marginal attribution. Ir (15% of PGM) enables PEM electrolysers (1 GW/t Ir, 20-yr stack life) producing green H₂, which avoids CO₂ at 12 t CO₂/t H₂ (energy + green steel DRI + green ammonia). Valued at SCC $190/t CO₂.
3. Geopolitical supply-chain insurance: $15 B/yr at 50%+ supply displacement. Based on China 85–90% REE processing control, 2010–11 14× price spike, EU gas crisis >€1 T from 40% dependency.
4. Rocket emissions (negative): 2,750 t CO₂/launch × tanker ratio (14→8→5) × fossil fraction (100%→5% with DAC methane by Y80). Peak ~3 Mt CO₂/yr at Y45–50; negligible from P11 onward.
## 2.5 Discount Rate
Declining schedule per Arrow, Cropper, Gollier et al. (2014): 3.0% (Y0–30), 2.5% (Y31–75), 2.0% (Y76+). Justified by intergenerational public good character (δ ≈ 0), Ramsey equation, and consistency with UK Green Book and World Bank sovereign investment practice.

# 3. Results: 200-Year Programme
## 3.1 Cost Breakdown
| Category | 200-yr total | % of total |
|---|---|---|
| Earth launch | $14.15 T | 66.4% |
| In-situ fabrication | $6.68 T | 31.3% |
| R&D / programme mgmt | $0.34 T | 1.6% |
| Asteroid processing | $0.11 T | 0.5% |
| DRO operations | $0.02 T | 0.1% |
| Mk III PROBEs (LEO) | $0.01 T | <0.1% |
| Total | $21.31 T | 100% |

Earth launch dominates at 66%. The single largest lever to reduce programme cost is reducing circuit Earth fraction — achieved through foundry maturation and asteroid resource exploitation.
## 3.2 Revenue and Externality Breakdown
| Source | 200-yr total | % of total |
|---|---|---|
| REO sales | $1.21 T | 7.7% |
| PGM sales (all sources) | $0.27 T | 1.7% |
| REO mining externality | $10.38 T | 66.5% |
| H₂ enabling (Ir, 50% attr) | $2.57 T | 16.5% |
| Geopolitical insurance | $1.20 T | 7.7% |
| Rocket emissions | −$0.01 T | −0.1% |
| Total | $15.62 T | 100% |

Direct revenue ($1.48 T) covers only 6.9% of costs. The programme is economically justified only when environmental externalities ($14.14 T) are internalised — requiring sovereign or multilateral funding.
## 3.3 Steady-State Economics (Y180+, 2.5 Mt/yr REO)
| Metric | Annual value |
|---|---|
| Annual cost | $114.7 B |
| REO sales | $12.5 B |
| PGM sales | $2.0 B |
| REO mining externality | $184.3 B |
| H₂ enabling externality | $20.3 B |
| Geopolitical insurance | $15.0 B |
| Rocket emissions | −$0.1 B |
| Total revenue + extern | $236.5 B |
| Net annual surplus | +$121.8 B |
| BCR (annual) | 2.06 |

# 4. BCR and IRR Analysis
## 4.1 Benefit-Cost Ratio
| Scenario | BCR |
|---|---|
| Direct revenue only | 0.055 |
| Direct + REO externality | 0.334 |
| All externalities | 0.502 |
| Annual at steady state (Y180+) | 2.06 |

The 200-year BCR of 0.50 reflects discounting, not fundamental economics. At steady state, the programme generates $2.06 in value per $1 spent — comparable to mature national infrastructure.
## 4.2 Internal Rate of Return
IRR (direct revenue): Undefined — NPV never positive at any discount rate.
IRR (all externalities): −2.54% — requires intergenerational weighting (δ < 0, valuing future generations more than present).
The negative IRR confirms that the programme requires a prescriptive (Stern) rather than descriptive (Nordhaus) discount framework. This is consistent with its character as an intergenerational civilisational investment.

# 5. Sensitivity Analysis
## 5.1 Comprehensive Tornado
| Parameter | Low case | High case | Range |
|---|---|---|---|
| Discount rate (1.4% vs 3.5%) | −$0.92 T | +$0.25 T | $1.17 T |
| Launch cost (±50%) | −$0.34 T | +$0.34 T | $0.67 T |
| Circuit: batch (0.4) vs cont (0.8) | −$0.34 T | −$0.11 T | $0.23 T |
| H₂ attribution (25% vs 100%) | −$0.06 T | +$0.13 T | $0.19 T |
| REO extern ($50k vs $90k/t) | −$0.09 T | +$0.06 T | $0.15 T |
| Geo insurance ($0 vs $25 B/yr) | −$0.04 T | +$0.03 T | $0.06 T |
| Maint rate (0.5% vs 0.25%) | +$0.02 T | +$0.02 T | $0.01 T |

Discount rate is the dominant sensitivity ($1.17 T range), confirming that the programme’s economic case is fundamentally a question of intergenerational ethics, not engineering economics.
PKT resource adequacy. Total KREEP REE in the lunar KREEP layer is ~1–3 billion tonnes (5–9% lunar mass at 300–500 ppm). Accessible PKT resource to 200 m depth: ~220–660 Mt REE (at 100–300 ppm bulk grade). At 2.5 Mt/yr steady-state demand from Y180, this provides ~88–264 years of supply. DART-selected high-grade sites (300+ ppm) place the programme toward the upper end. Resource depletion is not a binding constraint within the 200-year evaluation period: steady state begins at Y180, so only ~20 years of 2.5 Mt/yr production falls within the model horizon. Post-P14 expansion pathways (deeper mining via hauler upgrades, fleet expansion across PKT’s 6.1 million km², or new extraction methods) and projected terrestrial recycling improvements (90%+ REE recovery by the 23rd century) further extend resource life indefinitely.
## 5.2 Target Comparison: 2.5 Mt/yr vs 1.25 Mt/yr
| Metric | 2.5 Mt/yr (committed) | 1.25 Mt/yr (stop-early) |
|---|---|---|
| Steady state reached | Y180 | Y140 |
| 200-yr cost | $21.3 T | $15.4 T |
| SS net surplus/yr | $121.8 B | $76.9 B |
| SS CO₂ avoided/yr | 182 Mt | 145 Mt |
| NPV (200 yr) | −$0.49 T | −$0.44 T |

The 2.5 Mt/yr target has marginally worse NPV (−$0.05 T) but 58% higher steady-state surplus and achieves full replacement of terrestrial REE mining. The strategic goal overrides the marginal NPV difference.

# 6. Environmental Accounting
## 6.1 CO₂ Balance at Steady State (Y200)
| Stream | Mt CO₂/yr | Direction |
|---|---|---|
| REE mining lifecycle avoided | 75.0 | Positive |
| H₂ via Ir (PEM → green steel/ammonia) | 107.1 | Positive |
| Rocket emissions (5% fossil frac) | 0.3 | Negative |
| NET | 181.7 | Strongly positive |

The programme avoids 182 Mt CO₂/yr at steady state — equivalent to eliminating the combined annual emissions of France and the United Kingdom.
## 6.2 Rocket Emissions
Rocket emissions peak at ~3 Mt CO₂/yr during Y45–50 (P9–P10 infrastructure build-out), when cargo volume is highest and fossil propellant fraction remains above 50%. By Y80, DAC methane adoption reduces the fossil fraction to ~5%, and the programme’s P12 cargo ramp coincides with near carbon-neutral propellant production. Lifetime rocket CO₂ across 200 years: 52 Mt — equivalent to approximately six days of current global emissions.
# 7. Programme Cost in Context
| Comparator | Annual cost | Scale |
|---|---|---|
| Selenite Programme | $106 B/yr avg | 4.7% of global military spending |
| Global military spending (SIPRI 2024) | $2,240 B/yr | 21× programme cost |
| Global fossil fuel subsidies (IMF 2023) | $7,000 B/yr | 66× programme cost |
| EU gas crisis cost (2022–23) | >$500 B/yr | 5× programme cost |
| ITER (fusion, 35 nations) | ~$1.5 B/yr | 1.4% of programme cost |

The programme costs less per year than the world spends in a single day on fossil fuel subsidies.
# 8. Beyond P14+: Deep-Space Resource Exploration
The programme’s infrastructure — mass drivers, autonomous robotics, in-situ manufacturing, MSR power, and the propellant advantage of operating from a shallow gravity well — creates capabilities that extend beyond cislunar space.
## 8.1 MOLE-I Plutonium Stockpile
Decommissioned MOLE-I units contain Pu-238 radioisotope thermoelectric generators (RTGs). As the MOLE-I fleet scales down from ~355 (P12) to ~50 (P13+, crew ECLSS only), approximately 305 RTGs are recovered. Pu-238 is stockpiled at SPA for future deep-space mission power supplies. Current global Pu-238 production is ~1.5 kg/yr (Oak Ridge); the Selenite stockpile represents a strategically significant reserve for missions beyond the Earth–Moon system.
## 8.2 Asteroid Belt Prospecting (P15+)
The main asteroid belt between Mars and Jupiter contains millions of bodies, including large M-type asteroids (e.g., 16 Psyche, ~226 km diameter, estimated ~10¹⁹ kg Fe-Ni). Small-scale Mk III–derived prospecting missions using combined chemical/SEP propulsion could reach the belt in 2–4 years. Crater ice on C-type belt asteroids (Ceres confirmed by Dawn mission) provides propellant for return journeys. SPA serves as the launch hub with ISRU propellant depot (revived role from P0–P10 era). Pu-238 RTGs from MOLE-I stockpile power the deep-space avionics.
## 8.3 Kuiper Belt Research (P15+)
Long-range research missions to Kuiper Belt objects (30–50 AU) explore volatile-rich bodies for future capture and processing. These missions operate on decade-scale timescales with Pu-238 RTG power and ion propulsion. The programme does not depend on Kuiper Belt resources within the 200-year economic window, but the infrastructure built through P7–P14 makes such missions technically feasible and scientifically valuable.
## 8.4 REO Surplus, LOX By-Product, and the Interplanetary Fuel Depot
At 2.5 Mt/yr REO, the programme produces far more rare earth material than Earth’s EV and renewable energy sectors can absorb — particularly once terrestrial recycling matures (projected at 90%+ recovery by the 23rd century). The surplus creates the industrial feedstock for space-based manufacturing that could not otherwise exist: neodymium magnets for ion thrusters and reaction wheels, dysprosium for high-temperature motors on interplanetary spacecraft, europium and terbium for display and lighting systems in orbital habitats. Rather than a waste problem, surplus REO becomes the enabling resource for cislunar and interplanetary industry.
Processing 5 billion tonnes of KREEP regolith per year at PKT to extract 2.5 Mt REO also liberates oxygen as a by-product — lunar regolith is approximately 45% oxygen by mass. PKT is fully autonomous with zero crew and no chemical-propulsion vehicles during the P8–P14 REO build-out era, so this oxygen is initially vented or stored. However, at P14+ the programme repurposes PKT’s existing mass driver infrastructure to transform this waste stream into the solar system’s primary propellant source.
LOX constitutes 75–85% of propellant mass in any LOX/LH₂ or LOX/CH₄ system. Launching LOX from Earth currently costs ~$2,000/kg. PKT produces it for free. The architecture is straightforward: liberated oxygen is liquefied using MSR-powered cryocoolers (proven ISRU technology), loaded into Fe-Ni canisters (identical to REO export canisters), and launched via MD-2 to an Earth–Moon L1 orbital fuel depot at ~2,400 m/s — the same mass driver, at the same velocity, using the same canister design already operating for REO exports. Mars-bound or asteroid-belt-bound spacecraft rendezvous at L1, collect LOX, and only require Earth to launch the light fuel component (LH₂ at 15–25% of propellant mass, or CH₄ synthesised from C-type asteroid carbon). This reduces interplanetary mission propellant launch mass from Earth by 75–85%. A Mars transit requiring 500 t of propellant from Earth under current architecture would need only 75–125 t from Earth plus 375–425 t of effectively free lunar LOX. The marginal cost is near zero: the mass driver is already built, the MSR provides power, and the oxygen is a waste product of REO processing.
PKT’s role thereby evolves from KREEP-only processing hub (P8–P14) to dual-purpose REO exporter and interplanetary fuel depot (P14+), without any new mass driver construction. Combined with SPA’s propellant independence (C-type asteroid water, LOX/Al from lunar anorthite, Sabatier methane from C-type carbon), the programme establishes two complementary propellant architectures: SPA for cislunar and deep-space vehicle operations, PKT for bulk interplanetary LOX supply. The investment costs for the L1 depot and LOX liquefaction plant are not modelled in the current 200-year evaluation but represent a natural P14+ decision gate (DG-14.4) leveraging infrastructure that already exists for REO production.
Both asteroid belt and Kuiper Belt research represent the programme’s long-term evolution from “betterment of Earth” to “self-sustaining civilisation” — designed to be maintained and grown for millions of years.

# 9. Conclusions
1. The programme is economically justified on externalities. The 200-year BCR of 0.50 reflects discounting limitations, not poor economics. At steady state, every $1 spent generates $2.06 in benefits.
2. Direct revenue alone cannot fund the programme. $1.48 T revenue versus $21.3 T cost over 200 years. Government-consortium funding with internalised externalities is essential — consistent with Arrow et al. (2014) and the programme’s character as an intergenerational public good.
3. Circuit throughput is the highest-value R&D investment. Optimised continuous-flow circuits (1.2 t/yr) reduce total cost by $22 T compared to batch processing. Further throughput improvements would proportionally reduce costs.
4. The programme is strongly net carbon-positive from P9 onward. 182 Mt CO₂/yr avoided at steady state versus 0.3 Mt/yr rocket emissions. DAC methane production reaches ~95% of launch propellant by Y80.
5. Diversified asteroid exploitation (M/C/S-type) achieves near-complete Earth independence by Y135. Circuit Earth fraction drops from 10% to 0.8%, reducing the dominant cost category by an order of magnitude.
6. 2.5 Mt/yr is the committed target — full replacement of terrestrial REE mining. 1.25 Mt/yr leaves half the environmental damage unresolved.
7. The programme’s cost ($106 B/yr) represents 4.7% of global military spending. If the geopolitical cooperation it necessitates reduces military expenditure by just 5%, the savings exceed the programme cost.
8. Decommissioned MOLE-I Pu-238 RTGs provide power for deep-space missions to the asteroid belt and Kuiper Belt (P15+), extending the programme’s reach beyond the cislunar environment.
9. PKT’s oxygen waste stream becomes the solar system’s fuel supply. At P14+, the existing mass driver launches LOX canisters to an Earth–Moon L1 fuel depot, reducing interplanetary mission propellant launch mass from Earth by 75–85% at near-zero marginal cost.
# References
Arrow, K.J., Cropper, M.L., Gollier, C. et al. (2014) ‘Should governments use a declining discount rate in project analysis?’, Review of Environmental Economics and Policy, 8(2), pp. 145–163.
Lee, J. and Wen, Z. (2018) ‘Rare earths from mines to metals: comparing environmental impacts from China’s main production pathways’, Journal of Industrial Ecology, 22(4), pp. 811–822.
EPA (2023) Report on the Social Cost of Greenhouse Gases, November 2023. Social cost of carbon: $190/t CO₂ at 2% discount rate.
Handmer, C. (2021) Starship is still not understood, caseyhandmer.wordpress.com.
USGS (2025) Mineral Commodity Summaries: Rare Earths, January 2025.
Adamas Intelligence (2025) Rare Earth Magnet Market Outlook to 2040, Q4 2025.
SIPRI (2024) SIPRI Yearbook 2024: Armaments, Disarmament and International Security.
IMF (2023) Fossil Fuel Subsidies Data: 2023 Update.

This report was generated from SELENITE_ECON v1.3 (200-year bottom-up model) and v1.4 (BCR/IRR/sensitivity analysis layer). All figures derived from unit specifications and programme architecture — no hard-coded cargo values. Australian spelling. Harvard referencing.