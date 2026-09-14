%% SELENITE_ECON v1.2 — Bottom-Up Economic Evaluation
%  Every cargo figure derived from infrastructure requirements,
%  constrained by phase targets and unit specifications.
%
%  Model logic: REO target → circuits → haulers/conveyors → power →
%               canisters → MOLE-I (from PROBE propellant) → Earth cargo
%
%  Ref: ECN-019 Rev B, SEL-DECISION-001 Rev B, all design specs
%  Author: Jason Stewart | April 2026

clear; close all; clc;
fprintf('SELENITE_ECON v1.2 — Bottom-Up Economic Model\n');
fprintf('ECN-019 Rev B | %s\n\n', datestr(now));

%% ═══════════════════════════════════════════════════════════════
%  1. UNIT SPECIFICATIONS (from design docs)
%  ═══════════════════════════════════════════════════════════════

% --- Processing circuit (SEL-PROC-001, SEL-PROC-PKT-001) ---
circuit.reo_yr       = 0.4;       % t REO/yr per circuit
circuit.regolith_yr  = 800;       % t regolith/yr per circuit (~500 ppm REE)
circuit.mass_kg      = 15000;     % kg per circuit
circuit.power_kw     = 180;       % kW per circuit
circuit.earth_frac  = @(y) min(1.0, max(0.10, 1.0 - (y - 25) * 0.03));
% 100% at Y25 (P8, all equipment Earth-built)
% ~55% at Y40 (P9, foundry producing vessels + piping)
% ~10% at Y55+ (mature: only sensors, PTFE, seals, pumps, bearings from Earth)
% Earth-only at maturity: ~1,500 kg per 15,000 kg circuit
%   Sensors/PLCs 500 kg + PTFE linings 200 kg + pump internals 300 kg +
%   filter cloths 50 kg + seals 50 kg + bearings 100 kg +
%   power electronics 200 kg + valve seats 100 kg = ~1,500 kg
circuit.life_yr      = 20;        % replacement cycle
circuit.maint_frac   = 0.02;     % 2 kg/yr Earth replacement parts per circuit (sensors, pumps, linings)

% --- Hauler (SEL-HAULER-001 Rev B, ECN-019) ---
hauler.mass_kg       = 1450;      % kg dry (incl bucket/blade, Na-S, SRM)
hauler.throughput_yr = 1500;      % t regolith/yr (mining + transport, blended road/off-road)
hauler.life_yr       = 10;        % service life
hauler.maint_kg_yr   = 9;        % kg Earth parts/yr (avionics 3 + bearings 2 + BMS 4)

% Hauler Earth fraction transitions as foundry matures
% P8: 100% Earth-built. P9: ~80%. P10+: ~43% (57% in-situ)
hauler.earth_frac = @(y) min(1.0, max(0.43, 1.0 - (y - 25) * 0.0285));
% Linear from 1.0 at Y25 to 0.43 at Y45

% --- Steel apron conveyor (ECN-019 Addendum A) ---
conv.mass_per_km     = 100000;    % kg/km (chain + rollers + frame + drives)
conv.earth_frac      = 0.05;      % 5% Earth (drive electronics, bearings)
conv.maint_frac_yr   = 0.005;     % 0.5%/yr replacement (bearings, electronics)

% --- Thorium MSR (ECN-019 §2) ---
msr.power_mw         = 100;       % MWe per unit
msr.mass_kg          = 50000;     % kg (vessel + turbomachinery, excl regolith shielding)
msr.life_yr          = 20;        % vessel replacement cycle
msr.earth_frac = @(y) max(0.3, min(1.0, 1.0 - (y - 45) * 0.02));
% 100% Earth (Hastelloy-N) until Y45, declining to 30% by Y80 (Ni-201 in-situ)

% --- FSP (NASA Kilopower heritage) ---
fsp.power_kw         = 40;        % kW per unit
fsp.mass_kg          = 6600;      % kg per unit

% --- Mass driver canister (ECN-019 §10) ---
can.total_mass_kg    = 5000;      % kg total (shell + TPS + REO)
can.shell_mass_kg    = 1500;      % kg (Fe-Ni shell + Al₂O₃ TPS)
can.reo_payload_t    = 3.5;       % t REO per canister
can.earth_kg         = 28;        % kg Earth content per canister (minimal chute baseline)

% --- MOLE-I (SEL_MOLEI_DESIGN v5) ---
molei.propellant_yr  = 5692;      % kg propellant/yr per unit
molei.mass_kg        = 360;       % kg per unit
molei.earth_frac     = 1.0;       % 100% Earth-built always

% --- PROBE (SEL_PROBE_DESIGN Rev A) ---
probe.propellant     = 6654;      % kg propellant per mission
probe.mass_kg        = 800;       % kg dry
probe.missions_yr    = 1;         % missions/yr average
probe.life_yr        = 15;        % replacement cycle
probe.pgm_per_mission= 0.0175;   % t PGM per mission (~17.5 kg)

% --- SKIP (SEL_SKIP_DESIGN Rev A, SPA only) ---
skip.propellant_yr   = 83000;     % kg/yr per SKIP (303 kg/hop × 274 hops)
skip.count           = 8;         % fleet size P7-P8
skip.mass_kg         = 300;       % kg dry

% --- SINTER / ARM-C (construction fleet) ---
sinter.mass_kg       = 2200;
armc.mass_kg         = 1500;

% --- Substation (for MOLE-I, 1 per 5 MOLE-I) ---
substation.mass_kg   = 135;

% --- Reagent ---
reagent.per_circuit_yr = 49000;   % kg/yr Earth reagent per circuit (pre-ISRU)
reagent.isru_frac = @(y) min(0.98, max(0, (y - 9) * 0.03));
% 0% at Y9, ~50% at Y25, ~85% at Y35, ~95% at Y45, ~98% at Y55+

%% ═══════════════════════════════════════════════════════════════
%  2. ECONOMIC PARAMETERS
%  ═══════════════════════════════════════════════════════════════

Y = (0:100)';  N = length(Y);

% Launch cost ($/kg to lunar surface)
launch_cost = arrayfun(@(y) ...
    6000*(y<25) + 4000*(y>=25 & y<45) + 2000*(y>=45), Y);

