/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package VacuumCleanerSystem {
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
    package Behavior {
        public import FunctionalArchitecture::*;
        public import BehaviorStates::*;
    }
    part def CleaningRobotSystemOfInterestSpecification :> Elan8::SystemsEngineering::SystemSpecification {

    }

    part def CleaningRobotSystemOfInterestArchitecture :> CleaningRobotSystemOfInterestSpecification, Elan8::SystemsEngineering::SystemArchitecture {
        part physical : RobotPlatformSystem::AutonomousFloorCleaningRobotSpecification;
    }

    part def CleaningRobotSystemOfInterestIntegration :> CleaningRobotSystemOfInterestArchitecture, Elan8::SystemsEngineering::SystemIntegration {
        part physical : RobotPlatformSystem::AutonomousFloorCleaningRobotIntegration :>> physical;
        perform action operate : OperateCleaningRobot;
        exhibit state operatingBehavior : RobotOperatingBehavior;
        allocate operate.locomotion to physical.base;
        allocate operate.locomotion to physical.firmwareTasks.actuatorControl;
        allocate operate.cleaning to physical.base.cleaningHead;
        allocate operate.cleaning to physical.firmwareTasks.actuatorControl;
        allocate operate.perception to physical.base;
        allocate operate.perception to physical.top;
        allocate operate.perception to physical.firmwareTasks.sensorAcquisition;
        allocate operate.navigation to physical.firmwareTasks.navigation;
        allocate operate.powerManagement to physical.base.powerModule;
        allocate operate.powerManagement to physical.firmwareTasks.powerManager;
        allocate operate.docking to physical.base.dockInterface;
        allocate operate.missionControl to physical.firmwareTasks.missionController;
        allocate operate.safetySupervision
              to physical.firmwareTasks.safetySupervisor;
        allocate operate.userInteraction to physical.top.hmi;
        allocate operate.userInteraction to physical.firmwareTasks.appService;
    }
    part robotSystem : CleaningRobotSystemOfInterestIntegration;
    satisfy robotSystemSpecification.'Cleaning area per charge'
        by robotSystem.operate.cleaning;
    satisfy robotSystemSpecification.'Floor coverage'
        by robotSystem.operate.navigation;
    satisfy robotSystemSpecification.'Obstacle avoidance'
        by robotSystem.operate.perception;
    satisfy robotSystemSpecification.'Cliff detection'
        by robotSystem.operate.perception;
    satisfy robotSystemSpecification.'Safe stop on hazard'
        by robotSystem.operate.safetySupervision;
    satisfy robotSystemSpecification.'Localization accuracy'
        by robotSystem.operate.navigation;
    satisfy robotSystemSpecification.'Coverage map maintenance'
        by robotSystem.operate.navigation;
    satisfy robotSystemSpecification.'Wheel stall detection and recovery'
        by robotSystem.operate.missionControl;
    satisfy robotSystemSpecification.'Return to dock on low battery'
        by robotSystem.operate.docking;
    satisfy robotSystemSpecification.'Charging within the battery safe operating area'
        by robotSystem.operate.powerManagement;
    satisfy robotSystemSpecification.'Mission status reporting'
        by robotSystem.operate.userInteraction;
    satisfy robotSystemSpecification.'Local storage of map data'
        by robotSystem.operate.userInteraction;
    satisfy robotSystemSpecification.'Operating modes'
        by robotSystem.operate.missionControl;
    satisfy robotSystemSpecification.'Safe stop held until cleared'
        by robotSystem.operate.safetySupervision;
    // Physical properties are claimed by the element that determines them.
      satisfy robotSystemSpecification.'Overall height'
        by robotSystem.physical.top;
    satisfy robotSystemSpecification.'Acoustic noise'
        by robotSystem.physical.base.cleaningHead;
    satisfy robotSystemSpecification.'Dust bin capacity'
        by robotSystem.physical.dustBin;
    satisfy robotSystemSpecification.'Threshold climbing'
        by robotSystem.operate.locomotion;
    satisfy robotSystemSpecification.'Robot mass'
        by robotSystem.physical;
    satisfy robotSystemSpecification.'Recharge time'
        by robotSystem.operate.powerManagement;
    satisfy robotSystemSpecification.'Battery protection independent of firmware'
        by robotSystem.physical.base.powerModule.bms;
    // Module requirements are claimed by the module they are allocated to.
      satisfy baseModuleSpecification.'Cliff sensing latency'
        by robotSystem.physical.base;
    satisfy baseModuleSpecification.'Drive braking time'
        by robotSystem.physical.base;
    satisfy baseModuleSpecification.'Base module mass'
        by robotSystem.physical.base;
    satisfy baseModuleSpecification.'Base module height'
        by robotSystem.physical.base;
    satisfy baseModuleSpecification.'Battery capacity'
        by robotSystem.physical.base.powerModule;
    satisfy baseModuleSpecification.'Charge current'
        by robotSystem.physical.base.powerModule;
    satisfy mainPcbSpecification.'Drive disable latency'
        by robotSystem.physical.mainPcb;
    satisfy mainPcbSpecification.'Main board mass'
        by robotSystem.physical.mainPcb;
    satisfy firmwareSpecification.'Safety supervisor deadline'
        by robotSystem.physical.firmwareTasks.safetySupervisor;
    satisfy topModuleSpecification.'Top module height'
        by robotSystem.physical.top;
    satisfy topModuleSpecification.'Top module mass'
        by robotSystem.physical.top;
    satisfy dustBinSpecification.'Dust bin mass'
        by robotSystem.physical.dustBin;
    satisfy harnessSpecification.'Wiring harness mass'
        by robotSystem.physical;

    package Verification {
        package Validation {
            private import VerificationCases::*;
            private import PhysicalArchitecture::*;
            private import StakeholderNeeds::*;

            action def DemonstrateInHome;

            verification <'VAL-001'> 'Whole-home mission' {
              @VerificationMethod { kind = VerificationMethodKind::demo; }
              doc /* A household starts a mission from the application in each of three reference homes
                   * and lets the robot finish. Accepted when the whole reachable floor is cleaned in one
                   * run in every home, including under furniture and across thresholds, and the
                   * household could follow progress in the application. */
              subject robot : AutonomousFloorCleaningRobot;
              objective {
                verify 'Whole-home cleaning in one run';
                verify 'Reliable navigation at home';
                verify 'Mission progress and fault feedback';
                verify 'Cleaning under furniture';
                verify 'Thresholds between rooms';
              }
              then action runInHome : DemonstrateInHome;
            }

            verification <'VAL-002'> 'Two weeks unattended' {
              @VerificationMethod { kind = VerificationMethodKind::demo; }
              doc /* The robot runs a daily scheduled mission for two weeks in an occupied home without
                   * the development team present. Accepted when it was ready for every mission without
                   * help, and the household emptied the dust bin at most once per run and without tools. */
              subject robot : AutonomousFloorCleaningRobot;
              objective {
                verify 'Unattended docking and charging';
                verify 'Easy routine maintenance';
              }
              then action runInHome : DemonstrateInHome;
            }

            verification <'VAL-003'> 'Household safety walkthrough' {
              @VerificationMethod { kind = VerificationMethodKind::demo; }
              @VerificationMethod { kind = VerificationMethodKind::inspect; }
              doc /* The robot runs in a home with stairs, pets, cables and children's toys while an
                   * independent safety assessor observes, and the assessor reviews the hazard analysis.
                   * Accepted when no fall, harmful collision or entanglement occurs and the assessor has
                   * no open finding. */
              subject robot : AutonomousFloorCleaningRobot;
              objective {
                verify 'Safe operation in the household';
              }
              then action runInHome : DemonstrateInHome;
            }

            verification <'VAL-004'> 'Privacy review' {
              @VerificationMethod { kind = VerificationMethodKind::inspect; }
              doc /* A privacy reviewer inspects the data the robot and the application store and
                   * transmit during normal use. Accepted when the home map stays on the robot unless the
                   * household gave consent in the application. */
              subject robot : AutonomousFloorCleaningRobot;
              objective {
                verify 'Privacy of the home map';
              }
              then action runInHome : DemonstrateInHome;
            }

            verification <'VAL-005'> 'Living with the robot' {
              @VerificationMethod { kind = VerificationMethodKind::demo; }
              doc /* A panel of ten households uses the robot for a week and answers a structured
                   * questionnaire. Accepted when at least eight can hold a conversation in the room
                   * while it cleans and can carry it between floors in one hand. */
              subject robot : AutonomousFloorCleaningRobot;
              objective {
                verify 'Quiet operation';
                verify 'Carrying between floors';
              }
              then action runInHome : DemonstrateInHome;
            }
        }
    }
    package Views {
        view cliffSafeStopScenario : ActionFlowView {
            doc /* How does a cliff observation propagate to stopped actuation and reported safe-stop status?
             * Show the scenario actions, parameter flows and successions. This is the behavioral path;
             * timing budgets and requirement verification are provided separately. */
            satisfy safeStopScenarioPerspective;
            expose OperationalScenarios::CliffSafeStopScenario;
          }
        view specification : Elan8::SystemsEngineering::SpecificationView { expose VacuumCleanerSystem::CleaningRobotSystemOfInterestSpecification; }
        view architecture : Elan8::SystemsEngineering::ArchitectureView { expose VacuumCleanerSystem::CleaningRobotSystemOfInterestArchitecture; }
        view integration : Elan8::SystemsEngineering::IntegrationView { expose VacuumCleanerSystem::robotSystem; }
    }
}
