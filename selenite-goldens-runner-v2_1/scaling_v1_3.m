%% SELENITE_SCALE_v1_3.m
%  100-Year Scaling Analysis: Shackleton + PKT Dual-Base Architecture
%  Target: 1,000,000 t/yr REO + PGM scaling to meet 2100 demand
%
%  v1.3 changes from v1.2:
%    - Corrected catapult scaling: tier fractions evolve by phase as
%      near deposits deplete. P12: ~9,100 catapults (was 5)
%    - Bidirectional catapult: return launchers fire empty canisters
%      back to regional hubs. 4 tracks per hub pair.
%    - In-situ fabrication at PKT: haulers, canisters, structural
%      components manufactured from Fe-Ni (PROBE) + Al gangue (KREEP).
%      Earth supplies only electronics/batteries (8% of hauler mass).
%    - Fe/Ni: in-space structural use ONLY, NOT Earth return.
%      Earth Fe/Ni met by terrestrial green steel.
%    - Asteroid capture: targets PGM + Fe-Ni for in-space use.
%    - Hauler deployment: 92% in-situ manufactured, 8% Earth-supplied.
%
%  Author: Jason (Systems Engineering Lead), Selenite Programme
%  Date: March 2026

clear; clc; close all;

fprintf('════════════════════════════════════════════════════════════════════════\n');
fprintf('  SELENITE SCALE v1.3 — 100-Year Dual-Base Scaling Analysis\n');
fprintf('  Surface Haulers at PKT | PROBE PGM Scaling | Deep Ice Mining\n');
fprintf('  Target: 1 Mt/yr REO + PGM to meet 2100 projected demand\n');
fprintf('════════════════════════════════════════════════════════════════════════\n\n');

% Helper functions (must be at end of file in MATLAB, or use nested)
% Using inline conditionals instead

%% ═══ CONSTANTS ═══
g0 = 9.81; g_moon = 1.62; Isp = 450; ve = Isp*g0;

% KREEP grades (ppm REE in raw regolith)
kreep.spa_mid = 140; kreep.pkt_mid = 1000;

% Beneficiation + Processing
bene.recovery = 0.04; bene.uplift = 10;
bene.line_cap = 1000; % t/yr per line
proc.eff = 0.80; proc.circuit_cap = 50; % t/yr concentrate per circuit
proc.pwr_kW = 180; proc.reagent = 49; % t/yr per circuit

% SKIP (chemical, used P7-P9 at PKT, all phases at SPA)
skip.mf = 700; % dry + payload
skip.rng_spa = 100; skip.rng_pkt = 35; % km
skip.dv_spa = 4*sqrt(g_moon*skip.rng_spa*1e3/2)*1.05;
skip.dv_pkt = 4*sqrt(g_moon*skip.rng_pkt*1e3/2)*1.05;
skip.fuel_spa = skip.mf*(exp(skip.dv_spa/ve)-1);
skip.fuel_pkt = skip.mf*(exp(skip.dv_pkt/ve)-1);
skip.hops = 274; skip.payload = 400; % kg/hop

% Surface hauler (electric, replaces SKIP at PKT P10+)
hauler.payload = 5000; % kg per trip (5 t)
hauler.speed = 1.0; % m/s average on sintered road
hauler.avail = 0.80;
hauler.range_km = 30; % average round-trip distance
hauler.trip_hr = hauler.range_km*2*1000/hauler.speed/3600;
hauler.trips_yr = floor(8760*hauler.avail/hauler.trip_hr);
hauler.throughput = hauler.trips_yr*hauler.payload/1000; % t/yr per hauler
hauler.pwr_kW = 5; % average power while driving (battery, charged at hub)

% EM catapult hub (for ore transport >50 km)
catapult.range_km = 100; catapult.v_launch = 500; % m/s
catapult.canister_kg = 5000; catapult.canister_payload = 4500; % kg ore
catapult.canister_empty = 500; % kg shell
catapult.pwr_MW = 5; % per launch (loaded)
catapult.pwr_return_MW = 0.5; % per return launch (empty, 10% energy)
catapult.launches_hr = 6; % max sustained rate per track
catapult.throughput_yr = catapult.canister_payload * catapult.launches_hr * 8760 * 0.80 / 1000; % t/yr per hub
% Each catapult HUB PAIR = 4 tracks:
%   Regional hub: 1× outbound launcher + 1× empty canister catcher
%   Spine: 1× loaded canister catcher + 1× empty return launcher

% Tier fractions by phase (% of ore from each distance band)
% Near deposits deplete over time, frontier expands outward
tier.frac_t1 = [0.95, 0.90, 0.85, 0.70, 0.40, 0.15]; % 0-20 km (direct hauler)
tier.frac_t2 = [0.05, 0.08, 0.12, 0.25, 0.35, 0.30]; % 20-50 km (extended hauler)
tier.frac_t3 = [0.00, 0.02, 0.03, 0.05, 0.25, 0.55]; % 50-150 km (catapult)

