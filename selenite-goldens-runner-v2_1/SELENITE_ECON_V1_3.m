%% SELENITE_ECON v1.3 — 200-Year Bottom-Up Economic Model
%  Extended to capture post-build-out steady state and P13+ operations
%  
%  KEY CHANGES FROM v1.2:
%    - 200-year horizon (Y0-Y200) to capture steady-state payback
%    - REO ramp constrained by Starship cadence (~200 kt/yr cargo cap)
%    - Circuit throughput sensitivity (0.4 / 0.8 / 1.2 t/yr)
%    - Geopolitical supply-chain insurance externality ($10-25B/yr)
%    - P13+ steady state at 1.25 Mt/yr REO (no further build-out)
%    - 50% H2 marginal attribution on Ir
%    - PROBE Mk III SEP (DG-11.6) as sensitivity
%
%  Author: Jason Stewart | April 2026

clear; close all; clc;
fprintf('SELENITE_ECON v1.3 — 200-Year Model\n');
fprintf('ECN-019 Rev B | %s\n\n', datestr(now));

%% ═══════════════════════════════════════════════════════════════
%  1. UNIT SPECIFICATIONS
%  ═══════════════════════════════════════════════════════════════

% --- Circuit design options ---
% Three designs: batch (existing), continuous-flow, optimised
% Physics: acid bake 2-4hr, leach 4-8hr, precip 1-2hr per stage
% Continuous-flow eliminates batch dead time (~30% of cycle)
% Larger vessels: cube-square law → 1.5x mass for 2x volume

circuit_designs = struct();
circuit_designs(1).name = 'Batch (0.4 t/yr)';
circuit_designs(1).reo_yr = 0.4;
circuit_designs(1).mass_kg = 15000;
circuit_designs(1).power_kw = 180;

circuit_designs(2).name = 'Continuous-flow (0.8 t/yr)';
circuit_designs(2).reo_yr = 0.8;
circuit_designs(2).mass_kg = 22000;  % 1.47x mass for 2x throughput
circuit_designs(2).power_kw = 300;   % ~1.67x power (pumps run continuous)

circuit_designs(3).name = 'Optimised (1.2 t/yr)';
circuit_designs(3).reo_yr = 1.2;
circuit_designs(3).mass_kg = 28000;  % 1.87x mass for 3x throughput
circuit_designs(3).power_kw = 400;

% SELECT ACTIVE DESIGN (run sensitivity by changing this)
CIRCUIT_DESIGN = 3;  % 1=batch, 2=continuous, 3=optimised (RECOMMENDED)

circuit.reo_yr    = circuit_designs(CIRCUIT_DESIGN).reo_yr;
circuit.mass_kg   = circuit_designs(CIRCUIT_DESIGN).mass_kg;
circuit.power_kw  = circuit_designs(CIRCUIT_DESIGN).power_kw;
circuit.life_yr   = 20;
circuit.maint_frac = 0.005;  % 0.5% of mass/yr (mature foundry, in-situ spares)
circuit.earth_frac = @(y) min(1.0, max(0.10, 1.0 - (y-25)*0.03));

fprintf('Circuit design: %s\n', circuit_designs(CIRCUIT_DESIGN).name);
fprintf('  %.1f t/yr REO, %d kg, %d kW per circuit\n', ...
    circuit.reo_yr, circuit.mass_kg, circuit.power_kw);
fprintf('  Circuits for 1.25 Mt/yr: %s\n\n', ...
    num2str(ceil(1250000/circuit.reo_yr)));

% --- Other unit specs (unchanged from v1.2) ---
hauler.mass_kg = 1450; hauler.throughput_yr = 1500;
hauler.life_yr = 10; hauler.maint_kg_yr = 9;
hauler.earth_frac = @(y) min(1.0, max(0.43, 1.0 - (y-25)*0.0285));

conv.mass_per_km = 100000; conv.earth_frac = 0.05; conv.maint_frac_yr = 0.005;

msr.power_mw = 100; msr.mass_kg = 50000; msr.life_yr = 20;
msr.earth_frac = @(y) max(0.3, min(1.0, 1.0 - (y-45)*0.02));

fsp.power_kw = 40; fsp.mass_kg = 6600;

can.reo_payload_t = 3.5; can.earth_kg = 28;

molei.propellant_yr = 5692; molei.mass_kg = 360;

probe.propellant = 6654; probe.mass_kg = 800;
probe.pgm_per_mission = 0.0175;

skip.propellant_yr = 83000; skip.count = 8;

sinter.mass_kg = 2200; armc.mass_kg = 1500;

reagent.per_circuit_yr = 49000;
reagent.isru_frac = @(y) min(0.98, max(0, (y-9)*0.03));

%% ═══════════════════════════════════════════════════════════════
%  2. ECONOMIC PARAMETERS (200-year)
%  ═══════════════════════════════════════════════════════════════

Y = (0:200)'; N = length(Y);

launch_cost = arrayfun(@(y) ...
    6000*(y<25) + 4000*(y>=25 & y<45) + 2000*(y>=45), Y);

dr = arrayfun(@(y) 0.03*(y<=30) + 0.025*(y>30 & y<=75) + 0.02*(y>75), Y);
df = cumprod(1 ./ (1 + dr));

contingency = arrayfun(@(y) ...
    1.50*(y<25) + 1.35*(y>=25 & y<45) + 1.25*(y>=45), Y);

insitu_cost_per_kg = 100;
scc = 190;

%% ═══════════════════════════════════════════════════════════════
%  3. REO RAMP — Starship cadence constrained
%  ═══════════════════════════════════════════════════════════════
%  Maximum Earth cargo: ~200 kt/yr (2,000 Starship flights/yr)
%  This constrains the build rate, extending build-out beyond Y100
%  Target: 1.25 Mt/yr REO at P13 (steady state)

reo_final = 2500000;  % 2.5 Mt/yr — full replacement of terrestrial REE mining

% Cadence-constrained ramp to 2.5 Mt/yr:
% P7: proof of concept. P8: PKT online. P9: mass driver.
% P10: full-scale. P11: 10% displacement. P12: scaling.
% P13: 1.25 Mt/yr milestone (50% replacement, Y140)
% P14: 2.5 Mt/yr target (100% replacement, Y180). Steady state.
reo_knots_y = [0  15  18   25    28    35    45     60      80     100    120    140    160    180    200];
reo_knots_v = [0   0   0   0.4   125   125   1000   10000   100000 250000 500000 1000000 1500000 2500000 2500000];

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
            reo_target(i) = exp(log(r0) + frac*(log(r1) - log(r0)));
        end
    end
end
% Cap at 1.25 Mt/yr
reo_target = min(reo_target, reo_final);

% PROBE fleet (same as v1.2, extended)
% PROBE Mk I/II fleet (chemical, lands at SPA)
% Phases DOWN as Mk III takes over bulk asteroid work from Y60
% Further reduces once captured asteroid processing starts Y85
% Retains ~30 units for specialist SPA-based short-range ops
probe_knots_y = [0 9  15  25  35   45   60   70   80   85   200];
probe_knots_v = [0 3  30  96  190  230  260  150  50   30   30];
probe_fleet = floor(interp1(probe_knots_y, probe_knots_v, Y, 'linear', 30));
% Y60-Y80: Mk III replaces bulk asteroid mining, Mk I/II fleet shrinks
% Y85+: Captured asteroid produces 36.5 t/yr PGM via dedicated infra (no PROBEs)
%        Mk I/II retained only for SPA short-range ops and contingency

skip_active = arrayfun(@(y) ...
    skip.count*(y>=7 & y<35) + max(0, skip.count*(1-(y-35)/10))*(y>=35 & y<45), Y);

frontier_km = arrayfun(@(y) min(150, max(0, (y-28)*2))*(y>=28), Y);
tier3_frac = arrayfun(@(y) min(0.55, max(0, (y-40)*0.01))*(y>=40), Y);

