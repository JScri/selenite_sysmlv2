<!-- Markdown extract of docs/sources/SEL-ECLSS-SCALING-001_RevB.docx, converted 7 Nov 2026 (Wave 4B addendum). The docx is the source of record; this extract is for grep and citation. -->

SELENITE PROGRAMME
ECLSS Scaling Analysis: 4 → 6 → 12 → 20 Crew
Reference: SEL-ECLSS-SCALING-001 Rev A
Source: SEL-ECLSS-002 Rev A (4-crew baseline), SEL-HAB-001 Rev D (§6 food, §12 scalability), SELENITE_VERIFY v5.0
# 1. Purpose
SEL-ECLSS-002 Rev A specifies the complete ECLSS for 4 crew at P4, with the statement “scalable to 20 crew at Phase 7+ (H3 module + processing staff per ECN-019).” However, the detailed equipment counts, power draws, mass budgets, and radiator sizing are all locked to the 4-crew baseline. This document derives the scaled values for 6 crew (P6) and 12 crew (P7+) from first principles, using the 4-crew specification as the anchor. All figures are derived from BVAD metabolic rates (82 kg reference crew, 90 min/day exercise), stoichiometric mass balances (MATLAB-verified at 4-crew in ECLSS-002), and linear scaling where subsystem physics permit.
★ The 4-crew baseline cross-checks exactly: ECLSS power 6.9 kW (excl greenhouse) / 21.4 kW (with greenhouse) matches the ECLSS-002 Rev A §12 budget. All scaling below preserves this anchor.
# 2. Habitat Module Phasing
| Phase | Crew | Modules | Notes |
|---|---|---|---|
| P4 (Y7–9) | 4 | Ops Hub + H1 + H2 + EVA Vestibule | Crew-1 arrival. 518 m³ pressurised. |
| P5 (Y9–12) | 4 | Add F1 (food arm) | Greenhouse online. 657 m³. 48 m² growing. |
| P6 (Y12–15) | 6 | Add H3 (hab arm extension) | Crew-2. 5 pressurised modules + EVA. ~760 m³. |
| P7+ (Y20+) | 12 | H1–H5 + F1–F2 + Ops + EVA | Full build. 9 pressurised modules. ~1,213 m³. |
| P7+ (Y20+, ECN-019) | 20 | H1–H5 + F1–F2 + Ops + EVA + H3 processing | H3 adds 4 processing staff (ECN-015→ECN-019). 11 pressurised modules. ~1,400 m³. |

# 3. Metabolic Loads (per Crew-Member per Day)
All rates from NASA BVAD (82 kg reference crew, 90 min/day exercise). These are the fundamental inputs to every ECLSS subsystem.
| Parameter | Per CM | 4 Crew | 6 Crew | 12 Crew |
|---|---|---|---|---|
| CO₂ production (kg/day) | 1.00 | 4.00 | 6.00 | 12.00 |
| O₂ consumption (kg/day) | 0.84 | 3.36 | 5.04 | 10.08 |
| Drinking + food prep water (kg/day) | 2.50 | 10.00 | 15.00 | 30.00 |
| Perspiration + respiration (kg/day) | 3.00 | 12.00 | 18.00 | 36.00 |
| Urine (kg/day) | 1.50 | 6.00 | 9.00 | 18.00 |
| Faeces (kg/day) | 0.12 | 0.48 | 0.72 | 1.44 |
| Urine nitrogen (kg N/day) | 0.011 | 0.044 | 0.066 | 0.132 |

