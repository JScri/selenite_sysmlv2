#!/usr/bin/env python3
"""Build the Selenite upload ledger and document-family precedence table.

Precedence rule (agreed 8 Sep 2026):
  1. Revision identifier wins within a family (v9.1 > v9, Rev B > Rev A,
     _revised/_updated > base).
  2. Batch (folder) date breaks ties only between identically-labelled files,
     because folder dates reflect copying, not authorship.
  3. ECN-019 Rev C + ECN-020 is the architectural baseline; ECN-021 excluded.
  4. Markdown is authoritative over docx for the same revision.
Outputs: UPLOAD_LEDGER.csv (per file), DOCUMENT_FAMILIES.csv (per family).
"""
import csv, re, collections

# (batch_id, jason's label, date as given, files)
BATCHES = [
 ("B01","april 12th folder","2026-04-12", """SEL_PROBE_DESIGN_RevA_updated.docx selenite_extended_timeline_v3_revised.html W5_T4_3_JS_fleet_specs_summary.html W5_T4_4_JS_milestone_reference.html W5_T4_4_JS_scaling_P7_P14.html MTL_GUIDE_v18.md SEL_ROBOT_FLEET_v9.md SELENITE_DECISION_FRAMEWORK_v4.md SEL-T1_1-STRATEGY-v3_1.md MTL_GUIDE_v18.docx SEL_ARM_DESIGN_RevA_updated.docx SEL_DART_DESIGN_RevA_updated.docx SEL_HARVEST_DESIGN_RevA_updated.docx SEL_MOLEI_DESIGN_v5.docx SEL_MOLES_DESIGN_RevA_updated.docx selenite_value_chain_v14_1.html selenite_value_chain_v15.html selenite_value_chain_v16.html SEL-ECN-020_MassDriver_ParallelTracks.md selenite_programme_scope.md
   SEL-MOLEI-MkII-001_RevA.docx SEL_PROBE_DESIGN_RevB.docx SEL_ROBOT_FLEET_v9.docx SEL_SENTINEL_DESIGN_RevA_updated.docx SEL_SENTINEL_DESIGN_RevB.docx SEL_SINTER_DESIGN_RevA_updated.docx SEL_SKIP_DESIGN_RevA_updated.docx SEL_SURVEY_DESIGN_RevA_updated.docx SEL-CATAPULT-001_RevB.docx SEL-CON-001_RevB_updated.docx SEL-CONVEYOR-001_RevA.docx SEL-ECLSS-002_RevB.docx SEL-ECLSS-SCALING-001_RevB.docx SEL-ECON-001_RevA_revised.docx SEL-FAB-001_RevA.docx SEL-HAULER-001_RevB.docx SEL-ISRU-001_RevD_updated.docx SEL-IZ-001_RevB.docx SEL-CAP-001_RevA_updated.docx SEL-ECLSS-001_RevB.docx
   W3_T2_1_JS_ValueChain_v1_1.docx SEL-POWER-001_RevB.docx SEL-PROBE-MkII-001_RevA.docx SEL-PROBE-MkIII-001_RevA.docx SEL-PROC-001_RevB.docx SEL-REAGENT-001_RevA.docx SEL-SW-SENTINEL-001_RevB.docx SEL-PROC-PKT-001_RevB.docx"""),
 ("B02","11th march batch 1","2026-03-11", """SEL-CAD-PB-001_RevA.docx SEL-CAD-PS-001_RevA.docx SEL-CAD-PZ-001_RevA.docx SEL-CAD-SE-001_RevA.docx SEL-CAD-SK-001_RevA.docx SEL-CAD-SN-001_RevA.docx SEL-ECLSS-002_RevA.docx SEL-ECLSS-SCALING-001_RevA.docx SEL-ELZ-001_RevA.docx SEL-HAB-001_RevD.docx SEL-ISRU-001_RevD.docx SEL-IZ-001_RevA.docx SEL-PIPE-001_RevA.docx SEL-POWER-001_RevA.docx SEL-SW-SENTINEL-001_RevA.docx SEL-T1_1-STRATEGY-v2_6.docx W2_T1_1_JS_MTL_GUIDE_v17.docx W3_T2_1_JS_ValueChain_v1_0.docx SEL-SW-SENTINEL-001_ECN014.docx SELENITE_CROSS_DOC_AUDIT.docx"""),
 ("B03","11th march batch 2","2026-03-11", """SEL_ARM_DESIGN_RevA.docx SEL_DART_DESIGN_RevA.docx SEL_HARVEST_DESIGN_RevA.docx SEL_MOLEI_DESIGN_v5.docx SEL_MOLES_DESIGN_RevA.docx SEL_PROBE_DESIGN_RevA.docx SEL_ROBOT_FLEET_v8.docx SEL_SENTINEL_DESIGN_RevA.docx SEL_SINTER_DESIGN_RevA.docx SEL_SKIP_DESIGN_RevA.docx SEL_SURVEY_DESIGN_RevA.docx SEL-CAD-AC-001_RevA.docx SEL-CAD-AD-001_RevA.docx SEL-CAD-DT-001_RevA.docx SEL-CAD-ELZ-001_RevA.docx SEL-CAD-HAB-001_RevA.docx SEL-CAD-HV-001_RevA.docx SEL-CAD-IZ-001_RevA.docx SEL-CAD-MS-001_RevA.docx SEL-CAD-ISRU-001_RevA.docx"""),
 ("B04","11th march batch 3","2026-03-11", """SELENITE_VISUALIZE_v3_3.m selenite_value_chain_v14.html W2_T1_1_JS_MTL_v8_5.html sabatier.m scaling.m scaling_v1_2.m scaling_v1_3.m SELENITE_AUDIT_RESOLVE.m SELENITE_VERIFY_v5_0.m"""),
 ("B05","11th march / pre-ecn014","2026-03-11", """SEL-POWER-001_RevA.docx SEL-CAD-IZ-001_RevA.docx SEL-HAB-001_RevD.docx SEL-ISRU-001_RevD.docx SEL-IZ-001_RevA.docx SEL-CAD-ISRU-001_RevA.docx"""),
 ("B06","11th march / ecn-015-016-017 fab-haul-cata","2026-03-11", """SEL_ROBOT_FLEET_ECN016.docx selenite_extended_timeline.html SEL-PIPE-001_RevA.docx SEL-PROC-001_RevA.docx updated_SEL-CAD-IZ-001_RevA.docx updated_SEL-ECLSS-002_RevA.docx updated_SEL-ECLSS-SCALING-001_RevA.docx updated_SEL-ELZ-001_RevA.docx updated_SEL-HAB-001_RevD.docx updated_SEL-ISRU-001_RevD.docx updated_SEL-IZ-001_RevA.docx updated_SEL-POWER-001_RevA.docx updated_SEL-T1_1-STRATEGY-v2_6.docx updated_W2_T1_1_JS_MTL_GUIDE_v17.docx SEL-PROC-PKT-001_RevA.docx SEL-HAULER-001_RevA.docx updated_W3_T2_1_JS_ValueChain_v1_0.docx updated_SEL-CAD-ISRU-001_RevA.docx SEL-CATAPULT-001_RevA.docx updated_SEL-SW-SENTINEL-001_ECN014.docx"""),
 ("B07","4th april batch 1","2026-04-04", """SELENITE_ECON_V1_3.m selenite_extended_timeline_v2.html selenite_extended_timeline_v3.html compass_artifact_wf-0de39b9e.md compass_artifact_wf-0ed1ff48.md compass_artifact_wf-2ccba0e0.md compass_artifact_wf-489c50ff.md compass_artifact_wf-d62dc23b.md compass_artifact_wf-d64817b5.md compass_artifact_wf-fe9fecf5.md ECN-018_InSitu_Reagent_Fabrication_PGM__1_.md ECN-018_InSitu_Reagent_Fabrication_PGM.md ECN-019_Programme_Wide_Design_Revision.md SELENITE_DECISION_FRAMEWORK_v3.md SELENITE_ECON_V1.m SELENITE_ECON_v1_0.m SELENITE_ECON_V1_1.m SELENITE_ECON_V1_2.m SELENITE_DOC_UPDATE_SESSION_PROMPTS.md SELENITE_DOCUMENT_INVENTORY.md"""),
 ("B08","4th april batch 2","2026-04-04", """SELENITE_ECON_v1_4_tornado.png SELENITE_ECON_V1_4.m MTL_GUIDE_v18.docx SEL_ROBOT_FLEET_v9.docx SEL-ECON-001_RevA.docx SEL-T1_1-STRATEGY-v3_0.docx SELENITE_ECON_v1_1_costs.png SELENITE_ECON_v1_1_environmental.png SELENITE_ECON_v1_1_overview.png SELENITE_ECON_v1_1_sensitivity.png SELENITE_ECON_v1_2_cargo_breakdown.png SELENITE_ECON_v1_2_environmental.png SELENITE_ECON_v1_2_infrastructure.png SELENITE_ECON_v1_2_overview.png SELENITE_ECON_v1_3_cargo.png SELENITE_ECON_v1_3_environmental.png SELENITE_ECON_v1_3_net_benefit.png SELENITE_ECON_v1_3_overview.png"""),
 ("B09","w5 folder","2026-03-23", """W5_Task_4_1_Oluchi_ISRU_workflow.docx W5_T4_3_JS_fleet_specs_summary.html W5_T4_4_JS_construction_phasing_gantt.html W5_T4_4_JS_milestone_reference.html W5_T4_4_JS_scaling_P7_P12.html W5_T4_6_VL_PowerSystemsBrief_v1_0_2026_03_22.docx selenite_autonomous_ops_framework.html selenite_programme_scope.md W5_T4_3_JS_fleet_count_P3toP7.html W5_T4_4_JS_expansion_P4_P7.html"""),
 ("B10","10th march","2026-03-10", """W2_T1_1_JS_MTL_GUIDE_v17.docx W2_T1_1_JS_MTL_v8_3.html SEL_SUBSTATION_SOLIDWORKS_GUIDE.md SELENITE_VERIFY_v5.m SEL_MOLEI_DESIGN_v5.docx SEL_ROBOT_FLEET_v8.docx SEL_SUBSTATION_DESIGN_v4.docx SEL-CAP-001_CraterAccessPod_RevA.docx SEL-CON-001_PSR_Construction_Logistics_RevB.docx SEL-ECLSS-002_RevA.docx SEL-ECN-012_DrainPipeReroute_v1.docx SEL-HAB-001_RevD.docx SEL-ISRU-001_RevD.docx SEL-SW-MOLEI-001_RevD.docx SEL-SW-SUB-001_RevC.docx SEL-T1_1-STRATEGY-v2_6.docx SEL-ECN-013_Navigation_ARMfix_RFconstruction_v1.docx SEL-NAV-001_MOLEI_Navigation_RevA.docx"""),
 ("B11","9th march","2026-03-09", """substation_3d_render.html SEL-SW-SUB-001_RevA.docx MOLEI_ISO.png mole_i_3d_render_v2.html mole_i_3d_render.html SEL-ISRU-001_RevC.docx substation_design_v3.jsx mole_i_design_v3.jsx SEL-T1_1-STRATEGY-v2_5.docx SEL_ROBOT_FLEET_v6.docx SEL-SW-MOLEI-001_RevB.docx SEL_SUBSTATION_DESIGN_v2.docx SEL_MOLEI_DESIGN_v3.docx MOLEI_THERMAL_v1_3.m SELENITE_VERIFY_v4_5.m W2_T1_1_JS_MTL_GUIDE_v16.docx conductor_tables.jsx conductor_tables_reference.html SEL-ECLSS-001_RevA.docx"""),
 ("B12","main folder (9th march unless noted)","2026-03-09", """SEL_FINAL_REPORT_v4.docx sabatier.m W2_T1_1_JS_MTL_v8_4.html SEL-ISRU-001_RevA.docx SEL-HAB-001_RevB.docx mole-i-3d-render.html SELENITE_VERIFY_v4_5.m SELENITE_VERIFY_v4_4.m molei_thermal_v1_3.m high_level_base_layout_v2.png SEL_ROBOT_FLEET_v5.docx SEL-T1_1-STRATEGY-v2_4.docx W2_T1_1_JS_MTL_GUIDE_v16.docx"""),
 ("B13","8th march","2026-03-08", """SEL-SW-MOLEI-001_RevA.docx SELENITE_VERIFY_v4_3.m molei_thermal_v1_2.m molei_thermal_v1.m SEL_MOLEI_DESIGN_v1.docx SEL_SUBSTATION_DESIGN_v1.docx W3_T2_1_JS_ValueChain_v1_0.docx W2_T1_1_JS_MTL_v8_2.html SEL-T1_1-STRATEGY-v2_3.docx W2_T1_1_JS_MTL_GUIDE_v15.docx high_level_base_layout.png base_layout.pptx SEL_ROBOT_FLEET_v4.docx SELENITE_VERIFY_v4_2.m SELENITE_VERIFY_v4_1.m selenite_value_chain_v14.html selenite_value_chain_v13.html SELENITE_VERIFY_v4.m molei_thermal_v1_1.m 1_2_propellant_econ_prefab_v3_2.docx"""),
 ("B14","7th march","2026-03-07", """SELENITE_VERIFY_v3.m substation_design.jsx SEL_ROBOT_FLEET_v3_1.docx SELENITE_VISUALIZE_v3_3.m SELENITE_VISUALIZE_v3_2.m SELENITE_VISUALIZE_v3.m"""),
 ("B15","5th march (value chain v7 = 6th)","2026-03-05", """selenite_value_chain_v7.html SELENITE_VERIFY_v2.m W2_T1_1_JS_MTL_v8_1.html SEL_ROBOT_FLEET_v2_6.docx W2_T1_1_JS_GUIDE_v14.docx strat_doc_v2_1.docx v2_demand_comp_by_phase.jpg v2_power_budget.jpg v2_probe_propellant_vs_missionDV.jpg v2_molei_yield_sens.jpg v2_skip_ballistic_hop.jpg v2_propellant_balance_by_phase.jpg"""),
 ("B16","3rd march (audit = 4th)","2026-03-03", """Selenite_Programme_Technical_Audit__23_Claims_Flagged_Across_10_Domains.pdf selenite_8x8x8_v4.html SELENITE_VERIFY.m SEL_ROBOT_FLEET_v2_2.docx W2_T1_1_JS_GUIDE_v12.docx W2_T1_1_JS_MTL_v6.html annual_processed_output_by_phase.jpg mole-i_yield_sensitivity.jpg propellant_balance_by_phase.jpg probe_propellant_vs_deltaV.jpg power_budget.jpg"""),
 ("B17","1st march","2026-03-01", """Selenite_Programme__Engineering_Specifications_for_an_Autonomous_Lunar_Base.pdf SEL_ROBOT_FLEET_v2_1.docx W2_T1_1_JS_MTL_v5.html W2_T1_1_JS_MTL_v4.html MTL_bar_hovers.docx W2_T1_1_JS_GUIDE_v11.docx"""),
 ("B18","28th feb","2026-02-28", """W2_T1_6_VL_AutonomousAISys_V1_0_2026_02_27.docx selenite_timeline_guide_v4.docx selenite_mission_timeline_v4.html selenite_mission_timeline_v3.html W2_T1_2_JS_ITER-ISS_v1_0_2026_02_28.docx selenite_mission_timeline_v2.html W2_T1_6_OO_CircularEconomy_v1_0_2026-02-27.docx selenite_mission_timeline.html ishola-et-al-2021-legal-enforceability.pdf Studies_in_International_Space.pdf 9789047419464-13074.pdf W2_T1_6_ASC_SpaceRobotics_v1_0_2026-02-27.docx W2_T1_6_RT_LifeSupport_v1_0_2026-03-01.docx W2_T1_6_JS_InternationalSpaceGovernance_v1_0_2026-02-28.docx"""),
 ("B19","20-23 feb (concept/pitch)","2026-02-22", """pitch_madma-JS-laptop.html JSTEWART_-_Selenite_pitch.docx artifact2_pitch_updated.html selenite_master_v2.html artifact1_submission.html artifact2_pitch.html artifact3_semester.html asteroid_cba.html selenite_brief04_automation.html selenite_design_briefs.html selenite_missing40.html selenite_master.html pitch_selection_louis_reard_group.pdf pitch_selection_louis_reard_group.docx pitch_madma.html selenite_deliverables.txt evaluation_strategy.txt artifact2_pitch_edited.html how_pitch.docx how_pitch_v2.docx"""),
 ("B20","GIS site selection","2026-03-16", """W4_T3_3_JS_Selenite_site_selection_v1.png W4_T3_3_JS_Selenite_site_selection_v1.docx"""),
 ("B21","downloads, mid-late april","2026-04-20", """selenite_timeline_condensed.html W6_T5_4_RT_foodclosedloop_v1_2026-03-29.docx selenite_lh2_transport_v4__1_.pdf Selenite_Base_Floor_Plan_v2_1.pdf probe_ops_3d_render_v1__1_.html W5_T4_4_JS_scaling_P7_P12.html W5_T4_4_JS_milestone_reference.html W5_T4_4_JS_expansion_P4_P7.html W5_T4_3_JS_fleet_specs_summary.html W5_T4_4_JS_construction_phasing_gantt.html selenite_timeline_condensed__1_.html selenite_lh2_transport_v4.pdf W7_T6_1_NB_Sankey_Material_Flow_Diagram_.pdf probe_ops_3d_render_v1.html W5_T4_3_JS_fleet_count_P3toP7.html selenite_eclss_circularity.html selenite_programme_overview.html selenite_water_loop.jpg"""),
 ("B22","downloads, early april","2026-04-05", """SELENITE_DOC_UPDATE_SESSION_PROMPTS__1_.md selenite_extended_timeline_v3_revised__1_.html MTL_GUIDE_v18_revised__1_.docx Cochlear_form-f17b.docx SEL-IZ-001_RevB.docx SEL-PROC-001_RevB.docx SEL-CATAPULT-001_RevB.docx SEL_PROBE_DESIGN_RevA_updated.docx SEL_SENTINEL_DESIGN_RevA_updated.docx SELENITE_DECISION_FRAMEWORK_v4.md MTL_GUIDE_v18_revised.docx SEL-ECON-001_RevA_revised.docx selenite_extended_timeline_v3_revised.html SEL_ROBOT_FLEET_v9-1.docx SEL_ROBOT_FLEET_ECN019.docx SEL-ECON-001_Economic_Evaluation_Report__1_.md HAULER_SPEC_UPDATE_BRIEF.md selenite_briefing_scene_v2.md SEL-PROC-PKT-001_RevB__1_.docx SEL-PROC-PKT-001_RevB.docx"""),
 ("B23","late march / early april","2026-04-01", """probe_ops_3d_render_v1.html ECN-019_Programme_Wide_Design_Revision__1_.md SELENITE_ECON_v1_4.m SELENITE_ECON_v1_3.m selenite_extended_timeline_v2.html SEL-ECON-001_Economic_Evaluation_Report.md SELENITE_DECISION_FRAMEWORK_v2.md ECN-019_Programme_Wide_Design_Revision.md SELENITE_DOC_UPDATE_SESSION_PROMPTS.md The_bases_of_social_power.pdf 49069_SYD_2026_AUT_-_Lecture_05_-_PersuasionNegotiation__1_.pdf 49069_2026_SYD_AUT_Task_3_DiscussionBoard.pdf W5_T4_4_JS_scaling_P7_P12.html W5_T4_4_JS_milestone_reference.html W5_T4_4_JS_construction_phasing_gantt.html W5_T4_3_JS_fleet_specs_summary.html W6_T5_7_JS_PROBE_Concept_Brief.docx W5_T4_4_JS_expansion_P4_P7.html selenite_programme_scope.md W5_T4_3_JS_fleet_count_P3toP7.html"""),
 ("B24","march (day unknown)","2026-03-15", """SEL_ROBOT_FLEET_v2_7.docx arm_d_3d_render_v1.html SEL-FP-HAB-001_RevB.html selenite_8x8x8_v4.html SEL_SINTER_DESIGN_RevA.docx SEL-T1_1-STRATEGY-v2_6.docx W2_T1_1_JS_MTL_GUIDE_v17.docx mole_i_3d_render_v2.html substation_3d_render.html SEL-ECN-012_DrainPipeReroute_v1.docx SEL-HAB-001_RevA.docx W3_T2_1_JS_ValueChain_v1_0.docx strat_doc_v2_3__1_.docx strat_doc_v2_3.docx W2_T1_1_JS_GUIDE_v15__2_.docx W2_T1_1_JS_GUIDE_v15__1_.docx SEL_ROBOT_FLEET_v3_2.docx SEL_EVA_CONTINGENCY_CORRECTED.docx W2_T1_1_JS_GUIDE_v15.docx SEL-HAB-WALL-XSECTION-001_1.html"""),
 ("B25","early march and before","2026-03-01", """selenite_madm.html selenite_value_chain_v1_static.svg SEL_TECHREF_v1.docx SEL_Verification_Audit_v1.docx W2_T1_1_JS_GUIDE_v12__1_.docx W2_T1_1_JS_GUIDE_v12.docx selenite_timeline_guide_v11.docx selenite_mission_timeline_v3.html selenite_timeline_guide.docx pitch_selection_louis_reard_group-2.pdf selenite_delivery_plan.html JSTEWART_-_Selenite_pitch.docx T1_2_ITER_ISS_Governance_Summary.docx"""),
 ("B26","construction phasing subdir (dup)","2026-03-23", """W5_T4_4_JS_scaling_P7_P12.html W5_T4_4_JS_construction_phasing_gantt.html W5_T4_4_JS_milestone_reference.html selenite_programme_scope.md W5_T4_4_JS_expansion_P4_P7.html"""),
]

