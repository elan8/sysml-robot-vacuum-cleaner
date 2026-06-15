# Model Guide

This guide explains how the robot-vacuum model is organized and how to read it without needing to inspect every package first.

## Model Layers

The model is intentionally layered from product intent to implementation evidence:

| Layer | Main packages | Purpose |
| --- | --- | --- |
| Requirements | `StakeholderNeeds`, `SystemRequirements`, `DesignLimits` | User needs, derived system requirements, and shared numeric limits. |
| Context | `ProductContext`, `OperationalScenarios` | External actors, home environment, dock, app/cloud, and mission flows. |
| Architecture | `ArchitectureCommon`, `PhysicalProtocols`, `FunctionalArchitecture`, `PhysicalArchitecture`, `ArchitectureAllocations`, `Architecture` | Functional capabilities, product assemblies, typed interfaces, and allocation links. |
| Implementation | `ElectricalInterfaces`, `InterfaceControl`, `FirmwareArchitecture` | PCB interface control, software contracts, firmware tasks, and scheduler assumptions. |
| Assurance | `SafetyAnalysis`, `TradeStudies`, `Verification`, `AnalysisCases` | Hazards, mitigations, trade rationale, verification cases, and engineering margins. |
| Views | `ModelViews` | Stakeholder-facing slices of the model. |
| Root | `AutonomousFloorCleaningRobotDemo` | Import hub for loading the full workspace. |

## Engineering Threads

- Needs to evidence: stakeholder needs derive system requirements, which are satisfied by design elements and verified by cases or analyses.
- Context to architecture: product context defines external interactions; architecture packages define the robot boundary and internal realization.
- Function to realization: functional actions allocate to physical LRUs, firmware modules, and MCU execution targets.
- Safety assurance: hazards link to mitigations, safety requirements, implementation elements, analyses, and verification cases.
- Implementation handoff: electrical interfaces, software contracts, and firmware tasks provide a bridge from MBSE model to PCB and embedded-software work.
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
| `PhysicalArchitecture` | Product assemblies, physical harnesses, firmware suite, and roll-ups. | Common items, protocols, behavior, software, compute, units. |
| `ArchitectureAllocations` | Function, action, firmware, and MCU allocation links. | Functional, physical, firmware, software, compute packages. |
| `Architecture` | Public architecture import hub and `robot` part. | Architecture packages and system requirements. |
| `ElectricalInterfaces` | PCB connector, signal, rail, bus, and fault records. | Board/electronics libraries, protocols, physical architecture. |
| `InterfaceControl` | Software-facing message contracts and producer/consumer ownership. | Common items and software library. |
| `FirmwareArchitecture` | Firmware task definitions, scheduler model, and task architecture instance. | Common items, contracts, physical architecture, software library. |
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
4. Physical, electrical, interface-control, and firmware architecture.
5. Allocations and the `Architecture` hub.
6. Behavior, safety, trade studies, verification, and analyses.
7. Views for stakeholder-specific slices.

## Future Folder Structure

The repository currently keeps a flat `model/` directory for maximum compatibility. If recursive workspace loading remains stable across Spec42 and Babel42, use this grouping without changing package names:

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

Validate immediately after any move. If import resolution or demo bootstrapping regresses, keep the flat layout and rely on package headers plus this guide.
