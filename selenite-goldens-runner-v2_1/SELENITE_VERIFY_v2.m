%% SELENITE_VERIFY.m
%  Supply-chain optimisation & feasibility verification
%  Mirrors Fleet Spec v2.6 + Mission Guide v14 + Strategy v1.2
%
%  Run section-by-section in MATLAB Editor (Ctrl+Enter per section)
%  or run whole file with F5. Requires R2021a or later.
%
%  Author : Jason (Systems Engineering Lead), Selenite Programme
%  Date   : March 2026  (REVISED — corrected SKIP ΔV, ice strength,
%           pipeline heating, MOLE-I fleet sizing from first principles)
%  Ref    : SEL_ROBOT_FLEET_v2_6, W2_T1_1_JS_GUIDE_v14, audit findings

clear; clc; close all;

% ── GLOBAL CONSTANTS ─────────────────────────────────────────────────
g0      = 9.81;           % m/s²  (standard gravity)
g_moon  = 1.62;           % m/s²  (lunar surface gravity)
Isp     = 450;            % s     (LH₂/LOX bipropellant — RL-10 class)
ve      = Isp * g0;       % m/s   exhaust velocity (~4,415 m/s)
c_light = 299792;         % km/s  speed of light
d_moon  = 384400;         % km    mean Earth–Moon distance

fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('  Selenite Programme — Supply Chain Verification (REVISED)\n');
fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('ve = Isp × g0 = %d × %.2f = %.1f m/s\n', Isp, g0, ve);
fprintf('Lunar gravity: %.2f m/s²\n\n', g_moon);


%% ════════════════════════════════════════════════════════════════════
%  SECTION 1 — SHACKLETON CRATER GEOMETRY (corrected)
% ════════════════════════════════════════════════════════════════════

fprintf('== SECTION 1: SHACKLETON CRATER GEOMETRY ==\n');

crater.depth_km      = 4.2;    % km  (Zuber et al. 2012, Spudis 2008)
crater.wall_slope_deg= 30;     % deg (Haruyama et al. 2008, SELENE/Kaguya TC)
crater.wall_slope_rad= deg2rad(crater.wall_slope_deg);

% Slant distance from rim to floor
crater.traverse_km   = crater.depth_km / sin(crater.wall_slope_rad);

fprintf('  Depth:            %.1f km (Zuber et al. 2012)\n', crater.depth_km);
fprintf('  Wall slope:       %d° (Haruyama et al. 2008 — was incorrectly 22° prior)\n', ...
        crater.wall_slope_deg);
fprintf('  Traverse (slant): %.1f km (= %.1f / sin(%d°))\n', ...
        crater.traverse_km, crater.depth_km, crater.wall_slope_deg);
fprintf('  OLD estimate:     ~4.0 km (based on 22° — INCORRECT)\n');
fprintf('  Correction factor: %.2f× longer traverse\n\n', crater.traverse_km / 4.0);

% PSR temperatures (Diviner radiometer)
crater.T_floor_avg   = 88;     % K  (Diviner)
crater.T_floor_range = [50 90]; % K  (coldest micro-environments to warmest)
crater.T_wall_sunlit = [280 290]; % K (when illuminated)
crater.T_wall_psr    = 25;     % K  (nested shadow geometries)

fprintf('  Floor temperature:    %d K average (%d–%d K range)\n', ...
        crater.T_floor_avg, crater.T_floor_range(1), crater.T_floor_range(2));
fprintf('  Wall (sunlit):        %d–%d K\n', crater.T_wall_sunlit(1), crater.T_wall_sunlit(2));
fprintf('  Wall (nested shadow): ~%d K (sizing case for transit)\n', crater.T_wall_psr);

% Solar illumination (Mazarico et al. 2011, Gläser et al. 2014)
crater.sun_pct_ground = 0.82;   % 82% at surface level (Gläser 2014 upper bound)
crater.sun_pct_mast   = 0.89;   % 89% at 10 m mast height (Mazarico 2011)
crater.sun_pct_design = 0.85;   % design midpoint for power sizing

fprintf('\n  Solar illumination:\n');
fprintf('    Ground level: ~%.0f%% (Gläser et al. 2014)\n', crater.sun_pct_ground*100);
fprintf('    10 m mast:    ~%.0f%% (Mazarico et al. 2011)\n', crater.sun_pct_mast*100);
fprintf('    Design value:  %.0f%% (midpoint for power sizing)\n', crater.sun_pct_design*100);

% Ice content
crater.ice_lcross     = 0.056;  % LCROSS plume (Cabeus crater, Colaprete 2010)
crater.ice_luchsinger = 0.043;  % Luchsinger et al. 2021 reanalysis
crater.ice_design     = 0.045;  % design planning value
crater.ice_minirf_ub  = 0.10;   % Mini-RF upper bound

fprintf('\n  Water ice (Shackleton — UNCONFIRMED, extrapolated from Cabeus):\n');
fprintf('    LCROSS Cabeus:       %.1f ± 2.9 wt%%\n', crater.ice_lcross*100);
fprintf('    Luchsinger reanalysis: %.1f wt%%\n', crater.ice_luchsinger*100);
fprintf('    Mini-RF upper bound:  ≤%.0f wt%%\n', crater.ice_minirf_ub*100);
fprintf('    Design planning value: %.1f wt%%\n', crater.ice_design*100);
fprintf('    NOTE: If prospecting negative → programme rebases to Cabeus.\n');

% Ice compressive strength (icy permafrost regolith)
ice.pure_strength_90K  = 70;    % MPa (Arakawa & Maeno 1997, polycrystalline)
ice.regolith_low       = 5;     % MPa (low cementation, scattered ice)
ice.regolith_high      = 20;    % MPa (well-cemented frozen soil analogue)
ice.design_value       = 12;    % MPa (midpoint for excavation power sizing)

fprintf('\n  Icy regolith compressive strength at ~4.5%% ice, 90 K:\n');
fprintf('    Pure ice at 90 K:    ~%d MPa (Arakawa & Maeno 1997)\n', ice.pure_strength_90K);
fprintf('    Icy permafrost range: %d–%d MPa (frozen soil analogue)\n', ...
        ice.regolith_low, ice.regolith_high);
fprintf('    Design value:         %d MPa (midpoint)\n', ice.design_value);
fprintf('    NOTE: pure ice value NOT applicable — ice is ~4.5%% of regolith matrix\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 2 — VEHICLE MASS BUDGETS (Tsiolkovsky verification)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 2: VEHICLE MASS BUDGETS ==\n');

% ── PROBE-Scout (one-way asteroid survey) ──
scout.m_dry   = 101;    % kg
scout.m_prop  = 142;    % kg  Earth-supplied
scout.m_wet   = scout.m_dry + scout.m_prop;
scout.dv      = ve * log(scout.m_wet / scout.m_dry);

fprintf('\nPROBE-Scout (one-way survey):\n');
fprintf('  dry=%g kg  prop=%g kg  wet=%g kg\n', scout.m_dry, scout.m_prop, scout.m_wet);
fprintf('  ΔV = %.0f m/s (one-way to accessible NEA from LLO)\n', scout.dv);