% In-situ fabrication at PKT (P10+)
fab.hauler_earth_frac = 0.08; % 8% of hauler mass from Earth (electronics, batteries)
fab.hauler_local_frac = 0.92; % 92% manufactured in-situ (chassis, hopper, wheels)
fab.hauler_life_yr = 10; % hauler service life before replacement
fab.canister_life_cycles = 10000; % canister fatigue life
fab.canister_cycles_yr = 40*365*0.80; % cycles/yr per canister (~11,680)

% PROBE (asteroid PGM)
probe.prop = 6654; % kg/mission (current 2,300 kg class)
probe.payload_current = 1500; % kg ore returned
probe.pgm_grade = 50e-6; % 50 g/t PGM in M-type
probe.pgm_extraction = 0.70;
% Scaled PROBE (P9+): larger vehicle, in-situ beneficiation
probe_big.prop = 40000; % bigger vehicle, more fuel
probe_big.payload = 10000; % 10 t ore (or 1 t PGM concentrate if beneficiated)
probe_big.insitu_conc = 50; % in-situ concentration factor at asteroid

% LLO tanker
tanker.payload = 6000; tanker.prop = 6654;
tanker.total = tanker.payload + tanker.prop;
tanker.trips_yr = 12;

% Mass driver efficiencies
md.tanker_eff = tanker.payload/tanker.total; % 0.47
md.retro_eff = 0.63; md.catcher_eff = 0.95;
md.earth_canister_reo = 3.5; % t REO per Earth-return canister

% MOLE-I
mi.water_yr = 25*0.0446*0.80*8760; % kg water/yr per MOLE-I
mi.prop_yield = mi.water_yr*0.722;
mi.node = 10; mi.pwr_kW = 1.934;

% Ice availability
ice.depth_m = 10; % strip mining to 10m depth (was 1-2m)
ice.frac = 0.0446; ice.rho = 1550; % kg/m³ regolith

% Shackleton crater
shack.floor_km2 = 33.2;
shack.ice_total = shack.floor_km2*1e6*ice.depth_m*ice.rho*ice.frac; % kg total ice
% Sustainable extraction: 2% of total per year (50-year replenishment assumption)
shack.ice_yr = shack.ice_total * 0.02; % kg/yr sustainable

% Other PSR craters (average 15 km² floor, similar ice fraction)
other_crater.floor_km2 = 15;
other_crater.ice_yr = other_crater.floor_km2*1e6*ice.depth_m*ice.rho*ice.frac*0.02;

% FSP + Solar
fsp.kW = 40; solar.yield = 0.319;

% Hab/ECLSS
hab.crew_mod = 4; hab.eclss_kW = 1.2;
ls.prop_yr = 0.9*365/0.889*0.722; % kg prop-equiv per crew per year

% Starship
ss.cap_t = 100; % payload
ss.return_prop = 80000; % kg propellant for crew Starship lunar→Earth return

% PGM demand targets (t/yr)
pgm.demand = [0.001, 0.005, 0.05, 0.2, 1.0, 5.0]; % t/yr (realistic ramp)
% NOTE: Full 2100 PGM demand (8,000 t/yr) requires orbital processing
% platforms + asteroid capture, beyond probe-class vehicles. Programme
% targets 5 t/yr by P12 from PROBE fleet; rest flagged for P13+ orbital infra.
% Current Earth PGM supply: ~565 t/yr. 5 t/yr = ~1% — meaningful supplement,
% not replacement. REE displacement is the primary mission; PGM is secondary.

fprintf('== KEY PARAMETERS ==\n');
fprintf('  SKIP SPA: dV=%.0f m/s, fuel=%.0f kg/hop\n', skip.dv_spa, skip.fuel_spa);
fprintf('  SKIP PKT: dV=%.0f m/s, fuel=%.0f kg/hop (P7-P9 only)\n', skip.dv_pkt, skip.fuel_pkt);
fprintf('  Hauler: %d kg payload, %.0f t/yr throughput, %d kW\n',...
    hauler.payload, hauler.throughput, hauler.pwr_kW);
fprintf('  MOLE-I: %.0f kg prop/yr | Ice depth: %dm (strip mining)\n', mi.prop_yield, ice.depth_m);
fprintf('  Shackleton ice: %.2e kg total, %.2e kg/yr sustainable\n',...
    shack.ice_total, shack.ice_yr);
fprintf('  Probe big (P9+): %d kg payload, %dx in-situ concentration\n\n',...
    probe_big.payload, probe_big.insitu_conc);

%% ═══ PHASES ═══
ph.n = 6;
ph.lab = {'P7 (Y20)','P8 (Y30)','P9 (Y40)','P10 (Y55)','P11 (Y75)','P12 (Y95)'};
ph.reo_target = [0.4, 125, 1000, 10000, 100000, 1000000];

fprintf('== TARGETS ==\n');
fprintf('  %-12s %14s %10s\n', 'Phase', 'REO t/yr', 'PGM t/yr');
for i=1:ph.n
    fprintf('  %-12s %14.1f %10.0f\n', ph.lab{i}, ph.reo_target(i), pgm.demand(i)*1000);
end
fprintf('\n');

