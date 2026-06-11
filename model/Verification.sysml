package Verification {
  private import SystemRequirements::*;
  private import Architecture::*;

  action def RecordModelAnalysisEvidence;
  action def RunPhysicalTest;

  verification verifyCleaningCoverage {
    doc /* Confirm at least 90% reachable floor coverage in the standard rectangular test room. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify coverFloor;
    }
    then action runCoverageTest : RunPhysicalTest;
    then done;
  }

  verification verifyBatteryRuntime {
    doc /* Confirm cleaning area per charge meets cleanAtLeastEighty under the reference mission profile. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify cleanAtLeastEighty;
    }
    then action runRuntimeTest : RunPhysicalTest;
    then done;
  }

  verification verifyObstacleAvoidance {
    doc /* Confirm the robot avoids obstacles taller than 30 mm without contact. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify avoidObstacles;
    }
    then action runObstacleScenario : RunPhysicalTest;
    then done;
  }

  verification verifyDockingSuccess {
    doc /* Confirm autonomous return and docking when battery state of charge is low. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify returnToDock;
    }
    then action runDockingTest : RunPhysicalTest;
    then done;
  }

  verification verifyDustBinDetection {
    doc /* Confirm dust-bin-full detection and user notification. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify detectDustBin;
    }
    then action runBinFullTest : RunPhysicalTest;
    then done;
  }

  verification verifyNoiseLevel {
    doc /* Confirm acoustic noise in standard cleaning mode stays below 65 dBA. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify keepNoise;
    }
    then action runNoiseTest : RunPhysicalTest;
    then done;
  }

  verification verifyBomCost {
    doc /*
      Confirm limitBomCost: BOM roll-up at target volume within budget.
      Design-time: run ProductCostAnalysis; V&V: optional physical cost audit.
    */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify limitBomCost;
    }
    then action recordBomAnalysis : RecordModelAnalysisEvidence;
    then action optionalBomAudit : RunPhysicalTest;
    then done;
  }

  verification verifyTotalMass {
    doc /*
      Confirm limitTotalMass: weigh or sum subsystem masses within budget.
      Design-time: run TotalMassAnalysis; V&V: optional weighed sample.
    */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify limitTotalMass;
    }
    then action recordMassAnalysis : RecordModelAnalysisEvidence;
    then action optionalWeighIn : RunPhysicalTest;
    then done;
  }
}
