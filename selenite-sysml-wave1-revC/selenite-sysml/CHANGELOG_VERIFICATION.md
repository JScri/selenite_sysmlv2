# Verification — the model after Wave 4A (audit, not a build)

```
CHANGE LOG — 6 November 2026 (verification session, post-Wave-4A)
Scope: audit the model as it stands after Waves 1–3, the Python port, Wave 4A
       and SEL-ECN-023 against docs/SESSION_BRIEF_verification_post_wave4a.md:
       ten items, each recorded as pass or finding (V-N1 …) with its method.
       Value-neutral fixes applied; value-changing findings are draft ECNs
       (SEL-ECN-024 … 026) for Jason; nothing bound, thresholded, selected or
       decided was changed.
Baseline in:  main 1044bb5 (Wave 4B brief merged); 16 model files, exit 0, zero
              hints; pytest 1,565 passed, 33 skipped; plan_check exit 0;
              scenario_check exit 0.
Baseline out: 16 model files, exit 0, zero hints; pytest 1,565 passed, 33
              skipped; plan_check exit 0 and byte-identical by default; seven
              diagrams re-rendered (sysml-diagram 0.42.0); docs/SCENARIO_REGISTER.md
              regenerated at n = 2,000 (source strings and number formatting
              only — every number and recommendation unchanged); three draft
              ECNs; the consolidated open-items list for Waves 4B and 5 (§4).
```

Method note. The ten items were audited by one reader each (items 1–4, 9
and 10 by delegated auditors with a reproducibility brief; items 3–8 also
re-done by the session lead with scripts), and every finding applied below
was reproduced by the lead by hand — file:line on both sides, or the command
re-run — before the edit went in. The planned second-reader refutation pass
and the completeness critic did not complete (usage limit); their scope is
covered by the lead's re-checks, the structural checks and the test suite.
Goldens, `econ.py`, `verify.py`, `thermal.py`, `psr_layout.py` and their
tests were not touched (git log confirms no commit since the port).

## 0. Start-up (mandatory, in order) — all clean

| Check | Result |
|---|---|
| `npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0` | 0.36.0 / 0.42.0 installed |
| `tools/validate.sh` | 16 files checked, no problems found (exit 0, zero hints) |
| `pip install -e "./selenite-compute[test]"`; `pytest selenite-compute` | 1,565 passed, 33 skipped |
| `python tools/plan_check.py --quiet` | exit 0, all structural checks passed |
| `python tools/scenario_check.py --n 200 --quiet` | exit 0, all structural checks passed (largest SE 1.74 % at n = 200) |

Reading list read in the brief's order (context rules 3, 5a–5d, the plan,
the baseline, the families and flags, VALUE_CONFLICTS, the three wave
changelogs, ECN-022, ECN-023, both registers, the port changelog).

## 1. The ten items — method, passes and findings

Disposition codes: **fixed** = value-neutral edit applied this session;
**record** = true observation carried forward (no edit, or a doc note only);
**ECN** = would change a bound value, threshold, selection or decision —
drafted in `docs/SEL-ECN-02N_draft_*.md`, not applied.

### Item 1 — Model integrity

Method: parser over all 16 files (packages, imports, every `def` and its
`doc`, enum-typed usages, library-name shadowing); `document_map.csv` rows
checked against the elements in their `target_file`; all seven views
re-rendered with 0.42.0 and parsed (`<text>` labels: duplicates, gate count,
variations, requirements, fleet classes) and rasterised for inspection;
spelling grep over repo-authored files.

Pass: one `Selenite`-prefixed package per file, none reopened; flat
`model/`; every import group alphabetised case-insensitively; no shadowed
library name; all 22 enum-typed usages are `abstract attribute` bound with
`attribute redefines x = Enum::v`; gates_view carries all 81 gate usages,
scenarios_view D1–D8 with variants and the register, requirements view all
16, fleet view all 25 classes; six of seven SVGs byte-identical on re-render;
every `target_file` exists; ECN-022 / ECN-023 content present where the map
says `applied`; Australian spelling clean in the model.

