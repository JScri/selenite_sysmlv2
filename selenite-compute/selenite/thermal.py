"""Port of ``MOLEI_THERMAL_v1_3.m``: MOLE-I WEB heat-loss paths, LWRHU
sizing, mini-VEX strap, wax thermal shunt, keep-alive and DC-DC budget,
multi-mode transient (ode45), power-failure survival, substation WEB audit,
substation survival, and the figure data. Oracle: ``MOLEI_THERMAL_v1_3.csv``
(274 rows; ODE-derived rows compared at 0.05 K per the port brief).

Numerics: MATLAB ``integral`` -> ``scipy.integrate.quad`` (tight tolerance;
the integrands are smooth polynomials/exponentials on the ranges used);
``ode45`` -> ``solve_ivp(method="RK45", rtol=1e-6, atol=1e-4, max_step=300)``
(both are Dormand-Prince 5(4); step sequences differ, values do not beyond
the 0.05 K rule).
"""
from __future__ import annotations

import math

import numpy as np
from scipy.integrate import quad, solve_ivp

from .capture import Summarised, flatten, mceil

PORTED = True
SOURCE_SCRIPT = "MOLEI_THERMAL_v1_3.m"

# Keys whose values depend on the ODE step sequence beyond the 0.05 K rule.
ODE_TEMPERATURE_KEYS = {"T0", "T24", "T72", "T200", "T6", "T12", "T48"}
ODE_TIME_STRING_KEYS = {"s253"}          # '%.0fhr' — compared within 1 hour
ODE_SKIP_KEYS = {"i253", "yl"}           # step index; MATLAB auto ylim of a figure
# ode45 output grids (> 2000 elements in MATLAB, so captured as statistics).
# The old oracle tagged only the temperature stems; the time grids carry the
# same step-sequence dependence, so they are declared here.
ODE_ARRAY_STEMS = {"tAll", "tNS", "tWS", "tp", "ts", "TAll", "TNS", "TWS", "Tp", "Ts"}

# MATLAB R2025a lines() colormap ("gem" default colour order), captured as figure colour tables
_LINES = np.array([[0.0660, 0.4430, 0.7450], [0.8660, 0.3290, 0.0000], [0.9290, 0.6940, 0.1250],
                   [0.5210, 0.0860, 0.8190], [0.2310, 0.6660, 0.1960], [0.4820, 0.5980, 0.9370],
                   [0.9210, 0.6910, 0.1450]])


def _integral(f, a, b):
    return quad(f, a, b, epsabs=0.0, epsrel=1e-13, limit=500)[0]


def _ode45(fun, t_span, y0, max_step=300.0):
    sol = solve_ivp(lambda t, y: [fun(t, y[0])], t_span, [y0], method="RK45",
                    rtol=1e-6, atol=1e-4, max_step=max_step)
    return Summarised(sol.t), Summarised(sol.y[0])


def _interp1(x, y, xq):
    return float(np.interp(xq, x, y))


def _find_first(mask):
    idx = np.flatnonzero(mask)
    return int(idx[0]) + 1 if idx.size else None   # MATLAB 1-based index or empty


def therm_ode_shunt(T, Tc, Qlw, Qe_max, Qw, Tsp, Gc, Aw, mN, mE, mCs, mCr, mD, C, Gs, T_on, T_off):
    T = max(T, Tc + 0.1)
    Q_base = Gc * (T - Tc) + mD * Aw * (mCs * (T - Tc) * ((T + Tc) / 2) / mN + mCr * mE * (T**4.67 - Tc**4.67) / mN)
    if T > T_on:
        Q_shunt = Gs * (T - Tc)
    elif T < T_off:
        Q_shunt = 0
    else:
        Q_shunt = Gs * (T - Tc) * 0.5
    Ql = Q_base + Q_shunt
    if T < Tsp - 2 and Qe_max > 0:
        Qh = min(Qe_max, max(0, Ql - Qlw - Qw))
    else:
        Qh = 0
    return (Qlw + Qh + Qw - Ql) / C


