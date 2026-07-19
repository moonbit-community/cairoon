#!/usr/bin/env python3
"""Check that cairoon migration reliability evidence stays explicit."""

from __future__ import annotations

import pathlib
import re
import shlex
import sys
import unittest
from collections.abc import Iterator


SCRIPT_ROOT = pathlib.Path(__file__).resolve().parent
if str(SCRIPT_ROOT) not in sys.path:
    sys.path.insert(0, str(SCRIPT_ROOT))

from reliability.ci_workflow import check_ci_workflow


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
API_INVENTORY = REPO_ROOT / "API_INVENTORY.md"
TESTING = REPO_ROOT / "TESTING.md"
PACKAGE_README = REPO_ROOT / "src" / "README.mbt.md"
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
TESTS_EVIDENCE_MAX_CHARS = 1200
NATIVE_TEST_MARKER = "840/840 native tests"
PUBLICATION_MARKER = "657 publication members"
OWNER_EVIDENCE_MARKER = (
    "12/12 raw external owners with exact finalizer and 1000-iteration stress evidence"
)
TESTS_EVIDENCE_MARKERS = (
    "Cairo 1.15.10",
    "Cairo 1.18.4",
    NATIVE_TEST_MARKER,
    "63/63 executable docs",
    "288 upstream pycairo tests across 20 families",
    "579/579 documented public declarations",
    OWNER_EVIDENCE_MARKER,
    "349-local-plus-two-direct production FFI boundary",
    "source and extracted consumers plus the unmodified cross-host archive consumer",
    PUBLICATION_MARKER,
    "ASan/LSan/UBSan",
    "Remaining gap:",
    "release commit",
    "Ubuntu",
    "macOS",
)
TIER_THREE_MARKERS = (
    "ASan/LSan/UBSan gate",
    "signed-overflow preflight",
    "intentional-leak preflight",
    "every discovered MoonBit package in a separate process",
    "scripts/sanitizers/probes/cairo_recording_snapshot_probe.c",
    "scripts/sanitizers/probes/cairo_pdf_jbig2_missing_probe.c",
    "exactly four non-inlined helpers",
)
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
    "Publication integrity",
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


def markdown_indent_columns(line: str) -> int:
    columns = 0
    for character in line:
        if character == " ":
            columns += 1
        elif character == "\t":
            columns += 4 - (columns % 4)
        else:
            break
    return columns


def markdown_fence_opener(line: str) -> tuple[str, int] | None:
    body = line.rstrip("\r\n")
    match = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", body)
    if match is None:
        return None
    marker, info = match.groups()
    if marker[0] == "`" and "`" in info:
        return None
    return marker[0], len(marker)


def markdown_fence_closes(line: str, character: str, length: int) -> bool:
    body = line.rstrip("\r\n")
    return re.fullmatch(
        rf" {{0,3}}{re.escape(character)}{{{length},}}[ \t]*",
        body,
    ) is not None


def mask_markdown_content(text: str) -> str:
    """Hide comments and Markdown code while preserving source line numbers."""
    characters = list(text)
    search_from = 0
    while (start := text.find("<!--", search_from)) != -1:
        closing = text.find("-->", start + 4)
        end = len(text) if closing == -1 else closing + 3
        for index in range(start, end):
            if characters[index] not in "\r\n":
                characters[index] = " "
        search_from = end

    without_comments = "".join(characters)
    visible_lines: list[str] = []
    fence_character: str | None = None
    fence_length = 0
    for line in without_comments.splitlines(keepends=True):
        if fence_character is not None:
            visible_lines.append(re.sub(r"[^\r\n]", " ", line))
            if markdown_fence_closes(line, fence_character, fence_length):
                fence_character = None
                fence_length = 0
            continue
        opener = markdown_fence_opener(line)
        if opener is not None:
            fence_character, fence_length = opener
            visible_lines.append(re.sub(r"[^\r\n]", " ", line))
            continue
        if markdown_indent_columns(line) >= 4:
            visible_lines.append(re.sub(r"[^\r\n]", " ", line))
            continue
        visible_lines.append(line)
    return "".join(visible_lines)


