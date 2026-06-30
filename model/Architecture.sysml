/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns the public architecture hub, the system-of-interest definition
 * (CleaningRobotSystemOfInterest), and all allocation links. Depends on
 * functional/physical/firmware architecture and system requirements.
 * Keep detailed hardware assemblies in PhysicalArchitecture and firmware
 * task definitions in FirmwareArchitecture.
 */
package Architecture {
  public import ArchitectureCommon::*;
  public import PhysicalProtocols::*;
  public import FunctionalArchitecture::*;
  public import PhysicalArchitecture::*;
  public import ArchitectureAllocations::*;
  private import SystemRequirements::*;

  part def CleaningRobotSystemOfInterest {
    doc /*
      The system of interest: the physical robot together with its operational
      behavior and firmware execution surface. Use this as the subject for
      use cases, allocation views, and system-level verification.
    */
    part physical : AutonomousFloorCleaningRobot;

    // Operational capability and scenario surface.
    perform action operate : OperateCleaningRobot;
    perform action nominalMission : AutonomousCleaningMission;
    perform action recoveryMission : ObstacleRecoveryMission;
    perform action startMission : StartMission;
    perform action buildMap : BuildMap;
    perform action planCoveragePath : PlanCoveragePath;
    perform action cleanReachableArea : CleanReachableArea;
    perform action avoidDynamicObstacle : AvoidDynamicObstacle;
    perform action recoverFromStall : RecoverFromStall;
    perform action reportMissionStatus : ReportMissionStatus;
    perform action returnToDock : ReturnToDock;
    perform action chargeBattery : ChargeBattery;

    // Capability-to-LRU/software realization.
    allocate operate.locomotion to physical.driveModule;
    allocate operate.cleaning to physical.cleaningHead;
    allocate operate.perception to physical.sensorAssembly;
    allocate operate.perception to physical.mainElectronics.robotFirmware.mapProcessing;
    allocate operate.navigation to physical.mainElectronics.robotFirmware.localizationEstimator;
    allocate operate.navigation to physical.mainElectronics.robotFirmware.coveragePlanner;
    allocate operate.powerManagement to physical.powerModule;
    allocate operate.docking to physical.dockInterface;
    allocate operate.missionControl to physical.mainElectronics.robotFirmware.applicationFirmware;
    allocate operate.safetySupervision to physical.mainElectronics.robotFirmware.safetySupervisor;
    allocate operate.userInteraction to physical.hmi;
    allocate operate.userInteraction to physical.mainElectronics.robotFirmware.applicationFirmware;

    // Scenario action ownership by operational capability.
    allocate startMission to operate.missionControl;
    allocate buildMap to operate.perception;
    allocate planCoveragePath to operate.navigation;
    allocate cleanReachableArea to operate.cleaning;
    allocate avoidDynamicObstacle to operate.perception;
    allocate recoverFromStall to operate.missionControl;
    allocate reportMissionStatus to operate.userInteraction;
    allocate returnToDock to operate.docking;
    allocate chargeBattery to operate.powerManagement;

  }

  part robotSystem : CleaningRobotSystemOfInterest;

  satisfy robotSystem.physical by limitBomCost;
  satisfy robotSystem.physical by limitTotalMass;
}
