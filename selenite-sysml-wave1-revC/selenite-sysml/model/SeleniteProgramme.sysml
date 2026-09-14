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
         *   SelenitePhases          - phase enumeration P0-P14
         *   SeleniteSites           - site definitions (dual-site arch)
         *   SeleniteFleet           - robot fleet (fleet v9 authority)
         *   SeleniteTransport       - conveyors, mass drivers
         *   SeleniteProcessing      - REE value chain, Th/U separation
         *   SelenitePower           - thorium MSR fleet, solar
         *   SeleniteHabitat         - SPA crewed infrastructure
         *   SeleniteRequirements    - committed architectural principles
         *   SeleniteAnalysis        - calcs (MATLAB remains authority)
         *   SeleniteConfigurations  - programme instance tree
         */

    private import SeleniteConfigurations::*;
}
