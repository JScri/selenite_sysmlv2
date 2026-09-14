"""Physical and programme constants, single definition, one provenance comment per constant (source document + revision). Populated as each module is ported.

STATUS: not ported. Source is in selenite-goldens-runner-v2_1/ (see
README.md).
"""
from __future__ import annotations

PORTED = False
SOURCE_SCRIPT: str | None = None  # set to the .m filename when ported


def run(**params):
    """Return a flat {golden_key: value} mapping reproducing the oracle."""
    raise NotImplementedError("port pending: MATLAB source not yet ported")
