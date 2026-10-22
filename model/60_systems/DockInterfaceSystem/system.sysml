/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package DockInterfaceSystem {
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
    part def DockInterfaceModuleSpecification :> ElectronicsComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
        port dockPowerInput : ~PowerRailPort;
        port chargePowerOutput : PowerRailPort;
        port beaconDetected : GpioPort;
    }

    part def DockInterfaceModuleArchitecture :> DockInterfaceModuleSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
        part contacts : ComponentProfiles::DockContactAssembly::DockContactAssemblySpecification;
        part beaconReceiver : ComponentProfiles::HomingBeaconReceiver::HomingBeaconReceiverSpecification;
    }

    part def DockInterfaceModuleIntegration :> DockInterfaceModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part contacts : ComponentProfiles::DockContactAssembly::DockContactAssemblyArchitecture :>> contacts;
        part beaconReceiver : ComponentProfiles::HomingBeaconReceiver::HomingBeaconReceiverArchitecture :>> beaconReceiver {
              @BomItem { description = "Infrared homing-beacon receiver"; sourcing = SourcingKind::buy; unitCostEur = 0.35; }
              attribute :>> mass = 0.03 [kg]; /* illustrative estimate */
              attribute :>> powerDraw = 0.1 [W]; /* illustrative estimate */
            }
        doc /*
              Robot-side docking interface with charging contacts and an optical
              homing-beacon receiver. The receiver converts the external beacon into
              an internal GPIO indication for the main controller.
            */
        attribute :>> powerDraw = 2 [W];
        attribute :>> mass = sum(beaconReceiver.mass, contacts.mass);
        connect dockPowerInput to chargePowerOutput;
        connect beaconReceiver.detection to beaconDetected;
    }

}
