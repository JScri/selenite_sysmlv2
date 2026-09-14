# Selenite — Architecture Baseline (what · how · when)

**Baseline:** ECN-019 Rev C + ECN-020. **Purpose:** the structural and
temporal skeleton the SysML v2 model must carry before any quantity is
attached. Numbers here are phase-existence and counts only where they define
structure; everything quantitative arrives from the Python layer later.
Sources are the authoritative set in `DOCUMENT_FAMILIES.md`. Items marked ⚑
are open flags (see that document).

## 1. Phases (temporal spine)

| Phase | Years | Defining event | Site state |
|---|---|---|---|
| P0 | Y1–3 | Earth: relay sats built, fleet fabricated, planning | none on Moon |
| P1 | Y2–4 | EML-2 relay ×3 deployed; cargo lands initial fleet; PROBE-Scout + SURVEY dispatched | SPA: hardware landed |
| P2 | Y4–6 | Robotic site prep (MOLE-S grading, SINTER, ARM), SENTINEL from Earth at 2.56 s RTT | SPA: uncrewed |
| P3 | Y4–7 | Hab shells printed; PSR trunk/CLP/spine; MOLE-I descend; ISRU first output; 3 PROBE (Earth-fuelled) | SPA: uncrewed |
| P4 | Y7–9 | Crew-1 (4) arrives M82; ECLSS commissioned; ISRU self-sufficient; SKIP-1; crew → 8 | SPA: crewed |
| P5 | Y9–12 | Beneficiation online; first export (Y10); DART-1 to PKT; crew → 12 | SPA |
| P6 | Y12–15 | HARVEST + greenhouse; crew rotation; PKT recon continues | SPA |
| ⚑F7 gap | Y15–18 | — | — |
| P7 | Y18–25 | **HØW target.** Processing facility (5 circuits, ~0.4 t/yr); crew 16–20; MOLE-I Mk II retrofit; DART confirms PKT site (Y22); progressive automation; YBCO for MD-1 delivered | SPA at full config |
| P8 | Y25–35 | **PKT online (Y27).** MD-1 SPA→PKT (DG-8.0); 4-wave construction (~30,000 t, ~300 flights); temporary commissioning crew (3–4, 6–12 mo); haulers from day one | SPA + PKT |
| P9 | Y35–45 | MD-2 PKT→Earth (DG-9.1); SKIPs retired; first thorium MSR (DG-9.3); PROBE Mk II; conveyor pilot; foundry scaling | dual-site |
| P10 | Y45–60 | MSR fleet ~74 replaces FSP at PKT; conveyor network deploying; redirect-tug development; ⚑F5 SPA MSR (DG-10.5?) | industrial |
| P11 | Y60–80 | PROBE Mk III SEP (DG-11.6); EM catcher at SPA; M-type redirect begins (Y75); MD-4 SPA→Earth PGM; in-situ Ni-201 MSR vessels | 100 kt/yr REO |
| P12 | Y80–120 | M-type online at DRO (Y85, Laser Ablation Truss); MD-5 DRO→SPA; C-type redirect (Y95); **C-type online (Y105)**; propellant independence; S-type redirect (Y115); Mk III peak → prospecting | 100k→500k t/yr |
| P13 | Y120–140 | **S-type online (Y125)**; Si/Cu in-situ; ⚑F5 SPA MSR units (demand-gated) | 500k→1.25M t/yr |
| P14 | Y140–180 | No new asteroid arrival: scale-up with all three streams flowing; 5 mass drivers; Earth-independence gate DG-14.6; ⚑F5 SPA MSR #2/#3 | 1.25M→2.5M t/yr |

Corrected 14 Sep 2026 (W2-N7): the online years Y85/Y105/Y125 are the
authoritative sequence (20-year redirect→arrive cadence); the phase labels
in fleet v9 App. C, the extended timeline and the final report's Figure 2/34
had drifted one phase late for C-type and S-type. Years win.
| P14+ | Y180+ | **Steady state 2.5 Mt/yr REO.** Mission achieved | permanent |

