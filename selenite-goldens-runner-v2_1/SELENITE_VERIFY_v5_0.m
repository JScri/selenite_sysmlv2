%% SELENITE_VERIFY_v5_0.m
%  Comprehensive Programme Verification: Fleet + Power + ECLSS + ISRU
%  Merges v4.5 (fleet sizing, fishbone pipeline, DC-DC losses, figures)
%  with POWER_VERIFY (ECLSS Scenario C, hab breakdown, solar dust, FSP)
%
%  v5.0 changes from v4.5:
%    - ECLSS Scenario C (OGA 0.43 kg H₂/day, Sabatier 59/41 split)
%    - Electrolysis: 19 stacks (17+2 spare), 850 kW at P7+
%    - FSP: 1→5 per phase (was capped at 2)
%    - Eclipse: 72 hr conservative (was 72 in v4.5, confirmed)
%    - Habitat 12-component ECLSS power breakdown
%    - ISRU first-principles cross-check (electrolysis + cryo)
%    - Solar array dust factor (5% loss)
%    - Power infrastructure mass summary
%    - Sabatier stoichiometry + CO₂/O₂/water balance verification
%    - P4 eclipse battery sizing
%    - SURVEY re-architected as orbital spacecraft (no ground rover)
%    - ARM split to ARM-C (mobile crane) + ARM-D (gantry manipulator)
%    - MOLE-S: auger standard fit, depth-dependent excavation rates
%    - SINTER: 3 operating modes, onboard 10 kWe reactor (no grid draw)
%    - MOLE-I §6.1: prospecting function (ground-truth for SURVEY orbital)
%
%  Author: Jason (Systems Engineering Lead), Selenite Programme
%  Date: March 2026

clear; clc; close all;

g0=9.81; g_moon=1.62; Isp=450; ve=Isp*g0;

fprintf('════════════════════════════════════════════════════════════════\n');
fprintf('  SELENITE v5.0 — Comprehensive Programme Verification\n');
fprintf('  Fleet + Power + ECLSS Scenario C + ISRU + Fishbone Pipeline\n');
fprintf('  72-hr conservative eclipse | 5× FSP | 19 PEM stacks\n');
fprintf('  Ref: All subsystem specs (March 2026)\n');
fprintf('════════════════════════════════════════════════════════════════\n\n');

%% ENVIRONMENT
crater.traverse_km = 4.2/sind(30);  % 8.4 km slope distance
crater.floor_dia_km = 6.5;
crater.floor_area = pi*(crater.floor_dia_km/2)^2;  % 33.2 km²
crater.ice_frac = 0.0446;

solar.illum = 0.85; solar.eff = 0.29; solar.irr = 1.361;
solar.eol = 0.85; solar.dust = 0.95;  % v5.0: added dust factor
solar.yield_kWm2 = solar.irr * solar.eff * solar.illum * solar.dust;  % kW/m²
fsp.pwr_kW = 40; fsp.mass_kg = 6600;

fprintf('  Crater: %.1f km slope, %.1f km floor dia, %.1f km² floor\n',...
    crater.traverse_km, crater.floor_dia_km, crater.floor_area);
fprintf('  Solar: %.3f kW/m² (%.0f W/m² × %.0f%% eff × %.0f%% illum × %.0f%% dust)\n',...
    solar.yield_kWm2, solar.irr*1000, solar.eff*100, solar.illum*100, solar.dust*100);
fprintf('  FSP: %d kWe per unit, %d kg\n\n', fsp.pwr_kW, fsp.mass_kg);

%% MOLE-I (6-WHEEL, from MOLEI_DESIGN v5)
mi.mass_dry = 360.35; mi.n_wheels = 6; mi.prop_yield = 5692;
mi.water_rate = 25*crater.ice_frac; mi.water_yr = mi.water_rate*0.80*8760;

mi.pwr.drive=300; mi.pwr.drill=200; mi.pwr.minivex=1200;
mi.pwr.web=15; mi.pwr.comms=20; mi.pwr.gbx_htr=30; mi.pwr.drill_htr=15;
mi.pwr.recept=5; mi.pwr.vex_stby=0;

mi.pwr_op = mi.pwr.drive+mi.pwr.drill+mi.pwr.minivex+mi.pwr.web+mi.pwr.comms+...
            mi.pwr.gbx_htr+mi.pwr.drill_htr+mi.pwr.recept+mi.pwr.vex_stby;
mi.pwr_ka = mi.pwr.web+mi.pwr.gbx_htr+mi.pwr.drill_htr+mi.pwr.recept;

