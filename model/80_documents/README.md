# Engineering document sources

`Documents.sysml` selects authoritative model content using the shared
`Elan8::Documents` vocabulary. `prose/`, `figures/` and `template/` contain
authored publication inputs. Paths in document metadata are relative to this
directory. The four documents are CRS, SRS, SDS, and the verification and
validation plan.

Doc42 renders the documents as PDF with the house template in `template/`. CI
checks them on every run and builds them, except for pull requests from forks,
which cannot read the license secret; the PDFs are the `documents` artifact of
the run. To build one locally, with an Elan8 license in `ELAN8_LICENSE`:

```sh
doc42 build model --workspace-root . --library-path ../sysml-domain-libraries/model \
  --doc RobotDocuments::sds --out generated/documents
```

The independent `python scripts/generate-document-data.py` command, run from the
repository root, writes BOM and mass-budget tables to ignored `generated/`.
Document selections refer to those tables through `../../generated/`.
Rendered PDFs go to `generated/documents/`; never commit them.
