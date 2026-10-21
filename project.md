# Robot vacuum model baseline

This project follows MBSE methodology 0.3.0 at commit
`3837d43ac9d16f25b6d99e52e1e8e545bf16bc6b`. Exact dependencies are in
`dependencies.lock.json`; validation verifies both dependency checkout revisions.
Use Spec42 0.56.0 with its 2026-04 standard libraries. The domain source pin also
includes `Elan8::Documents`; it is intentionally newer than the methodology's
frozen candidate archive. Disable managed `domain` and `method` archives when
using these sources. No Doc42 dependency or PDF generation is enabled.

Diagram rendering has a separate Spec42 source revision in the lock file because
inherited view discovery and Boolean metaclass filters need post-release fixes.
See `docs/VALIDATION.md` for build and export commands. CI validates the model
with the released binary and does not render diagrams.

Load the complete `model/` tree. `Root.sysml` provides navigation. Systems are
flat under `60_systems`; part usages define their recursive composition.
Each developed system owns its Specification, Architecture and Integration.
System requirements belong to its Specification, allocations and budgets to
Architecture, and analyses/verification/views to their assessed system.
`20_requirements` owns stakeholder needs. `50_library` contains shared interfaces,
component contract/design profiles and purchased parts. `80_documents` owns
publication sources. All disposable outputs belong in ignored `generated/`.

The single selected product usage is
`VacuumCleanerSystem::Integration::robotSystem`. Its physical baseline is
`robotSystem.physical`. The residential context has a separate boundary role;
it is an environment model, not a second selected product assembly.

`50_library/Navigation.sysml` preserves prior access paths through native aliases
and public imports. It owns no duplicate engineering definitions. See
`docs/METHODOLOGY_MIGRATION.md` for canonical owners and preserved engineering IDs.
