package FirmwareArchitecture {
  private import ArchitectureCommon::*;
  private import InterfaceControl::*;
  private import PhysicalArchitecture::*;
  private import SoftwareCore::*;
  private import ScalarValues::*;

  part def FirmwareTask :> SoftwareComponent {
    attribute taskName : String;
    attribute periodMs : Real;
    attribute deadlineMs : Real;
    attribute criticality : String;
    attribute owningFirmwareModule : String;
    attribute allocatedTarget : String;
    attribute consumesContracts : String;
    attribute producesContracts : String;
  }

  part def SchedulerModel {
    attribute tickPeriodMs : Real;
    attribute schedulingPolicy : String;
    attribute overloadPolicy : String;
  }

  part def MissionControllerTask :> FirmwareTask {
    attribute :>> taskName = "MissionControllerTask";
    attribute :>> periodMs = 50.0;
    attribute :>> deadlineMs = 50.0;
    attribute :>> criticality = "mission-critical";
    attribute :>> owningFirmwareModule = "ApplicationFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "UserCommand, BatteryTelemetry, HazardEvent, DriveCommand planner input";
    attribute :>> producesContracts = "DriveCommand, CleaningCommand, MissionStatus";
  }

  part def SafetySupervisorTask :> FirmwareTask {
    attribute :>> taskName = "SafetySupervisorTask";
    attribute :>> periodMs = 10.0;
    attribute :>> deadlineMs = 10.0;
    attribute :>> criticality = "safety-critical";
    attribute :>> owningFirmwareModule = "SafetySupervisorFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "HazardEvent, BatteryTelemetry, DiagnosticEvent";
    attribute :>> producesContracts = "DriveCommand forceStop, DiagnosticEvent";
  }

  part def MotorControlTask :> FirmwareTask {
    attribute :>> taskName = "MotorControlTask";
    attribute :>> periodMs = 20.0;
    attribute :>> deadlineMs = 20.0;
    attribute :>> criticality = "control-critical";
    attribute :>> owningFirmwareModule = "ApplicationFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "DriveCommand";
    attribute :>> producesContracts = "HazardEvent, DiagnosticEvent";
  }

  part def SensorAcquisitionTask :> FirmwareTask {
    attribute :>> taskName = "SensorAcquisitionTask";
    attribute :>> periodMs = 20.0;
    attribute :>> deadlineMs = 20.0;
    attribute :>> criticality = "control-critical";
    attribute :>> owningFirmwareModule = "MapProcessingSoftware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "sensor I2C samples, LiDAR serial scan frames, safety GPIO";
    attribute :>> producesContracts = "HazardEvent, LidarScanFrame, MapUpdate input observations";
  }

  part def LocalizationTask :> FirmwareTask {
    attribute :>> taskName = "LocalizationTask";
    attribute :>> periodMs = 20.0;
    attribute :>> deadlineMs = 20.0;
    attribute :>> criticality = "mission-critical";
    attribute :>> owningFirmwareModule = "LocalizationEstimatorSoftware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "odometry, IMU, LiDAR scan frames, ToF observations, PoseGraphUpdate";
    attribute :>> producesContracts = "PoseEstimate";
  }

  part def SlamTask :> FirmwareTask {
    attribute :>> taskName = "SlamTask";
    attribute :>> periodMs = 50.0;
    attribute :>> deadlineMs = 50.0;
    attribute :>> criticality = "mission-critical";
    attribute :>> owningFirmwareModule = "MapProcessingSoftware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "LidarScanFrame, PoseEstimate, ToF observations";
    attribute :>> producesContracts = "PoseGraphUpdate, MapUpdate";
  }

  part def ObstacleClassificationTask :> FirmwareTask {
    attribute :>> taskName = "ObstacleClassificationTask";
    attribute :>> periodMs = 100.0;
    attribute :>> deadlineMs = 100.0;
    attribute :>> criticality = "deferred flagship";
    attribute :>> owningFirmwareModule = "DeferredVisionObstacleSoftware";
    attribute :>> allocatedTarget = "AiInferenceAccelerator";
    attribute :>> consumesContracts = "RGB/3D ToF frames";
    attribute :>> producesContracts = "ObstacleClassEvent";
  }

  part def CoveragePlannerTask :> FirmwareTask {
    attribute :>> taskName = "CoveragePlannerTask";
    attribute :>> periodMs = 100.0;
    attribute :>> deadlineMs = 100.0;
    attribute :>> criticality = "mission-critical";
    attribute :>> owningFirmwareModule = "CoveragePlannerSoftware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "PoseEstimate, OccupancyGrid";
    attribute :>> producesContracts = "DriveCommand planner input, MapUpdate";
  }

  part def BatteryManagerTask :> FirmwareTask {
    attribute :>> taskName = "BatteryManagerTask";
    attribute :>> periodMs = 100.0;
    attribute :>> deadlineMs = 100.0;
    attribute :>> criticality = "safety-critical";
    attribute :>> owningFirmwareModule = "SafetySupervisorFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "BMS SMBus telemetry";
    attribute :>> producesContracts = "BatteryTelemetry, HazardEvent";
  }

  part def CleaningControlTask :> FirmwareTask {
    attribute :>> taskName = "CleaningControlTask";
    attribute :>> periodMs = 50.0;
    attribute :>> deadlineMs = 50.0;
    attribute :>> criticality = "mission-critical";
    attribute :>> owningFirmwareModule = "ApplicationFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "CleaningCommand";
    attribute :>> producesContracts = "DiagnosticEvent, HazardEvent";
  }

  part def AppProtocolTask :> FirmwareTask {
    attribute :>> taskName = "AppProtocolTask";
    attribute :>> periodMs = 100.0;
    attribute :>> deadlineMs = 100.0;
    attribute :>> criticality = "user-facing";
    attribute :>> owningFirmwareModule = "ApplicationFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "AppMessage, MissionStatus, DiagnosticEvent";
    attribute :>> producesContracts = "UserCommand, AppMessage";
  }

  part def DiagnosticsTask :> FirmwareTask {
    attribute :>> taskName = "DiagnosticsTask";
    attribute :>> periodMs = 500.0;
    attribute :>> deadlineMs = 500.0;
    attribute :>> criticality = "diagnostic";
    attribute :>> owningFirmwareModule = "ApplicationFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "DiagnosticEvent from all tasks";
    attribute :>> producesContracts = "DiagnosticEvent summary";
  }

  part def StorageTask :> FirmwareTask {
    attribute :>> taskName = "StorageTask";
    attribute :>> periodMs = 1000.0;
    attribute :>> deadlineMs = 1000.0;
    attribute :>> criticality = "privacy-critical";
    attribute :>> owningFirmwareModule = "ApplicationFirmware";
    attribute :>> allocatedTarget = "MicrocontrollerUnit";
    attribute :>> consumesContracts = "MapUpdate, UserCommand cloudBackupConsent";
    attribute :>> producesContracts = "DiagnosticEvent, AppMessage map-summary";
  }

  part def FirmwareTaskArchitecture {
    ref firmwareSuite : RobotFirmwareSuite;
    ref mcu : MicrocontrollerUnit;
    part scheduler : SchedulerModel {
      attribute :>> tickPeriodMs = 1.0;
      attribute :>> schedulingPolicy = "fixed-priority cooperative with bounded interrupt service";
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
  }

  part firmwareTaskArchitecture : FirmwareTaskArchitecture;
}