% Discount rate (Arrow et al. 2014 declining)
dr = arrayfun(@(y) 0.03*(y<=30) + 0.025*(y>30 & y<=75) + 0.02*(y>75), Y);
df = cumprod(1 ./ (1 + dr));  % discount factor

% Contingency
contingency = arrayfun(@(y) ...
    1.50*(y<25) + 1.35*(y>=25 & y<45) + 1.25*(y>=45), Y);

% In-situ fabrication cost
insitu_cost_per_kg = 100;  % $/kg (midpoint $50-200)

% Social cost of carbon (EPA Nov 2023)
scc = 190;  % $/tCO2

%% ═══════════════════════════════════════════════════════════════
%  3. PHASE TARGETS (exogenous — programme plan)
%  ═══════════════════════════════════════════════════════════════

% REO production targets by year (log-linear interpolation)
reo_knots_y = [0  15  18   25    28    35     45      60       80       100];
reo_knots_v = [0   0   0   0.4   125   125    1000    10000    100000   1000000];

reo_target = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y <= 18, reo_target(i) = 0; continue; end
    idx = find(reo_knots_y <= y, 1, 'last');
    if idx >= length(reo_knots_y)
        reo_target(i) = reo_knots_v(end);
    else
        y0 = reo_knots_y(idx); y1 = reo_knots_y(idx+1);
        r0 = max(reo_knots_v(idx), 0.01); r1 = reo_knots_v(idx+1);
        if r1 <= 0, reo_target(i) = 0;
        else
            frac = (y - y0) / (y1 - y0);
            reo_target(i) = exp(log(r0) + frac * (log(r1) - log(r0)));
        end
    end
end

% PROBE fleet targets by year
probe_knots_y = [0  9  15  25  35  45  60  80  100];
probe_knots_v = [0  3  30  96 190 230 260 286  286];
probe_fleet = interp1(probe_knots_y, probe_knots_v, Y, 'linear', 286);
probe_fleet = floor(probe_fleet);

% SKIP fleet (SPA only, P3-P8, retire P9)
skip_active = arrayfun(@(y) skip.count * (y >= 7 & y < 45), Y);
% Ramp down: 8 until Y35, then linear to 0 by Y45
skip_active = arrayfun(@(y) ...
    skip.count * (y >= 7 & y < 35) + ...
    max(0, skip.count * (1 - (y-35)/10)) * (y >= 35 & y < 45), Y);

% Mining frontier radius (km from spine)
% Determines conveyor need: Tier 3 = 50-150 km
frontier_km = arrayfun(@(y) ...
    0*(y<28) + min(150, max(0, (y-28)*2)) * (y>=28), Y);

% Fraction of ore via Tier 3 (conveyor territory)
tier3_frac = arrayfun(@(y) ...
    0*(y<40) + min(0.55, max(0, (y-40)*0.01)) * (y>=40), Y);

%% ═══════════════════════════════════════════════════════════════
%  4. INFRASTRUCTURE DERIVATION (bottom-up)
%  ═══════════════════════════════════════════════════════════════

% --- Circuits needed ---
circuits_needed = ceil(reo_target / circuit.reo_yr);

% --- Regolith throughput ---
regolith_yr = reo_target / 0.0005;  % t/yr (500 ppm REE)

% --- Haulers needed (for non-conveyor fraction) ---
hauler_ore_frac = 1 - tier3_frac;  % fraction handled by haulers
haulers_needed = ceil(regolith_yr .* hauler_ore_frac / hauler.throughput_yr);

% --- Conveyor km needed ---
% Tier 3 ore volume determines conveyor throughput needed
% Each km of trunk conveyor handles ~20,000 t/yr (at 2,000 t/hr, utilisation)
% Network is dendritic: ~500 trunk + 5000 branch at P12
conv_throughput_per_km = 20000;  % t/yr per km (average across trunk+branch)
conv_km_needed = regolith_yr .* tier3_frac / conv_throughput_per_km;

% --- Power needed (kW) ---
power_kw = circuits_needed * circuit.power_kw;
% Convert to MSR count (P9+ only, FSP before)
msr_count = zeros(N,1);
fsp_count = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y < 35       % Pre-MSR: all FSP
        fsp_count(i) = ceil(power_kw(i) / fsp.power_kw);
    elseif y < 45   % Transition: MSR growing, FSP declining
        msr_frac = (y - 35) / 10;  % 0 at Y35, 1 at Y45
        msr_count(i) = ceil(power_kw(i) * msr_frac / (msr.power_mw * 1000));
        fsp_count(i) = ceil(power_kw(i) * (1-msr_frac) / fsp.power_kw);
    else             % P10+: MSR dominant, FSP backup only
        msr_count(i) = ceil(power_kw(i) / (msr.power_mw * 1000));
        fsp_count(i) = min(fsp_count(max(1,i-1)), 20);  % keep ~20 FSP as backup
    end
end

% --- MOLE-I needed (from propellant demand) ---
prop_demand = probe_fleet * probe.propellant * probe.missions_yr ...  % PROBE
            + skip_active * skip.propellant_yr / 1000 ...             % SKIP (convert to t)
            + 100 * 1000;                                              % Crew rotation (~100 t/yr)
% prop_demand in kg/yr
prop_demand_kg = probe_fleet * probe.propellant ...
               + skip_active * skip.propellant_yr ...
               + 100000;  % crew + ECLSS
molei_needed = ceil(prop_demand_kg / molei.propellant_yr);

% --- Canisters/yr (P9+ mass driver era) ---
canisters_yr = zeros(N,1);
for i = 1:N
    if Y(i) >= 35  % PKT→Earth mass driver from P9
        canisters_yr(i) = ceil(reo_target(i) / can.reo_payload_t);
    end
end

% --- PGM production ---
pgm_production = probe_fleet * probe.pgm_per_mission;  % t/yr

%% ═══════════════════════════════════════════════════════════════
%  5. EARTH CARGO DERIVATION (from infrastructure deltas)
%  ═══════════════════════════════════════════════════════════════

% Year-on-year infrastructure deltas
d_circuits = max(0, diff([0; circuits_needed]));
d_haulers  = max(0, diff([0; haulers_needed]));
d_conv_km  = max(0, diff([0; conv_km_needed]));
d_msr      = max(0, diff([0; msr_count]));
d_fsp      = max(0, diff([0; fsp_count]));
d_molei    = max(0, diff([0; molei_needed]));
d_probes   = max(0, diff([0; probe_fleet]));

