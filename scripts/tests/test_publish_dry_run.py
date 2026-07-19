#!/usr/bin/env python3
"""Tests for strict interpretation of Moon's publish dry-run output."""

from __future__ import annotations

import importlib.util
import pathlib
import subprocess
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-publish-dry-run.py"
SUCCESS_OUTPUT = """\
Running moon check ...
Check passed
validating packaged zip: /tmp/CAIMEOX-cairoon-0.2.0.zip
extracting packaged zip to /tmp/mooncake_publish_check
running moon check on extracted package
Running moon check ...
Check passed
Server status: 202 Accepted, detail: Dry run completed successfully. No changes were made. The dry-run was made for package CAIMEOX/cairoon version 0.2.0.
Error: `moon publish` failed
"""
ZERO_EXIT_SUCCESS_OUTPUT = SUCCESS_OUTPUT.replace("Error: `moon publish` failed\n", "")


def load_checker():
    spec = importlib.util.spec_from_file_location("check_publish_dry_run", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PublishDryRunOutputTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.checker = load_checker()

    def check(self, output: str, returncode: int = 255) -> list[str]:
        return self.checker.validate_publish_output(
            output,
            returncode,
            "CAIMEOX/cairoon",
            "0.2.0",
        )

    def test_current_moon_nonzero_success_is_accepted(self) -> None:
        self.assertEqual(self.check(SUCCESS_OUTPUT), [])
        self.assertTrue(
            self.check(
                SUCCESS_OUTPUT.replace("Error: `moon publish` failed\n", ""),
            )
        )

    def test_future_zero_exit_success_is_accepted(self) -> None:
        self.assertEqual(self.check(ZERO_EXIT_SUCCESS_OUTPUT, returncode=0), [])
        self.assertTrue(self.check(SUCCESS_OUTPUT, returncode=0))

    def test_non_success_or_spoofed_registry_response_is_rejected(self) -> None:
        duplicate = SUCCESS_OUTPUT.replace(
            "202 Accepted, detail: Dry run completed successfully. No changes were made.",
            "409 Conflict, detail: Version Error: duplicate version.",
        )
        spoofed = SUCCESS_OUTPUT.replace(
            "Server status: 202 Accepted, detail: Dry run completed successfully. "
            "No changes were made. The dry-run was made for package "
            "CAIMEOX/cairoon version 0.2.0.",
            "Server status: 202 Accepted, detail: unrelated response\n"
            "Dry run completed successfully. No changes were made.\n"
            "The dry-run was made for package CAIMEOX/cairoon version 0.2.0.",
        )
        for output in (duplicate, spoofed):
            with self.subTest(output=output):
                self.assertTrue(self.check(output))

    def test_missing_extracted_check_or_wrong_identity_is_rejected(self) -> None:
        outputs = (
            SUCCESS_OUTPUT.replace("running moon check on extracted package\n", ""),
            SUCCESS_OUTPUT.replace("version 0.2.0.", "version 0.1.0."),
        )
        for output in outputs:
            with self.subTest(output=output):
                self.assertTrue(self.check(output))

    def test_unexpected_exit_code_is_rejected(self) -> None:
        self.assertTrue(self.check(SUCCESS_OUTPUT, returncode=1))

    def test_runner_invokes_only_the_fixed_dry_run_command(self) -> None:
        completed = mock.Mock(stdout="dry-run output", returncode=255)
        repo_root = pathlib.Path("/tmp/cairoon-release-candidate")
        with mock.patch.object(
            self.checker.subprocess,
            "run",
            return_value=completed,
        ) as run:
            result = self.checker.run_publish_dry_run("/opt/moon/bin/moon", repo_root)

        self.assertEqual(result, ("dry-run output", 255))
        run.assert_called_once_with(
            ["/opt/moon/bin/moon", "publish", "--dry-run"],
            cwd=repo_root,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )


if __name__ == "__main__":
    unittest.main()
