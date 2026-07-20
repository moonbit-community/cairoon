"""Validate the failure-critical structure of cairoon's CI workflow."""

from __future__ import annotations

import pathlib
from dataclasses import dataclass

from reliability.yaml_subset import (
    active_yaml_lines,
    yaml_has_key,
    yaml_job_section,
    yaml_key_value,
    yaml_keys_at_indent,
    yaml_mapping_section,
    yaml_named_step_section,
    yaml_noncomment_lines,
    yaml_run_commands,
    yaml_sequence_scalars_at_indent,
    yaml_step_names,
    yaml_step_section,
    yaml_structural_lines,
)


@dataclass(frozen=True)
class StepSpec:
    name: str
    keys: tuple[str, ...]
    lines: tuple[str, ...] = ()
    commands: tuple[str, ...] = ()


CHECKOUT_STEP = StepSpec(
    "Checkout",
    ("uses",),
    lines=("uses: actions/checkout@v6",),
)
INSTALL_MOONBIT_STEP = StepSpec(
    "Install MoonBit",
    ("run",),
    lines=("run: |",),
    commands=(
        "curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash",
        'echo "$HOME/.moon/bin" >> "$GITHUB_PATH"',
    ),
)
UPDATE_REGISTRY_STEP = StepSpec(
    "Update MoonBit registry",
    ("run",),
    commands=("moon update",),
)
CONFIGURE_CONSTANTS_STEP = StepSpec(
    "Configure generated Cairo constants",
    ("run",),
    commands=("scripts/configure-cairo-constants.sh",),
)


JOB_SPECS = {
    "native": {
        "keys": ("name", "runs-on", "timeout-minutes", "strategy", "steps"),
        "job": (
            "name: native (${{ matrix.os }})",
            "runs-on: ${{ matrix.os }}",
            "timeout-minutes: 60",
            "- ubuntu-24.04",
            "- macos-15",
        ),
        "gate_name": "Run native reliability gate",
        "step": (
            "- name: Run native reliability gate",
            'CAIROON_VERIFY_ASAN: "0"',
            "run: ./scripts/verify.sh",
        ),
        "run": "run: ./scripts/verify.sh",
        "env_keys": ("CAIROON_VERIFY_ASAN",),
    },
    "asan": {
        "keys": ("name", "runs-on", "timeout-minutes", "steps"),
        "job": (
            "name: asan (ubuntu)",
            "runs-on: ubuntu-24.04",
            "timeout-minutes: 60",
        ),
        "gate_name": "Run ASan, LSan, and UBSan package gate",
        "step": (
            "- name: Run ASan, LSan, and UBSan package gate",
            "CAIROON_ASAN_CC: clang",
            "CAIROON_ASAN_AR: llvm-ar",
            'CAIROON_SANITIZER_LEAKS: "on"',
            "run: python3 ./scripts/sanitizers/run.py",
        ),
        "run": "run: python3 ./scripts/sanitizers/run.py",
        "env_keys": (
            "CAIROON_ASAN_CC",
            "CAIROON_ASAN_AR",
            "CAIROON_SANITIZER_LEAKS",
        ),
    },
}


SETUP_STEP_SPECS = {
    "native": (
        CHECKOUT_STEP,
        StepSpec(
            "Install system dependencies (Ubuntu)",
            ("if", "run"),
            lines=("if: runner.os == 'Linux'", "run: |"),
            commands=(
                "sudo apt-get update",
                "sudo apt-get install -y pkg-config libcairo2-dev build-essential",
            ),
        ),
        StepSpec(
            "Install system dependencies (macOS)",
            ("if", "run"),
            lines=("if: runner.os == 'macOS'", "run: |"),
            commands=("brew update", "brew install cairo pkg-config"),
        ),
        INSTALL_MOONBIT_STEP,
        UPDATE_REGISTRY_STEP,
        StepSpec(
            "Show tool versions",
            ("run",),
            lines=("run: |",),
            commands=("moon version", "pkg-config --modversion cairo"),
        ),
        CONFIGURE_CONSTANTS_STEP,
    ),
    "asan": (
        CHECKOUT_STEP,
        StepSpec(
            "Install system dependencies",
            ("run",),
            lines=("run: |",),
            commands=(
                "sudo apt-get update",
                "sudo apt-get install -y pkg-config libcairo2-dev "
                "libfontconfig1-dev clang llvm build-essential",
            ),
        ),
        INSTALL_MOONBIT_STEP,
        UPDATE_REGISTRY_STEP,
        StepSpec(
            "Show tool versions",
            ("run",),
            lines=("run: |",),
            commands=(
                "moon version",
                "clang --version",
                "pkg-config --modversion cairo",
            ),
        ),
        CONFIGURE_CONSTANTS_STEP,
    ),
}


