<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Model Guide

This guide explains how the robot-vacuum model is organized and how to read it without needing to inspect every package first.

## Showcase Tour

Use this tour when evaluating the model as a high-end SysML v2 example:

1. Start in `StakeholderNeeds` and `SystemRequirements` to see user needs, derived requirements, metadata, and derivation links.
2. Read `FunctionalArchitecture` for capability actions and mission-level behavior.
3. Read `PhysicalArchitecture` for product assemblies, typed ports, harnesses, firmware suite parts, and mass/BOM/power roll-ups.
4. Read `ArchitectureAllocations` to follow capability-to-LRU, software-to-MCU, scenario-action, and firmware-task allocations.
5. Read `Implementation` first, then the software and electronics implementation packages as the handoff layer for message contracts, task timing/resource constraints, PCB/harness contracts, component candidates, software implementation records, electronics work packages, queues, HAL bindings, rail budgets, and bring-up checks.
6. Read `SafetyAnalysis`, `TradeStudies`, `Verification`, and `AnalysisCases` for assurance, rationale, and engineering margins.
7. Finish in `ModelViews` to see curated stakeholder slices over the same source model.

## Model Layers

The model is intentionally layered from product intent to implementation evidence:

| Layer | Main packages | Purpose |
| --- | --- | --- |
| Requirements | `StakeholderNeeds`, `SystemRequirements`, `DesignLimits` | User needs, derived system requirements, and shared numeric limits. |
| Context | `ProductContext`, `OperationalScenarios` | External actors, home environment, dock, app/cloud, and mission flows. |
| Architecture | `ArchitectureCommon`, `PhysicalProtocols`, `FunctionalArchitecture`, `PhysicalArchitecture`, `ArchitectureAllocations`, `Architecture` | Functional capabilities, product assemblies, typed interfaces, and allocation links. |
| Implementation | `Implementation`, `InterfaceControl`, `FirmwareArchitecture`, `SoftwareImplementation`, `ElectronicsInterfaceControl`, `ElectronicsImplementation`, `ElectronicsComponentSelection`, `ElectronicsVerification` | Implementation hub, software message contracts, firmware tasks, scheduler assumptions, runtime/resource constraints, PCB/harness contracts, component candidates, software implementation records, electronics work packages, queue policies, HAL bindings, rail budgets, bring-up checks, and test intent. Harness ICD notes live on `PhysicalArchitecture` ports. |
| Assurance | `SafetyAnalysis`, `TradeStudies`, `Verification`, `AnalysisCases` | Hazards, mitigations, trade rationale, verification cases, and engineering margins. |
| Views | `ModelViews` | Stakeholder-facing slices of the model. |
| Root | `AutonomousFloorCleaningRobotDemo` | Import hub for loading the full workspace. |

## Folder Layout

The `model/` directory mirrors the layer structure for navigation. The folder names do not define SysML namespaces; each file still owns exactly one top-level package.

```text
model/
  root/
  requirements/
  context/
  architecture/
  implementation/
  behavior/
  assurance/
  views/
```

## Engineering Threads

- Needs to evidence: stakeholder needs derive system requirements, which are satisfied by design elements and verified by cases or analyses.
- Context to architecture: product context defines external interactions; architecture packages define the robot boundary and internal realization.
- Function to realization: functional actions allocate to physical LRUs, firmware modules, and MCU execution targets.
- Safety assurance: hazards link to mitigations, safety requirements, implementation elements, analyses, and verification cases.
- Implementation handoff: `Implementation` provides the software/electronics entry point, while electrical interfaces, software contracts, firmware task constraints, electronics contracts, component candidates, PCB/harness work packages, and software implementation records provide a bridge from MBSE model to PCB and embedded-software work.
- Design rationale: trade studies record selected and deferred product options, including the privacy-conscious LiDAR SLAM baseline.

## Package Map

