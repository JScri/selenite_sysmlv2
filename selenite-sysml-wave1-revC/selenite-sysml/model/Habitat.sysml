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
         * scenario authority), ARCHITECTURE_BASELINE.md s.4. Wave 4B (7 Nov
         * 2026): every port typed by SeleniteInterfaces, the ISRU chain
         * connected through interfaces, the habitat O2 line and the
         * cryo valve stations carrying the ECN-014 ports. */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;
    private import SeleniteProcessing::*;
    private import SeleniteSites::*;

    abstract part def Facility :> PhaseGated {
        doc /* Base for fixed facilities. Source: ARCHITECTURE_BASELINE.md s.4
             * (the facility list this package carries). */
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
        port o2SupplyLine : ~OxygenPort {
            doc /* Low-pressure stainless O2 line with double-block-and-bleed
                 * isolation (Strategy v3.1 s.5.1); monitored and auto-closed
                 * per ECN-014 (SeleniteSoftware::O2SupplyLineMonitoringFunction). */
        }
        port o2LineSensors : SensorPort;
        port o2LineAutoClose : ~HardwiredClosePort;
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
             * fleet. Water in from the PSR (pipeline P4+, tramway containers
             * P3). Source: fleet v9 s.12.1. */
        port regolithIn : ~IcyRegolithPort;
        port waterIn : ~WaterPort;
        port waterOut : WaterPort;
        flow waterIn.water to waterOut.water;
    }

    part def PemElectrolyserStack {
        doc /* PEM electrolyser stack (ISS OGA heritage); stack count per phase
             * is a Wave 5 value (F8 / VC-04 ISRU power 1,090 / 1,171 / 1,360 /
             * 1,627 kW recorded, none bound). Source: fleet v9 s.12.2. */
        port waterIn : ~WaterPort;
        port hydrogenOut : HydrogenPort;
        port oxygenOut : OxygenPort;
    }

    part def CryocoolerPlant {
        doc /* H2/O2 liquefaction (turbo-Brayton or pulse-tube, ZBO heritage).
             * Source: fleet v9 s.12.3. */
        port hydrogenIn : ~HydrogenPort;
        port oxygenIn : ~OxygenPort;
        port propellantOut : PropellantPort;
    }

    part def CryogenicStorage {
        doc /* LH2/LOX propellant farm adjacent to the IZ. VC-13 (LH2 buffer
             * volume 175 vs 196 m3) recorded, not bound. Source: fleet v9
             * s.12.4. */
        port propellantIn : ~PropellantPort;
        port propellantOut : PropellantPort;
        port oxygenToHabitat : OxygenPort;
        flow propellantIn.propellant to propellantOut.propellant;
    }

    enum def ValvePosition {
        doc /* Commanded / confirmed position of a cryo isolation valve pair
             * (ECN-014 via fleet v9 s.9.2: closure confirmed by limit switch). */
        open; closed;
    }

    part def CryoIsolationValveStation {
        doc /* Isolation valve station on the ISRU-IZ cryo transfer line: two
             * valves, pneumatic actuators with spring-return fail-closed,
             * hardwired 24 VDC close line, limit switches, ECN-014 sensor set.
             * Monitored by SeleniteSoftware::CryoValveMonitoringFunction, whose
             * state machine commands it; the hardware facts ECN-014 fixes are
             * asserted here (Wave 4B). Source: ECN-014 extract in fleet v9
             * s.9.2 and s.12.4; updated_SEL-CAD-ISRU-001 Rev A (ECN-014
             * amendment, not in the repository - TODO). */
        port sensorOutput : SensorPort;
        port hardwiredCloseInput : ~HardwiredClosePort;
        port limitSwitchOutput : LimitSwitchPort;
        attribute springReturnFailClosed : Boolean = true;
        attribute closeCommandHardwired : Boolean = true;
        attribute closeCommandOverFieldbus : Boolean = false;
        attribute closureConfirmedByLimitSwitch : Boolean = true;
        abstract attribute positionOnLossOfSignal : ValvePosition;
        assert constraint deadManFailClosed {
            doc /* ECN-014: loss of the hardwired signal fails the valves
                 * closed by spring return; the close path is never a fieldbus. */
            springReturnFailClosed == true
                and closeCommandHardwired == true
                and closeCommandOverFieldbus == false
                and closureConfirmedByLimitSwitch == true
        }
    }

    part def IsruCryoValveStation :> CryoIsolationValveStation {
        doc /* The concrete ECN-014 station (binds the fail-closed position so
             * the usage is complete). */
        attribute redefines positionOnLossOfSignal = ValvePosition::closed;
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
        part cryoTransferValveStations : IsruCryoValveStation[4];
        port psrWaterInlet : ~WaterPort;
        port tramwayRegolithInlet : ~IcyRegolithPort;
        port propellantToIz : PropellantPort;
        port oxygenToHabitat : OxygenPort;
        port powerIn : ~PowerPort;
        port supervision : SupervisionPort;
        interface psrWaterToVex : WaterTransfer connect psrWaterInlet to vex.waterIn;
        interface tramwayToVex : IcyRegolithTransfer connect tramwayRegolithInlet to vex.regolithIn;
        interface vexToElectrolyser : WaterTransfer connect vex.waterOut to electrolyser.waterIn;
        interface hydrogenToCryo : HydrogenTransfer connect electrolyser.hydrogenOut to cryocooler.hydrogenIn;
        interface oxygenToCryo : OxygenTransfer connect electrolyser.oxygenOut to cryocooler.oxygenIn;
        interface cryoToFarm : PropellantTransfer connect cryocooler.propellantOut to propellantFarm.propellantIn;
        interface farmToIz : PropellantTransfer connect propellantFarm.propellantOut to propellantToIz;
        interface farmOxygenToHab : OxygenTransfer connect propellantFarm.oxygenToHabitat to oxygenToHabitat;
    }

    part def DockingCollar {
        doc /* PROBE docking collar: horizontal cylinder in a single linear row,
             * soft capture + conductive charging + SpaceWire. One ARM-D per
             * collar. Ore containers leave through the dust vestibule to
             * beneficiation; the PROBE is refuelled at the collar (Decision
             * Framework Rev D s.3.2). Source: SEL-IZ-001 Rev B, SEL-CAD-IZ-001. */
        port oreFromProbe : ~OrePort;
        port oreOut : OrePort;
        port propellantToProbe : PropellantPort;
        flow oreFromProbe.ore to oreOut.ore;
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
             * report Fig. 26).
             * Source: SEL-IZ-001 Rev B; fleet v9 s.19; ARCHITECTURE_BASELINE.md s.4. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        part dockingCollars : DockingCollar[8];
        part beneficiation : BeneficiationPlant;
        port propellantFromIsru : ~PropellantPort;
        port emCatcherBerth : ~CanisterPort;
        port skipOreIn : ~OrePort;
        port concentrateOut : OrePort;
        port powerIn : ~PowerPort;
        interface collarsToBeneficiation : OreTransfer connect dockingCollars.oreOut to beneficiation.oreIn;
        interface skipToBeneficiation : OreTransfer connect skipOreIn to beneficiation.oreIn;
        interface beneficiationOut : OreTransfer connect beneficiation.concentrateOut to concentrateOut;
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
        port cargoLanding : ~CargoPort;
    }

    part def Greenhouse :> Facility {
        doc /* SPA aeroponic greenhouse from P6, tended by HARVEST. Source:
             * ARCHITECTURE_BASELINE.md s.3 and s.4; SEL_HARVEST_DESIGN Rev A
             * updated. */
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
             * per DOCUMENT_FAMILIES.md resolved conflicts. Source: Decision
             * Framework Rev D DG-8.6 and s.10.2; Strategy v3.1 s.5.2. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = Phase::P8;
        attribute redefines location = SiteId::pkt;
    }

    part def PktLandingZone :> Facility {
        doc /* PKT ELZ for the four-wave construction campaign, P8. Source:
             * Strategy v3.1 s.7.2; ARCHITECTURE_BASELINE.md s.4. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        port cargoLanding : ~CargoPort;
    }
}
