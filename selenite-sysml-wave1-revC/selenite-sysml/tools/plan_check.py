#!/usr/bin/env python3
"""plan_check.py - the derived-versus-declared register for the Selenite plan.

Wave 3 (15 Sep 2026). Reads the SysML v2 model by regular expression
(gates, thresholds, phase windows, definition-level phase attributes and the
configuration's bindings) and the Python computational layer
(``selenite.econ.workspace()``, ``selenite.verify.workspace()["ph"]``,
``selenite.psr_layout.workspace()``), evaluates every derivable gate
criterion on the year vectors, and prints three tables:

1. the gate register (every DecisionGate: declared phase / year, the phase
   the year implies, the derived year and phase, a verdict);
2. the element register (every phase attribute the configuration binds to a
   gate: definition value, gate, vector-derived value where one exists);
3. the discrepancy register in the W2-N table format (numbered W3-R rows).

Structural checks (exit code 1 on failure, so the compute CI job fails):
every DG id in the Decision Framework is a DecisionGate and vice versa;
every DerivableGate owns a calc and has an evaluator; every calc def
referenced exists; every gate the configuration binds to exists; every
threshold an evaluator reads exists. Discrepancies never fail the run: they
are the findings.

Usage:  python tools/plan_check.py [--markdown OUT.md] [--no-python]
"""
from __future__ import annotations

import argparse
import math
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MODEL = ROOT / "model"
DF_DOC = ROOT / "docs" / "SELENITE_DECISION_FRAMEWORK_v4.md"

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


def read_model() -> dict[str, str]:
    return {p.name: strip_comments(p.read_text(encoding="utf-8")) for p in sorted(MODEL.glob("*.sysml"))}


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


# --------------------------------------------------------------------------
# Year -> phase
# --------------------------------------------------------------------------


def year_phases(year: float | None, windows) -> list[str]:
    """Inclusive windows as the model defines them; boundary years belong to
    both phases (Y25 -> P7/P8). Years in the F7 gap return ['F7-gap']."""
    if year is None:
        return []
    if year < windows["P0"][0]:
        return ["P0"]
    hits = [p for p in PHASES if windows[p][0] <= year and (windows[p][1] is None or year <= windows[p][1])]
    return hits or ["F7-gap"]


def phase_index(p: str) -> int:
    return PHASES.index(p) if p in PHASES else -1


def fmt_phases(ps: list[str]) -> str:
    return "/".join(ps) if ps else "-"


def fmt_year(y) -> str:
    if y is None:
        return "-"
    if isinstance(y, str):
        return y
    return f"Y{int(y)}" if float(y).is_integer() else f"Y{y}"


# --------------------------------------------------------------------------
# Python layer
# --------------------------------------------------------------------------


@dataclass
class Ctx:
    w: dict
    ph: dict
    psr: dict
    T: dict[str, float]
    P: dict[str, float]

    def first_year(self, mask) -> int | None:
        import numpy as np
        idx = np.flatnonzero(np.asarray(mask))
        return int(idx[0]) if idx.size else None


def load_python() -> tuple[dict, dict, dict]:
    from selenite import econ, psr_layout, verify
    return econ.workspace(), verify.workspace()["ph"], psr_layout.workspace()


VERIFY_PHASES = ["P3", "P4", "P5", "P6", "P7"]


def verify_first_phase(mask) -> str | None:
    for label, ok in zip(VERIFY_PHASES, mask):
        if ok:
            return label
    return None


def circuit_earth_fraction(w):
    import numpy as np
    d = w["d_circuits"]
    with np.errstate(divide="ignore", invalid="ignore"):
        ef = w["cargo_circuits"] / (d * w["circuit"]["mass_kg"] / 1000)
    ef[d <= 0] = np.nan
    return ef


def hauler_earth_fraction(w):
    import numpy as np
    d = w["d_haulers"]
    with np.errstate(divide="ignore", invalid="ignore"):
        ef = w["cargo_haulers"] / (d * w["hauler"]["mass_kg"] / 1000)
    ef[d <= 0] = np.nan
    return ef


@dataclass
class Result:
    label: str
    year: int | str | None      # int year, 'never', or None (unevaluated); VERIFY phase strings allowed
    phase: str | None = None    # for VERIFY per-phase results
    detail: str = ""


def _thr(ctx: Ctx, name: str) -> float:
    if name not in ctx.T:
        raise KeyError(f"GateThresholds.{name} is not in Parameters.sysml")
    return ctx.T[name]


def ev_isru(ctx: Ctx, demand_key: str, label: str, need_dart: bool = False) -> list[Result]:
    ph = ctx.ph
    mask = ph["isru"] >= ph[demand_key]
    if need_dart:
        mask = mask & (ph["dD"] > 0)
    p = verify_first_phase(mask)
    return [Result(label, None if p is None else p, p, f"VERIFY ph.isru {list(map(int, ph['isru']))} vs ph.{demand_key} {[round(float(x)) for x in ph[demand_key]]} (P3..P7)")]


def ev_threshold(ctx: Ctx, key: str, thr_name: str, label: str, op=">=") -> list[Result]:
    import numpy as np
    v = np.asarray(ctx.w[key], dtype=float)
    t = _thr(ctx, thr_name)
    mask = v >= t if op == ">=" else (v > t if op == ">" else v <= t)
    y = ctx.first_year(mask)
    peak = f"max {v[~np.isnan(v)].max():,.4g}" if np.isnan(v).any() else f"max {v.max():,.4g}"
    return [Result(label, "never" if y is None else y, None,
                   f"ECON {key} {op} {t:,.4g} ({peak}; Y200 {v[-1]:,.4g})")]


