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
         *     ECN-015 made unconditional): left as defined.
         *
         * Wave 4B (7 Nov 2026) - behaviour, interfaces and software. Every
         * connection in this tree is an interface usage typed by
         * SeleniteInterfaces (material, power, canister, supervision, sensor
         * and hardwired-close links); boundary ports of a usage are delegated
         * to internal parts with 'bind'. The value chain
         * (SeleniteBehaviour::ValueChain) is performed once here and every
         * step is allocated to the part that performs it; each performed
         * stream's phase is rebound by ':>>' to the phase of its performing
         * element, so the streams are gated by the same derived plan as the
         * elements (and tools/plan_check.py, which registers the
         * 'attribute redefines' bindings of parts, is unchanged by them).
         * The gated elements the Wave 3 catalogue named with "TODO Wave 4"
         * exist and are bound here (SpaReagentPilot to DG-5.3 / DG-7.4,
         * OxalicAcidLine to DG-9.5), with SpaPgmHydromet (DG-5.4) and the L1
         * O2 depot (existsFrom derived from MD-2's phase) - these are the
         * bindings that change the plan register this wave. The ECN-023
         * operating rule is the EclipseGatedPowerSupply interface on each
         * asteroid line and SEL-REQ-017, satisfied below. Addendum (7 Nov
         * 2026): the CAP's guide cable and floor power tap interfaces; no
         * binding changed, so the plan register is byte-identical. */

    private import ScalarValues::*;
    private import SeleniteBehaviour::*;
    private import SeleniteFleet::*;
    private import SeleniteGates::*;
    private import SeleniteHabitat::*;
    private import SeleniteInterfaces::*;
    private import SeleniteParameters::*;
    private import SelenitePhases::*;
    private import SelenitePower::*;
    private import SeleniteProcessing::*;
    private import SelenitePsrNetwork::*;
    private import SeleniteRequirements::*;
    private import SeleniteScenarios::*;
    private import SeleniteSites::*;
    private import SeleniteSoftware::*;
    private import SeleniteTransport::*;

    part seleniteProgramme {
        doc /* Root programme assembly - dual-site architecture with Earth,
             * relay, DRO and PSR nodes. */

        part timeline : ProgrammeTimeline;
        part parameters : ProgrammeParameters;

        // ---- Wave 4A: the sampled space, the decision catalogue and the --
        // ---- baseline's selections (the alternative each committed decision
        // ---- assumes; an open decision stays abstract) --------------------

        part uncertainty : UncertaintyRegister;
        part decisions : DecisionCatalogue;
        part trades : TradeStudySet;
        part scenarios : ScenarioSet;

        part d1 :> EclipseOperatingStrategy::sunlitDutyCycle;
        doc d1Doc /* SEL-ECN-023 (Jason, 6 Nov 2026): the sunlit duty cycle -
             * pausable steps outside the eclipse, plant oversized for the dark
             * fraction and restart losses, hold loads only through the eclipse;
             * spaAsteroidLoadCriticalFraction rebound 1.0 -> 0.18 (derived).
             * Supersedes ECN-022 s.2.4 (carry-through). The operating rule is
             * to be recorded as a requirement on the asteroid lines at Wave 4B. */
        part d2 :> SpaPowerSupplyMix::msrWhenJustified;
        doc d2Doc /* ECN-022 s.2.3: the SPA MSR when the cargo-mass trade says so
             * (incremental basis), first unit Y105. */
        abstract part d3 : CanisterRecoveryOption;
        doc d3Doc /* DG-9.1 canister recovery is open (canisterEarthContentKg
             * unbound); the economics assumed option 1b. Jason, 6 Nov 2026: in
             * scope for Wave 4A - the register carries the recommendation. */
        part d4 :> ProcessingCircuitDesign::optimisedDesign;
        doc d4Doc /* Decision Framework Rev D s.4 committed design; SEL-REQ-015. */
        part d5 :> MdFourRetirementTiming::consequenceOfMTypeArrival;
        doc d5Doc /* ECN-022 s.2.1 (a consequence, no alternative). */
        part d6 :> ThoriumStreamSizing::consequenceOfGradeAndCapture;
        doc d6Doc /* ECN-022 s.2.2 (a consequence, no alternative). */
        part d7 :> MkIiiTransitionTrigger::testOutcomeDriven;
        doc d7Doc /* ECN-022 s.2.6: not capacity-forced on the 620-position layout;
             * rests on the DG-11.6 test outcome. */
        part d8 :> HaulerInSituFractionPolicy::econFloor;
        doc d8Doc /* F3 recorded, not resolved: the economics' 0.43 floor with the
             * M-type bonus is what the plan carries; DG-13.7's 20 % is the gate
             * threshold the register tests. */

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
            interface cargoToStarship : CargoDelivery connect cargoOrigin to starshipCargo.cargoIn;
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
            part oxygenStore : ByProductOxygenStore {
                doc /* SPA by-product oxygen store (SEL-ECN-027). */
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
                    doc /* F5: demand-gated (SpaMsrIntroductionGate). SEL-ECN-025
                         * (Jason, 6 Nov 2026, option 2a): unit #1 is DG-13.4, the
                         * ECN-022 s.2.3 carry-through; DG-10.5 and DG-11.3 are
                         * superseded as commissioning gates and stay in the
                         * catalogue evaluating the same trade. Wave 3 bound this
                         * to DG-10.5. */
                    attribute redefines introducedIn = gates.dgThirteenFour.derivedPhase;
                }
            }
            part processingFacility : SpaProcessingFacility {
                doc /* Fixed (c): processing is a core element, not conditional
                     * (ECN-015 retired the Y12 gate, DG-6.1). */
            }
            part reagentPilot : SpaReagentPilot {
                doc /* Wave 4B: the DG-5.3 pilot and the DG-7.4 production scale
                     * (the "TODO Wave 4" gated elements of the Wave 3 catalogue). */
                attribute redefines introducedIn = gates.dgFiveThree.derivedPhase;
                attribute redefines productionScaleFrom = gates.dgSevenFour.derivedPhase;
            }
            part pgmHydromet : SpaPgmHydromet {
                doc /* Wave 4B (W4B-N5): PROBE-era PGM separation, in the first
                     * export batch (DG-5.4). */
                attribute redefines introducedIn = gates.dgFiveFour.derivedPhase;
            }
            part mTypeLine : MTypeProcessingLine {
                attribute redefines introducedIn = gates.dgTwelveFour.derivedPhase;
            }
            part cTypeLine : CTypeProcessingLine {
                attribute redefines introducedIn = gates.dgThirteenThree.derivedPhase;
            }
            part sTypeLine : STypeProcessingLine {
                attribute redefines introducedIn = gates.dgFourteenThree.derivedPhase;
                attribute redefines minimumContinuousRunHours = parameters.czochralskiBatchHours;
                part redefines czochralski : AsteroidProcessStep {
                    attribute redefines minimumContinuousRunHours = parameters.czochralskiBatchHours;
                }
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

            // ---- Wave 4B: every SPA connection through an interface ------
            bind returnPayloadDispatch = processingFacility.reoOut;
            bind cargoLanding = landingZone.cargoLanding;

            // ISRU chain: propellant to the IZ and the fuelled fleet, O2 to the habitat
            interface isruToIz : PropellantTransfer connect isru.propellantToIz to industrialZone.propellantFromIsru;
            interface isruOxygenToHabitat : OxygenTransfer connect isru.oxygenToHabitat to habComplex.o2SupplyLine;
            interface isruOxygenToStore : OxygenTransfer connect isru.oxygenToHabitat to oxygenStore.oxygenIn;
            interface collarFuelsProbeMkI : PropellantTransfer connect industrialZone.dockingCollars.propellantToProbe to probeMkI.propellantIn;
            interface collarFuelsProbeMkII : PropellantTransfer connect industrialZone.dockingCollars.propellantToProbe to probeMkII.propellantIn;
            interface farmFuelsSkip : PropellantTransfer connect isru.propellantToIz to skip.propellantIn;
            interface farmFuelsDart : PropellantTransfer connect isru.propellantToIz to dart.propellantIn;
            interface farmFuelsStarshipReturn : PropellantTransfer connect isru.propellantToIz to starshipReturn.propellantIn;

            // KREEP and asteroid ore into the IZ, concentrate on to processing
            interface skipOreToIz : OreTransfer connect skip.oreOut to industrialZone.skipOreIn;
            interface probeMkIOreToCollar : OreTransfer connect probeMkI.oreOut to industrialZone.dockingCollars.oreFromProbe;
            interface probeMkIIOreToCollar : OreTransfer connect probeMkII.oreOut to industrialZone.dockingCollars.oreFromProbe;
            interface mkIiiCanistersToCatcher : CanisterLink connect probeMkIII.canisterEjection to industrialZone.emCatcher.inboundCanisters;
            interface catcherToBeneficiation : OreTransfer connect industrialZone.emCatcher.concentrateOut to industrialZone.beneficiation.oreIn;
            interface concentrateToProcessing : OreTransfer connect industrialZone.concentrateOut to processingFacility.concentrateIn;
            interface concentrateToPgmHydromet : OreTransfer connect industrialZone.concentrateOut to pgmHydromet.oreIn;
            interface concentrateToMTypeLine : OreTransfer connect industrialZone.emCatcher.concentrateOut to mTypeLine.concentrateIn;
            interface concentrateToCTypeLine : OreTransfer connect industrialZone.emCatcher.concentrateOut to cTypeLine.concentrateIn;
            interface concentrateToSTypeLine : OreTransfer connect industrialZone.emCatcher.concentrateOut to sTypeLine.concentrateIn;
            interface reagentsToProcessing : ReagentTransfer connect reagentPilot.reagentOut to processingFacility.reagentIn;
            interface pgmToReturn : ProductTransfer connect pgmHydromet.pgmOut to starshipReturn.payloadIn;
            interface reoToReturn : ProductTransfer connect processingFacility.reoOut to starshipReturn.payloadIn;

            // power: base bus to the facilities; the asteroid lines on the ECN-023 rule
            interface powerToIsru : PowerBus connect powerZone.baseBus to isru.powerIn;
            interface powerToIz : PowerBus connect powerZone.baseBus to industrialZone.powerIn;
            interface powerToProcessing : PowerBus connect powerZone.baseBus to processingFacility.powerIn;
            interface powerToCatcher : PowerBus connect powerZone.baseBus to industrialZone.emCatcher.powerIn;
            interface mTypeLineSupply : EclipseGatedPowerSupply connect powerZone.asteroidLineSupply to mTypeLine.powerIn {
                doc /* SEL-ECN-023 on the M-type line: pausable, hold loads only
                     * through the eclipse, plant oversized. holdLoadFraction is
                     * the line's unbound PointReal nominal (W4A-N3). */
                :>> pausableThroughEclipse = mTypeLine.pausableThroughEclipse;
                :>> holdLoadFraction = mTypeLine.holdLoadFraction.nominal;
                :>> eclipseCarriedFraction = mTypeLine.holdLoadFraction.nominal;
                :>> oversizedForDarkFraction = true;
            }
            interface cTypeLineSupply : EclipseGatedPowerSupply connect powerZone.asteroidLineSupply to cTypeLine.powerIn {
                doc /* SEL-ECN-023 on the C-type line (pyrolysis, Fischer-Tropsch). */
                :>> pausableThroughEclipse = cTypeLine.pausableThroughEclipse;
                :>> holdLoadFraction = cTypeLine.holdLoadFraction.nominal;
                :>> eclipseCarriedFraction = cTypeLine.holdLoadFraction.nominal;
                :>> oversizedForDarkFraction = true;
            }
            interface sTypeLineSupply : EclipseGatedPowerSupply connect powerZone.asteroidLineSupply to sTypeLine.powerIn {
                doc /* SEL-ECN-023 on the S-type line (Czochralski batches between
                     * eclipses, copper electrolysis). */
                :>> pausableThroughEclipse = sTypeLine.pausableThroughEclipse;
                :>> holdLoadFraction = sTypeLine.holdLoadFraction.nominal;
                :>> eclipseCarriedFraction = sTypeLine.holdLoadFraction.nominal;
                :>> oversizedForDarkFraction = true;
            }
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
            // Wave 4B: tether, bayonet tap and UHF construction link to each MOLE-I class
            interface tetherMkI : TetherLink connect psrNetwork.moleIFleetTethers to moleIMkI.tetherReceptacle;
            interface tetherMkII : TetherLink connect psrNetwork.moleIFleetTethers to moleIMkII.tetherReceptacle;
            interface tapMkI : BayonetCoupling connect psrNetwork.substations.tapSocket.socket to moleIMkI.bayonetAdapter.plug;
            interface tapMkII : BayonetCoupling connect psrNetwork.substations.tapSocket.socket to moleIMkII.bayonetAdapter.plug;
            interface constructionRadioMkI : ConstructionRadioLink connect psrNetwork.moleIConstructionRadio to moleIMkI.constructionRadio;
            interface constructionRadioMkII : ConstructionRadioLink connect psrNetwork.moleIConstructionRadio to moleIMkII.constructionRadio;
            interface drillProductToTramway : IcyRegolithTransfer connect moleIMkI.drillProduct to psrNetwork.tramwayFloorLoad;
        }
        // Addendum 7 Nov 2026: the CAP on its guide cable and on the CLP floor
        // docking pad power tap (SEL-CAP-001 Rev A updated s.2-3, s.5). The pod
        // side of the tap coupling is CAP-001 s.8 item 4 (OPEN): the interface
        // carries the power flow only, not the rover's engagement sequence.
        interface capOnGuideCable : GuideCableLink connect shackletonPsrFloor.psrNetwork.capGuideCable.floorDockingPad to shackletonHub.cap.guideCable;
        interface capFloorPower : BayonetCoupling connect shackletonPsrFloor.psrNetwork.clp.capDockingPadTap.socket to shackletonHub.cap.floorPowerUmbilical;

        // rim <-> floor: trunk power down, water and P3 tramway regolith up
        interface psrTrunkPower : PowerBus connect shackletonHub.powerZone.psrTrunkFeed to shackletonPsrFloor.psrNetwork.rimPowerFeed;
        interface psrWaterToIsru : WaterTransfer connect shackletonPsrFloor.psrNetwork.rimIsruWaterReturn to shackletonHub.isru.psrWaterInlet;
        interface tramwayRegolithToIsru : IcyRegolithTransfer connect shackletonPsrFloor.psrNetwork.rimIsruRegolith to shackletonHub.isru.tramwayRegolithInlet;

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

            part oxygenStore : ByProductOxygenStore {
                doc /* PKT by-product oxygen store (SEL-ECN-027; ECON s.8.4). */
            }
            part processingSpine : PktProcessingSpine {
                attribute redefines introducedIn = gates.dgEightOne.derivedPhase;
            }
            interface spineOxygenToStore : OxygenTransfer connect processingSpine.byProductOxygen to oxygenStore.oxygenIn;
            part reagentPlant : ReagentPlant {
                attribute redefines introducedIn = gates.dgEightThree.derivedPhase;
                part redefines oxalicAcidLine : OxalicAcidLine {
                    doc /* Wave 4B: the DG-9.5 gated element. */
                    attribute redefines introducedIn = gates.dgNineFive.derivedPhase;
                }
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

            // ---- Wave 4B: every PKT connection through an interface ------
            bind canisterDispatch = processingSpine.canisterDispatch;
            bind cargoLanding = landingZone.cargoLanding;
            interface haulerToConveyor : OreTransfer connect hauler.oreOut to conveyorNetwork.haulerTipIn;
            interface haulerToSpine : OreTransfer connect hauler.oreOut to processingSpine.oreInput;
            interface conveyorToSpine : OreTransfer connect conveyorNetwork.spineDelivery to processingSpine.oreInput;
            interface reagentsToSpine : ReagentTransfer connect reagentPlant.reagentOutput to processingSpine.reagentInput;
            interface thoriumToMsr : ThoriumTransfer connect processingSpine.thoriumOutput to powerSystem.thcl4FuelInlet;
            interface spinePower : PowerBus connect powerSystem.spineBus to processingSpine.powerIn;
            interface reagentPlantPower : PowerBus connect powerSystem.spineBus to reagentPlant.powerIn;
            interface foundryPower : PowerBus connect powerSystem.spineBus to foundry.powerIn;
            interface conveyorPower : PowerBus connect powerSystem.spineBus to conveyorNetwork.referenceTrunk.drivePowerIn;
            interface haulerCharging : PowerBus connect powerSystem.haulerCharging to hauler.chargeIn;
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

        part l1OxygenDepot : L1OxygenDepot {
            doc /* Wave 4B: the SEL-REQ-005 O2 depot. Exists when MD-2, which
                 * lofts the O2, is operational - derived through the driver's
                 * own phase (the StarshipReturnLink idiom), bound before any
                 * document gave it a phase (W4B-N4). W4B-N27 (addendum): SEL-
                 * ECON-001 Rev A revised s.8.4 (docs/) places the depot at P14+
                 * (DG-14.4) with the O2 "initially vented or stored" through
                 * P8-P14 - against this derivation (P9) and against SEL-REQ-005
                 * "not vented or dumped". Recorded, not resolved; the binding
                 * is unchanged (no decision changed) and raised to Jason. */
            attribute redefines nodeName = "L1 / EML-2 O2 depot";
            attribute redefines role = "sink for the process by-product O2 lofted on MD-2 (SEL-REQ-005)";
            attribute redefines existsFrom = massDriverNetwork.md2.operationalFrom;
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
                doc /* SEL-ECN-022 s.2.1 (Jason, 19 Sep 2026): MD-4 is bound to the M-type
                     * arrival (DG-12.4), not to the DG-11.6 PGM-volume trigger,
                     * which the programme's own PGM production never reaches
                     * (W3-N2). The Starship returns therefore retire at the
                     * M-type arrival through the Wave 2 chain below. */
                attribute redefines introducedIn = gates.dgTwelveFour.derivedPhase;
                attribute redefines operationalFrom = gates.dgTwelveFour.derivedPhase;
            }
            part redefines md5 : MassDriverMd5 {
                attribute redefines introducedIn = gates.dgTwelveFive.derivedPhase;
                attribute redefines operationalFrom = gates.dgTwelveFive.derivedPhase;
            }
        }
        // Wave 4B: the ten mass driver legs (plus the MD-2 O2 loft) as CanisterLinks
        interface spaToMd1 : CanisterLink connect shackletonHub.canisterDispatch to massDriverNetwork.md1.launchInput;
        interface md1ToPkt : CanisterLink connect massDriverNetwork.md1.receiverOutput to pktFactory.canisterReceipt;
        interface pktToMd2 : CanisterLink connect pktFactory.canisterDispatch to massDriverNetwork.md2.launchInput;
        interface md2ToEarth : CanisterLink connect massDriverNetwork.md2.receiverOutput to earth.canisterReceipt;
        interface md2ToDepot : CanisterLink connect massDriverNetwork.md2.receiverOutput to l1OxygenDepot.oxygenReceipt;
        interface pktToMd3 : CanisterLink connect pktFactory.canisterDispatch to massDriverNetwork.md3.launchInput;
        interface md3ToCatcher : CanisterLink connect massDriverNetwork.md3.receiverOutput to shackletonHub.industrialZone.emCatcher.inboundCanisters;
        interface spaToMd4 : CanisterLink connect shackletonHub.canisterDispatch to massDriverNetwork.md4.launchInput;
        interface md4ToEarth : CanisterLink connect massDriverNetwork.md4.receiverOutput to earth.canisterReceipt;
        interface droToMd5 : CanisterLink connect droStation.canisterDispatch to massDriverNetwork.md5.launchInput;
        interface md5ToCatcher : CanisterLink connect massDriverNetwork.md5.receiverOutput to shackletonHub.industrialZone.emCatcher.inboundCanisters;
        interface md1Power : PowerBus connect shackletonHub.powerZone.baseBus to massDriverNetwork.md1.powerIn;
        interface md2Power : PowerBus connect pktFactory.powerSystem.spineBus to massDriverNetwork.md2.powerIn;
        interface md3Power : PowerBus connect pktFactory.powerSystem.spineBus to massDriverNetwork.md3.powerIn;
        interface md4Power : PowerBus connect shackletonHub.powerZone.baseBus to massDriverNetwork.md4.powerIn;

        // Starship cargo and return legs
        interface cargoToSpa : CargoDelivery connect earth.starshipCargo.spaDelivery to shackletonHub.cargoLanding;
        interface cargoToPkt : CargoDelivery connect earth.starshipCargo.pktDelivery to pktFactory.cargoLanding;
        interface returnToEarth : ProductTransfer connect shackletonHub.starshipReturn.earthDelivery to earth.returnPayloadReceipt;

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
        // Wave 4B: supervision through SupervisionLink, ECN-014 through the sensor,
        // hardwired-close and limit-switch interfaces
        interface earthSupervision : SupervisionLink connect sentinelSystem.earthLink to earth.opsHub;
        interface relaysSupervisedFromEarth : SupervisionLink connect emL2Relays.southPoleComms to earth.opsHub;
        interface spaOpsHubSupervision : SupervisionLink connect sentinelSystem.spaOpsHubLink to shackletonHub.opsHubSupervisor;
        interface pktRelaySupervision : SupervisionLink connect pktRelay.supervisionTrunk to sentinelSystem.pktRelayLink;
        interface pktNodeSupervision : SupervisionLink connect pktFactory.supervision to sentinelSystem.pktRelayLink;
        interface spaNodeSupervision : SupervisionLink connect shackletonHub.supervision to sentinelSystem.fleetLink;
        interface droSupervision : SupervisionLink connect droStation.supervision to sentinelSystem.fleetLink;
        interface isruSupervision : SupervisionLink connect shackletonHub.isru.supervision to sentinelSystem.fleetLink;
        interface psrNetworkSupervision : SupervisionLink connect shackletonPsrFloor.psrNetwork.supervision to sentinelSystem.fleetLink;
        interface moleIMkISupervision : SupervisionLink connect shackletonPsrFloor.moleIMkI.supervision to sentinelSystem.fleetLink;
        interface moleIMkIISupervision : SupervisionLink connect shackletonPsrFloor.moleIMkII.supervision to sentinelSystem.fleetLink;
        interface probeMkISupervision : SupervisionLink connect shackletonHub.probeMkI.supervision to sentinelSystem.fleetLink;
        interface probeMkIISupervision : SupervisionLink connect shackletonHub.probeMkII.supervision to sentinelSystem.fleetLink;
        interface probeMkIIISupervision : SupervisionLink connect shackletonHub.probeMkIII.supervision to sentinelSystem.fleetLink;
        interface surveySupervision : SupervisionLink connect shackletonHub.survey.supervision to sentinelSystem.fleetLink;
        interface moleSSupervision : SupervisionLink connect shackletonHub.moleS.supervision to sentinelSystem.fleetLink;
        interface sinterSupervision : SupervisionLink connect shackletonHub.sinter.supervision to sentinelSystem.fleetLink;
        interface armCSupervision : SupervisionLink connect shackletonHub.armC.supervision to sentinelSystem.fleetLink;
        interface armDSupervision : SupervisionLink connect shackletonHub.armD.supervision to sentinelSystem.fleetLink;
        interface sentinelRoverSupervision : SupervisionLink connect shackletonHub.sentinelRover.supervision to sentinelSystem.fleetLink;
        interface skipSupervision : SupervisionLink connect shackletonHub.skip.supervision to sentinelSystem.fleetLink;
        interface dartSupervision : SupervisionLink connect shackletonHub.dart.supervision to sentinelSystem.fleetLink;
        interface harvestSupervision : SupervisionLink connect shackletonHub.harvest.supervision to sentinelSystem.fleetLink;
        interface capSupervision : SupervisionLink connect shackletonHub.cap.supervision to sentinelSystem.fleetLink;
        interface haulerSupervision : SupervisionLink connect pktFactory.hauler.supervision to sentinelSystem.pktRelayLink;
        interface sinterPktSupervision : SupervisionLink connect pktFactory.sinterPkt.supervision to sentinelSystem.pktRelayLink;
        interface armCPktSupervision : SupervisionLink connect pktFactory.armCPkt.supervision to sentinelSystem.pktRelayLink;
        interface sentinelRoverPktSupervision : SupervisionLink connect pktFactory.sentinelRoverPkt.supervision to sentinelSystem.pktRelayLink;
        interface redirectTugSupervision : SupervisionLink connect droStation.redirectTug.supervision to sentinelSystem.fleetLink;
        interface laserTrussSupervision : SupervisionLink connect droStation.laserAblationTruss.supervision to sentinelSystem.fleetLink;

        interface cryoStationSensing : SensorLink connect shackletonHub.isru.cryoTransferValveStations.sensorOutput
            to sentinelSystem.cryoValveMonitoring.stationMonitors.stationSensorInput;
        interface cryoStationClose : HardwiredCloseLine connect sentinelSystem.cryoValveMonitoring.stationMonitors.hardwiredCloseSignal
            to shackletonHub.isru.cryoTransferValveStations.hardwiredCloseInput;
        interface cryoStationLimitSwitch : LimitSwitchLine connect shackletonHub.isru.cryoTransferValveStations.limitSwitchOutput
            to sentinelSystem.cryoValveMonitoring.stationMonitors.limitSwitchFeedback;
        interface o2LineSensing : SensorLink connect shackletonHub.habComplex.o2LineSensors
            to sentinelSystem.o2SupplyMonitoring.o2LineSensors;
        interface o2LineClose : HardwiredCloseLine connect sentinelSystem.o2SupplyMonitoring.o2AutoCloseSignal
            to shackletonHub.habComplex.o2LineAutoClose;

        // ---- Wave 4B: the value chain, performed and allocated -----------

        perform action valueChain : ValueChain {
            doc /* Every stream's phase follows its performing element (':>>'
                 * bindings below) - the derived plan gates the behaviour as it
                 * gates the structure. */
            action redefines psrIceToPropellant : PsrIceToPropellant {
                :>> introducedIn = shackletonHub.isru.introducedIn;
            }
            action redefines spaKreepToExport : SpaKreepToExport {
                :>> introducedIn = shackletonHub.skipHops.operationalFrom;
                :>> retiredIn = shackletonHub.skipHops.retiredIn;
            }
            action redefines pktKreepToEarth : PktKreepToEarth {
                :>> introducedIn = pktFactory.processingSpine.introducedIn;
            }
            action redefines thoriumToMsrFuel : ThoriumToMsrFuel {
                :>> introducedIn = pktFactory.processingSpine.introducedIn;
            }
            action redefines probeOreToPgmAndFeNi : ProbeOreToPgmAndFeNi {
                :>> introducedIn = shackletonHub.probeMkI.introducedIn;
            }
            action redefines capturedAsteroidToProducts : CapturedAsteroidToProducts {
                :>> introducedIn = droStation.existsFrom;
            }
            action redefines interSiteCargoToPkt : InterSiteCargoToPkt {
                :>> introducedIn = massDriverNetwork.md1.operationalFrom;
            }
        }

        // PSR ice -> propellant
        allocate valueChain.psrIceToPropellant.drill to shackletonPsrFloor.moleIMkI;
        allocate valueChain.psrIceToPropellant.drill to shackletonPsrFloor.moleIMkII;
        allocate valueChain.psrIceToPropellant.dump to shackletonPsrFloor.psrNetwork.substations;
        allocate valueChain.psrIceToPropellant.tramway to shackletonPsrFloor.psrNetwork.tramway;
        allocate valueChain.psrIceToPropellant.pump to shackletonPsrFloor.psrNetwork.clp.trunkPump;
        allocate valueChain.psrIceToPropellant.pump to shackletonPsrFloor.psrNetwork.pipeline;
        allocate valueChain.psrIceToPropellant.desorb to shackletonHub.isru.vex;
        allocate valueChain.psrIceToPropellant.electrolyse to shackletonHub.isru.electrolyser;
        allocate valueChain.psrIceToPropellant.liquefy to shackletonHub.isru.cryocooler;
        allocate valueChain.psrIceToPropellant.store to shackletonHub.isru.propellantFarm;
        allocate valueChain.psrIceToPropellant.fuel to shackletonHub.industrialZone.dockingCollars;
        allocate valueChain.psrIceToPropellant.habitatO2 to shackletonHub.habComplex;
        // SPA KREEP -> export
        allocate valueChain.spaKreepToExport.hop to shackletonHub.skip;
        allocate valueChain.spaKreepToExport.beneficiate to shackletonHub.industrialZone.beneficiation;
        allocate valueChain.spaKreepToExport.flowsheet to shackletonHub.processingFacility.flowsheet;
        allocate valueChain.spaKreepToExport.returnToEarth to shackletonHub.starshipReturn;
        allocate valueChain.spaReagents to shackletonHub.reagentPilot;
        // PKT KREEP -> Earth
        allocate valueChain.pktKreepToEarth.mine to pktFactory.hauler;
        allocate valueChain.pktKreepToEarth.convey to pktFactory.conveyorNetwork;
        allocate valueChain.pktKreepToEarth.flowsheet to pktFactory.processingSpine.flowsheet;
        allocate valueChain.pktKreepToEarth.loadReo to pktFactory.processingSpine;
        allocate valueChain.pktKreepToEarth.launchMd2 to massDriverNetwork.md2;
        allocate valueChain.pktKreepToEarth.recover to earth;
        allocate valueChain.pktKreepToEarth.loadOxygen to pktFactory;
        allocate valueChain.pktKreepToEarth.launchOxygenMd2 to massDriverNetwork.md2;
        allocate valueChain.pktReagents to pktFactory.reagentPlant;
        // thorium -> MSR fuel
        allocate valueChain.thoriumToMsrFuel.loadMd1 to shackletonHub.processingFacility;
        allocate valueChain.thoriumToMsrFuel.launchMd1 to massDriverNetwork.md1;
        allocate valueChain.thoriumToMsrFuel.stockpile to pktFactory.processingSpine;
        allocate valueChain.thoriumToMsrFuel.chlorinate to pktFactory.processingSpine.flowsheet.thoriumConversion;
        allocate valueChain.thoriumToMsrFuel.fuelPkt to pktFactory.powerSystem.referenceMsr;
        allocate valueChain.thoriumToMsrFuel.loadMd3 to pktFactory.processingSpine;
        allocate valueChain.thoriumToMsrFuel.launchMd3 to massDriverNetwork.md3;
        allocate valueChain.thoriumToMsrFuel.catchAtSpa to shackletonHub.industrialZone.emCatcher;
        allocate valueChain.thoriumToMsrFuel.fuelSpa to shackletonHub.powerZone.spaMsr;
        // PROBE ore -> PGM and Fe-Ni
        allocate valueChain.probeOreToPgmAndFeNi.probeMission to shackletonHub.probeMkI;
        allocate valueChain.probeOreToPgmAndFeNi.probeMission to shackletonHub.probeMkII;
        allocate valueChain.probeOreToPgmAndFeNi.mkIiiMission to shackletonHub.probeMkIII;
        allocate valueChain.probeOreToPgmAndFeNi.catchMkIii to shackletonHub.industrialZone.emCatcher;
        allocate valueChain.probeOreToPgmAndFeNi.beneficiate to shackletonHub.industrialZone.beneficiation;
        allocate valueChain.probeOreToPgmAndFeNi.separate to shackletonHub.pgmHydromet;
        allocate valueChain.probeOreToPgmAndFeNi.exportPgm to shackletonHub.starshipReturn;
        allocate valueChain.probeOreToPgmAndFeNi.loadFeNi to shackletonHub.pgmHydromet;
        allocate valueChain.probeOreToPgmAndFeNi.launchMd1 to massDriverNetwork.md1;
        allocate valueChain.probeOreToPgmAndFeNi.fabricate to pktFactory.foundry;
        // captured asteroids -> products
        allocate valueChain.capturedAsteroidToProducts.ablate to droStation.laserAblationTruss;
        allocate valueChain.capturedAsteroidToProducts.loadMd5 to droStation;
        allocate valueChain.capturedAsteroidToProducts.launchMd5 to massDriverNetwork.md5;
        allocate valueChain.capturedAsteroidToProducts.catchAtSpa to shackletonHub.industrialZone.emCatcher;
        allocate valueChain.capturedAsteroidToProducts.mTypeLine to shackletonHub.mTypeLine;
        allocate valueChain.capturedAsteroidToProducts.cTypeLine to shackletonHub.cTypeLine;
        allocate valueChain.capturedAsteroidToProducts.sTypeLine to shackletonHub.sTypeLine;
        allocate valueChain.capturedAsteroidToProducts.loadProductsMd1 to shackletonHub;
        allocate valueChain.capturedAsteroidToProducts.launchMd1 to massDriverNetwork.md1;
        // MD-1 cargo
        allocate valueChain.interSiteCargoToPkt.load to shackletonHub;
        allocate valueChain.interSiteCargoToPkt.launch to massDriverNetwork.md1;

        // ---- Committed-principle requirements -------------------------

        requirement steadyStateTarget : SteadyStateReoTarget {
            subject params = parameters;
        }
        satisfy steadyStateTarget by parameters;

        requirement byProductsUsedAtScale : AllByProductsUsedAtScale {
            doc /* Wave 4B: SEL-REQ-005 gets its subject, the L1 O2 depot. */
            subject depot = l1OxygenDepot;
        }
        satisfy byProductsUsedAtScale by l1OxygenDepot;

        requirement spaOxygenStored : ExcessOxygenStoredBeforeDumping {
            subject store = shackletonHub.oxygenStore;
        }
        satisfy spaOxygenStored by shackletonHub.oxygenStore;

        requirement pktOxygenStored : ExcessOxygenStoredBeforeDumping {
            subject store = pktFactory.oxygenStore;
        }
        satisfy pktOxygenStored by pktFactory.oxygenStore;

        requirement mTypePausable : AsteroidProcessingPausableThroughEclipse {
            subject line = shackletonHub.mTypeLine;
        }
        satisfy mTypePausable by shackletonHub.mTypeLine;

        requirement cTypePausable : AsteroidProcessingPausableThroughEclipse {
            subject line = shackletonHub.cTypeLine;
        }
        satisfy cTypePausable by shackletonHub.cTypeLine;

        requirement sTypePausable : AsteroidProcessingPausableThroughEclipse {
            subject line = shackletonHub.sTypeLine;
        }
        satisfy sTypePausable by shackletonHub.sTypeLine;

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