EXCLUDED = {"Cochlear_form-f17b.docx": "accidental upload",
            "selenite_briefing_scene_v2.md": "novel material — never enters the repo"}
OUT_OF_SCOPE_PAT = re.compile(r"^(49069_|The_bases_of_social_power|ishola|Studies_in_International|9789047419464|pitch_|JSTEWART|how_pitch|artifact\d|evaluation_strategy|selenite_deliverables|selenite_missing40|selenite_master|selenite_design_briefs|selenite_brief04|selenite_madm|selenite_delivery_plan)", re.I)
REFERENCE_PAT = re.compile(r"^(W\d_T\d_\d_(?!JS_)|W\d_Task_|compass_artifact|T1_2_ITER|Selenite_Programme__Engineering|Selenite_Programme_Technical_Audit|SEL_TECHREF|SEL_Verification_Audit|SELENITE_CROSS_DOC_AUDIT|SELENITE_DOCUMENT_INVENTORY|SELENITE_DOC_UPDATE|HAULER_SPEC_UPDATE|1_2_propellant)", re.I)

# Programme-scope.md exists in two incompatible versions: the ECN-019 Rev C
# rewrite (B01) and the pre-ECN-019 original (B09/B23/B26). Filenames identical.
SCOPE_OVERRIDE = {("selenite_programme_scope.md","B01"): "1.0", ("selenite_programme_scope.md","B09"): "0.9",
                  ("selenite_programme_scope.md","B23"): "0.9", ("selenite_programme_scope.md","B26"): "0.9"}
