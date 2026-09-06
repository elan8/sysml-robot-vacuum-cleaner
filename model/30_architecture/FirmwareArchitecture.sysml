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

  abstract part def FirmwareTask :> RealtimeTask;
  abstract part def PeriodicFirmwareTask :> FirmwareTask, PeriodicTask;
  abstract part def EventDrivenFirmwareTask :> FirmwareTask, EventDrivenTask;

  port def HazardEventQueuePort {
    in item input : HazardEvent;
    out item output : HazardEvent;
  }
  port def UserCommandQueuePort {
    in item input : UserCommand;
    out item output : UserCommand;
  }
  port def DriveCommandQueuePort {
    in item input : DriveCommand;
    out item output : DriveCommand;
  }
  port def MapUpdateQueuePort {
    in item input : MapUpdate;
    out item output : MapUpdate;
  }

  part def HazardEventQueue :> SoftwareQueue {
    port messages : HazardEventQueuePort;
  }
  part def UserCommandQueue :> SoftwareQueue {
    port messages : UserCommandQueuePort;
  }
  part def DriveCommandQueue :> SoftwareQueue {
    port messages : DriveCommandQueuePort;
  }
  part def MapUpdateQueue :> SoftwareQueue {
    port messages : MapUpdateQueuePort;
  }

  part def MissionControllerTask :> EventDrivenFirmwareTask {
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

  part def SafetySupervisorTask :> EventDrivenFirmwareTask {
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

  part def ActuatorControlTask :> PeriodicFirmwareTask {
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

  part def SensorAcquisitionTask :> PeriodicFirmwareTask {
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

  part def NavigationTask :> PeriodicFirmwareTask {
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

  part def PowerManagerTask :> PeriodicFirmwareTask {
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> priority = 5;
    attribute :>> criticality = TaskCriticality::safetyCritical;
    action run {
      out item telemetryOut : BatteryTelemetry;
      out item hazardOut : HazardEvent;
    }
  }

  part def AppServiceTask :> EventDrivenFirmwareTask {
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
      attribute :>> discipline = QueueDiscipline::fifoDropNewest;
    }
    part userCommandQueue : UserCommandQueue {
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
    }
    part plannerCommandQueue : DriveCommandQueue {
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
    }
    part safetyCommandQueue : DriveCommandQueue {
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
    }
    part mapUpdateQueue : MapUpdateQueue {
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
  }
}
