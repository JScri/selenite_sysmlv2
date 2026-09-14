%% MOLEI_THERMAL_v1_2.m
%  MOLE-I WEB + Subsystem Thermal Verification
%  v1.2: adds wax-actuated thermal shunt (n-tetradecane, passive)
%
%  Changelog from v1.1:
%    - Wax-actuated variable-conductance thermal shunt sized & modelled
%    - Shunt integrated into all transient ODE modes
%    - Side-by-side comparison: with/without shunt
%    - Waste heat sensitivity sweep
%    - Construction tether docking concept documented
%    - Oversized strap option (15 mm² for margin)
%
%  Retained from v1.1:
%    - 49-conductor Manganin harness, MLI penetration losses
%    - Drain valve actuator, feed chute thermal bridge
%    - mini-VEX Cu braid thermal strap (eliminates 25W standby heater)
%    - Passive funnel-cradle docking (no arm)
%    - Tether stays connected during dump retraction
%    - 5-mode transient + sensitivity analysis
%
%  Author : Jason (Systems Engineering Lead), Selenite Programme
%  Date   : March 2026
%  Ref    : SEL_MOLEI_DESIGN v1, SEL_ROBOT_FLEET v4, VERIFY v4.2

clear; clc; close all;

fprintf('================================================================\n');
fprintf('  MOLE-I THERMAL v1.2\n');
fprintf('  v1.1 base + wax-actuated thermal shunt (n-tetradecane)\n');
fprintf('================================================================\n\n');

%% S1 — MATERIAL k(T) AND CONSTANTS
k_Ti   = @(T) max(0.1, -0.341+0.0327*T-4.16e-5*T.^2+2.17e-8*T.^3);
k_Cu   = @(T) max(10, 500-1.2*(T-200).^2/500+50*exp(-(T-30).^2/200));
k_SS   = @(T) max(0.5, -1.40+0.0820*T-1.30e-4*T.^2+8.50e-8*T.^3);
k_PEEK = @(T) 0.20+2.0e-4*T;
k_Mn   = @(T) max(5, 10.0+0.038*T);
QCf = @(kf,A,L,Tc,Th) (A/L)*integral(kf,Tc,Th);

Tf=40; Tw=25; Tweb=273; dT=Tweb-Tf;
ki_Ti=integral(k_Ti,Tf,Tweb); ki_PK=integral(k_PEEK,Tf,Tweb);
ka_Ti=ki_Ti/dT; ka_PK=ki_PK/dT;

% WEB geometry & thermal mass
wA=2*(0.55*0.35+0.55*0.35+0.35*0.35);
wC=50*4186+20*700;
lwP=1.1; lwM=0.042;

% MLI
mN=20; mE=0.03; mCs=8.95e-8; mCr=5.39e-10; mDeg=2.0;
Ab=pi/4*(6e-3)^2;

fprintf('== S1: Constants. T_floor=%d T_wall=%d T_web=%d dT=%d K\n',Tf,Tw,Tweb,dT);
fprintf('  WEB: A=%.3f m^2, C=%.0f J/K (%.0f Wh/K)\n\n',wA,wC,wC/3600);

%% S2 — WEB HEAT LOSS PATHS (unchanged from v1.1)
fprintf('== S2: WEB heat loss (v1.1 paths, unchanged) ==\n');

% A: PEEK standoffs
pA=pi/4*((20e-3)^2-(7e-3)^2); pL=0.050;
QA1=4*QCf(k_PEEK,pA,pL,Tf,Tweb);
hA=pi/4*((10e-3)^2-(6e-3)^2); wL=5e-3; bf=pL-2*wL;
Rw=wL/(ka_PK*hA); Rbo=bf/(ka_Ti*Ab);
QA2=4*dT/(2*Rw+Rbo); QA=QA1+QA2;

% B: Drain pipe
dA=pi/4*(20e-3^2-18e-3^2);
RB=2*(0.075/(ka_Ti*dA))+0.050/(ka_PK*dA); QB=dT/RB;

