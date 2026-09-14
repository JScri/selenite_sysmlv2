"""Port of MOLEI_THERMAL_v1_3.m: WEB thermal model; ODE via scipy.integrate.solve_ivp(method='RK45', rtol=1e-6, atol=1e-4).

STATUS: not ported. Source is in selenite-goldens-runner-v2_1/ (see
README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT = "MOLEI_THERMAL_v1_3.m"


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not yet ported")