%% ═══════════════════════════════════════════════════════════════
%  4. INFRASTRUCTURE DERIVATION
%  ═══════════════════════════════════════════════════════════════

circuits_needed = ceil(reo_target / circuit.reo_yr);
regolith_yr = reo_target / 0.0005;
hauler_ore_frac = 1 - tier3_frac;
haulers_needed = ceil(regolith_yr .* hauler_ore_frac / hauler.throughput_yr);
conv_km_needed = regolith_yr .* tier3_frac / 20000;

power_kw = circuits_needed * circuit.power_kw;
msr_count = zeros(N,1); fsp_count = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y < 35
        fsp_count(i) = ceil(power_kw(i) / fsp.power_kw);
    elseif y < 45
        mf = (y-35)/10;
        msr_count(i) = ceil(power_kw(i)*mf / (msr.power_mw*1000));
        fsp_count(i) = ceil(power_kw(i)*(1-mf) / fsp.power_kw);
    else
        msr_count(i) = ceil(power_kw(i) / (msr.power_mw*1000));
        fsp_count(i) = min(20, fsp_count(max(1,i-1)));
    end
end

prop_demand_kg = probe_fleet*probe.propellant + skip_active*skip.propellant_yr + 100000;
molei_needed = ceil(prop_demand_kg / molei.propellant_yr);

canisters_yr = zeros(N,1);
for i = 1:N
    if Y(i) >= 35, canisters_yr(i) = ceil(reo_target(i)/can.reo_payload_t); end
end

pgm_production = probe_fleet * probe.pgm_per_mission;

%% ═══════════════════════════════════════════════════════════════
%  5. EARTH CARGO — cadence constrained
%  ═══════════════════════════════════════════════════════════════

d_circuits = max(0, diff([0; circuits_needed]));
d_haulers = max(0, diff([0; haulers_needed]));
d_conv_km = max(0, diff([0; conv_km_needed]));
d_msr = max(0, diff([0; msr_count]));
d_fsp = max(0, diff([0; fsp_count]));
d_molei = max(0, diff([0; molei_needed]));
d_probes = max(0, diff([0; probe_fleet]));

cargo_circuits = zeros(N,1);
for i=1:N, cargo_circuits(i) = d_circuits(i)*circuit.mass_kg*circuit.earth_frac(Y(i))/1000; end
cargo_haulers = zeros(N,1);
for i=1:N, cargo_haulers(i) = d_haulers(i)*hauler.mass_kg*hauler.earth_frac(Y(i))/1000; end
cargo_conveyors = d_conv_km * conv.mass_per_km * conv.earth_frac / 1000;
cargo_msr = zeros(N,1);
for i=1:N, cargo_msr(i) = d_msr(i)*msr.mass_kg*msr.earth_frac(Y(i))/1000; end
cargo_fsp = d_fsp * fsp.mass_kg / 1000;
cargo_molei = d_molei * (molei.mass_kg + 27) / 1000;
cargo_probes = d_probes * probe.mass_kg / 1000;
cargo_canisters = canisters_yr * can.earth_kg / 1000;

cargo_reagent = zeros(N,1);
for i=1:N
    cargo_reagent(i) = circuits_needed(i)*reagent.per_circuit_yr*(1-reagent.isru_frac(Y(i)))/1e6;
end

maint_circuits = zeros(N,1);
for i=1:N, maint_circuits(i) = circuits_needed(i)*circuit.mass_kg*circuit.maint_frac*circuit.earth_frac(Y(i))/1000; end
maint_haulers = haulers_needed * hauler.maint_kg_yr / 1000;
maint_conv = conv_km_needed * conv.mass_per_km * conv.maint_frac_yr * conv.earth_frac / 1000;
maint_msr = zeros(N,1);
for i=1:N, maint_msr(i) = msr_count(i)/msr.life_yr*msr.mass_kg*msr.earth_frac(Y(i))/1000; end

cargo_construction = zeros(N,1);
cargo_construction(26) = (20*sinter.mass_kg + 10*hauler.mass_kg + 5*armc.mass_kg + 4*fsp.mass_kg + 85000)/1000;
cargo_construction(29) = 62/1;  % crew hab + foundry + catapult demo

cargo_ybco = zeros(N,1);
cargo_ybco(23) = 30; cargo_ybco(24) = 30; cargo_ybco(36) = 50; cargo_ybco(44) = 30;

cargo_spa_ops = arrayfun(@(y) ...
    18*(y<7) + 23*(y>=7&y<9) + 30*(y>=9&y<15) + 20*(y>=15&y<25) + 15*(y>=25), Y);

% --- Construction fleet (ARM-C, SINTER, SENTINEL, charging hubs) ---
% Scales with circuit build rate during construction, then maintenance fleet
armc_needed = ceil(d_circuits / 500);    % 1 ARM-C per 500 circuits/yr
sinter_needed_build = ceil(d_circuits / 200);  % 1 SINTER per 200 circuits/yr
sentinel_needed = ceil(circuits_needed / 500); % 1 per 500 circuits (monitoring)
hubs_needed = ceil(haulers_needed / 100);      % 1 per 100 haulers

d_sentinel = max(0, diff([0; sentinel_needed]));
d_hubs = max(0, diff([0; hubs_needed]));

cargo_armc = armc_needed * 1500 / 1000;          % ARM-C 100% Earth
cargo_sinter_build = sinter_needed_build * 2200 / 1000;  % SINTER 100% Earth
cargo_sentinel = d_sentinel * 80 / 1000;          % SENTINEL 100% Earth
cargo_hubs = d_hubs * 5000 * 0.05 / 1000;        % Hubs 95% in-situ, 5% Earth

% Maintenance fleet replacement (steady-state)
maint_armc = zeros(N,1);
maint_sinter = zeros(N,1);
maint_sentinel = zeros(N,1);
for i = 1:N
    % Keep minimum fleet for maintenance ops even when not building
    active_armc = max(20, armc_needed(i));  % min 20 ARM-C for repairs
    active_sinter = max(50, sinter_needed_build(i));  % min 50 SINTER
    maint_armc(i) = active_armc / 10 * 1500 / 1000;  % 10-yr life
    maint_sinter(i) = active_sinter / 15 * 2200 / 1000;  % 15-yr life
    maint_sentinel(i) = sentinel_needed(i) / 10 * 80 / 1000;  % 10-yr life
end

cargo_construction_fleet = cargo_armc + cargo_sinter_build + cargo_sentinel + ...
    cargo_hubs + maint_armc + maint_sinter + maint_sentinel;

% --- PROBE Mk III SEP fleet (DG-11.6, baseline from Y60) ---
% 1,714 units for bulk remote asteroid mining during build-up
% Phases down after captured asteroid infra handles bulk processing:
%   Y60-Y85: Full fleet build-out and bulk mining operations
%   Y85-Y115: Shifts to prospecting for C-type and S-type captures
%   Y115+: All 3 captures done. Fleet reduces to ~300 for future prospecting
% Never lands on Moon. EM anchoring. LLO canister ejection.
mkiii_target = 1714;
mkiii_mass_kg = 1200;
mkiii_life = 15;
mkiii_active = zeros(N,1);
mkiii_build = zeros(N,1);
mkiii_pgm = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y >= 60 && y < 80      % Build-out phase
        mkiii_active(i) = min(mkiii_target, (y-60)/20 * mkiii_target);
        mkiii_build(i) = mkiii_target / 20;
    elseif y >= 80 && y < 115  % Full fleet, bulk ops + prospecting
        mkiii_active(i) = mkiii_target;
    elseif y >= 115            % All captures done, reduce to prospecting fleet
        mkiii_active(i) = 300;
    end
    mkiii_replace = mkiii_active(i) / mkiii_life;
    mkiii_pgm(i) = mkiii_active(i) * probe.pgm_per_mission * 0.5;
