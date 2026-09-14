"""Regenerates the console output the ``.m`` scripts printed, from the port
modules' workspaces, so the documents can be regenerated from the same
numbers.

Oracle: ``selenite-goldens-runner-v2_1/goldens_20260914_224703/console_*.txt``
(the ``evalc`` capture of each script under MATLAB R2025a);
``tests/test_console.py`` compares line by line. Only the timestamp line in
ECON v1.3 and the ode45-derived temperatures in THERMAL are compared loosely.

``_mf`` emulates MATLAB ``sprintf``: arrays expand into the argument list,
the format recycles while arguments remain, output stops at a conversion
without an argument, ``%d`` of a non-integer falls back to ``%e``, and an
unknown conversion (the ``92% hauler`` defect in scaling v1.3) truncates the
output exactly as MATLAB did.
"""
from __future__ import annotations

import math
import re
from datetime import datetime

import numpy as np

_CONV = re.compile(r"%(?P<flags>[-+ 0#]*)(?P<width>\d+)?(?:\.(?P<prec>\d+))?(?P<conv>[a-zA-Z%])")


def _expand(args):
    out = []
    for a in args:
        if isinstance(a, np.ndarray):
            out.extend(a.flatten(order="F").tolist())
        elif isinstance(a, (list, tuple)):
            out.extend(a)
        else:
            out.append(a)
    return out


def _one(spec, flags, width, prec, conv, value):
    if conv == "s":
        if not isinstance(value, str):
            value = _one("", "", None, None, "g", value)
        return ("%" + flags + (width or "") + ("." + prec if prec else "") + "s") % value
    if isinstance(value, (bool, np.bool_)):
        value = int(value)
    v = float(value)
    if math.isnan(v) or math.isinf(v):
        txt = "NaN" if math.isnan(v) else ("-Inf" if v < 0 else "Inf")
        return ("%" + flags.replace("0", "") + (width or "") + "s") % txt
    if conv in "diu":
        if math.isfinite(v) and v == math.floor(v):
            return ("%" + flags + (width or "") + "d") % int(v)
        conv, prec = "e", None  # MATLAB overrides %d with %e for non-integers
    return ("%" + flags + (width or "") + ("." + prec if prec else "") + conv) % float(value)


def _mf(fmt: str, *args) -> str:
    """MATLAB sprintf/fprintf semantics (see module docstring)."""
    vals = _expand(args)
    out = []
    pos = 0
    first_pass = True
    while True:
        i = 0
        consumed = 0
        while True:
            m = _CONV.search(fmt, i)
            if m is None:
                out.append(fmt[i:])
                break
            out.append(fmt[i:m.start()])
            i = m.end()
            if m.group("conv") == "%":
                out.append("%")
                continue
            if m.group("conv") not in "diufeEgGsc":
                return "".join(out)  # MATLAB stops at an unknown conversion
            if pos >= len(vals):
                if not first_pass or vals:
                    return "".join(out)
                out.append("")  # no arguments at all: conversion prints nothing
                continue
            out.append(_one(m.group(0), m.group("flags"), m.group("width"), m.group("prec"),
                            m.group("conv"), vals[pos]))
            pos += 1
            consumed += 1
        first_pass = False
        if pos >= len(vals) or consumed == 0:
            return "".join(out)


def _tern(c, a, b):
    return a if c else b


def _mround(x):
    """MATLAB round(): half away from zero."""
    return math.floor(x + 0.5) if x >= 0 else -math.floor(-x + 0.5)


class _Console:
    def __init__(self):
        self.parts = []

    def p(self, fmt, *args):
        self.parts.append(_mf(fmt, *args))

    def text(self):
        return "".join(self.parts)


# ---------------------------------------------------------------------------
# sabatier.m
# ---------------------------------------------------------------------------
def sabatier(ws=None) -> str:
    from . import eclss
    w = ws or eclss.workspace()
    c = _Console(); P = c.p
    P('═══════════════════════════════════════════════════════\n')
    P('  SELENITE AUDIT RESOLUTION SCRIPT\n')
    P('  Resolving: Q2, Q4, Q8/Q9/Q10/Q12, Q15, Q19\n')
    P('═══════════════════════════════════════════════════════\n\n')
    P('━━━ Q8/Q9/Q10/Q12: COMPLETE ECLSS MASS BALANCE ━━━\n\n')
    P('Crew metabolic rates (4 crew):\n')
    P('  CO₂ exhaled:    %.2f kg/day\n', w["CO2_crew"])
    P('  O₂ consumed:    %.2f kg/day\n', w["O2_crew"])
    P('  H₂O consumed:   %.2f kg/day\n\n', w["H2O_crew"])
    P('Greenhouse (48 m², from P5):\n')
    P('  CO₂ demand:     %.1f–%.1f kg/day (nom %.2f)\n', w["GH_CO2_low"], w["GH_CO2_high"], w["GH_CO2_nom"])
    P('  O₂ produced:    ~%.2f kg/day\n\n', w["GH_O2_nom"])

    P('──── SCENARIO A: OGA at crew O₂ demand (RECOMMENDED) ────\n')
    P('  OGA O₂ output:  %.2f kg/day\n', w["O2_OGA_A"])
    P('  OGA H₂ output:  %.3f kg/day\n', w["H2_OGA_A"])
    P('  OGA H₂O input:  %.2f kg/day\n', w["H2O_consumed_OGA_A"])
    P('  Sabatier CO₂ consumed: %.2f kg/day\n', w["CO2_sab_A"])
    P('  Sabatier CH₄ produced: %.2f kg/day\n', w["CH4_sab_A"])
    P('  Sabatier H₂O recovered: %.2f kg/day\n', w["H2O_sab_A"])
    P('  CO₂ remaining for greenhouse: %.2f kg/day\n', w["CO2_remaining_A"])
    P('  Greenhouse demand: %.2f kg/day\n', w["GH_CO2_nom"])
    if w["CO2_remaining_A"] >= w["GH_CO2_low"]:
        P('  ✓ SUFFICIENT for greenhouse (%.0f–%.0f%% of demand met)\n',
          w["CO2_remaining_A"] / w["GH_CO2_high"] * 100, w["CO2_remaining_A"] / w["GH_CO2_low"] * 100)
    else:
        P('  ✗ INSUFFICIENT: deficit %.2f kg/day\n', w["GH_CO2_nom"] - w["CO2_remaining_A"])
    P('  O₂ surplus: %.2f kg/day (OGA excess + greenhouse)\n', w["O2_surplus_A"])
    P('  WRS recovered: %.2f kg/day\n', w["WRS_recovered"])
    P('  Water deficit (ISRU makeup): %.2f kg/day\n', w["H2O_balance_A"])
    P('  OGA power: %.0f W continuous\n\n', w["P_OGA_A"] * 1000)

    P('──── SCENARIO B: OGA at 0.73 kg H₂/day (original spec) ────\n')
    P('  OGA O₂ output:  %.2f kg/day\n', w["O2_OGA_B"])
    P('  OGA H₂ output:  %.3f kg/day\n', w["H2_OGA_B"])
    P('  OGA H₂O input:  %.2f kg/day\n', w["H2O_consumed_OGA_B"])
    P('  Sabatier CO₂ consumed: %.2f kg/day\n', w["CO2_sab_B"])
    P('  Sabatier CH₄ produced: %.2f kg/day\n', w["CH4_sab_B"])
    P('  Sabatier H₂O recovered: %.2f kg/day\n', w["H2O_sab_B"])
    P('  CO₂ remaining for greenhouse: %.2f kg/day\n', w["CO2_remaining_B"])
    P('  O₂ surplus (must store/vent): %.2f kg/day (%.0f kg/yr)\n', w["O2_surplus_B"], w["O2_surplus_B"] * 365)
    P('  Water deficit (ISRU makeup): %.2f kg/day\n\n', w["H2O_balance_B"])

    P('──── SCENARIO C: BALANCED (Sabatier + GH = crew CO₂) ────\n')
    P('  REQUIRED H₂ from OGA: %.3f kg/day\n', w["H2_OGA_C"])
    P('  OGA O₂ output:  %.2f kg/day\n', w["O2_OGA_C"])
    P('  OGA H₂O input:  %.2f kg/day\n', w["H2O_consumed_OGA_C"])
    P('  Sabatier CO₂:   %.2f kg/day (%.0f%% of crew)\n', w["CO2_sab_C"], w["CO2_sab_C"] / w["CO2_crew"] * 100)
    P('  Greenhouse CO₂: %.2f kg/day (%.0f%% of crew)\n', w["CO2_remaining_C"], w["CO2_remaining_C"] / w["CO2_crew"] * 100)
    P('  CH₄ vented:     %.2f kg/day (%.0f kg/yr)\n', w["CH4_sab_C"], w["CH4_sab_C"] * 365)
    P('  H₂O recovered:  %.2f kg/day\n', w["H2O_sab_C"])
    P('  O₂ surplus:     %.2f kg/day (%.0f kg/yr)\n', w["O2_surplus_C"], w["O2_surplus_C"] * 365)
    P('  Water deficit:   %.2f kg/day (ISRU makeup)\n', w["H2O_balance_C"])
    P('  OGA power:      %.0f W continuous\n\n', w["P_OGA_C"] * 1000)

    P('━━━ SCENARIO COMPARISON ━━━\n')
    P('                    Scen A (crew O₂)  Scen B (0.73 H₂)  Scen C (balanced)\n')
    P('  H₂ from OGA:     %.3f kg/day       %.3f kg/day       %.3f kg/day\n', w["H2_OGA_A"], w["H2_OGA_B"], w["H2_OGA_C"])
    P('  CO₂ to Sabatier: %.2f kg/day       %.2f kg/day       %.2f kg/day\n', w["CO2_sab_A"], w["CO2_sab_B"], w["CO2_sab_C"])
    P('  CO₂ to GH:       %.2f kg/day       %.2f kg/day       %.2f kg/day\n', w["CO2_remaining_A"], w["CO2_remaining_B"], w["CO2_remaining_C"])
    P('  GH CO₂ met?:     %s               %s               %s\n',
      _tern(w["CO2_remaining_A"] >= w["GH_CO2_low"], 'YES', 'NO'),
      _tern(w["CO2_remaining_B"] >= w["GH_CO2_low"], 'YES', 'NO'),
      _tern(w["CO2_remaining_C"] >= w["GH_CO2_low"], 'YES', 'NO'))
    P('  O₂ surplus:      %.2f kg/day       %.2f kg/day       %.2f kg/day\n', w["O2_surplus_A"], w["O2_surplus_B"], w["O2_surplus_C"])
    P('  ISRU H₂O:        %.2f kg/day       %.2f kg/day       %.2f kg/day\n', w["H2O_balance_A"], w["H2O_balance_B"], w["H2O_balance_C"])
    P('  OGA power:        %.0f W              %.0f W              %.0f W\n', w["P_OGA_A"] * 1000, w["P_OGA_B"] * 1000, w["P_OGA_C"] * 1000)
    P('  CH₄ vented:      %.2f kg/day       %.2f kg/day       %.2f kg/day\n\n', w["CH4_sab_A"], w["CH4_sab_B"], w["CH4_sab_C"])
    P('  ★ RECOMMENDATION: Scenario C (balanced)\n')
    P('    - All crew CO₂ is consumed (Sabatier + greenhouse)\n')
    P('    - Greenhouse gets exactly the CO₂ it needs\n')
    P('    - O₂ surplus is modest and manageable\n')
    P('    - OGA power is reasonable (~940 W)\n')
    P('    - ISRU water demand is lowest\n\n')

    P('━━━ Q4: MEZZANINE GEOMETRY CORRECTION ━━━\n\n')
    P('  Cylinder ID: %d mm (R = %d mm)\n', w["R_inner"] * 2, w["R_inner"])
    P('  Floor:     y = %+d mm from centre → chord = %.0f mm ✓ (spec: 2,470)\n', w["y_floor"], w["chord_floor"])
    P('  Mezzanine: y = %+d mm from centre → chord = %.0f mm ✗ (spec: 2,920)\n', w["y_mezz"], w["chord_mezz"])
    P('  Error: spec is %.0f mm too narrow (%.0f%%)\n\n', w["chord_mezz"] - 2920, (w["chord_mezz"] - 2920) / 2920 * 100)
    P('  2,920 mm chord occurs at y = +%.0f mm (= %.0f mm above floor)\n', w["y_2920"], w["h_2920"])
    P('  That is %.0f mm ABOVE the mezzanine — near the upper wall curvature\n\n', w["h_2920"] - 2200)
    P('  Headroom above mezzanine: %.0f mm (to ceiling centreline)\n', w["headroom_above_mezz"])
    P('  Headroom below mezzanine: %.0f mm (to floor)\n', w["headroom_below_mezz"])
    if w["y_berth_head"] < w["R_inner"]:
        P('  Width at 1,000 mm above mezzanine: %.0f mm\n', w["chord_berth"])
    else:
        P('  1,000 mm above mezzanine exceeds cylinder radius!\n')

    V_sphere = w["V_sphere"]; V_needed = w["V_needed"]
    P('\n━━━ Q15: LH₂ STORAGE VOLUME CORRECTION ━━━\n\n')
    P('  Single 5.0 m sphere: %.2f m³\n', V_sphere)
    P('  Two 5.0 m spheres:   %.2f m³ (spec says 175 m³)\n', 2 * V_sphere)
    P('  Shortfall:           %.2f m³ (%.1f%%)\n\n', 175 - 2 * V_sphere, (175 - 2 * V_sphere) / 175 * 100)
    P('  Fix option 1: Two spheres at %.2f m diameter = 175 m³\n', w["d_needed"])
    P('  Fix option 2: Three 5.0 m spheres = %.1f m³ (%.0f m³ excess)\n', 3 * V_sphere, 3 * V_sphere - 175)
    P('\n  Actual LH₂ storage requirement:\n')
    P('    30-day buffer LH₂:    %.0f kg → %.1f m³\n', w["LH2_30day"], w["LH2_30day"] / w["rho_LH2"])
    P('    DART accumulation:    %.0f kg → %.1f m³\n', w["LH2_DART"], w["LH2_DART"] / w["rho_LH2"])
    P('    TOTAL:                %.0f kg → %.1f m³\n', w["LH2_total"], V_needed)
    P('    Two 5.0 m spheres:   %.1f m³ → %s\n', 2 * V_sphere, _tern(2 * V_sphere >= V_needed, 'SUFFICIENT', 'INSUFFICIENT'))
    P('    Recommended: 2 × 5.0 m spheres (130.9 m³) is adequate.\n')
    P('    The 175 m³ figure in the spec was an error — actual need is ~%.0f m³.\n\n', V_needed)

    P('━━━ Q19: ELECTROLYSIS POWER CORRECTION ━━━\n\n')
    H2_total = w["H2_total"]; O2_total = w["O2_total"]; H2_per_day = w["H2_per_day"]
    P('  170 MOLE-I × 7,818 kg water/yr = %.0f kg water/yr\n', w["total_water"])
    P('  Electrolysis products:\n')
    P('    H₂: %.0f kg/yr (%.1f kg/day)\n', H2_total, H2_total / 365)
    P('    O₂: %.0f kg/yr (%.1f kg/day)\n', O2_total, O2_total / 365)
    P('  Propellant at 6:1 O:F: %.0f kg/yr (H₂-limited)\n', w["prop_from_H2"])
    P('  Propellant at 6:1 O:F: %.0f kg/yr (O₂-limited)\n', w["prop_from_O2"])
    P('  Excess O₂: %.0f kg/yr (available for life support/industrial)\n\n', O2_total - H2_total * 6)
    P('  Electrolysis power at different efficiencies:\n')
    P('  %-12s %-12s %-12s\n', 'kWh/kg H₂', 'kW cont.', 'Stacks @60.5kW')
    for kwh in w["kWh_per_kg_H2"]:
        P_kW = H2_per_day * kwh / 24
        P('  %-12.1f %-12.0f %-12d\n', kwh, P_kW, math.ceil(P_kW / 60.5))
    P('\n  Spec says: 9 stacks at 545 kW (60.5 kW/stack)\n')
    P('  At 52.5 kWh/kg H₂: need %.0f kW → %.0f stacks\n', H2_per_day * 52.5 / 24, math.ceil(H2_per_day * 52.5 / 24 / 60.5))
    P('  RECOMMENDATION: Increase to 11 stacks at 665 kW total\n')
    P('  Or: increase per-stack capacity to ~74 kW (within PEM scaling range)\n\n')
    P('  REVISED ISRU POWER BUDGET (P7+):\n')
    P('    Pipeline heating:        %.0f kW\n', w["P_pipeline"])
    P('    Electrolysis (revised):  %.0f kW\n', w["P_electrolysis_new"])
    P('    Sublimation (fleet):     %.0f kW (est.)\n', w["P_sublimation"])
    P('    LH₂ liquefaction:        %.0f kW\n', w["P_LH2_liq"])
    P('    LOX liquefaction:        %.0f kW\n', w["P_LOX_liq"])
    P('    Purification + other:    %.0f kW\n', w["P_purification"] + w["P_other"])
    P('    ─────────────────────────────\n')
    P('    TOTAL:                   %.0f kW\n', w["P_ISRU_total"])
    P('    (Previous spec: 1,090 kW. Δ = +%.0f kW)\n\n', w["P_ISRU_total"] - 1090)

    P('━━━ Q2: STARSHIP PAYLOAD CONFIGURATION ━━━\n\n')
    D_fairing = w["D_fairing"]; L_fairing = w["L_fairing"]; D_module = w["D_module"]; L_module = w["L_module"]
    P('  Fairing dynamic envelope: %.1f m diameter × %.1f m height\n', D_fairing, L_fairing)
    P('  Module OD: %.1f m × %.1f m overall\n\n', D_module, L_module)
    P('  2-abreast: enclosing diameter = %.1f m → %s (envelope = %.1f m)\n',
      w["D_enclosing"], _tern(w["D_enclosing"] <= D_fairing, 'FITS', 'DOES NOT FIT'), D_fairing)
    P('  Stacked (end-to-end): height = %.1f m → %s (envelope = %.1f m)\n',
      w["H_stacked"], _tern(w["H_stacked"] <= L_fairing, 'FITS', 'DOES NOT FIT'), L_fairing)
    P('  Single module: %.1f m OD in %.1f m envelope → %.2f m clearance each side\n\n',
      D_module, D_fairing, (D_fairing - D_module) / 2)
    M_module_max = w["M_module_max"]; M_starship_lunar = w["M_starship_lunar"]
    P('  Heaviest module (Ops Hub revised): %.0f kg\n', M_module_max)
    P('  Starship lunar payload: ≥%.0f kg\n', M_starship_lunar)
    P('  Mass margin per flight: %.0f kg (%.0f%% of capacity)\n',
      M_starship_lunar - M_module_max, (M_starship_lunar - M_module_max) / M_starship_lunar * 100)
    P('  → Co-manifest ECLSS equipment, spares, consumables on same flight\n\n')
    P('  RECOMMENDATION: 1 module per Starship flight.\n')
    P('  Co-manifest supplementary cargo to exploit 27+ t mass surplus.\n')
    P('  Stacking is feasible for smaller modules (EVA vestibule + cargo).\n\n')

    P('═══════════════════════════════════════════════════════\n')
    P('  RESOLUTION SUMMARY\n')
    P('═══════════════════════════════════════════════════════\n\n')
    P('  Q2  Starship: 1 module/flight. Co-manifest cargo. RESOLVED.\n')
    P('  Q4  Mezzanine: chord = %.0f mm (not 2,920). Update spec. RESOLVED.\n', w["chord_mezz"])
    P('  Q8  Sabatier: Use Scenario C (balanced). H₂ = %.3f kg/day.\n', w["H2_OGA_C"])
    P('       CO₂ to Sabatier: %.2f kg/day (%.0f%%). To GH: %.2f kg/day (%.0f%%).\n',
      w["CO2_sab_C"], w["CO2_sab_C"] / w["CO2_crew"] * 100, w["CO2_remaining_C"], w["CO2_remaining_C"] / w["CO2_crew"] * 100)
    P('  Q9  CO₂ budget: CLOSES under Scenario C. RESOLVED.\n')
    P('  Q10 O₂ surplus: %.2f kg/day (%.0f kg/yr). Small, manageable.\n', w["O2_surplus_C"], w["O2_surplus_C"] * 365)
    P('       → Store in EVA suit O₂ tanks + emergency cache.\n')
    P('  Q12 Water: %.2f kg/day ISRU makeup. CLOSES. RESOLVED.\n', w["H2O_balance_C"])
    P('  Q15 LH₂ vol: 2 × 5.0 m spheres = %.1f m³. Actual need: ~%.0f m³.\n', 2 * V_sphere, V_needed)
    P('       → Correct spec from 175 to 131 m³. RESOLVED.\n')
    P('  Q19 Electrolysis: Increase to 11 stacks at %.0f kW. RESOLVED.\n', w["P_electrolysis_new"])
    P('       Total ISRU power revised: %.0f kW (was 1,090 kW).\n\n', w["P_ISRU_total"])
    return c.text()


