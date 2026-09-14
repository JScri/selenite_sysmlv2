# Wave 2 — Architecture and temporal skeleton

```
CHANGE LOG — 14 September 2026
Scope: Wave 2 — every element of docs/ARCHITECTURE_BASELINE.md §2–§7 as a
       phase-gated model element with provenance; no quantities beyond
       structure-defining counts. Fleet source diff (F2) performed first.
Baseline in:  Wave 1 Rev C (11 model files, exit 0, 8 SSM021 hints)
Baseline out: Wave 2 (13 model files, exit 0, 0 hints, 0 warnings;
              5 diagrams; document_map 45 rows advanced)
```

## 0. Start-up findings

**Inherited state:** `sysml-validate model --workspace . --all` → exit 0,
eight SSM021 hints (the enum-typed `activeFrom` attributes flagged in Rev C).
`tools/*.sh` had lost their executable bit and `.vscode/sysml/project.json`
was absent (hidden files dropped on upload) — both restored. The
`.github/workflows/` CI mentioned in the README is likewise absent and was
**not** re-created (it belongs at the git root and would run on Jason's
GitHub; noted in README for a decision).

**F2 — `SEL_ROBOT_FLEET_v9-1.docx` vs `SEL_ROBOT_FLEET_v9.md`.** Text was
extracted from both docx files (WordprocessingML → text, tables preserved)
and diffed against the markdown.

| Evidence | `v9-1.docx` | `v9.docx` | `v9.md` |
|---|---|---|---|
| Internal title | "v9.0 — All ECNs Applied (ECN-012 through ECN-019 Rev C)" | same | same |
| docx `created` metadata | 2026-04-05 13:12 | 2026-04-05 13:27 | — (April-12 folder) |
| Extracted lines | 237 | 295 | 730 |
| Mentions ECN-020 / parallel tracks / 523 t / 694,444 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 4 / 4 / 2 / 2 |
| Mass driver section | none (only a count row in App. B) | none; doc history says "5 mass drivers (~280 t YBCO lifetime)" | §16 "5 Drivers, 8 Tracks (ECN-020)" |
| PROBE-Scout §2.1, Mk II retrofit §4.2, ISRU §12, crater access §13 incl. CAP, power §18, IZ §19 | absent (per-class sections read "Specification unchanged from v8 §n") | partial | present |
| Document history last row | v9 (ECN-019) | v9 (ECN-019) | **v9 incl. ECN-020** |
| Fleet mentions of `SEL-SW-SENTINEL-001` | "Rev A + ECN-014" | — | (family winner is Rev B, ECN-014 folded in) |

**Verdict:** the `-1` in the filename is not a revision label. `v9-1.docx`
is the *earliest* of the three copies — a condensed v9.0 draft written
fifteen minutes before `v9.docx`, both pre-ECN-020. `v9.md` is the only copy
consistent with the ECN-019 Rev C + ECN-020 baseline the repository is
built on. Precedence rule 1 ("revision identifier wins") misfired.
**Modelled from `v9.md`.** Winner corrected in `docs/DOCUMENT_FAMILIES.md`,
`mapping/DOCUMENT_FAMILIES.csv`, `mapping/UPLOAD_LEDGER.csv`
(`v9-1.docx` → HISTORICAL) and `mapping/document_map.csv`. Jason to
confirm; nothing else in the repo depended on the docx.

Content deltas worth knowing (all three agree on the architecture — SKIP
retired P9, no PKT SKIPs, MOLE-S SPA-only, hauler Rev B at P8, catapults →
conveyors, Mk III SEP, M/C/S captures): PROBE Mk I era "P5–P8" (`v9-1`) vs
"P3–P11" (`v9.md`); MOLE-S "6 (P7+)" vs "6 (P6+)"; hauler table showing Rev A
92 % → Rev B ~57 % in-situ (the origin of F3 — 92 % is the superseded Rev A
column, not a competing Rev B value); SPA MSR "from Y50" in the P10 power
row of `v9.md` (feeds F5).

## 1. Phase-attribute idiom (decision deferred from Rev C)

`sysml-validate` 0.36.0 treats `enum def` as abstract: any usage typed
`: Phase` raises SSM021, *with or without* a default. Tested idioms
(scratch workspace): subsetting `:> Phase::P3` is clean but semantically
odd; `abstract attribute x : Phase` in an abstract definition with
`attribute redefines x = Phase::Pn` in concrete definitions is clean and
reads as intended. Adopted the latter; `SelenitePhases::PhaseGated` carries
`introducedIn` / `retiredIn [0..1]`; `retiredIn = null` = never retired.
Enum defs cannot hold attributes (SSM036), so year windows live in
`ProgrammeTimeline`. Documented in `CLAUDE_SYSML_CONTEXT.md` §4 and §7.

