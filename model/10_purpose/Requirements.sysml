/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Stakeholder needs, measurable design limits, system requirements, and their
 * native derivation relationships.
 */
package DesignLimits {
  private import EngineeringUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  attribute cleaningAreaTarget : AreaValue = 80 [m^2];
  attribute floorCoverageTargetPercent : Integer = 90;
  attribute lowBatteryReturnThresholdPercent : Real = 15.0;
  attribute minimumAvoidedObstacleHeight : LengthValue = 30 [mm];
  attribute maxLocalizationError : LengthValue = 150 [mm];
  attribute minimumCliffHeight : LengthValue = 50 [mm];
  attribute maxSafeStopReactionTime : DurationValue = 100 [ms];
  attribute maxWheelStallDetectionTime : DurationValue = 2 [s];
  attribute batteryCapacityBudget : ElectricChargeValue = 12500 [mAh];
}

package StakeholderNeeds {
  private import Elan8RequirementMetadata::*;
  private import Elan8Method::*;

  requirement cleanLargeAreas {
    @RequirementRole { role = user; }
    @RequirementIdentity { requirementId = "USR-001"; }
    doc /* Clean the reachable floor efficiently in one autonomous mission. */
  }

  requirement operateSafely {
    @RequirementRole { role = user; }
    @RequirementIdentity { requirementId = "USR-SAFE-001"; }
    @EngineeringConcern { concern = purpose; }
    doc /* Operate safely around stairs, people, pets, and household obstacles. */
  }

  requirement reliableDocking {
    @RequirementRole { role = user; }
    @RequirementIdentity { requirementId = "USR-002"; }
    doc /* Return to the dock and charge without routine user intervention. */
  }

  requirement navigateReliably {
    @RequirementRole { role = user; }
    @RequirementIdentity { requirementId = "USR-003"; }
    doc /* Maintain a useful map and pose in a changing residential environment. */
  }

  requirement missionFeedback {
    @RequirementRole { role = user; }
    @RequirementIdentity { requirementId = "USR-004"; }
    doc /* Give the user clear mission progress and fault status. */
  }

  requirement respectPrivacy {
    @RequirementRole { role = user; }
    @RequirementIdentity { requirementId = "USR-005"; }
    doc /* Keep home-map data local unless the user explicitly consents to transfer. */
  }
}

