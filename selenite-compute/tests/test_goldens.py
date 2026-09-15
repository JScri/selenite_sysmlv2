"""One test per comparable oracle row. Skips (with the reason) until the
row's port module exists; then it is the regression suite."""
import importlib

import pytest

from selenite import goldens
from .conftest import results_for

ROWS = [r for r in goldens.load() if r.comparable in ("yes", "platform_dependent_ode")]


@pytest.mark.parametrize("row", ROWS, ids=[r.id for r in ROWS])
def test_golden_row(row):
    ported, results = results_for(row)
    if not ported:
        pytest.skip(results)
    module = importlib.import_module(row.module)
    rule = goldens.compare_rule(row, module)
    if rule[0] == "skip":
        pytest.skip(rule[1])
    assert row.key in results, f"{row.id}: key missing from port output"
    goldens.assert_with_rule(row, results[row.key], rule)
