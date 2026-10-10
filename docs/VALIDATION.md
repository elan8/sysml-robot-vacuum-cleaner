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

The script runs Spec42 over all fourteen model files, supplies local Elan8
domain-library paths when available, and then runs static model guards.

Expected result:

```text
Checked 14 document(s): 0 error(s), 0 warning(s), 0 info(s)
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
  "baseDecomposition",
  "topDecomposition",
  "mainPcbDecomposition",
  "powerDecomposition",
  "interconnections",
  "firmwareDeployment",
  "systemRequirements",
  "cliffSafeStopScenario"
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

`.github/workflows/validate.yml` runs on pushes and pull requests:

- **Spec42** checks out `mbse-methodology` and `sysml-domain-libraries` at pinned
  commits, runs the model guards, and validates `model/` with Spec42 **0.54.1**.
  The libraries bundled with Spec42 are disabled so only the pinned sources are
  used. Any error, warning or information diagnostic fails the job.
- **Doc42 documents** checks `documents/` against the model and builds the three
  PDFs with [Doc42](https://github.com/elan8/doc42-action), uploading them as the
  `engineering-documents` artifact. It needs the `ELAN8_LICENSE` repository
  secret and is skipped for pull requests from forks.

To move to newer libraries, update the two pinned commits in the workflow and
re-run validation locally first.

If Spec42 rejects or misprojects an independently confirmed SysML v2-conforming
construct, add a minimal Spec42 regression test and repair the tool. Do not
encode tool workarounds into the model.
