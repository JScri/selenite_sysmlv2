%% SELENITE_VERIFY_v4_5.m
%  Demand-Driven Fleet Sizing & Base Infrastructure Verification
%  6-Wheel MOLE-I | Ti Flexure Pivots | Bilateral Fishbone | 1000 VDC
%  Hybrid Power (Solar + FSP Eclipse) | Separated ISRU | CAP
%
%  v4.5: Variable-length pipeline heating + fishbone geometry:
%    - Pipe heating scales with deployed length per phase (not flat)
%    - Three pipe types: trunk (7 W/m ground), spine (7 W/m ground),
%      branch (1.5 W/m elevated vacuum+MLI)
%    - Best case (pack from CLP) vs worst case (1/branch, far end)
%    - Pipeline pressure: 80 bar working / 200 bar burst
%    - FSP decision gate: if worst-case pipe exceeds +40kW contingency
%    - Fishbone geometry from VISUALIZE v3.3 (12 junctions, 24 branches)
%  v4.4: Full power chain (tether 1934W, substation 95.5W, 3x LWRHU)
%  v4.3: MOLE-I thermal corrections (WEB 57->15W, VEX stby eliminated)
%  v4.2: Corrected eclipse model, CAP power, 6-wheel cascade, EOL derating
%  Author: Jason (Systems Engineering Lead), Selenite Programme
%  Date: March 2026

clear; clc; close all;

g0=9.81; g_moon=1.62; Isp=450; ve=Isp*g0;

fprintf('================================================================\n');
fprintf('  SELENITE v4.5 - Variable Pipeline + Full Power Chain\n');
fprintf('  Fishbone from VISUALIZE v3.3 | Tether 1934W | Sub 95.5W\n');
fprintf('  Pipe: trunk 7W/m | spine 7W/m | branch 1.5W/m (elevated)\n');
fprintf('  Best/worst case pipe heating | FSP decision gate\n');
fprintf('  Ref: MOLEI_THERMAL v1.3, VISUALIZE v3.3\n');
fprintf('================================================================\n\n');

%% ENVIRONMENT
crater.traverse_km = 4.2/sind(30);
crater.floor_dia_km = 6.5;
crater.floor_area = pi*(crater.floor_dia_km/2)^2;
crater.ice_frac = 0.0446;

solar.illum = 0.85; solar.eff = 0.29; solar.irr = 1.361; solar.eol = 0.85;
fsp.pwr_kW = 40; fsp.mass_kg = 6600;

%% MOLE-I (6-WHEEL)
mi.mass_dry = 360; mi.n_wheels = 6; mi.prop_yield = 5692;
mi.water_rate = 25*crater.ice_frac; mi.water_yr = mi.water_rate*0.80*8760;

mi.pwr.drive=300; mi.pwr.drill=200; mi.pwr.minivex=1200;
mi.pwr.web=15;      % v4.4: was 57W original, 15W since v4.3. MOLEI_THERMAL v1.3: 11.6W WEB loss
                     %   (108 conductors, 0.529W harness) + 3.1W VEX strap = 14.7W, rounded to 15W.
mi.pwr.comms=20; mi.pwr.gbx_htr=30; mi.pwr.drill_htr=15; mi.pwr.recept=5;
mi.pwr.vex_stby=0;  % Eliminated since v4.3 by Cu braid thermal strap from WEB.

mi.pwr_op = mi.pwr.drive+mi.pwr.drill+mi.pwr.minivex+mi.pwr.web+mi.pwr.comms+...
            mi.pwr.gbx_htr+mi.pwr.drill_htr+mi.pwr.recept+mi.pwr.vex_stby;
mi.pwr_ka = mi.pwr.web+mi.pwr.gbx_htr+mi.pwr.drill_htr+mi.pwr.recept+mi.pwr.vex_stby;

% v4.4: DC-DC conversion losses + battery trickle charge
mi.dcdc.eff_48v=0.95; mi.dcdc.eff_28v=0.93; mi.dcdc.eff_5v=0.90;
mi.dcdc.load_48v=1730; mi.dcdc.load_28v=90; mi.dcdc.load_5v=13;
mi.dcdc.loss_48v = mi.dcdc.load_48v*(1/mi.dcdc.eff_48v-1);  % 91W
mi.dcdc.loss_28v = mi.dcdc.load_28v*(1/mi.dcdc.eff_28v-1);  % 6.8W
mi.dcdc.loss_5v  = mi.dcdc.load_5v*(1/mi.dcdc.eff_5v-1);    % 1.4W
mi.dcdc.loss_total = mi.dcdc.loss_48v+mi.dcdc.loss_28v+mi.dcdc.loss_5v;
mi.batt_charge = 50;  % W trickle charge average

% Tether draw = what the substation bus must supply per MOLE-I
mi.pwr_tether = mi.pwr_op + mi.dcdc.loss_total + mi.batt_charge;

mi.descent_hr = (crater.traverse_km*1000/0.5)/3600;
mi.batt_Wh = mi.pwr_ka*mi.descent_hr*1.10;
mi.batt_kg = mi.batt_Wh/250;

fprintf('== MOLE-I (6-WHEEL) ==\n');
fprintf('  %d kg dry | %d W op | %d W ka | %.0f Wh batt\n',...
    mi.mass_dry,mi.pwr_op,mi.pwr_ka,mi.batt_Wh);
fprintf('  Tether draw: %dW (load %d + DC-DC %.0f + batt %d)\n',...
    round(mi.pwr_tether),mi.pwr_op,mi.dcdc.loss_total,mi.batt_charge);
fprintf('  1000 VDC end-to-end. PDU inside WEB: 48/28/5V.\n');
fprintf('  VEX heater: 1000V direct (SiC MOSFET, 833ohm nichrome)\n\n');

