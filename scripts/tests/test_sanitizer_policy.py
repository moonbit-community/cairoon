from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


SANITIZER_DIR = Path(__file__).resolve().parents[1] / "sanitizers"
sys.path.insert(0, str(SANITIZER_DIR))

from policy import asan_options, leak_detection_enabled, policy_description
from run import (
    CLEANUP_SOURCE,
    RECORDING_SNAPSHOT_PACKAGES,
    RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION,
    RECORDING_SNAPSHOT_SUPPRESSION,
    classify_recording_snapshot_probe,
    create_compiler_wrapper,
    create_shadow_toolchain,
    discover_packages,
    lsan_options,
    moon_test_command,
    normalize_package,
    validate_suppression_usage,
)


class SanitizerPolicyTests(unittest.TestCase):
    def test_auto_enables_lsan_only_on_linux(self) -> None:
        self.assertTrue(leak_detection_enabled("auto", "Linux"))
        self.assertFalse(leak_detection_enabled("auto", "Darwin"))

    def test_explicit_mode_overrides_platform_default(self) -> None:
        self.assertTrue(leak_detection_enabled("on", "Darwin"))
        self.assertFalse(leak_detection_enabled("off", "Linux"))

    def test_asan_options_encode_leak_policy(self) -> None:
        self.assertIn("detect_leaks=1", asan_options(True))
        self.assertIn("detect_leaks=0", asan_options(False))
        self.assertIn("halt_on_error=1", asan_options(True))

    def test_macos_policy_names_linux_as_authoritative(self) -> None:
        description = policy_description("Darwin", False)
        self.assertIn("Linux matrix", description)

    def test_cleanup_releases_cairo_before_fontconfig(self) -> None:
        cairo_reset = CLEANUP_SOURCE.index("cairo_debug_reset_static_data();")
        fontconfig_reset = CLEANUP_SOURCE.index("FcFini();")
        self.assertLess(cairo_reset, fontconfig_reset)
        self.assertIn("atexit(cairoon_sanitizer_cleanup)", CLEANUP_SOURCE)

    def test_cleanup_object_is_added_only_when_linking(self) -> None:
        with tempfile.TemporaryDirectory() as raw_dir:
            directory = Path(raw_dir)
            cleanup = directory / "sanitizer-cleanup.o"
            wrapper = create_compiler_wrapper(directory, "/usr/bin/clang", cleanup)
            script = wrapper.read_text(encoding="ascii")

        self.assertIn('-c|-E|-S|-M|-MM) exec', script)
        self.assertEqual(script.count(str(cleanup)), 1)
        self.assertTrue(script.rstrip().endswith(str(cleanup)))

    def test_focused_test_command_preserves_release_flags(self) -> None:
        command = moon_test_command(
            "/moon/bin/moon",
            "src/tests/oracle/vector_backend",
            "*grouped glyph*",
            True,
        )
        self.assertEqual(
            command,
            [
                "/moon/bin/moon",
                "test",
                "src/tests/oracle/vector_backend",
                "--target",
                "native",
                "--deny-warn",
                "--filter",
                "*grouped glyph*",
                "-v",
            ],
        )

    def test_lsan_suppression_is_narrow_and_reports_usage(self) -> None:
        options = lsan_options(RECORDING_SNAPSHOT_SUPPRESSION)
        self.assertIn("exitcode=86", options)
        self.assertIn(
            f"suppressions={RECORDING_SNAPSHOT_SUPPRESSION}",
            options,
        )
        self.assertIn("print_suppressions=1", options)
        self.assertEqual(
            RECORDING_SNAPSHOT_PACKAGES,
            frozenset({"src/tests/oracle/vector_backend"}),
        )
        expected = {
            RECORDING_SNAPSHOT_SUPPRESSION: [
                "leak:_cairo_recording_surface_snapshot"
            ],
            RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION: ["leak:cairo_restore"],
        }
        for path, expected_lines in expected.items():
            suppression_lines = [
                line.strip()
                for line in path.read_text(encoding="ascii").splitlines()
                if line.strip() and not line.startswith("#")
            ]
            self.assertEqual(suppression_lines, expected_lines)

    def test_clean_recording_snapshot_probe_needs_no_suppression(self) -> None:
        self.assertIsNone(classify_recording_snapshot_probe(0, ""))

    def test_known_recording_snapshot_probe_signature_is_accepted(self) -> None:
        stack = (
            "Direct leak of 584 byte(s) in 1 object(s) allocated from:\n"
            "    #1 0x0 in _cairo_recording_surface_snapshot source.c\n"
        )
        output = (
            "ERROR: LeakSanitizer: detected memory leaks\n"
            + stack
            + stack
            + "SUMMARY: AddressSanitizer: 1168 byte(s) leaked in "
            "2 allocation(s).\n"
        )
        leak = classify_recording_snapshot_probe(86, output)
        self.assertIsNotNone(leak)
        assert leak is not None
        self.assertEqual(leak.allocation_size, 584)
        self.assertEqual(
            leak.suppression_template,
            "_cairo_recording_surface_snapshot",
        )

    def test_stripped_recording_snapshot_probe_signature_is_accepted(self) -> None:
        stack = (
            "Direct leak of 584 byte(s) in 1 object(s) allocated from:\n"
            "    #1 0x1 (/lib/libcairo.so.2+0x1)\n"
            "    #2 0x2 in cairo_surface_destroy (/lib/libcairo.so.2+0x2)\n"
            "    #3 0x3 in cairo_pattern_destroy (/lib/libcairo.so.2+0x3)\n"
            "    #4 0x4 in cairo_restore (/lib/libcairo.so.2+0x4)\n"
            "    #5 0x5 in render_document probe.c:70:3\n"
        )
        output = (
            "ERROR: LeakSanitizer: detected memory leaks\n"
            + stack
            + stack
            + "SUMMARY: AddressSanitizer: 1168 byte(s) leaked in "
            "2 allocation(s).\n"
        )
        leak = classify_recording_snapshot_probe(86, output)
        self.assertIsNotNone(leak)
        assert leak is not None
        self.assertEqual(leak.suppression_template, "cairo_restore")
        self.assertEqual(
            leak.suppression_path,
            RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION,
        )

    def test_unknown_recording_snapshot_probe_signature_is_rejected(self) -> None:
        output = (
            "ERROR: LeakSanitizer: detected memory leaks\n"
            "Direct leak of 64 byte(s) in 1 object(s) allocated from:\n"
            "SUMMARY: AddressSanitizer: 64 byte(s) leaked in 1 allocation(s).\n"
        )
        with self.assertRaisesRegex(RuntimeError, "unknown sanitizer signature"):
            classify_recording_snapshot_probe(86, output)

    def test_package_discovery_keeps_sanitizer_processes_isolated(self) -> None:
        packages = discover_packages()
        self.assertIn("src", packages)
        self.assertIn("src/tests/oracle/vector_backend", packages)
        self.assertEqual(packages, sorted(packages))

    def test_package_normalization_accepts_cli_relative_paths(self) -> None:
        self.assertEqual(
            normalize_package("./src/tests/oracle/vector_backend/"),
            "src/tests/oracle/vector_backend",
        )

    def test_shadow_toolchain_replaces_only_its_allocator(self) -> None:
        with tempfile.TemporaryDirectory() as raw_dir:
            directory = Path(raw_dir)
            source = directory / "source"
            (source / "bin").mkdir(parents=True)
            (source / "lib" / "core").mkdir(parents=True)
            original = source / "lib" / "libmoonbitrun.o"
            original.write_bytes(b"original")
            (source / "lib" / "runmain.o").write_bytes(b"runmain")
            replacement = directory / "replacement.o"
            replacement.write_bytes(b"replacement")

            shadow = create_shadow_toolchain(source, directory, replacement)

            self.assertEqual(original.read_bytes(), b"original")
            self.assertEqual(
                (shadow / "lib" / "libmoonbitrun.o").read_bytes(),
                b"replacement",
            )
            self.assertTrue((shadow / "bin").is_symlink())
            self.assertTrue((shadow / "lib" / "runmain.o").is_symlink())

    def test_suppression_usage_requires_exact_count_and_bytes(self) -> None:
        probe_output = (
            "ERROR: LeakSanitizer: detected memory leaks\n"
            + (
                "Direct leak of 584 byte(s) in 1 object(s) allocated from:\n"
                "    #1 0x0 in _cairo_recording_surface_snapshot source.c\n"
            )
            * 2
            + "SUMMARY: AddressSanitizer: 1168 byte(s) leaked in "
            "2 allocation(s).\n"
        )
        leak = classify_recording_snapshot_probe(86, probe_output)
        assert leak is not None
        output = (
            "-----------------------------------------------------\n"
            "Suppressions used:\n"
            "  count      bytes template\n"
            "     16       9344 _cairo_recording_surface_snapshot\n"
            "-----------------------------------------------------\n"
        )
        validate_suppression_usage(output, leak)

        with self.assertRaisesRegex(RuntimeError, "unexpected leak suppression"):
            validate_suppression_usage(output.replace("16", "17"), leak)


if __name__ == "__main__":
    unittest.main()
