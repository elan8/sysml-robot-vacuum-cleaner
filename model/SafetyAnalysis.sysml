/*
 * Owns hazards, mitigations, safety satisfaction links, and safety evidence
 * references. Depends on requirements, design, behavior, verification, analyses,
 * and scalar values. Keep primary requirements and verification procedures in
 * their source packages.
 */
package SafetyAnalysis {
  private import SystemRequirements::*;
  private import PhysicalArchitecture::*;
  private import FunctionalArchitecture::*;
  private import BehaviorStates::*;
  private import Verification::*;
  private import AnalysisCases::*;
  private import ScalarValues::*;

  part def HazardRecord {
    attribute hazardName : String;
    attribute severity : String;
    attribute exposure : String;
    attribute mitigationSummary : String;
  }

  part def SafetyMitigation {
    attribute mitigationName : String;
    attribute diagnosticCoverage : String;
  }

  part stairFallHazard : HazardRecord {
    attribute :>> hazardName = "stair fall";
    attribute :>> severity = "high";
    attribute :>> exposure = "home stair edge";
    attribute :>> mitigationSummary = "cliff sensors plus safe-stop supervisor";
  }

  part collisionContactHazard : HazardRecord {
    attribute :>> hazardName = "collision contact";
    attribute :>> severity = "medium";
    attribute :>> exposure = "people, pets, furniture";
    attribute :>> mitigationSummary = "ToF obstacle sensing, bumpers, bounded speed";
  }

  part wheelStallHazard : HazardRecord {
    attribute :>> hazardName = "wheel stall";
    attribute :>> severity = "medium";
    attribute :>> exposure = "thresholds, cords, rugs";
    attribute :>> mitigationSummary = "encoder monitoring and bounded recovery";
  }

  part liftDropHazard : HazardRecord {
    attribute :>> hazardName = "lift or drop";
    attribute :>> severity = "medium";
    attribute :>> exposure = "user handling during operation";
    attribute :>> mitigationSummary = "lift input to safety supervisor";
  }

  part batteryThermalHazard : HazardRecord {
    attribute :>> hazardName = "battery thermal event";
    attribute :>> severity = "high";
    attribute :>> exposure = "charging and repeated missions";
    attribute :>> mitigationSummary = "BMS charge current and temperature limits";
  }

  part motorOvercurrentHazard : HazardRecord {
    attribute :>> hazardName = "motor overcurrent";
    attribute :>> severity = "medium";
    attribute :>> exposure = "blocked wheels or brush";
    attribute :>> mitigationSummary = "motor-driver fault GPIO and safe stop";
  }

  part privacyDataLeakHazard : HazardRecord {
    attribute :>> hazardName = "privacy data leak";
    attribute :>> severity = "medium";
    attribute :>> exposure = "home map backup and app telemetry";
    attribute :>> mitigationSummary = "local-only default and explicit cloud consent";
  }

  part cliffSensingMitigation : SafetyMitigation {
    attribute :>> mitigationName = "cliff sensing and safe stop";
    attribute :>> diagnosticCoverage = "four cliff sensors plus reaction-time verification";
  }

  part powerThermalMitigation : SafetyMitigation {
    attribute :>> mitigationName = "battery and board thermal supervision";
    attribute :>> diagnosticCoverage = "BMS SMBus, BMS fault GPIO, board thermal input";
  }

  part motionFaultMitigation : SafetyMitigation {
    attribute :>> mitigationName = "motion fault supervision";
    attribute :>> diagnosticCoverage = "encoders, bumpers, motor-driver fault GPIO, lift input";
  }

  part privacyMitigation : SafetyMitigation {
    attribute :>> mitigationName = "local map handling by default";
    attribute :>> diagnosticCoverage = "privacy configuration review";
  }

  satisfy cliffSensingMitigation by detectCliffs;
  satisfy cliffSensingMitigation by superviseHazards;
  satisfy powerThermalMitigation by chargeSafely;
  satisfy powerThermalMitigation by superviseHazards;
  satisfy motionFaultMitigation by avoidObstacles;
  satisfy motionFaultMitigation by recoverFromStall;
  satisfy motionFaultMitigation by superviseHazards;
  satisfy privacyMitigation by protectMapPrivacy;
}