| # | Finding | Disposition |
|---|---|---|
| V-N1 | `diagrams/programme_general_view.svg` was stale: the ECN-023 addendum changed the `d1` doc but did not re-render the view. | fixed (re-rendered; committed first) |
| V-N2 | 20 definitions carried no `doc` at all (rule 6): the four distribution subtypes, seven `…Option` defs and seven `…Trade` defs in `Scenarios.sysml`, `MassDriverId` in `Transport.sysml`. | fixed (docs added, each naming its source) |
| V-N3 | About 44 concrete definitions carry a descriptive doc that names no source (the source sits in the package doc or the owning def); 12 docs name a source without its revision. | record for 4B (the behaviour wave touches those files); four unambiguous revision-less citations fixed now (`SEL-CAD-PZ-001 Rev A`, `SEL-NAV-001 Rev A` ×2, `VERIFY v5.0`) |
| V-N4 | Four doc comments still said "ECN-022 stands until Jason signs ECN-023" / "declared 1.0" after the signature (`Scenarios.sysml` ×3, `ThroughputCalcs.sysml`). | fixed |
| V-N5 | `SeleniteProgramme.sysml` package map and wave history omitted `SeleniteScenarios` and Wave 4A. | fixed |
| V-N6 | The ECN-022 decisions were cited as "ECN (Jason, 19 Sep 2026)" without the number in five docs (`Gates` ×2, `Transport`, `ProgrammeConfiguration`, `Parameters`). | fixed (`SEL-ECN-022 s.2.1` / `s.2.2`) |
| V-N7 | `document_map.csv`: row 65 (LH₂ transport) unquoted comma → 9 columns; six rows with the wrong `target_package` (Substation, PIPE-001, ECN-012 → `SelenitePsrNetwork`; ELZ-001, IZ-001 → `SeleniteHabitat`); SEL-CON-001 marked `skeleton` with no element in the model. | fixed (quoted; packages corrected; CON-001 → `4B, planned`) |
| V-N8 | `Milestone` is a concrete `part def` holding `abstract attribute declaredPhase : Phase` — the SSM021 idiom used outside an abstract def (validator-clean). | record, 4B |
| V-N9 | `tools/render_diagrams.sh` renders six of sixteen files; no view of Transport, PsrNetwork, Processing, Power, Habitat, Sites, Phases, Parameters, ThroughputCalcs. | record, 4B |
| V-N10 | `UncertaintyRegister` owns its own `part parameters : ProgrammeParameters`, never bound to `seleniteProgramme.parameters` (the interconnection view shows two instances). | record, Wave 5 (bind before quantities) |

### Item 2 — Provenance audit

Method: every bound value in `ProgrammeParameters` (about 110) and all 38
`GateThresholds` opened against its cited source (`docs/`, the fleet
authority at the git root, `verify.py` / `econ.py` / `psr_layout.py` /
`plan_vectors.py` / `eclipse.py` and the MATLAB originals); arithmetic
parentheticals recomputed; `psr_layout.workspace()` run (124 × 5 = 620,
47 %); rule 5d: every Low/High twin and every sampled register entry traced
to a source stating the range, and `Scenarios.sysml` grepped for retyped
literals (none — all bindings by reference).

Pass: every `GateThresholds` number and unit matches the Decision Framework
Rev D gate text verbatim; every ECON/VERIFY transcription (battery 250 Wh/kg
and 1.2 margin, FSP 40 kW / 6,600 kg, panels 3 kg/m², MSR 50,000 kg and 0.3
floor, illumination 0.85, 72 h, the full v1.4 tornado) equals the Python
layer exactly; Gläser 2014 figures self-consistent (1 − 0.880 = 0.120,
1 − 0.771 = 0.229; 3–5 days = 72–120 h); 708.7 h, 1.293, 0.4667 / 1.1667,
73 / 28 / 8 kg, 1.2 / 28,000 / 400, 2025, 180, 75 / 95 / 115 (+10) all
supported; 19 of 20 sampled ranges have a source stating the range. **No
bound value disagrees with its source.**

| # | Finding | Disposition |
|---|---|---|
| V-N11 | Nine citation strings wrong while the values are right: Th grade quote is fleet v9 **s.8** (not s.11); the 90–95 % acid-bake capture is **Strategy v3.1 s.8.2** (DG-7.2 gives the mechanism only); "MSR 30 %" is Strategy **s.15.2** / the Rev D P14 Earth-fraction table (Rev D has no s.15); "~310 positions" is fleet v9 **s.4.3** (not s.4.1); ">500 ppm" is not in fleet v9 s.20.3 (it is the scaling page, the extended timeline and final report Figs 2 / 33); crew 20 is the Rev D P12 end-state and Strategy s.5.1, not SEL-REQ-002 / s.5.2 / HAB-001; the ECON "knots" Y121 / Y152 are plan_check crossing years (knots are Y120 / Y140); the 92 % hauler figure is the superseded SEL-HAULER-001 Rev A column, not fleet v9 (which says ~57 %). | fixed (`Parameters.sysml`, `Scenarios.sysml` source strings, `Gates.sysml` DG-7.1) |
| V-N12 | ECN-023 §5 / §5a and `Parameters.sysml` say the plan register "now reads 1,156 FSP max"; it reads **1,129** (plan_check at the nominal inputs, 132 + 0.18 × 250,000 = 45,120 kW → ⌈45,132 / 40⌉). 1,156 is the n = 2,000 scenario-register mean at the derived 0.1843. | fixed (both bases stated in `Parameters.sysml`; dated verification note under ECN-023 §5a; the signed text itself not rewritten) |
| V-N13 | VC-22 (canister payload 3.5 t ECON vs 3.6 t ECN-020) was cited by `Parameters.sysml`, the register and the families doc but never added to `VALUE_CONFLICTS.md`. | fixed (row added to both copies, which stay byte-identical) |
| V-N14 | D8 samples `haulerEarthFractionFloor` two-point 0.43 / 0.08 at equal weight, but the Wave 2 F2 diff had already found the 92 % to be the superseded Rev A column; the D8 0.50 / 0.50 tie is that weight, not a finding about the haulers. | **ECN** — `docs/SEL-ECN-024_draft_HaulerInSituFractionCandidates.md` (close F3 and reduce the entry to a point, or re-source the 92 %) |
| V-N15 | DG-2.1 threshold 5,692 kg/yr is verbatim in Rev D and a typed VERIFY constant, but the Strategy s.1 product it cites (25 × 4.46 % × 80 % × 8,760 × 0.722) evaluates to 5,642; 5,692 corresponds to 4.5 % ice. | record (doc note on t21; no value changes; Wave 5 settles the authority) |
| V-N16 | Three of the V-N11 slips are carried verbatim from the signed ECN-022 §2.2 / §5. | record (lineage note under the ECN-022 status header, with the §2.4 supersession) |

