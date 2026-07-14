#!/usr/bin/env python3
"""Tests for the pycairo family test-parity gate."""

from __future__ import annotations

import copy
import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-pycairo-test-parity.py"


class PycairoTestParityCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.repo_root = pathlib.Path(self.temp_dir.name)
        self.upstream = self.repo_root / "upstream_test_sample.py"
        self.runtime_tests = self.repo_root / "src/tests/sample"
        self.public_api = self.repo_root / "src/pkg.generated.mbti"
        self.inventory = self.repo_root / "API_INVENTORY.md"
        self.ledger = self.repo_root / "sample-test-parity.json"
        self.ledger_dir = self.repo_root / "scripts/parity"

        self.runtime_tests.mkdir(parents=True)
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
        (self.runtime_tests / "sample_test.mbt").write_text(
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
        self.inventory.write_text(
            "| `get_include()` | Decision | Python-only header discovery |\n",
            encoding="utf-8",
        )
        self.ledger_data = {
            "schema_version": 1,
            "family": "Sample",
            "runtime_root": "src/tests/sample",
            "upstream": {
                "repository": "https://github.com/pygobject/pycairo",
                "commit": "0" * 40,
                "path": "upstream_test_sample.py",
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
                        "src/tests/sample/sample_test.mbt::runtime evidence"
                    ]
                },
                "test_typed": {
                    "runtime": [
                        "src/tests/sample/sample_test.mbt::typed evidence"
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

    def write_ledger(
        self,
        path: pathlib.Path | None = None,
        data: dict[str, object] | None = None,
    ) -> None:
        destination = path or self.ledger
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(
            json.dumps(data or self.ledger_data, indent=2) + "\n",
            encoding="utf-8",
        )

    def run_checker(
        self,
        *,
        discover_ledgers: bool = False,
        extra_args: list[str] | None = None,
    ) -> subprocess.CompletedProcess[str]:
        ledger_args = [] if discover_ledgers else ["--ledger", str(self.ledger)]
        return subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--repo-root",
                str(self.repo_root),
                "--upstream-root",
                str(self.repo_root),
                "--public-api",
                str(self.public_api),
                *ledger_args,
                *(extra_args or []),
            ],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_complete_mapping_passes(self) -> None:
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Sample parity ledger covers 2 upstream tests", result.stdout)

    def test_source_without_type_errors_accepts_empty_mapping(self) -> None:
        self.upstream.write_text(
            """\
def test_runtime():
    pass
""",
            encoding="utf-8",
        )
        self.ledger_data["upstream"]["sha256"] = hashlib.sha256(
            self.upstream.read_bytes()
        ).hexdigest()
        self.ledger_data["upstream"]["test_count"] = 1
        self.ledger_data["type_error_tests"] = []
        del self.ledger_data["tests"]["test_typed"]
        self.write_ledger()

        result = self.run_checker()

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_tuple_type_error_assertion_is_detected(self) -> None:
        self.upstream.write_text(
            """\
def test_runtime():
    pass

def test_typed():
    with pytest.raises((TypeError, AttributeError)):
        object()
""",
            encoding="utf-8",
        )
        self.ledger_data["upstream"]["sha256"] = hashlib.sha256(
            self.upstream.read_bytes()
        ).hexdigest()
        self.write_ledger()

        result = self.run_checker()

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_decision_mapping_can_replace_runtime_evidence(self) -> None:
        self.upstream.write_text("def test_runtime():\n    pass\n", encoding="utf-8")
        self.ledger_data["upstream"]["sha256"] = hashlib.sha256(
            self.upstream.read_bytes()
        ).hexdigest()
        self.ledger_data["upstream"]["test_count"] = 1
        self.ledger_data["type_error_tests"] = []
        self.ledger_data["tests"] = {
            "test_runtime": {
                "decision": "| `get_include()` | Decision |",
                "adaptation": "MoonBit uses package-native link configuration.",
            }
        }
        self.write_ledger()

        result = self.run_checker()

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_decision_mapping_requires_inventory_anchor(self) -> None:
        self.ledger_data["tests"]["test_runtime"] = {
            "decision": "| `missing()` | Decision |",
            "adaptation": "The API is outside the MoonBit product scope.",
        }
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing inventory decision anchor", result.stderr)

    def test_decision_mapping_requires_adaptation(self) -> None:
        self.ledger_data["tests"]["test_runtime"] = {
            "decision": "| `get_include()` | Decision |"
        }
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("decision mappings require adaptation", result.stderr)

    def test_missing_runtime_anchor_fails(self) -> None:
        self.ledger_data["tests"]["test_runtime"]["runtime"] = [
            "src/tests/sample/sample_test.mbt::missing evidence"
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

    def test_detected_source_checkout_requires_upstream_file(self) -> None:
        marker = self.repo_root / "cairo/__init__.pyi"
        marker.parent.mkdir()
        marker.write_text("", encoding="utf-8")
        self.ledger_data["upstream"]["path"] = "tests/missing.py"
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("source checkout is missing", result.stderr)

    def test_require_source_rejects_snapshot_fallback(self) -> None:
        self.upstream.unlink()

        result = self.run_checker(extra_args=["--require-source"])

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("source checkout is missing", result.stderr)

    def test_default_ledger_discovery_checks_multiple_families(self) -> None:
        other = copy.deepcopy(self.ledger_data)
        other["family"] = "Other"
        self.write_ledger(self.ledger_dir / "sample.json")
        self.write_ledger(self.ledger_dir / "other.json", other)

        result = self.run_checker(discover_ledgers=True)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Sample parity ledger", result.stdout)
        self.assertIn("Other parity ledger", result.stdout)
        self.assertIn("4 upstream tests across 2 families", result.stdout)

    def test_default_ledger_discovery_rejects_duplicate_family(self) -> None:
        self.write_ledger(self.ledger_dir / "first.json")
        self.write_ledger(self.ledger_dir / "second.json")

        result = self.run_checker(discover_ledgers=True)

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("duplicate parity family", result.stderr)

    def test_source_sha_drift_fails(self) -> None:
        self.upstream.write_text(
            self.upstream.read_text(encoding="utf-8") + "\n# drift\n",
            encoding="utf-8",
        )

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("SHA-256 drift", result.stderr)

    def test_source_test_set_drift_fails(self) -> None:
        self.upstream.write_text(
            self.upstream.read_text(encoding="utf-8")
            + "\ndef test_added():\n    pass\n",
            encoding="utf-8",
        )
        self.ledger_data["upstream"]["sha256"] = hashlib.sha256(
            self.upstream.read_bytes()
        ).hexdigest()
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("test_added", result.stderr)
        self.assertIn("is unmapped", result.stderr)

    def test_source_type_error_set_drift_fails(self) -> None:
        self.upstream.write_text(
            """\
def test_runtime():
    pass

def test_typed():
    pass
""",
            encoding="utf-8",
        )
        self.ledger_data["upstream"]["sha256"] = hashlib.sha256(
            self.upstream.read_bytes()
        ).hexdigest()
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("stale TypeError mapping", result.stderr)

    def test_type_error_mapping_requires_static_evidence(self) -> None:
        del self.ledger_data["tests"]["test_typed"]["static_api"]
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires static_api or static_absent evidence", result.stderr)

    def test_type_error_mapping_accepts_absent_static_api(self) -> None:
        del self.ledger_data["tests"]["test_typed"]["static_api"]
        self.ledger_data["tests"]["test_typed"]["static_absent"] = [
            "pub fn Pattern::new("
        ]
        self.write_ledger()

        result = self.run_checker()

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_forbidden_static_api_anchor_fails(self) -> None:
        self.ledger_data["tests"]["test_typed"]["static_absent"] = [
            "pub fn Pattern::new("
        ]
        self.public_api.write_text(
            self.public_api.read_text(encoding="utf-8")
            + "pub fn Pattern::new() -> Pattern\n",
            encoding="utf-8",
        )
        self.write_ledger()

        result = self.run_checker()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("forbidden public API anchor", result.stderr)


if __name__ == "__main__":
    unittest.main()
