/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Functional decomposition of the robot and its operating states.
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
