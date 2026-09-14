"""Port of ``sabatier.m`` (the working copy of SELENITE_AUDIT_RESOLVE): ECLSS
Sabatier / OGA / greenhouse CO2 and water balance (scenarios A, B, C), the
mezzanine chord geometry (Q4), LH2 sphere volumes (Q15), electrolysis power
(Q19) and Starship module loading (Q2).

Oracle: ``sabatier.csv`` (107 rows). Every local variable of the script is
reproduced under the same name; ``run()`` returns the flattened workspace.
"""
from __future__ import annotations

import math

import numpy as np

from . import constants as C
from .capture import flatten, mceil

PORTED = True
SOURCE_SCRIPT = "sabatier.m"


def run(**params):
    # ---- Q8/Q9/Q10/Q12: ECLSS Sabatier + CO2 + water balance ---------------
    n_crew = 4
    CO2_per_CM = C.CO2_PER_CM
    O2_per_CM = C.O2_PER_CM
    H2O_per_CM = C.H2O_PER_CM
    H2O_recoverable_per_CM = C.H2O_RECOVERABLE_PER_CM
    WRS_recovery = C.WRS_RECOVERY

    M_CO2 = C.M_CO2
    M_H2 = C.M_H2
    M_CH4 = C.M_CH4
    M_H2O = C.M_H2O
    M_O2 = C.M_O2

    CO2_crew = n_crew * CO2_per_CM
    O2_crew = n_crew * O2_per_CM
    H2O_crew = n_crew * H2O_per_CM

    GH_CO2_low = C.GH_CO2_LOW
    GH_CO2_high = C.GH_CO2_HIGH
    GH_CO2_nom = C.GH_CO2_NOM
    GH_O2_nom = C.GH_O2_NOM

    # Scenario A: OGA sized to crew O2 demand
    O2_OGA_A = O2_crew + 0.5
    H2O_OGA_A = O2_OGA_A / (M_O2 / M_H2O)
    H2_OGA_A = O2_OGA_A * (2 * M_H2) / (M_O2)
    H2O_consumed_OGA_A = O2_OGA_A * (2 * M_H2O) / (M_O2)

    mol_H2_A = H2_OGA_A * 1000 / M_H2
    mol_CO2_A = mol_H2_A / 4
    CO2_sab_A = mol_CO2_A * M_CO2 / 1000
    CH4_sab_A = mol_CO2_A * M_CH4 / 1000
    H2O_sab_A = mol_CO2_A * 2 * M_H2O / 1000

    CO2_remaining_A = CO2_crew - CO2_sab_A
    O2_surplus_A = O2_OGA_A - O2_crew + GH_O2_nom

    WRS_recovered = n_crew * H2O_recoverable_per_CM * WRS_recovery
    H2O_balance_A = H2O_crew - WRS_recovered - H2O_sab_A + H2O_consumed_OGA_A

    P_OGA_A = H2O_consumed_OGA_A * 52.5 / 24   # overwritten next line, as in the source
    P_OGA_A = H2_OGA_A * C.OGA_KWH_PER_KG_H2 / 24

    # Scenario B: OGA at 0.73 kg H2/day (original spec)
    H2_OGA_B = 0.73
    mol_H2_B = H2_OGA_B * 1000 / M_H2
    O2_OGA_B = mol_H2_B / 2 * M_O2 / 1000
    H2O_consumed_OGA_B = mol_H2_B * M_H2O / 1000

    mol_CO2_B = mol_H2_B / 4
    CO2_sab_B = mol_CO2_B * M_CO2 / 1000
    CH4_sab_B = mol_CO2_B * M_CH4 / 1000
    H2O_sab_B = mol_CO2_B * 2 * M_H2O / 1000

    CO2_remaining_B = CO2_crew - CO2_sab_B
    O2_surplus_B = O2_OGA_B - O2_crew + GH_O2_nom
    H2O_balance_B = H2O_crew - WRS_recovered - H2O_sab_B + H2O_consumed_OGA_B
    P_OGA_B = H2_OGA_B * C.OGA_KWH_PER_KG_H2 / 24

    # Scenario C: balanced (Sabatier + greenhouse consume all crew CO2)
    H2_OGA_C = (CO2_crew - GH_CO2_nom) / (M_CO2 / (4 * M_H2))
    mol_H2_C = H2_OGA_C * 1000 / M_H2
    O2_OGA_C = mol_H2_C / 2 * M_O2 / 1000
    H2O_consumed_OGA_C = mol_H2_C * M_H2O / 1000

    mol_CO2_C = mol_H2_C / 4
    CO2_sab_C = mol_CO2_C * M_CO2 / 1000
    CH4_sab_C = mol_CO2_C * M_CH4 / 1000
    H2O_sab_C = mol_CO2_C * 2 * M_H2O / 1000
    CO2_remaining_C = CO2_crew - CO2_sab_C

    O2_surplus_C = O2_OGA_C - O2_crew + GH_O2_nom
    H2O_balance_C = H2O_crew - WRS_recovered - H2O_sab_C + H2O_consumed_OGA_C
    P_OGA_C = H2_OGA_C * C.OGA_KWH_PER_KG_H2 / 24

    # ---- Q4: mezzanine chord width ----------------------------------------
    R_inner = 4200 / 2
    y_floor = -R_inner + 400
    y_mezz = y_floor + 2200

    chord_floor = 2 * math.sqrt(R_inner**2 - y_floor**2)
    chord_mezz = 2 * math.sqrt(R_inner**2 - y_mezz**2)

    y_2920 = math.sqrt(R_inner**2 - (2920 / 2) ** 2)
    h_2920 = y_2920 - y_floor

    ceiling_y = R_inner
    headroom_above_mezz = ceiling_y - y_mezz
    headroom_below_mezz = y_mezz - y_floor

    y_berth_head = y_mezz + 1000
    if y_berth_head < R_inner:
        chord_berth = 2 * math.sqrt(R_inner**2 - y_berth_head**2)

    # ---- Q15: LH2 sphere volumes ------------------------------------------
    d_sphere = 5.0
    V_sphere = (4 / 3) * math.pi * (d_sphere / 2) ** 3

    V_target = 175 / 2
    d_needed = 2 * (3 * V_target / (4 * math.pi)) ** (1 / 3)

    rho_LH2 = C.RHO_LH2
    LH2_30day = C.PROPELLANT_P7_KG_YR / 365 * 30 * (1 / 7)
    LH2_DART = 15000 * (1 / 7)
    LH2_total = LH2_30day + LH2_DART
    V_needed = LH2_total / rho_LH2

    # ---- Q19: electrolysis power ------------------------------------------
    water_yr = C.PROPELLANT_P7_KG_YR
    water_per_MI = C.WATER_PER_MOLEI_KG_YR
    n_MI = 170
    total_water = water_per_MI * n_MI
    H2_total = total_water * (2 * M_H2) / (2 * M_H2O)
    O2_total = total_water * M_O2 / (2 * M_H2O)

    prop_from_H2 = H2_total * 7
    prop_from_O2 = O2_total * (7 / 6)
    usable_prop = min(prop_from_H2, prop_from_O2)

    kWh_per_kg_H2 = np.array([50, 52.5, 55, 57.5])
    H2_per_day = H2_total / 365

    for i in range(1, len(kWh_per_kg_H2) + 1):
        P_kW = H2_per_day * kWh_per_kg_H2[i - 1] / 24
        n_stacks = mceil(P_kW / 60.5)

    P_pipeline = 59.5
    P_electrolysis_new = H2_per_day * 52.5 / 24
    P_sublimation = 275
    P_LH2_liq = H2_total / 365 * 15 / 24
    P_LOX_liq = (H2_total * 6) / 365 * 1.0 / 24
    P_purification = 15
    P_other = 30
    P_ISRU_total = (P_pipeline + P_electrolysis_new + P_sublimation + P_LH2_liq
                    + P_LOX_liq + P_purification + P_other)

    # ---- Q2: Starship loading ---------------------------------------------
    D_fairing = 8.0
    D_module = 4.5
    L_module = 11.0
    L_fairing = 22.0

    D_enclosing = 2 * D_module
    H_stacked = 2 * L_module

    M_module_max = 23000
    M_starship_lunar = 50000

    return flatten(locals())
