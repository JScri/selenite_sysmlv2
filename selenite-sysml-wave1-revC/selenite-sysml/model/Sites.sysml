package SeleniteSites {
    doc /* Lunar site definitions for the dual-site architecture.
         * Source: Strategy v3.1, Decision Framework Rev D, ECN-019 Rev C. */

    private import ScalarValues::*;
    private import SelenitePhases::*;

    part def LunarSite {
        attribute siteName : String;
        attribute latitudeDeg : Real;
        attribute longitudeDeg : Real;
        attribute permanentCrew : Integer;
        attribute operationalFrom : Phase;
    }

    part def CrewedHub :> LunarSite {
        doc /* Crewed operations hub pattern: habitation, ISRU,
             * asteroid processing centre, mass driver network terminus. */
    }

    part def AutonomousFactory :> LunarSite {
        doc /* Fully autonomous processing factory pattern.
             * Zero permanent crew at all phases — see SEL-REQ-002. */
    }
}
