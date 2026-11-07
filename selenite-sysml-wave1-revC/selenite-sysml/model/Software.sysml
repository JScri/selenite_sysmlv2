package SeleniteSoftware {
    doc /* Software and supervision. Wave 2 (14 Sep 2026) laid the structure:
         * SENTINEL system (three tiers, three modes, supervision location per
         * phase), ECN-014 cryo/O2 valve monitoring as structure, NAV-001
         * MOLE-I navigation as a subsystem, MOLE-I flight software and the
         * substation controller as placeholders. Wave 4B (7 Nov 2026) adds the
         * behaviour the repository documents support: the supervision
         * location and SENTINEL operating modes as state machines, the ECN-014
         * cryo-valve auto-close and the O2 supply-line auto-close as state
         * machines with the hardwired 24 VDC dead-man fail-closed logic
         * asserted, the fault patterns #201-#206 as the transitions, the
         * NAV-001 three-layer fusion as an action flow allocated to the MOLE-I
         * software with the ECN-013 UHF construction link where the fix
         * depends on it, and the MOLE-I operating states ECN-012 / fleet v9
         * s.4.1 describe. Every port is typed by SeleniteInterfaces.
         * Behaviour mirrors the documents and invents no control logic: where
         * the repository documents are silent a transition is declared with
         * its trigger UNBOUND and a doc naming the source needed. Thresholds
         * and timings stay UNBOUND attributes (rule 3): the ECN-014 values
         * (100 / 1,000 ppm, 5 bar, 60 s, 3 s, 10 ppm for 5 min, 3 bar, 10 min;
         * O2 200 kPa, 2x flow) are quoted in the docs from fleet v9 s.9.2 and
         * bound at Wave 5.
         * Sources IN the repository: SEL_ROBOT_FLEET_v9.md s.4.1 (NAV-001,
         * ECN-012 drain sequence, ECN-013 adapter), s.9.2 (the ECN-014
         * extract, the only ECN-014 text in the repository - V-N19), s.10.1
         * (hauler navigation), s.13.4; SEL-T1.1-STRATEGY v3.1 s.4.2, s.5.1;
         * ARCHITECTURE_BASELINE.md s.7. Sources NOT in the repository (ledger
         * entries only; each use carries a TODO): SEL-SW-SENTINEL-001 Rev B
         * (ECN-014 folded in), SEL_SENTINEL_DESIGN_RevB, SEL-NAV-001 Rev A,
         * SEL-SW-MOLEI-001 Rev D, SEL-SW-SUB-001 Rev C, ECN-013 v1. */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;

    enum def SupervisionMode {
        doc /* The three SENTINEL operating modes. Source: SEL-SW-SENTINEL-001
             * Rev B (not in the repository), ARCHITECTURE_BASELINE.md s.7. */
        preProgrammedExecution;
        localAiWithinSafeParameters;
        exceptionFlaggingToHumans;
    }

    enum def SupervisionTier {
        doc /* Three-tier hierarchy: Earth ops hub -> SENTINEL edge (base AI
             * commander) -> fleet. Source: ARCHITECTURE_BASELINE.md s.7;
             * fleet v9 s.9.2 (comms). */
        earthOpsHub;
        sentinelEdge;
        fleet;
    }

    enum def Ecn014FaultPattern {
        doc /* The six ECN-014 fault patterns #201-#206 in order: H2 leak,
             * overpressure, UV flame, O2 overpressure, O2 high flow, comms
             * timeout (fleet v9 s.9.2). Each is a transition of the valve
             * state machines below. */
        h2Leak;
        overpressure;
        uvFlame;
        o2Overpressure;
        o2HighFlow;
        commsTimeout;
    }

    enum def AlertTier {
        doc /* ECN-014 escalation levels: Ops Hub notification (alert), Tier 2
             * (station auto-close, 100 m geofence), Tier 1 emergency (all four
             * cryo stations closed, full IZ + ISRU geofence). Source: fleet v9
             * s.9.2 table. */
        alert;
        tier2;
        tier1Emergency;
    }

    abstract part def SoftwareElement :> PhaseGated {
        doc /* Base for software-defined elements; deployed on hardware named
             * in 'hostedOn'. Source: ARCHITECTURE_BASELINE.md s.7 "software
             * is a separate element". */
        attribute hostedOn : String;
    }

    // =====================================================================
    // Supervision tiers and their state machines
    // =====================================================================

    state def SupervisionLocation {
        doc /* Where SENTINEL is supervised from, by phase: Earth at 2.56 s RTT
             * during P2-P3, the SPA Ops Hub from the crew sign-off (DG-4.1,
             * P4), and SPA supervising the PKT edge node at 0.5 s from PKT
             * construction start (DG-8.1, P8). The triggers are the gate
             * outcomes themselves (GatePassed items from SeleniteGates), so
             * the machine advances exactly when the derived plan says the
             * gate passed. Source: ARCHITECTURE_BASELINE.md s.2 and s.7;
             * SentinelEdgeTier phase attributes. */
        entry; then earthSupervised;
        state earthSupervised {
            doc /* Earth ops hub supervises SPA directly (P2-P3). */
        }
        state spaOpsHubSupervised {
            doc /* SPA Ops Hub commands; Earth has strategic oversight (P4+). */
        }
        state spaSupervisingPkt {
            doc /* SPA Ops Hub also supervises the PKT edge node over the relay
                 * at 0.5 s (P8+). */
        }
        transition crewSignOff
            first earthSupervised
            accept g : GatePassed
            if g.gateId == "DG-4.1"
            then spaOpsHubSupervised;
        transition pktConstructionStart
            first spaOpsHubSupervised
            accept g : GatePassed
            if g.gateId == "DG-8.1"
            then spaSupervisingPkt;
    }

    state def SentinelOperatingModes {
        doc /* The three SENTINEL modes as states. The repository documents
             * name the modes (ARCHITECTURE_BASELINE.md s.7) and one escalation
             * path - an ECN-014 auto-close notifies the Ops Hub and raises a
             * Tier 2 / Tier 1 alert (fleet v9 s.9.2), which is exception
             * flagging to humans. Every other transition is declared with its
             * trigger UNBOUND: the mode table is in SEL-SW-SENTINEL-001 Rev B,
             * which is not in the repository (TODO). */
        entry; then preProgrammedExecution;
        state preProgrammedExecution {
            doc /* Executing the uploaded plan. */
        }
        state localAiWithinSafeParameters {
            doc /* Local decisions inside the safe envelope. */
        }
        state exceptionFlaggingToHumans {
            doc /* An exception raised to the supervising ops hub. */
        }
        transition toLocalAi
            first preProgrammedExecution
            then localAiWithinSafeParameters {
            doc /* Trigger UNBOUND: SEL-SW-SENTINEL-001 Rev B mode table (not
                 * in the repository). */
        }
        transition backToPlan
            first localAiWithinSafeParameters
            then preProgrammedExecution {
            doc /* Trigger UNBOUND: SEL-SW-SENTINEL-001 Rev B. */
        }
        transition faultPatternEscalation
            first localAiWithinSafeParameters
            accept SensorReading
            then exceptionFlaggingToHumans {
            doc /* ECN-014 via fleet v9 s.9.2: an alert or auto-close is an Ops
                 * Hub notification (Tier 2 / Tier 1 emergency) - the one
                 * documented escalation. */
        }
        transition planExceptionEscalation
            first preProgrammedExecution
            accept SensorReading
            then exceptionFlaggingToHumans {
            doc /* The same ECN-014 escalation from pre-programmed execution. */
        }
        transition humanResolution
            first exceptionFlaggingToHumans
            then preProgrammedExecution {
            doc /* Trigger UNBOUND: the human disposition that returns SENTINEL
                 * to its plan - SEL-SW-SENTINEL-001 Rev B. */
        }
    }

    part def EarthOpsHubTier :> SoftwareElement {
        doc /* Tier 1: Earth operations hub. Supervises SPA directly at 2.56 s
             * RTT during P2-P3; thereafter strategic oversight only. Source:
             * ARCHITECTURE_BASELINE.md s.2 (P2 row) and s.7; Strategy v3.1
             * s.8.3 (fuel loading controlled from SPA). */
        attribute redefines introducedIn = Phase::P0;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "Earth ops hub";
        attribute tier = SupervisionTier::earthOpsHub;
        attribute directSupervisionOfSpaUntil = Phase::P3;
        port edgeSupervision : ~SupervisionPort;
        port earthHost : SupervisionPort;
    }

    part def SentinelEdgeTier :> SoftwareElement {
        doc /* Tier 2: SENTINEL base AI commander at the edge. Runs on SPA
             * Ops Hub compute from P4; a PKT instance from P8 is supervised
             * from SPA over the 0.5 s relay link. Exhibits the supervision
             * location machine. Software spec: SEL-SW-SENTINEL-001 Rev B (not
             * in the repository). Rover hardware is SeleniteFleet::SentinelRover
             * - a separate element. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "SPA Ops Hub (P4+); PKT edge node (P8+)";
        attribute tier = SupervisionTier::sentinelEdge;
        attribute supervisedFromEarthUntil = Phase::P3;
        attribute supervisedFromSpaFrom = Phase::P4;
        attribute pktSupervisedFromSpaFrom = Phase::P8;
        attribute supervisionNodeEarly = SiteId::earth;
        attribute supervisionNodeSteady = SiteId::spa;
        port uplink : SupervisionPort;
        port spaHost : SupervisionPort;
        port pktSupervision : ~SupervisionPort;
        port fleetSupervision : ~SupervisionPort;
        exhibit state location : SupervisionLocation;
    }

    part def FleetTier :> SoftwareElement {
        doc /* Tier 3: on-vehicle autonomy across the fleet (SAE Level 4 on
             * surface rovers per fleet v9 s.1). Individual vehicle software
             * elements (MoleIFlightSoftware, SubstationController) sit here;
             * every SeleniteFleet asset carries a supervision port. */
        attribute redefines introducedIn = Phase::P1;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "fleet vehicles and fixed infrastructure";
        attribute tier = SupervisionTier::fleet;
        port uplink : SupervisionPort;
        port vehicles : ~SupervisionPort;
    }

    part def SentinelSystem :> SoftwareElement {
        doc /* The SENTINEL supervision system as a whole: three tiers linked
             * by SupervisionLink interfaces, three modes exhibited as a state
             * machine, with the ECN-014 valve monitoring functions attached.
             * Source: SEL-SW-SENTINEL-001 Rev B (not in the repository);
             * ARCHITECTURE_BASELINE.md s.7; fleet v9 s.9.2. */
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

        port earthLink : SupervisionPort;
        port spaOpsHubLink : SupervisionPort;
        port pktRelayLink : ~SupervisionPort;
        port fleetLink : ~SupervisionPort;

        bind earthLink = earthOpsHub.earthHost;
        bind spaOpsHubLink = edge.spaHost;
        bind pktRelayLink = edge.pktSupervision;
        bind fleetLink = fleetTier.vehicles;

        interface earthToEdge : SupervisionLink connect edge.uplink to earthOpsHub.edgeSupervision;
        interface edgeToFleet : SupervisionLink connect fleetTier.uplink to edge.fleetSupervision;

        exhibit state modes : SentinelOperatingModes;
    }

    // =====================================================================
    // ECN-014: cryo transfer line and O2 line monitoring
    // =====================================================================

    enum def ValveMonitorAction {
        doc /* Response classes of the ECN-014 monitoring logic (fleet v9
             * s.9.2 table: Alert, Auto-close, Dead-man). */
        alert;
        autoClose;
        deadManFailClosed;
    }

    state def CryoValveStationStates {
        doc /* One cryo isolation valve station under SENTINEL monitoring, per
             * the ECN-014 condition / level / action table (fleet v9 s.9.2):
             * H2 >= alert threshold -> Alert (Ops Hub notification, polling
             * raised); H2 >= auto-close threshold -> both valves closed, Tier
             * 2, 100 m geofence (#201); pressure >= auto-close threshold ->
             * both valves closed, Tier 2, 1 s pre-trigger buffer logged
             * (#202); UV flame -> close, and the function closes ALL four
             * stations as a Tier 1 emergency (#203,
             * CryoMonitoringFunctionStates); comms loss beyond the dead-man
             * timeout -> the valve fails closed by spring return, Tier 2 on
             * restoration (#206). Re-open is crew-only with four
             * preconditions. The thresholds and the hold periods are
             * attributes bound by the exhibiting monitor and UNBOUND there
             * (rule 3; the ECN-014 figures are in the monitor's doc). The
             * guards read the latest readings the monitor holds. Transitions
             * the table does not give (an alert that clears without
             * escalating) are declared with the trigger UNBOUND. */
        attribute alertThresholdPpm : Real;
        attribute autoCloseThresholdPpm : Real;
        attribute pressureCloseThresholdBar : Real;
        attribute deadManTimeoutSeconds : Real;
        attribute latestH2Ppm : Real;
        attribute latestPressureBar : Real;
        attribute uvFlameDetected : Boolean;
        attribute commsLossSeconds : Real;
        attribute commsLost : Boolean;
        attribute reopenH2Clear : Boolean;
        attribute reopenPressureLow : Boolean;
        attribute reopenNoUvForHoldPeriod : Boolean;
        attribute reopenVerbalConfirmation : Boolean;

        entry; then open;
        state open {
            doc /* Both valves open, sensors polled at the base rate. */
        }
        state alert {
            doc /* Ops Hub notified, polling raised; valves still open. */
        }
        state autoClosed {
            doc /* Both valves closed over the hardwired 24 VDC line; closure
                 * confirmed by limit switch; Tier 2; geofence. Re-open
                 * crew-only. */
            entry action confirmClosureByLimitSwitch;
        }
        state failedClosed {
            doc /* Dead-man: the hardwired signal was lost beyond the timeout
                 * and the spring return closed the valves. */
            entry action confirmClosureByLimitSwitch;
        }

        transition h2Alert
            first open
            accept H2Reading
            if latestH2Ppm >= alertThresholdPpm
            then alert {
            doc /* #201 onset: H2 at the alert threshold (fleet v9 s.9.2 row 1). */
        }
        transition h2AutoCloseFromAlert
            first alert
            accept H2Reading
            if latestH2Ppm >= autoCloseThresholdPpm
            then autoClosed {
            doc /* #201 H2 leak: auto-close (row 2). */
        }
        transition h2AutoCloseFromOpen
            first open
            accept H2Reading
            if latestH2Ppm >= autoCloseThresholdPpm
            then autoClosed {
            doc /* #201 H2 leak when the first reading is already past the
                 * auto-close threshold (the table states conditions, not a
                 * sequence). */
        }
        transition overpressureFromOpen
            first open
            accept PressureReading
            if latestPressureBar >= pressureCloseThresholdBar
            then autoClosed {
            doc /* #202 overpressure (row 3). */
        }
        transition overpressureFromAlert
            first alert
            accept PressureReading
            if latestPressureBar >= pressureCloseThresholdBar
            then autoClosed {
            doc /* #202 overpressure during an H2 alert. */
        }
        transition uvFlameFromOpen
            first open
            accept UvFlameReading
            if uvFlameDetected
            then autoClosed {
            doc /* #203 UV flame (row 4): this station closes; the function
                 * closes all four. */
        }
        transition uvFlameFromAlert
            first alert
            accept UvFlameReading
            if uvFlameDetected
            then autoClosed {
            doc /* #203 UV flame during an H2 alert. */
        }
        transition deadManFromOpen
            first open
            if commsLossSeconds > deadManTimeoutSeconds
            then failedClosed {
            doc /* #206 comms timeout (row 5): no event, a timeout - the valve
                 * fails closed by spring return. */
        }
        transition deadManFromAlert
            first alert
            if commsLossSeconds > deadManTimeoutSeconds
            then failedClosed {
            doc /* #206 comms timeout during an H2 alert. */
        }
        transition commsRestored
            first failedClosed
            if not commsLost
            then autoClosed {
            doc /* "Tier 2 on restoration": the station is then an auto-closed
                 * Tier 2 station and re-open is crew-only. */
        }
        transition crewReopen
            first autoClosed
            accept CrewReopenCommand
            if reopenH2Clear and reopenPressureLow and reopenNoUvForHoldPeriod and reopenVerbalConfirmation
            then open {
            doc /* Crew command with the four ECN-014 preconditions (H2 below the
                 * clear threshold for the hold period, pressure below the
                 * re-open threshold, no UV for the hold period, verbal
                 * confirmation). */
        }
        transition alertCleared
            first alert
            then open {
            doc /* Trigger UNBOUND: the ECN-014 table gives no clearing
                 * condition for an alert that does not escalate. Source needed:
                 * SEL-SW-SENTINEL-001 Rev B (not in the repository). */
        }
    }

    state def CryoMonitoringFunctionStates {
        doc /* The function-level ECN-014 rule: UV flame at ANY of the four
             * stations closes ALL four cryo stations - Tier 1 emergency, full
             * IZ + ISRU geofence (fleet v9 s.9.2 row 4). Stand-down is not
             * described in the repository documents. */
        attribute uvFlameAtAnyStation : Boolean;
        entry; then normal;
        state normal {
            doc /* Stations individually in their own machines. */
        }
        state tier1Emergency {
            doc /* All four stations commanded closed; full geofence. */
            entry action closeAllFourStations;
        }
        transition uvFlameAnyStation
            first normal
            accept UvFlameReading
            if uvFlameAtAnyStation
            then tier1Emergency {
            doc /* #203 at the function level. */
        }
        transition standDown
            first tier1Emergency
            then normal {
            doc /* Trigger UNBOUND: no stand-down criterion in fleet v9 s.9.2.
                 * Source needed: SEL-SW-SENTINEL-001 Rev B. */
        }
    }

    state def O2SupplyLineStates {
        doc /* Habitat O2 supply line (ECN-014 via fleet v9 s.9.2): two pressure
             * transducers; auto-close on hab-end overpressure (#204) or excess
             * flow (#205); the hab runs on its reserve until resolved. The
             * thresholds (200 kPa hab-end, 2x normal flow in the source) are
             * UNBOUND attributes of the monitor. */
        attribute habEndOverpressureThresholdKpa : Real;
        attribute excessFlowRatioThreshold : Real;
        attribute latestHabEndPressureKpa : Real;
        attribute latestFlowRatio : Real;
        entry; then open;
        state open {
            doc /* Line open, hab fed from the ISRU farm. */
        }
        state autoClosed {
            doc /* Line closed; hab O2 on reserve until resolved. */
        }
        transition habEndOverpressure
            first open
            accept O2LineReading
            if latestHabEndPressureKpa >= habEndOverpressureThresholdKpa
            then autoClosed {
            doc /* #204 O2 overpressure. */
        }
        transition excessFlow
            first open
            accept O2LineReading
            if latestFlowRatio >= excessFlowRatioThreshold
            then autoClosed {
            doc /* #205 O2 high flow. */
        }
        transition resolved
            first autoClosed
            then open {
            doc /* Trigger UNBOUND: "until resolved" - no re-open criterion in
                 * the repository documents. Source needed: SEL-SW-SENTINEL-001
                 * Rev B. */
        }
    }

    part def ValveStationSensorSet {
        doc /* Per-station sensor set per ECN-014: catalytic H2 (cross-checked
             * pair), solar-blind UV flame detector, pressure transducer
             * (fleet v9 s.9.2). Sensor counts and polling rates (10 Hz
             * pressure, 1 Hz H2 / UV in the source) are Wave 5 data. */
        port readings : SensorPort;
    }

    part def ValveStationMonitor {
        doc /* Monitor for one cryo isolation valve station. Auto-close acts
             * over a hardwired 24 VDC signal to the pneumatic actuator (NOT CAN
             * bus or SpaceWire); comms loss beyond the dead-man timeout fails
             * the valve closed by spring return. Closure confirmed by limit
             * switch. Re-open is crew-only with four preconditions (H2 clear,
             * pressure low, no UV for the hold period, verbal confirmation).
             * Wave 4B: the behaviour is CryoValveStationStates, exhibited here
             * with its thresholds bound to this monitor's attributes, which
             * stay UNBOUND (rule 3): fleet v9 s.9.2 gives 100 ppm alert, 1,000
             * ppm auto-close, 5 bar, 60 s dead-man, closure within 3 s, re-open
             * at H2 < 10 ppm for 5 min, pressure < 3 bar, no UV for 10 min.
             * Source: ECN-014 extract in fleet v9 s.9.2; SEL-SW-SENTINEL-001
             * Rev B (not in the repository - TODO). */
        part sensors : ValveStationSensorSet;
        port stationSensorInput : ~SensorPort;
        port hardwiredCloseSignal : HardwiredClosePort;
        port limitSwitchFeedback : ~LimitSwitchPort;
        attribute h2AlertThresholdPpm : Real;
        attribute h2AutoCloseThresholdPpm : Real;
        attribute pressureAutoCloseThresholdBar : Real;
        attribute deadManTimeoutSeconds : Real;
        attribute closureConfirmationSeconds : Real;
        attribute reopenH2ClearThresholdPpm : Real;
        attribute reopenH2ClearHoldMinutes : Real;
        attribute reopenPressureThresholdBar : Real;
        attribute reopenNoUvHoldMinutes : Real;
        attribute latestH2Ppm : Real;
        attribute latestPressureBar : Real;
        attribute uvFlameDetected : Boolean;
        attribute commsLossSeconds : Real;
        attribute commsLost : Boolean;
        attribute reopenRequiresCrewCommand : Boolean = true;
        attribute reopenPreconditionCount : Integer = 4;
        attribute closeSignalHardwired : Boolean = true;
        attribute closeSignalOverFieldbus : Boolean = false;
        attribute deadManFailsClosed : Boolean = true;
        exhibit state stationState : CryoValveStationStates {
            :>> alertThresholdPpm = h2AlertThresholdPpm;
            :>> autoCloseThresholdPpm = h2AutoCloseThresholdPpm;
            :>> pressureCloseThresholdBar = pressureAutoCloseThresholdBar;
            :>> deadManTimeoutSeconds = deadManTimeoutSeconds;
            :>> latestH2Ppm = latestH2Ppm;
            :>> latestPressureBar = latestPressureBar;
            :>> uvFlameDetected = uvFlameDetected;
            :>> commsLossSeconds = commsLossSeconds;
            :>> commsLost = commsLost;
        }
        assert constraint ecn014DeadManLogic {
            doc /* ECN-014 asserted: the close path is hardwired and never a
                 * fieldbus; loss of signal fails closed; re-open is crew-only
                 * with exactly four preconditions. */
            closeSignalHardwired == true
                and closeSignalOverFieldbus == false
                and deadManFailsClosed == true
                and reopenRequiresCrewCommand == true
                and reopenPreconditionCount == 4
        }
    }

    part def ValveStateTable {
        doc /* VALVE_STATE database table, the 11th table of the SENTINEL
             * schema (one row per monitored valve, rolling retention; 8 rows,
             * 10 Hz cryo / 1 Hz O2, 90-day retention in the source). Schema as
             * attached CSV when SEL-SW-SENTINEL-001 Rev B is in the repository
             * (TODO). Source: ECN-014 extract, fleet v9 s.9.2. */
        attribute tableOrdinal : Integer = 11;
    }

    part def FaultPatternCatalogue {
        doc /* Fault pattern library; ECN-014 adds patterns #201-#206 (H2 leak,
             * overpressure, UV flame, O2 overpressure, O2 high flow, comms
             * timeout), each a transition in the state machines above. The
             * full pattern table (206 patterns, ARCHITECTURE_BASELINE.md s.7)
             * is in SEL-SW-SENTINEL-001 Rev B (not in the repository - TODO
             * attached CSV). Source: fleet v9 s.9.2. */
        attribute ecn014PatternRangeStart : Integer = 201;
        attribute ecn014PatternRangeEnd : Integer = 206;
        attribute ecn014Patterns = (
            Ecn014FaultPattern::h2Leak, Ecn014FaultPattern::overpressure,
            Ecn014FaultPattern::uvFlame, Ecn014FaultPattern::o2Overpressure,
            Ecn014FaultPattern::o2HighFlow, Ecn014FaultPattern::commsTimeout
        );
    }

    part def CryoValveMonitoringFunction :> SoftwareElement {
        doc /* ECN-014 cryo transfer line monitoring: four isolation valve
             * stations on the ISRU-IZ LH2/LOX transfer lines (two at the ISRU
             * manifold exit, two at the IZ propellant farm entry). Four
             * stations are the ECN-014 architecture, hence the multiplicity.
             * UV flame at any station closes all four (Tier 1 emergency,
             * CryoMonitoringFunctionStates). The physical stations live in
             * SeleniteHabitat::IsruPlant; the sensor, hardwired-close and
             * limit-switch interfaces are made in SeleniteConfigurations.
             * Introduced with the propellant farm at P3 (ISRU first output).
             * Source: ECN-014 extract, fleet v9 s.9.2 and s.12.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "SENTINEL edge tier + hardwired station loop";
        part stationMonitors : ValveStationMonitor[4];
        part valveStateTable : ValveStateTable;
        part faultPatterns : FaultPatternCatalogue;
        attribute uvFlameAtAnyStation : Boolean;
        exhibit state functionState : CryoMonitoringFunctionStates {
            :>> uvFlameAtAnyStation = uvFlameAtAnyStation;
        }
    }

    part def O2SupplyLineMonitoringFunction :> SoftwareElement {
        doc /* ECN-014 habitat O2 supply line monitoring: pressure transducers,
             * auto-close on hab-end overpressure or excess flow; hab on
             * reserve until resolved. Thresholds UNBOUND (200 kPa hab-end,
             * 2x normal flow, 90-day reserve in fleet v9 s.9.2). Crewed from
             * P4. Source: ECN-014 extract, fleet v9 s.9.2. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "SENTINEL edge tier";
        port o2LineSensors : ~SensorPort;
        port o2AutoCloseSignal : HardwiredClosePort;
        attribute habEndOverpressureThresholdKpa : Real;
        attribute excessFlowRatioThreshold : Real;
        attribute latestHabEndPressureKpa : Real;
        attribute latestFlowRatio : Real;
        exhibit state lineState : O2SupplyLineStates {
            :>> habEndOverpressureThresholdKpa = habEndOverpressureThresholdKpa;
            :>> excessFlowRatioThreshold = excessFlowRatioThreshold;
            :>> latestHabEndPressureKpa = latestHabEndPressureKpa;
            :>> latestFlowRatio = latestFlowRatio;
        }
    }

    // =====================================================================
    // NAV-001: MOLE-I three-layer navigation fusion
    // =====================================================================

    action def ReadTetherPolarFix {
        doc /* NAV-001 layer 1: the polar fix from the tether drum payout range
             * and the DRM-040 two-axis angle encoder on the substation guide
             * roller (fleet v9 s.4.1: +/- 0.5 m at 200 m, quoted not bound).
             * The encoder reading comes from the substation - over the tether
             * when tethered, over the UHF construction link when not. */
        in item encoder : SubstationEncoderReading;
        out item fix : TetherFixReading;
    }

    action def ReadWheelOdometry {
        doc /* NAV-001 layer 2: the six wheel encoders (fleet v9 s.4.1). */
        out item odometry : OdometryReading;
    }

    action def ReadImu {
        doc /* NAV-001 layer 3: the MEMS IMU inside the WEB (fleet v9 s.4.1). */
        out item imu : ImuReading;
    }

    action def KalmanUpdate {
        doc /* The Kalman fusion step on the existing MOLE-I PLC (fleet v9
             * s.4.1: 10 Hz, quoted not bound). Filter model and noise
             * matrices: SEL-NAV-001 Rev A (not in the repository - TODO). */
        in item fix : TetherFixReading;
        in item odometry : OdometryReading;
        in item imu : ImuReading;
        out item estimate : PositionEstimate;
    }

    action def UpdateDrillGrid {
        doc /* Mark the drilled cell in the per-sector workspace grid in
             * non-volatile flash (fleet v9 s.4.1). */
        in item estimate : PositionEstimate;
        out item update : DrillGridUpdate;
    }

    action def NavigationFusion {
        doc /* SEL-NAV-001 Rev A fusion as an action flow: the three layers are
             * read in parallel, fused, and the estimate marks the drill grid.
             * Rates and accuracies stay in the docs (rule 3). Allocated in
             * MoleINavigation to the sensing parts and the Kalman filter on
             * the PLC. */
        in item encoder : SubstationEncoderReading;
        out item estimate : PositionEstimate;
        out item gridUpdate : DrillGridUpdate;
        attribute fusionRateHz : Real;
        action tetherFix : ReadTetherPolarFix;
        action odometry : ReadWheelOdometry;
        action imu : ReadImu;
        action fuse : KalmanUpdate;
        action markGrid : UpdateDrillGrid;
        flow encoder to tetherFix.encoder;
        flow tetherFix.fix to fuse.fix;
        flow odometry.odometry to fuse.odometry;
        flow imu.imu to fuse.imu;
        flow fuse.estimate to estimate;
        flow fuse.estimate to markGrid.estimate;
        flow markGrid.update to gridUpdate;
        first start;
        succession start then tetherFix;
        succession start then odometry;
        succession start then imu;
        succession tetherFix then fuse;
        succession odometry then fuse;
        succession imu then fuse;
        succession fuse then markGrid;
        succession markGrid then done;
    }

    part def TetherPolarFix {
        doc /* NAV-001 layer 1: tether drum payout range + two-axis angle
             * encoder on the substation guide roller. Source: ECN-013,
             * SEL-NAV-001 Rev A (neither in the repository); fleet v9 s.4.1. */
    }

    part def WheelOdometry {
        doc /* NAV-001 layer 2: six existing wheel encoders. Source: SEL-NAV-001
             * Rev A; fleet v9 s.4.1. */
    }

    part def MemsImu {
        doc /* NAV-001 layer 3: MEMS IMU inside the WEB (SEL-MI-NAV-001). Source:
             * SEL-NAV-001 Rev A; fleet v9 s.4.1. */
    }

    part def KalmanFusion {
        doc /* NAV-001 fusion filter on the existing MOLE-I PLC; performs the
             * KalmanUpdate step of NavigationFusion. Source: SEL-NAV-001 Rev A
             * (not in the repository); fleet v9 s.4.1. */
    }

    part def DrillGridMap {
        doc /* NAV-001 workspace drill grid per sector (polar grid of radial x
             * angular bins) in non-volatile flash; enables gap-free systematic
             * mining over the service life. Cell count (3,600 per sector in
             * fleet v9 s.4.1) is a Wave 5 value. Source: SEL-NAV-001 Rev A;
             * fleet v9 s.4.1. */
    }

    part def UhfConstructionLink {
        doc /* UHF link used during PSR network construction (NAV-001 / ECN-013
             * RF construction): the encoder reading of the polar fix reaches an
             * untethered rover over it. Source: ECN-013 v1 (not in the
             * repository - TODO); ARCHITECTURE_BASELINE.md s.7. */
        port radio : ~ConstructionRadioPort;
    }

    part def MoleINavigation :> SoftwareElement {
        doc /* SEL-NAV-001 Rev A: three-layer MOLE-I navigation (tether polar
             * fix + wheel odometry + IMU, Kalman-fused) with the drill grid
             * map and UHF construction link. Structural subsystem of MOLE-I
             * (see SeleniteFleet::MoleI). Wave 4B: performs NavigationFusion,
             * allocated to its parts; the encoder reading arrives over the
             * tether (operation) or the UHF construction link (construction) -
             * the one place the navigation depends on ECN-013's RF
             * construction provision. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "MOLE-I PLC inside WEB";
        part tetherFix : TetherPolarFix;
        part odometry : WheelOdometry;
        part imu : MemsImu;
        part fusion : KalmanFusion;
        part drillGrid : DrillGridMap;
        part constructionLink : UhfConstructionLink;
        port tetherData : ~TetherPort;
        perform action navigate : NavigationFusion;
        allocate navigate.tetherFix to tetherFix;
        allocate navigate.odometry to odometry;
        allocate navigate.imu to imu;
        allocate navigate.fuse to fusion;
        allocate navigate.markGrid to drillGrid;
        flow tetherData.encoder to navigate.encoder;
        flow constructionLink.radio.encoder to navigate.encoder;
    }

    // =====================================================================
    // MOLE-I flight software and the substation controller
    // =====================================================================

    state def MoleIOperatingStates {
        doc /* MOLE-I operating states the repository documents describe (fleet
             * v9 s.4.1): transit on battery, drill operations with the
             * mini-VEX, the ECN-012 batch dump sequence (pre-heat at the tank
             * fraction, heater on through retraction, dump and purge) and
             * standby on WEB keep-alive. The dump is entered when the tank
             * reaches the pre-heat fraction (quoted 90 %, UNBOUND); every
             * other trigger is UNBOUND - the mode and drill sequencing logic is
             * SEL-SW-MOLEI-001 Rev D, not in the repository (TODO). */
        attribute tankFillFraction : Real;
        attribute preHeatTankFraction : Real;
        entry; then standby;
        state standby {
            doc /* WEB keep-alive only. */
        }
        state transit {
            doc /* Battery transit between cells (tether paid out). */
        }
        state drilling {
            doc /* Rotary-percussive drill and mini-VEX at a grid cell. */
        }
        state batchDump {
            doc /* ECN-012 rear-nozzle dump to the substation manifold:
                 * pre-heat, heater on, retraction, dump, purge. */
        }
        transition leaveStandby
            first standby
            then transit {
            doc /* Trigger UNBOUND: SEL-SW-MOLEI-001 Rev D. */
        }
        transition arriveAtCell
            first transit
            then drilling {
            doc /* Trigger UNBOUND (the drill-grid cell selection):
                 * SEL-SW-MOLEI-001 Rev D. */
        }
        transition tankAtPreHeatFraction
            first drilling
            if tankFillFraction >= preHeatTankFraction
            then batchDump {
            doc /* ECN-012 via fleet v9 s.4.1: "pre-heat at 90 % tank". */
        }
        transition dumpComplete
            first batchDump
            then drilling {
            doc /* Trigger UNBOUND (purge complete): SEL-SW-MOLEI-001 Rev D. */
        }
        transition moveOn
            first drilling
            then transit {
            doc /* Trigger UNBOUND (cell exhausted): SEL-SW-MOLEI-001 Rev D. */
        }
        transition toStandby
            first transit
            then standby {
            doc /* Trigger UNBOUND: SEL-SW-MOLEI-001 Rev D. */
        }
    }

    part def MoleIFlightSoftware :> SoftwareElement {
        doc /* SEL-SW-MOLEI-001 Rev D: MOLE-I on-board software hosting NAV-001.
             * Wave 4B: exhibits MoleIOperatingStates (the documented states,
             * triggers unbound where the Rev D document - not in the
             * repository - is needed); performs the navigation through its
             * subsystem. Source: SEL-SW-MOLEI-001 Rev D (TODO); fleet v9
             * s.4.1. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "MOLE-I PLC inside WEB";
        part navigation : MoleINavigation;
        attribute tankFillFraction : Real;
        attribute preHeatTankFraction : Real;
        port supervision : SupervisionPort;
        exhibit state operatingState : MoleIOperatingStates {
            :>> tankFillFraction = tankFillFraction;
            :>> preHeatTankFraction = preHeatTankFraction;
        }
    }

    part def SubstationController :> SoftwareElement {
        doc /* SEL-SW-SUB-001 Rev C: substation (SATS+WEB) controller - tether
             * drum tension, WEB thermal setpoint, water manifold pump,
             * MOLE-I port allocation. Wave 4B: ports typed (supervision up to
             * the edge, the UHF construction link to untethered rovers); the
             * control behaviour stays UNMODELLED because SEL-SW-SUB-001 Rev C
             * is not in the repository (TODO) and fleet v9 s.13.4 gives the
             * functions, not their logic. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "substation WEB PLC";
        port supervision : SupervisionPort;
        port constructionRadio : ConstructionRadioPort;
    }
}
