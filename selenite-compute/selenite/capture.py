"""Workspace capture that mirrors ``gold_flatten`` / ``gold_clean`` in
``selenite-goldens-runner-v2_1/gold_run_chain.m`` exactly, so a port module
can return its final workspace and be compared row by row with the goldens.

Rules reproduced from the MATLAB harness:

* structs flatten with ``.`` between levels (``ph.mi``); struct arrays
  (numel != 1) yield ``'ARRAY_OF_STRUCTS_SKIPPED'`` per field;
* char -> str; numeric/logical -> double;
* scalar -> the value; array with <= MAX_FULL elements -> ``mat2str(v(:)', 12)``,
  i.e. linearised in COLUMN-MAJOR order; larger arrays -> ``.numel``,
  ``.sum`` (NaN excluded), ``.min``, ``.max`` (MATLAB min/max ignore NaN),
  ``.mean`` (NaN excluded);
* function handles, objects, modules and cells are not captured (cells are
  captured to JSON but never reach the CSV).
"""
from __future__ import annotations

import math
import types
from typing import Any

import numpy as np

MAX_FULL = 2000


class StructArray(list):
    """A MATLAB struct array (list of dicts with the same fields)."""


class Summarised(np.ndarray):
    """An array the harness captured in statistics form (numel/sum/min/max/mean)
    because the MATLAB array exceeded MAX_FULL (e.g. ode45 output, which MATLAB
    refines to four points per step). The Python array may be shorter, so the
    port marks it explicitly."""

    def __new__(cls, a):
        return np.asarray(a, dtype=float).view(cls)


def _is_number(v: Any) -> bool:
    return isinstance(v, (bool, int, float, np.generic)) and not isinstance(v, (str, bytes))


def _keep(v: Any) -> bool:  # noqa: D103
    if v is None or callable(v) or isinstance(v, (types.ModuleType, type)):
        return False
    return _is_number(v) or isinstance(v, (str, dict, list, tuple, np.ndarray, StructArray))


def _flatten_into(flat: dict[str, Any], key: str, v: Any) -> None:
    if isinstance(v, StructArray):
        fields = list(v[0].keys()) if v else []
        for f in fields:
            flat[f"{key}.{f}"] = "ARRAY_OF_STRUCTS_SKIPPED"
        return
    if isinstance(v, dict):
        for f, sub in v.items():
            if _keep(sub):
                _flatten_into(flat, f"{key}.{f}", sub)
        return
    if isinstance(v, str):
        flat[key] = v
        return
    if isinstance(v, (list, tuple)):
        if v and all(isinstance(x, dict) for x in v):
            _flatten_into(flat, key, StructArray(v))
            return
        try:
            v = np.asarray(v, dtype=float)
        except (TypeError, ValueError):
            return  # a cell of mixed content: not in the CSV
    if _is_number(v):
        flat[key] = float(v)
        return
    if isinstance(v, np.ndarray):
        a = np.asarray(v, dtype=float)
        if isinstance(v, Summarised):
            a = a.reshape(-1)
            nonan = a[~np.isnan(a)]
            flat[f"{key}.numel"] = float(a.size)
            flat[f"{key}.sum"] = float(nonan.sum())
            flat[f"{key}.min"] = float(np.nanmin(a))
            flat[f"{key}.max"] = float(np.nanmax(a))
            flat[f"{key}.mean"] = float(nonan.mean()) if nonan.size else float("nan")
            return
        if a.size == 0:
            flat[key] = "zeros(1,0)"  # mat2str of an empty row, e.g. find() with no hit
        elif a.size == 1:
            flat[key] = float(a.reshape(-1)[0])
        elif a.size <= MAX_FULL:
            flat[key] = a.flatten(order="F")
        else:
            nonan = a[~np.isnan(a)]
            flat[f"{key}.numel"] = float(a.size)
            flat[f"{key}.sum"] = float(nonan.sum())
            flat[f"{key}.min"] = float(np.nanmin(a))
            flat[f"{key}.max"] = float(np.nanmax(a))
            flat[f"{key}.mean"] = float(nonan.mean()) if nonan.size else float("nan")
        return


def flatten(namespace: dict[str, Any]) -> dict[str, Any]:
    """Flatten a module's final workspace (e.g. ``locals()``) like the harness."""
    flat: dict[str, Any] = {}
    for name, v in namespace.items():
        if name.startswith("_") or name.startswith("GOLD_") or not _keep(v):
            continue
        _flatten_into(flat, name, v)
    return flat


def ternary(cond: Any, a: Any, b: Any) -> Any:
    return a if cond else b


def mceil(x: float) -> float:
    return float(math.ceil(x))
