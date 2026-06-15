/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns PCB-facing interface-control records for connectors, signals, buses,
 * rails, and fault polarities. Depends on board/electronics libraries,
 * protocols, and physical architecture. Keep software message schemas in
 * InterfaceControl.
 */
package ElectricalInterfaces {
  private import BoardIntegrationDomain::*;
  private import ElectronicsCore::*;
  private import PhysicalProtocols::*;
  private import PhysicalArchitecture::*;
  private import ScalarValues::*;

  part def InterfaceSignal {
    attribute signalName : String;
    attribute direction : String;
    attribute voltageDomain : String;
    attribute polarity : String;
    attribute nominalCurrentClass : String;
  }

  part def InterfaceControlRecord {
    attribute interfaceName : String;
    attribute connectorName : String;
    attribute connectorType : String;
    attribute pinCount : Integer;
    attribute voltageDomain : String;
    attribute busSpeed : String;
    attribute addressOrSelect : String;
    attribute implementationNote : String;
  }

  part def MainControlPcbInterfaceControl {
    ref board : MainControlPcb;
    part boardAssembly : BoardAssembly {
      attribute :>> boardName = "main-control-pcb";
      attribute :>> layerCount = 4;
    }

    part sensorI2cHarness : InterfaceControlRecord {
      attribute :>> interfaceName = "sensor I2C harness";
      attribute :>> connectorName = "J_SENSOR_I2C";
      attribute :>> connectorType = "6-pin JST-GH";
      attribute :>> pinCount = 6;
      attribute :>> voltageDomain = "3.3 V logic";
      attribute :>> busSpeed = "400 kHz";
      attribute :>> addressOrSelect = "front ToF 0x29, left ToF 0x2A, right ToF 0x2B, IMU 0x68";
      attribute :>> implementationNote = "SDA/SCL with 3.3 V pull-ups, sensor power, ground, keyed harness.";
      part sda : InterfaceSignal {
        attribute :>> signalName = "SENSOR_I2C_SDA";
        attribute :>> direction = "bidirectional";
        attribute :>> voltageDomain = "3.3 V";
        attribute :>> polarity = "open-drain active low acknowledge";
        attribute :>> nominalCurrentClass = "logic";
      }
      part scl : InterfaceSignal {
        attribute :>> signalName = "SENSOR_I2C_SCL";
        attribute :>> direction = "mcu to sensors";
        attribute :>> voltageDomain = "3.3 V";
        attribute :>> polarity = "open-drain clock";
        attribute :>> nominalCurrentClass = "logic";
      }
    }

    part bmsSmbusHarness : InterfaceControlRecord {
      attribute :>> interfaceName = "battery BMS SMBus";
      attribute :>> connectorName = "J_BMS";
      attribute :>> connectorType = "5-pin board-to-wire";
      attribute :>> pinCount = 5;
      attribute :>> voltageDomain = "3.3 V logic plus pack reference";
      attribute :>> busSpeed = "100 kHz";
      attribute :>> addressOrSelect = "BMS 0x16";
      attribute :>> implementationNote = "SMBus SDA/SCL, alert/fault GPIO, pack reference, ground.";
    }

    part flashSpiInterface : InterfaceControlRecord {
      attribute :>> interfaceName = "external SPI flash";
      attribute :>> connectorName = "U_FLASH on-board";
      attribute :>> connectorType = "SOIC/QSPI footprint";
      attribute :>> pinCount = 8;
      attribute :>> voltageDomain = "3.3 V logic";
      attribute :>> busSpeed = "24 MHz";
      attribute :>> addressOrSelect = "FLASH_CS0";
      attribute :>> implementationNote = "SPI mode 0; CS, SCK, MISO, MOSI, WP/HOLD pulled inactive.";
    }

    part wirelessUartInterface : InterfaceControlRecord {
      attribute :>> interfaceName = "wireless module UART";
      attribute :>> connectorName = "U_WIFI_BLE";
      attribute :>> connectorType = "soldered module castellated pads";
      attribute :>> pinCount = 6;
      attribute :>> voltageDomain = "3.3 V logic";
      attribute :>> busSpeed = "1 Mbps UART";
      attribute :>> addressOrSelect = "UART1";
      attribute :>> implementationNote = "MCU TX/RX cross to wireless RX/TX; optional wake/reset GPIO.";
    }

    part lidarSerialInterface : InterfaceControlRecord {
      attribute :>> interfaceName = "2D dToF/LiDAR serial link";
      attribute :>> connectorName = "J_LIDAR";
      attribute :>> connectorType = "6-pin JST-GH";
      attribute :>> pinCount = 6;
      attribute :>> voltageDomain = "5 V sensor power plus 3.3 V logic";
      attribute :>> busSpeed = "1 Mbps UART target";
      attribute :>> addressOrSelect = "UART2_LIDAR";
      attribute :>> implementationNote = "MCU TX/RX cross to LiDAR RX/TX; 5 V power, ground, optional motor-sync or health GPIO.";
      part txToLidar : InterfaceSignal {
        attribute :>> signalName = "MCU_LIDAR_TX";
        attribute :>> direction = "mcu to lidar";
        attribute :>> voltageDomain = "3.3 V";
        attribute :>> polarity = "idle high UART";
        attribute :>> nominalCurrentClass = "logic";
      }
      part rxFromLidar : InterfaceSignal {
        attribute :>> signalName = "LIDAR_MCU_RX";
        attribute :>> direction = "lidar to mcu";
        attribute :>> voltageDomain = "3.3 V";
        attribute :>> polarity = "idle high UART";
        attribute :>> nominalCurrentClass = "logic";
      }
      part power5v : InterfaceSignal {
        attribute :>> signalName = "LIDAR_5V";
        attribute :>> direction = "board to lidar";
        attribute :>> voltageDomain = "5 V";
        attribute :>> polarity = "positive supply";
        attribute :>> nominalCurrentClass = "sensor power below 500 mA";
      }
    }

    part flagshipVisionOptionInterface : InterfaceControlRecord {
      attribute :>> interfaceName = "deferred flagship vision and AI option";
      attribute :>> connectorName = "J_VISION_OPTION";
      attribute :>> connectorType = "board-to-board mezzanine candidate";
      attribute :>> pinCount = 30;
      attribute :>> voltageDomain = "5 V module power plus 3.3 V control";
      attribute :>> busSpeed = "MIPI/parallel camera candidate plus SPI/I2C control";
      attribute :>> addressOrSelect = "not selected for premium privacy-first variant";
      attribute :>> implementationNote = "Trade-study artifact only; not a selected PCB requirement until AI vision option is chosen.";
    }

    part motorAndActuatorPwm : InterfaceControlRecord {
      attribute :>> interfaceName = "motor and actuator PWM";
      attribute :>> connectorName = "J_MOTOR_PWM";
      attribute :>> connectorType = "PCB internal nets plus cleaning-head harness";
      attribute :>> pinCount = 8;
      attribute :>> voltageDomain = "3.3 V control, 14.4 V switched motor rail";
      attribute :>> busSpeed = "20 kHz PWM target";
      attribute :>> addressOrSelect = "left/right drive, main brush, side brush, vacuum fan";
      attribute :>> implementationNote = "PWM outputs to motor drivers and brushed actuators; fault GPIO returns to safety supervisor.";
    }

    part safetyGpioInterface : InterfaceControlRecord {
      attribute :>> interfaceName = "safety GPIO aggregation";
      attribute :>> connectorName = "J_SAFETY";
      attribute :>> connectorType = "mixed PCB and harness inputs";
      attribute :>> pinCount = 10;
      attribute :>> voltageDomain = "3.3 V logic";
      attribute :>> busSpeed = "sampled at 10 ms safety period";
      attribute :>> addressOrSelect = "cliff, bumper, lift, thermal, overcurrent, dock status";
      attribute :>> implementationNote = "Fault inputs use fail-safe active-low convention where supported.";
    }

    part powerRailInterface : InterfaceControlRecord {
      attribute :>> interfaceName = "power rails";
      attribute :>> connectorName = "J_POWER";
      attribute :>> connectorType = "battery and dock power entry";
      attribute :>> pinCount = 6;
      attribute :>> voltageDomain = "14.4 V battery, 5 V regulated, 3.3 V logic";
      attribute :>> busSpeed = "not applicable";
      attribute :>> addressOrSelect = "battery rail, motor rail, 5 V logic rail, charger input";
      attribute :>> implementationNote = "Separate high-current motor return from logic return until star point.";
    }
  }

  part mainControlPcbInterfaces : MainControlPcbInterfaceControl;
}
