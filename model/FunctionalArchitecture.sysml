package FunctionalArchitecture {
  private import ArchitectureCommon::*;
  private import SystemRequirements::*;

  part def LocomotionFunction {
    doc /* Provide wheeled locomotion and wheel odometry for coverage and localization. */
    port commandIn : MissionCommandPort;
    port odometryOut : OdometryPort;
    port faultOut : HazardPort;
    item wheelOdometry : PoseEstimate;
    item driveFault : HazardEvent;
  }

  part def CleaningFunction {
    doc /* Actuate brushes and vacuum; monitor dust-bin fill level. */
    port commandIn : MissionCommandPort;
    port statusOut : MissionStatusPort;
    port faultOut : HazardPort;
    item dustBinStatus : MissionStatus;
    item brushFault : HazardEvent;
  }

  part def PerceptionFunction {
    doc /* Sense obstacles and cliffs; build occupancy map from range and IMU data. */
    port mapOut;
    port obstacleOut;
    port cliffOut;
    port hazardOut : HazardPort;
    item occupancyGrid : OccupancyGrid;
    item obstacleObservation : ObstacleObservation;
    item cliffObservation : CliffObservation;
  }

  part def NavigationFunction {
    doc /* Localize the robot, plan coverage paths, and maintain the coverage map. */
    port mapIn;
    port obstacleIn;
    port odometryIn;
    port commandOut;
    item map : OccupancyGrid;
    item obstacles : ObstacleObservation;
    item odometry : PoseEstimate;
    item plannedDriveCommand : DriveCommand;
    item coverageMap : OccupancyGrid;
  }

  part def PowerManagementFunction {
    doc /* Supply electrical power, monitor battery state, and enforce safe charging. */
    port powerOut;
    port telemetryOut : TelemetryPort;
    port hazardOut : HazardPort;
    item batteryStatus : MissionStatus;
    item powerHazard : HazardEvent;
  }

  part def DockingFunction {
    doc /* Home on dock beacon and expose dock/charge contact status. */
    port dockStatusOut;
    item dockStatus : MissionStatus;
  }

  part def MissionControlFunction {
    doc /*
      Orchestrate mission lifecycle, arbitrate user and planner commands,
      detect dust-bin and stall conditions, and publish mission status.
    */
    port commandOut;
    port statusOut;
    port hazardIn;
    port odometryIn : OdometryPort;
    port telemetryIn : TelemetryPort;
    item userCommand : UserCommand;
    item hazard : HazardEvent;
    item driveCommand : DriveCommand;
    item cleaningCommand : CleaningCommand;
    item missionStatus : MissionStatus;
  }

  part def SafetySupervisionFunction {
    doc /*
      Aggregate hazard inputs and command safe stop within the reaction-time budget.
    */
    port hazardIn;
    item safeCommand : DriveCommand;
  }

  part def UserInteractionFunction {
    doc /* Accept local and app commands; present status while protecting map privacy. */
    port statusIn;
    port userCommandOut;
    item missionStatus : MissionStatus;
    item appCommand : UserCommand;
  }

  part def FunctionalCleaningRobot {
    part locomotion : LocomotionFunction;
    part cleaning : CleaningFunction;
    part perception : PerceptionFunction;
    part navigation : NavigationFunction;
    part powerManagement : PowerManagementFunction;
    part docking : DockingFunction;
    part missionControl : MissionControlFunction;
    part safetySupervision : SafetySupervisionFunction;
    part userInteraction : UserInteractionFunction;
    connect perception.mapOut to navigation.mapIn;
    connect perception.obstacleOut to navigation.obstacleIn;
    connect locomotion.odometryOut to navigation.odometryIn;
    connect locomotion.odometryOut to missionControl.odometryIn;
    connect navigation.commandOut to missionControl.commandOut;
    connect missionControl.commandOut to locomotion.commandIn;
    connect missionControl.commandOut to cleaning.commandIn;
    connect missionControl.statusOut to userInteraction.statusIn;
    connect userInteraction.userCommandOut to missionControl.commandOut;
    connect docking.dockStatusOut to missionControl.statusOut;
    connect perception.hazardOut to missionControl.hazardIn;
    connect perception.hazardOut to safetySupervision.hazardIn;
    connect locomotion.faultOut to missionControl.hazardIn;
    connect locomotion.faultOut to safetySupervision.hazardIn;
    connect cleaning.faultOut to missionControl.hazardIn;
    connect cleaning.faultOut to safetySupervision.hazardIn;
    connect powerManagement.hazardOut to missionControl.hazardIn;
    connect powerManagement.hazardOut to safetySupervision.hazardIn;
    connect powerManagement.telemetryOut to missionControl.telemetryIn;
  }

  part functionalRobot : FunctionalCleaningRobot;

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

  satisfy functionalRobot.locomotion by coverFloor;
  satisfy functionalRobot.cleaning by cleanAtLeastEighty;
  satisfy functionalRobot.cleaning by detectDustBin;
  satisfy functionalRobot.cleaning by keepNoise;
  satisfy functionalRobot.perception by avoidObstacles;
  satisfy functionalRobot.perception by detectCliffs;
  satisfy functionalRobot.navigation by coverFloor;
  satisfy functionalRobot.navigation by localizeReliably;
  satisfy functionalRobot.navigation by updateCoverageMap;
  satisfy functionalRobot.powerManagement by cleanAtLeastEighty;
  satisfy functionalRobot.powerManagement by chargeSafely;
  satisfy functionalRobot.docking by returnToDock;
  satisfy functionalRobot.missionControl by recoverFromStall;
  satisfy functionalRobot.safetySupervision by superviseHazards;
  satisfy functionalRobot.userInteraction by reportCleaningStatus;
  satisfy functionalRobot.userInteraction by protectMapPrivacy;
}