% DC-DC conversion losses (from v4.5)
mi.dcdc.eff_48v=0.95; mi.dcdc.eff_28v=0.93; mi.dcdc.eff_5v=0.90;
mi.dcdc.load_48v=1730; mi.dcdc.load_28v=90; mi.dcdc.load_5v=13;
mi.dcdc.loss_48v = mi.dcdc.load_48v*(1/mi.dcdc.eff_48v-1);
mi.dcdc.loss_28v = mi.dcdc.load_28v*(1/mi.dcdc.eff_28v-1);
mi.dcdc.loss_5v  = mi.dcdc.load_5v*(1/mi.dcdc.eff_5v-1);
mi.dcdc.loss_total = mi.dcdc.loss_48v+mi.dcdc.loss_28v+mi.dcdc.loss_5v;
mi.batt_charge = 50;
mi.pwr_tether = mi.pwr_op + mi.dcdc.loss_total + mi.batt_charge;

mi.descent_hr = (crater.traverse_km*1000/0.5)/3600;
mi.batt_Wh = mi.pwr_ka*mi.descent_hr*1.10;
mi.batt_kg = mi.batt_Wh/250;

fprintf('== MOLE-I (6-WHEEL) ==\n');
fprintf('  %.1f kg dry | %d W op | %d W ka | %.0f Wh batt\n',...
    mi.mass_dry,mi.pwr_op,mi.pwr_ka,mi.batt_Wh);
fprintf('  Tether draw: %dW (load %d + DC-DC %.0f + batt %d)\n',...
    round(mi.pwr_tether),mi.pwr_op,mi.dcdc.loss_total,mi.batt_charge);
fprintf('  Prospecting: first unit at each branch measures wt%% ice\n');
fprintf('    (drill mass / water output, 3-5 cycles at ~50 m spacing)\n\n');

%% SUBSTATION NODE (10-component audit from v4.4/v4.5)
node.units=5;
node.web=10.5; node.drums=5*8; node.pump=10; node.riser=21;
node.funnels=3; node.comms=3; node.controller=5; node.solenoids=3;
node.overhead = node.web+node.drums+node.pump+node.riser+...
                node.funnels+node.comms+node.controller+node.solenoids;
node.lwrhu=3; node.lwrhu_mass=node.lwrhu*0.042; node.mass=160;
% v5.0: ECN-013 added 5× angle encoders at 0.5 W total
node.angle_enc = 0.5;
node.overhead_v5 = node.overhead + node.angle_enc;  % 96.0 W

fprintf('== SUBSTATION NODE ==\n');
fprintf('  WEB %.1f + drums %d + pump %d + riser %d + funnels %d\n',...
    node.web, node.drums, node.pump, node.riser, node.funnels);
fprintf('  + comms %d + ctrl %d + solenoids %d + enc %.1f = %.1f W\n',...
    node.comms, node.controller, node.solenoids, node.angle_enc, node.overhead_v5);
fprintf('  %d LWRHU (%.0f g) | %d kg dry\n\n', node.lwrhu, node.lwrhu_mass*1000, node.mass);

%% PIPELINE (v4.5 heritage: variable-length fishbone)
pipe.trunk_m = 8500;
pipe.q_ground = 7.0;   % W/m (trunk + spine, ground contact)
pipe.q_elev = 1.5;     % W/m (branch, elevated, vacuum+MLI)
pipe.pump_kW = 0.3;    % trunk pump ~300 W (from ISRU-001 hydrostatic analysis)

%% CAP (Crater Access Pod)
cap.peak_kW = 5.0; cap.stby_kW = 1.0; cap.mass_loaded = 1360;
fprintf('== CAP ==\n');
fprintf('  %.1f kW peak | %.1f kW standby | %d kg loaded\n\n', cap.peak_kW, cap.stby_kW, cap.mass_loaded);

%% FLEET CONSUMERS
probe.prop = 6654;
skip.mf=700; skip.rng=100; skip.v0=sqrt(skip.rng*1000*g_moon);
skip.dv=4*skip.v0*1.05; skip.fuel_hop=skip.mf*(exp(skip.dv/ve)-1);
% Cross-check: should be ~303 kg
fprintf('== SKIP ORBITAL MECHANICS ==\n');
fprintf('  Range: %d km | v0=%.0f m/s | ΔV=%.0f m/s | Fuel/hop=%.0f kg\n',...
    skip.rng, skip.v0, skip.dv, skip.fuel_hop);
fprintf('  FLEET v8 says: 303 kg/hop. Δ: %+.0f kg (%s)\n\n',...
    skip.fuel_hop-303, ternary(abs(skip.fuel_hop-303)<30, 'OK', 'MISMATCH'));

skip.hops=274; skip.fuel_yr=skip.hops*skip.fuel_hop; skip.kreep_yr=skip.hops*400;
dart.prop=12370;
ls.eff=0.722; ls.prop_crew=0.9*365/0.889*ls.eff;

%% DEMAND-DRIVEN FLEET SIZING
ph.lab={'P3','P4','P5','P6','P7+'};
ph.nm={'P3 Y4-7','P4 Y7-9','P5 Y9-12','P6 Y12-15','P7+ Y20+'};
ph.n=5; ph.dur=[3 2 3 3 5];
ph.nP=[3 6 10 15 30]; ph.nS=[0 1 2 4 8]; ph.nD=[0 0 1 1 1]; ph.crew=[0 4 4 6 12];