Modelling note: every element below carries `introducedIn` / `retiredIn`
(phase enum) so the model can be queried per phase. Where a count changes by
phase, the model holds the per-phase profile as an attribute vector indexed by
`Phase`, sourced from the Python layer.

## 2. Sites and nodes

| Node | Role | Exists from | Crew |
|---|---|---|---|
| SPA Shackleton (Connecting Ridge, ~89.5°S) | Crewed hub, proving ground, ISRU, asteroid processing, command (Ops Hub) | P1 | 0 (P1–P3) → 4 (P4) → 8 → 12 → 20 (P7+) |
| Shackleton PSR floor | MOLE-I ice network (fishbone: trunk → CLP → spine → branches → substations) | P3 | 0; CAP contingency access only |
| PKT Procellarum (~14°N) | Autonomous factory | P8 | **0 permanent**; temporary 3–4 at P8 only |
| EML-2 relay constellation (×3) | Continuous south-pole comms | P1 | — |
| PKT relay satellite | SPA↔PKT 0.5 s link | P8 | — |
| DRO station | Captured-asteroid processing (Laser Ablation Truss) | P12 | 0 |
| Earth (launch, market, individual SX, ops hub) | Origin and sink | P0 | — |

## 3. Fleet — introduction and retirement

| Class | Site | Intro | Retire / supersede | Structural notes |
|---|---|---|---|---|
| PROBE-Scout | cislunar/NEA | P1 | expendable | not counted in fleet |
| PROBE Mk I | SPA | P3 (3) | superseded by Mk II/III; peaks P8 | RL-10C, ISRU-fuelled from P4 |
| PROBE Mk II | SPA | P9 | → Mk III | on-asteroid beneficiation |
| PROBE Mk III (SEP) | SPA/EM catcher | P11 | prospecting role P13+ | never lands; zero ISRU propellant |
| SURVEY | polar LLO | P1 (1) | 2 from P5 | orbital prospector |
| MOLE-I Mk I | PSR | P3 (10) | Mk II retrofit from P7 | binding design variable; demand-driven ⚑F4 |
| MOLE-I Mk II | PSR | P7 | declines as Mk III removes chemical demand | telescoping 5 m drill, ORU |
| MOLE-S | SPA only | P2 (4) | never to PKT | blade grading; 6 from P6 |
| SINTER | SPA (3); PKT from P8 | P2 | — | three modes; onboard 10 kWe reactor |
| ARM-C | SPA (1→2); PKT from P8 | P2/P3 | — | mobile crane; rim/surface only, never PSR |
| ARM-D | SPA | P3 (1) | — | = docking-collar count (1→2→4→6→8) |
| SENTINEL rover | SPA (2→4); PKT | P2 | — | inspection; software is a separate element |
| SKIP | SPA only | P4 (1) → P7 (8) | **retired P9**; never at PKT | 100 km hop; 400 kg container ⚑F8 |
| DART | SPA→PKT | P5 (1) | — | PKT ground truth, site confirmation Y22 |
| HARVEST | SPA greenhouse | P6 (1) | — | aeroponic tender |
| CAP | Shackleton wall | P4+ (anchors reserved P1) | — | contingency crew descent |
| Hauler Rev B | PKT only | P8 (200) | — | miner-hauler; Na-S; SRM; ⚑F3 in-situ fraction |
| Redirect tug (SEP/NEP) | cislunar | P10 dev, P11 ops | — | M/C/S captures Y75/95/115 |
| Laser Ablation Truss | DRO | P12 | — | 350 MW, 1,000 t/day |

## 4. Facilities

**SPA:** habitat (shells P3; crewed P4; H3 module P7; 8 modules), ECLSS
(P4; WRS 1→4 units), ISRU plant (P3; 19 PEM stacks + cryo by P7), IZ
(collars 1→8; beneficiation P5; EM catcher P11), ELZ (pads 1–2 P4, 3–4 P6),
power zone (solar array P3→; FSP 1→5 by P7; eclipse battery P4; SPA MSR
⚑F5), processing facility SEL-PROC-001 (P7, 5 circuits), PSR network
(34 substations by P7; pipeline PIPE-001; winches IW-1/IW-2; CAP winch),
greenhouse (P6), crew return vehicle (always fuelled, P4+).

