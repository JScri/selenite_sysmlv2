"""Typed view over the SELENITE_VERIFY_v5_0 port (see verify.py) — the isru
sections of that script. The numbers are computed once in verify.run(); this
module only names them. Not an oracle target itself.
"""
from __future__ import annotations

from . import verify

PORTED = True
SOURCE_SCRIPT = "SELENITE_VERIFY_v5_0.m (view)"

PHASE_LABELS = ("P3", "P4", "P5", "P6", "P7+")


def per_phase():
    """ISRU water, electrolysis and cryo per phase."""
    w = verify.run()
    return {
        "labels": PHASE_LABELS,
        "water_kg_yr": w["ph.wyr"], "water_kg_hr": w["ph.whr"], "electrolysis_kW": w["ph.p_elec"],
        "pem_stacks": w["ph.nPEM"], "cryo_kW": w["ph.p_cryo"], "isru_total_kW": w["ph.p_isru"],
        "h2_kg_hr": w["ph.h2hr"], "o2_kg_hr": w["ph.o2hr"],
    }