% --- New-build Earth cargo (tonnes/yr) ---
cargo_circuits = zeros(N,1);
for i = 1:N
    ef = circuit.earth_frac(Y(i));
    cargo_circuits(i) = d_circuits(i) * circuit.mass_kg * ef / 1000;
end
cargo_haulers   = zeros(N,1);
for i = 1:N
    ef = hauler.earth_frac(Y(i));
    cargo_haulers(i) = d_haulers(i) * hauler.mass_kg * ef / 1000;
end
cargo_conveyors = d_conv_km * conv.mass_per_km * conv.earth_frac / 1000;
cargo_msr       = zeros(N,1);
for i = 1:N
    ef = msr.earth_frac(Y(i));
    cargo_msr(i) = d_msr(i) * msr.mass_kg * ef / 1000;
end
cargo_fsp       = d_fsp * fsp.mass_kg / 1000;
cargo_molei     = d_molei * (molei.mass_kg + substation.mass_kg/5) / 1000;  % +substation
cargo_probes    = d_probes * probe.mass_kg / 1000;
cargo_canisters = canisters_yr * can.earth_kg / 1000;

% --- Reagent Earth cargo ---
cargo_reagent = zeros(N,1);
for i = 1:N
    y = Y(i);
    isru_frac = reagent.isru_frac(y);
    cargo_reagent(i) = circuits_needed(i) * reagent.per_circuit_yr * (1 - isru_frac) / 1e6;
end

% --- Maintenance/replacement cargo (existing fleet) ---
maint_circuits = zeros(N,1);
for i = 1:N
    maint_circuits(i) = circuits_needed(i) * circuit.mass_kg * circuit.maint_frac * ...
                         circuit.earth_frac(Y(i)) / 1000;
end
maint_haulers  = haulers_needed * hauler.maint_kg_yr / 1000;
maint_conv     = conv_km_needed * conv.mass_per_km * conv.maint_frac_yr * conv.earth_frac / 1000;
maint_msr      = zeros(N,1);
for i = 1:N
    maint_msr(i) = msr_count(i) / msr.life_yr * msr.mass_kg * msr.earth_frac(Y(i)) / 1000;
end

% --- Construction fleet (P8 Wave 1 — one-time) ---
cargo_construction = zeros(N,1);
cargo_construction(26) = (20*sinter.mass_kg + 10*hauler.mass_kg + 5*armc.mass_kg + ...
                           4*fsp.mass_kg + 80000 + 5000) / 1000;  % Wave 1 at Y25
% Crew hab + commissioning equipment at Y28
cargo_construction(29) = (20000 + 10000 + 7000 + 25000) / 1000;  % hab + supplies + foundry + catapult demo

% --- Mass driver YBCO (one-time, P7 for SPA→PKT) ---
cargo_ybco = zeros(N,1);
cargo_ybco(23) = 30;   % Y22: SPA→PKT YBCO delivery (30 t)
cargo_ybco(24) = 30;   % Y23: remainder
cargo_ybco(36) = 50;   % Y35: PKT→Earth mass driver YBCO
cargo_ybco(44) = 30;   % Y43: PKT→SPA mass driver YBCO

% --- R&D / programme management / SPA base ops ---
cargo_spa_ops = arrayfun(@(y) ...
    18*(y<7) + 23*(y>=7&y<9) + 30*(y>=9&y<15) + 20*(y>=15&y<25) + ...
    15*(y>=25), Y);  % SPA base steady-state (robots, crew, ECLSS)

% --- Total Earth cargo ---
earth_cargo = cargo_circuits + cargo_haulers + cargo_conveyors + ...
              cargo_msr + cargo_fsp + cargo_molei + cargo_probes + ...
              cargo_canisters + cargo_reagent + ...
              maint_circuits + maint_haulers + maint_conv + maint_msr + ...
              cargo_construction + cargo_ybco + cargo_spa_ops;

% --- In-situ manufactured mass ---
insitu_haulers = zeros(N,1);
for i = 1:N
    insitu_haulers(i) = d_haulers(i) * hauler.mass_kg * (1 - hauler.earth_frac(Y(i))) / 1000;
end
insitu_conveyors = d_conv_km * conv.mass_per_km * (1 - conv.earth_frac) / 1000;
insitu_canisters = canisters_yr * (can.shell_mass_kg - can.earth_kg) / 1000;
insitu_msr = zeros(N,1);
for i = 1:N
    insitu_msr(i) = d_msr(i) * msr.mass_kg * (1 - msr.earth_frac(Y(i))) / 1000;
end
insitu_circuits = zeros(N,1);
for i = 1:N
    insitu_circuits(i) = d_circuits(i) * circuit.mass_kg * (1 - circuit.earth_frac(Y(i))) / 1000;
end
insitu_total = insitu_haulers + insitu_conveyors + insitu_canisters + insitu_msr + insitu_circuits;

%% ═══════════════════════════════════════════════════════════════
%  6. REVENUE & ENVIRONMENTAL MODEL
%  ═══════════════════════════════════════════════════════════════

% REE market
reo_basket_2026    = 15000;
reo_price_floor    = 5000;
reo_demand_2026    = 400000;
reo_demand_growth  = 0.02;
reo_demand = reo_demand_2026 * (1 + reo_demand_growth).^Y;
supply_frac = reo_target ./ reo_demand;
reo_price = max(reo_price_floor, reo_basket_2026 * (1 - 0.6 * supply_frac));

% Direct revenue ($M/yr)
rev_reo = reo_target .* reo_price / 1e6;
rev_pgm = pgm_production * 50e6 / 1e6;  % $50k/kg
rev_direct = rev_reo + rev_pgm;

% Externality 1: REO mining displacement
% Total composite: $73,700/t (EEIO environmental + carbon + geopolitical)
% CO2 component: ~30 t CO2-eq per t REO (lifecycle, Frontiers 2014 / MDPI 2022)
% Non-CO2 component: water, land, radioactive waste, health
ext_reo = reo_target * 73700 / 1e6;
co2_avoided_reo = reo_target * 30;  % t CO2/yr avoided from mining lifecycle

