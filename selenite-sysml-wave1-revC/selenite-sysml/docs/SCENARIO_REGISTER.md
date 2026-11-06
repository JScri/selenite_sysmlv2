# Selenite scenario register - decisions under uncertainty (Wave 4A)

Run: n = 2,000 samples, seed 20260920, Latin hypercube, scenario `baseline`; common random numbers (every alternative of every decision on the same samples). ECON v1.3 parametrised (`econ_param`, equal to the port at defaults). Default criterion `expectedEarthMassWithSlipChance`: minimise expected cumulative Earth-launched mass subject to P(no gate slip) >= 0.80 (PROPOSED, open question 1, awaiting Jason); expected value, P90, CVaR90 and minimax regret are reported beside it.

Convergence: largest standard error 0.59 % of the mean (D3/shuttlecock); largest win-probability standard error 0.011.

Slip is measured against the plan's own date: the declared year, or the Wave 3 derived year at nominal where the deterministic register already derives the gate later (W3-R rows); exogenous gates and the years ECN-022 superseded are excluded. MTL v8.5 milestones M5 / M6 / M8 and the first-export year are not derivable from the Python layer and are not modelled as slips.

## 1. Uncertainty register (the U-set)

Every entry binds to a ProgrammeParameters attribute and its Low / High twins; an entry without a sourced range is a point at nominal (rule 5d). Two-point discrete entries carry equal weights (uninformative, stated per row).

