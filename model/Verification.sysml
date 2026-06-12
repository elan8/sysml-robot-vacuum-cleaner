package Verification {
  private import SystemRequirements::*;
  private import Architecture::*;

  action def RecordModelAnalysisEvidence;
  action def RunPhysicalTest;

  verification verifyCleaningCoverage {
    doc /* Confirm at least 90% reachable floor coverage in the standard rectangular test room. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::coverFloor;
    }
    then action runCoverageTest : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyBatteryRuntime {
    doc /* Confirm cleaning area per charge meets cleanAtLeastEighty under the reference mission profile. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::cleanAtLeastEighty;
    }
    then action runRuntimeTest : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyObstacleAvoidance {
    doc /* Confirm the robot avoids obstacles taller than 30 mm without contact. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::avoidObstacles;
    }
    then action runObstacleScenario : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyDockingSuccess {
    doc /* Confirm autonomous return and docking when battery state of charge is low. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::returnToDock;
    }
    then action runDockingTest : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyDustBinDetection {
    doc /* Confirm dust-bin-full detection and user notification. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::detectDustBin;
    }
    then action runBinFullTest : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyNoiseLevel {
    doc /* Confirm acoustic noise in standard cleaning mode stays below 65 dBA. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::keepNoise;
    }
    then action runNoiseTest : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyBomCost {
    doc /*
      Confirm limitBomCost: BOM roll-up at target volume within budget.
      Design-time: run ProductCostAnalysis; V&V: optional physical cost audit.
    */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::limitBomCost;
    }
    then action recordBomAnalysis : RecordModelAnalysisEvidence;
    
    then action optionalBomAudit : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyTotalMass {
    doc /*
      Confirm limitTotalMass: weigh or sum subsystem masses within budget.
      Design-time: run TotalMassAnalysis; V&V: optional weighed sample.
    */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::limitTotalMass;
    }
    then action recordMassAnalysis : RecordModelAnalysisEvidence;
    
    then action optionalWeighIn : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyCliffDetection {
    doc /* Confirm the robot detects 50 mm floor drop-offs and commands a safe stop before crossing the edge. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::detectCliffs;
      verify requirement SystemRequirements::superviseHazards;
    }
    then action runCliffEdgeTest : RunPhysicalTest;
    
    then action recordReactionTiming : RecordModelAnalysisEvidence;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyLocalizationAccuracy {
    doc /* Confirm localization error remains below 150 mm across the reference home layout. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::localizeReliably;
    }
    then action recordLocalizationAnalysis : RecordModelAnalysisEvidence;
    
    then action runLocalizationScenario : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyCoverageMap {
    doc /* Confirm cleaned, unknown, and unreachable areas are represented in the mission coverage map. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::updateCoverageMap;
    }
    then action recordCoverageMapAnalysis : RecordModelAnalysisEvidence;
    
    then action runCoverageMapScenario : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyStallRecovery {
    doc /* Confirm wheel-stall detection enters bounded recovery and escalates to safe stop when recovery fails. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::recoverFromStall;
      verify requirement SystemRequirements::superviseHazards;
    }
    then action runStallRecoveryScenario : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifyPrivacyControls {
    doc /* Confirm local-only map handling and user consent behavior for cloud backup. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::protectMapPrivacy;
    }
    then action runPrivacyConfigurationReview : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }

  verification verifySafeCharging {
    doc /* Confirm charge current and temperature remain within the battery safe operating area. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement SystemRequirements::chargeSafely;
    }
    then action runChargingSafetyTest : RunPhysicalTest;
    
    return ref verdictResult { return VerdictKind::pass; }
  }
}

