"""Wave 4A: the model-reading layer of tools/plan_check.py now lives in
selenite.scenarios.modelio (an extension with no golden); these tests prove
the move changed nothing.

plan_check.py is loaded by path exactly as tests/test_plan_check.py does and
its CLI is driven through ``main()`` with stdout captured. The register it
writes is compared byte-for-byte with the committed docs/PLAN_REGISTER.md,
and its stdout with a capture of ``python tools/plan_check.py`` made before
the refactor (tests/fixtures/plan_check_stdout_wave3.txt, trailing newline
included). The sys.path fallback in plan_check.py is exercised in a
subprocess with the installed package hidden, once with nothing importable
and once with a stale ``selenite`` distribution (no scenarios subpackage)
already bound in sys.modules.

No file or gate count is hard-coded: the model folder gains files in this
wave (Scenarios.sysml), so the expected names are read from the folder and
gate completeness is checked against the Decision Framework document.
"""
import importlib.util
import io
import os
import subprocess
import sys
import textwrap
from contextlib import redirect_stdout
from pathlib import Path

import pytest

from selenite.scenarios import modelio

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
SYSML = REPO / "selenite-sysml-wave1-revC" / "selenite-sysml"
TOOL = SYSML / "tools" / "plan_check.py"
REGISTER = SYSML / "docs" / "PLAN_REGISTER.md"
FIXTURE = HERE / "fixtures" / "plan_check_stdout_wave3.txt"
MOVED = ("PHASES", "PHASE_ATTRS", "strip_comments", "read_model", "DEF_RE", "top_level_blocks", "Gate",
         "parse_gates", "parse_phase_windows", "parse_numeric_attributes", "parse_calc_defs",
         "parse_definition_phases", "resolve_declared", "Binding", "parse_configuration", "df_gate_ids")


@pytest.fixture(scope="module")
def pc():
    spec = importlib.util.spec_from_file_location("plan_check", TOOL)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["plan_check"] = mod
    spec.loader.exec_module(mod)
    return mod


def run_main(pc, argv: list[str]) -> tuple[int, str]:
    buf = io.StringIO()
    with redirect_stdout(buf):
        rc = pc.main(argv)
    return rc, buf.getvalue()


def test_markdown_register_is_byte_identical(pc, tmp_path):
    out = tmp_path / "PLAN_REGISTER.md"
    rc, _ = run_main(pc, ["--markdown", str(out), "--quiet"])
    assert rc == 0
    assert out.read_bytes() == REGISTER.read_bytes()


def test_stdout_is_byte_identical_to_the_wave3_capture(pc):
    rc, text = run_main(pc, [])
    assert rc == 0
    assert text.encode("utf-8") == FIXTURE.read_bytes()


def test_read_model_default_is_the_plan_check_model(pc):
    default = modelio.read_model()
    explicit = modelio.read_model(pc.MODEL)
    expected = sorted(p.name for p in pc.MODEL.glob("*.sysml"))
    assert expected, "the model folder holds no .sysml files"
    assert list(default) == expected
    assert list(explicit) == expected
    assert default == explicit
    assert modelio.MODEL_DIR.resolve() == pc.MODEL.resolve()
    assert modelio.DF_DOC.resolve() == pc.DF_DOC.resolve()


def test_read_model_strips_comments(pc):
    model = modelio.read_model()
    raw = (pc.MODEL / "Gates.sysml").read_text(encoding="utf-8")
    assert "/*" in raw or "//" in raw
    assert "/*" not in model["Gates.sysml"]
    assert "//" not in model["Gates.sysml"]


def test_parse_gates_finds_every_gate():
    model = modelio.read_model()
    gates, usages = modelio.parse_gates(model["Gates.sysml"])
    assert gates, "no gates parsed"
    assert set(gates) == modelio.df_gate_ids(modelio.DF_DOC)
    assert {g.def_name for g in gates.values()} <= set(usages.values())


@pytest.mark.parametrize("name", MOVED)
def test_plan_check_re_exports_the_moved_names(pc, name):
    assert getattr(pc, name) is getattr(modelio, name)


def fallback_script(stale: bool) -> str:
    # Hide the installed package (editable finder and any path entry), load
    # plan_check.py by path and check it inserted <repo>/selenite-compute
    # itself and still runs the model-only register. With ``stale`` a stub
    # ``selenite`` package without the scenarios subpackage is imported first,
    # so the fallback must also drop it from sys.modules.
    return textwrap.dedent(f"""
        import contextlib, importlib.util, io, pathlib, sys
        sys.meta_path = [f for f in sys.meta_path if "editable" not in getattr(f, "__module__", "").lower()]
        sys.path = [p for p in sys.path if "selenite-compute" not in p]
        for name in [m for m in sys.modules if m == "selenite" or m.startswith("selenite.")]:
            del sys.modules[name]
        if {stale!r}:
            stub = pathlib.Path("stale").resolve() / "selenite"
            stub.mkdir(parents=True)
            (stub / "__init__.py").write_text("STALE = True")
            sys.path.insert(0, str(stub.parent))
            import selenite
            assert getattr(selenite, "STALE", False), "stub not imported"
        try:
            import selenite.scenarios.modelio
        except ImportError:
            pass
        else:
            print("SKIP: selenite is still importable with the editable finder removed")
            raise SystemExit(0)
        spec = importlib.util.spec_from_file_location("plan_check", {str(TOOL)!r})
        mod = importlib.util.module_from_spec(spec)
        sys.modules["plan_check"] = mod
        spec.loader.exec_module(mod)
        assert sys.path[0] == {str(REPO / "selenite-compute")!r}, sys.path[0]
        assert mod.read_model.__module__ == "selenite.scenarios.modelio", mod.read_model.__module__
        assert not getattr(sys.modules["selenite"], "STALE", False), "stale package still bound"
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = mod.main(["--no-python", "--quiet"])
        assert rc == 0, rc
        assert buf.getvalue().startswith("## 3. Discrepancy register")
        print("FALLBACK_OK")
    """)


@pytest.mark.parametrize("stale", [False, True], ids=["nothing-importable", "stale-distribution"])
def test_sys_path_fallback_when_the_package_is_not_importable(tmp_path, stale):
    env = {k: v for k, v in os.environ.items() if k != "PYTHONPATH"}
    res = subprocess.run([sys.executable, "-c", fallback_script(stale)],
                         capture_output=True, text=True, cwd=str(tmp_path), env=env)
    assert res.returncode == 0, res.stderr
    if res.stdout.startswith("SKIP:"):
        pytest.skip(res.stdout.strip())
    assert "FALLBACK_OK" in res.stdout, res.stdout