% C: Cable harness (49 cond Manganin)
Lm=0.100;
QCv=6*QCf(k_Mn,0.518e-6,Lm,Tf,Tweb)+13*QCf(k_Mn,0.326e-6,Lm,Tf,Tweb)+...
    26*QCf(k_Mn,0.081e-6,Lm,Tf,Tweb)+4*QCf(k_Mn,0.051e-6,Lm,Tf,Tweb);

% D: VEX water tube
QD=QCf(k_PEEK,pi/4*(10e-3^2-8e-3^2),0.040,Tf,Tweb);

% E: MLI penetrations (5x0.5W)
QE=5*0.5;

% F: Drain valve actuator
QF=QCf(k_SS,pi/4*(6e-3)^2,0.030,Tf,Tweb);

% G: Feed chute (50% PEEK)
chA=pi/4*(30e-3^2-26e-3^2);
Qch_full=QCf(k_SS,chA,0.100,Tf,Tweb); QG=Qch_full*0.50;

% H: MLI
qmli=mCs*(Tweb-Tf)*((Tweb+Tf)/2)/mN+mCr*mE*(Tweb^4.67-Tf^4.67)/mN;
QH=qmli*wA*mDeg;

Qsub=QA+QB+QCv+QD+QE+QF+QG+QH;
Qmar=Qsub*0.30; Qtot=Qsub+Qmar; Gweb=Qtot/dT;
Gc=(Qsub-QH)/dT;

pn={'A: PEEK standoffs (4x)','B: Drain pipe Ti+PEEK','C: Cables (49 Mn)',...
    'D: VEX tube PEEK','E: MLI penetrations 5x','F: Valve actuator',...
    'G: Feed chute 50%','H: MLI 20-layer'};
Qv=[QA QB QCv QD QE QF QG QH];

fprintf('\n  %-32s %8s\n','Path','Q (W)');
fprintf('  %s\n',repmat('-',1,44));
for i=1:8, fprintf('  %-32s %8.3f\n',pn{i},Qv(i)); end
fprintf('  %s\n',repmat('-',1,44));
fprintf('  %-32s %8.3f\n','SUBTOTAL',Qsub);
fprintf('  %-32s %8.3f\n','30%% margin',Qmar);
fprintf('  %-32s %8.3f\n','TOTAL',Qtot);
fprintf('\n  G_web = %.5f W/K | 57W spec -> %.1fx reduction\n',Gweb,57/Qtot);

%% S3 — LWRHU SIZING (unchanged)
fprintf('\n== S3: LWRHU sizing ==\n');
fprintf('  N | Q_in | T_eq(40K) | T_eq(25K) | >250K fl | >250K wl\n');
fprintf('  %s\n',repmat('-',1,60));
for N=3:10
    Qi=N*lwP; Teqf=Tf+Qi/Gweb; Teqw=Tw+Qi/Gweb;
    fprintf('  %d | %.1fW | %6.1fK   | %6.1fK   | %-3s     | %-3s\n',...
        N,Qi,Teqf,Teqw,tf(Teqf>=250,'YES','no'),tf(Teqw>=250,'YES','no'));
end
N250=max(ceil(Gweb*(250-Tf)/lwP),ceil(Gweb*(250-Tw)/lwP));
fprintf('  Indefinite 250K: %d LWRHU (%.1fW)\n',N250,N250*lwP);

%% S4 — MINI-VEX THERMAL STRAP (unchanged)
fprintf('\n== S4: mini-VEX thermal strap ==\n');
Tvex=200; dTv=Tvex-Tf; sc=dTv/dT;
Qvm=4*QCf(k_PEEK,pi/4*((15e-3)^2-(6e-3)^2),0.030,Tf,Tweb)*sc;
qvm=mCs*(Tvex-Tf)*((Tvex+Tf)/2)/10+mCr*mE*(Tvex^4.67-Tf^4.67)/10;
Qvl=qvm*0.15*2.5;
Qvc=Qch_full*sc;
Qvx_loss=Qvm+Qvl+Qvc;