| Entry | Distribution | Nominal | Low | High | Status | Source |
|---|---|---|---|---|---|---|
| thoriumGradePpm | triangular | 12 | 10 | 15 | sampled | ECN-022 s.2.2; fleet v9 s.11; Lawrence et al. 2000, 2003 |
| acidBakeThoriumCapture | triangular | 0.92 | 0.9 | 0.95 | sampled | ECN-022 s.2.2; DG-7.2 (~90-95 % of Th into ThP2O7) |
| spaDarkFraction | triangular | 0.15 | 0.12 | 0.229 | sampled | VERIFY v5.0 solar.illum 0.85; Glaeser et al. 2014 (Icarus 243) 77.1-88.0 % average illumination |
| spaLongestEclipseHours | triangular | 72 | 72 | 120 | sampled | Strategy v3.1 s.12.1 72 h design case; Glaeser et al. 2014 longest darkness 3-5 days (W4A-N1) |
| czochralskiBatchHours | triangular | 48 | 24 | 72 | sampled | Jason, 6 Nov 2026 (open question 3): a batch takes 1-3 days |
| plantOversizeMassPenaltyKgPerKw | triangular | 70 | 70 | 83 | sampled | PROXY: Decision Framework Rev D s.4 circuit designs 70.0-83.3 kg/kW |
| eclipseRestartLossDaysPerEclipse | pointValue | - | - | - | point (nominal unbound, evaluator assumption) | UNBOUND - no process source; evaluator ASSUMED 0.5 day per eclipse |
| spaMsrAvailabilityProbability | pointValue | 1 | - | - | point (range unbound) | Wave 3 assumedOutcome = true (DG-7.5, DG-9.3) restated as 1.0; range unbound |
| fspUnitMassKg | pointValue | 6,600 | - | - | point (range unbound) | VERIFY v5.0 fsp.mass_kg (ECON v1.3 agrees); range unbound |
| fspUnitPowerKw | pointValue | 40 | - | - | point (range unbound) | VERIFY v5.0 fsp.pwr_kW; range unbound |
| batterySpecificEnergyWhPerKg | pointValue | 250 | - | - | point (range unbound) | VERIFY v5.0 batt_Whkg; range unbound |
| solarPanelMassKgPerM2 | pointValue | 3 | - | - | point (range unbound) | VERIFY v5.0 ph.panel_kg = panel_m2 x 3; range unbound |
| thcl4AvailableYear | triangular | 43 | 43 | 60 | sampled | DG-9.6 declared Y43 (P9), alternate P10 -> Y43-Y60 (W2-N2) |
| solarInSituStartYear | triangular | 60 | 60 | 80 | sampled | Decision Framework Rev D s.6: a-Si panels in-situ from P11 (Y60-Y80) |
| msrUnitMassKg | pointValue | 50,000 | - | - | point (range unbound) | ECON v1.3 msr.mass_kg; range unbound |
| msrEarthFractionFloor | pointValue | 0.3 | - | - | point (range unbound) | ECON v1.3 msr.earth_frac floor 0.3 from Y80; DF s.15.2; range unbound |
| launchCostMultiplier | triangular | 1 | 0.5 | 1.5 | sampled | ECON v1.4 tornado: launch cost +50 % / -50 % on 6,000 / 4,000 / 2,000 $/kg |
| discountRateMultiplier | triangular | 1 | 0.4667 | 1.167 | sampled | ECON v1.4 tornado: 1.4 % vs 3.5 % as a multiplier on the 3 / 2.5 / 2 % schedule |
| reoExternalityUsdPerTonne | triangular | 73,700 | 50,000 | 90,000 | sampled | ECON v1.4 tornado: REO externality $50k vs $90k/t |
| h2AttributionFraction | triangular | 0.5 | 0.25 | 1 | sampled | ECON v1.4 tornado: H2 attribution 25 % vs 100 % |
| geoInsuranceUsdMPerYear | triangular | 15,000 | 0 | 25,000 | sampled | ECON v1.4 tornado: geo insurance $0 vs $25 B/yr |
| circuitMaintenanceFractionPerYear | triangular | 0.005 | 0.0025 | 0.005 | sampled | ECON v1.4 tornado: maintenance 0.5 % vs 0.25 %; DF s.4 |
| reoRampKnotShift | discrete | 0 | 0 | 1 | sampled | W3-N4: ECON knots (0) vs Decision Framework REO gates one knot earlier (1); equal weights |
| mTypeCaptureYear | pointValue | 75 | - | - | point (range unbound) | ECON v1.4 / DG-11.8 Y75; range UNBOUND (no source) - scenario lateMType |
| cTypeCaptureYear | pointValue | 95 | - | - | point (range unbound) | ECON v1.4 / DG-13.2 Y95; range unbound |
| sTypeCaptureYear | pointValue | 115 | - | - | point (range unbound) | ECON v1.4 / DG-13.6 Y115; range unbound |
| asteroidOnlineLagYears | pointValue | 10 | - | - | point (range unbound) | Decision Framework Rev D (redirect -> arrival +10); range UNBOUND |
| reoPayloadPerCanisterTonnes | discrete | 3.5 | 3.5 | 3.6 | sampled | W3-N7 / VC-22: ECON 3.5 t (714,286/yr) vs ECN-020 3.6 t (694,444/yr); equal weights |
| impactSurvivalPassProbability | pointValue | 0.5 | - | - | point (range unbound) | DF s.9 / s.11 item 9: test outcome, probability uninformative 0.5; range unbound |
| psrMoleICapacityUnits | discrete | 620 | 310 | 620 | sampled | W2-N18: psr_layout 620 (bound) vs fleet v9 / Strategy s.4.4 ~310; equal weights |
| mkIiiTestPassProbability | pointValue | 0.5 | - | - | point (range unbound) | DG-11.6 ion-SEP / EM-catcher validation; probability uninformative 0.5; range unbound |
| haulerEarthFractionFloor | discrete | 0.43 | 0.08 | 0.43 | sampled | F3: ECON 0.43 (~57 % in-situ) vs fleet v9 92 % in-situ (0.08); equal weights |

Evaluator working assumptions (ASSUMED - no process source; an ECN to `selenite/scenarios/eclipse.py` or a bound parameter replaces them): hold-load fractions cTypeLine 0.25, sTypeLine 0.25, scaledOperations 0.25; restart loss 0.50 day of output per eclipse; oversize plant Earth share the ECON circuit Earth-fraction trajectory. Sampled dimensions: 22; sample hash e38ce8ce00ec (common random numbers).

## 2. Decisions

### D1 - SPA eclipse operating strategy for the asteroid-processing loads