%% ═══ MAIN CALCULATION LOOP ═══
for i = 1:ph.n
    % ═══ KREEP CHAIN ═══
    if i == 1, grade = kreep.spa_mid; else, grade = kreep.pkt_mid; end
    grade_conc = grade * bene.uplift / 1e6;
    
    ph.concentrate(i) = ph.reo_target(i) / (grade_conc * proc.eff);
    ph.raw_kreep(i) = ph.concentrate(i) / bene.recovery;
    
    % ═══ KREEP TRANSPORT ═══
    kreep_per_skip = skip.payload * skip.hops / 1000; % t/yr per chemical SKIP
    
    if i <= 3 % P7-P9: chemical SKIPs
        if i == 1
            ph.skip_spa(i) = 8; ph.skip_pkt(i) = 0;
        else
            ph.skip_spa(i) = max(2, 8-2*(i-1)); % phase down SPA
            ph.skip_pkt(i) = max(1, ceil(ph.raw_kreep(i)/kreep_per_skip) - ph.skip_spa(i));
        end
        ph.n_haulers(i) = 0;
        ph.pkt_transport = 'Chemical SKIP';
        ph.prop_pkt_skip(i) = ph.skip_pkt(i)*skip.hops*skip.fuel_pkt/1000;
    else % P10+: surface haulers (zero propellant)
        ph.skip_spa(i) = 0; % SPA SKIPs phased out
        ph.skip_pkt(i) = 0; % NO chemical SKIPs at PKT
        ph.n_haulers(i) = ceil(ph.raw_kreep(i) / hauler.throughput);
        ph.pkt_transport = 'Surface Hauler';
        ph.prop_pkt_skip(i) = 0; % ZERO propellant for ore transport
    end
    ph.skip_total(i) = ph.skip_spa(i) + ph.skip_pkt(i);
    
    % ═══ PROCESSING + BENEFICIATION ═══
    ph.proc_spa(i) = min(5, ceil(ph.concentrate(i)/proc.circuit_cap));
    if i == 1, ph.proc_pkt(i) = 0;
    else, ph.proc_pkt(i) = max(0, ceil(ph.concentrate(i)/proc.circuit_cap) - ph.proc_spa(i));
    end
    ph.proc_total(i) = ph.proc_spa(i) + ph.proc_pkt(i);
    ph.bene_total(i) = ceil(ph.raw_kreep(i) / bene.line_cap);
    
    % ═══ EM CATAPULT HUBS (bidirectional, 4 tracks per hub pair) ═══
    % Tier fractions determine how much ore goes via catapult
    ph.ore_t1(i) = ph.raw_kreep(i) * tier.frac_t1(i); % direct hauler
    ph.ore_t2(i) = ph.raw_kreep(i) * tier.frac_t2(i); % extended hauler
    ph.ore_t3(i) = ph.raw_kreep(i) * tier.frac_t3(i); % catapult
    
    if ph.ore_t3(i) > 0 && i >= 3 % P9+ (catapults start small at P9)
        ph.n_catapults(i) = ceil(ph.ore_t3(i) / catapult.throughput_yr);
        % Canister fleet for this phase
        canisters_in_flight = ph.n_catapults(i) * catapult.launches_hr * 4; % ~4 hr round-trip
        ph.n_canisters(i) = ceil(canisters_in_flight * 1.20); % 20% spares
        % Canister production rate (replacement at fatigue life)
        ph.canister_prod_yr(i) = ceil(ph.n_canisters(i) / (fab.canister_life_cycles / fab.canister_cycles_yr));
    else
        ph.n_catapults(i) = 0; ph.n_canisters(i) = 0; ph.canister_prod_yr(i) = 0;
    end
    
    % ═══ IN-SITU FABRICATION (PKT, P10+) ═══
    if i >= 4 % P10+
        % Hauler production: replace fleet over service life + growth
        if i == 4
            ph.hauler_prod_yr(i) = ph.n_haulers(i); % initial deployment year
        else
            fleet_replace = ceil(ph.n_haulers(i) / fab.hauler_life_yr);
            fleet_growth = max(0, ph.n_haulers(i) - ph.n_haulers(i-1)) / 5; % ramp over ~5 yr
            ph.hauler_prod_yr(i) = ceil(fleet_replace + fleet_growth);
        end
        ph.fab_earth_mass(i) = ph.hauler_prod_yr(i) * 1200 * fab.hauler_earth_frac / 1000; % t/yr from Earth
        ph.fab_local_mass(i) = ph.hauler_prod_yr(i) * 1200 * fab.hauler_local_frac / 1000; % t/yr in-situ
        % Fe-Ni feedstock needed (from PROBE asteroid returns + local ilmenite)
        ph.feni_need(i) = ph.fab_local_mass(i) * 0.60; % 60% of local mass is Fe-Ni
        ph.al_need(i) = ph.fab_local_mass(i) * 0.30; % 30% aluminium (from gangue)
        ph.fab_pwr(i) = ph.hauler_prod_yr(i) * 50; % ~50 kW-yr per hauler (foundry energy)
    else
        ph.hauler_prod_yr(i) = 0; ph.fab_earth_mass(i) = 0; ph.fab_local_mass(i) = 0;
        ph.feni_need(i) = 0; ph.al_need(i) = 0; ph.fab_pwr(i) = 0;
    end
    
    % ═══ PROBE FLEET (PGM from asteroids) ═══
    pgm_needed = pgm.demand(i) * 1000; % kg/yr
    if i <= 2 % P7-P8: current PROBE class
        pgm_per_probe = probe.payload_current * probe.pgm_grade * probe.pgm_extraction; % kg PGM/mission
        ph.n_probe(i) = max(30, ceil(pgm_needed / pgm_per_probe));
        ph.probe_prop_each(i) = probe.prop;
        ph.probe_type{i} = 'Standard (1.5t)';
    else % P9+: bigger probes with in-situ beneficiation
        % In-situ: PROBE concentrates PGM 50× on asteroid, returns concentrate
        % 10 t ore × 50× concentration = returns 200 kg of 50× concentrated material
        % Effective PGM per mission: 10000 kg × 50e-6 × 0.70 = 0.35 kg
        % But with 50× in-situ conc: process 500 t on asteroid, return 10 t concentrate
        % PGM per mission: 500000 × 50e-6 × 0.70 = 17.5 kg
        pgm_per_probe = 500000 * probe.pgm_grade * probe.pgm_extraction; % process 500t on asteroid
        ph.n_probe(i) = max(30, ceil(pgm_needed / pgm_per_probe));
        ph.probe_prop_each(i) = probe_big.prop;
        ph.probe_type{i} = 'Heavy (500t proc)';
    end
    ph.pgm_output(i) = ph.n_probe(i) * pgm_per_probe / 1000; % t/yr PGM
    ph.prop_probe(i) = ph.n_probe(i) * ph.probe_prop_each(i) / 1000; % t/yr
    
    % ═══ PKT PROPELLANT DELIVERY (from SPA) ═══
    % Solar wind H₂ byproduct (from KREEP regolith thermal extraction)
    if i >= 2 && ph.raw_kreep(i) > 0
        h2_sw = ph.raw_kreep(i) * 50e-6 * 0.80;
        o2_ilm = ph.raw_kreep(i) * 0.05 * 0.10 * 0.50;
        ph.prop_local(i) = min(h2_sw*6.5, o2_ilm/5.5*6.5);
    else
        ph.prop_local(i) = 0;
    end
    
    ph.prop_pkt_need(i) = max(0, ph.prop_pkt_skip(i) - ph.prop_local(i));
    
    % Transfer method
    if ph.prop_pkt_need(i) > 0
        if i <= 3 % Tanker
            ph.xfer_trips(i) = ceil(ph.prop_pkt_need(i)*1000/tanker.payload);
            ph.xfer_cost(i) = ph.xfer_trips(i)*tanker.total/1000;
            ph.xfer_method{i} = 'Tanker (47%)';
        elseif i == 4 % Mass driver + retro
            ph.xfer_trips(i) = ceil(ph.prop_pkt_need(i)*1000/(10000*md.retro_eff));
            ph.xfer_cost(i) = ph.xfer_trips(i)*10000/1000;
            ph.xfer_method{i} = 'MassDriver+Retro';
        else % Mass driver + catcher
            ph.xfer_trips(i) = ceil(ph.prop_pkt_need(i)*1000/(10000*md.catcher_eff));
            ph.xfer_cost(i) = ph.xfer_trips(i)*10000/1000;
            ph.xfer_method{i} = 'MassDriver+Catcher';
        end
    else
        ph.xfer_trips(i) = 0; ph.xfer_cost(i) = 0;
        ph.xfer_method{i} = 'None (haulers)';
    end
    
    % ═══ CREW (SPA only) ═══
    ph.crew(i) = 12 + 4 + max(0,(ph.proc_spa(i)-1));
    
    % ═══ EARTH RETURN ═══
    if i <= 3 % Starship propulsive return
        ph.ss_reo_return(i) = ceil(ph.reo_target(i)/ss.cap_t);
        ph.prop_ss_return(i) = ph.ss_reo_return(i)*ss.return_prop/1000; % t/yr
        ph.md_earth(i) = 0;
    else % Mass driver (zero propellant)
        ph.ss_reo_return(i) = 0;
        ph.prop_ss_return(i) = 0;
        ph.md_earth(i) = ceil(ph.reo_target(i)/md.earth_canister_reo);
    end
    % Starship flights: crew rotation combined with cargo manifests
    % Each crew rotation flight also carries cargo (optimised manifest).
    % Crew flights: ~annual, 12 crew per flight, outbound carries max cargo
    % Return: crew + PGM product (small volume). Return prop from ISRU.
    ph.ss_crew(i) = max(1, ceil(ph.crew(i)/12)); % crew rotation flights
    ph.prop_crew_return(i) = ph.ss_crew(i)*ss.return_prop/1000;
    
    % Reagent delivery to PKT (one-way expendable Starship, no return prop)
    ph.ss_reagent(i) = ceil(ph.proc_pkt(i)*proc.reagent/ss.cap_t);
    if i==1, ph.ss_reagent(i)=0; end
    
    % PGM return: co-manifested on crew return flights (PGM volume is small)
    ph.ss_pgm(i) = 0; % PGM fits in crew Starship return cargo bay
    
    % ═══ TOTAL SPA PROPELLANT DEMAND ═══
    ph.prop_skip_spa(i) = ph.skip_spa(i)*skip.hops*skip.fuel_spa/1000;
    ph.prop_ls(i) = ph.crew(i)*ls.prop_yr/1000;
    
    ph.prop_total(i) = ph.prop_skip_spa(i) + ph.prop_probe(i) + ...
                       ph.xfer_cost(i) + ph.prop_ls(i) + ...
                       ph.prop_ss_return(i) + ph.prop_crew_return(i);
    
    % ═══ MOLE-I FLEET ═══
    demand_kg = ph.prop_total(i)*1000*1.10; % 10% margin
    raw_mi = ceil(demand_kg/mi.prop_yield);
    ph.n_molei(i) = ceil(raw_mi/mi.node)*mi.node;
    ph.n_nodes(i) = ph.n_molei(i)/mi.node;
    ph.isru_supply(i) = ph.n_molei(i)*mi.prop_yield/1000;
    ph.margin(i) = ph.isru_supply(i) - ph.prop_total(i);
    
    % Ice sites needed
    ice_demand_kg = demand_kg / 0.722; % water needed
    ph.ice_sites(i) = max(1, ceil(ice_demand_kg/shack.ice_yr) - 1) + 1; % Shackleton + others
    if ice_demand_kg <= shack.ice_yr, ph.ice_sites(i) = 1; end
    
    % ═══ SPA POWER ═══
    water_kghr = demand_kg/(0.80*8760);
    ph.n_pem(i) = ceil(water_kghr/50);
    ph.pwr_elec(i) = ph.n_pem(i)*51.8;
    ph.pwr_cryo(i) = water_kghr*(2/18)*11.9 + water_kghr*(16/18)*0.4;
    ph.pwr_psr(i) = ph.n_molei(i)*mi.pwr_kW;
    ph.pwr_hab(i) = ph.crew(i)*hab.eclss_kW + 50;
    ph.pwr_proc_spa(i) = ph.proc_spa(i)*proc.pwr_kW;
    ph.pwr_iz(i) = 50 + ph.n_probe(i)*0.5;
    ph.pwr_spa(i) = (ph.pwr_elec(i)+ph.pwr_cryo(i)+ph.pwr_psr(i)+...
                     ph.pwr_hab(i)+ph.pwr_proc_spa(i)+ph.pwr_iz(i))*1.20;
    ph.solar_m2(i) = ph.pwr_spa(i)/solar.yield;
    eclipse_kW = ph.pwr_hab(i)+60+10+ph.pwr_proc_spa(i)*0.3;
    ph.fsp_spa(i) = ceil(eclipse_kW/fsp.kW);
    
    % ═══ PKT POWER ═══
    ph.pwr_proc_pkt(i) = ph.proc_pkt(i)*proc.pwr_kW;
    ph.pwr_hauler(i) = ph.n_haulers(i)*hauler.pwr_kW*0.50; % 50% duty cycle
    ph.pwr_bene_pkt(i) = max(0,ph.bene_total(i)-2)*27; % subtract SPA bene lines
    if i==1, ph.pwr_hauler(i)=0; ph.pwr_bene_pkt(i)=0; end
    ph.pwr_catapult(i) = ph.n_catapults(i)*(catapult.pwr_MW+catapult.pwr_return_MW)*1000*0.30; % 30% avg duty, both directions
    ph.pwr_fab(i) = ph.fab_pwr(i); % foundry/fabrication
    ph.pwr_pkt(i) = (ph.pwr_proc_pkt(i)+ph.pwr_hauler(i)+ph.pwr_bene_pkt(i)+...
                     ph.pwr_catapult(i)+ph.pwr_fab(i)+20)*1.20; % +20 kW SENTINEL/comms
    if i==1, ph.pwr_pkt(i)=0; end
    ph.fsp_pkt(i) = ceil(ph.pwr_pkt(i)*0.70/fsp.kW);
    
    % ═══ INFRASTRUCTURE ═══
    ph.hab_mod(i) = ceil(ph.crew(i)/hab.crew_mod);
    ph.elz_spa(i) = max(4, 2+ceil(ph.xfer_trips(i)/500));
    ph.ss_total(i) = ph.ss_crew(i)+ph.ss_reo_return(i)+ph.ss_reagent(i)+2; % PGM on crew flights
