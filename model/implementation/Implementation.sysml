/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Engineer handoff view for electronics work packages. Interface contracts and
 * component candidates remain in their source packages.
 */
package Implementation {
  public import ElectronicsImplementation::*;
  private import Views::*;

  view electronicsWorkPackages : GeneralView {
    doc /* PCB and harness work packages for electronics engineers. */
    expose ElectronicsImplementation::electronicsHandoff;
  }
}
