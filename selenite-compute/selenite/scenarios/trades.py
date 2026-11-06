"""D2-D8 evaluators wrapping ``plan_vectors`` and ``econ_param`` per sample.

Wave 4A extension (6 Nov 2026), NOT a port, no golden. Every evaluator takes
the sampled parameter columns (``Samples.values``, one array per register
entry, common random numbers across alternatives) plus the per-sample ECON
runs the lead assembles once (``EconRuns``), and returns, per alternative,
one ``(n,)`` array per measure of value. Alternatives of one decision are
always evaluated on the same sample index, so comparisons are paired.

Programme-wide measures (cumulative Earth-launched mass, NPV, direct BCR,
launch CO2) come from ``econ_param`` on the sampled economics; a decision
that changes an ECON input (D4 circuit design, D8 hauler floor, D3 canister
content) re-runs the parametrised economics per alternative; a decision that
does not (D2, D5, D6, D7) adds its own power-side or fleet-side delta to the
shared base run.
"""
from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np

from .. import plan_vectors as pv
from . import econ_param
from .eclipse import NEVER, msr_earth_fraction

PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"

YEARS = np.arange(0, 201, dtype=float)


# --------------------------------------------------------------------------
# Sampled economics
# --------------------------------------------------------------------------


def params_for_sample(values: dict[str, np.ndarray], i: int, **overrides) -> econ_param.Params:
    """The ECON ``Params`` for sample ``i`` of the register (the U-set), with
    the decision's own overrides on top."""
    g = lambda name: float(values[name][i])  # noqa: E731
    p = dict(
        launch_cost_multiplier=g("launchCostMultiplier"),
        discount_rates=tuple(r * g("discountRateMultiplier") for r in (0.03, 0.025, 0.02)),
        reo_externality_per_t=g("reoExternalityUsdPerTonne"),
        h2_attribution=g("h2AttributionFraction"),
        geo_insurance_per_yr=g("geoInsuranceUsdMPerYear"),
        circuit_maint_frac=g("circuitMaintenanceFractionPerYear"),
        reo_ramp="decisionFramework" if g("reoRampKnotShift") >= 0.5 else "econ",
        mtype_capture_year=int(round(g("mTypeCaptureYear"))),
        ctype_capture_year=int(round(g("cTypeCaptureYear"))),
        stype_capture_year=int(round(g("sTypeCaptureYear"))),
        asteroid_online_lag=int(round(g("asteroidOnlineLagYears"))),
        can_reo_payload_t=g("reoPayloadPerCanisterTonnes"),
        msr_mass_kg=g("msrUnitMassKg"),
        msr_earth_frac_floor=g("msrEarthFractionFloor"),
        fsp_power_kw=g("fspUnitPowerKw"),
        fsp_mass_kg=g("fspUnitMassKg"),
    )
    p.update(overrides)
    return econ_param.Params(**p)


@dataclass
class EconRuns:
    """One ECON v1.3 run per sample on the U-set (no decision override)."""
    n: int
    metrics: dict[str, np.ndarray]                 # metric -> (n,)
    vectors: dict[str, np.ndarray]                 # ECON key -> (n, 201) for the gate evaluations
    params: list[econ_param.Params] = field(default_factory=list)

    KEEP = ("launch_cost", "df", "contingency", "reo_target", "msr_count", "fsp_count", "molei_needed",
            "haulers_needed", "conv_km_needed", "circuits_needed", "canisters_yr", "total_pgm",
            "captured_asteroid_pgm", "mkiii_active", "insitu_total", "earth_cargo", "cargo_circuits", "d_circuits",
            "cargo_haulers", "d_haulers", "supply_frac", "spa_msr_count", "cargo_mkiii_leo", "maint_haulers",
            "cargo_canisters", "power_kw")


def run_econ(values: dict[str, np.ndarray], n: int, base: EconRuns | None = None,
             per_sample: dict[str, np.ndarray] | None = None, **overrides) -> EconRuns:
    """One ECON v1.3 run per sample. ``overrides`` apply to every sample,
    ``per_sample`` gives a per-sample value of a field; a sample whose
    ``Params`` equal the base run's is copied from it, not re-run."""
    metrics: dict[str, list[float]] = {}
    vectors: dict[str, np.ndarray] = {k: np.zeros((n, 201)) for k in EconRuns.KEEP}
    params = []
    for i in range(n):
        ov = dict(overrides)
        for k, col in (per_sample or {}).items():
            ov[k] = col[i]
        p = params_for_sample(values, i, **ov)
        if base is not None and base.params[i] == p:
            for k in base.metrics:
                metrics.setdefault(k, []).append(float(base.metrics[k][i]))
            for k in EconRuns.KEEP:
                vectors[k][i] = base.vectors[k][i]
            params.append(p)
            continue
        ws = econ_param.v1_3(p)
        m = econ_param.metrics(ws)
        for k, v in m.items():
            metrics.setdefault(k, []).append(float(v))
        for k in EconRuns.KEEP:
            vectors[k][i] = np.asarray(ws[k], dtype=float)
        params.append(p)
    return EconRuns(n, {k: np.asarray(v) for k, v in metrics.items()}, vectors, params)


