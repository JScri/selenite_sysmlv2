%% SELENITE_ECON v1.4 — BCR, IRR & Comprehensive Sensitivity
%  Run this AFTER v1.3 (shares workspace variables)
%  Adds: BCR, IRR, tornado chart, methodology documentation
%
%  Author: Jason Stewart | April 2026

fprintf('\n\n');
fprintf('████████████████████████████████████████████████\n');
fprintf('  SELENITE_ECON v1.4 — REPORT ANALYSIS LAYER\n');
fprintf('████████████████████████████████████████████████\n\n');

%% ═══════════════════════════════════════════════════════════════
%  1. BENEFIT-COST RATIO (BCR)
%  ═══════════════════════════════════════════════════════════════
%  BCR = PV(Benefits) / PV(Costs)
%  BCR > 1 → project is worth doing on that basis

pv_cost = sum(cost_total .* df);
pv_rev_direct = sum(rev_direct .* df);
pv_rev_total = sum(rev_total .* df);
pv_ext_reo = sum(ext_reo .* df);
pv_ext_h2 = sum(ext_h2 .* df);
pv_ext_geo = sum(ext_geo .* df);
pv_ext_rockets = sum(ext_rockets .* df);

bcr_direct = pv_rev_direct / pv_cost;
bcr_total = pv_rev_total / pv_cost;
bcr_reo_only = (pv_rev_direct + pv_ext_reo) / pv_cost;

fprintf('--- BENEFIT-COST RATIO ---\n');
fprintf('  PV of costs:              $%.2f T\n', pv_cost/1e6);
fprintf('  PV of direct revenue:     $%.2f T\n', pv_rev_direct/1e6);
fprintf('  PV of REO extern:         $%.2f T\n', pv_ext_reo/1e6);
fprintf('  PV of H2 extern:          $%.2f T\n', pv_ext_h2/1e6);
fprintf('  PV of geo insurance:      $%.2f T\n', pv_ext_geo/1e6);
fprintf('  PV of rocket emissions:   $%.2f T\n', pv_ext_rockets/1e6);
fprintf('  PV of total benefits:     $%.2f T\n', pv_rev_total/1e6);
fprintf('\n');
fprintf('  BCR (direct revenue only):        %.3f\n', bcr_direct);
fprintf('  BCR (direct + REO extern):        %.3f\n', bcr_reo_only);
fprintf('  BCR (all externalities):          %.3f\n', bcr_total);
fprintf('\n');
if bcr_total >= 1
    fprintf('  ✓ BCR > 1 with externalities — programme is economically justified.\n');
else
    fprintf('  BCR < 1 within 200-yr window. At steady state (Y180+), annual BCR = %.2f.\n', ...
        rev_total(end) / cost_total(end));
    fprintf('  Programme achieves BCR > 1 annually from Y%d onward.\n', ...
        Y(find(rev_total > cost_total, 1, 'first')));
end

%% ═══════════════════════════════════════════════════════════════
%  2. INTERNAL RATE OF RETURN (IRR)
%  ═══════════════════════════════════════════════════════════════
%  IRR = discount rate at which NPV = 0
%  Solve: sum(net_benefit / (1+r)^t) = 0

fprintf('\n--- INTERNAL RATE OF RETURN ---\n');

% Direct revenue IRR
try
    irr_direct = fzero(@(r) sum(net_direct ./ (1+r).^Y), 0.01);
    fprintf('  IRR (direct revenue only):  %.2f%%\n', irr_direct*100);
catch
    fprintf('  IRR (direct revenue only):  UNDEFINED (NPV never positive)\n');
    irr_direct = NaN;
end

% Full externalities IRR
try
    irr_total = fzero(@(r) sum(net_total ./ (1+r).^Y), 0.01);
    fprintf('  IRR (all externalities):    %.2f%%\n', irr_total*100);
catch
    fprintf('  IRR (all externalities):    UNDEFINED (NPV never positive at any rate)\n');
    irr_total = NaN;
end

% For reference: what discount rate makes BCR = 1?
try
    dr_breakeven = fzero(@(r) sum(rev_total ./ (1+r).^Y) - sum(cost_total ./ (1+r).^Y), 0.01);
    fprintf('  Discount rate for BCR=1:    %.2f%%\n', dr_breakeven*100);
