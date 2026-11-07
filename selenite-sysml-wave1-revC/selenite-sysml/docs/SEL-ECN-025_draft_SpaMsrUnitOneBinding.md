# SEL-ECN-025 — SPA MSR unit #1: bind `introducedIn` to DG-13.4 (ECN-022 §2.3 carry-through) or keep DG-10.5

**Reference:** SEL-ECN-022 §2.3; `model/ProgrammeConfiguration.sysml` (`shackletonHub.powerZone.spaMsr`); `model/Gates.sysml` (DG-10.5, DG-11.3, DG-13.4, DG-14.4, DG-14.7); `model/Power.sysml` (`SpaThoriumMSR`); `docs/PLAN_REGISTER.md` (W3-R13, W3-R16, W3-R33, W3-R37, element row `spaMsr.introducedIn`); `CHANGELOG_VERIFICATION.md` (V-N, item 4)

**Date:** 6 November 2026 | **Status:** **SIGNED and APPLIED (Jason, 6 Nov 2026): option 2a.** `shackletonHub.powerZone.spaMsr.introducedIn` rebound to `gates.dgThirteenFour.derivedPhase`; `docs/PLAN_REGISTER.md` regenerated and the plan_check fixture re-cut. The file keeps its draft name for the document map. | **Author:** verification session for Jason (Systems Engineering Lead)

---

## 1. Problem statement

The configuration binds the SPA thorium MSR's `introducedIn` to the derived phase of **DG-10.5**:

```
part redefines spaMsr : SpaThoriumMSR {
    doc /* F5: demand-gated through DG-10.5 (SpaMsrIntroductionGate). */
    attribute redefines introducedIn = gates.dgTenFive.derivedPhase;
}
```

SEL-ECN-022 §2.3 (19 Sep 2026) decided the SPA MSR by the FSP-versus-MSR cargo-mass trade and recorded: "DG-10.5 (Y50) and DG-11.3 (Y70) as commissioning gates — superseded; DG-13.4 (Y105) stands as unit #1; DG-14.4 / DG-14.7 stand as #2 / #3." The binding was not moved: the element still hangs off a gate the same ECN superseded. Nothing is wrong in the numbers — all five gates share `SpaMsrIntroductionGate` and `plan_vectors.fsp_msr_trade`, so each derives Y105 and the plan register already prints the unit-#1 year under every one of them — but the *selection* of which gate owns the element is a decision, and rebinding it is therefore an ECN, not a verification fix (brief: "anything that would change a bound value, a threshold, a selection or a decision is a draft ECN").

At verification the gate docs were brought up to date (value-neutral): DG-8.7 and the five SPA MSR gates no longer describe themselves as "unevaluated", and DG-10.5 / DG-11.3 now say that ECN-022 §2.3 superseded them as commissioning gates.

## 2. Options

- **2a — Rebind to DG-13.4 (RECOMMENDED, the ECN-022 §2.3 carry-through).** `attribute redefines introducedIn = gates.dgThirteenFour.derivedPhase;` with the doc "F5: demand-gated; unit #1 is DG-13.4 (ECN-022 §2.3); DG-10.5 / DG-11.3 superseded as commissioning gates". DG-10.5 and DG-11.3 stay in the catalogue (every Rev D id present once — plan_check structural check) as superseded gates that still evaluate the same trade; DG-13.4's `gatedElements` already names `SpaThoriumMSR.introducedIn (unit #1)`. The register's element row moves from "bound to DG-10.5 (P10, Y50)" to "bound to DG-13.4 (P13/P12, Y105)" — the derived year is unchanged (Y105).
- **2b — Keep DG-10.5 as the owning gate**, reading ECN-022 §2.3 as superseding only the *declared year* Y50, not the gate's role as the catalogue's first SPA-MSR entry. Then the DG-10.5 doc should say so explicitly and the register's "later than declared" verdict on DG-10.5 stays the headline for F5.
- **2c — Bind to the trade directly** (a `derivedYear` on the element from `plan_vectors.fsp_msr_trade`) at Wave 5 when `derivedPhase` is bound for every gate; the gate ownership becomes moot.

## 3. If 2a is signed

`model/ProgrammeConfiguration.sysml` lines as above; `model/Power.sysml` `SpaThoriumMSR` doc "bound to DG-10.5" → "bound to DG-13.4 (unit #1)"; `model/Gates.sysml` DG-10.5 `gatedElements` → "SpaThoriumMSR.introducedIn (superseded owner; see DG-13.4)"; `docs/PLAN_REGISTER.md` regenerated (the element row and the plan_check byte-identity fixture `tests/fixtures/plan_check_stdout_wave3.txt` re-cut); `CHANGELOG_WAVE3.md` §3 classification row `SpaThoriumMSR.introducedIn | unbound (F5) | C | DG-10.5` updated by addendum. No value, threshold or golden changes; `scenario_check` unaffected (D2 reads the trade, not the binding).

## 4. Related, not decided here

- `SeleniteAnalysis::SpaMsrIntroductionGate`'s calc body still states the withdrawn Wave 2 comparison (SPA demand > non-MSR capability) rather than the cargo-mass trade plan_check evaluates (ECN-022 §2.3). Rule 3 says calc defs mirror the Python relationship; rewriting the calc is a Wave 5 model task recorded in `CHANGELOG_VERIFICATION.md`, not an ECN.
- F5 remains "demand-gated" by rule 5c; this ECN changes which gate carries the consequence, not the rule.

---

## 5. Decision (Jason, 6 November 2026)

**Option 2a adopted and applied in the same session:** the binding, the `Power.sysml` and DG-10.5 docs and `gatedElements` as §3 lists; `docs/PLAN_REGISTER.md` regenerated (the `spaMsr.introducedIn` element row now reads "bound to DG-13.4 (P13/P12, Y105)"; derived year unchanged) and `tests/fixtures/plan_check_stdout_wave3.txt` re-cut; `CHANGELOG_WAVE3.md` §3 row updated by addendum. The §4 calc-body item stays with Wave 5.

---

*— End of SEL-ECN-025 — signed 6 Nov 2026 (option 2a applied) —*
