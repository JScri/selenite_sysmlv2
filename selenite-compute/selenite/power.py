"""Typed view over the SELENITE_VERIFY_v5_0 port (see verify.py) — the power
sections of that script. The numbers are computed once in verify.run(); this
module only names them. Not an oracle target itself.
"""
from __future__ import annotations

from . import verify

PORTED = True
SOURCE_SCRIPT = "SELENITE_VERIFY_v5_0.m (view)"

PHASE_LABELS = ("P3", "P4", "P5", "P6", "P7+")


def per_phase():
    """Normal and eclipse power budgets per phase (kW) and solar sizing."""
    w = verify.run()
    return {
        "labels": PHASE_LABELS,
        "total_kW": w["ph.p_tot"], "subtotal_kW": w["ph.p_sub"], "contingency_kW": w["ph.p_cont"],
        "psr_kW": w["ph.p_psr"], "isru_kW": w["ph.p_isru"], "base_kW": w["ph.p_base"],
        "panel_m2": w["ph.panel_m2"], "panel_kg": w["ph.panel_kg"],
        "eclipse_critical_kW": w["ecl.tot"], "fsp_units": w["ecl.nfsp"], "fsp_kW": w["ecl.fsp_kW"],
        "eclipse_battery_kWh": w["ecl.bkWh"], "battery_total_t": w["ph.batt_total_t"],
    }