def first_year_matrix(mask: np.ndarray) -> np.ndarray:
    """Row-wise first True index of an (n, 201) mask; NaN when never."""
    hit = mask.any(axis=1)
    first = np.argmax(mask, axis=1).astype(float)
    first[~hit] = np.nan
    return first


def programme_moes(runs: EconRuns) -> dict[str, np.ndarray]:
    """The programme-wide measures every alternative reports."""
    m = runs.metrics
    return {
        "earthLaunchedMassTonnes": m["cum_earth_cargo_t"].copy(),
        "npvUsdB": m["npv_total_usd_b"].copy(),
        "directBcr": m["bcr_direct"].copy(),
        "launchCo2Tonnes": m["cum_co2_rockets_t"].copy(),
    }


def pv_launch_cost_usd_b(cargo_kg_by_year: np.ndarray, runs: EconRuns, i: int) -> float:
    """Present value ($B) of launching a cargo profile (kg by year) on sample i's
    launch cost, contingency and discount factors (ECON cost_launch rule)."""
    v = runs.vectors
    return float(np.sum(cargo_kg_by_year * v["launch_cost"][i] * v["contingency"][i] * v["df"][i])) / 1e9


# --------------------------------------------------------------------------
# D2 - SPA power supply mix (recourse)
# --------------------------------------------------------------------------


def evaluate_d2(values: dict[str, np.ndarray], runs: EconRuns, site, msr_rated_kw: float) -> dict[str, dict[str, np.ndarray]]:
    """Per alternative: the SPA power-side Earth mass and the first MSR year,
    from the same incremental trade as ECN-022 s.2.3 on the sampled inputs."""
    n = runs.n
    Y = site.Y
    base = programme_moes(runs)
    alts = {k: {} for k in ("nonNuclearOnly", "msrWhenJustified", "msrAtThcl4Availability")}
    out = {k: {"spaPowerEarthMassTonnes": np.zeros(n), "spaMsrFirstYear": np.full(n, np.nan),
               "npvDeltaUsdB": np.zeros(n), "milestoneSlipYears": np.zeros(n)} for k in alts}
    asteroid = np.zeros_like(Y, dtype=float)
    for i in range(n):
        g = lambda name: float(values[name][i])  # noqa: E731
        c_on = int(round(g("cTypeCaptureYear") + g("asteroidOnlineLagYears")))
        s_on = int(round(g("sTypeCaptureYear") + g("asteroidOnlineLagYears")))
        kw = dict(pv.DF_ASTEROID_PROCESSING_KW)
        asteroid[:] = 0.0
        for year, load in ((c_on, kw[105]), (s_on, kw[125]), (140, kw[140])):
            asteroid[Y >= year] += load
        # Carry-through critical fraction (the committed 1.0) for the FSP side of D2.
        critical = site.base_critical_kw + asteroid
        nfsp = np.ceil(critical / g("fspUnitPowerKw"))
        p_tot = (site.base_total_kw_sub + asteroid) * (1.0 + site.contingency)
        panel_m2 = p_tot / site.solar_yield_kwm2
        solar_ef = np.where(Y >= g("solarInSituStartYear"), 0.3, 1.0)
        fsp_inc = np.maximum(0.0, nfsp - site.p7_fsp_units) * g("fspUnitMassKg")
        solar_inc = np.maximum(0.0, panel_m2 * g("solarPanelMassKgPerM2") - site.p7_panel_kg) * solar_ef
        fsp_asb = nfsp * g("fspUnitMassKg")
        solar_asb = panel_m2 * g("solarPanelMassKgPerM2") * solar_ef
        units = np.maximum(1.0, np.ceil(p_tot / msr_rated_kw))
        ef = msr_earth_fraction(Y, g("msrEarthFractionFloor"))
        msr_earth = units * g("msrUnitMassKg") * ef
        thcl4 = g("thcl4AvailableYear")
        policies = {
            "nonNuclearOnly": None,
            "msrWhenJustified": (fsp_inc + solar_inc > msr_earth) & (Y >= thcl4) & (Y >= 18),
            "msrAtThcl4Availability": (fsp_asb + solar_asb > msr_earth) & (Y >= thcl4) & (Y >= 18),
        }
        for alt, justified in policies.items():
            idx = np.flatnonzero(justified) if justified is not None else np.array([], dtype=int)
            first = int(idx[0]) if idx.size else None
            cut = NEVER + 1 if first is None else first
            nn = fsp_inc + solar_inc
            cargo = np.zeros_like(Y, dtype=float)
            if cut > 0:
                cargo[:cut] = np.maximum(0.0, np.diff(np.concatenate([[0.0], nn[:cut]])))
            if first is not None:
                d_units = np.maximum(0.0, np.diff(np.concatenate([[0.0], units[first:]])))
                cargo[first:] += d_units * g("msrUnitMassKg") * ef[first:]
            out[alt]["spaPowerEarthMassTonnes"][i] = cargo.sum() / 1000.0
            out[alt]["spaMsrFirstYear"][i] = np.nan if first is None else float(first)
            out[alt]["npvDeltaUsdB"][i] = -pv_launch_cost_usd_b(cargo, runs, i)
            # Slip against DG-13.4 (Y105): the first MSR after the C-type arrival.
            out[alt]["milestoneSlipYears"][i] = max(0.0, (NEVER if first is None else first) - 105.0)
    for alt in out:
        out[alt]["earthLaunchedMassTonnes"] = base["earthLaunchedMassTonnes"] + out[alt]["spaPowerEarthMassTonnes"]
        out[alt]["npvUsdB"] = base["npvUsdB"] + out[alt]["npvDeltaUsdB"]
        out[alt]["directBcr"] = base["directBcr"]
        out[alt]["launchCo2Tonnes"] = base["launchCo2Tonnes"]
        out[alt]["probabilityMsrBeforeY105"] = np.where(np.isnan(out[alt]["spaMsrFirstYear"]), 0.0,
                                                        (out[alt]["spaMsrFirstYear"] < 105).astype(float))
    return out


