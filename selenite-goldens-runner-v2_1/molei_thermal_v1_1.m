%% MOLEI_THERMAL_v1_1.m
%  MOLE-I WEB + Subsystem Thermal Verification
%  v1.1: 49-cond harness, MLI pen, VEX strap, connector, 5-mode transient
%
%  v1.1 corrections from v1:
%    - Realistic cable harness (~49 conductors, not 8)
%    - MLI penetration losses (Gilmore 2002: 0.5 W/group)
%    - Drain valve actuator rod + feed chute thermal bridge
%    - mini-VEX thermal strap coupling
%    - Tether connector analysis (passive funnel-cradle docking)
%    - Multi-mode transient (drilling/dump/transit/construction/failure)
%    - Dump retraction: tether STAYS CONNECTED (drum reels in)
%
%  Author : Jason (Systems Engineering Lead), Selenite Programme
%  Date   : March 2026
%  Ref    : SEL_MOLEI_DESIGN v1, SEL_ROBOT_FLEET v4, VERIFY v4.2

clear; clc; close all;

fprintf('================================================================\n');
fprintf('  MOLE-I THERMAL v1.1\n');
fprintf('  49-cond harness | MLI pen | VEX strap | 5-mode transient\n');
fprintf('================================================================\n\n');

%% S1 — MATERIAL k(T) MODELS
k_Ti   = @(T) max(0.1, -0.341+0.0327*T-4.16e-5*T.^2+2.17e-8*T.^3);
k_Cu   = @(T) max(10, 500-1.2*(T-200).^2/500+50*exp(-(T-30).^2/200));
k_SS   = @(T) max(0.5, -1.40+0.0820*T-1.30e-4*T.^2+8.50e-8*T.^3);
k_PEEK = @(T) 0.20+2.0e-4*T;
k_Mn   = @(T) max(5, 10.0+0.038*T);
QC = @(kf,A,L,Tc,Th) (A/L)*integral(kf,Tc,Th);

Tf=40; Tw=25; Tweb=273; dT=Tweb-Tf;
ki_Ti=integral(k_Ti,Tf,Tweb); ki_PK=integral(k_PEEK,Tf,Tweb);
ka_Ti=ki_Ti/dT; ka_PK=ki_PK/dT;

% WEB geometry & thermal mass
wA=2*(0.55*0.35+0.55*0.35+0.35*0.35); % 1.015 m^2
wC=50*4186+20*700; % 223300 J/K
lwP=1.1; lwM=0.042; % LWRHU power, mass

% MLI parameters
mN=20; mE=0.03; mCs=8.95e-8; mCr=5.39e-10; mDeg=2.0;
Ab=pi/4*(6e-3)^2; % M6 bolt area

fprintf('== S1: k(T) loaded. T_floor=%d T_wall=%d T_web=%d dT=%d K ==\n',Tf,Tw,Tweb,dT);
fprintf('  WEB: A=%.3f m^2, C=%.0f J/K (%.0f Wh/K)\n\n',wA,wC,wC/3600);

%% S2 — WEB HEAT LOSS PATHS (v1.1 corrected)
fprintf('== S2: WEB heat loss ==\n');

% A: 4x PEEK standoffs (20mm OD, 7mm bore, 50mm tall) + bolt washers
pA=pi/4*((20e-3)^2-(7e-3)^2); pL=0.050;
QA1=4*QC(k_PEEK,pA,pL,Tf,Tweb);
hA=pi/4*((10e-3)^2-(6e-3)^2); wL=5e-3; bf=pL-2*wL;
Rw=wL/(ka_PK*hA); Rbo=bf/(ka_Ti*Ab);
QA2=4*dT/(2*Rw+Rbo);
QA=QA1+QA2;

% B: Drain pipe Ti S-bend + 50mm PEEK coupler
dA=pi/4*(20e-3^2-18e-3^2);
RB=2*(0.075/(ka_Ti*dA))+0.050/(ka_PK*dA);
QB=dT/RB;

