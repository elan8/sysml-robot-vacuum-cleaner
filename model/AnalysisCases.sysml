package AnalysisCases {
  private import Architecture::*;
  private import MonetaryUnits::*;
  private import DesignLimits::*;
  private import ISQ::*;
  private import SI::*;

  analysis def TotalPowerConsumptionAnalysis {
    attribute powerBudgetW : PowerValue = 55 [W];
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
        robot.userInterface.powerDrawW
      ) <= powerBudgetW;
    }
    objective estimatePower {
      doc /*
        Supporting engineering roll-up: subsystem powerDrawW summed vs local 55 W budget
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
        robot.userInterface.bomCost
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
        robot.userInterface.massKg
      ) <= massBudget;
    }
    objective estimateMass {
      doc /*
        Model-based evidence for limitTotalMass: mass roll-up vs DesignLimits.massBudget (5.0 kg).
      */
    }
  }
  analysis def MissionEnergyAnalysis {
    attribute missionEnergyKWh : EnergyValue = 1116 [kJ];
    attribute energyBudgetKWh : EnergyValue = 1440 [kJ];
    subject robot : AutonomousFloorCleaningRobot;
    return ref energyWithinBudget {
      return missionEnergyKWh <= energyBudgetKWh;
    }
    objective estimateMissionEnergy {
      doc /*
        Supporting mission energy vs battery budget (informs cleanAtLeastEighty runtime; no separate requirement).
      */
    }
  }
}
