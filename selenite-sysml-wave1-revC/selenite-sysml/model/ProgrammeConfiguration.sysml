package SeleniteConfigurations {
    doc /* Programme instance tree at the ECN-019 Rev C + ECN-020 baseline,
         * extended at Wave 2 to every phase-gated element: timeline, seven
         * nodes, fleet classes at their home sites, SPA/PKT/DRO facilities,
         * PSR network, mass driver network and other links, SENTINEL system,
         * with the committed-principle requirements satisfied. Every usage
         * inherits introducedIn / retiredIn from its definition, so the tree
         * can be queried per phase. Fleet-scale counts remain configuration
         * attributes (Wave 5 fills them from Python); enumerated multiplicities
         * appear only where the count is the architecture. */

    private import ScalarValues::*;
    private import SeleniteFleet::*;
    private import SeleniteHabitat::*;
    private import SelenitePhases::*;
    private import SelenitePower::*;
    private import SeleniteProcessing::*;
    private import SelenitePsrNetwork::*;
    private import SeleniteRequirements::*;
    private import SeleniteSites::*;
    private import SeleniteSoftware::*;
    private import SeleniteTransport::*;

    part seleniteProgramme {
        doc /* Root programme assembly - dual-site architecture with Earth,
             * relay, DRO and PSR nodes. */

        part timeline : ProgrammeTimeline;

        // ---- Earth and orbital nodes ----------------------------------

        part earth : EarthNode {
            attribute redefines nodeName = "Earth";
            attribute redefines role = "launch origin, market, individual SX, Earth ops hub";
            part probeScout : ProbeScout;
            part starshipCargo : StarshipCargoLink;
        }

        part emL2Relays : RelayConstellation {
            attribute redefines nodeName = "EML-2 relay constellation";
            attribute redefines role = "continuous south-pole comms";
        }

        part pktRelay : PktRelaySatellite {
            attribute redefines nodeName = "PKT relay satellite";
            attribute redefines role = "SPA<->PKT 0.5 s supervision link";
        }

        // ---- SPA Shackleton -------------------------------------------

        part shackletonHub : CrewedHub {
            doc /* SPA Shackleton crewed hub, Connecting Ridge. */
            attribute redefines nodeName = "SPA Shackleton";
            attribute redefines role = "crewed hub, proving ground, ISRU, asteroid processing, Ops Hub";

            part habComplex : HabitatComplex {
                part redefines referenceModule : HabModule {
                    attribute redefines crewCapacity = 20;
                }
            }
            part lifeSupport : Eclss;
            part isru : IsruPlant;
            part industrialZone : IndustrialZone {
                part emCatcher : EmCatcher;
            }
            part landingZone : SpaLandingZone;
            part greenhouse : Greenhouse;
            part crewReturnVehicle : CrewReturnVehicle;
            part powerZone : SpaPowerZone;
            part processingFacility : SpaProcessingFacility;
            part mTypeLine : MTypeProcessingLine;
            part cTypeLine : CTypeProcessingLine;
            part sTypeLine : STypeProcessingLine;

            // SPA fleet (one usage per class; counts are Wave 5 attributes)
            part probeMkI : ProbeMkI;
            part probeMkII : ProbeMkII;
            part probeMkIII : ProbeMkIII;
            part survey : Survey;
            part moleS : MoleS;
            part sinter : Sinter;
            part armC : ArmC;
            part armD : ArmD;
            part sentinelRover : SentinelRover;
            part skip : Skip;
            part dart : Dart;
            part harvest : Harvest;
            part cap : Cap;

            part skipHops : SkipHopLink;
            part earthReturnCapsules : EarthReturnCapsuleLink;
            part massDriverDemonstrator : MassDriverDemonstrator;
            part probeReturns : ProbeReturnLink;
            part psrAccess : PsrAccessLink;

            connect isru.propellantToIz to industrialZone.propellantFromIsru;
            connect industrialZone.emCatcherBerth to emCatcher.inboundCanisters;
            connect industrialZone.beneficiation to processingFacility;
        }

        part shackletonPsrFloor : PsrFloor {
            doc /* Shackleton PSR floor: MOLE-I network. */
            attribute redefines nodeName = "Shackleton PSR floor";
            attribute redefines role = "MOLE-I ice network (fishbone)";
            part psrNetwork : PsrNetwork;
            part moleIMkI : MoleIMkI;
            part moleIMkII : MoleIMkII;
            connect psrNetwork.moleIFleetTethers to moleIMkI;
            connect psrNetwork.moleIFleetTethers to moleIMkII;
        }

        connect shackletonHub.powerZone.psrTrunkFeed to shackletonPsrFloor.psrNetwork.rimPowerFeed;
        connect shackletonPsrFloor.psrNetwork.rimIsruWaterReturn to shackletonHub.isru.psrWaterInlet;

        // ---- PKT Procellarum ------------------------------------------

        part pktFactory : AutonomousFactory {
            doc /* PKT autonomous factory. Zero permanent crew, ever. */
            attribute redefines nodeName = "PKT Procellarum KREEP Terrane";
            attribute redefines role = "autonomous KREEP factory";

            attribute circuitCountAtP14 : Real = 2080000.0;
            doc circuitCountNote /* Inherited from Wave 1 (PROC-PKT-001 Rev B).
                 * VC-09 records 2,083,334 (ECON v1.3 / fleet v9 s.14) against
                 * this rounded figure; Wave 5 replaces it with the Python
                 * vector. Not altered here (rule 4). */
            attribute msrUnitCountAtP14 : Real = 6890.0;
            doc msrCountNote /* Inherited from Wave 1. VC-09: 6,890 (PROC-PKT Rev B,
                 * fleet v9) vs 8,334 (ECON v1.3 Y200). Both recorded; not
                 * adjudicated until Wave 5. */

            part processingSpine : PktProcessingSpine;
            part reagentPlant : ReagentPlant;
            part foundry : Foundry;
            part relayDepot : RelayDepot;
            part powerSystem : PktPowerSystem;
            part temporaryCrewHab : PktTemporaryCrewHab;
            part landingZone : PktLandingZone;
            part conveyorNetwork : ConveyorNetwork;
            part roadNetwork : HaulerRoadNetwork;

            // PKT fleet
            part hauler : HaulerRevB;
            part sinterPkt : Sinter;
            part armCPkt : ArmC;
            part sentinelRoverPkt : SentinelRover;
            doc dartNote /* DART (single unit, shackletonHub.dart) is PKT-based on
                 * surface power from P8 (Dart.pktBasedFrom); not a second usage. */

            connect conveyorNetwork.spineDelivery to processingSpine.oreInput;
            connect reagentPlant.reagentOutput to processingSpine.reagentInput;
            connect processingSpine.thoriumOutput to powerSystem.thcl4FuelInlet;
        }

        // ---- DRO --------------------------------------------------------

        part droStation : DroStation {
            attribute redefines nodeName = "DRO station";
            attribute redefines role = "captured-asteroid processing";
            part laserAblationTruss : LaserAblationTruss;
            part redirectTug : RedirectTug;
        }

        // ---- Logistics network ----------------------------------------

        part massDriverNetwork : MassDriverNetwork {
            doc /* MD-1 SPA->PKT (2 tracks), MD-2 PKT->Earth (3), MD-3 PKT->SPA,
                 * MD-4 SPA->Earth, MD-5 DRO->SPA (1 each). */
        }
        connect shackletonHub to massDriverNetwork.md1;
        connect massDriverNetwork.md1 to pktFactory;
        connect pktFactory to massDriverNetwork.md2;
        connect massDriverNetwork.md2 to earth;
        connect pktFactory to massDriverNetwork.md3;
        connect massDriverNetwork.md3 to shackletonHub.industrialZone.emCatcher;
        connect shackletonHub to massDriverNetwork.md4;
        connect massDriverNetwork.md4 to earth;
        connect droStation to massDriverNetwork.md5;
        connect massDriverNetwork.md5 to shackletonHub.industrialZone.emCatcher;

        // ---- Supervision --------------------------------------------------

        part sentinelSystem : SentinelSystem {
            doc /* Supervision from Earth (P2-P3) -> SPA Ops Hub (P4+); SPA
                 * supervises PKT at 0.5 s from P8. */
        }
        connect sentinelSystem.earthLink to earth;
        connect sentinelSystem.pktRelayLink to pktRelay;
        connect sentinelSystem.cryoValveMonitoring.monitoredStations
            to shackletonHub.isru.cryoTransferValveStations;
        connect sentinelSystem.o2SupplyMonitoring.o2LineSensors
            to shackletonHub.habComplex.o2SupplyLine;

        // ---- Committed-principle requirements -------------------------

        requirement zeroCrewPkt : ZeroPermanentCrewAtPkt {
            subject site = pktFactory;
        }
        satisfy zeroCrewPkt by pktFactory;

        requirement noSkipsPkt : NoSkipOperationsAtPkt {
            subject site = pktFactory;
        }
        satisfy noSkipsPkt by pktFactory;
    }
}
