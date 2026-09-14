%% SELENITE_VERIFY_v3.m
%  Demand-Driven Fleet Sizing & Base Infrastructure Verification
%  Solar-Only Power · Separated ISRU · 1000 VDC · Batch Dump
%
%  CHANGES FROM v2:
%    - Nuclear fission REMOVED from Shackleton (reserved for PKT)
%    - Solar-only power at Shackleton ridge
%    - ISRU plant SEPARATED 200-500m from habitat (LH2 hazard)
%    - Docking zone adjacent to ISRU (propellant transfer)
%    - Beneficiation zone 1 km from habitat (unchanged)
%    - 5 MOLE-I per sub-station node, fleet demand-derived
%    - Continuous tethered ops, substation drums, batch dump
%    - 1000 VDC trunk (from 400 V)
%    - MOLE-I: 1,842 W operating / 122 W keep-alive
%    - mini-VEX: 1,200 W (from 100 W)
%    - ISRU electrolysis power properly accounted (dominant load)
%
%  Author : Jason (Systems Engineering Lead), Selenite Programme
%  Date   : March 2026

clear; clc; close all;

%% === CONSTANTS ===
g0 = 9.81; g_moon = 1.62; Isp = 450; ve = Isp * g0;

fprintf('================================================================\n');
fprintf('  SELENITE v3 - Demand-Driven Verification\n');
fprintf('  Solar-Only / Separated ISRU / 1000 VDC\n');
fprintf('================================================================\n\n');

%% === SECTION 1: ENVIRONMENT & UNIT PARAMETERS ===
fprintf('== SECTION 1: ENVIRONMENT & UNIT PARAMETERS ==\n');

crater.depth_km = 4.2;
crater.wall_slope_deg = 30;
crater.traverse_km = crater.depth_km / sind(crater.wall_slope_deg);
crater.floor_dia_km = 6.5;
crater.floor_area_km2 = pi*(crater.floor_dia_km/2)^2;
crater.T_floor = 40;
crater.ice_design = 0.0446;

solar.illumination = 0.85;
solar.panel_eff = 0.29;
solar.irradiance = 1.361;

mi.prop_yield_yr = 5692;
mi.water_rate_hr = 25 * crater.ice_design;
mi.water_yr = mi.water_rate_hr * 0.80 * 8760;
mi.mass_dry = 357;
mi.pwr_operating = 1842;
mi.pwr_keepalive = 122;
mi.tether_m = 200;

node.units_per = 5;
node.ports_per = 6;
node.overhead_W = 80 + 8*5;
node.mass_kg = 200;

fprintf('  Traverse: %.1f km | Floor: %.1f km2\n', crater.traverse_km, crater.floor_area_km2);
fprintf('  MOLE-I: %d kg dry, %d W operating, %d W keepalive\n', mi.mass_dry, mi.pwr_operating, mi.pwr_keepalive);
fprintf('  Yield: %d kg prop/yr per unit (v2 locked)\n', mi.prop_yield_yr);
fprintf('  Node: %d units, %d W overhead\n\n', node.units_per, node.overhead_W);

%% === SECTION 2: FLEET CONSUMERS ===
fprintf('== SECTION 2: FLEET CONSUMERS ==\n');

probe.prop_per = 6654;
probe.missions_yr = 1;

skip.m_final = 650;
skip.range_km = 100;
skip.v0 = sqrt(skip.range_km*1000*g_moon);
skip.dv_rt = 4*skip.v0*1.05;
skip.fuel_hop = skip.m_final*(exp(skip.dv_rt/ve)-1);
skip.hops_yr = 274;
skip.fuel_yr = skip.hops_yr * skip.fuel_hop;
skip.kreep_yr = skip.hops_yr * 350;

dart.prop_mission = 12370;

ls.elec_eff = 0.722;
ls.prop_equiv_crew = 0.9*365/0.889*ls.elec_eff;

fprintf('  PROBE: %d kg/mission | SKIP: %.0f kg/hop, %.1f t/yr/craft\n', ...
    probe.prop_per, skip.fuel_hop, skip.fuel_yr/1000);
