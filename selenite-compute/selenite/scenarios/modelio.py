"""modelio.py - the one place the Selenite SysML v2 model files are read.

Wave 4A extension (no golden): this module is not a port of any MATLAB
script and has no oracle. The model-reading layer moved here verbatim from
``selenite-sysml-wave1-revC/selenite-sysml/tools/plan_check.py`` (Wave 3)
so that the scenario tooling and the plan check parse the model through one
set of regular expressions; ``plan_check.py`` imports these names back and
its tables are byte-identical to the Wave 3 tool.

What it reads, by regular expression: the gate catalogue (``parse_gates``),
the phase windows (``parse_phase_windows``), the numeric attributes of a
named block such as ``GateThresholds`` or ``ProgrammeParameters``
(``parse_numeric_attributes``), the calc definitions (``parse_calc_defs``),
definition-level phase attributes with inheritance
(``parse_definition_phases``, ``resolve_declared``), the configuration's
bindings and derivedYear expressions (``parse_configuration``) and the DG
ids of the Decision Framework document (``df_gate_ids``).

The only signature that changed in the move is ``read_model``: it takes an
optional model directory and defaults to ``MODEL_DIR``, the repository's
model folder resolved from this file's location.
"""
from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

REPO_ROOT = Path(__file__).resolve().parents[3]
SYSML_ROOT = REPO_ROOT / "selenite-sysml-wave1-revC" / "selenite-sysml"
MODEL_DIR = SYSML_ROOT / "model"
DF_DOC = SYSML_ROOT / "docs" / "SELENITE_DECISION_FRAMEWORK_v4.md"

PHASES = ["P0", "P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10",
          "P11", "P12", "P13", "P14", "P14plus"]
PHASE_ATTRS = ("introducedIn", "retiredIn", "operationalFrom", "existsFrom")

# --------------------------------------------------------------------------
# Model reading
# --------------------------------------------------------------------------


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"//[^\n]*", "", text)
    return text


def read_model(model_dir: Path | None = None) -> dict[str, str]:
    """Read every ``*.sysml`` file of ``model_dir`` (default ``MODEL_DIR``),
    comments stripped, keyed by file name in sorted order."""
    model_dir = MODEL_DIR if model_dir is None else Path(model_dir)
    return {p.name: strip_comments(p.read_text(encoding="utf-8")) for p in sorted(model_dir.glob("*.sysml"))}


DEF_RE = re.compile(r"^(\s*)(abstract\s+)?(part|calc|enum|attribute|requirement)\s+def\s+(?:<'[^']*'>\s+)?(\w+)(?:\s*:>\s*([\w:,\s]+?))?\s*\{", re.M)


def top_level_blocks(text: str):
    """Yield (kind, name, parents, body_lines_at_depth1) for every definition
    whose opening brace is on the declaration line. body_lines_at_depth1 are
    the lines directly inside the block (nested blocks excluded)."""
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = DEF_RE.match(lines[i])
        if not m:
            i += 1
            continue
        kind, name, parents = m.group(3), m.group(4), m.group(5)
        depth = lines[i].count("{") - lines[i].count("}")
        body = []
        j = i + 1
        while j < len(lines) and depth > 0:
            line = lines[j]
            if depth == 1:
                body.append(line)
            depth += line.count("{") - line.count("}")
            j += 1
        yield kind, name, [p.strip() for p in parents.split(",")] if parents else [], body
        i = j


@dataclass
class Gate:
    def_name: str
    supertype: str
    gate_id: str = ""
    criterion: str = ""
    as_modelled: str = ""
    declared_phase: str = ""
    declared_alt: str = ""
    declared_year: float | None = None
    declared_year_end: float | None = None
    assumed: bool | None = None
    calcs: list[tuple[str, str]] = field(default_factory=list)
    prerequisites: list[str] = field(default_factory=list)
    gated: list[str] = field(default_factory=list)
    former_id: str = ""
    econ_assumed_year: int | None = None
    usage: str = ""
    derived_year_expr: str = ""

    @property
    def evaluability(self) -> str:
        return {"DerivableGate": "derivable", "TestOutcomeGate": "testOutcome",
                "ExogenousGate": "exogenous"}.get(self.supertype, self.supertype)


def parse_gates(text: str) -> tuple[dict[str, Gate], dict[str, str]]:
    gates: dict[str, Gate] = {}
    usages: dict[str, str] = {}
    for kind, name, parents, body in top_level_blocks(text):
        if kind != "part":
            continue
        if name == "GateCatalogue":
            for line in body:
                m = re.match(r"\s*part (\w+) : (\w+);", line)
                if m:
                    usages[m.group(1)] = m.group(2)
            continue
        if not parents or parents[0] not in ("DerivableGate", "TestOutcomeGate", "ExogenousGate"):
            continue
        g = Gate(name, parents[0])
        for line in body:
            s = line.strip()
            m = re.match(r'attribute redefines gateId = "([^"]*)";', s)
            if m:
                g.gate_id = m.group(1)
            m = re.match(r'attribute redefines formerGateId = "([^"]*)";', s)
            if m:
                g.former_id = m.group(1)
            m = re.match(r'attribute redefines criterion = "(.*)";', s)
            if m:
                g.criterion = m.group(1)
            m = re.match(r'attribute redefines criterionAsModelled = "(.*)";', s)
            if m:
                g.as_modelled = m.group(1)
            m = re.match(r"attribute redefines declaredPhase = Phase::(\w+);", s)
            if m:
                g.declared_phase = m.group(1)
            m = re.match(r"attribute redefines declaredPhaseAlternate = Phase::(\w+);", s)
            if m:
                g.declared_alt = m.group(1)
            m = re.match(r"attribute redefines declaredYear = ([\d.]+);", s)
            if m:
                g.declared_year = float(m.group(1))
            m = re.match(r"attribute redefines declaredYearEnd = ([\d.]+);", s)
            if m:
                g.declared_year_end = float(m.group(1))
            m = re.match(r"attribute redefines assumedOutcome = (true|false);", s)
            if m:
                g.assumed = m.group(1) == "true"
            m = re.match(r"calc (\w+) : (\w+);", s)
            if m:
                g.calcs.append((m.group(1), m.group(2)))
            m = re.match(r"attribute redefines prerequisites = \((.*)\);", s)
            if m:
                g.prerequisites = re.findall(r'"([^"]*)"', m.group(1))
            m = re.match(r"attribute redefines gatedElements = \((.*)\);", s)
            if m:
                g.gated = re.findall(r'"([^"]*)"', m.group(1))
            m = re.match(r"attribute econAssumed(?:Introduction)?Year : Integer = (\d+);", s)
            if m:
                g.econ_assumed_year = int(m.group(1))
        if g.supertype == "TestOutcomeGate" and g.assumed is None:
            g.assumed = True
        gates[g.gate_id] = g
    for usage, def_name in usages.items():
        for g in gates.values():
            if g.def_name == def_name:
                g.usage = usage
    return gates, usages