%% SUBSTATION NODE (v4.4: audited from MOLEI_THERMAL v1.3 S10-S13)
node.units=5;
node.web=10.5;          % v4.4: was 80W. Bottom-up audit: 10.5W (MOLEI_THERMAL v1.3)
node.drums=5*8;         % 5 drums x 8W gearbox heater = 40W (unchanged)
node.pump=10;           % Transfer pump (unchanged)
node.riser=21;          % Riser trace heat 7W/m x 3m (was implicit in 130W total)
node.funnels=3;         % 5x 3W lip heaters, avg duty (was implicit)
node.comms=3;           % PLC + RF relay (was implicit)
node.controller=5;      % Port allocation + health hub (was implicit)
node.solenoids=3;       % 6x 0.5W holding (was implicit)
node.overhead = node.web+node.drums+node.pump+node.riser+...
                node.funnels+node.comms+node.controller+node.solenoids;  % 95.5W
node.lwrhu=3;           % v4.4: was 1. 3x LWRHU gives 33hr survival to 253K.
node.lwrhu_mass=node.lwrhu*0.042;  % kg per substation
node.mass=160;

%% PIPELINE (v4.5: variable-length, best/worst case from VISUALIZE v3.3)
% Fishbone geometry
pipe.trunk_m = 8500;           % rim -> CLP (fixed once installed, P4+)
pipe.q_ground = 7.0;           % W/m (trunk + spine, conduction to regolith)
pipe.q_elev = 1.5;             % W/m (branch, elevated 3m, vacuum+MLI, radiation only)
                                %   q_rad = eps*sigma*(273^4-40^4) = 9.4 W/m2 on 20mm pipe
                                %   = 0.59 W/m. With 2x degrade: 1.19. Design: 1.5 W/m.
                                %   Support PEEK standoffs add ~0.01 W/m (negligible).
pipe.q_support = 0.01;         % W/m (PEEK standoff conduction at supports, every 15m)
pump.trunk_kW = 0.408;         % 68 bar head (4200m vertical at 1.62 m/s2)

% Pipeline pressure specification (NEW v4.5)
pipe.pressure_working = 80;    % bar (68 bar static + flow losses + margin)
pipe.pressure_burst = 200;     % bar (2.5x safety factor)
pipe.wall_t = 1.0;             % mm Ti-6Al-4V (structural; pressure needs only 0.23mm)
pipe.check_valve = true;       % at each riser-to-branch junction (prevent backflow)

% Junction geometry from VISUALIZE v3.3
%   12 junctions at 500m spacing. CLP at x=-3100. J1 at -2750 (350m from CLP).
%   Max nodes per branch (bilateral): [3,4,5,6,6,7,7,6,6,5,4,3]
%   Node spacing: 450m. First node offset: 270m from spine.
pipe.jct_dist = 350 + (0:11)*500;  % distance from CLP to each junction [m]
pipe.jct_max  = [3,4,5,6,6,7,7,6,6,5,4,3];  % max nodes per branch (each side)
pipe.n_junctions = 12;
pipe.n_branches = 24;  % bilateral
pipe.node_spacing = 450;  % m
pipe.first_offset = 270;  % m

% Computation of best/worst case heating: after FLEET SIZING (needs ph.nd)
% See PIPELINE HEATING section below.

%% CAP (Phase 2+)
cap.peak_kW = 5.0;   % ascent: 4kW mech + 1kW internal
cap.stby_kW = 1.0;   % life support standby
cap.mass_loaded = 1360;

fprintf('== CAP ==\n');
fprintf('  %.1f kW peak | %.1f kW standby | %d kg loaded\n\n', cap.peak_kW, cap.stby_kW, cap.mass_loaded);

%% FLEET CONSUMERS
probe.prop = 6654;
skip.mf=650; skip.rng=100; skip.v0=sqrt(skip.rng*1000*g_moon);
skip.dv=4*skip.v0*1.05; skip.fuel_hop=skip.mf*(exp(skip.dv/ve)-1);
skip.hops=274; skip.fuel_yr=skip.hops*skip.fuel_hop; skip.kreep_yr=skip.hops*350;
dart.prop=12370;
ls.eff=0.722; ls.prop_crew=0.9*365/0.889*ls.eff;

%% DEMAND-DRIVEN FLEET SIZING
ph.lab={'P3','P4','P5','P6','P7+'};
ph.nm={'P3 Y4-7','P4 Y7-9','P5 Y9-12','P6 Y12-15','P7+ Y20+'};
ph.n=5; ph.dur=[3 2 3 3 5];
ph.nP=[3 6 10 15 30]; ph.nS=[0 1 2 4 8]; ph.nD=[0 0 1 1 0]; ph.crew=[0 4 4 6 12];

ph.dP=[0,6*6654,10*6654,15*6654,30*6654];
ph.dS=ph.nS*skip.fuel_yr; ph.dD=[0 0 dart.prop/3 0 0]; ph.dL=ph.crew*ls.prop_crew;
ph.dT=ph.dP+ph.dS+ph.dD+ph.dL;

mf=1.10; ph.mi=zeros(1,ph.n); ph.nd=zeros(1,ph.n);
for i=1:ph.n
    if ph.dT(i)>0, raw=ceil(ph.dT(i)*mf/mi.prop_yield); else, raw=10; end
    ph.mi(i)=ceil(raw/node.units)*node.units; ph.nd(i)=ph.mi(i)/node.units;
end
ph.isru=ph.mi*mi.prop_yield; ph.margin=ph.isru-ph.dT;

fprintf('== FLEET SIZING ==\n');
fprintf('  %-14s %4s %4s %4s %4s | %5s %5s | %8s %8s | %8s %8s %+8s\n',...
    'Phase','Prb','SKP','DRT','Crew','MI','Nod','Demand','Supply','Margin','','');
