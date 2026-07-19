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

    def test_c_sources_have_a_stricter_budget(self) -> None:
        self.assertEqual(
            self.budget.source_line_budget(self.root / "scene.c"),
            600,
        )
        self.assertEqual(
            self.budget.source_line_budget(self.root / "private.h"),
            600,
        )
        self.assertEqual(
            self.budget.source_line_budget(self.root / "checker.py"),
            850,
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
        self.assertIsNone(self.budget.source_size_violation(ordinary))

    def test_python_test_budget_rejects_601_lines_but_accepts_600(self) -> None:
        at_limit = self.write_lines("test_at_limit.py", 600)
        over_limit = self.write_lines("test_over_limit.py", 601)
        ordinary = self.write_lines("checker.py", 601)

        self.assertEqual(self.budget.source_line_budget(at_limit), 600)
        self.assertIsNone(self.budget.source_size_violation(at_limit))
        self.assertEqual(
            self.budget.source_size_violation(over_limit),
            (601, 600),
        )
        self.assertIsNone(self.budget.source_size_violation(ordinary))


if __name__ == "__main__":
    unittest.main()
