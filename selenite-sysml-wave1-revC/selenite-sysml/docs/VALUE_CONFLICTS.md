# Selenite — Value Conflicts: goldens vs documents (9 Sep 2026)

Source of truth for computed values is the golden oracle
(`selenite-goldens-oracle.zip`, MATLAB R2025a canonical, Octave-cross-checked).
This register lists where the authoritative documents disagree with the
current scripts, or where the scripts disagree with each other. **Nothing here
is resolved.** Each row is a Wave 5 adjudication item; Wave 2 records the
conflict in a `doc` comment and carries no numeric attribute for it.

| ID | Quantity | Documents say (family) | Goldens say (script) | Note |
|---|---|---|---|---|
| VC-01 | MOLE-I per phase P3–P7 | 10 / 25 / 50 / 85 / 170; nodes 2 / 5 / 10 / 17 / 34 (Fleet v9, fleet_count html, Strategy, MTL) | **5 / 30 / 55 / 90 / 180; nodes 1 / 6 / 11 / 18 / 36** (VERIFY v5.0 `ph.mi`, `ph.nd`) | Docs cite "MATLAB VERIFY v5.0" but carry v4.4/v4.5 numbers. v5.0 adds a prospecting unit per branch. Decide which profile is baseline. |
| VC-02 | P7 base power / array | 2,142 kW, 6,250 m² (fleet_count, expansion) | **2,342 kW, 7,348 m²** (VERIFY v5.0 `ph.p_tot`, `ph.panel_m2`) | 2,142 is SCALE v1.3 `pwr_spa[P7]`; 6,250 matches neither v4.4 (6,454) nor v4.5 (6,789). |
| VC-03 | P7 ISRU propellant | 968 t/yr (all docs) | **1,024.6 t/yr** (VERIFY v5.0 `ph.isru`) | 968 = VERIFY v4.x (170 MOLE-I). Follows VC-01. |
| VC-04 | ISRU plant power P7 | 1,171 kW = 850 + 256 + 50 + 15, 17 + 2 PEM (ISRU-001 Rev D, CAD-ISRU) | **1,360 kW = 883 + 412 + 50 + 15, 18 PEM** (VERIFY v5.0); **1,627 kW, 891 kW electrolysis** (sabatier Q19); 1,090 (Fleet v8) | Four values. VERIFY v5.0 itself flags cryo 412 vs 256 kW ⚠ (passive-cooling assumption). AUD-005/006/007 cluster, still open in the computation. |
| VC-05 | SKIP propellant per hop | 303 kg (Fleet v8/v9, SKIP spec, scope) | **326.6 kg** at mf 700 (VERIFY v5.0 `skip.fuel_hop`) | VERIFY notes Δ+24 kg "OK". Docs never updated. |
| VC-06 | ARM-C count P3–P7 | 1 → 2 from P4 (fleet_count html per AUD-012) | **1 / 1 / 1 / 1 / 2** (VERIFY v5.0 `ph.nARMC`) | Second ARM-C at P7 in the model, P4 in the docs. |
| VC-07 | MOLE-I after P7 | ~355 peak at P12 (HAULER_SPEC_UPDATE_BRIEF, scope material-flow); 320 → ~50 during P11 (scope P11) | **247 (Y25) → 357 (Y35) → 287 (Y45) → 322 (Y60) → 77 (Y80) → 53 (Y100+)** (ECON v1.3 infrastructure table) | ECON resolves F4: peak 357 at Y35 (P8/P9), decline Y60→Y80, 53 from Y100. "355 at P12" is wrong. |
| VC-08 | Hauler fleet by phase | 200 / 1,000+ / 14,881 / 148,810 / 1,488,096 / ~1.5M (PROC-PKT Rev B, Hauler brief, Fleet v9) | **167 (Y35) / 1,267 (Y45) / 10,667 (Y60) / 80,001 (Y80) / 150,000 (Y100) / 300,000 (Y120) / 1.5M (Y200)** (ECON v1.3) | The doc series is SCALE v1.3 (pre-ECN-019: 1 Mt/yr at P12, haulers carry all ore at 2,100 t/yr each). ECON uses 1,500 t/yr per hauler and a Tier-3 conveyor fraction. Only the Y200 endpoint agrees. |
| VC-09 | MSR count and PKT power at steady state | 6,890 MSR, 688.7 GW (PROC-PKT Rev B, overview) | **8,334 MSR** (ECON v1.3 Y200) = 2,083,334 circuits × 400 kW = **833 GW** | 688.7 GW is not 2.08M × 400 kW. Either the circuit power or the GW figure in the documents is stale. |
| VC-10 | Conveyor network at steady state | ~87,500 km (PROC-PKT Rev B, Strategy) | **137,500 km** (ECON v1.3 Y200) | ECON: regolith × Tier-3 fraction ÷ 20,000 t/yr/km. |
| VC-11 | Habitat power | ~50 kW nominal, 63 kW with margin (HAB/POWER specs) | **6.0 kW no greenhouse, 18.0 kW with LED greenhouse** (VERIFY v5.0 `hab.*`) | VERIFY treats the spec as an upper bound; an 8× gap is a spec problem, not a rounding one. |
| VC-12 | ISRU makeup water (4 crew) | 1.4 kg/day potable + 4.0 kg/day O₂ electrolysis ≈ 6 kg/day (ECLSS-001 Rev B) | **3.77 kg/day total** (sabatier Scenario C, VERIFY v5.0) | Scenario C balances CO₂ exactly; ECLSS-001 predates it. |
| VC-13 | LH₂ buffer volume | 175 m³ (older ISRU spec); 3 × 5.0 m spheres = 196 m³ (CAD-ISRU) | **need 190.8 m³**; 2 × 5.0 m = 130.9 m³ insufficient (sabatier Q15) | CAD's three spheres satisfy the golden; the "175" figure is an error the script identified. |
| VC-15 | PKT circuit initial water charge, total | ECN-021 §1: "~10,400–16,640 t" for 2.08M circuits at 5,000–8,000 kg each | **10.4–16.6 Mt** (2.08M × 5,000–8,000 kg) | **Factor-1000 error in ECN-021.** Load-bearing: §2 argues the supply chain covers it. |
| VC-16 | Gangue moisture loss at P14 | ECN-021 §3: "~375,000–750,000 t/yr" | **375–750 Mt/yr** (7.5 Bt/yr gangue × 5–10 %) | Same factor-1000 error. This is the dominant water loss in the programme and dwarfs every supply figure. |
| VC-17 | PKT process water supply adequacy | ECN-021 §2.2: 200–600 t/yr via MD-1 covers demand | Sustained need ≈ **198,000 t/yr** (94,000 fill + 104,000 top-up) → **~330× shortfall**. A 100 m C-type at 10 wt% yields ~79,000 t total ≈ 0.4 yr of need. | Consequence of VC-15/16. The water supply chain does not close at P14 as written. |
| VC-18 | Phase 1 / early-programme cost | Team Phase 1 evaluation: **US$51–73 B** for initial site prep, robotics, 4-crew habitat, power/comms, ECLSS, management | ECON v1 P0–P4 CapEx sums to **~US$27 B**; ECON v1.3 total programme **$21.31 T** over 200 yr | Different scope definitions ("Phase 1" ≠ P0–P4) and different cost bases. Reconcile before the final report quotes both. |
| VC-19 | Programme CO₂ | Team environmental table: **25,000 t CO₂e** (150 Starship launches + probes/RTG/infra), Bayan Obo **12 Mt CO₂e** | ECON v1.3: lifetime rocket CO₂ **52 Mt**; avoided **182 Mt/yr** at steady state | Team figures are Phase-1-scoped; ECON is 200-year. Both defensible, not comparable as printed. |
| VC-20 | CO₂ per Starship launch | ECN-020 §3: **2,683 t** | ECON v1: **2,200 t** (`launch.co2_per_launch`); ECON v1.4 methodology: **2,750 t** declining with DAC methane ramp | Three values for one parameter, used in every environmental claim the programme makes. ECON v1.4 is the current computational authority. |
| VC-21 | ECN-020 propagation completeness | Treated throughout as fully applied (Strategy v3.1, Fleet v9, Guide v18, Decision Framework Rev D all carry it) | ECN-020 §6 also requires **SEL-CATAPULT-001 Rev B → Rev C** (add §5.1 Parallel Track Architecture). Only Rev A and Rev B exist. | One outstanding propagation. Catapult doc is authoritative for per-driver YBCO, so it is the doc that most needs the track counts. |
| VC-14 | Scaling model identity | "SELENITE_SCALE v1.3" treated as current | **SCALE v1.3 is pre-ECN-019**: PKT SKIPs (3,557 at P8), tankers, 48,990 MOLE-I at P8, 2.5M circuits at P12, 1 Mt/yr target | Reclassify SCALE v1.3 HISTORICAL. ECON v1.3/v1.4's bottom-up infrastructure derivation is the current scaling authority. |

## Consistent (goldens and documents agree)
MOLE-I dry mass 360.35 kg; tether draw 1,934 W; keep-alive 65 W; transit
battery 334 Wh; substation 96 W; PROBE 3/6/10/15/30; ARM-D 1/2/4/6/8;
MOLE-S 4/4/4/6/6; SENTINEL 2/2/3/4/4; circuits 2,083,334 at 2.5 Mt/yr and
~417,000 at Y120; 1.5M haulers at steady state; $21.31 T, NPV −$0.49 T,
BCR 0.502 / 2.06, +$121.8 B/yr at Y200; 182 Mt CO₂/yr avoided.

## Rule
The Python port reproduces the goldens. Tests are never edited to match a
document. When Wave 5 adjudicates a row above, the decision is an ECN, the
script (Python by then) changes, a new golden is cut, and the documents follow.
