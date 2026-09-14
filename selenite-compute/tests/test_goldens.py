"""One test per comparable oracle row. Skips (with the reason) until the
row's port module exists; then it is the regression suite."""
import pytest

from selenite import goldens
from .conftest import results_for

ROWS = [r for r in goldens.load() if r.comparable in ("yes", "platform_dependent_ode")]


@pytest.mark.parametrize("row", ROWS, ids=[r.id for r in ROWS])
def test_golden_row(row):
    if row.is_ode and not goldens.ode_row_is_compared(row):
        pytest.skip("ODE row not in the compared set (step-sequence dependent)")
    ported, results = results_for(row)
    if not ported:
        pytest.skip(results)
    assert row.key in results, f"{row.id}: key missing from port output"
    goldens.assert_matches(row, results[row.key])
