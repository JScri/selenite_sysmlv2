"""Port of sabatier.m: Sabatier, WRS, OGA mass balance (Scenario C). Oracle: sabatier.csv (107 rows).

STATUS: not ported. Blocked until the MATLAB source is placed in
selenite-compute/matlab_sources/ (see README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT = "sabatier.m"


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not in repository")
