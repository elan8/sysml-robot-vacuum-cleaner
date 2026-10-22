/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package PowerSystem {
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
    part def PowerModuleSpecification :> ElectronicsComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
        port batteryRail : PowerRailPort;
        port logicRail : PowerRailPort;
        port sensorRail : PowerRailPort;
        port bmsBus : ~I2cControllerPort;
        port bmsAlert : GpioPort;
        attribute batteryRailBudget : PowerRailBudget;
        attribute logicRailBudget : PowerRailBudget;
        attribute sensorRailBudget : PowerRailBudget;
    }

    part def PowerModuleArchitecture :> PowerModuleSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
        part battery : ComponentProfiles::BatteryPack::BatteryPackSpecification;
        part charger : ComponentProfiles::RobotBatteryCharger::RobotBatteryChargerSpecification;
        part bms : ComponentProfiles::RobotBms::RobotBmsSpecification;
        part logicRegulator : ComponentProfiles::VoltageRegulator::VoltageRegulatorSpecification;
        part sensorRegulator : ComponentProfiles::VoltageRegulator::VoltageRegulatorSpecification;
        part smbus : ComponentProfiles::BmsSmbusBus::BmsSmbusBusSpecification;
    }

    part def PowerModuleIntegration :> PowerModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part battery : ComponentProfiles::BatteryPack::BatteryPackArchitecture :>> battery {
              @BomItem { description = "Lithium-ion battery pack, 4S2P, 14.4 V"; sourcing = SourcingKind::buy; unitCostEur = 16.00; }
              attribute :>> nominalCapacity = 6400 [mAh];
              attribute :>> nominalVoltage = 14.4 [V];
              attribute :>> mass = 0.50 [kg]; /* eight 18650 cells and pack hardware */
            }
        part charger : ComponentProfiles::RobotBatteryCharger::RobotBatteryChargerArchitecture :>> charger;
        part bms : ComponentProfiles::RobotBms::RobotBmsArchitecture :>> bms;
        part logicRegulator : ComponentProfiles::VoltageRegulator::VoltageRegulatorArchitecture :>> logicRegulator {
              @BomItem { description = "Buck regulator, 3.3 V"; sourcing = SourcingKind::buy; unitCostEur = 0.40; }
              attribute :>> outputVoltage = 3.3 [V];
              attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
              attribute :>> quiescentPower = 1 [W]; /* illustrative estimate */
            }
        part sensorRegulator : ComponentProfiles::VoltageRegulator::VoltageRegulatorArchitecture :>> sensorRegulator {
              @BomItem { description = "Buck regulator, 5 V"; sourcing = SourcingKind::buy; unitCostEur = 0.40; }
              attribute :>> outputVoltage = 5 [V];
              attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
              attribute :>> quiescentPower = 1 [W]; /* illustrative estimate */
            }
        part smbus : ComponentProfiles::BmsSmbusBus::BmsSmbusBusArchitecture :>> smbus;
        attribute :>> powerDraw =
              sum(charger.quiescentPower, bms.quiescentPower,
                  logicRegulator.quiescentPower, sensorRegulator.quiescentPower);
        attribute :>> mass =
              sum(battery.mass, charger.mass, bms.mass,
                  logicRegulator.mass, sensorRegulator.mass);
        attribute :>> batteryRailBudget {
              attribute :>> nominalVoltage = 14.4 [V];
              attribute :>> continuousCurrentBudget = 5 [A];
              attribute :>> peakCurrentBudget = 8 [A];
            }
        attribute :>> logicRailBudget {
              attribute :>> nominalVoltage = 3.3 [V];
              attribute :>> continuousCurrentBudget = 1 [A];
              attribute :>> peakCurrentBudget = 1.5 [A];
            }
        attribute :>> sensorRailBudget {
              attribute :>> nominalVoltage = 5 [V];
              attribute :>> continuousCurrentBudget = 0.8 [A];
              attribute :>> peakCurrentBudget = 1.2 [A];
            }
        connect charger.chargeOutput to bms.chargeInput;
        connect battery.terminal to bms.batteryTerminal;
        connect bms.protectedOutput to batteryRail;
        connect bms.protectedOutput to logicRegulator.input;
        connect bms.protectedOutput to sensorRegulator.input;
        connect logicRegulator.output to logicRail;
        connect sensorRegulator.output to sensorRail;
        connect bmsBus to smbus.host;
        connect bms.bus to smbus.bms;
        connect bms.alert to bmsAlert;
    }

    package Views {
        view powerDecomposition : GeneralView {
            doc /* Which components constitute this robot's power module? Show the battery, BMS, charger, two
             * regulators and SMBus in this power-module context. This view answers composition; the
             * document's power-module interconnection view answers how protected power is distributed. */
            satisfy productStructurePerspective;
            filter @SysML::PartUsage;
            filter not @SysML::ConnectionUsage;
            filter not @SysML::AllocationUsage;
            expose VacuumCleanerSystem::robotSystem.physical.base.powerModule;
          }
    }
}