# --------------------------------------------------------------------------
# D3 - canister recovery architecture (now, with the test outcome as recourse)
# --------------------------------------------------------------------------

CANISTER_OPTIONS = ("fullParachute", "minimalDragChute", "shuttlecock")
CANISTER_FALLBACK = {"shuttlecock": "minimalDragChute", "minimalDragChute": "fullParachute", "fullParachute": None}
ANNUAL_COST_USD_B = {"fullParachute": 42.0, "minimalDragChute": 16.0, "shuttlecock": 4.6}   # DF s.9 P14+


def evaluate_d3(values: dict[str, np.ndarray], base_runs: EconRuns, content_kg: dict[str, float],
                test_u: dict[str, np.ndarray]) -> dict[str, dict[str, np.ndarray]]:
    """Per alternative: the realised architecture after the impact-survival
    test (fail -> next safer option), the ECON run with that Earth content
    and the sampled canister payload, DF s.9 annual import cost."""
    n = base_runs.n
    p_pass = values["impactSurvivalPassProbability"]
    passes = {"minimalDragChute": test_u["impactSurvival1b"] < p_pass,
              "shuttlecock": test_u["impactSurvival2"] < p_pass,
              "fullParachute": np.ones(n, dtype=bool)}
    out = {}
    cache: dict[tuple[str, int], dict] = {}
    for alt in CANISTER_OPTIONS:
        realised = np.empty(n, dtype=object)
        for i in range(n):
            choice = alt
            while choice is not None and not passes[choice][i]:
                choice = CANISTER_FALLBACK[choice]
            realised[i] = choice or "fullParachute"
        moes = {k: np.zeros(n) for k in ("earthLaunchedMassTonnes", "npvUsdB", "directBcr", "launchCo2Tonnes",
                                          "annualEarthImportCostUsdB", "canisterEarthMassTonnes", "milestoneSlipYears")}
        for i in range(n):
            r = realised[i]
            key = (r, i)
            if key not in cache:
                p = params_for_sample(values, i, can_earth_kg=content_kg[r])
                if base_runs.params[i] == p:
                    m = {k: float(base_runs.metrics[k][i]) for k in base_runs.metrics}
                    cache[key] = {"m": m, "canister_t": float(np.sum(base_runs.vectors["cargo_canisters"][i]))}
                else:
                    ws = econ_param.v1_3(p)
                    m = econ_param.metrics(ws)
                    cache[key] = {"m": m, "canister_t": float(np.sum(ws["cargo_canisters"]))}
            m = cache[key]["m"]
            moes["earthLaunchedMassTonnes"][i] = m["cum_earth_cargo_t"]
            moes["npvUsdB"][i] = m["npv_total_usd_b"]
            moes["directBcr"][i] = m["bcr_direct"]
            moes["launchCo2Tonnes"][i] = m["cum_co2_rockets_t"]
            moes["canisterEarthMassTonnes"][i] = cache[key]["canister_t"]
            moes["annualEarthImportCostUsdB"][i] = ANNUAL_COST_USD_B[r]
        moes["probabilityRealisedAsChosen"] = np.array([float(realised[i] == alt) for i in range(n)])
        moes["earthContentKgPerCanister"] = np.array([content_kg[realised[i]] for i in range(n)])
        out[alt] = moes
    return out


