#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT
"""Validate language diagnostics and the pinned methodology's semantic rules."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent


def run_json(command):
    result = subprocess.run([str(x) for x in command], capture_output=True,
                            text=True, encoding="utf-8")
    if result.returncode:
        raise SystemExit(result.stderr or result.stdout)
    return json.loads(result.stdout)


def check_language(executable, libraries, model):
    report = run_json([executable, *libraries, "check", model, "--format", "json"])
    allowed = {
        ("00_context/Context.sysml", "ContextView"),
        ("60_systems/00_VacuumCleanerSystem/system.sysml", "SpecificationView"),
        ("60_systems/00_VacuumCleanerSystem/system.sysml", "ArchitectureView"),
        ("60_systems/00_VacuumCleanerSystem/system.sysml", "IntegrationView"),
    }
    seen = set()
    failures = []
    for document in report["documents"]:
        for diagnostic in document["diagnostics"]:
            severity = diagnostic["severity"]
            if severity not in (1, 2):
                continue
            match = next((key for key in allowed if document["uri"].endswith(key[0])
                          and diagnostic["message"].startswith(f"View type '{key[1]}' ")), None)
            if (severity == 2 and diagnostic["code"] == "view_type_non_standard"
                    and match and match not in seen):
                seen.add(match)
            else:
                failures.append(f"{document['uri']}: {diagnostic['message']}")
    if failures:
        raise SystemExit("\n".join(failures))
    return report, len(seen)


def dependency(name, environment):
    override = os.environ.get(environment)
    candidates = [Path(override)] if override else [ROOT / ".libraries" / name, ROOT.parent / name]
    for candidate in candidates:
        if candidate.is_dir():
            return candidate.resolve()
    raise SystemExit(f"Check out {name} in .libraries/ or beside this repository; or set {environment}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", default="model")
    parser.add_argument("--format", choices=["text", "json"], default="text")
    args = parser.parse_args()
    executable = os.environ.get("SPEC42_EXE") or shutil.which("spec42")
    if not executable:
        raise SystemExit("Set SPEC42_EXE or put Spec42 on PATH")
    lock = json.loads((ROOT / "dependencies.lock.json").read_text())
    version = subprocess.check_output([executable, "--version"], text=True).strip()
    if version.split()[-1] != lock["spec42"]:
        raise SystemExit(f"Expected Spec42 {lock['spec42']}, got {version}")
    domain = dependency("sysml-domain-libraries", "SYSML_DOMAIN_LIBRARIES_ROOT")
    methodology = dependency("mbse-methodology", "MBSE_METHODOLOGY_ROOT")
    for path, key in [(domain, "domain"), (methodology, "methodology")]:
        revision = subprocess.check_output(["git", "-C", str(path), "rev-parse", "HEAD"], text=True).strip()
        if revision != lock[key]["commit"]:
            raise SystemExit(f"{path} must be at {lock[key]['commit']}; found {revision}")
    libraries = ["--disable-kpar-library", "domain", "--disable-kpar-library", "method",
                 "--library-path", str(domain / "model")]
    model = ROOT / args.model
    report, known_warnings = check_language(executable, libraries, model)
    output = ROOT / "generated" / "validation"
    output.mkdir(parents=True, exist_ok=True)
    (output / "language.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    for path, filename, library_args in [(model, "model.json", libraries),
                                        (domain / "model", "domain.json", libraries[:4])]:
        exported = run_json([executable, *library_args, "model-export", path, "--format", "json"])
        (output / filename).write_text(json.dumps(exported), encoding="utf-8")
    structure = run_json([sys.executable, methodology / "scripts" / "check_structure.py",
                          output / "model.json", "--dependency-export", output / "domain.json",
                          "--complete-selection", "--format", "json"])
    (output / "structure.json").write_text(json.dumps(structure, indent=2), encoding="utf-8")
    if args.format == "json":
        print(json.dumps({"language": report, "structure": structure}))
    else:
        print(f"Language: 0 errors; {known_warnings} documented Spec42 custom-view warnings.")
        print("Methodology definition structure and complete child selection passed.")
        print("Coverage limits and full diagnostics: generated/validation/")


if __name__ == "__main__":
    main()
