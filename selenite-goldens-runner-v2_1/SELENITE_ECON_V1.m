%========================================================================
%  SELENITE_ECON v1.0 — Century-Scale Economic Evaluation
%  Selenite Programme: Lunar REE Extraction & Asteroid PGM Mining
%  Currency: USD (2026 constant dollars)
%  Discount: Declining schedule per Arrow et al. (2014)
%  Ref: SELENITE_SCALE v1.3, VERIFY v5.0, all design specs (March 2026)
%========================================================================
clear; clc;
fprintf('================================================================\n');
fprintf('  SELENITE PROGRAMME — Economic Evaluation v1.0\n');
fprintf('  100-Year Dual-Base Lunar REE + Asteroid PGM\n');
fprintf('  All figures in USD (2026 constant)\n');
fprintf('================================================================\n\n');

%% ====================================================================
%  SECTION 1: GLOBAL ASSUMPTIONS
%  All monetary values in USD. Mass in kg or tonnes as labelled.
% =====================================================================

% --- Discount Rate Schedule (Arrow et al. 2014, UK Green Book) ---
% Declining: 3.0% Y0-30, 2.5% Y31-75, 2.0% Y76-100
disc.r1 = 0.030;  disc.y1 = 30;   % Years 0-30
disc.r2 = 0.025;  disc.y2 = 75;   % Years 31-75
disc.r3 = 0.020;  disc.y3 = 100;  % Years 76-100

% --- Launch Economics ---
% Starship to lunar surface, mature operations
% Conservative: $6,000/kg (2030s), declining to $3,000/kg (2050s+)
launch.cost_kg_early  = 6000;   % $/kg to lunar surface, P0-P7 (Y0-Y25)
launch.cost_kg_mid    = 4000;   % $/kg, P8-P9 (Y25-Y45)
launch.cost_kg_late   = 2000;   % $/kg, P10+ (Y45+) — mass driver era
launch.starship_cargo = 100000; % kg useful cargo per Starship to Moon
launch.cost_per_flight_early = launch.cost_kg_early * launch.starship_cargo;
launch.cost_per_flight_mid   = launch.cost_kg_mid   * launch.starship_cargo;
launch.co2_per_launch = 2200;   % tonnes CO2-eq per Starship launch
launch.scc = 190;               % $/tonne CO2 (EPA 2023, 2% discount)

% --- REE Market ---
ree.basket_price_2026  = 15000;  % $/tonne mixed REO basket (2026)
ree.price_floor        = 5000;   % $/tonne at market saturation
ree.global_demand_2026 = 390000; % tonnes/yr (USGS MCS 2025)
ree.demand_cagr        = 0.03;   % 3% annual demand growth to 2100
ree.price_elasticity   = -0.5;   % Price drops 0.5% per 1% supply increase

% --- PGM Market ---
pgm.pt_price    = 61570;  % $/kg platinum (Apr 2026)
pgm.pd_price    = 47450;  % $/kg palladium
pgm.ir_price    = 281650; % $/kg iridium
pgm.basket_price = 80000; % $/kg blended PGM basket (Pt-dominant)
pgm.global_prod  = 450;   % tonnes/yr total PGM mine production

% --- Environmental Externalities ---
ext.avoided_damage_per_tREO = 73000;  % $/tonne REO (Lee & Wen 2018 mid)
ext.carbon_per_tREO = 5700;           % $/tonne REO (SCC × lifecycle CO2)
ext.strategic_premium = 5000;         % $/tonne REO (supply security)
ext.total_per_tREO = ext.avoided_damage_per_tREO + ...
                     ext.carbon_per_tREO + ext.strategic_premium;

% --- Contingency ---
contingency.early = 0.50;  % 50% on P0-P4 (pre-Phase A concept)
contingency.mid   = 0.35;  % 35% on P5-P7 (maturing design)
contingency.late  = 0.25;  % 25% on P8+ (operational scaling)