# ---------------------------------------------------------------------------
# SELENITE_VERIFY_v5_0.m
# ---------------------------------------------------------------------------
def verify_v5_0(ws=None) -> str:
    from . import verify
    w = ws or verify.workspace()
    c = _Console(); P = c.p
    crater = w["crater"]; solar = w["solar"]; fsp = w["fsp"]; mi = w["mi"]; node = w["node"]
    cap = w["cap"]; skip = w["skip"]; ph = w["ph"]; pipe = w["pipe"]; hab = w["hab"]; ecl = w["ecl"]
    n = int(ph["n"])
    P('════════════════════════════════════════════════════════════════\n')
    P('  SELENITE v5.0 — Comprehensive Programme Verification\n')
    P('  Fleet + Power + ECLSS Scenario C + ISRU + Fishbone Pipeline\n')
    P('  72-hr conservative eclipse | 5× FSP | 19 PEM stacks\n')
    P('  Ref: All subsystem specs (March 2026)\n')
    P('════════════════════════════════════════════════════════════════\n\n')
    P('  Crater: %.1f km slope, %.1f km floor dia, %.1f km² floor\n',
      crater["traverse_km"], crater["floor_dia_km"], crater["floor_area"])
    P('  Solar: %.3f kW/m² (%.0f W/m² × %.0f%% eff × %.0f%% illum × %.0f%% dust)\n',
      solar["yield_kWm2"], solar["irr"] * 1000, solar["eff"] * 100, solar["illum"] * 100, solar["dust"] * 100)
    P('  FSP: %d kWe per unit, %d kg\n\n', fsp["pwr_kW"], fsp["mass_kg"])

    P('== MOLE-I (6-WHEEL) ==\n')
    P('  %.1f kg dry | %d W op | %d W ka | %.0f Wh batt\n', mi["mass_dry"], mi["pwr_op"], mi["pwr_ka"], mi["batt_Wh"])
    P('  Tether draw: %dW (load %d + DC-DC %.0f + batt %d)\n',
      _mround(mi["pwr_tether"]), mi["pwr_op"], mi["dcdc"]["loss_total"], mi["batt_charge"])
    P('  Prospecting: first unit at each branch measures wt%% ice\n')
    P('    (drill mass / water output, 3-5 cycles at ~50 m spacing)\n\n')

    P('== SUBSTATION NODE ==\n')
    P('  WEB %.1f + drums %d + pump %d + riser %d + funnels %d\n',
      node["web"], node["drums"], node["pump"], node["riser"], node["funnels"])
    P('  + comms %d + ctrl %d + solenoids %d + enc %.1f = %.1f W\n',
      node["comms"], node["controller"], node["solenoids"], node["angle_enc"], node["overhead_v5"])
    P('  %d LWRHU (%.0f g) | %d kg dry\n\n', node["lwrhu"], node["lwrhu_mass"] * 1000, node["mass"])

    P('== CAP ==\n')
    P('  %.1f kW peak | %.1f kW standby | %d kg loaded\n\n', cap["peak_kW"], cap["stby_kW"], cap["mass_loaded"])

    P('== SKIP ORBITAL MECHANICS ==\n')
    P('  Range: %d km | v0=%.0f m/s | ΔV=%.0f m/s | Fuel/hop=%.0f kg\n', skip["rng"], skip["v0"], skip["dv"], skip["fuel_hop"])
    P('  FLEET v8 says: 303 kg/hop. Δ: %+.0f kg (%s)\n\n', skip["fuel_hop"] - 303,
      _tern(abs(skip["fuel_hop"] - 303) < 30, 'OK', 'MISMATCH'))

    P('== FLEET SIZING ==\n')
    P('  %-14s %4s %4s %4s %4s | %5s %5s | %8s %8s | %+8s\n',
      'Phase', 'Prb', 'SKP', 'DRT', 'Crew', 'MI', 'Nod', 'Demand', 'Supply', 'Margin')
    P('  %s\n', '-' * 85)
    for i in range(n):
        P('  %-14s %4d %4d %4d %4d | %5d %5d | %7.1ft %7.1ft | %+7.1ft  [%s]\n',
          ph["nm"][i], ph["nP"][i], ph["nS"][i], ph["nD"][i], ph["crew"][i], ph["mi"][i], ph["nd"][i],
          ph["dT"][i] / 1e3, ph["isru"][i] / 1e3, ph["margin"][i] / 1e3, _tern(ph["margin"][i] >= 0, 'PASS', 'FAIL'))
    stk = 0
    P('\n  STOCKPILE:\n')
    for i in range(n):
        stk = stk + ph["margin"][i] * ph["dur"][i]
        P('    %s: %+.1f t/yr × %d yr -> %.0f t\n', ph["lab"][i], ph["margin"][i] / 1e3, ph["dur"][i], stk / 1e3)

    P('\n== PIPELINE HEATING (v5.0) ==\n')
    P('  %-5s  Trunk   Spine   Branch   Heat(kW)  Pump(kW)  Total(kW)\n', 'Phase')
    for i in range(n):
        P('  %-5s  %5.1f   %5.1f   %5.1f    %6.1f     %5.1f     %6.1f\n',
          ph["lab"][i], w["trunk_km"][i], w["spine_km"][i], w["branch_km"][i], pipe["kW"][i], pipe["pump"][i], pipe["total"][i])

    P('\n== ECLSS SCENARIO C VERIFICATION ==\n')
    CO2_crew = w["CO2_crew"]; CO2_sab = w["CO2_sab"]; CO2_GH = w["CO2_GH"]
    P('  OGA: %.3f kg H₂/day → %.2f kg O₂ + %.2f kg H₂O consumed\n', w["H2_OGA"], w["O2_OGA"], w["H2O_OGA"])
    P('  Sabatier: %.2f kg CO₂ → %.2f kg CH₄ + %.2f kg H₂O\n', CO2_sab, w["CH4_sab"], w["H2O_sab"])
    P('  CO₂: crew %.1f − Sab %.2f − GH %.2f = %.2f (%s)\n', CO2_crew, CO2_sab, CO2_GH, CO2_crew - CO2_sab - CO2_GH,
      _tern(abs(CO2_crew - CO2_sab - CO2_GH) < 0.1, '✓ CLOSES', '✗'))
    P('  O₂: OGA %.2f − crew %.2f + GH %.2f = %+.2f surplus\n', w["O2_OGA"], w["O2_crew"], w["GH_O2"],
      w["O2_OGA"] - w["O2_crew"] + w["GH_O2"])
    P('  H₂O: crew %.1f − WRS %.2f − Sab %.2f + OGA %.2f = %.2f ISRU makeup\n',
      w["H2O_crew"], w["WRS_out"], w["H2O_sab"], w["H2O_OGA"], w["H2O_deficit"])
    P('  OGA power: %.0f W (%.3f kg H₂ × 52.5 kWh/kg ÷ 24)\n\n', w["H2_OGA"] * 52.5 / 24 * 1000, w["H2_OGA"])

    P('== HABITAT POWER BREAKDOWN ==\n')
    P('  CDRA %d + OGA %d + Sab %d + TCCS %d + CCAA %d\n', hab["CDRA"], hab["OGA"], hab["Sab"], hab["TCCS"], hab["CCAA"])
    P('  + WRS %d + thermal %d + lighting %d + comms %d + other %d + conv %d\n',
      hab["WRS"], hab["thermal"], hab["lighting"], hab["comms"], hab["other"], hab["conv_loss"])
    P('  = %.1f kW no-GH (spec: 50 kW nom → %s)\n', hab["no_GH"] / 1000, _tern(hab["no_GH"] / 1000 <= 50, '✓', '✗'))
    P('  + LED %d = %.1f kW with-GH (spec: 63 kW margin → %s)\n\n', hab["LED"], hab["with_GH"] / 1000,
      _tern(hab["with_GH"] / 1000 <= 63, '✓', '✗'))

    P('== NORMAL POWER BUDGET (v5.0) ==\n')
    P('\n  ISRU CRYO CROSS-CHECK (P7+):\n')
    P('    LH₂ liq: %.1f kg/hr × 15 kWh/kg ÷ 24 = %.0f kW (ISRU-001: 200 kW)\n', ph["h2hr"][-1] * 24, ph["p_lh2"][-1])
    P('    LOX liq: %.1f kg/hr × 1.0 kWh/kg ÷ 24 = %.0f kW (ISRU-001: 54 kW)\n', ph["o2hr"][-1] * 24, ph["p_lox"][-1])
    P('    Total cryo calc: %.0f kW vs ISRU-001 256 kW (Δ=%+.0f — passive cooling assumption)\n\n',
      ph["p_cryo"][-1], ph["p_cryo"][-1] - 256)
    P('  %-5s | %4s %4s | %6s %6s %6s | %6s | %6s %5s | %6s | %6s\n',
      'Phase', 'MI', 'Nod', 'PSR', 'Pipe', 'ISRU', 'Base', 'Sub', 'Cont', 'TOTAL', 'Panels')
    P('  %s\n', '-' * 85)
    for i in range(n):
        P('  %-5s | %4d %4d | %5.0f  %5.0f  %5.0f  | %5.0f  | %5.0f  %5.0f | %5.0f kW | %5.0f m²\n',
          ph["lab"][i], ph["mi"][i], ph["nd"][i], ph["p_fleet"][i] + ph["p_nodes"][i], ph["p_pipe"][i], ph["p_isru"][i],
          ph["p_base"][i], ph["p_sub"][i], ph["p_cont"][i], ph["p_tot"][i], ph["panel_m2"][i])
    P('\n  PEM STACKS: '); P('%d ', ph["nPEM"]); P('(spec: 19 at P7+)\n')

    P('\n== ECLIPSE POWER (72-hr conservative) ==\n')
    P('  %-5s | %5s %5s %5s %5s %5s %5s | %6s | %5s | %12s\n',
      'Phase', 'MI ka', 'Nodes', 'Pipe', 'Hab', 'FmZBO', 'Other', 'CRIT', 'FSP', 'Battery')
    P('  %s\n', '-' * 90)
    for i in range(n):
        short = max(0, ecl["tot"][i] - ecl["fsp_kW"][i])
        bkWh = short * w["eclipse_hr"] * w["batt_margin"]
        bt = bkWh * 1000 / w["batt_Whkg"] / 1000
        bs = _mf('%.0f kWh (%.1ft)', bkWh, bt) if short > 0 else 'FSP covers'
        P('  %-5s | %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f | %5.0f kW | %dx%dkW | %s\n',
          ph["lab"][i], ecl["mi"][i], ecl["nd"][i], ecl["pipe"][i], ecl["hab"][i], ecl["farmzbo"][i],
          ecl["sent"][i] + ecl["misc"][i], ecl["tot"][i], ecl["nfsp"][i], fsp["pwr_kW"], bs)
    P('\n  BATTERY TIERING (eclipse + ISRU ride-through):\n')
    P('  %-5s  Eclipse(kWh) ISRU-RT(kWh)  Total(kWh)  Mass(t)\n', 'Phase')
    for i in range(n):
        P('  %-5s  %8.0f     %8.0f      %8.0f     %5.1f\n', ph["lab"][i], ecl["bkWh"][i], ph["t2_kWh"][i],
          ph["batt_total_kWh"][i], ph["batt_total_t"][i])

    P('\n== ISRU PLANT ==\n')
    M_H2 = w["M_H2"]; M_H2O = w["M_H2O"]; M_O2 = w["M_O2"]
    for i in range(n):
        lh2 = ph["wyr"][i] * (2 * M_H2) / (2 * M_H2O) * 0.722
        lox = ph["wyr"][i] * M_O2 / (2 * M_H2O) * 0.722
        P('  %s: %.1f kg/hr | %d PEM | elec %.0f + cryo %.0f + vex %.0f + oth %.0f = %.0f kW | LH2 %.1ft LOX %.1ft\n',
          ph["lab"][i], ph["whr"][i], ph["nPEM"][i], ph["p_elec"][i], ph["p_cryo"][i], ph["p_vex"][i],
          ph["p_isru_oth"][i], ph["p_isru"][i], lh2 / 1e3, lox / 1e3)

    P('\n== TRUNK CABLE ==\n')
    V = w["V"]; cu_rho = w["cu_rho"]; cu_den = w["cu_den"]; tm = w["tm"]
    for i in range(n):
        I = ph["p_psr"][i] * 1000 / V
        if I > 0:
            R = 0.05 * V / I; A = cu_rho * tm * 2 / R * 1e6; m = A * 1e-6 * tm * 2 * cu_den
        else:
            A = 10; m = 1500
        P('  %s: %.0f kW -> %3.0f A -> %4.0f mm² -> %5.1f t Cu\n', ph["lab"][i], ph["p_psr"][i], I, A, m / 1e3)

    P('\n== MATERIAL OUTPUT ==\n')
    for i in range(1, n + 1):
        kc = ph["nS"][i - 1] * skip["kreep_yr"] / 1e3 * 0.04
        pg = max(0, ph["nP"][i - 1] * 1.5 * (i > 1))
        P('  %s: %.1ft PGM ore + %.1ft KREEP concentrate = %.1ft/yr\n', ph["lab"][i - 1], pg, kc, pg + kc)

    P('\n== POWER INFRASTRUCTURE MASS ==\n')
    P('  %-5s  Array(t)  FSP(t)  Batt(t) Hub(t)  Conv(t) Cable(t) TOTAL(t)\n', 'Phase')
    for i in range(n):
        P('  %-5s  %6.1f    %5.1f   %5.1f   %5.1f   %5.1f   %5.1f    %5.1f\n',
          ph["lab"][i], ph["panel_kg"][i] / 1000, w["fsp_mass_cum"][i] / 1000, w["batt_mass"][i] / 1000,
          w["hub_mass"][i] / 1000, w["conv_mass"][i] / 1000, w["cable_mass"][i] / 1000, w["total_pwr_mass"][i])

    P('\n== FAILURE ANALYSIS ==\n')
    d6 = w["d6"]; mn = w["mn"]
    P('  P6: %.0ft demand -> min %d MI | fleet %d -> %d buffer\n', d6 / 1e3, mn, ph["mi"][3], ph["mi"][3] - mn)
    P('  Stockpile: %.0f t (%.1f months P6 reserve)\n', stk / 1e3, stk / d6 * 12)
    P('  Cold spares: %d (12%%)\n', w["sp"])
    P('  FSP N+1: 5th reactor at P7+ covers single failure (4×40=160 kW > 156 kW crit)\n')

    P('\n════════════════════════════════════════════════════════════════\n')
    P('  v5.0 VERIFICATION SUMMARY\n')
    P('════════════════════════════════════════════════════════════════\n')
    P('  MOLE-I: %d W op / %d W tether / %d W ka          ✓\n', mi["pwr_op"], _mround(mi["pwr_tether"]), mi["pwr_ka"])
    P('  Substation: %.1f W (10-component + ECN-013 enc)    ✓\n', node["overhead_v5"])
    P('  Scenario C: CO₂ closes (%.2f residual)            ✓\n', CO2_crew - CO2_sab - CO2_GH)
    P('  Hab: %.1f kW no-GH / %.1f kW with-GH              ✓\n', hab["no_GH"] / 1000, hab["with_GH"] / 1000)
    P('  ISRU elec (P7+): %.0f kW (%d PEM stacks)            ✓\n', ph["p_elec"][-1], ph["nPEM"][-1])
    P('  ISRU cryo (P7+): %.0f kW (calc) vs 256 kW (spec)   ⚠\n', ph["p_cryo"][-1])
    P('  Total demand (P7+): %.0f kW + 20%% = %.0f kW          \n', ph["p_sub"][-1], ph["p_tot"][-1])
    P('  Solar (P7+): %.0f m² (%.2f ha) with dust factor    ✓\n', ph["panel_m2"][-1], ph["panel_m2"][-1] / 10000)
    P('  FSP: %d×%d kWe = %d kW | Eclipse 72hr covered     ✓\n', ecl["nfsp"][-1], fsp["pwr_kW"], ecl["fsp_kW"][-1])
    P('  Propellant: all phases PASS                        ✓\n')
    for i in range(n):
        if ph["margin"][i] < 0:
            P('  ✗ %s: PROPELLANT DEFICIT\n', ph["lab"][i])
    P('  Pipeline: %.0f kW at P7+ (MUST NOT STOP in eclipse) ✓\n', pipe["total"][-1])
    P('\n  9 figures generated.\n')
    P('  Save as: SELENITE_VERIFY_v5_0_figures.pdf\n')
    return c.text()


