package SelenitePhases {
    doc /* Programme temporal spine: phase enumeration P0 through P14+ with
         * programme-year windows, and the PhaseGated base that every
         * phase-existing element specialises.
         * Sources: docs/ARCHITECTURE_BASELINE.md s.1 (skeleton of record),
         * selenite_extended_timeline_v3_revised.html (P7-P14+),
         * W2_T1_1_JS_MTL_v8_5.html (P0-P7), MTL_GUIDE_v18_revised,
         * SEL_ROBOT_FLEET_v9.md App. C. Baseline ECN-019 Rev C + ECN-020.
         *
         * Idiom (decided Wave 2, see CHANGELOG_WAVE2.md): sysml-validate 0.36.0
         * treats an enum def as abstract, so any usage typed ': Phase' raises
         * SSM021. Phase-valued attributes are therefore declared as
         * 'abstract attribute x : Phase' inside an abstract definition and
         * bound in concrete definitions with 'attribute redefines x = Phase::Pn'.
         * A retirement attribute bound to 'null' means "not retired within the
         * programme horizon". */

    private import ScalarValues::*;

    enum def Phase {
        doc /* P0 Earth preparation; P1-P3 uncrewed SPA build-up; P4-P6 crewed
             * SPA; P7 SPA full configuration (HOW target); P8 PKT online;
             * P9-P10 dual-site industrialisation; P11-P14 asteroid captures and
             * scale-up; P14plus steady state 2.5 Mt/yr REO (~Y180+).
             * Source: ARCHITECTURE_BASELINE.md s.1. */
        P0; P1; P2; P3; P4; P5; P6; P7;
        P8; P9; P10; P11; P12; P13; P14; P14plus;
    }

    abstract part def PhaseGated {
        doc /* Base for every element with a phase of introduction and an
             * optional phase of retirement. Concrete definitions bind both;
             * 'retiredIn = null' means never retired within the programme.
             * An unbound 'introducedIn' on a concrete definition is deliberate
             * and marks an open flag (see F5 in Power.sysml). */
        abstract attribute introducedIn : Phase;
        abstract attribute retiredIn : Phase [0..1];
    }

    attribute def PhaseWindow {
        doc /* Programme-year window of one phase (inclusive, Y = programme
             * year). endYear absent means open-ended. */
        attribute startYear : Integer;
        attribute endYear : Integer [0..1];
    }

    part def ProgrammeTimeline {
        doc /* Year ranges per phase. Source: ARCHITECTURE_BASELINE.md s.1
             * (which consolidates Extended Timeline v3 revised, MTL v8.5 and
             * fleet v9 App. C). Windows overlap by design at P1/P2/P3 (P1 Y2-4,
             * P2 Y4-6, P3 Y4-7): parallel work streams, not drift.
             * Note (not an F-flag): fleet v9 App. C gives P0 as Y0-Y3 where
             * the baseline gives Y1-3; the baseline value is carried. */

        attribute p0 : PhaseWindow {
            :>> startYear = 1;
            :>> endYear = 3;
        }
        attribute p1 : PhaseWindow {
            :>> startYear = 2;
            :>> endYear = 4;
        }
        attribute p2 : PhaseWindow {
            :>> startYear = 4;
            :>> endYear = 6;
        }
        attribute p3 : PhaseWindow {
            :>> startYear = 4;
            :>> endYear = 7;
        }
        attribute p4 : PhaseWindow {
            :>> startYear = 7;
            :>> endYear = 9;
        }
        attribute p5 : PhaseWindow {
            :>> startYear = 9;
            :>> endYear = 12;
        }
        attribute p6 : PhaseWindow {
            :>> startYear = 12;
            :>> endYear = 15;
        }
        attribute p7 : PhaseWindow {
            doc /* HOW target phase. Starts Y18, not Y15 - see p6ToP7GapYears. */
            :>> startYear = 18;
            :>> endYear = 25;
        }
        attribute p8 : PhaseWindow {
            :>> startYear = 25;
            :>> endYear = 35;
        }
        attribute p9 : PhaseWindow {
            :>> startYear = 35;
            :>> endYear = 45;
        }
        attribute p10 : PhaseWindow {
            :>> startYear = 45;
            :>> endYear = 60;
        }
        attribute p11 : PhaseWindow {
            :>> startYear = 60;
            :>> endYear = 80;
        }
        attribute p12 : PhaseWindow {
            :>> startYear = 80;
            :>> endYear = 120;
        }
        attribute p13 : PhaseWindow {
            :>> startYear = 120;
            :>> endYear = 140;
        }
        attribute p14 : PhaseWindow {
            :>> startYear = 140;
            :>> endYear = 180;
        }
        attribute p14plus : PhaseWindow {
            doc /* Steady state, open-ended. */
            :>> startYear = 180;
            :>> endYear = null;
        }

        attribute p6ToP7GapYears : Integer = 3;
        doc gapFlag /* FLAG F7 (docs/DOCUMENT_FAMILIES.md): P6 ends Y15, P7
             * starts Y18. Every timeline source carries the three-year gap;
             * none states whether it is intentional slack (PKT commitment
             * gate DG-7.1 deliberation) or drift between the P0-P7 MTL and
             * the P7-P14+ extended timeline. Modelled explicitly as
             * p6ToP7GapYears so it cannot be absorbed silently. Jason to
             * rule; the checked constraint below keeps the windows honest. */

        assert constraint gapIsExplicit {
            doc /* The P6->P7 gap is exactly the declared attribute. */
            p7.startYear - p6.endYear == p6ToP7GapYears
        }
    }
}
