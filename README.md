# Autonomous Floor Cleaning Robot (SysML v2)

Canonical SysML v2 model for an autonomous floor-cleaning robot. One top-level package per `.sysml` file (webshop-style workspace layout) so `private import PackageName::*` resolves across files.

Used as the Babel42 bootstrap demo, Spec42 validation corpus, and teaching example for requirements traceability, subsystem architecture, behavior, verification, and analysis.

## Purpose

Model a residential robot vacuum with:

- stakeholder and system requirements (implicit usages with `@RequirementRole` and `@StatusInfo` metadata)
- requirement derivation from user needs to system requirements
- subsystem decomposition with power, mass, and BOM roll-ups
- operating behavior state machine
- verification cases with physical and model-based evidence
- analysis cases for power, cost, mass, and mission energy

## Library dependencies

Requires packages from [sysml-domain-libraries](https://github.com/elan8/sysml-domain-libraries), especially:

- `RequirementMetadata` (`RequirementRole`, `RequirementRoleKind`)
- `ModelingMetadata` (`StatusInfo`, OMG `StatusKind`)
- `RequirementManagement` (evidence, baseline, traceability scaffolding — not requirement defs)
- `MonetaryUnits` (`MonetaryAmount`)
- `ISQ` / `SI` quantity types

Point your tool's library roots at `domain/`, `technical/`, and `generic/` under that repository.

## Try it with Spec42

From a checkout that includes domain libraries on the library path:

```bash
spec42 check model/
```

## Try it with Babel42

Sync into Babel42's `third_party/` tree (sibling checkout or fetch script), then enable demo mode or install the demo project from the bootstrap UI:

```powershell
# From babel42 repo root (sibling checkout)
powershell -ExecutionPolicy Bypass -File scripts\sync-sysml-robot-vacuum-cleaner-from-local.ps1
```

Set `BABEL42_DEMO_MODE=true` or use **Install demo project** on first bootstrap.

Override the model directory with `BABEL42_ROBOT_VACUUM_MODEL_PATH` when developing against a local clone of this repository.

## Design limits

| Attribute | Value |
|-----------|-------|
| BOM budget | 400 EUR |
| Mass budget | 5.0 kg |

Defined in `DesignLimits.sysml` and referenced by system requirements and analysis cases.

## Files

| File | Package | Purpose |
|------|---------|---------|
| [AutonomousFloorCleaningRobotDemo.sysml](model/AutonomousFloorCleaningRobotDemo.sysml) | `AutonomousFloorCleaningRobotDemo` | Root hub — imports all project packages |
| [StakeholderNeeds.sysml](model/StakeholderNeeds.sysml) | `StakeholderNeeds` | User requirements |
| [SystemRequirements.sysml](model/SystemRequirements.sysml) | `SystemRequirements` | System requirements and derivations |
| [DesignLimits.sysml](model/DesignLimits.sysml) | `DesignLimits` | BOM and mass budgets |
| [Architecture.sysml](model/Architecture.sysml) | `Architecture` | Subsystems, connections, `satisfy` |
| [BehaviorStates.sysml](model/BehaviorStates.sysml) | `BehaviorStates` | Operating state machine |
| [Verification.sysml](model/Verification.sysml) | `Verification` | Verification cases |
| [AnalysisCases.sysml](model/AnalysisCases.sysml) | `AnalysisCases` | Power, cost, mass, energy roll-ups |

## Suggested reading order

1. `StakeholderNeeds.sysml` — user needs
2. `SystemRequirements.sysml` — derived system requirements
3. `Architecture.sysml` — physical/logical decomposition and traceability
4. `BehaviorStates.sysml` — mission lifecycle states
5. `Verification.sysml` and `AnalysisCases.sysml` — V&V and parametric evidence
6. `AutonomousFloorCleaningRobotDemo.sysml` — full workspace import hub

## Parser notes

- Transition names must not start with parser keywords as a prefix; use `to_charging` instead of `docked` in `BehaviorStates.sysml`.
- Requirements and verifications are **usages** typed from library defs, not project-local requirement definitions.