# ---------------------------------------------------------------------------
# MOLEI_THERMAL_v1_3.m
# ---------------------------------------------------------------------------
_MI_TAB = [
    ['#  ', 'Function', 'Signal', 'Dir', 'Gauge', 'V', 'I', 'Destination'],
    ['1-2', 'Tether power', 'V+, V-', 'IN', 'AWG20', '1000V', '1.93A', 'PDU input'],
    ['3-4', 'VEX heater', 'HTR+, HTR-', 'OUT', 'AWG22', '1000V', '1.2A', '833ohm nichrome'],
    ['5-7', 'Drill motor', 'phA,phB,phC', 'OUT', 'AWG20', '48V', '4.2A', 'SmCo BLDC 3ph'],
    ['8-19', 'Wheel motors', 'W1-W6 +/-', 'OUT', 'AWG22', '48V', '1.0A', '6x SmCo hub BLDC'],
    ['20-31', 'Steering', 'W1-W6 +/-', 'OUT', 'AWG28', '28V', '0.5Apk', '6x SmCo rotary'],
    ['32-43', 'Gearbox htrs', 'W1-W6 +/-', 'OUT', 'AWG28', '28V', '0.18A', '6x 5W kapton'],
    ['44-45', 'Drill brg htr', '+/-', 'OUT', 'AWG28', '28V', '0.54A', '15W kapton'],
    ['46-47', 'Recept htr', '+/-', 'OUT', 'AWG28', '28V', '0.18A', '5W band heater'],
    ['48-59', 'Gearbox Pt100', 'W1-W6 +/-', 'IN', 'AWG28', 'sig', 'uA', '6x Pt100 RTD'],
    ['60-61', 'Drill Pt100', '+/-', 'IN', 'AWG28', 'sig', 'uA', 'Pt100 bearing'],
    ['62-63', 'Recept Pt100', '+/-', 'IN', 'AWG28', 'sig', 'uA', 'Pt100 connector'],
    ['64-65', 'VEX Pt100', '+/-', 'IN', 'AWG28', 'sig', 'uA', 'Pt100 chamber'],
    ['66-67', 'Drill torque', '+/-', 'IN', 'AWG28', 'sig', 'mA', 'Strain gauge'],
    ['68-69', 'Drill vibration', 'sig,gnd', 'IN', 'AWG28', 'sig', 'mA', 'Accelerometer'],
    ['70-81', 'Wheel encoders', 'W1-W6 A/B', 'IN', 'AWG28', 'sig', 'uA', '6x quadrature'],
    ['82-83', 'PLC comms', 'TX,RX', 'BI', 'AWG28', 'sig', 'mA', 'Tether PLC'],
    ['84   ', 'RF antenna', 'coax', 'OUT', 'AWG22', 'RF', 'mA', '50ohm element'],
    ['85-88', 'Prox sensors', '1&2 sig/gnd', 'IN', 'AWG28', 'sig', 'mA', '2x docking'],
    ['89-92', 'VEX valves', 'intake+tail', 'OUT', 'AWG28', '28V', '0.3A', '2x solenoid'],
    ['93-94', 'VEX pressure', '+/-', 'IN', 'AWG28', 'sig', 'mA', '0-20kPa xducer'],
    ['95-96', 'Strap TC', '+/-', 'IN', 'AWG30', 'sig', 'uV', 'Type K midpoint'],
    ['97-98', 'Condenser TC', '+/-', 'IN', 'AWG30', 'sig', 'uV', 'Type K VEX'],
    ['99-106', 'LWRHU TCs', 'TC1-4 +/-', 'IN', 'AWG30', 'sig', 'uV', '4x Type K'],
    ['107-108', 'Drain valve', 'pos +/-', 'IN', 'AWG28', 'sig', 'mA', 'Position switch'],
]
_SUB_TAB = [
    ['#  ', 'Function', 'Signal', 'Dir', 'Gauge', 'V', 'I', 'Destination'],
    ['1-2', 'Branch power', 'V+, V-', 'IN', 'AWG14', '1000V', '~10A', 'Bus bar input'],
    ['3-14', 'Port outputs', 'P1-P6 +/-', 'OUT', 'AWG14', '1000V', '~2A', '6x tether drums'],
    ['15-24', 'Drum motors', 'D1-D5 +/-', 'OUT', 'AWG22', '28V', '~1A', '5x DC tension motor'],
    ['25-34', 'Drum heaters', 'D1-D5 +/-', 'OUT', 'AWG28', '28V', '0.29A', '5x 8W kapton'],
    ['35-44', 'Funnel heaters', 'F1-F5 +/-', 'OUT', 'AWG28', '28V', '0.11A', '5x 3W kapton'],
    ['45-46', 'Transfer pump', 'pump +/-', 'OUT', 'AWG22', '28V', '0.36A', 'Peristaltic 10W'],
    ['47-48', 'Riser heater', '+/-', 'OUT', 'AWG28', '28V', '0.75A', '21W trace heat'],
    ['49   ', 'RF antenna', 'coax', 'OUT', 'AWG22', 'RF', 'mA', 'Relay element'],
    ['50-59', 'Drum Pt100', 'D1-D5 +/-', 'IN', 'AWG28', 'sig', 'uA', '5x temp sensor'],
    ['60-61', 'Riser Pt100', '+/-', 'IN', 'AWG28', 'sig', 'uA', 'Pipe temp'],
    ['62-63', 'Pump feedback', '+/-', 'IN', 'AWG28', 'sig', 'mA', 'RPM/status'],
]
_SUB_PWR = [('WEB heater', 'continuous'), ('Drum gbx heaters 5x8W', 'continuous'),
            ('Transfer pump', 'intermittent'), ('Riser trace heat', 'continuous'),
            ('Funnel lip htrs 5x3W', 'dump only (~3W avg)'), ('Comms relay (PLC+RF)', 'continuous'),
            ('Controller + sensors', 'continuous'), ('Port solenoids (6x0.5W)', 'continuous')]