Stage: now; gates: DG-10.5, DG-11.3, DG-13.4, DG-14.4, DG-14.7; evaluator: `selenite.scenarios.eclipse.evaluate_d1` (evaluated); baseline selection: carryThroughEclipse; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `carryThroughEclipse`** - P(win) 1.00, P(no slip) 1.00.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | SPA power-side Earth mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | FSP units (non-nuclear fallback) mean / P10 / P50 / P90 | battery mass (t) mean / P10 / P50 / P90 | oversize plant mass (t) mean / P10 / P50 / P90 | throughput lost mean / P10 / P50 / P90 | throughput penalty, Earth mass (t) mean / P10 / P50 / P90 | SPA MSR first year mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| carryThroughEclipse | 6,935,204 / 5,548,520 / 6,864,572 / 8,352,623 | 135 / 135 / 135 / 135 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 6,254 / 6,254 / 6,254 / 6,254 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 105 / 105 / 105 / 105 |
| sunlitDutyCycle | 6,935,382 / 5,548,675 / 6,864,765 / 8,352,869 | 313 / 278 / 309 / 353 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 941 / 941 / 941 / 941 | 0 / 0 / 0 / 0 | 162 / 128 / 158 / 202 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 105 / 105 / 105 / 105 |
| hotStandby | 7,946,080 / 6,549,355 / 7,981,661 / 9,339,042 | 135 / 135 / 135 / 135 | -1,246 / -2,241 / -1,104 / -472 | 0.04983 / 0.03829 / 0.04899 / 0.06248 | 0 / 0 / 0 / 0 | 82,779,146 / 58,381,274 / 82,910,807 / 107,212,506 | 941 / 941 / 941 / 941 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 0.2051 / 0.1694 / 0.2016 / 0.2467 | 1,010,876 / 785,445 / 993,420 / 1,262,430 | 105 / 105 / 105 / 105 |
| hybridStorage | 6,988,086 / 5,602,067 / 6,926,494 / 8,406,537 | 53,017 / 44,887 / 51,849 / 63,121 | -1,132 / -2,075 / -996 / -401 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 472 / 472 / 472 / 472 | 52,800 / 44,679 / 51,636 / 62,882 | 81 / 64 / 79 / 101 | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 105 / 105 / 105 / 105 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| carryThroughEclipse | 8,352,623 | -2,597 | 30,390 | 1.00 |
| sunlitDutyCycle | 8,352,869 | -2,597 | 30,390 | 1.00 |
| hotStandby | 9,339,042 | -2,835 | 28,233 | 1.00 |
| hybridStorage | 8,406,537 | -2,622 | 30,389 | 1.00 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | carryThroughEclipse | 1.00 | 1.00 |
| p90 | carryThroughEclipse | 1.00 | 1.00 |
| cvar90 | carryThroughEclipse | 1.00 | 1.00 |
| minimaxRegret | carryThroughEclipse | 1.00 | 1.00 |
| chanceConstrained | carryThroughEclipse | 1.00 | 1.00 |

Declared versus derived eclipse-critical fraction of the asteroid-processing loads (ECN-022 s.2.4 declared 1.0; `SeleniteAnalysis::EclipseCriticalFraction` per strategy):

| Strategy | Declared | Derived mean / P10 / P50 / P90 | FSP units (fallback, max) | critical load max (kW) |
|---|---|---|---|---|
| carryThroughEclipse | 1 | 1 / 1 / 1 / 1 | 6,254 | 250,120 |
| sunlitDutyCycle | 1 | 0.15 / 0.15 / 0.15 / 0.15 | 941 | 37,620 |
| hotStandby | 1 | 0.15 / 0.15 / 0.15 / 0.15 | 941 | 37,620 |
| hybridStorage | 1 | 0.575 / 0.575 / 0.575 / 0.575 | 472 | 143,870 |

The two worlds D1 turns on (same samples; `spaMsrAvailabilityProbability` = 1 in the committed plan, scenario override none): the SPA MSR carries the asteroid loads through every eclipse when it is available at the C-type arrival; without it the strategy sizes the FSP fleet. Break-even: the availability probability below which the strategy beats carry-through on expected Earth-launched mass.

