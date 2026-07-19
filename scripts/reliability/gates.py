"""Shell, downstream-consumer, and local-matrix reliability gates."""

from __future__ import annotations

import pathlib
import shlex


DOWNSTREAM_GATE_LINES = (
    'if [[ "$#" == 2 && "$1" == "--archive" ]]; then',
    'archive_path="$2"',
    "test_source=0",
    'if ! package_listing="$(moon package --list 2>&1)"; then',
    'run python3 "$repo_root/scripts/check-publication-archive.py" "$archive_path"',
    'run python3 -m zipfile -e "$archive_path" "$published_root"',
    (
        'artifact_workspace="$(mktemp -d '
        '"${temp_root%/}/cairoon-package-consumer.XXXXXX")"'
    ),
    "trap cleanup EXIT",
    "'  \"./published\",' \\",
    "'  \"./consumer\",' \\",
    'run moon -C "$artifact_consumer_root" fmt --check "$consumer_package"',
    (
        'run moon -C "$artifact_consumer_root" check "$consumer_package" '
        "--target native --deny-warn"
    ),
    (
        'run moon -C "$artifact_consumer_root" test "$consumer_package" '
        "--target native --deny-warn -v"
    ),
    "printf 'Published archive passes the isolated consumer test.\\n'",
)
VERIFY_COMMANDS = (
    "moon fmt --check",
    "python3 -m unittest discover -s scripts/tests -p 'test_*.py'",
    "python3 ./scripts/check-project-layout.py",
    "python3 ./scripts/check-source-size-budget.py",
    "./scripts/configure-cairo-constants.sh --check",
    "python3 ./scripts/check-ffi-ownership.py",
    "python3 ./scripts/check-external-owners.py",
    "python3 ./scripts/check-stream-cleanup.py",
    "python3 ./scripts/check-api-inventory.py",
    "python3 ./scripts/check-public-docs.py",
    "python3 ./scripts/check-public-coverage.py",
    "python3 ./scripts/check-pycairo-test-parity.py",
    "python3 ./scripts/check-reliability-ledger.py",
    "python3 ./scripts/check-vector-backend-scenes.py",
    "moon check --target native --deny-warn --warn-list +73",
    "./scripts/check-downstream-consumer.sh",
    "moon test --target native --deny-warn",
    "moon info --target native",
    "python3 ./scripts/sanitizers/run.py",
)
SANITIZER_MODULE_MARKERS = {
    "run.py": (
        "from leak_probes import (",
        "from toolchain import (",
        "discover_packages",
        "MOON_TOOLCHAIN_ROOT",
    ),
    "toolchain.py": (
        "compiler_preflight",
        "-fsanitize=address,undefined",
        "UBSAN_OPTIONS",
        "validate_ubsan_probe",
    ),
    "leak_probes.py": (
        "probe_recording_snapshot_leak",
        "RECORDING_SNAPSHOT_PACKAGES",
        "probe_pdf_jbig2_missing_leak",
        "PDF_JBIG2_MISSING_PACKAGES",
        "validate_suppression_usage",
        "validate_pdf_jbig2_suppression_usage",
    ),
}


def shell_token_lines(text: str) -> list[list[str]]:
    lines: list[list[str]] = []
    for line in text.splitlines():
        try:
            tokens = shlex.split(line, comments=True, posix=True)
        except ValueError:
            continue
        if tokens:
            lines.append(tokens)
    return lines


def check_verify_gate(verify: pathlib.Path) -> list[str]:
    text = verify.read_text(encoding="utf-8")
    active_lines = shell_token_lines(text)
    errors: list[str] = []
    for command in VERIFY_COMMANDS:
        expected = ["run", *shlex.split(command)]
        if expected not in active_lines:
            errors.append(f"{verify}: verify gate no longer runs {command!r}")
    return errors


def check_downstream_consumer_gate(
    downstream_consumer: pathlib.Path,
) -> list[str]:
    text = downstream_consumer.read_text(encoding="utf-8")
    active_lines = {
        stripped
        for line in text.splitlines()
        if (stripped := line.strip()) and not stripped.startswith("#")
    }
    return [
        f"{downstream_consumer}: downstream gate is missing active line {line!r}"
        for line in DOWNSTREAM_GATE_LINES
        if line not in active_lines
    ]


def check_local_matrix(
    repo_root: pathlib.Path,
    matrix: pathlib.Path,
    sanitizer: pathlib.Path,
) -> list[str]:
    matrix_text = matrix.read_text(encoding="utf-8")
    lane_text = (repo_root / "scripts" / "matrix" / "run-lane.sh").read_text(
        encoding="utf-8"
    )
    dockerfile = repo_root / "scripts" / "matrix" / "Dockerfile"
    dockerfile_text = (
        dockerfile.read_text(encoding="utf-8") if dockerfile.is_file() else ""
    )
    errors: list[str] = []
    matrix_markers = (
        "cairo-1.15.10",
        "cairo-1.18.4",
        "CAIROON_SANITIZER_LEAKS=on",
        "moon package --list",
        "dst=/artifact/cairoon.zip,readonly",
    )
    for marker in matrix_markers:
        if marker not in matrix_text and marker not in lane_text:
            errors.append(f"{matrix}: local release matrix is missing {marker!r}")

    system_cairo_contract = (
        (matrix, matrix_text, "ubuntu-24.04-system"),
        (matrix, matrix_text, "--target system-cairo"),
        (dockerfile, dockerfile_text, "AS matrix-base"),
        (dockerfile, dockerfile_text, "FROM lane-runner AS system-cairo"),
        (dockerfile, dockerfile_text, "FROM matrix-base AS exact-cairo"),
        (
            dockerfile,
            dockerfile_text,
            'CAIROON_MATRIX_CAIRO_VERSION="1.18.0"',
        ),
        (
            dockerfile,
            dockerfile_text,
            'RUN test "$(pkg-config --modversion cairo)" = '
            '"${CAIROON_MATRIX_CAIRO_VERSION}"',
        ),
    )
    for path, source, marker in system_cairo_contract:
        if marker not in source:
            errors.append(
                f"{path}: Ubuntu system Cairo lane is missing {marker!r}"
            )

    coverage_command = "python3 ./scripts/check-public-coverage.py --analyze"
    if shlex.split(coverage_command) not in shell_token_lines(lane_text):
        errors.append(f"{matrix}: pinned Cairo lanes must run {coverage_command!r}")

    archive_command = (
        "./scripts/check-downstream-consumer.sh --archive /artifact/cairoon.zip"
    )
    if shlex.split(archive_command) not in shell_token_lines(lane_text):
        errors.append(f"{matrix}: pinned Cairo lanes must run {archive_command!r}")

    for filename, markers in SANITIZER_MODULE_MARKERS.items():
        path = sanitizer.parent / filename
        if not path.is_file():
            errors.append(f"{path}: sanitizer module is missing")
            continue
        source = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in source:
                errors.append(f"{path}: sanitizer gate is missing {marker!r}")
    return errors
