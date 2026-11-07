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
         * Addendum (7 Nov 2026, same wave, W4B-N18 onward): the primary
         * sources are now in docs/ (markdown extracts; originals under
         * docs/sources/): SEL-SW-SENTINEL-001 Rev B, SEL_SENTINEL_DESIGN Rev
         * B, SEL-NAV-001 Rev A, SEL-SW-MOLEI-001 Rev D, SEL-SW-SUB-001 Rev C,
         * SEL-CON-001 Rev B updated, SEL-ECN-012, SEL-ECN-013, SEL-ISRU-001
         * Rev D updated, updated_SEL-CAD-ISRU-001, SEL-CAP-001 Rev A updated,
         * SEL_EVA_CONTINGENCY corrected. From them: the ECN-012 dump sequence
         * triggers, the NAV-001 dock-cycle resets and grid upload, the
         * SENTINEL anomaly workflow, authority levels, no-contact mode and
         * PKT escalation tiers, the ECN-014 clear / stand-down / resolved
         * triggers (the anomaly ticket closing at workflow step 6), the
         * substation port allocation and breaker logic, the polar fix
         * computed on the substation (correcting the Wave 4B rover-side
         * ReadTetherPolarFix), construction navigation by tap count, the
         * PLC / UHF switchover, the bayonet engagement, the construction tap
         * hop and the CAP mission sequence with its SPE abort. Still UNBOUND
         * after the sources: the three SENTINEL mode transitions (the
         * documents carry an authority model, not a mode table - W4B-N21) and
         * the MOLE-I "cell exhausted" criterion (NAV-001 is silent). Earlier
         * sources: SEL_ROBOT_FLEET_v9.md s.4.1, s.9.2 (ECN-014 extract),
         * s.10.1, s.13.4; SEL-T1.1-STRATEGY v3.1 s.4.2, s.5.1;
         * ARCHITECTURE_BASELINE.md s.7. */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;

    enum def SupervisionMode {
        doc /* The three SENTINEL operating modes of ARCHITECTURE_BASELINE.md
             * s.7. SEL-SW-SENTINEL-001 Rev B and SEL_SENTINEL_DESIGN Rev B
             * (docs/) do not name them: they carry the five-level authority
             * model (AuthorityLevel) and the anomaly severities
             * (AnomalySeverity) instead - W4B-N21. */
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

    enum def AuthorityLevel {
        doc /* SENTINEL authority model: MONITOR (no state change), RECOMMEND
             * (no execution until a human approves), EXECUTE (pre-approved
             * routine actions, crew may override), GATE (hard prerequisite
             * needing explicit human approval, no timeout), EMERGENCY (the
             * only autonomous irreversible action: fire, depressurisation,
             * explosive H2 at SPA; PKT adds MSR emergency shutdown by control
             * rod drop, conveyor emergency stop and mass driver abort).
             * Source: SEL_SENTINEL_DESIGN Rev B s.5, s.8.4. */
        monitor;
        recommend;
        execute;
        gate;
        emergency;
    }

    enum def AnomalySeverity {
        doc /* Anomaly workflow step 2 classification: ADVISORY (drifting
             * within limits, log only), CAUTION (at limit or single-sensor,
             * cross-check), WARNING (confirmed, isolate and report URGENT),
             * EMERGENCY (life-safety, autonomous response). Source:
             * SEL_SENTINEL_DESIGN Rev B s.4.3. */
        advisory;
        caution;
        warning;
        emergency;
    }

    enum def PktEscalationTier {
        doc /* PKT node exception escalation to the SPA Ops Hub: T0 local
             * (logged, not uplinked unless requested), T1 advisory (contained,
             * uplinked in the next data packet - 60 s in the source, not
             * modelled), T2 alert (subsystem isolated, uplinked immediately
             * with full trace, crew guidance requested), T3 emergency (P0
             * autonomous response, immediate notification, adjacent nodes
             * notified for sector absorption). Source: SEL-SW-SENTINEL-001
             * Rev B s.15.3. Naming: SEL_SENTINEL_DESIGN Rev B s.8.2 speaks of
             * "Tier 1 or Tier 2 alert classification" where s.15.3 defines
             * T0-T3 (recorded, not resolved). */
        t0Local;
        t1Advisory;
        t2Alert;
        t3Emergency;
    }

    enum def TetherConnectionType {
        doc /* What the MOLE-I is plugged into: its permanent substation drum
             * port (PLC comms), a construction tap on a temporary tether (UHF
             * comms, no PLC handshake), or nothing (battery transit, UHF).
             * Source: SEL-ECN-013 s.5; SEL_MOLEI_DESIGN v5 s.4.7-4.8. */
        permanentDrumPort;
        constructionTap;
        untethered;
    }

    // ---- Software data items local to this package ----

    item def AnomalyClassification :> DataItem {
        doc /* The severity SENTINEL assigns at anomaly workflow step 2 (and
             * re-assigns on escalation at step 6). Source: SEL_SENTINEL_DESIGN
             * Rev B s.4.3. */
        abstract attribute severity : AnomalySeverity;
    }

    item def AnomalyTicketClosed :> DataItem {
        doc /* Anomaly workflow step 6: after the corrective action SENTINEL
             * re-inspects, confirms the anomaly resolved and closes the ticket
             * in the maintenance database. It is the trigger every ECN-014
             * machine returns on (alert clear, Tier 1 stand-down, O2 line
             * resolved). Source: SEL_SENTINEL_DESIGN Rev B s.4.3 step 6. */
    }

    item def CrewDisposition :> DataItem {
        doc /* Anomaly workflow step 5: crew or Earth mission control approves,
             * modifies or rejects the recommended action. Source:
             * SEL_SENTINEL_DESIGN Rev B s.4.3 step 5. */
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
        doc /* The three SENTINEL modes as states (ARCHITECTURE_BASELINE.md
             * s.7). Addendum (7 Nov 2026): SEL-SW-SENTINEL-001 Rev B and
             * SEL_SENTINEL_DESIGN Rev B are in docs/ and carry no mode table
             * (W4B-N21) - their behaviour is the authority model
             * (AuthorityLevel), the anomaly workflow (AnomalyResponseWorkflow)
             * and the no-contact mode (EarthContactStates). No document
             * equates the modes with the anomaly severities or the ECN-014
             * tiers, so the escalation transitions keep their Wave 4B form
             * (the ECN-014 Ops Hub notification on a reading, fleet v9 s.9.2)
             * with the candidate trigger recorded, and all five transitions
             * stay UNBOUND where the sources are silent (W4B-N21). */
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
            doc /* Trigger UNBOUND (W4B-N21): neither SEL-SW-SENTINEL-001 Rev B
                 * nor SEL_SENTINEL_DESIGN Rev B describes a mode change; the
                 * EXECUTE authority level covers both states. */
        }
        transition backToPlan
            first localAiWithinSafeParameters
            then preProgrammedExecution {
            doc /* Trigger UNBOUND (W4B-N21), as toLocalAi. */
        }
        transition faultPatternEscalation
            first localAiWithinSafeParameters
            accept SensorReading
            then exceptionFlaggingToHumans {
            doc /* ECN-014 via fleet v9 s.9.2: an alert or auto-close is an Ops
                 * Hub notification (Tier 2 / Tier 1 emergency) - the one
                 * documented escalation. Candidate trigger, NOT bound:
                 * SEL_SENTINEL_DESIGN Rev B s.4.3 step 4 reports every severity
                 * to humans (ADVISORY / CAUTION displayed and downlinked,
                 * WARNING URGENT, EMERGENCY post-facto) and SEL-SW-SENTINEL-001
                 * Rev B s.15.3 escalates by tier; no document equates the
                 * ECN-014 tiers with the s.4.3 severities or the modes
                 * (W4B-N21). */
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
            doc /* Trigger UNBOUND (W4B-N21): SEL_SENTINEL_DESIGN Rev B s.4.3
                 * step 5 gives the crew / Earth disposition (approve, modify,
                 * reject), but no document says it returns SENTINEL to its
                 * plan, nor to which mode; the step 6 loop may re-raise. The
                 * disposition itself is RespondToAnomaly in the workflow. */
        }
    }

    state def EarthContactStates {
        doc /* SENTINEL no-contact autonomous mode: Earth comms lost beyond the
             * no-contact threshold (24 hr in the source, UNBOUND here, rule 3)
             * -> all EXECUTE functions continue; GATE functions transfer to
             * the local crew from P4, and are SUSPENDED while there is no crew
             * (P2-P3: no departures, no heavy lifts, no reactor restarts);
             * production continues on the last schedule and every gate
             * request is queued for human review on restoration. Source:
             * SEL-SW-SENTINEL-001 Rev B s.12.2. Three wordings recorded, not
             * resolved (W4B-N26): SEL_SENTINEL_DESIGN Rev B s.3.7 carries the
             * same > 24 hr threshold but says only GATE functions (departure
             * approvals, structural clearance) are suspended until comms are
             * restored and that crew on site (P4+) can approve gates locally;
             * design s.9 (X-band link failure row) says GATE transfers to the
             * local crew with no threshold stated. The inContact wording is
             * design s.7 (P2-P3 and P4 rows). */
        attribute earthCommsLossHours : Real;
        attribute noContactThresholdHours : Real;
        attribute earthCommsLost : Boolean;
        entry; then inContact;
        state inContact {
            doc /* Earth link up; GATE functions held by Earth (P2-P3) or the
                 * local crew with Earth backup (P4+). */
        }
        state noContactAutonomous {
            doc /* EXECUTE continues; GATE to local crew (P4+) or suspended
                 * (P2-P3); gate requests queued. */
            do action queueGateRequestsForHumanReview;
        }
        transition commsLostBeyondThreshold
            first inContact
            if earthCommsLossHours > noContactThresholdHours
            then noContactAutonomous {
            doc /* "If Earth comms lost >24 hr" (s.12.2) - threshold UNBOUND. */
        }
        transition commsRestored
            first noContactAutonomous
            if not earthCommsLost
            then inContact {
            doc /* Queued gate requests go to human review on restoration. */
        }
    }

    action def DetectAnomaly {
        doc /* Step 1: a reading exceeds a threshold or trend analysis predicts
             * a breach within the look-ahead (SEL_SENTINEL_DESIGN Rev B s.4.3). */
        in item reading : SensorReading;
    }

    action def ClassifyAnomaly {
        doc /* Step 2: severity assignment (SEL_SENTINEL_DESIGN Rev B s.4.3). */
        out item classification : AnomalyClassification;
    }

    action def RespondToAnomaly {
        doc /* Step 5: the human disposition (SEL_SENTINEL_DESIGN Rev B s.4.3). */
        in item disposition : CrewDisposition;
    }

    action def VerifyAndCloseAnomaly {
        doc /* Step 6: re-inspect, confirm, close the ticket; escalate if the
             * anomaly persists (SEL_SENTINEL_DESIGN Rev B s.4.3). */
        out item closure : AnomalyTicketClosed;
    }

    action def AnomalyResponseWorkflow {
        doc /* The six-step SENTINEL anomaly workflow for every anomaly type:
             * detect (threshold or 24 hr trend prediction) -> classify
             * (AnomalySeverity) -> isolate (WARNING and EMERGENCY only:
             * pipeline valve closure, hatch closure, geofence expansion,
             * breaker trip - autonomous, no human approval) -> diagnose and
             * recommend (correlation against the fault pattern catalogue) ->
             * respond (crew / Earth disposition; EMERGENCY response has
             * already executed) -> verify and close (re-inspect, close the
             * ticket; if the anomaly persists, escalate one severity and
             * repeat from isolate - the loop is in the doc, not drawn). The
             * isolate step is a pass-through below WARNING. Times (30 s
             * valve, 10 s hatch, 24 hr corrective action) stay in the source
             * (rule 3). Source: SEL_SENTINEL_DESIGN Rev B s.4.3;
             * SEL-SW-SENTINEL-001 Rev B s.13 (fault patterns, correlation). */
        in item reading : SensorReading;
        out item classification : AnomalyClassification;
        out item closure : AnomalyTicketClosed;
        action detect : DetectAnomaly;
        action classify : ClassifyAnomaly;
        action isolate;
        action diagnoseAndRecommend;
        action respond : RespondToAnomaly;
        action verifyAndClose : VerifyAndCloseAnomaly;
        flow reading to detect.reading;
        flow classify.classification to classification;
        flow verifyAndClose.closure to closure;
        first start;
        succession start then detect;
        succession detect then classify;
        succession classify then isolate;
        succession isolate then diagnoseAndRecommend;
        succession diagnoseAndRecommend then respond;
        succession respond then verifyAndClose;
        succession verifyAndClose then done;
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
             * location machine; the PKT design principle and escalation tiers
             * below. Software spec: SEL-SW-SENTINEL-001 Rev B (docs/; s.2
             * partitions, s.15 PKT node architecture). Rover hardware is
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
        attribute pktSafetyCriticalDecisionsLocal : Boolean = true;
        attribute relaySatelliteInSafetyCriticalPath : Boolean = false;
        attribute pktEscalationTiers = (
            PktEscalationTier::t0Local, PktEscalationTier::t1Advisory,
            PktEscalationTier::t2Alert, PktEscalationTier::t3Emergency
        );
        port uplink : SupervisionPort;
        port spaHost : SupervisionPort;
        port pktSupervision : ~SupervisionPort;
        port fleetSupervision : ~SupervisionPort;
        exhibit state location : SupervisionLocation;
        assert constraint relayNeverInSafetyPath {
            doc /* SEL-SW-SENTINEL-001 Rev B s.15.2 design principle: any
                 * decision that must complete in under a second is handled in
                 * the local PKT node with hardwired actuator connections; the
                 * relay satellite is never in the critical path. */
            pktSafetyCriticalDecisionsLocal == true
                and relaySatelliteInSafetyCriticalPath == false
        }
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
             * Addendum (7 Nov 2026): the five authority levels, the SPA
             * EMERGENCY scope (fire, depressurisation, explosive H2 - the only
             * autonomous irreversible actions; design s.5) and the PKT
             * additions (design s.8.4), the anomaly workflow performed here and
             * the no-contact mode exhibited. Partition map, database schema,
             * control loops and the ~206 + ~150 fault patterns stay in the
             * source (SEL-SW-SENTINEL-001 Rev B s.2-s.13, s.15.4) as Wave 5
             * data. Source: SEL-SW-SENTINEL-001 Rev B; SEL_SENTINEL_DESIGN Rev
             * B s.4.3, s.5, s.8.4, s.9; ARCHITECTURE_BASELINE.md s.7; fleet v9
             * s.9.2. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "distributed across tiers";
        attribute supportedModes = (
            SupervisionMode::preProgrammedExecution,
            SupervisionMode::localAiWithinSafeParameters,
            SupervisionMode::exceptionFlaggingToHumans
        );
        attribute authorityLevels = (
            AuthorityLevel::monitor, AuthorityLevel::recommend,
            AuthorityLevel::execute, AuthorityLevel::gate, AuthorityLevel::emergency
        );
        attribute spaEmergencyScope = ("fire", "rapid depressurisation", "explosive H2 concentration");
        attribute pktEmergencyScopeAdds = ("MSR emergency shutdown", "conveyor emergency stop", "mass driver abort");
        attribute gateHasNoTimeout : Boolean = true;
        attribute earthCommsLossHours : Real;
        attribute noContactThresholdHours : Real;
        attribute earthCommsLost : Boolean;

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
        exhibit state earthContact : EarthContactStates {
            :>> earthCommsLossHours = earthCommsLossHours;
            :>> noContactThresholdHours = noContactThresholdHours;
            :>> earthCommsLost = earthCommsLost;
        }
        perform action anomalyWorkflow : AnomalyResponseWorkflow;
        allocate anomalyWorkflow.detect to edge;
        allocate anomalyWorkflow.classify to edge;
        allocate anomalyWorkflow.isolate to edge;
        allocate anomalyWorkflow.diagnoseAndRecommend to edge;
        allocate anomalyWorkflow.respond to earthOpsHub;
        allocate anomalyWorkflow.respond to edge;
        allocate anomalyWorkflow.verifyAndClose to edge;
        assert constraint gateNeedsHumanApproval {
            doc /* SEL_SENTINEL_DESIGN Rev B s.5: a GATE remains closed until
                 * approved - no timeout, SENTINEL cannot bypass it. */
            gateHasNoTimeout == true
        }
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
            accept AnomalyTicketClosed
            then open {
            doc /* Bound 7 Nov 2026: an alert that does not escalate clears when
                 * the anomaly workflow verifies it resolved and closes the
                 * ticket (step 6); until then the Ops Hub notification stands.
                 * The ECN-014 table itself gives no clearing condition.
                 * Source: SEL_SENTINEL_DESIGN Rev B s.4.3 step 6. */
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
            accept AnomalyTicketClosed
            then normal {
            doc /* Bound 7 Nov 2026: an EMERGENCY response has already executed;
                 * the crew assesses damage and plans recovery (step 5), and
                 * the function stands down when SENTINEL verifies the anomaly
                 * resolved and closes the ticket (step 6). Each station then
                 * still needs its own crew re-open. Source: SEL_SENTINEL_DESIGN
                 * Rev B s.4.3 steps 5-6; SEL-SW-SENTINEL-001 Rev B s.5
                 * (crew-directed recovery column). */
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
            accept AnomalyTicketClosed
            then open {
            doc /* Bound 7 Nov 2026: "until resolved" is the anomaly workflow's
                 * step 6 closure after the corrective action on the
                 * SENTINEL-triggered fail-closed isolation valve (ISRU-001 Rev
                 * D updated s.8.2 amendment). Source: SEL_SENTINEL_DESIGN Rev B
                 * s.4.3 step 6; SEL-ISRU-001 Rev D updated s.8.2. */
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
             * Source: ECN-014 extract in fleet v9 s.9.2; SEL-ISRU-001 Rev D
             * updated s.7.4 amendment (two catalytic sensors at 10 ppm, UV
             * flame detector, auto-close at 1,000 ppm H2 or UV flame or
             * pressure > 5 bar or comms loss > 60 s - the same figures);
             * updated_SEL-CAD-ISRU-001 ECN-014 amendment (station geometry).
             * The ECN-014 patterns are #201-#206 in the SEL-SW-SENTINEL-001
             * Rev B fault management system (s.13, "~200 patterns + 6 ECN-014
             * valve patterns", s.15.4). */
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
             * 10 Hz cryo / 1 Hz O2, 90-day retention in the source). The
             * ten-table schema it extends is SEL-SW-SENTINEL-001 Rev B s.4
             * (docs/); table contents are Wave 5 data. Source: ECN-014 extract,
             * fleet v9 s.9.2. */
        attribute tableOrdinal : Integer = 11;
    }

    part def FaultPatternCatalogue {
        doc /* Fault pattern library; ECN-014 adds patterns #201-#206 (H2 leak,
             * overpressure, UV flame, O2 overpressure, O2 high flow, comms
             * timeout), each a transition in the state machines above. The
             * full pattern table (~200 SPA patterns in six categories plus
             * the six ECN-014 patterns, ~150 PKT patterns, DAG correlation
             * engine with ~500 / ~300 causal edges) is SEL-SW-SENTINEL-001 Rev
             * B s.13 and s.15.4 (docs/); pattern counts are Wave 5 data.
             * Source: fleet v9 s.9.2; SEL-SW-SENTINEL-001 Rev B s.13. */
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

    action def ComputeTetherPolarFix {
        doc /* NAV-001 layer 1, computed ON THE SUBSTATION: range from the
             * drum payout encoder, bearing from the DRM-040 two-axis angle
             * encoder on the guide roller; the port allocation controller
             * calculates the polar fix for each MOLE-I, sends it down the
             * tether PLC and relays it to SENTINEL. Accuracies (range and
             * azimuth resolutions, the cross-track error growing with range)
             * stay in the source (rule 3). Degraded when the tether is slack;
             * the final docking approach uses the rear proximity sensors.
             * Corrected 7 Nov 2026 from the Wave 4B rover-side
             * ReadTetherPolarFix. Source: computation on the controller
             * SEL-ECN-013 s.3.2; transmission over the PLC SEL-SW-MOLEI-001
             * Rev D s.8.2 ECN-013 note; drum payout and roller encoders
             * SEL-NAV-001 Rev A s.2.1; encoder hardware SEL-SW-SUB-001 Rev C
             * ECN-013 addition. */
        in item payout : DrumPayoutReading;
        in item encoder : SubstationEncoderReading;
        out item fix : TetherFixReading;
    }

    action def ReceiveTetherPolarFix {
        doc /* The rover's end of layer 1: the navigation firmware receives the
             * polar fix (range + bearing) from the substation over the PLC.
             * Source: SEL-SW-MOLEI-001 Rev D ECN-013 note (s.8.2 firmware
             * addition); SEL-NAV-001 Rev A s.2.1. */
        in item fix : TetherFixReading;
        out item fixOut : TetherFixReading;
    }

    action def ReadWheelOdometry {
        doc /* NAV-001 layer 2: the six wheel encoders (fleet v9 s.4.1). */
        out item odometry : OdometryReading;
    }

    action def ReadImu {
        doc /* NAV-001 layer 3: the MEMS IMU inside the WEB (SEL-MI-NAV-001),
             * drift reset at each dock cycle (SEL-NAV-001 Rev A s.2.3; fleet
             * v9 s.4.1). */
        out item imu : ImuReading;
    }

    action def KalmanUpdate {
        doc /* The Kalman fusion step on the existing MOLE-I PLC (SEL-NAV-001
             * Rev A s.2.4: 10 Hz, +/- 0.5 m steady state - quoted not bound).
             * The filter's noise matrices are not stated in Rev A (verification
             * action 3 of SEL-ECN-013 s.6 is the simulation that would set
             * them). */
        in item fix : TetherFixReading;
        in item odometry : OdometryReading;
        in item imu : ImuReading;
        out item estimate : PositionEstimate;
    }

    action def UpdateDrillGrid {
        doc /* Mark the drilled cell (status, depth, yield, timestamp) in the
             * per-sector workspace grid in non-volatile flash; the grid is
             * uploaded to the substation over the PLC after each dump cycle
             * and relayed to SENTINEL (SEL-NAV-001 Rev A s.2.4, s.3; fleet v9
             * s.4.1). */
        in item estimate : PositionEstimate;
        out item update : DrillGridUpdate;
    }

    action def ConstructionNavigation {
        doc /* NAV-001 s.4 construction navigation: on a temporary 100 m tether
             * at the construction taps there is no polar fix; position is the
             * tap-point count along the branch plus the odometry offset from
             * the current tap, reported over the UHF link with power status
             * and construction gate requests (human approval for each
             * irreversible step). Source: SEL-NAV-001 Rev A s.4; SEL-ECN-013
             * s.5; SEL-CON-001 Rev B updated s.3.1 (taps every 100 m, power
             * only). */
        in item odometry : OdometryReading;
        out item estimate : PositionEstimate;
        out item gateRequest : ConstructionGateRequest;
        out item powerStatus : PowerStatusReport;
        attribute tapPointCount : Integer;
    }

    action def NavigationFusion {
        doc /* SEL-NAV-001 Rev A s.2.4 fusion as an action flow: the polar fix
             * (absolute, low rate, available only when the tether is taut)
             * arrives from the substation, odometry and IMU are read every
             * cycle, the filter fuses what it has - so the fix feeds the
             * filter by flow without a succession, and fusion runs on
             * odometry + IMU between fixes - and the estimate marks the drill
             * grid. The grid mark is per drill position (s.3.2), not per
             * filter cycle; the succession to markGrid is the data path, its
             * cadence is in the source. Rates and accuracies stay in the docs
             * (rule 3). Allocated in MoleINavigation to the sensing parts and
             * the Kalman filter on the PLC. */
        in item fix : TetherFixReading;
        out item estimate : PositionEstimate;
        out item gridUpdate : DrillGridUpdate;
        attribute fusionRateHz : Real;
        action tetherFix : ReceiveTetherPolarFix;
        action odometry : ReadWheelOdometry;
        action imu : ReadImu;
        action fuse : KalmanUpdate;
        action markGrid : UpdateDrillGrid;
        flow fix to tetherFix.fix;
        flow tetherFix.fixOut to fuse.fix;
        flow odometry.odometry to fuse.odometry;
        flow imu.imu to fuse.imu;
        flow fuse.estimate to estimate;
        flow fuse.estimate to markGrid.estimate;
        flow markGrid.update to gridUpdate;
        first start;
        succession start then tetherFix;
        succession start then odometry;
        succession start then imu;
        succession odometry then fuse;
        succession imu then fuse;
        succession fuse then markGrid;
        succession markGrid then done;
    }

    part def TetherPolarFix {
        doc /* NAV-001 layer 1 on the rover: the receiver of the polar fix the
             * substation computes from drum payout and the DRM-040 roller
             * encoder. Source: SEL-NAV-001 Rev A s.2.1; SEL-ECN-013 s.3;
             * fleet v9 s.4.1. */
    }

    part def WheelOdometry {
        doc /* NAV-001 layer 2: six wheel encoders and six steering sensors
             * (existing hardware; 2-5 % drift quoted). Source: SEL-NAV-001 Rev
             * A s.2.2; fleet v9 s.4.1. */
    }

    part def MemsImu {
        doc /* NAV-001 layer 3: MEMS 6-DOF IMU inside the WEB (SEL-MI-NAV-001,
             * SPI to the PLC), reset at each dock cycle. Source: SEL-NAV-001
             * Rev A s.2.3; SEL-ECN-013 s.3.1; fleet v9 s.4.1. */
    }

    part def KalmanFusion {
        doc /* NAV-001 fusion filter on the existing MOLE-I PLC (firmware,
             * no hardware addition); performs the KalmanUpdate step of
             * NavigationFusion. Source: SEL-NAV-001 Rev A s.2.4; SEL-SW-MOLEI-
             * 001 Rev D ECN-013 note; fleet v9 s.4.1. */
    }

    part def DrillGridMap {
        doc /* NAV-001 workspace drill grid per sector (polar grid of radial x
             * angular bins) in non-volatile flash; enables gap-free lawn-mower
             * drilling over the service life; uploaded to the substation after
             * each dump and relayed to SENTINEL. Cell count (3,600 per sector)
             * is a Wave 5 value. Source: SEL-NAV-001 Rev A s.2.4, s.3; fleet
             * v9 s.4.1. */
    }

    part def UhfConstructionLink {
        doc /* The rover's 20 W UHF radio (SEL-MI-COM-001) as the primary comms
             * path during construction on temporary tethers, to the nearest
             * substation or spine junction relay and on to SENTINEL; carries
             * position reports, power status and construction gate requests
             * (NAV-001 s.4), not the polar fix. Source: SEL-ECN-013 s.5;
             * SEL-NAV-001 Rev A s.4; ARCHITECTURE_BASELINE.md s.7. */
        port radio : ~ConstructionRadioPort;
    }

    part def MoleINavigation :> SoftwareElement {
        doc /* SEL-NAV-001 Rev A: three-layer MOLE-I navigation (tether polar
             * fix + wheel odometry + IMU, Kalman-fused) with the drill grid
             * map and UHF construction link. Structural subsystem of MOLE-I
             * (see SeleniteFleet::MoleI). Wave 4B: performs NavigationFusion,
             * allocated to its parts. Addendum (7 Nov 2026): the polar fix
             * arrives over the tether only (computed by the substation
             * controller, ECN-013 s.3.2); during construction the rover
             * navigates by tap count plus odometry (ConstructionNavigation)
             * and reports position over the UHF link (NAV-001 s.4) - the
             * Wave 4B "encoder over UHF" flow was not in the source and is
             * removed. */
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
        perform action navigateDuringConstruction : ConstructionNavigation;
        allocate navigate.tetherFix to tetherFix;
        allocate navigate.odometry to odometry;
        allocate navigate.imu to imu;
        allocate navigate.fuse to fusion;
        allocate navigate.markGrid to drillGrid;
        allocate navigateDuringConstruction to odometry;
        flow tetherData.fix to navigate.fix;
        flow navigate.odometry.odometry to navigateDuringConstruction.odometry;
        flow navigateDuringConstruction.estimate to constructionLink.radio.positionReport;
        flow navigateDuringConstruction.gateRequest to constructionLink.radio.gateRequest;
        flow navigateDuringConstruction.powerStatus to constructionLink.radio.powerStatus;
    }

    // =====================================================================
    // MOLE-I flight software and the substation controller
    // =====================================================================

    state def MoleIOperatingStates {
        doc /* MOLE-I operating states from the sources now in docs/: standby
             * on WEB keep-alive; battery transit; the construction role the
             * first unit on each branch takes before permanent drilling
             * (SEL_MOLEI_DESIGN v5 s.8; SEL-CON-001 Rev B updated s.3);
             * drilling at a grid cell; and the ECN-012 dump cycle as its own
             * states - pre-heat (drilling continues, drain pipe heater on from
             * the pre-heat tank fraction), retraction to the substation with
             * the heater on, the dump once docked, and the purge after the
             * drain valve closes (SEL-ECN-012 s.3.3.2 steps 1-5; SEL-ISRU-001
             * Rev D updated s.6.1 step F). Triggers bound where the source
             * states them; the fractions, the purge hold and the cell target
             * depth (90 %, full, 3 min, 400 mm) stay UNBOUND attributes of the
             * exhibiting software (rule 3). The cell is left when the drill
             * has excavated to its target depth (SEL-NAV-001 Rev A s.3.2: "to
             * depth ... retracts the drill, advances 2 m to the next
             * position"; the per-cell depth field is s.3.1) - W4B-N22 is
             * therefore bound; the lateral offset on unexpected drill
             * resistance (s.2.2) has no stated criterion and stays UNBOUND.
             * Pre-heat is not a pause: ECN-012 step 1 and ISRU-001 step D say
             * drilling continues, so the cell advance is also modelled from
             * preHeat (W4B-N24 records ECN-012 s.3.3.3's contrary "heater only
             * runs during non-drilling phases"). Safe-park is the SENTINEL
             * fault response for a robot (SEL-SW-SENTINEL-001 Rev B s.13.1);
             * task assignment is the fleet scheduler's per-robot output
             * (s.9.1); the construction role is an ordinal rule (the branch's
             * first unit), not a command, so its trigger is UNBOUND. */
        attribute tankFillFraction : Real;
        attribute preHeatTankFraction : Real;
        attribute tankFullFraction : Real;
        attribute purgeElapsedMinutes : Real;
        attribute purgeHoldMinutes : Real;
        attribute cellDrillDepthMm : Real;
        attribute cellTargetDepthMm : Real;
        attribute drainValveClosed : Boolean;
        attribute drainPipeHeaterOn : Boolean;
        attribute atSelectedCell : Boolean;
        attribute taskAssigned : Boolean;
        attribute branchBuildOutComplete : Boolean;
        attribute safeParkCommanded : Boolean;
        entry; then standby;
        state standby {
            doc /* WEB keep-alive only (the WEB heater never switches off -
                 * SEL_MOLEI_DESIGN v5 s.4.1). */
        }
        state transit {
            doc /* Battery transit: CLP to the assigned substation, or between
                 * cells with the tether paid out (SEL_MOLEI_DESIGN v5 s.4.6,
                 * s.8). */
        }
        state construction {
            doc /* The branch's first unit as construction unit: cable / pipe
                 * pulling, stake driving, mast tilt-up, substation towing, on
                 * temporary tethers at the construction taps (SEL-CON-001 Rev B
                 * updated s.3; ConstructionTapHop). */
        }
        state drilling {
            doc /* Rotary-percussive drill and mini-VEX at a grid cell
                 * (lawn-mower order over the sector grid, SEL-NAV-001 Rev A
                 * s.3.1-3.2). */
        }
        state preHeat {
            doc /* ECN-012 step 1: drain pipe trace heater on (drainPipeHeaterOn
                 * true from here to the end of the purge); drilling continues
                 * for the final fill, cell advances included. */
            entry action switchDrainPipeHeaterOn;
        }
        state retracting {
            doc /* ECN-012 step 2: reverse toward the substation, drum reels
                 * in, heater stays on. */
        }
        state dumping {
            doc /* ECN-012 step 3: docked, drain valve open, gravity dump into
                 * the funnel. NAV-001 s.2.3: the IMU heading is reset to the
                 * polar-derived heading at each dock cycle (the correction
                 * itself starts on retraction when the tether goes taut -
                 * placed on dock entry here, the retraction reading recorded);
                 * s.3.1: the grid is uploaded to the substation over the PLC
                 * after each dump cycle ("fits within the 15-min dump window"
                 * - both phrasings recorded; modelled as the exit action). */
            entry action resetImuAtDock;
            entry action openDrainValve;
            exit action uploadDrillGridToSubstation;
        }
        state purging {
            doc /* ECN-012 step 4 / ISRU-001 step F: heater holds after the
                 * valve closes until the pipe is clear, then off; no level
                 * feedback - the hold time is deterministic. */
            exit action switchDrainPipeHeaterOff;
        }
        transition leaveStandby
            first standby
            accept SupervisionCommand
            if taskAssigned
            then transit {
            doc /* Fleet scheduler task assignment (task id, waypoints) received
                 * in the rover's TDMA slot. Source: SEL-SW-SENTINEL-001 Rev B
                 * s.9.1; SEL_MOLEI_DESIGN v5 s.8 (transit to the assigned
                 * substation). */
        }
        transition takeConstructionRole
            first transit
            then construction {
            doc /* Trigger UNBOUND: the sources give an ordinal rule, not a
                 * command - "The first MOLE-I on each branch doubles as the
                 * construction unit" (SEL_MOLEI_DESIGN v5 s.8; SEL-CON-001 Rev B
                 * updated s.3), and at P4+ a unit is "temporarily borrowed
                 * from drilling" (SEL-CON-001 s.7); no document names who or
                 * what commands the role (SW-SENTINEL s.9.1 lists no MOLE-I
                 * construction task). */
        }
        transition constructionDone
            first construction
            if branchBuildOutComplete
            then transit {
            doc /* "... before transitioning to permanent drilling operations"
                 * (SEL_MOLEI_DESIGN v5 s.8); the branch gates of SEL-CON-001
                 * Rev B updated s.6 (GATE 2 substation installed, GATE 3 fleet
                 * operational) are the human approvals on the way. */
        }
        transition arriveAtCell
            first transit
            accept PositionEstimate
            if atSelectedCell and not drainPipeHeaterOn
            then drilling {
            doc /* The fused estimate places the rover at the next undrilled
                 * cell of the lawn-mower sequence (SEL-NAV-001 Rev A s.3.2). */
        }
        transition arriveAtCellPreHeating
            first transit
            accept PositionEstimate
            if atSelectedCell and drainPipeHeaterOn
            then preHeat {
            doc /* The same arrival rule while the ECN-012 pre-heat is running
                 * (drilling continues through the final fill, step 1). */
        }
        transition moveOnPreHeating
            first preHeat
            if cellDrillDepthMm >= cellTargetDepthMm
            then transit {
            doc /* The cell-complete rule of moveOn during pre-heat: ECN-012
                 * step 1 "continues drilling for final ~4.5 hours of fill" and
                 * NAV-001 s.3.2 (~1 hour per position) mean cells are advanced
                 * while the heater is on. */
        }
        transition tankAtPreHeatFraction
            first drilling
            if tankFillFraction >= preHeatTankFraction
            then preHeat {
            doc /* ECN-012 step 1: "tank level >= 90 %" (fraction UNBOUND). */
        }
        transition tankFull
            first preHeat
            if tankFillFraction >= tankFullFraction
            then retracting {
            doc /* ECN-012 step 2: "tank full" (fraction UNBOUND). */
        }
        transition dockedAtSubstation
            first retracting
            accept d : DockingState
            if d.docked
            then dumping {
            doc /* ECN-012 step 3: "docked at substation"; the final approach is
                 * on the rear proximity sensors (SEL-NAV-001 Rev A s.2.1). */
        }
        transition drainValveCloses
            first dumping
            if drainValveClosed
            then purging {
            doc /* ECN-012 step 4: "drain valve closes". */
        }
        transition purgeComplete
            first purging
            if purgeElapsedMinutes >= purgeHoldMinutes
            then transit {
            doc /* ECN-012 step 5: after the hold the pipe is clear and the
                 * rover drives forward to resume drilling (hold UNBOUND, 3 min
                 * quoted). */
        }
        transition moveOn
            first drilling
            if cellDrillDepthMm >= cellTargetDepthMm
            then transit {
            doc /* SEL-NAV-001 Rev A s.3.2: "excavates to depth (400 mm
                 * extension ...), retracts the drill, advances 2 m to the next
                 * position" - the target depth is UNBOUND (400 mm quoted; the
                 * Mk I bit extension of SEL_MOLEI_DESIGN v5 s.4.3). */
        }
        transition offsetOnResistance
            first drilling
            then transit {
            doc /* Trigger UNBOUND: SEL-NAV-001 Rev A s.2.2 "if the drill
                 * encounters unexpected resistance, the rover reverses and
                 * offsets laterally" - the resistance criterion is not given. */
        }
        transition safePark
            first transit
            accept SupervisionCommand
            if safeParkCommanded
            then standby {
            doc /* SENTINEL robot-fleet fault response "EXECUTE: safe-park the
                 * robot" (SEL-SW-SENTINEL-001 Rev B s.13.1); a dead unit sits
                 * in place and the substation retracts its tether
                 * (SEL_MOLEI_DESIGN v5 s.9 Tier 1). */
        }
    }

    state def MoleICommsStates {
        doc /* ECN-013 Change C: the WEB avionics switch comms by tether
             * connection type - permanent drum port = power-line carrier,
             * construction tap = UHF (no PLC handshake on a temporary tether);
             * untethered transit is also on the UHF backup (SEL_MOLEI_DESIGN
             * v5 s.4.8). Source: SEL-ECN-013 s.5; SEL_MOLEI_DESIGN v5 s.4.7-
             * 4.8. */
        abstract attribute tetherConnection : TetherConnectionType;
        entry; then powerLineCarrier;
        state powerLineCarrier {
            doc /* PLC on the permanent tether: dump coordination and telemetry
                 * (SEL_MOLEI_DESIGN v5 s.4.7), the polar fix (SEL-SW-MOLEI-001
                 * Rev D s.8.2 ECN-013 note), the grid upload (NAV-001 s.3.1). */
        }
        state uhfRadio {
            doc /* 20 W UHF to the substation relay mesh and on to SENTINEL. */
        }
        transition toUhf
            first powerLineCarrier
            if tetherConnection != TetherConnectionType::permanentDrumPort
            then uhfRadio {
            doc /* ECN-013 s.5: the avionics "automatically switches comms from
                 * PLC mode to UHF mode" when the rover unplugs from the drum
                 * port and plugs into a construction tap; the untethered leg
                 * is SEL_MOLEI_DESIGN v5 s.4.8 "RF relay for off-tether
                 * situations (transit, construction work with temporary
                 * tether)" - the sources do not say that leg is automatic. The
                 * start-up mode is in no source; powerLineCarrier is the
                 * modelling default and this guard corrects it on entry. */
        }
        transition backToPlc
            first uhfRadio
            if tetherConnection == TetherConnectionType::permanentDrumPort
            then powerLineCarrier {
            doc /* "On return to the permanent tether, it switches back to PLC." */
        }
    }

    state def BayonetEngagementStates {
        doc /* The motorised bayonet adapter SEL-MI-CON-001 in a tap socket:
             * push-and-twist engage by the DC motor, passive detent hold with
             * zero power, motor again to disengage. The 0.5 s cycle and 2 W
             * stay in the source (rule 3). Source: SEL-CON-001 Rev B updated
             * (ECN-013 Rev 2 "Construction MOLE-I interface"); SEL_MOLEI_DESIGN
             * v5 ECN-013 Rev 2. */
        attribute engageCommanded : Boolean;
        attribute disengageCommanded : Boolean;
        entry; then disengaged;
        state disengaged {
            doc /* Plug clear of the socket. */
        }
        state engaged {
            doc /* Twist-locked; detent holds without power; power flows on
                 * the BayonetCoupling. */
        }
        transition engage
            first disengaged
            if engageCommanded
            then engaged {
            doc /* Push-and-twist by the DC motor. On the socket side SEL-SW-
                 * SUB-001 Rev C s.6 states make-before-break ("solenoid closes
                 * AFTER connector fully seated") for the branch connector and
                 * "same spec" for the construction tap; whether the tap's
                 * supply follows that protocol is not stated. */
        }
        transition disengage
            first engaged
            if disengageCommanded
            then disengaged {
            doc /* Motor reverses the twist; the spool retracts the tether
                 * (SEL-CON-001 Rev B updated, ECN-013 Rev 3 step 5). */
        }
    }

    action def ConstructionTapHop {
        doc /* SEL-CON-001 Rev B updated, ECN-013 Rev 3 operational sequence:
             * (2) the construction MOLE-I arrives at a tap and engages the
             * bayonet plug via the motorised adapter; (3)-(4) it works the 100
             * m section while the spring spool pays out and retracts the
             * tether; (5) when the section is complete it disengages and
             * drives to the next tap on battery; the spool retracts the
             * tether. Comms are UHF throughout (MoleICommsStates). Hop energy
             * and spool tension stay in the source (rule 3). */
        action arriveAtTap;
        action engagePlug;
        action workSection;
        action disengagePlug;
        action hopOnBatteryToNextTap;
        first start;
        succession start then arriveAtTap;
        succession arriveAtTap then engagePlug;
        succession engagePlug then workSection;
        succession workSection then disengagePlug;
        succession disengagePlug then hopOnBatteryToNextTap;
        succession hopOnBatteryToNextTap then done;
    }

    part def MoleIFlightSoftware :> SoftwareElement {
        doc /* SEL-SW-MOLEI-001 Rev D is the SolidWorks modelling sequence for
             * the rover (its software content is the firmware notes: pipe
             * heater relay at the tank threshold, Kalman filter and PLC fix
             * receipt, bayonet adapter drive). The on-board behaviour comes
             * from SEL-ECN-012, SEL-ECN-013, SEL_MOLEI_DESIGN v5 and SEL-NAV-
             * 001 Rev A: exhibits MoleIOperatingStates and MoleICommsStates,
             * performs the navigation through its subsystem and the
             * construction tap hop. Source: SEL-SW-MOLEI-001 Rev D s.8.2 and
             * ECN-013 notes; SEL-ECN-012 s.3.3; SEL-ECN-013 s.5; SEL_MOLEI_
             * DESIGN v5 s.4.7-4.8, s.8-9; fleet v9 s.4.1. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "MOLE-I PLC inside WEB";
        part navigation : MoleINavigation;
        attribute tankFillFraction : Real;
        attribute preHeatTankFraction : Real;
        attribute tankFullFraction : Real;
        attribute purgeElapsedMinutes : Real;
        attribute purgeHoldMinutes : Real;
        attribute drainValveClosed : Boolean;
        attribute atSelectedCell : Boolean;
        attribute cellDrillDepthMm : Real;
        attribute cellTargetDepthMm : Real;
        attribute drainPipeHeaterOn : Boolean;
        attribute taskAssigned : Boolean;
        attribute branchBuildOutComplete : Boolean;
        attribute safeParkCommanded : Boolean;
        abstract attribute tetherConnection : TetherConnectionType;
        attribute plcAvailableOffPermanentTether : Boolean = false;
        port supervision : SupervisionPort;
        exhibit state operatingState : MoleIOperatingStates {
            :>> tankFillFraction = tankFillFraction;
            :>> preHeatTankFraction = preHeatTankFraction;
            :>> tankFullFraction = tankFullFraction;
            :>> purgeElapsedMinutes = purgeElapsedMinutes;
            :>> purgeHoldMinutes = purgeHoldMinutes;
            :>> drainValveClosed = drainValveClosed;
            :>> atSelectedCell = atSelectedCell;
            :>> cellDrillDepthMm = cellDrillDepthMm;
            :>> cellTargetDepthMm = cellTargetDepthMm;
            :>> drainPipeHeaterOn = drainPipeHeaterOn;
            :>> taskAssigned = taskAssigned;
            :>> branchBuildOutComplete = branchBuildOutComplete;
            :>> safeParkCommanded = safeParkCommanded;
        }
        exhibit state commsState : MoleICommsStates {
            :>> tetherConnection = tetherConnection;
        }
        perform action constructionTapHop : ConstructionTapHop;
        assert constraint plcOnlyOnPermanentTether {
            doc /* ECN-013 s.5: "PLC comms are unavailable on temporary
                 * construction tethers."; SEL_MOLEI_DESIGN v5 ECN-013 Rev 3:
                 * "PLC is NOT available on construction tethers". The
                 * switchover itself is MoleICommsStates. */
            plcAvailableOffPermanentTether == false
        }
    }

    state def TetherPortStates {
        doc /* One substation tether port under the port allocation controller
             * (SEL-SW-SUB-001 Rev C s.6 "Normally open; close on command from
             * port allocation controller. Fail-safe: power loss = breaker
             * opens", s.7.2 "Allocates power to tether ports based on MOLE-I
             * docking status"; SEL-NAV-001 Rev A s.3.3 "the port allocation
             * controller holds that unit until the path is clear"). The
             * MOLE-I drum tether is permanent (SEL_MOLEI_DESIGN v5 s.1, s.4.7),
             * so the port is not plugged by a dump docking: the breaker closes
             * on the controller's allocation command and opens on power loss
             * or when the tether is retracted (a dead unit, MOLEI v5 s.9 Tier
             * 1 - the opening event is not stated, UNBOUND). The
             * make-before-break protocol of s.6 is on the Branch connector
             * row (the substation's own bayonet input socket), not the port
             * breakers - which connector the port breakers wait on is not
             * stated (W4B-N25, recorded). The source does not say the s.3.3
             * hold acts through the port breaker; it is placed here for want
             * of a stated location (recorded). */
        attribute allocationGranted : Boolean;
        attribute busPowerLost : Boolean;
        attribute tetherPathsWouldCross : Boolean;
        entry; then breakerOpen;
        state breakerOpen {
            doc /* Normally open: port unallocated, tether retracted, or power
                 * lost. */
        }
        state energised {
            doc /* Breaker closed; 1,000 VDC on the tether; PLC up. */
        }
        state held {
            doc /* Energised but the advancing unit is held until the path is
                 * clear (NAV-001 s.3.3); SENTINEL monitors fleet-wide, the
                 * port allocation controller applies the hold. */
        }
        transition energise
            first breakerOpen
            if allocationGranted
            then energised {
            doc /* "Close on command from port allocation controller" (SEL-SW-
                 * SUB-001 Rev C s.6), by docking status (s.7.2). */
        }
        transition holdForCrossing
            first energised
            if tetherPathsWouldCross
            then held {
            doc /* NAV-001 s.3.3 port allocation: hold the unit if the tether
                 * paths would cross. */
        }
        transition releaseHold
            first held
            if not tetherPathsWouldCross
            then energised {
            doc /* Conflict cleared. */
        }
        transition tetherRetracted
            first energised
            then breakerOpen {
            doc /* Trigger UNBOUND: s.7.2 "based on MOLE-I docking status" does
                 * not define the opening event; SEL_MOLEI_DESIGN v5 s.9 Tier 1
                 * says only "Sub-station retracts tether". */
        }
        transition powerLossOpens
            first energised
            if busPowerLost
            then breakerOpen {
            doc /* "Fail-safe: power loss = breaker opens" (SEL-SW-SUB-001 Rev C
                 * s.6). */
        }
        transition powerLossOpensHeld
            first held
            if busPowerLost
            then breakerOpen {
            doc /* The same fail-safe from the held state. */
        }
    }

    part def SubstationController :> SoftwareElement {
        doc /* SEL-SW-SUB-001 Rev C: the substation WEB port allocation
             * controller (PLC-based) - allocates power to tether ports by
             * docking status through the normally-open solenoid breakers
             * (s.6, s.7.2), coordinates the MOLE-I dump cycles and relays
             * telemetry over the PLC modem on each tether (s.9), reads the
             * DRM-040 angle encoders and computes the polar fix for each
             * MOLE-I (ECN-013 addition; SEL-ECN-013 s.3.2), holds a unit whose
             * tether path would cross another's (SEL-NAV-001 Rev A s.3.3) and
             * uplinks over the UHF relay to adjacent nodes and the spine (s.9).
             * Addendum (7 Nov 2026): exhibits TetherPortStates and performs
             * ComputeTetherPolarFix; the drum tension loop, WEB thermostat and
             * transfer pump are hardware control loops and stay in the source.
             * Source: SEL-SW-SUB-001 Rev C s.6, s.7.2, s.9 and ECN-013
             * additions; SEL-NAV-001 Rev A s.3.3; fleet v9 s.13.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines hostedOn = "substation WEB PLC";
        attribute allocationGranted : Boolean;
        attribute busPowerLost : Boolean;
        attribute tetherPathsWouldCross : Boolean;
        attribute breakersNormallyOpen : Boolean = true;
        attribute breakerOpensOnPowerLoss : Boolean = true;
        attribute branchConnectorMakeBeforeBreak : Boolean = true;
        port supervision : SupervisionPort;
        port constructionRadio : ConstructionRadioPort;
        port drumSensing : ~DrumSensingPort;
        port tetherOut : TetherPort;
        perform action computeFix : ComputeTetherPolarFix;
        flow drumSensing.payout to computeFix.payout;
        flow drumSensing.encoder to computeFix.encoder;
        flow computeFix.fix to tetherOut.fix;
        exhibit state portState : TetherPortStates {
            :>> allocationGranted = allocationGranted;
            :>> busPowerLost = busPowerLost;
            :>> tetherPathsWouldCross = tetherPathsWouldCross;
        }
        assert constraint breakerFailSafe {
            doc /* SEL-SW-SUB-001 Rev C s.6, Breakers row: "Normally open; close
                 * on command from port allocation controller. Fail-safe: power
                 * loss = breaker opens."; Branch connector row: "Make-before-
                 * break protocol (solenoid closes AFTER connector fully
                 * seated)". */
            breakersNormallyOpen == true
                and breakerOpensOnPowerLoss == true
                and branchConnectorMakeBeforeBreak == true
        }
    }

    // =====================================================================
    // CAP mission sequence (SEL-CAP-001 Rev A updated; EVA contingency)
    // =====================================================================

    state def CapMissionStates {
        doc /* The Crater Access Pod mission as SEL-CAP-001 Rev A updated s.2
             * states it: pre-descent at the rim (seal, life support, comms,
             * suits stowed, SPE forecast clear; GATE go / no-go from mission
             * control), descent on the dedicated guide cable, docking at the
             * floor pad adjacent to the SATS / CLP (trunk power tap), floor
             * operations in 40 K-rated suits with the pod as shelter under a
             * hard work limit, ingress, ascent. The standing abort protocol
             * of the corrected EVA contingency s.4.8 ascends immediately on
             * any SPE forecast from any state below the rim. The work limit
             * (2 h design target), speeds and times stay in the source (rule
             * 3). Source: SEL-CAP-001 Rev A updated s.2-3; SEL_EVA_CONTINGENCY
             * corrected s.4.5-4.8, s.5; fleet v9 s.13.5. */
        attribute floorWorkLimitHours : Real;
        attribute floorWorkElapsedHours : Real;
        attribute goForDescent : Boolean;
        attribute ingressComplete : Boolean;
        entry; then atRim;
        state atRim {
            doc /* Pre-descent checks and the mission-control GATE. */
        }
        state descending {
            doc /* On the guide cable; crew in IVA suits; UHF to the surface. */
        }
        state dockedAtFloor {
            doc /* Docked at the floor pad, on trunk power; suit donning. */
        }
        state floorOps {
            doc /* Crew outside in 40 K-rated suits; pod pressurised as
                 * shelter and abort refuge. */
        }
        state ascending {
            doc /* Return transit; also the abort state. */
        }
        transition goNoGo
            first atRim
            accept GatePassed
            if goForDescent
            then descending {
            doc /* "GATE: Go / No-Go from mission control" after the SPE
                 * forecast check (SEL-CAP-001 s.2 pre-descent). A mission
                 * gate, not a decision gate of SeleniteGates. */
        }
        transition dockAtFloor
            first descending
            accept d : DockingState
            if d.docked
            then dockedAtFloor {
            doc /* "CAP docks at floor station" (s.2 arrival). */
        }
        transition egress
            first dockedAtFloor
            then floorOps {
            doc /* Suits donned inside the pod; egress through the EVA hatch
                 * (s.2 arrival / floor ops). */
        }
        transition ingress
            first floorOps
            if ingressComplete
            then ascending {
            doc /* Crew back in the pod, suits doffed, equipment stowed, then
                 * ascent (s.2 ingress / ascent). */
        }
        transition workLimitReached
            first floorOps
            if floorWorkElapsedHours >= floorWorkLimitHours
            then ascending {
            doc /* "2-hour hard limit (xEMU thermal design point)" - a design
                 * target, not a tested result (EVA contingency s.2.1); limit
                 * UNBOUND. */
        }
        transition speAbortDescending
            first descending
            accept SpeForecast
            then ascending {
            doc /* Standing abort protocol: immediate ascent on any SPE forecast
                 * (EVA contingency corrected s.4.8). */
        }
        transition speAbortDocked
            first dockedAtFloor
            accept SpeForecast
            then ascending {
            doc /* The same abort from the floor pad. */
        }
        transition speAbortFloorOps
            first floorOps
            accept SpeForecast
            then ascending {
            doc /* The same abort during floor operations (crew retreat to the
                 * pod, then ascent). */
        }
        transition backAtRim
            first ascending
            then atRim {
            doc /* Arrival at the rim station. */
        }
    }
}
