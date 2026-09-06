<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Elan8 Method tour

This showcase is laid out with Elan8 Method folders and imports
`mbse-methodology/library` alongside `sysml-domain-libraries`. Engineering
increments are a way to plan and review coherent changes; they are not product
concepts. The resulting SysML therefore uses names from the robot-vacuum domain.

## Folder map

| Folder | Content |
| --- | --- |
| `00_project/` | Project info (`ProjectInfo`, small profile) |
| `10_purpose/` | Context, stakeholder needs, design limits, system requirements |
| `20_behavior/` | Functional actions, states, and operational scenarios |
| `30_architecture/` | Domain model, physical + firmware architecture, SOI allocations |
| `40_analysis/` | Mission energy, safety reaction, localization analyses |
| `50_verification/` | Nine verification cases including `verifyCliffSafeStop` |
| `60_views/` | Six curated views |
| `90_library/` | Purchased parts catalog (`Elan8::Units::Engineering`) |
| `Root.sysml` | Import hub |

## Example increment coverage

| Method piece | Model anchor |
| --- | --- |
| Stakeholder concern / need | `StakeholderNeeds::operateSafely` (`USR-SAFE-001`) |
| Derived requirements | `detectCliffs`, `superviseHazards`, `reportCleaningStatus` |
| Scenario | `OperationalScenarios::CliffSafeStopScenario` |
| Architecture | Allocations on `Architecture::robotSystem` / scenario satisfy links |
| Evidence | `AnalysisCases::SafetyReactionAnalysis` |
| Verification | `Verification::verifyCliffSafeStop` |
| View | `ModelViews::cliffSafeStopScenario` |

This table is a method-oriented reading path across ordinary model elements. It
does not introduce a separate trace object into the product model.

## Operational scenario set

1. `AutonomousCleaningScenario` — clean reachable floor and return to dock.
2. `ObstacleAvoidanceScenario` — observe, replan, and continue safely.
3. `LowBatteryReturnScenario` — terminate cleaning, dock, and recharge.
4. `CliffSafeStopScenario` — detect a stair edge, stop, and report status.

## Libraries

- **Method:** `Elan8::Method::{Core, Requirements, Metadata, Viewpoints}`
- **Domain/technical:** namespaced `Elan8` electronics, mechanical, software,
  communication, units, and procurement vocabularies

See also [MODEL_GUIDE.md](MODEL_GUIDE.md) and
[mbse-methodology recipes](../../mbse-methodology/recipes/README.md).