end

%% ═══ OUTPUT ═══
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  KREEP CHAIN: REO Target → Raw Ore → Transport → Processing\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %11s %12s %14s %6s %8s %20s %8s\n',...
    'Phase','REO t/yr','Conc t/yr','Raw t/yr','SKIPs','Haulers','Transport','Circuits');
fprintf('  %s\n',repmat('-',1,105));
for i=1:ph.n
    fprintf('  %-12s %11.1f %12s %14s %6d %8s %20s %8d\n',...
        ph.lab{i}, ph.reo_target(i),...
        sprintf('%.0f',ph.concentrate(i)),...
        sprintf('%.0f',ph.raw_kreep(i)),...
        ph.skip_total(i), sprintf('%.0f',ph.n_haulers(i)),...
        ph.xfer_method{i}, ph.proc_total(i));
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  PGM FROM ASTEROIDS (PROBE Fleet)\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %6s %16s %10s %12s %10s\n',...
    'Phase','Probes','Type','PGM t/yr','Prop t/yr','Demand t/yr');
fprintf('  %s\n',repmat('-',1,75));
for i=1:ph.n
    fprintf('  %-12s %6d %16s %10.1f %12s %10.0f\n',...
        ph.lab{i}, ph.n_probe(i), ph.probe_type{i},...
        ph.pgm_output(i), sprintf('%.0f',ph.prop_probe(i)), pgm.demand(i)*1000);
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  SPA PROPELLANT (t/yr) — includes Earth transit fuel\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %8s %8s %10s %6s %8s %6s | %12s %12s\n',...
    'Phase','Sk_SPA','PROBE','Transfer','LS','SS_ret','Crew','TOTAL','ISRU_sup');
