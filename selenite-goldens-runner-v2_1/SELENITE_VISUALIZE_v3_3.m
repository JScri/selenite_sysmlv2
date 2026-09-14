%% SELENITE_NODE_LAYOUT_v3.m
%  Bilateral Fishbone — Dense Packing with Full Branch Extension
%
%  Topology:
%    - Spine enters from CLP on crater wall, runs toward centre
%    - At each junction: TWO branches (left AND right) simultaneously
%    - Each branch extends multiple nodes outward until crater wall
%    - All cables (spine + branches) in dedicated corridors
%    - No cable crosses any MOLE-I tether zone
%
%  Author : Jason (Systems Engineering Lead)
%  Date   : March 2026

clear; clc; close all;

%% ═══════════════════════════════════════════════════════════════════
%  PARAMETERS
% ═══════════════════════════════════════════════════════════════════

crater.floor_r  = 3250;       % m (6.5 km diameter)
crater.floor_area = pi * crater.floor_r^2;

node.tether_r   = 200;        % m
node.buffer     = 50;         % m clearance from any cable
node.clearance  = node.tether_r + node.buffer;  % 250 m
node.min_sep    = 2 * node.tether_r + 30;       % 430 m min centre-to-centre
node.units      = 5;

% Spine parameters
spine.junction_spacing = 500;  % m between junction points along spine
spine.branch_angle     = 90;   % degrees from spine (perpendicular)

% Branch parameters  
branch.node_spacing    = 450;  % m between nodes along a branch
branch.first_offset    = node.clearance + 20;  % 270 m: first node offset from spine

% CLP
clp = [-crater.floor_r + 150, 0];  % near western wall

% Spine direction: east (into crater)
spine_dir = [1, 0];

% Phase targets
phase.labels = {'P3','P4','P5','P6','P7+','P8+'};
phase.target = [2, 5, 10, 17, 34, 60];

% Colours
ph_colors = {[0.18 0.55 0.82], [0.30 0.65 0.30], [0.92 0.65 0.15], ...
             [0.85 0.32 0.24], [0.55 0.27 0.68], [0.15 0.55 0.55]};

theta_circ = linspace(0, 2*pi, 300);

fprintf('════════════════════════════════════════════════════════════════\n');
fprintf('  SELENITE — Bilateral Fishbone Layout v3\n');
fprintf('════════════════════════════════════════════════════════════════\n\n');


%% ═══════════════════════════════════════════════════════════════════
%  GENERATE BILATERAL FISHBONE
% ═══════════════════════════════════════════════════════════════════

% Generate junction points along spine
% Spine runs from CLP eastward; first junction offset to clear CLP area
first_junction = 350;
max_junctions  = 20;

junctions = [];  % [x, y, junction_id]
jx = clp(1) + first_junction;
jid = 0;
while jx < crater.floor_r * 0.85  % don't push spine too close to far wall
    jid = jid + 1;
    junctions = [junctions; jx, 0, jid];
    jx = jx + spine.junction_spacing;
end

fprintf('  Spine: %.0f m to %.0f m from crater centre (%.0f m total)\n', ...
    abs(junctions(1,1)), abs(junctions(end,1)), junctions(end,1) - junctions(1,1));
fprintf('  Junctions: %d at %d m spacing\n', size(junctions,1), spine.junction_spacing);

% For each junction, extend branches left (+y) and right (-y)
all_nodes   = [];   % [x, y, junction_id, branch_side, node_on_branch, phase]
all_cables  = {};   % cable segment arrays for drawing
branch_info = [];   % [junction_id, side, n_nodes]

total_placed = 0;

for j = 1:size(junctions, 1)
    jx = junctions(j, 1);
    jy = junctions(j, 2);
    
    for side = [+1, -1]  % both directions from every junction
        % Place nodes along this branch until hitting crater wall
        n_on_branch = 0;
        branch_cable_pts = [jx, jy];  % cable starts at junction
        
        for k = 1:20  % max nodes per branch (will be limited by crater wall)
            % Node position
            ny = jy + side * (branch.first_offset + (k-1) * branch.node_spacing);
            nx = jx;  % branches are perpendicular to spine
            
            % Check: inside crater floor?
            if sqrt(nx^2 + ny^2) + node.tether_r > crater.floor_r - 50
                break;  % hit the wall
            end
            
            % Check: not too close to existing nodes
            too_close = false;
            for m = 1:size(all_nodes, 1)
                if norm([nx, ny] - all_nodes(m, 1:2)) < node.min_sep - 10
                    too_close = true;
                    break;
                end
            end
            
            if ~too_close
                total_placed = total_placed + 1;
                n_on_branch = n_on_branch + 1;
                
                % Phase assignment
                ph_id = find(total_placed <= phase.target, 1, 'first');
                if isempty(ph_id), ph_id = length(phase.target); end
                
                all_nodes = [all_nodes; nx, ny, j, side, k, ph_id];
                branch_cable_pts = [branch_cable_pts; nx, ny];
            end
        end
        
        % Store cable segment for this branch
        if size(branch_cable_pts, 1) > 1
            all_cables{end+1} = branch_cable_pts;
        end
        branch_info = [branch_info; j, side, n_on_branch];
    end
