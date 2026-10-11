/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Engineering documents generated from the model with Doc42: the customer
 * requirements, system requirements and system design specifications. Each
 * document is a view; its nested views are the sections, in order. Tables,
 * values and diagrams are read from the model, so they cannot drift from it.
 * A short text is the `doc` of its section, written in Markdown; a long one is
 * a Markdown file in `prose/`.
 */
package RobotDocuments {
  private import Doc42::*;
  private import StandardViewDefinitions::*;

  view crs {
    @Document {
      title = "Autonomous Floor Cleaning Robot";
      subtitle = "Customer Requirements Specification";
      organization = "Elan8";
      number = "RVC-CRS-001";
      revision = "A";
      status = "Draft for review";
      template = "template";
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
      @Figure { file = "figures/operating-context.svg"; caption = "The reference home, the parties in it and the conditions the robot meets"; }
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
      expose StakeholderNeeds::'Cleaning under furniture';
      expose StakeholderNeeds::'Quiet operation';
      expose StakeholderNeeds::'Easy routine maintenance';
      expose StakeholderNeeds::'Thresholds between rooms';
      expose StakeholderNeeds::'Carrying between floors';
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
      subtitle = "System Requirements Specification";
      organization = "Elan8";
      number = "RVC-SRS-001";
      revision = "A";
      status = "Draft for review";
      template = "template";
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
        doc /* The system of interest is the robot: its mechanics, electronics and firmware. The
             * requirements apply to the robot as delivered, operating in the conditions of use
             * stated in RVC-CRS-001.
             *
             * The docking station, the mobile application and the home are external to the
             * system. They appear in this specification only through the interfaces the robot
             * has with them. Requirements on those external systems are not part of this
             * document. */
      }
      view conventions {
        @Section { title = "Document conventions"; }
        @Prose { file = "prose/conventions.md"; }
      }
    }

    view overview {
      @Section { title = "System overview"; }
      @Prose { file = "prose/srs-overview.md"; }
      @Figure { file = "figures/product-layout.svg"; caption = "Product layout with the envelope the physical requirements refer to"; }
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
        expose SystemRequirements::robotSystemSpecification::'Acoustic noise';
        expose SystemRequirements::robotSystemSpecification::'Threshold climbing';
        expose SystemRequirements::robotSystemSpecification::'Recharge time';
      }
      view safety : GeneralView {
        @Section { title = "Safety"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Obstacle avoidance';
        expose SystemRequirements::robotSystemSpecification::'Cliff detection';
        expose SystemRequirements::robotSystemSpecification::'Safe stop on hazard';
        expose SystemRequirements::robotSystemSpecification::'Charging within the battery safe operating area';
        expose SystemRequirements::robotSystemSpecification::'Battery protection independent of firmware';
      }
      view functional : GeneralView {
        @Section { title = "Functional"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Coverage map maintenance';
        expose SystemRequirements::robotSystemSpecification::'Wheel stall detection and recovery';
        expose SystemRequirements::robotSystemSpecification::'Return to dock on low battery';
        expose SystemRequirements::robotSystemSpecification::'Dust bin capacity';
      }
      view interfaceAndSecurity : GeneralView {
        @Section { title = "Interface and security"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Mission status reporting';
        expose SystemRequirements::robotSystemSpecification::'Local storage of map data';
      }
      view physical : GeneralView {
        @Section { title = "Physical characteristics"; }
        @RequirementTable;
        expose SystemRequirements::robotSystemSpecification::'Overall height';
        expose SystemRequirements::robotSystemSpecification::'Robot mass';
      }
    }

    view traceability {
      @Section { title = "Traceability to customer requirements"; }
      doc /* Every customer requirement of RVC-CRS-001 has one derivation in the model. The
           * derivation names all system requirements derived from the customer requirement and
           * records why that set is complete: meeting all of them leaves nothing of the
           * customer requirement unmet.
           *
           * The table shows those derivations as they are in the model. The build of the model
           * fails when a customer requirement has no derivation or when a system requirement is
           * named by none, so a row cannot be missing. */
      @Table {
        columns = "Customer requirement = original, Derived system requirements = derived, Why this set is complete = @Rationale.text";
        kind = "connection";
        sort = "original";
      }
      expose RequirementTraceability::*;
    }

    view verification {
      @Section { title = "Verification approach"; }
      @Prose { file = "prose/srs-verification.md"; }
      @Table {
        columns = "ID = id, System requirement = name, Satisfied by = satisfied-by, Verified by = verified-by";
        kind = "requirement";
        sort = "id";
      }
      expose SystemRequirements::robotSystemSpecification::*;
    }
  }

  view sds {
    @Document {
      title = "Autonomous Floor Cleaning Robot";
      subtitle = "System Design Specification";
      organization = "Elan8";
      number = "RVC-SDS-001";
      revision = "A";
      status = "Draft for review";
      template = "template";
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
        doc /* The design described here is the single selected baseline of the robot. It covers
             * the functional design, the physical architecture down to module level, the
             * firmware task architecture and the purchased components that determine the
             * design.
             *
             * It also allocates the system requirements to the modules, and lists the bill of
             * materials at the level of the model. Detailed mechanical drawings, circuit
             * schematics and source code are outside this document. Product variants and the
             * trade studies that led to the baseline are not recorded. */
      }
      view conventions {
        @Section { title = "Document conventions"; }
        @Prose { file = "prose/conventions.md"; }
      }
    }

    view designOverview {
      @Section { title = "Design overview"; }
      @Prose { file = "prose/sds-overview.md"; }
      @Figure { file = "figures/system-architecture.svg"; caption = "System architecture: sensing, control, actuation and power, with the safe-stop path"; }
      @Figure { file = "figures/product-layout.svg"; caption = "Product layout and envelope"; }
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

    view allocation {
      @Section { title = "Requirement allocation to modules"; }
      doc /* A system requirement that no single module can meet alone is split into budgets,
           * one for each module on the path. Each budget is a requirement on that module, so a
           * module team can design and verify against its own specification, and a change to
           * one budget is visible to the others.
           *
           * Five system requirements are split this way. Each split is a derivation in the
           * model that records why the budgets close. The module requirements constrain design
           * values that are attributes of the module in the model, so the model shows at any
           * time whether the current design is inside its budget. */
      @Table {
        columns = "System requirement = original, Module requirements = derived, How the budget closes = @Rationale.text";
        kind = "connection";
        sort = "original";
      }
      expose RequirementAllocation::*;
      view safeStopBudget {
        @Section { title = "Safe-stop time budget"; }
        @Prose { file = "prose/sds-safe-stop.md"; }
        @Figure { file = "figures/safe-stop-timing.svg"; caption = "Safe-stop time: module budgets and current design values against the 100 ms limit"; }
      }
      view baseModuleRequirements : GeneralView {
        @Section { title = "Base module requirements"; }
        @RequirementTable;
        expose ModuleRequirements::baseModuleSpecification::'Cliff sensing latency';
        expose ModuleRequirements::baseModuleSpecification::'Drive braking time';
        expose ModuleRequirements::baseModuleSpecification::'Base module mass';
        expose ModuleRequirements::baseModuleSpecification::'Base module height';
        expose ModuleRequirements::baseModuleSpecification::'Battery capacity';
        expose ModuleRequirements::baseModuleSpecification::'Charge current';
      }
      view mainPcbRequirements : GeneralView {
        @Section { title = "Main control board requirements"; }
        @RequirementTable;
        expose ModuleRequirements::mainPcbSpecification::'Drive disable latency';
        expose ModuleRequirements::mainPcbSpecification::'Main board mass';
      }
      view firmwareRequirements : GeneralView {
        @Section { title = "Firmware requirements"; }
        @RequirementTable;
        expose ModuleRequirements::firmwareSpecification::'Safety supervisor deadline';
      }
      view topAndBinRequirements : GeneralView {
        @Section { title = "Top module, dust bin and harness requirements"; }
        @RequirementTable;
        expose ModuleRequirements::topModuleSpecification::'Top module height';
        expose ModuleRequirements::topModuleSpecification::'Top module mass';
        expose ModuleRequirements::dustBinSpecification::'Dust bin mass';
        expose ModuleRequirements::harnessSpecification::'Wiring harness mass';
      }
      view moduleVerification {
        @Section { title = "Module requirement coverage"; }
        doc /* The matrix names, for every module requirement, the system requirement it was
             * derived from, the part that claims it and the verification case that covers it.
             * The same rule applies as for the system-level matrix in RVC-SRS-001: the build of
             * the model fails for a module requirement without a derivation, a claim or a
             * verification case. */
        @Table {
          columns = "ID = id, Module requirement = name, Derived from = derived-from, Satisfied by = satisfied-by, Verified by = verified-by";
          kind = "requirement";
          sort = "id";
        }
        expose ModuleRequirements::baseModuleSpecification::*;
        expose ModuleRequirements::mainPcbSpecification::*;
        expose ModuleRequirements::firmwareSpecification::*;
        expose ModuleRequirements::topModuleSpecification::*;
        expose ModuleRequirements::dustBinSpecification::*;
        expose ModuleRequirements::harnessSpecification::*;
      }
    }

    view firmwareArchitecture {
      @Section { title = "Firmware architecture"; }
      @Prose { file = "prose/sds-firmware.md"; }
    }

    view billOfMaterials {
      @Section { title = "Bill of materials"; }
      @Prose { file = "prose/sds-bom.md"; }
      @Prose { file = "generated/bom.md"; }
      view components {
        @Section { title = "Design-determining components"; }
        @Prose { file = "prose/sds-components.md"; }
      }
    }

    view analyses {
      @Section { title = "Design analyses"; }
      @Prose { file = "prose/sds-analyses.md"; }
      @Prose { file = "generated/mass-budget.md"; }
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
      expose SystemRequirements::robotSystemSpecification::'Overall height';
      expose SystemRequirements::robotSystemSpecification::'Acoustic noise';
      expose SystemRequirements::robotSystemSpecification::'Dust bin capacity';
      expose SystemRequirements::robotSystemSpecification::'Threshold climbing';
      expose SystemRequirements::robotSystemSpecification::'Robot mass';
      expose SystemRequirements::robotSystemSpecification::'Recharge time';
      expose SystemRequirements::robotSystemSpecification::'Battery protection independent of firmware';
    }

    view openPoints {
      @Section { title = "Limitations and open design points"; }
      @Prose { file = "prose/sds-open.md"; }
    }
  }
}