dTs=Tweb-Tvex; kCus=integral(k_Cu,Tvex,Tweb)/dTs;
Qstrap=0.40*kCus*(25e-3*3e-3)*dTs/0.150;
Qvx_draw=min(Qstrap,Qvx_loss);
Qvx_htr=max(0,Qvx_loss-Qstrap);

fprintf('  VEX loss at %dK: %.2fW | Strap cap: %.2fW | Residual htr: %.2fW\n',...
    Tvex,Qvx_loss,Qstrap,Qvx_htr);
fprintf('  Strap draws %.2fW from WEB\n',Qvx_draw);

%% S5 — TETHER CONNECTOR (unchanged)
fprintf('\n== S5: Tether connector ==\n');
Qcf_PK=(pi/4*(40e-3)^2/5e-3)*integral(k_PEEK,Tf,100);
Qcc_Mn=2*(2.08e-6/0.100)*integral(k_Mn,Tf,100);
fprintf('  PEEK+Mn: %.2fW (spec 5W). Passive funnel dock. No arm.\n',Qcf_PK+Qcc_Mn);
fprintf('  Tether stays on during dump. Disconnect only for construction.\n');
fprintf('  Construction tethers: heated drum at support base,\n');
fprintf('  same funnel-cradle geometry, auto-spool after disconnect.\n');

%% S6 — THERMAL SHUNT SIZING (NEW in v1.2)
fprintf('\n== S6: Wax-actuated thermal shunt (NEW v1.2) ==\n');

Nlw=8; Qlw=Nlw*lwP;
Qw_drill=15;  % W waste heat coupling during drilling

% Uncontrolled drilling equilibrium (no shunt)
Teq_noshunt = Tf + (Qlw+Qw_drill)/Gweb;
fprintf('  Problem: during drilling, %.1fW input vs %.1fW loss\n',...
    Qlw+Qw_drill, Qtot);
fprintf('  Uncontrolled T_eq = %.0fK (DANGEROUS)\n\n', Teq_noshunt);

% Shunt sizing
shunt.T_on  = 278;  % K — wax melts, shunt engages
shunt.T_off = 275;  % K — wax solidifies, shunt disengages
shunt.T_target = 278;  % desired drilling equilibrium

Q_in_drill = Qlw + Qw_drill;
G_needed = Q_in_drill / (shunt.T_target - Tf);
shunt.G = G_needed - Gweb;
shunt.G_margin = shunt.G * 1.5;  % 50% oversize for waste heat uncertainty

% Physical sizing
k_Cu_shunt = 490;  % W/m·K at ~278K
shunt.L = 0.100;   % 100mm strap
shunt.A = shunt.G / (k_Cu_shunt / shunt.L);         % nominal
shunt.A_margin = shunt.G_margin / (k_Cu_shunt / shunt.L);  % oversized

% Equilibria with oversized strap
Teq_drill_nom = Tf + Q_in_drill / (Gweb + shunt.G);
Teq_drill_os  = Tf + Q_in_drill / (Gweb + shunt.G_margin);

fprintf('  SHUNT SPECIFICATION:\n');
fprintf('    Wax: n-tetradecane (C14H30), mp = 278.7 K\n');
fprintf('    Mechanism: wax melts -> piston presses Cu pad to chassis\n');
fprintf('    Wax solidifies -> spring retracts pad (shunt opens)\n');
fprintf('    Hysteresis: ~3K (inherent from wax thermal mass)\n');
fprintf('    NO POWER, NO ELECTRONICS, FULLY PASSIVE\n\n');

fprintf('  SIZING:\n');
fprintf('    G_web (existing):     %.4f W/K\n', Gweb);
fprintf('    G_shunt (nominal):    %.4f W/K\n', shunt.G);
fprintf('    G_shunt (1.5x margin):%.4f W/K  <- RECOMMENDED\n', shunt.G_margin);
fprintf('    Cu strap: %.0fmm long, %.1f mm^2 nominal, %.1f mm^2 oversized\n',...
    shunt.L*1e3, shunt.A*1e6, shunt.A_margin*1e6);