% C: Cable harness (49 conductors, all Manganin 100mm)
Lm=0.100;
QC_val=6*QC(k_Mn,0.518e-6,Lm,Tf,Tweb)+13*QC(k_Mn,0.326e-6,Lm,Tf,Tweb)+...
       26*QC(k_Mn,0.081e-6,Lm,Tf,Tweb)+4*QC(k_Mn,0.051e-6,Lm,Tf,Tweb);

% D: VEX water tube PEEK coupler 40mm
QD=QC(k_PEEK,pi/4*(10e-3^2-8e-3^2),0.040,Tf,Tweb);

% E: MLI penetrations 5x0.5W (Gilmore 2002)
QE=5*0.5;

% F: Drain valve actuator SS rod 6mm 30mm
QF=QC(k_SS,pi/4*(6e-3)^2,0.030,Tf,Tweb);

% G: Feed chute drill->VEX (SS 30mm OD 2mm wall 100mm, 50% PEEK)
chA=pi/4*(30e-3^2-26e-3^2);
Qch_full=QC(k_SS,chA,0.100,Tf,Tweb);
QG=Qch_full*0.50;

% H: MLI 20-layer 2x degrade
qmli=mCs*(Tweb-Tf)*((Tweb+Tf)/2)/mN+mCr*mE*(Tweb^4.67-Tf^4.67)/mN;
QH=qmli*wA*mDeg;

Qsub=QA+QB+QC_val+QD+QE+QF+QG+QH;
Qmar=Qsub*0.30; Qtot=Qsub+Qmar; Gweb=Qtot/dT;

pn={'A: PEEK standoffs (4x)','B: Drain pipe Ti+PEEK','C: Cables (49 Mn)',...
    'D: VEX tube PEEK','E: MLI penetrations 5x','F: Valve actuator',...
    'G: Feed chute 50%','H: MLI 20-layer'};
Qv=[QA QB QC_val QD QE QF QG QH];

fprintf('\n  %-32s %8s\n','Path','Q (W)');
fprintf('  %s\n',repmat('-',1,44));
for i=1:8, fprintf('  %-32s %8.3f\n',pn{i},Qv(i)); end
fprintf('  %s\n',repmat('-',1,44));
fprintf('  %-32s %8.3f\n','SUBTOTAL',Qsub);
fprintf('  %-32s %8.3f\n','30%% margin',Qmar);
fprintf('  %-32s %8.3f\n','TOTAL',Qtot);
fprintf('\n  G_web = %.5f W/K | Spec 57W -> %.1fx reduction\n',Gweb,57/Qtot);

%% S3 — LWRHU SIZING
fprintf('\n== S3: LWRHU sizing ==\n');
fprintf('  N | Q_in | T_eq(40K) | T_eq(25K) | >250K fl | >250K wl\n');
fprintf('  %s\n',repmat('-',1,60));
for N=3:10
    Qi=N*lwP; Teqf=Tf+Qi/Gweb; Teqw=Tw+Qi/Gweb;
    fprintf('  %d | %.1fW | %6.1fK   | %6.1fK   | %-3s     | %-3s\n',...
        N,Qi,Teqf,Teqw,ternary(Teqf>=250,'YES','no'),ternary(Teqw>=250,'YES','no'));
end
N250=max(ceil(Gweb*(250-Tf)/lwP), ceil(Gweb*(250-Tw)/lwP));
fprintf('  Indefinite 250K hold (both cases): %d LWRHU (%.1fW)\n',N250,N250*lwP);
fprintf('  8 LWRHU: floor %.0fK, wall %.0fK — extended survival, not indefinite\n',...
    Tf+8*lwP/Gweb, Tw+8*lwP/Gweb);

%% S4 — MINI-VEX THERMAL STRAP
fprintf('\n== S4: mini-VEX thermal strap ==\n');
Tvex=200; dTv=Tvex-Tf; sc=dTv/dT;

