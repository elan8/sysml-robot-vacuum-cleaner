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
        part def DriveMotorSpecification :> BldcMotor, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def DriveMotorArchitecture :> DriveMotorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Drive motor, brushless DC, 14 W"; sourcing = SourcingKind::buy; unitCostEur = 4.80; }
            attribute :>> ratedPower = 14 [W];
            attribute :>> mass = 0.14 [kg];
        }

    }
    package CleaningHeadHousing {
        part def CleaningHeadHousingSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            /* illustrative estimate */
                port mainBrushAxle : RotationalMechanicalPort;
        }

        part def CleaningHeadHousingArchitecture :> CleaningHeadHousingSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            doc /* Brush chamber with main roller, suction duct and impeller housing. */
            @BomItem { description = "Cleaning head housing with main brush and duct"; sourcing = SourcingKind::make; unitCostEur = 2.60; }
            attribute :>> mass = 0.4 [kg];
        }

    }
    package SideBrush {
        part def SideBrushSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            port axle : RotationalMechanicalPort;
            attribute sweptDiameter : LengthValue;
        }

        part def SideBrushArchitecture :> SideBrushSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            doc /* Three-arm edge-sweeping brush, mechanically driven by the shared brush motor.
                     * Left and right outputs counter-rotate to sweep debris towards the main roller. */
            @BomItem { description = "Side brush, three-arm"; sourcing = SourcingKind::make; unitCostEur = 0.30; }
            attribute :>> mass = 0.015 [kg];
            /* illustrative estimate */
                attribute :>> sweptDiameter = 80 [mm];
        }

    }
    package BrushTransmission {
        part def BrushTransmissionSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            /* illustrative estimate */
                port inputShaft : RotationalMechanicalPort;
            port mainRollerOutput : RotationalMechanicalPort;
            port leftOutput : RotationalMechanicalPort;
            port rightOutput : RotationalMechanicalPort;
        }

        part def BrushTransmissionArchitecture :> BrushTransmissionSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            doc /* Belt and gear transmission from the brush motor to the main roller and both side
                     * brushes. The mirrored side outputs sweep inward; no independent brush motors. */
            @BomItem { description = "Brush belt and gear transmission"; sourcing = SourcingKind::make; unitCostEur = 0.60; }
            attribute :>> mass = 0.03 [kg];
        }

    }
    package RobotTofSensor {
        part def RobotTofSensorSpecification :> DcPoweredSensor, I2cDataSensor, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            attribute range : LengthValue;
        }

        part def RobotTofSensorArchitecture :> RobotTofSensorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
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
    package RobotLidar {
        part def RobotLidarSpecification :> DcPoweredSensor, UartDataSensor, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            attribute scanRate : FrequencyValue;
            attribute range : LengthValue;
        }

        part def RobotLidarArchitecture :> RobotLidarSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
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
    package CliffSensor {
        part def CliffSensorSpecification :> DcPoweredSensor, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            /* illustrative estimate */
                port signal : GpioPort;
            attribute triggerHeight : LengthValue;
        }

        part def CliffSensorArchitecture :> CliffSensorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Cliff sensor, infrared reflective"; sourcing = SourcingKind::buy; unitCostEur = 0.45; }
            attribute :>> triggerHeight = 50 [mm];
            attribute :>> mass = 0.02 [kg];
            /* illustrative estimate */
                attribute :>> powerDraw = 0.25 [W];
        }

    }
    package RobotBms {
        part def RobotBmsSpecification :> BatteryManagementSystem, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def RobotBmsArchitecture :> RobotBmsSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
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
    package RobotBatteryCharger {
        part def RobotBatteryChargerSpecification :> BatteryCharger, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def RobotBatteryChargerArchitecture :> RobotBatteryChargerSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Battery charger stage, 2 A"; sourcing = SourcingKind::buy; unitCostEur = 1.20; }
            attribute :>> maxChargeCurrent = 2 [A];
            attribute :>> quiescentPower = 0.5 [W];
            attribute :>> powerDraw = 0.5 [W];
            attribute :>> mass = 0.04 [kg];
        }

    }
    package DockContactAssembly {
        part def DockContactAssemblySpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def DockContactAssemblyArchitecture :> DockContactAssemblySpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            doc /* Two sprung charging contacts in their carrier. */
            @BomItem { description = "Charging contact assembly"; sourcing = SourcingKind::make; unitCostEur = 0.80; }
            attribute :>> mass = 0.05 [kg];
        }

    }
    package Chassis {
        part def ChassisSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def ChassisArchitecture :> ChassisSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            doc /* Bare structural tub; everything else in BaseModule mounts on it. */
            @BomItem { description = "Chassis tub, injection moulded"; sourcing = SourcingKind::make; unitCostEur = 3.50; }
            attribute :>> mass = 0.3 [kg];
        }

    }
    package RobotMotorDriver {
        part def RobotMotorDriverSpecification :> ThreePhaseMotorDriver, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def RobotMotorDriverArchitecture :> RobotMotorDriverSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Three-phase motor driver"; sourcing = SourcingKind::buy; unitCostEur = 2.30; }
            attribute :>> mass = 0.005 [kg];
            /* illustrative estimate */
                attribute :>> powerDraw = 1.5 [W];
            /* illustrative estimate */
                dependency selectedImplementation
                  from RobotMotorDriverArchitecture to DRV8316R;
        }

    }
    package RobotWirelessModule {
        part def RobotWirelessModuleSpecification :> WirelessModule, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            /* illustrative estimate */
                port hostLink : UartPort :>> hostLink;
            port robotService : RobotServicePort;
        }

        part def RobotWirelessModuleArchitecture :> RobotWirelessModuleSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Wi-Fi and Bluetooth LE module"; sourcing = SourcingKind::buy; unitCostEur = 1.50; }
            attribute :>> mass = 0.005 [kg];
            /* illustrative estimate */
                attribute :>> powerDraw = 1 [W];
            dependency selectedImplementation
                  from RobotWirelessModuleArchitecture to ESP32C3MINI1;
        }

    }
    package RobotControlBoard {
        part def RobotControlBoardSpecification :> PrintedCircuitBoard, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def RobotControlBoardArchitecture :> RobotControlBoardSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Main control board, bare PCB with passives and connectors"; sourcing = SourcingKind::make; unitCostEur = 3.40; }
            attribute :>> mass = 0.155 [kg];
        }

    }
    package HumanMachineInterface {
        part def HumanMachineInterfaceSpecification :> ElectronicsComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
            port power : ~PowerRailPort;
            port control : ~LocalHmiControllerPort;
        }

        part def HumanMachineInterfaceArchitecture :> HumanMachineInterfaceSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Button and indicator board"; sourcing = SourcingKind::make; unitCostEur = 1.10; }
            attribute :>> powerDraw = 1 [W];
            attribute :>> mass = 0.08 [kg];
        }

    }
    package TopShell {
        part def TopShellSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def TopShellArchitecture :> TopShellSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            doc /* Outer cover with the bumper carrier and the LiDAR turret opening. */
            @BomItem { description = "Top shell with bumper carrier, moulded"; sourcing = SourcingKind::make; unitCostEur = 2.80; }
            attribute :>> mass = 0.2 [kg];
        }

    }
    package DustBinLid {
        part def DustBinLidSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def DustBinLidArchitecture :> DustBinLidSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Dust bin lid, moulded"; sourcing = SourcingKind::make; unitCostEur = 0.30; }
            attribute :>> mass = 0.03 [kg];
        }

    }
    package DustFilter {
        part def DustFilterSpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def DustFilterArchitecture :> DustFilterSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Pleated dust filter"; sourcing = SourcingKind::buy; unitCostEur = 0.55; }
            attribute :>> mass = 0.02 [kg];
        }

    }
    package DustBinBody {
        part def DustBinBodySpecification :> MechanicalComponent, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def DustBinBodyArchitecture :> DustBinBodySpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
            @BomItem { description = "Dust bin body, moulded"; sourcing = SourcingKind::make; unitCostEur = 0.70; }
            attribute :>> mass = 0.15 [kg];
        }

    }
    package HazardEventQueue {
        part def HazardEventQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
            port messages : HazardEventQueuePort;
        }

        part def HazardEventQueueArchitecture :> HazardEventQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

        }

    }
    package UserCommandQueue {
        part def UserCommandQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
            port messages : UserCommandQueuePort;
        }

        part def UserCommandQueueArchitecture :> UserCommandQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

        }

    }
    package DriveCommandQueue {
        part def DriveCommandQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
            port messages : DriveCommandQueuePort;
        }

        part def DriveCommandQueueArchitecture :> DriveCommandQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

        }

    }
    package MapUpdateQueue {
        part def MapUpdateQueueSpecification :> SoftwareQueue, Elan8::SystemsEngineering::SystemSpecification {
            port messages : MapUpdateQueuePort;
        }

        part def MapUpdateQueueArchitecture :> MapUpdateQueueSpecification, Elan8::SystemsEngineering::SystemArchitecture {

        }

    }
    package MissionControllerTask {
        part def MissionControllerTaskSpecification :> EventDrivenFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def MissionControllerTaskArchitecture :> MissionControllerTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package SafetySupervisorTask {
        part def SafetySupervisorTaskSpecification :> EventDrivenFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def SafetySupervisorTaskArchitecture :> SafetySupervisorTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package ActuatorControlTask {
        part def ActuatorControlTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def ActuatorControlTaskArchitecture :> ActuatorControlTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package SensorAcquisitionTask {
        part def SensorAcquisitionTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def SensorAcquisitionTaskArchitecture :> SensorAcquisitionTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package NavigationTask {
        part def NavigationTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def NavigationTaskArchitecture :> NavigationTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package PowerManagerTask {
        part def PowerManagerTaskSpecification :> PeriodicFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def PowerManagerTaskArchitecture :> PowerManagerTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package AppServiceTask {
        part def AppServiceTaskSpecification :> EventDrivenFirmwareTask, Elan8::SystemsEngineering::SystemSpecification {

        }

        part def AppServiceTaskArchitecture :> AppServiceTaskSpecification, Elan8::SystemsEngineering::SystemArchitecture {
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
    package BatteryPack {
 part def BatteryPackSpecification :> Power::BatteryPack, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def BatteryPackArchitecture :> BatteryPackSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package BmsSmbusBus {
 part def BmsSmbusBusSpecification :> DomainModel::BmsSmbusBus, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def BmsSmbusBusArchitecture :> BmsSmbusBusSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package BoardConnector {
 part def BoardConnectorSpecification :> Electronics::Interconnection::BoardConnector, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, ComponentProfiles::ElectronicConnector::ElectronicConnectorSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def BoardConnectorArchitecture :> BoardConnectorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, ComponentProfiles::ElectronicConnector::ElectronicConnectorArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package BrushedDcMotor {
 part def BrushedDcMotorSpecification :> Actuation::BrushedDcMotor, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def BrushedDcMotorArchitecture :> BrushedDcMotorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package BumperSwitch {
 part def BumperSwitchSpecification :> DomainModel::BumperSwitch, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def BumperSwitchArchitecture :> BumperSwitchSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package CasterWheel {
 part def CasterWheelSpecification :> Drivetrain::CasterWheel, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def CasterWheelArchitecture :> CasterWheelSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package ElectronicConnector {
 part def ElectronicConnectorSpecification :> Electronics::Interconnection::ElectronicConnector, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def ElectronicConnectorArchitecture :> ElectronicConnectorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package ExecutionPlatform {
 part def ExecutionPlatformSpecification :> Software::ExecutionPlatform, Elan8::SystemsEngineering::SystemSpecification;

 part def ExecutionPlatformArchitecture :> ExecutionPlatformSpecification, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package Gearbox {
 part def GearboxSpecification :> Drivetrain::Gearbox, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def GearboxArchitecture :> GearboxSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package HBridgeMotorDriver {
 part def HBridgeMotorDriverSpecification :> Actuation::HBridgeMotorDriver, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def HBridgeMotorDriverArchitecture :> HBridgeMotorDriverSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package HarnessConductor {
 part def HarnessConductorSpecification :> Electronics::Interconnection::HarnessConductor, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def HarnessConductorArchitecture :> HarnessConductorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package HomingBeaconReceiver {
 part def HomingBeaconReceiverSpecification :> DomainModel::HomingBeaconReceiver, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def HomingBeaconReceiverArchitecture :> HomingBeaconReceiverSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package I2cInertialMeasurementUnit {
 part def I2cInertialMeasurementUnitSpecification :> Sensing::I2cInertialMeasurementUnit, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def I2cInertialMeasurementUnitArchitecture :> I2cInertialMeasurementUnitSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package LidarUartBus {
 part def LidarUartBusSpecification :> DomainModel::LidarUartBus, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def LidarUartBusArchitecture :> LidarUartBusSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package LiftSwitch {
 part def LiftSwitchSpecification :> DomainModel::LiftSwitch, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def LiftSwitchArchitecture :> LiftSwitchSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package MemoryBlock {
 part def MemoryBlockSpecification :> Compute::MemoryBlock, Elan8::SystemsEngineering::SystemSpecification;

 part def MemoryBlockArchitecture :> MemoryBlockSpecification, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package PeripheralBlock {
 part def PeripheralBlockSpecification :> Compute::PeripheralBlock, Elan8::SystemsEngineering::SystemSpecification;

 part def PeripheralBlockArchitecture :> PeripheralBlockSpecification, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package PhysicalComponent {
 part def PhysicalComponentSpecification :> Elan8::Core::PhysicalComponent, Elan8::SystemsEngineering::SystemSpecification;

 part def PhysicalComponentArchitecture :> PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package QuadratureEncoder {
 part def QuadratureEncoderSpecification :> Sensing::QuadratureEncoder, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def QuadratureEncoderArchitecture :> QuadratureEncoderSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package SensorI2cBus {
 part def SensorI2cBusSpecification :> DomainModel::SensorI2cBus, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def SensorI2cBusArchitecture :> SensorI2cBusSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package VoltageRegulator {
 part def VoltageRegulatorSpecification :> Power::VoltageRegulator, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def VoltageRegulatorArchitecture :> VoltageRegulatorSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package Wheel {
 part def WheelSpecification :> Drivetrain::Wheel, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def WheelArchitecture :> WheelSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
    package WirelessUartBus {
 part def WirelessUartBusSpecification :> DomainModel::WirelessUartBus, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification;

 part def WirelessUartBusArchitecture :> WirelessUartBusSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture;

    }
}
