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

### 6. Observations W4B-N1 … W4B-N17 (recorded, not resolved)

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
