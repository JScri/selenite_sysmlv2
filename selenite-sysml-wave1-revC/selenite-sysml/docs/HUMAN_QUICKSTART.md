# Human Quickstart — Selenite SysML v2 in VS Code

Everything here is free of financial charge. Total setup time: ~15 minutes
on desktop.

## 1. Prerequisites

- VS Code (or VSCodium/Cursor)
- git
- Optional but recommended: Node.js 18+ (for the CLI tools CI also uses)

## 2. Get the repository onto GitHub

From the unzipped folder:

```bash
cd selenite-sysml
git init
git add -A
git commit -m "Wave 1: SysML v2 architecture skeleton (ECN-019 Rev C + ECN-020 baseline)"
gh repo create selenite-sysml --private --source=. --push
# or create a private repo in the GitHub UI and:
# git remote add origin git@github.com:<you>/selenite-sysml.git
# git push -u origin main
```

**Keep it private** until the programme-name IP clearance opinion is in
hand — same gate as the arXiv/GitHub publication stream. On going public:
CC BY 4.0 for model/docs, MIT for tools.

## 3. VS Code setup

1. Open the `selenite-sysml` folder in VS Code.
2. VS Code will prompt to install the recommended extension —
   **Syside Editor: SysML v2 Essential** (`sensmetry.syside-editor`),
   free and open source. Accept.
3. Open any file in `model/`. You now have: live syntax + semantic
   validation (Problems panel), autocompletion, go-to-definition,
   hover docs, outline view, rename refactoring, formatting.

That is the whole core loop: edit `.sysml`, watch the Problems panel,
commit. The textual notation is the model — diffs, PRs, blame and ECN
discipline all work exactly as they do for code.

## 4. CLI tools (mirrors what Claude and CI run)

```bash
npm install -g sysml-validate@0.36.0 sysml-diagram@0.42.0   # both pinned (W4A-N2)
tools/validate.sh              # whole-tree validation, hints included
tools/render_diagrams.sh       # regenerate diagrams/*.svg (seven views)
python3 tools/scaffold_stubs.py --report   # migration status from the CSV
pip install -e "../../selenite-compute[test]" && pytest ../../selenite-compute   # 1,565 passed, 33 skipped
python3 tools/plan_check.py --quiet                # derived-vs-declared register, exit 0 (--markdown docs/PLAN_REGISTER.md)
python3 tools/scenario_check.py --n 200 --quiet    # decisions under uncertainty, exit 0 (--markdown at n = 2,000)
```

## 5. CI

`../../.github/workflows/validate.yml` (at the git root) runs on every push
and PR. The `validate` job validates the model (inline annotations on the
diff) and uploads freshly rendered diagrams as build artefacts; the
`compute` job runs `pytest selenite-compute`, `tools/plan_check.py` and
`tools/scenario_check.py` (n = 500) and uploads both registers. Nothing to
configure.

## 6. Diagrams and graphical modelling

- The committed `diagrams/*.svg` (dark theme) come from `sysml-diagram`
  — the programme General and Interconnection views plus the requirements,
  fleet, software, gates and scenarios views, viewable straight from GitHub
  mobile.
- When you want interactive graphical/tabular editing, run
  **Eclipse SysON** (free, EPL-2.0, web-based) locally via Docker —
  see mbse-syson.org for the compose file. Treat it as a viewing and
  stakeholder-diagram companion: **this repo's textual files remain the
  source of truth.**
- Sensmetry's paid Syside Modeler adds diagrams inside VS Code if ever
  wanted; not needed for this project.

## 7. Working with Claude on this repo

1. Start a Claude Code session on `JScri/selenite_sysmlv2` and paste the
   wave's brief from `docs/SESSION_BRIEF_*.md`.
2. State the task ("Wave 4B: SENTINEL states and modes"). Claude follows
   `docs/CLAUDE_SYSML_CONTEXT.md`: installs the pinned tools in its own
   environment, edits, validates to exit 0 with zero hints, runs
   `plan_check` and `scenario_check`, regenerates diagrams, and commits on
   a branch with an ECN-style change log.
3. Review the change log and the PR diff; CI re-validates independently;
   merge.

## 8. Mobile

GitHub's mobile app handles review well: SVG diagrams render inline,
`.sysml` files are readable text, and CI status is visible per commit.
Authoring stays on desktop or via Claude sessions.

## 9. Learning SysML v2 itself

The fastest on-ramp with this repo: read `model/ProgrammeConfiguration.sysml`
top to bottom with hover-docs enabled — it exercises definitions, usages,
specialisation, redefinition, requirements, satisfy, constraints,
connections and enums against systems you already know intimately. The
OMG spec and the `Systems-Modeling/SysML-v2-Release` repo (training
slides included) are the reference texts.