fprintf('  DART: %d kg (single mission) | L/S: %.0f kg/crew/yr\n\n', ...
    dart.prop_mission, ls.prop_equiv_crew);

%% === SECTION 3: DEMAND-DRIVEN FLEET SIZING ===
fprintf('== SECTION 3: DEMAND-DRIVEN FLEET SIZING ==\n');
fprintf('  MOLE-I = ceil(demand x 1.10 / %d), rounded to x5\n\n', mi.prop_yield_yr);

ph.names = {'P3 Y4-7','P4 Y7-9','P5 Y9-12','P6 Y12-15','P7+ Y20+'};
ph.labels = {'P3','P4','P5','P6','P7+'};
ph.n = 5;
ph.dur = [3 2 3 3 5];
ph.nProbe = [3 6 10 15 30];
ph.nSkip = [0 1 2 4 8];
ph.nDart = [0 0 1 1 0];
ph.crew = [0 4 4 6 12];

ph.d_probe = zeros(1,ph.n);
ph.d_skip = zeros(1,ph.n);
ph.d_dart = zeros(1,ph.n);
ph.d_ls = zeros(1,ph.n);

for i = 1:ph.n
    if i == 1
        ph.d_probe(i) = 0;
    else
        ph.d_probe(i) = ph.nProbe(i)*probe.prop_per*probe.missions_yr;
    end
    ph.d_skip(i) = ph.nSkip(i)*skip.fuel_yr;
    if i == 3
        ph.d_dart(i) = dart.prop_mission/ph.dur(i);
    end
    ph.d_ls(i) = ph.crew(i)*ls.prop_equiv_crew;
end
ph.d_total = ph.d_probe + ph.d_skip + ph.d_dart + ph.d_ls;

margin_factor = 1.10;
ph.mi = zeros(1,ph.n);
ph.nodes = zeros(1,ph.n);
for i = 1:ph.n
    if ph.d_total(i) > 0
        raw = ceil(ph.d_total(i)*margin_factor/mi.prop_yield_yr);
    else
        raw = 10;
    end
    ph.mi(i) = ceil(raw/node.units_per)*node.units_per;
    ph.nodes(i) = ph.mi(i)/node.units_per;
end

ph.isru = ph.mi * mi.prop_yield_yr;
ph.margin = ph.isru - ph.d_total;

fprintf('  %-14s %4s %4s %4s %4s | %5s %5s | %8s %8s %8s %8s | %8s %8s %+8s  Status\n', ...
    'Phase','Prb','SKP','DRT','Crew','MI','Nodes', ...
    'Probe(t)','SKIP(t)','DART(t)','L/S(t)','Demand','Supply','Margin');
fprintf('  %s\n', repmat('-',1,120));

for i = 1:ph.n
    if ph.margin(i) >= 5000, st='OK'; elseif ph.margin(i)>=0, st='TIGHT'; else, st='DEFICIT'; end
    fprintf('  %-14s %4d %4d %4d %4d | %5d %5d | %7.1ft %7.1ft %7.1ft %7.1ft | %7.1ft %7.1ft %+7.1ft  %s\n', ...
        ph.names{i}, ph.nProbe(i), ph.nSkip(i), ph.nDart(i), ph.crew(i), ...
        ph.mi(i), ph.nodes(i), ...
        ph.d_probe(i)/1e3, ph.d_skip(i)/1e3, ph.d_dart(i)/1e3, ph.d_ls(i)/1e3, ...
        ph.d_total(i)/1e3, ph.isru(i)/1e3, ph.margin(i)/1e3, st);
end

fprintf('\n  STOCKPILE:\n');
stockpile = 0;
ph.stockpile = zeros(1,ph.n);
for i = 1:ph.n
    stockpile = stockpile + ph.margin(i)*ph.dur(i);
    ph.stockpile(i) = stockpile;
    fprintf('    %s: %+.1f t/yr x %d yr -> %.0f t cumulative\n', ...
        ph.labels{i}, ph.margin(i)/1e3, ph.dur(i), stockpile/1e3);
end

