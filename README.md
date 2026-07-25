<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Autonomous Floor Cleaning Robot (SysML v2)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![SysML v2](https://img.shields.io/badge/SysML-v2-0f8fa8.svg)](https://www.omg.org/spec/SysML/)
[![Spec42](https://img.shields.io/badge/validated%20with-Spec42-0f8fa8.svg)](https://github.com/elan8/spec42)

![Autonomous floor cleaning robot in action](docs/assets/robot-vacuum-hero.png)

SysML v2 model for an autonomous floor-cleaning robot. The model is used as an example for requirements traceability, subsystem architecture, behavior, verification, and analysis.

The workspace keeps one top-level package per `.sysml` file under [`model/`](model/), grouped by engineering layer. Package names remain independent of file paths so `private import PackageName::*` resolves consistently across tools.

## Why This Exists

This repository gives systems engineers, tool builders, and educators a realistic SysML v2 corpus that is larger than a toy example but still small enough to read end to end.

It demonstrates how requirements, functional architecture, physical architecture, firmware allocation, safety analysis, verification, analysis cases, and stakeholder views can live together in one coherent model.

The repository also includes the Elan8 methodology, a lightweight SysML v2 way
of working for cyber-physical and software-only systems. It defines method
concepts, metadata, completeness rules, and extraction rules so tools can
reliably discover handoff information from the model.

## Highlights

- Requirements-to-architecture-to-verification traceability across needs, system requirements, design elements, verification cases, and analyses.
- Functional and physical decomposition with explicit allocation layers.
- Product-line variant modeling for navigation sensor suites, cleaning performance, battery pack, safety monitor, connectivity, privacy mode, dock options, and SKU baselines.
- Implementation-facing interface control for PCB harnesses, software message contracts, firmware tasks, scheduler timing, and MCU deployment.
- An implementation layer tying software contracts, firmware runtime/resource constraints, electronics interfaces, PCB/harness work packages, component candidates, queue policies, HAL bindings, rail budgets, timing budgets, and verification scope together.
- A lightweight `Elan8Methodology` package that separates native SysML v2 engineering semantics from metadata used for ownership, maturity, extraction, and external lifecycle references.
- Safety assurance, design trade studies, and technical margins instead of structure-only modeling.
- First-class SysML v2 views for context, structure, interconnections, behavior, traceability, safety, deployment, and rationale.

## Validation

This model was built and validated using Spec42.
Spec42 is open source at [`elan8/spec42`](https://github.com/elan8/spec42). Pull requests are also validated by the Spec42 GitHub Action in this repository.

## Tool and Library Requirements

The model imports packages from the SysML v2 standard library and from the Elan8 domain libraries, including the electronics-focused KPAR packages published in [`elan8/sysml-domain-libraries`](https://github.com/elan8/sysml-domain-libraries).

Project-specific measurement units are declared in [`VacuumCleanerQuantitiesAndUnits.sysml`](model/libraries/VacuumCleanerQuantitiesAndUnits.sysml). The `Ah`, `mAh`, and `ms` symbols are explicit model elements rather than tool-provided shorthand.

Spec42 resolves the required libraries in its validation workflow. If you open or validate this repository with another SysML v2 tool, make sure that tool has access to both the SysML v2 standard library KPAR and the Elan8 domain-library KPARs, or configure equivalent library search paths before loading `model/`.

## What Is Modeled

- Stakeholder needs, derived system requirements, verification cases, and analysis evidence.
- Functional capabilities for locomotion, cleaning, perception, navigation, power, docking, safety, and user interaction.
- Physical assemblies with typed electronics harnesses, power rails, firmware deployment, and implementation-facing interface control.
- Operating lifecycle behavior, operational scenarios, safety analysis, trade studies, and canonical SysML v2 views.
- A selected privacy-conscious SLAM variant using 2D dToF/LiDAR, wheel odometry, IMU, cliff sensing, and short-range ToF sensing.

## Design Limits

| Attribute                | Value                                 |
| ------------------------ | ------------------------------------- |
| BOM budget               | 400 EUR                               |
| Mass budget              | 5.0 kg                                |
| Battery capacity budget  | 12500 mAh (12.5 Ah at 14.4 V nominal) |
| Localization error limit | 150 mm                                |
| Safe-stop reaction limit | 100 ms                                |

The limits are defined in [`DesignLimits.sysml`](model/requirements/DesignLimits.sysml) and referenced by system requirements and analysis cases.

## Suggested Reading Order

1. [`StakeholderNeeds.sysml`](model/requirements/StakeholderNeeds.sysml) - user needs
2. [`SystemRequirements.sysml`](model/requirements/SystemRequirements.sysml) - derived system requirements
3. [`Elan8Methodology.sysml`](model/method/Elan8Methodology.sysml) - Elan8 methodology concepts, metadata, completeness rules, and extraction rules
4. [`FunctionalArchitecture.sysml`](model/architecture/FunctionalArchitecture.sysml) - capabilities and functional composition
5. [`PhysicalProtocols.sysml`](model/architecture/PhysicalProtocols.sysml) - electronics library imports and product bus aliases
6. [`ProductContext.sysml`](model/context/ProductContext.sysml) - external actors and context boundary
7. [`Implementation.sysml`](model/implementation/Implementation.sysml) - software and electronics engineer handoff views
8. [`InterfaceControl.sysml`](model/implementation/InterfaceControl.sysml) - software message contracts
9. [`FirmwareArchitecture.sysml`](model/implementation/FirmwareArchitecture.sysml) - firmware tasks, typed queues, flows, and scheduler timing
10. [`ElectronicsInterfaceControl.sysml`](model/implementation/ElectronicsInterfaceControl.sysml) - electronics-interface metadata applied to physical ports
11. [`ElectronicsComponentSelection.sysml`](model/implementation/ElectronicsComponentSelection.sysml) - component candidates linked to physical targets and interfaces
12. [`PhysicalArchitecture.sysml`](model/architecture/PhysicalArchitecture.sysml) - product assemblies, typed physical connections, rail budgets, interface metadata, and peripheral allocations
13. [`ProductVariants.sysml`](model/variants/ProductVariants.sysml) - native SysML variation choices, variant option records, and SKU configuration baselines
14. [`ArchitectureAllocations.sysml`](model/architecture/ArchitectureAllocations.sysml) - function, software, compute, and peripheral-access allocations
15. [`Architecture.sysml`](model/architecture/Architecture.sysml) - public architecture hub and system-level satisfy links
16. [`BehaviorStates.sysml`](model/behavior/BehaviorStates.sysml) - mission lifecycle states
17. [`OperationalScenarios.sysml`](model/context/OperationalScenarios.sysml) - nominal and recovery mission flows
18. [`SafetyAnalysis.sysml`](model/assurance/SafetyAnalysis.sysml) and [`TradeStudies.sysml`](model/assurance/TradeStudies.sysml) - hazards and design rationale
19. [`ModelViews.sysml`](model/views/ModelViews.sysml) - stakeholder views
20. [`Verification.sysml`](model/assurance/Verification.sysml) and [`AnalysisCases.sysml`](model/assurance/AnalysisCases.sysml) - V&V and engineering margins
21. [`AutonomousFloorCleaningRobotDemo.sysml`](model/root/AutonomousFloorCleaningRobotDemo.sysml) - full workspace import hub

## More Documentation

- [`docs/MODEL_GUIDE.md`](docs/MODEL_GUIDE.md) - model layers, package map, and engineering threads.
- [`docs/MODEL_CONVENTIONS.md`](docs/MODEL_CONVENTIONS.md) - naming, imports, comments, package ownership, and future folder structure.
- [`docs/ELAN8_METHODOLOGY.md`](docs/ELAN8_METHODOLOGY.md) - Elan8 methodology guidance, handoff contracts, metadata, and extraction rules.
- [`docs/VALIDATION.md`](docs/VALIDATION.md) - Spec42 setup, library paths, validation commands, and known tool notes.

## Known Limitations

- This is an engineering-grade showcase and validation corpus, not a certified product design or regulatory compliance package.
- The robot architecture is realistic enough for MBSE demonstration, but it is not a complete commercial robot-vacuum design.
- Generated documentation imagery is illustrative and not a product rendering from a manufactured device.
- The model uses subfolders for navigation only; SysML package names remain the semantic ownership boundary.
- Electronics component selections are baseline candidates and require final datasheet, lifecycle, compliance, and availability checks before production BOM release.

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md), follow [`docs/MODEL_CONVENTIONS.md`](docs/MODEL_CONVENTIONS.md), and run validation before opening a PR.

## License

This repository is licensed under the [MIT License](LICENSE). See [`NOTICE.md`](NOTICE.md) for trademark and showcase-disclaimer notes.
