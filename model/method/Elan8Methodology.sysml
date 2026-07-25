/*
 * SPDX-FileCopyrightText: 2026 Elan8
 * SPDX-License-Identifier: MIT
 *
 * Defines the lightweight Elan8 methodology layer. Native SysML v2
 * elements remain the engineering source of truth; these method concepts add
 * ownership, maturity, extractability, and handoff intent for tools.
 */
package Elan8Methodology {
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

  enum def ImplementationReadinessKind {
    readyForSchematic;
    needsComponentSelection;
    needsLayoutDetail;
    needsSafetyReview;
    deferred;
  }

  enum def ImplementationDomainKind {
    powerEntry;
    motorDrive;
    sensing;
    compute;
    wireless;
    charging;
    safetyMonitor;
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
  }

  metadata def ExternalReference {
    attribute externalSystem : String;
    attribute externalId : String;
    attribute externalUrl : String;
  }

  metadata def ImplementationHandoff {
    attribute artifactId : String;
    attribute readiness : ImplementationReadinessKind;
    attribute domain : ImplementationDomainKind;
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
  }

  part def Elan8MethodologyBaseline {
    doc /*
      Method baseline for cyber-physical and software-only systems. Use native
      SysML v2 requirements, parts, ports, actions, allocations, cases, and views
      for engineering semantics. Use Elan8 methodology metadata to classify ownership,
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
      attribute :>> validationHint = "Traverse typed interface usages and report missing endpoint, payload or signal semantics, timing, or safety metadata.";
    }

    part softwareHandoffCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-SW-HANDOFF-001";
      attribute :>> appliesToArtifact = ArtifactKind::softwareImplementationHandoff;
      attribute :>> expectation = CompletionExpectationKind::required;
      attribute :>> requiredFact = "Each software task has typed runtime flows, timing, startup phase, resource budgets, queue paths, peripheral allocations, requirements, and verification intent.";
      attribute :>> validationHint = "Traverse FirmwareTask usages through typed flows, SoftwareQueue parts, TaskToPeripheralAccess allocations, satisfy links, and verification cases.";
    }

    part electronicsHandoffCompleteness : MethodCompletenessRule {
      attribute :>> ruleId = "E8-CPS-EE-HANDOFF-001";
      attribute :>> appliesToArtifact = ArtifactKind::electronicsImplementationHandoff;
      attribute :>> expectation = CompletionExpectationKind::required;
      attribute :>> requiredFact = "Each electronics handoff subject has authoritative typed ports and connections, interface metadata, semantic rail budgets, component candidates, and verification intent.";
      attribute :>> validationHint = "Traverse physical parts and ports through connect relationships, ElectricalInterfaceInfo and ImplementationHandoff metadata, PowerRailBudget parts, ComponentCandidate refs, and verification cases.";
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
      doc /*
        Generate engineer-facing runtime, queue, peripheral-access, and
        verification views from the project semantic graph.
      */
    }

    part electronicsHandoffExtraction : MethodExtractionRule {
      attribute :>> ruleId = "E8-CPS-EXTRACT-EE-001";
      attribute :>> artifactKind = ArtifactKind::electronicsImplementationHandoff;
      doc /*
        Generate electronics interface, rail-budget, readiness, and
        component-selection views from the project semantic graph.
      */
    }
  }

  part elan8MethodologyBaseline : Elan8MethodologyBaseline;
}
