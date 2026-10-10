#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT
"""Generate the tables the engineering documents include, from the model.

Reads one Spec42 export of `model/` and writes Markdown tables into
`documents/generated/`:

    bom.md                 bill of materials with quantities, sourcing, cost and mass
    bom.csv                the same lines for a spreadsheet or an ERP import
    mass-budget.md         mass per module against the robot mass limit
    traceability.md        customer requirement -> derived system requirements
    verification-matrix.md system requirement -> satisfied by -> verified by
    allocation.md          system requirement -> module requirements and budgets
    module-matrix.md       module requirement -> satisfied by -> verified by

It also checks the model for gaps and fails when it finds one: a physical part
without a bill-of-materials classification, a customer requirement without a
derivation, a system or module requirement that no derivation names, or a
system or module requirement without a satisfaction claim or a verification
case.

    python scripts/generate-document-data.py            regenerate
    python scripts/generate-document-data.py --check    fail if the files are stale

Needs only Python 3.9+ and Spec42 (on PATH, or in SPEC42_EXE).
"""
from __future__ import annotations

import argparse
import csv
import io
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "documents" / "generated"
ROBOT = "PhysicalArchitecture::AutonomousFloorCleaningRobot"
SPECIFICATION = "SystemRequirements::robotSystemSpecification"
CUSTOMER = "StakeholderNeeds"
MODULES = "ModuleRequirements"
# Packages whose part definitions are logical, not purchasable or made items.
LOGICAL_PACKAGES = ("DomainModel::", "FirmwareArchitecture::")


def fail(message: str) -> "NoReturn":
    raise SystemExit("error: " + message)


def library_arguments() -> list[str]:
    """The same library selection as scripts/validate.ps1 and the CI workflow."""
    method = os.environ.get("ELAN8_METHOD_LIBRARY_ROOT")
    domain = os.environ.get("SYSML_DOMAIN_LIBRARIES_ROOT")
    for base in (ROOT / ".libraries", ROOT.parent):
        if not method and (base / "mbse-methodology" / "library").is_dir():
            method = str(base / "mbse-methodology" / "library")
        if not domain and (base / "sysml-domain-libraries" / "model").is_dir():
            domain = str(base / "sysml-domain-libraries")
    if not method or not domain:
        fail("check out mbse-methodology and sysml-domain-libraries next to this repository, "
             "or set ELAN8_METHOD_LIBRARY_ROOT and SYSML_DOMAIN_LIBRARIES_ROOT")
    return ["--disable-kpar-library", "domain", "--disable-kpar-library", "method",
            "--library-path", method, "--library-path", str(Path(domain) / "model")]


def export() -> dict:
    spec42 = os.environ.get("SPEC42_EXE") or shutil.which("spec42")
    if not spec42:
        fail("Spec42 was not found; put it on PATH or set SPEC42_EXE")
    completed = subprocess.run(
        [spec42, *library_arguments(), "model-export", str(ROOT / "model"), "--format", "json"],
        capture_output=True, text=True, encoding="utf-8", check=False)
    if completed.returncode != 0:
        sys.stderr.write(completed.stderr)
        fail("Spec42 could not export the model")
    data = json.loads(completed.stdout)
    summary = data["summary"]
    if summary["error_count"] or summary["warning_count"]:
        fail(f"the model has {summary['error_count']} error(s) and "
             f"{summary['warning_count']} warning(s); run the validation first")
    projection = data["projection"]
    if not projection["envelope"]["complete"] or projection["truncation"]["elements_incomplete"]:
        fail("the Spec42 export is incomplete")
    return projection


