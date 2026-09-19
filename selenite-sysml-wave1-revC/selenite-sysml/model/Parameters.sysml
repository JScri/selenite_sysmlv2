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
        doc crewDoc /* owner: programme | kind: policy | source: SEL-REQ-002;
             * Strategy v3.1 s.5.2; HAB-001 Rev D. */

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
             * fleet v9 s.4.1 and Strategy v3.1 s.4.4 "~310 MOLE-I positions
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
        attribute thoriumToReoMassRatio : Real;
        doc thoriumDoc /* owner: processing | kind: computationalInput |
             * UNBOUND: cumulative Th(OH)4 from the acid bake; not a vector in
             * ECON v1.3/v1.4. selenite.plan_vectors.thorium_stockpile (Wave 3
             * extension, no golden) computes it as cumulative reo_target x
             * thoriumToReoMassRatio; the Decision Framework's DG-11.2 numbers
             * imply 0.0039-0.0077 (387-773 t/yr Th against 100,000 t/yr REO).
             * plan_check reports DG-8.7 at both bounds until the ratio is
             * bound. Input to DG-8.7 (ThoriumStockpileGate). */

        attribute spaNonMsrCapabilityCeilingKw : Real;
        doc spaCeilingDoc /* owner: power | kind: capacityConstraint | UNBOUND:
             * the most solar + FSP + battery can deliver at SPA. No source
             * states it; VERIFY v5.0 sizes solar to demand through P7 (2,342
             * kW at P7). selenite.plan_vectors.spa_power (Wave 3 extension)
             * gives the demand trajectory beyond P7; the F5 gate evaluates
             * only once this ceiling is bound. */

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
        doc t21 /* DG-2.1. Equal to VERIFY v5.0 mi.prop_yield and Strategy v3.1
             * s.1 (25 kg/hr x 4.46 % ice x 80 % x 8,760 h x 0.722). */

        attribute probeIsruFuelledFraction : Real = 0.70;
        doc t32 /* DG-3.2 ">70%" - not a Python vector; recorded for the gate
             * text. */

        attribute dartSitesRequired : Integer = 3;
        attribute dartReePpmMinimum : Real = 200.0;
        attribute spaReoTonnesPerYearAtCommitment : Real = 0.4;
        doc t71 /* DG-7.1 ">=3 PKT sites", ">=200 ppm REE", ">=0.4 t/yr REO".
             * Fleet v9 s.20.3 quotes ">500 ppm" - Decision Framework Rev D
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