%% === SECTION 4: POWER BUDGET (SOLAR-ONLY, SEPARATED ISRU) ===
fprintf('\n== SECTION 4: POWER BUDGET (SOLAR-ONLY) ==\n');
fprintf('  No fission at Shackleton. ISRU separated 200-500m from habitat.\n\n');

V_trunk = 1000;
ph.water_yr = ph.mi .* mi.water_yr;
ph.water_hr = ph.water_yr / 8760;

% A. PSR power
ph.pwr_psr_fleet = ph.mi * mi.pwr_operating / 1000;
ph.pwr_psr_nodes = ph.nodes * node.overhead_W / 1000;
pipe_kW = 8500*7/1000;
ph.pwr_pipeline = [0 pipe_kW pipe_kW pipe_kW pipe_kW];
ph.pwr_psr = ph.pwr_psr_fleet + ph.pwr_psr_nodes + ph.pwr_pipeline;

% B. ISRU plant (SEPARATED)
% Industrial PEM: ~5.5 kW per kg/hr water
isru_kW_per_kghr = 5.5;
ph.pwr_electrolysis = ph.water_hr * isru_kW_per_kghr;
ph.h2_hr = ph.water_hr * (2/18);
ph.o2_hr = ph.water_hr * (16/18);
ph.pwr_cryo = ph.h2_hr*12 + ph.o2_hr*0.4;
ph.pwr_isru = ph.pwr_electrolysis + ph.pwr_cryo;
ph.n_stacks = ceil(ph.pwr_electrolysis / 50);

% C. Habitat
ph.pwr_eclss = [0 6 6 6 6];
ph.pwr_habitat = [2 6.5 6.5 6.5 6.5];
ph.pwr_comms = 1.5*ones(1,ph.n);
ph.pwr_hab = ph.pwr_eclss + ph.pwr_habitat + ph.pwr_comms;

% D. Surface robots (SINTER self-powered, not in grid)
ph.nMoleS = [4 4 4 6 6]; ph.nARM = [2 4 6 8 8];
ph.nSurvey = [1 1 2 2 2]; ph.nSentinel = [2 2 3 4 4];
ph.pwr_robots = ph.nMoleS*0.8*0.5 + ph.nARM*1.0 + (ph.nSurvey+ph.nSentinel)*0.2;

% E. Beneficiation + Docking
ph.pwr_benef = [0 0 0 15 20];
ph.pwr_dock = [1 2 3 4 5];

% Totals
ph.pwr_base = ph.pwr_hab + ph.pwr_robots + ph.pwr_benef + ph.pwr_dock;
ph.pwr_subtotal = ph.pwr_psr + ph.pwr_isru + ph.pwr_base;
ph.pwr_contingency = ph.pwr_subtotal * 0.20;
ph.pwr_total = ph.pwr_subtotal + ph.pwr_contingency;
ph.solar_cap = ph.pwr_total / solar.illumination;
ph.panel_m2 = ph.solar_cap / (solar.irradiance * solar.panel_eff);

fprintf('  %-5s | %4s %5s | %8s %8s %8s | %8s | %8s %8s | %8s | %7s\n', ...
    'Phase','MI','Nodes','PSR(kW)','Pipe(kW)','ISRU(kW)','Base(kW)', ...
    'Subtot','Conting','TOTAL','Panels');
fprintf('  %s\n', repmat('-',1,105));
for i = 1:ph.n
    fprintf('  %-5s | %4d %5d | %7.0f  %7.0f  %7.0f  | %7.1f  | %7.0f  %7.0f  | %7.0f kW %6.0f m2\n', ...
        ph.labels{i}, ph.mi(i), ph.nodes(i), ...
        ph.pwr_psr_fleet(i)+ph.pwr_psr_nodes(i), ph.pwr_pipeline(i), ph.pwr_isru(i), ...
        ph.pwr_base(i), ph.pwr_subtotal(i), ph.pwr_contingency(i), ...
        ph.pwr_total(i), ph.panel_m2(i));
end
fprintf('\n  SINTER self-powered (onboard reactor) - NOT in grid.\n');

