package Architecture {
  private import SystemRequirements::*;
  private import BehaviorStates::*;
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  interface def PowerInterface;
  interface def DataInterface;
  interface def CommandInterface;
  connection def PowerConnection;
  connection def DataConnection;
  connection def CommandConnection;

  item def OccupancyGrid;
  item def PoseEstimate;
  item def ObstacleObservation;
  item def CliffObservation;
  item def HazardEvent;
  item def DriveCommand;
  item def CleaningCommand;
  item def MissionStatus;
  item def UserCommand;

  port def PowerLoadPort {
    in item electricalPower;
  }
  port def SensorDataPort {
    out item observation;
  }
  port def MissionCommandPort {
    in item command;
  }
  port def MissionStatusPort {
    out item status;
  }

  part def RobotSubsystem {
    doc /*
      Shared roll-up attributes for robot subsystems (power, mass, BOM).
      Specialized by each physical or logical subsystem below.
    */
    attribute powerDrawW : PowerValue;
    attribute massKg : MassValue;
    attribute bomCost : MonetaryAmount;
  }

  part def MobilitySubsystem :> RobotSubsystem {
    attribute drivePowerW : PowerValue = 28 [W];
    attribute :>> powerDrawW = 28 [W];
    attribute :>> massKg = 1.2 [kg];
    attribute :>> bomCost = 120 [EUR];
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
    item wheelOdometry : PoseEstimate;
    item driveFault : HazardEvent;
  }
  part def CleaningSubsystem :> RobotSubsystem {
    attribute brushPowerW : PowerValue = 12 [W];
    attribute vacuumPowerW : PowerValue = 6 [W];
    attribute dustBinCapacityMl : Integer = 450;
    attribute :>> powerDrawW = 18 [W];
    attribute :>> massKg = 0.9 [kg];
    attribute :>> bomCost = 75 [EUR];
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
    item dustBinStatus : MissionStatus;
    item brushFault : HazardEvent;
  }
  part def PerceptionSubsystem :> RobotSubsystem {
    attribute obstacleDetectionRangeMm : LengthValue = 1200 [mm];
    attribute cliffDetectionHeightMm : LengthValue = 50 [mm];
    attribute :>> powerDrawW = 6 [W];
    attribute :>> massKg = 0.32 [kg];
    attribute :>> bomCost = 58 [EUR];
    port powerIn : PowerLoadPort;
    port mapOut;
    port obstacleOut;
    port cliffOut;
    item occupancyGrid : OccupancyGrid;
    item obstacleObservation : ObstacleObservation;
    item cliffObservation : CliffObservation;
  }
  part def NavigationSubsystem :> RobotSubsystem {
    attribute localizationErrorMm : LengthValue = 120 [mm];
    attribute coverageCellSizeMm : LengthValue = 100 [mm];
    attribute :>> powerDrawW = 5 [W];
    attribute :>> massKg = 0.18 [kg];
    attribute :>> bomCost = 20 [EUR];
    port powerIn : PowerLoadPort;
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
  part def PowerSubsystem :> RobotSubsystem {
    attribute electronicsPowerW : PowerValue = 8 [W];
    attribute batteryCapacity : EnergyValue = 648 [kJ];
    attribute lowBatteryThresholdPercent : Real = 15.0;
    attribute reserveEnergy : EnergyValue = 97 [kJ];
    attribute :>> powerDrawW = 8 [W];
    attribute :>> massKg = 0.72 [kg];
    attribute :>> bomCost = 68 [EUR];
    port powerOut;
    item batteryStatus : MissionStatus;
    item powerHazard : HazardEvent;
  }
  part def DockingSubsystem :> RobotSubsystem {
    attribute dockingBeaconRangeMm : LengthValue = 2500 [mm];
    attribute :>> powerDrawW = 2 [W];
    attribute :>> massKg = 0.38 [kg];
    attribute :>> bomCost = 24 [EUR];
    port powerIn : PowerLoadPort;
    port dockStatusOut;
    item dockStatus : MissionStatus;
  }
  part def ControlSoftware :> RobotSubsystem {
    attribute controlLoopPeriodMs : Integer = 50;
    attribute hazardReactionTimeMs : Integer = 100;
    attribute :>> powerDrawW = 3 [W];
    attribute :>> massKg = 0.10 [kg];
    attribute :>> bomCost = 8 [EUR];
    port powerIn : PowerLoadPort;
    port commandOut;
    port statusOut;
    port hazardIn;
    item userCommand : UserCommand;
    item hazard : HazardEvent;
    item safeCommand : DriveCommand;
    item driveCommand : DriveCommand;
    item cleaningCommand : CleaningCommand;
    item missionStatus : MissionStatus;
    exhibit state behavior : RobotOperatingBehavior;
  }
  part def UserInterface :> RobotSubsystem {
    attribute supportsLocalOnlyMode : Boolean = true;
    attribute :>> powerDrawW = 1 [W];
    attribute :>> massKg = 0.65 [kg];
    attribute :>> bomCost = 4 [EUR];
    port statusIn;
    port userCommandOut;
    item missionStatus : MissionStatus;
    item appCommand : UserCommand;
  }
  part def SafetySupervisor :> RobotSubsystem {
    attribute safeStopReactionTimeMs : Integer = 100;
    attribute :>> powerDrawW = 1 [W];
    attribute :>> massKg = 0.08 [kg];
    attribute :>> bomCost = 10 [EUR];
    port powerIn : PowerLoadPort;
    port hazardIn;
    port safeCommandOut;
    item hazard : HazardEvent;
    item safeCommand : DriveCommand;
  }

  part def AutonomousFloorCleaningRobot {
    part mobility : MobilitySubsystem;
    part cleaning : CleaningSubsystem;
    part perception : PerceptionSubsystem;
    part navigation : NavigationSubsystem;
    part power : PowerSubsystem;
    part docking : DockingSubsystem;
    part control : ControlSoftware;
    part userInterface : UserInterface;
    part safety : SafetySupervisor;
    connect power.powerOut to mobility.powerIn;
    connect power.powerOut to cleaning.powerIn;
    connect power.powerOut to perception.powerIn;
    connect power.powerOut to navigation.powerIn;
    connect power.powerOut to docking.powerIn;
    connect power.powerOut to control.powerIn;
    connect power.powerOut to safety.powerIn;
    connect perception.mapOut to navigation.mapIn;
    connect perception.obstacleOut to navigation.obstacleIn;
    connect mobility.wheelOdometry to navigation.odometry;
    connect navigation.commandOut to control.commandOut;
    connect control.commandOut to mobility.commandIn;
    connect control.commandOut to cleaning.commandIn;
    connect control.statusOut to userInterface.statusIn;
    connect userInterface.userCommandOut to control.commandOut;
    connect docking.dockStatusOut to control.statusOut;
    connect perception.cliffObservation to safety.hazard;
    connect mobility.driveFault to safety.hazard;
    connect cleaning.brushFault to safety.hazard;
    connect power.powerHazard to safety.hazard;
    connect safety.safeCommand to control.safeCommand;
  }

  part robot : AutonomousFloorCleaningRobot;

  satisfy robot.mobility by coverFloor;
  satisfy robot.cleaning by cleanAtLeastEighty;
  satisfy robot.perception by avoidObstacles;
  satisfy robot.perception by detectCliffs;
  satisfy robot.navigation by coverFloor;
  satisfy robot.navigation by localizeReliably;
  satisfy robot.navigation by updateCoverageMap;
  satisfy robot.power by cleanAtLeastEighty;
  satisfy robot.power by chargeSafely;
  satisfy robot.docking by returnToDock;
  satisfy robot.control by detectDustBin;
  satisfy robot.control by recoverFromStall;
  satisfy robot.userInterface by reportCleaningStatus;
  satisfy robot.userInterface by protectMapPrivacy;
  satisfy robot.safety by superviseHazards;
  satisfy robot by limitBomCost;
  satisfy robot by limitTotalMass;
}
