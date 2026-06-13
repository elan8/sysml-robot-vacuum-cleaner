# Spec42 Validation Report

Date: 2026-06-12 (re-validated after Spec42 metadata / requirement-conformance fixes)

Validated with the local Spec42 checkout at `C:\Git\spec42`.

## Commands

```powershell
C:\Git\spec42\target\debug\spec42.exe doctor --format json
C:\Git\spec42\target\debug\spec42.exe check model `
  --library-path C:\Git\sysml-domain-libraries\domain `
  --library-path C:\Git\sysml-domain-libraries\technical `
  --library-path C:\Git\sysml-domain-libraries\generic `
  --format json
```

## Environment

- Spec42 version: `0.30.0` (local debug build)
- Standard library: bundled **`2026-04`**, installed and canonical (`spec42 doctor` → `standard_library_status.is_installed: true`, `version_matches: true`)
- Standard library path: `%LOCALAPPDATA%\Elan8\spec42\data\standard-library\versions\2026-04\sysml.library`
- Domain libraries (default CLI): bundled `dc378a9` at `%LOCALAPPDATA%\Elan8\spec42\data\domain-libraries\versions\dc378a9\tree`
- Local checkout overrides: pass `--library-path` to `C:\Git\sysml-domain-libraries\{domain,technical,generic}` when validating unreleased library changes
- Sysand: not installed and no Sysand manifest found. Spec42 reports this as optional.

## Result

`spec42 check model --format json` completed with exit code `0`.

| Metric | Count |
| --- | ---: |
| Documents checked | 14 |
| Errors | 0 |
| Warnings | 0 |
| Information | 1 |

## Remaining diagnostic

| Code | Count | Assessment |
| --- | ---: | --- |
| `missing_initial_state` | 1 | Information-level guidance on [`RobotOperatingBehavior`](../model/BehaviorStates.sysml). The lifecycle is a deliberate cyclic controller (idle → mission → dock → charge → idle). No model change required unless an explicit initial transition is desired for tooling clarity. |

All former **warning**-level diagnostics from earlier Spec42 builds (`analysis_evaluation_unresolved`, `unknown_unit_symbol`, `unresolved_redefines_target`, `multiple_initial_states`, `missing_final_state`) are **no longer emitted** on this corpus.

The last remaining warning (`analysis_evaluation_unresolved` on `SafetyReactionAnalysis`) was cleared by correcting the analysis return expression in [`AnalysisCases.sysml`](../model/AnalysisCases.sysml) to use `measuredReactionTime` and `reactionTimeLimit` (not `…Ms` suffixes).

## Related corpora (same Spec42 build)

| Corpus | Errors | Warnings | Info |
| --- | ---: | ---: | ---: |
| `sysml-domain-libraries` (61 docs, local `--library-path`) | 0 | 0 | 1 |
| OMG `14c-Language Extensions` (stdlib stress test) | 0 | 26 | 2 |

See [`SPEC42_FIXES_NEEDED.md`](SPEC42_FIXES_NEEDED.md) for stdlib / metadata follow-up on the OMG validation file.

## Spec42 0.30 — resolved showcase limitations

The following items from the earlier validation cycle are fixed in Spec42 0.30 (see `C:\Git\spec42\docs\engineering\DIAGNOSTIC-CHECKS-ROADMAP.md`, section *Robot vacuum showcase regressions*):

| ID | Topic | Status in 0.30 |
| --- | --- | --- |
| `S42-LIM-001` | Cross-package `verify requirement` via import | Resolved — unqualified names work with `private import SystemRequirements::*` |
| `S42-LIM-002` | `then done` in verification cases | Resolved |
| `S42-LIM-003` | Verification case shape without explicit verdict | Resolved |
| `S42-LIM-004` | `VerdictKind::pass` / analysis evaluation on verification cases | Resolved |
| `S42-LIM-005` | `flow` in part-definition bodies | Resolved (parser + semantic graph) |
| `S42-LIM-006` | Item-level `connect` fallback | Resolved (superseded by flow support) |
| `S42-LIM-007` | Named transitions misclassified as initial | Resolved |
| `S42-LIM-008` | `missing_final_state` on cyclic state machines | Resolved (suppressed for cyclic lifecycles) |
| `S42-LIM-009` | `[EUR]` unit catalog | Resolved |
| `S42-LIM-010` | False-positive redefinition diagnostics | Resolved |

## Architecture layout

The model uses a functional / physical split (June 2026):

| File | Role |
| --- | --- |
| [`ArchitectureCommon.sysml`](../model/ArchitectureCommon.sysml) | Mission/application items and CPS ports |
| [`PhysicalProtocols.sysml`](../model/PhysicalProtocols.sysml) | Product bus aliases; `public import` of domain electronics libraries |
| [`FunctionalArchitecture.sysml`](../model/FunctionalArchitecture.sysml) | Capability `action def`s, `OperateCleaningRobot` bindings, requirement `satisfy` |
| [`PhysicalArchitecture.sysml`](../model/PhysicalArchitecture.sysml) | Product assemblies, typed physical harness, mass/BOM/power |
| [`ArchitectureAllocations.sysml`](../model/ArchitectureAllocations.sysml) | `allocate` from functions and scenario actions to physical parts |
| [`Architecture.sysml`](../model/Architecture.sysml) | Public import hub, `part robot`, system-level `satisfy` |

### Physical protocol topology (June 2026)

| Harness | Domain types | Product usage |
| --- | --- | --- |
| Sensor I2C | `I2cPort`, `I2cBusHub`, `I2cBusSlaveNode`, `I2cBusMasterNode` | ToF ×3 + IMU on `SensorI2cBus`; MCU master on main electronics |
| BMS SMBus | `I2cPort`, `BmsSmbusHub` | `PowerModule` → `MainElectronicsAssembly` |
| SPI flash | `SpiBusHub`, `SpiBusSlaveNode` | On `MainControlPcb` |
| UART / wireless | `UartPort`, `WirelessUartHub`, `RobotWirelessModule` | MCU ↔ Wi‑Fi/BLE module |
| Actuation | `PwmPort` | Wheel/br/vacuum motor drivers |
| Safety / HMI | `GpioPort`, `QuadratureEncoderPort` | Bumpers, cliffs, encoders, buttons, dock beacon |
| Power | `PowerRailPort` | 14.4 V distribution from `PowerModule` |

The hub uses **public** imports so downstream packages resolve `AutonomousFloorCleaningRobot` and related types via `import Architecture::*`.

## Model conventions (retained)

These choices remain valid MBSE modeling; they are no longer Spec42 workarounds:

- **Typed ports and `connect`** for CPS data exchange in [`PhysicalArchitecture.sysml`](../model/PhysicalArchitecture.sysml) — clear interface boundaries; `flow` syntax is now also supported by Spec42 if the model is migrated later.
- **Public hub imports** in [`Architecture.sysml`](../model/Architecture.sysml) — required for cross-file type visibility in SysML v2 package imports, not a parser bug workaround.

## Workarounds removed (June 2026)

After the Spec42 0.30 upgrade, the following model accommodations were dropped:

- Fully qualified verification objectives (`SystemRequirements::…`) — replaced by unqualified `verify requirement …;`
- Explicit `return ref verdictResult { return VerdictKind::pass; }` on every verification case — no longer required for a clean check

## Optional follow-up

- Add an explicit initial transition to `RobotOperatingBehavior` if `missing_initial_state` should be silenced.
- Revisit **`flow`** instead of port-only `connect` in the physical architecture now that `S42-LIM-005` is resolved (cosmetic / notation preference only).
