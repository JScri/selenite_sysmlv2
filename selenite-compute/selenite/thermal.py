"""Port of MOLEI_THERMAL_v1_3.m: WEB thermal model; ODE via scipy.integrate.solve_ivp(method='RK45', rtol=1e-6, atol=1e-4).

STATUS: not ported. Blocked until the MATLAB source is placed in
selenite-compute/matlab_sources/ (see README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT = "MOLEI_THERMAL_v1_3.m"


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not in repository")
