# Engineering document sources

`Documents.sysml` selects authoritative model content using the shared
`Elan8::Documents` vocabulary. `prose/`, `figures/` and `template/` contain
authored publication inputs. Paths in document metadata are relative to this
directory. The four documents are CRS, SRS, SDS, and the verification and
validation plan.

PDF generation is disabled until a suitable Doc42 release and working license
are available. There is no renderer dependency, generation command, CI job or
PDF artifact upload. The retained template is an inactive publication source.
SysML validation checks model semantics, not rendered documents or template compatibility.

The independent `python scripts/generate-document-data.py` command, run from the
repository root, writes BOM and mass-budget tables to ignored `generated/`.
Document selections refer to those tables through `../../generated/`.
Future rendered PDFs should also go under root `generated/`; never commit them.