# 4. CO₂ Removal — CDRA Scaling
Each 4-bed CO₂ removal assembly (4BCO₂, ISS heritage) processes up to 4.2 kg CO₂/day. At 4 crew (4.0 kg/day), a single unit operates at 95% capacity with minimal headroom. Units are added when crew CO₂ exceeds single-unit capacity.
| Phase | Crew | CO₂ (kg/d) | CDRA Units | Power (kW) | Notes |
|---|---|---|---|---|---|
| P4/P5 | 4 | 4.0 | 1 | 0.8 | 95% utilisation. Tight — no margin for crew metabolic variation. |
| P6 | 6 | 6.0 | 2 | 1.1 | 2nd unit added with H3. 71% utilisation per unit. Comfortable. |
| P7+ | 12 | 12.0 | 3 | 2.3 | 95% utilisation (3 × 4.2 = 12.6). Tight again — consider 4th unit as cold spare. |
| P7+ (20 crew) | 20 | 20.0 | 5 | 3.8 | 5× CDRA at 95% (20.0/21.0). Single failure → 4 units at 16.8 → crew at 84% capacity (manageable). |

⚠ At 12 crew, 3 CDRA units operate at 95% capacity (12.0/12.6). A single-unit failure drops capacity to 8.4 kg/day against 12.0 kg demand — crew must reduce metabolic output (rest protocol) or vent cabin CO₂ via emergency dump. Recommend manifesting 4th CDRA as cold spare. At 20 crew: 5 CDRA units at 95%. Single failure → 4 units at 80% capacity — manageable with rest protocol.

# 5. O₂ Generation — OGA Scaling
The in-hab OGA serves dual purpose: (1) H₂ production for Sabatier, and (2) backup O₂ during ISRU outages. ISRU is the primary O₂ source (hundreds of kg/day from electrolysis). OGA power scales with H₂ throughput, which is set by the Sabatier CO₂ processing rate.
| Phase | Crew | H₂ for Sab (kg/d) | OGA Units | Power (kW) | Notes |
|---|---|---|---|---|---|
| P4/P5 | 4 | 0.43 | 1 | 0.9 | Baseline. 3.86 kg H₂O/day consumption from potable bus. |
| P6 | 6 | 0.80 | 1 | 1.7 | Single unit at ~1.9× throughput. Approaching rated limit. |
| P7+ | 12 | 1.59 | 2 | 3.5 | 2nd unit required. 14.3 kg H₂O/day. Each unit at ~1.9× baseline. |
| P7+ (20 crew) | 20 | 2.65 | 3 | 5.8 | 3rd OGA unit. 23.9 kg H₂O/day. N+1 redundancy. |

# 6. Sabatier Reactor Scaling
CO₂ + 4H₂ → CH₄ + 2H₂O. Recovers water from exhaled CO₂. The CO₂ split between Sabatier and greenhouse scales dynamically (per HAB-001 §6.1). At P7+ (12 crew, 96 m²), 73% of CO₂ goes to Sabatier.
| Phase | CO₂ to Sab (kg/d) | H₂O Recovered | CH₄ Vented | Power (kW) | Notes |
|---|---|---|---|---|---|
| P4/P5 | 2.36 | 1.93 kg/d | 0.86 kg/d | 0.2 | Single unit. Scenario C balanced. |
| P6 | 4.38 | 3.58 kg/d | 1.59 kg/d | 0.4 | Single unit at ~1.9× throughput. |
| P7+ | 8.76 | 7.17 kg/d | 3.19 kg/d | 1.5 | 2 units required. CO₂ buffer tank: 50→100 kg capacity. |
| P7+ (20 crew) | 14.6 | 11.9 kg/d | 5.3 kg/d | 2.5 | 3 Sabatier units. CO₂ buffer: 150 kg capacity. |

# 7. CCAA (Humidity + Temperature) Scaling
One CCAA unit per pressurised module. Unit count scales with the habitat expansion, not directly with crew count. Each unit: ~90–120 kg, ~400 W, wall-mounted 600×500×400 mm. Gravity-drain condensate heat exchanger (1/6 g functional).
| Phase | Modules | CCAA Units | Power (kW) | Notes |
|---|---|---|---|---|
| P4 | 4 (Ops+H1+H2+EVA) | 4 | 1.6 | Baseline. |
| P5 | 5 (+F1) | 5 | 2.0 | F1 unit handles greenhouse humidity (high transpiration). |
| P6 | 6 (+H3) | 6 | 2.4 |  |
| P7+ | 9 (Ops+H1–H5+F1–F2+EVA) | 9 | 3.6 | Condensate: 36 kg/day (largest WRS input stream). |
| P7+ (20 crew) | 11 (+H3 processing) | 11 | 4.4 | Condensate: 60 kg/day. |

