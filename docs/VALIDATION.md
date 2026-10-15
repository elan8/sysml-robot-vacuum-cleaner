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

The script runs Spec42 over all model files, including
`model/95_documents/Documents.sysml`, supplies local Elan8 libraries and the
pinned Doc42 metadata library, and then runs static model guards.

Expected result:

```text
Checked 21 document(s): 0 error(s), 0 warning(s), 16 info(s)
Model guards passed: physical paths, purchased parts, runtime queues, and traceability are clean.
```

Spec42 0.55.0 reports `view_expose_empty` information for the document and
section container views: these organize nested sections or prose rather than
exposing model elements directly. They are intentional. Errors and warnings
fail validation.

The repository's `.vscode/settings.json` loads the same source libraries for
the editor. Open this repository as the workspace root; the two Elan8 library
checkouts are expected beside it. `libraries/doc42-v0.4.0` is the metadata
snapshot matching the Doc42 release used in CI.

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

## Generated document data

```sh
python scripts/generate-document-data.py --check
```

The script exports the model with Spec42 and compares the bill of materials and
the mass budget it derives with the committed files in `documents/generated/`. It fails when they differ and when
the model has a gap: a physical part without a bill-of-materials classification or
a mass, a customer requirement without a derivation, a system or module
requirement that no derivation names, or a requirement without a satisfaction
claim or a verification case, or a customer requirement without a validation case.
Run it without `--check` to regenerate the files
after a model change. It finds Spec42 on `PATH` or in `SPEC42_EXE`, and the
libraries next to the repository or through `ELAN8_METHOD_LIBRARY_ROOT` and
`SYSML_DOMAIN_LIBRARIES_ROOT`.

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
  used, together with `libraries/doc42-v0.4.0`. Errors and warnings fail the job;
  only `view_expose_empty` information in `Documents.sysml` is allowed. It then checks
  that the generated document data is up to date and that the model has no gap.
- **Doc42 documents** checks `model/` with the repository as `--workspace-root`
  and builds the four
  PDFs with [Doc42](https://github.com/elan8/doc42-action), uploading them as the
  `engineering-documents` artifact. It needs the `ELAN8_LICENSE` repository
  secret and is skipped for pull requests from forks.

To move to newer libraries, update the two pinned commits in the workflow and
re-run validation locally first.

If Spec42 rejects or misprojects an independently confirmed SysML v2-conforming
construct, add a minimal Spec42 regression test and repair the tool. Do not
encode tool workarounds into the model.
