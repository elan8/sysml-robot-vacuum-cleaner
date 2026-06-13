package AnalysisCases {
  private import Architecture::*;
  private import MonetaryUnits::*;
  private import DesignLimits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  analysis def TotalPowerConsumptionAnalysis {
    attribute powerBudgetW : PowerValue = 75 [W];
    attribute ecoModePowerW : PowerValue = 54 [W];
    attribute standardModePowerW : PowerValue = 73 [W];
    attribute maxModePowerW : PowerValue = 94 [W];
    attribute standardModeMarginW : PowerValue = 2 [W];
    subject robot : AutonomousFloorCleaningRobot;
    return ref powerWithinBudget {
      return sum(
        robot.driveModule.powerDrawW,
        robot.cleaningHead.powerDrawW,
        robot.sensorAssembly.powerDrawW,
        robot.mainElectronics.powerDrawW,
        robot.powerModule.powerDrawW,
        robot.dockInterface.powerDrawW,
        robot.hmi.powerDrawW,
        robot.chassis.powerDrawW
      ) <= powerBudgetW;
    }
    objective estimatePower {
      doc /*
        Supporting engineering roll-up: assembly powerDrawW summed vs local 75 W budget
        (no dedicated system requirement; informs runtime and thermal design).
      */
    }
  }
  analysis def ProductCostAnalysis {
    attribute bomCostBudget : MonetaryAmount = 400 [EUR];
    attribute estimatedBomCost : MonetaryAmount = 397 [EUR];
    attribute bomCostMargin : MonetaryAmount = 3 [EUR];
    subject robot : AutonomousFloorCleaningRobot;
    return ref costWithinTarget {
      return sum(
        robot.driveModule.bomCost,
        robot.cleaningHead.bomCost,
        robot.sensorAssembly.bomCost,
        robot.mainElectronics.bomCost,
        robot.powerModule.bomCost,
        robot.dockInterface.bomCost,
        robot.hmi.bomCost,
        robot.chassis.bomCost
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
    attribute estimatedMass : MassValue = 4.95 [kg];
    attribute manufacturingMassAllowance : MassValue = 0.25 [kg];
    attribute designTargetMass : MassValue = 4.75 [kg];
    attribute massMarginToTarget : MassValue = -0.20 [kg];
    subject robot : AutonomousFloorCleaningRobot;
    return ref massWithinLimit {
      return sum(
        robot.driveModule.massKg,
        robot.cleaningHead.massKg,
        robot.sensorAssembly.massKg,
        robot.mainElectronics.massKg,
        robot.powerModule.massKg,
        robot.dockInterface.massKg,
        robot.hmi.massKg,
        robot.chassis.massKg
      ) <= massBudget;
    }
    objective estimateMass {
      doc /*
        Model-based evidence for limitTotalMass: mass roll-up vs DesignLimits.massBudget (5.0 kg).
        The nominal roll-up fits the absolute limit but misses the 4.75 kg engineering target
        once manufacturing allowance is included, so the design needs a mass-reduction action.
      */
    }
  }
  analysis def MissionEnergyAnalysis {
    attribute missionChargeDraw : ElectricChargeValue = 9375 [mAh];
    attribute chargeBudget : ElectricChargeValue = 12500 [mAh];
    attribute reserveCharge : ElectricChargeValue = 1875 [mAh];
    attribute usableMissionBudget : ElectricChargeValue = 10625 [mAh];
    attribute missionChargeMargin : ElectricChargeValue = 1250 [mAh];
    subject robot : AutonomousFloorCleaningRobot;
    return ref energyWithinBudget {
      return missionChargeDraw <= chargeBudget;
    }
    objective estimateMissionEnergy {
      doc /*
        Supporting mission charge draw vs battery capacity (9375 mAh mission profile
        against 12500 mAh pack at 14.4 V nominal; informs cleanAtLeastEighty runtime).
      */
    }
  }
  analysis def LocalizationPerformanceAnalysis {
    attribute baselineTofImuLocalizationError : LengthValue = 180 [mm];
    attribute premiumLidarSlamLocalizationError : LengthValue = 95 [mm];
    attribute estimatedLocalizationError : LengthValue = 95 [mm];
    attribute localizationErrorLimit : LengthValue = 150 [mm];
    subject robot : AutonomousFloorCleaningRobot;
    return ref localizationWithinLimit {
      return estimatedLocalizationError <= localizationErrorLimit;
    }
    objective estimateLocalization {
      doc /*
        Model-based evidence for localizeReliably: robotFirmware.localizationEstimator
        on mainElectronics (allocated to mainControlPcb.mcu) uses wheel odometry,
        IMU, 2D LiDAR scan matching, and short-range ToF observations. The former
        ToF+IMU baseline is retained as a low-cost trade option but does not meet
        the 150 mm standard-home-layout target with sufficient robustness.
      */
    }
  }
  analysis def SafetyReactionAnalysis {
    attribute measuredReactionTime : DurationValue = 90 [ms];
    attribute reactionTimeLimit : DurationValue = 100 [ms];
    subject robot : AutonomousFloorCleaningRobot;
    return ref reactsWithinLimit {
      return measuredReactionTime <= reactionTimeLimit;
    }
    objective estimateSafeStopTiming {
      doc /*
        Model-based evidence for superviseHazards: robotFirmware.safetySupervisor
        on mainElectronics (allocated to mainControlPcb.mcu) reacts within the 100 ms budget.
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
        Model-based evidence for updateCoverageMap: robotFirmware.mapProcessing and
        robotFirmware.coveragePlanner on mainElectronics (allocated to mainControlPcb.mcu)
        use a grid resolution fine enough for room-scale coverage decisions.
      */
    }
  }
}
