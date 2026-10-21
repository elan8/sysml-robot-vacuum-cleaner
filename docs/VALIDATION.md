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
document metadata from `Elan8::Documents` in the domain library, and then runs static model guards.

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
the editor. Open this repository as the workspace root; the `sysml-domain-libraries`
checkout is expected beside it. Document metadata is provided by
`Elan8::Documents` in `sysml-domain-libraries/model`; no Doc42 snapshot is vendored.

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
python scripts/generate-document-data.py
```

The script exports the model with Spec42 and generates the bill of materials and
mass budget in `documents/generated/`. It fails on a model gap: a physical part
without a bill-of-materials classification or mass, a missing derivation,
satisfaction claim, verification case or customer validation case.

The directory is ignored and absent from a clean checkout. The retained design document sources refer to these Markdown tables. PDF
generation and Doc42 document checks are disabled. An optional
`--check` run compares existing local files against freshly computed content;
CI generates the files instead of comparing them with committed snapshots.
It finds Spec42 on `PATH` or in `SPEC42_EXE`, and the
domain libraries next to the repository or through `SYSML_DOMAIN_LIBRARIES_ROOT`.

## Diagram smoke check

```powershell
./scripts/render-views.ps1 -Spec42Exe <path-to-spec42> -ResvgExe <path-to-resvg>
```

`-ResvgExe` is optional. The script exports all nine `ModelViews` diagrams as SVG
and complete diagram products, plus PNG when requested, and creates
`target/model-views/index.html`. It fails on an export error or an incomplete
projection. See [VIEWS.md](VIEWS.md) for each diagram's engineering question,
selection and presentation depth. Inspect the gallery for readable labels,
module boundaries and relationships after validation succeeds.

## CI

`.github/workflows/validate.yml` runs on pushes and pull requests:

- **Spec42** checks out `sysml-domain-libraries` at a pinned
  commit, runs the model guards, and validates `model/` with Spec42 **0.54.1**.
  The libraries bundled with Spec42 are disabled so only the pinned sources are
  used, including `Elan8::Documents`. Errors and warnings fail the job;
  only `view_expose_empty` information in `Documents.sysml` is allowed. It then generates
  the document data, checks the model for gaps and checks the generated mass budget locally.
There is no Doc42 job, PDF build, license-dependent step or document artifact
upload. The document sources remain in the repository for future use.

To move to newer libraries or Doc42, update the pinned domain commit and
re-run validation locally first.

If Spec42 rejects or misprojects an independently confirmed SysML v2-conforming
construct, add a minimal Spec42 regression test and repair the tool. Do not
encode tool workarounds into the model.

## Document generation status

PDF generation is deferred until a suitable Doc42 release and working license
are available. No Doc42 binary version is pinned or installed in this repository.
The generic document definitions use `Elan8::Documents` from domain-library
commit `24f13ae144a0400609d33ec93b1e476269235c97`; no metadata copy is vendored.
Ordinary model validation checks the SysML sources, not their rendering.

The model uses the current domain vocabulary: product-specific bumper,
wheel-drop and homing-beacon roles specialize generic switches and infrared
components, and firmware tasks are allocated through a scheduler execution
platform to the processor. The old method library is no longer needed.
