%% SELENITE_SCALE_v1_1.m
%  100-Year Scaling Analysis: Shackleton + PKT Dual-Base Architecture
%  Target: 1,000,000 t/yr REO by ~2100 (Phase 12)
%
%  v1.1 changes from v1.0:
%    - PKT base redesigned as FULLY AUTONOMOUS (zero crew)
%      No hab, no ECLSS, no ISRU at PKT. LH₂/LOX delivered by tanker.
%      Maintenance by ARM-class robots. SENTINEL remote supervision.
%    - Shackleton crew: 12 (base ops) + 5 (processing) = 17
%    - Fixed ternary function syntax error
%    - LH₂/LOX sent to PKT (not water) — no PKT ISRU needed
%    - Added Starship backhaul (REO product to Earth) accounting
%    - Added global demand comparison with % displacement curves
%
%  Models cascading demands across all base zones:
%    SKIP fleet → raw KREEP → beneficiation → processing → REO output
%    Propellant → MOLE-I → ISRU → power (Shackleton produces ALL prop)
%    PKT propellant via LLO tanker from Shackleton
%    Crew (Shackleton only) → hab → ECLSS → water/O₂
%    Infrastructure: pads, collars, ELZ, processing circuits
%    Power: solar + FSP per base
%
%  Inputs: SELENITE_VERIFY v5.0, SEL-PROC-001 Rev A, SEL-IZ-001 Rev A,
%    SEL-ISRU-001 Rev D, SEL-POWER-001 Rev A, team_reference_v2
%
%  Author: Jason (Systems Engineering Lead), Selenite Programme
%  Date: March 2026

clear; clc; close all;

fprintf('════════════════════════════════════════════════════════════════════════\n');
fprintf('  SELENITE SCALE v1.1 — 100-Year Dual-Base Scaling Analysis\n');
fprintf('  Shackleton (crewed) + PKT (fully autonomous)\n');
fprintf('  Target: 1,000,000 t/yr REO by ~2100\n');
fprintf('  Ref: SEL-PROC-001 Rev A, all subsystem specs (March 2026)\n');
fprintf('════════════════════════════════════════════════════════════════════════\n\n');

% Helper: conditional string
function s = cond_str(condition, if_true, if_false)
    if condition
        s = if_true;
    else
        s = if_false;
    end
end

% Helper: format number with comma thousands separators
function s = fmtc(x, decimals)
    if nargin < 2, decimals = 0; end
    if decimals > 0
        fmt = sprintf('%%.%df', decimals);
        s = sprintf(fmt, x);
    else
        s = sprintf('%.0f', x);
    end
    % Insert commas from the right, before decimal point
    idx = strfind(s, '.');
    if isempty(idx), idx = length(s)+1; end
    int_part = s(1:idx-1);
    dec_part = s(idx:end);
    % Handle negative
    neg = '';
    if ~isempty(int_part) && int_part(1)=='-'
        neg = '-'; int_part = int_part(2:end);
    end
    n = length(int_part);
    if n > 3
        groups = {};
        while n > 3
            groups{end+1} = int_part(n-2:n);
            int_part = int_part(1:n-3);
            n = length(int_part);
        end
        groups{end+1} = int_part;
        groups = fliplr(groups);
        int_part = strjoin(groups, ',');
    end
    s = [neg int_part dec_part];
end

%% ═══ CONSTANTS & UNIT PARAMETERS ═══
g0 = 9.81; g_moon = 1.62; Isp = 450; ve = Isp*g0;

% KREEP grades (ppm REE in raw regolith)
kreep.spa_mid = 140;   % SPA Basin average
kreep.pkt_mid = 1000;  % PKT average (2–10× richer)

% Beneficiation
bene.mass_recovery = 0.04;     % 4% mass recovery
bene.grade_uplift = 10;        % 10× concentration factor
bene.capacity_per_line = 1000; % t/yr per beneficiation line

% Processing (hydromet) — per SEL-PROC-001 Rev A
proc.extraction_eff = 0.80;    % 80% REE extraction from concentrate
proc.circuit_capacity = 50;    % t/yr concentrate per circuit
proc.power_per_circuit = 180;  % kW average per circuit
proc.reagent_per_circuit = 49; % t/yr net reagents per circuit
proc.water_per_circuit = 8;    % m³/yr net water per circuit

