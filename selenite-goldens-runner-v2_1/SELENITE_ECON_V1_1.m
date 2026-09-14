%% SELENITE_ECON v1.1 — Programme-Wide Economic Evaluation
%  100-year cost-benefit analysis with ECN-019 Rev B corrections
%  
%  CHANGES FROM v1.0:
%    - MOLE-I demand-driven (max ~355, was 390,790)
%    - Mass driver at P8 (was P10)
%    - No SKIPs at PKT — haulers from P8
%    - Conveyors replace 9,084 EM catapults
%    - Na-S batteries, SRM motors, ~1,450 kg hauler
%    - D2EHPA eliminated, split value chain
%    - Thorium MSR for PKT power
%    - In-situ fraction ~57% (was 92%)
%    - Canister recovery options as sensitivity
%    - Year-by-year Earth cargo from build-out manifest
%
%  Reference: ECN-019 Rev B, SEL-DECISION-001 Rev B, 
%             Economic Parameters Research Report (April 2026)
%  Author: Jason Stewart — Systems Engineering Lead
%  Date: April 2026

clear; close all; clc;
fprintf('SELENITE_ECON v1.1 — Programme Economic Evaluation\n');
fprintf('ECN-019 Rev B Applied | %s\n\n', datestr(now));

%% ═══════════════════════════════════════════════════════════════
%  1. GLOBAL PARAMETERS
%  ═══════════════════════════════════════════════════════════════

Y = (0:100)';          % Year vector (Y0 = programme start)
N = length(Y);

% --- Launch cost to lunar surface ($/kg) ---
% Conservative-to-moderate Starship estimates
% Ref: Handmer 2021, Citi GPS 2022, PayloadSpace 2024
launch_cost = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y < 25         % P0-P7
        launch_cost(i) = 6000;
    elseif y < 45      % P8-P9
        launch_cost(i) = 4000;
    else               % P10+
        launch_cost(i) = 2000;
    end
end

% --- Discount rate (declining, Arrow et al. 2014) ---
% Ref: Arrow, Cropper, Gollier et al. (2014) REE&P 8(2):145-163
discount_rate = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y <= 30
        discount_rate(i) = 0.030;
    elseif y <= 75
        discount_rate(i) = 0.025;
    else
        discount_rate(i) = 0.020;
    end
end

% Cumulative discount factor
discount_factor = ones(N,1);
for i = 2:N
    discount_factor(i) = discount_factor(i-1) / (1 + discount_rate(i));
end

% --- Contingency multiplier ---
contingency = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y < 25          % P0-P7
        contingency(i) = 1.50;
    elseif y < 45      % P8-P9
        contingency(i) = 1.35;
    else               % P10+
        contingency(i) = 1.25;
    end
end

% --- In-situ fabrication cost ($/kg) ---
% Ref: Guerrero-Gonzalez & Zabel (2023), CisLunar Industries
insitu_cost_per_kg = 100;  % Midpoint of $50-200 range

%% ═══════════════════════════════════════════════════════════════
%  2. EARTH CARGO MANIFEST (Year-by-Year)
%  ═══════════════════════════════════════════════════════════════
%  From Decision Framework v2 §4 + P8 PKT construction manifest
%  All masses in tonnes

earth_cargo = zeros(N,1);  % tonnes/yr to lunar surface

for i = 1:N
    y = Y(i);
    if y < 7           % P0-P3: initial deployment
        earth_cargo(i) = 18;
    elseif y < 9       % P4: crew arrival
        earth_cargo(i) = 23;
    elseif y < 12      % P5: fleet expansion
        earth_cargo(i) = 49;
    elseif y < 15      % P6: processing commissioning
        earth_cargo(i) = 64;
    elseif y < 22      % P7 early: research ops
        earth_cargo(i) = 25;
    elseif y < 25      % P7 late: mass driver YBCO delivery
        earth_cargo(i) = 45;   % ~25 baseline + ~20 for YBCO/mass driver
    elseif y < 26      % P8 Wave 1: pioneer
        earth_cargo(i) = 200;  % 2 Starships to PKT
    elseif y < 28      % P8 Wave 2: processing
        earth_cargo(i) = 2900; % 100 circuits + haulers + FSP
    elseif y < 30      % P8 Wave 3: commissioning
        earth_cargo(i) = 4100; % crew hab + MSR + foundry + 200 circuits
    elseif y < 35      % P8 Wave 4: scale-up
        earth_cargo(i) = 2600; % remaining circuits + hauler expansion
    elseif y < 40      % P9 early: mass driver + foundry ramp
        earth_cargo(i) = 18000; % circuits + hauler Earth fraction + foundry
    elseif y < 45      % P9 late: conveyor + MSR expansion
        earth_cargo(i) = 12000;
    elseif y < 52      % P10 early: full-scale build-out
        earth_cargo(i) = 30000;
    elseif y < 60      % P10 late: in-situ fraction growing
        earth_cargo(i) = 20000;
    elseif y < 70      % P11 early
        earth_cargo(i) = 15000;
    elseif y < 80      % P11 late: Ni-201 replacing Hastelloy-N
        earth_cargo(i) = 10000;
    else               % P12: steady-state maintenance
        earth_cargo(i) = 33000; % hauler spares + canisters + circuits + MSR
    end
