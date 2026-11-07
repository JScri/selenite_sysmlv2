# SELENITE PROGRAMME

## ECN-019: Programme-Wide Design Revision — Manufacturing, Power, Chemistry, Materials & Economic Architecture

**Reference:** ECN-018 (superseded in part), SEL-PROC-001 Rev A, SEL-PROC-PKT-001 Rev A, SEL-ISRU-001 Rev D, SEL-HAULER-001 Rev A, SEL-CATAPULT-001 Rev A, SEL-POWER-001 Rev A, SEL-T1_1-STRATEGY v2.6, SEL_ROBOT_FLEET ECN-016, SELENITE_SCALE v1.3, SEL-DECISION-001 Rev B, SEL-ECON-001 Rev A, all robot design specs (Rev A), all updated_ docs with ECN-012 through ECN-017.

**Date:** April 2026

**Revision:** C (Rev A: initial. Rev B: hauler mining capability, no-MOLE-S-at-PKT, PKT construction manifest. Rev C: 2.5 Mt/yr target, optimised circuits, PROBE Mk III, base specialisation, diversified asteroids, laser ablation truss, economic evaluation integration.)

**Status:** PROPOSED

**Scope:** This ECN consolidates findings from seven research areas completed in the current evaluation cycle, plus programme rescoping from the economic evaluation (SELENITE_ECON v1.3/v1.4). It supersedes ECN-018 §1–§3 and extends to cover: D2EHPA elimination, thorium MSR, in-situ manufacturing, PROBE Mk III SEP architecture, base specialisation (SPA=asteroid hub, PKT=KREEP only), diversified asteroid captures (M/C/S-type), laser ablation truss mining, 2.5 Mt/yr committed REO target, optimised continuous-flow processing circuits, and P14+ Earth independence strategy.

---

## 1. D2EHPA Elimination — Split Value Chain Replaces All Organic Solvent Extraction

### 1.1 Problem Statement

D2EHPA (di(2-ethylhexyl)phosphoric acid, C₁₆H₃₅O₄P) is the standard solvent extraction agent for individual REE separation. At P12 scale (2.5M circuits × 1 t/yr makeup), the programme would require 2.5 Mt/yr of D2EHPA from Earth — approximately 25,000 Starship flights/yr for a single chemical. D2EHPA contains 596 g carbon per kilogram; lunar carbon availability (Sabatier CH₄ at 313 kg/yr + ~100 ppm solar wind implanted) cannot support synthesis at any meaningful fraction of demand. No organophosphorus extractant can be manufactured from lunar resources — the minimum-viable molecule (tributyl phosphate) requires butanol from petroleum chemistry.

### 1.2 Resolution: Eliminate D2EHPA Entirely

The programme does NOT need to separate individual REEs on the Moon. The magnet industry — representing ~80% of REE value — accepts didymium (mixed NdPr at 75:25 ratio) as standard commercial feedstock at $65–112/kg. Shipping group-separated concentrate to Earth for final SX captures >90% of economic value at <5% of the chemical complexity.

**Revised lunar processing flowsheet (zero ongoing carbon consumption):**

**Step 1 — Acid bake (H₂SO₄ only, in-situ produced):** KREEP regolith + concentrated H₂SO₄ at 300°C. This locks ~90–95% of thorium into insoluble ThP₂O₇ (pyrophosphate) — an automatic first-pass Th/REE separation using only H₂SO₄ and heat. Water leach dissolves REE sulfates while Th remains in the residue.

**Step 2 — Staged Ca(OH)₂ precipitation (in-situ produced):** Add Ca(OH)₂ (from anorthite calcination) to pH 3.8. This precipitates >95% of remaining Th and >99% of Fe/Al impurities, with <5% REE co-precipitation loss. REE remains in solution.

**Step 3 — Uranium separation:** Oxidise U to UO₂²⁺ using H₂O₂ (from ISRU water electrolysis) or O₂ bubbling. Raise pH to 6.5 with Ca(OH)₂ — uranium precipitates as uranyl hydroxide. REE stays in solution. Alternatively, Na₂CO₃ leach of the Th/U co-precipitate selectively dissolves U as soluble uranyl carbonate, leaving Th behind.

**Step 4 — Cerium oxidation (zero reagent consumption):** Electrochemical oxidation of Ce³⁺ → Ce⁴⁺ at a platinum or DSA anode, or roast mixed hydroxide at 650°C in O₂. CeO₂ is insoluble in dilute H₂SO₄ (Ksp ~10⁻⁴⁸). Achieves >97% CeO₂ purity in a single step. Removes ~35% of total REE mass — the lowest-value component (~$1/kg).

**Step 5 — Europium reduction (zero carbon, Fe metal as reductant):** Electrochemical reduction of Eu³⁺ → Eu²⁺ (E° ≈ −0.35 V), or use metallic Fe from MRE/asteroid returns as reductant (E° Fe²⁺/Fe = −0.44 V, thermodynamically sufficient). EuSO₄ precipitates selectively (isomorphous with BaSO₄, Ksp ~10⁻⁵). Recovery >95% at ~92% Eu₂O₃ purity, improving to 96.5% with one reprecipitation. All reagents lunar-available.

**Step 6 — LREE/HREE group split (double sulfate precipitation):** Add Na₂SO₄ at 50–60°C. NaLREE(SO₄)₂·H₂O (La, Pr, Nd, Sm) precipitates at >95% recovery. HREE (Gd through Lu) + Y remain in solution. Na from plagioclase processing. Zero carbon.

**Step 7 — Concentrate preparation and shipping:** LREE double sulfate dissolved in hot water, converted to mixed (NdPr + La + Sm) hydroxide or oxide. HREE solution precipitated as phosphate using lunar H₃PO₄ (from KREEP apatite + H₂SO₄). Both concentrates calcined, packaged in mass driver canisters, shipped to Earth.

**Step 8 — Earth-side final SX:** Existing terrestrial SX plants (massive overcapacity) produce individual NdPr didymium ($65–112/kg), Dy₂O₃ ($220–800/kg), Tb₄O₇ ($730–3,625/kg). Processing cost ~$10–60/kg REO — trivial vs product value.

**Optional Step 7a — On-Moon polishing (if local magnet manufacturing is required):** LAD chromatography (Purdue/Medallion) with recycled EDTA inventory (~200–500 kg imported from Earth, one-time). Achieves >99% purity and >99% yield for Nd, Pr, Dy at >100 kg REE per m³ of sorbent per day. EDTA is fully recycled — the carbon investment is a permanent column inventory, not a consumable stream. TRL 5.

### 1.3 Economic Impact

- **D2EHPA eliminated:** 2.5 Mt/yr Earth supply → 0. Saves ~25,000 Starship flights/yr at P12.
- **NaOH eliminated:** Replaced by Ca(OH)₂ from anorthite calcination (100% in-situ).
- **Oxalic acid eliminated:** REE precipitation via hydroxide/phosphate routes instead.
- **Remaining Earth reagent at P12:** EDTA replenishment (~200 kg/yr) + V₂O₅ catalyst (~5,000 t/yr) + specialty items. Total: <6,000 t/yr = ~60 Starship flights/yr.
- **Value chain split:** Moon performs group separation (zero to minimal carbon); Earth performs individual element SX using existing infrastructure.

### 1.4 KREEP REE Distribution Favours This Approach