catch
    fprintf('  Discount rate for BCR=1:    Not solvable\n');
    dr_breakeven = NaN;
end

%% ═══════════════════════════════════════════════════════════════
%  3. COMPREHENSIVE SENSITIVITY TORNADO
%  ═══════════════════════════════════════════════════════════════

fprintf('\n--- COMPREHENSIVE SENSITIVITY ANALYSIS ---\n');

baseline_npv = npv_total(end)/1e6;  % $T

% Helper: compute NPV with modified cost/revenue
compute_npv = @(rev, cost) sum((rev - cost) .* df) / 1e6;

% Build sensitivity pairs: [name, lo_npv_delta, hi_npv_delta]
sens = {};

% 1. Circuit throughput (batch vs continuous-flow)
for d_idx = 1:2
    cd = circuit_designs(d_idx);  % 1=batch, 2=continuous
    circ_k = ceil(reo_target / cd.reo_yr);
    d_circ_k = max(0, diff([0; circ_k]));
    cargo_k = zeros(N,1); maint_k = zeros(N,1); insitu_k = zeros(N,1);
    for i=1:N
        ef = min(1.0, max(0.10, 1.0-(Y(i)-25)*0.03));
        if Y(i)>=105, ef = max(0.03, ef-0.07*min(1,(Y(i)-105)/10)); end
        if Y(i)>=125, ef = max(0.008, ef-0.022*min(1,(Y(i)-125)/10)); end
        cargo_k(i) = d_circ_k(i)*cd.mass_kg*ef/1000;
        maint_k(i) = circ_k(i)*cd.mass_kg*0.005*ef/1000;
        insitu_k(i) = d_circ_k(i)*cd.mass_kg*(1-ef)/1000;
    end
    ec_k = max(0, earth_cargo - cargo_circuits - maint_circuits + cargo_k + maint_k);
    cl_k = ec_k*1000 .* launch_cost .* contingency / 1e6;
    is_k = (insitu_total - insitu_circuits + insitu_k)*1000 * insitu_cost_per_kg / 1e6;
    ct_k = cl_k + is_k + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing;
    circuit_npv(d_idx) = compute_npv(rev_total, ct_k);
end
sens{end+1} = {'Circuit: batch(0.4) vs cont(0.8)', circuit_npv(1)-baseline_npv, circuit_npv(2)-baseline_npv};

% 2. Discount rate (1.4% vs 3.5% flat)
npv_dr14 = sum(net_total ./ (1.014).^Y) / 1e6;
npv_dr35 = sum(net_total ./ (1.035).^Y) / 1e6;
sens{end+1} = {'Discount rate (1.4% vs 3.5%)', npv_dr14 - baseline_npv, npv_dr35 - baseline_npv};

% 3. Launch cost (±50%)
cl_hi = earth_cargo*1000.*(launch_cost*1.5).*contingency/1e6;
ct_hi = cl_hi + cost_insitu + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing;
cl_lo = earth_cargo*1000.*(launch_cost*0.5).*contingency/1e6;
ct_lo = cl_lo + cost_insitu + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing;
sens{end+1} = {'Launch cost (+50% vs -50%)', compute_npv(rev_total,ct_hi)-baseline_npv, compute_npv(rev_total,ct_lo)-baseline_npv};

% 4. REO externality ($50k vs $90k)
rev_reo_lo = rev_direct + reo_target*50000/1e6 + ext_h2 + ext_rockets + ext_geo;
rev_reo_hi = rev_direct + reo_target*90000/1e6 + ext_h2 + ext_rockets + ext_geo;
sens{end+1} = {'REO extern ($50k vs $90k/t)', compute_npv(rev_reo_lo,cost_total)-baseline_npv, compute_npv(rev_reo_hi,cost_total)-baseline_npv};

