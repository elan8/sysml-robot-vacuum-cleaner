/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Three quantitative analyses and nine verification cases.
 */
package AnalysisCases {
  private import Architecture::*;
  private import DesignLimits::*;
  private import VacuumCleanerQuantitiesAndUnits::*;
  private import ISQ::*;
  private import SI::*;

  analysis def MissionEnergyAnalysis {
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

package Verification {
  private import AnalysisCases::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import SystemRequirements::*;

  action def RunPhysicalTest;
  action def RunSoftwareVerification;
  action def RecordAnalysisResult;

  verification verifyMissionControl {
    subject task : MissionControllerTask;
    objective {
      verify requirement recoverFromStall;
      verify requirement returnToDock;
      verify requirement reportCleaningStatus;
    }
    then action runMissionChecks : RunSoftwareVerification;
  }

  verification verifySafetySupervisor {
    subject task : SafetySupervisorTask;
    objective {
      verify requirement superviseHazards;
      verify requirement detectCliffs;
      verify requirement chargeSafely;
    }
    then action runSafetyChecks : RunSoftwareVerification;
  }

  verification verifySensorAcquisition {
    subject task : SensorAcquisitionTask;
    objective {
      verify requirement avoidObstacles;
      verify requirement detectCliffs;
    }
    then action runSensorChecks : RunSoftwareVerification;
  }

  verification verifyActuatorControl {
    subject task : ActuatorControlTask;
    objective {
      verify requirement recoverFromStall;
      verify requirement superviseHazards;
    }
    then action runActuatorChecks : RunSoftwareVerification;
  }

  verification verifyAppPrivacy {
    subject task : AppServiceTask;
    objective {
      verify requirement reportCleaningStatus;
      verify requirement protectMapPrivacy;
    }
    then action runAppChecks : RunSoftwareVerification;
  }

  verification verifyCleaningCoverage {
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement cleanAtLeastEighty;
      verify requirement coverFloor;
    }
    ref energyAnalysis = MissionEnergyAnalysis;
    then action runCoverageMission : RunPhysicalTest;
    then action recordEnergyResult : RecordAnalysisResult;
  }

  verification verifyDockingAndCharging {
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement returnToDock;
      verify requirement chargeSafely;
    }
    then action runDockingMission : RunPhysicalTest;
  }

  verification verifyNavigationPerformance {
    subject task : NavigationTask;
    objective {
      verify requirement localizeReliably;
      verify requirement updateCoverageMap;
    }
    ref performanceAnalysis = LocalizationPerformanceAnalysis;
    then action runNavigationChecks : RunSoftwareVerification;
    then action recordLocalizationResult : RecordAnalysisResult;
  }

  verification verifyCliffSafeStop {
    subject thread : CliffSafeStopGoldenThread;
    objective {
      verify requirement detectCliffs;
      verify requirement superviseHazards;
      verify requirement reportCleaningStatus;
    }
    ref reactionAnalysis = SafetyReactionAnalysis;
    then action executeGoldenThread : RunPhysicalTest;
    then action recordReactionResult : RecordAnalysisResult;
  }
}