EVALUATORS: dict[str, callable] = {}


def evaluator(gate_id):
    def deco(fn):
        EVALUATORS[gate_id] = fn
        return fn
    return deco


@evaluator("DG-3.2")
def _(ctx):
    return ev_isru(ctx, "dT", "ISRU supply >= total fleet demand")


@evaluator("DG-4.3")
def _(ctx):
    return ev_isru(ctx, "dP", "ISRU supply >= PROBE demand")


@evaluator("DG-5.1")
def _(ctx):
    return ev_isru(ctx, "dT", "ISRU supply >= demand incl. DART mission", need_dart=True)


@evaluator("DG-7.1")
def _(ctx):
    r = ev_threshold(ctx, "reo_target", "spaReoTonnesPerYearAtCommitment", "SPA REO >= 0.4 t/yr (DART sites/ppm assumed)")
    return r


@evaluator("DG-7.2")
def _(ctx):
    y = ctx.first_year(ctx.w["reo_target"] > 0)
    return [Result("first SPA processing output (reo_target > 0)", y, None, f"ECON reo_target first non-zero Y{y}")]


@evaluator("DG-7.4")
def _(ctx):
    f = ctx.w["reagent"]["isru_frac"]
    t = _thr(ctx, "reagentInSituFractionP7")
    y = next((int(yy) for yy in ctx.w["Y"] if f(yy) >= t), None)
    return [Result("in-situ reagent fraction >= 0.5", "never" if y is None else y, None, "ECON reagent.isru_frac(y) = min(0.98, max(0, (y-9) x 0.03))")]


@evaluator("DG-8.2")
def _(ctx):
    return ev_threshold(ctx, "circuits_needed", "circuitsFirstTranche", "circuits >= 100")


@evaluator("DG-8.4")
def _(ctx):
    return ev_threshold(ctx, "haulers_needed", "haulersFirstTranche", "haulers >= 50")


@evaluator("DG-8.5")
def _(ctx):
    return (ev_threshold(ctx, "reo_target", "reoTonnesPerYearP8", "REO >= 125 t/yr")
            + ev_threshold(ctx, "circuits_needed", "circuitsP8Complete", "circuits >= 308 (batch-design count)"))


@evaluator("DG-8.7")
def _(ctx):
    return [Result("Th(OH)4 stockpile >= 40 t", None, None, "no thorium vector in the Python layer (Wave 5)")]


@evaluator("DG-9.2")
def _(ctx):
    return ev_threshold(ctx, "haulers_needed", "haulersP9", "haulers >= 1,000")


@evaluator("DG-9.4")
def _(ctx):
    return ev_threshold(ctx, "insitu_total", "foundryTonnesPerYearP9", "in-situ manufactured mass >= 100 t/yr (foundry proxy)")


@evaluator("DG-9.7")
def _(ctx):
    return ev_threshold(ctx, "conv_km_needed", "conveyorKmPilot", "conveyor >= 500 km")


@evaluator("DG-10.1")
def _(ctx):
    return ev_threshold(ctx, "haulers_needed", "haulersP10", "haulers >= 14,881")


@evaluator("DG-10.2")
def _(ctx):
    return ev_threshold(ctx, "conv_km_needed", "conveyorKmP10", "conveyor >= 5,000 km")


@evaluator("DG-10.3")
def _(ctx):
    return ev_threshold(ctx, "insitu_total", "foundryTonnesPerYearP10", "in-situ manufactured mass >= 1,000 t/yr (foundry proxy)")


@evaluator("DG-10.4")
def _(ctx):
    import numpy as np
    w = ctx.w
    r = ev_threshold(ctx, "msr_count", "msrUnitsP10", "MSR units >= 74")
    msr_w = w["msr_count"] * w["msr"]["power_mw"] * 1e6
    fsp_w = w["fsp_count"] * w["fsp"]["power_kw"] * 1e3
    y1 = ctx.first_year((msr_w > 0) & (msr_w >= fsp_w))
    y2 = ctx.first_year((np.arange(201) >= 45) & (w["fsp_count"] <= 20))
    r.append(Result("FSP field superseded: MSR installed power >= FSP installed power", y1, None,
                    f"ECON msr_count x 100 MWe vs fsp_count x 40 kWe; ECON caps fsp_count at 20 units from Y{y2} (its own FSP phase-out)"))
    return r


def ev_spa_msr(ctx: Ctx, unit: int) -> list[Result]:
    y = ctx.first_year(ctx.w["spa_msr_count"] >= unit)
    return [Result(f"SPA MSR unit #{unit}: demand > non-MSR capability", None, None,
                   f"no SPA demand vector beyond P7 (unevaluated); ECON spa_msr_count reaches {unit} at Y{y}")]


@evaluator("DG-10.5")
def _(ctx):
    return ev_spa_msr(ctx, 1)


@evaluator("DG-11.3")
def _(ctx):
    return ev_spa_msr(ctx, 1)


@evaluator("DG-13.4")
def _(ctx):
    return ev_spa_msr(ctx, 1)


@evaluator("DG-14.4")
def _(ctx):
    return ev_spa_msr(ctx, 2)


