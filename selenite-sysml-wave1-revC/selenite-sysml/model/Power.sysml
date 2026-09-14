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
        doc /* Fission surface power unit at SPA: first units with Crew-1 at
             * P4, five by P7 (count Wave 5); covers critical loads (pipeline
             * heating, WEBs) through the 72 h eclipse case. */
        attribute redefines introducedIn = Phase::P4;
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
             * FLAG F5 (recorded, NOT resolved): scope P10 says commissioned at
             * P10 (DG-10.5); scope P13 says "SPA MSR #1 at P13"; fleet v9
             * s.18.1 says units at Y105 (P12/13 boundary), Y125 (P13/14) and
             * Y140 (P14) with "SPA MSR (from Y50)" in the P10 row. Possibly
             * two events (a DG-10.5 pilot and the P13 production units).
             * introducedIn is deliberately UNBOUND until Jason rules. */
        attribute redefines retiredIn = null;
        attribute redefines location = SiteId::spa;
        attribute candidateIntroductionEarly = Phase::P10;
        attribute candidateIntroductionLate = Phase::P13;
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