end

%% ═══════════════════════════════════════════════════════════════
%  3. IN-SITU MANUFACTURED MASS (Year-by-Year)
%  ═══════════════════════════════════════════════════════════════
%  Haulers, conveyors, canisters — in-situ fraction grows over time
%  Only relevant from P8+ (foundry pilot) onward

insitu_mass = zeros(N,1);  % tonnes/yr manufactured on Moon

for i = 1:N
    y = Y(i);
    if y < 30          % Pre-foundry
        insitu_mass(i) = 0;
    elseif y < 35      % P8 late: foundry pilot, first haulers
        insitu_mass(i) = 50;    % ~50 t/yr pilot
    elseif y < 45      % P9: foundry ramp, first conveyors
        insitu_mass(i) = 500;   % haulers + canisters
    elseif y < 52      % P10 early
        insitu_mass(i) = 5000;
    elseif y < 60      % P10 late
        insitu_mass(i) = 15000;
    elseif y < 70      % P11 early
        insitu_mass(i) = 50000;
    elseif y < 80      % P11 late
        insitu_mass(i) = 100000;
    else               % P12: ~150k haulers/yr + canisters + conveyor
        insitu_mass(i) = 250000;
    end
end

%% ═══════════════════════════════════════════════════════════════
%  4. REO PRODUCTION RAMP
%  ═══════════════════════════════════════════════════════════════
%  From Decision Framework: 0.4 (P7) → 125 (P8) → 1,000 (P9)
%  → 10,000 (P10) → 100,000 (P11) → 1,000,000 (P12)
%  Log-linear interpolation within phases

reo_production = zeros(N,1);  % tonnes REO/yr

% Phase boundaries and targets
phase_years   = [0  15  18  25   28    35     45      60       80      100];
phase_reo     = [0   0  0   0.4  125   125    1000    10000    100000  1000000];

for i = 1:N
    y = Y(i);
    if y <= 18
        reo_production(i) = 0;
    else
        % Find bracketing phase points
        idx = find(phase_years <= y, 1, 'last');
        if idx >= length(phase_years)
            reo_production(i) = phase_reo(end);
        else
            y0 = phase_years(idx);
            y1 = phase_years(idx+1);
            r0 = max(phase_reo(idx), 0.1);  % avoid log(0)
            r1 = phase_reo(idx+1);
            if r1 <= 0 || r0 <= 0
                reo_production(i) = 0;
            else
                % Log-linear interpolation
                frac = (y - y0) / (y1 - y0);
                reo_production(i) = exp(log(r0) + frac * (log(r1) - log(r0)));
            end
        end
    end
end

%% ═══════════════════════════════════════════════════════════════
%  5. REVENUE & ENVIRONMENTAL MODEL
%  ═══════════════════════════════════════════════════════════════

% --- REE market ---
% Ref: USGS MCS 2025, Adamas Intelligence Q4 2025
reo_basket_2026    = 15000;    % $/t mixed REO (2025-26 elevated prices)
reo_price_floor    = 5000;     % $/t at full saturation
reo_demand_2026    = 400000;   % t/yr current global demand
reo_demand_growth  = 0.02;     % 2% CAGR (conservative, IEA NZE)

% --- Environmental externality 1: REO displacement ---
% Ref: Lee & Wen (2018) EEIO + EPA SCC $190/tCO2
% $63,000-83,000/t (EEIO) + ~$5,700/t (carbon) = ~$73,700/t composite
externality_reo_per_t = 73700;   % $/t REO displaced

