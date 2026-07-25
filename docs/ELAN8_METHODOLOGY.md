<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Elan8 Methodology

This document defines the Elan8 methodology, a lightweight modeling method for
cyber-physical and software-only systems. The goal is to make SysML v2 models
consistent for engineers and predictable for tools that extract handoff
information, traceability, dashboards, reviews, and reports.

## Core Principle

Use native SysML v2 for engineering semantics. Use Elan8 methodology metadata
for classification, ownership, maturity, extraction, and external references.

Native SysML v2 should own:

- requirements, subjects, assumptions, required constraints, satisfy links, and verification cases;
- parts, items, ports, interfaces, actions, states, allocations, and flows;
- physical, software, electronics, safety, verification, and analysis facts;
- views and viewpoints over the same model graph.

Elan8 methodology metadata should own:

- model layer and discipline ownership;
- lifecycle maturity, such as draft, candidate, baseline, verified, or released;
- whether an element is an extractable artifact for a specific engineering handoff;
- source-of-truth versus derived-view roles;
- references to external lifecycle tools such as Jira, GitHub, PLM, ALM, or ERP records.

Metadata must not replace SysML semantics. If a relation can be modeled as a requirement, allocation, connection, flow, verification case, or part relationship, model it natively first.

## Package Structure

Use a stable package structure by engineering ownership rather than diagram type.

```text
model/
  method/          Elan8 methodology library and extraction rules.
  root/            Full workspace import hubs.
  requirements/    Stakeholder needs, system requirements, design limits.
  context/         External actors, environment, use cases, operational scenarios.
  architecture/    Functional, physical, protocol, and allocation architecture.
  behavior/        State and behavior models that cut across structure.
  implementation/  Software, firmware, electronics, ICD, component, and handoff facts.
  assurance/       Safety, verification, analysis, and trade evidence.
  views/           Stakeholder views over the same source model.
```

Software-only projects may omit electronics and mechanical packages, but should keep the same intent: requirements, context, architecture, implementation, verification, analysis, and views.

## Method Library

The method concepts live in `model/method/Elan8Methodology.sysml`.

The package defines:

- `ModelLayerKind` for method, requirements, context, architecture, behavior, implementation, verification, analysis, views, and root.
- `DisciplineKind` for systems, software, electronics, mechanical, safety, verification, manufacturing, and product ownership.
- `MaturityKind` for draft, candidate, baseline, verified, released, and deprecated content.
- `ArtifactKind` for extractable engineering artifacts.
- `TraceRoleKind` for source-of-truth, derived view, handoff, evidence, and external-reference roles.
- metadata definitions for model layer, engineering ownership, lifecycle status, extractable artifact, trace role, and external reference.
- completeness and extraction rule records that tools can read even before full semantic metadata automation is available.

## Recommended Metadata Pattern

Use metadata sparingly and consistently. A package or element should only be tagged when the tag helps tooling or governance.

Example intent:

```sysml
@Elan8Methodology::EngineeringOwnership {
  discipline = Elan8Methodology::DisciplineKind::software;
  ownerRole = "Embedded Software Lead";
  reviewRole = "Systems Engineer";
}
```

Apply this kind of metadata to package entry points, handoff records, source-of-truth baselines, or elements that automation must discover reliably. Avoid tagging every small attribute.

## CPS Modeling Flow

Model cyber-physical systems in this order:

1. Capture stakeholder needs and system requirements with subjects and testable constraints.
2. Define context actors, environment boundaries, external systems, and operating scenarios.
3. Define functional behavior as actions and mission flows.
4. Define physical and logical architecture as parts, ports, item definitions, and connections.
5. Allocate functions to physical parts, software tasks, electronics functions, or deployment targets.
6. Define interface-control records for software messages, electrical connectors, rails, buses, and harnesses.
7. Define implementation handoff packages for software, firmware, electronics, and components.
8. Define verification cases, analysis cases, and evidence intent.
9. Define views for stakeholder questions rather than creating diagram-specific source packages.

## Software Handoff Contract

A software engineer should be able to extract the following facts without reading the whole model:

- task name, owning module, startup phase, period, deadline, WCET budget, stack budget, static RAM budget, and criticality;
- owned state and error-handling policy;
- input and output message contracts, payloads, timing, and queue policies;
- HAL or driver bindings to physical/electronics features;
- relevant requirements and verification cases;
- algorithm notes, unit-test intent, and integration-test intent.

In this repository those facts are composed through `Implementation`,
`FirmwareArchitecture`, `InterfaceControl`, `PhysicalArchitecture`,
`ArchitectureAllocations`, and `Verification`.

## Electronics Handoff Contract

An electronics engineer should be able to extract:

- owning board or harness and PCB domain;
- connector, signal, rail, bus, harness, and test-point contracts;
- voltage, current, timing, protocol, safety, EMC, and protection constraints;
- component candidates with manufacturer, MPN, package, footprint, critical specs, cost target, lifecycle/compliance status, and datasheet review status;
- verification references to system-level cases.

In this repository those facts are composed through `Implementation`,
`PhysicalArchitecture`, `ElectronicsInterfaceControl`,
`ElectronicsComponentSelection`, and `Verification`.

## Extraction Rules

Tooling should treat `Implementation` views as the main implementation entry
point. It should then use method rules from `Elan8Methodology` and traverse native
features, flows, connections, allocations, references, and metadata.

Recommended extraction behavior:

- Extract `MethodCompletenessRule` usages from `Elan8Methodology` to learn required facts per artifact kind.
- Extract `MethodExtractionRule` usages to find source packages, primary element kinds, join hints, and output intent.
- Prefer native SysML relationships and typed features when available.
- Do not reconstruct internal model identity from string paths.
- Report unresolved references as model hygiene findings rather than silently dropping them.

## Validation Expectations

A model following this way of working should pass these checks:

- every top-level package has clear ownership and imports only what it needs;
- every requirement has a subject and a verification or analysis path;
- every handoff package has an implementation hub or view that exposes it;
- every software task is linked to runtime, interface, requirement, verification, and test-intent facts;
- every electronics work package is linked to interface, rail, component, and verification facts;
- every component candidate has selection status and known review gaps;
- every source-of-truth element is distinguishable from derived views and external references.

## Adoption Guidance

Start small. Add the method package, tag only package entry points or baseline records, and make extraction rules visible as model elements. Once tooling support matures, increase use of semantic metadata and automated validation.

The method should remain opinionated but lightweight: enough structure for automation, not so much that engineers need to learn a second modeling language on top of SysML v2.
