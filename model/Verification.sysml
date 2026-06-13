package Verification {
  private import SystemRequirements::*;
  private import Architecture::*;

  action def RecordModelAnalysisEvidence;
  action def RunPhysicalTest;

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
}
