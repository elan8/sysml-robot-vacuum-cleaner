/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns generic allocation definition types reusable across the model.
 * The system-of-interest definition (CleaningRobotSystemOfInterest) and all
 * allocation links have moved to Architecture.sysml so they sit alongside
 * the architecture hub that gives them context.
 */
package ArchitectureAllocations {
  private import SoftwareCore::*;
  private import EmbeddedComputeDomain::*;

  allocation def SoftwareToComputeNode {
    end software : ExecutableComponent;
    end computeNode : EmbeddedComputeUnit;
  }
}
