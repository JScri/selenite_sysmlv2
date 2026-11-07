package SelenitePsrNetwork {
    doc /* Shackleton PSR access and charging network: descent winches, cable
         * tramway, trunk cable to the CLP, spine and branches, substations
         * (SATS+WEB), heated water pipeline, CAP guide cable - connected.
         * Fishbone topology: rim power zone -> trunk cable -> CLP junction ->
         * spine -> branches -> substations -> MOLE-I tethers; water returns
         * substation manifold -> branch pipe -> trunk pipe -> CLP trunk pump
         * -> rim ISRU. Per-phase counts (34 substations by P7, ~310 positions
         * maximum) are Wave 5 vectors; only topology is bound here.
         * Sources: SEL_ROBOT_FLEET_v9.md s.13, SEL_SUBSTATION_DESIGN_v4,
         * SEL-PIPE-001 Rev A, SEL-CON-001 Rev B updated, SEL-ECN-012 (drain
         * reroute, pipeline integration), SEL-ECN-013 (SATS+WEB, spools),
         * SEL-CAP-001 Rev A updated, ARCHITECTURE_BASELINE.md s.2 and s.4.
         * Wave 4B (7 Nov 2026): every port typed by SeleniteInterfaces and
         * every internal connection an interface (power path, water path,
         * crew access); the CON-001 bayonet tap sockets and the ECN-013 UHF
         * construction link added; the MOLE-I side of the tether and the
         * bayonet adapter are in SeleniteFleet::MoleI. Boundary ports are
         * delegated to the internal parts with 'bind'. Addendum (7 Nov
         * 2026): the sources are in docs/; the tether drum carries a sensing
         * port (payout + DRM-040 encoder) into the controller, which computes
         * the polar fix the drum sends down the tether (ECN-013 s.3.2); the
         * CLP carries the CAP floor docking pad power tap (CAP-001 s.5);
         * construction tap counts per branch and the SATS / substation tap
         * are documented, not multiplied (rule 3). */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;
    private import SeleniteSoftware::*;

    abstract part def PsrNetworkElement :> PhaseGated {
        doc /* Base for fixed PSR-access infrastructure. Source: fleet v9 s.13;
             * ARCHITECTURE_BASELINE.md s.4. */
        abstract attribute location : SiteId;
    }

    part def DescentWinch :> PsrNetworkElement {
        doc /* Rim-anchored MOLE-I descent winch (IW-1 / IW-2), Kevlar or
             * Vectran cable only (Dyneema excluded at cryogenic temperatures).
             * Optional retrieval for major maintenance. From P3. Source:
             * fleet v9 s.13.1; ARCHITECTURE_BASELINE.md s.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        port cableToFloor : WinchCablePort;
    }

    part def CrewWinch :> PsrNetworkElement {
        doc /* IW-CAP crew-rated winch for the Crater Access Pod, dedicated guide
             * cable, redundant braking, independent of all MOLE-I and
             * infrastructure winches. Operational P4 with the CAP. Phase 1
             * reservations (SEL-CAP-001 Rev A updated s.5; SEL-CON-001 Rev B
             * updated, CAP reservations): guide cable anchor sockets along the
             * wall route, the rim winch pad (SINTER-built), the floor docking
             * pad with power tap (SelenitePsrNetwork::ClpJunction), and a
             * lateral cable routing corridor. Source: SEL-CAP-001 Rev A
             * updated s.3, s.5; fleet v9 s.13.5. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute anchorsReservedFrom = Phase::P1;
        attribute phase1Reservations = (
            "guide cable anchor sockets", "rim winch pad",
            "floor docking pad with power tap", "lateral cable routing corridor"
        );
    }

    part def CapGuideCable :> PsrNetworkElement {
        doc /* Dedicated CAP guide cable rim -> floor docking pad at the CLP.
             * "CAP" names both the Crater Access Pod (SEL-CAP-001, fleet v9
             * s.13.5) and, in the final report Fig. 3, the crew access points
             * at rim and floor that the pod runs between. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port rimEnd : ~GuideCablePort;
        port floorDockingPad : GuideCablePort;
    }

    part def CableTramway :> PsrNetworkElement {
        doc /* Aerial cable tramway carrying icy-regolith containers PSR -> rim
             * during P3 (before the pipeline); retained as backup thereafter,
             * so never retired. Source: fleet v9 s.13.2. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        attribute primaryRoleUntil = Phase::P3;
        port floorLoad : ~IcyRegolithPort;
        port rimUnload : IcyRegolithPort;
        flow floorLoad.regolith to rimUnload.regolith;
    }

    part def TrunkCable :> PsrNetworkElement {
        doc /* 1,000 VDC OFHC copper trunk from the rim power zone down the
             * western wall to the CLP. From P3. Source: fleet v9 s.13.4;
             * SEL_SUBSTATION_DESIGN_v4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port rimFeed : ~PowerPort;
        port clpEnd : PowerPort;
    }

    part def RimLogisticsPoint :> PsrNetworkElement {
        doc /* Rim CLP - central logistics point on the crater rim (final report
             * Fig. 3: "one at crater rim and one at floor"): where the 1,000 VDC
             * trunk cable and the heated pipeline leave the rim trench from the
             * ISRU/power zone, the descent winches are anchored and the crew
             * access point (rim CAP) sits. Report Gantt (Fig. 26): trunk descent
             * from the CAP rim anchor, ~8.2 km, SATS+WEB lowered to the floor CLP. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        port rimPowerIn : ~PowerPort;
        port trunkCableOut : PowerPort;
        port pipelineRimEnd : ~WaterPort;
        port waterToIsru : WaterPort;
        port tramwayUnload : ~IcyRegolithPort;
        port regolithToIsru : IcyRegolithPort;
        port capRimAnchor : GuideCablePort;
        port winchAnchor : WinchCablePort;
    }

    part def ClpJunction :> PsrNetworkElement {
        doc /* Floor CLP - central logistics point at the western wall base
             * (final report Fig. 3 caption) where the trunk cable and trunk
             * pipe enter the crater floor; hosts the trunk water pump and the
             * CAP floor docking pad. Fleet v9 s.4.1 / s.13.4 use "CLP" without
             * expansion. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        part trunkPump : TrunkPump;
        part capDockingPadTap : BayonetTapSocket {
            doc /* CAP floor docking pad: flat Ti anchor plate adjacent to the
                 * SATS+WEB with a 1,000 VDC bayonet power tap socket, installed
                 * during Stage A by the construction MOLE-I (Phase 1
                 * reservation). Source: SEL-CAP-001 Rev A updated s.5;
                 * SEL-CON-001 Rev B updated, CAP Phase 1 reservations item 3. */
        }
        port trunkCableIn : ~PowerPort;
        port spineOut : PowerPort;
        port trunkPipeIn : ~WaterPort;
        port pipelineOut : WaterPort;
        port capDockingPad : ~GuideCablePort;
        port winchLanding : ~WinchCablePort;
        bind trunkPipeIn = trunkPump.waterIn;
        bind pipelineOut = trunkPump.waterOut;
    }

    part def TrunkPump {
        doc /* Trunk water pump at the CLP lifting product water to the rim
             * ISRU (values Wave 5). Source: SEL-PIPE-001 Rev A, fleet v9 s.13.3. */
        port waterIn : ~WaterPort;
        port waterOut : WaterPort;
        flow waterIn.water to waterOut.water;
    }

    part def Spine :> PsrNetworkElement {
        doc /* Floor-level spine along the highest ice-concentration zones from
             * the CLP; branches leave it toward confirmed ice (>= threshold,
             * SURVEY-mapped). Adaptive, incrementally extendable. Source:
             * fleet v9 s.13.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port clpIn : ~PowerPort;
        port branchTaps : PowerPort;
    }

    part def BayonetTapSocket {
        doc /* The standardised 20 mm two-L-slot bayonet power interface the
             * MOLE-I motorised adapter engages push-and-twist and holds on a
             * passive detent. Two forms: fixed sockets (the SATS construction
             * tap, the substation construction tap SEL-SUB-BUS-030, the CAP
             * floor docking pad tap) and, at each branch construction tap
             * every 100 m, the bayonet plug "integrated at the free end of the
             * tether" wound on the retraction spool (ECN-013 Rev 3) - the
             * rover mates with the spool tether's plug, not a socket on the
             * cable; electrically the same tap. The SEL-CON-001 Rev B updated
             * connector element (V-N7); the engagement sequence is
             * SeleniteSoftware::BayonetEngagementStates. The substation's own
             * branch connector is make-before-break (SEL-SW-SUB-001 Rev C
             * s.6). Socket counts (~9 spools per 450 m branch) and the 1,000
             * VDC rating stay in the source (rule 3). Source: SEL-CON-001 Rev
             * B updated s.3.1 and ECN-013 Rev 2 / Rev 3 and CAP reservations;
             * SEL-SW-SUB-001 Rev C s.6, ECN-013 Rev 3 part; fleet v9 s.4.1. */
        port socket : BayonetTapPort;
    }

    part def Branch :> PsrNetworkElement {
        doc /* Elevated (~3 m on sintered stakes) branch carrying cable and pipe
             * on shared brackets to a row of substations; construction taps
             * every 100 m with spring-loaded retraction spools (ECN-013 R3). */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port spineTap : ~PowerPort;
        port substationTaps : PowerPort;
        part retractionSpools : RetractionSpool[0..*];
        part constructionTaps : BayonetTapSocket[0..*] {
            doc /* Construction taps every 100 m, each a spring spool whose
                 * tether ends in the bayonet plug the rover engages (SEL-CON-001
                 * Rev B updated, ECN-013 Rev 3; fleet v9 s.13.4). */
        }
    }

    part def RetractionSpool {
        doc /* Clock-spring construction tether spool at each 100 m tap
             * (ECN-013 R3): constant tension, no power. */
    }

    part def Substation :> PsrNetworkElement {
        doc /* SATS+WEB substation node: pre-integrated assembly lowered warm
             * (ECN-013 R2), warm electronics box, constant-tension tether drums
             * with heaters, passive bus bars, water collection manifold with
             * transfer pump, five MOLE-I ports plus one spare (a structural
             * feature of the design, not a fleet count). Controller:
             * SEL-SW-SUB-001 Rev C. Source: SEL_SUBSTATION_DESIGN_v4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        part controller : SubstationController;
        part tetherDrums : TetherDrum[0..*];
        part waterManifold : WaterManifold;
        part tapSocket : BayonetTapSocket;
        port branchTap : ~PowerPort;
        port moleITethers : TetherPort;
        port waterOut : WaterPort;
        port constructionRadio : ConstructionRadioPort;
        port supervision : SupervisionPort;
        bind moleITethers = tetherDrums.tether;
        bind waterOut = waterManifold.branchPipeOut;
        bind constructionRadio = controller.constructionRadio;
        bind supervision = controller.supervision;
        // ECN-013 s.3.2: drum sensing into the controller, the computed fix
        // back out on the drum's tether port
        interface drumSensing : DrumSensingLine connect tetherDrums.sensing to controller.drumSensing;
        flow controller.tetherOut.fix to tetherDrums.tether.fix;
    }

    part def TetherDrum {
        doc /* Constant-tension MOLE-I tether drum with cable-drum heater (on the
             * substation, not the rover), 50 N tension loop, payout encoder,
             * and the DRM-040 two-axis angle encoder on the guide roller
             * (ECN-013). The drum end of the tether link carries power and
             * the controller-computed polar fix to the rover, water batches
             * and telemetry back; the sensing port carries payout and roller
             * angle to the controller. Source: SEL-SW-SUB-001 Rev C s.5 and
             * ECN-013 addition; SEL-NAV-001 Rev A s.2.1; fleet v9 s.4.1,
             * s.13.4; SEL_SUBSTATION_DESIGN_v4. */
        port tether : TetherPort;
        port sensing : DrumSensingPort;
    }

    part def WaterManifold {
        doc /* Ground-level manifold inside the WEB receiving MOLE-I batch dumps
             * and lifting them into the elevated branch pipe. Source: fleet v9
             * s.4.1 "Mini-VEX water path", s.13.4. */
        port batchIn : ~WaterPort;
        port branchPipeOut : WaterPort;
        flow batchIn.water to branchPipeOut.water;
    }

    part def HeatedPipeline :> PsrNetworkElement {
        doc /* Trace-heated Ti water pipeline rim <-> PSR operating zone,
             * ground-contact trunk and spine, elevated branches; dual parallel
             * trunk from P5 (single failure is mission-critical: freeze means
             * complete replacement). Primary from P4; tramway carries P3.
             * Source: SEL-PIPE-001 Rev A, fleet v9 s.13.3, ECN-012. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        attribute dualParallelTrunkFrom = Phase::P5;
        port branchInlets : ~WaterPort;
        port trunkPumpOut : WaterPort;
        port trunkPumpIn : ~WaterPort;
        port rimIsruOutlet : WaterPort;
        port traceHeatingIn : ~PowerPort;
        flow branchInlets.water to trunkPumpOut.water;
        flow trunkPumpIn.water to rimIsruOutlet.water;
    }

    part def PsrNetwork :> PsrNetworkElement {
        doc /* The connected Shackleton PSR network. One instance per PSR floor
             * in SeleniteConfigurations; de Gerlache extension is a P13+
             * decision gate rendered moot by the Mk III transition (fleet v9
             * s.4.3) and is not modelled. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;

        part descentWinches : DescentWinch[2] {
            doc /* IW-1 and IW-2 as named in ARCHITECTURE_BASELINE.md s.4. */
        }
        part crewWinch : CrewWinch;
        part capGuideCable : CapGuideCable;
        part tramway : CableTramway;
        part rimClp : RimLogisticsPoint;
        part trunkCable : TrunkCable;
        part clp : ClpJunction;
        part spine : Spine;
        part branches : Branch[0..*];
        part substations : Substation[0..*];
        part pipeline : HeatedPipeline;

        port rimPowerFeed : ~PowerPort;
        port rimIsruWaterReturn : WaterPort;
        port rimIsruRegolith : IcyRegolithPort;
        port moleIFleetTethers : TetherPort;
        port moleIConstructionRadio : ConstructionRadioPort;
        port tramwayFloorLoad : ~IcyRegolithPort;
        port supervision : SupervisionPort;

        // boundary delegation
        bind rimPowerFeed = rimClp.rimPowerIn;
        bind rimIsruWaterReturn = rimClp.waterToIsru;
        bind rimIsruRegolith = rimClp.regolithToIsru;
        bind moleIFleetTethers = substations.moleITethers;
        bind moleIConstructionRadio = substations.constructionRadio;
        bind tramwayFloorLoad = tramway.floorLoad;
        bind supervision = substations.supervision;

        // power and control path: rim -> trunk -> CLP -> spine -> branch -> substation
        interface rimToTrunk : PowerBus connect rimClp.trunkCableOut to trunkCable.rimFeed;
        interface trunkToClp : PowerBus connect trunkCable.clpEnd to clp.trunkCableIn;
        interface clpToSpine : PowerBus connect clp.spineOut to spine.clpIn;
        interface spineToBranches : PowerBus connect spine.branchTaps to branches.spineTap;
        interface branchesToSubstations : PowerBus connect branches.substationTaps to substations.branchTap;

        // water path: substation -> branch/trunk pipe -> CLP pump -> pipeline -> rim ISRU
        interface substationsToPipe : WaterTransfer connect substations.waterOut to pipeline.branchInlets;
        interface pipeToPump : WaterTransfer connect pipeline.trunkPumpOut to clp.trunkPipeIn;
        interface pumpToRimPipe : WaterTransfer connect clp.pipelineOut to pipeline.trunkPumpIn;
        interface pipeToRim : WaterTransfer connect pipeline.rimIsruOutlet to rimClp.pipelineRimEnd;

        // P3 tramway: floor containers -> rim
        interface tramwayToRim : IcyRegolithTransfer connect tramway.rimUnload to rimClp.tramwayUnload;

        // descent winches and crew contingency access
        interface winchToFloor : WinchCableLink connect descentWinches.cableToFloor to clp.winchLanding;
        interface capRimToCable : GuideCableLink connect rimClp.capRimAnchor to capGuideCable.rimEnd;
        interface capCableToFloor : GuideCableLink connect capGuideCable.floorDockingPad to clp.capDockingPad;
    }
}