end

n_total = size(all_nodes, 1);
fprintf('\n  Nodes placed: %d\n', n_total);

% Print junction/branch summary
fprintf('\n  JUNCTION BREAKDOWN:\n');
fprintf('  %5s  %6s  %6s  %8s  %8s\n', 'Jct', 'X(m)', 'Left', 'Right', 'Total');
fprintf('  %s\n', repmat('-', 1, 40));
for j = 1:size(junctions, 1)
    left  = sum(branch_info(branch_info(:,1)==j & branch_info(:,2)==1, 3));
    right = sum(branch_info(branch_info(:,1)==j & branch_info(:,2)==-1, 3));
    fprintf('  %5d  %6.0f  %6d  %8d  %8d\n', j, junctions(j,1), left, right, left+right);
end
fprintf('  %s\n', repmat('-', 1, 40));
fprintf('  %5s  %6s  %6d  %8d  %8d\n', 'TOTAL', '', ...
    sum(branch_info(branch_info(:,2)==1, 3)), ...
    sum(branch_info(branch_info(:,2)==-1, 3)), n_total);

% Phase coverage
fprintf('\n  PHASE COVERAGE:\n');
for p = 1:length(phase.target)
    n_in_phase = sum(all_nodes(:,6) <= p);
    status = 'OK';
    if n_in_phase < phase.target(p), status = 'SHORT'; end
    fprintf('    %s: target %d, placed %d [%s]\n', phase.labels{p}, phase.target(p), n_in_phase, status);
end


%% ═══════════════════════════════════════════════════════════════════
%  CLEARANCE VERIFICATION
% ═══════════════════════════════════════════════════════════════════
fprintf('\n  CLEARANCE CHECKS:\n');

% Min node-to-node
min_nn = inf;
for i = 1:n_total
    for j = i+1:n_total
        d = norm(all_nodes(i,1:2) - all_nodes(j,1:2));
        if d < min_nn, min_nn = d; end
    end
end
fprintf('    Node-to-node:    %.0f m (min %d) [%s]\n', min_nn, node.min_sep, ...
    ternary(min_nn >= node.min_sep - 10, 'PASS', 'FAIL'));

% Min node tether to spine (y=0 line)
min_spine = inf;
for i = 1:n_total
    d_spine = abs(all_nodes(i, 2)) - node.tether_r;
    if d_spine < min_spine, min_spine = d_spine; end
end
fprintf('    Tether-to-spine: %.0f m (min %d) [%s]\n', min_spine, node.buffer, ...
    ternary(min_spine >= node.buffer - 5, 'PASS', 'FAIL'));

% Min node tether to any branch cable (branch runs along x=const)
min_branch = inf;
for i = 1:n_total
    nx = all_nodes(i, 1);
    ny = all_nodes(i, 2);
    % Branch cables for OTHER junctions pass through x=junct_x, varying y
    for j = 1:size(junctions, 1)
        if junctions(j,1) ~= nx  % only check OTHER junctions' branch cables
            d_branch_cable = abs(nx - junctions(j,1)) - node.tether_r;
            if d_branch_cable < min_branch && d_branch_cable > 0
                min_branch = d_branch_cable;
            end
        end
    end
end
fprintf('    Tether-to-adj-branch: %.0f m (min %d) [%s]\n', min_branch, node.buffer, ...
    ternary(min_branch >= node.buffer - 5, 'PASS', 'FAIL'));

% Floor utilisation
util_pct = n_total * pi * node.tether_r^2 / crater.floor_area * 100;
fprintf('    Floor utilisation: %.1f%%\n', util_pct);

