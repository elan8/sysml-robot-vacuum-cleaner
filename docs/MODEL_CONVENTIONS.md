<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Model Conventions

These conventions keep the SysML model readable and maintainable while preserving tool compatibility.

## File And Package Layout

- Keep one top-level package per `.sysml` file.
- Keep package names stable; file moves should not rename packages.
- Treat `AutonomousFloorCleaningRobotDemo` as the full-workspace import hub.
- Treat `Architecture` as the public architecture hub for downstream packages that need the realized robot type.
- Keep the `model/` directory flat until Spec42 and Babel42 recursive loading are verified after any proposed move.

## Package Ownership

- Requirements packages own requirement intent and derivation. They should not own implementation structure.
- `FunctionalArchitecture` owns capability and mission action definitions. It should not own PCB, harness, or task scheduling details.
- `PhysicalArchitecture` owns product assemblies, physical ports, firmware suite parts, and roll-up values. It should not own connector metadata tables or software message schemas.
- `ElectricalInterfaces` owns implementation-facing PCB interface-control records.
- `InterfaceControl` owns software message contracts and producer/consumer ownership.
- `FirmwareArchitecture` owns task timing, task criticality, scheduler assumptions, and task-to-module allocation surfaces.
- Assurance packages own evidence, hazards, analyses, trade rationale, and verification intent.
- `ModelViews` owns stakeholder slices only; do not put primary engineering facts there.

## Imports

- Prefer `private import PackageName::*` inside model packages.
- Use public imports only for deliberate hubs such as `Architecture`.
- Do not add broad imports to avoid fixing a missing dependency; import the package that owns the referenced concept.
- Keep imports grouped before model content and avoid unused import churn unless a tool reports it.

## Naming

- Use nouns for parts, ports, data contracts, analyses, and views.
- Use verb phrases for actions and verification cases.
- Use domain-specific names over generic placeholders.
- Keep requirement names short and stable because they are referenced by satisfy, verify, view, and analysis relationships.
- Use explicit deferred names for non-baseline options, for example `DeferredVisionObstacleSoftware`.

## Comments And Documentation

- Use package-header comments to state ownership, dependencies, and boundaries.
- Use `doc /* ... */` when the explanation is model content that should travel with the element.
- Use `//` only for local parser/tooling notes or short section markers.
- Do not comment trivial attributes whose names and values are self-explanatory.
- Add rationale near non-obvious tradeoffs, package boundaries, allocations, and safety assumptions.

## Deferred Options

- Keep deferred product tiers visible when they explain a trade study or future variant.
- Mark deferred implementation elements explicitly with attributes such as `selectedForBaseline = false` or text values such as `deferred flagship`.
- Do not allocate deferred options into the baseline operational path unless the model intentionally changes product selection.

## Validation Discipline

- Run `scripts/validate.ps1` after changing model files.
- Run selected diagram exports after changing `ModelViews`, package structure, or view exposure paths.
- Keep validation notes in `docs/VALIDATION.md`.
- Keep tool-specific investigation notes outside the public repository.

## Open-Source Contribution Rules

- Preserve package ownership boundaries unless the PR explicitly changes and documents them.
- Validate before opening a PR; warnings are treated as failures in CI.
- Keep generated repository assets under `docs/assets/` and avoid visible third-party brand marks.
- Use MIT SPDX identifiers for new text files.
- Do not add links to private workspaces, local absolute paths, or internal investigation documents in public docs.