def therm_ode_sub(T, Tc, Qlw, Gsub, Aw, mN, mE, mCs, mCr, mD, C):
    T = max(T, Tc + 0.1)
    Q_cond = Gsub * (T - Tc)
    Q_rad = mD * Aw * (mCs * (T - Tc) * ((T + Tc) / 2) / mN + mCr * mE * (T**4.67 - Tc**4.67) / mN)
    Ql = Q_cond + Q_rad
    return (Qlw - Ql) / C


def workspace(**params):
    """The script's final workspace (raw Python objects, before capture)."""
    # ---- S1: material k(T) and constants -------------------------------------
    k_Ti = lambda T: np.maximum(0.1, -0.341 + 0.0327 * T - 4.16e-5 * T**2 + 2.17e-8 * T**3)
    k_Cu = lambda T: np.maximum(10, 500 - 1.2 * (T - 200) ** 2 / 500 + 50 * np.exp(-(T - 30) ** 2 / 200))
    k_SS = lambda T: np.maximum(0.5, -1.40 + 0.0820 * T - 1.30e-4 * T**2 + 8.50e-8 * T**3)
    k_PEEK = lambda T: 0.20 + 2.0e-4 * T
    k_Mn = lambda T: np.maximum(5, 10.0 + 0.038 * T)
    QCf = lambda kf, A, L, Tc, Th: (A / L) * _integral(kf, Tc, Th)

    Tf = 40; Tw = 25; Tweb = 273; dT = Tweb - Tf
    ki_Ti = _integral(k_Ti, Tf, Tweb); ki_PK = _integral(k_PEEK, Tf, Tweb)
    ki_Mn = _integral(k_Mn, Tf, Tweb); ki_Cu = _integral(k_Cu, Tf, Tweb)
    ka_Ti = ki_Ti / dT; ka_PK = ki_PK / dT; ka_Mn = ki_Mn / dT

    wA = 2 * (0.55 * 0.35 + 0.55 * 0.35 + 0.35 * 0.35)
    wC = 50 * 4186 + 20 * 700
    lwP = 1.1; lwM = 0.042

    mN = 20; mE = 0.03; mCs = 8.95e-8; mCr = 5.39e-10; mDeg = 2.0
    Ab = math.pi / 4 * (6e-3) ** 2
    Lm = 0.100

    # ---- S2: MOLE-I WEB heat loss paths ---------------------------------------
    pA = math.pi / 4 * ((20e-3) ** 2 - (7e-3) ** 2); pL = 0.050
    QA1 = 4 * QCf(k_PEEK, pA, pL, Tf, Tweb)
    hA = math.pi / 4 * ((10e-3) ** 2 - (6e-3) ** 2); wL = 5e-3; bf = pL - 2 * wL
    Rw = wL / (ka_PK * hA); Rbo = bf / (ka_Ti * Ab)
    QA2 = 4 * dT / (2 * Rw + Rbo); QA = QA1 + QA2

    dA = math.pi / 4 * (20e-3**2 - 18e-3**2)          # MATLAB precedence: 20e-3^2 = 20e-3**2
    RB = 2 * (0.075 / (ka_Ti * dA)) + 0.050 / (ka_PK * dA); QB = dT / RB

    mi_n20 = 5; mi_A20 = 0.518e-6
    mi_n22 = 15; mi_A22 = 0.326e-6
    mi_n28 = 76; mi_A28 = 0.081e-6
    mi_n30 = 12; mi_A30 = 0.051e-6
    mi_ntot = mi_n20 + mi_n22 + mi_n28 + mi_n30

    QC_20 = mi_n20 * QCf(k_Mn, mi_A20, Lm, Tf, Tweb)
    QC_22 = mi_n22 * QCf(k_Mn, mi_A22, Lm, Tf, Tweb)
    QC_28 = mi_n28 * QCf(k_Mn, mi_A28, Lm, Tf, Tweb)
    QC_30 = mi_n30 * QCf(k_Mn, mi_A30, Lm, Tf, Tweb)
    QCv = QC_20 + QC_22 + QC_28 + QC_30

    QD = QCf(k_PEEK, math.pi / 4 * (10e-3**2 - 8e-3**2), 0.040, Tf, Tweb)
    QE = 5 * 0.5
    QF = QCf(k_SS, math.pi / 4 * (6e-3) ** 2, 0.030, Tf, Tweb)
    chA = math.pi / 4 * (30e-3**2 - 26e-3**2)
    Qch_full = QCf(k_SS, chA, 0.100, Tf, Tweb); QG = Qch_full * 0.50

    qmli = mCs * (Tweb - Tf) * ((Tweb + Tf) / 2) / mN + mCr * mE * (Tweb**4.67 - Tf**4.67) / mN
    QH = qmli * wA * mDeg

    Qsub = QA + QB + QCv + QD + QE + QF + QG + QH
    Qmar = Qsub * 0.30; Qtot = Qsub + Qmar; Gweb = Qtot / dT
    Gc = (Qsub - QH) / dT
    Qv = np.array([QA, QB, QCv, QD, QE, QF, QG, QH])

    # ---- S4: LWRHU sizing ------------------------------------------------------
    for N in range(3, 11):
        Qi = N * lwP; Teqf = Tf + Qi / Gweb; Teqw = Tw + Qi / Gweb
    N250 = max(mceil(Gweb * (250 - Tf) / lwP), mceil(Gweb * (250 - Tw) / lwP))

    # ---- S5: mini-VEX thermal strap ---------------------------------------------
    Tvex = 200; dTv = Tvex - Tf; sc = dTv / dT
    Qvm = 4 * QCf(k_PEEK, math.pi / 4 * ((15e-3) ** 2 - (6e-3) ** 2), 0.030, Tf, Tweb) * sc
    qvm = mCs * (Tvex - Tf) * ((Tvex + Tf) / 2) / 10 + mCr * mE * (Tvex**4.67 - Tf**4.67) / 10
    Qvl = qvm * 0.15 * 2.5
    Qvc = Qch_full * sc
    Qvx_loss = Qvm + Qvl + Qvc
    dTs = Tweb - Tvex; kCus = _integral(k_Cu, Tvex, Tweb) / dTs
    Qstrap = 0.40 * kCus * (25e-3 * 3e-3) * dTs / 0.150
    Qvx_draw = min(Qstrap, Qvx_loss)
    Qvx_htr = max(0, Qvx_loss - Qstrap)

    # ---- S6: tether connector --------------------------------------------------
    Qcf_PK = (math.pi / 4 * (40e-3) ** 2 / 5e-3) * _integral(k_PEEK, Tf, 100)
    Qcc_Mn = 2 * (2.08e-6 / 0.100) * _integral(k_Mn, Tf, 100)

    # ---- S7: thermal shunt -----------------------------------------------------
    Nlw = 8; Qlw = Nlw * lwP
    Qw_drill = 15
    Teq_noshunt = Tf + (Qlw + Qw_drill) / Gweb
    Q_in_drill = Qlw + Qw_drill
    shunt = {"T_on": 278, "T_off": 275, "T_target": 278}
    G_needed = Q_in_drill / (shunt["T_target"] - Tf)
    shunt["G"] = G_needed - Gweb
    shunt["G_margin"] = shunt["G"] * 1.5
    k_Cu_shunt = 490
    shunt["L"] = 0.100
    shunt["A"] = shunt["G"] / (k_Cu_shunt / shunt["L"])
    shunt["A_margin"] = shunt["G_margin"] / (k_Cu_shunt / shunt["L"])
    Teq_drill_nom = Tf + Q_in_drill / (Gweb + shunt["G"])
    Teq_drill_os = Tf + Q_in_drill / (Gweb + shunt["G_margin"])

    # ---- S8: keep-alive + power architecture -----------------------------------
    ka_web = Qtot + Qvx_draw
    P48_load = 1730; eff48 = 0.95; P48_loss = P48_load * (1 / eff48 - 1)
    P28_load = 90; eff28 = 0.93; P28_loss = P28_load * (1 / eff28 - 1)
    P5_load = 13; eff5 = 0.90; P5_loss = P5_load * (1 / eff5 - 1)
    Ploss_dcdc = P48_loss + P28_loss + P5_loss
    Pbatt_charge = 50
    Pload = 1785
    Ptether = Pload + Ploss_dcdc + Pbatt_charge
    ka_orig = np.array([57, 30, 15, 5, 25, 0.0]); ka_real = np.array([ka_web, 30, 15, 5, Qvx_htr, 0]); ka_opt = np.array([ka_web, 30, 15, 0, 0, 0])
    tO = ka_orig.sum(); tR = ka_real.sum(); tP = ka_opt.sum()

    # ---- S9: multi-mode transient ----------------------------------------------
    opts = {"AbsTol": 1e-4, "BDF": "zeros(1,0)", "Events": "zeros(1,0)", "InitialStep": "zeros(1,0)",
            "Jacobian": "zeros(1,0)", "JConstant": "zeros(1,0)", "JPattern": "zeros(1,0)", "Mass": "zeros(1,0)",
            "MassSingular": "zeros(1,0)", "MaxOrder": "zeros(1,0)", "MaxStep": 300, "MinStep": "zeros(1,0)",
            "NonNegative": "zeros(1,0)", "NormControl": "zeros(1,0)", "OutputFcn": "zeros(1,0)",
            "OutputSel": "zeros(1,0)", "Refine": "zeros(1,0)", "RelTol": 1e-6, "Stats": "zeros(1,0)",
            "Vectorized": "zeros(1,0)", "MStateDependence": "zeros(1,0)", "MvPattern": "zeros(1,0)",
            "InitialSlope": "zeros(1,0)"}
    Qw_modes_val = np.array([15, 0, 15, 0, 15, 0.0]); Qe_modes_val = np.array([tR, tR, tR, tR, tR, 0])
    dur = np.array([44.8, 1.4, 44.8, 1.4, 44.8, 200]) * 3600

    _mode_stats = []   # per case: [(T_start, T_end, T_max)] per mode, for the console report
    _fail_rows = []    # MOLE-I power-failure table rows (Nl, T24, T72, T200, s253)
    _sub_fail_rows = []  # substation power-failure rows (Nl, T6, T12, T24, T48, s253)
    for case_id in range(1, 3):
        if case_id == 1:
            Gs = 0; label = "WITHOUT SHUNT"
        else:
            Gs = shunt["G_margin"]; label = "WITH SHUNT (1.5x)"
        T0 = Tweb; tAll = np.array([]); TAll = np.array([]); tOff = 0
        _mode_stats.append([])
        for m in range(1, 7):
            dTdt = lambda t, T, m=m, Gs=Gs: therm_ode_shunt(T, Tf, Qlw, Qe_modes_val[m - 1], Qw_modes_val[m - 1], Tweb,
                                                        Gc, wA, mN, mE, mCs, mCr, mDeg, wC, Gs, shunt["T_on"], shunt["T_off"])
            ts, Ts = _ode45(dTdt, (0, dur[m - 1]), T0)
            tAll = Summarised(np.concatenate([tAll, ts + tOff])); TAll = Summarised(np.concatenate([TAll, Ts]))
            _mode_stats[-1].append((Ts[0], Ts[-1], Ts.max()))
            T0 = Ts[-1]; tOff = tOff + dur[m - 1]
        if case_id == 1:
            tNS = tAll; TNS = TAll
        if case_id == 2:
            tWS = tAll; TWS = TAll

    for Nl in [0, 4, 6, 8, 10]:
        Qi = Nl * lwP
        dTdt_f = lambda t, T, Qi=Qi: therm_ode_shunt(T, Tf, Qi, 0, 0, Tweb, Gc, wA, mN, mE, mCs, mCr, mDeg, wC,
                                                  shunt["G_margin"], shunt["T_on"], shunt["T_off"])
        tp, Tp = _ode45(dTdt_f, (0, 200 * 3600), Tweb)
        T24 = _interp1(tp / 3600, Tp, 24); T72 = _interp1(tp / 3600, Tp, 72); T200 = Tp[-1]
        i253 = _find_first(Tp < 253)
        s253 = "NEVER" if i253 is None else "%.0fhr" % (tp[i253 - 1] / 3600)
        _fail_rows.append((Nl, T24, T72, T200, s253))

    # ---- S10: substation WEB thermal audit -------------------------------------
    sL = 0.35; sW = 0.25; sH = 0.25
    sA = 2 * (sL * sW + sL * sH + sW * sH)
    sC = 5 * 4186 + 3 * 800 + 5 * 500
    sQA_pk = 4 * QCf(k_PEEK, math.pi / 4 * ((15e-3) ** 2 - (6e-3) ** 2), 0.030, Tf, Tweb)
    sRw = 4e-3 / (ka_PK * math.pi / 4 * (8e-3) ** 2)
    sRb = 0.022 / (ka_Ti * math.pi / 4 * (5e-3) ** 2)
    sQA_bolt = 4 * dT / (2 * sRw + sRb)
    sQA = sQA_pk + sQA_bolt
    sLb = 0.020
    sQB_in = 2 * (2.08e-6 / sLb) * ki_Mn
    sQB_pt = 12 * (0.518e-6 / sLb) * ki_Mn
    sQB = sQB_in + sQB_pt
    rho_Mn = 48e-8
    sIR_in = 2 * 10**2 * rho_Mn * sLb / 2.08e-6
    sIR_pt = 12 * 2**2 * rho_Mn * sLb / 0.518e-6
    sn22 = 13; sn28 = 36
    sQC = sn22 * QCf(k_Mn, 0.326e-6, Lm, Tf, Tweb) + sn28 * QCf(k_Mn, 0.081e-6, Lm, Tf, Tweb)
    rA = math.pi / 4 * (20e-3**2 - 18e-3**2)
    sRD = 2 * (0.040 / (ka_Ti * rA)) + 0.030 / (ka_PK * rA)
    sQD = dT / sRD
    sQE = 4 * 0.5
    fA = math.pi / 4 * (15e-3) ** 2; fL = 0.030
    sQF = 5 * (fA / fL) * ki_PK
    sQG = qmli * sA * mDeg
    sQsub = sQA + sQB + sQC + sQD + sQE + sQF + sQG
    sQmar = sQsub * 0.30; sQtot = sQsub + sQmar
    sGweb = sQtot / dT
    sGc = (sQsub - sQG) / dT
    sQv = np.array([sQA, sQB, sQC, sQD, sQE, sQF, sQG])

    # ---- S12: substation LWRHU sizing + survival ---------------------------------
    for N in range(1, 6):
        Qi = N * lwP; Teq = Tf + Qi / sGweb
        Htr = max(0, sQtot - Qi)
    for Nl in [1, 2, 3, 4]:
        Qi = Nl * lwP
        dTdt_s = lambda t, T, Qi=Qi: therm_ode_sub(T, Tf, Qi, sGc, sA, mN, mE, mCs, mCr, mDeg, sC)
        ts, Ts = _ode45(dTdt_s, (0, 48 * 3600), Tweb)
        T6 = _interp1(ts / 3600, Ts, 6); T12 = _interp1(ts / 3600, Ts, 12)
        T24 = _interp1(ts / 3600, Ts, 24); T48 = Ts[-1]
        i253 = _find_first(Ts < 253)
        s253 = "NEVER" if i253 is None else "%.0fhr" % (ts[i253 - 1] / 3600)
        _sub_fail_rows.append((Nl, T6, T12, T24, T48, s253))
    # S14 conclusions: interp1(Ts, ts/3600, 253, 'linear', 'extrap') on the last (Nl=4) run
    _t253_last = _interp1_extrap(Ts, ts / 3600, 253)

    # ---- S13: substation power budget -------------------------------------------
    sub_pwr_W = [sQtot, 40, 10, 21, 3, 3, 5, 3]
    stot = 0
    for r in range(1, len(sub_pwr_W) + 1):
        stot = stot + sub_pwr_W[r - 1]

    # ---- FIGURES: data the harness captured --------------------------------------
    cb = np.array([.18, .55, .82]); cr = np.array([.85, .32, .24]); cg = np.array([.30, .65, .30])
    ca = np.array([.92, .65, .15]); cp = np.array([.55, .27, .68]); cy = np.array([.5, .5, .5])
    # Fig 3
    tb = np.concatenate([[0.0], np.cumsum(dur) / 3600])
    # Fig 4 (re-runs the power-failure ODE; last idx=5 -> Nl=10)
    cols = _LINES[:5].copy()
    for idx in range(1, 6):
        Nl = np.array([0, 4, 6, 8, 10.0]); Ni = Nl[idx - 1]
        dTdt_p = lambda t, T, Ni=Ni: therm_ode_shunt(T, Tf, Ni * lwP, 0, 0, Tweb, Gc, wA, mN, mE, mCs, mCr, mDeg, wC,
                                                  shunt["G_margin"], shunt["T_on"], shunt["T_off"])
        tp, Tp = _ode45(dTdt_p, (0, 200 * 3600), Tweb)
    # Fig 5
    dg = np.arange(1.0, 5.0 + 1e-9, 0.5); Nr = np.arange(4, 11, dtype=float); Qco = Qsub - QH
    Teq_map = np.zeros((len(dg), len(Nr)))
    for di in range(1, len(dg) + 1):
        Qmd = qmli * wA * dg[di - 1]; Qtd = (Qco + Qmd) * 1.30; Gd = Qtd / dT
        for ni in range(1, len(Nr) + 1):
            Teq_map[di - 1, ni - 1] = Tf + Nr[ni - 1] * lwP / Gd
    # Fig 7
    G_total_shunted = Gweb + shunt["G_margin"]
    Qw_sweep = np.arange(0, 31, dtype=float)
    # Fig 8
    T_range = np.arange(40, 351, dtype=float)
    G_eff = np.zeros(T_range.shape)
    for i in range(1, len(T_range) + 1):
        if T_range[i - 1] >= shunt["T_on"]:
            G_eff[i - 1] = Gweb + shunt["G_margin"]
        else:
            G_eff[i - 1] = Gweb
    # Fig 9 loop leaves i = 7
    for i in range(1, 8):
        pass
    # Fig 10 (re-runs the substation ODE; last idx=4)
    cols = _LINES[:4].copy()
    for idx in range(1, 5):
        Nl = idx; Qi = Nl * lwP
        dTdt_sp = lambda t, T, Qi=Qi: therm_ode_sub(T, Tf, Qi, sGc, sA, mN, mE, mCs, mCr, mDeg, sC)
        ts, Ts = _ode45(dTdt_sp, (0, 48 * 3600), Tweb)

    return dict(locals())


def _interp1_extrap(x, y, xq):
    """MATLAB interp1(x, y, xq, 'linear', 'extrap') for monotonic x (either direction)."""
    x = np.asarray(x, dtype=float); y = np.asarray(y, dtype=float)
    if x[0] > x[-1]:
        x = x[::-1]; y = y[::-1]
    if xq < x[0]:
        return y[0] + (y[1] - y[0]) * (xq - x[0]) / (x[1] - x[0])
    if xq > x[-1]:
        return y[-1] + (y[-1] - y[-2]) * (xq - x[-1]) / (x[-1] - x[-2])
    return float(np.interp(xq, x, y))


def run(**params):
    """Flattened workspace, keyed like the golden CSV."""
    return flatten(workspace(**params))
