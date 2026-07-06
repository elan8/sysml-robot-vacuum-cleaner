/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns electronics-facing interface-control records for connectors, signals,
 * rails, buses, and harnesses. PhysicalArchitecture remains authoritative for
 * physical parts and ports; this package adds implementation constraints that
 * electronics tools can extract into schematic and harness work.
 */
package ElectronicsInterfaceControl {
  private import PhysicalArchitecture::*;
  private import PhysicalProtocols::*;
  private import ISQ::*;
  private import SI::*;
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

  part def ElectronicsInterfaceContract {
    attribute contractId : String;
    attribute physicalFeaturePath : String;
    attribute matingFeaturePath : String;
    attribute interfaceKind : ElectricalInterfaceKind;
    attribute connectorRef : String;
    attribute signalDirection : SignalDirection;
    attribute nominalVoltage : ElectricPotentialValue;
    attribute maxCurrent : ElectricCurrentValue;
    attribute busRateOrFrequency : String;
    attribute pinOrSignalList : String;
    attribute criticality : ConnectorCriticality;
    attribute electricalConstraint : String;
    attribute harnessConstraint : String;
    attribute testPointGuidance : String;
  }

  part def ElectronicsInterfaceBaseline {
    doc /*
      Electronics interface-control baseline. Each contract points to source
      ports/features in PhysicalArchitecture and adds connector, signal, rail,
      and test-point details needed for schematic, layout, and harness work.
    */

    part mainPowerEntry : ElectronicsInterfaceContract {
      attribute :>> contractId = "EIC-J_POWER";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.mainPowerOut";
      attribute :>> matingFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.powerIn";
      attribute :>> interfaceKind = ElectricalInterfaceKind::powerRail;
      attribute :>> connectorRef = "J_POWER, 6-pin keyed board-to-wire";
      attribute :>> signalDirection = SignalDirection::sourceToLoad;
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> maxCurrent = 6.0 [A];
      attribute :>> busRateOrFrequency = "DC rail";
      attribute :>> pinOrSignalList = "BAT_14V4, MOTOR_SW, SYS_5V, LOGIC_3V3, CHG_IN, GND_STAR";
      attribute :>> criticality = ConnectorCriticality::safetyCritical;
      attribute :>> electricalConstraint = "Separate high-current motor return from logic return until star point; fuse battery entry.";
      attribute :>> harnessConstraint = "Keyed connector, current-rated contacts, strain relief at battery and main PCB.";
      attribute :>> testPointGuidance = "Expose BAT_14V4, SYS_5V, LOGIC_3V3 and GND_STAR test points near connector.";
    }

    part sensorI2cHarness : ElectronicsInterfaceContract {
      attribute :>> contractId = "EIC-J_SENSOR_I2C";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly.sensorBusOut";
      attribute :>> matingFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.sensorBusHarness";
      attribute :>> interfaceKind = ElectricalInterfaceKind::i2cBus;
      attribute :>> connectorRef = "J_SENSOR_I2C, 6-pin JST-GH";
      attribute :>> signalDirection = SignalDirection::bidirectional;
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> maxCurrent = 0.3 [A];
      attribute :>> busRateOrFrequency = "400 kHz I2C";
      attribute :>> pinOrSignalList = "SDA, SCL, SENSOR_5V, LOGIC_3V3, GND, SHIELD";
      attribute :>> criticality = ConnectorCriticality::missionCritical;
      attribute :>> electricalConstraint = "Open-drain SDA/SCL with 3.3 V pull-ups on main PCB; address set 0x29,0x2A,0x2B,0x68.";
      attribute :>> harnessConstraint = "Keep sensor harness away from motor phase bundle; shield drain bonded at main PCB.";
      attribute :>> testPointGuidance = "Expose SDA and SCL test pads near MCU and connector.";
    }

    part lidarUartHarness : ElectronicsInterfaceContract {
      attribute :>> contractId = "EIC-J_LIDAR";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly.lidarSerialOut";
      attribute :>> matingFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.lidarUartHarness";
      attribute :>> interfaceKind = ElectricalInterfaceKind::uartBus;
      attribute :>> connectorRef = "J_LIDAR, 6-pin JST-GH";
      attribute :>> signalDirection = SignalDirection::bidirectional;
      attribute :>> nominalVoltage = 5.0 [V];
      attribute :>> maxCurrent = 0.5 [A];
      attribute :>> busRateOrFrequency = "1 Mbps UART";
      attribute :>> pinOrSignalList = "MCU_LIDAR_TX, LIDAR_MCU_RX, LIDAR_5V, GND, LIDAR_HEALTH, SHIELD";
      attribute :>> criticality = ConnectorCriticality::missionCritical;
      attribute :>> electricalConstraint = "UART logic is 3.3 V; sensor supply is 5 V with local decoupling and inrush control.";
      attribute :>> harnessConstraint = "Twist TX/RX with ground reference; route away from motor phase wires.";
      attribute :>> testPointGuidance = "Expose TX, RX, LIDAR_5V and LIDAR_HEALTH test pads.";
    }

    part motorPhaseHarness : ElectronicsInterfaceContract {
      attribute :>> contractId = "EIC-J_MOTOR_PHASE";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.leftMotorPhaseOut/rightMotorPhaseOut";
      attribute :>> matingFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.driveModule.phaseLeftIn/phaseRightIn";
      attribute :>> interfaceKind = ElectricalInterfaceKind::threePhaseMotor;
      attribute :>> connectorRef = "J_MOTOR_L and J_MOTOR_R, 3-phase motor outputs";
      attribute :>> signalDirection = SignalDirection::sourceToLoad;
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> maxCurrent = 3.0 [A];
      attribute :>> busRateOrFrequency = "20 kHz PWM inverter output";
      attribute :>> pinOrSignalList = "U, V, W per motor; chassis/shield optional";
      attribute :>> criticality = ConnectorCriticality::safetyCritical;
      attribute :>> electricalConstraint = "Gate-driver current sense and fault output required; creepage and copper width sized for stall current.";
      attribute :>> harnessConstraint = "Short high-current route, separated from sensor and UART harnesses.";
      attribute :>> testPointGuidance = "Expose phase-current sense and driver fault test pads, not motor phases as small signal pads.";
    }

    part safetyGpioHarness : ElectronicsInterfaceContract {
      attribute :>> contractId = "EIC-J_SAFETY_GPIO";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.safetyGpioHarness";
      attribute :>> matingFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly.cliffHazardOut and powerModule.hazardOut";
      attribute :>> interfaceKind = ElectricalInterfaceKind::gpioFaultLine;
      attribute :>> connectorRef = "J_SAFETY_GPIO internal net group";
      attribute :>> signalDirection = SignalDirection::activeLowFaultToMcu;
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> maxCurrent = 0.02 [A];
      attribute :>> busRateOrFrequency = "10 ms sampling target";
      attribute :>> pinOrSignalList = "CLIFF_FL_N, CLIFF_FR_N, CLIFF_RL_N, CLIFF_RR_N, BMS_ALERT_N, MOTOR_FLT_L_N, MOTOR_FLT_R_N, THERMAL_ALERT_N";
      attribute :>> criticality = ConnectorCriticality::safetyCritical;
      attribute :>> electricalConstraint = "Default state shall be fault-active or pulled to known safe state if disconnected.";
      attribute :>> harnessConstraint = "Safety lines routed with ground reference; avoid shared connector pins with noisy motor outputs.";
      attribute :>> testPointGuidance = "Expose each fault line as a bring-up test pad with clear active-low label.";
    }

    part appWirelessUart : ElectronicsInterfaceContract {
      attribute :>> contractId = "EIC-UART_APP";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.mcuUartOut";
      attribute :>> matingFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.wirelessUart";
      attribute :>> interfaceKind = ElectricalInterfaceKind::uartBus;
      attribute :>> connectorRef = "On-board wireless module UART";
      attribute :>> signalDirection = SignalDirection::bidirectional;
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> maxCurrent = 0.15 [A];
      attribute :>> busRateOrFrequency = "921600 baud target";
      attribute :>> pinOrSignalList = "APP_TX, APP_RX, APP_RTS, APP_CTS, WLAN_EN, WLAN_IRQ";
      attribute :>> criticality = ConnectorCriticality::serviceable;
      attribute :>> electricalConstraint = "Level-compatible 3.3 V UART with ESD protection if exposed during service.";
      attribute :>> harnessConstraint = "On-board route; no external harness in baseline.";
      attribute :>> testPointGuidance = "Expose TX/RX and module enable pins for factory programming.";
    }
  }

  part electronicsInterfaceBaseline : ElectronicsInterfaceBaseline;
}
