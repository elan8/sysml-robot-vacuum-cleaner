/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Functional decomposition, operating states, and the two showcase scenarios.
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

    bind navigation.mapIn = perception.map;
    bind navigation.obstacleIn = perception.obstacle;
    bind missionControl.plannerCommandIn = navigation.driveCommand;
    bind missionControl.dockStatusIn = docking.dockStatus;
    bind missionControl.telemetryIn = powerManagement.telemetry;
    bind locomotion.command = missionControl.driveCommandOut;
    bind cleaning.command = missionControl.cleaningCommandOut;
    bind userInteraction.missionStatusIn = missionControl.missionStatusOut;
    bind missionControl.userCommandIn = userInteraction.userCommandOut;
    bind missionControl.hazardIn = perception.hazard;
    bind missionControl.hazardIn = locomotion.fault;
    bind missionControl.hazardIn = cleaning.fault;
    bind missionControl.hazardIn = powerManagement.hazard;
    bind safetySupervision.hazardIn = perception.hazard;
    bind safetySupervision.hazardIn = locomotion.fault;
    bind safetySupervision.hazardIn = cleaning.fault;
    bind safetySupervision.hazardIn = powerManagement.hazard;
  }

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

  action def AutonomousCleaningMission {
    action startMission : StartMission;
    action buildMap : BuildMap;
    action planCoverage : PlanCoveragePath;
    action cleanArea : CleanReachableArea;
    action reportStatus : ReportMissionStatus;
    action returnHome : ReturnToDock;
    action charge : ChargeBattery;

    flow buildMap.map to planCoverage.map;
    flow planCoverage.driveCommand to cleanArea.driveCommand;
    flow cleanArea.status to reportStatus.status;

    first startMission then buildMap;
    first buildMap then planCoverage;
    first planCoverage then cleanArea;
    first cleanArea then reportStatus;
    first reportStatus then returnHome;
    first returnHome then charge;
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
  private import Elan8::Method::Core::*;

  action def ObserveSafeStop {
    in stopCommand : DriveCommand;
    out stoppedStatus : MissionStatus;
  }

  action def CliffSafeStopGoldenThread {
    @EngineeringConcern { concern = behavior; }
    doc /* Engineering increment scenario: detect cliff and stop safely. */
    in cliffStimulus : CliffObservation;
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

  action cliffSafeStopGoldenThread : CliffSafeStopGoldenThread;

  use case runAutonomousCleaning {
    subject context : ResidentialCleaningContext;
    actor homeowner : User;
    actor home : HomeEnvironment;
    objective {
      doc /*
        Clean the reachable floor, respond safely to a cliff, report status,
        return to the dock, and keep map data local by default.
      */
    }
    first start;
    then action mission : AutonomousCleaningMission;
    then done;
  }

  use case demonstrateCliffSafeStop {
    subject context : ResidentialCleaningContext;
    actor homeowner : User;
    actor home : HomeEnvironment;
    objective {
      doc /* Demonstrate requirement-to-behavior-to-verification traceability. */
    }
    first start;
    then action executeGoldenThread : CliffSafeStopGoldenThread;
    then done;
  }

  allocate cliffSafeStopGoldenThread.detectCliff
    to robotSystem.physical.base;
  allocate cliffSafeStopGoldenThread.superviseHazard
    to robotSystem.physical.firmwareTasks.safetySupervisor;
  allocate cliffSafeStopGoldenThread.applySafeStop
    to robotSystem.physical.base;
  allocate cliffSafeStopGoldenThread.reportSafeStop
    to robotSystem.physical.firmwareTasks.appService;

  satisfy detectCliffs by cliffSafeStopGoldenThread.detectCliff;
  satisfy superviseHazards by cliffSafeStopGoldenThread.superviseHazard;
  satisfy reportCleaningStatus by cliffSafeStopGoldenThread.reportSafeStop;
}