def inventory_rows(
    section: str | None = None,
) -> Iterator[tuple[int, str, str, str]]:
    text = mask_markdown_content(API_INVENTORY.read_text(encoding="utf-8"))
    lines = text.splitlines()
    start = 0
    section_level = 0
    if section is not None:
        try:
            start = lines.index(section) + 1
        except ValueError:
            return
        section_level = len(section) - len(section.lstrip("#"))

    in_status_table = False
    section_end = re.compile(rf"^#{{1,{section_level}}}\s") if section else None
    for line_no, line in enumerate(lines[start:], start + 1):
        if section_end is not None and section_end.match(line):
            break
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


def markdown_section(text: str, heading: str) -> str:
    lines = mask_markdown_content(text).splitlines()
    matches = [index for index, line in enumerate(lines) if line == heading]
    if len(matches) != 1:
        return ""
    start = matches[0]

    level = len(heading) - len(heading.lstrip("#"))
    end = len(lines)
    heading_pattern = re.compile(rf"^#{{1,{level}}}\s")
    for index in range(start + 1, len(lines)):
        if heading_pattern.match(lines[index]):
            end = index
            break
    return "\n".join(lines[start:end])


def markdown_paragraphs(text: str) -> tuple[str, ...]:
    paragraphs = []
    for block in re.split(r"\n\s*\n", text):
        normalized = re.sub(r"\s+", " ", block).strip()
        if normalized and not re.match(r"^#{1,6}\s", normalized):
            paragraphs.append(normalized)
    return tuple(paragraphs)


def script_test_evidence_marker() -> str:
    test_dir = REPO_ROOT / "scripts" / "tests"
    suite = unittest.TestLoader().discover(
        str(test_dir),
        pattern="test_*.py",
        top_level_dir=str(test_dir),
    )
    count = suite.countTestCases()
    return f"{count}/{count} script tests"


def expected_tests_evidence() -> str:
    return (
        "Local portable-scope evidence is complete: exact Cairo 1.15.10 and "
        f"Cairo 1.18.4 lanes pass {script_test_evidence_marker()}, "
        f"{NATIVE_TEST_MARKER}, 63/63 executable docs, 288 upstream pycairo "
        "tests across 20 families, 579/579 documented public declarations, "
        f"{OWNER_EVIDENCE_MARKER}, the 349-local-plus-two-direct production "
        "FFI boundary, source and "
        "extracted consumers plus the unmodified cross-host archive consumer, "
        f"all {PUBLICATION_MARKER}, and every "
        "discovered package under ASan/LSan/UBSan. Remaining gap: the unpushed "
        "release commit lacks shipped GitHub evidence for Ubuntu and macOS "
        "native jobs plus the Ubuntu combined ASan/LSan/UBSan job. Do not "
        "close this row until those exact jobs pass on the release commit; "
        "local evidence alone cannot close it."
    )


def current_stability_markers() -> tuple[str, ...]:
    return (
        (
            "Local release-candidate matrices on exact Cairo 1.15.10 and "
            f"1.18.4 pass {script_test_evidence_marker()}, {NATIVE_TEST_MARKER}, "
            "63/63 executable docs, "
            f"{OWNER_EVIDENCE_MARKER}, source and extracted consumers plus "
            "the unmodified cross-host archive consumer, all "
            f"{PUBLICATION_MARKER}, and every package under "
            "ASan/LSan/UBSan."
        ),
        "The sole global `Partial` row is shipped test/release-platform evidence",
        "release commit still needs passing Ubuntu and macOS native jobs plus the Ubuntu ASan/LSan/UBSan job",
    )


def expected_current_stability_evidence() -> str:
    return (
        "Local release-candidate matrices on exact Cairo 1.15.10 and 1.18.4 "
        f"pass {script_test_evidence_marker()}, {NATIVE_TEST_MARKER}, 63/63 "
        f"executable docs, {OWNER_EVIDENCE_MARKER}, source and extracted "
        "consumers plus the unmodified cross-host archive consumer, all "
        f"{PUBLICATION_MARKER}, and every "
        "package under ASan/LSan/UBSan. The sole global `Partial` row is "
        "shipped test/release-platform evidence: the release commit still needs "
        "passing Ubuntu and macOS native jobs plus the Ubuntu ASan/LSan/UBSan job. "
        "It does not represent an unimplemented portable API family, but it must "
        "close before a full-product claim. There is still no source-compatibility "
        "promise before `1.0`."
    )