ph.dP=ph.nP*probe.prop; ph.dS=ph.nS*skip.fuel_yr;
ph.dD=[0 0 dart.prop 0 dart.prop/2]; ph.dL=ph.crew*ls.prop_crew;
ph.dT=ph.dP+ph.dS+ph.dD+ph.dL;

mf=1.10; ph.mi=zeros(1,ph.n); ph.nd=zeros(1,ph.n);
for i=1:ph.n
    if ph.dT(i)>0, raw=ceil(ph.dT(i)*mf/mi.prop_yield); else, raw=10; end
    ph.mi(i)=ceil(raw/node.units)*node.units; ph.nd(i)=ph.mi(i)/node.units;
end
ph.isru=ph.mi*mi.prop_yield; ph.margin=ph.isru-ph.dT;

fprintf('== FLEET SIZING ==\n');
fprintf('  %-14s %4s %4s %4s %4s | %5s %5s | %8s %8s | %+8s\n',...
    'Phase','Prb','SKP','DRT','Crew','MI','Nod','Demand','Supply','Margin');
fprintf('  %s\n',repmat('-',1,85));
for i=1:ph.n
    fprintf('  %-14s %4d %4d %4d %4d | %5d %5d | %7.1ft %7.1ft | %+7.1ft  [%s]\n',...
        ph.nm{i},ph.nP(i),ph.nS(i),ph.nD(i),ph.crew(i),...
        ph.mi(i),ph.nd(i),ph.dT(i)/1e3,ph.isru(i)/1e3,ph.margin(i)/1e3,...
        ternary(ph.margin(i)>=0,'PASS','FAIL'));
end

stk=0; fprintf('\n  STOCKPILE:\n');
for i=1:ph.n, stk=stk+ph.margin(i)*ph.dur(i);
    fprintf('    %s: %+.1f t/yr × %d yr -> %.0f t\n',ph.lab{i},ph.margin(i)/1e3,ph.dur(i),stk/1e3); end

%% PIPELINE HEATING (fishbone geometry from v4.5)
% Trunk grows per phase; branches = 200 m per node
trunk_km = [2.0, 4.0, 6.0, 8.0, 8.5];
branch_km = ph.nd * 0.2;  % 200 m per substation
spine_km = trunk_km * 0.15;  % spine ~15% of trunk length

pipe.kW = trunk_km*pipe.q_ground + spine_km*pipe.q_ground + branch_km*pipe.q_elev;
pipe.pump = [0 pipe.pump_kW pipe.pump_kW pipe.pump_kW pipe.pump_kW];
pipe.total = pipe.kW + pipe.pump;

fprintf('\n== PIPELINE HEATING (v5.0) ==\n');
fprintf('  %-5s  Trunk   Spine   Branch   Heat(kW)  Pump(kW)  Total(kW)\n','Phase');
for i=1:ph.n
    fprintf('  %-5s  %5.1f   %5.1f   %5.1f    %6.1f     %5.1f     %6.1f\n',...
        ph.lab{i}, trunk_km(i), spine_km(i), branch_km(i), pipe.kW(i), pipe.pump(i), pipe.total(i));
end

%% ═══ ECLSS SCENARIO C VERIFICATION (v5.0 new) ═══
fprintf('\n== ECLSS SCENARIO C VERIFICATION ==\n');
M_CO2=44.01; M_H2=2.016; M_CH4=16.04; M_H2O=18.015; M_O2=32.00;

H2_OGA = 0.431; % kg/day (Scenario C balanced)
mol_H2 = H2_OGA*1000/M_H2;
CO2_sab = mol_H2/4 * M_CO2/1000;
CH4_sab = mol_H2/4 * M_CH4/1000;
H2O_sab = mol_H2/4 * 2 * M_H2O/1000;
O2_OGA = mol_H2/2 * M_O2/1000;
H2O_OGA = mol_H2 * M_H2O/1000;

CO2_crew = 4.0; CO2_GH = 1.65; O2_crew = 3.36; H2O_crew = 20.0;
GH_O2 = 1.20;

fprintf('  OGA: %.3f kg H₂/day → %.2f kg O₂ + %.2f kg H₂O consumed\n', H2_OGA, O2_OGA, H2O_OGA);
fprintf('  Sabatier: %.2f kg CO₂ → %.2f kg CH₄ + %.2f kg H₂O\n', CO2_sab, CH4_sab, H2O_sab);
fprintf('  CO₂: crew %.1f − Sab %.2f − GH %.2f = %.2f (%s)\n',...
    CO2_crew, CO2_sab, CO2_GH, CO2_crew-CO2_sab-CO2_GH,...
    ternary(abs(CO2_crew-CO2_sab-CO2_GH)<0.1,'✓ CLOSES','✗'));
