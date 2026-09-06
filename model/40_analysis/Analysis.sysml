/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Quantitative analysis cases (evidence concern).
 */
package AnalysisCases {
  private import Architecture::*;
  private import DesignLimits::*;
  private import Elan8::Units::Engineering::*;
  private import ISQ::*;
  private import SI::*;
  private import NumericalFunctions::*; // sum(...) in measuredReactionTime / baseElectronicsPowerDraw
  private import Elan8::Method::Core::*;

  analysis def MissionEnergyAnalysis {
    @EngineeringConcern { concern = evidence; }
    subject robot : AutonomousFloorCleaningRobot;
    attribute chargeBudget : ElectricChargeValue =
      DesignLimits::batteryCapacityBudget;
    attribute averageMissionCurrent : ElectricCurrentValue = 5 [A];
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
    @EngineeringConcern { concern = evidence; }
    subject robot : AutonomousFloorCleaningRobot;
    attribute sensorDetectionLatency : DurationValue = 25 [ms];
    attribute queueAndSchedulingLatency : DurationValue = 10 [ms];
    attribute safetyTaskExecutionLatency : DurationValue = 5 [ms];
    attribute motorDisableLatency : DurationValue = 50 [ms];
    attribute measuredReactionTime : DurationValue = sum(
      sensorDetectionLatency,
      queueAndSchedulingLatency,
      safetyTaskExecutionLatency,
      motorDisableLatency
    );
    attribute reactionTimeLimit : DurationValue =
      DesignLimits::maxSafeStopReactionTime;
    return ref reactsWithinLimit {
      return measuredReactionTime <= reactionTimeLimit;
    }
    objective estimateSafeStopTiming {
      doc /* Demonstrate the quantitative path from sensing to motor disable. */
    }
  }

  analysis def LocalizationPerformanceAnalysis {
    @EngineeringConcern { concern = evidence; }
    subject robot : AutonomousFloorCleaningRobot;
    attribute estimatedLocalizationError : LengthValue = 95 [mm];
    attribute localizationErrorLimit : LengthValue =
      DesignLimits::maxLocalizationError;
    return ref localizationWithinLimit {
      return estimatedLocalizationError <= localizationErrorLimit;
    }
    objective estimateLocalization {
      doc /* Confirm the selected ToF, LiDAR, IMU, and odometry baseline. */
    }
  }
}