def parse_phase_windows(text: str) -> dict[str, tuple[int, int | None]]:
    windows = {}
    for m in re.finditer(r"attribute (p\d+|p14plus) : PhaseWindow \{\s*(?:doc\s*)?:>> startYear = (\d+);\s*:>> endYear = (\d+|null);", text):
        name = "P14plus" if m.group(1) == "p14plus" else m.group(1).upper()
        windows[name] = (int(m.group(2)), None if m.group(3) == "null" else int(m.group(3)))
    return windows


def parse_numeric_attributes(text: str, block_name: str) -> dict[str, float]:
    values = {}
    for kind, name, parents, body in top_level_blocks(text):
        if name != block_name:
            continue
        for line in body:
            m = re.match(r"\s*attribute (\w+) : (?:Real|Integer) = ([\d.]+);", line)
            if m:
                values[m.group(1)] = float(m.group(2))
    return values


def parse_calc_defs(text: str) -> set[str]:
    return {name for kind, name, _, _ in top_level_blocks(text) if kind == "calc"}


def parse_definition_phases(model: dict[str, str]) -> tuple[dict[str, dict[str, str]], dict[str, list[str]]]:
    """type -> {attribute: phase-or-null}; type -> parents. Definition-level
    values only (depth 1 of the part def block)."""
    declared: dict[str, dict[str, str]] = {}
    parents: dict[str, list[str]] = {}
    for fname, text in model.items():
        for kind, name, pars, body in top_level_blocks(text):
            if kind != "part":
                continue
            parents[name] = pars
            attrs = {}
            for line in body:
                s = line.strip()
                m = re.match(r"attribute redefines (\w+) = (?:Phase::(\w+)|(null));", s)
                if m:
                    attrs[m.group(1)] = m.group(2) or "null"
                    continue
                m = re.match(r"attribute (\w+) = Phase::(\w+);", s)
                if m:
                    attrs[m.group(1)] = m.group(2)
            declared[name] = attrs
    return declared, parents


def resolve_declared(type_name: str, attr: str, declared, parents) -> str | None:
    seen = set()
    stack = [type_name]
    while stack:
        t = stack.pop(0)
        if t in seen:
            continue
        seen.add(t)
        if attr in declared.get(t, {}):
            return declared[t][attr]
        stack.extend(parents.get(t, []))
    return None


@dataclass
class Binding:
    path: str
    type_name: str
    attr: str
    target: str          # "gate:dgX" | "element:massDriverNetwork.md2.operationalFrom" | "self:introducedIn"


def parse_configuration(text: str) -> tuple[list[Binding], dict[str, str]]:
    """Walk the configuration with a brace stack. Returns element bindings and
    the derivedYear expressions bound on gate usages."""
    bindings: list[Binding] = []
    derived_year_exprs: dict[str, str] = {}
    stack: list[tuple[str, str]] = []  # (name, type)
    for raw in text.splitlines():
        line = raw.strip()
        decl = re.match(r"(?:part|requirement) (?:redefines )?(\w+)(?: : (\w+))?\s*\{", line)
        m = re.match(r"attribute redefines (\w+) = (.+);", line)
        if m and stack:
            attr, expr = m.group(1), m.group(2).strip()
            name, tname = stack[-1]
            path = ".".join(n for n, _ in stack[2:]) if len(stack) > 2 else name
            if attr == "derivedYear" and name.startswith("dg"):
                derived_year_exprs[name] = expr
            elif re.match(r"gates\.(dg\w+)\.derivedPhase", expr):
                bindings.append(Binding(path, tname, attr, "gate:" + re.match(r"gates\.(dg\w+)", expr).group(1)))
            elif re.match(r"[\w.]+\.(operationalFrom|introducedIn|retiredIn|existsFrom)$", expr):
                bindings.append(Binding(path, tname, attr, "element:" + expr))
            elif expr in PHASE_ATTRS:
                bindings.append(Binding(path, tname, attr, "self:" + expr))
        for ch in line:
            if ch == "{":
                if decl:
                    stack.append((decl.group(1), decl.group(2) or ""))
                    decl = None
                else:
                    stack.append(("", ""))
            elif ch == "}":
                if stack:
                    stack.pop()
    return bindings, derived_year_exprs


def df_gate_ids(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    return set(re.findall(r"DG-(?:POST\.\d+|\d+\.(?:\d+|X))", text))