@evaluator("DG-14.7")
def _(ctx):
    return ev_spa_msr(ctx, 3)


@evaluator("DG-11.1")
def _(ctx):
    return (ev_threshold(ctx, "reo_target", "reoTonnesPerYearP11", "REO >= 100,000 t/yr")
            + ev_threshold(ctx, "supply_frac", "displacementFractionP11", "supply fraction >= 10%"))


@evaluator("DG-11.2")
def _(ctx):
    return ev_threshold(ctx, "msr_count", "msrUnitsP11", "MSR units >= 679")


@evaluator("DG-11.5")
def _(ctx):
    return ev_threshold(ctx, "conv_km_needed", "conveyorKmP11", "conveyor >= 15,000 km")


@evaluator("DG-11.6")
def _(ctx):
    import numpy as np
    w = ctx.w
    cap = ctx.P["psrMoleICapacityUnits"]
    need = np.asarray(w["molei_needed"], dtype=float)
    y = ctx.first_year(need > cap)
    y310 = ctx.first_year(need > 310)
    r = [Result(f"Mk III forced: chemical MOLE-I need > PSR capacity ({cap:.0f})", "never" if y is None else y, None,
                f"ECON molei_needed peak {need.max():.0f} at Y{int(need.argmax())}; with the fleet v9 figure 310 the need exceeds capacity at Y{y310} (sensitivity only, W2-N18)")]
    r += ev_threshold(ctx, "total_pgm", "pgmExportTriggerTonnesPerYear", "MD-4 trigger: PGM concentrate > 100 t/yr", op=">")
    return r


@evaluator("DG-12.1")
def _(ctx):
    return (ev_threshold(ctx, "reo_target", "reoTonnesPerYearP12", "REO >= 500,000 t/yr")
            + ev_threshold(ctx, "supply_frac", "displacementFractionP12", "supply fraction >= 40%"))


@evaluator("DG-12.2")
def _(ctx):
    return ev_threshold(ctx, "msr_count", "msrUnitsP12", "MSR units >= 6,890")


@evaluator("DG-12.3")
def _(ctx):
    import numpy as np
    per_day = np.asarray(ctx.w["canisters_yr"], dtype=float) / 365.0
    t = _thr(ctx, "canistersPerDaySteadyState")
    y = ctx.first_year(per_day >= t)
    return [Result("MD-2 cadence >= 783/day", "never" if y is None else y, None,
                   f"ECON canisters_yr / 365 (3.5 t per canister; Y200 {per_day[-1]:,.0f}/day; ECN-020 corrected the 2.5 Mt/yr cadence to ~1,903/day)")]


@evaluator("DG-12.6")
def _(ctx):
    return ev_threshold(ctx, "captured_asteroid_pgm", "mTypePgmTonnesPerYear", "captured-asteroid PGM >= 36.5 t/yr")


@evaluator("DG-13.1")
def _(ctx):
    return (ev_threshold(ctx, "reo_target", "reoTonnesPerYearP13", "REO >= 1,250,000 t/yr")
            + ev_threshold(ctx, "supply_frac", "displacementFractionP13", "supply fraction >= 50%"))


@evaluator("DG-13.5")
def _(ctx):
    import numpy as np
    ef = circuit_earth_fraction(ctx.w)
    t = _thr(ctx, "circuitEarthFractionPostCType")
    y = ctx.first_year(np.nan_to_num(ef, nan=1.0) <= t)
    return [Result("circuit Earth fraction <= 3%", "never" if y is None else y, None,
                   "ECON cargo_circuits / (d_circuits x circuit.mass_kg), years with new circuits only")]


@evaluator("DG-13.7")
def _(ctx):
    import numpy as np
    ef = hauler_earth_fraction(ctx.w)
    t = _thr(ctx, "haulerEarthFractionFloor")
    y = ctx.first_year(np.nan_to_num(ef, nan=1.0) <= t)
    return [Result("hauler Earth fraction <= 20%", "never" if y is None else y, None,
                   f"ECON hauler Earth fraction floors at {np.nanmin(ef):.2f} (hauler.earth_frac 0.43 floor less the M-type bonus); never reaches 0.20")]


@evaluator("DG-14.5")
def _(ctx):
    import numpy as np
    ef = circuit_earth_fraction(ctx.w)
    t = _thr(ctx, "circuitEarthFractionPostSType")
    y = ctx.first_year(np.nan_to_num(ef, nan=1.0) <= t)
    return [Result("circuit Earth fraction <= 0.8%", "never" if y is None else y, None,
                   "ECON cargo_circuits / (d_circuits x circuit.mass_kg)")]


@evaluator("DG-14.6")
def _(ctx):
    import numpy as np
    w = ctx.w
    earth = np.asarray(w["earth_cargo"], dtype=float)
    total = earth + np.asarray(w["insitu_total"], dtype=float)
    t = _thr(ctx, "earthDependencyMaximumFraction")
    with np.errstate(divide="ignore", invalid="ignore"):
        frac = np.where(total > 0, earth / total, np.nan)
    y = ctx.first_year(np.nan_to_num(frac, nan=1.0) < t)
    return [Result("Earth-supplied mass < 0.5% of infrastructure mass flow", "never" if y is None else y, None,
                   f"annual-flow proxy earth_cargo / (earth_cargo + insitu_total): minimum {np.nanmin(frac):.1%} at Y{int(np.nanargmin(frac))}")]


