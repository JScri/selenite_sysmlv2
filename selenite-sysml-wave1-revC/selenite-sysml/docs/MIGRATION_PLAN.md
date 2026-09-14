# Migration Plan — Documents to SysML v2

Strategy: migrate by **wave**, not by document. Each wave produces a
validated, diagrammable model increment; `mapping/document_map.csv`
tracks per-document status (`done | skeleton | planned | reference_only |
superseded | out_of_scope`). Documents are never deleted — they remain
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

## Wave 3 — Requirements and phase gates

SEL-REQ-0xx from ECN-019 Rev C, ECN-020, Strategy v3.1, Decision Framework
v4 (DG-8.0, DG-9.1, DG-9.3, DG-10.5, DG-11.6, DG-14.6 …) with concrete
subjects and `satisfy` links. Hard constraints already machine-checkable
(zero permanent crew at PKT; no SKIPs at PKT) stay; add "no ARM below the
rim", "no catapult for ore", "no D2EHPA".

## Wave 4 — Behaviour, interfaces, software

Value-chain action flows (v14.1/v15/v16), ports and interfaces, SENTINEL
states and modes, ECN-014 valve auto-close logic as state machine and
constraints, NAV-001 fusion as a behaviour. Th/U stage waits on the preprint.
ECN-021 enters here once its source documents are revised.

## Wave 5 — Quantities and parametrics (after the Python port)

Attributes populated from Python-generated data (fleet counts per phase,
masses, power, throughput, economics), with the checker asserting model ==
Python within tolerance. Constraint blocks mirror VERIFY/SCALE/ECON
relationships; Python computes. This is where the audit findings F8 get
adjudicated numerically rather than by reading documents.

Dependency: goldens (done under Octave; MATLAB run preferred) → Python port
→ Wave 5. Waves 2–4 do not wait for it.
