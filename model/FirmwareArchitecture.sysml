/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns firmware task definitions with typed in/out item interfaces, scheduler
 * assumptions, task criticality, and the task architecture instance whose flows
 * assert producer/consumer coupling. Depends on interface message items, shared
 * items, and software libraries. Keep physical harness wiring and message schema
 * definitions in their source packages.
 */
package FirmwareArchitecture {
  private import ArchitectureCommon::*;
  private import InterfaceControl::*;
  private import SoftwareCore::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def TaskCriticality {
    safetyCritical;
    missionCritical;
    controlCritical;
    userFacing;
    diagnostic;
    privacyCritical;
    deferredFlagship;
  }

  enum def SchedulingPolicy { fixedPriorityCooperative; }

  // A firmware task exposes its data interface as directed item features so
  // producer/consumer relationships can be asserted with typed flows rather
  // than free-form strings. Concrete tasks redefine timing and criticality.
  part def FirmwareTask :> SoftwareComponent {
    attribute taskName : String;
    attribute period : DurationValue;
    attribute deadline : DurationValue;
    attribute criticality : TaskCriticality;
  }

  part def SchedulerModel {
    attribute tickPeriod : DurationValue;
    attribute schedulingPolicy : SchedulingPolicy;
    attribute overloadPolicy : String;
  }

  // Each task part owns a run action that declares typed directed item
  // parameters; flows in FirmwareTaskArchitecture couple run.x to run.y.
  part def MissionControllerTask :> FirmwareTask {
    attribute :>> taskName = "MissionControllerTask";
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    action run {
      in item userCommandIn : UserCommand;
      in item batteryTelemetryIn : BatteryTelemetry;
      in item hazardIn : HazardEvent;
      in item plannerCommandIn : DriveCommand;
      out item driveCommandOut : DriveCommand;
      out item cleaningCommandOut : CleaningCommand;
      out item missionStatusOut : MissionStatus;
    }
  }

  part def SafetySupervisorTask :> FirmwareTask {
    attribute :>> taskName = "SafetySupervisorTask";
    attribute :>> period = 10 [ms];
    attribute :>> deadline = 10 [ms];
    attribute :>> criticality = TaskCriticality::safetyCritical;
    action run {
      in item hazardIn : HazardEvent;
      in item batteryTelemetryIn : BatteryTelemetry;
      in item diagnosticIn : DiagnosticEvent;
      out item safeStopCommandOut : DriveCommand;
      out item diagnosticOut : DiagnosticEvent;
    }
  }

  part def MotorControlTask :> FirmwareTask {
    attribute :>> taskName = "MotorControlTask";
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> criticality = TaskCriticality::controlCritical;
    action run {
      in item driveCommandIn : DriveCommand;
      out item hazardOut : HazardEvent;
      out item diagnosticOut : DiagnosticEvent;
    }
  }

  part def SensorAcquisitionTask :> FirmwareTask {
    attribute :>> taskName = "SensorAcquisitionTask";
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> criticality = TaskCriticality::controlCritical;
    action run {
      out item hazardOut : HazardEvent;
      out item lidarScanOut : LidarScanFrame;
      out item obstacleOut : ObstacleObservation;
    }
  }

  part def LocalizationTask :> FirmwareTask {
    attribute :>> taskName = "LocalizationTask";
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    action run {
      in item lidarScanIn : LidarScanFrame;
      in item poseGraphIn : PoseGraphUpdate;
      out item poseOut : PoseEstimate;
    }
  }

  part def SlamTask :> FirmwareTask {
    attribute :>> taskName = "SlamTask";
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    action run {
      in item lidarScanIn : LidarScanFrame;
      in item poseIn : PoseEstimate;
      out item poseGraphOut : PoseGraphUpdate;
      out item mapUpdateOut : MapUpdate;
    }
  }

  // Deferred flagship vision path retained for trade-study traceability.
  part def ObstacleClassificationTask :> FirmwareTask {
    attribute :>> taskName = "ObstacleClassificationTask";
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::deferredFlagship;
    action run {
      out item obstacleClassOut : ObstacleClassEvent;
    }
  }

  // Planning, power, cleaning, app, diagnostic, and storage tasks.
  part def CoveragePlannerTask :> FirmwareTask {
    attribute :>> taskName = "CoveragePlannerTask";
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    action run {
      in item poseIn : PoseEstimate;
      in item mapIn : OccupancyGrid;
      out item plannerCommandOut : DriveCommand;
      out item mapUpdateOut : MapUpdate;
    }
  }

  part def BatteryManagerTask :> FirmwareTask {
    attribute :>> taskName = "BatteryManagerTask";
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::safetyCritical;
    action run {
      out item batteryTelemetryOut : BatteryTelemetry;
      out item hazardOut : HazardEvent;
    }
  }

  part def CleaningControlTask :> FirmwareTask {
    attribute :>> taskName = "CleaningControlTask";
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    action run {
      in item cleaningCommandIn : CleaningCommand;
      out item diagnosticOut : DiagnosticEvent;
      out item hazardOut : HazardEvent;
    }
  }

  part def AppProtocolTask :> FirmwareTask {
    attribute :>> taskName = "AppProtocolTask";
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::userFacing;
    action run {
      in item appMessageIn : AppMessage;
      in item missionStatusIn : MissionStatus;
      in item diagnosticIn : DiagnosticEvent;
      out item userCommandOut : UserCommand;
      out item appMessageOut : AppMessage;
    }
  }

  part def DiagnosticsTask :> FirmwareTask {
    attribute :>> taskName = "DiagnosticsTask";
    attribute :>> period = 500 [ms];
    attribute :>> deadline = 500 [ms];
    attribute :>> criticality = TaskCriticality::diagnostic;
    action run {
      in item diagnosticIn : DiagnosticEvent;
      out item diagnosticSummaryOut : DiagnosticEvent;
    }
  }

  part def StorageTask :> FirmwareTask {
    attribute :>> taskName = "StorageTask";
    attribute :>> period = 1000 [ms];
    attribute :>> deadline = 1000 [ms];
    attribute :>> criticality = TaskCriticality::privacyCritical;
    action run {
      in item mapUpdateIn : MapUpdate;
      in item userCommandIn : UserCommand;
      out item diagnosticOut : DiagnosticEvent;
      out item mapSummaryOut : AppMessage;
    }
  }

  // Concrete task architecture used by allocation and view packages.
  part def FirmwareTaskArchitecture {
    part scheduler : SchedulerModel {
      attribute :>> tickPeriod = 1 [ms];
      attribute :>> schedulingPolicy = SchedulingPolicy::fixedPriorityCooperative;
      attribute :>> overloadPolicy = "drop noncritical app/status work before safety/control loops";
    }
    part missionController : MissionControllerTask;
    part safetySupervisor : SafetySupervisorTask;
    part motorControl : MotorControlTask;
    part sensorAcquisition : SensorAcquisitionTask;
    part localization : LocalizationTask;
    part slam : SlamTask;
    part coveragePlanner : CoveragePlannerTask;
    part batteryManager : BatteryManagerTask;
    part cleaningControl : CleaningControlTask;
    part appProtocol : AppProtocolTask;
    part diagnostics : DiagnosticsTask;
    part storage : StorageTask;
    part deferredObstacleClassification : ObstacleClassificationTask;

    // Producer -> consumer data flows (typed item transfers between task runs).
    flow sensorAcquisition.run.lidarScanOut to slam.run.lidarScanIn;
    flow sensorAcquisition.run.lidarScanOut to localization.run.lidarScanIn;
    flow slam.run.poseGraphOut to localization.run.poseGraphIn;
    flow localization.run.poseOut to slam.run.poseIn;
    flow localization.run.poseOut to coveragePlanner.run.poseIn;
    flow slam.run.mapUpdateOut to storage.run.mapUpdateIn;
    flow coveragePlanner.run.mapUpdateOut to storage.run.mapUpdateIn;
    flow coveragePlanner.run.plannerCommandOut to missionController.run.plannerCommandIn;
    flow batteryManager.run.batteryTelemetryOut to missionController.run.batteryTelemetryIn;
    flow batteryManager.run.batteryTelemetryOut to safetySupervisor.run.batteryTelemetryIn;
    flow batteryManager.run.hazardOut to safetySupervisor.run.hazardIn;
    flow sensorAcquisition.run.hazardOut to safetySupervisor.run.hazardIn;
    flow motorControl.run.hazardOut to safetySupervisor.run.hazardIn;
    flow cleaningControl.run.hazardOut to safetySupervisor.run.hazardIn;
    flow missionController.run.driveCommandOut to motorControl.run.driveCommandIn;
    flow safetySupervisor.run.safeStopCommandOut to motorControl.run.driveCommandIn;
    flow missionController.run.cleaningCommandOut to cleaningControl.run.cleaningCommandIn;
    flow missionController.run.missionStatusOut to appProtocol.run.missionStatusIn;
    flow appProtocol.run.userCommandOut to missionController.run.userCommandIn;
    flow appProtocol.run.userCommandOut to storage.run.userCommandIn;
    flow storage.run.mapSummaryOut to appProtocol.run.appMessageIn;
    flow motorControl.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow cleaningControl.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow safetySupervisor.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow storage.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow diagnostics.run.diagnosticSummaryOut to appProtocol.run.diagnosticIn;
    flow diagnostics.run.diagnosticSummaryOut to safetySupervisor.run.diagnosticIn;

    // Interface-control contracts for the most important task-to-task payloads.
    connection lidarScanToSlamContract : DataFlowContract {
      attribute :>> producerFeature = "sensorAcquisition.run.lidarScanOut";
      attribute :>> consumerFeature = "slam.run.lidarScanIn";
      attribute :>> payloadType = "LidarScanFrame";
      attribute :>> period = 20 [ms];
      attribute :>> maxLatency = 50 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "scanRateHz nominal 10 Hz; includesRawImageData must be false";
    }
    connection lidarScanToLocalizationContract : DataFlowContract {
      attribute :>> producerFeature = "sensorAcquisition.run.lidarScanOut";
      attribute :>> consumerFeature = "localization.run.lidarScanIn";
      attribute :>> payloadType = "LidarScanFrame";
      attribute :>> period = 20 [ms];
      attribute :>> maxLatency = 50 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "rangeSampleCount shall match selected LiDAR frame profile";
    }
    connection poseGraphToLocalizationContract : DataFlowContract {
      attribute :>> producerFeature = "slam.run.poseGraphOut";
      attribute :>> consumerFeature = "localization.run.poseGraphIn";
      attribute :>> payloadType = "PoseGraphUpdate";
      attribute :>> period = 50 [ms];
      attribute :>> maxLatency = 100 [ms];
      attribute :>> privacySensitive = true;
      attribute :>> allowedValues = "mapStabilityScore range 0..100; no raw home map export";
    }
    connection mapUpdateToStorageContract : DataFlowContract {
      attribute :>> producerFeature = "slam.run.mapUpdateOut";
      attribute :>> consumerFeature = "storage.run.mapUpdateIn";
      attribute :>> payloadType = "MapUpdate";
      attribute :>> period = 50 [ms];
      attribute :>> maxLatency = 1000 [ms];
      attribute :>> privacySensitive = true;
      attribute :>> allowedValues = "includesRawHomeMap may be true only for local storage";
    }
    connection plannerCommandToMissionContract : DataFlowContract {
      attribute :>> producerFeature = "coveragePlanner.run.plannerCommandOut";
      attribute :>> consumerFeature = "missionController.run.plannerCommandIn";
      attribute :>> payloadType = "DriveCommand";
      attribute :>> period = 100 [ms];
      attribute :>> maxLatency = 100 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "forceStop false unless planner escalates obstacle recovery";
    }
    connection hazardToSafetyContract : DataFlowContract {
      attribute :>> producerFeature = "sensorAcquisition.run.hazardOut";
      attribute :>> consumerFeature = "safetySupervisor.run.hazardIn";
      attribute :>> payloadType = "HazardEvent";
      attribute :>> period = 20 [ms];
      attribute :>> maxLatency = 100 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "severity safetyCritical requires safeStopRequired true";
    }
    connection missionStatusToAppContract : DataFlowContract {
      attribute :>> producerFeature = "missionController.run.missionStatusOut";
      attribute :>> consumerFeature = "appProtocol.run.missionStatusIn";
      attribute :>> payloadType = "MissionStatus";
      attribute :>> period = 100 [ms];
      attribute :>> maxLatency = 500 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "stateName shall match public mission lifecycle vocabulary";
    }
    connection appCommandToMissionContract : DataFlowContract {
      attribute :>> producerFeature = "appProtocol.run.userCommandOut";
      attribute :>> consumerFeature = "missionController.run.userCommandIn";
      attribute :>> payloadType = "UserCommand";
      attribute :>> period = 100 [ms];
      attribute :>> maxLatency = 250 [ms];
      attribute :>> privacySensitive = true;
      attribute :>> allowedValues = "cloudBackupConsent changes require explicit consent command";
    }
    connection diagnosticSummaryToAppContract : DataFlowContract {
      attribute :>> producerFeature = "diagnostics.run.diagnosticSummaryOut";
      attribute :>> consumerFeature = "appProtocol.run.diagnosticIn";
      attribute :>> payloadType = "DiagnosticEvent";
      attribute :>> period = 500 [ms];
      attribute :>> maxLatency = 1000 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "severity info, warning, fault, or safetyCritical";
    }
  }

  part firmwareTaskArchitecture : FirmwareTaskArchitecture;
}
