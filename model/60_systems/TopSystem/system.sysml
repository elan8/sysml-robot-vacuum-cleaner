/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package TopSystem {
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
        part def TopModuleSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            port sensorBus : I2cControllerPort;
            port lidarSerial : UartPort;
            port power : PowerRailPort;
            port bumperHazard : GpioPort;
            port hmiControl : LocalHmiControllerPort;
            attribute height : LengthValue;
            attribute topElectronicsPowerDraw : PowerValue;
            satisfy Requirements::topModuleSpecification;
        }
        package Requirements {
            private import ModuleBudgets::*;
            private import RequirementLimits::*;
            private import ISQ::*;
            private import SI::*;
            requirement topModuleSpecification {
                subject top : TopSystem::Specification::TopModuleSpecification;

                requirement <'TOP-001'> 'Top module height' {
                  require constraint { top.height <= topHeightBudget }
                  doc /* The top module shall rise at most {{= ModuleBudgets::topHeightBudget}} above the parting line, including the laser scanner turret. */
                }

                requirement <'TOP-002'> 'Top module mass' {
                  require constraint { top.mass <= topMassBudget }
                  doc /* The top module shall have a mass of at most {{= ModuleBudgets::topMassBudget}}. */
                }
              }
        }
    }
    package Architecture {
        part def TopModuleArchitecture :> Specification::TopModuleSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            part shell : ComponentProfiles::TopShell::Specification::TopShellSpecification;
            part lidar : ComponentProfiles::RobotLidar::Specification::RobotLidarSpecification;
            part frontTof : ComponentProfiles::RobotTofSensor::Specification::RobotTofSensorSpecification;
            part leftTof : ComponentProfiles::RobotTofSensor::Specification::RobotTofSensorSpecification;
            part rightTof : ComponentProfiles::RobotTofSensor::Specification::RobotTofSensorSpecification;
            part frontBumper : ComponentProfiles::BumperSwitch::Specification::BumperSwitchSpecification;
            part hmi : ComponentProfiles::HumanMachineInterface::Specification::HumanMachineInterfaceSpecification;
            part i2c : ComponentProfiles::SensorI2cBus::Specification::SensorI2cBusSpecification;
            part uart : ComponentProfiles::LidarUartBus::Specification::LidarUartBusSpecification;
        }
    }
    package Integration {
        part def TopModuleIntegration :> Architecture::TopModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
            part shell : ComponentProfiles::TopShell::Architecture::TopShellArchitecture :>> shell;
            part lidar : ComponentProfiles::RobotLidar::Architecture::RobotLidarArchitecture :>> lidar;
            part frontTof : ComponentProfiles::RobotTofSensor::Architecture::RobotTofSensorArchitecture :>> frontTof;
            part leftTof : ComponentProfiles::RobotTofSensor::Architecture::RobotTofSensorArchitecture :>> leftTof;
            part rightTof : ComponentProfiles::RobotTofSensor::Architecture::RobotTofSensorArchitecture :>> rightTof;
            part frontBumper : ComponentProfiles::BumperSwitch::Architecture::BumperSwitchArchitecture :>> frontBumper {
                  @BomItem { description = "Bumper switch assembly"; sourcing = SourcingKind::buy; unitCostEur = 0.20; }
                  attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
                }
            part hmi : ComponentProfiles::HumanMachineInterface::Architecture::HumanMachineInterfaceArchitecture :>> hmi;
            part i2c : ComponentProfiles::SensorI2cBus::Architecture::SensorI2cBusArchitecture :>> i2c;
            part uart : ComponentProfiles::LidarUartBus::Architecture::LidarUartBusArchitecture :>> uart;
            attribute :>> mass = sum(
                  lidar.mass, frontTof.mass, leftTof.mass, rightTof.mass,
                  frontBumper.mass, hmi.mass, shell.mass
                );
            attribute :>> height = 37 [mm];
            /* shell 12 mm, scanner turret 25 mm */
                attribute :>> topElectronicsPowerDraw = sum(
                  lidar.powerDraw, frontTof.powerDraw, leftTof.powerDraw, rightTof.powerDraw,
                  hmi.powerDraw
                );
            doc /*
                  topElectronicsPowerDraw is an ordinary (non-inherited) attribute, not an
                  ElectronicsComponent::powerDraw override — TopModule specializes
                  MechanicalComponent and is not itself an ElectronicsComponent. frontBumper's quiescent
                  draw is left unset (negligible), matching the ElectronicsComponent "no
                  default, not mandatory" convention already used for BatteryPack.
                */
            connect sensorBus to i2c.host;
            connect frontTof.data to i2c.frontTof;
            connect leftTof.data to i2c.leftTof;
            connect rightTof.data to i2c.rightTof;
            connect lidarSerial to uart.host;
            connect lidar.data to uart.lidar;
            connect lidar.power to power;
            connect frontTof.power to power;
            connect leftTof.power to power;
            connect rightTof.power to power;
            connect hmi.power to power;
            connect hmi.control to hmiControl;
            connect frontBumper.signal to bumperHazard;
        }
    }
    package Views {
        view topDecomposition : GeneralView {
            doc /* Which sensing and interaction components constitute this robot's top module? Show the
             * bumper, time-of-flight sensors, LiDAR, shell, sensor bus and human-machine interface in
             * their top context. This view answers composition, not signal routing. */
            satisfy productStructurePerspective;
            filter @SysML::PartUsage;
            filter not @SysML::ConnectionUsage;
            filter not @SysML::AllocationUsage;
            expose VacuumCleanerSystem::Integration::robotSystem.physical.top;
          }
    }
}
