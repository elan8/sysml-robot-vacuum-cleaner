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
    part def DriveTrainSpecification :> MechanicalComponent, Elan8::SystemsEngineering::SystemSpecification {
        port phases : ThreePhaseDrivePort;
        port odometry : QuadratureEncoderPort;
        port liftHazard : GpioPort;
    }

    part def DriveTrainArchitecture :> DriveTrainSpecification, Elan8::SystemsEngineering::SystemArchitecture {
        part motor : DriveTrainSystem::DriveMotor;
        part gearbox : Elan8::Mechanical::Drivetrain::Gearbox;
        part wheel : Elan8::Mechanical::Drivetrain::Wheel;
        part encoder : Elan8::Electronics::Sensing::QuadratureEncoder;
        part lift : DomainModel::LiftSwitch;
    }

    part def DriveTrainIntegration :> DriveTrainArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part motor : DriveTrainSystem::DriveMotor :>> motor;
        part gearbox : DriveTrainSystem::DriveGearbox :>> gearbox {
              attribute :>> gearRatio = 30 [one]; /* illustrative estimate */
              attribute :>> mass = 0.15 [kg]; /* illustrative estimate */
            }
        part wheel : DriveTrainSystem::DriveWheel :>> wheel {
              attribute :>> diameter = 65 [mm]; /* illustrative estimate */
              attribute :>> mass = 0.08 [kg]; /* illustrative estimate */
            }
        part encoder : DriveTrainSystem::WheelEncoder :>> encoder {
              attribute :>> mass = 0.005 [kg]; /* illustrative estimate */
            }
        part lift : DriveTrainSystem::WheelDropSwitch :>> lift {
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

    part def DriveMotor :> BldcMotor, CostedPart {
        doc /* Drive motor, brushless DC, 14 W */
        @BuyPart;
        attribute :>> unitCost = 4.80 [EUR];
        attribute :>> ratedPower = 14 [W];
        attribute :>> mass = 0.14 [kg];
    }

    part def DriveGearbox :> Elan8::Mechanical::Drivetrain::Gearbox, CostedPart {
        doc /* Planetary gearbox, 30:1 */
        @BuyPart;
        attribute :>> unitCost = 1.60 [EUR];
    }

    part def DriveWheel :> Elan8::Mechanical::Drivetrain::Wheel, CostedPart {
        doc /* Drive wheel with tyre, 65 mm */
        @MakePart;
        attribute :>> unitCost = 0.90 [EUR];
    }

    part def WheelEncoder :> Elan8::Electronics::Sensing::QuadratureEncoder, CostedPart {
        doc /* Quadrature encoder, magnetic */
        @BuyPart;
        attribute :>> unitCost = 0.70 [EUR];
    }

    part def WheelDropSwitch :> DomainModel::LiftSwitch, CostedPart {
        doc /* Wheel-drop switch */
        @BuyPart;
        attribute :>> unitCost = 0.15 [EUR];
    }
}
