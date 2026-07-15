#!/usr/bin/env python3
"""Tests for the public MoonBit documentation audit."""

from __future__ import annotations

import importlib.util
import pathlib
import sys
import tempfile
import unittest


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-public-docs.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_public_docs", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class PublicDocsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.checker = load_checker()

    def parse(self, source: str):
        with tempfile.TemporaryDirectory() as temp_dir:
            path = pathlib.Path(temp_dir) / "sample.mbt"
            path.write_text(source, encoding="utf-8")
            return self.checker.public_items(path, pathlib.Path(temp_dir))

    def read_ledger(self, contents: str):
        with tempfile.TemporaryDirectory() as temp_dir:
            path = pathlib.Path(temp_dir) / "debt.txt"
            path.write_text(contents, encoding="utf-8")
            return self.checker.read_debt_ledger(path)

    def test_empty_block_marker_is_not_documentation(self) -> None:
        items = self.parse("///|\npub fn answer() -> Int { 42 }\n")
        self.assertEqual(items[0].symbol, "answer")
        self.assertFalse(items[0].documented)

    def test_substantive_markdown_comment_is_documentation(self) -> None:
        items = self.parse(
            "///|\n/// Return the answer.\npub fn answer() -> Int { 42 }\n"
        )
        self.assertTrue(items[0].documented)

    def test_comment_before_attribute_documents_alias(self) -> None:
        items = self.parse(
            '/// Index into the value.\n#alias("_[_]")\n'
            "pub fn Value::at(self : Value, index : Int) -> Int { index }\n"
        )
        self.assertEqual(items[0].symbol, "Value::at")
        self.assertTrue(items[0].documented)

    def test_generic_function_and_public_types_are_discovered(self) -> None:
        items = self.parse(
            "/// Capture an error.\n"
            "pub fn[T] capture(f : () -> T) -> T { f() }\n"
            "/// A mode.\npub(all) enum Mode { One }\n"
            "/// A value.\npub struct Value { value : Int }\n"
            "/// An alias.\npub type Alias = Value\n"
            "/// An error.\npub suberror Failure { Bad }\n"
        )
        self.assertEqual(
            [item.symbol for item in items],
            ["capture", "Mode", "Value", "Alias", "Failure"],
        )
        self.assertTrue(all(item.documented for item in items))

    def test_trait_implementations_are_not_documentation_items(self) -> None:
        items = self.parse("pub impl Eq for Value with op_equal(self, other) { true }\n")
        self.assertEqual(items, [])

    def test_exact_debt_passes(self) -> None:
        items = self.parse(
            "///|\npub fn missing() -> Unit {}\n"
            "/// Present.\npub fn present() -> Unit {}\n"
        )
        self.assertEqual(
            self.checker.check_debt(items, [items[0].key]),
            [],
        )

    def test_new_undocumented_declaration_fails(self) -> None:
        items = self.parse("///|\npub fn missing() -> Unit {}\n")
        errors = self.checker.check_debt(items, [])
        self.assertIn("missing from debt ledger", errors[0])

    def test_documented_debt_entry_is_stale(self) -> None:
        items = self.parse("/// Present.\npub fn present() -> Unit {}\n")
        errors = self.checker.check_debt(items, [items[0].key])
        self.assertIn("stale public documentation debt", errors[0])

    def test_unsorted_debt_ledger_fails(self) -> None:
        _, errors = self.read_ledger("src/z.mbt\tz\nsrc/a.mbt\ta\n")
        self.assertTrue(any("must be sorted" in error for error in errors))

    def test_duplicate_debt_ledger_fails(self) -> None:
        _, errors = self.read_ledger("src/a.mbt\ta\nsrc/a.mbt\ta\n")
        self.assertTrue(any("duplicate" in error for error in errors))

    def test_malformed_debt_ledger_fails(self) -> None:
        _, errors = self.read_ledger("src/a.mbt\ta\textra\n")
        self.assertTrue(any("malformed" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
