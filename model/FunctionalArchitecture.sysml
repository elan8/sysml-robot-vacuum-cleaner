package FunctionalArchitecture {
  private import ArchitectureCommon::*;
  private import SystemRequirements::*;

  action def ProvideLocomotion {
    doc /* Provide wheeled locomotion and wheel odometry for coverage and localization. */
    in command : DriveCommand;
    out odometry : PoseEstimate;
    out fault : HazardEvent;
  }

  action def CleanSurface {
    doc /* Actuate brushes and vacuum; monitor dust-bin fill level. */
    in command : CleaningCommand;
    out dustBinStatus : MissionStatus;
    out fault : HazardEvent;
  }

  action def SenseEnvironment {
    doc /* Sense obstacles and cliffs; build occupancy map from range and IMU data. */
    out occupancyGrid : OccupancyGrid;
    out obstacleObservation : ObstacleObservation;
    out cliffObservation : CliffObservation;
    out hazard : HazardEvent;
  }

  action def PlanAndNavigate {
    doc /* Localize the robot, plan coverage paths, and maintain the coverage map. */
    in mapIn : OccupancyGrid;
    in obstacleIn : ObstacleObservation;
    in odometryIn : PoseEstimate;
    out driveCommand : DriveCommand;
    out coverageMap : OccupancyGrid;
  }

  action def ManagePower {
    doc /* Supply electrical power, monitor battery state, and enforce safe charging. */
    out batteryStatus : MissionStatus;
    out hazard : HazardEvent;
    out telemetry : BatteryTelemetry;
  }

  action def HomeAndDock {
    doc /* Home on dock beacon and expose dock/charge contact status. */
    out dockStatus : MissionStatus;
  }

  action def ControlMission {
    doc /*
      Orchestrate mission lifecycle, arbitrate user and planner commands,
      detect dust-bin and stall conditions, and publish mission status.
    */
    in odometryIn : PoseEstimate;
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
    doc /*
      Aggregate hazard inputs and command safe stop within the reaction-time budget.
    */
    in hazardIn : HazardEvent;
    out safeCommand : DriveCommand;
  }

  action def InteractWithUser {
    doc /* Accept local and app commands; present status while protecting map privacy. */
    in missionStatusIn : MissionStatus;
    out userCommandOut : UserCommand;
  }

  action def OperateCleaningRobot {
    doc /*
      Functional decomposition of autonomous floor-cleaning capabilities.
      Concurrent capability actions exchange data through parameter bindings.
    */
    action locomotion : ProvideLocomotion;
    action cleaning : CleanSurface;
    action perception : SenseEnvironment;
    action navigation : PlanAndNavigate;
    action powerManagement : ManagePower;
    action docking : HomeAndDock;
    action missionControl : ControlMission;
    action safetySupervision : SuperviseSafety;
    action userInteraction : InteractWithUser;

    bind navigation.mapIn = perception.occupancyGrid;
    bind navigation.obstacleIn = perception.obstacleObservation;
    bind navigation.odometryIn = locomotion.odometry;
    bind missionControl.odometryIn = locomotion.odometry;
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
  }

  action operateCleaningRobot : OperateCleaningRobot;

  action def StartMission;
  action def BuildMap;
  action def PlanCoveragePath;
  action def CleanReachableArea;
  action def AvoidDynamicObstacle;
  action def RecoverFromStall;
  action def ReturnToDock;
  action def ChargeBattery;
  action def ReportMissionStatus;

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

  action def ObstacleRecoveryMission {
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

  satisfy operateCleaningRobot.locomotion by coverFloor;
  satisfy operateCleaningRobot.cleaning by cleanAtLeastEighty;
  satisfy operateCleaningRobot.cleaning by detectDustBin;
  satisfy operateCleaningRobot.cleaning by keepNoise;
  satisfy operateCleaningRobot.perception by avoidObstacles;
  satisfy operateCleaningRobot.perception by detectCliffs;
  satisfy operateCleaningRobot.navigation by coverFloor;
  satisfy operateCleaningRobot.navigation by localizeReliably;
  satisfy operateCleaningRobot.navigation by updateCoverageMap;
  satisfy operateCleaningRobot.powerManagement by cleanAtLeastEighty;
  satisfy operateCleaningRobot.powerManagement by chargeSafely;
  satisfy operateCleaningRobot.docking by returnToDock;
  satisfy operateCleaningRobot.missionControl by recoverFromStall;
  satisfy operateCleaningRobot.safetySupervision by superviseHazards;
  satisfy operateCleaningRobot.userInteraction by reportCleaningStatus;
  satisfy operateCleaningRobot.userInteraction by protectMapPrivacy;
}
