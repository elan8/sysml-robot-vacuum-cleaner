<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Elan8 Method tour (cliff safe-stop)

This showcase is laid out with Elan8 Method folders and imports `mbse-methodology/library` alongside `sysml-domain-libraries`. The **cliff safe-stop engineering increment** is one end-to-end capability slice through the model (scenario element: `CliffSafeStopGoldenThread`).

## Folder map

| Folder | Content |
| --- | --- |
| `00_project/` | Project info (`ProjectInfo`, small profile) |
| `10_purpose/` | Context, stakeholder needs, design limits, system requirements |
| `20_behavior/` | Functional actions, states, cliff scenario |
| `30_architecture/` | Domain model, physical + firmware architecture, SOI allocations |
| `40_analysis/` | Mission energy, safety reaction, localization analyses |
| `50_verification/` | Nine verification cases including `verifyCliffSafeStop` |
| `60_views/` | Six curated views |
| `90_library/` | Purchased parts catalog (`EngineeringUnits` from domain libraries) |
| `Root.sysml` | Import hub |

## Increment spine

| Method piece | Model anchor |
| --- | --- |
| Stakeholder concern / need | `StakeholderNeeds::operateSafely` (`USR-SAFE-001`) |
| Derived requirements | `detectCliffs`, `superviseHazards`, `reportCleaningStatus` |
| Scenario | `OperationalScenarios::CliffSafeStopGoldenThread` |
| Architecture | Allocations on `Architecture::robotSystem` / scenario satisfy links |
| Evidence | `AnalysisCases::SafetyReactionAnalysis` |
| Verification | `Verification::verifyCliffSafeStop` |
| View | `ModelViews` cliff-safe-stop view |

## Recipes touched

1. Purpose / concerns — user need `operateSafely`
2. Context — `ProductContext::ResidentialCleaningContext`
3. Scenario — cliff increment (`CliffSafeStopGoldenThread`)
4. Derive requirements — safety system requirements with subjects
5. Logical/physical — actions allocated to LRUs/firmware (no parallel logical tree)
6. Verification — `verifyCliffSafeStop` + reaction analysis
7. Degraded outcome — safe stop / mission abort path inside the scenario

## Libraries

- **Method:** `Elan8RequirementMetadata`, `Elan8RequirementManagement`, `Elan8Method`
- **Domain/technical:** robotics/electronics/communication vocabulary via domain model and Spec42 library paths

See also [MODEL_GUIDE.md](MODEL_GUIDE.md) and [mbse-methodology recipes](../../mbse-methodology/recipes/README.md).
