#!/usr/bin/env python3
"""Tests for cairoon hosted-workflow reliability policy."""

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


class HostedWorkflowGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.script = pathlib.Path(self.temp_dir.name) / "ci.yml"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check_ci(self, workflow: str) -> list[str]:
        self.script.write_text(workflow, encoding="utf-8")
        with mock.patch.object(self.checker, "CI", self.script):
            return self.checker.check_ci_gate()

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
            "    runs-on: ubuntu-24.04\n"
            "    timeout-minutes: 60\n"
        )
        self.assertEqual(workflow.count(concurrency_anchor), 1)
        self.assertEqual(workflow.count(native_timeout_anchor), 1)
        self.assertEqual(workflow.count(asan_timeout_anchor), 1)
        job_anchor = "    runs-on: ubuntu-24.04\n"
        step_anchor = "      - name: Run ASan, LSan, and UBSan package gate\n"
        run_anchor = "        run: python3 ./scripts/sanitizers/run.py"
        jobs_anchor = "jobs:\n"
        matrix_anchor = (
            "        os:\n"
            "          - ubuntu-24.04\n"
            "          - macos-15\n"
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
                "    runs-on: ubuntu-24.04\n",
            ),
            (
                "sanitizer runner drifts to moving alias",
                job_anchor,
                "    runs-on: ubuntu-latest\n",
            ),
            (
                "native runners drift to moving aliases",
                matrix_anchor,
                "        os:\n"
                "          - ubuntu-latest\n"
                "          - macos-latest\n",
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
                matrix_anchor + "        exclude:\n          - os: macos-15\n",
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

        setup_mutations = (
            (
                "native cairo headers omitted",
                "sudo apt-get install -y pkg-config libcairo2-dev build-essential",
                "sudo apt-get install -y pkg-config libcairo2 build-essential",
            ),
            (
                "sanitizer compiler omitted",
                "sudo apt-get install -y pkg-config libcairo2-dev "
                "libfontconfig1-dev clang llvm build-essential",
                "sudo apt-get install -y pkg-config libcairo2-dev "
                "libfontconfig1-dev llvm build-essential",
            ),
            (
                "registry update skipped",
                "        run: moon update",
                "        run: moon version",
            ),
            (
                "generated constants skipped",
                "        run: scripts/configure-cairo-constants.sh",
                "        run: true",
            ),
            (
                "installer source changed",
                "curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash",
                "curl -fsSL https://example.invalid/install.sh | bash",
            ),
            (
                "setup commands use folded scalar",
                "        if: runner.os == 'Linux'\n        run: |",
                "        if: runner.os == 'Linux'\n        run: >",
            ),
            (
                "setup step renamed",
                "      - name: Update MoonBit registry\n",
                "      - name: Update package registry\n",
            ),
            (
                "unverified setup step inserted",
                step_anchor,
                "      - name: Unverified setup\n"
                "        run: true\n\n"
                + step_anchor,
            ),
        )
        for label, anchor, replacement in setup_mutations:
            with self.subTest(label=label):
                self.assertIn(anchor, workflow)
                mutated = workflow.replace(anchor, replacement, 1)
                self.assertNotEqual(mutated, workflow)
                self.assertTrue(self.check_ci(mutated))

        with self.subTest(label="complete setup steps reordered"):
            first = workflow.index("      - name: Update MoonBit registry\n")
            second = workflow.index("      - name: Show tool versions\n", first)
            third = workflow.index(
                "      - name: Configure generated Cairo constants\n",
                second,
            )
            reordered = (
                workflow[:first]
                + workflow[second:third]
                + workflow[first:second]
                + workflow[third:]
            )
            self.assertTrue(self.check_ci(reordered))

        continuation_mutations = (
            ("checkout scalar continuation", "        uses: actions/checkout@v6", "|| true"),
            ("condition scalar continuation", "        if: runner.os == 'Linux'", "&& false"),
            ("run scalar continuation", "        run: scripts/configure-cairo-constants.sh", "|| true"),
            ("parser-shaped run continuation", "        run: scripts/configure-cairo-constants.sh", "x:|| true"),
            ("gate sequence continuation", "        run: python3 ./scripts/sanitizers/run.py", "- || true"),
        )
        for label, anchor, continuation in continuation_mutations:
            with self.subTest(label=label):
                mutated = workflow.replace(anchor, anchor + "\n          " + continuation, 1)
                self.assertTrue(self.check_ci(mutated))

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
        with self.subTest(label="workflow permissions broadened"):
            broadened = workflow.replace(
                permissions_anchor,
                "permissions:\n  contents: write\n",
                1,
            )
            self.assertTrue(self.check_ci(broadened))

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