| Strategy | MSR available: SPA power mass (t) | MSR available: total Earth mass (t) | MSR unavailable: SPA power mass (t) | MSR unavailable: total Earth mass (t) | break-even P(MSR available) |
|---|---|---|---|---|---|
| carryThroughEclipse | 135 | 6,935,204 | 42,117 | 6,977,185 | reference |
| sunlitDutyCycle | 313 | 6,935,382 | 7,425 | 6,942,493 | 0.9949 |
| hotStandby | 135 | 7,946,080 | 7,051 | 7,952,996 | always |
| hybridStorage | 53,017 | 6,988,086 | 56,943 | 6,992,011 | never |

Notes: hold-load fractions ASSUMED (no process source): cTypeLine 0.25, sTypeLine 0.25, scaledOperations 0.25; restart loss ASSUMED 0.50 day per eclipse; DG-10.5 declared year superseded by ECN-022 s.2.3 (Y50 superseded); reported, excluded from the slip; DG-11.3 declared year superseded by ECN-022 s.2.3 (Y70 superseded); reported, excluded from the slip.

### D2 - SPA power supply mix: FSP + solar versus SPA MSR, solar in-situ timing

Stage: recourse; gates: DG-9.6, DG-10.5, DG-13.4; evaluator: `selenite.scenarios.trades.evaluate_d2` (evaluated); baseline selection: msrWhenJustified; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `msrWhenJustified`** - P(win) 1.00, P(no slip) 1.00.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | SPA MSR first year mean / P10 / P50 / P90 | P(MSR before Y105) mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|
| nonNuclearOnly | 6,977,185 / 5,590,501 / 6,906,553 / 8,394,604 | -1,126 / -2,062 / -989 / -396 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | never / never / never / never | 0 / 0 / 0 / 0 |
| msrWhenJustified | 6,935,204 / 5,548,520 / 6,864,572 / 8,352,623 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 105 / 105 / 105 / 105 | 0 / 0 / 0 / 0 |
| msrAtThcl4Availability | 6,935,231 / 5,548,543 / 6,864,598 / 8,352,653 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 49 / 44 / 48 / 55 | 1 / 1 / 1 / 1 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| nonNuclearOnly | 8,394,604 | -2,612 | 30,390 | 1.00 |
| msrWhenJustified | 8,352,623 | -2,597 | 30,390 | 1.00 |
| msrAtThcl4Availability | 8,352,653 | -2,597 | 30,390 | 1.00 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | msrWhenJustified | 1.00 | 1.00 |
| p90 | msrWhenJustified | 1.00 | 1.00 |
| cvar90 | msrWhenJustified | 1.00 | 1.00 |
| minimaxRegret | msrWhenJustified | 1.00 | 1.00 |
| chanceConstrained | msrWhenJustified | 1.00 | 1.00 |

Notes: DG-10.5 declared year superseded by ECN-022 s.2.3 (Y50 superseded); reported, excluded from the slip.

### D3 - Canister recovery architecture (DG-9.1)

