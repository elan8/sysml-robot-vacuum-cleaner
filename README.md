<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Autonomous Floor Cleaning Robot (SysML v2)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![SysML v2](https://img.shields.io/badge/SysML-v2-0f8fa8.svg)](https://www.omg.org/spec/SysML/)
[![Spec42](https://img.shields.io/badge/validated%20with-Spec42-0f8fa8.svg)](https://github.com/elan8/spec42)

![Autonomous floor cleaning robot in action](docs/assets/robot-vacuum-hero.png)

A compact, graph-first SysML v2 showcase for an autonomous vacuum cleaner. It
uses one selected product baseline, seven firmware tasks, six catalog parts and
one cliff-safe-stop golden thread. Every view projects the same authoritative
requirements, behavior, architecture and verification elements.

## What the showcase demonstrates

- Definition/usage separation and one concrete `robotSystem` usage.
- Typed items, ports, connections, flows and allocations instead of internal
  identity encoded as strings.
- Requirements satisfied by concrete behavior usages and verified by nine
  verification cases plus three quantitative analyses.
- A reusable `PurchasedParts` library whose `BuyPart` metadata annotates
  `SysML::PartDefinition`; named dependencies select catalog implementations
  without turning procurement choice into type specialization.
- A seven-task runtime with formal timing/resources, five typed queues and
  allocations to concrete MCU peripherals.
- Six curated views: `productDecomposition`, `interconnections`,
  `firmwareRuntime`, `requirementsTraceability`,
  `cliffSafeStopGoldenThread` and `selectedParts`.

The scope deliberately excludes product variants, trade studies, custom safety
records, implementation handoff tables and methodology metadata. Human-facing
external identifiers such as manufacturer part numbers and datasheet URLs stay
text; internal model identity is semantic.

## Model map

The complete model consists of twelve documents:

| Document | Purpose |
| --- | --- |
| `VacuumCleanerQuantitiesAndUnits.sysml` | Project units. |
| `PurchasedParts.sysml` | Extractable buy-part catalog and metadata. |
| `DomainModel.sysml` | Shared items, ports and bus definitions. |
| `Requirements.sysml` | Six needs, design limits and core requirements. |
| `FunctionalBehavior.sysml` | Capabilities, two state behaviors and scenarios. |
| `Context.sysml` | Residential actors and system boundary. |
| `FirmwareArchitecture.sysml` | Seven tasks, scheduler and five queues. |
| `PhysicalArchitecture.sysml` | Selected LRUs, parts, rails and interconnections. |
| `Architecture.sysml` | Concrete system, allocations and satisfaction links. |
| `Verification.sysml` | Nine cases and three analyses. |
| `ModelViews.sysml` | Six projections over the graph. |
| `AutonomousFloorCleaningRobotDemo.sysml` | Workspace import hub. |

See [the model guide](docs/MODEL_GUIDE.md) for the recommended tour.

## Validation

With Spec42 and the sibling `sysml-domain-libraries` checkout available:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

The release criterion is 0 errors, 0 warnings and 0 information diagnostics,
followed by successful SVG export of all six views. See
[validation details](docs/VALIDATION.md).

## Status and limitations

This is an MBSE teaching and tool-validation model, not a certified product
design or production BOM. Catalog metadata was checked against official
manufacturer sources, but lifecycle and availability must be reviewed again
before procurement.

Contributions are welcome; keep changes graph-first, run validation and update
the focused documentation when the public model interface changes.

## License

Licensed under the [MIT License](LICENSE). See [NOTICE.md](NOTICE.md).
