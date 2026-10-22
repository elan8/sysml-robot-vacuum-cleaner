/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package BaseSystem {
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
    part def BaseModuleSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
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
        attribute cliffSensingLatency : DurationValue;
        attribute brakingTime : DurationValue;
        attribute height : LengthValue;
        attribute baseElectronicsPowerDraw : PowerValue;
        attribute nominalBodyDiameter : LengthValue;
        attribute batteryCapacity : ElectricChargeValue;
        attribute chargeCurrent : ElectricCurrentValue;
        satisfy Requirements::baseModuleSpecification;
    }
    package Requirements {
        private import ModuleBudgets::*;
        private import RequirementLimits::*;
        private import ISQ::*;
        private import SI::*;
        requirement baseModuleSpecification {
            subject base : BaseSystem::BaseModuleSpecification;

            requirement <'BASE-001'> 'Cliff sensing latency' {
              require constraint { base.cliffSensingLatency <= cliffSensingBudget }
              doc /* The base module shall assert a cliff or wheel-drop hazard signal within {{= ModuleBudgets::cliffSensingBudget}} of the hazard appearing under a sensor. */
            }

            requirement <'BASE-002'> 'Drive braking time' {
              require constraint { base.brakingTime <= brakingBudget }
              doc /* The base module shall bring both drive wheels to standstill within {{= ModuleBudgets::brakingBudget}} of the drive outputs being disabled at cleaning speed. */
            }

            requirement <'BASE-003'> 'Base module mass' {
              require constraint { base.mass <= baseMassBudget }
              doc /* The base module shall have a mass of at most {{= ModuleBudgets::baseMassBudget}} including the battery pack. */
            }

            requirement <'BASE-004'> 'Base module height' {
              require constraint { base.height <= baseHeightBudget }
              doc /* The base module shall be at most {{= ModuleBudgets::baseHeightBudget}} high from the floor to the parting line with the top module. */
            }

            requirement <'BASE-005'> 'Battery capacity' {
              require constraint { base.batteryCapacity >= minBatteryCapacity }
              doc /* The power module shall hold a battery pack with a rated capacity of at least {{= ModuleBudgets::minBatteryCapacity}}. */
            }

            requirement <'BASE-006'> 'Charge current' {
              require constraint { base.chargeCurrent >= minChargeCurrent }
              doc /* The power module shall charge the battery pack with at least {{= ModuleBudgets::minChargeCurrent}} in the constant-current phase. */
            }
          }
    }

    part def BaseModuleArchitecture :> BaseModuleSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
        part chassis : ComponentProfiles::Chassis::ChassisSpecification;
        part leftDriveTrain : DriveTrainSystem::DriveTrainSpecification;
        part rightDriveTrain : DriveTrainSystem::DriveTrainSpecification;
        part casterWheel : ComponentProfiles::CasterWheel::CasterWheelSpecification;
        part frontLeftCliff : ComponentProfiles::CliffSensor::CliffSensorSpecification;
        part frontRightCliff : ComponentProfiles::CliffSensor::CliffSensorSpecification;
        part rearLeftCliff : ComponentProfiles::CliffSensor::CliffSensorSpecification;
        part rearRightCliff : ComponentProfiles::CliffSensor::CliffSensorSpecification;
        part cleaningHead : CleaningHeadSystem::CleaningHeadModuleSpecification;
        part powerModule : PowerSystem::PowerModuleSpecification;
        part dockInterface : DockInterfaceSystem::DockInterfaceModuleSpecification;
    }

    part def BaseModuleIntegration :> BaseModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part chassis : ComponentProfiles::Chassis::ChassisArchitecture :>> chassis;
        part leftDriveTrain : DriveTrainSystem::DriveTrainIntegration :>> leftDriveTrain;
        part rightDriveTrain : DriveTrainSystem::DriveTrainIntegration :>> rightDriveTrain;
        part casterWheel : ComponentProfiles::CasterWheel::CasterWheelArchitecture :>> casterWheel {
              doc /* Rear support: always aft of the main roller and suction intake in the
                   * normal forward cleaning direction. Positive longitudinal position is forward. */
              attribute longitudinalPosition : LengthValue = -140 [mm];
              @BomItem { description = "Rear caster wheel"; sourcing = SourcingKind::buy; unitCostEur = 0.60; }
              attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
            }
        part frontLeftCliff : ComponentProfiles::CliffSensor::CliffSensorArchitecture :>> frontLeftCliff;
        part frontRightCliff : ComponentProfiles::CliffSensor::CliffSensorArchitecture :>> frontRightCliff;
        part rearLeftCliff : ComponentProfiles::CliffSensor::CliffSensorArchitecture :>> rearLeftCliff;
        part rearRightCliff : ComponentProfiles::CliffSensor::CliffSensorArchitecture :>> rearRightCliff;
        part cleaningHead : CleaningHeadSystem::CleaningHeadModuleIntegration :>> cleaningHead;
        part powerModule : PowerSystem::PowerModuleIntegration :>> powerModule;
        part dockInterface : DockInterfaceSystem::DockInterfaceModuleIntegration :>> dockInterface;
        attribute :>> mass = sum(
              chassis.mass, leftDriveTrain.mass, rightDriveTrain.mass, casterWheel.mass,
              frontLeftCliff.mass, frontRightCliff.mass, rearLeftCliff.mass, rearRightCliff.mass,
              cleaningHead.mass, powerModule.mass, dockInterface.mass
            );
        attribute :>> cliffSensingLatency = 20 [ms];
        /* 100 Hz sampling, two-sample debounce */
            attribute :>> brakingTime = 40 [ms];
        /* active short-circuit braking at 0.3 m/s */
            attribute :>> height = 55 [mm];
        attribute :>> baseElectronicsPowerDraw = sum(
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
        attribute :>> nominalBodyDiameter = 340 [mm];
        assert constraint casterBehindCleaningHead {
              casterWheel.longitudinalPosition < cleaningHead.mainBrushLongitudinalPosition
                and casterWheel.longitudinalPosition < cleaningHead.suctionIntakeLongitudinalPosition
            }
        assert constraint sideBrushesAheadOfMainRoller {
              cleaningHead.leftSideBrush.longitudinalPosition > cleaningHead.mainBrushLongitudinalPosition
                and cleaningHead.rightSideBrush.longitudinalPosition > cleaningHead.mainBrushLongitudinalPosition
            }
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
        attribute :>> batteryCapacity = powerModule.battery.nominalCapacity;
        attribute :>> chargeCurrent = powerModule.charger.maxChargeCurrent;
    }

    package Views {
        view baseDecomposition : GeneralView {
            doc /* Which components constitute this robot's base? Show the chassis, two drive trains, rear caster,
             * four cliff sensors, cleaning head (main roller, suction and two side brushes), power module
             * and dock interface in their base context.
             * Electrical routing belongs in interconnections, not in this composition view. */
            satisfy productStructurePerspective;
            filter @SysML::PartUsage;
            filter not @SysML::ConnectionUsage;
            filter not @SysML::AllocationUsage;
            expose VacuumCleanerSystem::robotSystem.physical.base;
          }
    }
}
