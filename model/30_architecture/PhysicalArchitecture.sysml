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
  private import Elan8::Electronics::Board::*;
  private import Elan8::Electronics::Buses::*;
  private import Elan8::Electronics::Interconnection::*;
  private import Elan8::Mechanical::Core::*;
  private import Elan8::Mechanical::Drivetrain::*;
  private import Elan8::Mechanical::Interconnection::*;
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
    connect motor.mechanicalOutput to gearbox.rotationalInput;
    connect gearbox.rotationalOutput to wheel.axle;
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
    port debrisOut : CleaningFlowPort;

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
    connect brushDriver.fault to fault;
    connect vacuumDriver.fault to fault;
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

  part def RobotBatteryCharger :> BatteryCharger {
    attribute :>> maxChargeCurrent = 2 [A];
    attribute :>> quiescentPower = 0.5 [W];
    attribute :>> powerDraw = 0.5 [W];
    attribute :>> mass = 0.04 [kg]; /* illustrative estimate */
  }

  part def PowerModule :> ElectronicsComponent {
    attribute :>> powerDraw =
      sum(charger.quiescentPower, bms.quiescentPower,
          logicRegulator.quiescentPower, sensorRegulator.quiescentPower);
    attribute :>> mass =
      sum(battery.mass, charger.mass, bms.mass,
          logicRegulator.mass, sensorRegulator.mass);
    port batteryRail : PowerRailPort;
    port logicRail : PowerRailPort;
    port sensorRail : PowerRailPort;
    port bmsBus : ~I2cControllerPort;
    port bmsAlert : GpioPort;

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
    part charger : RobotBatteryCharger;
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

    connect charger.chargeOutput to bms.chargeInput;
    connect battery.terminal to bms.batteryTerminal;
    connect bms.protectedOutput to batteryRail;
    connect bms.protectedOutput to logicRegulator.input;
    connect bms.protectedOutput to sensorRegulator.input;
    connect logicRegulator.output to logicRail;
    connect sensorRegulator.output to sensorRail;
    connect bmsBus to smbus.host;
    connect bms.bus to smbus.bms;
    connect bms.alert to bmsAlert;
  }

  part def DockInterfaceModule :> ElectronicsComponent {
    doc /*
      Robot-side docking interface with charging contacts and an optical
      homing-beacon receiver. The receiver converts the external beacon into
      an internal GPIO indication for the main controller.
    */
    attribute :>> powerDraw = 2 [W];
    attribute :>> mass = sum(beaconReceiver.mass, interfaceMass);
    attribute interfaceMass : MassValue = 0.35 [kg]; /* contacts and housing */
    port dockPowerInput : ~PowerRailPort;
    port chargePowerOutput : PowerRailPort;
    port beaconDetected : GpioPort;

    part beaconReceiver : HomingBeaconReceiver {
      attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
      attribute :>> powerDraw = 0.1 [W]; /* illustrative estimate */
    }

    connect dockPowerInput to chargePowerOutput;
    connect beaconReceiver.detection to beaconDetected;
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
    port leftLiftHazard : GpioPort;
    port rightLiftHazard : GpioPort;
    port frontLeftCliffHazard : GpioPort;
    port frontRightCliffHazard : GpioPort;
    port rearLeftCliffHazard : GpioPort;
    port rearRightCliffHazard : GpioPort;
    port cleaningFault : GpioPort;
    port bmsAlert : GpioPort;
    port dockBeaconDetected : GpioPort;
    port batteryRail : PowerRailPort;
    port logicRail : PowerRailPort;
    port sensorRail : PowerRailPort;
    port bmsBus : I2cControllerPort;
    port dockPowerInput : PowerRailPort;
    port beaconInput : HomingBeaconPort;

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
    connect powerModule.sensorRail to leftDriveTrain.encoder.power;
    connect powerModule.sensorRail to rightDriveTrain.encoder.power;
    connect powerModule.sensorRail to frontLeftCliff.power;
    connect powerModule.sensorRail to frontRightCliff.power;
    connect powerModule.sensorRail to rearLeftCliff.power;
    connect powerModule.sensorRail to rearRightCliff.power;
    connect powerModule.sensorRail to dockInterface.beaconReceiver.power;

    connect brushCommand to cleaningHead.brushCommand;
    connect vacuumCommand to cleaningHead.vacuumCommand;

    connect dockPowerInput to dockInterface.dockPowerInput;
    connect dockInterface.chargePowerOutput to powerModule.charger.supplyInput;
    connect beaconInput to dockInterface.beaconReceiver.beacon;

    connect leftDriveTrain.liftHazard to leftLiftHazard;
    connect rightDriveTrain.liftHazard to rightLiftHazard;
    connect frontLeftCliff.signal to frontLeftCliffHazard;
    connect frontRightCliff.signal to frontRightCliffHazard;
    connect rearLeftCliff.signal to rearLeftCliffHazard;
    connect rearRightCliff.signal to rearRightCliffHazard;
    connect powerModule.bmsAlert to bmsAlert;
    connect dockInterface.beaconDetected to dockBeaconDetected;
    connect cleaningHead.fault to cleaningFault;
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
    port leftOdometry : QuadratureEncoderPort;
    port rightOdometry : QuadratureEncoderPort;
    port leftLiftHazard : GpioPort;
    port rightLiftHazard : GpioPort;
    port frontLeftCliffHazard : GpioPort;
    port frontRightCliffHazard : GpioPort;
    port rearLeftCliffHazard : GpioPort;
    port rearRightCliffHazard : GpioPort;
    port cleaningFault : GpioPort;
    port bmsAlert : GpioPort;
    port dockBeaconDetected : GpioPort;
    port topBumperHazard : GpioPort;
    port leftMotorFault : GpioPort;
    port rightMotorFault : GpioPort;
    port localHmi : LocalHmiControllerPort;
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
    port robotService : RobotServicePort;
    dependency selectedImplementation
      from RobotWirelessModule to ESP32C3MINI1;
  }

  part def RobotControlBoard :> PrintedCircuitBoard {
    attribute :>> mass = 0.155 [kg];
  }

  part def MainPcbModule :> PrintedCircuitBoardAssembly {
    attribute :>> powerDraw =
      sum(mcu.powerDraw, leftMotorDriver.powerDraw, rightMotorDriver.powerDraw,
          wireless.powerDraw, imu.powerDraw);
    attribute :>> mass =
      sum(mcu.mass, leftMotorDriver.mass, rightMotorDriver.mass, wireless.mass,
          imu.mass, bareBoard.mass);
    doc /*
      bareBoard.mass covers PCB substrate, connectors, and passives not individually
      modeled. Merges the former MainControlPcb + MainElectronicsAssembly wrapper
      into one module — Base and Top now form the real enclosure, so a separate
      PCB-housing level is no longer needed.
    */
    port batteryPower : PowerRailPort;
    port logicPower : PowerRailPort;
    port sensorBus : ~I2cControllerPort;
    port lidarSerial : UartPort;
    port bmsBus : ~I2cControllerPort;
    port appService : ~RobotServicePort;
    port leftPhases : ThreePhaseDrivePort;
    port rightPhases : ThreePhaseDrivePort;
    port leftOdometry : QuadratureEncoderPort;
    port rightOdometry : QuadratureEncoderPort;
    port brushCommand : PwmPort;
    port vacuumCommand : PwmPort;
    port leftLiftHazard : GpioPort;
    port rightLiftHazard : GpioPort;
    port frontLeftCliffHazard : GpioPort;
    port frontRightCliffHazard : GpioPort;
    port rearLeftCliffHazard : GpioPort;
    port rearRightCliffHazard : GpioPort;
    port cleaningFault : GpioPort;
    port bmsAlert : GpioPort;
    port dockBeaconDetected : GpioPort;
    port topBumperHazard : GpioPort;
    port localHmi : ~LocalHmiControllerPort;

    part bareBoard : RobotControlBoard :>> bareBoard;
    part mcu : RobotMainMcu :> mountedComponents;
    part leftMotorDriver : RobotMotorDriver :> mountedComponents;
    part rightMotorDriver : RobotMotorDriver :> mountedComponents;
    part wireless : RobotWirelessModule :> mountedComponents;
    part wirelessUart : WirelessUartBus;
    part imu : I2cInertialMeasurementUnit :> mountedComponents {
      attribute :>> mass = 0.03 [kg]; /* illustrative estimate — unchanged from prior SensorAssembly.imu */
      attribute :>> powerDraw = 0.2 [W]; /* illustrative estimate — unchanged from prior SensorAssembly.imu */
    }

    connect batteryPower to leftMotorDriver.supply;
    connect batteryPower to rightMotorDriver.supply;
    connect logicPower to mcu.power;
    connect logicPower to wireless.power;
    connect logicPower to imu.power;
    connect sensorBus to mcu.sensorI2c;
    interface imuLink : I2cLink
      connect controllerPort ::> mcu.sensorI2c
      to targetPort ::> imu.data;
    connect lidarSerial to mcu.lidarUart;
    connect bmsBus to mcu.bmsSmbus;
    connect leftOdometry to mcu.leftOdometry;
    connect rightOdometry to mcu.rightOdometry;
    connect mcu.leftMotorPwm to leftMotorDriver.command;
    connect mcu.rightMotorPwm to rightMotorDriver.command;
    connect leftMotorDriver.driveOutput to leftPhases;
    connect rightMotorDriver.driveOutput to rightPhases;
    connect mcu.brushPwm to brushCommand;
    connect mcu.vacuumPwm to vacuumCommand;
    connect mcu.wirelessUart to wirelessUart.host;
    connect wireless.hostLink to wirelessUart.wireless;
    connect appService to wireless.robotService;
    connect leftLiftHazard to mcu.leftLiftHazard;
    connect rightLiftHazard to mcu.rightLiftHazard;
    connect frontLeftCliffHazard to mcu.frontLeftCliffHazard;
    connect frontRightCliffHazard to mcu.frontRightCliffHazard;
    connect rearLeftCliffHazard to mcu.rearLeftCliffHazard;
    connect rearRightCliffHazard to mcu.rearRightCliffHazard;
    connect cleaningFault to mcu.cleaningFault;
    connect bmsAlert to mcu.bmsAlert;
    connect dockBeaconDetected to mcu.dockBeaconDetected;
    connect topBumperHazard to mcu.topBumperHazard;
    connect localHmi to mcu.localHmi;
    connect leftMotorDriver.fault to mcu.leftMotorFault;
    connect rightMotorDriver.fault to mcu.rightMotorFault;
  }

  part def HumanMachineInterface :> ElectronicsComponent {
    attribute :>> powerDraw = 1 [W];
    attribute :>> mass = 0.08 [kg];
    port power : ~PowerRailPort;
    port control : ~LocalHmiControllerPort;
  }

  part def TopModule :> MechanicalComponent {
    attribute :>> mass = sum(
      lidar.mass, frontTof.mass, leftTof.mass, rightTof.mass,
      frontBumper.mass, hmi.mass, shellMass
    );
    attribute shellMass : MassValue = 0.2 [kg]; /* illustrative estimate residual */
    attribute topElectronicsPowerDraw : PowerValue = sum(
      lidar.powerDraw, frontTof.powerDraw, leftTof.powerDraw, rightTof.powerDraw,
      hmi.powerDraw
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
    port bumperHazard : GpioPort;
    port hmiControl : LocalHmiControllerPort;

    part lidar : RobotLidar;
    part frontTof : RobotTofSensor;
    part leftTof : RobotTofSensor;
    part rightTof : RobotTofSensor;
    part frontBumper : BumperSwitch {
      attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
    }
    part hmi : HumanMachineInterface;
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
    connect hmi.power to power;
    connect hmi.control to hmiControl;
    connect frontBumper.signal to bumperHazard;
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
    port debrisIn : ~CleaningFlowPort;

    part lid : DustBinLid;
    part filter : DustFilter;
  }

  part def BaseWiringHarness :> WiringHarness {
    attribute :>> mass = 0.12 [kg]; /* illustrative estimate */
    part pcbConnector : BoardConnector :> connectors;
    part baseConnector : ElectronicConnector :> connectors;

    port pcbBatteryPower : PowerRailPort;
    port baseBatteryRail : PowerRailPort;
    port pcbLogicPower : PowerRailPort;
    port baseLogicRail : PowerRailPort;
    port pcbLeftPhases : ThreePhaseDrivePort;
    port baseLeftPhases : ThreePhaseDrivePort;
    port pcbRightPhases : ThreePhaseDrivePort;
    port baseRightPhases : ThreePhaseDrivePort;
    port pcbLeftOdometry : QuadratureEncoderPort;
    port baseLeftOdometry : QuadratureEncoderPort;
    port pcbRightOdometry : QuadratureEncoderPort;
    port baseRightOdometry : QuadratureEncoderPort;
    port pcbBrushCommand : PwmPort;
    port baseBrushCommand : PwmPort;
    port pcbVacuumCommand : PwmPort;
    port baseVacuumCommand : PwmPort;
    port pcbBmsBus : I2cControllerPort;
    port baseBmsBus : I2cControllerPort;
    port pcbLeftLiftHazard : GpioPort;
    port baseLeftLiftHazard : GpioPort;
    port pcbRightLiftHazard : GpioPort;
    port baseRightLiftHazard : GpioPort;
    port pcbFrontLeftCliffHazard : GpioPort;
    port baseFrontLeftCliffHazard : GpioPort;
    port pcbFrontRightCliffHazard : GpioPort;
    port baseFrontRightCliffHazard : GpioPort;
    port pcbRearLeftCliffHazard : GpioPort;
    port baseRearLeftCliffHazard : GpioPort;
    port pcbRearRightCliffHazard : GpioPort;
    port baseRearRightCliffHazard : GpioPort;
    port pcbCleaningFault : GpioPort;
    port baseCleaningFault : GpioPort;
    port pcbBmsAlert : GpioPort;
    port baseBmsAlert : GpioPort;
    port pcbDockBeaconDetected : GpioPort;
    port baseDockBeaconDetected : GpioPort;

    connect pcbBatteryPower to baseBatteryRail;
    connect pcbLogicPower to baseLogicRail;
    connect pcbLeftPhases to baseLeftPhases;
    connect pcbRightPhases to baseRightPhases;
    connect pcbLeftOdometry to baseLeftOdometry;
    connect pcbRightOdometry to baseRightOdometry;
    connect pcbBrushCommand to baseBrushCommand;
    connect pcbVacuumCommand to baseVacuumCommand;
    connect pcbBmsBus to baseBmsBus;
    connect pcbLeftLiftHazard to baseLeftLiftHazard;
    connect pcbRightLiftHazard to baseRightLiftHazard;
    connect pcbFrontLeftCliffHazard to baseFrontLeftCliffHazard;
    connect pcbFrontRightCliffHazard to baseFrontRightCliffHazard;
    connect pcbRearLeftCliffHazard to baseRearLeftCliffHazard;
    connect pcbRearRightCliffHazard to baseRearRightCliffHazard;
    connect pcbCleaningFault to baseCleaningFault;
    connect pcbBmsAlert to baseBmsAlert;
    connect pcbDockBeaconDetected to baseDockBeaconDetected;
  }

  part def TopWiringHarness :> WiringHarness {
    attribute :>> mass = 0.06 [kg]; /* illustrative estimate */
    part pcbConnector : BoardConnector :> connectors;
    part topConnector : ElectronicConnector :> connectors;

    port pcbSensorBus : I2cControllerPort;
    port topSensorBus : I2cControllerPort;
    port pcbLidarSerial : UartPort;
    port topLidarSerial : UartPort;
    port baseSensorPower : PowerRailPort;
    port topSensorPower : PowerRailPort;
    port pcbBumperHazard : GpioPort;
    port topBumperHazard : GpioPort;
    port pcbHmiControl : LocalHmiControllerPort;
    port topHmiControl : ~LocalHmiControllerPort;

    connect pcbSensorBus to topSensorBus;
    connect pcbLidarSerial to topLidarSerial;
    connect baseSensorPower to topSensorPower;
    connect pcbBumperHazard to topBumperHazard;
    connect pcbHmiControl to topHmiControl;
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
    part baseHarness : BaseWiringHarness;
    part topHarness : TopWiringHarness;
    part firmwareTasks : FirmwareTaskArchitecture;

    connect mainPcb.batteryPower to baseHarness.pcbBatteryPower;
    connect baseHarness.baseBatteryRail to base.batteryRail;
    connect mainPcb.logicPower to baseHarness.pcbLogicPower;
    connect baseHarness.baseLogicRail to base.logicRail;
    connect mainPcb.leftPhases to baseHarness.pcbLeftPhases;
    connect baseHarness.baseLeftPhases to base.leftPhases;
    connect mainPcb.rightPhases to baseHarness.pcbRightPhases;
    connect baseHarness.baseRightPhases to base.rightPhases;
    connect mainPcb.leftOdometry to baseHarness.pcbLeftOdometry;
    connect baseHarness.baseLeftOdometry to base.leftOdometry;
    connect mainPcb.rightOdometry to baseHarness.pcbRightOdometry;
    connect baseHarness.baseRightOdometry to base.rightOdometry;
    connect mainPcb.brushCommand to baseHarness.pcbBrushCommand;
    connect baseHarness.baseBrushCommand to base.brushCommand;
    connect mainPcb.vacuumCommand to baseHarness.pcbVacuumCommand;
    connect baseHarness.baseVacuumCommand to base.vacuumCommand;
    connect mainPcb.bmsBus to baseHarness.pcbBmsBus;
    connect baseHarness.baseBmsBus to base.bmsBus;
    connect mainPcb.leftLiftHazard to baseHarness.pcbLeftLiftHazard;
    connect baseHarness.baseLeftLiftHazard to base.leftLiftHazard;
    connect mainPcb.rightLiftHazard to baseHarness.pcbRightLiftHazard;
    connect baseHarness.baseRightLiftHazard to base.rightLiftHazard;
    connect mainPcb.frontLeftCliffHazard to baseHarness.pcbFrontLeftCliffHazard;
    connect baseHarness.baseFrontLeftCliffHazard to base.frontLeftCliffHazard;
    connect mainPcb.frontRightCliffHazard to baseHarness.pcbFrontRightCliffHazard;
    connect baseHarness.baseFrontRightCliffHazard to base.frontRightCliffHazard;
    connect mainPcb.rearLeftCliffHazard to baseHarness.pcbRearLeftCliffHazard;
    connect baseHarness.baseRearLeftCliffHazard to base.rearLeftCliffHazard;
    connect mainPcb.rearRightCliffHazard to baseHarness.pcbRearRightCliffHazard;
    connect baseHarness.baseRearRightCliffHazard to base.rearRightCliffHazard;
    connect mainPcb.cleaningFault to baseHarness.pcbCleaningFault;
    connect baseHarness.baseCleaningFault to base.cleaningFault;
    connect mainPcb.bmsAlert to baseHarness.pcbBmsAlert;
    connect baseHarness.baseBmsAlert to base.bmsAlert;
    connect mainPcb.dockBeaconDetected to baseHarness.pcbDockBeaconDetected;
    connect baseHarness.baseDockBeaconDetected to base.dockBeaconDetected;

    connect mainPcb.sensorBus to topHarness.pcbSensorBus;
    connect topHarness.topSensorBus to top.sensorBus;
    connect mainPcb.lidarSerial to topHarness.pcbLidarSerial;
    connect topHarness.topLidarSerial to top.lidarSerial;
    connect base.sensorRail to topHarness.baseSensorPower;
    connect topHarness.topSensorPower to top.power;
    connect mainPcb.topBumperHazard to topHarness.pcbBumperHazard;
    connect topHarness.topBumperHazard to top.bumperHazard;
    connect mainPcb.localHmi to topHarness.pcbHmiControl;
    connect topHarness.topHmiControl to top.hmiControl;

    connect dockPower to base.dockPowerInput;
    connect dockBeacon to base.beaconInput;
    connect app to mainPcb.appService;
    connect base.cleaningHead.debrisOut to dustBin.debrisIn;

    connection mainPcbMount : FastenedMount
      connect base to mainPcb;
    connection topMount : SnapFitMount
      connect base to top;
    connection dustBinMount : RemovableMount
      connect base to dustBin;

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
    allocation safetyInputAccess : TaskToPeripheralAccess
      allocate firmwareTasks.safetySupervisor
      to mainPcb.mcu.frontLeftCliffHazard;
    allocation powerBusAccess : TaskToPeripheralAccess
      allocate firmwareTasks.powerManager
      to mainPcb.mcu.bmsSmbus;
    allocation appWirelessAccess : TaskToPeripheralAccess
      allocate firmwareTasks.appService
      to mainPcb.wirelessUart;
  }
}
