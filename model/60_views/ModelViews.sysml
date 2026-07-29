/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Five focused views over the authoritative product graph.
 */
package ModelViews {
  private import Views::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import SystemRequirements::*;

  part def StakeholderRole;
  part systemsEngineer : StakeholderRole;
  part firmwareEngineer : StakeholderRole;
  part verificationEngineer : StakeholderRole;
  part productEngineer : StakeholderRole;

  concern productStructure {
    doc /* What constitutes the selected robot baseline? */
    subject;
    stakeholder :>> systemsEngineer;
    stakeholder :>> productEngineer;
  }
  concern productConnections {
    doc /* How are the product LRUs connected? */
    subject;
    stakeholder :>> systemsEngineer;
  }
  concern firmwareDeployment {
    doc /* Which firmware tasks execute on which processor? */
    subject;
    stakeholder :>> firmwareEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern requirementStructure {
    doc /* Which system requirements constrain the robot? */
    subject;
    stakeholder :>> verificationEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern safeStopScenario {
    doc /* How does a cliff observation lead to a verified safe stop? */
    subject;
    stakeholder :>> verificationEngineer;
    stakeholder :>> systemsEngineer;
  }
  viewpoint productStructurePerspective { frame productStructure; }
  viewpoint productConnectionsPerspective { frame productConnections; }
  viewpoint firmwareDeploymentPerspective { frame firmwareDeployment; }
  viewpoint requirementStructurePerspective { frame requirementStructure; }
  viewpoint safeStopScenarioPerspective { frame safeStopScenario; }

  view productDecomposition : GeneralView {
    satisfy productStructurePerspective;
    filter @SysML::PartUsage or @SysML::PartDefinition;
    expose Architecture::robotSystem;
    expose Architecture::robotSystem.physical;
    expose Architecture::robotSystem.physical.base;
    expose Architecture::robotSystem.physical.mainPcb;
    expose Architecture::robotSystem.physical.baseHarness;
    expose Architecture::robotSystem.physical.topHarness;
    expose Architecture::robotSystem.physical.top;
    expose Architecture::robotSystem.physical.dustBin;
    expose Architecture::robotSystem.physical.top.hmi;
  }

  view interconnections : InterconnectionView {
    satisfy productConnectionsPerspective;
    expose Architecture::robotSystem.physical.base;
    expose Architecture::robotSystem.physical.mainPcb;
    expose Architecture::robotSystem.physical.baseHarness;
    expose Architecture::robotSystem.physical.topHarness;
    expose Architecture::robotSystem.physical.top;
    expose Architecture::robotSystem.physical.dustBin;
  }

  view firmwareDeployment : GeneralView {
    satisfy firmwareDeploymentPerspective;
    filter @SysML::PartUsage or @SysML::AllocationUsage;
    expose Architecture::robotSystem.physical.firmwareTasks.missionController;
    expose Architecture::robotSystem.physical.firmwareTasks.safetySupervisor;
    expose Architecture::robotSystem.physical.firmwareTasks.actuatorControl;
    expose Architecture::robotSystem.physical.firmwareTasks.sensorAcquisition;
    expose Architecture::robotSystem.physical.firmwareTasks.navigation;
    expose Architecture::robotSystem.physical.firmwareTasks.powerManager;
    expose Architecture::robotSystem.physical.firmwareTasks.appService;
    expose Architecture::robotSystem.physical.mainPcb.mcu;
  }

  view systemRequirements : GeneralView {
    satisfy requirementStructurePerspective;
    filter @SysML::RequirementUsage;
    expose SystemRequirements::robotSystemSpecification;
    expose SystemRequirements::robotSystemSpecification::cleanAtLeastEighty;
    expose SystemRequirements::robotSystemSpecification::coverFloor;
    expose SystemRequirements::robotSystemSpecification::avoidObstacles;
    expose SystemRequirements::robotSystemSpecification::detectCliffs;
    expose SystemRequirements::robotSystemSpecification::superviseHazards;
    expose SystemRequirements::robotSystemSpecification::localizeReliably;
    expose SystemRequirements::robotSystemSpecification::updateCoverageMap;
    expose SystemRequirements::robotSystemSpecification::recoverFromStall;
    expose SystemRequirements::robotSystemSpecification::returnToDock;
    expose SystemRequirements::robotSystemSpecification::chargeSafely;
    expose SystemRequirements::robotSystemSpecification::reportCleaningStatus;
    expose SystemRequirements::robotSystemSpecification::protectMapPrivacy;
  }

  view cliffSafeStopScenario : ActionFlowView {
    satisfy safeStopScenarioPerspective;
    expose OperationalScenarios::CliffSafeStopScenario;
  }
}