%% === SECTION 5: ISRU PLANT DETAIL ===
fprintf('\n== SECTION 5: ISRU PLANT (SEPARATED) ==\n');
fprintf('  200-500m from habitat. No pressurised connections.\n');
fprintf('  Propellant lines to adjacent docking zone only.\n\n');

for i = 1:ph.n
    lh2_yr = ph.isru(i)*(1/6.5)/1e3;
    lox_yr = ph.isru(i)*(5.5/6.5)/1e3;
    fprintf('  %s (%d MI): %.1f kg/hr water | %d PEM stacks | %.0f kW elec + %.0f kW cryo = %.0f kW ISRU\n', ...
        ph.labels{i}, ph.mi(i), ph.water_hr(i), ph.n_stacks(i), ...
        ph.pwr_electrolysis(i), ph.pwr_cryo(i), ph.pwr_isru(i));
    fprintf('          LH2: %.1ft/yr (%.0f m3) | LOX: %.1ft/yr (%.0f m3)\n', ...
        lh2_yr, lh2_yr*1e3/70.8, lox_yr, lox_yr*1e3/1141);
end

%% === SECTION 6: TRUNK CABLE & INFRASTRUCTURE ===
fprintf('\n== SECTION 6: TRUNK CABLE & INFRASTRUCTURE ==\n');

cu_rho = 0.24e-8; cu_den = 8960;
trunk_m = crater.traverse_km*1000;

for i = 1:ph.n
    psr_kW = ph.pwr_psr(i);
    I = psr_kW*1000/V_trunk;
    if I > 0
        R = 0.05*V_trunk/I;
        A = cu_rho*trunk_m*2/R*1e6;
        mass = A*1e-6*trunk_m*2*cu_den;
    else
        A = 10; mass = 1500; I = 0;
    end
    fprintf('  %s: PSR %.0f kW -> %3.0f A -> %4.0f mm2 -> %5.1f t\n', ...
        ph.labels{i}, psr_kW, I, A, mass/1e3);
end

% Node geometry for max phase
max_nodes = max(ph.nodes);
fprintf('\n  NODE LAYOUT (%d nodes):\n', max_nodes);
ring_nodes=[]; ring_radii=[]; remaining=max_nodes; r=400;
while remaining > 0
    n = min(remaining, max(1,floor(2*pi*r/450)));
    ring_nodes=[ring_nodes n]; ring_radii=[ring_radii r];
    remaining = remaining - n;
    r = r+500;
end
backbone_km = sum(2*pi*ring_radii/1000);
for j = 1:length(ring_nodes)
    sp = 2*pi*ring_radii(j)/max(ring_nodes(j),1);
    fprintf('    Ring %d: %d nodes at %dm (spacing %.0fm, gap %.0fm)\n', ...
        j, ring_nodes(j), ring_radii(j), sp, sp-400);
end
fprintf('    Floor used: %.1f%% of %.1f km2\n', ...
    max_nodes*pi*200^2/(crater.floor_area_km2*1e6)*100, crater.floor_area_km2);

% Infrastructure mass
[~,idx]=max(ph.pwr_psr);
psr_kW=ph.pwr_psr(idx); I=psr_kW*1000/V_trunk;
R=0.05*V_trunk/I; A=cu_rho*trunk_m*2/R*1e6;
trunk_mass = A*1e-6*trunk_m*2*cu_den;
bb_mass = backbone_km*2*10e-6*1000*cu_den;
tether_mass = max_nodes*5*200*2*10e-6*cu_den;
pipe_mass = 8500*3.5*2;
total_infra = trunk_mass+bb_mass+tether_mass+pipe_mass;

fprintf('\n  INFRASTRUCTURE: Trunk %.1ft + Backbone %.1ft + Tethers %.1ft + Pipeline %.1ft = %.1ft\n', ...
    trunk_mass/1e3, bb_mass/1e3, tether_mass/1e3, pipe_mass/1e3, total_infra/1e3);

