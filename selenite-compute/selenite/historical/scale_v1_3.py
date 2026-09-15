"""Port of ``scaling_v1_3.m`` (SELENITE_SCALE v1.3, historical): six-phase
dual-base scaling analysis (KREEP chain, SKIP/hauler transport, catapult
hubs, in-situ fabrication, PROBE PGM, SPA propellant, MOLE-I fleet, power).

Oracle: ``scaling_v1_3.csv`` (171 rows). Historical: superseded by the
VERIFY and ECON chains, kept only so the golden reproduces. The script's
``'92%'`` printf defect affects console output only and is not reproduced.
"""
from __future__ import annotations

import math

import numpy as np

from ..capture import flatten

PORTED = True
SOURCE_SCRIPT = "scaling_v1_3.m"


def workspace(**params):
    """The script's final workspace (raw Python objects, before capture)."""
    g0 = 9.81
    g_moon = 1.62
    Isp = 450
    ve = Isp * g0

    kreep = {"spa_mid": 140, "pkt_mid": 1000}

    bene = {"recovery": 0.04, "uplift": 10, "line_cap": 1000}
    proc = {"eff": 0.80, "circuit_cap": 50, "pwr_kW": 180, "reagent": 49}

    skip = {"mf": 700, "rng_spa": 100, "rng_pkt": 35}
    skip["dv_spa"] = 4 * math.sqrt(g_moon * skip["rng_spa"] * 1e3 / 2) * 1.05
    skip["dv_pkt"] = 4 * math.sqrt(g_moon * skip["rng_pkt"] * 1e3 / 2) * 1.05
    skip["fuel_spa"] = skip["mf"] * (math.exp(skip["dv_spa"] / ve) - 1)
    skip["fuel_pkt"] = skip["mf"] * (math.exp(skip["dv_pkt"] / ve) - 1)
    skip["hops"] = 274
    skip["payload"] = 400

    hauler = {"payload": 5000, "speed": 1.0, "avail": 0.80, "range_km": 30}
    hauler["trip_hr"] = hauler["range_km"] * 2 * 1000 / hauler["speed"] / 3600
    hauler["trips_yr"] = math.floor(8760 * hauler["avail"] / hauler["trip_hr"])
    hauler["throughput"] = hauler["trips_yr"] * hauler["payload"] / 1000
    hauler["pwr_kW"] = 5

    catapult = {"range_km": 100, "v_launch": 500, "canister_kg": 5000, "canister_payload": 4500,
                "canister_empty": 500, "pwr_MW": 5, "pwr_return_MW": 0.5, "launches_hr": 6}
    catapult["throughput_yr"] = catapult["canister_payload"] * catapult["launches_hr"] * 8760 * 0.80 / 1000

    tier = {"frac_t1": np.array([0.95, 0.90, 0.85, 0.70, 0.40, 0.15]),
            "frac_t2": np.array([0.05, 0.08, 0.12, 0.25, 0.35, 0.30]),
            "frac_t3": np.array([0.00, 0.02, 0.03, 0.05, 0.25, 0.55])}

    fab = {"hauler_earth_frac": 0.08, "hauler_local_frac": 0.92, "hauler_life_yr": 10,
           "canister_life_cycles": 10000, "canister_cycles_yr": 40 * 365 * 0.80}

    probe = {"prop": 6654, "payload_current": 1500, "pgm_grade": 50e-6, "pgm_extraction": 0.70}
    probe_big = {"prop": 40000, "payload": 10000, "insitu_conc": 50}

    tanker = {"payload": 6000, "prop": 6654}
    tanker["total"] = tanker["payload"] + tanker["prop"]
    tanker["trips_yr"] = 12

    md = {"tanker_eff": tanker["payload"] / tanker["total"], "retro_eff": 0.63, "catcher_eff": 0.95,
          "earth_canister_reo": 3.5}

    mi = {"water_yr": 25 * 0.0446 * 0.80 * 8760}
    mi["prop_yield"] = mi["water_yr"] * 0.722
    mi["node"] = 10
    mi["pwr_kW"] = 1.934

    ice = {"depth_m": 10, "frac": 0.0446, "rho": 1550}

    shack = {"floor_km2": 33.2}
    shack["ice_total"] = shack["floor_km2"] * 1e6 * ice["depth_m"] * ice["rho"] * ice["frac"]
    shack["ice_yr"] = shack["ice_total"] * 0.02

    other_crater = {"floor_km2": 15}
    other_crater["ice_yr"] = other_crater["floor_km2"] * 1e6 * ice["depth_m"] * ice["rho"] * ice["frac"] * 0.02

    fsp = {"kW": 40}
    solar = {"yield": 0.319}

    hab = {"crew_mod": 4, "eclss_kW": 1.2}
    ls = {"prop_yr": 0.9 * 365 / 0.889 * 0.722}

    ss = {"cap_t": 100, "return_prop": 80000}

    pgm = {"demand": np.array([0.001, 0.005, 0.05, 0.2, 1.0, 5.0])}

    # ---- PHASES ------------------------------------------------------------
    n = 6
    ph = {"n": n, "lab": ["P7 (Y20)", "P8 (Y30)", "P9 (Y40)", "P10 (Y55)", "P11 (Y75)", "P12 (Y95)"],
          "reo_target": np.array([0.4, 125, 1000, 10000, 100000, 1000000])}
    fields = ("concentrate raw_kreep skip_spa skip_pkt n_haulers prop_pkt_skip skip_total proc_spa proc_pkt "
              "proc_total bene_total ore_t1 ore_t2 ore_t3 n_catapults n_canisters canister_prod_yr "
              "hauler_prod_yr fab_earth_mass fab_local_mass feni_need al_need fab_pwr n_probe probe_prop_each "
              "pgm_output prop_probe prop_local prop_pkt_need xfer_trips xfer_cost crew ss_reo_return "
              "prop_ss_return md_earth ss_crew prop_crew_return ss_reagent ss_pgm prop_skip_spa prop_ls "
              "prop_total n_molei n_nodes isru_supply margin ice_sites n_pem pwr_elec pwr_cryo pwr_psr pwr_hab "
              "pwr_proc_spa pwr_iz pwr_spa solar_m2 fsp_spa pwr_proc_pkt pwr_hauler pwr_bene_pkt pwr_catapult "
              "pwr_fab pwr_pkt fsp_pkt hab_mod elz_spa ss_total").split()
    for f in fields:
        ph[f] = np.zeros(n)
    probe_type = [None] * n   # MATLAB cells: never reach the CSV
    xfer_method = [None] * n

    # ---- MAIN CALCULATION LOOP -------------------------------------------
    for i in range(1, n + 1):
        p = i - 1
        grade = kreep["spa_mid"] if i == 1 else kreep["pkt_mid"]
        grade_conc = grade * bene["uplift"] / 1e6

        ph["concentrate"][p] = ph["reo_target"][p] / (grade_conc * proc["eff"])
        ph["raw_kreep"][p] = ph["concentrate"][p] / bene["recovery"]

        kreep_per_skip = skip["payload"] * skip["hops"] / 1000

        if i <= 3:
            if i == 1:
                ph["skip_spa"][p] = 8
                ph["skip_pkt"][p] = 0
            else:
                ph["skip_spa"][p] = max(2, 8 - 2 * (i - 1))
                ph["skip_pkt"][p] = max(1, math.ceil(ph["raw_kreep"][p] / kreep_per_skip) - ph["skip_spa"][p])
            ph["n_haulers"][p] = 0
            ph["pkt_transport"] = "Chemical SKIP"
            ph["prop_pkt_skip"][p] = ph["skip_pkt"][p] * skip["hops"] * skip["fuel_pkt"] / 1000
        else:
            ph["skip_spa"][p] = 0
            ph["skip_pkt"][p] = 0
            ph["n_haulers"][p] = math.ceil(ph["raw_kreep"][p] / hauler["throughput"])
            ph["pkt_transport"] = "Surface Hauler"
            ph["prop_pkt_skip"][p] = 0
        ph["skip_total"][p] = ph["skip_spa"][p] + ph["skip_pkt"][p]

        ph["proc_spa"][p] = min(5, math.ceil(ph["concentrate"][p] / proc["circuit_cap"]))
        if i == 1:
            ph["proc_pkt"][p] = 0
        else:
            ph["proc_pkt"][p] = max(0, math.ceil(ph["concentrate"][p] / proc["circuit_cap"]) - ph["proc_spa"][p])
        ph["proc_total"][p] = ph["proc_spa"][p] + ph["proc_pkt"][p]
        ph["bene_total"][p] = math.ceil(ph["raw_kreep"][p] / bene["line_cap"])

        ph["ore_t1"][p] = ph["raw_kreep"][p] * tier["frac_t1"][p]
        ph["ore_t2"][p] = ph["raw_kreep"][p] * tier["frac_t2"][p]
        ph["ore_t3"][p] = ph["raw_kreep"][p] * tier["frac_t3"][p]

        if ph["ore_t3"][p] > 0 and i >= 3:
            ph["n_catapults"][p] = math.ceil(ph["ore_t3"][p] / catapult["throughput_yr"])
            canisters_in_flight = ph["n_catapults"][p] * catapult["launches_hr"] * 4
            ph["n_canisters"][p] = math.ceil(canisters_in_flight * 1.20)
            ph["canister_prod_yr"][p] = math.ceil(
                ph["n_canisters"][p] / (fab["canister_life_cycles"] / fab["canister_cycles_yr"]))
        else:
            ph["n_catapults"][p] = 0
            ph["n_canisters"][p] = 0
            ph["canister_prod_yr"][p] = 0

        if i >= 4:
            if i == 4:
                ph["hauler_prod_yr"][p] = ph["n_haulers"][p]
            else:
                fleet_replace = math.ceil(ph["n_haulers"][p] / fab["hauler_life_yr"])
                fleet_growth = max(0, ph["n_haulers"][p] - ph["n_haulers"][p - 1]) / 5
                ph["hauler_prod_yr"][p] = math.ceil(fleet_replace + fleet_growth)
            ph["fab_earth_mass"][p] = ph["hauler_prod_yr"][p] * 1200 * fab["hauler_earth_frac"] / 1000
            ph["fab_local_mass"][p] = ph["hauler_prod_yr"][p] * 1200 * fab["hauler_local_frac"] / 1000
            ph["feni_need"][p] = ph["fab_local_mass"][p] * 0.60
            ph["al_need"][p] = ph["fab_local_mass"][p] * 0.30
            ph["fab_pwr"][p] = ph["hauler_prod_yr"][p] * 50
        else:
            for f in ("hauler_prod_yr", "fab_earth_mass", "fab_local_mass", "feni_need", "al_need", "fab_pwr"):
                ph[f][p] = 0

        pgm_needed = pgm["demand"][p] * 1000
        if i <= 2:
            pgm_per_probe = probe["payload_current"] * probe["pgm_grade"] * probe["pgm_extraction"]
            ph["n_probe"][p] = max(30, math.ceil(pgm_needed / pgm_per_probe))
            ph["probe_prop_each"][p] = probe["prop"]
            probe_type[p] = "Standard (1.5t)"
        else:
            pgm_per_probe = 500000 * probe["pgm_grade"] * probe["pgm_extraction"]
            ph["n_probe"][p] = max(30, math.ceil(pgm_needed / pgm_per_probe))
            ph["probe_prop_each"][p] = probe_big["prop"]
            probe_type[p] = "Heavy (500t proc)"
        ph["pgm_output"][p] = ph["n_probe"][p] * pgm_per_probe / 1000
        ph["prop_probe"][p] = ph["n_probe"][p] * ph["probe_prop_each"][p] / 1000

        if i >= 2 and ph["raw_kreep"][p] > 0:
            h2_sw = ph["raw_kreep"][p] * 50e-6 * 0.80
            o2_ilm = ph["raw_kreep"][p] * 0.05 * 0.10 * 0.50
            ph["prop_local"][p] = min(h2_sw * 6.5, o2_ilm / 5.5 * 6.5)
        else:
            ph["prop_local"][p] = 0

        ph["prop_pkt_need"][p] = max(0, ph["prop_pkt_skip"][p] - ph["prop_local"][p])

        if ph["prop_pkt_need"][p] > 0:
            if i <= 3:
                ph["xfer_trips"][p] = math.ceil(ph["prop_pkt_need"][p] * 1000 / tanker["payload"])
                ph["xfer_cost"][p] = ph["xfer_trips"][p] * tanker["total"] / 1000
                xfer_method[p] = "Tanker (47%)"
            elif i == 4:
                ph["xfer_trips"][p] = math.ceil(ph["prop_pkt_need"][p] * 1000 / (10000 * md["retro_eff"]))
                ph["xfer_cost"][p] = ph["xfer_trips"][p] * 10000 / 1000
                xfer_method[p] = "MassDriver+Retro"
            else:
                ph["xfer_trips"][p] = math.ceil(ph["prop_pkt_need"][p] * 1000 / (10000 * md["catcher_eff"]))
                ph["xfer_cost"][p] = ph["xfer_trips"][p] * 10000 / 1000
                xfer_method[p] = "MassDriver+Catcher"
        else:
            ph["xfer_trips"][p] = 0
            ph["xfer_cost"][p] = 0
            xfer_method[p] = "None (haulers)"

        ph["crew"][p] = 12 + 4 + max(0, (ph["proc_spa"][p] - 1))

        if i <= 3:
            ph["ss_reo_return"][p] = math.ceil(ph["reo_target"][p] / ss["cap_t"])
            ph["prop_ss_return"][p] = ph["ss_reo_return"][p] * ss["return_prop"] / 1000
            ph["md_earth"][p] = 0
        else:
            ph["ss_reo_return"][p] = 0
            ph["prop_ss_return"][p] = 0
            ph["md_earth"][p] = math.ceil(ph["reo_target"][p] / md["earth_canister_reo"])
        ph["ss_crew"][p] = max(1, math.ceil(ph["crew"][p] / 12))
        ph["prop_crew_return"][p] = ph["ss_crew"][p] * ss["return_prop"] / 1000

        ph["ss_reagent"][p] = math.ceil(ph["proc_pkt"][p] * proc["reagent"] / ss["cap_t"])
        if i == 1:
            ph["ss_reagent"][p] = 0

        ph["ss_pgm"][p] = 0

        ph["prop_skip_spa"][p] = ph["skip_spa"][p] * skip["hops"] * skip["fuel_spa"] / 1000
        ph["prop_ls"][p] = ph["crew"][p] * ls["prop_yr"] / 1000

        ph["prop_total"][p] = (ph["prop_skip_spa"][p] + ph["prop_probe"][p]
                               + ph["xfer_cost"][p] + ph["prop_ls"][p]
                               + ph["prop_ss_return"][p] + ph["prop_crew_return"][p])

        demand_kg = ph["prop_total"][p] * 1000 * 1.10
        raw_mi = math.ceil(demand_kg / mi["prop_yield"])
        ph["n_molei"][p] = math.ceil(raw_mi / mi["node"]) * mi["node"]
        ph["n_nodes"][p] = ph["n_molei"][p] / mi["node"]
        ph["isru_supply"][p] = ph["n_molei"][p] * mi["prop_yield"] / 1000
        ph["margin"][p] = ph["isru_supply"][p] - ph["prop_total"][p]

        ice_demand_kg = demand_kg / 0.722
        ph["ice_sites"][p] = max(1, math.ceil(ice_demand_kg / shack["ice_yr"]) - 1) + 1
        if ice_demand_kg <= shack["ice_yr"]:
            ph["ice_sites"][p] = 1

        water_kghr = demand_kg / (0.80 * 8760)
        ph["n_pem"][p] = math.ceil(water_kghr / 50)
        ph["pwr_elec"][p] = ph["n_pem"][p] * 51.8
        ph["pwr_cryo"][p] = water_kghr * (2 / 18) * 11.9 + water_kghr * (16 / 18) * 0.4
        ph["pwr_psr"][p] = ph["n_molei"][p] * mi["pwr_kW"]
        ph["pwr_hab"][p] = ph["crew"][p] * hab["eclss_kW"] + 50
        ph["pwr_proc_spa"][p] = ph["proc_spa"][p] * proc["pwr_kW"]
        ph["pwr_iz"][p] = 50 + ph["n_probe"][p] * 0.5
        ph["pwr_spa"][p] = (ph["pwr_elec"][p] + ph["pwr_cryo"][p] + ph["pwr_psr"][p]
                            + ph["pwr_hab"][p] + ph["pwr_proc_spa"][p] + ph["pwr_iz"][p]) * 1.20
        ph["solar_m2"][p] = ph["pwr_spa"][p] / solar["yield"]
        eclipse_kW = ph["pwr_hab"][p] + 60 + 10 + ph["pwr_proc_spa"][p] * 0.3
        ph["fsp_spa"][p] = math.ceil(eclipse_kW / fsp["kW"])

        ph["pwr_proc_pkt"][p] = ph["proc_pkt"][p] * proc["pwr_kW"]
        ph["pwr_hauler"][p] = ph["n_haulers"][p] * hauler["pwr_kW"] * 0.50
        ph["pwr_bene_pkt"][p] = max(0, ph["bene_total"][p] - 2) * 27
        if i == 1:
            ph["pwr_hauler"][p] = 0
            ph["pwr_bene_pkt"][p] = 0
        ph["pwr_catapult"][p] = ph["n_catapults"][p] * (catapult["pwr_MW"] + catapult["pwr_return_MW"]) * 1000 * 0.30
        ph["pwr_fab"][p] = ph["fab_pwr"][p]
        ph["pwr_pkt"][p] = (ph["pwr_proc_pkt"][p] + ph["pwr_hauler"][p] + ph["pwr_bene_pkt"][p]
                            + ph["pwr_catapult"][p] + ph["pwr_fab"][p] + 20) * 1.20
        if i == 1:
            ph["pwr_pkt"][p] = 0
        ph["fsp_pkt"][p] = math.ceil(ph["pwr_pkt"][p] * 0.70 / fsp["kW"])

        ph["hab_mod"][p] = math.ceil(ph["crew"][p] / hab["crew_mod"])
        ph["elz_spa"][p] = max(4, 2 + math.ceil(ph["xfer_trips"][p] / 500))
        ph["ss_total"][p] = ph["ss_crew"][p] + ph["ss_reo_return"][p] + ph["ss_reagent"][p] + 2

    # ---- OUTPUT (loop leftovers only) --------------------------------------
    for i in range(1, n + 1):
        st = "OK" if ph["margin"][i - 1] >= 0 else "FAIL"

    earth_ree = np.array([390000, 550000, 700000, 850000, 1000000, 1200000], dtype=float)
    pct = ph["reo_target"] / earth_ree * 100

    ph["probe_type"] = probe_type
    ph["xfer_method"] = xfer_method
    ws = dict(locals())
    for name in ("p", "f", "fields", "probe_type", "xfer_method", "params"):
        ws.pop(name, None)
    return ws


def run(**params):
    """Flattened workspace, keyed like the golden CSV."""
    return flatten(workspace(**params))
