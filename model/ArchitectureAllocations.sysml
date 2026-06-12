package ArchitectureAllocations {
  private import FunctionalArchitecture::*;
  private import PhysicalArchitecture::*;

  part def AutonomousFloorCleaningRobotSystem {
    part functional : FunctionalCleaningRobot;
    part physical : AutonomousFloorCleaningRobot;

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

    allocate functional.locomotion to physical.mobility;
    allocate functional.cleaning to physical.cleaning;
    allocate functional.perception to physical.perception;
    allocate functional.navigation to physical.navigation;
    allocate functional.powerManagement to physical.power;
    allocate functional.docking to physical.docking;
    allocate functional.missionControl to physical.control;
    allocate functional.safetySupervision to physical.control;
    allocate functional.userInteraction to physical.userInterface;

    allocate startMission to functional.missionControl;
    allocate buildMap to functional.perception;
    allocate planCoveragePath to functional.navigation;
    allocate cleanReachableArea to functional.cleaning;
    allocate avoidDynamicObstacle to functional.perception;
    allocate recoverFromStall to functional.missionControl;
    allocate reportMissionStatus to functional.userInteraction;
    allocate returnToDock to functional.docking;
    allocate chargeBattery to functional.powerManagement;
  }

  part robotSystem : AutonomousFloorCleaningRobotSystem;
}
