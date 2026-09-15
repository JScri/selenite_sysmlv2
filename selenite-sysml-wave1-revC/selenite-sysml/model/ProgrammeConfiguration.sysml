package SeleniteConfigurations {
    doc /* Programme instance tree at the ECN-019 Rev C + ECN-020 baseline,
         * extended at Wave 2 to every phase-gated element: timeline, seven
         * nodes, fleet classes at their home sites, SPA/PKT/DRO facilities,
         * PSR network, mass driver network and other links, SENTINEL system,
         * with the committed-principle requirements satisfied. Every usage
         * inherits introducedIn / retiredIn from its definition, so the tree
         * can be queried per phase. Fleet-scale counts remain configuration
         * attributes (Wave 5 fills them from Python); enumerated multiplicities
         * appear only where the count is the architecture.
         *
         * Wave 3 (15 Sep 2026) - the derived plan. Every phase attribute in
         * the model is classified in CHANGELOG_WAVE3.md as one of:
         * (a) CONSEQUENCE of a decision gate: re-bound here to that gate's
         *     derivedPhase (SeleniteGates), the way StarshipReturnLink.
         *     retiredIn = massDriverNetwork.md4.operationalFrom was bound at
         *     Wave 2. The definition-level value stays as the document's
         *     candidate; derivedPhase is unbound until the Wave 5 planner
         *     fills it, so a re-bound attribute reads "whatever the gate
         *     decides" - the literal form of the rule that timing is not
         *     gated on a predetermined phase. tools/plan_check.py prints the
         *     declared-vs-derived register from these bindings.
         * (b) EXOGENOUS: the gate's year is a ProgrammeParameters attribute
         *     (asteroid captures); derivedYear is bound on the gate usage in
         *     the catalogue below and the element binds to the gate.
         * (c) FIXED by architecture or policy (relay constellation P1, the
         *     PSR network with its floor, the SPA processing facility that
         *     ECN-015 made unconditional): left as defined. */

    private import ScalarValues::*;
    private import SeleniteFleet::*;
    private import SeleniteGates::*;
    private import SeleniteHabitat::*;
    private import SeleniteParameters::*;
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
        part parameters : ProgrammeParameters;

        part gates : GateCatalogue {
            doc /* Exogenous gates whose year is a declared parameter carry
                 * derivedYear bound to it here (classification (b)); every
                 * derivedPhase and every other derivedYear stays unbound for
                 * the Wave 5 planner. */
            part redefines dgElevenEight : DgElevenEight {
                attribute redefines derivedYear = parameters.mTypeCaptureYear;
            }
            part redefines dgTwelveFour : DgTwelveFour {
                attribute redefines derivedYear = parameters.mTypeCaptureYear + parameters.asteroidOnlineLagYears;
            }
            part redefines dgTwelveFive : DgTwelveFive {
                attribute redefines derivedYear = parameters.mTypeCaptureYear + parameters.asteroidOnlineLagYears;
            }
            part redefines dgThirteenTwo : DgThirteenTwo {
                attribute redefines derivedYear = parameters.cTypeCaptureYear;
            }
            part redefines dgFourteenOne : DgFourteenOne {
                attribute redefines derivedYear = parameters.cTypeCaptureYear;
            }
            part redefines dgThirteenThree : DgThirteenThree {
                attribute redefines derivedYear = parameters.cTypeCaptureYear + parameters.asteroidOnlineLagYears;
            }
            part redefines dgThirteenSix : DgThirteenSix {
                attribute redefines derivedYear = parameters.sTypeCaptureYear;
            }
            part redefines dgFourteenTwo : DgFourteenTwo {
                attribute redefines derivedYear = parameters.sTypeCaptureYear;
            }
            part redefines dgFourteenThree : DgFourteenThree {
                attribute redefines derivedYear = parameters.sTypeCaptureYear + parameters.asteroidOnlineLagYears;
            }
        }

        // ---- Earth and orbital nodes ----------------------------------

        part earth : EarthNode {
            attribute redefines nodeName = "Earth";
            attribute redefines role = "launch origin, market, individual SX, Earth ops hub";
            part probeScout : ProbeScout {
                attribute redefines introducedIn = gates.dgOneOne.derivedPhase;
            }
            part starshipCargo : StarshipCargoLink {
                attribute redefines introducedIn = gates.dgOneOne.derivedPhase;
                attribute redefines operationalFrom = gates.dgOneOne.derivedPhase;
                attribute redefines pktDeliveriesFrom = gates.dgEightOne.derivedPhase;
            }
        }

        part emL2Relays : RelayConstellation {
            doc /* Fixed (c): built P0, deployed P1 - the first hardware. */
            attribute redefines nodeName = "EML-2 relay constellation";
            attribute redefines role = "continuous south-pole comms";
        }

        part pktRelay : PktRelaySatellite {
            attribute redefines nodeName = "PKT relay satellite";
            attribute redefines role = "SPA<->PKT 0.5 s supervision link";
            attribute redefines existsFrom = gates.dgEightOne.derivedPhase;
        }

        // ---- SPA Shackleton -------------------------------------------

        part shackletonHub : CrewedHub {
            doc /* SPA Shackleton crewed hub, Connecting Ridge. Exists with the
                 * first cargo landing (DG-1.1); crewed and commanded from the
                 * crew sign-off (DG-4.1). */
            attribute redefines nodeName = "SPA Shackleton";
            attribute redefines role = "crewed hub, proving ground, ISRU, asteroid processing, Ops Hub";
            attribute redefines existsFrom = gates.dgOneOne.derivedPhase;
            attribute redefines crewedFrom = gates.dgFourOne.derivedPhase;
            attribute redefines opsHubFrom = gates.dgFourOne.derivedPhase;

            part habComplex : HabitatComplex {
                attribute redefines crewedFrom = gates.dgFourOne.derivedPhase;
                part redefines referenceModule : HabModule {
                    attribute redefines crewCapacity = 20;
                }
            }
            part lifeSupport : Eclss {
                attribute redefines introducedIn = gates.dgFourTwo.derivedPhase;
            }
            part isru : IsruPlant {
                attribute redefines selfSufficientFrom = gates.dgFourThree.derivedPhase;
            }
            part industrialZone : IndustrialZone {
                part redefines beneficiation : BeneficiationPlant {
                    attribute redefines introducedIn = gates.dgFiveTwo.derivedPhase;
                }
                part emCatcher : EmCatcher {
                    doc /* Bound to MD-3 (DG-9.6): the PKT->SPA driver needs its
                         * receiver (W2-N3); the definition keeps P11. */
                    attribute redefines introducedIn = gates.dgNineSix.derivedPhase;
                    attribute redefines operationalFrom = gates.dgNineSix.derivedPhase;
                }
            }
            part landingZone : SpaLandingZone;
            part greenhouse : Greenhouse;
            part crewReturnVehicle : CrewReturnVehicle {
                attribute redefines introducedIn = gates.dgFourOne.derivedPhase;
            }
            part powerZone : SpaPowerZone {
                part redefines spaMsr : SpaThoriumMSR {
                    doc /* F5: demand-gated through DG-10.5 (SpaMsrIntroductionGate). */
                    attribute redefines introducedIn = gates.dgTenFive.derivedPhase;
                }
            }
            part processingFacility : SpaProcessingFacility {
                doc /* Fixed (c): processing is a core element, not conditional
                     * (ECN-015 retired the Y12 gate, DG-6.1). */
            }
            part mTypeLine : MTypeProcessingLine {
                attribute redefines introducedIn = gates.dgTwelveFour.derivedPhase;
            }
            part cTypeLine : CTypeProcessingLine {
                attribute redefines introducedIn = gates.dgThirteenThree.derivedPhase;
            }
            part sTypeLine : STypeProcessingLine {
                attribute redefines introducedIn = gates.dgFourteenThree.derivedPhase;
            }

            // SPA fleet (one usage per class; counts are Wave 5 attributes)
            part probeMkI : ProbeMkI {
                attribute redefines isruFuelledFrom = gates.dgFourThree.derivedPhase;
                attribute redefines retiredIn = gates.dgElevenSix.derivedPhase;
            }
            part probeMkII : ProbeMkII;
            part probeMkIII : ProbeMkIII {
                attribute redefines introducedIn = gates.dgElevenSix.derivedPhase;
                attribute redefines prospectingRoleFrom = gates.dgFourteenNine.derivedPhase;
            }
            part survey : Survey {
                attribute redefines introducedIn = gates.dgOneOne.derivedPhase;
            }
            part moleS : MoleS;
            part sinter : Sinter {
                attribute redefines pktFrom = gates.dgEightOne.derivedPhase;
            }
            part armC : ArmC {
                attribute redefines pktFrom = gates.dgEightOne.derivedPhase;
            }
            part armD : ArmD;
            part sentinelRover : SentinelRover {
                attribute redefines pktFrom = gates.dgEightOne.derivedPhase;
            }
            part skip : Skip {
                doc /* Introduced by the SKIP first-hop clearance (DG-2.2);
                     * retired when MD-2 carries the exports (DG-9.1, through
                     * the driver's own phase, as StarshipReturnLink). */
                attribute redefines introducedIn = gates.dgTwoTwo.derivedPhase;
                attribute redefines retiredIn = massDriverNetwork.md2.operationalFrom;
            }
            part dart : Dart {
                attribute redefines introducedIn = gates.dgFiveOne.derivedPhase;
                attribute redefines pktSiteConfirmationIn = gates.dgSixThree.derivedPhase;
                attribute redefines pktBasedFrom = gates.dgEightOne.derivedPhase;
            }
            part harvest : Harvest;
            part cap : Cap {
                attribute redefines introducedIn = gates.dgFourOne.derivedPhase;
            }

            part skipHops : SkipHopLink {
                attribute redefines introducedIn = gates.dgTwoTwo.derivedPhase;
                attribute redefines operationalFrom = gates.dgTwoTwo.derivedPhase;
                attribute redefines retiredIn = massDriverNetwork.md2.operationalFrom;
            }
            part starshipReturn : StarshipReturnLink {
                doc /* Starts with the first export batch (DG-5.4). Retirement
                     * derived, not transcribed: the Starship return stream
                     * ends in the phase MD-4 (SPA->Earth) comes online. */
                attribute redefines introducedIn = gates.dgFiveFour.derivedPhase;
                attribute redefines operationalFrom = gates.dgFiveFour.derivedPhase;
                attribute redefines retiredIn = massDriverNetwork.md4.operationalFrom;
            }
            part massDriverDemonstrator : MassDriverDemonstrator {
                doc /* Fixed (c) at P7 (final report Fig. 27); DG-8.8 places a
                     * demonstrator at PKT in P8 - conflict W3-N11, not bound. */
            }
            part probeReturns : ProbeReturnLink {
                attribute redefines mkIiiCanisterStreamFrom = gates.dgElevenSix.derivedPhase;
            }
            part psrAccess : PsrAccessLink;

            connect isru.propellantToIz to industrialZone.propellantFromIsru;
            connect industrialZone.emCatcherBerth to emCatcher.inboundCanisters;
            connect industrialZone.beneficiation to processingFacility;
        }

        part shackletonPsrFloor : PsrFloor {
            doc /* Shackleton PSR floor: MOLE-I network. Fixed (c) at P3 with
                 * its network; crew contingency access follows DG-4.1. */
            attribute redefines nodeName = "Shackleton PSR floor";
            attribute redefines role = "MOLE-I ice network (fishbone)";
            attribute redefines contingencyCrewAccessFrom = gates.dgFourOne.derivedPhase;
            part psrNetwork : PsrNetwork {
                part redefines crewWinch : CrewWinch {
                    attribute redefines introducedIn = gates.dgFourOne.derivedPhase;
                }
                part redefines capGuideCable : CapGuideCable {
                    attribute redefines introducedIn = gates.dgFourOne.derivedPhase;
                }
            }
            part moleIMkI : MoleIMkI;
            part moleIMkII : MoleIMkII {
                attribute redefines declineDrivenByMkIIIFrom = gates.dgElevenSix.derivedPhase;
            }
            connect psrNetwork.moleIFleetTethers to moleIMkI;
            connect psrNetwork.moleIFleetTethers to moleIMkII;
        }

        connect shackletonHub.powerZone.psrTrunkFeed to shackletonPsrFloor.psrNetwork.rimPowerFeed;
        connect shackletonPsrFloor.psrNetwork.rimIsruWaterReturn to shackletonHub.isru.psrWaterInlet;

        // ---- PKT Procellarum ------------------------------------------

        part pktFactory : AutonomousFactory {
            doc /* PKT autonomous factory. Zero permanent crew, ever. Exists
                 * from PKT construction start (DG-8.1, the consequence of the
                 * DG-7.1 commitment); site confirmed by DART (DG-6.3). */
            attribute redefines nodeName = "PKT Procellarum KREEP Terrane";
            attribute redefines role = "autonomous KREEP factory";
            attribute redefines existsFrom = gates.dgEightOne.derivedPhase;
            attribute redefines siteConfirmedIn = gates.dgSixThree.derivedPhase;
            attribute redefines temporaryCrewOnlyIn = gates.dgEightSix.derivedPhase;

            attribute circuitCountAtP14 : Real = 2080000.0;
            doc circuitCountNote /* Inherited from Wave 1 (PROC-PKT-001 Rev B).
                 * VC-09 records 2,083,334 (ECON v1.3 / fleet v9 s.14) against
                 * this rounded figure; Wave 5 replaces it with the Python
                 * vector. Not altered here (rule 4). */
            attribute msrUnitCountAtP14 : Real = 6890.0;
            doc msrCountNote /* Inherited from Wave 1. VC-09: 6,890 (PROC-PKT Rev B,
                 * fleet v9) vs 8,334 (ECON v1.3 Y200). Both recorded; not
                 * adjudicated until Wave 5. */

            part processingSpine : PktProcessingSpine {
                attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
            }
            part reagentPlant : ReagentPlant {
                attribute redefines introducedIn = gates.dgEightThree.derivedPhase;
            }
            part foundry : Foundry {
                attribute redefines introducedIn = gates.dgEightSix.derivedPhase;
                attribute redefines atScaleFrom = gates.dgNineFour.derivedPhase;
            }
            part relayDepot : RelayDepot {
                doc /* Wave 2 TODO closed: appears when DG-POST.1 says Tier 1 is
                     * approaching depletion. */
                attribute redefines introducedIn = gates.dgPost1.derivedPhase;
            }
            part powerSystem : PktPowerSystem {
                attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
                part redefines fspField : PktFspField {
                    attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
                    attribute redefines retiredIn = gates.dgTenFour.derivedPhase;
                }
                part redefines referenceMsr : ThoriumMSR {
                    attribute redefines introducedIn = gates.dgNineThree.derivedPhase;
                    attribute redefines replacesPktFspFrom = gates.dgTenFour.derivedPhase;
                    attribute redefines inSituVesselsFrom = gates.dgElevenFour.derivedPhase;
                }
                part redefines referenceHubStation : HubChargingStation {
                    attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
                }
            }
            part temporaryCrewHab : PktTemporaryCrewHab {
                doc /* Introduced by DG-8.6 and retired in the same phase
                     * (SEL-REQ-012). */
                attribute redefines introducedIn = gates.dgEightSix.derivedPhase;
                attribute redefines retiredIn = introducedIn;
            }
            part landingZone : PktLandingZone {
                attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
            }
            part conveyorNetwork : ConveyorNetwork {
                attribute redefines introducedIn = gates.dgNineSeven.derivedPhase;
                attribute redefines deployingFrom = gates.dgTenTwo.derivedPhase;
                part redefines referenceTrunk : SteelApronConveyor {
                    attribute redefines introducedIn = gates.dgNineSeven.derivedPhase;
                    attribute redefines operationalFrom = gates.dgNineSeven.derivedPhase;
                }
                part redefines referenceBranch : SteelApronConveyor {
                    attribute redefines introducedIn = gates.dgNineSeven.derivedPhase;
                    attribute redefines operationalFrom = gates.dgNineSeven.derivedPhase;
                }
            }
            part roadNetwork : HaulerRoadNetwork {
                attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
                attribute redefines operationalFrom = gates.dgEightOne.derivedPhase;
            }

            // PKT fleet
            part hauler : HaulerRevB {
                attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
            }
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
            doc /* Exists when the M-type asteroid arrives (DG-12.4, whose year
                 * is mTypeCaptureYear + asteroidOnlineLagYears). */
            attribute redefines nodeName = "DRO station";
            attribute redefines role = "captured-asteroid processing";
            attribute redefines existsFrom = gates.dgTwelveFour.derivedPhase;
            part laserAblationTruss : LaserAblationTruss {
                attribute redefines introducedIn = gates.dgTwelveFour.derivedPhase;
            }
            part redirectTug : RedirectTug {
                attribute redefines introducedIn = gates.dgElevenEight.derivedPhase;
                attribute redefines firstCaptureIn = gates.dgElevenEight.derivedPhase;
            }
        }

        // ---- Logistics network ----------------------------------------

        part massDriverNetwork : MassDriverNetwork {
            doc /* MD-1 SPA->PKT (2 tracks), MD-2 PKT->Earth (3), MD-3 PKT->SPA,
                 * MD-4 SPA->Earth, MD-5 DRO->SPA (1 each). Each driver's
                 * operational phase is the consequence of its gate. */
            attribute redefines introducedIn = gates.dgEightZero.derivedPhase;
            part redefines md1 : MassDriverMd1 {
                attribute redefines introducedIn = gates.dgEightZero.derivedPhase;
                attribute redefines operationalFrom = gates.dgEightZero.derivedPhase;
            }
            part redefines md2 : MassDriverMd2 {
                attribute redefines introducedIn = gates.dgNineOne.derivedPhase;
                attribute redefines operationalFrom = gates.dgNineOne.derivedPhase;
            }
            part redefines md3 : MassDriverMd3 {
                attribute redefines introducedIn = gates.dgNineSix.derivedPhase;
                attribute redefines operationalFrom = gates.dgNineSix.derivedPhase;
            }
            part redefines md4 : MassDriverMd4 {
                attribute redefines introducedIn = gates.dgElevenSix.derivedPhase;
                attribute redefines operationalFrom = gates.dgElevenSix.derivedPhase;
            }
            part redefines md5 : MassDriverMd5 {
                attribute redefines introducedIn = gates.dgTwelveFive.derivedPhase;
                attribute redefines operationalFrom = gates.dgTwelveFive.derivedPhase;
            }
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
            part redefines edge : SentinelEdgeTier {
                attribute redefines supervisedFromSpaFrom = gates.dgFourOne.derivedPhase;
                attribute redefines pktSupervisedFromSpaFrom = gates.dgEightOne.derivedPhase;
            }
            part redefines o2SupplyMonitoring : O2SupplyLineMonitoringFunction {
                attribute redefines introducedIn = gates.dgFourTwo.derivedPhase;
            }
        }
        connect sentinelSystem.earthLink to earth;
        connect sentinelSystem.pktRelayLink to pktRelay;
        connect sentinelSystem.cryoValveMonitoring.monitoredStations
            to shackletonHub.isru.cryoTransferValveStations;
        connect sentinelSystem.o2SupplyMonitoring.o2LineSensors
            to shackletonHub.habComplex.o2SupplyLine;

        // ---- Committed-principle requirements -------------------------

        requirement steadyStateTarget : SteadyStateReoTarget {
            subject params = parameters;
        }
        satisfy steadyStateTarget by parameters;

        requirement zeroCrewPkt : ZeroPermanentCrewAtPkt {
            subject site = pktFactory;
        }
        satisfy zeroCrewPkt by pktFactory;

        requirement noSkipsPkt : NoSkipOperationsAtPkt {
            subject site = pktFactory;
        }
        satisfy noSkipsPkt by pktFactory;

        requirement noD2ehpaSpa : NoD2ehpa {
            subject flowsheet = shackletonHub.processingFacility.flowsheet;
        }
        satisfy noD2ehpaSpa by shackletonHub.processingFacility.flowsheet;

        requirement noD2ehpaPkt : NoD2ehpa {
            subject flowsheet = pktFactory.processingSpine.flowsheet;
        }
        satisfy noD2ehpaPkt by pktFactory.processingSpine.flowsheet;

        requirement oreByConveyor : OreTransportByConveyor {
            subject network = pktFactory.conveyorNetwork;
        }
        satisfy oreByConveyor by pktFactory.conveyorNetwork;

        requirement noArmBelowRimSpaC : NoArmBelowRim {
            subject arm = shackletonHub.armC;
        }
        satisfy noArmBelowRimSpaC by shackletonHub.armC;

        requirement noArmBelowRimSpaD : NoArmBelowRim {
            subject arm = shackletonHub.armD;
        }
        satisfy noArmBelowRimSpaD by shackletonHub.armD;

        requirement noArmBelowRimPkt : NoArmBelowRim {
            subject arm = pktFactory.armCPkt;
        }
        satisfy noArmBelowRimPkt by pktFactory.armCPkt;

        requirement moleSSpaOnly : NoMoleSAtPkt {
            subject moleS = shackletonHub.moleS;
        }
        satisfy moleSSpaOnly by shackletonHub.moleS;

        requirement haulerPktOnly : HaulerPktOnly {
            subject hauler = pktFactory.hauler;
        }
        satisfy haulerPktOnly by pktFactory.hauler;

        requirement mkIiiNeverLands : MkIiiNeverLands {
            subject probe = shackletonHub.probeMkIII;
        }
        satisfy mkIiiNeverLands by shackletonHub.probeMkIII;

        requirement trackBudget : MassDriverTrackBudget {
            subject network = massDriverNetwork;
        }
        satisfy trackBudget by massDriverNetwork;

        requirement pktTemporaryCrew : PktTemporaryCrewOnlyInP8 {
            subject hab = pktFactory.temporaryCrewHab;
        }
        satisfy pktTemporaryCrew by pktFactory.temporaryCrewHab;

        requirement mTypeAtSpa : AsteroidProcessingAtSpa {
            subject line = shackletonHub.mTypeLine;
        }
        satisfy mTypeAtSpa by shackletonHub.mTypeLine;

        requirement cTypeAtSpa : AsteroidProcessingAtSpa {
            subject line = shackletonHub.cTypeLine;
        }
        satisfy cTypeAtSpa by shackletonHub.cTypeLine;

        requirement sTypeAtSpa : AsteroidProcessingAtSpa {
            subject line = shackletonHub.sTypeLine;
        }
        satisfy sTypeAtSpa by shackletonHub.sTypeLine;

        requirement probeMkIAtSpa : ProbesBasedAtSpa {
            subject probe = shackletonHub.probeMkI;
        }
        satisfy probeMkIAtSpa by shackletonHub.probeMkI;

        requirement probeMkIIAtSpa : ProbesBasedAtSpa {
            subject probe = shackletonHub.probeMkII;
        }
        satisfy probeMkIIAtSpa by shackletonHub.probeMkII;

        requirement circuitDesign : CircuitDesignCommitted {
            subject params = parameters;
        }
        satisfy circuitDesign by parameters;

        requirement psrCapacity : PsrCapacityFromLayout {
            subject params = parameters;
        }
        satisfy psrCapacity by parameters;
    }
}