% SKIP parameters (from VERIFY v5.0)
skip.mass_dry = 300; skip.mass_payload = 400;
skip.mf = skip.mass_dry + skip.mass_payload;
skip.rng_spa = 100; skip.rng_pkt = 35; % km
skip.v0_spa = sqrt(g_moon * skip.rng_spa*1e3 / 2);
skip.v0_pkt = sqrt(g_moon * skip.rng_pkt*1e3 / 2);
skip.dv_spa = 4 * skip.v0_spa * 1.05;
skip.dv_pkt = 4 * skip.v0_pkt * 1.05;
skip.fuel_spa = skip.mf * (exp(skip.dv_spa/ve) - 1); % kg/hop
skip.fuel_pkt = skip.mf * (exp(skip.dv_pkt/ve) - 1);
skip.hops_per_yr = 274; % per SKIP

% PROBE parameters
probe.prop = 6654; % kg propellant per mission

% LLO tanker (repurposed PROBE-class)
tanker.payload = 6000;  % kg LH₂/LOX delivered per trip
tanker.prop_own = 6654; % propellant consumed by tanker (round-trip LLO)
tanker.total = tanker.payload + tanker.prop_own; % total prop per trip
tanker.trips_per_yr = 12; % max trips per tanker per year

% MOLE-I ice mining
mi.water_yr = 25 * 0.0446 * 0.80 * 8760;  % kg water/yr per MOLE-I
mi.prop_yield = mi.water_yr * 0.722;        % kg propellant/yr per MOLE-I
mi.node_units = 10;  % MOLE-I per substation node
mi.pwr_tether_kW = 1.934; % kW per MOLE-I at tether

% ISRU electrolysis
isru.pwr_per_stack = 51.8;     % kW per PEM stack
isru.cryo_lh2_per_kghr = 11.9; % kW per kg/hr H₂ liquefied
isru.cryo_lox_per_kghr = 0.4;  % kW per kg/hr O₂ liquefied

% FSP
fsp.pwr_kW = 40; fsp.mass_kg = 6600;

% Solar
solar.yield = 0.319; % kW/m² (with 5% dust, Shackleton)

% Hab/ECLSS (Shackleton only — PKT is autonomous)
hab.crew_per_module = 4;
hab.eclss_kW_per_crew = 1.2;

% Life support propellant-equivalent (O₂ + water from ISRU)
ls.prop_per_crew_yr = 0.9*365/0.889 * 0.722; % kg/yr

% Starship
starship.cap_t = 100; % payload capacity (t)

fprintf('== UNIT PARAMETERS ==\n');
fprintf('  SKIP SPA: dV=%.0f m/s, fuel=%.0f kg/hop, KREEP=%d kg/hop\n',...
    skip.dv_spa, skip.fuel_spa, skip.mass_payload);
fprintf('  SKIP PKT: dV=%.0f m/s, fuel=%.0f kg/hop, KREEP=%d kg/hop\n',...
    skip.dv_pkt, skip.fuel_pkt, skip.mass_payload);
fprintf('  MOLE-I: %.0f kg prop/yr (%.0f kg water/yr)\n', mi.prop_yield, mi.water_yr);
fprintf('  Tanker: %d kg delivered, %d kg consumed per trip\n',...
    tanker.payload, tanker.prop_own);
fprintf('  Processing: %d t/yr/circuit, %.0f%% extraction eff\n\n',...
    proc.circuit_capacity, proc.extraction_eff*100);

%% ═══ PHASE DEFINITIONS ═══
% P7:   Shackleton proof of concept (current small base)
% P8:   PKT-1 autonomous base online
% P9:   PKT scaled (10× circuits)
% P10:  Multi-site PKT (100× circuits)
% P11:  Pan-lunar industrial
% P12:  Full scale target (1 Mt/yr)

ph.n = 6;
ph.lab = {'P7 (Y20)','P8 (Y30)','P9 (Y40)','P10 (Y55)','P11 (Y75)','P12 (Y95)'};

% ─── REO OUTPUT TARGETS (t/yr) ───
ph.reo_target = [0.4, 125, 1000, 10000, 100000, 1000000];
% P7: 1 circuit processing SPA concentrate (35 t/yr × 1200 ppm × 80%)
% P8: 5 PKT circuits online (PKT grade 10,000 ppm in conc, 80% extr)
% P9–P12: exponential ramp

fprintf('== REO OUTPUT TARGETS ==\n');
for i=1:ph.n
    fprintf('  %s: %14s t/yr REO\n', ph.lab{i}, fmtc(ph.reo_target(i),1));
end
fprintf('\n');

%% ═══ BACK-CALCULATE: REO → SKIP FLEET → PROPELLANT → ISRU → POWER ═══

