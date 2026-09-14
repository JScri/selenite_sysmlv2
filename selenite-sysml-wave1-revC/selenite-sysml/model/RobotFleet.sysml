package SeleniteFleet {
    doc /* Robot fleet definitions. Authoritative integrated reference:
         * SEL_ROBOT_FLEET_v9.md. Individual Rev A design specs are
         * manufacturing-level sources per vehicle (see document_map.csv).
         * Migration status: skeleton only — full spec attributes are
         * Wave 2 (see docs/MIGRATION_PLAN.md). */

    private import ISQ::*;
    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SI::*;

    abstract part def SurfaceRobot {
        attribute dryMass :> ISQ::mass;
        attribute peakPower :> ISQ::power;
        attribute activeFrom : Phase;
    }

    part def MoleS :> SurfaceRobot {
        doc /* Surface regolith miner. Source: SEL_MOLES_DESIGN_RevA. TODO Wave 2. */
    }

    part def MoleI :> SurfaceRobot {
        doc /* Ice/volatiles miner, PSR crater operations, Mk II drill.
             * Source: SEL_MOLEI_DESIGN_v5 (incl. ECN-012/013). TODO Wave 2. */
    }

    part def Hauler :> SurfaceRobot {
        doc /* Ore/materials hauler. Source: fleet v9 s.10 (Rev B content);
             * SEL-HAULER-001 Rev A superseded. TODO Wave 2. */
    }

    part def Dart :> SurfaceRobot {
        doc /* Source: SEL_DART_DESIGN_RevA. TODO Wave 2. */
    }

    part def Arm :> SurfaceRobot {
        doc /* Source: SEL_ARM_DESIGN_RevA. TODO Wave 2. */
    }

    part def Sentinel :> SurfaceRobot {
        doc /* Monitoring/inspection incl. ECN-014 valve monitoring.
             * Sources: SEL_SENTINEL_DESIGN_RevA, SEL-SW-SENTINEL-001. TODO Wave 2. */
    }

    part def Sinter :> SurfaceRobot {
        doc /* Regolith sintering/construction. Source: SEL_SINTER_DESIGN_RevA. TODO Wave 2. */
    }

    part def Survey :> SurfaceRobot {
        doc /* Source: SEL_SURVEY_DESIGN_RevA. TODO Wave 2. */
    }

    part def Harvest :> SurfaceRobot {
        doc /* Source: SEL_HARVEST_DESIGN_RevA. TODO Wave 2. */
    }

    part def Skip :> SurfaceRobot {
        doc /* Ballistic hopper. Retirement per fleet v9; never operated at
             * PKT — see SEL-REQ-003. Source: SEL_SKIP_DESIGN_RevA. */
    }

    part def Probe {
        doc /* PROBE Mk III: SEP ion propulsion asteroid-return vehicle.
             * Never lands; electromagnetic anchoring. Diversified capture
             * targets: M-type, C-type, S-type. Source: fleet v9 (Mk III);
             * SEL_PROBE_DESIGN_RevA is stale (pre-Mk III). TODO Wave 2
             * pending SEL-PROBE-MkIII-001 Rev A. */
        attribute dryMass :> ISQ::mass;
        attribute activeFrom : Phase;
    }
}
