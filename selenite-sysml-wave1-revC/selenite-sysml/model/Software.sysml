package SeleniteSoftware {
    doc /* Software and supervision structure. SENTINEL system (three tiers,
         * three modes, supervision location per phase), ECN-014 cryo/O2
         * valve monitoring as structure, NAV-001 MOLE-I navigation as a
         * subsystem, MOLE-I flight software and substation controller as
         * placeholders. Wave 2 is STRUCTURE ONLY: states, transitions,
         * threshold values, auto-close logic and Kalman behaviour arrive in
         * Wave 4 (see docs/MIGRATION_PLAN.md). Attributes declared without
         * values are deliberate placeholders for that wave.
         * Sources: SEL-SW-SENTINEL-001 Rev B (ECN-014 folded in),
         * SEL_SENTINEL_DESIGN_RevB, SEL-NAV-001_MOLEI_Navigation_RevA,
         * SEL-SW-MOLEI-001 Rev D, SEL-SW-SUB-001 Rev C, ECN-013,
         * SEL_ROBOT_FLEET_v9.md s.4.1 and s.9.2, ARCHITECTURE_BASELINE.md s.7. */

    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;

    enum def SupervisionMode {
        doc /* The three SENTINEL operating modes. Source: SEL-SW-SENTINEL-001
             * Rev B, ARCHITECTURE_BASELINE.md s.7. */
        preProgrammedExecution;
        localAiWithinSafeParameters;
        exceptionFlaggingToHumans;
    }

    enum def SupervisionTier {
        doc /* Three-tier hierarchy: Earth ops hub -> SENTINEL edge (base AI
             * commander) -> fleet. */
        earthOpsHub;
        sentinelEdge;
        fleet;
    }

    abstract part def SoftwareElement :> PhaseGated {
        doc /* Base for software-defined elements; deployed on hardware named
             * in 'hostedOn'. */
        attribute hostedOn : String;
    }

    part def EarthOpsHubTier :> SoftwareElement {
        doc /* Tier 1: Earth operations hub. Supervises SPA directly at 2.56 s
             * RTT during P2-P3; thereafter strategic oversight only. */
        attribute redefines introducedIn = Phase::P0;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "Earth ops hub";
        attribute tier = SupervisionTier::earthOpsHub;
        attribute directSupervisionOfSpaUntil = Phase::P3;
    }

    part def SentinelEdgeTier :> SoftwareElement {
        doc /* Tier 2: SENTINEL base AI commander at the edge. Runs on SPA
             * Ops Hub compute from P4; a PKT instance from P8 is supervised
             * from SPA over the 0.5 s relay link. Software spec:
             * SEL-SW-SENTINEL-001 Rev B. Rover hardware is
             * SeleniteFleet::SentinelRover - a separate element. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "SPA Ops Hub (P4+); PKT edge node (P8+)";
        attribute tier = SupervisionTier::sentinelEdge;
        attribute supervisedFromEarthUntil = Phase::P3;
        attribute supervisedFromSpaFrom = Phase::P4;
        attribute pktSupervisedFromSpaFrom = Phase::P8;
        attribute supervisionNodeEarly = SiteId::earth;
        attribute supervisionNodeSteady = SiteId::spa;
    }

    part def FleetTier :> SoftwareElement {
        doc /* Tier 3: on-vehicle autonomy across the fleet (SAE Level 4 on
             * surface rovers per fleet v9). Individual vehicle software
             * elements (MoleIFlightSoftware, SubstationController) sit here. */
        attribute redefines introducedIn = Phase::P1;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "fleet vehicles and fixed infrastructure";
        attribute tier = SupervisionTier::fleet;
    }

    part def SentinelSystem :> SoftwareElement {
        doc /* The SENTINEL supervision system as a whole: three tiers, three
             * modes, with the ECN-014 valve monitoring function attached.
             * Mode selection and state machine: Wave 4.
             * Source: SEL-SW-SENTINEL-001 Rev B; ARCHITECTURE_BASELINE.md s.7. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "distributed across tiers";
        attribute supportedModes = (
            SupervisionMode::preProgrammedExecution,
            SupervisionMode::localAiWithinSafeParameters,
            SupervisionMode::exceptionFlaggingToHumans
        );

        part earthOpsHub : EarthOpsHubTier;
        part edge : SentinelEdgeTier;
        part fleetTier : FleetTier;
        part cryoValveMonitoring : CryoValveMonitoringFunction;
        part o2SupplyMonitoring : O2SupplyLineMonitoringFunction;

        port earthLink;
        port pktRelayLink;

        connect earthOpsHub to edge;
        connect edge to fleetTier;
    }

    enum def ValveMonitorAction {
        doc /* Response classes of the ECN-014 monitoring logic. */
        alert;
        autoClose;
        deadManFailClosed;
    }

    part def ValveStationSensorSet {
        doc /* Per-station sensor set per ECN-014: catalytic H2 (cross-checked
             * pair), solar-blind UV flame detector, pressure transducer.
             * Sensor counts and polling rates are Wave 4/5 data. */
    }

    part def ValveStationMonitor {
        doc /* Monitor for one cryo isolation valve station. Auto-close acts
             * over a hardwired 24 VDC signal to the pneumatic actuator (NOT CAN
             * bus or SpaceWire); comms loss beyond the dead-man timeout fails
             * the valve closed by spring return. Closure confirmed by limit
             * switch. Re-open is crew-only with four preconditions (H2 clear,
             * pressure low, no UV for the hold period, verbal confirmation).
             * Thresholds and timings: Wave 4. Source: ECN-014 via
             * SEL-SW-SENTINEL-001 Rev B; fleet v9 s.9.2. */
        part sensors : ValveStationSensorSet;
        port stationSensorInput;
        port hardwiredCloseSignal;
        port limitSwitchFeedback;
        attribute h2AlertThresholdPpm : Real;
        attribute h2AutoCloseThresholdPpm : Real;
        attribute pressureAutoCloseThresholdBar : Real;
        attribute deadManTimeoutSeconds : Real;
        attribute reopenRequiresCrewCommand : Boolean = true;
        attribute reopenPreconditionCount : Integer = 4;
    }

    part def ValveStateTable {
        doc /* VALVE_STATE database table, the 11th table of the SENTINEL
             * schema (one row per monitored valve, rolling retention).
             * Schema as attached CSV at Wave 4. Source: ECN-014. */
        attribute tableOrdinal : Integer = 11;
    }

    part def FaultPatternCatalogue {
        doc /* Fault pattern library; ECN-014 adds patterns #201-#206 (H2 leak,
             * overpressure, UV flame, O2 overpressure, O2 high flow, comms
             * timeout). Pattern table as attached CSV at Wave 4. */
        attribute ecn014PatternRangeStart : Integer = 201;
        attribute ecn014PatternRangeEnd : Integer = 206;
    }

    part def CryoValveMonitoringFunction :> SoftwareElement {
        doc /* ECN-014 cryo transfer line monitoring: four isolation valve
             * stations on the ISRU-IZ LH2/LOX transfer lines (two at the ISRU
             * manifold exit, two at the IZ propellant farm entry). Four
             * stations are the ECN-014 architecture, hence the multiplicity.
             * UV flame at any station closes all four (Tier 1 emergency). The
             * physical stations live in SeleniteHabitat::IsruPlant; the
             * binding is made in SeleniteConfigurations. Introduced with the
             * propellant farm at P3 (ISRU first output). */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "SENTINEL edge tier + hardwired station loop";
        part stationMonitors : ValveStationMonitor[4];
        part valveStateTable : ValveStateTable;
        part faultPatterns : FaultPatternCatalogue;
        port monitoredStations;
    }

    part def O2SupplyLineMonitoringFunction :> SoftwareElement {
        doc /* ECN-014 habitat O2 supply line monitoring: pressure transducers,
             * auto-close on hab-end overpressure or excess flow; hab on
             * reserve until resolved. Values Wave 4. Crewed from P4. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "SENTINEL edge tier";
        port o2LineSensors;
        port o2AutoCloseSignal;
    }

    part def TetherPolarFix {
        doc /* NAV-001 layer 1: tether drum payout range + two-axis angle
             * encoder on the substation guide roller. Source: ECN-013,
             * SEL-NAV-001 Rev A. */
    }

    part def WheelOdometry {
        doc /* NAV-001 layer 2: six existing wheel encoders. */
    }

    part def MemsImu {
        doc /* NAV-001 layer 3: MEMS IMU inside the WEB (SEL-MI-NAV-001). */
    }

    part def KalmanFusion {
        doc /* NAV-001 fusion filter on the existing MOLE-I PLC. Behaviour and
             * rates: Wave 4. */
    }

    part def DrillGridMap {
        doc /* NAV-001 workspace drill grid per sector (polar grid of radial x
             * angular bins) in non-volatile flash; enables gap-free systematic
             * mining over the service life. Cell count is a Wave 5 value. */
    }

    part def UhfConstructionLink {
        doc /* UHF link used during PSR network construction (NAV-001 / ECN-013
             * RF construction). */
    }

    part def MoleINavigation :> SoftwareElement {
        doc /* SEL-NAV-001 Rev A: three-layer MOLE-I navigation (tether polar
             * fix + wheel odometry + IMU, Kalman-fused) with the drill grid
             * map and UHF construction link. Structural subsystem of MOLE-I
             * (see SeleniteFleet::MoleI). Fusion behaviour: Wave 4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "MOLE-I PLC inside WEB";
        part tetherFix : TetherPolarFix;
        part odometry : WheelOdometry;
        part imu : MemsImu;
        part fusion : KalmanFusion;
        part drillGrid : DrillGridMap;
        part constructionLink : UhfConstructionLink;
        connect tetherFix to fusion;
        connect odometry to fusion;
        connect imu to fusion;
        connect fusion to drillGrid;
    }

    part def MoleIFlightSoftware :> SoftwareElement {
        doc /* SEL-SW-MOLEI-001 Rev D: MOLE-I on-board software hosting NAV-001.
             * Structure only; modes and drill sequencing Wave 4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "MOLE-I PLC inside WEB";
        part navigation : MoleINavigation;
    }

    part def SubstationController :> SoftwareElement {
        doc /* SEL-SW-SUB-001 Rev C: substation (SATS+WEB) controller - tether
             * drum tension, WEB thermal setpoint, water manifold pump,
             * MOLE-I port allocation. Structure only; Wave 4 behaviour. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "substation WEB PLC";
    }
}