% 5. H2 attribution (25% vs 100%)
h2_npv = zeros(2,1);
for kidx = 1:2
    attr_k = [0.25, 1.00]; a = attr_k(kidx);
    ir_k = total_pgm * ir_frac * a;
    pem_k = zeros(N,1);
    for i=2:N
        pem_k(i) = pem_k(i-1) + ir_k(i)*pem_gw_per_t_ir;
        if i>pem_life, pem_k(i) = pem_k(i)-ir_k(i-pem_life)*pem_gw_per_t_ir; end
        pem_k(i) = max(0, pem_k(i));
    end
    ext_h2_k = pem_k * h2_per_gw_yr * h2_co2_mult * scc / 1e6;
    rev_k = rev_direct + ext_reo + ext_h2_k + ext_rockets + ext_geo;
    h2_npv(kidx) = compute_npv(rev_k, cost_total);
end
sens{end+1} = {'H2 attribution (25% vs 100%)', h2_npv(1)-baseline_npv, h2_npv(2)-baseline_npv};

% 6. Geopolitical insurance ($0 vs $25B)
geo_npv = zeros(2,1);
for kidx = 1:2
    gvals = [0, 25000]; gv = gvals(kidx);
    ext_g_k = zeros(N,1);
    for i=1:N
        sf = reo_target(i)/reo_demand(i);
        if sf > geo_threshold, ext_g_k(i) = gv*min(1,sf/0.5); end
    end
    rev_k = rev_direct + ext_reo + ext_h2 + ext_rockets + ext_g_k;
    geo_npv(kidx) = compute_npv(rev_k, cost_total);
end
sens{end+1} = {'Geo insurance ($0 vs $25B/yr)', geo_npv(1)-baseline_npv, geo_npv(2)-baseline_npv};

% 7. Maintenance rate (0.5% vs 0.25%)
maint_npv = zeros(2,1);
for kidx = 1:2
    mrates = [0.005, 0.0025]; mr = mrates(kidx);
    maint_k = zeros(N,1);
    for i=1:N
        ef = min(1.0, max(0.008, 1.0-(Y(i)-25)*0.03));
        if Y(i)>=105, ef = max(0.03, ef-0.07*min(1,(Y(i)-105)/10)); end
        if Y(i)>=125, ef = max(0.008, ef-0.022*min(1,(Y(i)-125)/10)); end
        maint_k(i) = circuits_needed(i)*circuit.mass_kg*mr*ef/1000;
    end
    ec_k = max(0, earth_cargo - maint_circuits + maint_k);
    cl_k = ec_k*1000.*launch_cost.*contingency/1e6;
    ct_k = cl_k + cost_insitu + cost_rd + cost_mkiii + cost_tugs + cost_dro_ops + cost_asteroid_processing;
    maint_npv(kidx) = compute_npv(rev_total, ct_k);
end
sens{end+1} = {'Maint rate (0.5% vs 0.25%)', maint_npv(1)-baseline_npv, maint_npv(2)-baseline_npv};

% Extract arrays for plotting
n_sens = length(sens);
sens_names = cell(n_sens,1);
sens_lo = zeros(n_sens,1);
sens_hi = zeros(n_sens,1);
for k = 1:n_sens
    sens_names{k} = sens{k}{1};
    sens_lo(k) = sens{k}{2};
    sens_hi(k) = sens{k}{3};
end

% Print tornado data
fprintf('\n%-40s %10s %10s %10s\n', 'Parameter', 'Low $T', 'High $T', 'Range $T');
fprintf('%-40s %10s %10s %10s\n', '---------', '------', '-------', '--------');
[~, sort_idx] = sort(abs(sens_hi - sens_lo), 'descend');
for k = 1:n_sens
    j = sort_idx(k);
    fprintf('%-40s %+10.3f %+10.3f %10.3f\n', sens_names{j}, sens_lo(j), sens_hi(j), abs(sens_hi(j)-sens_lo(j)));
end

%% ═══════════════════════════════════════════════════════════════
%  4. TORNADO FIGURE
%  ═══════════════════════════════════════════════════════════════

fig5 = figure('Position',[50 50 1000 600],'Color',[.03 .06 .1]);
axc = [.05 .08 .12]; txc = [.7 .8 .9]; gc = [.15 .2 .3];

% Sort by absolute range (largest at top)
range = abs(sens_hi - sens_lo);
[~, sort_idx] = sort(range, 'ascend');  % ascending so largest is at top of barh

