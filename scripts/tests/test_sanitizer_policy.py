from __future__ import annotations

import re
import sys
import tempfile
import unittest
from pathlib import Path


SANITIZER_DIR = Path(__file__).resolve().parents[1] / "sanitizers"
REPO_ROOT = SANITIZER_DIR.parents[1]
sys.path.insert(0, str(SANITIZER_DIR))

import policy as sanitizer_policy
import run as sanitizer_run
from policy import asan_options, leak_detection_enabled, policy_description
from run import (
    CLEANUP_SOURCE,
    PDF_JBIG2_MISSING_PACKAGES,
    PDF_JBIG2_MISSING_SUPPRESSION,
    RECORDING_SNAPSHOT_PACKAGES,
    RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION,
    RECORDING_SNAPSHOT_SUPPRESSION,
    classify_pdf_jbig2_missing_probe,
    classify_recording_snapshot_probe,
    create_compiler_wrapper,
    create_shadow_toolchain,
    discover_packages,
    lsan_options,
    moon_test_command,
    normalize_package,
    validate_pdf_jbig2_suppression_usage,
    validate_suppression_usage,
)


class SanitizerPolicyTests(unittest.TestCase):
    def test_compile_flags_enable_address_and_undefined_sanitizers(self) -> None:
        self.assertIn(
            "-fsanitize=address,undefined",
            sanitizer_run.COMPILE_FLAGS,
        )
        self.assertNotIn("-fno-sanitize=function", sanitizer_run.COMPILE_FLAGS)
        runner_source = Path(sanitizer_run.__file__).read_text(encoding="utf-8")
        self.assertNotIn("-fno-sanitize=function", runner_source)
        for package in REPO_ROOT.rglob("moon.pkg"):
            self.assertNotIn(
                "-fno-sanitize=function",
                package.read_text(encoding="utf-8"),
                package,
            )

    def test_moonbit_funcref_function_check_exemption_is_narrow(self) -> None:
        header = (REPO_ROOT / "src/native/cairoon_private.h").read_text(
            encoding="utf-8"
        )
        self.assertIn('no_sanitize("function"), noinline', header)

        native_dir = REPO_ROOT / "src/native"
        native_sources = list(native_dir.glob("*.c"))
        helper_pattern = re.compile(
            r"static\s+CAIROON_MOONBIT_FUNCREF_DISPATCH\s+"
            r"[A-Za-z_][A-Za-z0-9_]*\s*\*?\s*"
            r"(cairoon_[A-Za-z0-9_]+)\s*\(",
            re.MULTILINE,
        )
        annotated_helpers = {
            source.name: set(helper_pattern.findall(source.read_text(encoding="utf-8")))
            for source in native_sources
        }
        self.assertEqual(
            {name: helpers for name, helpers in annotated_helpers.items() if helpers},
            {
                "cairoon_raster_source_callbacks.c": {
                    "cairoon_raster_source_call_acquire",
                    "cairoon_raster_source_call_release",
                },
                "cairoon_stream.c": {
                    "cairoon_stream_call_read",
                    "cairoon_stream_call_write",
                },
            },
        )
        c_family_sources = [
            source
            for root in (REPO_ROOT / "src", REPO_ROOT / "scripts")
            for source in root.rglob("*")
            if source.suffix in {".c", ".h"}
        ]
        macro_uses = {
            source.relative_to(REPO_ROOT).as_posix(): source.read_text(
                encoding="utf-8"
            ).count("CAIROON_MOONBIT_FUNCREF_DISPATCH")
            for source in c_family_sources
        }
        self.assertEqual(
            {name: count for name, count in macro_uses.items() if count},
            {
                "src/native/cairoon_private.h": 2,
                "src/native/cairoon_raster_source_callbacks.c": 2,
                "src/native/cairoon_stream.c": 2,
            },
        )

        raw_attribute_uses = {
            source.relative_to(REPO_ROOT).as_posix(): source.read_text(
                encoding="utf-8"
            ).count(
                'no_sanitize("function")'
            )
            for source in c_family_sources
        }
        self.assertEqual(
            {name: count for name, count in raw_attribute_uses.items() if count},
            {"src/native/cairoon_private.h": 1},
        )

    def test_ubsan_options_stop_on_first_error_with_stacktrace(self) -> None:
        options = sanitizer_policy.ubsan_options()
        self.assertIn("halt_on_error=1", options)
        self.assertIn("print_stacktrace=1", options)

    def test_ubsan_preflight_requires_signed_overflow_detection(self) -> None:
        sanitizer_run.validate_ubsan_probe(
            1,
            "probe.c:8:16: runtime error: signed integer overflow: "
            "2147483647 + 1 cannot be represented in type 'int'\n",
        )
        for returncode, output in ((0, ""), (1, "unrelated failure")):
            with self.subTest(returncode=returncode, output=output):
                with self.assertRaisesRegex(RuntimeError, "UndefinedBehaviorSanitizer"):
                    sanitizer_run.validate_ubsan_probe(returncode, output)

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

    def test_clean_pdf_jbig2_probe_needs_status_sentinel(self) -> None:
        sentinel = "CAIROON_PDF_JBIG2_STATUS=JBIG2_GLOBAL_MISSING\n"
        self.assertIsNone(classify_pdf_jbig2_missing_probe(0, sentinel))
        with self.assertRaisesRegex(RuntimeError, "status sentinel"):
            classify_pdf_jbig2_missing_probe(0, "")

    def test_pdf_jbig2_suppression_is_narrow(self) -> None:
        self.assertEqual(
            PDF_JBIG2_MISSING_PACKAGES,
            frozenset({"src/tests/backend/pdf"}),
        )
        suppression_lines = [
            line.strip()
            for line in PDF_JBIG2_MISSING_SUPPRESSION.read_text(
                encoding="ascii"
            ).splitlines()
            if line.strip() and not line.startswith("#")
        ]
        self.assertEqual(
            suppression_lines,
            [
                "leak:_cairo_pdf_interchange_init",
                "leak:_cairo_paginated_surface_finish",
            ],
        )

    def test_known_pdf_jbig2_probe_signatures_are_accepted(self) -> None:
        profiles = (
            (
                [304, 128, 20, 8, 344, 144],
                [24, 8, 8],
                988,
                9,
            ),
            (
                [304, 304, 304, 144, 20, 8, 344, 344, 344, 168],
                [32, 24, 8, 4],
                2352,
                14,
            ),
        )
        for interchange, paginated, total_bytes, total_count in profiles:
            with self.subTest(total_bytes=total_bytes):
                blocks = "".join(
                    f"Direct leak of {size} byte(s) in 1 object(s) allocated from:\n"
                    "    #1 0x0 in _cairo_pdf_interchange_init source.c\n"
                    for size in interchange
                )
                blocks += "".join(
                    f"Direct leak of {size} byte(s) in 1 object(s) allocated from:\n"
                    "    #1 0x0 in _cairo_paginated_surface_finish source.c\n"
                    for size in paginated
                )
                output = (
                    "CAIROON_PDF_JBIG2_STATUS=JBIG2_GLOBAL_MISSING\n"
                    "ERROR: LeakSanitizer: detected memory leaks\n"
                    + blocks
                    + f"SUMMARY: AddressSanitizer: {total_bytes} byte(s) leaked in "
                    f"{total_count} allocation(s).\n"
                )
                leak = classify_pdf_jbig2_missing_probe(86, output)
                self.assertIsNotNone(leak)
                assert leak is not None
                self.assertEqual(leak.total_bytes, total_bytes)
                self.assertEqual(leak.total_allocations, total_count)

    def test_unknown_pdf_jbig2_probe_signature_is_rejected(self) -> None:
        output = (
            "CAIROON_PDF_JBIG2_STATUS=JBIG2_GLOBAL_MISSING\n"
            "ERROR: LeakSanitizer: detected memory leaks\n"
            "Direct leak of 64 byte(s) in 1 object(s) allocated from:\n"
            "    #1 0x0 in _cairo_pdf_interchange_init source.c\n"
            "SUMMARY: AddressSanitizer: 64 byte(s) leaked in 1 allocation(s).\n"
        )
        with self.assertRaisesRegex(RuntimeError, "unknown sanitizer signature"):
            classify_pdf_jbig2_missing_probe(86, output)

    def test_pdf_jbig2_leak_without_status_sentinel_is_rejected(self) -> None:
        output = (
            "ERROR: LeakSanitizer: detected memory leaks\n"
            "Direct leak of 304 byte(s) in 1 object(s) allocated from:\n"
            "    #1 0x0 in _cairo_pdf_interchange_init source.c\n"
            "SUMMARY: AddressSanitizer: 304 byte(s) leaked in 1 allocation(s).\n"
        )
        with self.assertRaisesRegex(RuntimeError, "status sentinel"):
            classify_pdf_jbig2_missing_probe(86, output)

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

    def test_pdf_jbig2_suppression_usage_matches_probe(self) -> None:
        blocks = "".join(
            f"Direct leak of {size} byte(s) in 1 object(s) allocated from:\n"
            "    #1 0x0 in _cairo_pdf_interchange_init source.c\n"
            for size in [304, 128, 20, 8, 344, 144]
        )
        blocks += "".join(
            f"Direct leak of {size} byte(s) in 1 object(s) allocated from:\n"
            "    #1 0x0 in _cairo_paginated_surface_finish source.c\n"
            for size in [24, 8, 8]
        )
        probe_output = (
            "CAIROON_PDF_JBIG2_STATUS=JBIG2_GLOBAL_MISSING\n"
            "ERROR: LeakSanitizer: detected memory leaks\n"
            + blocks
            + "SUMMARY: AddressSanitizer: 988 byte(s) leaked in "
            "9 allocation(s).\n"
        )
        leak = classify_pdf_jbig2_missing_probe(86, probe_output)
        assert leak is not None
        output = (
            "-----------------------------------------------------\n"
            "Suppressions used:\n"
            "  count      bytes template\n"
            "      6        948 _cairo_pdf_interchange_init\n"
            "      3         40 _cairo_paginated_surface_finish\n"
            "-----------------------------------------------------\n"
        )
        validate_pdf_jbig2_suppression_usage(output, leak)
        with self.assertRaisesRegex(RuntimeError, "unexpected leak suppression"):
            validate_pdf_jbig2_suppression_usage(output.replace("948", "949"), leak)


if __name__ == "__main__":
    unittest.main()
