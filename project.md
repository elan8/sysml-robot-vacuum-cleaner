# Robot vacuum model baseline

This project follows MBSE methodology 0.5.0 at commit
`0cb3ee0e7b5e64cf4f850a46da5f26acb280a4c2`. Exact dependencies are in
`dependencies.lock.json`; validation verifies both dependency checkout revisions.
Use Spec42 0.57.0 with its 2026-04 standard libraries. The domain source pin is the
domain libraries v0.5.0 release, which includes `Elan8::Documents`; it is intentionally
newer than the methodology's frozen candidate archive. Disable managed `domain` and `method` archives when
using these sources. No Doc42 dependency or PDF generation is enabled.

Diagram rendering has a separate Spec42 source revision in the lock file because
inherited view discovery and Boolean metaclass filters need post-release fixes.
See `docs/VALIDATION.md` for build and export commands. CI validates the model
with the released binary and does not render diagrams.

Load the complete `model/` tree. `Root.sysml` provides navigation. Systems are
flat under `60_systems`, with the root in `00_VacuumCleanerSystem`; part usages define their recursive composition. `Root.sysml` aliases the selected `VacuumCleanerSystem::robotSystem` occurrence as `systemOfInterest`.
Each developed system directly owns its specification, architecture and integration
definitions. Role subpackages are optional organizational choices in the methodology;
this example omits them. Requirements, limits and budgets remain in useful named
system-owned packages, and specifications assert their applicable requirements.
Analyses, verification cases and views stay with their assessed system.
`20_requirements` owns stakeholder needs. `50_library` contains shared interfaces,
shared firmware types and purchased parts. Ordinary leaf components use domain
types directly; product-specific leaf definitions live with their owning systems. `80_documents` owns
publication sources. All disposable outputs belong in ignored `generated/`.

The single selected product usage is
`VacuumCleanerSystem::robotSystem`. Its physical baseline is
`robotSystem.physical`. The residential context has a separate boundary role;
it is an environment model, not a second selected product assembly.

`50_library/Navigation.sysml` preserves prior access paths through native aliases
and public imports. It owns no duplicate engineering definitions. See
`docs/METHODOLOGY_MIGRATION.md` for canonical owners and preserved engineering IDs.
