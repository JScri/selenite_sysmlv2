"""Port of the ISRU sections of SELENITE_VERIFY_v5_0.m: electrolysis, cryo, propellant.

STATUS: not ported. Blocked until the MATLAB source is placed in
selenite-compute/matlab_sources/ (see README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT: str | None = None  # set to the .m filename when ported


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not in repository")
