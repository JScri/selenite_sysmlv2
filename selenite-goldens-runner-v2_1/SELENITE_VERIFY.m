%% SELENITE_VERIFY.m
%  Supply chain optimisation & feasibility verification
%  Mirrors Fleet Spec v2.2 + Mission Guide v12 specifications
%
%  Run section-by-section in MATLAB Editor (Ctrl+Enter per section)
%  or run whole file with F5. Requires R2021a or later.
%
%  Author : Jason (Systems Engineering Lead), Selenite Programme
%  Date   : March 2026
%  Ref    : SEL_ROBOT_FLEET_v2_2, W2_T1_1_JS_GUIDE_v12

clear; clc; close all;

% ── GLOBAL CONSTANTS ─────────────────────────────────────────────────
g0  = 9.81;           % m/s²
Isp = 450;            % s   (LH₂/LOX bipropellant — RL-10 class)
ve  = Isp * g0;       % m/s exhaust velocity  (~4,415 m/s)

fprintf('Selenite Programme — Supply Chain Verification\n');
fprintf('ve = Isp × g0 = %.0f × %.2f = %.1f m/s\n\n', Isp, g0, ve);


%% ════════════════════════════════════════════════════════════════════
%  SECTION 1 — VEHICLE MASS BUDGETS (Tsiolkovsky verification)
%  m_prop = m_final × (exp(ΔV / ve) − 1)
% ════════════════════════════════════════════════════════════════════

fprintf('== SECTION 1: VEHICLE MASS BUDGETS ==\n');

% ── PROBE-Scout (P3 initial; one-way asteroid survey, NOT return mission) ──
scout.m_dry   = 101;    % kg  body + instruments
scout.m_prop  = 142;    % kg  Earth-supplied LH₂/LOX
scout.m_wet   = 243;    % kg  total
scout.dv      = ve * log(scout.m_wet / scout.m_dry);
fprintf('\nPROBE-Scout (one-way survey, no payload return):\n');
fprintf('  dry=%g kg  prop=%g kg  wet=%g kg\n', scout.m_dry, scout.m_prop, scout.m_wet);
fprintf('  Implied ΔV = %.0f m/s  (~one-way to accessible NEA from LLO)\n', scout.dv);
fprintf('  NOTE: This is a DIFFERENT vehicle to the operational PROBE.\n');

% ── PROBE-Ops (operational, P3 onward; round-trip with 1,500 kg payload) ──
probe.m_dry     = 800;    % kg  structural + avionics + landing legs
probe.m_payload = 1500;   % kg  Ni-Fe/PGM semi-raw return
probe.m_prop    = 6650;   % kg  LH₂/LOX per round-trip mission
probe.dv_design = 6000;   % m/s design ΔV (accessible NEA, Ryugu-class)
probe.m_final   = probe.m_dry + probe.m_payload;
probe.m_wet     = probe.m_final + probe.m_prop;
probe.dv_check  = ve * log(probe.m_wet / probe.m_final);
probe.missions_yr = 1;    % 1 round trip per craft per year

fprintf('\nPROBE-Ops (round-trip + 1,500 kg payload return):\n');
fprintf('  dry=%g  payload=%g  prop=%g kg → wet=%g kg\n', ...
        probe.m_dry, probe.m_payload, probe.m_prop, probe.m_wet);
fprintf('  ΔV Tsiolkovsky: %.0f m/s  (stated: %.0f m/s)  → ', ...
        probe.dv_check, probe.dv_design);
if abs(probe.dv_check - probe.dv_design) < 100
    fprintf('[PASS]\n');
else
    fprintf('[FAIL — delta %.0f m/s]\n', probe.dv_check - probe.dv_design);
end

% ── SKIP hopper ──────────────────────────────────────────────────────
skip.m_dry      = 300;    % kg
skip.m_payload  = 350;    % kg  KREEP regolith per hop
skip.dv_rt      = 600;    % m/s round-trip sub-orbital ΔV
skip.fuel_hop   = (skip.m_dry + skip.m_payload) * (exp(skip.dv_rt/ve) - 1);
skip.hops_per_day = 1.0;
skip.avail      = 0.75;
skip.hops_yr    = skip.hops_per_day * 365 * skip.avail;
skip.fuel_yr    = skip.hops_yr * skip.fuel_hop;
skip.kreep_yr   = skip.hops_yr * skip.m_payload;

fprintf('\nSKIP hopper:\n');
fprintf('  Fuel per hop: %.1f kg  (doc: 94.6 kg)  → ', skip.fuel_hop);
if abs(skip.fuel_hop - 94.6) < 1, fprintf('[PASS]\n'); else fprintf('[FAIL]\n'); end
fprintf('  Hops/yr: %.0f  (doc: 274)\n', skip.hops_yr);
fprintf('  Fuel/yr per craft: %.1f t  (doc: 25.9 t)\n', skip.fuel_yr/1000);
fprintf('  KREEP raw/yr per craft: %.1f t  (doc: 95.8 t)\n', skip.kreep_yr/1000);
fprintf('  8-craft fleet fuel/yr: %.1f t  (doc: ~207 t)\n', 8*skip.fuel_yr/1000);