for i = 1:ph.n
    % ─── KREEP grade depends on source ───
    if i == 1
        grade_raw = kreep.spa_mid; % ppm in raw ore
    else
        grade_raw = kreep.pkt_mid; % PKT
    end
    grade_conc = grade_raw * bene.grade_uplift / 1e6; % REE fraction in concentrate
    
    % ─── REO → concentrate → raw ore → SKIP fleet ───
    ph.concentrate(i) = ph.reo_target(i) / (grade_conc * proc.extraction_eff);
    ph.raw_kreep(i)   = ph.concentrate(i) / bene.mass_recovery;
    
    kreep_per_skip = skip.mass_payload * skip.hops_per_yr / 1000; % t/yr per SKIP
    
    if i == 1
        ph.skip_spa(i) = 8; % existing P7 fleet
        ph.skip_pkt(i) = 0;
    else
        ph.skip_spa(i) = 8; % maintain SPA fleet
        ph.skip_pkt(i) = max(1, ceil(ph.raw_kreep(i) / kreep_per_skip) - ph.skip_spa(i));
    end
    ph.skip_total(i) = ph.skip_spa(i) + ph.skip_pkt(i);
    
    % ─── Processing circuits ───
    ph.proc_spa(i) = min(5, ceil(ph.concentrate(i) / proc.circuit_capacity));
    if i == 1
        ph.proc_pkt(i) = 0;
    else
        ph.proc_pkt(i) = max(0, ceil(ph.concentrate(i) / proc.circuit_capacity) - ph.proc_spa(i));
    end
    ph.proc_total(i) = ph.proc_spa(i) + ph.proc_pkt(i);
    
    % ─── Beneficiation lines ───
    ph.bene_spa(i) = min(2, ceil(ph.raw_kreep(i) / bene.capacity_per_line));
    if i == 1
        ph.bene_pkt(i) = 0;
    else
        ph.bene_pkt(i) = max(0, ceil(ph.raw_kreep(i) / bene.capacity_per_line) - ph.bene_spa(i));
    end
    
    % ─── PROBE fleet (Shackleton only, asteroid PGM) ───
    ph.n_probe(i) = 30 + (i-1)*5;
    
    % ─── PKT propellant demand (SKIP hops) ───
    ph.prop_pkt_gross(i) = ph.skip_pkt(i) * skip.hops_per_yr * skip.fuel_pkt / 1000; % t/yr
    % NOTE: PKT is autonomous — zero crew, zero life support propellant
    
    % ─── Solar wind H₂ byproduct at PKT (thermal extraction from KREEP regolith) ───
    % PKT regolith contains ~50 ppm solar-wind-implanted hydrogen.
    % Thermal extraction at 700°C before crushing recovers H₂ as byproduct.
    % Ilmenite reduction (FeTiO₃ + H₂ → Fe + TiO₂ + H₂O → electrolysis) yields O₂.
    % Combined: partial propellant self-sufficiency at high KREEP throughput.
    if i >= 2 && ph.raw_kreep(i) > 0
        h2_solar_wind = ph.raw_kreep(i) * 50e-6 * 0.80; % t/yr H₂ from regolith
        ilmenite_frac = 0.05; ilmenite_o2_yield = 0.10; % conservative
        o2_ilmenite = ph.raw_kreep(i) * ilmenite_frac * ilmenite_o2_yield * 0.50; % t/yr O₂
        % At MR 5.5:1, per t H₂ need 5.5 t O₂ → 6.5 t propellant
        o2_needed = h2_solar_wind * 5.5;
        if o2_ilmenite >= o2_needed
            ph.prop_pkt_local(i) = h2_solar_wind * 6.5; % H₂-limited
        else
            ph.prop_pkt_local(i) = o2_ilmenite / 5.5 * 6.5; % O₂-limited
        end
    else
        ph.prop_pkt_local(i) = 0;
    end
    
    % Net propellant PKT needs from Shackleton
    ph.prop_pkt_import(i) = max(0, ph.prop_pkt_gross(i) - ph.prop_pkt_local(i));
    
    % ─── Propellant transfer: Shackleton → PKT ───
    % OPTION C HYBRID:
    %   P8–P9: Chemical tankers via LLO (47% delivery efficiency)
    %   P10+:  EM mass driver at Shackleton rim + propulsive retro canister
    %          Canister: ~10 t total, ~1,700 m/s retro ΔV, Isp 450s
    %          Retro fuel fraction: 32%, canister structure: 5%
    %          Delivery efficiency: 63% (vs 47% tanker)
    %          Mass driver powered electrically — no ISRU propellant for launch
    %   P11+:  Add EM catcher at PKT (linear electromagnetic decelerator)
    %          Near 100% delivery (canister structure only overhead)
    %          Recovers kinetic energy as electricity at PKT
    
    tanker_eff = tanker.payload / tanker.total; % 0.47
    canister_total = 10000; % kg per canister
    canister_retro_frac = 0.32; % from rocket eq: exp(1700/4414)-1 ≈ 0.47... 
    % Actually: mass_ratio = exp(1700/4414) = 1.469
    % retro_prop = total * (1 - 1/mass_ratio) = total * 0.319
    canister_struct_frac = 0.05;
    canister_deliver = canister_total * (1 - canister_retro_frac - canister_struct_frac); % 6,300 kg
    canister_eff = canister_deliver / canister_total; % 0.63
    
    % P11+ EM catcher: near 100% efficiency (only structure overhead)
    catcher_eff = 1 - canister_struct_frac; % 0.95
    
    if ph.prop_pkt_import(i) > 0
        if i <= 3 % P8–P9: chemical tankers
            ph.transfer_method{i} = 'Transfer';
            ph.transfer_eff(i) = tanker_eff;
            ph.tanker_trips(i) = ceil(ph.prop_pkt_import(i)*1000 / tanker.payload);
            ph.n_tankers(i) = ceil(ph.tanker_trips(i) / tanker.trips_per_yr);
            ph.prop_transfer_cost(i) = ph.tanker_trips(i) * tanker.total / 1000; % t/yr total
        elseif i <= 4 % P10: mass driver + propulsive retro
            ph.transfer_method{i} = 'MassDriver+Retro';
            ph.transfer_eff(i) = canister_eff;
            n_canisters = ceil(ph.prop_pkt_import(i)*1000 / canister_deliver);
            ph.tanker_trips(i) = n_canisters; % repurpose field for canister count
            ph.n_tankers(i) = 0; % no chemical tankers
            ph.prop_transfer_cost(i) = n_canisters * canister_total / 1000; % t/yr total prop in canisters
        else % P11+: mass driver + EM catcher at PKT
            ph.transfer_method{i} = 'MassDriver+Catcher';
            ph.transfer_eff(i) = catcher_eff;
            deliver_per = canister_total * catcher_eff;
            n_canisters = ceil(ph.prop_pkt_import(i)*1000 / deliver_per);
            ph.tanker_trips(i) = n_canisters;
            ph.n_tankers(i) = 0;
            ph.prop_transfer_cost(i) = n_canisters * canister_total / 1000;
        end
    else
        ph.transfer_method{i} = 'None';
        ph.transfer_eff(i) = 0;
        ph.tanker_trips(i) = 0; ph.n_tankers(i) = 0; ph.prop_transfer_cost(i) = 0;
    end
    
    % ─── Shackleton crew: 12 base + 4 processing = 16 ───
    % Base 12: commander, pilot, 2× flight eng, medical, 2× scientists,
    %   2× EVA/maintenance, 2× ISRU ops, 1× comms/SENTINEL
    % Processing 4: chem eng, metallurgist, 2× operators
    % Growth: +1 per additional SPA processing circuit beyond first
    ph.crew_spa(i) = 12 + 4 + max(0, (ph.proc_spa(i)-1))*1;
    ph.crew_pkt(i) = 0; % PKT is fully autonomous — ZERO crew
    ph.crew_total(i) = ph.crew_spa(i);
    
    % ─── Shackleton propellant demand (ALL produced here) ───
    ph.prop_skip_spa(i)  = ph.skip_spa(i) * skip.hops_per_yr * skip.fuel_spa / 1000;
    ph.prop_probe(i)     = ph.n_probe(i) * probe.prop / 1000;
    ph.prop_ls(i)        = ph.crew_spa(i) * ls.prop_per_crew_yr / 1000;
    
    ph.prop_total_spa(i) = ph.prop_skip_spa(i) + ph.prop_probe(i) + ...
                           ph.prop_transfer_cost(i) + ph.prop_ls(i);
    
    % ─── MOLE-I fleet (Shackleton only — produces ALL propellant) ───
    demand_kg = ph.prop_total_spa(i) * 1000;
    raw_mi = ceil(demand_kg * 1.10 / mi.prop_yield); % 10% margin
    ph.n_molei(i) = ceil(raw_mi / mi.node_units) * mi.node_units;
    ph.n_nodes(i) = ph.n_molei(i) / mi.node_units;
    ph.isru_supply(i) = ph.n_molei(i) * mi.prop_yield / 1000;
    ph.isru_margin(i) = ph.isru_supply(i) - ph.prop_total_spa(i);
    
    % ─── Ice mining sites (multiple craters at scale) ───
    % Shackleton floor: ~33 km², 4.46% ice, exploitable ~5% of area at any time
    shackleton_yr = 33.2e6 * 0.05 * 0.0446 * 1550 * 0.10; % kg ice/yr (10% depletion)
    ph.ice_sites(i) = max(1, ceil(demand_kg / (0.722 * shackleton_yr)));
    
    % ─── ISRU electrolysis sizing ───
    water_kghr = demand_kg * 1.10 / (0.80 * 8760 * 0.722); % water throughput
    ph.n_pem(i) = ceil(water_kghr / 50); % 1 stack per 50 kg/hr
    ph.pwr_elec(i) = ph.n_pem(i) * isru.pwr_per_stack;
    
    h2_rate = water_kghr * (2/18);
    o2_rate = water_kghr * (16/18);
    ph.pwr_cryo(i) = h2_rate * isru.cryo_lh2_per_kghr + o2_rate * isru.cryo_lox_per_kghr;
    
    % ─── SHACKLETON POWER BUDGET ───
    ph.pwr_psr(i)  = ph.n_molei(i) * mi.pwr_tether_kW;
    ph.pwr_hab(i)  = ph.crew_spa(i) * hab.eclss_kW_per_crew + 50; % +50 kW base
    ph.pwr_proc_spa(i) = ph.proc_spa(i) * proc.power_per_circuit;
    ph.pwr_iz(i)   = 50 + ph.n_probe(i)*0.5;
    ph.pwr_bene_spa(i) = ph.bene_spa(i) * 27;
    
    ph.pwr_raw_spa(i) = ph.pwr_elec(i) + ph.pwr_cryo(i) + ph.pwr_psr(i) + ...
                        ph.pwr_hab(i) + ph.pwr_proc_spa(i) + ph.pwr_iz(i) + ph.pwr_bene_spa(i);
    ph.pwr_spa(i) = ph.pwr_raw_spa(i) * 1.20; % 20% contingency
    
    ph.solar_m2(i) = ph.pwr_spa(i) / solar.yield;
    eclipse_kW = ph.pwr_hab(i) + 60 + 10 + ph.pwr_proc_spa(i)*0.3;
    ph.n_fsp_spa(i) = ceil(eclipse_kW / fsp.pwr_kW);
    
    % ─── PKT POWER BUDGET (autonomous — no hab, no ECLSS) ───
    ph.pwr_proc_pkt(i) = ph.proc_pkt(i) * proc.power_per_circuit;
    ph.pwr_bene_pkt(i) = ph.bene_pkt(i) * 27;
    ph.pwr_skip_pkt(i) = ph.skip_pkt(i) * 0.3; % pad infrastructure
    ph.pwr_sentinel_pkt(i) = 5 + ph.proc_pkt(i)*0.1; % SENTINEL + comms
    
    if i == 1
        ph.pwr_pkt(i) = 0;
    else
        ph.pwr_pkt(i) = (ph.pwr_proc_pkt(i) + ph.pwr_bene_pkt(i) + ...
                         ph.pwr_skip_pkt(i) + ph.pwr_sentinel_pkt(i)) * 1.20;
    end
    % PKT uses 70% FSP baseload (solar unreliable at 14°N)
    ph.n_fsp_pkt(i) = ceil(ph.pwr_pkt(i) * 0.70 / fsp.pwr_kW);
    
    % ─── INFRASTRUCTURE COUNTS ───
    ph.hab_modules(i)  = ceil(ph.crew_spa(i) / hab.crew_per_module);
    ph.elz_pads_spa(i) = max(4, 2 + ceil(ph.tanker_trips(i)/200));
    ph.probe_pads(i)   = 2 + ceil(ph.n_probe(i)/20);
    ph.skip_pads_spa(i)= max(2, ceil(ph.skip_spa(i)/4));
    ph.collars(i)      = max(8, ceil(ph.n_probe(i)*0.30));
    
    ph.skip_pads_pkt(i) = max(0, ceil(ph.skip_pkt(i)/4));
    ph.elz_pads_pkt(i)  = max(0, min(i-1,1)*2 + ceil(ph.tanker_trips(i)/100));
    if i == 1
        ph.skip_pads_pkt(i) = 0; ph.elz_pads_pkt(i) = 0;
    end
    
    % ─── STARSHIP + MASS DRIVER EARTH RETURN ───
    % P7–P9: Starship propulsive return for all cargo
    % P10+: Escape-velocity mass driver at PKT (~2,400 m/s) launches REO
    %   canisters to Earth transfer orbit. Heat shield + parachute/retro
    %   landing. Zero propellant per delivery. Crew still use Starship.
    %   SPA validates SPA→PKT mass driver first (P10), then PKT builds
    %   escape-velocity driver (P10 late / P11).
    
    % Reagents to PKT (direct from Earth — Starship needed at all phases)
    ph.ss_reagent_pkt(i) = ceil(ph.proc_pkt(i) * proc.reagent_per_circuit / starship.cap_t);
    
    % REO return to Earth
    if i <= 3  % P7–P9: propulsive Starship return
        ph.ss_reo_return(i) = ceil(ph.reo_target(i) / starship.cap_t);
        ph.md_earth_launches(i) = 0;
    else  % P10+: mass driver return (escape velocity, no propellant)
        ph.ss_reo_return(i) = 0; % no Starship needed for REO
        % Mass driver canister: ~5 t each (heat shield + structure + REO payload)
        % Payload fraction ~70% → 3.5 t REO per canister
        md_earth_payload = 3.5; % t REO per canister
        ph.md_earth_launches(i) = ceil(ph.reo_target(i) / md_earth_payload);
    end
    
    % Crew rotation (Starship, ~annual, Shackleton only)
    ph.ss_crew_rotation(i) = max(1, ceil(ph.crew_spa(i) / 12)); % 12 crew per rotation flight
    
    % Shackleton cargo (reagents + equipment + consumables)
    ph.ss_spa(i) = max(2, ceil((ph.proc_spa(i)*proc.reagent_per_circuit + 20) / starship.cap_t));
    
    if i == 1
        ph.ss_reagent_pkt(i) = 0; ph.ss_reo_return(i) = 0; ph.md_earth_launches(i) = 0;
    end
