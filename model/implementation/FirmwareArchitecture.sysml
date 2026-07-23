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
  private import VacuumCleanerQuantitiesAndUnits::*;
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

  enum def StartupPhase {
    bootSelfTest;
    schedulerStart;
    missionReady;
    deferredStartup;
  }

  // A firmware task exposes its data interface as directed item features so
  // producer/consumer relationships can be asserted with typed flows rather
  // than free-form strings. Concrete tasks redefine timing and criticality.
  part def FirmwareTask :> SoftwareComponent {
    attribute taskName : String;
    attribute period : DurationValue;
    attribute deadline : DurationValue;
    attribute criticality : TaskCriticality;
    attribute startupPhase : StartupPhase;
    attribute stateOwnedByTask : String;
    attribute errorHandling : String;
    attribute maxStackBytes : Integer;
    attribute maxStaticRamBytes : Integer;
    attribute wcetBudget : DurationValue;
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "RobotOperatingBehavior state mirror; authoritative mission state for app status.";
    attribute :>> errorHandling = "On stale planner command, hold last safe command for one period then force stop; on hazard input, publish safe stop request in same activation.";
    attribute :>> maxStackBytes = 2048;
    attribute :>> maxStaticRamBytes = 4096;
    attribute :>> wcetBudget = 8 [ms];
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
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> stateOwnedByTask = "latched fault state and safe-stop-clear debounce.";
    attribute :>> errorHandling = "Fault input disagreement is treated as active fault; clear only after explicit safeStopCleared/service reset condition.";
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 2048;
    attribute :>> wcetBudget = 2 [ms];
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
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> stateOwnedByTask = "last command, stall timers, PWM ramp limiter.";
    attribute :>> errorHandling = "Driver fault or encoder stall publishes HazardEvent and disables PWM until mission controller clears.";
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 2048;
    attribute :>> wcetBudget = 5 [ms];
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
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> stateOwnedByTask = "sensor health and last-good sample timestamps.";
    attribute :>> errorHandling = "Missing LiDAR frame raises diagnostic; cliff sensor active-low fault raises safetyCritical hazard immediately.";
    attribute :>> maxStackBytes = 3072;
    attribute :>> maxStaticRamBytes = 12288;
    attribute :>> wcetBudget = 12 [ms];
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "pose estimate, covariance/error estimate, degraded-localization flag.";
    attribute :>> errorHandling = "On stale pose graph or LiDAR scan, degrade to wheel/IMU prediction and raise diagnostic after timeout.";
    attribute :>> maxStackBytes = 3072;
    attribute :>> maxStaticRamBytes = 16384;
    attribute :>> wcetBudget = 12 [ms];
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "pose graph window, loop closure candidate state, map stability score.";
    attribute :>> errorHandling = "If scan matching confidence drops below threshold, request localization degraded diagnostic and keep previous stable map.";
    attribute :>> maxStackBytes = 4096;
    attribute :>> maxStaticRamBytes = 49152;
    attribute :>> wcetBudget = 35 [ms];
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
    attribute :>> startupPhase = StartupPhase::deferredStartup;
    attribute :>> stateOwnedByTask = "deferred obstacle-classification state.";
    attribute :>> errorHandling = "Deferred baseline task shall not affect safety or navigation command output.";
    attribute :>> maxStackBytes = 4096;
    attribute :>> maxStaticRamBytes = 32768;
    attribute :>> wcetBudget = 80 [ms];
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "coverage path cursor, replanning state, unreachable-cell marking.";
    attribute :>> errorHandling = "If no safe local path exists, request obstacle recovery rather than emitting a forward command.";
    attribute :>> maxStackBytes = 3072;
    attribute :>> maxStaticRamBytes = 24576;
    attribute :>> wcetBudget = 40 [ms];
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
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> stateOwnedByTask = "battery telemetry freshness, low-battery threshold state, BMS fault mirror.";
    attribute :>> errorHandling = "BMS alert or stale telemetry emits HazardEvent and forces mission return or stop according to severity.";
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 2048;
    attribute :>> wcetBudget = 5 [ms];
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "brush/fan command state, dust-bin status debounce, cleaning actuator diagnostics.";
    attribute :>> errorHandling = "Actuator fault or missing bin emits DiagnosticEvent and HazardEvent when motion could continue unsafely.";
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 2048;
    attribute :>> wcetBudget = 8 [ms];
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "protocol version, consent state, session health.";
    attribute :>> errorHandling = "Malformed command frame is dropped and diagnostic warning is emitted; consent changes are idempotent.";
    attribute :>> maxStackBytes = 3072;
    attribute :>> maxStaticRamBytes = 8192;
    attribute :>> wcetBudget = 20 [ms];
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
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> stateOwnedByTask = "diagnostic aggregation window and last published summary.";
    attribute :>> errorHandling = "Dropped duplicate diagnostics are counted; safetyCritical diagnostics are never coalesced away.";
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 4096;
    attribute :>> wcetBudget = 10 [ms];
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
    attribute :>> startupPhase = StartupPhase::missionReady;
    attribute :>> stateOwnedByTask = "wear-level cursor, map summary cache, privacy consent flag mirror.";
    attribute :>> errorHandling = "On flash write failure, keep RAM cache, publish diagnostic and continue mission without cloud upload.";
    attribute :>> maxStackBytes = 2048;
    attribute :>> maxStaticRamBytes = 32768;
    attribute :>> wcetBudget = 100 [ms];
    action run {
      in item mapUpdateIn : MapUpdate;
      in item userCommandIn : UserCommand;
      out item diagnosticOut : DiagnosticEvent;
      out item mapSummaryOut : AppMessage;
    }
  }

  // Task architecture definition; the authoritative instance lives on
  // AutonomousFloorCleaningRobot.firmwareTasks in PhysicalArchitecture.
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
}