for k = 1:n_sens
    j = sort_idx(k);
    lo_val = min(sens_lo(j), sens_hi(j));
    hi_val = max(sens_lo(j), sens_hi(j));
    % Draw range bar
    plot([lo_val hi_val], [k k], '-', 'Color', [.4 .6 .8], 'LineWidth', 8); hold on;
    % Negative portion
    if lo_val < 0
        plot([lo_val min(0, hi_val)], [k k], '-', 'Color', [.8 .3 .3], 'LineWidth', 8);
    end
    % Positive portion
    if hi_val > 0
        plot([max(0, lo_val) hi_val], [k k], '-', 'Color', [.3 .7 .3], 'LineWidth', 8);
    end
    % End markers
    plot(lo_val, k, 'o', 'MarkerSize', 7, 'MarkerFaceColor', [.8 .3 .3], 'MarkerEdgeColor', 'none');
    plot(hi_val, k, 'o', 'MarkerSize', 7, 'MarkerFaceColor', [.3 .7 .3], 'MarkerEdgeColor', 'none');
end

set(gca, 'YTick', 1:n_sens, 'YTickLabel', sens_names(sort_idx), ...
    'Color', axc, 'XColor', txc, 'YColor', txc, 'GridColor', gc, 'FontSize', 9);
xline(0, 'w-', 'LineWidth', 1.5);
grid on;
xlabel(sprintf('NPV change from baseline ($%.2fT)', baseline_npv), 'Color', txc);
title('Comprehensive Sensitivity Tornado', 'Color', [.9 .95 1], 'FontSize', 14);

saveas(fig5, 'SELENITE_ECON_v1_4_tornado.png');

%% ═══════════════════════════════════════════════════════════════
%  5. METHODOLOGY DOCUMENTATION
%  ═══════════════════════════════════════════════════════════════

fprintf('\n████████████████████████████████████████████████\n');
fprintf('  MODEL METHODOLOGY\n');
fprintf('████████████████████████████████████████████████\n\n');

fprintf('INFRASTRUCTURE DERIVATION (bottom-up):\n');
fprintf('  REO target (exogenous, programme plan)\n');
fprintf('  → Circuits needed = ceil(REO / %.1f t/yr per circuit)\n', circuit.reo_yr);
fprintf('  → Regolith throughput = REO / 500 ppm\n');
fprintf('  → Haulers needed = regolith × (1 - Tier3 frac) / %d t/yr per hauler\n', hauler.throughput_yr);
fprintf('  → Conveyor km = regolith × Tier3 frac / 20,000 t/yr per km\n');
fprintf('  → Power (kW) = circuits × %d kW each\n', circuit.power_kw);
fprintf('  → MSR count = power / %d MWe per MSR (from P9+)\n', msr.power_mw);
fprintf('  → MOLE-I = propellant demand / %d kg/yr per unit\n', molei.propellant_yr);
fprintf('  → Canisters/yr = REO / %.1f t per canister (from P9+)\n', can.reo_payload_t);
fprintf('\n');

fprintf('EARTH CARGO DERIVATION:\n');
fprintf('  For each infrastructure type:\n');
fprintf('    New-build cargo = delta(fleet) × unit mass × Earth fraction\n');
fprintf('    Maintenance cargo = fleet × unit mass × maint rate × Earth fraction\n');
fprintf('  Earth fractions decline over time:\n');
fprintf('    Circuits: 100%% (P8) → 10%% (P10+) → 3%% (C-type, Y105) → 0.8%% (S-type, Y125)\n');
fprintf('    Haulers: 100%% (P8) → 43%% (P10+) → 33%% (M-type Fe-Ni, Y90) → 20%% floor\n');
fprintf('    MSR: 100%% (Hastelloy-N) → 30%% (Ni-201 in-situ, Y80+)\n');
fprintf('    Conveyors: 5%% constant (drive electronics + bearings)\n');
fprintf('\n');

