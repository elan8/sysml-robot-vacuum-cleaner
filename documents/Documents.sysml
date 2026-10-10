/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Engineering documents generated from the model with Doc42: the customer
 * requirements, system requirements and system design specifications. Each
 * document is a view; its nested views are the sections, in order. Tables and
 * diagrams are projected from the model, so they cannot drift from it.
 */
package RobotDocuments {
  private import Doc42::*;
  private import StandardViewDefinitions::*;

  view crs {
    @Document {
      title = "Autonomous Floor Cleaning Robot";
      organization = "Elan8";
      number = "RVC-CRS-001";
      revision = "A";
      status = "Draft for review";
      template = "crs";
    }

    view introduction {
      @Section { title = "Introduction"; }
      view purpose {
        @Section { title = "Purpose"; }
        doc /* This specification records what a household expects from the autonomous floor
             * cleaning robot developed by Elan8. It states the customer requirements in the
             * customer's terms, before any design decision, and is the baseline against which
             * the finished product is validated. */
      }
      view scope {
        @Section { title = "Scope"; }
        @Prose { file = "prose/crs-scope.md"; }
      }
      view conventions {
        @Section { title = "Document conventions"; }
        @Prose { file = "prose/conventions.md"; }
      }
    }

    view context {
      @Section { title = "Stakeholders and operating context"; }
      @Prose { file = "prose/crs-context.md"; }
      view contextDiagram : InterconnectionView {
        @Section { title = "Operating context"; }
        doc /* The robot and the external parties it exchanges power, signals and
             * information with. */
        expose ProductContext::residentialCleaningContext;
      }
    }

    view scenarios {
      @Section { title = "Operational scenarios"; }
      @Prose { file = "prose/crs-scenarios.md"; }
    }

    view customerRequirements : GeneralView {
      @Section { title = "Customer requirements"; }
      @RequirementTable;
      doc /* Each requirement is a need of the household, identified by a stable number. The
           * system requirements that refine it are specified in RVC-SRS-001. */
      expose StakeholderNeeds::'Whole-home cleaning in one run';
      expose StakeholderNeeds::'Safe operation in the household';
      expose StakeholderNeeds::'Unattended docking and charging';
      expose StakeholderNeeds::'Reliable navigation at home';
      expose StakeholderNeeds::'Mission progress and fault feedback';
      expose StakeholderNeeds::'Privacy of the home map';
    }

    view constraints {
      @Section { title = "Constraints and assumptions"; }
      @Prose { file = "prose/crs-constraints.md"; }
    }

    view acceptance {
      @Section { title = "Acceptance and open points"; }
      @Prose { file = "prose/crs-acceptance.md"; }
    }
  }

  view srs {
    @Document {
      title = "Autonomous Floor Cleaning Robot";
      organization = "Elan8";
      number = "RVC-SRS-001";
      revision = "A";
      status = "Draft for review";
      template = "srs";
    }

    view introduction {
      @Section { title = "Introduction"; }
      view purpose {
        @Section { title = "Purpose"; }
        doc /* This specification states what the robot system shall do and how well, as
             * verifiable requirements on {{Architecture::robotSystem}}. It refines the customer
             * requirements of RVC-CRS-001 and is the baseline for design (RVC-SDS-001) and for
             * verification. */
      }
      view scope {
        @Section { title = "Scope"; }
        @Prose { file = "prose/srs-scope.md"; }
      }
      view conventions {
        @Section { title = "Document conventions"; }
        @Prose { file = "prose/conventions.md"; }
      }
    }

    view overview {
      @Section { title = "System overview"; }
      @Prose { file = "prose/srs-overview.md"; }
      view boundary : InterconnectionView {
        @Section { title = "System boundary"; }
        doc /* The system of interest is the robot. The user, the mobile application, the
             * docking station and the home are outside it; the requirements constrain the
             * robot's behaviour at these interfaces. */
        expose ProductContext::residentialCleaningContext;
      }
      view operatingStates : StateTransitionView {
        @Section { title = "Operating states"; }
        doc /* The states the robot moves through during a mission, including the safe stop
             * that the safety requirements refer to. */
        expose BehaviorStates::RobotOperatingBehavior;
      }
    }

    view designLimits {
      @Section { title = "Design limits"; }
      @Prose { file = "prose/srs-limits.md"; }
    }

    view requirements {
      @Section { title = "System requirements"; }
      doc /* Requirements are grouped by kind. Each one constrains a measurable property of the
           * robot; the limit values are those of the previous section. The last column names
           * the design element that claims to satisfy the requirement. */

      view performance : GeneralView {
        @Section { title = "Performance"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Cleaning area per charge';
        expose SystemRequirements::robotSystemSpecification::'Floor coverage';
        expose SystemRequirements::robotSystemSpecification::'Localization accuracy';
      }
      view safety : GeneralView {
        @Section { title = "Safety"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Obstacle avoidance';
        expose SystemRequirements::robotSystemSpecification::'Cliff detection';
        expose SystemRequirements::robotSystemSpecification::'Safe stop on hazard';
        expose SystemRequirements::robotSystemSpecification::'Charging within the battery safe operating area';
      }
      view functional : GeneralView {
        @Section { title = "Functional"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Coverage map maintenance';
        expose SystemRequirements::robotSystemSpecification::'Wheel stall detection and recovery';
        expose SystemRequirements::robotSystemSpecification::'Return to dock on low battery';
      }
      view interfaceAndSecurity : GeneralView {
        @Section { title = "Interface and security"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Mission status reporting';
        expose SystemRequirements::robotSystemSpecification::'Local storage of map data';
      }
    }

    view traceability {
      @Section { title = "Traceability to customer requirements"; }
      @Prose { file = "prose/srs-traceability.md"; }
    }

    view verification {
      @Section { title = "Verification approach"; }
      @Prose { file = "prose/srs-verification.md"; }
    }
  }

  view sds {
    @Document {
      title = "Autonomous Floor Cleaning Robot";
      organization = "Elan8";
      number = "RVC-SDS-001";
      revision = "A";
      status = "Draft for review";
      template = "sds";
    }

    view introduction {
      @Section { title = "Introduction"; }
      view purpose {
        @Section { title = "Purpose"; }
        doc /* This specification describes how the robot is built to meet RVC-SRS-001: its
             * functions, its physical and firmware architecture, the purchased components it
             * relies on, and the reasoning that links the design to the requirements. */
      }
      view scope {
        @Section { title = "Scope"; }
        @Prose { file = "prose/sds-scope.md"; }
      }
      view conventions {
        @Section { title = "Document conventions"; }
        @Prose { file = "prose/conventions.md"; }
      }
    }

    view designOverview {
      @Section { title = "Design overview"; }
      @Prose { file = "prose/sds-overview.md"; }
    }

    view functionalDesign {
      @Section { title = "Functional design"; }
      @Prose { file = "prose/sds-functions.md"; }
      view operatingStates : StateTransitionView {
        @Section { title = "Operating states"; }
        doc /* Mission control is a state machine. Every hazard leads to the safe stop, from
             * which only an explicit clearance returns the robot to service. */
        expose BehaviorStates::RobotOperatingBehavior;
      }
      view cliffSafeStop : ActionFlowView {
        @Section { title = "Cliff safe-stop sequence"; }
        doc /* The safety-critical path from a cliff observation to stopped motors and a
             * reported safe-stop state. */
        expose OperationalScenarios::CliffSafeStopScenario;
      }
    }

    view physicalArchitecture {
      @Section { title = "Physical architecture"; }
      @Prose { file = "prose/sds-physical.md"; }
      view interconnection : InterconnectionView {
        @Section { title = "Module interconnection"; }
        doc /* The six line-replaceable units and the electrical, signal and material
             * connections between them. */
        expose Architecture::robotSystem.physical.base;
        expose Architecture::robotSystem.physical.mainPcb;
        expose Architecture::robotSystem.physical.baseHarness;
        expose Architecture::robotSystem.physical.topHarness;
        expose Architecture::robotSystem.physical.top;
        expose Architecture::robotSystem.physical.dustBin;
      }
      view baseModule : InterconnectionView {
        @Section { title = "Base module"; }
        doc /* Chassis, both drive trains, the cleaning head, the four cliff sensors, the power
             * module and the dock interface. */
        expose Architecture::robotSystem.physical.base;
      }
      view powerModule : InterconnectionView {
        @Section { title = "Power module"; }
        doc /* Battery, battery management, charger and the two regulated rails. All loads are
             * fed through the protected output of the battery management system. */
        expose Architecture::robotSystem.physical.base.powerModule;
      }
      view mainPcb : InterconnectionView {
        @Section { title = "Main control board"; }
        doc /* Microcontroller, motor drivers, inertial measurement unit and wireless module. */
        expose Architecture::robotSystem.physical.mainPcb;
      }
      view topModule : InterconnectionView {
        @Section { title = "Top module"; }
        doc /* LiDAR, the three time-of-flight sensors, the bumper and the human-machine
             * interface. */
        expose Architecture::robotSystem.physical.top;
      }
    }

    view firmwareArchitecture {
      @Section { title = "Firmware architecture"; }
      @Prose { file = "prose/sds-firmware.md"; }
    }

    view components {
      @Section { title = "Purchased components"; }
      @Prose { file = "prose/sds-components.md"; }
    }

    view analyses {
      @Section { title = "Design analyses"; }
      @Prose { file = "prose/sds-analyses.md"; }
    }

    view satisfaction : GeneralView {
      @Section { title = "Requirement satisfaction"; }
      @RequirementTable;
      doc /* The design element that claims each system requirement. A claim is a design
           * intent recorded in the model, not evidence; evidence comes from the verification
           * cases listed in RVC-SRS-001. */
      expose SystemRequirements::robotSystemSpecification::'Cleaning area per charge';
      expose SystemRequirements::robotSystemSpecification::'Floor coverage';
      expose SystemRequirements::robotSystemSpecification::'Obstacle avoidance';
      expose SystemRequirements::robotSystemSpecification::'Cliff detection';
      expose SystemRequirements::robotSystemSpecification::'Safe stop on hazard';
      expose SystemRequirements::robotSystemSpecification::'Localization accuracy';
      expose SystemRequirements::robotSystemSpecification::'Coverage map maintenance';
      expose SystemRequirements::robotSystemSpecification::'Wheel stall detection and recovery';
      expose SystemRequirements::robotSystemSpecification::'Return to dock on low battery';
      expose SystemRequirements::robotSystemSpecification::'Charging within the battery safe operating area';
      expose SystemRequirements::robotSystemSpecification::'Mission status reporting';
      expose SystemRequirements::robotSystemSpecification::'Local storage of map data';
    }

    view openPoints {
      @Section { title = "Limitations and open design points"; }
      @Prose { file = "prose/sds-open.md"; }
    }
  }
}