end
cargo_mkiii_leo = zeros(N,1);
for i = 1:N
    build = 0;
    if Y(i) >= 60 && Y(i) < 80, build = mkiii_target/20; end
    cargo_mkiii_leo(i) = (build + mkiii_active(i)/mkiii_life) * mkiii_mass_kg / 1000;
end

% --- Asteroid Redirect Tugs ---
% ~50,000 kg each. Earth-built. Self-transfer (SEP). 
% 3 diversified captures: M-type (Y65), C-type (Y85), S-type (Y105)
% Each tug: ~10 year redirect campaign. Reusable for subsequent missions.
% Fleet: 2 tugs initially (redundancy), scaling to 3-5 for simultaneous ops
tug_mass_kg = 50000;
tug_life = 20;
tug_fleet = arrayfun(@(y) ...
    0*(y<65) + 2*(y>=65 & y<85) + 3*(y>=85 & y<105) + 5*(y>=105), Y);
d_tugs = max(0, diff([0; tug_fleet]));
cargo_tugs_leo = (d_tugs + tug_fleet/tug_life) * tug_mass_kg / 1000;  % t/yr to LEO

% --- DRO Infrastructure + Diversified Asteroid Strategy ---
% BASE SPECIALISATION:
%   SPA = Asteroid processing hub (M/C/S-type). All PROBE/asteroid material
%         processed at SPA. Products mass-driven to Earth or PKT as needed.
%   PKT = KREEP REO processing ONLY. Every km² is valuable ore — no non-KREEP
%         infrastructure built on PKT surface.
%
% Three captures, each enabling the next:
%   Y75 capture → Y85 processing: M-type (200m, ~30 Mt)
%     Fe-Ni + PGM. 36.5 t/yr PGM. 80+ year campaign on single asteroid.
%   Y95 capture → Y105 processing: C-type (~100m, carbonaceous)
%     Water (propellant independence), Carbon (PTFE, polymers, filter cloths),
%     Nitrogen (ammonia, fertiliser). Enables circuit Earth frac 10%→3%.
%     Carbon feedstock enables S-type Si refining.
%   Y115 capture → Y125 processing: S-type/E-type (~100m, enstatite)
%     Silicon (semiconductor-grade via carbothermic reduction with C-type C),
%     Copper (from enstatite sulfides, electrolytic refining).
%     Enables circuit Earth frac 3%→<1%. Near-complete Earth independence.
%
% ALL processing facilities at SPA (not PKT):
%   M-type PGM hydromet: exists from P5+ PROBE heritage
%   C-type pyrolysis + Fischer-Tropsch + polymer synthesis: Y105
%   S-type Si refinery (Czochralski) + Cu electrolysis: Y125
%   Products shipped SPA→PKT via mass driver where needed for circuit fabrication

cargo_dro_infra = zeros(N,1);
% M-type infrastructure (Y70-85)
cargo_dro_infra(71) = 110;  % Y70: SPA→Earth MD YBCO (60t) + EM catcher expansion (50t)
cargo_dro_infra(81) = 50;   % Y80: Laser Ablation Truss Earth components (to DRO)
cargo_dro_infra(86) = 50;   % Y85: DRO→SPA MD YBCO (30t) + processing facility (20t)
% C-type infrastructure (Y95-105) — ALL AT SPA
cargo_dro_infra(96) = 30;   % Y95: C-type redirect tug dispatch
cargo_dro_infra(106) = 40;  % Y105: Pyrolysis + Fischer-Tropsch at SPA
% S-type infrastructure (Y115-125) — ALL AT SPA
cargo_dro_infra(116) = 30;  % Y115: S-type redirect tug dispatch
cargo_dro_infra(126) = 60;  % Y125: Si refinery (Czochralski) + Cu electrolysis at SPA

% --- SPA MSR fleet for asteroid processing power ---
% SPA needs its own MSR units for C-type and S-type processing
% ThCl₄ fuel supplied from PKT→SPA mass driver (already exists from P9)
% Y105: 1 MSR for C-type pyrolysis (~50 MWe)
% Y125: +1 MSR for S-type Si refinery (~100 MWe)
% Y140+: +1 MSR for scaled ops
spa_msr_count = arrayfun(@(y) ...
    0*(y<105) + 1*(y>=105 & y<125) + 2*(y>=125 & y<140) + 3*(y>=140), Y);
d_spa_msr = max(0, diff([0; spa_msr_count]));
cargo_spa_msr = zeros(N,1);
maint_spa_msr = zeros(N,1);
for i = 1:N
    ef = msr.earth_frac(Y(i));
    cargo_spa_msr(i) = d_spa_msr(i) * msr.mass_kg * ef / 1000;
    maint_spa_msr(i) = spa_msr_count(i) / msr.life_yr * msr.mass_kg * ef / 1000;
end

% --- PROBE salvage/recycling ---
% Decommissioned Mk I/II PROBEs recycled at SPA for materials
% ~800 kg each × (260 peak - 30 retained) = ~184 t Fe-Ni recovered
% Recovered over Y60-Y80 as fleet phases down
% Small but represents circular economy principle
probe_salvage_feni = zeros(N,1);
for i = 2:N
    fleet_reduction = max(0, probe_fleet(i-1) - probe_fleet(i));
    probe_salvage_feni(i) = fleet_reduction * probe.mass_kg * 0.7 / 1000;  % 70% recoverable
end

% PGM from single M-type asteroid (Y85+, one asteroid only)
% NOTE: This PGM comes from DEDICATED INFRASTRUCTURE (Laser Ablation Truss
% + magnetic separation + mass driver), NOT from PROBEs. PROBEs are for
% remote uncaptured asteroids only. Captured asteroids have permanent
% facilities attached to them — fully automated, zero propellant.
captured_asteroid_pgm = zeros(N,1);
for i = 1:N
    if Y(i) >= 85
        captured_asteroid_pgm(i) = 36.5;  % t/yr from single M-type
    end
end

% --- Circuit Earth fraction reduction from asteroid resources ---
% Baseline: 10% at maturity (sensors, PTFE, seals, electronics from Earth)
% Post C-type (Y105+): PTFE, polymer seals, filter cloths in-situ → 3%
% Post S-type (Y125+): Si sensors, Cu wiring in-situ → <1%
% Recalculate circuit cargo with asteroid-adjusted Earth fraction
for i = 1:N
    y = Y(i);
    ef_base = min(1.0, max(0.10, 1.0 - (y-25)*0.03));  % original
    % C-type benefit: 10%→3% over Y105-Y115
    if y >= 105
        ctype_reduction = 0.07 * min(1, (y-105)/10);
        ef_base = max(0.03, ef_base - ctype_reduction);
    end
    % S-type benefit: 3%→0.8% over Y125-Y135
    if y >= 125
        stype_reduction = 0.022 * min(1, (y-125)/10);
        ef_base = max(0.008, ef_base - stype_reduction);
    end
    % Recalculate circuit cargo and maintenance with updated Earth fraction
    cargo_circuits(i) = d_circuits(i) * circuit.mass_kg * ef_base / 1000;
    maint_circuits(i) = circuits_needed(i) * circuit.mass_kg * circuit.maint_frac * ef_base / 1000;
    insitu_circuits(i) = d_circuits(i) * circuit.mass_kg * (1-ef_base) / 1000;
end

earth_cargo = cargo_circuits + cargo_haulers + cargo_conveyors + ...
    cargo_msr + cargo_fsp + cargo_molei + cargo_probes + ...
    cargo_canisters + cargo_reagent + ...
    maint_circuits + maint_haulers + maint_conv + maint_msr + ...
    cargo_construction + cargo_ybco + cargo_spa_ops + ...
    cargo_construction_fleet + cargo_dro_infra;