fprintf('    Oversized: flat strip ~10 x %.1f mm (trivial)\n', shunt.A_margin/10e-3*1e3);
fprintf('    Mass: ~50-80g total (wax capsule + Cu strap + spring)\n\n');

fprintf('  DRILLING EQUILIBRIUM:\n');
fprintf('    No shunt:      %.0fK (RUNAWAY)\n', Teq_noshunt);
fprintf('    Nominal shunt: %.0fK\n', Teq_drill_nom);
fprintf('    Oversized:     %.0fK  <- DESIGN POINT\n', Teq_drill_os);

fprintf('\n  POWER FAILURE: shunt disengages at %dK\n', shunt.T_off);
fprintf('    Below %dK: G = G_web only. Same LWRHU survival as v1.1.\n', shunt.T_off);
fprintf('    Shunt does NOT degrade power-failure performance.\n');

%% S7 — KEEP-ALIVE BUDGET (updated with shunt note)
fprintf('\n== S7: Keep-alive budget ==\n');
ka_web=Qtot+Qvx_draw;
ka_items={'WEB heater';'Gearbox 6x5W';'Drill bearing';'Receptacle';'VEX standby';'Thermal shunt'};
ka_orig=[57;30;15;5;25;0]; ka_real=[ka_web;30;15;5;Qvx_htr;0]; ka_opt=[ka_web;30;15;0;0;0];

fprintf('  %-24s | %7s | %9s | %10s\n','Subsystem','Original','Realistic','Optimistic');
fprintf('  %s\n',repmat('-',1,60));
for i=1:6
    fprintf('  %-24s | %6.1fW | %8.1fW | %9.1fW\n',...
        ka_items{i},ka_orig(i),ka_real(i),ka_opt(i));
end
tO=sum(ka_orig); tR=sum(ka_real); tP=sum(ka_opt);
fprintf('  %s\n',repmat('-',1,60));
fprintf('  %-24s | %6.0fW | %8.0fW | %9.0fW\n','TOTAL',tO,tR,tP);
fprintf('  %-24s | %6s | %8s | %9s\n','LWRHUs','8x1.1','8x1.1','8x1.1');
fprintf('  %-24s | %6s | %8s | %9s\n','Thermal shunt','none','passive','passive');

fprintf('\n  Transit battery (KA x 4.7hr x 1.10):\n');
for v={'Original',tO;'Realistic',tR;'Optimistic',tP}'
    b=v{2}*4.7*1.10; fprintf('    %s: %.0fW -> %.0f Wh (%.1f kg)\n',v{1},v{2},b,b/250);
end

%% S8 — MULTI-MODE TRANSIENT WITH SHUNT (ODE45)
fprintf('\n== S8: Multi-mode transient (with vs without shunt) ==\n');

opts=odeset('RelTol',1e-6,'AbsTol',1e-4,'MaxStep',300);
Qw_modes_val=[15,0,15,0,15,0]; % waste heat per mode
Qe_modes_val=[tR,tR,tR,tR,tR,0]; % heater available
modes={'DRILL','DUMP','DRILL','DUMP','DRILL','FAIL'};
dur=[44.8,1.4,44.8,1.4,44.8,200]*3600;

