/*
* SPDX-FileCopyrightText: 2026 Elan8
* SPDX-License-Identifier: MIT
*
* Stakeholder views tuned for Spec42 diagram export. Robot LRU interconnection
* uses boundary ports on mainElectronics so views do not expand PCB internals.
*/
package ModelViews {
  private import Views::*;
  private import StakeholderNeeds::*;
  private import SystemRequirements::*;
  private import Architecture::*;
  private import PhysicalArchitecture::*;
  private import Verification::*;
  private import ProductVariants::*;
  private import SafetyAnalysis::*;
  private import AnalysisCases::*;
  private import OperationalScenarios::*;

  part def StakeholderRole;

  part productOwner : StakeholderRole;
  part verificationEngineer : StakeholderRole;
  part firmwareEngineer : StakeholderRole;
  part systemsEngineer : StakeholderRole;
  part safetyEngineer : StakeholderRole;
  part productLineEngineer : StakeholderRole;

  concern requirementCoverage {
    doc /* How do needs, requirements, design, and verification connect? */
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> verificationEngineer;
  }

  concern firmwareRuntime {
    doc /* How are firmware tasks coupled and deployed to modules and the MCU? */
    subject;
    stakeholder :>> firmwareEngineer;
    stakeholder :>> systemsEngineer;
  }

  concern productIntegration {
    doc /* How are robot LRUs interconnected at the harness level? */
    subject;
    stakeholder :>> systemsEngineer;
  }

  viewpoint traceabilityPerspective {
    frame requirementCoverage;
  }

  viewpoint firmwareRuntimePerspective {
    frame firmwareRuntime;
  }

  viewpoint productIntegrationPerspective {
    frame productIntegration;
  }

  concern productArchitecture {
    doc /* How is the robot product broken down into major assemblies and software? */
    subject;
    stakeholder :>> systemsEngineer;
    stakeholder :>> productOwner;
  }

  viewpoint productArchitecturePerspective {
    frame productArchitecture;
  }

  concern operationalGoldenThread {
    doc /*
      How does one cliff event traverse behavior, allocation, requirements, and
      verification evidence without duplicating the underlying model?
    */
    subject;
    stakeholder :>> systemsEngineer;
    stakeholder :>> safetyEngineer;
    stakeholder :>> verificationEngineer;
  }

  concern configuredProduct {
    doc /* Which semantic product options form each candidate or released baseline? */
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> productLineEngineer;
  }

  concern safetyAssurance {
    doc /* Which hazards affect the robot, which controls mitigate them, and what evidence supports those controls? */
    subject;
    stakeholder :>> safetyEngineer;
    stakeholder :>> verificationEngineer;
  }

  viewpoint operationalGoldenThreadPerspective {
    frame operationalGoldenThread;
  }

  viewpoint configuredProductPerspective {
    frame configuredProduct;
  }

  viewpoint safetyAssurancePerspective {
    frame safetyAssurance;
  }

  view productDecomposition : GeneralView {
    satisfy productArchitecturePerspective;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::chassis;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::driveModule;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::cleaningHead;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::sensorAssembly;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::mainElectronics;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::powerModule;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::dockInterface;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::hmi;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot::robotFirmware;
    expose Architecture::robotSystem.physical;
    filter @SysML::PartUsage;
  }

  view firmwareDeployment : GeneralView {
    satisfy firmwareRuntimePerspective;
    expose FirmwareArchitecture::FirmwareTaskArchitecture;
    expose FirmwareArchitecture::FirmwareTaskArchitecture::missionController;
    expose FirmwareArchitecture::FirmwareTaskArchitecture::safetySupervisor;
    expose FirmwareArchitecture::FirmwareTaskArchitecture::sensorAcquisition;
    expose FirmwareArchitecture::FirmwareTaskArchitecture::motorControl;
    expose FirmwareArchitecture::FirmwareTaskArchitecture::appProtocol;
    expose PhysicalArchitecture::RobotFirmwareSuite;
    expose PhysicalArchitecture::RobotFirmwareSuite::applicationFirmware;
    expose PhysicalArchitecture::RobotFirmwareSuite::safetySupervisor;
    expose PhysicalArchitecture::RobotFirmwareSuite::mapProcessing;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.firmwareTasks;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.robotFirmware;
    expose PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.mcu;
    filter @SysML::PartUsage;
  }

  view interconnections : InterconnectionView {
    satisfy productIntegrationPerspective;
    expose Architecture::robotSystem.physical.chassis;
    expose Architecture::robotSystem.physical.driveModule;
    expose Architecture::robotSystem.physical.cleaningHead;
    expose Architecture::robotSystem.physical.sensorAssembly;
    expose Architecture::robotSystem.physical.mainElectronics;
    expose Architecture::robotSystem.physical.powerModule;
    expose Architecture::robotSystem.physical.dockInterface;
    expose Architecture::robotSystem.physical.hmi;
  }

  view requirementsTraceability : GeneralView {
    satisfy traceabilityPerspective;
    expose StakeholderNeeds::*;
    expose SystemRequirements::*;
    expose Verification::*;
    expose Architecture::robotSystem.physical;
    expose StakeholderNeeds::cleanLargeAreas;
    expose StakeholderNeeds::protectHomes;
    expose StakeholderNeeds::respectPrivacy;
    expose SystemRequirements::cleanAtLeastEighty;
    expose SystemRequirements::detectCliffs;
    expose SystemRequirements::superviseHazards;
    expose SystemRequirements::avoidObstacles;
    expose SystemRequirements::recoverFromStall;
    expose SystemRequirements::protectMapPrivacy;
    expose FunctionalArchitecture::operateCleaningRobot;
    expose Verification::verifyBatteryRuntime;
    expose Verification::verifyCliffDetection;
    expose Verification::verifyStallRecovery;
    expose Verification::verifyPrivacyControls;
    filter @SysML::RequirementUsage or
      @SysML::PartUsage or
      @SysML::VerificationCaseUsage;
  }

  view cliffSafeStopGoldenThread : ActionFlowView {
    satisfy operationalGoldenThreadPerspective;
    expose SystemRequirements::detectCliffs;
    expose SystemRequirements::superviseHazards;
    expose SystemRequirements::reportCleaningStatus;
    expose OperationalScenarios::CliffSafeStopGoldenThread;
    expose OperationalScenarios::cliffSafeStopGoldenThread;
    expose SafetyAnalysis::stairFallHazard;
    expose SafetyAnalysis::cliffSensingMitigation;
    expose AnalysisCases::SafetyReactionAnalysis;
    expose Verification::verifyCliffDetection;
    expose Verification::cliffSafeStopEvidence;
  }

  view productConfiguration : InterconnectionView {
    satisfy configuredProductPerspective;
    expose ProductVariants::*;
    expose ProductVariants::VariantOption;
    expose ProductVariants::VariantConfiguration;
    expose ProductVariants::NavigationSensorSuiteChoice;
    expose ProductVariants::CleaningPerformanceChoice;
    expose ProductVariants::BatteryPackChoice;
    expose ProductVariants::SafetyMonitorChoice;
    expose ProductVariants::ConnectivityChoice;
    expose ProductVariants::DockChoice;
    expose ProductVariants::RobotVariantCatalog;
    expose ProductVariants::RobotVariantConfigurations;
    expose ProductVariants::robotVariantCatalog;
    expose ProductVariants::robotVariantConfigurations;
    expose Architecture::robotSystem.physical;
  }

  view safetyAssuranceGraph : InterconnectionView {
    satisfy safetyAssurancePerspective;
    expose SafetyAnalysis::*;
    expose SystemRequirements::detectCliffs;
    expose SystemRequirements::avoidObstacles;
    expose SystemRequirements::recoverFromStall;
    expose SystemRequirements::chargeSafely;
    expose SystemRequirements::superviseHazards;
    expose SystemRequirements::protectMapPrivacy;
    expose Verification::cliffSafeStopEvidence;
    expose Verification::privacyConsentEvidence;
  }
}
