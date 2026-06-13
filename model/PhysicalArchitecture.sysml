package PhysicalArchitecture {
  private import ArchitectureCommon::*;
  private import BehaviorStates::*;
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  part def PhysicalAssembly {
    doc /*
      Shared roll-up attributes for monteerbare robot-assemblies (power, mass, BOM).
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
    attribute peakCurrent : ElectricCurrentValue = 3.0 [A];
    port powerIn : PowerLoadPort;
    port commandIn : MissionCommandPort;
    port faultOut : HazardPort;
  }
  part def BumperSwitchArray {
    attribute switchCount : Integer = 6;
    port hazardOut : HazardPort;
  }

  part def DriveModule :> PhysicalAssembly {
    doc /*
      Mechanical drive LRU: wheel motors, gearboxes, encoders, and bumper switches.
      Motor drivers are mounted on the main control PCB in mainElectronics.
    */
    attribute drivePowerW : PowerValue = 28 [W];
    attribute :>> powerDrawW = 28 [W];
    attribute :>> massKg = 1.2 [kg];
    attribute :>> bomCost = 100 [EUR];
    port powerIn : PowerLoadPort;
    port phaseLeftIn : MissionCommandPort;
    port phaseRightIn : MissionCommandPort;
    port encoderOut : OdometryPort;
    port bumperHazardOut : HazardPort;
    part leftMotor : BrushlessDriveMotor;
    part rightMotor : BrushlessDriveMotor;
    part leftGearbox : WheelGearbox;
    part rightGearbox : WheelGearbox;
    part leftEncoder : WheelEncoder;
    part rightEncoder : WheelEncoder;
    part bumperSwitches : BumperSwitchArray;
    connect powerIn to leftMotor.powerIn;
    connect powerIn to rightMotor.powerIn;
    connect leftMotor.phaseCommandIn to phaseLeftIn;
    connect rightMotor.phaseCommandIn to phaseRightIn;
    connect leftEncoder.odometryOut to encoderOut;
    connect rightEncoder.odometryOut to encoderOut;
    connect bumperSwitches.hazardOut to bumperHazardOut;
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
    attribute capacity : VolumeValue = 450 [mL];
  }
  part def DustLevelSensor {
    attribute sensorType : String = "optical interrupt";
    port statusOut : MissionStatusPort;
  }

  part def CleaningHeadModule :> PhysicalAssembly {
    attribute brushPowerW : PowerValue = 12 [W];
    attribute vacuumPowerW : PowerValue = 6 [W];
    attribute dustBinCapacity : VolumeValue = 450 [mL];
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
  part def CoveragePlannerSoftware {
    attribute plannerType : String = "boustrophedon with obstacle replanning";
  }
  part def LocalizationEstimatorSoftware {
    attribute estimatorType : String = "wheel odometry plus IMU plus range observations";
    attribute localizationErrorMm : LengthValue = 120 [mm];
  }

  part def SensorAssembly :> PhysicalAssembly {
    doc /* Sensor hardware LRU: range, cliff, and inertial sensing (no application firmware). */
    attribute obstacleDetectionRangeMm : LengthValue = 1200 [mm];
    attribute cliffDetectionHeightMm : LengthValue = 50 [mm];
    attribute :>> powerDrawW = 5 [W];
    attribute :>> massKg = 0.28 [kg];
    attribute :>> bomCost = 38 [EUR];
    port powerIn : PowerLoadPort;
    port sensorBusOut;
    port cliffHazardOut : HazardPort;
    part frontTofSensor : TimeOfFlightRangeSensor;
    part leftWallTofSensor : TimeOfFlightRangeSensor;
    part rightWallTofSensor : TimeOfFlightRangeSensor;
    part cliffSensorFrontLeft : InfraredCliffSensor;
    part cliffSensorFrontRight : InfraredCliffSensor;
    part cliffSensorRearLeft : InfraredCliffSensor;
    part cliffSensorRearRight : InfraredCliffSensor;
    part imu : InertialMeasurementUnit;
    connect cliffSensorFrontLeft.cliffOut to cliffHazardOut;
    connect cliffSensorFrontRight.cliffOut to cliffHazardOut;
    connect cliffSensorRearLeft.cliffOut to cliffHazardOut;
    connect cliffSensorRearRight.cliffOut to cliffHazardOut;
  }

  part def LithiumIonBatteryPack {
    attribute cellConfiguration : String = "4S2P";
    attribute nominalCapacity : ElectricChargeValue = 12500 [mAh];
    attribute nominalVoltage : ElectricPotentialDifferenceValue = 14.4 [V];
    port powerOut;
  }
  part def BatteryManagementSystem {
    doc /* Limits charge current and cell temperature (55 °C maximum) within the safe operating area. */
    attribute maxChargeCurrent : ElectricCurrentValue = 2.0 [A];
    attribute maxCellTemperature : ThermodynamicTemperatureValue = 328.15 [K];
    port batteryTelemetryOut : TelemetryPort;
    port hazardOut : HazardPort;
  }
  part def BuckRegulator {
    attribute outputVoltage : ElectricPotentialDifferenceValue = 5.0 [V];
    port powerIn : PowerLoadPort;
    port powerOut;
  }

  part def PowerModule :> PhysicalAssembly {
    attribute batteryCapacity : ElectricChargeValue = 12500 [mAh];
    attribute lowBatteryThresholdPercent : Real = 15.0;
    attribute reserveCapacity : ElectricChargeValue = 1875 [mAh];
    attribute :>> powerDrawW = 8 [W];
    attribute :>> massKg = 0.72 [kg];
    attribute :>> bomCost = 68 [EUR];
    port mainPowerOut;
    port telemetryOut : TelemetryPort;
    port hazardOut : HazardPort;
    part batteryPack : LithiumIonBatteryPack;
    part bms : BatteryManagementSystem;
    part logicRegulator : BuckRegulator;
    part motorRegulator : BuckRegulator;
    connect batteryPack.powerOut to mainPowerOut;
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

  part def DockInterfaceModule :> PhysicalAssembly {
    attribute dockingBeaconRangeMm : LengthValue = 2500 [mm];
    attribute :>> powerDrawW = 2 [W];
    attribute :>> massKg = 0.38 [kg];
    attribute :>> bomCost = 24 [EUR];
    port powerIn : PowerLoadPort;
    port dockStatusOut;
    part chargingContacts : ChargingContactPair;
    part beaconReceiver : DockBeaconReceiver;
    connect powerIn to chargingContacts.powerIn;
    connect beaconReceiver.statusOut to dockStatusOut;
  }

  part def MicrocontrollerUnit {
    attribute core : String = "Arm Cortex-M33";
    attribute clockFrequency : FrequencyValue = 120000000 [Hz];
    attribute flashCapacity : StorageCapacityValue = 1048576 [B];
    attribute ramCapacity : StorageCapacityValue = 262144 [B];
  }
  part def WirelessModule {
    attribute radios : String = "Wi-Fi 2.4 GHz and Bluetooth LE";
  }
  part def NonVolatileMemory {
    attribute capacity : StorageCapacityValue = 134217728 [B];
  }
  part def MainControlPcb {
    attribute layerCount : Integer = 4;
    part mcu : MicrocontrollerUnit;
    part wireless : WirelessModule;
    part flash : NonVolatileMemory;
    part leftMotorDriver : MotorDriverIC;
    part rightMotorDriver : MotorDriverIC;
  }
  part def ApplicationFirmware {
    doc /*
      Mission orchestration, command arbitration, and app-facing status on the main MCU.
    */
    attribute controlLoopPeriod : DurationValue = 50 [ms];
    exhibit state behavior : RobotOperatingBehavior;
  }
  part def SafetySupervisorFirmware {
    doc /*
      Safety-monitoring firmware task with inputs from sensors, motor drivers, and BMS.
    */
    attribute safeStopReactionTime : DurationValue = 100 [ms];
  }

  part def MainElectronicsAssembly :> PhysicalAssembly {
    doc /*
      Compute LRU: main PCB, motor drivers, and all deployed navigation/perception/control firmware.
    */
    attribute controlLoopPeriod : DurationValue = 50 [ms];
    attribute hazardReactionTime : DurationValue = 100 [ms];
    attribute coverageCellSizeMm : LengthValue = 100 [mm];
    attribute :>> powerDrawW = 9 [W];
    attribute :>> massKg = 0.28 [kg];
    attribute :>> bomCost = 48 [EUR];
    port powerIn : PowerLoadPort;
    port leftMotorDriveOut : MissionCommandPort;
    port rightMotorDriveOut : MissionCommandPort;
    port sensorBusIn;
    port encoderIn : OdometryPort;
    port cleaningCommandOut : MissionCommandPort;
    port telemetryIn : TelemetryPort;
    port dockStatusIn;
    port hazardIn : HazardPort;
    port statusOut;
    port userCommandIn;
    part mainControlPcb : MainControlPcb;
    part applicationFirmware : ApplicationFirmware;
    part safetySupervisor : SafetySupervisorFirmware;
    part mapProcessing : MapProcessingSoftware;
    part localizationEstimator : LocalizationEstimatorSoftware;
    part coveragePlanner : CoveragePlannerSoftware;
    exhibit state behavior : RobotOperatingBehavior;
    connect mainControlPcb.leftMotorDriver.commandIn to leftMotorDriveOut;
    connect mainControlPcb.rightMotorDriver.commandIn to rightMotorDriveOut;
    connect mainControlPcb.leftMotorDriver.faultOut to hazardIn;
    connect mainControlPcb.rightMotorDriver.faultOut to hazardIn;
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

  part def HumanMachineInterface :> PhysicalAssembly {
    attribute supportsLocalOnlyMode : Boolean = true;
    attribute :>> powerDrawW = 1 [W];
    attribute :>> massKg = 0.65 [kg];
    attribute :>> bomCost = 4 [EUR];
    port powerIn : PowerLoadPort;
    port statusIn;
    port userCommandOut;
    part cleanButton : PushButton;
    part homeButton : PushButton;
    part statusLedRing : StatusLedRing;
    part mobileApp : MobileAppInterface;
    connect cleanButton.commandOut to userCommandOut;
    connect homeButton.commandOut to userCommandOut;
    connect mobileApp.commandOut to userCommandOut;
    connect statusIn to statusLedRing.statusIn;
    connect statusIn to mobileApp.statusIn;
  }

  part def ChassisAssembly :> PhysicalAssembly {
    doc /* Structural shell, wheel mounts, and assembly hardware. */
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.55 [kg];
    attribute :>> bomCost = 20 [EUR];
  }

  part def AutonomousFloorCleaningRobot {
    part chassis : ChassisAssembly;
    part driveModule : DriveModule;
    part cleaningHead : CleaningHeadModule;
    part sensorAssembly : SensorAssembly;
    part mainElectronics : MainElectronicsAssembly;
    part powerModule : PowerModule;
    part dockInterface : DockInterfaceModule;
    part hmi : HumanMachineInterface;
    connect powerModule.mainPowerOut to driveModule.powerIn;
    connect powerModule.mainPowerOut to cleaningHead.powerIn;
    connect powerModule.mainPowerOut to sensorAssembly.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.powerIn;
    connect powerModule.mainPowerOut to dockInterface.powerIn;
    connect powerModule.mainPowerOut to hmi.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.mainControlPcb.leftMotorDriver.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.mainControlPcb.rightMotorDriver.powerIn;
    connect mainElectronics.leftMotorDriveOut to driveModule.phaseLeftIn;
    connect mainElectronics.rightMotorDriveOut to driveModule.phaseRightIn;
    connect driveModule.encoderOut to mainElectronics.encoderIn;
    connect sensorAssembly.sensorBusOut to mainElectronics.sensorBusIn;
    connect mainElectronics.cleaningCommandOut to cleaningHead.commandIn;
    connect mainElectronics.statusOut to hmi.statusIn;
    connect hmi.userCommandOut to mainElectronics.userCommandIn;
    connect dockInterface.dockStatusOut to mainElectronics.dockStatusIn;
    connect sensorAssembly.cliffHazardOut to mainElectronics.hazardIn;
    connect driveModule.bumperHazardOut to mainElectronics.hazardIn;
    connect cleaningHead.faultOut to mainElectronics.hazardIn;
    connect powerModule.hazardOut to mainElectronics.hazardIn;
    connect powerModule.telemetryOut to mainElectronics.telemetryIn;
  }
}
