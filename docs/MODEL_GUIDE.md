<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Model guide

The model is intentionally small enough to read end to end. File paths follow
the Elan8 Method layout; SysML packages remain the semantic ownership boundary.

Start with the [Elan8 Method tour](ELAN8_METHOD_TOUR.md) for the cliff-safe-stop
vertical increment.

## Recommended tour

1. Start in `10_purpose/Requirements.sysml`: six stakeholder needs derive twelve
   testable requirements with quantities, constraints, and Elan8 requirement roles.
2. Read `20_behavior/FunctionalBehavior.sysml`: `OperateCleaningRobot` decomposes
   product behavior. Follow `CliffSafeStopGoldenThread`.
3. Open `30_architecture/PhysicalArchitecture.sysml`: the selected baseline
   contains the major LRUs, typed interfaces, power rails, and catalog selections.
4. Follow `Architecture::robotSystem`. Its `operate` behavior usage is used for
   allocation and requirement satisfaction.
5. Inspect `30_architecture/FirmwareArchitecture.sysml`: seven tasks, queues, and
   timing.
6. Continue into `40_analysis/Analysis.sysml` (`SafetyReactionAnalysis`) and
   `50_verification/Verification.sysml` (`verifyCliffSafeStop`).
7. Finish with the six views in `60_views/ModelViews.sysml`.

## Semantic backbone

```mermaid
flowchart LR
  N["Stakeholder need"] -->|derive| R["System requirement"]
  R -->|satisfy by| B["robotSystem.operate / scenario"]
  B -->|allocate to| P["Physical LRU / firmware task"]
  P -->|selected implementation dependency| T["Purchased part definition"]
  P -->|typed connect / flow| P
  V["Verification case / analysis"] -->|verify| R
  W["View"] -->|expose| R
  W -->|expose| B
  W -->|expose| P
  W -->|expose| V
```

## Package ownership

| Package | Owns |
| --- | --- |
| `Project` | Tailoring and method profile |
| `Elan8::Units::Engineering` | Shared Ah/mAh/ms unit literals |
| `Elan8::Procurement` | `BuyPart` metadata and `PartLifecycleStatus` |
| `PurchasedParts` | Concrete catalog part selections annotated with `Elan8::Procurement::BuyPart` |
| `DomainModel` | Protocol vocabulary, items, ports, buses |
| `DesignLimits`, `StakeholderNeeds`, `SystemRequirements` | Product intent and constraints |
| `FunctionalArchitecture`, `BehaviorStates`, `OperationalScenarios` | Capabilities, states, scenarios |
| `ProductContext` | Users, app, network, dock, home, robot boundary |
| `Elan8::Software::Realtime` | `RealtimeTask`, `SoftwareQueue`, `SchedulerModel`, and their criticality/discipline/policy enums |
| `FirmwareArchitecture` | Vacuum-specific tasks, queues, and `StartupPhase` |
| `Elan8::Electronics::Actuation` | BLDC and brushed-DC motors, H-bridge and three-phase drivers, and mechanical outputs |
| `Elan8::Electronics::Sensing` | Powered/data sensors, I2C IMU, passive bumper/lift switches, and typed measurements |
| `Elan8::Electronics::Power` | `BatteryPack`, `BatteryManagementSystem`, and `VoltageRegulator` |
| `Elan8::Electronics::{Board, Assembly}` | Bare `PrintedCircuitBoard` versus populated `PrintedCircuitBoardAssembly` |
| `Elan8::Mechanical::Core` | `MechanicalComponent` (`mass` only, purely mechanical parts — no ports, no `powerDraw`) |
| `Elan8::Mechanical::Drivetrain` | `Gearbox`, `Wheel`, `CasterWheel` |
| `PhysicalArchitecture` | Assembly-oriented baseline. Drive motors use `ThreePhaseDrivePort`; cleaning motors use brushed-DC motors with H-bridge drivers; powered sensors expose power plus protocol-specific `data`, while passive switches expose only `signal`. `MainPcbModule` is the populated PCB assembly. |
| `Architecture` | Concrete system, allocations, satisfaction |
| `AnalysisCases` | Three analyses |
| `Verification` | Nine verification cases |
| `ModelViews` | Six stakeholder projections |

## Purchased parts

`BuyPart` is metadata for `SysML::PartDefinition`. Project definitions specialize
domain kinds; a named `dependency selectedImplementation` points at catalog parts.

## Deliberate boundaries

This baseline omits product-line engineering, trade studies, and handoff record
tables. It **does** use Elan8 Method libraries for requirement roles and concerns
on the cliff-safe-stop engineering increment. Narrative guidance beyond semantics belongs
in `doc` and markdown tours.
