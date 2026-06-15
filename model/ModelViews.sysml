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
  private import PhysicalArchitecture::*;
  private import ArchitectureAllocations::*;
  private import Architecture::*;
  private import BehaviorStates::*;
  private import Verification::*;
  private import AnalysisCases::*;
  private import ProductContext::*;
  private import SafetyAnalysis::*;
  private import TradeStudies::*;
  private import ElectricalInterfaces::*;
  private import InterfaceControl::*;
  private import FirmwareArchitecture::*;

  part def StakeholderRole;

  part systemsEngineer : StakeholderRole;
  part safetyEngineer : StakeholderRole;
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

  concern safetyAssuranceConcern {
    subject;
    stakeholder :>> safetyEngineer;
  }

  concern requirementCoverage {
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> verificationEngineer;
  }

  concern implementationDeployment {
    subject;
    stakeholder :>> systemsEngineer;
  }

  concern operationalContextConcern {
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> systemsEngineer;
  }

  concern tradeRationaleConcern {
    subject;
    stakeholder :>> productOwner;
    stakeholder :>> systemsEngineer;
  }

  concern implementationInterfaceConcern {
    subject;
    stakeholder :>> systemsEngineer;
    stakeholder :>> verificationEngineer;
  }

  viewpoint productStructurePerspective {
    frame productBreakdown;
  }

  viewpoint behaviorPerspective {
    frame missionBehavior;
  }

  viewpoint safetyPerspective {
    frame safetyAssuranceConcern;
  }

  viewpoint traceabilityPerspective {
    frame requirementCoverage;
  }

  viewpoint deploymentPerspective {
    frame implementationDeployment;
  }

  viewpoint contextPerspective {
    frame operationalContextConcern;
  }

  viewpoint tradePerspective {
    frame tradeRationaleConcern;
  }

  viewpoint implementationInterfacePerspective {
    frame implementationInterfaceConcern;
  }

  // Context, structure, behavior, and traceability views.
  view operationalContext {
    satisfy contextPerspective;
    expose ProductContext::residentialCleaningContext::**;
    render asInterconnectionDiagram;
  }

  view productStructure {
    satisfy productStructurePerspective;
    expose Architecture::robot::**[@SysML::PartUsage];
    render asTreeDiagram;
  }

  view physicalInterconnections {
    satisfy productStructurePerspective;
    expose Architecture::robot::**;
    render asInterconnectionDiagram;
  }

  view functionalArchitecture {
    satisfy behaviorPerspective;
    expose FunctionalArchitecture::operateCleaningRobot;
  }

  view nominalMissionFlow {
    satisfy behaviorPerspective;
    expose FunctionalArchitecture::AutonomousCleaningMission;
  }

  view recoveryMissionFlow {
    satisfy behaviorPerspective;
    expose FunctionalArchitecture::ObstacleRecoveryMission;
  }

  view operatingLifecycle {
    satisfy behaviorPerspective;
    expose BehaviorStates::RobotOperatingBehavior;
  }

  view requirementsTraceability {
    satisfy traceabilityPerspective;
    expose StakeholderNeeds::*;
    expose SystemRequirements::*;
    expose Verification::*;
    expose AnalysisCases::*;
    expose SafetyAnalysis::*;
    render asElementTable;
  }

  view safetyAssurance {
    satisfy safetyPerspective;
    expose SafetyAnalysis::*;
    expose SystemRequirements::detectCliffs;
    expose SystemRequirements::superviseHazards;
    expose SystemRequirements::chargeSafely;
    expose SystemRequirements::protectMapPrivacy;
    expose FunctionalArchitecture::operateCleaningRobot::perception;
    expose FunctionalArchitecture::operateCleaningRobot::safetySupervision;
    expose PhysicalArchitecture::SafetySupervisorFirmware;
    expose ArchitectureAllocations::robotSystem::operate::safetySupervision;
    expose Verification::verifyCliffDetection;
    expose Verification::verifySafeCharging;
    expose Verification::verifyLiftOvercurrentThermalHazards;
    expose AnalysisCases::SafetyReactionAnalysis;
  }

  // Deployment, rationale, margin, and implementation-interface views.
  view softwareDeployment {
    satisfy deploymentPerspective;
    expose ArchitectureAllocations::robotSystem;
    expose ArchitectureAllocations::robotSystem::physical::mainElectronics;
    expose ArchitectureAllocations::robotSystem::physical::mainElectronics::mainControlPcb::mcu;
    expose ArchitectureAllocations::robotSystem::physical::mainElectronics::robotFirmware;
  }

  view tradeStudyRationale {
    satisfy tradePerspective;
    expose TradeStudies::*;
    expose AnalysisCases::ProductCostAnalysis;
    expose AnalysisCases::TotalPowerConsumptionAnalysis;
    expose AnalysisCases::MissionEnergyAnalysis;
    render asElementTable;
  }

  view budgetMargins {
    satisfy traceabilityPerspective;
    expose AnalysisCases::TotalMassAnalysis;
    expose AnalysisCases::TotalPowerConsumptionAnalysis;
    expose AnalysisCases::ProductCostAnalysis;
    expose AnalysisCases::MissionEnergyAnalysis;
    render asElementTable;
  }

  view electricalInterfaceControl {
    satisfy implementationInterfacePerspective;
    expose ElectricalInterfaces::mainControlPcbInterfaces::**;
    render asElementTable;
  }

  view firmwareTaskArchitecture {
    satisfy implementationInterfacePerspective;
    expose FirmwareArchitecture::firmwareTaskArchitecture::**;
    render asElementTable;
  }

  view sensorSlamArchitecture {
    satisfy implementationInterfacePerspective;
    expose PhysicalArchitecture::SensorAssembly;
    expose PhysicalArchitecture::TwoDimensionalLidarModule;
    expose PhysicalArchitecture::LocalizationEstimatorSoftware;
    expose FirmwareArchitecture::SlamTask;
    expose FirmwareArchitecture::LocalizationTask;
    expose InterfaceControl::lidarScanFrameContract;
    expose InterfaceControl::poseGraphUpdateContract;
    expose TradeStudies::sensorLidarUpgrade;
    expose TradeStudies::flagshipAiVisionUpgrade;
    expose SystemRequirements::supportRoomScaleSlam;
    expose AnalysisCases::LocalizationPerformanceAnalysis;
    render asElementTable;
  }

  view softwareMessageContracts {
    satisfy implementationInterfacePerspective;
    expose InterfaceControl::*;
    render asElementTable;
  }

  view safetyFaultResponse {
    satisfy safetyPerspective;
    expose BehaviorStates::SafetyFaultResponseBehavior;
    expose FirmwareArchitecture::SafetySupervisorTask;
    expose InterfaceControl::hazardEventContract;
    expose InterfaceControl::driveCommandContract;
  }

  view startupSelfTestFlow {
    satisfy behaviorPerspective;
    expose BehaviorStates::StartupSelfTestBehavior;
    expose FirmwareArchitecture::DiagnosticsTask;
    expose FirmwareArchitecture::SafetySupervisorTask;
  }
}
