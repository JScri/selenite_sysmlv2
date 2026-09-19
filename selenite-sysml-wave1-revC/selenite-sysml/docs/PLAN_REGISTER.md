# Selenite plan check - derived-versus-declared register

Gates: 81; derivable 39, testOutcome 13, exogenous 29. Element bindings: 89. Python layer: loaded.

Phase of a year: inclusive windows from SelenitePhases::ProgrammeTimeline; a boundary year belongs to both phases (Y25 = P7/P8). Verdicts compare the derived phase with declaredPhase and declaredPhaseAlternate. 'never met on current vectors' means the criterion as written is false in every year to Y200 of the ECON v1.3/v1.4 port - a finding, not a decision.

## 1. Gate register

| Gate | Kind | Declared phase | Declared year | Year-phase | Derived | Verdict | Note |
|---|---|---|---|---|---|---|---|
| DG-0.1 | exogenous | P0 | - | - | declared | declared | exogenous: no parameter carries the year |
| DG-0.2 | exogenous | P0 | - | - | declared | declared | exogenous: no parameter carries the year |
| DG-0.3 | exogenous | P0 | - | - | declared | declared | exogenous: no parameter carries the year |
| DG-0.4 | exogenous | P0 | - | - | declared | declared | exogenous: no parameter carries the year |
| DG-1.1 | testOutcome | P1 | Y2 | P0/P1 | assumed | assumed | assumedOutcome = true |
| DG-2.1 | testOutcome | P2 | Y4 | P1/P2/P3 | assumed | assumed | assumedOutcome = true |
| DG-2.2 | testOutcome | P2 | Y5 | P2/P3 | assumed | assumed | assumedOutcome = true |
| DG-3.1 | testOutcome | P3 | Y5.5 | P2/P3 | assumed | assumed | assumedOutcome = true |
| DG-3.2 | derivable | P3 | Y6 | P2/P3 | ISRU supply >= total fleet demand: P3 | consistent | VERIFY ph.isru [28460, 170760, 313060, 512280, 1024560] vs ph.dT [19962, 130482, 258958, 459373, 924931] (P3..P7) |
| DG-4.1 | testOutcome | P4 | Y7 | P3/P4 | assumed | assumed | assumedOutcome = true |
| DG-4.2 | testOutcome | P4 | Y7 | P3/P4 | assumed | assumed | assumedOutcome = true |
| DG-4.3 | derivable | P4 | Y8 | P4 | ISRU supply >= PROBE demand: P3 | earlier than declared | VERIFY ph.isru [28460, 170760, 313060, 512280, 1024560] vs ph.dP [19962, 39924, 66540, 99810, 199620] (P3..P7) |
| DG-5.1 | derivable | P5 | Y9 | P4/P5 | ISRU supply >= demand incl. DART mission: P5 | consistent | VERIFY ph.isru [28460, 170760, 313060, 512280, 1024560] vs ph.dT [19962, 130482, 258958, 459373, 924931] (P3..P7) |
| DG-5.2 | exogenous | P5 | Y10 | P5 | declared | declared | exogenous: no parameter carries the year |
| DG-5.3 | exogenous | P5 | Y10 | P5 | declared | declared | exogenous: no parameter carries the year |
| DG-5.4 | exogenous | P5 | Y10 | P5 | declared | declared | exogenous: no parameter carries the year |
| DG-6.1 | exogenous | P6 | Y12 | P5/P6 | declared | declared | exogenous: no parameter carries the year |
| DG-6.2 | testOutcome | P6 | Y12 | P5/P6 | assumed | assumed | assumedOutcome = true |
| DG-6.3 | testOutcome | P6 | Y13-Y14 | P6 | assumed | assumed | assumedOutcome = true |
| DG-6.4 | exogenous | P6 | Y12 | P5/P6 | declared | declared | exogenous: no parameter carries the year |
| DG-7.1 | derivable | P7 | Y20 | P7 | SPA REO >= 0.4 t/yr (DART sites/ppm assumed): Y25 (P7/P8) | consistent | ECON reo_target >= 0.4 (max 2.5e+06; Y200 2.5e+06) |
| DG-7.2 | derivable | P7 | Y20 | P7 | first SPA processing output (reo_target > 0): Y19 (P7) | consistent | ECON reo_target first non-zero Y19 |
| DG-7.3 | testOutcome | P7 | Y20 | P7 | assumed | assumed | assumedOutcome = true |
| DG-7.4 | derivable | P7 | Y22 | P7 | in-situ reagent fraction >= 0.5: Y26 (P8) | later than declared | ECON reagent.isru_frac(y) = min(0.98, max(0, (y-9) x 0.03)) |
| DG-7.5 | testOutcome | P7 | Y15 | P6 | assumed | assumed | assumedOutcome = true; declared year Y15 is P6 by the year table |
| DG-8.0 | exogenous | P8 | Y25 | P7/P8 | declared | declared | exogenous: no parameter carries the year |
| DG-8.1 | exogenous | P8 | Y25 | P7/P8 | declared | declared | exogenous: no parameter carries the year |
| DG-8.2 | derivable | P8 | Y27 | P8 | circuits >= 100: Y28 (P8) | consistent | ECON circuits_needed >= 100 (max 2.083e+06; Y200 2.083e+06) |
| DG-8.3 | exogenous | P8 | Y25 | P7/P8 | declared | declared | exogenous: no parameter carries the year |
| DG-8.4 | derivable | P8 | Y26 | P8 | haulers >= 50: Y28 (P8) | consistent | ECON haulers_needed >= 50 (max 1.5e+06; Y200 1.5e+06) |
| DG-8.5 | derivable | P8 | Y28 | P8 | REO >= 125 t/yr: Y28 (P8); circuits >= 308 (batch-design count): Y41 (P9) | consistent | ECON reo_target >= 125 (max 2.5e+06; Y200 2.5e+06) / ECON circuits_needed >= 308 (max 2.083e+06; Y200 2.083e+06) |
| DG-8.6 | exogenous | P8 | Y28 | P8 | declared | declared | exogenous: no parameter carries the year |
| DG-8.7 | derivable | P8 | Y30 | P8 | Th(OH)4 stockpile >= 40 t: Y37 (P9) | later than declared | plan_vectors.thorium_stockpile: ratio 0.0297 t/t nominal (12.5 ppm Th, 0.92 capture); range Y36-Y39 (ratios 0.0369-0.0233) |
| DG-8.8 | exogenous | P8 (alt P7) | Y30 | P8 | declared | declared | exogenous: no parameter carries the year |
| DG-8.9 | exogenous | P8 | Y32 | P8 | declared | declared | exogenous: no parameter carries the year |
| DG-8.X | testOutcome | P8 | Y28 | P8 | assumed | assumed | assumedOutcome = true |
| DG-9.1 | exogenous | P9 | Y35 | P8/P9 | declared | declared | exogenous: no parameter carries the year |
| DG-9.2 | derivable | P9 | Y38 | P9 | haulers >= 1,000: Y44 (P9) | consistent | ECON haulers_needed >= 1,000 (max 1.5e+06; Y200 1.5e+06) |
| DG-9.3 | testOutcome | P9 | Y40 | P9 | assumed | assumed | assumedOutcome = true |
| DG-9.4 | derivable | P9 | Y42 | P9 | in-situ manufactured mass >= 100 t/yr (foundry proxy): Y28 (P8) | earlier than declared | ECON insitu_total >= 100 (max 1.685e+06; Y200 0) |
| DG-9.5 | exogenous | P9 | Y42 | P9 | declared | declared | exogenous: no parameter carries the year |
| DG-9.6 | exogenous | P9 (alt P10) | Y43 | P9 | declared | declared | exogenous: no parameter carries the year |
| DG-9.7 | derivable | P9 | Y40 | P9 | conveyor >= 500 km: Y66 (P11) | later than declared | ECON conv_km_needed >= 500 (max 1.375e+05; Y200 1.375e+05) |
| DG-10.1 | derivable | P10 | Y45 | P9/P10 | haulers >= 14,881: Y64 (P11) | later than declared | ECON haulers_needed >= 1.488e+04 (max 1.5e+06; Y200 1.5e+06) |
| DG-10.2 | derivable | P10 | Y48 | P10 | conveyor >= 5,000 km: Y84 (P12) | later than declared | ECON conv_km_needed >= 5,000 (max 1.375e+05; Y200 1.375e+05) |
| DG-10.3 | derivable | P10 | Y45 | P9/P10 | in-situ manufactured mass >= 1,000 t/yr (foundry proxy): Y41 (P9) | earlier than declared | ECON insitu_total >= 1,000 (max 1.685e+06; Y200 0) |
| DG-10.4 | derivable | P10 | Y50 | P10 | MSR units >= 74: Y67 (P11); FSP field superseded: MSR installed power >= FSP installed power: Y36 (P9) | later than declared | ECON msr_count >= 74 (max 8,334; Y200 8,334) / ECON msr_count x 100 MWe vs fsp_count x 40 kWe; ECON caps fsp_count at 20 units from Y45 (its own FSP phase-out) |
| DG-10.5 | derivable | P10 | Y50 | P10 | SPA MSR unit #1: non-nuclear cargo dearer than an MSR, with ThCl4 available: Y105 (P12) | later than declared | plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 1 at Y105 |
| DG-11.1 | derivable | P11 | Y60 | P10/P11 | REO >= 100,000 t/yr: Y80 (P11/P12); supply fraction >= 10%: Y101 (P12) | consistent | ECON reo_target >= 1e+05 (max 2.5e+06; Y200 2.5e+06) / ECON supply_frac >= 0.1 (max 1; Y200 1) |
| DG-11.2 | derivable | P11 | Y65 | P11 | MSR units >= 679: Y96 (P12) | later than declared | ECON msr_count >= 679 (max 8,334; Y200 8,334) |
| DG-11.3 | derivable | P11 | Y70 | P11 | SPA MSR unit #1: non-nuclear cargo dearer than an MSR, with ThCl4 available: Y105 (P12) | later than declared | plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 1 at Y105 |
| DG-11.4 | testOutcome | P11 | Y75 | P11 | assumed | assumed | assumedOutcome = true |
| DG-11.5 | derivable | P11 | - | - | conveyor >= 15,000 km: Y103 (P12) | later than declared | ECON conv_km_needed >= 1.5e+04 (max 1.375e+05; Y200 1.375e+05) |
| DG-11.6 | derivable | P11 | Y65-Y75 | P11 | Mk III forced: chemical MOLE-I need > PSR capacity (620): never; MD-4 trigger: PGM concentrate > 100 t/yr: never | never met on current vectors | ECON molei_needed peak 357 at Y35; with the fleet v9 figure 310 the need exceeds capacity at Y31 (sensitivity only, W2-N18) / ECON total_pgm > 100 (max 52.02; Y200 39.65) |
| DG-11.7 | exogenous | P11 | - | - | declared | declared | exogenous: no parameter carries the year |
| DG-11.8 | exogenous | P11 | Y75 | P11 | Y75 (P11) | consistent | derivedYear = parameters.mTypeCaptureYear |
| DG-12.1 | derivable | P12 | Y80 | P11/P12 | REO >= 500,000 t/yr: Y121 (P13); supply fraction >= 40%: Y141 (P14) | later than declared | ECON reo_target >= 5e+05 (max 2.5e+06; Y200 2.5e+06) / ECON supply_frac >= 0.4 (max 1; Y200 1) |
| DG-12.2 | derivable | P12 | Y85 | P12 | MSR units >= 6,890: Y173 (P14) | later than declared | ECON msr_count >= 6,890 (max 8,334; Y200 8,334) |
| DG-12.3 | derivable | P12 | Y85 | P12 | MD-2 cadence >= 783/day: Y141 (P14) | later than declared | ECON canisters_yr / 365 (3.5 t per canister; Y200 1,957/day; ECN-020 corrected the 2.5 Mt/yr cadence to ~1,903/day) |
| DG-12.4 | exogenous | P12 | Y85 | P12 | Y85 (P12) | consistent | derivedYear = parameters.mTypeCaptureYear + parameters.asteroidOnlineLagYears |
| DG-12.5 | exogenous | P12 | Y85 | P12 | Y85 (P12) | consistent | derivedYear = parameters.mTypeCaptureYear + parameters.asteroidOnlineLagYears |
| DG-12.6 | derivable | P12 | Y90 | P12 | captured-asteroid PGM >= 36.5 t/yr: Y85 (P12) | consistent | ECON captured_asteroid_pgm >= 36.5 (max 36.5; Y200 36.5) |
| DG-12.7 | exogenous | P12 | Y95 | P12 | declared | declared | exogenous: no parameter carries the year |
| DG-13.1 | derivable | P13 | Y120 | P12/P13 | REO >= 1,250,000 t/yr: Y152 (P14); supply fraction >= 50%: Y152 (P14) | later than declared | ECON reo_target >= 1.25e+06 (max 2.5e+06; Y200 2.5e+06) / ECON supply_frac >= 0.5 (max 1; Y200 1) |
| DG-13.2 | exogenous | P13 (alt P12) | Y95 | P12 | Y95 (P12) | consistent | derivedYear = parameters.cTypeCaptureYear |
| DG-14.1 | exogenous | P13 (alt P14) | Y95 | P12 | Y95 (P12) | earlier than declared | derivedYear = parameters.cTypeCaptureYear; declared year Y95 is P12 by the year table |
| DG-13.3 | exogenous | P13 (alt P12) | Y105 | P12 | Y105 (P12) | consistent | derivedYear = parameters.cTypeCaptureYear + parameters.asteroidOnlineLagYears |
| DG-13.4 | derivable | P13 (alt P12) | Y105 | P12 | SPA MSR unit #1: non-nuclear cargo dearer than an MSR, with ThCl4 available: Y105 (P12) | consistent | plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 1 at Y105 |
| DG-13.5 | derivable | P13 | Y110 | P12 | circuit Earth fraction <= 3%: Y115 (P12) | earlier than declared | declared year Y110 is P12 by the year table; ECON cargo_circuits / (d_circuits x circuit.mass_kg), years with new circuits only |
| DG-13.6 | exogenous | P13 | Y115 | P12 | Y115 (P12) | earlier than declared | derivedYear = parameters.sTypeCaptureYear; declared year Y115 is P12 by the year table |
| DG-13.7 | derivable | P13 | Y120 | P12/P13 | hauler Earth fraction <= 20%: never | never met on current vectors | ECON hauler Earth fraction floors at 0.33 (hauler.earth_frac 0.43 floor less the M-type bonus); never reaches 0.20 |
| DG-14.2 | exogenous | P14 (alt P13) | Y115 | P12 | Y115 (P12) | earlier than declared | derivedYear = parameters.sTypeCaptureYear; declared year Y115 is P12 by the year table |
| DG-14.3 | exogenous | P14 (alt P13) | Y125 | P13 | Y125 (P13) | consistent | derivedYear = parameters.sTypeCaptureYear + parameters.asteroidOnlineLagYears |
| DG-14.4 | derivable | P14 (alt P13) | Y125 | P13 | SPA MSR unit #2: non-nuclear cargo dearer than an MSR, with ThCl4 available: Y105 (P12) | earlier than declared | plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 2 at Y125 |
| DG-14.5 | derivable | P14 | Y130 | P13 | circuit Earth fraction <= 0.8%: Y135 (P13) | earlier than declared | declared year Y130 is P13 by the year table; ECON cargo_circuits / (d_circuits x circuit.mass_kg) |
| DG-14.6 | derivable | P14 | Y140 | P13/P14 | Earth-supplied mass < 0.5% of infrastructure mass flow: never | never met on current vectors | annual-flow proxy earth_cargo / (earth_cargo + insitu_total): minimum 4.8% at Y139 |
| DG-14.7 | derivable | P14 | Y140 | P13/P14 | SPA MSR unit #3: non-nuclear cargo dearer than an MSR, with ThCl4 available: Y105 (P12) | earlier than declared | plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 3 at Y140 |
| DG-14.8 | derivable | P14 (alt P14plus) | Y180 | P14/P14plus | REO >= 2,500,000 t/yr: Y180 (P14/P14plus) | consistent | ECON reo_target reaches the target at Y180; ProgrammeParameters.steadyStateYear = 180 |
| DG-14.9 | derivable | P14 | Y115 | P12 | Mk III active <= 300 with all captures complete: Y125 (P13) | earlier than declared | declared year Y115 is P12 by the year table; ECON mkiii_active falls to 300 at Y115; captures complete at Y125 (sTypeCaptureYear + lag) |
| DG-POST.1 | derivable | P14plus | Y280 | P14plus | Tier 1 approaching depletion: unevaluated | unevaluated | tier1ResourceTonnes unbound; ECON stops at Y200 (Wave 5) |
| DG-POST.2 | derivable | P14plus | Y380 | P14plus | Tier 2 approaching depletion: unevaluated | unevaluated | tier2ResourceTonnes unbound (Wave 5) |