## 2. Changes by file (Australian spelling; sources as cited in each `doc`)

- **`model/Phases.sysml`** — `Phase` gains `P14plus`; new `PhaseGated`,
  `PhaseWindow`, `ProgrammeTimeline` with a year window per phase
  (ARCHITECTURE_BASELINE §1) and **F7** as `p6ToP7GapYears = 3` with a
  `doc` flag and an asserted constraint `p7.startYear - p6.endYear ==
  p6ToP7GapYears`. W2-N5 (P0 Y1 vs Y0) recorded.
- **`model/Sites.sysml`** — `SiteId` enum; `ProgrammeNode` (abstract,
  `existsFrom`); `LunarSite` (+`skipOperationsPermitted`, GIS provenance
  string, unbound lat/long for Wave 5); `CrewedHub` (SPA, P1, crewed P4,
  full config P7, crew ramp in doc), `PsrFloor` (P3), `AutonomousFactory`
  (PKT, P8, `temporaryCrewOnlyIn = P8`, site confirmed P7),
  `RelayConstellation` (P1, built P0, `relaySatellites[3]`),
  `PktRelaySatellite` (P8), `DroStation` (P12), `EarthNode` (P0).
  `siteName`/`operationalFrom` replaced by `nodeName`/`existsFrom`.
- **`model/RobotFleet.sysml`** — rewritten. `FleetAsset :> PhaseGated`
  with `homeSite : SiteId [1..*]`, `canEnterPsr`, `countedInOperationalFleet`;
  `SurfaceRobot`, `Spacecraft`. Classes: `ProbeScout` (P1, expendable, not
  counted), `ProbeMkI` (P3→P11, ISRU-fuelled P4), `ProbeMkII` (P9),
  `ProbeMkIII` (P11, never lands, zero ISRU propellant — asserted;
  prospecting P13), `Survey` (P1, orbital unit P5), `MoleI` → `MoleIMkI`
  (P3→P9) / `MoleIMkII` (P7) with `flightSoftware : MoleIFlightSoftware`
  (NAV-001 subsystem), `MoleS` (P2), `Sinter` (P2, PKT P8), `Arm` →
  `ArmC` (P2, PKT P8) / `ArmD` (P3, count locked to collars),
  `SentinelRover` (P2, PKT P8), `Skip` (P4→P9), `Dart` (P5, PKT-based P8),
  `Harvest` (P6), `Cap` (P4, anchors P1), `HaulerRevB` (P8, modes enum,
  swappable `frontEnd`), `RedirectTug` (P11, dev P10), `LaserAblationTruss`
  (P12). **Hard constraints asserted:** `moleSNeverAtPkt`, `skipNeverAtPkt`
  (`homeSite == spa`), `haulerPktOnly` (`homeSite == pkt`),
  `armNeverBelowRim` (`canEnterPsr == false`), `mkIiiNeverLands`.
  Flags recorded, not resolved: **F3** (hauler 92 % vs ~57 %), **F4**/VC-07
  (MOLE-I peak/decline), **F8** AUD-001/002/003 and VC-05/06. W2-N1, W2-N4.
- **`model/PsrNetwork.sysml`** (new) — `DescentWinch[2]` (IW-1/IW-2),
  `CrewWinch` (IW-CAP), `CapGuideCable`, `CableTramway` (P3, backup after),
  `TrunkCable`, `ClpJunction` (+`TrunkPump`), `Spine`, `Branch`
  (+`RetractionSpool`), `Substation` (SATS+WEB, `SubstationController`,
  tether drums, water manifold), `HeatedPipeline` (P4, dual trunk P5);
  `PsrNetwork` connects power path rim → trunk → CLP → spine → branch →
  substation and water path substation → pipeline → CLP pump → rim ISRU.
- **`model/Habitat.sysml`** — `Facility :> PhaseGated`; `HabitatComplex`
  (P3, crewed P4, H3 P7), `Eclss` (P4), `IsruPlant` (P3, self-sufficient
  P4; VEX, PEM, cryocooler, propellant farm, **`cryoTransferValveStations[4]`**
  per ECN-014), `IndustrialZone` (P3, **`dockingCollars[8]`**, beneficiation,
  EM catcher berth), `SpaLandingZone` (pads 1–2 P4, 3–4 P6), `Greenhouse`
  (P6), `CrewReturnVehicle` (P4, always fuelled), `PktTemporaryCrewHab`
  (P8→P8), `PktLandingZone` (P8). VC-04/12/13 recorded, unbound.
- **`model/Power.sysml`** — `PowerAsset :> PhaseGated`; `SolarArray` (P3),
  `FissionSurfacePower` (P4), `EclipseBattery` (P4), `ThoriumMSR` (P9,
  replaces PKT FSP P10, in-situ vessels P11; 100 MWe inherited from Wave 1;
  VC-09 recorded), **`SpaThoriumMSR` with `introducedIn` deliberately
  unbound — F5** (candidates P10 / P13 / Y105–Y140 recorded), `PktFspField`
  (P8→P10), `HubChargingStation` (P8), `SpaPowerZone`, `PktPowerSystem`.
