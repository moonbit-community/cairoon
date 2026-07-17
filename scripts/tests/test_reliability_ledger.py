#!/usr/bin/env python3
"""Tests for downstream-consumer reliability gate wiring."""

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


class DownstreamConsumerGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "consumer.sh"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check(
        self,
        omitted: str | None = None,
        commented: str | None = None,
    ) -> list[str]:
        markers = [
            f"# {line}" if line == commented else line
            for line in self.checker.DOWNSTREAM_GATE_LINES
            if line != omitted
        ]
        self.script.write_text("\n".join(markers), encoding="utf-8")
        with mock.patch.object(self.checker, "DOWNSTREAM_CONSUMER", self.script):
            return self.checker.check_downstream_consumer_gate()

    def test_complete_artifact_gate_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_missing_existing_archive_mode_fails(self) -> None:
        self.assertTrue(
            self.check('if [[ "$#" == 2 && "$1" == "--archive" ]]; then')
        )

    def test_existing_archive_mode_must_skip_source_repackaging(self) -> None:
        self.assertTrue(self.check("test_source=0"))

    def test_missing_artifact_fmt_fails(self) -> None:
        marker = 'run moon -C "$artifact_consumer_root" fmt --check "$consumer_package"'
        self.assertTrue(self.check(marker))

    def test_missing_artifact_check_fails(self) -> None:
        marker = (
            'run moon -C "$artifact_consumer_root" check "$consumer_package" '
            "--target native --deny-warn"
        )
        self.assertTrue(self.check(marker))

    def test_missing_artifact_test_fails(self) -> None:
        marker = (
            'run moon -C "$artifact_consumer_root" test "$consumer_package" '
            "--target native --deny-warn -v"
        )
        self.assertTrue(self.check(marker))

    def test_missing_published_workspace_member_fails(self) -> None:
        self.assertTrue(self.check("'  \"./published\",' \\"))

    def test_commented_artifact_test_fails(self) -> None:
        marker = (
            'run moon -C "$artifact_consumer_root" test "$consumer_package" '
            "--target native --deny-warn -v"
        )
        self.assertTrue(self.check(commented=marker))


class VerifyGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "verify.sh"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check_ci(self, workflow: str) -> list[str]:
        self.script.write_text(workflow, encoding="utf-8")
        with mock.patch.object(self.checker, "CI", self.script):
            return self.checker.check_ci_gate()

    def test_missing_public_coverage_ledger_gate_fails(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.assertIn(marker, self.checker.VERIFY_COMMANDS)
        self.script.write_text(
            "\n".join(
                f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
                if command != marker
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

    def test_commented_public_coverage_gate_fails(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.script.write_text(
            "\n".join(
                f"# run {command}" if command == marker else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

    def test_inline_comment_cannot_impersonate_public_coverage_gate(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.script.write_text(
            "\n".join(
                f": # {command}" if command == marker else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

    def test_failure_masking_cannot_impersonate_verify_gate(self) -> None:
        marker = "python3 ./scripts/check-public-coverage.py"
        self.script.write_text(
            "\n".join(
                f"run {command} || true"
                if command == marker
                else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

        sanitizer_command = "run: python3 ./scripts/sanitizers/run.py"
        workflow = self.checker.CI.read_text(encoding="utf-8").replace(
            sanitizer_command,
            f"# {sanitizer_command}",
        )
        self.script.write_text(workflow, encoding="utf-8")
        with mock.patch.object(self.checker, "CI", self.script):
            errors = self.checker.check_ci_gate()
        self.assertTrue(any(sanitizer_command in error for error in errors))

    def test_ci_gate_rejects_job_and_gate_step_failure_masking(self) -> None:
        workflow = self.checker.CI.read_text(encoding="utf-8")
        self.assertEqual(self.check_ci(workflow), [])
        job_anchor = "    runs-on: ubuntu-latest\n"
        step_anchor = "      - name: Run ASan, LSan, and UBSan package gate\n"
        run_anchor = "        run: python3 ./scripts/sanitizers/run.py"
        jobs_anchor = "jobs:\n"
        matrix_anchor = (
            "        os:\n"
            "          - ubuntu-latest\n"
            "          - macos-latest\n"
        )
        push_branches_anchor = "    branches:\n      - main\n"
        global_env_anchor = (
            "env:\n"
            "  MOONBIT_INSTALL_VERSION: 0.10.4+4f2e8f7dc-nightly\n"
        )
        mutations = (
            (
                "workflow default shell masks failures",
                jobs_anchor,
                "defaults:\n"
                "  run:\n"
                "    shell: bash -c 'bash {0} || true'\n\n"
                + jobs_anchor,
            ),
            (
                "matrix excludes macOS",
                matrix_anchor,
                matrix_anchor + "        exclude:\n          - os: macos-latest\n",
            ),
            (
                "push trigger ignores every path",
                push_branches_anchor,
                push_branches_anchor + "    paths-ignore:\n      - '**'\n",
            ),
            (
                "global environment injects bash startup",
                global_env_anchor,
                global_env_anchor + "  BASH_ENV: scripts/ignore-failures.sh\n",
            ),
            (
                "job continue-on-error",
                job_anchor,
                job_anchor + "    continue-on-error: true\n",
            ),
            (
                "quoted job continue-on-error",
                job_anchor,
                job_anchor + '    "continue-on-error": true\n',
            ),
            (
                "step continue-on-error",
                run_anchor,
                run_anchor + "\n        continue-on-error: true",
            ),
            (
                "quoted step continue-on-error",
                run_anchor,
                run_anchor + '\n        "continue-on-error": true',
            ),
            (
                "job condition",
                job_anchor,
                job_anchor + "    if: ${{ github.ref == 'refs/heads/never' }}\n",
            ),
            (
                "quoted job condition",
                job_anchor,
                job_anchor + '    "if": false\n',
            ),
            (
                "gate step condition",
                step_anchor,
                step_anchor + "        if: ${{ github.ref == 'refs/heads/never' }}\n",
            ),
            (
                "quoted gate step condition",
                step_anchor,
                step_anchor + '        "if": false\n',
            ),
            (
                "block scalar command impersonation",
                run_anchor,
                "        run: |\n"
                "          cat <<'EOF'\n"
                "          run: python3 ./scripts/sanitizers/run.py\n"
                "          EOF",
            ),
            (
                "gate shell masks command failure",
                run_anchor,
                "        shell: bash -c '{0} || true'\n" + run_anchor,
            ),
            (
                "duplicate run overrides sanitizer",
                run_anchor,
                run_anchor + "\n        run: true",
            ),
            (
                "block scalar disables leak detection",
                step_anchor,
                "      - name: Disable leak detection\n"
                "        run: |\n"
                "          echo 'ASAN_OPTIONS=detect_leaks=0' >> \"$GITHUB_ENV\"\n\n"
                + step_anchor,
            ),
        )
        for label, anchor, replacement in mutations:
            with self.subTest(label=label):
                self.assertEqual(workflow.count(anchor), 1)
                mutated = workflow.replace(anchor, replacement, 1)
                self.assertNotEqual(mutated, workflow)
                errors = self.check_ci(mutated)
                self.assertTrue(errors)

        permissions_anchor = "permissions:\n  contents: read\n"
        self.assertEqual(workflow.count(permissions_anchor), 1)
        jobs_prefix, jobs_separator, jobs_body = workflow.partition("jobs:\n")
        self.assertEqual(jobs_separator, "jobs:\n")
        self.assertTrue(jobs_body.strip())
        misnested_jobs = (
            jobs_prefix.replace(
                permissions_anchor,
                permissions_anchor + jobs_body,
                1,
            )
            + "jobs:\n"
        )
        self.assertNotEqual(misnested_jobs, workflow)
        with self.subTest(label="jobs outside jobs mapping"):
            self.assertTrue(self.check_ci(misnested_jobs))

        gate_block = (
            "      - name: Run ASan, LSan, and UBSan package gate\n"
            "        env:\n"
            "          CAIROON_ASAN_CC: clang\n"
            "          CAIROON_ASAN_AR: llvm-ar\n"
            "          CAIROON_SANITIZER_LEAKS: \"on\"\n"
            "        run: python3 ./scripts/sanitizers/run.py\n"
        )
        asan_anchor = "  asan:\n"
        self.assertEqual(workflow.count(gate_block), 1)
        self.assertEqual(workflow.count(asan_anchor), 1)
        gate_outside_steps = workflow.replace(gate_block, "", 1).replace(
            asan_anchor,
            asan_anchor + "    misplaced-gate:\n" + gate_block,
            1,
        )
        self.assertNotEqual(gate_outside_steps, workflow)
        with self.subTest(label="gate outside steps sequence"):
            errors = self.check_ci(gate_outside_steps)
            self.assertTrue(
                any("must contain exactly one active gate step" in error for error in errors)
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
        package_readme_text = (
            CHECKER.parents[1] / "src" / "README.mbt.md"
        ).read_text(encoding="utf-8")
        self.package_readme_text = re.sub(
            r"\d+/\d+ script tests",
            self.script_test_marker,
            package_readme_text,
            count=1,
        )
        self.current_stability_evidence = (
            "Local release-candidate matrices on exact Cairo 1.15.10 and 1.18.4 "
            f"pass {self.script_test_marker}, 826/826 native tests, 63/63 executable "
            "docs, source and extracted consumers plus the unmodified cross-host "
            "archive consumer, all 623 publication members, and every package under "
            "ASan/LSan/UBSan. The sole global `Partial` row is shipped "
            "test/release-platform evidence: the release commit still needs passing "
            "Ubuntu and macOS native jobs plus the Ubuntu ASan/LSan/UBSan job. It does "
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
            f"Cairo 1.18.4 lanes pass {self.script_test_marker}, 826/826 native tests, "
            "63/63 executable docs, 288 upstream pycairo tests across 20 families, "
            "579/579 documented public declarations, the 349-local-plus-two-direct "
            "production FFI boundary, source and extracted consumers plus the "
            "unmodified cross-host archive consumer, all 623 publication members, "
            "and every discovered package under "
            "ASan/LSan/UBSan. Remaining gap: the unpushed release commit lacks "
            "shipped GitHub evidence for Ubuntu and macOS native jobs plus the Ubuntu "
            "combined ASan/LSan/UBSan job. Do not close this row until those exact "
            "jobs pass on the release commit; local evidence alone cannot close it."
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
            ),
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
        notes = self.tests_evidence.replace("826/826 native tests", "native tests")
        errors = self.check_inventory(notes)
        self.assertTrue(any("826/826 native tests" in error for error in errors))
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
            "826/826 native tests",
            "native tests",
        )
        errors = self.check_docs(package_readme_text=readme)
        self.assertTrue(any("826/826 native tests" in error for error in errors))

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


class LocalMatrixGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.matrix = self.root / "scripts" / "test-cairo-matrix.sh"
        self.lane = self.root / "scripts" / "matrix" / "run-lane.sh"
        self.sanitizer = self.root / "scripts" / "sanitizers" / "run.py"
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
                    "compiler_preflight",
                    "-fsanitize=address,undefined",
                    "UBSAN_OPTIONS",
                    "validate_ubsan_probe",
                    "probe_recording_snapshot_leak",
                    "RECORDING_SNAPSHOT_PACKAGES",
                    "probe_pdf_jbig2_missing_leak",
                    "PDF_JBIG2_MISSING_PACKAGES",
                    "discover_packages",
                    "MOON_TOOLCHAIN_ROOT",
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
        self.sanitizer.write_text(
            self.sanitizer.read_text(encoding="utf-8").replace(
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