% Externality 2: H2 enabling via Ir
% Ir and Fe-Ni are CO-PRODUCTS from the same M-type asteroid payload.
% PROBE returns 10 t enriched Fe-Ni containing PGMs at ~1,750 ppm.
% At SPA: Fe-Ni → mass driver to PKT (foundry feedstock)
%         PGM concentrate → hydromet → mass driver to Earth
% No fleet split needed — every mission serves both purposes.
%
% Green H2 applications: energy + green steel DRI + green ammonia
% H2 CO2 multiplier: ~12 t CO2/t H2 (blended across applications)
%
% MARGINAL ATTRIBUTION: Not 100% of programme Ir "enables" new PEM.
% Some PEM would be built with terrestrial Ir. Apply attribution factor.
% Baseline 50%, sensitivity at 25% and 100%.
%
% DG-11.6 CONSTRAINT: Scaling to 2,000+ PROBEs requires SEP/NEP
% propulsion (ISRU propellant caps at ~2,021 t/yr from 355 MOLE-I;
% 2,000 chemical PROBEs would need 13,308 t/yr = 6.6x shortfall).
% Additional PROBEs beyond 286 baseline are all-electric (ion drive).

ir_frac = 0.15;           % 5-25% range, mid-estimate for M-type asteroid mix
h2_attribution = 0.50;    % Marginal attribution: 50% of Ir is genuinely enabling
h2_co2_multiplier = 12;   % t CO2 avoided per t H2 (energy + steel + ammonia)
pem_gw_per_t_ir = 1.0;    % GW PEM per t Ir at 1 g/kW (conservative; future ~3 GW/t)
h2_per_gw_yr = 150000;    % t H2/yr per GW PEM at 80% capacity factor
pem_life = 20;             % years before stack replacement needs new Ir

ir_production = pgm_production * ir_frac;       % t Ir/yr from PROBE fleet
ir_attributed = ir_production * h2_attribution; % t Ir/yr genuinely enabling

pem_gw = zeros(N,1);
for i = 2:N
    pem_gw(i) = pem_gw(i-1) + ir_attributed(i) * pem_gw_per_t_ir;
    if i > pem_life
        pem_gw(i) = pem_gw(i) - ir_attributed(i-pem_life) * pem_gw_per_t_ir;
    end
    pem_gw(i) = max(0, pem_gw(i));
end
co2_avoided_h2 = pem_gw * h2_per_gw_yr * h2_co2_multiplier;  % t CO2/yr
ext_h2 = co2_avoided_h2 * scc / 1e6;

% Externality 3: Rocket emissions (negative)
% Tanker ratio declines with LEO depot maturation
% Carbon intensity declines as DAC methane production ramps on Earth
%   Y0-Y30:  100% fossil CH4 (DAC not yet at scale for rocket fuel)
%   Y30-Y45: 100%→80% (early DAC adoption, pilot plants)
%   Y45-Y60: 80%→30% (DAC scaling rapidly, SpaceX + others invest)
%   Y60-Y80: 30%→5% (DAC dominant, grid-scale renewable powered)
%   Y80+:    5% fossil (near carbon-neutral, residual process emissions)
% This creates the expected curve: rocket CO2 rises pre-Y50 (more flights
% × high fossil), peaks ~Y50, then declines as DAC overtakes volume growth.
% The Y80+ near-zero timing aligns with programme's P12 cargo ramp.
tanker_ratio = arrayfun(@(y) ...
    14*(y<25) + 8*(y>=25 & y<45) + 5*(y>=45), Y);
fossil_frac = arrayfun(@(y) ...
    1.00 * (y < 30) + ...
    max(0.80, 1.00 - (y-30)*0.0133) * (y>=30 & y<45) + ...
    max(0.30, 0.80 - (y-45)*0.0333) * (y>=45 & y<60) + ...
    max(0.05, 0.30 - (y-60)*0.0125) * (y>=60 & y<80) + ...
    0.05 * (y>=80), Y);
co2_per_launch = 2750;
cargo_flights = earth_cargo / 100;
total_launches = cargo_flights .* tanker_ratio;
co2_rockets = total_launches * co2_per_launch .* fossil_frac;
ext_rockets = -co2_rockets * scc / 1e6;

% Totals
ext_total = ext_reo + ext_h2 + ext_rockets;
rev_total = rev_direct + ext_total;

%% ═══════════════════════════════════════════════════════════════
%  7. COST MODEL
%  ═══════════════════════════════════════════════════════════════

cost_launch = earth_cargo * 1000 .* launch_cost .* contingency / 1e6;
cost_insitu = insitu_total * 1000 * insitu_cost_per_kg / 1e6;
cost_rd = arrayfun(@(y) 500*(y<25) + 1000*(y>=25&y<45) + 1500*(y>=45&y<60) + 2000*(y>=60), Y);
cost_total = cost_launch + cost_insitu + cost_rd;

%% ═══════════════════════════════════════════════════════════════
%  8. NPV & PROGRAMME METRICS
%  ═══════════════════════════════════════════════════════════════

net_total = rev_total - cost_total;
net_direct = rev_direct - cost_total;
npv_total = cumsum(net_total .* df);
npv_direct = cumsum(net_direct .* df);

cum_cost = cumsum(cost_total);
cum_rev = cumsum(rev_total);
cum_rev_dir = cumsum(rev_direct);

be_total = find(cumsum(rev_total - cost_total) > 0, 1, 'first');
be_direct = find(cumsum(rev_direct - cost_total) > 0, 1, 'first');

