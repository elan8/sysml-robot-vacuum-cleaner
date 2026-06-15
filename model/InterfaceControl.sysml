/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns software-facing data contracts and producer/consumer ownership for
 * commands, status, telemetry, maps, hazards, diagnostics, and app messages.
 * Depends on shared architecture items and software library concepts. Keep PCB
 * connector records in ElectricalInterfaces.
 */
package InterfaceControl {
  private import ArchitectureCommon::*;
  private import SoftwareCore::*;
  private import ScalarValues::*;

  item def MapUpdate {
    attribute sequenceNumber : Integer;
    attribute changedCellCount : Integer;
    attribute includesRawHomeMap : Boolean;
  }

  item def DiagnosticEvent {
    attribute diagnosticCode : String;
    attribute severity : String;
    attribute latched : Boolean;
  }

  item def AppMessage {
    attribute messageKind : String;
    attribute protocolVersion : String;
    attribute requiresConsent : Boolean;
  }

  item def LidarScanFrame {
    attribute scanSequence : Integer;
    attribute scanRateHz : Real;
    attribute rangeSampleCount : Integer;
    attribute includesRawImageData : Boolean;
  }

  item def PoseGraphUpdate {
    attribute nodeCount : Integer;
    attribute loopClosureCandidateCount : Integer;
    attribute mapStabilityScore : Real;
  }

  item def ObstacleClassEvent {
    attribute className : String;
    attribute confidencePercent : Real;
    attribute sourceSensor : String;
  }

  part def DataContract {
    attribute contractName : String;
    attribute payloadType : String;
    attribute allowedValues : String;
    attribute ownerTask : String;
    attribute producer : String;
    attribute consumers : String;
  }

  part driveCommandContract : DataContract {
    attribute :>> contractName = "DriveCommand";
    attribute :>> payloadType = "linearVelocityMmPerS, angularVelocityDegPerS, forceStop";
    attribute :>> allowedValues = "forceStop true overrides velocity commands";
    attribute :>> ownerTask = "MissionControllerTask";
    attribute :>> producer = "MissionControllerTask or SafetySupervisorTask";
    attribute :>> consumers = "MotorControlTask";
  }

  part cleaningCommandContract : DataContract {
    attribute :>> contractName = "CleaningCommand";
    attribute :>> payloadType = "brushEnabled, vacuumPowerMode, requestedPowerW";
    attribute :>> allowedValues = "vacuumPowerMode: eco, standard, max, off";
    attribute :>> ownerTask = "MissionControllerTask";
    attribute :>> producer = "MissionControllerTask";
    attribute :>> consumers = "CleaningControlTask";
  }

  part hazardEventContract : DataContract {
    attribute :>> contractName = "HazardEvent";
    attribute :>> payloadType = "hazardKind, severity, detectedWithinMs, safeStopRequired";
    attribute :>> allowedValues = "hazardKind: cliff, bumper, lift, overcurrent, thermal, stall, privacy";
    attribute :>> ownerTask = "SafetySupervisorTask";
    attribute :>> producer = "SensorAcquisitionTask, MotorControlTask, BatteryManagerTask, DiagnosticsTask";
    attribute :>> consumers = "SafetySupervisorTask, MissionControllerTask";
  }

  part missionStatusContract : DataContract {
    attribute :>> contractName = "MissionStatus";
    attribute :>> payloadType = "stateName, cleanedAreaPercent, userAttentionRequired";
    attribute :>> allowedValues = "stateName follows RobotOperatingBehavior state usages";
    attribute :>> ownerTask = "MissionControllerTask";
    attribute :>> producer = "MissionControllerTask";
    attribute :>> consumers = "AppProtocolTask, DiagnosticsTask";
  }

  part batteryTelemetryContract : DataContract {
    attribute :>> contractName = "BatteryTelemetry";
    attribute :>> payloadType = "stateOfChargePercent, packVoltageV, chargeCurrentA, maxCellTemperatureK";
    attribute :>> allowedValues = "low battery event below 15 percent state of charge";
    attribute :>> ownerTask = "BatteryManagerTask";
    attribute :>> producer = "BatteryManagerTask";
    attribute :>> consumers = "MissionControllerTask, SafetySupervisorTask, AppProtocolTask";
  }

  part userCommandContract : DataContract {
    attribute :>> contractName = "UserCommand";
    attribute :>> payloadType = "commandKind, cloudBackupConsent";
    attribute :>> allowedValues = "commandKind: start, pause, resume, home, empty-bin-confirmed, consent-changed";
    attribute :>> ownerTask = "AppProtocolTask";
    attribute :>> producer = "AppProtocolTask or HMI input";
    attribute :>> consumers = "MissionControllerTask, StorageTask";
  }

  part mapUpdateContract : DataContract {
    attribute :>> contractName = "MapUpdate";
    attribute :>> payloadType = "sequenceNumber, changedCellCount, includesRawHomeMap";
    attribute :>> allowedValues = "includesRawHomeMap false for app status; true only inside local storage boundary";
    attribute :>> ownerTask = "StorageTask";
    attribute :>> producer = "SlamTask, CoveragePlannerTask, MapProcessingSoftware";
    attribute :>> consumers = "StorageTask, AppProtocolTask";
  }

  part lidarScanFrameContract : DataContract {
    attribute :>> contractName = "LidarScanFrame";
    attribute :>> payloadType = "scanSequence, scanRateHz, rangeSampleCount, includesRawImageData";
    attribute :>> allowedValues = "includesRawImageData false; scan frames contain range/intensity samples only";
    attribute :>> ownerTask = "SensorAcquisitionTask";
    attribute :>> producer = "SensorAcquisitionTask";
    attribute :>> consumers = "SlamTask, LocalizationTask";
  }

  part poseGraphUpdateContract : DataContract {
    attribute :>> contractName = "PoseGraphUpdate";
    attribute :>> payloadType = "nodeCount, loopClosureCandidateCount, mapStabilityScore";
    attribute :>> allowedValues = "mapStabilityScore 0.0 to 1.0; loop closure candidates reviewed locally";
    attribute :>> ownerTask = "SlamTask";
    attribute :>> producer = "SlamTask";
    attribute :>> consumers = "LocalizationTask, CoveragePlannerTask, StorageTask, AppProtocolTask";
  }

  part obstacleClassEventContract : DataContract {
    attribute :>> contractName = "ObstacleClassEvent";
    attribute :>> payloadType = "className, confidencePercent, sourceSensor";
    attribute :>> allowedValues = "deferred flagship AI vision option; className examples: cable, pet-waste, shoe, unknown";
    attribute :>> ownerTask = "ObstacleClassificationTask";
    attribute :>> producer = "ObstacleClassificationTask";
    attribute :>> consumers = "SafetySupervisorTask, MissionControllerTask";
  }

  part diagnosticEventContract : DataContract {
    attribute :>> contractName = "DiagnosticEvent";
    attribute :>> payloadType = "diagnosticCode, severity, latched";
    attribute :>> allowedValues = "severity: info, warning, fault, safety-critical";
    attribute :>> ownerTask = "DiagnosticsTask";
    attribute :>> producer = "all firmware tasks";
    attribute :>> consumers = "DiagnosticsTask, AppProtocolTask, SafetySupervisorTask";
  }

  part appMessageContract : DataContract {
    attribute :>> contractName = "AppMessage";
    attribute :>> payloadType = "messageKind, protocolVersion, requiresConsent";
    attribute :>> allowedValues = "messageKind: command, status, map-summary, diagnostic, consent";
    attribute :>> ownerTask = "AppProtocolTask";
    attribute :>> producer = "AppProtocolTask";
    attribute :>> consumers = "MobileAppInterface, StorageTask";
  }
}
