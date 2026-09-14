"""Port of scaling_v1_3.m (SELENITE_SCALE v1.3) — HISTORICAL, pre-ECN-019.

Shows PKT SKIPs, tankers and 48,990 MOLE-I at P8 (VALUE_CONFLICTS.md VC-14).
Ported only so document figures can be traced; never the current scaling
authority (that is ECON v1.3/v1.4). Known source defect: line 584 ``92%``
unescaped in a printf (print only).

STATUS: not ported. Source is in selenite-goldens-runner-v2_1/ (see
README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT = "scaling_v1_3.m"


def run(**params):
    raise NotImplementedError("port pending: MATLAB source not yet ported")
