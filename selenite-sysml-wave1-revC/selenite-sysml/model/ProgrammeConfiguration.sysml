package SeleniteConfigurations {
    doc /* Programme instance tree: the two sites and their key
         * fleet/infrastructure content at the ECN-019 Rev C + ECN-020 baseline.
         * Counts are configuration attributes, not instantiated part
         * multiplicities, at this migration stage. */

    private import ScalarValues::*;
    private import SeleniteFleet::*;
    private import SeleniteHabitat::*;
    private import SelenitePhases::*;
    private import SelenitePower::*;
    private import SeleniteProcessing::*;
    private import SeleniteRequirements::*;
    private import SeleniteSites::*;
    private import SeleniteTransport::*;

    part seleniteProgramme {
        doc /* Root programme assembly — dual-site architecture. */

        part shackletonHub : CrewedHub {
            doc /* SPA Shackleton crewed hub: habitation, ISRU, asteroid
                 * processing centre, mass driver network. 20 crew at P7. */
            attribute redefines siteName = "SPA Shackleton";
            attribute redefines permanentCrew = 20;
            attribute redefines operationalFrom = Phase::P7;

            part habComplex : HabModule {
                attribute redefines crewCapacity = 20;
            }
            part isru : IsruPlant;
            part lifeSupport : Eclss;
            part massDriverNetwork : MassDriver[5] {
                doc /* 3x MD-2 + 2x MD-1 per ECN-020. */
            }
        }

        part pktFactory : AutonomousFactory {
            doc /* PKT Procellarum KREEP Terrane autonomous factory.
                 * Processing spine at PKT/highlands boundary, ~180 deg
                 * mining arc. Zero permanent crew, ever. */
            attribute redefines siteName = "PKT Procellarum KREEP Terrane";
            attribute redefines permanentCrew = 0;
            attribute redefines operationalFrom = Phase::P8;

            attribute circuitCountAtP14 : Real = 2080000.0;
            attribute msrUnitCountAtP14 : Real = 6890.0;

            part referenceCircuit : ProcessingCircuit;
            part thUStage : ThUSeparationStage;
            part referenceMsr : ThoriumMSR;
            part oreConveyor : SteelApronConveyor;

            connect oreConveyor to referenceCircuit;
        }

        requirement zeroCrewPkt : ZeroPermanentCrewAtPkt {
            subject site = pktFactory;
        }
        satisfy zeroCrewPkt by pktFactory;

        requirement noSkipsPkt : NoSkipOperationsAtPkt {
            subject site = pktFactory;
        }
    }
}