% ── PROBE-Ops (round-trip + 1,500 kg payload) ──
probe.m_dry     = 800;    % kg
probe.m_payload = 1500;   % kg  Ni-Fe/PGM return
probe.m_final   = probe.m_dry + probe.m_payload;
probe.dv_design = 6000;   % m/s  design (best-case favourable window)
probe.dv_range  = [4000 10000]; % m/s  (NHATS accessible NEA range from LLO)
probe.m_prop    = probe.m_final * (exp(probe.dv_design / ve) - 1);
probe.dv_check  = ve * log((probe.m_final + probe.m_prop) / probe.m_final);
probe.missions_yr = 1;

fprintf('\nPROBE-Ops (round-trip + payload):\n');
fprintf('  dry=%g  payload=%g  m_final=%g kg\n', probe.m_dry, probe.m_payload, probe.m_final);
fprintf('  Design ΔV: %d m/s (best-case, Ryugu-class low-i NEA)\n', probe.dv_design);
fprintf('  Propellant: %.0f kg  → ΔV check: %.0f m/s  ', probe.m_prop, probe.dv_check);
if abs(probe.dv_check - probe.dv_design) < 100
    fprintf('[PASS]\n');
else
    fprintf('[FAIL — delta %.0f m/s]\n', probe.dv_check - probe.dv_design);
end
fprintf('  NHATS accessible range: %d–%d m/s from LLO\n', probe.dv_range(1), probe.dv_range(2));
fprintf('  6 km/s is BEST-CASE — less favourable windows require significantly more\n');

% Propellant at different ΔV values
fprintf('\n  PROBE propellant sensitivity to window ΔV:\n');
for dv_test = [4000 5000 6000 7000 8000 10000]
    mp = probe.m_final * (exp(dv_test/ve) - 1);
    fprintf('    %5d m/s → %6.0f kg prop (%.1f t wet)\n', dv_test, mp, (probe.m_final+mp)/1000);
end

% ── SKIP hopper (CORRECTED — ballistic hop physics) ──────────────────
fprintf('\n== SKIP HOPPER — CORRECTED ΔV FROM FIRST PRINCIPLES ==\n');
skip.m_dry      = 300;    % kg
skip.m_payload  = 350;    % kg  KREEP regolith per hop
skip.m_final    = skip.m_dry + skip.m_payload;

% Ballistic hop physics:
%   Range R = v0² sin(2θ) / g_moon    (optimal θ = 45°, sin(90°) = 1)
%   One-way ΔV = 2 × v0               (launch burn + landing burn)
%   Round-trip ΔV = 4 × v0            (outbound + return)
%   Gravity loss factor: ~5% for short hops (high T/W on Moon)

skip.theta_opt  = 45;     % deg (optimal launch angle)
skip.grav_loss  = 0.05;   % 5% gravity loss factor

% Calculate ΔV for various ranges
skip.ranges_km  = [14 20 50 75 100 150 200];  % km
fprintf('\n  Ballistic hop ΔV table (optimal 45° angle, %.0f%% gravity losses):\n', skip.grav_loss*100);
fprintf('  %8s  %8s  %10s  %10s  %10s\n', 'Range', 'v0', 'ΔV 1-way', 'ΔV R/T', 'Prop(kg)');
fprintf('  %s\n', repmat('-', 1, 52));

skip_data = zeros(length(skip.ranges_km), 4); % [range, v0, dv_rt, fuel]
for i = 1:length(skip.ranges_km)
    R = skip.ranges_km(i) * 1000;  % metres
    v0 = sqrt(R * g_moon);         % launch velocity at 45°
    dv_oneway = 2 * v0;            % launch + landing
    dv_rt = 4 * v0 * (1 + skip.grav_loss);  % round trip + losses
    fuel = skip.m_final * (exp(dv_rt / ve) - 1);
    skip_data(i,:) = [skip.ranges_km(i), v0, dv_rt, fuel];
    
    marker = '';
    if skip.ranges_km(i) == 14, marker = ' ← OLD 600 m/s range!'; end
    if skip.ranges_km(i) == 100, marker = ' ← NOMINAL DESIGN'; end
    fprintf('  %6d km  %6.0f m/s  %8.0f m/s  %8.0f m/s  %8.0f kg%s\n', ...
            skip.ranges_km(i), v0, dv_oneway, dv_rt, fuel, marker);
end

% Select nominal design range
skip.range_nom_km = 100;   % km nominal
skip.range_nom_m  = skip.range_nom_km * 1000;
skip.v0_nom       = sqrt(skip.range_nom_m * g_moon);
skip.dv_rt_nom    = 4 * skip.v0_nom * (1 + skip.grav_loss);
skip.fuel_hop_nom = skip.m_final * (exp(skip.dv_rt_nom / ve) - 1);

% OLD calculation for comparison
skip.dv_rt_old    = 600;   % m/s (INCORRECT — original doc value)
skip.fuel_hop_old = skip.m_final * (exp(skip.dv_rt_old / ve) - 1);
skip.range_old_km = (skip.dv_rt_old / (4*(1+skip.grav_loss)))^2 / g_moon / 1000;

fprintf('\n  ── CRITICAL CORRECTION ──\n');
fprintf('  OLD: 600 m/s round-trip → fuel %.1f kg → range only %.1f km\n', ...
        skip.fuel_hop_old, skip.range_old_km);
fprintf('  NEW: %.0f m/s round-trip (100 km) → fuel %.1f kg → %.1f× increase\n', ...
        skip.dv_rt_nom, skip.fuel_hop_nom, skip.fuel_hop_nom / skip.fuel_hop_old);

% Fleet economics
skip.hops_per_day = 1.0;
skip.avail        = 0.75;
skip.hops_yr      = skip.hops_per_day * 365 * skip.avail;
skip.fuel_yr_nom  = skip.hops_yr * skip.fuel_hop_nom;
skip.kreep_yr     = skip.hops_yr * skip.m_payload;
skip.fuel_yr_old  = skip.hops_yr * skip.fuel_hop_old;

fprintf('\n  Fleet economics (%.0f hops/yr at %.0f%% availability):\n', skip.hops_yr, skip.avail*100);
fprintf('    Fuel/yr per craft (100 km): %.1f t  (OLD: %.1f t)\n', ...
        skip.fuel_yr_nom/1000, skip.fuel_yr_old/1000);
fprintf('    KREEP/yr per craft:         %.1f t  (unchanged)\n', skip.kreep_yr/1000);
fprintf('    Material-to-propellant ratio: %.2f  (OLD: %.2f)\n', ...
        skip.m_payload / skip.fuel_hop_nom, skip.m_payload / skip.fuel_hop_old);

% Fleet sizes
for n_skip = [1 2 4 8]
    fprintf('    %d-craft fleet fuel/yr: %.1f t\n', n_skip, n_skip*skip.fuel_yr_nom/1000);
end

