<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Model Guide

This guide explains how the robot-vacuum model is organized and how to read it without needing to inspect every package first.

## Showcase Tour

Use this tour when evaluating the model as a high-end SysML v2 example:

1. Start in `StakeholderNeeds` and `SystemRequirements` to see user needs, derived requirements, metadata, and derivation links.
2. Read `Strata` for the lightweight way-of-working concepts used by extraction and handoff tooling.
3. Read `FunctionalArchitecture` for capability actions and mission-level behavior.
4. Read `PhysicalArchitecture` for product assemblies, typed ports, harnesses, firmware suite parts, and mass/BOM/power roll-ups.
5. Read `ProductVariants` to see the product-line choices and selected SKU baselines.
6. Read `ArchitectureAllocations` to follow capability-to-LRU, software-to-MCU, scenario-action, and firmware-task allocations.
7. Read `Implementation` views, then the software and electronics implementation packages for message contracts, task timing/resource constraints, PCB/harness contracts, component candidates, software implementation records, electronics work packages, queues, HAL bindings, and rail budgets.
8. Read `SafetyAnalysis`, `TradeStudies`, `Verification`, and `AnalysisCases` for assurance, rationale, and engineering margins.
9. Finish in `ModelViews` and `Implementation` views for curated stakeholder and engineer slices over the same source model.

## Model Layers

The model is intentionally layered from product intent to implementation evidence:

| Layer | Main packages | Purpose |
| --- | --- | --- |
| Libraries | `VacuumCleanerQuantitiesAndUnits` | Project-specific measurement units declared in terms of the OMG quantities-and-units library. |
| Method | `Strata` | Way-of-working concepts, ownership and maturity metadata, completeness rules, and extraction rules for CPS and software-only models. |
| Requirements | `StakeholderNeeds`, `SystemRequirements`, `DesignLimits` | User needs, derived system requirements, and shared numeric limits. |
| Context | `ProductContext`, `OperationalScenarios` | External actors, home environment, dock, app/cloud, and mission flows. |
| Architecture | `ArchitectureCommon`, `PhysicalProtocols`, `FunctionalArchitecture`, `PhysicalArchitecture`, `ArchitectureAllocations`, `Architecture` | Functional capabilities, product assemblies, typed interfaces, and allocation links. |
| Variants | `ProductVariants` | Native SysML variation choices, variant option records, selected SKU baselines, and implementation/verification impact summaries. |
| Implementation | `Implementation`, `InterfaceControl`, `FirmwareArchitecture`, `SoftwareImplementation`, `ElectronicsInterfaceControl`, `ElectronicsImplementation`, `ElectronicsComponentSelection` | Implementation views, software message contracts, firmware tasks, scheduler assumptions, runtime/resource constraints, PCB/harness contracts, component candidates, software implementation records, electronics work packages, queue policies, HAL bindings, rail budgets, and test intent. Harness ICD notes live on `PhysicalArchitecture` ports. |
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
- Variants to implementation impact: product variants define selected and deferred choices, then point to changed architecture, software, electronics, verification, and trade-study records.
- Safety assurance: hazards link to mitigations, safety requirements, implementation elements, analyses, and verification cases.
- Implementation handoff: `Implementation` provides the software/electronics entry point, while electrical interfaces, software contracts, firmware task constraints, electronics contracts, component candidates, PCB/harness work packages, and software implementation records provide a bridge from MBSE model to PCB and embedded-software work.
- Design rationale: trade studies record selected and deferred product options, including the privacy-conscious LiDAR SLAM baseline.

## Package Map

