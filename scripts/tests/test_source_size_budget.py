#!/usr/bin/env python3
"""Regression tests for language-specific source size budgets."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest


REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
MODULE_PATH = REPO_ROOT / "scripts" / "check-source-size-budget.py"


def load_module():
    spec = importlib.util.spec_from_file_location("cairoon_source_size_budget", MODULE_PATH)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SourceSizeBudgetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.budget = load_module()

    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_lines(self, name: str, count: int) -> pathlib.Path:
        path = self.root / name
        path.write_text("line\n" * count, encoding="utf-8")
        return path

    def test_every_checked_source_uses_the_600_line_budget(self) -> None:
        for name in (
            "scene.c",
            "private.h",
            "facade.mbt",
            "guide.mbt.md",
            "checker.py",
            "test_checker.py",
            "verify.sh",
        ):
            with self.subTest(name=name):
                self.assertEqual(
                    self.budget.source_line_budget(self.root / name),
                    600,
                )

    def test_c_budget_rejects_601_lines_but_accepts_600(self) -> None:
        at_limit = self.write_lines("at_limit.c", 600)
        over_limit = self.write_lines("over_limit.c", 601)
        ordinary = self.write_lines("ordinary.py", 601)

        self.assertIsNone(self.budget.source_size_violation(at_limit))
        self.assertEqual(
            self.budget.source_size_violation(over_limit),
            (601, 600),
        )
        self.assertEqual(
            self.budget.source_size_violation(ordinary),
            (601, 600),
        )

    def test_python_budget_rejects_601_lines_but_accepts_600(self) -> None:
        at_limit = self.write_lines("test_at_limit.py", 600)
        over_limit = self.write_lines("test_over_limit.py", 601)
        ordinary = self.write_lines("checker.py", 601)

        self.assertEqual(self.budget.source_line_budget(at_limit), 600)
        self.assertIsNone(self.budget.source_size_violation(at_limit))
        self.assertEqual(
            self.budget.source_size_violation(over_limit),
            (601, 600),
        )
        self.assertEqual(
            self.budget.source_size_violation(ordinary),
            (601, 600),
        )

    def test_moonbit_budget_rejects_601_lines_but_accepts_600(self) -> None:
        at_limit = self.write_lines("at_limit.mbt", 600)
        over_limit = self.write_lines("over_limit.mbt", 601)
        doc_over_limit = self.write_lines("guide.mbt.md", 601)
        script_over_limit = self.write_lines("verify.sh", 601)

        self.assertEqual(self.budget.source_line_budget(at_limit), 600)
        self.assertIsNone(self.budget.source_size_violation(at_limit))
        self.assertEqual(
            self.budget.source_size_violation(over_limit),
            (601, 600),
        )
        self.assertEqual(
            self.budget.source_size_violation(doc_over_limit),
            (601, 600),
        )
        self.assertEqual(
            self.budget.source_size_violation(script_over_limit),
            (601, 600),
        )


if __name__ == "__main__":
    unittest.main()
