"""Parametrised ECON v1.3 (Wave 4A extension, NOT a port, no golden).

``selenite.econ._v1_3`` is a faithful port of ``SELENITE_ECON_V1_3.m`` with
every economic input written as a literal. The scenario work needs the same
model driven by sampled inputs, so this module repeats the v1.3 body with
every economic or scenario literal replaced by a field of :class:`Params`.
The loop structure and the floating-point operation order of ``econ.py`` are
preserved, so ``v1_3(Params())`` reproduces ``econ._v1_3()`` bit-for-bit at
the defaults (``tests/test_econ_param.py`` checks the whole workspace at a
relative tolerance of 1e-9, and the goldens stay with ``econ.py``, which is
untouched).

Year-indexed literals of ECON v1.3 (asteroid capture at Y75/Y95/Y115, the
ten-year lag to Y85/Y105/Y125, the DRO infrastructure drops, the Mk III
fleet reduction at Y115) are derived from the capture-year parameters so a
scenario that moves a capture moves the switches that ECON ties to the
arrival with it. Two things do not follow a moved capture: the hauler
M-type bonus year is its own field (``hauler_mtype_bonus_year``, ECON Y90),
and ``econ._v1_4``'s tornado keeps its literal Y105 / Y125 and circuit
Earth-fraction constants, so ``workspace(p)`` under a moved capture carries
a tornado that is v1.4's, not the scenario's. ``discount_rate_flat`` uses
the v1.3 discount-factor convention (cumulative product from Y0, so year 0
is discounted one period), which differs from v1.4's ``(1 + r) ** Y``
tornado convention by the factor 1 / (1 + r). The REO ramp is zero through
Y18 whatever knots ``reo_ramp`` carries (ECON's own clamp).

Three functions:

* ``v1_3(p)``      the ECON v1.3 workspace computed from ``p``;
* ``workspace(p)`` ``econ._v1_4(v1_3(p))``: v1.4's BCR, IRR and sensitivity
  tornado run unchanged on the parametrised workspace. The tornado
  perturbations (circuit design 1/2, 1.4 %/3.5 % discount rate, launch cost
  +-50 %, REO externality $50k/$90k, H2 attribution 25 %/100 %, geo
  insurance $0/$25B, maintenance 0.5 %/0.25 %) are v1.4's own definitions,
  not scenario inputs;
* ``metrics(ws)``  cheap headline measures of a v1.3 workspace without
  running v1.4.

Monetary values are in $M per year as in ECON (``npv_total_usd_b`` in the
metrics is converted to $B). Spelling is Australian throughout.
"""
from __future__ import annotations

import dataclasses
import math
from dataclasses import dataclass, field
from typing import Any

import numpy as np

from ..capture import StructArray
from ..econ import _interp_knots, _pos_diff, _v1_4

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

#: REO production ramps (t/yr at the knot years; log-linear in between,
#: capped at ``Params.reo_final``). ``"econ"`` is the ECON v1.3 ramp;
#: ``"decisionFramework"`` is the W3-N4 ramp with the DG-11.1 / DG-12.1 /
#: DG-13.1 years (100 kt at Y60, 500 kt at Y80, 1.25 Mt at Y120, 2.5 Mt at
#: Y180).
REO_RAMPS: dict[str, tuple[tuple[float, ...], tuple[float, ...]]] = {
    "econ": (
        (0, 15, 18, 25, 28, 35, 45, 60, 80, 100, 120, 140, 160, 180, 200),
        (0, 0, 0, 0.4, 125, 125, 1000, 10000, 100000, 250000, 500000, 1000000,
         1500000, 2500000, 2500000),
    ),
    "decisionFramework": (
        (0, 15, 18, 25, 28, 35, 45, 60, 80, 120, 180, 200),
        (0, 0, 0, 0.4, 125, 125, 1000, 100000, 500000, 1250000, 2500000, 2500000),
    ),
}

#: The ECON v1.3 circuit design table (index 1 batch, 2 continuous-flow,
#: 3 optimised).
CIRCUIT_DESIGNS: tuple[dict[str, Any], ...] = (
    {"name": "Batch (0.4 t/yr)", "reo_yr": 0.4, "mass_kg": 15000, "power_kw": 180},
    {"name": "Continuous-flow (0.8 t/yr)", "reo_yr": 0.8, "mass_kg": 22000, "power_kw": 300},
    {"name": "Optimised (1.2 t/yr)", "reo_yr": 1.2, "mass_kg": 28000, "power_kw": 400},
)