% In-situ mass
insitu_circuits = zeros(N,1);
for i=1:N, insitu_circuits(i) = d_circuits(i)*circuit.mass_kg*(1-circuit.earth_frac(Y(i)))/1000; end
insitu_haulers = zeros(N,1);
for i=1:N, insitu_haulers(i) = d_haulers(i)*hauler.mass_kg*(1-hauler.earth_frac(Y(i)))/1000; end
insitu_conveyors = d_conv_km * conv.mass_per_km * (1-conv.earth_frac) / 1000;
insitu_total = insitu_circuits + insitu_haulers + insitu_conveyors;

%% ═══════════════════════════════════════════════════════════════
%  6. REVENUE & ENVIRONMENTAL MODEL
%  ═══════════════════════════════════════════════════════════════

reo_demand_2026 = 400000;
reo_demand = reo_demand_2026 * (1.02).^Y;
% Cap demand growth at ~2.5 Mt/yr (population ~10B, recycling, efficiency)
reo_demand = min(reo_demand, 2500000);
supply_frac = reo_target ./ reo_demand;
reo_price = max(5000, 15000 * (1 - 0.6*supply_frac));

rev_reo = reo_target .* reo_price / 1e6;
% PGM: baseline PROBE (Mk I/II) + Mk III + captured asteroid
total_pgm = pgm_production + mkiii_pgm + captured_asteroid_pgm;
rev_pgm = total_pgm * 50e6 / 1e6;  % $50k/kg for all PGM
rev_direct = rev_reo + rev_pgm;

% Ext 1: REO mining displacement
ext_reo = reo_target * 73700 / 1e6;
co2_avoided_reo = reo_target * 30;

% Ext 2: H2 enabling (50% attribution, ALL Ir sources)
ir_frac = 0.15; h2_attribution = 0.50;
pem_gw_per_t_ir = 1.0; h2_per_gw_yr = 150000;
h2_co2_mult = 12; pem_life = 20;
% Total Ir: PROBE Mk I/II + Mk III + captured asteroid
total_ir = total_pgm * ir_frac;
ir_attributed = total_ir * h2_attribution;
pem_gw = zeros(N,1);
for i=2:N
    pem_gw(i) = pem_gw(i-1) + ir_attributed(i)*pem_gw_per_t_ir;
    if i>pem_life, pem_gw(i) = pem_gw(i) - ir_attributed(i-pem_life)*pem_gw_per_t_ir; end
    pem_gw(i) = max(0, pem_gw(i));
end
co2_avoided_h2 = pem_gw * h2_per_gw_yr * h2_co2_mult;
ext_h2 = co2_avoided_h2 * scc / 1e6;

% Ext 3: Rocket emissions
tanker_ratio = arrayfun(@(y) 14*(y<25)+8*(y>=25&y<45)+5*(y>=45), Y);
fossil_frac = arrayfun(@(y) ...
    1.00*(y<30) + max(0.80,1.00-(y-30)*0.0133)*(y>=30&y<45) + ...
    max(0.30,0.80-(y-45)*0.0333)*(y>=45&y<60) + ...
    max(0.05,0.30-(y-60)*0.0125)*(y>=60&y<80) + 0.05*(y>=80), Y);
total_launches = (earth_cargo/100) .* tanker_ratio;
co2_rockets = total_launches * 2750 .* fossil_frac;
ext_rockets = -co2_rockets * scc / 1e6;

% Ext 4: Geopolitical supply-chain insurance
% Ref: China 85-90% REE processing; 2010-11 14x price spike; 2025 controls
% EU gas crisis: >€1T from 40% dependency. REE at 85% = higher risk.
% Disruption probability: >50% per decade = ~5%/yr
% Disruption cost: $200-500B (supply chain reconfiguration)
% Expected annual avoided cost: proportional to lunar supply fraction
% At 50%+ displacement: insurance value ~$15B/yr (central)
% Ramps with supply fraction: zero until meaningful displacement (~1%)
geo_insurance_per_yr = 15000;  % $M/yr at full displacement
geo_threshold = 0.01;  % insurance kicks in at 1% supply fraction
ext_geo = zeros(N,1);
for i=1:N
    if supply_frac(i) > geo_threshold
        ext_geo(i) = geo_insurance_per_yr * min(1, supply_frac(i)/0.5);
        % Scales linearly to full value at 50% displacement
    end
end

ext_total = ext_reo + ext_h2 + ext_rockets + ext_geo;
rev_total = rev_direct + ext_total;

%% ═══════════════════════════════════════════════════════════════
%  7. COST MODEL
%  ═══════════════════════════════════════════════════════════════

cost_insitu = insitu_total*1000 * insitu_cost_per_kg / 1e6;
cost_rd = arrayfun(@(y) 500*(y<25)+1000*(y>=25&y<45)+1500*(y>=45&y<60)+2000*(y>=60), Y);

% LEO-only costs: Mk III PROBEs + Redirect Tugs (self-transfer, no tanker ratio)
% LEO launch cost: mature Starship ~$500/kg
leo_cost_per_kg = 500;
cost_mkiii = cargo_mkiii_leo * 1000 * leo_cost_per_kg .* contingency / 1e6;
cost_tugs = cargo_tugs_leo * 1000 * leo_cost_per_kg .* contingency / 1e6;

% DRO facility operations (crew rotation if crewed, or autonomous maintenance)
cost_dro_ops = arrayfun(@(y) 0*(y<85) + 200*(y>=85), Y);  % $200M/yr DRO station

% --- Asteroid processing facility operating costs (on Moon) ---
% M-type: PGM hydromet at SPA (exists from PROBE heritage, no additional)
% C-type: Pyrolysis + Fischer-Tropsch + polymer synthesis at PKT
%   Power: ~50 MW (1 MSR), reagents, maintenance
%   Operating cost: ~$500M/yr from Y105
% S-type: Czochralski Si refinery + Cu electrolysis at PKT
%   Power: ~100 MW (1 MSR), ultra-pure environment, precision equipment
%   Operating cost: ~$800M/yr from Y125
% Additional MSR for asteroid processing: 2 units × 50,000 kg × 30% Earth
%   One-time cargo already in dro_infra; operating cost is maintenance
cost_asteroid_processing = arrayfun(@(y) ...
    0*(y<105) + 500*(y>=105 & y<125) + 1300*(y>=125), Y);  % $M/yr

% --- Benefit: C-type water reduces remaining MOLE-I dependency ---
% By Y110, Mk I/II fleet already phased down to ~30 units (from 286)
% Propellant demand: 30 × 6,654 = ~200 t/yr (vs ~1,900 t/yr at 286 units)
% C-type water makes even this unnecessary → MOLE-I drops to ~50 (crew ECLSS only)
% Mk I/II could switch to C-type water propellant entirely
maint_molei_saving = zeros(N,1);
for i = 1:N
    if Y(i) >= 110  % C-type water fully online
        % MOLE-I requirement drops to ~50 (crew only, not PROBE propellant)
        current_molei = molei_needed(i);
        reduced_molei = 50;
        saved = max(0, current_molei - reduced_molei);
        maint_molei_saving(i) = saved * molei.mass_kg * 0.02 / 1000;
    end
end

% --- Benefit: M-type Fe-Ni reduces hauler/canister Earth fraction ---
% M-type produces ~328 kt/yr Fe-Ni (far exceeds foundry demand)
% Hauler Earth fraction already modelled declining to 43%
% With abundant M-type Fe-Ni, hauler in-situ fraction improves further
% Model: hauler Earth fraction drops additional 10% from Y90
% (Fe-Ni frames, bucket mechanisms, hopper all from asteroid metal)
for i = 1:N
    if Y(i) >= 90  % M-type Fe-Ni abundant
        mtype_bonus = 0.10 * min(1, (Y(i)-90)/10);
        ef_h = hauler.earth_frac(Y(i)) - mtype_bonus;
        ef_h = max(0.20, ef_h);  % floor at 20% (avionics + BMS irreducible)
        % Recalculate hauler cargo with improved fraction
        cargo_haulers(i) = d_haulers(i) * hauler.mass_kg * ef_h / 1000;
        maint_haulers(i) = haulers_needed(i) * hauler.maint_kg_yr * (ef_h/hauler.earth_frac(Y(i))) / 1000;
    end
