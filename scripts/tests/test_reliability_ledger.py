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


if __name__ == "__main__":
    unittest.main()