% ── DART orbital transfer vehicle ────────────────────────────────────
dart.m_dry       = 800;
dart.m_payload   = 1500;
dart.m_final     = dart.m_dry + dart.m_payload;
dart.dv_best     = 7400;   % m/s
dart.dv_worst    = 8900;   % m/s
dart.dv_planning = 8200;   % m/s
dart.fuel_plan   = dart.m_final * (exp(dart.dv_planning/ve) - 1);
dart.fuel_doc    = 12370;  % kg
dart.cadence_yr  = 0.5;    % biennial
dart.fuel_yr     = dart.fuel_doc * dart.cadence_yr;
dart.dv_implied  = ve * log((dart.m_final + dart.fuel_doc) / dart.m_final);

fprintf('\nDART orbital transfer (LLO method):\n');
fprintf('  Planning ΔV: %d m/s → fuel = %.1f t\n', dart.dv_planning, dart.fuel_plan/1000);
fprintf('  Doc: %d kg → implied ΔV = %.0f m/s ', dart.fuel_doc, dart.dv_implied);
if dart.dv_implied >= dart.dv_best && dart.dv_implied <= dart.dv_worst
    fprintf('[within range → PASS]\n');
else
    fprintf('[CHECK]\n');
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 3 — NEA DISTANCES AND TRANSIT TIMES
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 3: NEA DISTANCES AND TRANSIT TIMES ==\n');

nea.semi_major_au = 1.0;
a_transfer = (1.0 + nea.semi_major_au) / 2;
T_transfer_yr = a_transfer^1.5;
t_transit_yr = T_transfer_yr / 2;
t_transit_months = t_transit_yr * 12;
t_at_asteroid_months = 1;
t_roundtrip_months = 2 * t_transit_months + t_at_asteroid_months;

fprintf('  Hohmann estimate: %.1f months one-way, %.0f–%.0f months round-trip\n', ...
        t_transit_months, t_roundtrip_months - 1, t_roundtrip_months + 3);
fprintf('  Guide states 6–18 months transit — ');
if t_transit_months >= 3 && t_transit_months <= 9
    fprintf('consistent [PASS]\n');
else
    fprintf('[CHECK]\n');
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 4 — MOLE-I PROPELLANT YIELD (first principles)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 4: MOLE-I PROPELLANT YIELD ==\n');
fprintf('All water ISRU = MOLE-I exclusively (PSR Shackleton Crater)\n\n');

molei.drill_rate_hr  = 25;      % kg/hr (ESA PROSPECT heritage, conservative)
molei.availability   = 0.80;    % 80% operational availability
molei.psr_frac       = crater.ice_design;  % 4.5%
molei.electrolysis_eff = 0.722; % water-to-usable-propellant mass fraction

% First-principles derivation
molei.water_rate    = molei.drill_rate_hr * molei.psr_frac;  % kg water/hr
molei.water_yr      = molei.water_rate * molei.availability * 8760;
molei.prop_yield    = molei.water_yr * molei.electrolysis_eff;

fprintf('  Drill rate:     %d kg/hr regolith\n', molei.drill_rate_hr);
fprintf('  Ice fraction:   %.1f%%\n', molei.psr_frac*100);
fprintf('  Water rate:     %.3f kg/hr\n', molei.water_rate);
fprintf('  Availability:   %.0f%%\n', molei.availability*100);
fprintf('  Water/yr:       %.0f kg\n', molei.water_yr);
fprintf('  Electrolysis:   %.1f%% mass yield\n', molei.electrolysis_eff*100);
fprintf('  Propellant/yr:  %.0f kg per MOLE-I unit\n', molei.prop_yield);
fprintf('  (Doc v2.2 stated 5,645 kg/yr → delta: %.0f kg = %.1f%%)\n', ...
        abs(molei.prop_yield - 5645), abs(molei.prop_yield - 5645)/5645*100);

% Sensitivity table
fprintf('\n  Ice Fraction → MOLE-I Propellant Yield:\n');
for f = 0.03:0.01:0.10
    y = f * molei.drill_rate_hr * molei.availability * 8760 * molei.electrolysis_eff;
    marker = '';
    if abs(f - 0.056) < 0.001, marker = ' ← LCROSS (Cabeus)'; end
    if abs(f - 0.045) < 0.001, marker = ' ← design assumed'; end
    fprintf('    %.0f%%: %5.0f kg/yr%s\n', f*100, y, marker);
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 5 — MOLE-I FLEET SIZING FROM DEMAND (first principles)
%  This is the critical new section — derive MOLE-I counts from
%  what the programme NEEDS, not from arbitrary assignments.
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 5: MOLE-I FLEET SIZING FROM DEMAND ==\n');
fprintf('Sizing logic: MOLE-I count = ceil(total_demand / prop_yield_per_unit)\n');
fprintf('Plus margin (recommend 10%% minimum)\n\n');

% Life support oxygen (CORRECTED: NASA operational 0.9 kg/person/day)
ls.o2_rate_day  = 0.9;     % kg/person/day (ISS OGA operational, not 0.84 resting)
ls.o2_rate_yr   = ls.o2_rate_day * 365;  % 328.5 kg/person/year
ls.water_per_o2 = 1 / 0.889;   % kg water per kg O₂ (stoichiometric: H₂O → H₂ + ½O₂)
ls.prop_equiv_per_crew = ls.o2_rate_yr * ls.water_per_o2 * molei.electrolysis_eff;

fprintf('  Life support O₂: %.2f kg/person/day (ISS OGA operational rate)\n', ls.o2_rate_day);
fprintf('  Annual O₂: %.1f kg/person/year\n', ls.o2_rate_yr);
fprintf('  Propellant-equivalent per crew: %.0f kg/yr\n', ls.prop_equiv_per_crew);
fprintf('  (OLD rate was 0.84 kg/day → 306.6 kg/yr — 9%% too low)\n');

% Phase definitions
%  [nPROBE, nSKIP, nDART, crew]  ← fleet composition per phase
%  MOLE-I will be DERIVED, not assumed
phase_name = {'P3 Y4-7', 'P4 Y7-9', 'P5 Y9-12', 'P6 Y12-15', 'P7+ Y20+'};
phase_fleet = [
%  nProbe nSkip nDart crew
    3      0     0     0;    % P3: SKIP starts M70 (partial), PROBE Earth-fuelled
    6      1     0     4;    % P4
   10      2     1     4;    % P5
   15      4     1     6;    % P6
   30      8     0    12;    % P7+
];

% NOTE on P3: Probes are 100% Earth-fuelled in P3.
% SKIP-1 starts ~M70 = 14 of 36 P3 months. We'll handle partial year.
p3_skip_fraction = 14/36;  % fraction of P3 year SKIP operates

n_phases = size(phase_fleet, 1);

fprintf('\n  %-14s %6s %6s %5s %5s | %10s %8s %8s %8s %6s | %6s %7s %9s  Status\n', ...
    'Phase', 'Probe', 'SKIP', 'DART', 'Crew', 'Probe(t)', 'SKIP(t)', 'DART(t)', 'LS(t)', 'Tot(t)', ...
    'nMI', 'ISRU(t)', 'Margin(t)');
fprintf('  %s\n', repmat('─', 1, 120));

