#!/usr/bin/env python3
"""Tests for the pycairo Context test-parity gate."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-context-test-parity.py"


class ContextTestParityCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.repo_root = pathlib.Path(self.temp_dir.name)
        self.upstream = self.repo_root / "upstream_test_context.py"
        self.context_tests = self.repo_root / "src/tests/context/sample"
        self.public_api = self.repo_root / "src/pkg.generated.mbti"
        self.ledger = self.repo_root / "context-test-parity.json"

        self.context_tests.mkdir(parents=True)
        self.public_api.parent.mkdir(parents=True, exist_ok=True)
        self.upstream.write_text(
            """\
def test_runtime():
    pass

def test_typed():
    with pytest.raises(TypeError):
        object()
""",
            encoding="utf-8",
        )
        (self.context_tests / "sample_test.mbt").write_text(
            """\
test "runtime evidence" {
  inspect(true, content="true")
}

test "typed evidence" {
  inspect(true, content="true")
}
""",
            encoding="utf-8",
        )
        self.public_api.write_text(
            "pub fn Context::typed(Self, Double) -> Unit raise CairoError\n",
            encoding="utf-8",
        )
        self.ledger_data = {
            "schema_version": 1,
            "upstream": {
                "repository": "https://github.com/pygobject/pycairo",
                "commit": "0" * 40,
                "path": "tests/test_context.py",
                "sha256": hashlib.sha256(self.upstream.read_bytes()).hexdigest(),
                "test_count": 2,
            },
            "type_error_policy": (
                "Python runtime type errors map to checked MoonBit signatures."
            ),
            "type_error_tests": ["test_typed"],
            "tests": {
                "test_runtime": {
                    "runtime": [
                        "src/tests/context/sample/sample_test.mbt::runtime evidence"
                    ]
                },
                "test_typed": {
                    "runtime": [
                        "src/tests/context/sample/sample_test.mbt::typed evidence"
                    ],
                    "static_api": [
                        "pub fn Context::typed(Self, Double) -> Unit raise CairoError"
                    ],
                },
            },
        }
        self.write_ledger()

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_ledger(self) -> None:
        self.ledger.write_text(
            json.dumps(self.ledger_data, indent=2) + "\n",
            encoding="utf-8",
        )

    def run_checker(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--repo-root",
                str(self.repo_root),
                "--ledger",
                str(self.ledger),
                "--upstream",
                str(self.upstream),
                "--context-tests",
                str(self.repo_root / "src/tests/context"),
                "--public-api",
                str(self.public_api),
            ],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_complete_mapping_passes(self) -> None:
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("covers 2 upstream Context tests", result.stdout)

    def test_missing_runtime_anchor_fails(self) -> None:
        self.ledger_data["tests"]["test_runtime"]["runtime"] = [
            "src/tests/context/sample/sample_test.mbt::missing evidence"
        ]
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing MoonBit runtime test anchor", result.stderr)

    def test_missing_upstream_uses_pinned_snapshot(self) -> None:
        self.upstream.unlink()

        result = self.run_checker()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("using pinned snapshot", result.stdout)

    def test_type_error_mapping_requires_static_api(self) -> None:
        del self.ledger_data["tests"]["test_typed"]["static_api"]
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires at least one static_api anchor", result.stderr)


if __name__ == "__main__":
    unittest.main()
