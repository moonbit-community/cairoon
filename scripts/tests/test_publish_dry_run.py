#!/usr/bin/env python3
"""Tests for strict interpretation of Moon's publish dry-run output."""

from __future__ import annotations

import importlib.util
import pathlib
import unittest


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

    def test_future_zero_exit_success_is_accepted(self) -> None:
        self.assertEqual(self.check(SUCCESS_OUTPUT, returncode=0), [])

    def test_duplicate_registry_version_is_rejected(self) -> None:
        output = SUCCESS_OUTPUT.replace(
            "202 Accepted, detail: Dry run completed successfully. No changes were made.",
            "409 Conflict, detail: Version Error: duplicate version.",
        )
        self.assertTrue(self.check(output))

    def test_missing_extracted_package_check_is_rejected(self) -> None:
        output = SUCCESS_OUTPUT.replace("running moon check on extracted package\n", "")
        self.assertTrue(self.check(output))

    def test_wrong_package_version_is_rejected(self) -> None:
        output = SUCCESS_OUTPUT.replace("version 0.2.0.", "version 0.1.0.")
        self.assertTrue(self.check(output))

    def test_unexpected_exit_code_is_rejected(self) -> None:
        self.assertTrue(self.check(SUCCESS_OUTPUT, returncode=1))


if __name__ == "__main__":
    unittest.main()
