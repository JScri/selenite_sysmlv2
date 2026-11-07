# Selenite Programme — SysML v2 Model

SysML v2 (textual notation) model of the Selenite Programme: a 200-year lunar
rare earth element mining and processing initiative targeting 2.5 Mt/yr REO at
steady state (~Y180). Baseline: **ECN-019 Rev C + ECN-020**.

> **Baseline note.** ECN-019 Rev C is the consolidated programme baseline.
> ECN-020 (mass driver parallel track architecture, 5 drivers / 8 tracks,
> ~523 t YBCO, ~694,444 canisters/yr) is applied and propagated across
> Strategy v3.1, Decision Framework Rev D, Fleet v9 and MTL Guide v18.
> **ECN-021** (PKT process water supply chain) is drafted but deliberately
> *not* propagated — it is deferred pending updates to PROC-PKT-001,
> PROC-001, ISRU-001, MTL Guide and Strategy. The model must not adopt
> ECN-021 content until those source documents are revised.

**State (6 Nov 2026):** Wave 4A delivered
(`selenite-sysml-wave1-revC/selenite-sysml/CHANGELOG_WAVE4A.md`) and
SEL-ECN-023 signed and applied; the post-Wave-4A verification session
(`CHANGELOG_VERIFICATION.md`, SEL-ECN-024 … 026 signed and applied) audits that state; Wave 4B
(behaviour, interfaces, software) is next, then Wave 5. The Python layer
`selenite-compute/` is the quantitative authority (goldens, plan vectors,
scenario engine). Tools pinned: `sysml-validate@0.36.0`,
`sysml-diagram@0.42.0` (W4A-N2).

This repository is the MBSE migration target for the ~36-document engineering
suite. The documents remain the historical record; the model becomes the
single source of truth as migration waves complete (see
`docs/MIGRATION_PLAN.md` and `mapping/document_map.csv`).

## Layout (in selenite-sysml-wave1-revC/selenite-sysml)

| Path | Contents |
|---|---|
| `model/` | All `.sysml` sources (flat — see docs/CLAUDE_SYSML_CONTEXT.md §4 for why) |
| `docs/` | Quickstart, Claude session protocol, migration plan |
| `mapping/document_map.csv` | Master document→model migration index |
| `diagrams/` | Generated SVGs (regenerate via `tools/render_diagrams.sh`) |
| `tools/` | Validation, diagram export, stub scaffolding, `plan_check.py` (plan register), `scenario_check.py` (scenario register) |
| `.github/workflows/` | CI at the git root: `validate` (sysml-validate 0.36.0, sysml-diagram 0.42.0 render) and `compute` (pytest, plan_check, scenario_check) on every push |

## Quick start

See `docs/HUMAN_QUICKSTART.md`. Short version: open this folder in VS Code,
install the recommended **Syside Editor** extension when prompted, open any
`.sysml` file.

## Toolchain

- **Syside Editor** (free, open source) — VS Code language support
- **sysml-validate 0.36.0 / sysml-diagram 0.42.0** (npm, both pinned — W4A-N2)
  — headless CLI validation and SVG export, used by Claude, `tools/`, and CI
- **Eclipse SysON** (optional, free, EPL-2.0) — web-based graphical editing

## Licensing & scope

Private during migration, pending the programme-name IP clearance opinion.
Intended public licensing on release: CC BY 4.0 (model and docs), MIT (tools),
consistent with the wider programme. The novel *Selenite* is **not** part of
this repository and never will be — full copyright reserved, kept cleanly
separated from CC-licensed programme materials.