def thermal_v1_3(ws=None) -> str:
    from . import thermal
    w = ws or thermal.workspace()
    c = _Console(); P = c.p
    Tf = w["Tf"]; Tw = w["Tw"]; Tweb = w["Tweb"]; dT = w["dT"]; wA = w["wA"]; wC = w["wC"]; lwP = w["lwP"]
    Gweb = w["Gweb"]; Qtot = w["Qtot"]; shunt = w["shunt"]; sQtot = w["sQtot"]; stot = w["stot"]; Ptether = w["Ptether"]
    P('================================================================\n')
    P('  MOLE-I THERMAL v1.3\n')
    P('  108-conductor harness + substation thermal audit\n')
    P('================================================================\n\n')
    P('== S1: Constants. T_floor=%d T_wall=%d T_web=%d dT=%d K\n', Tf, Tw, Tweb, dT)
    P('  WEB: A=%.3f m^2, C=%.0f J/K (%.0f Wh/K)\n\n', wA, wC, wC / 3600)

    P('== S2: MOLE-I WEB heat loss paths ==\n')
    P('  C: Harness (v1.3: %d conductors, all Manganin %dmm)\n', w["mi_ntot"], w["Lm"] * 1e3)
    P('     AWG20: %2d x %.3fmm2 = %.4fW\n', w["mi_n20"], w["mi_A20"] * 1e6, w["QC_20"])
    P('     AWG22: %2d x %.3fmm2 = %.4fW\n', w["mi_n22"], w["mi_A22"] * 1e6, w["QC_22"])
    P('     AWG28: %2d x %.3fmm2 = %.4fW\n', w["mi_n28"], w["mi_A28"] * 1e6, w["QC_28"])
    P('     AWG30: %2d x %.3fmm2 = %.4fW\n', w["mi_n30"], w["mi_A30"] * 1e6, w["QC_30"])
    P('     TOTAL: %.3fW (was 0.359W in v1.2 with 49 cond)\n', w["QCv"])
    pn = ['A: PEEK standoffs (4x)', 'B: Drain pipe Ti+PEEK', _mf('C: Cables (%d Mn, v1.3)', w["mi_ntot"]),
          'D: VEX tube PEEK', 'E: MLI penetrations 5x', 'F: Valve actuator', 'G: Feed chute 50%', 'H: MLI 20-layer']
    P('\n  %-36s %8s\n', 'Path', 'Q (W)')
    P('  %s\n', '-' * 48)
    for i in range(8):
        P('  %-36s %8.3f\n', pn[i], w["Qv"][i])
    P('  %s\n', '-' * 48)
    P('  %-36s %8.3f\n', 'SUBTOTAL', w["Qsub"])
    P('  %-36s %8.3f\n', '30%% margin', w["Qmar"])
    P('  %-36s %8.3f\n', 'TOTAL', Qtot)
    P('\n  G_web = %.5f W/K\n', Gweb)

    P('\n== S3: MOLE-I conductor table (108 through WEB wall) ==\n')
    P('  All 1000 VDC architecture. PDU inside WEB converts to 48/28/5V.\n')
    P('  VEX heater: 1000V direct (SiC MOSFET switch), 833 ohm nichrome.\n\n')
    P('  %-8s %-16s %-16s %-4s %-6s %-6s %-6s %s\n', *_MI_TAB[0])
    P('  %s\n', '-' * 78)
    for row in _MI_TAB[1:]:
        P('  %-8s %-16s %-16s %-4s %-6s %-6s %-6s %s\n', *row)
    P('  %s\n', '-' * 78)
    P('  TOTAL: %d conductors | Harness Q = %.3f W\n', w["mi_ntot"], w["QCv"])

    P('\n== S4: LWRHU sizing ==\n')
    P('  N | Q_in | T_eq(40K) | T_eq(25K) | >250K fl | >250K wl\n')
    P('  %s\n', '-' * 60)
    for N in range(3, 11):
        Qi = N * lwP; Teqf = Tf + Qi / Gweb; Teqw = Tw + Qi / Gweb
        P('  %d | %.1fW | %6.1fK   | %6.1fK   | %-3s     | %-3s\n', N, Qi, Teqf, Teqw,
          _tern(Teqf >= 250, 'YES', 'no'), _tern(Teqw >= 250, 'YES', 'no'))
    P('  Indefinite 250K: %d LWRHU (%.1fW)\n', w["N250"], w["N250"] * lwP)

    P('\n== S5: mini-VEX thermal strap ==\n')
    P('  VEX loss at %dK: %.2fW | Strap cap: %.2fW | Residual htr: %.2fW\n', w["Tvex"], w["Qvx_loss"], w["Qstrap"], w["Qvx_htr"])
    P('  Strap draws %.2fW from WEB\n', w["Qvx_draw"])

    P('\n== S6: Tether connector ==\n')
    P('  PEEK+Mn: %.2fW (spec 5W). Passive funnel dock.\n', w["Qcf_PK"] + w["Qcc_Mn"])

    P('\n== S7: Wax-actuated thermal shunt ==\n')
    P('  G_web=%.4f | G_shunt(1.5x)=%.4f | G_total=%.4f W/K\n', Gweb, shunt["G_margin"], Gweb + shunt["G_margin"])
    P('  No shunt: T_eq=%.0fK | With shunt: T_eq=%.0fK\n', w["Teq_noshunt"], w["Teq_drill_os"])
    P('  Shunt: n-tetradecane, ON>%dK, OFF<%dK, ~50-80g, passive\n', shunt["T_on"], shunt["T_off"])

    P('\n== S8: Keep-alive budget + power architecture ==\n')
    P('\n  POWER ARCHITECTURE (1000 VDC end-to-end):\n')
    P('  Trunk->Branch->Substation(passive bus)->Tether->MOLE-I WEB PDU\n')
    P('  PDU: 1000V->48V (95%%eff) | 1000V->28V (93%%eff) | 28V->5V (90%%eff)\n')
    P('  VEX heater: 1000V direct via SiC MOSFET (no converter)\n')
    P('\n  DC-DC conversion losses:\n')
    P('    48V bus: %dW load / %.0f%% = %.0fW loss\n', w["P48_load"], w["eff48"] * 100, w["P48_loss"])
    P('    28V bus: %dW load / %.0f%% = %.1fW loss\n', w["P28_load"], w["eff28"] * 100, w["P28_loss"])
    P('    5V bus:  %dW load / %.0f%% = %.1fW loss\n', w["P5_load"], w["eff5"] * 100, w["P5_loss"])
    P('    TOTAL conversion loss: %.0fW\n', w["Ploss_dcdc"])
    P('    Battery trickle charge: %dW\n', w["Pbatt_charge"])
    P('    MOLE-I TETHER DRAW: %dW load + %.0fW conv + %dW batt = %.0fW\n',
      w["Pload"], w["Ploss_dcdc"], w["Pbatt_charge"], Ptether)
    P('    At 1000V: %.3fA per MOLE-I\n', Ptether / 1000)
    ka_items = ['WEB heater', 'Gearbox 6x5W', 'Drill bearing', 'Receptacle', 'VEX standby', 'Thermal shunt']
    P('\n  %-24s | %7s | %9s | %10s\n', 'Subsystem', 'Original', 'Realistic', 'Optimistic')
    P('  %s\n', '-' * 60)
    for i in range(6):
        P('  %-24s | %6.1fW | %8.1fW | %9.1fW\n', ka_items[i], w["ka_orig"][i], w["ka_real"][i], w["ka_opt"][i])
    tR = w["tR"]
    P('  %s\n', '-' * 60)
    P('  %-24s | %6.0fW | %8.0fW | %9.0fW\n', 'TOTAL', w["tO"], tR, w["tP"])
    P('\n  Transit battery: %.0fW x 4.7hr x 1.10 = %.0f Wh / %.1f kg\n', tR, tR * 4.7 * 1.10, tR * 4.7 * 1.10 / 250)

    P('\n== S9: Multi-mode transient (with vs without shunt) ==\n')
    modes = ['DRILL', 'DUMP', 'DRILL', 'DUMP', 'DRILL', 'FAIL']
    for case_id, label in ((0, 'WITHOUT SHUNT'), (1, 'WITH SHUNT (1.5x)')):
        P('\n  %s:\n', label)
        for m in range(6):
            t_start, t_end, t_max = w["_mode_stats"][case_id][m]
            P('    %s: %.1fK -> %.1fK (max %.1fK)\n', modes[m], t_start, t_end, t_max)
    P('\n  POWER FAILURE (LWRHU only, T_amb=40K, shunt present):\n')
    P('  N  | T@24hr | T@72hr | T@200hr | t(253K)\n')
    P('  %s\n', '-' * 50)
    for Nl, T24, T72, T200, s253 in w["_fail_rows"]:
        P('  %2d | %.1fK | %.1fK | %.1fK  | %s\n', Nl, T24, T72, T200, s253)

    P('\n================================================================\n')
    P('  S10: SUBSTATION WEB — BOTTOM-UP THERMAL AUDIT (NEW v1.3)\n')
    P('================================================================\n')
    P('  WEB: %.0fx%.0fx%.0f mm, A=%.4f m2, C=%.0f J/K\n', w["sL"] * 1e3, w["sW"] * 1e3, w["sH"] * 1e3, w["sA"], w["sC"])
    spn = ['A: Struct mounts (4x PEEK)', 'B: Bus bar trans (Mn 20mm)', 'C: Harness (49 non-bus Mn)',
           'D: Riser pipe Ti+PEEK', 'E: MLI penetrations 4x', 'F: Funnel inlets (PEEK)', 'G: MLI 20-layer']
    P('\n  %-36s %8s\n', 'Path', 'Q (W)')
    P('  %s\n', '-' * 48)
    for i in range(7):
        P('  %-36s %8.3f\n', spn[i], w["sQv"][i])
    P('  %s\n', '-' * 48)
    P('  %-36s %8.3f\n', 'SUBTOTAL', w["sQsub"])
    P('  %-36s %8.3f\n', '30%% margin', w["sQmar"])
    P('  %-36s %8.3f\n', 'TOTAL', sQtot)
    P('  %-36s %8.5f\n', 'G_sub (heater sizing, w/ margin)', w["sGweb"])
    P('  %-36s %8.5f\n', 'G_sub (ODE, conductive only)', w["sGc"])
    P('\n  Original spec: 80W. Audited: %.1fW. Was %.0fx too high.\n', sQtot, 80 / sQtot)
    P('  Bus bar I2R losses: %.2fW (input) + %.2fW (ports) = %.2fW\n', w["sIR_in"], w["sIR_pt"], w["sIR_in"] + w["sIR_pt"])

    P('\n== S11: Substation conductor table (63 through WEB wall) ==\n')
    P('  %-8s %-16s %-14s %-4s %-6s %-6s %-6s %s\n', *_SUB_TAB[0])
    P('  %s\n', '-' * 78)
    for row in _SUB_TAB[1:]:
        P('  %-8s %-16s %-14s %-4s %-6s %-6s %-6s %s\n', *row)
    P('  %s\n', '-' * 78)
    P('  TOTAL: 63 conductors | Harness Q = %.3f W (bus) + %.3f W (signal)\n', w["sQB"], w["sQC"])

    P('\n== S12: Substation LWRHU sizing + power failure survival ==\n')
    P('\n  LWRHU equilibrium (T_amb=40K):\n')
    P('  N | Q_in | T_eq | Heater needed | Survival note\n')
    P('  %s\n', '-' * 65)
    for N in range(1, 6):
        Qi = N * lwP; Teq = Tf + Qi / w["sGweb"]; Htr = max(0, sQtot - Qi)
        P('  %d | %.1fW | %5.0fK |   %5.1fW      | %s\n', N, Qi, Teq, Htr,
          _tern(Teq >= 250, 'Indefinite >250K', 'Below 250K'))
    P('\n  POWER FAILURE TRANSIENT (ODE45, starting at 273K):\n')
    P('  N  | T@6hr  | T@12hr | T@24hr | T@48hr | t(253K)\n')
    P('  %s\n', '-' * 60)
    for Nl, T6, T12, T24, T48, s253 in w["_sub_fail_rows"]:
        P('  %2d | %.1fK | %.1fK | %.1fK | %.1fK | %s\n', Nl, T6, T12, T24, T48, s253)

    P('\n== S13: Substation power budget (audited) ==\n')
    P('  %-30s %-22s %8s\n', 'Component', 'Duty', 'Power (W)')
    P('  %s\n', '-' * 64)
    for (name, duty), watts in zip(_SUB_PWR, w["sub_pwr_W"]):
        P('  %-30s %-22s %7.1fW\n', name, duty, watts)
    P('  %s\n', '-' * 64)
    P('  %-30s %-22s %7.1fW\n', 'TOTAL (substation own)', '-', stot)
    P('\n  Original spec: 130W (continuous). Audited: %.0fW.\n', stot)
    P('  Note: 80W heater -> %.0fW is the biggest change (was %.0fx oversized)\n', sQtot, 80 / sQtot)
    P('\n  NODE TOTAL (substation + 5 MOLE-I):\n')
    P('    Substation own:  %.0fW\n', stot)
    P('    5x MOLE-I tether draw: 5 x %.0fW = %.0fW\n', Ptether, 5 * Ptether)
    P('    NODE TOTAL: %.0fW (%.2fA at 1000V)\n', stot + 5 * Ptether, (stot + 5 * Ptether) / 1000)
    P('    P7+ (34 nodes): %.1f kW\n', 34 * (stot + 5 * Ptether) / 1000)

    P('\n================================================================\n')
    P('  v1.3 CONCLUSIONS\n')
    P('================================================================\n')
    P('  MOLE-I WEB:\n')
    P('    Harness: %d conductors (was 49). Q = %.3fW (was 0.359W)\n', w["mi_ntot"], w["QCv"])
    P('    Total WEB loss: %.1fW (unchanged from v1.2 within 2%%)\n', Qtot)
    P('    Keep-alive: %.0fW. Battery: %.0f Wh / %.1f kg\n', tR, tR * 4.7 * 1.10, tR * 4.7 * 1.10 / 250)
    P('    Tether draw: %.0fW (load %.0f + DC-DC %.0f + batt %d)\n', Ptether, w["Pload"], w["Ploss_dcdc"], w["Pbatt_charge"])
    P('    VEX heater: 1000V direct, SiC MOSFET, 833ohm nichrome\n')
    P('  SUBSTATION WEB:\n')
    P('    WEB heater: 80W -> %.0fW (%.0fx oversized)\n', sQtot, 80 / sQtot)
    P('    Conductors: 63 through wall\n')
    P('    Substation own demand: %.0fW (was 130W)\n', stot)
    P('    LWRHU: recommend 3x (t_253K=%.0fhr vs 1x)\n', w["_t253_last"])
    P('    Node total: %.0fW (sub %.0f + 5xMI %.0f)\n', stot + 5 * Ptether, stot, 5 * Ptether)
    P('    P7+ PSR total: %.1f kW (34 nodes + pipeline 59.5 + pump 0.4)\n', 34 * (stot + 5 * Ptether) / 1000 + 59.5 + 0.4)
    P('================================================================\n')
    P('  Figures: same 8 as v1.2 + 2 new substation figures\n')
    P('================================================================\n')
    P('\n  10 figures generated.\n')
    return c.text()


