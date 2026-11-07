# SEL-ECN-027 — By-product oxygen: store before dumping, closed-circuit use

**Reference:** SEL-REQ-005 (`model/ProgrammeRequirements.sysml`), SEL-REQ-018 (new), `SeleniteHabitat::ByProductOxygenStore` (new), `SeleniteSites::L1OxygenDepot`; `docs/SEL-ECON-001_RevA_revised.md` §8.4; `CHANGELOG_WAVE4B.md` W4B-N4 / N18 / N27

**Date:** 7 November 2026 | **Status:** **SIGNED and APPLIED (Jason, 7 Nov 2026).** The file keeps its draft name for the document map. | **Author:** Wave 4B addendum session for Jason (Systems Engineering Lead)

---

## 1. Problem statement

SEL-REQ-005 (Wave 1) says every process by-product is used at scale and O2 is "routed to the L1 fuel depot via MD-2, not vented or dumped". The Wave 4B addendum found its source, SEL-ECON-001 Rev A revised §8.4, which says the PKT by-product oxygen is "initially vented or stored" through P8–P14 and lofted as LOX to an Earth–Moon L1 depot only at P14+ (DG-14.4). The two statements conflict (W4B-N27), and the model carried no element for the storage or the policy.

## 2. Decision (Jason, 7 Nov 2026)

1. **Dump as little as possible.** Excess oxygen is stored at the base. Only when the storage capacity is used up is oxygen dumped.
2. **Capacity is a quantity to work out**: how much storage can feasibly be given under the space constraints at each base — a Wave 5 task (`ByProductOxygenStore.storageCapacity`, UNBOUND).
3. **Balance the oxygen as a closed circuit**: find the uses that absorb it (habitat ECLSS, LOX for the depot and the IZ propellant farm, process oxidant, anything else the flowsheets can take) so that dumping is the last resort — a Wave 5 balance task on the stream quantities.

## 3. What changed in the model

- `SeleniteHabitat::ByProductOxygenStore` (new): `excessStored = true`, `dumpOnlyWhenStorageExhausted = true` asserted (`storeBeforeDump`); `storageCapacity` UNBOUND.
- SEL-REQ-018 `ExcessOxygenStoredBeforeDumping` (new), instantiated and satisfied on the SPA and PKT stores in `SeleniteConfigurations`.
- SEL-REQ-005 doc: "not vented or dumped" read as this policy; the depot element and its derived `existsFrom` unchanged.
- `PktProcessingSpine.byProductOxygen` port; the SPA electrolyser oxygen and the PKT spine oxygen connected to the stores.
- No committed value rebound; the plan register is unchanged.

## 4. Open after this ECN

The depot's phase (ECON §8.4 P14+ / DG-14.4 vs the model's derived MD-2 phase) stays recorded under W4B-N27 for Wave 5, which binds the capacity and the oxygen balance and can then settle whether `existsFrom` follows DG-14.4.
