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
    exhibit state operatingBehavior : RobotOperatingBehavior;

    allocate operate.locomotion to physical.base;
    allocate operate.locomotion to physical.firmwareTasks.actuatorControl;
    allocate operate.cleaning to physical.base.cleaningHead;
    allocate operate.cleaning to physical.firmwareTasks.actuatorControl;
    allocate operate.perception to physical.base;
    allocate operate.perception to physical.top;
    allocate operate.perception to physical.firmwareTasks.sensorAcquisition;
    allocate operate.navigation to physical.firmwareTasks.navigation;
    allocate operate.powerManagement to physical.base.powerModule;
    allocate operate.powerManagement to physical.firmwareTasks.powerManager;
    allocate operate.docking to physical.base.dockInterface;
    allocate operate.missionControl to physical.firmwareTasks.missionController;
    allocate operate.safetySupervision
      to physical.firmwareTasks.safetySupervisor;
    allocate operate.userInteraction to physical.hmi;
    allocate operate.userInteraction to physical.firmwareTasks.appService;
  }

  part robotSystem : CleaningRobotSystemOfInterest;

  satisfy robotSystemSpecification.cleanAtLeastEighty
    by robotSystem.operate.cleaning;
  satisfy robotSystemSpecification.coverFloor
    by robotSystem.operate.navigation;
  satisfy robotSystemSpecification.avoidObstacles
    by robotSystem.operate.perception;
  satisfy robotSystemSpecification.detectCliffs
    by robotSystem.operate.perception;
  satisfy robotSystemSpecification.superviseHazards
    by robotSystem.operate.safetySupervision;
  satisfy robotSystemSpecification.localizeReliably
    by robotSystem.operate.navigation;
  satisfy robotSystemSpecification.updateCoverageMap
    by robotSystem.operate.navigation;
  satisfy robotSystemSpecification.recoverFromStall
    by robotSystem.operate.missionControl;
  satisfy robotSystemSpecification.returnToDock
    by robotSystem.operate.docking;
  satisfy robotSystemSpecification.chargeSafely
    by robotSystem.operate.powerManagement;
  satisfy robotSystemSpecification.reportCleaningStatus
    by robotSystem.operate.userInteraction;
  satisfy robotSystemSpecification.protectMapPrivacy
    by robotSystem.operate.userInteraction;
}
