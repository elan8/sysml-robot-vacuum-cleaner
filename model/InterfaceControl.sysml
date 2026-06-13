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
    attribute :>> producer = "CoveragePlannerTask, MapProcessingSoftware";
    attribute :>> consumers = "StorageTask, AppProtocolTask";
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
