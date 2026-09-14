package SeleniteRequirements {
    doc /* Programme-level requirements capturing committed architectural
         * principles from ECN-019 Rev C, Strategy v3.1 and the Decision
         * Framework v3. Requirement extraction from source documents is
         * Wave 3 — these six are the committed-principle exemplars. */

    private import ScalarValues::*;
    private import SeleniteSites::*;

    part def ProgrammeContext {
        doc /* Governance subject for programme-wide requirements that are
             * not bound to a single site or subsystem. Wave 3 will bind
             * requirements to concrete subjects where checkable. */
    }

    requirement def <'SEL-REQ-001'> SteadyStateReoTarget {
        doc /* The programme shall achieve 2.5 Mt/yr rare earth oxide
             * output at steady state (~Y180 / P14), fully replacing
             * terrestrial REE mining. Source: Strategy v3.1. */
        subject programme : ProgrammeContext;
        attribute targetTonnesPerYear : Real = 2500000.0;
    }

    requirement def <'SEL-REQ-002'> ZeroPermanentCrewAtPkt {
        doc /* The PKT site shall operate with zero permanent crew at all
             * phases, permanently. Source: ECN-019 Rev C committed decision. */
        subject site : LunarSite;
        require constraint { site.permanentCrew == 0 }
    }

    requirement def <'SEL-REQ-003'> NoSkipOperationsAtPkt {
        doc /* No SKIP vehicles shall ever operate at the PKT site.
             * Source: ECN-019 Rev C committed decision. Made checkable at
             * Wave 2 via LunarSite.skipOperationsPermitted. */
        subject site : LunarSite;
        require constraint { site.skipOperationsPermitted == false }
    }

    requirement def <'SEL-REQ-004'> NoD2ehpa {
        doc /* No D2EHPA shall be used anywhere in the value chain.
             * Basis: split value chain / organic-solvent-free processing.
             * Source: Strategy v3.1 s.10.1, Th/U separation preprint. */
        subject programme : ProgrammeContext;
    }

    requirement def <'SEL-REQ-005'> AllByProductsUsedAtScale {
        doc /* All process by-products shall be used at scale; O2 routed
             * to the L1 fuel depot via MD-2, not vented or dumped.
             * Source: Strategy v3.1, Decision Framework Rev D. */
        subject programme : ProgrammeContext;
    }

    requirement def <'SEL-REQ-006'> OreTransportByConveyor {
        doc /* Bulk ore transport shall use steel apron conveyors; EM
             * catapults are retired for ore duty (mass driver heritage
             * retained for canister launch only). Source: ECN-019 Rev C. */
        subject programme : ProgrammeContext;
    }
}
