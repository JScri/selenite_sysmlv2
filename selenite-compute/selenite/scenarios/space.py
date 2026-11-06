"""The parameter space and the decision catalogue, read from the model.

Wave 4A extension (6 Nov 2026), NOT a port, no golden. ``model/Scenarios.sysml``
declares the uncertain inputs (``UncertaintyRegister``: every entry an
``UncertainReal`` whose nominal / low / high are bound to ``ProgrammeParameters``
attributes), the decisions (``DecisionCatalogue``: ``variation part def`` with
``variant`` alternatives, metadata in a ``...Decision`` supertype), the
measures of value (``#moe`` attributes), the trade studies
(``analysis def`` with ``@ToolExecution``) and the named scenarios
(``ScenarioSet``). This module reads them by regular expression on top of
``modelio`` (the same primitives ``tools/plan_check.py`` uses) and builds the
``Dist`` list the sampler takes. Nothing here evaluates anything.

Rule 5d (CLAUDE_SYSML_CONTEXT.md): a register entry is sampled only when its
low and high are bound in ``ProgrammeParameters`` and its kind is not a
point; otherwise it is a point at nominal and the register says
"range unbound".
"""
from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from .modelio import MODEL_DIR, read_model, strip_comments, top_level_blocks
from .sample import Dist

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

KIND_BY_TYPE = {
    "PointReal": "pointValue",
    "UniformReal": "uniform",
    "TriangularReal": "triangular",
    "PertReal": "pert",
    "LogNormalReal": "logNormal",
    "DiscreteReal": "discrete",
}


# --------------------------------------------------------------------------
# Block helpers (nested bodies, which modelio.top_level_blocks does not give)
# --------------------------------------------------------------------------