@evaluator("DG-14.8")
def _(ctx):
    import numpy as np
    v = np.asarray(ctx.w["reo_target"], dtype=float)
    t = ctx.P["steadyStateReoTonnesPerYear"]
    y = ctx.first_year(v >= t)
    return [Result("REO >= 2,500,000 t/yr", "never" if y is None else y, None,
                   f"ECON reo_target reaches the target at Y{y}; ProgrammeParameters.steadyStateYear = {ctx.P['steadyStateYear']:.0f}")]


@evaluator("DG-14.9")
def _(ctx):
    import numpy as np
    w = ctx.w
    act = np.asarray(w["mkiii_active"], dtype=float)
    t = _thr(ctx, "mkIiiProspectingFleet")
    complete = int(ctx.P["sTypeCaptureYear"] + ctx.P["asteroidOnlineLagYears"])
    peak_y = int(act.argmax())
    after_peak = np.arange(201) > peak_y
    y_red = ctx.first_year(after_peak & (act <= t))
    y = ctx.first_year(after_peak & (act <= t) & (np.arange(201) >= complete))
    return [Result("Mk III active <= 300 with all captures complete", "never" if y is None else y, None,
                   f"ECON mkiii_active falls to {t:.0f} at Y{y_red}; captures complete at Y{complete} (sTypeCaptureYear + lag)")]


@evaluator("DG-POST.1")
def _(ctx):
    return [Result("Tier 1 approaching depletion", None, None, "tier1ResourceTonnes unbound; ECON stops at Y200 (Wave 5)")]


@evaluator("DG-POST.2")
def _(ctx):
    return [Result("Tier 2 approaching depletion", None, None, "tier2ResourceTonnes unbound (Wave 5)")]


# Element-level vector checks: (type, attribute) -> function(ctx) -> Result
ELEMENT_VECTORS: dict[tuple[str, str], callable] = {}


def element_vector(type_name, attr):
    def deco(fn):
        ELEMENT_VECTORS[(type_name, attr)] = fn
        return fn
    return deco


def verify_first(ctx, key, pred, detail):
    mask = pred(ctx.ph[key])
    p = verify_first_phase(mask)
    return Result(key, p, p, detail)


@element_vector("Skip", "introducedIn")
def _(ctx):
    return verify_first(ctx, "nS", lambda v: v > 0, "VERIFY ph.nS = " + str([int(x) for x in ctx.ph["nS"]]))


@element_vector("SkipHopLink", "introducedIn")
def _(ctx):
    return verify_first(ctx, "nS", lambda v: v > 0, "VERIFY ph.nS (SKIP count)")


@element_vector("Dart", "introducedIn")
def _(ctx):
    return verify_first(ctx, "nD", lambda v: v > 0, "VERIFY ph.nD = " + str([int(x) for x in ctx.ph["nD"]]))


@element_vector("CrewedHub", "crewedFrom")
def _(ctx):
    return verify_first(ctx, "crew", lambda v: v > 0, "VERIFY ph.crew = " + str([int(x) for x in ctx.ph["crew"]]))


@element_vector("HabitatComplex", "crewedFrom")
def _(ctx):
    return verify_first(ctx, "crew", lambda v: v > 0, "VERIFY ph.crew")


@element_vector("Eclss", "introducedIn")
def _(ctx):
    return verify_first(ctx, "p_hab", lambda v: v > 0, "VERIFY ph.p_hab (habitat power) first non-zero")


@element_vector("Cap", "introducedIn")
def _(ctx):
    return verify_first(ctx, "p_cap", lambda v: v > 0, "VERIFY ph.p_cap (CAP standby power) = " + str([float(x) for x in ctx.ph["p_cap"]]))


@element_vector("ProbeMkI", "isruFuelledFrom")
def _(ctx):
    ph = ctx.ph
    p = verify_first_phase(ph["isru"] >= ph["dP"])
    return Result("isru>=dP", p, p, "VERIFY ph.isru >= ph.dP (the P3 units are Earth-fuelled by policy)")


@element_vector("IsruPlant", "selfSufficientFrom")
def _(ctx):
    ph = ctx.ph
    p = verify_first_phase(ph["isru"] >= ph["dT"])
    return Result("isru>=dT", p, p, "VERIFY ph.isru >= ph.dT")


def econ_first(ctx, key, pred, detail):
    y = ctx.first_year(pred(ctx.w[key]))
    return Result(key, "never" if y is None else y, None, detail)


@element_vector("ThoriumMSR", "introducedIn")
def _(ctx):
    return econ_first(ctx, "msr_count", lambda v: v > 0, "ECON msr_count first non-zero")


@element_vector("PktFspField", "retiredIn")
def _(ctx):
    import numpy as np
    w = ctx.w
    y = ctx.first_year((np.arange(201) >= 45) & (w["fsp_count"] <= 20))
    return Result("fsp_count", y, None, "ECON fsp_count reaches its 20-unit floor (FSP phase-out complete)")


@element_vector("SpaThoriumMSR", "introducedIn")
def _(ctx):
    return econ_first(ctx, "spa_msr_count", lambda v: v > 0, "ECON spa_msr_count first non-zero (the economics' assumption, F5)")