end

%% ═══ PRINT RESULTS ═══

fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  KREEP CHAIN: REO Target → Raw Ore → Fleet → Processing\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %10s %10s %10s %6s %7s %6s %6s\n',...
    'Phase','REO t/yr','Conc t/yr','Raw t/yr','Sk_SP','Sk_PKT','Circ','Bene');
fprintf('  %s\n', repmat('-',1,82));
for i=1:ph.n
    fprintf('  %-12s %10s %10s %10s %6d %7d %6d %6d\n',...
        ph.lab{i},...
        fmtc(ph.reo_target(i),1),...
        fmtc(ph.concentrate(i)),...
        fmtc(ph.raw_kreep(i)),...
        ph.skip_spa(i), ph.skip_pkt(i),...
        ph.proc_total(i), ph.bene_spa(i)+ph.bene_pkt(i));
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  PROPELLANT DEMAND (t/yr) — All produced at Shackleton\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %8s %8s %8s %6s | %10s | %8s %5s\n',...
    'Phase','Sk_SPA','PROBE','Transfer','LS','Total_SPA','ISRU_sup','Marg');
fprintf('  %s\n', repmat('-',1,82));
for i=1:ph.n
    status = cond_str(ph.isru_margin(i)>=0, 'OK', 'FAIL');
    fprintf('  %-12s %8s %8s %8s %6.1f | %10s | %8s %5s\n',...
        ph.lab{i},...
        fmtc(ph.prop_skip_spa(i)),...
        fmtc(ph.prop_probe(i)),...
        fmtc(ph.prop_transfer_cost(i)),...
        ph.prop_ls(i),...
        fmtc(ph.prop_total_spa(i)),...
        fmtc(ph.isru_supply(i)),...
        status);
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  ISRU + POWER (Shackleton)\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %6s %5s %5s %8s %8s %8s %10s %8s %4s\n',...
    'Phase','MI','Nodes','PEM','Elec_kW','Cryo_kW','PSR_kW','Total_kW','Solar_m2','FSP');