end

% Recalculate earth_cargo with all corrections
earth_cargo = cargo_circuits + cargo_haulers + cargo_conveyors + ...
    cargo_msr + cargo_fsp + cargo_molei + cargo_probes + ...
    cargo_canisters + cargo_reagent + ...
    maint_circuits + maint_haulers + maint_conv + maint_msr + ...
    cargo_construction + cargo_ybco + cargo_spa_ops + ...
    cargo_construction_fleet + cargo_dro_infra + ...
    cargo_spa_msr + maint_spa_msr - maint_molei_saving;
earth_cargo = max(0, earth_cargo);  % floor at zero

% NOW compute launch cost from corrected earth_cargo
cost_launch = earth_cargo*1000 .* launch_cost .* contingency / 1e6;

cost_total = cost_launch + cost_insitu + cost_rd + cost_mkiii + cost_tugs + ...
    cost_dro_ops + cost_asteroid_processing;

%% ═══════════════════════════════════════════════════════════════
%  8. NPV & METRICS
%  ═══════════════════════════════════════════════════════════════

net_total = rev_total - cost_total;
net_direct = rev_direct - cost_total;
npv_total = cumsum(net_total .* df);
npv_direct = cumsum(net_direct .* df);
cum_cost = cumsum(cost_total);
cum_rev = cumsum(rev_total);

be_total = find(cumsum(rev_total - cost_total) > 0, 1, 'first');

fprintf('═══════════════════════════════════════════════\n');
fprintf('  200-YEAR PROGRAMME METRICS\n');
fprintf('═══════════════════════════════════════════════\n\n');
fprintf('Total cost (200 yr):        $%.2f T\n', cum_cost(end)/1e6);
fprintf('  Earth launch:             $%.2f T\n', sum(cost_launch)/1e6);
fprintf('  In-situ fabrication:      $%.2f T\n', sum(cost_insitu)/1e6);
fprintf('  Mk III PROBEs (LEO):      $%.2f T\n', sum(cost_mkiii)/1e6);
fprintf('  Redirect tugs (LEO):      $%.2f T\n', sum(cost_tugs)/1e6);
fprintf('  DRO operations:           $%.2f T\n', sum(cost_dro_ops)/1e6);
fprintf('  Asteroid processing:      $%.2f T\n', sum(cost_asteroid_processing)/1e6);
fprintf('  R&D / programme mgmt:     $%.2f T\n', sum(cost_rd)/1e6);
fprintf('Direct revenue:             $%.2f T\n', sum(rev_direct)/1e6);
fprintf('  REO sales:                $%.2f T\n', sum(rev_reo)/1e6);
fprintf('  PGM sales (all sources):  $%.2f T\n', sum(rev_pgm)/1e6);
fprintf('    Mk I/II PROBEs:         %.0f t total PGM\n', sum(pgm_production));
fprintf('    Mk III PROBEs:          %.0f t total PGM\n', sum(mkiii_pgm));
fprintf('    Captured asteroids:     %.0f t total PGM\n', sum(captured_asteroid_pgm));
fprintf('REO extern (mining):        $%.2f T\n', sum(ext_reo)/1e6);
fprintf('H2 extern (Ir, 50%% attr):   $%.2f T\n', sum(ext_h2)/1e6);
fprintf('Geopolitical insurance:     $%.2f T\n', sum(ext_geo)/1e6);
fprintf('Rocket emissions:           $%.2f T\n', sum(ext_rockets)/1e6);
fprintf('Total rev + extern:         $%.2f T\n', cum_rev(end)/1e6);
fprintf('NPV (all extern):           $%.2f T\n', npv_total(end)/1e6);
fprintf('NPV (direct only):          $%.2f T\n', npv_direct(end)/1e6);
fprintf('Earth cargo (200 yr):       %.1f Mt\n', sum(earth_cargo)/1e6);
fprintf('Lifetime rocket CO2:        %.0f Mt\n', sum(co2_rockets)/1e6);
if ~isempty(be_total)
    fprintf('Breakeven (undiscounted):   Y%d\n', Y(be_total));
else
    fprintf('Breakeven (undiscounted):   NOT REACHED\n');
end

% Phase boundary reporting
fprintf('\n--- Infrastructure at Key Years ---\n');
check_y = [25 35 45 60 80 100 120 140 160 200];
fprintf('%-6s %10s %10s %10s %6s %8s %8s %10s\n', ...
    'Year','REO t/y','Circuits','Haulers','MSR','Conv km','MOLE-I','Cargo t/y');
for y = check_y
    i = y+1;
    fprintf('Y%-5d %10.0f %10d %10d %6d %8.0f %8d %10.0f\n', ...
        y, reo_target(i), circuits_needed(i), haulers_needed(i), ...
        msr_count(i), conv_km_needed(i), molei_needed(i), earth_cargo(i));
end

% Steady-state reporting (Y160 — well into maintenance)
i160 = 161; i200 = 201;
fprintf('\n--- Status at Y160 (2.5 Mt/yr build-out: 1.5 Mt/yr at this point) ---\n');
fprintf('  REO production:   %.0f t/yr (target: %.0f)\n', reo_target(i160), reo_final);
fprintf('  Annual cost:      $%.1fB/yr\n', cost_total(i160)/1e3);
fprintf('    of which launch:  $%.1fB\n', cost_launch(i160)/1e3);
fprintf('    of which in-situ: $%.1fB\n', cost_insitu(i160)/1e3);
fprintf('    of which Mk III:  $%.1fB\n', cost_mkiii(i160)/1e3);
fprintf('    of which tugs:    $%.1fB\n', cost_tugs(i160)/1e3);
fprintf('    of which DRO ops: $%.1fB\n', cost_dro_ops(i160)/1e3);
fprintf('    of which ast proc: $%.1fB (C-type $0.5B + S-type $0.8B)\n', cost_asteroid_processing(i160)/1e3);
fprintf('  Direct revenue:   $%.1fB/yr\n', rev_direct(i160)/1e3);
fprintf('    REO sales:      $%.1fB (%.0f t × $%.0f/t)\n', ...
    rev_reo(i160)/1e3, reo_target(i160), reo_price(i160));
fprintf('    PGM sales:      $%.1fB (%.1f t total)\n', rev_pgm(i160)/1e3, total_pgm(i160));
fprintf('      Mk I/II:     %.1f t/yr\n', pgm_production(i160));
fprintf('      Mk III:      %.1f t/yr (%d active)\n', mkiii_pgm(i160), round(mkiii_active(i160)));
fprintf('      Asteroids:   %.1f t/yr PGM (1 M-type, processing since Y85)\n', captured_asteroid_pgm(i160));
fprintf('    Asteroid captures: M-type Y75, C-type Y95, S-type Y115\n');
fprintf('    Circuit Earth frac: %.1f%% (reduced by C-type carbon + S-type Si)\n', ...
    max(0.008, 0.10 - 0.07*min(1,(Y(i160)-105)/10) - 0.022*min(1,(Y(i160)-125)/10)) * 100);
fprintf('  Externalities:    $%.1fB/yr (REO $%.1f + H2 $%.1f + Geo $%.1f + Rockets $%.1f)\n', ...
    ext_total(i160)/1e3, ext_reo(i160)/1e3, ext_h2(i160)/1e3, ext_geo(i160)/1e3, ext_rockets(i160)/1e3);
fprintf('  Total Ir:         %.1f t/yr (attributed: %.1f t at 50%%)\n', ...
    total_ir(i160), ir_attributed(i160));