% VEX mounts: 4x PEEK (15mm OD, 30mm)
Qvm=4*QC(k_PEEK,pi/4*((15e-3)^2-(6e-3)^2),0.030,Tf,Tweb)*sc;
% VEX MLI (10-layer, 2.5x degrade)
qvm=mCs*(Tvex-Tf)*((Tvex+Tf)/2)/10+mCr*mE*(Tvex^4.67-Tf^4.67)/10;
Qvl=qvm*0.15*2.5;
% Feed chute at VEX temp
Qvc=Qch_full*sc;
Qvx_loss=Qvm+Qvl+Qvc;

% Cu braid strap 25x3mm, 150mm, 40% fill
dTs=Tweb-Tvex;
kCus=integral(k_Cu,Tvex,Tweb)/dTs;
Qstrap=0.40*kCus*(25e-3*3e-3)*dTs/0.150;
Qvx_draw=min(Qstrap,Qvx_loss);
Qvx_htr=max(0,Qvx_loss-Qstrap);

fprintf('  VEX loss at %dK: mount %.3f + MLI %.3f + chute %.3f = %.2fW\n',...
    Tvex,Qvm,Qvl,Qvc,Qvx_loss);
fprintf('  Strap capacity: %.2fW (need %.2fW) -> residual heater: %.2fW\n',...
    Qstrap,Qvx_loss,Qvx_htr);
fprintf('  Strap draws %.2fW from WEB -> WEB heater compensates\n',Qvx_draw);

%% S5 — TETHER CONNECTOR
fprintf('\n== S5: Tether connector ==\n');
dTc=100-Tf; % 60K to reach 100K target
Qcf_Ti=(pi/4*(40e-3)^2/3e-3)*integral(k_Ti,Tf,100);
Qcf_PK=(pi/4*(40e-3)^2/5e-3)*integral(k_PEEK,Tf,100);
Qcc_Cu=2*(2.08e-6/0.050)*integral(k_Cu,Tf,100);
Qcc_Mn=2*(2.08e-6/0.100)*integral(k_Mn,Tf,100);

fprintf('  Flange Ti direct: %.1fW | PEEK spacer: %.2fW\n',Qcf_Ti,Qcf_PK);
fprintf('  Cable Cu 50mm: %.2fW | Mn 100mm: %.4fW\n',Qcc_Cu,Qcc_Mn);
fprintf('  PEEK+Mn total: %.2fW (spec 5W — reasonable)\n',Qcf_PK+Qcc_Mn);
fprintf('  Docking: passive funnel-cradle, push-to-lock bayonet\n');
fprintf('  No arm needed. Tether stays on during dump retraction.\n');
fprintf('  Disconnect only during construction hops (1st unit/branch).\n');

%% S6 — KEEP-ALIVE BUDGET
fprintf('\n== S6: Keep-alive budget ==\n');
ka_web=Qtot+Qvx_draw;  % WEB heater must also supply VEX strap
ka_items={'WEB heater';'Gearbox 6x5W';'Drill bearing';'Receptacle';'VEX standby'};
ka_orig=[57;30;15;5;25]; ka_real=[ka_web;30;15;5;Qvx_htr]; ka_opt=[ka_web;30;15;0;0];

fprintf('  %-24s | %7s | %9s | %10s\n','Subsystem','Original','Realistic','Optimistic');
fprintf('  %s\n',repmat('-',1,60));
for i=1:5
    fprintf('  %-24s | %6.1fW | %8.1fW | %9.1fW\n',...
        ka_items{i},ka_orig(i),ka_real(i),ka_opt(i));
end
tO=sum(ka_orig); tR=sum(ka_real); tP=sum(ka_opt);
fprintf('  %s\n',repmat('-',1,60));
fprintf('  %-24s | %6.0fW | %8.0fW | %9.0fW\n','TOTAL',tO,tR,tP);
fprintf('  %-24s | %6s | %8s | %9s\n','LWRHUs','8x1.1','8x1.1','8x1.1');