% --- Environmental externality 2: H2 enabling via iridium ---
% Ref: IEA NZE 2050, EPA SCC Nov 2023
% Each tonne Ir → ~1 GW PEM electrolyser capacity (at ~1 g Ir/kW)
% Each GW PEM → ~150,000 t H2/yr (at ~80% capacity factor)
% Each tonne green H2 displacing grey H2 avoids ~9 t CO2
% (grey H2 from SMR: ~9-12 t CO2/t H2; green H2: ~0)
scc = 190;                     % $/t CO2 (EPA Nov 2023, 2% discount)
ir_fraction_of_pgm = 0.15;    % ~15% of PGM mix is Ir
pem_gw_per_t_ir    = 1.0;     % GW PEM per tonne Ir (at ~1 g/kW)
h2_per_gw_yr       = 150000;  % t H2/yr per GW PEM (80% CF)
co2_avoided_per_h2 = 9;       % t CO2 avoided per t green H2
pem_lifetime_yr    = 20;      % PEM stack replacement cycle

% --- Environmental externality 3: Rocket emissions (NEGATIVE) ---
% Starship CH4/LOX: ~1,000 t CH4 per full stack launch
% CH4 → CO2: 1,000 × (44/16) = 2,750 t CO2 per launch
% Each cargo delivery needs ~13 tanker flights + 1 cargo = ~14 launches
co2_per_launch     = 2750;     % t CO2 per Starship launch
tanker_ratio       = 14;       % total launches per cargo delivery

% --- PGM revenue ---
% PROBE fleet: 5 t/yr PGM at P12, avg $50,000/kg
pgm_price_per_kg   = 50000;
pgm_production = zeros(N,1);  % t/yr
for i = 1:N
    y = Y(i);
    if y < 9           % Pre-PROBE
        pgm_production(i) = 0;
    elseif y < 25      % P5-P7: 30 PROBEs
        pgm_production(i) = 0.5;
    elseif y < 35      % P8: 96 PROBEs
        pgm_production(i) = 1.5;
    elseif y < 45      % P9: ~190 PROBEs
        pgm_production(i) = 3.0;
    elseif y < 60      % P10: ~230 PROBEs
        pgm_production(i) = 3.5;
    elseif y < 80      % P11: ~260 PROBEs
        pgm_production(i) = 4.0;
    else               % P12: 286 PROBEs
        pgm_production(i) = 5.0;
    end
end

% --- Calculate Ir production and cumulative PEM installed base ---
ir_production = pgm_production * ir_fraction_of_pgm;  % t Ir/yr

% Cumulative PEM capacity (GW) — each year's Ir creates permanent capacity
% PEM stacks last ~20 years, then need Ir replacement
% Model as: installed_base grows with production, decays with stack life
pem_installed = zeros(N,1);  % GW installed
for i = 1:N
    if i > 1
        % Add this year's new capacity, subtract 20-year-old capacity
        pem_installed(i) = pem_installed(i-1) + ir_production(i) * pem_gw_per_t_ir;
        if i > pem_lifetime_yr
            pem_installed(i) = pem_installed(i) - ir_production(i - pem_lifetime_yr) * pem_gw_per_t_ir;
        end
        pem_installed(i) = max(0, pem_installed(i));
    end
end

% H2 produced from installed PEM base
h2_from_pem = pem_installed * h2_per_gw_yr;  % t H2/yr
co2_avoided_h2 = h2_from_pem * co2_avoided_per_h2;  % t CO2/yr avoided

% --- Calculate rocket emissions ---
cargo_flights = earth_cargo / 100;  % ~100 t per cargo Starship
total_launches = cargo_flights * tanker_ratio;  % including tankers
co2_rockets = total_launches * co2_per_launch;  % t CO2/yr from rockets

% --- Revenue streams ($ millions/yr) ---
reo_demand = reo_demand_2026 * (1 + reo_demand_growth).^Y;
supply_fraction = reo_production ./ reo_demand;
reo_price = max(reo_price_floor, reo_basket_2026 * (1 - 0.6 * supply_fraction));

rev_reo        = reo_production .* reo_price / 1e6;                    % Direct REO sales
rev_pgm        = pgm_production .* pgm_price_per_kg * 1000 / 1e6;     % PGM sales
rev_direct     = rev_reo + rev_pgm;                                     % Total direct revenue