def _freeze(obj: Any) -> Any:
    """A hashable image of a parameter value (dicts become sorted tuples)."""
    if isinstance(obj, dict):
        return tuple((k, _freeze(v)) for k, v in sorted(obj.items()))
    if isinstance(obj, (list, tuple)):
        return tuple(_freeze(v) for v in obj)
    if isinstance(obj, np.ndarray):
        return (obj.shape, tuple(obj.reshape(-1).tolist()))
    return obj


@dataclass(frozen=True)
class Params:
    """Every economic / scenario input of ECON v1.3, with the v1.3 literals as
    defaults. Build variants with ``dataclasses.replace(Params(), ...)``.

    Years are programme years (Y0 = 2026 in the model). Fields that ECON
    writes as several literals (for instance the Y85 asteroid switches) are
    derived from the capture-year fields in :func:`v1_3`.
    """

    # ---- circuits -------------------------------------------------------
    circuit_design: int = 3                       # 1 batch, 2 continuous, 3 optimised
    circuit_designs: tuple[dict[str, Any], ...] = CIRCUIT_DESIGNS
    circuit_life_yr: float = 20
    circuit_maint_frac: float = 0.005
    circuit_earth_frac_floor: float = 0.10
    circuit_earth_frac_slope: float = 0.03
    circuit_earth_frac_start_year: float = 25
    ctype_reduction: float = 0.07                 # Earth-fraction cut once C-type is online
    ctype_floor: float = 0.03
    stype_reduction: float = 0.022                # further cut once S-type is online
    stype_floor: float = 0.008
    reduction_ramp_years: float = 10

    # ---- haulers --------------------------------------------------------
    hauler_mass_kg: float = 1450
    hauler_throughput_yr: float = 1500
    hauler_life_yr: float = 10
    hauler_maint_kg_yr: float = 9
    hauler_earth_frac_floor: float = 0.43
    hauler_earth_frac_slope: float = 0.0285
    hauler_earth_frac_start_year: float = 25
    hauler_mtype_bonus: float = 0.10
    hauler_mtype_bonus_year: float = 90
    hauler_mtype_bonus_ramp_years: float = 10
    hauler_earth_frac_min: float = 0.20

    # ---- conveyors, reactors, canisters, propellant ---------------------
    conv_mass_per_km: float = 100000
    conv_earth_frac: float = 0.05
    conv_maint_frac_yr: float = 0.005
    msr_power_mw: float = 100
    msr_mass_kg: float = 50000
    msr_life_yr: float = 20
    msr_earth_frac_floor: float = 0.3
    msr_earth_frac_start_year: float = 45
    msr_earth_frac_slope: float = 0.02
    fsp_power_kw: float = 40
    fsp_mass_kg: float = 6600
    can_reo_payload_t: float = 3.5
    can_earth_kg: float = 28
    molei_propellant_yr: float = 5692
    molei_mass_kg: float = 360
    molei_cargo_extra_kg: float = 27
    probe_propellant: float = 6654
    probe_mass_kg: float = 800
    probe_pgm_per_mission: float = 0.0175
    skip_propellant_yr: float = 83000
    skip_count: float = 8
    sinter_mass_kg: float = 2200
    armc_mass_kg: float = 1500
    reagent_per_circuit_yr: float = 49000
    reagent_isru_slope: float = 0.03
    reagent_isru_start_year: float = 9
    reagent_isru_cap: float = 0.98
    reo_ore_grade: float = 0.0005                 # t REO per t regolith (500 ppm)

    # ---- economic parameters --------------------------------------------
    launch_cost_eras: tuple[float, float, float] = (6000.0, 4000.0, 2000.0)   # $/kg
    launch_cost_era_years: tuple[float, float] = (25, 45)                      # also the contingency eras
    launch_cost_multiplier: float = 1.0
    discount_rates: tuple[float, float, float] = (0.03, 0.025, 0.02)
    discount_rate_years: tuple[float, float] = (30, 75)
    discount_rate_flat: float | None = None       # a flat rate every year (v1.4 tornado: 0.014 / 0.035)
    contingency_eras: tuple[float, float, float] = (1.50, 1.35, 1.25)
    insitu_cost_per_kg: float = 100
    scc: float = 190                              # social cost of carbon, $/t CO2
    rd_cost_eras: tuple[float, float, float, float] = (500, 1000, 1500, 2000)  # $M/yr
    rd_cost_era_years: tuple[float, float, float] = (25, 45, 60)
    leo_cost_per_kg: float = 500
    cost_dro_ops_per_yr: float = 200              # $M/yr from M-type online
    cost_asteroid_processing: tuple[float, float] = (500, 1300)  # $M/yr from C-type / S-type online

    # ---- REO ramp and market --------------------------------------------
    reo_final: float = 2500000                    # t/yr cap on the ramp
    reo_ramp: Any = "econ"                        # a REO_RAMPS key, or (knots_y, knots_v)
    reo_demand_2026: float = 400000
    reo_demand_growth: float = 0.02
    reo_demand_cap: float = 2500000
    reo_price_max: float = 15000
    reo_price_min: float = 5000
    reo_price_elasticity: float = 0.6
    pgm_price_per_t: float = 50e6
    reo_externality_per_t: float = 73700
    co2_per_t_reo: float = 30

    # ---- hydrogen externality --------------------------------------------
    ir_frac: float = 0.15
    h2_attribution: float = 0.50
    pem_gw_per_t_ir: float = 1.0
    h2_per_gw_yr: float = 150000
    h2_co2_mult: float = 12
    pem_life: int = 20

    # ---- rockets, geopolitics ---------------------------------------------
    co2_per_launch: float = 2750
    geo_insurance_per_yr: float = 15000
    geo_threshold: float = 0.01

    # ---- asteroid programme ----------------------------------------------
    mtype_capture_year: float = 75
    ctype_capture_year: float = 95
    stype_capture_year: float = 115
    asteroid_online_lag: float = 10
    spa_msr_third_year: float = 140
    mtype_pgm_t_yr: float = 36.5
    mkiii_target: float = 1714
    mkiii_mass_kg: float = 1200
    mkiii_life: float = 15
    mkiii_build_start: float = 60
    mkiii_build_end: float = 80
    mkiii_prospecting: float = 300
    tug_mass_kg: float = 50000
    tug_life: float = 20

    def __post_init__(self) -> None:
        if not 1 <= int(self.circuit_design) <= len(self.circuit_designs):
            raise ValueError(f"circuit_design {self.circuit_design!r} is not an index into circuit_designs")
        if isinstance(self.reo_ramp, str) and self.reo_ramp not in REO_RAMPS:
            raise KeyError(f"reo_ramp {self.reo_ramp!r}: known ramps are {sorted(REO_RAMPS)}")

    def __hash__(self) -> int:  # the circuit table holds dicts
        return hash(tuple(_freeze(getattr(self, f.name)) for f in dataclasses.fields(self)))

    @property
    def mtype_online(self) -> float:
        return self.mtype_capture_year + self.asteroid_online_lag

    @property
    def ctype_online(self) -> float:
        return self.ctype_capture_year + self.asteroid_online_lag

    @property
    def stype_online(self) -> float:
        return self.stype_capture_year + self.asteroid_online_lag

    def reo_knots(self) -> tuple[tuple[float, ...], tuple[float, ...]]:
        """(knots_y, knots_v) of the selected REO ramp."""
        if isinstance(self.reo_ramp, str):
            return REO_RAMPS[self.reo_ramp]
        ky, kv = self.reo_ramp
        return tuple(ky), tuple(kv)


