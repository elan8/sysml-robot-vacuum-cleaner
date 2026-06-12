package DesignLimits {
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;
  attribute bomCostBudget : MonetaryAmount = 400 [EUR];
  attribute massBudget : MassValue = 5.0 [kg];
  attribute cleaningAreaTarget : AreaValue = 80 [m^2];
  attribute floorCoverageTargetPercent : Integer = 90;
  attribute maxLocalizationError : LengthValue = 150 [mm];
  attribute minimumCliffHeight : LengthValue = 50 [mm];
  attribute maxNoiseLevelDbA : Integer = 65;
  attribute maxControlLoopPeriodMs : Integer = 50;
  attribute maxSafeStopReactionTimeMs : Integer = 100;
  attribute batteryEnergyBudget : EnergyValue = 648 [kJ];
}