# 8. Water Recovery + Waste Processing
WRS (UPA + WPA + brine processor) scales linearly with crew. Nitrification bioreactor scales linearly. Combined power estimate ~1.5 kW at 4 crew.
| Phase | WRS Power (kW) | Waste Power (kW) | Bioreactor (L) | Notes |
|---|---|---|---|---|
| P4/P5 (4 crew) | 1.5 | 0.3 | 25 | Baseline. |
| P6 (6 crew) | 2.2 | 0.5 | 38 | 1.5× throughput. |
| P7+ (12 crew) | 4.5 | 0.9 | 75 | 3× throughput. Consider 2nd WRS rack for redundancy. |
| P7+ (20 crew) | 7.5 | 1.5 | 125 | 4× WRS units (3 active + 1 spare). 5× throughput vs P4. |

# 9. Thermal Rejection — Radiator Scaling
All electrical power input to the habitat ultimately becomes heat. Radiator sizing = total hab electrical load ÷ 350 W/m² (double-sided silverised Teflon, Novec 7200 loop) × 1.15 margin.
| Phase | Hab Heat Load (kW) | Radiator Area (m²) | Panels (3.5×2 m) | Notes |
|---|---|---|---|---|
| P4 (no GH) | 8.9 | 29 | ~4 | ECLSS only. |
| P5 (4 crew + GH) | 21.3 | 70 | ~10 | Greenhouse LEDs dominate (+14.5 kW). |
| P6 (6 crew + GH) | 24.4 | 80 | ~12 | Matches ECLSS-002 “future growth to 80+ m²”. |
| P7+ (12 crew + 2×GH) | 48.9 | 161 | ~23 | 2.8× P5 area. Major infrastructure expansion. Deploy on Ops Hub mast array. |
| P7+ (20 crew + 2×GH) | 81.5 | 269 | ~39 | 1.67× P7+ (12 crew) area. ~3,766 kg radiator mass. Major cargo allocation. |

⚠ 269 m² (20 crew) of radiator at P7+ is a significant mass addition (~3,766 kg at 14 kg/m²). This must be manifested across Cargo Launches 4 and 5.

# 10. N₂ Management Scaling
N₂ loss is driven by EVA frequency (suitport interface losses) and structural leakage (scales with pressurised volume). The suitport interface loss per EVA is independent of crew count — it depends on how many crew go EVA simultaneously, not total crew.
| Phase | Suitport Loss (kg/yr) | Structural (kg/yr) | Total (kg/yr) | Notes |
|---|---|---|---|---|
| P4/P5 (4 crew) | ~16 | ~40 | ~56 (+25 full-depress) | 104 routine EVAs × 0.15 kg + 12 full depress. |
| P6 (6 crew) | ~20 | ~45 | ~65 (+30 full-depress) | More EVAs (130/yr est). Volume: ~760 m³. |
| P7+ (12 crew) | ~24 | ~55 | ~79 (+40 full-depress) | ~160 EVAs/yr. Volume: 1,213 m³. Total ~119 kg/yr. Resupply: ~120 kg/yr N₂. |
| P7+ (20 crew) | ~32 | ~75 | ~107 (+55 full-depress) | ~220 EVAs/yr. Volume: ~1,400 m³. Resupply: ~160 kg/yr N₂. |

★ At 20 crew, annual N₂ resupply rises to ~160 kg/yr (from ~81 at 4 crew). Still a trivial mass fraction of cargo launches (~0.24% of a 50 t Starship).

