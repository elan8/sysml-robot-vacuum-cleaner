/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Representative operational scenarios of the cleaning robot.
 */
package OperationalScenarios {
  private import Architecture::*;
  private import DomainModel::*;
  private import FunctionalArchitecture::*;
  private import ProductContext::*;
  private import SystemRequirements::*;

  action def StartMission;

  action def BuildMap {
    out map : OccupancyGrid;
  }

  action def PlanCoveragePath {
    in map : OccupancyGrid;
    out driveCommand : DriveCommand;
  }

  action def CleanReachableArea {
    in driveCommand : DriveCommand;
    out status : MissionStatus;
  }

  action def ReportMissionStatus {
    in status : MissionStatus;
  }

  action def ReturnToDock {
    out dockStatus : MissionStatus;
  }

  action def ChargeBattery {
    out telemetry : BatteryTelemetry;
  }

  action def ObserveSafeStop {
    in stopCommand : DriveCommand;
    out stoppedStatus : MissionStatus;
  }

  action def AutonomousCleaningScenario {
    doc /* Clean the reachable floor and return to the dock when the mission completes. */
    out finalStatus : MissionStatus;

    action startMission : StartMission;
    action buildMap : BuildMap;
    action planCoverage : PlanCoveragePath;
    action cleanArea : CleanReachableArea;
    action reportStatus : ReportMissionStatus;
    action returnHome : ReturnToDock;

    flow buildMap.map to planCoverage.map;
    flow planCoverage.driveCommand to cleanArea.driveCommand;
    flow cleanArea.status to reportStatus.status;
    bind finalStatus = cleanArea.status;

    first startMission then buildMap;
    first buildMap then planCoverage;
    first planCoverage then cleanArea;
    first cleanArea then reportStatus;
    first reportStatus then returnHome;
  }

  action def ObstacleAvoidanceScenario {
    doc /* Detect an unexpected obstacle, replan locally, and continue without collision. */

    action observeEnvironment : SenseEnvironment;
    action replanPath : PlanAndNavigate;
    action updateMission : ControlMission;
    action executeAvoidance : ProvideLocomotion;

    flow observeEnvironment.map to replanPath.mapIn;
    flow observeEnvironment.obstacle to replanPath.obstacleIn;
    flow replanPath.driveCommand to updateMission.plannerCommandIn;
    flow updateMission.driveCommandOut to executeAvoidance.command;

    first observeEnvironment then replanPath;
    first replanPath then updateMission;
    first updateMission then executeAvoidance;
  }

  action def LowBatteryReturnScenario {
    doc /* Detect low battery, end cleaning, return to the dock, and recharge. */

    action monitorBattery : ManagePower;
    action decideReturn : ControlMission;
    action returnHome : ReturnToDock;
    action charge : ChargeBattery;
    action reportStatus : ReportMissionStatus;

    flow monitorBattery.telemetry to decideReturn.telemetryIn;
    flow returnHome.dockStatus to reportStatus.status;

    first monitorBattery then decideReturn;
    first decideReturn then returnHome;
    first returnHome then charge;
    first charge then reportStatus;
  }

  action def CliffSafeStopScenario {
    doc /* Detect a cliff hazard, stop motion, and report the safe-stop state. */
    out reportedStatus : MissionStatus;

    action startMission : StartMission;
    action detectCliff : SenseEnvironment;
    action superviseHazard : SuperviseSafety;
    action applySafeStop : ProvideLocomotion;
    action observeSafeStop : ObserveSafeStop;
    action reportSafeStop : ReportMissionStatus;

    succession flow detectCliff.hazard to superviseHazard.hazardIn;
    succession flow superviseHazard.safeCommand to applySafeStop.command;
    flow superviseHazard.safeCommand to observeSafeStop.stopCommand;
    succession flow observeSafeStop.stoppedStatus to reportSafeStop.status;
    bind reportedStatus = observeSafeStop.stoppedStatus;

    first startMission then detectCliff;
    first applySafeStop then observeSafeStop;
  }

  action autonomousCleaning : AutonomousCleaningScenario;
  action obstacleAvoidance : ObstacleAvoidanceScenario;
  action lowBatteryReturn : LowBatteryReturnScenario;
  action cliffSafeStop : CliffSafeStopScenario;

  use case runAutonomousCleaning {
    subject robot : CleaningRobot;
    actor homeowner : User;
    actor home : ResidentialEnvironment;
    objective {
      doc /*
        Clean the reachable floor, report progress, and return to the dock
        when the mission completes.
      */
    }
    first start;
    then action mission : AutonomousCleaningScenario;
    then done;
  }

  use case avoidUnexpectedObstacle {
    subject robot : CleaningRobot;
    actor homeowner : User;
    actor home : ResidentialEnvironment;
    objective {
      doc /* Continue cleaning safely when furniture or another obstacle blocks the path. */
    }
    first start;
    then action avoidObstacle : ObstacleAvoidanceScenario;
    then done;
  }

  use case returnForLowBattery {
    subject robot : CleaningRobot;
    actor homeowner : User;
    actor dock : DockingStation;
    objective {
      doc /* Preserve availability by returning to the dock before the battery is depleted. */
    }
    first start;
    then action returnAndCharge : LowBatteryReturnScenario;
    then done;
  }

  use case respondToCliffHazard {
    subject robot : CleaningRobot;
    actor homeowner : User;
    actor home : ResidentialEnvironment;
    objective {
      doc /* Prevent the robot from driving over a stair edge and inform the homeowner. */
    }
    first start;
    then action stopSafely : CliffSafeStopScenario;
    then done;
  }

  allocate cliffSafeStop.detectCliff
    to robotSystem.physical.base;
  allocate cliffSafeStop.superviseHazard
    to robotSystem.physical.firmwareTasks.safetySupervisor;
  allocate cliffSafeStop.applySafeStop
    to robotSystem.physical.base;
  allocate cliffSafeStop.reportSafeStop
    to robotSystem.physical.firmwareTasks.appService;

  satisfy robotSystemSpecification.'Cliff detection'
    by cliffSafeStop.detectCliff;
  satisfy robotSystemSpecification.'Safe stop on hazard'
    by cliffSafeStop.superviseHazard;
  satisfy robotSystemSpecification.'Mission status reporting'
    by cliffSafeStop.reportSafeStop;
}
