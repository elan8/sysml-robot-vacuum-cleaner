/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Nine verification cases (verification concern).
 */
package Verification {
  private import RobotAnalysisCases::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import SystemRequirements::*;

  action def RunPhysicalTest;
  action def RunSoftwareVerification;
  action def RecordAnalysisResult;
  action def InspectAndMeasure;

  verification verifyMissionControl {
    subject task : MissionControllerTask;
    objective {
      verify robotSystemSpecification.'Wheel stall detection and recovery';
      verify robotSystemSpecification.'Return to dock on low battery';
      verify robotSystemSpecification.'Mission status reporting';
    }
    then action runMissionChecks : RunSoftwareVerification;
  }

  verification verifySafetySupervisor {
    subject task : SafetySupervisorTask;
    objective {
      verify robotSystemSpecification.'Safe stop on hazard';
      verify robotSystemSpecification.'Cliff detection';
      verify robotSystemSpecification.'Charging within the battery safe operating area';
    }
    then action runSafetyChecks : RunSoftwareVerification;
  }

  verification verifySensorAcquisition {
    subject task : SensorAcquisitionTask;
    objective {
      verify robotSystemSpecification.'Obstacle avoidance';
      verify robotSystemSpecification.'Cliff detection';
    }
    then action runSensorChecks : RunSoftwareVerification;
  }

  verification verifyActuatorControl {
    subject task : ActuatorControlTask;
    objective {
      verify robotSystemSpecification.'Wheel stall detection and recovery';
      verify robotSystemSpecification.'Safe stop on hazard';
    }
    then action runActuatorChecks : RunSoftwareVerification;
  }

  verification verifyAppPrivacy {
    subject task : AppServiceTask;
    objective {
      verify robotSystemSpecification.'Mission status reporting';
      verify robotSystemSpecification.'Local storage of map data';
    }
    then action runAppChecks : RunSoftwareVerification;
  }

  verification verifyCleaningCoverage {
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Cleaning area per charge';
      verify robotSystemSpecification.'Floor coverage';
    }
    ref energyAnalysis = MissionEnergyAnalysis;
    then action runCoverageMission : RunPhysicalTest;
    then action recordEnergyResult : RecordAnalysisResult;
  }

  verification verifyDockingAndCharging {
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Return to dock on low battery';
      verify robotSystemSpecification.'Charging within the battery safe operating area';
      verify robotSystemSpecification.'Recharge time';
    }
    then action runDockingMission : RunPhysicalTest;
  }

  verification verifyNavigationPerformance {
    subject task : NavigationTask;
    objective {
      verify robotSystemSpecification.'Localization accuracy';
      verify robotSystemSpecification.'Coverage map maintenance';
    }
    ref performanceAnalysis = LocalizationPerformanceAnalysis;
    then action runNavigationChecks : RunSoftwareVerification;
    then action recordLocalizationResult : RecordAnalysisResult;
  }

  verification verifyCliffSafeStop {
    doc /* Verifies the reaction time and outcome of the cliff safe-stop scenario. */
    subject scenario : CliffSafeStopScenario;
    objective {
      verify robotSystemSpecification.'Cliff detection';
      verify robotSystemSpecification.'Safe stop on hazard';
      verify robotSystemSpecification.'Mission status reporting';
    }
    ref reactionAnalysis = SafetyReactionAnalysis;
    then action executeScenario : RunPhysicalTest;
    then action recordReactionResult : RecordAnalysisResult;
  }

  verification verifyPhysicalEnvelope {
    doc /* Inspection and measurement of the assembled robot: height, mass and dust bin volume. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Overall height';
      verify robotSystemSpecification.'Robot mass';
      verify robotSystemSpecification.'Dust bin capacity';
    }
    ref massAnalysis = MassBudgetAnalysis;
    then action measureRobot : InspectAndMeasure;
    then action recordMassResult : RecordAnalysisResult;
  }

  verification verifyMobilityAndAcoustics {
    doc /* Threshold crossing in both directions and sound pressure level on a hard floor. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Threshold climbing';
      verify robotSystemSpecification.'Acoustic noise';
    }
    then action runThresholdAndNoiseTest : RunPhysicalTest;
  }

  verification verifyBatteryProtection {
    doc /* Fault injection on the battery pack with the application firmware halted. */
    subject bms : RobotBms;
    objective {
      verify robotSystemSpecification.'Battery protection independent of firmware';
      verify robotSystemSpecification.'Charging within the battery safe operating area';
    }
    then action injectBatteryFaults : RunPhysicalTest;
  }
}