package SystemRequirements {
  private import Elan8RequirementManagement::*;
  private import Elan8RequirementMetadata::*;
  private import Elan8Method::*;
  private import DesignLimits::*;
  private import StakeholderNeeds::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  abstract part def SystemRequirementSubject {
    attribute cleanedAreaPerCharge : AreaValue;
    attribute reachableFloorCoveragePercent : Integer;
    attribute avoidedObstacleHeight : LengthValue;
    attribute cliffHeightDetectedBeforeWheelCrossing : LengthValue;
    attribute safeStopOnHazard : Boolean;
    attribute localizationError : LengthValue;
    attribute coverageMapMaintained : Boolean;
    attribute wheelStallDetectionTime : DurationValue;
    attribute lowBatteryReturnThresholdPercent : Real;
    attribute chargeCurrentWithinSafeOperatingArea : Boolean;
    attribute chargeTemperatureWithinSafeOperatingArea : Boolean;
    attribute cleaningStatusReported : Boolean;
    attribute mapDataLocalUnlessConsented : Boolean;
  }

  requirement cleanAtLeastEighty {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = performance; }
    @RequirementIdentity { requirementId = "SYS-001"; }
    require constraint { robot.cleanedAreaPerCharge >= cleaningAreaTarget }
    doc /* Clean at least 80 m² on one charge. */
  }

  requirement coverFloor {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = performance; }
    @RequirementIdentity { requirementId = "SYS-002"; }
    require constraint {
      robot.reachableFloorCoveragePercent >= floorCoverageTargetPercent
    }
    doc /* Cover at least 90 percent of reachable floor area. */
  }

  requirement avoidObstacles {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = safety; }
    @RequirementIdentity { requirementId = "SYS-003"; }
    require constraint {
      robot.avoidedObstacleHeight >= minimumAvoidedObstacleHeight
    }
    doc /* Avoid household obstacles at least 30 mm high. */
  }

  requirement detectCliffs {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = safety; }
    @RequirementIdentity { requirementId = "SYS-SAFE-010"; }
    @EngineeringConcern { concern = purpose; }
    require constraint {
      robot.cliffHeightDetectedBeforeWheelCrossing >= minimumCliffHeight
    }
    doc /* Detect a drop of at least 50 mm before a wheel crosses it. */
  }

  requirement superviseHazards {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = safety; }
    @RequirementIdentity { requirementId = "SYS-SAFE-011"; }
    @EngineeringConcern { concern = purpose; }
    require constraint { robot.safeStopOnHazard == true }
    doc /* Command a safe stop for cliff, lift, collision, current, or thermal hazards. */
  }

  requirement localizeReliably {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = performance; }
    @RequirementIdentity { requirementId = "SYS-004"; }
    require constraint { robot.localizationError <= maxLocalizationError }
    doc /* Maintain localization error below 150 mm during the reference mission. */
  }

  requirement updateCoverageMap {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = functional; }
    @RequirementIdentity { requirementId = "SYS-005"; }
    require constraint { robot.coverageMapMaintained == true }
    doc /* Maintain cleaned, unreachable, and unknown cells throughout the mission. */
  }

  requirement recoverFromStall {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = functional; }
    @RequirementIdentity { requirementId = "SYS-006"; }
    require constraint {
      robot.wheelStallDetectionTime <= maxWheelStallDetectionTime
    }
    doc /* Detect a wheel stall within two seconds and enter bounded recovery. */
  }

  requirement returnToDock {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = functional; }
    @RequirementIdentity { requirementId = "SYS-007"; }
    require constraint {
      robot.lowBatteryReturnThresholdPercent <=
        lowBatteryReturnThresholdPercent
    }
    doc /* Return to the dock when state of charge falls below 15 percent. */
  }

  requirement chargeSafely {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = safety; }
    @RequirementIdentity { requirementId = "SYS-008"; }
    require constraint {
      robot.chargeCurrentWithinSafeOperatingArea == true and
      robot.chargeTemperatureWithinSafeOperatingArea == true
    }
    doc /* Keep charging current and temperature inside the battery operating area. */
  }

  requirement reportCleaningStatus {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = interface; }
    @RequirementIdentity { requirementId = "SYS-009"; }
    require constraint { robot.cleaningStatusReported == true }
    doc /* Report progress and faults to the local application during a mission. */
  }

  requirement protectMapPrivacy {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = security; }
    @RequirementIdentity { requirementId = "SYS-010"; }
    require constraint { robot.mapDataLocalUnlessConsented == true }
    doc /* Keep raw home-map data local unless the user explicitly consents. */
  }

  #derivation connection cleanAreaFromNeed {
    end #original ::> cleanLargeAreas;
    end #derive ::> cleanAtLeastEighty;
  }
  #derivation connection coverageFromNeed {
    end #original ::> cleanLargeAreas;
    end #derive ::> coverFloor;
  }
  #derivation connection obstacleFromSafety {
    end #original ::> operateSafely;
    end #derive ::> avoidObstacles;
  }
  #derivation connection cliffFromSafety {
    end #original ::> operateSafely;
    end #derive ::> detectCliffs;
  }
  #derivation connection supervisionFromSafety {
    end #original ::> operateSafely;
    end #derive ::> superviseHazards;
  }
  #derivation connection localizationFromNavigation {
    end #original ::> navigateReliably;
    end #derive ::> localizeReliably;
  }
  #derivation connection mappingFromNavigation {
    end #original ::> navigateReliably;
    end #derive ::> updateCoverageMap;
  }
  #derivation connection dockingFromNeed {
    end #original ::> reliableDocking;
    end #derive ::> returnToDock;
  }
  #derivation connection chargingFromNeed {
    end #original ::> reliableDocking;
    end #derive ::> chargeSafely;
  }
  #derivation connection statusFromNeed {
    end #original ::> missionFeedback;
    end #derive ::> reportCleaningStatus;
  }
  #derivation connection privacyFromNeed {
    end #original ::> respectPrivacy;
    end #derive ::> protectMapPrivacy;
  }
}
