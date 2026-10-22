/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package FirmwareSystem {
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
    part def FirmwareTaskArchitectureSpecification :> Elan8::SystemsEngineering::SystemSpecification {
        attribute safetySupervisorDeadline : DurationValue;
        satisfy Requirements::firmwareSpecification;
    }
    package Requirements {
        private import ModuleBudgets::*;
        private import RequirementLimits::*;
        private import ISQ::*;
        private import SI::*;
        requirement firmwareSpecification {
            subject firmware : FirmwareSystem::FirmwareTaskArchitectureSpecification;

            requirement <'FW-001'> 'Safety supervisor deadline' {
              require constraint { firmware.safetySupervisorDeadline <= supervisorDecisionBudget }
              doc /* The safety supervisor task shall issue the safe-stop command within {{= ModuleBudgets::supervisorDecisionBudget}} of a hazard event entering its queue, under worst-case load of all other tasks. */
            }
          }
    }

    part def FirmwareTaskArchitectureArchitecture :> FirmwareTaskArchitectureSpecification, Elan8::SystemsEngineering::SystemArchitecture {
        part scheduler : Elan8::Software::ExecutionPlatform;
        part missionController : FirmwareLibrary::MissionControllerTask;
        part safetySupervisor : FirmwareLibrary::SafetySupervisorTask;
        part actuatorControl : FirmwareLibrary::ActuatorControlTask;
        part sensorAcquisition : FirmwareLibrary::SensorAcquisitionTask;
        part navigation : FirmwareLibrary::NavigationTask;
        part powerManager : FirmwareLibrary::PowerManagerTask;
        part appService : FirmwareLibrary::AppServiceTask;
        part hazardQueue : FirmwareLibrary::HazardEventQueue;
        part userCommandQueue : FirmwareLibrary::UserCommandQueue;
        part plannerCommandQueue : FirmwareLibrary::DriveCommandQueue;
        part safetyCommandQueue : FirmwareLibrary::DriveCommandQueue;
        part mapUpdateQueue : FirmwareLibrary::MapUpdateQueue;
    }

    part def FirmwareTaskArchitectureIntegration :> FirmwareTaskArchitectureArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part scheduler : Elan8::Software::ExecutionPlatform :>> scheduler {
              doc /*
                Safety and actuator loops execute before mission and app work. Overload
                sheds noncritical app/status work before safety or control work.
              */
              attribute :>> tickPeriod = 1 [ms];
              attribute :>> schedulingPolicy =
                SchedulingPolicy::fixedPriorityCooperative;
            }
        part missionController : FirmwareLibrary::MissionControllerTask :>> missionController;
        part safetySupervisor : FirmwareLibrary::SafetySupervisorTask :>> safetySupervisor;
        part actuatorControl : FirmwareLibrary::ActuatorControlTask :>> actuatorControl;
        part sensorAcquisition : FirmwareLibrary::SensorAcquisitionTask :>> sensorAcquisition;
        part navigation : FirmwareLibrary::NavigationTask :>> navigation;
        part powerManager : FirmwareLibrary::PowerManagerTask :>> powerManager;
        part appService : FirmwareLibrary::AppServiceTask :>> appService;
        part hazardQueue : FirmwareLibrary::HazardEventQueue :>> hazardQueue {
              attribute :>> discipline = QueueDiscipline::fifoDropNewest;
            }
        part userCommandQueue : FirmwareLibrary::UserCommandQueue :>> userCommandQueue {
              attribute :>> discipline = QueueDiscipline::overwriteLatest;
            }
        part plannerCommandQueue : FirmwareLibrary::DriveCommandQueue :>> plannerCommandQueue {
              attribute :>> discipline = QueueDiscipline::overwriteLatest;
            }
        part safetyCommandQueue : FirmwareLibrary::DriveCommandQueue :>> safetyCommandQueue {
              attribute :>> discipline = QueueDiscipline::overwriteLatest;
            }
        part mapUpdateQueue : FirmwareLibrary::MapUpdateQueue :>> mapUpdateQueue {
              attribute :>> discipline = QueueDiscipline::fifoDropOldest;
            }
        flow sensorAcquisition.run.lidarScanOut to navigation.run.lidarScanIn;
        flow actuatorControl.run.odometryOut to navigation.run.odometryIn;
        flow navigation.run.plannerCommandOut to plannerCommandQueue.messages.input;
        flow plannerCommandQueue.messages.output
              to missionController.run.plannerCommandIn;
        flow appService.run.userCommandOut to userCommandQueue.messages.input;
        flow userCommandQueue.messages.output to missionController.run.userCommandIn;
        flow navigation.run.mapUpdateOut to mapUpdateQueue.messages.input;
        flow mapUpdateQueue.messages.output to appService.run.mapUpdateIn;
        flow powerManager.run.telemetryOut to missionController.run.telemetryIn;
        flow powerManager.run.telemetryOut to safetySupervisor.run.telemetryIn;
        flow sensorAcquisition.run.hazardOut to hazardQueue.messages.input;
        flow actuatorControl.run.hazardOut to hazardQueue.messages.input;
        flow powerManager.run.hazardOut to hazardQueue.messages.input;
        flow hazardQueue.messages.output to safetySupervisor.run.hazardIn;
        flow safetySupervisor.run.safeStopCommandOut
              to safetyCommandQueue.messages.input;
        flow safetyCommandQueue.messages.output
              to actuatorControl.run.driveCommandIn;
        flow missionController.run.driveCommandOut
              to actuatorControl.run.driveCommandIn;
        flow missionController.run.cleaningCommandOut
              to actuatorControl.run.cleaningCommandIn;
        flow missionController.run.missionStatusOut to appService.run.missionStatusIn;
        flow actuatorControl.run.diagnosticOut to appService.run.diagnosticIn;
        flow actuatorControl.run.diagnosticOut to safetySupervisor.run.diagnosticIn;
        attribute :>> safetySupervisorDeadline = safetySupervisor.deadline;
    }

    package Views {
        view firmwareDeployment : GeneralView {
            doc /* Which processor hosts each of the seven firmware tasks? Show only task usages, the MCU
             * usage and their allocation relationships. Task queues, runtime behavior and reusable task
             * definitions are outside this deployment view. */
            satisfy firmwareDeploymentPerspective;
            filter @SysML::PartUsage or @SysML::AllocationUsage;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.missionController;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.safetySupervisor;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.actuatorControl;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.sensorAcquisition;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.navigation;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.powerManager;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.appService;
            expose VacuumCleanerSystem::robotSystem.physical.firmwareTasks.scheduler;
            expose VacuumCleanerSystem::robotSystem.physical.mainPcb.mcu;
          }
    }
}
