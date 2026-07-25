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
- Treat `Strata` as the lightweight method library for ownership, maturity, extractability, and handoff rules.
- Use `model/` subfolders only as navigation aids; SysML package ownership remains independent of file paths.

## Package Ownership

- `VacuumCleanerQuantitiesAndUnits` owns project-specific measurement-unit declarations and their standard-library-based conversions. It should not duplicate units already declared by the loaded OMG libraries.
- `Strata` owns way-of-working concepts, metadata definitions, completeness rules, and extraction rules. It should not own product-specific engineering facts.
- Requirements packages own requirement intent and derivation. They should not own implementation structure.
- `FunctionalArchitecture` owns capability and mission action definitions. It should not own PCB, harness, or task scheduling details.
- `PhysicalArchitecture` owns product assemblies, physical ports, harness ICD notes, semantic rail budgets, the `firmwareTasks` and `robotFirmware` instances, task/module/MCU/peripheral allocations, and roll-up values. It should not own software message schemas.
- `ProductVariants` owns product-line variation definitions, selected/deferred variant option records, and SKU configuration baselines. It should not duplicate trade rationale or realized architecture details.
- `InterfaceControl` owns software message contracts and producer/consumer ownership.
- `FirmwareArchitecture` owns firmware task definitions, scheduler model, typed queues, task architecture structure, flows, and interface-control contracts. The authoritative `firmwareTasks` instance lives on `AutonomousFloorCleaningRobot` in `PhysicalArchitecture`.
- `ElectronicsInterfaceControl` owns only reusable electronics-interface metadata. Concrete connector identity, limits, pinout guidance, and connectivity live on physical ports and harness parts.
- `ElectronicsComponentSelection` owns baseline component candidates, MPNs, footprints, key specs, cost targets, lifecycle status, and selection rationale. It should mark candidates that still need datasheet, lifecycle, compliance, or availability checks.
- `Implementation` owns engineer-facing views over runtime, peripheral access, interfaces, rails, and component selections. It should not duplicate any primary engineering facts.
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

## Semantic Links Before Text

- Use `ref`, typed usages, feature values, connection ends, `connect`, `flow`,
  `allocate`, `satisfy`, and `verify` for model identity and traceability.
- Do not store a qualified model path or an element name in `String` when the
  target exists in the loaded model and can be referenced directly.
- Do not repeat the payload type as text when it follows from typed ports,
  action parameters, items, or connection ends.
- Keep strings for genuine prose and external identifiers: rationale, human
  guidance, manufacturer part numbers, source-code symbols, external URLs, and
  identifiers owned by systems outside the SysML model.
- If current tooling cannot resolve a canonical relationship, keep the real
  typed `flow`, `connect`, allocation, or trace relationship as the source of
  truth and label any temporary string bridge explicitly as a compatibility
  field.

## Comments And Documentation

- Use package-header comments to state ownership, dependencies, and boundaries.
- Use `doc /* ... */` when the explanation is model content that should travel with the element.
- Use `//` only for local parser/tooling notes or short section markers.
- Do not comment trivial attributes whose names and values are self-explanatory.
- Add rationale near non-obvious tradeoffs, package boundaries, allocations, and safety assumptions.

## Strata Metadata

- Use native SysML v2 relationships first; use Strata method metadata for ownership, maturity, extraction, and external references.
- Prefer tagging package entry points, handoff baselines, source-of-truth records, and view/report roots over tagging every small feature.
- Do not encode requirements, allocations, interfaces, or verification links only as metadata when native SysML relationships are available.
- Keep extraction-oriented string paths as compatibility bridges only where
  current tooling cannot resolve the intended feature path. Remove the bridge
  once the canonical relationship validates and downstream extraction can
  follow it.

## Deferred Options

- Keep deferred product tiers visible when they explain a trade study or future variant.
- Model product-line choices in `ProductVariants` using native SysML v2 `variation` and `variant` definitions first, then add lightweight records for selection status and extraction.
- Keep trade rationale in `TradeStudies`; keep the actual selected structure in architecture and implementation packages.
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
