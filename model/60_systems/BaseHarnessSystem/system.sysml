/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package BaseHarnessSystem {
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
        part def BaseWiringHarnessSpecification :> Elan8::Core::PhysicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
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
        }
    }
    package Architecture {
        part def BaseWiringHarnessArchitecture :> Specification::BaseWiringHarnessSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, WiringHarness, Elan8::SystemsEngineering::SystemArchitecture {
            part pcbConnector : ComponentProfiles::BoardConnector::Specification::BoardConnectorSpecification :> connectors;
            part baseConnector : ComponentProfiles::ElectronicConnector::Specification::ElectronicConnectorSpecification :> connectors;
            part connectors : ComponentProfiles::ElectronicConnector::Specification::ElectronicConnectorSpecification [2..*] :>> connectors;
            part conductors : ComponentProfiles::HarnessConductor::Specification::HarnessConductorSpecification [1..*] :>> conductors;
        }
    }
    package Integration {
        part def BaseWiringHarnessIntegration :> Architecture::BaseWiringHarnessArchitecture, Elan8::SystemsEngineering::SystemIntegration {
            /* illustrative estimate */
                part pcbConnector : ComponentProfiles::BoardConnector::Architecture::BoardConnectorArchitecture :>> pcbConnector :> connectors;
            part baseConnector : ComponentProfiles::ElectronicConnector::Architecture::ElectronicConnectorArchitecture :>> baseConnector :> connectors;
            part connectors : ComponentProfiles::ElectronicConnector::Architecture::ElectronicConnectorArchitecture[2] :>> connectors = (pcbConnector, baseConnector);
            part conductors : ComponentProfiles::HarnessConductor::Architecture::HarnessConductorArchitecture[1..*] :>> conductors;
            @BomItem { description = "Base wiring harness with connectors"; sourcing = SourcingKind::make; unitCostEur = 1.90; }
            attribute :>> mass = 0.12 [kg];
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
    }
}
