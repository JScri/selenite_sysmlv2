package SeleniteGates {
    doc /* Decision gates (DG-x.y) and the derivation rule for phase
         * attributes. Wave 3 catalogue (15 Sep 2026): every gate of
         * docs/SELENITE_DECISION_FRAMEWORK_v4.md (SEL-DECISION-001 Rev D, F1
         * confirmed) as a DecisionGate - 81 unique gate identifiers DG-0.1 ..
         * DG-14.9 plus DG-POST.1/2. The "82 gates" of the session brief counts
         * the Rev A DG-10.3 canister-recovery decision, which Rev D folds into
         * DG-9.1 ("brought forward"); it is carried there as formerGateId and
         * the recovery-option attributes, not as a separate gate. Milestones
         * M0-M8 are in MilestoneSet (MTL v8.5 numbering, final report Fig. 2).
         *
         * Conventions:
         * - criterion: the Decision Framework Rev D text, verbatim modulo an
         *   ASCII transliteration (subscripts as digits, "->" for arrows,
         *   ">=" / "<=" for the comparison signs, "x" for the multiplication
         *   sign, "deg" for the degree sign); the source line stays the
         *   authority for the typography.
         * - criterionAsModelled: the comparison the referenced calc def
         *   implements and the Python vector it reads (tools/plan_check.py).
         * - declaredPhase: the phase section the Decision Framework lists the
         *   gate under (mechanical rule, so the register is auditable);
         *   declaredYear (and declaredYearEnd for a range) the year the gate
         *   text gives; declaredPhaseAlternate a second phase the document
         *   itself states for the gate ("executed during P12", a differently
         *   numbered id, or a baseline document's phase). The phase the year
         *   implies by SelenitePhases::ProgrammeTimeline is computed by
         *   plan_check, not stored - "a gate with two declared phases carries
         *   both" (session rule).
         * - evaluability by abstract subtype: DerivableGate (a condition on
         *   quantities the Python layer computes, or is expected to at Wave 5;
         *   plan_check prints "unevaluated" where the vector is missing),
         *   TestOutcomeGate (a demonstration or measurement whose result the
         *   plan assumes: assumedOutcome = true, so the plan is conditional on
         *   declared assumptions and says so), ExogenousGate (a policy input or
         *   scheduled build event; where its year is a ProgrammeParameters
         *   attribute, derivedYear is bound to it in SeleniteConfigurations).
         * - derivedPhase stays UNBOUND in every gate (Wave 5 binds it from the
         *   planner); phase attributes of elements bind to it in
         *   SeleniteConfigurations, so "timing is not gated on a predetermined
         *   phase where a condition on model data decides it" (Jason, 14 Sep
         *   2026) is literal in the model.
         * - prerequisites and gatedElements are strings naming gate ids and
         *   model elements (a dependency graph for the diagrams and the
         *   checker, not a semantic link - Wave 4 may promote them).
         * - consequenceIfNotMet is the Strategy v3.1 s.16 wording where that
         *   table has a row for the gate.
         * Sources: SEL-DECISION-001 Rev D s.2, s.3, s.4, s.9, s.10.2;
         * SEL-T1.1-STRATEGY v3.1 s.16 (and s.7.4 for DG-POST); ECN-020;
         * ARCHITECTURE_BASELINE.md s.1; SEL_ROBOT_FLEET_v9.md; SEL_FINAL_REPORT_v4
         * Figs. 2, 33, 34. Rev C -> Rev D changed no gate in s.2 (F1). */

    private import ScalarValues::*;
    private import SeleniteAnalysis::*;
    private import SelenitePhases::*;

    enum def GateEvaluability {
        doc /* derivable: a condition on quantities the Python layer computes
             * (or is expected to compute at Wave 5); testOutcome: a
             * demonstration or measurement whose result is an assumption the
             * plan declares; exogenous: a policy input or scheduled event. */
        derivable; testOutcome; exogenous;
    }

    abstract part def DecisionGate {
        doc /* One decision gate. declaredPhase is the phase the documents
             * attach; derivedPhase is what the planner computes (unbound until
             * Wave 5); the checker compares the two and prints the register. */
        attribute gateId : String;
        attribute formerGateId : String [0..1];
        attribute criterion : String;
        attribute criterionAsModelled : String [0..1];
        abstract attribute evaluability : GateEvaluability;
        abstract attribute declaredPhase : Phase;
        abstract attribute declaredPhaseAlternate : Phase [0..1];
        attribute declaredYear : Real [0..1];
        attribute declaredYearEnd : Real [0..1];
        abstract attribute derivedPhase : Phase [0..1];
        attribute derivedYear : Integer [0..1];
        attribute assumedOutcome : Boolean [0..1];
        attribute prerequisites : String [0..*];
        attribute gatedElements : String [0..*];
        attribute consequenceIfNotMet : String [0..1];
    }

    abstract part def DerivableGate :> DecisionGate {
        doc /* A gate whose criterion is a comparison on quantities: it owns one
             * or more calc usages typed by SeleniteAnalysis calc defs and
             * criterionAsModelled names the vectors. Boolean calc inputs (test
             * outcomes folded into the comparison) are assumed true where
             * assumedOutcome is bound. */
        attribute redefines evaluability = GateEvaluability::derivable;
    }

    abstract part def TestOutcomeGate :> DecisionGate {
        doc /* A gate whose criterion is a demonstration, measurement or review
             * result. The plan is conditional on the declared assumption: with
             * assumedOutcome = true the gate passes in its declared phase and
             * everything it gates follows; set false to plan the alternative
             * (consequenceIfNotMet). */
        attribute redefines evaluability = GateEvaluability::testOutcome;
        attribute redefines assumedOutcome = true;
    }

    abstract part def ExogenousGate :> DecisionGate {
        doc /* A gate that is a policy decision or a scheduled build event, not
             * a condition on model data. Where the Decision Framework's year is
             * a ProgrammeParameters attribute (asteroid captures), derivedYear
             * is bound to that attribute in SeleniteConfigurations. */
        attribute redefines evaluability = GateEvaluability::exogenous;
    }

    // =====================================================================
    // P0 - Pre-deployment (Y0-Y3)
    // =====================================================================

    part def DgZeroOne :> ExogenousGate {
        doc /* Decision Framework Rev D P0 "Gates: DG-0.1 Programme GO". No
             * year given. The programme's existence decision; nothing in the
             * model precedes it. */
        attribute redefines gateId = "DG-0.1";
        attribute redefines criterion = "Programme GO";
        attribute redefines declaredPhase = Phase::P0;
        attribute redefines gatedElements = ("EarthNode.existsFrom", "RelayConstellation.builtIn", "EarthOpsHubTier.introducedIn");
    }

    part def DgZeroTwo :> ExogenousGate {
        doc /* P0 "DG-0.2 Relay architecture". Three EML-2 relay satellites is
             * the architecture the model enumerates (RelayConstellation). */
        attribute redefines gateId = "DG-0.2";
        attribute redefines criterion = "Relay architecture";
        attribute redefines declaredPhase = Phase::P0;
        attribute redefines prerequisites = ("DG-0.1");
        attribute redefines gatedElements = ("RelayConstellation.relaySatellites[3]", "DG-1.1");
    }

    part def DgZeroThree :> ExogenousGate {
        doc /* P0 "DG-0.3 Robot fleet design freeze". Freezes the P1-P3 fleet
             * (fleet v9 authority). */
        attribute redefines gateId = "DG-0.3";
        attribute redefines criterion = "Robot fleet design freeze";
        attribute redefines declaredPhase = Phase::P0;
        attribute redefines prerequisites = ("DG-0.1");
        attribute redefines gatedElements = ("SeleniteFleet (P1-P3 classes: ProbeScout, Survey, MoleS, Sinter, ArmC, SentinelRover, MoleIMkI, ArmD, ProbeMkI)");
    }

    part def DgZeroFour :> ExogenousGate {
        doc /* P0 "DG-0.4 FSP spec lock". */
        attribute redefines gateId = "DG-0.4";
        attribute redefines criterion = "FSP spec lock";
        attribute redefines declaredPhase = Phase::P0;
        attribute redefines prerequisites = ("DG-0.1");
        attribute redefines gatedElements = ("FissionSurfacePower", "PktFspField");
    }

    // =====================================================================
    // P1-P3 - Launch, construction, early ISRU (Y2-Y7)
    // =====================================================================

    part def DgOneOne :> TestOutcomeGate {
        doc /* "DG-1.1 (Y2): Relay validated -> cargo launch clearance". The
             * first cargo landing makes SPA exist (CrewedHub.existsFrom = P1)
             * and dispatches PROBE-Scout and SURVEY. */
        attribute redefines gateId = "DG-1.1";
        attribute redefines criterion = "Relay validated -> cargo launch clearance";
        attribute redefines declaredPhase = Phase::P1;
        attribute redefines declaredYear = 2.0;
        attribute redefines prerequisites = ("DG-0.2", "RelayConstellation.existsFrom");
        attribute redefines gatedElements = ("CrewedHub.existsFrom", "StarshipCargoLink.operationalFrom", "ProbeScout.introducedIn", "Survey.introducedIn");
    }

    part def DgTwoOne :> TestOutcomeGate {
        doc /* "DG-2.1 (Y4): MOLE-I extraction rate >= 5,692 kg/yr/unit
             * confirmed". A measurement on the first units on the floor; the
             * threshold is GateThresholds.moleIYieldKgPerYear, equal to VERIFY
             * v5.0 mi.prop_yield, so a confirmed shortfall is an ECN to the
             * whole fleet-sizing chain (Strategy v3.1 s.16 "PSR ice fraction":
             * pessimistic 3.0 % -> -33 % yield -> +10 MOLE-I at P7+). */
        attribute redefines gateId = "DG-2.1";
        attribute redefines criterion = "MOLE-I extraction rate >= 5,692 kg/yr/unit confirmed";
        attribute redefines criterionAsModelled = "MoleIYieldGate: measured yield >= GateThresholds.moleIYieldKgPerYear (5,692 = VERIFY mi.prop_yield)";
        attribute redefines declaredPhase = Phase::P2;
        attribute redefines declaredYear = 4.0;
        attribute redefines prerequisites = ("MoleIMkI.introducedIn", "PsrNetwork.introducedIn");
        attribute redefines gatedElements = ("MoleI fleet growth from P4 (VERIFY ph.mi)");
        attribute redefines consequenceIfNotMet = "Pessimistic 3.0% ice -> -33% yield -> +10 MOLE-I at P7+ (Strategy v3.1 s.16)";
        calc yieldCheck : MoleIYieldGate;
    }

    part def DgTwoTwo :> TestOutcomeGate {
        doc /* "DG-2.2 (Y5): ISRU loop closed -> SKIP first hop cleared (M70)".
             * M70 = Y5.8. The model's first SKIP is P4 (fleet v9; VERIFY ph.nS
             * = 0 at P3, 1 at P4) while this clearance and Strategy v3.1 s.6
             * ("P3 (M70+) 1 SKIP pro-rated") sit in P3 - the register shows
             * it (W3-N9). */
        attribute redefines gateId = "DG-2.2";
        attribute redefines criterion = "ISRU loop closed -> SKIP first hop cleared (M70)";
        attribute redefines declaredPhase = Phase::P2;
        attribute redefines declaredYear = 5.0;
        attribute redefines prerequisites = ("DG-2.1", "IsruPlant.introducedIn");
        attribute redefines gatedElements = ("Skip.introducedIn", "SkipHopLink.operationalFrom");
        attribute redefines consequenceIfNotMet = "SKIP delayed; P3/P4 slip (Strategy v3.1 s.16 'ISRU verification (Y5.5)')";
    }

    part def DgThreeOne :> TestOutcomeGate {
        doc /* "DG-3.1 (Y5.5): SENTINEL structural sweep -> hab pressurisation
             * cleared". Precedes DG-4.1. */
        attribute redefines gateId = "DG-3.1";
        attribute redefines criterion = "SENTINEL structural sweep -> hab pressurisation cleared";
        attribute redefines declaredPhase = Phase::P3;
        attribute redefines declaredYear = 5.5;
        attribute redefines prerequisites = ("HabitatComplex.introducedIn", "SentinelRover.introducedIn");
        attribute redefines gatedElements = ("HabitatComplex pressurisation", "DG-4.1");
    }

    part def DgThreeTwo :> DerivableGate {
        doc /* "DG-3.2 (Y6): ISRU steady state -> PROBE fleet ISRU-fuelled
             * (>70%)". Derivable half: VERIFY v5.0 ph.isru >= ph.dT (supply
             * covers the whole fleet demand); the 70 % fuelling fraction is
             * not a Python vector (GateThresholds.probeIsruFuelledFraction
             * records it). */
        attribute redefines gateId = "DG-3.2";
        attribute redefines criterion = "ISRU steady state -> PROBE fleet ISRU-fuelled (>70%)";
        attribute redefines criterionAsModelled = "IsruSupplyMarginGate: VERIFY ph.isru >= ph.dT in the phase (P3..P7)";
        attribute redefines declaredPhase = Phase::P3;
        attribute redefines declaredYear = 6.0;
        attribute redefines prerequisites = ("DG-2.2");
        attribute redefines gatedElements = ("ProbeMkI.isruFuelledFrom (partial)");
        calc marginCheck : IsruSupplyMarginGate;
    }

    // =====================================================================
    // P4 - Crew arrival (Y7-Y9)
    // =====================================================================

    part def DgFourOne :> TestOutcomeGate {
        doc /* "DG-4.1 (Y7): SENTINEL crew sign-off -> crew launch authorised".
             * Crew-1 (4) arrives M82 (ARCHITECTURE_BASELINE.md s.2). Everything
             * that needs crew present binds to this gate. */
        attribute redefines gateId = "DG-4.1";
        attribute redefines criterion = "SENTINEL crew sign-off -> crew launch authorised";
        attribute redefines declaredPhase = Phase::P4;
        attribute redefines declaredYear = 7.0;
        attribute redefines prerequisites = ("DG-3.1", "SpaLandingZone.introducedIn");
        attribute redefines gatedElements = ("CrewedHub.crewedFrom", "CrewedHub.opsHubFrom", "HabitatComplex.crewedFrom", "CrewReturnVehicle.introducedIn", "Cap.introducedIn", "CrewWinch.introducedIn", "CapGuideCable.introducedIn", "PsrFloor.contingencyCrewAccessFrom", "SentinelEdgeTier.supervisedFromSpaFrom");
    }

    part def DgFourTwo :> TestOutcomeGate {
        doc /* "DG-4.2 (Y7): Life support commissioning (3-4 weeks)". */
        attribute redefines gateId = "DG-4.2";
        attribute redefines criterion = "Life support commissioning (3-4 weeks)";
        attribute redefines declaredPhase = Phase::P4;
        attribute redefines declaredYear = 7.0;
        attribute redefines prerequisites = ("DG-4.1");
        attribute redefines gatedElements = ("Eclss.introducedIn", "O2SupplyLineMonitoringFunction.introducedIn");
    }

    part def DgFourThree :> DerivableGate {
        doc /* "DG-4.3 (Y8): PROBE fleet fully ISRU-fuelled". VERIFY v5.0
             * ph.isru >= ph.dP (PROBE demand) - true from P3 on the v5.0
             * profile (the P3 units are Earth-fuelled by policy). Binds
             * ProbeMkI.isruFuelledFrom and IsruPlant.selfSufficientFrom. */
        attribute redefines gateId = "DG-4.3";
        attribute redefines criterion = "PROBE fleet fully ISRU-fuelled";
        attribute redefines criterionAsModelled = "IsruSupplyMarginGate: VERIFY ph.isru >= ph.dP in the phase";
        attribute redefines declaredPhase = Phase::P4;
        attribute redefines declaredYear = 8.0;
        attribute redefines prerequisites = ("DG-3.2");
        attribute redefines gatedElements = ("ProbeMkI.isruFuelledFrom", "IsruPlant.selfSufficientFrom");
        calc marginCheck : IsruSupplyMarginGate;
    }

    // =====================================================================
    // P5 - Fleet expansion + first exports (Y9-Y12)
    // =====================================================================

    part def DgFiveOne :> DerivableGate {
        doc /* "DG-5.1 (Y9): DART first PKT mission via LLO (M127)". The
             * mission is feasible when the ISRU margin covers the DART
             * propellant (12,370 kg, VERIFY dart.prop, inside ph.dT at P5).
             * Strategy v3.1 s.16 "DART PKT ground truth (M127)". */
        attribute redefines gateId = "DG-5.1";
        attribute redefines criterion = "DART first PKT mission via LLO (M127)";
        attribute redefines criterionAsModelled = "IsruSupplyMarginGate: VERIFY ph.isru >= ph.dT with the DART mission (ph.dD) included, from P5";
        attribute redefines declaredPhase = Phase::P5;
        attribute redefines declaredYear = 9.0;
        attribute redefines prerequisites = ("DG-4.3");
        attribute redefines gatedElements = ("Dart.introducedIn");
        attribute redefines consequenceIfNotMet = "PKT base does not proceed (Strategy v3.1 s.16)";
        calc marginCheck : IsruSupplyMarginGate;
    }

    part def DgFiveTwo :> ExogenousGate {
        doc /* "DG-5.2 (Y10): Beneficiation online (M105)". Build event. */
        attribute redefines gateId = "DG-5.2";
        attribute redefines criterion = "Beneficiation online (M105)";
        attribute redefines declaredPhase = Phase::P5;
        attribute redefines declaredYear = 10.0;
        attribute redefines prerequisites = ("IndustrialZone.introducedIn");
        attribute redefines gatedElements = ("BeneficiationPlant.introducedIn");
    }

    part def DgFiveThree :> ExogenousGate {
        doc /* "DG-5.3 (Y10): Troilite H2SO4 pilot commissioned (M115) - first
             * in-situ chemical production." The SPA reagent pilot has no
             * element yet (SEL-REAGENT-001 Rev A is the PKT plant): TODO Wave 4. */
        attribute redefines gateId = "DG-5.3";
        attribute redefines criterion = "Troilite H2SO4 pilot commissioned (M115) - first in-situ chemical production. 5,000 kg pilot equipment, 50 kW, 1-5 t/yr H2SO4.";
        attribute redefines declaredPhase = Phase::P5;
        attribute redefines declaredYear = 10.0;
        attribute redefines prerequisites = ("DG-5.2");
        attribute redefines gatedElements = ("SPA reagent pilot (no element; TODO Wave 4)", "DG-7.4");
    }

    part def DgFiveFour :> ExogenousGate {
        doc /* "DG-5.4 (Y10): First export batch dispatched (M116)". The SPA ->
             * Earth Starship return stream (StarshipReturnLink, W2-N15) starts
             * here. */
        attribute redefines gateId = "DG-5.4";
        attribute redefines criterion = "First export batch dispatched (M116)";
        attribute redefines declaredPhase = Phase::P5;
        attribute redefines declaredYear = 10.0;
        attribute redefines prerequisites = ("DG-5.2");
        attribute redefines gatedElements = ("StarshipReturnLink.operationalFrom");
    }

    // =====================================================================
    // P6 - Processing commissioning (Y12-Y15)
    // =====================================================================

    part def DgSixOne :> ExogenousGate {
        doc /* "DG-6.1 (Y12): Processing facility commissioning readiness
             * review - NOTE: per ECN-015, the Y12 processing gate is RETIRED.
             * Processing is a core programme element, not conditional." The
             * SPA processing facility is therefore FIXED at P7 in the model,
             * not bound to this gate. */
        attribute redefines gateId = "DG-6.1";
        attribute redefines criterion = "Processing facility commissioning readiness review - NOTE: per ECN-015, the Y12 processing gate is RETIRED. Processing is a core programme element, not conditional. This review confirms readiness, it does not decide whether to build.";
        attribute redefines declaredPhase = Phase::P6;
        attribute redefines declaredYear = 12.0;
        attribute redefines gatedElements = ("SpaProcessingFacility (readiness only; phase fixed P7)");
        attribute retiredByEcn015 : Boolean = true;
    }

    part def DgSixTwo :> TestOutcomeGate {
        doc /* "DG-6.2 (Y12): Ca(OH)2 pilot commissioned (2,500 kg, 30 kW) ->
             * NaOH substitution validated". */
        attribute redefines gateId = "DG-6.2";
        attribute redefines criterion = "Ca(OH)2 pilot commissioned (2,500 kg, 30 kW) -> NaOH substitution validated";
        attribute redefines declaredPhase = Phase::P6;
        attribute redefines declaredYear = 12.0;
        attribute redefines prerequisites = ("DG-5.3");
        attribute redefines gatedElements = ("ZeroCarbonFlowsheet.calciumHydroxidePrecipitation (reagent source)", "DG-7.4");
    }

    part def DgSixThree :> TestOutcomeGate {
        doc /* "DG-6.3 (Y13-14): DART PKT missions 2-3 -> PKT grade
             * confirmation". The model carries Dart.pktSiteConfirmationIn = P7
             * and AutonomousFactory.siteConfirmedIn = P7 ("DART confirms PKT
             * site (Y22)", ARCHITECTURE_BASELINE.md s.1); the Decision
             * Framework puts grade confirmation at Y13-14 (P6) with the
             * commitment at DG-7.1 (Y20). Both recorded (W3-N10). */
        attribute redefines gateId = "DG-6.3";
        attribute redefines criterion = "DART PKT missions 2-3 -> PKT grade confirmation";
        attribute redefines declaredPhase = Phase::P6;
        attribute redefines declaredYear = 13.0;
        attribute redefines declaredYearEnd = 14.0;
        attribute redefines prerequisites = ("DG-5.1");
        attribute redefines gatedElements = ("Dart.pktSiteConfirmationIn", "AutonomousFactory.siteConfirmedIn", "DG-7.1");
    }

    part def DgSixFour :> ExogenousGate {
        doc /* "DG-6.4 (Y12): Crew-1 rotation begins (staggered 4x swaps,
             * M136-M145)". Crew policy. */
        attribute redefines gateId = "DG-6.4";
        attribute redefines criterion = "Crew-1 rotation begins (staggered 4x swaps, M136-M145)";
        attribute redefines declaredPhase = Phase::P6;
        attribute redefines declaredYear = 12.0;
        attribute redefines prerequisites = ("DG-4.1");
        attribute redefines gatedElements = ("CrewedHub crew ramp (Wave 5 vector)");
    }

    // =====================================================================
    // P7 - Proof of concept (Y18-Y25)
    // =====================================================================

    part def DgSevenOne :> DerivableGate {
        doc /* PKT commitment gate. Decision Framework Rev D: "DG-7.1 (Y20): PKT
             * base commitment - requires DART XRF from >=3 PKT sites confirming
             * >=200 ppm REE + 5-circuit processing facility producing >=0.4 t/yr
             * REO". Fleet v9 s.20.3 words it "PKT commitment (DG-7.1)" with
             * "> 500 ppm" - the Decision Framework s.10.2 resolves that as
             * ">=200 ppm, target >500 ppm". The DART half is a test outcome
             * (DG-6.3) assumed true; the throughput half is ECON reo_target
             * (0.4 t/yr is the Y25 knot, i.e. the P7/P8 boundary, not Y20). */
        attribute redefines gateId = "DG-7.1";
        attribute redefines criterion = "PKT base commitment - requires DART XRF from >=3 PKT sites confirming >=200 ppm REE + 5-circuit processing facility producing >=0.4 t/yr REO";
        attribute redefines criterionAsModelled = "PktCommitmentGate: dartSitesConfirmed >= 3 and dartReePpm >= 200 (assumed, DG-6.3) and ECON reo_target >= 0.4 t/yr";
        attribute redefines declaredPhase = Phase::P7;
        attribute redefines declaredYear = 20.0;
        attribute redefines assumedOutcome = true;
        attribute redefines prerequisites = ("DG-6.3", "SpaProcessingFacility.introducedIn");
        attribute redefines gatedElements = ("DG-8.0", "DG-8.1", "AutonomousFactory.existsFrom (via DG-8.1)", "MassDriverMd1.operationalFrom (via DG-8.0)");
        attribute redefines consequenceIfNotMet = "PKT base does not proceed (Strategy v3.1 s.16)";
        calc commitmentCheck : PktCommitmentGate;
    }

    part def DgSevenTwo :> DerivableGate {
        doc /* "DG-7.2 (Y20): Thorium recovery begins". An automatic by-product
             * of the acid bake, so it begins with the first SPA processing
             * output: ECON reo_target > 0 (first non-zero at Y19). */
        attribute redefines gateId = "DG-7.2";
        attribute redefines criterion = "Thorium recovery begins - 300 deg C acid bake ThP2O7 mechanism automatically separates Th from REE. Th(OH)4 stockpiled for future MSR fuel. U separated by oxidation + pH 6.5 precipitation. Zero additional reagents needed.";
        attribute redefines criterionAsModelled = "ThoriumRecoveryGate: ECON reo_target > 0";
        attribute redefines declaredPhase = Phase::P7;
        attribute redefines declaredYear = 20.0;
        attribute redefines prerequisites = ("SpaProcessingFacility.introducedIn");
        attribute redefines gatedElements = ("ZeroCarbonFlowsheet.thoriumConversion", "DG-8.7");
        calc recoveryCheck : ThoriumRecoveryGate;
    }

    part def DgSevenThree :> TestOutcomeGate {
        doc /* "DG-7.3 (Y20): PGM source comparison". Assumed outcome: asteroid
             * only (the baseline has no third base; Strategy v3.1 s.11). */
        attribute redefines gateId = "DG-7.3";
        attribute redefines criterion = "PGM source comparison - DART/SURVEY data vs actual PROBE returns. If lunar >10 g/t -> third-base study. If <5 g/t -> asteroid only.";
        attribute redefines declaredPhase = Phase::P7;
        attribute redefines declaredYear = 20.0;
        attribute redefines prerequisites = ("DG-5.1", "ProbeMkI.introducedIn");
        attribute redefines gatedElements = ("(no third base in the baseline: asteroid-only PGM, Strategy v3.1 s.11)");
    }

    part def DgSevenFour :> DerivableGate {
        doc /* "DG-7.4 (Y22): Progressive reagent substitution at SPA (10% ->
             * 50% in-situ H2SO4, Ca(OH)2 replaces NaOH)". ECON reagent.isru_frac
             * (y) = min(0.98, max(0, (y - 9) x 0.03)) reaches 0.5 at Y26. */
        attribute redefines gateId = "DG-7.4";
        attribute redefines criterion = "Progressive reagent substitution at SPA (10% -> 50% in-situ H2SO4, Ca(OH)2 replaces NaOH)";
        attribute redefines criterionAsModelled = "ReagentSubstitutionGate: ECON reagent.isru_frac(y) >= GateThresholds.reagentInSituFractionP7";
        attribute redefines declaredPhase = Phase::P7;
        attribute redefines declaredYear = 22.0;
        attribute redefines prerequisites = ("DG-5.3", "DG-6.2");
        attribute redefines gatedElements = ("SPA reagent production (no element; TODO Wave 4)");
        calc substitutionCheck : ReagentSubstitutionGate;
    }

    part def DgSevenFive :> TestOutcomeGate {
        doc /* Thorium MSR decision. Decision Framework Rev D P7: "DG-7.5
             * (~2040): Thorium MSR decision - commit only if terrestrial MSR
             * demonstrates sustained BR >1.0". ~2040 is programme Y15 with
             * ProgrammeParameters.programmeStartCalendarYear = 2025, i.e.
             * inside the F7 gap between P6 (ends Y15) and P7 (starts Y18) -
             * the gate may be the reason the gap exists. Listed under P7.
             * Final report Fig. 33 P8 "First MSR prototype if DG-7.5 met"
             * (W2-N11). Resolution of the kick-off question "DG-7.5
             * criterion": a terrestrial test outcome (assumed true), gating the
             * whole PKT MSR line (DG-8.9 cold structure, DG-9.3 first power,
             * DG-10.4 fleet). Strategy v3.1 s.16 consequence carried. */
        attribute redefines gateId = "DG-7.5";
        attribute redefines criterion = "Thorium MSR decision - commit only if terrestrial MSR demonstrates sustained BR >1.0";
        attribute redefines criterionAsModelled = "BreedingRatioGate: measured terrestrial BR > GateThresholds.breedingRatioMinimum";
        attribute redefines declaredPhase = Phase::P7;
        attribute redefines declaredYear = 15.0;
        attribute redefines gatedElements = ("DG-8.9", "DG-9.3", "ThoriumMSR (whole PKT MSR line)");
        attribute redefines consequenceIfNotMet = "Continue FSP-only (limits PKT scaling) (Strategy v3.1 s.16)";
        calc breedingCheck : BreedingRatioGate;
    }

    // =====================================================================
    // P8 - Mass driver + PKT base online (Y25-Y35)
    // =====================================================================

    part def DgEightZero :> ExogenousGate {
        doc /* "DG-8.0 (Y25): SPA->PKT mass driver operational" - ECN-020 MD-1
             * (2 tracks), baseline P8. Transcribed from the computational
             * authority: ECON v1.3 cargo_ybco ships 30 t at Y22 and 30 t at
             * Y23 (the "~30-60 t YBCO installed during P7"). */
        attribute redefines gateId = "DG-8.0";
        attribute redefines criterion = "SPA->PKT mass driver operational - ~1,800 m/s, ~3.3 km track at SPA. Carries Fe-Ni from PROBE returns, Th(OH)4, spares. ~30-60 t YBCO installed during P7. CRITICAL PATH ITEM.";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 25.0;
        attribute redefines prerequisites = ("DG-7.1", "MassDriverDemonstrator.introducedIn");
        attribute redefines gatedElements = ("MassDriverMd1.operationalFrom", "MassDriverNetwork.introducedIn", "InterSiteCargoCanister");
        attribute econYbcoCargoYears : Integer [0..*] = (22, 23);
    }

    part def DgEightOne :> ExogenousGate {
        doc /* "DG-8.1 (Y25): PKT construction begins - Wave 1 Starships deliver
             * SINTER + haulers (w/ bucket) + ARM-C + FSP directly to PKT". The
             * consequence of DG-7.1 that makes the PKT node exist: every P8
             * PKT element binds here. ECON cargo_construction has the Wave 1
             * manifest at Y25. */
        attribute redefines gateId = "DG-8.1";
        attribute redefines criterion = "PKT construction begins - Wave 1 Starships deliver SINTER + haulers (w/ bucket) + ARM-C + FSP directly to PKT (Earth->PKT, NOT via SPA)";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 25.0;
        attribute redefines prerequisites = ("DG-7.1");
        attribute redefines gatedElements = ("AutonomousFactory.existsFrom", "PktRelaySatellite.existsFrom", "PktLandingZone.introducedIn", "HaulerRevB.introducedIn", "HaulerRoadNetwork.operationalFrom", "PktFspField.introducedIn", "PktPowerSystem.introducedIn", "HubChargingStation.introducedIn", "PktProcessingSpine.introducedIn", "Sinter.pktFrom", "ArmC.pktFrom", "SentinelRover.pktFrom", "Dart.pktBasedFrom", "StarshipCargoLink.pktDeliveriesFrom", "SentinelEdgeTier.pktSupervisedFromSpaFrom");
    }

    part def DgEightTwo :> DerivableGate {
        doc /* "DG-8.2 (Y27): First 100 processing circuits operational". ECON
             * circuits_needed >= 100 (first at Y28: 105). */
        attribute redefines gateId = "DG-8.2";
        attribute redefines criterion = "First 100 processing circuits operational";
        attribute redefines criterionAsModelled = "CircuitCountGate: ECON circuits_needed >= GateThresholds.circuitsFirstTranche";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 27.0;
        attribute redefines prerequisites = ("DG-8.1", "DG-8.3");
        attribute redefines gatedElements = ("PktProcessingSpine (first tranche)");
        calc countCheck : CircuitCountGate;
    }

    part def DgEightThree :> ExogenousGate {
        doc /* "DG-8.3 (Y25): PKT reagent plant commissioned - 80 t, 500 kW, 85%
             * self-sufficiency from day one". Build event (Wave 1 manifest). */
        attribute redefines gateId = "DG-8.3";
        attribute redefines criterion = "PKT reagent plant commissioned - 80 t, 500 kW, 85% self-sufficiency from day one";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 25.0;
        attribute redefines prerequisites = ("DG-8.1");
        attribute redefines gatedElements = ("ReagentPlant.introducedIn");
    }

    part def DgEightFour :> DerivableGate {
        doc /* "DG-8.4 (Y26): First 50 haulers operational at PKT". ECON
             * haulers_needed >= 50 (first at Y28: 167). ECON derives haulers
             * from regolith_yr = reo_target / 500 ppm from Y19, i.e. it
             * assigns haulers to the SPA research output too (W3-N8); the
             * threshold hides that artefact. */
        attribute redefines gateId = "DG-8.4";
        attribute redefines criterion = "First 50 haulers operational at PKT (Earth-built, off-road initially, Na-S battery, SRM motors)";
        attribute redefines criterionAsModelled = "HaulerFleetGate: ECON haulers_needed >= GateThresholds.haulersFirstTranche";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 26.0;
        attribute redefines prerequisites = ("DG-8.1");
        attribute redefines gatedElements = ("HaulerRevB fleet (Wave 5 vector)", "HubChargingStation");
        calc fleetCheck : HaulerFleetGate;
    }

    part def DgEightFive :> DerivableGate {
        doc /* "DG-8.5 (Y28): 308 processing circuits complete; 125 t/yr REO".
             * Evaluated on REO (ECON reo_target reaches 125 at Y28); the
             * circuit count is design-dependent: 308 x 0.4 t/yr (batch) = 123
             * t/yr, while the committed 1.2 t/yr circuit needs 105 (ECON
             * circuits_needed at Y28). The Decision Framework's P8 count is
             * therefore the batch-design figure (W3-N3). Both calcs attached. */
        attribute redefines gateId = "DG-8.5";
        attribute redefines criterion = "308 processing circuits complete; 125 t/yr REO";
        attribute redefines criterionAsModelled = "ReoOutputGate: ECON reo_target >= GateThresholds.reoTonnesPerYearP8; CircuitCountGate: circuits_needed >= GateThresholds.circuitsP8Complete";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 28.0;
        attribute redefines prerequisites = ("DG-8.2");
        attribute redefines gatedElements = ("PktProcessingSpine (P8 build-out)");
        calc outputCheck : ReoOutputGate;
        calc countCheck : CircuitCountGate;
    }

    part def DgEightSix :> ExogenousGate {
        doc /* "DG-8.6 (Y28): PKT temporary commissioning crew arrives - 3-4
             * specialists, 6-12 months (Wave 3)". Policy: the SEL-REQ-002
             * exception (ProgrammeParameters.pktTemporaryCommissioningCrewMax).
             * Introduces and retires PktTemporaryCrewHab within P8. */
        attribute redefines gateId = "DG-8.6";
        attribute redefines criterion = "PKT temporary commissioning crew arrives - 3-4 specialists, 6-12 months (Wave 3). Tasks: commission foundry pilot, build MSR cold structure, tune processing circuits with real regolith. Crew departs before MSR fuel loading.";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 28.0;
        attribute redefines prerequisites = ("DG-8.1", "DG-8.2");
        attribute redefines gatedElements = ("PktTemporaryCrewHab.introducedIn", "Foundry.introducedIn (pilot)", "DG-8.8", "DG-8.9");
    }

    part def DgEightSeven :> DerivableGate {
        doc /* "DG-8.7 (Y30): Thorium stockpile assessment (~40 t Th(OH)4
             * accumulated)". No thorium vector in the Python layer:
             * unevaluated until Wave 5 (ProgrammeParameters.
             * thoriumHydroxideStockpileByYear). */
        attribute redefines gateId = "DG-8.7";
        attribute redefines criterion = "Thorium stockpile assessment (~40 t Th(OH)4 accumulated)";
        attribute redefines criterionAsModelled = "ThoriumStockpileGate: cumulative Th(OH)4 >= GateThresholds.thoriumStockpileTonnes - no vector (unevaluated)";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 30.0;
        attribute redefines prerequisites = ("DG-7.2");
        attribute redefines gatedElements = ("DG-8.9 (fuel inventory)");
        calc stockpileCheck : ThoriumStockpileGate;
    }

    part def DgEightEight :> ExogenousGate {
        doc /* "DG-8.8 (Y30): EM catapult demonstrator hub - 500 m/s, ~23 t
             * YBCO. Proving ground for PKT->Earth mass driver." The Decision
             * Framework and Strategy v3.1 s.7.2 (Wave 3) place the 23 t
             * demonstrator at PKT in Y28-30; the model's MassDriverDemonstrator
             * is on the SPA rim at P7 from final report Fig. 27 (W2-N17). Two
             * demonstrators or one relocated is not decided: the element stays
             * fixed at P7 and the conflict is recorded (W3-N11). */
        attribute redefines gateId = "DG-8.8";
        attribute redefines criterion = "EM catapult demonstrator hub - 500 m/s, ~23 t YBCO. Proving ground for PKT->Earth mass driver.";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredPhaseAlternate = Phase::P7;
        attribute redefines declaredYear = 30.0;
        attribute redefines prerequisites = ("DG-8.6");
        attribute redefines gatedElements = ("MassDriverDemonstrator (location conflict W3-N11)", "DG-9.1");
    }

    part def DgEightNine :> ExogenousGate {
        doc /* "DG-8.9 (Y32): First MSR cold structure complete. Fuel loading
             * autonomous after crew departure. HALEU startup charge from Earth
             * (sealed, shielded)." Build event conditional on DG-7.5. */
        attribute redefines gateId = "DG-8.9";
        attribute redefines criterion = "First MSR cold structure complete. Fuel loading autonomous after crew departure. HALEU startup charge from Earth (sealed, shielded).";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 32.0;
        attribute redefines prerequisites = ("DG-7.5", "DG-8.6");
        attribute redefines gatedElements = ("ThoriumMSR (cold structure)", "DG-9.3");
    }

    part def DgEightX :> TestOutcomeGate {
        doc /* Circuit validation before full PKT commitment: Decision Framework
             * Rev D "DG-8.X (Y28)" (also s.4 and Strategy v3.1 s.10.2, s.16);
             * fleet v9 s.14; final report Fig. 33 P8. The per-circuit
             * throughput is a test outcome; the committed design
             * (ProgrammeParameters.circuitReoTonnesPerYear = 1.2) already
             * exceeds the 1.0 threshold in the economics. */
        attribute redefines gateId = "DG-8.X";
        attribute redefines criterion = "Circuit throughput validation - target >=1.0 t/yr REO per circuit before committing to full-scale PKT build-out. Optimised continuous-flow design at 1.2 t/yr, 28,000 kg, 400 kW is the committed baseline. This is the single highest-value design decision in the programme ($22T cost reduction over 200 years vs batch at 0.4 t/yr).";
        attribute redefines criterionAsModelled = "CircuitThroughputGate: measured t/yr per circuit >= GateThresholds.circuitThroughputMinimumTonnesPerYear (ECON commits circuit.reo_yr = 1.2)";
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines declaredYear = 28.0;
        attribute redefines prerequisites = ("DG-8.2");
        attribute redefines gatedElements = ("PktProcessingSpine (scale-up beyond 308 circuits)", "ProgrammeParameters.circuitReoTonnesPerYear", "DG-9.1");
        attribute redefines consequenceIfNotMet = "Batch design costs +$22T over 200 years (Strategy v3.1 s.16)";
        calc throughputCheck : CircuitThroughputGate;
    }

    // =====================================================================
    // P9 - Mass driver scaling + foundry ramp (Y35-Y45)
    // =====================================================================

    part def DgNineOne :> ExogenousGate {
        doc /* "DG-9.1 (Y35): PKT->Earth mass driver operational" - ECN-020 MD-2
             * (3 tracks), baseline P9. Carries the canister recovery
             * architecture decision that Rev A numbered DG-10.3 ("brought
             * forward"): options 1a / 1b / 2 open, 1b recommended; the
             * economics assumed 1b (ECON v1.3 can.earth_kg = 28, transcribed).
             * ECON cargo_ybco ships 50 t at Y35 (ECN-020: 240 t for three
             * tracks - the economics predate ECN-020, W3-N12). SKIP retirement
             * and the end of SKIP hops are consequences (fleet v9 s.7; Strategy
             * v3.1 s.6). */
        attribute redefines gateId = "DG-9.1";
        attribute redefines formerGateId = "DG-10.3 (Rev A: canister recovery architecture decision, brought forward into DG-9.1)";
        attribute redefines criterion = "PKT->Earth mass driver operational - REO canisters at ~2,400 m/s. First exports by mass driver. Canister recovery architecture decision (DG-10.3 from Rev A, brought forward): Option 1a full parachute (73 kg Earth content/canister); Option 1b minimal drag chute + hardened canister (28 kg Earth/canister) - RECOMMENDED; Option 2 shuttlecock design, no fabric (8 kg Earth/canister) - requires impact survival validation";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredYear = 35.0;
        attribute redefines prerequisites = ("DG-8.0", "DG-8.X", "DG-8.8");
        attribute redefines gatedElements = ("MassDriverMd2.operationalFrom", "ReoExportCanister", "Skip.retiredIn", "SkipHopLink.retiredIn");
        attribute redefines consequenceIfNotMet = "Full parachute (+$26B/yr vs minimal chute) (Strategy v3.1 s.16)";
        attribute canisterRecoveryOptionSelected : String [0..1];
        attribute canisterRecoveryOptionEconAssumed : String = "1b minimal drag chute - ECON v1.3 can.earth_kg = 28 kg";
        attribute econYbcoCargoYears : Integer [0..*] = (35);
    }

    part def DgNineTwo :> DerivableGate {
        doc /* "DG-9.2 (Y38): Hauler fleet scaling at PKT - 1,000+ haulers
             * operational". ECON haulers_needed >= 1,000 (Y45). */
        attribute redefines gateId = "DG-9.2";
        attribute redefines criterion = "Hauler fleet scaling at PKT - 1,000+ haulers operational";
        attribute redefines criterionAsModelled = "HaulerFleetGate: ECON haulers_needed >= GateThresholds.haulersP9";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredYear = 38.0;
        attribute redefines prerequisites = ("DG-8.4", "DG-9.4");
        attribute redefines gatedElements = ("HaulerRevB fleet (Wave 5 vector)");
        calc fleetCheck : HaulerFleetGate;
    }

    part def DgNineThree :> TestOutcomeGate {
        doc /* First thorium MSR at PKT. Decision Framework Rev D "DG-9.3 (Y40):
             * Thorium MSR first power - if BR >1.0 confirmed, commit to fleet
             * expansion"; fleet v9 s.18.2; final report Fig. 33 P9 "First MSR(s)
             * commissioned (DG-9.3)". Jason 14 Sep 2026: PKT first MSR is P9.
             * ECON msr_count first non-zero at Y38 (agrees with P9). */
        attribute redefines gateId = "DG-9.3";
        attribute redefines criterion = "Thorium MSR first power - if BR >1.0 confirmed, commit to fleet expansion";
        attribute redefines criterionAsModelled = "BreedingRatioGate: confirmed BR on ThCl4 fuel > GateThresholds.breedingRatioMinimum";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredYear = 40.0;
        attribute redefines prerequisites = ("DG-7.5", "DG-8.9", "ReagentPlant.introducedIn");
        attribute redefines gatedElements = ("ThoriumMSR.introducedIn", "DG-10.4");
        calc breedingCheck : BreedingRatioGate;
    }

    part def DgNineFour :> DerivableGate {
        doc /* "DG-9.4 (Y42): PKT foundry at 100+ t/yr metal production (MRE +
             * WAAM/EB welding)". Proxy vector: ECON insitu_total (in-situ
             * manufactured mass per year). Binds Foundry.atScaleFrom. */
        attribute redefines gateId = "DG-9.4";
        attribute redefines criterion = "PKT foundry at 100+ t/yr metal production (MRE + WAAM/EB welding)";
        attribute redefines criterionAsModelled = "FoundryOutputGate: ECON insitu_total >= GateThresholds.foundryTonnesPerYearP9 (proxy for foundry metal output)";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredYear = 42.0;
        attribute redefines prerequisites = ("DG-8.6");
        attribute redefines gatedElements = ("Foundry.atScaleFrom");
        calc outputCheck : FoundryOutputGate;
    }

    part def DgNineFive :> ExogenousGate {
        doc /* "DG-9.5 (Y42): Oxalic acid pilot at PKT (CO2 electroreduction)".
             * No element (reagent plant sub-line): TODO Wave 4. */
        attribute redefines gateId = "DG-9.5";
        attribute redefines criterion = "Oxalic acid pilot at PKT (CO2 electroreduction)";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredYear = 42.0;
        attribute redefines prerequisites = ("DG-8.3");
        attribute redefines gatedElements = ("ReagentPlant (oxalic acid line; no element, TODO Wave 4)");
    }

    part def DgNineSix :> ExogenousGate {
        doc /* "DG-9.6 (Y43): PKT->SPA mass driver operational - ThCl4 fuel for
             * SPA MSR". MD-3. The model binds MassDriverMd3 at P10 from
             * ARCHITECTURE_BASELINE.md; fleet v9 s.16 and the Decision
             * Framework s.3 give "P9-P10 (Y43)" and Y43 is P9 by the year
             * table (W2-N2): declaredPhaseAlternate = P10. A driver needs its
             * receiver, so EmCatcher (model P11, W2-N3) binds to this gate in
             * the configuration. ECON cargo_ybco ships 30 t at Y43 (the MD-3
             * allocation; agrees with Y43). */
        attribute redefines gateId = "DG-9.6";
        attribute redefines criterion = "PKT->SPA mass driver operational - ThCl4 fuel for SPA MSR";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredPhaseAlternate = Phase::P10;
        attribute redefines declaredYear = 43.0;
        attribute redefines prerequisites = ("DG-9.1");
        attribute redefines gatedElements = ("MassDriverMd3.operationalFrom", "EmCatcher.operationalFrom (receiver)", "ThCl4Canister", "DG-10.5");
        attribute econYbcoCargoYears : Integer [0..*] = (43);
    }

    part def DgNineSeven :> DerivableGate {
        doc /* "DG-9.7 (Y40): Steel conveyor pilot - first 500 km trunk from
             * Fe-Ni + MRE iron". ECON conv_km_needed >= 500 (Y66: the Tier 3
             * conveyor fraction grows 1 %/yr from Y40, so the 500 km pilot is
             * a P11 quantity in the economics). Binds SteelApronConveyor and
             * ConveyorNetwork.introducedIn. */
        attribute redefines gateId = "DG-9.7";
        attribute redefines criterion = "Steel conveyor pilot - first 500 km trunk from Fe-Ni + MRE iron";
        attribute redefines criterionAsModelled = "ConveyorLengthGate: ECON conv_km_needed >= GateThresholds.conveyorKmPilot";
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines declaredYear = 40.0;
        attribute redefines prerequisites = ("DG-9.4");
        attribute redefines gatedElements = ("SteelApronConveyor.operationalFrom", "ConveyorNetwork.introducedIn");
        calc lengthCheck : ConveyorLengthGate;
    }

    // =====================================================================
    // P10 - Full-scale operations (Y45-60)
    // =====================================================================

    part def DgTenOne :> DerivableGate {
        doc /* "DG-10.1 (Y45): Hauler fleet at scale - 14,881 mining-capable
             * haulers". ECON haulers_needed >= 14,881 (~Y63); VC-08 records
             * that the 14,881 series is SCALE v1.3. */
        attribute redefines gateId = "DG-10.1";
        attribute redefines criterion = "Hauler fleet at scale - 14,881 mining-capable haulers (Na-S battery, SRM motors, bucket/blade, ~57% in-situ)";
        attribute redefines criterionAsModelled = "HaulerFleetGate: ECON haulers_needed >= GateThresholds.haulersP10";
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines declaredYear = 45.0;
        attribute redefines prerequisites = ("DG-9.2", "DG-10.3");
        attribute redefines gatedElements = ("HaulerRevB fleet (Wave 5 vector)");
        calc fleetCheck : HaulerFleetGate;
    }

    part def DgTenTwo :> DerivableGate {
        doc /* "DG-10.2 (Y48): Steel conveyor network expanding - 5,000+ km".
             * ECON conv_km_needed >= 5,000 (~Y84). Binds
             * ConveyorNetwork.deployingFrom. */
        attribute redefines gateId = "DG-10.2";
        attribute redefines criterion = "Steel conveyor network expanding - 5,000+ km, replacing hauler Tier 3 routes (50-150 km), 95% in-situ manufactured";
        attribute redefines criterionAsModelled = "ConveyorLengthGate: ECON conv_km_needed >= GateThresholds.conveyorKmP10";
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines declaredYear = 48.0;
        attribute redefines prerequisites = ("DG-9.7");
        attribute redefines gatedElements = ("ConveyorNetwork.deployingFrom");
        calc lengthCheck : ConveyorLengthGate;
    }

    part def DgTenThree :> DerivableGate {
        doc /* "DG-10.3 (Y45): PKT foundry at industrial scale - 1,000+ t/yr
             * formed metal". Rev D numbering; in Rev A DG-10.3 was the
             * canister recovery decision now inside DG-9.1. Proxy vector ECON
             * insitu_total. */
        attribute redefines gateId = "DG-10.3";
        attribute redefines criterion = "PKT foundry at industrial scale - MRE cells, WAAM/EB welding, Fe-Si and Al production. 1,000+ t/yr formed metal.";
        attribute redefines criterionAsModelled = "FoundryOutputGate: ECON insitu_total >= GateThresholds.foundryTonnesPerYearP10 (proxy)";
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines declaredYear = 45.0;
        attribute redefines prerequisites = ("DG-9.4");
        attribute redefines gatedElements = ("Foundry (industrial scale)");
        calc outputCheck : FoundryOutputGate;
    }

    part def DgTenFour :> DerivableGate {
        doc /* MSR fleet replaces the PKT FSP field. Decision Framework Rev D
             * "DG-10.4 (Y50): Thorium MSR fleet expansion - ~74 x 100 MWe units
             * at PKT"; final report Fig. 33 P10 "MSR fleet ~74 x 100 MWe
             * (DG-10.4) replaces FSP". Two consequences: the fleet count
             * (MsrFleetGate on ECON msr_count) and the FSP field retirement
             * (PktFspRetirementGate: MSR installed power >= FSP installed
             * power, ECON msr_count x 100 MWe vs fsp_count x 40 kW), which
             * binds PktFspField.retiredIn and ThoriumMSR.replacesPktFspFrom. */
        attribute redefines gateId = "DG-10.4";
        attribute redefines criterion = "Thorium MSR fleet expansion - ~74 x 100 MWe units at PKT. Construction: temp crew builds cold structure, fuel loading autonomous.";
        attribute redefines criterionAsModelled = "MsrFleetGate: ECON msr_count >= GateThresholds.msrUnitsP10; PktFspRetirementGate: msr_count x 100 MWe >= fsp_count x 40 kWe";
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines declaredYear = 50.0;
        attribute redefines prerequisites = ("DG-9.3");
        attribute redefines gatedElements = ("PktFspField.retiredIn", "ThoriumMSR.replacesPktFspFrom");
        calc fleetCheck : MsrFleetGate;
        calc fspRetirementCheck : PktFspRetirementGate;
    }

    part def DgTenFive :> DerivableGate {
        doc /* SPA MSR commissioned. FLAG F5: Decision Framework Rev D itself
             * carries THREE commissioning gates for the SPA MSR - DG-10.5
             * (Y50) "SPA MSR commissioning", DG-11.3 (Y70) "SPA MSR
             * commissioning", DG-13.4 (Y105) "SPA MSR #1 commissioned" - plus
             * DG-14.4 (Y125) "#2" and DG-14.7 (Y140) "#3"; Strategy v3.1
             * s.5.1 says "SPA MSR from Y105" and s.12.1 "from Y50" (W2-N20).
             * This is why the gate is DERIVABLE via SeleniteAnalysis::
             * SpaMsrIntroductionGate and not transcribed; the ECON v2.1
             * golden's cargo_spa_msr / spa_msr_count vectors record what the
             * economics assumed (first unit Y105, see CHANGELOG_WAVE3.md).
             * declaredPhase keeps the earliest label as the candidate. The SPA
             * demand vector beyond P7 is not in the Python layer yet:
             * unevaluated at Wave 3. */
        attribute redefines gateId = "DG-10.5";
        attribute redefines criterion = "SPA MSR commissioning - ThCl4 mass-driven from PKT. Enables scaled PROBE/PGM ops.";
        attribute redefines criterionAsModelled = "SpaMsrIntroductionGate: SPA demand > solar + FSP + battery capability, ThCl4 supply available (MD-3), MSR deployable at the crewed base - no SPA demand vector beyond P7 (unevaluated); ECON spa_msr_count first unit Y105";
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines declaredYear = 50.0;
        attribute redefines prerequisites = ("MassDriverMd3.operationalFrom", "DG-9.3", "DG-9.6");
        attribute redefines gatedElements = ("SpaThoriumMSR.introducedIn");
        attribute econAssumedIntroductionYear : Integer = 105;
        calc introductionCheck : SpaMsrIntroductionGate;
    }

    // =====================================================================
    // P11 - 10% global displacement + PROBE Mk III transition (Y60-80)
    // =====================================================================

    part def DgElevenOne :> DerivableGate {
        doc /* "DG-11.1 (Y60): 100,000 t/yr REO -> market impact assessment".
             * ECON reo_target reaches 100,000 at Y80 (P12) and supply_frac
             * reaches 0.10 at Y100: the economics' ramp is one knot later than
             * the Decision Framework's REO gates (W3-N4). */
        attribute redefines gateId = "DG-11.1";
        attribute redefines criterion = "100,000 t/yr REO -> market impact assessment";
        attribute redefines criterionAsModelled = "ReoOutputGate: ECON reo_target >= GateThresholds.reoTonnesPerYearP11; MarketShareGate: supply_frac >= GateThresholds.displacementFractionP11";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines declaredYear = 60.0;
        attribute redefines prerequisites = ("DG-10.1", "DG-10.4");
        attribute redefines gatedElements = ("(market impact assessment; no element)");
        calc outputCheck : ReoOutputGate;
        calc shareCheck : MarketShareGate;
    }

    part def DgElevenTwo :> DerivableGate {
        doc /* "DG-11.2 (Y65): Thorium MSR fleet at ~679 x 100 MWe". ECON
             * msr_count >= 679 at ~Y96 (P12). */
        attribute redefines gateId = "DG-11.2";
        attribute redefines criterion = "Thorium MSR fleet at ~679 x 100 MWe. Annual Th consumption ~54 t/yr vs 387-773 t/yr production (massive surplus for stockpiling/SPA fuel).";
        attribute redefines criterionAsModelled = "MsrFleetGate: ECON msr_count >= GateThresholds.msrUnitsP11";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines declaredYear = 65.0;
        attribute redefines prerequisites = ("DG-10.4");
        attribute redefines gatedElements = ("ThoriumMSR fleet (Wave 5 vector)");
        calc fleetCheck : MsrFleetGate;
    }

    part def DgElevenThree :> DerivableGate {
        doc /* "DG-11.3 (Y70): SPA MSR commissioning - ThCl4 mass-driven from
             * PKT. Enables scaled PGM processing." The second of the five SPA
             * MSR gates (W2-N20, F5); same calc as DG-10.5. */
        attribute redefines gateId = "DG-11.3";
        attribute redefines criterion = "SPA MSR commissioning - ThCl4 mass-driven from PKT. Enables scaled PGM processing.";
        attribute redefines criterionAsModelled = "SpaMsrIntroductionGate (as DG-10.5) - unevaluated; ECON spa_msr_count first unit Y105";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines declaredYear = 70.0;
        attribute redefines prerequisites = ("DG-9.6");
        attribute redefines gatedElements = ("SpaThoriumMSR.introducedIn (duplicate of DG-10.5, W2-N20)");
        calc introductionCheck : SpaMsrIntroductionGate;
    }

    part def DgElevenFour :> TestOutcomeGate {
        doc /* "DG-11.4 (Y75): In-situ Ni-201 MSR vessels replace Hastelloy-N
             * for new builds". A qualification outcome. ECON msr.earth_frac
             * declines 2 %/yr from Y45 to its 0.30 floor at Y80 (the
             * economics' rendering of the substitution). Binds
             * ThoriumMSR.inSituVesselsFrom. */
        attribute redefines gateId = "DG-11.4";
        attribute redefines criterion = "In-situ Ni-201 MSR vessels replace Hastelloy-N for new builds -> reduces single largest specialty import.";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines declaredYear = 75.0;
        attribute redefines prerequisites = ("DG-10.3");
        attribute redefines gatedElements = ("ThoriumMSR.inSituVesselsFrom");
    }

    part def DgElevenFive :> DerivableGate {
        doc /* "DG-11.5: Conveyor network scales to ~15,000 km" (no year
             * given). ECON conv_km_needed >= 15,000 at ~Y103 (P12). */
        attribute redefines gateId = "DG-11.5";
        attribute redefines criterion = "Conveyor network scales to ~15,000 km";
        attribute redefines criterionAsModelled = "ConveyorLengthGate: ECON conv_km_needed >= GateThresholds.conveyorKmP11";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines prerequisites = ("DG-10.2");
        attribute redefines gatedElements = ("ConveyorNetwork (Wave 5 km vector)");
        calc lengthCheck : ConveyorLengthGate;
    }

    part def DgElevenSix :> DerivableGate {
        doc /* PROBE Mk III SEP commissioned; MD-4 SPA->Earth PGM exports.
             * Decision Framework Rev D "DG-11.6 (Y65-75)"; baseline P11; fleet
             * v9 s.2.4. Two derivable consequences: (a) the Mk III transition
             * is forced when the chemical PROBE fleet's MOLE-I need exceeds
             * the PSR floor capacity (ECON molei_needed vs ProgrammeParameters.
             * psrMoleICapacityUnits = 620 from psr_layout; the fleet v9 figure
             * 310 is reported alongside, W2-N18) - on the 620 capacity the
             * ECON peak of 357 never forces it; (b) MD-4 is triggered when PGM
             * concentrate exceeds ~100 t/yr (ECON total_pgm peaks near 52
             * t/yr, so the trigger as written is never met on the current
             * economics - W3-N2). Both are register rows, not decisions. */
        attribute redefines gateId = "DG-11.6";
        attribute redefines criterion = "PROBE Mk III SEP commissioning + SPA->Earth mass driver for PGM exports. Mk III: ion propulsion, ~1,200 kg dry, never lands on the Moon; ejects 10 t Fe-Ni/PGM payload canisters from LLO to the EM catcher at SPA (~1,680 m/s); electromagnetic anchoring on M-type Fe-Ni; build-out ~86 Mk III/yr from Y60-Y80 -> ~1,714 units, reducing to ~300 after all asteroid captures complete (Y115+); Mk I/II phasedown 260->50 (Y60-Y80), then ->30 (Y85+). SPA->Earth mass driver triggered when PGM concentrate volume exceeds ~100 t/yr.";
        attribute redefines criterionAsModelled = "MkIiiTransitionGate: ECON molei_needed > ProgrammeParameters.psrMoleICapacityUnits; PgmExportDriverGate: ECON total_pgm > GateThresholds.pgmExportTriggerTonnesPerYear";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines declaredYear = 65.0;
        attribute redefines declaredYearEnd = 75.0;
        attribute redefines prerequisites = ("ProbeMkII.introducedIn", "EmCatcher.introducedIn", "DG-9.6");
        attribute redefines gatedElements = ("ProbeMkIII.introducedIn", "MassDriverMd4.operationalFrom", "PgmExportCanister", "ProbeMkI.retiredIn", "MoleIMkII.declineDrivenByMkIIIFrom", "ProbeReturnLink.mkIiiCanisterStreamFrom", "StarshipReturnLink.retiredIn (via MD-4)");
        attribute redefines consequenceIfNotMet = "Chemical-only fleet caps at ~355 MOLE-I (Strategy v3.1 s.16)";
        calc transitionCheck : MkIiiTransitionGate;
        calc exportDriverCheck : PgmExportDriverGate;
    }

    part def DgElevenSeven :> ExogenousGate {
        doc /* "DG-11.7: PROBE fleet scaling - docking collars and ARM-D units
             * at SPA IZ scale linearly with fleet growth" (no year). A design
             * rule, carried structurally by ArmD.countLockedToDockingCollars
             * and IndustrialZone.dockingCollars. */
        attribute redefines gateId = "DG-11.7";
        attribute redefines criterion = "PROBE fleet scaling - docking collars and ARM-D units at SPA IZ scale linearly with fleet growth (same 1:1 collar:ARM-D ratio established P3-P7). SPA IZ gantry rail extendable by design (SEL-CAD-IZ-001).";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines gatedElements = ("IndustrialZone.dockingCollars", "ArmD.countLockedToDockingCollars");
    }

    part def DgElevenEight :> ExogenousGate {
        doc /* "DG-11.8 (Y75): M-type asteroid redirect initiated". The year is
             * ProgrammeParameters.mTypeCaptureYear; derivedYear is bound to it
             * in SeleniteConfigurations. ECON tug_fleet is 2 from Y65 (build
             * precedes the redirect). */
        attribute redefines gateId = "DG-11.8";
        attribute redefines criterion = "M-type asteroid redirect initiated - SEP/NEP redirect tug (~50,000 kg, 2 units) captures ~200 m M-type asteroid and transfers to DRO. Does NOT consume ISRU propellant (xenon/krypton from Earth). Self-transfer via ion drive from LEO. Arrival Y85.";
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines declaredYear = 75.0;
        attribute redefines prerequisites = ("RedirectTug.developmentFrom");
        attribute redefines gatedElements = ("RedirectTug.introducedIn", "RedirectTug.firstCaptureIn", "DG-12.4");
    }

    // =====================================================================
    // P12 - Scaling + M-type asteroid online (Y80-120)
    // =====================================================================

    part def DgTwelveOne :> DerivableGate {
        doc /* "DG-12.1 (Y80): 500,000 t/yr REO -> 40% global displacement".
             * ECON reo_target reaches 500,000 at Y120 and supply_frac 0.40 at
             * Y140; the same document's P12 end-state puts "~500,000 t/yr" at
             * ~Y120 (W3-N4: internal inconsistency in the Decision Framework). */
        attribute redefines gateId = "DG-12.1";
        attribute redefines criterion = "500,000 t/yr REO -> 40% global displacement (revised from 1,000,000 at Rev B - build-out extended to 2.5 Mt/yr at Y180)";
        attribute redefines criterionAsModelled = "ReoOutputGate: ECON reo_target >= GateThresholds.reoTonnesPerYearP12; MarketShareGate: supply_frac >= GateThresholds.displacementFractionP12";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 80.0;
        attribute redefines prerequisites = ("DG-11.1");
        attribute redefines gatedElements = ("(programme output; no element)");
        calc outputCheck : ReoOutputGate;
        calc shareCheck : MarketShareGate;
    }

    part def DgTwelveTwo :> DerivableGate {
        doc /* "DG-12.2 (Y85): Thorium MSR fleet at ~6,890 x 100 MWe (689 GW) at
             * PKT full-scale". ECON msr_count >= 6,890 at ~Y172 (P14); VC-09
             * (8,334 at Y200). */
        attribute redefines gateId = "DG-12.2";
        attribute redefines criterion = "Thorium MSR fleet at ~6,890 x 100 MWe (689 GW) at PKT full-scale";
        attribute redefines criterionAsModelled = "MsrFleetGate: ECON msr_count >= GateThresholds.msrUnitsP12";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 85.0;
        attribute redefines prerequisites = ("DG-11.2");
        attribute redefines gatedElements = ("ThoriumMSR fleet (Wave 5 vector; VC-09)");
        calc fleetCheck : MsrFleetGate;
    }

    part def DgTwelveThree :> DerivableGate {
        doc /* "DG-12.3 (Y85): PKT->Earth mass driver: scaling toward 783/day
             * at P14+ steady state". ECN-020 s.4 corrects 783/day (the stale
             * 1.0 Mt/yr figure) to ~1,903/day at 2.5 Mt/yr; the Rev D gate
             * text was not updated (W3-N6). Evaluated as written on ECON
             * canisters_yr / 365 (ECON uses 3.5 t per canister, W3-N7). */
        attribute redefines gateId = "DG-12.3";
        attribute redefines criterion = "PKT->Earth mass driver: scaling toward 783/day at P14+ steady state";
        attribute redefines criterionAsModelled = "CanisterCadenceGate: ECON canisters_yr / 365 >= GateThresholds.canistersPerDaySteadyState";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 85.0;
        attribute redefines prerequisites = ("DG-9.1");
        attribute redefines gatedElements = ("MassDriverMd2 (cadence; ECN-020 three tracks)");
        calc cadenceCheck : CanisterCadenceGate;
    }

    part def DgTwelveFour :> ExogenousGate {
        doc /* "DG-12.4 (Y85): M-type asteroid arrives in DRO". derivedYear =
             * mTypeCaptureYear + asteroidOnlineLagYears in the configuration.
             * ECON captured_asteroid_pgm is non-zero from Y85 (agrees). The DRO
             * node, the first Laser Ablation Truss and the M-type line bind
             * here. */
        attribute redefines gateId = "DG-12.4";
        attribute redefines criterion = "M-type asteroid arrives in DRO - ~200 m Fe-Ni body. Dedicated Laser Ablation Truss + mass driver (MD-5, DRO->SPA) installed.";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 85.0;
        attribute redefines prerequisites = ("DG-11.8");
        attribute redefines gatedElements = ("DroStation.existsFrom", "LaserAblationTruss.introducedIn", "MTypeProcessingLine.introducedIn", "DG-12.5");
    }

    part def DgTwelveFive :> ExogenousGate {
        doc /* "DG-12.5 (Y85): MD-5 (DRO->SPA) mass driver operational".
             * derivedYear = mTypeCaptureYear + asteroidOnlineLagYears. ECON
             * cargo_ybco has no MD-4 or MD-5 line (only Y22/23/35/43 - W3-N12). */
        attribute redefines gateId = "DG-12.5";
        attribute redefines criterion = "MD-5 (DRO->SPA) mass driver operational - ~800 m/s, ~500 m track, ~30 t YBCO. Delivers asteroid concentrate to SPA EM catcher.";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 85.0;
        attribute redefines prerequisites = ("DG-12.4", "EmCatcher.operationalFrom");
        attribute redefines gatedElements = ("MassDriverMd5.operationalFrom", "ConcentrateCanister");
    }

    part def DgTwelveSix :> DerivableGate {
        doc /* "DG-12.6 (Y90): M-type PGM yield: 36.5 t/yr PGM". ECON
             * captured_asteroid_pgm = 36.5 from Y85 (five years before the
             * gate's year). */
        attribute redefines gateId = "DG-12.6";
        attribute redefines criterion = "M-type PGM yield: 36.5 t/yr PGM at 100 ppm in Fe-Ni matrix. 1,000 t/day laser ablation throughput.";
        attribute redefines criterionAsModelled = "PgmYieldGate: ECON captured_asteroid_pgm >= GateThresholds.mTypePgmTonnesPerYear";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 90.0;
        attribute redefines prerequisites = ("DG-12.4", "DG-12.5");
        attribute redefines gatedElements = ("MTypeProcessingLine (throughput; Wave 5)");
        calc yieldCheck : PgmYieldGate;
    }

    part def DgTwelveSeven :> ExogenousGate {
        doc /* "DG-12.7 (Y95): Programme status assessment - P13+ scope
             * decision. 500k->1.25 Mt/yr build-out commitment." Policy review. */
        attribute redefines gateId = "DG-12.7";
        attribute redefines criterion = "Programme status assessment - P13+ scope decision. 500k->1.25 Mt/yr build-out commitment. Hauler Earth fraction dropping from 43% to ~33% as M-type Fe-Ni supplements foundry feedstock.";
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines declaredYear = 95.0;
        attribute redefines prerequisites = ("DG-12.1", "DG-12.6");
        attribute redefines gatedElements = ("DG-13.1 (build-out to 1.25 Mt/yr)");
    }

    // =====================================================================
    // P13 - 50% replacement + C-type asteroid (Y120-Y140)
    // =====================================================================

    part def DgThirteenOne :> DerivableGate {
        doc /* "DG-13.1 (Y120): 1,250,000 t/yr REO - 50% of projected global
             * demand". ECON reo_target reaches 1.25 Mt at ~Y151 (P14) and
             * supply_frac 0.50 at ~Y151. */
        attribute redefines gateId = "DG-13.1";
        attribute redefines criterion = "1,250,000 t/yr REO - 50% of projected global demand. P13 milestone, not final target. Programme proceeds to 2.5 Mt/yr.";
        attribute redefines criterionAsModelled = "ReoOutputGate: ECON reo_target >= GateThresholds.reoTonnesPerYearP13; MarketShareGate: supply_frac >= GateThresholds.displacementFractionP13";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredYear = 120.0;
        attribute redefines prerequisites = ("DG-12.7");
        attribute redefines gatedElements = ("(programme output; no element)");
        calc outputCheck : ReoOutputGate;
        calc shareCheck : MarketShareGate;
    }

    part def DgThirteenTwo :> ExogenousGate {
        doc /* Decision Framework Rev D: "DG-13.2 (Y95, executed during P12):
             * C-type asteroid redirect initiated" (three redirect tugs in the
             * fleet; arrival Y105). The same document also labels the Laser
             * Ablation Truss "DG-13.2 concept, deployed Y85" and fleet v9
             * s.17.2 calls the truss method selection DG-13.2 - one id, two
             * uses (W2-N19). The gate list definition is carried. Listed under
             * P13, executed in P12 by the document's own words: declaredPhase
             * P13, declaredPhaseAlternate P12, year Y95 =
             * ProgrammeParameters.cTypeCaptureYear (derivedYear bound). */
        attribute redefines gateId = "DG-13.2";
        attribute redefines criterion = "C-type asteroid redirect initiated - ~100 m carbonaceous body. SEP/NEP redirect tug (3 units now in fleet). Arrival in DRO at Y105.";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredPhaseAlternate = Phase::P12;
        attribute redefines declaredYear = 95.0;
        attribute redefines prerequisites = ("DG-14.1", "DG-11.8");
        attribute redefines gatedElements = ("RedirectTug (C-type campaign)", "DG-13.3");
    }

    part def DgFourteenOne :> ExogenousGate {
        doc /* "DG-14.1 (Y95): C-type asteroid targeting decision gate" - listed
             * under P13 although numbered 14 (declaredPhaseAlternate P14 by
             * number); Y95 is P12 by the year table. derivedYear =
             * cTypeCaptureYear. Strategy v3.1 s.16 "C-type asteroid (DG-14.1,
             * Y95)". */
        attribute redefines gateId = "DG-14.1";
        attribute redefines criterion = "C-type asteroid targeting decision gate - selects target optimising for water ice content + carbon/nitrogen fraction + accessible orbit.";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredPhaseAlternate = Phase::P14;
        attribute redefines declaredYear = 95.0;
        attribute redefines prerequisites = ("DG-12.7");
        attribute redefines gatedElements = ("DG-13.2");
        attribute redefines consequenceIfNotMet = "Circuit Earth frac stays at 10% (Strategy v3.1 s.16)";
    }

    part def DgThirteenThree :> ExogenousGate {
        doc /* "DG-13.3 (Y105): C-type processing facilities commissioned at
             * SPA". derivedYear = cTypeCaptureYear + asteroidOnlineLagYears.
             * The model's CTypeProcessingLine is P12 by the year table (W2-N7,
             * years authoritative); the Decision Framework lists the gate under
             * P13. ECON's circuit Earth-fraction C-type reduction starts at Y105
             * (agrees). MOLE-I floor (~50) is the ECON molei_needed floor of 53
             * from Y85 (VC-07), i.e. the economics drop the MOLE-I fleet before
             * C-type water is online. */
        attribute redefines gateId = "DG-13.3";
        attribute redefines criterion = "C-type processing facilities commissioned at SPA: Pyrolysis + Fischer-Tropsch for polymer precursors (PTFE, Kapton-equivalent); Water extraction -> propellant independence from lunar ice (MOLE-I drops to ~50 for crew ECLSS only); Carbon + nitrogen for organic chemistry; C-type thermal blanket: reflective MLI over unmined surfaces to preserve subsurface ice in continuous DRO solar exposure";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredPhaseAlternate = Phase::P12;
        attribute redefines declaredYear = 105.0;
        attribute redefines prerequisites = ("DG-13.2", "DG-12.5");
        attribute redefines gatedElements = ("CTypeProcessingLine.introducedIn", "MoleI fleet floor (Wave 5 vector)");
    }

    part def DgThirteenFour :> DerivableGate {
        doc /* "DG-13.4 (Y105): SPA MSR #1 commissioned - 50 MWe". The third of
             * the five SPA MSR gates (F5, W2-N20); the one the economics
             * funded (ECON spa_msr_count = 1 from Y105, cargo_spa_msr 15 t at
             * Y105). Same calc as DG-10.5. Y105 is P12 by the year table. */
        attribute redefines gateId = "DG-13.4";
        attribute redefines criterion = "SPA MSR #1 commissioned - 50 MWe, ThCl4 fuel from PKT->SPA mass driver. Powers C-type processing.";
        attribute redefines criterionAsModelled = "SpaMsrIntroductionGate (unit #1) - unevaluated; ECON spa_msr_count = 1 from Y105";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredPhaseAlternate = Phase::P12;
        attribute redefines declaredYear = 105.0;
        attribute redefines prerequisites = ("DG-9.6", "DG-13.3");
        attribute redefines gatedElements = ("SpaThoriumMSR.introducedIn (unit #1)");
        attribute econAssumedYear : Integer = 105;
        calc introductionCheck : SpaMsrIntroductionGate;
    }

    part def DgThirteenFive :> DerivableGate {
        doc /* "DG-13.5 (Y110): Circuit Earth fraction drops from 10% to 3%".
             * ECON's circuit Earth fraction (cargo_circuits / (d_circuits x
             * circuit.mass_kg)) reaches 0.03 at Y115 (a P12 year). */
        attribute redefines gateId = "DG-13.5";
        attribute redefines criterion = "Circuit Earth fraction drops from 10% to 3% - C-type carbon replaces PTFE/polymer imports.";
        attribute redefines criterionAsModelled = "CircuitEarthFractionGate: ECON circuit Earth fraction <= GateThresholds.circuitEarthFractionPostCType";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredYear = 110.0;
        attribute redefines prerequisites = ("DG-13.3");
        attribute redefines gatedElements = ("ProcessingCircuit (Earth fraction; Wave 5)");
        calc fractionCheck : CircuitEarthFractionGate;
    }

    part def DgThirteenSix :> ExogenousGate {
        doc /* "DG-13.6 (Y115): S-type asteroid redirect initiated". derivedYear
             * = sTypeCaptureYear (Y115 is P12 by the year table). */
        attribute redefines gateId = "DG-13.6";
        attribute redefines criterion = "S-type asteroid redirect initiated - ~100 m silicaceous body. Fleet now includes 5 redirect tugs (redundancy).";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredYear = 115.0;
        attribute redefines prerequisites = ("DG-14.2", "DG-13.2");
        attribute redefines gatedElements = ("RedirectTug (S-type campaign)", "DG-14.3");
    }

    part def DgThirteenSeven :> DerivableGate {
        doc /* "DG-13.7 (Y120): M-type Fe-Ni reduces hauler Earth fraction from
             * 43% to 20% floor". ECON v1.3 hauler.earth_frac floors at 0.43
             * less a 0.10 M-type bonus phased in over Y90-Y100 (0.33); the
             * 20 % floor is not modelled, so the criterion is never met on the
             * current economics (W3-N5). */
        attribute redefines gateId = "DG-13.7";
        attribute redefines criterion = "M-type Fe-Ni reduces hauler Earth fraction from 43% to 20% floor (avionics, BMS, bearings irreducible).";
        attribute redefines criterionAsModelled = "HaulerEarthFractionGate: ECON hauler Earth fraction (cargo_haulers / (d_haulers x hauler.mass_kg)) <= GateThresholds.haulerEarthFractionFloor";
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines declaredYear = 120.0;
        attribute redefines prerequisites = ("DG-12.4", "DG-10.3");
        attribute redefines gatedElements = ("HaulerRevB (in-situ fraction; F3)");
        calc fractionCheck : HaulerEarthFractionGate;
    }

    // =====================================================================
    // P14 - Full replacement + S-type asteroid + Earth independence (Y140-Y180)
    // =====================================================================

    part def DgFourteenTwo :> ExogenousGate {
        doc /* "DG-14.2 (Y115, executed during P13): S-type asteroid targeting
             * decision gate". Listed under P14, executed during P13 by the
             * document's words, and Y115 is P12 by the year table - three
             * readings; declaredPhase P14, declaredPhaseAlternate P13, the
             * year-phase from plan_check. derivedYear = sTypeCaptureYear.
             * Strategy v3.1 s.16 "S-type asteroid (DG-14.2, Y115)". */
        attribute redefines gateId = "DG-14.2";
        attribute redefines criterion = "S-type asteroid targeting decision gate - selects target optimising for silicon content + enstatite sulfide copper fraction.";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredPhaseAlternate = Phase::P13;
        attribute redefines declaredYear = 115.0;
        attribute redefines prerequisites = ("DG-13.3");
        attribute redefines gatedElements = ("DG-13.6");
        attribute redefines consequenceIfNotMet = "Circuit Earth frac stays at 3% (Strategy v3.1 s.16)";
    }

    part def DgFourteenThree :> ExogenousGate {
        doc /* Resolved (kick-off question DG-14.3 vs DG-14.6): Decision
             * Framework Rev D DG-14.3 (Y125) is "S-type processing facilities
             * commissioned at SPA" (Czochralski Si, Cu electrolysis). The
             * Earth-independence assessment was DG-14.3 in ECN-019 and is
             * DG-14.6 in Rev D ("DG-14.6 (Y140): Earth independence assessment
             * (DG-14.3 from ECN-019)"); fleet v9 App. C and Strategy v3.1
             * s.16 still use the ECN-019 number while Strategy s.15.1 uses
             * DG-14.6 - the Strategy is internally inconsistent. Rev D
             * numbering is carried; the alias is on DG-14.6.formerGateId.
             * Listed under P14; Y125 is P13 by the year table (W2-N7, the
             * model's STypeProcessingLine is P13). derivedYear =
             * sTypeCaptureYear + asteroidOnlineLagYears. */
        attribute redefines gateId = "DG-14.3";
        attribute redefines criterion = "S-type processing facilities commissioned at SPA: Czochralski silicon refining (semiconductor-grade Si using C-type carbon for carbothermic reduction); Copper electrolysis from enstatite sulfides; Products mass-driven SPA->PKT for circuit fabrication";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredPhaseAlternate = Phase::P13;
        attribute redefines declaredYear = 125.0;
        attribute redefines prerequisites = ("DG-13.6", "DG-12.5");
        attribute redefines gatedElements = ("STypeProcessingLine.introducedIn");
    }

    part def DgFourteenFour :> DerivableGate {
        doc /* "DG-14.4 (Y125): SPA MSR #2 commissioned - 100 MWe for S-type Si
             * refinery power." F5 / W2-N20 unit #2; ECON spa_msr_count = 2 from
             * Y125. Y125 is P13 by the year table. */
        attribute redefines gateId = "DG-14.4";
        attribute redefines criterion = "SPA MSR #2 commissioned - 100 MWe for S-type Si refinery power.";
        attribute redefines criterionAsModelled = "SpaMsrIntroductionGate (unit #2) - unevaluated; ECON spa_msr_count = 2 from Y125";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredPhaseAlternate = Phase::P13;
        attribute redefines declaredYear = 125.0;
        attribute redefines prerequisites = ("DG-13.4", "DG-14.3");
        attribute redefines gatedElements = ("SpaThoriumMSR (unit #2)");
        attribute econAssumedYear : Integer = 125;
        calc introductionCheck : SpaMsrIntroductionGate;
    }

    part def DgFourteenFive :> DerivableGate {
        doc /* "DG-14.5 (Y130): Circuit Earth fraction drops from 3% to 0.8%".
             * ECON's circuit Earth fraction reaches 0.008 at Y135. */
        attribute redefines gateId = "DG-14.5";
        attribute redefines criterion = "Circuit Earth fraction drops from 3% to 0.8% - only advanced ICs remain Earth-sourced.";
        attribute redefines criterionAsModelled = "CircuitEarthFractionGate: ECON circuit Earth fraction <= GateThresholds.circuitEarthFractionPostSType";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredYear = 130.0;
        attribute redefines prerequisites = ("DG-14.3", "DG-13.5");
        attribute redefines gatedElements = ("ProcessingCircuit (Earth fraction; Wave 5)");
        calc fractionCheck : CircuitEarthFractionGate;
    }

    part def DgFourteenSix :> DerivableGate {
        doc /* Earth-independence gate. Decision Framework Rev D "DG-14.6
             * (Y140): Earth independence assessment (DG-14.3 from ECN-019) -
             * comprehensive audit of remaining Earth dependencies. Target:
             * <0.5% of total infrastructure mass from Earth"; baseline P14;
             * final report Fig. 34 "Earth independence gate DG-14.6". Proxy
             * evaluation: ECON earth_cargo against earth_cargo + insitu_total
             * in the year (annual flow, not cumulative infrastructure mass);
             * on that proxy the target is not met in any year to Y200
             * (W3-N1). The alias DG-14.3 (ECN-019 numbering, still used by
             * fleet v9 App. C and Strategy v3.1 s.16) is recorded. */
        attribute redefines gateId = "DG-14.6";
        attribute redefines formerGateId = "DG-14.3 (ECN-019 numbering; fleet v9 App. C; Strategy v3.1 s.16)";
        attribute redefines criterion = "Earth independence assessment (DG-14.3 from ECN-019) - comprehensive audit of remaining Earth dependencies. Target: <0.5% of total infrastructure mass from Earth.";
        attribute redefines criterionAsModelled = "EarthIndependenceGate: ECON earth_cargo < GateThresholds.earthDependencyMaximumFraction x (earth_cargo + insitu_total) (annual-flow proxy)";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredYear = 140.0;
        attribute redefines prerequisites = ("STypeProcessingLine.introducedIn", "DG-14.5");
        attribute redefines gatedElements = ("(assessment; no element)");
        attribute redefines consequenceIfNotMet = "Identifies remaining irreducible imports (Strategy v3.1 s.16)";
        calc independenceCheck : EarthIndependenceGate;
    }

    part def DgFourteenSeven :> DerivableGate {
        doc /* "DG-14.7 (Y140): SPA MSR #3 commissioned - scaled operations,
             * full asteroid processing hub." F5 / W2-N20 unit #3; ECON
             * spa_msr_count = 3 from Y140. */
        attribute redefines gateId = "DG-14.7";
        attribute redefines criterion = "SPA MSR #3 commissioned - scaled operations, full asteroid processing hub.";
        attribute redefines criterionAsModelled = "SpaMsrIntroductionGate (unit #3) - unevaluated; ECON spa_msr_count = 3 from Y140";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredYear = 140.0;
        attribute redefines prerequisites = ("DG-14.4");
        attribute redefines gatedElements = ("SpaThoriumMSR (unit #3)");
        attribute econAssumedYear : Integer = 140;
        calc introductionCheck : SpaMsrIntroductionGate;
    }

    part def DgFourteenEight :> DerivableGate {
        doc /* "DG-14.8 (Y180): 2,500,000 t/yr REO achieved - full replacement
             * of terrestrial REE mining." Threshold =
             * ProgrammeParameters.steadyStateReoTonnesPerYear (SEL-REQ-001);
             * ECON reo_target reaches it at Y180 (= steadyStateYear). Listed
             * under P14; Y180 is P14plus by the year table. */
        attribute redefines gateId = "DG-14.8";
        attribute redefines criterion = "2,500,000 t/yr REO achieved - full replacement of terrestrial REE mining.";
        attribute redefines criterionAsModelled = "ReoOutputGate: ECON reo_target >= ProgrammeParameters.steadyStateReoTonnesPerYear";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredPhaseAlternate = Phase::P14plus;
        attribute redefines declaredYear = 180.0;
        attribute redefines prerequisites = ("DG-13.1");
        attribute redefines gatedElements = ("ProgrammeTimeline.p14plus", "ProgrammeParameters.steadyStateYear");
        calc outputCheck : ReoOutputGate;
    }

    part def DgFourteenNine :> DerivableGate {
        doc /* "DG-14.9 (Y115+): Mk III PROBE fleet reduction". ECON mkiii_active
             * falls from 1,714 to 300 at Y115 (a P12 year; the model's
             * ProbeMkIII.prospectingRoleFrom = P13). All three captures
             * complete at sTypeCaptureYear + asteroidOnlineLagYears (Y125). */
        attribute redefines gateId = "DG-14.9";
        attribute redefines criterion = "Mk III PROBE fleet reduction - all 3 asteroid captures complete by Y125. Fleet reduces from ~1,714 to ~300 (prospecting for future targets only). Decommissioned Mk III units: ion drives and solar arrays salvaged at SPA.";
        attribute redefines criterionAsModelled = "MkIiiFleetReductionGate: ECON mkiii_active <= GateThresholds.mkIiiProspectingFleet after the peak, with captures complete (sTypeCaptureYear + lag)";
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines declaredYear = 115.0;
        attribute redefines prerequisites = ("DG-11.6", "DG-13.6");
        attribute redefines gatedElements = ("ProbeMkIII.prospectingRoleFrom");
        calc reductionCheck : MkIiiFleetReductionGate;
    }

    // =====================================================================
    // Post-P14 - tiered depth mining (Decision Framework Rev D s.10.2)
    // =====================================================================

    part def DgPostOne :> DerivableGate {
        doc /* Tiered depth mining at PKT (Decision Framework Rev D s.10.2 and
             * Strategy v3.1 s.7.4): "DG-POST.1 (~Y280+): Tier 1 surface
             * regolith approaching depletion at active sites -> commit hauler
             * ripper/breaker attachments + relay depots for Tier 2 (20-100 m)".
             * ARCHITECTURE_BASELINE.md s.4 relay depots "later phases". Y280 is
             * beyond the P14plus window start (Y180): declaredPhase P14plus.
             * DERIVABLE from cumulative ore extracted vs the Tier 1 resource;
             * neither the tier resource (ProgrammeParameters.tier1ResourceTonnes)
             * nor ECON beyond Y200 exists yet: unevaluated. Binds
             * RelayDepot.introducedIn (Wave 2 TODO closed). */
        attribute redefines gateId = "DG-POST.1";
        attribute redefines criterion = "Tier 1 surface regolith approaching depletion at active sites -> commit hauler ripper/breaker attachments + relay depots for Tier 2 (20-100 m)";
        attribute redefines criterionAsModelled = "TierDepletionGate: cumulative ECON regolith_yr >= depletionFraction x tier1ResourceTonnes - resource parameter unbound (unevaluated)";
        attribute redefines declaredPhase = Phase::P14plus;
        attribute redefines declaredYear = 280.0;
        attribute redefines prerequisites = ("DG-14.8");
        attribute redefines gatedElements = ("RelayDepot.introducedIn", "HaulerRevB (ripper/breaker front end)");
        attribute redefines consequenceIfNotMet = "Commit hauler ripper/breaker attachments + relay depots for Tier 2 (20-100 m) (Strategy v3.1 s.16 wording of the trigger)";
        calc depletionCheck : TierDepletionGate;
    }

    part def DgPostTwo :> DerivableGate {
        doc /* Decision Framework Rev D s.10.2: "DG-POST.2 (~Y380+): Tier 2
             * megaregolith approaching depletion -> commit heavy breaker units
             * + sintered ramp network for Tier 3 (100-200 m)". Unevaluated as
             * DG-POST.1. */
        attribute redefines gateId = "DG-POST.2";
        attribute redefines criterion = "Tier 2 megaregolith approaching depletion -> commit heavy breaker units + sintered ramp network for Tier 3 (100-200 m)";
        attribute redefines criterionAsModelled = "TierDepletionGate on tier2ResourceTonnes - unbound (unevaluated)";
        attribute redefines declaredPhase = Phase::P14plus;
        attribute redefines declaredYear = 380.0;
        attribute redefines prerequisites = ("DG-POST.1");
        attribute redefines gatedElements = ("RelayDepot (series depots)", "HaulerRevB (heavy breaker)");
        calc depletionCheck : TierDepletionGate;
    }

    // =====================================================================
    // Milestones
    // =====================================================================

    part def Milestone {
        doc /* One formally defined programme milestone (MTL v8.5 convention:
             * nine milestones M0-M8, each verified by SENTINEL, crew or Earth
             * mission control before subsequent activities are authorised).
             * declaredMonth is the MTL month from programme go-ahead (M1);
             * declaredYear = ceiling(month / 12) as the reference states it. */
        attribute milestoneId : String;
        attribute title : String;
        attribute declaredMonth : Integer [0..1];
        attribute declaredYear : Real [0..1];
        abstract attribute declaredPhase : Phase [0..1];
        attribute source : String;
        attribute confirmedAgainstFigure2 : Boolean = true;
    }

    part def MilestoneSet {
        doc /* Milestones M0-M8 from docs/W5_T4_4_JS_milestone_reference.html
             * ("Programme Milestones (from MTL v8.5)", the milestone numbering
             * convention the final report's Fig. 2 follows); the Fig. 2
             * diamonds (docs/final_report_figures/page-05.jpg) agree on every
             * number and year it draws - it omits M5 (beneficiation) and
             * places M8 before M7 because M8 (M130) precedes M7 (M136). The
             * numbering is by definition order in MTL v8.5, not by date.
             * Phases follow the milestone month against ProgrammeTimeline
             * (P1 Y2-4, P2 Y4-6, P3 Y4-7, P4 Y7-9, P5 Y9-12); a boundary year
             * carries the phase the reference's own timeline shows. Replaces
             * the Wave 3 delivery proxy (W3-N13, closed 18 Sep 2026). Three
             * of these differ from the Decision Framework gate years the same
             * events carry: M4 SKIP hop Y6 vs DG-2.2 Y5, M8 DART PKT Y11 vs
             * DG-5.1 Y9, M7 crew rotation Y11.5 vs DG-6.4 Y12 (W3-N21). */

        part m0 : Milestone {
            attribute redefines milestoneId = "M0";
            attribute redefines title = "Relay Network Live - 3x EML-2 halo satellites validated; robot fleet launch cleared";
            attribute redefines declaredMonth = 20;
            attribute redefines declaredYear = 2.0;
            attribute redefines declaredPhase = Phase::P1;
            attribute redefines source = "W5_T4_4 milestone reference (MTL v8.5) M20; final report Fig. 2 'M0 Relay Live (Y2)'; DG-1.1";
        }
        part m1 : Milestone {
            attribute redefines milestoneId = "M1";
            attribute redefines title = "First PROBE Landing - PROBE-Scout XRF data from three expendable NEA survey vehicles";
            attribute redefines declaredMonth = 36;
            attribute redefines declaredYear = 3.0;
            attribute redefines declaredPhase = Phase::P1;
            attribute redefines source = "W5_T4_4 milestone reference M36; final report Fig. 2 'M1 First Surface (Y3)'";
        }
        part m2 : Milestone {
            attribute redefines milestoneId = "M2";
            attribute redefines title = "First SINTER Print - hab shell Layer 0, first in-situ manufactured structural component";
            attribute redefines declaredMonth = 54;
            attribute redefines declaredYear = 5.0;
            attribute redefines declaredPhase = Phase::P2;
            attribute redefines source = "W5_T4_4 milestone reference M54; final report Fig. 2 'M2 First SINTER Print (Y5)'";
        }
        part m3 : Milestone {
            attribute redefines milestoneId = "M3";
            attribute redefines title = "Crew-1 Arrival - 4 persons; ECLSS commissioning begins";
            attribute redefines declaredMonth = 82;
            attribute redefines declaredYear = 7.0;
            attribute redefines declaredPhase = Phase::P4;
            attribute redefines source = "W5_T4_4 milestone reference M82; final report Fig. 2 'M3 Crew-1 (Y7)'; DG-4.1";
        }
        part m4 : Milestone {
            attribute redefines milestoneId = "M4";
            attribute redefines title = "First SKIP Hop - SKIP-1 sub-orbital hop on ISRU propellant, KREEP sample return";
            attribute redefines declaredMonth = 70;
            attribute redefines declaredYear = 6.0;
            attribute redefines declaredPhase = Phase::P3;
            attribute redefines source = "W5_T4_4 milestone reference M70; final report Fig. 2 'M4 First SKIP Hop (Y6)'; DG-2.2 gives Y5 (W3-N21)";
        }
        part m5 : Milestone {
            attribute redefines milestoneId = "M5";
            attribute redefines title = "Beneficiation Online - crusher, screens, magnetic separation; 2-8x grade uplift";
            attribute redefines declaredMonth = 105;
            attribute redefines declaredYear = 9.0;
            attribute redefines declaredPhase = Phase::P5;
            attribute redefines source = "W5_T4_4 milestone reference M105 (not drawn on Fig. 2); DG-5.2 gives Y10";
        }
        part m6 : Milestone {
            attribute redefines milestoneId = "M6";
            attribute redefines title = "First Export Batch - asteroid Ni-Fe/PGM + KREEP REE concentrate dispatched";
            attribute redefines declaredMonth = 116;
            attribute redefines declaredYear = 10.0;
            attribute redefines declaredPhase = Phase::P5;
            attribute redefines source = "W5_T4_4 milestone reference M116; final report Fig. 2 'M6 First Export (Y10)'; DG-5.4";
        }
        part m7 : Milestone {
            attribute redefines milestoneId = "M7";
            attribute redefines title = "Crew Rotation Begins - staggered swap M136/139/142/145";
            attribute redefines declaredMonth = 136;
            attribute redefines declaredYear = 11.5;
            attribute redefines declaredPhase = Phase::P5;
            attribute redefines source = "W5_T4_4 milestone reference M136; final report Fig. 2 'M7 Crew Rotation (Y11.5)' under P6; DG-6.4 gives Y12 (W3-N21)";
        }
        part m8 : Milestone {
            attribute redefines milestoneId = "M8";
            attribute redefines title = "First DART PKT Mission - LLO transfer, autonomous landing, XRF confirms PKT grade";
            attribute redefines declaredMonth = 130;
            attribute redefines declaredYear = 11.0;
            attribute redefines declaredPhase = Phase::P5;
            attribute redefines source = "W5_T4_4 milestone reference M130; final report Fig. 2 'M8 DART PKT (Y11)'; DG-5.1 gives Y9 (W3-N21)";
        }
    }

    // =====================================================================
    // Catalogue
    // =====================================================================

    part def GateCatalogue {
        doc /* All gates in one place for the planner and the diagrams, in
             * Decision Framework order. Usage names follow the gate id. */
        part dgZeroOne : DgZeroOne;
        part dgZeroTwo : DgZeroTwo;
        part dgZeroThree : DgZeroThree;
        part dgZeroFour : DgZeroFour;
        part dgOneOne : DgOneOne;
        part dgTwoOne : DgTwoOne;
        part dgTwoTwo : DgTwoTwo;
        part dgThreeOne : DgThreeOne;
        part dgThreeTwo : DgThreeTwo;
        part dgFourOne : DgFourOne;
        part dgFourTwo : DgFourTwo;
        part dgFourThree : DgFourThree;
        part dgFiveOne : DgFiveOne;
        part dgFiveTwo : DgFiveTwo;
        part dgFiveThree : DgFiveThree;
        part dgFiveFour : DgFiveFour;
        part dgSixOne : DgSixOne;
        part dgSixTwo : DgSixTwo;
        part dgSixThree : DgSixThree;
        part dgSixFour : DgSixFour;
        part dgSevenOne : DgSevenOne;
        part dgSevenTwo : DgSevenTwo;
        part dgSevenThree : DgSevenThree;
        part dgSevenFour : DgSevenFour;
        part dgSevenFive : DgSevenFive;
        part dgEightZero : DgEightZero;
        part dgEightOne : DgEightOne;
        part dgEightTwo : DgEightTwo;
        part dgEightThree : DgEightThree;
        part dgEightFour : DgEightFour;
        part dgEightFive : DgEightFive;
        part dgEightSix : DgEightSix;
        part dgEightSeven : DgEightSeven;
        part dgEightEight : DgEightEight;
        part dgEightNine : DgEightNine;
        part dgEightX : DgEightX;
        part dgNineOne : DgNineOne;
        part dgNineTwo : DgNineTwo;
        part dgNineThree : DgNineThree;
        part dgNineFour : DgNineFour;
        part dgNineFive : DgNineFive;
        part dgNineSix : DgNineSix;
        part dgNineSeven : DgNineSeven;
        part dgTenOne : DgTenOne;
        part dgTenTwo : DgTenTwo;
        part dgTenThree : DgTenThree;
        part dgTenFour : DgTenFour;
        part dgTenFive : DgTenFive;
        part dgElevenOne : DgElevenOne;
        part dgElevenTwo : DgElevenTwo;
        part dgElevenThree : DgElevenThree;
        part dgElevenFour : DgElevenFour;
        part dgElevenFive : DgElevenFive;
        part dgElevenSix : DgElevenSix;
        part dgElevenSeven : DgElevenSeven;
        part dgElevenEight : DgElevenEight;
        part dgTwelveOne : DgTwelveOne;
        part dgTwelveTwo : DgTwelveTwo;
        part dgTwelveThree : DgTwelveThree;
        part dgTwelveFour : DgTwelveFour;
        part dgTwelveFive : DgTwelveFive;
        part dgTwelveSix : DgTwelveSix;
        part dgTwelveSeven : DgTwelveSeven;
        part dgThirteenOne : DgThirteenOne;
        part dgThirteenTwo : DgThirteenTwo;
        part dgFourteenOne : DgFourteenOne;
        part dgThirteenThree : DgThirteenThree;
        part dgThirteenFour : DgThirteenFour;
        part dgThirteenFive : DgThirteenFive;
        part dgThirteenSix : DgThirteenSix;
        part dgThirteenSeven : DgThirteenSeven;
        part dgFourteenTwo : DgFourteenTwo;
        part dgFourteenThree : DgFourteenThree;
        part dgFourteenFour : DgFourteenFour;
        part dgFourteenFive : DgFourteenFive;
        part dgFourteenSix : DgFourteenSix;
        part dgFourteenSeven : DgFourteenSeven;
        part dgFourteenEight : DgFourteenEight;
        part dgFourteenNine : DgFourteenNine;
        part dgPost1 : DgPostOne;
        part dgPost2 : DgPostTwo;
        part milestones : MilestoneSet;
    }
}
