# Spec42 fixes needed

Date: 2026-06-13 (updated after robot showcase context / safety / trade-study additions)

This document tracks **Spec42 tool gaps and false positives** discovered while extending `sysml-domain-libraries` (electronics interconnection / wireless) and validating the robot-vacuum showcase. It complements [`SPEC42_VALIDATION_REPORT.md`](SPEC42_VALIDATION_REPORT.md), which covers the robot model corpus.

Environment: Spec42 `0.30.0`, bundled standard library **`2026-04`** (installed, canonical — see `spec42 doctor`).

## How to reproduce

```powershell
# Domain libraries (61 documents, local checkout)
C:\Git\spec42\target\debug\spec42.exe `
  --library-path C:\Git\sysml-domain-libraries\domain `
  --library-path C:\Git\sysml-domain-libraries\technical `
  --library-path C:\Git\sysml-domain-libraries\generic `
  check C:\Git\sysml-domain-libraries `
  --workspace-root C:\Git\sysml-domain-libraries `
  --format text

# Robot vacuum (18 documents)
C:\Git\spec42\target\debug\spec42.exe check C:\Git\sysml-robot-vacuum-cleaner\model --format text

# Official OMG validation corpus (reference / stdlib stress test)
C:\Git\spec42\target\debug\spec42.exe check "C:\Git\sysml-v2-release\sysml\src\validation\14-Language Extensions\14c-Language Extensions.sysml" --format text

# Standard library health
C:\Git\spec42\target\debug\spec42.exe doctor --format json
```

Current counts (re-validated 2026-06-13):

| Corpus | Errors | Warnings | Info |
| --- | ---: | ---: | ---: |
| `sysml-domain-libraries` (local) | 0 | **0** | 1 |
| `sysml-robot-vacuum-cleaner/model` | 0 | **0** | 0 |
| OMG `14c-Language Extensions` | 0 | 26 | 2 |

---

See [`SPEC42_STDLIB_RESOLUTION_GUIDE.md`](../../spec42/docs/engineering/STDLIB-RESOLUTION-GUIDE.md) in the Spec42 repo for **how to implement** the remaining standard-library fixes (STD-004 … STD-007).

---

## Standard library status

`spec42 doctor` reports a healthy bundled stdlib:

| Field | Value |
| --- | --- |
| Pinned / installed version | `2026-04` |
| Install path | `%LOCALAPPDATA%\Elan8\spec42\data\standard-library\versions\2026-04\sysml.library` |
| Source | bundled (embedded in Spec42 binary, materialized on first use) |
| Status | `is_installed: true`, `version_matches: true`, `path_matches: true` |

**What works now**

- `SysML::RequirementUsage` and related **`SysML::…` namespace segments resolve** — the former `invalid_qualified_name_segment` warnings are gone on domain-library `RequirementMetadata.sysml` and on OMG `14c`.
- ISQ / SI quantity types (`ISQ`, `SI`, `[EUR]`, `[mAh]`, …) used by the robot showcase resolve via the bundled library.
- Requirement derivation (`#derivation connection`) and design satisfaction (`satisfy … by part`) no longer produce false positives on our corpora.

**Remaining stdlib-adjacent gap (OMG `14c` only)**

Metadata restriction typing still warns with `incompatible_type_kind` when `:> annotatedElement : SysML::RequirementUsage` (and similar) appears on user metadata defs — Spec42 resolves the name but does not yet accept the reflective stdlib type as a compatible attribute definition target. This does **not** affect the robot vacuum or domain-library validation corpora (0 warnings there).

---

## Tracking

| ID | Summary | Status |
| --- | --- | --- |
| S42-FIX-001 | Resolve `SysML::` qualified-name segments against bundled stdlib | **Fixed** — no `invalid_qualified_name_segment` on domain libs or `14c` |
| S42-FIX-002 | Type imported `SemanticMetadata` / metadata restrictions | **Fixed** for `RequirementMetadata.sysml` (0 warnings). Partial on OMG `14c` → see S42-FIX-006 |
| S42-FIX-003 | Suppress `connection_context_invalid` for `#derivation connection` | **Fixed** |
| S42-FIX-004 | Allow `satisfy requirement by part/action` (design satisfaction) | **Fixed** |
| S42-FIX-005 | Review cyclic behavior final-state policy (`missing_final_state`) | **Open** (info on webshop example only) |
| S42-FIX-006 | Accept `SysML::RequirementUsage` etc. as valid restriction types on metadata `annotatedElement` | **Open** — `incompatible_type_kind` on OMG `14c` (26 warnings total in that file) |

