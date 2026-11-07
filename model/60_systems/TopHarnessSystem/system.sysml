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
    port def TopHarnessBus {
        doc /* The signals the top wiring harness carries between the main board and the top
             * module, as nested ports typed as the main board sees them. The top module uses
             * TopHarnessModuleBus. Sensor power, which comes from the base module, is a port of
             * its own. */
        port sensorBus : ~I2cControllerPort;
        port lidarSerial : ~UartPort;
        port bumperHazard : GpioPort;
        port hmiControl : ~LocalHmiControllerPort;
    }

    port def TopHarnessModuleBus {
        doc /* The signals of the top wiring harness as the module sees them: the mate of the bus the main
             * board uses. Conjugating a bus reverses only its directed features, not its nested
             * ports (SysML v2 7.12), so the module end has a definition of its own. */
        port sensorBus : I2cControllerPort;
        port lidarSerial : UartPort;
        port bumperHazard : GpioPort;
        port hmiControl : LocalHmiControllerPort;
    }

    part def TopWiringHarnessSpecification :> Elan8::Core::PhysicalComponent, Elan8::SystemsEngineering::SystemSpecification {
        // Each end mates with the module it plugs into.
        port mainPcbEnd : TopHarnessModuleBus;
        port topEnd : TopHarnessBus;
        port baseSensorPower : PowerRailPort;
        port topSensorPower : PowerRailPort;
    }

    part def TopWiringHarnessArchitecture :> TopWiringHarnessSpecification, WiringHarness, Elan8::SystemsEngineering::SystemArchitecture {
        part pcbConnector : Elan8::Electronics::Interconnection::BoardConnector :> connectors;
        part topConnector : Elan8::Electronics::Interconnection::ElectronicConnector :> connectors;
        part connectors : Elan8::Electronics::Interconnection::ElectronicConnector [2..*] :>> connectors;
        part conductors : Elan8::Electronics::Interconnection::HarnessConductor [1..*] :>> conductors;
    }

    part def TopWiringHarnessIntegration :> TopWiringHarnessArchitecture, Elan8::SystemsEngineering::SystemIntegration, CostedPart {
        doc /* Top wiring harness with connectors */
        /* illustrative estimate */
            part pcbConnector : Elan8::Electronics::Interconnection::BoardConnector :>> pcbConnector :> connectors;
        part topConnector : Elan8::Electronics::Interconnection::ElectronicConnector :>> topConnector :> connectors;
        part connectors : Elan8::Electronics::Interconnection::ElectronicConnector[2] :>> connectors = (pcbConnector, topConnector);
        part conductors : Elan8::Electronics::Interconnection::HarnessConductor[1..*] :>> conductors;
        @MakePart;
        attribute :>> unitCost = 1.10 [EUR];
        attribute :>> mass = 0.06 [kg];
        connect mainPcbEnd.sensorBus to topEnd.sensorBus;
        connect mainPcbEnd.lidarSerial to topEnd.lidarSerial;
        connect mainPcbEnd.bumperHazard to topEnd.bumperHazard;
        connect mainPcbEnd.hmiControl to topEnd.hmiControl;
        connect baseSensorPower to topSensorPower;
    }


}
