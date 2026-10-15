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

  connection wholeHomeCleaningCoverage : Derivation {
    @Rationale { text = "Cleaning the whole home in one run needs enough energy for the area and a path that actually reaches the floor. Area per charge bounds the first, coverage of the reachable floor the second."; }
    end :>> Derivation::originalRequirement ::> 'Whole-home cleaning in one run';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Cleaning area per charge';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Floor coverage';
  }

  connection safeOperationCoverage : Derivation {
    @Rationale { text = "The household hazards are falling, collision, entanglement and the battery. Each has a detection requirement, and all of them lead to one supervised safe stop, which holds until the hazard is gone and the user has confirmed. The battery additionally has protection that does not depend on firmware, because a firmware fault must not become a fire risk."; }
    end :>> Derivation::originalRequirement ::> 'Safe operation in the household';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Obstacle avoidance';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Cliff detection';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Safe stop on hazard';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Wheel stall detection and recovery';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Battery protection independent of firmware';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Safe stop held until cleared';
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
    @Rationale { text = "Progress and faults are carried by the mission status the robot reports to the application. The household also needs to know what the robot is doing at any moment, which is its operating mode."; }
    end :>> Derivation::originalRequirement ::> 'Mission progress and fault feedback';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Mission status reporting';
    end :>> Derivation::derivedRequirements ::> robotSystemSpecification.'Operating modes';
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
}
