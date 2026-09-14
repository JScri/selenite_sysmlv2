%% SELENITE_VISUALISE_v3.m
%  Visualization companion to SELENITE_VERIFY_v3.m
%  Generates all programme figures from v3 verified data
%
%  Figures:
%    1. Propellant balance by phase (grouped bar + margin)
%    2. Demand composition (stacked bar)
%    3. Power budget by zone (stacked bar)
%    4. Solar array area scaling
%    5. Stockpile accumulation timeline
%    6. Fleet & node scaling (dual-axis)
%    7. Node deployment map — top-down crater floor
%    8. Node deployment map — 3D perspective
%    9. MOLE-I unit power breakdown (pie)
%   10. Infrastructure mass budget (horizontal bar)
%
%  Author : Jason (Systems Engineering Lead), Selenite Programme
%  Date   : March 2026
%  Ref    : SELENITE_VERIFY_v3.m output

clear; clc;

%% ═══════════════════════════════════════════════════════════════════
%  DATA (all from SELENITE_VERIFY_v3.m — do not modify independently)
% ═══════════════════════════════════════════════════════════════════

% Phase labels
ph.labels = {'P3','P4','P5','P6','P7+'};
ph.names  = {'P3 Y4-7','P4 Y7-9','P5 Y9-12','P6 Y12-15','P7+ Y20+'};
ph.n      = 5;
ph.dur    = [3 2 3 3 5];
x         = 1:ph.n;

% Fleet composition
ph.mi     = [10, 25, 50, 85, 170];
ph.nodes  = [2,  5,  10, 17, 34];
ph.nProbe = [3,  6,  10, 15, 30];
ph.nSkip  = [0,  1,  2,  4,  8];

% Propellant (kg/yr)
ph.d_probe = [0, 39924, 66540, 99810, 199620];
ph.d_skip  = [0, 83022, 166044, 332088, 664176];
ph.d_dart  = [0, 0, 4123, 0, 0];
ph.d_ls    = [0, 1068, 1068, 1602, 3204];
ph.d_total = ph.d_probe + ph.d_skip + ph.d_dart + ph.d_ls;
ph.isru    = ph.mi * 5692;
ph.margin  = ph.isru - ph.d_total;

% Power (kW)
ph.pwr_psr   = [18.7, 46.6, 93.3, 158.6, 317.2];   % fleet + nodes
ph.pwr_pipe  = [0, 59.5, 59.5, 59.5, 59.5];
ph.pwr_isru  = [64, 160, 321, 545, 1090];
ph.pwr_base  = [8.7, 22.2, 25.6, 44.6, 50.6];
ph.pwr_sub   = ph.pwr_psr + ph.pwr_pipe + ph.pwr_isru + ph.pwr_base;
ph.pwr_cont  = ph.pwr_sub * 0.20;
ph.pwr_total = ph.pwr_sub + ph.pwr_cont;
ph.solar_cap = ph.pwr_total / 0.85;
ph.panel_m2  = ph.solar_cap / (1.361 * 0.29);

% Node ring layout
ring.nodes  = [5, 12, 17];
ring.radii  = [400, 900, 1400];  % metres from OZDP
ring.phases = {'P3','P4-P5','P6-P7+'};

% MOLE-I power breakdown (Watts)
mi_pwr.labels = {'Drive motors (300)', 'Drill (200)', 'mini-VEX (1200)', ...
                 'WEB 273K (57)', 'Comms (20)', 'Gearbox heaters (20)', ...
                 'Drill bearing htr (15)', 'Receptacle htr (5)', ...
                 'VEX standby (25)'};
mi_pwr.vals   = [300, 200, 1200, 57, 20, 20, 15, 5, 25];

% Infrastructure mass (tonnes)
infra.labels = {'Trunk cable (45.7t)', 'Backbone ring (3.0t)', ...
                'Tethers 34×5×200m (6.1t)', 'Dual pipeline (59.5t)', ...
                'Sub-stations 34×200kg (6.8t)', 'Cold spares 21×357kg (7.5t)'};