- **`model/Processing.sysml`** — `ProcessingFacility :> PhaseGated`;
  `ProcessingCircuit` (P7), `BeneficiationPlant` (P5), `SpaProcessingFacility`
  (SEL-PROC-001, P7), `PktProcessingSpine` (P8), `ReagentPlant` (P8),
  `Foundry` (P8, at scale P9), `RelayDepot` (phase unbound — baseline gives
  none; TODO Wave 3), `ZeroCarbonFlowsheet` with nine connected
  `FlowsheetStep`s (eight steps + Th(OH)₄→ThCl₄), `ThUSeparationStage`
  (open), M/C/S-type processing lines at SPA (P12/P13/P14). ECN-021 stays
  out (stated in package doc).
- **`model/Transport.sysml`** — `LogisticsLink :> PhaseGated` with
  `operationalFrom`, `fromNode`, `toNode`; `MassDriver` (abstract) and
  **`MassDriverMd1..Md5`** with ECN-020 track counts 2/3/1/1/1 as both
  `trackCount` and `tracks[n]`; `MassDriverNetwork` enumerates the five and
  asserts `Σ trackCount == 8`; `Canister` (abstract) with six concrete kinds
  attached to their drivers; `EmCatcher` (P11); `SteelApronConveyor` (P9,
  Tier 3), `ConveyorNetwork` (P9, deploying P10), `HaulerRoadNetwork`
  (P8, Tier 1–2), `SkipHopLink` (P4→P9), `StarshipCargoLink` (P1, PKT P8),
  `ProbeReturnLink` (P3, Mk III stream P11), `PsrAccessLink` (P3).
  **Absent by design** asserted in a package-level `doc`: LLO tankers, PKT
  SKIPs, ore catapults (9,084 hubs), EM catapults for ore, MOLE-S at PKT,
  D2EHPA. **F6** recorded (MD-3/MD-4 numbering; ECN-020 carried). W2-N2, W2-N3.
