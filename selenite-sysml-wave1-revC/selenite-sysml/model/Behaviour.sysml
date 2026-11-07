package SeleniteBehaviour {
    doc /* Wave 4B (7 Nov 2026): the value chain as behaviour. One action def
         * per material stream, its steps as nested actions typed by step
         * action defs, every flow between them typed by a SeleniteInterfaces
         * item, and the stream phase-gated like every structural element
         * (the MaterialStream base carries introducedIn / retiredIn with the
         * SelenitePhases idiom; definitions bind the document phase, the
         * configuration rebinds each performed stream to the phase of the
         * element that performs it). The configuration
         * (SeleniteConfigurations) performs the streams and allocates every
         * step to the part that performs it. No throughput, mass or rate is
         * stated anywhere (rule 3: Wave 5 binds them from the Python layer).
         *
         * Streams by phase: PSR ice -> ISRU propellant (P3+); SPA KREEP by
         * SKIP -> beneficiation -> SPA processing -> export (P4/P5-P9, the
         * v14.1 scope); PKT KREEP by hauler and conveyor -> circuits -> REO
         * canisters -> MD-2 -> Earth, with the O2 by-product to the L1 depot
         * (P8+, the v15 scope); thorium -> Th(OH)4 -> ThCl4 -> MSR fuel (P8+,
         * MD-3 to SPA P9/P10); the asteroid streams - PROBE Mk I/II ore to the
         * IZ, Mk III canisters to the EM catcher, captured M / C / S-type
         * concentrate from the DRO truss over MD-5 - processed at SPA with
         * Fe-Ni and products to PKT over MD-1 (P3+, P11+, P12+ / P13+, the
         * v16 scope); and the MD-1 inter-site cargo.
         *
         * Sources IN the repository: SEL_ROBOT_FLEET_v9.md s.2.4-2.5, s.4.1
         * (mini-VEX water path), s.12, s.13.2-13.3, s.16, s.17.3, s.19;
         * SEL-T1.1-STRATEGY v3.1 s.1, s.2.4, s.5.1, s.6, s.8.2, s.10.1, s.11.1,
         * s.13; SEL-DECISION-001 Rev D s.3.2 (the three Fe-Ni flows), s.10.1;
         * SEL-ECN-020 s.2, s.4; ARCHITECTURE_BASELINE.md s.5-s.6. The value
         * chain family winners selenite_value_chain_v14_1.html (P0-P7),
         * v15.html (P7-P12) and v16.html (P13+) are NOT in the repository
         * (UPLOAD_LEDGER.csv entries only): the streams are modelled from the
         * documents above and each stream's doc names the value-chain file
         * that would confirm or extend it (TODO). SEL-REQ-005's L1 depot
         * stream has no repository source at all (W4B-N4). */

    private import ScalarValues::*;
    private import SeleniteInterfaces::*;
    private import SelenitePhases::*;

    // =====================================================================
    // Base
    // =====================================================================

    abstract action def MaterialStream {
        doc /* A material stream of the value chain, phase-gated with the
             * SelenitePhases idiom (abstract attributes, bound by redefinition
             * in concrete streams; rebound in the configuration to the
             * performing element's phase). retiredIn = null means the stream
             * runs to the end of the programme.
             * Source: ARCHITECTURE_BASELINE.md s.1 modelling note (the phase idiom of SelenitePhases). */
        abstract attribute introducedIn : Phase;
        abstract attribute retiredIn : Phase [0..1];
    }

    // =====================================================================
    // Step action definitions (one per unit operation or transfer)
    // =====================================================================

    action def DrillAndExtractIce {
        doc /* MOLE-I rotary-percussive drill and integrated mini-VEX thermal
             * extraction into the 50 L tank; the P3 tramway stream takes the
             * icy regolith instead (fleet v9 s.4.1, s.13.2). */
        out item water : Water;
        out item regolith : IcyRegolith;
    }

    action def BatchDumpToManifold {
        doc /* ECN-012 rear-nozzle batch dump into the substation manifold;
             * the transfer pump lifts the batch into the elevated branch pipe
             * (fleet v9 s.4.1). */
        in item water : Water;
        out item waterOut : Water;
    }

    action def LiftByTramway {
        doc /* P3 only: icy-regolith containers up the aerial tramway to the
             * rim VEX (fleet v9 s.13.2). */
        in item regolith : IcyRegolith;
        out item regolithOut : IcyRegolith;
    }

    action def PumpToRim {
        doc /* Branch pipe -> trunk pipe -> CLP trunk pump -> heated pipeline
             * -> rim ISRU (fleet v9 s.4.1, s.13.3). */
        in item water : Water;
        out item waterOut : Water;
    }

    action def DesorbVolatiles {
        doc /* Rim VEX thermal desorption of tramway regolith (P3) or pass-
             * through of piped water (fleet v9 s.12.1). */
        in item regolith : IcyRegolith;
        in item water : Water;
        out item waterOut : Water;
    }

    action def Electrolyse {
        doc /* PEM electrolysis of product water into H2 and O2 (fleet v9
             * s.12.2). */
        in item water : Water;
        out item hydrogen : Hydrogen;
        out item oxygen : Oxygen;
    }

    action def Liquefy {
        doc /* Cryocooler liquefaction of H2 and O2 into LH2 / LOX (fleet v9
             * s.12.3). */
        in item hydrogen : Hydrogen;
        in item oxygen : Oxygen;
        out item propellant : Propellant;
    }

    action def StoreInPropellantFarm {
        doc /* The cryogenic propellant farm adjacent to the IZ (fleet v9
             * s.12.4): propellant to the IZ collars and the fuelled fleet,
             * O2 to the habitat line. */
        in item propellant : Propellant;
        out item propellantOut : Propellant;
        out item oxygen : Oxygen;
    }

    action def FuelAtIz {
        doc /* Refuel a PROBE at its IZ collar, a SKIP or DART, from the farm
             * (Decision Framework Rev D s.3.2 step 7). */
        in item propellant : Propellant;
        out item propellantOut : Propellant;
    }

    action def SupplyHabitatOxygen {
        doc /* O2 to the habitat on the low-pressure line with double-block-
             * and-bleed isolation (Strategy v3.1 s.5.1); the surplus is 20-45x
             * crew demand (s.13). */
        in item oxygen : Oxygen;
        out item oxygenOut : Oxygen;
    }

    action def HopKreepBySkip {
        doc /* SKIP 100 km hops to SPA Basin KREEP exposures and back with a
             * KREEP container (fleet v9 s.7; Strategy v3.1 s.6). */
        in item propellant : Propellant;
        out item ore : KreepOre;
    }

    action def MineByHauler {
        doc /* Hauler Rev B mine mode at the PKT face, transport mode to the
             * conveyor hopper or spine (fleet v9 s.10.2-10.3). */
        out item ore : KreepOre;
    }

    action def ConveyToSpine {
        doc /* Steel apron conveyor Tier 3: branch -> trunk -> spine input
             * hopper (fleet v9 s.11; SEL-CONVEYOR-001 Rev A). */
        in item ore : KreepOre;
        out item oreOut : KreepOre;
    }

    action def Beneficiate {
        doc /* Physical beneficiation: jaw crusher, screens, magnetic drums -
             * 10x upgrade (Strategy v3.1 s.5.1 item 4, s.10.2 note). Also the
             * first stage for asteroid ore at SPA (Decision Framework Rev D
             * s.3.2). */
        in item ore : OreFeed;
        out item concentrate : KreepConcentrate;
    }

    action def AcidBake {
        doc /* Step 1: H2SO4 acid bake at 300 degC locking ~90-95 % of the Th
             * as insoluble ThP2O7 (Strategy v3.1 s.10.1, s.8.2). */
        in item concentrate : OreFeed;
        in item acid : SulfuricAcid;
        out item liquor : ProcessLiquor;
        out item thorium : ThoriumHydroxide;
    }

    action def PrecipitateWithCalciumHydroxide {
        doc /* Step 2: staged Ca(OH)2 precipitation removing Th / Fe / Al
             * (Strategy v3.1 s.10.1). */
        in item liquor : ProcessLiquor;
        in item lime : CalciumHydroxide;
        out item liquorOut : ProcessLiquor;
    }

    action def RemoveUraniumWithPeroxide {
        doc /* Step 3: U separation by H2O2 oxidation (Strategy v3.1 s.10.1). */
        in item liquor : ProcessLiquor;
        out item liquorOut : ProcessLiquor;
    }

    action def OxidiseCerium {
        doc /* Step 4: electrochemical Ce oxidation, zero reagent (Strategy
             * v3.1 s.10.1). */
        in item liquor : ProcessLiquor;
        out item liquorOut : ProcessLiquor;
    }

    action def SplitLreeHree {
        doc /* Steps 5-6: Eu reduction and the LREE / HREE double-sulfate split
             * (Strategy v3.1 s.10.1; ARCHITECTURE_BASELINE.md s.6 names the
             * (NH4)2SO4 LREE and H3PO4 HREE precipitations). */
        in item liquor : ProcessLiquor;
        out item lree : ProcessLiquor;
        out item hree : ProcessLiquor;
    }

    action def Calcine {
        doc /* Step 7: calcination to mixed oxide concentrates
             * (ARCHITECTURE_BASELINE.md s.6; Strategy v3.1 s.10.1 step 7
             * "concentrate shipment"). */
        in item lree : ProcessLiquor;
        in item hree : ProcessLiquor;
        out item reo : ReoConcentrate;
    }

    action def ChlorinateThorium {
        doc /* Th(OH)4 -> ThCl4 by carbothermic chlorination in NaCl-KCl-MgCl2
             * carrier salt (Strategy v3.1 s.8.2). */
        in item thorium : ThoriumHydroxide;
        out item fuel : ThoriumChloride;
    }

    action def KreepFlowsheet {
        doc /* The eight-step zero-carbon flowsheet as a flow (Strategy v3.1
             * s.10.1; ARCHITECTURE_BASELINE.md s.6), performed by
             * SeleniteProcessing::ZeroCarbonFlowsheet on both sites. No
             * D2EHPA (SEL-REQ-004). */
        in item concentrate : OreFeed;
        in item acid : SulfuricAcid;
        in item lime : CalciumHydroxide;
        out item reo : ReoConcentrate;
        out item thorium : ThoriumHydroxide;
        action acidBake : AcidBake;
        action precipitate : PrecipitateWithCalciumHydroxide;
        action removeUranium : RemoveUraniumWithPeroxide;
        action oxidiseCerium : OxidiseCerium;
        action split : SplitLreeHree;
        action calcine : Calcine;
        flow concentrate to acidBake.concentrate;
        flow acid to acidBake.acid;
        flow lime to precipitate.lime;
        flow acidBake.liquor to precipitate.liquor;
        flow acidBake.thorium to thorium;
        flow precipitate.liquorOut to removeUranium.liquor;
        flow removeUranium.liquorOut to oxidiseCerium.liquor;
        flow oxidiseCerium.liquorOut to split.liquor;
        flow split.lree to calcine.lree;
        flow split.hree to calcine.hree;
        flow calcine.reo to reo;
        first start;
        then acidBake;
        then precipitate;
        then removeUranium;
        then oxidiseCerium;
        then split;
        then calcine;
        then done;
    }

    action def LoadCanister {
        doc /* Load a mass driver canister with its typed payload (ECN-020;
             * fleet v9 s.16). */
        in item payload : CanisterPayload;
        out item load : CanisterPayload;
    }

    action def LaunchByMassDriver {
        doc /* One mass driver leg, launch to receiver (ECN-020 s.2). */
        in item load : CanisterPayload;
        out item loadOut : CanisterPayload;
    }

    action def CatchAtEmCatcher {
        doc /* SPA EM catcher receives MD-3 / MD-5 canisters and Mk III
             * ejections (fleet v9 s.16). */
        in item load : CanisterPayload;
        out item ore : OreFeed;
    }

    action def ReturnByStarship {
        doc /* SPA -> Earth concentrate in the Fe-Ni batch capsule on an ISRU-
             * fuelled Starship-class carrier, from the first export (DG-5.4)
             * until MD-4 (SeleniteTransport::StarshipReturnLink, W2-N15).
             * Source: final report Fig. 54; selenite_lh2_transport v4; Jason, 14 Sep 2026. */
        in item product : ProcessProduct;
        in item propellant : Propellant;
        out item productOut : ProcessProduct;
    }

    action def RecoverOnEarth {
        doc /* Earth arrival (DG-9.1 recovery option, D3 open) and the
             * individual SX in existing Earth plants (Strategy v3.1 s.10.1
             * step 8). */
        in item load : CanisterPayload;
    }

    action def FuelMsr {
        doc /* Autonomous ThCl4 fuel loading of a thorium MSR (Strategy v3.1
             * s.8.3 phase 3). */
        in item fuel : ThoriumChloride;
    }

    action def StockpileThoriumHydroxide {
        doc /* Th(OH)4 accumulated to the DG-8.7 assessment (Strategy v3.1
             * s.8.4 P8 row). */
        in item thorium : ThoriumHydroxide;
        out item thoriumOut : ThoriumHydroxide;
    }

    action def MineAsteroidByProbe {
        doc /* PROBE Mk I / II mission: depart SPA, collect ore (Mk II
             * beneficiates on the asteroid), return to an IZ collar
             * (Decision Framework Rev D s.3.2 steps 1-3). */
        in item propellant : Propellant;
        out item ore : AsteroidOre;
    }

    action def MineAsteroidByMkIii {
        doc /* PROBE Mk III: ion transit, EM anchoring, scraper mining, canister
             * ejection from LLO (Decision Framework Rev D s.3.2 Mk III flow). */
        out item load : MkIiiFeNiPayload;
    }

    action def AblateCapturedAsteroid {
        doc /* Laser Ablation Truss spiral ablation and ejecta capture at the
             * DRO body; concentrate to the MD-5 canisters (fleet v9 s.17.2;
             * Decision Framework Rev D s.3.2). */
        out item concentrate : AsteroidConcentrate;
    }

    action def SeparatePgm {
        doc /* PGM hydromet at SPA: magnetic separation, chlorination, leach
             * (fleet v9 s.17.3; Decision Framework Rev D s.3.2 step 5). */
        in item concentrate : OreFeed;
        out item pgm : PgmConcentrate;
        out item feNi : FeNiBulk;
    }

    action def PyrolyseAndSynthesise {
        doc /* C-type pyrolysis and Fischer-Tropsch: water, carbon, nitrogen,
             * hydrocarbons (fleet v9 s.17.3). Pausable through the eclipse on
             * the sunlit duty cycle (SEL-ECN-023, SEL-REQ-017). */
        in item concentrate : AsteroidConcentrate;
        out item volatiles : CTypeVolatiles;
        out item water : Water;
    }

    action def GrowSiliconAndRefineCopper {
        doc /* S-type Czochralski silicon (whole batches scheduled between
             * eclipses) and copper electrolysis (fleet v9 s.17.3; SEL-ECN-023). */
        in item concentrate : AsteroidConcentrate;
        out item silicon : Silicon;
        out item copper : Copper;
    }

    action def FabricateAtFoundry {
        doc /* PKT foundry: MRE, WAAM / EB welding of Fe-Ni, Al-Si, Fe-Si into
             * hauler, circuit and conveyor components (SEL-FAB-001 Rev A;
             * fleet v9 s.10.4). */
        in item feNi : FeNiBulk;
        out item metal : FoundryMetal;
    }

    action def ProduceReagents {
        doc /* Troilite H2SO4 and anorthite Ca(OH)2 (Decision Framework Rev D
             * s.1 transition 3; SEL-REAGENT-001 Rev A). */
        out item acid : SulfuricAcid;
        out item lime : CalciumHydroxide;
    }

    // =====================================================================
    // Streams
    // =====================================================================

    action def PsrIceToPropellant :> MaterialStream {
        doc /* PSR ice -> ISRU propellant, the binding constraint of P3-P11
             * (Strategy v3.1 s.1): MOLE-I drill and mini-VEX -> batch dump to
             * the substation manifold -> branch and trunk pipe -> CLP trunk
             * pump -> rim ISRU (VEX, PEM electrolysis, cryocooler, farm) ->
             * IZ fuelling and the habitat O2 line. P3 uses the tramway for
             * icy regolith before the pipeline (fleet v9 s.13.2). Source:
             * fleet v9 s.4.1, s.12, s.13; Strategy v3.1 s.1, s.5.1, s.13.
             * TODO: selenite_value_chain_v14_1.html (P0-P7 winner, not in the
             * repository) would confirm the P3 tramway branch. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        out item propellant : Propellant;
        out item habitatOxygen : Oxygen;
        action drill : DrillAndExtractIce;
        action dump : BatchDumpToManifold;
        action tramway : LiftByTramway;
        action pump : PumpToRim;
        action desorb : DesorbVolatiles;
        action electrolyse : Electrolyse;
        action liquefy : Liquefy;
        action store : StoreInPropellantFarm;
        action fuel : FuelAtIz;
        action habitatO2 : SupplyHabitatOxygen;
        flow drill.water to dump.water;
        flow drill.regolith to tramway.regolith;
        flow dump.waterOut to pump.water;
        flow pump.waterOut to desorb.water;
        flow tramway.regolithOut to desorb.regolith;
        flow desorb.waterOut to electrolyse.water;
        flow electrolyse.hydrogen to liquefy.hydrogen;
        flow electrolyse.oxygen to liquefy.oxygen;
        flow liquefy.propellant to store.propellant;
        flow store.propellantOut to fuel.propellant;
        flow fuel.propellantOut to propellant;
        flow store.oxygen to habitatO2.oxygen;
        flow habitatO2.oxygenOut to habitatOxygen;
        first start;
        then drill;
        succession drill then dump;
        succession drill then tramway;
        succession dump then pump;
        succession pump then desorb;
        succession tramway then desorb;
        succession desorb then electrolyse;
        succession electrolyse then liquefy;
        succession liquefy then store;
        succession store then fuel;
        succession store then habitatO2;
        succession fuel then done;
        succession habitatO2 then done;
    }

    action def SpaKreepToExport :> MaterialStream {
        doc /* SPA Basin KREEP by SKIP (P4, DG-2.2) -> beneficiation (P5,
             * DG-5.2) -> SPA processing facility flowsheet (P7, five circuits)
             * -> REO concentrate -> Starship return to Earth from the first
             * export (P5, DG-5.4) until MD-4. Between P5 and P7 the exported
             * batch is beneficiated concentrate (MilestoneSet m6 "KREEP REE
             * concentrate"). The stream ends with the SKIP retirement (P9,
             * DG-9.1 through MD-2's own phase). Source: fleet v9 s.7, s.14;
             * Strategy v3.1 s.6, s.10; ARCHITECTURE_BASELINE.md s.1 (P5, P7).
             * TODO: selenite_value_chain_v14_1.html (not in the repository). */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = Phase::P9;
        in item propellant : Propellant;
        in item acid : SulfuricAcid;
        in item lime : CalciumHydroxide;
        out item exported : ReoConcentrate;
        out item thorium : ThoriumHydroxide;
        action hop : HopKreepBySkip;
        action beneficiate : Beneficiate;
        action flowsheet : KreepFlowsheet;
        action returnToEarth : ReturnByStarship;
        flow propellant to hop.propellant;
        flow hop.ore to beneficiate.ore;
        flow beneficiate.concentrate to flowsheet.concentrate;
        flow acid to flowsheet.acid;
        flow lime to flowsheet.lime;
        flow flowsheet.reo to returnToEarth.product;
        flow flowsheet.thorium to thorium;
        flow returnToEarth.productOut to exported;
        first start;
        then hop;
        then beneficiate;
        then flowsheet;
        then returnToEarth;
        then done;
    }

    action def PktKreepToEarth :> MaterialStream {
        doc /* The PKT KREEP value chain (P8+): hauler mining Tier 1-2 and the
             * steel conveyor Tier 3 -> spine input -> circuits (the flowsheet
             * with in-situ reagents) -> REO concentrate -> canister -> MD-2
             * (P9, DG-9.1) -> Earth recovery and individual SX. The O2
             * by-product is lofted on MD-2 to the L1 depot (SEL-REQ-005; no
             * repository source, W4B-N4). Th(OH)4 leaves to ThoriumToMsrFuel.
             * Source: fleet v9 s.10-11, s.14, s.16; Strategy v3.1 s.7, s.9,
             * s.10; ECN-020 s.2.1, s.4; Decision Framework Rev D s.9. TODO:
             * selenite_value_chain_v15.html (P7-P12 winner, not in the
             * repository). */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        in item acid : SulfuricAcid;
        in item lime : CalciumHydroxide;
        in item byProductOxygen : Oxygen;
        out item thorium : ThoriumHydroxide;
        action mine : MineByHauler;
        action convey : ConveyToSpine;
        action flowsheet : KreepFlowsheet;
        action loadReo : LoadCanister;
        action launchMd2 : LaunchByMassDriver;
        action recover : RecoverOnEarth;
        action loadOxygen : LoadCanister;
        action launchOxygenMd2 : LaunchByMassDriver;
        flow mine.ore to convey.ore;
        flow convey.oreOut to flowsheet.concentrate;
        flow acid to flowsheet.acid;
        flow lime to flowsheet.lime;
        flow flowsheet.reo to loadReo.payload;
        flow flowsheet.thorium to thorium;
        flow loadReo.load to launchMd2.load;
        flow launchMd2.loadOut to recover.load;
        flow byProductOxygen to loadOxygen.payload;
        flow loadOxygen.load to launchOxygenMd2.load;
        first start;
        then mine;
        then convey;
        then flowsheet;
        then loadReo;
        then launchMd2;
        then recover;
        then done;
        succession start then loadOxygen;
        succession loadOxygen then launchOxygenMd2;
        succession launchOxygenMd2 then done;
        doc oxygenDoc /* The O2 loft is a parallel branch of the same MD-2
             * stream; its source and sink exist only in SEL-REQ-005 (W4B-N4). */
    }

    action def ThoriumToMsrFuel :> MaterialStream {
        doc /* Thorium stream: the acid bake's Th(OH)4 is stockpiled (DG-8.7),
             * chlorinated to ThCl4 and loaded into the PKT MSRs (P9, DG-9.3);
             * ThCl4 is mass-driven PKT -> SPA on MD-3 (P9/P10, DG-9.6) for the
             * SPA MSR. SPA's own Th(OH)4 (P7 facility) goes to PKT on MD-1
             * (fleet v9 s.16). Source: Strategy v3.1 s.8.2-8.4; fleet v9
             * s.16; Decision Framework Rev D P8-P9 gates. TODO:
             * selenite_value_chain_v15.html. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        in item thoriumFromPkt : ThoriumHydroxide;
        in item thoriumFromSpa : ThoriumHydroxide;
        action loadMd1 : LoadCanister;
        action launchMd1 : LaunchByMassDriver;
        action stockpile : StockpileThoriumHydroxide;
        action chlorinate : ChlorinateThorium;
        action fuelPkt : FuelMsr;
        action loadMd3 : LoadCanister;
        action launchMd3 : LaunchByMassDriver;
        action catchAtSpa : CatchAtEmCatcher;
        action fuelSpa : FuelMsr;
        flow thoriumFromSpa to loadMd1.payload;
        flow loadMd1.load to launchMd1.load;
        flow launchMd1.loadOut to stockpile.thorium;
        flow thoriumFromPkt to stockpile.thorium;
        flow stockpile.thoriumOut to chlorinate.thorium;
        flow chlorinate.fuel to fuelPkt.fuel;
        flow chlorinate.fuel to loadMd3.payload;
        flow loadMd3.load to launchMd3.load;
        flow launchMd3.loadOut to catchAtSpa.load;
        first start;
        succession start then loadMd1;
        succession loadMd1 then launchMd1;
        succession launchMd1 then stockpile;
        succession start then stockpile;
        succession stockpile then chlorinate;
        succession chlorinate then fuelPkt;
        succession chlorinate then loadMd3;
        succession loadMd3 then launchMd3;
        succession launchMd3 then catchAtSpa;
        succession catchAtSpa then fuelSpa;
        succession fuelPkt then done;
        succession fuelSpa then done;
        doc catchDoc /* catchAtSpa's ore output is not used on this stream: the
             * EM catcher delivers the ThCl4 canister, not ore (the shared
             * catcher action is typed for the asteroid streams). Wave 5 may
             * split the action. */
    }

    action def ProbeOreToPgmAndFeNi :> MaterialStream {
        doc /* The asteroid stream the PROBE fleet carries (P3+): Mk I / II
             * missions from the IZ return ore to a collar; ore through the
             * dust vestibule to beneficiation; PGM separated by chlorination
             * to Earth (Starship return, then MD-4 from DG-12.4); Fe-Ni bulk
             * mass-driven SPA -> PKT on MD-1 to the foundry. From P11 the
             * Mk III ejects canisters from LLO to the EM catcher instead of
             * landing. Source: Decision Framework Rev D s.3.2 (both flows);
             * fleet v9 s.2.2-2.5, s.19; Strategy v3.1 s.2.4. TODO:
             * selenite_value_chain_v14_1.html and v15.html. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        in item propellant : Propellant;
        out item pgm : PgmConcentrate;
        out item foundryMetal : FoundryMetal;
        action probeMission : MineAsteroidByProbe;
        action mkIiiMission : MineAsteroidByMkIii;
        action catchMkIii : CatchAtEmCatcher;
        action beneficiate : Beneficiate;
        action separate : SeparatePgm;
        action exportPgm : ReturnByStarship;
        action loadFeNi : LoadCanister;
        action launchMd1 : LaunchByMassDriver;
        action fabricate : FabricateAtFoundry;
        flow propellant to probeMission.propellant;
        flow probeMission.ore to beneficiate.ore;
        flow mkIiiMission.load to catchMkIii.load;
        flow catchMkIii.ore to beneficiate.ore;
        flow beneficiate.concentrate to separate.concentrate;
        flow separate.pgm to exportPgm.product;
        flow exportPgm.productOut to pgm;
        flow separate.feNi to loadFeNi.payload;
        flow loadFeNi.load to launchMd1.load;
        flow launchMd1.loadOut to fabricate.feNi;
        flow fabricate.metal to foundryMetal;
        first start;
        succession start then probeMission;
        succession start then mkIiiMission;
        succession probeMission then beneficiate;
        succession mkIiiMission then catchMkIii;
        succession catchMkIii then beneficiate;
        succession beneficiate then separate;
        succession separate then exportPgm;
        succession separate then loadFeNi;
        succession loadFeNi then launchMd1;
        succession launchMd1 then fabricate;
        succession exportPgm then done;
        succession fabricate then done;
        doc pgmExportDoc /* exportPgm is typed as the Starship return; from the
             * MD-4 operational phase (DG-12.4) the PGM leg is a mass driver
             * launch - the configuration's Starship return link retires then
             * (W2-N15 chain) and Wave 5 may rebind the step. */
    }

    action def CapturedAsteroidToProducts :> MaterialStream {
        doc /* Captured-asteroid streams (P12+, the v16 scope): the Laser
             * Ablation Truss at DRO -> MD-5 canisters -> SPA EM catcher -> the
             * M-type PGM hydromet (Y85), the C-type pyrolysis and Fischer-
             * Tropsch (Y105) and the S-type Czochralski and copper electrolysis
             * (Y125) lines at SPA - all on the sunlit duty cycle (SEL-ECN-023,
             * SEL-REQ-017) - with products mass-driven SPA -> PKT on MD-1
             * where circuit fabrication needs them (PTFE, Si, Cu) and C-type
             * water into the ISRU chain. Source: Decision Framework Rev D
             * s.3.2 (captured flow), s.10.1; fleet v9 s.17.2-17.3, s.16;
             * Strategy v3.1 s.11.1. TODO: selenite_value_chain_v16.html (P13+
             * winner, not in the repository). */
        attribute redefines introducedIn = Phase::P12;
        attribute redefines retiredIn = null;
        out item pgm : PgmConcentrate;
        out item water : Water;
        action ablate : AblateCapturedAsteroid;
        action loadMd5 : LoadCanister;
        action launchMd5 : LaunchByMassDriver;
        action catchAtSpa : CatchAtEmCatcher;
        action mTypeLine : SeparatePgm;
        action cTypeLine : PyrolyseAndSynthesise;
        action sTypeLine : GrowSiliconAndRefineCopper;
        action loadProductsMd1 : LoadCanister;
        action launchMd1 : LaunchByMassDriver;
        flow ablate.concentrate to loadMd5.payload;
        flow loadMd5.load to launchMd5.load;
        flow launchMd5.loadOut to catchAtSpa.load;
        flow catchAtSpa.ore to mTypeLine.concentrate;
        flow catchAtSpa.ore to cTypeLine.concentrate;
        flow catchAtSpa.ore to sTypeLine.concentrate;
        flow mTypeLine.pgm to pgm;
        flow mTypeLine.feNi to loadProductsMd1.payload;
        flow cTypeLine.volatiles to loadProductsMd1.payload;
        flow cTypeLine.water to water;
        flow sTypeLine.silicon to loadProductsMd1.payload;
        flow sTypeLine.copper to loadProductsMd1.payload;
        flow loadProductsMd1.load to launchMd1.load;
        first start;
        then ablate;
        then loadMd5;
        then launchMd5;
        then catchAtSpa;
        succession catchAtSpa then mTypeLine;
        succession catchAtSpa then cTypeLine;
        succession catchAtSpa then sTypeLine;
        succession mTypeLine then loadProductsMd1;
        succession cTypeLine then loadProductsMd1;
        succession sTypeLine then loadProductsMd1;
        succession loadProductsMd1 then launchMd1;
        succession launchMd1 then done;
        doc lineTypesDoc /* The three lines are typed by the step action defs;
             * the configuration allocates mTypeLine / cTypeLine / sTypeLine to
             * shackletonHub.mTypeLine / cTypeLine / sTypeLine, whose
             * introducedIn are the capture gates (DG-12.4 / 13.3 / 14.3), so
             * each branch is phase-gated by its performer. */
    }

    action def InterSiteCargoToPkt :> MaterialStream {
        doc /* MD-1 SPA -> PKT (P8, DG-8.0): propellant, reagents, Fe-Ni,
             * Th(OH)4, spares - the sole inter-site link (ECN-020 s.2.2; fleet
             * v9 s.16). The material legs are carried on the other streams;
             * this stream is the cargo leg itself with the PKT reagent plant's
             * day-one supply from SPA (DG-8.3 "85 % self-sufficiency from day
             * one" implies the balance arrives). Source: ECN-020 s.2.2; fleet
             * v9 s.16; Decision Framework Rev D DG-8.3. TODO:
             * selenite_value_chain_v15.html. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        in item propellant : Propellant;
        in item reagents : Reagent;
        in item spares : Spares;
        out item delivered : InterSiteCargo;
        action load : LoadCanister;
        action launch : LaunchByMassDriver;
        flow propellant to load.payload;
        flow reagents to load.payload;
        flow spares to load.payload;
        flow load.load to launch.load;
        flow launch.loadOut to delivered;
        first start;
        then load;
        then launch;
        then done;
    }

    action def ValueChain {
        doc /* The programme's value chain: every stream performed together,
             * with the cross-stream flows (propellant to the SKIPs and PROBEs,
             * SPA reagents and thorium to the PKT streams, C-type water back
             * into the ISRU chain, by-product oxygen to the MD-2 loft).
             * Performed once in SeleniteConfigurations::seleniteProgramme and
             * allocated there.
             * Source: ARCHITECTURE_BASELINE.md s.5-s.6; Decision Framework Rev D s.3.2. */
        action psrIceToPropellant : PsrIceToPropellant;
        action spaKreepToExport : SpaKreepToExport;
        action pktKreepToEarth : PktKreepToEarth;
        action thoriumToMsrFuel : ThoriumToMsrFuel;
        action probeOreToPgmAndFeNi : ProbeOreToPgmAndFeNi;
        action capturedAsteroidToProducts : CapturedAsteroidToProducts;
        action interSiteCargoToPkt : InterSiteCargoToPkt;
        action spaReagents : ProduceReagents;
        action pktReagents : ProduceReagents;
        flow psrIceToPropellant.propellant to spaKreepToExport.propellant;
        flow psrIceToPropellant.propellant to probeOreToPgmAndFeNi.propellant;
        flow psrIceToPropellant.propellant to interSiteCargoToPkt.propellant;
        flow psrIceToPropellant.habitatOxygen to pktKreepToEarth.byProductOxygen;
        flow spaReagents.acid to spaKreepToExport.acid;
        flow spaReagents.lime to spaKreepToExport.lime;
        flow spaReagents.acid to interSiteCargoToPkt.reagents;
        flow pktReagents.acid to pktKreepToEarth.acid;
        flow pktReagents.lime to pktKreepToEarth.lime;
        flow spaKreepToExport.thorium to thoriumToMsrFuel.thoriumFromSpa;
        flow pktKreepToEarth.thorium to thoriumToMsrFuel.thoriumFromPkt;
        doc crossFlowDoc /* The by-product oxygen flow re-uses the ISRU stream's
             * habitat O2 output as its typed source: the farm O2 is the only
             * O2 the repository documents produce (Strategy v3.1 s.13); which
             * site's O2 goes to the depot is unsourced (W4B-N4). */
    }
}
