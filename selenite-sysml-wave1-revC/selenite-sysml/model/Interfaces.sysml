package SeleniteInterfaces {
    doc /* Wave 4B (7 Nov 2026): the typed items, port definitions and
         * interface definitions that every connection in the model goes
         * through. Wave 2 declared bare ports ('port x;') on the structural
         * elements; this package types them. One port def per medium with the
         * supplying direction as the definition and the conjugate ('~') as the
         * receiving side, one interface def per medium with the flow stated,
         * and the ECN-023 eclipse operating rule as an interface constraint on
         * the power supply to the SPA asteroid lines. Items are the material
         * and data flowing in the value chain (SeleniteBehaviour) and nothing
         * is quantified here (rule 3: masses, rates and thresholds arrive from
         * the Python layer at Wave 5).
         * Sources: SEL_ROBOT_FLEET_v9.md s.4.1 (MOLE-I water path, tether,
         * bayonet adapter), s.9.2 (ECN-014 extract: sensors, hardwired 24 VDC
         * auto-close, limit switch, O2 line), s.12 (ISRU chain), s.13.3-13.4
         * (pipeline, trunk cable, taps), s.16 (mass driver streams), s.19 (IZ
         * material flow); SEL-T1.1-STRATEGY v3.1 s.2.4, s.5.1 (O2 line), s.8.2
         * (ThCl4), s.10.1 (flowsheet), s.11.1; SEL-DECISION-001 Rev D s.3.2
         * (Fe-Ni flows), s.10.1; SEL-ECN-023 s.3 (operating rule);
         * ARCHITECTURE_BASELINE.md s.5-s.7. The winners SEL-SW-SENTINEL-001
         * Rev B, SEL-NAV-001 Rev A, SEL-CON-001 Rev B updated and the value
         * chain v14.1 / v15 / v16 are NOT in the repository (UPLOAD_LEDGER.csv
         * entries only); where a definition rests on them it says so with a
         * TODO naming the file. */

    private import ScalarValues::*;

    // =====================================================================
    // Material items
    // =====================================================================

    item def Material {
        doc /* Base for every material flowing in the value chain (concrete so
             * a generic cargo port is complete, SSM021). Quantities (mass,
             * rate) are Wave 5 bindings from the Python layer. */
    }

    item def IcyRegolith :> Material {
        doc /* MOLE-I drill product: icy regolith (>= 3 wt% ice branches,
             * fleet v9 s.13.4) processed by the mini-VEX on the rover (fleet v9
             * s.4.1) or lifted by the P3 tramway to the rim VEX (fleet v9
             * s.13.2). */
    }

    item def Water :> Material {
        doc /* Product water: mini-VEX batch dump -> substation manifold ->
             * branch / trunk pipe -> CLP trunk pump -> rim ISRU (fleet v9 s.4.1
             * "Mini-VEX water path", s.13.3). Also C-type pyrolysis water from
             * Y105 (fleet v9 s.17.3). */
    }

    item def Hydrogen :> Material {
        doc /* Electrolysis hydrogen before liquefaction (fleet v9 s.12.2). */
    }

    item def Oxygen :> Material {
        doc /* Electrolysis oxygen: liquefied for propellant, piped to the
             * habitat on the low-pressure stainless line (Strategy v3.1 s.5.1),
             * surplus 20-45x crew demand (Strategy v3.1 s.13). SEL-REQ-005
             * routes the process by-product to the L1 depot via MD-2. */
    }

    item def Propellant :> Material {
        doc /* LH2 / LOX from the ISRU cryocooler and propellant farm (fleet v9
             * s.12.3-12.4) to PROBE, SKIP, DART and the crew return vehicle;
             * also MD-1 cargo to PKT (fleet v9 s.16). */
    }

    item def ElectricalPower :> Material {
        doc /* Electrical power on a bus: SPA base bus, 1,000 VDC trunk cable
             * to the PSR (fleet v9 s.13.4), PKT spine bus. Carried as an item
             * so the power interfaces have a typed flow; ratings are Wave 5. */
    }

    item def OreFeed :> Material {
        doc /* Any ore or concentrate entering a processing step (concrete so
             * that a port typed by it is complete, SSM021; the subtypes name
             * the specific feed). */
    }

    item def KreepOre :> OreFeed {
        doc /* Raw KREEP regolith: SPA Basin exposures by SKIP (P4-P9, fleet v9
             * s.7), PKT surface by hauler Tier 1-2 and conveyor Tier 3 (fleet
             * v9 s.10, s.11). */
    }

    item def KreepConcentrate :> OreFeed {
        doc /* Beneficiated KREEP (10x physical upgrade: jaw crusher, screens,
             * magnetic drums; Strategy v3.1 s.5.1 item 4, s.10.2 note). */
    }

    item def AsteroidOre :> OreFeed {
        doc /* Fe-Ni / PGM ore returned by PROBE Mk I / II to the IZ collar or
             * ejected by Mk III as LLO canisters to the EM catcher (Decision
             * Framework Rev D s.3.2; fleet v9 s.19). */
    }

    item def AsteroidConcentrate :> OreFeed {
        doc /* Laser Ablation Truss ejecta concentrate from the captured M / C /
             * S-type body at DRO, mass-driven to SPA on MD-5 (Decision
             * Framework Rev D s.3.2 "captured asteroid material flow"; fleet
             * v9 s.17.2-17.3). */
    }

    item def ProcessLiquor :> Material {
        doc /* Intermediate stream between flowsheet unit operations (leach
             * liquor, precipitates, split fractions; Strategy v3.1 s.10.1).
             * Chemistry per step is a SEL-PROC-001 Rev B value (not bound). */
    }

    item def ProcessProduct :> Material {
        doc /* A saleable or re-used product leaving a processing line. */
    }

    item def ReoConcentrate :> ProcessProduct {
        doc /* Mixed rare earth oxide concentrate (didymium-grade, individual SX
             * on Earth; Strategy v3.1 s.10.1 steps 7-8). The MD-2 canister
             * payload (ECN-020 s.4). */
    }

    item def PgmConcentrate :> ProcessProduct {
        doc /* PGM concentrate from chlorination hydromet at SPA (Decision
             * Framework Rev D s.3.2; fleet v9 s.19), to Earth by Starship
             * return and MD-4. */
    }

    item def FeNiBulk :> ProcessProduct {
        doc /* Fe-Ni bulk from asteroid ore after PGM separation: SPA -> PKT on
             * MD-1 as foundry feedstock (Decision Framework Rev D s.3.2 step 6;
             * Strategy v3.1 s.2.4). */
    }

    item def CTypeVolatiles :> ProcessProduct {
        doc /* Water, carbon and nitrogen from C-type pyrolysis (fleet v9
             * s.17.3); carbon products (PTFE, polymers, F-T hydrocarbons) to
             * PKT for circuit fabrication (Decision Framework Rev D s.10.1). */
    }

    item def Silicon :> ProcessProduct {
        doc /* Czochralski silicon from the S-type line (fleet v9 s.17.3;
             * carbothermic reduction needs C-type carbon, DG-14.3). */
    }

    item def Copper :> ProcessProduct {
        doc /* Electrolytic copper from the S-type line (fleet v9 s.17.3). */
    }

    item def FoundryMetal :> ProcessProduct {
        doc /* PKT foundry output - MRE Al-Si, Fe-Si, Fe-Ni components for
             * haulers, circuits and conveyors (SEL-FAB-001 Rev A; fleet v9
             * s.10.4). */
    }

    item def ThoriumCompound :> Material {
        doc /* The thorium stream from the KREEP flowsheet to MSR fuel. */
    }

    item def ThoriumHydroxide :> ThoriumCompound {
        doc /* Th(OH)4 locked by the 300 degC acid bake as ThP2O7 and recovered
             * at the Ca(OH)2 precipitation; stockpiled to DG-8.7 (Strategy v3.1
             * s.8.2; fleet v9 s.16 MD-1 cargo). */
    }

    item def ThoriumChloride :> ThoriumCompound {
        doc /* ThCl4 by carbothermic chlorination in NaCl-KCl-MgCl2 carrier
             * salt (Strategy v3.1 s.8.2): PKT MSR fuel, and MD-3 cargo to the
             * SPA MSR (fleet v9 s.16). */
    }

    item def Reagent :> Material {
        doc /* In-situ reagents for the flowsheet (Decision Framework Rev D
             * s.1 transition 3: H2SO4 from troilite, Ca(OH)2 from anorthite). */
    }

    item def SulfuricAcid :> Reagent {
        doc /* H2SO4 from troilite (DG-5.3 pilot at SPA, DG-8.3 PKT plant;
             * SEL-REAGENT-001 Rev A). */
    }

    item def CalciumHydroxide :> Reagent {
        doc /* Ca(OH)2 from anorthite, replacing NaOH (DG-7.4). */
    }

    item def OxalicAcid :> Reagent {
        doc /* Oxalic acid by CO2 electroreduction - the DG-9.5 pilot line at
             * the PKT reagent plant (Decision Framework Rev D P9). */
    }

    item def Spares :> Material {
        doc /* ORU spares and Earth-irreducible items (Decision Framework Rev D
             * s.8) carried on Starship cargo and MD-1. */
    }

    item def CanisterPayload :> Material {
        doc /* What a mass driver canister or a Mk III ejection carries. The
             * canister hardware is SeleniteTransport::Canister; the payload is
             * typed here so the launch / receive ports carry a typed item. */
    }

    item def ReoPayload :> CanisterPayload {
        doc /* MD-2 PKT -> Earth: REO concentrate (ECN-020 s.4). */
        item reo : ReoConcentrate;
    }

    item def InterSiteCargo :> CanisterPayload {
        doc /* MD-1 SPA -> PKT: propellant, reagents, Fe-Ni, Th(OH)4, spares
             * (fleet v9 s.16; SeleniteTransport::MassDriverMd1). */
    }

    item def ThCl4Payload :> CanisterPayload {
        doc /* MD-3 PKT -> SPA: ThCl4 for the SPA MSR (fleet v9 s.16). */
        item fuel : ThoriumChloride;
    }

    item def PgmPayload :> CanisterPayload {
        doc /* MD-4 SPA -> Earth: PGM concentrate (fleet v9 s.16). */
        item pgm : PgmConcentrate;
    }

    item def ConcentratePayload :> CanisterPayload {
        doc /* MD-5 DRO -> SPA: asteroid concentrate (fleet v9 s.16). */
        item concentrate : AsteroidConcentrate;
    }

    item def MkIiiFeNiPayload :> CanisterPayload {
        doc /* PROBE Mk III LLO ejection to the EM catcher: Fe-Ni / PGM ore
             * (fleet v9 s.2.4, s.16). */
        item ore : AsteroidOre;
    }

    item def OxygenPayload :> CanisterPayload {
        doc /* O2 by-product lofted on MD-2 to the L1 depot (SEL-REQ-005; the
             * SeleniteTransport::MassDriverMd2 doc). TODO: the depot and this
             * stream are named only by SEL-REQ-005 (Wave 1) - no repository
             * document carries them (W4B-N4); source needed: ECN-019 Rev C. */
        item oxygen : Oxygen;
    }

    item def CrewTransit :> Material {
        doc /* Crew in the Crater Access Pod on the guide cable (SEL-CAP-001
             * Rev A updated; fleet v9 s.13.5). */
    }

    item def LoweredAsset :> Material {
        doc /* A MOLE-I or SATS+WEB assembly on the descent winch cable (fleet
             * v9 s.13.1, s.13.4). */
    }

    // =====================================================================
    // Data items (supervision, sensing, navigation)
    // =====================================================================

    abstract item def DataItem {
        doc /* Base for data flowing on supervision, sensor and navigation
             * links. */
    }

    item def SupervisionTelemetry :> DataItem {
        doc /* Status and alerts up the SENTINEL hierarchy (fleet v9 s.9.2
             * "autonomous alert escalation"; ARCHITECTURE_BASELINE.md s.7). */
    }

    item def SupervisionCommand :> DataItem {
        doc /* Commands down the hierarchy (Earth ops hub -> SENTINEL edge ->
             * fleet; SPA Ops Hub -> PKT at 0.5 s from P8). */
    }

    item def SensorReading :> DataItem {
        doc /* One sensor sample. Thresholds the readings are compared with are
             * attributes of the monitors (unbound, rule 3; fleet v9 s.9.2
             * quotes them). */
    }

    item def H2Reading :> SensorReading {
        doc /* Catalytic H2 sensor (cross-checked pair per station; ECN-014 via
             * fleet v9 s.9.2). */
        attribute ppm : Real;
    }

    item def PressureReading :> SensorReading {
        doc /* Line pressure transducer (ECN-014 via fleet v9 s.9.2). */
        attribute bar : Real;
    }

    item def UvFlameReading :> SensorReading {
        doc /* Solar-blind UV flame detector (ECN-014 via fleet v9 s.9.2). */
        attribute flameDetected : Boolean;
    }

    item def O2LineReading :> SensorReading {
        doc /* Habitat O2 supply line: hab-end pressure and flow (ECN-014 via
             * fleet v9 s.9.2). */
        attribute habEndPressure : Real;
        attribute flowRatio : Real;
    }

    item def CommsHeartbeat :> DataItem {
        doc /* The monitor-to-station heartbeat whose loss beyond the dead-man
             * timeout fails the valve closed (ECN-014 via fleet v9 s.9.2). */
    }

    item def HardwiredCloseSignal :> DataItem {
        doc /* The hardwired 24 VDC close signal to the pneumatic actuator
             * (ECN-014: NOT CAN bus or SpaceWire; fleet v9 s.9.2). */
    }

    item def LimitSwitchState :> DataItem {
        doc /* Valve limit switch confirming closure (ECN-014 via fleet v9
             * s.9.2). */
        attribute closed : Boolean;
    }

    item def CrewReopenCommand :> DataItem {
        doc /* The crew-only re-open command with its four preconditions
             * (ECN-014: H2 clear for the hold period, pressure low, no UV for
             * the hold period, verbal confirmation; fleet v9 s.9.2). */
        attribute h2Clear : Boolean;
        attribute pressureLow : Boolean;
        attribute noUvForHoldPeriod : Boolean;
        attribute verbalConfirmation : Boolean;
    }

    item def GatePassed :> DataItem {
        doc /* A decision-gate outcome used as a supervision-state trigger
             * (SeleniteGates); gateId is the DG id. */
        attribute gateId : String;
    }

    item def TetherFixReading :> DataItem {
        doc /* NAV-001 layer 1: drum payout range and two-axis roller angle
             * from the substation (fleet v9 s.4.1). */
    }

    item def SubstationEncoderReading :> DataItem {
        doc /* The DRM-040 two-axis angle encoder on the substation guide
             * roller, read on the substation and sent to the rover (fleet v9
             * s.4.1). */
    }

    item def OdometryReading :> DataItem {
        doc /* NAV-001 layer 2: the six wheel encoders (fleet v9 s.4.1). */
    }

    item def ImuReading :> DataItem {
        doc /* NAV-001 layer 3: MEMS IMU in the WEB (fleet v9 s.4.1). */
    }

    item def PositionEstimate :> DataItem {
        doc /* The Kalman-fused rover position (fleet v9 s.4.1). */
    }

    item def DrillGridUpdate :> DataItem {
        doc /* A drilled-cell mark in the per-sector drill grid (fleet v9
             * s.4.1). */
    }

    // =====================================================================
    // Port definitions (supplying direction; receivers use the conjugate)
    // =====================================================================

    port def PowerPort {
        doc /* Power supply side; a load is '~PowerPort'. */
        out item power : ElectricalPower;
    }

    port def WaterPort {
        doc /* Water out; a consumer is '~WaterPort'. */
        out item water : Water;
    }

    port def IcyRegolithPort {
        doc /* Icy regolith out (tramway container, drill product). */
        out item regolith : IcyRegolith;
    }

    port def HydrogenPort {
        doc /* Hydrogen out (electrolyser to cryocooler). */
        out item hydrogen : Hydrogen;
    }

    port def OxygenPort {
        doc /* Oxygen out (electrolyser to cryocooler; farm to habitat line). */
        out item oxygen : Oxygen;
    }

    port def PropellantPort {
        doc /* Propellant out; fuelled vehicles and the IZ farm inlet are
             * '~PropellantPort'. */
        out item propellant : Propellant;
    }

    port def OrePort {
        doc /* Ore or concentrate out; a hopper or feed inlet is '~OrePort'. */
        out item ore : OreFeed;
    }

    port def ReagentPort {
        doc /* Reagent out; a circuit's reagent inlet is '~ReagentPort'. */
        out item reagent : Reagent;
    }

    port def ProcessStreamPort {
        doc /* Flowsheet step product; the next step's feed is
             * '~ProcessStreamPort'. */
        out item stream : ProcessLiquor;
    }

    port def ProductPort {
        doc /* Finished product out of a line. */
        out item product : ProcessProduct;
    }

    port def ThoriumPort {
        doc /* Thorium compound out; an MSR fuel inlet is '~ThoriumPort'. */
        out item thorium : ThoriumCompound;
    }

    port def CargoPort {
        doc /* Starship cargo out of Earth (fleet, spares, Earth-irreducible
             * items; Decision Framework Rev D s.8); a landing zone is
             * '~CargoPort'. */
        out item cargo : Material;
    }

    port def CanisterPort {
        doc /* Mass driver launch side (a node's dispatch, a driver's
             * receiver output); the receiving side is '~CanisterPort'. */
        out item load : CanisterPayload;
    }

    port def SupervisionPort {
        doc /* The supervised side: telemetry out, commands in. The supervisor
             * is '~SupervisionPort'. */
        out item telemetry : SupervisionTelemetry;
        in item command : SupervisionCommand;
    }

    port def SensorPort {
        doc /* Sensor readings out of a station or line; the monitor's input
             * is '~SensorPort'. */
        out item reading : SensorReading;
    }

    port def HardwiredClosePort {
        doc /* The monitor's hardwired 24 VDC close output; the station's
             * actuator input is '~HardwiredClosePort'. */
        out item closeSignal : HardwiredCloseSignal;
        out item heartbeat : CommsHeartbeat;
    }

    port def LimitSwitchPort {
        doc /* Limit switch state out of the station. */
        out item state : LimitSwitchState;
    }

    port def TetherPort {
        doc /* Substation tether drum side: power and the encoder reading to
             * the rover, water and telemetry back (fleet v9 s.4.1, s.13.4).
             * The rover's tether receptacle is '~TetherPort'. */
        out item power : ElectricalPower;
        out item encoder : SubstationEncoderReading;
        in item water : Water;
        in item telemetry : SupervisionTelemetry;
    }

    port def BayonetTapPort {
        doc /* A tap socket (construction tap, SATS tap, branch cable tap,
             * substation tap - standardised 20 mm bayonet profile, ECN-013
             * R2 via fleet v9 s.4.1); the rover's motorised adapter
             * (SEL-MI-CON-001) is '~BayonetTapPort'. TODO: SEL-CON-001 Rev B
             * updated is not in the repository. */
        out item power : ElectricalPower;
    }

    port def ConstructionRadioPort {
        doc /* UHF construction link, network side: encoder readings and
             * commands to an untethered rover, telemetry back (ECN-013 RF
             * construction; ARCHITECTURE_BASELINE.md s.7 "UHF during
             * construction"). TODO: SEL-NAV-001 Rev A and ECN-013 are not in
             * the repository. */
        out item encoder : SubstationEncoderReading;
        out item command : SupervisionCommand;
        in item telemetry : SupervisionTelemetry;
    }

    port def GuideCablePort {
        doc /* CAP guide cable end: the pod transits between rim and floor. */
        out item transit : CrewTransit;
    }

    port def WinchCablePort {
        doc /* Descent winch cable end (rim); the floor landing is
             * '~WinchCablePort'. */
        out item asset : LoweredAsset;
    }

    // =====================================================================
    // Interface definitions
    // =====================================================================

    interface def PowerBus {
        doc /* Electrical supply to a load. */
        end supply : PowerPort;
        end load : ~PowerPort;
        flow supply.power to load.power;
    }

    interface def EclipseGatedPowerSupply :> PowerBus {
        doc /* SEL-ECN-023 s.3 (signed 6 Nov 2026) as an interface constraint:
             * the SPA power zone supplies an asteroid processing line on the
             * sunlit duty cycle - pausable steps run outside the eclipse, the
             * plant is oversized for the dark fraction and the restart losses
             * (SeleniteAnalysis::PlantOversizeFactor), and only the hold loads
             * are carried through the eclipse. The attributes are bound in
             * SeleniteConfigurations to the line's own pausableThroughEclipse
             * and holdLoadFraction; the hold fraction itself is UNBOUND (W4A-N3,
             * ASSUMED 0.25 in the evaluator) so the constraint is structural
             * until Wave 5 binds it. SEL-REQ-017 states the same rule as a
             * requirement on the line. */
        attribute pausableThroughEclipse : Boolean;
        attribute holdLoadFraction : Real;
        attribute eclipseCarriedFraction : Real;
        attribute oversizedForDarkFraction : Boolean;
        assert constraint holdLoadsOnlyThroughEclipse {
            doc /* A pausable line draws no more than its hold load through
                 * the eclipse and is oversized to keep its annual output. */
            not pausableThroughEclipse
                or (eclipseCarriedFraction == holdLoadFraction and oversizedForDarkFraction)
        }
    }

    interface def WaterTransfer {
        doc /* Product water from a source to a consumer. */
        end source : WaterPort;
        end consumer : ~WaterPort;
        flow source.water to consumer.water;
    }

    interface def IcyRegolithTransfer {
        doc /* Icy regolith from the floor to the rim (P3 tramway). */
        end source : IcyRegolithPort;
        end receiver : ~IcyRegolithPort;
        flow source.regolith to receiver.regolith;
    }

    interface def HydrogenTransfer {
        doc /* Electrolyser hydrogen to the cryocooler. */
        end source : HydrogenPort;
        end consumer : ~HydrogenPort;
        flow source.hydrogen to consumer.hydrogen;
    }

    interface def OxygenTransfer {
        doc /* Electrolyser or farm oxygen to the cryocooler, the habitat line
             * or the MD-2 loft. */
        end source : OxygenPort;
        end consumer : ~OxygenPort;
        flow source.oxygen to consumer.oxygen;
    }

    interface def PropellantTransfer {
        doc /* LH2 / LOX from the farm to the IZ and the fuelled vehicles. */
        end source : PropellantPort;
        end consumer : ~PropellantPort;
        flow source.propellant to consumer.propellant;
    }

    interface def OreTransfer {
        doc /* Ore or concentrate to the next stage (SKIP container, hauler
             * tip, conveyor hopper, beneficiation, circuit feed). */
        end source : OrePort;
        end receiver : ~OrePort;
        flow source.ore to receiver.ore;
    }

    interface def ReagentTransfer {
        doc /* Reagent plant to circuit. */
        end source : ReagentPort;
        end consumer : ~ReagentPort;
        flow source.reagent to consumer.reagent;
    }

    interface def ProcessStreamLink {
        doc /* One flowsheet step to the next. */
        end upstream : ProcessStreamPort;
        end downstream : ~ProcessStreamPort;
        flow upstream.stream to downstream.stream;
    }

    interface def ProductTransfer {
        doc /* A line's product to its export or re-use point. */
        end source : ProductPort;
        end receiver : ~ProductPort;
        flow source.product to receiver.product;
    }

    interface def ThoriumTransfer {
        doc /* Th(OH)4 / ThCl4 from the flowsheet to the fuel inlet or the
             * MD-3 canister. */
        end source : ThoriumPort;
        end consumer : ~ThoriumPort;
        flow source.thorium to consumer.thorium;
    }

    interface def CargoDelivery {
        doc /* Starship cargo from Earth to a landing zone (fleet v9 s.20.3;
             * Strategy v3.1 s.7.2). */
        end origin : CargoPort;
        end landing : ~CargoPort;
        flow origin.cargo to landing.cargo;
    }

    interface def CanisterLink {
        doc /* A mass driver leg: dispatch -> launcher input, or receiver
             * output -> catcher / recovery (ECN-020; fleet v9 s.16). */
        end launch : CanisterPort;
        end receive : ~CanisterPort;
        flow launch.load to receive.load;
    }

    interface def SupervisionLink {
        doc /* SENTINEL supervision between a supervisor and a supervised
             * tier or node (ARCHITECTURE_BASELINE.md s.7). */
        end supervised : SupervisionPort;
        end supervisor : ~SupervisionPort;
        flow supervised.telemetry to supervisor.telemetry;
        flow supervisor.command to supervised.command;
    }

    interface def SensorLink {
        doc /* Station or line sensors to the SENTINEL monitor (ECN-014 via
             * fleet v9 s.9.2). */
        end sensors : SensorPort;
        end monitor : ~SensorPort;
        flow sensors.reading to monitor.reading;
    }

    interface def HardwiredCloseLine {
        doc /* ECN-014 auto-close path: a hardwired 24 VDC signal from the
             * monitor to the pneumatic actuator, never over CAN bus or
             * SpaceWire; the heartbeat on the same loop is what the dead-man
             * watches (fleet v9 s.9.2). The constraint keeps the path
             * hardwired. */
        end monitor : HardwiredClosePort;
        end actuator : ~HardwiredClosePort;
        flow monitor.closeSignal to actuator.closeSignal;
        flow monitor.heartbeat to actuator.heartbeat;
        attribute hardwired : Boolean = true;
        attribute overFieldbus : Boolean = false;
        assert constraint closePathIsHardwired {
            doc /* ECN-014: NOT CAN bus or SpaceWire. */
            hardwired == true and overFieldbus == false
        }
    }

    interface def LimitSwitchLine {
        doc /* Closure confirmation from the station's limit switch to the
             * monitor (ECN-014 via fleet v9 s.9.2). */
        end station : LimitSwitchPort;
        end monitor : ~LimitSwitchPort;
        flow station.state to monitor.state;
    }

    interface def TetherLink {
        doc /* Substation drum to MOLE-I: power and the encoder fix down the
             * tether, water batches and telemetry back (fleet v9 s.4.1,
             * s.13.4). */
        end drum : TetherPort;
        end rover : ~TetherPort;
        flow drum.power to rover.power;
        flow drum.encoder to rover.encoder;
        flow rover.water to drum.water;
        flow rover.telemetry to drum.telemetry;
    }

    interface def BayonetCoupling {
        doc /* SEL-CON-001 / ECN-013 R2 bayonet engagement: the rover's
             * motorised adapter in a tap socket, 90 deg twist-lock, passive
             * detent hold (fleet v9 s.4.1). TODO: SEL-CON-001 Rev B updated is
             * not in the repository - engagement sequence not modelled. */
        end socket : BayonetTapPort;
        end adapter : ~BayonetTapPort;
        flow socket.power to adapter.power;
    }

    interface def ConstructionRadioLink {
        doc /* UHF link between the network (substation controller) and an
             * untethered MOLE-I during PSR network construction (ECN-013 RF
             * construction). */
        end network : ConstructionRadioPort;
        end rover : ~ConstructionRadioPort;
        flow network.encoder to rover.encoder;
        flow network.command to rover.command;
        flow rover.telemetry to network.telemetry;
    }

    interface def GuideCableLink {
        doc /* CAP guide cable between the rim anchor and the floor docking
             * pad. */
        end rim : GuideCablePort;
        end floor : ~GuideCablePort;
        flow rim.transit to floor.transit;
    }

    interface def WinchCableLink {
        doc /* Descent winch cable from the rim anchor to the floor. */
        end rim : WinchCablePort;
        end floor : ~WinchCablePort;
        flow rim.asset to floor.asset;
    }
}