ph = struct();
ph.labels = phase_name;
ph.n_phases = n_phases;
ph.isru = zeros(n_phases, 1);
ph.demand = zeros(n_phases, 1);
ph.margin = zeros(n_phases, 1);
ph.molei_count = zeros(n_phases, 1);
ph.d_probe = zeros(n_phases, 1);
ph.d_skip = zeros(n_phases, 1);
ph.d_dart = zeros(n_phases, 1);
ph.d_ls = zeros(n_phases, 1);
ph.data = zeros(n_phases, 5); % [nMI, nProbe, nSkip, nDart, crew]

margin_factor = 1.10;  % 10% margin on top of demand

for i = 1:n_phases
    nP   = phase_fleet(i,1);
    nS   = phase_fleet(i,2);
    nD   = phase_fleet(i,3);
    crew = phase_fleet(i,4);
    
    % Demand calculation
    if i == 1  % P3: PROBE Earth-fuelled, SKIP partial year
        d_probe = 0;  % Earth-fuelled
        d_skip  = nS * skip.fuel_yr_nom * p3_skip_fraction;
    else
        d_probe = nP * probe.m_prop * probe.missions_yr;
        d_skip  = nS * skip.fuel_yr_nom;
    end
    d_dart = nD * dart.fuel_doc * dart.cadence_yr;
    d_ls   = crew * ls.prop_equiv_per_crew;
    demand = d_probe + d_skip + d_dart + d_ls;
    
    % Derive MOLE-I count from demand + margin
    n_molei_raw = demand * margin_factor / molei.prop_yield;
    n_molei = max(4, ceil(n_molei_raw));  % minimum 4 for redundancy
    
    % ISRU supply
    isru = n_molei * molei.prop_yield;
    margin_val = isru - demand;
    
    % Store
    ph.d_probe(i) = d_probe;
    ph.d_skip(i) = d_skip;
    ph.d_dart(i) = d_dart;
    ph.d_ls(i) = d_ls;
    ph.demand(i) = demand;
    ph.molei_count(i) = n_molei;
    ph.isru(i) = isru;
    ph.margin(i) = margin_val;
    ph.data(i,:) = [n_molei, nP, nS, nD, crew];
    
    % Status
    if margin_val >= 5000
        status = 'OK';
    elseif margin_val >= 0
        status = 'TIGHT';
    else
        status = 'DEFICIT';
    end
    
    fprintf('  %-14s %6d %6d %5d %5d | %10.1f %8.1f %8.1f %8.1f %6.1f | %6d %7.1f %+9.1f  %s\n', ...
        phase_name{i}, nP, nS, nD, crew, ...
        d_probe/1000, d_skip/1000, d_dart/1000, d_ls/1000, demand/1000, ...
        n_molei, isru/1000, margin_val/1000, status);
end

fprintf('\n  ── KEY FINDING ──\n');
fprintf('  P7+ requires %d MOLE-I (demand-driven + 10%% margin)\n', ph.molei_count(end));
fprintf('  OLD doc assumed 73 MOLE-I — ');
if ph.molei_count(end) > 73
    fprintf('INSUFFICIENT by %d units\n', ph.molei_count(end) - 73);
else
    fprintf('sufficient\n');
end
fprintf('  Primary driver: corrected SKIP ΔV increases fleet propellant %.1f×\n\n', ...
        skip.fuel_yr_nom / skip.fuel_yr_old);

% ── Trade study: reduce SKIP fleet or hop cadence ──
fprintf('  ── SKIP FLEET TRADE STUDY ──\n');
fprintf('  Options to manage P7+ propellant demand:\n\n');
fprintf('  %6s  %8s  %8s  %10s  %10s  %8s  %10s\n', ...
    'SKIPs', 'Hops/day', 'Fuel(t)', 'KREEP(t)', 'nMI(tot)', 'MI(SKIP)', 'Output(t)');
fprintf('  %s\n', repmat('-', 1, 72));

probe_demand_p7 = 30 * probe.m_prop;
dart_demand_p7 = 0;
ls_demand_p7 = 12 * ls.prop_equiv_per_crew;
base_demand = probe_demand_p7 + dart_demand_p7 + ls_demand_p7;

for nS = [2 4 6 8]
    for hpd = [0.5 1.0]
        hops = hpd * 365 * skip.avail;
        skip_fuel_yr = nS * hops * skip.fuel_hop_nom;
        skip_kreep_yr = nS * hops * skip.m_payload;
        total_demand = base_demand + skip_fuel_yr;
        n_mi_needed = ceil(total_demand * margin_factor / molei.prop_yield);
        n_mi_for_skip = ceil(skip_fuel_yr * margin_factor / molei.prop_yield);
        % REE output at 2-8× beneficiation (assume 5× midpoint) from ~50-200 ppm KREEP
        ree_conc_ppm = 100;   % conservative average KREEP REE
        benef_factor = 5;     % midpoint of 2-8× physical beneficiation
        output_t = skip_kreep_yr * ree_conc_ppm/1e6 * benef_factor / 1000;  % t/yr REE conc
        
        fprintf('  %6d  %8.1f  %8.1f  %8.1f  %10d  %8d  %10.3f\n', ...
            nS, hpd, skip_fuel_yr/1000, skip_kreep_yr/1000, n_mi_needed, n_mi_for_skip, output_t*1000);
    end
end

fprintf('\n  RECOMMENDATION: 4 SKIPs at 1 hop/day as baseline (manageable MOLE-I fleet).\n');
fprintf('  Scale to 8 SKIPs only after MOLE-I fleet and power can support it.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 6 — CRATER ACCESS INFRASTRUCTURE (corrected for 30° slope)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 6: CRATER ACCESS INFRASTRUCTURE ==\n');

% Descent winch
infra.descent_speed  = 0.5;    % m/s
infra.traverse_m     = crater.traverse_km * 1000;
infra.descent_time_s = infra.traverse_m / infra.descent_speed;
infra.descent_time_hr= infra.descent_time_s / 3600;

fprintf('  Descent winch:\n');
fprintf('    Traverse: %.0f m at %.1f m/s\n', infra.traverse_m, infra.descent_speed);
fprintf('    Descent time: %.1f hr (OLD: 2.25 hr at 4 km — INCORRECT)\n', infra.descent_time_hr);

% Transit battery (WEB-only for wall transit through ≤25 K zone)
infra.web_power_w    = 51;     % W (WEB heating during transit)
infra.batt_margin    = 1.10;   % 10% margin
infra.batt_wh        = infra.web_power_w * infra.descent_time_hr * infra.batt_margin;
infra.batt_mass_kg   = infra.batt_wh / 250;  % ~250 Wh/kg for space-grade Li-ion

fprintf('    Transit battery: %.0f W × %.1f hr × %.2f margin = %.0f Wh (%.1f kg)\n', ...
        infra.web_power_w, infra.descent_time_hr, infra.batt_margin, infra.batt_wh, infra.batt_mass_kg);
fprintf('    OLD: 52 Wh at 2.25 hr — undersized by %.1f×\n', infra.batt_wh / 52);

