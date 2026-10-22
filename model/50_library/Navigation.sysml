/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
// Public import paths preserve references without duplicating authoritative elements.
package PhysicalArchitecture {
    public import PhysicalShared::*;
    alias DriveMotor for DriveTrainSystem::DriveMotor;
    alias DriveTrain for DriveTrainSystem::DriveTrainIntegration;
    alias CleaningHeadHousing for CleaningHeadSystem::CleaningHeadHousing;
    alias SideBrush for CleaningHeadSystem::SideBrush;
    alias BrushTransmission for CleaningHeadSystem::BrushTransmission;
    alias CleaningHeadModule for CleaningHeadSystem::CleaningHeadModuleIntegration;
    alias RobotTofSensor for TopSystem::RobotTofSensor;
    alias RobotLidar for TopSystem::RobotLidar;
    alias CliffSensor for BaseSystem::CliffSensor;
    alias RobotBms for PowerSystem::RobotBms;
    alias RobotBatteryCharger for PowerSystem::RobotBatteryCharger;
    alias PowerModule for PowerSystem::PowerModuleIntegration;
    alias DockContactAssembly for DockInterfaceSystem::DockContactAssembly;
    alias DockInterfaceModule for DockInterfaceSystem::DockInterfaceModuleIntegration;
    alias Chassis for BaseSystem::Chassis;
    alias BaseModule for BaseSystem::BaseModuleIntegration;
    alias RobotMainMcu for ControllerSystem::RobotMainMcuIntegration;
    alias RobotMotorDriver for MainControlBoardSystem::RobotMotorDriver;
    alias RobotWirelessModule for MainControlBoardSystem::RobotWirelessModule;
    alias RobotControlBoard for MainControlBoardSystem::RobotControlBoard;
    alias MainPcbModule for MainControlBoardSystem::MainPcbModuleIntegration;
    alias HumanMachineInterface for TopSystem::HumanMachineInterface;
    alias TopShell for TopSystem::TopShell;
    alias TopModule for TopSystem::TopModuleIntegration;
    alias DustBinLid for DustBinSystem::DustBinLid;
    alias DustFilter for DustBinSystem::DustFilter;
    alias DustBinBody for DustBinSystem::DustBinBody;
    alias DustBin for DustBinSystem::DustBinIntegration;
    alias BaseWiringHarness for BaseHarnessSystem::BaseWiringHarnessIntegration;
    alias TopWiringHarness for TopHarnessSystem::TopWiringHarnessIntegration;
    alias AutonomousFloorCleaningRobot for RobotPlatformSystem::AutonomousFloorCleaningRobotIntegration;
}

package FirmwareArchitecture {
    public import FirmwareLibrary::*;

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
