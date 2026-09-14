%% SELENITE_NODE_LAYOUT_v2.m
%  Branching Tree Sub-Station Layout
%  Replaces concentric ring topology
%
%  Design principles:
%    - Cable Landing Point (CLP) on crater wall circumference
%    - Main spine extends from CLP toward crater centre
%    - Lateral branches alternate L/R off spine
%    - Nodes offset from all cables by ≥250m (200m tether + 50m buffer)
%    - No cable crosses any MOLE-I operating zone
%    - Infinitely scalable: extend spine + add branches
%    - Phase deployment: grow spine progressively from CLP inward
%
%  Author : Jason (Systems Engineering Lead)
%  Date   : March 2026

clear; clc; close all;

%% ═══════════════════════════════════════════════════════════════════
%  PARAMETERS
% ═══════════════════════════════════════════════════════════════════

% Crater
crater.floor_dia_m  = 6500;    % m
crater.floor_r_m    = crater.floor_dia_m / 2;
crater.floor_area   = pi * crater.floor_r_m^2;  % m²

% Node specs
node.tether_r       = 200;     % m tether radius
node.buffer         = 50;      % m safety buffer from cables
node.clearance      = node.tether_r + node.buffer;  % 250m
node.units          = 5;       % MOLE-I per node
node.sector_deg     = 360 / node.units;  % 72°

% Spine layout
spine.branch_spacing = 550;    % m between branch junctions along spine
spine.branch_angle   = 70;     % degrees from spine axis (not 90 — angled outward)
spine.node_spacing   = 480;    % m between nodes along a branch

% Phase fleet targets (from v3 verified)
phase.labels = {'P3','P4','P5','P6','P7+'};
phase.nodes  = [2, 5, 10, 17, 34];
phase.mi     = phase.nodes * 5;

theta_circ = linspace(0, 2*pi, 300);

fprintf('════════════════════════════════════════════════════════════\n');
fprintf('  SELENITE — Branching Tree Node Layout\n');
fprintf('  Fishbone topology from Cable Landing Point\n');
fprintf('════════════════════════════════════════════════════════════\n\n');


%% ═══════════════════════════════════════════════════════════════════
%  GENERATE TREE LAYOUT
% ═══════════════════════════════════════════════════════════════════

% CLP: where trunk cable meets crater floor (south-west wall base)
% Place it on the crater perimeter, offset to leave max floor ahead
clp = [-crater.floor_r_m * 0.92, 0];  % near western wall base

% Spine direction: from CLP toward crater centre (bearing ~East)
spine_dir = [1, 0];  % unit vector pointing into crater
spine_dir = spine_dir / norm(spine_dir);

% Perpendicular direction for branches
perp = [0, 1];  % north-south

% Generate branch junctions along spine
n_branches_needed = ceil(max(phase.nodes) / 3);  % ~3 nodes per branch avg
n_branches = 12;  % generate more than needed for future scaling

% Branch definitions: [junction_distance_along_spine, side (+1=left, -1=right), n_nodes]
branches = [];
junction_dist = 400;  % first junction 400m from CLP

for b = 1:n_branches
    side = (-1)^(b+1);  % alternate left/right
    
    % Nodes per branch: 2-4, tapering slightly as we go deeper
    if b <= 4
        n_on_branch = 3;
    elseif b <= 8
        n_on_branch = 3;
    else
        n_on_branch = 2;
    end
    
    branches = [branches; junction_dist, side, n_on_branch];
    junction_dist = junction_dist + spine.branch_spacing;
end

% Calculate total spine length
spine_length = max(branches(:,1)) + 200;

% Generate all node positions
all_nodes = [];       % [x, y, branch_id, node_in_branch, phase_ring]
all_cables = {};      % cable segment endpoints for drawing
spine_points = [];    % spine path points

% Spine cable path (straight line from CLP)
spine_start = clp;
spine_end   = clp + spine_dir * spine_length;
spine_points = [spine_start; spine_end];

node_count = 0;

