#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT
"""Generate the bill of materials and check the model for gaps.

Reads one Spec42 export of `model/` and writes into `generated/`:

    bom.md           bill of materials with quantities, sourcing, cost and mass
    bom.csv          the same lines for a spreadsheet or an ERP import
    mass-budget.md   mass per module against the robot mass limit

Trace tables and verification matrices are retained as model content selections;
document rendering is disabled. A bill of materials needs the part tree walked
through its definitions and quantities added up, which this script does.

It also checks the model for gaps and fails when it finds one: a physical part
without a bill-of-materials classification or a mass, a customer requirement
without a derivation, a system or module requirement that no derivation names,
a system or module requirement without a satisfaction claim or a
verification case, or a customer requirement without a validation case.

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
OUT = ROOT / "generated"
ROBOT = "RobotPlatformSystem::AutonomousFloorCleaningRobotIntegration"
SPECIFICATION = "RobotPlatformSystem::Requirements::robotSystemSpecification"
CUSTOMER = "StakeholderNeeds"
MODULES = (
    "BaseSystem::Requirements::baseModuleSpecification",
    "MainControlBoardSystem::Requirements::mainPcbSpecification",
    "FirmwareSystem::Requirements::firmwareSpecification",
    "TopSystem::Requirements::topModuleSpecification",
    "DustBinSystem::Requirements::dustBinSpecification",
    "RobotPlatformSystem::HarnessRequirements::harnessSpecification",
)
# Packages whose part definitions are logical, not purchasable or made items.
LOGICAL_PACKAGES = ("DomainModel::", "FirmwareSystem::", "FirmwareLibrary::")


def fail(message: str) -> "NoReturn":
    raise SystemExit("error: " + message)


def library_arguments() -> list[str]:
    """The same library selection as scripts/validate.ps1 and the CI workflow."""
    domain = os.environ.get("SYSML_DOMAIN_LIBRARIES_ROOT")
    for base in (ROOT / ".libraries", ROOT.parent):
        if not domain and (base / "sysml-domain-libraries" / "model").is_dir():
            domain = str(base / "sysml-domain-libraries")
    if not domain:
        fail("check out sysml-domain-libraries next to this repository, "
             "or set SYSML_DOMAIN_LIBRARIES_ROOT")
    # `method` is the managed archive older Spec42 releases bundle; the model no longer uses it.
    return ["--disable-kpar-library", "domain", "--disable-kpar-library", "method",
            "--library-path", str(Path(domain) / "model")]


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
    # The validator checks each diagnostic, including the four documented
    # Spec42 0.56.0 custom-view warnings. Do not accept warnings on count alone.
    from validate_model import check_language
    check_language(spec42, library_arguments(), ROOT / "model")
    if summary["error_count"]:
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

    def lineage(self, element: dict, relation: str = "specialization", active=()):
        """Most-specific first; retain semantic identity, never infer from names."""
        if element["token"] in active:
            fail("cyclic semantic inheritance")
        yield element
        for target in element["relationships"].get(relation, {}).get("targets", []):
            parent = self.by_token.get(target["token"])
            if parent is not None:
                yield from self.lineage(parent, relation, (*active, element["token"]))

    def feature_name(self, feature: dict) -> str:
        for parent in self.lineage(feature, "redefinition"):
            if parent.get("name"):
                return parent["name"]
        fail("unnamed feature with no named redefined feature")

    def effective_parts(self, definition: dict) -> list[dict]:
        candidates = {}
        for base in self.lineage(definition):
            for part in self.owned(base, "PartUsage"):
                candidates.setdefault(part["token"], part)
        hidden = {base["token"] for part in candidates.values()
                  for base in list(self.lineage(part, "redefinition"))[1:]}
        return [part for key, part in candidates.items() if key not in hidden]

    def is_aggregate(self, usage: dict) -> bool:
        # A collection whose members are the named subset features is not an
        # additional physical item (e.g. PCBA mountedComponents).
        return any(edge["kind"] == "subsetting" and edge.get("provenance") == "authored"
                   for base in self.lineage(usage, "redefinition")
                   for edge in base["relationships"]["incoming"])

    def definition(self, usage: dict) -> tuple[dict | None, str]:
        """The typing definition of a usage: (workspace element or None, qualified name)."""
        targets = usage["relationships"]["typing"]["targets"]
        if not targets:
            return None, ""
        return self.by_token.get(targets[0]["token"]), targets[0]["qualified_name"]

    def annotation(self, element: dict, definition: str) -> dict | None:
        """The values of the element's annotation of one metadata definition."""
        annotations = [annotation for base in self.lineage(element)
                       for annotation in base.get("metadata_annotations", [])]
        for annotation in annotations:
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
        for attribute in [child for base in self.lineage(element)
                          for child in self.owned(base, "AttributeUsage")]:
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
        for dependency in [child for base in self.lineage(definition)
                           for child in self.owned(base, "Dependency")]:
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
        for usage in self.model.effective_parts(definition):
            if "ref" in usage["modifiers"] or self.model.is_aggregate(usage):
                continue
            typed, type_name = self.model.definition(usage)
            name = self.model.feature_name(usage)
            here = path + [name]
            top = module or name
            buy = self.model.annotation(typed, "Procurement::BuyPart") if typed else None
            make = self.model.annotation(typed, "Procurement::MakePart") if typed else None
            if buy is not None or make is not None:
                if buy is not None and make is not None:
                    self.gaps.append(".".join(here) + " (both @BuyPart and @MakePart)")
                    continue
                self.add_item(usage, typed, here, level, top,
                              "buy" if buy is not None else "make", buy or {})
                added = True
                continue
            if type_name.startswith(LOGICAL_PACKAGES) or (typed is not None and any(
                    base["qualified_name"].startswith(LOGICAL_PACKAGES)
                    for base in self.model.lineage(typed))):
                continue
            index = len(self.lines)
            self.lines.append({"level": level, "item": humanize(name),
                               "path": ".".join(here), "assembly": True, "module": top})
            if typed is not None and self.walk(typed, here, level + 1, top):
                added = True
            else:
                del self.lines[index:]
                self.gaps.append(".".join(here))
        return added

    def add_item(self, usage, typed, path, level, module, sourcing, buy) -> None:
        model = self.model
        mass = kilograms(model.redefined_value(usage, "mass"))
        if mass is None and typed is not None:
            mass = kilograms(model.redefined_value(typed, "mass"))
        selected = model.selected_part(typed)
        if selected is not None:
            buy = model.annotation(selected, "Procurement::BuyPart") or buy
        manufacturer = buy.get("manufacturer", "")
        part_number = buy.get("manufacturerPartNumber", "")
        cost = model.redefined_value(usage, "unitCost")
        if cost is None:
            cost = model.redefined_value(typed, "unitCost")
        if (not isinstance(cost, dict) or cost.get("unit") != "EUR"
                or not isinstance(cost.get("magnitude"), (int, float))
                or cost["magnitude"] < 0):
            self.gaps.append(".".join(path) + " (unitCost must be a nonnegative EUR amount)")
            return
        # The concrete definition's first doc is its short procurement description.
        descriptions = [entry["text"].strip() for entry in typed["documentation"]
                        if entry["form"] == "doc"]
        if not descriptions:
            self.gaps.append(".".join(path) + " (no procurement description)")
            return
        if mass is None:
            self.gaps.append(".".join(path) + " (no mass)")
            return
        self.lines.append({"level": level, "item": descriptions[0], "path": ".".join(path),
                           "assembly": False, "module": module, "sourcing": sourcing,
                           "manufacturer": manufacturer, "part_number": part_number,
                           "cost": float(cost["magnitude"]), "mass": mass})
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
    for attribute in model.owned(model.element("RobotPlatformSystem::Limits"), "AttributeUsage"):
        if attribute["name"] == "maxRobotMass":
            for expression in model.owned(attribute, "Expression"):
                limit = kilograms(expression["expression"]["nodes"][0]["value"])
    if limit is None:
        fail("RequirementLimits::maxRobotMass has no literal value")
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


