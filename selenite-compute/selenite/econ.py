"""Port of ``SELENITE_ECON_V1_3.m`` (200-year bottom-up economic model) and
``SELENITE_ECON_V1_4.m`` (BCR, IRR and sensitivity tornado, which runs in
the v1.3 workspace).

Oracles: ``SELENITE_ECON_V1_3.csv`` (269 rows, the workspace after v1.3) and
``SELENITE_ECON_V1_4.csv`` (313 rows, the same workspace after v1.4 has
overwritten some names and added its own). ``run_script`` returns the
flattened workspace at either point; ``run`` returns the v1.4 (final) state.
``workspace(script)`` returns the raw objects for ``selenite.report``.

Every MATLAB variable is reproduced under the same name, including loop
leftovers (``i``, ``y``, ``idx``, ``ef`` ...) whose final values the harness
captured. Indices that MATLAB stores as values (``idx``, ``sort_idx``) are
kept 1-based; Python indexing uses ``idx - 1``.
"""
from __future__ import annotations

import math

import numpy as np
from scipy.optimize import brentq

from .capture import StructArray, flatten

PORTED = True
SOURCE_SCRIPT = "SELENITE_ECON_V1_3.m + SELENITE_ECON_V1_4.m"
SCRIPTS = ("SELENITE_ECON_V1_3", "SELENITE_ECON_V1_4")


def _pos_diff(x):
    """MATLAB ``max(0, diff([0; x]))``."""
    return np.maximum(0.0, np.diff(np.concatenate([[0.0], x])))


def _fzero(f, x0: float) -> float:
    """MATLAB (R2025a) ``fzero(f, x0)`` with a scalar start: expand an interval
    about ``x0`` until the sign changes, then Brent's method on the bracket.
    When the search reaches a non-finite point or value, fzero prints
    "Exiting fzero: aborting search ..." and returns NaN (it does not throw,
    so the script's try/catch is not taken)."""
    fx = f(x0)
    if not math.isfinite(fx):
        raise ValueError("fzero: function value at start is not finite")
    if fx == 0:
        return x0
    dx = x0 / 50 if x0 != 0 else 1 / 50
    a = b = x0
    fa = fb = fx
    while (fa > 0) == (fb > 0):
        dx *= math.sqrt(2)
        a = x0 - dx
        fa = f(a)
        if not math.isfinite(fa) or not math.isfinite(a):
            return float("nan")
        if (fa > 0) != (fb > 0):
            break
        b = x0 + dx
        fb = f(b)
        if not math.isfinite(fb) or not math.isfinite(b):
            return float("nan")
    return float(brentq(f, a, b, xtol=1e-15, rtol=8.9e-16, maxiter=500))


def _interp_knots(knots_y, knots_v, y):
    """The log-linear knot interpolation used for both REO ramps. Returns the
    value plus the loop leftovers (idx 1-based, y0, y1, r0, r1, frac)."""
    idx = int(np.flatnonzero(np.asarray(knots_y) <= y)[-1]) + 1  # find(..., 1, 'last')
    if idx >= len(knots_y):
        return knots_v[-1], idx, None
    y0 = knots_y[idx - 1]
    y1 = knots_y[idx]
    r0 = max(knots_v[idx - 1], 0.01)
    r1 = knots_v[idx]
    if r1 <= 0:
        return 0.0, idx, (y0, y1, r0, r1, None)
    frac = (y - y0) / (y1 - y0)
    return math.exp(math.log(r0) + frac * (math.log(r1) - math.log(r0))), idx, (y0, y1, r0, r1, frac)


