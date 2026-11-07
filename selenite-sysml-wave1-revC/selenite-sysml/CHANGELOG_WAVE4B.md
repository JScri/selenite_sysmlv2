# Wave 4B — Behaviour, interfaces and software

## Delivery — 7 November 2026

```
CHANGE LOG — 7 November 2026 (Wave 4B: behaviour, interfaces and software)
Scope: the original Wave 4 scope of docs/MIGRATION_PLAN.md as amended by the
       verification session (docs/SESSION_BRIEF_wave4b_behaviour.md, s.0):
       the value chain as typed action flows, typed ports and an interface on
       every connection, SENTINEL and the ECN-014 valve auto-close as state
       machines with asserted constraints, NAV-001 fusion as a behaviour,
       SEL-REQ-017 from SEL-ECN-023, the verification carry-overs (a)-(g).
Baseline in:  main 0a2794e (Wave 4B brief amended); 16 model files, exit 0,
              zero hints; pytest 1,565 passed, 33 skipped; plan_check exit 0
              and byte-identical to the fixture (89 element bindings);
              scenario_check exit 0; seven diagrams.
Baseline out: 18 model files (SeleniteInterfaces and SeleniteBehaviour new),
              exit 0, zero hints; every connection an interface, every port
              typed (186 typed, 0 bare); tools/connect_check.py 746 endpoints
              resolved; pytest 1,565 passed, 33 skipped; plan_check exit 0,
              docs/PLAN_REGISTER.md regenerated (94 element bindings, the five
              new rows in s.4) and the fixture re-cut in the same commit;
              scenario_check exit 0, docs/SCENARIO_REGISTER.md untouched
              (Scenarios.sysml and Parameters.sysml unchanged); 25 diagrams
              (seven re-rendered, 18 new: eight general, five action-flow,
              five state-transition views). No committed parameter rebound,
              no decision changed, no ECN raised (SEL-ECN-027 is still free).
```

### 0. Start-up findings

- `npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0`: both pinned
  versions installed. `tools/validate.sh` on the inherited tree: 16 files,
  exit 0, zero hints. `pytest selenite-compute`: 1,565 passed, 33 skipped.
  `plan_check.py --quiet`: exit 0; default output byte-identical to
  `tests/fixtures/plan_check_stdout_wave3.txt`. `scenario_check.py --n 200
  --quiet`: exit 0. Nothing started until all were clean.
- **W4B-N1 — none of the wave's primary sources is in the repository.** The
  family winners `selenite_value_chain_v14_1.html` / `v15.html` / `v16.html`,
  `SEL-SW-SENTINEL-001_RevB.docx` (ECN-014 folded in),
  `SEL_SENTINEL_DESIGN_RevB.docx`, `SEL-SW-MOLEI-001_RevD.docx`,
  `SEL-SW-SUB-001_RevC.docx`, `SEL-NAV-001_MOLEI_Navigation_RevA.docx`,
  `SEL-CON-001_RevB_updated.docx`, `SEL-ECN-013_..._v1.docx`,
  `SEL-ISRU-001_RevD_updated.docx` with the `updated_SEL-CAD-ISRU-001` ECN-014
  amendment, and `SEL_EVA_CONTINGENCY_CORRECTED.docx` exist only as
  `mapping/UPLOAD_LEDGER.csv` entries (a Drive search for the file names found
  nothing either). Per the brief, the wave modelled what the repository
  documents support — `SEL_ROBOT_FLEET_v9.md` s.2.4–2.5, s.4.1 (NAV-001,
  ECN-012, ECN-013 adapter), s.9.2 (the ECN-014 extract), s.12, s.13, s.16,
  s.17.3, s.19; Strategy v3.1 s.1, s.2.4, s.5.1, s.8, s.10, s.11, s.13;
  Decision Framework Rev D s.3.2 (the three Fe-Ni flows), s.8, s.10.1;
  ECN-020; the architecture baseline s.5–s.7 — and every definition that
  rests on a missing winner carries a `TODO` naming the file. Verification
  item (d) (V-N19) is therefore answered the second way: the SEL-SW-SENTINEL-001
  Rev B extract **cannot** be brought into `docs/`; the ECN-014 literals
  (stations 4, monitors 4, preconditions 4, table ordinal 11, patterns
  201–206) now cite the ECN-014 extract that *is* in the repository, fleet v9
  s.9.2, and keep the TODO for the Rev B docx.

### 1. Decisions and resolutions recorded

