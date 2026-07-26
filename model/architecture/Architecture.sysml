/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * System-of-interest usage, functional realization, and requirement satisfaction.
 */
package Architecture {
  public import DomainModel::*;
  public import FunctionalArchitecture::*;
  public import PhysicalArchitecture::*;
  private import BehaviorStates::*;
  private import SystemRequirements::*;

  part def CleaningRobotSystemOfInterest {
    part physical : AutonomousFloorCleaningRobot;
    perform action operate : OperateCleaningRobot;
    perform action nominalMission : AutonomousCleaningMission;
    exhibit state operatingBehavior : RobotOperatingBehavior;

    allocate operate.locomotion to physical.driveModule;
    allocate operate.locomotion to physical.firmwareTasks.actuatorControl;
    allocate operate.cleaning to physical.cleaningHead;
    allocate operate.cleaning to physical.firmwareTasks.actuatorControl;
    allocate operate.perception to physical.sensorAssembly;
    allocate operate.perception to physical.firmwareTasks.sensorAcquisition;
    allocate operate.navigation to physical.firmwareTasks.navigation;
    allocate operate.powerManagement to physical.powerModule;
    allocate operate.powerManagement to physical.firmwareTasks.powerManager;
    allocate operate.docking to physical.dockInterface;
    allocate operate.missionControl to physical.firmwareTasks.missionController;
    allocate operate.safetySupervision
      to physical.firmwareTasks.safetySupervisor;
    allocate operate.userInteraction to physical.hmi;
    allocate operate.userInteraction to physical.firmwareTasks.appService;
  }

  part robotSystem : CleaningRobotSystemOfInterest;

  satisfy cleanAtLeastEighty by robotSystem.operate.cleaning;
  satisfy coverFloor by robotSystem.operate.navigation;
  satisfy avoidObstacles by robotSystem.operate.perception;
  satisfy detectCliffs by robotSystem.operate.perception;
  satisfy superviseHazards by robotSystem.operate.safetySupervision;
  satisfy localizeReliably by robotSystem.operate.navigation;
  satisfy updateCoverageMap by robotSystem.operate.navigation;
  satisfy recoverFromStall by robotSystem.operate.missionControl;
  satisfy returnToDock by robotSystem.operate.docking;
  satisfy chargeSafely by robotSystem.operate.powerManagement;
  satisfy reportCleaningStatus by robotSystem.operate.userInteraction;
  satisfy protectMapPrivacy by robotSystem.operate.userInteraction;
}
