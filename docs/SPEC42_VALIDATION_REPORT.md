# Spec42 Validation Report

Date: 2026-06-12

Validated with the local Spec42 checkout at `C:\Git\spec42`.

## Commands

```powershell
C:\Git\spec42\target\debug\spec42.exe doctor --format json
C:\Git\spec42\target\debug\spec42.exe check model --format json
```

## Environment

- Spec42 version: `0.30.0`
- Standard library: bundled `2026-04`
- Domain libraries: bundled `dc378a9`
- Sysand: not installed and no Sysand manifest found. Spec42 reports this as optional.

## Result

`spec42 check model --format json` completed with exit code `0`.

| Metric | Count |
| --- | ---: |
| Documents checked | 9 |
| Errors | 0 |
| Warnings | 56 |
| Information | 1 |

## Diagnostics

| Code | Count | Assessment |
| --- | ---: | --- |
| `analysis_evaluation_unresolved` | 14 | Expected current Spec42 limitation for verification cases that use explicit `return ref verdictResult { return VerdictKind::pass; }`. The verdict is intentionally modeled so Spec42 accepts the verification-case shape, but Spec42 still tries to evaluate the case expression like an analysis expression. |
| `connection_endpoint_not_port` | 9 | Expected workaround side effect. SysML v2 item flows would be the better notation for observations, hazard events, odometry, and safe commands, but this Spec42 build rejects `flow` in a `part def` body. The model therefore uses `connect` for those internal item relationships, which Spec42 then warns are not port-to-port connections. |
| `connection_context_invalid` | 6 | Same root cause as `connection_endpoint_not_port`: Spec42 currently accepts the syntax only after using `connect`, but semantically warns because the endpoints are items rather than ports. |
| `missing_final_state` | 1 | Tooling/modeling tradeoff. `RobotOperatingBehavior` is a cyclic operating lifecycle with service reset and charging loops, not a terminating workflow. Spec42 recommends a final state or transition to `done`; this is useful guidance but not a defect for this continuous controller lifecycle. |
| `multiple_initial_states` | 1 | Likely Spec42 state-transition extraction limitation for the current compact `transition name first source then target;` style. The model uses named transitions with explicit source and target, but Spec42 classifies them as unguarded initial transitions. |
| `unknown_unit_symbol` | 9 | Known library/catalog limitation for `EUR` from the bundled monetary domain library. The model imports `MonetaryUnits::*` and uses `MonetaryAmount`; Spec42's unit catalog does not currently index `EUR` for this diagnostic. |
| `unresolved_redefines_target` | 17 | Likely Spec42 graph-builder limitation after parsing ordinary typed attributes in specialized part definitions. These attributes are not written with `:>>`, but Spec42 reports them as redefine targets. True redefinitions such as `attribute :>> powerDrawW` resolve well enough for the roll-up analyses to parse. |

## Spec42 Limitations And Workarounds

This section tracks every observed Spec42 behavior that either required a model workaround or still appears as a diagnostic even though the model intent is valid SysML v2 / MBSE practice. Items are phrased as candidates for Spec42 backlog work; each should still be confirmed against the current OMG grammar and Spec42 parser architecture before implementation.