---

## S42-FIX-006 — Metadata restriction typing (`incompatible_type_kind`)

### Symptom (remaining on OMG `14c`)

```
warning [incompatible_type_kind]
'attribute' cannot type 'annotatedElement' with 'SysML::RequirementUsage';
expected a compatible attribute definition.
```

Same pattern for `SysML::ConnectionUsage`, `SysML::ItemUsage`, etc.

### Expected behavior

Per OMG language-extension examples, metadata defs may restrict `annotatedElement` to reflective SysML usage types from the standard library (`SysML::RequirementUsage`, …).

### Suggested fix

In attribute typing / restriction checks, treat resolved reflective stdlib metadata types (`SysML::…` from `sysml.library/Systems Library/SysML.sysml`) as valid targets for metadata restriction attributes, not only user-defined `attribute def`s.

### Regression test

`spec42 check` on OMG `14c-Language Extensions.sysml` should drop `incompatible_type_kind` warnings for `annotatedElement` restrictions while keeping legitimate kind mismatches elsewhere.

---

## P3 — Residual behavior diagnostic (webshop example)

### Symptom

```
info [missing_final_state] on OrderLifecycleStateMachine (webshop example)
```

One behavior state machine in the domain-library webshop example still reports missing finality. The robot showcase now declares an explicit initial transition and has no behavior diagnostics ([`SPEC42_VALIDATION_REPORT.md`](SPEC42_VALIDATION_REPORT.md)).

### Suggested fix

Review whether cyclic operational lifecycles should suppress `missing_final_state` symmetrically to `missing_initial_state`, or document as intentional for long-running service behaviors.

---

## Model fixes applied (not Spec42)

| File | Issue | Status |
| --- | --- | --- |
| [`WirelessDomain.sysml`](../../sysml-domain-libraries/technical/communication/wireless/WirelessDomain.sysml) | `unresolved_type_reference` for `Name` | **Fixed** — `import SoftwareCore::*;` added |
| [`AnalysisCases.sysml`](../model/AnalysisCases.sysml) | `analysis_evaluation_unresolved` on `SafetyReactionAnalysis` | **Fixed** — return uses `measuredReactionTime <= reactionTimeLimit` |

---

## Resolved issues (archive)

<details>
<summary>P1 — Standard-library qualified names (`SysML::…`) — Fixed</summary>

Former symptom: `invalid_qualified_name_segment` — segment `SysML` does not resolve.

Affected: `RequirementMetadata.sysml`, OMG `14c`. Re-validation: **0 occurrences** on domain libraries; namespace segments now resolve on `14c`.
</details>

<details>
<summary>P2 — Requirement derivation connections — Fixed</summary>

Former symptom: `connection_context_invalid` on `#derivation connection` between requirements.

Affected: `minimal-traceability`, `inspection-rover`, etc. Re-validation: **0 warnings**.
</details>

<details>
<summary>P2 — Satisfy requirement by design element — Fixed</summary>

Former symptom: `satisfy_invalid_endpoint_kind` for `satisfy patrolAisles by rover`.

Re-validation: **0 warnings** on `inspection-rover.sysml`.
</details>

---

## Acceptance criteria

| Corpus | Target | Current |
| --- | --- | --- |
| `sysml-robot-vacuum-cleaner/model` | 0 warnings | **Met** |
| `sysml-domain-libraries` (local paths) | 0 warnings | **Met** |
| OMG `14c-Language Extensions` | 0 warnings | **Not met** (26 — mostly language-extension / annotation syntax; S42-FIX-006 covers metadata typing subset) |

---

## Related Spec42 sources

| Topic | Location |
| --- | --- |
| Diagnostic roadmap | `C:\Git\spec42\docs\engineering\DIAGNOSTIC-CHECKS-ROADMAP.md` |
| Connection checks | `crates/semantic_core/src/semantic/diagnostics/checks/connection_conformance.rs` |
| Satisfy checks | `crates/semantic_core/src/semantic/diagnostics/checks/requirement_case_conformance.rs` |
| Qualified names | `crates/semantic_core/src/semantic/diagnostics/checks/name_resolution.rs` |
| Derivation wiring | `crates/semantic_core/src/semantic/relationships.rs` (`try_wire_derivation_connection`) |
| Metadata tests | `crates/semantic_core/tests/metadata_semantics.rs` |
| Derivation tests | `crates/semantic_core/tests/requirement_derivation_semantics.rs` |