% Furthest node
max_dist = max(sqrt(sum(all_nodes(:,1:2).^2, 2)));
max_clp  = max(sqrt(sum((all_nodes(:,1:2) - clp).^2, 2)));
fprintf('    Furthest from centre: %.0f m (crater wall at %d m)\n', max_dist, crater.floor_r);
fprintf('    Furthest from CLP:    %.0f m\n', max_clp);

% Cable lengths
spine_len = junctions(end,1) - clp(1);
branch_total = 0;
for i = 1:length(all_cables)
    seg = all_cables{i};
    for k = 2:size(seg,1)
        branch_total = branch_total + norm(seg(k,:) - seg(k-1,:));
    end
end
fprintf('    Spine cable:  %.1f km\n', spine_len/1000);
fprintf('    Branch cable: %.1f km total\n', branch_total/1000);
fprintf('    All cable:    %.1f km (× 2 for dual-path: %.1f km)\n', ...
    (spine_len + branch_total)/1000, 2*(spine_len + branch_total)/1000);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 1 — Full Crater Layout
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 1 — Bilateral Fishbone (Full Crater)', ...
       'Position', [50 50 900 900]);

% Crater floor
fill(crater.floor_r * cos(theta_circ), crater.floor_r * sin(theta_circ), ...
     [0.94 0.96 0.98], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 2.5);
hold on; axis equal; grid on;

% Spine cable (thick blue line)
spine_end_x = junctions(end, 1) + 100;
plot([clp(1), spine_end_x], [0, 0], 'b-', 'LineWidth', 3);

% Trunk from rim (dashed, extending west beyond CLP)
plot([clp(1) - 500, clp(1)], [0, 0], 'b--', 'LineWidth', 2);
text(clp(1) - 700, 150, {'Trunk cable', 'from rim'}, 'FontSize', 9, 'Color', [0.2 0.4 0.7]);

% Branch cables
for i = 1:length(all_cables)
    seg = all_cables{i};
    plot(seg(:,1), seg(:,2), '-', 'LineWidth', 1.5, 'Color', [0.3 0.55 0.75]);
end

% Junction markers on spine
for j = 1:size(junctions, 1)
    plot(junctions(j,1), 0, 'b^', 'MarkerSize', 7, 'MarkerFaceColor', [0.3 0.55 0.75]);
end

% Nodes with tether circles
for i = 1:n_total
    nx = all_nodes(i, 1);
    ny = all_nodes(i, 2);
    ph = all_nodes(i, 6);
    
    fill(nx + node.tether_r*cos(theta_circ), ny + node.tether_r*sin(theta_circ), ...
         ph_colors{ph}, 'FaceAlpha', 0.18, 'EdgeColor', ph_colors{ph}, ...
         'LineWidth', 0.8, 'EdgeAlpha', 0.5);
    plot(nx, ny, 'o', 'Color', ph_colors{ph}, 'MarkerSize', 4, ...
         'MarkerFaceColor', ph_colors{ph});
end

% CLP marker
plot(clp(1), clp(2), 'bs', 'MarkerSize', 14, 'MarkerFaceColor', 'b', 'LineWidth', 2);
text(clp(1) + 80, clp(2) + 200, 'CLP', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'b');

% Scale bar
plot([-3000, -2000], [-3000, -3000], 'k-', 'LineWidth', 4);
text(-2500, -3200, '1 km', 'HorizontalAlignment', 'center', 'FontSize', 11);

% Legend
h_leg = [];
for p = 1:min(5, length(phase.target))
    h_leg(p) = fill(NaN, NaN, ph_colors{p}, 'FaceAlpha', 0.35, 'EdgeColor', ph_colors{p});
end
h_sp = plot(NaN, NaN, 'b-', 'LineWidth', 3);
h_br = plot(NaN, NaN, '-', 'LineWidth', 1.5, 'Color', [0.3 0.55 0.75]);
legend([h_sp, h_br, h_leg], ...
       {'Spine cable (1000 VDC)', 'Branch cables', ...
        sprintf('P3: %d nodes (%d MI)', phase.target(1), phase.target(1)*5), ...
        sprintf('P4: +%d → %d nodes', phase.target(2)-phase.target(1), phase.target(2)), ...
        sprintf('P5: +%d → %d nodes', phase.target(3)-phase.target(2), phase.target(3)), ...
        sprintf('P6: +%d → %d nodes', phase.target(4)-phase.target(3), phase.target(4)), ...
        sprintf('P7+: +%d → %d nodes', phase.target(5)-phase.target(4), phase.target(5))}, ...
       'Location', 'southeast', 'FontSize', 9);

