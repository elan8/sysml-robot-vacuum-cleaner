/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns stakeholder concerns, viewpoints, view definitions, expose filters, and
 * renderings. Depends on all packages that are sliced for presentation. Keep
 * primary engineering facts in their source packages rather than in views.
 */
package ModelViews {
  private import Views::*;
  private import StakeholderNeeds::*;
  private import SystemRequirements::*;
  private import FunctionalArchitecture::*;
  private import Architecture::*;
  private import Verification::*;

  part def StakeholderRole;

  part systemsEngineer : StakeholderRole;
  part productOwner : StakeholderRole;
  part verificationEngineer : StakeholderRole;

  concern productBreakdown {
    subject;
    stakeholder :>> systemsEngineer;
  }

  concern missionBehavior {
    subject;
    stakeholder :>> systemsEngineer;
  }

  concern requirementCoverage {
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> verificationEngineer;
  }

  viewpoint productStructurePerspective {
    frame productBreakdown;
  }

  viewpoint behaviorPerspective {
    frame missionBehavior;
  }

  viewpoint traceabilityPerspective {
    frame requirementCoverage;
  }

  // Product breakdown: robot part tree (part usages only).
  view productStructure : GeneralView {
    satisfy productStructurePerspective;
    expose Architecture::robot;
    filter @SysML::PartUsage;
  }

  // Functional decomposition: capability actions and their bindings.
  view functionalArchitecture {
    satisfy behaviorPerspective;
    expose FunctionalArchitecture::OperateCleaningRobot;
  }

  // Requirements traceability: needs, requirements, verification, and design links.
  view requirementsTraceability : RequirementView {
    satisfy traceabilityPerspective;
    expose StakeholderNeeds::*;
    expose SystemRequirements::*;
    expose Verification::*;
    expose Architecture::robot;
    expose FunctionalArchitecture::operateCleaningRobot;
    filter @SysML::RequirementUsage or @SysML::VerificationCase or @SysML::PartUsage or @SysML::ActionUsage;
  }
}
