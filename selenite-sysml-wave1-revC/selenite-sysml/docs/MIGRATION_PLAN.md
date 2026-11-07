# Migration Plan — Documents to SysML v2

Strategy: migrate by **wave**, not by document. Each wave produces a
validated, diagrammable model increment; `mapping/document_map.csv`
tracks per-document status. Vocabulary in use (6 Nov 2026): `planned |
skeleton | architected | gated | applied | delivered | generated | folded |
heritage_only | reference_only | reference_integrator | cited_external |
team_input | python_port | python_port_figures | excluded_until_propagated |
out_of_scope`, plus `superseded` for a source revision kept only as history
and `draft_awaiting_decision` for an ECN draft before Jason signs it. Documents are never deleted — they remain
the historical record and the provenance cited in model `doc` comments.

## Wave 1 — Architecture skeleton ✅ COMPLETE (this scaffold)

Dual-site instance tree, phase enumeration, fleet/transport/processing/
power/habitat definition skeletons, six committed-principle requirements
(SEL-REQ-001..006) with one machine-checkable constraint (zero crew at
PKT), calc exemplars, toolchain, CI, diagrams. Everything validates at
exit 0, zero hints.

## Wave 2 — Architecture and temporal skeleton ✅ COMPLETE (14 Sep 2026)

Build the *what / how / when* before any *how much*. From
`docs/ARCHITECTURE_BASELINE.md`: every element (sites, nodes, fleet classes
incl. Hauler Rev B, CAP, redirect tugs, Laser Ablation Truss; SPA/PKT/DRO
facilities; MD-1..5 links; SENTINEL as a system element) exists in the model
with `introducedIn` / `retiredIn` phase attributes, allocation to site, and
`doc` provenance to its family winner. New files: `Software.sysml`,
`PsrNetwork.sysml`. Phase enum gains year ranges and the P6→P7 gap flag.
No numeric attributes beyond counts that define structure (e.g. 5 mass
drivers, 8 tracks). Exit: every `wave=2` row in `document_map.csv` at
`skeleton` → `architected`; `sysml-validate` exit 0; diagrams regenerate.

Delivered 14 Sep 2026 — see `CHANGELOG_WAVE2.md`. Phase-attribute idiom
fixed (`abstract attribute x : Phase` + `attribute redefines x = Phase::Pn`),
zero hints. Open flags F3–F8 recorded in `doc` comments, none resolved; F2
resolved by diff (`v9.md` is the fleet winner). F5 leaves `SpaThoriumMSR.
introducedIn` unbound by design.

## Python port — prerequisite track (DONE 14 Sep 2026, night)

`selenite-compute/` is the computational authority: the six current-baseline
scripts are ported and reproduce the runner v2.1 goldens (1,404 rows exact
or within the ODE rules, 33 declared skips) and the captured console text.
`pytest selenite-compute` runs 1,443 checks in the CI job next to
`sysml-validate`. Findings are in `selenite-compute/CHANGELOG_PORT.md`
(R2025a `fzero` semantics, two ECON sensitivity inconsistencies, no
undiscounted break-even within 200 years). Wave 5 can now bind derived
values from `selenite.econ.workspace()` and friends.

## Wave 3 — Gates and the derived programme plan ✅ DELIVERED (15 Sep 2026)

Decision (Jason, 14 Sep 2026): timing is not gated on a predetermined phase
where a condition on model data decides it. The documents are inconsistent
with each other (W2-N1…N18); the model plus the Python layer become the
single source of decisions, and documents become renderings.

Three kinds of "when": **consequences** (derivable from quantities — SPA
MSR, Mk III transition, SKIP retirement, conveyor deployment, MSR
increments), **decision gates with criteria** (DG-x.y: breeding ratio,
circuit throughput, site grade — the criterion and prerequisite chain are
modelled, the pass/fail outcome is a declared assumption), and **exogenous
inputs** (REO ramp, crew policy, capture years, launch cost, PSR capacity).

