# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT
"""Procurement export must preserve monetary units and make/buy meaning."""
import importlib.util
import sys
import unittest
from pathlib import Path
from unittest.mock import Mock

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
spec = importlib.util.spec_from_file_location("document_data", SCRIPTS / "generate-document-data.py")
data = importlib.util.module_from_spec(spec)
spec.loader.exec_module(data)


class ProcurementBom(unittest.TestCase):
    def export_item(self, *, buy=None, make=None, cost=None, selected=None):
        root = {"token": "root"}
        usage = {"token": "usage", "modifiers": []}
        typed = {"token": "part", "qualified_name": "Example::Part",
                 "documentation": [{"form": "doc", "text": "Example part"}]}
        catalog = {"token": "catalog"}
        model = Mock()
        model.element.return_value = root
        model.effective_parts.side_effect = lambda element: [usage] if element is root else []
        model.is_aggregate.return_value = False
        model.definition.return_value = typed, typed["qualified_name"]
        model.feature_name.return_value = "component"
        model.lineage.side_effect = lambda element: iter([element])
        model.selected_part.return_value = catalog if selected is not None else None
        model.annotation.side_effect = lambda element, name: (
            selected if element is catalog else buy if name.endswith("::BuyPart") else make)
        model.redefined_value.side_effect = lambda element, name: (
            {"magnitude": 0.1, "unit": "kg"} if name == "mass" else
            cost if element is typed else None)
        return data.Bom(model)

    def test_buy_uses_selected_catalog_identity_and_definition_cost(self):
        bom = self.export_item(buy={}, cost={"magnitude": 2.5, "unit": "EUR"},
                               selected={"manufacturer": "Example", "manufacturerPartNumber": "P1"})
        self.assertEqual(bom.gaps, [])
        self.assertEqual(len(bom.lines), 1)
        line = bom.lines[0]
        self.assertEqual((line["sourcing"], line["manufacturer"], line["part_number"], line["cost"]),
                         ("buy", "Example", "P1", 2.5))

    def test_empty_make_annotation_is_classification(self):
        bom = self.export_item(make={}, cost={"magnitude": 0, "unit": "EUR"})
        self.assertEqual(bom.gaps, [])
        self.assertEqual(bom.lines[0]["sourcing"], "make")
        self.assertEqual(bom.lines[0]["cost"], 0)

    def test_currency_missing_cost_and_negative_amount_cannot_be_silently_totalled(self):
        for cost in (None, 2.5, {"magnitude": 2.5, "unit": "USD"},
                     {"magnitude": -1, "unit": "EUR"}):
            with self.subTest(cost=cost):
                bom = self.export_item(buy={}, cost=cost)
                self.assertEqual(bom.lines, [])
                self.assertIn("unitCost", bom.gaps[0])

    def test_conflicting_make_buy_fails(self):
        bom = self.export_item(buy={}, make={}, cost={"magnitude": 2.5, "unit": "EUR"})
        self.assertEqual(bom.lines, [])
        self.assertIn("both @BuyPart and @MakePart", bom.gaps[0])


if __name__ == "__main__":
    unittest.main()
