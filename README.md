# Autonomous Floor Cleaning Robot (SysML v2)

Canonical SysML v2 model for an autonomous floor-cleaning robot. One top-level package per `.sysml` file (webshop-style workspace layout) so `private import PackageName::*` resolves across files.

Used as the Babel42 bootstrap demo, Spec42 validation corpus, and teaching example for requirements traceability, subsystem architecture, behavior, verification, and analysis.

## Purpose

Model a residential robot vacuum with:

- stakeholder and system requirements (implicit usages with `@RequirementRole` and `@StatusInfo` metadata)
- requirement derivation from user needs to system requirements
- functional decomposition as **`action def` capabilities** (`ProvideLocomotion`, `SenseEnvironment`, …) composed in `OperateCleaningRobot`, with mission scenarios and requirement `satisfy`
- physical decomposition as **monteerbare assemblies** with typed electronics harnesses (I2C sensor bus, SMBus BMS, SPI flash, UART/BLE wireless, 3-phase BLDC wheel drives, PWM brushed/vacuum motors, GPIO safety/HMI, power rails)
- **three allocation layers**: capability → software/LRU (`ArchitectureAllocations`), software → MCU (`allocate` to `mainControlPcb.mcu`), peripheral I/O (`connect` on `MainControlPcb`)
- cyberphysical interfaces and flows for maps, pose estimates, hazard events, commands, and mission status
- operational product context with user, mobile app, home network, optional cloud backup, dock, floor surfaces, obstacles, and stair edges
- operating behavior state machine with self-test, cleaning, pause, recovery, safe-stop, fault, docking, and charging states
- operational scenarios for the nominal autonomous cleaning mission and obstacle recovery
- canonical SysML v2 views with concerns, viewpoints, expose filters, and standard renderings for structure, interconnections, behavior, traceability, safety, and deployment
- safety analysis, maintainability requirements, technical margins, and trade-study rationale for realistic product engineering
- verification cases with physical and model-based evidence
- analysis cases for power, cost, mass, mission energy, localization, coverage resolution, and safety reaction timing

## Library dependencies

