# SEL-ECN-024 — Hauler in-situ fraction: close flag F3 or re-source the 92 % candidate (D8 sampling)

**Reference:** `docs/DOCUMENT_FAMILIES.md` flag F3; `CHANGELOG_WAVE2.md` §0 (F2 diff); `model/Parameters.sysml` (`haulerEarthFractionFloorEcon` 0.43, `haulerEarthFractionFloorFleetV9` 0.08, `GateThresholds.haulerEarthFractionFloor` 0.20); `model/Scenarios.sysml` (`UncertaintyRegister.haulerEarthFractionFloor`, D8 `HaulerInSituFractionPolicy`); `docs/SCENARIO_REGISTER.md` §1 and §2 D8; `CHANGELOG_VERIFICATION.md` (V-N, item 2)

**Date:** 6 November 2026 | **Status:** **DRAFT — for Jason's decision; not applied.** The verification session changes no bound value, no sampling weight and no selection. | **Author:** verification session for Jason (Systems Engineering Lead)

---

## 1. Problem statement

Flag F3 (8 Sep 2026) reads: "Hauler in-situ fraction: fleet v9 / hauler brief say **92 %**; the update-session prompts and strategy items say **~57 %**. Model as an attribute with both values flagged; do not pick." Wave 4A carried the two readings into the uncertainty register as a two-point discrete entry with equal weights (`haulerEarthFractionFloor`: 0.43 from ECON v1.3 `hauler.earth_frac`, 0.08 from "fleet v9 / hauler brief 92 % in-situ"), and D8 (`HaulerInSituFractionPolicy`: `econFloor` versus `targetFloor`) samples it (`CHANGELOG_WAVE4A.md` §1 "Two-point conflicts sampled", W4A-N4).

The verification provenance audit (item 2) found that the 92 % figure is not a competing current value:

- `SEL_ROBOT_FLEET_v9.md` §10.1 (the fleet authority, F2) gives the Rev B hauler's in-situ fraction as **~57 %** (TOTAL row "~1,450 kg | ~57 %") and its Earth-fraction trajectory as 100 % (P8) → 70 % (P9) → 43 % (P10) → 33 % (P12) — the ECON v1.3 floor of 0.43 with the M-type bonus is this trajectory.
- `CHANGELOG_WAVE2.md` §0 (14 Sep 2026, F2 diff) already recorded that the "92 %" is the **superseded SEL-HAULER-001 Rev A column** shown beside Rev B in the hauler table ("the origin of F3 — 92 % is the superseded Rev A column, not a competing Rev B value"); `HAULER_SPEC_UPDATE_BRIEF.md` is the rationale for the Rev A → Rev B change.
- No document in the repository states 92 % as the current Rev B figure. The citation strings in `Parameters.sysml` and the register were corrected at verification to say so (value-neutral; the 0.08 candidate itself stays bound and sampled).

Consequence in the register: D8 is a 0.50 / 0.50 tie under every criterion (`SCENARIO_REGISTER.md` §2 D8: `econFloor` P(win) 0.50; P(DG-13.7 met by Y120) 0.5) — the tie is exactly the uninformative weight on a candidate the Wave 2 evidence had already set aside, not a finding about the haulers.

## 2. What would change

| Item | Today | If 2a | If 2b |
|---|---|---|---|
| F3 (`DOCUMENT_FAMILIES.md`) | open | **closed by evidence** (F2 diff): 92 % is Rev A | stays open with a cited current source for 92 % |
| `UncertaintyRegister.haulerEarthFractionFloor` | DiscreteReal 0.43 / 0.08, equal weights | point at 0.43 (`PointReal`; "range unbound" — rule 5d) | DiscreteReal with the sourced weight |
| `ProgrammeParameters.haulerEarthFractionFloorFleetV9` | 0.08, bound | retained as a recorded historical candidate (doc "Rev A, superseded") or removed | re-cited |
| D8 result | `econFloor` P(win) 0.50 (tie) | `econFloor` versus `targetFloor` evaluated on the ECON floor alone: P(DG-13.7 met by Y120) → 0 (W3-N5 stands: the 20 % floor is never reached on the economics) | depends on the weight |
| DG-13.7 (`haulerEarthFractionFloor` 0.20) | threshold carried as written | unchanged — the gate stays "never met" (W3-N5), a Wave 5 economics item | unchanged |

Nothing in ECON, VERIFY or the goldens moves under either option; `evaluate_d8` reads the register entry and would see a point instead of a two-point draw.

## 3. Options

- **2a — Close F3 and reduce the register entry to a point at 0.43 (RECOMMENDED).** The Wave 2 diff is the evidence; keeping a superseded column as an equal-weight candidate overstates the programme's uncertainty about its own hauler design and makes D8 unreadable (a coin toss). W3-N5 (the 20 % floor never reached) remains the real open item, for Wave 5.
- **2b — Keep F3 open and re-source the 92 %.** Only if a current document (Rev B or later, or an ECN) states ~92 % in-situ; none is in the repository.
- **2c — Keep the equal-weight sampling as a declared sensitivity.** Rule 5d would then prefer a named scenario (`haulerHighInSitu`, 0.08) rather than a distribution, since the second value has no current source.

## 4. If 2a is signed

`model/Scenarios.sysml`: `haulerEarthFractionFloor` becomes a `PointReal` bound to `parameters.haulerEarthFractionFloorEcon` with `low` / `high` unbound and the source line "F3 closed by SEL-ECN-024; 92 % is the superseded Rev A column (CHANGELOG_WAVE2 §0)"; `model/Parameters.sysml` `haulerFloorDoc` records the closure (the `...FleetV9` attribute may stay as a historical candidate, bound, or be removed — Jason's call); `docs/DOCUMENT_FAMILIES.md` F3 row → "Closed 6 Nov 2026 by SEL-ECN-024"; `docs/SCENARIO_REGISTER.md` regenerated (D8 and the §1 row); `CHANGELOG_WAVE4A.md` W4A-N4 note updated by addendum. Validate, `scenario_check --quiet`, pytest (the D8 tests in `tests/test_scenarios.py` read the register from the model and need no edit unless they assert the two-point count of 18 sampled entries — then 17).

## 5. Related, not decided here

- DG-13.7's 20 % floor against the ECON 0.33 (0.43 less the M-type bonus) — W3-N5, Wave 5 economics (VC-08 lineage).
- The DG-2.1 threshold arithmetic (Strategy v3.1 §1 product evaluates to 5,642 kg/yr; the typed VERIFY constant and the gate say 5,692) — recorded at verification, no value changes; Wave 5 decides the authority if VERIFY ever recomputes `prop_yield`.

---

*— End of SEL-ECN-024 (DRAFT) —*