### Item 3 — Rule-3 audit

Method: script over every `.sysml` for numeric literals outside docs and
strings, classified (structural counts, phase windows, bound parameters,
calc-def bodies, gate years, scenario weights, other); each traced;
`scenario_check --n 200 --seed 20260920 --decisions D1 --no-scenarios` run
and `eclipse.py` read against `EclipseCriticalFraction` /
`PlantOversizeFactor`.

Pass: the 33 calc defs hold only identity and unit constants (0.0, 1.0,
1000.0 kWh→Wh); the other files' literals are structural counts with
sources (tracks 2/3/1/1/1 = 8, drivers 5, collars 8, hubs 0, ECN-014
ordinals 4 / 11 / 201–206, crew 0 / 20), the Wave 1 VC-09 inherited values
(`circuitCountAtP14` 2,080,000, `msrUnitCountAtP14` 6,890) unaltered with
their notes, and `econAssumedIntroductionYear = 105` (ECON); every Gates
`econ*` transcription matches `econ.py`. **0.18 reproduces**: the derived
fraction for the sunlit duty cycle is 0.1843 (mean, P10–P90 0.1775–0.1928)
at n = 2,000 and the model calcs mirror `eclipse.py`'s relationship
(hold-load share of the plant oversized by 1 / ((1 − dark)(1 − restart
loss))); 0.18 is the two-figure value, consistently so.

| # | Finding | Disposition |
|---|---|---|
| V-N17 | `scenario_check.py` printed values in [10, 100) at two significant figures, so the committed register showed `thoriumGradePpm` 12.5 as "12" and the oversize High 83.3 as "83". | fixed (four significant figures; register regenerated — no evaluated number changes) |
| V-N18 | The register's D1 caption still read "ECN-022 s.2.4 declared 1.0" beside a Declared column of 0.18. | fixed (tool string; register regenerated) |
| V-N19 | The ECN-014 literals (valve stations 4, monitors 4, preconditions 4, table 11, patterns 201–206) cite a document that exists only as a ledger entry folded into SEL-SW-SENTINEL-001 Rev B (docx, not in `docs/`). | record, 4B (bring the source or its extract into `docs/` with the behaviour) |
| V-N20 | The register says "Sampled dimensions: 22" where the changelog says 18: 18 register entries plus the four event draws (`u:msrAvailable`, `u:impactSurvival1b/2`, `u:mkIiiTest`). | record (both right; wording only) |

### Item 4 — Gate catalogue versus Decision Framework Rev D

Method: script extracting all 81 ids from the document and the model;
criterion strings normalised by the stated transliteration and compared;
phase section and year(s) compared; the eight gates the document does not
bullet (DG-0.1–0.4, 11.5, 11.7, POST.1/2) by hand; `gatedElements` and
`prerequisites` cross-checked against the configuration bindings;
`consequenceIfNotMet` against Strategy s.16; milestones against the MTL
v8.5 page; ten gates read side by side (DG-0.2, 2.2, 4.3, 7.1, 8.0, 9.1,
10.4, 11.6, 13.4, 14.6, POST.1).

Pass: 81 ids, each once; 73 criteria byte-identical after transliteration,
four carry the document's sub-bullets inline (no word or number changed);
every `declaredPhase` is the section the document lists the gate under and
every `declaredYear` / `declaredYearEnd` the year it gives (DG-7.5 "~2040" =
Y15); every binding in the configuration names a gate that lists the
element; counts derivable 39 / testOutcome 13 / exogenous 29; M0–M8 months
and years match the reference; the W3-N notes in the gate docs re-derive
(min 4.76 % at Y139; PGM peak 52.0 t/yr; MOLE-I peak 357 < 620; 105
circuits at Y28; hauler floor 0.33; 1,903/day; YBCO 140 t).