fprintf('  PEM installed:    %.1f GW\n', pem_gw(i160));
fprintf('  Rev+Ext / Cost:   %.2f\n', rev_total(i160)/cost_total(i160));
fprintf('  Net annual:       $%.1fB/yr (%s)\n', (rev_total(i160)-cost_total(i160))/1e3, ...
    iff(rev_total(i160)>cost_total(i160), 'POSITIVE', 'negative'));

fprintf('\n--- Environmental Balance at Y160 ---\n');
fprintf('  CO2 avoided (REE): %.1f Mt/yr\n', co2_avoided_reo(i160)/1e6);
fprintf('  CO2 avoided (H2):  %.1f Mt/yr\n', co2_avoided_h2(i160)/1e6);
fprintf('  CO2 rockets:       %.1f Mt/yr\n', co2_rockets(i160)/1e6);
fprintf('  NET CO2:           %.1f Mt/yr\n', ...
    (co2_avoided_reo(i160)+co2_avoided_h2(i160)-co2_rockets(i160))/1e6);

fprintf('\n--- TRUE STEADY STATE at Y200 (2.5 Mt/yr, 20 years post build-out) ---\n');
i200 = 201;
fprintf('  REO production:   %.0f t/yr\n', reo_target(i200));
fprintf('  Annual cost:      $%.1fB/yr\n', cost_total(i200)/1e3);
fprintf('  Direct revenue:   $%.1fB/yr\n', rev_direct(i200)/1e3);
fprintf('  Externalities:    $%.1fB/yr\n', ext_total(i200)/1e3);
fprintf('  Rev+Ext / Cost:   %.2f\n', rev_total(i200)/cost_total(i200));
fprintf('  Net annual:       $%.1fB/yr (%s)\n', (rev_total(i200)-cost_total(i200))/1e3, ...
    iff(rev_total(i200)>cost_total(i200), 'POSITIVE', 'negative'));
fprintf('  CO2 avoided:      %.1f Mt/yr (REE %.1f + H2 %.1f - rockets %.1f)\n', ...
    (co2_avoided_reo(i200)+co2_avoided_h2(i200)-co2_rockets(i200))/1e6, ...
    co2_avoided_reo(i200)/1e6, co2_avoided_h2(i200)/1e6, co2_rockets(i200)/1e6);

%% ═══════════════════════════════════════════════════════════════
%  9. CIRCUIT THROUGHPUT SENSITIVITY
%  ═══════════════════════════════════════════════════════════════

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  CIRCUIT THROUGHPUT SENSITIVITY\n');
fprintf('═══════════════════════════════════════════════\n');

for d = 1:3
    cd = circuit_designs(d);
    circ_k = ceil(reo_target / cd.reo_yr);
    d_circ_k = max(0, diff([0; circ_k]));
    cargo_k = zeros(N,1);
    maint_k = zeros(N,1);
    insitu_k = zeros(N,1);
    for i=1:N
        ef = circuit.earth_frac(Y(i));
        cargo_k(i) = d_circ_k(i) * cd.mass_kg * ef / 1000;
        maint_k(i) = circ_k(i) * cd.mass_kg * 0.02 * ef / 1000;
        insitu_k(i) = d_circ_k(i) * cd.mass_kg * (1-ef) / 1000;
    end
    % Replace circuit cargo in total
    ec_k = earth_cargo - cargo_circuits - maint_circuits + cargo_k + maint_k;
    cl_k = ec_k*1000 .* launch_cost .* contingency / 1e6;
    is_k = (insitu_total - insitu_circuits + insitu_k)*1000 * insitu_cost_per_kg / 1e6;
    ct_k = cl_k + is_k + cost_rd;
    npv_k = sum((rev_total - ct_k) .* df);
    
    fprintf('\n  %s:\n', cd.name);
    fprintf('    Circuits for 1.25 Mt/yr: %s\n', num2str(ceil(reo_final/cd.reo_yr)));
    fprintf('    Mass per circuit: %d kg (Earth: %d kg at 10%%)\n', cd.mass_kg, round(cd.mass_kg*0.1));
    fprintf('    Total circuit mass: %.1f Mt (Earth: %.1f Mt)\n', ...
        ceil(reo_final/cd.reo_yr)*cd.mass_kg/1e9, ceil(reo_final/cd.reo_yr)*cd.mass_kg*0.1/1e9);
    fprintf('    200-yr cost: $%.2f T\n', sum(ct_k)/1e6);
    fprintf('    NPV (all extern): $%.2f T\n', npv_k/1e6);
    fprintf('    NPV delta from batch: $%.2f T\n', (npv_k - npv_total(end))/1e6);
end

%% ═══════════════════════════════════════════════════════════════
%  10. OTHER SENSITIVITIES
%  ═══════════════════════════════════════════════════════════════

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  OTHER SENSITIVITIES\n');
fprintf('═══════════════════════════════════════════════\n');

baseline_npv = npv_total(end)/1e6;

% Discount rate
dr_opts = [0.014 0.020 0.030 0.035];
dr_labs = {'Stern 1.4%','Flat 2.0%','Flat 3.0%','UK Green 3.5%'};
fprintf('\nDiscount rate:\n');
for k=1:4
    df_k = cumprod(1./(1+dr_opts(k)*ones(N,1)));
    fprintf('  %s: NPV $%.2fT\n', dr_labs{k}, sum(net_total.*df_k)/1e6);
end

% Launch cost
fprintf('\nLaunch cost:\n');
for mult = [1.5 1.0 0.5]
    cl_k = earth_cargo*1000.*(launch_cost*mult).*contingency/1e6;
    ct_k = cl_k + cost_insitu + cost_rd;
    fprintf('  %.0f%%: NPV $%.2fT\n', mult*100, sum((rev_total-ct_k).*df)/1e6);
end

% Geopolitical insurance sensitivity
fprintf('\nGeopolitical insurance:\n');
for gval = [0, 15000, 25000]
    ext_g_k = zeros(N,1);
    for i=1:N
        if supply_frac(i)>geo_threshold
            ext_g_k(i) = gval * min(1, supply_frac(i)/0.5);
        end
    end
    rev_k = rev_direct + ext_reo + ext_h2 + ext_rockets + ext_g_k;
    fprintf('  $%dB/yr: NPV $%.2fT\n', gval/1000, sum((rev_k-cost_total).*df)/1e6);
end

%% ═══════════════════════════════════════════════════════════════
%  11. FIGURES
%  ═══════════════════════════════════════════════════════════════

axc = [.05 .08 .12]; txc = [.7 .8 .9]; gc = [.15 .2 .3];

% Fig 1: Overview
fig1 = figure('Position',[50 50 1200 700],'Color',[.03 .06 .1]);
subplot(2,2,1);
semilogy(Y,max(cost_total,.1),'r-','LineWidth',2); hold on;
semilogy(Y,max(rev_total,.1),'g-','LineWidth',2);
semilogy(Y,max(rev_direct,.01),'g--','LineWidth',1.5);
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('Cost vs Revenue','Color',[.9 .95 1]);
legend('Cost','Rev+Ext','Direct','Location','se','FontSize',7);

subplot(2,2,2);
plot(Y,npv_total/1e6,'g-','LineWidth',2); hold on;
plot(Y,npv_direct/1e6,'g--','LineWidth',1.5); yline(0,'w--');
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('Cumulative NPV ($T)','Color',[.9 .95 1]);
legend('With Extern','Direct Only','Location','nw');

subplot(2,2,3);
bar(Y,earth_cargo/1000,1,'FaceColor',[.2 .5 .8],'EdgeColor','none');
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('Earth Cargo (kt/yr)','Color',[.9 .95 1]);

subplot(2,2,4);
semilogy(Y,max(reo_target,.01),'c-','LineWidth',2); hold on;
yline(reo_final,'c--','2.5 Mt/yr','LabelColor','c');
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); ylim([.01 2e6]);
title('REO Production','Color',[.9 .95 1]);