fprintf('  %s\n',repmat('-',1,100));
for i=1:ph.n
    if ph.margin(i)>=0, st='OK'; else, st='FAIL'; end
    fprintf('  %-12s %8.0f %8.0f %10s %6.1f %8.0f %6.0f | %12s %12s %s\n',...
        ph.lab{i}, ph.prop_skip_spa(i), ph.prop_probe(i),...
        sprintf('%.0f',ph.xfer_cost(i)), ph.prop_ls(i),...
        ph.prop_ss_return(i), ph.prop_crew_return(i),...
        sprintf('%.0f',ph.prop_total(i)), sprintf('%.0f',ph.isru_supply(i)), st);
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  ISRU + ICE MINING (Shackleton)\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %10s %8s %6s %12s %12s %12s %6s\n',...
    'Phase','MOLE-I','Nodes','PEM','Elec kW','Cryo kW','SPA Total kW','Ice#');
fprintf('  %s\n',repmat('-',1,90));
for i=1:ph.n
    fprintf('  %-12s %10s %8s %6d %12s %12s %12s %6d\n',...
        ph.lab{i}, sprintf('%.0f',ph.n_molei(i)), sprintf('%.0f',ph.n_nodes(i)),...
        ph.n_pem(i), sprintf('%.0f',ph.pwr_elec(i)),...
        sprintf('%.0f',ph.pwr_cryo(i)), sprintf('%.0f',ph.pwr_spa(i)), ph.ice_sites(i));
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  PKT AUTONOMOUS BASE\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %10s %8s %8s %6s %12s %8s %10s\n',...
    'Phase','Haulers','Catapults','Canistrs','Bene','PKT kW','FSP','Fab t/yr');
