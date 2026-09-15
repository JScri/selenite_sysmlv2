"""Port of ``SELENITE_VISUALIZE_v3_3.m``: bilateral fishbone MOLE-I node
layout on the Shackleton crater floor (spine junctions, perpendicular
branches, phase allocation, clearance checks, cable lengths, scalability
curve). Geometry only; the four figures are not drawn.

Oracle: ``SELENITE_VISUALIZE_v3_3.csv`` (66 rows). ``h_leg`` is a MATLAB
graphics-handle number array (session dependent) and is declared as a skip.
"""
from __future__ import annotations

import math

import numpy as np

from .capture import flatten

PORTED = True
SOURCE_SCRIPT = "SELENITE_VISUALIZE_v3_3.m"
SKIP_KEYS = {"h_leg": "MATLAB graphics handle numbers (session dependent)"}


_NOT_CAPTURED = ("junction_rows", "node_rows", "info_rows", "all_cables", "hits", "params")


def workspace(**params):
    """The script's final workspace (raw Python objects, before capture)."""
    crater = {"floor_r": 3250}
    crater["floor_area"] = math.pi * crater["floor_r"] ** 2
    node = {"tether_r": 200, "buffer": 50}
    node["clearance"] = node["tether_r"] + node["buffer"]
    node["min_sep"] = 2 * node["tether_r"] + 30
    node["units"] = 5
    spine = {"junction_spacing": 500, "branch_angle": 90}
    branch = {"node_spacing": 450, "first_offset": node["clearance"] + 20}
    clp = np.array([-crater["floor_r"] + 150, 0], dtype=float)
    spine_dir = np.array([1, 0], dtype=float)
    phase = {"labels": ["P3", "P4", "P5", "P6", "P7+", "P8+"], "target": np.array([2, 5, 10, 17, 34, 60], dtype=float)}
    theta_circ = np.linspace(0, 2 * math.pi, 300)

    # ---- spine junctions ---------------------------------------------------
    first_junction = 350
    max_junctions = 20
    junction_rows = []
    jx = clp[0] + first_junction
    jid = 0
    while jx < crater["floor_r"] * 0.85:
        jid = jid + 1
        junction_rows.append([jx, 0.0, float(jid)])
        jx = jx + spine["junction_spacing"]
    junctions = np.array(junction_rows)

    # ---- node placement ----------------------------------------------------
    node_rows = []          # [x, y, junction_id, branch_side, node_on_branch, phase]
    all_cables = []
    info_rows = []
    total_placed = 0
    for j in range(1, junctions.shape[0] + 1):
        jx = junctions[j - 1, 0]
        jy = junctions[j - 1, 1]
        for side in (+1, -1):
            n_on_branch = 0
            branch_cable_pts = [[jx, jy]]
            for k in range(1, 21):
                ny = jy + side * (branch["first_offset"] + (k - 1) * branch["node_spacing"])
                nx = jx
                if math.sqrt(nx ** 2 + ny ** 2) + node["tether_r"] > crater["floor_r"] - 50:
                    break
                too_close = False
                for m in range(1, len(node_rows) + 1):
                    if math.hypot(nx - node_rows[m - 1][0], ny - node_rows[m - 1][1]) < node["min_sep"] - 10:
                        too_close = True
                        break
                if not too_close:
                    total_placed = total_placed + 1
                    n_on_branch = n_on_branch + 1
                    hits = np.flatnonzero(total_placed <= phase["target"])
                    ph_id = int(hits[0]) + 1 if hits.size else len(phase["target"])
                    node_rows.append([nx, ny, float(j), float(side), float(k), float(ph_id)])
                    branch_cable_pts.append([nx, ny])
            branch_cable_pts = np.array(branch_cable_pts)
            if branch_cable_pts.shape[0] > 1:
                all_cables.append(branch_cable_pts)
            info_rows.append([float(j), float(side), float(n_on_branch)])
    all_nodes = np.array(node_rows)
    branch_info = np.array(info_rows)
    n_total = all_nodes.shape[0]

    # ---- junction breakdown ------------------------------------------------
    for j in range(1, junctions.shape[0] + 1):
        left = float(np.sum(branch_info[(branch_info[:, 0] == j) & (branch_info[:, 1] == 1), 2]))
        right = float(np.sum(branch_info[(branch_info[:, 0] == j) & (branch_info[:, 1] == -1), 2]))

    for p in range(1, len(phase["target"]) + 1):
        n_in_phase = float(np.sum(all_nodes[:, 5] <= p))
        status = "OK"
        if n_in_phase < phase["target"][p - 1]:
            status = "SHORT"

    # ---- clearance checks --------------------------------------------------
    min_nn = math.inf
    for i in range(1, n_total + 1):
        for j in range(i + 1, n_total + 1):
            d = float(np.linalg.norm(all_nodes[i - 1, 0:2] - all_nodes[j - 1, 0:2]))
            if d < min_nn:
                min_nn = d

    min_spine = math.inf
    for i in range(1, n_total + 1):
        d_spine = abs(all_nodes[i - 1, 1]) - node["tether_r"]
        if d_spine < min_spine:
            min_spine = d_spine

    min_branch = math.inf
    for i in range(1, n_total + 1):
        nx = all_nodes[i - 1, 0]
        ny = all_nodes[i - 1, 1]
        for j in range(1, junctions.shape[0] + 1):
            if junctions[j - 1, 0] != nx:
                d_branch_cable = abs(nx - junctions[j - 1, 0]) - node["tether_r"]
                if d_branch_cable < min_branch and d_branch_cable > 0:
                    min_branch = d_branch_cable

    util_pct = n_total * math.pi * node["tether_r"] ** 2 / crater["floor_area"] * 100
    max_dist = float(np.max(np.sqrt(np.sum(all_nodes[:, 0:2] ** 2, axis=1))))
    max_clp = float(np.max(np.sqrt(np.sum((all_nodes[:, 0:2] - clp) ** 2, axis=1))))

    spine_len = junctions[-1, 0] - clp[0]
    branch_total = 0.0
    for i in range(1, len(all_cables) + 1):
        seg = all_cables[i - 1]
        for k in range(2, seg.shape[0] + 1):
            branch_total = branch_total + float(np.linalg.norm(seg[k - 1, :] - seg[k - 2, :]))

    # ---- Fig 1 (data) ------------------------------------------------------
    spine_end_x = junctions[-1, 0] + 100
    for i in range(1, len(all_cables) + 1):
        seg = all_cables[i - 1]
    for j in range(1, junctions.shape[0] + 1):
        pass
    for i in range(1, n_total + 1):
        nx = all_nodes[i - 1, 0]
        ny = all_nodes[i - 1, 1]
        ph = all_nodes[i - 1, 5]
    for p in range(1, min(5, len(phase["target"])) + 1):
        pass

    # ---- Fig 2 (data) ------------------------------------------------------
    cor_x = np.array([junctions[0, 0] - 200, spine_end_x, spine_end_x, junctions[0, 0] - 200])
    cor_y = np.array([-node["clearance"], -node["clearance"], node["clearance"], node["clearance"]], dtype=float)
    for j in range(2, min(4, junctions.shape[0]) + 1):
        pass
    for i in range(1, len(all_cables) + 1):
        seg = all_cables[i - 1]
        jx = seg[0, 0]
        hits = np.flatnonzero(np.abs(junctions[:, 0] - jx) < 1)
        jid = float(hits[0]) + 1 if hits.size == 1 else hits + 1.0
    for i in range(1, n_total + 1):
        nx = all_nodes[i - 1, 0]
        ny = all_nodes[i - 1, 1]
        jid = all_nodes[i - 1, 2]
        ph = all_nodes[i - 1, 5]
        if 2 <= jid <= 4:
            for s in range(0, 5):
                angle = s * 72 * math.pi / 180

    # ---- Fig 3 (data) ------------------------------------------------------
    for p in range(1, 6):
        for i in range(1, len(all_cables) + 1):
            seg = all_cables[i - 1]
            jx = seg[0, 0]
            hits = np.flatnonzero(np.abs(junctions[:, 0] - jx) < 1)
            jid = float(hits[0]) + 1 if hits.size == 1 else hits + 1.0
            if hits.size:
                branch_nodes = all_nodes[all_nodes[:, 2] == jid, :]
        for i in range(1, n_total + 1):
            if all_nodes[i - 1, 5] <= p:
                nx = all_nodes[i - 1, 0]
                ny = all_nodes[i - 1, 1]
        n_active = float(np.sum(all_nodes[:, 5] <= p))

    # ---- Fig 4 (data) ------------------------------------------------------
    distances = np.sqrt(np.sum((all_nodes[:, 0:2] - clp) ** 2, axis=1))
    sort_idx = np.argsort(distances, kind="stable") + 1.0
    radii_test = np.arange(500, 6001, 100, dtype=float)
    nodes_within = np.zeros(radii_test.shape)
    for k in range(1, len(radii_test) + 1):
        nodes_within[k - 1] = np.sum(distances <= radii_test[k - 1])

    return dict(locals())


def run(**params):
    """Flattened workspace, keyed like the golden CSV."""
    ws = workspace(**params)
    return flatten({k: v for k, v in ws.items() if k not in _NOT_CAPTURED})