% --- Vehicle Mass (kg, dry, Earth-manufactured) ---
mass.probe_mk1   = 12000;   % PROBE Mk I
mass.probe_mk2   = 25000;   % PROBE Mk II (P9+)
mass.skip         = 4500;    % Chemical SKIP
mass.dart         = 2000;    % DART pathfinder
mass.survey       = 1500;    % SURVEY orbital
mass.mole_i       = 360;     % MOLE-I rover
mass.mole_s       = 8000;    % MOLE-S excavator
mass.sinter       = 5000;    % SINTER printer
mass.arm_c        = 15000;   % ARM-C crane
mass.arm_d        = 8000;    % ARM-D docking gantry
mass.sentinel     = 200;     % SENTINEL rover
mass.harvest      = 500;     % HARVEST hydroponic
mass.fsp          = 6600;    % Fission Surface Power unit (40 kWe)
mass.hab_module   = 20000;   % Pressurised hab module
mass.isru_pem     = 1500;    % PEM electrolyser stack
mass.proc_circuit = 15000;   % Processing circuit (SPA, pressurised)
mass.elz_pad_mat  = 5000;    % ELZ pad construction materials

% --- Reagent Mass (kg/yr per processing circuit) ---
reagent.h2so4    = 35000;  % kg/yr H2SO4 per circuit
reagent.naoh     = 9000;   % kg/yr NaOH per circuit
reagent.oxalic   = 2000;   % kg/yr oxalic acid per circuit
reagent.d2ehpa   = 1000;   % kg/yr D2EHPA makeup (5% of charge)
reagent.total    = 47000;  % kg/yr total per circuit (≈1 Starship)
% In-situ reagent transition: P10+ PKT produces H2SO4 from troilite
% Ca(OH)2 from anorthite substitutes NaOH. Oxalic from CO2 electro.
% Only D2EHPA remains Earth-imported at P10+.
reagent.insitu_fraction_P10 = 0.85; % 85% of reagent mass produced in-situ

% --- Crew Costs ---
crew.cost_per_person_yr = 5e6;  % $/person/yr (ops, training, salary)
crew.rotation_flights   = 2;    % Starship crew flights per year (P4+)

% --- Ground Operations ---
ground.ops_annual_early = 200e6;  % $200M/yr mission control (P0-P7)
ground.ops_annual_mid   = 500e6;  % $500M/yr (P8-P9, dual-site)
ground.ops_annual_late  = 300e6;  % $300M/yr (P10+, highly automated)

% --- R&D / Development ---
rd.total_p0_p3 = 15e9;  % $15B total R&D (P0-P3), spread over ~7 yr

%% ====================================================================
%  SECTION 2: PHASE-BY-PHASE PHYSICAL QUANTITIES
%  From SELENITE_SCALE v1.3 and VERIFY v5.0
% =====================================================================

% Phase structure: [phase, start_year, end_year, ...]
% Using programme years (Y0 = programme start ≈ 2025)

phases = struct();

% --- P0: Pre-Deployment (Y0-Y3) ---
phases(1).name = 'P0'; phases(1).y_start = 0; phases(1).y_end = 3;
phases(1).crew = 0;
phases(1).new_hardware_kg = 3*1500 + 0; % 3 relay sats only
phases(1).cargo_flights = 0;
phases(1).crew_flights = 0;
phases(1).reo_tyr = 0; phases(1).pgm_tyr = 0;
phases(1).proc_circuits_spa = 0; phases(1).proc_circuits_pkt = 0;
phases(1).reagent_earth_tyr = 0;
phases(1).description = 'Relay satellites, R&D, mission planning';

% --- P1: Launch & Transit (Y2-Y4) ---
phases(2).name = 'P1'; phases(2).y_start = 2; phases(2).y_end = 4;
phases(2).crew = 0;
% Initial robot fleet: 3 PROBE, 1 SKIP, 1 SURVEY, 5 MOLE-I,
% 4 MOLE-S, 3 SINTER, 1 ARM-C, 1 ARM-D, 2 SENTINEL
phases(2).new_hardware_kg = 3*mass.probe_mk1 + 1*mass.skip + ...
    1*mass.survey + 5*mass.mole_i + 4*mass.mole_s + 3*mass.sinter + ...
    1*mass.arm_c + 1*mass.arm_d + 2*mass.sentinel + ...
    1*mass.fsp + 2*mass.hab_module + 3*mass.isru_pem + ...
    2*mass.elz_pad_mat;  % + hab, ISRU, ELZ materials
phases(2).cargo_flights = ceil(phases(2).new_hardware_kg / launch.starship_cargo) + 2;
phases(2).crew_flights = 0;
phases(2).reo_tyr = 0; phases(2).pgm_tyr = 0;
phases(2).proc_circuits_spa = 0; phases(2).proc_circuits_pkt = 0;
phases(2).reagent_earth_tyr = 0;
phases(2).description = 'Robot fleet delivery, relay validation';

