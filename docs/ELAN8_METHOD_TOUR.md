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
| `00_project/` | Project info (`ProjectInfo`) |
| `05_requirements/` | Stakeholder needs, design limits, system requirements |
| `10_context/` | External actors and the operating boundary |
| `20_usecases/` | Operational scenarios |
| `40_functions/` | Functional actions and operating states |
| `50_logical/` | Domain model and firmware architecture |
| `60_physical/` | Physical architecture and SOI allocations |
| `70_analysis/` | Mission energy, safety reaction, localization analyses |
| `80_verification/` | Nine verification cases including `verifyCliffSafeStop` |
| `90_views/` | Nine focused views |
| `99_library/` | Purchased parts catalog (`Elan8::Units::Engineering`) |
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

- **Method:** `Elan8Method` (`MethodCore`, `MethodMetadata`, `Viewpoints`)
- **Domain/technical:** namespaced `Elan8` electronics, mechanical, software,
  communication, units, and procurement vocabularies

See also [MODEL_GUIDE.md](MODEL_GUIDE.md) and
[mbse-methodology recipes](../../mbse-methodology/recipes/README.md).