fprintf('\n  Transit battery (KA x 4.7hr x 1.10):\n');
for v={'Original',tO;'Realistic',tR;'Optimistic',tP}'
    b=v{2}*4.7*1.10; fprintf('    %s: %.0fW -> %.0f Wh (%.1f kg)\n',v{1},v{2},b,b/250);
end

%% S7 — MULTI-MODE TRANSIENT (ODE45)
fprintf('\n== S7: Multi-mode transient ==\n');

Gc=(Qsub-QH)/dT; % conduction-only conductance

% Waste heat coupling during drilling
Qw_drill=200*0.05+5; % 10W drill + 5W VEX reverse strap
Qw_dump=0; Qw_none=0;

Nlw=8; Qlw=Nlw*lwP;
opts=odeset('RelTol',1e-6,'AbsTol',1e-4,'MaxStep',300);

% Sequence: 3x [drill 44.8hr + dump 1.4hr] then power fail 200hr
modes={'DRILL','DUMP','DRILL','DUMP','DRILL','FAIL'};
dur=[44.8,1.4,44.8,1.4,44.8,200]*3600;
Qe_mode=[tR,tR,tR,tR,tR,0]; % electric heater available
Qw_mode=[Qw_drill,Qw_dump,Qw_drill,Qw_dump,Qw_drill,Qw_none];

T0=Tweb; tAll=[]; TAll=[]; tOff=0;
for m=1:6
    Tc_m=Tf; Qe_m=Qe_mode(m); Qw_m=Qw_mode(m);
    dTdt=@(t,T) therm_ode(T,Tc_m,Qlw,Qe_m,Qw_m,Tweb,Gc,wA,mN,mE,mCs,mCr,mDeg,wC);
    [ts,Ts]=ode45(dTdt,[0 dur(m)],T0,opts);
    tAll=[tAll;ts+tOff]; TAll=[TAll;Ts];
    T0=Ts(end); tOff=tOff+dur(m);
    fprintf('  %s: %.1fK -> %.1fK (%.1fhr)\n',modes{m},Ts(1),Ts(end),dur(m)/3600);
end

% Transit standalone (Mode 4)
fprintf('\n  TRANSIT (battery, T_amb=25K):\n');
for Nl=[4 6 8]
    Qi=Nl*lwP;
    dTdt_t=@(t,T) therm_ode(T,Tw,Qi,tR,0,Tweb,Gc,wA,mN,mE,mCs,mCr,mDeg,wC);
    [tt,Tt]=ode45(dTdt_t,[0 6*3600],Tweb,opts);
    T47=interp1(tt/3600,Tt,4.7);
    fprintf('    %d LWRHU + batt KA: T@4.7hr=%.1fK T@6hr=%.1fK\n',Nl,T47,Tt(end));
end

% Power failure (Mode 5)
fprintf('\n  POWER FAILURE (LWRHU only, T_amb=40K):\n');
fprintf('  N | T@24hr | T@72hr | T@200hr | t(253K)\n');
fprintf('  %s\n',repmat('-',1,50));
for Nl=[0 4 6 8 10]
    Qi=Nl*lwP;
    dTdt_f=@(t,T) therm_ode(T,Tf,Qi,0,0,Tweb,Gc,wA,mN,mE,mCs,mCr,mDeg,wC);
    [tp,Tp]=ode45(dTdt_f,[0 200*3600],Tweb,opts);
    T24=interp1(tp/3600,Tp,24); T72=interp1(tp/3600,Tp,72); T200=Tp(end);
    i253=find(Tp<253,1);
    if isempty(i253), s253='NEVER'; else, s253=sprintf('%.0fhr',tp(i253)/3600); end
    fprintf('  %2d | %.1f | %.1f | %.1f  | %s\n',Nl,T24,T72,T200,s253);
end