# Same-name, different-content amendments folded into later docs
ALIASES = {"guide": "mtl_guide", "selenite_timeline_guide": "mtl_guide", "selenite_mission_timeline": "mtl",
           "strat_doc": "sel-t1_1-strategy", "molei_thermal": "molei_thermal", "mole-i-3d-render": "mole_i_3d_render",
           "scaling": "selenite_scale", "sel-cap-001_crateraccesspod": "sel-cap-001",
           "sel-con-001_psr_construction_logistics": "sel-con-001", "sel-nav-001_molei_navigation": "sel-nav-001",
           "sel-ecn-012_drainpipereroute": "sel-ecn-012", "sel-ecn-013_navigation_armfix_rfconstruction": "sel-ecn-013",
           "sel-ecn-020_massdriver_paralleltracks": "sel-ecn-020", "ecn-019_programme_wide_design_revision": "ecn-019",
           "ecn-018_insitu_reagent_fabrication_pgm": "ecn-018", "sel-econ-001_economic_evaluation_report": "sel-econ-001-report"}
REV_LETTER = {c: i+1 for i, c in enumerate("ABCDEFGH")}

def parse(fname):
    base = re.sub(r"\.(docx|md|html|m|pdf|png|jpg|jsx|svg|txt|pptx)$", "", fname, flags=re.I)
    dup = bool(re.search(r"(__\d_|_\(\d\)|-2$|_1$)", base))
    base = re.sub(r"(__\d_|_\(\d\)|-2$)", "", base)
    mod = 0.0
    if base.startswith("updated_"): mod = 0.2; base = base[8:]
    if re.search(r"_updated$", base, re.I): mod = 0.2; base = re.sub(r"_updated$", "", base, flags=re.I)
    if re.search(r"_revised$", base, re.I): mod = 0.2; base = re.sub(r"_revised$", "", base, flags=re.I)
    if re.search(r"_CORRECTED$", base):     mod = 0.2; base = re.sub(r"_CORRECTED$", "", base)
    rev = 0.0; label = "-"
    m = re.search(r"_Rev([A-H])$", base)
    if m: rev = REV_LETTER[m.group(1)]; label = "Rev " + m.group(1); base = base[:m.start()]
    else:
        m = re.search(r"[_-][vV](\d+)(?:[_.\-](\d+))?$", base)
        if m:
            rev = int(m.group(1)) + (int(m.group(2))/10 if m.group(2) else 0)
            label = "v" + m.group(1) + ("." + m.group(2) if m.group(2) else "")
            base = base[:m.start()]
    m = re.search(r"_ECN(\d{3})$", base)
    if m: label = "ECN-" + m.group(1); base = base[:m.start()] + "_ecn"; rev = int(m.group(1))
    fam = base.lower()
    fam = re.sub(r"^w\d_t\d_\d_js_", "", fam)          # Jason's course-prefixed engineering docs
    fam = re.sub(r"_1$", "", fam)
    fam = ALIASES.get(fam, fam)
    return fam, rev + mod, (label + ("+" if mod else "")), dup

