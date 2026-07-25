<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Model Guide

This guide explains how the robot-vacuum model is organized and how to read it without needing to inspect every package first.

## Showcase Tour

Use this tour when evaluating the model as a high-end SysML v2 example:

1. Start in `StakeholderNeeds` and `SystemRequirements` to see user needs, derived requirements, metadata, and derivation links.
2. Read `Elan8Methodology` for the lightweight way-of-working concepts used by extraction and handoff tooling.
3. Read `FunctionalArchitecture` for capability actions and mission-level behavior.
4. Read `PhysicalArchitecture` for product assemblies, typed ports, harnesses, firmware suite parts, and mass/BOM/power roll-ups.
5. Read `ProductVariants` to see the product-line choices and selected SKU baselines.
6. Read `ArchitectureAllocations` to follow capability-to-LRU, software-to-MCU, scenario-action, and firmware-task allocations.
7. Read `Implementation` views, then follow their exposed firmware tasks,
   typed queues, peripheral allocations, physical ports, rail budgets,
   component candidates, and verification cases in the shared semantic graph.
8. Read `SafetyAnalysis`, `TradeStudies`, `Verification`, and `AnalysisCases` for assurance, rationale, and engineering margins.
9. Finish in `ModelViews` and `Implementation` views for curated stakeholder and engineer slices over the same source model.

## Model Layers

The model is intentionally layered from product intent to implementation evidence:

| Layer | Main packages | Purpose |
| --- | --- | --- |
| Libraries | `VacuumCleanerQuantitiesAndUnits` | Project-specific measurement units declared in terms of the OMG quantities-and-units library. |
| Method | `Elan8Methodology` | Way-of-working concepts, ownership and maturity metadata, completeness rules, and extraction rules for CPS and software-only models. |
| Requirements | `StakeholderNeeds`, `SystemRequirements`, `DesignLimits` | User needs, derived system requirements, and shared numeric limits. |
| Context | `ProductContext`, `OperationalScenarios` | External actors, home environment, dock, app/cloud, and mission flows. |
| Architecture | `ArchitectureCommon`, `PhysicalProtocols`, `FunctionalArchitecture`, `PhysicalArchitecture`, `ArchitectureAllocations`, `Architecture` | Functional capabilities, product assemblies, typed interfaces, and allocation links. |
| Variants | `ProductVariants` | Native SysML variation choices, variant option records, selected SKU baselines, and implementation/verification impact summaries. |
| Implementation | `Implementation`, `InterfaceControl`, `FirmwareArchitecture`, `ElectronicsInterfaceControl`, `ElectronicsComponentSelection`, plus implementation facts in `PhysicalArchitecture` | Views over software contracts, firmware tasks, typed queues, scheduler/resource constraints, peripheral allocations, physical interface metadata, semantic rail budgets, component candidates, and verification intent. |
| Assurance | `SafetyAnalysis`, `TradeStudies`, `Verification`, `AnalysisCases` | Hazards, mitigations, trade rationale, verification cases, and engineering margins. |
| Views | `ModelViews`, `Implementation` | Firmware diagram views and electronics work-package handoff. |
| Root | `AutonomousFloorCleaningRobotDemo` | Import hub for loading the full workspace. |

## Folder Layout

The `model/` directory mirrors the layer structure for navigation. The folder names do not define SysML namespaces; each file still owns exactly one top-level package.

```text
model/
  root/
  libraries/
  method/
  requirements/
  context/
  architecture/
  variants/
  implementation/
  behavior/
  assurance/
  views/
```

## Engineering Threads

- Needs to evidence: stakeholder needs derive system requirements, which are satisfied by design elements and verified by cases or analyses.
- Context to architecture: product context defines external interactions; architecture packages define the robot boundary and internal realization.
- Function to realization: functional actions allocate to physical LRUs, firmware modules, and MCU execution targets.
- Variants to implementation impact: product variants define selected and deferred choices, then point to changed architecture, software, electronics, verification, and trade-study elements.
- Safety assurance: hazards link to mitigations, safety requirements, implementation elements, analyses, and verification cases.
- Implementation handoff: `Implementation` provides the software/electronics
  entry point; its views expose the authoritative runtime, allocation,
  interface, rail, component-selection, and verification elements directly.