- **`model/Software.sysml`** (new) — `SupervisionMode` (three modes),
  `SupervisionTier` (three tiers), `EarthOpsHubTier` / `SentinelEdgeTier` /
  `FleetTier`, `SentinelSystem` (supervision Earth until P3, SPA from P4, PKT
  from SPA at P8), ECN-014 `CryoValveMonitoringFunction` with
  `stationMonitors[4]`, `ValveStateTable` (11th table), `FaultPatternCatalogue`
  (#201–#206), `O2SupplyLineMonitoringFunction`; NAV-001 `MoleINavigation`
  (tether polar fix + odometry + IMU → Kalman fusion → drill grid; UHF link);
  `MoleIFlightSoftware` (SW-MOLEI-001 Rev D), `SubstationController`
  (SW-SUB-001 Rev C). Threshold attributes declared, unbound. Behaviour:
  Wave 4.
- **`model/ProgrammeRequirements.sysml`** — SEL-REQ-003 gains
  `require constraint { site.skipOperationsPermitted == false }` so it is
  machine-checkable; text otherwise unchanged.
- **`model/ProgrammeConfiguration.sysml`** — instance tree extended to every
  phase-gated element: timeline, Earth (Scout, Starship link), EML-2
  constellation, PKT relay, SPA hub (all facilities, thirteen fleet classes,
  three links, EM catcher inside the IZ), PSR floor (network + Mk I/Mk II),
  PKT factory (spine, reagent plant, foundry, relay depot, power, temporary
  hab, ELZ, conveyor and road networks, PKT fleet), DRO (truss, tug), mass
  driver network wired node-to-node, SENTINEL system wired to Earth, the PKT
  relay, the ISRU valve stations and the hab O₂ line. `satisfy` for
  SEL-REQ-002 **and** SEL-REQ-003. Wave 1 `circuitCountAtP14` /
  `msrUnitCountAtP14` values kept unaltered (rule 4) with VC-09 `doc` notes.
- **`model/SeleniteProgramme.sysml`** — package map updated.
- **`tools/render_diagrams.sh`** — `software_view` added; executable bits
  restored on both scripts. **`.vscode/sysml/project.json`** restored.
- **`diagrams/`** — all four regenerated plus `software_view.svg`.
- **`mapping/document_map.csv`** — 45 rows: all wave-2 `skeleton` and the
  wave-2 facility `planned` rows → `architected`; software rows (NAV-001,
  SW-MOLEI, SW-SENTINEL, SW-SUB, CON-001) `planned` → `skeleton` (structure
  exists, behaviour Wave 4); fleet winner row → `SEL_ROBOT_FLEET_v9.md`.
  Still `planned`: `selenite_lh2_transport_v4.pdf`, `selenite_value_chain_v16`,
  EVA contingency (not family winners read this wave).
- **`docs/DOCUMENT_FAMILIES.md`**, **`mapping/DOCUMENT_FAMILIES.csv`**,
  **`mapping/UPLOAD_LEDGER.csv`** — F2 resolved as above; W2-N1…N6 table.
- **`docs/MIGRATION_PLAN.md`**, **`docs/CLAUDE_SYSML_CONTEXT.md`**,
  **`README.md`** — wave state, idiom, tool-fact rows SSM021/SSM036/STYL007.

## 3. Conflicts flagged (recorded in `doc`, none resolved)

| Flag | Where | Disposition |
|---|---|---|
| F2 | ledgers, this log | **Resolved by evidence** — `v9.md` wins; awaiting Jason's confirmation |
| F3 | `HaulerRevB` | 92 % vs ~57 %; no fraction bound |
| F4 | `MoleI` | 355@P12 vs 320→50 in P11 vs ECON v1.3 profile; no count bound |
| F5 | `SpaThoriumMSR`, `SpaMsrIntroductionGate` | **Demand-gated** (Jason, 14 Sep): `introducedIn` unbound, gate as a calc, P10/P13 as candidates; final report v4 carries both |
| F6 | `MassDriverMd3` | ECN-020 numbering carried; scope label stale |
| F7 | `ProgrammeTimeline` | gap explicit (`p6ToP7GapYears = 3`), checked |
| F8 | `MoleS`, `Sinter`, `Skip`, `PemElectrolyserStack` | AUD-001/002/003/005–007 noted; no masses or powers bound |
| VC-04/05/06/07/09/10/12/13/14/21 | as cited | carried into Wave 5 |
| W2-N1…N6 | `DOCUMENT_FAMILIES.md` | new baseline-vs-fleet-v9 phase observations |

## 3a. Follow-ups after the PR opened (14 Sep 2026)

- **W2-N7 resolved, years authoritative.** `CTypeProcessingLine` P13 → P12,
  `STypeProcessingLine` P14 → P13; `ARCHITECTURE_BASELINE.md` §1 rows
  corrected; P14 now has no new asteroid arrival. Source documents untouched
  (obsolete by policy; the model is the source of truth).
- **F5 re-decided as demand-gated.** `SpaThoriumMSR.introducedIn` unbound
  again; `SeleniteAnalysis::SpaMsrIntroductionGate` added (demand vs non-MSR
  capability vs ThCl₄ supply vs feasibility); rule 5c added to
  `CLAUDE_SYSML_CONTEXT.md`. PKT first MSR stays P9 (DG-9.3), confirmed.
- **Final report v4 read as integrating reference** (Figures 2, 33, 34, 48):
  it carries both F5 readings, the W2-N7 drift, a pre-ECN-020 YBCO total
  (W2-N8), the F6 stale MD-3 label (W2-N9), ECN-021 process-water language
  (W2-N10) and a conditional P8 MSR prototype (W2-N11). Recorded, not modelled.
- CI workflow restored at the git root; `.vscode/` restored in the model folder.
- **Final report v4 read in full** (53 pages rendered). Two elements the
  baseline lacked were added: `StarshipReturnLink` (SPA→Earth Starship
  returns from P5, Jason's ruling; `retiredIn` derived from MD-4's
  `operationalFrom` in the configuration, W2-N15) and `MassDriverDemonstrator` (SPA rim, P7,
  W2-N17); `RimLogisticsPoint` added so the network has the rim CLP the
  report names (W2-N16). Drifts recorded as W2-N12…N14 (SURVEY concept,
  first-FSP phase, minor counts); F4 gains a fourth candidate (355 at P10).

## 4. Counts bound (the only numerics added this wave)

Relay satellites 3; mass drivers 5; tracks 2/3/1/1/1 = 8 (asserted);
docking collars 8; ECN-014 valve stations 4 (and monitors 4); descent
winches 2; ELZ pads 2 + 2; VALVE_STATE table ordinal 11; fault patterns
201–206; year windows per phase; `p6ToP7GapYears = 3`; `reopenPreconditionCount
= 4`. Everything else remains unbound for the Python layer.

## 5. Validation

`sysml-validate model --workspace . --all` (0.36.0): **13 files checked, no
problems found** — exit 0, zero errors, zero warnings, zero hints.
`tools/render_diagrams.sh` (sysml-diagram 0.41.0): exit 0, five SVGs.

## 6. Map updates

`mapping/document_map.csv`: 45 rows (listed in §2). Status totals now
architected 39 · skeleton 8 · planned 5 · python_port 5 · reference_only 16
· folded 3 · other 8.
