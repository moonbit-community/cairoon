#!/usr/bin/env python3
"""Keep cairoon source files small enough to review and split."""

from __future__ import annotations

import pathlib
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
MAX_SOURCE_LINES = 600
MAX_HISTORY_DOCUMENT_LINES = 600
MAX_DOCUMENT_LINES = 1000
MAX_AGENTS_LINES = 1500
SOURCE_SUFFIXES = (".mbt", ".mbt.md", ".c", ".h", ".py", ".sh")
SEARCH_ROOTS = (
    REPO_ROOT / "src",
    REPO_ROOT / "scripts",
    REPO_ROOT / "integration" / "consumer" / "src",
)
EXCLUDED_PARTS = frozenset({".git", ".mooncakes", "_build"})


def is_checked_source(path: pathlib.Path) -> bool:
    return path.is_file() and any(
        path.name.endswith(suffix) for suffix in SOURCE_SUFFIXES
    )


def is_checked_document(path: pathlib.Path) -> bool:
    return (
        path.is_file()
        and path.name.endswith(".md")
        and not path.name.endswith(".mbt.md")
        and not EXCLUDED_PARTS.intersection(path.parts)
    )


def line_count(path: pathlib.Path) -> int:
    return len(path.read_text(encoding="utf-8").splitlines())


def source_line_budget(_path: pathlib.Path) -> int:
    return MAX_SOURCE_LINES


def source_size_violation(
    path: pathlib.Path,
    lines: int | None = None,
) -> tuple[int, int] | None:
    if lines is None:
        lines = line_count(path)
    budget = source_line_budget(path)
    if lines > budget:
        return lines, budget
    return None


def document_line_budget(path: pathlib.Path) -> int:
    if path.name == "AGENTS.md":
        return MAX_AGENTS_LINES
    if "docs" in path.parts:
        return MAX_HISTORY_DOCUMENT_LINES
    return MAX_DOCUMENT_LINES


def document_size_violation(
    path: pathlib.Path,
    lines: int | None = None,
) -> tuple[int, int] | None:
    if lines is None:
        lines = line_count(path)
    budget = document_line_budget(path)
    if lines > budget:
        return lines, budget
    return None


def main() -> int:
    oversized: list[tuple[str, int, int, pathlib.Path]] = []
    checked_sources = 0
    checked_documents = 0
    largest_source: tuple[int, pathlib.Path] | None = None
    largest_document: tuple[int, pathlib.Path] | None = None

    for root in SEARCH_ROOTS:
        for path in sorted(root.rglob("*")):
            if "_build" in path.parts or ".git" in path.parts:
                continue
            if not is_checked_source(path):
                continue
            checked_sources += 1
            lines = line_count(path)
            if largest_source is None or lines > largest_source[0]:
                largest_source = (lines, path)
            violation = source_size_violation(path, lines)
            if violation is not None:
                oversized.append(("source", *violation, path))

    for path in sorted(REPO_ROOT.rglob("*.md")):
        if not is_checked_document(path):
            continue
        checked_documents += 1
        lines = line_count(path)
        if largest_document is None or lines > largest_document[0]:
            largest_document = (lines, path)
        violation = document_size_violation(path, lines)
        if violation is not None:
            oversized.append(("document", *violation, path))

    if oversized:
        for kind, lines, budget, path in oversized:
            rel = path.relative_to(REPO_ROOT)
            print(
                f"{rel}: {lines} lines exceeds the {budget}-line {kind} budget",
                file=sys.stderr,
            )
        return 1

    largest_source_text = "none"
    if largest_source is not None:
        largest_source_text = (
            f"{largest_source[1].relative_to(REPO_ROOT)} "
            f"({largest_source[0]} lines)"
        )
    largest_document_text = "none"
    if largest_document is not None:
        largest_document_text = (
            f"{largest_document[1].relative_to(REPO_ROOT)} "
            f"({largest_document[0]} lines)"
        )
    print(
        f"Size budgets ok; {checked_sources} source files checked at "
        f"{MAX_SOURCE_LINES} lines; {checked_documents} Markdown files checked; "
        f"largest source {largest_source_text}; "
        f"largest document {largest_document_text}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
