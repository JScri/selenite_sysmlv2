package SeleniteParameters {
    doc /* Exogenous programme inputs: the small set of declared decisions from
         * which the derived plan (SeleniteGates, Wave 3) and the quantities
         * (Wave 5) follow. Each parameter names its decision owner and source.
         * A parameter is bound here only when it is a committed decision the
         * model already carries elsewhere; capacity constraints and vectors
         * that the Python layer supplies stay unbound with a doc. Changing a
         * bound value here is an ECN. Rule 5c in CLAUDE_SYSML_CONTEXT.md. */

    private import ScalarValues::*;
    private import SelenitePhases::*;

    enum def ParameterKind {
        doc /* policy: a programme decision; computationalInput: an input the
             * ECON/VERIFY layer takes as given; capacityConstraint: a physical
             * limit that gates derived from it must respect. */
        policy; computationalInput; capacityConstraint;
    }

    part def ProgrammeParameters {
        doc /* Single instance in SeleniteConfigurations. Values with
             * provenance; unbound attributes are Wave 5 inputs. */

        attribute steadyStateReoTonnesPerYear : Real = 2500000.0;
        doc reoDoc /* policy. SEL-REQ-001; ECN-019 Rev C committed target;
             * ECON v1.3 reo vector reaches it (test_invariants.py). */

        attribute steadyStateYear : Integer = 180;
        doc ssYearDoc /* policy. ARCHITECTURE_BASELINE.md s.1 (P14plus from Y180);
             * final report v4 Fig. 2 "Mission achieved Y180". */

        attribute mTypeCaptureYear : Integer = 75;
        attribute cTypeCaptureYear : Integer = 95;
        attribute sTypeCaptureYear : Integer = 115;
        doc captureDoc /* computationalInput. ECON v1.4 console "Diversified
             * asteroids: M-type (Y75), C-type (Y95), S-type (Y115)"; fleet v9
             * s.17.3. Online years follow at +10 (Y85/Y105/Y125) and set the
             * phases of the SPA processing lines (W2-N7). */

        attribute permanentCrewAtPkt : Integer = 0;
        attribute spaPermanentCrewAtFullConfiguration : Integer = 20;
        doc crewDoc /* policy. SEL-REQ-002; Strategy v3.1; HAB-001 Rev D. */

        attribute psrMoleICapacityUnits : Integer;
        doc psrCapDoc /* capacityConstraint, UNBOUND - W2-N18: fleet v9 s.4.1 says
             * ~310 MOLE-I on ~8.5 km2 usable floor (62 substations); final
             * report Fig. 12 (VISUALIZE v3.3) says 124 nodes / 620 MOLE-I on a
             * 33.2 km2 floor; Fig. 11 scopes ~17.5 km2 feasible. This cap
             * drives the Mk III transition gate, so it must be settled by the
             * PSR layout computation (psr_layout.py), not by a document. */

        attribute reoTonnesPerYearByYear : Real [0..*] ordered;
        doc rampDoc /* computationalInput, UNBOUND: the REO demand ramp by
             * programme year, from ECON v1.3 'reo' (Wave 5 binding). Every
             * capacity-driven gate is a consequence of this vector. */

        attribute co2PerLaunchTonnes : Real;
        doc co2Doc /* computationalInput, UNBOUND - VC-20: 2,200 (ECON v1) vs
             * 2,683 (ECN-020) vs 2,750 declining (ECON v1.4). ECON v1.4 is the
             * authority; bound at Wave 5. */

        attribute launchCostPerFlightUsd : Real;
        doc launchDoc /* computationalInput, UNBOUND: ECON v1.4 Starship
             * baseline ($100M/flight per final report Fig. 48); Wave 5. */
    }
}
