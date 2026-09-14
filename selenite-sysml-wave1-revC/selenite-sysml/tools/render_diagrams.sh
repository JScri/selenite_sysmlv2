#!/usr/bin/env bash
# Regenerate the committed SVG diagram set.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p diagrams
sysml-diagram export --file model/ProgrammeConfiguration.sysml --view gv \
    --workspace . --out diagrams/programme_general_view.svg
sysml-diagram export --file model/ProgrammeConfiguration.sysml --view iv \
    --anchor "SeleniteConfigurations::seleniteProgramme" \
    --workspace . --out diagrams/programme_interconnection_view.svg
sysml-diagram export --file model/ProgrammeRequirements.sysml --view gv \
    --workspace . --out diagrams/requirements_general_view.svg
sysml-diagram export --file model/RobotFleet.sysml --view gv \
    --workspace . --out diagrams/fleet_general_view.svg
sysml-diagram export --file model/Software.sysml --view gv \
    --workspace . --out diagrams/software_view.svg
echo "Diagrams written to diagrams/"