% Heated water pipeline
infra.pipe_heat_wm   = 7;     % W/m (cold wall sections dominate)
infra.pipe_length_m  = ceil(infra.traverse_m / 100) * 100;  % round to 100 m
infra.pipe_power_kw  = infra.pipe_heat_wm * infra.pipe_length_m / 1000;

fprintf('\n  Heated water pipeline:\n');
fprintf('    Length: %.0f m (= ~%.1f km traverse, rounded)\n', infra.pipe_length_m, infra.pipe_length_m/1000);
fprintf('    Heat trace: %d W/m × %d m = %.1f kW continuous\n', ...
        infra.pipe_heat_wm, infra.pipe_length_m, infra.pipe_power_kw);
fprintf('    OLD: 5 W/m × 4,039 m = 20.2 kW — UNDERSIZED by %.1f×\n', infra.pipe_power_kw / 20.2);

% Cable material
fprintf('\n  Descent cable material:\n');
fprintf('    Kevlar or Vectran ONLY (retain tensile strength to <40 K)\n');
fprintf('    Dyneema (UHMWPE) EXCLUDED — Tg ~193 K causes embrittlement\n');
fprintf('    (Prior docs incorrectly stated Dyneema embrittlement at "~40 K")\n');

% Copper cable specification
fprintf('\n  Power cable specification:\n');
fprintf('    Phase 1–3 rim operations: standard-purity copper acceptable\n');
fprintf('    Phase 4+ PSR cables: OFHC copper, RRR >100\n');
fprintf('    Resistivity at 90 K: 0.25–0.30 μΩ·cm (6–7× lower than 293 K)\n');
fprintf('    Insulation: PTFE or Kapton (rated to <4 K)\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 7 — COMMUNICATIONS (corrected delay)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 7: EARTH-MOON COMMUNICATIONS ==\n');

comms.delay_oneway  = d_moon / c_light;  % seconds
comms.delay_rt      = 2 * comms.delay_oneway;