def check_inventory() -> list[str]:
    errors: list[str] = []
    rows = list(inventory_rows())
    if not rows:
        return [f"{API_INVENTORY}: no migration status rows found"]

    tests_rows = [row for row in rows if row[1] == "Tests"]
    if len(tests_rows) != 1:
        errors.append(
            f"{API_INVENTORY}: expected exactly one Tests row; found {len(tests_rows)}"
        )
    snapshot_tests = [
        row
        for row in inventory_rows("## Current Coverage Snapshot")
        if row[1] == "Tests"
    ]
    if len(snapshot_tests) != 1:
        errors.append(
            f"{API_INVENTORY}: Current Coverage Snapshot must contain exactly "
            f"one Tests row; found {len(snapshot_tests)}"
        )
    partial_rows = [row for row in rows if row[2] == "Partial"]
    if len(partial_rows) != 1:
        errors.append(
            f"{API_INVENTORY}: expected exactly one Partial row; "
            f"found {len(partial_rows)}"
        )

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
        if label == "Tests":
            if status != "Partial":
                errors.append(
                    f"{location}: Tests must remain Partial until shipped CI "
                    "evidence closes the documented gap"
                )
            if len(notes) > TESTS_EVIDENCE_MAX_CHARS:
                errors.append(
                    f"{location}: evidence is too long ({len(notes)} characters; "
                    f"maximum {TESTS_EVIDENCE_MAX_CHARS})"
                )
            if notes != expected_tests_evidence():
                errors.append(
                    f"{location}: Tests must match the canonical release evidence "
                    "contract exactly"
                )
            evidence_markers = (
                script_test_evidence_marker(),
                *TESTS_EVIDENCE_MARKERS,
            )
            for marker in evidence_markers:
                if marker not in notes:
                    errors.append(
                        f"{location}: current release evidence is missing {marker!r}"
                    )
    return errors


def check_testing_doc() -> list[str]:
    text = TESTING.read_text(encoding="utf-8")
    package_readme_text = PACKAGE_README.read_text(encoding="utf-8")
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

    tier_three = markdown_section(text, "### Tier 3: Memory And Lifetime Tests")
    if not tier_three:
        errors.append(f"{TESTING}: missing Tier 3 memory and lifetime section")
    else:
        normalized_tier_three = re.sub(r"\s+", " ", tier_three)
        for marker in TIER_THREE_MARKERS:
            if marker not in normalized_tier_three:
                errors.append(f"{TESTING}: Tier 3 policy is missing {marker!r}")

    current_stability = markdown_section(
        package_readme_text,
        "## Current Stability",
    )
    if not current_stability:
        errors.append(
            f"{PACKAGE_README}: Current Stability heading must exist exactly once"
        )
    else:
        normalized_current_stability = re.sub(r"\s+", " ", current_stability)
        for marker in current_stability_markers():
            if marker not in normalized_current_stability:
                errors.append(
                    f"{PACKAGE_README}: Current Stability is missing {marker!r}"
                )
        paragraphs = markdown_paragraphs(current_stability)
        expected = expected_current_stability_evidence()
        if paragraphs.count(expected) != 1:
            errors.append(
                f"{PACKAGE_README}: Current Stability must contain exactly one "
                "canonical visible release-evidence paragraph"
            )
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
    return check_ci_workflow(CI.read_text(encoding="utf-8"), CI)


def check_local_matrix() -> list[str]:
    matrix_text = MATRIX.read_text(encoding="utf-8")
    lane_text = (
        REPO_ROOT / "scripts" / "matrix" / "run-lane.sh"
    ).read_text(encoding="utf-8")
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
            errors.append(f"{MATRIX}: local release matrix is missing {marker!r}")

    coverage_command = "python3 ./scripts/check-public-coverage.py --analyze"
    if shlex.split(coverage_command) not in shell_token_lines(lane_text):
        errors.append(
            f"{MATRIX}: pinned Cairo lanes must run {coverage_command!r}"
        )

    archive_command = (
        "./scripts/check-downstream-consumer.sh --archive /artifact/cairoon.zip"
    )
    if shlex.split(archive_command) not in shell_token_lines(lane_text):
        errors.append(
            f"{MATRIX}: pinned Cairo lanes must run {archive_command!r}"
        )

    for filename, markers in SANITIZER_MODULE_MARKERS.items():
        path = SANITIZER.parent / filename
        if not path.is_file():
            errors.append(f"{path}: sanitizer module is missing")
            continue
        source = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in source:
                errors.append(f"{path}: sanitizer gate is missing {marker!r}")
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
