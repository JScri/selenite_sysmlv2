package SeleniteAnalysis {
    doc /* Analysis definitions. AUTHORITY NOTE: the Python layer
         * (selenite-compute, the port of SELENITE_VERIFY v5.0, SELENITE_ECON
         * v1.3/v1.4, MOLEI_THERMAL v1.3, VISUALIZE v3.3 - goldens are the
         * oracle) is the quantitative source of truth. Values here are
         * transcribed from that layer, never derived independently. The
         * calc defs mirror relationships and state gate criteria as
         * comparisons; tools/plan_check.py evaluates them on the year
         * vectors and prints the derived-vs-declared register (Wave 3).
         * Full parametric linkage is Wave 5.
         *
         * Gate criterion pattern (rule 5c, CLAUDE_SYSML_CONTEXT.md): a
         * criterion that compares quantities is a calc def returning a
         * Boolean; the threshold is an input supplied from
         * SeleniteParameters::GateThresholds (a committed decision, one ECN
         * to change), never a literal inside the calc. Boolean inputs stand
         * for test outcomes the plan assumes (see DecisionGate.assumedOutcome). */

    private import ScalarValues::*;

    calc def AnnualReoOutput {
        doc /* Steady-state REO output from feed rate and recovery. */
        in feedTonnesPerYear : Real;
        in overallRecoveryFraction : Real;
        return reoTonnesPerYear : Real = feedTonnesPerYear * overallRecoveryFraction;
    }

    calc def SpaMsrIntroductionGate {
        doc /* F5 gate (Wave 2 structure, Wave 5 evaluation): an SPA MSR is
             * justified in a phase when SPA electrical demand exceeds what
             * solar + FSP + battery can deliver, ThCl4 supply exists (MD-3
             * operational) and an MSR can feasibly be deployed at the crewed
             * base in that phase. Evaluated per phase on Python-sourced
             * demand/capability vectors; the first phase returning true binds
             * SelenitePower::SpaThoriumMSR.introducedIn. Mirrors the rule
             * "weight demand and capability, do not gate on a predetermined
             * phase" (Jason, 14 Sep 2026). Weights and margins: Wave 5.
             * Referenced by DG-10.5, DG-11.3, DG-13.4, DG-14.4 and DG-14.7
             * (W2-N20: five commissioning gates for one element). The SPA
             * demand vector beyond P7 is not yet in the Python layer, so
             * plan_check reports the gate unevaluated and prints what the
             * economics assumed (ECON spa_msr_count: Y105 / Y125 / Y140). */
        in spaDemandWatts : Real;
        in spaNonMsrCapabilityWatts : Real;
        in thcl4SupplyAvailable : Boolean;
        in msrDeployableAtSpa : Boolean;
        return justified : Boolean =
            thcl4SupplyAvailable and msrDeployableAtSpa
            and spaDemandWatts > spaNonMsrCapabilityWatts;
    }

    calc def MsrFleetPower {
        doc /* Installed PKT electrical capacity from MSR unit count. */
        in unitCount : Real;
        in unitRatedWatts : Real;
        return installedWatts : Real = unitCount * unitRatedWatts;
    }

    // ---- Wave 3: Decision Framework Rev D criteria as constraints --------

    calc def IsruSupplyMarginGate {
        doc /* ISRU propellant supply covers a demand (DG-3.2 total fleet
             * demand, DG-4.3 PROBE demand, DG-5.1 demand including the DART
             * mission). Evaluated on VERIFY v5.0 ph.isru against ph.dT / ph.dP
             * per phase P3..P7. */
        in supplyKgPerYear : Real;
        in demandKgPerYear : Real;
        return satisfied : Boolean = supplyKgPerYear >= demandKgPerYear;
    }

    calc def MoleIYieldGate {
        doc /* DG-2.1: measured MOLE-I propellant yield meets the design yield
             * (GateThresholds.moleIYieldKgPerYear; VERIFY v5.0 mi.prop_yield).
             * The measurement is a test outcome; the comparison is stated so
             * the threshold is one ECN-controlled value. */
        in measuredYieldKgPerYear : Real;
        in requiredYieldKgPerYear : Real;
        return satisfied : Boolean = measuredYieldKgPerYear >= requiredYieldKgPerYear;
    }

    calc def PktCommitmentGate {
        doc /* DG-7.1: DART XRF from at least the required number of PKT sites
             * at or above the grade threshold (test outcomes, DG-6.3) and the
             * SPA five-circuit facility producing at least the required REO
             * (ECON reo_target). */
        in dartSitesConfirmed : Integer;
        in requiredSites : Integer;
        in dartReePpm : Real;
        in requiredReePpm : Real;
        in spaReoTonnesPerYear : Real;
        in requiredReoTonnesPerYear : Real;
        return satisfied : Boolean =
            dartSitesConfirmed >= requiredSites and dartReePpm >= requiredReePpm
            and spaReoTonnesPerYear >= requiredReoTonnesPerYear;
    }

    calc def ThoriumRecoveryGate {
        doc /* DG-7.2: thorium recovery is an automatic by-product of the acid
             * bake, so it begins with the first SPA processing output
             * (ECON reo_target > 0). */
        in spaReoTonnesPerYear : Real;
        return satisfied : Boolean = spaReoTonnesPerYear > 0.0;
    }

    calc def ReagentSubstitutionGate {
        doc /* DG-7.4: in-situ reagent fraction at SPA reaches the required
             * fraction (ECON reagent.isru_frac(y)). */
        in inSituReagentFraction : Real;
        in requiredFraction : Real;
        return satisfied : Boolean = inSituReagentFraction >= requiredFraction;
    }

    calc def BreedingRatioGate {
        doc /* DG-7.5 (terrestrial demonstrator) and DG-9.3 (first PKT MSR):
             * sustained breeding ratio above the threshold. Test outcomes;
             * no Python vector. */
        in measuredBreedingRatio : Real;
        in requiredBreedingRatio : Real;
        return satisfied : Boolean = measuredBreedingRatio > requiredBreedingRatio;
    }

    calc def CircuitThroughputGate {
        doc /* DG-8.X: validated per-circuit REO throughput meets the minimum
             * before full PKT build-out. Test outcome; ECON commits the
             * optimised design (circuit.reo_yr = 1.2 =
             * ProgrammeParameters.circuitReoTonnesPerYear). */
        in measuredReoTonnesPerYearPerCircuit : Real;
        in requiredReoTonnesPerYearPerCircuit : Real;
        return satisfied : Boolean =
            measuredReoTonnesPerYearPerCircuit >= requiredReoTonnesPerYearPerCircuit;
    }

    calc def CircuitCountGate {
        doc /* DG-8.2, DG-8.5: circuits operational at PKT reach a count
             * (ECON circuits_needed). */
        in circuitsOperational : Real;
        in requiredCircuits : Real;
        return satisfied : Boolean = circuitsOperational >= requiredCircuits;
    }

    calc def HaulerFleetGate {
        doc /* DG-8.4, DG-9.2, DG-10.1: hauler fleet at PKT reaches a count
             * (ECON haulers_needed). */
        in haulersOperational : Real;
        in requiredHaulers : Real;
        return satisfied : Boolean = haulersOperational >= requiredHaulers;
    }

    calc def ReoOutputGate {
        doc /* DG-8.5, DG-11.1, DG-12.1, DG-13.1, DG-14.8: programme REO output
             * reaches a rate (ECON reo_target). */
        in reoTonnesPerYear : Real;
        in requiredReoTonnesPerYear : Real;
        return satisfied : Boolean = reoTonnesPerYear >= requiredReoTonnesPerYear;
    }

    calc def MarketShareGate {
        doc /* The "global displacement" half of DG-11.1 / DG-12.1 / DG-13.1:
             * programme supply as a fraction of projected demand
             * (ECON supply_frac). */
        in supplyFraction : Real;
        in requiredFraction : Real;
        return satisfied : Boolean = supplyFraction >= requiredFraction;
    }

    calc def ThoriumStockpileGate {
        doc /* DG-8.7: accumulated Th(OH)4 stockpile reaches the assessment
             * quantity. No thorium vector exists in the Python layer yet
             * (Wave 5: cumulative reo_target x Th:REE ratio). */
        in thoriumHydroxideStockpileTonnes : Real;
        in requiredTonnes : Real;
        return satisfied : Boolean = thoriumHydroxideStockpileTonnes >= requiredTonnes;
    }

    calc def FoundryOutputGate {
        doc /* DG-9.4, DG-10.3: PKT foundry metal output reaches a rate. Proxy
             * in the Python layer: ECON insitu_total (in-situ manufactured
             * circuit + hauler + conveyor mass per year). */
        in inSituMetalTonnesPerYear : Real;
        in requiredTonnesPerYear : Real;
        return satisfied : Boolean = inSituMetalTonnesPerYear >= requiredTonnesPerYear;
    }

    calc def ConveyorLengthGate {
        doc /* DG-9.7, DG-10.2, DG-11.5: steel apron conveyor network length
             * reaches a value (ECON conv_km_needed). */
        in conveyorKm : Real;
        in requiredKm : Real;
        return satisfied : Boolean = conveyorKm >= requiredKm;
    }

    calc def MsrFleetGate {
        doc /* DG-10.4, DG-11.2, DG-12.2: PKT MSR unit count reaches a value
             * (ECON msr_count; VC-09 for the steady-state figure). */
        in msrUnits : Real;
        in requiredUnits : Real;
        return satisfied : Boolean = msrUnits >= requiredUnits;
    }

    calc def PktFspRetirementGate {
        doc /* Consequence attached to DG-10.4: the PKT FSP field is superseded
             * when MSR installed power (MsrFleetPower) is at least the FSP
             * field's installed power (ECON msr_count, fsp_count). Binds
             * PktFspField.retiredIn and ThoriumMSR.replacesPktFspFrom. */
        in msrInstalledWatts : Real;
        in fspInstalledWatts : Real;
        return satisfied : Boolean = msrInstalledWatts >= fspInstalledWatts;
    }

    calc def MkIiiTransitionGate {
        doc /* DG-11.6 (a): the PROBE Mk III transition is forced when the
             * MOLE-I count the chemical PROBE fleet would need exceeds the PSR
             * floor capacity (ECON molei_needed vs
             * ProgrammeParameters.psrMoleICapacityUnits, W2-N18). */
        in chemicalProbeMoleINeed : Real;
        in psrMoleICapacityUnits : Real;
        return forced : Boolean = chemicalProbeMoleINeed > psrMoleICapacityUnits;
    }

    calc def PgmExportDriverGate {
        doc /* DG-11.6 (b): the SPA->Earth mass driver (MD-4) is triggered when
             * PGM concentrate volume exceeds the threshold
             * (ECON total_pgm = PROBE + Mk III + captured-asteroid PGM). */
        in pgmConcentrateTonnesPerYear : Real;
        in thresholdTonnesPerYear : Real;
        return triggered : Boolean = pgmConcentrateTonnesPerYear > thresholdTonnesPerYear;
    }

    calc def CanisterCadenceGate {
        doc /* DG-12.3: MD-2 launch cadence reaches the steady-state figure
             * (ECON canisters_yr / 365). */
        in canistersPerDay : Real;
        in requiredPerDay : Real;
        return satisfied : Boolean = canistersPerDay >= requiredPerDay;
    }

    calc def PgmYieldGate {
        doc /* DG-12.6: captured M-type asteroid PGM yield reaches the design
             * rate (ECON captured_asteroid_pgm). */
        in capturedAsteroidPgmTonnesPerYear : Real;
        in requiredTonnesPerYear : Real;
        return satisfied : Boolean = capturedAsteroidPgmTonnesPerYear >= requiredTonnesPerYear;
    }

    calc def CircuitEarthFractionGate {
        doc /* DG-13.5, DG-14.5: circuit Earth-supplied mass fraction falls to
             * or below the target (ECON: cargo_circuits / (d_circuits x
             * circuit.mass_kg) in the year). */
        in circuitEarthFraction : Real;
        in maximumFraction : Real;
        return satisfied : Boolean = circuitEarthFraction <= maximumFraction;
    }

    calc def HaulerEarthFractionGate {
        doc /* DG-13.7: hauler Earth-supplied mass fraction falls to or below
             * the floor (ECON: cargo_haulers / (d_haulers x hauler.mass_kg)). */
        in haulerEarthFraction : Real;
        in maximumFraction : Real;
        return satisfied : Boolean = haulerEarthFraction <= maximumFraction;
    }

    calc def EarthIndependenceGate {
        doc /* DG-14.6: Earth-supplied mass is below the maximum fraction of
             * total infrastructure mass flow. Proxy in the Python layer: ECON
             * earth_cargo against earth_cargo + insitu_total in the year. */
        in earthSuppliedTonnesPerYear : Real;
        in totalInfrastructureTonnesPerYear : Real;
        in maximumFraction : Real;
        return satisfied : Boolean =
            earthSuppliedTonnesPerYear < maximumFraction * totalInfrastructureTonnesPerYear;
    }

    calc def MkIiiFleetReductionGate {
        doc /* DG-14.9: with all three captures complete the active Mk III
             * fleet falls to the prospecting complement
             * (ECON mkiii_active; captures complete at
             * ProgrammeParameters.sTypeCaptureYear + 10). */
        in mkIiiActiveUnits : Real;
        in prospectingFleetUnits : Real;
        in allCapturesComplete : Boolean;
        return satisfied : Boolean = allCapturesComplete and mkIiiActiveUnits <= prospectingFleetUnits;
    }

    calc def TierDepletionGate {
        doc /* DG-POST.1 / DG-POST.2: cumulative ore extracted at active sites
             * approaches the tier resource. Needs a tier resource parameter
             * (ProgrammeParameters.tier1ResourceTonnes, unbound) and the ECON
             * regolith_yr vector beyond Y200: unevaluated until Wave 5. */
        in cumulativeOreTonnes : Real;
        in tierResourceTonnes : Real;
        in depletionFraction : Real;
        return satisfied : Boolean = cumulativeOreTonnes >= depletionFraction * tierResourceTonnes;
    }
}