fprintf('═══════════════════════════════════════════════\n');
fprintf('  PROGRAMME METRICS (100-YEAR)\n');
fprintf('═══════════════════════════════════════════════\n\n');
fprintf('Total cost:                 $%.2f T\n', cum_cost(end)/1e6);
fprintf('Direct revenue:             $%.2f T\n', cum_rev_dir(end)/1e6);
fprintf('REO extern (mining):        $%.2f T\n', sum(ext_reo)/1e6);
fprintf('H2 extern (Ir→PEM):         $%.2f T\n', sum(ext_h2)/1e6);
fprintf('Rocket emissions:           $%.2f T\n', sum(ext_rockets)/1e6);
fprintf('Total revenue + extern:     $%.2f T\n', cum_rev(end)/1e6);
fprintf('NPV (all extern):           $%.2f T\n', npv_total(end)/1e6);
fprintf('NPV (direct only):          $%.2f T\n', npv_direct(end)/1e6);
fprintf('Earth cargo (100 yr):       %.0f t (%.1f Mt)\n', sum(earth_cargo), sum(earth_cargo)/1e6);
fprintf('Starship flights (cargo):   ~%.0f\n', sum(earth_cargo)/100);
fprintf('Total launches (+ tankers): ~%.0f\n', sum(total_launches));
fprintf('Lifetime rocket CO2:        %.0f Mt\n', sum(co2_rockets)/1e6);
if ~isempty(be_total), fprintf('Breakeven (with extern):    Y%d\n', Y(be_total));
else, fprintf('Breakeven (with extern):    NOT REACHED\n'); end
if ~isempty(be_direct), fprintf('Breakeven (direct only):    Y%d\n', Y(be_direct));
else, fprintf('Breakeven (direct only):    NOT REACHED\n'); end

% Infrastructure at key years
fprintf('\n--- Infrastructure at Phase Boundaries ---\n');
check_years = [20 25 30 35 45 60 80 100];
fprintf('%-6s %8s %8s %8s %6s %6s %8s %8s %8s\n', ...
    'Year', 'REO t/y', 'Circuits', 'Haulers', 'MSR', 'FSP', 'Conv km', 'MOLE-I', 'PROBEs');
for y = check_years
    i = y+1;
    fprintf('Y%-5d %8.0f %8d %8d %6d %6d %8.0f %8d %8d\n', ...
        y, reo_target(i), circuits_needed(i), haulers_needed(i), ...
        msr_count(i), fsp_count(i), conv_km_needed(i), molei_needed(i), probe_fleet(i));
end

% Cost per tonne REO
fprintf('\n--- Cost per tonne REO ---\n');
for y = check_years
    i = y+1;
    if reo_target(i) > 0.1
        cpt = cost_total(i) * 1e6 / reo_target(i);
        fprintf('  Y%d: $%s/t REO\n', y, num2str(round(cpt)));
    end
end

% Cargo breakdown at P8 and P12
fprintf('\n--- Earth Cargo Breakdown at Y30 (P8) ---\n');
i30 = 31;
fprintf('  Circuits:      %.0f t\n', cargo_circuits(i30));
fprintf('  Haulers:       %.0f t\n', cargo_haulers(i30));
fprintf('  MSR:           %.0f t\n', cargo_msr(i30));
fprintf('  FSP:           %.0f t\n', cargo_fsp(i30));
fprintf('  MOLE-I:        %.0f t\n', cargo_molei(i30));
fprintf('  Reagent:       %.0f t\n', cargo_reagent(i30));
fprintf('  Maintenance:   %.0f t\n', maint_circuits(i30)+maint_haulers(i30));
fprintf('  SPA ops:       %.0f t\n', cargo_spa_ops(i30));
fprintf('  TOTAL:         %.0f t\n', earth_cargo(i30));

fprintf('\n--- Earth Cargo Breakdown at Y90 (P12 midpoint) ---\n');
i90 = 91;
fprintf('  Circuits:      %.0f t (Earth frac %.0f%%)\n', cargo_circuits(i90), circuit.earth_frac(Y(i90))*100);
fprintf('  Haulers:       %.0f t (Earth frac %.0f%%)\n', cargo_haulers(i90), hauler.earth_frac(Y(i90))*100);
fprintf('  Conveyors:     %.0f t\n', cargo_conveyors(i90));
fprintf('  Canisters:     %.0f t\n', cargo_canisters(i90));
fprintf('  MSR:           %.0f t (Earth frac %.0f%%)\n', cargo_msr(i90), msr.earth_frac(Y(i90))*100);
fprintf('  MOLE-I:        %.0f t\n', cargo_molei(i90));
fprintf('  Reagent:       %.0f t (ISRU %.0f%%)\n', cargo_reagent(i90), reagent.isru_frac(Y(i90))*100);
fprintf('  Maint (all):   %.0f t\n', maint_circuits(i90)+maint_haulers(i90)+maint_conv(i90)+maint_msr(i90));
fprintf('  SPA ops:       %.0f t\n', cargo_spa_ops(i90));
fprintf('  TOTAL:         %.0f t = %.0f Starship flights\n', earth_cargo(i90), earth_cargo(i90)/100);

fprintf('\n--- Earth Cargo Breakdown at Y100 (1 Mt/yr target) ---\n');
i100 = 101;
fprintf('  Circuits:      %.0f t (Earth frac %.0f%%)\n', cargo_circuits(i100), circuit.earth_frac(Y(i100))*100);
fprintf('  Haulers:       %.0f t (Earth frac %.0f%%)\n', cargo_haulers(i100), hauler.earth_frac(Y(i100))*100);
fprintf('  Conveyors:     %.0f t\n', cargo_conveyors(i100));
fprintf('  Canisters:     %.0f t\n', cargo_canisters(i100));
fprintf('  MSR:           %.0f t (Earth frac %.0f%%)\n', cargo_msr(i100), msr.earth_frac(Y(i100))*100);
fprintf('  MOLE-I:        %.0f t\n', cargo_molei(i100));
fprintf('  Reagent:       %.0f t (ISRU %.0f%%)\n', cargo_reagent(i100), reagent.isru_frac(Y(i100))*100);
fprintf('  Maint (all):   %.0f t\n', maint_circuits(i100)+maint_haulers(i100)+maint_conv(i100)+maint_msr(i100));
fprintf('  SPA ops:       %.0f t\n', cargo_spa_ops(i100));
fprintf('  TOTAL:         %.0f t = %.0f Starship flights\n', earth_cargo(i100), earth_cargo(i100)/100);

