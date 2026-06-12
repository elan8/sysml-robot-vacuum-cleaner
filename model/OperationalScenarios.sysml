package OperationalScenarios {
  private import Architecture::*;
  private import FunctionalArchitecture::*;

  part def Homeowner;
  part def HomeEnvironment;

  use case def RunAutonomousCleaningMission {
    subject robotSystem : AutonomousFloorCleaningRobotSystem;
    actor homeowner : Homeowner;
    actor home : HomeEnvironment;
    objective {
      doc /*
        Clean reachable floor area with autonomous mapping, hazard supervision,
        recovery behavior, status reporting, and return-to-dock charging.
      */
    }
  }

  action def ObstacleRecoveryScenario :> ObstacleRecoveryMission;
}