fprintf('  %s\n',repmat('-',1,95));
for i=1:ph.n
    fprintf('  %-14s %4d %4d %4d %4d | %5d %5d | %7.1ft %7.1ft | %+7.1ft  [%s]\n',...
        ph.nm{i},ph.nP(i),ph.nS(i),ph.nD(i),ph.crew(i),...
        ph.mi(i),ph.nd(i),ph.dT(i)/1e3,ph.isru(i)/1e3,ph.margin(i)/1e3,...
        ternary(ph.margin(i)>=0,'PASS','FAIL'));
end

stk=0; fprintf('\n  STOCKPILE:\n');
for i=1:ph.n, stk=stk+ph.margin(i)*ph.dur(i);
    fprintf('    %s: %+.1f t/yr x %d yr -> %.0f t\n',ph.lab{i},ph.margin(i)/1e3,ph.dur(i),stk/1e3); end


%% PIPELINE HEATING (v4.5: computed from fishbone geometry + fleet sizing)
branch_len = @(N) pipe.first_offset + (N-1)*pipe.node_spacing;

% === BEST CASE: deploy closest to CLP first ===
pipe.spine_best = zeros(1,ph.n);
pipe.branch_best = zeros(1,ph.n);
for p = 1:ph.n
    needed = ph.nd(p); placed = 0; s_len = 0; b_len = 0;
    for j = 1:pipe.n_junctions
        if placed >= needed, break; end
        s_len = pipe.jct_dist(j);
        for side = 1:2
            if placed >= needed, break; end
            avail = pipe.jct_max(j);
            use = min(avail, needed - placed);
            b_len = b_len + branch_len(use);
            placed = placed + use;
        end
    end
    pipe.spine_best(p) = s_len; pipe.branch_best(p) = b_len;
end

% === WORST CASE: 1 node per branch, farthest junction first ===
pipe.spine_worst = zeros(1,ph.n);
pipe.branch_worst = zeros(1,ph.n);
for p = 1:ph.n
    needed = ph.nd(p); placed = 0; s_len = 0; b_len = 0;
    for j = pipe.n_junctions:-1:1
        if placed >= needed, break; end
        s_len = pipe.jct_dist(j);
        for side = 1:2
            if placed >= needed, break; end
            b_len = b_len + branch_len(pipe.jct_max(j));
            placed = placed + 1;
        end
    end
    pipe.spine_worst(p) = s_len; pipe.branch_worst(p) = b_len;
end

% Compute heating power
pipe.kW_best  = zeros(1,ph.n); pipe.kW_worst = zeros(1,ph.n);
for p = 1:ph.n
    trunk = ternary(p>=2, pipe.trunk_m, 0);
    pipe.kW_best(p) = (trunk+pipe.spine_best(p))*pipe.q_ground/1e3 + pipe.branch_best(p)*pipe.q_elev/1e3;
    pipe.kW_worst(p) = (trunk+pipe.spine_worst(p))*pipe.q_ground/1e3 + pipe.branch_worst(p)*pipe.q_elev/1e3;
end
pipe.kW = pipe.kW_worst;  % design uses worst case

fprintf('\n== PIPELINE HEATING (v4.5: variable-length) ==\n');
fprintf('  Trunk: %.1f km @ %.1f W/m (ground) | Spine: %.1f W/m (ground) | Branch: %.1f W/m (elevated)\n',...
    pipe.trunk_m/1e3, pipe.q_ground, pipe.q_ground, pipe.q_elev);
fprintf('  Pressure: %d bar working / %d bar burst (Ti %.1fmm wall)\n\n',...
    pipe.pressure_working, pipe.pressure_burst, pipe.wall_t);

fprintf('  %5s | -------- BEST CASE -------- | ------- WORST CASE ------- |\n','');
fprintf('  %-5s | %6s %6s %6s %7s | %6s %6s %6s %7s | %7s\n',...
    'Phase','Spine','Branch','Total','kW','Spine','Branch','Total','kW','Delta');
fprintf('  %s\n',repmat('-',1,82));
for p = 1:ph.n
    tb = ternary(p>=2, pipe.trunk_m, 0);
    tot_b = tb+pipe.spine_best(p)+pipe.branch_best(p);
    tot_w = tb+pipe.spine_worst(p)+pipe.branch_worst(p);
    fprintf('  %-5s | %5.0fm %5.0fm %5.0fm %6.1fkW | %5.0fm %5.0fm %5.0fm %6.1fkW | %+6.1fkW\n',...
        ph.lab{p}, pipe.spine_best(p),pipe.branch_best(p),tot_b,pipe.kW_best(p),...
        pipe.spine_worst(p),pipe.branch_worst(p),tot_w,pipe.kW_worst(p),...
        pipe.kW_worst(p)-pipe.kW_best(p));
end
fprintf('\n  Design uses WORST CASE (conservative).\n');
fsp_threshold = 40;
for p = 1:ph.n
    delta = pipe.kW_worst(p) - pipe.kW_best(p);
    if delta > fsp_threshold
        fprintf('  !! %s: worst-case delta %.0f kW > %d kW -> consider additional FSP\n',...
            ph.lab{p}, delta, fsp_threshold);
    end
end

%% NORMAL POWER BUDGET
fprintf('\n== NORMAL POWER BUDGET ==\n');
V=1000;
ph.wyr=ph.mi.*mi.water_yr; ph.whr=ph.wyr/8760;

% PSR — v4.4: uses mi.pwr_tether (includes DC-DC losses + battery charge)
ph.p_fleet = ph.mi*mi.pwr_tether/1000;  % v4.4: was mi.pwr_op. Now uses tether draw.
ph.p_nodes = ph.nd*node.overhead/1000;
ph.p_pipe  = pipe.kW;  % v4.5: variable per phase (worst case)
ph.p_pump  = [0,pump.trunk_kW,pump.trunk_kW,pump.trunk_kW,pump.trunk_kW];
ph.p_psr   = ph.p_fleet+ph.p_nodes+ph.p_pipe+ph.p_pump;

