#!/usr/bin/env python3
"""Check that cairoon migration reliability evidence stays explicit."""

from __future__ import annotations

import pathlib
import sys
from collections.abc import Iterator


SCRIPT_ROOT = pathlib.Path(__file__).resolve().parent
if str(SCRIPT_ROOT) not in sys.path:
    sys.path.insert(0, str(SCRIPT_ROOT))

from reliability.ci_workflow import check_ci_workflow as _check_ci_workflow
from reliability.evidence import (
    NATIVE_TEST_MARKER,
    OWNER_EVIDENCE_MARKER,
    PARTIAL_GAP_MARKERS,
    PUBLICATION_MARKER,
    SCORECARD_DIMENSIONS,
    STATUSES,
    TESTS_EVIDENCE_MARKERS,
    TESTS_EVIDENCE_MAX_CHARS,
    TIER_THREE_MARKERS,
    check_inventory as _check_inventory,
    check_testing_doc as _check_testing_doc,
    current_stability_markers as _current_stability_markers,
    expected_current_stability_evidence as _expected_current_stability_evidence,
    expected_tests_evidence as _expected_tests_evidence,
    script_test_evidence_marker as _script_test_evidence_marker,
)
from reliability.gates import (
    DOWNSTREAM_GATE_LINES,
    SANITIZER_MODULE_MARKERS,
    VERIFY_COMMANDS,
    check_downstream_consumer_gate as _check_downstream_consumer_gate,
    check_local_matrix as _check_local_matrix,
    check_verify_gate as _check_verify_gate,
    shell_token_lines,
)
from reliability.markdown import (
    contains_any,
    inventory_rows as _inventory_rows,
    is_separator,
    markdown_fence_closes,
    markdown_fence_opener,
    markdown_indent_columns,
    markdown_paragraphs,
    markdown_section,
    mask_markdown_content,
    table_cells,
)


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
API_INVENTORY = REPO_ROOT / "API_INVENTORY.md"
TESTING = REPO_ROOT / "TESTING.md"
PACKAGE_README = REPO_ROOT / "src" / "README.mbt.md"
VERIFY = REPO_ROOT / "scripts" / "verify.sh"
CI = REPO_ROOT / ".github" / "workflows" / "ci.yml"
MATRIX = REPO_ROOT / "scripts" / "test-cairo-matrix.sh"
SANITIZER = REPO_ROOT / "scripts" / "sanitizers" / "run.py"
DOWNSTREAM_CONSUMER = REPO_ROOT / "scripts" / "check-downstream-consumer.sh"


def inventory_rows(
    section: str | None = None,
) -> Iterator[tuple[int, str, str, str]]:
    return _inventory_rows(API_INVENTORY, section)


def script_test_evidence_marker() -> str:
    return _script_test_evidence_marker(REPO_ROOT)


def expected_tests_evidence() -> str:
    return _expected_tests_evidence(REPO_ROOT)


def current_stability_markers() -> tuple[str, ...]:
    return _current_stability_markers(REPO_ROOT)


def expected_current_stability_evidence() -> str:
    return _expected_current_stability_evidence(REPO_ROOT)


def check_inventory() -> list[str]:
    return _check_inventory(API_INVENTORY, REPO_ROOT)


def check_testing_doc() -> list[str]:
    return _check_testing_doc(TESTING, PACKAGE_README, REPO_ROOT)


def check_verify_gate() -> list[str]:
    return _check_verify_gate(VERIFY)


def check_downstream_consumer_gate() -> list[str]:
    return _check_downstream_consumer_gate(DOWNSTREAM_CONSUMER)


def check_ci_gate() -> list[str]:
    return _check_ci_workflow(CI.read_text(encoding="utf-8"), CI)


def check_local_matrix() -> list[str]:
    return _check_local_matrix(REPO_ROOT, MATRIX, SANITIZER)


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

    partial_count = sum(
        1 for _, _, status, _ in inventory_rows() if status == "Partial"
    )
    print(f"Reliability ledger ok; {partial_count} Partial rows have explicit gaps")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
