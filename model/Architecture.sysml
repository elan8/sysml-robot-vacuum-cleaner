/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns the public architecture hub and top-level robot part used by downstream
 * packages. Depends on functional/physical architecture and system
 * requirements. Keep detailed assemblies and allocations in their source
 * packages.
 */
package Architecture {
  public import ArchitectureCommon::*;
  public import PhysicalProtocols::*;
  public import FunctionalArchitecture::*;
  public import PhysicalArchitecture::*;
  public import ArchitectureAllocations::*;
  private import SystemRequirements::*;

  part robot : AutonomousFloorCleaningRobot;

  satisfy robot by limitBomCost;
  satisfy robot by limitTotalMass;
}