# ---------------------------------------------------------------------------
# SELENITE_ECON_V1_3.m
# ---------------------------------------------------------------------------
def econ_v1_3(ws=None, now: datetime | None = None) -> str:
    from . import econ
    w = ws or econ.workspace("SELENITE_ECON_V1_3")
    c = _Console(); P = c.p
    circuit = w["circuit"]; cds = w["circuit_designs"]; CD = int(w["CIRCUIT_DESIGN"])
    Y = w["Y"]; reo_final = w["reo_final"]; reo_final_alt = w["reo_final_alt"]
    i160 = int(w["i160"]) - 1; i200 = int(w["i200"]) - 1
    stamp = (now or datetime.now()).strftime("%d-%b-%Y %H:%M:%S")
    P('SELENITE_ECON v1.3 — 200-Year Model\n')
    P('ECN-019 Rev B | %s\n\n', stamp)
    P('Circuit design: %s\n', cds[CD - 1]["name"])
    P('  %.1f t/yr REO, %d kg, %d kW per circuit\n', circuit["reo_yr"], circuit["mass_kg"], circuit["power_kw"])
    P('  Circuits for 1.25 Mt/yr: %s\n\n', str(int(math.ceil(1250000 / circuit["reo_yr"]))))

    def S(x):
        return float(np.sum(x))

    P('═══════════════════════════════════════════════\n')
    P('  200-YEAR PROGRAMME METRICS\n')
    P('═══════════════════════════════════════════════\n\n')
    P('Total cost (200 yr):        $%.2f T\n', w["cum_cost"][-1] / 1e6)
    P('  Earth launch:             $%.2f T\n', S(w["cost_launch"]) / 1e6)
    P('  In-situ fabrication:      $%.2f T\n', S(w["cost_insitu"]) / 1e6)
    P('  Mk III PROBEs (LEO):      $%.2f T\n', S(w["cost_mkiii"]) / 1e6)
    P('  Redirect tugs (LEO):      $%.2f T\n', S(w["cost_tugs"]) / 1e6)
    P('  DRO operations:           $%.2f T\n', S(w["cost_dro_ops"]) / 1e6)
    P('  Asteroid processing:      $%.2f T\n', S(w["cost_asteroid_processing"]) / 1e6)
    P('  R&D / programme mgmt:     $%.2f T\n', S(w["cost_rd"]) / 1e6)
    P('Direct revenue:             $%.2f T\n', S(w["rev_direct"]) / 1e6)
    P('  REO sales:                $%.2f T\n', S(w["rev_reo"]) / 1e6)
    P('  PGM sales (all sources):  $%.2f T\n', S(w["rev_pgm"]) / 1e6)
    P('    Mk I/II PROBEs:         %.0f t total PGM\n', S(w["pgm_production"]))
    P('    Mk III PROBEs:          %.0f t total PGM\n', S(w["mkiii_pgm"]))
    P('    Captured asteroids:     %.0f t total PGM\n', S(w["captured_asteroid_pgm"]))
    P('REO extern (mining):        $%.2f T\n', S(w["ext_reo"]) / 1e6)
    P('H2 extern (Ir, 50%% attr):   $%.2f T\n', S(w["ext_h2"]) / 1e6)
    P('Geopolitical insurance:     $%.2f T\n', S(w["ext_geo"]) / 1e6)
    P('Rocket emissions:           $%.2f T\n', S(w["ext_rockets"]) / 1e6)
    P('Total rev + extern:         $%.2f T\n', w["cum_rev"][-1] / 1e6)
    P('NPV (all extern):           $%.2f T\n', w["npv_total"][-1] / 1e6)
    P('NPV (direct only):          $%.2f T\n', w["npv_direct"][-1] / 1e6)
    P('Earth cargo (200 yr):       %.1f Mt\n', S(w["earth_cargo"]) / 1e6)
    P('Lifetime rocket CO2:        %.0f Mt\n', S(w["co2_rockets"]) / 1e6)
    be = w["be_total"]
    if np.size(be):
        P('Breakeven (undiscounted):   Y%d\n', Y[int(be[0]) - 1])
    else:
        P('Breakeven (undiscounted):   NOT REACHED\n')

    P('\n--- Infrastructure at Key Years ---\n')
    P('%-6s %10s %10s %10s %6s %8s %8s %10s\n', 'Year', 'REO t/y', 'Circuits', 'Haulers', 'MSR', 'Conv km', 'MOLE-I', 'Cargo t/y')
    for y in w["check_y"]:
        i = int(y)
        P('Y%-5d %10.0f %10d %10d %6d %8.0f %8d %10.0f\n', y, w["reo_target"][i], w["circuits_needed"][i],
          w["haulers_needed"][i], w["msr_count"][i], w["conv_km_needed"][i], w["molei_needed"][i], w["earth_cargo"][i])

    rt = w["rev_total"]; ct = w["cost_total"]
    P('\n--- Status at Y160 (2.5 Mt/yr build-out: 1.5 Mt/yr at this point) ---\n')
    P('  REO production:   %.0f t/yr (target: %.0f)\n', w["reo_target"][i160], reo_final)
    P('  Annual cost:      $%.1fB/yr\n', ct[i160] / 1e3)
    P('    of which launch:  $%.1fB\n', w["cost_launch"][i160] / 1e3)
    P('    of which in-situ: $%.1fB\n', w["cost_insitu"][i160] / 1e3)
    P('    of which Mk III:  $%.1fB\n', w["cost_mkiii"][i160] / 1e3)
    P('    of which tugs:    $%.1fB\n', w["cost_tugs"][i160] / 1e3)
    P('    of which DRO ops: $%.1fB\n', w["cost_dro_ops"][i160] / 1e3)
    P('    of which ast proc: $%.1fB (C-type $0.5B + S-type $0.8B)\n', w["cost_asteroid_processing"][i160] / 1e3)
    P('  Direct revenue:   $%.1fB/yr\n', w["rev_direct"][i160] / 1e3)
    P('    REO sales:      $%.1fB (%.0f t × $%.0f/t)\n', w["rev_reo"][i160] / 1e3, w["reo_target"][i160], w["reo_price"][i160])
    P('    PGM sales:      $%.1fB (%.1f t total)\n', w["rev_pgm"][i160] / 1e3, w["total_pgm"][i160])
    P('      Mk I/II:     %.1f t/yr\n', w["pgm_production"][i160])
    P('      Mk III:      %.1f t/yr (%d active)\n', w["mkiii_pgm"][i160], _mround(w["mkiii_active"][i160]))
    P('      Asteroids:   %.1f t/yr PGM (1 M-type, processing since Y85)\n', w["captured_asteroid_pgm"][i160])
    P('    Asteroid captures: M-type Y75, C-type Y95, S-type Y115\n')
    P('    Circuit Earth frac: %.1f%% (reduced by C-type carbon + S-type Si)\n',
      max(0.008, 0.10 - 0.07 * min(1, (Y[i160] - 105) / 10) - 0.022 * min(1, (Y[i160] - 125) / 10)) * 100)
    P('  Externalities:    $%.1fB/yr (REO $%.1f + H2 $%.1f + Geo $%.1f + Rockets $%.1f)\n',
      w["ext_total"][i160] / 1e3, w["ext_reo"][i160] / 1e3, w["ext_h2"][i160] / 1e3, w["ext_geo"][i160] / 1e3,
      w["ext_rockets"][i160] / 1e3)
    P('  Total Ir:         %.1f t/yr (attributed: %.1f t at 50%%)\n', w["total_ir"][i160], w["ir_attributed"][i160])
    P('  PEM installed:    %.1f GW\n', w["pem_gw"][i160])
    P('  Rev+Ext / Cost:   %.2f\n', rt[i160] / ct[i160])
    P('  Net annual:       $%.1fB/yr (%s)\n', (rt[i160] - ct[i160]) / 1e3, _tern(rt[i160] > ct[i160], 'POSITIVE', 'negative'))
    P('\n--- Environmental Balance at Y160 ---\n')
    P('  CO2 avoided (REE): %.1f Mt/yr\n', w["co2_avoided_reo"][i160] / 1e6)
    P('  CO2 avoided (H2):  %.1f Mt/yr\n', w["co2_avoided_h2"][i160] / 1e6)
    P('  CO2 rockets:       %.1f Mt/yr\n', w["co2_rockets"][i160] / 1e6)
    P('  NET CO2:           %.1f Mt/yr\n',
      (w["co2_avoided_reo"][i160] + w["co2_avoided_h2"][i160] - w["co2_rockets"][i160]) / 1e6)

    P('\n--- TRUE STEADY STATE at Y200 (2.5 Mt/yr, 20 years post build-out) ---\n')
    P('  REO production:   %.0f t/yr\n', w["reo_target"][i200])
    P('  Annual cost:      $%.1fB/yr\n', ct[i200] / 1e3)
    P('  Direct revenue:   $%.1fB/yr\n', w["rev_direct"][i200] / 1e3)
    P('  Externalities:    $%.1fB/yr\n', w["ext_total"][i200] / 1e3)
    P('  Rev+Ext / Cost:   %.2f\n', rt[i200] / ct[i200])
    P('  Net annual:       $%.1fB/yr (%s)\n', (rt[i200] - ct[i200]) / 1e3, _tern(rt[i200] > ct[i200], 'POSITIVE', 'negative'))
    P('  CO2 avoided:      %.1f Mt/yr (REE %.1f + H2 %.1f - rockets %.1f)\n',
      (w["co2_avoided_reo"][i200] + w["co2_avoided_h2"][i200] - w["co2_rockets"][i200]) / 1e6,
      w["co2_avoided_reo"][i200] / 1e6, w["co2_avoided_h2"][i200] / 1e6, w["co2_rockets"][i200] / 1e6)

    # ---- 9. circuit throughput sensitivity (recomputed per design) -------
    P('\n═══════════════════════════════════════════════\n')
    P('  CIRCUIT THROUGHPUT SENSITIVITY\n')
    P('═══════════════════════════════════════════════\n')
    N = int(w["N"]); df = w["df"]; ec = w["earth_cargo"]
    for cd in cds:
        circ_k = np.ceil(w["reo_target"] / cd["reo_yr"])
        d_circ_k = np.maximum(0.0, np.diff(np.concatenate([[0.0], circ_k])))
        ef = np.array([circuit["earth_frac"](Y[i]) for i in range(N)])
        cargo_k = d_circ_k * cd["mass_kg"] * ef / 1000
        maint_k = circ_k * cd["mass_kg"] * 0.02 * ef / 1000
        insitu_k = d_circ_k * cd["mass_kg"] * (1 - ef) / 1000
        ec_k = ec - w["cargo_circuits"] - w["maint_circuits"] + cargo_k + maint_k
        cl_k = ec_k * 1000 * w["launch_cost"] * w["contingency"] / 1e6
        is_k = (w["insitu_total"] - w["insitu_circuits"] + insitu_k) * 1000 * w["insitu_cost_per_kg"] / 1e6
        ct_k = cl_k + is_k + w["cost_rd"]
        npv_k = S((rt - ct_k) * df)
        nc = math.ceil(reo_final / cd["reo_yr"])
        P('\n  %s:\n', cd["name"])
        P('    Circuits for 1.25 Mt/yr: %s\n', str(int(nc)))
        P('    Mass per circuit: %d kg (Earth: %d kg at 10%%)\n', cd["mass_kg"], _mround(cd["mass_kg"] * 0.1))
        P('    Total circuit mass: %.1f Mt (Earth: %.1f Mt)\n', nc * cd["mass_kg"] / 1e9, nc * cd["mass_kg"] * 0.1 / 1e9)
        P('    200-yr cost: $%.2f T\n', S(ct_k) / 1e6)
        P('    NPV (all extern): $%.2f T\n', npv_k / 1e6)
        P('    NPV delta from batch: $%.2f T\n', (npv_k - w["npv_total"][-1]) / 1e6)

    # ---- 10. other sensitivities ------------------------------------------
    P('\n═══════════════════════════════════════════════\n')
    P('  OTHER SENSITIVITIES\n')
    P('═══════════════════════════════════════════════\n')
    net_total = w["net_total"]
    dr_labs = ['Stern 1.4%', 'Flat 2.0%', 'Flat 3.0%', 'UK Green 3.5%']
    P('\nDiscount rate:\n')
    for k in range(4):
        df_k = np.cumprod(1.0 / (1.0 + w["dr_opts"][k] * np.ones(N)))
        P('  %s: NPV $%.2fT\n', dr_labs[k], S(net_total * df_k) / 1e6)
    P('\nLaunch cost:\n')
    for mult in (1.5, 1.0, 0.5):
        cl_k = ec * 1000 * (w["launch_cost"] * mult) * w["contingency"] / 1e6
        ct_k = cl_k + w["cost_insitu"] + w["cost_rd"]
        P('  %.0f%%: NPV $%.2fT\n', mult * 100, S((rt - ct_k) * df) / 1e6)
    P('\nGeopolitical insurance:\n')
    sf = w["supply_frac"]
    for gval in (0, 15000, 25000):
        ext_g_k = np.where(sf > w["geo_threshold"], gval * np.minimum(1, sf / 0.5), 0.0)
        rev_k = w["rev_direct"] + w["ext_reo"] + w["ext_h2"] + w["ext_rockets"] + ext_g_k
        P('  $%dB/yr: NPV $%.2fT\n', gval / 1000, S((rev_k - ct) * df) / 1e6)

    # ---- 12. comparison ----------------------------------------------------
    P('\n═══════════════════════════════════════════════\n')
    P('  COMMITTED TARGET vs STOP-EARLY ALTERNATIVE\n')
    P('═══════════════════════════════════════════════\n')
    ct_25 = w["ct_25"]; rv_25 = w["rv_25"]; ec_25 = w["ec_25"]
    P('\n%-30s %15s %15s\n', '', '2.5 Mt/yr', '1.25 Mt/yr')
    P('%-30s %15s %15s\n', '', '(committed)', '(stop-early)')
    P('%-30s %15.0f %15.0f\n', 'Circuits needed', math.ceil(reo_final / circuit["reo_yr"]), math.ceil(reo_final_alt / circuit["reo_yr"]))
    P('%-30s %15.0f %15.0f\n', 'Haulers needed', w["haulers_needed"][i200], w["haul_25"][i200])
    P('%-30s %15.0f %15.0f\n', 'MSR count', w["msr_count"][i200], w["msr_25"][i200])
    P('%-30s %15.0f %15.0f\n', 'Conveyor km', w["conv_km_needed"][i200], w["conv_25"][i200])
    P('%-30s %12.1f Mt %12.1f Mt\n', 'Earth cargo (200 yr)', S(ec) / 1e6, S(ec_25) / 1e6)
    P('%-30s %12.2f $T %12.2f $T\n', 'Total cost (200 yr)', w["cum_cost"][-1] / 1e6, S(ct_25) / 1e6)
    P('%-30s %12.2f $T %12.2f $T\n', 'REO extern (200 yr)', S(w["ext_reo"]) / 1e6, S(w["er_25"]) / 1e6)
    P('%-30s %12.2f $T %12.2f $T\n', 'Geo insurance (200 yr)', S(w["ext_geo"]) / 1e6, S(w["eg_25"]) / 1e6)
    P('%-30s %12.2f $T %12.2f $T\n', 'Total rev+extern', w["cum_rev"][-1] / 1e6, S(rv_25) / 1e6)
    P('%-30s %12.2f $T %12.2f $T\n', 'NPV (all extern)', w["npv_total"][-1] / 1e6, w["npv_25"] / 1e6)
    P('%-30s %12.1f $B %12.1f $B\n', 'SS cost/yr', ct[i200] / 1e3, ct_25[i200] / 1e3)
    P('%-30s %12.1f $B %12.1f $B\n', 'SS rev+ext/yr', rt[i200] / 1e3, rv_25[i200] / 1e3)
    P('%-30s %12.1f $B %12.1f $B\n', 'SS net/yr', (rt[i200] - ct[i200]) / 1e3, (rv_25[i200] - ct_25[i200]) / 1e3)
    P('%-30s %12s %12s\n', 'Steady-state reached', 'Y180', 'Y140')
    P('%-30s %12.0f Mt %12.0f Mt\n', 'CO2 avoided at SS/yr',
      (w["co2_avoided_reo"][i200] + w["co2_avoided_h2"][i200]) / 1e6,
      (w["reo_25"][i200] * 30 + w["co2_avoided_h2"][i200]) / 1e6)
    P('\n2.5 Mt/yr costs $%.1fT more over 200 yr but generates $%.1fT more benefit.\n',
      (w["cum_cost"][-1] - S(ct_25)) / 1e6, (w["cum_rev"][-1] - S(rv_25)) / 1e6)
    P('SS net surplus: $%.1fB/yr (2.5) vs $%.1fB/yr (1.25)\n', (rt[i200] - ct[i200]) / 1e3, (rv_25[i200] - ct_25[i200]) / 1e3)
    P('COMMITTED TARGET: 2.5 Mt/yr — full replacement of terrestrial REE mining.\n')
    P('\n═══════════════════════════════════════════════\n')
    P('  SELENITE_ECON v1.3 COMPLETE — 4 figures saved\n')
    P('  200-year model, cadence-constrained, %s circuits\n', cds[CD - 1]["name"])
    P('  Diversified asteroid strategy: M-type + C-type + S-type\n')
    P('═══════════════════════════════════════════════\n')
    return c.text()


