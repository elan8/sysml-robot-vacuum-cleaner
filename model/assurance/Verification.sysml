/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns verification cases and evidence intent for system requirements. Depends
 * on system requirements and architecture. Keep requirement text and analysis
 * calculations in their dedicated packages.
 */
package Verification {
  private import SystemRequirements::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import AnalysisCases::*;
  private import DesignLimits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def VerificationVerdict {
    notRun;
    pass;
    fail;
    inconclusive;
  }

  item def VerificationResult {
    attribute verdict : VerificationVerdict = VerificationVerdict::notRun;
    attribute evidenceId : String;
  }

  part def VerificationEvidence {
    attribute evidenceId : String;
    attribute verdict : VerificationVerdict;
  }

  part def ReferenceHomeTestEnvironment {
    attribute rectangularRoom : Boolean = true;
    attribute includesStairEdge : Boolean = true;
    attribute localNetworkOnly : Boolean = true;
  }

  part referenceHomeEnvironment : ReferenceHomeTestEnvironment;

  action def RecordModelAnalysisEvidence {
    doc /* Capture the output of a model-based analysis case as traceable verification evidence. */
    out result : VerificationResult;
  }
  action def RunPhysicalTest {
    doc /* Execute a physical test procedure on a robot unit and record pass/fail evidence. */
    out result : VerificationResult;
  }
  action def RunSoftwareVerification {
    doc /* Execute unit and integration checks against a typed firmware task and its runtime connections. */
    out result : VerificationResult;
  }

  verification verifyCleaningCoverage {
    doc /* Confirm at least 90% reachable floor coverage in the standard rectangular test room. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement coverFloor;
    }
    then action runCoverageTest : RunPhysicalTest;
  }

  verification verifyBatteryRuntime {
    doc /* Confirm cleaning area per charge meets cleanAtLeastEighty under the reference mission profile. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement cleanAtLeastEighty;
    }
    then action runRuntimeTest : RunPhysicalTest;
  }

  verification verifyObstacleAvoidance {
    doc /* Confirm the robot avoids obstacles taller than 30 mm without contact. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement avoidObstacles;
    }
    then action runObstacleScenario : RunPhysicalTest;
  }

  verification verifyDockingSuccess {
    doc /* Confirm autonomous return and docking when battery state of charge is low. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement returnToDock;
    }
    then action runDockingTest : RunPhysicalTest;
  }

  verification verifyDustBinDetection {
    doc /* Confirm dust-bin-full detection and user notification. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement detectDustBin;
    }
    then action runBinFullTest : RunPhysicalTest;
  }

  verification verifyNoiseLevel {
    doc /* Confirm acoustic noise in standard cleaning mode stays below 65 dBA. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement keepNoise;
    }
    then action runNoiseTest : RunPhysicalTest;
  }

  verification verifyBomCost {
    doc /*
      Confirm limitBomCost: BOM roll-up at target volume within budget.
      Design-time: run ProductCostAnalysis; V&V: optional physical cost audit.
    */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement limitBomCost;
    }
    then action recordBomAnalysis : RecordModelAnalysisEvidence;
    then action optionalBomAudit : RunPhysicalTest;
  }

  verification verifyTotalMass {
    doc /*
      Confirm limitTotalMass: weigh or sum subsystem masses within budget.
      Design-time: run TotalMassAnalysis; V&V: optional weighed sample.
    */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement limitTotalMass;
    }
    then action recordMassAnalysis : RecordModelAnalysisEvidence;
    then action optionalWeighIn : RunPhysicalTest;
  }

  verification verifyCliffDetection {
    doc /* Confirm the robot detects 50 mm floor drop-offs and commands a safe stop before crossing the edge. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement detectCliffs;
      verify requirement superviseHazards;
    }
    ref testEnvironment = referenceHomeEnvironment;
    then action runCliffEdgeTest : RunPhysicalTest;
    then action recordReactionTiming : RecordModelAnalysisEvidence;
  }

  verification verifyLocalizationAccuracy {
    doc /* Confirm localization error remains below 150 mm across the reference home layout. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement localizeReliably;
    }
    then action recordLocalizationAnalysis : RecordModelAnalysisEvidence;
    then action runLocalizationScenario : RunPhysicalTest;
  }

  verification verifyCoverageMap {
    doc /* Confirm cleaned, unknown, and unreachable areas are represented in the mission coverage map. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement updateCoverageMap;
    }
    then action recordCoverageMapAnalysis : RecordModelAnalysisEvidence;
    then action runCoverageMapScenario : RunPhysicalTest;
  }

  verification verifyRoomScaleSlam {
    doc /* Confirm selected premium LiDAR SLAM maintains stable maps and below-150 mm localization across a standard home layout. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement localizeReliably;
      verify requirement updateCoverageMap;
      verify requirement supportRoomScaleSlam;
    }
    then action recordLocalizationAnalysis : RecordModelAnalysisEvidence;
    then action runSlamReferenceHomeScenario : RunPhysicalTest;
  }

  verification verifyStallRecovery {
    doc /* Confirm wheel-stall detection enters bounded recovery and escalates to safe stop when recovery fails. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement recoverFromStall;
      verify requirement superviseHazards;
    }
    then action runStallRecoveryScenario : RunPhysicalTest;
  }

  verification verifyPrivacyControls {
    doc /* Confirm local-only map handling and user consent behavior for cloud backup. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement protectMapPrivacy;
    }
    ref testEnvironment = referenceHomeEnvironment;
    then action runPrivacyConfigurationReview : RunPhysicalTest;
  }

  verification verifySafeCharging {
    doc /* Confirm charge current and temperature remain within the battery safe operating area. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement chargeSafely;
    }
    then action runChargingSafetyTest : RunPhysicalTest;
  }

  verification verifyToolLessBinService {
    doc /* Confirm the dust bin can be removed, emptied, and reinstalled without tools. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement emptyBinWithoutTools;
    }
    then action runBinServiceUsabilityTest : RunPhysicalTest;
  }

  verification verifyBinPresenceDetection {
    doc /* Confirm missing or unlatched bin status prevents cleaning and notifies the user. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement detectBinRemovedOrMissing;
      verify requirement notifyMaintenanceNeeded;
    }
    then action runBinLatchDetectionTest : RunPhysicalTest;
  }

  verification verifyLiftOvercurrentThermalHazards {
    doc /* Confirm lift, motor overcurrent, and thermal fault inputs are aggregated into safe stop. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement superviseHazards;
      verify requirement chargeSafely;
    }
    then action runFaultInjectionTest : RunPhysicalTest;
    then action recordSafetyReactionAnalysis : RecordModelAnalysisEvidence;
  }

  verification verifyElectricalInterfaceControl {
    doc /* Confirm PCB harness port docs, power rails, bus speeds, addresses, and fault polarities match the schematic. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement superviseHazards;
      verify requirement chargeSafely;
    }
    then action reviewSchematicAgainstIcd : RunPhysicalTest;
  }

  verification verifyFirmwareSchedulerTiming {
    doc /* Confirm safety, motor, sensor, mission, app, diagnostics, and storage tasks meet declared periods and deadlines. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement superviseHazards;
      verify requirement localizeReliably;
      verify requirement reportCleaningStatus;
    }
    then action runSchedulerTimingTest : RunPhysicalTest;
    then action recordTimingAnalysis : RecordModelAnalysisEvidence;
  }

  verification verifyProtocolContracts {
    doc /* Confirm app messages, user commands, mission status, telemetry, map updates, and diagnostics conform to data contracts. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement reportCleaningStatus;
      verify requirement protectMapPrivacy;
      verify requirement notifyMaintenanceNeeded;
    }
    then action runProtocolConformanceTest : RunPhysicalTest;
  }

  verification verifyMissionControllerImplementation {
    doc /*
      Exercise mission-state transitions, arbitration priority, stale-input
      handling, app-to-mission commands, planner commands, and the safe-stop chain.
    */
    subject task : MissionControllerTask;
    objective {
      verify requirement reportCleaningStatus;
      verify requirement recoverFromStall;
      verify requirement returnToDock;
    }
    then action runMissionControllerChecks : RunSoftwareVerification;
  }

  verification verifySafetySupervisorImplementation {
    doc /*
      Exercise hazard mapping, latch/clear behavior, GPIO-to-stop propagation,
      BMS escalation, and diagnostic publication.
    */
    subject task : SafetySupervisorTask;
    objective {
      verify requirement superviseHazards;
      verify requirement detectCliffs;
      verify requirement chargeSafely;
    }
    then action runSafetySupervisorChecks : RunSoftwareVerification;
  }

  verification verifySensorAcquisitionImplementation {
    doc /*
      Exercise sample normalization, stale-frame detection, cliff debounce,
      I2C addressing, LiDAR framing, and safety-GPIO aggregation.
    */
    subject task : SensorAcquisitionTask;
    objective {
      verify requirement avoidObstacles;
      verify requirement detectCliffs;
      verify requirement supportRoomScaleSlam;
    }
    then action runSensorAcquisitionChecks : RunSoftwareVerification;
  }

  verification verifyMotorControlImplementation {
    doc /*
      Exercise command bounds, forced stop, PWM ramping, stall timing, encoder
      feedback, and motor-driver fault propagation.
    */
    subject task : MotorControlTask;
    objective {
      verify requirement avoidObstacles;
      verify requirement recoverFromStall;
      verify requirement superviseHazards;
    }
    then action runMotorControlChecks : RunSoftwareVerification;
  }

  verification verifyAppPrivacyImplementation {
    doc /*
      Exercise protocol encoding, consent handling, malformed frames, local map
      filtering, storage persistence, and app-command delivery.
    */
    subject task : AppProtocolTask;
    objective {
      verify requirement reportCleaningStatus;
      verify requirement protectMapPrivacy;
      verify requirement notifyMaintenanceNeeded;
    }
    then action runAppPrivacyChecks : RunSoftwareVerification;
  }

  part cliffSafeStopEvidence : VerificationEvidence {
    attribute :>> evidenceId = "EVID-CLIFF-SAFE-STOP-001";
    attribute :>> verdict = VerificationVerdict::pass;
    attribute measuredReactionTime : DurationValue = 90 [ms];
    attribute reactionTimeLimit : DurationValue =
      DesignLimits::maxSafeStopReactionTime;
    constraint { measuredReactionTime <= reactionTimeLimit }
    ref verificationCase = verifyCliffDetection;
    ref analysisCase = SafetyReactionAnalysis;
    ref requirementUnderTest = detectCliffs;
    ref secondaryRequirement = superviseHazards;
    ref testEnvironment = referenceHomeEnvironment;
    ref observedResult = verifyCliffDetection.runCliffEdgeTest.result;
  }

  part missionEnergyEvidence : VerificationEvidence {
    attribute :>> evidenceId = "EVID-MISSION-ENERGY-001";
    attribute :>> verdict = VerificationVerdict::pass;
    attribute missionChargeDraw : ElectricChargeValue = 9375 [mAh];
    attribute usableChargeBudget : ElectricChargeValue = 10625 [mAh];
    constraint { missionChargeDraw <= usableChargeBudget }
    ref verificationCase = verifyBatteryRuntime;
    ref analysisCase = MissionEnergyAnalysis;
    ref requirementUnderTest = cleanAtLeastEighty;
    ref observedResult = verifyBatteryRuntime.runRuntimeTest.result;
  }

  part privacyConsentEvidence : VerificationEvidence {
    attribute :>> evidenceId = "EVID-PRIVACY-CONSENT-001";
    attribute :>> verdict = VerificationVerdict::pass;
    attribute rawMapTransferredWithoutConsent : Boolean = false;
    constraint { rawMapTransferredWithoutConsent == false }
    ref verificationCase = verifyPrivacyControls;
    ref requirementUnderTest = protectMapPrivacy;
    ref testEnvironment = referenceHomeEnvironment;
    ref observedResult = verifyPrivacyControls.runPrivacyConfigurationReview.result;
  }

  part appPrivacySoftwareEvidence : VerificationEvidence {
    attribute :>> evidenceId = "EVID-APP-PRIVACY-SW-001";
    attribute :>> verdict = VerificationVerdict::pass;
    attribute malformedFrameRejected : Boolean = true;
    attribute consentRevocationPersisted : Boolean = true;
    constraint {
      malformedFrameRejected == true and
      consentRevocationPersisted == true
    }
    ref verificationCase = verifyAppPrivacyImplementation;
    ref requirementUnderTest = protectMapPrivacy;
    ref taskUnderTest = FirmwareTaskArchitecture::appProtocol;
    ref observedResult =
      verifyAppPrivacyImplementation.runAppPrivacyChecks.result;
  }
}