fprintf('  %s\n', repmat('-',1,95));
for i=1:ph.n
    fprintf('  %-12s %6d %5d %5d %8s %8s %8s %10s %8s %4d\n',...
        ph.lab{i}, ph.n_molei(i), ph.n_nodes(i), ph.n_pem(i),...
        fmtc(ph.pwr_elec(i)),...
        fmtc(ph.pwr_cryo(i)),...
        fmtc(ph.pwr_psr(i)),...
        fmtc(ph.pwr_spa(i)),...
        fmtc(ph.solar_m2(i)),...
        ph.n_fsp_spa(i));
end

fprintf('\n══════════════════════════════════════════════════════════════════════\n');
fprintf('  PKT AUTONOMOUS BASE — Power + Infrastructure\n');
fprintf('══════════════════════════════════════════════════════════════════════\n');
fprintf('  %-12s %8s %6s %6s %6s %10s %5s\n',...
    'Phase','Proc_kW','Bene','SkPad','ELZ','Total_kW','FSP');
fprintf('  %s\n', repmat('-',1,65));
for i=1:ph.n
    fprintf('  %-12s %8s %6d %6d %6d %10s %5d\n',...
        ph.lab{i},...
        fmtc(ph.pwr_proc_pkt(i)),...
        ph.bene_pkt(i), ph.skip_pads_pkt(i), ph.elz_pads_pkt(i),...
        fmtc(ph.pwr_pkt(i)),...
        ph.n_fsp_pkt(i));
