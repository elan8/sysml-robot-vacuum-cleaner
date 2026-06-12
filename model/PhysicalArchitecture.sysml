package PhysicalArchitecture {
  private import ArchitectureCommon::*;
  private import BehaviorStates::*;
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  part def RobotSubsystem {
    doc /*
      Shared roll-up attributes for physical robot subsystems (power, mass, BOM).
    */
    attribute powerDrawW : PowerValue;
    attribute massKg : MassValue;
    attribute bomCost : MonetaryAmount;
  }

  part def BrushlessDriveMotor {
    attribute ratedPower : PowerValue = 14 [W];
    attribute massKg : MassValue = 0.18 [kg];
    port powerIn : PowerLoadPort;
    port phaseCommandIn : MissionCommandPort;
  }
  part def WheelGearbox {
    attribute reductionRatio : Real = 38.0;
    attribute massKg : MassValue = 0.12 [kg];
  }
  part def WheelEncoder {
    attribute countsPerRevolution : Integer = 384;
    port odometryOut : OdometryPort;
  }
  part def MotorDriverIC {
    attribute peakCurrentA : Real = 3.0;
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
    port faultOut : HazardPort;
  }
  part def BumperSwitchArray {
    attribute switchCount : Integer = 6;
    port hazardOut : HazardPort;
  }

  part def MobilitySubsystem :> RobotSubsystem {
    doc /*
      Wheel actuation and proprioception. Motor drivers live on the main control PCB;
      phase commands are routed at robot level from control.mainControlPcb.
    */
    attribute drivePowerW : PowerValue = 28 [W];
    attribute :>> powerDrawW = 28 [W];
    attribute :>> massKg = 1.2 [kg];
    attribute :>> bomCost = 120 [EUR];
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
    port odometryOut : OdometryPort;
    port faultOut : HazardPort;
    part leftMotor : BrushlessDriveMotor;
    part rightMotor : BrushlessDriveMotor;
    part leftGearbox : WheelGearbox;
    part rightGearbox : WheelGearbox;
    part leftEncoder : WheelEncoder;
    part rightEncoder : WheelEncoder;
    part bumperSwitches : BumperSwitchArray;
    item wheelOdometry : PoseEstimate;
    item driveFault : HazardEvent;
    connect powerIn to leftMotor.powerIn;
    connect powerIn to rightMotor.powerIn;
    connect leftEncoder.odometryOut to odometryOut;
    connect rightEncoder.odometryOut to odometryOut;
    connect bumperSwitches.hazardOut to faultOut;
  }

  part def BrushMotor {
    attribute ratedPower : PowerValue = 8 [W];
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
    port faultOut : HazardPort;
  }
  part def VacuumFan {
    attribute ratedPower : PowerValue = 6 [W];
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
  }
  part def DustBin {
    attribute capacityMl : Integer = 450;
  }
  part def DustLevelSensor {
    attribute sensorType : String = "optical interrupt";
    port statusOut : MissionStatusPort;
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
    port statusOut : MissionStatusPort;
    port faultOut : HazardPort;
    part mainBrushMotor : BrushMotor;
    part sideBrushMotor : BrushMotor;
    part vacuumFan : VacuumFan;
    part dustBin : DustBin;
    part dustLevelSensor : DustLevelSensor;
    item dustBinStatus : MissionStatus;
    item brushFault : HazardEvent;
    connect powerIn to mainBrushMotor.powerIn;
    connect powerIn to sideBrushMotor.powerIn;
    connect powerIn to vacuumFan.powerIn;
    connect commandIn to mainBrushMotor.commandIn;
    connect commandIn to sideBrushMotor.commandIn;
    connect commandIn to vacuumFan.commandIn;
    connect dustLevelSensor.statusOut to statusOut;
    connect mainBrushMotor.faultOut to faultOut;
    connect sideBrushMotor.faultOut to faultOut;
  }

  part def TimeOfFlightRangeSensor {
    attribute rangeMm : LengthValue = 1200 [mm];
    port observationOut : SensorDataPort;
  }
  part def InfraredCliffSensor {
    attribute triggerHeightMm : LengthValue = 50 [mm];
    port cliffOut : HazardPort;
  }
  part def InertialMeasurementUnit {
    attribute axisCount : Integer = 6;
    port poseOut : OdometryPort;
  }
  part def MapProcessingSoftware {
    attribute gridCellSizeMm : LengthValue = 100 [mm];
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
    port hazardOut : HazardPort;
    part frontTofSensor : TimeOfFlightRangeSensor;
    part leftWallTofSensor : TimeOfFlightRangeSensor;
    part rightWallTofSensor : TimeOfFlightRangeSensor;
    part cliffSensorFrontLeft : InfraredCliffSensor;
    part cliffSensorFrontRight : InfraredCliffSensor;
    part cliffSensorRearLeft : InfraredCliffSensor;
    part cliffSensorRearRight : InfraredCliffSensor;
    part imu : InertialMeasurementUnit;
    part mapProcessor : MapProcessingSoftware;
    item occupancyGrid : OccupancyGrid;
    item obstacleObservation : ObstacleObservation;
    item cliffObservation : CliffObservation;
    connect cliffSensorFrontLeft.cliffOut to hazardOut;
    connect cliffSensorFrontRight.cliffOut to hazardOut;
    connect cliffSensorRearLeft.cliffOut to hazardOut;
    connect cliffSensorRearRight.cliffOut to hazardOut;
  }

  part def CoveragePlannerSoftware {
    attribute plannerType : String = "boustrophedon with obstacle replanning";
  }
  part def LocalizationEstimatorSoftware {
    attribute estimatorType : String = "wheel odometry plus IMU plus range observations";
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
    part localizationEstimator : LocalizationEstimatorSoftware;
    part coveragePlanner : CoveragePlannerSoftware;
    item map : OccupancyGrid;
    item obstacles : ObstacleObservation;
    item odometry : PoseEstimate;
    item plannedDriveCommand : DriveCommand;
    item coverageMap : OccupancyGrid;
  }

  part def LithiumIonBatteryPack {
    attribute cellConfiguration : String = "4S2P";
    attribute nominalEnergy : EnergyValue = 648 [kJ];
    attribute nominalVoltageV : Real = 14.4;
    port powerOut;
  }
  part def BatteryManagementSystem {
    attribute maxChargeCurrentA : Real = 2.0;
    attribute maxCellTemperatureC : Real = 55.0;
    port batteryTelemetryOut : TelemetryPort;
    port hazardOut : HazardPort;
  }
  part def BuckRegulator {
    attribute outputVoltageV : Real = 5.0;
    port powerIn : PowerLoadPort;
    port powerOut;
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
    port telemetryOut : TelemetryPort;
    port hazardOut : HazardPort;
    part batteryPack : LithiumIonBatteryPack;
    part bms : BatteryManagementSystem;
    part logicRegulator : BuckRegulator;
    part motorRegulator : BuckRegulator;
    item batteryStatus : MissionStatus;
    item powerHazard : HazardEvent;
    connect batteryPack.powerOut to powerOut;
    connect bms.batteryTelemetryOut to telemetryOut;
    connect bms.hazardOut to hazardOut;
  }

  part def ChargingContactPair {
    attribute contactMaterial : String = "spring loaded plated copper";
    port powerIn : PowerLoadPort;
  }
  part def DockBeaconReceiver {
    attribute receiverType : String = "infrared homing receiver";
    port statusOut : MissionStatusPort;
  }

  part def DockingSubsystem :> RobotSubsystem {
    attribute dockingBeaconRangeMm : LengthValue = 2500 [mm];
    attribute :>> powerDrawW = 2 [W];
    attribute :>> massKg = 0.38 [kg];
    attribute :>> bomCost = 24 [EUR];
    port powerIn : PowerLoadPort;
    port dockStatusOut;
    part chargingContacts : ChargingContactPair;
    part beaconReceiver : DockBeaconReceiver;
    item dockStatus : MissionStatus;
    connect powerIn to chargingContacts.powerIn;
    connect beaconReceiver.statusOut to dockStatusOut;
  }

  part def MicrocontrollerUnit {
    attribute core : String = "Arm Cortex-M33";
    attribute clockMHz : Integer = 120;
    attribute flashKb : Integer = 1024;
    attribute ramKb : Integer = 256;
  }
  part def WirelessModule {
    attribute radios : String = "Wi-Fi 2.4 GHz and Bluetooth LE";
  }
  part def NonVolatileMemory {
    attribute capacityMb : Integer = 128;
  }
  part def MainControlPcb {
    attribute layerCount : Integer = 4;
    part mcu : MicrocontrollerUnit;
    part wireless : WirelessModule;
    part flash : NonVolatileMemory;
    part leftMotorDriver : MotorDriverIC;
    part rightMotorDriver : MotorDriverIC;
  }
  part def ControlSoftware {
    doc /*
      Application firmware running on the MCU. It owns mission orchestration,
      state management, command arbitration, and app-facing status.
    */
    attribute controlLoopPeriodMs : Integer = 50;
    exhibit state behavior : RobotOperatingBehavior;
  }
  part def SafetySupervisor {
    doc /*
      Safety-monitoring firmware task running on the main MCU, with direct inputs
      from cliff sensors, bumper switches, motor drivers, and the BMS. It can
      override mission commands by issuing a safe-stop drive command.
    */
    attribute safeStopReactionTimeMs : Integer = 100;
  }
  part def ControlElectronicsSubsystem :> RobotSubsystem {
    attribute controlLoopPeriodMs : Integer = 50;
    attribute hazardReactionTimeMs : Integer = 100;
    attribute :>> powerDrawW = 3 [W];
    attribute :>> massKg = 0.10 [kg];
    attribute :>> bomCost = 8 [EUR];
    port powerIn : PowerLoadPort;
    port commandOut;
    port statusOut;
    port hazardIn;
    port odometryIn : OdometryPort;
    port telemetryIn : TelemetryPort;
    part mainControlPcb : MainControlPcb;
    part applicationSoftware : ControlSoftware;
    part safetySupervisor : SafetySupervisor;
    item userCommand : UserCommand;
    item hazard : HazardEvent;
    item safeCommand : DriveCommand;
    item driveCommand : DriveCommand;
    item cleaningCommand : CleaningCommand;
    item missionStatus : MissionStatus;
    exhibit state behavior : RobotOperatingBehavior;
  }

  part def PushButton {
    port commandOut;
  }
  part def StatusLedRing {
    port statusIn;
  }
  part def MobileAppInterface {
    attribute cloudBackupDefaultEnabled : Boolean = false;
    port commandOut;
    port statusIn;
  }

  part def UserInterface :> RobotSubsystem {
    attribute supportsLocalOnlyMode : Boolean = true;
    attribute :>> powerDrawW = 1 [W];
    attribute :>> massKg = 0.65 [kg];
    attribute :>> bomCost = 4 [EUR];
    port statusIn;
    port userCommandOut;
    part cleanButton : PushButton;
    part homeButton : PushButton;
    part statusLedRing : StatusLedRing;
    part mobileApp : MobileAppInterface;
    item missionStatus : MissionStatus;
    item appCommand : UserCommand;
    connect cleanButton.commandOut to userCommandOut;
    connect homeButton.commandOut to userCommandOut;
    connect mobileApp.commandOut to userCommandOut;
    connect statusIn to statusLedRing.statusIn;
    connect statusIn to mobileApp.statusIn;
  }

  part def AutonomousFloorCleaningRobot {
    part mobility : MobilitySubsystem;
    part cleaning : CleaningSubsystem;
    part perception : PerceptionSubsystem;
    part navigation : NavigationSubsystem;
    part power : PowerSubsystem;
    part docking : DockingSubsystem;
    part control : ControlElectronicsSubsystem;
    part userInterface : UserInterface;
    connect power.powerOut to mobility.powerIn;
    connect power.powerOut to cleaning.powerIn;
    connect power.powerOut to perception.powerIn;
    connect power.powerOut to navigation.powerIn;
    connect power.powerOut to docking.powerIn;
    connect power.powerOut to control.powerIn;
    connect power.powerOut to control.mainControlPcb.leftMotorDriver.powerIn;
    connect power.powerOut to control.mainControlPcb.rightMotorDriver.powerIn;
    connect perception.mapOut to navigation.mapIn;
    connect perception.obstacleOut to navigation.obstacleIn;
    connect mobility.odometryOut to navigation.odometryIn;
    connect mobility.odometryOut to control.odometryIn;
    connect navigation.commandOut to control.commandOut;
    connect control.commandOut to mobility.commandIn;
    connect control.commandOut to cleaning.commandIn;
    connect control.mainControlPcb.leftMotorDriver.commandIn to mobility.leftMotor.phaseCommandIn;
    connect control.mainControlPcb.rightMotorDriver.commandIn to mobility.rightMotor.phaseCommandIn;
    connect control.mainControlPcb.leftMotorDriver.faultOut to control.hazardIn;
    connect control.mainControlPcb.rightMotorDriver.faultOut to control.hazardIn;
    connect control.statusOut to userInterface.statusIn;
    connect userInterface.userCommandOut to control.commandOut;
    connect docking.dockStatusOut to control.statusOut;
    connect perception.hazardOut to control.hazardIn;
    connect mobility.faultOut to control.hazardIn;
    connect cleaning.faultOut to control.hazardIn;
    connect power.hazardOut to control.hazardIn;
    connect power.telemetryOut to control.telemetryIn;
  }
}