Stage: now; gates: DG-9.1, DG-14.6; evaluator: `selenite.scenarios.trades.evaluate_d3` (evaluated); baseline selection: open (abstract part); objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `shuttlecock`** - P(win) 0.71, P(no slip) 1.00.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | canister Earth mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | annual Earth import cost ($B/yr, DF s.9) mean / P10 / P50 / P90 | P(realised as chosen) mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|---|
| fullParachute | 9,079,848 / 7,321,338 / 9,004,147 / 10,882,811 | 3,479,309 / 2,855,749 / 3,471,085 / 4,119,252 | -1,409 / -2,571 / -1,240 / -513 | 0.04706 / 0.03548 / 0.04635 / 0.0596 | 0 / 0 / 0 / 0 | 91,161,607 / 63,857,557 / 90,482,528 / 118,842,477 | 42 / 42 / 42 / 42 | 1 / 1 / 1 / 1 |
| minimalDragChute | 8,005,036 / 5,570,285 / 7,776,021 / 10,815,417 | 2,404,497 / 1,095,356 / 2,217,868 / 4,119,252 | -1,262 / -2,332 / -1,093 / -443 | 0.05003 / 0.03753 / 0.04889 / 0.06396 | 0 / 0 / 0 / 0 | 83,476,129 / 51,665,255 / 81,552,265 / 118,359,272 | 29 / 16 / 29 / 42 | 0.5 / 0 / 0.5 / 1 |
| shuttlecock | 6,980,985 / 4,783,030 / 7,180,643 / 10,710,163 | 1,380,447 / 312,959 / 773,390 / 4,004,829 | -1,123 / -2,058 / -986 / -380 | 0.05312 / 0.03955 / 0.05228 / 0.0681 | 0 / 0 / 0 / 0 | 76,153,945 / 46,178,490 / 77,551,940 / 117,496,921 | 17 / 4.6 / 10 / 42 | 0.5 / 0 / 0.5 / 1 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| fullParachute | 10,882,811 | -3,294 | 38,435 | 1.00 |
| minimalDragChute | 10,815,417 | -3,005 | 41,899 | 1.00 |
| shuttlecock | 10,710,163 | -2,682 | 41,408 | 1.00 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | shuttlecock | 0.71 | 1.00 |
| p90 | shuttlecock | 0.71 | 1.00 |
| cvar90 | shuttlecock | 0.71 | 1.00 |
| minimaxRegret | shuttlecock | 0.71 | 1.00 |
| chanceConstrained | shuttlecock | 0.71 | 1.00 |

Notes: impact-survival pass probability uninformative 0.5 (range unbound); a failed test falls back 2 -> 1b -> 1a.

### D4 - Processing circuit design (batch / continuous-flow / optimised)

Stage: now; gates: DG-8.5, DG-9.2, DG-10.2; evaluator: `selenite.scenarios.trades.evaluate_d4` (evaluated); baseline selection: optimisedDesign; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `optimisedDesign`** - P(win) 1.00, P(no slip) 1.00.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | circuits at Y200 mean / P10 / P50 / P90 | PKT power at Y200 (GW) mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|
| batchDesign | 8,964,553 / 6,979,987 / 8,852,952 / 11,003,675 | -1,966 / -3,512 / -1,765 / -749 | 0.03839 / 0.02839 / 0.03811 / 0.04883 | 0 / 0 / 0 / 0 | 101,293,548 / 66,048,694 / 100,283,327 / 137,065,178 | 6,250,000 / 6,250,000 / 6,250,000 / 6,250,000 | 1,125 / 1,125 / 1,125 / 1,125 |
| continuousFlowDesign | 7,529,347 / 5,966,921 / 7,446,665 / 9,129,702 | -1,368 / -2,490 / -1,220 / -505 | 0.04766 / 0.0356 / 0.04719 / 0.06031 | 0 / 0 / 0 / 0 | 83,348,285 / 55,799,133 / 82,600,656 / 111,273,529 | 3,125,000 / 3,125,000 / 3,125,000 / 3,125,000 | 938 / 938 / 938 / 938 |
| optimisedDesign | 6,935,068 / 5,548,384 / 6,864,436 / 8,352,487 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 2,083,334 / 2,083,334 / 2,083,334 / 2,083,334 | 833 / 833 / 833 / 833 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| batchDesign | 11,003,675 | -4,439 | 43,452 | 1.00 |
| continuousFlowDesign | 9,129,702 | -3,134 | 34,226 | 1.00 |
| optimisedDesign | 8,352,487 | -2,597 | 30,390 | 1.00 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | optimisedDesign | 1.00 | 1.00 |
| p90 | optimisedDesign | 1.00 | 1.00 |
| cvar90 | optimisedDesign | 1.00 | 1.00 |
| minimaxRegret | optimisedDesign | 1.00 | 1.00 |
| chanceConstrained | optimisedDesign | 1.00 | 1.00 |

### D5 - MD-4 and Starship-return retirement timing (consequence of the M-type arrival)

