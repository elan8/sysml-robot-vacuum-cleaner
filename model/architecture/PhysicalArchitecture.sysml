/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Selected physical product baseline and its authoritative interconnections.
 */
package PhysicalArchitecture {
  private import BehaviorStates::*;
  private import DomainModel::*;
  private import FirmwareArchitecture::*;
  private import PurchasedParts::*;
  private import SystemRequirements::*;
  private import SoftwareCore::*;
  private import VacuumCleanerQuantitiesAndUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  part def PhysicalAssembly {
    attribute powerDraw : PowerValue;
    attribute mass : MassValue;
  }

  part def DriveMotor {
    attribute ratedPower : PowerValue = 14 [W];
    port phases : ~ThreePhaseMotorPort;
  }

  part def WheelEncoder {
    port odometry : QuadratureEncoderPort;
  }

  part def DriveModule :> PhysicalAssembly {
    attribute :>> powerDraw = 28 [W];
    attribute :>> mass = 1.2 [kg];
    port leftPhases : ThreePhaseMotorPort;
    port rightPhases : ThreePhaseMotorPort;
    port leftOdometry : QuadratureEncoderPort;
    port rightOdometry : QuadratureEncoderPort;
    port bumperHazard : GpioPort;
    part leftMotor : DriveMotor;
    part rightMotor : DriveMotor;
    part leftEncoder : WheelEncoder;
    part rightEncoder : WheelEncoder;
    connect leftMotor.phases to leftPhases;
    connect rightMotor.phases to rightPhases;
    connect leftEncoder.odometry to leftOdometry;
    connect rightEncoder.odometry to rightOdometry;
  }

  part def CleaningHeadModule :> PhysicalAssembly {
    attribute :>> powerDraw = 18 [W];
    attribute :>> mass = 0.9 [kg];
    port power : PowerRailPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port fault : GpioPort;
  }

  part def RobotTofSensor :> VL53L1CX {
    attribute range : LengthValue = 1200 [mm];
    port bus : I2cPort;
  }

  part def RobotLidar :> RPLIDARC1 {
    attribute scanRate : FrequencyValue = 10 [Hz];
    attribute range : LengthValue = 6000 [mm];
    port serial : UartPort;
    port power : PowerRailPort;
  }

  part def InertialMeasurementUnit {
    port bus : I2cPort;
  }

  part def CliffSensor {
    attribute triggerHeight : LengthValue = 50 [mm];
    port hazard : GpioPort;
  }

  part def SensorAssembly :> PhysicalAssembly {
    attribute :>> powerDraw = 5 [W];
    attribute :>> mass = 0.35 [kg];
    port power : PowerRailPort;
    port sensorBus : I2cPort;
    port lidarSerial : UartPort;
    port cliffHazard : GpioPort;

    part frontTof : RobotTofSensor;
    part leftTof : RobotTofSensor;
    part rightTof : RobotTofSensor;
    part imu : InertialMeasurementUnit;
    part lidar : RobotLidar;
    part frontLeftCliff : CliffSensor;
    part frontRightCliff : CliffSensor;
    part rearLeftCliff : CliffSensor;
    part rearRightCliff : CliffSensor;
    part i2c : SensorI2cBus;
    part uart : LidarUartBus;

    connect sensorBus to i2c.host;
    connect frontTof.bus to i2c.frontTof;
    connect leftTof.bus to i2c.leftTof;
    connect rightTof.bus to i2c.rightTof;
    connect imu.bus to i2c.imu;
    connect lidarSerial to uart.host;
    connect lidar.serial to uart.lidar;
    connect lidar.power to power;
    connect frontLeftCliff.hazard to cliffHazard;
    connect frontRightCliff.hazard to cliffHazard;
    connect rearLeftCliff.hazard to cliffHazard;
    connect rearRightCliff.hazard to cliffHazard;
  }

  part def BatteryPack {
    attribute nominalCapacity : ElectricChargeValue = 12500 [mAh];
    attribute nominalVoltage : ElectricPotentialValue = 14.4 [V];
    port output : PowerRailPort;
  }

  part def RobotBms :> BQ40Z50R2 {
    attribute maxChargeCurrent : ElectricCurrentValue = 2 [A];
    attribute maxCellTemperature : ThermodynamicTemperatureValue = 328.15 [K];
    port bus : I2cPort;
    port alert : GpioPort;
  }

  part def PowerRegulator {
    attribute outputVoltage : ElectricPotentialValue;
    port input : PowerRailPort;
    port output : PowerRailPort;
  }

  part def PowerModule :> PhysicalAssembly {
    attribute :>> powerDraw = 3 [W];
    attribute :>> mass = 0.72 [kg];
    port batteryRail : PowerRailPort;
    port logicRail : PowerRailPort;
    port sensorRail : PowerRailPort;
    port bmsBus : I2cPort;
    port hazard : GpioPort;
    part battery : BatteryPack;
    part bms : RobotBms;
    part logicRegulator : PowerRegulator {
      attribute :>> outputVoltage = 3.3 [V];
    }
    part sensorRegulator : PowerRegulator {
      attribute :>> outputVoltage = 5 [V];
    }
    part smbus : BmsSmbusBus;

    connect battery.output to batteryRail;
    connect battery.output to logicRegulator.input;
    connect battery.output to sensorRegulator.input;
    connect logicRegulator.output to logicRail;
    connect sensorRegulator.output to sensorRail;
    connect bmsBus to smbus.host;
    connect bms.bus to smbus.bms;
    connect bms.alert to hazard;
  }

  part def RobotMainMcu :> STM32U575VGT6 {
    port sensorI2c : I2cPort;
    port lidarUart : UartPort;
    port bmsSmbus : I2cPort;
    port wirelessUart : UartPort;
    port leftMotorPwm : PwmPort;
    port rightMotorPwm : PwmPort;
    port brushPwm : PwmPort;
    port vacuumPwm : PwmPort;
    port safetyGpio : GpioPort;
  }

  part def RobotMotorDriver :> DRV8316R {
    port power : PowerRailPort;
    port command : PwmPort;
    port phases : ThreePhaseMotorPort;
    port fault : GpioPort;
  }

  part def RobotWirelessModule :> ESP32C3MINI1 {
    port serial : UartPort;
  }

  part def MainControlPcb :> PhysicalAssembly {
    attribute :>> powerDraw = 7 [W];
    attribute :>> mass = 0.18 [kg];
    port batteryPower : PowerRailPort;
    port logicPower : PowerRailPort;
    port sensorBus : I2cPort;
    port lidarSerial : UartPort;
    port bmsBus : I2cPort;
    port wirelessService : UartPort;
    port leftPhases : ThreePhaseMotorPort;
    port rightPhases : ThreePhaseMotorPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port hazard : GpioPort;

    part mcu : RobotMainMcu;
    part leftMotorDriver : RobotMotorDriver;
    part rightMotorDriver : RobotMotorDriver;
    part wireless : RobotWirelessModule;
    part wirelessUart : WirelessUartBus;

    connect batteryPower to leftMotorDriver.power;
    connect batteryPower to rightMotorDriver.power;
    connect sensorBus to mcu.sensorI2c;
    connect lidarSerial to mcu.lidarUart;
    connect bmsBus to mcu.bmsSmbus;
    connect mcu.leftMotorPwm to leftMotorDriver.command;
    connect mcu.rightMotorPwm to rightMotorDriver.command;
    connect leftMotorDriver.phases to leftPhases;
    connect rightMotorDriver.phases to rightPhases;
    connect mcu.brushPwm to brushCommand;
    connect mcu.vacuumPwm to vacuumCommand;
    connect mcu.wirelessUart to wirelessUart.host;
    connect wireless.serial to wirelessUart.wireless;
    connect wirelessService to wirelessUart.wireless;
    connect leftMotorDriver.fault to hazard;
    connect rightMotorDriver.fault to hazard;
    connect mcu.safetyGpio to hazard;
  }

  part def MainElectronicsAssembly :> PhysicalAssembly {
    attribute :>> powerDraw = 9 [W];
    attribute :>> mass = 0.28 [kg];
    port batteryPower : PowerRailPort;
    port logicPower : PowerRailPort;
    port sensorBus : I2cPort;
    port lidarSerial : UartPort;
    port bmsBus : I2cPort;
    port leftPhases : ThreePhaseMotorPort;
    port rightPhases : ThreePhaseMotorPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port hazard : GpioPort;
    part mainControlPcb : MainControlPcb;

    connect batteryPower to mainControlPcb.batteryPower;
    connect logicPower to mainControlPcb.logicPower;
    connect sensorBus to mainControlPcb.sensorBus;
    connect lidarSerial to mainControlPcb.lidarSerial;
    connect bmsBus to mainControlPcb.bmsBus;
    connect mainControlPcb.leftPhases to leftPhases;
    connect mainControlPcb.rightPhases to rightPhases;
    connect mainControlPcb.brushCommand to brushCommand;
    connect mainControlPcb.vacuumCommand to vacuumCommand;
    connect mainControlPcb.hazard to hazard;
  }

  part def DockInterfaceModule :> PhysicalAssembly {
    attribute :>> powerDraw = 2 [W];
    attribute :>> mass = 0.38 [kg];
    port chargePower : PowerRailPort;
    port beacon : GpioPort;
  }

  part def HumanMachineInterface :> PhysicalAssembly {
    attribute :>> powerDraw = 1 [W];
    attribute :>> mass = 0.08 [kg];
    port app : ~AppServicePort;
  }

  part def PowerRailBudget {
    attribute nominalVoltage : ElectricPotentialValue;
    attribute continuousCurrentBudget : ElectricCurrentValue;
    attribute peakCurrentBudget : ElectricCurrentValue;
  }

  allocation def TaskToPeripheralAccess {
    end task : FirmwareTask;
    end peripheral;
  }

  part def AutonomousFloorCleaningRobot :> SystemRequirementSubject {
    attribute :>> cleanedAreaPerCharge = 80 [m^2];
    attribute :>> reachableFloorCoveragePercent = 90;
    attribute :>> avoidedObstacleHeight = 30 [mm];
    attribute :>> cliffHeightDetectedBeforeWheelCrossing = 50 [mm];
    attribute :>> safeStopOnHazard = true;
    attribute :>> localizationError = 120 [mm];
    attribute :>> coverageMapMaintained = true;
    attribute :>> wheelStallDetectionTime = 1500 [ms];
    attribute :>> lowBatteryReturnThresholdPercent = 15.0;
    attribute :>> chargeCurrentWithinSafeOperatingArea = true;
    attribute :>> chargeTemperatureWithinSafeOperatingArea = true;
    attribute :>> cleaningStatusReported = true;
    attribute :>> mapDataLocalUnlessConsented = true;

    part driveModule : DriveModule;
    part cleaningHead : CleaningHeadModule;
    part sensorAssembly : SensorAssembly;
    part mainElectronics : MainElectronicsAssembly;
    part powerModule : PowerModule;
    part dockInterface : DockInterfaceModule;
    part hmi : HumanMachineInterface;
    part firmwareTasks : FirmwareTaskArchitecture;

    port app : AppServicePort;
    port dockPower : PowerRailPort;
    port dockBeacon : GpioPort;

    part batteryRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> continuousCurrentBudget = 5 [A];
      attribute :>> peakCurrentBudget = 8 [A];
      ref source = powerModule.battery.output;
      ref computeLoad = mainElectronics.batteryPower;
      ref cleaningLoad = cleaningHead.power;
    }
    part logicRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> continuousCurrentBudget = 1 [A];
      attribute :>> peakCurrentBudget = 1.5 [A];
      ref source = powerModule.logicRegulator.output;
      ref computeLoad = mainElectronics.logicPower;
    }
    part sensorRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 5 [V];
      attribute :>> continuousCurrentBudget = 0.8 [A];
      attribute :>> peakCurrentBudget = 1.2 [A];
      ref source = powerModule.sensorRegulator.output;
      ref sensorLoad = sensorAssembly.power;
    }

    connect powerModule.batteryRail to mainElectronics.batteryPower;
    connect powerModule.logicRail to mainElectronics.logicPower;
    connect powerModule.sensorRail to sensorAssembly.power;
    connect mainElectronics.leftPhases to driveModule.leftPhases;
    connect mainElectronics.rightPhases to driveModule.rightPhases;
    connect mainElectronics.brushCommand to cleaningHead.brushCommand;
    connect mainElectronics.vacuumCommand to cleaningHead.vacuumCommand;
    connect sensorAssembly.sensorBus to mainElectronics.sensorBus;
    connect sensorAssembly.lidarSerial to mainElectronics.lidarSerial;
    connect powerModule.bmsBus to mainElectronics.bmsBus;
    connect sensorAssembly.cliffHazard to mainElectronics.hazard;
    connect powerModule.hazard to mainElectronics.hazard;
    connect mainElectronics.hazard to cleaningHead.fault;
    connect hmi.app to app;
    connect dockPower to dockInterface.chargePower;
    connect dockBeacon to dockInterface.beacon;

    allocate firmwareTasks.missionController
      to mainElectronics.mainControlPcb.mcu;
    allocate firmwareTasks.safetySupervisor
      to mainElectronics.mainControlPcb.mcu;
    allocate firmwareTasks.actuatorControl
      to mainElectronics.mainControlPcb.mcu;
    allocate firmwareTasks.sensorAcquisition
      to mainElectronics.mainControlPcb.mcu;
    allocate firmwareTasks.navigation
      to mainElectronics.mainControlPcb.mcu;
    allocate firmwareTasks.powerManager
      to mainElectronics.mainControlPcb.mcu;
    allocate firmwareTasks.appService
      to mainElectronics.mainControlPcb.mcu;

    allocation sensorBusAccess : TaskToPeripheralAccess
      allocate firmwareTasks.sensorAcquisition
      to mainElectronics.mainControlPcb.mcu.sensorI2c;
    allocation lidarAccess : TaskToPeripheralAccess
      allocate firmwareTasks.sensorAcquisition
      to mainElectronics.mainControlPcb.mcu.lidarUart;
    allocation actuatorPwmAccess : TaskToPeripheralAccess
      allocate firmwareTasks.actuatorControl
      to mainElectronics.mainControlPcb.mcu.leftMotorPwm;
    allocation safetyGpioAccess : TaskToPeripheralAccess
      allocate firmwareTasks.safetySupervisor
      to mainElectronics.mainControlPcb.mcu.safetyGpio;
    allocation powerBusAccess : TaskToPeripheralAccess
      allocate firmwareTasks.powerManager
      to mainElectronics.mainControlPcb.mcu.bmsSmbus;
    allocation appWirelessAccess : TaskToPeripheralAccess
      allocate firmwareTasks.appService
      to mainElectronics.mainControlPcb.wirelessUart;
  }
}