def check_ci_workflow(text: str, source: pathlib.Path) -> list[str]:
    errors = check_workflow_shape(text, source)
    for _, _, content in yaml_structural_lines(text):
        if not content.startswith("- ") and yaml_key_value(content) is None:
            errors.append(
                f"{source}: CI workflow contains an unparsed scalar continuation"
            )
            break
    actual_sequences = [
        (indent, content)
        for _, indent, content in yaml_structural_lines(text)
        if content.startswith("- ")
    ]
    if actual_sequences != canonical_sequence_lines():
        errors.append(f"{source}: CI workflow sequence structure must remain canonical")
    checkout_steps = [
        content
        for _, _, content in yaml_structural_lines(text)
        if content.startswith("uses: actions/checkout@")
    ]
    if checkout_steps != ["uses: actions/checkout@v6"] * 2:
        errors.append(
            f"{source}: native and sanitizer jobs must each use actions/checkout@v6"
        )
    jobs_section = yaml_mapping_section(text, 0, "jobs")
    if sorted(yaml_keys_at_indent(jobs_section, 2)) != ["asan", "native"]:
        errors.append(f"{source}: CI jobs mapping must contain exactly native and asan")
    for job, spec in JOB_SPECS.items():
        section = yaml_job_section(jobs_section, job)
        if not section:
            errors.append(f"{source}: CI reliability workflow is missing job {job!r}")
            continue

        job_lines = active_yaml_lines(section)
        for marker in spec["job"]:
            if marker not in job_lines:
                errors.append(
                    f"{source}: CI job {job!r} is missing active line {marker!r}"
                )
        if sorted(yaml_keys_at_indent(section, 4)) != sorted(spec["keys"]):
            errors.append(
                f"{source}: CI job {job!r} must keep its canonical top-level keys"
            )
        if yaml_has_key(section, "continue-on-error"):
            errors.append(
                f"{source}: CI job {job!r} must not allow continue-on-error"
            )
        if yaml_has_key(section, "if", indent=4):
            errors.append(f"{source}: CI job {job!r} must not be conditional")
        if job == "native":
            errors.extend(check_native_matrix(section, source))

        steps_section = yaml_mapping_section(section, 4, "steps")
        errors.extend(check_setup_steps(job, steps_section, source))
        gate_step = yaml_step_section(steps_section, spec["run"])
        if not gate_step:
            errors.append(
                f"{source}: CI job {job!r} must contain exactly one active gate "
                f"step for {spec['run']!r}"
            )
            continue
        gate_lines = active_yaml_lines(gate_step)
        for marker in spec["step"]:
            if marker not in gate_lines:
                errors.append(
                    f"{source}: CI job {job!r} gate step is missing active line "
                    f"{marker!r}"
                )
        if sorted(yaml_keys_at_indent(gate_step, 8)) != ["env", "run"]:
            errors.append(
                f"{source}: CI job {job!r} gate step may contain only env and run "
                "keys"
            )
        if sorted(yaml_keys_at_indent(gate_step, 10)) != sorted(spec["env_keys"]):
            errors.append(
                f"{source}: CI job {job!r} gate environment must match the "
                "canonical keys exactly"
            )
        if any(indent > 10 for _, indent, _ in yaml_structural_lines(gate_step)):
            errors.append(
                f"{source}: CI job {job!r} gate step has unexpected nested lines"
            )
        if yaml_has_key(gate_step, "if"):
            errors.append(
                f"{source}: CI job {job!r} gate step must not be conditional"
            )

    if any("detect_leaks=0" in line for line in yaml_noncomment_lines(text)):
        errors.append(f"{source}: Linux sanitizer CI must not disable LeakSanitizer")
    return errors


def canonical_sequence_lines() -> list[tuple[int, str]]:
    lines = [(6, "- main"), (10, "- ubuntu-24.04"), (10, "- macos-15")]
    for job in ("native", "asan"):
        lines.extend((6, f"- name: {step.name}") for step in SETUP_STEP_SPECS[job])
        lines.append((6, f"- name: {JOB_SPECS[job]['gate_name']}"))
    return lines


