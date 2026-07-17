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
            flags = "${build.CAIRO_CFLAGS}"
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


if __name__ == "__main__":
    unittest.main()