Skeleton delivered at Wave 3 kick-off: `SeleniteParameters` (exogenous
inputs with provenance; unbound where the Python layer supplies them),
`SeleniteGates` (14 gates with criterion, evaluability, `declaredPhase`,
`derivedPhase` unbound, prerequisites, gated elements), first derived
bindings (`SpaThoriumMSR` via `SpaMsrIntroductionGate`; `StarshipReturnLink.
retiredIn = md4.operationalFrom`). Remaining Wave 3 work: read
`SELENITE_DECISION_FRAMEWORK_v4.md` and Strategy v3.1 (add both to the
repo), complete the gate catalogue and milestones M0–M8, rebind every
`introducedIn` to a gate or a parameter, write `tools/plan_check.py`
(compares derived vs declared phases, prints the register automatically),
and the SEL-REQ-0xx extraction with `satisfy` links as originally planned.
Evaluation of derivable gates waits on the Python port.

Delivered 15 Sep 2026 — see `CHANGELOG_WAVE3.md` §"Wave 3 delivery". All 81
Rev D gates are `DecisionGate`s (39 derivable with calcs and thresholds, 13
test outcomes with `assumedOutcome`, 29 exogenous); every phase attribute is
classified and the consequences are bound to gate outcomes in the
configuration; `SeleniteParameters` completed (PSR capacity 620 from
`psr_layout.py`); SEL-REQ-001..016 with checkable subjects;
`tools/plan_check.py` prints the register (`docs/PLAN_REGISTER.md`, 55 rows)
and runs in the `compute` CI job. Left for Wave 5: bind `derivedPhase` from
the planner; add the SPA demand vector beyond P7 (F5), the thorium stockpile
vector and the tier resource parameters so the seven unevaluated derivable
gates evaluate; adjudicate the register findings (W3-N1…N20) by ECN.

Closed 19 Sep 2026 with SEL-ECN-022 (`docs/`): the extension vectors landed
(`plan_vectors.py`), thorium and the SPA MSR trade are bound, MD-4 is bound
to the M-type arrival, milestones follow MTL v8.5. Rev E of the Decision
Framework is a Wave 5 rendering.

## Wave 4 — split 20 Sep 2026 into 4A (scenarios) and 4B (behaviour)

### Wave 4A — Scenarios, uncertainty and decision analysis ✅ DELIVERED (6 Nov 2026; brief: `docs/SESSION_BRIEF_wave4_scenarios.md`)

Decision (Jason, 20 Sep 2026): the model must parameterise per scenario,
compute and compare alternatives under uncertainty and guide the selection;
where an input is not deterministic the plan carries its distribution
(stochastic optimisation by sample-average approximation over discrete
alternatives, recourse decisions re-evaluated per sample). First case: the
SPA eclipse operating strategy behind `spaAsteroidLoadCriticalFraction`
(SEL-ECN-022 §2.4) — "fine if the power-intensive work is done while the
eclipse is not present" makes it a strategy to trade, not a constant to type.
Delivers `model/Scenarios.sysml` (decision catalogue D1–D8 as variations, an
uncertainty register bound to the existing parameter ranges, trade-study
analyses), `selenite/scenarios/` (parametrised ECON equal to the port at
defaults, common-random-number sampler, criteria), `tools/scenario_check.py`
printing `docs/SCENARIO_REGISTER.md` in CI, and a draft ECN-023 for the
eclipse strategy. Committed parameters are never rebound by the wave; the
draft ECN carries the recommendation to Jason.

