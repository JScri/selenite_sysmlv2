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

**State: Wave 2 complete (14 Sep 2026)** — architecture and temporal
skeleton for P0–P14+; see `CHANGELOG_WAVE2.md`. Note: the `.github/workflows/`
CI described in earlier revisions was not carried into this git repository
(hidden directories were dropped on upload); CI must be re-added at the
repository root if wanted.

This repository is the MBSE migration target for the ~36-document engineering
suite. The documents remain the historical record; the model becomes the
single source of truth as migration waves complete (see
`docs/MIGRATION_PLAN.md` and `mapping/document_map.csv`).

## Layout

| Path | Contents |
|---|---|
| `model/` | All `.sysml` sources (flat — see docs/CLAUDE_SYSML_CONTEXT.md §4 for why) |
| `docs/` | Quickstart, Claude session protocol, migration plan |
| `mapping/document_map.csv` | Master document→model migration index |
| `diagrams/` | Generated SVGs (regenerate via `tools/render_diagrams.sh`) |
| `tools/` | Validation, diagram export, stub scaffolding |
| `.vscode/sysml/project.json` | Project marker the diagram CLI needs (restored Wave 2) |
| `CHANGELOG_WAVE*.md` | ECN-style change logs per wave |

## Quick start

See `docs/HUMAN_QUICKSTART.md`. Short version: open this folder in VS Code,
install the recommended **Syside Editor** extension when prompted, open any
`.sysml` file.

## Toolchain

- **Syside Editor** (free, open source) — VS Code language support
- **sysml-validate / sysml-diagram** (npm) — headless CLI validation and SVG
  export, used by Claude, `tools/`, and CI
- **Eclipse SysON** (optional, free, EPL-2.0) — web-based graphical editing

## Licensing & scope

Private during migration, pending the programme-name IP clearance opinion.
Intended public licensing on release: CC BY 4.0 (model and docs), MIT (tools),
consistent with the wider programme. The novel *Selenite* is **not** part of
this repository and never will be — full copyright reserved, kept cleanly
separated from CC-licensed programme materials.
