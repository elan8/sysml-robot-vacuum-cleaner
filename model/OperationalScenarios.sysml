package OperationalScenarios {
  private import Architecture::*;

  part def Homeowner;
  part def HomeEnvironment;

  action def StartMission;
  action def BuildMap;
  action def PlanCoveragePath;
  action def CleanReachableArea;
  action def AvoidDynamicObstacle;
  action def RecoverFromStall;
  action def ReturnToDock;
  action def ChargeBattery;
  action def ReportMissionStatus;

  use case def RunAutonomousCleaningMission {
    subject robot : AutonomousFloorCleaningRobot;
    actor homeowner : Homeowner;
    actor home : HomeEnvironment;
    objective {
      doc /*
        Clean reachable floor area with autonomous mapping, hazard supervision,
        recovery behavior, status reporting, and return-to-dock charging.
      */
    }
  }

  action def AutonomousCleaningMission {
    action startMission : StartMission;
    action buildMap : BuildMap;
    action planCoveragePath : PlanCoveragePath;
    action cleanReachableArea : CleanReachableArea;
    action reportMissionStatus : ReportMissionStatus;
    action returnToDock : ReturnToDock;
    action chargeBattery : ChargeBattery;
    first startMission then buildMap;
    first buildMap then planCoveragePath;
    first planCoveragePath then cleanReachableArea;
    first cleanReachableArea then reportMissionStatus;
    first reportMissionStatus then returnToDock;
    first returnToDock then chargeBattery;
  }

  action def ObstacleRecoveryScenario {
    action startMission : StartMission;
    action buildMap : BuildMap;
    action avoidDynamicObstacle : AvoidDynamicObstacle;
    action recoverFromStall : RecoverFromStall;
    action reportMissionStatus : ReportMissionStatus;
    first startMission then buildMap;
    first buildMap then avoidDynamicObstacle;
    first avoidDynamicObstacle then recoverFromStall;
    first recoverFromStall then reportMissionStatus;
  }
}