% --- Environmental externality streams ($M/yr) ---
ext_reo_mining = reo_production .* externality_reo_per_t / 1e6;        % Avoided mining damage
ext_h2_enable  = co2_avoided_h2 * scc / 1e6;                           % H2-via-Ir avoided CO2
ext_rockets    = -co2_rockets * scc / 1e6;                              % Rocket emissions (negative)

ext_total      = ext_reo_mining + ext_h2_enable + ext_rockets;          % Net environmental
rev_total      = rev_direct + ext_total;                                 % Total with externalities

% --- Summary environmental metrics ---
fprintf('--- Environmental Balance at P12 (Y90) ---\n');
idx90 = 91;
fprintf('  REO displacement avoided damage:  $%.1fB/yr\n', ext_reo_mining(idx90)/1e3);
fprintf('  H2 enabling (Ir→PEM→CO2 avoided): $%.1fB/yr\n', ext_h2_enable(idx90)/1e3);
fprintf('  Rocket emissions (negative):      $%.1fB/yr\n', ext_rockets(idx90)/1e3);
fprintf('  NET environmental:                $%.1fB/yr\n', ext_total(idx90)/1e3);
fprintf('  Rockets as %% of benefits:         %.1f%%\n', ...
    abs(ext_rockets(idx90)) / (ext_reo_mining(idx90) + ext_h2_enable(idx90)) * 100);
fprintf('  Cumulative PEM installed:          %.1f GW\n', pem_installed(idx90));
fprintf('  Annual CO2 avoided (H2):           %.1f Mt\n', co2_avoided_h2(idx90)/1e6);
fprintf('  Annual CO2 from rockets:           %.1f Mt\n', co2_rockets(idx90)/1e6);
fprintf('\n');

%% ═══════════════════════════════════════════════════════════════
%  6. COST MODEL
%  ═══════════════════════════════════════════════════════════════

% Earth launch costs ($ millions/yr)
cost_launch = earth_cargo .* launch_cost .* contingency / 1e3;  % $M/yr
% (earth_cargo in tonnes × $/kg × contingency → $/yr → $M/yr)
% Note: earth_cargo is tonnes, launch_cost is $/kg, so × 1000 for kg then / 1e6 for $M
cost_launch = earth_cargo * 1000 .* launch_cost .* contingency / 1e6;

% In-situ fabrication costs ($ millions/yr)
cost_insitu = insitu_mass * 1000 * insitu_cost_per_kg / 1e6;

% Canister recovery costs ($ millions/yr) — for P9+ mass driver era
% Baseline: Option 1b (minimal chute, ~$16B/yr at P12)
% Scale linearly with mass driver throughput
canister_cost_p12 = 16000;  % $M/yr at P12 (285,715 canisters/yr)
cost_canister = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y >= 35 && y < 45       % P9: mass driver ramps up
        cost_canister(i) = canister_cost_p12 * reo_production(i) / 1e6;
    elseif y >= 45
        cost_canister(i) = canister_cost_p12 * reo_production(i) / 1e6;
    end
end

% Operations & maintenance ($ millions/yr)
% ~5% of cumulative Earth-launched hardware value per year
% Simplification: proportional to current Earth cargo cost
cost_ops = cost_launch * 0.05;

% R&D and programme management ($ millions/yr)
% ~$500M/yr early, scaling to ~$2B/yr at full operations
cost_rd = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y < 25
        cost_rd(i) = 500;
    elseif y < 45
        cost_rd(i) = 1000;
    elseif y < 60
        cost_rd(i) = 1500;
    else
        cost_rd(i) = 2000;
    end
end

% Total costs
cost_total = cost_launch + cost_insitu + cost_canister + cost_ops + cost_rd;

%% ═══════════════════════════════════════════════════════════════
%  7. NPV AND IRR CALCULATION
%  ═══════════════════════════════════════════════════════════════

% Net benefit ($ millions/yr)
net_benefit_total = rev_total - cost_total;       % Including externalities
net_benefit_direct = rev_direct - cost_total;      % Direct revenue only

% NPV ($ millions)
npv_total  = cumsum(net_benefit_total .* discount_factor);
npv_direct = cumsum(net_benefit_direct .* discount_factor);

% Cumulative undiscounted
cum_cost     = cumsum(cost_total);
cum_rev_tot  = cumsum(rev_total);
cum_rev_dir  = cumsum(rev_direct);

% Breakeven year (undiscounted)
net_cum_total  = cum_rev_tot - cum_cost;
net_cum_direct = cum_rev_dir - cum_cost;

