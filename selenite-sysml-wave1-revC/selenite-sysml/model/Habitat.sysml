package SeleniteHabitat {
    doc /* Crewed and fixed surface infrastructure: SPA habitat, ECLSS, ISRU
         * plant (with the four ECN-014 cryo isolation valve stations),
         * Industrial Zone (docking collars, beneficiation, EM catcher slot),
         * ELZ landing pads, greenhouse, crew return vehicle; PKT temporary
         * crew hab and PKT ELZ. Phase of introduction only; sizes and rates
         * are Wave 5. Sources: SEL-HAB-001 Rev D updated, SEL-FP-HAB-001
         * Rev B, HAB-WALL-XSECTION-001, SEL-ECLSS-001/002/SCALING Rev B,
         * SEL-ISRU-001 Rev D updated (+ CAD-ISRU ECN-014 amendment),
         * SEL-IZ-001 Rev B, SEL-ELZ-001 Rev A updated, sabatier.m (ECLSS
         * scenario authority), ARCHITECTURE_BASELINE.md s.4. */

    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteProcessing::*;
    private import SeleniteSites::*;

    abstract part def Facility :> PhaseGated {
        doc /* Base for fixed facilities. */
        abstract attribute location : SiteId;
    }

    part def HabModule {
        doc /* One sintered-regolith habitat module (shell printed by SINTER,
             * outfitted later). Source: SEL-HAB-001 Rev D, FP-HAB-001 Rev B. */
        attribute crewCapacity : Integer;
    }

    part def HabitatComplex :> Facility {
        doc /* SPA habitat complex: shells printed P3, crewed P4 (Crew-1),
             * H3 module added P7; eight modules at full configuration (module
             * count is a Wave 5 value, recorded here in doc only).
             * Source: SEL-HAB-001 Rev D updated, ARCHITECTURE_BASELINE.md s.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute crewedFrom = Phase::P4;
        attribute h3ModuleFrom = Phase::P7;
        part referenceModule : HabModule;
        port o2SupplyLine;
    }

    part def Eclss :> Facility {
        doc /* Environmental control and life support, commissioned P4 with
             * Crew-1; water recovery units scale 1 -> 4 (values Wave 5).
             * Source: SEL-ECLSS-001/002 Rev B, ECLSS-SCALING-001 Rev B,
             * sabatier.m Scenario C (VC-12 recorded). */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
    }

    part def VolatileExtractionUnit {
        doc /* VEX thermal desorption unit; throughput matched to the MOLE-I
             * fleet. Source: fleet v9 s.12.1. */
    }

    part def PemElectrolyserStack {
        doc /* PEM electrolyser stack (ISS OGA heritage); stack count per phase
             * is a Wave 5 value (F8 / VC-04 ISRU power 1,090 / 1,171 / 1,360 /
             * 1,627 kW recorded, none bound). */
    }

    part def CryocoolerPlant {
        doc /* H2/O2 liquefaction (turbo-Brayton or pulse-tube, ZBO heritage). */
    }

    part def CryogenicStorage {
        doc /* LH2/LOX propellant farm adjacent to the IZ. VC-13 (LH2 buffer
             * volume 175 vs 196 m3) recorded, not bound. */
    }

    part def CryoIsolationValveStation {
        doc /* Isolation valve station on the ISRU-IZ cryo transfer line: two
             * valves, pneumatic actuators with spring-return fail-closed,
             * hardwired 24 VDC close line, limit switches, ECN-014 sensor set.
             * Monitored by SeleniteSoftware::CryoValveMonitoringFunction. */
        port sensorOutput;
        port hardwiredCloseInput;
        port limitSwitchOutput;
    }

    part def IsruPlant :> Facility {
        doc /* SPA ISRU plant: first output P3, self-sufficient P4, 19 PEM
             * stacks + cryo by P7 (stack count Wave 5). Water from the PSR via
             * the heated pipeline (tramway in P3). Four cryo isolation valve
             * stations (two at the ISRU manifold exit, two at the IZ propellant
             * farm entry) are the ECN-014 architecture, hence the
             * multiplicity. Electrolysis arithmetic per resolved
             * AUD-005/006/007 where adopted (CAD-ISRU). Source: SEL-ISRU-001
             * Rev D updated, updated_SEL-CAD-ISRU-001. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute selfSufficientFrom = Phase::P4;
        part vex : VolatileExtractionUnit;
        part electrolyser : PemElectrolyserStack;
        part cryocooler : CryocoolerPlant;
        part propellantFarm : CryogenicStorage;
        part cryoTransferValveStations : CryoIsolationValveStation[4];
        port psrWaterInlet;
        port propellantToIz;
        connect vex to electrolyser;
        connect electrolyser to cryocooler;
        connect cryocooler to propellantFarm;
    }

    part def DockingCollar {
        doc /* PROBE docking collar: horizontal cylinder in a single linear row,
             * soft capture + conductive charging + SpaceWire. One ARM-D per
             * collar. Source: SEL-IZ-001 Rev B, SEL-CAD-IZ-001. */
    }

    part def IndustrialZone :> Facility {
        doc /* SPA Industrial Zone: PROBE docking gantry (collars 1 -> 2 -> 4 ->
             * 6 -> 8 through P7; 30+ by P11 is a Wave 5 value), beneficiation
             * from P5, EM catcher from P11 (SeleniteTransport::EmCatcher,
             * placed in the configuration). Eight collars at P7 full
             * configuration is the IZ-001 Rev B design point, hence the
             * enumerated multiplicity. Mk III PROBEs never dock here. A
             * provisional non-pressurised collar arrives with Cargo Launch 1
             * (P1) for PROBE-Scout data receipt before the IZ proper (final
             * report Fig. 26). */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        part dockingCollars : DockingCollar[8];
        part beneficiation : BeneficiationPlant;
        port propellantFromIsru;
        port emCatcherBerth;
    }

    part def LandingPad {
        doc /* Sintered landing pad in the ELZ. Source: SEL-ELZ-001 Rev A updated. */
    }

    part def SpaLandingZone :> Facility {
        doc /* SPA ELZ: pads 1-2 at P4 (Crew-1 arrival), pads 3-4 at P6.
             * Source: SEL-ELZ-001 Rev A updated, ARCHITECTURE_BASELINE.md s.4. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        part padsOneAndTwo : LandingPad[2] {
            doc /* From P4. */
        }
        part padsThreeAndFour : LandingPad[2] {
            doc /* From P6. */
        }
        attribute padsThreeAndFourFrom = Phase::P6;
    }

    part def Greenhouse :> Facility {
        doc /* SPA aeroponic greenhouse from P6, tended by HARVEST. */
        attribute redefines introducedIn = Phase::P6;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
    }

    part def CrewReturnVehicle :> Facility {
        doc /* Always-fuelled crew return vehicle at SPA from P4 (crew presence).
             * Source: ARCHITECTURE_BASELINE.md s.4. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute alwaysFuelled : Boolean = true;
    }

    part def PktTemporaryCrewHab :> Facility {
        doc /* Temporary commissioning crew habitat at PKT, P8 only (3-4 crew,
             * 6-12 months): introduced and retired in the same phase. Baseline
             * per DOCUMENT_FAMILIES.md resolved conflicts. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = Phase::P8;
        attribute redefines location = SiteId::pkt;
    }

    part def PktLandingZone :> Facility {
        doc /* PKT ELZ for the four-wave construction campaign, P8. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
    }
}