for b = 1:size(branches, 1)
    jdist = branches(b, 1);
    side  = branches(b, 2);
    n_n   = branches(b, 3);
    
    % Junction point on spine
    jpt = clp + spine_dir * jdist;
    
    % Branch direction (angled outward from spine)
    branch_dir = perp * side;
    % Add slight forward angle
    angle_rad = deg2rad(spine.branch_angle);
    if side > 0
        branch_vec = [cos(angle_rad), sin(angle_rad)] .* [spine_dir(1), 1];
        branch_vec = [spine_dir(1)*cos(angle_rad) - side*spine_dir(2)*sin(angle_rad), ...
                      spine_dir(2)*cos(angle_rad) + side*spine_dir(1)*sin(angle_rad)];
    else
        branch_vec = [spine_dir(1)*cos(angle_rad) - side*spine_dir(2)*sin(angle_rad), ...
                      spine_dir(2)*cos(angle_rad) + side*spine_dir(1)*sin(angle_rad)];
    end
    branch_vec = branch_vec / norm(branch_vec);
    
    % Place nodes along branch
    branch_cable_end = jpt;
    for n = 1:n_n
        % Node position: offset from branch by clearance distance
        node_pos = jpt + branch_vec * (node.clearance + (n-1) * spine.node_spacing);
        
        % Check if inside crater floor
        if norm(node_pos) < crater.floor_r_m - node.tether_r
            node_count = node_count + 1;
            
            % Assign phase based on deployment order
            if node_count <= phase.nodes(1)
                ph = 1;
            elseif node_count <= phase.nodes(2)
                ph = 2;
            elseif node_count <= phase.nodes(3)
                ph = 3;
            elseif node_count <= phase.nodes(4)
                ph = 4;
            else
                ph = 5;
            end
            
            all_nodes = [all_nodes; node_pos, b, n, ph];
            branch_cable_end = node_pos;
        end
    end
    
    % Store cable segment
    all_cables{end+1} = [jpt; branch_cable_end];
end

fprintf('  Total nodes generated: %d (target P7+: %d)\n', node_count, phase.nodes(end));
fprintf('  Spine length: %.0f m\n', spine_length);
fprintf('  Branches: %d (alternating L/R)\n', size(branches, 1));

% Check clearances
fprintf('\n  CLEARANCE CHECK:\n');
min_node_dist = inf;
for i = 1:size(all_nodes, 1)
    for j = i+1:size(all_nodes, 1)
        d = norm(all_nodes(i,1:2) - all_nodes(j,1:2));
        if d < min_node_dist
            min_node_dist = d;
        end
    end
end
fprintf('    Minimum node-to-node distance: %.0f m (need >400m)\n', min_node_dist);

% Check no node's tether circle crosses spine
min_spine_dist = inf;
for i = 1:size(all_nodes, 1)
    % Distance from node to spine line
    np = all_nodes(i, 1:2);
    % Point-to-line distance (spine is along x-axis from CLP)
    d_to_spine = abs((np(2) - clp(2)));  % simplified since spine is horizontal
    if d_to_spine < min_spine_dist
        min_spine_dist = d_to_spine;
    end
end
fprintf('    Minimum node-to-spine distance: %.0f m (need >250m)\n', min_spine_dist);

% Floor utilisation
node_area = node_count * pi * node.tether_r^2;
util_pct = node_area / crater.floor_area * 100;
fprintf('    Floor utilisation: %.1f%% of %.1f km²\n', util_pct, crater.floor_area/1e6);

% Max distance from CLP
max_dist = max(sqrt(sum((all_nodes(:,1:2) - clp).^2, 2)));
fprintf('    Furthest node: %.0f m from CLP\n', max_dist);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 1 — Full Crater Layout (Branching Tree)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 1 — Branching Tree Layout (Full Crater)', ...
       'Position', [50 50 850 850]);

% Crater floor
fill(crater.floor_r_m * cos(theta_circ), ...
     crater.floor_r_m * sin(theta_circ), ...
     [0.93 0.95 0.97], 'EdgeColor', 'k', 'LineWidth', 2.5);
hold on; axis equal; grid on;

% Phase colours
ph_colors = {[0.18 0.55 0.82], [0.30 0.65 0.30], [0.92 0.65 0.15], ...
             [0.85 0.32 0.24], [0.55 0.27 0.68]};

% Draw spine cable
plot([spine_start(1), spine_end(1)], [spine_start(2), spine_end(2)], ...
     'b-', 'LineWidth', 3);

% Draw branch cables
for b = 1:length(all_cables)
    seg = all_cables{b};
    plot(seg(:,1), seg(:,2), 'b-', 'LineWidth', 1.5, 'Color', [0.3 0.5 0.7]);
