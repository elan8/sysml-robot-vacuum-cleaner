/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Project metadata and Elan8 Method tailoring for the vacuum showcase.
 */
package Project {
  private import Elan8::Method::Core::*;

  part projectInfo : ProjectInfo {
    attribute :>> projectName = "AutonomousFloorCleaningRobot";
    attribute :>> profile = small;
    attribute :>> notes = "Lean showcase using the Elan8 Method folder layout and domain-oriented SysML names.";
  }

  doc /*
    Library imports (via Spec42):
    - mbse-methodology/library (Elan8::Method::*)
    - sysml-domain-libraries domain/technical/generic
  */
}
