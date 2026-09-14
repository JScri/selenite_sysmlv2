# Claude Session Protocol — Selenite SysML v2 Repository

**Audience: Claude.** Read this in full at the start of any session that
touches this repository. This is the SysML v2 analogue of the CAD context
prompt: it defines the environment, the rules, and the deliverable format.
Jason works fast and directive; do not ask clarifying questions that this
document already answers.

## 1. What this repository is

The SysML v2 (textual notation) model of the Selenite Programme,
migrating the ~36-document engineering suite to MBSE. Baseline:
**ECN-019 Rev C as amended by ECN-020**. ECN-021 (PKT process water) is
drafted but unpropagated — do **not** model it until PROC-PKT-001,
PROC-001, ISRU-001, MTL Guide and Strategy are revised. The source is
now in `docs/SEL-ECN-021_PKT_ProcessWater.md`; its presence is not
permission. Note VC-15/16/17: its water arithmetic is out by 1000× and
the supply chain does not close at P14 as written. The novel *Selenite* and all course-admin material are
permanently out of scope. `mapping/document_map.csv` is the master
migration index — update its `status` column whenever a wave item
progresses.

## 2. Environment bootstrap (run first, every session)

Claude's container has Node and npm with registry access. Install the
headless toolchain before touching any `.sysml` file:

```bash
npm install -g sysml-validate@0.36.0 sysml-diagram
```

Both bundle the OMG standard library (`ScalarValues`, `ISQ`, `SI`, ...)
so nothing else is needed. Verified working in Claude's container
August 2026 at v0.20.0. If npm install fails, still deliver — but state
plainly that the model is **unvalidated** and Jason must rely on Syside
in VS Code to check it.

The user's uploaded copy of the repo (zip in project knowledge or
uploads) is read-only — copy it to `/home/claude/` before editing.

## 3. Hard rules

1. **Never deliver an unvalidated model.** Before presenting any
   `.sysml` change: `sysml-validate model --workspace . --format compact --all`
   must exit 0. Review hints too; fix them unless there is a documented
   reason not to.
2. **Always validate the full tree**, never just the changed file —
   cross-file references break silently otherwise.
3. **Never derive quantitative values.** MATLAB (`SELENITE_VERIFY`,
   `SELENITE_ECON`, `SELENITE_SCALE`) is the quantitative authority.
   The model transcribes verified MATLAB output; it does not compute
   programme numbers independently. `calc def`s exist to mirror
   relationships, not to originate figures.
4. **Never silently alter baseline values.** If a source document
   conflicts with the model or with another document, flag it to Jason
   in the change log (ECN discipline) — do not pick a winner unprompted.
5. **Source-of-truth hierarchy:** ECN-019 Rev C as amended by ECN-020 (mass driver parallel tracks) > named
   document revisions cited as authoritative > `.md` over `.docx` >
   prose estimates. Fleet questions: `SEL_ROBOT_FLEET_v9.md` is the
   integrated authority (confirmed by the F2 diff, Wave 2 — the file named
   `v9-1.docx` is an earlier v9.0 draft); individual Rev A specs are
   manufacturing-level detail.
   Precedence between document revisions is fixed in
   `docs/DOCUMENT_FAMILIES.md`: revision identifier beats folder date;
   markdown beats docx at equal revision; `SEL_FINAL_REPORT_v4.docx` is the
   integrating reference; team inputs (W2_T1_6, W5_Task_4_1, W5_T4_6,
   W6_T5_4, W7_T6_1) carry design weight through it. Winners per family are
   in `mapping/DOCUMENT_FAMILIES.csv`; every uploaded file's status is in
   `mapping/UPLOAD_LEDGER.csv`. Consult those before opening any source.
5a. **Architecture before quantities.** The model captures *what* exists,
   *how* it connects and *when* (phase of introduction and retirement) before
   any value is attached. `docs/ARCHITECTURE_BASELINE.md` is the structural
   and temporal skeleton to build against. Quantities arrive from the Python
   layer, never from reading documents into attributes by hand.
5b. **Open flags F1–F10** in `docs/DOCUMENT_FAMILIES.md` are recorded, not
   resolved, in the model: conflicting values become attributes with both
   candidates and a `doc` comment naming the conflict.
5c. **Demand-gated introductions.** Where a document gives a phase for an
   element whose real trigger is a computed demand/capability comparison
   (SPA MSR is the first case), do not bind `introducedIn` to the document's
   phase. Model the gate as a `calc def` in `SeleniteAnalysis`, keep the
   document phases as `candidateIntroduction*` attributes, and let Wave 5
   evaluate the gate on Python-sourced vectors. Phase labels in documents
   are candidates, not decisions.
6. **Every definition carries provenance**: a `doc` comment citing
   source document + revision (`Source: SEL_MOLES_DESIGN_RevA.`).
   Unmigrated content gets an explicit `TODO Wave N.` marker.

## 4. Layout and modelling conventions