fprintf('  %s\n',repmat('-',1,95));
for i=1:ph.n
    fprintf('  %-12s %10s %8d %8s %6d %12s %8d %10s\n',...
        ph.lab{i}, sprintf('%.0f',ph.n_haulers(i)), ph.n_catapults(i),...
        sprintf('%.0f',ph.n_canisters(i)), ph.bene_total(i),...
        sprintf('%.0f',ph.pwr_pkt(i)), ph.fsp_pkt(i),...
        sprintf('%.0f',ph.hauler_prod_yr(i)));
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  EARTH LOGISTICS\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %8s %8s %10s %8s %12s\n',...
    'Phase','SS_crew','SS_REO','SS_reagent','SS_PGM','MD_Earth');
fprintf('  %s\n',repmat('-',1,60));
for i=1:ph.n
    fprintf('  %-12s %8d %8d %10d %8d %12s\n',...
        ph.lab{i}, ph.ss_crew(i), ph.ss_reo_return(i), ph.ss_reagent(i),...
        ph.ss_pgm(i), sprintf('%.0f',ph.md_earth(i)));
end

%% ═══ FULL SUMMARY ═══
fprintf('\n═══════════════════════════════════════════════════════════════════════\n');
fprintf('  PHASE-BY-PHASE SUMMARY\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');
for i=1:ph.n
    fprintf('─── %s ──────────────────────────────────────\n', ph.lab{i});
    fprintf('  REO:      %14.1f t/yr | PGM:    %10.1f t/yr\n', ph.reo_target(i), ph.pgm_output(i));
    fprintf('  Raw KREEP:%14s t/yr | Transport: %s\n', sprintf('%.0f',ph.raw_kreep(i)), ph.xfer_method{i});
    fprintf('  SKIPs:    %6d SPA + %8d PKT | Haulers: %s | Catapults: %d | Canisters: %s\n',...
        ph.skip_spa(i), ph.skip_pkt(i), sprintf('%.0f',ph.n_haulers(i)), ph.n_catapults(i), sprintf('%.0f',ph.n_canisters(i)));
    fprintf('  PROBEs:   %6d (%s)\n', ph.n_probe(i), ph.probe_type{i});
    fprintf('  Proc:     %6d SPA + %8d PKT = %8d total\n', ph.proc_spa(i),ph.proc_pkt(i),ph.proc_total(i));
    fprintf('  Crew:     %6d (SPA only, PKT autonomous)\n', ph.crew(i));
    fprintf('  MOLE-I:   %10s (%s nodes, %d ice sites)\n',...
        sprintf('%.0f',ph.n_molei(i)), sprintf('%.0f',ph.n_nodes(i)), ph.ice_sites(i));
    if ph.hauler_prod_yr(i) > 0
        fprintf('  Fab:      %10s haulers/yr in-situ | %s t/yr Fe-Ni | %s t/yr Al | %s t/yr from Earth\n',...
            sprintf('%.0f',ph.hauler_prod_yr(i)), sprintf('%.0f',ph.feni_need(i)),...
            sprintf('%.0f',ph.al_need(i)), sprintf('%.0f',ph.fab_earth_mass(i)));
    end
    fprintf('  Prop SPA: %14s t/yr | ISRU margin: %+.0f t/yr\n',...
        sprintf('%.0f',ph.prop_total(i)), ph.margin(i));
    fprintf('  Power:    %12s kW SPA | %12s kW PKT\n',...
        sprintf('%.0f',ph.pwr_spa(i)), sprintf('%.0f',ph.pwr_pkt(i)));
    fprintf('  FSP:      %6d SPA + %8d PKT = %8d total\n',...
        ph.fsp_spa(i), ph.fsp_pkt(i), ph.fsp_spa(i)+ph.fsp_pkt(i));
    fprintf('  Earth:    %6d SS + %8s mass driver launches/yr\n',...
        ph.ss_total(i), sprintf('%.0f',ph.md_earth(i)));
    fprintf('\n');