Lunar KREEP contains ~24% combined NdPr (comparable to terrestrial bastnasite at ~23%) and ~7% Dy (far exceeding bastnasite's ~0.03%). The pronounced negative Eu anomaly (Eu depleted ~4× relative to neighbours) is actually beneficial — less low-value Eu dilutes the concentrate. KREEP-derived concentrate is inherently more valuable per kilogram than the dominant terrestrial ore because of elevated heavy REE content.

---

## 2. Thorium Recovery & MSR Power Strategy

### 2.1 Thorium Recovery from Processing Waste

The 300°C acid bake in Step 1 above automatically separates thorium as a byproduct. ThP₂O₇ is collected from the leach residue, washed, and stored as Th(OH)₄ after alkaline treatment. This is the MSR fuel feedstock.

Uranium is separated in Step 3 and stored as uranyl hydroxide cake — strategic reserve for HALEU startup charges or trade.

Neither Th nor U recovery requires any reagent not already in the processing flowsheet. The Th/U separation is a free byproduct of REE processing.

### 2.2 Thorium MSR Integration Timeline

| Phase | PKT Power | Power Source | Th Fuel Status | Key Milestone |
|-------|-----------|-------------|----------------|---------------|
| P3–P7 | 0.1–2.1 MW (SPA only) | Solar + 4–11 FSP (uranium, Earth) | Stockpiling begins P7 | — |
| P8 | ~55 MW PKT | 1,386 FSP (Earth) | ~40 t Th(OH)₄ stockpiled | First MSR prototype if DG-7.5 met |
| P9 | ~100 MW PKT | FSP + first MSR(s) | ~150 t stockpiled | DG-9.3: confirm breeding ratio >1.0 |
| P10 | 7.4 GW | MSR fleet (~74 × 100 MWe) + FSP backup | Consuming ~54 t/yr; producing 387–773 t/yr | MSR expansion, U-233 bootstrapping |
| P11 | 67.9 GW | MSR fleet (~679 × 100 MWe) | ~551 t/yr consumed; surplus growing | Fleet scaling |
| P12 | 688.7 GW | MSR fleet (~6,890 × 100 MWe) | ~551 t/yr consumed vs 387–773 t/yr produced | Self-sustaining fuel cycle (marginal at low estimate) |

### 2.3 MSR Vessel Material

Hastelloy-N (Ni-16Mo-7Cr-5Fe) is the standard MSR containment alloy. Molybdenum (~16 wt%) is essentially absent on the Moon (~1 ppm in basalt, absent from iron meteorites). Hastelloy-N vessels must be imported from Earth.

**In-situ alternative: Ni-201** (commercially pure nickel, >99% Ni). Refined electrochemically from asteroid Fe-Ni returns. ORNL testing shows acceptable FLiBe corrosion resistance (Cr depletion depth ~2 μm after 1,000 hr at 700°C). Trade-off: lower high-temperature creep strength limits operating temperature to ~600–650°C vs Hastelloy-N's 704°C design limit. This reduces Brayton cycle thermal efficiency by ~5–8% but is manageable.

**Recommendation:** Import Hastelloy-N vessels from Earth for initial MSR fleet (P8–P10). Transition to in-situ Ni-201 vessels for fleet expansion at P11+ once performance is validated. Hastelloy-N remains the highest-leverage specialty material import — at ~8,000 t/yr for P12 replacement vessels (20-year service life × 6,890 units), this is ~80 Starship flights/yr.

### 2.4 Chloride Salt MSR Configuration (Preferred for Lunar Deployment)

- Carrier salt: NaCl-KCl-MgCl₂ — all constituent elements at percent-level abundance in lunar minerals
- Fast neutron spectrum — no graphite moderator needed (carbon scarce)
- ThCl₄ fuel from carbothermic chlorination of Th(OH)₄ stockpile
- Breeding ratio 1.01–1.08 (sufficient for gradual U-233 buildup)
- Process heat at 200–300°C available as waste heat — dual-purpose industrial powerplant for acid baking
- China TMSR-LF1 achieved first criticality Oct 2023; Pa-233 detected Oct 2024 — first thorium breeding signal in a reactor since Shippingport (1977–82)

### 2.5 Nuclear Reactor Construction — Crew Safety

MSR construction at PKT follows a strict radioactive/non-radioactive separation:

1. **Temporary crew (3–4 specialists, 6–12 months) builds the cold structure:** Ni-201 or Hastelloy-N vessel, heat exchangers, turbomachinery, piping, radiator panels, regolith shielding fill (1–2 m thick, in-situ). None of this material is radioactive. Standard industrial construction.

2. **Crew departs PKT** (returns to SPA or shielded PKT habitat).

3. **Fuel loading is autonomous/telerobotic:** ThCl₄ salt arrives from SPA (mass-driven in shielded container) or is prepared at PKT from Th(OH)₄ stockpile via carbothermic chlorination (autonomous). Salt pumped into vessel by remote systems. HALEU startup charge (for first criticality before breeding equilibrium) arrives from Earth in sealed shielded cask, loaded via same remote system.

4. **First criticality and power-up controlled from SPA Ops Hub** at 0.5s latency — well within nuclear reactor control requirements (terrestrial reactors operate with multi-second control rod response times).

Crew never handles nuclear fuel. Radiation hazard begins only at step 3, after crew departure. Shielding already in place from step 1.

---

## 3. In-Situ Manufacturing Design Changes

### 3.1 Three Mandatory Design Revisions

Based on lunar materials assessment (MRE at TRL 4–5, demonstrated 25 kg simulant processing; Blue Origin Blue Alchemist targeting TRL 6 in 2026), three vehicle/infrastructure subsystems must be redesigned:

**A. Batteries: Li-ion → Sodium-Sulfur (Na-S)**

Li-ion batteries cannot be manufactured in-situ. Lithium is ~10 ppm in regolith (1 million tonnes processing per 10 kg Li). Carbon for graphite anodes is ~100 ppm. Polymer separators and organic electrolyte solvents require petroleum-derived chemistry.

Na-S batteries use only lunar-available materials: sodium from plagioclase (Na₂O 0.3–0.6 wt%), sulfur from troilite (FeS), and beta-alumina solid electrolyte (Na₂O·11Al₂O₃) from sodium + aluminium. NASA tested Na-S cells achieving >1,000 LEO cycles (Eagle-Picher/USAF, STS-87 flight 1997). Performance: ~150–200 Wh/kg at 300–350°C operating temperature.

**Hauler battery revision:** 50 kWh Li-ion (200 kg) → 50 kWh Na-S (~300 kg). Mass penalty: +100 kg. **Mining capability addition:** front bucket/blade mechanism + electric linear actuators (~150 kg). Hauler dry mass: 1,200 → ~1,450 kg. Thermal management: Na-S operates at 300–350°C — battery itself serves as a heat source, reducing or eliminating the need for separate heaters during lunar night. Self-heating on discharge.

In-situ Na-S fraction: ~60% of cell mass (Na, S, Al₂O₃ electrolyte). Remaining 40% (current collectors, seals, insulation, BMS electronics) from Earth.

**B. Motors: SmCo BLDC → Switched Reluctance Motors (SRM)**

SmCo magnets require samarium (~25–45 ppm in KREEP, yielding ~1 kg per 33 tonnes processed) and cobalt (~190 kg/yr from asteroid Fe-Ni returns). This supports ~300–600 small motors annually — orders of magnitude below the 1.49M hauler fleet. NdFeB magnets need boron (absent).

SRMs use only silicon-steel laminations (Fe + Si from MRE, both abundant) and aluminium windings (from regolith Al₂O₃ reduction, substituting for copper). No permanent magnets. TRL 8–9 on Earth. McGill University thesis specifically designed SRMs for lunar rovers.

Performance penalty: ~10–20% lower power density than BLDC. ~5–10% lower efficiency. For the hauler application (1.5 kW per motor, low-speed high-torque), SRMs are well-suited and the efficiency penalty is modest.

**Hauler motor revision:** 4× SmCo BLDC hub motors → 4× SRM hub motors with Fe-Si laminations and Al windings. Mass approximately equivalent (~200 kg for 4 motors). In-situ fraction: ~70% (laminations, windings, housings). Earth-supplied: power electronics, position sensors, bearings (~30%).

**Note:** This change applies to haulers (PKT only). SPA robots (MOLE-I, MOLE-S, ARM, SINTER) retain SmCo BLDC motors — they are Earth-manufactured and the fleet count is small enough (hundreds, not millions) to justify permanent magnet motors. SmCo magnets for SPA robots can theoretically be manufactured from KREEP samarium + asteroid cobalt at the modest quantities required.

**C. Ore catapults: REPLACED by steel conveyor network (immediate baseline change)**

YBCO (YBa₂Cu₃O₇) requires copper at 286 g per kg. Lunar basalt contains ~15 ppm Cu; iron meteorites ~100–300 ppm. The programme extracts ~6 kg Cu/yr from asteroid returns. No alternative high-temperature superconductor avoids the copper problem. The 9,084 ore catapult hubs specified in SEL-CATAPULT-001 would require ~209,000 tonnes of YBCO — an ongoing import of ~6,000 t/yr (~$12B/yr).

**Resolution: Replace all 9,084 ore catapult hubs with a steel apron conveyor network.** Steel apron conveyors (interlocking Fe-Ni steel pans on roller chains) use zero YBCO, zero copper, zero carbon. They are ~95% in-situ manufactured from asteroid Fe-Ni + MRE iron/silicon/aluminium.

Comparison (P12 Tier 3 ore transport, 1.71 Bt/yr over 50–150 km):

| Parameter | EM Catapult (superseded) | Steel Conveyor (baseline) |
|-----------|------------------------|--------------------------|
| Total infrastructure | ~1.82 Mt | ~7–9 Mt |
| Earth import | ~215,000 t (35 yr) | ~10,000–15,000 t (35 yr) |
| Annual Earth import | ~6,140 t/yr (~61 flights) | ~300–430 t/yr (~3–4 flights) |
| Annual cost | ~$12.3B/yr | ~$0.6–0.9B/yr |
| YBCO required | ~209,000 t | 0 |
| Continuous power | ~13.6 GW | ~0.44 GW |
| In-situ fraction | ~0% of critical components | ~95–97% |
| Throughput per route | 720 t/day (batch) | 48,000 t/day (continuous) |

Network topology: dendritic (trunk + branch), ~87,500 km total at P12. ~500 trunk lines averaging 75 km + ~5,000 branches averaging 10 km. Runs alongside existing sintered road network. Drive stations (SRM, Fe-Si + Al, in-situ) every 1–2 km. MoS₂ lubricated rollers.

**SEL-CATAPULT-001 Rev A is superseded for ore transport.** Retained for mass driver heritage only.

**EM mass drivers retained (3 baseline + 1 conditional, ~175–300 t YBCO lifetime total):**

| # | Route | Velocity | YBCO | Purpose |
|---|-------|----------|------|---------|
| 1 | SPA→PKT | ~1,800 m/s | ~30–60 t | P8–P9: propellant. P10+: Fe-Ni foundry feedstock from PROBE asteroid returns + ThCl₄ + spares |
| 2 | PKT→Earth | ~2,400 m/s | ~60–100 t | REO canisters, 783/day at P12 |
| 3 | PKT→SPA | ~1,800 m/s | ~30–60 t | ThCl₄ fuel for SPA MSR + spares |
| 4 | SPA→Earth | ~2,400 m/s | ~30–60 t | PGM concentrate — conditional on DG-11.6 (when export >100 t/yr, driven by iridium demand for H₂ economy PEM electrolysers) |

Plus one catapult demonstrator hub at P10 (~23 t YBCO) to validate coilgun physics at 500 m/s before committing to escape-velocity mass drivers.

**PROBE fleet basing rationale:** PROBEs remain at SPA permanently. SPA produces all ISRU propellant; PKT has no water ice and no propellant production. Rebasing to PKT would require mass-driving cryogenic propellant to PKT + duplicating the entire IZ infrastructure (collars, ARM-D, cryo farm). Instead, PROBE returns to SPA → ore processed at SPA beneficiation → PGM separated for Earth return → **Fe-Ni bulk mass-driven SPA→PKT as foundry feedstock**. At P12: 286 PROBEs × 1,500 kg = ~429 t/yr Fe-Ni through SPA→PKT driver. SPA IZ scales linearly: collar + ARM-D count maintains 1:1 ratio, gantry rail extendable by design.

**New document required: SEL-CONVEYOR-001 Rev A** — steel apron conveyor specification for PKT Tier 3 transport.

### 3.2 Revised Hauler In-Situ Fraction

| Component | Mass (kg) | In-situ % | In-situ source | Earth-supplied |
|-----------|-----------|-----------|----------------|----------------|
| Al frame | 400 | 85% | MRE Al-Si alloy, WAAM/casting | Fasteners, precision interfaces |
| Bucket/blade mechanism | 150 | 75% | Fe-Si casting + Al actuator housing | Linear actuator electronics, pivot bearings |
| SRM hub motors (×4) | 200 | 40% | Fe-Si laminations, Al windings, housings | Power electronics, sensors, bearings |
| Fe-Si hopper | 250 | 65% | MRE Fe-Si alloy, WAAM fabrication | Wear liners, dust seals |
| Na-S battery (50 kWh) | 300 | 60% | Na, S, Al₂O₃ electrolyte | Current collectors, BMS, insulation |
| Avionics/nav | 100 | 0% | — | All Earth: processors, LiDAR, cameras |
| Thermal | 50 | 50% | Al radiator panels | MLI, heaters, thermal straps |
| **TOTAL** | **~1,450** | **~57%** | **~830 kg** | **~620 kg** |

This is a significant reduction from the 92% previously specified but is grounded in demonstrated extraction technologies and realistic materials assessment. The 55–60% fraction is defensible; 92% required breakthroughs in semiconductor fabrication and carbon-free battery chemistry not on any current roadmap.

### 3.3 Mass Driver Return Canister Manufacturing

At P12: 783 canisters/day, each ~1,500 kg Fe-Ni shell + ~200 kg ceramic TPS = ~1,332 t/day throughput.

A single WAAM/casting line at ~10 kg/hr produces ~240 kg/day. Required: **~5,500 parallel production lines** for shells. This is not a single foundry — it is a distributed manufacturing network along the PKT spine, with cluster foundries at each catapult hub producing 1–5 canisters/day for local mass driver operations.

Canister in-situ fraction: ~85% (Fe-Ni shell from asteroid returns, Al₂O₃/SiO₂ ablative TPS from regolith sintering). Earth-supplied ~15%: parachute fabric (Nomex/Kevlar), pyrotechnics, tracking beacon, telemetry electronics.

### 3.4 Minimum Viable Foundry

Three independent assessments converge: Guerrero-Gonzalez & Zabel (Acta Astronautica, 2023) specified a complete MRE plant at ~6,776 kg producing 25 t/yr. CisLunar Industries (DARPA LunA-10) targets ~5,000 kg at 10–100 kW for 20–500 t/yr. MIT thesis modelled 1,593 kg / 56.5 kW for 10,000 kg O₂/yr with proportional metal co-production.

**Programme foundry scaling:**

| Scale | Equipment mass | Power | Phase |
|-------|---------------|-------|-------|
| 25 t/yr (pilot) | ~5–7 tonnes | 25–60 kW | P9 |
| 1,000 t/yr | ~70–100 tonnes | 0.5–1 MW | P10 early |
| 10,000 t/yr | ~500–700 tonnes | 5–15 MW | P10 late |
| 100,000 t/yr | ~5,000–7,000 tonnes | 50–250 MW | P11–P12 |

At P12 power budget of 689 GW, even the most power-intensive foundry estimates consume <0.04% of available generation. Power is not the bottleneck.

### 3.5 Vacuum Manufacturing Advantages

Several manufacturing processes are superior on the lunar surface:

- **Electron beam welding:** Unlimited vacuum work volume (no pump-down). Penetration to 300 mm in steel. First autonomous in-space EB weld demonstrated by ThinkOrbital (2024).
- **Titanium machining:** Leibniz University SFB 1368 showed extreme vacuum suppresses tribo-oxidation, extending tool life 170% and reducing cutting forces 16–50%.
- **PVD coatings:** Moon provides 10⁻¹² Torr vacuum for free (vs 10⁻²–10⁻⁶ Torr chambers on Earth). TiN, TiAlN tool coatings from lunar Ti and Al.
- **Electron beam melting:** Already operates in vacuum at >99.5% density. Native to lunar surface.

### 3.6 PKT Construction: Temporary Commissioning Crew

The programme specifies PKT as fully autonomous from construction. Evidence from Tesla's "production hell" (full automation attempt → 2,000 vs 5,000 cars/week target, $100M/week losses), industrial robot reliability data (real-world MTBF ~87 minutes due to peripheral equipment failures), and foundry commissioning practice (every terrestrial foundry requires weeks of iterative human troubleshooting for first heats) all indicate that **initial foundry commissioning should include a temporary crew presence.**

**Recommendation:** 3–4 specialists for 6–12 months at PKT during foundry and MSR commissioning. Tasks: first MRE heats with actual regolith (tuning parameters for real composition), troubleshooting thermal/material behaviours, commissioning manufacturing lines, installing and testing MSR cold structure. After commissioning, facility transitions to teleoperation from SPA at 0.5s latency for routine production.

The 0.5s round-trip teleoperation latency from SPA is adequate for routine production oversight (medical teleoperation research shows no significant performance degradation below 400 ms). Shared autonomy techniques — operators send high-level commands, robots execute sub-tasks — overcome remaining latency effects.

**Crew accommodation at PKT:** Temporary pressurised habitat (Starship-class lander or inflatable module), independent life support for 6–12 months, crew return vehicle on standby. Habitat is not permanent infrastructure — it is decommissioned or repurposed after the commissioning period. Crew safety during MSR construction: see §2.5 above (crew builds cold structure only; fuel loading is autonomous after crew departure).

---

## 4. Reagent ISRU — Revised Schedule (Supersedes ECN-018 §1)

### 4.1 Phased Introduction (Updated)

**P5 (Y9–12): Troilite H₂SO₄ pilot at SPA.** 5,000 kg equipment, 50 kW, 1–5 t/yr H₂SO₄ from beneficiation gangue. Milestone M5.5 (~M115).

**P6 (Y12–15): Ca(OH)₂ pilot at SPA.** 2,500 kg equipment, 30 kW, 5–10 t/yr Ca(OH)₂ replacing NaOH.

**P7 (Y15–25): Progressive substitution at SPA processing facility.** 10% → 50%+ in-situ H₂SO₄. Ca(OH)₂ replaces NaOH in all circuits.

**P8 (Y25–35): PKT reagent plant from day one.** 80,000 kg, 500 kW, 85% self-sufficiency across 308 circuits. Troilite roasting + Ca(OH)₂ production. Earth supply: ~2,207 t/yr (vs 14,711 t/yr without in-situ).

**P9 (Y35–45): 90% in-situ.** Oxalic acid pilot from CO₂ electroreduction. Earth: ~11,750 t/yr.

**P10+ (Y45+): 95–98% in-situ.** H₂SO₄ 98%, Ca(OH)₂ 100%, oxalic acid 80%. D2EHPA eliminated (see §1). Earth residual: EDTA (~200 kg/yr), V₂O₅ catalyst replacement, specialty items.

### 4.2 Revised Earth Reagent Demand (with D2EHPA elimination)

| Phase | Circuits | Old demand (t/yr) | New demand (t/yr) | Reduction | Flights saved/yr |
|-------|----------|-------------------|-------------------|-----------|-----------------|
| P7 | 5 | 235 | 60 | 74% | ~2 |
| P8 | 313 | 14,711 | 1,100 | 92% | ~136 |
| P9 | 2,500 | 117,500 | 5,500 | 95% | ~1,120 |
| P10 | 25,000 | 1,175,000 | 12,500 | 99% | ~11,625 |
| P11 | 250,000 | 11,750,000 | 50,000 | 99.6% | ~117,000 |
| P12 | 2,500,000 | 117,500,000 | 6,000 | >99.99% | ~1,174,940 |

The D2EHPA elimination (§1) combined with in-situ H₂SO₄ and Ca(OH)₂ production reduces P12 Earth reagent demand from 117.5 Mt/yr to ~6,000 t/yr — a factor of ~19,600× improvement.

---

## 5. PGM Dual-Track Strategy

### 5.1 Asteroid PGMs (Primary, Immediate)

M-type asteroids carry 20–40 ppm median PGM — 6–100× richer than any lunar source. PROBE fleet targets M-type NEAs exclusively. Iridium ($154,000–161,000/kg) is the highest-value target, with global production of only 7.5–9 t/yr against potentially hundreds of tonnes demand by 2050 for PEM electrolysers.

### 5.2 Lunar PGMs (Prospecting Only Until P8 Decision Gate)

Srivastava et al. (2026, Communications Earth & Environment) modelled sulfide-silicate segregation in basin-scale impact melts producing 1–5 g/t PGE — comparable to Bushveld Complex economic grades. Chennamangalam et al. (2025) identified ~6,500 craters ≥1 km with potential PGM content, ~38 craters >19 km with well-defined central peaks as priority targets. Total aggregate value estimated >$1 trillion. However, this is modelled, not measured — no one has sampled the interior of a lunar impact melt sheet.

**Action: Task DART and SURVEY to collect PGM data during existing missions (zero additional cost).**

- SURVEY: Add XRF scan for siderophile elements over SPA Basin impact melt sheets during existing orbital passes.
- DART: Collect and analyse XRF samples at impact melt exposures near PKT sites during surface operations.

**Decision gate: P8 (Y25).** If lunar grades confirmed >10 g/t at accessible locations → commission third-base feasibility study (likely Orientale Basin, best-preserved large melt sheet). If <5 g/t → asteroid PROBE remains sole PGM pathway. Economic model base case assumes asteroid PGMs only; lunar PGMs as upside sensitivity.

---

## 6. In-Situ Solar Cell Assessment

Blue Origin's Blue Alchemist demonstrated solar cells manufactured entirely from MRE-processed regolith simulant (CDR 2025, TRL 6 target 2026). Amorphous Si from lunar SiO₂ achieves ~10–15% efficiency vs GaAs 29%.

**PKT solar vs thorium MSR comparison:**

| Parameter | In-situ a-Si Solar | Thorium MSR (100 MWe) |
|-----------|-------------------|----------------------|
| Efficiency | 10–15% | ~30–35% (Brayton) |
| PKT avg output | ~68 W/m² (50% illumination at 14°N) | 100 MW continuous |
| Mass per kW | ~44–74 kg/kW (panels + frames) | ~0.5 kg/kW (excl. regolith shielding) |
| Lunar night | Zero output for 14.7 days | Continuous |
| Night storage for 689 GW | ~243 TWh = ~40% of current global battery capacity | Not required |
| In-situ fraction | ~80% (Si cells + Al frames) | ~60–80% (Ni-201 vessel + regolith shielding) |

**Conclusion:** Thorium MSR is superior on every metric except in-situ fraction. Solar is a viable supplement for daytime peak loads and for applications where reactor deployment is impractical (remote catapult hubs, outlying hauler charging stations). Solar array frames (Al from regolith) are in-situ manufactured; only the GaAs cells (if used instead of a-Si) come from Earth.

---

## 7. Document Impact Matrix

| Document | Change | Priority |
|----------|--------|----------|
| **SEL-PROC-001 Rev A** | MAJOR: Replace entire reagent section. Remove D2EHPA. Add 300°C acid bake ThP₂O₇ mechanism. Add Ca(OH)₂ substitution for NaOH. Add Th/U recovery steps. Reference split value chain. | HIGH |
| **SEL-PROC-PKT-001 Rev A** | MAJOR: (a) §3 Ore Input: Remove "P8–P9: Chemical SKIPs" — NO SKIPs at PKT ever. No MOLE-S at PKT. Replace with "P8+: Mining-capable haulers (front bucket/blade) self-load 5 t KREEP, transport to spine, grade terrain, supply SINTER — one vehicle class handles all PKT surface operations." (b) §4 Product Output: Remove "propellant from SPA via tanker". Replace with "P8: REO via Starship return. P9+: mass driver." (c) Replace §2 Reagent Supply with in-situ production plant. Remove D2EHPA. Update Earth demand table per §4.2. (d) Add PKT construction manifest (4 waves, ~30,000 t over P8). | HIGH |
| **SEL-HAULER-001 Rev A** | MAJOR: (a) Introduction brought forward from P10 to P8. (b) Add mining capability: front bucket/blade mechanism (~150 kg), self-loads 5 t in ~25 min, grade mode, trench mode. Replaces MOLE-S at PKT entirely. (c) Dry mass 1,200 → ~1,450 kg (bucket + Na-S battery mass). (d) Replace Li-ion with Na-S battery (50 kWh, ~300 kg, 300–350°C). (e) Replace SmCo BLDC with SRM (Fe-Si laminations, Al windings). (f) Update in-situ fraction to 55–60%. (g) Remove "SPA uses SKIP hoppers (P7–P9 only)" — and note MOLE-S is SPA-only. (h) Addendum canister return: catapult reference superseded by conveyor. | HIGH |
| **SEL-CATAPULT-001 Rev A** | SUPERSEDED for ore transport. Retained for mass driver heritage only. 9,084 ore catapult hubs replaced by steel conveyor network. Ore catapult count in SCALE v1.3 replaced by conveyor km. | HIGH |
| **NEW: SEL-CONVEYOR-001 Rev A** | Steel apron conveyor network for PKT Tier 3 ore transport. Fe-Ni chain/pans, SRM drive stations, dendritic topology (~87,500 km at P12), 95% in-situ manufactured. Replaces SEL-CATAPULT-001 ore catapult function. | HIGH |
| **SEL-POWER-001 Rev A** | MAJOR: Add thorium MSR section. Phase out FSP for PKT bulk power. Add Ni-201 vessel alternative to Hastelloy-N. Add MSR construction sequence (cold build → autonomous fuel loading). Chloride salt MSR configuration. | HIGH |
| **SEL-ISRU-001 Rev D** | Add: Sulfur Extraction Module (troilite roasting, 1,100°C, contact process). Ca(OH)₂ from anorthite calcination. +50 kW at P5, +30 kW at P6. H₃PO₄ from apatite + H₂SO₄ for REE precipitation. | HIGH |
| **SEL-IZ-001 Rev A** | Update: §11 reagent table — remove D2EHPA, NaOH, oxalic acid from Earth supply list. Add in-situ reagent pilot equipment to IZ infrastructure. | MEDIUM |
| **SEL-T1_1-STRATEGY v2.6** | Add: Reagent ISRU as critical transition. Thorium MSR as power transition. PGM dual-track decision gate at P8. D2EHPA elimination note. Temporary PKT commissioning crew. | HIGH |
| **W2_T1_1_JS_MTL_GUIDE v17** | Update: Cargo manifests — add reagent pilot (5,000 kg) to Cargo Launch 4. Add M5.5 milestone. Remove bulk H₂SO₄/NaOH/D2EHPA from P10+ manifests. Add YBCO tape to standing manifest P10+. Update permanent Earth dependencies (remove D2EHPA, add YBCO, add Hastelloy-N). | HIGH |
| **W3_T2_1_JS_ValueChain v1.0** | Update: Add reagent self-sufficiency loop. Add split value chain (group separation on Moon, SX on Earth). Add PGM scouting. Remove D2EHPA from all flowcharts. | MEDIUM |
| **SELENITE_SCALE v1.3** | MAJOR: (a) Hauler mass 1,200 → ~1,450 kg (Na-S battery + mining bucket/blade), in-situ fraction 92% → ~57%. (b) Replace catapult count with conveyor km (P9: 500 km, P10: 5,000 km, P11: 15,000 km, P12: 87,500 km). (c) MOLE-I scaling corrected: demand-driven by PROBE fleet + ECLSS + crew rotation, NOT by PKT transport. Fleet: 170 (P7–P8), ~240 (P9), ~280 (P10), ~355 (P12). Old figures (48,990 at P8, 390,790 at P9) eliminated — physically impossible on crater floor. (d) Mass driver timeline: SPA→PKT at P8 (was P10), PKT→Earth at P9 (was P10). (e) Na-S battery mass. (f) YBCO reduced to ~175–300 t lifetime. (g) Recalculate Starship flights — P8–P9 logistics drop dramatically without MOLE-I scaling. | HIGH |
| **SELENITE_ECON v1.0** | MAJOR: Apply all corrections — in-situ fabrication at 55–60% (not 92%), D2EHPA elimination, reagent demand reduction, thorium MSR power, YBCO import cost, Na-S mass penalty. | HIGH |
| **SEL-DECISION-001 Rev A** | Update: Correct DG-6.1 (processing gate retired per ECN-015). Add thorium MSR decision gates. Add PGM decision gate. Add PKT commissioning crew. Integrate manufacturing findings. | HIGH |
| **NEW: SEL-REAGENT-001 Rev A** | Standalone spec for in-situ reagent production system. SPA pilot + PKT plant. Troilite extraction, contact process, Ca(OH)₂ from anorthite, H₃PO₄ from apatite. | HIGH |
| **NEW: SEL-FAB-001 Rev A** | PKT foundry/fabrication facility spec. MRE cells, WAAM/EB welding lines, Fe-Si and Al production, distributed canister manufacturing. Pilot 25 t/yr → industrial 100,000 t/yr scaling. | HIGH |
| **NEW: SEL-CANISTER-001 Rev A** | Mass driver return canister spec. Fe-Ni shell, Al₂O₃/SiO₂ ablative TPS, parachute + electronics from Earth. 5 t total / 3.5 t REO. Distributed production at 783/day. | MEDIUM |
| **NEW: SEL-POWER-PKT-001 Rev A** | PKT power architecture. Thorium MSR fleet at 100 MWe units. Chloride salt configuration. ThCl₄ fuel from KREEP waste. In-situ Ni-201 vessels (P11+). Construction sequence with crew safety protocol. | HIGH |

---

## 8. Summary of Programme-Wide Impact

### 8.1 Earth Dependencies Eliminated or Reduced

| Dependency | Previous | After ECN-019 | Change |
|-----------|----------|---------------|--------|
| D2EHPA | 2.5 Mt/yr at P12 | 0 | Eliminated |
| NaOH | 9 t/yr/circuit | 0 | Replaced by Ca(OH)₂ |
| Oxalic acid | 2 t/yr/circuit | 0 | Replaced by hydroxide/phosphate precipitation |
| Bulk reagent flights (P12) | ~1.2M flights/yr | ~60 flights/yr | 99.995% reduction |
| FSP units (P12) | 12,052,243 (absurd) | ~11 at SPA + 1,386 at PKT P8 | Replaced by thorium MSR |
| Nuclear fuel (P12) | ~4,479 t/yr HALEU | ~0 (self-breeding) | Thorium from KREEP waste |
| YBCO superconductor | ~209,000 t (9,084 catapult hubs) | ~150–250 t lifetime (3 mass drivers) | 99.9% — ore catapults → conveyor |
| Ore catapult infrastructure | 9,084 hub pairs from Earth | 0 | Replaced by 95% in-situ steel conveyor |

### 8.2 Design Changes Required

| System | Change | Mass impact | Performance impact |
|--------|--------|------------|-------------------|
| Hauler batteries | Li-ion → Na-S | +100 kg/unit | Self-heating; higher operating temp |
| Hauler motors | SmCo BLDC → SRM | ~0 | −10–20% power density; −5–10% efficiency |
| Hauler in-situ fraction | 92% → 55–60% | N/A | More Earth logistics but realistic |
| Catapult coils | 9,084 ore catapult hubs → steel conveyor network | Saves ~$11B/yr; +6–9 Mt in-situ steel | Zero YBCO for ore transport; 3–4 mass drivers retained (~175–300 t YBCO lifetime) |
| PKT power | FSP → thorium MSR | Reactor vessels from Earth | Continuous power through lunar night |
| REE processing | Full SX on Moon → group separation + Earth SX | Simpler lunar plant | Earth captures final separation value |
| PKT construction | Fully autonomous → temp crew commissioning | Hab for 3–4 crew, 6–12 months | De-risks foundry and MSR commissioning |

### 8.3 Permanent Earth Dependencies at P12 (Audit-Based, Minimal Chute Option)

| Category | t/yr | Flights/yr | Driver |
|----------|------|-----------|--------|
| Hauler spares (avionics, BMS, bearings, motor electronics) | ~13,000–19,000 | ~130–190 | 1.49M units × ~3 kg/yr avionics + ~6 kg/yr battery BMS + ~2 kg/yr bearings |
| Canister recovery systems (minimal drag chute option) | ~8,000 | ~80 | 285,715/yr × ~28 kg (10 kg chute fabric + 18 kg deploy/electronics) |
| Processing circuit maintenance | ~5,000 | ~50 | 2.5M circuits × ~2 kg/yr (PTFE linings, sensors, pumps, valves) |
| MSR maintenance | ~1,500 | ~15 | Ni-201 in-situ vessels by P11+; turbomachinery + spares from Earth |
| Conveyor network | ~1,250 | ~13 | 50,000 drive stations (electronics, bearings) + roller bearings |
| SPA base + crew | ~350 | ~4 | Robot spares, biologicals, crew supplies, pharmaceuticals |
| Lubricants (MoS₂) + catalysts (V₂O₅) + EDTA + other | ~1,200 | ~12 | Programme-wide consumables |
| **TOTAL** | **~30,000–36,000** | **~300–360** | |

Note: range reflects battery replacement cycle assumptions (5-year vs 15-year Na-S cell life). Canister recovery is the key sensitivity — full parachute option adds ~13,000 t/yr; shuttlecock option saves ~6,000 t/yr.

**Total P12 Earth logistics: ~300–360 Starship flights/yr.** This supports 3.1 Bt/yr ore processing and 1 Mt/yr REO export. Earth import mass represents <0.001% of total operational mass throughput.

---

---

## 9. MOLE-I Fleet Scaling — Demand-Driven by Propellant, Not PKT Transport

### 9.1 Correction from Previous Architecture

Previous SELENITE_SCALE v1.3 specified MOLE-I counts of 48,990 (P8) and 390,790 (P9). These figures were driven by propellant demand for **chemical tanker flights from SPA to PKT** (each LLO transfer consuming ~100+ t ISRU propellant) to fuel SKIPs that were specified to operate at PKT during P8–P9 (SEL-PROC-PKT-001 §3). The SEL-HAULER-001 spec itself acknowledged this was unsustainable: "chemical SKIPs would consume ~953 Mt/yr of propellant (exceeding all lunar ice reserves in 1–4 years)."

**Resolution: No SKIPs at PKT — ever. No MOLE-S at PKT.** Mining-capable haulers (with front bucket/blade, ~1,450 kg dry) handle ALL PKT surface operations from P8 day one: self-load 5 t KREEP regolith (~25 min dig cycle), transport to processing spine, grade terrain for SINTER, trench for utilities, supply regolith to SINTER input. One vehicle class replaces both SKIP and MOLE-S at PKT. Haulers operate off-road at 0.3 m/s initially, improving to 1.0 m/s on sintered road. MOLE-S remains SPA-only (crater rim construction, unchanged). SPA→PKT mass driver (operational at P8 boundary) carries Fe-Ni feedstock, Th(OH)₄, and spares — NOT propellant for PKT SKIPs. All PKT construction fleet and infrastructure arrives via Earth Starship directly to PKT ELZ (NOT via SPA).

Additionally, the Shackleton crater floor physically accommodates ~310 MOLE-I (~62 substations on ~8.5 km² usable flat area, accounting for central mound, landslides, and boulder fields occupying ~50% of the 34.2 km² floor). The P9 figure of 390,790 exceeds total south pole PSR capacity by ~10× and was never physically achievable.

### 9.2 Revised MOLE-I Scaling (Demand-Driven)

Each MOLE-I produces 5,692 kg/yr propellant (7,818 kg/yr water × 0.722 electrolysis efficiency). Each PROBE mission consumes 6,654 kg propellant. PROBE equivalence: 0.855 PROBE missions per MOLE-I per year.

| Phase | MOLE-I | PROBE fleet | SKIP fleet | Other demand | Supply (t/yr) | Demand (t/yr) | Margin |
|-------|--------|-------------|------------|-------------|---------------|---------------|--------|
| P7 | 170 | 30 | 8 (SPA KREEP) | DART + crew | 968 | 868 | +11.5% |
| P8 | ~247 | 96 | 8 (continuing SPA KREEP) | Crew only | 1,406 | 1,403 | +0.2% |
| P9 | ~240 | ~190 | **0 (retired — PKT dominates)** | Crew only | 1,367 | 1,364 | +0.2% |
| P10 | ~286 | ~230 | 0 | Crew only | 1,628 | 1,630 | −0.1% |
| P11 | ~322 | ~260 | 0 | Crew only | 1,833 | 1,830 | +0.2% |
| P12 | ~355 | 286 | 0 | Crew only | 2,021 | 2,023 | −0.1% |

SKIPs operated exclusively at SPA (100 km hop range from Shackleton to SPA Basin KREEP exposures). They were never based at PKT — PKT is 3,300 km from SPA, reachable only via DART's LLO orbital transfer. The old 48,990+ MOLE-I figures were driven by chemical TANKER flights to PKT, not by SKIP operations. SKIPs retire at P9 when PKT's 2,500 circuits produce 1,000 t/yr REO, far exceeding SPA's 5-circuit research output of 0.4 t/yr.

P10–P12 show marginal shortfalls at the 4.46% ice design point. If actual ice fraction is at LCROSS-measured 5.6%, all phases have positive margin. At 4.46%, de Gerlache crater (5–10 km from Shackleton via Connecting Ridge, ~12 km² usable PSR floor) provides ~45 additional MOLE-I positions, closing the gap.

DART propellant demand is zero from P8 onward — DART operates at PKT on surface power, delivered by mass driver. No chemical propulsion required.

### 9.3 Economic Impact

| Item | Old architecture (SCALE v1.3) | New architecture | Saving |
|------|-------------------------------|-----------------|--------|
| P8 MOLE-I | 48,990 units × 360 kg = 17,636 t | ~77 new units × 360 kg = 28 t (170→247) | ~$70B |
| P9 MOLE-I | 341,800 units × 360 kg = 123,048 t | 0 new (247→240, SKIP retirement frees capacity) | ~$492B |
| P9 substations | ~68,360 nodes | ~14 new nodes | ~$37B |
| P9 FSP (for MOLE-I power) | ~9,851 FSP | ~0 additional for MOLE-I | ~$200B |
| Multi-crater infrastructure | 7+ craters with independent trunk cables, heated pipelines | Shackleton only (+ de Gerlache P13+ if needed) | ~$50B+ |
| **Total saving** | | | **~$850B** |

---

## 10. Canister Recovery Architecture — DG-9.1

At P12, 285,715 canisters/year enter Earth's atmosphere at ~11 km/s. After re-entry (ablative TPS from in-situ Al₂O₃/SiO₂ handles heating), the canister decelerates through Earth's atmosphere to terminal velocity. Recovery architecture determines the single largest variable in P12 Earth imports.

| Option | Concept | Earth content/canister | P12 Earth import | Annual cost |
|--------|---------|----------------------|-----------------|-------------|
| 1a | Full parachute (~35 m² Nomex canopy) | ~73 kg | ~20,900 t/yr (~209 flights) | ~$42B/yr |
| **1b** | **Minimal drag chute (~5 m diameter) + thickened Fe-Ni wall (8 mm)** | **~28 kg** | **~8,000 t/yr (~80 flights)** | **~$16B/yr** |
| 2 | Shuttlecock (flared aft skirt, no fabric) — requires ocean impact survival validation at ~160 m/s | ~8 kg | ~2,300 t/yr (~23 flights) | ~$4.6B/yr |

**Recommended baseline: Option 1b.** Terminal velocity with minimal chute: ~50 m/s. Fe-Ni wall at 8 mm (vs 4 mm) survives ocean impact — water hammer pressure ~70 MPa vs Fe-Ni yield 260–935 MPa. Wall mass increase is in-situ steel (zero Earth penalty). Chute mass drops from ~35 kg to ~10 kg fabric.

Economic model should evaluate all three options as sensitivity cases. Decision required before PKT→Earth mass driver commissioning at P9.

---

## 11. Earth Import Audit — P12 Steady-State (Component-Level)

The following audit traces Earth imports from actual fleet counts and component-level replacement rates, replacing the rough estimates in §8.3 Rev A.

**Hauler fleet (1,488,096 units):**
- Avionics replacement: ~3 kg/unit/yr (LiDAR, cameras, sensors — not full module swap) = ~4,500 t/yr
- Motor electronics: ~5% annual failure rate × ~30 kg Earth content = ~2,200 t/yr
- Bearings/seals: ~20% annual replacement × ~10 kg = ~3,000 t/yr
- Na-S battery BMS + Earth fraction: ~30 kg Earth content per pack, 5–15 yr cell life = ~3,000–9,000 t/yr
- **Hauler subtotal: ~13,000–19,000 t/yr**

**Mass driver canisters (285,715/yr, expendable):**
- Minimal drag chute: ~10 kg Nomex/Kevlar fabric
- Deployment mechanism: ~10 kg
- Electronics (beacon, GPS, altimeter, telemetry): ~5 kg
- Pyrotechnics: ~3 kg
- **Canister subtotal: ~28 kg/unit × 285,715 = ~8,000 t/yr**

**Processing circuits (2,500,000 units):**
- PTFE linings, sensors, pumps, valves, filter membranes: ~2 kg Earth content/circuit/yr
- **Circuit subtotal: ~5,000 t/yr**

**MSR reactors (6,890 units, 20-yr life):**
- Ni-201 vessels in-situ by P11+ (declining Hastelloy-N)
- Turbomachinery spares: ~345 replacements/yr × ~3,000 kg = ~1,000 t/yr
- Control systems, instrumentation: ~500 t/yr
- **MSR subtotal: ~1,500 t/yr**

**Conveyor network (87,500 km):**
- Drive station electronics: 5,000 replacements/yr × 150 kg = ~750 t/yr
- Roller bearings: ~500 t/yr
- **Conveyor subtotal: ~1,250 t/yr**

**SPA base (steady-state):** Robot spares ~200 t/yr, ECLSS/biological ~100 t/yr, crew ~50 t/yr = ~350 t/yr

**Other:** MoS₂ ~500 t/yr, V₂O₅ ~200 t/yr, seals/gaskets ~300 t/yr, EDTA ~10 t/yr = ~1,200 t/yr

**TOTAL: ~30,000–36,000 t/yr = ~300–360 Starship flights/yr**

Parachute/canister recovery drives ~25% of imports. Hauler battery BMS drives ~10–25% (sensitive to cell life). All other categories combined are ~35–40%.

*— End of ECN-019 Rev B content —*

---

## 12. Programme Target Revision — 2.5 Mt/yr REO (Rev C)

### 12.1 Committed Target

The programme target is revised from 1.25 Mt/yr to **2.5 Mt/yr REO** — full replacement (not just displacement) of terrestrial REE mining. At projected 2100 global demand of ~2.5 Mt/yr (IEA NZE scenario extrapolated, capped by population plateau at ~10B and recycling maturation), 2.5 Mt/yr achieves 100% substitution.

### 12.2 Revised Timeline

| Phase | Years | REO t/yr | Milestone |
|---|---|---|---|
| P7 | Y18–Y25 | 0.4 | Proof of concept |
| P8 | Y25–Y35 | 125 | PKT base online |
| P9 | Y35–Y45 | 1,000 | Mass driver era |
| P10 | Y45–Y60 | 10,000 | Full-scale operations |
| P11 | Y60–Y80 | 100,000 | 10% displacement |
| P12 | Y80–Y120 | 100k→500k | Scaling |
| P13 | Y120–Y140 | 500k→1,250,000 | 50% replacement milestone |
| P14 | Y140–Y180 | 1.25M→2,500,000 | Full replacement |
| P14+ | Y180+ | 2,500,000 (steady state) | Maintenance only |

Build-out is constrained by Starship launch cadence (~200 kt/yr cargo cap, ~2,000 flights/yr).

### 12.3 Economic Evaluation Summary

From SEL-ECON-001 Rev A (SELENITE_ECON v1.3/v1.4):

- **Total cost (200 yr):** $21.3 T ($106 B/yr average = 4.7% of global military spending)
- **BCR (200-year):** 0.50; **BCR (annual, steady state Y180+):** 2.06
- **NPV (all externalities):** -$0.49 T (declining discount rate 3.0/2.5/2.0%)
- **Steady-state net surplus:** +$121.8 B/yr from Y181
- **CO₂ avoided at steady state:** 182 Mt/yr

The programme is NOT commercially viable on direct revenue ($1.48 T vs $21.3 T cost). The economic case rests on internalised externalities: avoided mining damage ($10.4 T), H₂ enabling via Ir ($2.6 T), geopolitical insurance ($1.2 T). Requires government-consortium funding per Arrow et al. (2014).

---

## 13. Optimised Processing Circuit Design (Rev C)

### 13.1 Circuit Throughput Selection

The programme commits to an **optimised continuous-flow design** at 1.2 t/yr REO per circuit, replacing the batch design at 0.4 t/yr. This is the single highest-value design decision in the programme ($22 T cost reduction over 200 years vs batch).

| Design | REO/yr | Mass (kg) | Power (kW) | Circuits for 2.5 Mt/yr | Total mass |
|---|---|---|---|---|---|
| Batch (rejected) | 0.4 | 15,000 | 180 | 6,250,000 | 93.8 Mt |
| Continuous-flow | 0.8 | 22,000 | 300 | 3,125,000 | 68.8 Mt |
| **Optimised (committed)** | **1.2** | **28,000** | **400** | **2,083,334** | **58.3 Mt** |

Physics basis: continuous-flow reactors eliminate batch dead time (~30% of cycle). Acid bake (2–4 hr), leaching (4–8 hr), precipitation (1–2 hr per stage) operate simultaneously in sequence. Larger vessels follow cube-square law (~1.5× mass for 2× volume).

### 13.2 Circuit Maintenance Rate

Revised from 2% to **0.5% of mass per year** as Earth-sourced spare parts. Justified by: mature foundry producing replacement vessels/piping in-situ from Y45, 130+ years of foundry operating experience by steady state, and asteroid-sourced materials (C-type PTFE, S-type sensors) reducing Earth fraction to 0.8%.

### 13.3 Circuit Earth Fraction Trajectory

| Era | Earth fraction | Driver |
|---|---|---|
| P8 (Y25) | 100% | All Earth-built |
| P10+ (Y55) | 10% | Foundry produces vessels, piping, manifolds |
| Post C-type (Y105–Y115) | 3% | PTFE, polymer seals, filter cloths from C-type carbon |
| Post S-type (Y125–Y135) | **0.8%** | Sensors, Cu wiring from S-type Si/Cu |

**Decision gate DG-8.X:** Circuit throughput validation — target ≥1.0 t/yr REO per circuit before committing to full-scale PKT build-out.

---

## 14. PROBE Fleet Lifecycle (Rev C)

### 14.1 Mk Classification

| Class | Era | Fleet | Propulsion | Lands? | Missions/yr | Role |
|---|---|---|---|---|---|---|
| Mk I | P5–P8 | 30→96 | Chemical | Yes (SPA IZ) | 1 | Basic scraper collection |
| Mk II Heavy | P9–P11 | 190→260 | Chemical | Yes (SPA IZ) | 1 | In-situ beneficiation (500 t → 10 t) |
| Mk I/II phasedown | P11+ | 260→30 | Chemical | Yes | 1 | Specialist SPA short-range ops |
| **Mk III SEP** | **P11+** | **0→1,714→300** | **Ion** | **Never** | **0.5** | **Bulk remote mining → prospecting** |

### 14.2 Mk III SEP Architecture (DG-11.6)

- **Ion propulsion** (xenon/argon from asteroid volatiles or Earth supply). ~1,200 kg dry. Larger solar arrays than Mk I/II (no landing loads, no dust).
- **Never lands on the Moon.** Stays in orbit permanently. Ejects 10 t Fe-Ni/PGM payload canisters from LLO on ballistic deorbit trajectory.
- **EM catcher at SPA** receives canisters at ~1,680 m/s — same YBCO coil technology as mass drivers, run in reverse. The PKT→SPA mass driver receiver (built P9–P10 for ThCl₄ delivery) serves double duty.
- **Canister:** Fe-Ni shell (ferromagnetic, compatible with EM braking) + small cold-gas kick motor (~5–10 kg) for trajectory shaping.
- **Electromagnetic anchoring on M-type asteroids:** Fe-Ni surface is ferromagnetic → powered electromagnet pads, no harpoons or drills. Attachment force enormous relative to ~0.0001 m/s² surface gravity. Heritage: Northrop Grumman MEV-1 (2020).
- **Operational sequence:** (1) ion thrust transit 3–8 months; (2) velocity matching to cm/s; (3) LiDAR surface mapping at 100 m; (4) terminal approach at 2–5 cm/s; (5) EM anchor engagement (3–4 pads); (6) scraper mining 6–12 months; (7) disengage (cut current), cold-gas separation, ion return.

### 14.3 Fleet Phasedown

- Y60–Y80: Mk III build-out (~86/yr), Mk I/II phasedown (260→50)
- Y85: Mk I/II at 30 units (specialist SPA ops only)
- Y115: All 3 asteroid captures complete → Mk III reduces from 1,714 to 300 (prospecting only)
- Decommissioned Mk I/II salvaged at SPA — Fe-Ni frames, motors, electronics recycled (~184 t recovered)

### 14.4 Propellant Demand Cascade

| Year | Mk I/II fleet | Propellant demand | MOLE-I needed |
|---|---|---|---|
| Y45 | 230 | 1,530 t/yr | ~280 |
| Y70 | 150 | 998 t/yr | ~190 |
| Y85 | 30 | 200 t/yr | ~50 |
| Y110+ | 30 (C-type water) | 0 from lunar ice | ~50 (crew ECLSS only) |

Mk III uses zero ISRU propellant (ion drive). MOLE-I fleet drops to ~50 from Y85, irrespective of Mk III fleet size.

### 14.5 Captured Asteroids vs PROBEs

**Captured asteroids do NOT use PROBEs.** They have dedicated permanent infrastructure (Laser Ablation Truss + mass driver) attached to the asteroid in DRO. PROBEs are for remote uncaptured asteroids only. The two systems are architecturally independent.

---

## 15. Base Specialisation Architecture (Rev C)

### 15.1 SPA (Shackleton) = Asteroid Processing Hub

**ALL asteroid material (M/C/S-type) processed at SPA.** SPA has existing PGM hydromet from P5+ PROBE heritage. C-type and S-type processing facilities built at SPA from Y105/Y125. Products shipped SPA→PKT via mass driver where needed for circuit fabrication (PTFE, Si, Cu).

SPA role evolution:
- P0–P10: ISRU propellant hub + crew base + PROBE launch
- P11+: PGM processing hub (Mk III canisters via EM catcher)
- P12+: Full asteroid hub (M/C/S-type processing)
- P14+: Deep-space launch hub (ISRU propellant revives for interplanetary missions)

**SPA MSR fleet** for asteroid processing power:
- Y105: 1 MSR (C-type pyrolysis, ~50 MWe)
- Y125: +1 MSR (S-type Si refinery, ~100 MWe)
- Y140: +1 MSR (scaled operations)
- ThCl₄ fuel from PKT→SPA mass driver (already exists from P9)

### 15.2 PKT (Procellarum) = KREEP REO Processing ONLY

**Every km² of PKT surface is valuable KREEP ore.** No non-KREEP infrastructure is built on it. PKT has: processing circuits, haulers, conveyors, SINTER, MSR for KREEP power. No PROBE operations, no asteroid processing, no PGM.

---

## 16. Diversified Asteroid Strategy (Rev C)

### 16.1 Three Captures, Each Enabling the Next

The programme captures ONE of each asteroid type — not multiple M-types. Each capture enables the next through enabling feedstock:

| Capture | Type | Size | Year | Processing | Provides | Duration |
|---|---|---|---|---|---|---|
| 1 | M-type | ~200 m | Y75 | Y85+ | 36.5 t/yr PGM, Fe-Ni for foundry | 80+ yr campaign |
| 2 | C-type | ~100 m | Y95 | Y105+ | Water, carbon, nitrogen | Circuit Earth frac 10%→3% |
| 3 | S-type/E-type | ~100 m | Y115 | Y125+ | Silicon, copper | Circuit Earth frac 3%→0.8% |

### 16.2 Synergies

- C-type carbon is the feedstock for S-type silicon refining (carbothermic reduction)
- C-type water provides propellant independence (MOLE-I drops to ~50 for crew ECLSS)
- M-type Fe-Ni reduces hauler Earth fraction from 43% to 20% floor
- Combined M/C/S-type exploitation achieves near-complete Earth independence by ~Y135

### 16.3 C-type Thermal Management

Reflective MLI blanket over unmined C-type surfaces to preserve subsurface ice in continuous DRO solar exposure. Low mass, high impact. Mining proceeds under blanket at exposed face; blanket repositioned as spiral ablation progresses.

### 16.4 Processing Locations

**ALL processing at SPA** (not PKT):
- M-type: PGM hydromet (existing PROBE heritage)
- C-type: Pyrolysis + Fischer-Tropsch + polymer synthesis (from Y105)
- S-type: Si refinery (Czochralski process) + Cu electrolysis (from Y125)
- Products mass-driven SPA→PKT where needed for circuit fabrication

### 16.5 Redirect Tugs

SEP/NEP redirect tugs: ~50,000 kg each, 20-yr replacement cycle. Fleet: 2 tugs initially (Y65, M-type redirect), growing to 3 (C-type) then 5 (S-type + redundancy). Earth-built, LEO launch only ($500/kg), self-transfer via ion drive.

### 16.6 Decision Gates

- **DG-14.1 (Y95):** C-type asteroid targeting for polymer precursors
- **DG-14.2 (Y115):** S-type targeting for semiconductor feedstock
- **DG-14.3 (Y140):** Earth independence assessment

---

## 17. Laser Ablation Truss Mining (Rev C)

### 17.1 Concept

Linear rigid truss with dual high-power laser heads at each end. Truss rotates slowly around asteroid's long axis. Laser heads perform surface ablation in spiral pattern (~1 m depth channel), peeling the asteroid progressively. No mechanical contact — avoids microgravity reaction force problems.

### 17.2 Specifications

- **Power:** ~350 MW total (3–4 MSR units or ~1.2 km² solar array at DRO)
- **Throughput:** ~1,000 t/day = ~365,000 t/yr
- **PGM yield:** at 100 ppm PGM in Fe-Ni matrix → 36.5 t/yr PGM per asteroid
- **Ejecta capture:** Electrostatic/magnetic collector behind each laser head. Continuous feed stream of sublimated metal vapour + spalled fragments.
- **Advantages over diameter cuts:** Lower peak power, continuous processing, captures condensed metal vapour directly, avoids cutting through 100+ m of Fe-Ni.

### 17.3 Decision Gate

**DG-13.2:** Asteroid mining method selection (laser ablation vs mechanical vs hybrid). Laser ablation truss is recommended baseline. Heritage: DE-STAR programme (Lubin, UCSB) demonstrated laser ablation rates in vacuum.

---

## 18. Mass Driver Network Expansion (Rev C)

### 18.1 Five Mass Drivers

| ID | Route | Velocity | Track | YBCO | Year | Purpose |
|---|---|---|---|---|---|---|
| MD-1 | SPA→PKT | ~1,800 m/s | ~3.3 km | ~60 t | Y25 (P8) | Fe-Ni, Th(OH)₄, spares |
| MD-2 | PKT→Earth | ~2,400 m/s | ~5 km | ~100 t | Y35 (P9) | REO canisters |
| MD-3 | PKT→SPA | ~1,800 m/s | ~3.3 km | ~30 t | Y43 (P9–P10) | ThCl₄ fuel for SPA MSR |
| MD-4 | SPA→Earth | ~2,400 m/s | ~5 km | ~60 t | Y70 (P11) | PGM exports (DG-11.6) |
| **MD-5** | **DRO→SPA** | **~800 m/s** | **~500 m** | **~30 t** | **Y85 (P12+)** | **Captured asteroid concentrate** |

Total YBCO: ~280 t lifetime (was ~209,000 t for 9,084 catapult hubs in original architecture).

### 18.2 EM Catchers

SPA operates EM catchers for two inbound streams:
- PKT→SPA mass driver canisters (ThCl₄ fuel)
- DRO→SPA mass driver canisters (asteroid concentrate)
- Mk III PROBE LLO canister ejections (~1,680 m/s, decelerated by EM catcher)

Same YBCO coil technology as mass drivers, run in reverse.

---

## 19. Environmental Accounting Framework (Rev C)

### 19.1 Four Externality Streams

**1. REO mining displacement:** $73,700/t REO displaced. Source: Lee & Wen (2018) EEIO ($63,000–$83,000/t) + EPA SCC at $190/t CO₂ (~$5,700/t for 30 t CO₂-eq/t REO lifecycle). At 2.5 Mt/yr: $184 B/yr.

**2. H₂ enabling via iridium:** 50% marginal attribution. Ir (15% of PGM) → PEM electrolysers (1 GW/t Ir, 20-yr stack life) → green H₂ → CO₂ avoided at 12 t CO₂/t H₂ (energy + green steel DRI + green ammonia). At steady state with PROBE Mk III + captured asteroid Ir: ~59.5 GW PEM installed → 107 Mt CO₂/yr avoided → $20.3 B/yr.

**3. Geopolitical supply-chain insurance:** $15 B/yr at 50%+ supply displacement. China controls 85–90% of REE processing. 2010–11 export restrictions caused 14× price spike. EU gas crisis (40% dependency on Russia) cost >€1 T.

**4. Rocket emissions (negative):** 2,750 t CO₂/launch × tanker ratio (14→8→5 with LEO depot maturation) × fossil fraction (100%→5% with DAC methane by Y80). Peak ~3 Mt CO₂/yr at Y45–50 during P9–P10 build-out. Near carbon-neutral from P11+. Lifetime: 52 Mt CO₂ over 200 years.

### 19.2 CO₂ Balance at Steady State (Y200)

| Stream | Mt CO₂/yr | Direction |
|---|---|---|
| REE mining lifecycle avoided | 75.0 | Positive |
| H₂ via Ir (PEM → steel/ammonia) | 107.1 | Positive |
| Rocket emissions (5% fossil frac) | 0.3 | Negative |
| **NET** | **181.7** | **Strongly positive** |

### 19.3 DAC Methane Timeline

Fossil propellant fraction: 100% (Y0–Y30) → 80% (Y45) → 30% (Y60) → 5% (Y80+). The Y80+ near-zero timing aligns with the programme's P12 cargo ramp. SpaceX has discussed DAC+Sabatier for Mars propellant — same process at Earth scale.

---

## 20. Construction Fleet Scaling (Rev C)

### 20.1 Fleet Types

| Vehicle | Scales with | Unit mass | Replacement |
|---|---|---|---|
| ARM-C (assembly) | 1 per 500 circuits/yr | 1,500 kg | 10-yr life |
| SINTER (construction) | 1 per 200 circuits/yr | 2,200 kg | 15-yr life |
| SENTINEL (monitoring) | 1 per 500 circuits | 80 kg | 10-yr life |
| Charging hubs | 1 per 100 haulers | 5,000 kg (95% in-situ) | Long life |

### 20.2 Steady-State Minimum Fleet

During maintenance (no new circuit construction): ~20 ARM-C, ~50 SINTER for road/enclosure repairs, SENTINEL scales with circuit count. Total construction fleet cargo: ~0.3% of total Earth cargo — small but present for completeness.

---

## 21. P14+ Earth Independence Vision (Rev C)

### 21.1 Earth Fraction Trajectory

| Year | Circuit | Hauler | MSR | Earth dependency |
|---|---|---|---|---|
| P8 (Y25) | 100% | 100% | 100% | Everything from Earth |
| P10 (Y55) | 10% | 43% | 30% | Foundry produces steel, Al |
| P12 (Y85) | 10% | 33% | 30% | M-type Fe-Ni improves hauler |
| Post C-type (Y115) | 3% | 25% | 30% | PTFE, polymers in-situ |
| Post S-type (Y135) | **0.8%** | **20%** | 30% | Si sensors, Cu wiring in-situ |

### 21.2 Remaining Earth Dependencies at Y135

- Advanced integrated circuits (processors, FPGAs)
- Specialty optical components (LiDAR optics)
- Some precision bearings (ceramic hybrids)
- Estimated: <0.5% of total infrastructure mass

### 21.3 Beyond Y200

With M-type (Fe-Ni, PGM), C-type (water, carbon, nitrogen), and S-type (silicon, copper) resources combined, the programme becomes functionally independent of Earth supply. Infrastructure supports indefinite operation and growth without Earth resupply. The programme's purpose evolves from "betterment of Earth" to "self-sustaining cislunar industrial civilisation" — designed to be maintained and grown for millions of years.

---

## 22. Updated Document Impact Matrix (Rev C Additions)

| Document | Rev C Changes Required | Priority |
|---|---|---|
| **SEL-DECISION-001** | MAJOR: Update to v3. 2.5 Mt/yr target. PROBE Mk III lifecycle. Base specialisation. Diversified asteroids. Laser truss. 5 mass drivers. Economic findings. Circuit throughput. Construction fleet. P14+ vision. | CRITICAL |
| **SEL-T1_1-STRATEGY** | MAJOR: All of above propagated to strategy narrative. Funding model (government-consortium, internalised externalities). 200-year timeline. | HIGH |
| **SEL_ROBOT_FLEET** | MAJOR: PROBE Mk III section. Mk I/II phasedown table. Fleet scaling to Y200. Construction fleet (ARM-C/SINTER/SENTINEL). | HIGH |
| **W2_T1_1_JS_MTL_GUIDE** | MAJOR: P13/P14 phases. Cargo manifests for Y140–Y180 build-out. Asteroid milestones. Environmental milestones. | HIGH |
| **SEL-HAULER-001** | Update: M-type Fe-Ni reducing Earth frac to 20% floor from Y90. | MEDIUM |
| **SEL-PROC-001 / SEL-PROC-PKT-001** | Update: Optimised circuit design (1.2 t/yr, 28,000 kg, 400 kW). 0.5% maint rate. | HIGH |
| **SEL-POWER-001** | Update: SPA MSR fleet (3 units from Y105–Y140). Power budget for C-type/S-type processing. | MEDIUM |
| **SEL_PROBE_DESIGN** | MAJOR: Add Mk III SEP spec. EM anchoring. LLO canister ejection. Phasedown table. | HIGH |
| **SEL-ECON-001** | Complete — delivered as Rev A with v1.3/v1.4 MATLAB. | DONE |
| **SELENITE_SCALE** | Update: 2.5 Mt/yr target. Circuit count 2,083,334. Hauler scaling to 1,500,000. | HIGH |

---

*— End of ECN-019 Rev C —*
