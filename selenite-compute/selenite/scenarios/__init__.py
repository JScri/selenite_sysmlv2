"""Wave 4A scenarios, uncertainty and decision analysis (NOT a port, no golden).

The model (``model/Scenarios.sysml``) declares the decisions, their
alternatives, the uncertain inputs and the measures of value; this
subpackage samples the uncertainty (``sample``), evaluates every alternative
of every decision on the same sample matrix (common random numbers;
``eclipse``, ``trades``), scores the alternatives under each decision
criterion (``criteria``) and assembles one ``DecisionResult`` per decision
(``run``). ``modelio`` is the one place the SysML files are read;
``econ_param`` is the parametrised ECON v1.3 that equals ``selenite.econ``
at its defaults. Goldens, ``econ.py`` and ``verify.py`` are untouched.
"""
PORTED = False
SOURCE_SCRIPT = "none - Wave 4A extension (no golden)"
