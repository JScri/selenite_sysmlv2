# Session Brief — Wave 2: Architecture and temporal skeleton

**Scope:** one session. Make the SysML v2 model structurally complete for
all phases P0–P14+, with no quantities beyond structure-defining counts.
Paste this into a fresh chat with `selenite-sysml-wave1-revC.zip` (or the
current repo) in project knowledge.

## Start-up (mandatory, in order)
1. Unzip repo to `/home/claude/selenite-sysml`; `npm install -g sysml-validate@0.36.0 sysml-diagram`; validate inherited state → exit 0.
2. Read `docs/CLAUDE_SYSML_CONTEXT.md`, then `docs/DOCUMENT_FAMILIES.md`, then `docs/ARCHITECTURE_BASELINE.md`. Do not open any source document not listed as a family winner in `mapping/DOCUMENT_FAMILIES.csv`.
3. First real task: extract text from `SEL_ROBOT_FLEET_v9-1.docx` and diff against `SEL_ROBOT_FLEET_v9.md` (flag F2). Report the delta before modelling anything from either.

## Build (in this order, validating after each step)
1. `Phases.sysml`: year ranges per phase; the P6→P7 gap as an explicit attribute with a `doc` flag (F7).
2. `Sites.sysml`: SPA, PSR floor, PKT, EML-2 relay, PKT relay, DRO station, Earth — each with `existsFrom : Phase`, crew profile per phase (permanent vs temporary), and site-selection provenance (GIS).
3. `RobotFleet.sysml`: every class in `ARCHITECTURE_BASELINE.md §3`, including PROBE-Scout, PROBE Mk I/II/III, MOLE-I Mk I/II, Hauler Rev B (miner-hauler with swappable front-end attachments), CAP, redirect tug, Laser Ablation Truss. Each gets `introducedIn`, `retiredIn`, `homeSite`, and the hard allocation rules as constraints (MOLE-S and SKIP never at PKT; ARM never below the rim; Hauler PKT-only).
4. New `PsrNetwork.sysml`: trunk cable, CLP, SATS+WEB, spine/branches, substations, winches, pipeline, CAP guide cable — connected.
5. `Habitat.sysml` / `Power.sysml` / `Processing.sysml`: SPA and PKT facilities from §4, with phase of introduction. PKT foundry, reagent plant, MSR fleet, conveyor network, hub stations, relay depots.
6. `Transport.sysml`: MD-1..5 with `operationalFrom : Phase`, track counts from ECN-020, canister def; SKIP hops (P4–P9, SPA); PKT hauler/conveyor tiers. Absent by design (assert in a `doc`): tankers, PKT SKIPs, ore catapults.
7. New `Software.sysml`: SENTINEL system (three tiers, three modes, supervision location per phase), ECN-014 valve monitoring as a structural element, NAV-001 as a MOLE-I subsystem. Behaviour comes in Wave 4; this wave is structure only.
8. `ProgrammeConfiguration.sysml`: extend the instance tree to every phase-gated element; `satisfy` the existing SEL-REQ-002/003.
9. Update `mapping/document_map.csv` statuses `skeleton` → `architected`; regenerate diagrams; ECN-style change log.

## Rules
- Conflicts F3–F6, F8: record, do not resolve. Both candidate values in the `doc`, no numeric attribute chosen.
- No values from documents into attributes. Counts only where they *are* the architecture (5 drivers, 8 tracks, 3 relay sats, 8 collars).
- ECN-021 content stays out. Novel stays out.
- Australian spelling; flat `model/`; one package per file; alphabetised private imports; validate to exit 0 with zero hints before delivery.

## Done when
Every element in `ARCHITECTURE_BASELINE.md` §2–§7 is a model element with phase attributes and provenance; validation exit 0; four diagrams plus a new `software_view` render; change log lists every F-flag touched.
