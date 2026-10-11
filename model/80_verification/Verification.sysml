/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Twelve verification cases for the system and module requirements. Each case
 * has an identifier, a method, a short procedure with its pass criterion, a
 * subject and the requirements it verifies. No case has been executed: the
 * model plans verification and holds no results.
 */
package Verification {
  private import VerificationCases::*;
  private import RobotAnalysisCases::*;
  private import Architecture::*;
  private import FirmwareArchitecture::*;
  private import OperationalScenarios::*;
  private import SystemRequirements::*;
  private import ModuleRequirements::*;

  action def RunPhysicalTest;
  action def RunSoftwareVerification;
  action def RecordAnalysisResult;
  action def InspectAndMeasure;

  verification <'VER-001'> 'Mission control firmware' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Run the mission controller on the target board against simulated sensor, battery and
         * application inputs. Pass when a stalled wheel is reported and recovered within the
         * limit, the return to the dock starts at the threshold state of charge, the robot is
         * always in exactly one operating mode, and every change of mode is reported. */
    subject task : MissionControllerTask;
    objective {
      verify robotSystemSpecification.'Wheel stall detection and recovery';
      verify robotSystemSpecification.'Return to dock on low battery';
      verify robotSystemSpecification.'Mission status reporting';
      verify robotSystemSpecification.'Operating modes';
    }
    then action runMissionChecks : RunSoftwareVerification;
  }

  verification <'VER-002'> 'Safety supervisor firmware' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Inject every hazard event on the target board under worst-case load of the other
         * tasks and measure the time to the safe-stop command with a logic analyser. Pass when
         * the command is issued within the deadline for every hazard in 1000 consecutive
         * injections, and no drive command is passed on until the hazard is removed and a
         * user confirmation is received. */
    subject task : SafetySupervisorTask;
    objective {
      verify robotSystemSpecification.'Safe stop on hazard';
      verify robotSystemSpecification.'Cliff detection';
      verify robotSystemSpecification.'Charging within the battery safe operating area';
      verify firmwareSpecification.'Safety supervisor deadline';
      verify robotSystemSpecification.'Safe stop held until cleared';
    }
    then action runSafetyChecks : RunSoftwareVerification;
  }

  verification <'VER-003'> 'Sensor acquisition firmware' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Replay recorded sensor data with obstacles and drops of known size through the
         * acquisition task. Pass when every obstacle of at least the minimum height and every
         * drop of at least the minimum depth produces its event. */
    subject task : SensorAcquisitionTask;
    objective {
      verify robotSystemSpecification.'Obstacle avoidance';
      verify robotSystemSpecification.'Cliff detection';
    }
    then action runSensorChecks : RunSoftwareVerification;
  }

  verification <'VER-004'> 'Actuator control firmware' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Drive the motor outputs on the target board into a blocked rotor and command a safe
         * stop at cleaning speed. Pass when the stall is detected within the limit and the
         * drive outputs are disabled on the safe-stop command. */
    subject task : ActuatorControlTask;
    objective {
      verify robotSystemSpecification.'Wheel stall detection and recovery';
      verify robotSystemSpecification.'Safe stop on hazard';
    }
    then action runActuatorChecks : RunSoftwareVerification;
  }

  verification <'VER-005'> 'Application service and map privacy' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    @VerificationMethod { kind = VerificationMethodKind::inspect; }
    doc /* Exercise the application interface on the home network and capture all traffic
         * leaving the robot, then inspect where map data is stored. Pass when status is
         * reported for every mission event and no map data leaves the robot without recorded
         * consent. */
    subject task : AppServiceTask;
    objective {
      verify robotSystemSpecification.'Mission status reporting';
      verify robotSystemSpecification.'Local storage of map data';
    }
    then action runAppChecks : RunSoftwareVerification;
  }

  verification <'VER-006'> 'Cleaning coverage mission' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    @VerificationMethod { kind = VerificationMethodKind::analyze; }
    doc /* Run a full mission in the reference home from a full charge and compare the cleaned
         * area with the surveyed reachable floor; confirm the energy margin with the mission
         * energy analysis. Pass when the cleaned area and the coverage meet their limits in
         * three consecutive missions. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Cleaning area per charge';
      verify robotSystemSpecification.'Floor coverage';
    }
    ref energyAnalysis = MissionEnergyAnalysis;
    then action runCoverageMission : RunPhysicalTest;
    then action recordEnergyResult : RecordAnalysisResult;
  }

  verification <'VER-007'> 'Docking and charging' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Let the robot run down to the return threshold in the reference home, return, dock
         * and recharge, while logging charge current, cell temperature and time. Pass when the
         * robot docks without help in ten of ten runs, charging stays inside the battery safe
         * operating area and the recharge time is within the limit. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Return to dock on low battery';
      verify robotSystemSpecification.'Charging within the battery safe operating area';
      verify robotSystemSpecification.'Recharge time';
      verify baseModuleSpecification.'Battery capacity';
      verify baseModuleSpecification.'Charge current';
    }
    then action runDockingMission : RunPhysicalTest;
  }

  verification <'VER-008'> 'Navigation performance' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    @VerificationMethod { kind = VerificationMethodKind::analyze; }
    doc /* Track the robot with an external reference system during the reference mission and
         * compare its estimated pose with the reference; support the result with the
         * localization performance analysis. Pass when the localization error stays within the
         * limit and the coverage map matches the floor actually cleaned. */
    subject task : NavigationTask;
    objective {
      verify robotSystemSpecification.'Localization accuracy';
      verify robotSystemSpecification.'Coverage map maintenance';
    }
    ref performanceAnalysis = LocalizationPerformanceAnalysis;
    then action runNavigationChecks : RunSoftwareVerification;
    then action recordLocalizationResult : RecordAnalysisResult;
  }

  verification <'VER-009'> 'Cliff safe stop' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    @VerificationMethod { kind = VerificationMethodKind::analyze; }
    doc /* Drive the robot at cleaning speed towards a drop on the cliff rig from four
         * directions and record sensing, command and wheel motion with a high-speed camera and
         * a logic analyser; compare with the safety reaction analysis. Pass when no wheel
         * crosses the edge, the time from hazard to standstill is within the limit in every
         * run, each step is within its module budget, the safe stop is reported, and the robot
         * stays stationary until the drop is covered and the user confirms. */
    subject scenario : CliffSafeStopScenario;
    objective {
      verify robotSystemSpecification.'Cliff detection';
      verify robotSystemSpecification.'Safe stop on hazard';
      verify robotSystemSpecification.'Mission status reporting';
      verify baseModuleSpecification.'Cliff sensing latency';
      verify baseModuleSpecification.'Drive braking time';
      verify mainPcbSpecification.'Drive disable latency';
      verify robotSystemSpecification.'Safe stop held until cleared';
    }
    ref reactionAnalysis = SafetyReactionAnalysis;
    then action executeScenario : RunPhysicalTest;
    then action recordReactionResult : RecordAnalysisResult;
  }

  verification <'VER-010'> 'Physical envelope' {
    @VerificationMethod { kind = VerificationMethodKind::inspect; }
    @VerificationMethod { kind = VerificationMethodKind::analyze; }
    doc /* Measure the height of the assembled robot on a surface plate, weigh the robot and
         * each module, and measure the dust bin volume by filling; compare the masses with the
         * mass budget analysis. Pass when every measured value is within its limit or budget. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Overall height';
      verify robotSystemSpecification.'Robot mass';
      verify robotSystemSpecification.'Dust bin capacity';
      verify baseModuleSpecification.'Base module mass';
      verify baseModuleSpecification.'Base module height';
      verify mainPcbSpecification.'Main board mass';
      verify topModuleSpecification.'Top module height';
      verify topModuleSpecification.'Top module mass';
      verify dustBinSpecification.'Dust bin mass';
      verify harnessSpecification.'Wiring harness mass';
    }
    ref massAnalysis = MassBudgetAnalysis;
    then action measureRobot : InspectAndMeasure;
    then action recordMassResult : RecordAnalysisResult;
  }

  verification <'VER-011'> 'Mobility and acoustics' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Cross a rigid threshold of the limit height in both directions ten times, and
         * measure the sound pressure level at 1 m while cleaning a hard floor in a low-noise
         * room. Pass when every crossing succeeds and the A-weighted level is within the
         * limit. */
    subject robot : AutonomousFloorCleaningRobot;
    objective {
      verify robotSystemSpecification.'Threshold climbing';
      verify robotSystemSpecification.'Acoustic noise';
    }
    then action runThresholdAndNoiseTest : RunPhysicalTest;
  }

  verification <'VER-012'> 'Battery protection' {
    @VerificationMethod { kind = VerificationMethodKind::test; }
    doc /* Apply over-current, over-voltage, under-voltage and over-temperature to the battery
         * pack on the fault injection bench with the application firmware halted. Pass when
         * the pack disconnects for every fault without firmware action. */
    subject bms : RobotBms;
    objective {
      verify robotSystemSpecification.'Battery protection independent of firmware';
      verify robotSystemSpecification.'Charging within the battery safe operating area';
    }
    then action injectBatteryFaults : RunPhysicalTest;
  }
}