% Environmental balance at P12
fprintf('\n--- Environmental Balance at Y90 (P12 midpoint) ---\n');
fprintf('  REO production:               %.0f t/yr\n', reo_target(i90));
fprintf('  PGM production:               %.1f t/yr (%.0f PROBEs)\n', pgm_production(i90), probe_fleet(i90));
fprintf('  Ir production:                %.2f t/yr (%.0f%% of PGM)\n', ir_production(i90), ir_frac*100);
fprintf('  Ir attributed (%.0f%%):          %.2f t/yr\n', h2_attribution*100, ir_attributed(i90));
fprintf('  REO extern:    $%.1fB/yr\n', ext_reo(i90)/1e3);
fprintf('  H2 extern:     $%.1fB/yr (%.0f%% attribution)\n', ext_h2(i90)/1e3, h2_attribution*100);
fprintf('  Rockets:       $%.1fB/yr\n', ext_rockets(i90)/1e3);
fprintf('  NET:           $%.1fB/yr\n', ext_total(i90)/1e3);
fprintf('  PEM installed: %.1f GW (from attributed Ir)\n', pem_gw(i90));
fprintf('  CO2 avoided (REE mining): %.1f Mt/yr\n', co2_avoided_reo(i90)/1e6);
fprintf('  CO2 avoided (H2 via Ir):  %.1f Mt/yr\n', co2_avoided_h2(i90)/1e6);
fprintf('  CO2 from rockets:         %.1f Mt/yr (fossil frac %.0f%%)\n', ...
    co2_rockets(i90)/1e6, fossil_frac(i90)*100);
fprintf('  NET CO2 balance:          %.1f Mt/yr\n', ...
    (co2_avoided_reo(i90)+co2_avoided_h2(i90)-co2_rockets(i90))/1e6);

i100 = 101;
fprintf('\n--- Environmental Balance at Y100 (P12 target: 1 Mt/yr REO) ---\n');
fprintf('  REO production:               %.0f t/yr\n', reo_target(i100));
fprintf('  PGM production:               %.1f t/yr (%.0f PROBEs)\n', pgm_production(i100), probe_fleet(i100));
fprintf('  Ir production:                %.2f t/yr → attributed: %.2f t/yr\n', ir_production(i100), ir_attributed(i100));
fprintf('  NOTE: Ir and Fe-Ni are co-products (same M-type asteroid payload)\n');
fprintf('  Fe-Ni to PKT foundry:         %.0f t/yr\n', probe_fleet(i100)*10);  % 10t Fe-Ni per PROBE
fprintf('  REO extern:    $%.1fB/yr\n', ext_reo(i100)/1e3);
fprintf('  H2 extern:     $%.1fB/yr (%.0f%% attribution)\n', ext_h2(i100)/1e3, h2_attribution*100);
fprintf('  Rockets:       $%.1fB/yr\n', ext_rockets(i100)/1e3);
fprintf('  NET:           $%.1fB/yr\n', ext_total(i100)/1e3);
fprintf('  PEM installed: %.1f GW (from attributed Ir)\n', pem_gw(i100));
fprintf('  CO2 avoided (REE mining): %.1f Mt/yr\n', co2_avoided_reo(i100)/1e6);
fprintf('  CO2 avoided (H2 via Ir):  %.1f Mt/yr\n', co2_avoided_h2(i100)/1e6);
fprintf('  CO2 from rockets:         %.1f Mt/yr (fossil frac %.0f%%)\n', ...
    co2_rockets(i100)/1e6, fossil_frac(i100)*100);
fprintf('  NET CO2 balance:          %.1f Mt/yr\n', ...
    (co2_avoided_reo(i100)+co2_avoided_h2(i100)-co2_rockets(i100))/1e6);
fprintf('  Direct revenue at Y100:   $%.1fB/yr (REO $%.0f/t × %.0f t + PGM)\n', ...
    rev_direct(i100)/1e3, reo_price(i100), reo_target(i100));
fprintf('  Annual cost at Y100:      $%.1fB/yr\n', cost_total(i100)/1e3);
fprintf('  Revenue/Cost ratio:       %.2f (direct), %.2f (with extern)\n', ...
    rev_direct(i100)/cost_total(i100), rev_total(i100)/cost_total(i100));

%% ═══════════════════════════════════════════════════════════════
%  9. SENSITIVITY ANALYSIS
%  ═══════════════════════════════════════════════════════════════

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  SENSITIVITY ANALYSIS\n');
fprintf('═══════════════════════════════════════════════\n');

baseline_npv = npv_total(end)/1e6;

% Canister options
can_options = [73, 28, 8];  % kg Earth per canister
can_labels = {'Full parachute', 'Minimal chute (baseline)', 'Shuttlecock'};
npv_can = zeros(3,1);
for k = 1:3
    cargo_can_k = canisters_yr * can_options(k) / 1000;
    ec_k = earth_cargo - cargo_canisters + cargo_can_k;
    cl_k = ec_k * 1000 .* launch_cost .* contingency / 1e6;
    ct_k = cl_k + cost_insitu + cost_rd;
    npv_can(k) = sum((rev_total - ct_k) .* df);
end
fprintf('\nCanister recovery:\n');
for k = 1:3
    fprintf('  %s: NPV $%.2fT (delta $%.2fT)\n', can_labels{k}, npv_can(k)/1e6, (npv_can(k)/1e6 - baseline_npv));
end

% Discount rate sensitivity
dr_flat = [0.014 0.020 0.030 0.035];
dr_labels = {'Stern 1.4%', 'Flat 2.0%', 'Flat 3.0%', 'UK Green 3.5%'};
for k = 1:4
    df_k = cumprod(1./(1+dr_flat(k)*ones(N,1)));
    npv_k = sum(net_total .* df_k);
    fprintf('  %s: NPV $%.2fT\n', dr_labels{k}, npv_k/1e6);
end

% Launch cost sensitivity
fprintf('\nLaunch cost:\n');
for mult = [1.5, 1.0, 0.5]
    cl_k = earth_cargo * 1000 .* (launch_cost * mult) .* contingency / 1e6;
    ct_k = cl_k + cost_insitu + cost_rd;
    npv_k = sum((rev_total - ct_k) .* df);
    fprintf('  %.0f%%: NPV $%.2fT\n', mult*100, npv_k/1e6);
end