def _design_dict(cd: Any) -> dict[str, Any]:
    """A circuit design as the dict ECON's StructArray holds."""
    if isinstance(cd, dict):
        return dict(cd)
    return {k: getattr(cd, k) for k in ("name", "reo_yr", "mass_kg", "power_kw")}


def _add_at_year(arr: np.ndarray, year: float, value: float) -> None:
    """Add ``value`` to the year-``year`` slot (years outside Y0..Y200 are dropped)."""
    k = int(round(year))
    if 0 <= k < arr.shape[0]:
        arr[k] += value


def v1_3(p: Params) -> dict:
    """The ECON v1.3 workspace computed from ``p`` (``econ._v1_3`` with every
    literal replaced by a field of ``p``; identical results at the defaults).
    The workspace also carries ``params`` (``p``) and the derived
    ``mtype_online`` / ``ctype_online`` / ``stype_online`` years."""
    # ---- derived years -------------------------------------------------------
    mtype_online = p.mtype_capture_year + p.asteroid_online_lag        # Y85
    ctype_online = p.ctype_capture_year + p.asteroid_online_lag        # Y105
    stype_online = p.stype_capture_year + p.asteroid_online_lag        # Y125
    molei_saving_year = ctype_online + 5                                # Y110
    mkiii_reduction_year = p.stype_capture_year                         # Y115
    tug_first_year = p.mtype_capture_year - 10                          # Y65

    # ---- 1. UNIT SPECIFICATIONS --------------------------------------------
    circuit_designs = StructArray([_design_dict(cd) for cd in p.circuit_designs])
    CIRCUIT_DESIGN = int(p.circuit_design)

    circuit = {
        "reo_yr": circuit_designs[CIRCUIT_DESIGN - 1]["reo_yr"],
        "mass_kg": circuit_designs[CIRCUIT_DESIGN - 1]["mass_kg"],
        "power_kw": circuit_designs[CIRCUIT_DESIGN - 1]["power_kw"],
        "life_yr": p.circuit_life_yr,
        "maint_frac": p.circuit_maint_frac,
        "earth_frac": lambda y: min(1.0, max(p.circuit_earth_frac_floor,
                                             1.0 - (y - p.circuit_earth_frac_start_year) * p.circuit_earth_frac_slope)),
    }

    hauler = {"mass_kg": p.hauler_mass_kg, "throughput_yr": p.hauler_throughput_yr, "life_yr": p.hauler_life_yr,
              "maint_kg_yr": p.hauler_maint_kg_yr,
              "earth_frac": lambda y: min(1.0, max(p.hauler_earth_frac_floor,
                                                   1.0 - (y - p.hauler_earth_frac_start_year) * p.hauler_earth_frac_slope))}
    conv = {"mass_per_km": p.conv_mass_per_km, "earth_frac": p.conv_earth_frac, "maint_frac_yr": p.conv_maint_frac_yr}
    msr = {"power_mw": p.msr_power_mw, "mass_kg": p.msr_mass_kg, "life_yr": p.msr_life_yr,
           "earth_frac": lambda y: max(p.msr_earth_frac_floor,
                                       min(1.0, 1.0 - (y - p.msr_earth_frac_start_year) * p.msr_earth_frac_slope))}
    fsp = {"power_kw": p.fsp_power_kw, "mass_kg": p.fsp_mass_kg}
    can = {"reo_payload_t": p.can_reo_payload_t, "earth_kg": p.can_earth_kg}
    molei = {"propellant_yr": p.molei_propellant_yr, "mass_kg": p.molei_mass_kg}
    probe = {"propellant": p.probe_propellant, "mass_kg": p.probe_mass_kg, "pgm_per_mission": p.probe_pgm_per_mission}
    skip = {"propellant_yr": p.skip_propellant_yr, "count": p.skip_count}
    sinter = {"mass_kg": p.sinter_mass_kg}
    armc = {"mass_kg": p.armc_mass_kg}
    reagent = {"per_circuit_yr": p.reagent_per_circuit_yr,
               "isru_frac": lambda y: min(p.reagent_isru_cap,
                                          max(0, (y - p.reagent_isru_start_year) * p.reagent_isru_slope))}

    # ---- 2. ECONOMIC PARAMETERS --------------------------------------------
    Y = np.arange(0, 201, dtype=float)
    N = len(Y)

    lc0, lc1, lc2 = p.launch_cost_eras
    era0, era1 = p.launch_cost_era_years
    launch_cost = np.array([lc0 * (y < era0) + lc1 * (era0 <= y < era1) + lc2 * (y >= era1) for y in Y],
                           dtype=float) * p.launch_cost_multiplier
    if p.discount_rate_flat is None:
        dr0, dr1, dr2 = p.discount_rates
        dy0, dy1 = p.discount_rate_years
        dr = np.array([dr0 * (y <= dy0) + dr1 * (dy0 < y <= dy1) + dr2 * (y > dy1) for y in Y])
    else:
        dr = np.full(N, float(p.discount_rate_flat))
    df = np.cumprod(1.0 / (1.0 + dr))
    ct0, ct1, ct2 = p.contingency_eras
    contingency = np.array([ct0 * (y < era0) + ct1 * (era0 <= y < era1) + ct2 * (y >= era1) for y in Y])

    insitu_cost_per_kg = p.insitu_cost_per_kg
    scc = p.scc

    # ---- 3. REO RAMP -------------------------------------------------------
    reo_final = p.reo_final
    knots_y, knots_v = p.reo_knots()
    reo_knots_y = np.array(knots_y, dtype=float)
    reo_knots_v = np.array(knots_v, dtype=float)

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
    regolith_yr = reo_target / p.reo_ore_grade
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
    cargo_molei = d_molei * (molei["mass_kg"] + p.molei_cargo_extra_kg) / 1000
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

    # ECON writes the ARMC / sinter masses as literals (1500, 2200) here.
    cargo_armc = armc_needed * armc["mass_kg"] / 1000
    cargo_sinter_build = sinter_needed_build * sinter["mass_kg"] / 1000
    cargo_sentinel = d_sentinel * 80 / 1000
    cargo_hubs = d_hubs * 5000 * 0.05 / 1000

    maint_armc = np.zeros(N)
    maint_sinter = np.zeros(N)
    maint_sentinel = np.zeros(N)
    for i in range(1, N + 1):
        active_armc = max(20, armc_needed[i - 1])
        active_sinter = max(50, sinter_needed_build[i - 1])
        maint_armc[i - 1] = active_armc / 10 * armc["mass_kg"] / 1000
        maint_sinter[i - 1] = active_sinter / 15 * sinter["mass_kg"] / 1000
        maint_sentinel[i - 1] = sentinel_needed[i - 1] / 10 * 80 / 1000

    cargo_construction_fleet = (cargo_armc + cargo_sinter_build + cargo_sentinel + cargo_hubs
                                + maint_armc + maint_sinter + maint_sentinel)

    # PROBE Mk III SEP fleet
    mkiii_target = p.mkiii_target
    mkiii_mass_kg = p.mkiii_mass_kg
    mkiii_life = p.mkiii_life
    mkiii_build_years = p.mkiii_build_end - p.mkiii_build_start                # 20
    mkiii_active = np.zeros(N)
    mkiii_build = np.zeros(N)
    mkiii_pgm = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        if p.mkiii_build_start <= y < p.mkiii_build_end:
            mkiii_active[i - 1] = min(mkiii_target, (y - p.mkiii_build_start) / mkiii_build_years * mkiii_target)
            mkiii_build[i - 1] = mkiii_target / mkiii_build_years
        elif p.mkiii_build_end <= y < mkiii_reduction_year:
            mkiii_active[i - 1] = mkiii_target
        elif y >= mkiii_reduction_year:
            mkiii_active[i - 1] = p.mkiii_prospecting
        mkiii_replace = mkiii_active[i - 1] / mkiii_life
        mkiii_pgm[i - 1] = mkiii_active[i - 1] * probe["pgm_per_mission"] * 0.5
    cargo_mkiii_leo = np.zeros(N)
    for i in range(1, N + 1):
        build = 0
        if p.mkiii_build_start <= Y[i - 1] < p.mkiii_build_end:
            build = mkiii_target / mkiii_build_years
        cargo_mkiii_leo[i - 1] = (build + mkiii_active[i - 1] / mkiii_life) * mkiii_mass_kg / 1000

    # Asteroid redirect tugs
    tug_mass_kg = p.tug_mass_kg
    tug_life = p.tug_life
    tug_fleet = np.array([0 * (y < tug_first_year) + 2 * (tug_first_year <= y < mtype_online)
                          + 3 * (mtype_online <= y < ctype_online) + 5 * (y >= ctype_online) for y in Y],
                         dtype=float)
    d_tugs = _pos_diff(tug_fleet)
    cargo_tugs_leo = (d_tugs + tug_fleet / tug_life) * tug_mass_kg / 1000

    # DRO infrastructure drops (ECON: Y70, Y80, Y85, Y95, Y105, Y115, Y125)
    cargo_dro_infra = np.zeros(N)
    _add_at_year(cargo_dro_infra, p.mtype_capture_year - 5, 110)
    _add_at_year(cargo_dro_infra, mtype_online - 5, 50)
    _add_at_year(cargo_dro_infra, mtype_online, 50)
    _add_at_year(cargo_dro_infra, p.ctype_capture_year, 30)
    _add_at_year(cargo_dro_infra, ctype_online, 40)
    _add_at_year(cargo_dro_infra, p.stype_capture_year, 30)
    _add_at_year(cargo_dro_infra, stype_online, 60)

    spa_msr_count = np.array([0 * (y < ctype_online) + 1 * (ctype_online <= y < stype_online)
                              + 2 * (stype_online <= y < p.spa_msr_third_year) + 3 * (y >= p.spa_msr_third_year)
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
        if Y[i - 1] >= mtype_online:
            captured_asteroid_pgm[i - 1] = p.mtype_pgm_t_yr

    # Circuit Earth fraction reduction from asteroid resources
    insitu_circuits = np.zeros(N)
    for i in range(1, N + 1):
        y = Y[i - 1]
        ef_base = circuit["earth_frac"](y)
        if y >= ctype_online:
            ctype_reduction = p.ctype_reduction * min(1, (y - ctype_online) / p.reduction_ramp_years)
            ef_base = max(p.ctype_floor, ef_base - ctype_reduction)
        if y >= stype_online:
            stype_reduction = p.stype_reduction * min(1, (y - stype_online) / p.reduction_ramp_years)
            ef_base = max(p.stype_floor, ef_base - stype_reduction)
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
    reo_demand_2026 = p.reo_demand_2026
    reo_demand = reo_demand_2026 * (1 + p.reo_demand_growth) ** Y
    reo_demand = np.minimum(reo_demand, p.reo_demand_cap)
    supply_frac = reo_target / reo_demand
    reo_price = np.maximum(p.reo_price_min, p.reo_price_max * (1 - p.reo_price_elasticity * supply_frac))

    rev_reo = reo_target * reo_price / 1e6
    total_pgm = pgm_production + mkiii_pgm + captured_asteroid_pgm
    rev_pgm = total_pgm * p.pgm_price_per_t / 1e6
    rev_direct = rev_reo + rev_pgm

    ext_reo = reo_target * p.reo_externality_per_t / 1e6
    co2_avoided_reo = reo_target * p.co2_per_t_reo

    ir_frac = p.ir_frac
    h2_attribution = p.h2_attribution
    pem_gw_per_t_ir = p.pem_gw_per_t_ir
    h2_per_gw_yr = p.h2_per_gw_yr
    h2_co2_mult = p.h2_co2_mult
    pem_life = int(p.pem_life)
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
    co2_rockets = total_launches * p.co2_per_launch * fossil_frac
    ext_rockets = -co2_rockets * scc / 1e6

    geo_insurance_per_yr = p.geo_insurance_per_yr
    geo_threshold = p.geo_threshold
    ext_geo = np.zeros(N)
    for i in range(1, N + 1):
        if supply_frac[i - 1] > geo_threshold:
            ext_geo[i - 1] = geo_insurance_per_yr * min(1, supply_frac[i - 1] / 0.5)

    ext_total = ext_reo + ext_h2 + ext_rockets + ext_geo
    rev_total = rev_direct + ext_total

    # ---- 7. COST MODEL -----------------------------------------------------
    cost_insitu = insitu_total * 1000 * insitu_cost_per_kg / 1e6
    rd0, rd1, rd2, rd3 = p.rd_cost_eras
    rdy0, rdy1, rdy2 = p.rd_cost_era_years
    cost_rd = np.array([rd0 * (y < rdy0) + rd1 * (rdy0 <= y < rdy1) + rd2 * (rdy1 <= y < rdy2) + rd3 * (y >= rdy2)
                        for y in Y], dtype=float)

    leo_cost_per_kg = p.leo_cost_per_kg
    cost_mkiii = cargo_mkiii_leo * 1000 * leo_cost_per_kg * contingency / 1e6
    cost_tugs = cargo_tugs_leo * 1000 * leo_cost_per_kg * contingency / 1e6

    cost_dro_ops = np.array([0 * (y < mtype_online) + p.cost_dro_ops_per_yr * (y >= mtype_online) for y in Y],
                            dtype=float)
    cap0, cap1 = p.cost_asteroid_processing
    cost_asteroid_processing = np.array([0 * (y < ctype_online) + cap0 * (ctype_online <= y < stype_online)
                                         + cap1 * (y >= stype_online) for y in Y], dtype=float)

    maint_molei_saving = np.zeros(N)
    for i in range(1, N + 1):
        if Y[i - 1] >= molei_saving_year:
            current_molei = molei_needed[i - 1]
            reduced_molei = 50
            saved = max(0, current_molei - reduced_molei)
            maint_molei_saving[i - 1] = saved * molei["mass_kg"] * 0.02 / 1000

    for i in range(1, N + 1):
        if Y[i - 1] >= p.hauler_mtype_bonus_year:
            mtype_bonus = p.hauler_mtype_bonus * min(1, (Y[i - 1] - p.hauler_mtype_bonus_year)
                                                     / p.hauler_mtype_bonus_ramp_years)
            ef_h = hauler["earth_frac"](Y[i - 1]) - mtype_bonus
            ef_h = max(p.hauler_earth_frac_min, ef_h)
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

    # ---- 9. CIRCUIT THROUGHPUT SENSITIVITY (ECON's own 2 % maintenance) ----
    for d in range(1, len(circuit_designs) + 1):
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

    # ---- 10. OTHER SENSITIVITIES (ECON's own perturbations) ----------------
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
    reg_25 = reo_25 / p.reo_ore_grade
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
        ef = circuit["earth_frac"](y)
        if y >= ctype_online:
            ef = max(p.ctype_floor, ef - p.ctype_reduction * min(1, (y - ctype_online) / p.reduction_ramp_years))
        if y >= stype_online:
            ef = max(p.stype_floor, ef - p.stype_reduction * min(1, (y - stype_online) / p.reduction_ramp_years))
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
    rp_25 = np.maximum(p.reo_price_min, p.reo_price_max * (1 - p.reo_price_elasticity * sf_25))
    rr_25 = reo_25 * rp_25 / 1e6
    er_25 = reo_25 * p.reo_externality_per_t / 1e6
    co2_reo_25 = reo_25 * p.co2_per_t_reo
    eg_25 = np.zeros(N)
    for i in range(1, N + 1):
        if sf_25[i - 1] > geo_threshold:
            eg_25[i - 1] = geo_insurance_per_yr * min(1, sf_25[i - 1] / 0.5)
    tl_25 = (ec_25 / 100) * tanker_ratio
    cr_25 = tl_25 * p.co2_per_launch * fossil_frac
    exr_25 = -cr_25 * scc / 1e6

    rv_25 = rr_25 + rev_pgm + er_25 + ext_h2 + eg_25 + exr_25
    npv_25 = np.sum((rv_25 - ct_25) * df)

    i200 = 201

    net_25 = rv_25 - ct_25

    ws = dict(locals())
    for name in ("val", "left", "frac_", "p", "knots_y", "knots_v", "lc0", "lc1", "lc2", "era0", "era1",
                 "dr0", "dr1", "dr2", "dy0", "dy1", "ct0", "ct1", "ct2", "rd0", "rd1", "rd2", "rd3",
                 "rdy0", "rdy1", "rdy2", "cap0", "cap1"):
        ws.pop(name, None)
    ws["params"] = p
    return ws


def workspace(p: Params = Params()) -> dict:
    """``econ._v1_4(v1_3(p))``: the v1.3 workspace plus v1.4's BCR, IRR and
    sensitivity tornado (v1.4's own perturbation definitions, unchanged)."""
    return _v1_4(v1_3(p))


def metrics(ws: dict) -> dict:
    """Headline measures of a v1.3 workspace without running v1.4.

    ``pv_cost``, ``pv_rev_direct``, ``pv_rev_total`` ($M, discounted with the
    workspace's ``df``), ``bcr_direct``, ``bcr_total``, ``npv_total_usd_b``
    and ``npv_direct_usd_b`` ($B, the Y200 cumulative NPV), ``cum_earth_cargo_t``
    (t over 200 years), ``cum_co2_rockets_t`` (t CO2) and ``cum_launches``.
    """
    df = ws["df"]
    pv_cost = float(np.sum(ws["cost_total"] * df))
    pv_rev_direct = float(np.sum(ws["rev_direct"] * df))
    pv_rev_total = float(np.sum(ws["rev_total"] * df))
    return {
        "pv_cost": pv_cost,
        "pv_rev_direct": pv_rev_direct,
        "pv_rev_total": pv_rev_total,
        "bcr_direct": pv_rev_direct / pv_cost,
        "bcr_total": pv_rev_total / pv_cost,
        "npv_total_usd_b": float(ws["npv_total"][-1] / 1e3),
        "npv_direct_usd_b": float(ws["npv_direct"][-1] / 1e3),
        "cum_earth_cargo_t": float(ws["earth_cargo"].sum()),
        "cum_co2_rockets_t": float(ws["co2_rockets"].sum()),
        "cum_launches": float(ws["total_launches"].sum()),
    }