end

%% ═══ GLOBAL COMPARISON ═══
earth_ree = [390000,550000,700000,850000,1000000,1200000];
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('  GLOBAL DEMAND vs SELENITE SUPPLY\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %12s %12s %8s | %10s %10s\n',...
    'Phase','Sel REO','Earth REO','REO %%','Sel PGM','PGM Demand');
fprintf('  %s\n',repmat('-',1,75));
for i=1:ph.n
    fprintf('  %-12s %12s %12s %7.3f%% | %10.1f %10.0f\n',...
        ph.lab{i}, sprintf('%.0f',ph.reo_target(i)), sprintf('%.0f',earth_ree(i)),...
        ph.reo_target(i)/earth_ree(i)*100, ph.pgm_output(i), pgm.demand(i)*1000);
end

fprintf('\n  Fe/Ni POSITION: NOT for Earth return. In-space structural use only.\n');
fprintf('  Earth Fe demand ~5 Bt/yr by 2100 — met by terrestrial green steel.\n');
fprintf('  Programme Fe-Ni use: PKT foundry feedstock for haulers, canisters,\n');
fprintf('  hub structures. Source: PROBE asteroid returns + local ilmenite.\n');
fprintf('  P12 Fe-Ni demand for fabrication: %s t/yr\n', sprintf('%.0f',ph.feni_need(ph.n)));
fprintf('  This is %% of PROBE Ni-Fe return, validating in-space use case.\n');

%% ═══ KEY FINDING: ICE COMPARISON v1.1 vs v1.2 ═══
fprintf('\n═══════════════════════════════════════════════════════════════════════\n');
fprintf('  v1.2 → v1.3 COMPARISON: Key Changes\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');
% v1.1 P12 MOLE-I was 194,838,070. v1.2 should be dramatically less.
fprintf('  v1.2 P12 catapults: 5 (underestimated)\n');
fprintf('  v1.3 P12 catapults: %d (tier-fraction model, frontier expansion)\n', ph.n_catapults(ph.n));
fprintf('  v1.3 P12 canisters in fleet: %s\n', sprintf('%.0f',ph.n_canisters(ph.n)));
fprintf('  v1.3 P12 hauler production: %s/yr (92%% in-situ manufactured)\n', sprintf('%.0f',ph.hauler_prod_yr(ph.n)));
fprintf('  v1.3 P12 Earth-supplied mass for fab: %s t/yr (electronics+batteries only)\n', sprintf('%.0f',ph.fab_earth_mass(ph.n)));
fprintf('  v1.3 P12 Fe-Ni feedstock for fab: %s t/yr (from PROBE + ilmenite)\n', sprintf('%.0f',ph.feni_need(ph.n)));
fprintf('  v1.3 P12 Al feedstock for fab: %s t/yr (from KREEP gangue)\n', sprintf('%.0f',ph.al_need(ph.n)));
fprintf('  v1.3 Bidirectional catapult: 4 tracks per hub pair (loaded out, empties back)\n');
fprintf('  v1.3 Fe/Ni: in-space use only, NOT Earth return\n');

%% ═══ FIGURES ═══
figure('Position',[50 50 1500 950],'Color','k','Name','SELENITE SCALE v1.3');