Stage: recourse; gates: DG-11.8, DG-12.4; evaluator: `selenite.scenarios.trades.evaluate_d5` (evaluated); baseline selection: consequenceOfMTypeArrival; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `consequenceOfMTypeArrival`** - P(win) 1.00, P(no slip) 1.00.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | MD-4 year mean / P10 / P50 / P90 | P(MD-4 by Y85) mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|
| consequenceOfMTypeArrival | 6,935,068 / 5,548,384 / 6,864,436 / 8,352,487 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0 / 0 / 0 / 0 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 85 / 85 / 85 / 85 | 1 / 1 / 1 / 1 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| consequenceOfMTypeArrival | 8,352,487 | -2,597 | 30,390 | 1.00 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | consequenceOfMTypeArrival | 1.00 | 1.00 |
| p90 | consequenceOfMTypeArrival | 1.00 | 1.00 |
| cvar90 | consequenceOfMTypeArrival | 1.00 | 1.00 |
| minimaxRegret | consequenceOfMTypeArrival | 1.00 | 1.00 |
| chanceConstrained | consequenceOfMTypeArrival | 1.00 | 1.00 |

Notes: capture-year ranges unbound: the distribution is a point unless the scenario moves it.

### D6 - Thorium stream sizing (consequence of grade and capture)

Stage: recourse; gates: DG-8.7, DG-9.6; evaluator: `selenite.scenarios.trades.evaluate_d6` (evaluated); baseline selection: consequenceOfGradeAndCapture; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `consequenceOfGradeAndCapture`** - P(win) 1.00, P(no slip) 0.59.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | DG-8.7 year mean / P10 / P50 / P90 | Th(OH)4 stockpile at Y43 (t) mean / P10 / P50 / P90 | Th(OH)4 per t REO mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|---|
| consequenceOfGradeAndCapture | 6,935,068 / 5,548,384 / 6,864,436 / 8,352,487 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 0.426 / 0 / 0 / 1 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 37 / 37 / 37 / 38 | 116 / 103 / 115 / 128 | 0.02985 / 0.02656 / 0.02983 / 0.03316 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| consequenceOfGradeAndCapture | 8,352,487 | -2,597 | 30,390 | 0.59 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | consequenceOfGradeAndCapture | 1.00 | 0.59 |
| p90 | consequenceOfGradeAndCapture | 1.00 | 0.59 |
| cvar90 | consequenceOfGradeAndCapture | 1.00 | 0.59 |
| minimaxRegret | consequenceOfGradeAndCapture | 1.00 | 0.59 |
| chanceConstrained | none admissible | - | - |

Notes: no alternative meets P(no slip) >= 0.80; lead falls back to expectedValue.

### D7 - Mk III transition trigger (capacity-forced versus DG-11.6 test outcome)

Stage: recourse; gates: DG-11.6, DG-11.7; evaluator: `selenite.scenarios.trades.evaluate_d7` (evaluated); baseline selection: testOutcomeDriven; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `capacityForced`** - P(win) 0.50, P(no slip) 0.50.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | P(capacity-forced) mean / P10 / P50 / P90 | Mk III transition year mean / P10 / P50 / P90 | Mk III fleet Earth mass (t, LEO) mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|---|
| capacityForced | 6,935,068 / 5,548,384 / 6,864,436 / 8,352,487 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 68 / 0 / 68 / 135 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 0.5 / 0 / 0.5 / 1 | never / never / never / never | 5,111 / 0 / 5,111 / 10,223 |
| testOutcomeDriven | 6,935,068 / 5,548,384 / 6,864,436 / 8,352,487 | -1,118 / -2,053 / -980 / -391 | 0.05301 / 0.03986 / 0.05237 / 0.0669 | 68 / 0 / 68 / 135 | 75,829,372 / 51,491,096 / 75,191,150 / 100,477,001 | 0.5 / 0 / 0.5 / 1 | never / never / never / never | 5,111 / 0 / 5,111 / 10,223 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| capacityForced | 8,352,487 | -2,597 | 30,390 | 0.50 |
| testOutcomeDriven | 8,352,487 | -2,597 | 30,390 | 0.50 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | capacityForced | 0.50 | 0.50 |
| p90 | capacityForced | 0.50 | 0.50 |
| cvar90 | capacityForced | 0.50 | 0.50 |
| minimaxRegret | capacityForced | 0.50 | 0.50 |
| chanceConstrained | none admissible | - | - |

