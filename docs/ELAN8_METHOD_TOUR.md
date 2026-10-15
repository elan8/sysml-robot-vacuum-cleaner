<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Elan8 Method tour

This showcase is laid out with Elan8 Method folders and imports
`sysml-domain-libraries`; the method itself needs no library. Engineering
increments are a way to plan and review coherent changes; they are not product
concepts. The resulting SysML therefore uses names from the robot-vacuum domain.

## Folder map

| Folder | Content |
| --- | --- |
| `00_project/` | Project information |
| `05_requirements/` | Customer, system and module requirements, design limits, budgets, derivations |
| `10_context/` | External actors and the operating boundary |
| `20_usecases/` | Operational scenarios |
| `40_functions/` | Functional actions and operating states |
| `50_logical/` | Domain model and firmware architecture |
| `60_physical/` | Physical architecture and SOI allocations |
| `70_analysis/` | Mission energy, safety reaction, localization and mass budget analyses |
| `80_verification/` | Twelve verification cases including `'Cliff safe stop'`, and five validation cases |
| `90_views/` | Nine focused views |
| `99_library/` | Purchased parts catalog and bill-of-materials classification |
| `Root.sysml` | Import hub |

## Example increment coverage

| Method piece | Model anchor |
| --- | --- |
| Customer requirement | `StakeholderNeeds::'Safe operation in the household'` (`USR-SAFE-001`) |
| Derived system requirements | `'Cliff detection'`, `'Safe stop on hazard'`, `'Mission status reporting'` |
| Module budgets | `'Cliff sensing latency'`, `'Safety supervisor deadline'`, `'Drive disable latency'`, `'Drive braking time'` |
| Scenario | `OperationalScenarios::CliffSafeStopScenario` |
| Architecture | Allocations on `Architecture::robotSystem` / scenario satisfy links |
| Evidence | `RobotAnalysisCases::SafetyReactionAnalysis` |
| Verification | `Verification::'Cliff safe stop'` (VER-009) |
| Validation | `Validation::'Household safety walkthrough'` (VAL-003) |
| View | `ModelViews::cliffSafeStopScenario` |

This table is a method-oriented reading path across ordinary model elements. It
does not introduce a separate trace object into the product model.

## Operational scenario set

1. `AutonomousCleaningScenario` — clean reachable floor and return to dock.
2. `ObstacleAvoidanceScenario` — observe, replan, and continue safely.
3. `LowBatteryReturnScenario` — terminate cleaning, dock, and recharge.
4. `CliffSafeStopScenario` — detect a stair edge, stop, and report status.

## Libraries

- **Domain/technical:** namespaced `Elan8` electronics, mechanical, software,
  communication, units, and procurement vocabularies

See also [MODEL_GUIDE.md](MODEL_GUIDE.md) and
[Elan8 Method guidance](../../mbse-methodology/docs/README.md).
