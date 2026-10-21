/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package DriveTrainSystem {
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
        part def DriveTrainSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            port phases : ThreePhaseDrivePort;
            port odometry : QuadratureEncoderPort;
            port liftHazard : GpioPort;
        }
    }
    package Architecture {
        part def DriveTrainArchitecture :> Specification::DriveTrainSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            part motor : ComponentProfiles::DriveMotor::Specification::DriveMotorSpecification;
            part gearbox : ComponentProfiles::Gearbox::Specification::GearboxSpecification;
            part wheel : ComponentProfiles::Wheel::Specification::WheelSpecification;
            part encoder : ComponentProfiles::QuadratureEncoder::Specification::QuadratureEncoderSpecification;
            part lift : ComponentProfiles::LiftSwitch::Specification::LiftSwitchSpecification;
        }
    }
    package Integration {
        part def DriveTrainIntegration :> Architecture::DriveTrainArchitecture, Elan8::SystemsEngineering::SystemIntegration {
            part motor : ComponentProfiles::DriveMotor::Architecture::DriveMotorArchitecture :>> motor;
            part gearbox : ComponentProfiles::Gearbox::Architecture::GearboxArchitecture :>> gearbox {
                  @BomItem { description = "Planetary gearbox, 30:1"; sourcing = SourcingKind::buy; unitCostEur = 1.60; }
                  attribute :>> gearRatio = 30 [one]; /* illustrative estimate */
                  attribute :>> mass = 0.15 [kg]; /* illustrative estimate */
                }
            part wheel : ComponentProfiles::Wheel::Architecture::WheelArchitecture :>> wheel {
                  @BomItem { description = "Drive wheel with tyre, 65 mm"; sourcing = SourcingKind::make; unitCostEur = 0.90; }
                  attribute :>> diameter = 65 [mm]; /* illustrative estimate */
                  attribute :>> mass = 0.08 [kg]; /* illustrative estimate */
                }
            part encoder : ComponentProfiles::QuadratureEncoder::Architecture::QuadratureEncoderArchitecture :>> encoder {
                  @BomItem { description = "Quadrature encoder, magnetic"; sourcing = SourcingKind::buy; unitCostEur = 0.70; }
                  attribute :>> mass = 0.005 [kg]; /* illustrative estimate */
                }
            part lift : ComponentProfiles::LiftSwitch::Architecture::LiftSwitchArchitecture :>> lift {
                  @BomItem { description = "Wheel-drop switch"; sourcing = SourcingKind::buy; unitCostEur = 0.15; }
                  attribute :>> mass = 0.01 [kg]; /* illustrative estimate */
                }
            attribute :>> mass =
                  sum(motor.mass, gearbox.mass, wheel.mass, encoder.mass, lift.mass);
            connect motor.electricalInput to phases;
            connect motor.mechanicalOutput to gearbox.rotationalInput;
            connect gearbox.rotationalOutput to wheel.axle;
            connect encoder.odometry to odometry;
            connect lift.signal to liftHazard;
        }
    }
}
