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
      verify requirement recoverFromStall;
      verify requirement returnToDock;
      verify requirement reportCleaningStatus;
    }
    then action runMissionChecks : RunSoftwareVerification;
  }

  verification verifySafetySupervisor {
    @EngineeringConcern { concern = verification; }
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
    @EngineeringConcern { concern = verification; }
    doc /* Verifies the cliff safe-stop engineering increment reaction time. */
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
