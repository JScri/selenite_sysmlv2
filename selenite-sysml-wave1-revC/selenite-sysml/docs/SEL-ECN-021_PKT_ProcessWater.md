# SEL-ECN-021 — PKT Process Water Supply Chain

**Reference:** SEL-PROC-PKT-001 Rev B, SEL-ISRU-001 Rev D, SEL-CATAPULT-001 Rev B (MD-1)

**Date:** April 2026 | **Status:** DRAFT | **Author:** Jason (Systems Engineering Lead)

---

## 1. Problem Statement

SEL-PROC-PKT-001 Rev B specifies aqueous hydrometallurgical processing (8-step flowsheet) but does not specify the source, delivery, or management of process water at PKT. PKT has no MOLE-I fleet, no PSR access, and no ISRU water plant. Each processing circuit requires an initial water charge (~5,000–8,000 kg) for leach liquor, wash water, and precipitation media. At 2.08 million circuits (P14 steady state), total initial water demand is ~10,400–16,640 t — accumulated over 155 years of circuit installation, not demanded at once.

Once charged, each circuit recirculates its process liquor internally (standard hydrometallurgical closed-loop practice). Losses are limited to moisture retained in gangue filter cake and evaporation during Step 8 calcination. Calcination off-gas condensate is recovered and returned to the circuit. Top-up water demand per circuit is negligible (<1% of charge per year).

## 2. Amendment — Phased Water Supply (Option B)

No changes to SELENITE_ECON model, MOLE-I fleet sizing, or infrastructure counts. The amendment specifies the water source and delivery method for PKT circuit commissioning, using existing infrastructure and existing propellant surplus margins.

### 2.1 Phase 1: Starship Cargo (P8, Y25–35)

First ~50 circuits commissioned with Earth-delivered water co-manifested in P8 Starship cargo flights.

| Parameter | Value |
|-----------|-------|
| Circuits commissioned | ~50 of 308 initial |
| Water per circuit | ~7,000 kg |
| Total water | ~350 t |
| Delivery rate | ~35 t/yr over 10 years |
| Delivery method | Sealed water containers in Starship cargo bay |
| Impact on cargo budget | 35 t/yr added to ~212 t/yr existing P8 cargo (16% increase) |
| Model impact | **None** — within Starship manifest margin |

Remaining ~258 circuits of the P8 initial 308 are commissioned progressively from Y30–Y45 as SPA propellant surplus becomes available (§2.2).

### 2.2 Phase 2: SPA ISRU via MD-1 (P9–P12, Y35–120)

SKIPs retire between Y35–Y45 (8 units × 83,000 kg/yr = 664,000 kg/yr propellant freed). This freed capacity is redirected: ISRU water production continues at the existing rate, but a portion is diverted pre-electrolysis (liquid water, not split into LH₂/LOX) and packaged in sealed containers for MD-1 SPA→PKT delivery.

| Parameter | Value |
|-----------|-------|
| SKIP propellant freed | ~664 t/yr (fully freed by Y45) |
| Water available for PKT | ~200–600 t/yr (phased with SKIP retirement) |
| Circuit commissioning rate | ~250/yr (P9) → ~25,000/yr (P10) → scaling |
| Water per circuit | ~7,000 kg |
| P9 water demand | 250 × 7 t = ~1,750 t/yr (within freed surplus) |
| Delivery method | MD-1 SPA→PKT (operational from P8, DG-8.0) |
| MOLE-I fleet | No change to decommission curve; units freed by SKIP retirement remain active to produce water instead of propellant |
| Model impact | **None** — total MOLE-I count unchanged, total ISRU output unchanged; only the downstream product (water vs propellant) changes |

Key insight: the MOLE-I units don't care whether their water output goes to electrolysis (propellant) or to containers (PKT process water). The same fleet, the same ISRU throughput, the same infrastructure — just a different valve downstream.

### 2.3 Phase 3: C-type Asteroid Water (P13+, Y105+)

C-type asteroid online at Y105 (DRO capture Y95). Water extraction via pyrolysis at SPA. Replaces PSR-sourced process water for PKT circuit commissioning. MOLE-I fleet completes decommission to ~50 units (retained for SPA propellant only).

| Parameter | Value |
|-----------|-------|
| Source | C-type asteroid water processed at SPA |
| Delivery | MD-1 SPA→PKT (existing) |
| MOLE-I | Drops to ~50 as planned (SPA propellant only) |
| Model impact | **None** |

## 3. Process Water Recirculation Within Circuits

Once charged, each circuit operates as a closed-loop aqueous system:

| Step | Water role | Recovery |
|------|-----------|----------|
| 1. H₂SO₄ acid bake (300°C) | Minimal water — solid-phase reaction | N/A |
| 2. Ca(OH)₂ precipitation (pH 3.8) | Aqueous slurry | Filtrate returned to leach |
| 3. U separation (H₂O₂) | Aqueous | Filtrate returned |
| 4. Ce oxidation | Aqueous | Filtrate returned |
| 5. LREE/HREE split | Aqueous | Filtrate returned |
| 6. (NH₄)₂SO₄ double salt LREE | Aqueous | Mother liquor recycled |
| 7. H₃PO₄ HREE precipitation | Aqueous | Mother liquor recycled |
| 8. Calcination | Thermal decomposition; off-gas condensate recovered | >95% water recovered from off-gas |

Gangue filter cake exits wet (~5–10% moisture by mass). At P14 steady state, gangue moisture loss is ~375,000–750,000 t/yr — significant but covered by the C-type water supply chain (Phase 3 above).

Estimated top-up rate per circuit: <50 kg/yr (0.7% of initial charge). At 2.08M circuits: ~104,000 t/yr top-up. Well within C-type + residual MOLE-I capacity.

## 4. Summary — No Model Changes Required

| Parameter | Before ECN-021 | After ECN-021 |
|-----------|---------------|---------------|
| MOLE-I fleet curve | Unchanged | Unchanged |
| MOLE-I count at any year | Unchanged | Unchanged |
| ISRU total water output | Unchanged | Unchanged |
| Propellant available | Slightly reduced Y35–45 (water diverted pre-electrolysis) | Offset by SKIP retirement freeing demand |
| Starship cargo Y25–35 | +35 t/yr (water containers) | Within existing manifest margin |
| MD-1 throughput | Unchanged | Water containers added to existing reagent manifest |
| SELENITE_ECON model | **No changes** | **No changes** |

The water was always being produced. The only change is where it goes after ISRU extraction and before electrolysis.

## 5. Affected Documents (Future Update)

| Document | Change Required |
|----------|----------------|
| SEL-PROC-PKT-001 Rev B → Rev C | Add §3.1 Process Water Supply Chain (this ECN content) |
| SEL-PROC-001 Rev B → Rev C | Add process water recirculation section for SPA circuits |
| SEL-ISRU-001 Rev D → Rev E | Add pre-electrolysis water diversion valve for PKT supply |
| MTL Guide v18 → v19 | Add P8 water delivery to PKT commissioning narrative |
| SEL-T1.1-STRATEGY v3.1 → v3.2 | Note process water supply chain in §5 or §8 |

**These updates are deferred to post-49069 submission. No impact on current report or HØW deliverables.**

---

*— End of SEL-ECN-021 —*
