package SeleniteFleet {
    doc /* Robot fleet: every class in ARCHITECTURE_BASELINE.md s.3 with
         * introducedIn, retiredIn, homeSite and the hard allocation rules as
         * asserted constraints. Integrated authority: SEL_ROBOT_FLEET_v9.md
         * (see CHANGELOG_WAVE2.md F2: the file named v9-1.docx is an earlier,
         * shorter v9.0 draft without ECN-020 and is NOT the winner). Rev A/B
         * vehicle specs are manufacturing-level sources per class.
         * Quantities (mass, power, per-phase counts) arrive from the Python
         * layer at Wave 5; dryMass/peakPower remain unbound declarations.
         * Fleet-scale counts stay configuration attributes, not part
         * multiplicities. */

    private import ISQ::*;
    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;
    private import SeleniteSoftware::*;
    private import SI::*;

    abstract part def FleetAsset :> PhaseGated {
        doc /* Base for every fleet class. homeSite may list two sites for
             * classes fielded at both (SINTER, ARM-C, SENTINEL); pktFrom on
             * those gives the phase their PKT complement begins.
             * canEnterPsr defaults false: only cryogenically hardened classes
             * (MOLE-I) and the CAP may go below the rim. */
        abstract attribute homeSite : SiteId [1..*];
        attribute canEnterPsr : Boolean = false;
        attribute countedInOperationalFleet : Boolean = true;
    }

    abstract part def SurfaceRobot :> FleetAsset {
        doc /* Lunar surface or PSR rover. */
        attribute dryMass :> ISQ::mass;
        attribute peakPower :> ISQ::power;
    }

    abstract part def Spacecraft :> FleetAsset {
        doc /* Orbital or interplanetary vehicle. */
        attribute dryMass :> ISQ::mass;
    }

    // ---- PROBE family --------------------------------------------------

    part def ProbeScout :> Spacecraft {
        doc /* PROBE-Scout: one-way expendable NEA survey and XRF confirmation,
             * Earth-fuelled, dispatched P1 as secondary payloads; stays at the
             * target. Not counted in the operational fleet.
             * Source: fleet v9 s.2.1; SEL_PROBE_DESIGN_RevB. */
        attribute redefines introducedIn = Phase::P1;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::cislunar;
        attribute redefines countedInOperationalFleet = false;
        attribute expendable : Boolean = true;
    }

    part def ProbeMkI :> Spacecraft {
        doc /* PROBE Mk I chemical LH2/LOX return vehicle (RL-10C class), lands
             * at the SPA IZ. Three Earth-fuelled units at P3, ISRU-fuelled from
             * P4; fleet peaks P8 and phases to zero during P11 as Mk II/III
             * take over (fleet v9 s.2.2, s.20.1). Based permanently at SPA
             * (propellant constraint). Source: fleet v9 s.2.2,
             * SEL_PROBE_DESIGN_RevB. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = Phase::P11;
        attribute redefines homeSite = SiteId::spa;
        attribute isruFuelledFrom = Phase::P4;
        attribute peakFleetIn = Phase::P8;
    }

    part def ProbeMkII :> Spacecraft {
        doc /* PROBE Mk II Heavy: on-asteroid beneficiation (magnetic drum +
             * centrifuge), chemical propulsion, lands at IZ. P9 introduction,
             * peak P11, residual specialist fleet retained to steady state.
             * Source: fleet v9 s.2.3, SEL-PROBE-MkII-001 Rev A. */
        attribute redefines introducedIn = Phase::P9;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::spa;
        attribute peakFleetIn = Phase::P11;
    }

    part def ProbeMkIII :> Spacecraft {
        doc /* PROBE Mk III SEP ion bulk miner (DG-11.6): never lands, zero ISRU
             * propellant, electromagnetic anchoring on M-type surfaces, ejects
             * Fe-Ni/PGM canisters from LLO to the SPA EM catcher. Peak fleet
             * P11-P12; prospecting role after all captures complete (P13+).
             * Source: fleet v9 s.2.4, SEL-PROBE-MkIII-001 Rev A. */
        attribute redefines introducedIn = Phase::P11;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::cislunar;
        attribute neverLands : Boolean = true;
        attribute usesIsruPropellant : Boolean = false;
        attribute prospectingRoleFrom = Phase::P13;
        assert constraint mkIiiNeverLands {
            doc /* Committed by ECN-019 Rev C / DG-11.6. */
            neverLands == true and usesIsruPropellant == false
        }
    }

    part def Survey :> SurfaceRobot {
        doc /* SURVEY geological prospector: one surface unit from P1 (SPA Basin
             * KREEP mapping) and a polar-LLO orbital unit from P5 (PKT target
             * ranking for DART). Source: fleet v9 s.6,
             * SEL_SURVEY_DESIGN_RevA_updated. */
        attribute redefines introducedIn = Phase::P1;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::spa;
        attribute orbitalUnitFrom = Phase::P5;
    }

    // ---- MOLE family ---------------------------------------------------

    part def MoleI :> SurfaceRobot {
        doc /* MOLE-I PSR ice extraction rover: tethered, permanent PSR
             * residence (never retrieved), WEB warm electronics box, integrated
             * mini-VEX, NAV-001 navigation (ECN-013), rear drain nozzle
             * (ECN-012), motorised bayonet adapter (CON-001). Fleet size is the
             * binding design variable and demand-driven.
             * FLAG F4 / VC-07 (recorded, not resolved): peak and decline -
             * "~355 at P12" (HAULER_SPEC_UPDATE_BRIEF, scope material-flow) vs
             * "320 -> ~50 during P11" (scope P11, fleet v9 s.4.3) vs ECON v1.3
             * "357 at Y35 (P8/P9), decline Y60-Y80, 53 from Y100". No numeric
             * attribute is bound; the Wave 5 vector settles it.
             * Source: SEL_MOLEI_DESIGN_v5 (+ECN-012/013), fleet v9 s.4.1. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::psrFloor;
        attribute redefines canEnterPsr = true;
        attribute permanentPsrResidence : Boolean = true;
        part flightSoftware : MoleIFlightSoftware;
    }

    part def MoleIMkI :> MoleI {
        doc /* MOLE-I Mk I: rotary-percussive 800 mm drill. Ten units lowered
             * at P3. Superseded by the Mk II drill retrofit: ARCHITECTURE_
             * BASELINE.md s.3 says "Mk II retrofit from P7"; fleet v9 s.4.2
             * says rollover P8-P9 with full fleet Mk II by end P9. Both
             * recorded (new observation W2-N1 in CHANGELOG_WAVE2.md);
             * retiredIn follows fleet v9 (last Mk I drill leaves in P9). */
        attribute redefines retiredIn = Phase::P9;
        attribute retrofitToMkIIFrom = Phase::P7;
    }

    part def MoleIMkII :> MoleI {
        doc /* MOLE-I Mk II: field retrofit of the Mk I chassis with a
             * telescoping three-section 5 m auger (ORU, +35 kg with
             * counterbalance), Inconel bellows at the chassis penetration.
             * Introduced P7 per ARCHITECTURE_BASELINE.md s.3 (fleet v9 s.4.2:
             * P8-P9 rollover, see W2-N1). Declines as Mk III removes chemical
             * propellant demand. Source: SEL-MOLEI-MkII-001 Rev A, ECN-016 s.2. */
        attribute redefines introducedIn = Phase::P7;
        attribute declineDrivenByMkIIIFrom = Phase::P11;
    }

    part def MoleS :> SurfaceRobot {
        doc /* MOLE-S surface excavation rover (RASSOR heritage bucket drums),
             * SPA ONLY: rim construction, blade grading, regolith supply to
             * SINTER, pad preparation. Four from P2; six from P6. Never
             * deployed to PKT under any circumstance - hauler Rev B does all
             * PKT surface work. FLAG F8 / AUD-001 (recorded): dry mass 350 kg
             * (fleet v9 s.3) vs ~205 kg (audit); no mass bound here.
             * Source: fleet v9 s.3, SEL_MOLES_DESIGN_RevA_updated. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::spa;
        assert constraint moleSNeverAtPkt {
            doc /* ECN-019 Rev C committed constraint (fleet v9 s.1 item 2). */
            homeSite == SiteId::spa
        }
    }

    // ---- Construction and support -------------------------------------

    part def Sinter :> SurfaceRobot {
        doc /* SINTER regolith sintering construction rover (ATHLETE mobility,
             * onboard 10 kWe fission reactor, three sintering modes: solar
             * concentrator, CO2 laser, microwave). Three at SPA from P2; PKT
             * complement from P8. Mandate: never decommission all units.
             * FLAG F8 / AUD-002 (recorded): 2,200 kg vs ~1,418 kg; no mass
             * bound. Source: fleet v9 s.5, SEL_SINTER_DESIGN_RevA_updated. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = (SiteId::spa, SiteId::pkt);
        attribute pktFrom = Phase::P8;
        attribute neverAllDecommissioned : Boolean = true;
    }

    abstract part def Arm :> SurfaceRobot {
        doc /* ARM manipulator family (ESA ERA + CSA Dextre heritage), rail-
             * gantry mounted, grid powered. ARM CANNOT enter the PSR: no WEB,
             * no cryogenic hardening (ECN-013 removed ARM from PSR deployment).
             * Source: fleet v9 s.9.1, SEL_ARM_DESIGN_RevA_updated. */
        attribute redefines canEnterPsr = false;
        assert constraint armNeverBelowRim {
            doc /* ECN-013: rim-and-surface operations only. */
            canEnterPsr == false
        }
    }

    part def ArmC :> Arm {
        doc /* ARM-C construction variant: mobile crane, circuit installation
             * and hub-station maintenance. One at SPA from P2, second per
             * VC-06 (P4 docs vs P7 VERIFY v5.0 - recorded, no count bound);
             * PKT complement from P8 scaling with circuit build rate. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = (SiteId::spa, SiteId::pkt);
        attribute pktFrom = Phase::P8;
    }

    part def ArmD :> Arm {
        doc /* ARM-D docking/maintenance variant at the SPA IZ; 1:1 with
             * docking collars (1 -> 2 -> 4 -> 6 -> 8 through P7, 30+ by P11).
             * The count is therefore SeleniteHabitat::IndustrialZone's collar
             * count, not a fleet attribute. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::spa;
        attribute countLockedToDockingCollars : Boolean = true;
    }

    part def SentinelRover :> SurfaceRobot {
        doc /* SENTINEL inspection and safety rover (hardware). Structural
             * validation before crew clearance, ISRU monitoring, H2 leak
             * detection, ECN-014 valve-station sensing. Two at SPA from P2,
             * PKT complement from P8 scaling with circuit count. The SENTINEL
             * supervision software is SeleniteSoftware::SentinelSystem - a
             * separate element. Source: SEL_SENTINEL_DESIGN_RevB, fleet v9
             * s.9.2. */
        attribute redefines introducedIn = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = (SiteId::spa, SiteId::pkt);
        attribute pktFrom = Phase::P8;
    }

    // ---- SPA logistics vehicles ---------------------------------------

    part def Skip :> SurfaceRobot {
        doc /* SKIP sub-orbital KREEP hopper, SPA ONLY (100 km hops to SPA
             * Basin exposures), ISRU-fuelled only. SKIP-1 at P4, eight by P7,
             * RETIRED P9 when PKT output makes SPA KREEP irrelevant. Never at
             * PKT (SEL-REQ-003; PROC-PKT-001 "PKT SKIPs" was an error fixed by
             * ECN-019). FLAG F8 / AUD-003 (recorded): 350 vs 400 kg per hop
             * container; VC-05 propellant per hop 303 vs 326.6 kg; no value
             * bound. Source: fleet v9 s.7, SEL_SKIP_DESIGN_RevA_updated. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = Phase::P9;
        attribute redefines homeSite = SiteId::spa;
        attribute peakFleetIn = Phase::P7;
        assert constraint skipNeverAtPkt {
            doc /* ECN-019 Rev C committed constraint; SEL-REQ-003. */
            homeSite == SiteId::spa
        }
    }

    part def Dart :> Spacecraft {
        doc /* DART deep-range autonomous return transport: SPA->PKT via LLO
             * orbital transfer (ballistic arc physically impractical). Single
             * pathfinder unit from P5; PKT ground truth and site confirmation
             * at Y22 (P7); from P8 operates at PKT on surface power, propellant
             * via mass driver. Source: fleet v9 s.8, SEL_DART_DESIGN_RevA_updated. */
        attribute redefines introducedIn = Phase::P5;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::spa;
        attribute pktSiteConfirmationIn = Phase::P7;
        attribute pktBasedFrom = Phase::P8;
    }

    part def Harvest :> SurfaceRobot {
        doc /* HARVEST aeroponic greenhouse tender, SPA, from P6 with the
             * greenhouse. Source: SEL_HARVEST_DESIGN_RevA_updated, baseline s.3. */
        attribute redefines introducedIn = Phase::P6;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::spa;
    }

    part def Cap :> SurfaceRobot {
        doc /* CAP Crater Access Pod: pressurised contingency crew descent on a
             * dedicated guide cable and crew-rated winch (IW-CAP). Guide-cable
             * anchors, rim winch pad and floor docking pad reserved at P1;
             * operational when crew are present (P4+). Fleet v9 s.13.5 titles
             * it "Phase 2+ Contingency" - both recorded; P4 is bound because
             * there is no crew to descend before P4. Does not solve floor EVA
             * thermal limits. Source: SEL-CAP-001 Rev A updated, fleet v9 s.13.5. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = (SiteId::spa, SiteId::psrFloor);
        attribute redefines canEnterPsr = true;
        attribute redefines countedInOperationalFleet = false;
        attribute anchorsReservedFrom = Phase::P1;
    }

    // ---- PKT surface fleet --------------------------------------------

    enum def HaulerMode {
        doc /* Hauler Rev B operating modes (fleet v9 s.10.2). */
        mine; grade; trench; transport;
    }

    part def HaulerFrontEnd {
        doc /* Swappable front-end attachment (bucket / blade), electric
             * linear actuation, Fe-Ni in-situ wear parts, ARM-swappable ORU. */
    }

    part def HaulerRevB :> SurfaceRobot {
        doc /* Surface hauler Rev B, mining-capable miner-hauler: PKT ONLY, from
             * P8 day one. Na-S battery, switched-reluctance hub motors, front
             * bucket/blade; replaces both SKIP and MOLE-S functions at PKT.
             * FLAG F3 (recorded, not resolved): in-situ manufactured mass
             * fraction - Rev A / ECN-017 lineage says 92 %; Rev B (fleet v9
             * s.10.4, HAULER_SPEC_UPDATE_BRIEF) says ~57 % with an Earth
             * fraction trajectory 100 % (P8) -> 20 % floor (post S-type).
             * No fraction bound. Source: SEL-HAULER-001 Rev B, fleet v9 s.10. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::pkt;
        attribute supportedModes = (
            HaulerMode::mine, HaulerMode::grade,
            HaulerMode::trench, HaulerMode::transport
        );
        part frontEnd : HaulerFrontEnd;
        assert constraint haulerPktOnly {
            doc /* ECN-019 Rev C committed constraint (fleet v9 s.1 item 3). */
            homeSite == SiteId::pkt
        }
    }

    // ---- Asteroid capture infrastructure ------------------------------

    part def RedirectTug :> Spacecraft {
        doc /* SEP/NEP redirect tug: Earth-built, self-transfers from LEO,
             * captures M-type (Y75), C-type (Y95), S-type (Y115) into DRO.
             * Development P10, operations P11 (first capture Y75). Fleet 2 ->
             * 3 -> 5 with redundancy (values Wave 5). Planetary-defence
             * review gates. Source: fleet v9 s.17.1, Strategy v3.1. */
        attribute redefines introducedIn = Phase::P11;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::cislunar;
        attribute developmentFrom = Phase::P10;
        attribute firstCaptureIn = Phase::P11;
    }

    part def LaserAblationTruss :> FleetAsset {
        doc /* Laser Ablation Truss at DRO: one per captured asteroid, dual
             * laser heads on a rotating rigid truss, spiral surface ablation,
             * electrostatic/magnetic ejecta capture (DE-STAR heritage,
             * DG-13.2). ~350 MW / ~1,000 t/day are Wave 5 values. First truss
             * with the M-type at P12. Source: fleet v9 s.17.2. */
        attribute redefines introducedIn = Phase::P12;
        attribute redefines retiredIn = null;
        attribute redefines homeSite = SiteId::dro;
        attribute onePerCapturedAsteroid : Boolean = true;
    }
}
