package AnalysisCases {
  private import Architecture::*;
  private import MonetaryUnits::*;
  private import DesignLimits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  analysis def TotalPowerConsumptionAnalysis {
    attribute powerBudgetW : PowerValue = 75 [W];
    subject robot : AutonomousFloorCleaningRobot;
    return ref powerWithinBudget {
      return sum(
        robot.mobility.powerDrawW,
        robot.cleaning.powerDrawW,
        robot.perception.powerDrawW,
        robot.navigation.powerDrawW,
        robot.power.powerDrawW,
        robot.docking.powerDrawW,
        robot.control.powerDrawW,
        robot.userInterface.powerDrawW,
        robot.safety.powerDrawW
      ) <= powerBudgetW;
    }
    objective estimatePower {
      doc /*
        Supporting engineering roll-up: subsystem powerDrawW summed vs local 75 W budget
        (no dedicated system requirement; informs runtime and thermal design).
      */
    }
  }
  analysis def ProductCostAnalysis {
    attribute bomCostBudget : MonetaryAmount = 400 [EUR];
    subject robot : AutonomousFloorCleaningRobot;
    return ref costWithinTarget {
      return sum(
        robot.mobility.bomCost,
        robot.cleaning.bomCost,
        robot.perception.bomCost,
        robot.navigation.bomCost,
        robot.power.bomCost,
        robot.docking.bomCost,
        robot.control.bomCost,
        robot.userInterface.bomCost,
        robot.safety.bomCost
      ) <= bomCostBudget;
    }
    objective estimateCost {
      doc /*
        Model-based evidence for limitBomCost: BOM roll-up vs DesignLimits.bomCostBudget (400 EUR).
      */
    }
  }
  analysis def TotalMassAnalysis {
    attribute massBudget : MassValue = 5.0 [kg];
    subject robot : AutonomousFloorCleaningRobot;
    return ref massWithinLimit {
      return sum(
        robot.mobility.massKg,
        robot.cleaning.massKg,
        robot.perception.massKg,
        robot.navigation.massKg,
        robot.power.massKg,
        robot.docking.massKg,
        robot.control.massKg,
        robot.userInterface.massKg,
        robot.safety.massKg
      ) <= massBudget;
    }
    objective estimateMass {
      doc /*
        Model-based evidence for limitTotalMass: mass roll-up vs DesignLimits.massBudget (5.0 kg).
      */
    }
  }
  analysis def MissionEnergyAnalysis {
    attribute missionEnergy : EnergyValue = 486 [kJ];
    attribute energyBudget : EnergyValue = 648 [kJ];
    subject robot : AutonomousFloorCleaningRobot;
    return ref energyWithinBudget {
      return missionEnergy <= energyBudget;
    }
    objective estimateMissionEnergy {
      doc /*
        Supporting mission energy vs battery budget (informs cleanAtLeastEighty runtime; no separate requirement).
      */
    }
  }
  analysis def LocalizationPerformanceAnalysis {
    attribute estimatedLocalizationError : LengthValue = 120 [mm];
    attribute localizationErrorLimit : LengthValue = 150 [mm];
    subject robot : AutonomousFloorCleaningRobot;
    return ref localizationWithinLimit {
      return estimatedLocalizationError <= localizationErrorLimit;
    }
    objective estimateLocalization {
      doc /*
        Model-based evidence for localizeReliably: fused odometry and perception estimate stays below the 150 mm limit.
      */
    }
  }
  analysis def SafetyReactionAnalysis {
    attribute measuredReactionTimeMs : Integer = 90;
    attribute reactionTimeLimitMs : Integer = 100;
    subject robot : AutonomousFloorCleaningRobot;
    return ref reactsWithinLimit {
      return measuredReactionTimeMs <= reactionTimeLimitMs;
    }
    objective estimateSafeStopTiming {
      doc /*
        Model-based evidence for superviseHazards: hazard detection to safe stop command within the 100 ms budget.
      */
    }
  }
  analysis def CoverageMapResolutionAnalysis {
    attribute cellSize : LengthValue = 100 [mm];
    attribute cellSizeLimit : LengthValue = 100 [mm];
    subject robot : AutonomousFloorCleaningRobot;
    return ref coverageGridWithinLimit {
      return cellSize <= cellSizeLimit;
    }
    objective estimateCoverageMapResolution {
      doc /*
        Model-based evidence for updateCoverageMap: grid resolution is fine enough for room-scale coverage decisions.
      */
    }
  }
}