| Item | Resolution |
|---|---|
| Behaviour mirrors the documents (brief rule) | Every transition and guard the repository documents state is modelled with its trigger (the ECN-014 table rows become transitions #201–#206; the ECN-012 "pre-heat at 90 % tank" is a guard on an unbound attribute). Where a document is silent the transition is declared with its trigger **UNBOUND** and a `doc` naming the source needed — SEL-SW-SENTINEL-001 Rev B for the SENTINEL mode table, the alert-clear condition, the Tier 1 stand-down and the O2 "until resolved"; SEL-SW-MOLEI-001 Rev D for the MOLE-I state triggers (**W4B-N7**). No control logic was invented. |
| Rule 3 on the ECN-014 thresholds | 100 / 1,000 ppm, 5 bar, 60 s, closure within 3 s, re-open at < 10 ppm for 5 min, < 3 bar, no UV for 10 min, O2 200 kPa and 2× flow, 10 Hz / 1 Hz polling, 8 rows, 90-day retention are **document constants with no computational source**. They stay UNBOUND attributes of the monitors and the state defs (quoted in the docs) — the first case where "Wave 5 binds from the Python layer" has no Python layer to bind from (**W4B-N6**, a rule for Jason / Wave 5). |
| Phase-gating the streams | `SeleniteBehaviour::MaterialStream` carries `introducedIn` / `retiredIn` with the Wave 2 idiom; each stream definition binds the document phase; the performed stream in the configuration rebinds both with `:>>` to the phase of its performing element (`shackletonHub.isru.introducedIn`, `skipHops.operationalFrom` / `retiredIn`, `pktFactory.processingSpine.introducedIn`, `probeMkI.introducedIn`, `droStation.existsFrom`, `md1.operationalFrom`). The `:>>` form is deliberate: `tools/plan_check.py` registers the `attribute redefines` bindings of parts, and a stream adds no information beyond its performer's row (**W4B-N15**: Wave 5 may add a stream register if it wants one). |
| Which bindings change the plan register | The brief allowed it for new gated elements: `SpaReagentPilot.introducedIn` → DG-5.3 and `.productionScaleFrom` → DG-7.4 (the two "TODO Wave 4" gated elements), `OxalicAcidLine.introducedIn` → DG-9.5, `SpaPgmHydromet.introducedIn` → DG-5.4 (W4B-N5) and `l1OxygenDepot.existsFrom` = `massDriverNetwork.md2.operationalFrom` (the StarshipReturnLink chain idiom). Register regenerated, fixture re-cut, rows in s.4 (**W4B-N14**). The scenario register reads none of them. |
| Carry-over (b): SEL-REQ-005 subject | `SeleniteSites::L1OxygenDepot` added (`SiteId::l1Depot`); `existsFrom` derived from MD-2's phase; `ProgrammeContext` retired (nothing used it). The requirement's constraint is the depot's identity (`nodeId == l1Depot`); "at scale" is a Wave 5 quantity (**W4B-N16**). **W4B-N4**: no repository document names the depot or the MD-2 O2 loft — not Strategy v3.1, not Decision Framework Rev D, not fleet v9, not ECN-020 — although SEL-REQ-005 has cited the first two since Wave 1; the committed source must be ECN-019 Rev C (not in the repository). Recorded in the requirement, the element, the item and the stream; a question for Jason. |
| Carry-over (c): gated elements that did not exist | `SeleniteProcessing::SpaReagentPilot` (DG-5.3 pilot, DG-7.4 production scale: one element, two phase attributes), `SeleniteProcessing::OxalicAcidLine` inside `ReagentPlant` (DG-9.5), `SelenitePsrNetwork::BayonetTapSocket` + `SeleniteFleet::BayonetAdapter` + `SeleniteInterfaces::BayonetCoupling` (the SEL-CON-001 connector, V-N7; the engagement sequence waits on the Rev B docx). `ThUSeparationStage` stays OPEN (brief s.6). `Gates.sysml` `gatedElements` now name the elements; no "TODO Wave 4" string remains in the model. |
| **W4B-N5 — a value-chain gap the behaviour exposed** | PROBE Mk I / II return Fe-Ni / PGM ore from P3 and the first export batch at Y10 (M6, DG-5.4) is "asteroid Ni-Fe/PGM + KREEP REE concentrate", yet the only PGM hydromet in the model was the M-type line (P12). Decision Framework Rev D s.10.1 states "SPA has existing PGM hydromet from P5+ PROBE heritage" and s.3.2 steps 4–6 describe it. `SeleniteProcessing::SpaPgmHydromet` added (P5, bound to DG-5.4; DG-5.4's `gatedElements` lists it) so the `SeparatePgm` step has a performer before the captured-asteroid era; the M-type line is documented as its scale-up. |
| Carry-over (e): hygiene | V-N3: every definition in the files this wave touched now names its source — 53 docs gained one (Habitat 7, Power 4, Processing 2, PsrNetwork 8, RobotFleet 5, Sites 4, Software 5, Transport 16, Phases 2) and the two new packages name one on every definition; 41 remain in files the wave did not touch (`Gates.sysml` 18, `Scenarios.sysml` 16, `ThroughputCalcs.sysml` 6, `ProgrammeParameters` 1 — W4B-N17). V-N8: `Milestone` is now `abstract part def` and the tree validates at zero hints, so the "why not" never arose (**W4B-N11**). V-N9: general views for Interfaces, Behaviour, Processing, Habitat, Transport, PsrNetwork, Power and Sites added to `tools/render_diagrams.sh` (Phases, Parameters and ThroughputCalcs stay unrendered — no behaviour was added there). V-N27: "App. C" → s.20.3 in `Phases.sysml` (×3), `ARCHITECTURE_BASELINE.md` and `DOCUMENT_FAMILIES.md`. Every "Wave 4" placeholder in `Software.sysml`, `Processing.sysml`, `Gates.sysml` and `ProgrammeRequirements.sysml` is either done or re-labelled with the wave and the missing file. |
| Carry-over (f): `prerequisites` / `gatedElements` | **Not promoted (W4B-N12).** `tools/plan_check.py` and `selenite.scenarios.modelio` read them as strings by name; the designed indirect cases (DG-7.1 "via", the DG-9.1 / DG-12.4 chained retirements through `md2` / `md4.operationalFrom`, DG-3.2 "partial") have no single link semantics a `dependency` or `satisfy` could carry without a convention; and a promotion that the parsers then had to follow would change the register for no new information. Carried to the Wave 5 brief with the convention sketched there (a `prerequisite` connection usage per edge with a `kind` attribute `direct | via | partial | chained`). |
| Carry-over (g): EVA contingency | **Wave 4B owns it (W4B-N13)**: `SEL_EVA_CONTINGENCY_CORRECTED.docx` is procedural behaviour (CAP descent, floor EVA limits, fleet v9 s.13.5), not a quantity. The file is not in the repository, so nothing was modelled; the map row moves to wave `4B`, status `planned`, with the TODO. |
| `connect` → interface | The configuration's 20 bare `connect`s and the 19 definition-level ones are gone: 105 interface usages in the configuration (ISRU chain, ore and concentrate, reagents, products, power — the three asteroid lines through `EclipseGatedPowerSupply` — the eleven mass driver legs including the MD-2 O2 loft, the Starship cargo and return legs, 31 supervision links, the ECN-014 sensor / hardwired-close / limit-switch lines) and 75 in the definitions; boundary ports of a composite are delegated with `bind`. The links a vehicle flies or drives (SKIP hops, PROBE returns, hauler roads) carry no ports — the vehicle connects, the link is the route, and the step is allocated to the vehicle. |
| Allocation | `perform action valueChain : ValueChain` once in `seleniteProgramme`; 56 `allocate` statements map every step to the part that performs it (MOLE-I Mk I and Mk II both drill; both chemical PROBE classes fly missions; the pump step to the trunk pump and the pipeline). |
| Th(OH)4 from SPA | fleet v9 s.16 lists Th(OH)4 as MD-1 cargo, so `ThoriumToMsrFuel` carries the SPA facility's thorium to the PKT stockpile over MD-1 as well as PKT's own. The SPA facility (P7) precedes MD-1 (P8): where SPA's P7 thorium goes for a phase is not stated by any document — recorded, not resolved (**W4B-N9**). |
| SEL-REQ-017 on the M-type line | ECN-023's subject is "the SPA asteroid lines"; the requirement is instantiated on all three, although Decision Framework s.10.1 sizes no MSR load for the M-type line and Wave 4A carried it "without a load". `pausableThroughEclipse = true` on all three (Wave 4A binding), so the constraint holds (**W4B-N10**). |
| SENTINEL rover first phase | Read while extracting ECN-014: fleet v9 s.9.2 gives SENTINEL "2 initial (P3) → 4 (P6+)" where `SeleniteFleet::SentinelRover` binds `introducedIn = P2` (ARCHITECTURE_BASELINE.md s.3) and cites s.9.2 for it. Recorded, not resolved (**W4B-N8**). |

### 2. Changes by file

- **`model/Interfaces.sysml`** (new) — package `SeleniteInterfaces`: 58
  item defs (`Material` → `IcyRegolith`, `Water`, `Hydrogen`, `Oxygen`,
  `Propellant`, `ElectricalPower`, `OreFeed` → `KreepOre` /
  `KreepConcentrate` / `AsteroidOre` / `AsteroidConcentrate`,
  `ProcessLiquor`, `ProcessProduct` → `ReoConcentrate` / `PgmConcentrate` /
  `FeNiBulk` / `CTypeVolatiles` / `Silicon` / `Copper` / `FoundryMetal`,
  `ThoriumCompound` → `ThoriumHydroxide` / `ThoriumChloride`, `Reagent` →
  `SulfuricAcid` / `CalciumHydroxide` / `OxalicAcid`, `Spares`,
  `CanisterPayload` → the six driver payloads + `OxygenPayload`,
  `CrewTransit`, `LoweredAsset`; `DataItem` → supervision telemetry and
  command, the ECN-014 readings, `CommsHeartbeat`, `HardwiredCloseSignal`,
  `LimitSwitchState`, `CrewReopenCommand`, `GatePassed`, the NAV-001
  readings and estimate); 24 port defs, one per medium with the supplying
  direction as the definition and `~` as the receiver; 25 interface defs
  with their flows (`PowerBus`, **`EclipseGatedPowerSupply`** with the
  ECN-023 assert, `WaterTransfer`, `IcyRegolithTransfer`,
  `HydrogenTransfer`, `OxygenTransfer`, `PropellantTransfer`, `OreTransfer`,
  `ReagentTransfer`, `ProcessStreamLink`, `ProductTransfer`,
  `ThoriumTransfer`, `CargoDelivery`, `CanisterLink`, `SupervisionLink`,
  `SensorLink`, **`HardwiredCloseLine`** with the "never a fieldbus"
  assert, `LimitSwitchLine`, `TetherLink`, `BayonetCoupling`,
  `ConstructionRadioLink`, `GuideCableLink`, `WinchCableLink`). The generic
  bases (`Material`, `OreFeed`, `ProcessProduct`, `ThoriumCompound`,
  `Reagent`, `CanisterPayload`, `SensorReading`) are concrete so a port typed
  by them is complete (SSM021).
- **`model/Behaviour.sysml`** (new) — package `SeleniteBehaviour`:
  `abstract action def MaterialStream` (phase-gated); 36 step action defs
  (drill / dump / tramway / pump / desorb / electrolyse / liquefy / store /
  fuel / habitat O2; SKIP hop, hauler mining, conveying, beneficiation; the
  eight flowsheet steps and `KreepFlowsheet` as a flow; canister load /
  launch / catch / recover, Starship return; thorium stockpile,
  chlorination, MSR fuelling; PROBE and Mk III missions, laser ablation;
  PGM separation, pyrolysis + Fischer-Tropsch, Czochralski + copper;
  foundry; reagents); seven streams — `PsrIceToPropellant` (P3+),
  `SpaKreepToExport` (P4–P9), `PktKreepToEarth` (P8+, with the MD-2 O2 loft
  branch), `ThoriumToMsrFuel` (P8+), `ProbeOreToPgmAndFeNi` (P3+, Mk III
  branch), `CapturedAsteroidToProducts` (P12+, M / C / S branches),
  `InterSiteCargoToPkt` (P8+) — every parameter an item of
  `SeleniteInterfaces`, every inter-step `flow` typed, successions
  explicit; `ValueChain` performing them with the cross-stream flows.
- **`model/Software.sysml`** (rewritten around the Wave 2 structure) —
  `Ecn014FaultPattern` (#201–#206), `AlertTier`; **state defs**
  `SupervisionLocation` (Earth → SPA Ops Hub on DG-4.1 → SPA supervising
  PKT on DG-8.1, triggered by `GatePassed` items), `SentinelOperatingModes`
  (three modes; the ECN-014 escalation is the one documented transition,
  four declared unbound), **`CryoValveStationStates`** (open / alert /
  autoClosed / failedClosed; the ECN-014 table rows as transitions #201,
  #202, #203, #206 with guards on the monitor's thresholds; `commsRestored`
  "Tier 2 on restoration"; `crewReopen` with the four preconditions;
  `alertCleared` unbound), `CryoMonitoringFunctionStates` (UV flame at any
  station → all four closed, Tier 1), `O2SupplyLineStates` (#204, #205;
  "until resolved" unbound), `MoleIOperatingStates` (standby / transit /
  drilling / batchDump; the ECN-012 pre-heat guard; the rest unbound);
  `ValveStationMonitor` exhibits the station machine with its thresholds
  bound (all UNBOUND) and asserts the dead-man logic (hardwired, no
  fieldbus, fails closed, crew-only re-open with four preconditions);
  `CryoValveMonitoringFunction` exhibits the function machine;
  `O2SupplyLineMonitoringFunction` exhibits the line machine; the tiers
  linked by `SupervisionLink` and the system's ports delegated with
  `bind`; **NAV-001**: `ReadTetherPolarFix`, `ReadWheelOdometry`,
  `ReadImu`, `KalmanUpdate`, `UpdateDrillGrid` and `NavigationFusion` (the
  three layers read in parallel, fused, the estimate marks the grid),
  performed by `MoleINavigation`, allocated step by step to its parts, the
  encoder reading flowing in from the tether port **and** from the
  `UhfConstructionLink` radio port — the ECN-013 dependency; `SubstationController`
  typed (supervision, construction radio) with its logic declared unmodelled
  (Rev C not in the repository).
- **`model/Habitat.sysml`** — every port typed; the ISRU chain connected
  through interfaces (VEX → electrolyser → cryocooler → farm → IZ / habitat
  O2); `DockingCollar` ore and fuelling ports; `CryoIsolationValveStation`
  asserts spring-return fail-closed, hardwired close, no fieldbus, limit-
  switch confirmation (`IsruCryoValveStation` binds the fail position
  `closed`); `HabitatComplex` carries the O2 line, its sensors and the
  auto-close input; landing zones carry `cargoLanding`; sources added to
  eight definitions.
- **`model/Processing.sysml`** — ports typed; circuits, facilities and
  lines carry ore / reagent / product / thorium ports; the flowsheet steps
  linked by `ProcessStreamLink`; **`SpaReagentPilot`**, **`OxalicAcidLine`**
  (inside `ReagentPlant`), **`SpaPgmHydromet`** added; `ThUSeparationStage`
  TODO re-labelled (waits on the preprint).
- **`model/Transport.sysml`** — drivers carry `launchInput` / `receiverOutput`
  / `powerIn` with the internal flow; each canister carries its typed
  payload item; `EmCatcher` typed; `ConveyorNetwork` delegated with `bind`
  and linked by `OreTransfer`; the SKIP / PROBE / hauler-road links
  documented as port-less routes; sources on 16 definitions.
- **`model/Power.sysml`** — `PowerAsset.powerOut`; MSR fuel inlets and
  process-heat port; `SpaPowerZone.asteroidLineSupply` (the ECN-023 supply
  end), `baseBus`, `psrTrunkFeed`; `PktPowerSystem` buses and the hauler
  charging bind; the generation aggregation noted as a Wave 5 binding.
- **`model/PsrNetwork.sysml`** — every port typed; power path, water path
  (through the CLP pump), tramway, winches and CAP guide cable as
  interfaces; `BayonetTapSocket` on branches and substations; `TetherDrum`
  / `WaterManifold` ports; the network's boundary ports delegated with
  `bind`; sources on eight definitions.
- **`model/RobotFleet.sysml`** — `FleetAsset.supervision`; propellant and
  ore ports on the PROBE classes, SKIP and DART; `ProbeMkIII.canisterEjection`;
  hauler ore and charging ports; `LaserAblationTruss.concentrateOut`;
  `MoleI` tether receptacle, `BayonetAdapter` part, construction radio bound
  to the navigation's link, `drillProduct`; sources on five definitions.
- **`model/Sites.sysml`** — `SiteId::l1Depot`; `LunarSite` canister dispatch
  / receipt, cargo landing and supervision ports; `CrewedHub.opsHubSupervisor`
  and `returnPayloadDispatch`; **`L1OxygenDepot`**; relay, DRO and Earth
  ports; sources on four definitions.
- **`model/Phases.sysml`** — V-N27 (×3); sources on `PhaseGated` and
  `PhaseWindow`.
- **`model/Gates.sysml`** — `Milestone` abstract (V-N8); `gatedElements` of
  DG-5.3, DG-5.4, DG-7.4, DG-9.1, DG-9.5 name the new elements; the package
  convention records why the strings were not promoted.
- **`model/ProgrammeRequirements.sysml`** — **SEL-REQ-017**
  `AsteroidProcessingPausableThroughEclipse` (abstract subject
  `AsteroidProcessingLine`, `require constraint { line.pausableThroughEclipse
  == true }`, the three ECN-023 clauses in its doc); SEL-REQ-005 subject
  `L1OxygenDepot` with `require constraint { depot.nodeId == SiteId::l1Depot }`;
  `ProgrammeContext` removed.
- **`model/ProgrammeConfiguration.sysml`** — the Wave 4B paragraph in the
  package doc; `reagentPilot`, `pgmHydromet`, `oxalicAcidLine` and
  `l1OxygenDepot` bound; every connection an interface usage (105), the
  three `EclipseGatedPowerSupply` usages binding the lines' own attributes;
  `perform action valueChain` with the seven stream phases rebound; 56
  allocations; `byProductsUsedAtScale` (SEL-REQ-005) and the three
  SEL-REQ-017 usages with `satisfy` links.
- **`model/SeleniteProgramme.sysml`** — package map and wave history.
- **`tools/connect_check.py`** (new) — resolves every `connect` / `bind` /
  `allocate` / `flow` endpoint through the definition and usage tree
  (W4B-N2); run in the CI `validate` job after `sysml-validate`.
- **`tools/render_diagrams.sh`** — 18 new views (s.5).
- **`docs/PLAN_REGISTER.md`**, **`selenite-compute/tests/fixtures/plan_check_stdout_wave3.txt`**
  — regenerated / re-cut for the five new bindings (s.4).
- **`mapping/document_map.csv`**, **`docs/MIGRATION_PLAN.md`**,
  **`docs/CLAUDE_SYSML_CONTEXT.md`** (s.4 idioms, s.7 tool facts, s.8),
  **`docs/DOCUMENT_FAMILIES.md`**, **`docs/ARCHITECTURE_BASELINE.md`**,
  **`README.md`** (both), **`docs/HUMAN_QUICKSTART.md`**,
  **`.github/workflows/validate.yml`**, **`docs/SESSION_BRIEF_wave4b_behaviour.md`**
  (banner), **`docs/SESSION_BRIEF_wave5_quantities.md`** (new) — s.7.

### 3. Idioms probed against sysml-validate 0.36.0 and sysml-diagram 0.42.0 (zero hints)

- `port def P { out item x : X; }` with the receiver `port p : ~P;`;
  `interface def L { end a : P; end b : ~P; flow a.x to b.x; }`;
  `interface u : L connect p.q to r.s { :>> attr = expr; }`; `bind outer = inner.port;`
  for boundary delegation; `flow portA.x to portB.x;` inside a part def.
- `action def A { in item x : X; out item y : Y; action s : S; flow x to s.x;
  first start; then s; then done; succession a then b; }`; `perform action
  v : V { action redefines s : S { :>> introducedIn = part.attr; } }`;
  `allocate v.s to part;` (nested paths on both sides).
- `state def S { entry; then a; state a; transition t first a accept Item if
  attr >= threshold then b; transition u first b then a { doc /* trigger
  unbound */ } }`; `exhibit state s : S { :>> attr = ownAttr; }`; `entry
  action name;` inside a state.
- Quirks (**W4B-N3**): a transition guard may reference an `accept` payload
  only when the payload is named with a single letter (`accept g : GatePassed
  if g.gateId == …` resolves; `accept reading : …` raises RES001), so the
  valve machines guard on state-def attributes bound by the exhibiting
  monitor instead; an action def may not name an `in` and an `out` parameter
  alike (RES017) — pass-through steps use an `…Out` output; a port typed by
  an abstract item def raises SSM021.
- **W4B-N2**: sysml-validate 0.36.0 does not resolve feature chains in
  `connect`, `bind`, `allocate` or `flow` — the configuration validated at
  zero hints while two interfaces named a `landingZone.cargoLanding` port that
  did not exist. `tools/connect_check.py` walks every endpoint (746 at
  delivery, all resolved) and runs in CI.
- Diagram CLI 0.42.0 renders `afv` (action flow) and `stv` (state transition)
  views as well as `gv` / `iv`: both used (s.5); no view was skipped.

### 4. Plan register (plan_check, 7 Nov 2026)

Default output changed only by the five new element bindings (89 → 94);
every gate row, every W3-R discrepancy row and the structural checks are
unchanged:

| Element.attribute | Type | Definition | Bound to | Verdict |
|---|---|---|---|---|
| shackletonHub.reagentPilot.introducedIn | SpaReagentPilot | P5 | DG-5.3 (P5, Y10) | def = gate |
| shackletonHub.reagentPilot.productionScaleFrom | SpaReagentPilot | P7 | DG-7.4 (P7, Y22; derives Y26 = P8, W3-R2) | def = gate |
| shackletonHub.pgmHydromet.introducedIn | SpaPgmHydromet | P5 | DG-5.4 (P5, Y10) | def = gate |
| pktFactory.reagentPlant.oxalicAcidLine.introducedIn | OxalicAcidLine | P9 | DG-9.5 (P9, Y42) | def = gate |
| l1OxygenDepot.existsFrom | L1OxygenDepot | unbound | massDriverNetwork.md2.operationalFrom | – |

`docs/SCENARIO_REGISTER.md` is untouched: `Scenarios.sysml` and
`Parameters.sysml` did not change and the scenario layer reads none of the
new elements.

### 5. Diagrams

`tools/render_diagrams.sh` now writes 25 views (sysml-diagram 0.42.0, exit
0): the seven of Wave 4A re-rendered; general views `interfaces_view`,
`behaviour_view`, `processing_view`, `habitat_view`, `transport_view`,
`psr_network_view`, `power_view`, `sites_view`; action-flow views
`value_chain_action_flow`, `psr_ice_to_propellant_action_flow`,
`pkt_kreep_to_earth_action_flow`, `captured_asteroid_action_flow`,
`nav001_fusion_action_flow`; state-transition views
`supervision_location_states`, `sentinel_modes_states`,
`cryo_valve_station_states`, `o2_supply_line_states`,
`molei_operating_states`. The interconnection view grew with the interface
usages (720 kB).

### 6. Observations W4B-N1 … W4B-N17 (recorded, not resolved; W4B-N18 … N28 in §9.4–9.5)

| # | Observation | Where |
|---|---|---|
| W4B-N1 | None of the wave's primary sources (value chain v14.1 / v15 / v16, SW-SENTINEL Rev B, SENTINEL design Rev B, SW-MOLEI Rev D, SW-SUB Rev C, NAV-001 Rev A, CON-001 Rev B, ECN-013 v1, ISRU-001 Rev D + CAD-ISRU ECN-014 amendment, EVA contingency) is in the repository; modelled from fleet v9, Strategy v3.1, Decision Framework Rev D, ECN-020; every dependent definition carries a TODO naming the file. The ECN-014 extract in `docs/` (V-N19) cannot be produced; fleet v9 s.9.2 is cited instead. | package docs; s.0 |
| W4B-N2 | sysml-validate 0.36.0 accepts unresolved feature chains in `connect` / `bind` / `allocate` / `flow` (two missing ports validated clean). `tools/connect_check.py` added to the toolchain and CI. | `tools/`, `validate.yml` |
| W4B-N3 | Validator quirks: single-letter `accept` payload names only in guards; RES017 on an `in` / `out` pair of the same name; SSM021 on ports typed by abstract item defs. | s.3 |
| W4B-N4 | The L1 / EML-2 O2 depot and the MD-2 O2 loft of SEL-REQ-005 appear in no repository document; the requirement's own citation (Strategy v3.1, Decision Framework Rev D) does not carry them. Source needed: ECN-019 Rev C. | `Sites.sysml`, `ProgrammeRequirements.sysml`, `Interfaces.sysml`, `Behaviour.sysml` |
| W4B-N5 | No SPA PGM hydromet existed before the M-type line (P12) although PROBE PGM is in the Y10 export batch; `SpaPgmHydromet` added from Decision Framework s.10.1 / s.3.2 and M6, bound to DG-5.4. | `Processing.sysml`, `Gates.sysml` |
| W4B-N6 | The ECN-014 thresholds, timings and polling rates are document constants with no computational source; left UNBOUND (rule 3). Wave 5 needs a rule for binding document constants that no Python module produces. | `Software.sysml` |
| W4B-N7 | Transitions declared with their trigger UNBOUND: SENTINEL mode changes except the ECN-014 escalation, the cryo alert clear, the Tier 1 stand-down, the O2 line "resolved", the MOLE-I state changes except the ECN-012 pre-heat guard. Sources needed: SEL-SW-SENTINEL-001 Rev B, SEL-SW-MOLEI-001 Rev D. | `Software.sysml` |
| W4B-N8 | fleet v9 s.9.2 "SENTINEL 2 initial (P3) → 4 (P6+)" against `SentinelRover.introducedIn = P2` (baseline s.3), which cites s.9.2. | `RobotFleet.sysml` |
| W4B-N9 | The SPA processing facility's Th(OH)4 (P7) has no stated destination before MD-1 (P8) carries it to PKT (fleet v9 s.16). | `Behaviour.sysml` |
| W4B-N10 | SEL-REQ-017 instantiated on the M-type line too (ECN-023 "the SPA asteroid lines"), although Decision Framework s.10.1 sizes no load for it. | `ProgrammeConfiguration.sysml` |
| W4B-N11 | `Milestone` made abstract validates at zero hints (V-N8 closed). | `Gates.sysml` |
| W4B-N12 | `prerequisites` / `gatedElements` kept as strings; promotion needs a convention for the indirect cases and a parser change — Wave 5 brief. | `Gates.sysml` |
| W4B-N13 | EVA contingency is Wave 4B scope (procedural behaviour); its file is absent, so the map row is `4B, planned` with a TODO. | `document_map.csv` |
| W4B-N14 | Plan register 89 → 94 element bindings (s.4); fixture re-cut; no gate or discrepancy row moved. | `PLAN_REGISTER.md`, fixture |
| W4B-N15 | Stream phases are bound to their performers with `:>>` and are therefore not plan-register rows; a stream register is a Wave 5 option. | `ProgrammeConfiguration.sysml` |
| W4B-N16 | SEL-REQ-005's constraint is the depot's identity only; "used at scale" is quantitative and waits for Wave 5. | `ProgrammeRequirements.sysml` |
| W4B-N17 | V-N3 residue after this wave: 41 definitions in files the wave did not touch still carry a doc with no named source — 18 in `Gates.sysml` (the gate docs quote the Decision Framework by the package convention; `GateEvaluability` and the three abstract gate bases), 16 in `Scenarios.sysml` (the option, decision and trade defs whose sources sit on their variants), 6 calc defs in `ThroughputCalcs.sysml`, and `ProgrammeParameters` (sources are per attribute). Counted by a wrap-tolerant script (94 → 42 → 41 over the wave); cite as those files are next touched. | `Gates.sysml`, `Scenarios.sysml`, `ThroughputCalcs.sysml` |

### 7. Validation, map and doc updates

`sysml-validate model --workspace . --all` (0.36.0): **18 files checked, no
problems found** — exit 0, zero hints. `tools/connect_check.py`: 746
endpoints, 0 unresolved. `tools/render_diagrams.sh` (0.42.0): 25 SVGs, exit
0. `pytest selenite-compute`: **1,565 passed, 33 skipped** (the three
byte-identity tests pass against the re-cut fixture and the regenerated
register). `tools/plan_check.py --quiet`: exit 0. `tools/scenario_check.py
--n 200 --quiet`: exit 0, all structural checks passed. Australian spelling
checked over the new and edited files.

`mapping/document_map.csv`: value chain v16 and the new v14.1 / v15 rows,
SEL-NAV-001, SEL-SW-MOLEI-001, SEL-SW-SENTINEL-001 → `behaviour_modelled`
(from repository documents; winner absent); SEL-SW-SUB-001 stays `skeleton`
(ports typed, logic awaits Rev C); SEL-CON-001 → `architected`; EVA
contingency → wave `4B`; ECN-013, ISRU-001 and SEL_SENTINEL_DESIGN rows
annotated; the Wave 4B brief → `delivered`; the Wave 5 brief and
`CHANGELOG`-independent `PLAN_REGISTER` row (94 bindings) updated.
`docs/MIGRATION_PLAN.md`: `behaviour_modelled` added to the status
vocabulary; Wave 4B delivered. `docs/CLAUDE_SYSML_CONTEXT.md`: s.4 gains the
interface, behaviour and state idioms and the `connect_check` step; s.7 the
W4B-N3 quirks; s.8 the Wave 4B state. `docs/DOCUMENT_FAMILIES.md`: V-N27
and the Wave 4B observations pointer. `docs/ARCHITECTURE_BASELINE.md`:
V-N27. `docs/HUMAN_QUICKSTART.md` and both READMEs: 25 views,
`connect_check`, the wave state. `docs/SESSION_BRIEF_wave5_quantities.md`
drafted from `CHANGELOG_VERIFICATION.md` s.4 "Wave 5 must start from" plus
this wave's carry-overs.

### 8. Open for Jason

Unchanged from `CHANGELOG_VERIFICATION.md` s.4 "Needs Jason's decision now"
(items 1–8: the default criterion, `spaMsrAvailabilityProbability`, the
hold-load and restart-loss assumptions, VC-22, the W3-N4 ramp, the D8 hauler
policy, D7 / D3, W3-N11 / F7 / F9 / F2 / W4A-N1 / VC-21 / DG-2.1 / V-N37 /
V-N38) — none resolved here. New questions, none of which changes a bound
value (no ECN drafted): **W4B-N4** (is the L1 O2 depot a committed element,
and where is it written?), **W4B-N8** (SENTINEL's first phase, P2 or P3),
**W4B-N6** (the rule for binding document constants that have no Python
source), and whether the missing Wave 4B winners can be added to `docs/` so
the TODOs can close.

## Addendum — 7 November 2026, same PR: the primary sources arrive

```
CHANGE LOG — 7 November 2026 (Wave 4B addendum: sources committed, behaviour
       bound from them)
Scope: Jason supplied every primary source the wave had modelled without
       (W4B-N1). Fold-in on the same branch before merge, as proposed: commit
       the sources, close the TODOs that named them, bind the transitions
       they give, record what they contradict. No committed parameter
       rebound, no decision changed, no ECN raised (SEL-ECN-027 still free).
Baseline in:  wave4b-behaviour 30ae15e (the delivery above).
Baseline out: 18 model files, exit 0, zero hints; tools/connect_check.py 796
              endpoints resolved (746 before); plan_check exit 0 and the
              default output byte-identical to the fixture (no binding
              changed - the register is untouched); scenario_check exit 0;
              pytest 1,565 passed, 33 skipped; 32 diagrams (25 + two
              action-flow and five state-transition views); 110 document-map
              rows (107 + 3). docs/ gains 23 originals under docs/sources/,
              19 markdown extracts, the three value-chain html and ECN-019
              Rev C. Two commits: the fold-in with the first seven
              verification verdicts applied, then the remaining four and the
              completeness critic (s.9.5, s.9.8).
```

### 9. The addendum

#### 9.1 Sources committed

Uploaded by Jason in six batches on 7 Nov 2026 and committed as the
precedence rules of `docs/DOCUMENT_FAMILIES.md` put them: originals under
`docs/sources/` (19 docx, the three value-chain html, the ECN-019 Rev C md
as uploaded), a markdown extract of each docx in `docs/` named after the
docx (tables flattened, figures dropped; the docx is the source of record),
`docs/ECN-019_Programme_Wide_Design_Revision.md` (Rev C, status PROPOSED —
confirmed from its header) and `docs/selenite_value_chain_v14_1.html` /
`v15` / `v16` as-is. Two uploads were already in the repository and were
byte-identical (`SELENITE_DECISION_FRAMEWORK_v4.md`, `SEL-ECN-020_…md`); one
copy of `SEL_MOLEI_DESIGN_v5.docx` was plain text, not a docx, and the valid
copy was kept; `SEL_SENTINEL_DESIGN_RevA_updated.docx` and
`SEL-CAP-001_CraterAccessPod_RevA.docx` are superseded by the Rev B / Rev A
updated winners in the same batch and are kept under `docs/sources/` mapped
`superseded` (the CAP pair differs only in its Source Docs row). Every
"NOT IN REPO" in `mapping/document_map.csv` is gone; the rows carry what
each source now binds.

#### 9.2 What the sources changed in the model

| Element | Before the sources | From the sources |
|---|---|---|
| Polar fix (NAV-001 layer 1) | `ReadTetherPolarFix` on the rover from a raw `SubstationEncoderReading` sent down the tether or over the UHF link | **Computed on the substation**: `ComputeTetherPolarFix` (drum payout + DRM-040 roller angle) performed by `SubstationController` from the new `DrumSensingPort` / `DrumSensingLine`, sent down the tether PLC as `TetherFixReading` (`TetherPort.fix` replaces `.encoder`), received by `ReceiveTetherPolarFix` in `NavigationFusion` (ECN-013 §3.2; SW-MOLEI Rev D ECN-013 note; SW-SUB Rev C ECN-013 addition) |
| Construction navigation | the encoder reading "over the UHF link" (not in any source) | `ConstructionNavigation`: tap-point count plus odometry offset; the UHF link carries position reports, power status and construction gate requests (`ConstructionRadioPort` re-typed; NAV-001 §4, ECN-013 §5) |
| `MoleIOperatingStates` | four states, one bound guard | eight states: the ECN-012 §3.3.2 sequence as `preHeat` → `retracting` → `dumping` → `purging` with its five triggers (tank fraction, tank full, docked, drain valve closed, purge hold elapsed), `construction` for the branch's first unit (MOLE-I design v5 §8, CON-001 §3), task assignment and safe-park from SW-SENTINEL §9.1 / §13.1, arrival at the lawn-mower cell from NAV-001 §2.4; IMU reset and grid upload as entry / exit actions of `dumping` (NAV-001 §2.3–2.4) |
| `MoleICommsStates` (new) | — | PLC on the permanent drum port, UHF on a construction tap or untethered, automatic switchover (ECN-013 §5); `plcOnlyOnPermanentTether` asserted |
| `TetherPortStates` (new) | controller "UNMODELLED" | breakers normally open, closed on command only after the connector is seated (make-before-break), open on power loss, hold while tether paths would cross (SW-SUB Rev C §6, §7.2; NAV-001 §3.3); `breakerFailSafe` asserted |
| `SentinelOperatingModes` | two ECN-014 escalations on a raw reading; three triggers unbound | escalation on a WARNING / EMERGENCY `AnomalyClassification`, return on `CrewDisposition` (design Rev B §4.3 steps 2, 4, 5); `toLocalAi` / `backToPlan` stay unbound (W4B-N21) |
| `AnomalyResponseWorkflow` (new) | — | the six steps detect → classify → isolate → diagnose and recommend → respond → verify and close, performed by `SentinelSystem` and allocated to the edge and Earth tiers (design Rev B §4.3); `AnomalySeverity`, `AuthorityLevel` enums; SPA / PKT EMERGENCY scopes and the GATE no-timeout rule as attributes and `gateNeedsHumanApproval` (design §5, §8.4) |
| `EarthContactStates` (new) | — | no-contact autonomous mode beyond the threshold (24 hr quoted, UNBOUND), GATE to local crew (P4+) or suspended (P2–P3), gate requests queued (SW-SENTINEL §12.2) |
| PKT escalation | — | `PktEscalationTier` T0–T3 and `relayNeverInSafetyPath` asserted on `SentinelEdgeTier` (SW-SENTINEL §15.2–15.3) |
| ECN-014 returns | `alertCleared`, `standDown`, `resolved` unbound | **still unbound** after the sources (the verification reversed a first binding to the step 6 ticket closing — §9.5): the only documented return is the per-station crew re-open with four sensor preconditions; the docs now name the sources read and the candidates |
| `CryoIsolationValveStation` | hardwired close, spring return, limit switch | plus the passive excess-flow check valve, burst disc, two catalytic sensors + UV, valves open in normal flow (ISRU-001 Rev D §7.4 amendment; CAD-ISRU ECN-014 amendment); `deadManFailClosed` extended |
| Habitat O2 line | double-block-and-bleed | the ECN-014 amendment's regulator, relief valve and SENTINEL-triggered fail-closed isolation valve in addition to the double-block-and-bleed, and the hab-entry check valve; "four independent barriers" quoted, not typed (`o2IsolationFailClosed`; ISRU-001 Rev D §8.2 amendment) |
| `BayonetEngagementStates` (new), `ConstructionTapHop` (new) | `BayonetAdapter` / `BayonetTapSocket` with TODOs | push-and-twist engage / disengage, detent hold without power asserted (`passiveDetentHold`); the six-step tap hop allocated to the adapter from `MoleIFlightSoftware` (CON-001 Rev B updated ECN-013 Rev 2 / Rev 3) |
| `CapMissionStates` (new) | `Cap` structural only | at rim (GATE go / no-go) → descending → docked at floor → floor ops (work limit UNBOUND, 2 h quoted; the limit ends floor work) → ingressing → ascending, SPE abort from every below-rim state (CAP-001 §2–3; EVA contingency §4.6, §4.8); `Cap` gains the guide-cable and floor-power ports and `dedicatedCrewRatedWinch`; `ClpJunction.capDockingPadTap` and `CrewWinch.phase1Reservations` (CAP-001 §5); two configuration interfaces (`capOnGuideCable`, `capFloorPower` — power flow only, the pod-side engagement is CAP-001 §8 item 4 OPEN) |
| Value-chain streams | TODO naming the html | docs name the html sections; topology confirmed; conflicts W4B-N20 |
| `L1OxygenDepot`, SEL-REQ-005, `OxygenPayload` | "source needed: ECN-019 Rev C" | ECN-019 Rev C names no depot; the verification found the source in SEL-ECON-001 Rev A revised §8.4 — LOX canisters on MD-2 to an Earth–Moon L1 fuel depot at P14+ (W4B-N18 corrected); its phase and "vented or stored" against the requirement and the derived `existsFrom` are W4B-N27; nothing rebound |

Rule 3 held throughout: the new UNBOUND attributes (`tankFullFraction`,
`purgeHoldMinutes`, `noContactThresholdHours`, `floorWorkLimitHours`) quote
their figures in the docs only and join the W4B-N6 list for Wave 5.
`plan_check` is byte-identical because no `attribute redefines … =
Phase::…` or gate binding was added or changed: the new part defs carry no
phase and the configuration gained interfaces only.

#### 9.3 Idioms probed (zero hints)

- An enum-typed attribute with no value (`tetherConnection :
  TetherConnectionType`) raises SSM021 like an abstract-typed port; declaring
  it `abstract attribute` in the state def, the item def and the exhibiting
  part clears it and the guards (`a.severity == AnomalySeverity::warning`,
  `tetherConnection != TetherConnectionType::permanentDrumPort`) resolve.
- `action x { in item … }` as a one-line body raises STYL007; an inline
  action usage with a body is also opaque to `tools/connect_check.py`
  ("has no type to descend"), so each workflow step is a typed action def.
- `flow` from a part's performed action output to a multi-valued part's port
  (`controller.tetherOut.fix` → `tetherDrums.tether.fix`) validates and
  resolves.

#### 9.4 Observations W4B-N18 … W4B-N23 and W4B-N27 … N28 (recorded, not resolved)

| # | Observation | Where |
|---|---|---|
| W4B-N18 | ECN-019 Rev C (now `docs/ECN-019_Programme_Wide_Design_Revision.md`, status PROPOSED) names no L1 / EML-2 O2 depot and no O2 loft: §18.1 gives MD-2 the single purpose "REO canisters" PKT → Earth; §15.1 makes SPA the P14+ "deep-space launch hub" (value chain v16 and ECON §8.2: "cislunar launch hub: propellant depot"). **Corrected by the verification (§9.5):** the depot's source is `docs/SEL-ECON-001_RevA_revised.md` §8.4 — PKT's by-product oxygen "liquefied using MSR-powered cryocoolers … loaded into Fe-Ni canisters … and launched via MD-2 to an Earth–Moon L1 orbital fuel depot", "a natural P14+ decision gate (DG-14.4)"; conclusion 9 the same. W4B-N4 is answered; what it opens is W4B-N27. | `Sites.sysml`, `ProgrammeRequirements.sysml`, `Interfaces.sysml`, `Behaviour.sysml` |
| W4B-N19 | SENTINEL first phase, more evidence for W4B-N8: SENTINEL design Rev B §7 places "2× inspection rovers" in its "P2–P3 (pre-crew)" row; its Rev A history line says "2 rovers (P3) → 4 (P7+)"; the fleet ECN-019 amendment table starts at P7 ("4+"); fleet v9 §9.2 says "2 initial (P3)". `SentinelRover.introducedIn = P2` kept. | `RobotFleet.sysml` |
| W4B-N20 | Value-chain html against the streams: v14.1 labels the Starship return "P7–P8" while its own Phase 2 panel has the first export batch at M116 / Y10 (the model binds DG-5.4); v15 carries the pre-ECN-020 "~303 t YBCO" (W3-N7 territory) and "MD-3 ThCl₄ (P10)" against ECN-019 §18.1 Y43 P9–P10 and the model's DG-9.6; v16 sends S-type Si / Cu "to PKT via MD-3" although MD-3 is PKT → SPA in ECN-019 §18.1 and the model carries them on MD-1. Nothing in the streams changed. | `Behaviour.sysml` |
| W4B-N21 | Neither SW-SENTINEL Rev B nor SENTINEL design Rev B carries a three-mode table: the modes are a baseline construct (ARCHITECTURE_BASELINE.md §7); the documents' behaviour is the five-level authority model and the anomaly workflow, now modelled beside the modes. `toLocalAi` / `backToPlan` stay unbound; Wave 5 may retire the mode machine in favour of `AuthorityLevel`. | `Software.sysml` |
| W4B-N22 | First recorded as "NAV-001 gives no cell-completion rule"; the verification (§9.5) found it in §3.2 (excavate to depth, retract, advance 2 m) and `moveOn` is bound on the depth. What stays unbound is the lateral offset on unexpected drill resistance (§2.2, no criterion). | `Software.sysml` |
| W4B-N23 | Three H₂ thresholds in three contexts, recorded for the W4B-N6 rule: SENTINEL design §4.3 WARNING "H₂ detected at > 10 ppm" (and a WARNING isolates — valve closure ≤ 30 s — where ECN-014's 100 ppm is alert-only); ECN-014 (fleet v9 §9.2, ISRU-001 Rev D §7.4) 100 ppm alert / 1,000 ppm auto-close at the valve stations; SW-SENTINEL §5 P0 EMERGENCY at 4 % LEL (40,000 ppm) with re-power at < 100 ppm. Different sensors and zones, but the design §4.3 isolate-on-WARNING rule and the ECN-014 alert-only row are a conflict at 10–100 ppm; recorded. | `Software.sysml` docs |
| W4B-N27 | SEL-ECON-001 Rev A revised §8.4 places the L1 depot at P14+ (DG-14.4) with PKT's oxygen "initially vented or stored" through P8–P14 — against SEL-REQ-005 "not vented or dumped" and against the configuration's derived `existsFrom = md2.operationalFrom` (P9, a model idiom bound before any document gave the depot a phase); and it makes PKT the "interplanetary fuel depot" where ECON §8.2 / ECN-019 §15.1 / v16 make SPA the launch hub with the propellant depot — two depot roles. Recorded; the binding and the requirement text unchanged (no decision changed); Jason's call. | `ProgrammeConfiguration.sysml`, `Sites.sysml`, `ProgrammeRequirements.sysml` |
| W4B-N28 | CAP floor work window: CAP-001 §2 "2-hour hard limit" / §6 "hard constraint on work duration" against the EVA contingency §4.5 "2–4 hr work window at floor". The machine's limit is UNBOUND; recorded. | `Software.sysml` |

#### 9.5 Adversarial verification

Every binding of the addendum was put to an adversarial reviewer with the
model element and the source sections, briefed to refute (eleven reviewers,
one per binding group, plus a completeness critic; the workflow transcript
is session material, the outcomes are here). Verdicts applied in this
commit (the first seven):

| Group | Verdict | Applied |
|---|---|---|
| ECN-012 dump sequence | overreach | pre-heat is not a pause: `arriveAtCellPreHeating` / `moveOnPreHeating` added so cells advance while the heater is on; `drainPipeHeaterOn` attribute; IMU-reset and grid-upload docs carry both NAV-001 phrasings (reset on retraction when taut vs at the dock; upload "after each dump" vs "within the dump window"); NAV-001 citations corrected (§2.1 proximity sensors, §3.1 grid, §3.2 strategy); ECN-012 §3.3.3 contradiction recorded (**W4B-N24**) |
| MOLE-I roles | misread | `moveOn` **is** in the source — NAV-001 §3.2 "excavates to depth … retracts the drill, advances 2 m": bound on `cellDrillDepthMm >= cellTargetDepthMm` (target UNBOUND, 400 mm quoted); W4B-N22 re-stated as the lateral-offset criterion of §2.2 (`offsetOnResistance`, unbound); `takeConstructionRole` made UNBOUND (an ordinal rule, not a command) |
| PLC / UHF switchover | overreach | a paraphrase presented as a quotation replaced by the real sentences; the untethered leg attributed to MOLE-I design v5 §4.8 and marked "not said to be automatic"; start-up mode noted as unstated; the `commsPath` attribute and enum dropped, the constraint now asserts the documented fact (`plcAvailableOffPermanentTether = false`) |
| Polar fix on the substation | supported | accuracy figures removed from the doc (left to the source), citations split by claim (computation ECN-013 §3.2, transmission SW-MOLEI Rev D §8.2, encoders NAV-001 §2.1, hardware SW-SUB Rev C); `succession tetherFix then fuse` dropped (the fix is low-rate and taut-only, fusion runs on odometry + IMU between fixes, the flow stays); `PowerStatusReport` added so the three UHF payloads NAV-001 §4 names each have an item; the downlink "command" noted as implied |
| Substation ports | misread | make-before-break is the **branch connector** row of SW-SUB Rev C §6, not the port breakers, and the MOLE-I drum tether is permanent: the `seated` state and the `DockingState` triggers removed; the breaker closes on the allocation command and opens on power loss or tether retraction (opening event UNBOUND); which connector the port breakers wait on is not stated (**W4B-N25**); the §3.3 hold's location noted as unstated |
| SENTINEL workflow and authority | overreach | the mode escalations restored to the Wave 4B ECN-014 form (`accept SensorReading`) with the severity-based candidate recorded, not bound — no document equates the three modes with the §4.3 severities or the tiers; `humanResolution` UNBOUND again (step 5 gives the disposition, not the return to plan); `respond` allocated to both the Earth and edge tiers; "MSR scram" → the source's "MSR emergency shutdown (control rod drop)" |
| No-contact mode, PKT tiers | overreach | three wordings of the no-contact rule recorded (SW §12.2 transfer-or-suspend by phase; design §3.7 suspend, crew may approve locally; design §9 transfer, no threshold — **W4B-N26**); T0–T3 wording aligned to §15.3; the §8.2 "Tier 1 / Tier 2" naming clash noted; queueing a `do action` |

The remaining four groups, applied in the second commit:

| Group | Verdict | Applied |
|---|---|---|
| Valve hardware | rule 3 | `o2LineIndependentBarriers = 4` was a document constant typed into an attribute — removed, "four independent barriers" quoted in the doc only, the constraint reduced to the fail-closed fact; the O2 line doc re-cut to §8.2's own structure (three new items "in addition to" the double-block-and-bleed, the hab-entry check valve named separately, the four not enumerated by the source); "two valves" → one ball valve plus one passive check valve; the hardwired / never-fieldbus / limit-switch facts re-cited to their only repository text (fleet v9 §9.2) rather than §7.4 |
| ECN-014 returns | overreach | the step 6 ticket closing is record-keeping after the recovery, and the only documented return is the crew re-open with sensor preconditions (fleet v9 §9.2; SW-SENTINEL §5 makes every recovery a crew command after a measured condition): `alertCleared`, `standDown` and `resolved` are **UNBOUND again**, their docs naming the sources read and the candidates; the item doc and the package doc corrected; W4B-N7 stays open for these three; the WARNING-isolates vs ECN-014 alert-only clash added to W4B-N23 |
| Depot and the quotations (W4B-N18–N20) | unsupported (N18) | **SEL-ECON-001 Rev A revised §8.4 names the depot** — a document the same addendum committed; W4B-N18 corrected in the model and here, W4B-N27 recorded (phase, "vented or stored", two depot roles), the ECN-019 §15.1 misattribution fixed ("deep-space launch hub"; "propellant depot" is v16 / ECON §8.2), `OxygenPayload` says LOX, the v15 quotation completed ("MD-3 ThCl₄ fuel (P10)"); N19 and the rest of N20 confirmed |
| Bayonet / CAP | misread | the work limit ends floor operations, it does not command ascent: `ingressing` state added, `workLimitReached` → `ingressing`, `workComplete` UNBOUND, `ingress` from `ingressing`, SPE abort from `ingressing` too; `egress` and `backAtRim` declared UNBOUND; the 2 h vs 2–4 h window recorded (W4B-N28); the CAP's floor-power coupling documented as power flow only (the pod-side engagement is CAP-001 §8 item 4, OPEN); the branch construction tap re-described as the plug at the free end of the spool tether (ECN-013 Rev 3), not a socket on the cable; the winch quotation restored verbatim; the disengage and abort docs re-sourced |

The completeness critic's findings, if any, are in §9.8.

| # | Observation (from the verification) | Where |
|---|---|---|
| W4B-N24 | ECN-012 §3.3.3 "the heater only runs during non-drilling phases (retraction and dump)" against its own §3.3.2 step 1 "continues drilling for final ~4.5 hours of fill" and ISRU-001 Rev D step D "Drilling continues normally". Modelled as the steps say; recorded. | `Software.sysml` |
| W4B-N25 | SW-SUB Rev C §6 states make-before-break for the branch connector (the substation's input socket) and "same spec" for the construction tap; the per-port breakers "close on command" by docking status (§7.2) with no connector named. The MOLE-I tether is permanent, so a dump docking is not a plug-in. Recorded. | `Software.sysml` |
| W4B-N26 | The no-contact rule in three wordings (SW-SENTINEL §12.2; SENTINEL design §3.7; design §9). The machine follows §12.2; the others are recorded in its doc. | `Software.sysml` |

#### 9.9 Decisions, 7 Nov 2026 (Jason, on the §9.7 questions)

- **By-product oxygen (W4B-N4 / N18 / N27) → SEL-ECN-027, signed and
  applied:** dump as little as possible; store excess; dump only when the
  storage capacity is used up; work out the feasible capacity under the
  base's space constraints and balance the oxygen as a closed circuit
  (Wave 5). Model: `ByProductOxygenStore` at SPA and PKT with
  `storeBeforeDump` asserted and `storageCapacity` UNBOUND, SEL-REQ-018
  satisfied on both, SEL-REQ-005 read as the policy, the PKT spine's
  by-product oxygen port. The depot's phase stays open for Wave 5.
- **SENTINEL first phase (W4B-N8 / N19):** left to the model — P2 kept
  (the design's own P2–P3 pre-crew row, the pre-crew structural clearance,
  `SentinelSystem.introducedIn = P2`); closed.
- **The §9.8 backlog:** welcomed; to be modelled in a future wave (Wave 6
  in `docs/MIGRATION_PLAN.md`).
- PR #13 merged on these decisions.

#### 9.8 Completeness critic

A final reviewer read `Software.sysml` in full, the behaviour elements of
the fleet, PSR network and habitat packages, and all twelve source extracts,
and asked what behaviour the sources describe that the model still does not
carry. Its answer is a backlog, not a defect list: the brief's build steps
(value-chain flows, SENTINEL states, ECN-014 auto-close, NAV-001 fusion,
the MOLE-I / substation / CAP operating behaviour the sources give) are met,
and the sources describe a great deal more control behaviour than those
steps asked for. One item was cheap and belonged to a machine this addendum
built, so it was added (`CapMissionStates.suitFailureRetreat`: floor ops →
docked at floor as shelter, CAP-001 §2 / EVA contingency §5, trigger
UNBOUND). The rest is recorded here for the next behaviour wave (the Wave 5
brief §0 points at it), grouped:

- **SENTINEL emergency responses and recoveries** (SW-SENTINEL §5; design
  §3.2, §3.6, §5): fire with 2-of-3 smoke / CO / thermal voting (H₂ does
  not vote), rapid depressurisation, explosive H₂ (zone power cut, vent,
  geofence), each with its crew-directed recovery; the H₂ patrol rule
  "a leak terminates all propellant ops immediately" as an interlock on
  the IZ and farm; the SPE shelter transition for the habitat (§3.6).
- **SENTINEL platform states** (SW §2.1, §3.1; design §2.1, §9): primary /
  hot-standby failover on a missed watchdog, the both-servers-fail degraded
  mode (robots on last schedule, ECLSS to local PID, GATE suspended), UHF
  relay failure, inspection rover loss, sensor failure handling.
- **Eclipse and power** (SW §8; design §3.3–3.4): the pre-eclipse sequence
  two hours before onset, eclipse declared at the solar threshold, the
  post-eclipse reverse, the five-tier load-shedding order, and the FSP
  authority rule (SENTINEL requests, FSP confirms, never controls nuclear
  parameters) — today only the ECN-023 interface constraint exists.
- **Fleet scheduling and geofence** (SW §9.1–9.2, §11; design §3.1, §3.6):
  priority tiers 1–5 and the four constraint checks; breach → stop, shared
  cell → lower priority yields; EVA boundary breach → halt all robots in
  zone; suit HUD warning and lockout radii.
- **GATE catalogue and the departure rule** (design §3.1, §5): "SENTINEL can
  HALT a departure autonomously but cannot AUTHORISE one"; ARM-C heavy lift,
  SINTER reactor restart, crew EVA authorisation, pre-crew structural
  clearance as gate waits; the structural clearance sweep (PASS / FAIL per
  structure, §3.5 / §7) as a rover behaviour feeding DG-3.1.
- **ISRU process interlocks** (SW §7; design §3.3; ISRU-001 Rev D §6.3,
  §7.3, §10, §13; CAD-ISRU §3): water-quality divert and electrolyser input
  closure (two auto-divert figures, SW / design vs CAD-ISRU — record), pipeline
  section isolation on a pressure deviation (SW §7 and design §3.3 state the
  criterion differently — record), trunk pump active / cold spare, cryo tank
  level management and the propellant allocation order, IZ propellant
  transfer interlocks (EVA only outside transfer periods).
- **SENTINEL rover and PKT node behaviour** (design §2.2, §4.1–4.2, §8.2–8.4;
  SW §15.2–15.4): patrol routes by priority and the optics-cleaning retreat;
  the T0–T3 protocol as transitions; node failure → sector absorption; hauler
  sector handoff; MSR start / stop as GATE via SPA; first-launch-of-day GATE;
  circuit auto-shutdown and QC restart; conveyor segment auto-stop; the
  expanded EXECUTE scope at PKT.
- **MOLE-I and substation detail** (NAV-001 §2.1, §3.2; ISRU-001 Rev D
  §4.2, §5.1.2; ECN-012 §5.2; SW-SUB Rev C §5, §7.2–9, §10, §13; MOLE-I
  design v5 §9): the lawn-mower turn-around at the tether limit and the
  resume-at-stored-cell rule after a dump; the docking handover from the
  polar fix to the proximity sensors; the mini-VEX batch cycle steps A–F;
  the interrupted-purge freeze and its recovery by the next pre-heat;
  substation-side dump coordination (funnel lip heater, manifold level →
  transfer pump); drum failure → spare-port replacement; the substation
  transit and anchoring sequence to "operational".
- **Construction and commissioning** (CON-001 Rev B §3.1–3.4, §5.1, §6–7;
  ECN-013 §4.2 and Rev 2 Stage B; NAV-001 §4): the branch build-out steps
  (pull, stake, tilt-up with the wheel-current latch confirmation, guy-wire
  passes, towing) with GATE 1–4 as waits on the construction gate requests
  the model already emits; the Stage B gate-only check; the CLP
  commissioning sequence (SATS+WEB pushed into place, tap engaged, bayonet
  seated).
- **CAP** (CAP-001 §2–3, §7; EVA contingency §6): the go / no-go
  preconditions as the guard of `goNoGo`; the pre-crew cargo-carrier use of
  the guide cable (recorded, flag only).
- **Prospecting** (ISRU-001 Rev D §2.3.3, §13): GATE 0 / 1 / 1B / 2 with the
  Cabeus fallback and the no-irreversible-actions hold between GATE 0 and
  GATE 2 — `Gates.sysml` territory.

Two further source conflicts the critic noted for the record: the pipeline
leak criterion (SW-SENTINEL §7 adjacent-sensor deviation vs design §3.3
percentage drop over a period) and the water-quality divert figures
(SW-SENTINEL §7 / design §3.3 / ISRU-001 §7.3 vs CAD-ISRU §3). Neither
changes a bound value.

#### 9.6 Map and doc updates

`mapping/document_map.csv`: every row of a committed source re-worded to
name its extract and what it binds (SW-SUB-001 `skeleton` →
`behaviour_modelled`; SEL_SENTINEL_DESIGN, CAP-001, EVA contingency,
CON-001 → `behaviour_modelled`; ECN-012 → wave 4B), three rows added
(fleet ECN-019 amendment `folded`, SENTINEL design Rev A+ and CAP-001 Rev A
`superseded`). `docs/DOCUMENT_FAMILIES.md`: the "Primary sources in the
repository" section. `docs/CLAUDE_SYSML_CONTEXT.md` §8, `docs/MIGRATION_PLAN.md`,
`docs/HUMAN_QUICKSTART.md` (32 views), both READMEs, the Wave 4B brief
banner and the Wave 5 brief §0 (counts, the W4B-N6 list, W4B-N7 mostly
closed, W4B-N18) updated. `tools/render_diagrams.sh` renders the seven new
views (`anomaly_workflow_action_flow`, `construction_tap_hop_action_flow`,
`earth_contact_states`, `molei_comms_states`, `bayonet_engagement_states`,
`tether_port_states`, `cap_mission_states`).

#### 9.7 Open for Jason (addendum)

W4B-N4 / N18 / N27 (SEL-REQ-005's L1 O2 depot now has its source, SEL-ECON-001
Rev A revised §8.4, which puts it at P14+ with the oxygen vented or stored
before — does the requirement's "not vented or dumped" stand, and should
`existsFrom` follow DG-14.4 rather than MD-2's phase?), W4B-N8 / N19
(SENTINEL's first phase), W4B-N28 (the CAP work window, 2 h or 2–4 h),
W4B-N25 (which connector the port breakers wait on),
W4B-N20 (should the value-chain html be re-cut to ECN-020 — YBCO, MD-3 phase,
MD-3 direction?), W4B-N21 (retire the three-mode machine?), W4B-N6 / N23
(the document-constant rule, with the three H₂ thresholds as its test
case). None changes a bound value.
