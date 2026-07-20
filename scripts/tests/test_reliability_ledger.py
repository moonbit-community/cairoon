#!/usr/bin/env python3
"""Tests for downstream-consumer and local verify reliability gates."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-reliability-ledger.py"

CONSUMER_CONTRACT_TESTS = {
    "image_render_test.mbt": (
        "consumer renders paths and patterns",
    ),
    "mapped_lifecycle_test.mbt": (
        "consumer maps and unmaps image data with scoped ownership",
    ),
    "value_error_test.mbt": (
        "consumer composes matrix and region values",
        "consumer matches typed cairo errors",
    ),
    "stream_helpers_test.mbt": (),
    "png_stream_test.mbt": (
        "consumer round trips PNG stream callbacks",
    ),
    "pdf_stream_test.mbt": (
        "consumer finishes PDF stream callbacks",
    ),
}



def load_checker():
    spec = importlib.util.spec_from_file_location("check_reliability_ledger", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ReliabilityGateDelegationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()

    def test_gate_wrappers_delegate_current_paths(self) -> None:
        with mock.patch.object(
            self.checker,
            "_check_verify_gate",
            return_value=["verify"],
        ) as check_verify:
            self.assertEqual(self.checker.check_verify_gate(), ["verify"])
        check_verify.assert_called_once_with(self.checker.VERIFY)

        with mock.patch.object(
            self.checker,
            "_check_downstream_consumer_gate",
            return_value=["consumer"],
        ) as check_consumer:
            self.assertEqual(
                self.checker.check_downstream_consumer_gate(),
                ["consumer"],
            )
        check_consumer.assert_called_once_with(
            self.checker.DOWNSTREAM_CONSUMER,
            self.checker.DOWNSTREAM_CONSUMER_PACKAGE,
        )

        workflow = self.checker.CI.read_text(encoding="utf-8")
        with mock.patch.object(
            self.checker,
            "_check_ci_workflow",
            return_value=["ci"],
        ) as check_ci:
            self.assertEqual(self.checker.check_ci_gate(), ["ci"])
        check_ci.assert_called_once_with(workflow, self.checker.CI)


class DownstreamConsumerGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "consumer.sh"
        self.consumer_package = pathlib.Path(self.temp_dir.name) / "contract"
        self.consumer_package.mkdir()

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check(
        self,
        omitted: str | None = None,
        commented: str | None = None,
        omitted_source: str | None = None,
        missing_file: str | None = None,
        missing_test: str | None = None,
    ) -> list[str]:
        markers = [
            f"# {line}" if line == commented else line
            for line in self.checker.DOWNSTREAM_GATE_LINES
            if line != omitted
        ]
        sources = [
            source
            for source in CONSUMER_CONTRACT_TESTS
            if source != omitted_source
        ]
        script_lines = [
            'consumer_package="src/contract"',
            "consumer_sources=(",
            *(f'  "{source}"' for source in sources),
            ")",
            *markers,
        ]
        self.script.write_text("\n".join(script_lines), encoding="utf-8")
        for source, tests in CONSUMER_CONTRACT_TESTS.items():
            path = self.consumer_package / source
            if source == missing_file:
                if path.exists():
                    path.unlink()
                continue
            declarations = [
                f'test "{name}" {{}}'
                for name in tests
                if name != missing_test
            ]
            path.write_text("\n".join(declarations), encoding="utf-8")
        with (
            mock.patch.object(self.checker, "DOWNSTREAM_CONSUMER", self.script),
            mock.patch.object(
                self.checker,
                "DOWNSTREAM_CONSUMER_PACKAGE",
                self.consumer_package,
                create=True,
            ),
        ):
            return self.checker.check_downstream_consumer_gate()

    def test_complete_artifact_gate_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_missing_existing_archive_mode_fails(self) -> None:
        self.assertTrue(
            self.check('if [[ "$#" == 2 && "$1" == "--archive" ]]; then')
        )

    def test_existing_archive_mode_must_skip_source_repackaging(self) -> None:
        self.assertTrue(self.check("test_source=0"))

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

    def test_consumer_source_manifest_must_be_complete(self) -> None:
        self.assertTrue(self.check(omitted_source="png_stream_test.mbt"))

    def test_missing_consumer_contract_source_fails(self) -> None:
        self.assertTrue(self.check(missing_file="mapped_lifecycle_test.mbt"))

    def test_missing_named_consumer_workflow_fails(self) -> None:
        self.assertTrue(
            self.check(missing_test="consumer matches typed cairo errors")
        )


class VerifyGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "verify.sh"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_native_check_requires_warning_73(self) -> None:
        marker = "moon check --target native --deny-warn --warn-list +73"
        downgraded = "moon check --target native --deny-warn"
        self.assertIn(marker, self.checker.VERIFY_COMMANDS)
        self.script.write_text(
            "\n".join(
                f"run {downgraded}" if command == marker else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

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

        sanitizer_command = "run: python3 ./scripts/sanitizers/run.py"
        workflow = self.checker.CI.read_text(encoding="utf-8").replace(
            sanitizer_command,
            f"# {sanitizer_command}",
        )
        self.script.write_text(workflow, encoding="utf-8")
        with mock.patch.object(self.checker, "CI", self.script):
            errors = self.checker.check_ci_gate()
        self.assertTrue(any(sanitizer_command in error for error in errors))

if __name__ == "__main__":
    unittest.main()
