"""Port of SELENITE_ECON_V1_3.m (run(): infrastructure derivation by year, NPV/BCR) and SELENITE_ECON_V1_4.m (report(): externalities, on the v1.3 state). One module because v1.4 reads v1.3's workspace.

STATUS: not ported. Source is in selenite-goldens-runner-v2_1/ (see
README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT = "SELENITE_ECON_V1_3.m + SELENITE_ECON_V1_4.m"


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not yet ported")
