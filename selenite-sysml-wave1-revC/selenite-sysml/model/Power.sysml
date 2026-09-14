package SelenitePower {
    doc /* Power architecture. Sources: fleet v9 s.18, Strategy v3.1 s.12,
         * Decision Framework Rev D s.7. SEL-POWER-001 Rev A is stale
         * (pre-MSR fleet); SEL-POWER-PKT-001 Rev A not yet written. */

    private import ISQ::*;
    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SI::*;

    part def ThoriumMSR {
        doc /* Thorium molten salt reactor, PKT power from P9.
             * ~6,890 units x 100 MWe at P14. Fuel: Th from KREEP
             * processing stream (closed loop with SeleniteProcessing). */
        attribute ratedElectricalPower :> ISQ::power = 100000000.0 [SI::W];
        attribute activeFrom : Phase = Phase::P9;
    }

    part def SolarArray {
        doc /* SPA early-phase power (Shackleton illumination advantage —
             * Glaeser et al. 2014). TODO Wave 2 attributes. */
        attribute ratedPower :> ISQ::power;
    }
}
