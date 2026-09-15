package SeleniteRequirements {
    doc /* Programme-level requirements capturing committed architectural
         * principles. Wave 1 carried six committed-principle exemplars with
         * ProgrammeContext subjects; Wave 3 (15 Sep 2026) binds them to
         * checkable subjects where a model attribute exists and adds
         * SEL-REQ-007..016 from ECN-019 Rev C (cited through SEL-T1.1-STRATEGY
         * v3.1, which integrates it in its body text - ECN-019 itself is not
         * in the repository), SEL-ECN-020 and SEL-DECISION-001 Rev D. Every
         * requirement with a require constraint is machine-checkable on the
         * instance tree in SeleniteConfigurations, where the satisfy links
         * live. SEL-REQ-005 keeps the ProgrammeContext subject: the L1 O2
         * depot it names has no element yet (Wave 4). */

    private import ScalarValues::*;
    private import SeleniteFleet::*;
    private import SeleniteHabitat::*;
    private import SeleniteParameters::*;
    private import SelenitePhases::*;
    private import SeleniteProcessing::*;
    private import SeleniteSites::*;
    private import SeleniteTransport::*;

    part def ProgrammeContext {
        doc /* Governance subject for programme-wide requirements that are
             * not bound to a single site or subsystem (SEL-REQ-005 only,
             * after Wave 3). */
    }

    requirement def <'SEL-REQ-001'> SteadyStateReoTarget {
        doc /* The programme shall achieve 2.5 Mt/yr rare earth oxide
             * output at steady state (~Y180 / P14), fully replacing
             * terrestrial REE mining. Source: Strategy v3.1 header (ECN-019
             * Rev C target); Decision Framework Rev D DG-14.8. Checked against
             * ProgrammeParameters (Wave 3); the ECON reo vector reaches the
             * target at Y180 (test_invariants.py, plan_check DG-14.8). */
        subject params : ProgrammeParameters;
        attribute targetTonnesPerYear : Real = 2500000.0;
        require constraint { params.steadyStateReoTonnesPerYear == targetTonnesPerYear }
    }

    requirement def <'SEL-REQ-002'> ZeroPermanentCrewAtPkt {
        doc /* The PKT site shall operate with zero permanent crew at all
             * phases, permanently. Source: ECN-019 Rev C committed decision
             * (Strategy v3.1 s.5.2). The temporary commissioning crew of
             * DG-8.6 is the recorded exception (SEL-REQ-012). */
        subject site : LunarSite;
        require constraint { site.permanentCrew == 0 }
    }

    requirement def <'SEL-REQ-003'> NoSkipOperationsAtPkt {
        doc /* No SKIP vehicles shall ever operate at the PKT site.
             * Source: ECN-019 Rev C committed decision (Strategy v3.1 s.6).
             * Made checkable at Wave 2 via LunarSite.skipOperationsPermitted. */
        subject site : LunarSite;
        require constraint { site.skipOperationsPermitted == false }
    }

    requirement def <'SEL-REQ-004'> NoD2ehpa {
        doc /* No D2EHPA shall be used anywhere in the value chain.
             * Basis: split value chain / organic-solvent-free processing.
             * Source: Strategy v3.1 s.10.1 (ECN-019 Rev C), Th/U separation
             * preprint. Checkable at Wave 3 on ZeroCarbonFlowsheet.usesD2ehpa
             * (ThUSeparationStage asserts the same on itself). */
        subject flowsheet : ZeroCarbonFlowsheet;
        require constraint { flowsheet.usesD2ehpa == false }
    }

    requirement def <'SEL-REQ-005'> AllByProductsUsedAtScale {
        doc /* All process by-products shall be used at scale; O2 routed
             * to the L1 fuel depot via MD-2, not vented or dumped.
             * Source: Strategy v3.1, Decision Framework Rev D. Not yet
             * checkable: the L1 depot and the O2 stream have no element
             * (Wave 4 value-chain flows). */
        subject programme : ProgrammeContext;
    }

    requirement def <'SEL-REQ-006'> OreTransportByConveyor {
        doc /* Bulk ore transport shall use steel apron conveyors (Tier 3) and
             * haulers (Tier 1-2); EM catapults are retired for ore duty (mass
             * driver heritage retained for canister launch only). Source:
             * ECN-019 Rev C via Strategy v3.1 s.7.3 (9,084 catapult hubs ->
             * 0). Checkable at Wave 3 on ConveyorNetwork.oreCatapultHubCount
             * and the trunk's oreTransportMode. */
        subject network : ConveyorNetwork;
        require constraint {
            network.oreCatapultHubCount == 0
            and network.referenceTrunk.oreTransportMode == OreTransportMode::conveyor
        }
    }

    requirement def <'SEL-REQ-007'> NoArmBelowRim {
        doc /* No ARM manipulator shall operate below the crater rim (no WEB,
             * no cryogenic hardening). Source: ECN-013 (removed ARM from PSR
             * deployment), fleet v9 s.9.1. The assert constraint
             * SeleniteFleet::Arm.armNeverBelowRim carries it; this requirement
             * wires it to every ARM usage. */
        abstract subject arm : Arm;
        require constraint { arm.canEnterPsr == false }
    }

    requirement def <'SEL-REQ-008'> NoMoleSAtPkt {
        doc /* MOLE-S shall be deployed at SPA only; all PKT surface excavation
             * is by mining-capable haulers. Source: ECN-019 Rev C via Strategy
             * v3.1 s.4.1 and s.7.1 (fleet v9 s.1 item 2). Constraint
             * SeleniteFleet::MoleS.moleSNeverAtPkt. */
        subject moleS : MoleS;
        require constraint { moleS.homeSite == SiteId::spa }
    }

    requirement def <'SEL-REQ-009'> HaulerPktOnly {
        doc /* The Rev B miner-hauler shall be based at PKT only. Source:
             * ECN-019 Rev C via Strategy v3.1 s.7.1; SEL-HAULER-001 Rev B.
             * Constraint SeleniteFleet::HaulerRevB.haulerPktOnly. */
        subject hauler : HaulerRevB;
        require constraint { hauler.homeSite == SiteId::pkt }
    }

    requirement def <'SEL-REQ-010'> MkIiiNeverLands {
        doc /* PROBE Mk III shall never land on the Moon and shall use zero ISRU
             * propellant (ion propulsion; canisters to the EM catcher).
             * Source: ECN-019 Rev C via Strategy v3.1 s.2.2; Decision
             * Framework Rev D DG-11.6. Constraint
             * SeleniteFleet::ProbeMkIII.mkIiiNeverLands. */
        subject probe : ProbeMkIII;
        require constraint { probe.neverLands == true and probe.usesIsruPropellant == false }
    }

    requirement def <'SEL-REQ-011'> MassDriverTrackBudget {
        doc /* The mass driver network shall comprise five drivers and eight
             * tracks: MD-1 two (primary + redundant), MD-2 three (round-robin),
             * MD-3/4/5 one each. Source: SEL-ECN-020 s.2 and s.3 (applied
             * baseline). Constraint SeleniteTransport::MassDriverNetwork.
             * ecn020TrackBudget. */
        subject network : MassDriverNetwork;
        require constraint {
            network.driverCount == 5
            and network.md1.trackCount == 2 and network.md2.trackCount == 3
            and network.md3.trackCount == 1 and network.md4.trackCount == 1
            and network.md5.trackCount == 1
            and network.totalTrackCount == 8
        }
    }

    requirement def <'SEL-REQ-012'> PktTemporaryCrewOnlyInP8 {
        doc /* A temporary commissioning crew (3-4, 6-12 months) may be present
             * at PKT during P8 only; the crew habitat is introduced and
             * retired in the same phase. Source: Decision Framework Rev D
             * DG-8.6; Strategy v3.1 s.5.2 and s.7.2; the SEL-REQ-002 exception
             * resolved in DOCUMENT_FAMILIES.md. Crew size bound in
             * ProgrammeParameters.pktTemporaryCommissioningCrewMax. */
        subject hab : PktTemporaryCrewHab;
        require constraint { hab.retiredIn == hab.introducedIn }
    }

    requirement def <'SEL-REQ-013'> AsteroidProcessingAtSpa {
        doc /* All asteroid material (M/C/S-type) shall be processed at SPA;
             * PKT processes KREEP REO only. Source: ECN-019 Rev C base
             * specialisation via Strategy v3.1 s.5.2; Decision Framework Rev D
             * s.10.1 / s.10.2. */
        abstract subject line : AsteroidProcessingLine;
        require constraint { line.location == SiteId::spa }
    }

    requirement def <'SEL-REQ-014'> ProbesBasedAtSpa {
        doc /* Chemical PROBE classes (Mk I, Mk II) shall be based permanently
             * at SPA (propellant constraint: PKT has no water ice). Source:
             * Strategy v3.1 s.2.4; Decision Framework Rev D s.3.2. */
        abstract subject probe : Spacecraft;
        require constraint { probe.homeSite == SiteId::spa }
    }

    requirement def <'SEL-REQ-015'> CircuitDesignCommitted {
        doc /* The committed processing circuit design shall meet the DG-8.X
             * throughput threshold: the optimised continuous-flow circuit
             * (1.2 t/yr REO, 28,000 kg, 400 kW) against >= 1.0 t/yr. Source:
             * Decision Framework Rev D s.4 and DG-8.X; Strategy v3.1 s.10.2.
             * Both values are ProgrammeParameters attributes. */
        subject params : ProgrammeParameters;
        require constraint {
            params.circuitReoTonnesPerYear >= params.gateThresholds.circuitThroughputMinimumTonnesPerYear
        }
    }

    requirement def <'SEL-REQ-016'> PsrCapacityFromLayout {
        doc /* The PSR MOLE-I capacity used by the Mk III transition gate
             * (DG-11.6) shall be the layout computation's node count times
             * units per node, not a document figure (rule W2-N18; psr_layout.py
             * n_total = 124, node.units = 5). The fleet-need side
             * (ECON molei_needed) is checked by tools/plan_check.py. */
        subject params : ProgrammeParameters;
        require constraint {
            params.psrMoleICapacityUnits == params.psrMoleINodeCount * params.psrMoleIUnitsPerNode
        }
    }
}