be_total  = find(net_cum_total > 0, 1, 'first');
be_direct = find(net_cum_direct > 0, 1, 'first');

% Programme totals
total_cost_100yr = cum_cost(end);
total_rev_100yr  = cum_rev_tot(end);
total_earth_cargo = sum(earth_cargo);
total_flights = total_earth_cargo / 100;  % ~100 t per Starship

fprintf('═══════════════════════════════════════════════\n');
fprintf('  SELENITE PROGRAMME — 100-YEAR ECONOMICS\n');
fprintf('═══════════════════════════════════════════════\n\n');
fprintf('Total programme cost (100 yr):     $%.1f trillion\n', total_cost_100yr/1e6);
fprintf('Total revenue + externalities:     $%.1f trillion\n', total_rev_100yr/1e6);
fprintf('  of which direct revenue:         $%.1f trillion\n', cum_rev_dir(end)/1e6);
fprintf('  of which REO extern (mining):    $%.1f trillion\n', sum(ext_reo_mining)/1e6);
fprintf('  of which H2 extern (Ir→PEM):     $%.1f trillion\n', sum(ext_h2_enable)/1e6);
fprintf('  of which rocket emissions:       $%.1f trillion\n', sum(ext_rockets)/1e6);
fprintf('Total Earth cargo:                 %s tonnes\n', num2str(round(total_earth_cargo)));
fprintf('Total Starship flights (cargo):    ~%s\n', num2str(round(total_flights)));
fprintf('Total launches (incl tankers):     ~%s\n', num2str(round(total_flights * tanker_ratio)));
fprintf('Total rocket CO2 (100 yr):         %.0f Mt\n', sum(co2_rockets)/1e6);
fprintf('NPV (with all externalities):      $%.1f trillion\n', npv_total(end)/1e6);
fprintf('NPV (direct revenue only):         $%.1f trillion\n', npv_direct(end)/1e6);
if ~isempty(be_total)
    fprintf('Breakeven year (with extern):      Y%d\n', Y(be_total));
end
if ~isempty(be_direct)
    fprintf('Breakeven year (direct only):      Y%d\n', Y(be_direct));
else
    fprintf('Breakeven year (direct only):      NOT REACHED in 100 yr\n');
end

% Cost per tonne REO at each phase
fprintf('\n--- Cost per tonne REO by phase ---\n');
phases = {'P7 (Y20)', 'P8 (Y30)', 'P9 (Y40)', 'P10 (Y55)', 'P11 (Y70)', 'P12 (Y90)'};
phase_y = [20 30 40 55 70 90];
for j = 1:length(phase_y)
    idx = phase_y(j) + 1;
    if reo_production(idx) > 0
        cpt = cost_total(idx) / reo_production(idx) * 1e6;  % $/t
        fprintf('  %s: $%s/t REO (production: %.0f t/yr)\n', ...
            phases{j}, num2str(round(cpt)), reo_production(idx));
    end
end

%% ═══════════════════════════════════════════════════════════════
%  8. SENSITIVITY ANALYSIS
%  ═══════════════════════════════════════════════════════════════

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  SENSITIVITY ANALYSIS\n');
fprintf('═══════════════════════════════════════════════\n\n');

% --- Canister recovery options ---
canister_options = [42000, 16000, 4600];  % $M/yr at P12
canister_labels = {'Full parachute ($42B)', 'Minimal chute ($16B)', 'Shuttlecock ($4.6B)'};

npv_canister = zeros(3,1);
for k = 1:3
    cost_can_k = cost_canister * canister_options(k) / canister_cost_p12;
    cost_tot_k = cost_launch + cost_insitu + cost_can_k + cost_ops + cost_rd;
    net_k = rev_total - cost_tot_k;
    npv_canister(k) = sum(net_k .* discount_factor);
end
fprintf('Canister recovery NPV (with extern):\n');
for k = 1:3
    fprintf('  %s: $%.1f T\n', canister_labels{k}, npv_canister(k)/1e6);
end

% --- Discount rate sensitivity ---
dr_options = [0.014, 0.020, 0.030, 0.035];
dr_labels = {'Stern 1.4%', 'Flat 2.0%', 'Flat 3.0%', 'UK Green Book 3.5%'};

npv_dr = zeros(4,1);
for k = 1:4
    df_k = ones(N,1);
    for i = 2:N
        df_k(i) = df_k(i-1) / (1 + dr_options(k));
    end
    npv_dr(k) = sum(net_benefit_total .* df_k);
