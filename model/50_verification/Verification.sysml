/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Nine verification cases (verification concern).
 */
package Verification {
  private import AnalysisCases::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import SystemRequirements::*;
  private import Elan8::Method::Core::*;

  action def RunPhysicalTest;
  action def RunSoftwareVerification;
  action def RecordAnalysisResult;

  verification verifyMissionControl {
    @EngineeringConcern { concern = verification; }
    subject task : MissionControllerTask;
    objective {
      verify requirement robotSystemSpecification.recoverFromStall;
      verify requirement robotSystemSpecification.returnToDock;
      verify requirement robotSystemSpecification.reportCleaningStatus;
    }
    then action runMissionChecks : RunSoftwareVerification;
  }

  verification verifySafetySupervisor {
    @EngineeringConcern { concern = verification; }
    subject task : SafetySupervisorTask;
    objective {
      verify requirement robotSystemSpecification.superviseHazards;
      verify requirement robotSystemSpecification.detectCliffs;
      verify requirement robotSystemSpecification.chargeSafely;
    }
    then action runSafetyChecks : RunSoftwareVerification;
  }

  verification verifySensorAcquisition {
    subject task : SensorAcquisitionTask;
    objective {
      verify requirement robotSystemSpecification.avoidObstacles;
      verify requirement robotSystemSpecification.detectCliffs;
    }
    then action runSensorChecks : RunSoftwareVerification;
  }

  verification verifyActuatorControl {
    subject task : ActuatorControlTask;
    objective {
      verify requirement robotSystemSpecification.recoverFromStall;
      verify requirement robotSystemSpecification.superviseHazards;
    }
    then action runActuatorChecks : RunSoftwareVerification;
  }

  verification verifyAppPrivacy {
    subject task : AppServiceTask;
    objective {
      verify requirement robotSystemSpecification.reportCleaningStatus;
      verify requirement robotSystemSpecification.protectMapPrivacy;
    }
    then action runAppChecks : RunSoftwareVerification;
  }

  verification verifyCleaningCoverage {
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement robotSystemSpecification.cleanAtLeastEighty;
      verify requirement robotSystemSpecification.coverFloor;
    }
    ref energyAnalysis = MissionEnergyAnalysis;
    then action runCoverageMission : RunPhysicalTest;
    then action recordEnergyResult : RecordAnalysisResult;
  }

  verification verifyDockingAndCharging {
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify requirement robotSystemSpecification.returnToDock;
      verify requirement robotSystemSpecification.chargeSafely;
    }
    then action runDockingMission : RunPhysicalTest;
  }

  verification verifyNavigationPerformance {
    subject task : NavigationTask;
    objective {
      verify requirement robotSystemSpecification.localizeReliably;
      verify requirement robotSystemSpecification.updateCoverageMap;
    }
    ref performanceAnalysis = LocalizationPerformanceAnalysis;
    then action runNavigationChecks : RunSoftwareVerification;
    then action recordLocalizationResult : RecordAnalysisResult;
  }

  verification verifyCliffSafeStop {
    @EngineeringConcern { concern = verification; }
    doc /* Verifies the reaction time and outcome of the cliff safe-stop scenario. */
    subject scenario : CliffSafeStopScenario;
    objective {
      verify requirement robotSystemSpecification.detectCliffs;
      verify requirement robotSystemSpecification.superviseHazards;
      verify requirement robotSystemSpecification.reportCleaningStatus;
    }
    ref reactionAnalysis = SafetyReactionAnalysis;
    then action executeScenario : RunPhysicalTest;
    then action recordReactionResult : RecordAnalysisResult;
  }
}
