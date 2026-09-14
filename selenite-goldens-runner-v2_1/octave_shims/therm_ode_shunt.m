% Hoisted from molei_thermal_v1_3.m for Octave (script-local functions unsupported).
function dTdt=therm_ode_shunt(T,Tc,Qlw,Qe_max,Qw,Tsp,...
    Gc,Aw,mN,mE,mCs,mCr,mD,C,Gs,T_on,T_off)
    T=max(T,Tc+0.1);
    Q_base=Gc*(T-Tc)+mD*Aw*(mCs*(T-Tc)*((T+Tc)/2)/mN+mCr*mE*(T^4.67-Tc^4.67)/mN);
    if T>T_on,        Q_shunt=Gs*(T-Tc);
    elseif T<T_off,   Q_shunt=0;
    else,              Q_shunt=Gs*(T-Tc)*0.5;
    end
    Ql=Q_base+Q_shunt;
    if T<Tsp-2 && Qe_max>0, Qh=min(Qe_max,max(0,Ql-Qlw-Qw)); else, Qh=0; end
    dTdt=(Qlw+Qh+Qw-Ql)/C;
end