| Package | Owns | Key dependencies |
| --- | --- | --- |
| `VacuumCleanerQuantitiesAndUnits` | Project-specific `Ah` and `mAh` electric-charge units and the `ms` duration unit. | OMG measurement references, ISQ, SI, and SI prefixes. |
| `Strata` | Lightweight method metadata, artifact kinds, completeness rules, and extraction rules. | Scalar values. |
| `StakeholderNeeds` | User-facing needs with requirement metadata. | Requirement and modeling metadata libraries. |
| `SystemRequirements` | Derived system requirements and derivation links. | `StakeholderNeeds`, metadata libraries. |
| `DesignLimits` | Shared budget, mass, energy, and timing limits. | Quantity and monetary libraries. |
| `ArchitectureCommon` | Shared mission items, commands, telemetry, map, and CPS ports. | Scalar values. |
| `PhysicalProtocols` | Product-specific bus aliases and domain electronics imports. | Electronics, bus, wireless, and software domain libraries. |
| `ProductContext` | External systems and residential cleaning context. | Architecture and protocol packages. |
| `FunctionalArchitecture` | Capability `action def`s and mission actions. | `ArchitectureCommon`, `SystemRequirements`. |
| `PhysicalArchitecture` | Product assemblies, physical harnesses, harness port ICD docs, authoritative `firmwareTasks` and `robotFirmware` instances, task/module/MCU allocations, and roll-ups. | Common items, protocols, behavior, software, compute, units. |
| `ArchitectureAllocations` | `TaskToSoftwareModule`, `SoftwareToComputeNode`, and reusable allocation definition types. | Firmware architecture, software core, embedded compute libraries. |
| `Architecture` | Public architecture import hub and `robot` part. | Architecture packages and system requirements. |
| `ProductVariants` | Product-line variation definitions, variant option records, SKU configuration baselines, and implementation/verification impact summaries. | Physical architecture, firmware architecture, component selection. |
| `InterfaceControl` | Software-facing message contracts and producer/consumer ownership. | Common items and software library. |
| `FirmwareArchitecture` | Firmware task definitions, scheduler model, `FirmwareTaskArchitecture` structure, flows, and embedded interface-control contracts. | Common items, contracts, physical architecture, software library. |
| `SoftwareImplementation` | Engineer-facing software implementation records, queue contracts, message field rules, HAL bindings, and test intent. | Firmware architecture, interface control, physical architecture, requirements, verification. |
| `ElectronicsInterfaceControl` | Electronics connector, signal, rail, bus, harness, and test-point contracts. | Physical architecture, physical protocols, units. |
| `ElectronicsImplementation` | PCB/harness work packages, schematic/layout constraints, BOM notes, and rail budgets. | Physical architecture, electronics interface control, requirements, verification. |
| `ElectronicsComponentSelection` | Baseline component candidates, MPNs, footprints, key specs, cost targets, lifecycle status, and selection rationale. | Physical architecture, electronics interface control, electronics implementation, monetary units. |
| `BehaviorStates` | Operating lifecycle and detailed behavior fragments. | None beyond SysML basics. |
| `OperationalScenarios` | Scenario-level use cases over context and functional actions. | Architecture, functional architecture, product context. |
| `SafetyAnalysis` | Hazards, mitigations, safety satisfaction, and safety evidence links. | Requirements, design, behavior, verification, analysis packages. |
| `TradeStudies` | Selected/deferred options and rationale. | Requirements, physical architecture, analyses. |
| `Verification` | Verification cases and evidence intent. | Requirements and architecture. |
| `AnalysisCases` | Power, mass, cost, energy, localization, coverage, and timing analyses. | Architecture, design limits, units. |
| `ModelViews` | Firmware task/deployment interconnection views and requirements traceability. | Requirements, physical architecture, verification. |
| `Implementation` | Electronics work-package handoff view. | Electronics implementation package, views. |

## Reading Strategy

Start with requirements and functional behavior before reading physical details. The recommended path is:

1. Requirements and design limits.
2. Method package when building tools or checking handoff completeness.
3. Functional architecture and operational scenarios.
4. Physical protocols and product context.
5. Product variants and selected SKU baselines.
6. Physical, electrical, implementation views, interface-control, firmware architecture, software implementation handoff, and electronics handoff.
7. Allocations and the `Architecture` hub.
8. Behavior, safety, trade studies, verification, and analyses.
9. Views for stakeholder-specific slices.

## Folder Changes

Validate immediately after moving model files. If import resolution or demo bootstrapping regresses in a tool, keep package names stable and fix the tool configuration rather than renaming packages to match paths.