def check_setup_steps(
    job: str,
    steps_section: str,
    source: pathlib.Path,
) -> list[str]:
    errors = []
    specs = SETUP_STEP_SPECS[job]
    expected_names = [step.name for step in specs] + [JOB_SPECS[job]["gate_name"]]
    if yaml_step_names(steps_section) != expected_names:
        errors.append(
            f"{source}: CI job {job!r} steps must match the canonical order exactly"
        )

    for spec in specs:
        step = yaml_named_step_section(steps_section, spec.name)
        if not step:
            errors.append(
                f"{source}: CI job {job!r} is missing unique setup step "
                f"{spec.name!r}"
            )
            continue
        if sorted(yaml_keys_at_indent(step, 8)) != sorted(spec.keys):
            errors.append(
                f"{source}: CI job {job!r} setup step {spec.name!r} must keep "
                "its canonical keys"
            )
        if any(indent > 8 for _, indent, _ in yaml_structural_lines(step)):
            errors.append(
                f"{source}: CI job {job!r} setup step {spec.name!r} has "
                "unexpected nested lines"
            )
        lines = active_yaml_lines(step)
        for marker in spec.lines:
            if marker not in lines:
                errors.append(
                    f"{source}: CI job {job!r} setup step {spec.name!r} is "
                    f"missing active line {marker!r}"
                )
        if spec.commands and yaml_run_commands(step) != spec.commands:
            errors.append(
                f"{source}: CI job {job!r} setup step {spec.name!r} must run "
                "the canonical commands exactly"
            )
    return errors


def check_workflow_shape(text: str, source: pathlib.Path) -> list[str]:
    errors = []
    expected_root_keys = (
        "name",
        "on",
        "concurrency",
        "permissions",
        "env",
        "jobs",
    )
    if sorted(yaml_keys_at_indent(text, 0)) != sorted(expected_root_keys):
        errors.append(f"{source}: CI workflow must keep its canonical root keys")

    permissions = yaml_mapping_section(text, 0, "permissions")
    if active_yaml_lines(permissions) != {"permissions:", "contents: read"}:
        errors.append(f"{source}: CI workflow permissions must remain contents: read")

    trigger = yaml_mapping_section(text, 0, "on")
    if sorted(yaml_keys_at_indent(trigger, 2)) != [
        "pull_request",
        "push",
        "workflow_dispatch",
    ]:
        errors.append(f"{source}: CI workflow triggers must keep their canonical keys")
    push = yaml_mapping_section(trigger, 2, "push")
    if yaml_keys_at_indent(push, 4) != ["branches"]:
        errors.append(f"{source}: CI push trigger must contain only branches")
    branches = yaml_mapping_section(push, 4, "branches")
    if yaml_sequence_scalars_at_indent(branches, 6) != ["main"]:
        errors.append(f"{source}: CI push trigger must run on main")
    for trigger_name in ("pull_request", "workflow_dispatch"):
        section = yaml_mapping_section(trigger, 2, trigger_name)
        if len(yaml_structural_lines(section)) != 1:
            errors.append(
                f"{source}: CI trigger {trigger_name!r} must be unconditional"
            )

    concurrency = yaml_mapping_section(text, 0, "concurrency")
    if sorted(yaml_keys_at_indent(concurrency, 2)) != [
        "cancel-in-progress",
        "group",
    ]:
        errors.append(
            f"{source}: CI concurrency must contain only group and "
            "cancel-in-progress"
        )
    if active_yaml_lines(concurrency) != {
        "concurrency:",
        "group: cairoon-${{ github.workflow }}-${{ github.ref }}",
        "cancel-in-progress: true",
    }:
        errors.append(
            f"{source}: CI concurrency must cancel stale runs for the same ref"
        )

    global_env = yaml_mapping_section(text, 0, "env")
    if active_yaml_lines(global_env) != {
        "env:",
        "MOONBIT_INSTALL_VERSION: 0.10.4+4f2e8f7dc-nightly",
    }:
        errors.append(f"{source}: CI global environment must remain canonical")
    return errors


def check_native_matrix(job_section: str, source: pathlib.Path) -> list[str]:
    errors = []
    strategy = yaml_mapping_section(job_section, 4, "strategy")
    if sorted(yaml_keys_at_indent(strategy, 6)) != ["fail-fast", "matrix"]:
        errors.append(
            f"{source}: native strategy must contain only fail-fast and matrix"
        )
    if "fail-fast: false" not in active_yaml_lines(strategy):
        errors.append(f"{source}: native strategy must keep fail-fast false")

    matrix = yaml_mapping_section(strategy, 6, "matrix")
    if yaml_keys_at_indent(matrix, 8) != ["os"]:
        errors.append(f"{source}: native matrix must contain only the os axis")
    os_axis = yaml_mapping_section(matrix, 8, "os")
    if yaml_sequence_scalars_at_indent(os_axis, 10) != [
        "ubuntu-24.04",
        "macos-15",
    ]:
        errors.append(
            f"{source}: native matrix must run exact Ubuntu and macOS combinations"
        )
    return errors