sgtitle(sprintf('SELENITE v1.3 — 200-Year Model (%s)', ...
    circuit_designs(CIRCUIT_DESIGN).name),'Color',[.9 .95 1],'FontSize',14);
saveas(fig1,'SELENITE_ECON_v1_3_overview.png');

% Fig 2: Environmental
fig2 = figure('Position',[100 100 1200 500],'Color',[.03 .06 .1]);
subplot(1,2,1);
plot(Y,ext_reo/1e3,'g-','LineWidth',2); hold on;
plot(Y,ext_h2/1e3,'b-','LineWidth',2);
plot(Y,ext_geo/1e3,'m-','LineWidth',2);
plot(Y,ext_rockets/1e3*100,'r-','LineWidth',2);  % ×100 for visibility
plot(Y,ext_total/1e3,'w-','LineWidth',2.5); yline(0,'w:');
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('Externalities ($B/yr)','Color',[.9 .95 1]);
legend('REO Mining','H2 (Ir)','Geopolitical','Rockets (x100)','NET','Location','nw','FontSize',7);
text(150, -5, sprintf('Peak rocket cost: $%.0fM/yr', min(ext_rockets)*1e3), ...
    'Color',[.8 .3 .3],'FontSize',8);

subplot(1,2,2);
plot(Y,co2_avoided_reo/1e6,'g-','LineWidth',2); hold on;
plot(Y,co2_avoided_h2/1e6,'b-','LineWidth',2);
plot(Y,-co2_rockets/1e6*100,'r-','LineWidth',2);  % ×100 for visibility
plot(Y,(co2_avoided_reo+co2_avoided_h2-co2_rockets)/1e6,'w-','LineWidth',2.5); yline(0,'w:');
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('CO2 Balance (Mt/yr)','Color',[.9 .95 1]);
legend('Avoided: REE','Avoided: H2','Rockets x100 (neg)','NET','Location','nw','FontSize',7);
text(150, -10, sprintf('Peak rocket CO2: %.1f Mt/yr', max(co2_rockets)/1e6), ...
    'Color',[.8 .3 .3],'FontSize',8);

sgtitle('SELENITE — Environmental Accounting (200 yr)','Color',[.9 .95 1],'FontSize',14);
saveas(fig2,'SELENITE_ECON_v1_3_environmental.png');

% Fig 3: Cargo breakdown
fig3 = figure('Position',[150 150 1200 500],'Color',[.03 .06 .1]);
cargo_stack = [cargo_circuits, cargo_haulers, cargo_conveyors, cargo_canisters, ...
    cargo_msr+cargo_fsp, cargo_reagent, cargo_molei+cargo_probes, ...
    maint_circuits+maint_haulers+maint_conv+maint_msr, ...
    cargo_spa_ops+cargo_construction+cargo_ybco];
h = area(Y, cargo_stack/1000);
colors = {[.8 .2 .2],[.2 .7 .3],[.4 .6 .2],[.8 .6 .2],[.6 .3 .7],[.2 .5 .8],[.7 .4 .2],[.5 .5 .5],[.3 .3 .6]};
labels = {'Circuits','Haulers','Conveyors','Canisters','Power','Reagent','MOLE-I+PROBE','Maintenance','SPA+Constr'};
for j=1:9, h(j).FaceColor=colors{j}; h(j).EdgeColor='none'; h(j).FaceAlpha=.85; end
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('Earth Cargo by Category (kt/yr)','Color',[.9 .95 1]);
legend(labels,'Location','nw','FontSize',7,'TextColor',txc,'Color',[.08 .12 .18]);
saveas(fig3,'SELENITE_ECON_v1_3_cargo.png');

% Fig 4 moved after comparison section (needs rv_25)

%% ═══════════════════════════════════════════════════════════════
%  12. COMPARISON: 2.5 Mt/yr (committed) vs 1.25 Mt/yr (stop-early)
%  ═══════════════════════════════════════════════════════════════

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  COMMITTED TARGET vs STOP-EARLY ALTERNATIVE\n');
fprintf('═══════════════════════════════════════════════\n');

% 1.25 Mt/yr alternative: same ramp but caps at 1.25 Mt/yr at Y140
reo_alt_y = [0  15  18   25    28    35    45     60      80     100    120    140    200];
reo_alt_v = [0   0   0   0.4   125   125   1000   10000   100000 250000 500000 1250000 1250000];
reo_final_alt = 1250000;

reo_25 = zeros(N,1);
for i = 1:N
    y = Y(i);
    if y <= 18, reo_25(i) = 0; continue; end
    idx = find(reo_alt_y <= y, 1, 'last');
    if idx >= length(reo_alt_y)
        reo_25(i) = reo_alt_v(end);
    else
        y0 = reo_alt_y(idx); y1 = reo_alt_y(idx+1);
        r0 = max(reo_alt_v(idx), 0.01); r1 = reo_alt_v(idx+1);
        if r1 <= 0, reo_25(i) = 0;
        else
            frac = (y - y0) / (y1 - y0);
            reo_25(i) = exp(log(r0) + frac*(log(r1) - log(r0)));
        end
    end
end
reo_25 = min(reo_25, reo_final_alt);

% Infrastructure for 2.5 Mt/yr
circ_25 = ceil(reo_25 / circuit.reo_yr);
d_circ_25 = max(0, diff([0; circ_25]));
reg_25 = reo_25 / 0.0005;
haul_25 = ceil(reg_25 .* hauler_ore_frac / hauler.throughput_yr);
conv_25 = reg_25 .* tier3_frac / 20000;
d_haul_25 = max(0, diff([0; haul_25]));
d_conv_25 = max(0, diff([0; conv_25]));
pwr_25 = circ_25 * circuit.power_kw;
msr_25 = zeros(N,1);
for i = 1:N
    if Y(i) >= 45, msr_25(i) = ceil(pwr_25(i)/(msr.power_mw*1000)); end
end
d_msr_25 = max(0, diff([0; msr_25]));
can_25 = zeros(N,1);
for i=1:N, if Y(i)>=35, can_25(i) = ceil(reo_25(i)/can.reo_payload_t); end; end

% Earth cargo for 2.5 Mt/yr
cargo_circ_25 = zeros(N,1);
cargo_haul_25 = zeros(N,1);
maint_circ_25 = zeros(N,1);
maint_haul_25 = haul_25 * hauler.maint_kg_yr / 1000;
insitu_circ_25 = zeros(N,1);
for i = 1:N
    y = Y(i);
    ef = min(1.0, max(0.10, 1.0 - (y-25)*0.03));
    if y >= 105, ef = max(0.03, ef - 0.07*min(1,(y-105)/10)); end
    if y >= 125, ef = max(0.008, ef - 0.022*min(1,(y-125)/10)); end
    cargo_circ_25(i) = d_circ_25(i) * circuit.mass_kg * ef / 1000;
    maint_circ_25(i) = circ_25(i) * circuit.mass_kg * circuit.maint_frac * ef / 1000;
    cargo_haul_25(i) = d_haul_25(i) * hauler.mass_kg * hauler.earth_frac(y) / 1000;
    insitu_circ_25(i) = d_circ_25(i) * circuit.mass_kg * (1-ef) / 1000;
end
cargo_conv_25 = d_conv_25 * conv.mass_per_km * conv.earth_frac / 1000;
maint_conv_25 = conv_25 * conv.mass_per_km * conv.maint_frac_yr * conv.earth_frac / 1000;
cargo_msr_25 = zeros(N,1);
maint_msr_25 = zeros(N,1);
for i=1:N
    ef = msr.earth_frac(Y(i));
    cargo_msr_25(i) = d_msr_25(i) * msr.mass_kg * ef / 1000;
    maint_msr_25(i) = msr_25(i)/msr.life_yr * msr.mass_kg * ef / 1000;
