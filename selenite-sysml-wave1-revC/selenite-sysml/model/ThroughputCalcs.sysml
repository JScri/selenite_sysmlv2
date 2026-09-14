package SeleniteAnalysis {
    doc /* Analysis definitions. AUTHORITY NOTE: MATLAB remains the
         * quantitative source of truth (SELENITE_VERIFY v5.0,
         * SELENITE_ECON v1.4, SELENITE_SCALE). Values here are
         * transcribed from verified MATLAB output, never derived
         * independently. Full parametric linkage is Wave 5. */

    private import ScalarValues::*;

    calc def AnnualReoOutput {
        doc /* Steady-state REO output from feed rate and recovery. */
        in feedTonnesPerYear : Real;
        in overallRecoveryFraction : Real;
        return reoTonnesPerYear : Real = feedTonnesPerYear * overallRecoveryFraction;
    }

    calc def SpaMsrIntroductionGate {
        doc /* F5 gate (Wave 2 structure, Wave 5 evaluation): an SPA MSR is
             * justified in a phase when SPA electrical demand exceeds what
             * solar + FSP + battery can deliver, ThCl4 supply exists (MD-3
             * operational) and an MSR can feasibly be deployed at the crewed
             * base in that phase. Evaluated per phase on Python-sourced
             * demand/capability vectors; the first phase returning true binds
             * SelenitePower::SpaThoriumMSR.introducedIn. Mirrors the rule
             * "weight demand and capability, do not gate on a predetermined
             * phase" (Jason, 14 Sep 2026). Weights and margins: Wave 5. */
        in spaDemandWatts : Real;
        in spaNonMsrCapabilityWatts : Real;
        in thcl4SupplyAvailable : Boolean;
        in msrDeployableAtSpa : Boolean;
        return justified : Boolean =
            thcl4SupplyAvailable and msrDeployableAtSpa
            and spaDemandWatts > spaNonMsrCapabilityWatts;
    }

    calc def MsrFleetPower {
        doc /* Installed PKT electrical capacity from MSR unit count. */
        in unitCount : Real;
        in unitRatedWatts : Real;
        return installedWatts : Real = unitCount * unitRatedWatts;
    }
}