**PKT:** processing spine (P8 308 circuits → P14 ~2.08 M), reagent plant
(P8+; H₂SO₄ from troilite, Ca(OH)₂), foundry FAB-001 (P8 pilot → P9+),
FSP field (~1,386 units, P8) → thorium MSR fleet (first P9; ~74 P10; ~679
P11; ~6,890 P12+), hub charging stations (1 per 100 haulers), steel apron
conveyor network (pilot P9; deploying P10; ~87,500 km), relay depots for
tiered depth mining (Tier 2/3, later phases), temporary crew hab (P8 only),
PKT ELZ (P8).

## 5. Logistics network

| Link | Mode | From | Notes |
|---|---|---|---|
| Earth → SPA / PKT | Starship cargo | P1 | diminishing; <1 % mass by P14 |
| SPA ↔ PSR floor | winches, trunk cable, pipeline | P3 | 8.2 km wall, 30° |
| SPA → PKT | **MD-1** (2 tracks, 1+1 redundant) | P8, DG-8.0 | propellant, reagents, Fe-Ni, spares |
| PKT → Earth | **MD-2** (3 tracks, round-robin) | P9, DG-9.1 | 3.6 t REO canisters, ~2,400 m/s; minimal drag chute |
| PKT → SPA | **MD-3** | P10 | ThCl₄ fuel ⚑F6 |
| SPA → Earth | **MD-4** | P11 | PGM |
| DRO → SPA | **MD-5** | P12 | asteroid concentrate |
| SPA (P4–P9) | SKIP hops | P4 | SPA Basin KREEP only |
| PKT surface | haulers (Tier 1–2) + conveyors (Tier 3) | P8 / P9 | no SKIPs, no catapults |
| Asteroids ↔ SPA | PROBE Mk I/II return; Mk III canisters to EM catcher | P3 / P11 | |

Eliminated by ECN-019 and **absent from the model**: LLO tanker fleet,
PKT SKIPs, ore catapults (9,084 hubs), MOLE-S at PKT, D2EHPA.

## 6. Processing chemistry (structure only)

KREEP → beneficiation (10×) → 8-step zero-carbon flowsheet: acid bake 300 °C
(Th as ThP₂O₇) → Ca(OH)₂ precipitation → U via H₂O₂ → Ce oxidation →
LREE/HREE split → (NH₄)₂SO₄ LREE → H₃PO₄ HREE → calcination → mixed oxide
concentrates → Earth (individual SX on Earth). Th(OH)₄ → ThCl₄ MSR fuel.
Th/U separation stage architecture: **open**, pending the preprint.
Asteroid: M-type magnetic separation → chlorination → PGM; C-type pyrolysis +
Fischer-Tropsch; S-type Czochralski Si + Cu electrolysis (all at SPA).

## 7. Software and operations

SENTINEL three-tier hierarchy: Earth ops hub → SENTINEL (edge, base AI
commander) → fleet. Three modes: pre-programmed execution; local AI within
safe parameters; exception flagging to humans. Supervision moves from Earth
(2.56 s RTT, P2–P3) to SPA Ops Hub (P4+); SPA supervises PKT at 0.5 s (P8+).
ECN-014: cryo/O₂ valve monitoring, auto-close on hardwired 24 VDC, dead-man
fail-closed, crew-only re-open with four preconditions; VALVE_STATE table
(11 tables), fault patterns #201–206 (206 total). NAV-001: tether polar fix +
odometry + IMU Kalman fusion, 3,600-cell drill grid, UHF during construction.
Modelling intent: states, interfaces, alarm thresholds and constraints as
model elements; the pattern table and schema as attached CSV data.

## 8. Governance and economics envelope (reference, not modelled yet)

Single international legal entity (ITER-style), binding treaty, cash/in-kind
capped ~40–50 %, engineered interdependency, proportional allocation with
barter. Economics per ECON v1.4 goldens: BCR 0.50 (200-yr) / 2.06 (annual
steady state), NPV −$0.49 T, discount rate dominant. These are "to what
extent" and belong to Wave 5 + Python, not to the architecture wave.