end
fprintf('\nDiscount rate sensitivity (NPV with extern):\n');
for k = 1:4
    fprintf('  %s: $%.1f T\n', dr_labels{k}, npv_dr(k)/1e6);
end

% --- Launch cost sensitivity ---
lc_options = [1.5, 1.0, 0.5];  % multiplier on baseline
lc_labels = {'150% baseline', '100% baseline', '50% baseline'};

npv_lc = zeros(3,1);
for k = 1:3
    cost_launch_k = earth_cargo * 1000 .* (launch_cost * lc_options(k)) .* contingency / 1e6;
    cost_tot_k = cost_launch_k + cost_insitu + cost_canister + cost_ops + cost_rd;
    net_k = rev_total - cost_tot_k;
    npv_lc(k) = sum(net_k .* discount_factor);
end
fprintf('\nLaunch cost sensitivity (NPV with extern):\n');
for k = 1:3
    fprintf('  %s: $%.1f T\n', lc_labels{k}, npv_lc(k)/1e6);
end

% --- Old architecture comparison (mass driver at P10, 390k MOLE-I) ---
fprintf('\n--- OLD vs NEW architecture ---\n');
earth_cargo_old = earth_cargo;
for i = 1:N
    y = Y(i);
    if y >= 25 && y < 35      % P8: add 48,990 MOLE-I
        earth_cargo_old(i) = earth_cargo(i) + 17636/10;
    elseif y >= 35 && y < 45  % P9: add 341,800 MOLE-I + FSP
        earth_cargo_old(i) = earth_cargo(i) + (123048 + 65017)/10;
    end
end
cost_launch_old = earth_cargo_old * 1000 .* launch_cost .* contingency / 1e6;
cost_total_old = cost_launch_old + cost_insitu + cost_canister + cost_ops + cost_rd;
net_old = rev_total - cost_total_old;
npv_old = sum(net_old .* discount_factor);
fprintf('  OLD architecture NPV: $%.1f T\n', npv_old/1e6);
fprintf('  NEW architecture NPV: $%.1f T\n', npv_total(end)/1e6);
fprintf('  ECN-019 improvement:  $%.1f T\n', (npv_total(end) - npv_old)/1e6);

%% ═══════════════════════════════════════════════════════════════
%  9. FIGURES
%  ═══════════════════════════════════════════════════════════════

% --- Figure 1: Cost vs Revenue over time ---
fig1 = figure('Position', [50 50 1200 700], 'Color', [0.03 0.06 0.1]);
set(fig1, 'DefaultAxesColor', [0.05 0.08 0.12]);

subplot(2,2,1);
semilogy(Y, cost_total, 'r-', 'LineWidth', 2); hold on;
semilogy(Y, max(rev_total, 0.01), 'g-', 'LineWidth', 2);
semilogy(Y, max(rev_direct, 0.01), 'g--', 'LineWidth', 1.5);
semilogy(Y, max(ext_reo_mining, 0.01), 'c:', 'LineWidth', 1);
semilogy(Y, max(ext_h2_enable, 0.01), 'm:', 'LineWidth', 1);
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('$M/yr (log scale)', 'Color', [0.7 0.8 0.9]);
title('Annual Cost vs Revenue', 'Color', [0.9 0.95 1], 'FontSize', 12);
legend('Total Cost', 'Revenue + All Extern', 'Direct Revenue', ...
    'REO Mining Extern', 'H2 Enabling Extern', ...
    'TextColor', [0.7 0.8 0.9], 'Color', [0.08 0.12 0.18], ...
    'Location', 'southeast', 'FontSize', 7);

% --- Figure 1b: Cumulative NPV ---
subplot(2,2,2);
plot(Y, npv_total/1e6, 'g-', 'LineWidth', 2); hold on;
plot(Y, npv_direct/1e6, 'g--', 'LineWidth', 1.5);
yline(0, 'w--', 'LineWidth', 0.5);
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('Cumulative NPV ($T)', 'Color', [0.7 0.8 0.9]);
title('Net Present Value', 'Color', [0.9 0.95 1], 'FontSize', 12);
legend('With Externalities', 'Direct Revenue Only', ...
    'TextColor', [0.7 0.8 0.9], 'Color', [0.08 0.12 0.18], 'Location', 'northwest');