| # | Finding | Disposition |
|---|---|---|
| V-N21 | DG-11.6's criterion was an abridgement (whole sentences dropped) against the package convention "verbatim modulo transliteration". | fixed (full text; plan_check output unchanged) |
| V-N22 | DG-8.7 and the five SPA-MSR gates still described themselves as "unevaluated / no vector" although plan_check has evaluated them since the 19 Sep addenda (`thorium_stockpile`, `fsp_msr_trade`); DG-10.5 / DG-11.3 did not record their supersession as commissioning gates (ECN-022 §2.3). | fixed (docs and `criterionAsModelled`) |
| V-N23 | `SpaThoriumMSR.introducedIn` is still bound to **DG-10.5**, which ECN-022 §2.3 superseded in favour of DG-13.4 as unit #1; rebinding is a selection. | **ECN** — `docs/SEL-ECN-025_draft_SpaMsrUnitOneBinding.md` |
| V-N24 | `SeleniteAnalysis::SpaMsrIntroductionGate`'s calc body still states the withdrawn Wave 2 comparison (demand > non-MSR capability), not the cargo-mass trade plan_check evaluates. | record, Wave 5 (rewrite the calc to mirror `fsp_msr_trade`) |
| V-N25 | Seven gate docs quoted ECON crossing years one year off the Python layer (haulers ≥ 1,000 Y44 not Y45; first MSR Y36 not Y38; 14,881 haulers Y64; supply fraction 0.10 Y101; 500 kt Y121 / 0.40 Y141; 6,890 MSR Y173; 1.25 Mt Y152). | fixed (re-derived from `econ.workspace()`) |
| V-N26 | DG-POST.1/2 criteria are the Strategy s.16 trigger + consequence wording, cited to s.7.4 (ids and years only); DG-POST.2 lacked the `consequenceIfNotMet` its s.16 row supplies. | fixed |
| V-N27 | "fleet v9 App. C" is cited for the DG-14.3 alias and the P0 window, but the markdown authority has no appendix — the content is its s.20.3. | fixed in `Gates.sysml`; the same string in `Phases.sysml` (×3), `DOCUMENT_FAMILIES.md` and `ARCHITECTURE_BASELINE.md` recorded for the next touch of those files |
| V-N28 | Twelve configuration bindings were not named in their gate's `gatedElements` (where an element binds both `introducedIn` and `operationalFrom` the list named one). | fixed (lists completed; plan_check byte-identical) |
| V-N29 | DG-14.3's text makes the S-type Si refinery depend on C-type carbon, but its `prerequisites` did not name DG-13.3 (DG-13.5 does for the same dependency). | fixed |
| V-N30 | `declaredPhaseAlternate` is stored for DG-13.4 / DG-14.4 from the year table but not for DG-13.5 / 13.6 / 14.5 / 14.9, which the register marks "earlier than declared" on that basis; the package doc says the year-implied phase is computed, not stored. | record, Wave 5 (adding alternates changes verdicts) |

### Item 5 — Configuration bindings — pass

Method: script over `ProgrammeConfiguration.sysml` (every `redefines … =
gates.<usage>.derivedPhase`, every chain, every `derivedYear`) against the
`GateCatalogue` usages and the CHANGELOG_WAVE3 §3 classification table in
both directions. 85 gate bindings + 4 chains (= 89) and 9 `derivedYear`
bindings, all resolving; every C / C/E row bound as tabled, no F or E row
bound; `temporaryCrewHab.retiredIn = introducedIn`,
`starshipReturn.retiredIn = massDriverNetwork.md4.operationalFrom`, `md4` →
`dgTwelveFour` (ECN-022 §2.1), `skip` / `skipHops.retiredIn` →
`md2.operationalFrom` all hold; the Wave 4A selections `d1 :> sunlitDutyCycle`
… `d8 :> econFloor` each name an existing variant and `d1`'s doc cites
ECN-023; every definition value in the table unchanged (rule 4). The only
observation is V-N23 (item 4).

### Item 6 — Requirements — pass

Method: script over `ProgrammeRequirements.sysml` and the configuration;
every assert evaluated on the bound values. SEL-REQ-001..016 each have a
`subject` (`abstract subject` where the type is abstract), 15 carry a
`require constraint`, SEL-REQ-005 keeps `ProgrammeContext` as the changelog
says; 21 requirement usages, each with a `satisfy … by` link. Constraints
true on the bound values: D2EHPA false on both flowsheets; PKT
`permanentCrew` 0 and `skipOperationsPermitted` false; conveyor hubs 0 and
trunk mode conveyor; every ARM `canEnterPsr` false; MOLE-S and both
chemical PROBE classes at `spa`; hauler at `pkt`; Mk III never lands, no ISRU
propellant; 2 + 3 + 1 + 1 + 1 = 8 tracks, 5 drivers; crew hab retired in its
introduction phase; all three asteroid lines at `spa`; 1.2 ≥ 1.0; 124 × 5 =
620. The ECN-023 operating rule is not yet a requirement — open item for 4B
(§4).

### Item 7 — Python layer — pass

