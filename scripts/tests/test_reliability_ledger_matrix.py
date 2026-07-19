#!/usr/bin/env python3
"""Tests for exact local-matrix reliability gate wiring."""

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


class LocalMatrixGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.matrix = self.root / "scripts" / "test-cairo-matrix.sh"
        self.lane = self.root / "scripts" / "matrix" / "run-lane.sh"
        self.sanitizer = self.root / "scripts" / "sanitizers" / "run.py"
        self.sanitizer_toolchain = self.sanitizer.with_name("toolchain.py")
        self.sanitizer_leak_probes = self.sanitizer.with_name("leak_probes.py")
        self.lane.parent.mkdir(parents=True)
        self.sanitizer.parent.mkdir(parents=True)
        self.matrix.write_text(
            "cairo-1.15.10\n"
            "cairo-1.18.4\n"
            "CAIROON_SANITIZER_LEAKS=on\n"
            "moon package --list\n"
            "dst=/artifact/cairoon.zip,readonly\n",
            encoding="utf-8",
        )
        self.sanitizer.write_text(
            "\n".join(
                [
                    "from leak_probes import (",
                    "from toolchain import (",
                    "discover_packages",
                    "MOON_TOOLCHAIN_ROOT",
                ]
            ) + "\n",
            encoding="utf-8",
        )
        self.sanitizer_toolchain.write_text(
            "\n".join(
                [
                    "compiler_preflight",
                    "-fsanitize=address,undefined",
                    "UBSAN_OPTIONS",
                    "validate_ubsan_probe",
                ]
            ) + "\n",
            encoding="utf-8",
        )
        self.sanitizer_leak_probes.write_text(
            "\n".join(
                [
                    "probe_recording_snapshot_leak",
                    "RECORDING_SNAPSHOT_PACKAGES",
                    "probe_pdf_jbig2_missing_leak",
                    "PDF_JBIG2_MISSING_PACKAGES",
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
        errors = self.check(
            "./scripts/check-downstream-consumer.sh --archive /artifact/cairoon.zip\n"
            "./scripts/verify.sh\n"
        )
        self.assertTrue(any("--analyze" in error for error in errors))

    def test_matrix_lane_accepts_active_instrumented_public_coverage(self) -> None:
        errors = self.check(
            "./scripts/check-downstream-consumer.sh --archive /artifact/cairoon.zip\n"
            "python3 ./scripts/check-public-coverage.py --analyze\n"
            "./scripts/verify.sh\n"
        )
        self.assertEqual(errors, [])

    def test_matrix_lane_rejects_commented_instrumented_coverage(self) -> None:
        errors = self.check(
            "./scripts/check-downstream-consumer.sh --archive /artifact/cairoon.zip\n"
            ": # python3 ./scripts/check-public-coverage.py --analyze\n"
            "./scripts/verify.sh\n"
        )
        self.assertTrue(any("--analyze" in error for error in errors))

    def test_matrix_lane_requires_undefined_behavior_preflight(self) -> None:
        self.sanitizer_toolchain.write_text(
            self.sanitizer_toolchain.read_text(encoding="utf-8").replace(
                "validate_ubsan_probe\n",
                "",
            ),
            encoding="utf-8",
        )
        errors = self.check(
            "./scripts/check-downstream-consumer.sh --archive /artifact/cairoon.zip\n"
            "python3 ./scripts/check-public-coverage.py --analyze\n"
            "./scripts/verify.sh\n"
        )
        self.assertTrue(any("validate_ubsan_probe" in error for error in errors))

    def test_matrix_lane_requires_unmodified_archive_consumer(self) -> None:
        errors = self.check(
            "python3 ./scripts/check-public-coverage.py --analyze\n"
            "./scripts/verify.sh\n"
        )
        self.assertTrue(any("--archive" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