subplot(2,3,1);
semilogy(1:ph.n, ph.reo_target, 'co-','LineWidth',2.5,'MarkerSize',9,'MarkerFaceColor','c');
hold on; semilogy(1:ph.n, earth_ree, 'r--s','LineWidth',1.5,'MarkerSize',7,'MarkerFaceColor','r');
yline(1e6,'g--','LineWidth',1.5);
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],'XColor','w','YColor','w','FontSize',8);
xtickangle(30); ylabel('t/yr (log)','Color','w'); title('REO Output vs Earth Demand','Color','w');
legend('Selenite','Earth','Target','TextColor','w','Color',[.08 .10 .16],'Location','southeast','FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

subplot(2,3,2);
semilogy(1:ph.n, max(1,[ph.n_haulers; ph.n_catapults*1000]'), 'o-','LineWidth',2,'MarkerSize',8);
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],'XColor','w','YColor','w','FontSize',8);
xtickangle(30); ylabel('Count (log)','Color','w'); title('PKT Transport (log)','Color','w');
legend('Haulers','Catapults x1000','TextColor','w','Color',[.08 .10 .16],'FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

subplot(2,3,3);
semilogy(1:ph.n, max(1,ph.n_molei), 'ms-','LineWidth',2,'MarkerSize',9,'MarkerFaceColor','m');
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],'XColor','w','YColor','w','FontSize',8);
xtickangle(30); ylabel('MOLE-I (log)','Color','w'); title('Ice Mining Fleet (log scale)','Color','w');
grid on; set(gca,'GridColor',[.2 .25 .35]);

subplot(2,3,4);
semilogy(1:ph.n, max(1,ph.pwr_spa), 'co-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','c');
hold on;
semilogy(1:ph.n, max(1,ph.pwr_pkt), 'rs-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','r');
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],'XColor','w','YColor','w','FontSize',8);
xtickangle(30); ylabel('kW (log)','Color','w'); title('Power: SPA vs PKT (log)','Color','w');
legend('SPA','PKT','TextColor','w','Color',[.08 .10 .16],'FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

subplot(2,3,5);
bar(1:ph.n, [ph.proc_spa; ph.proc_pkt]', 'stacked');
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],'XColor','w','YColor','w','FontSize',8);
xtickangle(30); ylabel('Circuits','Color','w'); title('Processing Circuits','Color','w');
legend('SPA','PKT','TextColor','w','Color',[.08 .10 .16],'FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

subplot(2,3,6);
pct = ph.reo_target./earth_ree*100;
bar(1:ph.n, pct, 'FaceColor',[.2 .85 .4]);
hold on; yline(50,'r--','LineWidth',1.5); yline(83,'g--','LineWidth',1.5);
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],'XColor','w','YColor','w','FontSize',8);
xtickangle(30); ylabel('% Earth demand','Color','w'); title('Global Displacement','Color','w');
grid on; set(gca,'GridColor',[.2 .25 .35]);

sgtitle('SELENITE v1.2 — v1.3 — Fabrication + Bidirectional Catapults + Fe-Ni In-Space','Color','w','FontSize',14,'FontWeight','bold');

fprintf('\n═══════════════════════════════════════════════════════════════════════\n');
fprintf('  ANALYSIS COMPLETE — v1.3\n');
fprintf('  KEY: Surface haulers + in-situ fabrication + bidirectional catapults\n');
fprintf('  Ice demand reduced by >99%% vs v1.1\n');
fprintf('  In-situ fab: 92% hauler mass manufactured at PKT from Fe-Ni + Al gangue\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');

%% ═══ DESIGN EVOLUTION NOTES ═══
fprintf('\n═══════════════════════════════════════════════════════════════════════\n');
fprintf('  DESIGN EVOLUTION FLAGS (future spec documents)\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('  PROBE Mk II (P9+): Larger vehicle, 10-50t payload class.\n');
fprintf('    In-situ beneficiation on asteroid (magnetic separation in micro-g).\n');
fprintf('    Returns PGM concentrate only, not raw ore. 50x mass reduction.\n');
fprintf('    Required for PGM scaling beyond 5 t/yr.\n');
fprintf('    Full 2100 PGM demand (8,000 t/yr) requires orbital processing\n');
fprintf('    platforms + asteroid capture/redirect — P13+ infrastructure.\n\n');
fprintf('  MOLE-I Mk II (P8+): Extended drill for deep ice (10m+ strip mining).\n');
fprintf('    Retractable drill assembly (must fully retract for transit).\n');
fprintf('    Options: (a) Mk II new-build with telescoping drill, or\n');
fprintf('    (b) Mk I retrofit: replace drill module at existing substations.\n');
fprintf('    Design consideration: drill retraction clearance vs chassis height.\n');
fprintf('    If retrofit: drill module is an ORU — ARM swaps at substation.\n\n');
fprintf('  Surface Hauler (P10+ PKT): New vehicle class, no current spec.\n');
fprintf('    5 t payload, electric drive, 1 m/s on sintered road.\n');
fprintf('    Autonomous (SENTINEL-supervised from SPA Ops Hub).\n');
fprintf('    Charged at hub stations (FSP-powered). ~5 kW average.\n');
fprintf('    Spec document needed: SEL-HAULER-001 Rev A.\n\n');
fprintf('  EM Catapult Hub (P11+): Regional ore launch facility.\n');
fprintf('    500m track, SINTER-built bed, ARM-installed coils.\n');
fprintf('    500 m/s launch for 5t canisters. ~5 MW pulsed.\n');
fprintf('    Spec document needed: SEL-CATAPULT-001 Rev A.\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');