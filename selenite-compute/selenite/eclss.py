"""Port of sabatier.m: Sabatier, WRS, OGA mass balance (Scenario C). Oracle: sabatier.csv (107 rows).

STATUS: not ported. Source is in selenite-goldens-runner-v2_1/ (see
README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT = "sabatier.m"


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not yet ported")