Delivered 6 Nov 2026 — see `CHANGELOG_WAVE4A.md`. D1–D8 catalogued as
variations with their trade studies; the uncertainty register binds 32
entries (18 sampled from sourced ranges, 14 points with the reason stated);
D1–D8 all evaluated stochastically (none stubbed); `econ_param` equals the
port bit-for-bit at defaults; `plan_check` output byte-identical by default;
`docs/SCENARIO_REGISTER.md` at n = 2,000 with the convergence line; the D1
result and the derived `spaAsteroidLoadCriticalFraction` per strategy are in
`docs/SEL-ECN-023_draft_EclipseOperatingStrategy.md`, signed and applied
6 Nov 2026 (duty cycle, fraction 0.18). Open
questions 2–4 of the brief are answered in the ECN draft (dark fraction from
Gläser et al. 2014; a Czochralski batch fits the sunlit window; D3 in
scope); question 1 (the default criterion) is proposed, not decided.

### Verification after Wave 4A ✅ DELIVERED (6 Nov 2026; brief: `docs/SESSION_BRIEF_verification_post_wave4a.md`)

An audit, not a build: the ten brief items (model integrity, provenance,
rule 3, the gate catalogue against Rev D, configuration bindings,
requirements, the Python layer, the scenario layer, registers versus
documents, the document map and families) recorded as pass or finding
V-N1 … V-N46 in `CHANGELOG_VERIFICATION.md`. No bound value disagrees with
its source; determinism (n = 2,000 byte-identical) and robustness (seed 1,
Sobol: no recommendation changes) hold; `econ_param` equals the port
bit-for-bit. 46 observations: value-neutral fixes applied (citation strings,
stale statuses and doc comments, 20 missing definition docs, map rows and
package names, a stale diagram, the register's number formatting and D1
caption); three ECNs raised — **SEL-ECN-024** (signed 6 Nov 2026: flag F3 closed, the
hauler floor a point at the ECON 0.43), **SEL-ECN-025** (signed 6 Nov 2026:
SPA MSR unit #1 bound to DG-13.4), **SEL-ECN-026** (signed 7 Nov 2026: DG-12.3 783 → 1,903/day
and DG-8.5 308 → 105 circuits aligned to ECN-020 / ECN-022) — and the consolidated open-items list
for Waves 4B and 5 (`CHANGELOG_VERIFICATION.md` §4), which both waves start
from.

### Wave 4B — Behaviour, interfaces, software (original Wave 4 scope, unchanged; brief: `docs/SESSION_BRIEF_wave4b_behaviour.md`; starts from `CHANGELOG_VERIFICATION.md` §4)

Value-chain action flows (v14.1/v15/v16), ports and interfaces, SENTINEL
states and modes, ECN-014 valve auto-close logic as state machine and
constraints, NAV-001 fusion as a behaviour. Th/U stage waits on the preprint.
ECN-021 enters here once its source documents are revised. Verification
(6 Nov 2026) adds: SEL-REQ-017 (the ECN-023 sunlit duty-cycle rule on the SPA
asteroid lines), the missing gated elements (SPA reagent pilot, PKT oxalic-acid
line, CON-001 connector, L1 depot for SEL-REQ-005), the ECN-014 source extract,
and the hygiene backlog (V-N3, V-N8, V-N9, V-N27) — see `CHANGELOG_VERIFICATION.md` §4.

## Wave 5 — Quantities, parametrics and the first derived timeline (after the Python port)

Adds to the original scope: the planner's first full run (every derivable
gate evaluated on Python vectors, `derivedPhase` bound, phase year windows
in `Phases.sysml` become outputs), the derived-versus-document register
replaces the hand-kept W2-N list, and the Wave 4A gate-year distributions
feed the bound phases as probabilities beside the point values. Timeline figures are then rendered from
the model.

### Wave 5 (original scope)

Attributes populated from Python-generated data (fleet counts per phase,
masses, power, throughput, economics), with the checker asserting model ==
Python within tolerance. Constraint blocks mirror VERIFY/SCALE/ECON
relationships; Python computes. This is where the audit findings F8 get
adjudicated numerically rather than by reading documents.

Dependency: goldens (done under Octave; MATLAB run preferred) → Python port
→ Wave 5. Waves 2–4 do not wait for it.