@element_vector("ProbeMkIII", "introducedIn")
def _(ctx):
    return econ_first(ctx, "mkiii_active", lambda v: v > 0, "ECON mkiii_active first non-zero")


@element_vector("ProbeMkIII", "prospectingRoleFrom")
def _(ctx):
    import numpy as np
    act = np.asarray(ctx.w["mkiii_active"])
    y = ctx.first_year((np.arange(201) > act.argmax()) & (act <= 300))
    return Result("mkiii_active", y, None, "ECON mkiii_active falls to the 300-unit prospecting fleet")


@element_vector("RedirectTug", "introducedIn")
def _(ctx):
    return econ_first(ctx, "tug_fleet", lambda v: v > 0, "ECON tug_fleet first non-zero (build precedes the Y75 redirect)")


@element_vector("HaulerRevB", "introducedIn")
def _(ctx):
    return econ_first(ctx, "haulers_needed", lambda v: v >= 10, "ECON haulers_needed >= 10 (Wave 1 Pioneer count; ECON assigns haulers to SPA research output from Y20, W3-N8)")


@element_vector("ConveyorNetwork", "introducedIn")
def _(ctx):
    return econ_first(ctx, "conv_km_needed", lambda v: v > 0, "ECON conv_km_needed first non-zero")


@element_vector("MassDriverMd2", "operationalFrom")
def _(ctx):
    return econ_first(ctx, "canisters_yr", lambda v: v > 0, "ECON canisters_yr first non-zero")


@element_vector("DroStation", "existsFrom")
def _(ctx):
    return econ_first(ctx, "captured_asteroid_pgm", lambda v: v > 0, "ECON captured_asteroid_pgm first non-zero")


@element_vector("LaserAblationTruss", "introducedIn")
def _(ctx):
    return econ_first(ctx, "captured_asteroid_pgm", lambda v: v > 0, "ECON captured_asteroid_pgm first non-zero")


@element_vector("MTypeProcessingLine", "introducedIn")
def _(ctx):
    return econ_first(ctx, "captured_asteroid_pgm", lambda v: v > 0, "ECON captured_asteroid_pgm first non-zero")


@element_vector("Foundry", "introducedIn")
def _(ctx):
    return econ_first(ctx, "insitu_total", lambda v: v > 0, "ECON insitu_total first non-zero (in-situ manufacture)")


@element_vector("PktProcessingSpine", "introducedIn")
def _(ctx):
    return econ_first(ctx, "circuits_needed", lambda v: v >= 100, "ECON circuits_needed >= 100 (first PKT tranche, DG-8.2)")


@element_vector("Skip", "retiredIn")
def _(ctx):
    import numpy as np
    sk = np.asarray(ctx.w["skip_active"])
    y = ctx.first_year((np.arange(201) > 30) & (sk <= 0))
    y0 = ctx.first_year((np.arange(201) > 30) & (sk < 8))
    return Result("skip_active", y, None, f"ECON skip_active ramps 8 -> 0 over Y{y0}-Y{y}")


@element_vector("SkipHopLink", "retiredIn")
def _(ctx):
    import numpy as np
    sk = np.asarray(ctx.w["skip_active"])
    y = ctx.first_year((np.arange(201) > 30) & (sk <= 0))
    return Result("skip_active", y, None, "ECON skip_active reaches zero")


# --------------------------------------------------------------------------
# Register
# --------------------------------------------------------------------------


@dataclass
class GateRow:
    gate: Gate
    year_phases: list[str]
    results: list[Result]
    derived_year: int | str | None
    derived_phases: list[str]
    verdict: str
    note: str


def verdict_for(declared: set[str], derived: list[str], derived_year) -> str:
    if derived_year is None:
        return "unevaluated"
    if derived_year == "never":
        return "never met on current vectors"
    if not derived:
        return "unevaluated"
    if set(derived) & declared:
        return "consistent"
    d_idx = min(phase_index(p) for p in derived if p in PHASES) if any(p in PHASES for p in derived) else -1
    c_idx = min(phase_index(p) for p in declared if p in PHASES) if any(p in PHASES for p in declared) else -1
    if d_idx < 0 or c_idx < 0:
        return "differs"
    return "earlier than declared" if d_idx < c_idx else "later than declared"


def evaluate_gates(gates: dict[str, Gate], windows, derived_exprs, params, ctx: Ctx | None) -> list[GateRow]:
    rows = []
    for gid in sorted(gates, key=gate_sort_key):
        g = gates[gid]
        yp = year_phases(g.declared_year, windows)
        declared = {g.declared_phase} | ({g.declared_alt} if g.declared_alt else set())
        results: list[Result] = []
        derived_year = None
        derived_phases: list[str] = []
        note = ""
        if g.evaluability == "derivable":
            if ctx is None:
                note = "python layer not loaded"
            elif gid in EVALUATORS:
                results = EVALUATORS[gid](ctx)
                first = results[0]
                if first.phase:            # VERIFY per-phase result
                    derived_year = first.phase
                    derived_phases = [first.phase]
                elif isinstance(first.year, int):
                    derived_year = first.year
                    derived_phases = year_phases(first.year, windows)
                else:
                    derived_year = first.year
            else:
                note = "NO EVALUATOR"
        elif g.evaluability == "exogenous":
            expr = derived_exprs.get(g.usage)
            if expr:
                derived_year = eval_expr(expr, params)
                derived_phases = year_phases(derived_year, windows)
                note = f"derivedYear = {expr}"
            else:
                derived_year = "declared"
                derived_phases = [g.declared_phase]
                note = "exogenous: no parameter carries the year"
        else:  # testOutcome
            derived_year = "assumed"
            derived_phases = [g.declared_phase] if g.assumed else []
            note = "assumedOutcome = true" if g.assumed else "assumedOutcome = false"
        if derived_year in ("declared", "assumed"):
            verdict = derived_year
        else:
            verdict = verdict_for(declared, derived_phases, derived_year)
        if g.declared_year is not None and yp and not (set(yp) & declared) and "gap" not in yp[0]:
            note = (note + "; " if note else "") + f"declared year {fmt_year(g.declared_year)} is {fmt_phases(yp)} by the year table"
        elif yp and "gap" in yp[0]:
            note = (note + "; " if note else "") + "declared year lies in the F7 gap"
        rows.append(GateRow(g, yp, results, derived_year, derived_phases, verdict, note))
    return rows