% H2 attribution sensitivity
fprintf('\nH2 marginal attribution (Ir enabling):\n');
attr_options = [0.25, 0.50, 1.00];
attr_labels = {'25% (conservative)', '50% (baseline)', '100% (all marginal)'};
for k = 1:3
    ir_attr_k = ir_production * attr_options(k);
    pem_k = zeros(N,1);
    for i = 2:N
        pem_k(i) = pem_k(i-1) + ir_attr_k(i) * pem_gw_per_t_ir;
        if i > pem_life, pem_k(i) = pem_k(i) - ir_attr_k(i-pem_life) * pem_gw_per_t_ir; end
        pem_k(i) = max(0, pem_k(i));
    end
    ext_h2_k = pem_k * h2_per_gw_yr * h2_co2_multiplier * scc / 1e6;
    rev_k = rev_direct + ext_reo + ext_h2_k + ext_rockets;
    npv_k = sum((rev_k - cost_total) .* df);
    fprintf('  %s: NPV $%.2fT (H2 extern $%.2fT)\n', attr_labels{k}, npv_k/1e6, sum(ext_h2_k)/1e6);
end

% DG-11.6: PROBE Mk III SEP fleet (never lands, LLO canister ejection)
% 286 Mk I/II (chemical, land at SPA, 1 mission/yr, ISRU propellant)
% + 1,714 Mk III SEP (ion drive, never land, 0.5 missions/yr, NO ISRU)
% Mk III ejects Fe-Ni/PGM canisters from LLO → EM catcher at SPA
% Fe-Ni and Ir are co-products from same M-type asteroid payload
% Total returns: 286×10t + 1,714×10t×0.5 = 2,860 + 8,570 = 11,430 t/yr Fe-Ni
fprintf('\nDG-11.6 PROBE Mk III SEP fleet (1,714 Mk III + 286 Mk I/II):\n');
% Mk III PGM: 1,714 × 17.5 kg × 0.5 missions/yr = 15 t/yr additional PGM
% Total PGM: 5 t/yr (Mk I/II) + 15 t/yr (Mk III) = 20 t/yr
pgm_mkiii = probe_fleet * probe.pgm_per_mission;  % baseline Mk I/II
for i = 1:N
    if Y(i) >= 60  % DG-11.6 triggered at P11
        mkiii_active = min(1714, (Y(i)-60)/10 * 1714);  % ramp over 10 years
        pgm_mkiii(i) = pgm_mkiii(i) + mkiii_active * probe.pgm_per_mission * 0.5;
    end
end
ir_mkiii = pgm_mkiii * ir_frac * h2_attribution;
pem_mkiii = zeros(N,1);
for i = 2:N
    pem_mkiii(i) = pem_mkiii(i-1) + ir_mkiii(i) * pem_gw_per_t_ir;
    if i > pem_life, pem_mkiii(i) = pem_mkiii(i) - ir_mkiii(i-pem_life) * pem_gw_per_t_ir; end
    pem_mkiii(i) = max(0, pem_mkiii(i));
end
ext_h2_mkiii = pem_mkiii * h2_per_gw_yr * h2_co2_multiplier * scc / 1e6;

% Additional cost: Mk III PROBEs (Earth-built, ~1,200 kg, larger solar arrays)
% Launched to LLO — no lunar surface delivery needed
% LEO→LLO transfer via SEP tug (reusable), so launch cost = LEO only (~$500/kg)
cost_mkiii = zeros(N,1);
for i = 1:N
    if Y(i) >= 60
        mkiii_build_rate = min(1714/10, 1714/10);  % ~171/yr during build-out
        mkiii_replace = min(1714, (Y(i)-60)/10 * 1714) / 15;  % 15-yr life
        cost_mkiii(i) = (mkiii_build_rate + mkiii_replace) * 1.2 * 500 * contingency(i) / 1e6;
        % 1.2 t per Mk III × $500/kg to LEO × contingency
    end
end

rev_mkiii_pgm = pgm_mkiii * 50e6 / 1e6;
rev_mkiii_total = rev_mkiii_pgm - rev_pgm + rev_direct + ext_reo + ext_h2_mkiii + ext_rockets;
npv_mkiii = sum((rev_mkiii_total - cost_total - cost_mkiii) .* df);

fprintf('  NPV: $%.2fT (delta $%.2fT from baseline)\n', npv_mkiii/1e6, (npv_mkiii/1e6 - baseline_npv));
fprintf('  H2 extern: $%.2fT | PGM revenue: $%.2fT\n', sum(ext_h2_mkiii)/1e6, sum(rev_mkiii_pgm)/1e6);
fprintf('  Mk III fleet cost: $%.2fT (LEO launch only, no lunar delivery)\n', sum(cost_mkiii)/1e6);
fprintf('  PGM at P12: %.1f t/yr (Mk I/II: %.1f + Mk III: %.1f)\n', ...
    pgm_mkiii(91), pgm_production(91), pgm_mkiii(91)-pgm_production(91));
fprintf('  Ir at P12: %.1f t/yr (attributed: %.1f at %.0f%%)\n', ...
    pgm_mkiii(91)*ir_frac, pgm_mkiii(91)*ir_frac*h2_attribution, h2_attribution*100);
fprintf('  Fe-Ni to PKT: %.0f t/yr (Mk I/II land + Mk III EM catch)\n', ...
    probe_fleet(91)*10 + min(1714, (Y(91)-60)/10*1714)*10*0.5);
fprintf('  MOLE-I: unchanged at ~355 (Mk III uses NO ISRU propellant)\n');
fprintf('  Mk III never lands — EM catcher at SPA receives canisters from LLO\n');

%% ═══════════════════════════════════════════════════════════════
%  10. FIGURES
%  ═══════════════════════════════════════════════════════════════

% Figure 1: Overview 4-panel
fig1 = figure('Position', [50 50 1200 700], 'Color', [0.03 0.06 0.1]);
axcolor = [0.05 0.08 0.12]; txcolor = [0.7 0.8 0.9]; gcolor = [0.15 0.2 0.3];

subplot(2,2,1);
semilogy(Y, max(cost_total,0.1), 'r-', 'LineWidth', 2); hold on;
semilogy(Y, max(rev_total,0.1), 'g-', 'LineWidth', 2);
semilogy(Y, max(rev_direct,0.01), 'g--', 'LineWidth', 1.5);
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('Cost vs Revenue', 'Color', [.9 .95 1]);
xlabel('Year'); ylabel('$M/yr'); legend('Cost','Rev+Ext','Direct','Location','se','FontSize',7);