% --- P2-P3: Robotic Construction & Early ISRU (Y4-Y7) ---
phases(3).name = 'P2-P3'; phases(3).y_start = 4; phases(3).y_end = 7;
phases(3).crew = 0;
% Additional: +5 MOLE-I, spares, ISRU expansion, solar arrays
phases(3).new_hardware_kg = 5*mass.mole_i + 2*mass.fsp + ...
    50000 + 30000;  % solar arrays, spares, construction materials
phases(3).cargo_flights = 4;  % ~4 cargo flights over 3 years
phases(3).crew_flights = 0;
phases(3).reo_tyr = 0; phases(3).pgm_tyr = 0;
phases(3).proc_circuits_spa = 0; phases(3).proc_circuits_pkt = 0;
phases(3).reagent_earth_tyr = 0;
phases(3).description = 'Autonomous base construction, early ISRU';

% --- P4: Crew Arrival (Y7-Y9) ---
phases(4).name = 'P4'; phases(4).y_start = 7; phases(4).y_end = 9;
phases(4).crew = 6; % average 4→8
% +3 PROBE, +20 MOLE-I, +1 ARM-C, +1 ARM-D, +1 FSP, ISRU expansion
phases(4).new_hardware_kg = 3*mass.probe_mk1 + 20*mass.mole_i + ...
    1*mass.arm_c + 1*mass.arm_d + 1*mass.fsp + 2*mass.isru_pem + ...
    40000;  % solar expansion, spares
phases(4).cargo_flights = 4;
phases(4).crew_flights = 2; % crew arrival + resupply
phases(4).reo_tyr = 0; phases(4).pgm_tyr = 0;
phases(4).proc_circuits_spa = 0; phases(4).proc_circuits_pkt = 0;
phases(4).reagent_earth_tyr = 0;
phases(4).description = 'Crew-1 arrival, ECLSS commissioning';

% --- P5: Fleet Expansion (Y9-Y12) ---
phases(5).name = 'P5'; phases(5).y_start = 9; phases(5).y_end = 12;
phases(5).crew = 10; % 8→12
% +4 PROBE, +1 SKIP, +1 DART, +1 SURVEY, +25 MOLE-I, +2 ARM-D
phases(5).new_hardware_kg = 4*mass.probe_mk1 + 1*mass.skip + ...
    1*mass.dart + 1*mass.survey + 25*mass.mole_i + 2*mass.arm_d + ...
    1*mass.sentinel + 1*mass.fsp + 3*mass.isru_pem + ...
    1*mass.hab_module + 60000;  % beneficiation module, solar, spares
phases(5).cargo_flights = 6;
phases(5).crew_flights = 2;
phases(5).reo_tyr = 0; phases(5).pgm_tyr = 0;  % concentrate only, no REO
phases(5).proc_circuits_spa = 0; phases(5).proc_circuits_pkt = 0;
phases(5).reagent_earth_tyr = 0;
phases(5).description = 'First export batch, beneficiation online';

% --- P6: Pre-PKT Expansion (Y12-Y15) ---
phases(6).name = 'P6'; phases(6).y_start = 12; phases(6).y_end = 15;
phases(6).crew = 12;
% +5 PROBE, +2 SKIP, +35 MOLE-I, +2 ARM-D, +1 HARVEST
phases(6).new_hardware_kg = 5*mass.probe_mk1 + 2*mass.skip + ...
    35*mass.mole_i + 2*mass.arm_d + 1*mass.sentinel + 1*mass.harvest + ...
    1*mass.fsp + 3*mass.isru_pem + 1*mass.hab_module + 50000;
phases(6).cargo_flights = 6;
phases(6).crew_flights = 2;
phases(6).reo_tyr = 0; phases(6).pgm_tyr = 0;
phases(6).proc_circuits_spa = 0; phases(6).proc_circuits_pkt = 0;
phases(6).reagent_earth_tyr = 0;  % processing facility decision at Y12
phases(6).description = 'Processing decision gate, crew rotation';

% --- P7: Proof of Concept (Y18-Y25) ---
% Note: gap Y15-Y18 modelled as steady-state P6 costs
phases(7).name = 'P7'; phases(7).y_start = 15; phases(7).y_end = 25;
phases(7).crew = 18; % 12→20 average
% +15 PROBE, +4 SKIP, +85 MOLE-I, +2 ARM-D, 5 proc circuits
phases(7).new_hardware_kg = 15*mass.probe_mk1 + 4*mass.skip + ...
    85*mass.mole_i + 2*mass.arm_d + 1*mass.fsp + 9*mass.isru_pem + ...
    5*mass.proc_circuit + 1*mass.hab_module + ...
    100000;  % processing facility, solar expansion, spares