- **All `.sysml` files live flat in `model/`** — no subdirectories.
  Reason: the `sysml-diagram` CLI (v0.20.x) resolves cross-file
  references only among same-directory siblings, even with
  `--workspace`. The validator handles nesting fine, but flat keeps
  both tools clean. Revisit if the tool gains full workspace indexing.
  Organisation comes from packages, not folders.
- One top-level package per file, `Selenite`-prefixed
  (`SeleniteFleet`, `SelenitePower`, ...). Do not reopen a package
  across files — SysML v2 does not support partial packages.
- Naming: `PascalCase` for defs, `camelCase` for usages and
  attributes. No unit suffixes in names — use ISQ subsetting:
  `attribute dryMass :> ISQ::mass = 1200 [SI::kg];`
  Beware shadowing library names (`mass`, `power`) — subset (`:>`),
  never plain-declare them.
- Imports: `private import`, one per line, alphabetised
  case-insensitively (linter STYL005).
- Requirement short names carry programme IDs: `<'SEL-REQ-NNN'>`.
  Every `requirement def` needs a `subject`; programme-wide ones use
  `ProgrammeContext` until Wave 3 binds them to checkable subjects.
- **Phase-valued attributes** (decided Wave 2): `sysml-validate` 0.36.0
  treats `enum def` as abstract, so any usage typed `: Phase` (or by any
  other enum) raises hint SSM021. Declare them `abstract attribute x : Phase`
  inside an `abstract part def` (`SelenitePhases::PhaseGated` for
  `introducedIn` / `retiredIn`) and bind in concrete definitions with
  `attribute redefines x = Phase::Pn`. Ad-hoc phase markers on a concrete def
  are untyped value bindings: `attribute crewedFrom = Phase::P4;`.
  `retiredIn = null` means "never retired within the programme". An open
  flag may leave `introducedIn` deliberately unbound (F5, `SpaThoriumMSR`).
- Fleet-scale counts stay as configuration **attributes**
  (`circuitCountAtP14`), not part multiplicities, until multiplicities
  earn their keep. Exception: genuinely enumerable assets
  (`massDriverNetwork : MassDriver[5]`).

## 5. Session workflow

1. Locate the current repo state (project knowledge zip, upload, or
   pasted files). Copy to `/home/claude/selenite-sysml/`.
2. Bootstrap tools (§2). Run `tools/validate.sh` to confirm the
   inherited state is clean before changing anything.
3. Make the session's changes. Whole-file rewrites are fine; keep
   diffs reviewable per commit-sized chunk of intent.
4. Validate (hard rule 1). Fix until exit 0 and hints are clean.
5. If structure changed, regenerate `diagrams/` via
   `tools/render_diagrams.sh` (add new views to that script when new
   anchors matter).
6. Update `mapping/document_map.csv` status for any migrated rows,
   and `docs/MIGRATION_PLAN.md` if a wave's scope moved.
7. Deliver: zip the full repo (or the changed files if Jason asks),
   `present_files`, and post an ECN-style change log (§6). Australian
   spelling in all documentation.

## 6. Change log format (in the chat response)

```
CHANGE LOG — <date>
Scope: <one line>
Baseline in: <state received> | Baseline out: <state delivered>
Changes:
  - <file>: <what and why, citing source doc + rev>
Conflicts flagged: <none | list>
Validation: sysml-validate exit 0, <n> hints (<disposition>)
Map updates: <document_map.csv rows touched>
```

## 7. Known tool facts (as observed, Aug 2026)

| Code | Meaning | Our handling |
|---|---|---|
| STYL002 | usage names should be camelCase | comply; no unit suffixes |
| STYL005 | import group not alphabetised | comply (case-insensitive) |
| SEM006 | requirement def lacks subject | always declare a subject |
| RES016 | name shadows standard library | subset with `:>` instead |
| RES001 | unresolved reference | usually cross-directory — keep model/ flat |
| SSM021 | usage typed only by an abstract definition (enum defs count) | phase idiom in §4; never type a usage `: Phase` directly |
| SSM036 | enum def body may hold only enum values | year windows live in `ProgrammeTimeline`, not on `Phase` |
| STYL007 | single-element body on one line | expand to multiple lines |

Project root detection for the diagram CLI requires `.vscode/sysml/`
(present, `project.json` = `{}`) or a git repo. `--view grv` emits CSV
tables, useful for requirement/attribute exports.

## 8. Wave roadmap

See `docs/MIGRATION_PLAN.md`. Current state: **Wave 2 complete**
(architecture and temporal skeleton: every element of
`ARCHITECTURE_BASELINE.md` §2–§7 is a phase-gated model element with
provenance; F2 resolved; F3–F8 recorded). Next: Wave 3, requirements and
phase gates (DG-x.y) with concrete subjects and `satisfy` links. Fleet
authority is `SEL_ROBOT_FLEET_v9.md`, not the `v9-1.docx` file.
