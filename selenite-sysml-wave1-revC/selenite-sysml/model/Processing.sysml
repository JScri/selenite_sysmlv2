package SeleniteProcessing {
    doc /* REE value chain processing: SPA processing facility (SEL-PROC-001),
         * PKT processing spine, reagent plant, foundry, relay depots, the
         * eight-step zero-carbon flowsheet (structure only) and the three
         * asteroid processing lines at SPA. Chemistry values, circuit counts
         * per phase and throughput are Wave 4/5. Th/U separation stage
         * architecture is OPEN pending the preprint.
         * Sources: SEL-PROC-001 Rev B, SEL-PROC-PKT-001 Rev B, SEL-REAGENT-001
         * Rev A, SEL-FAB-001 Rev A, ECN-018 (in-situ reagents, PGM),
         * Strategy v3.1 s.10, Decision Framework v4, fleet v9 s.14,
         * ARCHITECTURE_BASELINE.md s.4 and s.6. ECN-021 (PKT process water)
         * is drafted and NOT modelled - excluded until its five source
         * documents are revised (VC-15/16/17). Wave 4B (7 Nov 2026): ports
         * typed by SeleniteInterfaces; the flowsheet steps linked through
         * ProcessStreamLink; the SPA reagent pilot (DG-5.3 / DG-7.4) and the
         * PKT oxalic-acid line (DG-9.5) added as the gated elements the Wave 3
         * catalogue named with "TODO Wave 4"; the value-chain behaviour that
         * these facilities perform is in SeleniteBehaviour. */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;
    private import SeleniteScenarios::*;
    private import SeleniteSites::*;

    abstract part def ProcessingFacility :> PhaseGated {
        doc /* Base for fixed processing infrastructure. Source:
             * ARCHITECTURE_BASELINE.md s.4 and s.6. */
        abstract attribute location : SiteId;
        port powerIn : ~PowerPort;
    }

    part def ProcessingCircuit :> PhaseGated {
        doc /* Optimised continuous-flow circuit (committed design, fleet v9
             * s.14). Fleet-scale counts per phase are configuration values from
             * the Python layer (VC-09 records 2.08 M vs 2,083,334 and the MSR
             * mismatch). First five circuits at SPA in P7; PKT spine from P8. */
        attribute redefines introducedIn = Phase::P7;
        attribute redefines retiredIn = null;
        port oreIn : ~OrePort;
        port reagentIn : ~ReagentPort;
        port reoOut : ProductPort;
        port thoriumOut : ThoriumPort;
    }

    part def BeneficiationPlant :> ProcessingFacility {
        doc /* KREEP beneficiation (10x upgrade) in the SPA Industrial Zone from
             * P5; first export Y10. Stage 1 physical only: jaw crusher, screens,
             * magnetic drums (Strategy v3.1 s.5.1 item 4). Also the first
             * stage for asteroid ore from the IZ collars and the EM catcher
             * (Decision Framework Rev D s.3.2). Source: SEL-IZ-001 Rev B,
             * baseline s.4. */
        attribute redefines introducedIn = Phase::P5;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        port oreIn : ~OrePort;
        port concentrateOut : OrePort;
    }

    part def SpaPgmHydromet :> ProcessingFacility {
        doc /* SPA PGM hydromet for PROBE-returned asteroid ore: chlorination
             * separation of the PGM concentrate from the beneficiated Fe-Ni /
             * PGM ore, Fe-Ni bulk to PKT on MD-1 (Decision Framework Rev D
             * s.3.2 steps 4-6 and s.10.1 "existing PGM hydromet from P5+ PROBE
             * heritage"; fleet v9 s.19). From P5: the first export batch (M6,
             * DG-5.4, Y10) is "asteroid Ni-Fe/PGM + KREEP REE concentrate"
             * (MilestoneSet m6). Created at Wave 4B when the value chain could
             * not allocate the PGM separation step before the M-type line
             * (P12) exists - W4B-N5; introducedIn bound in
             * SeleniteConfigurations to DG-5.4. The captured-asteroid scale-up
             * of the same chemistry is MTypeProcessingLine. No SPA hydromet
             * document exists (TODO naming it when written). */
        attribute redefines introducedIn = Phase::P5;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        port oreIn : ~OrePort;
        port pgmOut : ProductPort;
        port feNiOut : ProductPort;
    }

    part def SpaReagentPilot :> ProcessingFacility {
        doc /* SPA troilite H2SO4 pilot - "first in-situ chemical production"
             * (Decision Framework Rev D DG-5.3, Y10 = P5), growing into the
             * progressive reagent substitution at SPA (DG-7.4, Y22 = P7: 10 % ->
             * 50 % in-situ H2SO4, Ca(OH)2 replaces NaOH). One element with two
             * phase attributes, both bound in SeleniteConfigurations to their
             * gates. The pilot equipment figures (5,000 kg, 50 kW, 1-5 t/yr)
             * stay in the gate criterion text (rule 3). Created at Wave 4B for
             * the "TODO Wave 4" gated element of DG-5.3 / DG-7.4; the PKT
             * plant is SEL-REAGENT-001 Rev A (ReagentPlant). Source: Decision
             * Framework Rev D P5 / P7 gates and s.1 transition 3; Strategy
             * v3.1 s.10.1. No SPA reagent document exists - TODO naming it
             * when written. */
        attribute redefines introducedIn = Phase::P5;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute productionScaleFrom = Phase::P7;
        port reagentOut : ReagentPort;
    }

    part def SpaProcessingFacility :> ProcessingFacility {
        doc /* SEL-PROC-001 Rev B: SPA KREEP processing facility, P7 (HOW
             * target), five circuits proving the flowsheet at ~0.4 t/yr.
             * Five is the document's design point, carried in this doc only
             * (count attributes are Wave 5). */
        attribute redefines introducedIn = Phase::P7;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        part referenceCircuit : ProcessingCircuit;
        part flowsheet : ZeroCarbonFlowsheet;
        part thUStage : ThUSeparationStage;
        port concentrateIn : ~OrePort;
        port reagentIn : ~ReagentPort;
        port reoOut : ProductPort;
        port thoriumOut : ThoriumPort;
        interface feedToCircuit : OreTransfer connect concentrateIn to referenceCircuit.oreIn;
        interface reagentToCircuit : ReagentTransfer connect reagentIn to referenceCircuit.reagentIn;
        interface circuitReoOut : ProductTransfer connect referenceCircuit.reoOut to reoOut;
        interface circuitThoriumOut : ThoriumTransfer connect referenceCircuit.thoriumOut to thoriumOut;
    }

    part def PktProcessingSpine :> ProcessingFacility {
        doc /* PKT processing spine at the PKT/highlands boundary with a ~180 deg
             * mining arc; circuits from P8 (308) growing to ~2.08 M at P14
             * (VC-09; values Wave 5). Fed by hauler tips and conveyor input.
             * Source: SEL-PROC-PKT-001 Rev B. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        part referenceCircuit : ProcessingCircuit {
            attribute redefines introducedIn = Phase::P8;
        }
        part flowsheet : ZeroCarbonFlowsheet;
        part thUStage : ThUSeparationStage;
        port oreInput : ~OrePort;
        port reagentInput : ~ReagentPort;
        port reoOutput : ProductPort;
        port thoriumOutput : ThoriumPort;
        port canisterDispatch : CanisterPort;
        port byProductOxygen : OxygenPort {
            doc /* KREEP processing liberates oxygen as a by-product; stored
                 * before any dumping (SEL-ECN-027) and lofted as LOX on MD-2
                 * at P14+ (SEL-ECON-001 Rev A revised s.8.4). */
        }
        interface feedToCircuit : OreTransfer connect oreInput to referenceCircuit.oreIn;
        interface reagentToCircuit : ReagentTransfer connect reagentInput to referenceCircuit.reagentIn;
        interface circuitReoOut : ProductTransfer connect referenceCircuit.reoOut to reoOutput;
        interface circuitThoriumOut : ThoriumTransfer connect referenceCircuit.thoriumOut to thoriumOutput;
    }

    part def OxalicAcidLine :> ProcessingFacility {
        doc /* Oxalic acid pilot at PKT by CO2 electroreduction (Decision
             * Framework Rev D DG-9.5, Y42 = P9) - a sub-line of the PKT
             * reagent plant. Created at Wave 4B for the "TODO Wave 4" gated
             * element of DG-9.5; bound to the gate in SeleniteConfigurations.
             * Source: Decision Framework Rev D P9 gates. The process is not in
             * SEL-REAGENT-001 Rev A as cited by the model - TODO naming the
             * reagent document revision that carries it. */
        attribute redefines introducedIn = Phase::P9;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        port reagentOut : ReagentPort;
    }

    part def ReagentPlant :> ProcessingFacility {
        doc /* PKT reagent plant from P8: H2SO4 from troilite, Ca(OH)2, in-situ
             * reagent fabrication per ECN-018; the oxalic-acid pilot line from
             * P9 (DG-9.5). Source: SEL-REAGENT-001 Rev A. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        part oxalicAcidLine : OxalicAcidLine;
        port reagentOutput : ReagentPort;
        port reagentFromSpaIn : ~ReagentPort;
        interface oxalicOut : ReagentTransfer connect oxalicAcidLine.reagentOut to reagentOutput;
    }

    part def Foundry :> ProcessingFacility {
        doc /* SEL-FAB-001 Rev A: PKT foundry for in-situ hauler, circuit and
             * conveyor components (MRE Al-Si, Fe-Si, Fe-Ni from asteroid
             * feedstock via MD-1). Pilot at P8, at scale from P9. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        attribute atScaleFrom = Phase::P9;
        port feedstockIn : ~ProductPort;
        port metalOut : ProductPort;
    }

    part def RelayDepot :> ProcessingFacility {
        doc /* Relay depot for tiered depth mining (Tier 2/3 haul distances) at
             * PKT in later phases. ARCHITECTURE_BASELINE.md s.4 gives no phase;
             * introducedIn is deliberately unbound at definition level; Wave 3
             * binds it in SeleniteConfigurations to DG-POST.1 (Decision
             * Framework Rev D s.10.2, ~Y280+: Tier 1 approaching depletion),
             * so the depot appears when the tiering gate says so. */
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
    }

    part def FlowsheetStep {
        doc /* One unit operation of the zero-carbon flowsheet (Strategy v3.1
             * s.10.1); the unit operation it performs is an action in
             * SeleniteBehaviour::KreepFlowsheet. Chemistry, temperatures and
             * reagent rates are SEL-PROC-001 Rev B values bound at Wave 5. */
        attribute stepName : String;
        port feed : ~ProcessStreamPort;
        port product : ProcessStreamPort;
    }

    part def ZeroCarbonFlowsheet {
        doc /* Eight-step zero-carbon KREEP flowsheet (Strategy v3.1 s.10,
             * ARCHITECTURE_BASELINE.md s.6): acid bake (Th as ThP2O7) ->
             * Ca(OH)2 precipitation -> U removal via H2O2 -> Ce oxidation ->
             * LREE/HREE split -> (NH4)2SO4 LREE -> H3PO4 HREE -> calcination
             * -> mixed oxide concentrates to Earth (individual SX on Earth).
             * No D2EHPA anywhere (SEL-REQ-004, asserted on usesD2ehpa).
             * Th(OH)4 -> ThCl4 MSR fuel. */
        attribute usesD2ehpa : Boolean = false;
        assert constraint noOrganicSolventExtraction {
            doc /* ECN-019 Rev C committed decision (Strategy v3.1 s.10.1). */
            usesD2ehpa == false
        }
        part acidBake : FlowsheetStep {
            attribute redefines stepName = "acid bake";
        }
        part calciumHydroxidePrecipitation : FlowsheetStep {
            attribute redefines stepName = "Ca(OH)2 precipitation";
        }
        part uraniumPeroxideRemoval : FlowsheetStep {
            attribute redefines stepName = "U removal via H2O2";
        }
        part ceriumOxidation : FlowsheetStep {
            attribute redefines stepName = "Ce oxidation";
        }
        part lreeHreeSplit : FlowsheetStep {
            attribute redefines stepName = "LREE/HREE split";
        }
        part lreeAmmoniumSulfate : FlowsheetStep {
            attribute redefines stepName = "(NH4)2SO4 LREE";
        }
        part hreePhosphoric : FlowsheetStep {
            attribute redefines stepName = "H3PO4 HREE";
        }
        part calcination : FlowsheetStep {
            attribute redefines stepName = "calcination";
        }
        part thoriumConversion : FlowsheetStep {
            attribute redefines stepName = "Th(OH)4 -> ThCl4";
        }
        interface bakeToPrecipitation : ProcessStreamLink connect acidBake.product to calciumHydroxidePrecipitation.feed;
        interface precipitationToUranium : ProcessStreamLink connect calciumHydroxidePrecipitation.product to uraniumPeroxideRemoval.feed;
        interface uraniumToCerium : ProcessStreamLink connect uraniumPeroxideRemoval.product to ceriumOxidation.feed;
        interface ceriumToSplit : ProcessStreamLink connect ceriumOxidation.product to lreeHreeSplit.feed;
        interface splitToLree : ProcessStreamLink connect lreeHreeSplit.product to lreeAmmoniumSulfate.feed;
        interface splitToHree : ProcessStreamLink connect lreeHreeSplit.product to hreePhosphoric.feed;
        interface lreeToCalcination : ProcessStreamLink connect lreeAmmoniumSulfate.product to calcination.feed;
        interface hreeToCalcination : ProcessStreamLink connect hreePhosphoric.product to calcination.feed;
        interface bakeToThorium : ProcessStreamLink connect acidBake.product to thoriumConversion.feed;
    }

    part def ThUSeparationStage {
        doc /* Organic-solvent-free Th/U separation from KREEP leach liquor.
             * Candidate architectures per the Th/U preprint; selection OPEN
             * (waits on the preprint - out of Wave 4B scope by the brief s.6;
             * TODO naming the preprint when it is in docs/). Constraint: no
             * D2EHPA (SEL-REQ-004). */
        attribute usesD2ehpa : Boolean = false;
        assert constraint noOrganicSolventExtraction {
            doc /* Whatever architecture the preprint selects, it is
                 * organic-solvent-free. */
            usesD2ehpa == false
        }
    }

    part def KreepFeedstock {
        doc /* PKT KREEP terrane ore feed (resource basis per Strategy v3.1;
             * values Wave 5). */
    }

    part def AsteroidProcessStep {
        doc /* One process of an asteroid line, with its eclipse operating
             * behaviour (Wave 4A, D1). pausableThroughEclipse: the step can be
             * scheduled outside the eclipse (or, for a batch process, scheduled
             * as whole batches between eclipses). holdLoadFraction: the share of
             * the step's rated electrical load that must be carried through an
             * eclipse to hold it (thermal keep-warm, controls) - UNBOUND unless
             * a process source gives a value; SEL-PROC-C-001 / SEL-PROC-S-001 do
             * not exist, Decision Framework s.10.1 and Strategy v3.1 s.5.1 give
             * loads, not hold fractions. The Python evaluator carries a declared
             * working assumption per step (selenite.scenarios.eclipse
             * ASSUMED_HOLD_LOAD_FRACTION) and the register marks it ASSUMED.
             * minimumContinuousRunHours: the run that cannot be interrupted
             * (a Czochralski batch), compared with the sunlit window by
             * SeleniteAnalysis::SunlitWindowGate. */
        attribute stepName : String;
        attribute pausableThroughEclipse : Boolean;
        attribute holdLoadFraction : PointReal;
        attribute minimumContinuousRunHours : Real [0..1];
    }

    abstract part def AsteroidProcessingLine :> ProcessingFacility {
        doc /* Captured-asteroid concentrate processing at SPA (all asteroid
             * processing at SPA, never PKT - fleet v9 s.1 item 6). Wave 4A: the
             * line carries its eclipse operating behaviour (D1) as a whole and
             * per step; the Decision Framework s.10.1 loads (50 MWe at Y105 for
             * the C-type line, 100 MWe at Y125 for the S-type line, +100 MWe at
             * Y140 scaled operations) are per line, so the line-level hold
             * fraction is what the evaluator reads; the step split is recorded
             * for the process sources that will bind it. */
        attribute redefines location = SiteId::spa;
        attribute pausableThroughEclipse : Boolean;
        attribute holdLoadFraction : PointReal;
        attribute minimumContinuousRunHours : Real [0..1];
        port concentrateIn : ~OrePort;
        port productOut : ProductPort;
    }

    part def MTypeProcessingLine :> AsteroidProcessingLine {
        doc /* M-type: magnetic separation -> chlorination -> PGM; Fe-Ni to the
             * PKT foundry via MD-1. Online Y85 (P12); the captured-asteroid
             * scale-up of the PROBE-era SpaPgmHydromet. Source: fleet v9 s.17.3.
             * Wave 4A: aqueous hydrometallurgy can pause between leach batches;
             * no Decision Framework s.10.1 load is sized for it (the SPA MSRs
             * are sized for the C-type and S-type lines), so D1 carries it
             * without a load. */
        attribute redefines introducedIn = Phase::P12;
        attribute redefines retiredIn = null;
        attribute redefines pausableThroughEclipse = true;
        part hydromet : AsteroidProcessStep {
            attribute redefines stepName = "PGM hydromet (magnetic separation, chlorination, leach)";
            attribute redefines pausableThroughEclipse = true;
        }
    }

    part def CTypeProcessingLine :> AsteroidProcessingLine {
        doc /* C-type: pyrolysis + Fischer-Tropsch (water, carbon, nitrogen;
             * propellant independence). Online Y105 = P12 by the year table
             * (W2-N7 resolved 14 Sep 2026: years authoritative; documents
             * that file this under P13 carry a stale phase label).
             * Wave 4A (D1): both steps are continuous thermal processes
             * (ECN-022 s.2.4) that can nevertheless be scheduled outside the
             * eclipse and held warm through it (Jason, 19 Sep 2026: "fine if
             * the power-intensive work is done while the eclipse is not
             * present"); pausable, hold fraction unbound (ASSUMED 0.25 in the
             * evaluator). Load: Decision Framework s.10.1, 50 MWe from Y105.
             * SEL-ECN-023 (6 Nov 2026): the sunlit duty cycle is the operating
             * rule. */
        attribute redefines introducedIn = Phase::P12;
        attribute redefines retiredIn = null;
        attribute redefines pausableThroughEclipse = true;
        part pyrolysis : AsteroidProcessStep {
            attribute redefines stepName = "pyrolysis (water, volatiles)";
            attribute redefines pausableThroughEclipse = true;
        }
        part fischerTropsch : AsteroidProcessStep {
            attribute redefines stepName = "Fischer-Tropsch (carbon, hydrocarbons)";
            attribute redefines pausableThroughEclipse = true;
        }
    }

    part def STypeProcessingLine :> AsteroidProcessingLine {
        doc /* S-type: Czochralski Si + Cu electrolysis (in-situ sensors and
             * wiring). Online Y125 = P13 by the year table (W2-N7 resolved:
             * years authoritative; the P14 label in the documents is stale).
             * P14 therefore has no new asteroid arrival - it is the scale-up
             * to 2.5 Mt/yr with all three streams flowing.
             * Wave 4A (D1): Czochralski growth cannot pause mid-crystal, so its
             * eclipse strategy is scheduling whole batches between eclipses
             * (open question 3: a 1-3 day batch fits the sunlit window,
             * SunlitWindowGate); the furnace is cold between batches, so its
             * hold load is nil and the eclipse cost is scheduling slack.
             * Copper electrolysis can pause. minimumContinuousRunHours is bound
             * in the configuration to ProgrammeParameters.czochralskiBatchHours.
             * Load: Decision Framework s.10.1, 100 MWe from Y125. */
        attribute redefines introducedIn = Phase::P13;
        attribute redefines retiredIn = null;
        attribute redefines pausableThroughEclipse = true;
        part czochralski : AsteroidProcessStep {
            attribute redefines stepName = "Czochralski silicon growth (batch)";
            attribute redefines pausableThroughEclipse = true;
        }
        part copperElectrolysis : AsteroidProcessStep {
            attribute redefines stepName = "copper electrolysis";
            attribute redefines pausableThroughEclipse = true;
        }
    }
}
