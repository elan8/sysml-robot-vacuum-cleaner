package PhysicalArchitecture {
  private import ArchitectureCommon::*;
  private import PhysicalProtocols::*;
  private import BehaviorStates::*;
  private import SoftwareCore::*;
  private import EmbeddedComputeDomain::*;
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
    doc /*
      Wye-connected BLDC wheel motor: three phase windings driven by an inverter
      on the main PCB
    */
    attribute ratedPower : PowerValue = 14 [W];
    attribute massKg : MassValue = 0.18 [kg];
    port phaseIn : ~ThreePhaseMotorPort;
  }
  part def WheelGearbox {
    attribute reductionRatio : Real = 38.0;
    attribute massKg : MassValue = 0.12 [kg];
  }
  part def WheelEncoder {
    attribute countsPerRevolution : Integer = 384;
    port odometryOut : QuadratureEncoderPort;
  }
  part def MotorDriverIC {
    doc /*
      Three-phase gate driver / inverter: MCU PWM commands, battery switched to U/V/W.
    */
    attribute peakCurrent : ElectricCurrentValue = 3.0 [A];
    port powerIn : PowerRailPort;
    port commandIn : PwmPort;
    port phaseOut : ThreePhaseMotorPort;
    port faultOut : GpioPort;
  }
  part def BumperSwitchArray {
    attribute switchCount : Integer = 6;
    port hazardOut : GpioPort;
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
    port phaseLeftIn : ThreePhaseMotorPort;
    port phaseRightIn : ThreePhaseMotorPort;
    port encoderOut : QuadratureEncoderPort;
    port bumperHazardOut : GpioPort;
    part leftMotor : BrushlessDriveMotor;
    part rightMotor : BrushlessDriveMotor;
    part leftGearbox : WheelGearbox;
    part rightGearbox : WheelGearbox;
    part leftEncoder : WheelEncoder;
    part rightEncoder : WheelEncoder;
    part bumperSwitches : BumperSwitchArray;
    connect leftMotor.phaseIn to phaseLeftIn;
    connect rightMotor.phaseIn to phaseRightIn;
    connect leftEncoder.odometryOut to encoderOut;
    connect rightEncoder.odometryOut to encoderOut;
    connect bumperSwitches.hazardOut to bumperHazardOut;
  }

  part def BrushMotor {
    attribute ratedPower : PowerValue = 8 [W];
    port powerIn : PowerRailPort;
    port commandIn : PwmPort;
    port faultOut : GpioPort;
  }
  part def VacuumFan {
    attribute ratedPower : PowerValue = 6 [W];
    port powerIn : PowerRailPort;
    port commandIn : PwmPort;
  }
  part def DustBin {
    attribute capacity : VolumeValue = 450 [mL];
    attribute toolLessRemoval : Boolean = true;
    port latchStatusOut : MissionStatusPort;
  }
  part def DustLevelSensor {
    attribute sensorType : String = "optical interrupt";
    port statusOut : MissionStatusPort;
  }
  part def DustBinLatchSensor {
    attribute detectsMissingBin : Boolean = true;
    port latchStatusOut : MissionStatusPort;
  }

  part def CleaningHeadModule :> PhysicalAssembly {
    attribute brushPowerW : PowerValue = 12 [W];
    attribute vacuumPowerW : PowerValue = 6 [W];
    attribute dustBinCapacity : VolumeValue = 450 [mL];
    attribute :>> powerDrawW = 18 [W];
    attribute :>> massKg = 0.9 [kg];
    attribute :>> bomCost = 75 [EUR];
    port powerIn : PowerRailPort;
    port mainBrushPwmIn : PwmPort;
    port sideBrushPwmIn : PwmPort;
    port vacuumPwmIn : PwmPort;
    port statusOut : MissionStatusPort;
    port faultOut : GpioPort;
    part mainBrushMotor : BrushMotor;
    part sideBrushMotor : BrushMotor;
    part vacuumFan : VacuumFan;
    part dustBin : DustBin;
    part dustLevelSensor : DustLevelSensor;
    part dustBinLatchSensor : DustBinLatchSensor;
    connect powerIn to mainBrushMotor.powerIn;
    connect powerIn to sideBrushMotor.powerIn;
    connect powerIn to vacuumFan.powerIn;
    connect mainBrushPwmIn to mainBrushMotor.commandIn;
    connect sideBrushPwmIn to sideBrushMotor.commandIn;
    connect vacuumPwmIn to vacuumFan.commandIn;
    connect dustLevelSensor.statusOut to statusOut;
    connect dustBin.latchStatusOut to statusOut;
    connect dustBinLatchSensor.latchStatusOut to statusOut;
    connect mainBrushMotor.faultOut to faultOut;
    connect sideBrushMotor.faultOut to faultOut;
  }

  part def TimeOfFlightRangeSensor {
    attribute rangeMm : LengthValue = 1200 [mm];
    port observationOut : SensorDataPort;
  }
  part def InfraredCliffSensor {
    attribute triggerHeightMm : LengthValue = 50 [mm];
    port cliffOut : GpioPort;
  }
  part def InertialMeasurementUnit {
    attribute axisCount : Integer = 6;
    port poseOut : OdometryPort;
  }
  part def MapProcessingSoftware :> ExecutableComponent {
    attribute gridCellSizeMm : LengthValue = 100 [mm];
  }
  part def CoveragePlannerSoftware :> ExecutableComponent {
    attribute plannerType : String = "boustrophedon with obstacle replanning";
  }
  part def LocalizationEstimatorSoftware :> ExecutableComponent {
    attribute estimatorType : String = "wheel odometry plus IMU plus range observations";
    attribute localizationErrorMm : LengthValue = 120 [mm];
  }

  part def SensorAssembly :> PhysicalAssembly {
    doc /*
      Sensor hardware LRU: ToF, cliff, and IMU on sensor I2C; cliff lines as GPIO hazards.
    */
    attribute obstacleDetectionRangeMm : LengthValue = 1200 [mm];
    attribute cliffDetectionHeightMm : LengthValue = 50 [mm];
    attribute :>> powerDrawW = 5 [W];
    attribute :>> massKg = 0.28 [kg];
    attribute :>> bomCost = 38 [EUR];
    port powerIn : PowerRailPort;
    port sensorBusOut : I2cPort;
    port cliffHazardOut : GpioPort;
    part sensorI2c : SensorI2cBus;
    part frontTofNode : I2cBusSlaveNode;
    part leftWallTofNode : I2cBusSlaveNode;
    part rightWallTofNode : I2cBusSlaveNode;
    part imuNode : I2cBusSlaveNode;
    part frontTofSensor : TimeOfFlightRangeSensor;
    part leftWallTofSensor : TimeOfFlightRangeSensor;
    part rightWallTofSensor : TimeOfFlightRangeSensor;
    part cliffSensorFrontLeft : InfraredCliffSensor;
    part cliffSensorFrontRight : InfraredCliffSensor;
    part cliffSensorRearLeft : InfraredCliffSensor;
    part cliffSensorRearRight : InfraredCliffSensor;
    part imu : InertialMeasurementUnit;
    connect sensorBusOut to sensorI2c.hostBackplane;
    connect frontTofNode.busPort to sensorI2c.frontTof;
    connect leftWallTofNode.busPort to sensorI2c.leftWallTof;
    connect rightWallTofNode.busPort to sensorI2c.rightWallTof;
    connect imuNode.busPort to sensorI2c.imu;
    connect cliffSensorFrontLeft.cliffOut to cliffHazardOut;
    connect cliffSensorFrontRight.cliffOut to cliffHazardOut;
    connect cliffSensorRearLeft.cliffOut to cliffHazardOut;
    connect cliffSensorRearRight.cliffOut to cliffHazardOut;
  }

  part def LithiumIonBatteryPack {
    attribute cellConfiguration : String = "4S2P";
    attribute nominalCapacity : ElectricChargeValue = 12500 [mAh];
    attribute nominalVoltage : ElectricPotentialDifferenceValue = 14.4 [V];
    port packOut : PowerRailPort;
  }
  part def BatteryManagementSystem {
    doc /* Limits charge current and cell temperature (55 °C maximum) within the safe operating area. */
    attribute maxChargeCurrent : ElectricCurrentValue = 2.0 [A];
    attribute maxCellTemperature : ThermodynamicTemperatureValue = 328.15 [K];
    port smbusPort : ~I2cPort;
    port hazardOut : GpioPort;
  }
  part def BuckRegulator {
    attribute outputVoltage : ElectricPotentialDifferenceValue = 5.0 [V];
    port powerIn : PowerRailPort;
    port powerOut : PowerRailPort;
  }

  part def PowerModule :> PhysicalAssembly {
    attribute batteryCapacity : ElectricChargeValue = 12500 [mAh];
    attribute lowBatteryThresholdPercent : Real = 15.0;
    attribute reserveCapacity : ElectricChargeValue = 1875 [mAh];
    attribute :>> powerDrawW = 8 [W];
    attribute :>> massKg = 0.72 [kg];
    attribute :>> bomCost = 68 [EUR];
    port mainPowerOut : PowerRailPort;
    port bmsBusOut : I2cPort;
    port telemetryOut : TelemetryPort;
    port hazardOut : GpioPort;
    part batteryPack : LithiumIonBatteryPack;
    part bms : BatteryManagementSystem;
    part bmsSmbus : BmsSmbusBus;
    part logicRegulator : BuckRegulator;
    part motorRegulator : BuckRegulator;
    connect batteryPack.packOut to mainPowerOut;
    connect batteryPack.packOut to logicRegulator.powerIn;
    connect batteryPack.packOut to motorRegulator.powerIn;
    connect logicRegulator.powerOut to mainPowerOut;
    connect motorRegulator.powerOut to mainPowerOut;
    connect bmsBusOut to bmsSmbus.hostBackplane;
    connect bms.smbusPort to bmsSmbus.bms;
    connect bms.hazardOut to hazardOut;
  }

  part def ChargingContactPair {
    attribute contactMaterial : String = "spring loaded plated copper";
    port powerIn : PowerRailPort;
  }
  part def DockBeaconReceiver {
    attribute receiverType : String = "infrared homing receiver";
    port statusOut : GpioPort;
  }

  part def DockInterfaceModule :> PhysicalAssembly {
    attribute dockingBeaconRangeMm : LengthValue = 2500 [mm];
    attribute :>> powerDrawW = 2 [W];
    attribute :>> massKg = 0.38 [kg];
    attribute :>> bomCost = 24 [EUR];
    port powerIn : PowerRailPort;
    port dockStatusOut : GpioPort;
    part chargingContacts : ChargingContactPair;
    part beaconReceiver : DockBeaconReceiver;
    connect powerIn to chargingContacts.powerIn;
    connect beaconReceiver.statusOut to dockStatusOut;
  }

  part def MicrocontrollerUnit :> Microcontroller {
    attribute core : String = "Arm Cortex-M33";
    attribute clockFrequency : FrequencyValue = 120000000 [Hz];
    attribute flashCapacity : StorageCapacityValue = 1048576 [B];
    attribute ramCapacity : StorageCapacityValue = 262144 [B];
  }
  part def NonVolatileMemory {
    attribute capacity : StorageCapacityValue = 134217728 [B];
  }
  part def MainControlPcb {
    doc /*
      Main PCB: MCU execution node, motor inverters, wireless link, and external flash.
      Software deployment to mcu uses allocate (ArchitectureAllocations); peripheral I/O uses connect.
    */
    attribute layerCount : Integer = 4;
    port leftMotorPhaseOut : ThreePhaseMotorPort;
    port rightMotorPhaseOut : ThreePhaseMotorPort;
    port sensorBusHarness : I2cPort;
    port bmsBusHarness : I2cPort;
    port mcuUartOut : UartPort;
    part mcu : MicrocontrollerUnit {
      port sensorI2c : I2cPort;
      port bmsI2c : I2cPort;
      port leftMotorPwm : PwmPort;
      port rightMotorPwm : PwmPort;
    }
    part mcuI2cMaster : I2cBusMasterNode;
    part wirelessModule : RobotWirelessModule;
    part flashSpi : FlashSpiBus;
    part flashNode : SpiBusSlaveNode;
    part flash : NonVolatileMemory;
    part leftMotorDriver : MotorDriverIC;
    part rightMotorDriver : MotorDriverIC;
    part liftSensorInput {
      port hazardOut : GpioPort;
    }
    part boardThermalSensor {
      attribute overTemperatureThresholdK = 343.15;
      port hazardOut : GpioPort;
    }
    part wirelessUart : McuWirelessUart;
    connect mcu.sensorI2c to mcuI2cMaster.busPort;
    connect sensorBusHarness to mcuI2cMaster.busPort;
    connect bmsBusHarness to mcu.bmsI2c;
    connect mcu.leftMotorPwm to leftMotorDriver.commandIn;
    connect mcu.rightMotorPwm to rightMotorDriver.commandIn;
    connect leftMotorDriver.phaseOut to leftMotorPhaseOut;
    connect rightMotorDriver.phaseOut to rightMotorPhaseOut;
    connect flashNode.busPort to flashSpi.flash;
    connect mcuUartOut to wirelessUart.mcu;
    connect wirelessModule.hostLink to wirelessUart.wirelessModule;
  }
  part def ApplicationFirmware :> ExecutableComponent {
    doc /*
      Mission orchestration, command arbitration, and app-facing status on the main MCU.
    */
    attribute controlLoopPeriod : DurationValue = 50 [ms];
    exhibit state behavior : RobotOperatingBehavior;
  }
  part def SafetySupervisorFirmware :> ExecutableComponent {
    doc /*
      Safety-monitoring firmware task with inputs from sensors, motor drivers, and BMS.
    */
    attribute safeStopReactionTime : DurationValue = 100 [ms];
  }

  part def RobotFirmwareSuite {
    doc /* Deployable firmware modules on the main MCU (see ArchitectureAllocations). */
    part applicationFirmware : ApplicationFirmware;
    part safetySupervisor : SafetySupervisorFirmware;
    part mapProcessing : MapProcessingSoftware;
    part localizationEstimator : LocalizationEstimatorSoftware;
    part coveragePlanner : CoveragePlannerSoftware;
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
    port powerIn : PowerRailPort;
    port leftMotorPhaseOut : ThreePhaseMotorPort;
    port rightMotorPhaseOut : ThreePhaseMotorPort;
    port mainBrushPwmOut : PwmPort;
    port sideBrushPwmOut : PwmPort;
    port vacuumPwmOut : PwmPort;
    port sensorBusIn : I2cPort;
    port bmsBusIn : I2cPort;
    port encoderIn : QuadratureEncoderPort;
    port telemetryIn : TelemetryPort;
    port dockStatusIn : GpioPort;
    port hazardIn : GpioPort;
    port statusOut : MissionStatusPort;
    port userCommandIn : GpioPort;
    part mainControlPcb : MainControlPcb;
    part robotFirmware : RobotFirmwareSuite;
    connect sensorBusIn to mainControlPcb.sensorBusHarness;
    connect bmsBusIn to mainControlPcb.bmsBusHarness;
    connect mainControlPcb.leftMotorPhaseOut to leftMotorPhaseOut;
    connect mainControlPcb.rightMotorPhaseOut to rightMotorPhaseOut;
    connect mainControlPcb.leftMotorDriver.faultOut to hazardIn;
    connect mainControlPcb.rightMotorDriver.faultOut to hazardIn;
    connect mainControlPcb.liftSensorInput.hazardOut to hazardIn;
    connect mainControlPcb.boardThermalSensor.hazardOut to hazardIn;
  }

  part def PushButton {
    port commandOut : GpioPort;
  }
  part def StatusLedRing {
    port statusIn : GpioPort;
  }
  part def MobileAppInterface {
    attribute cloudBackupDefaultEnabled : Boolean = false;
    ref bleChannel : BleCommunicationChannel;
  }

  part def HumanMachineInterface :> PhysicalAssembly {
    attribute supportsLocalOnlyMode : Boolean = true;
    attribute :>> powerDrawW = 1 [W];
    attribute :>> massKg = 0.65 [kg];
    attribute :>> bomCost = 4 [EUR];
    port powerIn : PowerRailPort;
    port statusIn : MissionStatusPort;
    port userCommandOut : GpioPort;
    part cleanButton : PushButton;
    part homeButton : PushButton;
    part statusLedRing : StatusLedRing;
    part mobileApp : MobileAppInterface;
    connect cleanButton.commandOut to userCommandOut;
    connect homeButton.commandOut to userCommandOut;
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
    connect powerModule.mainPowerOut to cleaningHead.powerIn;
    connect powerModule.mainPowerOut to sensorAssembly.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.powerIn;
    connect powerModule.mainPowerOut to dockInterface.powerIn;
    connect powerModule.mainPowerOut to hmi.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.mainControlPcb.leftMotorDriver.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.mainControlPcb.rightMotorDriver.powerIn;
    connect mainElectronics.leftMotorPhaseOut to driveModule.phaseLeftIn;
    connect mainElectronics.rightMotorPhaseOut to driveModule.phaseRightIn;
    connect driveModule.encoderOut to mainElectronics.encoderIn;
    connect sensorAssembly.sensorBusOut to mainElectronics.sensorBusIn;
    connect powerModule.bmsBusOut to mainElectronics.bmsBusIn;
    connect powerModule.telemetryOut to mainElectronics.telemetryIn;
    connect mainElectronics.mainBrushPwmOut to cleaningHead.mainBrushPwmIn;
    connect mainElectronics.sideBrushPwmOut to cleaningHead.sideBrushPwmIn;
    connect mainElectronics.vacuumPwmOut to cleaningHead.vacuumPwmIn;
    connect mainElectronics.statusOut to hmi.statusIn;
    connect hmi.userCommandOut to mainElectronics.userCommandIn;
    connect dockInterface.dockStatusOut to mainElectronics.dockStatusIn;
    connect sensorAssembly.cliffHazardOut to mainElectronics.hazardIn;
    connect driveModule.bumperHazardOut to mainElectronics.hazardIn;
    connect cleaningHead.faultOut to mainElectronics.hazardIn;
    connect powerModule.hazardOut to mainElectronics.hazardIn;
  }
}