# ---------------------------------------------------------------------------
# SELENITE_ECON_V1_4.m
# ---------------------------------------------------------------------------
_SENS_NAMES = ['Circuit: batch(0.4) vs cont(0.8)', 'Discount rate (1.4% vs 3.5%)', 'Launch cost (+50% vs -50%)',
               'REO extern ($50k vs $90k/t)', 'H2 attribution (25% vs 100%)', 'Geo insurance ($0 vs $25B/yr)',
               'Maint rate (0.5% vs 0.25%)']


def econ_v1_4(ws=None) -> str:
    from . import econ
    w = ws or econ.workspace("SELENITE_ECON_V1_4")
    c = _Console(); P = c.p
    rt = w["rev_total"]; ct = w["cost_total"]; Y = w["Y"]
    P('\n\n')
    P('████████████████████████████████████████████████\n')
    P('  SELENITE_ECON v1.4 — REPORT ANALYSIS LAYER\n')
    P('████████████████████████████████████████████████\n\n')
    P('--- BENEFIT-COST RATIO ---\n')
    P('  PV of costs:              $%.2f T\n', w["pv_cost"] / 1e6)
    P('  PV of direct revenue:     $%.2f T\n', w["pv_rev_direct"] / 1e6)
    P('  PV of REO extern:         $%.2f T\n', w["pv_ext_reo"] / 1e6)
    P('  PV of H2 extern:          $%.2f T\n', w["pv_ext_h2"] / 1e6)
    P('  PV of geo insurance:      $%.2f T\n', w["pv_ext_geo"] / 1e6)
    P('  PV of rocket emissions:   $%.2f T\n', w["pv_ext_rockets"] / 1e6)
    P('  PV of total benefits:     $%.2f T\n', w["pv_rev_total"] / 1e6)
    P('\n')
    P('  BCR (direct revenue only):        %.3f\n', w["bcr_direct"])
    P('  BCR (direct + REO extern):        %.3f\n', w["bcr_reo_only"])
    P('  BCR (all externalities):          %.3f\n', w["bcr_total"])
    P('\n')
    if w["bcr_total"] >= 1:
        P('  ✓ BCR > 1 with externalities — programme is economically justified.\n')
    else:
        P('  BCR < 1 within 200-yr window. At steady state (Y180+), annual BCR = %.2f.\n', rt[-1] / ct[-1])
        first = np.flatnonzero(rt > ct)
        P('  Programme achieves BCR > 1 annually from Y%d onward.\n', Y[first[0]] if first.size else np.zeros(0))

    P('\n--- INTERNAL RATE OF RETURN ---\n')
    # R2025a fzero prints this notice and returns NaN instead of throwing, so
    # the script's catch branches are never taken (golden: "NaN%").
    fzero_notice = ('Exiting fzero: aborting search for an interval containing a sign change\n'
                    '    because no sign change is detected during search.\n'
                    'Function may not have a root.\n')
    if math.isnan(w["irr_direct"]):
        P(fzero_notice)
    P('  IRR (direct revenue only):  %.2f%%\n', w["irr_direct"] * 100)
    if math.isnan(w["irr_total"]):
        P(fzero_notice)
    P('  IRR (all externalities):    %.2f%%\n', w["irr_total"] * 100)
    if math.isnan(w["dr_breakeven"]):
        P(fzero_notice)
    P('  Discount rate for BCR=1:    %.2f%%\n', w["dr_breakeven"] * 100)

    P('\n--- COMPREHENSIVE SENSITIVITY ANALYSIS ---\n')
    sens_lo = w["sens_lo"]; sens_hi = w["sens_hi"]; n_sens = int(w["n_sens"])
    P('\n%-40s %10s %10s %10s\n', 'Parameter', 'Low $T', 'High $T', 'Range $T')
    P('%-40s %10s %10s %10s\n', '---------', '------', '-------', '--------')
    order = np.argsort(-np.abs(sens_hi - sens_lo), kind="stable")
    for j in order[:n_sens]:
        P('%-40s %+10.3f %+10.3f %10.3f\n', _SENS_NAMES[j], sens_lo[j], sens_hi[j], abs(sens_hi[j] - sens_lo[j]))

    circuit = w["circuit"]; hauler = w["hauler"]; msr = w["msr"]; molei = w["molei"]; can = w["can"]; probe = w["probe"]
    P('\n████████████████████████████████████████████████\n')
    P('  MODEL METHODOLOGY\n')
    P('████████████████████████████████████████████████\n\n')
    P('INFRASTRUCTURE DERIVATION (bottom-up):\n')
    P('  REO target (exogenous, programme plan)\n')
    P('  → Circuits needed = ceil(REO / %.1f t/yr per circuit)\n', circuit["reo_yr"])
    P('  → Regolith throughput = REO / 500 ppm\n')
    P('  → Haulers needed = regolith × (1 - Tier3 frac) / %d t/yr per hauler\n', hauler["throughput_yr"])
    P('  → Conveyor km = regolith × Tier3 frac / 20,000 t/yr per km\n')
    P('  → Power (kW) = circuits × %d kW each\n', circuit["power_kw"])
    P('  → MSR count = power / %d MWe per MSR (from P9+)\n', msr["power_mw"])
    P('  → MOLE-I = propellant demand / %d kg/yr per unit\n', molei["propellant_yr"])
    P('  → Canisters/yr = REO / %.1f t per canister (from P9+)\n', can["reo_payload_t"])
    P('\n')
    P('EARTH CARGO DERIVATION:\n')
    P('  For each infrastructure type:\n')
    P('    New-build cargo = delta(fleet) × unit mass × Earth fraction\n')
    P('    Maintenance cargo = fleet × unit mass × maint rate × Earth fraction\n')
    P('  Earth fractions decline over time:\n')
    P('    Circuits: 100%% (P8) → 10%% (P10+) → 3%% (C-type, Y105) → 0.8%% (S-type, Y125)\n')
    P('    Haulers: 100%% (P8) → 43%% (P10+) → 33%% (M-type Fe-Ni, Y90) → 20%% floor\n')
    P('    MSR: 100%% (Hastelloy-N) → 30%% (Ni-201 in-situ, Y80+)\n')
    P('    Conveyors: 5%% constant (drive electronics + bearings)\n')
    P('\n')
    P('COST MODEL:\n')
    P('  Earth launch: cargo × launch cost × contingency\n')
    P('    Launch cost: $6,000/kg (P0-P7), $4,000 (P8-P9), $2,000 (P10+)\n')
    P('    Contingency: 50%% (P0-P7), 35%% (P8-P9), 25%% (P10+)\n')
    P('  In-situ fabrication: insitu mass × $100/kg\n')
    P('  Mk III PROBEs: LEO launch only at $500/kg × contingency\n')
    P('  Redirect tugs: LEO launch only at $500/kg × contingency\n')
    P('  Asteroid processing: $500M/yr (C-type) + $800M/yr (S-type)\n')
    P('  R&D: $500M-$2,000M/yr scaling with programme maturity\n')
    P('\n')
    P('REVENUE MODEL:\n')
    P('  REO sales: production × basket price\n')
    P('    Basket: $15,000/t (2026), declining to $5,000/t floor at market saturation\n')
    P('    Price model: max($5,000, $15,000 × (1 - 0.6 × supply fraction))\n')
    P('  PGM sales: (Mk I/II + Mk III + captured asteroid) × $50,000/kg\n')
    P('    Mk I/II: %d fleet × %.4f t/mission × 1 mission/yr\n', w["probe_fleet"][-1], probe["pgm_per_mission"])
    P('    Mk III: %d fleet × %.4f t/mission × 0.5 missions/yr\n', _mround(w["mkiii_active"][-1]), probe["pgm_per_mission"])
    P('    Captured: 36.5 t/yr from single M-type asteroid (Y85+)\n')
    P('\n')
    P('ENVIRONMENTAL EXTERNALITIES:\n')
    P('  1. REO mining displacement: $73,700/t REO\n')
    P('     Source: Lee & Wen (2018) EEIO + EPA SCC $190/tCO2\n')
    P('     CO2 component: 30 t CO2-eq/t REO lifecycle\n')
    P('  2. H2 enabling via Ir: 50%% marginal attribution\n')
    P('     Chain: Ir → PEM (1 GW/t, 20-yr life) → H2 → CO2 avoided\n')
    P('     Multiplier: 12 t CO2/t H2 (energy + green steel + ammonia)\n')
    P('     SCC: $190/t CO2 (EPA Nov 2023)\n')
    P('  3. Geopolitical insurance: $15B/yr at 50%%+ supply displacement\n')
    P('     Ref: China 85-90%% REE control, 2010-11 14× price spike, EU gas crisis >€1T\n')
    P('  4. Rocket emissions (negative): tanker ratio 14→8→5, fossil frac 100%%→5%%\n')
    P('     CO2: 2,750 t/launch, declining with DAC methane ramp\n')
    P('\n')
    P('DISCOUNT RATE:\n')
    P('  Declining: 3.0%% (Y0-30), 2.5%% (Y31-75), 2.0%% (Y76+)\n')
    P('  Ref: Arrow, Cropper, Gollier et al. (2014) REE&P 8(2):145-163\n')
    P('  Justification: intergenerational public good, δ ≈ 0, Ramsey equation\n')
    P('\n')
    P('PROGRAMME ARCHITECTURE:\n')
    P('  SPA (Shackleton): Asteroid processing hub (M/C/S-type), crew base, PROBE ops\n')
    P('  PKT (Procellarum): KREEP REO processing ONLY — every km² is ore\n')
    P('  3 mass drivers baseline + 1 conditional (SPA→PKT, PKT→Earth, PKT→SPA, SPA→Earth)\n')
    P('  + 1 DRO→SPA mass driver for captured asteroid concentrate\n')
    P('  Diversified asteroids: M-type (Y75), C-type (Y95), S-type (Y115)\n')
    P('  PROBE Mk I/II → III transition: chemical→ion, landing→orbital\n')
    P('\n')
    P('████████████████████████████████████████████████\n')
    P('  v1.4 ANALYSIS COMPLETE\n')
    P('  BCR (full): %.3f | IRR (full): ', w["bcr_total"])
    if not math.isnan(w["irr_total"]):
        P('%.2f%%', w["irr_total"] * 100)
    else:
        P('N/A')
    P('\n')
    P('  Baseline NPV: $%.2fT | SS net: $%.1fB/yr\n', w["baseline_npv"], (rt[-1] - ct[-1]) / 1e3)
    P('████████████████████████████████████████████████\n')
    return c.text()


