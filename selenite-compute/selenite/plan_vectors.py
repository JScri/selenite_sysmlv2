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


def fsp_msr_trade(md3_year: int, asteroid_critical_fraction: float = 0.0, msr_rated_kw: float = 50_000.0,
                  basis: str = "incremental", solar_in_situ_from: int | None = None,
                  solar_in_situ_earth_frac: float = 0.3) -> dict:
    """The SPA MSR decision as a cargo-mass trade, by year, with every mass
    given its source and destination:

    Non-nuclear alternative (both parts Earth -> SPA ELZ by Starship, then
    ARM-C haul ELZ -> power zone, 4.3 km uphill):
      * FSP units to cover the eclipse-critical load (VERIFY fsp: 40 kW,
        6,600 kg each), and
      * the solar array to cover the total day load (VERIFY solar yield
        0.319 kW/m2 at 85 % illumination, 3 kg/m2), Earth-sourced unless
        ``solar_in_situ_from`` is set (Decision Framework s.6: a-Si panels
        in-situ from P11), after which only ``solar_in_situ_earth_frac`` of
        new array mass comes from Earth.
    Nuclear alternative: SPA MSR units sized to the total demand (ECON msr:
    50,000 kg each, ``msr_rated_kw`` per unit); the Earth fraction
    (ECON earth_frac(y), 0.3 floor from Y80) travels Earth -> SPA; the
    in-situ fraction is PKT-foundry Ni-201 and travels PKT -> SPA by MD-3
    (ECN-020: MD-3 single track, ~42 launches/yr; the canister payload for
    that route is not specified - a mass, not a cargo-flight cost, is what
    is compared here).

    ``basis="asbuilt"`` compares the full masses for that year's demand;
    ``basis="incremental"`` (decision-relevant: delivered hardware is sunk)
    subtracts the P7 as-built non-nuclear fleet (VERIFY ecl.nfsp and
    ph.panel_kg at P7) from the non-nuclear side, floored at zero.
    The MSR is *worth it* when the non-nuclear Earth-sourced cargo exceeds the
    MSR's Earth-sourced cargo; *justified* (SpaMsrIntroductionGate) when it
    is worth it and ThCl4 is available (MD-3 from ``md3_year``); the
    crewed-base feasibility input is assumed true."""
    w = econ.workspace()
    v = verify.workspace()
    cp = spa_critical_power(asteroid_critical_fraction)
    sp = spa_power(with_asteroid_loads=True)
    Y = cp["Y"]
    fsp_kw, fsp_kg = float(v["fsp"]["pwr_kW"]), float(v["fsp"]["mass_kg"])
    yield_kwm2 = float(v["solar"]["yield_kWm2"])
    panel_kg_m2 = 3.0
    nfsp = np.ceil(cp["p_critical"] / fsp_kw)
    fsp_mass = nfsp * fsp_kg
    panel_m2 = sp["p_tot"] / yield_kwm2
    solar_ef = np.ones_like(panel_m2)
    if solar_in_situ_from is not None:
        solar_ef[Y >= solar_in_situ_from] = solar_in_situ_earth_frac
    solar_mass = panel_m2 * panel_kg_m2 * solar_ef
    if basis == "incremental":
        fsp_mass = np.maximum(0.0, fsp_mass - float(v["ecl"]["nfsp"][P7_INDEX]) * fsp_kg)
        solar_mass = np.maximum(0.0, panel_m2 * panel_kg_m2 - float(v["ph"]["panel_kg"][P7_INDEX])) * solar_ef
    elif basis != "asbuilt":
        raise ValueError(basis)
    nonnuclear_mass = fsp_mass + solar_mass
    ef = np.array([w["msr"]["earth_frac"](float(y)) for y in Y])
    units = np.maximum(1.0, np.ceil(sp["p_tot"] / msr_rated_kw))
    msr_total_mass = units * w["msr"]["mass_kg"]
    msr_earth_mass = msr_total_mass * ef
    msr_pkt_mass = msr_total_mass * (1.0 - ef)     # PKT -> SPA via MD-3
    worth = nonnuclear_mass > msr_earth_mass
    fuel = Y >= md3_year
    justified = worth & fuel & (Y >= 18)
    idx = np.flatnonzero(justified)
    idx_w = np.flatnonzero(worth & (Y >= 18))
    return {"Y": Y, "basis": basis, "p_critical": cp["p_critical"], "p_total": sp["p_tot"],
            "nfsp_needed": nfsp, "fsp_earth_mass_kg": fsp_mass, "solar_earth_mass_kg": solar_mass,
            "nonnuclear_earth_mass_kg": nonnuclear_mass, "msr_units": units,
            "msr_earth_mass_kg": msr_earth_mass, "msr_pkt_to_spa_mass_kg": msr_pkt_mass,
            "worth_it": worth, "justified": justified,
            "first_worth_it_year": int(idx_w[0]) if idx_w.size else None,
            "first_justified_year": int(idx[0]) if idx.size else None,
            "routes": {"fsp": "Earth -> SPA ELZ (Starship), ARM-C haul to power zone",
                       "solar": "Earth -> SPA ELZ (Starship)" + (f"; a-Si in-situ from Y{solar_in_situ_from}" if solar_in_situ_from else ""),
                       "msr_earth_fraction": "Earth -> SPA ELZ (Starship)",
                       "msr_in_situ_fraction": "PKT foundry -> SPA via MD-3 (ECN-020 single track, ~42 launches/yr; canister payload unspecified)"},
            "assumptions": {**cp["assumptions"], "fsp_kw": fsp_kw, "fsp_kg": fsp_kg, "solar_yield_kwm2": yield_kwm2,
                            "panel_kg_m2": panel_kg_m2, "msr_mass_kg": w["msr"]["mass_kg"], "md3_year": md3_year,
                            "msr_rated_kw": msr_rated_kw, "solar_in_situ_from": solar_in_situ_from}}
