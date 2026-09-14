#!/usr/bin/env bash
# Validate the entire model tree with cross-file resolution.
# Usage: tools/validate.sh [extra sysml-validate flags]
set -euo pipefail
cd "$(dirname "$0")/.."
sysml-validate model --workspace . --all "$@"
