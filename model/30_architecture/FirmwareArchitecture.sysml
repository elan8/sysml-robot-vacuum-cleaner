/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Seven-task runtime architecture with typed queues and native item flows.
 */
package FirmwareArchitecture {
  private import DomainModel::*;
  private import Elan8::Software::Core::*;
  private import Elan8::Software::Realtime::*;
  private import Elan8::Units::Engineering::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def StartupPhase { platform; safety; mission; services; }

  part def FirmwareTask :> RealtimeTask {
    attribute startupPhase : StartupPhase;
  }

  part def HazardEventQueue :> SoftwareQueue {
    action transfer {
      in item enqueue : HazardEvent;
      out item dequeue : HazardEvent;
    }
  }
  part def UserCommandQueue :> SoftwareQueue {
    action transfer {
      in item enqueue : UserCommand;
      out item dequeue : UserCommand;
    }
  }
  part def DriveCommandQueue :> SoftwareQueue {
    action transfer {
      in item enqueue : DriveCommand;
      out item dequeue : DriveCommand;
    }
  }
  part def MapUpdateQueue :> SoftwareQueue {
    action transfer {
      in item enqueue : MapUpdate;
      out item dequeue : MapUpdate;
    }
  }

  part def MissionControllerTask :> FirmwareTask {
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> worstCaseExecutionTime = 4 [ms];
    attribute :>> stackBudgetBytes = 4096;
    attribute :>> heapBudgetBytes = 4096;
    attribute :>> priority = 5;
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::mission;
    action run {
      in item plannerCommandIn : DriveCommand;
      in item userCommandIn : UserCommand;
      in item telemetryIn : BatteryTelemetry;
      out item driveCommandOut : DriveCommand;
      out item cleaningCommandOut : CleaningCommand;
      out item missionStatusOut : MissionStatus;
    }
  }

  part def SafetySupervisorTask :> FirmwareTask {
    attribute :>> period = 10 [ms];
    attribute :>> deadline = 10 [ms];
    attribute :>> worstCaseExecutionTime = 1 [ms];
    attribute :>> stackBudgetBytes = 3072;
    attribute :>> heapBudgetBytes = 0;
    attribute :>> priority = 7;
    attribute :>> criticality = TaskCriticality::safetyCritical;
    attribute :>> startupPhase = StartupPhase::safety;
    action run {
      in item hazardIn : HazardEvent;
      in item telemetryIn : BatteryTelemetry;
      in item diagnosticIn : DiagnosticEvent;
      out item safeStopCommandOut : DriveCommand;
    }
  }

  part def ActuatorControlTask :> FirmwareTask {
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> worstCaseExecutionTime = 3 [ms];
    attribute :>> stackBudgetBytes = 4096;
    attribute :>> heapBudgetBytes = 1024;
    attribute :>> priority = 6;
    attribute :>> criticality = TaskCriticality::safetyCritical;
    attribute :>> startupPhase = StartupPhase::safety;
    action run {
      in item driveCommandIn : DriveCommand;
      in item cleaningCommandIn : CleaningCommand;
      out item odometryOut : PoseEstimate;
      out item hazardOut : HazardEvent;
      out item diagnosticOut : DiagnosticEvent;
    }
  }

  part def SensorAcquisitionTask :> FirmwareTask {
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> worstCaseExecutionTime = 3 [ms];
    attribute :>> stackBudgetBytes = 4096;
    attribute :>> heapBudgetBytes = 2048;
    attribute :>> priority = 6;
    attribute :>> criticality = TaskCriticality::safetyCritical;
    attribute :>> startupPhase = StartupPhase::safety;
    action run {
      out item lidarScanOut : LidarScanFrame;
      out item obstacleOut : ObstacleObservation;
      out item cliffOut : CliffObservation;
      out item hazardOut : HazardEvent;
    }
  }

  part def NavigationTask :> FirmwareTask {
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> worstCaseExecutionTime = 12 [ms];
    attribute :>> stackBudgetBytes = 8192;
    attribute :>> heapBudgetBytes = 32768;
    attribute :>> priority = 4;
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::mission;
    action run {
      in item lidarScanIn : LidarScanFrame;
      in item odometryIn : PoseEstimate;
      out item poseOut : PoseEstimate;
      out item mapUpdateOut : MapUpdate;
      out item plannerCommandOut : DriveCommand;
    }
  }

  part def PowerManagerTask :> FirmwareTask {
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> worstCaseExecutionTime = 2 [ms];
    attribute :>> stackBudgetBytes = 3072;
    attribute :>> heapBudgetBytes = 1024;
    attribute :>> priority = 5;
    attribute :>> criticality = TaskCriticality::safetyCritical;
    attribute :>> startupPhase = StartupPhase::safety;
    action run {
      out item telemetryOut : BatteryTelemetry;
      out item hazardOut : HazardEvent;
    }
  }

  part def AppServiceTask :> FirmwareTask {
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> worstCaseExecutionTime = 8 [ms];
    attribute :>> stackBudgetBytes = 8192;
    attribute :>> heapBudgetBytes = 16384;
    attribute :>> priority = 2;
    attribute :>> criticality = TaskCriticality::nonCritical;
    attribute :>> startupPhase = StartupPhase::services;
    action run {
      in item missionStatusIn : MissionStatus;
      in item mapUpdateIn : MapUpdate;
      in item diagnosticIn : DiagnosticEvent;
      out item userCommandOut : UserCommand;
      out item appMessageOut : AppMessage;
    }
  }

  part def FirmwareTaskArchitecture {
    part scheduler : SchedulerModel {
      doc /*
        Safety and actuator loops execute before mission and app work. Overload
        sheds noncritical app/status work before safety or control work.
      */
      attribute :>> tickPeriod = 1 [ms];
      attribute :>> schedulingPolicy =
        SchedulingPolicy::fixedPriorityCooperative;
    }
    part missionController : MissionControllerTask;
    part safetySupervisor : SafetySupervisorTask;
    part actuatorControl : ActuatorControlTask;
    part sensorAcquisition : SensorAcquisitionTask;
    part navigation : NavigationTask;
    part powerManager : PowerManagerTask;
    part appService : AppServiceTask;

    part hazardQueue : HazardEventQueue {
      attribute :>> depth = 8;
      attribute :>> discipline = QueueDiscipline::fifoDropNewest;
      attribute :>> maxAge = 100 [ms];
      doc /* Overflow produces a synthetic safety-critical hazard. */
    }
    part userCommandQueue : UserCommandQueue {
      attribute :>> depth = 4;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 250 [ms];
    }
    part plannerCommandQueue : DriveCommandQueue {
      attribute :>> depth = 4;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 100 [ms];
    }
    part safetyCommandQueue : DriveCommandQueue {
      attribute :>> depth = 2;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 20 [ms];
    }
    part mapUpdateQueue : MapUpdateQueue {
      attribute :>> depth = 16;
      attribute :>> discipline = QueueDiscipline::fifoDropOldest;
      attribute :>> maxAge = 5000 [ms];
    }

    flow sensorAcquisition.run.lidarScanOut to navigation.run.lidarScanIn;
    flow actuatorControl.run.odometryOut to navigation.run.odometryIn;
    flow navigation.run.plannerCommandOut to plannerCommandQueue.transfer.enqueue;
    flow plannerCommandQueue.transfer.dequeue
      to missionController.run.plannerCommandIn;
    flow appService.run.userCommandOut to userCommandQueue.transfer.enqueue;
    flow userCommandQueue.transfer.dequeue to missionController.run.userCommandIn;
    flow navigation.run.mapUpdateOut to mapUpdateQueue.transfer.enqueue;
    flow mapUpdateQueue.transfer.dequeue to appService.run.mapUpdateIn;
    flow powerManager.run.telemetryOut to missionController.run.telemetryIn;
    flow powerManager.run.telemetryOut to safetySupervisor.run.telemetryIn;
    flow sensorAcquisition.run.hazardOut to hazardQueue.transfer.enqueue;
    flow actuatorControl.run.hazardOut to hazardQueue.transfer.enqueue;
    flow powerManager.run.hazardOut to hazardQueue.transfer.enqueue;
    flow hazardQueue.transfer.dequeue to safetySupervisor.run.hazardIn;
    flow safetySupervisor.run.safeStopCommandOut
      to safetyCommandQueue.transfer.enqueue;
    flow safetyCommandQueue.transfer.dequeue
      to actuatorControl.run.driveCommandIn;
    flow missionController.run.driveCommandOut
      to actuatorControl.run.driveCommandIn;
    flow missionController.run.cleaningCommandOut
      to actuatorControl.run.cleaningCommandIn;
    flow missionController.run.missionStatusOut to appService.run.missionStatusIn;
    flow actuatorControl.run.diagnosticOut to appService.run.diagnosticIn;
    flow actuatorControl.run.diagnosticOut to safetySupervisor.run.diagnosticIn;
  }
}
