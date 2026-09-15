"""Typed view over the SELENITE_VERIFY_v5_0 port (see verify.py) — the fleet
sections of that script. The numbers are computed once in verify.run(); this
module only names them. Not an oracle target itself.
"""
from __future__ import annotations

from . import verify

PORTED = True
SOURCE_SCRIPT = "SELENITE_VERIFY_v5_0.m (view)"

PHASE_LABELS = ("P3", "P4", "P5", "P6", "P7+")


def per_phase():
    """Demand-driven fleet per phase: MOLE-I, substations, PROBE, SKIP, DART, surface robots."""
    w = verify.run()
    return {
        "labels": PHASE_LABELS,
        "moleI": w["ph.mi"], "substations": w["ph.nd"], "probe": w["ph.nP"], "skip": w["ph.nS"],
        "dart": w["ph.nD"], "crew": w["ph.crew"], "moleS": w["ph.nMS"], "armC": w["ph.nARMC"],
        "armD": w["ph.nARMD"], "sentinel": w["ph.nSEN"],
        "propellant_demand_kg": w["ph.dT"], "propellant_supply_kg": w["ph.isru"], "margin_kg": w["ph.margin"],
    }
