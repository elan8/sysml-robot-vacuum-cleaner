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

  enum def QueueDiscipline {
    overwriteLatest;
    fifoDropOldest;
    fifoDropNewest;
  }

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
    attribute period : DurationValue;
    attribute deadline : DurationValue;
    attribute criticality : TaskCriticality;
    attribute startupPhase : StartupPhase;
    attribute maxStackBytes : Integer;
    attribute maxStaticRamBytes : Integer;
    attribute wcetBudget : DurationValue;
  }

  part def SoftwareQueue {
    attribute depth : Natural;
    attribute discipline : QueueDiscipline;
    attribute maxAge : DurationValue;
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

  part def SchedulerModel {
    attribute tickPeriod : DurationValue;
    attribute schedulingPolicy : SchedulingPolicy;
    attribute overloadPolicy : String;
  }

  // Each task part owns a run action that declares typed directed item
  // parameters; flows in FirmwareTaskArchitecture couple run.x to run.y.
  part def MissionControllerTask :> FirmwareTask {
    doc /*
      Owns the authoritative mission-state mirror, command arbitration,
      low-battery return, bin/stall escalation, and mission-status publication.
      Safe-stop commands take priority over planner commands. Stale planner
      input is held for one period and then converted to a forced stop.
    */
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::missionReady;
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
    doc /*
      Aggregates hazards and diagnostics, owns latched fault and clear-debounce
      state, and commands a forced stop within the safe-stop budget. Input
      disagreement is treated as an active fault.
    */
    attribute :>> period = 10 [ms];
    attribute :>> deadline = 10 [ms];
    attribute :>> criticality = TaskCriticality::safetyCritical;
    attribute :>> startupPhase = StartupPhase::schedulerStart;
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
    doc /*
      Translates drive commands into PWM behavior, owns command/ramp/stall
      state, monitors encoders and driver faults, and publishes motion hazards.
      Forced stop overrides ramping; driver faults disable PWM until cleared.
    */
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> criticality = TaskCriticality::controlCritical;
    attribute :>> startupPhase = StartupPhase::schedulerStart;
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
    doc /*
      Polls ToF, cliff, IMU, and LiDAR inputs; owns sensor-health and last-good
      timestamps; and publishes hazards, scans, and obstacle observations.
      Safety GPIO is sampled before noncritical sensor reads.
    */
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> criticality = TaskCriticality::controlCritical;
    attribute :>> startupPhase = StartupPhase::schedulerStart;
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
    doc /*
      Fuses odometry, IMU, LiDAR, and pose-graph corrections into the pose
      estimate. Owns estimator error/degraded state and falls back to
      wheel/IMU prediction when scan or pose-graph input becomes stale.
    */
    attribute :>> period = 20 [ms];
    attribute :>> deadline = 20 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::missionReady;
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
    doc /*
      Maintains the pose-graph window and local occupancy-grid updates using
      2D scan matching. Publishes compact pose/map updates and retains the last
      stable map when matching confidence is insufficient.
    */
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::missionReady;
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
    doc /*
      Deferred flagship classifier. Its state and outputs are isolated from the
      selected baseline and shall not affect safety or navigation commands.
    */
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::deferredFlagship;
    attribute :>> startupPhase = StartupPhase::deferredStartup;
    attribute :>> maxStackBytes = 4096;
    attribute :>> maxStaticRamBytes = 32768;
    attribute :>> wcetBudget = 80 [ms];
    action run {
      out item obstacleClassOut : ObstacleClassEvent;
    }
  }

  // Planning, power, cleaning, app, diagnostic, and storage tasks.
  part def CoveragePlannerTask :> FirmwareTask {
    doc /*
      Converts pose and map updates into coverage commands and cell-state
      updates. Owns path/replanning state and requests recovery rather than
      emitting a forward command when no safe local path exists.
    */
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::missionReady;
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
    doc /*
      Owns battery telemetry freshness, low-battery threshold, and BMS fault
      state. Stale telemetry or a BMS alert publishes a hazard and requests
      mission return or stop according to severity.
    */
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::safetyCritical;
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 2048;
    attribute :>> wcetBudget = 5 [ms];
    action run {
      out item batteryTelemetryOut : BatteryTelemetry;
      out item hazardOut : HazardEvent;
    }
  }

  part def CleaningControlTask :> FirmwareTask {
    doc /*
      Owns brush/fan command and dust-bin debounce state. Actuator faults or a
      missing bin publish diagnostics and, where continued motion is unsafe,
      a hazard event.
    */
    attribute :>> period = 50 [ms];
    attribute :>> deadline = 50 [ms];
    attribute :>> criticality = TaskCriticality::missionCritical;
    attribute :>> startupPhase = StartupPhase::missionReady;
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
    doc /*
      Encodes and decodes the app protocol, owns version/consent/session state,
      and exposes mission and diagnostic summaries. Raw map updates are never
      serialized to the app path without an explicitly selected consent path.
    */
    attribute :>> period = 100 [ms];
    attribute :>> deadline = 100 [ms];
    attribute :>> criticality = TaskCriticality::userFacing;
    attribute :>> startupPhase = StartupPhase::missionReady;
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
    doc /*
      Aggregates diagnostics and owns the publication window. Duplicate
      diagnostics may be coalesced, but safety-critical diagnostics are never
      discarded.
    */
    attribute :>> period = 500 [ms];
    attribute :>> deadline = 500 [ms];
    attribute :>> criticality = TaskCriticality::diagnostic;
    attribute :>> startupPhase = StartupPhase::schedulerStart;
    attribute :>> maxStackBytes = 1536;
    attribute :>> maxStaticRamBytes = 4096;
    attribute :>> wcetBudget = 10 [ms];
    action run {
      in item diagnosticIn : DiagnosticEvent;
      out item diagnosticSummaryOut : DiagnosticEvent;
    }
  }

  part def StorageTask :> FirmwareTask {
    doc /*
      Persists local map, diagnostic, and maintenance state; owns wear-level and
      map-summary state; and prevents raw home-map geometry from entering the
      app-visible summary. Failed writes retain the RAM copy and emit diagnostics.
    */
    attribute :>> period = 1000 [ms];
    attribute :>> deadline = 1000 [ms];
    attribute :>> criticality = TaskCriticality::privacyCritical;
    attribute :>> startupPhase = StartupPhase::missionReady;
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

    // Runtime queues are first-class typed transport resources.
    part hazardQueue : HazardEventQueue {
      attribute :>> depth = 8;
      attribute :>> discipline = QueueDiscipline::fifoDropNewest;
      attribute :>> maxAge = 100 [ms];
      doc /* Overflow is represented by a synthetic safety-critical hazard. */
    }
    part userCommandQueue : UserCommandQueue {
      attribute :>> depth = 4;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 250 [ms];
      doc /* Retain the newest idempotent user command. */
    }
    part plannerCommandQueue : DriveCommandQueue {
      attribute :>> depth = 4;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 100 [ms];
      doc /* Retain the newest planner command; safety commands use a separate path. */
    }
    part safetyCommandQueue : DriveCommandQueue {
      attribute :>> depth = 2;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 20 [ms];
      doc /* Safety commands are isolated from planner traffic and always take priority. */
    }
    part mapUpdateQueue : MapUpdateQueue {
      attribute :>> depth = 16;
      attribute :>> discipline = QueueDiscipline::fifoDropOldest;
      attribute :>> maxAge = 5000 [ms];
      doc /* Coalesce old updates while preserving the latest cell state. */
    }

    // Producer -> queue -> consumer data flows.
    flow sensorAcquisition.run.lidarScanOut to slam.run.lidarScanIn;
    flow sensorAcquisition.run.lidarScanOut to localization.run.lidarScanIn;
    flow slam.run.poseGraphOut to localization.run.poseGraphIn;
    flow localization.run.poseOut to slam.run.poseIn;
    flow localization.run.poseOut to coveragePlanner.run.poseIn;
    flow slam.run.mapUpdateOut to mapUpdateQueue.transfer.enqueue;
    flow coveragePlanner.run.mapUpdateOut to mapUpdateQueue.transfer.enqueue;
    flow mapUpdateQueue.transfer.dequeue to storage.run.mapUpdateIn;
    flow coveragePlanner.run.plannerCommandOut to plannerCommandQueue.transfer.enqueue;
    flow plannerCommandQueue.transfer.dequeue to missionController.run.plannerCommandIn;
    flow batteryManager.run.batteryTelemetryOut to missionController.run.batteryTelemetryIn;
    flow batteryManager.run.batteryTelemetryOut to safetySupervisor.run.batteryTelemetryIn;
    flow batteryManager.run.hazardOut to hazardQueue.transfer.enqueue;
    flow sensorAcquisition.run.hazardOut to hazardQueue.transfer.enqueue;
    flow motorControl.run.hazardOut to hazardQueue.transfer.enqueue;
    flow cleaningControl.run.hazardOut to hazardQueue.transfer.enqueue;
    flow hazardQueue.transfer.dequeue to safetySupervisor.run.hazardIn;
    flow missionController.run.driveCommandOut to motorControl.run.driveCommandIn;
    flow safetySupervisor.run.safeStopCommandOut to safetyCommandQueue.transfer.enqueue;
    flow safetyCommandQueue.transfer.dequeue to motorControl.run.driveCommandIn;
    flow missionController.run.cleaningCommandOut to cleaningControl.run.cleaningCommandIn;
    flow missionController.run.missionStatusOut to appProtocol.run.missionStatusIn;
    flow appProtocol.run.userCommandOut to userCommandQueue.transfer.enqueue;
    flow userCommandQueue.transfer.dequeue to missionController.run.userCommandIn;
    flow userCommandQueue.transfer.dequeue to storage.run.userCommandIn;
    flow storage.run.mapSummaryOut to appProtocol.run.appMessageIn;
    flow motorControl.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow cleaningControl.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow safetySupervisor.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow storage.run.diagnosticOut to diagnostics.run.diagnosticIn;
    flow diagnostics.run.diagnosticSummaryOut to appProtocol.run.diagnosticIn;
    flow diagnostics.run.diagnosticSummaryOut to safetySupervisor.run.diagnosticIn;

    // Interface-control contracts for the most important task-to-task payloads.
    connection lidarScanToSlamContract : DataFlowContract {
      end producer ::> sensorAcquisition.run.lidarScanOut;
      end consumer ::> slam.run.lidarScanIn;
      attribute :>> period = 20 [ms];
      attribute :>> maxLatency = 50 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "scanRateHz nominal 10 Hz; includesRawImageData must be false";
    }
    connection lidarScanToLocalizationContract : DataFlowContract {
      end producer ::> sensorAcquisition.run.lidarScanOut;
      end consumer ::> localization.run.lidarScanIn;
      attribute :>> period = 20 [ms];
      attribute :>> maxLatency = 50 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "rangeSampleCount shall match selected LiDAR frame profile";
    }
    connection poseGraphToLocalizationContract : DataFlowContract {
      end producer ::> slam.run.poseGraphOut;
      end consumer ::> localization.run.poseGraphIn;
      attribute :>> period = 50 [ms];
      attribute :>> maxLatency = 100 [ms];
      attribute :>> privacySensitive = true;
      attribute :>> allowedValues = "mapStabilityScore range 0..100; no raw home map export";
    }
    connection mapUpdateToStorageContract : DataFlowContract {
      end producer ::> slam.run.mapUpdateOut;
      end consumer ::> storage.run.mapUpdateIn;
      attribute :>> period = 50 [ms];
      attribute :>> maxLatency = 1000 [ms];
      attribute :>> privacySensitive = true;
      attribute :>> allowedValues = "includesRawHomeMap may be true only for local storage";
    }
    connection plannerCommandToMissionContract : DataFlowContract {
      end producer ::> coveragePlanner.run.plannerCommandOut;
      end consumer ::> missionController.run.plannerCommandIn;
      attribute :>> period = 100 [ms];
      attribute :>> maxLatency = 100 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "forceStop false unless planner escalates obstacle recovery";
    }
    connection hazardToSafetyContract : DataFlowContract {
      end producer ::> sensorAcquisition.run.hazardOut;
      end consumer ::> safetySupervisor.run.hazardIn;
      attribute :>> period = 20 [ms];
      attribute :>> maxLatency = 100 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "severity safetyCritical requires safeStopRequired true";
    }
    connection missionStatusToAppContract : DataFlowContract {
      end producer ::> missionController.run.missionStatusOut;
      end consumer ::> appProtocol.run.missionStatusIn;
      attribute :>> period = 100 [ms];
      attribute :>> maxLatency = 500 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "stateName shall match public mission lifecycle vocabulary";
    }
    connection appCommandToMissionContract : DataFlowContract {
      end producer ::> appProtocol.run.userCommandOut;
      end consumer ::> missionController.run.userCommandIn;
      attribute :>> period = 100 [ms];
      attribute :>> maxLatency = 250 [ms];
      attribute :>> privacySensitive = true;
      attribute :>> allowedValues = "cloudBackupConsent changes require explicit consent command";
    }
    connection diagnosticSummaryToAppContract : DataFlowContract {
      end producer ::> diagnostics.run.diagnosticSummaryOut;
      end consumer ::> appProtocol.run.diagnosticIn;
      attribute :>> period = 500 [ms];
      attribute :>> maxLatency = 1000 [ms];
      attribute :>> privacySensitive = false;
      attribute :>> allowedValues = "severity info, warning, fault, or safetyCritical";
    }
  }
}
