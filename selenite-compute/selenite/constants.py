"""Physical and programme constants — single definition, one provenance line each.

Values are transcribed from the MATLAB sources they are cited to; the port
reproduces the goldens and never re-derives a figure (docs/SESSION_BRIEF_python_port.md).
"""

# --- Molecular masses (g/mol), sabatier.m lines 24-25 -----------------------
M_CO2 = 44.01
M_H2 = 2.016
M_CH4 = 16.04
M_H2O = 18.015
M_O2 = 32.00

# --- Crew metabolic rates (kg per crew-member-day), NASA BVAD via sabatier.m 17-21
CO2_PER_CM = 1.0        # 82 kg crew, 90 min exercise
O2_PER_CM = 0.84
H2O_PER_CM = 5.0        # total water consumption
H2O_RECOVERABLE_PER_CM = 4.88   # WRS input streams
WRS_RECOVERY = 0.93     # 93 % water recovery

# --- Greenhouse (48 m2, NASA BPC mixed crop), sabatier.m 38-41 ---------------
GH_CO2_LOW = 1.4
GH_CO2_HIGH = 1.9
GH_CO2_NOM = 1.65
GH_O2_NOM = 1.2

# --- OGA / electrolysis energy, sabatier.m 96 (52.5 kWh per kg H2) -----------
OGA_KWH_PER_KG_H2 = 52.5

# --- Propellant / ISRU, sabatier.m 237-262 ----------------------------------
RHO_LH2 = 70.8          # kg/m3
WATER_PER_MOLEI_KG_YR = 7818.0   # kg water per MOLE-I per year
PROPELLANT_P7_KG_YR = 968000.0   # kg/yr total propellant at P7 (as water input)
