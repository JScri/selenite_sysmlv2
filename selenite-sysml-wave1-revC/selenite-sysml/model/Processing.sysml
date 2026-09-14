package SeleniteProcessing {
    doc /* REE value chain processing. Sources: fleet v9 s.14,
         * Strategy v3.1 s.10 (split value chain, D2EHPA elimination),
         * Decision Framework Rev D s.4, Th/U separation preprint (.md). */

    private import ScalarValues::*;
    private import SelenitePhases::*;

    part def ProcessingCircuit {
        doc /* Optimised continuous-flow circuit. Fleet-scale count is a
             * configuration value (2.08e6 at P14) — see PKT configuration. */
        attribute activeFrom : Phase;
    }

    part def ThUSeparationStage {
        doc /* Organic-solvent-free Th/U separation from KREEP leach liquor.
             * Feed: Li et al. 2022 silicothermic ITE phase. Candidate
             * architectures per the Th/U preprint; selection TODO Wave 4.
             * Constraint: no D2EHPA anywhere (SEL-REQ-004). */
    }

    part def KreepFeedstock {
        doc /* PKT KREEP terrane ore feed. Resource basis: ~88-264 years at
             * 2.5 Mt/yr from 200 m accessible depth (Strategy v3.1). */
    }
}