%% S8 — CONTROL SYSTEM REQUIREMENTS
fprintf('\n== S8: Thermal control requirements ==\n');
fprintf('  SENSORS: 8 channels WEB internal (Pt100 RTDs)\n');
fprintf('           10 channels external (gearbox, drill, conn, VEX)\n');
fprintf('  HEATER CIRCUITS: 10 switched (WEB, 6x gbx, drill, conn, VEX)\n');
fprintf('  WEB THERMOSTAT: bang-bang 273+/-2K or PID (~15W max element)\n');
fprintf('  DOCKING: passive funnel-cradle, rear prox sensors, PLC confirm\n');
fprintf('  NO ARM OR MANIPULATOR REQUIRED\n');

%% S9 — SENSITIVITY
fprintf('\n== S9: Sensitivity ==\n');
dg=1.0:0.5:5.0; Nr=4:10; Qco=Qsub-QH;
fprintf('  Degrade');for N=Nr,fprintf('|%2dLW',N);end;fprintf('\n');
fprintf('  %s\n',repmat('-',1,60));
Teq_map=zeros(length(dg),length(Nr));
for di=1:length(dg)
    Qmd=qmli*wA*dg(di); Qtd=(Qco+Qmd)*1.30; Gd=Qtd/dT;
    fprintf('  %4.1f  ',dg(di));
    for ni=1:length(Nr)
        Teq=Tf+Nr(ni)*lwP/Gd; Teq_map(di,ni)=Teq;
        if Teq<250,f='!';else,f=' ';end
        fprintf('|%s%3.0f ',f,Teq);
    end
    fprintf('\n');
end
fprintf('  (! = below 250K)\n');

%% FIGURES (6)
cb=[.18 .55 .82];cr=[.85 .32 .24];cg=[.30 .65 .30];ca=[.92 .65 .15];cp=[.55 .27 .68];

% Fig 1: k(T)
figure('Name','Fig 1 - k(T)','Position',[50 50 800 500]);
Tp=linspace(20,300,200);
semilogy(Tp,k_Ti(Tp),'-','Color',cb,'LineWidth',2);hold on;
semilogy(Tp,k_Cu(Tp),'-','Color',cr,'LineWidth',2);
semilogy(Tp,k_SS(Tp),'-','Color',ca,'LineWidth',2);
semilogy(Tp,k_PEEK(Tp),'-','Color',cg,'LineWidth',2);
semilogy(Tp,k_Mn(Tp),'-','Color',cp,'LineWidth',2);
xline(40,'k:','40K');xline(273,'k:','273K');
xlabel('Temperature (K)');ylabel('k (W/m K)');grid on;set(gca,'FontSize',11);
legend('Ti-6Al-4V','Cu','SS304','PEEK','Manganin','Location','nw');
title('Material Thermal Conductivity');

% Fig 2: Heat loss by path
figure('Name','Fig 2 - Heat Loss','Position',[50 600 900 500]);
bar(Qv,'FaceColor',cb);
set(gca,'XTickLabel',{'Standoff','Drain','Cables','VEX','MLI pen','Valve','Chute','MLI'});
ylabel('Heat Loss (W)');title('WEB Heat Loss by Path (v1.1)');grid on;set(gca,'FontSize',10);
for i=1:8,text(i,Qv(i)+0.05,sprintf('%.2f',Qv(i)),'HorizontalAlignment','center','FontSize',8);end