class Model:
    def __init__(self, projection: dict):
        self.elements = projection["elements"]
        self.connectors = projection["connectors"]
        self.by_token = {element["token"]: element for element in self.elements}
        self.by_name: dict[str, dict] = {}
        self.children: dict[str, list[dict]] = {}
        for element in self.elements:
            self.by_name.setdefault(element["qualified_name"], element)
            self.children.setdefault(element["owner"], []).append(element)

    def element(self, qualified_name: str) -> dict:
        if qualified_name not in self.by_name:
            fail(f"the model has no element `{qualified_name}`")
        return self.by_name[qualified_name]

    def owned(self, element: dict, kind: str) -> list[dict]:
        return [child for child in self.children.get(element["token"], []) if child["kind"] == kind]

    def definition(self, usage: dict) -> tuple[dict | None, str]:
        """The typing definition of a usage: (workspace element or None, qualified name)."""
        targets = usage["relationships"]["typing"]["targets"]
        if not targets:
            return None, ""
        return self.by_token.get(targets[0]["token"]), targets[0]["qualified_name"]

    def annotation(self, element: dict, definition: str) -> dict | None:
        """The values of the element's annotation of one metadata definition."""
        for annotation in element.get("metadata_annotations", []):
            if annotation["definition"].get("qualified_name") != definition:
                continue
            values = {}
            for entry in annotation["body"]:
                name = entry["redefines"]["qualified_name"].rsplit("::", 1)[-1]
                nodes = entry["value"]["nodes"]
                node = nodes[entry["value"]["root"]] if nodes else {}
                values[name] = node.get("value", node.get("authored"))
            return values
        return None

    def redefined_value(self, element: dict, feature: str):
        """The literal value an owned attribute gives to a redefined feature."""
        for attribute in self.owned(element, "AttributeUsage"):
            redefined = [target["qualified_name"]
                         for target in attribute["relationships"]["redefinition"]["targets"]]
            if not any(name.endswith("::" + feature) for name in redefined):
                continue
            for expression in self.owned(attribute, "Expression"):
                nodes = expression["expression"]["nodes"]
                if len(nodes) == 1 and nodes[0]["kind"] == "literal":
                    return nodes[0]["value"]
        return None

    def selected_part(self, definition: dict) -> dict | None:
        """The catalogue part a definition selects through `selectedImplementation`."""
        for dependency in self.owned(definition, "Dependency"):
            if dependency["name"] != "selectedImplementation":
                continue
            for edge in dependency["relationships"]["outgoing"]:
                if edge["kind"] == "dependencySupplier":
                    return self.by_token.get(edge["peer"]["token"])
        return None

    def documentation(self, element: dict) -> str:
        texts = [entry["text"] for entry in element["documentation"] if entry["form"] == "doc"]
        return " ".join(" ".join(texts).split())


def kilograms(value) -> float | None:
    if not isinstance(value, dict) or "magnitude" not in value:
        return None
    factor = {"kg": 1.0, "g": 0.001}.get(value.get("unit"))
    return None if factor is None else value["magnitude"] * factor


def humanize(name: str) -> str:
    words, word = [], ""
    for character in name:
        if character.isupper() and word and not word[-1].isupper():
            words.append(word)
            word = character
        else:
            word += character
    words.append(word)
    text = " ".join(words)
    text = text[0].upper() + text[1:].lower() if text else text
    return text.replace("pcb", "PCB")


