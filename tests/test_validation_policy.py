# SPDX-FileCopyrightText: 2026 Elan8
# SPDX-License-Identifier: MIT
"""The tool exception must never accept unrelated warnings or errors."""
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from validate_model import check_language


class DiagnosticPolicy(unittest.TestCase):
    def report(self, code="view_type_non_standard", severity=2,
               path="00_context/Context.sysml", view_type="ContextView", count=1):
        return {"documents": [{"uri": "file:///project/model/" + path,
                               "diagnostics": [{"severity": severity, "code": code,
                                                "message": f"View type '{view_type}' is not standard."}
                                               for _ in range(count)]}]}

    def check(self, report):
        with patch("validate_model.run_json", return_value=report):
            return check_language("spec42", [], Path("model"))

    def test_documented_custom_view_warning_is_reported(self):
        report, count = self.check(self.report())
        self.assertEqual(count, 1)
        self.assertEqual(report["documents"][0]["diagnostics"][0]["severity"], 2)

    def test_clean_report_needs_no_exception(self):
        self.assertEqual(self.check({"documents": []})[1], 0)

    def test_other_warning_same_count_fails(self):
        for report in [self.report(code="unresolved_reference"),
                       self.report(path="60_systems/BaseSystem/system.sysml"),
                       self.report(view_type="OtherCustomView")]:
            with self.subTest(report=report), self.assertRaises(SystemExit):
                self.check(report)

    def test_error_cannot_use_warning_exception(self):
        with self.assertRaises(SystemExit):
            self.check(self.report(severity=1))

    def test_additional_custom_view_warning_fails(self):
        with self.assertRaises(SystemExit):
            self.check(self.report(count=2))


if __name__ == "__main__":
    unittest.main()