subplot(2,2,2);
plot(Y, npv_total/1e6, 'g-', 'LineWidth', 2); hold on;
plot(Y, npv_direct/1e6, 'g--', 'LineWidth', 1.5); yline(0,'w--');
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('Cumulative NPV ($T)', 'Color', [.9 .95 1]);
xlabel('Year'); ylabel('$T'); legend('With Extern','Direct Only','Location','nw');

subplot(2,2,3);
bar(Y, earth_cargo/1000, 1, 'FaceColor', [.2 .5 .8], 'EdgeColor', 'none');
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('Earth Cargo (kt/yr)', 'Color', [.9 .95 1]);
xlabel('Year'); ylabel('kt/yr');

subplot(2,2,4);
semilogy(Y, max(reo_target,0.01), 'c-', 'LineWidth', 2);
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); ylim([0.01 2e6]);
title('REO Production', 'Color', [.9 .95 1]); xlabel('Year'); ylabel('t/yr');
sgtitle('SELENITE v1.2 — Bottom-Up Economic Model', 'Color', [.9 .95 1], 'FontSize', 14);
saveas(fig1, 'SELENITE_ECON_v1_2_overview.png');

% Figure 2: Infrastructure scaling
fig2 = figure('Position', [100 100 1200 500], 'Color', [0.03 0.06 0.1]);
subplot(1,2,1);
semilogy(Y, max(circuits_needed,0.1), 'r-', 'LineWidth', 2); hold on;
semilogy(Y, max(haulers_needed,0.1), 'g-', 'LineWidth', 2);
semilogy(Y, max(molei_needed,0.1), 'c-', 'LineWidth', 2);
semilogy(Y, max(probe_fleet,0.1), 'm-', 'LineWidth', 2);
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('Fleet Scaling', 'Color', [.9 .95 1]);
legend('Circuits','Haulers','MOLE-I','PROBEs','Location','se','FontSize',8);

subplot(1,2,2);
yyaxis left;
plot(Y, conv_km_needed, 'g-', 'LineWidth', 2);
ylabel('Conveyor (km)'); set(gca, 'YColor', [.3 .8 .3]);
yyaxis right;
plot(Y, msr_count, 'm-', 'LineWidth', 2);
ylabel('MSR count'); set(gca, 'YColor', [.8 .3 .8]);
set(gca, 'Color', axcolor, 'XColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('Conveyor + MSR Scaling', 'Color', [.9 .95 1]);
sgtitle('SELENITE — Infrastructure Derived from REO Targets', 'Color', [.9 .95 1], 'FontSize', 14);
saveas(fig2, 'SELENITE_ECON_v1_2_infrastructure.png');

% Figure 3: Environmental
fig3 = figure('Position', [150 150 1200 500], 'Color', [0.03 0.06 0.1]);
subplot(1,2,1);
plot(Y, ext_reo/1e3, 'g-', 'LineWidth', 2); hold on;
plot(Y, ext_h2/1e3, 'b-', 'LineWidth', 2);
plot(Y, ext_rockets/1e3, 'r-', 'LineWidth', 2);  % Already negative from -co2*scc
plot(Y, ext_total/1e3, 'w-', 'LineWidth', 2.5);
yline(0, 'w:', 'LineWidth', 0.5);
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('Environmental Externalities ($B/yr)', 'Color', [.9 .95 1]);
legend('REO Mining Avoided','H2 via Ir','Rockets (neg)','NET','Location','nw','FontSize',7);

subplot(1,2,2);
plot(Y, co2_avoided_reo/1e6, 'g-', 'LineWidth', 2); hold on;
plot(Y, co2_avoided_h2/1e6, 'b-', 'LineWidth', 2);
plot(Y, -co2_rockets/1e6, 'r-', 'LineWidth', 2);  % NEGATIVE — emissions below zero
plot(Y, (co2_avoided_reo + co2_avoided_h2 - co2_rockets)/1e6, 'w-', 'LineWidth', 2.5);
yline(0, 'w:', 'LineWidth', 0.5);
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); title('CO2 Balance (Mt/yr)', 'Color', [.9 .95 1]);
legend('Avoided: REE Mining','Avoided: H2 (Ir)','Rockets (neg)','NET','Location','nw','FontSize',7);
sgtitle('SELENITE — Environmental Accounting', 'Color', [.9 .95 1], 'FontSize', 14);
saveas(fig3, 'SELENITE_ECON_v1_2_environmental.png');

% Figure 4: Cargo breakdown stacked
fig4 = figure('Position', [200 200 1200 500], 'Color', [0.03 0.06 0.1]);
cargo_stack = [cargo_circuits, cargo_haulers, cargo_conveyors, cargo_canisters, ...
               cargo_msr+cargo_fsp, cargo_reagent, cargo_molei+cargo_probes, ...
               maint_circuits+maint_haulers+maint_conv+maint_msr, ...
               cargo_spa_ops+cargo_construction+cargo_ybco];
h = area(Y, cargo_stack/1000);
colors = {[.8 .2 .2],[.2 .7 .3],[.4 .6 .2],[.8 .6 .2],[.6 .3 .7],[.2 .5 .8],[.7 .4 .2],[.5 .5 .5],[.3 .3 .6]};
labels = {'Circuits','Haulers','Conveyors','Canisters','Power (MSR+FSP)','Reagent','MOLE-I+PROBE','Maintenance','SPA+Constr+YBCO'};
for j=1:9, h(j).FaceColor=colors{j}; h(j).EdgeColor='none'; h(j).FaceAlpha=0.85; end
set(gca, 'Color', axcolor, 'XColor', txcolor, 'YColor', txcolor, 'GridColor', gcolor);
grid on; xlim([0 100]); ylabel('Earth Cargo (kt/yr)');
title('Earth Cargo by Category — Derived from Infrastructure Requirements', 'Color', [.9 .95 1], 'FontSize', 13);
legend(labels, 'Location','northwest','FontSize',7,'TextColor',txcolor,'Color',[.08 .12 .18]);
saveas(fig4, 'SELENITE_ECON_v1_2_cargo_breakdown.png');

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  SELENITE_ECON v1.2 COMPLETE — 4 figures saved\n');
fprintf('  All cargo derived from unit specs × fleet deltas\n');
fprintf('═══════════════════════════════════════════════\n');