def requirement_gaps(model: Model) -> list[str]:
    """Coverage gaps between the requirement levels and towards design and verification."""
    gaps: list[str] = []
    customer = model.owned(model.element(CUSTOMER), "RequirementUsage")
    system = model.owned(model.element(SPECIFICATION), "RequirementUsage")
    module = [requirement
              for specification in (model.element(name) for name in MODULES)
              for requirement in model.owned(specification, "RequirementUsage")]
    names = {level: {requirement["qualified_name"] for requirement in requirements}
             for level, requirements in (("system", system), ("module", module))}

    # Original requirement -> the requirements one derivation derives from it.
    derivations: dict[str, list[str]] = {}
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
        if original:
            derivations[original] = derived

    def derived_from(originals: list[dict], level: str, required: bool) -> None:
        """Checks one step between levels: `originals` derive the requirements of `level`."""
        named: set[str] = set()
        for requirement in originals:
            derived = derivations.get(requirement["qualified_name"], [])
            if required and not derived:
                gaps.append("requirement without a derivation: " + requirement_label(requirement))
            named.update(derived)
        for requirement in (system if level == "system" else module):
            if requirement["qualified_name"] not in named:
                gaps.append(f"{level} requirement named by no derivation: "
                            + requirement_label(requirement))
        for name in sorted(named - names[level]):
            gaps.append(f"a derivation names an element that is not a {level} requirement: {name}")

    derived_from(customer, "system", required=True)
    # Only system requirements that no single module can meet are split into module budgets.
    derived_from(system, "module", required=False)

    satisfied: set[str] = set()
    for satisfy in model.elements:
        if satisfy["kind"] == "SatisfyRequirementUsage":
            satisfied.update(edges(satisfy, "outgoing", "satisfySource"))
    for level, requirements in (("system", system), ("module", module)):
        for requirement in requirements:
            if requirement["qualified_name"] not in satisfied:
                gaps.append(f"{level} requirement without a satisfaction claim: "
                            + requirement_label(requirement))
            if not edges(requirement, "incoming", "verifyRequirementTarget"):
                gaps.append(f"{level} requirement without a verification case: "
                            + requirement_label(requirement))
    for requirement in customer:
        if not edges(requirement, "incoming", "verifyRequirementTarget"):
            gaps.append("customer requirement without a validation case: "
                        + requirement_label(requirement))
    return gaps


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--check", action="store_true",
                        help="do not write; fail when a generated file is missing or stale")
    arguments = parser.parse_args()

    model = Model(export())
    files, gaps, modules = bom_outputs(model)
    files["mass-budget.md"], mass_gaps = mass_budget(model, modules)
    gaps += mass_gaps + requirement_gaps(model)
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
    print(("Checked" if arguments.check else "Wrote") + f" {len(files)} files in generated/.")


if __name__ == "__main__":
    main()
