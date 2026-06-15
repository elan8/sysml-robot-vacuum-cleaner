<!--
SPDX-FileCopyrightText: 2026 Elan8
SPDX-License-Identifier: MIT
-->

# Contributing

Thanks for helping improve this SysML v2 showcase.

## Pull Requests

- Keep model semantics clear and reviewable.
- Run validation before opening a PR:

  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1
  ```

- Keep the flat `model/` layout unless a PR explicitly validates and motivates a folder move.
- Preserve package ownership boundaries from `docs/MODEL_CONVENTIONS.md`.
- Avoid unrelated formatting churn in model files.
- Add or update documentation when changing package ownership, imports, views, validation behavior, or generated assets.

## Model Changes

- Prefer small, focused PRs.
- Keep requirement names stable when possible; many satisfy, verify, analysis, and view relationships depend on them.
- Use `doc /* ... */` for model-level explanations and short comments for local navigation or tool notes.
- Do not add implementation detail to requirements packages or primary engineering facts to view packages.

## Generated Assets

- Store final repository assets under `docs/assets/`.
- Do not leave project-referenced generated files only under local tool output directories.
- Avoid visible third-party brand marks unless the repository has explicit permission to use them.

## Reporting Issues

Useful issues include:

- validation failures
- unclear package boundaries
- broken links or stale documentation
- examples where a view or traceability path is hard to follow
