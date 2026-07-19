"""Canonical migration and release-evidence checks."""

from __future__ import annotations

import pathlib
import re
import unittest

from reliability.markdown import (
    contains_any,
    inventory_rows,
    markdown_paragraphs,
    markdown_section,
)


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
NATIVE_TEST_MARKER = "841/841 native tests"
PUBLICATION_MARKER = "668 byte-identical publication members"
OWNER_EVIDENCE_MARKER = (
    "12/12 raw external owners with exact finalizer and 1000-iteration stress "
    "evidence, including one raw-result stress path that bans explicit release"
)
TESTS_EVIDENCE_MARKERS = (
    "Cairo 1.15.10",
    "Cairo 1.18.4",
    "Ubuntu 24.04 system Cairo 1.18.0",
    NATIVE_TEST_MARKER,
    "63/63 executable docs",
    "288 upstream pycairo tests across 20 families",
    "579/579 documented public declarations",
    OWNER_EVIDENCE_MARKER,
    "349-local-plus-two-direct production FFI boundary",
    "6/6 source, extracted, and unmodified cross-host archive consumer runs",
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


def script_test_evidence_marker(repo_root: pathlib.Path) -> str:
    test_dir = repo_root / "scripts" / "tests"
    suite = unittest.TestLoader().discover(
        str(test_dir),
        pattern="test_*.py",
        top_level_dir=str(test_dir),
    )
    count = suite.countTestCases()
    return f"{count}/{count} script tests"


def expected_tests_evidence(repo_root: pathlib.Path) -> str:
    return (
        "Local portable-scope evidence is complete: exact Cairo 1.15.10 and "
        f"Cairo 1.18.4 lanes pass {script_test_evidence_marker(repo_root)}, "
        f"{NATIVE_TEST_MARKER}, 63/63 executable docs, 288 upstream pycairo "
        "tests across 20 families, 579/579 documented public declarations, "
        f"{OWNER_EVIDENCE_MARKER}, the 349-local-plus-two-direct production "
        "FFI boundary, 6/6 source, extracted, and unmodified cross-host "
        "archive consumer runs, "
        f"all {PUBLICATION_MARKER}, and every "
        "discovered package under ASan/LSan/UBSan. Ubuntu 24.04 system Cairo "
        f"1.18.0 independently passes {NATIVE_TEST_MARKER} and every discovered "
        "package under ASan/LSan/UBSan. Remaining gap: GitHub run "
        "29678818105 passed macOS native but failed both Ubuntu jobs on the "
        "prior release commit. The local fix commit still needs passing Ubuntu "
        "and macOS native jobs plus the Ubuntu combined ASan/LSan/UBSan job. "
        "Do not close this row until those exact jobs pass on the release "
        "commit; local evidence alone cannot close it."
    )


def current_stability_markers(repo_root: pathlib.Path) -> tuple[str, ...]:
    return (
        (
            "Local release-candidate matrices on exact Cairo 1.15.10 and "
            f"1.18.4 pass {script_test_evidence_marker(repo_root)}, "
            f"{NATIVE_TEST_MARKER}, 63/63 executable docs, "
            f"{OWNER_EVIDENCE_MARKER}, 6/6 source, extracted, and unmodified "
            "cross-host archive consumer runs, all "
            f"{PUBLICATION_MARKER}, and every package under "
            "ASan/LSan/UBSan."
        ),
        (
            "Ubuntu 24.04 system Cairo 1.18.0 independently passes "
            f"{NATIVE_TEST_MARKER} and every package under ASan/LSan/UBSan"
        ),
        "The sole global `Partial` row is shipped test/release-platform evidence",
        (
            "GitHub run 29678818105 passed macOS native but failed both Ubuntu "
            "jobs on the prior release commit"
        ),
        (
            "local fix commit still needs passing Ubuntu and macOS native jobs "
            "plus the Ubuntu ASan/LSan/UBSan job"
        ),
    )


def expected_current_stability_evidence(repo_root: pathlib.Path) -> str:
    return (
        "Local release-candidate matrices on exact Cairo 1.15.10 and 1.18.4 "
        f"pass {script_test_evidence_marker(repo_root)}, {NATIVE_TEST_MARKER}, "
        f"63/63 executable docs, {OWNER_EVIDENCE_MARKER}, 6/6 source, "
        "extracted, and unmodified cross-host archive consumer runs, all "
        f"{PUBLICATION_MARKER}, and every "
        "package under ASan/LSan/UBSan. Ubuntu 24.04 system Cairo 1.18.0 "
        f"independently passes {NATIVE_TEST_MARKER} and every package under "
        "ASan/LSan/UBSan. The sole global `Partial` row is "
        "shipped test/release-platform evidence: GitHub run 29678818105 passed "
        "macOS native but failed both Ubuntu jobs on the prior release commit. "
        "The local fix commit still needs passing Ubuntu and macOS native jobs "
        "plus the Ubuntu ASan/LSan/UBSan job. "
        "It does not represent an unimplemented portable API family, but it must "
        "close before a full-product claim. There is still no source-compatibility "
        "promise before `1.0`."
    )


def check_inventory(
    api_inventory: pathlib.Path,
    repo_root: pathlib.Path,
) -> list[str]:
    errors: list[str] = []
    rows = list(inventory_rows(api_inventory))
    if not rows:
        return [f"{api_inventory}: no migration status rows found"]

    tests_rows = [row for row in rows if row[1] == "Tests"]
    if len(tests_rows) != 1:
        errors.append(
            f"{api_inventory}: expected exactly one Tests row; found {len(tests_rows)}"
        )
    snapshot_tests = [
        row
        for row in inventory_rows(api_inventory, "## Current Coverage Snapshot")
        if row[1] == "Tests"
    ]
    if len(snapshot_tests) != 1:
        errors.append(
            f"{api_inventory}: Current Coverage Snapshot must contain exactly "
            f"one Tests row; found {len(snapshot_tests)}"
        )
    partial_rows = [row for row in rows if row[2] == "Partial"]
    if len(partial_rows) != 1:
        errors.append(
            f"{api_inventory}: expected exactly one Partial row; "
            f"found {len(partial_rows)}"
        )

    for line_no, label, status, notes in rows:
        location = f"{api_inventory}:{line_no}: {label!r}"
        if status not in STATUSES:
            errors.append(f"{location}: unknown migration status {status!r}")
            continue
        if not notes.strip():
            errors.append(f"{location}: migration status row has no evidence notes")
        if status == "Todo":
            errors.append(
                f"{location}: Todo rows cannot pass the reliability gate; use Partial "
                "with an explicit remaining-risk note or Decision with a scope "
                "rationale"
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
            if notes != expected_tests_evidence(repo_root):
                errors.append(
                    f"{location}: Tests must match the canonical release evidence "
                    "contract exactly"
                )
            evidence_markers = (
                script_test_evidence_marker(repo_root),
                *TESTS_EVIDENCE_MARKERS,
            )
            for marker in evidence_markers:
                if marker not in notes:
                    errors.append(
                        f"{location}: current release evidence is missing {marker!r}"
                    )
    return errors


def check_testing_doc(
    testing: pathlib.Path,
    package_readme: pathlib.Path,
    repo_root: pathlib.Path,
) -> list[str]:
    text = testing.read_text(encoding="utf-8")
    package_readme_text = package_readme.read_text(encoding="utf-8")
    normalized_text = re.sub(r"\s+", " ", text)
    errors: list[str] = []
    for dimension in SCORECARD_DIMENSIONS:
        if f"| {dimension} |" not in text:
            errors.append(f"{testing}: scorecard is missing dimension {dimension!r}")

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
            errors.append(f"{testing}: missing reliability rule {phrase!r}")

    tier_three = markdown_section(text, "### Tier 3: Memory And Lifetime Tests")
    if not tier_three:
        errors.append(f"{testing}: missing Tier 3 memory and lifetime section")
    else:
        normalized_tier_three = re.sub(r"\s+", " ", tier_three)
        for marker in TIER_THREE_MARKERS:
            if marker not in normalized_tier_three:
                errors.append(f"{testing}: Tier 3 policy is missing {marker!r}")

    current_stability = markdown_section(
        package_readme_text,
        "## Current Stability",
    )
    if not current_stability:
        errors.append(
            f"{package_readme}: Current Stability heading must exist exactly once"
        )
    else:
        normalized_current_stability = re.sub(r"\s+", " ", current_stability)
        for marker in current_stability_markers(repo_root):
            if marker not in normalized_current_stability:
                errors.append(
                    f"{package_readme}: Current Stability is missing {marker!r}"
                )
        paragraphs = markdown_paragraphs(current_stability)
        expected = expected_current_stability_evidence(repo_root)
        if paragraphs.count(expected) != 1:
            errors.append(
                f"{package_readme}: Current Stability must contain exactly one "
                "canonical visible release-evidence paragraph"
            )
    return errors
