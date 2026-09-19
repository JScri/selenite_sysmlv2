"""Wave 3: tools/plan_check.py structural checks run inside the compute suite.

The tool lives with the model (selenite-sysml-wave1-revC/selenite-sysml/tools)
and reads the .sysml files by regular expression; these tests load it by
path so that `pytest selenite-compute` fails when the gate catalogue, the
calc defs, the thresholds and the configuration bindings drift apart.
"""
import importlib.util
import sys
from pathlib import Path

import pytest

TOOL = Path(__file__).resolve().parents[2] / "selenite-sysml-wave1-revC" / "selenite-sysml" / "tools" / "plan_check.py"
ALL_PHASES = {"P0", "P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10", "P11", "P12", "P13", "P14", "P14plus"}


@pytest.fixture(scope="module")
def pc():
    spec = importlib.util.spec_from_file_location("plan_check", TOOL)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["plan_check"] = mod
    spec.loader.exec_module(mod)
    return mod


@pytest.fixture(scope="module")
def parsed(pc):
    model = pc.read_model()
    gates, usages = pc.parse_gates(model["Gates.sysml"])
    return {
        "model": model,
        "gates": gates,
        "usages": usages,
        "windows": pc.parse_phase_windows(model["Phases.sysml"]),
        "thresholds": pc.parse_numeric_attributes(model["Parameters.sysml"], "GateThresholds"),
        "params": pc.parse_numeric_attributes(model["Parameters.sysml"], "ProgrammeParameters"),
        "calc_defs": pc.parse_calc_defs(model["ThroughputCalcs.sysml"]),
        "config": pc.parse_configuration(model["ProgrammeConfiguration.sysml"]),
        "df_ids": pc.df_gate_ids(pc.DF_DOC),
    }


def test_every_decision_framework_gate_is_modelled(parsed):
    assert parsed["df_ids"] == set(parsed["gates"]), sorted(parsed["df_ids"] ^ set(parsed["gates"]))
    assert len(parsed["gates"]) == 81


def test_phase_windows_complete(parsed):
    assert set(parsed["windows"]) == ALL_PHASES


def test_structural_checks_pass(pc, parsed):
    bindings, derived_exprs = parsed["config"]
    errors = pc.structural_checks(parsed["gates"], parsed["usages"], parsed["calc_defs"], bindings,
                                  derived_exprs, parsed["thresholds"], parsed["df_ids"])
    assert errors == []


def test_psr_capacity_is_the_layout_computation(parsed):
    # Rule W2-N18: ProgrammeParameters.psrMoleICapacityUnits comes from psr_layout.py.
    from selenite import psr_layout
    psr = psr_layout.workspace()
    assert parsed["params"]["psrMoleICapacityUnits"] == psr["n_total"] * psr["node"]["units"] == 620
    assert parsed["params"]["psrMoleINodeCount"] == psr["n_total"] == 124


def test_register_runs_and_evaluates_every_derivable_gate(pc, parsed):
    w, ph, psr = pc.load_python()
    ctx = pc.Ctx(w, ph, psr, parsed["thresholds"], parsed["params"])
    pc.WINDOWS = parsed["windows"]
    bindings, derived_exprs = parsed["config"]
    rows = pc.evaluate_gates(parsed["gates"], parsed["windows"], derived_exprs, parsed["params"], ctx)
    derivable = [r for r in rows if r.gate.evaluability == "derivable"]
    assert derivable and all(r.results for r in derivable)
    declared, parents = pc.parse_definition_phases(parsed["model"])
    elems = pc.evaluate_elements(bindings, parsed["gates"], rows, declared, parents, parsed["windows"], ctx)
    assert len(elems) >= 60
    text = pc.render(rows, elems, [], True, parsed["thresholds"], parsed["params"])
    assert "## 3. Discrepancy register" in text and "W3-R1" in text


def test_f5_gates_evaluate_as_the_fsp_msr_trade(pc, parsed):
    # The five SPA MSR gates share one evaluation: the FSP-versus-MSR Earth-mass
    # trade with ThCl4 available (plan_vectors.fsp_msr_trade); every one also
    # prints what the economics assumed (Y105 / Y125 / Y140).
    w, ph, psr = pc.load_python()
    ctx = pc.Ctx(w, ph, psr, parsed["thresholds"], parsed["params"], md3_year=43.0)
    years = set()
    for gid, econ_year in (("DG-10.5", 105), ("DG-13.4", 105), ("DG-14.4", 125), ("DG-14.7", 140)):
        res = pc.EVALUATORS[gid](ctx)[0]
        assert isinstance(res.year, int) and res.year > 43 and f"at Y{econ_year}" in res.detail
        years.add(res.year)
    assert len(years) == 1
