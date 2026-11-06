"""D1 - the SPA eclipse operating strategy for the asteroid-processing loads.

Wave 4A extension (6 Nov 2026), NOT a port, no golden. ECN-022 s.2.4 bound
``spaAsteroidLoadCriticalFraction = 1.0``: the C-type pyrolysis and
Fischer-Tropsch loads (50 MWe from the C-type arrival) and the S-type
Czochralski silicon loads (100 MWe from the S-type arrival, +100 MWe scaled
operations at Y140; Decision Framework Rev D s.10.1) are carried through the
72 h SPA eclipse. Jason's reading (19 Sep 2026): that is only needed if the
power-intensive work cannot be scheduled outside the eclipse, which makes the
fraction an operating strategy. This module evaluates the four strategies of
``SeleniteScenarios::EclipseOperatingStrategy`` on every sample of the
uncertainty register, with the FSP-versus-MSR count as the recourse
(``plan_vectors.fsp_msr_trade`` re-derived per sample):

* A ``carryThroughEclipse`` - every asteroid load eclipse-critical.
* B ``sunlitDutyCycle``    - pausable steps run only in sunlight; the plant is
  oversized by 1 / ((1 - dark fraction)(1 - restart loss)) so annual
  throughput is kept despite the dark time and the output lost to restarts;
  only the hold loads - a fraction of the oversized plant's rated load - go
  through the eclipse.
* C ``hotStandby``         - as B but no oversize: throughput falls by the dark
  fraction plus restart losses.
* D ``hybridStorage``      - a chosen fraction (``hybridStoredLoadFraction``)
  keeps running on battery (VERIFY rule: shortfall x hours x 1.2 at 250
  Wh/kg); the remainder follows the sunlit duty cycle.

Two worlds decide the trade. When the SPA MSR is available at the C-type
arrival (the committed plan, ``spaMsrAvailabilityProbability`` 1.0) the MSR -
sized to the total load - carries the asteroid loads through every eclipse,
so carry-through costs nothing extra and the other strategies pay their
oversize plant, battery or throughput. When it is not (the thorium line fails
its tests or ThCl4 never ships), the strategy sizes the FSP fleet: 6,254
units under carry-through at Y140 against a few hundred under a duty cycle.
The register prints both worlds and the break-even probability.

Lost asteroid throughput is charged where ECON values the asteroid lines:
their output is what lets the circuit Earth fraction fall (0.10 to 0.03
after the C-type, to 0.008 after the S-type, ECON v1.3 ``insitu_circuits``).
A strategy that delivers a fraction ``1 - lost`` of a line's planned output
scales that line's reduction by the same fraction, so the programme's
Earth-launched mass and NPV carry the loss (``run.evaluate_d1`` re-runs the
parametrised ECON with the scaled reductions). The duty-cycle strategies
oversize the plant for the dark fraction and the restart losses, so they
keep the planned output; hot standby does not.

Declared working assumptions (no process source; Parameters.sysml docs name
what would bind them; the register marks them ASSUMED):
``ASSUMED_HOLD_LOAD_FRACTION`` and ``ASSUMED_RESTART_LOSS_DAYS``. Changing
one is an ECN to this module; the named scenarios ``holdLoadLow`` /
``holdLoadHigh`` carry the sensitivity.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache

import numpy as np

from .. import plan_vectors as pv
from .. import verify

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

STRATEGIES = ("carryThroughEclipse", "sunlitDutyCycle", "hotStandby", "hybridStorage")

# Working assumptions (ASSUMED in the register). A quarter of rated load to
# hold a paused thermal process warm is conservative against the duty-cycle
# strategies: external analogues (holding furnaces at ~7-10 % of melting
# power per tonne) sit at the low end of the holdLoadLow / holdLoadHigh
# scenario range 0.05-0.50.
ASSUMED_HOLD_LOAD_FRACTION = {"cTypeLine": 0.25, "sTypeLine": 0.25, "scaledOperations": 0.25}
ASSUMED_RESTART_LOSS_DAYS = 0.5          # days of output lost per restart after an eclipse pause
HOURS_PER_YEAR = 8760.0
SCALED_OPERATIONS_YEAR = 140             # Decision Framework s.10.1 "Y140: +1 MSR - scaled operations"
P7_INDEX = pv.P7_INDEX
NEVER = 200                              # "never" on the Y0..Y200 horizon, for slips and gate years


@dataclass(frozen=True)
class LoadBlock:
    """One Decision Framework s.10.1 asteroid-processing load."""
    line: str
    year: int
    kw: float
    batch_scheduled: bool   # Czochralski: whole batches between eclipses, no hold


@dataclass(frozen=True)
class SiteConstants:
    """Sample-invariant VERIFY / ECON vectors and constants the trade reads."""
    Y: np.ndarray
    base_critical_kw: np.ndarray     # spa_critical_power without asteroid loads
    base_total_kw_sub: np.ndarray    # spa_power p_sub without asteroid loads (before contingency)
    contingency: float
    solar_yield_kwm2: float
    p7_fsp_units: float
    p7_panel_kg: float
    msr_rated_kw: float
    msr_earth_frac_start_year: float
    msr_earth_frac_slope: float


def site_constants(w: dict, v: dict, msr_rated_kw: float) -> SiteConstants:
    """Sample-invariant SPA power vectors; cached per MSR rating (the
    VERIFY and ECON workspaces behind them are deterministic)."""
    return _site_constants(float(msr_rated_kw))


@lru_cache(maxsize=4)
def _site_constants(msr_rated_kw: float) -> SiteConstants:
    v = verify.workspace()
    cp = pv.spa_critical_power(0.0)
    sp = pv.spa_power(with_asteroid_loads=False)
    return SiteConstants(
        Y=cp["Y"], base_critical_kw=cp["p_critical_base"],
        base_total_kw_sub=sp["p_tot"] / 1.20, contingency=0.20,
        solar_yield_kwm2=float(v["solar"]["yield_kWm2"]),
        p7_fsp_units=float(v["ecl"]["nfsp"][P7_INDEX]), p7_panel_kg=float(v["ph"]["panel_kg"][P7_INDEX]),
        msr_rated_kw=msr_rated_kw, msr_earth_frac_start_year=45.0, msr_earth_frac_slope=0.02)


def load_blocks(c_online: int, s_online: int, scaled_year: int = SCALED_OPERATIONS_YEAR) -> list[LoadBlock]:
    """Decision Framework s.10.1 loads placed on the sampled arrival years."""
    kw = dict(pv.DF_ASTEROID_PROCESSING_KW)
    return [LoadBlock("cTypeLine", int(c_online), kw[105], False),
            LoadBlock("sTypeLine", int(s_online), kw[125], True),
            LoadBlock("scaledOperations", int(scaled_year), kw[140], False)]


@dataclass(frozen=True)
class StrategyProfile:
    """Per-block factors of one strategy on one sample."""
    carried_fraction: float      # share of the block carried through the eclipse by any means (the derived twin)
    fsp_fraction: float          # share FSP must carry (battery carries the rest of carried_fraction)
    stored_fraction: float       # share on battery
    oversize_factor: float       # plant rating multiplier to keep annual throughput
    throughput_lost: float       # fraction of annual throughput lost


def profile(strategy: str, block: LoadBlock, dark: float, hold: float, stored: float,
            restart_days: float, batch_hours: float, eclipse_hours: float) -> StrategyProfile:
    """The per-block factors of a strategy. ``eclipse_hours`` is the sampled
    longest eclipse: the dark fraction divided by it is the fewest, longest
    eclipses a year (a lower bound on restarts, W4A-N7). The hold load is a
    fraction of the plant's RATED load, so under a duty cycle it scales with
    the oversize factor (SeleniteAnalysis::EclipseCriticalFraction)."""
    eclipses_per_year = dark * HOURS_PER_YEAR / eclipse_hours
    restart_loss = eclipses_per_year * restart_days / 365.0
    if block.batch_scheduled:
        # Czochralski: no hold (cold between batches); the cost is scheduling
        # slack of half a batch before each eclipse.
        hold = 0.0
        restart_loss = eclipses_per_year * (batch_hours / 2.0) / HOURS_PER_YEAR
    # A duty-cycled plant keeps its annual throughput when it is oversized for
    # the dark fraction AND for the output lost to restarts (or batch slack).
    keep = 1.0 / ((1.0 - dark) * (1.0 - restart_loss))
    if strategy == "carryThroughEclipse":
        return StrategyProfile(1.0, 1.0, 0.0, 1.0, 0.0)
    if strategy == "sunlitDutyCycle":
        return StrategyProfile(hold * keep, hold * keep, 0.0, keep, 0.0)
    if strategy == "hotStandby":
        return StrategyProfile(hold, hold, 0.0, 1.0, dark + restart_loss)
    if strategy == "hybridStorage":
        rest = 1.0 - stored
        return StrategyProfile(stored + rest * hold * keep, rest * hold * keep, stored, 1.0 + rest * (keep - 1.0), 0.0)
    raise KeyError(strategy)


def msr_earth_fraction(Y: np.ndarray, floor: float, start: float = 45.0, slope: float = 0.02) -> np.ndarray:
    """ECON v1.3 msr.earth_frac with the floor as an input."""
    return np.maximum(floor, np.minimum(1.0, 1.0 - (Y - start) * slope))


@dataclass
class SampleInputs:
    dark: float
    longest_eclipse_h: float
    design_eclipse_h: float
    batch_hours: float
    oversize_kg_per_kw: float
    restart_days: float
    hold: dict[str, float]
    stored: float
    msr_available: bool
    fsp_kw: float
    fsp_kg: float
    batt_wh_kg: float
    batt_margin: float
    panel_kg_m2: float
    thcl4_year: float
    solar_in_situ_year: float
    solar_in_situ_ef: float
    msr_mass_kg: float
    msr_ef_floor: float
    c_online: int
    s_online: int
    plant_earth_fraction: np.ndarray    # by year (ECON circuit Earth fraction or the scenario's constant)
    launch_cost: np.ndarray             # $/kg by year (sampled multiplier applied)
    contingency: np.ndarray
    df: np.ndarray


def evaluate_strategy(strategy: str, x: SampleInputs, c: SiteConstants) -> dict[str, float]:
    """One strategy on one sample: the SPA power-side masses under the
    FSP-versus-MSR recourse, the gate years and the derived critical fraction."""
    Y = c.Y
    blocks = load_blocks(x.c_online, x.s_online)
    carried = np.zeros_like(c.base_critical_kw)
    fsp_sized = np.zeros_like(carried)
    battery_kwh = 0.0
    battery_cargo_kg = np.zeros_like(carried)       # each block's battery in the block's year
    oversize_kw = np.zeros_like(carried)
    oversize_mass_kg = np.zeros_like(carried)       # Earth-launched, placed in the block's year
    lost_weight = 0.0
    load_weight = 0.0
    carried_weight = 0.0
    profiles = []
    for b in blocks:
        pr = profile(strategy, b, x.dark, x.hold[b.line], x.stored, x.restart_days,
                     x.batch_hours, x.longest_eclipse_h)
        profiles.append(pr)
        on = Y >= b.year
        carried[on] += b.kw * pr.carried_fraction
        fsp_sized[on] += b.kw * pr.fsp_fraction
        block_kwh = b.kw * pr.stored_fraction * x.longest_eclipse_h * x.batt_margin
        battery_kwh += block_kwh
        if b.year <= NEVER:
            battery_cargo_kg[b.year] += block_kwh * 1000.0 / x.batt_wh_kg
        extra_kw = b.kw * (pr.oversize_factor - 1.0)
        oversize_kw[on] += extra_kw
        if b.year <= NEVER:
            oversize_mass_kg[b.year] += extra_kw * x.oversize_kg_per_kw * x.plant_earth_fraction[b.year]
        lost_weight += b.kw * pr.throughput_lost
        load_weight += b.kw
        carried_weight += b.kw * pr.carried_fraction
    battery_kg = battery_kwh * 1000.0 / x.batt_wh_kg

    # Non-nuclear alternative (incremental basis: the P7 as-built fleet is sunk).
    critical_kw = c.base_critical_kw + fsp_sized
    nfsp = np.ceil(critical_kw / x.fsp_kw)
    fsp_mass = np.maximum(0.0, nfsp - c.p7_fsp_units) * x.fsp_kg
    asteroid_total_kw = np.zeros_like(carried)
    for b, pr in zip(blocks, profiles):
        asteroid_total_kw[Y >= b.year] += b.kw * pr.oversize_factor
    p_tot = (c.base_total_kw_sub + asteroid_total_kw) * (1.0 + c.contingency)
    panel_m2 = p_tot / c.solar_yield_kwm2
    solar_ef = np.where(Y >= x.solar_in_situ_year, x.solar_in_situ_ef, 1.0)
    solar_mass = np.maximum(0.0, panel_m2 * x.panel_kg_m2 - c.p7_panel_kg) * solar_ef
    nonnuclear = fsp_mass + solar_mass

    # Nuclear alternative sized to the total load; Earth fraction with the sampled floor.
    units = np.maximum(1.0, np.ceil(p_tot / c.msr_rated_kw))
    ef = msr_earth_fraction(Y, x.msr_ef_floor, c.msr_earth_frac_start_year, c.msr_earth_frac_slope)
    msr_earth = units * x.msr_mass_kg * ef
    worth = nonnuclear > msr_earth
    justified = worth & (Y >= x.thcl4_year) & (Y >= 18) & x.msr_available
    idx = np.flatnonzero(justified)
    first = int(idx[0]) if idx.size else None

    # Earth-launched mass of the SPA power side under the recourse policy:
    # the non-nuclear fleet built before the MSR year (hardware is sunk, so
    # cargo is the growth of the RUNNING MAXIMUM of the fleet the load needs
    # - a load that falls and regrows re-uses the fleet already built), the
    # MSR units built from that year (ECON cargo rule: increments of the
    # running maximum x mass x Earth fraction in the build year), each
    # block's battery in the block's year and the oversize plant.
    cut = NEVER + 1 if first is None else first
    nn_cargo_kg = np.zeros_like(carried)
    nn_built_kg = 0.0
    if cut > 0:
        built = np.maximum.accumulate(fsp_mass[:cut] + solar_mass[:cut])
        nn_cargo_kg[:cut] = np.diff(np.concatenate([[0.0], built]))
        nn_built_kg = float(built[-1])
    fsp_built_kg = float(np.maximum.accumulate(fsp_mass[:cut])[-1]) if cut > 0 else 0.0
    solar_built_kg = float(np.maximum.accumulate(solar_mass[:cut])[-1]) if cut > 0 else 0.0
    msr_cargo_kg = np.zeros_like(carried)
    if first is not None:
        built_units = np.maximum.accumulate(units[first:])
        d_units = np.diff(np.concatenate([[0.0], built_units]))
        msr_cargo_kg[first:] = d_units * x.msr_mass_kg * ef[first:]
    cargo_kg = nn_cargo_kg + msr_cargo_kg + battery_cargo_kg + oversize_mass_kg
    earth_mass_t = float(cargo_kg.sum()) / 1000.0
    npv_delta_usd_m = -float(np.sum(cargo_kg * x.launch_cost * x.contingency * x.df)) / 1e6

    def unit_year(k: int):
        if first is None:
            return None
        hit = np.flatnonzero((units >= k) & (Y >= first))
        return int(hit[0]) if hit.size else None

    lost_by_line = {b.line: pr.throughput_lost for b, pr in zip(blocks, profiles)}
    return {
        "earthMassSpaPowerTonnes": earth_mass_t,
        "throughputLostCTypeLine": lost_by_line.get("cTypeLine", 0.0),
        "throughputLostSTypeLine": lost_by_line.get("sTypeLine", 0.0),
        "throughputLostScaledOperations": lost_by_line.get("scaledOperations", 0.0),
        "nonNuclearBuiltTonnes": nn_built_kg / 1000.0,
        "fspBuiltTonnes": fsp_built_kg / 1000.0,
        "solarBuiltTonnes": solar_built_kg / 1000.0,
        "msrEarthTonnes": float(msr_cargo_kg.sum()) / 1000.0,
        "oversizeMassTonnes": float(oversize_mass_kg.sum()) / 1000.0,
        "batteryMassTonnes": battery_kg / 1000.0,
        "fspUnits": float(nfsp.max()),
        "fspUnitsNonNuclearY140": float(nfsp[min(NEVER, max(140, x.s_online))]),
        "throughputLostFraction": lost_weight / load_weight if load_weight else 0.0,
        "derivedCriticalFraction": carried_weight / load_weight if load_weight else 1.0,
        "spaMsrFirstYear": float(first) if first is not None else float("nan"),
        "spaMsrUnit2Year": float(unit_year(2)) if unit_year(2) is not None else float("nan"),
        "spaMsrUnit3Year": float(unit_year(3)) if unit_year(3) is not None else float("nan"),
        "npvDeltaUsdM": npv_delta_usd_m,
        "criticalLoadMaxKw": float((c.base_critical_kw + carried).max()),
        "msrAvailable": float(x.msr_available),
    }


def evaluate_d1(space, samples, runs, assumptions):
    """The D1 evaluator named by the model (SeleniteScenarios D1.evaluator):
    every strategy on every sample, with the programme-wide measures from
    the parametrised ECON. The orchestration lives in ``run.evaluate_d1``;
    this is its public entry point (late import avoids the module cycle)."""
    from . import run as _run
    return _run.evaluate_d1(space, samples, runs, assumptions)


def break_even_probability(mass_msr_world: dict[str, float], mass_fsp_world: dict[str, float],
                           reference: str = "carryThroughEclipse") -> dict[str, dict[str, float | str]]:
    """For each alternative, the MSR-availability probability at which its
    expected Earth-launched mass equals the reference's, from the two worlds:
    extra = cost above the reference when the MSR is available, saving =
    saving against the reference when it is not. Returns ``{"p": p*,
    "wins": how}`` with ``how`` one of: "always" (no worse in either world),
    "never" (no better in either world), "below" (beats the reference at
    availability probabilities below p* = saving / (saving + extra)) or
    "above" (better with the MSR, worse without: beats the reference above
    p* = |saving| / (|saving| + |extra|))."""
    out = {}
    for alt in mass_msr_world:
        if alt == reference:
            continue
        extra = mass_msr_world[alt] - mass_msr_world[reference]        # cost in the MSR world
        saving = mass_fsp_world[reference] - mass_fsp_world[alt]       # saving in the FSP-only world
        if extra <= 0 and saving >= 0:
            out[alt] = {"p": 1.0, "wins": "always"}
        elif extra >= 0 and saving <= 0:
            out[alt] = {"p": float("nan"), "wins": "never"}
        elif extra > 0 and saving > 0:
            out[alt] = {"p": saving / (saving + extra), "wins": "below"}
        else:   # extra < 0 and saving < 0: better with the MSR, worse without
            out[alt] = {"p": abs(saving) / (abs(saving) + abs(extra)), "wins": "above"}
    return out


def sunlit_window_fits(batch_hours: np.ndarray, synodic_hours: float, longest_eclipse_hours: np.ndarray) -> np.ndarray:
    """SeleniteAnalysis::SunlitWindowGate per sample."""
    return batch_hours <= synodic_hours - longest_eclipse_hours


def verify_transcription(params: dict[str, object]) -> list[str]:
    """ProgrammeParameters transcribed from VERIFY must equal verify.workspace()."""
    v = verify.workspace()
    errors = []
    checks = {
        "fspUnitPowerKw": float(v["fsp"]["pwr_kW"]), "fspUnitMassKg": float(v["fsp"]["mass_kg"]),
        "spaIlluminatedFraction": float(v["solar"]["illum"]), "spaDesignEclipseHours": float(v["eclipse_hr"]),
        "batterySpecificEnergyWhPerKg": float(v["batt_Whkg"]), "batteryMarginFactor": float(v["batt_margin"]),
    }
    for name, expected in checks.items():
        got = params.get(name)
        if got is None or abs(float(got) - expected) > 1e-9:
            errors.append(f"ProgrammeParameters.{name} = {got} but VERIFY v5.0 gives {expected}")
    return errors