def eval_expr(expr: str, params: dict[str, float]) -> int:
    e = re.sub(r"parameters\.(\w+)", lambda m: str(params[m.group(1)]), expr)
    if not re.fullmatch(r"[\d.+\-*/ ()]+", e):
        raise ValueError(f"unsupported derivedYear expression: {expr}")
    return int(eval(e))  # arithmetic on parameter values only


def gate_sort_key(gid: str):
    m = re.match(r"DG-(POST)?\.?(\d+)?\.?(\d+|X)?", gid)
    if gid.startswith("DG-POST"):
        return (99, int(gid.split(".")[1]), 0)
    major, minor = gid[3:].split(".")
    minor_v = 99 if minor == "X" else int(minor)
    order_override = {"DG-14.1": (13, 2, 1)}  # listed inside P13 after DG-13.2
    return order_override.get(gid, (int(major), minor_v, 0))


@dataclass
class ElementRow:
    binding: Binding
    declared: str | None
    gate: Gate | None
    gate_row: GateRow | None
    vector: Result | None
    verdict: str


def evaluate_elements(bindings, gates, gate_rows, declared, parents, windows, ctx) -> list[ElementRow]:
    by_usage = {g.usage: g for g in gates.values()}
    rows_by_id = {r.gate.gate_id: r for r in gate_rows}
    out = []
    for b in bindings:
        decl = resolve_declared(b.type_name, b.attr, declared, parents)
        g = gr = None
        if b.target.startswith("gate:"):
            g = by_usage.get(b.target[5:])
            gr = rows_by_id.get(g.gate_id) if g else None
        vec = None
        if ctx is not None and (b.type_name, b.attr) in ELEMENT_VECTORS:
            vec = ELEMENT_VECTORS[(b.type_name, b.attr)](ctx)
        verdict = element_verdict(decl, g, gr, vec, windows)
        out.append(ElementRow(b, decl, g, gr, vec, verdict))
    return out


def element_verdict(decl, g, gr, vec, windows) -> str:
    parts = []
    if g is not None:
        gate_phases = {g.declared_phase} | ({g.declared_alt} if g.declared_alt else set())
        if decl in (None, "null"):
            parts.append("def unbound -> gate")
        elif decl in gate_phases:
            parts.append("def = gate")
        else:
            parts.append(f"def {decl} vs gate {'/'.join(sorted(gate_phases, key=phase_index))}")
    if vec is not None:
        vphases = [vec.phase] if vec.phase else (year_phases(vec.year, windows) if isinstance(vec.year, int) else [])
        if vec.year is None:
            parts.append("vector: n/a")
        elif vec.year == "never":
            parts.append("vector: never")
        elif decl in vphases:
            parts.append("vector = def")
        elif vec.phase and phase_index(vec.phase) == 0 + phase_index("P3") and decl and phase_index(decl) < phase_index("P3"):
            parts.append("vector starts at P3 (inconclusive)")
        else:
            parts.append(f"vector {fmt_phases(vphases)} vs def {decl}")
    return "; ".join(parts) if parts else "-"


# --------------------------------------------------------------------------
# Structural checks
# --------------------------------------------------------------------------


def structural_checks(gates, usages, calc_defs, bindings, derived_exprs, thresholds, df_ids) -> list[str]:
    errors = []
    model_ids = set(gates)
    if df_ids - model_ids:
        errors.append(f"Decision Framework gates missing from Gates.sysml: {sorted(df_ids - model_ids)}")
    if model_ids - df_ids:
        errors.append(f"Gates.sysml gates not in the Decision Framework: {sorted(model_ids - df_ids)}")
    def_names = {g.def_name for g in gates.values()}
    cat = set(usages.values())
    if def_names - cat:
        errors.append(f"gate defs missing from GateCatalogue: {sorted(def_names - cat)}")
    if len(usages) != len(set(usages.values())):
        errors.append("GateCatalogue lists a gate def twice")
    for g in gates.values():
        if g.evaluability == "derivable":
            if not g.calcs:
                errors.append(f"{g.gate_id}: DerivableGate without a calc usage")
            if g.gate_id not in EVALUATORS:
                errors.append(f"{g.gate_id}: DerivableGate without an evaluator in plan_check.py")
        for _, calc in g.calcs:
            if calc not in calc_defs:
                errors.append(f"{g.gate_id}: calc def {calc} not found in ThroughputCalcs.sysml")
        if not g.gate_id or not g.criterion or not g.declared_phase:
            errors.append(f"{g.def_name}: gateId, criterion or declaredPhase missing")
    usage_names = set(usages)
    for b in bindings:
        if b.target.startswith("gate:") and b.target[5:] not in usage_names:
            errors.append(f"configuration binds {b.path}.{b.attr} to unknown gate usage {b.target[5:]}")
    for u in derived_exprs:
        if u not in usage_names:
            errors.append(f"configuration binds derivedYear on unknown gate usage {u}")
    used_thresholds = set(re.findall(r'_thr\(ctx, "(\w+)"\)', Path(__file__).read_text(encoding="utf-8")))
    for t in sorted(used_thresholds - set(thresholds)):
        errors.append(f"evaluator reads GateThresholds.{t}, which is not in Parameters.sysml")
    return errors