fprintf('COST MODEL:\n');
fprintf('  Earth launch: cargo × launch cost × contingency\n');
fprintf('    Launch cost: $6,000/kg (P0-P7), $4,000 (P8-P9), $2,000 (P10+)\n');
fprintf('    Contingency: 50%% (P0-P7), 35%% (P8-P9), 25%% (P10+)\n');
fprintf('  In-situ fabrication: insitu mass × $100/kg\n');
fprintf('  Mk III PROBEs: LEO launch only at $500/kg × contingency\n');
fprintf('  Redirect tugs: LEO launch only at $500/kg × contingency\n');
fprintf('  Asteroid processing: $500M/yr (C-type) + $800M/yr (S-type)\n');
fprintf('  R&D: $500M-$2,000M/yr scaling with programme maturity\n');
fprintf('\n');

fprintf('REVENUE MODEL:\n');
fprintf('  REO sales: production × basket price\n');
fprintf('    Basket: $15,000/t (2026), declining to $5,000/t floor at market saturation\n');
fprintf('    Price model: max($5,000, $15,000 × (1 - 0.6 × supply fraction))\n');
fprintf('  PGM sales: (Mk I/II + Mk III + captured asteroid) × $50,000/kg\n');
fprintf('    Mk I/II: %d fleet × %.4f t/mission × 1 mission/yr\n', probe_fleet(end), probe.pgm_per_mission);
fprintf('    Mk III: %d fleet × %.4f t/mission × 0.5 missions/yr\n', round(mkiii_active(end)), probe.pgm_per_mission);
fprintf('    Captured: 36.5 t/yr from single M-type asteroid (Y85+)\n');
fprintf('\n');

fprintf('ENVIRONMENTAL EXTERNALITIES:\n');
fprintf('  1. REO mining displacement: $73,700/t REO\n');
fprintf('     Source: Lee & Wen (2018) EEIO + EPA SCC $190/tCO2\n');
fprintf('     CO2 component: 30 t CO2-eq/t REO lifecycle\n');
fprintf('  2. H2 enabling via Ir: 50%% marginal attribution\n');
fprintf('     Chain: Ir → PEM (1 GW/t, 20-yr life) → H2 → CO2 avoided\n');
fprintf('     Multiplier: 12 t CO2/t H2 (energy + green steel + ammonia)\n');
fprintf('     SCC: $190/t CO2 (EPA Nov 2023)\n');
fprintf('  3. Geopolitical insurance: $15B/yr at 50%%+ supply displacement\n');
fprintf('     Ref: China 85-90%% REE control, 2010-11 14× price spike, EU gas crisis >€1T\n');
fprintf('  4. Rocket emissions (negative): tanker ratio 14→8→5, fossil frac 100%%→5%%\n');
fprintf('     CO2: 2,750 t/launch, declining with DAC methane ramp\n');
fprintf('\n');

fprintf('DISCOUNT RATE:\n');
fprintf('  Declining: 3.0%% (Y0-30), 2.5%% (Y31-75), 2.0%% (Y76+)\n');
fprintf('  Ref: Arrow, Cropper, Gollier et al. (2014) REE&P 8(2):145-163\n');
fprintf('  Justification: intergenerational public good, δ ≈ 0, Ramsey equation\n');
fprintf('\n');

fprintf('PROGRAMME ARCHITECTURE:\n');
fprintf('  SPA (Shackleton): Asteroid processing hub (M/C/S-type), crew base, PROBE ops\n');
fprintf('  PKT (Procellarum): KREEP REO processing ONLY — every km² is ore\n');
fprintf('  3 mass drivers baseline + 1 conditional (SPA→PKT, PKT→Earth, PKT→SPA, SPA→Earth)\n');
fprintf('  + 1 DRO→SPA mass driver for captured asteroid concentrate\n');
fprintf('  Diversified asteroids: M-type (Y75), C-type (Y95), S-type (Y115)\n');
fprintf('  PROBE Mk I/II → III transition: chemical→ion, landing→orbital\n');
fprintf('\n');

fprintf('████████████████████████████████████████████████\n');
fprintf('  v1.4 ANALYSIS COMPLETE\n');
fprintf('  BCR (full): %.3f | IRR (full): ', bcr_total);
if ~isnan(irr_total), fprintf('%.2f%%', irr_total*100); else, fprintf('N/A'); end
fprintf('\n');
fprintf('  Baseline NPV: $%.2fT | SS net: $%.1fB/yr\n', baseline_npv, (rev_total(end)-cost_total(end))/1e3);
fprintf('████████████████████████████████████████████████\n');