% Run BOTH cases
for case_id=1:2
    if case_id==1
        Gs=0; label='WITHOUT SHUNT';
    else
        Gs=shunt.G_margin; label='WITH SHUNT (1.5x oversized)';
    end
    fprintf('\n  %s (G_shunt=%.4f W/K):\n',label,Gs);
    
    T0=Tweb; tAll=[]; TAll=[]; tOff=0;
    for m=1:6
        Tc=Tf; Qe=Qe_modes_val(m); Qw=Qw_modes_val(m);
        dTdt=@(t,T) therm_ode_shunt(T,Tc,Qlw,Qe,Qw,Tweb,...
            Gc,wA,mN,mE,mCs,mCr,mDeg,wC,Gs,shunt.T_on,shunt.T_off);
        [ts,Ts]=ode45(dTdt,[0 dur(m)],T0,opts);
        tAll=[tAll;ts+tOff]; TAll=[TAll;Ts];
        T0=Ts(end); tOff=tOff+dur(m);
        fprintf('    %s: %.1fK -> %.1fK (max %.1fK)\n',...
            modes{m},Ts(1),Ts(end),max(Ts));
    end
    
    % Store for plotting
    if case_id==1, tNS=tAll; TNS=TAll; end
    if case_id==2, tWS=tAll; TWS=TAll; end
end

% Transit (battery, T_amb=25K)
fprintf('\n  TRANSIT (battery, T_amb=25K, with shunt):\n');
for Nl=[4 6 8]
    Qi=Nl*lwP;
    dTdt_t=@(t,T) therm_ode_shunt(T,Tw,Qi,tR,0,Tweb,...
        Gc,wA,mN,mE,mCs,mCr,mDeg,wC,shunt.G_margin,shunt.T_on,shunt.T_off);
    [tt,Tt]=ode45(dTdt_t,[0 6*3600],Tweb,opts);
    T47=interp1(tt/3600,Tt,4.7);
    fprintf('    %d LWRHU + batt: T@4.7hr=%.1fK T@6hr=%.1fK\n',Nl,T47,Tt(end));
end

% Power failure (LWRHU only, shunt auto-disengages)
fprintf('\n  POWER FAILURE (LWRHU only, T_amb=40K, shunt present):\n');
fprintf('  N  | T@24hr | T@72hr | T@200hr | t(253K)\n');
fprintf('  %s\n',repmat('-',1,50));
for Nl=[0 4 6 8 10]
    Qi=Nl*lwP;
    dTdt_f=@(t,T) therm_ode_shunt(T,Tf,Qi,0,0,Tweb,...
        Gc,wA,mN,mE,mCs,mCr,mDeg,wC,shunt.G_margin,shunt.T_on,shunt.T_off);
    [tp,Tp]=ode45(dTdt_f,[0 200*3600],Tweb,opts);
    T24=interp1(tp/3600,Tp,24); T72=interp1(tp/3600,Tp,72); T200=Tp(end);
    i253=find(Tp<253,1);
    if isempty(i253),s253='NEVER';else,s253=sprintf('%.0fhr',tp(i253)/3600);end
    fprintf('  %2d | %.1fK | %.1fK | %.1fK  | %s\n',Nl,T24,T72,T200,s253);
end

%% S9 — WASTE HEAT SENSITIVITY (NEW in v1.2)
fprintf('\n== S9: Waste heat sensitivity (with oversized shunt) ==\n');
G_total_shunted = Gweb + shunt.G_margin;
fprintf('  G_total (web+shunt): %.4f W/K\n', G_total_shunted);
fprintf('  Waste heat | Total Q_in | T_eq (drilling) | Status\n');
fprintf('  %s\n',repmat('-',1,55));
for Qw_t=[0 5 10 15 20 25 30]
    Q_in=Qlw+Qw_t; Teq=Tf+Q_in/G_total_shunted;
    if Teq<280, st='NOMINAL'; elseif Teq<310, st='ACCEPTABLE'; else, st='HIGH'; end
    fprintf('    %4dW    | %6.1fW    | %6.1fK          | %s\n',Qw_t,Q_in,Teq,st);
end

%% S10 — MLI DEGRADE vs LWRHU SENSITIVITY (unchanged logic)
fprintf('\n== S10: MLI degrade vs LWRHU (LWRHU-only, shunt OFF) ==\n');
dg=1.0:0.5:5.0; Nr=4:10; Qco=Qsub-QH;
fprintf('  Deg  ');for N=Nr,fprintf('|%2dLW',N);end;fprintf('\n');
fprintf('  %s\n',repmat('-',1,60));
Teq_map=zeros(length(dg),length(Nr));
for di=1:length(dg)
    Qmd=qmli*wA*dg(di); Qtd=(Qco+Qmd)*1.30; Gd=Qtd/dT;
    fprintf('  %4.1f ',dg(di));
    for ni=1:length(Nr)
        Teq=Tf+Nr(ni)*lwP/Gd; Teq_map(di,ni)=Teq;
        if Teq<250,f='!';else,f=' ';end
        fprintf('|%s%3.0f ',f,Teq);
    end
    fprintf('\n');
