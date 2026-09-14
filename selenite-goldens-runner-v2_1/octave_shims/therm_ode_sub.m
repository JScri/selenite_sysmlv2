% Hoisted from molei_thermal_v1_3.m for Octave (script-local functions unsupported).
function dTdt=therm_ode_sub(T,Tc,Qlw,Gsub,Aw,mN,mE,mCs,mCr,mD,C)
    % Substation ODE: no shunt, no heater, LWRHU only
    T=max(T,Tc+0.1);
    Q_cond=Gsub*(T-Tc);
    Q_rad=mD*Aw*(mCs*(T-Tc)*((T+Tc)/2)/mN+mCr*mE*(T^4.67-Tc^4.67)/mN);
    Ql=Q_cond+Q_rad;
    dTdt=(Qlw-Ql)/C;
end

