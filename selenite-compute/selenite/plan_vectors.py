"""Plan vectors that no MATLAB script computes (Wave 3 extension, 19 Sep 2026).

NOT A PORT. Nothing here has a golden. The two vectors exist so that the
derivable gates the Decision Framework states on quantities the scripts never
modelled can be evaluated under *stated* assumptions instead of standing
"unevaluated":

* ``spa_power()`` - SPA electrical demand beyond P7 (F5 / DG-10.5, 11.3,
  13.4, 14.4, 14.7). VERIFY v5.0 sizes SPA power for P3..P7 only; this
  extends it by scaling the VERIFY P7 per-unit loads with the ECON fleet
  vectors. The non-MSR capability ceiling (solar + FSP + battery) has no
  source anywhere and is an INPUT (``ProgrammeParameters.
  spaNonMsrCapabilityCeilingKw``, unbound); the gate is evaluated only when
  it is bound, otherwise the demand trajectory is reported.
* ``thorium_stockpile()`` - cumulative Th(OH)4 from the acid bake (DG-8.7).
  ECON has no thorium; the stockpile is cumulative ``reo_target`` times a
  Th:REO mass ratio (``ProgrammeParameters.thoriumToReoMassRatio``,
  unbound). The two bounds below are what the Decision Framework's own
  DG-11.2 numbers imply (Th production 387-773 t/yr against the P11
  100,000 t/yr REO).

Every assumption is a named constant or a function argument; changing one is
an ECN to this module, and the goldens are untouched.
"""
from __future__ import annotations

import numpy as np

from . import econ, verify

PORTED = False
SOURCE_SCRIPT = "none - Wave 3 extension (no golden)"

# Decision Framework Rev D DG-11.2: "~54 t/yr consumption vs 387-773 t/yr
# production" while the P11 heading is 100,000 t/yr REO.
TH_TO_REO_RATIO_LOW = 387.0 / 100_000.0
TH_TO_REO_RATIO_HIGH = 773.0 / 100_000.0

# Decision Framework Rev D s.10.1 SPA MSR sizing: the asteroid-processing
# loads the MSRs are sized for. Used only when asked for (``with_asteroid_loads``).
DF_ASTEROID_PROCESSING_KW = ((105, 50_000.0), (125, 100_000.0), (140, 100_000.0))

P7_INDEX = 4  # VERIFY ph.* index of "P7+"


