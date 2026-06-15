# Validation

Use this page for reproducible validation commands.

## Standard Command

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1
```

The script validates `model/` with Spec42 and passes local domain-library roots when they exist.

## Parameters

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1 `
  -Spec42Exe C:\Git\spec42\target\debug\spec42.exe `
  -DomainLibrariesRoot C:\Git\sysml-domain-libraries `
  -Format text
```

| Parameter | Default | Purpose |
| --- | --- | --- |
| `Spec42Exe` | `spec42` on `PATH`, or `C:\Git\spec42\target\debug\spec42.exe` if present | Spec42 executable to run. |
| `DomainLibrariesRoot` | `C:\Git\sysml-domain-libraries` if present | Root containing `domain`, `technical`, and `generic`. |
| `ModelPath` | `model` | Model workspace to validate. |
| `Format` | `text` | Spec42 output format. |

## Diagram Smoke Checks

Run these after changing `ModelViews`, view exposure paths, or file layout:

```powershell
spec42 diagrams export model --selected-view productStructure --format svg --output target/diagrams
spec42 diagrams export model --selected-view operationalContext --format svg --output target/diagrams
spec42 diagrams export model --selected-view physicalInterconnections --format svg --output target/diagrams
spec42 diagrams export model --selected-view firmwareTaskArchitecture --format svg --output target/diagrams
spec42 diagrams export model --selected-view requirementsTraceability --format svg --output target/diagrams
```

## Expected Result

The robot-vacuum corpus should validate with:

- `0 errors`
- `0 warnings`
- `0 information` diagnostics

The latest local run should be recorded in commit notes or CI logs rather than checked into the public model repository.

## Known Notes

- Local domain-library checkouts may contain newer electronics packages than the bundled Spec42 libraries, so use `-DomainLibrariesRoot` during active library development.
- Tool-specific investigation notes should stay outside the public repository, for example under ignored `internal_docs/`.