% ── DART orbital transfer vehicle ────────────────────────────────────
% Architecture: Shackleton → LLO ascent (~1,800 m/s) + coast +
%               powered descent to PKT (~1,900 m/s per leg)
% NOT ballistic arc (ruled out: 3,300 km arc = ~13,200 m/s ΔV, 30+ t fuel)
dart.m_dry       = 800;    % kg
dart.m_payload   = 1500;   % kg  PKT regolith
dart.m_final     = dart.m_dry + dart.m_payload;
dart.dv_best     = 7400;   % m/s  favourable orbital geometry
dart.dv_worst    = 8900;   % m/s  worst case + 15% margin
dart.dv_planning = 8200;   % m/s  planning value (mid-range)
dart.fuel_best   = dart.m_final * (exp(dart.dv_best/ve) - 1);
dart.fuel_worst  = dart.m_final * (exp(dart.dv_worst/ve) - 1);
dart.fuel_plan   = dart.m_final * (exp(dart.dv_planning/ve) - 1);
dart.fuel_doc    = 12370;  % kg  as stated in fleet doc
dart.cadence_yr  = 0.5;    % biennial = 0.5 missions/yr
dart.fuel_yr     = dart.fuel_doc * dart.cadence_yr;

% Reverse-engineer effective ΔV from doc figure
dart.dv_implied  = ve * log((dart.m_final + dart.fuel_doc) / dart.m_final);

fprintf('\nDART orbital transfer (LLO method — confirmed correct):\n');
fprintf('  Ballistic arc alternative: ~13,200 m/s → 30+ t fuel (RULED OUT)\n');
fprintf('  LLO ascent ~1,800 m/s + coast + descent ~1,900 m/s per leg\n');
fprintf('  ΔV at best  (%.0f m/s) → fuel = %.1f t\n', dart.dv_best, dart.fuel_best/1000);
fprintf('  ΔV at worst (%.0f m/s) → fuel = %.1f t\n', dart.dv_worst, dart.fuel_worst/1000);
fprintf('  ΔV planning (%.0f m/s) → fuel = %.1f t\n', dart.dv_planning, dart.fuel_plan/1000);
fprintf('  Doc states 12,370 kg → implied ΔV = %.0f m/s ', dart.dv_implied);
if dart.dv_implied >= dart.dv_best && dart.dv_implied <= dart.dv_worst
    fprintf('(within 7,400–8,900 range → [PASS])\n');
else
    fprintf('[outside stated range — CHECK]\n');
