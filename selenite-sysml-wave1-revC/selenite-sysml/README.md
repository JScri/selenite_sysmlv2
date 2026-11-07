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

**State: Wave 4B delivered (7 Nov 2026, `CHANGELOG_WAVE4B.md`): the
value chain as typed action flows (`model/Behaviour.sysml`), typed ports and
an interface on every connection (`model/Interfaces.sysml`), SENTINEL and the
ECN-014 valve auto-close as state machines, NAV-001 fusion as a behaviour,
SEL-REQ-017, `tools/connect_check.py`; same-day addendum: the wave's primary
sources are in `docs/` and `docs/sources/` and the behaviour they give is
bound (`CHANGELOG_WAVE4B.md` §9); next is Wave 5
(`docs/SESSION_BRIEF_wave5_quantities.md`).** Wave 4A (6 Nov 2026,
`CHANGELOG_WAVE4A.md`) delivered the decision catalogue D1–D8 and the
uncertainty register in `model/Scenarios.sysml`, the stochastic decision
engine in `selenite-compute/selenite/scenarios/`, `tools/scenario_check.py`
printing `docs/SCENARIO_REGISTER.md` in CI, and
`docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md` signed 6 Nov 2026
(duty cycle, critical fraction 0.18); the post-Wave-4A verification session
(6 Nov 2026, `CHANGELOG_VERIFICATION.md`, SEL-ECN-024 … 026 signed and
applied) audited that state. Wave 3
(closed 19 Sep 2026, SEL-ECN-022)
delivered gates and the derived programme plan: 81 Decision Framework gates with criteria, thresholds and calcs, every
phase attribute classified and bound, SEL-REQ-001..016, `tools/plan_check.py`
printing the derived-vs-declared register (`docs/PLAN_REGISTER.md`); see
`CHANGELOG_WAVE3.md`. Wave 2 (architecture and temporal skeleton) is in
`CHANGELOG_WAVE2.md`. CI lives at the git
repository root (`../../.github/workflows/validate.yml`) and runs every step
inside this folder; `.vscode/` (Syside recommendation, diagram-CLI project
marker) is restored here.

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
| `tools/` | Validation, `connect_check.py` (connection endpoints, W4B-N2), diagram export, stub scaffolding, `plan_check.py` (plan register), `scenario_check.py` (scenario register) |
| `.vscode/` | Syside extension recommendation and the `sysml/project.json` marker the diagram CLI needs |
| `../../.github/workflows/` | CI at the git root: validate + render on every push |
| `CHANGELOG_WAVE*.md` | ECN-style change logs per wave |

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
