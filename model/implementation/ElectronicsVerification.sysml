/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns electronics bring-up and verification intent for PCB, harness, power,
 * sensing, motor-drive, and safety interfaces. System-level verification cases
 * remain in Verification; this package gives electronics engineers executable
 * checklist structure.
 */
package ElectronicsVerification {
  private import ElectronicsInterfaceControl::*;
  private import ElectronicsImplementation::*;
  private import PhysicalArchitecture::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def ElectronicsTestMethod {
    inspection;
    benchMeasurement;
    functionalBringUp;
    faultInjection;
    manufacturingTest;
  }

  part def ElectronicsVerificationStep {
    attribute stepId : String;
    attribute method : ElectronicsTestMethod;
    attribute targetFeaturePath : String;
    attribute relatedContractRefs : String;
    attribute setup : String;
    attribute expectedResult : String;
    attribute evidenceArtifact : String;
  }

  part def ElectronicsVerificationPlan {
    doc /*
      Electronics bring-up plan extracted from interface contracts and handoff
      packages. This is a discipline-specific checklist and complements the
      higher-level Verification package.
    */

    part powerRailBringUp : ElectronicsVerificationStep {
      attribute :>> stepId = "EVT-POWER-001";
      attribute :>> method = ElectronicsTestMethod::benchMeasurement;
      attribute :>> targetFeaturePath = "ElectronicsImplementation::electronicsHandoff.batteryRailBudget, logicRailBudget, sensorRailBudget";
      attribute :>> relatedContractRefs = "EIC-J_POWER";
      attribute :>> setup = "Current-limited bench supply at battery input, motor drivers disabled, no battery connected.";
      attribute :>> expectedResult = "BAT_14V4, LOGIC_3V3 and SENSOR_5V within tolerance; no unexpected load or regulator thermal issue.";
      attribute :>> evidenceArtifact = "bringup/power_rail_measurements.csv";
    }

    part sensorBusBringUp : ElectronicsVerificationStep {
      attribute :>> stepId = "EVT-SENSOR-001";
      attribute :>> method = ElectronicsTestMethod::functionalBringUp;
      attribute :>> targetFeaturePath = "ElectronicsInterfaceControl::electronicsInterfaceBaseline.sensorI2cHarness";
      attribute :>> relatedContractRefs = "EIC-J_SENSOR_I2C";
      attribute :>> setup = "MCU firmware in bus-scan mode, sensor harness connected, motors disabled.";
      attribute :>> expectedResult = "I2C devices respond at 0x29, 0x2A, 0x2B and 0x68 with stable 400 kHz waveform.";
      attribute :>> evidenceArtifact = "bringup/sensor_i2c_scan.log";
    }

    part lidarUartBringUp : ElectronicsVerificationStep {
      attribute :>> stepId = "EVT-LIDAR-001";
      attribute :>> method = ElectronicsTestMethod::functionalBringUp;
      attribute :>> targetFeaturePath = "ElectronicsInterfaceControl::electronicsInterfaceBaseline.lidarUartHarness";
      attribute :>> relatedContractRefs = "EIC-J_LIDAR";
      attribute :>> setup = "LiDAR powered from SENSOR_5V, UART capture enabled at 1 Mbps.";
      attribute :>> expectedResult = "Valid scan frames with checksum pass and no framing errors for 10 minutes.";
      attribute :>> evidenceArtifact = "bringup/lidar_uart_capture.bin";
    }

    part safetyGpioFaultInjection : ElectronicsVerificationStep {
      attribute :>> stepId = "EVT-SAFETY-001";
      attribute :>> method = ElectronicsTestMethod::faultInjection;
      attribute :>> targetFeaturePath = "ElectronicsInterfaceControl::electronicsInterfaceBaseline.safetyGpioHarness";
      attribute :>> relatedContractRefs = "EIC-J_SAFETY_GPIO";
      attribute :>> setup = "Inject active-low cliff, BMS, motor fault and thermal inputs one at a time.";
      attribute :>> expectedResult = "Each fault line is detected as active fault and reaches safety supervisor input within 10 ms sampling target.";
      attribute :>> evidenceArtifact = "bringup/safety_gpio_fault_matrix.csv";
    }

    part motorDriverBringUp : ElectronicsVerificationStep {
      attribute :>> stepId = "EVT-MOTOR-001";
      attribute :>> method = ElectronicsTestMethod::faultInjection;
      attribute :>> targetFeaturePath = "ElectronicsImplementation::electronicsHandoff.motorDriveWork";
      attribute :>> relatedContractRefs = "EIC-J_MOTOR_PHASE, EIC-J_SAFETY_GPIO";
      attribute :>> setup = "Motor fixture, current limit, low PWM duty, fault injection on driver fault pins.";
      attribute :>> expectedResult = "PWM output disabled on force stop or driver fault; current remains within 3 A peak budget.";
      attribute :>> evidenceArtifact = "bringup/motor_driver_fault_test.csv";
    }

    part manufacturingContinuityTest : ElectronicsVerificationStep {
      attribute :>> stepId = "EVT-MFG-001";
      attribute :>> method = ElectronicsTestMethod::manufacturingTest;
      attribute :>> targetFeaturePath = "ElectronicsImplementation::electronicsHandoff.mainControlPcbWork";
      attribute :>> relatedContractRefs = "EIC-J_POWER, EIC-J_SENSOR_I2C, EIC-J_LIDAR, EIC-J_MOTOR_PHASE, EIC-J_SAFETY_GPIO, EIC-UART_APP";
      attribute :>> setup = "Factory test fixture connected to all board and harness interfaces before enclosure assembly.";
      attribute :>> expectedResult = "No shorts, connector orientation correct, programming/debug access works, required test points reachable.";
      attribute :>> evidenceArtifact = "manufacturing/eol_electronics_report.json";
    }
  }

  part electronicsVerificationPlan : ElectronicsVerificationPlan;
}
