/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Defines electronics-interface metadata applied to authoritative physical
 * ports and harness parts. Endpoint identity and connectivity remain native
 * SysML relationships in PhysicalArchitecture.
 */
package ElectronicsInterfaceControl {
  private import ISQ::*;
  private import ScalarValues::*;

  enum def ElectricalInterfaceKind {
    powerRail;
    i2cBus;
    uartBus;
    pwmOutput;
    gpioFaultLine;
    threePhaseMotor;
    chargingContact;
  }

  enum def SignalDirection {
    sourceToLoad;
    bidirectional;
    mcuToPeripheral;
    peripheralToMcu;
    activeLowFaultToMcu;
  }

  enum def ConnectorCriticality {
    safetyCritical;
    missionCritical;
    serviceable;
    diagnostic;
  }

  metadata def ElectricalInterfaceInfo {
    attribute connectorId : String;
    attribute interfaceKind : ElectricalInterfaceKind;
    attribute signalDirection : SignalDirection;
    attribute nominalVoltage : ElectricPotentialValue;
    attribute maxCurrent : ElectricCurrentValue;
    attribute criticality : ConnectorCriticality;
  }
}
