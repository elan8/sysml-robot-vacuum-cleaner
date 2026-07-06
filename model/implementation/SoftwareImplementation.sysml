/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns implementation-facing software handoff records derived from firmware
 * architecture, interface control, physical architecture, requirements, and
 * verification intent. Keep primary architecture facts in their source
 * packages; this package organizes them for implementation planning and tool
 * extraction.
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

  enum def ImplementationStatus {
    readyForImplementation;
    needsDriverDetail;
    needsAlgorithmDetail;
    deferred;
  }

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

  enum def StartupPhase {
    bootSelfTest;
    schedulerStart;
    missionReady;
    deferredStartup;
  }

  part def SoftwareTaskWorkPackage {
    attribute taskPath : String;
    attribute owningModulePath : String;
    attribute requirementRefs : String;
    attribute verificationRefs : String;
    attribute implementationStatus : ImplementationStatus;
    attribute startupPhase : StartupPhase;
    attribute sourceFiles : String;
    attribute mainResponsibility : String;
    attribute stateOwnedByTask : String;
    attribute algorithmNotes : String;
    attribute errorHandling : String;
    attribute unitTestScope : String;
    attribute integrationTestScope : String;
    attribute maxStackBytes : Integer;
    attribute maxStaticRamBytes : Integer;
    attribute wcetBudget : DurationValue;
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
      Engineer-facing implementation package. The path attributes refer to the
      semantic source elements in FirmwareArchitecture, InterfaceControl,
      PhysicalArchitecture, SystemRequirements, and Verification. They are kept
      explicit so a tool can generate task cards even while Spec42 lacks nested
      feature-path connection end resolution for action parameters.
    */

    // Firmware task implementation cards.
    part missionControllerWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.missionController";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "reportCleaningStatus, recoverFromStall, superviseHazards, returnToDock";
      attribute :>> verificationRefs = "verifyFirmwareSchedulerTiming, verifyStallRecovery, verifyDockingSuccess, verifyProtocolContracts";
      attribute :>> implementationStatus = ImplementationStatus::readyForImplementation;
      attribute :>> startupPhase = StartupPhase::missionReady;
      attribute :>> sourceFiles = "src/tasks/mission_controller.c; include/tasks/mission_controller.h";
      attribute :>> mainResponsibility = "Mission state arbitration, command fan-out, low-battery return, bin/stall escalation, mission status publication.";
      attribute :>> stateOwnedByTask = "RobotOperatingBehavior state mirror; authoritative mission state for app status.";
      attribute :>> algorithmNotes = "Prioritize safeStopCommand over planner drive command; reject cleaning start when bin is missing or unlatched.";
      attribute :>> errorHandling = "On stale planner command, hold last safe command for one period then force stop; on hazard input, publish safe stop request in same activation.";
      attribute :>> unitTestScope = "state transitions, command arbitration priority, stale input handling, low battery transition.";
      attribute :>> integrationTestScope = "app command to mission state, planner command to motor command, safe-stop reaction chain.";
      attribute :>> maxStackBytes = 2048;
      attribute :>> maxStaticRamBytes = 4096;
      attribute :>> wcetBudget = 8 [ms];
    }

    part safetySupervisorWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.safetySupervisor";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.safetySupervisor";
      attribute :>> requirementRefs = "superviseHazards, detectCliffs, chargeSafely";
      attribute :>> verificationRefs = "verifyCliffDetection, verifyLiftOvercurrentThermalHazards, verifyFirmwareSchedulerTiming";
      attribute :>> implementationStatus = ImplementationStatus::readyForImplementation;
      attribute :>> startupPhase = StartupPhase::schedulerStart;
      attribute :>> sourceFiles = "src/tasks/safety_supervisor.c; include/tasks/safety_supervisor.h";
      attribute :>> mainResponsibility = "Aggregate hazards and diagnostics, latch safety-critical faults, command force stop within safe-stop budget.";
      attribute :>> stateOwnedByTask = "latched fault state and safe-stop-clear debounce.";
      attribute :>> algorithmNotes = "Any safetyCritical HazardEvent or active-low GPIO fault produces DriveCommand.forceStop=true.";
      attribute :>> errorHandling = "Fault input disagreement is treated as active fault; clear only after explicit safeStopCleared/service reset condition.";
      attribute :>> unitTestScope = "hazard severity mapping, latch/clear behavior, diagnostic escalation.";
      attribute :>> integrationTestScope = "GPIO fault to motor stop, BMS alert to mission safe stop, diagnostics to app.";
      attribute :>> maxStackBytes = 1536;
      attribute :>> maxStaticRamBytes = 2048;
      attribute :>> wcetBudget = 2 [ms];
    }

    part sensorAcquisitionWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.sensorAcquisition";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.mapProcessing";
      attribute :>> requirementRefs = "avoidObstacles, detectCliffs, supportRoomScaleSlam";
      attribute :>> verificationRefs = "verifyObstacleAvoidance, verifyCliffDetection, verifyRoomScaleSlam, verifyElectricalInterfaceControl";
      attribute :>> implementationStatus = ImplementationStatus::needsDriverDetail;
      attribute :>> startupPhase = StartupPhase::schedulerStart;
      attribute :>> sourceFiles = "src/tasks/sensor_acquisition.c; include/tasks/sensor_acquisition.h";
      attribute :>> mainResponsibility = "Poll ToF, cliff, IMU and LiDAR drivers; publish HazardEvent, LidarScanFrame and obstacle observations.";
      attribute :>> stateOwnedByTask = "sensor health and last-good sample timestamps.";
      attribute :>> algorithmNotes = "Timestamp each scan frame at acquisition; cliff GPIO is sampled every period before noncritical sensor reads.";
      attribute :>> errorHandling = "Missing LiDAR frame raises diagnostic; cliff sensor active-low fault raises safetyCritical hazard immediately.";
      attribute :>> unitTestScope = "sample normalization, stale-frame detection, cliff debounce.";
      attribute :>> integrationTestScope = "I2C address map, UART frame parser, safety GPIO aggregation.";
      attribute :>> maxStackBytes = 3072;
      attribute :>> maxStaticRamBytes = 12288;
      attribute :>> wcetBudget = 12 [ms];
    }

    part slamWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.slam";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.mapProcessing";
      attribute :>> requirementRefs = "supportRoomScaleSlam, updateCoverageMap, localizeReliably";
      attribute :>> verificationRefs = "verifyRoomScaleSlam, verifyCoverageMap, verifyLocalizationAccuracy";
      attribute :>> implementationStatus = ImplementationStatus::needsAlgorithmDetail;
      attribute :>> startupPhase = StartupPhase::missionReady;
      attribute :>> sourceFiles = "src/tasks/slam.c; include/tasks/slam.h";
      attribute :>> mainResponsibility = "Maintain pose graph and local occupancy-grid updates from LiDAR and fused pose input.";
      attribute :>> stateOwnedByTask = "pose graph window, loop closure candidate state, map stability score.";
      attribute :>> algorithmNotes = "Use 2D scan matching against local grid; publish compact PoseGraphUpdate and MapUpdate, not raw home map to app path.";
      attribute :>> errorHandling = "If scan matching confidence drops below threshold, request localization degraded diagnostic and keep previous stable map.";
      attribute :>> unitTestScope = "pose graph update bounds, loop closure candidate scoring, map update privacy flag.";
      attribute :>> integrationTestScope = "LiDAR scan to map update, map update to storage, localization feedback loop.";
      attribute :>> maxStackBytes = 4096;
      attribute :>> maxStaticRamBytes = 49152;
      attribute :>> wcetBudget = 35 [ms];
    }

    part localizationWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.localization";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.localizationEstimator";
      attribute :>> requirementRefs = "localizeReliably, supportRoomScaleSlam";
      attribute :>> verificationRefs = "verifyLocalizationAccuracy, verifyRoomScaleSlam, verifyFirmwareSchedulerTiming";
      attribute :>> implementationStatus = ImplementationStatus::needsAlgorithmDetail;
      attribute :>> startupPhase = StartupPhase::missionReady;
      attribute :>> sourceFiles = "src/tasks/localization.c; include/tasks/localization.h";
      attribute :>> mainResponsibility = "Fuse wheel odometry, IMU, LiDAR scan features, and pose-graph corrections into PoseEstimate.";
      attribute :>> stateOwnedByTask = "pose estimate, covariance/error estimate, degraded-localization flag.";
      attribute :>> algorithmNotes = "Publish PoseEstimate.errorMm; keep error below maxLocalizationError during standard layout mission.";
      attribute :>> errorHandling = "On stale pose graph or LiDAR scan, degrade to wheel/IMU prediction and raise diagnostic after timeout.";
      attribute :>> unitTestScope = "pose propagation, correction application, stale-input fallback.";
      attribute :>> integrationTestScope = "encoder/IMU/LiDAR fusion and coverage planner consumption.";
      attribute :>> maxStackBytes = 3072;
      attribute :>> maxStaticRamBytes = 16384;
      attribute :>> wcetBudget = 12 [ms];
    }

    part coveragePlannerWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.coveragePlanner";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.coveragePlanner";
      attribute :>> requirementRefs = "coverFloor, updateCoverageMap, cleanAtLeastEighty";
      attribute :>> verificationRefs = "verifyCleaningCoverage, verifyCoverageMap, verifyRoomScaleSlam";
      attribute :>> implementationStatus = ImplementationStatus::readyForImplementation;
      attribute :>> startupPhase = StartupPhase::missionReady;
      attribute :>> sourceFiles = "src/tasks/coverage_planner.c; include/tasks/coverage_planner.h";
      attribute :>> mainResponsibility = "Convert pose and map updates into drive commands and cleaned/unreachable/unknown map updates.";
      attribute :>> stateOwnedByTask = "coverage path cursor, replanning state, unreachable-cell marking.";
      attribute :>> algorithmNotes = "Use boustrophedon path over known free cells; replan around dynamic obstacle observations.";
      attribute :>> errorHandling = "If no safe local path exists, request obstacle recovery rather than emitting a forward command.";
      attribute :>> unitTestScope = "cell-state transitions, path cursor, obstacle replanning.";
      attribute :>> integrationTestScope = "map update to planner command and mission controller arbitration.";
      attribute :>> maxStackBytes = 3072;
      attribute :>> maxStaticRamBytes = 24576;
      attribute :>> wcetBudget = 40 [ms];
    }

    part motorControlWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.motorControl";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "avoidObstacles, recoverFromStall, superviseHazards";
      attribute :>> verificationRefs = "verifyStallRecovery, verifyLiftOvercurrentThermalHazards, verifyFirmwareSchedulerTiming";
      attribute :>> implementationStatus = ImplementationStatus::readyForImplementation;
      attribute :>> startupPhase = StartupPhase::schedulerStart;
      attribute :>> sourceFiles = "src/tasks/motor_control.c; include/tasks/motor_control.h";
      attribute :>> mainResponsibility = "Translate DriveCommand into PWM outputs, monitor encoders and driver faults, publish motion hazards.";
      attribute :>> stateOwnedByTask = "last command, stall timers, PWM ramp limiter.";
      attribute :>> algorithmNotes = "Force stop overrides all ramping; stall detection threshold is 2 s maximum.";
      attribute :>> errorHandling = "Driver fault or encoder stall publishes HazardEvent and disables PWM until mission controller clears.";
      attribute :>> unitTestScope = "command saturation, force stop, ramp limiting, stall timer.";
      attribute :>> integrationTestScope = "PWM outputs, encoder inputs, motor driver fault GPIO.";
      attribute :>> maxStackBytes = 1536;
      attribute :>> maxStaticRamBytes = 2048;
      attribute :>> wcetBudget = 5 [ms];
    }

    part appProtocolWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.appProtocol";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "reportCleaningStatus, protectMapPrivacy, notifyMaintenanceNeeded";
      attribute :>> verificationRefs = "verifyProtocolContracts, verifyPrivacyControls, verifyFirmwareSchedulerTiming";
      attribute :>> implementationStatus = ImplementationStatus::readyForImplementation;
      attribute :>> startupPhase = StartupPhase::missionReady;
      attribute :>> sourceFiles = "src/tasks/app_protocol.c; include/tasks/app_protocol.h";
      attribute :>> mainResponsibility = "Encode/decode app protocol, publish user commands, expose mission and diagnostic summaries.";
      attribute :>> stateOwnedByTask = "protocol version, consent state, session health.";
      attribute :>> algorithmNotes = "Never serialize raw MapUpdate to app; use map summary only unless explicit cloud backup consent is enabled.";
      attribute :>> errorHandling = "Malformed command frame is dropped and diagnostic warning is emitted; consent changes are idempotent.";
      attribute :>> unitTestScope = "JSON schema encoding/decoding, consent command handling, malformed frame behavior.";
      attribute :>> integrationTestScope = "BLE/Wi-Fi UART transport and app command to mission controller.";
      attribute :>> maxStackBytes = 3072;
      attribute :>> maxStaticRamBytes = 8192;
      attribute :>> wcetBudget = 20 [ms];
    }

    part storageWork : SoftwareTaskWorkPackage {
      attribute :>> taskPath = "FirmwareArchitecture::firmwareTaskArchitecture.storage";
      attribute :>> owningModulePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.robotFirmware.applicationFirmware";
      attribute :>> requirementRefs = "protectMapPrivacy, updateCoverageMap, notifyMaintenanceNeeded";
      attribute :>> verificationRefs = "verifyPrivacyControls, verifyCoverageMap, verifyProtocolContracts";
      attribute :>> implementationStatus = ImplementationStatus::needsDriverDetail;
      attribute :>> startupPhase = StartupPhase::missionReady;
      attribute :>> sourceFiles = "src/tasks/storage.c; include/tasks/storage.h";
      attribute :>> mainResponsibility = "Persist local map updates, diagnostics and maintenance state to external flash.";
      attribute :>> stateOwnedByTask = "wear-level cursor, map summary cache, privacy consent flag mirror.";
      attribute :>> algorithmNotes = "Store raw map locally only; app-visible mapSummaryOut must not include raw home map geometry.";
      attribute :>> errorHandling = "On flash write failure, keep RAM cache, publish diagnostic and continue mission without cloud upload.";
      attribute :>> unitTestScope = "wear-level record lifecycle, privacy filter, map summary generation.";
      attribute :>> integrationTestScope = "SPI flash driver, map update persistence, app map summary contract.";
      attribute :>> maxStackBytes = 2048;
      attribute :>> maxStaticRamBytes = 32768;
      attribute :>> wcetBudget = 100 [ms];
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