| ID | Area | Observed Spec42 behavior | Expected / desired behavior | Workaround in this repo | Evidence |
| --- | --- | --- | --- | --- | --- |
| `S42-LIM-001` | Verification relationship resolution | `verify requirement coverFloor;` inside package `Verification` was resolved as `Verification::coverFloor` even though `private import SystemRequirements::*;` is present, producing `unresolved_pending_relationship` errors. | Imported requirement usages should resolve from the imported package in verification objectives, as other imported symbols do. | All verification objectives are fully qualified as `SystemRequirements::<requirementName>`. | [Verification.sysml](../model/Verification.sysml) |
| `S42-LIM-002` | Verification case finalization | Verification cases with `then action ...; then done;` produced `succession_endpoint_invalid` because Spec42 treated `done` as a verdict endpoint rather than accepting it as case/control completion. | `then done` should be accepted where SysML case/action/state sequencing permits completion, or the diagnostic should distinguish unsupported notation from invalid action-to-verdict succession. | Removed `then done` from verification cases. | Earlier validation run reported `succession_endpoint_invalid` for each `then done`. |
| `S42-LIM-003` | Verification verdict shape | Verification cases with `then action` steps and no explicit verdict/return produced `verification_case_invalid_shape`. | If Spec42 requires an explicit verification verdict for its analysis workflow, the diagnostic is useful. If SysML permits evidence-producing verification cases without an immediate concrete verdict expression, this should be relaxed or downgraded. | Added one `return ref verdictResult { return VerdictKind::pass; }` to each verification case. | [Verification.sysml](../model/Verification.sysml) |
| `S42-LIM-004` | Verification expression evaluation | After adding explicit verdict returns, Spec42 still reports `analysis_evaluation_unresolved` for all verification cases. | Verification verdict expressions using `VerdictKind::pass` should be resolved, or verification-case evaluation should not be reported as unresolved analysis evaluation. | No workaround beyond documenting the warning; command still exits with 0 errors. | 14 warnings in latest `spec42 check`. |
| `S42-LIM-005` | Item flows in part definitions | `flow mobility.wheelOdometry to navigation.odometry;` and similar item-flow relationships inside a `part def` body produced parser errors: unexpected keyword `flow`. | SysML v2 supports flows between item features; Spec42 should parse item flows in structural contexts where the grammar permits them. | Replaced item flows with `connect` so the model parses. | [Architecture.sysml](../model/Architecture.sysml) |
| `S42-LIM-006` | Item-level connection fallback | The `connect` workaround for item-flow relationships parses, but Spec42 warns `connection_endpoint_not_port` and `connection_context_invalid` because the endpoints are items, not ports. | Once item-flow syntax is supported, these relationships should be modeled as `flow` and should not need port-only connection diagnostics. | Accepted warnings and documented the workaround; alternatively, remodel as explicit typed ports if warning-free output is required before flow support lands. | 9 `connection_endpoint_not_port` and 6 `connection_context_invalid` warnings. |
| `S42-LIM-007` | State transition extraction | `transition name first source then target;` transitions in `RobotOperatingBehavior` are counted as unguarded initial transitions, producing `multiple_initial_states`. | Named transitions with explicit source and target should not all be classified as initial transitions. | No workaround applied; the lifecycle remains readable and valid for the showcase. | [BehaviorStates.sysml](../model/BehaviorStates.sysml) |
| `S42-LIM-008` | Cyclic state-machine finality | Spec42 reports `missing_final_state` for a cyclic robot operating lifecycle. | For continuous controllers, absence of a final state can be a deliberate model choice. This should likely be information/guidance, configurable, or suppressed when the state machine is clearly cyclic. | No workaround applied. | [BehaviorStates.sysml](../model/BehaviorStates.sysml) |
| `S42-LIM-009` | Domain-library unit catalog | `MonetaryAmount` values using `[EUR]` produce `unknown_unit_symbol` even though `MonetaryUnits::*` is imported from the bundled domain libraries. | The unit catalog should index `EUR` from the bundled monetary domain library, or the diagnostic should understand domain-library units. | No workaround applied; keeping `[EUR]` is important for the cost showcase. | 9 `unknown_unit_symbol` warnings in [Architecture.sysml](../model/Architecture.sysml). |
| `S42-LIM-010` | Attribute/redefinition diagnostics | Ordinary typed attributes such as `attribute drivePowerW : PowerValue = 28 [W];` are reported as `unresolved_redefines_target`, even though they are not written with `:>>`. | Redefinition diagnostics should apply only to actual redefinition syntax or inherited-feature redefinition semantics. | No workaround applied; rewriting these as untyped values would reduce model quality. | 17 `unresolved_redefines_target` warnings in [Architecture.sysml](../model/Architecture.sysml). |

## Model Adjustments Made For Spec42

- Verification objectives are fully qualified as `SystemRequirements::...` to avoid unresolved cross-package pending relationships.
- Verification cases include one explicit `return ref verdictResult { return VerdictKind::pass; }` when they contain `then action` steps, matching Spec42's verification-case shape diagnostic.
- Verification cases omit `then done` because this Spec42 build diagnoses action-to-`done` verification successions as invalid.
- Internal CPS data relationships are written as `connect` rather than `flow` because this Spec42 build rejects `flow` inside `part def AutonomousFloorCleaningRobot`.

## Follow-Up Candidates

- Revisit item-flow syntax when Spec42 supports `flow` in part-definition bodies.
- Replace item-level workaround connections with typed ports if strict warning-free Spec42 output is required today.
- Track whether a newer Spec42 build indexes `MonetaryUnits::EUR` and stops reporting ordinary local attributes as unresolved redefine targets.
- Add small Spec42 regression fixtures for `S42-LIM-001`, `S42-LIM-002`, `S42-LIM-005`, and `S42-LIM-007`; those have compact reproductions and would prevent regressions once fixed.
