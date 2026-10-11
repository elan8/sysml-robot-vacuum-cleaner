/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Engineering documents generated from the model with Doc42: the customer
 * requirements, system requirements and system design specifications and the
 * verification and validation plan. Each
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
      view referenceDocuments {
        @Section { title = "Applicable and reference documents"; }
        @Prose { file = "prose/references.md"; }
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

    view customerRequirements {
      @Section { title = "Customer requirements"; }
      doc /* Each requirement is a need of the household, stated in the household's terms and
           * identified by a stable number. None of them says how the product meets it or how
           * that is measured: the system requirements that make each need measurable are in
           * RVC-SRS-001. */
      @Table { columns = "ID = id, Requirement = name, Text = text"; kind = "requirement"; sort = "id"; }
      expose StakeholderNeeds::*;
    }

    view constraints {
      @Section { title = "Constraints and assumptions"; }
      @Prose { file = "prose/crs-constraints.md"; }
    }

    view validation {
      @Section { title = "Validation and open points"; }
      @Prose { file = "prose/crs-validation.md"; }
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
        doc /* This specification states what the robot shall do and how well, as verifiable
             * requirements on the robot as a whole. It refines the customer requirements of
             * RVC-CRS-001 and is the baseline for the design (RVC-SDS-001) and for verification
             * (RVC-VVP-001). It contains no design. */
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
      view referenceDocuments {
        @Section { title = "Applicable and reference documents"; }
        @Prose { file = "prose/references.md"; }
      }
    }

    view overview {
      @Section { title = "System overview"; }
      @Prose { file = "prose/srs-overview.md"; }
      view boundary : InterconnectionView {
        @Section { title = "System context"; }
        doc /* The system of interest is the robot. The user, the mobile application, the
             * docking station and the home are outside it; the requirements constrain the
             * robot's behaviour at these interfaces. */
        expose ProductContext::residentialCleaningContext;
      }
      view operatingStates : StateTransitionView {
        @Section { title = "Modes and states"; }
        doc /* The states the robot is required to move through during a mission, including
             * the safe stop that the safety requirements refer to. */
        expose BehaviorStates::RobotOperatingBehavior;
      }
    }

    view designLimits {
      @Section { title = "Limit values"; }
      @Prose { file = "prose/srs-limits.md"; }
    }

    view requirements {
      @Section { title = "System requirements"; }
      doc /* Each requirement constrains one measurable property of the robot against a limit
           * value of the previous section, and names the customer requirement it was derived
           * from. A requirement states what the robot shall do or be, not how: the design that
           * meets it is in RVC-SDS-001, and how it is verified is in RVC-VVP-001. */

      view functional {
        @Section { title = "Functional requirements"; }
        @Table { columns = "ID = id, Requirement = name, Text = text, Derived from = derived-from / id"; sort = "id"; }
        expose SystemRequirements::robotSystemSpecification::'Coverage map maintenance';
        expose SystemRequirements::robotSystemSpecification::'Wheel stall detection and recovery';
        expose SystemRequirements::robotSystemSpecification::'Return to dock on low battery';
        expose SystemRequirements::robotSystemSpecification::'Dust bin capacity';
      }
      view performance {
        @Section { title = "Performance requirements"; }
        @Table { columns = "ID = id, Requirement = name, Text = text, Derived from = derived-from / id"; sort = "id"; }
        expose SystemRequirements::robotSystemSpecification::'Cleaning area per charge';
        expose SystemRequirements::robotSystemSpecification::'Floor coverage';
        expose SystemRequirements::robotSystemSpecification::'Localization accuracy';
        expose SystemRequirements::robotSystemSpecification::'Acoustic noise';
        expose SystemRequirements::robotSystemSpecification::'Threshold climbing';
        expose SystemRequirements::robotSystemSpecification::'Recharge time';
      }
      view interfaces {
        @Section { title = "Interface requirements"; }
        @Table { columns = "ID = id, Requirement = name, Text = text, Derived from = derived-from / id"; sort = "id"; }
        expose SystemRequirements::robotSystemSpecification::'Mission status reporting';
      }
      view physical {
        @Section { title = "Physical characteristics"; }
        @Table { columns = "ID = id, Requirement = name, Text = text, Derived from = derived-from / id"; sort = "id"; }
        expose SystemRequirements::robotSystemSpecification::'Overall height';
        expose SystemRequirements::robotSystemSpecification::'Robot mass';
      }
      view safety {
        @Section { title = "Safety requirements"; }
        @Table { columns = "ID = id, Requirement = name, Text = text, Derived from = derived-from / id"; sort = "id"; }
        expose SystemRequirements::robotSystemSpecification::'Obstacle avoidance';
        expose SystemRequirements::robotSystemSpecification::'Cliff detection';
        expose SystemRequirements::robotSystemSpecification::'Safe stop on hazard';
        expose SystemRequirements::robotSystemSpecification::'Charging within the battery safe operating area';
        expose SystemRequirements::robotSystemSpecification::'Battery protection independent of firmware';
      }
      view security {
        @Section { title = "Security and privacy requirements"; }
        @Table { columns = "ID = id, Requirement = name, Text = text, Derived from = derived-from / id"; sort = "id"; }
        expose SystemRequirements::robotSystemSpecification::'Local storage of map data';
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
      @Section { title = "Verification"; }
      doc /* Every requirement of this specification is verified by at least one verification
           * case. The methods, the cases with their pass criteria and the requirements
           * verification matrix are in the Verification and Validation Plan, RVC-VVP-001.
           * This specification states what is required; it claims nothing about whether the
           * design meets it. */
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
      view referenceDocuments {
        @Section { title = "Applicable and reference documents"; }
        @Prose { file = "prose/references.md"; }
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
      view moduleSummary {
        @Section { title = "Module requirement summary"; }
        doc /* Every module requirement with the system requirement it was derived from and the
             * part that claims it. How each one is verified is in RVC-VVP-001. */
        @Table {
          columns = "ID = id, Module requirement = name, Derived from = derived-from, Satisfied by = satisfied-by";
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

    view satisfaction {
      @Section { title = "Requirement satisfaction"; }
      doc /* The design element that claims each system requirement. A claim is a design intent
           * recorded in the model, not evidence; evidence comes from the verification cases of
           * RVC-VVP-001. */
      @Table {
        columns = "ID = id, System requirement = name, Satisfied by = satisfied-by";
        kind = "requirement";
        sort = "id";
      }
      expose SystemRequirements::robotSystemSpecification::*;
    }

    view openPoints {
      @Section { title = "Limitations and open design points"; }
      @Prose { file = "prose/sds-open.md"; }
    }
  }

  view vvp {
    @Document {
      title = "Autonomous Floor Cleaning Robot";
      subtitle = "Verification and Validation Plan";
      organization = "Elan8";
      number = "RVC-VVP-001";
      revision = "A";
      status = "Draft for review";
      template = "template";
    }

    view introduction {
      @Section { title = "Introduction"; }
      view purpose {
        @Section { title = "Purpose"; }
        doc /* This plan states how Elan8 will show that the robot meets its requirements and
             * that it is the product a household needs. Verification answers the first
             * question against RVC-SRS-001 and the module requirements of RVC-SDS-001;
             * validation answers the second against RVC-CRS-001. The plan defines the methods,
             * the cases with their pass criteria, and the matrices that show every requirement
             * is covered. It contains no results. */
      }
      view scope {
        @Section { title = "Scope"; }
        @Prose { file = "prose/vvp-scope.md"; }
      }
      view conventions {
        @Section { title = "Document conventions"; }
        @Prose { file = "prose/conventions.md"; }
      }
      view referenceDocuments {
        @Section { title = "Applicable and reference documents"; }
        @Prose { file = "prose/references.md"; }
      }
    }

    view system {
      @Section { title = "System under verification"; }
      @Prose { file = "prose/vvp-system.md"; }
      @Figure { file = "figures/product-layout.svg"; caption = "The robot and its modules, the units verification is planned against"; }
    }

    view approach {
      @Section { title = "Verification and validation approach"; }
      @Prose { file = "prose/vvp-approach.md"; }
    }

    view resources {
      @Section { title = "Test articles, facilities and equipment"; }
      @Prose { file = "prose/vvp-resources.md"; }
    }

    view systemVerification {
      @Section { title = "System verification"; }
      doc /* Twelve verification cases cover the system requirements. Six are run on the
           * firmware on its target board and six on the assembled robot. */
      view cases {
        @Section { title = "Verification cases"; }
        doc /* Each case states its method, what is done, and the criterion for passing. The
             * last column lists the requirements the case verifies, at system and at module
             * level. */
        @Table {
          columns = "ID = id, Case = name, Method = @VerificationMethod.kind, Procedure and pass criterion = text, Verifies = verifies / id";
          kind = "verification case";
          sort = "id";
        }
        expose Verification::*;
      }
      view matrix {
        @Section { title = "Requirements verification matrix"; }
        doc /* Every system requirement of RVC-SRS-001 with the methods and the cases that
             * verify it. The build of the model fails for a requirement without a case, so a
             * requirement cannot be missing from this matrix or be left without verification. */
        @Table {
          columns = "ID = id, System requirement = name, Method = verified-by / @VerificationMethod.kind, Verified by = verified-by";
          kind = "requirement";
          sort = "id";
        }
        expose SystemRequirements::robotSystemSpecification::*;
      }
    }

    view moduleVerification {
      @Section { title = "Module verification"; }
      doc /* Module requirements are the budgets that RVC-SDS-001 allocates to the modules.
           * They are verified in the same cases as the system requirements they come from,
           * with the module quantity measured separately, so that a failure at system level
           * can be traced to the module that exceeded its budget. */
      @Table {
        columns = "ID = id, Module requirement = name, Derived from = derived-from / id, Method = verified-by / @VerificationMethod.kind, Verified by = verified-by";
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

    view validation {
      @Section { title = "Validation"; }
      @Prose { file = "prose/vvp-validation.md"; }
      view cases {
        @Section { title = "Validation cases"; }
        @Table {
          columns = "ID = id, Case = name, Method = @VerificationMethod.kind, Activity and acceptance criterion = text, Validates = verifies / id";
          kind = "verification case";
          sort = "id";
        }
        expose Validation::*;
      }
      view matrix {
        @Section { title = "Validation matrix"; }
        doc /* Every customer requirement of RVC-CRS-001 with the validation case that covers
             * it. */
        @Table {
          columns = "ID = id, Customer requirement = name, Method = verified-by / @VerificationMethod.kind, Validated by = verified-by";
          kind = "requirement";
          sort = "id";
        }
        expose StakeholderNeeds::*;
      }
    }

    view status {
      @Section { title = "Status and open points"; }
      @Prose { file = "prose/vvp-status.md"; }
    }
  }
}