def _v1_3() -> dict:
    """SELENITE_ECON_V1_3.m body; returns the workspace."""
    # ---- 1. UNIT SPECIFICATIONS --------------------------------------------
    circuit_designs = StructArray([
        {"name": "Batch (0.4 t/yr)", "reo_yr": 0.4, "mass_kg": 15000, "power_kw": 180},
        {"name": "Continuous-flow (0.8 t/yr)", "reo_yr": 0.8, "mass_kg": 22000, "power_kw": 300},
        {"name": "Optimised (1.2 t/yr)", "reo_yr": 1.2, "mass_kg": 28000, "power_kw": 400},
    ])
    CIRCUIT_DESIGN = 3

    circuit = {
        "reo_yr": circuit_designs[CIRCUIT_DESIGN - 1]["reo_yr"],
        "mass_kg": circuit_designs[CIRCUIT_DESIGN - 1]["mass_kg"],
        "power_kw": circuit_designs[CIRCUIT_DESIGN - 1]["power_kw"],
        "life_yr": 20,
        "maint_frac": 0.005,
        "earth_frac": lambda y: min(1.0, max(0.10, 1.0 - (y - 25) * 0.03)),
    }

    hauler = {"mass_kg": 1450, "throughput_yr": 1500, "life_yr": 10, "maint_kg_yr": 9,
              "earth_frac": lambda y: min(1.0, max(0.43, 1.0 - (y - 25) * 0.0285))}
    conv = {"mass_per_km": 100000, "earth_frac": 0.05, "maint_frac_yr": 0.005}
    msr = {"power_mw": 100, "mass_kg": 50000, "life_yr": 20,
           "earth_frac": lambda y: max(0.3, min(1.0, 1.0 - (y - 45) * 0.02))}
    fsp = {"power_kw": 40, "mass_kg": 6600}
    can = {"reo_payload_t": 3.5, "earth_kg": 28}
    molei = {"propellant_yr": 5692, "mass_kg": 360}
    probe = {"propellant": 6654, "mass_kg": 800, "pgm_per_mission": 0.0175}
    skip = {"propellant_yr": 83000, "count": 8}
    sinter = {"mass_kg": 2200}
    armc = {"mass_kg": 1500}
    reagent = {"per_circuit_yr": 49000, "isru_frac": lambda y: min(0.98, max(0, (y - 9) * 0.03))}

    # ---- 2. ECONOMIC PARAMETERS --------------------------------------------
    Y = np.arange(0, 201, dtype=float)
    N = len(Y)

    launch_cost = np.array([6000 * (y < 25) + 4000 * (25 <= y < 45) + 2000 * (y >= 45) for y in Y], dtype=float)
    dr = np.array([0.03 * (y <= 30) + 0.025 * (30 < y <= 75) + 0.02 * (y > 75) for y in Y])
    df = np.cumprod(1.0 / (1.0 + dr))
    contingency = np.array([1.50 * (y < 25) + 1.35 * (25 <= y < 45) + 1.25 * (y >= 45) for y in Y])

    insitu_cost_per_kg = 100
    scc = 190

    # ---- 3. REO RAMP -------------------------------------------------------
    reo_final = 2500000
    reo_knots_y = np.array([0, 15, 18, 25, 28, 35, 45, 60, 80, 100, 120, 140, 160, 180, 200], dtype=float)
    reo_knots_v = np.array([0, 0, 0, 0.4, 125, 125, 1000, 10000, 100000, 250000, 500000, 1000000,
                            1500000, 2500000, 2500000], dtype=float)

    reo_target = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        if y <= 18:
            reo_target[i - 1] = 0
            continue
        val, idx, left = _interp_knots(reo_knots_y, reo_knots_v, y)
        reo_target[i - 1] = val
        if left is not None:
            y0, y1, r0, r1, frac_ = left
            if frac_ is not None:
                frac = frac_
    reo_target = np.minimum(reo_target, reo_final)

    probe_knots_y = np.array([0, 9, 15, 25, 35, 45, 60, 70, 80, 85, 200], dtype=float)
    probe_knots_v = np.array([0, 3, 30, 96, 190, 230, 260, 150, 50, 30, 30], dtype=float)
    probe_fleet = np.floor(np.interp(Y, probe_knots_y, probe_knots_v))

    skip_active = np.array([skip["count"] * (7 <= y < 35)
                            + max(0, skip["count"] * (1 - (y - 35) / 10)) * (35 <= y < 45) for y in Y])
    frontier_km = np.array([min(150, max(0, (y - 28) * 2)) * (y >= 28) for y in Y], dtype=float)
    tier3_frac = np.array([min(0.55, max(0, (y - 40) * 0.01)) * (y >= 40) for y in Y], dtype=float)

    # ---- 4. INFRASTRUCTURE DERIVATION --------------------------------------
    circuits_needed = np.ceil(reo_target / circuit["reo_yr"])
    regolith_yr = reo_target / 0.0005
    hauler_ore_frac = 1 - tier3_frac
    haulers_needed = np.ceil(regolith_yr * hauler_ore_frac / hauler["throughput_yr"])
    conv_km_needed = regolith_yr * tier3_frac / 20000

    power_kw = circuits_needed * circuit["power_kw"]
    msr_count = np.zeros(N)
    fsp_count = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        if y < 35:
            fsp_count[i - 1] = math.ceil(power_kw[i - 1] / fsp["power_kw"])
        elif y < 45:
            mf = (y - 35) / 10
            msr_count[i - 1] = math.ceil(power_kw[i - 1] * mf / (msr["power_mw"] * 1000))
            fsp_count[i - 1] = math.ceil(power_kw[i - 1] * (1 - mf) / fsp["power_kw"])
        else:
            msr_count[i - 1] = math.ceil(power_kw[i - 1] / (msr["power_mw"] * 1000))
            fsp_count[i - 1] = min(20, fsp_count[max(1, i - 1) - 1])

    prop_demand_kg = probe_fleet * probe["propellant"] + skip_active * skip["propellant_yr"] + 100000
    molei_needed = np.ceil(prop_demand_kg / molei["propellant_yr"])

    canisters_yr = np.zeros(N)
    for i in range(1, N + 1):
        if Y[i - 1] >= 35:
            canisters_yr[i - 1] = math.ceil(reo_target[i - 1] / can["reo_payload_t"])

    pgm_production = probe_fleet * probe["pgm_per_mission"]

    # ---- 5. EARTH CARGO ----------------------------------------------------
    d_circuits = _pos_diff(circuits_needed)
    d_haulers = _pos_diff(haulers_needed)
    d_conv_km = _pos_diff(conv_km_needed)
    d_msr = _pos_diff(msr_count)
    d_fsp = _pos_diff(fsp_count)
    d_molei = _pos_diff(molei_needed)
    d_probes = _pos_diff(probe_fleet)

    cargo_circuits = np.array([d_circuits[i] * circuit["mass_kg"] * circuit["earth_frac"](Y[i]) / 1000 for i in range(N)])
    cargo_haulers = np.array([d_haulers[i] * hauler["mass_kg"] * hauler["earth_frac"](Y[i]) / 1000 for i in range(N)])
    cargo_conveyors = d_conv_km * conv["mass_per_km"] * conv["earth_frac"] / 1000
    cargo_msr = np.array([d_msr[i] * msr["mass_kg"] * msr["earth_frac"](Y[i]) / 1000 for i in range(N)])
    cargo_fsp = d_fsp * fsp["mass_kg"] / 1000
    cargo_molei = d_molei * (molei["mass_kg"] + 27) / 1000
    cargo_probes = d_probes * probe["mass_kg"] / 1000
    cargo_canisters = canisters_yr * can["earth_kg"] / 1000

    cargo_reagent = np.array([circuits_needed[i] * reagent["per_circuit_yr"] * (1 - reagent["isru_frac"](Y[i])) / 1e6
                              for i in range(N)])

    maint_circuits = np.array([circuits_needed[i] * circuit["mass_kg"] * circuit["maint_frac"]
                               * circuit["earth_frac"](Y[i]) / 1000 for i in range(N)])
    maint_haulers = haulers_needed * hauler["maint_kg_yr"] / 1000
    maint_conv = conv_km_needed * conv["mass_per_km"] * conv["maint_frac_yr"] * conv["earth_frac"] / 1000
    maint_msr = np.array([msr_count[i] / msr["life_yr"] * msr["mass_kg"] * msr["earth_frac"](Y[i]) / 1000
                          for i in range(N)])

    cargo_construction = np.zeros(N)
    cargo_construction[26 - 1] = (20 * sinter["mass_kg"] + 10 * hauler["mass_kg"] + 5 * armc["mass_kg"]
                                  + 4 * fsp["mass_kg"] + 85000) / 1000
    cargo_construction[29 - 1] = 62 / 1

    cargo_ybco = np.zeros(N)
    cargo_ybco[23 - 1] = 30
    cargo_ybco[24 - 1] = 30
    cargo_ybco[36 - 1] = 50
    cargo_ybco[44 - 1] = 30

    cargo_spa_ops = np.array([18 * (y < 7) + 23 * (7 <= y < 9) + 30 * (9 <= y < 15) + 20 * (15 <= y < 25)
                              + 15 * (y >= 25) for y in Y], dtype=float)

    armc_needed = np.ceil(d_circuits / 500)
    sinter_needed_build = np.ceil(d_circuits / 200)
    sentinel_needed = np.ceil(circuits_needed / 500)
    hubs_needed = np.ceil(haulers_needed / 100)

    d_sentinel = _pos_diff(sentinel_needed)
    d_hubs = _pos_diff(hubs_needed)

    cargo_armc = armc_needed * 1500 / 1000
    cargo_sinter_build = sinter_needed_build * 2200 / 1000
    cargo_sentinel = d_sentinel * 80 / 1000
    cargo_hubs = d_hubs * 5000 * 0.05 / 1000

    maint_armc = np.zeros(N)
    maint_sinter = np.zeros(N)
    maint_sentinel = np.zeros(N)
    for i in range(1, N + 1):
        active_armc = max(20, armc_needed[i - 1])
        active_sinter = max(50, sinter_needed_build[i - 1])
        maint_armc[i - 1] = active_armc / 10 * 1500 / 1000
        maint_sinter[i - 1] = active_sinter / 15 * 2200 / 1000
        maint_sentinel[i - 1] = sentinel_needed[i - 1] / 10 * 80 / 1000

    cargo_construction_fleet = (cargo_armc + cargo_sinter_build + cargo_sentinel + cargo_hubs
                                + maint_armc + maint_sinter + maint_sentinel)

    # PROBE Mk III SEP fleet
    mkiii_target = 1714
    mkiii_mass_kg = 1200
    mkiii_life = 15
    mkiii_active = np.zeros(N)
    mkiii_build = np.zeros(N)
    mkiii_pgm = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        if 60 <= y < 80:
            mkiii_active[i - 1] = min(mkiii_target, (y - 60) / 20 * mkiii_target)
            mkiii_build[i - 1] = mkiii_target / 20
        elif 80 <= y < 115:
            mkiii_active[i - 1] = mkiii_target
        elif y >= 115:
            mkiii_active[i - 1] = 300
        mkiii_replace = mkiii_active[i - 1] / mkiii_life
        mkiii_pgm[i - 1] = mkiii_active[i - 1] * probe["pgm_per_mission"] * 0.5
    cargo_mkiii_leo = np.zeros(N)
    for i in range(1, N + 1):
        build = 0
        if 60 <= Y[i - 1] < 80:
            build = mkiii_target / 20
        cargo_mkiii_leo[i - 1] = (build + mkiii_active[i - 1] / mkiii_life) * mkiii_mass_kg / 1000

    # Asteroid redirect tugs
    tug_mass_kg = 50000
    tug_life = 20
    tug_fleet = np.array([0 * (y < 65) + 2 * (65 <= y < 85) + 3 * (85 <= y < 105) + 5 * (y >= 105) for y in Y],
                         dtype=float)
    d_tugs = _pos_diff(tug_fleet)
    cargo_tugs_leo = (d_tugs + tug_fleet / tug_life) * tug_mass_kg / 1000

    cargo_dro_infra = np.zeros(N)
    cargo_dro_infra[71 - 1] = 110
    cargo_dro_infra[81 - 1] = 50
    cargo_dro_infra[86 - 1] = 50
    cargo_dro_infra[96 - 1] = 30
    cargo_dro_infra[106 - 1] = 40
    cargo_dro_infra[116 - 1] = 30
    cargo_dro_infra[126 - 1] = 60

    spa_msr_count = np.array([0 * (y < 105) + 1 * (105 <= y < 125) + 2 * (125 <= y < 140) + 3 * (y >= 140)
                              for y in Y], dtype=float)
    d_spa_msr = _pos_diff(spa_msr_count)
    cargo_spa_msr = np.zeros(N)
    maint_spa_msr = np.zeros(N)
    for i in range(1, N + 1):
        ef = msr["earth_frac"](Y[i - 1])
        cargo_spa_msr[i - 1] = d_spa_msr[i - 1] * msr["mass_kg"] * ef / 1000
        maint_spa_msr[i - 1] = spa_msr_count[i - 1] / msr["life_yr"] * msr["mass_kg"] * ef / 1000

    probe_salvage_feni = np.zeros(N)
    for i in range(2, N + 1):
        fleet_reduction = max(0, probe_fleet[i - 2] - probe_fleet[i - 1])
        probe_salvage_feni[i - 1] = fleet_reduction * probe["mass_kg"] * 0.7 / 1000

    captured_asteroid_pgm = np.zeros(N)
    for i in range(1, N + 1):
        if Y[i - 1] >= 85:
            captured_asteroid_pgm[i - 1] = 36.5

    # Circuit Earth fraction reduction from asteroid resources
    insitu_circuits = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        ef_base = min(1.0, max(0.10, 1.0 - (y - 25) * 0.03))
        if y >= 105:
            ctype_reduction = 0.07 * min(1, (y - 105) / 10)
            ef_base = max(0.03, ef_base - ctype_reduction)
        if y >= 125:
            stype_reduction = 0.022 * min(1, (y - 125) / 10)
            ef_base = max(0.008, ef_base - stype_reduction)
        cargo_circuits[i - 1] = d_circuits[i - 1] * circuit["mass_kg"] * ef_base / 1000
        maint_circuits[i - 1] = circuits_needed[i - 1] * circuit["mass_kg"] * circuit["maint_frac"] * ef_base / 1000
        insitu_circuits[i - 1] = d_circuits[i - 1] * circuit["mass_kg"] * (1 - ef_base) / 1000

    earth_cargo = (cargo_circuits + cargo_haulers + cargo_conveyors
                   + cargo_msr + cargo_fsp + cargo_molei + cargo_probes
                   + cargo_canisters + cargo_reagent
                   + maint_circuits + maint_haulers + maint_conv + maint_msr
                   + cargo_construction + cargo_ybco + cargo_spa_ops
                   + cargo_construction_fleet + cargo_dro_infra)

    insitu_circuits = np.array([d_circuits[i] * circuit["mass_kg"] * (1 - circuit["earth_frac"](Y[i])) / 1000
                                for i in range(N)])
    insitu_haulers = np.array([d_haulers[i] * hauler["mass_kg"] * (1 - hauler["earth_frac"](Y[i])) / 1000
                               for i in range(N)])
    insitu_conveyors = d_conv_km * conv["mass_per_km"] * (1 - conv["earth_frac"]) / 1000
    insitu_total = insitu_circuits + insitu_haulers + insitu_conveyors

    # ---- 6. REVENUE & ENVIRONMENTAL MODEL ----------------------------------
    reo_demand_2026 = 400000
    reo_demand = reo_demand_2026 * (1.02) ** Y
    reo_demand = np.minimum(reo_demand, 2500000)
    supply_frac = reo_target / reo_demand
    reo_price = np.maximum(5000, 15000 * (1 - 0.6 * supply_frac))

    rev_reo = reo_target * reo_price / 1e6
    total_pgm = pgm_production + mkiii_pgm + captured_asteroid_pgm
    rev_pgm = total_pgm * 50e6 / 1e6
    rev_direct = rev_reo + rev_pgm

    ext_reo = reo_target * 73700 / 1e6
    co2_avoided_reo = reo_target * 30

    ir_frac = 0.15
    h2_attribution = 0.50
    pem_gw_per_t_ir = 1.0
    h2_per_gw_yr = 150000
    h2_co2_mult = 12
    pem_life = 20
    total_ir = total_pgm * ir_frac
    ir_attributed = total_ir * h2_attribution
    pem_gw = np.zeros(N)
    for i in range(2, N + 1):
        pem_gw[i - 1] = pem_gw[i - 2] + ir_attributed[i - 1] * pem_gw_per_t_ir
        if i > pem_life:
            pem_gw[i - 1] = pem_gw[i - 1] - ir_attributed[i - pem_life - 1] * pem_gw_per_t_ir
        pem_gw[i - 1] = max(0, pem_gw[i - 1])
    co2_avoided_h2 = pem_gw * h2_per_gw_yr * h2_co2_mult
    ext_h2 = co2_avoided_h2 * scc / 1e6

    tanker_ratio = np.array([14 * (y < 25) + 8 * (25 <= y < 45) + 5 * (y >= 45) for y in Y], dtype=float)
    fossil_frac = np.array([
        1.00 * (y < 30) + max(0.80, 1.00 - (y - 30) * 0.0133) * (30 <= y < 45)
        + max(0.30, 0.80 - (y - 45) * 0.0333) * (45 <= y < 60)
        + max(0.05, 0.30 - (y - 60) * 0.0125) * (60 <= y < 80) + 0.05 * (y >= 80) for y in Y])
    total_launches = (earth_cargo / 100) * tanker_ratio
    co2_rockets = total_launches * 2750 * fossil_frac
    ext_rockets = -co2_rockets * scc / 1e6

    geo_insurance_per_yr = 15000
    geo_threshold = 0.01
    ext_geo = np.zeros(N)
    for i in range(1, N + 1):
        if supply_frac[i - 1] > geo_threshold:
            ext_geo[i - 1] = geo_insurance_per_yr * min(1, supply_frac[i - 1] / 0.5)

    ext_total = ext_reo + ext_h2 + ext_rockets + ext_geo
    rev_total = rev_direct + ext_total

    # ---- 7. COST MODEL -----------------------------------------------------
    cost_insitu = insitu_total * 1000 * insitu_cost_per_kg / 1e6
    cost_rd = np.array([500 * (y < 25) + 1000 * (25 <= y < 45) + 1500 * (45 <= y < 60) + 2000 * (y >= 60)
                        for y in Y], dtype=float)

    leo_cost_per_kg = 500
    cost_mkiii = cargo_mkiii_leo * 1000 * leo_cost_per_kg * contingency / 1e6
    cost_tugs = cargo_tugs_leo * 1000 * leo_cost_per_kg * contingency / 1e6

    cost_dro_ops = np.array([0 * (y < 85) + 200 * (y >= 85) for y in Y], dtype=float)
    cost_asteroid_processing = np.array([0 * (y < 105) + 500 * (105 <= y < 125) + 1300 * (y >= 125) for y in Y],
                                        dtype=float)

    maint_molei_saving = np.zeros(N)
    for i in range(1, N + 1):
        if Y[i - 1] >= 110:
            current_molei = molei_needed[i - 1]
            reduced_molei = 50
            saved = max(0, current_molei - reduced_molei)
            maint_molei_saving[i - 1] = saved * molei["mass_kg"] * 0.02 / 1000

    for i in range(1, N + 1):
        if Y[i - 1] >= 90:
            mtype_bonus = 0.10 * min(1, (Y[i - 1] - 90) / 10)
            ef_h = hauler["earth_frac"](Y[i - 1]) - mtype_bonus
            ef_h = max(0.20, ef_h)
            cargo_haulers[i - 1] = d_haulers[i - 1] * hauler["mass_kg"] * ef_h / 1000
            maint_haulers[i - 1] = (haulers_needed[i - 1] * hauler["maint_kg_yr"]
                                    * (ef_h / hauler["earth_frac"](Y[i - 1])) / 1000)

    earth_cargo = (cargo_circuits + cargo_haulers + cargo_conveyors
                   + cargo_msr + cargo_fsp + cargo_molei + cargo_probes
                   + cargo_canisters + cargo_reagent
                   + maint_circuits + maint_haulers + maint_conv + maint_msr
                   + cargo_construction + cargo_ybco + cargo_spa_ops
                   + cargo_construction_fleet + cargo_dro_infra
                   + cargo_spa_msr + maint_spa_msr - maint_molei_saving)
    earth_cargo = np.maximum(0, earth_cargo)

    cost_launch = earth_cargo * 1000 * launch_cost * contingency / 1e6
    cost_total = (cost_launch + cost_insitu + cost_rd + cost_mkiii + cost_tugs
                  + cost_dro_ops + cost_asteroid_processing)

    # ---- 8. NPV & METRICS --------------------------------------------------
    net_total = rev_total - cost_total
    net_direct = rev_direct - cost_total
    npv_total = np.cumsum(net_total * df)
    npv_direct = np.cumsum(net_direct * df)
    cum_cost = np.cumsum(cost_total)
    cum_rev = np.cumsum(rev_total)

    _be = np.flatnonzero(np.cumsum(rev_total - cost_total) > 0)
    be_total = np.array([_be[0] + 1.0]) if _be.size else np.zeros(0)

    check_y = np.array([25, 35, 45, 60, 80, 100, 120, 140, 160, 200], dtype=float)
    for y in check_y:
        i = y + 1
    i160 = 161
    i200 = 201

    # ---- 9. CIRCUIT THROUGHPUT SENSITIVITY ---------------------------------
    for d in range(1, 4):
        cd = circuit_designs[d - 1]
        circ_k = np.ceil(reo_target / cd["reo_yr"])
        d_circ_k = _pos_diff(circ_k)
        cargo_k = np.zeros(N)
        maint_k = np.zeros(N)
        insitu_k = np.zeros(N)
        for i in range(1, N + 1):
            ef = circuit["earth_frac"](Y[i - 1])
            cargo_k[i - 1] = d_circ_k[i - 1] * cd["mass_kg"] * ef / 1000
            maint_k[i - 1] = circ_k[i - 1] * cd["mass_kg"] * 0.02 * ef / 1000
            insitu_k[i - 1] = d_circ_k[i - 1] * cd["mass_kg"] * (1 - ef) / 1000
        ec_k = earth_cargo - cargo_circuits - maint_circuits + cargo_k + maint_k
        cl_k = ec_k * 1000 * launch_cost * contingency / 1e6
        is_k = (insitu_total - insitu_circuits + insitu_k) * 1000 * insitu_cost_per_kg / 1e6
        ct_k = cl_k + is_k + cost_rd
        npv_k = np.sum((rev_total - ct_k) * df)

    # ---- 10. OTHER SENSITIVITIES -------------------------------------------
    baseline_npv = npv_total[-1] / 1e6

    dr_opts = np.array([0.014, 0.020, 0.030, 0.035])
    for k in range(1, 5):
        df_k = np.cumprod(1.0 / (1.0 + dr_opts[k - 1] * np.ones(N)))

    for mult in (1.5, 1.0, 0.5):
        cl_k = earth_cargo * 1000 * (launch_cost * mult) * contingency / 1e6
        ct_k = cl_k + cost_insitu + cost_rd

    for gval in (0, 15000, 25000):
        ext_g_k = np.zeros(N)
        for i in range(1, N + 1):
            if supply_frac[i - 1] > geo_threshold:
                ext_g_k[i - 1] = gval * min(1, supply_frac[i - 1] / 0.5)
        rev_k = rev_direct + ext_reo + ext_h2 + ext_rockets + ext_g_k

    # ---- 11. FIGURES (data only) -------------------------------------------
    axc = np.array([.05, .08, .12])
    txc = np.array([.7, .8, .9])
    gc = np.array([.15, .2, .3])

    cargo_stack = np.column_stack([
        cargo_circuits, cargo_haulers, cargo_conveyors, cargo_canisters,
        cargo_msr + cargo_fsp, cargo_reagent, cargo_molei + cargo_probes,
        maint_circuits + maint_haulers + maint_conv + maint_msr,
        cargo_spa_ops + cargo_construction + cargo_ybco])
    for j in range(1, 10):
        pass

    # ---- 12. COMPARISON: 2.5 Mt/yr vs 1.25 Mt/yr ---------------------------
    reo_alt_y = np.array([0, 15, 18, 25, 28, 35, 45, 60, 80, 100, 120, 140, 200], dtype=float)
    reo_alt_v = np.array([0, 0, 0, 0.4, 125, 125, 1000, 10000, 100000, 250000, 500000, 1250000, 1250000],
                         dtype=float)
    reo_final_alt = 1250000

    reo_25 = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        if y <= 18:
            reo_25[i - 1] = 0
            continue
        val, idx, left = _interp_knots(reo_alt_y, reo_alt_v, y)
        reo_25[i - 1] = val
        if left is not None:
            y0, y1, r0, r1, frac_ = left
            if frac_ is not None:
                frac = frac_
    reo_25 = np.minimum(reo_25, reo_final_alt)

    circ_25 = np.ceil(reo_25 / circuit["reo_yr"])
    d_circ_25 = _pos_diff(circ_25)
    reg_25 = reo_25 / 0.0005
    haul_25 = np.ceil(reg_25 * hauler_ore_frac / hauler["throughput_yr"])
    conv_25 = reg_25 * tier3_frac / 20000
    d_haul_25 = _pos_diff(haul_25)
    d_conv_25 = _pos_diff(conv_25)
    pwr_25 = circ_25 * circuit["power_kw"]
    msr_25 = np.zeros(N)
    for i in range(1, N + 1):
        if Y[i - 1] >= 45:
            msr_25[i - 1] = math.ceil(pwr_25[i - 1] / (msr["power_mw"] * 1000))
    d_msr_25 = _pos_diff(msr_25)
    can_25 = np.zeros(N)
    for i in range(1, N + 1):
        if Y[i - 1] >= 35:
            can_25[i - 1] = math.ceil(reo_25[i - 1] / can["reo_payload_t"])

    cargo_circ_25 = np.zeros(N)
    cargo_haul_25 = np.zeros(N)
    maint_circ_25 = np.zeros(N)
    maint_haul_25 = haul_25 * hauler["maint_kg_yr"] / 1000
    insitu_circ_25 = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        ef = min(1.0, max(0.10, 1.0 - (y - 25) * 0.03))
        if y >= 105:
            ef = max(0.03, ef - 0.07 * min(1, (y - 105) / 10))
        if y >= 125:
            ef = max(0.008, ef - 0.022 * min(1, (y - 125) / 10))
        cargo_circ_25[i - 1] = d_circ_25[i - 1] * circuit["mass_kg"] * ef / 1000
        maint_circ_25[i - 1] = circ_25[i - 1] * circuit["mass_kg"] * circuit["maint_frac"] * ef / 1000
        cargo_haul_25[i - 1] = d_haul_25[i - 1] * hauler["mass_kg"] * hauler["earth_frac"](y) / 1000
        insitu_circ_25[i - 1] = d_circ_25[i - 1] * circuit["mass_kg"] * (1 - ef) / 1000
    cargo_conv_25 = d_conv_25 * conv["mass_per_km"] * conv["earth_frac"] / 1000
    maint_conv_25 = conv_25 * conv["mass_per_km"] * conv["maint_frac_yr"] * conv["earth_frac"] / 1000
    cargo_msr_25 = np.zeros(N)
    maint_msr_25 = np.zeros(N)
    for i in range(1, N + 1):
        ef = msr["earth_frac"](Y[i - 1])
        cargo_msr_25[i - 1] = d_msr_25[i - 1] * msr["mass_kg"] * ef / 1000
        maint_msr_25[i - 1] = msr_25[i - 1] / msr["life_yr"] * msr["mass_kg"] * ef / 1000
    cargo_can_25 = can_25 * can["earth_kg"] / 1000

    ec_25 = (cargo_circ_25 + cargo_haul_25 + cargo_conv_25 + cargo_msr_25
             + cargo_can_25 + maint_circ_25 + maint_haul_25 + maint_conv_25 + maint_msr_25
             + cargo_fsp + cargo_molei + cargo_probes + cargo_reagent
             + cargo_construction + cargo_ybco + cargo_spa_ops
             + cargo_construction_fleet + cargo_dro_infra
             + cargo_spa_msr + maint_spa_msr - maint_molei_saving)
    ec_25 = np.maximum(0, ec_25)
    insitu_25 = insitu_circ_25 + insitu_haulers + insitu_conveyors

    cl_25 = ec_25 * 1000 * launch_cost * contingency / 1e6
    ci_25 = insitu_25 * 1000 * insitu_cost_per_kg / 1e6
    ct_25 = cl_25 + ci_25 + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing

    sf_25 = reo_25 / reo_demand
    rp_25 = np.maximum(5000, 15000 * (1 - 0.6 * sf_25))
    rr_25 = reo_25 * rp_25 / 1e6
    er_25 = reo_25 * 73700 / 1e6
    co2_reo_25 = reo_25 * 30
    eg_25 = np.zeros(N)
    for i in range(1, N + 1):
        if sf_25[i - 1] > geo_threshold:
            eg_25[i - 1] = geo_insurance_per_yr * min(1, sf_25[i - 1] / 0.5)
    tl_25 = (ec_25 / 100) * tanker_ratio
    cr_25 = tl_25 * 2750 * fossil_frac
    exr_25 = -cr_25 * scc / 1e6

    rv_25 = rr_25 + rev_pgm + er_25 + ext_h2 + eg_25 + exr_25
    npv_25 = np.sum((rv_25 - ct_25) * df)

    i200 = 201

    net_25 = rv_25 - ct_25

    ws = dict(locals())
    for name in ("val", "left", "frac_"):
        ws.pop(name, None)
    return ws


