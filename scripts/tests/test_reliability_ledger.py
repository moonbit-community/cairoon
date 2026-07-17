#!/usr/bin/env python3
"""Tests for downstream-consumer reliability gate wiring."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-reliability-ledger.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_reliability_ledger", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class DownstreamConsumerGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "consumer.sh"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check(
        self,
        omitted: str | None = None,
        commented: str | None = None,
    ) -> list[str]:
        markers = [
            f"# {line}" if line == commented else line
            for line in self.checker.DOWNSTREAM_GATE_LINES
            if line != omitted
        ]
        self.script.write_text("\n".join(markers), encoding="utf-8")
        with mock.patch.object(self.checker, "DOWNSTREAM_CONSUMER", self.script):
            return self.checker.check_downstream_consumer_gate()

    def test_complete_artifact_gate_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_missing_artifact_fmt_fails(self) -> None:
        marker = 'run moon -C "$artifact_consumer_root" fmt --check "$consumer_package"'
        self.assertTrue(self.check(marker))

    def test_missing_artifact_check_fails(self) -> None:
        marker = (
            'run moon -C "$artifact_consumer_root" check "$consumer_package" '
            "--target native --deny-warn"
        )
        self.assertTrue(self.check(marker))

    def test_missing_artifact_test_fails(self) -> None:
        marker = (
            'run moon -C "$artifact_consumer_root" test "$consumer_package" '
            "--target native --deny-warn -v"
        )
        self.assertTrue(self.check(marker))

    def test_missing_published_workspace_member_fails(self) -> None:
        self.assertTrue(self.check("'  \"./published\",' \\"))

    def test_commented_artifact_test_fails(self) -> None:
        marker = (
            'run moon -C "$artifact_consumer_root" test "$consumer_package" '
            "--target native --deny-warn -v"
        )
        self.assertTrue(self.check(commented=marker))


class VerifyGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "verify.sh"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_missing_public_coverage_ledger_gate_fails(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.assertIn(marker, self.checker.VERIFY_COMMANDS)
        self.script.write_text(
            "\n".join(
                f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
                if command != marker
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

    def test_commented_public_coverage_gate_fails(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.script.write_text(
            "\n".join(
                f"# run {command}" if command == marker else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

    def test_inline_comment_cannot_impersonate_public_coverage_gate(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.script.write_text(
            "\n".join(
                f": # {command}" if command == marker else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

    def test_failure_masking_cannot_impersonate_verify_gate(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.script.write_text(
            "\n".join(
                f"run {command} || true"
                if command == marker
                else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))


class LocalMatrixGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.matrix = self.root / "scripts" / "test-cairo-matrix.sh"
        self.lane = self.root / "scripts" / "matrix" / "run-lane.sh"
        self.sanitizer = self.root / "scripts" / "sanitizers" / "run.py"
        self.lane.parent.mkdir(parents=True)
        self.sanitizer.parent.mkdir(parents=True)
        self.matrix.write_text(
            "cairo-1.15.10\ncairo-1.18.4\nCAIROON_SANITIZER_LEAKS=on\n",
            encoding="utf-8",
        )
        self.sanitizer.write_text(
            "\n".join(
                [
                    "compiler_preflight",
                    "probe_recording_snapshot_leak",
                    "RECORDING_SNAPSHOT_PACKAGES",
                    "probe_pdf_jbig2_missing_leak",
                    "PDF_JBIG2_MISSING_PACKAGES",
                    "discover_packages",
                    "MOON_TOOLCHAIN_ROOT",
                    "validate_suppression_usage",
                    "validate_pdf_jbig2_suppression_usage",
                ]
            ),
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check(self, lane_text: str) -> list[str]:
        self.lane.write_text(lane_text, encoding="utf-8")
        with (
            mock.patch.object(self.checker, "REPO_ROOT", self.root),
            mock.patch.object(self.checker, "MATRIX", self.matrix),
            mock.patch.object(self.checker, "SANITIZER", self.sanitizer),
        ):
            return self.checker.check_local_matrix()

    def test_matrix_lane_requires_instrumented_public_coverage(self) -> None:
        errors = self.check("./scripts/verify.sh\n")
        self.assertTrue(any("--analyze" in error for error in errors))

    def test_matrix_lane_accepts_active_instrumented_public_coverage(self) -> None:
        errors = self.check(
            "python3 ./scripts/check-public-coverage.py --analyze\n"
            "./scripts/verify.sh\n"
        )
        self.assertEqual(errors, [])

    def test_matrix_lane_rejects_commented_instrumented_coverage(self) -> None:
        errors = self.check(
            ": # python3 ./scripts/check-public-coverage.py --analyze\n"
            "./scripts/verify.sh\n"
        )
        self.assertTrue(any("--analyze" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
