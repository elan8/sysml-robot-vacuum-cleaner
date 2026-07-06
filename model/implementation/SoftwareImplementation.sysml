/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns implementation-facing software records derived from firmware
 * architecture, interface control, physical architecture, requirements, and
 * verification intent. Keep primary architecture facts such as task timing,
 * startup, state ownership, error handling, and resource budgets in
 * FirmwareArchitecture; this package organizes trace and implementation notes
 * for tool extraction.
 */
package SoftwareImplementation {
  private import ArchitectureCommon::*;
  private import InterfaceControl::*;
  private import FirmwareArchitecture::*;
  private import PhysicalArchitecture::*;
  private import SystemRequirements::*;
  private import Verification::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def SerializationFormat {
    packedLittleEndianC;
    appJsonV1;
    internalQueueObject;
  }

  enum def QueueDiscipline {
    overwriteLatest;
    fifoDropOldest;
    fifoDropNewest;
    blockingNotAllowed;
  }

  enum def HalAccessKind {
    i2cMaster;
    uartDma;
    pwmOutput;
    gpioInput;
    gpioOutput;
    quadratureTimer;
    adcOrTelemetry;
    flashStorage;
    wirelessUart;
  }

  part def SoftwareImplementationRecord {
    attribute taskPath : String;
    attribute owningModulePath : String;
    attribute requirementRefs : String;
    attribute verificationRefs : String;
    attribute mainResponsibility : String;
    attribute algorithmNotes : String;
    attribute unitTestIntent : String;
    attribute integrationTestIntent : String;
  }

  part def MessageFieldRule {
    attribute messageType : String;
    attribute fieldName : String;
    attribute representation : String;
    attribute unit : String;
    attribute range : String;
    attribute defaultValue : String;
    attribute invalidValuePolicy : String;
  }

  part def QueueContract {
    attribute queueName : String;
    attribute producerTaskPath : String;
    attribute consumerTaskPath : String;
    attribute payloadType : String;
    attribute depth : Integer;
    attribute discipline : QueueDiscipline;
    attribute maxAge : DurationValue;
    attribute overflowHandling : String;
  }

  part def HalBinding {
    attribute bindingName : String;
    attribute taskPath : String;
    attribute physicalFeaturePath : String;
    attribute accessKind : HalAccessKind;
    attribute driverApi : String;
    attribute timingRequirement : String;
    attribute faultPolicy : String;
  }

  part def SoftwareHandoffPackage {
    doc /*
      Engineer-facing software implementation record package. The path
      attributes refer to semantic source elements in FirmwareArchitecture,
      InterfaceControl, PhysicalArchitecture, SystemRequirements, and
      Verification. Runtime facts such as startup phase, state ownership,
      error handling, stack/RAM, and WCET are owned by the firmware task
      definitions.
    */

    // Firmware task implementation records.
    part missionControllerImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.missionController";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "reportCleaningStatus, recoverFromStall, superviseHazards, returnToDock";
      attribute :>> verificationRefs = "verifyFirmwareSchedulerTiming, verifyStallRecovery, verifyDockingSuccess, verifyProtocolContracts";
      attribute :>> mainResponsibility = "Mission state arbitration, command fan-out, low-battery return, bin/stall escalation, mission status publication.";
      attribute :>> algorithmNotes = "Prioritize safeStopCommand over planner drive command; reject cleaning start when bin is missing or unlatched.";
      attribute :>> unitTestIntent = "state transitions, command arbitration priority, stale input handling, low battery transition.";
      attribute :>> integrationTestIntent = "app command to mission state, planner command to motor command, safe-stop reaction chain.";
    }

    part safetySupervisorImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.safetySupervisor";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.safetySupervisor";
      attribute :>> requirementRefs = "superviseHazards, detectCliffs, chargeSafely";
      attribute :>> verificationRefs = "verifyCliffDetection, verifyLiftOvercurrentThermalHazards, verifyFirmwareSchedulerTiming";
      attribute :>> mainResponsibility = "Aggregate hazards and diagnostics, latch safety-critical faults, command force stop within safe-stop budget.";
      attribute :>> algorithmNotes = "Any safetyCritical HazardEvent or active-low GPIO fault produces DriveCommand.forceStop=true.";
      attribute :>> unitTestIntent = "hazard severity mapping, latch/clear behavior, diagnostic escalation.";
      attribute :>> integrationTestIntent = "GPIO fault to motor stop, BMS alert to mission safe stop, diagnostics to app.";
    }

    part sensorAcquisitionImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.sensorAcquisition";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.mapProcessing";
      attribute :>> requirementRefs = "avoidObstacles, detectCliffs, supportRoomScaleSlam";
      attribute :>> verificationRefs = "verifyObstacleAvoidance, verifyCliffDetection, verifyRoomScaleSlam, verifyElectricalInterfaceControl";
      attribute :>> mainResponsibility = "Poll ToF, cliff, IMU and LiDAR drivers; publish HazardEvent, LidarScanFrame and obstacle observations.";
      attribute :>> algorithmNotes = "Timestamp each scan frame at acquisition; cliff GPIO is sampled every period before noncritical sensor reads.";
      attribute :>> unitTestIntent = "sample normalization, stale-frame detection, cliff debounce.";
      attribute :>> integrationTestIntent = "I2C address map, UART frame parser, safety GPIO aggregation.";
    }

    part slamImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.slam";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.mapProcessing";
      attribute :>> requirementRefs = "supportRoomScaleSlam, updateCoverageMap, localizeReliably";
      attribute :>> verificationRefs = "verifyRoomScaleSlam, verifyCoverageMap, verifyLocalizationAccuracy";
      attribute :>> mainResponsibility = "Maintain pose graph and local occupancy-grid updates from LiDAR and fused pose input.";
      attribute :>> algorithmNotes = "Use 2D scan matching against local grid; publish compact PoseGraphUpdate and MapUpdate, not raw home map to app path.";
      attribute :>> unitTestIntent = "pose graph update bounds, loop closure candidate scoring, map update privacy flag.";
      attribute :>> integrationTestIntent = "LiDAR scan to map update, map update to storage, localization feedback loop.";
    }

    part localizationImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.localization";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.localizationEstimator";
      attribute :>> requirementRefs = "localizeReliably, supportRoomScaleSlam";
      attribute :>> verificationRefs = "verifyLocalizationAccuracy, verifyRoomScaleSlam, verifyFirmwareSchedulerTiming";
      attribute :>> mainResponsibility = "Fuse wheel odometry, IMU, LiDAR scan features, and pose-graph corrections into PoseEstimate.";
      attribute :>> algorithmNotes = "Publish PoseEstimate.errorMm; keep error below maxLocalizationError during standard layout mission.";
      attribute :>> unitTestIntent = "pose propagation, correction application, stale-input fallback.";
      attribute :>> integrationTestIntent = "encoder/IMU/LiDAR fusion and coverage planner consumption.";
    }

    part coveragePlannerImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.coveragePlanner";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.coveragePlanner";
      attribute :>> requirementRefs = "coverFloor, updateCoverageMap, cleanAtLeastEighty";
      attribute :>> verificationRefs = "verifyCleaningCoverage, verifyCoverageMap, verifyRoomScaleSlam";
      attribute :>> mainResponsibility = "Convert pose and map updates into drive commands and cleaned/unreachable/unknown map updates.";
      attribute :>> algorithmNotes = "Use boustrophedon path over known free cells; replan around dynamic obstacle observations.";
      attribute :>> unitTestIntent = "cell-state transitions, path cursor, obstacle replanning.";
      attribute :>> integrationTestIntent = "map update to planner command and mission controller arbitration.";
    }

    part motorControlImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.motorControl";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "avoidObstacles, recoverFromStall, superviseHazards";
      attribute :>> verificationRefs = "verifyStallRecovery, verifyLiftOvercurrentThermalHazards, verifyFirmwareSchedulerTiming";
      attribute :>> mainResponsibility = "Translate DriveCommand into PWM outputs, monitor encoders and driver faults, publish motion hazards.";
      attribute :>> algorithmNotes = "Force stop overrides all ramping; stall detection threshold is 2 s maximum.";
      attribute :>> unitTestIntent = "command saturation, force stop, ramp limiting, stall timer.";
      attribute :>> integrationTestIntent = "PWM outputs, encoder inputs, motor driver fault GPIO.";
    }

    part appProtocolImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.appProtocol";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "reportCleaningStatus, protectMapPrivacy, notifyMaintenanceNeeded";
      attribute :>> verificationRefs = "verifyProtocolContracts, verifyPrivacyControls, verifyFirmwareSchedulerTiming";
      attribute :>> mainResponsibility = "Encode/decode app protocol, publish user commands, expose mission and diagnostic summaries.";
      attribute :>> algorithmNotes = "Never serialize raw MapUpdate to app; use map summary only unless explicit cloud backup consent is enabled.";
      attribute :>> unitTestIntent = "JSON schema encoding/decoding, consent command handling, malformed frame behavior.";
      attribute :>> integrationTestIntent = "BLE/Wi-Fi UART transport and app command to mission controller.";
    }

    part storageImplementation : SoftwareImplementationRecord {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.storage";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "protectMapPrivacy, updateCoverageMap, notifyMaintenanceNeeded";
      attribute :>> verificationRefs = "verifyPrivacyControls, verifyCoverageMap, verifyProtocolContracts";
      attribute :>> mainResponsibility = "Persist local map updates, diagnostics and maintenance state to external flash.";
      attribute :>> algorithmNotes = "Store raw map locally only; app-visible mapSummaryOut must not include raw home map geometry.";
      attribute :>> unitTestIntent = "wear-level record lifecycle, privacy filter, map summary generation.";
      attribute :>> integrationTestIntent = "SPI flash driver, map update persistence, app map summary contract.";
    }

    // Message field and serialization rules.
    part driveCommandForceStopRule : MessageFieldRule {
      attribute :>> messageType = "DriveCommand";
      attribute :>> fieldName = "forceStop";
      attribute :>> representation = "bool";
      attribute :>> unit = "none";
      attribute :>> range = "false,true";
      attribute :>> defaultValue = "false";
      attribute :>> invalidValuePolicy = "treat invalid/missing as true in safety supervisor output path";
    }
    part driveCommandLinearVelocityRule : MessageFieldRule {
      attribute :>> messageType = "DriveCommand";
      attribute :>> fieldName = "linearVelocityMmPerS";
      attribute :>> representation = "int16 little-endian";
      attribute :>> unit = "mm/s";
      attribute :>> range = "-350..350";
      attribute :>> defaultValue = "0";
      attribute :>> invalidValuePolicy = "saturate and emit diagnostic warning";
    }
    part hazardSeverityRule : MessageFieldRule {
      attribute :>> messageType = "HazardEvent";
      attribute :>> fieldName = "severity";
      attribute :>> representation = "uint8 enum Severity";
      attribute :>> unit = "none";
      attribute :>> range = "info, warning, fault, safetyCritical";
      attribute :>> defaultValue = "fault";
      attribute :>> invalidValuePolicy = "map to safetyCritical";
    }
    part mapUpdatePrivacyRule : MessageFieldRule {
      attribute :>> messageType = "MapUpdate";
      attribute :>> fieldName = "includesRawHomeMap";
      attribute :>> representation = "bool";
      attribute :>> unit = "none";
      attribute :>> range = "false,true";
      attribute :>> defaultValue = "false";
      attribute :>> invalidValuePolicy = "drop app-bound frame if true";
    }
    part appMessageVersionRule : MessageFieldRule {
      attribute :>> messageType = "AppMessage";
      attribute :>> fieldName = "protocolVersion";
      attribute :>> representation = "UTF-8 string max 16 bytes";
      attribute :>> unit = "none";
      attribute :>> range = "v1";
      attribute :>> defaultValue = "v1";
      attribute :>> invalidValuePolicy = "reject frame and emit diagnostic warning";
    }

    // Runtime queue contracts.
    part hazardQueue : QueueContract {
      attribute :>> queueName = "hazardQueue";
      attribute :>> producerTaskPath = "sensorAcquisition, motorControl, cleaningControl, batteryManager";
      attribute :>> consumerTaskPath = "safetySupervisor";
      attribute :>> payloadType = "HazardEvent";
      attribute :>> depth = 8;
      attribute :>> discipline = QueueDiscipline::fifoDropNewest;
      attribute :>> maxAge = 100 [ms];
      attribute :>> overflowHandling = "publish synthetic safetyCritical overflow hazard";
    }
    part missionCommandQueue : QueueContract {
      attribute :>> queueName = "missionCommandQueue";
      attribute :>> producerTaskPath = "appProtocol, coveragePlanner, safetySupervisor";
      attribute :>> consumerTaskPath = "missionController";
      attribute :>> payloadType = "UserCommand or DriveCommand";
      attribute :>> depth = 4;
      attribute :>> discipline = QueueDiscipline::overwriteLatest;
      attribute :>> maxAge = 250 [ms];
      attribute :>> overflowHandling = "keep latest safety command and drop older planner commands";
    }
    part mapUpdateQueue : QueueContract {
      attribute :>> queueName = "mapUpdateQueue";
      attribute :>> producerTaskPath = "slam, coveragePlanner";
      attribute :>> consumerTaskPath = "storage";
      attribute :>> payloadType = "MapUpdate";
      attribute :>> depth = 16;
      attribute :>> discipline = QueueDiscipline::fifoDropOldest;
      attribute :>> maxAge = 5000 [ms];
      attribute :>> overflowHandling = "coalesce updates and preserve latest cell state";
    }

    // HAL and driver bindings.
    part sensorI2cHal : HalBinding {
      attribute :>> bindingName = "sensorI2cHal";
      attribute :>> taskPath = "sensorAcquisition";
      attribute :>> physicalFeaturePath = "mainElectronics.mainControlPcb.sensorBusHarness";
      attribute :>> accessKind = HalAccessKind::i2cMaster;
      attribute :>> driverApi = "hal_i2c_transfer(sensor_bus, address, tx, rx, timeout_ms)";
      attribute :>> timingRequirement = "complete ToF and IMU reads inside 20 ms acquisition period";
      attribute :>> faultPolicy = "NACK or timeout increments sensor fault counter and may emit HazardEvent";
    }
    part lidarUartHal : HalBinding {
      attribute :>> bindingName = "lidarUartHal";
      attribute :>> taskPath = "sensorAcquisition";
      attribute :>> physicalFeaturePath = "mainElectronics.mainControlPcb.lidarUartHarness";
      attribute :>> accessKind = HalAccessKind::uartDma;
      attribute :>> driverApi = "hal_uart_dma_read(lidar_uart, frame_buffer)";
      attribute :>> timingRequirement = "deliver complete scan frame to queue within 50 ms";
      attribute :>> faultPolicy = "bad checksum drops frame and emits diagnostic after three consecutive failures";
    }
    part motorPwmHal : HalBinding {
      attribute :>> bindingName = "motorPwmHal";
      attribute :>> taskPath = "motorControl";
      attribute :>> physicalFeaturePath = "mainElectronics.mainControlPcb.mcu.leftMotorPwm/rightMotorPwm";
      attribute :>> accessKind = HalAccessKind::pwmOutput;
      attribute :>> driverApi = "hal_pwm_set_duty(motor_channel, duty_permille)";
      attribute :>> timingRequirement = "apply force stop output in the same 20 ms motor period";
      attribute :>> faultPolicy = "PWM disabled on forceStop or driver fault until supervisor clears";
    }
    part safetyGpioHal : HalBinding {
      attribute :>> bindingName = "safetyGpioHal";
      attribute :>> taskPath = "safetySupervisor";
      attribute :>> physicalFeaturePath = "mainElectronics.safetyGpioHarness";
      attribute :>> accessKind = HalAccessKind::gpioInput;
      attribute :>> driverApi = "hal_gpio_read_fault_lines()";
      attribute :>> timingRequirement = "sample all safety lines every 10 ms";
      attribute :>> faultPolicy = "active-low or indeterminate input is treated as fault active";
    }
    part flashStorageHal : HalBinding {
      attribute :>> bindingName = "flashStorageHal";
      attribute :>> taskPath = "storage";
      attribute :>> physicalFeaturePath = "mainElectronics.mainControlPcb.flashSpi";
      attribute :>> accessKind = HalAccessKind::flashStorage;
      attribute :>> driverApi = "hal_flash_write_record(record_type, payload)";
      attribute :>> timingRequirement = "nonblocking write scheduling; no safety/control loop blocking";
      attribute :>> faultPolicy = "write failure emits DiagnosticEvent and preserves RAM copy";
    }
    part appWirelessHal : HalBinding {
      attribute :>> bindingName = "appWirelessHal";
      attribute :>> taskPath = "appProtocol";
      attribute :>> physicalFeaturePath = "mainElectronics.mainControlPcb.mcuUartOut";
      attribute :>> accessKind = HalAccessKind::wirelessUart;
      attribute :>> driverApi = "hal_uart_write(app_uart, encoded_frame)";
      attribute :>> timingRequirement = "status frames delivered within 500 ms when link is connected";
      attribute :>> faultPolicy = "link loss is user-facing diagnostic, not mission fault";
    }

    // Serialization profiles.
    attribute internalMessageFormat : SerializationFormat = SerializationFormat::internalQueueObject;
    attribute appMessageFormat : SerializationFormat = SerializationFormat::appJsonV1;
    attribute driverFrameFormat : SerializationFormat = SerializationFormat::packedLittleEndianC;
    attribute publicApiVersion = "robot-vacuum-app-v1";
  }

  part softwareHandoff : SoftwareHandoffPackage;
}