xlabel('metres (East-West)'); ylabel('metres (North-South)');
title(sprintf('Bilateral Fishbone — %d Nodes (%d MOLE-I) in %.1f km² Floor', ...
              n_total, n_total*5, crater.floor_area/1e6));
xlim([-3600 3600]); ylim([-3600 3600]);
set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 2 — Zoomed Detail (2 Junctions)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 2 — Junction Detail', 'Position', [1000 50 900 700]);
hold on; axis equal; grid on;

% Spine
plot([clp(1), spine_end_x], [0, 0], 'b-', 'LineWidth', 3);

% Cable clearance corridor
cor_x = [junctions(1,1)-200, spine_end_x, spine_end_x, junctions(1,1)-200];
cor_y = [-node.clearance, -node.clearance, node.clearance, node.clearance];
fill(cor_x, cor_y, [0.92 0.92 1.0], 'EdgeColor', [0.7 0.7 0.9], ...
     'LineStyle', ':', 'FaceAlpha', 0.3);
text(mean(cor_x(1:2)), node.clearance + 30, ...
     sprintf('Spine clearance corridor (±%dm)', node.clearance), ...
     'FontSize', 9, 'Color', [0.5 0.5 0.7], 'HorizontalAlignment', 'center');

% Focus on junctions 2-4
for j = 2:min(4, size(junctions, 1))
    plot(junctions(j,1), 0, 'b^', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    text(junctions(j,1), -40, sprintf('J%d', j), 'HorizontalAlignment', 'center', ...
         'FontSize', 9, 'Color', 'b', 'FontWeight', 'bold');
end

% Draw branches and nodes for junctions 2-4
for i = 1:length(all_cables)
    seg = all_cables{i};
    jx = seg(1,1);
    % Check if this branch belongs to junction 2-4
    jid = find(abs(junctions(:,1) - jx) < 1);
    if ~isempty(jid) && jid >= 2 && jid <= 4
        plot(seg(:,1), seg(:,2), '-', 'LineWidth', 2, 'Color', [0.3 0.55 0.75]);
    end
end

for i = 1:n_total
    nx = all_nodes(i, 1);
    ny = all_nodes(i, 2);
    jid = all_nodes(i, 3);
    ph = all_nodes(i, 6);
    
    if jid >= 2 && jid <= 4
        % Tether circle
        fill(nx + node.tether_r*cos(theta_circ), ny + node.tether_r*sin(theta_circ), ...
             ph_colors{ph}, 'FaceAlpha', 0.15, 'EdgeColor', ph_colors{ph}, 'LineWidth', 1);
        
        % Sector lines (72° divisions)
        for s = 0:4
            angle = s * 72 * pi/180;
            plot([nx, nx + node.tether_r*cos(angle)], [ny, ny + node.tether_r*sin(angle)], ...
                 '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
        end
        
        % Node marker
        plot(nx, ny, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
        text(nx, ny, sprintf('%d', i), 'HorizontalAlignment', 'center', 'FontSize', 7);
    end
end

xlabel('metres'); ylabel('metres');
title('Junction Detail — Bilateral Branches with 72° Sectors');
set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 3 — Phase Deployment Sequence
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 3 — Phase Deployment', 'Position', [50 800 1200 350]);

for p = 1:5
    subplot(1, 5, p);
    
    % Crater
    plot(crater.floor_r*cos(theta_circ)/1000, crater.floor_r*sin(theta_circ)/1000, ...
         'k-', 'LineWidth', 1.5);
    hold on; axis equal;
    
    % Spine (faded)
    plot([clp(1), spine_end_x]/1000, [0, 0], '-', 'LineWidth', 1, 'Color', [0.8 0.85 0.9]);
    
    % Active branches
    for i = 1:length(all_cables)
        seg = all_cables{i};
        jx = seg(1,1);
        jid = find(abs(junctions(:,1) - jx) < 1);
        % Check if any node on this branch is active
        if ~isempty(jid)
            branch_nodes = all_nodes(all_nodes(:,3)==jid, :);
            if any(branch_nodes(:,6) <= p)
                plot(seg(:,1)/1000, seg(:,2)/1000, 'b-', 'LineWidth', 1);
            end
        end
    end
    
    % Active nodes
    for i = 1:n_total
        if all_nodes(i, 6) <= p
            nx = all_nodes(i,1); ny = all_nodes(i,2);
            fill((nx + node.tether_r*cos(theta_circ))/1000, ...
                 (ny + node.tether_r*sin(theta_circ))/1000, ...
                 ph_colors{all_nodes(i,6)}, 'FaceAlpha', 0.3, ...
                 'EdgeColor', ph_colors{all_nodes(i,6)}, 'LineWidth', 0.6);
        end
    end
    
    plot(clp(1)/1000, 0, 'bs', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
    
    n_active = sum(all_nodes(:,6) <= p);
    title(sprintf('%s\n%d nodes / %d MI', phase.labels{p}, n_active, n_active*5), 'FontSize', 10);
    xlim([-3.5 3.5]); ylim([-3.5 3.5]);
    set(gca, 'XTick', [], 'YTick', []);
end
sgtitle('Phase Deployment — Fishbone Grows from CLP Inward', 'FontSize', 12);


%% ═══════════════════════════════════════════════════════════════════
%  FIGURE 4 — Scalability Test (How Many Nodes Can We Fit?)
% ═══════════════════════════════════════════════════════════════════
figure('Name','Fig 4 — Scalability', 'Position', [1000 800 700 400]);

% The layout already generated max nodes — just count by distance from CLP
distances = sqrt(sum((all_nodes(:,1:2) - clp).^2, 2));
[~, sort_idx] = sort(distances);

radii_test = 500:100:6000;
nodes_within = zeros(size(radii_test));
for k = 1:length(radii_test)
    nodes_within(k) = sum(distances <= radii_test(k));
end

plot(radii_test/1000, nodes_within, 'b-', 'LineWidth', 2.5);
hold on;
yline(34, 'r--', 'P7+ (34)', 'FontSize', 10, 'LineWidth', 1.5);
yline(17, 'Color', [0.8 0.5 0], 'LineStyle', '--', 'LineWidth', 1);
text(0.5, 18, 'P6 (17)', 'FontSize', 9, 'Color', [0.8 0.5 0]);
xlabel('Distance from CLP (km)');
ylabel('Nodes within radius');
title('Node Count vs Distance — Bilateral Fishbone Scalability');
grid on; set(gca, 'FontSize', 11);


%% ═══════════════════════════════════════════════════════════════════
%  SUMMARY
% ═══════════════════════════════════════════════════════════════════
fprintf('\n════════════════════════════════════════════════════════════════\n');
fprintf('  BILATERAL FISHBONE LAYOUT v3 SUMMARY\n');
fprintf('════════════════════════════════════════════════════════════════\n');
fprintf('  Topology:        Bilateral fishbone from CLP\n');
fprintf('  Spine:           %.1f km (CLP to last junction)\n', spine_len/1000);
fprintf('  Junctions:       %d at %d m spacing\n', size(junctions,1), spine.junction_spacing);
fprintf('  Branches:        %d (bilateral from each junction)\n', size(branch_info,1));
fprintf('  Nodes/branch:    %s (varies with crater wall proximity)\n', ...
    strjoin(arrayfun(@(x) sprintf('%d',x), branch_info(:,3)', 'UniformOutput', false), ','));
fprintf('  Total nodes:     %d (P7+ target: %d, P8+ target: %d)\n', ...
    n_total, phase.target(5), phase.target(6));
fprintf('  Min node-node:   %.0f m [%s]\n', min_nn, ternary(min_nn>=node.min_sep-10,'PASS','FAIL'));
fprintf('  Min to spine:    %.0f m [%s]\n', min_spine, ternary(min_spine>=node.buffer-5,'PASS','FAIL'));
fprintf('  Floor used:      %.1f%%\n', util_pct);
fprintf('  Cable total:     %.1f km (%.1f km dual-path)\n', ...
    (spine_len+branch_total)/1000, 2*(spine_len+branch_total)/1000);
fprintf('\n  ADVANTAGES:\n');
fprintf('    + Dense packing (all nodes within ~%.0f m of CLP)\n', max_clp);
fprintf('    + Trunk cable NEVER crosses any work zone\n');
fprintf('    + Scales to %d+ nodes without wall collision\n', n_total);
fprintf('    + Bilateral branches: both sides of every junction used\n');
fprintf('    + Simple cable management: spine + perpendicular branches\n');
fprintf('    + Phase deployment: grow spine → activate next junction pair\n');
fprintf('════════════════════════════════════════════════════════════════\n');


function result = ternary(cond, t, f)
    if cond, result = t; else, result = f; end
end