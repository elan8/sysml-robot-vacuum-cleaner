/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns electronics component candidate selections and selection rationale.
 * These are engineering baseline candidates, not a released production BOM.
 * Final availability, lifecycle, compliance, and datasheet limits must be
 * confirmed before schematic release.
 */
package ElectronicsComponentSelection {
  private import PhysicalArchitecture::*;
  private import ElectronicsInterfaceControl::*;
  private import ElectronicsImplementation::*;
  private import MonetaryUnits::*;
  private import ISQ::*;
  private import SI::*;
  private import ScalarValues::*;

  enum def ComponentSelectionStatus {
    baselineCandidate;
    approvedForPrototype;
    needsDatasheetReview;
    needsAvailabilityCheck;
    alternateCandidate;
    rejected;
  }

  enum def LifecycleStatus {
    active;
    notRecommendedForNewDesign;
    endOfLifeRisk;
    unknown;
  }

  enum def ComponentCategory {
    microcontroller;
    motorDriver;
    timeOfFlightSensor;
    imu;
    lidarModule;
    batteryGaugeOrBms;
    buckRegulator;
    flashMemory;
    wirelessModule;
    connector;
    esdProtection;
    currentSense;
  }

  part def ComponentCandidate {
    attribute candidateId : String;
    attribute functionPath : String;
    attribute relatedContractRefs : String;
    attribute category : ComponentCategory;
    attribute manufacturer : String;
    attribute mpn : String;
    attribute packageName : String;
    attribute footprintName : String;
    attribute supplyVoltageRange : String;
    attribute operatingTemperatureRange : String;
    attribute keySpecs : String;
    attribute interfaceFit : String;
    attribute deratingAndProtection : String;
    attribute unitCostTarget : MonetaryAmount;
    attribute lifecycleStatus : LifecycleStatus;
    attribute selectionStatus : ComponentSelectionStatus;
    attribute approvedForBaseline : Boolean;
    attribute datasheetReviewStatus : String;
    attribute selectionRationale : String;
  }

  part def ElectronicsComponentSelectionBaseline {
    doc /*
      Component selection baseline for electronics implementation. These
      candidates give the electronics engineer enough specificity to start
      schematic symbols, footprints, interface checks, and early BOM review.
      The model intentionally keeps them separate from PhysicalArchitecture so
      product structure does not become coupled to one vendor choice.
    */

    part mainMcuCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-MCU-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.mcu";
      attribute :>> relatedContractRefs = "EIC-J_SENSOR_I2C, EIC-J_LIDAR, EIC-J_SAFETY_GPIO, EIC-UART_APP";
      attribute :>> category = ComponentCategory::microcontroller;
      attribute :>> manufacturer = "STMicroelectronics";
      attribute :>> mpn = "STM32U575VGT6";
      attribute :>> packageName = "LQFP-100";
      attribute :>> footprintName = "LQFP-100_14x14mm_P0.5mm";
      attribute :>> supplyVoltageRange = "1.71..3.6 V";
      attribute :>> operatingTemperatureRange = "-40..85 C industrial target";
      attribute :>> keySpecs = "Arm Cortex-M33 class MCU; >=1 MB flash target; >=256 KB RAM target; I2C, UART, SPI, timers/PWM, quadrature-capable timer inputs.";
      attribute :>> interfaceFit = "Covers sensor I2C, LiDAR UART, BMS I2C, app UART, SPI flash, PWM motor drivers and safety GPIO lines.";
      attribute :>> deratingAndProtection = "3.3 V logic rail, local decoupling on each VDD pair, SWD access, reset supervisor recommended.";
      attribute :>> unitCostTarget = 7 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsDatasheetReview;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm exact flash/RAM/timer counts and package availability before schematic release.";
      attribute :>> selectionRationale = "Low-power Cortex-M33 family matches firmware architecture and security/privacy posture.";
    }

    part motorDriverCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-MDRV-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.leftMotorDriver/rightMotorDriver";
      attribute :>> relatedContractRefs = "EIC-J_MOTOR_PHASE, EIC-J_SAFETY_GPIO";
      attribute :>> category = ComponentCategory::motorDriver;
      attribute :>> manufacturer = "Texas Instruments";
      attribute :>> mpn = "DRV8316R";
      attribute :>> packageName = "VQFN";
      attribute :>> footprintName = "TI_DRV8316_VQFN";
      attribute :>> supplyVoltageRange = "4.5..35 V motor supply target";
      attribute :>> operatingTemperatureRange = "-40..125 C silicon target";
      attribute :>> keySpecs = "Three-phase BLDC driver with integrated MOSFETs, current sense support, fault reporting, PWM control.";
      attribute :>> interfaceFit = "Matches 14.4 V battery rail, 20 kHz PWM target, 3 A peak motor phase budget and fault GPIO requirement.";
      attribute :>> deratingAndProtection = "Thermal copper under package, current limit configured below motor and connector peak limits, fault line routed to safety supervisor.";
      attribute :>> unitCostTarget = 4 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsDatasheetReview;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm peak/continuous current and thermal margin with selected PCB copper.";
      attribute :>> selectionRationale = "Integrated BLDC driver reduces BOM and supports required fault path.";
    }

    part tofSensorCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-TOF-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly.frontTofSensor/leftWallTofSensor/rightWallTofSensor";
      attribute :>> relatedContractRefs = "EIC-J_SENSOR_I2C";
      attribute :>> category = ComponentCategory::timeOfFlightSensor;
      attribute :>> manufacturer = "STMicroelectronics";
      attribute :>> mpn = "VL53L1CX";
      attribute :>> packageName = "Optical LGA module";
      attribute :>> footprintName = "VL53L1CX_LGA";
      attribute :>> supplyVoltageRange = "2.6..3.5 V core/I/O target";
      attribute :>> operatingTemperatureRange = "-20..85 C target";
      attribute :>> keySpecs = "Long-distance ToF ranging class; I2C control; configurable timing budget and region of interest.";
      attribute :>> interfaceFit = "Fits 400 kHz I2C sensor bus and 1200 mm obstacle detection target.";
      attribute :>> deratingAndProtection = "Optical keepout required; confirm cover-glass and floor-dust contamination behavior.";
      attribute :>> unitCostTarget = 5 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsAvailabilityCheck;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm multi-sensor address isolation strategy for three ToF devices.";
      attribute :>> selectionRationale = "Common I2C ToF candidate that matches short-range obstacle sensing.";
    }

    part imuCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-IMU-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly.imu";
      attribute :>> relatedContractRefs = "EIC-J_SENSOR_I2C";
      attribute :>> category = ComponentCategory::imu;
      attribute :>> manufacturer = "TDK InvenSense";
      attribute :>> mpn = "ICM-42688-P";
      attribute :>> packageName = "LGA";
      attribute :>> footprintName = "ICM-42688-P_LGA";
      attribute :>> supplyVoltageRange = "1.71..3.6 V I/O target";
      attribute :>> operatingTemperatureRange = "-40..85 C target";
      attribute :>> keySpecs = "6-axis IMU, I2C/SPI capable, low-noise gyro/accelerometer class.";
      attribute :>> interfaceFit = "Fits I2C bus and localization estimator requirement for wheel odometry plus IMU fusion.";
      attribute :>> deratingAndProtection = "Place near robot centerline where possible; isolate from motor vibration and brush noise.";
      attribute :>> unitCostTarget = 3 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::baselineCandidate;
      attribute :>> approvedForBaseline = true;
      attribute :>> datasheetReviewStatus = "Confirm I2C address and interrupt routing before schematic release.";
      attribute :>> selectionRationale = "Widely used 6-axis IMU class with adequate localization support.";
    }

    part lidarCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-LIDAR-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly.lidar";
      attribute :>> relatedContractRefs = "EIC-J_LIDAR";
      attribute :>> category = ComponentCategory::lidarModule;
      attribute :>> manufacturer = "Slamtec";
      attribute :>> mpn = "RPLIDAR C1 class module";
      attribute :>> packageName = "Vendor module";
      attribute :>> footprintName = "Harnessed module, no PCB footprint";
      attribute :>> supplyVoltageRange = "5 V module supply target";
      attribute :>> operatingTemperatureRange = "consumer indoor target";
      attribute :>> keySpecs = "2D scanning LiDAR class, >=6 m mapping range target, UART data interface, around 10 Hz scan rate target.";
      attribute :>> interfaceFit = "Matches J_LIDAR 5 V supply and 1 Mbps UART target; supports room-scale SLAM baseline.";
      attribute :>> deratingAndProtection = "Add inrush control and connector retention; confirm startup current and EMC impact.";
      attribute :>> unitCostTarget = 35 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::unknown;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsAvailabilityCheck;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm exact module MPN, frame protocol, current draw and mechanical mounting.";
      attribute :>> selectionRationale = "2D LiDAR module class supports privacy-conscious SLAM without camera baseline.";
    }

    part flashCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-FLASH-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.flash";
      attribute :>> relatedContractRefs = "EIC-UART_APP";
      attribute :>> category = ComponentCategory::flashMemory;
      attribute :>> manufacturer = "Winbond";
      attribute :>> mpn = "W25N01GVZEIG";
      attribute :>> packageName = "WSON-8";
      attribute :>> footprintName = "WSON-8_8x6mm";
      attribute :>> supplyVoltageRange = "2.7..3.6 V";
      attribute :>> operatingTemperatureRange = "-40..85 C target";
      attribute :>> keySpecs = "1 Gbit serial NAND flash class, SPI interface, sufficient for local map and diagnostic storage.";
      attribute :>> interfaceFit = "Matches flashSpi storage capacity target of 134217728 B and 3.3 V SPI.";
      attribute :>> deratingAndProtection = "Use wear-leveling, bad-block handling and local decoupling.";
      attribute :>> unitCostTarget = 2 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::baselineCandidate;
      attribute :>> approvedForBaseline = true;
      attribute :>> datasheetReviewStatus = "Confirm footprint, ECC/bad-block software support and endurance requirement.";
      attribute :>> selectionRationale = "Capacity matches privacy-local map storage requirement.";
    }

    part wirelessCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-WIFI-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.wirelessModule";
      attribute :>> relatedContractRefs = "EIC-UART_APP";
      attribute :>> category = ComponentCategory::wirelessModule;
      attribute :>> manufacturer = "Espressif";
      attribute :>> mpn = "ESP32-C3-MINI-1";
      attribute :>> packageName = "Castellated module";
      attribute :>> footprintName = "ESP32-C3-MINI-1_Module";
      attribute :>> supplyVoltageRange = "3.0..3.6 V";
      attribute :>> operatingTemperatureRange = "-40..85 C target";
      attribute :>> keySpecs = "Wi-Fi/BLE module class, UART host interface, integrated antenna option.";
      attribute :>> interfaceFit = "Matches app UART contract and local app connectivity without raw map upload.";
      attribute :>> deratingAndProtection = "Antenna keepout required; ESD on service/programming access; module enable/reset routed to MCU.";
      attribute :>> unitCostTarget = 3 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::baselineCandidate;
      attribute :>> approvedForBaseline = true;
      attribute :>> datasheetReviewStatus = "Confirm regulatory module variant and antenna keepout with enclosure.";
      attribute :>> selectionRationale = "Low-cost module with BLE/Wi-Fi path for local app link.";
    }

    part bmsCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-BMS-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.bms";
      attribute :>> relatedContractRefs = "EIC-J_POWER, EIC-J_SAFETY_GPIO";
      attribute :>> category = ComponentCategory::batteryGaugeOrBms;
      attribute :>> manufacturer = "Texas Instruments";
      attribute :>> mpn = "BQ40Z50-R2";
      attribute :>> packageName = "VQFN";
      attribute :>> footprintName = "TI_BQ40Z50_VQFN";
      attribute :>> supplyVoltageRange = "2S..4S Li-ion pack monitor target";
      attribute :>> operatingTemperatureRange = "-40..85 C target";
      attribute :>> keySpecs = "Li-ion battery gauge/protection controller class for 4S pack telemetry, SMBus/I2C, alert output.";
      attribute :>> interfaceFit = "Matches 4S2P pack, BMS harness address target and safety alert line.";
      attribute :>> deratingAndProtection = "Requires pack-level protection FETs, sense resistor and cell balancing review.";
      attribute :>> unitCostTarget = 4 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsDatasheetReview;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm charger topology, protection FET sizing and pack certification path.";
      attribute :>> selectionRationale = "Supports smart battery telemetry and safety alert integration.";
    }

    part logicBuckCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-BUCK-3V3-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.logicRegulator";
      attribute :>> relatedContractRefs = "EIC-J_POWER";
      attribute :>> category = ComponentCategory::buckRegulator;
      attribute :>> manufacturer = "Texas Instruments";
      attribute :>> mpn = "TPS62177";
      attribute :>> packageName = "WSON";
      attribute :>> footprintName = "TPS62177_WSON";
      attribute :>> supplyVoltageRange = "4.75..28 V input target";
      attribute :>> operatingTemperatureRange = "-40..125 C silicon target";
      attribute :>> keySpecs = "Synchronous buck regulator class for 3.3 V logic rail around 1 A class.";
      attribute :>> interfaceFit = "Fits LOGIC_3V3 budget if final current and thermal derating pass.";
      attribute :>> deratingAndProtection = "Validate inductor saturation, thermal rise and startup sequencing with sensor rail.";
      attribute :>> unitCostTarget = 1 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsDatasheetReview;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm exact output-current variant and compensation requirements.";
      attribute :>> selectionRationale = "Compact wide-input buck family for battery-powered logic rail.";
    }

    part sensorLoadSwitchCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-PROT-SENSOR-001";
      attribute :>> functionPath = "ElectronicsImplementation::electronicsHandoff.sensorRailBudget";
      attribute :>> relatedContractRefs = "EIC-J_SENSOR_I2C, EIC-J_LIDAR";
      attribute :>> category = ComponentCategory::esdProtection;
      attribute :>> manufacturer = "Texas Instruments";
      attribute :>> mpn = "TPS22919";
      attribute :>> packageName = "WSON/SOT class";
      attribute :>> footprintName = "TPS22919_LoadSwitch";
      attribute :>> supplyVoltageRange = "1.0..5.5 V load switch target";
      attribute :>> operatingTemperatureRange = "-40..105 C target";
      attribute :>> keySpecs = "Load switch class for sensor 5 V rail isolation and inrush limiting.";
      attribute :>> interfaceFit = "Supports SENSOR_5V protection strategy for LiDAR and sensor harness.";
      attribute :>> deratingAndProtection = "Validate current limit and thermal behavior with LiDAR startup current.";
      attribute :>> unitCostTarget = 1 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::alternateCandidate;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm selected package current rating and fault reporting need.";
      attribute :>> selectionRationale = "Provides controlled sensor rail sequencing and fault containment.";
    }

    part sensorConnectorCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-CONN-SENSOR-001";
      attribute :>> functionPath = "ElectronicsInterfaceControl::electronicsInterfaceBaseline.sensorI2cHarness";
      attribute :>> relatedContractRefs = "EIC-J_SENSOR_I2C";
      attribute :>> category = ComponentCategory::connector;
      attribute :>> manufacturer = "JST";
      attribute :>> mpn = "BM06B-GHS-TBT or equivalent JST-GH 6-pin header";
      attribute :>> packageName = "1.25 mm pitch SMT header";
      attribute :>> footprintName = "JST_GH_BM06B-GHS-TBT";
      attribute :>> supplyVoltageRange = "signal connector, 3.3/5 V harness";
      attribute :>> operatingTemperatureRange = "-25..85 C target";
      attribute :>> keySpecs = "6-pin keyed connector for SDA, SCL, SENSOR_5V, LOGIC_3V3, GND, SHIELD.";
      attribute :>> interfaceFit = "Matches J_SENSOR_I2C contract and keyed harness requirement.";
      attribute :>> deratingAndProtection = "Confirm contact current for sensor power and strain relief in enclosure.";
      attribute :>> unitCostTarget = 1 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::baselineCandidate;
      attribute :>> approvedForBaseline = true;
      attribute :>> datasheetReviewStatus = "Confirm mating housing/crimp part numbers and enclosure clearance.";
      attribute :>> selectionRationale = "Compact keyed harness connector already used in physical interface notes.";
    }

    part motorCurrentSenseCandidate : ComponentCandidate {
      attribute :>> candidateId = "ECS-CSENSE-001";
      attribute :>> functionPath = "PhysicalArchitecture::AutonomousFloorCleaningRobot.mainElectronics.mainControlPcb.leftMotorDriver/rightMotorDriver";
      attribute :>> relatedContractRefs = "EIC-J_MOTOR_PHASE, EIC-J_SAFETY_GPIO";
      attribute :>> category = ComponentCategory::currentSense;
      attribute :>> manufacturer = "Yageo or Vishay";
      attribute :>> mpn = "0.02 ohm 1 percent 1 W current-sense resistor class";
      attribute :>> packageName = "2512 shunt";
      attribute :>> footprintName = "R_2512_CurrentSense";
      attribute :>> supplyVoltageRange = "low-side or inline sense target";
      attribute :>> operatingTemperatureRange = "-55..155 C resistor target";
      attribute :>> keySpecs = "20 milliohm shunt class, 1 percent tolerance, >=1 W, low TCR preferred.";
      attribute :>> interfaceFit = "Supports motor driver fault/current limit and 3 A peak validation.";
      attribute :>> deratingAndProtection = "Power dissipation at 3 A is 0.18 W nominal; derate for stall and thermal enclosure.";
      attribute :>> unitCostTarget = 1 [EUR];
      attribute :>> lifecycleStatus = LifecycleStatus::active;
      attribute :>> selectionStatus = ComponentSelectionStatus::needsDatasheetReview;
      attribute :>> approvedForBaseline = false;
      attribute :>> datasheetReviewStatus = "Confirm sense topology with selected motor driver and ADC/fault thresholds.";
      attribute :>> selectionRationale = "Explicit current-sense component is needed to close motor stall and safety evidence.";
    }
  }

  part electronicsComponentSelectionBaseline : ElectronicsComponentSelectionBaseline;
}