# --------------------------------------------------------------------------
# D4 - processing circuit design (now)
# --------------------------------------------------------------------------

CIRCUIT_DESIGNS = (("batchDesign", 1), ("continuousFlowDesign", 2), ("optimisedDesign", 3))


def evaluate_d4(values: dict[str, np.ndarray], base_runs: EconRuns, thresholds: dict[str, float]) -> dict[str, dict[str, np.ndarray]]:
    n = base_runs.n
    out = {}
    for alt, design in CIRCUIT_DESIGNS:
        runs = base_runs if design == 3 else run_econ(values, n, base=base_runs, circuit_design=design)
        moes = programme_moes(runs)
        v = runs.vectors
        moes["circuitsNeeded"] = v["circuits_needed"][:, -1]
        moes["pktPowerGw"] = v["power_kw"][:, -1] / 1e6
        # Gate years the decision touches: DG-8.5 (REO >= 125 t/yr, Y28), DG-9.2 (haulers >= 1,000, Y38),
        # DG-10.2 (conveyor >= 5,000 km, Y48). Slip = the largest lateness.
        y85 = first_year_matrix(v["reo_target"] >= thresholds["reoTonnesPerYearP8"])
        y92 = first_year_matrix(v["haulers_needed"] >= thresholds["haulersP9"])
        y102 = first_year_matrix(v["conv_km_needed"] >= thresholds["conveyorKmP10"])
        moes["gateYear:DG-8.5"] = y85
        moes["gateYear:DG-9.2"] = y92
        moes["gateYear:DG-10.2"] = y102
        moes["milestoneSlipYears"] = np.maximum.reduce([
            np.maximum(0.0, np.nan_to_num(y85, nan=NEVER) - 28.0),
            np.maximum(0.0, np.nan_to_num(y92, nan=NEVER) - 38.0),
            np.maximum(0.0, np.nan_to_num(y102, nan=NEVER) - 48.0)])
        out[alt] = moes
    return out


# --------------------------------------------------------------------------
# D5 - MD-4 / Starship-return retirement timing (consequence)
# --------------------------------------------------------------------------


def evaluate_d5(values: dict[str, np.ndarray], runs: EconRuns) -> dict[str, dict[str, np.ndarray]]:
    year = values["mTypeCaptureYear"] + values["asteroidOnlineLagYears"]
    moes = programme_moes(runs)
    moes["mdFourYear"] = year.astype(float)
    moes["probabilityOperationalByY85"] = (year <= 85).astype(float)
    moes["milestoneSlipYears"] = np.maximum(0.0, year - 85.0)
    moes["gateYear:DG-11.8"] = values["mTypeCaptureYear"].astype(float)
    moes["gateYear:DG-12.4"] = year.astype(float)
    moes["starshipReturnYearsAvoided"] = np.maximum(0.0, NEVER - year)
    return {"consequenceOfMTypeArrival": moes}


# --------------------------------------------------------------------------
# D6 - thorium stream sizing (consequence)
# --------------------------------------------------------------------------


def evaluate_d6(values: dict[str, np.ndarray], runs: EconRuns, params: dict[str, object],
                thresholds: dict[str, float]) -> dict[str, dict[str, np.ndarray]]:
    n = runs.n
    ratio = np.array([pv.thorium_ratio(float(values["thoriumGradePpm"][i]), float(params["processingReeGradePpm"]),
                                       float(values["acidBakeThoriumCapture"][i])) for i in range(n)])
    stock = np.cumsum(runs.vectors["reo_target"], axis=1) * ratio[:, None]
    y87 = first_year_matrix(stock >= thresholds["thoriumStockpileTonnes"])
    moes = programme_moes(runs)
    moes["dgEightSevenYear"] = y87
    moes["thoriumHydroxideAtY43Tonnes"] = stock[:, 43]
    moes["thoriumToReoMassRatio"] = ratio
    moes["milestoneSlipYears"] = np.maximum(0.0, np.nan_to_num(y87, nan=NEVER) - 30.0)
    moes["gateYear:DG-8.7"] = y87
    return {"consequenceOfGradeAndCapture": moes}


