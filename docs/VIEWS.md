<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Focused model views

The nine focused views live in each reviewed system's `Views` package under
`model/60_systems/<System>/system.sysml` (root: `00_VacuumCleanerSystem`). They answer one engineering question each.
The view's `doc` states its scope alongside its exposes and filter.

| View | Engineering question | Selected content | Export depth |
| --- | --- | --- | --- |
| `productDecomposition` | What constitutes this robot baseline at the top level? | Physical robot, six hardware modules and referenced firmware task group | 1 |
| `baseDecomposition` | What constitutes the base? | Contextual base and its mechanical, sensing, cleaning, docking and power components | 1 |
| `topDecomposition` | What constitutes the top module? | Contextual top and its sensing, enclosure and interaction components | 1 |
| `mainPcbDecomposition` | What constitutes the main PCB assembly? | Contextual board assembly, bare PCB, MCU, drivers, IMU and wireless components | 1 |
| `powerDecomposition` | What constitutes the power module? | Contextual power module, battery, BMS, charger, regulators and SMBus | 1 |
| `interconnections` | How do the six hardware modules connect at their boundaries? | Six modules with boundary ports and inter-module connectors; internal connections stay inside closed modules | 0 |
| `firmwareDeployment` | Which processor hosts each firmware task? | Seven tasks, scheduler execution platform, MCU and their allocations | 0 |
| `systemRequirements` | Which requirements constrain this baseline? | System requirement collection and its 21 requirements | 1 |
| `cliffSafeStopScenario` | How does a cliff observation lead to stopped actuation and reported status? | Scenario actions, parameter flows and successions | Action-flow rendering |

The five composition views select constituent part usages in the robot context,
explicitly excluding connection and allocation usages (also subtypes of PartUsage).
A label such
as `charger : RobotBatteryCharger` identifies the reusable definition without
adding a second definition tree. Inherited members remain part of the effective
structure of the usage. These views do not claim to show procurement choices,
electrical routing, requirement evidence or timing budgets.

The product view includes the `ref part firmwareTasks` group because it is part
of the robot's effective architecture. It is a reference, not another hardware
module. The deployment view shows tasks allocated to their scheduler execution platform,
which is allocated to the processor.

The interconnection view intentionally exposes modules separately rather than
the whole robot: this avoids introducing the firmware task group into the
hardware boundary diagram. Open a module in the editor to investigate an
internal endpoint. The document views in `model/80_documents/Documents.sysml`
provide separate base, power, PCB and top interconnection diagrams; the document
trace tables cover derivation, satisfaction and verification.

## Rendering

With the rendering build pinned in `dependencies.lock.json`, run:

```powershell
./scripts/render-views.ps1 -Spec42Exe <path-to-spec42>
```

To also produce PNGs, supply `-ResvgExe <path-to-resvg>`. Outputs are written to
the ignored `generated/views/` directory: nine SVGs, their complete diagram
products, optional PNGs and an HTML gallery. The script fails on an export error
or an incomplete diagram projection. Depth controls presentation only; the JSON
products retain the selected content and relationships.

The sibling library defaults match `validate.ps1`; override them with
`-DomainLibrariesRoot` when necessary. Validate before exporting. Released
Spec42 0.56.0 lacks Boolean filter preparation and derived-view discovery;
use the exact rendering source revision recorded in VALIDATION.md and the lock
file. Pass `-IncludeMethodologyViews` to export all thirteen.

## Authored product illustrations

`model/80_documents/figures/product-layout.svg` uses the physical model's longitudinal
coordinates: forward side brushes at +100 mm, main roller at +75 mm, suction
intake at +55 mm and rear caster at -140 mm, relative to the drive axle.
Forward is up in plan and left in the side elevation. The plan includes
underside components seen through the chassis. The 80 mm dashed brush circles
show swept extent; the 340 mm dimension is the nominal body diameter.
The 65 mm drive wheels and 55 + 37 mm design height use the same 0.88 px/mm
scale in both views. Height budgets (57 + 38 mm) are labeled separately.

The hero image, product layout and system architecture depict the same two
side brushes. The system architecture groups their shared transmission and
main roller under the brush motor; detailed parts and mass come from the model.
The other authored figures were checked against the context and timing model:
three ToF sensors, four cliff sensors, two wheel-drop switches, seven firmware
tasks, a 14.4 V battery, a 2 A charger, and a 72 ms safe-stop design against the
100 ms limit. Authored figures must be reviewed when those model values change.


## Canonical view owners and methodology views

| Focused view | System owner |
| --- | --- |
| `productDecomposition` | `RobotPlatformSystem::Views` |
| `baseDecomposition` | `BaseSystem::Views` |
| `topDecomposition` | `TopSystem::Views` |
| `mainPcbDecomposition` | `MainControlBoardSystem::Views` |
| `powerDecomposition` | `PowerSystem::Views` |
| `interconnections` | `RobotPlatformSystem::Views` |
| `firmwareDeployment` | `FirmwareSystem::Views` |
| `systemRequirements` | `RobotPlatformSystem::Views` |
| `cliffSafeStopScenario` | `VacuumCleanerSystem::Views` |

The additional context view is `ProductContext::context`. The three role views
are `VacuumCleanerSystem::Views::{specification,architecture,integration}`.
They use shared `Elan8::SystemsEngineering` view definitions to select project
boundary/context, contracts, decomposition and the selected product integration.
The context boundary role is separate from the selected product assembly.
The architecture role view types children by specifications; the integration
role view exposes the existing `robotSystem`, not a duplicate design.
Four custom-view diagnostics are a documented Spec42 limitation; see VALIDATION.md.
