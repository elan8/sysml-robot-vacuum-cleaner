/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Engineer-facing views over the canonical architecture graph. This package
 * owns no duplicate task, interface, rail, work-package, or component facts.
 */
package Implementation {
  private import Views::*;
  private import Architecture::*;
  private import PhysicalArchitecture::*;
  private import FirmwareArchitecture::*;
  private import ArchitectureAllocations::*;
  private import ElectronicsComponentSelection::*;

  part def ImplementationEngineer;
  part implementationEngineer : ImplementationEngineer;

  concern implementationHandoff {
    doc /* Which runtime, peripheral, electrical, and component facts implement the robot? */
    subject;
    stakeholder :>> implementationEngineer;
  }

  viewpoint implementationHandoffPerspective {
    frame implementationHandoff;
  }

  view softwareRuntimeHandoff : GeneralView {
    satisfy implementationHandoffPerspective;
    expose Architecture::robotSystem.physical.firmwareTasks;
    expose Architecture::robotSystem.physical.robotFirmware;
  }

  view peripheralAccessHandoff : GeneralView {
    satisfy implementationHandoffPerspective;
    expose Architecture::robotSystem.physical.firmwareTasks;
    expose Architecture::robotSystem.physical.mainElectronics.mainControlPcb;
    expose Architecture::robotSystem.physical.mainElectronics.safetyGpioHarness;
  }

  view electronicsInterfaceHandoff : InterconnectionView {
    satisfy implementationHandoffPerspective;
    expose Architecture::robotSystem.physical.powerModule;
    expose Architecture::robotSystem.physical.sensorAssembly;
    expose Architecture::robotSystem.physical.driveModule;
    expose Architecture::robotSystem.physical.mainElectronics;
  }

  view railBudgetHandoff : GeneralView {
    satisfy implementationHandoffPerspective;
    expose Architecture::robotSystem.physical.batteryRailBudget;
    expose Architecture::robotSystem.physical.logicRailBudget;
    expose Architecture::robotSystem.physical.sensorRailBudget;
  }

  view componentSelectionHandoff : GeneralView {
    satisfy implementationHandoffPerspective;
    expose ElectronicsComponentSelection::electronicsComponentSelectionBaseline;
    expose Architecture::robotSystem.physical.mainElectronics;
    expose Architecture::robotSystem.physical.sensorAssembly;
    expose Architecture::robotSystem.physical.powerModule;
  }
}
