package SeleniteSites {
    doc /* Programme nodes for the dual-site architecture plus its orbital and
         * terrestrial ends: SPA Shackleton, Shackleton PSR floor, PKT
         * Procellarum, EML-2 relay constellation, PKT relay satellite, DRO
         * station, Earth. Each carries existsFrom (phase), crew policy and
         * site-selection provenance. Sources: ARCHITECTURE_BASELINE.md s.2,
         * Strategy v3.1, Decision Framework v4 (F1: taken as "Rev D"),
         * ECN-019 Rev C, W4_T3_3_JS_Selenite_site_selection_v1 (GIS, LOLA 5 m).
         * Coordinates and crew ramp values arrive from the Python layer
         * (Wave 5); only phase gates and committed policy are bound here.
         * Wave 4B (7 Nov 2026): nodes carry typed mass-driver dispatch /
         * receipt and supervision ports (SeleniteInterfaces) so every
         * node-to-link connection in SeleniteConfigurations goes through an
         * interface; the L1 O2 depot of SEL-REQ-005 is added as a node. */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;

    enum def SiteId {
        doc /* Node identifiers used by fleet homeSite and logistics links.
             * l1Depot added at Wave 4B (SEL-REQ-005). Source:
             * ARCHITECTURE_BASELINE.md s.2. */
        earth; emL2; spa; psrFloor; pkt; pktRelay; dro; cislunar; l1Depot;
    }

    abstract part def ProgrammeNode {
        doc /* Any node in the programme network. existsFrom is the phase in
             * which the node first exists physically (hardware landed, satellite
             * deployed, asteroid captured). Source: ARCHITECTURE_BASELINE.md
             * s.2. */
        abstract attribute nodeId : SiteId;
        abstract attribute existsFrom : Phase;
        attribute nodeName : String;
        attribute role : String;
    }

    part def LunarSite :> ProgrammeNode {
        doc /* Lunar surface site. permanentCrew is the committed steady-state
             * permanent complement (0 or 20 are policy, not estimates);
             * latitude/longitude are GIS values populated at Wave 5 from the
             * W4_T3_3 site-selection dataset (LOLA 5 m DEM). canisterDispatch
             * and canisterReceipt are the site ends of the mass driver legs
             * (ECN-020); supervision is the site's SENTINEL node. Source:
             * ARCHITECTURE_BASELINE.md s.2, s.5, s.7. */
        attribute latitudeDeg : Real;
        attribute longitudeDeg : Real;
        attribute permanentCrew : Integer;
        attribute skipOperationsPermitted : Boolean;
        attribute gisProvenance : String = "W4_T3_3_JS_Selenite_site_selection_v1 (LOLA 5 m)";
        port canisterDispatch : CanisterPort;
        port canisterReceipt : ~CanisterPort;
        port cargoLanding : ~CargoPort;
        port supervision : SupervisionPort;
    }

    part def CrewedHub :> LunarSite {
        doc /* SPA Shackleton, Connecting Ridge (~89.5 deg S). Crewed hub,
             * proving ground, ISRU, asteroid processing centre, Ops Hub
             * (command from P4). Crew ramp per ARCHITECTURE_BASELINE.md s.2:
             * 0 (P1-P3) -> 4 (P4, Crew-1 at M82) -> 8 -> 12 -> 20 (P7+);
             * the ramp is documentation here and a Python-sourced vector at
             * Wave 5. Source: Strategy v3.1, HAB-001 Rev D, site selection v1. */
        attribute redefines nodeId = SiteId::spa;
        attribute redefines existsFrom = Phase::P1;
        attribute redefines permanentCrew = 20;
        attribute redefines skipOperationsPermitted = true;
        attribute crewedFrom = Phase::P4;
        attribute fullConfigurationFrom = Phase::P7;
        attribute opsHubFrom = Phase::P4;
        port opsHubSupervisor : ~SupervisionPort {
            doc /* The SPA Ops Hub: supervises the SENTINEL edge from P4 and,
                 * through the PKT relay, PKT at 0.5 s from P8
                 * (ARCHITECTURE_BASELINE.md s.7). */
        }
        port returnPayloadDispatch : ProductPort {
            doc /* REO / PGM concentrate to the Starship return capsule
                 * (StarshipReturnLink, P5 until MD-4). */
        }
    }

    part def PsrFloor :> LunarSite {
        doc /* Shackleton permanently shadowed crater floor: MOLE-I ice network
             * (fishbone trunk -> CLP -> spine -> branches -> substations, see
             * SelenitePsrNetwork). Zero crew; CAP contingency access only.
             * ARM never enters (no cryogenic hardening, ECN-013).
             * Source: fleet v9 s.13, SEL_SUBSTATION_DESIGN_v4, VISUALIZE v3.3
             * geometry. */
        attribute redefines nodeId = SiteId::psrFloor;
        attribute redefines existsFrom = Phase::P3;
        attribute redefines permanentCrew = 0;
        attribute redefines skipOperationsPermitted = false;
        attribute contingencyCrewAccessFrom = Phase::P4;
    }

    part def AutonomousFactory :> LunarSite {
        doc /* PKT Procellarum KREEP Terrane (~14 deg N), ~3,300 km from SPA.
             * Fully autonomous factory; zero permanent crew at every phase
             * (SEL-REQ-002). Temporary commissioning crew (3-4, 6-12 months)
             * during P8 only is baseline; the older "no temporary crews, ever"
             * scope text is superseded (DOCUMENT_FAMILIES.md, resolved).
             * No SKIPs, ever (SEL-REQ-003). Site confirmed by DART at Y22 (P7).
             * Source: ECN-019 Rev C, Strategy v3.1, PROC-PKT-001 Rev B. */
        attribute redefines nodeId = SiteId::pkt;
        attribute redefines existsFrom = Phase::P8;
        attribute redefines permanentCrew = 0;
        attribute redefines skipOperationsPermitted = false;
        attribute temporaryCrewOnlyIn = Phase::P8;
        attribute siteConfirmedIn = Phase::P7;
    }

    abstract part def OrbitalNode :> ProgrammeNode {
        doc /* Orbital or deep-space node (no surface, no crew). Source:
             * ARCHITECTURE_BASELINE.md s.2. */
    }

    part def L1OxygenDepot :> OrbitalNode {
        doc /* The L1 / EML-2 O2 fuel depot that SEL-REQ-005 routes the
             * process by-product O2 to via MD-2 ("not vented or dumped").
             * Added at Wave 4B so SEL-REQ-005 has a subject (verification
             * item (b)). existsFrom is UNBOUND at definition level and
             * DERIVED in SeleniteConfigurations as the phase MD-2 becomes
             * operational (the depot cannot receive before its driver exists),
             * the StarshipReturnLink idiom. W4B-N4 (recorded, not resolved):
             * no repository document names this depot - not Strategy v3.1, not
             * Decision Framework Rev D, not fleet v9, not ECN-020; the Wave 1
             * requirement cites "Strategy v3.1, Decision Framework Rev D" and
             * neither carries it. W4B-N18 (7 Nov 2026): ECN-019 Rev C
             * (docs/ECN-019_Programme_Wide_Design_Revision.md, status
             * PROPOSED) does not name an L1 / EML-2 depot or an O2 loft
             * either - its s.18.1 gives MD-2 the single purpose "REO
             * canisters" PKT -> Earth, and its s.15.1 names SPA as the
             * "propellant depot" of the P14+ cislunar launch hub (value chain
             * v16 says the same). The depot therefore rests on SEL-REQ-005
             * alone; kept as the requirement states it and raised to Jason. */
        attribute redefines nodeId = SiteId::l1Depot;
        port oxygenReceipt : ~CanisterPort;
    }

    part def RelaySatellite {
        doc /* One EML-2 halo relay spacecraft, built on Earth in P0.
             * Source: Strategy v3.1, fleet v9 s.8 (DART comms). */
    }

    part def RelayConstellation :> OrbitalNode {
        doc /* Three EML-2 relay satellites for continuous south-pole comms;
             * built P0, deployed P1. Three is the architecture (continuous
             * coverage), hence the enumerated multiplicity.
             * Source: ARCHITECTURE_BASELINE.md s.2, fleet v9 s.8. */
        attribute redefines nodeId = SiteId::emL2;
        attribute redefines existsFrom = Phase::P1;
        attribute builtIn = Phase::P0;
        part relaySatellites : RelaySatellite[3];
        port southPoleComms : SupervisionPort {
            doc /* Continuous south-pole comms the Earth ops hub supervises SPA
                 * through in P2-P3 (ARCHITECTURE_BASELINE.md s.7). */
        }
    }

    part def PktRelaySatellite :> OrbitalNode {
        doc /* SPA<->PKT relay giving the 0.5 s supervision link from P8.
             * Source: ARCHITECTURE_BASELINE.md s.2 and s.7. */
        attribute redefines nodeId = SiteId::pktRelay;
        attribute redefines existsFrom = Phase::P8;
        port supervisionTrunk : SupervisionPort {
            doc /* The 0.5 s SPA <-> PKT supervision link passes through the
                 * relay; the SENTINEL edge's pktRelayLink connects here. */
        }
    }

    part def DroStation :> OrbitalNode {
        doc /* Distant retrograde orbit station: captured-asteroid processing
             * (Laser Ablation Truss, MD-5 DRO->SPA). Exists from the first
             * capture (M-type online Y85, P12); C-type online Y105 (P12),
             * S-type online Y125 (P13) - years authoritative per W2-N7.
             * Source: fleet v9 s.17, Strategy v3.1. */
        attribute redefines nodeId = SiteId::dro;
        attribute redefines existsFrom = Phase::P12;
        port canisterDispatch : CanisterPort;
        port supervision : SupervisionPort;
    }

    part def EarthNode :> ProgrammeNode {
        doc /* Earth: launch origin, market sink, individual REE solvent
             * extraction, Earth ops hub (supervision P2-P3 at 2.56 s RTT).
             * Source: ARCHITECTURE_BASELINE.md s.2 and s.7. */
        attribute redefines nodeId = SiteId::earth;
        attribute redefines existsFrom = Phase::P0;
        port opsHub : ~SupervisionPort {
            doc /* Earth ops hub: direct supervision of SPA at 2.56 s RTT in
                 * P2-P3, strategic oversight after (ARCHITECTURE_BASELINE.md
                 * s.7). */
        }
        port canisterReceipt : ~CanisterPort;
        port returnPayloadReceipt : ~ProductPort;
        port cargoOrigin : CargoPort;
    }
}
