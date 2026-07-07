/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns product-line variant choices and selected configuration baselines for
 * the robot. Keep rationale in TradeStudies and realized structure in
 * PhysicalArchitecture, Implementation, and assurance packages.
 */
package ProductVariants {
  private import ScalarValues::*;
  private import PhysicalArchitecture::*;
  private import FirmwareArchitecture::*;
  private import ElectronicsComponentSelection::*;

  enum def VariantSelectionStatus {
    candidate;
    selectedBaseline;
    deferred;
    rejected;
    released;
  }

  enum def ProductTier {
    entry;
    standard;
    premium;
    flagship;
  }

  enum def VariantConcernKind {
    productTier;
    navigationSensorSuite;
    cleaningPerformance;
    batteryPack;
    safetyMonitor;
    connectivity;
    privacyMode;
    computePlatform;
    dockOption;
  }

  part def VariantOptionRecord {
    attribute optionId : String;
    attribute concern : VariantConcernKind;
    attribute tierApplicability : ProductTier;
    attribute selectionStatus : VariantSelectionStatus;
    attribute optionName : String;
    attribute selectedModelElementPaths : String;
    attribute changedImplementationPaths : String;
    attribute requirementRefs : String;
    attribute verificationRefs : String;
    attribute rationaleRef : String;
  }

  part def VariantConfiguration {
    attribute configurationId : String;
    attribute displayName : String;
    attribute tier : ProductTier;
    attribute selectedOptions : String;
    attribute excludedOptions : String;
    attribute implementationImpactSummary : String;
    attribute verificationImpactSummary : String;
  }

  variation part def NavigationSensorSuiteChoice :> SensorAssembly {
    variant tofImuOnly;
    variant lidarSlamSuite;
    variant aiVisionSuite;
  }

  variation part def CleaningPerformanceChoice :> CleaningHeadModule {
    variant standardQuietCleaning;
    variant highSuctionCleaning;
  }

  variation part def BatteryPackChoice :> LithiumIonBatteryPack {
    variant pack4s2p12500mAh;
    variant extendedPack4s3p;
  }

  variation part def SafetyMonitorChoice :> SafetySupervisorFirmware {
    variant sameMcuSafetySupervisor;
    variant independentSafetyMonitor;
  }

  variation part def ConnectivityChoice :> MainControlPcb {
    variant localBleOnly;
    variant wifiBleLocalApp;
    variant wifiBleCloudCapable;
  }

  variation part def DockChoice :> DockInterfaceModule {
    variant chargeOnlyDock;
    variant beaconChargeDock;
    variant autoEmptyDock;
  }

  part def RobotVariantCatalog {
    doc /*
      Product-line variant catalog. Native SysML variation definitions above
      define the allowed choices; the records below make selection status,
      affected model paths, requirements, verification, and trade-study
      rationale easy for tools to extract.
    */

    part entryTofImuNavigation : VariantOptionRecord {
      attribute :>> optionId = "VAR-NAV-ENTRY-TOF-IMU";
      attribute :>> concern = VariantConcernKind::navigationSensorSuite;
      attribute :>> tierApplicability = ProductTier::entry;
      attribute :>> selectionStatus = VariantSelectionStatus::deferred;
      attribute :>> optionName = "ToF plus IMU navigation";
      attribute :>> selectedModelElementPaths = "ProductVariants::NavigationSensorSuiteChoice::tofImuOnly; TradeStudies::sensorBaseline";
      attribute :>> changedImplementationPaths = "PhysicalArchitecture::SensorAssembly; FirmwareArchitecture::LocalizationTask; FirmwareArchitecture::SlamTask; SoftwareImplementation localization/map records";
      attribute :>> requirementRefs = "limitBomCost; localizeReliably; updateCoverageMap";
      attribute :>> verificationRefs = "Verification::verifyLocalizationPerformance; AnalysisCases::LocalizationPerformanceAnalysis";
      attribute :>> rationaleRef = "TradeStudies::sensorBaseline";
    }

    part premiumLidarNavigation : VariantOptionRecord {
      attribute :>> optionId = "VAR-NAV-PREMIUM-LIDAR";
      attribute :>> concern = VariantConcernKind::navigationSensorSuite;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "ToF plus IMU plus 2D dToF/LiDAR";
      attribute :>> selectedModelElementPaths = "ProductVariants::NavigationSensorSuiteChoice::lidarSlamSuite; PhysicalArchitecture::AutonomousFloorCleaningRobot.sensorAssembly; ElectronicsComponentSelection::electronicsComponentSelectionBaseline.lidarModuleCandidate";
      attribute :>> changedImplementationPaths = "InterfaceControl::lidarScanContract; FirmwareArchitecture::sensorAcquisition; FirmwareArchitecture::localization; FirmwareArchitecture::slam; ElectronicsInterfaceControl::electronicsInterfaceBaseline.lidarUart";
      attribute :>> requirementRefs = "localizeReliably; updateCoverageMap; protectMapPrivacy";
      attribute :>> verificationRefs = "Verification::verifyLocalizationPerformance; Verification::verifyCoverageMapping; Verification::verifyElectricalInterfaceControl";
      attribute :>> rationaleRef = "TradeStudies::sensorLidarUpgrade";
    }

    part flagshipAiVisionNavigation : VariantOptionRecord {
      attribute :>> optionId = "VAR-NAV-FLAGSHIP-AI-VISION";
      attribute :>> concern = VariantConcernKind::navigationSensorSuite;
      attribute :>> tierApplicability = ProductTier::flagship;
      attribute :>> selectionStatus = VariantSelectionStatus::deferred;
      attribute :>> optionName = "LiDAR plus RGB/dual camera plus local AI accelerator plus 3D ToF";
      attribute :>> selectedModelElementPaths = "ProductVariants::NavigationSensorSuiteChoice::aiVisionSuite; PhysicalArchitecture::DeferredVisionObstacleModule; FirmwareArchitecture::deferredObstacleClassification";
      attribute :>> changedImplementationPaths = "Deferred camera/AI electronics, privacy verification, obstacle classification task, additional firmware memory and power budgets";
      attribute :>> requirementRefs = "avoidObstacles; protectMapPrivacy; limitBomCost";
      attribute :>> verificationRefs = "Verification::verifyObstacleAvoidance; Verification::verifyMapPrivacy";
      attribute :>> rationaleRef = "TradeStudies::flagshipAiVisionUpgrade";
    }

    part standardQuietCleaningOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-CLEAN-STANDARD";
      attribute :>> concern = VariantConcernKind::cleaningPerformance;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "standard low-power fan";
      attribute :>> selectedModelElementPaths = "ProductVariants::CleaningPerformanceChoice::standardQuietCleaning; TradeStudies::standardFan";
      attribute :>> changedImplementationPaths = "PhysicalArchitecture::CleaningHeadModule; FirmwareArchitecture::cleaningControl; ElectronicsImplementation cleaning load budget";
      attribute :>> requirementRefs = "keepNoise; cleanAtLeastEighty";
      attribute :>> verificationRefs = "Verification::verifyNoiseLimit; Verification::verifyCleaningCoverage";
      attribute :>> rationaleRef = "TradeStudies::standardFan";
    }

    part highSuctionCleaningOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-CLEAN-HIGH-SUCTION";
      attribute :>> concern = VariantConcernKind::cleaningPerformance;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::deferred;
      attribute :>> optionName = "higher suction fan";
      attribute :>> selectedModelElementPaths = "ProductVariants::CleaningPerformanceChoice::highSuctionCleaning; TradeStudies::highSuctionFan";
      attribute :>> changedImplementationPaths = "Cleaning motor driver current, acoustic verification, power budget, firmware cleaning modes";
      attribute :>> requirementRefs = "keepNoise; cleanAtLeastEighty; limitBomCost";
      attribute :>> verificationRefs = "Verification::verifyNoiseLimit; AnalysisCases::TotalPowerConsumptionAnalysis";
      attribute :>> rationaleRef = "TradeStudies::highSuctionFan";
    }

    part baselineBatteryOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-BATT-4S2P-12500";
      attribute :>> concern = VariantConcernKind::batteryPack;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "4S2P 12500 mAh pack";
      attribute :>> selectedModelElementPaths = "ProductVariants::BatteryPackChoice::pack4s2p12500mAh; PhysicalArchitecture::AutonomousFloorCleaningRobot.powerModule.batteryPack; TradeStudies::battery4s2p";
      attribute :>> changedImplementationPaths = "DesignLimits::batteryCapacityBudget; ElectronicsImplementation::electronicsHandoff.batteryRailBudget; FirmwareArchitecture::batteryManager";
      attribute :>> requirementRefs = "cleanAtLeastEighty; returnToDock; chargeSafely";
      attribute :>> verificationRefs = "Verification::verifyReturnToDock; Verification::verifyChargingSafety; AnalysisCases::MissionEnergyAnalysis";
      attribute :>> rationaleRef = "TradeStudies::battery4s2p";
    }

    part sameMcuSafetyOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-SAFE-SAME-MCU";
      attribute :>> concern = VariantConcernKind::safetyMonitor;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "same-MCU safety supervisor";
      attribute :>> selectedModelElementPaths = "ProductVariants::SafetyMonitorChoice::sameMcuSafetySupervisor; PhysicalArchitecture::AutonomousFloorCleaningRobot.robotFirmware.safetySupervisor; TradeStudies::sameMcuSafetySupervisor";
      attribute :>> changedImplementationPaths = "FirmwareArchitecture::safetySupervisor; SoftwareImplementation::safetySupervisorImplementation; SafetyAnalysis hazard mitigations";
      attribute :>> requirementRefs = "superviseHazards; detectCliffs; detectBinRemovedOrMissing";
      attribute :>> verificationRefs = "Verification::verifyHazardSupervision; Verification::verifyElectricalInterfaceControl";
      attribute :>> rationaleRef = "TradeStudies::sameMcuSafetySupervisor";
    }

    part localPrivacyOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-PRIVACY-LOCAL-ONLY";
      attribute :>> concern = VariantConcernKind::privacyMode;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "local-only privacy default";
      attribute :>> selectedModelElementPaths = "PhysicalArchitecture::AutonomousFloorCleaningRobot.cloudBackupDefaultEnabled; TradeStudies::localOnlyPrivacyDefault";
      attribute :>> changedImplementationPaths = "SoftwareImplementation::appProtocolImplementation; FirmwareArchitecture::storage; InterfaceControl privacy consent fields";
      attribute :>> requirementRefs = "protectMapPrivacy";
      attribute :>> verificationRefs = "Verification::verifyMapPrivacy";
      attribute :>> rationaleRef = "TradeStudies::localOnlyPrivacyDefault";
    }

    part wifiBleLocalAppOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-CONN-WIFI-BLE-LOCAL";
      attribute :>> concern = VariantConcernKind::connectivity;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "Wi-Fi/BLE local app link";
      attribute :>> selectedModelElementPaths = "ProductVariants::ConnectivityChoice::wifiBleLocalApp; ElectronicsComponentSelection::electronicsComponentSelectionBaseline.wirelessModuleCandidate";
      attribute :>> changedImplementationPaths = "ElectronicsInterfaceControl::electronicsInterfaceBaseline.appUart; FirmwareArchitecture::appProtocol; SoftwareImplementation::appProtocolImplementation";
      attribute :>> requirementRefs = "reportCleaningStatus; protectMapPrivacy";
      attribute :>> verificationRefs = "Verification::verifyStatusReporting; Verification::verifyMapPrivacy";
      attribute :>> rationaleRef = "ElectronicsComponentSelection::electronicsComponentSelectionBaseline.wirelessModuleCandidate";
    }

    part beaconChargeDockOption : VariantOptionRecord {
      attribute :>> optionId = "VAR-DOCK-BEACON-CHARGE";
      attribute :>> concern = VariantConcernKind::dockOption;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      attribute :>> optionName = "charging dock with homing beacon";
      attribute :>> selectedModelElementPaths = "ProductVariants::DockChoice::beaconChargeDock; PhysicalArchitecture::AutonomousFloorCleaningRobot.dockInterface";
      attribute :>> changedImplementationPaths = "FunctionalArchitecture::HomeAndDock; PhysicalArchitecture::DockInterfaceModule; FirmwareArchitecture::missionController; ElectronicsInterfaceControl power and GPIO contracts";
      attribute :>> requirementRefs = "returnToDock; chargeSafely";
      attribute :>> verificationRefs = "Verification::verifyReturnToDock; Verification::verifyChargingSafety";
      attribute :>> rationaleRef = "OperationalScenarios::returnToDockAndCharge";
    }
  }

  part def RobotVariantConfigurations {
    part premiumPrivacySlamBaseline : VariantConfiguration {
      attribute :>> configurationId = "SKU-PREMIUM-PRIVACY-SLAM";
      attribute :>> displayName = "Premium privacy-conscious LiDAR SLAM baseline";
      attribute :>> tier = ProductTier::premium;
      attribute :>> selectedOptions = "VAR-NAV-PREMIUM-LIDAR; VAR-CLEAN-STANDARD; VAR-BATT-4S2P-12500; VAR-SAFE-SAME-MCU; VAR-PRIVACY-LOCAL-ONLY; VAR-CONN-WIFI-BLE-LOCAL; VAR-DOCK-BEACON-CHARGE";
      attribute :>> excludedOptions = "VAR-NAV-ENTRY-TOF-IMU; VAR-NAV-FLAGSHIP-AI-VISION; VAR-CLEAN-HIGH-SUCTION";
      attribute :>> implementationImpactSummary = "Use LiDAR UART, sensor I2C, local map storage, standard fan power budget, same-MCU safety supervision, 4S2P pack and beacon charging dock.";
      attribute :>> verificationImpactSummary = "Run localization, coverage mapping, privacy, charging safety, hazard supervision, app status, and electrical interface verification.";
    }

    part entryCostOptimizedCandidate : VariantConfiguration {
      attribute :>> configurationId = "SKU-ENTRY-COST-CANDIDATE";
      attribute :>> displayName = "Entry cost-optimized candidate";
      attribute :>> tier = ProductTier::entry;
      attribute :>> selectedOptions = "VAR-NAV-ENTRY-TOF-IMU; VAR-CLEAN-STANDARD; VAR-SAFE-SAME-MCU; VAR-PRIVACY-LOCAL-ONLY; VAR-DOCK-BEACON-CHARGE";
      attribute :>> excludedOptions = "VAR-NAV-PREMIUM-LIDAR; VAR-NAV-FLAGSHIP-AI-VISION; VAR-CLEAN-HIGH-SUCTION";
      attribute :>> implementationImpactSummary = "Remove LiDAR UART and SLAM scan matching path; retain lower-cost localization candidate only if localization and coverage requirements are relaxed or reallocated.";
      attribute :>> verificationImpactSummary = "Requires localization and coverage re-verification; current requirement set does not accept this as the baseline.";
    }

    part flagshipAiVisionCandidate : VariantConfiguration {
      attribute :>> configurationId = "SKU-FLAGSHIP-AI-VISION-CANDIDATE";
      attribute :>> displayName = "Flagship AI vision candidate";
      attribute :>> tier = ProductTier::flagship;
      attribute :>> selectedOptions = "VAR-NAV-FLAGSHIP-AI-VISION; VAR-CLEAN-HIGH-SUCTION; VAR-BATT-4S2P-12500; VAR-PRIVACY-LOCAL-ONLY";
      attribute :>> excludedOptions = "VAR-NAV-ENTRY-TOF-IMU";
      attribute :>> implementationImpactSummary = "Adds camera/AI accelerator electronics, obstacle-classification firmware, higher power and stronger privacy handling.";
      attribute :>> verificationImpactSummary = "Requires additional privacy, AI obstacle recognition, thermal, EMC, battery runtime and acoustic verification before baseline selection.";
    }
  }

  part robotVariantCatalog : RobotVariantCatalog;
  part robotVariantConfigurations : RobotVariantConfigurations;
}
