/* SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT */
package PhysicalShared {
    private import ISQ::*;
    private import FirmwareLibrary::*;
    attribute def PowerRailBudget {
        attribute nominalVoltage : ElectricPotentialValue;
        attribute continuousCurrentBudget : ElectricCurrentValue;
        attribute peakCurrentBudget : ElectricCurrentValue;
      }
    allocation def TaskToPeripheralAccess {
        end task : FirmwareTask;
        end peripheral;
      }
}
