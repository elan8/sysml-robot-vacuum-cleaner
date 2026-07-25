/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns derived system requirements and requirement derivation links from
 * stakeholder needs. Depends on metadata libraries, StakeholderNeeds, and
 * DesignLimits. Keep verification procedures, analyses, and physical solution
 * structure elsewhere.
 */
package SystemRequirements {
  private import RequirementMetadata::*;
  private import ModelingMetadata::*;
  private import MonetaryUnits::*;
  private import DesignLimits::*;
  private import StakeholderNeeds::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  abstract part def SystemRequirementSubject {
    doc /*
      Requirement-facing abstraction of measurable system properties. Concrete
      architecture elements satisfy these requirements without making the
      requirements package depend on solution-structure packages.
    */
    attribute cleanedAreaPerCharge : AreaValue;
    attribute lowBatteryReturnThresholdPercent : Real;
    attribute avoidedObstacleHeight : LengthValue;
    attribute dustBinFullDetected : Boolean;
    attribute standardModeNoise : SoundPressureLevelValue;
    attribute reachableFloorCoveragePercent : Integer;
    attribute cleaningStatusReported : Boolean;
    attribute bomCost : MonetaryAmount;
    attribute totalMass : MassValue;
    attribute cliffHeightDetectedBeforeWheelCrossing : LengthValue;
    attribute localizationError : LengthValue;
    attribute coverageMapMaintained : Boolean;
    attribute roomScaleSlamSupported : Boolean;
    attribute wheelStallDetectionTime : DurationValue;
    attribute mapDataLocalUnlessConsented : Boolean;
    attribute chargeCurrentWithinSafeOperatingArea : Boolean;
    attribute chargeTemperatureWithinSafeOperatingArea : Boolean;
    attribute safeStopOnHazard : Boolean;
    attribute toolLessBinRemoval : Boolean;
    attribute binRemovedOrMissingDetectedBeforeCleaning : Boolean;
    attribute maintenanceNotificationIssued : Boolean;
  }

  requirement cleanAtLeastEighty {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.cleanedAreaPerCharge >= cleaningAreaTarget }
    doc /* The robot shall clean at least 80 m² on a single charge. */
  }
  requirement returnToDock {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.lowBatteryReturnThresholdPercent <= lowBatteryReturnThresholdPercent }
    doc /* The robot shall return to the docking station when battery state of charge drops below 15%. */
  }
  requirement avoidObstacles {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.avoidedObstacleHeight >= minimumAvoidedObstacleHeight }
    doc /* The robot shall avoid obstacles higher than 30 mm. */
  }
  requirement detectDustBin {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.dustBinFullDetected == true }
    doc /* The robot shall detect when the dust bin is full. */
  }
  requirement keepNoise {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.standardModeNoise <= maxNoiseLevel }
    doc /* The robot shall keep acoustic noise below 65 dBA in standard mode. */
  }
  requirement coverFloor {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.reachableFloorCoveragePercent >= floorCoverageTargetPercent }
    doc /* The robot shall cover at least 90% of reachable floor area in a rectangular room. */
  }
  requirement reportCleaningStatus {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.cleaningStatusReported == true }
    doc /* The robot shall report cleaning progress and status to the mobile app during a mission. */
  }
  requirement limitBomCost {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.bomCost <= bomCostBudget }
    doc /* The bill of materials at target production volume shall not exceed 400 EUR. */
  }
  requirement limitTotalMass {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.totalMass <= massBudget }
    doc /* The total robot mass shall not exceed 5.0 kg. */
  }
  requirement detectCliffs {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.cliffHeightDetectedBeforeWheelCrossing >= minimumCliffHeight }
    doc /* The robot shall detect floor drop-offs of at least 50 mm before any wheel crosses the edge. */
  }
  requirement localizeReliably {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.localizationError <= maxLocalizationError }
    doc /* The robot shall maintain localization error below 150 mm during a standard home-layout cleaning mission using the selected premium SLAM sensor set. */
  }
  requirement updateCoverageMap {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.coverageMapMaintained == true }
    doc /* The robot shall maintain a coverage map with cleaned, unreachable, and unknown cells during the mission. */
  }
  requirement supportRoomScaleSlam {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.roomScaleSlamSupported == true }
    doc /* The robot shall build and reuse a room-scale map using wheel odometry, IMU, 2D LiDAR scan matching, and short-range ToF observations. */
  }
  requirement recoverFromStall {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.wheelStallDetectionTime <= maxWheelStallDetectionTime }
    doc /* The robot shall detect a wheel stall within 2 s and enter a bounded recovery maneuver. */
  }
  requirement protectMapPrivacy {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.mapDataLocalUnlessConsented == true }
    doc /* The robot shall keep raw home map data local unless the user explicitly enables cloud backup. */
  }
  requirement chargeSafely {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint {
      robot.chargeCurrentWithinSafeOperatingArea == true and
      robot.chargeTemperatureWithinSafeOperatingArea == true
    }
    doc /* The robot shall limit charge current and temperature within the battery manufacturer's safe operating area. */
  }
  requirement superviseHazards {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.safeStopOnHazard == true }
    doc /* The robot shall command a safe stop when cliff, bumper, lift, overcurrent, or thermal hazards are detected. */
  }
  requirement emptyBinWithoutTools {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.toolLessBinRemoval == true }
    doc /* The dust bin shall be removable and replaceable by a home user without tools. */
  }
  requirement detectBinRemovedOrMissing {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.binRemovedOrMissingDetectedBeforeCleaning == true }
    doc /* The robot shall detect when the dust bin is removed, missing, or not latched before cleaning starts. */
  }
  requirement notifyMaintenanceNeeded {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }
    @StatusInfo { status = done; }
    require constraint { robot.maintenanceNotificationIssued == true }
    doc /* The robot shall notify the user when dust-bin emptying or routine cleaning-head maintenance is needed. */
  }

  #derivation connection cleanAtLeastEighty_from_cleanLargeAreas {
    end #original ::> cleanLargeAreas;
    end #derive ::> cleanAtLeastEighty;
  }
  #derivation connection returnToDock_from_reliableDocking {
    end #original ::> reliableDocking;
    end #derive ::> returnToDock;
  }
  #derivation connection avoidObstacles_from_operateSafely {
    end #original ::> operateSafely;
    end #derive ::> avoidObstacles;
  }
  #derivation connection detectDustBin_from_cleanLargeAreas {
    end #original ::> cleanLargeAreas;
    end #derive ::> detectDustBin;
  }
  #derivation connection keepNoise_from_quietCleaning {
    end #original ::> quietCleaning;
    end #derive ::> keepNoise;
  }
  #derivation connection coverFloor_from_cleanLargeAreas {
    end #original ::> cleanLargeAreas;
    end #derive ::> coverFloor;
  }
  #derivation connection reportCleaningStatus_from_missionFeedback {
    end #original ::> missionFeedback;
    end #derive ::> reportCleaningStatus;
  }
  #derivation connection limitBomCost_from_affordableProduct {
    end #original ::> affordableProduct;
    end #derive ::> limitBomCost;
  }
  #derivation connection limitTotalMass_from_portableDesign {
    end #original ::> portableDesign;
    end #derive ::> limitTotalMass;
  }
  #derivation connection detectCliffs_from_protectHomes {
    end #original ::> protectHomes;
    end #derive ::> detectCliffs;
  }
  #derivation connection localizeReliably_from_adaptToHomes {
    end #original ::> adaptToHomes;
    end #derive ::> localizeReliably;
  }
  #derivation connection supportRoomScaleSlam_from_adaptToHomes {
    end #original ::> adaptToHomes;
    end #derive ::> supportRoomScaleSlam;
  }
  #derivation connection updateCoverageMap_from_adaptToHomes {
    end #original ::> adaptToHomes;
    end #derive ::> updateCoverageMap;
  }
  #derivation connection recoverFromStall_from_tolerateFaults {
    end #original ::> tolerateFaults;
    end #derive ::> recoverFromStall;
  }
  #derivation connection protectMapPrivacy_from_respectPrivacy {
    end #original ::> respectPrivacy;
    end #derive ::> protectMapPrivacy;
  }
  #derivation connection chargeSafely_from_maintainBatteryHealth {
    end #original ::> maintainBatteryHealth;
    end #derive ::> chargeSafely;
  }
  #derivation connection superviseHazards_from_protectHomes {
    end #original ::> protectHomes;
    end #derive ::> superviseHazards;
  }
  #derivation connection emptyBinWithoutTools_from_easyToEmpty {
    end #original ::> easyToEmpty;
    end #derive ::> emptyBinWithoutTools;
  }
  #derivation connection detectBinRemovedOrMissing_from_easyToEmpty {
    end #original ::> easyToEmpty;
    end #derive ::> detectBinRemovedOrMissing;
  }
  #derivation connection notifyMaintenanceNeeded_from_easyToEmpty {
    end #original ::> easyToEmpty;
    end #derive ::> notifyMaintenanceNeeded;
  }
}
