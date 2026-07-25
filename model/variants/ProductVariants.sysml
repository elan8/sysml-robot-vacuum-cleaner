/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns native product-line variation points, semantic option usages, and
 * configured product baselines. Internal model identity is expressed with
 * references; only external configuration identifiers remain textual.
 */
package ProductVariants {
  private import ScalarValues::*;
  private import SystemRequirements::*;
  private import PhysicalArchitecture::*;
  private import FirmwareArchitecture::*;
  private import ElectronicsComponentSelection::*;
  private import Verification::*;
  private import AnalysisCases::*;
  private import TradeStudies::*;

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
    navigationSensorSuite;
    cleaningPerformance;
    batteryPack;
    safetyMonitor;
    connectivity;
    privacyMode;
    dockOption;
  }

  part def VariantOption {
    attribute optionId : String;
    attribute concern : VariantConcernKind;
    attribute tierApplicability : ProductTier;
    attribute selectionStatus : VariantSelectionStatus;
  }

  part def VariantConfiguration {
    attribute configurationId : String;
    attribute tier : ProductTier;
  }

  connection def ConfigurationSelection {
    end configuration : VariantConfiguration;
    end selectedOption : VariantOption;
  }

  connection def ConfigurationExclusion {
    end configuration : VariantConfiguration;
    end excludedOption : VariantOption;
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
      Semantic option catalog. Each option references its native SysML variant,
      realized design elements, requirements, verification or analysis evidence,
      and trade rationale without encoding model paths in strings.
    */

    part entryTofImuNavigation : VariantOption {
      attribute :>> optionId = "VAR-NAV-ENTRY-TOF-IMU";
      attribute :>> concern = VariantConcernKind::navigationSensorSuite;
      attribute :>> tierApplicability = ProductTier::entry;
      attribute :>> selectionStatus = VariantSelectionStatus::deferred;
      ref selectedChoice = NavigationSensorSuiteChoice::tofImuOnly;
      ref sensorDesign = AutonomousFloorCleaningRobot::sensorAssembly;
      ref localizationTask = FirmwareTaskArchitecture::localization;
      ref slamTask = FirmwareTaskArchitecture::slam;
      ref costRequirement = limitBomCost;
      ref localizationRequirement = localizeReliably;
      ref mapRequirement = updateCoverageMap;
      ref localizationEvidence = verifyLocalizationAccuracy;
      ref performanceAnalysis = LocalizationPerformanceAnalysis;
      ref rationale = sensorBaseline;
      doc /*
        Low-cost ToF plus IMU option for simple reference layouts. It remains
        deferred because the present analysis does not satisfy the premium
        room-scale localization target.
      */
    }

    part premiumLidarNavigation : VariantOption {
      attribute :>> optionId = "VAR-NAV-PREMIUM-LIDAR";
      attribute :>> concern = VariantConcernKind::navigationSensorSuite;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref selectedChoice = NavigationSensorSuiteChoice::lidarSlamSuite;
      ref sensorDesign = AutonomousFloorCleaningRobot::sensorAssembly;
      ref componentCandidate =
        ElectronicsComponentSelection::electronicsComponentSelectionBaseline.lidarModuleCandidate;
      ref localizationRequirement = localizeReliably;
      ref mapRequirement = updateCoverageMap;
      ref privacyRequirement = protectMapPrivacy;
      ref localizationEvidence = verifyLocalizationAccuracy;
      ref mappingEvidence = verifyCoverageMap;
      ref interfaceEvidence = verifyElectricalInterfaceControl;
      ref performanceAnalysis = LocalizationPerformanceAnalysis;
      ref rationale = sensorLidarUpgrade;
      doc /*
        Selected premium LiDAR SLAM option. It activates the LiDAR UART,
        acquisition, localization, SLAM, and mapping paths while preserving
        local-first map privacy.
      */
    }

    part flagshipAiVisionNavigation : VariantOption {
      attribute :>> optionId = "VAR-NAV-FLAGSHIP-AI-VISION";
      attribute :>> concern = VariantConcernKind::navigationSensorSuite;
      attribute :>> tierApplicability = ProductTier::flagship;
      attribute :>> selectionStatus = VariantSelectionStatus::deferred;
      ref selectedChoice = NavigationSensorSuiteChoice::aiVisionSuite;
      ref visionDesign = DeferredVisionObstacleModule;
      ref classificationTask = FirmwareTaskArchitecture::deferredObstacleClassification;
      ref obstacleRequirement = avoidObstacles;
      ref privacyRequirement = protectMapPrivacy;
      ref costRequirement = limitBomCost;
      ref obstacleEvidence = verifyObstacleAvoidance;
      ref privacyEvidence = verifyPrivacyControls;
      ref rationale = flagshipAiVisionUpgrade;
      doc /*
        Deferred camera and local-AI option. Selection requires additional
        compute, power, privacy, thermal, EMC, and recognition evidence.
      */
    }

    part standardQuietCleaningOption : VariantOption {
      attribute :>> optionId = "VAR-CLEAN-STANDARD";
      attribute :>> concern = VariantConcernKind::cleaningPerformance;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref selectedChoice = CleaningPerformanceChoice::standardQuietCleaning;
      ref cleaningDesign = AutonomousFloorCleaningRobot::cleaningHead;
      ref cleaningTask = FirmwareTaskArchitecture::cleaningControl;
      ref noiseRequirement = keepNoise;
      ref areaRequirement = cleanAtLeastEighty;
      ref noiseEvidence = verifyNoiseLevel;
      ref coverageEvidence = verifyCleaningCoverage;
      ref rationale = standardFan;
    }

    part highSuctionCleaningOption : VariantOption {
      attribute :>> optionId = "VAR-CLEAN-HIGH-SUCTION";
      attribute :>> concern = VariantConcernKind::cleaningPerformance;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::deferred;
      ref selectedChoice = CleaningPerformanceChoice::highSuctionCleaning;
      ref cleaningDesign = AutonomousFloorCleaningRobot::cleaningHead;
      ref noiseRequirement = keepNoise;
      ref areaRequirement = cleanAtLeastEighty;
      ref costRequirement = limitBomCost;
      ref noiseEvidence = verifyNoiseLevel;
      ref powerAnalysis = TotalPowerConsumptionAnalysis;
      ref rationale = highSuctionFan;
    }

    part baselineBatteryOption : VariantOption {
      attribute :>> optionId = "VAR-BATT-4S2P-12500";
      attribute :>> concern = VariantConcernKind::batteryPack;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref selectedChoice = BatteryPackChoice::pack4s2p12500mAh;
      ref batteryDesign = AutonomousFloorCleaningRobot::powerModule.batteryPack;
      ref railBudget = AutonomousFloorCleaningRobot::batteryRailBudget;
      ref batteryTask = FirmwareTaskArchitecture::batteryManager;
      ref areaRequirement = cleanAtLeastEighty;
      ref dockingRequirement = returnToDock;
      ref chargingRequirement = chargeSafely;
      ref dockingEvidence = verifyDockingSuccess;
      ref chargingEvidence = verifySafeCharging;
      ref energyAnalysis = MissionEnergyAnalysis;
      ref rationale = battery4s2p;
    }

    part sameMcuSafetyOption : VariantOption {
      attribute :>> optionId = "VAR-SAFE-SAME-MCU";
      attribute :>> concern = VariantConcernKind::safetyMonitor;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref selectedChoice = SafetyMonitorChoice::sameMcuSafetySupervisor;
      ref safetyDesign = AutonomousFloorCleaningRobot::robotFirmware.safetySupervisor;
      ref safetyTask = FirmwareTaskArchitecture::safetySupervisor;
      ref hazardRequirement = superviseHazards;
      ref cliffRequirement = detectCliffs;
      ref binRequirement = detectBinRemovedOrMissing;
      ref safetyEvidence = verifySafetySupervisorImplementation;
      ref interfaceEvidence = verifyElectricalInterfaceControl;
      ref rationale = sameMcuSafetySupervisor;
    }

    part localPrivacyOption : VariantOption {
      attribute :>> optionId = "VAR-PRIVACY-LOCAL-ONLY";
      attribute :>> concern = VariantConcernKind::privacyMode;
      attribute :>> tierApplicability = ProductTier::premium;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref robotSetting = AutonomousFloorCleaningRobot::cloudBackupDefaultEnabled;
      ref appTask = FirmwareTaskArchitecture::appProtocol;
      ref storageTask = FirmwareTaskArchitecture::storage;
      ref privacyRequirement = protectMapPrivacy;
      ref privacyEvidence = verifyPrivacyControls;
      ref rationale = localOnlyPrivacyDefault;
    }

    part wifiBleLocalAppOption : VariantOption {
      attribute :>> optionId = "VAR-CONN-WIFI-BLE-LOCAL";
      attribute :>> concern = VariantConcernKind::connectivity;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref selectedChoice = ConnectivityChoice::wifiBleLocalApp;
      ref componentCandidate =
        ElectronicsComponentSelection::electronicsComponentSelectionBaseline.wirelessModuleCandidate;
      ref appTask = FirmwareTaskArchitecture::appProtocol;
      ref statusRequirement = reportCleaningStatus;
      ref privacyRequirement = protectMapPrivacy;
      ref protocolEvidence = verifyProtocolContracts;
      ref privacyEvidence = verifyPrivacyControls;
    }

    part beaconChargeDockOption : VariantOption {
      attribute :>> optionId = "VAR-DOCK-BEACON-CHARGE";
      attribute :>> concern = VariantConcernKind::dockOption;
      attribute :>> tierApplicability = ProductTier::standard;
      attribute :>> selectionStatus = VariantSelectionStatus::selectedBaseline;
      ref selectedChoice = DockChoice::beaconChargeDock;
      ref dockDesign = AutonomousFloorCleaningRobot::dockInterface;
      ref missionTask = FirmwareTaskArchitecture::missionController;
      ref dockingRequirement = returnToDock;
      ref chargingRequirement = chargeSafely;
      ref dockingEvidence = verifyDockingSuccess;
      ref chargingEvidence = verifySafeCharging;
    }
  }

  part def RobotVariantConfigurations {
    part premiumPrivacySlamBaseline : VariantConfiguration {
      attribute :>> configurationId = "SKU-PREMIUM-PRIVACY-SLAM";
      attribute :>> tier = ProductTier::premium;
      doc /*
        Released demonstration baseline: LiDAR SLAM, standard quiet cleaning,
        4S2P battery, same-MCU safety supervision, local-first privacy,
        Wi-Fi/BLE local app connectivity, and beacon charging dock.
      */
    }

    part entryCostOptimizedCandidate : VariantConfiguration {
      attribute :>> configurationId = "SKU-ENTRY-COST-CANDIDATE";
      attribute :>> tier = ProductTier::entry;
      doc /*
        Cost candidate only. The current localization and coverage requirements
        prevent baseline selection until its performance is improved or the
        affected requirements are deliberately changed.
      */
    }

    part flagshipAiVisionCandidate : VariantConfiguration {
      attribute :>> configurationId = "SKU-FLAGSHIP-AI-VISION-CANDIDATE";
      attribute :>> tier = ProductTier::flagship;
      doc /*
        Flagship candidate. Additional privacy, recognition, thermal, EMC,
        runtime, acoustic, and cost evidence is mandatory before selection.
      */
    }
  }

  part robotVariantCatalog : RobotVariantCatalog;
  part robotVariantConfigurations : RobotVariantConfigurations;

  connection premiumNavigationSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.premiumLidarNavigation;
  connection premiumCleaningSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.standardQuietCleaningOption;
  connection premiumBatterySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.baselineBatteryOption;
  connection premiumSafetySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.sameMcuSafetyOption;
  connection premiumPrivacySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.localPrivacyOption;
  connection premiumConnectivitySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.wifiBleLocalAppOption;
  connection premiumDockSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.premiumPrivacySlamBaseline
    to selectedOption ::> robotVariantCatalog.beaconChargeDockOption;

  connection entryNavigationSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to selectedOption ::> robotVariantCatalog.entryTofImuNavigation;
  connection entryCleaningSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to selectedOption ::> robotVariantCatalog.standardQuietCleaningOption;
  connection entrySafetySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to selectedOption ::> robotVariantCatalog.sameMcuSafetyOption;
  connection entryPrivacySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to selectedOption ::> robotVariantCatalog.localPrivacyOption;
  connection entryDockSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to selectedOption ::> robotVariantCatalog.beaconChargeDockOption;
  connection entryPremiumNavigationExclusion : ConfigurationExclusion
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to excludedOption ::> robotVariantCatalog.premiumLidarNavigation;
  connection entryVisionNavigationExclusion : ConfigurationExclusion
    connect configuration ::>
      robotVariantConfigurations.entryCostOptimizedCandidate
    to excludedOption ::> robotVariantCatalog.flagshipAiVisionNavigation;

  connection flagshipNavigationSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.flagshipAiVisionCandidate
    to selectedOption ::> robotVariantCatalog.flagshipAiVisionNavigation;
  connection flagshipCleaningSelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.flagshipAiVisionCandidate
    to selectedOption ::> robotVariantCatalog.highSuctionCleaningOption;
  connection flagshipBatterySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.flagshipAiVisionCandidate
    to selectedOption ::> robotVariantCatalog.baselineBatteryOption;
  connection flagshipPrivacySelection : ConfigurationSelection
    connect configuration ::>
      robotVariantConfigurations.flagshipAiVisionCandidate
    to selectedOption ::> robotVariantCatalog.localPrivacyOption;
  connection flagshipEntryNavigationExclusion : ConfigurationExclusion
    connect configuration ::>
      robotVariantConfigurations.flagshipAiVisionCandidate
    to excludedOption ::> robotVariantCatalog.entryTofImuNavigation;

}
