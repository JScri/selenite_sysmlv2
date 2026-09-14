"""Verifies the MATLAB sources in the runner folder match the hashes recorded when the goldens were captured."""
import hashlib
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "selenite-goldens-runner-v2_1"
MANIFEST = ROOT / "selenite-goldens-oracle" / "oracle" / "matlab_r2025a" / "manifest.json"


def _expected():
    return {s["file"]: s["sha256"] for s in json.loads(MANIFEST.read_text())["scripts"] if s["status"] == "ok"}


@pytest.mark.parametrize("name,sha", sorted(_expected().items()))
def test_source_hash(name, sha):
    p = SOURCES / name
    if not p.exists():
        pytest.fail(f"{name} missing from selenite-goldens-runner-v2_1/")
    assert hashlib.sha256(p.read_bytes()).hexdigest() == sha, f"{name} differs from the script that produced the goldens"
