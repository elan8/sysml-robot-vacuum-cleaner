/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Five validation cases for the customer requirements. Verification asks
 * whether the robot meets its system requirements; validation asks whether a
 * household gets what it needs from the robot. A validation case is a
 * verification case whose objective is a customer requirement and whose
 * evidence comes from use in a home. No case has been executed.
 */
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
