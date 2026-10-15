/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Quantitative analysis cases (evidence concern).
 */
package RobotAnalysisCases {
  private import Architecture::*;
  private import RequirementLimits::*;
  private import Elan8::Units::Engineering::*;
  private import ISQ::*;
  private import SI::*;
  private import NumericalFunctions::*; // sum(...) in measuredReactionTime / baseElectronicsPowerDraw

  analysis def MissionEnergyAnalysis {
    subject robot : AutonomousFloorCleaningRobot;
    attribute chargeBudget : ElectricChargeValue =
      RequirementLimits::batteryCapacityBudget;
    attribute averageMissionCurrent : ElectricCurrentValue = 2.6 [A];
    attribute missionDuration : DurationValue = 1.875 [h];
    attribute missionChargeDraw : ElectricChargeValue =
      averageMissionCurrent * missionDuration;
    attribute reserveCharge : ElectricChargeValue = chargeBudget * 0.15;
    attribute usableMissionBudget : ElectricChargeValue =
      chargeBudget - reserveCharge;
    return ref energyWithinBudget {
      return missionChargeDraw <= usableMissionBudget;
    }
    objective estimateMissionEnergy {
      doc /* Demonstrate quantity-based mission energy analysis with reserve. */
    }
  }

  analysis def SafetyReactionAnalysis {
    subject robot : AutonomousFloorCleaningRobot;
    attribute sensorDetectionLatency : DurationValue = robot.base.cliffSensingLatency;
    attribute supervisorDecisionLatency : DurationValue = robot.firmwareTasks.safetySupervisor.deadline;
    attribute driveDisableLatency : DurationValue = robot.mainPcb.driveDisableLatency;
    attribute brakingTime : DurationValue = robot.base.brakingTime;
    attribute measuredReactionTime : DurationValue = sum(
      sensorDetectionLatency,
      supervisorDecisionLatency,
      driveDisableLatency,
      brakingTime
    );
    attribute reactionTimeLimit : DurationValue =
      RequirementLimits::maxSafeStopReactionTime;
    return ref reactsWithinLimit {
      return measuredReactionTime <= reactionTimeLimit;
    }
    objective estimateSafeStopTiming {
      doc /* Add the design values of the four steps from hazard to standstill and compare the sum with the limit. */
    }
  }

  analysis def LocalizationPerformanceAnalysis {
    subject robot : AutonomousFloorCleaningRobot;
    attribute estimatedLocalizationError : LengthValue = 95 [mm];
    attribute localizationErrorLimit : LengthValue =
      RequirementLimits::maxLocalizationError;
    return ref localizationWithinLimit {
      return estimatedLocalizationError <= localizationErrorLimit;
    }
    objective estimateLocalization {
      doc /* Confirm the selected ToF, LiDAR, IMU, and odometry baseline. */
    }
  }

  analysis def MassBudgetAnalysis {
    subject robot : AutonomousFloorCleaningRobot;
    attribute baseMass : MassValue = robot.base.mass;
    attribute mainPcbMass : MassValue = robot.mainPcb.mass;
    attribute topMass : MassValue = robot.top.mass;
    attribute dustBinMass : MassValue = robot.dustBin.mass;
    attribute harnessMass : MassValue = robot.baseHarness.mass + robot.topHarness.mass;
    attribute totalMass : MassValue =
      sum(baseMass, mainPcbMass, topMass, dustBinMass, harnessMass);
    attribute massLimit : MassValue = maxRobotMass;
    return ref massWithinLimit {
      return totalMass <= massLimit;
    }
    objective massObjective {
      doc /* Roll up the module masses and compare the total with the mass limit. */
    }
  }
}