Notes: Mk III validation pass probability uninformative 0.5 (range unbound); no alternative meets P(no slip) >= 0.80; lead falls back to expectedValue.

### D8 - Hauler in-situ fraction policy (F3, DG-13.7)

Stage: recourse; gates: DG-10.1, DG-13.7; evaluator: `selenite.scenarios.trades.evaluate_d8` (evaluated); baseline selection: econFloor; objective: minimise Earth-launched mass (t).

**Recommended under the default criterion (chanceConstrained): `econFloor`** - P(win) 0.50, P(no slip) 1.00.

| Alternative | Earth-launched mass (t) mean / P10 / P50 / P90 | hauler Earth mass (t) mean / P10 / P50 / P90 | NPV with externalities ($B) mean / P10 / P50 / P90 | direct BCR mean / P10 / P50 / P90 | gate slip (yr) mean / P10 / P50 / P90 | launch CO2 (t) mean / P10 / P50 / P90 | P(DG-13.7 by Y120) mean / P10 / P50 / P90 |
|---|---|---|---|---|---|---|---|
| econFloor | 6,745,773 / 5,184,519 / 6,685,344 / 8,320,812 | 1,294,000 / 940,424 / 1,297,963 / 1,639,556 | -1,067 / -1,968 / -939 / -365 | 0.05429 / 0.04112 / 0.05355 / 0.06832 | 0 / 0 / 0 / 0 | 72,059,721 / 45,864,771 / 70,616,333 / 100,205,777 | 0.5 / 0 / 0.5 / 1 |
| targetFloor | 6,814,913 / 5,421,884 / 6,744,281 / 8,238,676 | 1,363,140 / 1,200,534 / 1,363,140 / 1,525,745 | -1,067 / -1,958 / -933 / -371 | 0.05422 / 0.04099 / 0.05361 / 0.06821 | 0 / 0 / 0 / 0 | 70,790,647 / 47,656,063 / 70,152,426 / 94,234,585 | 1 / 1 / 1 / 1 |

| Alternative | Earth mass P90 (t) | NPV CVaR90 ($B) | Earth mass SE (t) | P(no slip) |
|---|---|---|---|---|
| econFloor | 8,320,812 | -2,492 | 30,751 | 1.00 |
| targetFloor | 8,238,676 | -2,490 | 30,532 | 1.00 |

| Criterion | Recommended | P(win) | P(no slip) |
|---|---|---|---|
| expectedValue | econFloor | 0.50 | 1.00 |
| p90 | targetFloor | 0.50 | 1.00 |
| cvar90 | targetFloor | 0.50 | 1.00 |
| minimaxRegret | econFloor | 0.50 | 1.00 |
| chanceConstrained | econFloor | 0.50 | 1.00 |

## 3. Gate-year distributions

Every gate in the catalogue's Gates column, on the baseline's selected alternative (the lead recommendation where the baseline leaves the decision open). P(met) is the share of samples whose derived year is no later than the declared year; 'never' quantiles mean the criterion is not met on the horizon.

