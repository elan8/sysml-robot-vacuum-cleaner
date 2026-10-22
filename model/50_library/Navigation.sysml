/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
// Public import paths preserve references without duplicating authoritative elements.
package PhysicalArchitecture {
    public import PhysicalShared::*;
    alias DriveMotor for ComponentProfiles::DriveMotor::DriveMotorArchitecture;
    alias DriveTrain for DriveTrainSystem::DriveTrainIntegration;
    alias CleaningHeadHousing for ComponentProfiles::CleaningHeadHousing::CleaningHeadHousingArchitecture;
    alias SideBrush for ComponentProfiles::SideBrush::SideBrushArchitecture;
    alias BrushTransmission for ComponentProfiles::BrushTransmission::BrushTransmissionArchitecture;
    alias CleaningHeadModule for CleaningHeadSystem::CleaningHeadModuleIntegration;
    alias RobotTofSensor for ComponentProfiles::RobotTofSensor::RobotTofSensorArchitecture;
    alias RobotLidar for ComponentProfiles::RobotLidar::RobotLidarArchitecture;
    alias CliffSensor for ComponentProfiles::CliffSensor::CliffSensorArchitecture;
    alias RobotBms for ComponentProfiles::RobotBms::RobotBmsArchitecture;
    alias RobotBatteryCharger for ComponentProfiles::RobotBatteryCharger::RobotBatteryChargerArchitecture;
    alias PowerModule for PowerSystem::PowerModuleIntegration;
    alias DockContactAssembly for ComponentProfiles::DockContactAssembly::DockContactAssemblyArchitecture;
    alias DockInterfaceModule for DockInterfaceSystem::DockInterfaceModuleIntegration;
    alias Chassis for ComponentProfiles::Chassis::ChassisArchitecture;
    alias BaseModule for BaseSystem::BaseModuleIntegration;
    alias RobotMainMcu for ControllerSystem::RobotMainMcuIntegration;
    alias RobotMotorDriver for ComponentProfiles::RobotMotorDriver::RobotMotorDriverArchitecture;
    alias RobotWirelessModule for ComponentProfiles::RobotWirelessModule::RobotWirelessModuleArchitecture;
    alias RobotControlBoard for ComponentProfiles::RobotControlBoard::RobotControlBoardArchitecture;
    alias MainPcbModule for MainControlBoardSystem::MainPcbModuleIntegration;
    alias HumanMachineInterface for ComponentProfiles::HumanMachineInterface::HumanMachineInterfaceArchitecture;
    alias TopShell for ComponentProfiles::TopShell::TopShellArchitecture;
    alias TopModule for TopSystem::TopModuleIntegration;
    alias DustBinLid for ComponentProfiles::DustBinLid::DustBinLidArchitecture;
    alias DustFilter for ComponentProfiles::DustFilter::DustFilterArchitecture;
    alias DustBinBody for ComponentProfiles::DustBinBody::DustBinBodyArchitecture;
    alias DustBin for DustBinSystem::DustBinIntegration;
    alias BaseWiringHarness for BaseHarnessSystem::BaseWiringHarnessIntegration;
    alias TopWiringHarness for TopHarnessSystem::TopWiringHarnessIntegration;
    alias AutonomousFloorCleaningRobot for RobotPlatformSystem::AutonomousFloorCleaningRobotIntegration;
}

package FirmwareArchitecture {
    public import FirmwareLibrary::*;
    alias HazardEventQueue for ComponentProfiles::HazardEventQueue::HazardEventQueueArchitecture;
    alias UserCommandQueue for ComponentProfiles::UserCommandQueue::UserCommandQueueArchitecture;
    alias DriveCommandQueue for ComponentProfiles::DriveCommandQueue::DriveCommandQueueArchitecture;
    alias MapUpdateQueue for ComponentProfiles::MapUpdateQueue::MapUpdateQueueArchitecture;
    alias MissionControllerTask for ComponentProfiles::MissionControllerTask::MissionControllerTaskArchitecture;
    alias SafetySupervisorTask for ComponentProfiles::SafetySupervisorTask::SafetySupervisorTaskArchitecture;
    alias ActuatorControlTask for ComponentProfiles::ActuatorControlTask::ActuatorControlTaskArchitecture;
    alias SensorAcquisitionTask for ComponentProfiles::SensorAcquisitionTask::SensorAcquisitionTaskArchitecture;
    alias NavigationTask for ComponentProfiles::NavigationTask::NavigationTaskArchitecture;
    alias PowerManagerTask for ComponentProfiles::PowerManagerTask::PowerManagerTaskArchitecture;
    alias AppServiceTask for ComponentProfiles::AppServiceTask::AppServiceTaskArchitecture;
    alias FirmwareTaskArchitecture for FirmwareSystem::FirmwareTaskArchitectureIntegration;
}

package Architecture {
    public import DomainModel::*;
    public import FunctionalArchitecture::*;
    public import PhysicalArchitecture::*;
    public import VacuumCleanerSystem::robotSystem;
    alias CleaningRobotSystemOfInterest for VacuumCleanerSystem::CleaningRobotSystemOfInterestIntegration;
}

package RequirementLimits { public import RobotPlatformSystem::Limits::*; }

package SystemRequirements { public import RobotPlatformSystem::Requirements::*; }

package ModuleBudgets { public import RobotPlatformSystem::Budgets::*; }

package ModuleRequirements {
    public import BaseSystem::Requirements::*;
    public import MainControlBoardSystem::Requirements::*;
    public import FirmwareSystem::Requirements::*;
    public import TopSystem::Requirements::*;
    public import DustBinSystem::Requirements::*;
    public import RobotPlatformSystem::HarnessRequirements::*;
}

package RequirementTraceability { public import RobotPlatformSystem::Traceability::*; }

package RequirementAllocation { public import RobotPlatformSystem::RequirementAllocation::*; }

package RobotAnalysisCases { public import RobotPlatformSystem::Analysis::*; }

package Verification { public import RobotPlatformSystem::Verification::*; }

package Validation { public import VacuumCleanerSystem::Verification::Validation::*; }

package ModelViews {
    alias productDecomposition for RobotPlatformSystem::Views::productDecomposition;
    alias baseDecomposition for BaseSystem::Views::baseDecomposition;
    alias topDecomposition for TopSystem::Views::topDecomposition;
    alias mainPcbDecomposition for MainControlBoardSystem::Views::mainPcbDecomposition;
    alias powerDecomposition for PowerSystem::Views::powerDecomposition;
    alias interconnections for RobotPlatformSystem::Views::interconnections;
    alias firmwareDeployment for FirmwareSystem::Views::firmwareDeployment;
    alias systemRequirements for RobotPlatformSystem::Views::systemRequirements;
    alias cliffSafeStopScenario for VacuumCleanerSystem::Views::cliffSafeStopScenario;
}