# ---------------------------------------------------------------------------
# scaling_v1_3.m
# ---------------------------------------------------------------------------
def scaling_v1_3(ws=None) -> str:
    from .historical import scale_v1_3
    w = ws or scale_v1_3.workspace()
    c = _Console(); P = c.p
    ph = w["ph"]; skip = w["skip"]; hauler = w["hauler"]; mi = w["mi"]; ice = w["ice"]; shack = w["shack"]
    probe_big = w["probe_big"]; pgm = w["pgm"]; n = int(ph["n"])
    P('════════════════════════════════════════════════════════════════════════\n')
    P('  SELENITE SCALE v1.3 — 100-Year Dual-Base Scaling Analysis\n')
    P('  Surface Haulers at PKT | PROBE PGM Scaling | Deep Ice Mining\n')
    P('  Target: 1 Mt/yr REO + PGM to meet 2100 projected demand\n')
    P('════════════════════════════════════════════════════════════════════════\n\n')
    P('== KEY PARAMETERS ==\n')
    P('  SKIP SPA: dV=%.0f m/s, fuel=%.0f kg/hop\n', skip["dv_spa"], skip["fuel_spa"])
    P('  SKIP PKT: dV=%.0f m/s, fuel=%.0f kg/hop (P7-P9 only)\n', skip["dv_pkt"], skip["fuel_pkt"])
    P('  Hauler: %d kg payload, %.0f t/yr throughput, %d kW\n', hauler["payload"], hauler["throughput"], hauler["pwr_kW"])
    P('  MOLE-I: %.0f kg prop/yr | Ice depth: %dm (strip mining)\n', mi["prop_yield"], ice["depth_m"])
    P('  Shackleton ice: %.2e kg total, %.2e kg/yr sustainable\n', shack["ice_total"], shack["ice_yr"])
    P('  Probe big (P9+): %d kg payload, %dx in-situ concentration\n\n', probe_big["payload"], probe_big["insitu_conc"])

    P('== TARGETS ==\n')
    P('  %-12s %14s %10s\n', 'Phase', 'REO t/yr', 'PGM t/yr')
    for i in range(n):
        P('  %-12s %14.1f %10.0f\n', ph["lab"][i], ph["reo_target"][i], pgm["demand"][i] * 1000)
    P('\n')

    f0 = lambda x: _mf('%.0f', x)  # noqa: E731
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  KREEP CHAIN: REO Target → Raw Ore → Transport → Processing\n')
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %11s %12s %14s %6s %8s %20s %8s\n', 'Phase', 'REO t/yr', 'Conc t/yr', 'Raw t/yr', 'SKIPs', 'Haulers', 'Transport', 'Circuits')
    P('  %s\n', '-' * 105)
    for i in range(n):
        P('  %-12s %11.1f %12s %14s %6d %8s %20s %8d\n', ph["lab"][i], ph["reo_target"][i], f0(ph["concentrate"][i]),
          f0(ph["raw_kreep"][i]), ph["skip_total"][i], f0(ph["n_haulers"][i]), ph["xfer_method"][i], ph["proc_total"][i])

    P('\n══════════════════════════════════════════════════════════════════════\n')
    P('  PGM FROM ASTEROIDS (PROBE Fleet)\n')
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %6s %16s %10s %12s %10s\n', 'Phase', 'Probes', 'Type', 'PGM t/yr', 'Prop t/yr', 'Demand t/yr')
    P('  %s\n', '-' * 75)
    for i in range(n):
        P('  %-12s %6d %16s %10.1f %12s %10.0f\n', ph["lab"][i], ph["n_probe"][i], ph["probe_type"][i],
          ph["pgm_output"][i], f0(ph["prop_probe"][i]), pgm["demand"][i] * 1000)

    P('\n══════════════════════════════════════════════════════════════════════\n')
    P('  SPA PROPELLANT (t/yr) — includes Earth transit fuel\n')
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %8s %8s %10s %6s %8s %6s | %12s %12s\n', 'Phase', 'Sk_SPA', 'PROBE', 'Transfer', 'LS', 'SS_ret', 'Crew', 'TOTAL', 'ISRU_sup')
    P('  %s\n', '-' * 100)
    for i in range(n):
        st = 'OK' if ph["margin"][i] >= 0 else 'FAIL'
        P('  %-12s %8.0f %8.0f %10s %6.1f %8.0f %6.0f | %12s %12s %s\n', ph["lab"][i], ph["prop_skip_spa"][i],
          ph["prop_probe"][i], f0(ph["xfer_cost"][i]), ph["prop_ls"][i], ph["prop_ss_return"][i],
          ph["prop_crew_return"][i], f0(ph["prop_total"][i]), f0(ph["isru_supply"][i]), st)

    P('\n══════════════════════════════════════════════════════════════════════\n')
    P('  ISRU + ICE MINING (Shackleton)\n')
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %10s %8s %6s %12s %12s %12s %6s\n', 'Phase', 'MOLE-I', 'Nodes', 'PEM', 'Elec kW', 'Cryo kW', 'SPA Total kW', 'Ice#')
    P('  %s\n', '-' * 90)
    for i in range(n):
        P('  %-12s %10s %8s %6d %12s %12s %12s %6d\n', ph["lab"][i], f0(ph["n_molei"][i]), f0(ph["n_nodes"][i]),
          ph["n_pem"][i], f0(ph["pwr_elec"][i]), f0(ph["pwr_cryo"][i]), f0(ph["pwr_spa"][i]), ph["ice_sites"][i])

    P('\n══════════════════════════════════════════════════════════════════════\n')
    P('  PKT AUTONOMOUS BASE\n')
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %10s %8s %8s %6s %12s %8s %10s\n', 'Phase', 'Haulers', 'Catapults', 'Canistrs', 'Bene', 'PKT kW', 'FSP', 'Fab t/yr')
    P('  %s\n', '-' * 95)
    for i in range(n):
        P('  %-12s %10s %8d %8s %6d %12s %8d %10s\n', ph["lab"][i], f0(ph["n_haulers"][i]), ph["n_catapults"][i],
          f0(ph["n_canisters"][i]), ph["bene_total"][i], f0(ph["pwr_pkt"][i]), ph["fsp_pkt"][i], f0(ph["hauler_prod_yr"][i]))

    P('\n══════════════════════════════════════════════════════════════════════\n')
    P('  EARTH LOGISTICS\n')
    P('══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %8s %8s %10s %8s %12s\n', 'Phase', 'SS_crew', 'SS_REO', 'SS_reagent', 'SS_PGM', 'MD_Earth')
    P('  %s\n', '-' * 60)
    for i in range(n):
        P('  %-12s %8d %8d %10d %8d %12s\n', ph["lab"][i], ph["ss_crew"][i], ph["ss_reo_return"][i], ph["ss_reagent"][i],
          ph["ss_pgm"][i], f0(ph["md_earth"][i]))

    P('\n═══════════════════════════════════════════════════════════════════════\n')
    P('  PHASE-BY-PHASE SUMMARY\n')
    P('═══════════════════════════════════════════════════════════════════════\n\n')
    for i in range(n):
        P('─── %s ──────────────────────────────────────\n', ph["lab"][i])
        P('  REO:      %14.1f t/yr | PGM:    %10.1f t/yr\n', ph["reo_target"][i], ph["pgm_output"][i])
        P('  Raw KREEP:%14s t/yr | Transport: %s\n', f0(ph["raw_kreep"][i]), ph["xfer_method"][i])
        P('  SKIPs:    %6d SPA + %8d PKT | Haulers: %s | Catapults: %d | Canisters: %s\n',
          ph["skip_spa"][i], ph["skip_pkt"][i], f0(ph["n_haulers"][i]), ph["n_catapults"][i], f0(ph["n_canisters"][i]))
        P('  PROBEs:   %6d (%s)\n', ph["n_probe"][i], ph["probe_type"][i])
        P('  Proc:     %6d SPA + %8d PKT = %8d total\n', ph["proc_spa"][i], ph["proc_pkt"][i], ph["proc_total"][i])
        P('  Crew:     %6d (SPA only, PKT autonomous)\n', ph["crew"][i])
        P('  MOLE-I:   %10s (%s nodes, %d ice sites)\n', f0(ph["n_molei"][i]), f0(ph["n_nodes"][i]), ph["ice_sites"][i])
        if ph["hauler_prod_yr"][i] > 0:
            P('  Fab:      %10s haulers/yr in-situ | %s t/yr Fe-Ni | %s t/yr Al | %s t/yr from Earth\n',
              f0(ph["hauler_prod_yr"][i]), f0(ph["feni_need"][i]), f0(ph["al_need"][i]), f0(ph["fab_earth_mass"][i]))
        P('  Prop SPA: %14s t/yr | ISRU margin: %+.0f t/yr\n', f0(ph["prop_total"][i]), ph["margin"][i])
        P('  Power:    %12s kW SPA | %12s kW PKT\n', f0(ph["pwr_spa"][i]), f0(ph["pwr_pkt"][i]))
        P('  FSP:      %6d SPA + %8d PKT = %8d total\n', ph["fsp_spa"][i], ph["fsp_pkt"][i], ph["fsp_spa"][i] + ph["fsp_pkt"][i])
        P('  Earth:    %6d SS + %8s mass driver launches/yr\n', ph["ss_total"][i], f0(ph["md_earth"][i]))
        P('\n')

    earth_ree = w["earth_ree"]
    P('═══════════════════════════════════════════════════════════════════════\n')
    P('  GLOBAL DEMAND vs SELENITE SUPPLY\n')
    P('═══════════════════════════════════════════════════════════════════════\n')
    P('  %-12s %12s %12s %8s | %10s %10s\n', 'Phase', 'Sel REO', 'Earth REO', 'REO %%', 'Sel PGM', 'PGM Demand')
    P('  %s\n', '-' * 75)
    for i in range(n):
        P('  %-12s %12s %12s %7.3f%% | %10.1f %10.0f\n', ph["lab"][i], f0(ph["reo_target"][i]), f0(earth_ree[i]),
          ph["reo_target"][i] / earth_ree[i] * 100, ph["pgm_output"][i], pgm["demand"][i] * 1000)
    P('\n  Fe/Ni POSITION: NOT for Earth return. In-space structural use only.\n')
    P('  Earth Fe demand ~5 Bt/yr by 2100 — met by terrestrial green steel.\n')
    P('  Programme Fe-Ni use: PKT foundry feedstock for haulers, canisters,\n')
    P('  hub structures. Source: PROBE asteroid returns + local ilmenite.\n')
    P('  P12 Fe-Ni demand for fabrication: %s t/yr\n', f0(ph["feni_need"][n - 1]))
    P('  This is %% of PROBE Ni-Fe return, validating in-space use case.\n')

    P('\n═══════════════════════════════════════════════════════════════════════\n')
    P('  v1.2 → v1.3 COMPARISON: Key Changes\n')
    P('═══════════════════════════════════════════════════════════════════════\n')
    P('  v1.2 P12 catapults: 5 (underestimated)\n')
    P('  v1.3 P12 catapults: %d (tier-fraction model, frontier expansion)\n', ph["n_catapults"][n - 1])
    P('  v1.3 P12 canisters in fleet: %s\n', f0(ph["n_canisters"][n - 1]))
    P('  v1.3 P12 hauler production: %s/yr (92%% in-situ manufactured)\n', f0(ph["hauler_prod_yr"][n - 1]))
    P('  v1.3 P12 Earth-supplied mass for fab: %s t/yr (electronics+batteries only)\n', f0(ph["fab_earth_mass"][n - 1]))
    P('  v1.3 P12 Fe-Ni feedstock for fab: %s t/yr (from PROBE + ilmenite)\n', f0(ph["feni_need"][n - 1]))
    P('  v1.3 P12 Al feedstock for fab: %s t/yr (from KREEP gangue)\n', f0(ph["al_need"][n - 1]))
    P('  v1.3 Bidirectional catapult: 4 tracks per hub pair (loaded out, empties back)\n')
    P('  v1.3 Fe/Ni: in-space use only, NOT Earth return\n')

    P('\n═══════════════════════════════════════════════════════════════════════\n')
    P('  ANALYSIS COMPLETE — v1.3\n')
    P('  KEY: Surface haulers + in-situ fabrication + bidirectional catapults\n')
    P('  Ice demand reduced by >99%% vs v1.1\n')
    # Source defect (scaling_v1_3.m line 584): the unescaped "92% hauler ..." is
    # parsed by MATLAB as a "% h" conversion, so the line is truncated here.
    P('  In-situ fab: 92% hauler mass manufactured at PKT from Fe-Ni + Al gangue\n')
    P('═══════════════════════════════════════════════════════════════════════\n')

    P('\n═══════════════════════════════════════════════════════════════════════\n')
    P('  DESIGN EVOLUTION FLAGS (future spec documents)\n')
    P('═══════════════════════════════════════════════════════════════════════\n')
    P('  PROBE Mk II (P9+): Larger vehicle, 10-50t payload class.\n')
    P('    In-situ beneficiation on asteroid (magnetic separation in micro-g).\n')
    P('    Returns PGM concentrate only, not raw ore. 50x mass reduction.\n')
    P('    Required for PGM scaling beyond 5 t/yr.\n')
    P('    Full 2100 PGM demand (8,000 t/yr) requires orbital processing\n')
    P('    platforms + asteroid capture/redirect — P13+ infrastructure.\n\n')
    P('  MOLE-I Mk II (P8+): Extended drill for deep ice (10m+ strip mining).\n')
    P('    Retractable drill assembly (must fully retract for transit).\n')
    P('    Options: (a) Mk II new-build with telescoping drill, or\n')
    P('    (b) Mk I retrofit: replace drill module at existing substations.\n')
    P('    Design consideration: drill retraction clearance vs chassis height.\n')
    P('    If retrofit: drill module is an ORU — ARM swaps at substation.\n\n')
    P('  Surface Hauler (P10+ PKT): New vehicle class, no current spec.\n')
    P('    5 t payload, electric drive, 1 m/s on sintered road.\n')
    P('    Autonomous (SENTINEL-supervised from SPA Ops Hub).\n')
    P('    Charged at hub stations (FSP-powered). ~5 kW average.\n')
    P('    Spec document needed: SEL-HAULER-001 Rev A.\n\n')
    P('  EM Catapult Hub (P11+): Regional ore launch facility.\n')
    P('    500m track, SINTER-built bed, ARM-installed coils.\n')
    P('    500 m/s launch for 5t canisters. ~5 MW pulsed.\n')
    P('    Spec document needed: SEL-CATAPULT-001 Rev A.\n')
    P('═══════════════════════════════════════════════════════════════════════\n')
    return c.text()


