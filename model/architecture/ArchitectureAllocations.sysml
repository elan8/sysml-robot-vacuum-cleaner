/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns generic allocation definition types reusable across the model.
 * The system-of-interest definition (CleaningRobotSystemOfInterest) and all
 * allocation links have moved to Architecture.sysml so they sit alongside
 * the architecture hub that gives them context. Task-to-module and
 * software-to-MCU allocation defs are consumed by PhysicalArchitecture.
 */
package ArchitectureAllocations {
  private import SoftwareCore::*;
  private import EmbeddedComputeDomain::*;
  private import FirmwareArchitecture::*;

  allocation def TaskToSoftwareModule {
    end task : FirmwareTask;
    end softwareModule : ExecutableComponent;
  }

  allocation def SoftwareToComputeNode {
    end software : ExecutableComponent;
    end computeNode : EmbeddedComputeUnit;
  }

  allocation def TaskToPeripheralAccess {
    end task : FirmwareTask;
    end peripheral;
  }

  allocation def I2cMasterAccess :> TaskToPeripheralAccess;
  allocation def UartDmaAccess :> TaskToPeripheralAccess;
  allocation def PwmOutputAccess :> TaskToPeripheralAccess;
  allocation def GpioInputAccess :> TaskToPeripheralAccess;
  allocation def FlashStorageAccess :> TaskToPeripheralAccess;
  allocation def WirelessUartAccess :> TaskToPeripheralAccess;
}