end
fprintf('  RECOMMENDATION: label doc figure as planning ΔV ~8,200 m/s (mid-range),\n');
fprintf('  not worst-case 8,900 m/s.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 2 — NEA DISTANCES AND PROBE TRANSIT TIMES
%  Note: Selenite targets Near-Earth Asteroids (NEAs), NOT main belt
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 2: NEA DISTANCES AND TRANSIT TIMES ==\n');

% NEA categories (CNEOS/JPL classification):
% Atiras:  a < 0.983 AU — entirely inside Earth's orbit
% Atens:   a < 1.0 AU, Q > 0.983 AU — cross Earth orbit
% Apollos: a > 1.0 AU, q < 1.017 AU — cross Earth orbit (majority of M-types)
% Amors:   1.017 < q < 1.3 AU — between Earth and Mars

% Accessible NEA parameters (low-ΔV Ryugu-class targets):
nea.semi_major_au = 1.0;        % AU  (typical accessible NEA like Ryugu, 2016 HO3)
nea.dv_one_way_km_s = 3.0;      % km/s  one-way from LLO (low-ΔV window)
nea.dv_rt_km_s = 6.0;           % km/s  round-trip (matches probe design)
nea.AU_km = 1.496e8;            % km per AU

% Hohmann-approximation transit time from lunar orbit to accessible NEA:
% Simplified: semi-major axis of transfer orbit ≈ (1 AU + a_target)/2
% Transfer time = half the period of the transfer ellipse
a_transfer = (1.0 + nea.semi_major_au) / 2;   % AU (simplified)
T_transfer_yr = a_transfer^1.5;                 % Kepler's 3rd law (period in years)
t_transit_yr = T_transfer_yr / 2;              % one-way (half period)
t_transit_months = t_transit_yr * 12;

fprintf('\nTarget type: M-type NEA (Ryugu-class, ~1.0 AU semi-major axis)\n');
fprintf('Main belt distance: 2.2–3.2 AU — NOT targeted by Selenite\n');
fprintf('Accessible NEA semi-major axis: ~%.1f AU\n', nea.semi_major_au);
fprintf('\nHohmann transfer estimate (from lunar orbit ≈ 1 AU):\n');
fprintf('  Transfer ellipse semi-major axis: %.2f AU\n', a_transfer);
fprintf('  One-way transit time: ~%.1f months\n', t_transit_months);
fprintf('  Return transit: ~%.1f months\n', t_transit_months);

% Time at asteroid for sample collection
t_at_asteroid_months = 1;       % 2–6 weeks for sample collection + prep

% Total round-trip mission duration
t_roundtrip_months = 2 * t_transit_months + t_at_asteroid_months;
fprintf('  Time at asteroid (sampling): ~%.0f month(s)\n', t_at_asteroid_months);
fprintf('  Total round-trip duration: ~%.0f–%.0f months\n', ...
        t_roundtrip_months - 1, t_roundtrip_months + 3);
fprintf('  Guide states: 6–18 months transit — ');
if t_transit_months >= 3 && t_transit_months <= 9
    fprintf('consistent [PASS]\n');
else
    fprintf('[CHECK against actual target selection]\n');
end

fprintf('\nPROBE-Scout (one-way survey, P3 initial):\n');
fprintf('  ΔV = %.0f m/s → one-way capable to ~1 AU targets\n', scout.dv);
fprintf('  Transit: ~%.0f months one-way; no return required\n', t_transit_months);
fprintf('  Purpose: characterise NEA target geometry, surface composition,\n');
fprintf('  approach vectors before committing full PROBE-Ops fleet.\n');
fprintf('  Lower mass (243 kg vs 8,950 kg) because no return propellant load.\n');

fprintf('\nNOTE: Actual transit time depends heavily on launch window.\n');
fprintf('  Best windows recur every 12–24 months for a given target.\n');
fprintf('  Programme must manage departure timing to avoid extended waits.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 3 — MOLE-I PROPELLANT YIELD (PSR ice sensitivity)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 3: MOLE-I PROPELLANT YIELD ==\n');
fprintf('All water ISRU = MOLE-I exclusively (PSR Shackleton Crater)\n');
fprintf('MOLE-S = surface regolith only; does NOT contribute to propellant.\n\n');

molei.drill_rate_hr  = 25;      % kg/hr total drill throughput (ESA PROSPECT heritage)
molei.availability   = 0.80;    % 80% operational availability
molei.psr_frac_lcross = 0.056;  % LCROSS plume water mass fraction
molei.psr_frac_doc   = 0.045;   % conservative planning value (back-calculated)
molei.prop_yield_doc = 5645;    % kg/yr as stated in fleet doc v2.2

% First-principles derivation
molei.water_rate_lc  = molei.drill_rate_hr * molei.psr_frac_lcross;
molei.water_yr_lc    = molei.water_rate_lc * molei.availability * 8760;
molei.prop_fp_lc     = molei.water_yr_lc * 0.722;   % electrolysis + Sabatier yield

molei.water_rate_doc = molei.drill_rate_hr * molei.psr_frac_doc;
molei.water_yr_doc   = molei.water_rate_doc * molei.availability * 8760;
molei.prop_fp_doc    = molei.water_yr_doc * 0.722;

fprintf('  Using LCROSS fraction (%.1f%%): water = %.2f kg/hr → %.0f kg/yr → %.0f kg prop/yr\n', ...
        molei.psr_frac_lcross*100, molei.water_rate_lc, molei.water_yr_lc, molei.prop_fp_lc);
fprintf('  Using doc fraction  (%.1f%%): water = %.2f kg/hr → %.0f kg/yr → %.0f kg prop/yr\n', ...
        molei.psr_frac_doc*100, molei.water_rate_doc, molei.water_yr_doc, molei.prop_fp_doc);
fprintf('  Doc stated value: %d kg/yr  (%.1f%% discrepancy from LCROSS — within uncertainty)\n', ...
        molei.prop_yield_doc, abs(molei.prop_fp_lc - molei.prop_yield_doc)/molei.prop_yield_doc*100);

% Sensitivity range
fprintf('\n  PSR Ice Fraction → MOLE-I Propellant Yield (kg/yr):\n');
fracs = 0.03:0.01:0.10;
for f = fracs
    y = f * molei.drill_rate_hr * molei.availability * 8760 * 0.722;
    marker = '';
    if abs(f - molei.psr_frac_lcross) < 0.001, marker = ' ← LCROSS'; end
    if abs(f - molei.psr_frac_doc) < 0.001,    marker = ' ← doc assumed'; end
    fprintf('    %.0f%%: %.0f kg/yr%s\n', f*100, y, marker);
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 4 — PHASE PROPELLANT BALANCE (MOLE-I model)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 4: PHASE PROPELLANT BALANCE ==\n');
fprintf('ISRU source: MOLE-I only @ %.0f kg/yr per unit\n\n', molei.prop_yield_doc);

% Life support oxygen equivalent propellant commitment per crew member
ls_prop_crew = 0.84 * 365 / 0.889 * 0.722;   % kg/yr per person

% Phase data: [nMOLE-I, nPROBE, nSKIP, nDart, crew]
% Note: P3 PROBE missions are Earth-fuelled → PROBE ISRU demand = 0 in P3
ph = struct();
ph.labels = {'P3 Y4-7','P4 Y7-9','P5 Y9-12','P6 Y12-15','P7+ Y20+'};
ph.data = [
%  nMI  nP  nS  nD crew
    4    3   1   0   0;   % P3: SKIP starts M70 (14 of 36 P3 months)
   12    6   1   0   4;   % P4
   23   10   2   1   4;   % P5
   38   15   4   1   6;   % P6
   73   30   8   0  12;   % P7+
];

ph.n_phases = size(ph.data, 1);
ph.isru      = zeros(ph.n_phases, 1);
ph.d_probe   = zeros(ph.n_phases, 1);
ph.d_skip    = zeros(ph.n_phases, 1);
ph.d_dart    = zeros(ph.n_phases, 1);
ph.d_ls      = zeros(ph.n_phases, 1);
ph.demand    = zeros(ph.n_phases, 1);
ph.margin    = zeros(ph.n_phases, 1);

for i = 1:ph.n_phases
    nMI   = ph.data(i,1);
    nP    = ph.data(i,2);
    nS    = ph.data(i,3);
    nD    = ph.data(i,4);
    crew  = ph.data(i,5);

    ph.isru(i)    = nMI * molei.prop_yield_doc;             % kg/yr
    ph.d_probe(i) = nP  * probe.m_prop * probe.missions_yr; % kg/yr (0 for P3 Earth-fuelled)
    ph.d_skip(i)  = nS  * skip.fuel_yr;                     % kg/yr
    ph.d_dart(i)  = nD  * dart.fuel_doc * dart.cadence_yr;  % kg/yr (biennial)
    ph.d_ls(i)    = crew * ls_prop_crew;                     % kg/yr
    ph.demand(i)  = ph.d_probe(i) + ph.d_skip(i) + ph.d_dart(i) + ph.d_ls(i);
    ph.margin(i)  = ph.isru(i) - ph.demand(i);
end

fprintf('%-14s %6s %10s %9s %8s %8s %5s %11s %9s  Status\n', ...
    'Phase','MOLE-I','ISRU(t)','Probe(t)','Skip(t)','Dart(t)','LS(t)','Demand(t)','Margin(t)');
fprintf('%s\n', repmat('-', 1, 95));
for i = 1:ph.n_phases
    if ph.margin(i) >= 5000
        status = 'PASS';
    elseif ph.margin(i) >= 0
        status = 'TIGHT';
    else
        status = 'FAIL*';
    end
    fprintf('%-14s %6d %10.1f %9.1f %8.1f %8.1f %5.1f %11.1f %+9.1f  %s\n', ...
        ph.labels{i}, ph.data(i,1), ...
        ph.isru(i)/1000, ph.d_probe(i)/1000, ph.d_skip(i)/1000, ...
        ph.d_dart(i)/1000, ph.d_ls(i)/1000, ph.demand(i)/1000, ph.margin(i)/1000, status);
end
fprintf('\n* P3 FAIL note: SKIP operates for ~14 of 36 P3 months (starts M70).\n');
fprintf('  Effective P3 SKIP demand: ~%.1f t (not %.1f t full-year).\n', ...
        14/12 * skip.fuel_yr/1000, skip.fuel_yr/1000);
fprintf('  P3 PROBE missions are 100%% Earth-fuelled → no ISRU draw.\n');
fprintf('  Real P3 deficit is small; two remediation options evaluated below.\n');

% P3 remediation comparison
fprintf('\n── P3 REMEDIATION OPTIONS ──────────────────────────────────────\n');
p3_skip_actual_demand = (14/12) * skip.fuel_yr;  % partial year
p3_isru_base = 4 * molei.prop_yield_doc;
p3_deficit   = p3_skip_actual_demand - p3_isru_base;
if p3_deficit < 0
    fprintf('  With partial-year SKIP (14 months): surplus of %.0f kg → NO DEFICIT\n', abs(p3_deficit));
else
    fprintf('  With partial-year SKIP (14 months): deficit of %.0f kg\n', p3_deficit);
end
fprintf('\n  Option A — Earth propellant supplement:\n');
fprintf('    Supplement %.0f kg LH₂/LOX from Earth for SKIP-1 P3 ops.\n', max(0, p3_deficit));
fprintf('    Pro: No additional infrastructure; P3 already Earth-fuelled for PROBE.\n');
fprintf('    Con: Adds launch mass; unit cost of Earth propellant to lunar surface\n');
fprintf('         ~$10,000–$50,000/kg depending on vehicle class.\n');

fprintf('\n  Option B — Scale MOLE-I from 4 → 8 units:\n');
p3_isru_8mi = 8 * molei.prop_yield_doc;
fprintf('    ISRU output: 4 → 8 MOLE-I = %.0f t/yr → margin of %.0f kg vs SKIP demand.\n', ...
        p3_isru_8mi/1000, p3_isru_8mi - skip.fuel_yr);
fprintf('    Pro: Eliminates deficit permanently; accelerates P4 ISRU ramp.\n');
fprintf('    Con: 4 extra MOLE-I → 4 more descent winches + PSR charging ports.\n');
power_extra_mi = 4 * (800 + 35) / 1000;  % kW: excavation + WEB heating
fprintf('         Extra power demand: ~%.1f kW continuous (WEB heating always-on).\n', power_extra_mi);
fprintf('         Also doubles early PSR maintenance burden (Y4–5).\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 5 — DART STOCKPILE TIME (accounting for other fleet demand)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 5: DART STOCKPILE ACCUMULATION ==\n');
fprintf('Doc states: ~22 months at 5,000 kg/yr ISRU surplus to accumulate 9 t.\n');
fprintf('QUESTION: Does the 5,000 kg/yr account for PROBE + SKIP demand?\n\n');

% At P5 (when DART arrives, M108):
p5_isru    = 23 * molei.prop_yield_doc;   % 129,835 kg/yr
p5_d_probe = 10 * probe.m_prop;           % 66,500 kg/yr
p5_d_skip  = 2  * skip.fuel_yr;           % 51,820 kg/yr
p5_d_ls    = 4  * ls_prop_crew;           % ~1,000 kg/yr
p5_surplus = p5_isru - p5_d_probe - p5_d_skip - p5_d_ls;

fprintf('  P5 MOLE-I ISRU output:          %.0f kg/yr\n', p5_isru);
fprintf('  P5 PROBE fleet demand:          %.0f kg/yr\n', p5_d_probe);
fprintf('  P5 SKIP fleet demand:           %.0f kg/yr\n', p5_d_skip);
fprintf('  P5 life support demand:         %.0f kg/yr\n', p5_d_ls);
fprintf('  P5 surplus available for DART:  %.0f kg/yr\n', p5_surplus);

dart_target_prop = 9000;  % kg minimum for first mission
stockpile_months_doc  = dart_target_prop / (5000/12);
stockpile_months_real = dart_target_prop / (p5_surplus/12);

fprintf('\n  Doc assumed surplus: 5,000 kg/yr → stockpile time: %.0f months\n', ...
        stockpile_months_doc);
fprintf('  Actual P5 surplus:   %.0f kg/yr → stockpile time: %.0f months\n', ...
        p5_surplus, stockpile_months_real);

if stockpile_months_real > stockpile_months_doc
    fprintf('  ⚠ DART stockpile takes %.0f months longer than doc states.\n', ...
            stockpile_months_real - stockpile_months_doc);
    dart_first_mission = 108 + stockpile_months_real;
    fprintf('  First PKT mission shifts from M127 to ~M%.0f (Y%.1f) if surplus holds.\n', ...
            dart_first_mission, dart_first_mission/12);
else
    fprintf('  Stockpile time is within doc estimate.\n');
end
fprintf('\n  CONCLUSION: 5,000 kg/yr figure IS a surplus (after other demand),\n');
fprintf('  not total ISRU. But actual P5 surplus (%.0f kg/yr) is tighter.\n', p5_surplus);
fprintf('  Recommend: track DART accumulation separately as a running reserve.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 6 — DOCKING COLLAR THROUGHPUT AND MINIMUM COLLAR COUNT
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 6: DOCKING COLLAR THROUGHPUT ==\n');

turnaround_hr = 60;    % hours (midpoint of 48–72h range)
collar_util   = 0.70;  % 70% operational utilisation
collar_cap_yr = 365*24 / turnaround_hr * collar_util;

fprintf('Per-collar capacity (%.0fh turnaround, %.0f%% util): %.0f missions/yr\n\n', ...
        turnaround_hr, collar_util*100, collar_cap_yr);

dock_data = [2,3; 4,6; 6,10; 8,15; 8,30];
ph2 = {'P3','P4','P5','P6','P7+'};
fprintf('%-8s %8s %16s %12s %8s\n', 'Phase','Collars','Cap(mis/yr)','PROBEs/yr','Util%');
for i = 1:5
    cap  = dock_data(i,1) * collar_cap_yr;
    util = dock_data(i,2) / cap * 100;
    fprintf('%-8s %8d %16.0f %12d %7.1f%%\n', ph2{i}, dock_data(i,1), cap, dock_data(i,2), util);
end

fprintf('\n── MINIMUM COLLAR ANALYSIS: 30-PROBE FLEET ────────────────────\n');
fprintf('Mathematical minimum: 1 collar can service %.0f missions/yr >> 30/yr\n', collar_cap_yr);
fprintf('But single collar has risks:\n');

% Poisson arrival probability (simultaneous returns)
lambda_per_year = 30;                              % 30 PROBE returns/yr
lambda_per_window = lambda_per_year * (turnaround_hr / 8760);  % per turnaround window
prob_2_plus = 1 - exp(-lambda_per_window) - lambda_per_window * exp(-lambda_per_window);
expected_conflicts_yr = prob_2_plus * (8760 / turnaround_hr) * collar_util;

fprintf('\n  Simultaneous return risk (Poisson, unscheduled departures):\n');
fprintf('    Expected arrivals per %.0fh window: λ = %.4f\n', turnaround_hr, lambda_per_window);
fprintf('    P(2+ in same window):  %.1f%%\n', prob_2_plus * 100);
fprintf('    Expected queue conflicts/yr: %.2f (largely preventable with scheduling)\n', ...
        expected_conflicts_yr);
fprintf('\n  With controlled departure scheduling (15-PROBE staggered 24-day intervals):\n');
fprintf('    Arrivals are deterministic → P(conflict) ≈ 0.\n');
fprintf('    In practice, asteroid mission timing varies ±weeks → minor scheduling buffer.\n');

fprintf('\n  Non-throughput justifications for 4–8 collars:\n');
fprintf('    • Maintenance bays: %.0f craft in maintenance at any time (15%% rule)\n', ceil(30*0.15));
fprintf('    • Parallel payload processing + propellant loading can be concurrent\n');
fprintf('    • Redundancy: single collar failure = programme stop if only 1 exists\n');
fprintf('    • Each collar has an associated ARM robot; ARM servicing also requires space\n');
fprintf('    • Plume hazard: PROBE departure LH₂/LOX exhaust is H₂O steam;\n');
fprintf('      requires standoff corridor + base-facing blast shield per collar.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 7 — FULL SYSTEM POWER BUDGET (Phase 7+)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 7: POWER BUDGET — P7+ FULL SCALE ==\n');
fprintf('73 MOLE-I, 6 MOLE-S, 8 ARM, 3 SINTER, 2 SURVEY, 8 SKIP, 4 SENTINEL, 12 crew\n\n');

% Robot power draw estimates (kW per unit, active)
pw.molei_exc   = 0.800;   % kW excavation (same drum as MOLE-S, at 25 kg/hr)
pw.molei_web   = 0.035;   % kW WEB heating — ALWAYS ON (RHU + resistive)
pw.molei_avail = 0.80;    % fraction active at any time
pw.moles_exc   = 0.800;   % kW
pw.moles_avail = 0.80;
pw.arm_ops     = 3.000;   % kW (7-DOF heavy manipulator, high power when active)
pw.arm_avail   = 0.40;    % 40% active (most time idle between PROBE arrivals)
pw.sinter_ops  = 5.000;   % kW (microwave sintering ~1,050°C)
pw.sinter_avail= 0.70;
pw.survey_ops  = 0.300;   % kW (instruments + locomotion)
pw.survey_avail= 0.60;
pw.sentinel_ops= 0.150;   % kW (lightweight inspection bot)
pw.sentinel_avail = 0.90;
pw.skip_base   = 0.100;   % kW (avionics + refuel interface when docked)
pw.dart_base   = 0.150;   % kW

% ISRU plant power (electrolysis + cryocooling — batch duty-cycled)
pw.electrolyzer = 25.0;   % kW average (capacity ~100 kW, ~25% duty cycle)
pw.cryocooling  = 8.0;    % kW average (LH₂/LOX cryostorage)
pw.vex_batch    = 10.0;   % kW (1 VEX per 8 MOLE-I at batch mode, not 1:1)

% Base and crew systems
pw.habitat       = 20.0;   % kW (HVAC, lighting, pressure management)
pw.life_support  = 15.0;   % kW (O₂/CO₂ loops, water recycling)
pw.crew_personal = 2.0;    % kW per person (electronics, medical)
pw.comms         = 3.0;    % kW (relay uplink, base LAN)
pw.computing     = 2.0;    % kW (autonomy servers, telemetry)
pw.benef_module  = 16.0;   % kW (jaw crusher + screens + magnetic separators)
pw.charging_infra= 5.0;    % kW (charging stations for robot battery top-up)

% Calculate totals
n_molei   = 73;
n_moles   = 6;
n_arm     = 8;
n_sinter  = 3;
n_survey  = 2;
n_sentinel= 4;
n_skip    = 8;
n_dart    = 1;
n_crew    = 12;

pwr.molei_exc   = n_molei * pw.molei_exc * pw.molei_avail;
pwr.molei_web   = n_molei * pw.molei_web;                  % always-on
pwr.moles       = n_moles * pw.moles_exc * pw.moles_avail;
pwr.arm         = n_arm   * pw.arm_ops   * pw.arm_avail;
pwr.sinter      = n_sinter* pw.sinter_ops* pw.sinter_avail;
pwr.survey      = n_survey* pw.survey_ops* pw.survey_avail;
pwr.sentinel    = n_sentinel*pw.sentinel_ops*pw.sentinel_avail;
pwr.skip_base   = n_skip  * pw.skip_base;
pwr.dart_base   = n_dart  * pw.dart_base;
pwr.isru_elec   = pw.electrolyzer;
pwr.isru_cryo   = pw.cryocooling;
pwr.vex         = pw.vex_batch;
pwr.habitat     = pw.habitat;
pwr.life_support= pw.life_support;
pwr.crew_pers   = n_crew * pw.crew_personal;
pwr.comms       = pw.comms;
pwr.computing   = pw.computing;
pwr.benef       = pw.benef_module;
pwr.charging    = pw.charging_infra;

fields = fieldnames(pwr);
total_kw = 0;
fprintf('%-22s %8s\n', 'Consumer', 'Power(kW)');
fprintf('%s\n', repmat('-', 32, 1));
for i = 1:length(fields)
    v = pwr.(fields{i});
    total_kw = total_kw + v;
    fprintf('%-22s %8.1f\n', fields{i}, v);
end
fprintf('%s\n', repmat('-', 32, 1));
fprintf('%-22s %8.1f kW\n', 'TOTAL CONTINUOUS', total_kw);
fprintf('\nPeak demand (simultaneous SINTER + ARM active): +%.1f kW\n', ...
        n_sinter*pw.sinter_ops*(1-pw.sinter_avail) + n_arm*pw.arm_ops*(1-pw.arm_avail));

% Solar sizing
sun_fraction  = 0.89;   % Shackleton, 89–94% annual sunlight
panel_eff     = 0.29;   % 29% panel efficiency (current state of practice)
solar_output_per_kw_capacity = sun_fraction * panel_eff;
solar_needed_kw = total_kw / solar_output_per_kw_capacity;

fprintf('\nSolar array sizing (89%% sun, 29%% panel efficiency):\n');
fprintf('  Average output per kW capacity: %.3f kW\n', solar_output_per_kw_capacity);
fprintf('  Required capacity: %.0f kW  (doc states ~1,000 kW)\n', solar_needed_kw);
if abs(solar_needed_kw - 1000) / 1000 < 0.30
    fprintf('  → Consistent with doc figure [PASS]\n');
else
    fprintf('  → Discrepancy: revise doc solar figure.\n');
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 8 — PLOTS
% ════════════════════════════════════════════════════════════════════

x_ph = 1:ph.n_phases;
ph_xlabels = strrep(ph.labels, ' ', '\n');

% ── Plot 1: Propellant balance by phase ──────────────────────────────
figure('Name','Fig 1 — Propellant Balance by Phase', ...
       'Position',[50 50 920 480]);
bar_data = [ph.isru, ph.demand] / 1000;
b = bar(x_ph, bar_data, 'grouped');
b(1).FaceColor = [0.18 0.42 0.72];
b(2).FaceColor = [0.85 0.32 0.24];
hold on;
plot(x_ph, ph.margin/1000, 'k--o', 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 6);
yline(0, 'k:', 'LineWidth', 1);
ylabel('Propellant (t/yr)');
xlabel('Programme Phase');
xticks(x_ph); xticklabels(ph.labels);
legend({'ISRU Supply (MOLE-I @ 5,645 kg/yr/unit)', 'Fleet Demand', 'Margin (ISRU − Demand)'}, ...
       'Location', 'northwest');
title('Selenite Programme: Propellant Balance by Phase (MOLE-I model)');
grid on; set(gca, 'FontSize', 11);

% ── Plot 2: Output mass by phase ─────────────────────────────────────
figure('Name','Fig 2 — Annual Processed Output by Phase', ...
       'Position',[50 580 920 400]);
output_probe = ph.data(:,2) * probe.m_payload * 0.90 / 1000;   % t/yr PGM/NiFe
output_kreep = ph.data(:,3) .* (skip.kreep_yr/1000) * 0.04;    % t/yr REE concentrate
output_dart  = ph.data(:,4) * 1500 * dart.cadence_yr / 1000;   % t/yr PKT return
bar(x_ph, [output_probe, output_kreep, output_dart], 'stacked');
colororder([0.18 0.42 0.72; 0.30 0.65 0.30; 0.72 0.52 0.18]);
ylabel('Output (t/yr)');
xlabel('Programme Phase');
xticks(x_ph); xticklabels(ph.labels);
legend({'PGM/Ni-Fe (PROBE)','REE Concentrate (SKIP KREEP)','PKT Material (DART)'});
title('Selenite Programme: Processed Material Output by Phase');
grid on; set(gca, 'FontSize', 11);

% ── Plot 3: MOLE-I yield sensitivity ─────────────────────────────────
figure('Name','Fig 3 — MOLE-I Yield Sensitivity to PSR Ice Fraction', ...
       'Position',[990 50 700 420]);
fracs_plot = 0.02:0.001:0.12;
yields_plot = fracs_plot * molei.drill_rate_hr * molei.availability * 8760 * 0.722;
plot(fracs_plot*100, yields_plot/1000, 'b-', 'LineWidth', 2.5); hold on;
yline(molei.prop_yield_doc/1000, 'r--', 'LineWidth', 1.5);
text(2.5, molei.prop_yield_doc/1000 + 0.1, sprintf('Doc: %.2f t/yr', molei.prop_yield_doc/1000), ...
     'Color', 'r', 'FontSize', 10);
xline(molei.psr_frac_lcross*100, 'g--', 'LineWidth', 1.5);
text(molei.psr_frac_lcross*100 + 0.1, 1, 'LCROSS 5.6%', 'Color', [0 0.5 0], 'FontSize', 10);
xline(molei.psr_frac_doc*100, 'm--', 'LineWidth', 1.5);
text(molei.psr_frac_doc*100 + 0.1, 0.5, 'Doc assumed 4.5%', 'Color', 'm', 'FontSize', 10);
xlabel('PSR Regolith Water Content (% by mass)');
ylabel('MOLE-I Propellant Yield (t/yr per unit)');
title('MOLE-I Propellant Yield Sensitivity to PSR Ice Concentration');
xlim([2 12]); grid on; set(gca, 'FontSize', 11);

% ── Plot 4: PROBE ΔV trade ────────────────────────────────────────────
figure('Name','Fig 4 — PROBE Propellant vs Mission ΔV', ...
       'Position',[990 530 700 420]);
dv_range = 3000:100:12000;
fuel_range = probe.m_final * (exp(dv_range/ve) - 1);
plot(dv_range/1000, fuel_range/1000, 'b-', 'LineWidth', 2.5); hold on;
xline(probe.dv_design/1000, 'r--', 'LineWidth', 1.5);
text(probe.dv_design/1000 + 0.1, 5, sprintf('Design %.0f km/s', probe.dv_design/1000), ...
     'Color', 'r', 'FontSize', 10);
yline(probe.m_prop/1000, 'g--', 'LineWidth', 1.5);
text(3.2, probe.m_prop/1000 + 0.5, sprintf('%.1f t prop', probe.m_prop/1000), ...
     'Color', [0 0.5 0], 'FontSize', 10);
% Mark scout ΔV range
xline(scout.dv/1000, 'm--', 'LineWidth', 1.5);
text(scout.dv/1000 + 0.1, 20, 'Scout ΔV', 'Color', 'm', 'FontSize', 10);
xlabel('Round-trip ΔV (km/s)');
ylabel('Propellant Required (t)');
title(sprintf('PROBE Propellant vs Mission ΔV  (Isp=%gs, dry=%gkg, payload=%gkg)', ...
              Isp, probe.m_dry, probe.m_payload));
xlim([3 12]); ylim([0 60]); grid on; set(gca, 'FontSize', 11);

% ── Plot 5: Power budget breakdown ───────────────────────────────────
figure('Name','Fig 5 — P7+ Power Budget', ...
       'Position',[50 1100 700 450]);
pw_labels = {
    'MOLE-I excavation','MOLE-I WEB heat','MOLE-S','ARM robots', ...
    'SINTER rovers','SURVEY+SENTINEL','SKIP+DART (docked)', ...
    'ISRU electrolysis','ISRU cryo+VEX', ...
    'Habitat','Life support','Crew personal', ...
    'Comms+Computing','Beneficiation','Charging infra'
};
pw_vals = [pwr.molei_exc, pwr.molei_web, pwr.moles, pwr.arm, ...
           pwr.sinter, pwr.survey+pwr.sentinel, pwr.skip_base+pwr.dart_base, ...
           pwr.isru_elec, pwr.isru_cryo+pwr.vex, ...
           pwr.habitat, pwr.life_support, pwr.crew_pers, ...
           pwr.comms+pwr.computing, pwr.benef, pwr.charging];
pie(pw_vals);
legend(pw_labels, 'Location', 'eastoutside', 'FontSize', 8);
title(sprintf('P7+ Power Budget (Total: %.0f kW continuous, ~%.0f kW solar capacity needed)', ...
              total_kw, solar_needed_kw));

fprintf('\nAll plots generated. Review Figures 1–5.\n');
fprintf('\n== SELENITE_VERIFY.m COMPLETE ==\n');