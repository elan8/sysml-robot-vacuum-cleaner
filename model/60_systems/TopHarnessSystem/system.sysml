/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package TopHarnessSystem {
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
    part def TopWiringHarnessSpecification :> Elan8::Core::PhysicalComponent, Elan8::SystemsEngineering::SystemSpecification {
        port pcbSensorBus : I2cControllerPort;
        port topSensorBus : I2cControllerPort;
        port pcbLidarSerial : UartPort;
        port topLidarSerial : ~UartPort;
        port baseSensorPower : PowerRailPort;
        port topSensorPower : PowerRailPort;
        port pcbBumperHazard : GpioPort;
        port topBumperHazard : GpioPort;
        port pcbHmiControl : LocalHmiControllerPort;
        port topHmiControl : ~LocalHmiControllerPort;
    }

    part def TopWiringHarnessArchitecture :> TopWiringHarnessSpecification, WiringHarness, Elan8::SystemsEngineering::SystemArchitecture {
        part pcbConnector : Elan8::Electronics::Interconnection::BoardConnector :> connectors;
        part topConnector : Elan8::Electronics::Interconnection::ElectronicConnector :> connectors;
        part connectors : Elan8::Electronics::Interconnection::ElectronicConnector [2..*] :>> connectors;
        part conductors : Elan8::Electronics::Interconnection::HarnessConductor [1..*] :>> conductors;
    }

    part def TopWiringHarnessIntegration :> TopWiringHarnessArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        /* illustrative estimate */
            part pcbConnector : Elan8::Electronics::Interconnection::BoardConnector :>> pcbConnector :> connectors;
        part topConnector : Elan8::Electronics::Interconnection::ElectronicConnector :>> topConnector :> connectors;
        part connectors : Elan8::Electronics::Interconnection::ElectronicConnector[2] :>> connectors = (pcbConnector, topConnector);
        part conductors : Elan8::Electronics::Interconnection::HarnessConductor[1..*] :>> conductors;
        @BomItem { description = "Top wiring harness with connectors"; sourcing = SourcingKind::make; unitCostEur = 1.10; }
        attribute :>> mass = 0.06 [kg];
        connect pcbSensorBus to topSensorBus;
        connect pcbLidarSerial to topLidarSerial;
        connect baseSensorPower to topSensorPower;
        connect pcbBumperHazard to topBumperHazard;
        connect pcbHmiControl to topHmiControl;
    }

}
