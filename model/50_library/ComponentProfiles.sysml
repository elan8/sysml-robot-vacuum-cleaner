/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package ComponentProfiles {
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
    package DriveMotor {
        package Specification {
            part def DriveMotorSpecification :> BldcMotor, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def DriveMotorArchitecture :> Specification::DriveMotorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Drive motor, brushless DC, 14 W"; sourcing = SourcingKind::buy; unitCostEur = 4.80; }
                attribute :>> ratedPower = 14 [W];
                attribute :>> mass = 0.14 [kg];
            }
        }
    }
    package CleaningHeadHousing {
        package Specification {
            part def CleaningHeadHousingSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                /* illustrative estimate */
                    port mainBrushAxle : RotationalMechanicalPort;
            }
        }
        package Architecture {
            part def CleaningHeadHousingArchitecture :> Specification::CleaningHeadHousingSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                doc /* Brush chamber with main roller, suction duct and impeller housing. */
                @BomItem { description = "Cleaning head housing with main brush and duct"; sourcing = SourcingKind::make; unitCostEur = 2.60; }
                attribute :>> mass = 0.4 [kg];
            }
        }
    }
    package SideBrush {
        package Specification {
            part def SideBrushSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                port axle : RotationalMechanicalPort;
                attribute sweptDiameter : LengthValue;
            }
        }
        package Architecture {
            part def SideBrushArchitecture :> Specification::SideBrushSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                doc /* Three-arm edge-sweeping brush, mechanically driven by the shared brush motor.
                         * Left and right outputs counter-rotate to sweep debris towards the main roller. */
                @BomItem { description = "Side brush, three-arm"; sourcing = SourcingKind::make; unitCostEur = 0.30; }
                attribute :>> mass = 0.015 [kg];
                /* illustrative estimate */
                    attribute :>> sweptDiameter = 80 [mm];
            }
        }
    }
    package BrushTransmission {
        package Specification {
            part def BrushTransmissionSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                /* illustrative estimate */
                    port inputShaft : RotationalMechanicalPort;
                port mainRollerOutput : RotationalMechanicalPort;
                port leftOutput : RotationalMechanicalPort;
                port rightOutput : RotationalMechanicalPort;
            }
        }
        package Architecture {
            part def BrushTransmissionArchitecture :> Specification::BrushTransmissionSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                doc /* Belt and gear transmission from the brush motor to the main roller and both side
                         * brushes. The mirrored side outputs sweep inward; no independent brush motors. */
                @BomItem { description = "Brush belt and gear transmission"; sourcing = SourcingKind::make; unitCostEur = 0.60; }
                attribute :>> mass = 0.03 [kg];
            }
        }
    }
    package RobotTofSensor {
        package Specification {
            part def RobotTofSensorSpecification :> DcPoweredSensor, I2cDataSensor, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                attribute range : LengthValue;
            }
        }
        package Architecture {
            part def RobotTofSensorArchitecture :> Specification::RobotTofSensorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Time-of-flight distance sensor module"; sourcing = SourcingKind::buy; unitCostEur = 2.60; }
                attribute :>> range = 1200 [mm];
                attribute :>> mass = 0.03 [kg];
                /* illustrative estimate */
                    attribute :>> powerDraw = 0.1 [W];
                /* illustrative estimate */
                    dependency selectedImplementation
                      from RobotTofSensorArchitecture to VL53L1CX;
            }
        }
    }
    package RobotLidar {
        package Specification {
            part def RobotLidarSpecification :> DcPoweredSensor, UartDataSensor, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                attribute scanRate : FrequencyValue;
                attribute range : LengthValue;
            }
        }
        package Architecture {
            part def RobotLidarArchitecture :> Specification::RobotLidarSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "360° laser distance scanner"; sourcing = SourcingKind::buy; unitCostEur = 35.00; }
                attribute :>> scanRate = 10 [Hz];
                attribute :>> range = 6000 [mm];
                attribute :>> mass = 0.15 [kg];
                /* illustrative estimate */
                    attribute :>> powerDraw = 3.5 [W];
                /* illustrative estimate */
                    dependency selectedImplementation
                      from RobotLidarArchitecture to RPLIDARC1;
            }
        }
    }
    package CliffSensor {
        package Specification {
            part def CliffSensorSpecification :> DcPoweredSensor, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                /* illustrative estimate */
                    port signal : GpioPort;
                attribute triggerHeight : LengthValue;
            }
        }
        package Architecture {
            part def CliffSensorArchitecture :> Specification::CliffSensorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Cliff sensor, infrared reflective"; sourcing = SourcingKind::buy; unitCostEur = 0.45; }
                attribute :>> triggerHeight = 50 [mm];
                attribute :>> mass = 0.02 [kg];
                /* illustrative estimate */
                    attribute :>> powerDraw = 0.25 [W];
            }
        }
    }
    package RobotBms {
        package Specification {
            part def RobotBmsSpecification :> BatteryManagementSystem, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def RobotBmsArchitecture :> Specification::RobotBmsSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Battery gauge and protection circuit"; sourcing = SourcingKind::buy; unitCostEur = 2.90; }
                attribute :>> maxChargeCurrent = 2 [A];
                attribute :>> maxCellTemperature = 328.15 [K];
                attribute :>> mass = 0.03 [kg];
                /* illustrative estimate */
                    attribute :>> quiescentPower = 1 [W];
                /* illustrative estimate */
                    dependency selectedImplementation
                      from RobotBmsArchitecture to BQ40Z50R2;
            }
        }
    }
    package RobotBatteryCharger {
        package Specification {
            part def RobotBatteryChargerSpecification :> BatteryCharger, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def RobotBatteryChargerArchitecture :> Specification::RobotBatteryChargerSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Battery charger stage, 2 A"; sourcing = SourcingKind::buy; unitCostEur = 1.20; }
                attribute :>> maxChargeCurrent = 2 [A];
                attribute :>> quiescentPower = 0.5 [W];
                attribute :>> powerDraw = 0.5 [W];
                attribute :>> mass = 0.04 [kg];
            }
        }
    }
    package DockContactAssembly {
        package Specification {
            part def DockContactAssemblySpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def DockContactAssemblyArchitecture :> Specification::DockContactAssemblySpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                doc /* Two sprung charging contacts in their carrier. */
                @BomItem { description = "Charging contact assembly"; sourcing = SourcingKind::make; unitCostEur = 0.80; }
                attribute :>> mass = 0.05 [kg];
            }
        }
    }
    package Chassis {
        package Specification {
            part def ChassisSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def ChassisArchitecture :> Specification::ChassisSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                doc /* Bare structural tub; everything else in BaseModule mounts on it. */
                @BomItem { description = "Chassis tub, injection moulded"; sourcing = SourcingKind::make; unitCostEur = 3.50; }
                attribute :>> mass = 0.3 [kg];
            }
        }
    }
    package RobotMotorDriver {
        package Specification {
            part def RobotMotorDriverSpecification :> ThreePhaseMotorDriver, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def RobotMotorDriverArchitecture :> Specification::RobotMotorDriverSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Three-phase motor driver"; sourcing = SourcingKind::buy; unitCostEur = 2.30; }
                attribute :>> mass = 0.005 [kg];
                /* illustrative estimate */
                    attribute :>> powerDraw = 1.5 [W];
                /* illustrative estimate */
                    dependency selectedImplementation
                      from RobotMotorDriverArchitecture to DRV8316R;
            }
        }
    }
    package RobotWirelessModule {
        package Specification {
            part def RobotWirelessModuleSpecification :> WirelessModule, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                /* illustrative estimate */
                    port hostLink : UartPort :>> hostLink;
                port robotService : RobotServicePort;
            }
        }
        package Architecture {
            part def RobotWirelessModuleArchitecture :> Specification::RobotWirelessModuleSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Wi-Fi and Bluetooth LE module"; sourcing = SourcingKind::buy; unitCostEur = 1.50; }
                attribute :>> mass = 0.005 [kg];
                /* illustrative estimate */
                    attribute :>> powerDraw = 1 [W];
                dependency selectedImplementation
                      from RobotWirelessModuleArchitecture to ESP32C3MINI1;
            }
        }
    }
    package RobotControlBoard {
        package Specification {
            part def RobotControlBoardSpecification :> PrintedCircuitBoard, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def RobotControlBoardArchitecture :> Specification::RobotControlBoardSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Main control board, bare PCB with passives and connectors"; sourcing = SourcingKind::make; unitCostEur = 3.40; }
                attribute :>> mass = 0.155 [kg];
            }
        }
    }
    package HumanMachineInterface {
        package Specification {
            part def HumanMachineInterfaceSpecification :> ElectronicsComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
                port power : ~PowerRailPort;
                port control : ~LocalHmiControllerPort;
            }
        }
        package Architecture {
            part def HumanMachineInterfaceArchitecture :> Specification::HumanMachineInterfaceSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Button and indicator board"; sourcing = SourcingKind::make; unitCostEur = 1.10; }
                attribute :>> powerDraw = 1 [W];
                attribute :>> mass = 0.08 [kg];
            }
        }
    }
    package TopShell {
        package Specification {
            part def TopShellSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def TopShellArchitecture :> Specification::TopShellSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                doc /* Outer cover with the bumper carrier and the LiDAR turret opening. */
                @BomItem { description = "Top shell with bumper carrier, moulded"; sourcing = SourcingKind::make; unitCostEur = 2.80; }
                attribute :>> mass = 0.2 [kg];
            }
        }
    }
    package DustBinLid {
        package Specification {
            part def DustBinLidSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def DustBinLidArchitecture :> Specification::DustBinLidSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Dust bin lid, moulded"; sourcing = SourcingKind::make; unitCostEur = 0.30; }
                attribute :>> mass = 0.03 [kg];
            }
        }
    }
    package DustFilter {
        package Specification {
            part def DustFilterSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def DustFilterArchitecture :> Specification::DustFilterSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Pleated dust filter"; sourcing = SourcingKind::buy; unitCostEur = 0.55; }
                attribute :>> mass = 0.02 [kg];
            }
        }
    }
    package DustBinBody {
        package Specification {
            part def DustBinBodySpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def DustBinBodyArchitecture :> Specification::DustBinBodySpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
                @BomItem { description = "Dust bin body, moulded"; sourcing = SourcingKind::make; unitCostEur = 0.70; }
                attribute :>> mass = 0.15 [kg];
            }
        }
    }
    package HazardEventQueue {
        package Specification {
            part def HazardEventQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
                port messages : HazardEventQueuePort;
            }
        }
        package Architecture {
            part def HazardEventQueueArchitecture :> Specification::HazardEventQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

            }
        }
    }
    package UserCommandQueue {
        package Specification {
            part def UserCommandQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
                port messages : UserCommandQueuePort;
            }
        }
        package Architecture {
            part def UserCommandQueueArchitecture :> Specification::UserCommandQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

            }
        }
    }
    package DriveCommandQueue {
        package Specification {
            part def DriveCommandQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
                port messages : DriveCommandQueuePort;
            }
        }
        package Architecture {
            part def DriveCommandQueueArchitecture :> Specification::DriveCommandQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

            }
        }
    }
    package MapUpdateQueue {
        package Specification {
            part def MapUpdateQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
                port messages : MapUpdateQueuePort;
            }
        }
        package Architecture {
            part def MapUpdateQueueArchitecture :> Specification::MapUpdateQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

            }
        }
    }
    package MissionControllerTask {
        package Specification {
            part def MissionControllerTaskSpecification :> EventDrivenFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def MissionControllerTaskArchitecture :> Specification::MissionControllerTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> deadline = 50 [ms];
                attribute :>> priority = 5;
                attribute :>> criticality = TaskCriticality::missionCritical;
                action run {
                      in item plannerCommandIn : DriveCommand;
                      in item userCommandIn : UserCommand;
                      in item telemetryIn : BatteryTelemetry;
                      out item driveCommandOut : DriveCommand;
                      out item cleaningCommandOut : CleaningCommand;
                      out item missionStatusOut : MissionStatus;
                    }
            }
        }
    }
    package SafetySupervisorTask {
        package Specification {
            part def SafetySupervisorTaskSpecification :> EventDrivenFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def SafetySupervisorTaskArchitecture :> Specification::SafetySupervisorTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> deadline = 10 [ms];
                attribute :>> priority = 7;
                attribute :>> criticality = TaskCriticality::safetyCritical;
                action run {
                      in item hazardIn : HazardEvent;
                      in item telemetryIn : BatteryTelemetry;
                      in item diagnosticIn : DiagnosticEvent;
                      out item safeStopCommandOut : DriveCommand;
                    }
            }
        }
    }
    package ActuatorControlTask {
        package Specification {
            part def ActuatorControlTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def ActuatorControlTaskArchitecture :> Specification::ActuatorControlTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> period = 20 [ms];
                attribute :>> deadline = 20 [ms];
                attribute :>> priority = 6;
                attribute :>> criticality = TaskCriticality::safetyCritical;
                action run {
                      in item driveCommandIn : DriveCommand;
                      in item cleaningCommandIn : CleaningCommand;
                      out item odometryOut : PoseEstimate;
                      out item hazardOut : HazardEvent;
                      out item diagnosticOut : DiagnosticEvent;
                    }
            }
        }
    }
    package SensorAcquisitionTask {
        package Specification {
            part def SensorAcquisitionTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def SensorAcquisitionTaskArchitecture :> Specification::SensorAcquisitionTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> period = 20 [ms];
                attribute :>> deadline = 20 [ms];
                attribute :>> priority = 6;
                attribute :>> criticality = TaskCriticality::safetyCritical;
                action run {
                      out item lidarScanOut : LidarScanFrame;
                      out item obstacleOut : ObstacleObservation;
                      out item cliffOut : CliffObservation;
                      out item hazardOut : HazardEvent;
                    }
            }
        }
    }
    package NavigationTask {
        package Specification {
            part def NavigationTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def NavigationTaskArchitecture :> Specification::NavigationTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> period = 50 [ms];
                attribute :>> deadline = 50 [ms];
                attribute :>> priority = 4;
                attribute :>> criticality = TaskCriticality::missionCritical;
                action run {
                      in item lidarScanIn : LidarScanFrame;
                      in item odometryIn : PoseEstimate;
                      out item poseOut : PoseEstimate;
                      out item mapUpdateOut : MapUpdate;
                      out item plannerCommandOut : DriveCommand;
                    }
            }
        }
    }
    package PowerManagerTask {
        package Specification {
            part def PowerManagerTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def PowerManagerTaskArchitecture :> Specification::PowerManagerTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> period = 100 [ms];
                attribute :>> deadline = 100 [ms];
                attribute :>> priority = 5;
                attribute :>> criticality = TaskCriticality::safetyCritical;
                action run {
                      out item telemetryOut : BatteryTelemetry;
                      out item hazardOut : HazardEvent;
                    }
            }
        }
    }
    package AppServiceTask {
        package Specification {
            part def AppServiceTaskSpecification :> EventDrivenFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

            }
        }
        package Architecture {
            part def AppServiceTaskArchitecture :> Specification::AppServiceTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
                attribute :>> deadline = 100 [ms];
                attribute :>> priority = 2;
                attribute :>> criticality = TaskCriticality::nonCritical;
                action run {
                      in item missionStatusIn : MissionStatus;
                      in item mapUpdateIn : MapUpdate;
                      in item diagnosticIn : DiagnosticEvent;
                      out item userCommandOut : UserCommand;
                      out item appMessageOut : AppMessage;
                    }
            }
        }
    }
    package BatteryPack {
        package Specification { part def BatteryPackSpecification :> Power::BatteryPack, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def BatteryPackArchitecture :> Specification::BatteryPackSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package BmsSmbusBus {
        package Specification { part def BmsSmbusBusSpecification :> DomainModel::BmsSmbusBus, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def BmsSmbusBusArchitecture :> Specification::BmsSmbusBusSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package BoardConnector {
        package Specification { part def BoardConnectorSpecification :> Electronics::Interconnection::BoardConnector, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, ComponentProfiles::ElectronicConnector::Specification::ElectronicConnectorSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def BoardConnectorArchitecture :> Specification::BoardConnectorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, ComponentProfiles::ElectronicConnector::Architecture::ElectronicConnectorArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package BrushedDcMotor {
        package Specification { part def BrushedDcMotorSpecification :> Actuation::BrushedDcMotor, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def BrushedDcMotorArchitecture :> Specification::BrushedDcMotorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package BumperSwitch {
        package Specification { part def BumperSwitchSpecification :> DomainModel::BumperSwitch, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def BumperSwitchArchitecture :> Specification::BumperSwitchSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package CasterWheel {
        package Specification { part def CasterWheelSpecification :> Drivetrain::CasterWheel, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def CasterWheelArchitecture :> Specification::CasterWheelSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package ElectronicConnector {
        package Specification { part def ElectronicConnectorSpecification :> Electronics::Interconnection::ElectronicConnector, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def ElectronicConnectorArchitecture :> Specification::ElectronicConnectorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package ExecutionPlatform {
        package Specification { part def ExecutionPlatformSpecification :> Software::ExecutionPlatform, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def ExecutionPlatformArchitecture :> Specification::ExecutionPlatformSpecification, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package Gearbox {
        package Specification { part def GearboxSpecification :> Drivetrain::Gearbox, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def GearboxArchitecture :> Specification::GearboxSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package HBridgeMotorDriver {
        package Specification { part def HBridgeMotorDriverSpecification :> Actuation::HBridgeMotorDriver, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def HBridgeMotorDriverArchitecture :> Specification::HBridgeMotorDriverSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package HarnessConductor {
        package Specification { part def HarnessConductorSpecification :> Electronics::Interconnection::HarnessConductor, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def HarnessConductorArchitecture :> Specification::HarnessConductorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package HomingBeaconReceiver {
        package Specification { part def HomingBeaconReceiverSpecification :> DomainModel::HomingBeaconReceiver, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def HomingBeaconReceiverArchitecture :> Specification::HomingBeaconReceiverSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package I2cInertialMeasurementUnit {
        package Specification { part def I2cInertialMeasurementUnitSpecification :> Sensing::I2cInertialMeasurementUnit, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def I2cInertialMeasurementUnitArchitecture :> Specification::I2cInertialMeasurementUnitSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package LidarUartBus {
        package Specification { part def LidarUartBusSpecification :> DomainModel::LidarUartBus, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def LidarUartBusArchitecture :> Specification::LidarUartBusSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package LiftSwitch {
        package Specification { part def LiftSwitchSpecification :> DomainModel::LiftSwitch, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def LiftSwitchArchitecture :> Specification::LiftSwitchSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package MemoryBlock {
        package Specification { part def MemoryBlockSpecification :> Compute::MemoryBlock, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def MemoryBlockArchitecture :> Specification::MemoryBlockSpecification, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package PeripheralBlock {
        package Specification { part def PeripheralBlockSpecification :> Compute::PeripheralBlock, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def PeripheralBlockArchitecture :> Specification::PeripheralBlockSpecification, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package PhysicalComponent {
        package Specification { part def PhysicalComponentSpecification :> Elan8::Core::PhysicalComponent, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def PhysicalComponentArchitecture :> Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package QuadratureEncoder {
        package Specification { part def QuadratureEncoderSpecification :> Sensing::QuadratureEncoder, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def QuadratureEncoderArchitecture :> Specification::QuadratureEncoderSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package SensorI2cBus {
        package Specification { part def SensorI2cBusSpecification :> DomainModel::SensorI2cBus, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def SensorI2cBusArchitecture :> Specification::SensorI2cBusSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package VoltageRegulator {
        package Specification { part def VoltageRegulatorSpecification :> Power::VoltageRegulator, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def VoltageRegulatorArchitecture :> Specification::VoltageRegulatorSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package Wheel {
        package Specification { part def WheelSpecification :> Drivetrain::Wheel, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def WheelArchitecture :> Specification::WheelSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
    package WirelessUartBus {
        package Specification { part def WirelessUartBusSpecification :> DomainModel::WirelessUartBus, ComponentProfiles::PhysicalComponent::Specification::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification; }
        package Architecture { part def WirelessUartBusArchitecture :> Specification::WirelessUartBusSpecification, ComponentProfiles::PhysicalComponent::Architecture::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture; }
    }
}