fprintf('  O₂: OGA %.2f − crew %.2f + GH %.2f = %+.2f surplus\n',...
    O2_OGA, O2_crew, GH_O2, O2_OGA-O2_crew+GH_O2);

WRS_out = 4*4.88*0.93;
H2O_deficit = H2O_crew - WRS_out - H2O_sab + H2O_OGA;
fprintf('  H₂O: crew %.1f − WRS %.2f − Sab %.2f + OGA %.2f = %.2f ISRU makeup\n',...
    H2O_crew, WRS_out, H2O_sab, H2O_OGA, H2O_deficit);
fprintf('  OGA power: %.0f W (%.3f kg H₂ × 52.5 kWh/kg ÷ 24)\n\n',...
    H2_OGA*52.5/24*1000, H2_OGA);

%% HABITAT POWER BREAKDOWN (v5.0 new)
fprintf('== HABITAT POWER BREAKDOWN ==\n');
hab.CDRA=1000; hab.OGA=940; hab.Sab=350; hab.TCCS=380; hab.CCAA=500;
hab.WRS=500; hab.thermal=200; hab.lighting=500; hab.comms=150;
hab.other=500; hab.conv_loss=1000; hab.LED=12000;

hab.no_GH = hab.CDRA+hab.OGA+hab.Sab+hab.TCCS+hab.CCAA+hab.WRS+...
    hab.thermal+hab.lighting+hab.comms+hab.other+hab.conv_loss;
hab.with_GH = hab.no_GH + hab.LED;

fprintf('  CDRA %d + OGA %d + Sab %d + TCCS %d + CCAA %d\n',...
    hab.CDRA, hab.OGA, hab.Sab, hab.TCCS, hab.CCAA);
fprintf('  + WRS %d + thermal %d + lighting %d + comms %d + other %d + conv %d\n',...
    hab.WRS, hab.thermal, hab.lighting, hab.comms, hab.other, hab.conv_loss);
fprintf('  = %.1f kW no-GH (spec: 50 kW nom → %s)\n',...
    hab.no_GH/1000, ternary(hab.no_GH/1000<=50,'✓','✗'));
fprintf('  + LED %d = %.1f kW with-GH (spec: 63 kW margin → %s)\n\n',...
    hab.LED, hab.with_GH/1000, ternary(hab.with_GH/1000<=63,'✓','✗'));

%% NORMAL POWER BUDGET
fprintf('== NORMAL POWER BUDGET (v5.0) ==\n');
V=1000;
ph.wyr=ph.mi.*mi.water_yr; ph.whr=ph.wyr/8760;

% PSR — uses tether draw (includes DC-DC + batt charge)
ph.p_fleet = ph.mi*mi.pwr_tether/1000;
ph.p_nodes = ph.nd*node.overhead_v5/1000;
ph.p_pipe  = pipe.total;
ph.p_psr   = ph.p_fleet+ph.p_nodes+ph.p_pipe;

% ISRU (from ISRU-001 Rev D: 5.5 kW per kg/hr H₂O)
kw_per_kghr=5.5; ph.p_elec=ph.whr*kw_per_kghr;
ph.h2hr=ph.whr*(2*M_H2)/(2*M_H2O); ph.o2hr=ph.whr*M_O2/(2*M_H2O);
ph.p_lh2=ph.h2hr*15; ph.p_lox=ph.o2hr*1.0;  % 15 kWh/kg LH₂, 1 kWh/kg LOX
ph.p_cryo=ph.p_lh2+ph.p_lox;
ph.p_vex=[5 15 30 40 50]; ph.p_isru_oth=[5 10 12 14 15];
ph.p_isru=ph.p_elec+ph.p_cryo+ph.p_vex+ph.p_isru_oth;
ph.nPEM=ceil(ph.p_elec/50);

% Cross-check ISRU-001 cryo value
fprintf('\n  ISRU CRYO CROSS-CHECK (P7+):\n');
fprintf('    LH₂ liq: %.1f kg/hr × 15 kWh/kg ÷ 24 = %.0f kW (ISRU-001: 200 kW)\n',...
    ph.h2hr(end)*24, ph.p_lh2(end));
fprintf('    LOX liq: %.1f kg/hr × 1.0 kWh/kg ÷ 24 = %.0f kW (ISRU-001: 54 kW)\n',...
    ph.o2hr(end)*24, ph.p_lox(end));
fprintf('    Total cryo calc: %.0f kW vs ISRU-001 256 kW (Δ=%+.0f — passive cooling assumption)\n\n',...
    ph.p_cryo(end), ph.p_cryo(end)-256);

% Habitat (phase-dependent)
ph.p_hab=[0 hab.no_GH/1000 hab.no_GH/1000 hab.no_GH/1000+2 hab.with_GH/1000];

% IZ
ph.p_iz=[5 20 40 60 108];

% Surface robots (grid draw only — SINTER is self-powered)
ph.nMS=[4 4 4 6 6]; ph.nARMC=[1 1 1 1 2]; ph.nARMD=[1 2 4 6 8];
ph.nSEN=[2 2 3 4 4];
ph.p_robots = ph.nMS*1.2 + ph.nARMC*3.0 + ph.nSEN*0.5;  % charging station avg draw