def block_body(text: str, header_re: str) -> str:
    """The text inside the braces of the first block whose declaration line
    matches ``header_re`` (nested blocks included)."""
    m = re.search(header_re, text, re.M)
    if not m:
        raise KeyError(header_re)
    start = text.index("{", m.end() - 1)
    depth = 0
    for i in range(start, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return text[start + 1:i]
    raise ValueError(f"unbalanced block for {header_re}")


def nested_blocks(body: str, header_re: str):
    """Yield (match, inner_text) for every depth-1 block in ``body`` whose
    declaration matches ``header_re``."""
    pos = 0
    while True:
        m = re.compile(header_re, re.M).search(body, pos)
        if not m:
            return
        start = body.index("{", m.end() - 1)
        depth = 0
        end = None
        for i in range(start, len(body)):
            if body[i] == "{":
                depth += 1
            elif body[i] == "}":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end is None:
            raise ValueError("unbalanced block")
        yield m, body[start + 1:end]
        pos = end + 1


def _literal(expr: str):
    expr = expr.strip()
    if re.fullmatch(r"-?\d+", expr):
        return int(expr)
    if re.fullmatch(r"-?\d*\.\d+(e-?\d+)?|-?\d+e-?\d+", expr, re.I):
        return float(expr)
    if expr in ("true", "false"):
        return expr == "true"
    if expr.startswith('"') and expr.endswith('"'):
        return expr[1:-1]
    m = re.fullmatch(r"(\w+)::(\w+)", expr)
    if m:
        return expr
    return None


# --------------------------------------------------------------------------
# ProgrammeParameters: every attribute, expressions evaluated
# --------------------------------------------------------------------------


def parse_parameters(text: str, block_name: str = "ProgrammeParameters") -> dict[str, object]:
    """Every attribute of ``ProgrammeParameters`` (numbers, strings, enum
    bindings; ``None`` where unbound). Arithmetic expressions over sibling
    attributes (``1.0 - spaIlluminatedFraction``) are evaluated after the
    literals, in declaration order, so a derived value never has to be typed."""
    values: dict[str, object] = {}
    exprs: dict[str, str] = {}
    for kind, name, parents, body in top_level_blocks(text):
        if name != block_name:
            continue
        for s in _statements(body):
            m = re.match(r"attribute (\w+)(?: : [\w\[\]\.\* ]+?)?\s*(?:=\s*(.+?))?;$", s)
            if not m:
                continue
            attr, expr = m.group(1), m.group(2)
            if expr is None:
                values[attr] = None
                continue
            lit = _literal(expr)
            if lit is not None:
                values[attr] = lit
            else:
                exprs[attr] = expr
    for attr, expr in exprs.items():
        values[attr] = eval_parameter_expression(expr, values)
    return values


def _statements(body: list[str]) -> list[str]:
    """Join continuation lines so a statement that wraps (a derived attribute
    expression) is one string ending in ';'."""
    out, buf = [], ""
    for line in body:
        s = line.strip()
        if not s or re.fullmatch(r"doc(\s+\w+)?", s):   # a doc comment's stub after strip_comments
            continue
        buf = (buf + " " + s).strip() if buf else s
        if s.endswith(";") or s.endswith("{") or s.endswith("}"):
            out.append(buf)
            buf = ""
    if buf:
        out.append(buf)
    return out


def eval_parameter_expression(expr: str, values: dict[str, object]) -> float:
    e = expr.replace("\n", " ")
    e = re.sub(r"\b([A-Za-z_]\w*)\b", lambda m: _ref(m.group(1), values), e)
    if not re.fullmatch(r"[\d.eE+\-*/ ()]+", e):
        raise ValueError(f"unsupported parameter expression: {expr}")
    return float(eval(e))  # arithmetic on parameter values only


def _ref(name: str, values: dict[str, object]) -> str:
    if name not in values or values[name] is None:
        raise KeyError(f"parameter expression refers to unbound or unknown attribute {name}")
    return repr(float(values[name]))


# --------------------------------------------------------------------------
# UncertaintyRegister
# --------------------------------------------------------------------------


@dataclass
class RegisterEntry:
    name: str
    type_name: str
    bindings: dict[str, str]          # nominal/low/high -> ProgrammeParameters attribute name
    source: str
    nominal: float | None = None
    low: float | None = None
    high: float | None = None

    @property
    def kind(self) -> str:
        return KIND_BY_TYPE.get(self.type_name, "pointValue")

    @property
    def sampled(self) -> bool:
        return self.kind != "pointValue" and self.low is not None and self.high is not None and self.low != self.high

    @property
    def status(self) -> str:
        if self.nominal is None:
            return "point (nominal unbound, evaluator assumption)"
        if self.sampled:
            return "sampled"
        if self.kind == "pointValue" and self.low is not None and self.high is not None:
            return "point (range recorded, kind pointValue)"
        return "point (range unbound)"

    def to_dist(self) -> Dist:
        if self.kind == "discrete" and self.sampled:
            return Dist(self.name, "discrete", float(self.nominal), self.low, self.high,
                        values=(float(self.low), float(self.high)), source=self.source)
        if self.sampled:
            return Dist(self.name, self.kind, float(self.nominal), self.low, self.high, source=self.source)
        nominal = float("nan") if self.nominal is None else float(self.nominal)
        return Dist(self.name, "pointValue", nominal, source=self.source)


def parse_register(text: str, block_name: str = "UncertaintyRegister") -> list[RegisterEntry]:
    body = block_body(strip_comments(text), rf"^\s*part def {block_name}\b.*?\{{")
    entries = []
    for m, inner in nested_blocks(body, r"^\s*attribute (\w+) : (\w+)\s*\{"):
        name, type_name = m.group(1), m.group(2)
        bindings = {}
        source = ""
        for line in inner.splitlines():
            s = line.strip()
            b = re.match(r"attribute redefines (nominal|low|high) = parameters\.(\w+);", s)
            if b:
                bindings[b.group(1)] = b.group(2)
            sm = re.match(r'attribute redefines source = "(.*)";', s)
            if sm:
                source = sm.group(1)
        entries.append(RegisterEntry(name, type_name, bindings, source))
    return entries


def bind_register(entries: list[RegisterEntry], params: dict[str, object]) -> list[RegisterEntry]:
    for e in entries:
        for slot in ("nominal", "low", "high"):
            attr = e.bindings.get(slot)
            if attr is None:
                continue
            if attr not in params:
                raise KeyError(f"UncertaintyRegister.{e.name}.{slot} binds to unknown ProgrammeParameters.{attr}")
            v = params[attr]
            setattr(e, slot, None if v is None else float(v))
    return entries


# --------------------------------------------------------------------------
# DecisionCatalogue, MOEs, analyses, scenarios, selections
# --------------------------------------------------------------------------


@dataclass
class Alternative:
    name: str
    option_type: str
    source: str = ""


@dataclass
class DecisionSpec:
    variation: str
    option_type: str
    decision_id: str = ""
    title: str = ""
    stage: str = ""
    gates: list[str] = field(default_factory=list)
    uncertain_inputs: list[str] = field(default_factory=list)
    evaluator: str = ""
    evaluator_status: str = ""
    alternatives: list[Alternative] = field(default_factory=list)


def _string_list(expr: str) -> list[str]:
    return re.findall(r'"([^"]*)"', expr)


def parse_catalogue(text: str) -> list[DecisionSpec]:
    clean = strip_comments(text)
    meta: dict[str, dict] = {}
    for kind, name, parents, body in top_level_blocks(clean):
        if kind != "part" or "Decision" not in parents:
            continue
        d: dict = {"gates": [], "uncertain_inputs": []}
        for line in body:
            s = line.strip()
            for key, attr in (("decision_id", "decisionId"), ("title", "title"), ("evaluator", "evaluator"),
                              ("evaluator_status", "evaluatorStatus")):
                m = re.match(rf'attribute redefines {attr} = "(.*)";', s)
                if m:
                    d[key] = m.group(1)
            m = re.match(r"attribute stage = DecisionStage::(\w+);", s)
            if m:
                d["stage"] = m.group(1)
            m = re.match(r"attribute redefines gates = \((.*)\);", s)
            if m:
                d["gates"] = _string_list(m.group(1))
            m = re.match(r"attribute redefines uncertainInputs = \((.*)\);", s)
            if m:
                d["uncertain_inputs"] = _string_list(m.group(1))
        meta[name] = d
    specs = []
    for m, inner in nested_blocks(clean, r"^\s*variation part def (\w+) :> (\w+), (\w+)\s*\{"):
        variation, option_type, meta_name = m.group(1), m.group(2), m.group(3)
        spec = DecisionSpec(variation, option_type, **meta.get(meta_name, {}))
        for vm, vinner in nested_blocks(inner, r"^\s*variant part (\w+) : (\w+)\s*\{"):
            src = re.search(r'attribute redefines source = "(.*)";', vinner)
            spec.alternatives.append(Alternative(vm.group(1), vm.group(2), src.group(1) if src else ""))
        specs.append(spec)
    return sorted(specs, key=lambda s: s.decision_id)


def parse_moes(text: str) -> dict[str, list[str]]:
    """part def -> its #moe attribute names, parents' included."""
    clean = strip_comments(text)
    own: dict[str, list[str]] = {}
    parents: dict[str, list[str]] = {}
    for kind, name, pars, body in top_level_blocks(clean):
        if kind != "part":
            continue
        parents[name] = pars
        own[name] = [re.match(r"#moe attribute (\w+)", l.strip()).group(1)
                     for l in body if l.strip().startswith("#moe attribute ")]
    out = {}
    for name in own:
        seen, stack, moes = set(), [name], []
        while stack:
            t = stack.pop(0)
            if t in seen:
                continue
            seen.add(t)
            moes.extend(x for x in own.get(t, []) if x not in moes)
            stack.extend(parents.get(t, []))
        out[name] = moes
    return out


@dataclass
class AnalysisSpec:
    name: str
    option_type: str
    objective_moe: str
    tool_name: str
    uri: str


def parse_analyses(text: str) -> list[AnalysisSpec]:
    clean = strip_comments(text)
    out = []
    for m, inner in nested_blocks(clean, r"^\s*analysis def (\w+) :> TradeStudy\s*\{"):
        subj = re.search(r"subject options : (\w+)\[\*\];", inner)
        obj = re.search(r"return :>> result = option\.(\w+);", inner)
        tool = re.search(r'toolName = "([^"]*)";', inner)
        uri = re.search(r'uri = "([^"]*)";', inner)
        out.append(AnalysisSpec(m.group(1), subj.group(1) if subj else "", obj.group(1) if obj else "",
                                tool.group(1) if tool else "", uri.group(1) if uri else ""))
    return out


@dataclass
class ScenarioSpec:
    name: str
    overrides: dict[str, float]


def parse_scenarios(text: str, block_name: str = "ScenarioSet") -> list[ScenarioSpec]:
    body = block_body(strip_comments(text), rf"^\s*part def {block_name}\b.*?\{{")
    out = []
    for m, inner in nested_blocks(body, r"^\s*part (\w+) : ScenarioDef\s*\{"):
        overrides = {}
        name = m.group(1)
        for line in inner.splitlines():
            s = line.strip()
            b = re.match(r"attribute redefines (\w+) = (.+);", s)
            if not b:
                continue
            if b.group(1) == "scenarioName":
                name = b.group(2).strip('"')
            else:
                overrides[b.group(1)] = float(b.group(2))
        out.append(ScenarioSpec(name, overrides))
    return out


def parse_selections(config_text: str) -> dict[str, str | None]:
    """seleniteProgramme.dN -> 'Variation::variant' or None when abstract (open)."""
    clean = strip_comments(config_text)
    sel: dict[str, str | None] = {}
    for m in re.finditer(r"^\s*part (d\d+) :> (\w+::\w+);", clean, re.M):
        sel[m.group(1)] = m.group(2)
    for m in re.finditer(r"^\s*abstract part (d\d+) : (\w+);", clean, re.M):
        sel[m.group(1)] = None
    return sel


# --------------------------------------------------------------------------
# The space
# --------------------------------------------------------------------------


@dataclass
class Space:
    params: dict[str, object]
    register: list[RegisterEntry]
    decisions: list[DecisionSpec]
    moes: dict[str, list[str]]
    analyses: list[AnalysisSpec]
    scenarios: list[ScenarioSpec]
    selections: dict[str, str | None]
    thresholds: dict[str, float]

    @property
    def dists(self) -> list[Dist]:
        return [e.to_dist() for e in self.register]

    def entry(self, name: str) -> RegisterEntry:
        for e in self.register:
            if e.name == name:
                return e
        raise KeyError(name)

    def decision(self, decision_id: str) -> DecisionSpec:
        for d in self.decisions:
            if d.decision_id == decision_id:
                return d
        raise KeyError(decision_id)


def load_space(model_dir: Path | None = None) -> Space:
    model = read_model(model_dir or MODEL_DIR)
    params = parse_parameters(model["Parameters.sysml"])
    thresholds = {k: float(v) for k, v in parse_parameters(model["Parameters.sysml"], "GateThresholds").items()
                  if isinstance(v, (int, float)) and not isinstance(v, bool)}
    register = bind_register(parse_register(model["Scenarios.sysml"]), params)
    return Space(params, register, parse_catalogue(model["Scenarios.sysml"]), parse_moes(model["Scenarios.sysml"]),
                 parse_analyses(model["Scenarios.sysml"]), parse_scenarios(model["Scenarios.sysml"]),
                 parse_selections(model["ProgrammeConfiguration.sysml"]), thresholds)
