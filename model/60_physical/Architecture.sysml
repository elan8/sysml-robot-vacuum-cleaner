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
    allocate operate.userInteraction to physical.top.hmi;
    allocate operate.userInteraction to physical.firmwareTasks.appService;
  }

  part robotSystem : CleaningRobotSystemOfInterest;

  satisfy robotSystemSpecification.'Cleaning area per charge'
    by robotSystem.operate.cleaning;
  satisfy robotSystemSpecification.'Floor coverage'
    by robotSystem.operate.navigation;
  satisfy robotSystemSpecification.'Obstacle avoidance'
    by robotSystem.operate.perception;
  satisfy robotSystemSpecification.'Cliff detection'
    by robotSystem.operate.perception;
  satisfy robotSystemSpecification.'Safe stop on hazard'
    by robotSystem.operate.safetySupervision;
  satisfy robotSystemSpecification.'Localization accuracy'
    by robotSystem.operate.navigation;
  satisfy robotSystemSpecification.'Coverage map maintenance'
    by robotSystem.operate.navigation;
  satisfy robotSystemSpecification.'Wheel stall detection and recovery'
    by robotSystem.operate.missionControl;
  satisfy robotSystemSpecification.'Return to dock on low battery'
    by robotSystem.operate.docking;
  satisfy robotSystemSpecification.'Charging within the battery safe operating area'
    by robotSystem.operate.powerManagement;
  satisfy robotSystemSpecification.'Mission status reporting'
    by robotSystem.operate.userInteraction;
  satisfy robotSystemSpecification.'Local storage of map data'
    by robotSystem.operate.userInteraction;

  // Physical properties are claimed by the element that determines them.
  satisfy robotSystemSpecification.'Overall height'
    by robotSystem.physical.top;
  satisfy robotSystemSpecification.'Acoustic noise'
    by robotSystem.physical.base.cleaningHead;
  satisfy robotSystemSpecification.'Dust bin capacity'
    by robotSystem.physical.dustBin;
  satisfy robotSystemSpecification.'Threshold climbing'
    by robotSystem.operate.locomotion;
  satisfy robotSystemSpecification.'Robot mass'
    by robotSystem.physical;
  satisfy robotSystemSpecification.'Recharge time'
    by robotSystem.operate.powerManagement;
  satisfy robotSystemSpecification.'Battery protection independent of firmware'
    by robotSystem.physical.base.powerModule.bms;
}
