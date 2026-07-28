/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Selected physical product baseline and its authoritative interconnections.
 */
package PhysicalArchitecture {
  private import BehaviorStates::*;
  private import DomainModel::*;
  private import ElectronicsCore::*;
  private import ElectronicActuationDomain::*;
  private import SensingDomain::*;
  private import ElectricalPowerDomain::*;
  private import BoardIntegrationDomain::*;
  private import EmbeddedComputeDomain::*;
  private import FirmwareArchitecture::*;
  private import PurchasedParts::*;
  private import SystemRequirements::*;
  private import SoftwareCore::*;
  private import WirelessDomain::*;
  private import EngineeringUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  part def DriveMotor :> BldcMotor {
    attribute :>> ratedPower = 14 [W];
    attribute :>> mass = 0.5 [kg]; /* illustrative estimate */
  }

  part def DriveModule :> ElectronicsComponent {
    attribute :>> powerDraw = sum(leftMotor.ratedPower, rightMotor.ratedPower);
    attribute :>> mass =
      sum(leftMotor.mass, rightMotor.mass, leftEncoder.mass, rightEncoder.mass);
    port leftPhases : ThreePhaseMotorPort;
    port rightPhases : ThreePhaseMotorPort;
    port leftOdometry : QuadratureEncoderPort;
    port rightOdometry : QuadratureEncoderPort;
    port bumperHazard : GpioPort;
    part leftMotor : DriveMotor;
    part rightMotor : DriveMotor;
    part leftEncoder : QuadratureEncoder {
      attribute :>> mass = 0.1 [kg]; /* illustrative estimate */
    }
    part rightEncoder : QuadratureEncoder {
      attribute :>> mass = 0.1 [kg]; /* illustrative estimate */
    }
    connect leftMotor.phases to leftPhases;
    connect rightMotor.phases to rightPhases;
    connect leftEncoder.odometry to leftOdometry;
    connect rightEncoder.odometry to rightOdometry;
  }

  part def CleaningHeadModule :> ElectronicsComponent {
    doc /* Atomic module; no internal part decomposition modeled here. */
    attribute :>> powerDraw = 18 [W];
    attribute :>> mass = 0.9 [kg];
    port power : PowerRailPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port fault : GpioPort;
  }

  part def RobotTofSensor :> ElectronicsComponent {
    attribute range : LengthValue = 1200 [mm];
    attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 0.1 [W]; /* illustrative estimate */
    port bus : I2cPort;
    dependency selectedImplementation
      from RobotTofSensor to VL53L1CX;
  }

  part def RobotLidar :> ElectronicsComponent {
    attribute scanRate : FrequencyValue = 10 [Hz];
    attribute range : LengthValue = 6000 [mm];
    attribute :>> mass = 0.15 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 3.5 [W]; /* illustrative estimate */
    port serial : UartPort;
    port power : PowerRailPort;
    dependency selectedImplementation
      from RobotLidar to RPLIDARC1;
  }

  part def CliffSensor :> ElectronicsComponent {
    attribute triggerHeight : LengthValue = 50 [mm];
    attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 0.25 [W]; /* illustrative estimate */
    port hazard : GpioPort;
  }

  part def SensorAssembly :> ElectronicsComponent {
    attribute :>> powerDraw = sum(
      frontTof.powerDraw, leftTof.powerDraw, rightTof.powerDraw,
      imu.powerDraw, lidar.powerDraw,
      frontLeftCliff.powerDraw, frontRightCliff.powerDraw,
      rearLeftCliff.powerDraw, rearRightCliff.powerDraw
    );
    attribute :>> mass = sum(
      frontTof.mass, leftTof.mass, rightTof.mass,
      imu.mass, lidar.mass,
      frontLeftCliff.mass, frontRightCliff.mass,
      rearLeftCliff.mass, rearRightCliff.mass
    );
    port power : PowerRailPort;
    port sensorBus : I2cPort;
    port lidarSerial : UartPort;
    port cliffHazard : GpioPort;

    part frontTof : RobotTofSensor;
    part leftTof : RobotTofSensor;
    part rightTof : RobotTofSensor;
    part imu : InertialMeasurementUnit {
      attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
      attribute :>> powerDraw = 0.2 [W]; /* illustrative estimate */
    }
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

  part def RobotBms :> BatteryManagementSystem {
    attribute :>> maxChargeCurrent = 2 [A];
    attribute :>> maxCellTemperature = 328.15 [K];
    attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
    attribute :>> quiescentPower = 1 [W]; /* illustrative estimate */
    dependency selectedImplementation
      from RobotBms to BQ40Z50R2;
  }

  part def PowerModule :> ElectronicsComponent {
    attribute :>> powerDraw =
      sum(bms.quiescentPower, logicRegulator.quiescentPower, sensorRegulator.quiescentPower);
    attribute :>> mass =
      sum(battery.mass, bms.mass, logicRegulator.mass, sensorRegulator.mass);
    port batteryRail : PowerRailPort;
    port logicRail : PowerRailPort;
    port sensorRail : PowerRailPort;
    port bmsBus : I2cPort;
    port hazard : GpioPort;

    attribute batteryRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> continuousCurrentBudget = 5 [A];
      attribute :>> peakCurrentBudget = 8 [A];
    }
    attribute logicRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> continuousCurrentBudget = 1 [A];
      attribute :>> peakCurrentBudget = 1.5 [A];
    }
    attribute sensorRailBudget : PowerRailBudget {
      attribute :>> nominalVoltage = 5 [V];
      attribute :>> continuousCurrentBudget = 0.8 [A];
      attribute :>> peakCurrentBudget = 1.2 [A];
    }
    part battery : BatteryPack {
      attribute :>> nominalCapacity = 12500 [mAh];
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> mass = 0.65 [kg]; /* illustrative estimate */
    }
    part bms : RobotBms;
    part logicRegulator : VoltageRegulator {
      attribute :>> outputVoltage = 3.3 [V];
      attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
      attribute :>> quiescentPower = 1 [W]; /* illustrative estimate */
    }
    part sensorRegulator : VoltageRegulator {
      attribute :>> outputVoltage = 5 [V];
      attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
      attribute :>> quiescentPower = 1 [W]; /* illustrative estimate */
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

  part def RobotMainMcu :> Microcontroller {
    attribute :>> mass = 0.01 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 3 [W]; /* illustrative estimate */
    port sensorI2c : I2cPort;
    port lidarUart : UartPort;
    port bmsSmbus : I2cPort;
    port wirelessUart : UartPort;
    port leftMotorPwm : PwmPort;
    port rightMotorPwm : PwmPort;
    port brushPwm : PwmPort;
    port vacuumPwm : PwmPort;
    port safetyGpio : GpioPort;
    dependency selectedImplementation
      from RobotMainMcu to STM32U575VGT6;
  }

  part def RobotMotorDriver :> MotorDriver {
    attribute :>> mass = 0.005 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 1.5 [W]; /* illustrative estimate */
    dependency selectedImplementation
      from RobotMotorDriver to DRV8316R;
  }

  part def RobotWirelessModule :> WirelessModule {
    attribute :>> mass = 0.005 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 1 [W]; /* illustrative estimate */
    port serial : UartPort;
    dependency selectedImplementation
      from RobotWirelessModule to ESP32C3MINI1;
  }

  part def MainControlPcb :> BoardAssembly {
    attribute :>> powerDraw =
      sum(mcu.powerDraw, leftMotorDriver.powerDraw, rightMotorDriver.powerDraw, wireless.powerDraw);
    attribute :>> mass =
      sum(mcu.mass, leftMotorDriver.mass, rightMotorDriver.mass, wireless.mass, boardMass);
    attribute boardMass : MassValue = 0.155 [kg];
    doc /* boardMass covers PCB substrate, connectors, and passives not individually modeled. */
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

  part def MainElectronicsAssembly :> ElectronicsComponent {
    attribute :>> mass = sum(mainControlPcb.mass, enclosureMass);
    attribute enclosureMass : MassValue = 0.10 [kg];
    attribute :>> powerDraw = sum(mainControlPcb.powerDraw, auxiliaryPower);
    attribute auxiliaryPower : PowerValue = 2 [W];
    doc /*
      enclosureMass/auxiliaryPower are named residuals for unmodeled housing and
      wiring/connector overhead not attributable to mainControlPcb's own children.
    */
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

  part def DockInterfaceModule :> ElectronicsComponent {
    doc /* Atomic module; no internal part decomposition modeled here. */
    attribute :>> powerDraw = 2 [W];
    attribute :>> mass = 0.38 [kg];
    port chargePower : PowerRailPort;
    port beacon : GpioPort;
  }

  part def HumanMachineInterface :> ElectronicsComponent {
    doc /* Atomic module; no internal part decomposition modeled here. */
    attribute :>> powerDraw = 1 [W];
    attribute :>> mass = 0.08 [kg];
    port app : ~AppServicePort;
  }

  attribute def PowerRailBudget {
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

    connect powerModule.batteryRail to mainElectronics.batteryPower;
    connect powerModule.batteryRail to cleaningHead.power;
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
