# SEL-ECN-020 — Mass Driver Parallel Track Architecture

**Reference:** SEL-CATAPULT-001 Rev B (authoritative for per-driver YBCO), SEL-T1.1-STRATEGY v3.0 §9, SEL-DECISION-001 Rev D

**Date:** April 2026 | **Status:** DRAFT | **Author:** Jason (Systems Engineering Lead)

---

## 1. Problem Statement

At 2.5 Mt/yr REO (ECN-019 Rev C committed target), MD-2 PKT→Earth must launch ~694,444 canisters/yr (~1,903/day at 3.6 t REO each). A single ~5 km track requires one launch every ~45 seconds. Each parallel track is a complete coilgun — same length, same coil count, same YBCO — and cannot share coils with another track. The acceleration itself takes ~4 s at ~59g, but the full cycle (canister feed, coil pre-charge, launch, discharge/recharge, track clearance) at 45 s intervals leaves zero margin for maintenance, thermal management, or feed failures. Any single-track failure halts all REO exports.

MD-1 SPA→PKT is the only logistics link between the two bases. A single-track failure halts all inter-site material flow (Fe-Ni foundry feedstock, Th(OH)₄, spares).

## 2. Amendment

### 2.1 MD-2 (PKT→Earth): 3 Parallel Tracks

| Parameter | Single track (superseded) | 3 parallel tracks (baseline) |
|-----------|--------------------------|------------------------------|
| Tracks | 1 × ~5 km | 3 × ~5 km (~50 m lateral spacing on shared sintered foundation) |
| Cadence per track | 1,903/day (1 every 45 s) | 634/day (1 every 136 s) |
| YBCO per track | ~80 t | ~80 t (each track is a complete coilgun) |
| Total YBCO | ~80 t | **~240 t** |
| Maintenance | Zero downtime tolerance | 1 track offline at any time; 2 tracks sustain 1,268/day (67%, ~1.67 Mt/yr) |
| Supercapacitor banks | Single point of failure | Independent per track (~500 kg, 10 MJ each) |
| Cryocooler strings | Single | Independent per track |

**Operational mode:** Round-robin firing. Each track fires once every ~136 s. System-wide cadence: 1 launch every ~45 s. Maintenance rotation: 1 track taken offline per lunar day (14 Earth days).

### 2.2 MD-1 (SPA→PKT): 2 Parallel Tracks

Throughput is moderate (~5,000–10,000 t/yr), but MD-1 is the sole inter-site link. Single-track failure halts all SPA↔PKT material flow.

| Parameter | Specification |
|-----------|--------------|
| Tracks | 2 × ~3.3 km (1 primary + 1 redundant) |
| YBCO per track | ~60 t |
| Total YBCO | **~120 t** |
| Normal ops | Primary handles all traffic; secondary on warm standby |
| Maintenance | Primary offline → secondary takes full load |

### 2.3 MD-3/4/5: Single Track (No Change)

MD-3 (PKT→SPA): ~42 launches/yr. Single track adequate. YBCO: ~55 t.
MD-4 (SPA→Earth): ~10–30 launches/yr. Single track adequate. Foundation designed for future parallel. YBCO: ~70 t.
MD-5 (DRO→SPA): ~200 launches/day. Single track comfortable at 1 every ~7 min. YBCO: ~38 t.

## 3. Revised YBCO Budget

| Driver | Route | Tracks | YBCO/track (t) | Total YBCO (t) | Was (t) | Change |
|--------|-------|--------|----------------|----------------|---------|--------|
| MD-1 | SPA→PKT | **2** | 60 | **120** | 60 | +60 |
| MD-2 | PKT→Earth | **3** | 80 | **240** | 80 | +160 |
| MD-3 | PKT→SPA | 1 | 55 | 55 | 55 | 0 |
| MD-4 | SPA→Earth | 1 | 70 | 70 | 70 | 0 |
| MD-5 | DRO→SPA | 1 | 38 | 38 | 38 | 0 |
| **Total** | | **8** | | **523** | **303** | **+220 (+73%)** |

**Cost impact:** +220 t YBCO = ~2.2 additional Starship flights over programme lifetime. At ~$100M/flight = ~$220M. On a $21.3T programme, this is 0.001% of total cost. For context, the conveyor-replaces-catapult decision saved 209,000 t YBCO — parallel tracks add back 0.11% of that saving. No revision to SEL-ECON-001 required.

**CO₂ impact:** ~2.2 extra methane/LOX Starship flights × ~2,683 t CO₂/flight ≈ ~5,900 t CO₂ additional over programme lifetime. Programme avoids 182 Mt CO₂/yr at steady state. The parallel track CO₂ cost is recovered in ~12 minutes of steady-state operation.

## 4. Corrected MD-2 Canister Figures

The strategy doc v3.0 §9 carried stale figures from the pre-Rev C 1.0 Mt/yr target:

| Parameter | Stale (strat v3.0) | Corrected |
|-----------|-------------------|-----------|
| REO target | 1,000,000 t/yr | 2,500,000 t/yr |
| Canister payload | 3.5 t | 3.6 t |
| Canisters/yr | 285,715 | ~694,444 |
| Per day (system) | 783 | ~1,903 (across 3 tracks) |
| Per day (per track) | 783 | ~634 |

## 5. Per-Driver YBCO Correction

The strategy doc v3.0 §9 had per-driver YBCO allocations that disagree with SEL-CATAPULT-001 Rev B. The catapult doc is the specialist specification and is authoritative:

| Driver | Strategy v3.0 (wrong) | Catapult Rev B (authoritative) |
|--------|----------------------|-------------------------------|
| MD-1 | 60 t | 60 t (match) |
| MD-2 | 100 t | 80 t |
| MD-3 | 30 t | 55 t |
| MD-4 | 60 t | 70 t |
| MD-5 | 30 t | 38 t |
| Demo | 23 t | (included in total) |

## 6. Affected Documents

| Document | Change |
|----------|--------|
| SEL-T1.1-STRATEGY v3.0 → v3.1 §9 | Update mass driver table with parallel tracks + corrected YBCO + corrected cadence |
| SEL_ROBOT_FLEET v9 §16 | Same updates |
| SEL-CATAPULT-001 Rev B → Rev C | Add §5.1 Parallel Track Architecture (ECN-020 content) |
| MTL_GUIDE v18 | Update P12/P14+ canister figures |
| selenite_extended_timeline_v3 | P14+ notes already correct at ~695k/yr |

---

*— End of SEL-ECN-020 —*