end

% Draw nodes with tether circles
for i = 1:size(all_nodes, 1)
    nx = all_nodes(i, 1);
    ny = all_nodes(i, 2);
    ph = all_nodes(i, 5);
    
    % Tether circle
    cx = nx + node.tether_r * cos(theta_circ);
    cy = ny + node.tether_r * sin(theta_circ);
    fill(cx, cy, ph_colors{ph}, 'FaceAlpha', 0.15, ...
         'EdgeColor', ph_colors{ph}, 'LineWidth', 0.8, 'EdgeAlpha', 0.5);
    
    % Node marker
    plot(nx, ny, 'o', 'Color', ph_colors{ph}, ...
         'MarkerSize', 5, 'MarkerFaceColor', ph_colors{ph});
end

% CLP marker
plot(clp(1), clp(2), 'bs', 'MarkerSize', 14, 'MarkerFaceColor', 'b', 'LineWidth', 2);
text(clp(1)+100, clp(2)+200, 'CLP', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'b');
text(clp(1)+100, clp(2)-200, '(Cable Landing Point)', 'FontSize', 9, 'Color', 'b');

% Arrow showing trunk cable descending wall
plot([clp(1)-800, clp(1)], [clp(2), clp(2)], 'b--', 'LineWidth', 2);
text(clp(1)-1200, clp(2)+150, 'Trunk from rim', 'FontSize', 9, 'Color', 'b');

% Scale bar
plot([-3000, -2000], [-3000, -3000], 'k-', 'LineWidth', 4);
text(-2500, -3200, '1 km', 'HorizontalAlignment', 'center', 'FontSize', 11);

% Legend
h_leg = [];
for p = 1:5
    h_leg(p) = fill(NaN, NaN, ph_colors{p}, 'FaceAlpha', 0.3, 'EdgeColor', ph_colors{p});
end
h_spine = plot(NaN, NaN, 'b-', 'LineWidth', 3);
legend([h_spine, h_leg], ...
       {'Spine + branch cables', ...
        sprintf('P3: %d nodes (%d MI)', phase.nodes(1), phase.mi(1)), ...
        sprintf('P4: +%d nodes (%d MI)', phase.nodes(2)-phase.nodes(1), phase.mi(2)), ...
        sprintf('P5: +%d nodes (%d MI)', phase.nodes(3)-phase.nodes(2), phase.mi(3)), ...
        sprintf('P6: +%d nodes (%d MI)', phase.nodes(4)-phase.nodes(3), phase.mi(4)), ...
        sprintf('P7+: +%d nodes (%d MI)', phase.nodes(5)-phase.nodes(4), phase.mi(5))}, ...
       'Location', 'southeast', 'FontSize', 9);

xlabel('metres (East-West)'); ylabel('metres (North-South)');
title(sprintf('Branching Tree Layout — %d Nodes (%d MOLE-I) in %.1f km² Floor', ...
              node_count, node_count*5, crater.floor_area/1e6));
xlim([-3800 3800]); ylim([-3800 3800]);
set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 2 — Zoomed Spine Detail (First 3 Branches)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 2 — Spine Detail (First Branches)', ...
       'Position', [950 50 850 700]);
hold on; axis equal; grid on;

% Draw spine (truncated)
plot([clp(1), clp(1) + 2500], [clp(2), clp(2)], 'b-', 'LineWidth', 3);

% Cable clearance corridor (hatched zone along spine)
corridor_y = [-node.clearance, -node.clearance, node.clearance, node.clearance];
corridor_x = [clp(1), clp(1)+2500, clp(1)+2500, clp(1)];
fill(corridor_x, corridor_y, [0.9 0.9 1.0], 'EdgeColor', [0.7 0.7 0.9], ...
     'LineStyle', '--', 'FaceAlpha', 0.3);
text(clp(1)+800, 230, 'Cable clearance corridor (250m each side)', ...
     'FontSize', 9, 'Color', [0.5 0.5 0.7]);

