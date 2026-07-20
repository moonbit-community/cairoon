"""Validate the failure-critical structure of cairoon's CI workflow."""

from __future__ import annotations

import pathlib
import re
from dataclasses import dataclass


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


def yaml_job_section(text: str, job: str) -> str:
    return yaml_mapping_section(text, 2, job)


def yaml_mapping_section(text: str, indent: int, key: str) -> str:
    lines = text.splitlines()
    entries = yaml_structural_lines(text)
    matches = [
        line_no
        for line_no, line_indent, content in entries
        if line_indent == indent
        and not content.startswith("- ")
        and yaml_key_value(content) == (key, "")
    ]
    if len(matches) != 1:
        return ""
    start = matches[0]
    end = len(lines)
    for line_no, line_indent, content in entries:
        if (
            line_no > start
            and line_indent <= indent
            and yaml_key_value(content) is not None
        ):
            end = line_no
            break
    return "\n".join(lines[start:end])


def yaml_step_section(job_section: str, run_line: str) -> str:
    lines = job_section.splitlines()
    expected_command = yaml_key_value(run_line)
    if expected_command is None or expected_command[0] != "run":
        return ""
    entries = yaml_structural_lines(job_section)
    run_indexes = [
        line_no
        for line_no, indent, content in entries
        if indent == 8 and yaml_key_value(content) == expected_command
    ]
    if len(run_indexes) != 1:
        return ""

    run_index = run_indexes[0]
    starts = [
        line_no
        for line_no, indent, content in reversed(entries)
        if line_no <= run_index and indent == 6 and content.startswith("- ")
    ]
    if not starts:
        return ""
    start = starts[0]
    end = len(lines)
    for line_no, indent, content in entries:
        if line_no > start and indent == 6 and content.startswith("- "):
            end = line_no
            break
    return "\n".join(lines[start:end])


def yaml_step_sections(steps_section: str) -> list[str]:
    lines = steps_section.splitlines()
    starts = [
        line_no
        for line_no, indent, content in yaml_structural_lines(steps_section)
        if indent == 6 and content.startswith("- ")
    ]
    return [
        "\n".join(lines[start : starts[index + 1] if index + 1 < len(starts) else None])
        for index, start in enumerate(starts)
    ]


def yaml_step_names(steps_section: str) -> list[str]:
    names = []
    sections = yaml_step_sections(steps_section)
    section_starts = {
        line_no
        for line_no, indent, content in yaml_structural_lines(steps_section)
        if indent == 6 and content.startswith("- ")
    }
    for line_no, indent, content in yaml_structural_lines(steps_section):
        if indent == 6 and line_no not in section_starts:
            names.append("<non-step>")
    for section in sections:
        entries = yaml_structural_lines(section)
        first = entries[0][2] if entries else ""
        key_value = yaml_key_value(first)
        if key_value is None or key_value[0] != "name":
            names.append("<unnamed>")
        else:
            names.append(key_value[1])
    return names


def yaml_named_step_section(steps_section: str, name: str) -> str:
    matches = []
    for section in yaml_step_sections(steps_section):
        entries = yaml_structural_lines(section)
        if entries and yaml_key_value(entries[0][2]) == ("name", name):
            matches.append(section)
    return matches[0] if len(matches) == 1 else ""


def yaml_run_commands(step_section: str) -> tuple[str, ...]:
    lines = step_section.splitlines()
    runs = [
        (line_no, value)
        for line_no, indent, content in yaml_structural_lines(step_section)
        if indent == 8
        and (key_value := yaml_key_value(content)) is not None
        and key_value[0] == "run"
        for value in (key_value[1],)
    ]
    if len(runs) != 1:
        return ()
    line_no, value = runs[0]
    if not yaml_is_block_scalar(value):
        return (value,) if value else ()

    block = []
    for line in lines[line_no + 1 :]:
        content = line.lstrip(" ")
        indent = len(line) - len(content)
        if content and indent <= 8:
            break
        if content:
            block.append(content.rstrip())
    if not block:
        return ()
    return tuple(block)


def active_yaml_lines(text: str) -> set[str]:
    return {content for _, _, content in yaml_structural_lines(text)}


def yaml_noncomment_lines(text: str) -> list[str]:
    return [
        content
        for line in text.splitlines()
        if (content := line.lstrip(" \t")) and not content.startswith("#")
    ]


def yaml_key_value(content: str) -> tuple[str, str] | None:
    candidate = content[2:].lstrip() if content.startswith("- ") else content
    match = re.match(
        r'^(?:"([^"]+)"|\'([^\']+)\'|([A-Za-z0-9_<>-]+))\s*:(?=$|[ \t])(.*)$',
        candidate,
    )
    if match is None:
        return None
    key = next(group for group in match.groups()[:3] if group is not None)
    return key, match.group(4).strip()


def yaml_structural_lines(text: str) -> list[tuple[int, int, str]]:
    entries: list[tuple[int, int, str]] = []
    block_parent_indent: int | None = None
    for line_no, line in enumerate(text.splitlines()):
        content = line.lstrip(" ")
        indent = len(line) - len(content)
        if block_parent_indent is not None:
            if not content or indent > block_parent_indent:
                continue
            block_parent_indent = None
        if not content or content.startswith("#"):
            continue

        entries.append((line_no, indent, content))
        key_value = yaml_key_value(content)
        if key_value is not None and yaml_is_block_scalar(key_value[1]):
            block_parent_indent = indent
    return entries


def yaml_is_block_scalar(value: str) -> bool:
    value_without_comment = re.sub(r"\s+#.*$", "", value).rstrip()
    return re.search(r"(?:^|\s)[>|][0-9+-]*$", value_without_comment) is not None


def yaml_has_key(text: str, key: str, *, indent: int | None = None) -> bool:
    for _, line_indent, content in yaml_structural_lines(text):
        if indent is not None and line_indent != indent:
            continue
        key_value = yaml_key_value(content)
        if key_value is not None and key_value[0] == key:
            return True
    return False


def yaml_keys_at_indent(text: str, indent: int) -> list[str]:
    keys = []
    for _, line_indent, content in yaml_structural_lines(text):
        if line_indent != indent or content.startswith("- "):
            continue
        key_value = yaml_key_value(content)
        keys.append("<unparsed>" if key_value is None else key_value[0])
    return keys


def yaml_sequence_scalars_at_indent(text: str, indent: int) -> list[str]:
    values = []
    for _, line_indent, content in yaml_structural_lines(text):
        if line_indent != indent or not content.startswith("- "):
            continue
        value = content[2:].strip()
        values.append("<mapping>" if yaml_key_value(value) is not None else value)
    return values