def _v1_4(ws: dict) -> dict:
    """SELENITE_ECON_V1_4.m body run in the v1.3 workspace; returns the union."""
    Y = ws["Y"]
    N = ws["N"]
    df = ws["df"]
    cost_total = ws["cost_total"]
    cost_insitu = ws["cost_insitu"]
    cost_rd = ws["cost_rd"]
    cost_mkiii = ws["cost_mkiii"]
    cost_tugs = ws["cost_tugs"]
    cost_dro_ops = ws["cost_dro_ops"]
    cost_asteroid_processing = ws["cost_asteroid_processing"]
    rev_direct = ws["rev_direct"]
    rev_total = ws["rev_total"]
    ext_reo = ws["ext_reo"]
    ext_h2 = ws["ext_h2"]
    ext_geo = ws["ext_geo"]
    ext_rockets = ws["ext_rockets"]
    net_direct = ws["net_direct"]
    net_total = ws["net_total"]
    npv_total = ws["npv_total"]
    circuit_designs = ws["circuit_designs"]
    circuit = ws["circuit"]
    reo_target = ws["reo_target"]
    reo_demand = ws["reo_demand"]
    earth_cargo = ws["earth_cargo"]
    cargo_circuits = ws["cargo_circuits"]
    maint_circuits = ws["maint_circuits"]
    launch_cost = ws["launch_cost"]
    contingency = ws["contingency"]
    insitu_total = ws["insitu_total"]
    insitu_circuits = ws["insitu_circuits"]
    insitu_cost_per_kg = ws["insitu_cost_per_kg"]
    circuits_needed = ws["circuits_needed"]
    total_pgm = ws["total_pgm"]
    ir_frac = ws["ir_frac"]
    pem_gw_per_t_ir = ws["pem_gw_per_t_ir"]
    pem_life = ws["pem_life"]
    h2_per_gw_yr = ws["h2_per_gw_yr"]
    h2_co2_mult = ws["h2_co2_mult"]
    scc = ws["scc"]
    geo_threshold = ws["geo_threshold"]

    # ---- 1. BCR ------------------------------------------------------------
    pv_cost = np.sum(cost_total * df)
    pv_rev_direct = np.sum(rev_direct * df)
    pv_rev_total = np.sum(rev_total * df)
    pv_ext_reo = np.sum(ext_reo * df)
    pv_ext_h2 = np.sum(ext_h2 * df)
    pv_ext_geo = np.sum(ext_geo * df)
    pv_ext_rockets = np.sum(ext_rockets * df)

    bcr_direct = pv_rev_direct / pv_cost
    bcr_total = pv_rev_total / pv_cost
    bcr_reo_only = (pv_rev_direct + pv_ext_reo) / pv_cost

    # ---- 2. IRR ------------------------------------------------------------
    with np.errstate(all="ignore"):
        try:
            irr_direct = _fzero(lambda r: float(np.sum(net_direct / (1 + r) ** Y)), 0.01)
        except ValueError:
            irr_direct = float("nan")
        try:
            irr_total = _fzero(lambda r: float(np.sum(net_total / (1 + r) ** Y)), 0.01)
        except ValueError:
            irr_total = float("nan")
        try:
            dr_breakeven = _fzero(
                lambda r: float(np.sum(rev_total / (1 + r) ** Y) - np.sum(cost_total / (1 + r) ** Y)), 0.01)
        except ValueError:
            dr_breakeven = float("nan")

    # ---- 3. SENSITIVITY TORNADO -------------------------------------------
    baseline_npv = npv_total[-1] / 1e6

    def compute_npv(rev, cost):
        return np.sum((rev - cost) * df) / 1e6

    sens = []

    circuit_npv = np.zeros(2)
    for d_idx in range(1, 3):
        cd = circuit_designs[d_idx - 1]
        circ_k = np.ceil(reo_target / cd["reo_yr"])
        d_circ_k = _pos_diff(circ_k)
        cargo_k = np.zeros(N)
        maint_k = np.zeros(N)
        insitu_k = np.zeros(N)
        for i in range(1, N + 1):
            ef = min(1.0, max(0.10, 1.0 - (Y[i - 1] - 25) * 0.03))
            if Y[i - 1] >= 105:
                ef = max(0.03, ef - 0.07 * min(1, (Y[i - 1] - 105) / 10))
            if Y[i - 1] >= 125:
                ef = max(0.008, ef - 0.022 * min(1, (Y[i - 1] - 125) / 10))
            cargo_k[i - 1] = d_circ_k[i - 1] * cd["mass_kg"] * ef / 1000
            maint_k[i - 1] = circ_k[i - 1] * cd["mass_kg"] * 0.005 * ef / 1000
            insitu_k[i - 1] = d_circ_k[i - 1] * cd["mass_kg"] * (1 - ef) / 1000
        ec_k = np.maximum(0, earth_cargo - cargo_circuits - maint_circuits + cargo_k + maint_k)
        cl_k = ec_k * 1000 * launch_cost * contingency / 1e6
        is_k = (insitu_total - insitu_circuits + insitu_k) * 1000 * insitu_cost_per_kg / 1e6
        ct_k = cl_k + is_k + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing
        circuit_npv[d_idx - 1] = compute_npv(rev_total, ct_k)
    sens.append(("Circuit: batch(0.4) vs cont(0.8)", circuit_npv[0] - baseline_npv, circuit_npv[1] - baseline_npv))

    npv_dr14 = np.sum(net_total / (1.014) ** Y) / 1e6
    npv_dr35 = np.sum(net_total / (1.035) ** Y) / 1e6
    sens.append(("Discount rate (1.4% vs 3.5%)", npv_dr14 - baseline_npv, npv_dr35 - baseline_npv))

    cl_hi = earth_cargo * 1000 * (launch_cost * 1.5) * contingency / 1e6
    ct_hi = cl_hi + cost_insitu + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing
    cl_lo = earth_cargo * 1000 * (launch_cost * 0.5) * contingency / 1e6
    ct_lo = cl_lo + cost_insitu + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing
    sens.append(("Launch cost (+50% vs -50%)", compute_npv(rev_total, ct_hi) - baseline_npv,
                 compute_npv(rev_total, ct_lo) - baseline_npv))

    rev_reo_lo = rev_direct + reo_target * 50000 / 1e6 + ext_h2 + ext_rockets + ext_geo
    rev_reo_hi = rev_direct + reo_target * 90000 / 1e6 + ext_h2 + ext_rockets + ext_geo
    sens.append(("REO extern ($50k vs $90k/t)", compute_npv(rev_reo_lo, cost_total) - baseline_npv,
                 compute_npv(rev_reo_hi, cost_total) - baseline_npv))

    h2_npv = np.zeros(2)
    for kidx in range(1, 3):
        attr_k = np.array([0.25, 1.00])
        a = attr_k[kidx - 1]
        ir_k = total_pgm * ir_frac * a
        pem_k = np.zeros(N)
        for i in range(2, N + 1):
            pem_k[i - 1] = pem_k[i - 2] + ir_k[i - 1] * pem_gw_per_t_ir
            if i > pem_life:
                pem_k[i - 1] = pem_k[i - 1] - ir_k[i - pem_life - 1] * pem_gw_per_t_ir
            pem_k[i - 1] = max(0, pem_k[i - 1])
        ext_h2_k = pem_k * h2_per_gw_yr * h2_co2_mult * scc / 1e6
        rev_k = rev_direct + ext_reo + ext_h2_k + ext_rockets + ext_geo
        h2_npv[kidx - 1] = compute_npv(rev_k, cost_total)
    sens.append(("H2 attribution (25% vs 100%)", h2_npv[0] - baseline_npv, h2_npv[1] - baseline_npv))

    geo_npv = np.zeros(2)
    for kidx in range(1, 3):
        gvals = np.array([0, 25000], dtype=float)
        gv = gvals[kidx - 1]
        ext_g_k = np.zeros(N)
        for i in range(1, N + 1):
            sf = reo_target[i - 1] / reo_demand[i - 1]
            if sf > geo_threshold:
                ext_g_k[i - 1] = gv * min(1, sf / 0.5)
        rev_k = rev_direct + ext_reo + ext_h2 + ext_rockets + ext_g_k
        geo_npv[kidx - 1] = compute_npv(rev_k, cost_total)
    sens.append(("Geo insurance ($0 vs $25B/yr)", geo_npv[0] - baseline_npv, geo_npv[1] - baseline_npv))

    maint_npv = np.zeros(2)
    for kidx in range(1, 3):
        mrates = np.array([0.005, 0.0025])
        mr = mrates[kidx - 1]
        maint_k = np.zeros(N)
        for i in range(1, N + 1):
            ef = min(1.0, max(0.008, 1.0 - (Y[i - 1] - 25) * 0.03))
            if Y[i - 1] >= 105:
                ef = max(0.03, ef - 0.07 * min(1, (Y[i - 1] - 105) / 10))
            if Y[i - 1] >= 125:
                ef = max(0.008, ef - 0.022 * min(1, (Y[i - 1] - 125) / 10))
            maint_k[i - 1] = circuits_needed[i - 1] * circuit["mass_kg"] * mr * ef / 1000
        ec_k = np.maximum(0, earth_cargo - maint_circuits + maint_k)
        cl_k = ec_k * 1000 * launch_cost * contingency / 1e6
        ct_k = cl_k + cost_insitu + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing
        maint_npv[kidx - 1] = compute_npv(rev_total, ct_k)
    sens.append(("Maint rate (0.5% vs 0.25%)", maint_npv[0] - baseline_npv, maint_npv[1] - baseline_npv))

    n_sens = len(sens)
    sens_names = [s[0] for s in sens]
    sens_lo = np.array([s[1] for s in sens])
    sens_hi = np.array([s[2] for s in sens])
    for k in range(1, n_sens + 1):
        pass

    # tornado print order (descending), 1-based like MATLAB
    sort_idx = np.argsort(-np.abs(sens_hi - sens_lo), kind="stable") + 1.0
    for k in range(1, n_sens + 1):
        j = int(sort_idx[k - 1])

    # ---- 4. TORNADO FIGURE (data only) ------------------------------------
    axc = np.array([.05, .08, .12])
    txc = np.array([.7, .8, .9])
    gc = np.array([.15, .2, .3])

    range_ = np.abs(sens_hi - sens_lo)
    sort_idx = np.argsort(range_, kind="stable") + 1.0
    for k in range(1, n_sens + 1):
        j = int(sort_idx[k - 1])
        lo_val = min(sens_lo[j - 1], sens_hi[j - 1])
        hi_val = max(sens_lo[j - 1], sens_hi[j - 1])

    out = dict(ws)
    local = dict(locals())
    local.pop("ws")
    local.pop("out")
    local.pop("local", None)
    local.pop("sens")        # a cell in MATLAB: never reaches the CSV
    local.pop("sens_names")  # cell
    local["range"] = local.pop("range_")
    out.update(local)
    return out