| Gate | Decision / alternative | Declared | P10 | P50 | P90 | P(met by declared year) | Note |
|---|---|---|---|---|---|---|---|
| DG-8.5 | D4 / optimisedDesign | Y28 | Y28 | Y28 | Y28 | 1.00 |  |
| DG-8.7 | D6 / consequenceOfGradeAndCapture | Y30 | Y37 | Y37 | Y38 | 0.00 |  |
| DG-9.1 | D3 / shuttlecock | Y35 | Y35 | Y35 | Y35 | 1.00 |  |
| DG-9.2 | D4 / optimisedDesign | Y38 | Y44 | Y44 | Y44 | 0.00 |  |
| DG-9.6 | D2 / msrWhenJustified | Y43 | Y44 | Y48 | Y55 | 0.06 |  |
| DG-10.1 | D8 / econFloor | Y45 | Y54 | Y59 | Y64 | 0.00 |  |
| DG-10.2 | D4 / optimisedDesign | Y48 | Y68 | Y76 | Y84 | 0.00 |  |
| DG-10.5 | D1 / carryThroughEclipse | Y50 | Y105 | Y105 | Y105 | 0.00 | ECN-022 s.2.3 (Y50 superseded) |
| DG-11.3 | D1 / carryThroughEclipse | Y70 | Y105 | Y105 | Y105 | 0.00 | ECN-022 s.2.3 (Y70 superseded) |
| DG-11.6 | D7 / testOutcomeDriven | Y65 | Y65 | Y65 | Y65 | 0.50 |  |
| DG-11.7 | D7 / testOutcomeDriven | - | never | never | never | - | no declared year (exogenous) |
| DG-11.8 | D5 / consequenceOfMTypeArrival | Y75 | Y75 | Y75 | Y75 | 1.00 |  |
| DG-12.4 | D5 / consequenceOfMTypeArrival | Y85 | Y85 | Y85 | Y85 | 1.00 |  |
| DG-13.4 | D1 / carryThroughEclipse | Y105 | Y105 | Y105 | Y105 | 1.00 |  |
| DG-13.7 | D8 / econFloor | Y120 | Y54 | Y54 | Y54 | 0.50 |  |
| DG-14.4 | D1 / carryThroughEclipse | Y125 | Y105 | Y105 | Y105 | 1.00 |  |
| DG-14.6 | D3 / shuttlecock | Y140 | never | never | never | 0.00 |  |
| DG-14.7 | D1 / carryThroughEclipse | Y140 | Y125 | Y125 | Y125 | 1.00 |  |

## 4. Named scenarios

Each scenario holds its overrides constant and samples everything else (n = 100 per scenario, seed 20260920); the lead recommendation under the default criterion per decision.

| Scenario | Overrides | D1 lead (P win) | D2 lead (P win) | D3 lead (P win) | D4 lead (P win) | D5 lead (P win) | D6 lead (P win) | D7 lead (P win) | D8 lead (P win) | D1 SPA power mass by strategy (t) |
|---|---|---|---|---|---|---|---|---|---|---|
| baseline | none | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 313; hotStandby 135; hybridStorage 53,018 |
| lowLaunchCost | launchCostMultiplier=0.5 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 313; hotStandby 135; hybridStorage 53,018 |
| lateMType | mTypeCaptureYear=85 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 313; hotStandby 135; hybridStorage 53,018 |
| highThorium | thoriumGradePpm=15, acidBakeThoriumCapture=0.95 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 313; hotStandby 135; hybridStorage 53,018 |
| msrUnavailable | spaMsrAvailabilityProbability=0 | sunlitDutyCycle (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 42,117; sunlitDutyCycle 7,424; hotStandby 7,051; hybridStorage 56,943 |
| msrUncertain | spaMsrAvailabilityProbability=0.9 | sunlitDutyCycle (0.10) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 4,334; sunlitDutyCycle 1,025; hotStandby 827; hybridStorage 53,411 |
| earthBuiltAsteroidPlant | asteroidPlantEarthFraction=1 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 4,794; hotStandby 135; hybridStorage 55,258 |
| holdLoadLow | holdLoadFraction=0.05 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 313; hotStandby 135; hybridStorage 53,018 |
| holdLoadHigh | holdLoadFraction=0.5 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 313; hotStandby 135; hybridStorage 53,018 |
| darkSite | spaDarkFraction=0.229 | carryThroughEclipse (1.00) | msrWhenJustified (1.00) | shuttlecock (0.71) | optimisedDesign (1.00) | consequenceOfMTypeArrival (1.00) | consequenceOfGradeAndCapture (1.00) | capacityForced (0.50) | econFloor (0.50) | carryThroughEclipse 135; sunlitDutyCycle 406; hotStandby 135; hybridStorage 53,071 |

## 5. Structural checks

All structural checks passed.
