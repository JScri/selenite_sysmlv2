"""Port of ``SELENITE_VERIFY_v5_0.m``: fleet sizing, fishbone pipeline, ECLSS
Scenario C, habitat power, normal and eclipse power budgets, ISRU, trunk
cable, material output, power infrastructure mass, failure analysis, and the
figure data arrays. Oracle: ``SELENITE_VERIFY_v5_0.csv`` (237 rows).

The script is one workspace with interleaved dependencies, so it is ported
as one ``run()``; ``power.py``, ``fleet.py`` and ``isru.py`` are typed views
over its result. Figure-only variables (``x``, colour vectors, ``pz``, ``ez``,
``yrs``...) are reproduced because the harness captured them.
"""
from __future__ import annotations

import math

import numpy as np

from .capture import flatten, mceil

PORTED = True
SOURCE_SCRIPT = "SELENITE_VERIFY_v5_0.m"


def run(**params):
    g0 = 9.81
    g_moon = 1.62
    Isp = 450
    ve = Isp * g0

    # ---- ENVIRONMENT -------------------------------------------------------
    crater = {}
    crater["traverse_km"] = 4.2 / 0.5            # sind(30) is exactly 0.5 in MATLAB
    crater["floor_dia_km"] = 6.5
    crater["floor_area"] = math.pi * (crater["floor_dia_km"] / 2) ** 2
    crater["ice_frac"] = 0.0446

    solar = {"illum": 0.85, "eff": 0.29, "irr": 1.361, "eol": 0.85, "dust": 0.95}
    solar["yield_kWm2"] = solar["irr"] * solar["eff"] * solar["illum"] * solar["dust"]
    fsp = {"pwr_kW": 40, "mass_kg": 6600}

    # ---- MOLE-I -------------------------------------------------------------
    mi = {"mass_dry": 360.35, "n_wheels": 6, "prop_yield": 5692}
    mi["water_rate"] = 25 * crater["ice_frac"]
    mi["water_yr"] = mi["water_rate"] * 0.80 * 8760
    mi["pwr"] = {"drive": 300, "drill": 200, "minivex": 1200, "web": 15, "comms": 20,
                 "gbx_htr": 30, "drill_htr": 15, "recept": 5, "vex_stby": 0}
    p = mi["pwr"]
    mi["pwr_op"] = (p["drive"] + p["drill"] + p["minivex"] + p["web"] + p["comms"]
                    + p["gbx_htr"] + p["drill_htr"] + p["recept"] + p["vex_stby"])
    mi["pwr_ka"] = p["web"] + p["gbx_htr"] + p["drill_htr"] + p["recept"]
    mi["dcdc"] = {"eff_48v": 0.95, "eff_28v": 0.93, "eff_5v": 0.90,
                  "load_48v": 1730, "load_28v": 90, "load_5v": 13}
    d = mi["dcdc"]
    d["loss_48v"] = d["load_48v"] * (1 / d["eff_48v"] - 1)
    d["loss_28v"] = d["load_28v"] * (1 / d["eff_28v"] - 1)
    d["loss_5v"] = d["load_5v"] * (1 / d["eff_5v"] - 1)
    d["loss_total"] = d["loss_48v"] + d["loss_28v"] + d["loss_5v"]
    mi["batt_charge"] = 50
    mi["pwr_tether"] = mi["pwr_op"] + d["loss_total"] + mi["batt_charge"]
    mi["descent_hr"] = (crater["traverse_km"] * 1000 / 0.5) / 3600
    mi["batt_Wh"] = mi["pwr_ka"] * mi["descent_hr"] * 1.10
    mi["batt_kg"] = mi["batt_Wh"] / 250
    del p, d

    # ---- SUBSTATION NODE -----------------------------------------------------
    node = {"units": 5, "web": 10.5, "drums": 5 * 8, "pump": 10, "riser": 21,
            "funnels": 3, "comms": 3, "controller": 5, "solenoids": 3}
    node["overhead"] = (node["web"] + node["drums"] + node["pump"] + node["riser"]
                        + node["funnels"] + node["comms"] + node["controller"] + node["solenoids"])
    node["lwrhu"] = 3
    node["lwrhu_mass"] = node["lwrhu"] * 0.042
    node["mass"] = 160
    node["angle_enc"] = 0.5
    node["overhead_v5"] = node["overhead"] + node["angle_enc"]

    # ---- PIPELINE ------------------------------------------------------------
    pipe = {"trunk_m": 8500, "q_ground": 7.0, "q_elev": 1.5, "pump_kW": 0.3}

    # ---- CAP -----------------------------------------------------------------
    cap = {"peak_kW": 5.0, "stby_kW": 1.0, "mass_loaded": 1360}

    # ---- FLEET CONSUMERS -----------------------------------------------------
    probe = {"prop": 6654}
    skip = {"mf": 700, "rng": 100}
    skip["v0"] = math.sqrt(skip["rng"] * 1000 * g_moon)
    skip["dv"] = 4 * skip["v0"] * 1.05
    skip["fuel_hop"] = skip["mf"] * (math.exp(skip["dv"] / ve) - 1)
    skip["hops"] = 274
    skip["fuel_yr"] = skip["hops"] * skip["fuel_hop"]
    skip["kreep_yr"] = skip["hops"] * 400
    dart = {"prop": 12370}
    ls = {"eff": 0.722}
    ls["prop_crew"] = 0.9 * 365 / 0.889 * ls["eff"]

    # ---- DEMAND-DRIVEN FLEET SIZING ---------------------------------------------
    ph = {"lab": ["P3", "P4", "P5", "P6", "P7+"],
          "nm": ["P3 Y4-7", "P4 Y7-9", "P5 Y9-12", "P6 Y12-15", "P7+ Y20+"],
          "n": 5, "dur": np.array([3, 2, 3, 3, 5.0])}
    ph["nP"] = np.array([3, 6, 10, 15, 30.0])
    ph["nS"] = np.array([0, 1, 2, 4, 8.0])
    ph["nD"] = np.array([0, 0, 1, 1, 1.0])
    ph["crew"] = np.array([0, 4, 4, 6, 12.0])

    ph["dP"] = ph["nP"] * probe["prop"]
    ph["dS"] = ph["nS"] * skip["fuel_yr"]
    ph["dD"] = np.array([0, 0, dart["prop"], 0, dart["prop"] / 2])
    ph["dL"] = ph["crew"] * ls["prop_crew"]
    ph["dT"] = ph["dP"] + ph["dS"] + ph["dD"] + ph["dL"]

    mf = 1.10
    ph["mi"] = np.zeros(ph["n"])
    ph["nd"] = np.zeros(ph["n"])
    for i in range(1, ph["n"] + 1):
        if ph["dT"][i - 1] > 0:
            raw = mceil(ph["dT"][i - 1] * mf / mi["prop_yield"])
        else:
            raw = 10
        ph["mi"][i - 1] = mceil(raw / node["units"]) * node["units"]
        ph["nd"][i - 1] = ph["mi"][i - 1] / node["units"]
    ph["isru"] = ph["mi"] * mi["prop_yield"]
    ph["margin"] = ph["isru"] - ph["dT"]

    stk = 0
    for i in range(1, ph["n"] + 1):
        stk = stk + ph["margin"][i - 1] * ph["dur"][i - 1]

    # ---- PIPELINE HEATING ------------------------------------------------------
    trunk_km = np.array([2.0, 4.0, 6.0, 8.0, 8.5])
    branch_km = ph["nd"] * 0.2
    spine_km = trunk_km * 0.15
    pipe["kW"] = trunk_km * pipe["q_ground"] + spine_km * pipe["q_ground"] + branch_km * pipe["q_elev"]
    pipe["pump"] = np.array([0, pipe["pump_kW"], pipe["pump_kW"], pipe["pump_kW"], pipe["pump_kW"]])
    pipe["total"] = pipe["kW"] + pipe["pump"]

    # ---- ECLSS SCENARIO C VERIFICATION -----------------------------------------
    M_CO2 = 44.01
    M_H2 = 2.016
    M_CH4 = 16.04
    M_H2O = 18.015
    M_O2 = 32.00
    H2_OGA = 0.431
    mol_H2 = H2_OGA * 1000 / M_H2
    CO2_sab = mol_H2 / 4 * M_CO2 / 1000
    CH4_sab = mol_H2 / 4 * M_CH4 / 1000
    H2O_sab = mol_H2 / 4 * 2 * M_H2O / 1000
    O2_OGA = mol_H2 / 2 * M_O2 / 1000
    H2O_OGA = mol_H2 * M_H2O / 1000
    CO2_crew = 4.0
    CO2_GH = 1.65
    O2_crew = 3.36
    H2O_crew = 20.0
    GH_O2 = 1.20
    WRS_out = 4 * 4.88 * 0.93
    H2O_deficit = H2O_crew - WRS_out - H2O_sab + H2O_OGA

    # ---- HABITAT POWER BREAKDOWN ------------------------------------------------
    hab = {"CDRA": 1000, "OGA": 940, "Sab": 350, "TCCS": 380, "CCAA": 500, "WRS": 500,
           "thermal": 200, "lighting": 500, "comms": 150, "other": 500, "conv_loss": 1000, "LED": 12000}
    hab["no_GH"] = (hab["CDRA"] + hab["OGA"] + hab["Sab"] + hab["TCCS"] + hab["CCAA"] + hab["WRS"]
                    + hab["thermal"] + hab["lighting"] + hab["comms"] + hab["other"] + hab["conv_loss"])
    hab["with_GH"] = hab["no_GH"] + hab["LED"]

    # ---- NORMAL POWER BUDGET ---------------------------------------------------
    V = 1000
    ph["wyr"] = ph["mi"] * mi["water_yr"]
    ph["whr"] = ph["wyr"] / 8760
    ph["p_fleet"] = ph["mi"] * mi["pwr_tether"] / 1000
    ph["p_nodes"] = ph["nd"] * node["overhead_v5"] / 1000
    ph["p_pipe"] = pipe["total"]
    ph["p_psr"] = ph["p_fleet"] + ph["p_nodes"] + ph["p_pipe"]

    kw_per_kghr = 5.5
    ph["p_elec"] = ph["whr"] * kw_per_kghr
    ph["h2hr"] = ph["whr"] * (2 * M_H2) / (2 * M_H2O)
    ph["o2hr"] = ph["whr"] * M_O2 / (2 * M_H2O)
    ph["p_lh2"] = ph["h2hr"] * 15
    ph["p_lox"] = ph["o2hr"] * 1.0
    ph["p_cryo"] = ph["p_lh2"] + ph["p_lox"]
    ph["p_vex"] = np.array([5, 15, 30, 40, 50.0])
    ph["p_isru_oth"] = np.array([5, 10, 12, 14, 15.0])
    ph["p_isru"] = ph["p_elec"] + ph["p_cryo"] + ph["p_vex"] + ph["p_isru_oth"]
    ph["nPEM"] = np.ceil(ph["p_elec"] / 50)

    ph["p_hab"] = np.array([0, hab["no_GH"] / 1000, hab["no_GH"] / 1000, hab["no_GH"] / 1000 + 2, hab["with_GH"] / 1000])
    ph["p_iz"] = np.array([5, 20, 40, 60, 108.0])
    ph["nMS"] = np.array([4, 4, 4, 6, 6.0])
    ph["nARMC"] = np.array([1, 1, 1, 1, 2.0])
    ph["nARMD"] = np.array([1, 2, 4, 6, 8.0])
    ph["nSEN"] = np.array([2, 2, 3, 4, 4.0])
    ph["p_robots"] = ph["nMS"] * 1.2 + ph["nARMC"] * 3.0 + ph["nSEN"] * 0.5
    ph["p_skippad"] = np.array([0, 0.5, 1, 2, 4])
    ph["p_dartzbo"] = np.array([0, 0, 2.5, 2.5, 2.5])
    ph["p_farmzbo"] = np.array([0, 4, 6, 8, 11.0])
    ph["p_cap"] = np.array([0, 0, 0, cap["stby_kW"], cap["stby_kW"]])
    ph["p_comms"] = np.array([0.2, 0.5, 0.5, 0.5, 0.5])
    ph["p_base"] = (ph["p_hab"] + ph["p_iz"] + ph["p_robots"] + ph["p_skippad"] + ph["p_dartzbo"]
                    + ph["p_farmzbo"] + ph["p_cap"] + ph["p_comms"])
    ph["p_sub"] = ph["p_psr"] + ph["p_isru"] + ph["p_base"]
    ph["p_cont"] = ph["p_sub"] * 0.20
    ph["p_tot"] = ph["p_sub"] + ph["p_cont"]
    ph["solar_cap"] = ph["p_tot"] / solar["illum"]
    ph["panel_m2"] = ph["p_tot"] / solar["yield_kWm2"]
    ph["panel_kg"] = ph["panel_m2"] * 3

    # ---- ECLIPSE POWER -----------------------------------------------------------
    eclipse_hr = 72
    ecl = {}
    ecl["mi"] = ph["mi"] * mi["pwr_ka"] / 1000
    ecl["nd"] = ph["nd"] * node["overhead_v5"] / 1000
    ecl["pipe"] = pipe["total"]
    ecl["hab"] = ph["p_hab"]
    ecl["sent"] = ph["nSEN"] * 0.5
    ecl["farmzbo"] = ph["p_farmzbo"]
    ecl["misc"] = np.array([0, 5, 5, 5, 5.0])
    ecl["tot"] = ecl["mi"] + ecl["nd"] + ecl["pipe"] + ecl["hab"] + ecl["sent"] + ecl["farmzbo"] + ecl["misc"]
    ecl["nfsp"] = np.array([1, 2, 3, 4, 5.0])
    ecl["fsp_kW"] = ecl["nfsp"] * fsp["pwr_kW"]

    batt_margin = 1.20
    batt_Whkg = 250
    ecl["bkWh"] = np.zeros(ph["n"])
    ecl["bt"] = np.zeros(ph["n"])
    for i in range(1, ph["n"] + 1):
        short = max(0, ecl["tot"][i - 1] - ecl["fsp_kW"][i - 1])
        bkWh = short * eclipse_hr * batt_margin
        bt = bkWh * 1000 / batt_Whkg / 1000
        ecl["bkWh"][i - 1] = bkWh
        ecl["bt"][i - 1] = bt
        if short > 0:
            bs = "%.0f kWh (%.1ft)" % (bkWh, bt)
        else:
            bs = "FSP covers"

    isru_ride_hr = 2
    ph["t2_kWh"] = ph["p_isru"] * isru_ride_hr
    ph["batt_total_kWh"] = ecl["bkWh"] + ph["t2_kWh"]
    ph["batt_total_t"] = ph["batt_total_kWh"] * 1000 / batt_Whkg / 1000

    # ---- ISRU DETAIL (loop leaves last-phase values) --------------------------------
    for i in range(1, ph["n"] + 1):
        lh2 = ph["wyr"][i - 1] * (2 * M_H2) / (2 * M_H2O) * 0.722
        lox = ph["wyr"][i - 1] * M_O2 / (2 * M_H2O) * 0.722

    # ---- TRUNK CABLE ---------------------------------------------------------------
    cu_rho = 0.24e-8
    cu_den = 8960
    tm = crater["traverse_km"] * 1000
    for i in range(1, ph["n"] + 1):
        I = ph["p_psr"][i - 1] * 1000 / V
        if I > 0:
            R = 0.05 * V / I
            A = cu_rho * tm * 2 / R * 1e6
            m = A * 1e-6 * tm * 2 * cu_den
        else:
            A = 10
            m = 1500

    # ---- MATERIAL OUTPUT ------------------------------------------------------------
    for i in range(1, ph["n"] + 1):
        kc = ph["nS"][i - 1] * skip["kreep_yr"] / 1e3 * 0.04
        pg = max(0, ph["nP"][i - 1] * 1.5 * (i > 1))

    # ---- POWER INFRASTRUCTURE MASS ---------------------------------------------------
    fsp_mass_cum = ecl["nfsp"] * fsp["mass_kg"]
    batt_mass = np.array([0, 1000, 1000, 1000, 1000.0])
    hub_mass = np.array([500, 500, 500, 500, 500.0])
    conv_mass = np.array([200, 400, 600, 800, 1000.0])
    cable_mass = np.array([300, 500, 700, 800, 880.0])
    total_pwr_mass = (ph["panel_kg"] + fsp_mass_cum + batt_mass + hub_mass + conv_mass + cable_mass) / 1000

    # ---- FAILURE ANALYSIS ------------------------------------------------------------
    d6 = ph["dT"][3]
    mn = mceil(d6 / mi["prop_yield"])
    sp = mceil(ph["mi"][-1] * 0.12)

    # ---- FIGURE DATA (captured by the harness) -----------------------------------------
    x = np.arange(1, ph["n"] + 1, dtype=float)
    cb = np.array([0.18, 0.55, 0.82]); cr = np.array([0.85, 0.32, 0.24]); ca = np.array([0.92, 0.65, 0.15])
    cg = np.array([0.30, 0.65, 0.30]); cy = np.array([0.60, 0.60, 0.60]); cd = np.array([0.18, 0.42, 0.72]); cp = np.array([0.55, 0.27, 0.68])
    pz = np.array([ph["p_fleet"] + ph["p_nodes"], ph["p_pipe"], ph["p_isru"], ph["p_base"], ph["p_cont"]]).T
    ez = np.array([ecl["mi"], ecl["nd"], ecl["pipe"], ecl["hab"], ecl["farmzbo"], ecl["sent"] + ecl["misc"]]).T
    for i in range(1, ph["n"] + 1):
        fc = ecl["fsp_kW"][i - 1]
    yrs = []
    st2 = []
    cs = 0
    ys = 4
    for i in range(1, ph["n"] + 1):
        for y in range(1, int(ph["dur"][i - 1]) + 1):
            cs = cs + ph["margin"][i - 1]
            yrs.append(ys + y - 1)
            st2.append(cs / 1e3)
        ys = ys + ph["dur"][i - 1]
    yrs = np.array(yrs, dtype=float)
    st2 = np.array(st2, dtype=float)
    ps = np.cumsum(np.concatenate(([4.0], ph["dur"])))
    pv = np.array([mi["pwr"]["drive"], mi["pwr"]["drill"], mi["pwr"]["minivex"], mi["pwr"]["web"], mi["pwr"]["comms"],
                   mi["pwr"]["gbx_htr"], mi["pwr"]["drill_htr"], mi["pwr"]["recept"]], dtype=float)

    return flatten(locals())
