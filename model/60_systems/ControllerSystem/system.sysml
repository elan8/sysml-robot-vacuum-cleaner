/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package ControllerSystem {
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
    private import Sourcing::*;
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
    package Specification {
        part def RobotMainMcuSpecification :> ElectronicsComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            /* illustrative estimate */
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
            port power : ~PowerRailPort;
        }
    }
    package Architecture {
        part def RobotMainMcuArchitecture :> Specification::RobotMainMcuSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Microcontroller, Elan8::SystemsEngineering::SystemArchitecture {
            part memories : ComponentProfiles::MemoryBlock::Specification::MemoryBlockSpecification [0..*] :>> memories;
            part peripherals : ComponentProfiles::PeripheralBlock::Specification::PeripheralBlockSpecification [0..*] :>> peripherals;
            port power : ~PowerRailPort :>> Specification::RobotMainMcuSpecification::power, Microcontroller::power;
        }
    }
    package Integration {
        part def RobotMainMcuIntegration :> Architecture::RobotMainMcuArchitecture, Elan8::SystemsEngineering::SystemIntegration {
            part memories : ComponentProfiles::MemoryBlock::Architecture::MemoryBlockArchitecture[0..*] :>> memories;
            part peripherals : ComponentProfiles::PeripheralBlock::Architecture::PeripheralBlockArchitecture[0..*] :>> peripherals;
            @BomItem { description = "Main microcontroller"; sourcing = SourcingKind::buy; unitCostEur = 4.60; }
            attribute :>> mass = 0.01 [kg];
            /* illustrative estimate */
                attribute :>> powerDraw = 3 [W];
            dependency selectedImplementation
                  from RobotMainMcuIntegration to STM32U575VGT6;
        }
    }
}