end
fprintf('  (! = below 250K Li-ion threshold)\n');

%% S11 — CONTROL SYSTEM REQUIREMENTS (updated for shunt)
fprintf('\n== S11: Thermal control requirements ==\n');
fprintf('  SENSORS: 8 WEB internal + 10 external = 18 channels\n');
fprintf('  HEATER CIRCUITS: 10 switched (WEB, 6x gbx, drill, conn, VEX)\n');
fprintf('  WEB THERMOSTAT: bang-bang 273+/-2K, ~15W max element\n');
fprintf('  THERMAL SHUNT: fully passive (wax switch), no control needed\n');
fprintf('  DOCKING: passive funnel-cradle, rear prox sensors, PLC confirm\n');
fprintf('  CONSTRUCTION TETHER: heated drum at support base,\n');
fprintf('    same funnel-cradle geometry, auto-spool after disconnect\n');
fprintf('  NO ARM OR MANIPULATOR REQUIRED\n');

%% FIGURES (8)
cb=[.18 .55 .82]; cr=[.85 .32 .24]; cg=[.30 .65 .30];
ca=[.92 .65 .15]; cp=[.55 .27 .68]; cy=[.5 .5 .5];

% Fig 1: k(T) curves
figure('Name','Fig 1 - k(T)','Position',[50 50 800 500]);
Tp=linspace(20,300,200);
semilogy(Tp,k_Ti(Tp),'-','Color',cb,'LineWidth',2);hold on;
semilogy(Tp,k_Cu(Tp),'-','Color',cr,'LineWidth',2);
semilogy(Tp,k_SS(Tp),'-','Color',ca,'LineWidth',2);
semilogy(Tp,k_PEEK(Tp),'-','Color',cg,'LineWidth',2);
semilogy(Tp,k_Mn(Tp),'-','Color',cp,'LineWidth',2);
xline(40,'k:','40K');xline(273,'k:','273K');
xlabel('Temperature (K)');ylabel('k (W/m K)');grid on;set(gca,'FontSize',11);
legend('Ti-6Al-4V','Cu','SS304','PEEK','Manganin','Location','northwest');
title('Material Thermal Conductivity');

% Fig 2: Heat loss by path
figure('Name','Fig 2 - Heat Loss','Position',[50 600 900 500]);
bar(Qv,'FaceColor',cb);
set(gca,'XTickLabel',{'Standoff','Drain','Cables','VEX','MLI pen','Valve','Chute','MLI'});
ylabel('Heat Loss (W)');title('WEB Heat Loss by Path (v1.2)');grid on;set(gca,'FontSize',10);
for i=1:8
    text(i,Qv(i)+0.05,sprintf('%.2f',Qv(i)),...
        'HorizontalAlignment','center','FontSize',8);
end

% Fig 3: Multi-mode WITH vs WITHOUT shunt (KEY FIGURE)
figure('Name','Fig 3 - Shunt Comparison','Position',[900 50 1100 600]);
plot(tNS/3600,TNS,'r-','LineWidth',2,'DisplayName','No shunt');hold on;
plot(tWS/3600,TWS,'b-','LineWidth',2,'DisplayName','With shunt');
yline(253,'r--','253K','LineWidth',1,'FontSize',9);
yline(273,'g:','273K setpoint','LineWidth',1,'FontSize',9);
yline(shunt.T_on,'Color',[.5 .5 .5],'LineStyle',':','LineWidth',1);
text(5,shunt.T_on+1.5,'shunt ON','FontSize',8,'Color',cy);

