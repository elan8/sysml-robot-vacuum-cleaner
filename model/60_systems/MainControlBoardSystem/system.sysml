/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package MainControlBoardSystem {
    private import NumericalFunctions::*;
    // sum(...) in the rolled-up mass/power attributes
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
    private import Elan8::Procurement::*;
    private import Elan8::Units::Money::*;
    private import SystemRequirements::*;
    private import Elan8::Software::*;
    private import Elan8::Electronics::Wireless::*;
    private import Elan8::Units::Engineering::*;
    private import ISQ::*;
    private import SI::*;
    private import ScalarValues::*;
    private import FunctionalArchitecture::*;
    private import PhysicalArchitecture::*;
    private import ModuleRequirements::*;
    private import FirmwareLibrary::*;
    private import PhysicalShared::*;
    private import StandardViewDefinitions::*;
    private import ReviewConcerns::*;
    part def MainPcbModuleSpecification :> ElectronicsComponent, Elan8::SystemsEngineering::SystemSpecification {
        port batteryPower : PowerRailPort;
        port logicPower : PowerRailPort;
        port sensorBus : ~I2cControllerPort;
        port lidarSerial : ~UartPort;
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
        attribute driveDisableLatency : DurationValue;
        satisfy Requirements::mainPcbSpecification;
    }
    package Requirements {
        private import ModuleBudgets::*;
        private import RequirementLimits::*;
        private import ISQ::*;
        private import SI::*;
        requirement mainPcbSpecification {
            subject board : MainControlBoardSystem::MainPcbModuleSpecification;

            requirement <'PCB-001'> 'Drive disable latency' {
              require constraint { board.driveDisableLatency <= driveDisableBudget }
              doc /* The main board shall remove drive from both motors within {{= ModuleBudgets::driveDisableBudget}} of the safe-stop command, through a disable line that does not depend on the motion-control loop. */
            }

            requirement <'PCB-002'> 'Main board mass' {
              require constraint { board.mass <= mainPcbMassBudget }
              doc /* The assembled main board shall have a mass of at most {{= ModuleBudgets::mainPcbMassBudget}}. */
            }
          }
    }

    part def MainPcbModuleArchitecture :> MainPcbModuleSpecification, PrintedCircuitBoardAssembly, Elan8::SystemsEngineering::SystemArchitecture {
        part mountedComponents : Elan8::Core::PhysicalComponent[0..*] nonunique :>> mountedComponents;
        part bareBoard : MainControlBoardSystem::RobotControlBoard :>> bareBoard;
        part mcu : ControllerSystem::RobotMainMcuSpecification :> mountedComponents;
        part leftMotorDriver : MainControlBoardSystem::RobotMotorDriver :> mountedComponents;
        part rightMotorDriver : MainControlBoardSystem::RobotMotorDriver :> mountedComponents;
        part wireless : MainControlBoardSystem::RobotWirelessModule :> mountedComponents;
        part wirelessUart : DomainModel::WirelessUartBus;
        part imu : Elan8::Electronics::Sensing::I2cInertialMeasurementUnit :> mountedComponents;
    }

    part def MainPcbModuleIntegration :> MainPcbModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part mountedComponents : Elan8::Core::PhysicalComponent[5] nonunique :>> mountedComponents = (mcu, leftMotorDriver, rightMotorDriver, wireless, imu);
        part bareBoard : MainControlBoardSystem::RobotControlBoard :>> bareBoard;
        part mcu : ControllerSystem::RobotMainMcuIntegration :>> mcu :> mountedComponents;
        part leftMotorDriver : MainControlBoardSystem::RobotMotorDriver :>> leftMotorDriver :> mountedComponents;
        part rightMotorDriver : MainControlBoardSystem::RobotMotorDriver :>> rightMotorDriver :> mountedComponents;
        part wireless : MainControlBoardSystem::RobotWirelessModule :>> wireless :> mountedComponents;
        part wirelessUart : DomainModel::WirelessUartBus :>> wirelessUart;
        part imu : MainControlBoardSystem::RobotImu :>> imu :> mountedComponents {
              attribute :>> mass = 0.03 [kg]; /* illustrative estimate — unchanged from prior SensorAssembly.imu */
              attribute :>> powerDraw = 0.2 [W]; /* illustrative estimate — unchanged from prior SensorAssembly.imu */
            }
        attribute :>> powerDraw =
              sum(mcu.powerDraw, leftMotorDriver.powerDraw, rightMotorDriver.powerDraw,
                  wireless.powerDraw, imu.powerDraw);
        attribute :>> mass =
              sum(mcu.mass, leftMotorDriver.mass, rightMotorDriver.mass, wireless.mass,
                  imu.mass, bareBoard.mass);
        attribute :>> driveDisableLatency = 2 [ms];
        /* gate-driver disable input, hardware path */
            doc /*
              bareBoard.mass covers PCB substrate, connectors, and passives not individually
              modeled. Merges the former MainControlPcb + MainElectronicsAssembly wrapper
              into one module — Base and Top now form the real enclosure, so a separate
              PCB-housing level is no longer needed.
            */
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

    package Views {
        view mainPcbDecomposition : GeneralView {
            doc /* Which board and electronic components constitute this robot's main PCB assembly? Show the
             * bare board, MCU, two motor drivers, IMU, wireless module and wireless link in this
             * assembly context. Procurement choices and circuit routing are outside this view. */
            satisfy productStructurePerspective;
            filter @SysML::PartUsage;
            filter not @SysML::ConnectionUsage;
            filter not @SysML::AllocationUsage;
            expose VacuumCleanerSystem::robotSystem.physical.mainPcb;
          }
    }

    part def RobotMotorDriver :> ThreePhaseMotorDriver, CostedPart {
        doc /* Three-phase motor driver */
        @BuyPart;
        attribute :>> unitCost = 2.30 [EUR];
        attribute :>> mass = 0.005 [kg];
        /* illustrative estimate */
        attribute :>> powerDraw = 1.5 [W];
        /* illustrative estimate */
        dependency selectedImplementation
            from RobotMotorDriver to DRV8316R;
    }

    part def RobotWirelessModule :> WirelessModule, CostedPart {
        doc /* Wi-Fi and Bluetooth LE module */
        /* illustrative estimate */
        port hostLink : UartPort :>> hostLink;
        port robotService : RobotServicePort;
        @BuyPart;
        attribute :>> unitCost = 1.50 [EUR];
        attribute :>> mass = 0.005 [kg];
        /* illustrative estimate */
        attribute :>> powerDraw = 1 [W];
        dependency selectedImplementation
            from RobotWirelessModule to ESP32C3MINI1;
    }

    part def RobotControlBoard :> PrintedCircuitBoard, CostedPart {
        doc /* Main control board, bare PCB with passives and connectors */
        @MakePart;
        attribute :>> unitCost = 3.40 [EUR];
        attribute :>> mass = 0.155 [kg];
    }

    part def RobotImu :> Elan8::Electronics::Sensing::I2cInertialMeasurementUnit, CostedPart {
        doc /* Inertial measurement unit, 6-axis */
        @BuyPart;
        attribute :>> unitCost = 1.40 [EUR];
    }
}
