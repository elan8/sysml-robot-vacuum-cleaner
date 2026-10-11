/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Project metadata and Elan8 Method tailoring for the vacuum showcase.
 */
package Project {
  private import MethodCore::*;

  part projectInfo : ProjectInfo {
    attribute :>> projectName = "AutonomousFloorCleaningRobot";
    attribute :>> notes = "Lean showcase using the Elan8 Method folder layout and domain-oriented SysML names.";
  }

  doc /*
    Library imports (via Spec42):
    - mbse-methodology/library (Elan8Method)
    - sysml-domain-libraries domain/technical/generic
  */
}
