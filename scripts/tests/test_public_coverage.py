#!/usr/bin/env python3
"""Tests for the public-package coverage exception gate."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-public-coverage.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_public_coverage", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PublicCoverageTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(CHECKER.exists(), f"missing coverage checker: {CHECKER}")
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        (self.root / "src").mkdir()

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_source(self) -> tuple[pathlib.Path, int]:
        source = self.root / "src" / "sample.mbt"
        lines = [
            "///|",
            "fn first() -> Int {",
            "  1",
            "}",
            "",
            "///|",
            "fn sample_status(raw : Int) -> Int {",
            "  match raw {",
            "    0 => 0",
            "    _ => 6",
            "  }",
            "}",
        ]
        source.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return source, lines.index("    _ => 6") + 1

    def test_report_parser_builds_stable_function_key(self) -> None:
        _, line_no = self.write_source()
        report = (
            "1 uncovered line(s) in src/sample.mbt:\n\n"
            f"{line_no}\t    _ => 6\t<-- UNCOVERED\n"
        )
        actual = self.checker.parse_coverage_report(report, self.root)
        self.assertEqual(
            actual,
            [
                self.checker.CoverageKey(
                    "src/sample.mbt",
                    "sample_status",
                    "_ => 6",
                )
            ],
        )

    def test_report_parser_rejects_section_count_mismatch(self) -> None:
        _, line_no = self.write_source()
        report = (
            "2 uncovered line(s) in src/sample.mbt:\n\n"
            f"{line_no}\t    _ => 6\t<-- UNCOVERED\n"
        )
        with self.assertRaisesRegex(ValueError, "declares 2 uncovered lines but parsed 1"):
            self.checker.parse_coverage_report(report, self.root)

    def test_report_parser_rejects_malformed_uncovered_row(self) -> None:
        self.write_source()
        report = (
            "1 uncovered line(s) in src/sample.mbt:\n\n"
            "not-a-line-number    _ => 6    <-- UNCOVERED\n"
        )
        with self.assertRaisesRegex(ValueError, "malformed uncovered source line"):
            self.checker.parse_coverage_report(report, self.root)

    def test_report_parser_rejects_whitespace_variant_marker(self) -> None:
        _, line_no = self.write_source()
        report = (
            "0 uncovered line(s) in src/sample.mbt:\n\n"
            f"{line_no}\t    _ => 6\t<--  UNCOVERED\n"
        )
        with self.assertRaisesRegex(ValueError, "malformed uncovered source line"):
            self.checker.parse_coverage_report(report, self.root)

    def test_ledger_entry_must_still_exist_in_named_function(self) -> None:
        self.write_source()
        entry = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "sample_status",
                "_ => 6",
            ),
            "defensive-native-value",
            "The native API contract excludes unknown status integers.",
        )
        self.assertEqual(self.checker.check_ledger([entry], self.root), [])

        stale = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "sample_status",
                "_ => 99",
            ),
            "defensive-native-value",
            "The native API contract excludes unknown status integers.",
        )
        errors = self.checker.check_ledger([stale], self.root)
        self.assertTrue(any("source anchor" in error for error in errors))

    def test_ledger_rejects_sources_outside_public_facade(self) -> None:
        internal = self.root / "src" / "internal"
        internal.mkdir()
        (internal / "sample.mbt").write_text(
            "fn hidden() -> Int {\n  42\n}\n",
            encoding="utf-8",
        )
        entry = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/internal/sample.mbt",
                "hidden",
                "42",
            ),
            "defensive-native-value",
            "The internal source is intentionally outside the public facade.",
        )
        errors = self.checker.check_ledger([entry], self.root)
        self.assertTrue(any("outside public facade" in error for error in errors))

    def test_ledger_source_anchor_must_be_unique_in_function(self) -> None:
        source = self.root / "src" / "sample.mbt"
        source.write_text(
            "fn duplicate() -> Int {\n  let _ = 42\n  let _ = 42\n  42\n}\n",
            encoding="utf-8",
        )
        entry = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "duplicate",
                "let _ = 42",
            ),
            "defensive-native-value",
            "The test contains two identical source anchors in one function.",
        )
        errors = self.checker.check_ledger([entry], self.root)
        self.assertTrue(any("source anchor is not unique" in error for error in errors))

    def test_comparison_rejects_new_and_stale_exceptions(self) -> None:
        actual_key = self.checker.CoverageKey(
            "src/sample.mbt",
            "sample_status",
            "_ => 6",
        )
        stale_key = self.checker.CoverageKey(
            "src/sample.mbt",
            "sample_status",
            "0 => 0",
        )
        expected = self.checker.CoverageException(
            stale_key,
            "defensive-native-value",
            "The native API contract excludes unknown status integers.",
        )
        errors = self.checker.compare_coverage([actual_key], [expected])
        self.assertTrue(any("unexpected uncovered" in error for error in errors))
        self.assertTrue(any("stale coverage exception" in error for error in errors))

    def test_ledger_parser_rejects_duplicate_keys(self) -> None:
        self.write_source()
        ledger = self.root / "coverage.tsv"
        row = (
            "src/sample.mbt\tsample_status\t_ => 6\t"
            "defensive-native-value\tall\t"
            "The native API contract excludes unknown status integers.\n"
        )
        ledger.write_text(row + row, encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "duplicate coverage key"):
            self.checker.parse_ledger(ledger)

    def test_ledger_parser_reads_explicit_version_scope(self) -> None:
        self.write_source()
        ledger = self.root / "coverage.tsv"
        ledger.write_text(
            "src/sample.mbt\tsample_status\t_ => 6\t"
            "defensive-native-value\tcairo<1.18.0\t"
            "Cairo before 1.18 cannot exercise this native value branch.\n",
            encoding="utf-8",
        )
        entries = self.checker.parse_ledger(ledger)
        self.assertEqual(entries[0].scope, "cairo<1.18.0")

    def test_coverage_profile_selects_entries_for_linked_version(self) -> None:
        key = self.checker.CoverageKey(
            "src/sample.mbt",
            "sample_status",
            "_ => 6",
        )
        common = self.checker.CoverageException(
            key,
            "defensive-native-value",
            "The native API contract excludes unknown status integers.",
            "all",
        )
        legacy = self.checker.CoverageException(
            key,
            "defensive-native-value",
            "Cairo before 1.18 cannot exercise this native value branch.",
            "cairo<1.18.0",
        )
        modern = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "sample_status",
                "0 => 0",
            ),
            "defensive-native-value",
            "Cairo 1.18 and newer retain this native value branch.",
            "cairo>=1.18.0",
        )
        pre_116 = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "sample_status",
                "1 => 1",
            ),
            "defensive-native-value",
            "Cairo before 1.16 cannot expose this native value branch.",
            "cairo<1.16.0",
        )
        since_116 = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "sample_status",
                "2 => 2",
            ),
            "defensive-native-value",
            "Cairo 1.16 and newer retain this native value branch.",
            "cairo>=1.16.0",
        )
        self.assertEqual(
            self.checker.active_exceptions(
                [common, legacy, modern, pre_116, since_116],
                (1, 15, 10),
            ),
            [common, legacy, pre_116],
        )
        self.assertEqual(
            self.checker.active_exceptions(
                [common, legacy, modern, pre_116, since_116],
                (1, 16, 0),
            ),
            [common, legacy, since_116],
        )
        self.assertEqual(
            self.checker.active_exceptions(
                [common, legacy, modern, pre_116, since_116],
                (1, 18, 4),
            ),
            [common, modern, since_116],
        )

    def test_cairo_version_parser_accepts_pkg_config_versions(self) -> None:
        self.assertEqual(
            self.checker.parse_cairo_version("1.18.4\n"),
            (1, 18, 4),
        )
        with self.assertRaisesRegex(ValueError, "invalid Cairo version"):
            self.checker.parse_cairo_version("development")

    def test_ledger_rejects_unknown_version_scope(self) -> None:
        self.write_source()
        entry = self.checker.CoverageException(
            self.checker.CoverageKey(
                "src/sample.mbt",
                "sample_status",
                "_ => 6",
            ),
            "defensive-native-value",
            "The native API contract excludes unknown status integers.",
            "cairo=1.18",
        )
        errors = self.checker.check_ledger([entry], self.root)
        self.assertTrue(any("unknown version scope" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
