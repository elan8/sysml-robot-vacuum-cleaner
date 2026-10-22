/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package FirmwareLibrary {
    private import Elan8::Units::Engineering::*;
    private import SI::*;
    private import DomainModel::*;
    private import Elan8::Software::*;
    abstract part def FirmwareTask :> Task;
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
}