fprintf('  Earth–Moon distance: %d km\n', d_moon);
fprintf('  One-way delay:  %.2f s\n', comms.delay_oneway);
fprintf('  Round-trip delay: %.2f s\n', comms.delay_rt);
fprintf('  OLD doc stated 1.28 s "round trip" — INCORRECT (that is one-way)\n');
fprintf('\n  EML-2 relay coverage:\n');
fprintf('    Single EML-2 satellite: ~45%% south pole coverage\n');
fprintf('    3 satellites needed for continuous, or hybrid with ELFO\n');
fprintf('    Ref: Queqiao demonstrated EML-2 relay 2018+\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 8 — LIFE SUPPORT & 90-DAY SUPPLY BUDGET
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 8: LIFE SUPPORT & 90-DAY SUPPLY BUDGET ==\n');

% NASA-STD-3001 metabolic requirements
ls.o2_kg_day    = 0.9;     % kg/person/day (ISS OGA operational)
ls.water_kg_day = 2.5;     % kg/person/day (drinking + food prep)
ls.food_kg_day  = 1.8;     % kg/person/day (dry + packaging)
ls.co2_kg_day   = 1.0;     % kg/person/day (metabolic output)
ls.n2_leakage   = 0.01;    % kg/person/day (nominal leakage replacement)

n_crew_initial = 4;
buffer_days = 90;  % project design requirement (not NASA standard)

fprintf('  Per-person daily requirements (NASA-STD-3001):\n');
fprintf('    O₂:    %.2f kg/day (ISS OGA operational — was 0.84 resting)\n', ls.o2_kg_day);
fprintf('    Water: %.1f kg/day\n', ls.water_kg_day);
fprintf('    Food:  %.1f kg/day (dry + packaging)\n', ls.food_kg_day);
fprintf('    N₂:    %.2f kg/day (leakage replacement)\n', ls.n2_leakage);

ls.total_per_person_day = ls.o2_kg_day + ls.water_kg_day + ls.food_kg_day + ls.n2_leakage;
ls.buffer_mass_per_person = ls.total_per_person_day * buffer_days;
ls.buffer_total_4crew = ls.buffer_mass_per_person * n_crew_initial;

fprintf('\n  90-day buffer for %d crew:\n', n_crew_initial);
fprintf('    Per person: %.1f kg/day × %d days = %.0f kg\n', ...
        ls.total_per_person_day, buffer_days, ls.buffer_mass_per_person);
fprintf('    Total (%d crew): %.0f kg = %.1f t\n', ...
        n_crew_initial, ls.buffer_total_4crew, ls.buffer_total_4crew/1000);

% Breakdown
fprintf('\n    Component breakdown (90 days, %d crew):\n', n_crew_initial);
fprintf('      O₂:    %.0f kg\n', ls.o2_kg_day * buffer_days * n_crew_initial);
fprintf('      Water: %.0f kg\n', ls.water_kg_day * buffer_days * n_crew_initial);
fprintf('      Food:  %.0f kg\n', ls.food_kg_day * buffer_days * n_crew_initial);
fprintf('      N₂:    %.0f kg\n', ls.n2_leakage * buffer_days * n_crew_initial);

fprintf('\n  Freight manifest impact:\n');
fprintf('    90-day buffer = %.1f t → must be included in cargo launches\n', ls.buffer_total_4crew/1000);
fprintf('    NOTE: Water is partially recyclable (ISS WRS recovers ~93%%);\n');
fprintf('    O₂ is produced by ISRU once operational.\n');
fprintf('    Food is fully consumable — no ISRU substitute.\n');
fprintf('    Pure food mass for 90 days: %.0f kg = %.1f t\n', ...
        ls.food_kg_day * buffer_days * n_crew_initial, ...
        ls.food_kg_day * buffer_days * n_crew_initial / 1000);


%% ════════════════════════════════════════════════════════════════════
%  SECTION 9 — DART STOCKPILE ACCUMULATION
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 9: DART STOCKPILE ACCUMULATION ==\n');

p5_idx = 3;  % P5 index in our phase array
p5_surplus = ph.margin(p5_idx);  % kg/yr surplus after all demand

dart_target_prop = 9000;
if p5_surplus > 0
    stockpile_months = dart_target_prop / (p5_surplus / 12);
else
    stockpile_months = Inf;
end

fprintf('  P5 ISRU surplus: %.0f kg/yr\n', p5_surplus);
fprintf('  DART first mission needs: %d kg propellant\n', dart_target_prop);
fprintf('  Stockpile time: %.0f months (%.1f years)\n', stockpile_months, stockpile_months/12);
if p5_surplus <= 0
    fprintf('  ⚠ P5 surplus is ZERO or NEGATIVE — DART cannot accumulate!\n');
    fprintf('  DART first mission must wait until MOLE-I fleet grows.\n');
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 10 — DOCKING COLLAR THROUGHPUT
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 10: DOCKING COLLAR THROUGHPUT ==\n');

turnaround_hr = 60;
collar_util   = 0.70;
collar_cap_yr = 365*24 / turnaround_hr * collar_util;

fprintf('  Per-collar capacity: %.0f missions/yr (%.0fh turnaround, %.0f%% util)\n\n', ...
        collar_cap_yr, turnaround_hr, collar_util*100);

dock_data = [2,3; 4,6; 6,10; 8,15; 8,30];
ph_dock = {'P3','P4','P5','P6','P7+'};
for i = 1:5
    cap  = dock_data(i,1) * collar_cap_yr;
    util = dock_data(i,2) / cap * 100;
    fprintf('  %-6s %d collars → cap %.0f mis/yr, %d PROBEs → %.1f%% util\n', ...
            ph_dock{i}, dock_data(i,1), cap, dock_data(i,2), util);
end


%% ════════════════════════════════════════════════════════════════════
%  SECTION 11 — BENEFICIATION REALITY CHECK
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 11: BENEFICIATION REALITY CHECK ==\n');

benef.method = 'Physical only (gravity + magnetic)';
benef.factor_range = [2 8];    % × concentration (REVISED from 10-50×)
benef.factor_design = 5;       % midpoint

% KREEP REE concentrations
benef.kreep_ree_ppm_low  = 50;    % ppm (SPA Basin surface)
benef.kreep_ree_ppm_high = 200;   % ppm (PKT KREEP-bearing regolith)
benef.kreep_ree_ppm_design = 100; % ppm (conservative average)

fprintf('  Method: %s\n', benef.method);
fprintf('  Concentration factor: %d–%d× (REVISED from 10–50×)\n', benef.factor_range(1), benef.factor_range(2));
fprintf('  Design factor: %d× (midpoint)\n', benef.factor_design);
fprintf('\n  WHY REVISED: REE minerals (merrillite, apatite) SG 3.1–3.2\n');
fprintf('    Host silicates (pyroxene) SG 3.2–3.5 → gravity separation ineffective\n');
fprintf('    Magnetic drums concentrate mafics, not REE carriers\n');
fprintf('    Terrestrial physical-only REE beneficiation: 2–8× (literature)\n');

% Output calculation
fprintf('\n  KREEP REE concentrate output:\n');
for nS = [1 2 4 8]
    kreep_raw = nS * skip.kreep_yr;   % kg/yr raw KREEP
    for bf = [2 5 8]
        conc_ppm = benef.kreep_ree_ppm_design * bf;  % concentrated ppm
        conc_fraction = conc_ppm / 1e6;
        % Mass of concentrate depends on feed mass and concentration ratio
        % If feed has 100 ppm and we concentrate 5×, output is 500 ppm
        % Mass of concentrate = feed_mass / bf (volume reduction)
        conc_mass = kreep_raw / bf;     % kg concentrate
        ree_in_conc = conc_mass * conc_fraction;   % kg pure REE
        % Actually: concentrate mass = raw × (input_grade / output_grade)
        % = raw / concentration_factor
        fprintf('    %dS × %d×: %.0f t raw → %.0f t concentrate @ %d ppm → %.1f kg REE\n', ...
                nS, bf, kreep_raw/1000, conc_mass/1000, conc_ppm, ree_in_conc);
    end
end

fprintf('\n  Earth comparison:\n');
fprintf('    Mountain Pass: 80,000–90,000 ppm  | Mount Weld: 52,000–83,000 ppm\n');
fprintf('    Ion-adsorption clays: 200–2,000 ppm (but easy extraction)\n');
fprintf('    KREEP concentrate at 5×: 500 ppm — below ion-adsorption clay grade\n');
fprintf('    CONCLUSION: KREEP REE is a supplementary revenue stream, not primary.\n');
fprintf('    PGMs from PROBE asteroid mining remain the dominant value proposition.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 12 — CRYOGENIC LIQUEFACTION POWER (LH₂ vs LOX)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 12: CRYOGENIC LIQUEFACTION POWER ==\n');

cryo.lh2_boil_K    = 20;    % K
cryo.lox_boil_K    = 90;    % K
cryo.lh2_ratio     = 100;   % electrical-to-thermal at 20 K (Carnot + inefficiency)
cryo.lox_ratio     = 15;    % electrical-to-thermal at 90 K
cryo.lh2_rate_kg_hr = 0.3;  % kg/hr achievable with ~35 kW electrical
cryo.lox_rate_kg_hr = 2.0;  % kg/hr achievable with ~5 kW electrical

fprintf('  LH₂ (20 K): electrical/thermal ratio ~%d:1\n', cryo.lh2_ratio);
fprintf('    ~35 kW electrical → ~%.1f kg/hr LH₂\n', cryo.lh2_rate_kg_hr);
fprintf('    NASA 20 K cryocoolers: TRL 4–5 for flight systems\n');
fprintf('  LOX (90 K): electrical/thermal ratio ~%d:1\n', cryo.lox_ratio);
fprintf('    ~5 kW electrical → ~%.1f kg/hr LOX\n', cryo.lox_rate_kg_hr);
fprintf('    150 W-class 90 K cryocoolers: higher TRL\n');
fprintf('\n  CONCLUSION: Oxygen-first ISRU staging is essential.\n');
fprintf('  LH₂ production scales only after power infrastructure established.\n');
fprintf('  This is a potential showstopper for early-phase ISRU if power is constrained.\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 13 — LAUNCH VEHICLE ASSUMPTIONS
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 13: LAUNCH VEHICLE ASSUMPTIONS ==\n');

fprintf('  SpaceX Starship:\n');
fprintf('    Claimed: ~100 t to lunar surface (requires 10–15 tanker flights)\n');
fprintf('    Status (early 2026): multiple test flights, NO lunar delivery\n');
fprintf('    Orbital refueling: UNDEMONSTRATED at scale\n');
fprintf('    Cost projections: $100/kg (aspirational) to $5,000/kg (analyst)\n');
fprintf('    Current CLPS: $500,000–$1,200,000/kg demonstrated\n');
fprintf('    Programme timeline does NOT start until capabilities are proven.\n');
fprintf('\n  NOTE: All mass budgets must be achievable within demonstrated\n');
fprintf('  or near-term vehicle capabilities. Economic modelling should\n');
fprintf('  bracket cost across 3 orders of magnitude ($100–$100,000/kg).\n');


%% ════════════════════════════════════════════════════════════════════
%  SECTION 14 — FULL SYSTEM POWER BUDGET (P7+ corrected)
% ════════════════════════════════════════════════════════════════════

fprintf('\n== SECTION 14: POWER BUDGET — P7+ FULL SCALE ==\n');

n_molei_p7 = ph.molei_count(end);
n_moles    = 6;
n_arm      = 8;
n_sinter   = 3;
n_survey   = 2;
n_sentinel = 4;
n_skip_p7  = phase_fleet(end, 2);  % from fleet composition
n_dart_p7  = phase_fleet(end, 3);
n_crew_p7  = phase_fleet(end, 4);

fprintf('  Fleet: %d MOLE-I, %d MOLE-S, %d ARM, %d SINTER, %d SURVEY, %d SKIP, %d SENTINEL, %d crew\n', ...
        n_molei_p7, n_moles, n_arm, n_sinter, n_survey, n_skip_p7, n_sentinel, n_crew_p7);

% Robot power draw (kW per unit)
pw.molei_exc    = 0.800;
pw.molei_web    = 0.035;   % ALWAYS ON
pw.molei_avail  = 0.80;
pw.moles_exc    = 0.800;
pw.moles_avail  = 0.80;
pw.arm_ops      = 3.000;
pw.arm_avail    = 0.40;
pw.sinter_ops   = 5.000;
pw.sinter_avail = 0.70;
pw.survey_ops   = 0.300;
pw.survey_avail = 0.60;
pw.sentinel_ops = 0.150;
pw.sentinel_avail = 0.90;
pw.skip_base    = 0.100;
pw.dart_base    = 0.150;

% ISRU plant (scaled for corrected demand)
pw.electrolyzer  = 35.0;   % kW average (INCREASED — must support corrected demand)
pw.cryocooling   = 12.0;   % kW average (INCREASED — LH₂ power asymmetry)
pw.vex_batch     = 15.0;   % kW (scaled up for more MOLE-I)

% Base systems
pw.habitat       = 20.0;
pw.life_support  = 15.0;
pw.crew_personal = 2.0;
pw.comms         = 3.0;
pw.computing     = 2.0;
pw.benef_module  = 16.0;
pw.charging_infra= 8.0;    % kW (scaled up for larger MOLE-I fleet)

% Pipeline heating (CORRECTED)
pw.pipeline      = infra.pipe_power_kw;  % ~58.1 kW

% Calculate totals
pwr = struct();
pwr.molei_exc    = n_molei_p7 * pw.molei_exc * pw.molei_avail;
pwr.molei_web    = n_molei_p7 * pw.molei_web;
pwr.moles        = n_moles * pw.moles_exc * pw.moles_avail;
pwr.arm          = n_arm * pw.arm_ops * pw.arm_avail;
pwr.sinter       = n_sinter * pw.sinter_ops * pw.sinter_avail;
pwr.survey       = n_survey * pw.survey_ops * pw.survey_avail;
pwr.sentinel     = n_sentinel * pw.sentinel_ops * pw.sentinel_avail;
pwr.skip_base    = n_skip_p7 * pw.skip_base;
pwr.dart_base    = n_dart_p7 * pw.dart_base;
pwr.isru_elec    = pw.electrolyzer;
pwr.isru_cryo    = pw.cryocooling;
pwr.vex          = pw.vex_batch;
pwr.pipeline     = pw.pipeline;
pwr.habitat      = pw.habitat;
pwr.life_support = pw.life_support;
pwr.crew_pers    = n_crew_p7 * pw.crew_personal;
pwr.comms        = pw.comms;
pwr.computing    = pw.computing;
pwr.benef        = pw.benef_module;
pwr.charging     = pw.charging_infra;

fields = fieldnames(pwr);
total_kw = 0;
fprintf('\n  %-22s %8s\n', 'Consumer', 'Power(kW)');
fprintf('  %s\n', repmat('─', 1, 32));
for i = 1:length(fields)
    v = pwr.(fields{i});
    total_kw = total_kw + v;
    fprintf('  %-22s %8.1f\n', fields{i}, v);
end
fprintf('  %s\n', repmat('─', 1, 32));
fprintf('  %-22s %8.1f kW\n', 'TOTAL CONTINUOUS', total_kw);

% Solar sizing (CORRECTED illumination fraction)
panel_eff       = 0.29;
solar_capacity  = total_kw / (crater.sun_pct_design * panel_eff);
solar_area_m2   = solar_capacity / 0.15;  % ~150 W/m² effective at 1 AU

fprintf('\n  Solar array sizing (%.0f%% sun design value, %.0f%% panel efficiency):\n', ...
        crater.sun_pct_design*100, panel_eff*100);
fprintf('    Required capacity:  %.0f kW\n', solar_capacity);
fprintf('    Estimated area:     %.0f m² (~%.1f football fields)\n', ...
        solar_area_m2, solar_area_m2 / 7140);
fprintf('    OLD estimate used 89%% sun → now %.0f%% → %.1f%% more panels needed\n', ...
        crater.sun_pct_design*100, (0.89/crater.sun_pct_design - 1)*100);


%% ════════════════════════════════════════════════════════════════════
%  SECTION 15 — PLOTS
% ════════════════════════════════════════════════════════════════════

x_ph = 1:ph.n_phases;

% ── Plot 1: Propellant balance by phase ──
figure('Name','Fig 1 — Propellant Balance by Phase (CORRECTED)', ...
       'Position',[50 50 920 520]);
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
legend({'ISRU Supply (MOLE-I)', 'Fleet Demand (corrected ΔV)', 'Margin'}, ...
       'Location', 'northwest');
title(sprintf('Propellant Balance (MOLE-I @ %.0f kg/yr, SKIP @ %d km nominal)', ...
              molei.prop_yield, skip.range_nom_km));
grid on; set(gca, 'FontSize', 11);

% Annotate MOLE-I counts
for i = 1:ph.n_phases
    text(i, ph.isru(i)/1000 + 15, sprintf('%d MI', ph.molei_count(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end

% ── Plot 2: SKIP ΔV vs Range ──
figure('Name','Fig 2 — SKIP Ballistic Hop: ΔV vs Range', ...
       'Position',[50 620 700 420]);
ranges_plot = 5:1:250;
v0_plot = sqrt(ranges_plot * 1000 * g_moon);
dv_rt_plot = 4 * v0_plot * (1 + skip.grav_loss);
fuel_plot = skip.m_final * (exp(dv_rt_plot / ve) - 1);

yyaxis left;
plot(ranges_plot, dv_rt_plot, 'b-', 'LineWidth', 2.5);
ylabel('Round-trip ΔV (m/s)');
hold on;
yline(600, 'r--', 'LineWidth', 1.5);
text(200, 650, 'OLD: 600 m/s', 'Color', 'r', 'FontSize', 10);

yyaxis right;
plot(ranges_plot, fuel_plot, 'Color', [0.85 0.32 0.24], 'LineWidth', 2);
ylabel('Propellant per hop (kg)');

xline(100, 'g--', 'LineWidth', 1.5);
text(105, 200, 'Nominal 100 km', 'Color', [0 0.5 0], 'FontSize', 10);
xline(14, 'm--', 'LineWidth', 1);
text(18, 100, '14 km (old range)', 'Color', 'm', 'FontSize', 9);

xlabel('Hop Range (km)');
title('SKIP Sub-orbital Hop: ΔV and Propellant vs Range');
grid on; set(gca, 'FontSize', 11);
xlim([0 250]);

% ── Plot 3: MOLE-I yield sensitivity ──
figure('Name','Fig 3 — MOLE-I Yield Sensitivity', ...
       'Position',[780 50 700 420]);
fracs_plot = 0.02:0.001:0.12;
yields_plot = fracs_plot * molei.drill_rate_hr * molei.availability * 8760 * molei.electrolysis_eff;
plot(fracs_plot*100, yields_plot/1000, 'b-', 'LineWidth', 2.5); hold on;
yline(molei.prop_yield/1000, 'r--', 'LineWidth', 1.5);
text(2.5, molei.prop_yield/1000 + 0.1, sprintf('Design: %.2f t/yr', molei.prop_yield/1000), ...
     'Color', 'r', 'FontSize', 10);
xline(5.6, 'g--', 'LineWidth', 1.5);
text(5.8, 1, 'LCROSS 5.6%', 'Color', [0 0.5 0], 'FontSize', 10);
xline(4.5, 'm--', 'LineWidth', 1.5);
text(2.5, 0.5, 'Design 4.5%', 'Color', 'm', 'FontSize', 10);
xlabel('PSR Regolith Water Content (%)');
ylabel('Propellant Yield (t/yr per MOLE-I)');
title('MOLE-I Yield Sensitivity to Ice Fraction');
xlim([2 12]); grid on; set(gca, 'FontSize', 11);

% ── Plot 4: PROBE ΔV trade ──
figure('Name','Fig 4 — PROBE Propellant vs Mission ΔV', ...
       'Position',[780 520 700 420]);
dv_range = 3000:100:12000;
fuel_range = probe.m_final * (exp(dv_range/ve) - 1);
plot(dv_range/1000, fuel_range/1000, 'b-', 'LineWidth', 2.5); hold on;
xline(6, 'r--', 'LineWidth', 1.5);
text(6.1, 5, 'Best-case 6 km/s', 'Color', 'r', 'FontSize', 10);
xline(8, 'Color', [0.8 0.5 0], 'LineStyle', '--', 'LineWidth', 1.5);
text(8.1, 15, 'Mid-range 8 km/s', 'Color', [0.8 0.5 0], 'FontSize', 10);
yline(probe.m_prop/1000, 'g--', 'LineWidth', 1.5);
text(3.2, probe.m_prop/1000 + 0.5, sprintf('Design: %.1f t', probe.m_prop/1000), ...
     'Color', [0 0.5 0], 'FontSize', 10);
xlabel('Round-trip ΔV (km/s)');
ylabel('Propellant Required (t)');
title(sprintf('PROBE Propellant vs ΔV (Isp=%ds, m_{final}=%dkg)', Isp, probe.m_final));
xlim([3 12]); ylim([0 60]); grid on; set(gca, 'FontSize', 11);

% ── Plot 5: Power budget breakdown ──
figure('Name','Fig 5 — P7+ Power Budget (CORRECTED)', ...
       'Position',[50 1100 800 500]);
pw_labels = {
    sprintf('MOLE-I excavation (%d)', n_molei_p7), ...
    sprintf('MOLE-I WEB heat (%d)', n_molei_p7), ...
    'MOLE-S (6)', 'ARM (8)', 'SINTER (3)', 'SURVEY+SENTINEL', ...
    'SKIP+DART (docked)', 'ISRU electrolysis', 'ISRU cryo+VEX', ...
    'Pipeline heating', 'Habitat', 'Life support', ...
    sprintf('Crew (%d)', n_crew_p7), 'Comms+Computing', 'Beneficiation', 'Charging'
};
pw_vals = [pwr.molei_exc, pwr.molei_web, pwr.moles, pwr.arm, ...
           pwr.sinter, pwr.survey+pwr.sentinel, pwr.skip_base+pwr.dart_base, ...
           pwr.isru_elec, pwr.isru_cryo+pwr.vex, pwr.pipeline, ...
           pwr.habitat, pwr.life_support, pwr.crew_pers, ...
           pwr.comms+pwr.computing, pwr.benef, pwr.charging];
pie(pw_vals);
legend(pw_labels, 'Location', 'eastoutside', 'FontSize', 8);
title(sprintf('P7+ Power: %.0f kW continuous → %.0f kW solar capacity (%.0f%% sun)', ...
              total_kw, solar_capacity, crater.sun_pct_design*100));

% ── Plot 6: Demand composition stacked by phase ──
figure('Name','Fig 6 — Demand Composition by Phase', ...
       'Position',[900 1100 700 450]);
demand_stack = [ph.d_probe, ph.d_skip, ph.d_dart, ph.d_ls] / 1000;
b6 = bar(x_ph, demand_stack, 'stacked');
b6(1).FaceColor = [0.18 0.42 0.72];
b6(2).FaceColor = [0.85 0.32 0.24];
b6(3).FaceColor = [0.72 0.52 0.18];
b6(4).FaceColor = [0.30 0.65 0.30];
hold on;
plot(x_ph, ph.isru/1000, 'k-s', 'LineWidth', 2.5, 'MarkerFaceColor', 'k', 'MarkerSize', 8);
ylabel('Propellant (t/yr)');
xlabel('Programme Phase');
xticks(x_ph); xticklabels(ph.labels);
legend({'PROBE', 'SKIP (corrected ΔV)', 'DART', 'Life Support', 'ISRU Supply'}, ...
       'Location', 'northwest');
title('Demand Composition vs ISRU Supply by Phase');
grid on; set(gca, 'FontSize', 11);


%% ════════════════════════════════════════════════════════════════════
%  SUMMARY
% ════════════════════════════════════════════════════════════════════

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('  SUMMARY OF CRITICAL CORRECTIONS\n');
fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('  1. Crater wall slope: 22° → 30° (traverse 4→%.1f km)\n', crater.traverse_km);
fprintf('  2. SKIP round-trip ΔV: 600 → %.0f m/s at %d km range\n', skip.dv_rt_nom, skip.range_nom_km);
fprintf('     Fuel per hop: %.0f → %.0f kg (%.1f× increase)\n', ...
        skip.fuel_hop_old, skip.fuel_hop_nom, skip.fuel_hop_nom/skip.fuel_hop_old);
fprintf('  3. P7+ MOLE-I: 73 → %d units (demand-driven)\n', ph.molei_count(end));
fprintf('  4. Pipeline heating: 20.2 → %.1f kW\n', infra.pipe_power_kw);
fprintf('  5. Transit battery: 52 → %.0f Wh\n', infra.batt_wh);
fprintf('  6. Solar illumination: 89%% → %.0f%% design\n', crater.sun_pct_design*100);
fprintf('  7. Comms delay: 1.28 s one-way, %.2f s round-trip\n', comms.delay_rt);
fprintf('  8. O₂ rate: 0.84 → %.2f kg/person/day\n', ls.o2_rate_day);
fprintf('  9. Ice strength: 7 → %d–%d MPa (icy permafrost)\n', ice.regolith_low, ice.regolith_high);
fprintf(' 10. Beneficiation: 10–50× → %d–%d× (physical-only limit)\n', benef.factor_range(1), benef.factor_range(2));
fprintf(' 11. Solar capacity needed: %.0f kW (was ~1,000 kW)\n', solar_capacity);
fprintf(' 12. 90-day supply buffer: %.1f t for %d crew\n', ls.buffer_total_4crew/1000, n_crew_initial);
fprintf('═══════════════════════════════════════════════════════════\n');
fprintf('  Run complete. Review Figures 1–6 and phase balance table.\n');
fprintf('  Use these figures to update Guide v14, Fleet v2.6,\n');
fprintf('  Strategy v1.2, and Timeline v8 for cross-consistency.\n');
fprintf('═══════════════════════════════════════════════════════════\n');