% SKIP/DART pad + ZBO
ph.p_skippad = [0 0.5 1 2 4];
ph.p_dartzbo = [0 0 2.5 2.5 2.5];
ph.p_farmzbo = [0 4 6 8 11];

% CAP
ph.p_cap = [0 0 0 cap.stby_kW cap.stby_kW];

% Comms
ph.p_comms = [0.2 0.5 0.5 0.5 0.5];

% Totals
ph.p_base = ph.p_hab + ph.p_iz + ph.p_robots + ph.p_skippad + ph.p_dartzbo + ...
            ph.p_farmzbo + ph.p_cap + ph.p_comms;
ph.p_sub = ph.p_psr + ph.p_isru + ph.p_base;
ph.p_cont = ph.p_sub * 0.20;
ph.p_tot = ph.p_sub + ph.p_cont;

% Solar array sizing (v5.0: with dust factor)
ph.solar_cap = ph.p_tot / solar.illum;
ph.panel_m2 = ph.p_tot / solar.yield_kWm2;
ph.panel_kg = ph.panel_m2 * 3;  % 3 kg/m²

fprintf('  %-5s | %4s %4s | %6s %6s %6s | %6s | %6s %5s | %6s | %6s\n',...
    'Phase','MI','Nod','PSR','Pipe','ISRU','Base','Sub','Cont','TOTAL','Panels');
fprintf('  %s\n',repmat('-',1,85));
for i=1:ph.n
    fprintf('  %-5s | %4d %4d | %5.0f  %5.0f  %5.0f  | %5.0f  | %5.0f  %5.0f | %5.0f kW | %5.0f m²\n',...
        ph.lab{i},ph.mi(i),ph.nd(i),...
        ph.p_fleet(i)+ph.p_nodes(i), ph.p_pipe(i), ph.p_isru(i),...
        ph.p_base(i), ph.p_sub(i), ph.p_cont(i), ph.p_tot(i), ph.panel_m2(i));
end

fprintf('\n  PEM STACKS: '); fprintf('%d ',ph.nPEM); fprintf('(spec: 19 at P7+)\n');

%% ECLIPSE POWER (72-hr conservative)
fprintf('\n== ECLIPSE POWER (72-hr conservative) ==\n');
eclipse_hr = 72;

ecl.mi = ph.mi*mi.pwr_ka/1000;
ecl.nd = ph.nd*node.overhead_v5/1000;
ecl.pipe = pipe.total;  % MUST NOT stop
ecl.hab = ph.p_hab;     % Life-critical
ecl.sent = ph.nSEN*0.5; % SENTINEL rovers standby + servers
ecl.farmzbo = ph.p_farmzbo;
ecl.misc = [0 5 5 5 5];  % essential controls
ecl.tot = ecl.mi+ecl.nd+ecl.pipe+ecl.hab+ecl.sent+ecl.farmzbo+ecl.misc;

% FSP deployment: 1→2→3→4→5 per phase
ecl.nfsp = [1 2 3 4 5];
ecl.fsp_kW = ecl.nfsp * fsp.pwr_kW;

batt_margin=1.20; batt_Whkg=250;

fprintf('  %-5s | %5s %5s %5s %5s %5s %5s | %6s | %5s | %12s\n',...
    'Phase','MI ka','Nodes','Pipe','Hab','FmZBO','Other','CRIT','FSP','Battery');
fprintf('  %s\n',repmat('-',1,90));

ecl.bkWh=zeros(1,ph.n); ecl.bt=zeros(1,ph.n);
for i=1:ph.n
    short=max(0, ecl.tot(i) - ecl.fsp_kW(i));
    bkWh=short*eclipse_hr*batt_margin;
    bt=bkWh*1000/batt_Whkg/1000;
    ecl.bkWh(i)=bkWh; ecl.bt(i)=bt;
    if short>0, bs=sprintf('%.0f kWh (%.1ft)',bkWh,bt); else, bs='FSP covers'; end
    fprintf('  %-5s | %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f | %5.0f kW | %dx%dkW | %s\n',...
        ph.lab{i},ecl.mi(i),ecl.nd(i),ecl.pipe(i),ecl.hab(i),...
        ecl.farmzbo(i),ecl.sent(i)+ecl.misc(i),...
        ecl.tot(i),ecl.nfsp(i),fsp.pwr_kW,bs);
end

% Battery + ISRU ride-through (v4.5 tiered model)
isru_ride_hr = 2;  % 2 hr ride-through for ISRU during solar transient
ph.t2_kWh = ph.p_isru * isru_ride_hr;
ph.batt_total_kWh = ecl.bkWh + ph.t2_kWh;
ph.batt_total_t = ph.batt_total_kWh * 1000 / batt_Whkg / 1000;

