"""Port of the fleet sections of SELENITE_VERIFY_v5_0.m: MOLE-I/S, PROBE, ARM, SENTINEL per-phase counts (ph.* vectors).

STATUS: not ported. Source is in selenite-goldens-runner-v2_1/ (see
README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT: str | None = None  # set to the .m filename when ported


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not yet ported")