phases(7).cargo_flights = 12;
phases(7).crew_flights = 2;
phases(7).reo_tyr = 0.4;    % 0.4 t/yr REO from 5 circuits
phases(7).pgm_tyr = 0.05;   % ~50 kg/yr PGM from PROBE
phases(7).proc_circuits_spa = 5; phases(7).proc_circuits_pkt = 0;
phases(7).reagent_earth_tyr = 5 * reagent.total / 1000; % ~235 t/yr
phases(7).description = 'Processing PoC, DART confirms PKT, MOLE Mk II';

% --- P8: PKT Online (Y25-Y35) ---
phases(8).name = 'P8'; phases(8).y_start = 25; phases(8).y_end = 35;
phases(8).crew = 20;
% PKT construction fleet + 308 circuits + infrastructure
% Most mass is PKT processing circuits + construction robots
pkt_construct_mass = 50*mass.sinter + 20*mass.mole_s + 10*mass.arm_c + ...
    308*mass.proc_circuit;  % ~5.3M kg
spa_additions = 66*mass.probe_mk1 + 48000*mass.mole_i; % huge MOLE-I scale
% Note: at P8, MOLE-I count jumps to ~49,000 (SCALE v1.3)
% This is driven by propellant for PKT tanker fleet
% Mass of 49,000 MOLE-I @ 360 kg each = 17,640 t — enormous
% Delivered over 10 years = ~1,764 t/yr = ~18 flights/yr just for MOLE-I
phases(8).new_hardware_kg = pkt_construct_mass + ...
    66*mass.probe_mk1 + 48800*mass.mole_i + ...  % SPA fleet expansion
    1386*mass.fsp + ...  % FSP for PKT (1,386 units!)
    500000;  % infrastructure, spares, miscellaneous
phases(8).cargo_flights = ceil(phases(8).new_hardware_kg / launch.starship_cargo) + 20;
phases(8).crew_flights = 2;
phases(8).reo_tyr = 125;   % 125 t/yr REO
phases(8).pgm_tyr = 0.05;
phases(8).proc_circuits_spa = 5; phases(8).proc_circuits_pkt = 308;
phases(8).reagent_earth_tyr = 313 * reagent.total / 1000; % ~14,711 t/yr
phases(8).description = 'PKT autonomous base online, tanker era';

% --- P9: Last Chemical Phase (Y35-Y45) ---
phases(9).name = 'P9'; phases(9).y_start = 35; phases(9).y_end = 45;
phases(9).crew = 20;
% PKT scales to 2,500 circuits; MOLE-I to ~390,000
phases(9).new_hardware_kg = (2500-308)*mass.proc_circuit + ...
    (390790-48990)*mass.mole_i + ...
    (11237-1386)*mass.fsp + ...
    1000000;  % mass driver prototype, infrastructure
phases(9).cargo_flights = ceil(phases(9).new_hardware_kg / launch.starship_cargo) + 30;
phases(9).crew_flights = 2;
phases(9).reo_tyr = 1000;   % 1,000 t/yr REO
phases(9).pgm_tyr = 0.5;
phases(9).proc_circuits_spa = 5; phases(9).proc_circuits_pkt = 2495;
phases(9).reagent_earth_tyr = 2500 * reagent.total / 1000; % ~117,500 t/yr!
phases(9).description = 'Peak chemical stress, mass driver prototype';

% --- P10: Paradigm Shift (Y45-Y60) ---
phases(10).name = 'P10'; phases(10).y_start = 45; phases(10).y_end = 60;
phases(10).crew = 20;
% Chemical→Electric transition. SKIPs retired. Haulers replace.
% In-situ fabrication begins. MOLE-I drops back to ~270.
% In-situ reagent production at PKT (85% of reagent mass)
phases(10).new_hardware_kg = (25000-2500)*mass.proc_circuit + ...
    (128918-11237)*mass.fsp + ...
    5000000;  % mass driver infrastructure, foundry equipment
