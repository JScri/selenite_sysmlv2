package SeleniteGates {
    doc /* Decision gates (DG-x.y) and the derivation rule for phase
         * attributes. Wave 3 structural skeleton (14 Sep 2026): every gate
         * the read documents name, with its criterion as text, whether it is
         * evaluable from model data, its declared phase (what the documents
         * say) and a derivedPhase left UNBOUND for the planner (Wave 5) to
         * fill from Python-sourced vectors. The full catalogue (DG-0.1 to
         * DG-14.9 plus DG-POST.1/2, 82 gates) is in
         * docs/SELENITE_DECISION_FRAMEWORK_v4.md (SEL-DECISION-001 Rev D,
         * in the repository from 14 Sep 2026; F1 confirmed). The gates below
         * are the subset already referenced by the model; Wave 3 completes
         * the catalogue from that document.
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
        doc /* Thorium MSR decision. Decision Framework Rev D P7: "DG-7.5
             * (~2040): commit only if terrestrial MSR demonstrates sustained
             * BR > 1.0". ~2040 is programme Y15, i.e. inside the F7 gap between
             * P6 and P7 - the gate may be the reason the gap exists. Final
             * report Fig. 33 P8 "First MSR prototype if DG-7.5 met" (W2-N11). */
        attribute redefines gateId = "DG-7.5";
        attribute redefines criterion = "A terrestrial thorium MSR demonstrates sustained breeding ratio > 1.0 (~2040)";
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
        doc /* SPA MSR commissioned. FLAG F5: Decision Framework Rev D itself
             * carries THREE commissioning gates for the SPA MSR - DG-10.5
             * (Y50) "SPA MSR commissioning", DG-11.3 (Y70) "SPA MSR
             * commissioning", DG-13.4 (Y105) "SPA MSR #1 commissioned" - plus
             * DG-14.4 (Y125) "#2" and DG-14.7 (Y140) "#3"; Strategy v3.1
             * s.5.1 says "SPA MSR from Y105" and s.12.1 "from Y50". This is
             * why the gate is DERIVABLE via SeleniteAnalysis::
             * SpaMsrIntroductionGate and not transcribed; the ECON v2.1
             * golden's cargo_spa_msr vector records what the economics
             * assumed (see CHANGELOG_WAVE3.md). declaredPhase keeps the
             * earliest label as the candidate. */
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
        doc /* Decision Framework Rev D: "DG-13.2 (Y95, executed during P12):
             * C-type asteroid redirect initiated" (three redirect tugs in the
             * fleet; arrival Y105). The same document also labels the Laser
             * Ablation Truss "DG-13.2 concept, deployed Y85" and fleet v9
             * s.17.2 calls the truss method selection DG-13.2 - one id, two
             * uses (W2-N19). The gate list definition is carried. Numbered 13
             * but executed in P12 by the document's own words: declaredPhase
             * P12 (year Y95). */
        attribute redefines gateId = "DG-13.2";
        attribute redefines criterion = "C-type asteroid redirect initiated (Y95); target per DG-14.1";
        attribute redefines evaluability = GateEvaluability::exogenous;
        attribute redefines declaredPhase = Phase::P12;
        attribute redefines gatedElements = ("RedirectTug (C-type campaign)", "CTypeProcessingLine");
    }

    part def DgFourteenThree :> DecisionGate {
        doc /* Resolved from Decision Framework Rev D: DG-14.3 (Y125) is
             * "S-type processing facilities commissioned at SPA" (Czochralski
             * Si, Cu electrolysis). The Earth-independence assessment was
             * DG-14.3 in ECN-019 and is DG-14.6 in the Decision Framework
             * ("DG-14.6 (Y140): Earth independence assessment (DG-14.3 from
             * ECN-019)"); fleet v9 App. C still uses the ECN-019 number.
             * Y125 is P13 by the year table (W2-N7). */
        attribute redefines gateId = "DG-14.3";
        attribute redefines criterion = "S-type processing facilities commissioned at SPA (Y125)";
        attribute redefines evaluability = GateEvaluability::exogenous;
        attribute redefines declaredPhase = Phase::P13;
        attribute redefines gatedElements = ("STypeProcessingLine");
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
             * gates SeleniteProcessing::RelayDepot.introducedIn. Decision
             * Framework Rev D s.10.2: "DG-POST.1 (~Y280+): Tier 1 surface
             * regolith approaching depletion at active sites -> commit hauler
             * ripper/breaker attachments + relay depots for Tier 2 (20-100 m)".
             * Y280 is beyond the P14plus window start (Y180): declaredPhase
             * P14plus. DERIVABLE from cumulative ore extracted vs Tier 1
             * resource at active sites. */
        attribute redefines gateId = "DG-POST.1";
        attribute redefines criterion = "Tier 1 surface regolith (0-20 m) approaching depletion at active sites (~Y280+)";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines declaredPhase = Phase::P14plus;
        attribute redefines gatedElements = ("RelayDepot.introducedIn", "HaulerRevB (ripper/breaker front end)");
    }

    part def DgPostTwo :> DecisionGate {
        doc /* Decision Framework Rev D s.10.2: "DG-POST.2 (~Y380+): Tier 2
             * megaregolith approaching depletion -> commit heavy breaker units
             * + sintered ramp network for Tier 3 (100-200 m)". */
        attribute redefines gateId = "DG-POST.2";
        attribute redefines criterion = "Tier 2 megaregolith (20-100 m) approaching depletion (~Y380+)";
        attribute redefines evaluability = GateEvaluability::derivable;
        attribute redefines declaredPhase = Phase::P14plus;
        attribute redefines prerequisites = ("DG-POST.1");
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