%% === SECTION 7: MATERIAL HANDLING ===
fprintf('\n== SECTION 7: MATERIAL HANDLING ==\n');
fprintf('  CAMPUS ZONES:\n');
fprintf('    1. HABITAT: Crew quarters, ops hub, ECLSS, medical\n');
fprintf('    2. ISRU:    Electrolysis, cryo, LH2/LOX tanks (200-500m from hab)\n');
fprintf('    3. DOCKING:  PROBE/SKIP collars, ARM, refuelling (adjacent ISRU)\n');
fprintf('    4. BENEF:   KREEP processing, stockpile (1 km from hab)\n');
fprintf('    5. POWER:   Solar arrays on Shackleton ridge\n\n');

fprintf('  KREEP FLOW: SKIP pad -> MOLE-S transport -> Benef Zone -> stockpile -> Earth return\n');
for i = 1:ph.n
    k = ph.nSkip(i)*skip.kreep_yr/1e3;
    c = k*0.04;
    fprintf('    %s: %d SKIPs -> %.0f t/yr raw -> %.1f t/yr concentrate (4%% recovery)\n', ...
        ph.labels{i}, ph.nSkip(i), k, c);
end

fprintf('\n  PGM FLOW: PROBE dock -> ARM unload -> stockpile -> Earth return\n');
for i = 1:ph.n
    if i==1, fprintf('    %s: Earth-fuelled scouts only\n', ph.labels{i});
    else, fprintf('    %s: %d PROBEs -> %.1f t/yr Ni-Fe/PGM\n', ph.labels{i}, ph.nProbe(i), ph.nProbe(i)*1.5);
    end
end

%% === SECTION 8: FAILURE ANALYSIS ===
fprintf('\n== SECTION 8: FAILURE ANALYSIS ==\n');
dem_p6 = ph.d_total(4);
min_mi = ceil(dem_p6/mi.prop_yield_yr);
fprintf('  P6: %.0ft demand -> min %d MI | fleet %d -> %d spare\n', ...
    dem_p6/1e3, min_mi, ph.mi(4), ph.mi(4)-min_mi);
fprintf('  Stockpile at P6 end: %.0f t (%.1f months reserve)\n', ...
    ph.stockpile(4)/1e3, ph.stockpile(4)/dem_p6*12);

spares = ceil(ph.mi(end)*0.12);
fprintf('  Cold spares: %d units (12%% of P7+ fleet)\n', spares);

%% === SECTION 9: FIGURES ===
x = 1:ph.n;