% ISRU
kw_per_kghr=5.5; ph.p_elec=ph.whr*kw_per_kghr;
ph.h2hr=ph.whr*(2/18); ph.o2hr=ph.whr*(16/18);
ph.p_cryo=ph.h2hr*12+ph.o2hr*0.4; ph.p_isru=ph.p_elec+ph.p_cryo;
ph.nPEM=ceil(ph.p_elec/50);

% Habitat
ph.p_eclss=[0 6 6 6 6]; ph.p_hab_sys=[2 6.5 6.5 6.5 6.5]; ph.p_comms=1.5*ones(1,ph.n);
ph.p_hab=ph.p_eclss+ph.p_hab_sys+ph.p_comms;

% Surface robots
ph.nMS=[4 4 4 6 6]; ph.nARM=[2 4 6 8 8]; ph.nSV=[1 1 2 2 2]; ph.nSEN=[2 2 3 4 4];
ph.p_robots=ph.nMS*0.4+ph.nARM*1.0+(ph.nSV+ph.nSEN)*0.2;

% Benef + Dock + CAP
ph.p_benef=[0 0 0 15 20]; ph.p_dock=[1 2 3 4 5];
ph.p_cap=[0 0 0 cap.stby_kW cap.stby_kW];
ph.p_base=ph.p_hab+ph.p_robots+ph.p_benef+ph.p_dock+ph.p_cap;

% Totals
ph.p_sub=ph.p_psr+ph.p_isru+ph.p_base;
ph.p_cont=ph.p_sub*0.20; ph.p_tot=ph.p_sub+ph.p_cont;
ph.solar_cap=ph.p_tot/solar.illum;
ph.panel_m2=ph.solar_cap/(solar.irr*solar.eff*solar.eol);

fprintf('\n  %-5s | %4s %4s | %7s %7s %7s | %7s | %7s %7s | %7s | %7s\n',...
    'Phase','MI','Nod','PSR','Pipe','ISRU','Base','Sub','Cont','TOTAL','Panels');
fprintf('  %s\n',repmat('-',1,95));
for i=1:ph.n
    fprintf('  %-5s | %4d %4d | %6.1f  %6.1f  %6.1f  | %6.1f  | %6.0f   %5.0f  | %5.0f kW | %5.0f m2\n',...
        ph.lab{i},ph.mi(i),ph.nd(i),...
        ph.p_fleet(i)+ph.p_nodes(i), ph.p_pipe(i)+ph.p_pump(i), ph.p_isru(i),...
        ph.p_base(i), ph.p_sub(i), ph.p_cont(i), ph.p_tot(i), ph.panel_m2(i));
end

% v4.4: Node-level power breakdown
fprintf('\n  NODE-LEVEL (v4.4):\n');
node_total_W = node.overhead + node.units*mi.pwr_tether;
fprintf('    Per MOLE-I at tether: %dW (load %d + DC-DC %.0f + batt %d)\n',...
    round(mi.pwr_tether), mi.pwr_op, mi.dcdc.loss_total, mi.batt_charge);
fprintf('    Substation own: %.1fW (htr %.1f + drums %d + pump %d + riser %d + misc %d)\n',...
    node.overhead, node.web, node.drums, node.pump, node.riser,...
    node.funnels+node.comms+node.controller+node.solenoids);
fprintf('    Node total: %d MI x %dW + %.0fW sub = %.0fW (%.2fA at 1000V)\n',...
    node.units, round(mi.pwr_tether), node.overhead, node_total_W, node_total_W/1000);
fprintf('    P7+ PSR fleet+nodes: %.1f kW | + pipe %.1f + pump %.1f = %.1f kW\n',...
    ph.p_fleet(end)+ph.p_nodes(end), ph.p_pipe(end), ph.p_pump(end), ph.p_psr(end));


%% ECLIPSE POWER (CORRECTED)
fprintf('\n== ECLIPSE POWER (CORRECTED) ==\n');
fprintf('  During 1-3 day shadow (~2x/lunar yr):\n');
fprintf('  MOLE-I -> keep-alive (%d W, NOT %d W tether draw)\n', mi.pwr_ka, round(mi.pwr_tether));
fprintf('  Substations -> ON (distribute keep-alive via tethers)\n');
fprintf('  Pipeline -> ON (freeze = replacement)\n');
fprintf('  ISRU -> OFF | Beneficiation -> OFF\n\n');

ecl.mi = ph.mi*mi.pwr_ka/1000;
ecl.nd = ph.nd*node.overhead/1000;
ecl.pipe = pipe.kW;  % v4.5: same as normal (pipe never shuts off)
ecl.hab = ph.p_hab;
ecl.rob = (ph.nARM+ph.nMS)*0.05;
ecl.cap = ph.p_cap;
ecl.tot = ecl.mi+ecl.nd+ecl.pipe+ecl.hab+ecl.rob+ecl.cap;

eclipse_hr=72; batt_margin=1.20; batt_Whkg=250;

fprintf('  %-5s | %6s %6s %6s %6s %6s | %7s | %5s | %12s\n',...
    'Phase','MI ka','Nodes','Pipe','Hab','Other','TOTAL','FSP','Battery');
fprintf('  %s\n',repmat('-',1,80));

ecl.nfsp=zeros(1,ph.n); ecl.bkWh=zeros(1,ph.n); ecl.bt=zeros(1,ph.n);
for i=1:ph.n
    nf=min(ceil(ecl.tot(i)/fsp.pwr_kW),2);
    short=max(0,ecl.tot(i)-nf*fsp.pwr_kW);
    bkWh=short*eclipse_hr*batt_margin; bt=bkWh*1000/batt_Whkg/1000;  % kWh->Wh / Wh_per_kg -> kg -> tonnes
    ecl.nfsp(i)=nf; ecl.bkWh(i)=bkWh; ecl.bt(i)=bt;
    if short>0, bs=sprintf('%.0f kWh (%.1ft)',bkWh,bt); else, bs='none'; end
    fprintf('  %-5s | %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  | %6.1f kW | %dx%dkW | %s\n',...
        ph.lab{i},ecl.mi(i),ecl.nd(i),ecl.pipe(i),ecl.hab(i),ecl.rob(i)+ecl.cap(i),...
        ecl.tot(i),nf,fsp.pwr_kW,bs);
