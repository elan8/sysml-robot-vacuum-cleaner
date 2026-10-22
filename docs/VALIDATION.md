# Validation

Use Spec42 **0.56.0**, its **2026-04** standard libraries and Python 3.9+.
Exact domain and methodology source revisions are in `../dependencies.lock.json`.
Check out both repositories beside this repository or under `.libraries/`.
The validator verifies their HEAD revisions; it does not fetch or update them.
Set `SYSML_DOMAIN_LIBRARIES_ROOT` and `MBSE_METHODOLOGY_ROOT` for other locations.
The editor's sibling library settings remain suitable for local browsing.

```powershell
./scripts/validate.ps1 -Spec42Exe <path-to-spec42>
python scripts/generate-document-data.py
./scripts/render-views.ps1 -Spec42Exe <path-to-rendering-build>
```

For a shell without PowerShell, set `SPEC42_EXE` (or put Spec42 on PATH) and run
`python scripts/validate_model.py`. The PowerShell wrapper additionally runs
`check-model-guards.ps1`; CI runs the same guards as a separate step.
Managed `domain` and `method` archives are disabled; pinned source libraries are used.

## Language diagnostics

The migrated baseline has 27 SysML source files, zero errors, four warnings and
16 informational diagnostics. The information concerns document/section views
which compose content and intentionally have no direct exposes.

Spec42 0.56.0 incorrectly reports `view_type_non_standard` for custom view
definitions that specialize `GeneralView`. The methodology documents the same
defect for its starter and elevator example. The model retains the valid shared
definitions. The validator accepts only one occurrence of each named view type:

| Source | Type |
| --- | --- |
| `model/00_context/Context.sysml` | `ContextView` |
| `model/60_systems/VacuumCleanerSystem/system.sysml` | `SpecificationView` |
| Same system | `ArchitectureView` |
| Same system | `IntegrationView` |

Every error and every other warning fails. The full native diagnostic report is
saved in `generated/validation/language.json`; warnings are not suppressed.
Review this exception when updating Spec42; remove it when the defect is fixed.

Integrations use explicit named redefinitions (`part drive : SelectedDrive :>> drive`).
This is equivalent to the valid `part redefines drive : SelectedDrive` shorthand,
and makes selected role names visible in source and semantic exports. Spec42
0.56.0's diagram projector reports an incomplete connector end for this model
with the anonymous shorthand; named declarations retain complete projections.
The selection and engineering identity are unchanged. BOM traversal supports
both forms by following semantic redefinition relationships.

## Structural checks and limits

The validator exports the complete model and the domain dependency, then invokes
the pinned methodology's `scripts/check_structure.py --complete-selection`.
It checks independent role ancestry, boundary-only specifications, architecture
developed children typed by project specifications and ordinary typed leaf parts, integration redefinition and compatible
complete child design selection. The current baseline has no structural diagnostics.
Dependency export is essential for inherited harness, controller and PCBA parts.

Reports and semantic exports go to `generated/validation/`. The checker explicitly
does not assess usage-local root overrides, contextual constraints or verification
correctness. Passing it is not proof of complete methodology or product conformance.
The product usage currently adds no local root overrides.

Role definitions are directly system-owned. The checker recognizes semantic
inheritance and child selections independently of namespace layout; the methodology
tests cover both direct ownership and optional grouping packages. The flattening
retained all 62 engineering IDs/names and 10,096 selected relationship edges after
mapping retired role-package prefixes. The subsequent removal of component adapters
changes the artificial type chains deliberately, while retaining IDs, actual
engineering data, behavior and byte-identical BOM/mass-budget outputs.

Model guards separately check required physical connections, catalog dependencies,
metadata, seven task profiles, five runtime queue flows and satisfaction/verification
paths. The independent BOM script checks classification, mass, requirement
derivation, satisfaction, verification and validation coverage. It traverses
effective inherited/redefined parts and counts subset collections only once.
The preserved baseline is 49 items, 3.694 kg and EUR 121.10.

## Views and generated outputs

The rendering script exports nine focused views, checks each diagram product is
complete, and writes an SVG/JSON gallery under `generated/views/`. Optional
`-ResvgExe` adds PNGs. See [VIEWS.md](VIEWS.md).

Diagram export uses the separate source revision pinned as `diagramRenderer`
in the lock file: `dc2bc2790fda6114d61b5860e4632cf96379774e`. Check out that
revision of Spec42 and build its CLI (`cargo build -p server --bin spec42`), then pass the
resulting executable to `render-views.ps1`. It identifies itself as 0.56.0 but
contains post-release fixes, so the version string alone is insufficient.

Released Spec42 0.56.0 cannot prepare Boolean metaclass filters and does not
discover derived GeneralView types. Composition views deliberately exclude
connection/allocation usages, which also conform to PartUsage. Removing those
filters would add allocation boxes to diagrams intended to show constituents.
The model keeps the correct filters. `-IncludeMethodologyViews` exports the four
additional role views with the same rendering build, for thirteen in total.
This rendering baseline is separate from the released binary used for
pinned language/structural CI; CI does not build Spec42 or render diagrams.
Inspect relationship content and readability after a model change.

`generate-document-data.py --check` checks local table freshness. CI regenerates
tables from the model. All `generated/` contents are ignored and absent from
a clean checkout. No generated files are required as tracked inputs.

## CI and publication

The workflow pins Spec42, domain sources and the methodology checker to the same
baseline as local validation. It checks guards, language diagnostics, semantic
structure, complete child selection, traceability and mass. There is no Doc42
installation, license step, document rendering, PDF build or artifact upload.
Retained `Elan8::Documents` sources are ordinary model inputs only.
