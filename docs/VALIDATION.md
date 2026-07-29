<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Validation

## Full model check

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

The script runs Spec42 over all thirteen model documents, supplies local Elan8
domain-library paths when available, and then runs static model guards.

Expected result:

```text
Checked 13 document(s): 0 error(s), 0 warning(s), 0 info(s)
Model guards passed: lean graph, purchased parts, runtime queues, and traceability are clean.
```

Optional parameters:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 `
  -Spec42Exe <path-to-spec42> `
  -DomainLibrariesRoot <path-to-sysml-domain-libraries> `
  -Format text
```

The guards reject removed layers and types, handoff names, internal path-string
identity, missing semantic catalog selection, specialization of catalog parts,
incomplete `BuyPart` metadata,
missing queue flows and requirements without satisfaction or verification.

## Diagram smoke check

```powershell
$views = @(
  "productDecomposition",
  "interconnections",
  "firmwareRuntime",
  "requirementsTraceability",
  "cliffSafeStopScenario",
  "selectedParts"
)
foreach ($view in $views) {
  spec42 diagrams export model `
    --selected-view $view `
    --format svg `
    --output target/lean-diagrams
}
```

Each generated SVG must contain model nodes and no unresolved-reference
fallback labels.

## CI

`.github/workflows/validate.yml` runs Spec42 **v0.47.1** (`elan8/spec42@v0.47.1`) for
pushes and pull requests. Warnings remain visible in SARIF; this showcase treats
any error, warning or information diagnostic as a release blocker.

If Spec42 rejects or misprojects an independently confirmed SysML v2-conforming
construct, add a minimal Spec42 regression test and repair the tool. Do not
encode tool workarounds into the model.