% Mode shading
tb=[0;cumsum(dur(:))/3600]; yl=ylim;
mc={[.8 .9 1],[1 .9 .8],[.8 .9 1],[1 .9 .8],[.8 .9 1],[1 .8 .8]};
for i=1:6
    patch([tb(i) tb(i+1) tb(i+1) tb(i)],[yl(1) yl(1) yl(2) yl(2)],...
        mc{i},'FaceAlpha',.12,'EdgeColor','none');
    text((tb(i)+tb(i+1))/2,yl(2)-1.5,modes{i},...
        'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
end
xlabel('Time (hours)');ylabel('WEB Temperature (K)');
title('Drilling Thermal Runaway: Shunt vs No Shunt');
legend('Location','northwest');grid on;set(gca,'FontSize',11);

% Fig 4: Power failure survival
figure('Name','Fig 4 - Power Failure','Position',[900 600 900 550]);
hold on;cols=lines(5);
for idx=1:5
    Nl=[0 4 6 8 10]; Ni=Nl(idx);
    dTdt_p=@(t,T) therm_ode_shunt(T,Tf,Ni*lwP,0,0,Tweb,...
        Gc,wA,mN,mE,mCs,mCr,mDeg,wC,shunt.G_margin,shunt.T_on,shunt.T_off);
    [tp,Tp]=ode45(dTdt_p,[0 200*3600],Tweb,opts);
    plot(tp/3600,Tp,'-','LineWidth',2,'Color',cols(idx,:));
end
yline(253,'r--','253K','LineWidth',1.5);yline(40,'k:','40K');
xlabel('Hours after power loss');ylabel('T (K)');
legend('0','4','6','8','10 LWRHU','Location','southwest');
title('Power Failure Survival (shunt auto-disengages)');
xlim([0 200]);grid on;set(gca,'FontSize',11);

% Fig 5: Sensitivity heatmap
figure('Name','Fig 5 - Sensitivity','Position',[50 1150 700 500]);
[X,Y]=meshgrid(Nr,dg);
contourf(X,Y,Teq_map,20);hold on;
contour(X,Y,Teq_map,[250 250],'r-','LineWidth',3);
xlabel('LWRHUs');ylabel('MLI Degrade');title('T_{eq} (K) — LWRHU-only, shunt OFF');
colorbar;colormap(parula);set(gca,'FontSize',11,'XTick',Nr);

% Fig 6: Keep-alive comparison
figure('Name','Fig 6 - Keep-Alive','Position',[800 1150 800 500]);
b6=bar([ka_orig(1:5) ka_real(1:5)],'grouped');
b6(1).FaceColor=cr;b6(2).FaceColor=cg;
set(gca,'XTickLabel',ka_items(1:5));ylabel('Power (W)');
legend('Original spec','v1.2 corrected');
title(sprintf('Keep-Alive: %dW -> %.0fW',tO,tR));
grid on;set(gca,'FontSize',10);

% Fig 7: Waste heat sensitivity
figure('Name','Fig 7 - Waste Heat Sensitivity','Position',[50 700 700 450]);
Qw_sweep=0:1:30;
Teq_ns=Tf+(Qlw+Qw_sweep)/Gweb;
Teq_ws=Tf+(Qlw+Qw_sweep)/G_total_shunted;
plot(Qw_sweep,Teq_ns,'r-','LineWidth',2);hold on;
plot(Qw_sweep,Teq_ws,'b-','LineWidth',2);
yline(273,'g:','273K');yline(310,'r:','310K safe limit');
xline(15,'k--','Design 15W','FontSize',9);
xlabel('Waste Heat Coupling (W)');ylabel('Drilling T_{eq} (K)');
legend('No shunt','With shunt (1.5x)','Location','northwest');
title('Drilling Equilibrium vs Waste Heat');grid on;set(gca,'FontSize',11);

% Fig 8: Shunt ON/OFF state diagram
figure('Name','Fig 8 - Shunt State','Position',[800 700 700 400]);
% Conceptual: show T ranges and shunt behaviour
T_range=40:1:350;
G_eff=zeros(size(T_range));
for i=1:length(T_range)
    if T_range(i)>=shunt.T_on
        G_eff(i)=Gweb+shunt.G_margin;
    else
        G_eff(i)=Gweb;
    end
end
yyaxis left;
area(T_range,G_eff,'FaceColor',[.85 .92 1],'EdgeColor',cb,'LineWidth',2);
ylabel('Effective G (W/K)');ylim([0 0.15]);
yyaxis right;
Q_loss_curve=(T_range-Tf).*G_eff;
plot(T_range,Q_loss_curve,'r-','LineWidth',2);ylabel('Q_{loss} (W)');
xline(shunt.T_on,'k--',sprintf('Shunt ON %dK',shunt.T_on),'FontSize',10);
xline(shunt.T_off,'k:',sprintf('OFF %dK',shunt.T_off),'FontSize',9);
xlabel('WEB Temperature (K)');
title('Variable Conductance: Shunt Engagement');
grid on;set(gca,'FontSize',11);

%% S12 — CONCLUSIONS
fprintf('\n================================================================\n');
fprintf('  v1.2 CONCLUSIONS\n');
fprintf('================================================================\n');
fprintf('  1. WEB heat loss: %.1fW (57W spec -> %.0fx reduction)\n',Qtot,57/Qtot);
fprintf('  2. Drilling waste heat (%.0fW) + 8 LWRHU (%.1fW) = %.1fW input\n',...
    Qw_drill,Qlw,Q_in_drill);
fprintf('     Without shunt: T climbs to >300K (RUNAWAY)\n');
fprintf('     With shunt: T stabilises at ~%.0fK (SAFE)\n',Teq_drill_os);
fprintf('  3. Shunt: n-tetradecane wax switch + %.0fmm^2 Cu strap\n',...
    shunt.A_margin*1e6);
fprintf('     Fully passive. ~50-80g. No power, no control.\n');
fprintf('     Engages >%dK, disengages <%dK.\n',shunt.T_on,shunt.T_off);
fprintf('  4. Power failure: shunt auto-OFF. 8 LWRHU holds >253K\n');
fprintf('     for >200hr. Identical to v1.1.\n');
fprintf('  5. VEX standby: 25W -> 0W (Cu strap from WEB)\n');
fprintf('  6. Keep-alive: %dW -> %.0fW. Battery: %d -> %.0f Wh\n',...
    132,tR,682,tR*4.7*1.10);
fprintf('  7. Passive funnel-cradle docking everywhere. No arm.\n');
fprintf('     Construction tethers: heated drum at support base.\n');
fprintf('  8. 18 sensors + 10 heater circuits + 1 passive shunt.\n');
fprintf('================================================================\n');
fprintf('  8 figures generated.\n');
fprintf('================================================================\n');

%% LOCAL FUNCTIONS
function dTdt=therm_ode_shunt(T,Tc,Qlw,Qe_max,Qw,Tsp,...
    Gc,Aw,mN,mE,mCs,mCr,mD,C,Gs,T_on,T_off)
    % Total heat loss (base + shunt)
    T=max(T,Tc+0.1);
    Q_base=Gc*(T-Tc)+mD*Aw*(mCs*(T-Tc)*((T+Tc)/2)/mN+mCr*mE*(T^4.67-Tc^4.67)/mN);
    if T>T_on,        Q_shunt=Gs*(T-Tc);
    elseif T<T_off,   Q_shunt=0;
    else,              Q_shunt=Gs*(T-Tc)*0.5; % transition band
    end
    Ql=Q_base+Q_shunt;
    % Thermostat
    if T<Tsp-2 && Qe_max>0, Qh=min(Qe_max,max(0,Ql-Qlw-Qw)); else, Qh=0; end
    dTdt=(Qlw+Qh+Qw-Ql)/C;
end

function r=tf(c,t,f), if c, r=t; else, r=f; end, end