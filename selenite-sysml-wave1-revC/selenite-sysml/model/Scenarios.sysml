package SeleniteScenarios {
    doc /* Wave 4A (6 Nov 2026): scenarios, uncertainty and decision analysis.
         * The deterministic derived plan of Wave 3 becomes a decision engine:
         * this package DECLARES the decisions (DecisionCatalogue, D1-D8 as
         * variations whose variants are the alternatives), the uncertain inputs
         * (UncertaintyRegister, every entry bound to an existing
         * ProgrammeParameters attribute and its Low / High twins, never
         * retyped), the measures of value (#moe attributes on the option
         * definitions) and the trade studies (one analysis per decision with
         * @ToolExecution naming the Python entry point). The Python layer
         * (selenite-compute/selenite/scenarios/) samples the uncertainty with
         * common random numbers under a fixed seed, evaluates every alternative
         * on the same samples, scores them under each decision criterion and
         * prints docs/SCENARIO_REGISTER.md (tools/scenario_check.py).
         *
         * Decision (Jason, 20 Sep 2026): the model must parameterise per
         * scenario and arrive at the most economical decision for that
         * scenario; where an input is not deterministic its variability is
         * carried (stochastic optimisation by sample-average approximation over
         * discrete alternatives, recourse decisions re-evaluated per sample).
         * Rules: no distribution parameter is typed from a document unless it
         * is an existing Low / High pair or a cited source - otherwise the
         * entry is a point at nominal with its range unbound and the register
         * says so; the wave produces recommendations and draft ECNs, never a
         * rebinding of a committed parameter (ECN-022 stands until Jason signs
         * ECN-023). Source: docs/SESSION_BRIEF_wave4_scenarios.md; rules 3, 5b,
         * 5c and 5d of CLAUDE_SYSML_CONTEXT.md. */

    private import AnalysisTooling::*;
    private import ParametersOfInterestMetadata::*;
    private import ScalarValues::*;
    private import SeleniteParameters::*;
    private import TradeStudies::*;

    // =====================================================================
    // Uncertain values
    // =====================================================================

    enum def DistributionKind {
        doc /* How the Python sampler draws an UncertainReal: pointValue (a
             * constant at nominal), uniform (low..high), triangular (low,
             * nominal, high), pert (beta-PERT, lambda 4, mode at nominal),
             * logNormal (median nominal; low / high as P10 / P90), discrete
             * (the two candidates low / high, equal weights unless stated). */
        pointValue; uniform; triangular; pert; logNormal; discrete;
    }

    abstract attribute def UncertainReal {
        doc /* An input the plan carries with its variability. nominal is the
             * committed or transcribed value, low / high the sourced range
             * (unbound = point at nominal), source the provenance line the
             * register prints. Concrete subtypes bind the distribution kind
             * with the Wave 2 redefines idiom (clears SSM021). */
        attribute nominal : Real;
        attribute low : Real;
        attribute high : Real;
        attribute source : String;
        abstract attribute distribution : DistributionKind;
    }

    attribute def PointReal :> UncertainReal {
        doc /* A point: nominal only; sampled as a constant. */
        attribute redefines distribution = DistributionKind::pointValue;
    }

    attribute def UniformReal :> UncertainReal {
        attribute redefines distribution = DistributionKind::uniform;
    }

    attribute def TriangularReal :> UncertainReal {
        attribute redefines distribution = DistributionKind::triangular;
    }

    attribute def PertReal :> UncertainReal {
        attribute redefines distribution = DistributionKind::pert;
    }

    attribute def LogNormalReal :> UncertainReal {
        attribute redefines distribution = DistributionKind::logNormal;
    }

    attribute def DiscreteReal :> UncertainReal {
        doc /* Two candidate values recorded under rule 5b (a conflict carried,
             * not resolved): low and high are the candidates, nominal the one
             * the goldens or the committed plan use. */
        attribute redefines distribution = DistributionKind::discrete;
    }

    // =====================================================================
    // Uncertainty register (the U-set): every entry bound to ProgrammeParameters
    // =====================================================================

    part def UncertaintyRegister {
        doc /* The sampled space. Each entry is an UncertainReal whose nominal /
             * low / high are bound to the existing ProgrammeParameters
             * attributes (Wave 3 ranges, ECON v1.4 tornado bounds, Wave 4A
             * sourced ranges) - never retyped here. An entry whose low / high
             * stay unbound is a point; its doc in Parameters.sysml names the
             * source that would bind it. Python: selenite.scenarios.space reads
             * this part def by name; the register reports every entry as
             * sampled or point with its distribution and source. */
        part parameters : ProgrammeParameters;

        // ---- Wave 3 ranges (ECN-022 s.2.2) ---------------------------------
        attribute thoriumGradePpm : TriangularReal {
            attribute redefines nominal = parameters.thoriumGradePpm;
            attribute redefines low = parameters.thoriumGradePpmLow;
            attribute redefines high = parameters.thoriumGradePpmHigh;
            attribute redefines source = "ECN-022 s.2.2; fleet v9 s.11; Lawrence et al. 2000, 2003";
        }
        attribute acidBakeThoriumCapture : TriangularReal {
            attribute redefines nominal = parameters.acidBakeThoriumCapture;
            attribute redefines low = parameters.acidBakeThoriumCaptureLow;
            attribute redefines high = parameters.acidBakeThoriumCaptureHigh;
            attribute redefines source = "ECN-022 s.2.2; DG-7.2 (~90-95 % of Th into ThP2O7)";
        }

        // ---- SPA eclipse operating strategy (D1) ----------------------------
        attribute spaDarkFraction : TriangularReal {
            attribute redefines nominal = parameters.spaDarkFraction;
            attribute redefines low = parameters.spaDarkFractionLow;
            attribute redefines high = parameters.spaDarkFractionHigh;
            attribute redefines source = "VERIFY v5.0 solar.illum 0.85; Glaeser et al. 2014 (Icarus 243) 77.1-88.0 % average illumination";
        }
        attribute spaLongestEclipseHours : TriangularReal {
            attribute redefines nominal = parameters.spaDesignEclipseHours;
            attribute redefines low = parameters.spaLongestEclipseHoursLow;
            attribute redefines high = parameters.spaLongestEclipseHoursHigh;
            attribute redefines source = "Strategy v3.1 s.12.1 72 h design case; Glaeser et al. 2014 longest darkness 3-5 days (W4A-N1)";
        }
        attribute czochralskiBatchHours : TriangularReal {
            attribute redefines nominal = parameters.czochralskiBatchHours;
            attribute redefines low = parameters.czochralskiBatchHoursLow;
            attribute redefines high = parameters.czochralskiBatchHoursHigh;
            attribute redefines source = "Jason, 6 Nov 2026 (open question 3): a batch takes 1-3 days";
        }
        attribute plantOversizeMassPenaltyKgPerKw : TriangularReal {
            attribute redefines nominal = parameters.plantOversizeMassPenaltyKgPerKw;
            attribute redefines low = parameters.plantOversizeMassPenaltyKgPerKwLow;
            attribute redefines high = parameters.plantOversizeMassPenaltyKgPerKwHigh;
            attribute redefines source = "PROXY: Decision Framework Rev D s.4 circuit designs 70.0-83.3 kg/kW";
        }
        attribute eclipseRestartLossDaysPerEclipse : PointReal {
            attribute redefines nominal = parameters.eclipseRestartLossDaysPerEclipse;
            attribute redefines source = "UNBOUND - no process source; evaluator ASSUMED 0.5 day per eclipse";
        }
        attribute spaMsrAvailabilityProbability : PointReal {
            attribute redefines nominal = parameters.spaMsrAvailabilityProbability;
            attribute redefines source = "Wave 3 assumedOutcome = true (DG-7.5, DG-9.3) restated as 1.0; range unbound";
        }
        attribute fspUnitMassKg : PointReal {
            attribute redefines nominal = parameters.fspUnitMassKg;
            attribute redefines source = "VERIFY v5.0 fsp.mass_kg (ECON v1.3 agrees); range unbound";
        }
        attribute fspUnitPowerKw : PointReal {
            attribute redefines nominal = parameters.fspUnitPowerKw;
            attribute redefines source = "VERIFY v5.0 fsp.pwr_kW; range unbound";
        }
        attribute batterySpecificEnergyWhPerKg : PointReal {
            attribute redefines nominal = parameters.batterySpecificEnergyWhPerKg;
            attribute redefines source = "VERIFY v5.0 batt_Whkg; range unbound";
        }
        attribute solarPanelMassKgPerM2 : PointReal {
            attribute redefines nominal = parameters.solarPanelMassKgPerM2;
            attribute redefines source = "VERIFY v5.0 ph.panel_kg = panel_m2 x 3; range unbound";
        }

        // ---- SPA power supply mix (D2) --------------------------------------
        attribute thcl4AvailableYear : TriangularReal {
            attribute redefines nominal = parameters.thcl4AvailableYear;
            attribute redefines low = parameters.thcl4AvailableYearLow;
            attribute redefines high = parameters.thcl4AvailableYearHigh;
            attribute redefines source = "DG-9.6 declared Y43 (P9), alternate P10 -> Y43-Y60 (W2-N2)";
        }
        attribute solarInSituStartYear : TriangularReal {
            attribute redefines nominal = parameters.solarInSituStartYear;
            attribute redefines low = parameters.solarInSituStartYearLow;
            attribute redefines high = parameters.solarInSituStartYearHigh;
            attribute redefines source = "Decision Framework Rev D s.6: a-Si panels in-situ from P11 (Y60-Y80)";
        }
        attribute msrUnitMassKg : PointReal {
            attribute redefines nominal = parameters.msrUnitMassKg;
            attribute redefines source = "ECON v1.3 msr.mass_kg; range unbound";
        }
        attribute msrEarthFractionFloor : PointReal {
            attribute redefines nominal = parameters.msrEarthFractionFloor;
            attribute redefines source = "ECON v1.3 msr.earth_frac floor 0.3 from Y80; DF s.15.2; range unbound";
        }

        // ---- Programme-wide economics (ECON v1.4 tornado) -------------------
        attribute launchCostMultiplier : TriangularReal {
            attribute redefines nominal = parameters.launchCostMultiplier;
            attribute redefines low = parameters.launchCostMultiplierLow;
            attribute redefines high = parameters.launchCostMultiplierHigh;
            attribute redefines source = "ECON v1.4 tornado: launch cost +50 % / -50 % on 6,000 / 4,000 / 2,000 $/kg";
        }
        attribute discountRateMultiplier : TriangularReal {
            attribute redefines nominal = parameters.discountRateMultiplier;
            attribute redefines low = parameters.discountRateMultiplierLow;
            attribute redefines high = parameters.discountRateMultiplierHigh;
            attribute redefines source = "ECON v1.4 tornado: 1.4 % vs 3.5 % as a multiplier on the 3 / 2.5 / 2 % schedule";
        }
        attribute reoExternalityUsdPerTonne : TriangularReal {
            attribute redefines nominal = parameters.reoExternalityUsdPerTonne;
            attribute redefines low = parameters.reoExternalityUsdPerTonneLow;
            attribute redefines high = parameters.reoExternalityUsdPerTonneHigh;
            attribute redefines source = "ECON v1.4 tornado: REO externality $50k vs $90k/t";
        }
        attribute h2AttributionFraction : TriangularReal {
            attribute redefines nominal = parameters.h2AttributionFraction;
            attribute redefines low = parameters.h2AttributionFractionLow;
            attribute redefines high = parameters.h2AttributionFractionHigh;
            attribute redefines source = "ECON v1.4 tornado: H2 attribution 25 % vs 100 %";
        }
        attribute geoInsuranceUsdMPerYear : TriangularReal {
            attribute redefines nominal = parameters.geoInsuranceUsdMPerYear;
            attribute redefines low = parameters.geoInsuranceUsdMPerYearLow;
            attribute redefines high = parameters.geoInsuranceUsdMPerYearHigh;
            attribute redefines source = "ECON v1.4 tornado: geo insurance $0 vs $25 B/yr";
        }
        attribute circuitMaintenanceFractionPerYear : TriangularReal {
            attribute redefines nominal = parameters.circuitMaintenanceFractionPerYear;
            attribute redefines low = parameters.circuitMaintenanceFractionPerYearLow;
            attribute redefines high = parameters.circuitMaintenanceFractionPerYearHigh;
            attribute redefines source = "ECON v1.4 tornado: maintenance 0.5 % vs 0.25 %; DF s.4";
        }
        attribute reoRampKnotShift : DiscreteReal {
            attribute redefines nominal = parameters.reoRampKnotShift;
            attribute redefines low = parameters.reoRampKnotShiftLow;
            attribute redefines high = parameters.reoRampKnotShiftHigh;
            attribute redefines source = "W3-N4: ECON knots (0) vs Decision Framework REO gates one knot earlier (1); equal weights";
        }

        // ---- Captures and the asteroid lag (D5, points with ranges unbound) -
        attribute mTypeCaptureYear : PointReal {
            attribute redefines nominal = parameters.mTypeCaptureYear;
            attribute redefines low = parameters.mTypeCaptureYearLow;
            attribute redefines high = parameters.mTypeCaptureYearHigh;
            attribute redefines source = "ECON v1.4 / DG-11.8 Y75; range UNBOUND (no source) - scenario lateMType";
        }
        attribute cTypeCaptureYear : PointReal {
            attribute redefines nominal = parameters.cTypeCaptureYear;
            attribute redefines source = "ECON v1.4 / DG-13.2 Y95; range unbound";
        }
        attribute sTypeCaptureYear : PointReal {
            attribute redefines nominal = parameters.sTypeCaptureYear;
            attribute redefines source = "ECON v1.4 / DG-13.6 Y115; range unbound";
        }
        attribute asteroidOnlineLagYears : PointReal {
            attribute redefines nominal = parameters.asteroidOnlineLagYears;
            attribute redefines low = parameters.asteroidOnlineLagYearsLow;
            attribute redefines high = parameters.asteroidOnlineLagYearsHigh;
            attribute redefines source = "Decision Framework Rev D (redirect -> arrival +10); range UNBOUND";
        }

        // ---- Canister recovery (D3) -----------------------------------------
        attribute reoPayloadPerCanisterTonnes : DiscreteReal {
            attribute redefines nominal = parameters.reoPayloadPerCanisterTonnesEcon;
            attribute redefines low = parameters.reoPayloadPerCanisterTonnesEcon;
            attribute redefines high = parameters.reoPayloadPerCanisterTonnesEcn020;
            attribute redefines source = "W3-N7 / VC-22: ECON 3.5 t (714,286/yr) vs ECN-020 3.6 t (694,444/yr); equal weights";
        }
        attribute impactSurvivalPassProbability : PointReal {
            attribute redefines nominal = parameters.impactSurvivalPassProbability;
            attribute redefines source = "DF s.9 / s.11 item 9: test outcome, probability uninformative 0.5; range unbound";
        }

        // ---- Mk III transition (D7) and hauler policy (D8) ------------------
        attribute psrMoleICapacityUnits : DiscreteReal {
            attribute redefines nominal = parameters.psrMoleICapacityUnits;
            attribute redefines low = parameters.psrMoleICapacityUnitsDocument;
            attribute redefines high = parameters.psrMoleICapacityUnits;
            attribute redefines source = "W2-N18: psr_layout 620 (bound) vs fleet v9 / Strategy s.4.4 ~310; equal weights";
        }
        attribute mkIiiTestPassProbability : PointReal {
            attribute redefines nominal = parameters.mkIiiTestPassProbability;
            attribute redefines source = "DG-11.6 ion-SEP / EM-catcher validation; probability uninformative 0.5; range unbound";
        }
        attribute haulerEarthFractionFloor : DiscreteReal {
            attribute redefines nominal = parameters.haulerEarthFractionFloorEcon;
            attribute redefines low = parameters.haulerEarthFractionFloorFleetV9;
            attribute redefines high = parameters.haulerEarthFractionFloorEcon;
            attribute redefines source = "F3: ECON 0.43 (~57 % in-situ) vs fleet v9 92 % in-situ (0.08); equal weights";
        }
    }

    // =====================================================================
    // Decision catalogue: options, their measures of value, the alternatives
    // =====================================================================

    enum def DecisionStage {
        doc /* now: a design choice made before the information arrives (a
             * here-and-now decision); recourse: decided when a gate's
             * information arrives and therefore re-evaluated per sample. */
        now; recourse;
    }

    part def DecisionOption {
        doc /* Base of every alternative of every decision: the measures of
             * value (#moe) tools/scenario_check.py reports for each
             * alternative as mean / P10 / P50 / P90, and the recommendation's
             * criterion and win probability. Earth-launched mass is the
             * programme's own Earth-independence measure (DG-14.6); NPV and
             * direct BCR are ECON v1.4's; milestone slip is against the gates
             * the decision touches that ECN-022 leaves standing (M5 / M6 / M8
             * of MTL v8.5 are not derivable from the Python layer and are
             * reported as not modelled). */
        #moe attribute earthLaunchedMassTonnes : Real;
        #moe attribute earthLaunchedMassP90Tonnes : Real;
        #moe attribute npvUsdB : Real;
        #moe attribute npvCvar90UsdB : Real;
        #moe attribute directBcr : Real;
        #moe attribute milestoneSlipYears : Real;
        #moe attribute launchCo2Tonnes : Real;
        attribute source : String;
    }

    part def EclipseStrategyOption :> DecisionOption {
        doc /* D1 alternatives add the SPA power-side measures. */
        #moe attribute fspUnits : Real;
        #moe attribute batteryMassTonnes : Real;
        #moe attribute throughputLostFraction : Real;
        #moe attribute spaMsrFirstYear : Real;
        attribute derivedCriticalFraction : Real;
    }

    part def SpaPowerOption :> DecisionOption {
        #moe attribute spaMsrFirstYear : Real;
        #moe attribute probabilityMsrBeforeY105 : Real;
    }

    part def CanisterRecoveryOption :> DecisionOption {
        #moe attribute annualEarthImportCostUsdB : Real;
        attribute earthContentKgPerCanister : Real;
    }

    part def CircuitDesignOption :> DecisionOption {
        #moe attribute circuitsNeeded : Real;
        #moe attribute pktPowerGw : Real;
    }

    part def MdFourTimingOption :> DecisionOption {
        #moe attribute mdFourYear : Real;
        #moe attribute probabilityOperationalByY85 : Real;
    }

    part def ThoriumSizingOption :> DecisionOption {
        #moe attribute dgEightSevenYear : Real;
        #moe attribute thoriumHydroxideAtY43Tonnes : Real;
    }

    part def MkIiiTriggerOption :> DecisionOption {
        #moe attribute probabilityCapacityForced : Real;
        #moe attribute mkIiiFleetEarthMassTonnes : Real;
    }

    part def HaulerPolicyOption :> DecisionOption {
        #moe attribute probabilityDgThirteenSevenMetByY120 : Real;
        #moe attribute haulerEarthMassTonnes : Real;
    }

    abstract part def Decision {
        doc /* Catalogue metadata on every variation: id, title, stage, the gates
             * it touches, the register entries it samples and the Python
             * evaluator. Stage is bound with the untyped-value idiom. */
        attribute decisionId : String;
        attribute title : String;
        attribute gates : String [0..*];
        attribute uncertainInputs : String [0..*];
        attribute evaluator : String;
        attribute evaluatorStatus : String;
    }

    part def EclipseOperatingStrategyDecision :> Decision {
        doc /* Catalogue metadata of EclipseOperatingStrategy (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D1";
        attribute redefines title = "SPA eclipse operating strategy for the asteroid-processing loads";
        attribute stage = DecisionStage::now;
        attribute redefines gates = ("DG-10.5", "DG-11.3", "DG-13.4", "DG-14.4", "DG-14.7");
        attribute redefines uncertainInputs = ("spaDarkFraction", "spaLongestEclipseHours", "czochralskiBatchHours", "plantOversizeMassPenaltyKgPerKw", "eclipseRestartLossDaysPerEclipse", "spaMsrAvailabilityProbability", "fspUnitMassKg", "fspUnitPowerKw", "batterySpecificEnergyWhPerKg", "solarPanelMassKgPerM2", "thcl4AvailableYear", "solarInSituStartYear", "msrUnitMassKg", "msrEarthFractionFloor", "launchCostMultiplier");
        attribute redefines evaluator = "selenite.scenarios.eclipse.evaluate_d1";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def EclipseOperatingStrategy :> EclipseStrategyOption, EclipseOperatingStrategyDecision {
        doc /* D1 - the lead case. The asteroid-processing loads (C-type
             * pyrolysis and Fischer-Tropsch from Y105, S-type Czochralski
             * silicon from Y125, Decision Framework s.10.1) are eclipse-critical
             * only if the power-intensive work cannot be scheduled outside the
             * eclipse (Jason, 19 Sep 2026). ECN-022 s.2.4 bound the fraction at
             * 1.0; the fraction is an operating strategy, and its value falls
             * out of this trade: the register shows the declared 1.0 beside the
             * derived twin (EclipseCriticalFraction) of every alternative. A
             * here-and-now design choice; the FSP-versus-MSR count is the
             * recourse (plan_vectors.fsp_msr_trade per sample). PKT is out of
             * D1: its 14-day night is why it is MSR-powered (Strategy s.12.2). */
        variant part carryThroughEclipse : EclipseStrategyOption {
            doc /* A: all asteroid loads eclipse-critical - ECN-022 s.2.4 as bound
                 * (spaAsteroidLoadCriticalFraction = 1.0). FSP sized to the whole
                 * load in the non-nuclear alternative; no oversize, no loss. */
            attribute redefines source = "ECN-022 s.2.4 (declared assumption)";
        }
        variant part sunlitDutyCycle : EclipseStrategyOption {
            doc /* B: pausable steps scheduled outside the eclipse, plant oversized
                 * by 1 / ((1 - dark fraction)(1 - restart loss)) to keep annual
                 * throughput despite the dark time and the restarts; only the hold
                 * loads (a share of the oversized plant) go through the eclipse. */
            attribute redefines source = "Wave 4A brief D1 (Jason, 19 Sep 2026 reading)";
        }
        variant part hotStandby : EclipseStrategyOption {
            doc /* C: process heat held by storage / insulation, electrical hold
                 * fraction per process through the eclipse, no oversize: annual
                 * throughput falls by the dark fraction plus restart losses. */
            attribute redefines source = "Wave 4A brief D1";
        }
        variant part hybridStorage : EclipseStrategyOption {
            doc /* D: a chosen fraction (ProgrammeParameters.hybridStoredLoadFraction)
                 * keeps running through the eclipse on battery (VERIFY battery
                 * rule); the remainder follows the sunlit duty cycle. */
            attribute redefines source = "Wave 4A brief D1";
        }
    }

    part def SpaPowerSupplyMixDecision :> Decision {
        doc /* Catalogue metadata of SpaPowerSupplyMix (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D2";
        attribute redefines title = "SPA power supply mix: FSP + solar versus SPA MSR, solar in-situ timing";
        attribute stage = DecisionStage::recourse;
        attribute redefines gates = ("DG-9.6", "DG-10.5", "DG-13.4");
        attribute redefines uncertainInputs = ("msrUnitMassKg", "msrEarthFractionFloor", "launchCostMultiplier", "thcl4AvailableYear", "solarPanelMassKgPerM2", "solarInSituStartYear", "fspUnitMassKg", "spaDarkFraction");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d2";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def SpaPowerSupplyMix :> SpaPowerOption, SpaPowerSupplyMixDecision {
        doc /* D2 - FSP versus SPA MSR versus a-Si solar in-situ timing, the
             * deterministic plan_vectors.fsp_msr_trade of ECN-022 s.2.3 made
             * stochastic. A recourse: per sample the year the MSR becomes worth
             * it (non-nuclear Earth cargo beyond the P7 fleet exceeds the MSR's
             * Earth cargo) and ThCl4 is available. */
        variant part nonNuclearOnly : SpaPowerOption {
            doc /* FSP for the eclipse-critical load and solar for the day load,
                 * Earth-sourced, never an SPA MSR (the counterfactual). */
            attribute redefines source = "plan_vectors.fsp_msr_trade non-nuclear side";
        }
        variant part msrWhenJustified : SpaPowerOption {
            doc /* ECN-022 s.2.3 policy: the MSR when the non-nuclear cargo beyond
                 * the P7 as-built fleet exceeds the MSR's Earth cargo and ThCl4 is
                 * available (incremental basis). */
            attribute redefines source = "ECN-022 s.2.3; plan_vectors.fsp_msr_trade incremental basis";
        }
        variant part msrAtThcl4Availability : SpaPowerOption {
            doc /* The as-built reading: an MSR as soon as ThCl4 arrives (MD-3,
                 * DG-9.6), delivered hardware not sunk. */
            attribute redefines source = "plan_vectors.fsp_msr_trade as-built basis; Strategy v3.1 s.12.1 'from Y50'";
        }
    }

    part def CanisterRecoveryArchitectureDecision :> Decision {
        doc /* Catalogue metadata of CanisterRecoveryArchitecture (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D3";
        attribute redefines title = "Canister recovery architecture (DG-9.1)";
        attribute stage = DecisionStage::now;
        attribute redefines gates = ("DG-9.1", "DG-14.6");
        attribute redefines uncertainInputs = ("reoPayloadPerCanisterTonnes", "impactSurvivalPassProbability", "launchCostMultiplier");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d3";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def CanisterRecoveryArchitecture :> CanisterRecoveryOption, CanisterRecoveryArchitectureDecision {
        doc /* D3 - DG-9.1 canister recovery (Decision Framework s.9). A
             * here-and-now choice of the architecture to develop; the
             * impact-survival test is the recourse: when it fails the plan
             * falls back to the next safer option (2 -> 1b -> 1a). In scope for
             * Wave 4A (Jason, 6 Nov 2026, open question 4). */
        variant part fullParachute : CanisterRecoveryOption {
            doc /* Option 1a, ~73 kg Earth content per canister, proven. */
            attribute redefines source = "Decision Framework Rev D s.9 option 1a";
        }
        variant part minimalDragChute : CanisterRecoveryOption {
            doc /* Option 1b, ~28 kg, RECOMMENDED; needs impact-survival
                 * validation (DF s.11 item 9); ECON v1.3 assumes it. */
            attribute redefines source = "Decision Framework Rev D s.9 option 1b; ECON v1.3 can.earth_kg = 28";
        }
        variant part shuttlecock : CanisterRecoveryOption {
            doc /* Option 2, ~8 kg, no fabric; unproven at scale. */
            attribute redefines source = "Decision Framework Rev D s.9 option 2";
        }
    }

    part def ProcessingCircuitDesignDecision :> Decision {
        doc /* Catalogue metadata of ProcessingCircuitDesign (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D4";
        attribute redefines title = "Processing circuit design (batch / continuous-flow / optimised)";
        attribute stage = DecisionStage::now;
        attribute redefines gates = ("DG-8.5", "DG-9.2", "DG-10.2");
        attribute redefines uncertainInputs = ("circuitMaintenanceFractionPerYear", "launchCostMultiplier", "discountRateMultiplier", "reoRampKnotShift");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d4";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def ProcessingCircuitDesign :> CircuitDesignOption, ProcessingCircuitDesignDecision {
        doc /* D4 - DG-8.5 / W3-N3: the three ECON v1.3 circuit designs. The
             * optimised design is committed (DF s.4, SEL-REQ-015); the trade
             * reports what the alternatives cost under the sampled economics. */
        variant part batchDesign : CircuitDesignOption {
            doc /* 0.4 t/yr, 15,000 kg, 180 kW (rejected by DF s.4). */
            attribute redefines source = "ECON v1.3 circuit_designs(1); DF s.4";
        }
        variant part continuousFlowDesign : CircuitDesignOption {
            doc /* 0.8 t/yr, 22,000 kg, 300 kW. */
            attribute redefines source = "ECON v1.3 circuit_designs(2); DF s.4";
        }
        variant part optimisedDesign : CircuitDesignOption {
            doc /* 1.2 t/yr, 28,000 kg, 400 kW - committed. */
            attribute redefines source = "ECON v1.3 circuit_designs(3); DF s.4 committed; SEL-REQ-015";
        }
    }

    part def MdFourRetirementTimingDecision :> Decision {
        doc /* Catalogue metadata of MdFourRetirementTiming (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D5";
        attribute redefines title = "MD-4 and Starship-return retirement timing (consequence of the M-type arrival)";
        attribute stage = DecisionStage::recourse;
        attribute redefines gates = ("DG-11.8", "DG-12.4");
        attribute redefines uncertainInputs = ("mTypeCaptureYear", "asteroidOnlineLagYears");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d5";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def MdFourRetirementTiming :> MdFourTimingOption, MdFourRetirementTimingDecision {
        doc /* D5 - MD-4 and the Starship-return retirement are consequences of
             * the M-type arrival (ECN-022 s.2.1): no alternatives, included so
             * the year carries a distribution. With the capture ranges unbound
             * the distribution is a point; the lateMType scenario moves it. */
        variant part consequenceOfMTypeArrival : MdFourTimingOption {
            doc /* mdFourYear = mTypeCaptureYear + asteroidOnlineLagYears. */
            attribute redefines source = "ECN-022 s.2.1; ProgrammeConfiguration dgTwelveFour.derivedYear";
        }
    }

    part def ThoriumStreamSizingDecision :> Decision {
        doc /* Catalogue metadata of ThoriumStreamSizing (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D6";
        attribute redefines title = "Thorium stream sizing (consequence of grade and capture)";
        attribute stage = DecisionStage::recourse;
        attribute redefines gates = ("DG-8.7", "DG-9.6");
        attribute redefines uncertainInputs = ("thoriumGradePpm", "acidBakeThoriumCapture", "reoRampKnotShift");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d6";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def ThoriumStreamSizing :> ThoriumSizingOption, ThoriumStreamSizingDecision {
        doc /* D6 - W3-N22: the thorium stream is a sizing consequence of the ore
             * grade and the acid-bake capture (ECN-022 s.2.2 ranges); the
             * DG-8.7 year and the stockpile available for ThCl4 carry the
             * distribution. */
        variant part consequenceOfGradeAndCapture : ThoriumSizingOption {
            doc /* plan_vectors.thorium_stockpile on the sampled ratio. */
            attribute redefines source = "ECN-022 s.2.2; plan_vectors.thorium_ratio";
        }
    }

    part def MkIiiTransitionTriggerDecision :> Decision {
        doc /* Catalogue metadata of MkIiiTransitionTrigger (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D7";
        attribute redefines title = "Mk III transition trigger (capacity-forced versus DG-11.6 test outcome)";
        attribute stage = DecisionStage::recourse;
        attribute redefines gates = ("DG-11.6", "DG-11.7");
        attribute redefines uncertainInputs = ("psrMoleICapacityUnits", "mkIiiTestPassProbability");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d7";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def MkIiiTransitionTrigger :> MkIiiTriggerOption, MkIiiTransitionTriggerDecision {
        doc /* D7 - W3-N2 / ECN-022 s.2.6: the Mk III transition is either forced
             * by PSR capacity (MOLE-I need above the floor positions) or rests on
             * the DG-11.6 test outcome. Capacity is sampled between the layout's
             * 620 and the documents' 310 (W2-N18); the test outcome is a sampled
             * Boolean. */
        variant part capacityForced : MkIiiTriggerOption {
            doc /* Transition when ECON molei_needed exceeds the PSR capacity. */
            attribute redefines source = "MkIiiTransitionGate; W2-N18";
        }
        variant part testOutcomeDriven : MkIiiTriggerOption {
            doc /* Transition at DG-11.6 (Y65-75) if the ion-SEP / EM-catcher
                 * validation passes - ECN-022 s.2.6. */
            attribute redefines source = "ECN-022 s.2.6; Strategy v3.1 s.16";
        }
    }

    part def HaulerInSituFractionPolicyDecision :> Decision {
        doc /* Catalogue metadata of HaulerInSituFractionPolicy (kept in a supertype: every
             * usage nested in a variation is a variant, SSM030). */
        attribute redefines decisionId = "D8";
        attribute redefines title = "Hauler in-situ fraction policy (F3, DG-13.7)";
        attribute stage = DecisionStage::recourse;
        attribute redefines gates = ("DG-10.1", "DG-13.7");
        attribute redefines uncertainInputs = ("haulerEarthFractionFloor", "mTypeCaptureYear", "launchCostMultiplier");
        attribute redefines evaluator = "selenite.scenarios.trades.evaluate_d8";
        attribute redefines evaluatorStatus = "evaluated";
    }

    variation part def HaulerInSituFractionPolicy :> HaulerPolicyOption, HaulerInSituFractionPolicyDecision {
        doc /* D8 - F3 / DG-13.7 / W3-N5: the hauler Earth-fraction floor as a
             * policy - ECON's 0.43 floor less the 0.10 M-type bonus, or the
             * DG-13.7 20 % target. */
        variant part econFloor : HaulerPolicyOption {
            doc /* ECON v1.3: floor 0.43 with the 0.10 M-type bonus from Y90. */
            attribute redefines source = "ECON v1.3 hauler.earth_frac; W3-N5";
        }
        variant part targetFloor : HaulerPolicyOption {
            doc /* The DG-13.7 target: floor 0.20 (avionics, BMS, bearings). */
            attribute redefines source = "Decision Framework Rev D DG-13.7; GateThresholds.haulerEarthFractionFloor";
        }
    }

    part def DecisionCatalogue {
        doc /* The eight decisions in one place for the diagrams and the
             * checker (tools/scenario_check.py: every variation here has an
             * evaluator or a declared stub, every #moe is reported). Abstract
             * usages: the catalogue lists each decision as a whole; the
             * baseline's selection of one variant is in the configuration
             * (seleniteProgramme.d1 ... d8). */
        abstract part d1 : EclipseOperatingStrategy;
        abstract part d2 : SpaPowerSupplyMix;
        abstract part d3 : CanisterRecoveryArchitecture;
        abstract part d4 : ProcessingCircuitDesign;
        abstract part d5 : MdFourRetirementTiming;
        abstract part d6 : ThoriumStreamSizing;
        abstract part d7 : MkIiiTransitionTrigger;
        abstract part d8 : HaulerInSituFractionPolicy;
    }

    // =====================================================================
    // Trade studies: one analysis per decision, each naming its Python entry
    // =====================================================================

    analysis def EclipseStrategyTrade :> TradeStudy {
        doc /* D1 under the default criterion: minimise expected Earth-launched
             * mass (ProgrammeParameters.decisionCriterion). The tool reports
             * every criterion side by side. */
        subject options : EclipseStrategyOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : EclipseStrategyOption;
                return :>> result = option.earthLaunchedMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/eclipse.py";
        }
    }

    analysis def SpaPowerTrade :> TradeStudy {
        subject options : SpaPowerOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : SpaPowerOption;
                return :>> result = option.earthLaunchedMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    analysis def CanisterRecoveryTrade :> TradeStudy {
        subject options : CanisterRecoveryOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : CanisterRecoveryOption;
                return :>> result = option.earthLaunchedMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    analysis def CircuitDesignTrade :> TradeStudy {
        subject options : CircuitDesignOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : CircuitDesignOption;
                return :>> result = option.earthLaunchedMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    analysis def MdFourTimingTrade :> TradeStudy {
        subject options : MdFourTimingOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : MdFourTimingOption;
                return :>> result = option.milestoneSlipYears;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    analysis def ThoriumSizingTrade :> TradeStudy {
        subject options : ThoriumSizingOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : ThoriumSizingOption;
                return :>> result = option.milestoneSlipYears;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    analysis def MkIiiTriggerTrade :> TradeStudy {
        subject options : MkIiiTriggerOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : MkIiiTriggerOption;
                return :>> result = option.earthLaunchedMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    analysis def HaulerPolicyTrade :> TradeStudy {
        subject options : HaulerPolicyOption[*];
        objective : MinimizeObjective {
            calc :>> fn {
                in part option : HaulerPolicyOption;
                return :>> result = option.earthLaunchedMassTonnes;
            }
        }
        @ToolExecution {
            toolName = "selenite.scenarios";
            uri = "selenite-compute/selenite/scenarios/trades.py";
        }
    }

    part def TradeStudySet {
        doc /* The eight analyses, instanced in the configuration beside the
             * catalogue they evaluate. */
        analysis eclipseTrade : EclipseStrategyTrade;
        analysis spaPowerTrade : SpaPowerTrade;
        analysis canisterTrade : CanisterRecoveryTrade;
        analysis circuitTrade : CircuitDesignTrade;
        analysis mdFourTrade : MdFourTimingTrade;
        analysis thoriumTrade : ThoriumSizingTrade;
        analysis mkIiiTrade : MkIiiTriggerTrade;
        analysis haulerTrade : HaulerPolicyTrade;
    }

    // =====================================================================
    // Named scenarios: parameter overrides beside the sampled space
    // =====================================================================

    part def ScenarioDef {
        doc /* A named set of parameter overrides evaluated beside the sampled
             * space (every override holds the sampled entry at the stated
             * value; everything else is still sampled). Overrides are
             * ProgrammeParameters names; the evaluator-only working assumptions
             * (holdLoadFraction, asteroidPlantEarthFraction) are overridable
             * here so their sensitivity is a scenario, not an unsourced
             * distribution (rule 5d). */
        attribute scenarioName : String;
        attribute launchCostMultiplier : Real [0..1];
        attribute mTypeCaptureYear : Integer [0..1];
        attribute thoriumGradePpm : Real [0..1];
        attribute acidBakeThoriumCapture : Real [0..1];
        attribute spaMsrAvailabilityProbability : Real [0..1];
        attribute spaDarkFraction : Real [0..1];
        attribute holdLoadFraction : Real [0..1];
        attribute asteroidPlantEarthFraction : Real [0..1];
    }

    part def ScenarioSet {
        doc /* The named scenarios of the Wave 4A brief plus the D1
             * sensitivities the register needs. */
        part baseline : ScenarioDef {
            doc /* The committed plan: no overrides, everything at nominal with
                 * its sourced range. */
            attribute redefines scenarioName = "baseline";
        }
        part lowLaunchCost : ScenarioDef {
            doc /* Launch cost at half the era schedule (ECON v1.4 tornado low). */
            attribute redefines scenarioName = "lowLaunchCost";
            attribute redefines launchCostMultiplier = 0.5;
        }
        part lateMType : ScenarioDef {
            doc /* M-type capture ten years late (Y85 -> arrival Y95); the only
                 * carrier of capture-year sensitivity while the range is unbound. */
            attribute redefines scenarioName = "lateMType";
            attribute redefines mTypeCaptureYear = 85;
        }
        part highThorium : ScenarioDef {
            doc /* Th grade and capture at the top of the ECN-022 ranges. */
            attribute redefines scenarioName = "highThorium";
            attribute redefines thoriumGradePpm = 15.0;
            attribute redefines acidBakeThoriumCapture = 0.95;
        }
        part msrUnavailable : ScenarioDef {
            doc /* D1 insurance case: no SPA MSR when the asteroid loads arrive
                 * (the thorium line fails its tests or ThCl4 never ships); the
                 * eclipse strategy then sizes the FSP fleet. */
            attribute redefines scenarioName = "msrUnavailable";
            attribute redefines spaMsrAvailabilityProbability = 0.0;
        }
        part msrUncertain : ScenarioDef {
            doc /* D1 with a nine-in-ten MSR availability. */
            attribute redefines scenarioName = "msrUncertain";
            attribute redefines spaMsrAvailabilityProbability = 0.9;
        }
        part earthBuiltAsteroidPlant : ScenarioDef {
            doc /* Oversize plant mass launched from Earth in full (the ECON
                 * circuit Earth fraction is the baseline proxy). */
            attribute redefines scenarioName = "earthBuiltAsteroidPlant";
            attribute redefines asteroidPlantEarthFraction = 1.0;
        }
        part holdLoadLow : ScenarioDef {
            doc /* Hold loads at 5 % of rated (well-insulated plant). */
            attribute redefines scenarioName = "holdLoadLow";
            attribute redefines holdLoadFraction = 0.05;
        }
        part holdLoadHigh : ScenarioDef {
            doc /* Hold loads at half of rated (poorly insulated plant). */
            attribute redefines scenarioName = "holdLoadHigh";
            attribute redefines holdLoadFraction = 0.5;
        }
        part darkSite : ScenarioDef {
            doc /* The darkest Glaeser et al. 2014 candidate site (77.1 % lit). */
            attribute redefines scenarioName = "darkSite";
            attribute redefines spaDarkFraction = 0.229;
        }
    }
}
