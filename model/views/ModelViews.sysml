/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Six small views over the authoritative product graph.
 */
package ModelViews {
  private import Views::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import PurchasedParts::*;
  private import SystemRequirements::*;
  private import Verification::*;

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
  concern runtimeStructure {
    doc /* Which tasks, queues, and physical endpoints form the runtime? */
    subject;
    stakeholder :>> firmwareEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern requirementCoverage {
    doc /* How do requirements connect to realization and verification? */
    subject;
    stakeholder :>> verificationEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern safeStopThread {
    doc /* How does a cliff observation lead to a verified safe stop? */
    subject;
    stakeholder :>> verificationEngineer;
    stakeholder :>> systemsEngineer;
  }
  concern selectedCatalogParts {
    doc /* Which catalog definitions are selected in the physical baseline? */
    subject;
    stakeholder :>> productEngineer;
    stakeholder :>> systemsEngineer;
  }

  viewpoint productStructurePerspective { frame productStructure; }
  viewpoint productConnectionsPerspective { frame productConnections; }
  viewpoint runtimeStructurePerspective { frame runtimeStructure; }
  viewpoint requirementCoveragePerspective { frame requirementCoverage; }
  viewpoint safeStopThreadPerspective { frame safeStopThread; }
  viewpoint selectedCatalogPartsPerspective { frame selectedCatalogParts; }

  view productDecomposition : GeneralView {
    satisfy productStructurePerspective;
    expose Architecture::robotSystem;
    expose Architecture::robotSystem.physical;
    expose Architecture::robotSystem.physical.driveModule;
    expose Architecture::robotSystem.physical.cleaningHead;
    expose Architecture::robotSystem.physical.sensorAssembly;
    expose Architecture::robotSystem.physical.mainElectronics;
    expose Architecture::robotSystem.physical.powerModule;
    expose Architecture::robotSystem.physical.dockInterface;
    expose Architecture::robotSystem.physical.hmi;
    expose Architecture::robotSystem.physical.firmwareTasks;
  }

  view interconnections : InterconnectionView {
    satisfy productConnectionsPerspective;
    expose Architecture::robotSystem.physical.driveModule;
    expose Architecture::robotSystem.physical.cleaningHead;
    expose Architecture::robotSystem.physical.sensorAssembly;
    expose Architecture::robotSystem.physical.mainElectronics;
    expose Architecture::robotSystem.physical.powerModule;
    expose Architecture::robotSystem.physical.dockInterface;
    expose Architecture::robotSystem.physical.hmi;
  }

  view firmwareRuntime : GeneralView {
    satisfy runtimeStructurePerspective;
    expose Architecture::robotSystem.physical.firmwareTasks;
    expose Architecture::robotSystem.physical.firmwareTasks.missionController;
    expose Architecture::robotSystem.physical.firmwareTasks.safetySupervisor;
    expose Architecture::robotSystem.physical.firmwareTasks.actuatorControl;
    expose Architecture::robotSystem.physical.firmwareTasks.sensorAcquisition;
    expose Architecture::robotSystem.physical.firmwareTasks.navigation;
    expose Architecture::robotSystem.physical.firmwareTasks.powerManager;
    expose Architecture::robotSystem.physical.firmwareTasks.appService;
    expose Architecture::robotSystem.physical.firmwareTasks.hazardQueue;
    expose Architecture::robotSystem.physical.firmwareTasks.userCommandQueue;
    expose Architecture::robotSystem.physical.firmwareTasks.plannerCommandQueue;
    expose Architecture::robotSystem.physical.firmwareTasks.safetyCommandQueue;
    expose Architecture::robotSystem.physical.firmwareTasks.mapUpdateQueue;
    expose Architecture::robotSystem.physical.mainElectronics.mainControlPcb.mcu;
  }

  view requirementsTraceability : GeneralView {
    satisfy requirementCoveragePerspective;
    expose SystemRequirements::*;
    expose Architecture::robotSystem.operate;
    expose Verification::*;
  }

  view cliffSafeStopGoldenThread : ActionFlowView {
    satisfy safeStopThreadPerspective;
    expose OperationalScenarios::CliffSafeStopGoldenThread;
    expose OperationalScenarios::cliffSafeStopGoldenThread;
    expose SystemRequirements::detectCliffs;
    expose SystemRequirements::superviseHazards;
    expose AnalysisCases::SafetyReactionAnalysis;
    expose Verification::verifyCliffSafeStop;
  }

  view selectedParts : GeneralView {
    satisfy selectedCatalogPartsPerspective;
    expose PurchasedParts::STM32U575VGT6;
    expose PurchasedParts::DRV8316R;
    expose PurchasedParts::VL53L1CX;
    expose PurchasedParts::RPLIDARC1;
    expose PurchasedParts::ESP32C3MINI1;
    expose PurchasedParts::BQ40Z50R2;
    expose Architecture::robotSystem.physical.mainElectronics.mainControlPcb.mcu;
    expose Architecture::robotSystem.physical.mainElectronics.mainControlPcb.leftMotorDriver;
    expose Architecture::robotSystem.physical.mainElectronics.mainControlPcb.rightMotorDriver;
    expose Architecture::robotSystem.physical.mainElectronics.mainControlPcb.wireless;
    expose Architecture::robotSystem.physical.sensorAssembly.frontTof;
    expose Architecture::robotSystem.physical.sensorAssembly.lidar;
    expose Architecture::robotSystem.physical.powerModule.bms;
  }
}
