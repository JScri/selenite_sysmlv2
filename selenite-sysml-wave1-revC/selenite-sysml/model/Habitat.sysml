package SeleniteHabitat {
    doc /* Crewed infrastructure, SPA Shackleton only.
         * Sources: SEL-HAB-001 Rev D, SEL-ECLSS-002 Rev A,
         * potable water supply design (.md). TODO Wave 2. */

    private import ScalarValues::*;

    part def HabModule {
        attribute crewCapacity : Integer;
    }

    part def Eclss {
        doc /* Environmental control & life support. Source: SEL-ECLSS-002. */
    }

    part def IsruPlant {
        doc /* In-situ resource utilisation plant. Source: SEL-ISRU-001 Rev D.
             * Electrolysis arithmetic per resolved AUD-005/006/007. */
    }
}
