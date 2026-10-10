/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Stakeholder needs, measurable design limits, system requirements, and their
 * requirement hierarchy and refinement traceability.
 */
package DesignLimits {
  private import Elan8::Units::Engineering::*;
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
  private import Elan8Method::Metadata::*;

  requirement <'USR-001'> cleanLargeAreas {
    @RequirementRole { role = user; }
    doc /* Clean the reachable floor efficiently in one autonomous mission. */
  }

  requirement <'USR-SAFE-001'> operateSafely {
    @RequirementRole { role = user; }
    doc /* Operate safely around stairs, people, pets, and household obstacles. */
  }

  requirement <'USR-002'> reliableDocking {
    @RequirementRole { role = user; }
    doc /* Return to the dock and charge without routine user intervention. */
  }

  requirement <'USR-003'> navigateReliably {
    @RequirementRole { role = user; }
    doc /* Maintain a useful map and pose in a changing residential environment. */
  }

  requirement <'USR-004'> missionFeedback {
    @RequirementRole { role = user; }
    doc /* Give the user clear mission progress and fault status. */
  }

  requirement <'USR-005'> respectPrivacy {
    @RequirementRole { role = user; }
    doc /* Keep home-map data local unless the user explicitly consents to transfer. */
  }
}

package SystemRequirements {
  private import Elan8Method::Metadata::*;
  private import DesignLimits::*;
  private import StakeholderNeeds::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;
  private import ModelingMetadata::*;

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

  requirement robotSystemSpecification {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }

  requirement <'SYS-001'> cleanAtLeastEighty {
    @RequirementRole { role = performance; }
    require constraint { robot.cleanedAreaPerCharge >= cleaningAreaTarget }
    doc /* Clean at least 80 m² on one charge. */
  }

  requirement <'SYS-002'> coverFloor {
    @RequirementRole { role = performance; }
    require constraint {
      robot.reachableFloorCoveragePercent >= floorCoverageTargetPercent
    }
    doc /* Cover at least 90 percent of reachable floor area. */
  }

  requirement <'SYS-003'> avoidObstacles {
    @RequirementRole { role = safety; }
    require constraint {
      robot.avoidedObstacleHeight >= minimumAvoidedObstacleHeight
    }
    doc /* Avoid household obstacles at least 30 mm high. */
  }

  requirement <'SYS-SAFE-010'> detectCliffs {
    @RequirementRole { role = safety; }
    require constraint {
      robot.cliffHeightDetectedBeforeWheelCrossing >= minimumCliffHeight
    }
    doc /* Detect a drop of at least 50 mm before a wheel crosses it. */
  }

  requirement <'SYS-SAFE-011'> superviseHazards {
    @RequirementRole { role = safety; }
    require constraint { robot.safeStopOnHazard == true }
    doc /* Command a safe stop for cliff, lift, collision, current, or thermal hazards. */
  }

  requirement <'SYS-004'> localizeReliably {
    @RequirementRole { role = performance; }
    require constraint { robot.localizationError <= maxLocalizationError }
    doc /* Maintain localization error below 150 mm during the reference mission. */
  }

  requirement <'SYS-005'> updateCoverageMap {
    @RequirementRole { role = functional; }
    require constraint { robot.coverageMapMaintained == true }
    doc /* Maintain cleaned, unreachable, and unknown cells throughout the mission. */
  }

  requirement <'SYS-006'> recoverFromStall {
    @RequirementRole { role = functional; }
    require constraint {
      robot.wheelStallDetectionTime <= maxWheelStallDetectionTime
    }
    doc /* Detect a wheel stall within two seconds and enter bounded recovery. */
  }

  requirement <'SYS-007'> returnToDock {
    @RequirementRole { role = functional; }
    require constraint {
      robot.lowBatteryReturnThresholdPercent <=
        lowBatteryReturnThresholdPercent
    }
    doc /* Return to the dock when state of charge falls below 15 percent. */
  }

  requirement <'SYS-008'> chargeSafely {
    @RequirementRole { role = safety; }
    require constraint {
      robot.chargeCurrentWithinSafeOperatingArea == true and
      robot.chargeTemperatureWithinSafeOperatingArea == true
    }
    doc /* Keep charging current and temperature inside the battery operating area. */
  }

  requirement <'SYS-009'> reportCleaningStatus {
    @RequirementRole { role = 'interface'; }
    require constraint { robot.cleaningStatusReported == true }
    doc /* Report progress and faults to the local application during a mission. */
  }

  requirement <'SYS-010'> protectMapPrivacy {
    @RequirementRole { role = security; }
    require constraint { robot.mapDataLocalUnlessConsented == true }
    doc /* Keep raw home-map data local unless the user explicitly consents. */
  }
  }

  dependency cleanAreaRefinement
    from robotSystemSpecification::cleanAtLeastEighty to cleanLargeAreas {
    @Refinement;
  }
  dependency coverageRefinement
    from robotSystemSpecification::coverFloor to cleanLargeAreas {
    @Refinement;
  }
  dependency obstacleRefinement
    from robotSystemSpecification::avoidObstacles to operateSafely {
    @Refinement;
  }
  dependency cliffRefinement
    from robotSystemSpecification::detectCliffs to operateSafely {
    @Refinement;
  }
  dependency supervisionRefinement
    from robotSystemSpecification::superviseHazards to operateSafely {
    @Refinement;
  }
  dependency stallRecoveryRefinement
    from robotSystemSpecification::recoverFromStall to operateSafely {
    @Refinement;
  }
  dependency localizationRefinement
    from robotSystemSpecification::localizeReliably to navigateReliably {
    @Refinement;
  }
  dependency mappingRefinement
    from robotSystemSpecification::updateCoverageMap to navigateReliably {
    @Refinement;
  }
  dependency dockingRefinement
    from robotSystemSpecification::returnToDock to reliableDocking {
    @Refinement;
  }
  dependency chargingRefinement
    from robotSystemSpecification::chargeSafely to reliableDocking {
    @Refinement;
  }
  dependency statusRefinement
    from robotSystemSpecification::reportCleaningStatus to missionFeedback {
    @Refinement;
  }
  dependency privacyRefinement
    from robotSystemSpecification::protectMapPrivacy to respectPrivacy {
    @Refinement;
  }
}
