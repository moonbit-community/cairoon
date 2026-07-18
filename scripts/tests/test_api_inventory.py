#!/usr/bin/env python3
"""Regression tests for the self-contained pycairo API snapshot."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest


REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
MODULE_PATH = REPO_ROOT / "scripts" / "api" / "snapshot.py"
SNAPSHOT_PATH = REPO_ROOT / "scripts" / "api" / "pycairo-api-snapshot.json"
PYCAIRO_STUB = REPO_ROOT.parent / "cairo" / "__init__.pyi"
CHECKER_PATH = REPO_ROOT / "scripts" / "check-api-inventory.py"
INVENTORY_PATH = REPO_ROOT / "API_INVENTORY.md"
PUBLIC_API_PATH = REPO_ROOT / "src" / "pkg.generated.mbti"
GLYPH_API_PATH = REPO_ROOT / "src" / "core" / "glyph" / "pkg.generated.mbti"
UPSTREAM_COMMIT = "80ea3348aff95e8441e6c3e2086371ea40528d81"


def load_module():
    spec = importlib.util.spec_from_file_location("cairoon_api_snapshot", MODULE_PATH)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ApiInventorySnapshotTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.snapshot = load_module()

    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.temp_root = pathlib.Path(self.temp_dir.name)
        self.fixture = self.temp_root / "snapshot.json"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_payload(self, payload: dict[str, object]) -> pathlib.Path:
        self.fixture.write_text(
            json.dumps(payload, indent=2) + "\n",
            encoding="utf-8",
        )
        return self.fixture

    def committed_payload(self) -> dict[str, object]:
        return json.loads(SNAPSHOT_PATH.read_text(encoding="utf-8"))

    def write_synthetic_stub(self) -> pathlib.Path:
        payload = self.committed_payload()
        top_level = payload["top_level"]
        methods = payload["methods"]
        protocols = payload["protocols"]
        attributes = payload["attributes"]
        constants = payload["constants"]
        enum_aliases = payload["enum_aliases"]
        assert isinstance(top_level, list)
        assert isinstance(methods, dict)
        assert isinstance(protocols, dict)
        assert isinstance(attributes, dict)
        assert isinstance(constants, list)
        assert isinstance(enum_aliases, list)

        lines: list[str] = []
        for name in top_level:
            assert isinstance(name, str)
            class_methods = methods.get(name, [])
            class_protocols = protocols.get(name, [])
            class_attributes = attributes.get(name, [])
            if not class_methods and not class_protocols and not class_attributes:
                lines.extend((f"def {name}(): ...", ""))
                continue
            assert isinstance(class_methods, list)
            assert isinstance(class_protocols, list)
            assert isinstance(class_attributes, list)
            lines.append(f"class {name}:")
            lines.extend(f"    {attribute}: int = ..." for attribute in class_attributes)
            lines.extend(f"    def {method}(self): ..." for method in class_methods)
            lines.extend(f"    def {protocol}(self): ..." for protocol in class_protocols)
            lines.append("")

        alias_owner = top_level[0]
        alias_names = set(enum_aliases)
        for name in constants:
            assert isinstance(name, str)
            if name in alias_names:
                lines.append(f"{name} = {alias_owner}.value")
            else:
                lines.append(f"{name}: int")

        stub = self.temp_root / "synthetic.pyi"
        stub.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return stub

    def test_parser_captures_protocols_and_class_attributes(self) -> None:
        stub = self.temp_root / "members.pyi"
        stub.write_text(
            "class Widget:\n"
            "    KIND: int = ...\n"
            "    def __init__(self): ...\n"
            "    def __iter__(self): ...\n"
            "    def run(self): ...\n",
            encoding="utf-8",
        )

        (
            top_level,
            methods,
            protocols,
            attributes,
            constants,
            enum_aliases,
        ) = self.snapshot.parse_pycairo_api(stub)

        self.assertEqual(top_level, {"Widget"})
        self.assertEqual(methods, {"Widget": {"run"}})
        self.assertEqual(protocols, {"Widget": {"__init__", "__iter__"}})
        self.assertEqual(attributes, {"Widget": {"KIND"}})
        self.assertEqual(constants, set())
        self.assertEqual(enum_aliases, set())

    def test_source_mode_matches_snapshot(self) -> None:
        stub = PYCAIRO_STUB
        snapshot = SNAPSHOT_PATH
        if not stub.is_file():
            stub = self.write_synthetic_stub()
            snapshot = self.temp_root / "synthetic-snapshot.json"
            self.snapshot.write_api_snapshot(stub, snapshot, UPSTREAM_COMMIT)
        shape = self.snapshot.load_pycairo_api(stub, snapshot)

        self.assertEqual(
            self.snapshot.shape_counts(shape),
            self.snapshot.EXPECTED_SNAPSHOT_COUNTS,
        )

    def test_missing_source_uses_complete_snapshot(self) -> None:
        shape = self.snapshot.load_pycairo_api(
            self.temp_root / "missing.pyi",
            SNAPSHOT_PATH,
        )

        self.assertEqual(
            self.snapshot.shape_counts(shape),
            {
                "top_level": 67,
                "methods": 259,
                "protocols": 39,
                "attributes": 206,
                "constants": 224,
                "enum_aliases": 178,
            },
        )

    def test_source_digest_drift_fails(self) -> None:
        drifted = self.temp_root / "drifted.pyi"
        drifted.write_text("# deliberately not the pinned source\n", encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "SHA-256 drift"):
            self.snapshot.load_pycairo_api(drifted, SNAPSHOT_PATH)

    def test_duplicate_entries_fail(self) -> None:
        payload = self.committed_payload()
        top_level = payload["top_level"]
        assert isinstance(top_level, list)
        top_level.append(top_level[0])

        with self.assertRaisesRegex(ValueError, "duplicate entries"):
            self.snapshot.load_api_snapshot(self.write_payload(payload))

    def test_truncated_snapshot_fails_count_contract(self) -> None:
        payload = self.committed_payload()
        constants = payload["constants"]
        assert isinstance(constants, list)
        constants.pop()

        with self.assertRaisesRegex(ValueError, "snapshot counts"):
            self.snapshot.load_api_snapshot(self.write_payload(payload))

    def test_unsorted_method_list_fails(self) -> None:
        payload = self.committed_payload()
        methods = payload["methods"]
        assert isinstance(methods, dict)
        context_methods = methods["Context"]
        assert isinstance(context_methods, list)
        context_methods[0], context_methods[1] = context_methods[1], context_methods[0]

        with self.assertRaisesRegex(ValueError, "must be sorted"):
            self.snapshot.load_api_snapshot(self.write_payload(payload))

    def test_snapshot_generator_round_trips(self) -> None:
        stub = self.write_synthetic_stub()
        generated = self.temp_root / "generated.json"

        written_shape = self.snapshot.write_api_snapshot(
            stub,
            generated,
            UPSTREAM_COMMIT,
        )
        loaded_shape, _ = self.snapshot.load_api_snapshot(generated)
        source_shape = self.snapshot.load_pycairo_api(stub, generated)

        self.assertEqual(written_shape, loaded_shape)
        self.assertEqual(written_shape, source_shape)

        generated_payload = json.loads(generated.read_text(encoding="utf-8"))
        committed_payload = self.committed_payload()
        generated_upstream = generated_payload["upstream"]
        committed_upstream = committed_payload["upstream"]
        assert isinstance(generated_upstream, dict)
        assert isinstance(committed_upstream, dict)
        self.assertEqual(
            generated_upstream["sha256"], hashlib.sha256(stub.read_bytes()).hexdigest()
        )
        generated_upstream["sha256"] = committed_upstream["sha256"]
        self.assertEqual(generated_payload, committed_payload)

    def test_checker_requires_context_constructor_evidence(self) -> None:
        public_api = self.temp_root / "pkg.generated.mbti"
        public_api.write_text(
            PUBLIC_API_PATH.read_text(encoding="utf-8").replace(
                "pub fn Context::new(",
                "pub fn Context::missing(",
                1,
            ),
            encoding="utf-8",
        )

        result = subprocess.run(
            [
                sys.executable,
                str(CHECKER_PATH),
                "--stub",
                str(PYCAIRO_STUB),
                "--snapshot",
                str(SNAPSHOT_PATH),
                "--inventory",
                str(INVENTORY_PATH),
                "--public-api",
                str(public_api),
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("pycairo protocol 'Context.__init__'", result.stderr)

    def test_checker_covers_every_pycairo_protocol(self) -> None:
        result = subprocess.run(
            [sys.executable, str(CHECKER_PATH)],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("4 method Decisions", result.stdout)
        self.assertIn("39 class protocols", result.stdout)

    def test_checker_covers_every_pycairo_class_attribute(self) -> None:
        result = subprocess.run(
            [sys.executable, str(CHECKER_PATH)],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("206 class attributes", result.stdout)

    def test_checker_requires_matrix_field_evidence(self) -> None:
        public_api = self.temp_root / "pkg.generated.mbti"
        public_api.write_text(
            PUBLIC_API_PATH.read_text(encoding="utf-8").replace(
                "  xx : Double\n",
                "  missing_xx : Double\n",
                1,
            ),
            encoding="utf-8",
        )

        result = subprocess.run(
            [
                sys.executable,
                str(CHECKER_PATH),
                "--stub",
                str(PYCAIRO_STUB),
                "--snapshot",
                str(SNAPSHOT_PATH),
                "--inventory",
                str(INVENTORY_PATH),
                "--public-api",
                str(public_api),
                "--public-api",
                str(GLYPH_API_PATH),
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("pycairo class attribute 'Matrix.xx'", result.stderr)

    def test_checker_requires_xlib_method_decision(self) -> None:
        inventory = self.temp_root / "API_INVENTORY.md"
        inventory.write_text(
            INVENTORY_PATH.read_text(encoding="utf-8").replace(
                "requires a future conditional extension layer with X11/XCB headers",
                "requires an unspecified extension layer",
                1,
            ),
            encoding="utf-8",
        )

        result = subprocess.run(
            [
                sys.executable,
                str(CHECKER_PATH),
                "--inventory",
                str(inventory),
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("pycairo method 'XlibSurface.get_width'", result.stderr)


if __name__ == "__main__":
    unittest.main()
