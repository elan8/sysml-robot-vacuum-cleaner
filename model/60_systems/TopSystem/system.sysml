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
    part def TopModuleSpecification :> MechanicalComponent, Elan8::SystemsEngineering::SystemSpecification {
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
            subject top : TopSystem::TopModuleSpecification;

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

    part def TopModuleArchitecture :> TopModuleSpecification, Elan8::SystemsEngineering::SystemArchitecture {
        part shell : TopSystem::TopShell;
        part lidar : TopSystem::RobotLidar;
        part frontTof : TopSystem::RobotTofSensor;
        part leftTof : TopSystem::RobotTofSensor;
        part rightTof : TopSystem::RobotTofSensor;
        part frontBumper : DomainModel::BumperSwitch;
        part hmi : TopSystem::HumanMachineInterface;
        part i2c : DomainModel::SensorI2cBus;
        part uart : DomainModel::LidarUartBus;
    }

    part def TopModuleIntegration :> TopModuleArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part shell : TopSystem::TopShell :>> shell;
        part lidar : TopSystem::RobotLidar :>> lidar;
        part frontTof : TopSystem::RobotTofSensor :>> frontTof;
        part leftTof : TopSystem::RobotTofSensor :>> leftTof;
        part rightTof : TopSystem::RobotTofSensor :>> rightTof;
        part frontBumper : DomainModel::BumperSwitch :>> frontBumper {
              @BomItem { description = "Bumper switch assembly"; sourcing = SourcingKind::buy; unitCostEur = 0.20; }
              attribute :>> mass = 0.02 [kg]; /* illustrative estimate */
            }
        part hmi : TopSystem::HumanMachineInterface :>> hmi;
        part i2c : DomainModel::SensorI2cBus :>> i2c;
        part uart : DomainModel::LidarUartBus :>> uart;
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

    package Views {
        view topDecomposition : GeneralView {
            doc /* Which sensing and interaction components constitute this robot's top module? Show the
             * bumper, time-of-flight sensors, LiDAR, shell, sensor bus and human-machine interface in
             * their top context. This view answers composition, not signal routing. */
            satisfy productStructurePerspective;
            filter @SysML::PartUsage;
            filter not @SysML::ConnectionUsage;
            filter not @SysML::AllocationUsage;
            expose VacuumCleanerSystem::robotSystem.physical.top;
          }
    }

    part def RobotTofSensor :> DcPoweredSensor, I2cDataSensor {
        attribute range : LengthValue = 1200 [mm];
        @BomItem { description = "Time-of-flight distance sensor module"; sourcing = SourcingKind::buy; unitCostEur = 2.60; }

        attribute :>> mass = 0.03 [kg];
        /* illustrative estimate */
        attribute :>> powerDraw = 0.1 [W];
        /* illustrative estimate */
        dependency selectedImplementation
            from RobotTofSensor to VL53L1CX;
    }

    part def RobotLidar :> DcPoweredSensor, UartDataSensor {
        attribute scanRate : FrequencyValue = 10 [Hz];
        attribute range : LengthValue = 6000 [mm];
        @BomItem { description = "360° laser distance scanner"; sourcing = SourcingKind::buy; unitCostEur = 35.00; }

        attribute :>> mass = 0.15 [kg];
        /* illustrative estimate */
        attribute :>> powerDraw = 3.5 [W];
        /* illustrative estimate */
        dependency selectedImplementation
            from RobotLidar to RPLIDARC1;
    }

    part def HumanMachineInterface :> ElectronicsComponent {
        port power : ~PowerRailPort;
        port control : ~LocalHmiControllerPort;
        @BomItem { description = "Button and indicator board"; sourcing = SourcingKind::make; unitCostEur = 1.10; }
        attribute :>> powerDraw = 1 [W];
        attribute :>> mass = 0.08 [kg];
    }

    part def TopShell :> MechanicalComponent {
        doc /* Outer cover with the bumper carrier and the LiDAR turret opening. */
        @BomItem { description = "Top shell with bumper carrier, moulded"; sourcing = SourcingKind::make; unitCostEur = 2.80; }
        attribute :>> mass = 0.2 [kg];
    }
}