- Design rationale: trade studies record selected and deferred product options, including the privacy-conscious LiDAR SLAM baseline.

## Package Map

| Package | Owns | Key dependencies |
| --- | --- | --- |
| `VacuumCleanerQuantitiesAndUnits` | Project-specific `Ah` and `mAh` electric-charge units and the `ms` duration unit. | OMG measurement references, ISQ, SI, and SI prefixes. |
| `Elan8Methodology` | Lightweight method metadata, artifact kinds, completeness rules, and extraction rules. | Scalar values. |
| `StakeholderNeeds` | User-facing needs with requirement metadata. | Requirement and modeling metadata libraries. |
| `SystemRequirements` | Derived system requirements and derivation links. | `StakeholderNeeds`, metadata libraries. |
| `DesignLimits` | Shared budget, mass, energy, and timing limits. | Quantity and monetary libraries. |
| `ArchitectureCommon` | Shared mission items, commands, telemetry, map, and CPS ports. | Scalar values. |
| `PhysicalProtocols` | Product-specific bus aliases and domain electronics imports. | Electronics, bus, wireless, and software domain libraries. |
| `ProductContext` | External systems and residential cleaning context. | Architecture and protocol packages. |
| `FunctionalArchitecture` | Capability `action def`s and mission actions. | `ArchitectureCommon`, `SystemRequirements`. |
| `PhysicalArchitecture` | Product assemblies, physical harnesses, interface metadata, semantic rail budgets, authoritative task/software instances, task/module/MCU/peripheral allocations, and roll-ups. | Common items, protocols, behavior, software, compute, units. |
| `ArchitectureAllocations` | Task-to-software, software-to-compute, and typed task-to-peripheral allocation definitions. | Firmware architecture, software core, embedded compute libraries. |
| `Architecture` | Public architecture import hub and `robot` part. | Architecture packages and system requirements. |
| `ProductVariants` | Product-line variation definitions, variant option records, SKU configuration baselines, and implementation/verification impact summaries. | Physical architecture, firmware architecture, component selection. |
| `InterfaceControl` | Software-facing message contracts and producer/consumer ownership. | Common items and software library. |
| `FirmwareArchitecture` | Firmware task definitions, scheduler model, typed runtime queues, task structure, flows, and embedded data contracts. | Common items, contracts, software library. |
| `ElectronicsInterfaceControl` | Reusable interface kind, direction, criticality, and quantity metadata. | Scalar values and ISQ. |
| `ElectronicsComponentSelection` | Component candidates with refs to physical targets/interfaces, typed limits, MPNs, lifecycle status, and rationale. | Architecture, physical architecture, interface metadata, monetary units. |
| `BehaviorStates` | Operating lifecycle and detailed behavior fragments. | None beyond SysML basics. |
| `OperationalScenarios` | Scenario-level use cases over context and functional actions. | Architecture, functional architecture, product context. |
| `SafetyAnalysis` | Hazards, mitigations, safety satisfaction, and safety evidence links. | Requirements, design, behavior, verification, analysis packages. |
| `TradeStudies` | Selected/deferred options and rationale. | Requirements, physical architecture, analyses. |
| `Verification` | Verification cases and evidence intent. | Requirements and architecture. |
| `AnalysisCases` | Power, mass, cost, energy, localization, coverage, and timing analyses. | Architecture, design limits, units. |
| `ModelViews` | Firmware task/deployment interconnection views and requirements traceability. | Requirements, physical architecture, verification. |
| `Implementation` | Software runtime, peripheral access, electronics interface, rail budget, and component-selection views. | Architecture graph, allocations, and component selection. |

## Reading Strategy

Start with requirements and functional behavior before reading physical details. The recommended path is:

1. Requirements and design limits.
2. Method package when building tools or checking handoff completeness.
3. Functional architecture and operational scenarios.
4. Physical protocols and product context.
5. Product variants and selected SKU baselines.
6. Physical and firmware architecture, interface control, component selection,
   and the implementation views over their shared graph.
7. Allocations and the `Architecture` hub.
8. Behavior, safety, trade studies, verification, and analyses.
9. Views for stakeholder-specific slices.

## Folder Changes

Validate immediately after moving model files. If import resolution or demo bootstrapping regresses in a tool, keep package names stable and fix the tool configuration rather than renaming packages to match paths.