def spa_power(with_asteroid_loads: bool = False) -> dict:
    """SPA electrical demand by programme year Y0..Y200 (kW) and its
    components, scaled from VERIFY v5.0 P7 per-unit loads by ECON fleets.

    Components (VERIFY names): PSR fleet + nodes + pipeline; ISRU per
    MOLE-I; habitat (with greenhouse, constant from P7); IZ per chemical
    PROBE; the other base loads held at their P7 values; 20 % contingency
    as VERIFY applies it. Loads VERIFY never modelled and this module does
    not invent: the EM catcher, PGM hydromet, the Mk III canister stream.
    ``with_asteroid_loads`` adds the Decision Framework's SPA MSR sizing
    (the loads, not the MSRs) from Y105 / Y125 / Y140.
    """
    w = econ.workspace()
    v = verify.workspace()
    ph = v["ph"]
    Y = w["Y"].astype(int)
    molei = np.asarray(w["molei_needed"], dtype=float)
    probes = np.asarray(w["probe_fleet"], dtype=float)

    mi_kw = v["mi"]["pwr_tether"] / 1000.0
    node_kw = v["node"]["overhead_v5"] / 1000.0 / v["node"]["units"]   # per MOLE-I
    pipe_kw = float(ph["p_pipe"][P7_INDEX])
    isru_per_molei = float(ph["p_isru"][P7_INDEX] / ph["mi"][P7_INDEX])
    iz_per_probe = float(ph["p_iz"][P7_INDEX] / ph["nP"][P7_INDEX])
    hab_kw = float(ph["p_hab"][P7_INDEX])
    other_base_kw = float(ph["p_base"][P7_INDEX] - ph["p_hab"][P7_INDEX] - ph["p_iz"][P7_INDEX])

    p_psr = molei * (mi_kw + node_kw) + pipe_kw
    p_isru = molei * isru_per_molei
    p_base = hab_kw + probes * iz_per_probe + other_base_kw
    p_asteroid = np.zeros_like(p_psr)
    if with_asteroid_loads:
        for year, kw in DF_ASTEROID_PROCESSING_KW:
            p_asteroid[Y >= year] += kw
    p_sub = p_psr + p_isru + p_base + p_asteroid
    p_tot = p_sub * 1.20
    # Before P7 the VERIFY sizing is the authority: splice it in by phase window.
    verify_years = {3: 4, 4: 7, 5: 9, 6: 12}  # phase -> start year (P7 from 18)
    p_ref = p_tot.copy()
    for i, start in enumerate((4, 7, 9, 12, 18)):
        end = (7, 9, 12, 18, 25)[i]
        p_ref[(Y >= start) & (Y < end)] = float(ph["p_tot"][i])
    p_ref[Y < 4] = 0.0
    return {
        "Y": Y, "p_tot": p_tot, "p_ref_to_p7": p_ref, "p_psr": p_psr, "p_isru": p_isru,
        "p_base": p_base, "p_asteroid": p_asteroid,
        "p7_sized_capability_kw": float(ph["p_tot"][P7_INDEX]),
        "assumptions": {
            "mi_kw_per_unit": mi_kw, "node_kw_per_molei": node_kw, "pipe_kw": pipe_kw,
            "isru_kw_per_molei": isru_per_molei, "iz_kw_per_probe": iz_per_probe,
            "hab_kw": hab_kw, "other_base_kw": other_base_kw, "contingency": 0.20,
            "asteroid_loads": DF_ASTEROID_PROCESSING_KW if with_asteroid_loads else (),
        },
    }


def first_year_demand_exceeds(ceiling_kw: float, with_asteroid_loads: bool = False) -> int | None:
    """First programme year (>= Y18, P7) in which SPA demand exceeds a
    non-MSR capability ceiling; None if never."""
    sp = spa_power(with_asteroid_loads)
    mask = (sp["Y"] >= 18) & (sp["p_tot"] > ceiling_kw)
    idx = np.flatnonzero(mask)
    return int(idx[0]) if idx.size else None


def thorium_stockpile(ratio: float) -> np.ndarray:
    """Cumulative Th(OH)4 stockpile (t) by year: cumulative ECON reo_target
    times the Th:REO mass ratio. Consumption by MSRs is not subtracted."""
    w = econ.workspace()
    return np.cumsum(np.asarray(w["reo_target"], dtype=float)) * ratio


def first_year_stockpile_reaches(tonnes: float, ratio: float) -> int | None:
    idx = np.flatnonzero(thorium_stockpile(ratio) >= tonnes)
    return int(idx[0]) if idx.size else None


# ---------------------------------------------------------------------------
# Eclipse-critical load split and the FSP-versus-MSR trade (19 Sep 2026)
# ---------------------------------------------------------------------------

TH_HYDROXIDE_TO_TH_MASS = (232.04 + 4 * 17.01) / 232.04   # Th(OH)4 / Th = 1.293


def thorium_ratio(th_grade_ppm: float, ree_grade_ppm: float, capture: float) -> float:
    """Th(OH)4 tonnes per tonne REO: ore Th:REE ratio x acid-bake capture x
    hydroxide mass factor (DG-7.2: ~90-95 % of Th locks into ThP2O7)."""
    return th_grade_ppm / ree_grade_ppm * capture * TH_HYDROXIDE_TO_TH_MASS


