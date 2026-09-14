package SeleniteTransport {
    doc /* Surface and orbital logistics. Sources: fleet v9 s.16,
         * Strategy v3.1 s.9, Decision Framework Rev D s.3, ECN-019/020. */

    private import ScalarValues::*;
    private import SelenitePhases::*;

    part def SteelApronConveyor {
        doc /* Primary ore transport, replacing EM catapults for ore duty
             * (ECN-019). SEL-CONVEYOR-001 Rev A not yet written — this
             * definition is the placeholder. See SEL-REQ-006. */
        attribute throughputTonnesPerYear : Real;
        attribute activeFrom : Phase;
    }

    enum def MassDriverClass {
        MD1; MD2;
    }

    part def MassDriver {
        doc /* Mass driver network: 5 drivers total per ECN-020 —
             * 3x MD-2 parallel tracks + 2x MD-1 tracks. MD-2 also lofts
             * O2 by-product to the L1 fuel depot (SEL-REQ-005).
             * Heritage: SEL-CATAPULT-001 (superseded for ore transport). */
        attribute driverClass : MassDriverClass;
        attribute activeFrom : Phase;
    }

    part def ReturnCanister {
        doc /* Mass driver return canister. SEL-CANISTER-001 Rev A not yet
             * written — placeholder. TODO Wave 2. */
    }
}
