/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package RobotPlatformSystem {
    private import NumericalFunctions::*;
    // sum(...) in the rolled-up mass/power attributes
    private import BehaviorStates::*;
    private import DomainModel::*;
    private import ProductContext::CleaningRobot;
    private import Elan8::Electronics::Core::*;
    private import Elan8::Electronics::Actuation::*;
    private import Elan8::Electronics::Sensing::*;
    private import Elan8::Electronics::Power::*;
    private import Elan8::Electronics::Assembly::*;
    private import Elan8::Electronics::Board::*;
    private import Elan8::Electronics::Buses::*;
    private import Elan8::Electronics::Interconnection::*;
    private import Elan8::Mechanical::Core::*;
    private import Elan8::Mechanical::Drivetrain::*;
    private import Elan8::Mechanical::Interconnection::*;
    private import Elan8::Electronics::Compute::*;
    private import FirmwareArchitecture::*;
    private import PurchasedParts::*;
    private import Sourcing::*;
    private import SystemRequirements::*;
    private import Elan8::Software::*;
    private import Elan8::Electronics::Wireless::*;
    private import Elan8::Units::Engineering::*;
    private import ISQ::*;
    private import SI::*;
    private import ScalarValues::*;
    private import FunctionalArchitecture::*;
    private import PhysicalArchitecture::*;
    private import ModuleRequirements::*;
    private import FirmwareLibrary::*;
    private import PhysicalShared::*;
    private import StandardViewDefinitions::*;
    private import ReviewConcerns::*;
    part def AutonomousFloorCleaningRobotSpecification :> CleaningRobot, ComponentProfiles::PhysicalComponent::PhysicalComponentSpecification, Elan8::SystemsEngineering::SystemSpecification {
        attribute harnessMass : MassValue;
        satisfy HarnessRequirements::harnessSpecification;
        satisfy Requirements::robotSystemSpecification;
    }
    package Limits {
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
    package Requirements {
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
          subject robot : RobotPlatformSystem::AutonomousFloorCleaningRobotSpecification;

        requirement <'SYS-001'> 'Cleaning area per charge' {
          require constraint { robot.cleanedAreaPerCharge >= cleaningAreaTarget }
          doc /* The robot shall clean at least 80 m² of floor on one battery charge in the reference home. */
          // The area is typed in the text: Spec42 does not evaluate a unit expression such as [m^2] yet.
        }

        requirement <'SYS-002'> 'Floor coverage' {
          require constraint {
            robot.reachableFloorCoveragePercent >= floorCoverageTargetPercent
          }
          doc /* The robot shall cover at least {{= RequirementLimits::floorCoverageTargetPercent}} percent of the reachable floor area in one mission. */
        }

        requirement <'SYS-003'> 'Obstacle avoidance' {
          require constraint {
            robot.avoidedObstacleHeight >= minimumAvoidedObstacleHeight
          }
          doc /* The robot shall avoid collision with household obstacles that are at least {{= RequirementLimits::minimumAvoidedObstacleHeight}} high. */
        }

        requirement <'SYS-SAFE-010'> 'Cliff detection' {
          require constraint {
            robot.cliffHeightDetectedBeforeWheelCrossing >= minimumCliffHeight
          }
          doc /* The robot shall detect a drop of at least {{= RequirementLimits::minimumCliffHeight}} before a wheel crosses its edge. */
        }

        requirement <'SYS-SAFE-011'> 'Safe stop on hazard' {
          require constraint { robot.safeStopOnHazard == true }
          doc /* The robot shall command a safe stop within {{= RequirementLimits::maxSafeStopReactionTime}} of a cliff, lift, collision, over-current or over-temperature hazard. */
        }

        requirement <'SYS-004'> 'Localization accuracy' {
          require constraint { robot.localizationError <= maxLocalizationError }
          doc /* The robot shall keep its localization error below {{= RequirementLimits::maxLocalizationError}} throughout the reference mission. */
        }

        requirement <'SYS-005'> 'Coverage map maintenance' {
          require constraint { robot.coverageMapMaintained == true }
          doc /* The robot shall maintain a map of cleaned, unreachable and unknown floor cells throughout a mission. */
        }

        requirement <'SYS-006'> 'Wheel stall detection and recovery' {
          require constraint {
            robot.wheelStallDetectionTime <= maxWheelStallDetectionTime
          }
          doc /* The robot shall detect a stalled drive wheel within {{= RequirementLimits::maxWheelStallDetectionTime}} and enter a bounded recovery. */
        }

        requirement <'SYS-007'> 'Return to dock on low battery' {
          require constraint {
            robot.lowBatteryReturnThresholdPercent <=
              lowBatteryReturnThresholdPercent
          }
          doc /* The robot shall return to its dock when the state of charge falls below {{= RequirementLimits::lowBatteryReturnThresholdPercent}} percent. */
        }

        requirement <'SYS-008'> 'Charging within the battery safe operating area' {
          require constraint {
            robot.chargeCurrentWithinSafeOperatingArea == true and
            robot.chargeTemperatureWithinSafeOperatingArea == true
          }
          doc /* The robot shall keep charge current and cell temperature inside the safe operating area of the battery. */
        }

        requirement <'SYS-009'> 'Mission status reporting' {
          require constraint { robot.cleaningStatusReported == true }
          doc /* The robot shall report mission progress and faults to the local application during a mission. */
        }

        requirement <'SYS-010'> 'Local storage of map data' {
          require constraint { robot.mapDataLocalUnlessConsented == true }
          doc /* The robot shall keep raw home-map data on the robot and the local network unless the user has explicitly consented to transfer. */
        }

        requirement <'SYS-011'> 'Overall height' {
          require constraint { robot.overallHeight <= maxOverallHeight }
          doc /* The robot shall be no higher than {{= RequirementLimits::maxOverallHeight}}, including the laser scanner turret. */
        }

        requirement <'SYS-012'> 'Acoustic noise' {
          require constraint { robot.soundPressureLevel <= maxSoundPressureLevel }
          doc /* The robot shall emit a sound pressure level of at most {{= RequirementLimits::maxSoundPressureLevel}}(A) at 1 m while cleaning a hard floor at the default suction setting. */
        }

        requirement <'SYS-013'> 'Dust bin capacity' {
          require constraint { robot.dustBinCapacity >= minDustBinCapacity }
          doc /* The robot shall hold at least {{= RequirementLimits::minDustBinCapacity}} of debris in a dust bin that is removed and emptied without tools. */
        }

        requirement <'SYS-014'> 'Threshold climbing' {
          require constraint { robot.climbableThreshold >= minClimbableThreshold }
          doc /* The robot shall cross a rigid threshold at least {{= RequirementLimits::minClimbableThreshold}} high in both directions. */
        }

        requirement <'SYS-015'> 'Robot mass' {
          require constraint { robot.robotMass <= maxRobotMass }
          doc /* The robot shall have a mass of at most {{= RequirementLimits::maxRobotMass}} with an empty dust bin. */
        }

        requirement <'SYS-016'> 'Recharge time' {
          require constraint { robot.rechargeTime <= maxRechargeTime }
          doc /* The robot shall recharge from the low-battery return threshold to full charge within {{= RequirementLimits::maxRechargeTime}} on its dock. */
        }

        requirement <'SYS-017'> 'Operating modes' {
          require constraint { robot.operatingModeReported == true }
          doc /* The robot shall at any time be in exactly one of the operating modes idle, cleaning, paused, returning to the dock, charging, safe stop and fault, and shall report a change of mode to the local application. */
        }

        requirement <'SYS-SAFE-013'> 'Safe stop held until cleared' {
          require constraint { robot.safeStopHeldUntilCleared == true }
          doc /* The robot shall remain stationary in safe stop, with drive and cleaning motors off, until the hazard is no longer present and the user has confirmed that the robot may continue. */
        }

        requirement <'SYS-SAFE-012'> 'Battery protection independent of firmware' {
          require constraint { robot.batteryProtectionIndependentOfFirmware == true }
          doc /* The robot shall disconnect the battery on over-current, over-voltage, under-voltage and over-temperature by hardware that works without the application firmware. */
        }
        }
    }
    package HarnessRequirements {
        private import ModuleBudgets::*;
        private import RequirementLimits::*;
        private import ISQ::*;
        private import SI::*;
        requirement harnessSpecification {
            subject robot : RobotPlatformSystem::AutonomousFloorCleaningRobotSpecification;

            requirement <'HAR-001'> 'Wiring harness mass' {
              require constraint { robot.harnessMass <= harnessMassBudget }
              doc /* The base and top wiring harnesses together shall have a mass of at most {{= ModuleBudgets::harnessMassBudget}}. */
            }
          }
    }
    package Traceability {
        private import RequirementDerivation::*;
        private import ModelingMetadata::*;
        private import StakeholderNeeds::*;
        private import SystemRequirements::*;

        connection wholeHomeCleaningCoverage : Derivation {
          @Rationale { text = "Cleaning the whole home in one run needs enough energy for the area and a path that actually reaches the floor. Area per charge bounds the first, coverage of the reachable floor the second."; }
          end :>> Derivation::originalRequirement ::> 'Whole-home cleaning in one run';
          end #derive derived1 ::> robotSystemSpecification.'Cleaning area per charge';
          end #derive derived2 ::> robotSystemSpecification.'Floor coverage';
        }

        connection safeOperationCoverage : Derivation {
          @Rationale { text = "The household hazards are falling, collision, entanglement and the battery. Each has a detection requirement, and all of them lead to one supervised safe stop, which holds until the hazard is gone and the user has confirmed. The battery additionally has protection that does not depend on firmware, because a firmware fault must not become a fire risk."; }
          end :>> Derivation::originalRequirement ::> 'Safe operation in the household';
          end #derive derived1 ::> robotSystemSpecification.'Obstacle avoidance';
          end #derive derived2 ::> robotSystemSpecification.'Cliff detection';
          end #derive derived3 ::> robotSystemSpecification.'Safe stop on hazard';
          end #derive derived4 ::> robotSystemSpecification.'Wheel stall detection and recovery';
          end #derive derived5 ::> robotSystemSpecification.'Battery protection independent of firmware';
          end #derive derived6 ::> robotSystemSpecification.'Safe stop held until cleared';
        }

        connection dockingCoverage : Derivation {
          @Rationale { text = "Being ready the next day without help needs the robot to leave for the dock early enough, to charge safely once there, and to finish charging overnight."; }
          end :>> Derivation::originalRequirement ::> 'Unattended docking and charging';
          end #derive derived1 ::> robotSystemSpecification.'Return to dock on low battery';
          end #derive derived2 ::> robotSystemSpecification.'Charging within the battery safe operating area';
          end #derive derived3 ::> robotSystemSpecification.'Recharge time';
        }

        connection navigationCoverage : Derivation {
          @Rationale { text = "Knowing where it is becomes a bound on localization error. Knowing where it has cleaned becomes a maintained coverage map."; }
          end :>> Derivation::originalRequirement ::> 'Reliable navigation at home';
          end #derive derived1 ::> robotSystemSpecification.'Localization accuracy';
          end #derive derived2 ::> robotSystemSpecification.'Coverage map maintenance';
        }

        connection feedbackCoverage : Derivation {
          @Rationale { text = "Progress and faults are carried by the mission status the robot reports to the application. The household also needs to know what the robot is doing at any moment, which is its operating mode."; }
          end :>> Derivation::originalRequirement ::> 'Mission progress and fault feedback';
          end #derive derived1 ::> robotSystemSpecification.'Mission status reporting';
          end #derive derived2 ::> robotSystemSpecification.'Operating modes';
        }

        connection privacyCoverage : Derivation {
          @Rationale { text = "The map is the only personal data the robot creates. Keeping it local by default, with transfer only after explicit consent, is the whole need."; }
          end :>> Derivation::originalRequirement ::> 'Privacy of the home map';
          end #derive derived1 ::> robotSystemSpecification.'Local storage of map data';
        }

        connection underFurnitureCoverage : Derivation {
          @Rationale { text = "Fitting under furniture with about 10 cm of clearance is one dimension, the overall height including the LiDAR turret, with margin for carpet pile."; }
          end :>> Derivation::originalRequirement ::> 'Cleaning under furniture';
          end #derive derived1 ::> robotSystemSpecification.'Overall height';
        }

        connection quietOperationCoverage : Derivation {
          @Rationale { text = "A conversation in the same room is possible below about 65 dB(A), so the need becomes one sound pressure limit with a stated distance, floor and mode."; }
          end :>> Derivation::originalRequirement ::> 'Quiet operation';
          end #derive derived1 ::> robotSystemSpecification.'Acoustic noise';
        }

        connection maintenanceCoverage : Derivation {
          @Rationale { text = "Emptying at most once per run needs a bin that holds the debris of one run of the reference home; doing it without tools is part of the same requirement."; }
          end :>> Derivation::originalRequirement ::> 'Easy routine maintenance';
          end #derive derived1 ::> robotSystemSpecification.'Dust bin capacity';
        }

        connection thresholdCoverage : Derivation {
          @Rationale { text = "Door thresholds and rug edges in the target homes are up to 20 mm high; crossing them in both directions is one capability."; }
          end :>> Derivation::originalRequirement ::> 'Thresholds between rooms';
          end #derive derived1 ::> robotSystemSpecification.'Threshold climbing';
        }

        connection carryingCoverage : Derivation {
          @Rationale { text = "Carrying in one hand is bounded by mass. The grip is a detail of the enclosure design under that limit."; }
          end :>> Derivation::originalRequirement ::> 'Carrying between floors';
          end #derive derived1 ::> robotSystemSpecification.'Robot mass';
        }
    }

    part def AutonomousFloorCleaningRobotArchitecture :> AutonomousFloorCleaningRobotSpecification, ComponentProfiles::PhysicalComponent::PhysicalComponentArchitecture, Elan8::SystemsEngineering::SystemArchitecture {
        part base : BaseSystem::BaseModuleSpecification;
        part mainPcb : MainControlBoardSystem::MainPcbModuleSpecification;
        part top : TopSystem::TopModuleSpecification;
        part dustBin : DustBinSystem::DustBinSpecification;
        part baseHarness : BaseHarnessSystem::BaseWiringHarnessSpecification;
        part topHarness : TopHarnessSystem::TopWiringHarnessSpecification;
        ref part firmwareTasks : FirmwareSystem::FirmwareTaskArchitectureSpecification;
    }
    package Budgets {
        private import Elan8::Units::Engineering::*;
        private import RequirementLimits::*;
        private import ISQ::*;
        private import SI::*;

        // Safe stop: 100 ms from hazard to standstill command, of which 10 ms is unallocated margin.
        attribute cliffSensingBudget : DurationValue = 25 [ms];
        attribute supervisorDecisionBudget : DurationValue = 10 [ms];
        attribute driveDisableBudget : DurationValue = 5 [ms];
        attribute brakingBudget : DurationValue = 50 [ms];
        attribute allocatedSafeStopTime : DurationValue =
          cliffSensingBudget + supervisorDecisionBudget + driveDisableBudget + brakingBudget;

        // Mass: 4.0 kg, fully allocated; the margin is held inside each module budget.
        attribute baseMassBudget : MassValue = 2.75 [kg];
        attribute topMassBudget : MassValue = 0.60 [kg];
        attribute mainPcbMassBudget : MassValue = 0.25 [kg];
        attribute dustBinMassBudget : MassValue = 0.22 [kg];
        attribute harnessMassBudget : MassValue = 0.18 [kg];
        attribute allocatedMass : MassValue =
          baseMassBudget + topMassBudget + mainPcbMassBudget + dustBinMassBudget + harnessMassBudget;

        // Height: 95 mm overall, split at the parting line between base and top.
        attribute baseHeightBudget : LengthValue = 57 [mm];
        attribute topHeightBudget : LengthValue = 38 [mm];
        attribute allocatedHeight : LengthValue = baseHeightBudget + topHeightBudget;

        // Energy and charging.
        attribute minBatteryCapacity : ElectricChargeValue = batteryCapacityBudget;
        attribute minChargeCurrent : ElectricCurrentValue = 2 [A];

        assert constraint safeStopBudgetCloses { allocatedSafeStopTime <= maxSafeStopReactionTime }
        assert constraint massBudgetCloses { allocatedMass <= maxRobotMass }
        assert constraint heightBudgetCloses { allocatedHeight <= maxOverallHeight }
    }
    package RequirementAllocation {
        private import RequirementDerivation::*;
        private import ModelingMetadata::*;
        private import SystemRequirements::*;
        private import ModuleRequirements::*;

        connection safeStopAllocation : Derivation {
          @Rationale { text = "The 100 ms from hazard to standstill is a chain of four steps in three modules: sensing 25 ms, supervisor decision 10 ms, drive disable 5 ms and braking 50 ms. The budgets add up to 90 ms, which leaves 10 ms unallocated margin."; }
          end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Safe stop on hazard';
          end #derive derived1 ::> baseModuleSpecification.'Cliff sensing latency';
          end #derive derived2 ::> firmwareSpecification.'Safety supervisor deadline';
          end #derive derived3 ::> mainPcbSpecification.'Drive disable latency';
          end #derive derived4 ::> baseModuleSpecification.'Drive braking time';
        }

        connection massAllocation : Derivation {
          @Rationale { text = "Every gram of the robot belongs to one of five budgets, and the budgets add up to the 4.0 kg limit. Margin is held inside each module budget, so a module that grows has to renegotiate with the others rather than use up a common reserve unnoticed."; }
          end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Robot mass';
          end #derive derived1 ::> baseModuleSpecification.'Base module mass';
          end #derive derived2 ::> topModuleSpecification.'Top module mass';
          end #derive derived3 ::> mainPcbSpecification.'Main board mass';
          end #derive derived4 ::> dustBinSpecification.'Dust bin mass';
          end #derive derived5 ::> harnessSpecification.'Wiring harness mass';
        }

        connection heightAllocation : Derivation {
          @Rationale { text = "The overall height is the base module up to the parting line plus the top module above it. The split at 57 mm follows the drive wheel diameter and the battery pack; the remaining 38 mm is for the shell and the scanner turret."; }
          end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Overall height';
          end #derive derived1 ::> baseModuleSpecification.'Base module height';
          end #derive derived2 ::> topModuleSpecification.'Top module height';
        }

        connection energyAllocation : Derivation {
          @Rationale { text = "The mission energy analysis shows that 80 m² at an average of 2.6 A takes 4875 mAh. With a 15 % reserve for the return to the dock this needs a 6400 mAh pack."; }
          end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Cleaning area per charge';
          end #derive derived1 ::> baseModuleSpecification.'Battery capacity';
        }

        connection rechargeAllocation : Derivation {
          @Rationale { text = "Recharging 85 % of 6400 mAh within 4 hours, including the constant-voltage tail, needs at least 2 A in the constant-current phase."; }
          end :>> Derivation::originalRequirement ::> robotSystemSpecification.'Recharge time';
          end #derive derived1 ::> baseModuleSpecification.'Charge current';
        }
    }

    part def AutonomousFloorCleaningRobotIntegration :> AutonomousFloorCleaningRobotArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part base : BaseSystem::BaseModuleIntegration :>> base;
        part mainPcb : MainControlBoardSystem::MainPcbModuleIntegration :>> mainPcb;
        part top : TopSystem::TopModuleIntegration :>> top;
        part dustBin : DustBinSystem::DustBinIntegration :>> dustBin;
        part baseHarness : BaseHarnessSystem::BaseWiringHarnessIntegration :>> baseHarness;
        part topHarness : TopHarnessSystem::TopWiringHarnessIntegration :>> topHarness;
        ref part firmwareTasks : FirmwareSystem::FirmwareTaskArchitectureIntegration :>> firmwareTasks;
        attribute :>> cleanedAreaPerCharge = 80 [m^2];
        attribute :>> reachableFloorCoveragePercent = 90;
        attribute :>> avoidedObstacleHeight = 30 [mm];
        attribute :>> cliffHeightDetectedBeforeWheelCrossing = 50 [mm];
        attribute :>> safeStopOnHazard = true;
        attribute :>> localizationError = 120 [mm];
        attribute :>> coverageMapMaintained = true;
        attribute :>> wheelStallDetectionTime = 1500 [ms];
        attribute :>> lowBatteryReturnThresholdPercent = 15.0;
        attribute :>> chargeCurrentWithinSafeOperatingArea = true;
        attribute :>> chargeTemperatureWithinSafeOperatingArea = true;
        attribute :>> cleaningStatusReported = true;
        attribute :>> mapDataLocalUnlessConsented = true;
        attribute :>> overallHeight = 92 [mm];
        attribute :>> soundPressureLevel = 62 [dB];
        attribute :>> dustBinCapacity = 450 [mL];
        attribute :>> climbableThreshold = 20 [mm];
        attribute :>> robotMass =
              sum(base.mass, mainPcb.mass, top.mass, dustBin.mass, baseHarness.mass, topHarness.mass);
        attribute :>> rechargeTime = 3.5 [h];
        attribute :>> batteryProtectionIndependentOfFirmware = true;
        attribute :>> operatingModeReported = true;
        attribute :>> safeStopHeldUntilCleared = true;
        connect mainPcb.batteryPower to baseHarness.pcbBatteryPower;
        connect baseHarness.baseBatteryRail to base.batteryRail;
        connect mainPcb.logicPower to baseHarness.pcbLogicPower;
        connect baseHarness.baseLogicRail to base.logicRail;
        connect mainPcb.leftPhases to baseHarness.pcbLeftPhases;
        connect baseHarness.baseLeftPhases to base.leftPhases;
        connect mainPcb.rightPhases to baseHarness.pcbRightPhases;
        connect baseHarness.baseRightPhases to base.rightPhases;
        connect mainPcb.leftOdometry to baseHarness.pcbLeftOdometry;
        connect baseHarness.baseLeftOdometry to base.leftOdometry;
        connect mainPcb.rightOdometry to baseHarness.pcbRightOdometry;
        connect baseHarness.baseRightOdometry to base.rightOdometry;
        connect mainPcb.brushCommand to baseHarness.pcbBrushCommand;
        connect baseHarness.baseBrushCommand to base.brushCommand;
        connect mainPcb.vacuumCommand to baseHarness.pcbVacuumCommand;
        connect baseHarness.baseVacuumCommand to base.vacuumCommand;
        connect mainPcb.bmsBus to baseHarness.pcbBmsBus;
        connect baseHarness.baseBmsBus to base.bmsBus;
        connect mainPcb.leftLiftHazard to baseHarness.pcbLeftLiftHazard;
        connect baseHarness.baseLeftLiftHazard to base.leftLiftHazard;
        connect mainPcb.rightLiftHazard to baseHarness.pcbRightLiftHazard;
        connect baseHarness.baseRightLiftHazard to base.rightLiftHazard;
        connect mainPcb.frontLeftCliffHazard to baseHarness.pcbFrontLeftCliffHazard;
        connect baseHarness.baseFrontLeftCliffHazard to base.frontLeftCliffHazard;
        connect mainPcb.frontRightCliffHazard to baseHarness.pcbFrontRightCliffHazard;
        connect baseHarness.baseFrontRightCliffHazard to base.frontRightCliffHazard;
        connect mainPcb.rearLeftCliffHazard to baseHarness.pcbRearLeftCliffHazard;
        connect baseHarness.baseRearLeftCliffHazard to base.rearLeftCliffHazard;
        connect mainPcb.rearRightCliffHazard to baseHarness.pcbRearRightCliffHazard;
        connect baseHarness.baseRearRightCliffHazard to base.rearRightCliffHazard;
        connect mainPcb.cleaningFault to baseHarness.pcbCleaningFault;
        connect baseHarness.baseCleaningFault to base.cleaningFault;
        connect mainPcb.bmsAlert to baseHarness.pcbBmsAlert;
        connect baseHarness.baseBmsAlert to base.bmsAlert;
        connect mainPcb.dockBeaconDetected to baseHarness.pcbDockBeaconDetected;
        connect baseHarness.baseDockBeaconDetected to base.dockBeaconDetected;
        connect mainPcb.sensorBus to topHarness.pcbSensorBus;
        connect topHarness.topSensorBus to top.sensorBus;
        connect mainPcb.lidarSerial to topHarness.pcbLidarSerial;
        connect topHarness.topLidarSerial to top.lidarSerial;
        connect base.sensorRail to topHarness.baseSensorPower;
        connect topHarness.topSensorPower to top.power;
        connect mainPcb.topBumperHazard to topHarness.pcbBumperHazard;
        connect topHarness.topBumperHazard to top.bumperHazard;
        connect mainPcb.localHmi to topHarness.pcbHmiControl;
        connect topHarness.topHmiControl to top.hmiControl;
        connect dockPower to base.dockPowerInput;
        connect dockBeacon to base.beaconInput;
        connect app to mainPcb.appService;
        connect base.cleaningHead.debrisOut to dustBin.debrisIn;
        connection mainPcbMount : FastenedMount
              connect base to mainPcb;
        connection topMount : SnapFitMount
              connect base to top;
        connection dustBinMount : RemovableMount
              connect base to dustBin;
        allocate firmwareTasks.scheduler to mainPcb.mcu;
        allocate firmwareTasks.missionController
              to firmwareTasks.scheduler;
        allocate firmwareTasks.safetySupervisor
              to firmwareTasks.scheduler;
        allocate firmwareTasks.actuatorControl
              to firmwareTasks.scheduler;
        allocate firmwareTasks.sensorAcquisition
              to firmwareTasks.scheduler;
        allocate firmwareTasks.navigation
              to firmwareTasks.scheduler;
        allocate firmwareTasks.powerManager
              to firmwareTasks.scheduler;
        allocate firmwareTasks.appService
              to firmwareTasks.scheduler;
        allocation sensorBusAccess : TaskToPeripheralAccess
              allocate firmwareTasks.sensorAcquisition
              to mainPcb.mcu.sensorI2c;
        allocation lidarAccess : TaskToPeripheralAccess
              allocate firmwareTasks.sensorAcquisition
              to mainPcb.mcu.lidarUart;
        allocation actuatorPwmAccess : TaskToPeripheralAccess
              allocate firmwareTasks.actuatorControl
              to mainPcb.mcu.leftMotorPwm;
        allocation safetyInputAccess : TaskToPeripheralAccess
              allocate firmwareTasks.safetySupervisor
              to mainPcb.mcu.frontLeftCliffHazard;
        allocation powerBusAccess : TaskToPeripheralAccess
              allocate firmwareTasks.powerManager
              to mainPcb.mcu.bmsSmbus;
        allocation appWirelessAccess : TaskToPeripheralAccess
              allocate firmwareTasks.appService
              to mainPcb.wirelessUart;
        attribute :>> harnessMass = baseHarness.mass + topHarness.mass;
    }

    package Analysis {
        private import RequirementLimits::*;
        private import Elan8::Units::Engineering::*;
        private import ISQ::*;
        private import SI::*;
        private import NumericalFunctions::*; // sum(...) in measuredReactionTime / baseElectronicsPowerDraw

        analysis def MissionEnergyAnalysis {
          subject robot : AutonomousFloorCleaningRobot;
          attribute chargeBudget : ElectricChargeValue =
            RequirementLimits::batteryCapacityBudget;
          attribute averageMissionCurrent : ElectricCurrentValue = 2.6 [A];
          attribute missionDuration : DurationValue = 1.875 [h];
          attribute missionChargeDraw : ElectricChargeValue =
            averageMissionCurrent * missionDuration;
          attribute reserveCharge : ElectricChargeValue = chargeBudget * 0.15;
          attribute usableMissionBudget : ElectricChargeValue =
            chargeBudget - reserveCharge;
          return ref energyWithinBudget {
            return missionChargeDraw <= usableMissionBudget;
          }
          objective estimateMissionEnergy {
            doc /* Demonstrate quantity-based mission energy analysis with reserve. */
          }
        }

        analysis def SafetyReactionAnalysis {
          subject robot : AutonomousFloorCleaningRobot;
          attribute sensorDetectionLatency : DurationValue = robot.base.cliffSensingLatency;
          attribute supervisorDecisionLatency : DurationValue = robot.firmwareTasks.safetySupervisor.deadline;
          attribute driveDisableLatency : DurationValue = robot.mainPcb.driveDisableLatency;
          attribute brakingTime : DurationValue = robot.base.brakingTime;
          attribute measuredReactionTime : DurationValue = sum(
            sensorDetectionLatency,
            supervisorDecisionLatency,
            driveDisableLatency,
            brakingTime
          );
          attribute reactionTimeLimit : DurationValue =
            RequirementLimits::maxSafeStopReactionTime;
          return ref reactsWithinLimit {
            return measuredReactionTime <= reactionTimeLimit;
          }
          objective estimateSafeStopTiming {
            doc /* Add the design values of the four steps from hazard to standstill and compare the sum with the limit. */
          }
        }

        analysis def LocalizationPerformanceAnalysis {
          subject robot : AutonomousFloorCleaningRobot;
          attribute estimatedLocalizationError : LengthValue = 95 [mm];
          attribute localizationErrorLimit : LengthValue =
            RequirementLimits::maxLocalizationError;
          return ref localizationWithinLimit {
            return estimatedLocalizationError <= localizationErrorLimit;
          }
          objective estimateLocalization {
            doc /* Confirm the selected ToF, LiDAR, IMU, and odometry baseline. */
          }
        }

        analysis def MassBudgetAnalysis {
          subject robot : AutonomousFloorCleaningRobot;
          attribute baseMass : MassValue = robot.base.mass;
          attribute mainPcbMass : MassValue = robot.mainPcb.mass;
          attribute topMass : MassValue = robot.top.mass;
          attribute dustBinMass : MassValue = robot.dustBin.mass;
          attribute harnessMass : MassValue = robot.baseHarness.mass + robot.topHarness.mass;
          attribute totalMass : MassValue =
            sum(baseMass, mainPcbMass, topMass, dustBinMass, harnessMass);
          attribute massLimit : MassValue = maxRobotMass;
          return ref massWithinLimit {
            return totalMass <= massLimit;
          }
          objective massObjective {
            doc /* Roll up the module masses and compare the total with the mass limit. */
          }
        }
    }
    package Verification {
        private import VerificationCases::*;
        private import RobotAnalysisCases::*;
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
    package Views {
        view productDecomposition : GeneralView {
            doc /* What are the top-level constituents of this robot baseline? Show the physical robot, its
             * six hardware modules and its referenced firmware task group. Module internals are explored
             * in the module views; type names identify reusable definitions without displaying a second
             * definition tree. */
            satisfy productStructurePerspective;
            filter @SysML::PartUsage;
            filter not @SysML::ConnectionUsage;
            filter not @SysML::AllocationUsage;
            expose VacuumCleanerSystem::robotSystem.physical;
          }
        view interconnections : InterconnectionView {
            doc /* How do the six hardware modules connect at their boundaries? Show the base, main PCB, two
             * harnesses, top and dust bin. Start with module internals closed to follow inter-module
             * power, signals and debris transfer; expand a module only to trace an endpoint inside it.
             * Firmware deployment is shown separately. */
            satisfy productConnectionsPerspective;
            expose VacuumCleanerSystem::robotSystem.physical.base;
            expose VacuumCleanerSystem::robotSystem.physical.mainPcb;
            expose VacuumCleanerSystem::robotSystem.physical.baseHarness;
            expose VacuumCleanerSystem::robotSystem.physical.topHarness;
            expose VacuumCleanerSystem::robotSystem.physical.top;
            expose VacuumCleanerSystem::robotSystem.physical.dustBin;
          }
        view systemRequirements : GeneralView {
            doc /* Which 21 system requirements constrain the robot baseline? Show the requirement collection
             * and its individual requirements. Satisfaction, derivation and verification evidence are
             * provided by the document trace tables, not inferred from this inventory. */
            satisfy requirementStructurePerspective;
            filter @SysML::RequirementUsage;
            expose SystemRequirements::robotSystemSpecification;
          }
    }
}
