/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Project metadata and Elan8 Method tailoring for the vacuum showcase.
 */
package Project {
  private import Elan8Method::*;

  part projectInfo : ProjectTailoring {
    attribute :>> projectName = "AutonomousFloorCleaningRobot";
    attribute :>> profile = small;
    attribute :>> notes = "Lean showcase; Elan8 Method compliant folder layout with cliff-safe-stop vertical increment.";
  }

  doc /*
    Library imports (via Spec42):
    - mbse-methodology/library (Elan8Method, Elan8Requirement*)
    - sysml-domain-libraries domain/technical/generic
  */
}
