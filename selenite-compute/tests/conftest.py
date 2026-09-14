import importlib
from functools import lru_cache

import pytest

from selenite import goldens


@lru_cache(maxsize=None)
def _module_results(module_name: str):
    """Run a port module once per session; returns (ported, results_or_reason)."""
    mod = importlib.import_module(module_name)
    if not getattr(mod, "PORTED", False):
        return False, f"port pending: {getattr(mod, 'SOURCE_SCRIPT', module_name)} not in repository"
    try:
        return True, mod.run()
    except NotImplementedError as e:  # pragma: no cover - defensive
        return False, str(e)


@pytest.fixture(scope="session")
def oracle_rows():
    rows = goldens.load()
    assert rows, f"no oracle rows found under {goldens.oracle_dir()}"
    return rows


def results_for(row: goldens.GoldenRow):
    return _module_results(row.module)
