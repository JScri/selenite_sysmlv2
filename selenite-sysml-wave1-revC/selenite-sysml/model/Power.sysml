package SelenitePower {
    doc /* Power architecture: SPA solar array, fission surface power, eclipse
         * battery, SPA thorium MSR (F5 open); PKT FSP field, thorium MSR
         * fleet, hub charging stations. Phase gates only; capacities and unit
         * counts per phase are Wave 5 (VC-09 MSR count recorded).
         * Sources: SEL-POWER-001 Rev B, fleet v9 s.18, Strategy v3.1 s.12,
         * Decision Framework v4 s.7, ARCHITECTURE_BASELINE.md s.4.
         * SEL-POWER-PKT-001 not yet written. */

    private import ISQ::*;
    private import ScalarValues::*;
    private import SelenitePhases::*;
    private import SeleniteSites::*;
    private import SI::*;

    abstract part def PowerAsset :> PhaseGated {
        doc /* Base for generation and storage assets. */
        abstract attribute location : SiteId;
        attribute ratedPower :> ISQ::power;
    }

    part def SolarArray :> PowerAsset {
        doc /* SPA solar array from P3, exploiting Shackleton illumination
             * (Glaeser et al. 2014); grows through P7 (VC-02 P7 array area
             * recorded, not bound). */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
    }

    part def FissionSurfacePower :> PowerAsset {
        doc /* Fission surface power unit at SPA; five by P7 (count Wave 5);
             * covers critical loads (pipeline heating, WEBs) through the 72 h
             * eclipse case. W2-N13 (recorded, not resolved): fleet v9 s.18.1
             * shows P1-P3 as solar-only with FSP from P4, but the final report
             * Gantt (Fig. 25, W5_T4_4 construction phasing) hauls FSP-1 from
             * the ELZ to the power zone at ~M33 and commissions the power hub
             * at M36 (Y3, P1/P2 boundary), and Fig. 32 has FSP-2 arriving with
             * Crew-1 at P4, FSP-3/4/5 at P5/P6/P7. Bound P4 per fleet v9;
             * early candidate P2 recorded. */
        attribute redefines introducedIn = Phase::P4;
        attribute candidateIntroductionEarly = Phase::P2;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
    }

    part def EclipseBattery :> PowerAsset {
        doc /* SPA eclipse battery from P4. */
        attribute redefines introducedIn = Phase::P4;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
    }

    part def ThoriumMSR :> PowerAsset {
        doc /* Thorium molten salt reactor at PKT; first unit P9 (DG-9.3), ~74
             * at P10 replacing the FSP field, ~679 P11, ~6,890 P12+ (fleet v9)
             * vs 8,334 at Y200 (ECON v1.3) - VC-09 recorded, counts are Wave 5.
             * Fuel: ThCl4 from the KREEP thorium stream (closed loop with
             * SeleniteProcessing); in-situ Ni-201 vessels from P11. Process
             * heat dual-purposed for acid baking. Rated power inherited from
             * Wave 1 (fleet v9 s.18.2, 100 MWe). */
        attribute redefines ratedPower = 100000000.0 [SI::W];
        attribute redefines introducedIn = Phase::P9;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
        attribute replacesPktFspFrom = Phase::P10;
        attribute inSituVesselsFrom = Phase::P11;
    }

    part def SpaThoriumMSR :> PowerAsset {
        doc /* SPA thorium MSR fuelled by ThCl4 via MD-3.
             * FLAG F5 - DEMAND-GATED, not phase-gated (Jason, 14 Sep 2026).
             * introducedIn is deliberately UNBOUND: the phase of introduction
             * is to be derived from SPA power demand versus non-MSR generation
             * capability and deployment feasibility, evaluated on model data
             * at Wave 5 through SeleniteAnalysis::SpaMsrIntroductionGate.
             * Document phase labels are candidates only, and the integrating
             * reference (SEL_FINAL_REPORT_v4) carries both: Fig. 33 P10 card
             * "SPA MSR commissioned (DG-10.5) - first nuclear power at crewed
             * base"; Fig. 34 P13 card "SPA MSR #1 commissioned" and P14 "SPA MSR
             * #2/#3". Fleet v9 s.18.1 gives "from Y50" (P10) and units at
             * Y105 / Y125 / Y140 sized to asteroid processing loads. Report
             * text p.2: "As SPA scales, MSRs are employed at the first base
             * too, to accommodate asteroid processing demands" - i.e. demand
             * driven, which is the rule now adopted. The ECON cargo_spa_msr
             * vector (dropped by golden runner v2.0) records what the
             * economics assumed and is an input to the gate, not its answer. */
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute gatedByDemand : Boolean = true;
        attribute candidateIntroductionEarly = Phase::P10;
        attribute candidateIntroductionLate = Phase::P13;
        attribute asteroidProcessingUnitsFrom = Phase::P12;
        attribute econAssumedIntroductionYear : Integer = 105;
        doc econDoc /* Transcribed from the computational authority (rule 3):
             * SELENITE_ECON_V1_3/V1_4, runner v2.1 capture 14 Sep 2026,
             * cargo_spa_msr first non-zero at Y105 (then Y125, Y140; 15 t
             * each), spa_msr_count vector present. Y105 is P12 by the year
             * table. Decision Framework Rev D also gates SPA MSR at Y50
             * (DG-10.5) and Y70 (DG-11.3); the economics did not fund those.
             * The Wave 5 planner must either reproduce Y105 from the demand
             * gate or flag the difference as an ECN to the economics. */
    }

    part def PktFspField :> PowerAsset {
        doc /* PKT fission surface power field for construction waves 1-4 (P8);
             * superseded by the MSR fleet from P10 (unit count Wave 5). */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = Phase::P10;
        attribute redefines location = SiteId::pkt;
    }

    part def HubChargingStation :> PowerAsset {
        doc /* PKT hauler hub charging station (one per 100 haulers; every fifth
             * a maintenance hub with ARM-C for ORU swaps), from P8 with the
             * first haulers. Source: fleet v9 s.10.6 and s.15. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::pkt;
    }

    part def SpaPowerZone :> PhaseGated {
        doc /* SPA power zone (SEL-CAD-PZ-001): array + FSP + battery, with the
             * SPA MSR slot (F5). Feeds the PSR trunk cable. */
        attribute redefines introducedIn = Phase::P3;
        attribute redefines retiredIn = null;
        part solarArray : SolarArray;
        part fsp : FissionSurfacePower;
        part eclipseBattery : EclipseBattery;
        part spaMsr : SpaThoriumMSR;
        port psrTrunkFeed;
        port baseBus;
    }

    part def PktPowerSystem :> PhaseGated {
        doc /* PKT power: FSP field (P8) -> thorium MSR fleet (P9+), hub
             * charging stations for the hauler fleet. */
        attribute redefines introducedIn = Phase::P8;
        attribute redefines retiredIn = null;
        part fspField : PktFspField;
        part referenceMsr : ThoriumMSR;
        part referenceHubStation : HubChargingStation;
        port spineBus;
        port thcl4FuelInlet;
    }
}