Requires packages from [sysml-domain-libraries](https://github.com/elan8/sysml-domain-libraries), especially:

**Generic / requirements**

- `RequirementMetadata` (`RequirementRole`, `RequirementRoleKind`)
- `ModelingMetadata` (`StatusInfo`, OMG `StatusKind`)
- `RequirementManagement` (evidence, baseline, traceability scaffolding — not requirement defs)
- `MonetaryUnits` (`MonetaryAmount`)
- `ISQ` / `SI` quantity types

**Electronics / communication (physical layer)**

- `ElectronicsInterconnection` (`I2cPort`, `PwmPort`, `PowerRailPort`, `GpioPort`, …)
- `ElectronicBusDomain` (`I2cBus`, `I2cBusMasterNode`, `I2cBusSlaveNode`, `SmbusBus`, …)
- `WirelessDomain` (`WirelessModule`, `BleCommunicationChannel`)
- Composed in project-local [`PhysicalProtocols.sysml`](model/PhysicalProtocols.sysml) — product bus media with named attachment ports (`SensorI2cBus`, `BmsSmbusBus`, …)

**Software / compute (deployment layer)**

- `SoftwareCore` (`ExecutableComponent`, `DeploymentNode`, …)
- `EmbeddedComputeDomain` (`Microcontroller`, `EmbeddedComputeUnit`)
- Product firmware in [`PhysicalArchitecture.sysml`](model/PhysicalArchitecture.sysml) as `RobotFirmwareSuite` (`:> ExecutableComponent`); deployed to `MicrocontrollerUnit :> Microcontroller` via `allocate` in [`ArchitectureAllocations.sysml`](model/ArchitectureAllocations.sysml)

Point your tool's library roots at `domain/`, `technical/`, and `generic/` under that repository.

## Try it with Spec42

From a checkout that includes domain libraries on the library path:

```powershell
spec42 check model/ `
  --library-path C:\Git\sysml-domain-libraries\domain `
  --library-path C:\Git\sysml-domain-libraries\technical `
  --library-path C:\Git\sysml-domain-libraries\generic
```

When using a sibling checkout of `sysml-domain-libraries`, adjust paths accordingly. The bundled domain libraries in Spec42 may lag behind local electronics packages until republished.

## Try it with Babel42

Sync into Babel42's `third_party/` tree (sibling checkout or fetch script), then enable demo mode or install the demo project from the bootstrap UI:

```powershell
# From babel42 repo root (sibling checkout)
powershell -ExecutionPolicy Bypass -File scripts\sync-sysml-robot-vacuum-cleaner-from-local.ps1
```

Set `BABEL42_DEMO_MODE=true` or use **Install demo project** on first bootstrap.

Override the model directory with `BABEL42_ROBOT_VACUUM_MODEL_PATH` when developing against a local clone of this repository.

## Design limits

| Attribute | Value |
|-----------|-------|
| BOM budget | 400 EUR |
| Mass budget | 5.0 kg |
| Battery capacity budget | 12500 mAh (12.5 Ah at 14.4 V nominal) |
| Localization error limit | 150 mm |
| Safe-stop reaction limit | 100 ms |

Defined in `DesignLimits.sysml` and referenced by system requirements and analysis cases.

## Files

| File | Package | Purpose |
|------|---------|---------|
| [AutonomousFloorCleaningRobotDemo.sysml](model/AutonomousFloorCleaningRobotDemo.sysml) | `AutonomousFloorCleaningRobotDemo` | Root hub — imports all project packages |
| [StakeholderNeeds.sysml](model/StakeholderNeeds.sysml) | `StakeholderNeeds` | User requirements |
| [SystemRequirements.sysml](model/SystemRequirements.sysml) | `SystemRequirements` | System requirements and derivations |
| [DesignLimits.sysml](model/DesignLimits.sysml) | `DesignLimits` | BOM and mass budgets |
| [ArchitectureCommon.sysml](model/ArchitectureCommon.sysml) | `ArchitectureCommon` | Mission/application items and CPS ports (functional layer) |
| [PhysicalProtocols.sysml](model/PhysicalProtocols.sysml) | `PhysicalProtocols` | Product bus aliases; re-exports domain electronics libraries |
| [ProductContext.sysml](model/ProductContext.sysml) | `ProductContext` | External systems, home environment, dock, app/cloud, and context boundary |
| [FunctionalArchitecture.sysml](model/FunctionalArchitecture.sysml) | `FunctionalArchitecture` | Capability `action def`s, `OperateCleaningRobot` composition, mission actions, requirement `satisfy` |
| [PhysicalArchitecture.sysml](model/PhysicalArchitecture.sysml) | `PhysicalArchitecture` | Product assemblies, typed physical harness (`I2cPort`, `PwmPort`, …), mass/BOM/power roll-ups |
| [ArchitectureAllocations.sysml](model/ArchitectureAllocations.sysml) | `ArchitectureAllocations` | Capability → LRU/software; software → MCU (`SoftwareToComputeNode`); scenario action allocations |
| [Architecture.sysml](model/Architecture.sysml) | `Architecture` | Import hub, `part robot`, system-level `satisfy` |
| [BehaviorStates.sysml](model/BehaviorStates.sysml) | `BehaviorStates` | Operating state machine |
| [OperationalScenarios.sysml](model/OperationalScenarios.sysml) | `OperationalScenarios` | Use-case context and mission action flows |
| [SafetyAnalysis.sysml](model/SafetyAnalysis.sysml) | `SafetyAnalysis` | Hazards, mitigations, and safety requirement satisfaction |
| [TradeStudies.sysml](model/TradeStudies.sysml) | `TradeStudies` | Product trade options and selected architecture rationale |
| [ModelViews.sysml](model/ModelViews.sysml) | `ModelViews` | Canonical views, concerns, viewpoints, expose slices, and renderings |
| [Verification.sysml](model/Verification.sysml) | `Verification` | Verification cases |
| [AnalysisCases.sysml](model/AnalysisCases.sysml) | `AnalysisCases` | Power, cost, mass, energy, timing, and margin analyses |

## Suggested reading order

1. `StakeholderNeeds.sysml` — user needs
2. `SystemRequirements.sysml` — derived system requirements
3. `FunctionalArchitecture.sysml` — capability actions, functional composition, requirement traceability
4. `PhysicalProtocols.sysml` — electronics library imports and product bus aliases
5. `ProductContext.sysml` — external actors, dock, app/cloud, and home environment
6. `PhysicalArchitecture.sysml` — product assemblies and typed physical connections
7. `ArchitectureAllocations.sysml` — function-to-physical and action allocations
8. `Architecture.sysml` — hub package and system-level constraints
9. `BehaviorStates.sysml` — mission lifecycle states
10. `OperationalScenarios.sysml` — use cases over the combined system model
11. `SafetyAnalysis.sysml` and `TradeStudies.sysml` — hazards, mitigations, and design rationale
12. `ModelViews.sysml` — stakeholder views and viewpoint satisfaction over the model
13. `Verification.sysml` and `AnalysisCases.sysml` — V&V, parametric evidence, and margins
14. `AutonomousFloorCleaningRobotDemo.sysml` — full workspace import hub

## Engineering threads

- **Context to architecture:** `ProductContext` defines external systems and environmental stimuli; `Architecture` and `PhysicalArchitecture` define the robot boundary and internal realization.
- **Needs to evidence:** stakeholder needs derive system requirements, which are satisfied by actions/parts and verified by `Verification` cases.
- **Safety assurance:** `SafetyAnalysis` links hazards to mitigations, requirements, analyses, and fault-injection verification.
- **Design rationale:** `TradeStudies` records selected and deferred options for sensors, suction, battery, safety supervision, and privacy.
- **Margins:** `AnalysisCases` tracks nominal values and engineering margins for mass, power, cost, runtime, localization, coverage, and reaction timing.

## Suggested views

The [`ModelViews.sysml`](model/ModelViews.sysml) package defines first-class SysML v2 views. Useful entry points are:

- `productStructure` — product breakdown rendered as a tree diagram
- `operationalContext` — robot, app, cloud, dock, user, and home environment boundary
- `physicalInterconnections` — physical wiring and cyberphysical links rendered as an interconnection diagram
- `safetyAssurance` — hazards, mitigations, safety requirements, and verification evidence
- `tradeStudyRationale` — selected and deferred architecture options
- `budgetMargins` — mass, power, cost, and energy margin analyses
- `operatingLifecycle` — mission lifecycle state behavior
- `requirementsTraceability` — stakeholder needs, system requirements, verification cases, and analyses

With Spec42 diagram export support, these can be rendered from the model workspace, for example:

```powershell
spec42 diagrams export model --selected-view productStructure --format svg --output target/diagrams
spec42 diagrams export model --selected-view operationalContext --format svg --output target/diagrams
spec42 diagrams export model --selected-view physicalInterconnections --format svg --output target/diagrams
spec42 diagrams export model --selected-view operatingLifecycle --format svg --output target/diagrams
```

## Parser notes

- Transition names must not start with parser keywords as a prefix; use `to_charging` instead of `docked` in `BehaviorStates.sysml`.
- Requirements and verifications are **usages** typed from library defs, not project-local requirement definitions.