def workspace(script: str = "SELENITE_ECON_V1_4") -> dict:
    """Raw workspace after ``script`` ran (v1.4 includes the v1.3 state)."""
    ws = _v1_3()
    if script == "SELENITE_ECON_V1_3":
        return ws
    if script == "SELENITE_ECON_V1_4":
        return _v1_4(ws)
    raise KeyError(script)


def run_script(script: str) -> dict:
    """Flattened workspace as captured after ``script`` ran."""
    return flatten(workspace(script))


def run(**params):
    """Return the final (v1.4) flattened workspace."""
    return run_script("SELENITE_ECON_V1_4")


def report_lines() -> list[str]:
    """Headline figures from the v1.4 state, for ``selenite.report``."""
    r = run()
    return [
        f"Total cost (200 yr):        ${r['cum_cost'][-1] / 1e6:.2f} T",
        f"Total rev + extern:         ${r['cum_rev'][-1] / 1e6:.2f} T",
        f"NPV (all extern):           ${r['npv_total'][-1] / 1e6:.2f} T",
        f"NPV (direct only):          ${r['npv_direct'][-1] / 1e6:.2f} T",
        f"BCR (direct revenue only):  {r['bcr_direct']:.3f}",
        f"BCR (all externalities):    {r['bcr_total']:.3f}",
        f"IRR (all externalities):    {r['irr_total'] * 100:.2f}%",
        f"Circuits at Y200:           {r['circuits_needed'][-1]:.0f}",
        f"MSR count at Y200:          {r['msr_count'][-1]:.0f}",
    ]