## 2. Element register (configuration bindings)

| Element.attribute | Type | Definition value | Bound to | Gate derived | Vector-derived | Verdict |
|---|---|---|---|---|---|---|
| earth.probeScout.introducedIn | ProbeScout | P1 | DG-1.1 (P1, Y2) | assumed | - | def = gate |
| earth.starshipCargo.introducedIn | StarshipCargoLink | P1 | DG-1.1 (P1, Y2) | assumed | - | def = gate |
| earth.starshipCargo.operationalFrom | StarshipCargoLink | P1 | DG-1.1 (P1, Y2) | assumed | - | def = gate |
| earth.starshipCargo.pktDeliveriesFrom | StarshipCargoLink | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktRelay.existsFrom | PktRelaySatellite | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| shackletonHub.existsFrom | CrewedHub | P1 | DG-1.1 (P1, Y2) | assumed | - | def = gate |
| shackletonHub.crewedFrom | CrewedHub | P4 | DG-4.1 (P4, Y7) | assumed | P4 - VERIFY ph.crew = [0, 4, 4, 6, 12] | def = gate; vector = def |
| shackletonHub.opsHubFrom | CrewedHub | P4 | DG-4.1 (P4, Y7) | assumed | - | def = gate |
| shackletonHub.habComplex.crewedFrom | HabitatComplex | P4 | DG-4.1 (P4, Y7) | assumed | P4 - VERIFY ph.crew | def = gate; vector = def |
| shackletonHub.lifeSupport.introducedIn | Eclss | P4 | DG-4.2 (P4, Y7) | assumed | P4 - VERIFY ph.p_hab (habitat power) first non-zero | def = gate; vector = def |
| shackletonHub.isru.selfSufficientFrom | IsruPlant | P4 | DG-4.3 (P4, Y8) | P3 (P3) | P3 - VERIFY ph.isru >= ph.dT | def = gate; vector P3 vs def P4 |
| shackletonHub.industrialZone.beneficiation.introducedIn | BeneficiationPlant | P5 | DG-5.2 (P5, Y10) | declared | - | def = gate |
| shackletonHub.industrialZone.emCatcher.introducedIn | EmCatcher | P11 | DG-9.6 (P9, alt P10, Y43) | declared | - | def P11 vs gate P9/P10 |
| shackletonHub.industrialZone.emCatcher.operationalFrom | EmCatcher | P11 | DG-9.6 (P9, alt P10, Y43) | declared | - | def P11 vs gate P9/P10 |
| shackletonHub.crewReturnVehicle.introducedIn | CrewReturnVehicle | P4 | DG-4.1 (P4, Y7) | assumed | - | def = gate |
| shackletonHub.powerZone.spaMsr.introducedIn | SpaThoriumMSR | unbound | DG-10.5 (P10, Y50) | Y105 (P12) | Y105 (P12) - ECON spa_msr_count first non-zero (the economics' assumption, F5) | def unbound -> gate; vector P12 vs def None |
| shackletonHub.mTypeLine.introducedIn | MTypeProcessingLine | P12 | DG-12.4 (P12, Y85) | Y85 (P12) | Y85 (P12) - ECON captured_asteroid_pgm first non-zero | def = gate; vector = def |
| shackletonHub.cTypeLine.introducedIn | CTypeProcessingLine | P12 | DG-13.3 (P13, alt P12, Y105) | Y105 (P12) | - | def = gate |
| shackletonHub.sTypeLine.introducedIn | STypeProcessingLine | P13 | DG-14.3 (P14, alt P13, Y125) | Y125 (P13) | - | def = gate |
| shackletonHub.probeMkI.isruFuelledFrom | ProbeMkI | P4 | DG-4.3 (P4, Y8) | P3 (P3) | P3 - VERIFY ph.isru >= ph.dP (the P3 units are Earth-fuelled by policy) | def = gate; vector P3 vs def P4 |
| shackletonHub.probeMkI.retiredIn | ProbeMkI | P11 | DG-11.6 (P11, Y65) | never | - | def = gate |
| shackletonHub.probeMkIII.introducedIn | ProbeMkIII | P11 | DG-11.6 (P11, Y65) | never | Y61 (P11) - ECON mkiii_active first non-zero | def = gate; vector = def |
| shackletonHub.probeMkIII.prospectingRoleFrom | ProbeMkIII | P13 | DG-14.9 (P14, Y115) | Y125 (P13) | Y115 (P12) - ECON mkiii_active falls to the 300-unit prospecting fleet | def P13 vs gate P14; vector P12 vs def P13 |
| shackletonHub.survey.introducedIn | Survey | P1 | DG-1.1 (P1, Y2) | assumed | - | def = gate |
| shackletonHub.sinter.pktFrom | Sinter | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| shackletonHub.armC.pktFrom | ArmC | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| shackletonHub.sentinelRover.pktFrom | SentinelRover | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| shackletonHub.skip.introducedIn | Skip | P4 | DG-2.2 (P2, Y5) | assumed | P4 - VERIFY ph.nS = [0, 1, 2, 4, 8] | def P4 vs gate P2; vector = def |
| shackletonHub.skip.retiredIn | Skip | P9 | massDriverNetwork.md2.operationalFrom | - | Y45 (P9/P10) - ECON skip_active ramps 8 -> 0 over Y36-Y45 | vector = def |
| shackletonHub.dart.introducedIn | Dart | P5 | DG-5.1 (P5, Y9) | P5 (P5) | P5 - VERIFY ph.nD = [0, 0, 1, 1, 1] | def = gate; vector = def |
| shackletonHub.dart.pktSiteConfirmationIn | Dart | P7 | DG-6.3 (P6, Y13) | assumed | - | def P7 vs gate P6 |
| shackletonHub.dart.pktBasedFrom | Dart | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| shackletonHub.cap.introducedIn | Cap | P4 | DG-4.1 (P4, Y7) | assumed | P6 - VERIFY ph.p_cap (CAP standby power) = [0.0, 0.0, 0.0, 1.0, 1.0] | def = gate; vector P6 vs def P4 |
| shackletonHub.skipHops.introducedIn | SkipHopLink | P4 | DG-2.2 (P2, Y5) | assumed | P4 - VERIFY ph.nS (SKIP count) | def P4 vs gate P2; vector = def |
| shackletonHub.skipHops.operationalFrom | SkipHopLink | P4 | DG-2.2 (P2, Y5) | assumed | - | def P4 vs gate P2 |
| shackletonHub.skipHops.retiredIn | SkipHopLink | P9 | massDriverNetwork.md2.operationalFrom | - | Y45 (P9/P10) - ECON skip_active reaches zero | vector = def |
| shackletonHub.starshipReturn.introducedIn | StarshipReturnLink | P5 | DG-5.4 (P5, Y10) | declared | - | def = gate |
| shackletonHub.starshipReturn.operationalFrom | StarshipReturnLink | P5 | DG-5.4 (P5, Y10) | declared | - | def = gate |
| shackletonHub.starshipReturn.retiredIn | StarshipReturnLink | unbound | massDriverNetwork.md4.operationalFrom | - | - | - |
| shackletonHub.probeReturns.mkIiiCanisterStreamFrom | ProbeReturnLink | P11 | DG-11.6 (P11, Y65) | never | - | def = gate |
| shackletonPsrFloor.contingencyCrewAccessFrom | PsrFloor | P4 | DG-4.1 (P4, Y7) | assumed | - | def = gate |
| shackletonPsrFloor.psrNetwork.crewWinch.introducedIn | CrewWinch | P4 | DG-4.1 (P4, Y7) | assumed | - | def = gate |
| shackletonPsrFloor.psrNetwork.capGuideCable.introducedIn | CapGuideCable | P4 | DG-4.1 (P4, Y7) | assumed | - | def = gate |
| shackletonPsrFloor.moleIMkII.declineDrivenByMkIIIFrom | MoleIMkII | P11 | DG-11.6 (P11, Y65) | never | - | def = gate |
| pktFactory.existsFrom | AutonomousFactory | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.siteConfirmedIn | AutonomousFactory | P7 | DG-6.3 (P6, Y13) | assumed | - | def P7 vs gate P6 |
| pktFactory.temporaryCrewOnlyIn | AutonomousFactory | P8 | DG-8.6 (P8, Y28) | declared | - | def = gate |
| pktFactory.processingSpine.introducedIn | PktProcessingSpine | P8 | DG-8.1 (P8, Y25) | declared | Y28 (P8) - ECON circuits_needed >= 100 (first PKT tranche, DG-8.2) | def = gate; vector = def |
| pktFactory.reagentPlant.introducedIn | ReagentPlant | P8 | DG-8.3 (P8, Y25) | declared | - | def = gate |
| pktFactory.foundry.introducedIn | Foundry | P8 | DG-8.6 (P8, Y28) | declared | Y26 (P8) - ECON insitu_total first non-zero (in-situ manufacture) | def = gate; vector = def |
| pktFactory.foundry.atScaleFrom | Foundry | P9 | DG-9.4 (P9, Y42) | Y28 (P8) | - | def = gate |
| pktFactory.relayDepot.introducedIn | RelayDepot | unbound | DG-POST.1 (P14plus, Y280) | None | - | def unbound -> gate |
| pktFactory.powerSystem.introducedIn | PktPowerSystem | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.powerSystem.fspField.introducedIn | PktFspField | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.powerSystem.fspField.retiredIn | PktFspField | P10 | DG-10.4 (P10, Y50) | Y67 (P11) | Y45 (P9/P10) - ECON fsp_count reaches its 20-unit floor (FSP phase-out complete) | def = gate; vector = def |
| pktFactory.powerSystem.referenceMsr.introducedIn | ThoriumMSR | P9 | DG-9.3 (P9, Y40) | assumed | Y36 (P9) - ECON msr_count first non-zero | def = gate; vector = def |
| pktFactory.powerSystem.referenceMsr.replacesPktFspFrom | ThoriumMSR | P10 | DG-10.4 (P10, Y50) | Y67 (P11) | - | def = gate |
| pktFactory.powerSystem.referenceMsr.inSituVesselsFrom | ThoriumMSR | P11 | DG-11.4 (P11, Y75) | assumed | - | def = gate |
| pktFactory.powerSystem.referenceHubStation.introducedIn | HubChargingStation | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.temporaryCrewHab.introducedIn | PktTemporaryCrewHab | P8 | DG-8.6 (P8, Y28) | declared | - | def = gate |
| pktFactory.temporaryCrewHab.retiredIn | PktTemporaryCrewHab | P8 | introducedIn | - | - | - |
| pktFactory.landingZone.introducedIn | PktLandingZone | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.conveyorNetwork.introducedIn | ConveyorNetwork | P9 | DG-9.7 (P9, Y40) | Y66 (P11) | Y41 (P9) - ECON conv_km_needed first non-zero | def = gate; vector = def |
| pktFactory.conveyorNetwork.deployingFrom | ConveyorNetwork | P10 | DG-10.2 (P10, Y48) | Y84 (P12) | - | def = gate |
| pktFactory.conveyorNetwork.referenceTrunk.introducedIn | SteelApronConveyor | P9 | DG-9.7 (P9, Y40) | Y66 (P11) | - | def = gate |
| pktFactory.conveyorNetwork.referenceTrunk.operationalFrom | SteelApronConveyor | P9 | DG-9.7 (P9, Y40) | Y66 (P11) | - | def = gate |
| pktFactory.conveyorNetwork.referenceBranch.introducedIn | SteelApronConveyor | P9 | DG-9.7 (P9, Y40) | Y66 (P11) | - | def = gate |
| pktFactory.conveyorNetwork.referenceBranch.operationalFrom | SteelApronConveyor | P9 | DG-9.7 (P9, Y40) | Y66 (P11) | - | def = gate |
| pktFactory.roadNetwork.introducedIn | HaulerRoadNetwork | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.roadNetwork.operationalFrom | HaulerRoadNetwork | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| pktFactory.hauler.introducedIn | HaulerRevB | P8 | DG-8.1 (P8, Y25) | declared | Y27 (P8) - ECON haulers_needed >= 10 (Wave 1 Pioneer count; ECON assigns haulers to SPA research output from Y20, W3-N8) | def = gate; vector = def |
| droStation.existsFrom | DroStation | P12 | DG-12.4 (P12, Y85) | Y85 (P12) | Y85 (P12) - ECON captured_asteroid_pgm first non-zero | def = gate; vector = def |
| droStation.laserAblationTruss.introducedIn | LaserAblationTruss | P12 | DG-12.4 (P12, Y85) | Y85 (P12) | Y85 (P12) - ECON captured_asteroid_pgm first non-zero | def = gate; vector = def |
| droStation.redirectTug.introducedIn | RedirectTug | P11 | DG-11.8 (P11, Y75) | Y75 (P11) | Y65 (P11) - ECON tug_fleet first non-zero (build precedes the Y75 redirect) | def = gate; vector = def |
| droStation.redirectTug.firstCaptureIn | RedirectTug | P11 | DG-11.8 (P11, Y75) | Y75 (P11) | - | def = gate |
| massDriverNetwork.introducedIn | MassDriverNetwork | P8 | DG-8.0 (P8, Y25) | declared | - | def = gate |
| massDriverNetwork.md1.introducedIn | MassDriverMd1 | P8 | DG-8.0 (P8, Y25) | declared | - | def = gate |
| massDriverNetwork.md1.operationalFrom | MassDriverMd1 | P8 | DG-8.0 (P8, Y25) | declared | - | def = gate |
| massDriverNetwork.md2.introducedIn | MassDriverMd2 | P9 | DG-9.1 (P9, Y35) | declared | - | def = gate |
| massDriverNetwork.md2.operationalFrom | MassDriverMd2 | P9 | DG-9.1 (P9, Y35) | declared | Y35 (P8/P9) - ECON canisters_yr first non-zero | def = gate; vector = def |
| massDriverNetwork.md3.introducedIn | MassDriverMd3 | P10 | DG-9.6 (P9, alt P10, Y43) | declared | - | def = gate |
| massDriverNetwork.md3.operationalFrom | MassDriverMd3 | P10 | DG-9.6 (P9, alt P10, Y43) | declared | - | def = gate |
| massDriverNetwork.md4.introducedIn | MassDriverMd4 | P11 | DG-12.4 (P12, Y85) | Y85 (P12) | - | def P11 vs gate P12 |
| massDriverNetwork.md4.operationalFrom | MassDriverMd4 | P11 | DG-12.4 (P12, Y85) | Y85 (P12) | - | def P11 vs gate P12 |
| massDriverNetwork.md5.introducedIn | MassDriverMd5 | P12 | DG-12.5 (P12, Y85) | Y85 (P12) | - | def = gate |
| massDriverNetwork.md5.operationalFrom | MassDriverMd5 | P12 | DG-12.5 (P12, Y85) | Y85 (P12) | - | def = gate |
| sentinelSystem.edge.supervisedFromSpaFrom | SentinelEdgeTier | P4 | DG-4.1 (P4, Y7) | assumed | - | def = gate |
| sentinelSystem.edge.pktSupervisedFromSpaFrom | SentinelEdgeTier | P8 | DG-8.1 (P8, Y25) | declared | - | def = gate |
| sentinelSystem.o2SupplyMonitoring.introducedIn | O2SupplyLineMonitoringFunction | P4 | DG-4.2 (P4, Y7) | assumed | - | def = gate |

## 3. Discrepancy register (W2-N table format)

| # | Observation | Where |
|---|---|---|
| W3-R1 | DG-4.3 PROBE fleet fully ISRU-fuelled: declared Y8 (P4); derived P3 - VERIFY ph.isru [28460, 170760, 313060, 512280, 1024560] vs ph.dP [19962, 39924, 66540, 99810, 199620] (P3..P7) | Gates.sysml / econ.py |
| W3-R2 | DG-7.4 Progressive reagent substitution at SPA (10% -> 50% in-situ H2SO4, Ca(...: declared Y22 (P7); derived Y26 (P8) - ECON reagent.isru_frac(y) = min(0.98, max(0, (y-9) x 0.03)) | Gates.sysml / econ.py |
| W3-R3 | DG-7.5: listed under P7 but its year Y15 is P6 | Gates.sysml / Phases.sysml |
| W3-R4 | DG-8.5: its criteria split - REO >= 125 t/yr -> Y28; circuits >= 308 (batch-design count) -> Y41 | Gates.sysml / econ.py |
| W3-R5 | DG-8.7 Thorium stockpile assessment (~40 t Th(OH)4 accumulated): declared Y30 (P8); derived Y37 (P9) - plan_vectors.thorium_stockpile: ratio 0.0297 t/t nominal (12.5 ppm Th, 0.92 capture); range Y36-Y39 (ratios 0.0369-0.0233) | Gates.sysml / econ.py |
| W3-R6 | DG-9.4 PKT foundry at 100+ t/yr metal production (MRE + WAAM/EB welding): declared Y42 (P9); derived Y28 (P8) - ECON insitu_total >= 100 (max 1.685e+06; Y200 0) | Gates.sysml / econ.py |
| W3-R7 | DG-9.7 Steel conveyor pilot - first 500 km trunk from Fe-Ni + MRE iron: declared Y40 (P9); derived Y66 (P11) - ECON conv_km_needed >= 500 (max 1.375e+05; Y200 1.375e+05) | Gates.sysml / econ.py |
| W3-R8 | DG-10.1 Hauler fleet at scale - 14,881 mining-capable haulers (Na-S battery, S...: declared Y45 (P10); derived Y64 (P11) - ECON haulers_needed >= 1.488e+04 (max 1.5e+06; Y200 1.5e+06) | Gates.sysml / econ.py |
| W3-R9 | DG-10.2 Steel conveyor network expanding - 5,000+ km, replacing hauler Tier 3...: declared Y48 (P10); derived Y84 (P12) - ECON conv_km_needed >= 5,000 (max 1.375e+05; Y200 1.375e+05) | Gates.sysml / econ.py |
| W3-R10 | DG-10.3 PKT foundry at industrial scale - MRE cells, WAAM/EB welding, Fe-Si an...: declared Y45 (P10); derived Y41 (P9) - ECON insitu_total >= 1,000 (max 1.685e+06; Y200 0) | Gates.sysml / econ.py |
| W3-R11 | DG-10.4 Thorium MSR fleet expansion - ~74 x 100 MWe units at PKT. Construction...: declared Y50 (P10); derived Y67 (P11) - ECON msr_count >= 74 (max 8,334; Y200 8,334) | Gates.sysml / econ.py |
| W3-R12 | DG-10.4: its criteria split - MSR units >= 74 -> Y67; FSP field superseded: MSR installed power >= FSP installed power -> Y36 | Gates.sysml / econ.py |
| W3-R13 | DG-10.5 SPA MSR commissioning - ThCl4 mass-driven from PKT. Enables scaled PRO...: declared Y50 (P10); derived Y105 (P12) - plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 1 at Y105 | Gates.sysml / econ.py |
| W3-R14 | DG-11.1: its criteria split - REO >= 100,000 t/yr -> Y80; supply fraction >= 10% -> Y101 | Gates.sysml / econ.py |
| W3-R15 | DG-11.2 Thorium MSR fleet at ~679 x 100 MWe. Annual Th consumption ~54 t/yr vs...: declared Y65 (P11); derived Y96 (P12) - ECON msr_count >= 679 (max 8,334; Y200 8,334) | Gates.sysml / econ.py |
| W3-R16 | DG-11.3 SPA MSR commissioning - ThCl4 mass-driven from PKT. Enables scaled PGM...: declared Y70 (P11); derived Y105 (P12) - plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 1 at Y105 | Gates.sysml / econ.py |
| W3-R17 | DG-11.5 Conveyor network scales to ~15,000 km: declared - (P11); derived Y103 (P12) - ECON conv_km_needed >= 1.5e+04 (max 1.375e+05; Y200 1.375e+05) | Gates.sysml / econ.py |
| W3-R18 | DG-11.6 PROBE Mk III SEP commissioning + SPA->Earth mass driver for PGM export...: declared Y65 (P11); derived never - ECON molei_needed peak 357 at Y35; with the fleet v9 figure 310 the need exceeds capacity at Y31 (sensitivity only, W2-N18) | Gates.sysml / econ.py |
| W3-R19 | DG-12.1 500,000 t/yr REO -> 40% global displacement (revised from 1,000,000 at...: declared Y80 (P12); derived Y121 (P13) - ECON reo_target >= 5e+05 (max 2.5e+06; Y200 2.5e+06) | Gates.sysml / econ.py |
| W3-R20 | DG-12.1: its criteria split - REO >= 500,000 t/yr -> Y121; supply fraction >= 40% -> Y141 | Gates.sysml / econ.py |
| W3-R21 | DG-12.2 Thorium MSR fleet at ~6,890 x 100 MWe (689 GW) at PKT full-scale: declared Y85 (P12); derived Y173 (P14) - ECON msr_count >= 6,890 (max 8,334; Y200 8,334) | Gates.sysml / econ.py |
| W3-R22 | DG-12.3 PKT->Earth mass driver: scaling toward 783/day at P14+ steady state: declared Y85 (P12); derived Y141 (P14) - ECON canisters_yr / 365 (3.5 t per canister; Y200 1,957/day; ECN-020 corrected the 2.5 Mt/yr cadence to ~1,903/day) | Gates.sysml / econ.py |
| W3-R23 | DG-13.1 1,250,000 t/yr REO - 50% of projected global demand. P13 milestone, no...: declared Y120 (P13); derived Y152 (P14) - ECON reo_target >= 1.25e+06 (max 2.5e+06; Y200 2.5e+06) | Gates.sysml / econ.py |
| W3-R24 | DG-14.1 C-type asteroid targeting decision gate - selects target optimising fo...: declared Y95 (P13/P14); derived Y95 (P12) - derivedYear = parameters.cTypeCaptureYear; declared year Y95 is P12 by the year table | Gates.sysml / Parameters.sysml |
| W3-R25 | DG-14.1: listed under P13 (alt P14) but its year Y95 is P12 | Gates.sysml / Phases.sysml |
| W3-R26 | DG-13.5 Circuit Earth fraction drops from 10% to 3% - C-type carbon replaces P...: declared Y110 (P13); derived Y115 (P12) - ECON cargo_circuits / (d_circuits x circuit.mass_kg), years with new circuits only | Gates.sysml / econ.py |
| W3-R27 | DG-13.5: listed under P13 but its year Y110 is P12 | Gates.sysml / Phases.sysml |
| W3-R28 | DG-13.6 S-type asteroid redirect initiated - ~100 m silicaceous body. Fleet no...: declared Y115 (P13); derived Y115 (P12) - derivedYear = parameters.sTypeCaptureYear; declared year Y115 is P12 by the year table | Gates.sysml / Parameters.sysml |
| W3-R29 | DG-13.6: listed under P13 but its year Y115 is P12 | Gates.sysml / Phases.sysml |
| W3-R30 | DG-13.7 M-type Fe-Ni reduces hauler Earth fraction from 43% to 20% floor (avio...: declared Y120 (P13); derived never - ECON hauler Earth fraction floors at 0.33 (hauler.earth_frac 0.43 floor less the M-type bonus); never reaches 0.20 | Gates.sysml / econ.py |
| W3-R31 | DG-14.2 S-type asteroid targeting decision gate - selects target optimising fo...: declared Y115 (P14/P13); derived Y115 (P12) - derivedYear = parameters.sTypeCaptureYear; declared year Y115 is P12 by the year table | Gates.sysml / Parameters.sysml |
| W3-R32 | DG-14.2: listed under P14 (alt P13) but its year Y115 is P12 | Gates.sysml / Phases.sysml |
| W3-R33 | DG-14.4 SPA MSR #2 commissioned - 100 MWe for S-type Si refinery power.: declared Y125 (P14/P13); derived Y105 (P12) - plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 2 at Y125 | Gates.sysml / econ.py |
| W3-R34 | DG-14.5 Circuit Earth fraction drops from 3% to 0.8% - only advanced ICs remai...: declared Y130 (P14); derived Y135 (P13) - ECON cargo_circuits / (d_circuits x circuit.mass_kg) | Gates.sysml / econ.py |
| W3-R35 | DG-14.5: listed under P14 but its year Y130 is P13 | Gates.sysml / Phases.sysml |
| W3-R36 | DG-14.6 Earth independence assessment (DG-14.3 from ECN-019) - comprehensive a...: declared Y140 (P14); derived never - annual-flow proxy earth_cargo / (earth_cargo + insitu_total): minimum 4.8% at Y139 | Gates.sysml / econ.py |
| W3-R37 | DG-14.7 SPA MSR #3 commissioned - scaled operations, full asteroid processing...: declared Y140 (P14); derived Y105 (P12) - plan_vectors.fsp_msr_trade, incremental basis (cargo beyond the P7 as-built fleet; FSP Earth->SPA, solar Earth->SPA, MSR Earth fraction Earth->SPA, in-situ fraction PKT->SPA via MD-3): non-nuclear cargo exceeds the MSR's Earth cargo from Y105, ThCl4 from MD-3 Y43; with a-Si solar in-situ from Y60 -> Y105; as-built basis (all cargo for the year's demand, delivered hardware not sunk) -> Y43; eclipse-critical load 132-146 kW, 4 FSP max; ECON spa_msr_count reaches 3 at Y140 | Gates.sysml / econ.py |
| W3-R38 | DG-14.9 Mk III PROBE fleet reduction - all 3 asteroid captures complete by Y12...: declared Y115 (P14); derived Y125 (P13) - ECON mkiii_active falls to 300 at Y115; captures complete at Y125 (sTypeCaptureYear + lag) | Gates.sysml / econ.py |
| W3-R39 | DG-14.9: listed under P14 but its year Y115 is P12 | Gates.sysml / Phases.sysml |
| W3-R40 | DG-POST.1: derivable but unevaluated - tier1ResourceTonnes unbound; ECON stops at Y200 (Wave 5) | Gates.sysml / Parameters.sysml |
| W3-R41 | DG-POST.2: derivable but unevaluated - tier2ResourceTonnes unbound (Wave 5) | Gates.sysml / Parameters.sysml |
| W3-R42 | shackletonHub.isru.selfSufficientFrom: definition P4, vector says P3 - VERIFY ph.isru >= ph.dT | ProgrammeConfiguration.sysml / selenite-compute |
| W3-R43 | shackletonHub.industrialZone.emCatcher.introducedIn: definition P11 but bound to DG-9.6 (P9/P10, Y43) | ProgrammeConfiguration.sysml |
| W3-R44 | shackletonHub.industrialZone.emCatcher.operationalFrom: definition P11 but bound to DG-9.6 (P9/P10, Y43) | ProgrammeConfiguration.sysml |
| W3-R45 | shackletonHub.powerZone.spaMsr.introducedIn: definition unbound, vector says Y105 - ECON spa_msr_count first non-zero (the economics' assumption, F5) | ProgrammeConfiguration.sysml / selenite-compute |
| W3-R46 | shackletonHub.probeMkI.isruFuelledFrom: definition P4, vector says P3 - VERIFY ph.isru >= ph.dP (the P3 units are Earth-fuelled by policy) | ProgrammeConfiguration.sysml / selenite-compute |
| W3-R47 | shackletonHub.probeMkIII.prospectingRoleFrom: definition P13 but bound to DG-14.9 (P14, Y115) | ProgrammeConfiguration.sysml |
| W3-R48 | shackletonHub.probeMkIII.prospectingRoleFrom: definition P13, vector says Y115 - ECON mkiii_active falls to the 300-unit prospecting fleet | ProgrammeConfiguration.sysml / selenite-compute |
| W3-R49 | shackletonHub.skip.introducedIn: definition P4 but bound to DG-2.2 (P2, Y5) | ProgrammeConfiguration.sysml |
| W3-R50 | shackletonHub.dart.pktSiteConfirmationIn: definition P7 but bound to DG-6.3 (P6, Y13) | ProgrammeConfiguration.sysml |
| W3-R51 | shackletonHub.cap.introducedIn: definition P4, vector says P6 - VERIFY ph.p_cap (CAP standby power) = [0.0, 0.0, 0.0, 1.0, 1.0] | ProgrammeConfiguration.sysml / selenite-compute |
| W3-R52 | shackletonHub.skipHops.introducedIn: definition P4 but bound to DG-2.2 (P2, Y5) | ProgrammeConfiguration.sysml |
| W3-R53 | shackletonHub.skipHops.operationalFrom: definition P4 but bound to DG-2.2 (P2, Y5) | ProgrammeConfiguration.sysml |
| W3-R54 | pktFactory.siteConfirmedIn: definition P7 but bound to DG-6.3 (P6, Y13) | ProgrammeConfiguration.sysml |
| W3-R55 | massDriverNetwork.md4.introducedIn: definition P11 but bound to DG-12.4 (P12, Y85) | ProgrammeConfiguration.sysml |
| W3-R56 | massDriverNetwork.md4.operationalFrom: definition P11 but bound to DG-12.4 (P12, Y85) | ProgrammeConfiguration.sysml |

## 4. Structural checks

All structural checks passed.
