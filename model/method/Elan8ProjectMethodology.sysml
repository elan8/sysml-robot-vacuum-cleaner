/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Binds the reusable Elan8 methodology rules to this project's authoritative
 * semantic elements. This package depends on the project graph; engineering
 * packages depend only on the reusable Elan8Methodology metadata library.
 */
package Elan8ProjectMethodology {
  private import Elan8Methodology::*;
  private import Implementation::*;
  private import FirmwareArchitecture::*;
  private import InterfaceControl::*;
  private import PhysicalArchitecture::*;
  private import ElectronicsInterfaceControl::*;
  private import ElectronicsComponentSelection::*;
  private import Verification::*;
  private import ProductVariants::*;
  private import SafetyAnalysis::*;
  private import OperationalScenarios::*;

  part def ProjectMethodBinding {
    attribute bindingId : String;
  }

  part softwareImplementationBinding : ProjectMethodBinding {
    attribute :>> bindingId = "E8-BIND-SW-IMPLEMENTATION";
    ref methodRule =
      elan8MethodologyBaseline.softwareHandoffExtraction;
    ref runtimeView = Implementation::softwareRuntimeHandoff;
    ref peripheralView = Implementation::peripheralAccessHandoff;
    ref taskArchitecture =
      PhysicalArchitecture::AutonomousFloorCleaningRobot::firmwareTasks;
    ref queueArchitecture = FirmwareArchitecture::FirmwareTaskArchitecture;
    ref dataContractDefinition = InterfaceControl::DataFlowContract;
    ref missionVerification = Verification::verifyMissionControllerImplementation;
    ref safetyVerification = Verification::verifySafetySupervisorImplementation;
  }

  part electronicsImplementationBinding : ProjectMethodBinding {
    attribute :>> bindingId = "E8-BIND-EE-IMPLEMENTATION";
    ref methodRule =
      elan8MethodologyBaseline.electronicsHandoffExtraction;
    ref interfaceView = Implementation::electronicsInterfaceHandoff;
    ref railView = Implementation::railBudgetHandoff;
    ref componentView = Implementation::componentSelectionHandoff;
    ref robotElectronics =
      PhysicalArchitecture::AutonomousFloorCleaningRobot::mainElectronics;
    ref interfaceMetadata = ElectronicsInterfaceControl::ElectricalInterfaceInfo;
    ref componentBaseline =
      ElectronicsComponentSelection::electronicsComponentSelectionBaseline;
    ref interfaceVerification = Verification::verifyElectricalInterfaceControl;
  }

  part assuranceBinding : ProjectMethodBinding {
    attribute :>> bindingId = "E8-BIND-ASSURANCE";
    ref configuredBaseline =
      ProductVariants::robotVariantConfigurations.premiumPrivacySlamBaseline;
    ref safetyGraph = SafetyAnalysis::cliffSensingMitigation;
    ref goldenThread = OperationalScenarios::cliffSafeStopGoldenThread;
    ref verificationEvidence = Verification::cliffSafeStopEvidence;
  }
}
