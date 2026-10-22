/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package CleaningHeadSystem {
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
    part def CleaningHeadModuleSpecification :> ElectronicsComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
        port power : PowerRailPort;
        port brushCommand : PwmPort;
        port vacuumCommand : PwmPort;
        port fault : GpioPort;
        port debrisOut : CleaningFlowPort;
        attribute mainBrushLongitudinalPosition : LengthValue;
        attribute suctionIntakeLongitudinalPosition : LengthValue;
    }

    part def CleaningHeadModuleArchitecture :> CleaningHeadModuleSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
        part brushTransmission : ComponentProfiles::BrushTransmission::BrushTransmissionSpecification;
        part leftSideBrush : ComponentProfiles::SideBrush::SideBrushSpecification;
        part rightSideBrush : ComponentProfiles::SideBrush::SideBrushSpecification;
        part housing : ComponentProfiles::CleaningHeadHousing::CleaningHeadHousingSpecification;
        part brushMotor : ComponentProfiles::BrushedDcMotor::BrushedDcMotorSpecification;
        part brushDriver : ComponentProfiles::HBridgeMotorDriver::HBridgeMotorDriverSpecification;
        part vacuumMotor : ComponentProfiles::BrushedDcMotor::BrushedDcMotorSpecification;
        part vacuumDriver : ComponentProfiles::HBridgeMotorDriver::HBridgeMotorDriverSpecification;
    }

    part def CleaningHeadModuleIntegration :> CleaningHeadModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part brushTransmission : ComponentProfiles::BrushTransmission::BrushTransmissionArchitecture :>> brushTransmission;
        part leftSideBrush : ComponentProfiles::SideBrush::SideBrushArchitecture :>> leftSideBrush {
              attribute longitudinalPosition : LengthValue = 100 [mm];
              attribute lateralPosition : LengthValue = 125 [mm];
            }
        part rightSideBrush : ComponentProfiles::SideBrush::SideBrushArchitecture :>> rightSideBrush {
              attribute longitudinalPosition : LengthValue = 100 [mm];
              attribute lateralPosition : LengthValue = -125 [mm];
            }
        part housing : ComponentProfiles::CleaningHeadHousing::CleaningHeadHousingArchitecture :>> housing;
        part brushMotor : ComponentProfiles::BrushedDcMotor::BrushedDcMotorArchitecture :>> brushMotor {
              @BomItem { description = "Brush motor, brushed DC, 8 W"; sourcing = SourcingKind::buy; unitCostEur = 1.80; }
              attribute :>> ratedPower = 8 [W]; /* illustrative estimate */
              attribute :>> mass = 0.07 [kg]; /* illustrative estimate */
            }
        part brushDriver : ComponentProfiles::HBridgeMotorDriver::HBridgeMotorDriverArchitecture :>> brushDriver {
              @BomItem { description = "H-bridge motor driver"; sourcing = SourcingKind::buy; unitCostEur = 0.55; }
              attribute :>> mass = 0.002 [kg]; /* illustrative estimate */
            }
        part vacuumMotor : ComponentProfiles::BrushedDcMotor::BrushedDcMotorArchitecture :>> vacuumMotor {
              @BomItem { description = "Vacuum fan motor, brushed DC, 10 W"; sourcing = SourcingKind::buy; unitCostEur = 3.20; }
              attribute :>> ratedPower = 10 [W]; /* illustrative estimate */
              attribute :>> mass = 0.16 [kg]; /* illustrative estimate */
            }
        part vacuumDriver : ComponentProfiles::HBridgeMotorDriver::HBridgeMotorDriverArchitecture :>> vacuumDriver {
              @BomItem { description = "H-bridge motor driver"; sourcing = SourcingKind::buy; unitCostEur = 0.55; }
              attribute :>> mass = 0.002 [kg]; /* illustrative estimate */
            }
        attribute :>> powerDraw = sum(brushMotor.ratedPower, vacuumMotor.ratedPower);
        attribute :>> mass = sum(brushMotor.mass, brushDriver.mass, vacuumMotor.mass, vacuumDriver.mass, housing.mass,
              brushTransmission.mass, leftSideBrush.mass, rightSideBrush.mass);
        doc /* Main roller, suction intake and two forward side brushes share one cleaning head.
                 * Layout coordinates are measured from the drive axle; positive is forward/left.
                 * The 8 W brush motor rating covers the complete brush train (design estimate). */
        attribute :>> mainBrushLongitudinalPosition = 75 [mm];
        attribute :>> suctionIntakeLongitudinalPosition = 55 [mm];
        connect power to brushDriver.supply;
        connect power to vacuumDriver.supply;
        connect brushCommand to brushDriver.command;
        connect vacuumCommand to vacuumDriver.command;
        connect brushDriver.driveOutput to brushMotor.electricalInput;
        connect vacuumDriver.driveOutput to vacuumMotor.electricalInput;
        connect brushMotor.mechanicalOutput to brushTransmission.inputShaft;
        connect brushTransmission.mainRollerOutput to housing.mainBrushAxle;
        connect brushTransmission.leftOutput to leftSideBrush.axle;
        connect brushTransmission.rightOutput to rightSideBrush.axle;
        connect brushDriver.fault to fault;
        connect vacuumDriver.fault to fault;
    }

}