| Package | Owns | Key dependencies |
| --- | --- | --- |
| `StakeholderNeeds` | User-facing needs with requirement metadata. | Requirement and modeling metadata libraries. |
| `SystemRequirements` | Derived system requirements and derivation links. | `StakeholderNeeds`, metadata libraries. |
| `DesignLimits` | Shared budget, mass, energy, and timing limits. | Quantity and monetary libraries. |
| `ArchitectureCommon` | Shared mission items, commands, telemetry, map, and CPS ports. | Scalar values. |
| `PhysicalProtocols` | Product-specific bus aliases and domain electronics imports. | Electronics, bus, wireless, and software domain libraries. |
| `ProductContext` | External systems and residential cleaning context. | Architecture and protocol packages. |
| `FunctionalArchitecture` | Capability `action def`s and mission actions. | `ArchitectureCommon`, `SystemRequirements`. |
| `PhysicalArchitecture` | Product assemblies, physical harnesses, harness port ICD docs, firmware suite, and roll-ups. | Common items, protocols, behavior, software, compute, units. |
| `ArchitectureAllocations` | Function, action, firmware, and MCU allocation links. | Functional, physical, firmware, software, compute packages. |
| `Architecture` | Public architecture import hub and `robot` part. | Architecture packages and system requirements. |
| `InterfaceControl` | Software-facing message contracts and producer/consumer ownership. | Common items and software library. |
| `FirmwareArchitecture` | Firmware task definitions, scheduler model, task architecture instance, startup phase, state ownership, error handling, and resource/WCET budgets. | Common items, contracts, physical architecture, software library. |
| `SoftwareImplementation` | Engineer-facing software implementation records, queue contracts, message field rules, HAL bindings, and test intent. | Firmware architecture, interface control, physical architecture, requirements, verification. |
| `ElectronicsInterfaceControl` | Electronics connector, signal, rail, bus, harness, and test-point contracts. | Physical architecture, physical protocols, units. |
| `ElectronicsImplementation` | PCB/harness work packages, schematic/layout constraints, BOM notes, rail budgets, bring-up scope, and manufacturing notes. | Physical architecture, electronics interface control, requirements, verification. |
| `ElectronicsComponentSelection` | Baseline component candidates, MPNs, footprints, key specs, cost targets, lifecycle status, and selection rationale. | Physical architecture, electronics interface control, electronics implementation, monetary units. |
| `ElectronicsVerification` | Electronics bring-up, fault-injection, bench-measurement, and manufacturing test steps. | Electronics interface control, electronics implementation, physical architecture. |
| `Implementation` | Implementation-layer hub, trace records, and software/electronics engineer views over interface, firmware, PCB/harness, component-selection, and handoff packages. | Interface control, firmware architecture, software implementation, electronics implementation packages, views. |
| `BehaviorStates` | Operating lifecycle and detailed behavior fragments. | None beyond SysML basics. |
| `OperationalScenarios` | Scenario-level use cases over context and functional actions. | Architecture, functional architecture, product context. |
| `SafetyAnalysis` | Hazards, mitigations, safety satisfaction, and safety evidence links. | Requirements, design, behavior, verification, analysis packages. |
| `TradeStudies` | Selected/deferred options and rationale. | Requirements, physical architecture, analyses. |
| `Verification` | Verification cases and evidence intent. | Requirements and architecture. |
| `AnalysisCases` | Power, mass, cost, energy, localization, coverage, and timing analyses. | Architecture, design limits, units. |
| `ModelViews` | Concerns, viewpoints, views, expose slices, and renderings. | All major model packages. |

## Reading Strategy

Start with requirements and functional behavior before reading physical details. The recommended path is:

1. Requirements and design limits.
2. Functional architecture and operational scenarios.
3. Physical protocols and product context.
4. Physical, electrical, implementation hub, interface-control, firmware architecture, software implementation handoff, and electronics handoff.
5. Allocations and the `Architecture` hub.
6. Behavior, safety, trade studies, verification, and analyses.
7. Views for stakeholder-specific slices.

## Folder Changes

Validate immediately after moving model files. If import resolution or demo bootstrapping regresses in a tool, keep package names stable and fix the tool configuration rather than renaming packages to match paths.
