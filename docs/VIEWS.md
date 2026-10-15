<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Focused model views

Each view in `model/90_views/ModelViews.sysml` answers one engineering question.
The view's `doc` states its scope alongside its exposes and filter.

| View | Engineering question | Selected content | Export depth |
| --- | --- | --- | --- |
| `productDecomposition` | What constitutes this robot baseline at the top level? | Physical robot, six hardware modules and referenced firmware task group | 1 |
| `baseDecomposition` | What constitutes the base? | Contextual base and its mechanical, sensing, cleaning, docking and power components | 1 |
| `topDecomposition` | What constitutes the top module? | Contextual top and its sensing, enclosure and interaction components | 1 |
| `mainPcbDecomposition` | What constitutes the main PCB assembly? | Contextual board assembly, bare PCB, MCU, drivers, IMU and wireless components | 1 |
| `powerDecomposition` | What constitutes the power module? | Contextual power module, battery, BMS, charger, regulators and SMBus | 1 |
| `interconnections` | How do the six hardware modules connect at their boundaries? | Six modules with boundary ports and inter-module connectors; internal connections stay inside closed modules | 0 |
| `firmwareDeployment` | Which processor hosts each firmware task? | Seven task usages, MCU usage and task-to-processor allocations | 0 |
| `systemRequirements` | Which requirements constrain this baseline? | System requirement collection and its 21 requirements | 1 |
| `cliffSafeStopScenario` | How does a cliff observation lead to stopped actuation and reported status? | Scenario actions, parameter flows and successions | Action-flow rendering |

The five composition views select part usages in the robot context. A label such
as `charger : RobotBatteryCharger` identifies the reusable definition without
adding a second definition tree. Inherited members remain part of the effective
structure of the usage. These views do not claim to show procurement choices,
electrical routing, requirement evidence or timing budgets.

The product view includes the `ref part firmwareTasks` group because it is part
of the robot's effective architecture. It is a reference, not another hardware
module. The deployment view addresses which processor hosts those tasks.

The interconnection view intentionally exposes modules separately rather than
the whole robot: this avoids introducing the firmware task group into the
hardware boundary diagram. Open a module in the editor to investigate an
internal endpoint. The document views in `model/95_documents/Documents.sysml`
provide separate base, power, PCB and top interconnection diagrams; the document
trace tables cover derivation, satisfaction and verification.

## Rendering

With a Spec42 build supporting `spec42 diagram`, run:

```powershell
./scripts/render-views.ps1 -Spec42Exe <path-to-spec42>
```

To also produce PNGs, supply `-ResvgExe <path-to-resvg>`. Outputs are written to
the ignored `target/model-views/` directory: nine SVGs, their complete diagram
products, optional PNGs and an HTML gallery. The script fails on an export error
or an incomplete diagram projection. Depth controls presentation only; the JSON
products retain the selected content and relationships.

The sibling library defaults match `validate.ps1`; override them with
`-DomainLibrariesRoot` and `-MethodLibraryRoot` when necessary. The local Spec42
rendering corrections for allocations, inherited ports, connections owned by
enclosing assemblies and ownership layout must
be present to reproduce the reviewed diagrams; model validation is independent
of those renderer changes.
