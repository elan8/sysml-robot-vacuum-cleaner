/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Owns the implementation-layer hub for software engineers and extraction
 * tools. It composes the implementation story from software and electronics
 * handoff packages without redefining their primary facts.
 */
package Implementation {
  public import InterfaceControl::*;
  public import FirmwareArchitecture::*;
  public import SoftwareImplementation::*;
  public import ElectronicsInterfaceControl::*;
  public import ElectronicsImplementation::*;
  public import ElectronicsVerification::*;
  private import Views::*;
  private import ScalarValues::*;

  enum def ImplementationConcernKind {
    messageContract;
    taskRuntime;
    softwareImplementationRecord;
    queuePolicy;
    halBinding;
    electricalInterface;
    electronicsWorkPackage;
    railBudget;
    electronicsBringUp;
    crossDisciplineIntegration;
    verificationScope;
  }

  part def ImplementationTraceRecord {
    attribute concern : ImplementationConcernKind;
    attribute sourceElementPath : String;
    attribute relatedElementPaths : String;
    attribute engineerQuestionAnswered : String;
    attribute extractionHint : String;
  }

  part def ImplementationBaseline {
    doc /*
      Single implementation entry point. Read this package first when generating
      embedded-software implementation records, electronics work packages, interface-control
      reports, HAL/driver records, or verification checklists. The source
      packages remain authoritative: InterfaceControl owns payload contracts,
      FirmwareArchitecture owns task timing and flows, SoftwareImplementation
      owns software handoff details, ElectronicsInterfaceControl owns electrical
      contracts, ElectronicsImplementation owns PCB/harness work packages, and
      ElectronicsVerification owns electronics bring-up intent.
    */

    attribute interfaceControlPackage = "InterfaceControl";
    attribute firmwareArchitecturePackage = "FirmwareArchitecture";
    attribute softwareImplementationPackage = "SoftwareImplementation";
    attribute electronicsInterfaceControlPackage = "ElectronicsInterfaceControl";
    attribute electronicsImplementationPackage = "ElectronicsImplementation";
    attribute electronicsVerificationPackage = "ElectronicsVerification";
    attribute authoritativeRuntimeInstance = "FirmwareArchitecture::firmwareTaskArchitecture";
    attribute authoritativeSoftwareHandoffInstance = "SoftwareImplementation::softwareHandoff";
    attribute authoritativeElectronicsHandoffInstance = "ElectronicsImplementation::electronicsHandoff";
    attribute authoritativeElectronicsInterfaceBaseline = "ElectronicsInterfaceControl::electronicsInterfaceBaseline";

    part contractStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::messageContract;
      attribute :>> sourceElementPath = "InterfaceControl::DataFlowContract and FirmwareArchitecture::firmwareTaskArchitecture.*Contract";
      attribute :>> relatedElementPaths = "FirmwareArchitecture task run input/output item features; SoftwareImplementation message field rules and queue contracts";
      attribute :>> engineerQuestionAnswered = "Welke berichten bestaan, wie produceert ze, wie consumeert ze, wat is de latency en welke veldregels gelden?";
      attribute :>> extractionHint = "Extract DataFlowContract usages, then join on producerFeature, consumerFeature, payloadType and matching MessageFieldRule.messageType.";
    }

    part runtimeStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::taskRuntime;
      attribute :>> sourceElementPath = "FirmwareArchitecture::FirmwareTaskArchitecture";
      attribute :>> relatedElementPaths = "SoftwareImplementation::SoftwareImplementationRecord.taskPath; SystemRequirements and Verification refs in implementation records";
      attribute :>> engineerQuestionAnswered = "Welke taken draaien er, met welke periode/deadline, welke flows verbinden ze, en wat moet de scheduler garanderen?";
      attribute :>> extractionHint = "Extract FirmwareTask parts and their period, deadline, criticality, startupPhase, stateOwnedByTask, errorHandling, resource budgets, run parameters, flows and scheduler overload policy.";
    }

    part softwareImplementationRecordStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::softwareImplementationRecord;
      attribute :>> sourceElementPath = "SoftwareImplementation::softwareHandoff.*Implementation";
      attribute :>> relatedElementPaths = "FirmwareArchitecture task paths; PhysicalArchitecture firmware modules; Verification cases";
      attribute :>> engineerQuestionAnswered = "Welke requirements, verificaties, verantwoordelijkheden, algoritmen en testintentie horen bij elke firmwaretaak?";
      attribute :>> extractionHint = "Extract SoftwareImplementationRecord usages and group by taskPath and owningModulePath; get runtime/resource facts from the referenced FirmwareTask.";
    }

    part queueStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::queuePolicy;
      attribute :>> sourceElementPath = "SoftwareImplementation::softwareHandoff.*Queue";
      attribute :>> relatedElementPaths = "FirmwareArchitecture flows and InterfaceControl payload items";
      attribute :>> engineerQuestionAnswered = "Welke queues zijn nodig, hoe diep zijn ze, wat gebeurt er bij overflow en hoe oud mag data worden?";
      attribute :>> extractionHint = "Extract QueueContract usages and join payloadType with item definitions and DataFlowContract.payloadType.";
    }

    part halStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::halBinding;
      attribute :>> sourceElementPath = "SoftwareImplementation::softwareHandoff.*Hal";
      attribute :>> relatedElementPaths = "PhysicalArchitecture harnesses and MCU features; FirmwareArchitecture task paths";
      attribute :>> engineerQuestionAnswered = "Welke drivers moet software leveren, welke taak gebruikt ze, welke fysieke feature is gebonden en wat is de fault policy?";
      attribute :>> extractionHint = "Extract HalBinding usages and join taskPath with SoftwareImplementationRecord.taskPath.";
    }

    part electricalInterfaceStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::electricalInterface;
      attribute :>> sourceElementPath = "ElectronicsInterfaceControl::electronicsInterfaceBaseline.*";
      attribute :>> relatedElementPaths = "PhysicalArchitecture ports and harnesses; ElectronicsImplementation work packages";
      attribute :>> engineerQuestionAnswered = "Welke connectoren, rails, signalen, voltage/current limits, bus rates, pinlists en testpunten horen bij elke elektrische interface?";
      attribute :>> extractionHint = "Extract ElectronicsInterfaceContract usages and join connectorRef/contractId with ElectronicsWorkPackage.interfaceContractRefs.";
    }

    part electronicsWorkPackageStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::electronicsWorkPackage;
      attribute :>> sourceElementPath = "ElectronicsImplementation::electronicsHandoff.*Work";
      attribute :>> relatedElementPaths = "PhysicalArchitecture features; ElectronicsInterfaceControl contracts; ElectronicsVerification plan";
      attribute :>> engineerQuestionAnswered = "Welke schematic sheets, layout constraints, BOM keuzes, testpunten, bring-up acties en manufacturing notes horen bij PCB/harness werk?";
      attribute :>> extractionHint = "Extract ElectronicsWorkPackage usages and group by owningBoardOrHarness, pcbDomain and implementationStatus.";
    }

    part railBudgetStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::railBudget;
      attribute :>> sourceElementPath = "ElectronicsImplementation::electronicsHandoff.*RailBudget";
      attribute :>> relatedElementPaths = "PhysicalArchitecture powerModule rails and loads; ElectronicsInterfaceControl power contracts";
      attribute :>> engineerQuestionAnswered = "Welke rails bestaan, wat zijn nominale spanning, continue/peak current, protection en meetpunten?";
      attribute :>> extractionHint = "Extract RailBudgetRecord usages and compare loadFeaturePaths against PhysicalArchitecture power connections.";
    }

    part electronicsBringUpStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::electronicsBringUp;
      attribute :>> sourceElementPath = "ElectronicsVerification::electronicsVerificationPlan.*";
      attribute :>> relatedElementPaths = "ElectronicsInterfaceControl contract IDs; ElectronicsImplementation work package IDs";
      attribute :>> engineerQuestionAnswered = "Welke bench, fault-injection en manufacturing tests moeten de electronics engineer uitvoeren en welk bewijs hoort daarbij?";
      attribute :>> extractionHint = "Extract ElectronicsVerificationStep usages and join relatedContractRefs to ElectronicsInterfaceContract.contractId.";
    }

    part crossDisciplineIntegrationStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::crossDisciplineIntegration;
      attribute :>> sourceElementPath = "Implementation::implementationBaseline";
      attribute :>> relatedElementPaths = "SoftwareImplementation HalBinding.physicalFeaturePath; ElectronicsInterfaceControl physicalFeaturePath; FirmwareArchitecture task flows";
      attribute :>> engineerQuestionAnswered = "Waar raken software drivers, firmware taken, PCB interfaces en harness constraints elkaar?";
      attribute :>> extractionHint = "Join HalBinding.physicalFeaturePath with ElectronicsInterfaceContract physical/mating paths; report unmatched paths as integration gaps.";
    }

    part verificationStory : ImplementationTraceRecord {
      attribute :>> concern = ImplementationConcernKind::verificationScope;
      attribute :>> sourceElementPath = "SoftwareImplementation::SoftwareImplementationRecord.verificationRefs";
      attribute :>> relatedElementPaths = "Verification cases, SystemRequirements, DataFlowContract usages, QueueContract usages";
      attribute :>> engineerQuestionAnswered = "Welke requirements en verificaties moeten per softwaretaak aantoonbaar worden afgedekt?";
      attribute :>> extractionHint = "Extract requirementRefs and verificationRefs from implementation records; report unresolved names as model hygiene findings.";
    }
  }

  part implementationBaseline : ImplementationBaseline;

  view softwareEngineerImplementationHandoff : GeneralView {
    expose Implementation::implementationBaseline;
    expose InterfaceControl::*;
    expose FirmwareArchitecture::firmwareTaskArchitecture;
    expose SoftwareImplementation::softwareHandoff;
    filter @SysML::PartUsage or @SysML::ConnectionUsage or @SysML::ItemDefinition;
  }

  view electronicsEngineerImplementationHandoff : GeneralView {
    expose Implementation::implementationBaseline;
    expose ElectronicsInterfaceControl::electronicsInterfaceBaseline;
    expose ElectronicsImplementation::electronicsHandoff;
    expose ElectronicsVerification::electronicsVerificationPlan;
    filter @SysML::PartUsage;
  }

  view implementationTraceability : GeneralView {
    expose Implementation::implementationBaseline;
    expose FirmwareArchitecture::*;
    expose SoftwareImplementation::*;
    expose ElectronicsInterfaceControl::*;
    expose ElectronicsImplementation::*;
    expose ElectronicsVerification::*;
    filter @SysML::PartUsage or @SysML::ConnectionUsage;
  }

  view crossDisciplineImplementationIntegration : GeneralView {
    expose Implementation::implementationBaseline;
    expose SoftwareImplementation::softwareHandoff;
    expose ElectronicsInterfaceControl::electronicsInterfaceBaseline;
    expose ElectronicsImplementation::electronicsHandoff;
    expose FirmwareArchitecture::firmwareTaskArchitecture;
    filter @SysML::PartUsage or @SysML::ConnectionUsage;
  }
}