# ---------------------------------------------------------------------------
# SELENITE_VISUALIZE_v3_3.m
# ---------------------------------------------------------------------------
def visualize_v3_3(ws=None) -> str:
    from . import psr_layout
    w = ws or psr_layout.workspace()
    c = _Console(); P = c.p
    node = w["node"]; spine = w["spine"]; crater = w["crater"]; phase = w["phase"]
    junctions = w["junctions"]; branch_info = w["branch_info"]; all_nodes = w["all_nodes"]; n_total = int(w["n_total"])
    P('════════════════════════════════════════════════════════════════\n')
    P('  SELENITE — Bilateral Fishbone Layout v3\n')
    P('════════════════════════════════════════════════════════════════\n\n')
    P('  Spine: %.0f m to %.0f m from crater centre (%.0f m total)\n',
      abs(junctions[0, 0]), abs(junctions[-1, 0]), junctions[-1, 0] - junctions[0, 0])
    P('  Junctions: %d at %d m spacing\n', junctions.shape[0], spine["junction_spacing"])
    P('\n  Nodes placed: %d\n', n_total)
    P('\n  JUNCTION BREAKDOWN:\n')
    P('  %5s  %6s  %6s  %8s  %8s\n', 'Jct', 'X(m)', 'Left', 'Right', 'Total')
    P('  %s\n', '-' * 40)
    for j in range(1, junctions.shape[0] + 1):
        left = np.sum(branch_info[(branch_info[:, 0] == j) & (branch_info[:, 1] == 1), 2])
        right = np.sum(branch_info[(branch_info[:, 0] == j) & (branch_info[:, 1] == -1), 2])
        P('  %5d  %6.0f  %6d  %8d  %8d\n', j, junctions[j - 1, 0], left, right, left + right)
    P('  %s\n', '-' * 40)
    P('  %5s  %6s  %6d  %8d  %8d\n', 'TOTAL', '', np.sum(branch_info[branch_info[:, 1] == 1, 2]),
      np.sum(branch_info[branch_info[:, 1] == -1, 2]), n_total)
    P('\n  PHASE COVERAGE:\n')
    for p in range(1, len(phase["target"]) + 1):
        n_in_phase = np.sum(all_nodes[:, 5] <= p)
        status = 'SHORT' if n_in_phase < phase["target"][p - 1] else 'OK'
        P('    %s: target %d, placed %d [%s]\n', phase["labels"][p - 1], phase["target"][p - 1], n_in_phase, status)
    P('\n  CLEARANCE CHECKS:\n')
    P('    Node-to-node:    %.0f m (min %d) [%s]\n', w["min_nn"], node["min_sep"],
      _tern(w["min_nn"] >= node["min_sep"] - 10, 'PASS', 'FAIL'))
    P('    Tether-to-spine: %.0f m (min %d) [%s]\n', w["min_spine"], node["buffer"],
      _tern(w["min_spine"] >= node["buffer"] - 5, 'PASS', 'FAIL'))
    P('    Tether-to-adj-branch: %.0f m (min %d) [%s]\n', w["min_branch"], node["buffer"],
      _tern(w["min_branch"] >= node["buffer"] - 5, 'PASS', 'FAIL'))
    P('    Floor utilisation: %.1f%%\n', w["util_pct"])
    P('    Furthest from centre: %.0f m (crater wall at %d m)\n', w["max_dist"], crater["floor_r"])
    P('    Furthest from CLP:    %.0f m\n', w["max_clp"])
    spine_len = w["spine_len"]; branch_total = w["branch_total"]
    P('    Spine cable:  %.1f km\n', spine_len / 1000)
    P('    Branch cable: %.1f km total\n', branch_total / 1000)
    P('    All cable:    %.1f km (× 2 for dual-path: %.1f km)\n', (spine_len + branch_total) / 1000, 2 * (spine_len + branch_total) / 1000)
    P('\n════════════════════════════════════════════════════════════════\n')
    P('  BILATERAL FISHBONE LAYOUT v3 SUMMARY\n')
    P('════════════════════════════════════════════════════════════════\n')
    P('  Topology:        Bilateral fishbone from CLP\n')
    P('  Spine:           %.1f km (CLP to last junction)\n', spine_len / 1000)
    P('  Junctions:       %d at %d m spacing\n', junctions.shape[0], spine["junction_spacing"])
    P('  Branches:        %d (bilateral from each junction)\n', branch_info.shape[0])
    P('  Nodes/branch:    %s (varies with crater wall proximity)\n', ','.join(_mf('%d', x) for x in branch_info[:, 2]))
    P('  Total nodes:     %d (P7+ target: %d, P8+ target: %d)\n', n_total, phase["target"][4], phase["target"][5])
    P('  Min node-node:   %.0f m [%s]\n', w["min_nn"], _tern(w["min_nn"] >= node["min_sep"] - 10, 'PASS', 'FAIL'))
    P('  Min to spine:    %.0f m [%s]\n', w["min_spine"], _tern(w["min_spine"] >= node["buffer"] - 5, 'PASS', 'FAIL'))
    P('  Floor used:      %.1f%%\n', w["util_pct"])
    P('  Cable total:     %.1f km (%.1f km dual-path)\n', (spine_len + branch_total) / 1000, 2 * (spine_len + branch_total) / 1000)
    P('\n  ADVANTAGES:\n')
    P('    + Dense packing (all nodes within ~%.0f m of CLP)\n', w["max_clp"])
    P('    + Trunk cable NEVER crosses any work zone\n')
    P('    + Scales to %d+ nodes without wall collision\n', n_total)
    P('    + Bilateral branches: both sides of every junction used\n')
    P('    + Simple cable management: spine + perpendicular branches\n')
    P('    + Phase deployment: grow spine → activate next junction pair\n')
    P('════════════════════════════════════════════════════════════════\n')
    return c.text()


CONSOLE = {
    "sabatier": sabatier,
    "SELENITE_VERIFY_v5_0": verify_v5_0,
    "MOLEI_THERMAL_v1_3": thermal_v1_3,
    "SELENITE_ECON_V1_3": econ_v1_3,
    "SELENITE_ECON_V1_4": econ_v1_4,
    "scaling_v1_3": scaling_v1_3,
    "SELENITE_VISUALIZE_v3_3": visualize_v3_3,
}


def console(script: str, **kw) -> str:
    """The console text ``script`` printed, regenerated from the port."""
    return CONSOLE[script](**kw)


def main(argv=None):
    import sys
    names = argv if argv else list(CONSOLE)
    for name in names:
        sys.stdout.write(console(name))
        sys.stdout.write("\n")


if __name__ == "__main__":
    import sys
    main(sys.argv[1:])
