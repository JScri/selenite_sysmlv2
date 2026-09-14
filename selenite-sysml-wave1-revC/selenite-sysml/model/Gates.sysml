package SeleniteGates {
    doc /* Decision gates (DG-x.y) and the derivation rule for phase
         * attributes. Wave 3 structural skeleton (14 Sep 2026): every gate
         * the read documents name, with its criterion as text, whether it is
         * evaluable from model data, its declared phase (what the documents
         * say) and a derivedPhase left UNBOUND for the planner (Wave 5) to
         * fill from Python-sourced vectors. The full gate catalogue is in
         * SELENITE_DECISION_FRAMEWORK_v4.md (F1: "Rev D"), which is not yet in
         * the repository - TODO Wave 3: add it and complete the catalogue.
         * Sources: ARCHITECTURE_BASELINE.md s.1, SEL_ROBOT_FLEET_v9.md,
         * SEL_FINAL_REPORT_v4 Figs. 2, 33, 34, ECN-020, MIGRATION_PLAN.md.
         *
         * Derivation rule (Jason, 14 Sep 2026): timing is not gated on a
         * predetermined phase where a condition on model data decides it.
         * Elements bind introducedIn to a gate's outcome; documents' phase
         * labels are candidates. First applications:
         * SelenitePower::SpaThoriumMSR (DG-10.5, via
         * SeleniteAnalysis::SpaMsrIntroductionGate) and
         * SeleniteTransport::StarshipReturnLink (retires when MD-4 is
         * operational, bound in SeleniteConfigurations). */

    private import ScalarValues::*;
    private import SelenitePhases::*;

    enum def GateEvaluability {
        doc /* derivable: a condition on quantities the Python layer computes;
             * testOutcome: a demonstration or measurement whose result is an
             * assumption the plan declares; exogenous: a policy input. */
        derivable; testOutcome; exogenous;
    }

    abstract part def DecisionGate {
        doc /* One decision gate. declaredPhase is the phase the documents
             * attach; derivedPhase is what the planner computes (unbound until
             * Wave 5); the checker compares the two and prints the register. */
        attribute gateId : String;
        attribute criterion : String;
        abstract attribute evaluability : GateEvaluability;
        abstract attribute declaredPhase : Phase;
        abstract attribute derivedPhase : Phase [0..1];
        attribute prerequisites : String [0..*];
        attribute gatedElements : String [0..*];
    }

    part def DgSevenOne :> DecisionGate {
        doc /* PKT commitment gate. Fleet v9 s.20.3 "PKT commitment (DG-7.1)";
             * baseline P7. Depends on DART site confirmation (Y22) and the
             * five-circuit flowsheet proof. */
        attribute redefines gateId = "DG-7.1";
        attribute redefines criterion = "DART ground truth > 500 ppm REE at the PKT site and SEL-PROC-001 proves the 8-step flowsheet at SPA";
        attribute redefines evaluability = GateEvaluability::testOutcome;
        attribute redefines declaredPhase = Phase::P7;
        attribute redefines prerequisites = ("Dart.pktSiteConfirmationIn", "SpaProcessingFacility.introducedIn");
        attribute redefines gatedElements = ("AutonomousFactory", "MassDriverMd1");
    }

    part def DgSevenFive :> DecisionGate {
        doc /* Condition for an early PKT MSR prototype at P8: final report
             * Fig. 33 "First MSR prototype if DG-7.5 met" (W2-N11). Criterion
             * unknown until the Decision Framework is read. TODO Wave 3. */
        attribute redefines gateId = "DG-7.5";
        attribute redefines criterion = "TODO Wave 3: not stated in any read source";
        attribute redefines evaluability = GateEvaluability::testOutcome;
        attribute redefines declaredPhase = Phase::P7;
    }

    part def DgEightZero :> DecisionGate {
        doc /* MD-1 SPA->PKT operational. ECN-020, baseline P8. */
        attribute redefines gateId = "DG-8.0";
        attribute redefines criterion = "MD-1 commissioned and first inter-site launch";
        attribute redefines evaluability = GateEvaluability::exogenous;
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines prerequisites = ("DG-7.1", "MassDriverDemonstrator.introducedIn");
        attribute redefines gatedElements = ("MassDriverMd1", "PktProcessingSpine", "HaulerRevB");
    }

    part def DgEightX :> DecisionGate {
        doc /* Circuit validation before full PKT commitment: fleet v9 s.14
             * "validate >= 1.0 t/yr before full PKT commitment"; final report
             * Fig. 33 P8. The per-circuit throughput is a test outcome. */
        attribute redefines gateId = "DG-8.X";
        attribute redefines criterion = "Optimised circuit demonstrates >= 1.0 t/yr REO";
        attribute redefines evaluability = GateEvaluability::testOutcome;
        attribute redefines declaredPhase = Phase::P8;
        attribute redefines gatedElements = ("PktProcessingSpine (scale-up beyond 308 circuits)");
    }

    part def DgNineOne :> DecisionGate {
        doc /* MD-2 PKT->Earth operational (first REO canisters). ECN-020,
             * baseline P9. */
        attribute redefines gateId = "DG-9.1";
        attribute redefines criterion = "MD-2 commissioned; first canister recovered on Earth";
        attribute redefines evaluability = GateEvaluability::exogenous;
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines prerequisites = ("DG-8.0", "DG-8.X");
        attribute redefines gatedElements = ("MassDriverMd2", "Skip.retiredIn");
    }

    part def DgNineThree :> DecisionGate {
        doc /* First thorium MSR at PKT: breeding ratio confirmed > 1.0.
             * Fleet v9 s.18.2, final report Fig. 33 P9 "First MSR(s)
             * commissioned (DG-9.3)". Jason 14 Sep 2026: PKT first MSR is P9. */
        attribute redefines gateId = "DG-9.3";
        attribute redefines criterion = "Breeding ratio > 1.0 confirmed on ThCl4 fuel from the KREEP thorium stream";
        attribute redefines evaluability = GateEvaluability::testOutcome;
        attribute redefines declaredPhase = Phase::P9;
        attribute redefines prerequisites = ("DG-8.0", "ReagentPlant.introducedIn");
        attribute redefines gatedElements = ("ThoriumMSR");
    }

    part def DgTenFour :> DecisionGate {
        doc /* MSR fleet replaces the PKT FSP field. Final report Fig. 33 P10
             * "MSR fleet ~74 x 100 MWe (DG-10.4) replaces FSP". DERIVABLE: the
             * phase in which PKT circuit power demand exceeds FSP field
             * capability (ECON circuits_needed x circuit power vs FSP field). */
        attribute redefines gateId = "DG-10.4";
        attribute redefines criterion = "PKT electrical demand > FSP field capability";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines prerequisites = ("DG-9.3");
        attribute redefines gatedElements = ("PktFspField.retiredIn", "ThoriumMSR.replacesPktFspFrom");
    }

    part def DgTenFive :> DecisionGate {
        doc /* SPA MSR commissioned. FLAG F5: declared P10 (scope P10, final
             * report Fig. 33) and P13 (scope P13, Fig. 34 "SPA MSR #1").
             * DERIVABLE via SeleniteAnalysis::SpaMsrIntroductionGate; the
             * declaredPhase records the P10 label only as a candidate. */
        attribute redefines gateId = "DG-10.5";
        attribute redefines criterion = "SPA demand > solar + FSP + battery capability, ThCl4 supply available (MD-3), MSR deployable at the crewed base";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines declaredPhase = Phase::P10;
        attribute redefines prerequisites = ("MassDriverMd3.operationalFrom", "DG-9.3");
        attribute redefines gatedElements = ("SpaThoriumMSR.introducedIn");
    }

    part def DgElevenSix :> DecisionGate {
        doc /* PROBE Mk III SEP commissioned; MD-4 SPA->Earth PGM exports.
             * Baseline P11, fleet v9 s.2.4. Partly DERIVABLE: the transition is
             * forced when chemical PROBE propellant demand would need more
             * MOLE-I than the PSR floor holds (ProgrammeParameters.
             * psrMoleICapacityUnits, W2-N18). */
        attribute redefines gateId = "DG-11.6";
        attribute redefines criterion = "Mk III SEP demonstrated (never-lands, EM anchoring) and chemical PROBE propellant demand exceeds PSR MOLE-I capacity";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines declaredPhase = Phase::P11;
        attribute redefines prerequisites = ("ProbeMkII.introducedIn", "EmCatcher.introducedIn");
        attribute redefines gatedElements = ("ProbeMkIII", "MassDriverMd4", "MoleIMkII.declineDrivenByMkIIIFrom", "StarshipReturnLink.retiredIn");
    }

    part def DgThirteenTwo :> DecisionGate {
        doc /* Asteroid mining method selection (laser vs mechanical vs hybrid)
             * for the Laser Ablation Truss. Fleet v9 s.17.2. Declared P13 by
             * its number, but the first truss is P12 (M-type online Y85) -
             * recorded, TODO Wave 3 with the Decision Framework. */
        attribute redefines gateId = "DG-13.2";
        attribute redefines criterion = "Mining method selected for captured asteroids";
        attribute redefines evaluability = GateEvaluability::testOutcome;
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines gatedElements = ("LaserAblationTruss");
    }

    part def DgFourteenThree :> DecisionGate {
        doc /* Fleet v9 s.20.3 P14 milestone "DG-14.3"; the baseline and final
             * report name the P14 gate DG-14.6 instead. Two numbers for what
             * may be one gate - TODO Wave 3 with the Decision Framework. */
        attribute redefines gateId = "DG-14.3";
        attribute redefines criterion = "TODO Wave 3: as stated in Decision Framework v4";
        attribute redefines evaluability = GateEvaluability::exogenous;
        attribute redefines declaredPhase = Phase::P14;
    }

    part def DgFourteenSix :> DecisionGate {
        doc /* Earth-independence gate. Baseline P14, final report Fig. 34
             * "Earth independence gate DG-14.6". DERIVABLE: Earth mass
             * dependency below the declared threshold (< 0.5 % per Fig. 1). */
        attribute redefines gateId = "DG-14.6";
        attribute redefines criterion = "Earth mass dependency < 0.5 % of programme mass flow";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines declaredPhase = Phase::P14;
        attribute redefines prerequisites = ("STypeProcessingLine.introducedIn");
    }

    part def DgPostOne :> DecisionGate {
        doc /* Tiered depth mining at PKT (Decision Framework Rev D: DG-POST.1 /
             * DG-POST.2; ARCHITECTURE_BASELINE.md s.4 relay depots "later
             * phases"). Phase not declared anywhere read - left unbound;
             * gates SeleniteProcessing::RelayDepot.introducedIn. TODO Wave 3. */
        attribute redefines gateId = "DG-POST.1";
        attribute redefines criterion = "TODO Wave 3: Tier 2/3 depth mining trigger per Decision Framework v4";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines gatedElements = ("RelayDepot.introducedIn");
    }

    part def DgPostTwo :> DecisionGate {
        doc /* Companion to DG-POST.1 (Decision Framework Rev D). TODO Wave 3. */
        attribute redefines gateId = "DG-POST.2";
        attribute redefines criterion = "TODO Wave 3: per Decision Framework v4";
        attribute redefines evaluability = GateEvaluability::derivable;
    }

    part def GateCatalogue {
        doc /* All gates in one place for the planner and the diagrams. */
        part dgSevenOne : DgSevenOne;
        part dgSevenFive : DgSevenFive;
        part dgEightZero : DgEightZero;
        part dgEightX : DgEightX;
        part dgNineOne : DgNineOne;
        part dgNineThree : DgNineThree;
        part dgTenFour : DgTenFour;
        part dgTenFive : DgTenFive;
        part dgElevenSix : DgElevenSix;
        part dgThirteenTwo : DgThirteenTwo;
        part dgFourteenThree : DgFourteenThree;
        part dgFourteenSix : DgFourteenSix;
        part dgPost1 : DgPostOne;
        part dgPost2 : DgPostTwo;
    }
}