class Bom:
    """Walks the physical part tree of the robot into bill-of-materials lines."""

    def __init__(self, model: Model):
        self.model = model
        self.lines: list[dict] = []
        self.gaps: list[str] = []
        self.modules: dict[str, float] = {}
        self.walk(model.element(ROBOT), [], 1, None)

    def walk(self, definition: dict, path: list[str], level: int, module: str | None) -> bool:
        """Adds the lines below a definition; returns whether any were added."""
        added = False
        for usage in self.model.owned(definition, "PartUsage"):
            if "ref" in usage["modifiers"]:
                continue
            typed, type_name = self.model.definition(usage)
            here = path + [usage["name"]]
            top = module or usage["name"]
            item = self.model.annotation(usage, "Sourcing::BomItem")
            if item is None and typed is not None:
                item = self.model.annotation(typed, "Sourcing::BomItem")
            if item is not None:
                self.add_item(usage, typed, here, level, top, item)
                added = True
                continue
            if type_name.startswith(LOGICAL_PACKAGES):
                continue
            index = len(self.lines)
            self.lines.append({"level": level, "item": humanize(usage["name"]),
                               "path": ".".join(here), "assembly": True, "module": top})
            if typed is not None and self.walk(typed, here, level + 1, top):
                added = True
            else:
                del self.lines[index:]
                self.gaps.append(".".join(here))
        return added

    def add_item(self, usage, typed, path, level, module, item) -> None:
        model = self.model
        mass = kilograms(model.redefined_value(usage, "mass"))
        if mass is None and typed is not None:
            mass = kilograms(model.redefined_value(typed, "mass"))
        manufacturer = part_number = ""
        selected = model.selected_part(typed) if typed is not None else None
        if selected is not None:
            buy = model.annotation(selected, "Procurement::BuyPart") or {}
            manufacturer = buy.get("manufacturer", "")
            part_number = buy.get("manufacturerPartNumber", "")
        sourcing = str(item.get("sourcing", "")).rsplit("::", 1)[-1]
        if sourcing not in ("buy", "make") or not isinstance(item.get("unitCostEur"), (int, float)):
            self.gaps.append(".".join(path) + " (incomplete @BomItem)")
            return
        if mass is None:
            self.gaps.append(".".join(path) + " (no mass)")
            return
        self.lines.append({"level": level, "item": item["description"], "path": ".".join(path),
                           "assembly": False, "module": module, "sourcing": sourcing,
                           "manufacturer": manufacturer, "part_number": part_number,
                           "cost": float(item["unitCostEur"]), "mass": mass})
        self.modules[module] = self.modules.get(module, 0.0) + mass

    def grouped(self) -> list[dict]:
        """One row per distinct item under each assembly, with a quantity."""
        rows: list[dict] = []
        index: dict[tuple, dict] = {}
        parent: list[str] = []
        for line in self.lines:
            del parent[line["level"] - 1:]
            if line["assembly"]:
                rows.append({**line, "quantity": 1})
                parent.append(line["path"])
                continue
            key = (tuple(parent), line["item"], line["part_number"], line["cost"], line["mass"])
            if key in index:
                index[key]["quantity"] += 1
            else:
                row = {**line, "quantity": 1}
                index[key] = row
                rows.append(row)
        return rows


def table(header: list[str], rows: list[list[str]], align: str = "") -> str:
    marks = [("---:" if column < len(align) and align[column] == "r" else "---")
             for column in range(len(header))]
    lines = ["| " + " | ".join(header) + " |", "| " + " | ".join(marks) + " |"]
    lines += ["| " + " | ".join(cell.replace("|", "/") for cell in row) + " |" for row in rows]
    return "\n".join(lines) + "\n"


def bom_outputs(model: Model) -> tuple[dict[str, str], list[str], dict[str, float]]:
    bom = Bom(model)
    rows = bom.grouped()
    body, records = [], []
    total_cost = total_mass = 0.0
    count = 0
    for row in rows:
        indent = " " * (row["level"] - 1)
        if row["assembly"]:
            body.append([indent + "**" + row["item"] + "**", "", "", "", "", "", ""])
            records.append([row["level"], row["item"], row["path"], "", "assembly", "", "", "", "", ""])
            continue
        quantity = row["quantity"]
        cost, mass = row["cost"] * quantity, row["mass"] * quantity
        total_cost += cost
        total_mass += mass
        count += quantity
        source = row["sourcing"].capitalize()
        maker = " ".join(filter(None, [row["manufacturer"], row["part_number"]]))
        body.append([indent + row["item"], str(quantity), source, maker,
                     f"{row['cost']:.2f}", f"{cost:.2f}", f"{mass * 1000:.0f}"])
        records.append([row["level"], row["item"], row["path"], quantity, row["sourcing"],
                        row["manufacturer"], row["part_number"], f"{row['cost']:.2f}",
                        f"{cost:.2f}", f"{mass:.3f}"])
    body.append(["**Total**", str(count), "", "", "", f"**{total_cost:.2f}**",
                 f"**{total_mass * 1000:.0f}**"])
    markdown = table(["Item", "Qty", "Source", "Manufacturer and part number",
                      "Unit cost (EUR)", "Cost (EUR)", "Mass (g)"], body, " r  rrr")
    buffer = io.StringIO()
    writer = csv.writer(buffer, lineterminator="\n")
    writer.writerow(["level", "item", "model_path", "quantity", "sourcing", "manufacturer",
                     "manufacturer_part_number", "unit_cost_eur", "extended_cost_eur", "mass_kg"])
    writer.writerows(records)
    gaps = ["no bill-of-materials classification: " + gap for gap in bom.gaps]
    return {"bom.md": markdown, "bom.csv": buffer.getvalue()}, gaps, bom.modules


