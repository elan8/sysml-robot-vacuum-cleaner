/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns shared numeric design limits for budgets, mass, battery capacity,
 * localization, and safe-stop timing. Depends on unit and monetary libraries.
 * Keep requirement wording and analysis calculations outside this package.
 */
package DesignLimits {
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  attribute bomCostBudget : MonetaryAmount = 400 [EUR];
  attribute massBudget : MassValue = 5.0 [kg];
  attribute maxTotalPowerDraw : PowerValue = 75 [W];
  attribute cleaningAreaTarget : AreaValue = 80 [m^2];
  attribute floorCoverageTargetPercent : Integer = 90;
  attribute lowBatteryReturnThresholdPercent : Real = 15.0;
  attribute minimumAvoidedObstacleHeight : LengthValue = 30 [mm];
  attribute maxLocalizationError : LengthValue = 150 [mm];
  attribute minimumCliffHeight : LengthValue = 50 [mm];
  attribute maxNoiseLevel : SoundPressureLevelValue = 65 [dB];
  attribute maxControlLoopPeriod : DurationValue = 50 [ms];
  attribute maxSafeStopReactionTime : DurationValue = 100 [ms];
  attribute maxWheelStallDetectionTime : DurationValue = 2 [s];
  attribute maxCoverageGridCellSize : LengthValue = 100 [mm];
  attribute batteryCapacityBudget : ElectricChargeValue = 12500 [mAh];
}
