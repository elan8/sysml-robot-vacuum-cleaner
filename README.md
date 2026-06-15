# Autonomous Floor Cleaning Robot (SysML v2)

Canonical SysML v2 model for an autonomous floor-cleaning robot. The model is used as a Babel42 bootstrap demo, Spec42 validation corpus, and teaching example for requirements traceability, subsystem architecture, behavior, verification, and analysis.

The workspace currently keeps one top-level package per `.sysml` file under [`model/`](model/) so `private import PackageName::*` resolves consistently across tools.

## Quick Start

Validate the model with Spec42:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

By default the script expects a sibling checkout at `C:\Git\sysml-domain-libraries`. Override paths when needed:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 `
  -Spec42Exe C:\Git\spec42\target\debug\spec42.exe `
  -DomainLibrariesRoot C:\Git\sysml-domain-libraries
```

## What Is Modeled

- Stakeholder needs, derived system requirements, verification cases, and analysis evidence.
- Functional capabilities for locomotion, cleaning, perception, navigation, power, docking, safety, and user interaction.
- Physical assemblies with typed electronics harnesses, power rails, firmware deployment, and implementation-facing interface control.
- Operating lifecycle behavior, operational scenarios, safety analysis, trade studies, and canonical SysML v2 views.
- A selected privacy-conscious SLAM variant using 2D dToF/LiDAR, wheel odometry, IMU, cliff sensing, and short-range ToF sensing.

## Design Limits

| Attribute | Value |
| --- | --- |
| BOM budget | 400 EUR |
| Mass budget | 5.0 kg |
| Battery capacity budget | 12500 mAh (12.5 Ah at 14.4 V nominal) |
| Localization error limit | 150 mm |
| Safe-stop reaction limit | 100 ms |

The limits are defined in [`DesignLimits.sysml`](model/DesignLimits.sysml) and referenced by system requirements and analysis cases.

## Suggested Reading Order

1. [`StakeholderNeeds.sysml`](model/StakeholderNeeds.sysml) - user needs
2. [`SystemRequirements.sysml`](model/SystemRequirements.sysml) - derived system requirements
3. [`FunctionalArchitecture.sysml`](model/FunctionalArchitecture.sysml) - capabilities and functional composition
4. [`PhysicalProtocols.sysml`](model/PhysicalProtocols.sysml) - electronics library imports and product bus aliases
5. [`ProductContext.sysml`](model/ProductContext.sysml) - external actors and context boundary
6. [`ElectricalInterfaces.sysml`](model/ElectricalInterfaces.sysml) - PCB harness and connector records
7. [`InterfaceControl.sysml`](model/InterfaceControl.sysml) - software message contracts
8. [`FirmwareArchitecture.sysml`](model/FirmwareArchitecture.sysml) - firmware tasks and scheduler timing
9. [`PhysicalArchitecture.sysml`](model/PhysicalArchitecture.sysml) - product assemblies and typed physical connections
10. [`ArchitectureAllocations.sysml`](model/ArchitectureAllocations.sysml) - function, scenario, firmware, and MCU allocations
11. [`Architecture.sysml`](model/Architecture.sysml) - public architecture hub and system-level satisfy links
12. [`BehaviorStates.sysml`](model/BehaviorStates.sysml) - mission lifecycle states
13. [`OperationalScenarios.sysml`](model/OperationalScenarios.sysml) - nominal and recovery mission flows
14. [`SafetyAnalysis.sysml`](model/SafetyAnalysis.sysml) and [`TradeStudies.sysml`](model/TradeStudies.sysml) - hazards and design rationale
15. [`ModelViews.sysml`](model/ModelViews.sysml) - stakeholder views
16. [`Verification.sysml`](model/Verification.sysml) and [`AnalysisCases.sysml`](model/AnalysisCases.sysml) - V&V and engineering margins
17. [`AutonomousFloorCleaningRobotDemo.sysml`](model/AutonomousFloorCleaningRobotDemo.sysml) - full workspace import hub

## Useful Views

The [`ModelViews.sysml`](model/ModelViews.sysml) package defines first-class SysML v2 views. Useful entry points are:

- `productStructure`
- `operationalContext`
- `physicalInterconnections`
- `firmwareTaskArchitecture`
- `sensorSlamArchitecture`
- `softwareMessageContracts`
- `safetyFaultResponse`
- `operatingLifecycle`
- `requirementsTraceability`
- `safetyAssurance`
- `tradeStudyRationale`
- `budgetMargins`

With Spec42 diagram export support:

```powershell
spec42 diagrams export model --selected-view productStructure --format svg --output target/diagrams
spec42 diagrams export model --selected-view operationalContext --format svg --output target/diagrams
spec42 diagrams export model --selected-view firmwareTaskArchitecture --format svg --output target/diagrams
spec42 diagrams export model --selected-view requirementsTraceability --format svg --output target/diagrams
```

## More Documentation

- [`docs/MODEL_GUIDE.md`](docs/MODEL_GUIDE.md) - model layers, package map, and engineering threads.
- [`docs/MODEL_CONVENTIONS.md`](docs/MODEL_CONVENTIONS.md) - naming, imports, comments, package ownership, and future folder structure.
- [`docs/VALIDATION.md`](docs/VALIDATION.md) - Spec42 setup, library paths, validation commands, and known tool notes.

## Babel42

Sync into Babel42's `third_party/` tree from a sibling checkout, then enable demo mode or install the demo project from the bootstrap UI:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync-sysml-robot-vacuum-cleaner-from-local.ps1
```

Set `BABEL42_DEMO_MODE=true` or use `BABEL42_ROBOT_VACUUM_MODEL_PATH` when developing against a local clone of this repository.