def mass_budget(model: Model, modules: dict[str, float]) -> tuple[str, list[str]]:
    limit = None
    for attribute in model.owned(model.element("DesignLimits"), "AttributeUsage"):
        if attribute["name"] == "maxRobotMass":
            for expression in model.owned(attribute, "Expression"):
                limit = kilograms(expression["expression"]["nodes"][0]["value"])
    if limit is None:
        fail("DesignLimits::maxRobotMass has no literal value")
    total = sum(modules.values())
    rows = [[humanize(name), f"{mass:.2f}", f"{100 * mass / total:.0f} %"]
            for name, mass in sorted(modules.items(), key=lambda entry: -entry[1])]
    rows.append(["**Total**", f"**{total:.2f}**", "100 %"])
    rows.append(["Limit (SYS-015)", f"{limit:.2f}", ""])
    rows.append(["Margin", f"{limit - total:.2f}", f"{100 * (limit - total) / limit:.0f} % of the limit"])
    gaps = [] if total <= limit else [f"robot mass {total:.2f} kg exceeds the limit {limit:.2f} kg"]
    return table(["Module", "Mass (kg)", "Share"], rows, " rr"), gaps


def requirement_label(requirement: dict) -> str:
    return f"{requirement['short_name']} {requirement['name']}"


def edges(element: dict, direction: str, kind: str) -> list[str]:
    return [edge["peer"]["qualified_name"] for edge in element["relationships"][direction]
            if edge["kind"] == kind]