# --------------------------------------------------------------------------
# D7 - Mk III transition trigger (recourse)
# --------------------------------------------------------------------------


def evaluate_d7(values: dict[str, np.ndarray], runs: EconRuns, test_u: np.ndarray) -> dict[str, dict[str, np.ndarray]]:
    n = runs.n
    need = runs.vectors["molei_needed"]
    cap = values["psrMoleICapacityUnits"]
    forced_year = first_year_matrix(need > cap[:, None])
    forced = ~np.isnan(forced_year)
    passes = test_u < values["mkIiiTestPassProbability"]
    mkiii_mass = runs.vectors["cargo_mkiii_leo"].sum(axis=1)
    base = programme_moes(runs)
    out = {}
    # capacityForced: the transition happens only when (and when) capacity forces it.
    moes = dict(base)
    moes["probabilityCapacityForced"] = forced.astype(float)
    moes["mkIiiTransitionYear"] = forced_year
    moes["mkIiiFleetEarthMassTonnes"] = np.where(forced, mkiii_mass, 0.0)
    moes["milestoneSlipYears"] = np.maximum(0.0, np.nan_to_num(forced_year, nan=NEVER) - 75.0)
    moes["gateYear:DG-11.6"] = forced_year
    out["capacityForced"] = moes
    # testOutcomeDriven: the transition at DG-11.6 (ECON Y60 build start) when the validation passes.
    moes = dict(base)
    year = np.where(passes, 65.0, np.nan)
    moes["probabilityCapacityForced"] = forced.astype(float)
    moes["mkIiiTransitionYear"] = year
    moes["mkIiiFleetEarthMassTonnes"] = np.where(passes, mkiii_mass, 0.0)
    moes["milestoneSlipYears"] = np.where(passes, 0.0, float(NEVER - 75))
    moes["gateYear:DG-11.6"] = year
    out["testOutcomeDriven"] = moes
    return out


# --------------------------------------------------------------------------
# D8 - hauler in-situ fraction policy (recourse)
# --------------------------------------------------------------------------


def evaluate_d8(values: dict[str, np.ndarray], base_runs: EconRuns, thresholds: dict[str, float]) -> dict[str, dict[str, np.ndarray]]:
    n = base_runs.n
    out = {}
    for alt in ("econFloor", "targetFloor"):
        if alt == "econFloor":
            floors = values["haulerEarthFractionFloor"]            # the sampled F3 candidates
        else:
            floors = np.full(n, thresholds["haulerEarthFractionFloor"])   # the DG-13.7 target
        runs = _runs_with_floor(values, n, floors, base_runs)
        moes = programme_moes(runs)
        v = runs.vectors
        with np.errstate(divide="ignore", invalid="ignore"):
            ef = v["cargo_haulers"] / (v["d_haulers"] * 1450.0 / 1000.0)
        ef = np.where(v["d_haulers"] > 0, ef, np.nan)
        y137 = first_year_matrix(np.nan_to_num(ef, nan=1.0) <= thresholds["haulerEarthFractionFloor"])
        moes["probabilityDgThirteenSevenMetByY120"] = np.where(np.isnan(y137), 0.0, (y137 <= 120).astype(float))
        moes["haulerEarthMassTonnes"] = v["cargo_haulers"].sum(axis=1) + v["maint_haulers"].sum(axis=1)
        moes["milestoneSlipYears"] = np.maximum(0.0, np.nan_to_num(y137, nan=NEVER) - 120.0)
        moes["gateYear:DG-13.7"] = y137
        moes["gateYear:DG-10.1"] = first_year_matrix(v["haulers_needed"] >= thresholds["haulersP10"])
        out[alt] = moes
    return out


def _runs_with_floor(values: dict[str, np.ndarray], n: int, floors: np.ndarray, base: EconRuns) -> EconRuns:
    """ECON runs with a per-sample hauler Earth-fraction floor (the F3
    candidates are sampled, so the floor differs by sample); the ECON floor
    0.43 keeps its 0.20 post-bonus minimum, a lower floor lowers it too."""
    floors = np.asarray(floors, dtype=float)
    return run_econ(values, n, base=base,
                    per_sample={"hauler_earth_frac_floor": floors, "hauler_earth_frac_min": np.minimum(0.20, floors)})
