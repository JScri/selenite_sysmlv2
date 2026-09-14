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

    calc def MsrFleetPower {
        doc /* Installed PKT electrical capacity from MSR unit count. */
        in unitCount : Real;
        in unitRatedWatts : Real;
        return installedWatts : Real = unitCount * unitRatedWatts;
    }
}