# 11. Integrated ECLSS Power Budget by Phase
This is the key output of this document. The 4-crew column cross-checks against ECLSS-002 Rev A §12 (6.9 / 21.4 kW).
| Subsystem | P4 (4 crew) | P6 (6 crew) | P7+ (12 crew) | Conf | Scaling Method |
|---|---|---|---|---|---|
| CDRA | 0.8 kW | 1.1 kW | 2.3 kW | HIGH | Linear with CO₂ load + unit step. |
| OGA (enlarged) | 0.9 kW | 1.7 kW | 3.5 kW | MED | Linear with H₂ throughput. |
| Sabatier | 0.2 kW | 0.4 kW | 1.5 kW | MED | Linear with CO₂ input + unit step. |
| CCAA | 1.6 kW | 2.0 kW | 3.6 kW | HIGH | 1 unit per module (400 W each). |
| TCCS | 0.2 kW | 0.2 kW | 0.5 kW | MED | Linear with crew + volume. |
| Waste processing | 0.3 kW | 0.5 kW | 0.9 kW | MED | Linear with crew. |
| WRS (UPA+WPA+brine) | 1.5 kW | 2.2 kW | 4.5 kW | MED | Linear with crew. |
| Monitoring + fire + pumps | 1.4 kW | 1.8 kW | 3.1 kW | MED | Linear with module count. |
| ECLSS TOTAL (excl GH) | 6.9 kW | 9.9 kW | 19.9 kW |  | cf. ECLSS-002: 6.9 kW ✓ |
| Greenhouse LEDs | 14.5 kW | 14.5 kW | 29.0 kW | MED | 302 W/m² × area (48→96 m²). |
| TOTAL (with GH) | 21.4 kW | 24.4 kW | 48.9 kW |  | cf. ECLSS-002: 21.4 kW ✓ |

⚠ The Fleet power budget table (SEL_ROBOT_FLEET v9 §12) currently shows ECLSS as constant 6.0 kW across all phases. This must be updated: P4/P5: 6.9 kW, P6: 9.9 kW, P7+: 19.9 kW (excl greenhouse). The “Habitat + lighting + computing” row should similarly scale from 6.5 kW to ~10 kW at P7+ (9 modules vs 4).
# 12. Equipment Mass Scaling
| Equipment | P4 (4 crew) | P6 (6 crew) | P7+ (12 crew) | Notes |
|---|---|---|---|---|
| CDRA | ~150 kg (1×) | ~300 kg (2×) | ~450 kg (3×) | +1 cold spare recommended at P7+. |
| OGA (enlarged) | ~400 kg (1×) | ~400 kg (1×) | ~800 kg (2×) |  |
| Sabatier | ~100 kg (1×) | ~100 kg (1×) | ~200 kg (2×) | CO₂ buffer tank: 50→100 kg. |
| CCAA | ~400 kg (4×) | ~600 kg (6×) | ~900 kg (9×) | ~100 kg each. |
| TCCS | ~60 kg | ~60 kg | ~90 kg | Charcoal bed + catalytic oxidiser. |
| Waste (TCPS + bioreactor) | ~200 kg | ~280 kg | ~450 kg | Bioreactor scales: 25→75 L. |
| WRS | ~800 kg | ~1,000 kg | ~1,600 kg | UPA + WPA + brine processor. |
| Monitoring + fire + pumps | ~500 kg | ~650 kg | ~1,100 kg | Sensors, PFE, fluid loops. |
| Radiator array | ~800 kg (57 m²) | ~1,120 kg (80 m²) | ~2,254 kg (161 m²) | 14 kg/m² incl structure. |
| Greenhouse (racks+LEDs+nutrient) | ~2,060 kg (48 m²) | ~2,060 kg (48 m²) | ~3,600 kg (96 m²) | F2 module adds 48 m². |
| TOTAL ECLSS EQUIPMENT | ~5,470 kg | ~6,570 kg | ~11,444 kg | cf. ECLSS-002: 5,570 kg ✓ |

