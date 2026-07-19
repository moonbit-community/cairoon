#!/usr/bin/env python3
"""Tests for executable reference-document layout rules."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-project-layout.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_project_layout", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ReferenceDocumentationLayoutTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.docs = self.root / "src" / "docs"
        self.docs.mkdir(parents=True)
        (self.docs / "moon.pkg").write_text("", encoding="utf-8")
        (self.docs / "prelude.mbt").write_text("", encoding="utf-8")
        self.root_readme = self.root / "README.md"
        self.public_readme = self.root / "src" / "README.mbt.md"
        self.required = frozenset({"one.mbt.md", "two.mbt.md"})
        for name in self.required:
            self.write_doc(name)
        self.write_indexes(self.required)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_doc(self, name: str, text: str | None = None) -> None:
        if text is None:
            text = '# Reference\n\n```mbt check\n///|\ntest "docs" {}\n```\n'
        (self.docs / name).write_text(text, encoding="utf-8")

    def index_text(self, names: set[str] | frozenset[str]) -> str:
        entries = "\n".join(f"- `src/docs/{name}`" for name in sorted(names))
        return f"# Project\n\n## Documentation\n\n{entries}\n\n## Testing\n"

    def write_indexes(
        self,
        root_names: set[str] | frozenset[str],
        public_names: set[str] | frozenset[str] | None = None,
    ) -> None:
        if public_names is None:
            public_names = root_names
        self.root_readme.write_text(self.index_text(root_names), encoding="utf-8")
        self.public_readme.write_text(
            self.index_text(public_names), encoding="utf-8"
        )

    def check(self) -> list[str]:
        with mock.patch.multiple(
            self.checker,
            DOC_PACKAGE_DIR=self.docs,
            ROOT_README=self.root_readme,
            PUBLIC_README=self.public_readme,
            REQUIRED_REFERENCE_DOCS=self.required,
        ):
            return self.checker.check_reference_docs()

    def test_complete_executable_document_set_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_missing_required_document_fails(self) -> None:
        (self.docs / "two.mbt.md").unlink()

        errors = self.check()

        self.assertTrue(any("missing required" in error for error in errors), errors)

    def test_document_without_executable_block_fails(self) -> None:
        self.write_doc("one.mbt.md", "# Reference\n\nNarrative only.\n")

        errors = self.check()

        self.assertTrue(any("executable mbt check" in error for error in errors), errors)

    def test_document_with_unclosed_executable_block_fails(self) -> None:
        self.write_doc(
            "one.mbt.md",
            '# Reference\n\n```mbt check\n///|\ntest "docs" {}\n',
        )

        errors = self.check()

        self.assertTrue(any("executable mbt check" in error for error in errors), errors)

    def test_document_without_level_one_title_fails(self) -> None:
        self.write_doc(
            "one.mbt.md",
            'Narrative.\n\n```mbt check\n///|\ntest "docs" {}\n```\n',
        )

        errors = self.check()

        self.assertTrue(any("level-one title" in error for error in errors), errors)

    def test_root_readme_unindexed_document_fails(self) -> None:
        self.write_indexes(frozenset({"one.mbt.md"}), self.required)

        errors = self.check()

        self.assertTrue(
            any(
                str(self.root_readme) in error and "two.mbt.md" in error
                for error in errors
            ),
            errors,
        )

    def test_public_readme_unindexed_document_fails(self) -> None:
        self.write_indexes(self.required, frozenset({"one.mbt.md"}))

        errors = self.check()

        self.assertTrue(
            any(
                str(self.public_readme) in error and "two.mbt.md" in error
                for error in errors
            ),
            errors,
        )

    def test_index_entry_outside_documentation_section_fails(self) -> None:
        root_text = self.index_text(frozenset({"one.mbt.md"}))
        root_text += "\n## History\n\nPreviously `src/docs/two.mbt.md`.\n"
        self.root_readme.write_text(root_text, encoding="utf-8")

        errors = self.check()

        self.assertTrue(
            any(
                str(self.root_readme) in error and "two.mbt.md" in error
                for error in errors
            ),
            errors,
        )


class SourceRootMetadataTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.source = self.root / "src"
        self.source.mkdir()
        (self.source / "moon.pkg").write_text("", encoding="utf-8")
        (self.source / "pkg.generated.mbti").write_text("", encoding="utf-8")
        self.moon_mod = self.root / "moon.mod"
        self.write_module()

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_module(
        self,
        *,
        preferred_target: bool = True,
        supported_targets: bool = True,
    ) -> None:
        lines = [
            'name = "CAIMEOX/cairoon"',
            'readme = "src/README.mbt.md"',
            'source = "src"',
        ]
        if preferred_target:
            lines.append('preferred_target = "native"')
        if supported_targets:
            lines.append('supported_targets = "native"')
        lines.append('options(exclude: [ "integration" ])')
        self.moon_mod.write_text("\n".join(lines) + "\n", encoding="utf-8")

    def check(self) -> list[str]:
        with mock.patch.multiple(
            self.checker,
            REPO_ROOT=self.root,
            PACKAGE_ROOT=self.source,
            MOON_MOD=self.moon_mod,
        ):
            return self.checker.check_source_root()

    def test_native_only_module_metadata_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_missing_preferred_native_target_fails(self) -> None:
        self.write_module(preferred_target=False)

        errors = self.check()

        self.assertTrue(any("preferred_target" in error for error in errors), errors)

    def test_missing_supported_native_target_fails(self) -> None:
        self.write_module(supported_targets=False)

        errors = self.check()

        self.assertTrue(any("supported_targets" in error for error in errors), errors)


class NativeBuildConfigurationLayoutTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.source = self.root / "src"
        self.native = self.source / "native"
        self.consumer = self.root / "integration" / "consumer" / "src" / "smoke"
        self.build_script = self.root / "scripts" / "build" / "cairo_config.py"
        self.native.mkdir(parents=True)
        self.consumer.mkdir(parents=True)
        self.build_script.parent.mkdir(parents=True)
        self.build_script.write_text("# build protocol\n", encoding="utf-8")
        self.moon_mod = self.root / "moon.mod"
        self.moon_mod.write_text(
            'name = "CAIMEOX/cairoon"\n'
            'options("--moonbit-unstable-prebuild": '
            '"scripts/build/cairo_config.py")\n',
            encoding="utf-8",
        )
        self.write_stub_package(self.native)
        (self.source / "plain").mkdir()
        (self.source / "plain" / "moon.pkg").write_text("", encoding="utf-8")
        (self.consumer / "moon.pkg").write_text(
            'import { "CAIMEOX/cairoon" } for "test"\n',
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_stub_package(self, package: pathlib.Path, flags: str | None = None) -> None:
        package.mkdir(parents=True, exist_ok=True)
        if flags is None:
            flags = (
                "${build.CAIRO_CFLAGS} "
                "-std=c11 -Wall -Wextra -Wpedantic -Werror"
            )
        (package / "moon.pkg").write_text(
            'options(\n'
            '  "native-stub": [ "stub.c" ],\n'
            '  link: {\n'
            '    "native": {\n'
            f'      "stub-cc-flags": "{flags}",\n'
            '    },\n'
            '  },\n'
            ')\n',
            encoding="utf-8",
        )

    def check(self) -> list[str]:
        with mock.patch.multiple(
            self.checker,
            REPO_ROOT=self.root,
            PACKAGE_ROOT=self.source,
            MOON_MOD=self.moon_mod,
            NATIVE_PACKAGE_CONFIG=self.native / "moon.pkg",
            CAIRO_BUILD_SCRIPT=self.build_script,
            CONSUMER_PACKAGE_CONFIG=self.consumer / "moon.pkg",
        ):
            return self.checker.check_native_build_configuration()

    def test_central_build_configuration_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_missing_module_prebuild_registration_fails(self) -> None:
        self.moon_mod.write_text('name = "CAIMEOX/cairoon"\n', encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("unstable-prebuild" in error for error in errors), errors)

    def test_concrete_link_flags_in_any_package_fail(self) -> None:
        (self.source / "plain" / "moon.pkg").write_text(
            'options(link: { "native": { "cc-link-flags": "-lcairo" } })\n',
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(any("cc-link-flags" in error for error in errors), errors)

    def test_native_stub_without_build_variable_fails(self) -> None:
        self.write_stub_package(self.native, "-I/host/include/cairo")

        errors = self.check()

        self.assertTrue(any("CAIRO_CFLAGS" in error for error in errors), errors)

    def test_native_stub_requires_every_strict_c_flag(self) -> None:
        complete = (
            "${build.CAIRO_CFLAGS} "
            "-std=c11 -Wall -Wextra -Wpedantic -Werror"
        )
        for required in ["-std=c11", "-Wall", "-Wextra", "-Wpedantic", "-Werror"]:
            with self.subTest(required=required):
                self.write_stub_package(
                    self.native,
                    complete.replace(f" {required}", ""),
                )

                errors = self.check()

                self.assertTrue(
                    any("exact strict C flags" in error for error in errors),
                    errors,
                )

    def test_consumer_must_not_repeat_cairo_link_flags(self) -> None:
        (self.consumer / "moon.pkg").write_text(
            'import { "CAIMEOX/cairoon" } for "test"\n'
            'options(link: { "native": { "cc-link-flags": "-lcairo" } })\n',
            encoding="utf-8",
        )

        errors = self.check()

        self.assertTrue(
            any("consumer" in error and "cc-link-flags" in error for error in errors),
            errors,
        )


class ProjectLayoutModuleBoundaryTests(unittest.TestCase):
    def test_cli_wrappers_delegate_with_current_layout_inputs(self) -> None:
        checker = load_checker()
        marker = {"marker"}
        cases = (
            (
                "check_root_freeze",
                "_check_root_freeze",
                (checker.REPO_ROOT, marker),
                (marker,),
            ),
            (
                "check_public_package_root_freeze",
                "_check_public_package_root_freeze",
                (checker.PACKAGE_ROOT, marker),
                (marker,),
            ),
            (
                "check_source_root",
                "_check_source_root",
                (checker.REPO_ROOT, checker.PACKAGE_ROOT, checker.MOON_MOD),
                (),
            ),
            (
                "check_reference_docs",
                "_check_reference_docs",
                (
                    checker.DOC_PACKAGE_DIR,
                    checker.ROOT_README,
                    checker.PUBLIC_README,
                    checker.REQUIRED_REFERENCE_DOCS,
                ),
                (),
            ),
            (
                "check_integration_fixture",
                "_check_integration_fixture",
                (
                    checker.REPO_ROOT,
                    checker.MOON_MOD,
                    checker.INTEGRATION_WORKSPACE,
                    checker.CONSUMER_MODULE,
                    checker.CONSUMER_PACKAGE_CONFIG,
                    checker.CONSUMER_TEST,
                ),
                (),
            ),
            (
                "check_native_package",
                "_check_native_package",
                (checker.PACKAGE_ROOT, checker.NATIVE_PACKAGE_CONFIG),
                (),
            ),
            (
                "check_native_build_configuration",
                "_check_native_build_configuration",
                (
                    checker.REPO_ROOT,
                    checker.PACKAGE_ROOT,
                    checker.MOON_MOD,
                    checker.CAIRO_BUILD_SCRIPT,
                    checker.CONSUMER_PACKAGE_CONFIG,
                    checker.STRICT_STUB_CFLAGS,
                ),
                (),
            ),
            (
                "check_nested_packages",
                "_check_nested_packages",
                (checker.REPO_ROOT, checker.PACKAGE_ROOT),
                (),
            ),
            (
                "check_ffi_native_targets",
                "_check_ffi_native_targets",
                (
                    checker.REPO_ROOT,
                    checker.PACKAGE_ROOT,
                    checker.TEST_PACKAGE_ROOT,
                    checker.NATIVE_TARGETS,
                ),
                (),
            ),
            (
                "check_layout_counters",
                "_check_layout_counters",
                (
                    checker.REPO_ROOT,
                    checker.PACKAGE_ROOT,
                    checker.DOC_PACKAGE_DIR,
                    checker.TEST_PACKAGE_ROOT,
                    checker.NATIVE_PACKAGE_DIR,
                    checker.LAYOUT_DOC,
                    checker.COUNTED_PACKAGE_ROOTS,
                ),
                (),
            ),
            (
                "check_nested_c_files",
                "_check_nested_c_files",
                (
                    checker.REPO_ROOT,
                    checker.NATIVE_PACKAGE_DIR,
                    checker.NATIVE_PACKAGE_CONFIG,
                    checker.SANITIZER_PROBE_ROOT,
                ),
                (),
            ),
        )

        for wrapper_name, delegate_name, expected_args, call_args in cases:
            with self.subTest(wrapper=wrapper_name):
                sentinel = [wrapper_name]
                with mock.patch.object(
                    checker,
                    delegate_name,
                    return_value=sentinel,
                ) as delegate:
                    wrapper = getattr(checker, wrapper_name)
                    self.assertIs(wrapper(*call_args), sentinel)
                    delegate.assert_called_once_with(*expected_args)


if __name__ == "__main__":
    unittest.main()
