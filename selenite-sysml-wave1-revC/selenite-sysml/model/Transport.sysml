package SeleniteTransport {
    doc /* Logistics network: mass drivers MD-1..5 (5 drivers, 8 tracks per
         * ECN-020), canisters, EM catcher, steel apron conveyor network and
         * hauler/conveyor tiers at PKT, SKIP hops at SPA, Starship cargo,
         * PROBE return streams, PSR access link. Phase gates and ECN-020 track
         * counts only; velocities, YBCO masses, cadences are Wave 5.
         * Sources: SEL-ECN-020, SEL_ROBOT_FLEET_v9.md s.10.6, s.11, s.16,
         * s.19, SEL-CATAPULT-001 Rev B (heritage; Rev C outstanding, VC-21),
         * SEL-CONVEYOR-001 Rev A, Strategy v3.1 s.9, ARCHITECTURE_BASELINE.md
         * s.5. */

    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;

    doc absentByDesign /* ABSENT BY DESIGN (ECN-019 Rev C), asserted here so no
         * later wave re-introduces them: LLO tanker fleet; PKT SKIPs; ore
         * catapults (the 9,084 hubs of ECN-016/017); EM catapults for ore
         * duty; MOLE-S at PKT; D2EHPA. Coilgun technology survives only as
         * heritage for the five mass drivers and the EM catcher. SCALE v1.3
         * output showing tankers and PKT SKIPs is HISTORICAL (VC-14). */

    abstract part def LogisticsLink :> PhaseGated {
        doc /* Directed transport link between two programme nodes.
             * operationalFrom is the phase the link first carries traffic
             * (the brief's name for links; equals introducedIn). */
        abstract attribute operationalFrom : Phase;
        abstract attribute fromNode : SiteId;
        abstract attribute toNode : SiteId;
    }

    enum def MassDriverId {
        md1; md2; md3; md4; md5;
    }

    part def MassDriverTrack {
        doc /* One complete coilgun track (own coils, YBCO, cryocooler string
             * and supercapacitor bank - tracks share only the sintered
             * foundation). Source: ECN-020 s.1. */
    }

    abstract part def MassDriver :> LogisticsLink {
        doc /* Mass driver: coilgun launcher (SEL-CATAPULT-001 Rev B heritage,
             * EMALS / maglev TRL basis). trackCount per ECN-020 s.3; the
             * network total of 8 is asserted in MassDriverNetwork. */
        abstract attribute driverId : MassDriverId;
        attribute trackCount : Integer;
        part tracks : MassDriverTrack[1..*];
        port launchInput;
        port receiverOutput;
    }

    part def MassDriverMd1 :> MassDriver {
        doc /* MD-1 SPA->PKT, P8 (DG-8.0): propellant, reagents, Fe-Ni foundry
             * feedstock, Th(OH)4, spares. Sole inter-site link, hence 2 tracks
             * (1 primary + 1 warm-standby redundant). */
        attribute redefines driverId = MassDriverId::md1;
        attribute redefines introducedIn = Phase::P8;
        attribute redefines operationalFrom = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::spa;
        attribute redefines toNode = SiteId::pkt;
        attribute redefines trackCount = 2;
        part redefines tracks : MassDriverTrack[2];
        part canister : InterSiteCargoCanister;
    }

    part def MassDriverMd2 :> MassDriver {
        doc /* MD-2 PKT->Earth, P9 (DG-9.1): REO canisters, round-robin over 3
             * parallel tracks with one-track-offline maintenance rotation;
             * also lofts O2 by-product to the L1 depot (SEL-REQ-005). */
        attribute redefines driverId = MassDriverId::md2;
        attribute redefines introducedIn = Phase::P9;
        attribute redefines operationalFrom = Phase::P9;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::pkt;
        attribute redefines toNode = SiteId::earth;
        attribute redefines trackCount = 3;
        part redefines tracks : MassDriverTrack[3];
        part canister : ReoExportCanister;
    }

    part def MassDriverMd3 :> MassDriver {
        doc /* MD-3 PKT->SPA: ThCl4 for the SPA MSR, single track. P10 per
             * ARCHITECTURE_BASELINE.md; fleet v9 s.16 gives "P9-P10 (Y43)"
             * (Y43 lies in P9) - recorded as W2-N2. FLAG F6 (recorded): scope
             * P11 labels the SPA->Earth driver "MD-3"; ECN-020 numbering
             * (MD-3 = PKT->SPA, MD-4 = SPA->Earth) is carried and the scope
             * label treated as stale, per DOCUMENT_FAMILIES.md default. */
        attribute redefines driverId = MassDriverId::md3;
        attribute redefines introducedIn = Phase::P10;
        attribute redefines operationalFrom = Phase::P10;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::pkt;
        attribute redefines toNode = SiteId::spa;
        attribute redefines trackCount = 1;
        part redefines tracks : MassDriverTrack[1];
        part canister : ThCl4Canister;
    }

    part def MassDriverMd4 :> MassDriver {
        doc /* MD-4 SPA->Earth, P11 (DG-11.6): PGM exports, single track,
             * foundation sized for a future parallel track. See F6 in MD-3. */
        attribute redefines driverId = MassDriverId::md4;
        attribute redefines introducedIn = Phase::P11;
        attribute redefines operationalFrom = Phase::P11;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::spa;
        attribute redefines toNode = SiteId::earth;
        attribute redefines trackCount = 1;
        part redefines tracks : MassDriverTrack[1];
        part canister : PgmExportCanister;
    }

    part def MassDriverMd5 :> MassDriver {
        doc /* MD-5 DRO->SPA, P12 (M-type online Y85): asteroid concentrate,
             * single track. */
        attribute redefines driverId = MassDriverId::md5;
        attribute redefines introducedIn = Phase::P12;
        attribute redefines operationalFrom = Phase::P12;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::dro;
        attribute redefines toNode = SiteId::spa;
        attribute redefines trackCount = 1;
        part redefines tracks : MassDriverTrack[1];
        part canister : ConcentrateCanister;
    }

    part def MassDriverNetwork :> PhaseGated {
        doc /* The five-driver, eight-track network of ECN-020. Enumerated by
             * name because five drivers ARE the architecture. YBCO totals
             * (~523 t lifetime) and cadences (~694,444 canisters/yr) are Wave 5
             * values; CATAPULT-001 Rev C is outstanding (VC-21). */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        part md1 : MassDriverMd1;
        part md2 : MassDriverMd2;
        part md3 : MassDriverMd3;
        part md4 : MassDriverMd4;
        part md5 : MassDriverMd5;
        attribute driverCount : Integer = 5;
        attribute totalTrackCount : Integer = 8;
        assert constraint ecn020TrackBudget {
            doc /* ECN-020 s.3: 2 + 3 + 1 + 1 + 1 = 8 tracks over 5 drivers. */
            md1.trackCount + md2.trackCount + md3.trackCount
                + md4.trackCount + md5.trackCount == totalTrackCount
        }
    }

    enum def CanisterKind {
        doc /* Payload families carried by the network. */
        reoExport; interSiteCargo; thcl4Fuel; pgmExport; asteroidConcentrate; mkIiiFeNi;
    }

    abstract part def Canister {
        doc /* Mass driver canister: Fe-Ni shell (ferromagnetic, EM-brake
             * compatible). Payload mass (3.6 t REO for MD-2 per ECN-020 s.4)
             * is a Wave 5 value. SEL-CANISTER-001 not yet written - these are
             * the placeholders. Source: ECN-020, fleet v9 s.2.4 and s.16. */
        abstract attribute kind : CanisterKind;
    }

    part def ReoExportCanister :> Canister {
        doc /* MD-2 REO export canister with minimal drag chute for Earth arrival. */
        attribute redefines kind = CanisterKind::reoExport;
    }

    part def InterSiteCargoCanister :> Canister {
        doc /* MD-1 SPA->PKT cargo canister (propellant, reagents, Fe-Ni, spares). */
        attribute redefines kind = CanisterKind::interSiteCargo;
    }

    part def ThCl4Canister :> Canister {
        doc /* MD-3 PKT->SPA thorium chloride fuel canister. */
        attribute redefines kind = CanisterKind::thcl4Fuel;
    }

    part def PgmExportCanister :> Canister {
        doc /* MD-4 SPA->Earth PGM export canister. */
        attribute redefines kind = CanisterKind::pgmExport;
    }

    part def ConcentrateCanister :> Canister {
        doc /* MD-5 DRO->SPA asteroid concentrate canister. */
        attribute redefines kind = CanisterKind::asteroidConcentrate;
    }

    part def MkIiiPayloadCanister :> Canister {
        doc /* PROBE Mk III Fe-Ni/PGM canister ejected from LLO; cold-gas kick
             * motor for trajectory shaping; received by the EM catcher. */
        attribute redefines kind = CanisterKind::mkIiiFeNi;
    }

    part def EmCatcher :> LogisticsLink {
        doc /* SPA electromagnetic catcher: coilgun run in reverse, regenerative.
             * Three inbound streams: PKT->SPA canisters (MD-3), DRO->SPA
             * concentrate (MD-5), Mk III PROBE LLO ejections. P11 per
             * ARCHITECTURE_BASELINE.md s.4; fleet v9 s.2.4 notes the MD-3
             * receiver "built P9-P10 serves double duty" (recorded, W2-N3).
             * Source: fleet v9 s.16 and s.19. */
        attribute redefines introducedIn = Phase::P11;
        attribute redefines operationalFrom = Phase::P11;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::cislunar;
        attribute redefines toNode = SiteId::spa;
        port inboundCanisters;
    }

    enum def PktTransportTier {
        doc /* PKT surface transport tiers: haulers Tier 1-2, conveyors Tier 3
             * (50-150 km). No SKIPs, no catapults. */
        tier1; tier2; tier3;
    }

    part def SteelApronConveyor :> LogisticsLink {
        doc /* Steel apron conveyor (Fe-Ni pans on roller chains, SRM drive
             * stations, MoS2 rollers), ~95 % in-situ. Tier 3 ore transport,
             * replacing EM catapults (SEL-REQ-006). Pilot P9, network deploying
             * P10. Source: SEL-CONVEYOR-001 Rev A, fleet v9 s.11. */
        attribute redefines introducedIn = Phase::P9;
        attribute redefines operationalFrom = Phase::P9;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::pkt;
        attribute redefines toNode = SiteId::pkt;
        attribute tier = PktTransportTier::tier3;
        attribute throughputTonnesPerYear : Real;
    }

    part def ConveyorNetwork :> PhaseGated {
        doc /* Dendritic trunk + branch conveyor network at PKT (route counts
             * and km per phase are Wave 5; VC-10 87,500 vs 137,500 km
             * recorded). Pilot P9, deploying from P10. */
        attribute redefines introducedIn = Phase::P9;
        attribute redefines retiredIn = null;
        attribute deployingFrom = Phase::P10;
        part referenceTrunk : SteelApronConveyor;
        part referenceBranch : SteelApronConveyor;
        port spineDelivery;
        connect referenceBranch.receiverOutput to referenceTrunk.launchInput;
    }

    part def HaulerRoadNetwork :> LogisticsLink {
        doc /* PKT sintered road network for hauler Tier 1-2 transport from P8
             * day one (haulers from the first construction wave). */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines operationalFrom = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::pkt;
        attribute redefines toNode = SiteId::pkt;
        attribute tiers = (PktTransportTier::tier1, PktTransportTier::tier2);
    }

    part def SkipHopLink :> LogisticsLink {
        doc /* SKIP hops SPA <-> SPA Basin KREEP exposures, P4-P9 (SKIP retired
             * P9). SPA Basin KREEP only. Never PKT. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines operationalFrom = Phase::P4;
        attribute redefines retiredIn = Phase::P9;
        attribute redefines fromNode = SiteId::spa;
        attribute redefines toNode = SiteId::spa;
    }

    part def StarshipCargoLink :> LogisticsLink {
        doc /* Earth -> SPA (P1) and Earth -> PKT (P8, four construction waves)
             * cargo; diminishing to <1 % of mass by P14. Never retired
             * (irreducible avionics/BMS imports). */
        attribute redefines introducedIn = Phase::P1;
        attribute redefines operationalFrom = Phase::P1;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::earth;
        attribute redefines toNode = (SiteId::spa, SiteId::pkt);
        attribute pktDeliveriesFrom = Phase::P8;
    }

    part def ProbeReturnLink :> LogisticsLink {
        doc /* Asteroids -> SPA: Mk I/II land at the IZ (P3 onwards); Mk III
             * canisters to the EM catcher (P11 onwards). */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines operationalFrom = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::cislunar;
        attribute redefines toNode = SiteId::spa;
        attribute mkIiiCanisterStreamFrom = Phase::P11;
    }

    part def PsrAccessLink :> LogisticsLink {
        doc /* SPA rim <-> PSR floor: winches, trunk cable, tramway (P3),
             * heated pipeline (P4+). Physical elements in SelenitePsrNetwork. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines operationalFrom = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines fromNode = SiteId::spa;
        attribute redefines toNode = SiteId::psrFloor;
    }
}