★ The ~5,900 kg delta between P4 and P7+ ECLSS equipment mass (5,470 → 11,444 kg) must be distributed across Cargo Launches 3–5. The radiator expansion alone (57 → 161 m², +1,454 kg) requires dedicated cargo allocation.
# 13. ISRU Life Support Demand
Life support water demand is trivially small relative to ISRU propellant production. The following table confirms this at all crew levels.
| Parameter | 4 Crew | 6 Crew | 12 Crew | vs ISRU Total |
|---|---|---|---|---|
| Potable water makeup (kg/day) | 1.4–6.0 | 2.1–9.0 | 4.2–18.0 | <0.14% of ISRU output |
| OGA water for H₂ (kg/day) | 3.9 | 7.2 | 14.3 | <0.11% |
| O₂ from ISRU (kg/day) | ~0 (surplus) | ~0 (surplus) | ~0 (surplus) | OGA+GH exceed crew O₂ demand |
| Total life support (t/yr) | ~1.9 | ~3.0 | ~6.2 | 0.64% of 967.6 t/yr ISRU |
| Propellant balance impact | Negligible | Negligible | Negligible | +3 t/yr demand → absorbed by 100 t/yr surplus |

★ Even at 20 crew, life support consumes <1% of ISRU water output. The propellant balance (867.6 t/yr demand, 967.6 t/yr supply, +100 t/yr surplus) is unaffected. 20 crew adds ~3 t/yr water demand — absorbed within surplus.. No MOLE-I fleet scaling needed for crew expansion.
# 14. Propagation Checklist
The following documents require updates when crew scaling values are committed:
| Document | Section | Change Required |
|---|---|---|
| SEL-ECLSS-002 Rev A | §12 Mass + Power | Add P6/P7+ rows to equipment mass and power tables. |
| SEL-ECLSS-002 Rev A | §11 Radiator | Update from “57 m², future 80+” to phased: 57→80→161 m². |
| SEL-ECLSS-002 Rev A | §2 CDRA | Add 2nd (P6) and 3rd (P7+) unit sizing. Cold spare note. |
| SEL-ECLSS-002 Rev A | §2.2 OGA | Add 2nd unit at P7+. Scale water consumption. |
| SEL-ECLSS-002 Rev A | §3 Sabatier | Add 2nd unit at P7+. CO₂ buffer tank 50→100 kg. |
| SEL-ECLSS-002 Rev A | §9 Waste | Scale bioreactor 25→75 L. Add 2nd WRS rack note. |
| SEL_ROBOT_FLEET v8 | §12 Power budget | ECLSS row: 6.0 kW constant → 6.9/9.9/19.9 kW phased. |
| SEL_ROBOT_FLEET v8 | §12 Power budget | Habitat row: 6.5 kW constant → 6.5/8.0/10.0 kW phased. |
| SEL-POWER-001 Rev A | §2 Consumer table | Habitat line: 50/55/63 kW → recalculate with ECLSS scaling. |
| SEL-HAB-001 Rev D | §12 Scalability | Cross-reference this document for ECLSS equipment at each phase. |

ECN-019 Amendment — 20-Crew Baseline (April 2026)
Reference: SEL-PROC-001 Rev A
Baseline crew count updated to 20 (from 12 original, 16 ECN-015) for P7+ steady state. H3 module adds living quarters for processing facility staff. 20 crew = 16 base operations + 4 processing/research specialists. Water demand: 20 × 2.5 kg/day = 50 kg/day (was 30 at 12 crew). Still <0.5% of ISRU output — no MOLE-I fleet impact. Key scaling changes at 20 crew: CDRA 3→5 units, OGA 2→3 units, Sabatier 2→3 units, CCAA 9→11 units, WRS 2→4 units (3+1 spare), radiator 161→269 m² (+3,766 kg), N₂ resupply ~160 kg/yr. ECLSS power (excl GH): ~33.2 kW. Total with 2× greenhouse: ~62.2 kW. Total ECLSS equipment mass at 20 crew: ~16,500 kg (vs 11,444 at 12 crew, +5,056 kg delta).
— End of Document —