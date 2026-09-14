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
         * SEL-CAP-001 Rev A updated, ARCHITECTURE_BASELINE.md s.2 and s.4. */

    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;
    private import SeleniteSoftware::*;

    abstract part def PsrNetworkElement :> PhaseGated {
        doc /* Base for fixed PSR-access infrastructure. */
        abstract attribute location : SiteId;
    }

    part def DescentWinch :> PsrNetworkElement {
        doc /* Rim-anchored MOLE-I descent winch (IW-1 / IW-2), Kevlar or
             * Vectran cable only (Dyneema excluded at cryogenic temperatures).
             * Optional retrieval for major maintenance. From P3. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        port cableToFloor;
    }

    part def CrewWinch :> PsrNetworkElement {
        doc /* IW-CAP crew-rated winch for the Crater Access Pod, dedicated guide
             * cable, anchors reserved at P1. Operational P4 with the CAP. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute anchorsReservedFrom = Phase::P1;
    }

    part def CapGuideCable :> PsrNetworkElement {
        doc /* Dedicated CAP guide cable rim -> floor docking pad at the CLP. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port rimEnd;
        port floorDockingPad;
    }

    part def CableTramway :> PsrNetworkElement {
        doc /* Aerial cable tramway carrying icy-regolith containers PSR -> rim
             * during P3 (before the pipeline); retained as backup thereafter,
             * so never retired. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        attribute primaryRoleUntil = Phase::P3;
    }

    part def TrunkCable :> PsrNetworkElement {
        doc /* 1,000 VDC OFHC copper trunk from the rim power zone down the
             * western wall to the CLP. From P3. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port rimFeed;
        port clpEnd;
    }

    part def ClpJunction :> PsrNetworkElement {
        doc /* CLP: the point at the western wall base where the trunk cable
             * and trunk pipe enter the crater floor; hosts the trunk water pump
             * and the CAP floor docking pad. Name as used in fleet v9 s.4.1 and
             * s.13.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        part trunkPump : TrunkPump;
        port trunkCableIn;
        port spineOut;
        port trunkPipeIn;
        port pipelineOut;
    }

    part def TrunkPump {
        doc /* Trunk water pump at the CLP lifting product water to the rim
             * ISRU (values Wave 5). Source: SEL-PIPE-001 Rev A, fleet v9 s.13.3. */
    }

    part def Spine :> PsrNetworkElement {
        doc /* Floor-level spine along the highest ice-concentration zones from
             * the CLP; branches leave it toward confirmed ice (>= threshold,
             * SURVEY-mapped). Adaptive, incrementally extendable. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port clpIn;
        port branchTaps;
    }

    part def Branch :> PsrNetworkElement {
        doc /* Elevated (~3 m on sintered stakes) branch carrying cable and pipe
             * on shared brackets to a row of substations; construction taps
             * every 100 m with spring-loaded retraction spools (ECN-013 R3). */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::psrFloor;
        port spineTap;
        port substationTaps;
        part retractionSpools : RetractionSpool[0..*];
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
        port branchTap;
        port moleITethers;
        port waterOut;
    }

    part def TetherDrum {
        doc /* Constant-tension MOLE-I tether drum with cable-drum heater (on the
             * substation, not the rover). */
    }

    part def WaterManifold {
        doc /* Ground-level manifold inside the WEB receiving MOLE-I batch dumps
             * and lifting them into the elevated branch pipe. */
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
        port branchInlets;
        port rimIsruOutlet;
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
        part trunkCable : TrunkCable;
        part clp : ClpJunction;
        part spine : Spine;
        part branches : Branch[0..*];
        part substations : Substation[0..*];
        part pipeline : HeatedPipeline;

        port rimPowerFeed;
        port rimIsruWaterReturn;
        port moleIFleetTethers;

        // power and control path: rim -> trunk -> CLP -> spine -> branch -> substation
        connect trunkCable.clpEnd to clp.trunkCableIn;
        connect clp.spineOut to spine.clpIn;
        connect spine.branchTaps to branches.spineTap;
        connect branches.substationTaps to substations.branchTap;

        // water path: substation -> branch/trunk pipe -> CLP pump -> pipeline -> rim ISRU
        connect substations.waterOut to pipeline.branchInlets;
        connect pipeline.branchInlets to clp.trunkPipeIn;
        connect clp.pipelineOut to pipeline.rimIsruOutlet;

        // crew contingency access
        connect capGuideCable.floorDockingPad to clp.trunkCableIn;
    }
}
