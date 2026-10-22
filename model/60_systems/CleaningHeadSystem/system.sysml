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
    part def CleaningHeadModuleSpecification :> ElectronicsComponent, Elan8::SystemsEngineering::SystemSpecification {
        port power : PowerRailPort;
        port brushCommand : PwmPort;
        port vacuumCommand : PwmPort;
        port fault : GpioPort;
        port debrisOut : CleaningFlowPort;
        attribute mainBrushLongitudinalPosition : LengthValue;
        attribute suctionIntakeLongitudinalPosition : LengthValue;
    }

    part def CleaningHeadModuleArchitecture :> CleaningHeadModuleSpecification, Elan8::SystemsEngineering::SystemArchitecture {
        part brushTransmission : CleaningHeadSystem::BrushTransmission;
        part leftSideBrush : CleaningHeadSystem::SideBrush;
        part rightSideBrush : CleaningHeadSystem::SideBrush;
        part housing : CleaningHeadSystem::CleaningHeadHousing;
        part brushMotor : Elan8::Electronics::Actuation::BrushedDcMotor;
        part brushDriver : Elan8::Electronics::Actuation::HBridgeMotorDriver;
        part vacuumMotor : Elan8::Electronics::Actuation::BrushedDcMotor;
        part vacuumDriver : Elan8::Electronics::Actuation::HBridgeMotorDriver;
    }

    part def CleaningHeadModuleIntegration :> CleaningHeadModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part brushTransmission : CleaningHeadSystem::BrushTransmission :>> brushTransmission;
        part leftSideBrush : CleaningHeadSystem::SideBrush :>> leftSideBrush {
              attribute longitudinalPosition : LengthValue = 100 [mm];
              attribute lateralPosition : LengthValue = 125 [mm];
            }
        part rightSideBrush : CleaningHeadSystem::SideBrush :>> rightSideBrush {
              attribute longitudinalPosition : LengthValue = 100 [mm];
              attribute lateralPosition : LengthValue = -125 [mm];
            }
        part housing : CleaningHeadSystem::CleaningHeadHousing :>> housing;
        part brushMotor : Elan8::Electronics::Actuation::BrushedDcMotor :>> brushMotor {
              @BomItem { description = "Brush motor, brushed DC, 8 W"; sourcing = SourcingKind::buy; unitCostEur = 1.80; }
              attribute :>> ratedPower = 8 [W]; /* illustrative estimate */
              attribute :>> mass = 0.07 [kg]; /* illustrative estimate */
            }
        part brushDriver : Elan8::Electronics::Actuation::HBridgeMotorDriver :>> brushDriver {
              @BomItem { description = "H-bridge motor driver"; sourcing = SourcingKind::buy; unitCostEur = 0.55; }
              attribute :>> mass = 0.002 [kg]; /* illustrative estimate */
            }
        part vacuumMotor : Elan8::Electronics::Actuation::BrushedDcMotor :>> vacuumMotor {
              @BomItem { description = "Vacuum fan motor, brushed DC, 10 W"; sourcing = SourcingKind::buy; unitCostEur = 3.20; }
              attribute :>> ratedPower = 10 [W]; /* illustrative estimate */
              attribute :>> mass = 0.16 [kg]; /* illustrative estimate */
            }
        part vacuumDriver : Elan8::Electronics::Actuation::HBridgeMotorDriver :>> vacuumDriver {
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

    part def CleaningHeadHousing :> MechanicalComponent {
        /* illustrative estimate */
        port mainBrushAxle : RotationalMechanicalPort;
        doc /* Brush chamber with main roller, suction duct and impeller housing. */
        @BomItem { description = "Cleaning head housing with main brush and duct"; sourcing = SourcingKind::make; unitCostEur = 2.60; }
        attribute :>> mass = 0.4 [kg];
    }

    part def SideBrush :> MechanicalComponent {
        port axle : RotationalMechanicalPort;
        attribute sweptDiameter : LengthValue = 80 [mm];
        doc /* Three-arm edge-sweeping brush, mechanically driven by the shared brush motor.
        * Left and right outputs counter-rotate to sweep debris towards the main roller. */
        @BomItem { description = "Side brush, three-arm"; sourcing = SourcingKind::make; unitCostEur = 0.30; }
        attribute :>> mass = 0.015 [kg];
        /* illustrative estimate */
    }

    part def BrushTransmission :> MechanicalComponent {
        /* illustrative estimate */
        port inputShaft : RotationalMechanicalPort;
        port mainRollerOutput : RotationalMechanicalPort;
        port leftOutput : RotationalMechanicalPort;
        port rightOutput : RotationalMechanicalPort;
        doc /* Belt and gear transmission from the brush motor to the main roller and both side
        * brushes. The mirrored side outputs sweep inward; no independent brush motors. */
        @BomItem { description = "Brush belt and gear transmission"; sourcing = SourcingKind::make; unitCostEur = 0.60; }
        attribute :>> mass = 0.03 [kg];
    }
}