end

% Solar-only comparison
so_bkWh=ecl.tot(end)*eclipse_hr*batt_margin; so_bt=so_bkWh*1000/batt_Whkg/1000;
fprintf('\n  COMPARISON (P7+ worst case):\n');
fprintf('    0 FSP (solar-only): %.0f kWh battery (%.1f t)\n',so_bkWh,so_bt);
fprintf('    2x FSP (hybrid):    %.0f kWh battery (%.1f t) - saves %.1f t\n',...
    ecl.bkWh(end),ecl.bt(end),so_bt-ecl.bt(end));
fprintf('    FSP mass: 2x%.0f kg = %.1f t\n',fsp.mass_kg,2*fsp.mass_kg/1e3);

% Pre-compute battery model variables (needed by figures)
ph.surplus = ph.solar_cap - ph.p_tot;
isru_ride_hr = 2;
ph.t2_kWh = ph.p_isru * isru_ride_hr;
ph.t2_t = ph.t2_kWh * 1000 / batt_Whkg / 1000;
ph.batt_total_kWh = ecl.bkWh + ph.t2_kWh;
ph.batt_total_t = ph.batt_total_kWh * 1000 / batt_Whkg / 1000;



%% ISRU DETAIL
fprintf('\n== ISRU PLANT ==\n');
for i=1:ph.n
    lh2=ph.wyr(i)*(2/18)*0.722; lox=ph.wyr(i)*(16/18)*0.722;
    fprintf('  %s: %.1f kg/hr | %d PEM | %.0f+%.0f = %.0f kW | LH2 %.1ft LOX %.1ft\n',...
        ph.lab{i},ph.whr(i),ph.nPEM(i),ph.p_elec(i),ph.p_cryo(i),ph.p_isru(i),lh2/1e3,lox/1e3);
end

%% CAP DETAIL
fprintf('\n== CAP (PHASE 2+) ==\n');
fprintf('  %d kg dry | %d kg loaded | %.0f kW peak | %.0f kW stby\n',...
    cap.mass_loaded-560,cap.mass_loaded,cap.peak_kW,cap.stby_kW);
fprintf('  Transit: %d min @ 3m/s | Floor EVA: %d hr (40K suit limit)\n',45,2);
fprintf('  Cable: %.0f N (%.0f N at 5x SF)\n',...
    cap.mass_loaded*g_moon*0.5, cap.mass_loaded*g_moon*0.5*5);
fprintf('  Phase 1: reserve anchor points only\n');

%% TRUNK CABLE
fprintf('\n== TRUNK CABLE ==\n');
cu_rho=0.24e-8; cu_den=8960; tm=crater.traverse_km*1000;
for i=1:ph.n
    I=ph.p_psr(i)*1000/V;
    if I>0, R=0.05*V/I; A=cu_rho*tm*2/R*1e6; m=A*1e-6*tm*2*cu_den;
    else, A=10; m=1500; end
    fprintf('  %s: %.0f kW -> %3.0f A -> %4.0f mm2 -> %5.1f t\n',ph.lab{i},ph.p_psr(i),I,A,m/1e3);
end

%% MATERIAL OUTPUT
fprintf('\n== MATERIAL OUTPUT ==\n');
for i=1:ph.n
    kc=ph.nS(i)*skip.kreep_yr/1e3*0.04; pg=max(0,ph.nP(i)*1.5*(i>1));
    fprintf('  %s: %.1ft PGM + %.1ft KREEP = %.1ft/yr\n',ph.lab{i},pg,kc,pg+kc);
end

%% FAILURE
fprintf('\n== FAILURE ANALYSIS ==\n');
d6=ph.dT(4); mn=ceil(d6/mi.prop_yield); sp=ceil(ph.mi(end)*0.12);
fprintf('  P6: %.0ft -> min %d MI | fleet %d -> %d buffer\n',d6/1e3,mn,ph.mi(4),ph.mi(4)-mn);
fprintf('  Stockpile: %.0f t (%.1f months P6 reserve)\n',stk/1e3,stk/d6*12);
fprintf('  Cold spares: %d (12%%)\n',sp);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURES (8 total)
% ═══════════════════════════════════════════════════════════════════
x=1:ph.n;
cb=[0.18 0.55 0.82]; cr=[0.85 0.32 0.24]; ca=[0.92 0.65 0.15];
cg=[0.30 0.65 0.30]; cy=[0.60 0.60 0.60]; cd=[0.18 0.42 0.72]; cp=[0.55 0.27 0.68];