rows = []
for bid, blabel, bdate, files in BATCHES:
    for f in files.split():
        fam, rev, label, dup = parse(f)
        if (f, bid) in SCOPE_OVERRIDE: rev = float(SCOPE_OVERRIDE[(f, bid)]); label = "ECN-019 rewrite" if rev == 1.0 else "pre-ECN-019"
        rows.append(dict(file=f, batch=bid, batch_label=blabel, batch_date=bdate, family=fam, rev=rev, rev_label=label, dup_marker=dup))

# Status
fams = collections.defaultdict(list)
for r in rows: fams[r["family"]].append(r)
seen_names = set()
for fam, rs in fams.items():
    rs.sort(key=lambda r: (r["rev"], r["batch_date"], not r["dup_marker"]), reverse=True)
    top = rs[0]["rev"]
    for r in rs:
        f = r["file"]
        if f in EXCLUDED: r["status"] = "EXCLUDED"; r["note"] = EXCLUDED[f]; continue
        if OUT_OF_SCOPE_PAT.search(f): r["status"] = "OUT_OF_SCOPE"; r["note"] = "course/pitch/legal context"; continue
        key = re.sub(r"(__\d_|_\(\d\))", "", f)
        if key in seen_names: r["status"] = "DUPLICATE"; r["note"] = "same file uploaded again"; continue
        seen_names.add(key)
        if re.search(r"\.(png|jpg|svg)$", f, re.I): r["status"] = "FIGURE"; r["note"] = "rendered output, not a source"; continue
        if fam.endswith("_ecn"): r["status"] = "AMENDMENT"; r["note"] = "folded into the parent family's later revision"; continue
        if re.search(r"^(W2_T1_6_|W2_T1_2_|W5_Task_4_1|W5_T4_6_|W6_T5_4_|W7_T6_1_)", f): r["status"] = "TEAM_INPUT"; r["note"] = "team contribution; carries weight via the final report"; continue
        if fam == "selenite_value_chain" and r["rev"] >= 14.1: r["status"] = "AUTHORITATIVE"; r["note"] = "scope-split: v14.1=P0-P7, v15=P7-P12, v16=P13+"; continue
        if REFERENCE_PAT.search(f): r["status"] = "REFERENCE"; r["note"] = "team/course research or audit — informs, not authoritative"; continue
        if r["rev"] == top: r["status"] = "AUTHORITATIVE"; r["note"] = "family winner"
        elif f.endswith(".m"): r["status"] = "HISTORICAL"; r["note"] = "kept for goldens/value tracing"
        else: r["status"] = "SUPERSEDED"; r["note"] = ""

with open("UPLOAD_LEDGER.csv", "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=["file","family","rev_label","status","batch","batch_date","batch_label","note"])
    w.writeheader()
    for r in sorted(rows, key=lambda r: (r["family"], -r["rev"], r["file"])):
        w.writerow({k: r[k] for k in w.fieldnames})

with open("DOCUMENT_FAMILIES.csv", "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["family","winner_file","winner_rev","winner_batch_date","n_files","superseded_revs","status"])
    for fam in sorted(fams):
        rs = fams[fam]
        auth = [r for r in rs if r["status"] == "AUTHORITATIVE"]
        stat = auth[0]["status"] if auth else rs[0]["status"]
        win = auth[0] if auth else rs[0]
        older = sorted({r["rev_label"] for r in rs if r["rev"] < win["rev"]})
        w.writerow([fam, win["file"], win["rev_label"], win["batch_date"], len(rs), " ".join(older), stat])

c = collections.Counter(r["status"] for r in rows)
print(f"files: {len(rows)}  families: {len(fams)}"); print(dict(c))
