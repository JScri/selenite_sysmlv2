#!/usr/bin/env bash
# Regenerate the committed SVG diagram set (sysml-diagram 0.42.0; see validate.yml).
# Wave 4B (7 Nov 2026): general views for every package the wave touched, the
# action-flow views (afv) of the value chain and the NAV-001 fusion, and the
# state-transition views (stv) of the SENTINEL and ECN-014 machines. 0.42.0
# supports gv | iv | afv | stv | sv | cv | gev | grv (export --help).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p diagrams
render() {  # render <file> <view> <out> [anchor]
    if [ $# -ge 4 ]; then
        sysml-diagram export --file "$1" --view "$2" --anchor "$4" --workspace . --out "$3"
    else
        sysml-diagram export --file "$1" --view "$2" --workspace . --out "$3"
    fi
}
# ---- Waves 1-4A ----
render model/ProgrammeConfiguration.sysml gv diagrams/programme_general_view.svg
render model/ProgrammeConfiguration.sysml iv diagrams/programme_interconnection_view.svg "SeleniteConfigurations::seleniteProgramme"
render model/ProgrammeRequirements.sysml gv diagrams/requirements_general_view.svg
render model/RobotFleet.sysml gv diagrams/fleet_general_view.svg
render model/Software.sysml gv diagrams/software_view.svg
render model/Gates.sysml gv diagrams/gates_view.svg
render model/Scenarios.sysml gv diagrams/scenarios_view.svg
# ---- Wave 4B: structure views for the files V-N9 listed without one ----
render model/Interfaces.sysml gv diagrams/interfaces_view.svg
render model/Behaviour.sysml gv diagrams/behaviour_view.svg
render model/Processing.sysml gv diagrams/processing_view.svg
render model/Habitat.sysml gv diagrams/habitat_view.svg
render model/Transport.sysml gv diagrams/transport_view.svg
render model/PsrNetwork.sysml gv diagrams/psr_network_view.svg
render model/Power.sysml gv diagrams/power_view.svg
render model/Sites.sysml gv diagrams/sites_view.svg
# ---- Wave 4B: action-flow views ----
render model/Behaviour.sysml afv diagrams/value_chain_action_flow.svg "SeleniteBehaviour::ValueChain"
render model/Behaviour.sysml afv diagrams/psr_ice_to_propellant_action_flow.svg "SeleniteBehaviour::PsrIceToPropellant"
render model/Behaviour.sysml afv diagrams/pkt_kreep_to_earth_action_flow.svg "SeleniteBehaviour::PktKreepToEarth"
render model/Behaviour.sysml afv diagrams/captured_asteroid_action_flow.svg "SeleniteBehaviour::CapturedAsteroidToProducts"
render model/Software.sysml afv diagrams/nav001_fusion_action_flow.svg "SeleniteSoftware::NavigationFusion"
# ---- Wave 4B: state-transition views ----
render model/Software.sysml stv diagrams/supervision_location_states.svg "SeleniteSoftware::SupervisionLocation"
render model/Software.sysml stv diagrams/sentinel_modes_states.svg "SeleniteSoftware::SentinelOperatingModes"
render model/Software.sysml stv diagrams/cryo_valve_station_states.svg "SeleniteSoftware::CryoValveStationStates"
render model/Software.sysml stv diagrams/o2_supply_line_states.svg "SeleniteSoftware::O2SupplyLineStates"
render model/Software.sysml stv diagrams/molei_operating_states.svg "SeleniteSoftware::MoleIOperatingStates"
# ---- Wave 4B addendum (7 Nov 2026): behaviour bound from the sources now in docs/ ----
render model/Software.sysml afv diagrams/anomaly_workflow_action_flow.svg "SeleniteSoftware::AnomalyResponseWorkflow"
render model/Software.sysml afv diagrams/construction_tap_hop_action_flow.svg "SeleniteSoftware::ConstructionTapHop"
render model/Software.sysml stv diagrams/earth_contact_states.svg "SeleniteSoftware::EarthContactStates"
render model/Software.sysml stv diagrams/molei_comms_states.svg "SeleniteSoftware::MoleICommsStates"
render model/Software.sysml stv diagrams/bayonet_engagement_states.svg "SeleniteSoftware::BayonetEngagementStates"
render model/Software.sysml stv diagrams/tether_port_states.svg "SeleniteSoftware::TetherPortStates"
render model/Software.sysml stv diagrams/cap_mission_states.svg "SeleniteSoftware::CapMissionStates"
echo "Diagrams written to diagrams/"
