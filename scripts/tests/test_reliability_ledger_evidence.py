#!/usr/bin/env python3
"""Tests for current release-evidence ledger rules."""

from __future__ import annotations

import importlib.util
import pathlib
import re
import tempfile
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-reliability-ledger.py"


def script_test_count() -> int:
    test_dir = CHECKER.parent / "tests"
    return unittest.TestLoader().discover(
        str(test_dir),
        pattern="test_*.py",
        top_level_dir=str(test_dir),
    ).countTestCases()


def load_checker():
    spec = importlib.util.spec_from_file_location("check_reliability_ledger", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ReliabilityEvidenceDelegationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()

    def test_evidence_wrappers_delegate_current_paths(self) -> None:
        rows = [(7, "Tests", "Partial", "remaining")]
        with mock.patch.object(
            self.checker,
            "_inventory_rows",
            return_value=iter(rows),
        ) as inventory_rows:
            self.assertEqual(
                list(self.checker.inventory_rows("## Current Coverage Snapshot")),
                rows,
            )
        inventory_rows.assert_called_once_with(
            self.checker.API_INVENTORY,
            "## Current Coverage Snapshot",
        )

        with mock.patch.object(
            self.checker,
            "_script_test_evidence_marker",
            return_value="marker",
        ) as script_marker:
            self.assertEqual(self.checker.script_test_evidence_marker(), "marker")
        script_marker.assert_called_once_with(self.checker.REPO_ROOT)

        with mock.patch.object(
            self.checker,
            "_check_inventory",
            return_value=["inventory"],
        ) as check_inventory:
            self.assertEqual(self.checker.check_inventory(), ["inventory"])
        check_inventory.assert_called_once_with(
            self.checker.API_INVENTORY,
            self.checker.REPO_ROOT,
        )

        with mock.patch.object(
            self.checker,
            "_check_testing_doc",
            return_value=["testing"],
        ) as check_testing:
            self.assertEqual(self.checker.check_testing_doc(), ["testing"])
        check_testing.assert_called_once_with(
            self.checker.TESTING,
            self.checker.PACKAGE_README,
            self.checker.REPO_ROOT,
        )


class CurrentReleaseEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.inventory = self.root / "API_INVENTORY.md"
        self.testing = self.root / "TESTING.md"
        self.package_readme = self.root / "README.mbt.md"
        self.testing_text = self.checker.TESTING.read_text(encoding="utf-8")
        self.script_test_marker = (
            f"{script_test_count()}/{script_test_count()} script tests"
        )
        self.native_test_marker = self.checker.NATIVE_TEST_MARKER
        self.publication_marker = self.checker.PUBLICATION_MARKER
        self.owner_evidence_marker = self.checker.OWNER_EVIDENCE_MARKER
        package_readme_text = (
            CHECKER.parents[1] / "src" / "README.mbt.md"
        ).read_text(encoding="utf-8")
        self.package_readme_text = re.sub(
            r"\d+/\d+\s+script tests",
            self.script_test_marker,
            package_readme_text,
            count=1,
        )
        self.current_stability_evidence = (
            "Local release-candidate matrices on exact Cairo 1.15.10 and 1.18.4 "
            f"pass {self.script_test_marker}, {self.native_test_marker}, 63/63 "
            f"executable docs, {self.owner_evidence_marker}, 6/6 source, "
            "extracted, and unmodified cross-host archive consumer runs, all "
            f"{self.publication_marker}, and every package under "
            "ASan/LSan/UBSan. Ubuntu 24.04 system Cairo 1.18.0 independently "
            f"passes {self.native_test_marker} and every package under "
            "ASan/LSan/UBSan. The sole global `Partial` row is shipped "
            "test/release-platform evidence: GitHub run 29678818105 passed macOS "
            "native but failed both Ubuntu jobs on the prior release commit. The "
            "local fix commit still needs passing Ubuntu and macOS native jobs plus "
            "the Ubuntu ASan/LSan/UBSan job. It does "
            "not represent an unimplemented portable API family, but it must close "
            "before a full-product claim. There is still no source-compatibility "
            "promise before `1.0`."
        )
        stability_section = self.checker.markdown_section(
            self.package_readme_text,
            "## Current Stability",
        )
        self.current_stability_block = next(
            block
            for block in re.split(r"\n\s*\n", stability_section)
            if re.sub(r"\s+", " ", block).strip()
            == self.current_stability_evidence
        )
        self.tests_evidence = (
            "Local portable-scope evidence is complete: exact Cairo 1.15.10 and "
            f"Cairo 1.18.4 lanes pass {self.script_test_marker}, "
            f"{self.native_test_marker}, 63/63 executable docs, 288 upstream pycairo "
            "tests across 20 families, 579/579 documented public declarations, "
            f"{self.owner_evidence_marker}, the 349-local-plus-two-direct production "
            "FFI boundary, 6/6 source, extracted, and unmodified cross-host "
            f"archive consumer runs, all {self.publication_marker}, "
            "and every discovered package under ASan/LSan/UBSan. Ubuntu 24.04 "
            f"system Cairo 1.18.0 independently passes {self.native_test_marker} "
            "and every discovered package under ASan/LSan/UBSan. Remaining gap: "
            "GitHub run 29678818105 passed macOS native but failed both Ubuntu jobs "
            "on the prior release commit. The local fix commit still needs passing "
            "Ubuntu and macOS native jobs plus the Ubuntu combined ASan/LSan/UBSan "
            "job. Do not close this row until those exact jobs pass on the release "
            "commit; local evidence alone cannot close it."
        )

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check_inventory(
        self,
        notes: str,
        *,
        label: str = "Tests",
        status: str = "Partial",
        section_heading: str = "## Current Coverage Snapshot",
        fenced: bool = False,
        html_commented: bool = False,
        indented_code: bool = False,
        indent_prefix: str = "    ",
        false_closing_fence: bool = False,
        extra_row: str | None = None,
    ) -> list[str]:
        row = f"| {label} | {status} | {notes} |"
        if false_closing_fence:
            row = f"```text\n``` still-code\n{row}\n```"
        elif fenced:
            row = f"```text\n{row}\n```"
        rows = [
            section_heading,
            "",
            "| Family | Status | Evidence |",
            "|---|---|---|",
            row,
        ]
        if extra_row is not None:
            rows.append(extra_row)
        if indented_code:
            rows[2:] = [f"{indent_prefix}{line}" for line in rows[2:]]
        inventory_text = "\n".join(rows)
        if html_commented:
            inventory_text = f"<!--\n{inventory_text}\n-->"
        self.inventory.write_text(
            inventory_text,
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "API_INVENTORY", self.inventory):
            return self.checker.check_inventory()

    def check_docs(
        self,
        *,
        testing_text: str | None = None,
        package_readme_text: str | None = None,
    ) -> list[str]:
        self.testing.write_text(
            self.testing_text if testing_text is None else testing_text,
            encoding="utf-8",
        )
        self.package_readme.write_text(
            self.package_readme_text
            if package_readme_text is None
            else package_readme_text,
            encoding="utf-8",
        )
        with (
            mock.patch.object(self.checker, "TESTING", self.testing),
            mock.patch.object(
                self.checker,
                "PACKAGE_README",
                self.package_readme,
                create=True,
            ),
        ):
            return self.checker.check_testing_doc()

    def test_current_tests_evidence_passes(self) -> None:
        self.assertEqual(self.check_inventory(self.tests_evidence), [])
        errors = self.check_inventory(self.tests_evidence, label="Docs", status="Done")
        self.assertTrue(any("exactly one Tests row" in error for error in errors))
        errors = self.check_inventory(self.tests_evidence, status="Done")
        self.assertTrue(any("must remain Partial" in error for error in errors))
        errors = self.check_inventory(
            self.tests_evidence,
            section_heading="## Historical Evidence",
        )
        self.assertTrue(any("Current Coverage Snapshot" in error for error in errors))
        errors = self.check_inventory(self.tests_evidence, fenced=True)
        self.assertTrue(errors)
        errors = self.check_inventory(
            self.tests_evidence,
            extra_row="| Other | Partial | Remaining platform evidence. |",
        )
        self.assertTrue(any("exactly one Partial row" in error for error in errors))
        tests_dir = self.root / "scripts" / "tests"
        tests_dir.mkdir(parents=True)
        (tests_dir / "test_count.py").write_text(
            "\n".join(
                [
                    "import unittest",
                    "",
                    "class Helper:",
                    "    def test_not_discovered(self):",
                    "        pass",
                    "",
                    "class RealTest(unittest.TestCase):",
                    "    def test_discovered(self):",
                    "        pass",
                ]
            ) + "\n",
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "REPO_ROOT", self.root):
            marker = self.checker.script_test_evidence_marker()
        self.assertEqual(marker, "1/1 script tests")

    def test_current_release_docs_pass(self) -> None:
        self.assertEqual(self.check_docs(), [])
        section = self.checker.markdown_section(
            "### Current\ninside\n### Next\noutside\n",
            "### Current",
        )
        self.assertEqual(section, "### Current\ninside")

    def test_tests_evidence_requires_combined_sanitizers(self) -> None:
        notes = self.tests_evidence.replace("ASan/LSan/UBSan", "ASan/LSan")
        errors = self.check_inventory(notes)
        self.assertTrue(any("ASan/LSan/UBSan" in error for error in errors))

    def test_tests_evidence_in_html_comment_is_ignored(self) -> None:
        errors = self.check_inventory(
            self.tests_evidence,
            html_commented=True,
        )
        self.assertTrue(errors)
        errors = self.check_inventory(
            self.tests_evidence,
            indented_code=True,
        )
        self.assertTrue(errors)
        errors = self.check_inventory(
            self.tests_evidence,
            indented_code=True,
            indent_prefix=" \t",
        )
        self.assertTrue(errors)
        errors = self.check_inventory(
            self.tests_evidence,
            false_closing_fence=True,
        )
        self.assertTrue(errors)

    def test_tests_evidence_requires_discovered_script_count(self) -> None:
        notes = self.tests_evidence.replace(self.script_test_marker, "1/1 script tests")
        errors = self.check_inventory(notes)
        self.assertTrue(any(self.script_test_marker in error for error in errors))

    def test_tests_evidence_requires_exact_native_count(self) -> None:
        notes = self.tests_evidence.replace(self.native_test_marker, "native tests")
        errors = self.check_inventory(notes)
        self.assertTrue(any(self.native_test_marker in error for error in errors))
        notes = self.tests_evidence.replace("lanes pass", "lanes do not pass")
        errors = self.check_inventory(notes)
        self.assertTrue(any("canonical release evidence" in error for error in errors))

    def test_tests_evidence_has_a_size_budget(self) -> None:
        errors = self.check_inventory(self.tests_evidence + " detail" * 300)
        self.assertTrue(any("too long" in error for error in errors))

    def test_current_stability_requires_combined_sanitizers(self) -> None:
        readme = self.package_readme_text.replace(
            "ASan/LSan/UBSan",
            "ASan/LSan",
        )
        errors = self.check_docs(package_readme_text=readme)
        self.assertTrue(any("ASan/LSan/UBSan" in error for error in errors))
        readme = self.package_readme_text.replace(
            self.native_test_marker,
            "native tests",
        )
        errors = self.check_docs(package_readme_text=readme)
        self.assertTrue(any(self.native_test_marker in error for error in errors))

    def test_current_stability_requires_one_exact_visible_paragraph(self) -> None:
        mutations = {
            "HTML comment": self.package_readme_text.replace(
                self.current_stability_block,
                f"<!--\n{self.current_stability_block}\n-->",
                1,
            ),
            "negated claim": self.package_readme_text.replace(
                self.current_stability_block,
                f"These claims are false: {self.current_stability_block}",
                1,
            ),
            "indented code": self.package_readme_text.replace(
                self.current_stability_block,
                "\n".join(
                    f"    {line}" for line in self.current_stability_block.splitlines()
                ),
                1,
            ),
            "tab-expanded indented code": self.package_readme_text.replace(
                self.current_stability_block,
                "\n".join(
                    f" \t{line}" for line in self.current_stability_block.splitlines()
                ),
                1,
            ),
            "false closing fence": self.package_readme_text.replace(
                self.current_stability_block,
                "```text\n``` still-code\n"
                + self.current_stability_block
                + "\n```",
                1,
            ),
            "duplicate heading": (
                self.package_readme_text
                + "\n\n## Current Stability\n\n"
                + self.current_stability_evidence
                + "\n"
            ),
        }
        for label, readme in mutations.items():
            with self.subTest(label=label):
                errors = self.check_docs(package_readme_text=readme)
                self.assertTrue(errors)

    def test_tier_three_requires_signed_overflow_preflight(self) -> None:
        testing = self.testing_text.replace(
            "signed-overflow preflight",
            "undefined-behavior preflight",
        )
        errors = self.check_docs(testing_text=testing)
        self.assertTrue(any("signed-overflow preflight" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