% --- Figure 1c: Earth cargo ---
subplot(2,2,3);
bar(Y, earth_cargo/1000, 1, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'none');
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('Earth Cargo (kt/yr)', 'Color', [0.7 0.8 0.9]);
title('Earth-to-Moon Cargo', 'Color', [0.9 0.95 1], 'FontSize', 12);

% --- Figure 1d: REO production ---
subplot(2,2,4);
semilogy(Y, max(reo_production, 0.01), 'c-', 'LineWidth', 2);
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]); ylim([0.01 2e6]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('REO Production (t/yr)', 'Color', [0.7 0.8 0.9]);
title('REO Production Ramp', 'Color', [0.9 0.95 1], 'FontSize', 12);

sgtitle('SELENITE PROGRAMME — Economic Evaluation (ECN-019 Rev B)', ...
    'Color', [0.9 0.95 1], 'FontSize', 14, 'FontWeight', 'bold');

% --- Figure 2: Cost breakdown stacked area ---
fig2 = figure('Position', [100 100 1200 500], 'Color', [0.03 0.06 0.1]);

area_data = [cost_launch, cost_insitu, cost_canister, cost_ops, cost_rd];
h = area(Y, area_data / 1000);  % $B/yr
h(1).FaceColor = [0.8 0.2 0.2];  % Launch
h(2).FaceColor = [0.2 0.6 0.8];  % In-situ fab
h(3).FaceColor = [0.8 0.6 0.2];  % Canister recovery
h(4).FaceColor = [0.5 0.3 0.6];  % Ops
h(5).FaceColor = [0.3 0.5 0.3];  % R&D
for j = 1:5, h(j).EdgeColor = 'none'; h(j).FaceAlpha = 0.8; end
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('Cost ($B/yr)', 'Color', [0.7 0.8 0.9]);
title('SELENITE Cost Breakdown by Category', 'Color', [0.9 0.95 1], 'FontSize', 14);
legend('Earth Launch', 'In-Situ Fabrication', 'Canister Recovery', ...
    'Operations', 'R&D / Programme Mgmt', ...
    'TextColor', [0.7 0.8 0.9], 'Color', [0.08 0.12 0.18], 'Location', 'northwest');

% --- Figure 3: Sensitivity tornado ---
fig3 = figure('Position', [150 150 900 500], 'Color', [0.03 0.06 0.1]);

baseline_npv = npv_total(end) / 1e6;  % $T

% Build sensitivity data
% Baseline NPV
baseline_npv = npv_total(end) / 1e6;  % $T

% H2 enabling: scale PROBE fleet for Ir (DG-11.6 at 7x fleet)
ir_scale_factor = 7;  % ~2,000 PROBEs, ~50 t/yr PGM, ~7.5 t/yr Ir
pgm_scaled = pgm_production * ir_scale_factor;
ir_scaled = pgm_scaled * ir_fraction_of_pgm;
pem_scaled = zeros(N,1);
for i = 2:N
    pem_scaled(i) = pem_scaled(i-1) + ir_scaled(i) * pem_gw_per_t_ir;
    if i > pem_lifetime_yr
        pem_scaled(i) = pem_scaled(i) - ir_scaled(i-pem_lifetime_yr) * pem_gw_per_t_ir;
    end
    pem_scaled(i) = max(0, pem_scaled(i));
end
ext_h2_scaled = pem_scaled * h2_per_gw_yr * co2_avoided_per_h2 * scc / 1e6;
rev_total_h2scaled = rev_direct + ext_reo_mining + ext_h2_scaled + ext_rockets;
npv_h2scaled = sum((rev_total_h2scaled - cost_total) .* discount_factor);

% No rocket externality counted (direct revenue + REO extern only, no rocket penalty)
rev_no_rockets = rev_direct + ext_reo_mining + ext_h2_enable;
npv_no_rockets = sum((rev_no_rockets - cost_total) .* discount_factor);

sens_labels = {'Canister: Full chute', 'Canister: Shuttlecock', ...
               'Discount: Stern 1.4%', 'Discount: UK 3.5%', ...
               'Launch: +50%', 'Launch: -50%', ...
               'Old arch (P10 MD)', ...
               'Ir 7x (DG-11.6 PGM)', ...
               'No rocket penalty'};
sens_delta = [npv_canister(1)/1e6 - baseline_npv;
              npv_canister(3)/1e6 - baseline_npv;
              npv_dr(1)/1e6 - baseline_npv;
              npv_dr(4)/1e6 - baseline_npv;
              npv_lc(1)/1e6 - baseline_npv;
              npv_lc(3)/1e6 - baseline_npv;
              npv_old/1e6 - baseline_npv;
              npv_h2scaled/1e6 - baseline_npv;
              npv_no_rockets/1e6 - baseline_npv];

[~, sort_idx] = sort(abs(sens_delta), 'descend');
sens_labels = sens_labels(sort_idx);
sens_delta = sens_delta(sort_idx);

barh(sens_delta, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'none');
set(gca, 'YTickLabel', sens_labels, 'Color', [0.05 0.08 0.12], ...
    'XColor', [0.7 0.8 0.9], 'YColor', [0.7 0.8 0.9], ...
    'GridColor', [0.15 0.2 0.3], 'FontSize', 10);
grid on;
xlabel(sprintf('Change in NPV from baseline ($%.1fT)', baseline_npv), 'Color', [0.7 0.8 0.9]);
title('Sensitivity Tornado — NPV Impact', 'Color', [0.9 0.95 1], 'FontSize', 14);
xline(0, 'w-', 'LineWidth', 1);

% Save figures
fprintf('\nSaving figures...\n');
saveas(fig1, 'SELENITE_ECON_v1_1_overview.png');
saveas(fig2, 'SELENITE_ECON_v1_1_costs.png');
saveas(fig3, 'SELENITE_ECON_v1_1_sensitivity.png');

% --- Figure 4: Environmental balance ---
fig4 = figure('Position', [200 200 1200 500], 'Color', [0.03 0.06 0.1]);

subplot(1,2,1);
area_env = [ext_reo_mining/1e3, ext_h2_enable/1e3, ext_rockets/1e3];
h = area(Y, area_env);
h(1).FaceColor = [0.2 0.7 0.3];   % REO mining extern (green)
h(2).FaceColor = [0.3 0.5 0.9];   % H2 enabling (blue)
h(3).FaceColor = [0.8 0.2 0.2];   % Rocket emissions (red, negative)
for j = 1:3, h(j).EdgeColor = 'none'; h(j).FaceAlpha = 0.8; end
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('Environmental Value ($B/yr)', 'Color', [0.7 0.8 0.9]);
title('Environmental Externalities Breakdown', 'Color', [0.9 0.95 1], 'FontSize', 12);
legend('REO: Avoided Mining Damage', 'H2: Ir-Enabled Decarbonisation', ...
    'Rocket CO2 Emissions (negative)', ...
    'TextColor', [0.7 0.8 0.9], 'Color', [0.08 0.12 0.18], 'Location', 'northwest');

subplot(1,2,2);
plot(Y, co2_avoided_h2/1e6, 'b-', 'LineWidth', 2); hold on;
plot(Y, co2_rockets/1e6, 'r-', 'LineWidth', 2);
plot(Y, (co2_avoided_h2 - co2_rockets)/1e6, 'g-', 'LineWidth', 2);
plot(Y, pem_installed, 'm--', 'LineWidth', 1.5);
set(gca, 'Color', [0.05 0.08 0.12], 'XColor', [0.7 0.8 0.9], ...
    'YColor', [0.7 0.8 0.9], 'GridColor', [0.15 0.2 0.3]);
grid on; xlim([0 100]);
xlabel('Programme Year', 'Color', [0.7 0.8 0.9]);
ylabel('Mt CO2/yr  |  GW installed (dashed)', 'Color', [0.7 0.8 0.9]);
title('Carbon Balance: H2 Avoidance vs Rocket Emissions', 'Color', [0.9 0.95 1], 'FontSize', 12);
legend('CO2 Avoided (H2 via Ir)', 'CO2 from Rockets', 'Net CO2 Balance', ...
    'PEM Installed (GW)', ...
    'TextColor', [0.7 0.8 0.9], 'Color', [0.08 0.12 0.18], 'Location', 'northwest');

sgtitle('SELENITE — Full Environmental Accounting', ...
    'Color', [0.9 0.95 1], 'FontSize', 14, 'FontWeight', 'bold');

saveas(fig4, 'SELENITE_ECON_v1_1_environmental.png');

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  SELENITE_ECON v1.1 COMPLETE\n');
fprintf('  4 figures saved to working directory\n');
fprintf('  Environmental balance: rockets ~3%% of benefits\n');
fprintf('═══════════════════════════════════════════════\n');