figure('Name','Fig 1: Propellant Balance','Position',[50 50 900 500]);
b=bar(x,[ph.isru;ph.d_total]'/1e3,'grouped');
b(1).FaceColor=[.18 .55 .82]; b(2).FaceColor=[.85 .32 .24];
hold on; plot(x,ph.margin/1e3,'k--o','LineWidth',2,'MarkerFaceColor',[.2 .7 .3],'MarkerSize',8);
yline(0,'k:'); ylabel('Propellant (t/yr)'); xticks(x); xticklabels(ph.labels);
legend('ISRU Supply','Demand','Margin','Location','northwest');
title('Propellant Balance - Demand-Driven'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.isru(i)/1e3+20,sprintf('%d MI\n%d nodes',ph.mi(i),ph.nodes(i)),...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold'); end

figure('Name','Fig 2: Demand Composition','Position',[50 600 900 500]);
b2=bar(x,[ph.d_probe;ph.d_skip;ph.d_dart;ph.d_ls]'/1e3,'stacked');
b2(1).FaceColor=[.18 .42 .72]; b2(2).FaceColor=[.85 .32 .24];
b2(3).FaceColor=[.72 .52 .18]; b2(4).FaceColor=[.3 .65 .3];
hold on; plot(x,ph.isru/1e3,'k-s','LineWidth',2.5,'MarkerFaceColor','k','MarkerSize',8);
ylabel('Propellant (t/yr)'); xticks(x); xticklabels(ph.labels);
legend('PROBE','SKIP','DART','Life Support','ISRU Supply','Location','northwest');
title('Demand Composition'); grid on; set(gca,'FontSize',11);

figure('Name','Fig 3: Power Budget','Position',[1000 50 950 550]);
pz = [ph.pwr_psr_fleet+ph.pwr_psr_nodes; ph.pwr_pipeline; ph.pwr_isru; ph.pwr_base; ph.pwr_contingency]';
b3=bar(x,pz,'stacked');
c3={[.85 .32 .24],[.18 .55 .82],[.92 .65 .15],[.3 .65 .3],[.6 .6 .6]};
for j=1:5, b3(j).FaceColor=c3{j}; end
ylabel('Power (kW)'); xticks(x); xticklabels(ph.labels);
legend('PSR Fleet','Pipeline','ISRU Plant','Base','Contingency','Location','northwest');
title('Power Budget by Zone (Solar-Only)'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.pwr_total(i)+10,sprintf('%.0f kW\n%.0f m2',ph.pwr_total(i),ph.panel_m2(i)),...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold'); end

figure('Name','Fig 4: Solar Array','Position',[1000 600 800 450]);
bar(x,ph.panel_m2,'FaceColor',[.92 .75 .18]);
ylabel('Panel Area (m2)'); xticks(x); xticklabels(ph.labels);
title('Solar Array Area by Phase (GaAs 29%, 85% sun)'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.panel_m2(i)+50,sprintf('%.0f m2\n(%.2f ha)',ph.panel_m2(i),ph.panel_m2(i)/1e4),...
    'HorizontalAlignment','center','FontSize',10); end

figure('Name','Fig 5: Stockpile','Position',[50 1150 900 450]);
yrs=[]; st=[]; c=0; ys=4;
for i=1:ph.n, for y=1:ph.dur(i), c=c+ph.margin(i); yrs=[yrs ys+y-1]; st=[st c/1e3]; end; ys=ys+ph.dur(i); end
plot(yrs,st,'b-','LineWidth',2.5); hold on; yline(410,'r--','LineWidth',1.5);
ps=cumsum([4 ph.dur]);
for i=1:ph.n, xline(ps(i),'k:'); text(ps(i)+.3,max(st)*.95,ph.labels{i},'FontSize',10,'FontWeight','bold'); end
xlabel('Year'); ylabel('Stockpile (t)'); title('Propellant Stockpile'); grid on; set(gca,'FontSize',11);

figure('Name','Fig 6: Fleet Scaling','Position',[1000 1150 800 450]);
yyaxis left; bar(x,ph.mi,'FaceColor',[.18 .55 .82]); ylabel('MOLE-I Units');
yyaxis right; plot(x,ph.nodes,'r-o','LineWidth',2.5,'MarkerFaceColor','r','MarkerSize',8); ylabel('Nodes');
xticks(x); xticklabels(ph.labels); title('Fleet & Node Scaling'); grid on; set(gca,'FontSize',11);
legend('MOLE-I','Nodes','Location','northwest');

%% === SUMMARY ===
fprintf('\n================================================================\n');
fprintf('  v3 SUMMARY\n');
fprintf('================================================================\n');
fprintf('  Power: SOLAR-ONLY | ISRU: SEPARATED | Trunk: %d VDC\n\n', V_trunk);
all_pass = true;
for i=1:ph.n
    s='PASS'; if ph.margin(i)<0, s='FAIL'; all_pass=false; end
    fprintf('  %s: %3d MI (%2d nodes) | %5.0ft supply - %5.0ft demand = %+5.0ft [%s]\n', ...
        ph.labels{i}, ph.mi(i), ph.nodes(i), ph.isru(i)/1e3, ph.d_total(i)/1e3, ph.margin(i)/1e3, s);
end
fprintf('\n');
for i=1:ph.n
    fprintf('  %s: %4.0f kW total | %4.0f kW solar | %5.0f m2 panels (%.2f ha)\n', ...
        ph.labels{i}, ph.pwr_total(i), ph.solar_cap(i), ph.panel_m2(i), ph.panel_m2(i)/1e4);
end
fprintf('\n  Stockpile: %.0f t | Infra: %.0f t | Spares: %d units\n', ...
    stockpile/1e3, total_infra/1e3, spares);
if all_pass
    fprintf('\n  ** ALL PHASES BALANCED [PASS] **\n');
else
    fprintf('\n  !! BALANCE FAILURE [FAIL] !!\n');
end
fprintf('================================================================\n');