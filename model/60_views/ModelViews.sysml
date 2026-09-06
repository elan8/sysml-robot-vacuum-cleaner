/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Nine focused views over the authoritative product graph.
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
    filter @SysML::PartUsage
      or @SysML::PartDefinition
      or @KerML::OwningMembership
      or @KerML::FeatureTyping;
    expose Architecture::robotSystem;
    expose Architecture::CleaningRobotSystemOfInterest;
    expose Architecture::robotSystem.physical;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot;
    expose Architecture::robotSystem.physical.base;
    expose PhysicalArchitecture::BaseModule;
    expose Architecture::robotSystem.physical.mainPcb;
    expose PhysicalArchitecture::MainPcbModule;
    expose Architecture::robotSystem.physical.baseHarness;
    expose PhysicalArchitecture::BaseWiringHarness;
    expose Architecture::robotSystem.physical.topHarness;
    expose PhysicalArchitecture::TopWiringHarness;
    expose Architecture::robotSystem.physical.top;
    expose PhysicalArchitecture::TopModule;
    expose Architecture::robotSystem.physical.dustBin;
    expose PhysicalArchitecture::DustBin;
    expose Architecture::robotSystem.physical.top.hmi;
    expose PhysicalArchitecture::HumanMachineInterface;
  }

  view baseDecomposition : GeneralView {
    satisfy productStructurePerspective;
    filter @SysML::PartUsage
      or @SysML::PartDefinition
      or @KerML::OwningMembership
      or @KerML::FeatureTyping;
    expose Architecture::robotSystem.physical.base;
    expose PhysicalArchitecture::BaseModule;
    expose Architecture::robotSystem.physical.base.chassis;
    expose PhysicalArchitecture::Chassis;
    expose Architecture::robotSystem.physical.base.leftDriveTrain;
    expose Architecture::robotSystem.physical.base.rightDriveTrain;
    expose PhysicalArchitecture::DriveTrain;
    expose Architecture::robotSystem.physical.base.casterWheel;
    expose Architecture::robotSystem.physical.base.cleaningHead;
    expose PhysicalArchitecture::CleaningHeadModule;
    expose Architecture::robotSystem.physical.base.dockInterface;
    expose PhysicalArchitecture::DockInterfaceModule;
    expose Architecture::robotSystem.physical.base.frontLeftCliff;
    expose Architecture::robotSystem.physical.base.frontRightCliff;
    expose Architecture::robotSystem.physical.base.rearLeftCliff;
    expose Architecture::robotSystem.physical.base.rearRightCliff;
    expose PhysicalArchitecture::CliffSensor;
    expose Architecture::robotSystem.physical.base.powerModule;
    expose PhysicalArchitecture::PowerModule;
  }

  view topDecomposition : GeneralView {
    satisfy productStructurePerspective;
    filter @SysML::PartUsage
      or @SysML::PartDefinition
      or @KerML::OwningMembership
      or @KerML::FeatureTyping;
    expose Architecture::robotSystem.physical.top;
    expose PhysicalArchitecture::TopModule;
    expose Architecture::robotSystem.physical.top.frontBumper;
    expose Architecture::robotSystem.physical.top.leftTof;
    expose Architecture::robotSystem.physical.top.rightTof;
    expose Architecture::robotSystem.physical.top.frontTof;
    expose PhysicalArchitecture::RobotTofSensor;
    expose Architecture::robotSystem.physical.top.lidar;
    expose PhysicalArchitecture::RobotLidar;
    expose Architecture::robotSystem.physical.top.hmi;
    expose PhysicalArchitecture::HumanMachineInterface;
  }

  view mainPcbDecomposition : GeneralView {
    satisfy productStructurePerspective;
    filter @SysML::PartUsage
      or @SysML::PartDefinition
      or @KerML::OwningMembership
      or @KerML::FeatureTyping;
    expose Architecture::robotSystem.physical.mainPcb;
    expose PhysicalArchitecture::MainPcbModule;
    expose Architecture::robotSystem.physical.mainPcb.bareBoard;
    expose PhysicalArchitecture::RobotControlBoard;
    expose Architecture::robotSystem.physical.mainPcb.mcu;
    expose PhysicalArchitecture::RobotMainMcu;
    expose Architecture::robotSystem.physical.mainPcb.imu;
    expose Architecture::robotSystem.physical.mainPcb.leftMotorDriver;
    expose Architecture::robotSystem.physical.mainPcb.rightMotorDriver;
    expose PhysicalArchitecture::RobotMotorDriver;
    expose Architecture::robotSystem.physical.mainPcb.wireless;
    expose PhysicalArchitecture::RobotWirelessModule;
  }

  view powerDecomposition : GeneralView {
    satisfy productStructurePerspective;
    filter @SysML::PartUsage
      or @SysML::PartDefinition
      or @KerML::OwningMembership
      or @KerML::FeatureTyping;
    expose Architecture::robotSystem.physical.base.powerModule;
    expose PhysicalArchitecture::PowerModule;
    expose Architecture::robotSystem.physical.base.powerModule.battery;
    expose Architecture::robotSystem.physical.base.powerModule.bms;
    expose PhysicalArchitecture::RobotBms;
    expose Architecture::robotSystem.physical.base.powerModule.charger;
    expose PhysicalArchitecture::RobotBatteryCharger;
    expose Architecture::robotSystem.physical.base.powerModule.logicRegulator;
    expose Architecture::robotSystem.physical.base.powerModule.sensorRegulator;
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
