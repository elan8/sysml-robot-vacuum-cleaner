/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns electronics-engineering handoff records derived from physical
 * architecture, electronics interface control, requirements, and verification.
 * Keep physical parts, ports, and product roll-ups in PhysicalArchitecture.
 */
package ElectronicsImplementation {
  private import PhysicalArchitecture::*;
  private import ElectronicsInterfaceControl::*;
  private import SystemRequirements::*;
  private import Verification::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def ElectronicsImplementationStatus {
    readyForSchematic;
    needsComponentSelection;
    needsLayoutDetail;
    needsSafetyReview;
    deferred;
  }

  enum def PcbDomain {
    powerEntry;
    motorDrive;
    sensing;
    compute;
    wireless;
    charging;
    safetyMonitor;
  }

  part def ElectronicsWorkPackage {
    attribute workPackageId : String;
    attribute physicalFeaturePath : String;
    attribute owningBoardOrHarness : String;
    attribute interfaceContractRefs : String;
    attribute requirementRefs : String;
    attribute verificationRefs : String;
    attribute implementationStatus : ElectronicsImplementationStatus;
    attribute pcbDomain : PcbDomain;
    attribute schematicSheets : String;
    attribute layoutConstraints : String;
    attribute bomSelectionNotes : String;
    attribute testPointScope : String;
    attribute maxBoardAreaMm2 : Real;
    attribute powerDissipationBudget : PowerValue;
  }

  part def RailBudgetRecord {
    attribute railName : String;
    attribute sourceFeaturePath : String;
    attribute loadFeaturePaths : String;
    attribute nominalVoltage : ElectricPotentialValue;
    attribute continuousCurrentBudget : ElectricCurrentValue;
    attribute peakCurrentBudget : ElectricCurrentValue;
    attribute protectionStrategy : String;
    attribute measurementPoint : String;
  }

  part def ElectronicsHandoffPackage {
    doc /*
      Engineer-facing electronics handoff. The source of physical truth remains
      PhysicalArchitecture; this package organizes the electronics work that a
      PCB/harness engineer needs to execute and that tools can extract.
    */

    part mainControlPcbWork : ElectronicsWorkPackage {
      attribute :>> workPackageId = "EWP-MAIN-PCB";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb";
      attribute :>> owningBoardOrHarness = "MainControlPcb";
      attribute :>> interfaceContractRefs = "EIC-J_POWER, EIC-J_SENSOR_I2C, EIC-J_LIDAR, EIC-J_MOTOR_PHASE, EIC-J_SAFETY_GPIO, EIC-UART_APP";
      attribute :>> requirementRefs = "limitBomCost, limitTotalMass, superviseHazards, reportCleaningStatus";
      attribute :>> verificationRefs = "verifyElectricalInterfaceControl, verifyFirmwareSchedulerTiming, verifyLiftOvercurrentThermalHazards";
      attribute :>> implementationStatus = ElectronicsImplementationStatus::readyForSchematic;
      attribute :>> pcbDomain = PcbDomain::compute;
      attribute :>> schematicSheets = "power_entry, mcu_core, motor_drivers, sensor_io, wireless, flash_storage, safety_gpio";
      attribute :>> layoutConstraints = "Partition motor driver currents from MCU/sensor ground; star point at J_POWER; keep LiDAR UART and I2C away from phase routes.";
      attribute :>> bomSelectionNotes = "Select MCU with enough timers for dual BLDC PWM, quadrature inputs, UART2 LiDAR, I2C sensors/BMS, SPI flash, and wireless UART.";
      attribute :>> testPointScope = "BAT_14V4, SYS_5V, LOGIC_3V3, SDA, SCL, LIDAR_TX/RX, driver faults, safety GPIO, SWD/debug.";
      attribute :>> maxBoardAreaMm2 = 7200.0;
      attribute :>> powerDissipationBudget = 4.0 [W];
    }

    part powerAndChargingWork : ElectronicsWorkPackage {
      attribute :>> workPackageId = "EWP-POWER-CHARGE";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule";
      attribute :>> owningBoardOrHarness = "PowerModule and battery harness";
      attribute :>> interfaceContractRefs = "EIC-J_POWER";
      attribute :>> requirementRefs = "returnToDock, chargeSafely, limitTotalMass";
      attribute :>> verificationRefs = "verifyDockingSuccess, verifyLiftOvercurrentThermalHazards, verifyElectricalInterfaceControl";
      attribute :>> implementationStatus = ElectronicsImplementationStatus::needsSafetyReview;
      attribute :>> pcbDomain = PcbDomain::charging;
      attribute :>> schematicSheets = "battery_pack_interface, charger_input, logic_regulator, motor_regulator, bms_telemetry";
      attribute :>> layoutConstraints = "Current-rated paths for battery and motor rail; thermal relief for regulators; charger input isolated from user-accessible contacts.";
      attribute :>> bomSelectionNotes = "Select buck regulators and protection devices for 14.4 V pack, motor peaks, and safe dock charging.";
      attribute :>> testPointScope = "Battery voltage, charger input, regulator outputs, BMS alert, charge current sense.";
      attribute :>> maxBoardAreaMm2 = 4200.0;
      attribute :>> powerDissipationBudget = 5.0 [W];
    }

    part sensorHarnessWork : ElectronicsWorkPackage {
      attribute :>> workPackageId = "EWP-SENSOR-HARNESS";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly";
      attribute :>> owningBoardOrHarness = "Sensor harness and sensor carrier";
      attribute :>> interfaceContractRefs = "EIC-J_SENSOR_I2C, EIC-J_LIDAR, EIC-J_SAFETY_GPIO";
      attribute :>> requirementRefs = "avoidObstacles, detectCliffs, supportRoomScaleSlam, localizeReliably";
      attribute :>> verificationRefs = "verifyObstacleAvoidance, verifyCliffDetection, verifyRoomScaleSlam, verifyElectricalInterfaceControl";
      attribute :>> implementationStatus = ElectronicsImplementationStatus::needsLayoutDetail;
      attribute :>> pcbDomain = PcbDomain::sensing;
      attribute :>> schematicSheets = "tof_sensors, imu, lidar_connector, cliff_gpio";
      attribute :>> layoutConstraints = "Maintain LiDAR UART signal integrity and separate cliff safety lines from motor noise.";
      attribute :>> bomSelectionNotes = "Choose ToF sensors with configurable I2C addresses or address-isolation strategy.";
      attribute :>> testPointScope = "Sensor I2C, LiDAR 5 V, LiDAR UART, each cliff active-low line.";
      attribute :>> maxBoardAreaMm2 = 3000.0;
      attribute :>> powerDissipationBudget = 2.0 [W];
    }

    part motorDriveWork : ElectronicsWorkPackage {
      attribute :>> workPackageId = "EWP-MOTOR-DRIVE";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.leftMotorDriver/rightMotorDriver";
      attribute :>> owningBoardOrHarness = "MainControlPcb motor driver section and drive harness";
      attribute :>> interfaceContractRefs = "EIC-J_MOTOR_PHASE, EIC-J_SAFETY_GPIO";
      attribute :>> requirementRefs = "recoverFromStall, superviseHazards, avoidObstacles";
      attribute :>> verificationRefs = "verifyStallRecovery, verifyLiftOvercurrentThermalHazards, verifyElectricalInterfaceControl";
      attribute :>> implementationStatus = ElectronicsImplementationStatus::needsComponentSelection;
      attribute :>> pcbDomain = PcbDomain::motorDrive;
      attribute :>> schematicSheets = "left_motor_driver, right_motor_driver, current_sense, fault_outputs";
      attribute :>> layoutConstraints = "Wide copper for phase currents, compact gate loops, thermal copper for driver ICs, clear separation from sensor IO.";
      attribute :>> bomSelectionNotes = "Select gate driver/inverter with fault output and current sense compatible with 3 A peak.";
      attribute :>> testPointScope = "Driver enable, PWM commands, fault outputs, current sense; no small-signal probing on phase nodes during normal run.";
      attribute :>> maxBoardAreaMm2 = 2400.0;
      attribute :>> powerDissipationBudget = 3.5 [W];
    }

    part wirelessAndStorageWork : ElectronicsWorkPackage {
      attribute :>> workPackageId = "EWP-WIRELESS-STORAGE";
      attribute :>> physicalFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.wirelessUart and flashSpi";
      attribute :>> owningBoardOrHarness = "MainControlPcb wireless and nonvolatile memory section";
      attribute :>> interfaceContractRefs = "EIC-UART_APP";
      attribute :>> requirementRefs = "reportCleaningStatus, protectMapPrivacy, notifyMaintenanceNeeded";
      attribute :>> verificationRefs = "verifyProtocolContracts, verifyPrivacyControls";
      attribute :>> implementationStatus = ElectronicsImplementationStatus::readyForSchematic;
      attribute :>> pcbDomain = PcbDomain::wireless;
      attribute :>> schematicSheets = "wireless_module, external_flash, service_programming";
      attribute :>> layoutConstraints = "Respect antenna keepout; keep flash SPI short and away from motor driver edges.";
      attribute :>> bomSelectionNotes = "Wireless module shall support local app link without requiring raw map upload.";
      attribute :>> testPointScope = "Wireless UART, module reset/enable, flash CS/SCK/MOSI/MISO.";
      attribute :>> maxBoardAreaMm2 = 1800.0;
      attribute :>> powerDissipationBudget = 1.2 [W];
    }

    part batteryRailBudget : RailBudgetRecord {
      attribute :>> railName = "BAT_14V4";
      attribute :>> sourceFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.batteryPack.packOut";
      attribute :>> loadFeaturePaths = "mainElectronics.powerIn, cleaningHead.powerIn, drive motor drivers, regulators, dockInterface";
      attribute :>> nominalVoltage = 14.4 [V];
      attribute :>> continuousCurrentBudget = 5.0 [A];
      attribute :>> peakCurrentBudget = 8.0 [A];
      attribute :>> protectionStrategy = "battery fuse, reverse-polarity protection, charger-current limit, motor rail current monitoring";
      attribute :>> measurementPoint = "J_POWER BAT_14V4 test point";
    }

    part logicRailBudget : RailBudgetRecord {
      attribute :>> railName = "LOGIC_3V3";
      attribute :>> sourceFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.logicRegulator.powerOut";
      attribute :>> loadFeaturePaths = "MCU, I2C pull-ups, sensors logic, wireless IO, flash, safety GPIO";
      attribute :>> nominalVoltage = 3.3 [V];
      attribute :>> continuousCurrentBudget = 1.0 [A];
      attribute :>> peakCurrentBudget = 1.5 [A];
      attribute :>> protectionStrategy = "regulator current limit, local decoupling, ESD on service/external lines";
      attribute :>> measurementPoint = "LOGIC_3V3 test point near MCU";
    }

    part sensorRailBudget : RailBudgetRecord {
      attribute :>> railName = "SENSOR_5V";
      attribute :>> sourceFeaturePath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.logicRegulator.powerOut";
      attribute :>> loadFeaturePaths = "LiDAR module, ToF sensor power, sensor harness";
      attribute :>> nominalVoltage = 5.0 [V];
      attribute :>> continuousCurrentBudget = 0.8 [A];
      attribute :>> peakCurrentBudget = 1.2 [A];
      attribute :>> protectionStrategy = "load switch or polyfuse for sensor harness; LiDAR inrush control";
      attribute :>> measurementPoint = "SENSOR_5V test point near J_SENSOR_I2C and J_LIDAR";
    }
  }

  part electronicsHandoff : ElectronicsHandoffPackage;
}