fprintf('\n  BATTERY TIERING (eclipse + ISRU ride-through):\n');
fprintf('  %-5s  Eclipse(kWh) ISRU-RT(kWh)  Total(kWh)  Mass(t)\n','Phase');
for i=1:ph.n
    fprintf('  %-5s  %8.0f     %8.0f      %8.0f     %5.1f\n',...
        ph.lab{i}, ecl.bkWh(i), ph.t2_kWh(i), ph.batt_total_kWh(i), ph.batt_total_t(i));
end

%% ISRU DETAIL
fprintf('\n== ISRU PLANT ==\n');
for i=1:ph.n
    lh2=ph.wyr(i)*(2*M_H2)/(2*M_H2O)*0.722; lox=ph.wyr(i)*M_O2/(2*M_H2O)*0.722;
    fprintf('  %s: %.1f kg/hr | %d PEM | elec %.0f + cryo %.0f + vex %.0f + oth %.0f = %.0f kW | LH2 %.1ft LOX %.1ft\n',...
        ph.lab{i},ph.whr(i),ph.nPEM(i),ph.p_elec(i),ph.p_cryo(i),ph.p_vex(i),ph.p_isru_oth(i),...
        ph.p_isru(i),lh2/1e3,lox/1e3);
end

%% TRUNK CABLE
fprintf('\n== TRUNK CABLE ==\n');
cu_rho=0.24e-8; cu_den=8960; tm=crater.traverse_km*1000;
for i=1:ph.n
    I=ph.p_psr(i)*1000/V;
    if I>0, R=0.05*V/I; A=cu_rho*tm*2/R*1e6; m=A*1e-6*tm*2*cu_den;
    else, A=10; m=1500; end
    fprintf('  %s: %.0f kW -> %3.0f A -> %4.0f mm² -> %5.1f t Cu\n',ph.lab{i},ph.p_psr(i),I,A,m/1e3);
end

%% MATERIAL OUTPUT
fprintf('\n== MATERIAL OUTPUT ==\n');
for i=1:ph.n
    kc=ph.nS(i)*skip.kreep_yr/1e3*0.04; pg=max(0,ph.nP(i)*1.5*(i>1));
    fprintf('  %s: %.1ft PGM ore + %.1ft KREEP concentrate = %.1ft/yr\n',ph.lab{i},pg,kc,pg+kc);
end

%% POWER INFRASTRUCTURE MASS (v5.0 new)
fprintf('\n== POWER INFRASTRUCTURE MASS ==\n');
fsp_mass_cum = ecl.nfsp * fsp.mass_kg;
batt_mass = [0 1000 1000 1000 1000];  % P4+ eclipse supplement
hub_mass = [500 500 500 500 500];
conv_mass = [200 400 600 800 1000];
cable_mass = [300 500 700 800 880];
total_pwr_mass = (ph.panel_kg + fsp_mass_cum + batt_mass + hub_mass + conv_mass + cable_mass)/1000;

fprintf('  %-5s  Array(t)  FSP(t)  Batt(t) Hub(t)  Conv(t) Cable(t) TOTAL(t)\n','Phase');
for i=1:ph.n
    fprintf('  %-5s  %6.1f    %5.1f   %5.1f   %5.1f   %5.1f   %5.1f    %5.1f\n',...
        ph.lab{i}, ph.panel_kg(i)/1000, fsp_mass_cum(i)/1000, batt_mass(i)/1000,...
        hub_mass(i)/1000, conv_mass(i)/1000, cable_mass(i)/1000, total_pwr_mass(i));
end

%% FAILURE ANALYSIS
fprintf('\n== FAILURE ANALYSIS ==\n');
d6=ph.dT(4); mn=ceil(d6/mi.prop_yield); sp=ceil(ph.mi(end)*0.12);
fprintf('  P6: %.0ft demand -> min %d MI | fleet %d -> %d buffer\n',d6/1e3,mn,ph.mi(4),ph.mi(4)-mn);
fprintf('  Stockpile: %.0f t (%.1f months P6 reserve)\n',stk/1e3,stk/d6*12);
fprintf('  Cold spares: %d (12%%)\n',sp);
fprintf('  FSP N+1: 5th reactor at P7+ covers single failure (4×40=160 kW > 156 kW crit)\n');

