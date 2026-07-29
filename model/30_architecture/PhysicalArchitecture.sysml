/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Selected physical product baseline and its authoritative interconnections.
 *
 * Assembly-oriented breakdown: BaseModule (chassis, drivetrain, cleaning head,
 * power, dock interface) is built first; MainPcbModule screws into it and is
 * wired to its motors/sensors/power; TopModule (LiDAR, front ToF, bumper)
 * snaps onto BaseModule last, enclosing everything; DustBin is a separate,
 * tool-free-removable module.
 */
package PhysicalArchitecture {
  private import BehaviorStates::*;
  private import DomainModel::*;
  private import ProductContext::CleaningRobot;
  private import Elan8::Electronics::Core::*;
  private import Elan8::Electronics::Actuation::*;
  private import Elan8::Electronics::Sensing::*;
  private import Elan8::Electronics::Power::*;
  private import Elan8::Electronics::Assembly::*;
  private import Elan8::Electronics::Buses::*;
  private import Elan8::Electronics::Interconnection::*;
  private import Elan8::Mechanical::Core::*;
  private import Elan8::Mechanical::Drivetrain::*;
  private import Elan8::Electronics::Compute::*;
  private import FirmwareArchitecture::*;
  private import PurchasedParts::*;
  private import SystemRequirements::*;
  private import Elan8::Software::Core::*;
  private import Elan8::Electronics::Wireless::*;
  private import Elan8::Units::Engineering::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  part def DriveMotor :> BldcMotor {
    attribute :>> ratedPower = 14 [W];
    attribute :>> mass = 0.5 [kg]; /* illustrative estimate */
  }

  part def DriveTrain :> MechanicalComponent {
    attribute :>> mass =
      sum(motor.mass, gearbox.mass, wheel.mass, encoder.mass, lift.mass);
    port phases : ThreePhaseDrivePort;
    port odometry : QuadratureEncoderPort;
    port liftHazard : GpioPort;

    part motor : DriveMotor;
    part gearbox : Gearbox {
      attribute :>> gearRatio = 30; /* illustrative estimate */
      attribute :>> mass = 0.15 [kg]; /* illustrative estimate */
    }
    part wheel : Wheel {
      attribute :>> diameter = 65 [mm]; /* illustrative estimate */
      attribute :>> mass = 0.08 [kg]; /* illustrative estimate */
    }
    part encoder : QuadratureEncoder {
      attribute :>> mass = 0.1 [kg]; /* illustrative estimate */
    }
    part lift : LiftSwitch {
      attribute :>> mass = 0.01 [kg]; /* illustrative estimate */
    }

    connect motor.electricalInput to phases;
    connect encoder.odometry to odometry;
    connect lift.signal to liftHazard;
  }

  part def CleaningHeadModule :> ElectronicsComponent {
    attribute :>> powerDraw = sum(brushMotor.ratedPower, vacuumMotor.ratedPower);
    attribute :>> mass = sum(brushMotor.mass, vacuumMotor.mass, housingMass);
    attribute housingMass : MassValue = 0.4 [kg]; /* illustrative estimate residual */
    doc /*
      housingMass is a named residual for unmodeled housing, brush-assembly, and
      vacuum duct/impeller housing mass, following the enclosureMass/binMass
      residual pattern used elsewhere in this file.
    */
    port power : PowerRailPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port fault : GpioPort;

    part brushMotor : BrushedDcMotor {
      attribute :>> ratedPower = 8 [W]; /* illustrative estimate */
      attribute :>> mass = 0.25 [kg]; /* illustrative estimate */
    }
    part brushDriver : HBridgeMotorDriver;
    part vacuumMotor : BrushedDcMotor {
      attribute :>> ratedPower = 10 [W]; /* illustrative estimate */
      attribute :>> mass = 0.25 [kg]; /* illustrative estimate */
    }
    part vacuumDriver : HBridgeMotorDriver;

    connect power to brushDriver.supply;
    connect power to vacuumDriver.supply;
    connect brushCommand to brushDriver.command;
    connect vacuumCommand to vacuumDriver.command;
    connect brushDriver.driveOutput to brushMotor.electricalInput;
    connect vacuumDriver.driveOutput to vacuumMotor.electricalInput;
  }

  part def RobotTofSensor :> DcPoweredSensor, I2cDataSensor {
    attribute range : LengthValue = 1200 [mm];
    attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 0.1 [W]; /* illustrative estimate */
    dependency selectedImplementation
      from RobotTofSensor to VL53L1CX;
  }

  part def RobotLidar :> DcPoweredSensor, UartDataSensor {
    attribute scanRate : FrequencyValue = 10 [Hz];
    attribute range : LengthValue = 6000 [mm];
    attribute :>> mass = 0.15 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 3.5 [W]; /* illustrative estimate */
    dependency selectedImplementation
      from RobotLidar to RPLIDARC1;
  }

  part def CliffSensor :> DcPoweredSensor {
    attribute triggerHeight : LengthValue = 50 [mm];
    attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 0.25 [W]; /* illustrative estimate */
    port signal : GpioPort;
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
    port bmsBus : ~I2cControllerPort;
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

  part def DockInterfaceModule :> ElectronicsComponent {
    doc /* Atomic module; no internal part decomposition modeled here. */
    attribute :>> powerDraw = 2 [W];
    attribute :>> mass = 0.38 [kg];
    port chargePower : PowerRailPort;
    port beacon : GpioPort;
  }

  part def Chassis :> MechanicalComponent {
    doc /* Bare structural tub; everything else in BaseModule mounts on it. */
    attribute :>> mass = 0.3 [kg]; /* illustrative estimate */
  }

  part def BaseModule :> MechanicalComponent {
    attribute :>> mass = sum(
      chassis.mass, leftDriveTrain.mass, rightDriveTrain.mass, casterWheel.mass,
      frontLeftCliff.mass, frontRightCliff.mass, rearLeftCliff.mass, rearRightCliff.mass,
      cleaningHead.mass, powerModule.mass, dockInterface.mass
    );
    attribute baseElectronicsPowerDraw : PowerValue = sum(
      leftDriveTrain.motor.ratedPower, rightDriveTrain.motor.ratedPower,
      frontLeftCliff.powerDraw, frontRightCliff.powerDraw,
      rearLeftCliff.powerDraw, rearRightCliff.powerDraw,
      cleaningHead.powerDraw, powerModule.powerDraw, dockInterface.powerDraw
    );
    doc /*
      baseElectronicsPowerDraw is an ordinary (non-inherited) attribute, not an
      ElectronicsComponent::powerDraw override — BaseModule specializes
      MechanicalComponent and is not itself an ElectronicsComponent. It aggregates
      the current draw of every electronics child mounted in/on the base tub.
    */
    port leftPhases : ThreePhaseDrivePort;
    port rightPhases : ThreePhaseDrivePort;
    port leftOdometry : QuadratureEncoderPort;
    port rightOdometry : QuadratureEncoderPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port hazard : GpioPort;
    port batteryRail : PowerRailPort;
    port logicRail : PowerRailPort;
    port sensorRail : PowerRailPort;
    port bmsBus : I2cControllerPort;
    port chargePower : PowerRailPort;
    port beacon : GpioPort;

    part chassis : Chassis;
    part leftDriveTrain : DriveTrain;
    part rightDriveTrain : DriveTrain;
    part casterWheel : CasterWheel {
      attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
    }
    part frontLeftCliff : CliffSensor;
    part frontRightCliff : CliffSensor;
    part rearLeftCliff : CliffSensor;
    part rearRightCliff : CliffSensor;
    part cleaningHead : CleaningHeadModule;
    part powerModule : PowerModule;
    part dockInterface : DockInterfaceModule;

    connect leftDriveTrain.phases to leftPhases;
    connect rightDriveTrain.phases to rightPhases;
    connect leftDriveTrain.odometry to leftOdometry;
    connect rightDriveTrain.odometry to rightOdometry;

    connect powerModule.batteryRail to batteryRail;
    connect powerModule.logicRail to logicRail;
    connect powerModule.sensorRail to sensorRail;
    connect powerModule.bmsBus to bmsBus;
    connect powerModule.batteryRail to cleaningHead.power;

    connect brushCommand to cleaningHead.brushCommand;
    connect vacuumCommand to cleaningHead.vacuumCommand;

    connect chargePower to dockInterface.chargePower;
    connect beacon to dockInterface.beacon;

    connect leftDriveTrain.liftHazard to hazard;
    connect rightDriveTrain.liftHazard to hazard;
    connect frontLeftCliff.signal to hazard;
    connect frontRightCliff.signal to hazard;
    connect rearLeftCliff.signal to hazard;
    connect rearRightCliff.signal to hazard;
    connect powerModule.hazard to hazard;
    connect cleaningHead.fault to hazard;
  }

  part def RobotMainMcu :> Microcontroller {
    attribute :>> mass = 0.01 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 3 [W]; /* illustrative estimate */
    port sensorI2c : I2cControllerPort;
    port lidarUart : UartPort;
    port bmsSmbus : I2cControllerPort;
    port wirelessUart : UartPort;
    port leftMotorPwm : PwmPort;
    port rightMotorPwm : PwmPort;
    port brushPwm : PwmPort;
    port vacuumPwm : PwmPort;
    port safetyGpio : GpioPort;
    dependency selectedImplementation
      from RobotMainMcu to STM32U575VGT6;
  }

  part def RobotMotorDriver :> ThreePhaseMotorDriver {
    attribute :>> mass = 0.005 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 1.5 [W]; /* illustrative estimate */
    dependency selectedImplementation
      from RobotMotorDriver to DRV8316R;
  }

  part def RobotWirelessModule :> WirelessModule {
    attribute :>> mass = 0.005 [kg]; /* illustrative estimate */
    attribute :>> powerDraw = 1 [W]; /* illustrative estimate */
    port hostLink : UartPort :>> hostLink;
    dependency selectedImplementation
      from RobotWirelessModule to ESP32C3MINI1;
  }

  part def MainPcbModule :> PrintedCircuitBoardAssembly {
    attribute :>> powerDraw =
      sum(mcu.powerDraw, leftMotorDriver.powerDraw, rightMotorDriver.powerDraw,
          wireless.powerDraw, imu.powerDraw);
    attribute :>> mass =
      sum(mcu.mass, leftMotorDriver.mass, rightMotorDriver.mass, wireless.mass,
          imu.mass, boardMass);
    attribute boardMass : MassValue = 0.155 [kg];
    doc /*
      boardMass covers PCB substrate, connectors, and passives not individually
      modeled. Merges the former MainControlPcb + MainElectronicsAssembly wrapper
      into one module — Base and Top now form the real enclosure, so a separate
      PCB-housing level is no longer needed.
    */
    port batteryPower : PowerRailPort;
    port logicPower : PowerRailPort;
    port sensorBus : ~I2cControllerPort;
    port lidarSerial : UartPort;
    port bmsBus : ~I2cControllerPort;
    port wirelessService : UartPort;
    port leftPhases : ThreePhaseDrivePort;
    port rightPhases : ThreePhaseDrivePort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port hazard : GpioPort;

    part mcu : RobotMainMcu;
    part leftMotorDriver : RobotMotorDriver;
    part rightMotorDriver : RobotMotorDriver;
    part wireless : RobotWirelessModule;
    part wirelessUart : WirelessUartBus;
    part imu : I2cInertialMeasurementUnit {
      attribute :>> mass = 0.03 [kg]; /* illustrative estimate — unchanged from prior SensorAssembly.imu */
      attribute :>> powerDraw = 0.2 [W]; /* illustrative estimate — unchanged from prior SensorAssembly.imu */
    }

    connect batteryPower to leftMotorDriver.supply;
    connect batteryPower to rightMotorDriver.supply;
    connect logicPower to imu.power;
    connect sensorBus to mcu.sensorI2c;
    interface imuLink : I2cLink
      connect controllerPort ::> mcu.sensorI2c
      to targetPort ::> imu.data;
    connect lidarSerial to mcu.lidarUart;
    connect bmsBus to mcu.bmsSmbus;
    connect mcu.leftMotorPwm to leftMotorDriver.command;
    connect mcu.rightMotorPwm to rightMotorDriver.command;
    connect leftMotorDriver.driveOutput to leftPhases;
    connect rightMotorDriver.driveOutput to rightPhases;
    connect mcu.brushPwm to brushCommand;
    connect mcu.vacuumPwm to vacuumCommand;
    connect mcu.wirelessUart to wirelessUart.host;
    connect wireless.hostLink to wirelessUart.wireless;
    connect wirelessService to wirelessUart.wireless;
    connect leftMotorDriver.fault to hazard;
    connect rightMotorDriver.fault to hazard;
    connect mcu.safetyGpio to hazard;
  }

  part def TopModule :> MechanicalComponent {
    attribute :>> mass = sum(
      lidar.mass, frontTof.mass, leftTof.mass, rightTof.mass, frontBumper.mass, shellMass
    );
    attribute shellMass : MassValue = 0.2 [kg]; /* illustrative estimate residual */
    attribute topElectronicsPowerDraw : PowerValue = sum(
      lidar.powerDraw, frontTof.powerDraw, leftTof.powerDraw, rightTof.powerDraw
    );
    doc /*
      topElectronicsPowerDraw is an ordinary (non-inherited) attribute, not an
      ElectronicsComponent::powerDraw override — TopModule specializes
      MechanicalComponent and is not itself an ElectronicsComponent. shellMass is a
      named residual for the unmodeled outer-shell plastic. frontBumper's quiescent
      draw is left unset (negligible), matching the ElectronicsComponent "no
      default, not mandatory" convention already used for BatteryPack.
    */
    port sensorBus : I2cControllerPort;
    port lidarSerial : UartPort;
    port power : PowerRailPort;
    port hazard : GpioPort;

    part lidar : RobotLidar;
    part frontTof : RobotTofSensor;
    part leftTof : RobotTofSensor;
    part rightTof : RobotTofSensor;
    part frontBumper : BumperSwitch {
      attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
    }
    part i2c : SensorI2cBus;
    part uart : LidarUartBus;

    connect sensorBus to i2c.host;
    connect frontTof.data to i2c.frontTof;
    connect leftTof.data to i2c.leftTof;
    connect rightTof.data to i2c.rightTof;
    connect lidarSerial to uart.host;
    connect lidar.data to uart.lidar;
    connect lidar.power to power;
    connect frontTof.power to power;
    connect leftTof.power to power;
    connect rightTof.power to power;
    connect frontBumper.signal to hazard;
  }

  part def DustBinLid :> MechanicalComponent {
    attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
  }

  part def DustFilter :> MechanicalComponent {
    attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
  }

  part def DustBin :> MechanicalComponent {
    doc /*
      Tool-free-removable module, independent of Base/Top — matches it being a
      separately replaceable real-world spare part. Purely mechanical: no ports,
      no electronics.
    */
    attribute :>> mass = sum(lid.mass, filter.mass, binMass);
    attribute binMass : MassValue = 0.15 [kg]; /* illustrative estimate residual */
    attribute capacity : VolumeValue = 400000 [mm^3]; /* illustrative estimate, ~0.4 L */

    part lid : DustBinLid;
    part filter : DustFilter;
  }

  part def HumanMachineInterface :> ElectronicsComponent {
    doc /* Atomic module; no internal part decomposition modeled here. */
    attribute :>> powerDraw = 1 [W];
    attribute :>> mass = 0.08 [kg];
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

  part def AutonomousFloorCleaningRobot :> CleaningRobot {
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

    part base : BaseModule;
    part mainPcb : MainPcbModule;
    part top : TopModule;
    part dustBin : DustBin;
    part hmi : HumanMachineInterface;
    part firmwareTasks : FirmwareTaskArchitecture;

    connect mainPcb.batteryPower to base.batteryRail;
    connect mainPcb.logicPower to base.logicRail;
    connect top.power to base.sensorRail;
    connect mainPcb.leftPhases to base.leftPhases;
    connect mainPcb.rightPhases to base.rightPhases;
    connect mainPcb.brushCommand to base.brushCommand;
    connect mainPcb.vacuumCommand to base.vacuumCommand;
    connect mainPcb.sensorBus to top.sensorBus;
    connect mainPcb.lidarSerial to top.lidarSerial;
    connect mainPcb.bmsBus to base.bmsBus;
    connect base.hazard to mainPcb.hazard;
    connect top.hazard to mainPcb.hazard;
    connect dockPower to base.chargePower;
    connect dockBeacon to base.beacon;

    allocate firmwareTasks.missionController
      to mainPcb.mcu;
    allocate firmwareTasks.safetySupervisor
      to mainPcb.mcu;
    allocate firmwareTasks.actuatorControl
      to mainPcb.mcu;
    allocate firmwareTasks.sensorAcquisition
      to mainPcb.mcu;
    allocate firmwareTasks.navigation
      to mainPcb.mcu;
    allocate firmwareTasks.powerManager
      to mainPcb.mcu;
    allocate firmwareTasks.appService
      to mainPcb.mcu;

    allocation sensorBusAccess : TaskToPeripheralAccess
      allocate firmwareTasks.sensorAcquisition
      to mainPcb.mcu.sensorI2c;
    allocation lidarAccess : TaskToPeripheralAccess
      allocate firmwareTasks.sensorAcquisition
      to mainPcb.mcu.lidarUart;
    allocation actuatorPwmAccess : TaskToPeripheralAccess
      allocate firmwareTasks.actuatorControl
      to mainPcb.mcu.leftMotorPwm;
    allocation safetyGpioAccess : TaskToPeripheralAccess
      allocate firmwareTasks.safetySupervisor
      to mainPcb.mcu.safetyGpio;
    allocation powerBusAccess : TaskToPeripheralAccess
      allocate firmwareTasks.powerManager
      to mainPcb.mcu.bmsSmbus;
    allocation appWirelessAccess : TaskToPeripheralAccess
      allocate firmwareTasks.appService
      to mainPcb.wirelessUart;
  }
}