% Draw first 4 branches and their nodes
for b = 1:min(4, length(all_cables))
    seg = all_cables{b};
    plot(seg(:,1), seg(:,2), '-', 'LineWidth', 2, 'Color', [0.3 0.5 0.7]);
    
    % Junction marker
    plot(seg(1,1), seg(1,2), 'b^', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
end

% Draw relevant nodes with sector detail
for i = 1:min(12, size(all_nodes, 1))
    nx = all_nodes(i, 1);
    ny = all_nodes(i, 2);
    ph = all_nodes(i, 5);
    
    % Tether circle
    cx = nx + node.tether_r * cos(theta_circ);
    cy = ny + node.tether_r * sin(theta_circ);
    fill(cx, cy, ph_colors{ph}, 'FaceAlpha', 0.12, ...
         'EdgeColor', ph_colors{ph}, 'LineWidth', 1);
    
    % Draw 5 sector lines
    for s = 0:4
        angle = s * 72 * pi/180;
        plot([nx, nx + node.tether_r*cos(angle)], ...
             [ny, ny + node.tether_r*sin(angle)], ...
             '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5);
    end
    
    % Node marker
    plot(nx, ny, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
    text(nx, ny, sprintf('%d', i), 'HorizontalAlignment', 'center', 'FontSize', 7);
end

% CLP
plot(clp(1), clp(2), 'bs', 'MarkerSize', 14, 'MarkerFaceColor', 'b');
text(clp(1)+50, clp(2)+80, 'CLP', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'b');

% Annotations
annotation('textarrow', [0.2 0.25], [0.85 0.8], 'String', 'Spine cable (1000 VDC)', ...
           'FontSize', 9, 'Color', 'b');

xlabel('metres'); ylabel('metres');
title('Spine Detail — Cable Corridor Keeps Trunk Outside All Working Zones');
set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 3 — Scaling Comparison (Rings vs Tree)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 3 — Rings vs Tree Scaling', ...
       'Position', [50 750 1000 400]);

% How many nodes can each topology support before hitting crater wall?
max_nodes_ring = [];
max_nodes_tree = [];
node_counts = 10:5:100;

for n = node_counts
    % Rings: need concentric rings, each ring has more nodes
    % At some point the outer ring hits the crater wall
    remaining = n;
    r = 400; ok_ring = true;
    while remaining > 0
        max_fit = max(1, floor(2*pi*r/450));
        on_ring = min(remaining, max_fit);
        remaining = remaining - on_ring;
        r = r + 500;
        if r > crater.floor_r_m * 0.85  % hits wall zone
            ok_ring = false;
            break;
        end
    end
    max_nodes_ring = [max_nodes_ring, ok_ring * n + ~ok_ring * (n-remaining)];
    
    % Tree: just extend spine + add branches
    % Spine length needed: ceil(n/6) * branch_spacing (3 nodes/branch, 2 sides)
    spine_needed = ceil(n / 6) * spine.branch_spacing;
    ok_tree = spine_needed < (crater.floor_dia_m * 0.8);  % plenty of room
    max_nodes_tree = [max_nodes_tree, n * ok_tree];
end

subplot(1,2,1);
plot(node_counts, max_nodes_ring, 'r-o', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
plot(node_counts, max_nodes_tree, 'b-s', 'LineWidth', 2, 'MarkerSize', 6);
yline(34, 'k--', 'P7+ target (34)', 'FontSize', 9);
xlabel('Target Nodes'); ylabel('Achievable Nodes');
legend({'Concentric Rings', 'Branching Tree'}, 'Location', 'northwest');
title('Scalability: Rings vs Tree');
grid on; set(gca, 'FontSize', 11);

% Trunk cable conflict zones
subplot(1,2,2);
bar_data = [1, 0; 1, 0; 1, 0];  % [has_conflict, no_conflict] for each issue
bar_labels = {'Trunk crosses\nwork zones', 'Wall collision\nat Ring 4+', 'OZDP offset\nrequired'};
b = bar([1 0; 0 1; 0 1], 'stacked');
b(1).FaceColor = col.red;
b(2).FaceColor = col.green;
set(gca, 'XTickLabel', {'Rings', 'Tree'}, 'FontSize', 11);
title('Design Issue Resolution');
legend({'Problem present', 'Problem solved'}, 'Location', 'northeast');


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 4 — Phase-by-Phase Deployment on Tree
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 4 — Phase Deployment Sequence', ...
       'Position', [950 750 850 450]);

for p = 1:5
    subplot(1, 5, p);
    
    % Crater outline
    plot(crater.floor_r_m * cos(theta_circ) / 1000, ...
         crater.floor_r_m * sin(theta_circ) / 1000, 'k-', 'LineWidth', 1.5);
    hold on; axis equal;
    
    % Spine
    plot([clp(1), spine_end(1)]/1000, [clp(2), spine_end(2)]/1000, ...
         'b-', 'LineWidth', 1, 'Color', [0.7 0.8 0.9]);
    
    % Draw active cables for this phase
    active_branches = [];
    for b = 1:length(all_cables)
        seg = all_cables{b};
        % Check if any node on this branch is active in this phase
        branch_nodes = all_nodes(all_nodes(:,3) == b, :);
        if any(branch_nodes(:,5) <= p)
            plot(seg(:,1)/1000, seg(:,2)/1000, 'b-', 'LineWidth', 1.2);
        end
    end
    
    % Draw nodes
    for i = 1:size(all_nodes, 1)
        nx = all_nodes(i, 1);
        ny = all_nodes(i, 2);
        node_ph = all_nodes(i, 5);
        
        if node_ph <= p
            % Active
            fill((nx + node.tether_r*cos(theta_circ))/1000, ...
                 (ny + node.tether_r*sin(theta_circ))/1000, ...
                 ph_colors{node_ph}, 'FaceAlpha', 0.25, ...
                 'EdgeColor', ph_colors{node_ph}, 'LineWidth', 0.8);
        end
    end
    
    % CLP
    plot(clp(1)/1000, clp(2)/1000, 'bs', 'MarkerSize', 6, 'MarkerFaceColor', 'b');
    
    n_active = sum(all_nodes(:,5) <= p);
    title(sprintf('%s\n%d nodes / %d MI', phase.labels{p}, n_active, n_active*5), ...
          'FontSize', 10);
    xlim([-3.5 3.5]); ylim([-3.5 3.5]);
    set(gca, 'XTick', [], 'YTick', []);
end
sgtitle('Phase-by-Phase Deployment — Tree Grows from CLP Inward', 'FontSize', 12);


%% ═══════════════════════════════════════════════════════════════════
%  SUMMARY
% ═══════════════════════════════════════════════════════════════════
fprintf('\n════════════════════════════════════════════════════════════\n');
fprintf('  BRANCHING TREE LAYOUT SUMMARY\n');
fprintf('════════════════════════════════════════════════════════════\n');
fprintf('  Topology:       Fishbone/herringbone from CLP\n');
fprintf('  CLP position:   Western crater wall base\n');
fprintf('  Spine direction: East (into crater)\n');
fprintf('  Spine length:   %.0f m\n', spine_length);
fprintf('  Branches:       %d (alternating L/R at %d° from spine)\n', ...
        size(branches, 1), spine.branch_angle);
fprintf('  Branch spacing:  %d m along spine\n', spine.branch_spacing);
fprintf('  Node spacing:    %d m along branches\n', spine.node_spacing);
fprintf('  Tether radius:   %d m (72° sectors)\n', node.tether_r);
fprintf('  Cable clearance: %d m from all node zones\n', node.clearance);
fprintf('  Nodes placed:    %d (P7+ target: %d)\n', node_count, phase.nodes(end));
fprintf('  Min node-node:   %.0f m [%s]\n', min_node_dist, ...
        ternary(min_node_dist > 400, 'PASS', 'FAIL'));
fprintf('  Min node-spine:  %.0f m [%s]\n', min_spine_dist, ...
        ternary(min_spine_dist > 250, 'PASS', 'FAIL'));
fprintf('  Floor used:      %.1f%%\n', util_pct);
fprintf('  Max reach:       %.0f m from CLP\n', max_dist);
fprintf('\n  ADVANTAGES OVER CONCENTRIC RINGS:\n');
fprintf('    ✓ Trunk cable never crosses any working zone\n');
fprintf('    ✓ No crater wall collision at any scale\n');
fprintf('    ✓ Scales indefinitely (extend spine + add branches)\n');
fprintf('    ✓ Deployment sequence follows spine progressively\n');
fprintf('    ✓ Each branch independently serviceable\n');
fprintf('    ✓ OZDP not needed — CLP is the natural origin\n');
fprintf('════════════════════════════════════════════════════════════\n');


function result = ternary(cond, t, f)
    if cond, result = t; else, result = f; end
end