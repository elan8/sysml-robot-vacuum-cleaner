/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns the semantic safety-assurance graph: hazardous occurrences, risk
 * classification, safety controls, mitigation relationships, requirements,
 * design targets, and verification or analysis evidence.
 */
package SafetyAnalysis {
  private import SystemRequirements::*;
  private import PhysicalArchitecture::*;
  private import FunctionalArchitecture::*;
  private import BehaviorStates::*;
  private import FirmwareArchitecture::*;
  private import Verification::*;
  private import AnalysisCases::*;
  private import ScalarValues::*;

  enum def HazardSeverity {
    minor;
    serious;
    critical;
  }

  enum def HazardExposure {
    unlikely;
    occasional;
    frequent;
  }

  enum def RiskDisposition {
    acceptable;
    reduceAsFarAsPracticable;
    unacceptable;
  }

  part def Hazard {
    attribute hazardId : String;
    attribute severity : HazardSeverity;
    attribute exposure : HazardExposure;
    attribute disposition : RiskDisposition;
  }

  part def SafetyControl {
    attribute controlId : String;
  }

  connection def HazardMitigation {
    end hazard : Hazard;
    end control : SafetyControl;
  }

  part stairFallHazard : Hazard {
    attribute :>> hazardId = "HAZ-STAIR-FALL";
    attribute :>> severity = HazardSeverity::critical;
    attribute :>> exposure = HazardExposure::occasional;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref affectedRobot = Architecture::robotSystem.physical;
    ref hazardousOperatingState = RobotOperatingBehavior::cleaning;
    ref initiatingCliff = CliffObservation;
    doc /*
      The robot reaches a stair edge and a wheel crosses the drop before motion
      is stopped, potentially damaging the product or creating secondary harm.
    */
  }

  part collisionContactHazard : Hazard {
    attribute :>> hazardId = "HAZ-COLLISION-CONTACT";
    attribute :>> severity = HazardSeverity::serious;
    attribute :>> exposure = HazardExposure::frequent;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref affectedRobot = Architecture::robotSystem.physical;
    ref hazardousOperatingState = RobotOperatingBehavior::cleaning;
    ref initiatingObservation = ObstacleObservation;
    doc /* Bounded-speed collision with people, pets, furniture, or fragile objects. */
  }

  part wheelStallHazard : Hazard {
    attribute :>> hazardId = "HAZ-WHEEL-STALL";
    attribute :>> severity = HazardSeverity::serious;
    attribute :>> exposure = HazardExposure::frequent;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref affectedDrive = AutonomousFloorCleaningRobot::driveModule;
    ref hazardousOperatingState = RobotOperatingBehavior::recovering;
    ref motorControl = FirmwareTaskArchitecture::motorControl;
    doc /* A threshold, cord, or rug blocks a wheel while drive torque remains commanded. */
  }

  part liftDropHazard : Hazard {
    attribute :>> hazardId = "HAZ-LIFT-DROP";
    attribute :>> severity = HazardSeverity::serious;
    attribute :>> exposure = HazardExposure::occasional;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref affectedRobot = Architecture::robotSystem.physical;
    ref liftInput = AutonomousFloorCleaningRobot::mainElectronics.mainControlPcb.liftSensorInput;
    doc /* Motion continues while a user lifts or handles the operating robot. */
  }

  part batteryThermalHazard : Hazard {
    attribute :>> hazardId = "HAZ-BATTERY-THERMAL";
    attribute :>> severity = HazardSeverity::critical;
    attribute :>> exposure = HazardExposure::occasional;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref affectedBattery = AutonomousFloorCleaningRobot::powerModule.batteryPack;
    ref chargingState = RobotOperatingBehavior::charging;
    ref batteryTask = FirmwareTaskArchitecture::batteryManager;
    doc /* Charge current or cell temperature leaves the approved battery operating area. */
  }

  part motorOvercurrentHazard : Hazard {
    attribute :>> hazardId = "HAZ-MOTOR-OVERCURRENT";
    attribute :>> severity = HazardSeverity::serious;
    attribute :>> exposure = HazardExposure::occasional;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref affectedDrive = AutonomousFloorCleaningRobot::driveModule;
    ref motorControl = FirmwareTaskArchitecture::motorControl;
    ref safetyControl = FirmwareTaskArchitecture::safetySupervisor;
    doc /* A blocked wheel or brush produces sustained motor-driver overcurrent. */
  }

  part privacyDataLeakHazard : Hazard {
    attribute :>> hazardId = "HAZ-PRIVACY-DISCLOSURE";
    attribute :>> severity = HazardSeverity::serious;
    attribute :>> exposure = HazardExposure::occasional;
    attribute :>> disposition = RiskDisposition::reduceAsFarAsPracticable;
    ref mapStorage = AutonomousFloorCleaningRobot::robotFirmware.mapProcessing;
    ref wirelessInterface =
      AutonomousFloorCleaningRobot::mainElectronics.mainControlPcb.wirelessModule;
    ref privacyBehavior = PrivacyConsentBehavior;
    doc /* Raw or reconstructable home-map data leaves the robot without user consent. */
  }

  part cliffSensingMitigation : SafetyControl {
    attribute :>> controlId = "CTRL-CLIFF-SAFE-STOP";
    ref frontLeftSensor =
      AutonomousFloorCleaningRobot::sensorAssembly.cliffSensorFrontLeft;
    ref frontRightSensor =
      AutonomousFloorCleaningRobot::sensorAssembly.cliffSensorFrontRight;
    ref rearLeftSensor =
      AutonomousFloorCleaningRobot::sensorAssembly.cliffSensorRearLeft;
    ref rearRightSensor =
      AutonomousFloorCleaningRobot::sensorAssembly.cliffSensorRearRight;
    ref safetyTask = FirmwareTaskArchitecture::safetySupervisor;
    ref safeStopState = RobotOperatingBehavior::safeStop;
    ref cliffRequirement = detectCliffs;
    ref supervisionRequirement = superviseHazards;
    ref reactionAnalysis = SafetyReactionAnalysis;
    ref verificationEvidence = verifyCliffDetection;
    doc /* Four-channel cliff sensing followed by a bounded-latency safe stop. */
  }

  part powerThermalMitigation : SafetyControl {
    attribute :>> controlId = "CTRL-BATTERY-THERMAL";
    ref battery = AutonomousFloorCleaningRobot::powerModule.batteryPack;
    ref batteryTask = FirmwareTaskArchitecture::batteryManager;
    ref safetyTask = FirmwareTaskArchitecture::safetySupervisor;
    ref chargingRequirement = chargeSafely;
    ref supervisionRequirement = superviseHazards;
    ref verificationEvidence = verifySafeCharging;
    doc /* BMS current, temperature, and fault monitoring controls charging and motion. */
  }

  part motionFaultMitigation : SafetyControl {
    attribute :>> controlId = "CTRL-MOTION-FAULT";
    ref drive = AutonomousFloorCleaningRobot::driveModule;
    ref motorTask = FirmwareTaskArchitecture::motorControl;
    ref safetyTask = FirmwareTaskArchitecture::safetySupervisor;
    ref obstacleRequirement = avoidObstacles;
    ref recoveryRequirement = recoverFromStall;
    ref supervisionRequirement = superviseHazards;
    ref recoveryEvidence = verifyStallRecovery;
    ref hazardEvidence = verifyLiftOvercurrentThermalHazards;
    doc /* Encoder, bumper, lift, and driver-fault supervision with bounded recovery. */
  }

  part privacyMitigation : SafetyControl {
    attribute :>> controlId = "CTRL-PRIVACY-CONSENT";
    ref appTask = FirmwareTaskArchitecture::appProtocol;
    ref storageTask = FirmwareTaskArchitecture::storage;
    ref privacyBehavior = PrivacyConsentBehavior;
    ref privacyRequirement = protectMapPrivacy;
    ref verificationEvidence = verifyPrivacyControls;
    doc /* Local map handling by default; cloud transfer requires explicit consent. */
  }

  connection mitigateStairFall : HazardMitigation
    connect hazard ::> stairFallHazard
    to control ::> cliffSensingMitigation;
  connection mitigateCollision : HazardMitigation
    connect hazard ::> collisionContactHazard
    to control ::> motionFaultMitigation;
  connection mitigateWheelStall : HazardMitigation
    connect hazard ::> wheelStallHazard
    to control ::> motionFaultMitigation;
  connection mitigateLiftDrop : HazardMitigation
    connect hazard ::> liftDropHazard
    to control ::> motionFaultMitigation;
  connection mitigateBatteryThermal : HazardMitigation
    connect hazard ::> batteryThermalHazard
    to control ::> powerThermalMitigation;
  connection mitigateMotorOvercurrent : HazardMitigation
    connect hazard ::> motorOvercurrentHazard
    to control ::> motionFaultMitigation;
  connection mitigatePrivacyDisclosure : HazardMitigation
    connect hazard ::> privacyDataLeakHazard
    to control ::> privacyMitigation;

  satisfy detectCliffs by cliffSensingMitigation;
  satisfy superviseHazards by cliffSensingMitigation;
  satisfy chargeSafely by powerThermalMitigation;
  satisfy superviseHazards by powerThermalMitigation;
  satisfy avoidObstacles by motionFaultMitigation;
  satisfy recoverFromStall by motionFaultMitigation;
  satisfy superviseHazards by motionFaultMitigation;
  satisfy protectMapPrivacy by privacyMitigation;
}