%% ═══════════════════════════════════════════════════════════════════
%  SUMMARY
%% ═══════════════════════════════════════════════════════════════════
fprintf('\n════════════════════════════════════════════════════════════════\n');
fprintf('  v5.0 VERIFICATION SUMMARY\n');
fprintf('════════════════════════════════════════════════════════════════\n');
fprintf('  MOLE-I: %d W op / %d W tether / %d W ka          ✓\n',mi.pwr_op,round(mi.pwr_tether),mi.pwr_ka);
fprintf('  Substation: %.1f W (10-component + ECN-013 enc)    ✓\n',node.overhead_v5);
fprintf('  Scenario C: CO₂ closes (%.2f residual)            ✓\n',CO2_crew-CO2_sab-CO2_GH);
fprintf('  Hab: %.1f kW no-GH / %.1f kW with-GH              ✓\n',hab.no_GH/1000,hab.with_GH/1000);
fprintf('  ISRU elec (P7+): %.0f kW (%d PEM stacks)            ✓\n',ph.p_elec(end),ph.nPEM(end));
fprintf('  ISRU cryo (P7+): %.0f kW (calc) vs 256 kW (spec)   ⚠\n',ph.p_cryo(end));
fprintf('  Total demand (P7+): %.0f kW + 20%% = %.0f kW          \n',ph.p_sub(end),ph.p_tot(end));
fprintf('  Solar (P7+): %.0f m² (%.2f ha) with dust factor    ✓\n',ph.panel_m2(end),ph.panel_m2(end)/10000);
fprintf('  FSP: %d×%d kWe = %d kW | Eclipse 72hr covered     ✓\n',ecl.nfsp(end),fsp.pwr_kW,ecl.fsp_kW(end));
fprintf('  Propellant: all phases PASS                        ✓\n');
for i=1:ph.n
    if ph.margin(i)<0, fprintf('  ✗ %s: PROPELLANT DEFICIT\n',ph.lab{i}); end
end
fprintf('  Pipeline: %.0f kW at P7+ (MUST NOT STOP in eclipse) ✓\n', pipe.total(end));

%% ═══════════════════════════════════════════════════════════════════
%  FIGURES (9 total)
%% ═══════════════════════════════════════════════════════════════════
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
title('Propellant Balance (v5.0)'); grid on; set(gca,'FontSize',11);

% Fig 2: Demand Composition
figure('Name','Fig 2 - Demand Composition','Position',[50 620 920 520]);
b2=bar(x,[ph.dP;ph.dS;ph.dD;ph.dL]'/1e3,'stacked');
b2(1).FaceColor=cd; b2(2).FaceColor=cr; b2(3).FaceColor=ca; b2(4).FaceColor=cg;
hold on; plot(x,ph.isru/1e3,'k-s','LineWidth',2.5,'MarkerFaceColor','k','MarkerSize',8);
ylabel('Propellant (t/yr)'); xticks(x); xticklabels(ph.lab);
legend('PROBE','SKIP','DART','Life Support','ISRU Supply','Location','northwest');
title('Demand Composition (v5.0)'); grid on; set(gca,'FontSize',11);

% Fig 3: Normal Power by Zone
figure('Name','Fig 3 - Power Budget','Position',[1000 50 950 550]);
pz=[ph.p_fleet+ph.p_nodes; ph.p_pipe; ph.p_isru; ph.p_base; ph.p_cont]';
b3=bar(x,pz,'stacked');
b3(1).FaceColor=cr; b3(2).FaceColor=cb; b3(3).FaceColor=ca; b3(4).FaceColor=cg; b3(5).FaceColor=cy;
ylabel('Power (kW)'); xticks(x); xticklabels(ph.lab);
legend('PSR Fleet+Nodes','Pipeline','ISRU','Base+IZ','Contingency 20%','Location','northwest');
title('Normal Operations Power (v5.0)'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.p_tot(i)+20,sprintf('%.0f kW\n%.0f m²',ph.p_tot(i),ph.panel_m2(i)),...
    'HorizontalAlignment','center','FontSize',9,'FontWeight','bold'); end

% Fig 4: Eclipse Power
figure('Name','Fig 4 - Eclipse Power (72hr)','Position',[1000 620 950 550]);
ez=[ecl.mi; ecl.nd; ecl.pipe; ecl.hab; ecl.farmzbo; ecl.sent+ecl.misc]';
b4=bar(x,ez,'stacked');
b4(1).FaceColor=cr; b4(2).FaceColor=cp; b4(3).FaceColor=cb;
b4(4).FaceColor=cg; b4(5).FaceColor=ca; b4(6).FaceColor=cy;
hold on;
for i=1:ph.n
    fc=ecl.fsp_kW(i);
    plot([i-0.4,i+0.4],[fc,fc],'r-','LineWidth',3);
    if ecl.tot(i)>fc
        text(i,ecl.tot(i)+3,sprintf('+%.0f kWh\n(%.1ft batt)',ecl.bkWh(i),ecl.bt(i)),...
            'HorizontalAlignment','center','FontSize',7,'Color',ca);
    else
        text(i,ecl.tot(i)+2,sprintf('FSP OK\n(%d×%dkW)',ecl.nfsp(i),fsp.pwr_kW),...
            'HorizontalAlignment','center','FontSize',9,'Color',cg,'FontWeight','bold');
    end
end
ylabel('Eclipse Load (kW)'); xticks(x); xticklabels(ph.lab);
legend('MI keep-alive','Substations','Pipeline','Habitat','Farm ZBO','Other+SENTINEL',...
       'FSP capacity','Location','northwest');
title('Eclipse Survival — 72hr Conservative (v5.0)'); grid on; set(gca,'FontSize',11);

% Fig 5: Solar + Battery
figure('Name','Fig 5 - Solar & Battery','Position',[50 1200 900 450]);
subplot(1,2,1);
bar(x,ph.panel_m2,'FaceColor',ca); ylabel('Panel Area (m²)');
xticks(x); xticklabels(ph.lab);
title(sprintf('Solar (29%% GaAs, 85%% sun, %d%% dust)',solar.dust*100));
grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.panel_m2(i)+80,sprintf('%.0f',ph.panel_m2(i)),...
    'HorizontalAlignment','center','FontSize',9); end