# --------------------------------------------------------------------------
# Output
# --------------------------------------------------------------------------


def md_table(headers, rows) -> str:
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c).replace("|", "\\|") for c in r) + " |")
    return "\n".join(out)


def render(gate_rows: list[GateRow], elem_rows: list[ElementRow], errors, ctx_loaded: bool, thresholds, params) -> str:
    lines = []
    lines.append("# Selenite plan check - derived-versus-declared register")
    lines.append("")
    lines.append(f"Gates: {len(gate_rows)}; derivable {sum(1 for r in gate_rows if r.gate.evaluability == 'derivable')}, "
                 f"testOutcome {sum(1 for r in gate_rows if r.gate.evaluability == 'testOutcome')}, "
                 f"exogenous {sum(1 for r in gate_rows if r.gate.evaluability == 'exogenous')}. "
                 f"Element bindings: {len(elem_rows)}. Python layer: {'loaded' if ctx_loaded else 'not loaded (--no-python)'}.")
    lines.append("")
    lines.append("Phase of a year: inclusive windows from SelenitePhases::ProgrammeTimeline; a boundary year "
                 "belongs to both phases (Y25 = P7/P8). Verdicts compare the derived phase with declaredPhase "
                 "and declaredPhaseAlternate. 'never met on current vectors' means the criterion as written is "
                 "false in every year to Y200 of the ECON v1.3/v1.4 port - a finding, not a decision.")
    lines.append("")
    lines.append("## 1. Gate register")
    lines.append("")
    rows = []
    for r in gate_rows:
        g = r.gate
        declared = g.declared_phase + (f" (alt {g.declared_alt})" if g.declared_alt else "")
        dy = fmt_year(g.declared_year) + (f"-{fmt_year(g.declared_year_end)}" if g.declared_year_end else "")
        if r.results:
            derived = "; ".join(
                f"{res.label}: {fmt_year(res.year) if res.year is not None else 'unevaluated'}"
                + (f" ({fmt_phases(year_phases(res.year, WINDOWS))})" if isinstance(res.year, int) else "")
                for res in r.results)
            detail = " / ".join(res.detail for res in r.results if res.detail)
        else:
            derived = fmt_year(r.derived_year) if r.derived_year not in ("declared", "assumed") else r.derived_year
            if isinstance(r.derived_year, int):
                derived += f" ({fmt_phases(r.derived_phases)})"
            detail = ""
        note = "; ".join(x for x in (r.note, detail) if x)
        rows.append([g.gate_id, g.evaluability, declared, dy, fmt_phases(r.year_phases), derived, r.verdict, note])
    lines.append(md_table(["Gate", "Kind", "Declared phase", "Declared year", "Year-phase", "Derived", "Verdict", "Note"], rows))
    lines.append("")
    lines.append("## 2. Element register (configuration bindings)")
    lines.append("")
    rows = []
    for e in elem_rows:
        b = e.binding
        target = b.target.split(":", 1)[1]
        if e.gate:
            target = f"{e.gate.gate_id} ({e.gate.declared_phase}{', alt ' + e.gate.declared_alt if e.gate.declared_alt else ''}, {fmt_year(e.gate.declared_year)})"
        gate_derived = "-"
        if e.gate_row:
            gr = e.gate_row
            if isinstance(gr.derived_year, int) or (isinstance(gr.derived_year, str) and gr.derived_year.startswith("P")):
                gate_derived = f"{fmt_year(gr.derived_year)} ({fmt_phases(gr.derived_phases)})"
            else:
                gate_derived = str(gr.derived_year)
        vec = "-"
        if e.vector is not None:
            v = e.vector
            if v.phase:
                vec = f"{v.phase} - {v.detail}"
            elif isinstance(v.year, int):
                vec = f"Y{v.year} ({fmt_phases(year_phases(v.year, WINDOWS))}) - {v.detail}"
            else:
                vec = f"{v.year or 'n/a'} - {v.detail}"
        rows.append([f"{b.path}.{b.attr}", b.type_name, e.declared or "unbound", target, gate_derived, vec, e.verdict])
    lines.append(md_table(["Element.attribute", "Type", "Definition value", "Bound to", "Gate derived", "Vector-derived", "Verdict"], rows))
    lines.append("")
    lines.append("## 3. Discrepancy register (W2-N table format)")
    lines.append("")
    reg = discrepancy_rows(gate_rows, elem_rows)
    lines.append(md_table(["#", "Observation", "Where"], [[f"W3-R{i}", obs, where] for i, (obs, where) in enumerate(reg, 1)]))
    lines.append("")
    lines.append("## 4. Structural checks")
    lines.append("")
    lines.append("All structural checks passed." if not errors else "\n".join(f"- ERROR: {e}" for e in errors))
    lines.append("")
    return "\n".join(lines)


