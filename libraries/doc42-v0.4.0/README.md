# Doc42 metadata library

`Doc42.sysml` is the unmodified metadata library from `elan8/doc42`, tag
`v0.4.0`, path `crates/doc42-library/library/Doc42.sysml`. It matches the
Doc42 version pinned in CI and makes the document definitions resolvable by
Spec42 and the editor without a Doc42 installation.

When upgrading Doc42, replace this snapshot with the matching release's
`doc42 library export` output and update the validation and editor paths.
Doc42 supplies its own embedded library when building documents, so build
`model/` with the repository as `--workspace-root` rather than scanning this
library as another authored model.