end

%% ═══ FULL SUMMARY ═══
fprintf('\n═══════════════════════════════════════════════════════════════════════\n');
fprintf('  PROGRAMME SCALING SUMMARY — PHASE BY PHASE\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');
for i = 1:ph.n
    fprintf('─── %s ─────────────────────────────────────────────\n', ph.lab{i});
    fprintf('  REO output:         %14s t/yr\n', fmtc(ph.reo_target(i),1));
    fprintf('  Raw KREEP:          %14s t/yr\n', fmtc(ph.raw_kreep(i)));
    fprintf('  SKIP:       %8d SPA + %8d PKT = %8d total\n',...
        ph.skip_spa(i), ph.skip_pkt(i), ph.skip_total(i));
    fprintf('  PROBE:      %8d\n', ph.n_probe(i));
    fprintf('  Transfer:   %14s | %s (%s/yr, %.0f%% eff)\n',...
        ph.transfer_method{i}, fmtc(ph.tanker_trips(i)), ...
        cond_str(ph.n_tankers(i)>0, [fmtc(ph.n_tankers(i)) ' tankers'], 'electric'), ...
        ph.transfer_eff(i)*100);
    fprintf('  PKT local:  %14s t/yr propellant (solar wind H₂ + ilmenite O₂)\n',...
        fmtc(ph.prop_pkt_local(i)));
    fprintf('  Proc circ:  %8d SPA + %8d PKT = %8d total\n',...
        ph.proc_spa(i), ph.proc_pkt(i), ph.proc_total(i));
    fprintf('  Crew:       %8d SPA + %8d PKT = %8d (PKT = autonomous)\n',...
        ph.crew_spa(i), ph.crew_pkt(i), ph.crew_total(i));
    fprintf('  MOLE-I:     %8d (%d nodes, %d ice sites)\n',...
        ph.n_molei(i), ph.n_nodes(i), ph.ice_sites(i));
    fprintf('  Prop SPA:   %14s t/yr\n', fmtc(ph.prop_total_spa(i)));
    fprintf('  Power SPA:  %14s kW\n', fmtc(ph.pwr_spa(i)));
    fprintf('  Power PKT:  %14s kW\n', fmtc(ph.pwr_pkt(i)));
    fprintf('  FSP:        %8d SPA + %8d PKT = %8d total\n',...
        ph.n_fsp_spa(i), ph.n_fsp_pkt(i), ph.n_fsp_spa(i)+ph.n_fsp_pkt(i));
    fprintf('  Starship:   %8d SPA + %8d crew + %8d PKT reagent + %8d REO prop\n',...
        ph.ss_spa(i), ph.ss_crew_rotation(i), ph.ss_reagent_pkt(i), ph.ss_reo_return(i));
    fprintf('  MassDriver: %8s Earth-return launches/yr (%.1f t REO each, no propellant)\n',...
        fmtc(ph.md_earth_launches(i)), 3.5);
    fprintf('\n');
