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
         * documents are revised (VC-15/16/17). */

    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;

    abstract part def ProcessingFacility :> PhaseGated {
        doc /* Base for fixed processing infrastructure. */
        abstract attribute location : SiteId;
    }

    part def ProcessingCircuit :> PhaseGated {
        doc /* Optimised continuous-flow circuit (committed design, fleet v9
             * s.14). Fleet-scale counts per phase are configuration values from
             * the Python layer (VC-09 records 2.08 M vs 2,083,334 and the MSR
             * mismatch). First five circuits at SPA in P7; PKT spine from P8. */
        attribute redefines introducedIn = Phase::P7;
        attribute redefines retiredIn = null;
    }

    part def BeneficiationPlant :> ProcessingFacility {
        doc /* KREEP beneficiation (10x upgrade) in the SPA Industrial Zone from
             * P5; first export Y10. Source: SEL-IZ-001 Rev B, baseline s.4. */
        attribute redefines introducedIn = Phase::P5;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
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
        port oreInput;
        port reagentInput;
        port reoOutput;
        port thoriumOutput;
    }

    part def ReagentPlant :> ProcessingFacility {
        doc /* PKT reagent plant from P8: H2SO4 from troilite, Ca(OH)2, in-situ
             * reagent fabrication per ECN-018. Source: SEL-REAGENT-001 Rev A. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        port reagentOutput;
    }

    part def Foundry :> ProcessingFacility {
        doc /* SEL-FAB-001 Rev A: PKT foundry for in-situ hauler, circuit and
             * conveyor components (MRE Al-Si, Fe-Si, Fe-Ni from asteroid
             * feedstock via MD-1). Pilot at P8, at scale from P9. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        attribute atScaleFrom = Phase::P9;
    }

    part def RelayDepot :> ProcessingFacility {
        doc /* Relay depot for tiered depth mining (Tier 2/3 haul distances) at
             * PKT in later phases. ARCHITECTURE_BASELINE.md s.4 gives no phase;
             * introducedIn is deliberately unbound until Wave 3 reads the
             * Decision Framework tiering gates (TODO Wave 3). */
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
    }

    part def FlowsheetStep {
        doc /* One unit operation of the zero-carbon flowsheet; chemistry,
             * temperatures and reagents are Wave 4 attributes. */
        attribute stepName : String;
        port feed;
        port product;
    }

    part def ZeroCarbonFlowsheet {
        doc /* Eight-step zero-carbon KREEP flowsheet (Strategy v3.1 s.10,
             * ARCHITECTURE_BASELINE.md s.6): acid bake (Th as ThP2O7) ->
             * Ca(OH)2 precipitation -> U removal via H2O2 -> Ce oxidation ->
             * LREE/HREE split -> (NH4)2SO4 LREE -> H3PO4 HREE -> calcination
             * -> mixed oxide concentrates to Earth (individual SX on Earth).
             * No D2EHPA anywhere (SEL-REQ-004). Th(OH)4 -> ThCl4 MSR fuel. */
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
        connect acidBake.product to calciumHydroxidePrecipitation.feed;
        connect calciumHydroxidePrecipitation.product to uraniumPeroxideRemoval.feed;
        connect uraniumPeroxideRemoval.product to ceriumOxidation.feed;
        connect ceriumOxidation.product to lreeHreeSplit.feed;
        connect lreeHreeSplit.product to lreeAmmoniumSulfate.feed;
        connect lreeHreeSplit.product to hreePhosphoric.feed;
        connect lreeAmmoniumSulfate.product to calcination.feed;
        connect hreePhosphoric.product to calcination.feed;
        connect acidBake.product to thoriumConversion.feed;
    }

    part def ThUSeparationStage {
        doc /* Organic-solvent-free Th/U separation from KREEP leach liquor.
             * Candidate architectures per the Th/U preprint; selection OPEN
             * (TODO Wave 4). Constraint: no D2EHPA (SEL-REQ-004). */
    }

    part def KreepFeedstock {
        doc /* PKT KREEP terrane ore feed (resource basis per Strategy v3.1;
             * values Wave 5). */
    }

    abstract part def AsteroidProcessingLine :> ProcessingFacility {
        doc /* Captured-asteroid concentrate processing at SPA (all asteroid
             * processing at SPA, never PKT - fleet v9 s.1 item 6). */
        attribute redefines location = SiteId::spa;
    }

    part def MTypeProcessingLine :> AsteroidProcessingLine {
        doc /* M-type: magnetic separation -> chlorination -> PGM; Fe-Ni to the
             * PKT foundry via MD-1. Online Y85 (P12). Source: fleet v9 s.17.3. */
        attribute redefines introducedIn = Phase::P12;
        attribute redefines retiredIn = null;
    }

    part def CTypeProcessingLine :> AsteroidProcessingLine {
        doc /* C-type: pyrolysis + Fischer-Tropsch (water, carbon, nitrogen;
             * propellant independence). Online Y105 (P13). */
        attribute redefines introducedIn = Phase::P13;
        attribute redefines retiredIn = null;
    }

    part def STypeProcessingLine :> AsteroidProcessingLine {
        doc /* S-type: Czochralski Si + Cu electrolysis (in-situ sensors and
             * wiring). Online Y125 (P14). */
        attribute redefines introducedIn = Phase::P14;
        attribute redefines retiredIn = null;
    }
}