def requirement_tables(model: Model) -> tuple[dict[str, str], list[str]]:
    gaps: list[str] = []
    customer = sorted(model.owned(model.element(CUSTOMER), "RequirementUsage"),
                      key=lambda requirement: requirement["short_name"] or "")
    system = sorted(model.owned(model.element(SPECIFICATION), "RequirementUsage"),
                    key=lambda requirement: requirement["short_name"] or "")
    system_names = {requirement["qualified_name"] for requirement in system}

    derivations: dict[str, tuple[list[str], str]] = {}
    for connector in model.connectors:
        if connector["declared_type"].get("qualified_name") != "DerivationConnections::Derivation":
            continue
        original, derived = None, []
        for end in connector["ends"]:
            endpoint = end["endpoint"]
            target = endpoint.get("terminal", endpoint.get("target", {})).get("qualified_name")
            if end["declaration"].endswith("originalRequirement1:0"):
                original = target
            else:
                derived.append(target)
        rationale = model.annotation(model.element(connector["qualified_name"]),
                                     "ModelingMetadata::Rationale") or {}
        if original:
            derivations[original] = (derived, rationale.get("text", ""))

    trace_rows, named = [], set()
    for requirement in customer:
        derived, rationale = derivations.get(requirement["qualified_name"], ([], ""))
        if not derived:
            gaps.append("customer requirement without a derivation: " + requirement_label(requirement))
        named.update(derived)
        labels = [requirement_label(model.element(name)) for name in sorted(
            derived, key=lambda name: model.element(name)["short_name"] or "")]
        trace_rows.append([requirement_label(requirement), "; ".join(labels), rationale])
    for requirement in system:
        if requirement["qualified_name"] not in named:
            gaps.append("system requirement named by no derivation: " + requirement_label(requirement))
    for name in named - system_names:
        gaps.append("derivation names an element that is not a system requirement: " + name)

    satisfied: dict[str, list[str]] = {}
    for satisfy in model.elements:
        if satisfy["kind"] != "SatisfyRequirementUsage":
            continue
        targets = edges(satisfy, "outgoing", "satisfySource")
        by = edges(satisfy, "outgoing", "satisfyTarget")
        for target in targets:
            satisfied.setdefault(target, []).extend(by)
    module = sorted((requirement
                     for specification in model.owned(model.element(MODULES), "RequirementUsage")
                     for requirement in model.owned(specification, "RequirementUsage")),
                    key=lambda requirement: requirement["short_name"] or "")
    module_names = {requirement["qualified_name"] for requirement in module}
    allocation_rows, allocated = [], set()
    for requirement in system:
        derived, rationale = derivations.get(requirement["qualified_name"], ([], ""))
        if not derived:
            continue
        allocated.update(derived)
        for name in set(derived) - module_names:
            gaps.append("allocation names an element that is not a module requirement: " + name)
        labels = [requirement_label(model.element(name)) for name in sorted(
            derived, key=lambda name: model.element(name)["short_name"] or "")]
        allocation_rows.append([requirement_label(requirement), "; ".join(labels), rationale])
    for requirement in module:
        if requirement["qualified_name"] not in allocated:
            gaps.append("module requirement named by no derivation: " + requirement_label(requirement))

    verified: dict[str, list[str]] = {}
    for requirement in system + module:
        for peer in edges(requirement, "incoming", "verifyRequirementTarget"):
            verified.setdefault(requirement["qualified_name"], []).append(peer.split("::")[1])

    def matrix(requirements: list[dict], level: str) -> list[list[str]]:
        rows = []
        for requirement in requirements:
            rows.append(matrix_row(requirement, level))
        return rows

    def matrix_row(requirement: dict, level: str) -> list[str]:
        name = requirement["qualified_name"]
        claims = sorted({claim.split("::", 1)[-1].replace("::", ".") for claim in satisfied.get(name, [])})
        cases = sorted(set(verified.get(name, [])))
        if not claims:
            gaps.append(f"{level} requirement without a satisfaction claim: " + requirement_label(requirement))
        if not cases:
            gaps.append(f"{level} requirement without a verification case: " + requirement_label(requirement))
        return [requirement_label(requirement), ", ".join(claims),
                ", ".join(humanize(case.removeprefix("verify")) for case in cases)]

    matrix_rows = matrix(system, "system")
    module_rows = matrix(module, "module")
    return {
        "allocation.md": table(["System requirement", "Module requirements", "How the budget closes"],
                               allocation_rows),
        "module-matrix.md": table(["Module requirement", "Satisfied by", "Verified by"], module_rows),
        "traceability.md": table(["Customer requirement", "Derived system requirements",
                                  "Why this set is complete"], trace_rows),
        "verification-matrix.md": table(["System requirement", "Satisfied by", "Verified by"],
                                        matrix_rows),
    }, gaps


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--check", action="store_true",
                        help="do not write; fail when a generated file is missing or stale")
    arguments = parser.parse_args()

    model = Model(export())
    files, gaps, modules = bom_outputs(model)
    files["mass-budget.md"], mass_gaps = mass_budget(model, modules)
    requirement_files, requirement_gaps = requirement_tables(model)
    files.update(requirement_files)
    gaps += mass_gaps + requirement_gaps
    if gaps:
        for gap in gaps:
            print("gap: " + gap, file=sys.stderr)
        fail(f"{len(gaps)} gap(s) in the model")

    stale = []
    for name, content in files.items():
        path = OUT / name
        if arguments.check:
            if not path.is_file() or path.read_text(encoding="utf-8") != content:
                stale.append(name)
        else:
            OUT.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8", newline="\n")
    if stale:
        fail("stale generated files: " + ", ".join(stale)
             + "; run python scripts/generate-document-data.py")
    print(("Checked" if arguments.check else "Wrote") + f" {len(files)} files in documents/generated.")


if __name__ == "__main__":
    main()
