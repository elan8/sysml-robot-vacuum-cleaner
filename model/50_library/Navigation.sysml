/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
// Public import paths preserve references without duplicating authoritative elements.
package PhysicalArchitecture {
    public import PhysicalShared::*;
    alias DriveMotor for ComponentProfiles::DriveMotor::Architecture::DriveMotorArchitecture;
    alias DriveTrain for DriveTrainSystem::Integration::DriveTrainIntegration;
    alias CleaningHeadHousing for ComponentProfiles::CleaningHeadHousing::Architecture::CleaningHeadHousingArchitecture;
    alias SideBrush for ComponentProfiles::SideBrush::Architecture::SideBrushArchitecture;
    alias BrushTransmission for ComponentProfiles::BrushTransmission::Architecture::BrushTransmissionArchitecture;
    alias CleaningHeadModule for CleaningHeadSystem::Integration::CleaningHeadModuleIntegration;
    alias RobotTofSensor for ComponentProfiles::RobotTofSensor::Architecture::RobotTofSensorArchitecture;
    alias RobotLidar for ComponentProfiles::RobotLidar::Architecture::RobotLidarArchitecture;
    alias CliffSensor for ComponentProfiles::CliffSensor::Architecture::CliffSensorArchitecture;
    alias RobotBms for ComponentProfiles::RobotBms::Architecture::RobotBmsArchitecture;
    alias RobotBatteryCharger for ComponentProfiles::RobotBatteryCharger::Architecture::RobotBatteryChargerArchitecture;
    alias PowerModule for PowerSystem::Integration::PowerModuleIntegration;
    alias DockContactAssembly for ComponentProfiles::DockContactAssembly::Architecture::DockContactAssemblyArchitecture;
    alias DockInterfaceModule for DockInterfaceSystem::Integration::DockInterfaceModuleIntegration;
    alias Chassis for ComponentProfiles::Chassis::Architecture::ChassisArchitecture;
    alias BaseModule for BaseSystem::Integration::BaseModuleIntegration;
    alias RobotMainMcu for ControllerSystem::Integration::RobotMainMcuIntegration;
    alias RobotMotorDriver for ComponentProfiles::RobotMotorDriver::Architecture::RobotMotorDriverArchitecture;
    alias RobotWirelessModule for ComponentProfiles::RobotWirelessModule::Architecture::RobotWirelessModuleArchitecture;
    alias RobotControlBoard for ComponentProfiles::RobotControlBoard::Architecture::RobotControlBoardArchitecture;
    alias MainPcbModule for MainControlBoardSystem::Integration::MainPcbModuleIntegration;
    alias HumanMachineInterface for ComponentProfiles::HumanMachineInterface::Architecture::HumanMachineInterfaceArchitecture;
    alias TopShell for ComponentProfiles::TopShell::Architecture::TopShellArchitecture;
    alias TopModule for TopSystem::Integration::TopModuleIntegration;
    alias DustBinLid for ComponentProfiles::DustBinLid::Architecture::DustBinLidArchitecture;
    alias DustFilter for ComponentProfiles::DustFilter::Architecture::DustFilterArchitecture;
    alias DustBinBody for ComponentProfiles::DustBinBody::Architecture::DustBinBodyArchitecture;
    alias DustBin for DustBinSystem::Integration::DustBinIntegration;
    alias BaseWiringHarness for BaseHarnessSystem::Integration::BaseWiringHarnessIntegration;
    alias TopWiringHarness for TopHarnessSystem::Integration::TopWiringHarnessIntegration;
    alias AutonomousFloorCleaningRobot for RobotPlatformSystem::Integration::AutonomousFloorCleaningRobotIntegration;
}

package FirmwareArchitecture {
    public import FirmwareLibrary::*;
    alias HazardEventQueue for ComponentProfiles::HazardEventQueue::Architecture::HazardEventQueueArchitecture;
    alias UserCommandQueue for ComponentProfiles::UserCommandQueue::Architecture::UserCommandQueueArchitecture;
    alias DriveCommandQueue for ComponentProfiles::DriveCommandQueue::Architecture::DriveCommandQueueArchitecture;
    alias MapUpdateQueue for ComponentProfiles::MapUpdateQueue::Architecture::MapUpdateQueueArchitecture;
    alias MissionControllerTask for ComponentProfiles::MissionControllerTask::Architecture::MissionControllerTaskArchitecture;
    alias SafetySupervisorTask for ComponentProfiles::SafetySupervisorTask::Architecture::SafetySupervisorTaskArchitecture;
    alias ActuatorControlTask for ComponentProfiles::ActuatorControlTask::Architecture::ActuatorControlTaskArchitecture;
    alias SensorAcquisitionTask for ComponentProfiles::SensorAcquisitionTask::Architecture::SensorAcquisitionTaskArchitecture;
    alias NavigationTask for ComponentProfiles::NavigationTask::Architecture::NavigationTaskArchitecture;
    alias PowerManagerTask for ComponentProfiles::PowerManagerTask::Architecture::PowerManagerTaskArchitecture;
    alias AppServiceTask for ComponentProfiles::AppServiceTask::Architecture::AppServiceTaskArchitecture;
    alias FirmwareTaskArchitecture for FirmwareSystem::Integration::FirmwareTaskArchitectureIntegration;
}

package Architecture {
    public import DomainModel::*;
    public import FunctionalArchitecture::*;
    public import PhysicalArchitecture::*;
    public import VacuumCleanerSystem::Integration::*;
    alias CleaningRobotSystemOfInterest for VacuumCleanerSystem::Integration::CleaningRobotSystemOfInterestIntegration;
}

package RequirementLimits { public import RobotPlatformSystem::Specification::Limits::*; }

package SystemRequirements { public import RobotPlatformSystem::Specification::Requirements::*; }

package ModuleBudgets { public import RobotPlatformSystem::Architecture::Budgets::*; }

package ModuleRequirements {
    public import BaseSystem::Specification::Requirements::*;
    public import MainControlBoardSystem::Specification::Requirements::*;
    public import FirmwareSystem::Specification::Requirements::*;
    public import TopSystem::Specification::Requirements::*;
    public import DustBinSystem::Specification::Requirements::*;
    public import RobotPlatformSystem::Specification::HarnessRequirements::*;
}

package RequirementTraceability { public import RobotPlatformSystem::Specification::Traceability::*; }

package RequirementAllocation { public import RobotPlatformSystem::Architecture::RequirementAllocation::*; }

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