% Note: haulers (14,881) are mostly in-situ manufactured at P10
% Earth-supplied: electronics, batteries = ~1,429 t/yr (from SCALE v1.3)
phases(10).cargo_flights = ceil(phases(10).new_hardware_kg / launch.starship_cargo) + 50;
phases(10).crew_flights = 2;
phases(10).reo_tyr = 10000;
phases(10).pgm_tyr = 0.5;
phases(10).proc_circuits_spa = 5; phases(10).proc_circuits_pkt = 24995;
% In-situ reagent: 85% produced locally, 15% still from Earth
phases(10).reagent_earth_tyr = 25000 * reagent.total / 1000 * ...
    (1 - reagent.insitu_fraction_P10);  % ~176,250 t/yr
phases(10).description = 'Electric haulers, mass drivers, in-situ reagent';

% --- P11: 10% Global Displacement (Y60-Y80) ---
phases(11).name = 'P11'; phases(11).y_start = 60; phases(11).y_end = 80;
phases(11).crew = 20;
phases(11).new_hardware_kg = (1188042-128918)*mass.fsp + ...
    10000000;  % EM catapults, infrastructure
% Most fleet in-situ manufactured
phases(11).cargo_flights = ceil(phases(11).new_hardware_kg / launch.starship_cargo) + 100;
phases(11).crew_flights = 2;
phases(11).reo_tyr = 100000;
phases(11).pgm_tyr = 1.0;
phases(11).proc_circuits_spa = 5; phases(11).proc_circuits_pkt = 249995;
phases(11).reagent_earth_tyr = 250000 * reagent.total / 1000 * ...
    (1 - 0.95);  % 95% in-situ by P11 → 587,500 t/yr Earth
phases(11).description = '10% global REO, in-situ fabrication at scale';

% --- P12: Mission Accomplished (Y80-Y100) ---
phases(12).name = 'P12'; phases(12).y_start = 80; phases(12).y_end = 100;
phases(12).crew = 20;
phases(12).new_hardware_kg = (12052243-1188042)*mass.fsp + ...
    50000000;  % massive infrastructure
phases(12).cargo_flights = ceil(phases(12).new_hardware_kg / launch.starship_cargo) + 200;
phases(12).crew_flights = 2;
phases(12).reo_tyr = 1000000;
phases(12).pgm_tyr = 5.0;
phases(12).proc_circuits_spa = 5; phases(12).proc_circuits_pkt = 2499995;
phases(12).reagent_earth_tyr = 2500000 * reagent.total / 1000 * ...
    (1 - 0.98);  % 98% in-situ by P12 → 2,350,000 t/yr Earth
phases(12).description = '83% global REO displacement, mission complete';

%% ====================================================================
%  SECTION 3: ANNUALISE & COMPUTE CASH FLOWS
% =====================================================================
fprintf('== PHASE-BY-PHASE COST BREAKDOWN ==\n\n');

T = 100;  % Total project life (years)
cashflow = zeros(T+1, 1);        % Net cash flow by year
capex_annual = zeros(T+1, 1);    % Capital expenditure
opex_annual = zeros(T+1, 1);     % Operating expenditure
revenue_annual = zeros(T+1, 1);  % Direct revenue (REO + PGM sales)
extern_annual = zeros(T+1, 1);   % Environmental externality benefit
launch_carbon = zeros(T+1, 1);   % Launch emission costs (negative)
total_capex = 0;
total_opex = 0;
total_revenue = 0;
total_extern = 0;

