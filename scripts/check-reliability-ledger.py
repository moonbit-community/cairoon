#!/usr/bin/env python3
"""Check that cairoon migration reliability evidence stays explicit."""

from __future__ import annotations

import pathlib
import re
import shlex
import sys
from collections.abc import Iterator


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
API_INVENTORY = REPO_ROOT / "API_INVENTORY.md"
TESTING = REPO_ROOT / "TESTING.md"
VERIFY = REPO_ROOT / "scripts" / "verify.sh"
CI = REPO_ROOT / ".github" / "workflows" / "ci.yml"
MATRIX = REPO_ROOT / "scripts" / "test-cairo-matrix.sh"
SANITIZER = REPO_ROOT / "scripts" / "sanitizers" / "run.py"
DOWNSTREAM_CONSUMER = REPO_ROOT / "scripts" / "check-downstream-consumer.sh"

STATUSES = {"Done", "Partial", "Decision", "Todo"}
PARTIAL_GAP_MARKERS = (
    "remain",
    "remaining",
    "not sufficient",
    "not proven",
    "not yet",
    "broader",
    "partial",
    "manual",
    "until",
)
DOWNSTREAM_GATE_LINES = (
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
SCORECARD_DIMENSIONS = (
    "API surface",
    "FFI boundary safety",
    "Behavioral parity",
    "Rendering parity",
    "Lifetime safety",
    "Callback safety",
    "Portability",
    "Documentation",
    "Downstream consumption",
)
VERIFY_COMMANDS = (
    "moon fmt --check",
    "python3 -m unittest discover -s scripts/tests -p 'test_*.py'",
    "python3 ./scripts/check-project-layout.py",
    "python3 ./scripts/check-source-size-budget.py",
    "./scripts/configure-link-flags.sh --check",
    "python3 ./scripts/check-ffi-ownership.py",
    "python3 ./scripts/check-stream-cleanup.py",
    "python3 ./scripts/check-api-inventory.py",
    "python3 ./scripts/check-public-docs.py",
    "python3 ./scripts/check-public-coverage.py",
    "python3 ./scripts/check-pycairo-test-parity.py",
    "python3 ./scripts/check-reliability-ledger.py",
    "python3 ./scripts/check-vector-backend-scenes.py",
    "moon check --target native --deny-warn",
    "./scripts/check-downstream-consumer.sh",
    "moon test --target native --deny-warn",
    "moon info --target native",
    "python3 ./scripts/sanitizers/run.py",
)


def table_cells(line: str) -> list[str] | None:
    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return None
    cells = [cell.strip() for cell in stripped.strip("|").split("|")]
    if len(cells) < 3:
        return None
    return cells


def is_separator(cells: list[str]) -> bool:
    return all(re.fullmatch(r":?-+:?", cell.replace(" ", "")) for cell in cells)


def inventory_rows() -> Iterator[tuple[int, str, str, str]]:
    in_status_table = False
    for line_no, line in enumerate(API_INVENTORY.read_text(encoding="utf-8").splitlines(), 1):
        cells = table_cells(line)
        if cells is None:
            in_status_table = False
            continue
        if is_separator(cells):
            continue

        second_header = cells[1].lower()
        if second_header in {"status", "cairoon status"}:
            in_status_table = True
            continue
        if not in_status_table:
            continue

        label = cells[0]
        status = cells[1]
        notes = " | ".join(cells[2:])
        yield line_no, label, status, notes


def contains_any(text: str, markers: tuple[str, ...]) -> bool:
    lowered = text.lower()
    return any(marker in lowered for marker in markers)


def check_inventory() -> list[str]:
    errors: list[str] = []
    rows = list(inventory_rows())
    if not rows:
        return [f"{API_INVENTORY}: no migration status rows found"]

    for line_no, label, status, notes in rows:
        location = f"{API_INVENTORY}:{line_no}: {label!r}"
        if status not in STATUSES:
            errors.append(f"{location}: unknown migration status {status!r}")
            continue
        if not notes.strip():
            errors.append(f"{location}: migration status row has no evidence notes")
        if status == "Todo":
            errors.append(
                f"{location}: Todo rows cannot pass the reliability gate; use Partial "
                "with an explicit remaining-risk note or Decision with a scope rationale"
            )
        elif status == "Partial" and not contains_any(notes, PARTIAL_GAP_MARKERS):
            errors.append(
                f"{location}: Partial row must state the remaining gap explicitly"
            )
    return errors


def check_testing_doc() -> list[str]:
    text = TESTING.read_text(encoding="utf-8")
    normalized_text = re.sub(r"\s+", " ", text)
    errors: list[str] = []
    for dimension in SCORECARD_DIMENSIONS:
        if f"| {dimension} |" not in text:
            errors.append(f"{TESTING}: scorecard is missing dimension {dimension!r}")

    required_phrases = (
        "For the full-product claim, there must be no `Todo` or `Partial` rows left",
        "reliable partial binding rather than a complete pycairo migration",
        "scripts/check-reliability-ledger.py",
        "scripts/check-public-docs.py",
        "scripts/check-public-coverage.py --analyze",
        "./scripts/test-cairo-matrix.sh cairo-1.15.10",
        "./scripts/test-cairo-matrix.sh cairo-1.18.4",
        "scripts/sanitizers/probes/cairo_recording_snapshot_probe.c",
        "scripts/sanitizers/probes/cairo_pdf_jbig2_missing_probe.c",
    )
    for phrase in required_phrases:
        if re.sub(r"\s+", " ", phrase) not in normalized_text:
            errors.append(f"{TESTING}: missing reliability rule {phrase!r}")
    return errors


def check_verify_gate() -> list[str]:
    text = VERIFY.read_text(encoding="utf-8")
    active_lines = shell_token_lines(text)
    errors: list[str] = []
    for command in VERIFY_COMMANDS:
        expected = ["run", *shlex.split(command)]
        if expected not in active_lines:
            errors.append(f"{VERIFY}: verify gate no longer runs {command!r}")
    return errors


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


def check_downstream_consumer_gate() -> list[str]:
    text = DOWNSTREAM_CONSUMER.read_text(encoding="utf-8")
    active_lines = {
        stripped
        for line in text.splitlines()
        if (stripped := line.strip()) and not stripped.startswith("#")
    }
    return [
        f"{DOWNSTREAM_CONSUMER}: downstream gate is missing active line {line!r}"
        for line in DOWNSTREAM_GATE_LINES
        if line not in active_lines
    ]


def check_ci_gate() -> list[str]:
    text = CI.read_text(encoding="utf-8")
    errors: list[str] = []
    required = (
        "./scripts/verify.sh",
        "CAIROON_VERIFY_ASAN",
        "CAIROON_ASAN_CC: clang",
        "CAIROON_ASAN_AR: llvm-ar",
        "CAIROON_SANITIZER_LEAKS: \"on\"",
        "python3 ./scripts/sanitizers/run.py",
        "ubuntu-latest",
        "macos-latest",
    )
    for marker in required:
        if marker not in text:
            errors.append(f"{CI}: CI reliability workflow is missing {marker!r}")
    if "detect_leaks=0" in text:
        errors.append(f"{CI}: Linux sanitizer CI must not disable LeakSanitizer")
    return errors


def check_local_matrix() -> list[str]:
    matrix_text = MATRIX.read_text(encoding="utf-8")
    lane_text = (
        REPO_ROOT / "scripts" / "matrix" / "run-lane.sh"
    ).read_text(encoding="utf-8")
    sanitizer_text = SANITIZER.read_text(encoding="utf-8")
    errors: list[str] = []
    matrix_markers = (
        "cairo-1.15.10",
        "cairo-1.18.4",
        "CAIROON_SANITIZER_LEAKS=on",
    )
    for marker in matrix_markers:
        if marker not in matrix_text and marker not in lane_text:
            errors.append(f"{MATRIX}: local release matrix is missing {marker!r}")

    coverage_command = "python3 ./scripts/check-public-coverage.py --analyze"
    if shlex.split(coverage_command) not in shell_token_lines(lane_text):
        errors.append(
            f"{MATRIX}: pinned Cairo lanes must run {coverage_command!r}"
        )

    sanitizer_markers = (
        "compiler_preflight",
        "probe_recording_snapshot_leak",
        "RECORDING_SNAPSHOT_PACKAGES",
        "probe_pdf_jbig2_missing_leak",
        "PDF_JBIG2_MISSING_PACKAGES",
        "discover_packages",
        "MOON_TOOLCHAIN_ROOT",
        "validate_suppression_usage",
        "validate_pdf_jbig2_suppression_usage",
    )
    for marker in sanitizer_markers:
        if marker not in sanitizer_text:
            errors.append(f"{SANITIZER}: sanitizer gate is missing {marker!r}")
    return errors


def main() -> int:
    errors = []
    errors.extend(check_inventory())
    errors.extend(check_testing_doc())
    errors.extend(check_verify_gate())
    errors.extend(check_downstream_consumer_gate())
    errors.extend(check_ci_gate())
    errors.extend(check_local_matrix())
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    partial_count = sum(1 for _, _, status, _ in inventory_rows() if status == "Partial")
    print(f"Reliability ledger ok; {partial_count} Partial rows have explicit gaps")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