% Fig 3: Multi-mode transient
figure('Name','Fig 3 - Multi-Mode','Position',[900 50 1000 550]);
plot(tAll/3600,TAll,'b-','LineWidth',2);hold on;
yline(253,'r--','253K','LineWidth',1.5);yline(273,'g:','273K');
tb=[0;cumsum(dur(:))/3600];
mc={[.8 .9 1],[1 .9 .8],[.8 .9 1],[1 .9 .8],[.8 .9 1],[1 .8 .8]};
yl=ylim;
for i=1:6
    patch([tb(i) tb(i+1) tb(i+1) tb(i)],[yl(1) yl(1) yl(2) yl(2)],...
        mc{i},'FaceAlpha',.15,'EdgeColor','none');
    text((tb(i)+tb(i+1))/2,yl(2)-2,modes{i},'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
end
xlabel('Time (hours)');ylabel('WEB Temperature (K)');
title('3 Drill-Dump Cycles + Power Failure');grid on;set(gca,'FontSize',11);

% Fig 4: Power failure survival
figure('Name','Fig 4 - Power Failure','Position',[900 600 900 550]);
hold on;cols=lines(5);
for idx=1:5
    Nl=[0 4 6 8 10]; Ni=Nl(idx);
    dTdt_p=@(t,T) therm_ode(T,Tf,Ni*lwP,0,0,Tweb,Gc,wA,mN,mE,mCs,mCr,mDeg,wC);
    [tp,Tp]=ode45(dTdt_p,[0 200*3600],Tweb,opts);
    plot(tp/3600,Tp,'-','LineWidth',2,'Color',cols(idx,:));
end
yline(253,'r--','253K','LineWidth',1.5);yline(40,'k:','40K');
xlabel('Hours');ylabel('T (K)');legend('0','4','6','8','10 LWRHU','Location','sw');
title('Power Failure Survival');xlim([0 200]);grid on;set(gca,'FontSize',11);

% Fig 5: Sensitivity heatmap
figure('Name','Fig 5 - Sensitivity','Position',[50 1200 700 500]);
[X,Y]=meshgrid(Nr,dg);
contourf(X,Y,Teq_map,20);hold on;
contour(X,Y,Teq_map,[250 250],'r-','LineWidth',3);
xlabel('LWRHUs');ylabel('MLI Degrade');title('T_{eq} (K)');
colorbar;colormap(parula);set(gca,'FontSize',11,'XTick',Nr);

% Fig 6: Keep-alive comparison
figure('Name','Fig 6 - Keep-Alive','Position',[800 1200 800 500]);
b6=bar([ka_orig ka_real],'grouped');
b6(1).FaceColor=cr;b6(2).FaceColor=cg;
set(gca,'XTickLabel',ka_items);ylabel('Power (W)');
legend('Original','v1.1');
title(sprintf('Keep-Alive: %dW -> %.0fW',sum(ka_orig),sum(ka_real)));
grid on;set(gca,'FontSize',10);

%% S10 — CONCLUSIONS
fprintf('\n================================================================\n');
fprintf('  v1.1 CONCLUSIONS\n');
fprintf('================================================================\n');
fprintf('  1. WEB loss: %.1fW (was 57W spec, 3.2W in v1)\n',Qtot);
fprintf('  2. 57W spec was %.0fx too high\n',57/Qtot);
fprintf('  3. VEX standby 25W -> %.1fW (Cu strap from WEB)\n',Qvx_htr);
fprintf('  4. Keep-alive: %dW -> %.0fW (batt %.0f->%.0f Wh)\n',132,tR,682,tR*4.7*1.10);
fprintf('  5. 8 LWRHU T_eq=%.0fK. Not indefinite >250K.\n',Tf+8*lwP/Gweb);
fprintf('     But >200hr before 253K. Role = rate reducer, not heater.\n');
fprintf('  6. Passive funnel-cradle dock. No arm. Tether stays on for dump.\n');
fprintf('  7. 18 sensors + 10 heater circuits. Thermostat ~15W max.\n');
fprintf('================================================================\n');
fprintf('  6 figures generated.\n');
fprintf('================================================================\n');

%% LOCAL FUNCTIONS
function dTdt=therm_ode(T,Tc,Qlw,Qe_max,Qw,Tsp,Gc,Aw,mN,mE,mCs,mCr,mD,C)
    T=max(T,Tc+0.1);
    Ql=Gc*(T-Tc)+mD*Aw*(mCs*(T-Tc)*((T+Tc)/2)/mN+mCr*mE*(T^4.67-Tc^4.67)/mN);
    if T<Tsp-2 && Qe_max>0, Qh=min(Qe_max,max(0,Ql-Qlw-Qw)); else, Qh=0; end
    dTdt=(Qlw+Qh+Qw-Ql)/C;
end

function r=ternary(c,t,f), if c, r=t; else, r=f; end, end