def discrepancy_rows(gate_rows, elem_rows) -> list[tuple[str, str]]:
    rows = []
    for r in gate_rows:
        g = r.gate
        if r.verdict in ("earlier than declared", "later than declared", "never met on current vectors", "differs"):
            first = r.results[0] if r.results else None
            d = fmt_year(r.derived_year) + (f" ({fmt_phases(r.derived_phases)})" if r.derived_phases and isinstance(r.derived_year, int) else "")
            detail = first.detail if first else r.note
            obs = (f"{g.gate_id} {g.criterion[:70].rstrip()}{'...' if len(g.criterion) > 70 else ''}: declared "
                   f"{fmt_year(g.declared_year)} ({g.declared_phase}{'/' + g.declared_alt if g.declared_alt else ''}); "
                   f"derived {d} - {detail}")
            rows.append((obs, "Gates.sysml / econ.py" if g.evaluability == "derivable" else "Gates.sysml / Parameters.sysml"))
        elif r.verdict == "unevaluated" and g.evaluability == "derivable":
            first = r.results[0] if r.results else None
            rows.append((f"{g.gate_id}: derivable but unevaluated - {first.detail if first else r.note}", "Gates.sysml / Parameters.sysml"))
        if r.note and "by the year table" in r.note:
            rows.append((f"{g.gate_id}: listed under {g.declared_phase}{' (alt ' + g.declared_alt + ')' if g.declared_alt else ''} "
                         f"but its year {fmt_year(g.declared_year)} is {fmt_phases(r.year_phases)}", "Gates.sysml / Phases.sysml"))
        if r.note and "F7 gap" in r.note:
            rows.append((f"{g.gate_id}: declared year {fmt_year(g.declared_year)} lies in the F7 gap (Y15-Y18)", "Gates.sysml / Phases.sysml (F7)"))
        if len(r.results) > 1:
            ys = [res.year for res in r.results]
            if len({str(y) for y in ys}) > 1:
                rows.append((f"{g.gate_id}: its criteria split - " + "; ".join(f"{res.label} -> {fmt_year(res.year) if res.year is not None else 'unevaluated'}" for res in r.results), "Gates.sysml / econ.py"))
    for e in elem_rows:
        if e.verdict.startswith("def ") and " vs gate " in e.verdict:
            rows.append((f"{e.binding.path}.{e.binding.attr}: definition {e.declared} but bound to {e.gate.gate_id} ({e.gate.declared_phase}{'/' + e.gate.declared_alt if e.gate.declared_alt else ''}, {fmt_year(e.gate.declared_year)})",
                         "ProgrammeConfiguration.sysml"))
        if e.vector is not None and ("vs def" in e.verdict or "vector: never" in e.verdict):
            v = e.vector
            vy = v.phase or fmt_year(v.year)
            rows.append((f"{e.binding.path}.{e.binding.attr}: definition {e.declared or 'unbound'}, vector says {vy} - {v.detail}", "ProgrammeConfiguration.sysml / selenite-compute"))
    return rows


WINDOWS: dict = {}


def main(argv=None) -> int:
    global WINDOWS
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--markdown", type=Path, help="write the register to this file as well as stdout")
    ap.add_argument("--no-python", action="store_true", help="structural checks and model tables only")
    ap.add_argument("--quiet", action="store_true", help="print only the discrepancy register and the check result")
    args = ap.parse_args(argv)

    model = read_model()
    gates, usages = parse_gates(model["Gates.sysml"])
    WINDOWS = parse_phase_windows(model["Phases.sysml"])
    thresholds = parse_numeric_attributes(model["Parameters.sysml"], "GateThresholds")
    params = parse_numeric_attributes(model["Parameters.sysml"], "ProgrammeParameters")
    calc_defs = parse_calc_defs(model["ThroughputCalcs.sysml"])
    declared, parents = parse_definition_phases(model)
    bindings, derived_exprs = parse_configuration(model["ProgrammeConfiguration.sysml"])
    df_ids = df_gate_ids(DF_DOC)

    errors = structural_checks(gates, usages, calc_defs, bindings, derived_exprs, thresholds, df_ids)

    ctx = None
    if not args.no_python:
        w, ph, psr = load_python()
        ctx = Ctx(w, ph, psr, thresholds, params)
        n_total = int(psr["n_total"]) * int(psr["node"]["units"])
        if n_total != int(params.get("psrMoleICapacityUnits", -1)):
            errors.append(f"ProgrammeParameters.psrMoleICapacityUnits = {params.get('psrMoleICapacityUnits')} but psr_layout gives {n_total} (rule W2-N18)")

    gate_rows = evaluate_gates(gates, WINDOWS, derived_exprs, params, ctx)
    elem_rows = evaluate_elements(bindings, gates, gate_rows, declared, parents, WINDOWS, ctx)
    text = render(gate_rows, elem_rows, errors, ctx is not None, thresholds, params)
    if args.markdown:
        args.markdown.write_text(text, encoding="utf-8")
    if args.quiet:
        sec = text.split("## 3. Discrepancy register")[1]
        print("## 3. Discrepancy register" + sec)
    else:
        print(text)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