def spa_critical_power(asteroid_critical_fraction: float = 0.0) -> dict:
    """Eclipse-critical SPA demand by year (kW): the loads VERIFY v5.0's
    eclipse budget (ecl.*) must carry for the 72 h design case, scaled from
    the P7 values - MOLE-I keep-alive and node overhead per ECON molei_needed,
    with pipeline heating, habitat, SENTINEL, farm ZBO and misc held at P7.
    ``asteroid_critical_fraction`` is the share of the Decision Framework
    asteroid-processing loads that cannot pause through an eclipse (an
    assumption, default none). Solar carries everything else, as VERIFY
    sizes it."""
    w = econ.workspace()
    v = verify.workspace()
    ecl = v["ecl"]
    Y = w["Y"].astype(int)
    molei = np.asarray(w["molei_needed"], dtype=float)
    ka_kw = v["mi"]["pwr_ka"] / 1000.0 + v["node"]["overhead_v5"] / 1000.0 / v["node"]["units"]
    fixed = float(ecl["pipe"][P7_INDEX] + ecl["hab"][P7_INDEX] + ecl["sent"][P7_INDEX]
                  + ecl["farmzbo"][P7_INDEX] + ecl["misc"][P7_INDEX])
    crit = molei * ka_kw + fixed
    asteroid = np.zeros_like(crit)
    for year, kw in DF_ASTEROID_PROCESSING_KW:
        asteroid[Y >= year] += kw * asteroid_critical_fraction
    return {"Y": Y, "p_critical": crit + asteroid, "p_critical_base": crit, "p_asteroid_critical": asteroid,
            "assumptions": {"keepalive_kw_per_molei": ka_kw, "fixed_kw": fixed,
                            "asteroid_critical_fraction": asteroid_critical_fraction}}


def fsp_msr_trade(md3_year: int, asteroid_critical_fraction: float = 0.0, msr_rated_kw: float = 50_000.0) -> dict:
    """The SPA MSR decision as a mass trade, by year: the Earth mass of the
    FSP fleet needed to cover eclipse-critical demand (VERIFY fsp: 40 kW,
    6,600 kg per unit) against the Earth mass of one SPA MSR (ECON msr:
    50,000 kg x earth_frac(y), which falls to 0.3 as Ni-201 vessels go
    in-situ). The MSR is *worth it* when the FSP fleet's Earth mass exceeds
    the MSR's; it is *justified* (SpaMsrIntroductionGate) when it is worth it
    and ThCl4 is available (MD-3 operational from ``md3_year``); the crewed-
    base feasibility input is assumed true. ``msr_rated_kw`` caps what one
    unit covers (Decision Framework s.10.1: SPA MSR #1 ~50 MWe)."""
    w = econ.workspace()
    v = verify.workspace()
    cp = spa_critical_power(asteroid_critical_fraction)
    Y = cp["Y"]
    fsp_kw, fsp_kg = float(v["fsp"]["pwr_kW"]), float(v["fsp"]["mass_kg"])
    nfsp = np.ceil(cp["p_critical"] / fsp_kw)
    fsp_mass = nfsp * fsp_kg
    ef = np.array([w["msr"]["earth_frac"](float(y)) for y in Y])
    units = np.maximum(1.0, np.ceil(cp["p_critical"] / msr_rated_kw))
    msr_mass = units * w["msr"]["mass_kg"] * ef
    worth = fsp_mass > msr_mass
    fuel = Y >= md3_year
    justified = worth & fuel & (Y >= 18)
    idx = np.flatnonzero(justified)
    idx_w = np.flatnonzero(worth & (Y >= 18))
    return {"Y": Y, "p_critical": cp["p_critical"], "nfsp_needed": nfsp, "fsp_earth_mass_kg": fsp_mass,
            "msr_earth_mass_kg": msr_mass, "msr_units": units, "worth_it": worth, "justified": justified,
            "first_worth_it_year": int(idx_w[0]) if idx_w.size else None,
            "first_justified_year": int(idx[0]) if idx.size else None,
            "assumptions": {**cp["assumptions"], "fsp_kw": fsp_kw, "fsp_kg": fsp_kg,
                            "msr_mass_kg": w["msr"]["mass_kg"], "md3_year": md3_year, "msr_rated_kw": msr_rated_kw}}
