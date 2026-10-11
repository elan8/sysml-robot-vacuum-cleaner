/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * The limits the system requirements set, and the system requirements on the
 * robot. Each requirement constrains one property of the robot against a
 * limit. A limit is written once, as an attribute: the constraint refers to it
 * and the requirement text shows it with a `{{= ...}}` placeholder, which Doc42
 * replaces by the value. The analyses and budgets use the same attributes.
 * Their derivation from the customer requirements is in RequirementTraceability.
 */
package RequirementLimits {
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
  attribute batteryCapacityBudget : ElectricChargeValue = 6400 [mAh];
  attribute maxOverallHeight : LengthValue = 95 [mm];
  attribute maxSoundPressureLevel : SoundPressureLevelValue = 65 [dB];
  attribute minDustBinCapacity : VolumeValue = 400 [mL];
  attribute minClimbableThreshold : LengthValue = 20 [mm];
  attribute maxRobotMass : MassValue = 4.0 [kg];
  attribute maxRechargeTime : DurationValue = 4 [h];
}

package SystemRequirements {
  private import Elan8Method::Metadata::*;
  private import RequirementLimits::*;
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
    attribute overallHeight : LengthValue;
    attribute soundPressureLevel : SoundPressureLevelValue;
    attribute dustBinCapacity : VolumeValue;
    attribute climbableThreshold : LengthValue;
    attribute robotMass : MassValue;
    attribute rechargeTime : DurationValue;
    attribute batteryProtectionIndependentOfFirmware : Boolean;
    attribute operatingModeReported : Boolean;
    attribute safeStopHeldUntilCleared : Boolean;
  }

  requirement robotSystemSpecification {
    subject robot : SystemRequirementSubject;
    @RequirementRole { role = system; }

  requirement <'SYS-001'> 'Cleaning area per charge' {
    @RequirementRole { role = performance; }
    require constraint { robot.cleanedAreaPerCharge >= cleaningAreaTarget }
    doc /* The robot shall clean at least 80 m² of floor on one battery charge in the reference home. */
    // The area is typed in the text: Spec42 does not evaluate a unit expression such as [m^2] yet.
  }

  requirement <'SYS-002'> 'Floor coverage' {
    @RequirementRole { role = performance; }
    require constraint {
      robot.reachableFloorCoveragePercent >= floorCoverageTargetPercent
    }
    doc /* The robot shall cover at least {{= RequirementLimits::floorCoverageTargetPercent}} percent of the reachable floor area in one mission. */
  }

  requirement <'SYS-003'> 'Obstacle avoidance' {
    @RequirementRole { role = safety; }
    require constraint {
      robot.avoidedObstacleHeight >= minimumAvoidedObstacleHeight
    }
    doc /* The robot shall avoid collision with household obstacles that are at least {{= RequirementLimits::minimumAvoidedObstacleHeight}} high. */
  }

  requirement <'SYS-SAFE-010'> 'Cliff detection' {
    @RequirementRole { role = safety; }
    require constraint {
      robot.cliffHeightDetectedBeforeWheelCrossing >= minimumCliffHeight
    }
    doc /* The robot shall detect a drop of at least {{= RequirementLimits::minimumCliffHeight}} before a wheel crosses its edge. */
  }

  requirement <'SYS-SAFE-011'> 'Safe stop on hazard' {
    @RequirementRole { role = safety; }
    require constraint { robot.safeStopOnHazard == true }
    doc /* The robot shall command a safe stop within {{= RequirementLimits::maxSafeStopReactionTime}} of a cliff, lift, collision, over-current or over-temperature hazard. */
  }

  requirement <'SYS-004'> 'Localization accuracy' {
    @RequirementRole { role = performance; }
    require constraint { robot.localizationError <= maxLocalizationError }
    doc /* The robot shall keep its localization error below {{= RequirementLimits::maxLocalizationError}} throughout the reference mission. */
  }

  requirement <'SYS-005'> 'Coverage map maintenance' {
    @RequirementRole { role = functional; }
    require constraint { robot.coverageMapMaintained == true }
    doc /* The robot shall maintain a map of cleaned, unreachable and unknown floor cells throughout a mission. */
  }

  requirement <'SYS-006'> 'Wheel stall detection and recovery' {
    @RequirementRole { role = functional; }
    require constraint {
      robot.wheelStallDetectionTime <= maxWheelStallDetectionTime
    }
    doc /* The robot shall detect a stalled drive wheel within {{= RequirementLimits::maxWheelStallDetectionTime}} and enter a bounded recovery. */
  }

  requirement <'SYS-007'> 'Return to dock on low battery' {
    @RequirementRole { role = functional; }
    require constraint {
      robot.lowBatteryReturnThresholdPercent <=
        lowBatteryReturnThresholdPercent
    }
    doc /* The robot shall return to its dock when the state of charge falls below {{= RequirementLimits::lowBatteryReturnThresholdPercent}} percent. */
  }

  requirement <'SYS-008'> 'Charging within the battery safe operating area' {
    @RequirementRole { role = safety; }
    require constraint {
      robot.chargeCurrentWithinSafeOperatingArea == true and
      robot.chargeTemperatureWithinSafeOperatingArea == true
    }
    doc /* The robot shall keep charge current and cell temperature inside the safe operating area of the battery. */
  }

  requirement <'SYS-009'> 'Mission status reporting' {
    @RequirementRole { role = 'interface'; }
    require constraint { robot.cleaningStatusReported == true }
    doc /* The robot shall report mission progress and faults to the local application during a mission. */
  }

  requirement <'SYS-010'> 'Local storage of map data' {
    @RequirementRole { role = security; }
    require constraint { robot.mapDataLocalUnlessConsented == true }
    doc /* The robot shall keep raw home-map data on the robot and the local network unless the user has explicitly consented to transfer. */
  }

  requirement <'SYS-011'> 'Overall height' {
    @RequirementRole { role = 'interface'; }
    require constraint { robot.overallHeight <= maxOverallHeight }
    doc /* The robot shall be no higher than {{= RequirementLimits::maxOverallHeight}}, including the laser scanner turret. */
  }

  requirement <'SYS-012'> 'Acoustic noise' {
    @RequirementRole { role = performance; }
    require constraint { robot.soundPressureLevel <= maxSoundPressureLevel }
    doc /* The robot shall emit a sound pressure level of at most {{= RequirementLimits::maxSoundPressureLevel}}(A) at 1 m while cleaning a hard floor at the default suction setting. */
  }

  requirement <'SYS-013'> 'Dust bin capacity' {
    @RequirementRole { role = functional; }
    require constraint { robot.dustBinCapacity >= minDustBinCapacity }
    doc /* The robot shall hold at least {{= RequirementLimits::minDustBinCapacity}} of debris in a dust bin that is removed and emptied without tools. */
  }

  requirement <'SYS-014'> 'Threshold climbing' {
    @RequirementRole { role = performance; }
    require constraint { robot.climbableThreshold >= minClimbableThreshold }
    doc /* The robot shall cross a rigid threshold at least {{= RequirementLimits::minClimbableThreshold}} high in both directions. */
  }

  requirement <'SYS-015'> 'Robot mass' {
    @RequirementRole { role = 'interface'; }
    require constraint { robot.robotMass <= maxRobotMass }
    doc /* The robot shall have a mass of at most {{= RequirementLimits::maxRobotMass}} with an empty dust bin. */
  }

  requirement <'SYS-016'> 'Recharge time' {
    @RequirementRole { role = performance; }
    require constraint { robot.rechargeTime <= maxRechargeTime }
    doc /* The robot shall recharge from the low-battery return threshold to full charge within {{= RequirementLimits::maxRechargeTime}} on its dock. */
  }

  requirement <'SYS-017'> 'Operating modes' {
    @RequirementRole { role = functional; }
    require constraint { robot.operatingModeReported == true }
    doc /* The robot shall at any time be in exactly one of the operating modes idle, cleaning, paused, returning to the dock, charging, safe stop and fault, and shall report a change of mode to the local application. */
  }

  requirement <'SYS-SAFE-013'> 'Safe stop held until cleared' {
    @RequirementRole { role = safety; }
    require constraint { robot.safeStopHeldUntilCleared == true }
    doc /* The robot shall remain stationary in safe stop, with drive and cleaning motors off, until the hazard is no longer present and the user has confirmed that the robot may continue. */
  }

  requirement <'SYS-SAFE-012'> 'Battery protection independent of firmware' {
    @RequirementRole { role = safety; }
    require constraint { robot.batteryProtectionIndependentOfFirmware == true }
    doc /* The robot shall disconnect the battery on over-current, over-voltage, under-voltage and over-temperature by hardware that works without the application firmware. */
  }
  }

}
