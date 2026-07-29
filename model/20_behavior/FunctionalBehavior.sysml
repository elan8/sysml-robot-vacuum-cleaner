/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Functional decomposition, operating states, and representative operational scenarios.
 */
package FunctionalArchitecture {
  private import DomainModel::*;

  action def ProvideLocomotion {
    in command : DriveCommand;
    out odometry : PoseEstimate;
    out fault : HazardEvent;
  }

  action def CleanSurface {
    in command : CleaningCommand;
    out status : MissionStatus;
    out fault : HazardEvent;
  }

  action def SenseEnvironment {
    out map : OccupancyGrid;
    out obstacle : ObstacleObservation;
    out cliff : CliffObservation;
    out hazard : HazardEvent;
  }

  action def PlanAndNavigate {
    in mapIn : OccupancyGrid;
    in obstacleIn : ObstacleObservation;
    in odometryIn : PoseEstimate;
    out driveCommand : DriveCommand;
    out coverageMap : OccupancyGrid;
  }

  action def ManagePower {
    out telemetry : BatteryTelemetry;
    out hazard : HazardEvent;
  }

  action def HomeAndDock {
    out dockStatus : MissionStatus;
  }

  action def ControlMission {
    in telemetryIn : BatteryTelemetry;
    in hazardIn : HazardEvent;
    in plannerCommandIn : DriveCommand;
    in safetyCommandIn : DriveCommand;
    in userCommandIn : UserCommand;
    in dockStatusIn : MissionStatus;
    out driveCommandOut : DriveCommand;
    out cleaningCommandOut : CleaningCommand;
    out missionStatusOut : MissionStatus;
  }

  action def SuperviseSafety {
    in hazardIn : HazardEvent;
    out safeCommand : DriveCommand;
  }

  action def InteractWithUser {
    in missionStatusIn : MissionStatus;
    out userCommandOut : UserCommand;
  }

  action def OperateCleaningRobot {
    action locomotion : ProvideLocomotion;
    action cleaning : CleanSurface;
    action perception : SenseEnvironment;
    action navigation : PlanAndNavigate;
    action powerManagement : ManagePower;
    action docking : HomeAndDock;
    action missionControl : ControlMission;
    action safetySupervision : SuperviseSafety;
    action userInteraction : InteractWithUser;

    flow perception.map to navigation.mapIn;
    flow perception.obstacle to navigation.obstacleIn;
    flow locomotion.odometry to navigation.odometryIn;
    flow navigation.driveCommand to missionControl.plannerCommandIn;
    flow docking.dockStatus to missionControl.dockStatusIn;
    flow powerManagement.telemetry to missionControl.telemetryIn;
    flow missionControl.driveCommandOut to locomotion.command;
    flow missionControl.cleaningCommandOut to cleaning.command;
    flow missionControl.missionStatusOut to userInteraction.missionStatusIn;
    flow userInteraction.userCommandOut to missionControl.userCommandIn;
    flow perception.hazard to missionControl.hazardIn;
    flow perception.hazard to safetySupervision.hazardIn;
    flow locomotion.fault to safetySupervision.hazardIn;
    flow cleaning.fault to safetySupervision.hazardIn;
    flow powerManagement.hazard to safetySupervision.hazardIn;
    flow safetySupervision.safeCommand to missionControl.safetyCommandIn;
  }
}

package BehaviorStates {
  item def StartMissionEvent;
  item def SelfTestPassedEvent;
  item def SelfTestFailedEvent;
  item def MappingCompleteEvent;
  item def UserPauseEvent;
  item def UserResumeEvent;
  item def ObstacleStallEvent;
  item def RecoveryCompleteEvent;
  item def RecoveryFailedEvent;
  item def HazardDetectedEvent;
  item def SafeStopClearedEvent;
  item def LowBatteryEvent;
  item def DockDetectedEvent;
  item def ChargeCompleteEvent;
  item def ServiceResetEvent;
  item def CloudConsentChangedEvent;

  state def RobotOperatingBehavior {
    entry; then idle;
    state idle;
    state selfTest;
    state mapping;
    state cleaning;
    state paused;
    state recovering;
    state safeStop;
    state returning;
    state docking;
    state charging;
    state fault;

    transition startMission first idle accept StartMissionEvent then selfTest;
    transition selfTestPassed first selfTest accept SelfTestPassedEvent then mapping;
    transition selfTestFailed first selfTest accept SelfTestFailedEvent then fault;
    transition mappingComplete first mapping accept MappingCompleteEvent then cleaning;
    transition pause first cleaning accept UserPauseEvent then paused;
    transition resume first paused accept UserResumeEvent then cleaning;
    transition stall first cleaning accept ObstacleStallEvent then recovering;
    transition recovered first recovering accept RecoveryCompleteEvent then cleaning;
    transition recoveryFailed first recovering accept RecoveryFailedEvent then safeStop;
    transition hazardDetected first cleaning accept HazardDetectedEvent then safeStop;
    transition safeStopCleared first safeStop accept SafeStopClearedEvent then recovering;
    transition lowBattery first cleaning accept LowBatteryEvent then returning;
    transition dockDetected first returning accept DockDetectedEvent then docking;
    transition chargingStarted first docking accept DockDetectedEvent then charging;
    transition chargeComplete first charging accept ChargeCompleteEvent then idle;
    transition unrecoverable first safeStop accept RecoveryFailedEvent then fault;
    transition serviceReset first fault accept ServiceResetEvent then idle;
  }

  state def PrivacyConsentBehavior {
    entry; then localOnly;
    state localOnly;
    state cloudBackupEnabled;
    transition consentGranted
      first localOnly accept CloudConsentChangedEvent then cloudBackupEnabled;
    transition consentRevoked
      first cloudBackupEnabled accept CloudConsentChangedEvent then localOnly;
  }
}

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

    flow detectCliff.hazard to superviseHazard.hazardIn;
    flow superviseHazard.safeCommand to applySafeStop.command;
    flow superviseHazard.safeCommand to observeSafeStop.stopCommand;
    flow observeSafeStop.stoppedStatus to reportSafeStop.status;
    bind reportedStatus = observeSafeStop.stoppedStatus;

    first startMission then detectCliff;
    first detectCliff then superviseHazard;
    first superviseHazard then applySafeStop;
    first applySafeStop then observeSafeStop;
    first observeSafeStop then reportSafeStop;
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

  satisfy robotSystemSpecification.detectCliffs
    by cliffSafeStop.detectCliff;
  satisfy robotSystemSpecification.superviseHazards
    by cliffSafeStop.superviseHazard;
  satisfy robotSystemSpecification.reportCleaningStatus
    by cliffSafeStop.reportSafeStop;
}
