/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * The coverage argument of the system requirements: one derivation for each
 * customer requirement, naming every system requirement derived from it and
 * the reason that set is complete. A customer requirement is covered when
 * meeting all of its derived system requirements leaves nothing of it unmet.
 * The document data generator fails for a customer requirement without a
 * derivation and for a system requirement that no derivation names.
 */
package RequirementTraceability {
  private import RequirementDerivation::*;
  private import ModelingMetadata::*;
  private import StakeholderNeeds::*;
  private import SystemRequirements::*;
  private import ModuleRequirements::*;

  connection wholeHomeCleaningCoverage : Derivation {
    @Rationale { text = "Cleaning the whole home in one run needs enough energy for the area and a path that actually reaches the floor. Area per charge bounds the first, coverage of the reachable floor the second."; }
    end :>> Derivation::originalRequirement ::> 'Whole-home cleaning in one run';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Cleaning area per charge';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Floor coverage';
  }

  connection safeOperationCoverage : Derivation {
    @Rationale { text = "The household hazards are falling, collision, entanglement and the battery. Each has a detection requirement, and all of them lead to one supervised safe stop. The battery additionally has protection that does not depend on firmware, because a firmware fault must not become a fire risk."; }
    end :>> Derivation::originalRequirement ::> 'Safe operation in the household';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Obstacle avoidance';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Cliff detection';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Safe stop on hazard';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Wheel stall detection and recovery';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Battery protection independent of firmware';
  }

  connection dockingCoverage : Derivation {
    @Rationale { text = "Being ready the next day without help needs the robot to leave for the dock early enough, to charge safely once there, and to finish charging overnight."; }
    end :>> Derivation::originalRequirement ::> 'Unattended docking and charging';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Return to dock on low battery';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Charging within the battery safe operating area';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Recharge time';
  }

  connection navigationCoverage : Derivation {
    @Rationale { text = "Knowing where it is becomes a bound on localization error. Knowing where it has cleaned becomes a maintained coverage map."; }
    end :>> Derivation::originalRequirement ::> 'Reliable navigation at home';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Localization accuracy';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Coverage map maintenance';
  }

  connection feedbackCoverage : Derivation {
    @Rationale { text = "Progress and faults are both carried by the mission status the robot reports to the application."; }
    end :>> Derivation::originalRequirement ::> 'Mission progress and fault feedback';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Mission status reporting';
  }

  connection privacyCoverage : Derivation {
    @Rationale { text = "The map is the only personal data the robot creates. Keeping it local by default, with transfer only after explicit consent, is the whole need."; }
    end :>> Derivation::originalRequirement ::> 'Privacy of the home map';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Local storage of map data';
  }

  connection underFurnitureCoverage : Derivation {
    @Rationale { text = "Fitting under furniture with about 10 cm of clearance is one dimension, the overall height including the LiDAR turret, with margin for carpet pile."; }
    end :>> Derivation::originalRequirement ::> 'Cleaning under furniture';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Overall height';
  }

  connection quietOperationCoverage : Derivation {
    @Rationale { text = "A conversation in the same room is possible below about 65 dB(A), so the need becomes one sound pressure limit with a stated distance, floor and mode."; }
    end :>> Derivation::originalRequirement ::> 'Quiet operation';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Acoustic noise';
  }

  connection maintenanceCoverage : Derivation {
    @Rationale { text = "Emptying at most once per run needs a bin that holds the debris of one run of the reference home; doing it without tools is part of the same requirement."; }
    end :>> Derivation::originalRequirement ::> 'Easy routine maintenance';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Dust bin capacity';
  }

  connection thresholdCoverage : Derivation {
    @Rationale { text = "Door thresholds and rug edges in the target homes are up to 20 mm high; crossing them in both directions is one capability."; }
    end :>> Derivation::originalRequirement ::> 'Thresholds between rooms';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Threshold climbing';
  }

  connection carryingCoverage : Derivation {
    @Rationale { text = "Carrying in one hand is bounded by mass. The grip is a detail of the enclosure design under that limit."; }
    end :>> Derivation::originalRequirement ::> 'Carrying between floors';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Robot mass';
  }

  // Allocation of system requirements to module requirements.

  connection safeStopAllocation : Derivation {
    @Rationale { text = "The 100 ms from hazard to standstill is a chain of four steps in three modules: sensing 25 ms, supervisor decision 10 ms, drive disable 5 ms and braking 50 ms. The budgets add up to 90 ms, which leaves 10 ms unallocated margin."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Safe stop on hazard';
    end :>> Derivation::derivedRequirements ::> baseModuleSpecification.'Cliff sensing latency';
    end :>> Derivation::derivedRequirements ::> firmwareSpecification.'Safety supervisor deadline';
    end :>> Derivation::derivedRequirements ::> mainPcbSpecification.'Drive disable latency';
    end :>> Derivation::derivedRequirements ::> baseModuleSpecification.'Drive braking time';
  }

  connection massAllocation : Derivation {
    @Rationale { text = "Every gram of the robot belongs to one of five budgets, and the budgets add up to the 4.0 kg limit. Margin is held inside each module budget, so a module that grows has to renegotiate with the others rather than use up a common reserve unnoticed."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Robot mass';
    end :>> Derivation::derivedRequirements ::> baseModuleSpecification.'Base module mass';
    end :>> Derivation::derivedRequirements ::> topModuleSpecification.'Top module mass';
    end :>> Derivation::derivedRequirements ::> mainPcbSpecification.'Main board mass';
    end :>> Derivation::derivedRequirements ::> dustBinSpecification.'Dust bin mass';
    end :>> Derivation::derivedRequirements ::> harnessSpecification.'Wiring harness mass';
  }

  connection heightAllocation : Derivation {
    @Rationale { text = "The overall height is the base module up to the parting line plus the top module above it. The split at 57 mm follows the drive wheel diameter and the battery pack; the remaining 38 mm is for the shell and the scanner turret."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Overall height';
    end :>> Derivation::derivedRequirements ::> baseModuleSpecification.'Base module height';
    end :>> Derivation::derivedRequirements ::> topModuleSpecification.'Top module height';
  }

  connection energyAllocation : Derivation {
    @Rationale { text = "The mission energy analysis shows that 80 m² at an average of 2.6 A takes 4875 mAh. With a 15 % reserve for the return to the dock this needs a 6400 mAh pack."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Cleaning area per charge';
    end :>> Derivation::derivedRequirements ::> baseModuleSpecification.'Battery capacity';
  }

  connection rechargeAllocation : Derivation {
    @Rationale { text = "Recharging 85 % of 6400 mAh within 4 hours, including the constant-voltage tail, needs at least 2 A in the constant-current phase."; }
    end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Recharge time';
    end :>> Derivation::derivedRequirements ::> baseModuleSpecification.'Charge current';
  }
}