Method: scripts and `git log`. `test_goldens.py` collects **1,437** rows
(1,404 pass + the 33 declared skips: THERMAL 30 + 2 ODE-grid statistics,
VISUALIZE `h_leg`); `econ_param.v1_3(Params())` equals `econ._v1_3()`
**exactly** on all 247 shared keys (arrays by shape, dtype and value;
callables `earth_frac` / `isru_frac` on the Y0–Y200 grid; eight extra keys
are the parametrisation's own); `plan_check` default stdout byte-identical
to `tests/fixtures/plan_check_stdout_wave3.txt` and `--markdown`
byte-identical to `docs/PLAN_REGISTER.md` (re-checked after every model
edit); `PORTED = False` in `plan_vectors.py` and all nine `scenarios/`
modules; assumptions named (`ASSUMED_HOLD_LOAD_FRACTION`,
`ASSUMED_RESTART_LOSS_DAYS`, `TH_TO_REO_RATIO_LOW/HIGH`,
`DF_ASTEROID_PROCESSING_KW`, `ANNUAL_COST_USD_B` …); `econ.py`, `verify.py`,
`thermal.py`, `psr_layout.py`, `eclss.py`, `goldens.py`, the golden tests and
the v2.1 capture untouched since the port commits (`96c251f`, `df14c4f`,
`cc075db`, `ced07c3`); `test_sources.py` hashes pass. One
`pytest.skip` outside the goldens (`test_modelio.py:154`, environmental).

### Item 8 — Scenario layer — pass

Method: three full runs at n = 2,000 (seed 20260920 LHS, seed 1 LHS, seed
20260920 Sobol) diffed against the committed register; the §1 table checked
row by row against `Parameters.sysml`; the D1 two-world table recomputed.

- **Determinism:** the seed-20260920 re-run is byte-identical to the
  committed `docs/SCENARIO_REGISTER.md`.
- **Robustness:** seed 1 and Sobol change **no recommendation** under any
  criterion for D1–D8 (the only visible movement is D6's P(no slip) 0.59 →
  0.58 under Sobol, sampling noise); all three runs exit 0, structural checks
  passed.
- **Sampled / point:** 18 sampled entries each have bound Low/High twins (or
  bound two-point candidates) and a cited range; 14 points each state their
  reason (range unbound / evaluator assumption); 18 + 14 = 32 entries, all
  bound by reference.
- **Two worlds by hand:** A 6,935,154 t (MSR) / 6,977,110 t (no MSR), B
  6,935,326 / 6,943,821; B − A = +172 t with the MSR, −33,289 t without; the
  availability p at which A(p) = B(p) is 33,289 / (33,289 + 172) = **0.9949**,
  the printed break-even; at p = 0.9 the totals are 6,939,350 (A) and
  6,936,176 (B), matching ECN-023 §2 to rounding; every ECN-023 §2 number
  appears in the register. Findings V-N17, V-N18 and V-N20 above.

### Item 9 — Registers versus documents

Method: every W2-N1…20, W3-N1…22, W4A-N1…7, W3-R1…56 (ten re-derived from
the model and the port), VC-01…22 and F1…F10 row read against the current
model and documents, each classified still true / resolved / superseded;
grep for stale current-status wording. The consolidated open-items list is
§4.

Pass (verified resolutions): W2-N7 (C-type P12, S-type P13), W2-N15/16/17
elements, W2-N18 (620 bound; 310 sampled for D7 only), W3-N2 MD-4 half
(`md4` → DG-12.4), W3-N13 (M0–M8 verified month by month against the MTL
v8.5 page), ECN-023 superseding ECN-022 §2.4 (0.18 bound, `d1` selected);
W4A-N2 pin consistent across CI, context doc, scripts and briefs; W4A-N7
counting as described in `eclipse.py`; all sampled W3-R rows re-derive
exactly.

| # | Finding | Disposition |
|---|---|---|
| V-N31 | CHANGELOG_WAVE4A §5 heading said W4A-N1 … N6 over a seven-row table. | fixed |
| V-N32 | CHANGELOG_WAVE3 §3 / §6 cite W3-R numbers of the 15 Sep register (55 rows); the 19 Sep regeneration (56 rows) moved every row from W3-R24 down by one (W3-R47 → R46 for the PROBE fuelling, R44/45 → R43/44 for the EM catcher, R52 → R51 for CAP, R43 → R42 for ISRU). | fixed (dated note appended to CHANGELOG_WAVE3; the record itself not rewritten) |
| V-N33 | DOCUMENT_FAMILIES pointed to W3-N1…N20 in §5 only; W3-N21 / N22 live in the 18 and 19 Sep addenda. | fixed |
| V-N34 | Flag F10 still read "Fix in source before Python port" — never done, by rule: the sources are hash-pinned, the port reproduces the line-584 truncation, AUDIT_RESOLVE is declared expected-to-fail. | fixed (closed as recorded) |
| V-N35 | The Wave 4A brief banner still said "PR open" (PR #9 merged; ECN-023 PR #10). | fixed |
| V-N36 | F2 (fleet v9.md wins; v9-1.docx HISTORICAL) was resolved by evidence on 14 Sep; no document records Jason's confirmation. | record → Jason (§4) |
| V-N37 | W2-N12 (SURVEY concept) has new evidence not recorded: the MTL v8.5 page has an orbital SURVEY from P2 and a SURVEY-2 on Cargo Launch 4 (P5). | record, Wave 5 |
| V-N38 | W2-N13 (first FSP): `Power.sysml` calls the Gantt's FSP-1 at M36 / Y3 the "P1/P2 boundary" and sets the early candidate P2; by `ProgrammeTimeline` Y3 is inside P1. | record, Wave 5 |
| V-N39 | VALUE_CONFLICTS says every row is recorded in a model doc; VC-03 and VC-11 are cited nowhere in the model. | record, Wave 5 |
| V-N40 | `GateThresholds` carries Rev D's 783/day (DG-12.3) and 308 circuits (DG-8.5) verbatim although ECN-020 §4 and ECN-022 §3.1 / §3.2 record them as wrong (1,903/day; 105 circuits); the register evaluates the gates on them. | **ECN** — `docs/SEL-ECN-026_draft_RevDThresholdsCarriedVerbatim.md` |

### Item 10 — Document map and families

Method: every file in `docs/`, `mapping/` and the seven root files matched
to `document_map.csv`; statuses judged against the repo state; the status
vocabulary tabulated; the CSVs parsed; `build_ledger.py` re-run into a
scratch directory and diffed; every model citation of a family compared with
the family winner; the three READMEs and the quickstart read.

Pass: every source document in `docs/` has a row; the ECN-023, 4A-brief,
SW-skeleton, ECON-001, value-chain and ECN-019 ("NOT IN REPO") rows are
right; all Tier 1–6 model citations match their winners (fleet v9 only,
Rev B SENTINEL software and rover, Rev D framework, Strategy v3.1, MTL v18
revised, ISRU-001 Rev D updated, HAB-001 Rev D, PROC-PKT-001 Rev B, HAULER
Rev B, CATAPULT Rev B, CONVEYOR Rev A …; the three SEL-HAULER-001 Rev A
mentions are the deliberate F3 lineage); the ledger marks `v9-1.docx`
HISTORICAL; the root copies of VALUE_CONFLICTS and the port brief are
byte-identical to `docs/`; spelling clean after the one fix.

| # | Finding | Disposition |
|---|---|---|
| V-N41 | No map rows for `PLAN_REGISTER.md` (generated), the Wave 2 / 3 / port briefs, the Rev C framework kept as history, the two fleet docx at the git root, or SEL-ECN-024; the verification brief row and banner said "planned / not started". | fixed (rows added incl. ECN-025 / 026; brief → delivered) |
| V-N42 | MIGRATION_PLAN stated a six-word status vocabulary; the map uses seventeen values, two of the six never. | fixed |
| V-N43 | DOCUMENT_FAMILIES said the CSVs are generated by `build_ledger.py`; since the F2 hand-correction the script no longer reproduces them (re-run differs exactly at the F2 rows), so they are hand-maintained; `scaling_v1_3.m` was AUTHORITATIVE in the CSV / ledger but HISTORICAL in the doc (VC-14); value chain v14.1 / v15 listed as superseded though all three are current (scope split); "HAB-001 Rev D" lacked "(updated)". | fixed (doc wording; CSV / ledger rows). The missing ECN-021/022/023 rows in `DOCUMENT_FAMILIES.csv` are a record, not an edit: repo-authored ECNs are indexed in `document_map.csv` |
| V-N44 | The git-root README had no wave state and no tool pins (and omitted plan_check / scenario_check / the compute job); the model README named no pins; the compute README still said 1,443 tests and omitted `plan_vectors.py`, `scenarios/` and the Wave 3 / 4A tests; the quickstart installed an unpinned `sysml-diagram`, listed two views, one CI job and the Wave 1 zip workflow; one US spelling ("artifacts"). | fixed |
| V-N45 | Rows for the Wave 4B sources (value chain v16, NAV-001, SW-MOLEI, SW-SENTINEL, SW-SUB, ECN-013) still carried wave "4" beside rows reading "4B"; the Wave 2 brief had no status banner. | fixed. EVA contingency (`planned`, wave 4) is named in no brief — record for 4B / 5 planning |
| V-N46 | Three dated 14 Sep statements still quote "pytest 1,443" in historical sections (MIGRATION_PLAN §Python port, the port brief, CHANGELOG_PORT). | record (true at the time) |

## 2. Fixes applied, by file (all value-neutral; no bound value, threshold, selection or decision changed)

- **`model/Parameters.sysml`** — V-N11 citation strings (fleet v9 s.8, s.4.3 ×2; Strategy s.8.2; Strategy s.15.2 / Rev D P14 table; the ">500 ppm" attribution; crew 20 sources; ECON knots vs crossing years; hauler Rev A lineage); V-N12 both FSP bases; V-N15 DG-2.1 arithmetic note; V-N6 `SEL-ECN-022 s.2.2`.
- **`model/Scenarios.sysml`** — V-N2 docs on 18 definitions; V-N4 three stale ECN-023 docs; V-N11 four register `source` strings (these print in the register).
- **`model/Gates.sysml`** — V-N6 ×2; V-N11 DG-7.1 doc; V-N21 DG-11.6 full criterion; V-N22 DG-8.7 and the five SPA-MSR gates; V-N25 seven ECON years; V-N26 DG-POST citations and DG-POST.2 `consequenceIfNotMet`; V-N27 s.20.3 ×3; V-N28 twelve `gatedElements` entries; V-N29 DG-14.3 prerequisite DG-13.3.
- **`model/ThroughputCalcs.sysml`** — V-N4 `EclipseCriticalFraction` doc; V-N3 "VERIFY v5.0".
- **`model/Transport.sysml`** — V-N2 `MassDriverId` doc; V-N6. **`model/ProgrammeConfiguration.sysml`** — V-N6 `md4` doc. **`model/Power.sysml`**, **`model/Software.sysml`** — V-N3 revisions. **`model/SeleniteProgramme.sysml`** — V-N5.
- **`tools/scenario_check.py`** — V-N17 four significant figures in [10, 100); V-N18 D1 caption.
- **`docs/SCENARIO_REGISTER.md`** — regenerated at n = 2,000, seed 20260920 after the above: the §1 source strings, the D1 caption and the number formatting differ (values in [10, 100) now print at four significant figures: 12.5 and 83.3 in §1 and seven table cells such as 48.66 and 67.5); every evaluated number, quantile and recommendation is otherwise byte-for-byte the same as before (12 of 324 lines touched, all of them formatting or source text).
- **`diagrams/*.svg`** — all seven re-rendered with 0.42.0 (V-N1; the gates, scenarios, software and programme general views change with the doc edits).
- **`docs/VALUE_CONFLICTS.md`** and the root copy — VC-22 (V-N13).
- **`docs/SEL-ECN-022_DecisionFramework_Wave3.md`** — dated "superseded in part" note (§2.4 → ECN-023) and the citation-lineage note (V-N16). **`docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md`** — dated verification note under §5a (V-N12).
- **`mapping/document_map.csv`** — V-N7, V-N41, V-N45 (105 rows, all eight columns). **`mapping/DOCUMENT_FAMILIES.csv`**, **`mapping/UPLOAD_LEDGER.csv`** — V-N43.
- **`docs/DOCUMENT_FAMILIES.md`** — V-N33, V-N34, V-N43, Tier 6 ECN-024 … 026. **`docs/MIGRATION_PLAN.md`** — V-N42 and the verification state (§"Verification"). **`docs/CLAUDE_SYSML_CONTEXT.md`** — §8 verified state and what 4B starts from.
- **`CHANGELOG_WAVE4A.md`** — V-N31. **`CHANGELOG_WAVE3.md`** — V-N32 note. **`docs/SESSION_BRIEF_wave4_scenarios.md`** — V-N35; **`…wave2_architecture.md`** — status banner; **`…verification_post_wave4a.md`** — delivered.
- **`README.md`** (root), **`selenite-sysml-wave1-revC/selenite-sysml/README.md`**, **`selenite-compute/README.md`**, **`docs/HUMAN_QUICKSTART.md`** — V-N44.

## 3. Draft ECNs for Jason (not applied)

| ECN | Question | Value / decision at stake |
|---|---|---|
| SEL-ECN-024 | Close flag F3 (92 % is the superseded Rev A column) and reduce the D8 register entry to a point at 0.43, or re-source the 92 %. | `UncertaintyRegister.haulerEarthFractionFloor` sampling (0.43 / 0.08 equal weights); D8's 0.50 / 0.50 tie; F3 status |
| SEL-ECN-025 | Bind the SPA MSR unit #1 to DG-13.4 (ECN-022 §2.3 carry-through) or keep DG-10.5 as the owning gate. | `shackletonHub.powerZone.spaMsr.introducedIn` binding (derived year unchanged, Y105) |
| SEL-ECN-026 | Align `canistersPerDaySteadyState` (783 → 1,903) and `circuitsP8Complete` (308 → 105, or drop) to ECN-020 / ECN-022, or keep Rev D's figures until Rev E. | two `GateThresholds`; DG-12.3 (Y141) and DG-8.5 (circuits Y41) derived years |

## 4. Consolidated open-items list for Waves 4B and 5 (the state they start from)

### Needs Jason's decision now (ECN-024 … 026 above, plus)

1. **Default decision criterion** (Wave 4A open question 1): `decisionCriterion = expectedEarthMassWithSlipChance`, `chanceConstraintThreshold = 0.8` are still PROPOSED; every D1–D8 lead recommendation follows it.
2. **`spaMsrAvailabilityProbability`** 1.0 (range unbound): a sourced probability for the thorium line settles the D1 insurance case (break-even 0.995) and D2's first-MSR year.
3. **Hold-load fractions 0.25 and restart loss 0.5 day** (W4A-N3): bind from a process source or accept by ECN; `spaAsteroidLoadCriticalFraction` 0.18 (0.04–0.37) rests on them.
4. **VC-22** canister payload 3.5 t (ECON) vs 3.6 t (ECN-020): cadence, DG-12.3, D3 costs, and the ECN-026 figure.
5. **W3-N4 REO ramp**: align DG-11.1 / 12.1 / 13.1 to the ECON ramp (Y80 / Y121 / Y152) at Rev E or ECN the ramp.
6. **D7 Mk III trigger** (`mkIiiTestPassProbability` 0.5 uninformative; capacity-forced never on 620, Y31 on 310) and **D3 canister recovery** (`abstract part d3`; shuttlecock P(win) 0.71 on an uninformative 0.5 impact-survival probability; `canisterEarthContentKg` unbound).
7. **W3-N11** demonstrator location (SPA rim P7 vs PKT Y28–30, DG-8.8); **F7** gap intent (DG-7.5 at Y15); **F9** final report date; **F2** confirmation (V-N36); **W4A-N1** design eclipse 72 h vs 3–5 days; **VC-21** Catapult Rev C; **DG-2.1** 5,692 vs 5,642 (V-N15); SURVEY concept and first-FSP phase rulings (V-N37, V-N38).

### Wave 4B (behaviour, interfaces, software) must start from

- **SEL-REQ-017**: the ECN-023 operating rule (pausable steps outside the eclipse; plant oversized for the dark fraction and restart losses; hold loads only through eclipse) as a requirement on the SPA asteroid lines, checkable on `pausableThroughEclipse`, with `satisfy` links (ECN-023 §3 / §5a).
- SEL-REQ-005 keeps `ProgrammeContext`: an L1 / EML-2 O₂ depot element gives it a subject.
- Gated elements that do not exist: SPA reagent pilot / production (DG-5.3, DG-7.4), PKT oxalic-acid line (DG-9.5) — "TODO Wave 4" strings in `Gates.sysml`; the `ThUSeparationStage` selection (preprint); SEL-CON-001 connector element (V-N7); the ECN-014 source extract (V-N19).
- The behaviour scope itself (brief steps 1–4): value-chain action flows v14.1 / v15 / v16, typed ports on every `connect`, SENTINEL states and the ECN-014 valve auto-close, NAV-001 fusion; advance the `skeleton` / `planned` rows (value chain, NAV-001, SW-MOLEI, SW-SENTINEL, SW-SUB, CON-001) and decide where EVA contingency is consumed (V-N45).
- Model hygiene carried over: V-N3 (44 docs without a named source; 12 without a revision), V-N8 (`Milestone` abstract attribute), V-N9 (views for the ten unrendered files), V-N27 ("App. C" → s.20.3 in `Phases.sysml`), the "Wave 4" placeholders to re-label 4B.
- `prerequisites` / `gatedElements` are strings ("Wave 4 may promote them"): if promoted to semantic links, the designed indirect cases (DG-7.1 "via", the chained retirements, DG-3.2 "partial") need a convention.
- ECN-021 stays out until PROC-PKT-001 Rev C, PROC-001 Rev C, ISRU-001 Rev E, MTL Guide v19 and Strategy v3.2 exist and VC-15/16/17 are corrected.

### Wave 5 (quantities, derived timeline) must start from

- Bind `derivedPhase` for the 89 bindings; the W2-N1/2/3/4, W3-N9/10 and W3-R42–56 definition-versus-gate rows become derived outputs; settle the SPA MSR owner (ECN-025) and rewrite `SpaMsrIntroductionGate` to mirror `fsp_msr_trade` (V-N24); decide the `declaredPhaseAlternate` rule (V-N30); bind `UncertaintyRegister.parameters` to the programme instance (V-N10).
- DG-POST.1/2: `tier1ResourceTonnes` / `tier2ResourceTonnes` unbound; ECON stops at Y200.
- Never-met gates: DG-14.6 (annual-flow proxy minimum 4.76 % at Y139; needs a cumulative infrastructure-mass vector) and DG-13.7 (hauler floor 0.33 vs 0.20; F3 / ECN-024 lineage).
- VC adjudications VC-01…14, 18, 19, 20, 22 by ECN + new golden (VC-09 carried in `msrUnitsP12` and `msrUnitCountAtP14` = 6,890; `circuitCountAtP14` 2.08 M; VC-20 `co2PerLaunchTonnes` unbound); VC-03 / VC-11 model doc records (V-N39).
- Decision Framework Rev E rendering (ECN-022 §3 and §5; ECN-023 §5; ECN-026 if signed): MD-4 row, DG-11.2 thorium figures (W3-N22), DG-10.5 / 11.3 superseded, milestone alignment (W3-N21), 310 → 620, 308 / 783 / DG-14.3 alias / DG-7.5 placement / P12–P13 re-sectioning / REO gate years / YBCO 280 → 523, DG-13.2 double use (W2-N19); Strategy v3.2 and fleet v9 follow-ons.
- Unbound Python-supplied inputs to bind: `reoTonnesPerYearByYear`, `reoDemandBaseline…`, `spaElectricalDemandByYear`, `spaNonMsrCapabilityByYear`, `thoriumHydroxideStockpileByYear`, `mkIiiPeakFleetUnits`, `redirectTugFleetUnits`, `canisterEarthContentKg`, `reoPayloadPerCanisterTonnes`, `co2PerLaunchTonnes`, `launchCostPerFlightUsd` (W3-N18 basis); the capture-year ranges (W4A-N5); the test-outcome probabilities (W4A-N4).
- ECON items by ECN + golden: `cargo_ybco` 140 t pre-ECN-020 (W3-N12); the hauler artefact (W3-N8); the lost-throughput gearing (W4A-N6); the eclipse count (W4A-N7); VERIFY vectors vs definition phases (W3-N17); F4 / VC-07 MOLE-I profile; F8 AUD masses and powers (VC-04).

## 5. Validation (end of session)

`sysml-validate model --workspace . --all` (0.36.0): **16 files checked, no
problems found** — exit 0, zero hints. `tools/render_diagrams.sh`
(sysml-diagram 0.42.0): seven SVGs, exit 0. `pytest selenite-compute`:
**1,565 passed, 33 skipped**. `tools/plan_check.py --quiet`: exit 0; default
output byte-identical to the fixture and `docs/PLAN_REGISTER.md`.
`tools/scenario_check.py --n 2000 --seed 20260920 --markdown
docs/SCENARIO_REGISTER.md`: exit 0, all structural checks passed, largest SE
0.59 % (D3/shuttlecock); `--n 200 --quiet`: exit 0.

## 6. Map updates

`mapping/document_map.csv`: 94 → 105 rows (PLAN_REGISTER, three briefs, the
Rev C framework, two fleet docx, ECN-024 … 026 added; verification brief →
`delivered`; CON-001 → `4B, planned`; six Wave 4B labels; six package names;
row 65 quoted). Families CSV / ledger: `scaling_v1_3.m` HISTORICAL; value
chain v14.1 / v15 current.
