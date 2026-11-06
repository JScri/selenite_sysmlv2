package SeleniteParameters {
    doc /* Exogenous programme inputs: the small set of declared decisions from
         * which the derived plan (SeleniteGates, Wave 3) and the quantities
         * (Wave 5) follow. Each parameter's doc names its decision owner, its
         * kind and its source (owner | kind | source). A parameter is bound
         * here only when it is a committed decision (ECN-019 Rev C + ECN-020,
         * Decision Framework Rev D, Strategy v3.1) or a value the
         * computational authority settles (rule W2-N18: PSR capacity from
         * psr_layout.py); capacity constraints and vectors that the Python
         * layer supplies stay unbound with a doc. Changing a bound value here
         * is an ECN. Rules 3, 5b and 5c in CLAUDE_SYSML_CONTEXT.md.
         *
         * Wave 3 (15 Sep 2026): completed from SEL-DECISION-001 Rev D and
         * SEL-T1.1-STRATEGY v3.1; GateThresholds added so that every numeric
         * gate criterion is one attribute here and never a literal inside a
         * SeleniteAnalysis calc def. ECN-019 Rev C itself is not in the
         * repository; its committed decisions are cited through Strategy v3.1,
         * which integrates them in its body text. */

    private import ScalarValues::*;
    private import SelenitePhases::*;

    enum def ParameterKind {
        doc /* policy: a programme decision; computationalInput: an input the
             * ECON/VERIFY layer takes as given; capacityConstraint: a physical
             * limit that gates derived from it must respect. */
        policy; computationalInput; capacityConstraint;
    }

    enum def DecisionCriterion {
        doc /* Wave 4A (6 Nov 2026): the default criterion the scenario register
             * leads with (SESSION_BRIEF_wave4_scenarios.md, open question 1).
             * expectedEarthMassWithSlipChance: minimise expected cumulative
             * Earth-launched mass subject to P(no milestone slip) >= the chance
             * threshold, NPV and CVaR reported beside it; expectedNpv: maximise
             * expected NPV with externalities; lexicographicMassThenNpv: mass
             * first, NPV breaks ties. Every criterion is reported side by side
             * by tools/scenario_check.py; the parameter only selects the lead. */
        expectedEarthMassWithSlipChance; expectedNpv; lexicographicMassThenNpv;
    }

    part def ProgrammeParameters {
        doc /* Single instance in SeleniteConfigurations. Values with
             * provenance; unbound attributes are Wave 5 inputs. */

        // ---- Programme target and calendar -------------------------------

        attribute steadyStateReoTonnesPerYear : Real = 2500000.0;
        doc reoDoc /* owner: programme | kind: policy | source: SEL-REQ-001;
             * ECN-019 Rev C committed target (Strategy v3.1 header); ECON v1.3
             * reo vector reaches it (test_invariants.py). Also the DG-14.8
             * threshold. */

        attribute steadyStateYear : Integer = 180;
        doc ssYearDoc /* owner: programme | kind: policy | source:
             * ARCHITECTURE_BASELINE.md s.1 (P14plus from Y180); Decision
             * Framework Rev D DG-14.8 (Y180); final report v4 Fig. 2 "Mission
             * achieved Y180". */

        attribute programmeStartCalendarYear : Integer = 2025;
        doc calendarDoc /* owner: programme | kind: policy | source: Strategy
             * v3.1 header "~Y180 (~2205)" gives Y0 = 2025; Decision Framework
             * Rev D writes DG-7.5 as "~2040", i.e. Y15 (inside the F7 gap).
             * Used only to place calendar-dated gates on the programme-year
             * axis. */

        // ---- Asteroid captures (exogenous years) -------------------------

        attribute mTypeCaptureYear : Integer = 75;
        attribute cTypeCaptureYear : Integer = 95;
        attribute sTypeCaptureYear : Integer = 115;
        doc captureDoc /* owner: programme | kind: computationalInput | source:
             * ECON v1.4 console "Diversified asteroids: M-type (Y75), C-type
             * (Y95), S-type (Y115)"; fleet v9 s.17.3; Decision Framework Rev D
             * DG-11.8 / DG-13.2 / DG-13.6. Online years follow at +10
             * (Y85/Y105/Y125, DG-12.4 / DG-13.3 / DG-14.3) and set the phases
             * of the SPA processing lines (W2-N7). The exogenous gates carry
             * derivedYear bound to these attributes in SeleniteConfigurations. */

        attribute asteroidOnlineLagYears : Integer = 10;
        doc lagDoc /* owner: programme | kind: computationalInput | source:
             * Decision Framework Rev D (redirect Y75 -> arrival Y85, Y95 ->
             * Y105, Y115 -> Y125); Strategy v3.1 s.11.1. */

        // ---- Crew policy ---------------------------------------------------

        attribute permanentCrewAtPkt : Integer = 0;
        attribute spaPermanentCrewAtFullConfiguration : Integer = 20;
        doc crewDoc /* owner: programme | kind: policy | source: SEL-REQ-002 and
             * Strategy v3.1 s.5.2 (zero permanent crew at PKT); Decision
             * Framework Rev D P12 end-state "20 crew at SPA" and Strategy v3.1
             * s.5.1 "12-20 crew (P6+)" (SPA 20); HAB-001 Rev D (docx, not in
             * docs/). */

        attribute pktTemporaryCommissioningCrewMax : Integer = 4;
        attribute pktTemporaryCommissioningMonthsMax : Integer = 12;
        doc tempCrewDoc /* owner: programme | kind: policy | source: Decision
             * Framework Rev D DG-8.6 "3-4 specialists, 6-12 months"; Strategy
             * v3.1 s.5.2 and s.7.2 Wave 3; the SEL-REQ-002 exception resolved
             * in DOCUMENT_FAMILIES.md (temporary commissioning crew at PKT in
             * P8 is baseline; permanent crew stays zero). */

        // ---- Committed processing design ---------------------------------

        attribute circuitReoTonnesPerYear : Real = 1.2;
        attribute circuitMassKg : Real = 28000.0;
        attribute circuitPowerKw : Real = 400.0;
        doc circuitDoc /* owner: programme | kind: policy | source: Decision
             * Framework Rev D s.4 "Optimised (committed)" row and DG-8.X;
             * Strategy v3.1 s.10.2. The computational authority carries the
             * same design (ECON v1.3 circuit.reo_yr / mass_kg / power_kw). */

        // ---- Capacity constraints -------------------------------------------

        attribute psrMoleICapacityUnits : Integer = 620;
        attribute psrMoleINodeCount : Integer = 124;
        attribute psrMoleIUnitsPerNode : Integer = 5;
        doc psrCapDoc /* owner: PSR layout (VISUALIZE v3.3 / psr_layout.py) |
             * kind: capacityConstraint | source: psr_layout.workspace()
             * n_total = 124 nodes x node.units = 5 -> 620 MOLE-I positions on
             * the 3,250 m radius floor (util_pct 47 %), runner v2.1 golden.
             * Bound by rule W2-N18 (the layout computation, not a document, is
             * the arbiter). Superseded document figures, recorded not bound:
             * fleet v9 s.4.3 and Strategy v3.1 s.4.4 "~310 MOLE-I positions
             * (~8.5 km2 usable floor, 62 substations)"; Strategy s.4.3 "62
             * junctions (620 MOLE-I max)"; final report Fig. 11 "~17.5 km2
             * feasible". This cap is an input to DG-11.6 (MkIiiTransitionGate);
             * plan_check reports the 310 sensitivity alongside. */

        attribute tier1ResourceTonnes : Real;
        attribute tier2ResourceTonnes : Real;
        doc tierDoc /* owner: programme | kind: capacityConstraint | UNBOUND:
             * Decision Framework Rev D s.10.2 gives only the 200 m column total
             * (~220-660 Mt REE, "Tier 1 supports the first ~50-100+ years");
             * no per-tier tonnage is stated. Inputs to DG-POST.1 / DG-POST.2
             * (TierDepletionGate); Wave 5 with the resource model. */

        // ---- Python-supplied vectors and inputs (unbound) ------------------

        attribute reoTonnesPerYearByYear : Real [0..*] ordered;
        doc rampDoc /* owner: economics | kind: computationalInput | UNBOUND:
             * the REO ramp by programme year, ECON v1.3 reo_target (knots at
             * Y25 0.4, Y28 125, Y45 1,000, Y60 10,000, Y80 100,000, Y120
             * 500,000, Y180 2.5 M). Every capacity-driven gate is a consequence
             * of this vector; plan_check reads it from econ.workspace(). */

        attribute reoDemandBaselineTonnesPerYear : Real;
        attribute reoDemandGrowthRatePerYear : Real;
        doc demandDoc /* owner: economics | kind: computationalInput | UNBOUND:
             * ECON v1.3 reo_demand_2026 (400,000 t/yr) growing 2 %/yr, capped at
             * the programme target - the denominator of supply_frac used by
             * the "global displacement" gates. Wave 5 binding. */

        attribute spaElectricalDemandByYear : Real [0..*] ordered;
        attribute spaNonMsrCapabilityByYear : Real [0..*] ordered;
        doc spaPowerDoc /* owner: power (VERIFY) | kind: computationalInput |
             * UNBOUND: SPA demand and solar + FSP + battery capability beyond
             * P7. VERIFY v5.0 ph.p_tot covers P3..P7 only; the F5 gate
             * (SpaMsrIntroductionGate) cannot be evaluated until the Python
             * layer extends these vectors (Wave 5). */

        attribute thoriumHydroxideStockpileByYear : Real [0..*] ordered;
        doc thoriumDoc /* owner: processing | kind: computationalInput |
             * UNBOUND vector: cumulative Th(OH)4 from the acid bake, computed
             * by selenite.plan_vectors.thorium_stockpile (Wave 3 extension,
             * no golden) as cumulative reo_target x thoriumToReoMassRatio.
             * Input to DG-8.7 (ThoriumStockpileGate). */

        attribute processingReeGradePpm : Real = 500.0;
        attribute thoriumGradePpm : Real = 12.5;
        attribute thoriumGradePpmLow : Real = 10.0;
        attribute thoriumGradePpmHigh : Real = 15.0;
        attribute acidBakeThoriumCapture : Real = 0.92;
        attribute acidBakeThoriumCaptureLow : Real = 0.90;
        attribute acidBakeThoriumCaptureHigh : Real = 0.95;
        attribute thoriumHydroxideToThoriumMassRatio : Real = 1.293;
        attribute thoriumToReoMassRatio : Real =
            thoriumGradePpm / processingReeGradePpm * acidBakeThoriumCapture * thoriumHydroxideToThoriumMassRatio;
        doc thoriumRatioDoc /* owner: processing | kind: computationalInput |
             * SEL-ECN-022 s.2.2 (Jason, 19 Sep 2026): Th grade at the DART-selected
             * processing sites 12.5 ppm nominal, range 10-15 ppm (fleet v9
             * s.8 "10-15 ppm Th vs 1-3 ppm SPA"; Lunar Prospector GRS:
             * Apollo-14-soil-equivalent Fra Mauro 12-13 ppm, PKT hot spots at
             * Aristarchus / Apennine Bench, Lawrence et al. 2000, 2003; KREEP
             * basalt ~15 ppm Th); REE processing grade 500 ppm (Decision
             * Framework Rev D "500 ppm grade clarified as DART-selected site /
             * post-beneficiation concentrate"); acid-bake Th capture 0.92
             * nominal, range 0.90-0.95 (Strategy v3.1 s.8.2 "~90-95% of Th into
             * insoluble ThP2O7"; DG-7.2 states the mechanism without the figure);
             * Th(OH)4/Th = 300.1/232.0. The ratio is derived, never typed:
             * ~0.030 t Th(OH)4 per t REO, four times the 0.004-0.008 the
             * Decision Framework's DG-11.2 figures imply (387-773 t/yr Th at
             * 100,000 t/yr REO) - W3-N22. plan_check evaluates DG-8.7 at the
             * nominal and both range corners. */

        attribute spaEclipseCriticalCoverageOnly : Boolean = true;
        attribute spaAsteroidLoadCriticalFraction : Real = 0.18;
        attribute spaMsrFirstUnitRatedKw : Real = 50000.0;
        doc spaMsrDoc /* owner: power | kind: policy / computationalInput |
             * The SPA MSR decision (F5, SpaMsrIntroductionGate) is evaluated
             * as VERIFY v5.0 sizes SPA power: solar carries the day load and
             * FSP + battery must carry the eclipse-critical loads (ecl.*) for
             * the 72 h case. spaEclipseCriticalCoverageOnly = true is that
             * rule. selenite.plan_vectors.fsp_msr_trade compares the Earth
             * mass of the FSP fleet the critical load needs (VERIFY fsp: 40
             * kW, 6,600 kg per unit) with one SPA MSR (ECON msr: 50,000 kg x
             * earth_frac(y), 0.3 floor from Y80 as Ni-201 vessels go in-situ)
             * and requires ThCl4 (MD-3, DG-9.6). Jason, 19 Sep 2026: "when
             * demand builds beyond what it is worth bringing more FSP units
             * for, the MSR becomes worth it". spaAsteroidLoadCriticalFraction
             * = 1.0 (ECN-022, Jason, 19 Sep 2026): pyrolysis, Fischer-Tropsch
             * and Czochralski growth are continuous thermal processes that
             * cannot cold-soak through the 72 h eclipse, so the whole
             * asteroid-processing load is eclipse-critical. The derived year
             * (Y105) is the same at 0 and 1 because the cargo-mass crossover
             * comes first. First-unit rating 50 MWe per Decision Framework
             * s.10.1. SEL-ECN-023 (Jason, 6 Nov 2026) SUPERSEDES the 1.0: the
             * asteroid lines run on the sunlit duty cycle (D1 alternative B,
             * selected in the configuration), so only the hold loads - a share
             * of the plant oversized x1.21 for the dark fraction and restart
             * losses - are eclipse-critical. 0.18 is the derived value
             * (SeleniteAnalysis::EclipseCriticalFraction on the ASSUMED
             * hold-load fractions 0.25, the Decision Framework s.10.1 loads and
             * the Czochralski batch scheduling; register mean 0.184, 0.04-0.37
             * across the holdLoadLow / holdLoadHigh scenarios), carried to two
             * figures. The non-nuclear fallback becomes 1,156 FSP (scenario register
             * mean at the sampled 0.1843; the plan register's nominal evaluation
             * at 0.18 prints 1,129), not 6,254;
             * the derived MSR year stays Y105. The derived twin remains
             * reported per strategy by tools/scenario_check.py. */

        attribute co2PerLaunchTonnes : Real;
        doc co2Doc /* owner: economics | kind: computationalInput | UNBOUND -
             * VC-20: 2,200 (ECON v1) vs 2,683 (ECN-020) vs 2,750 declining
             * (ECON v1.4). ECON v1.4 is the authority; bound at Wave 5. */

        attribute launchCostPerFlightUsd : Real;
        doc launchDoc /* owner: economics | kind: computationalInput | UNBOUND:
             * Starship baseline ($100M/flight per final report Fig. 48; ECN-020
             * s.3). ECON v1.3 carries launch cost per kg instead
             * (launch_cost: 6,000 / 4,000 / 2,000 $/kg by era). Wave 5. */

        attribute reoPayloadPerCanisterTonnes : Real;
        doc canisterPayloadDoc /* owner: transport | kind: computationalInput |
             * UNBOUND - conflict recorded (W3-N7): ECN-020 s.4 corrects the
             * MD-2 payload to 3.6 t (694,444 canisters/yr); ECON v1.3
             * can.reo_payload_t = 3.5 t (714,286/yr at 2.5 Mt/yr). Not
             * adjudicated. */

        attribute canisterEarthContentKg : Real;
        doc canisterEarthDoc /* owner: transport | kind: computationalInput |
             * UNBOUND - DG-9.1 canister recovery decision open: 73 kg (option
             * 1a full parachute), 28 kg (1b minimal drag chute, RECOMMENDED),
             * 8 kg (2 shuttlecock). ECON v1.3 can.earth_kg = 28 assumes option
             * 1b (recorded on the gate). */

        attribute mkIiiPeakFleetUnits : Integer;
        attribute redirectTugFleetUnits : Integer [0..*] ordered;
        doc fleetDoc /* owner: fleet | kind: computationalInput | UNBOUND: Mk III
             * build-out to ~1,714 (ECON mkiii_target) and redirect tugs 2 -> 3
             * -> 5 (ECON tug_fleet from Y65 / Y85 / Y105; Strategy v3.1 s.11.2).
             * Estimates, not decisions; the DG-14.9 thresholds below carry the
             * gate's own figures. */

        // ---- Wave 4A: decision criterion, SPA eclipse strategy (D1) and ------
        // ---- the sampled scenario inputs (U-set) --------------------------------

        attribute decisionCriterion = DecisionCriterion::expectedEarthMassWithSlipChance;
        attribute chanceConstraintThreshold : Real = 0.8;
        doc criterionDoc /* owner: programme | kind: policy | PROPOSED (Wave 4A,
             * 6 Nov 2026, open question 1; Jason to confirm by ECN-023): minimise
             * expected cumulative Earth-launched mass, the programme's own
             * Earth-independence measure (DG-14.6), subject to P(no milestone
             * slip) >= 0.8. Consistent with Wave 3 practice: the SPA MSR
             * decision (ECN-022 s.2.3) was made on Earth-launched cargo mass,
             * and the ECON NPV (-0.49 T, BCR 0.50 direct / 2.06 with
             * externalities) is dominated by externality assumptions. Jason,
             * 20 Sep 2026: "the most economical decision"; the alternatives
             * (expected NPV; lexicographic) are reported beside it. */

        attribute spaIlluminatedFraction : Real = 0.85;
        attribute spaDarkFraction : Real = 1.0 - spaIlluminatedFraction;
        attribute spaDarkFractionLow : Real = 0.12;
        attribute spaDarkFractionHigh : Real = 0.229;
        doc darkDoc /* owner: power (VERIFY) | kind: computationalInput | source:
             * VERIFY v5.0 solar.illum = 0.85, the annual-average illumination of
             * the SPA site; the dark fraction is derived (1 - illumination),
             * never typed. Range: Glaeser et al. 2014 (Icarus 243, 78-90 and
             * EPSC 2014-136), average illumination 77.1-88.0 % at the
             * Shackleton-rim and Connecting Ridge candidate sites 2 m above
             * ground, the maximum on the ridge between Shackleton and de
             * Gerlache -> dark fraction 0.120-0.229; VERIFY's 0.15 lies inside
             * it (Power.sysml already cites the paper for the array). Wave 4A
             * (6 Nov 2026, open question 2): the NASA South Pole-Aitken basin
             * page Jason offered describes the basin's geology and gives no
             * illumination figure, so it is not the source. The brief's fallback
             * (triangular 0.10-0.20, source unbound) is superseded. */

        attribute spaDesignEclipseHours : Real = 72.0;
        attribute spaLongestEclipseHoursLow : Real = 72.0;
        attribute spaLongestEclipseHoursHigh : Real = 120.0;
        doc eclipseDoc /* owner: power | kind: policy / computationalInput |
             * source: Strategy v3.1 s.12.1 "72-hr eclipse design case"; VERIFY
             * v5.0 eclipse_hr = 72. Range of the longest eclipse: Glaeser et al.
             * 2014 "longest continuous periods in darkness typically only 3-5
             * days" at the candidate sites -> 72-120 h, the design case at the
             * low end (W4A-N1, recorded not resolved: a five-day eclipse
             * exceeds the design case). FSP units are sized on power and do not
             * move with it; the hybrid strategy's battery and the hold energy
             * are sized on the sampled length. */

        attribute lunarSynodicPeriodHours : Real = 708.7;
        doc synodicDoc /* owner: power | kind: computationalInput | source: the
             * lunar synodic month, 29.53 days (astronomical constant). The
             * sunlit window between successive eclipses is at least the synodic
             * period less the longest eclipse (589-637 h on the range above);
             * SunlitWindowGate compares a Czochralski batch against it. */

        attribute czochralskiBatchHours : Real = 48.0;
        attribute czochralskiBatchHoursLow : Real = 24.0;
        attribute czochralskiBatchHoursHigh : Real = 72.0;
        doc czochralskiDoc /* owner: processing | kind: computationalInput |
             * source: Jason, 6 Nov 2026 (open question 3): "reading says a
             * batch takes 1-3 days" -> 24-72 h, nominal the midpoint. Czochralski
             * growth cannot pause mid-crystal (Wave 4A brief s.2), so the S-type
             * furnace is batch-scheduled between eclipses, not held: a batch
             * fits when its hours do not exceed the minimum sunlit window, which
             * every sampled value satisfies with at least eight times margin
             * (SunlitWindowGate; (708.7 - 120) / 72 at the worst corner). External figures found 6 Nov 2026 (200 mm
             * cycles ~1-2 days; 300 mm pulls 60-100 h, vendor data, unverified)
             * are recorded here, not bound. */

        attribute plantOversizeMassPenaltyKgPerKw : Real = 70.0;
        attribute plantOversizeMassPenaltyKgPerKwLow : Real = 70.0;
        attribute plantOversizeMassPenaltyKgPerKwHigh : Real = 83.3;
        doc oversizeDoc /* owner: processing | kind: computationalInput | PROXY,
             * flagged in the scenario register: no document gives the asteroid
             * processing lines' mass per kW. Decision Framework Rev D s.4 gives
             * a processing plant of the same kind at 28,000 kg / 400 kW = 70.0
             * (optimised, committed), 22,000 / 300 = 73.3 (continuous-flow) and
             * 15,000 / 180 = 83.3 kg/kW (batch); carried as the range. The
             * Earth-launched share of oversize plant follows the ECON circuit
             * Earth-fraction trajectory (0.10 falling to 0.03 after the C-type
             * and 0.008 after the S-type arrival); the named scenario
             * earthBuiltAsteroidPlant tests an all-Earth plant. */

        attribute eclipseRestartLossDaysPerEclipse : Real;
        doc restartDoc /* owner: processing | kind: computationalInput | UNBOUND:
             * production lost per restart after an eclipse pause, in days of
             * output. No process source exists (SEL-PROC-C-001 and
             * SEL-PROC-S-001 are not written). The Python evaluator carries a
             * declared working assumption (selenite.scenarios.eclipse
             * ASSUMED_RESTART_LOSS_DAYS = 0.5, a half day per eclipse) and the
             * register marks it ASSUMED; the evaluator's eclipse count per year
             * is the dark fraction divided by the sampled longest eclipse (the
             * fewest, longest eclipses - a lower bound on restarts, 11-18 a
             * year). W4A-N7 (recorded, not resolved): VERIFY's 0.85 illumination
             * with a 72 h longest eclipse implies about 18 dark periods a year,
             * more than one per synodic month, while the Glaeser 3-5 day
             * darkness is consistent with 11-13; the sunlit-window gate assumes
             * at most one dark period per synodic month. */

        attribute hybridStoredLoadFraction : Real = 0.5;
        doc hybridDoc /* owner: power | kind: policy | source: Wave 4A brief D1
             * alternative D, "battery or thermal storage carries a chosen
             * fraction": the chosen fraction is a design parameter of that
             * alternative, not an uncertainty; 0.5 is the declared design
             * point. The rest of the load follows the sunlit duty cycle. */

        attribute spaMsrAvailabilityProbability : Real = 1.0;
        doc msrAvailDoc /* owner: power | kind: policy | source: Wave 3 - the
             * thorium MSR line rests on test outcomes the plan assumes true
             * (DG-7.5 breeding ratio, DG-9.3 first PKT MSR, assumedOutcome =
             * true) and on MD-3 (DG-9.6). 1.0 is that assumption restated as a
             * probability that the SPA MSR is available when the asteroid loads
             * arrive; range unbound (no source states a probability). D1 turns
             * on it: with the MSR present the eclipse strategy costs nothing
             * extra under carry-through, without it the strategy sizes the FSP
             * fleet. The named scenarios msrUnavailable (0.0) and msrUncertain
             * (0.9) carry the sensitivity; the register prints the break-even
             * probability. */

        attribute batterySpecificEnergyWhPerKg : Real = 250.0;
        attribute batteryMarginFactor : Real = 1.2;
        attribute fspUnitPowerKw : Real = 40.0;
        attribute fspUnitMassKg : Real = 6600.0;
        attribute solarPanelMassKgPerM2 : Real = 3.0;
        doc powerUnitDoc /* owner: power (VERIFY) | kind: computationalInput |
             * transcribed from VERIFY v5.0: batt_Whkg = 250 and batt_margin =
             * 1.20 (eclipse battery rule bkWh = shortfall x eclipse_hr x
             * margin); fsp.pwr_kW = 40, fsp.mass_kg = 6,600 (ECON v1.3 fsp
             * agrees); panel mass 3 kg/m2 (ph.panel_kg = panel_m2 x 3). Points;
             * ranges unbound (no second source). scenario_check asserts the
             * transcription against verify.workspace(). */

        attribute thcl4AvailableYear : Integer = 43;
        attribute thcl4AvailableYearLow : Integer = 43;
        attribute thcl4AvailableYearHigh : Integer = 60;
        doc thcl4Doc /* owner: transport | kind: computationalInput | source:
             * DG-9.6 "PKT->SPA mass driver operational - ThCl4 fuel for SPA MSR"
             * declared Y43 (P9) with declaredPhaseAlternate P10 (W2-N2: fleet v9
             * s.16 and Decision Framework s.3 "P9-P10 (Y43)"); the range is the
             * gate's own two phases, Y43 to the end of P10 (Y60). The
             * exogenous gate itself stays declared; this is the sampled twin
             * the FSP-versus-MSR trade reads. */

        attribute solarInSituStartYear : Integer = 60;
        attribute solarInSituStartYearLow : Integer = 60;
        attribute solarInSituStartYearHigh : Integer = 80;
        attribute solarInSituEarthFraction : Real = 0.3;
        doc solarInSituDoc /* owner: power | kind: computationalInput | source:
             * Decision Framework Rev D s.6 (P11 row): a-Si panels in-situ from
             * P11 -> the P11 window Y60-Y80 (ProgrammeTimeline) is the range,
             * Y60 the nominal plan_check uses. The Earth fraction of in-situ
             * array mass, 0.3, mirrors the ECON MSR floor as plan_vectors
             * assumed it (point, range unbound). */

        attribute launchCostMultiplier : Real = 1.0;
        attribute launchCostMultiplierLow : Real = 0.5;
        attribute launchCostMultiplierHigh : Real = 1.5;
        doc launchMultDoc /* owner: economics | kind: computationalInput | source:
             * ECON v1.4 tornado "Launch cost (+50% vs -50%)" applied to the v1.3
             * era schedule 6,000 / 4,000 / 2,000 $/kg (W3-N18: per kg, not per
             * flight). */

        attribute discountRateMultiplier : Real = 1.0;
        attribute discountRateMultiplierLow : Real = 0.4667;
        attribute discountRateMultiplierHigh : Real = 1.1667;
        doc discountDoc /* owner: economics | kind: computationalInput | source:
             * ECON v1.3 schedule 3 / 2.5 / 2 % (to Y30 / Y75 / after); ECON
             * v1.4 tornado bounds 1.4 % and 3.5 % as flat rates. Modelled as a
             * multiplier on the schedule so that the first-era rate spans
             * 1.4-3.5 % (0.4667 = 1.4/3.0, 1.1667 = 3.5/3.0); a convention,
             * stated in the register. */

        attribute reoExternalityUsdPerTonne : Real = 73700.0;
        attribute reoExternalityUsdPerTonneLow : Real = 50000.0;
        attribute reoExternalityUsdPerTonneHigh : Real = 90000.0;
        attribute h2AttributionFraction : Real = 0.5;
        attribute h2AttributionFractionLow : Real = 0.25;
        attribute h2AttributionFractionHigh : Real = 1.0;
        attribute geoInsuranceUsdMPerYear : Real = 15000.0;
        attribute geoInsuranceUsdMPerYearLow : Real = 0.0;
        attribute geoInsuranceUsdMPerYearHigh : Real = 25000.0;
        attribute circuitMaintenanceFractionPerYear : Real = 0.005;
        attribute circuitMaintenanceFractionPerYearLow : Real = 0.0025;
        attribute circuitMaintenanceFractionPerYearHigh : Real = 0.005;
        doc tornadoDoc /* owner: economics | kind: computationalInput | source:
             * ECON v1.4 sensitivity tornado: REO externality $73,700/t ($50k vs
             * $90k); H2 attribution 0.50 (25 % vs 100 %); geo insurance
             * $15 B/yr ($0 vs $25 B); circuit maintenance 0.5 %/yr (0.5 % vs
             * 0.25 %; Decision Framework Rev D s.4 "revised from 2%"). The
             * nominals are the v1.3 values the goldens carry. */

        attribute reoRampKnotShift : Integer = 0;
        attribute reoRampKnotShiftLow : Integer = 0;
        attribute reoRampKnotShiftHigh : Integer = 1;
        doc rampVariantDoc /* owner: economics | kind: computationalInput |
             * source: W3-N4 - the ECON v1.3 reo_target knots (100 kt at Y80,
             * 500 kt at Y120, 1 Mt at Y140; plan_check meets the gate criteria
             * at Y80 / Y121 / Y152) are one knot later than the
             * Decision Framework's REO gates (DG-11.1 Y60, DG-12.1 Y80, DG-13.1
             * Y120). 0 = the ECON ramp (the goldens), 1 = the Decision
             * Framework's knots one step earlier. Sampled as a two-point
             * discrete variable with equal weights (uninformative; stated in
             * the register). */

        attribute msrUnitMassKg : Real = 50000.0;
        attribute msrEarthFractionFloor : Real = 0.3;
        doc msrUnitDoc /* owner: power (ECON) | kind: computationalInput |
             * transcribed from ECON v1.3: msr.mass_kg = 50,000 per 100 MWe unit
             * and msr.earth_frac floor 0.3 from Y80 (Ni-201 in-situ vessels,
             * DG-11.4; Strategy v3.1 s.15.2 and the Decision Framework Rev D P14
             * "Earth fraction trajectory" table, MSR 30 %). Points;
             * ranges unbound. Read by the FSP-versus-MSR trade (D1, D2). */

        attribute reoPayloadPerCanisterTonnesEcon : Real = 3.5;
        attribute reoPayloadPerCanisterTonnesEcn020 : Real = 3.6;
        doc canisterPayloadCandidatesDoc /* owner: transport | kind:
             * computationalInput | W3-N7 / VC-22 candidates for the unbound
             * reoPayloadPerCanisterTonnes (rule 5b): ECON v1.3 can.reo_payload_t
             * = 3.5 t (714,286 canisters/yr) and ECN-020 s.4 3.6 t (694,444/yr).
             * Sampled two-point, equal weights, for D3. */

        attribute canisterEarthContentFullParachuteKg : Real = 73.0;
        attribute canisterEarthContentDragChuteKg : Real = 28.0;
        attribute canisterEarthContentShuttlecockKg : Real = 8.0;
        attribute impactSurvivalPassProbability : Real = 0.5;
        doc canisterOptionsDoc /* owner: transport | kind: computationalInput |
             * source: Decision Framework Rev D s.9 / DG-9.1 options 1a, 1b
             * (RECOMMENDED; ECON v1.3 can.earth_kg = 28 assumes it) and 2
             * (needs impact-survival validation, DF s.11 item 9). The
             * impact-survival test outcome is a sampled Boolean (D3 recourse:
             * a failed test falls back to the next safer option); 0.5 is an
             * uninformative probability, range unbound - DF s.9 rates the risk
             * MED / HIGH without a number. Jason, 6 Nov 2026: D3 in scope. */

        attribute psrMoleICapacityUnitsDocument : Integer = 310;
        doc capacityCandidatesDoc /* owner: PSR layout | kind: capacityConstraint
             * | W2-N18 candidate for D7: fleet v9 s.4.3 / Strategy v3.1 s.4.4
             * "~310 MOLE-I positions" against the bound 620 (psr_layout.py,
             * SEL-REQ-016). Sampled two-point with the bound value, equal
             * weights; the bound value stays bound. The MOLE-I peak need is
             * ECON's vector (357 at Y35; VC-07 documents say ~355), not a
             * parameter. */

        attribute mkIiiTestPassProbability : Real = 0.5;
        doc mkIiiTestDoc /* owner: fleet | kind: computationalInput | source:
             * DG-11.6 is a derivable gate resting on the ion-SEP / EM-catcher
             * validation (Strategy v3.1 s.16 "Ion SEP validated; EM catcher
             * operational"); 0.5 is an uninformative probability for D7, range
             * unbound. */

        attribute haulerEarthFractionFloorEcon : Real = 0.43;
        attribute haulerEarthFractionFloorFleetV9 : Real = 0.08;
        doc haulerFloorDoc /* owner: fleet | kind: computationalInput | F3
             * candidates for D8: ECON v1.3 hauler.earth_frac floor 0.43 (the
             * "~57 % in-situ" reading; fleet v9 s.10.1 itself) and the superseded
             * SEL-HAULER-001 Rev A column / HAULER_SPEC_UPDATE_BRIEF "92 %
             * in-situ" -> 0.08 (CHANGELOG_WAVE2 F2 diff; DOCUMENT_FAMILIES F3).
             * The DG-13.7 20 % floor is GateThresholds.
             * haulerEarthFractionFloor. Sampled two-point, equal weights. */

        attribute mTypeCaptureYearLow : Integer;
        attribute mTypeCaptureYearHigh : Integer;
        attribute asteroidOnlineLagYearsLow : Integer;
        attribute asteroidOnlineLagYearsHigh : Integer;
        doc captureRangeDoc /* owner: programme | kind: computationalInput |
             * UNBOUND ranges: no document states a range for the capture years
             * or the redirect-to-arrival lag (every source gives Y75 -> Y85,
             * Y95 -> Y105, Y115 -> Y125). D5 and the gate-year distributions
             * therefore carry the capture years as points; the named scenario
             * lateMType (capture Y85) carries the sensitivity. Binding a range
             * is an ECN with a source (tug readiness, DG-11.8). */

        part gateThresholds : GateThresholds;
    }

    part def GateThresholds {
        doc /* owner: Decision Framework Rev D (SEL-DECISION-001) | kind: policy.
             * One attribute per numeric criterion in the gate catalogue, each
             * the value the Decision Framework states for that gate (Strategy
             * v3.1 s.16 where it restates it). The calc defs in
             * SeleniteAnalysis take these as inputs; tools/plan_check.py reads
             * them by name. A threshold change is an ECN to the Decision
             * Framework. Dimensions are in the names. */

        attribute moleIYieldKgPerYear : Real = 5692.0;
        doc t21 /* DG-2.1. Equal to VERIFY v5.0 mi.prop_yield (a typed constant)
             * and Strategy v3.1 s.1, whose stated product (25 kg/hr x 4.46 % ice
             * x 80 % x 8,760 h x 0.722) evaluates to 5,642; 5,692 corresponds to
             * 4.5 % ice. Verification 6 Nov 2026: recorded, not resolved. */

        attribute probeIsruFuelledFraction : Real = 0.70;
        doc t32 /* DG-3.2 ">70%" - not a Python vector; recorded for the gate
             * text. */

        attribute dartSitesRequired : Integer = 3;
        attribute dartReePpmMinimum : Real = 200.0;
        attribute spaReoTonnesPerYearAtCommitment : Real = 0.4;
        doc t71 /* DG-7.1 ">=3 PKT sites", ">=200 ppm REE", ">=0.4 t/yr REO".
             * The scaling page (W5_T4_4_JS_scaling_P7_P14.html "ground-truth
             * >500 ppm REE"), the extended timeline v3 and final report Fig. 2
             * quote ">500 ppm"; fleet v9 does not - Decision Framework Rev D
             * s.10.2 resolves it as ">=200 ppm, target >500 ppm"; the target is
             * not a threshold. */

        attribute reagentInSituFractionP7 : Real = 0.5;
        doc t74 /* DG-7.4 "10% -> 50% in-situ H2SO4". */

        attribute breedingRatioMinimum : Real = 1.0;
        doc t75 /* DG-7.5 and DG-9.3 "BR > 1.0" (strict). Strategy v3.1 s.8.2
             * design range 1.01-1.08. */

        attribute circuitsFirstTranche : Real = 100.0;
        doc t82 /* DG-8.2 "First 100 processing circuits operational". */

        attribute haulersFirstTranche : Real = 50.0;
        doc t84 /* DG-8.4 "First 50 haulers operational at PKT". */

        attribute circuitsP8Complete : Real = 308.0;
        attribute reoTonnesPerYearP8 : Real = 125.0;
        doc t85 /* DG-8.5 "308 processing circuits complete; 125 t/yr REO". 308 x
             * 0.4 t/yr (batch) = 123 t/yr; with the committed 1.2 t/yr circuit
             * ECON needs 105 circuits for 125 t/yr (W3-N3). */

        attribute thoriumStockpileTonnes : Real = 40.0;
        doc t87 /* DG-8.7 "~40 t Th(OH)4 accumulated". */

        attribute circuitThroughputMinimumTonnesPerYear : Real = 1.0;
        doc t8x /* DG-8.X ">=1.0 t/yr REO per circuit"; Strategy v3.1 s.16. */

        attribute haulersP9 : Real = 1000.0;
        doc t92 /* DG-9.2 "1,000+ haulers operational". */

        attribute foundryTonnesPerYearP9 : Real = 100.0;
        doc t94 /* DG-9.4 "100+ t/yr metal production". */

        attribute conveyorKmPilot : Real = 500.0;
        doc t97 /* DG-9.7 "first 500 km trunk". */

        attribute haulersP10 : Real = 14881.0;
        doc t101 /* DG-10.1 "14,881 mining-capable haulers" (VC-08: the document
             * series is SCALE v1.3; ECON haulers_needed is the authority). */

        attribute conveyorKmP10 : Real = 5000.0;
        doc t102 /* DG-10.2 "5,000+ km". */

        attribute foundryTonnesPerYearP10 : Real = 1000.0;
        doc t103 /* DG-10.3 "1,000+ t/yr formed metal". */

        attribute msrUnitsP10 : Real = 74.0;
        doc t104 /* DG-10.4 "~74 x 100 MWe units at PKT". */

        attribute reoTonnesPerYearP11 : Real = 100000.0;
        attribute displacementFractionP11 : Real = 0.10;
        doc t111 /* DG-11.1 "100,000 t/yr REO"; P11 heading "10% global
             * displacement". */

        attribute msrUnitsP11 : Real = 679.0;
        doc t112 /* DG-11.2 "~679 x 100 MWe". */

        attribute conveyorKmP11 : Real = 15000.0;
        doc t115 /* DG-11.5 "~15,000 km". */

        attribute pgmExportTriggerTonnesPerYear : Real = 100.0;
        doc t116 /* DG-11.6 "SPA->Earth mass driver triggered when PGM
             * concentrate volume exceeds ~100 t/yr"; Decision Framework s.3
             * MD-4 row. */

        attribute reoTonnesPerYearP12 : Real = 500000.0;
        attribute displacementFractionP12 : Real = 0.40;
        doc t121 /* DG-12.1 "500,000 t/yr REO -> 40% global displacement". The
             * same document's P12 end-state puts ~500,000 t/yr at ~Y120
             * (W3-N4). */

        attribute msrUnitsP12 : Real = 6890.0;
        doc t122 /* DG-12.2 "~6,890 x 100 MWe" (VC-09: ECON gives 8,334 at
             * Y200). */

        attribute canistersPerDaySteadyState : Real = 783.0;
        doc t123 /* DG-12.3 "783/day at P14+ steady state". ECN-020 s.4
             * identifies 783/day as the stale 1.0 Mt/yr figure and corrects
             * the 2.5 Mt/yr cadence to ~1,903/day; the Decision Framework Rev D
             * gate text was not updated (W3-N6). Threshold carried as written. */

        attribute mTypePgmTonnesPerYear : Real = 36.5;
        doc t126 /* DG-12.6 "36.5 t/yr PGM". ECON captured_asteroid_pgm = 36.5
             * from Y85. */

        attribute reoTonnesPerYearP13 : Real = 1250000.0;
        attribute displacementFractionP13 : Real = 0.50;
        doc t131 /* DG-13.1 "1,250,000 t/yr REO - 50% of projected global
             * demand". */

        attribute circuitEarthFractionPostCType : Real = 0.03;
        doc t135 /* DG-13.5 "10% to 3%". */

        attribute haulerEarthFractionFloor : Real = 0.20;
        doc t137 /* DG-13.7 "43% to 20% floor". ECON v1.3 hauler.earth_frac
             * floors at 0.43, less a 0.10 M-type bonus from Y90 (0.33); the
             * 0.20 floor is not modelled - W3-N5. */

        attribute circuitEarthFractionPostSType : Real = 0.008;
        doc t145 /* DG-14.5 "3% to 0.8%". */

        attribute earthDependencyMaximumFraction : Real = 0.005;
        doc t146 /* DG-14.6 "<0.5% of total infrastructure mass from Earth". */

        attribute mkIiiPeakFleet : Real = 1714.0;
        attribute mkIiiProspectingFleet : Real = 300.0;
        doc t149 /* DG-14.9 "from ~1,714 to ~300"; ECON mkiii_target 1714 and
             * the 300 prospecting complement from Y115. */
    }
}
