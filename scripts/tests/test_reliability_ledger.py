#!/usr/bin/env python3
"""Tests for downstream-consumer and hosted workflow reliability gates."""

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


class ReliabilityGateDelegationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()

    def test_gate_wrappers_delegate_current_paths(self) -> None:
        with mock.patch.object(
            self.checker,
            "_check_verify_gate",
            return_value=["verify"],
        ) as check_verify:
            self.assertEqual(self.checker.check_verify_gate(), ["verify"])
        check_verify.assert_called_once_with(self.checker.VERIFY)

        with mock.patch.object(
            self.checker,
            "_check_downstream_consumer_gate",
            return_value=["consumer"],
        ) as check_consumer:
            self.assertEqual(
                self.checker.check_downstream_consumer_gate(),
                ["consumer"],
            )
        check_consumer.assert_called_once_with(self.checker.DOWNSTREAM_CONSUMER)

        workflow = self.checker.CI.read_text(encoding="utf-8")
        with mock.patch.object(
            self.checker,
            "_check_ci_workflow",
            return_value=["ci"],
        ) as check_ci:
            self.assertEqual(self.checker.check_ci_gate(), ["ci"])
        check_ci.assert_called_once_with(workflow, self.checker.CI)


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

    def test_native_check_requires_warning_73(self) -> None:
        marker = "moon check --target native --deny-warn --warn-list +73"
        downgraded = "moon check --target native --deny-warn"
        self.assertIn(marker, self.checker.VERIFY_COMMANDS)
        self.script.write_text(
            "\n".join(
                f"run {downgraded}" if command == marker else f"run {command}"
                for command in self.checker.VERIFY_COMMANDS
            ),
            encoding="utf-8",
        )
        with mock.patch.object(self.checker, "VERIFY", self.script):
            errors = self.checker.check_verify_gate()
        self.assertTrue(any(marker in error for error in errors))

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
        concurrency_anchor = (
            "concurrency:\n"
            "  group: cairoon-${{ github.workflow }}-${{ github.ref }}\n"
            "  cancel-in-progress: true\n"
        )
        native_timeout_anchor = (
            "    runs-on: ${{ matrix.os }}\n"
            "    timeout-minutes: 60\n"
        )
        asan_timeout_anchor = (
            "    runs-on: ubuntu-latest\n"
            "    timeout-minutes: 60\n"
        )
        self.assertEqual(workflow.count(concurrency_anchor), 1)
        self.assertEqual(workflow.count(native_timeout_anchor), 1)
        self.assertEqual(workflow.count(asan_timeout_anchor), 1)
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
                "concurrency cancellation disabled",
                concurrency_anchor,
                concurrency_anchor.replace(
                    "cancel-in-progress: true",
                    "cancel-in-progress: false",
                ),
            ),
            (
                "concurrency group merges unrelated refs",
                concurrency_anchor,
                concurrency_anchor.replace(
                    "cairoon-${{ github.workflow }}-${{ github.ref }}",
                    "cairoon-${{ github.workflow }}",
                ),
            ),
            (
                "native timeout removed",
                native_timeout_anchor,
                "    runs-on: ${{ matrix.os }}\n",
            ),
            (
                "sanitizer timeout removed",
                asan_timeout_anchor,
                "    runs-on: ubuntu-latest\n",
            ),
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

        checkout_anchor = "        uses: actions/checkout@v6"
        self.assertEqual(workflow.count(checkout_anchor), 2)
        with self.subTest(label="deprecated checkout runtime"):
            downgraded = workflow.replace(
                checkout_anchor,
                "        uses: actions/checkout@v4",
                1,
            )
            self.assertTrue(self.check_ci(downgraded))

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


if __name__ == "__main__":
    unittest.main()
