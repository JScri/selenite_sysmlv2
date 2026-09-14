package SeleniteProgramme {
    doc /* Selenite Programme — SysML v2 model root.
         *
         * A 200-year lunar rare earth element mining and processing
         * initiative targeting full replacement of terrestrial REE
         * mining at 2.5 Mt/yr REO by ~Y180.
         *
         * Baseline: ECN-019 Rev C + ECN-020.
         * ECN-021 (PKT process water) drafted, NOT propagated — excluded. Document-of-record traceability:
         * every definition carries a doc comment citing its source
         * document and revision. mapping/document_map.csv is the
         * master migration index.
         *
         * Package map:
         *   SelenitePhases          - phase enumeration P0-P14+, PhaseGated
         *                             base, year windows, F7 gap
         *   SeleniteSites           - seven programme nodes (SPA, PSR floor,
         *                             PKT, EML-2, PKT relay, DRO, Earth)
         *   SeleniteFleet           - robot fleet (fleet v9.md authority)
         *   SelenitePsrNetwork      - Shackleton PSR access/charging network
         *   SeleniteHabitat         - SPA/PKT crewed and fixed facilities
         *   SelenitePower           - SPA/PKT power, MSR fleet, F5
         *   SeleniteProcessing      - REE value chain, flowsheet, Th/U stage
         *   SeleniteTransport       - MD-1..5 (ECN-020), conveyors, links
         *   SeleniteSoftware        - SENTINEL, ECN-014, NAV-001 (structure)
         *   SeleniteParameters      - exogenous programme inputs (Wave 3)
         *   SeleniteGates           - decision gates DG-x.y, derivation rule
         *   SeleniteRequirements    - committed architectural principles
         *   SeleniteAnalysis        - calcs (MATLAB remains authority)
         *   SeleniteConfigurations  - programme instance tree
         *
         * Wave 2 (September 2026): architecture and temporal skeleton
         * complete; see CHANGELOG_WAVE2.md.
         */

    private import SeleniteConfigurations::*;
}