end
cargo_can_25 = can_25 * can.earth_kg / 1000;

ec_25 = cargo_circ_25 + cargo_haul_25 + cargo_conv_25 + cargo_msr_25 + ...
    cargo_can_25 + maint_circ_25 + maint_haul_25 + maint_conv_25 + maint_msr_25 + ...
    cargo_fsp + cargo_molei + cargo_probes + cargo_reagent + ...
    cargo_construction + cargo_ybco + cargo_spa_ops + ...
    cargo_construction_fleet + cargo_dro_infra + ...
    cargo_spa_msr + maint_spa_msr - maint_molei_saving;
ec_25 = max(0, ec_25);
insitu_25 = insitu_circ_25 + insitu_haulers + insitu_conveyors;

% Costs for 2.5 Mt/yr
cl_25 = ec_25*1000 .* launch_cost .* contingency / 1e6;
ci_25 = insitu_25*1000 * insitu_cost_per_kg / 1e6;
ct_25 = cl_25 + ci_25 + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing;

% Revenue for 2.5 Mt/yr
sf_25 = reo_25 ./ reo_demand;
rp_25 = max(5000, 15000*(1-0.6*sf_25));
rr_25 = reo_25 .* rp_25 / 1e6;
er_25 = reo_25 * 73700 / 1e6;  % REO extern
co2_reo_25 = reo_25 * 30;
% H2 extern same (same Ir production from PROBEs + asteroids)
% Geopolitical scales with supply fraction
eg_25 = zeros(N,1);
for i=1:N
    if sf_25(i)>geo_threshold
        eg_25(i) = geo_insurance_per_yr * min(1, sf_25(i)/0.5);
    end
end
% Rocket emissions for 2.5 case
tl_25 = (ec_25/100) .* tanker_ratio;
cr_25 = tl_25 * 2750 .* fossil_frac;
exr_25 = -cr_25 * scc / 1e6;

rv_25 = rr_25 + rev_pgm + er_25 + ext_h2 + eg_25 + exr_25;
npv_25 = sum((rv_25 - ct_25) .* df);

% Steady state for 2.5 (Y200)
i200 = 201;

fprintf('\n%-30s %15s %15s\n', '', '2.5 Mt/yr', '1.25 Mt/yr');
fprintf('%-30s %15s %15s\n', '', '(committed)', '(stop-early)');
fprintf('%-30s %15.0f %15.0f\n', 'Circuits needed', ceil(reo_final/circuit.reo_yr), ceil(reo_final_alt/circuit.reo_yr));
fprintf('%-30s %15.0f %15.0f\n', 'Haulers needed', haulers_needed(i200), haul_25(i200));
fprintf('%-30s %15.0f %15.0f\n', 'MSR count', msr_count(i200), msr_25(i200));
fprintf('%-30s %15.0f %15.0f\n', 'Conveyor km', conv_km_needed(i200), conv_25(i200));
fprintf('%-30s %12.1f Mt %12.1f Mt\n', 'Earth cargo (200 yr)', sum(earth_cargo)/1e6, sum(ec_25)/1e6);
fprintf('%-30s %12.2f $T %12.2f $T\n', 'Total cost (200 yr)', cum_cost(end)/1e6, sum(ct_25)/1e6);
fprintf('%-30s %12.2f $T %12.2f $T\n', 'REO extern (200 yr)', sum(ext_reo)/1e6, sum(er_25)/1e6);
fprintf('%-30s %12.2f $T %12.2f $T\n', 'Geo insurance (200 yr)', sum(ext_geo)/1e6, sum(eg_25)/1e6);
fprintf('%-30s %12.2f $T %12.2f $T\n', 'Total rev+extern', cum_rev(end)/1e6, sum(rv_25)/1e6);
fprintf('%-30s %12.2f $T %12.2f $T\n', 'NPV (all extern)', npv_total(end)/1e6, npv_25/1e6);
fprintf('%-30s %12.1f $B %12.1f $B\n', 'SS cost/yr', cost_total(i200)/1e3, ct_25(i200)/1e3);
fprintf('%-30s %12.1f $B %12.1f $B\n', 'SS rev+ext/yr', rev_total(i200)/1e3, rv_25(i200)/1e3);
fprintf('%-30s %12.1f $B %12.1f $B\n', 'SS net/yr', ...
    (rev_total(i200)-cost_total(i200))/1e3, (rv_25(i200)-ct_25(i200))/1e3);
fprintf('%-30s %12s %12s\n', 'Steady-state reached', 'Y180', 'Y140');
fprintf('%-30s %12.0f Mt %12.0f Mt\n', 'CO2 avoided at SS/yr', ...
    (co2_avoided_reo(i200)+co2_avoided_h2(i200))/1e6, ...
    (reo_25(i200)*30+co2_avoided_h2(i200))/1e6);

fprintf('\n2.5 Mt/yr costs $%.1fT more over 200 yr but generates $%.1fT more benefit.\n', ...
    (cum_cost(end) - sum(ct_25))/1e6, (cum_rev(end) - sum(rv_25))/1e6);
fprintf('SS net surplus: $%.1fB/yr (2.5) vs $%.1fB/yr (1.25)\n', ...
    (rev_total(i200)-cost_total(i200))/1e3, (rv_25(i200)-ct_25(i200))/1e3);
fprintf('COMMITTED TARGET: 2.5 Mt/yr — full replacement of terrestrial REE mining.\n');

% Fig 4: Annual net benefit + 2.5 Mt/yr comparison (needs rv_25 from above)
fig4 = figure('Position',[200 200 1200 500],'Color',[.03 .06 .1]);
subplot(1,2,1);
plot(Y, net_total/1e3, 'g-', 'LineWidth', 2); hold on;
plot(Y, net_direct/1e3, 'g--', 'LineWidth', 1.5);
yline(0, 'w--'); 
xline(140, 'c:', '1.25Mt milestone', 'LabelColor', 'c', 'FontSize', 8);
xline(180, 'c--', 'SS 2.5Mt', 'LabelColor', 'c', 'FontSize', 9);
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('2.5 Mt/yr Target (committed)','Color',[.9 .95 1]);
ylabel('$B/yr'); xlabel('Year');
legend('With Extern','Direct Only','Location','se','FontSize',8);

subplot(1,2,2);
net_25 = rv_25 - ct_25;
plot(Y, net_total/1e3, 'g-', 'LineWidth', 2); hold on;
plot(Y, net_25/1e3, 'c--', 'LineWidth', 1.5);
yline(0, 'w--');
xline(140, 'c:', '1.25Mt SS', 'LabelColor', 'c', 'FontSize', 8);
xline(180, 'm--', '2.5Mt SS', 'LabelColor', 'm', 'FontSize', 9);
set(gca,'Color',axc,'XColor',txc,'YColor',txc,'GridColor',gc);
grid on; xlim([0 200]); title('Committed 2.5 vs Stop-Early 1.25','Color',[.9 .95 1]);
ylabel('$B/yr'); xlabel('Year');
legend('2.5 Mt/yr (committed)','1.25 Mt/yr (stop-early)','Location','se','FontSize',8);

sgtitle('SELENITE — Annual Net Benefit Comparison','Color',[.9 .95 1],'FontSize',14);
saveas(fig4,'SELENITE_ECON_v1_3_net_benefit.png');

fprintf('\n═══════════════════════════════════════════════\n');
fprintf('  SELENITE_ECON v1.3 COMPLETE — 4 figures saved\n');
fprintf('  200-year model, cadence-constrained, %s circuits\n', ...
    circuit_designs(CIRCUIT_DESIGN).name);
fprintf('  Diversified asteroid strategy: M-type + C-type + S-type\n');
fprintf('═══════════════════════════════════════════════\n');

% Helper function
function result = iff(condition, trueVal, falseVal)
    if condition, result = trueVal; else, result = falseVal; end
end