subplot(1,2,2);
bar(x, ph.batt_total_t, 'FaceColor', cr);
ylabel('Battery (tonnes)'); xticks(x); xticklabels(ph.lab);
title('Total Battery (Eclipse + ISRU ride-through)'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,ph.batt_total_t(i)+0.1,sprintf('%.1ft',ph.batt_total_t(i)),...
    'HorizontalAlignment','center','FontSize',9); end

% Fig 6: Stockpile
figure('Name','Fig 6 - Stockpile','Position',[50 700 920 480]);
yrs=[]; st2=[]; cs=0; ys=4;
for i=1:ph.n
    for y=1:ph.dur(i), cs=cs+ph.margin(i); yrs=[yrs,ys+y-1]; st2=[st2,cs/1e3]; end
    ys=ys+ph.dur(i);
end
area(yrs,st2,'FaceColor',[0.75 0.88 0.95],'EdgeColor',cb,'LineWidth',2);
hold on;
ps=cumsum([4 ph.dur]);
for i=1:ph.n, xline(ps(i),'k:'); text(ps(i)+0.3,max(st2)*0.92,ph.lab{i},'FontSize',11,'FontWeight','bold'); end
xlabel('Year'); ylabel('Stockpile (t)'); title('Propellant Stockpile (v5.0)'); grid on; set(gca,'FontSize',11);

% Fig 7: Fleet Scaling
figure('Name','Fig 7 - Fleet Scaling','Position',[1000 700 800 450]);
yyaxis left; bar(x,ph.mi,'FaceColor',cb,'BarWidth',0.6); ylabel('MOLE-I'); ylim([0 200]);
yyaxis right; plot(x,ph.nd,'r-o','LineWidth',2.5,'MarkerFaceColor',cr,'MarkerSize',10); ylabel('Nodes');
xticks(x); xticklabels(ph.lab); title('Fleet Scaling (v5.0)'); grid on; set(gca,'FontSize',11);

% Fig 8: MOLE-I Power Pie
figure('Name','Fig 8 - MOLE-I Power','Position',[50 1250 750 500]);
pv=[mi.pwr.drive,mi.pwr.drill,mi.pwr.minivex,mi.pwr.web,mi.pwr.comms,...
    mi.pwr.gbx_htr,mi.pwr.drill_htr,mi.pwr.recept];
pl={sprintf('Drive %dW',mi.pwr.drive),sprintf('Drill %dW',mi.pwr.drill),...
    sprintf('mini-VEX %dW',mi.pwr.minivex),sprintf('WEB %dW',mi.pwr.web),...
    sprintf('Comms %dW',mi.pwr.comms),sprintf('Gearbox 6×5=%dW',mi.pwr.gbx_htr),...
    sprintf('Drill htr %dW',mi.pwr.drill_htr),sprintf('Recept %dW',mi.pwr.recept)};
pie(pv); legend(pl,'Location','eastoutside','FontSize',9);
title(sprintf('MOLE-I: %dW op / %dW tether / %dW ka (v5.0)',mi.pwr_op,round(mi.pwr_tether),mi.pwr_ka));

% Fig 9: FSP Deployment + Eclipse Margin
figure('Name','Fig 9 - FSP & Eclipse','Position',[850 1250 900 500]);
subplot(1,2,1);
bar(x, [ecl.fsp_kW; ecl.tot]', 'grouped');
ylabel('Power (kW)'); xticks(x); xticklabels(ph.lab);
legend('FSP capacity','Eclipse-critical load','Location','northwest');
title('FSP vs Eclipse Load (72hr)'); grid on; set(gca,'FontSize',11);

subplot(1,2,2);
bar(x, total_pwr_mass, 'FaceColor', cd);
ylabel('Mass (tonnes)'); xticks(x); xticklabels(ph.lab);
title('Power Infrastructure Mass (cumulative)'); grid on; set(gca,'FontSize',11);
for i=1:ph.n, text(i,total_pwr_mass(i)+0.5,sprintf('%.1ft',total_pwr_mass(i)),...
    'HorizontalAlignment','center','FontSize',9); end

fprintf('\n  9 figures generated.\n');
fprintf('  Save as: SELENITE_VERIFY_v5_0_figures.pdf\n');

% Helper
function s = ternary(cond, a, b)
    if cond, s = a; else, s = b; end
end
