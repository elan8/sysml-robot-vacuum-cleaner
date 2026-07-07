/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Defines the lightweight Strata CPS modeling method layer. Native SysML v2
 * elements remain the engineering source of truth; these method concepts add
 * ownership, maturity, extractability, and handoff intent for tools.
 */
package Strata {
  private import ScalarValues::*;

  enum def ModelLayerKind {
    method;
    requirements;
    context;
    architecture;
    behavior;
    implementation;
    verification;
    analysis;
    views;
    root;
  }

  enum def DisciplineKind {
    systems;
    software;
    electronics;
    mechanical;
    safety;
    verification;
    manufacturing;
    product;
  }

  enum def MaturityKind {
    draft;
    candidate;
    baseline;
    verified;
    released;
    deprecated;
  }

  enum def ArtifactKind {
    requirementSet;
    contextBoundary;
    functionalArchitecture;
    physicalArchitecture;
    interfaceControl;
    softwareRuntimeArchitecture;
    softwareImplementationHandoff;
    electronicsInterfaceControl;
    electronicsImplementationHandoff;
    componentSelection;
    verificationPlan;
    analysisEvidence;
    stakeholderView;
  }

  enum def TraceRoleKind {
    sourceOfTruth;
    derivedView;
    implementationHandoff;
    verificationEvidence;
    externalReference;
  }

  enum def CompletionExpectationKind {
    required;
    recommended;
    optional;
    deferred;
  }

  metadata def ModelLayer {
    attribute layer : ModelLayerKind;
    attribute description : String;
  }

  metadata def EngineeringOwnership {
    attribute discipline : DisciplineKind;
    attribute ownerRole : String;
    attribute reviewRole : String;
  }

  metadata def LifecycleStatus {
    attribute maturity : MaturityKind;
    attribute rationale : String;
  }

  metadata def ExtractableArtifact {
    attribute artifactKind : ArtifactKind;
    attribute extractionId : String;
    attribute displayName : String;
  }

  metadata def TraceRole {
    attribute role : TraceRoleKind;
    attribute authoritativeSourcePath : String;
  }

  metadata def ExternalReference {
    attribute externalSystem : String;
    attribute externalId : String;
    attribute externalUrl : String;
  }

  part def MethodCompletenessRule {
    attribute ruleId : String;
    attribute appliesToArtifact : ArtifactKind;
    attribute expectation : CompletionExpectationKind;
    attribute requiredFact : String;
    attribute validationHint : String;
  }

  part def MethodExtractionRule {
    attribute ruleId : String;
    attribute artifactKind : ArtifactKind;
    attribute sourcePackage : String;
    attribute primaryElementKind : String;
    attribute joinHint : String;
    attribute outputIntent : String;
  }

  part def StrataMethodBaseline {
    doc /*
      Method baseline for cyber-physical and software-only systems. Use native
      SysML v2 requirements, parts, ports, actions, allocations, cases, and views
      for engineering semantics. Use Strata metadata to classify ownership,
      lifecycle maturity, extractable artifacts, trace roles, and external tool
      references in a stable way for automation.
    */

    part requirementTraceCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-REQ-TRACE-001";
      attribute :>> appliesToArtifact = ArtifactKind::requirementSet;
      attribute :>> expectation = CompletionExpectationKind::required;
      attribute :>> requiredFact = "Each system requirement has a subject, a testable required condition, a satisfaction path, and verification or analysis evidence intent.";
      attribute :>> validationHint = "Find requirement usages in requirements packages and report missing subject, satisfy, verify, or analysis references.";
    }

    part interfaceContractCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-ICD-001";
      attribute :>> appliesToArtifact = ArtifactKind::interfaceControl;
      attribute :>> expectation = CompletionExpectationKind::required;
      attribute :>> requiredFact = "Each interface contract identifies producer/consumer ownership, payload or signal semantics, timing, safety relevance, and physical or logical endpoints.";
      attribute :>> validationHint = "Extract interface-control records and report missing endpoint, payload/signal, timing, or safety fields.";
    }

    part softwareHandoffCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-SW-HANDOFF-001";
      attribute :>> appliesToArtifact = ArtifactKind::softwareImplementationHandoff;
      attribute :>> expectation = CompletionExpectationKind::required;
      attribute :>> requiredFact = "Each software task has runtime timing, startup phase, owned state, error policy, resource budgets, message contracts, HAL bindings, requirements, verification refs, and test intent.";
      attribute :>> validationHint = "Join SoftwareImplementationRecord.taskPath with FirmwareTask usages and related InterfaceControl, QueueContract, HalBinding, and verification refs.";
    }

    part electronicsHandoffCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-EE-HANDOFF-001";
      attribute :>> appliesToArtifact = ArtifactKind::electronicsImplementationHandoff;
      attribute :>> expectation = CompletionExpectationKind::required;
      attribute :>> requiredFact = "Each electronics work package has owning board/harness, interface contracts, rail budgets, layout constraints, component candidates, and verification refs.";
      attribute :>> validationHint = "Join ElectronicsWorkPackage records with ElectronicsInterfaceContract, RailBudgetRecord, and ComponentCandidate usages.";
    }

    part componentSelectionCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-COMP-001";
      attribute :>> appliesToArtifact = ArtifactKind::componentSelection;
      attribute :>> expectation = CompletionExpectationKind::recommended;
      attribute :>> requiredFact = "Each selected component candidate has manufacturer, MPN, package, footprint, critical specs, cost target, selection status, lifecycle/compliance status, and datasheet review status.";
      attribute :>> validationHint = "Extract ComponentCandidate usages and flag candidates with unknown datasheet, lifecycle, compliance, or availability status.";
    }

    part softwareHandoffExtraction : MethodExtractionRule {
      attribute :>> ruleId = "E8-CPS-EXTRACT-SW-001";
      attribute :>> artifactKind = ArtifactKind::softwareImplementationHandoff;
      attribute :>> sourcePackage = "Implementation, FirmwareArchitecture, InterfaceControl, SoftwareImplementation";
      attribute :>> primaryElementKind = "SoftwareImplementationRecord";
      attribute :>> joinHint = "Group by taskPath; join runtime facts from FirmwareTask, message facts from DataFlowContract and MessageFieldRule, queue facts from QueueContract, and driver facts from HalBinding.";
      attribute :>> outputIntent = "Generate engineer-facing software task cards, queue tables, HAL driver cards, and verification checklists.";
    }

    part electronicsHandoffExtraction : MethodExtractionRule {
      attribute :>> ruleId = "E8-CPS-EXTRACT-EE-001";
      attribute :>> artifactKind = ArtifactKind::electronicsImplementationHandoff;
      attribute :>> sourcePackage = "Implementation, ElectronicsInterfaceControl, ElectronicsImplementation, ElectronicsComponentSelection";
      attribute :>> primaryElementKind = "ElectronicsWorkPackage";
      attribute :>> joinHint = "Group by owningBoardOrHarness; join interfaceContractRefs, railFeaturePath, relatedContractRefs, workPackageRefs, and verification refs.";
      attribute :>> outputIntent = "Generate electronics work-package cards, connector/rail tables, and component-candidate sheets.";
    }
  }

  part strataMethodBaseline : StrataMethodBaseline;
}