for p = 1:length(phases)
    ph = phases(p);
    dur = ph.y_end - ph.y_start;
    if dur < 1, dur = 1; end
    
    % Determine launch cost regime
    if ph.y_end <= 25
        lcost = launch.cost_kg_early;
        cont = contingency.early;
        if ph.y_start >= 9, cont = contingency.mid; end
        gops = ground.ops_annual_early;
    elseif ph.y_end <= 45
        lcost = launch.cost_kg_mid;
        cont = contingency.late;
        gops = ground.ops_annual_mid;
    else
        lcost = launch.cost_kg_late;
        cont = contingency.late;
        gops = ground.ops_annual_late;
    end
    
    % --- CAPEX: Hardware delivery ---
    hardware_cost = ph.new_hardware_kg * lcost;
    
    % --- CAPEX: R&D (P0-P3 only) ---
    rd_cost = 0;
    if p <= 3
        rd_cost = rd.total_p0_p3 / 3;  % spread over 3 phases
    end
    
    % --- Apply contingency ---
    capex_phase = (hardware_cost + rd_cost) * (1 + cont);
    capex_per_yr = capex_phase / dur;
    
    % --- OPEX: Reagent supply ---
    reagent_flights = ceil(ph.reagent_earth_tyr * 1000 / launch.starship_cargo);
    reagent_cost = reagent_flights * lcost * launch.starship_cargo;
    
    % --- OPEX: Crew ---
    crew_cost = ph.crew * crew.cost_per_person_yr;
    crew_flight_cost = ph.crew_flights * lcost * launch.starship_cargo;
    
    % --- OPEX: Ground ops ---
    ground_cost = gops;
    
    % --- OPEX: Cargo flights (ongoing spares, ~2 flights/yr) ---
    spares_cost = 2 * lcost * launch.starship_cargo;
    
    opex_per_yr = reagent_cost + crew_cost + crew_flight_cost + ...
                  ground_cost + spares_cost;
    
    % --- REVENUE: REO sales ---
    % Apply price elasticity based on market share
    global_demand_yr = ree.global_demand_2026 * ...
        (1 + ree.demand_cagr)^((ph.y_start + ph.y_end)/2);
    market_share = ph.reo_tyr / max(global_demand_yr, 1);
    price_adj = max(ree.price_floor, ...
        ree.basket_price_2026 * (1 + ree.price_elasticity * market_share));
    reo_revenue = ph.reo_tyr * price_adj;
    
    % --- REVENUE: PGM sales ---
    pgm_revenue = ph.pgm_tyr * 1000 * pgm.basket_price;  % kg × $/kg
    
    rev_per_yr = reo_revenue + pgm_revenue;
    
    % --- EXTERNALITY: Avoided terrestrial damage ---
    ext_per_yr = ph.reo_tyr * ext.total_per_tREO;
    
    % --- LAUNCH CARBON COST ---
    total_flights_yr = (ph.cargo_flights + ph.crew_flights) / dur + ...
                       reagent_flights;
    carbon_cost_yr = total_flights_yr * launch.co2_per_launch * launch.scc;
    
    % --- Distribute to annual arrays ---
    for y = max(0, ph.y_start):min(T, ph.y_end-1)
        idx = y + 1;
        capex_annual(idx) = capex_annual(idx) + capex_per_yr;
        opex_annual(idx)  = opex_annual(idx) + opex_per_yr;
        revenue_annual(idx) = revenue_annual(idx) + rev_per_yr;
        extern_annual(idx) = extern_annual(idx) + ext_per_yr;
        launch_carbon(idx) = launch_carbon(idx) + carbon_cost_yr;
    end
    
    total_capex = total_capex + capex_phase;
    total_opex = total_opex + opex_per_yr * dur;
    total_revenue = total_revenue + rev_per_yr * dur;
    total_extern = total_extern + ext_per_yr * dur;
    
    % --- Print phase summary ---
    fprintf('--- %s (%s) Y%d–Y%d ---\n', ph.name, ph.description, ph.y_start, ph.y_end);
    fprintf('  CapEx:     $%12.2fB (incl %d%% contingency)\n', capex_phase/1e9, cont*100);
    fprintf('  OpEx/yr:   $%12.2fB\n', opex_per_yr/1e9);
    fprintf('  Revenue/yr:$%12.2fB  (REO: $%.2fB, PGM: $%.2fB)\n', ...
        rev_per_yr/1e9, reo_revenue/1e9, pgm_revenue/1e9);
    fprintf('  Extern/yr: $%12.2fB  (avoided terr. damage)\n', ext_per_yr/1e9);
    fprintf('  REO: %.1f t/yr | PGM: %.1f kg/yr | Crew: %d\n', ...
        ph.reo_tyr, ph.pgm_tyr*1000, ph.crew);
    fprintf('  Reagent flights/yr: %d | Launch carbon: $%.1fM/yr\n', ...
        reagent_flights, carbon_cost_yr/1e6);
    fprintf('  Circuits: %d SPA + %d PKT = %d\n', ...
        ph.proc_circuits_spa, ph.proc_circuits_pkt, ...
        ph.proc_circuits_spa + ph.proc_circuits_pkt);
    fprintf('\n');
end

%% ====================================================================
%  SECTION 4: NET CASH FLOW & DISCOUNTING
% =====================================================================

% Net cash flow (commercial only — revenue minus costs)
ncf_commercial = revenue_annual - capex_annual - opex_annual - launch_carbon;

% Net cash flow (hybrid — includes monetised externalities)
ncf_hybrid = ncf_commercial + extern_annual;

% Build discount factor vector (declining schedule)
df = zeros(T+1, 1);
for y = 0:T
    if y <= disc.y1
        r = disc.r1;
    elseif y <= disc.y2
        r = disc.r2;
    else
        r = disc.r3;
    end
    if y == 0
        df(y+1) = 1;
    else
        df(y+1) = df(y) / (1 + r);
    end