end

%% ═══ GLOBAL DEMAND COMPARISON ═══
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('  GLOBAL REE DEMAND vs SELENITE SUPPLY\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');

earth_demand = [390000, 550000, 700000, 850000, 1000000, 1200000]; % t/yr REO
fprintf('  %-12s %12s %12s %10s\n', 'Phase','Selenite','Earth Demand','Share');
fprintf('  %s\n', repmat('-',1,52));
for i=1:ph.n
    pct = ph.reo_target(i) / earth_demand(i) * 100;
    fprintf('  %-12s %12s %12s %9.4f%%\n',...
        ph.lab{i},...
        fmtc(ph.reo_target(i)),...
        fmtc(earth_demand(i)), pct);
end
fprintf('\n');
fprintf('  P12 target: %.0f%% of projected 2100 demand\n',...
    ph.reo_target(end)/earth_demand(end)*100);
fprintf('  At P12: programme produces ~83%% of projected global REE demand.\n');
fprintf('  This is the threshold at which terrestrial REE mining becomes\n');
fprintf('  economically uncompetitive — the mission objective is achieved.\n\n');

%% ═══ FIGURES ═══
figure('Position',[50 50 1500 950],'Color','k','Name','SELENITE SCALE v1.1');

% 1. REO output vs Earth demand
subplot(2,3,1);
semilogy(1:ph.n, ph.reo_target, 'co-','LineWidth',2.5,'MarkerSize',9,'MarkerFaceColor','c');
hold on;
semilogy(1:ph.n, earth_demand, 'r--s','LineWidth',1.5,'MarkerSize',7,'MarkerFaceColor','r');
yline(1e6,'g--','LineWidth',1.5);
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],...
    'XColor','w','YColor','w','FontSize',8);