infra.vals   = [45.7, 3.0, 6.1, 59.5, 6.8, 7.5];

% Crater
crater.floor_dia_km = 6.5;
crater.rim_dia_km   = 21;

% Colours
col.blue    = [0.18 0.55 0.82];
col.red     = [0.85 0.32 0.24];
col.amber   = [0.92 0.65 0.15];
col.green   = [0.30 0.65 0.30];
col.grey    = [0.60 0.60 0.60];
col.dkblue  = [0.18 0.42 0.72];
col.purple  = [0.55 0.27 0.68];
col.teal    = [0.15 0.60 0.55];

fprintf('════════════════════════════════════════════════════════\n');
fprintf('  SELENITE v3 — Visualisation Suite (10 figures)\n');
fprintf('════════════════════════════════════════════════════════\n\n');


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 1 — Propellant Balance by Phase
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 1 — Propellant Balance','Position',[50 50 920 520]);
bar_data = [ph.isru; ph.d_total]' / 1000;
b = bar(x, bar_data, 'grouped');
b(1).FaceColor = col.blue;
b(2).FaceColor = col.red;
hold on;
plot(x, ph.margin/1000, 'k--o', 'LineWidth', 2, ...
     'MarkerFaceColor', col.green, 'MarkerSize', 8);
yline(0, 'k:', 'LineWidth', 1);
for i = 1:ph.n
    text(i, ph.isru(i)/1000 + 25, ...
         sprintf('%d MI\n%d nodes', ph.mi(i), ph.nodes(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end
ylabel('Propellant (t/yr)'); xlabel('Programme Phase');
xticks(x); xticklabels(ph.labels);
legend({'ISRU Supply (MOLE-I)', 'Fleet Demand', 'Margin'}, ...
       'Location', 'northwest', 'FontSize', 10);
title('Propellant Balance — Demand-Driven 17×5 Architecture');
grid on; set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 2 — Demand Composition (Stacked)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 2 — Demand Composition','Position',[50 620 920 520]);
stk = [ph.d_probe; ph.d_skip; ph.d_dart; ph.d_ls]' / 1000;
b2 = bar(x, stk, 'stacked');
b2(1).FaceColor = col.dkblue;
b2(2).FaceColor = col.red;
b2(3).FaceColor = col.amber;
b2(4).FaceColor = col.green;
hold on;
plot(x, ph.isru/1000, 'k-s', 'LineWidth', 2.5, ...
     'MarkerFaceColor', 'k', 'MarkerSize', 8);
ylabel('Propellant (t/yr)'); xlabel('Programme Phase');
xticks(x); xticklabels(ph.labels);
legend({'PROBE', 'SKIP (corrected ΔV)', 'DART stockpile', ...
        'Life Support', 'ISRU Supply'}, ...
       'Location', 'northwest', 'FontSize', 10);
title('Demand Composition vs ISRU Supply by Phase');
grid on; set(gca, 'FontSize', 11);
% Annotate SKIP dominance
for i = 2:ph.n
    skip_pct = ph.d_skip(i) / ph.d_total(i) * 100;
    text(i, ph.d_total(i)/1000 + 15, ...
         sprintf('SKIP: %.0f%%', skip_pct), ...
         'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', col.red);
end


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 3 — Power Budget by Zone (Stacked)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 3 — Power Budget by Zone','Position',[1000 50 950 550]);
pwr_zones = [ph.pwr_psr; ph.pwr_pipe; ph.pwr_isru; ...
             ph.pwr_base; ph.pwr_cont]';
b3 = bar(x, pwr_zones, 'stacked');
b3(1).FaceColor = col.red;
b3(2).FaceColor = col.blue;
b3(3).FaceColor = col.amber;
b3(4).FaceColor = col.green;
b3(5).FaceColor = col.grey;
ylabel('Power (kW)'); xlabel('Programme Phase');
xticks(x); xticklabels(ph.labels);
legend({'PSR Fleet + Nodes', 'Pipeline (59.5 kW)', ...
        'ISRU Plant (electrolysis + cryo)', 'Base Systems', ...
        'Contingency (20%)'}, ...
       'Location', 'northwest', 'FontSize', 9);
title('Total Continuous Power Budget — Solar-Only (No Fission)');
grid on; set(gca, 'FontSize', 11);
for i = 1:ph.n
    text(i, ph.pwr_total(i) + 20, ...
         sprintf('%.0f kW\n%.0f m²', ph.pwr_total(i), ph.panel_m2(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 4 — Solar Array Area by Phase
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 4 — Solar Array Scaling','Position',[1000 620 800 450]);
b4 = bar(x, ph.panel_m2, 'FaceColor', col.amber, 'EdgeColor', [0.6 0.4 0.1]);
ylabel('Panel Area (m²)'); xlabel('Programme Phase');
xticks(x); xticklabels(ph.labels);
title('Solar Array Area Required (GaAs 29%, 85% Sun)');
grid on; set(gca, 'FontSize', 11);
for i = 1:ph.n
    text(i, ph.panel_m2(i) + 100, ...
         sprintf('%.0f m²\n(%.2f ha)', ph.panel_m2(i), ph.panel_m2(i)/10000), ...
         'HorizontalAlignment', 'center', 'FontSize', 10);
end
% Reference lines
yline(2500, 'b--', 'LineWidth', 1);
text(0.6, 2650, 'ISS array area (~2,500 m²)', 'FontSize', 8, 'Color', 'b');


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 5 — Stockpile Accumulation Timeline
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 5 — Stockpile Accumulation','Position',[50 1200 920 480]);
years = []; stock_t = []; curr = 0;
yr_start = 4;
for i = 1:ph.n
    for y = 1:ph.dur(i)
        curr = curr + ph.margin(i);
        years = [years, yr_start + y - 1];
        stock_t = [stock_t, curr/1000];
    end
    yr_start = yr_start + ph.dur(i);
end
area(years, stock_t, 'FaceColor', [0.75 0.88 0.95], 'EdgeColor', col.blue, 'LineWidth', 2);
hold on;
yline(410, 'r--', 'LineWidth', 1.5);
text(years(end)-3, 440, '12-month P6 reserve target (410 t)', ...
     'Color', 'r', 'FontSize', 10);
% Phase boundaries
phase_starts = cumsum([4, ph.dur]);
for i = 1:ph.n
    xline(phase_starts(i), 'k:', 'LineWidth', 1);
    text(phase_starts(i)+0.3, max(stock_t)*0.92, ph.labels{i}, ...
         'FontSize', 11, 'FontWeight', 'bold');
end
xlabel('Programme Year'); ylabel('Stockpile (tonnes)');
title('Propellant Stockpile Accumulation Over Programme Lifetime');
grid on; set(gca, 'FontSize', 11);
xlim([3.5, years(end)+0.5]);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 6 — Fleet & Node Scaling (Dual Axis)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 6 — Fleet Scaling','Position',[1000 1200 800 450]);
yyaxis left;
b6 = bar(x, ph.mi, 'FaceColor', col.blue, 'BarWidth', 0.6);
ylabel('MOLE-I Units');
ylim([0, 200]);
yyaxis right;
plot(x, ph.nodes, 'r-o', 'LineWidth', 2.5, ...
     'MarkerFaceColor', col.red, 'MarkerSize', 10);
ylabel('Sub-Stations (Nodes)');
ylim([0, 40]);
xlabel('Programme Phase'); xticks(x); xticklabels(ph.labels);
title('Fleet & Sub-Station Scaling by Phase');
grid on; set(gca, 'FontSize', 11);
legend({'MOLE-I fleet', 'Sub-stations'}, 'Location', 'northwest');
% Annotate
for i = 1:ph.n
    text(i, ph.mi(i)+5, sprintf('%d', ph.mi(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 7 — Node Deployment Map (Top-Down Crater Floor)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 7 — Node Layout (Top-Down)','Position',[50 100 750 750]);

theta_circ = linspace(0, 2*pi, 200);

% Draw crater floor boundary
plot(crater.floor_dia_km/2 * cos(theta_circ), ...
     crater.floor_dia_km/2 * sin(theta_circ), ...
     'k-', 'LineWidth', 2.5);
hold on; axis equal; grid on;

% PSR shading (fill crater floor area)
fill(crater.floor_dia_km/2 * cos(theta_circ), ...
     crater.floor_dia_km/2 * sin(theta_circ), ...
     [0.92 0.94 0.97], 'EdgeColor', 'none');
% Redraw boundary on top
plot(crater.floor_dia_km/2 * cos(theta_circ), ...
     crater.floor_dia_km/2 * sin(theta_circ), ...
     'k-', 'LineWidth', 2.5);

% OZDP (offset toward wall — closest to rim base)
ozdp = [-1.5, 0];  % km
plot(ozdp(1), ozdp(2), 'r^', 'MarkerSize', 16, 'MarkerFaceColor', 'r', 'LineWidth', 1.5);
text(ozdp(1)+0.15, ozdp(2)+0.2, 'OZDP', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'r');

% Trunk cable from rim (approximate wall base location)
wall_base = [-3.0, 0];
plot([wall_base(1), ozdp(1)], [wall_base(2), ozdp(2)], ...
     'b-', 'LineWidth', 2);
text(-2.3, 0.15, 'Trunk cable', 'FontSize', 9, 'Color', 'b', 'Rotation', 0);
plot(wall_base(1), wall_base(2), 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
text(wall_base(1)-0.1, wall_base(2)+0.2, 'Rim base', 'FontSize', 9, 'Color', 'b');

% Deploy nodes by ring
ring_colors = {col.blue, col.green, col.purple};
ring_labels = {};
node_positions = [];

for r = 1:length(ring.nodes)
    n = ring.nodes(r);
    rad_km = ring.radii(r) / 1000;
    
    % Stagger starting angles for visual clarity
    theta_start = pi/3 + (r-1)*pi/9;
    
    for j = 1:n
        theta_j = theta_start + (j-1) * 2*pi/n;
        nx = ozdp(1) + rad_km * cos(theta_j);
        ny = ozdp(2) + rad_km * sin(theta_j);
        node_positions = [node_positions; nx, ny, r];
        
        % Tether operating circle
        circ_r = 200 / 1000;  % 200m in km
        circ_x = nx + circ_r * cos(theta_circ);
        circ_y = ny + circ_r * sin(theta_circ);
        
        fill(circ_x, circ_y, ring_colors{r}, ...
             'FaceAlpha', 0.15, 'EdgeColor', ring_colors{r}, ...
             'LineWidth', 1, 'EdgeAlpha', 0.5);
        plot(nx, ny, 'o', 'Color', ring_colors{r}, ...
             'MarkerSize', 6, 'MarkerFaceColor', ring_colors{r});
    end
end

% Draw backbone ring connections
for r = 1:length(ring.nodes)
    idx_ring = find(node_positions(:,3) == r);
    if length(idx_ring) > 1
        pts = node_positions(idx_ring, 1:2);
        % Sort by angle from OZDP
        angles = atan2(pts(:,2) - ozdp(2), pts(:,1) - ozdp(1));
        [~, sort_idx] = sort(angles);
        pts = pts(sort_idx, :);
        % Close the ring
        pts_closed = [pts; pts(1,:)];
        plot(pts_closed(:,1), pts_closed(:,2), '-', ...
             'Color', [ring_colors{r}, 0.4], 'LineWidth', 1.5);
    end
end

% Annotations
text(-3.1, -2.8, sprintf('Crater floor: %.1f km dia (%.1f km²)', ...
     crater.floor_dia_km, pi*(crater.floor_dia_km/2)^2), ...
     'FontSize', 9, 'Color', [0.4 0.4 0.4]);
text(-3.1, -3.1, sprintf('Floor utilisation: %.1f%%', ...
     34 * pi * 0.2^2 / (pi*(crater.floor_dia_km/2)^2) * 100), ...
     'FontSize', 9, 'Color', [0.4 0.4 0.4]);

% Scale bar
plot([-3, -2], [-3.5, -3.5], 'k-', 'LineWidth', 3);
text(-2.5, -3.7, '1 km', 'HorizontalAlignment', 'center', 'FontSize', 10);

% Legend entries (manual)
h_r1 = plot(NaN, NaN, 'o', 'Color', ring_colors{1}, ...
            'MarkerFaceColor', ring_colors{1}, 'MarkerSize', 8);
h_r2 = plot(NaN, NaN, 'o', 'Color', ring_colors{2}, ...
            'MarkerFaceColor', ring_colors{2}, 'MarkerSize', 8);
h_r3 = plot(NaN, NaN, 'o', 'Color', ring_colors{3}, ...
            'MarkerFaceColor', ring_colors{3}, 'MarkerSize', 8);
legend([h_r1, h_r2, h_r3], ...
       {sprintf('Ring 1: %d nodes @ %dm (P3)', ring.nodes(1), ring.radii(1)), ...
        sprintf('Ring 2: %d nodes @ %dm (P4–P5)', ring.nodes(2), ring.radii(2)), ...
        sprintf('Ring 3: %d nodes @ %dm (P6–P7+)', ring.nodes(3), ring.radii(3))}, ...
       'Location', 'southeast', 'FontSize', 9);

xlabel('km (East-West)'); ylabel('km (North-South)');
title(sprintf('Shackleton PSR — 34 Node Layout (17×5 × 2 = 170 MOLE-I at P7+)'));
xlim([-3.8 3.8]); ylim([-3.8 3.8]);
set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 8 — Node Layout with Sector Detail (Zoomed Ring 1)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 8 — Ring 1 Sector Detail','Position',[850 100 750 750]);

% Focus on Ring 1 — show 5 nodes with 72° sectors
r1_rad = ring.radii(1);  % 400m
n1 = ring.nodes(1);      % 5 nodes
theta_start = pi/3;

hold on; axis equal; grid on;

% Draw OZDP
plot(0, 0, 'r^', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
text(5, 15, 'OZDP', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r');

% Draw each node with its 5 sectors
sector_colors = {[0.85 0.32 0.24], [0.18 0.55 0.82], [0.30 0.65 0.30], ...
                 [0.92 0.65 0.15], [0.55 0.27 0.68]};

for j = 1:n1
    theta_j = theta_start + (j-1) * 2*pi/n1;
    nx = r1_rad * cos(theta_j);
    ny = r1_rad * sin(theta_j);
    
    % Draw 5 sectors (72° each)
    for s = 1:5
        sector_start = (s-1) * 72 * pi/180;
        sector_end   = s * 72 * pi/180;
        theta_sector = linspace(sector_start, sector_end, 50);
        
        % Sector arc at tether radius (200m)
        tether_r = 200;
        sec_x = [nx, nx + tether_r * cos(theta_sector), nx];
        sec_y = [ny, ny + tether_r * sin(theta_sector), ny];
        
        fill(sec_x, sec_y, sector_colors{s}, ...
             'FaceAlpha', 0.12, 'EdgeColor', sector_colors{s}, ...
             'LineWidth', 0.8, 'EdgeAlpha', 0.4);
    end
    
    % Node marker
    plot(nx, ny, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'w', 'LineWidth', 2);
    text(nx, ny, sprintf('N%d', j), 'HorizontalAlignment', 'center', ...
         'FontSize', 8, 'FontWeight', 'bold');
    
    % Tether radius circle
    plot(nx + 200*cos(theta_circ), ny + 200*sin(theta_circ), ...
         'k:', 'LineWidth', 0.8);
    
    % Draw backbone connection to neighbours
    if j > 1
        prev_theta = theta_start + (j-2) * 2*pi/n1;
        px = r1_rad * cos(prev_theta);
        py = r1_rad * sin(prev_theta);
        plot([px, nx], [py, ny], 'k-', 'LineWidth', 1.5);
    end
    if j == n1
        first_theta = theta_start;
        fx = r1_rad * cos(first_theta);
        fy = r1_rad * sin(first_theta);
        plot([nx, fx], [ny, fy], 'k-', 'LineWidth', 1.5);
    end
end

% Trunk cable from OZDP to one node
plot([0, r1_rad*cos(theta_start)], [0, r1_rad*sin(theta_start)], ...
     'b--', 'LineWidth', 1.5);
text(100, 220, 'Trunk from rim', 'FontSize', 9, 'Color', 'b', 'Rotation', 45);

% Labels
xlabel('metres'); ylabel('metres');
title(sprintf('Ring 1 Detail — 5 Nodes × 5 MOLE-I (72° sectors, 200m tether)'));
xlim([-700 700]); ylim([-700 700]);

% Sector legend
for s = 1:5
    h_sec(s) = fill(NaN, NaN, sector_colors{s}, 'FaceAlpha', 0.3);
end
legend(h_sec, {'MOLE-I #1','MOLE-I #2','MOLE-I #3','MOLE-I #4','MOLE-I #5'}, ...
       'Location', 'southeast', 'FontSize', 9);
set(gca, 'FontSize', 11);

% Annotations
text(-680, -600, sprintf('Sector arc at 200m: %.0fm', 2*pi*200/5), 'FontSize', 9);
text(-680, -650, 'MOLE-I width: 2.8m → 90× clearance', 'FontSize', 9);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 9 — MOLE-I Unit Power Breakdown
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 9 — MOLE-I Power Breakdown','Position',[50 700 700 550]);

% Custom colours for pie
pie_colors = [col.green; col.blue; col.red; col.amber; col.grey; ...
              col.teal; col.dkblue; col.purple; [0.7 0.5 0.3]];

p = pie(mi_pwr.vals);
colormap(pie_colors);

% Style the pie
for i = 1:2:length(p)
    p(i).EdgeColor = 'w';
    p(i).LineWidth = 1.5;
end

legend(mi_pwr.labels, 'Location', 'eastoutside', 'FontSize', 9);
title(sprintf('MOLE-I Unit Power: %dW operating / %dW keep-alive', ...
              sum(mi_pwr.vals), 57+20+15+5+25));

% Add keep-alive annotation
annotation('textbox', [0.05 0.05 0.35 0.08], ...
           'String', sprintf('Keep-alive (24/7): %dW — WEB %d + gearbox %d + drill %d + recept %d + VEX stby %d', ...
                             122, 57, 20, 15, 5, 25), ...
           'FontSize', 8, 'EdgeColor', 'none', 'BackgroundColor', [0.95 0.95 0.95]);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 10 — Infrastructure Mass Budget
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 10 — Infrastructure Mass','Position',[800 700 750 450]);

barh(infra.vals, 'FaceColor', col.dkblue, 'EdgeColor', [0.1 0.2 0.4]);
set(gca, 'YTickLabel', infra.labels, 'FontSize', 10);
xlabel('Mass (tonnes)');
title(sprintf('PSR Infrastructure Mass Budget — %.1f tonnes total', sum(infra.vals)));
grid on;
% Annotate values
for i = 1:length(infra.vals)
    text(infra.vals(i) + 1, i, sprintf('%.1f t', infra.vals(i)), ...
         'FontSize', 10, 'FontWeight', 'bold');
end
xlim([0, max(infra.vals) * 1.3]);


%% ═══════════════════════════════════════════════════════════════════
%  DONE
% ═══════════════════════════════════════════════════════════════════
fprintf('  Generated 10 figures.\n');
fprintf('  All data from SELENITE_VERIFY_v3.m (MATLAB v3 verified).\n');
fprintf('════════════════════════════════════════════════════════\n');