end

% Discounted cash flows
dcf_commercial = ncf_commercial .* df;
dcf_hybrid     = ncf_hybrid .* df;

% NPV
npv_commercial = sum(dcf_commercial);
npv_hybrid     = sum(dcf_hybrid);

% BCR
total_costs_pv = sum((capex_annual + opex_annual + launch_carbon) .* df);
total_rev_pv   = sum(revenue_annual .* df);
total_ext_pv   = sum(extern_annual .* df);

bcr_commercial = total_rev_pv / total_costs_pv;
bcr_hybrid     = (total_rev_pv + total_ext_pv) / total_costs_pv;

% IRR (approximate — find rate where NPV = 0)
% Commercial IRR
irr_func = @(r) sum(ncf_commercial ./ (1+r).^(0:T)');
try
    irr_commercial = fzero(irr_func, [0.001, 0.50]);
catch
    irr_commercial = NaN;  % No IRR if never profitable
end

% Hybrid IRR
irr_func_h = @(r) sum(ncf_hybrid ./ (1+r).^(0:T)');
try
    irr_hybrid = fzero(irr_func_h, [0.001, 0.50]);
catch
    irr_hybrid = NaN;
end

% Payback period (undiscounted)
cumcf_commercial = cumsum(ncf_commercial);
cumcf_hybrid     = cumsum(ncf_hybrid);
payback_commercial = find(cumcf_commercial > 0, 1) - 1;
payback_hybrid     = find(cumcf_hybrid > 0, 1) - 1;
if isempty(payback_commercial), payback_commercial = Inf; end
if isempty(payback_hybrid), payback_hybrid = Inf; end

%% ====================================================================
%  SECTION 5: RESULTS
% =====================================================================
fprintf('================================================================\n');
fprintf('  VIABILITY INDICATORS\n');
fprintf('================================================================\n\n');

fprintf('  Discount rate: %.1f%% (Y0-30), %.1f%% (Y31-75), %.1f%% (Y76-100)\n', ...
    disc.r1*100, disc.r2*100, disc.r3*100);
fprintf('  Launch cost: $%d/kg (early), $%d/kg (mid), $%d/kg (late)\n\n', ...
    launch.cost_kg_early, launch.cost_kg_mid, launch.cost_kg_late);

fprintf('  --- COMMERCIAL (REO + PGM revenue only) ---\n');
fprintf('  Total CapEx (undiscounted):     $%9.1fB\n', total_capex/1e9);
fprintf('  Total OpEx (undiscounted):      $%9.1fB\n', total_opex/1e9);
fprintf('  Total Revenue (undiscounted):   $%9.1fB\n', total_revenue/1e9);
fprintf('  NPV (commercial):              $%9.1fB\n', npv_commercial/1e9);
fprintf('  BCR (commercial):              %9.3f\n', bcr_commercial);
fprintf('  IRR (commercial):              %9.1f%%\n', irr_commercial*100);
fprintf('  Payback (undiscounted):         Year %d\n\n', payback_commercial);

fprintf('  --- HYBRID (revenue + monetised externalities) ---\n');
fprintf('  Externality value (undisc):     $%9.1fB\n', total_extern/1e9);
fprintf('  NPV (hybrid):                  $%9.1fB\n', npv_hybrid/1e9);
fprintf('  BCR (hybrid):                  %9.3f\n', bcr_hybrid);
fprintf('  IRR (hybrid):                  %9.1f%%\n', irr_hybrid*100);
fprintf('  Payback (undiscounted):         Year %d\n\n', payback_hybrid);

fprintf('  --- LAUNCH CARBON FOOTPRINT ---\n');
fprintf('  Total launch carbon cost:       $%9.1fB\n', sum(launch_carbon)/1e9);
fprintf('  Total avoided externality:      $%9.1fB\n', total_extern/1e9);
fprintf('  Net environmental benefit:      $%9.1fB\n', ...
    (total_extern - sum(launch_carbon))/1e9);

%% ====================================================================
%  SECTION 6: SENSITIVITY ANALYSIS
% =====================================================================
fprintf('\n================================================================\n');
fprintf('  SENSITIVITY ANALYSIS\n');
fprintf('================================================================\n\n');

% Test factors: launch cost, REE price, discount rate, contingency,
%               reagent in-situ fraction, programme timeline
deviations = [-30, -15, 0, 15, 30];  % percentage deviations

% We'll test NPV sensitivity to each factor
factors = {'Launch Cost', 'REE Basket Price', 'Flat Discount Rate', ...
           'Contingency', 'Externality Value'};

npv_sens = zeros(length(factors), length(deviations));

for f = 1:length(factors)
    for d = 1:length(deviations)
        dev = deviations(d) / 100;
        
        % Recompute NCF with modified parameter
        ncf_test = ncf_hybrid;  % start from hybrid
        
        switch f
            case 1  % Launch cost
                % Approximate: costs scale linearly with launch cost
                cost_mult = 1 + dev;
                ncf_test = (revenue_annual + extern_annual) - ...
                    (capex_annual + opex_annual + launch_carbon) * cost_mult;
            case 2  % REE price
                price_mult = 1 + dev;
                ncf_test = ncf_hybrid + revenue_annual * dev;
            case 3  % Flat discount rate (test at 1%, 2%, 2.5%, 3%, 4%)
                test_rates = [0.01, 0.02, 0.025, 0.03, 0.04];
                r_test = test_rates(d);
                df_test = 1 ./ (1 + r_test).^(0:T)';
                npv_sens(f, d) = sum(ncf_hybrid .* df_test) / 1e9;
                continue
            case 4  % Contingency
                cont_mult = 1 + dev;
                ncf_test = ncf_hybrid + capex_annual * ...
                    (1 - cont_mult) * 0.3; % ~30% of capex is contingency
            case 5  % Externality value
                ext_mult = 1 + dev;
                ncf_test = ncf_commercial + extern_annual * ext_mult;
        end
        
        npv_sens(f, d) = sum(ncf_test .* df) / 1e9;
    end
end

% Print sensitivity table
fprintf('  NPV Sensitivity (Hybrid, $B)\n');
fprintf('  %-20s', 'Factor');
for d = 1:length(deviations)
    fprintf('%10s', [num2str(deviations(d)) '%']);
end
fprintf('\n');
fprintf('  %s\n', repmat('-', 1, 70));

for f = 1:length(factors)
    fprintf('  %-20s', factors{f});
    for d = 1:length(deviations)
        fprintf('%10.1f', npv_sens(f, d));
    end
    fprintf('\n');
end

% Discount rate separate display
fprintf('\n  Discount Rate Sensitivity (NPV Hybrid, $B):\n');
test_rates_str = {'1.0%', '2.0%', '2.5%', '3.0%', '4.0%'};
for d = 1:5
    fprintf('    r = %s:  NPV = $%.1fB\n', test_rates_str{d}, npv_sens(3,d));
end

%% ====================================================================
%  SECTION 7: KEY FINDINGS SUMMARY
% =====================================================================
fprintf('\n================================================================\n');
fprintf('  KEY FINDINGS\n');
fprintf('================================================================\n\n');

fprintf('  1. The programme is commercially NEGATIVE at all discount rates\n');
fprintf('     above ~%.1f%% due to the 40-60 year lag between investment\n', ...
    max(irr_commercial*100, 0));
fprintf('     and significant revenue.\n\n');

fprintf('  2. INCLUDING monetised environmental externalities, the\n');
fprintf('     programme achieves positive NPV at discount rates ≤%.1f%%,\n', ...
    max(irr_hybrid*100, 0));
fprintf('     consistent with Arrow et al. (2014) declining schedule.\n\n');

fprintf('  3. The P8-P9 chemical transport era is the cost bottleneck:\n');
fprintf('     reagent delivery alone requires ~%d Starship flights/yr\n', ...
    ceil(phases(9).reagent_earth_tyr * 1000 / launch.starship_cargo));
fprintf('     at P9. In-situ reagent production is economically essential.\n\n');

fprintf('  4. Net environmental benefit (avoided damage minus launch\n');
fprintf('     carbon) is $%.1fB — launch pollution is dwarfed by\n', ...
    (total_extern - sum(launch_carbon))/1e9);
fprintf('     avoided terrestrial mining damage by >%.0f×.\n\n', ...
    total_extern / max(sum(launch_carbon), 1));

fprintf('  5. The programme is best justified as a sovereign/consortium\n');
fprintf('     investment capturing intergenerational public goods,\n');
fprintf('     analogous to nuclear waste management or climate adaptation.\n');

fprintf('\n================================================================\n');
fprintf('  SELENITE_ECON v1.0 COMPLETE\n');
fprintf('================================================================\n');