xtickangle(30);
ylabel('t/yr REO (log)','Color','w');
title('REO Output vs Earth Demand','Color','w','FontSize',11);
legend('Selenite','Earth demand','1 Mt/yr target','TextColor','w',...
    'Color',[.08 .10 .16],'Location','southeast','FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

% 2. SKIP fleet
subplot(2,3,2);
b = bar(1:ph.n, [ph.skip_spa; ph.skip_pkt]', 'stacked');
b(1).FaceColor = [.3 .6 .9]; b(2).FaceColor = [.9 .5 .2];
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],...
    'XColor','w','YColor','w','FontSize',8);
xtickangle(30);
ylabel('SKIP count','Color','w');
title('SKIP Fleet','Color','w','FontSize',11);
legend('SPA Basin','PKT (autonomous)','TextColor','w','Color',[.08 .10 .16],'FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

% 3. MOLE-I + ice sites
subplot(2,3,3);
yyaxis left;
bar(1:ph.n, ph.n_molei, 'FaceColor',[.2 .6 .9]);
ylabel('MOLE-I count','Color',[.3 .7 1]);
yyaxis right;
plot(1:ph.n, ph.ice_sites, 'ms-','LineWidth',2,'MarkerSize',8,'MarkerFaceColor','m');
ylabel('Ice mining sites','Color','m');
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],...
    'XColor','w','FontSize',8);
xtickangle(30);
title('Ice Mining Scale','Color','w','FontSize',11);
grid on; set(gca,'GridColor',[.2 .25 .35]);

% 4. Shackleton power breakdown
subplot(2,3,4);
pwr_matrix = [ph.pwr_elec; ph.pwr_cryo; ph.pwr_psr; ph.pwr_hab;...
              ph.pwr_proc_spa; ph.pwr_iz; ph.pwr_bene_spa]';
b4 = bar(1:ph.n, pwr_matrix, 'stacked');
colors = {[.2 .5 .8],[.3 .7 .9],[.5 .3 .7],[.2 .8 .4],[.9 .5 .2],[.6 .6 .6],[.7 .6 .4]};
for j=1:7, b4(j).FaceColor = colors{j}; end
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],...
    'XColor','w','YColor','w','FontSize',8);
xtickangle(30);
ylabel('kW','Color','w');
title('Shackleton Power','Color','w','FontSize',11);
legend('Electrolysis','Cryo','PSR Fleet','Hab','Processing','IZ','Bene',...
    'TextColor','w','Color',[.08 .10 .16],'Location','northwest','FontSize',6);
grid on; set(gca,'GridColor',[.2 .25 .35]);

% 5. Processing circuits (SPA vs PKT)
subplot(2,3,5);
b5 = bar(1:ph.n, [ph.proc_spa; ph.proc_pkt]', 'stacked');
b5(1).FaceColor = [.3 .6 .9]; b5(2).FaceColor = [.9 .5 .2];
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],...
    'XColor','w','YColor','w','FontSize',8);
xtickangle(30);
ylabel('Circuits','Color','w');
title('Processing Circuits','Color','w','FontSize',11);
legend('Shackleton','PKT (autonomous)','TextColor','w','Color',[.08 .10 .16],'FontSize',7);
grid on; set(gca,'GridColor',[.2 .25 .35]);

% 6. % of global demand displaced
subplot(2,3,6);
pct_displaced = ph.reo_target ./ earth_demand * 100;
bar(1:ph.n, pct_displaced, 'FaceColor',[.2 .85 .4]);
hold on;
yline(50,'r--','50% displacement','LineWidth',1.5,'Color','r','LabelColor','r');
yline(83,'g--','Target: 83%','LineWidth',1.5,'Color','g','LabelColor','g');
set(gca,'XTick',1:ph.n,'XTickLabel',ph.lab,'Color',[.04 .06 .1],...
    'XColor','w','YColor','w','FontSize',8);
xtickangle(30);
ylabel('% of Earth REE demand','Color','w');
title('Global Demand Displacement','Color','w','FontSize',11);
grid on; set(gca,'GridColor',[.2 .25 .35]);

sgtitle('SELENITE PROGRAMME — 100-Year Scaling Analysis (v1.1)',...
    'Color','w','FontSize',14,'FontWeight','bold');

fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('  ANALYSIS COMPLETE — %d phases, %d figures\n', ph.n, 6);
fprintf('  KEY FINDING: PKT autonomous base is MANDATORY for mission success.\n');
fprintf('  Shackleton is the propellant engine. PKT is the REE factory.\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');