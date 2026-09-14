%% SELENITE_VERIFY_v4_3.m
%  Demand-Driven Fleet Sizing & Base Infrastructure Verification
%  6-Wheel MOLE-I | Ti Flexure Pivots | Bilateral Fishbone | 1000 VDC
%  Hybrid Power (Solar + FSP Eclipse) | Separated ISRU | CAP
%
%  v4.3: MOLE-I thermal corrections from MOLEI_THERMAL v1.2:
%    - WEB heater: 57W -> 15W (bottom-up thermal model, includes VEX strap draw)
%    - VEX standby: 25W -> 0W (Cu braid thermal strap from WEB, passive)
%    - Wax-actuated thermal shunt added (n-tetradecane, passive, ~50-80g)
%    - Keep-alive: 132W -> 65W | Transit battery: 682 -> 337 Wh
%    - Passive funnel-cradle docking (no arm needed)
%    - 8 LWRHU retained (extended survival >200hr, not indefinite)
%  v4.2: Corrected eclipse model, CAP power, 6-wheel cascade, EOL derating
%  Author: Jason (Systems Engineering Lead), Selenite Programme
%  Date: March 2026

clear; clc; close all;

g0=9.81; g_moon=1.62; Isp=450; ve=Isp*g0;

fprintf('================================================================\n');
fprintf('  SELENITE v4.3 - Thermal-Corrected Fleet Model\n');
fprintf('  6-Wheel MOLE-I | Hybrid Power | Bilateral Fishbone\n');
fprintf('  WEB 15W (was 57W) | VEX stby 0W (was 25W) | Ref: MOLEI_THERMAL v1.2\n');
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
mi.pwr.web=15;      % v4.3: was 57W. MOLEI_THERMAL v1.2: 11.4W WEB loss + 3.1W VEX strap = 14.4W, rounded to 15W.
                     %   Bottom-up: PEEK standoffs, Manganin cables, MLI pen losses, valve actuator, feed chute.
                     %   Includes VEX thermal strap draw (Cu braid, passive, replaces 25W VEX standby heater).
                     %   Wax-actuated thermal shunt (n-tetradecane, 278K) prevents drilling overheating.
mi.pwr.comms=20; mi.pwr.gbx_htr=30; mi.pwr.drill_htr=15; mi.pwr.recept=5;
mi.pwr.vex_stby=0;  % v4.3: was 25W. Eliminated by Cu braid thermal strap from WEB (7.2W capacity vs 3.1W need).

mi.pwr_op = mi.pwr.drive+mi.pwr.drill+mi.pwr.minivex+mi.pwr.web+mi.pwr.comms+...
            mi.pwr.gbx_htr+mi.pwr.drill_htr+mi.pwr.recept+mi.pwr.vex_stby;
mi.pwr_ka = mi.pwr.web+mi.pwr.gbx_htr+mi.pwr.drill_htr+mi.pwr.recept+mi.pwr.vex_stby;
mi.descent_hr = (crater.traverse_km*1000/0.5)/3600;
mi.batt_Wh = mi.pwr_ka*mi.descent_hr*1.10;
mi.batt_kg = mi.batt_Wh/250;

fprintf('== MOLE-I (6-WHEEL) ==\n');
fprintf('  %d kg dry | %d W op | %d W ka | %.0f Wh batt\n\n', mi.mass_dry,mi.pwr_op,mi.pwr_ka,mi.batt_Wh);

%% SUBSTATION NODE
node.units=5; node.web=80; node.drums=5*8; node.pump=10;
node.overhead = node.web+node.drums+node.pump;  % 130 W
node.mass=160;

%% PIPELINE
pipe.kW = 8500*7/1000;  % 59.5 kW trace heating
pump.trunk_kW = 0.408;

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


%% NORMAL POWER BUDGET
fprintf('\n== NORMAL POWER BUDGET ==\n');
V=1000;
ph.wyr=ph.mi.*mi.water_yr; ph.whr=ph.wyr/8760;

% PSR
ph.p_fleet = ph.mi*mi.pwr_op/1000;
ph.p_nodes = ph.nd*node.overhead/1000;
ph.p_pipe  = [0,pipe.kW,pipe.kW,pipe.kW,pipe.kW];
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


%% ECLIPSE POWER (CORRECTED)
fprintf('\n== ECLIPSE POWER (CORRECTED) ==\n');
fprintf('  During 1-3 day shadow (~2x/lunar yr):\n');
fprintf('  MOLE-I -> keep-alive (%d W, NOT %d W operating)\n', mi.pwr_ka, mi.pwr_op);
fprintf('  Substations -> ON (distribute keep-alive via tethers)\n');
fprintf('  Pipeline -> ON (freeze = replacement)\n');
fprintf('  ISRU -> OFF | Beneficiation -> OFF\n\n');

ecl.mi = ph.mi*mi.pwr_ka/1000;
ecl.nd = ph.nd*node.overhead/1000;
ecl.pipe = [0,pipe.kW,pipe.kW,pipe.kW,pipe.kW];
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
xticks(x); xticklabels(ph.lab); title('Fleet Scaling (v4.3)'); grid on; set(gca,'FontSize',11);

% Fig 8: MOLE-I Power Pie (v4.3: VEX stby removed — 0W via thermal strap)
figure('Name','Fig 8 - MOLE-I Power','Position',[50 1250 750 500]);
pv=[mi.pwr.drive,mi.pwr.drill,mi.pwr.minivex,mi.pwr.web,mi.pwr.comms,...
    mi.pwr.gbx_htr,mi.pwr.drill_htr,mi.pwr.recept];
pl={sprintf('Drive %dW',mi.pwr.drive),sprintf('Drill %dW',mi.pwr.drill),...
    sprintf('mini-VEX %dW',mi.pwr.minivex),sprintf('WEB %dW (v4.3)',mi.pwr.web),...
    sprintf('Comms %dW',mi.pwr.comms),sprintf('Gearbox 6x5=%dW',mi.pwr.gbx_htr),...
    sprintf('Drill htr %dW',mi.pwr.drill_htr),sprintf('Recept %dW',mi.pwr.recept)};
if mi.pwr.vex_stby > 0  % include only if non-zero
    pv=[pv, mi.pwr.vex_stby];
    pl=[pl, {sprintf('VEX stby %dW',mi.pwr.vex_stby)}];
end
pie(pv); legend(pl,'Location','eastoutside','FontSize',9);
title(sprintf('MOLE-I: %dW op / %dW ka (v4.3)',mi.pwr_op,mi.pwr_ka));

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
fprintf('  v4.3 SUMMARY (thermal-corrected)\n');
fprintf('================================================================\n');
fprintf('  MOLE-I: 6-wheel, %dkg, %dW op / %dW ka\n',mi.mass_dry,mi.pwr_op,mi.pwr_ka);
fprintf('    v4.3 thermal corrections (ref: MOLEI_THERMAL v1.2):\n');
fprintf('    WEB heater: 57W -> %dW (bottom-up model + VEX strap draw)\n',mi.pwr.web);
fprintf('    VEX standby: 25W -> %dW (Cu braid strap, passive)\n',mi.pwr.vex_stby);
fprintf('    Wax thermal shunt: n-tetradecane, 278K, ~50-80g, passive\n');
fprintf('    Transit battery: %.0f Wh / %.1f kg (was 682 Wh / 2.7 kg)\n',mi.batt_Wh,mi.batt_kg);
fprintf('  Power: solar + %dx%dkW FSP | CAP: %.0fkW peak (Phase 2+)\n\n',max(ecl.nfsp),fsp.pwr_kW,cap.peak_kW);

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