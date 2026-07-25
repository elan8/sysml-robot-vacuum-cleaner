/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns product assemblies, physical ports, firmware suite parts, physical
 * connections, and mass/BOM/power roll-ups. Depends on shared items, physical
 * protocols, behavior, software, compute, and unit libraries. Keep PCB metadata,
 * software contracts, and allocation links in their dedicated packages. Harness
 * connector ICD notes live in doc on the corresponding ports.
 */
package PhysicalArchitecture {
  private import ArchitectureCommon::*;
  private import PhysicalProtocols::*;
  private import BehaviorStates::*;
  private import FirmwareArchitecture::*;
  private import ArchitectureAllocations::*;
  private import ElectronicsInterfaceControl::*;
  private import Elan8Methodology::*;
  private import SoftwareCore::*;
  private import EmbeddedComputeDomain::*;
  private import MonetaryUnits::*;
  private import VacuumCleanerQuantitiesAndUnits::*;
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

  // Drive module and wheel-actuation hardware.
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
    port leftEncoderOut : QuadratureEncoderPort {
      doc /* Left wheel quadrature channel; independent line to the motion controller. */
    }
    port rightEncoderOut : QuadratureEncoderPort {
      doc /* Right wheel quadrature channel; independent line to the motion controller. */
    }
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
    connect leftEncoder.odometryOut to leftEncoderOut;
    connect rightEncoder.odometryOut to rightEncoderOut;
    connect bumperSwitches.hazardOut to bumperHazardOut;
  }

  // Cleaning head hardware and dust-bin sensing.
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

  // Sensor hardware and navigation/perception software elements.
  part def TimeOfFlightRangeSensor :> I2cBusSlaveNode {
    attribute rangeMm : LengthValue = 1200 [mm];
    port observationOut : SensorDataPort;
  }
  part def InfraredCliffSensor {
    attribute triggerHeightMm : LengthValue = 50 [mm];
    port cliffOut : GpioPort;
  }
  part def InertialMeasurementUnit :> I2cBusSlaveNode {
    attribute axisCount : Integer = 6;
    port poseOut : OdometryPort;
  }
  part def TwoDimensionalLidarModule {
    attribute scanRateHz : FrequencyValue = 10 [Hz];
    attribute rangeMm : LengthValue = 6000 [mm];
    attribute angularResolutionDeg : Real = 1.0;
    attribute interfaceType : String = "3.3 V UART, 5 V sensor power";
    attribute powerDrawW : PowerValue = 2 [W];
    port scanOut : UartPort;
  }
  part def VisionObstacleModule {
    attribute cameraCount : Integer = 2;
    attribute fieldOfViewDeg : Real = 136.0;
    attribute selectedForBaseline : Boolean = false;
    port visionDataOut : UartPort;
  }
  part def AiInferenceAccelerator {
    attribute localInferenceOnly : Boolean = true;
    attribute selectedForBaseline : Boolean = false;
    port hostLink : SpiPort;
  }
  part def MapProcessingSoftware :> ExecutableComponent {
    attribute gridCellSizeMm : LengthValue = 100 [mm];
  }
  part def CoveragePlannerSoftware :> ExecutableComponent {
    attribute plannerType : String = "boustrophedon with obstacle replanning";
  }
  part def LocalizationEstimatorSoftware :> ExecutableComponent {
    attribute estimatorType : String = "wheel odometry plus IMU plus 2D LiDAR scan matching plus ToF observations";
    attribute localizationErrorMm : LengthValue = 95 [mm];
  }

  part def SensorAssembly :> PhysicalAssembly {
    doc /*
      Sensor hardware LRU: 2D LiDAR/dToF, ToF, cliff, and IMU.
      ToF and IMU are on sensor I2C; LiDAR uses a serial link; cliff lines are GPIO hazards.
    */
    attribute obstacleDetectionRangeMm : LengthValue = 1200 [mm];
    attribute lidarMappingRangeMm : LengthValue = 6000 [mm];
    attribute cliffDetectionHeightMm : LengthValue = 50 [mm];
    attribute :>> powerDrawW = 7 [W];
    attribute :>> massKg = 0.34 [kg];
    attribute :>> bomCost = 58 [EUR];
    port powerIn : PowerRailPort {
      doc /*
        Sensor LRU power from main battery rail via harness J_SENSOR_PWR segment;
        shares return with sensor bus ground at the keyed connector.
      */
    }
    port sensorBusOut : I2cPort {
      doc /*
        Sensor harness mate to main PCB J_SENSOR_I2C (6-pin JST-GH).
        3.3 V logic at 400 kHz; SDA/SCL open-drain with 3.3 V pull-ups.
        Addresses: front ToF 0x29, left ToF 0x2A, right ToF 0x2B, IMU 0x68.
      */
    }
    port lidarSerialOut : UartPort {
      doc /*
        LiDAR harness mate to main PCB J_LIDAR (6-pin JST-GH).
        5 V sensor power, 3.3 V UART at 1 Mbps target; MCU TX/RX cross to module.
        Signals: MCU_LIDAR_TX, LIDAR_MCU_RX, LIDAR_5V (sensor power below 500 mA).
      */
    }
    port cliffHazardOut : GpioPort {
      doc /*
        Cliff sensor hazard lines; fail-safe active-low where supported.
        Routed to mainElectronics.cliffHazardIn at the robot integration boundary.
      */
    }
    part sensorI2c : SensorI2cBus;
    part lidarSerial : LidarSerialBus;
    part frontTofSensor : TimeOfFlightRangeSensor;
    part leftWallTofSensor : TimeOfFlightRangeSensor;
    part rightWallTofSensor : TimeOfFlightRangeSensor;
    part cliffSensorFrontLeft : InfraredCliffSensor;
    part cliffSensorFrontRight : InfraredCliffSensor;
    part cliffSensorRearLeft : InfraredCliffSensor;
    part cliffSensorRearRight : InfraredCliffSensor;
    part imu : InertialMeasurementUnit;
    part lidar : TwoDimensionalLidarModule;
    connect sensorBusOut to sensorI2c.hostBackplane;
    connect lidarSerialOut to lidarSerial.mcu;
    connect lidar.scanOut to lidarSerial.lidarModule;
    connect frontTofSensor.busPort to sensorI2c.frontTof;
    connect leftWallTofSensor.busPort to sensorI2c.leftWallTof;
    connect rightWallTofSensor.busPort to sensorI2c.rightWallTof;
    connect imu.busPort to sensorI2c.imu;
    connect cliffSensorFrontLeft.cliffOut to cliffHazardOut;
    connect cliffSensorFrontRight.cliffOut to cliffHazardOut;
    connect cliffSensorRearLeft.cliffOut to cliffHazardOut;
    connect cliffSensorRearRight.cliffOut to cliffHazardOut;
  }

  // Battery, regulation, charging, and docking hardware.
  part def LithiumIonBatteryPack {
    attribute cellConfiguration : String = "4S2P";
    attribute nominalCapacity : ElectricChargeValue = 12500 [mAh];
    attribute nominalVoltage : ElectricPotentialDifferenceValue = 14.4 [V];
    port packOut : PowerRailPort;
  }
  part def BatteryManagementSystem {
    doc /* Limits charge current and cell temperature (55 degC maximum) within the safe operating area. */
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
    port mainPowerOut : PowerRailPort {
      doc /*
        Battery and dock power entry (J_POWER, 6-pin).
        Rails: 14.4 V battery, switched motor rail, 5 V regulated, 3.3 V logic, charger input.
        Separate high-current motor return from logic return until star point.
      */
    }
    port bmsBusOut : I2cPort {
      doc /*
        BMS harness mate to main PCB J_BMS (5-pin board-to-wire).
        SMBus at 100 kHz, 3.3 V logic plus pack reference; BMS address 0x16.
        SMBus SDA/SCL, alert/fault GPIO, pack reference, ground.
      */
    }
    port telemetryOut : TelemetryPort;
    port hazardOut : GpioPort {
      doc /*
        BMS fault/alert output; active-low alert convention where supported.
      */
    }
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

  part def PowerRailBudget {
    attribute nominalVoltage : ElectricPotentialValue;
    attribute continuousCurrentBudget : ElectricCurrentValue;
    attribute peakCurrentBudget : ElectricCurrentValue;
  }

  // Main electronics, MCU peripherals, and deployable firmware suite.
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
    port leftMotorPhaseOut : ThreePhaseMotorPort {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-J_MOTOR_PHASE-L";
        interfaceKind = ElectricalInterfaceKind::threePhaseMotor;
        signalDirection = SignalDirection::sourceToLoad;
        nominalVoltage = 14.4 [V];
        maxCurrent = 3.0 [A];
        criticality = ConnectorCriticality::safetyCritical;
      }
      doc /*
        Left wheel motor phase harness (U/V/W) from onboard inverter;
        part of J_MOTOR_PWM motor/actuator net group (20 kHz PWM target).
      */
    }
    port rightMotorPhaseOut : ThreePhaseMotorPort {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-J_MOTOR_PHASE-R";
        interfaceKind = ElectricalInterfaceKind::threePhaseMotor;
        signalDirection = SignalDirection::sourceToLoad;
        nominalVoltage = 14.4 [V];
        maxCurrent = 3.0 [A];
        criticality = ConnectorCriticality::safetyCritical;
      }
      doc /*
        Right wheel motor phase harness (U/V/W) from onboard inverter;
        part of J_MOTOR_PWM motor/actuator net group (20 kHz PWM target).
      */
    }
    port sensorBusHarness : I2cPort {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-J_SENSOR_I2C";
        interfaceKind = ElectricalInterfaceKind::i2cBus;
        signalDirection = SignalDirection::bidirectional;
        nominalVoltage = 3.3 [V];
        maxCurrent = 0.3 [A];
        criticality = ConnectorCriticality::missionCritical;
      }
      doc /*
        J_SENSOR_I2C, 6-pin JST-GH, 3.3 V logic at 400 kHz.
        SDA (SENSOR_I2C_SDA, open-drain bidirectional), SCL (SENSOR_I2C_SCL, open-drain clock),
        sensor power, ground, keyed harness.
        Addresses: front ToF 0x29, left ToF 0x2A, right ToF 0x2B, IMU 0x68.
      */
    }
    port lidarUartHarness : UartPort {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-J_LIDAR";
        interfaceKind = ElectricalInterfaceKind::uartBus;
        signalDirection = SignalDirection::bidirectional;
        nominalVoltage = 5.0 [V];
        maxCurrent = 0.5 [A];
        criticality = ConnectorCriticality::missionCritical;
      }
      doc /*
        J_LIDAR, 6-pin JST-GH; 5 V sensor power plus 3.3 V logic at 1 Mbps UART target (UART2_LIDAR).
        MCU_LIDAR_TX to LiDAR RX, LIDAR_MCU_RX from LiDAR TX; idle-high UART.
        LIDAR_5V positive supply; optional motor-sync or health GPIO.
      */
    }
    port bmsBusHarness : I2cPort {
      doc /*
        J_BMS, 5-pin board-to-wire; SMBus at 100 kHz, BMS address 0x16.
        3.3 V logic plus pack reference; SDA/SCL, alert/fault GPIO, ground.
      */
    }
    port mcuUartOut : UartPort {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-UART_APP";
        interfaceKind = ElectricalInterfaceKind::uartBus;
        signalDirection = SignalDirection::bidirectional;
        nominalVoltage = 3.3 [V];
        maxCurrent = 0.15 [A];
        criticality = ConnectorCriticality::serviceable;
      }
      doc /*
        U_WIFI_BLE wireless module (soldered castellated pads, 6-pin, 3.3 V logic, 1 Mbps UART1).
        MCU TX/RX cross to wireless RX/TX; optional wake/reset GPIO.
      */
    }
    part mcu : MicrocontrollerUnit {
      port sensorI2c : I2cPort;
      port lidarUart : UartPort;
      port bmsI2c : I2cPort;
      port leftMotorPwm : PwmPort;
      port rightMotorPwm : PwmPort;
    }
    part mcuI2cMaster : I2cBusMasterNode;
    part wirelessModule : RobotWirelessModule;
    part flashSpi : FlashSpiBus {
      doc /*
        U_FLASH on-board SOIC/QSPI footprint (8-pin); SPI mode 0 at 24 MHz, 3.3 V logic.
        CS (FLASH_CS0), SCK, MISO, MOSI; WP/HOLD pulled inactive.
      */
    }
    part flashNode : SpiBusSlaveNode;
    part flash : NonVolatileMemory {
      @ImplementationHandoff {
        artifactId = "EWP-WIRELESS-STORAGE";
        readiness = ImplementationReadinessKind::readyForSchematic;
        domain = ImplementationDomainKind::wireless;
      }
    }
    part leftMotorDriver : MotorDriverIC {
      @ImplementationHandoff {
        artifactId = "EWP-MOTOR-DRIVE-L";
        readiness = ImplementationReadinessKind::needsComponentSelection;
        domain = ImplementationDomainKind::motorDrive;
      }
    }
    part rightMotorDriver : MotorDriverIC {
      @ImplementationHandoff {
        artifactId = "EWP-MOTOR-DRIVE-R";
        readiness = ImplementationReadinessKind::needsComponentSelection;
        domain = ImplementationDomainKind::motorDrive;
      }
    }
    part liftSensorInput {
      port hazardOut : GpioPort;
    }
    part boardThermalSensor {
      attribute overTemperatureThresholdK = 343.15;
      port hazardOut : GpioPort;
    }
    part wirelessUart : McuWirelessUart {
      @ImplementationHandoff {
        artifactId = "EWP-WIRELESS-STORAGE";
        readiness = ImplementationReadinessKind::readyForSchematic;
        domain = ImplementationDomainKind::wireless;
      }
    }
    connect mcu.sensorI2c to mcuI2cMaster.busPort;
    connect sensorBusHarness to mcuI2cMaster.busPort;
    connect lidarUartHarness to mcu.lidarUart;
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

  part def SafetyGpioHarness {
    doc /*
      J_SAFETY passive wire bundle: each port is an independent fault line routed
      to the safety supervisor GPIO block. Fail-safe active-low where supported.
    */
    port cliffIn : GpioPort;
    port bumperIn : GpioPort;
    port cleaningFaultIn : GpioPort;
    port bmsAlertIn : GpioPort;
    port motorFaultLeftIn : GpioPort;
    port motorFaultRightIn : GpioPort;
    port liftIn : GpioPort;
    port thermalIn : GpioPort;
    port toSupervisor : GpioPort;
  }

  part def MainElectronicsAssembly :> PhysicalAssembly {
    doc /*
      Compute LRU: main PCB, motor-driver section, safety GPIO harness, and
      external harness ports. Deployable firmware and task architecture live at
      the robot level and allocate to mainControlPcb.mcu.
    */
    attribute controlLoopPeriod : DurationValue = 50 [ms];
    attribute hazardReactionTime : DurationValue = 100 [ms];
    attribute coverageCellSizeMm : LengthValue = 100 [mm];
    attribute :>> powerDrawW = 9 [W];
    attribute :>> massKg = 0.28 [kg];
    attribute :>> bomCost = 48 [EUR];
    port powerIn : PowerRailPort {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-J_POWER";
        interfaceKind = ElectricalInterfaceKind::powerRail;
        signalDirection = SignalDirection::sourceToLoad;
        nominalVoltage = 14.4 [V];
        maxCurrent = 6.0 [A];
        criticality = ConnectorCriticality::safetyCritical;
      }
      doc /*
        Main electronics power from battery module (J_POWER segment).
        14.4 V battery, 5 V regulated, 3.3 V logic; charger input on dock path.
      */
    }
    port leftMotorPhaseOut : ThreePhaseMotorPort {
      doc /* Left drive motor harness to drive module; 14.4 V switched motor rail. */
    }
    port rightMotorPhaseOut : ThreePhaseMotorPort {
      doc /* Right drive motor harness to drive module; 14.4 V switched motor rail. */
    }
    port mainBrushPwmOut : PwmPort {
      doc /*
        Main brush PWM harness (J_MOTOR_PWM group); 3.3 V control, 20 kHz PWM target.
        Fault GPIO returns to safety supervisor via hazardIn.
      */
    }
    port sideBrushPwmOut : PwmPort {
      doc /* Side brush PWM harness (J_MOTOR_PWM group); 3.3 V control, 20 kHz PWM target. */
    }
    port vacuumPwmOut : PwmPort {
      doc /* Vacuum fan PWM harness (J_MOTOR_PWM group); 3.3 V control, 20 kHz PWM target. */
    }
    port sensorBusIn : I2cPort {
      doc /* Sensor assembly harness; see mainControlPcb.sensorBusHarness for J_SENSOR_I2C ICD. */
    }
    port lidarSerialIn : UartPort {
      doc /* Sensor assembly LiDAR harness; see mainControlPcb.lidarUartHarness for J_LIDAR ICD. */
    }
    port bmsBusIn : I2cPort {
      doc /* Power module BMS harness; see mainControlPcb.bmsBusHarness for J_BMS ICD. */
    }
    port leftEncoderIn : QuadratureEncoderPort {
      doc /* Left wheel quadrature channel from the drive module. */
    }
    port rightEncoderIn : QuadratureEncoderPort {
      doc /* Right wheel quadrature channel from the drive module. */
    }
    port telemetryIn : ~TelemetryPort;
    port dockStatusIn : GpioPort;
    port hazardIn : GpioPort {
      doc /*
        Safety supervisor GPIO input block; fed by safetyGpioHarness.toSupervisor.
        Sampled at 10 ms safety period.
      */
    }
    port cliffHazardIn : GpioPort {
      doc /* Cliff sensor hazard lines from sensor assembly; routed to safety GPIO harness. */
    }
    port bumperHazardIn : GpioPort {
      doc /* Bumper hazard line from drive module; routed to safety GPIO harness. */
    }
    port cleaningFaultIn : GpioPort {
      doc /* Cleaning-head fault line; routed to safety GPIO harness. */
    }
    port bmsAlertIn : GpioPort {
      doc /* BMS alert line from power module; routed to safety GPIO harness. */
    }
    port statusOut : MissionStatusPort;
    port userCommandIn : GpioPort;
    part mainControlPcb : MainControlPcb {
      @ImplementationHandoff {
        artifactId = "EWP-MAIN-PCB";
        readiness = ImplementationReadinessKind::readyForSchematic;
        domain = ImplementationDomainKind::compute;
      }
    }
    part safetyGpioHarness : SafetyGpioHarness {
      @ElectricalInterfaceInfo {
        connectorId = "EIC-J_SAFETY_GPIO";
        interfaceKind = ElectricalInterfaceKind::gpioFaultLine;
        signalDirection = SignalDirection::activeLowFaultToMcu;
        nominalVoltage = 3.3 [V];
        maxCurrent = 0.02 [A];
        criticality = ConnectorCriticality::safetyCritical;
      }
    }
    connect powerIn to mainControlPcb.leftMotorDriver.powerIn;
    connect powerIn to mainControlPcb.rightMotorDriver.powerIn;
    connect sensorBusIn to mainControlPcb.sensorBusHarness;
    connect lidarSerialIn to mainControlPcb.lidarUartHarness;
    connect bmsBusIn to mainControlPcb.bmsBusHarness;
    connect mainControlPcb.leftMotorPhaseOut to leftMotorPhaseOut;
    connect mainControlPcb.rightMotorPhaseOut to rightMotorPhaseOut;
    connect cliffHazardIn to safetyGpioHarness.cliffIn;
    connect bumperHazardIn to safetyGpioHarness.bumperIn;
    connect cleaningFaultIn to safetyGpioHarness.cleaningFaultIn;
    connect bmsAlertIn to safetyGpioHarness.bmsAlertIn;
    connect mainControlPcb.leftMotorDriver.faultOut to safetyGpioHarness.motorFaultLeftIn;
    connect mainControlPcb.rightMotorDriver.faultOut to safetyGpioHarness.motorFaultRightIn;
    connect mainControlPcb.liftSensorInput.hazardOut to safetyGpioHarness.liftIn;
    connect mainControlPcb.boardThermalSensor.hazardOut to safetyGpioHarness.thermalIn;
    connect safetyGpioHarness.toSupervisor to hazardIn;
  }

  // Human-machine interface and app interaction boundary.
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

  // Top-level robot assembly and physical interconnections.
  part def ChassisAssembly :> PhysicalAssembly {
    doc /* Structural shell, wheel mounts, and assembly hardware. */
    attribute :>> powerDrawW = 0 [W];
    attribute :>> massKg = 0.48 [kg];
    attribute :>> bomCost = 20 [EUR];
  }

  part def AutonomousFloorCleaningRobot {
    part chassis : ChassisAssembly;
    part driveModule : DriveModule;
    part cleaningHead : CleaningHeadModule;
    part sensorAssembly : SensorAssembly {
      @ImplementationHandoff {
        artifactId = "EWP-SENSOR-HARNESS";
        readiness = ImplementationReadinessKind::needsLayoutDetail;
        domain = ImplementationDomainKind::sensing;
      }
    }
    part mainElectronics : MainElectronicsAssembly;
    part powerModule : PowerModule {
      @ImplementationHandoff {
        artifactId = "EWP-POWER-CHARGE";
        readiness = ImplementationReadinessKind::needsSafetyReview;
        domain = ImplementationDomainKind::charging;
      }
    }
    part dockInterface : DockInterfaceModule;
    part hmi : HumanMachineInterface;
    part robotFirmware : RobotFirmwareSuite;
    part firmwareTasks : FirmwareTaskArchitecture;

    part batteryRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> continuousCurrentBudget = 5.0 [A];
      attribute :>> peakCurrentBudget = 8.0 [A];
      ref source = powerModule.batteryPack.packOut;
      ref mainElectronicsLoad = mainElectronics.powerIn;
      ref cleaningLoad = cleaningHead.powerIn;
      ref dockingLoad = dockInterface.powerIn;
      doc /*
        BAT_14V4 budget. Protect with battery fuse, reverse-polarity protection,
        charger-current limiting, and motor-rail current monitoring. Measure at
        the J_POWER BAT_14V4 test point.
      */
    }
    part logicRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> continuousCurrentBudget = 1.0 [A];
      attribute :>> peakCurrentBudget = 1.5 [A];
      ref source = powerModule.logicRegulator.powerOut;
      ref computeLoad = mainElectronics.mainControlPcb.mcu;
      ref sensorBusLoad = mainElectronics.mainControlPcb.sensorBusHarness;
      ref wirelessLoad = mainElectronics.mainControlPcb.wirelessModule;
      ref storageLoad = mainElectronics.mainControlPcb.flash;
      doc /*
        LOGIC_3V3 budget. Use regulator current limiting, local decoupling, and
        ESD protection on service/external lines. Measure near the MCU.
      */
    }
    part sensorRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 5.0 [V];
      attribute :>> continuousCurrentBudget = 0.8 [A];
      attribute :>> peakCurrentBudget = 1.2 [A];
      ref source = powerModule.logicRegulator.powerOut;
      ref lidarLoad = sensorAssembly.lidar;
      ref sensorHarnessLoad = sensorAssembly.sensorBusOut;
      doc /*
        SENSOR_5V budget. Use load-switch or polyfuse protection and LiDAR
        inrush control. Measure near J_SENSOR_I2C and J_LIDAR.
      */
    }

    connect powerModule.mainPowerOut to cleaningHead.powerIn;
    connect powerModule.mainPowerOut to sensorAssembly.powerIn;
    connect powerModule.mainPowerOut to mainElectronics.powerIn;
    connect powerModule.mainPowerOut to dockInterface.powerIn;
    connect powerModule.mainPowerOut to hmi.powerIn;
    connect mainElectronics.leftMotorPhaseOut to driveModule.phaseLeftIn;
    connect mainElectronics.rightMotorPhaseOut to driveModule.phaseRightIn;
    connect driveModule.leftEncoderOut to mainElectronics.leftEncoderIn;
    connect driveModule.rightEncoderOut to mainElectronics.rightEncoderIn;
    connect sensorAssembly.sensorBusOut to mainElectronics.sensorBusIn;
    connect sensorAssembly.lidarSerialOut to mainElectronics.lidarSerialIn;
    connect powerModule.bmsBusOut to mainElectronics.bmsBusIn;
    connect powerModule.telemetryOut to mainElectronics.telemetryIn;
    connect mainElectronics.mainBrushPwmOut to cleaningHead.mainBrushPwmIn;
    connect mainElectronics.sideBrushPwmOut to cleaningHead.sideBrushPwmIn;
    connect mainElectronics.vacuumPwmOut to cleaningHead.vacuumPwmIn;
    connect mainElectronics.statusOut to hmi.statusIn;
    connect hmi.userCommandOut to mainElectronics.userCommandIn;
    connect dockInterface.dockStatusOut to mainElectronics.dockStatusIn;
    connect sensorAssembly.cliffHazardOut to mainElectronics.cliffHazardIn;
    connect driveModule.bumperHazardOut to mainElectronics.bumperHazardIn;
    connect cleaningHead.faultOut to mainElectronics.cleaningFaultIn;
    connect powerModule.hazardOut to mainElectronics.bmsAlertIn;

    // Firmware task ownership by deployable software module.
    allocate firmwareTasks.missionController to robotFirmware.applicationFirmware;
    allocate firmwareTasks.motorControl to robotFirmware.applicationFirmware;
    allocate firmwareTasks.cleaningControl to robotFirmware.applicationFirmware;
    allocate firmwareTasks.appProtocol to robotFirmware.applicationFirmware;
    allocate firmwareTasks.diagnostics to robotFirmware.applicationFirmware;
    allocate firmwareTasks.storage to robotFirmware.applicationFirmware;
    allocate firmwareTasks.safetySupervisor to robotFirmware.safetySupervisor;
    allocate firmwareTasks.batteryManager to robotFirmware.safetySupervisor;
    allocate firmwareTasks.sensorAcquisition to robotFirmware.mapProcessing;
    allocate firmwareTasks.slam to robotFirmware.mapProcessing;
    allocate firmwareTasks.localization to robotFirmware.localizationEstimator;
    allocate firmwareTasks.coveragePlanner to robotFirmware.coveragePlanner;

    // Deployable software modules on the MCU execution node.
    allocate robotFirmware.applicationFirmware to mainElectronics.mainControlPcb.mcu;
    allocate robotFirmware.safetySupervisor to mainElectronics.mainControlPcb.mcu;
    allocate robotFirmware.mapProcessing to mainElectronics.mainControlPcb.mcu;
    allocate robotFirmware.localizationEstimator to mainElectronics.mainControlPcb.mcu;
    allocate robotFirmware.coveragePlanner to mainElectronics.mainControlPcb.mcu;

    // Firmware task access to concrete hardware peripherals and buses.
    allocation sensorI2cAccess : I2cMasterAccess
      allocate firmwareTasks.sensorAcquisition
      to mainElectronics.mainControlPcb.mcuI2cMaster;
    allocation lidarUartAccess : UartDmaAccess
      allocate firmwareTasks.sensorAcquisition
      to mainElectronics.mainControlPcb.mcu.lidarUart;
    allocation motorPwmAccess : PwmOutputAccess
      allocate firmwareTasks.motorControl
      to mainElectronics.mainControlPcb.mcu;
    allocation safetyGpioAccess : GpioInputAccess
      allocate firmwareTasks.safetySupervisor
      to mainElectronics.safetyGpioHarness;
    allocation flashStorageAccess : FlashStorageAccess
      allocate firmwareTasks.storage
      to mainElectronics.mainControlPcb.flash;
    allocation appWirelessAccess : WirelessUartAccess
      allocate firmwareTasks.appProtocol
      to mainElectronics.mainControlPcb.wirelessUart;
  }
}