% Fig 1: Propellant Balance
figure('Name','Fig 1 - Propellant Balance','Position',[50 50 920 520]);
b=bar(x,[ph.isru;ph.dT]'/1e3,'grouped'); b(1).FaceColor=cb; b(2).FaceColor=cr;
hold on; plot(x,ph.margin/1e3,'k--o','LineWidth',2,'MarkerFaceColor',cg,'MarkerSize',8);
for i=1:ph.n, text(i,ph.isru(i)/1e3+25,sprintf('%d MI\n%d nodes',ph.mi(i),ph.nd(i)),...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold'); end
ylabel('Propellant (t/yr)'); xticks(x); xticklabels(ph.lab);
legend('ISRU Supply','Demand','Margin','Location','northwest');
title('Propellant Balance (v4)'); grid on; set(gca,'FontSize',11);

% Fig 2: Demand Composition
figure('Name','Fig 2 - Demand Composition','Position',[50 620 920 520]);
b2=bar(x,[ph.dP;ph.dS;ph.dD;ph.dL]'/1e3,'stacked');
b2(1).FaceColor=cd; b2(2).FaceColor=cr; b2(3).FaceColor=ca; b2(4).FaceColor=cg;
hold on; plot(x,ph.isru/1e3,'k-s','LineWidth',2.5,'MarkerFaceColor','k','MarkerSize',8);
ylabel('Propellant (t/yr)'); xticks(x); xticklabels(ph.lab);
legend('PROBE','SKIP','DART','Life Support','ISRU Supply','Location','northwest');
title('Demand Composition (v4)'); grid on; set(gca,'FontSize',11);

% Fig 3: Normal Power by Zone
figure('Name','Fig 3 - Normal Power Budget','Position',[1000 50 950 550]);
pz=[ph.p_fleet+ph.p_nodes; ph.p_pipe+ph.p_pump; ph.p_isru; ph.p_base; ph.p_cont]';
b3=bar(x,pz,'stacked');
b3(1).FaceColor=cr; b3(2).FaceColor=cb; b3(3).FaceColor=ca; b3(4).FaceColor=cg; b3(5).FaceColor=cy;
ylabel('Power (kW)'); xticks(x); xticklabels(ph.lab);
legend('PSR Fleet+Nodes','Pipeline+Pumps','ISRU','Base+CAP','Contingency 20%','Location','northwest');
title('Normal Operations Power (v4)'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.p_tot(i)+20,sprintf('%.0f kW\n%.0f m^2',ph.p_tot(i),ph.panel_m2(i)),...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold'); end

% Fig 4: ECLIPSE POWER (CORRECTED) - stacked zones + FSP capacity line
figure('Name','Fig 4 - Eclipse Power (CORRECTED)','Position',[1000 620 950 550]);
ez=[ecl.mi; ecl.nd; ecl.pipe; ecl.hab; ecl.rob+ecl.cap]';
b4=bar(x,ez,'stacked');
b4(1).FaceColor=cr; b4(2).FaceColor=cp; b4(3).FaceColor=cb; b4(4).FaceColor=cg; b4(5).FaceColor=cy;
hold on;
for i=1:ph.n
    fc=ecl.nfsp(i)*fsp.pwr_kW;
    plot([i-0.4,i+0.4],[fc,fc],'r-','LineWidth',3);
    if ecl.tot(i)>fc
        text(i,ecl.tot(i)+3,sprintf('+%.0f kWh\n(%.1ft batt)',ecl.bkWh(i),ecl.bt(i)),...
            'HorizontalAlignment','center','FontSize',7,'Color',ca);
    else
        text(i,ecl.tot(i)+2,'FSP OK','HorizontalAlignment','center',...
            'FontSize',9,'Color',cg,'FontWeight','bold');
    end
end
ylabel('Eclipse Load (kW)'); xticks(x); xticklabels(ph.lab);
legend('MOLE-I keep-alive','Substations','Pipeline 59.5kW','Habitat ECLSS','Robots+CAP',...
       'FSP capacity','Location','northwest');
title('Eclipse Survival - Corrected (MOLE-I keep-alive mode)'); grid on; set(gca,'FontSize',11);

% Fig 5: Solar + Eclipse Battery
figure('Name','Fig 5 - Solar & Eclipse Battery','Position',[50 1200 900 450]);
subplot(1,2,1);
bar(x,ph.panel_m2,'FaceColor',ca); ylabel('Panel Area (m^2)');
xticks(x); xticklabels(ph.lab);
title(sprintf('Solar (29%% GaAs, 85%% sun, %d%% EOL)',solar.eol*100));
grid on; set(gca,'FontSize',11); yline(2500,'b--','ISS ~2500m^2','FontSize',9);
for i=1:ph.n, text(i,ph.panel_m2(i)+80,sprintf('%.0f',ph.panel_m2(i)),...
    'HorizontalAlignment','center','FontSize',9); end

subplot(1,2,2);
bar(x,[ones(1,ph.n)*so_bt; ecl.bt]','grouped');
ylabel('Battery (tonnes)'); xticks(x); xticklabels(ph.lab);
legend(sprintf('0 FSP: %.1ft',so_bt),sprintf('2x FSP: %.1ft max',max(ecl.bt)),'Location','northwest');
title('Eclipse Battery: 0 FSP vs 2x FSP'); grid on; set(gca,'FontSize',11);

% Fig 6: Stockpile
figure('Name','Fig 6 - Stockpile','Position',[50 700 920 480]);
yrs=[]; st2=[]; cs=0; ys=4;
for i=1:ph.n
    for y=1:ph.dur(i), cs=cs+ph.margin(i); yrs=[yrs,ys+y-1]; st2=[st2,cs/1e3]; end
    ys=ys+ph.dur(i);
end
area(yrs,st2,'FaceColor',[0.75 0.88 0.95],'EdgeColor',cb,'LineWidth',2);
hold on; yline(410,'r--','LineWidth',1.5);
text(yrs(end)-3,440,'12-month P6 reserve','Color','r','FontSize',10);
ps=cumsum([4 ph.dur]);
for i=1:ph.n, xline(ps(i),'k:'); text(ps(i)+0.3,max(st2)*0.92,ph.lab{i},'FontSize',11,'FontWeight','bold'); end
xlabel('Year'); ylabel('Stockpile (t)'); title('Stockpile (v4)'); grid on; set(gca,'FontSize',11);

% Fig 7: Fleet Scaling
figure('Name','Fig 7 - Fleet Scaling','Position',[1000 700 800 450]);
yyaxis left; bar(x,ph.mi,'FaceColor',cb,'BarWidth',0.6); ylabel('MOLE-I'); ylim([0 200]);
yyaxis right; plot(x,ph.nd,'r-o','LineWidth',2.5,'MarkerFaceColor',cr,'MarkerSize',10); ylabel('Nodes');
xticks(x); xticklabels(ph.lab); title('Fleet Scaling (v4.5)'); grid on; set(gca,'FontSize',11);

% Fig 8: MOLE-I Power Pie (v4.4: VEX stby 0W, VEX htr 1000V direct)
figure('Name','Fig 8 - MOLE-I Power','Position',[50 1250 750 500]);
pv=[mi.pwr.drive,mi.pwr.drill,mi.pwr.minivex,mi.pwr.web,mi.pwr.comms,...
    mi.pwr.gbx_htr,mi.pwr.drill_htr,mi.pwr.recept];
pl={sprintf('Drive %dW',mi.pwr.drive),sprintf('Drill %dW',mi.pwr.drill),...
    sprintf('mini-VEX %dW',mi.pwr.minivex),sprintf('WEB %dW',mi.pwr.web),...
    sprintf('Comms %dW',mi.pwr.comms),sprintf('Gearbox 6x5=%dW',mi.pwr.gbx_htr),...
    sprintf('Drill htr %dW',mi.pwr.drill_htr),sprintf('Recept %dW',mi.pwr.recept)};
if mi.pwr.vex_stby > 0  % include only if non-zero
    pv=[pv, mi.pwr.vex_stby];
    pl=[pl, {sprintf('VEX stby %dW',mi.pwr.vex_stby)}];
end
pie(pv); legend(pl,'Location','eastoutside','FontSize',9);
title(sprintf('MOLE-I: %dW op / %dW tether / %dW ka (v4.4)',mi.pwr_op,round(mi.pwr_tether),mi.pwr_ka));

% Fig 9: Battery & Power Tiering
figure('Name','Fig 9 - Battery & Power Tiering','Position',[850 1250 900 500]);
subplot(1,2,1);
batt_data = [ecl.bkWh; ph.t2_kWh]';
b9=bar(x, batt_data/1000, 'stacked');
b9(1).FaceColor=cr; b9(2).FaceColor=ca;
ylabel('Battery (MWh)'); xticks(x); xticklabels(ph.lab);
legend('Eclipse supplement (72hr)','ISRU ride-through (2hr)','Location','northwest');
title('Total Battery Inventory by Phase'); grid on; set(gca,'FontSize',11);
for i=1:ph.n
    bt=ph.batt_total_kWh(i)*1000/batt_Whkg/1000;
    text(i,(ecl.bkWh(i)+ph.t2_kWh(i))/1000+0.05,sprintf('%.1f t',bt),...
        'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
end

subplot(1,2,2);
bar(x, [ph.p_tot; ph.surplus]', 'stacked');
ylabel('Power (kW)'); xticks(x); xticklabels(ph.lab);
legend('Operational load','Surplus to battery (17.6%)','Location','northwest');
title('Solar Output: Load + Charging Surplus'); grid on; set(gca,'FontSize',11);
for i=1:ph.n
    text(i,ph.solar_cap(i)+15,sprintf('%.0f kW\nsolar cap',ph.solar_cap(i)),...
        'HorizontalAlignment','center','FontSize',8);
end



%% SUMMARY


%% ═══════════════════════════════════════════════════════════════════
%  BATTERY SIZING & CHARGING MODEL
%  Tiered power management for shadow events:
%    Tier 1: Critical loads always on (PSR ka + substations + pipe + hab)
%    Tier 2: ISRU ride-through for short shadows (<=2 hr)
%    Tier 3: ISRU graceful shutdown for long shadows (>2 hr)
% ═══════════════════════════════════════════════════════════════════
fprintf('\n== BATTERY & CHARGING MODEL ==\n');

% Surplus during lit periods
ph.surplus = ph.solar_cap - ph.p_tot;
fprintf('  SURPLUS DURING ILLUMINATION (17.6%% of load):\n');
for i=1:ph.n
    fprintf('    %s: solar %.0f kW - load %.0f kW = %.0f kW surplus -> battery\n',...
        ph.lab{i}, ph.solar_cap(i), ph.p_tot(i), ph.surplus(i));
end

% Tier 1: Critical (same as eclipse loads, covered by FSP + eclipse battery)
fprintf('\n  TIER 1 — CRITICAL (any shadow, any duration):\n');
fprintf('    PSR keep-alive + substations + pipeline + habitat\n');
fprintf('    Covered by 2x FSP (%d kW) + eclipse battery bank\n', 2*fsp.pwr_kW);
for i=1:ph.n
    fprintf('    %s: %.1f kW critical | FSP %d kW | batt supplement: %.0f kWh (%.1ft)\n',...
        ph.lab{i}, ecl.tot(i), ecl.nfsp(i)*fsp.pwr_kW, ecl.bkWh(i), ecl.bt(i));
end

% Tier 2: ISRU ride-through (2 hr max)
isru_ride_hr = 2;
fprintf('\n  TIER 2 — ISRU RIDE-THROUGH (shadows <= %d hr):\n', isru_ride_hr);
ph.t2_kWh = ph.p_isru * isru_ride_hr;
ph.t2_t = ph.t2_kWh * 1000 / batt_Whkg / 1000;
for i=1:ph.n
    fprintf('    %s: %.0f kW ISRU x %d hr = %.0f kWh (%.1f t)\n',...
        ph.lab{i}, ph.p_isru(i), isru_ride_hr, ph.t2_kWh(i), ph.t2_t(i));
end

% Tier 3: ISRU shutdown (implicit - no battery needed)
fprintf('\n  TIER 3 — ISRU SHUTDOWN (shadows > %d hr):\n', isru_ride_hr);
fprintf('    ISRU gracefully shuts down. PEM membranes tolerate cycling.\n');
fprintf('    Cryo cold mass maintains temperature for hours unpowered.\n');
fprintf('    Production loss from occasional 4-8 hr shutdowns: ~1-2%% annual yield.\n');

% Total battery inventory
fprintf('\n  TOTAL BATTERY INVENTORY:\n');
fprintf('  %-5s | %10s | %10s | %10s | %7s\n', 'Phase','Eclipse','ISRU ride','TOTAL','Mass');
fprintf('  %s\n', repmat('-',1,55));
ph.batt_total_kWh = ecl.bkWh + ph.t2_kWh;
ph.batt_total_t = ph.batt_total_kWh * 1000 / batt_Whkg / 1000;
for i=1:ph.n
    fprintf('  %-5s | %8.0f kWh | %8.0f kWh | %8.0f kWh | %5.1f t\n',...
        ph.lab{i}, ecl.bkWh(i), ph.t2_kWh(i), ph.batt_total_kWh(i), ph.batt_total_t(i));
end

% Recharge analysis
fprintf('\n  RECHARGE ANALYSIS:\n');
for i=1:ph.n
    if ph.batt_total_kWh(i) > 0
        charge_hr = ph.batt_total_kWh(i) / ph.surplus(i);
        fprintf('    %s: %.0f kWh recharged in %.1f hr (%.1f days) from %.0f kW surplus\n',...
            ph.lab{i}, ph.batt_total_kWh(i), charge_hr, charge_hr/24, ph.surplus(i));
    else
        fprintf('    %s: no battery needed (FSP covers all critical loads)\n', ph.lab{i});
    end
end
fprintf('    Eclipse interval: ~180 days -> recharge margin: >100x at all phases\n');

fprintf('\n================================================================\n');
fprintf('  v4.5 SUMMARY (variable pipeline + full power chain)\n');
fprintf('================================================================\n');
fprintf('  MOLE-I: 6-wheel, %dkg, %dW op / %dW tether / %dW ka\n',...
    mi.mass_dry,mi.pwr_op,round(mi.pwr_tether),mi.pwr_ka);
fprintf('    v4.4: tether draw includes DC-DC losses (%.0fW) + batt charge (%dW)\n',...
    mi.dcdc.loss_total,mi.batt_charge);
fprintf('    WEB heater: %dW | VEX stby: %dW (thermal strap)\n',mi.pwr.web,mi.pwr.vex_stby);
fprintf('    VEX heater: 1000V direct (SiC MOSFET, 833ohm nichrome)\n');
fprintf('    108 conductors through WEB wall (all Manganin 100mm transition)\n');
fprintf('    Transit battery: %.0f Wh / %.1f kg\n',mi.batt_Wh,mi.batt_kg);
fprintf('  SUBSTATION: %.1fW own (was 130W). WEB htr %.1fW (was 80W). %dx LWRHU.\n',...
    node.overhead,node.web,node.lwrhu);
fprintf('    Heater %.1f + drums %.0f + pump %.0f + riser %.0f + funnels %.0f + comms %.0f + ctrl %.0f + sol %.0f\n',...
    node.web,node.drums,node.pump,node.riser,node.funnels,node.comms,node.controller,node.solenoids);
fprintf('    3x LWRHU: 33hr survival to 253K (was 1x/22hr). Mass: %.0fg/node.\n',...
    node.lwrhu_mass*1000);
fprintf('  Power: solar + %dx%dkW FSP | CAP: %.0fkW peak (Phase 2+)\n',...
    max(ecl.nfsp),fsp.pwr_kW,cap.peak_kW);
fprintf('  1000 VDC end-to-end: trunk->branch->substation(passive)->tether->MOLE-I\n');
fprintf('  PIPELINE: %.1f W/m ground | %.1f W/m elevated | %d bar / %d bar burst\n',...
    pipe.q_ground, pipe.q_elev, pipe.pressure_working, pipe.pressure_burst);
fprintf('  P7+ pipe heat: %.1f kW best / %.1f kW worst (using worst)\n\n',...
    pipe.kW_best(end), pipe.kW_worst(end));

ap=true;
for i=1:ph.n
    s='PASS'; if ph.margin(i)<0, s='FAIL'; ap=false; end
    fprintf('  %s: %3d MI (%2d nd) | %5.0ft - %5.0ft = %+5.0ft [%s]\n',...
        ph.lab{i},ph.mi(i),ph.nd(i),ph.isru(i)/1e3,ph.dT(i)/1e3,ph.margin(i)/1e3,s);
end

fprintf('\n  NORMAL POWER:                    ECLIPSE POWER:\n');
for i=1:ph.n
    fprintf('  %s: %5.0f kW | %5.0f m2       %5.1f kW | %dx FSP + %.0f kWh batt (%.1ft)\n',...
        ph.lab{i},ph.p_tot(i),ph.panel_m2(i),ecl.tot(i),ecl.nfsp(i),ecl.bkWh(i),ecl.bt(i));
end

fprintf('\n  BATTERY INVENTORY:        RECHARGE:\n');
for i=1:ph.n
    if ph.batt_total_kWh(i)>0
        chr=ph.batt_total_kWh(i)/ph.surplus(i);
        fprintf('  %s: %6.0f kWh (%4.1ft)     %.1f hr from %.0f kW surplus\n',...
            ph.lab{i},ph.batt_total_kWh(i),ph.batt_total_t(i),chr,ph.surplus(i));
    else
        fprintf('  %s:    FSP covers all       no battery needed\n',ph.lab{i});
    end
end
fprintf('\n  Stockpile: %.0ft | Spares: %d | Infra: ~115t\n',stk/1e3,sp);
if ap, fprintf('\n  ** ALL PHASES BALANCED [PASS] **\n'); end
fprintf('================================================================\n');
fprintf('  9 figures generated.\n');
fprintf('================================================================\n');

function r=ternary(c,t,f), if c, r=t; else, r=f; end, end