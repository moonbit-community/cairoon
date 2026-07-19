#!/usr/bin/env python3
"""Keep cairoon source files small enough to review and split."""

from __future__ import annotations

import pathlib
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
MAX_SOURCE_LINES = 600
SOURCE_SUFFIXES = (".mbt", ".mbt.md", ".c", ".h", ".py", ".sh")
SEARCH_ROOTS = (
    REPO_ROOT / "src",
    REPO_ROOT / "scripts",
    REPO_ROOT / "integration" / "consumer" / "src",
)


def is_checked_source(path: pathlib.Path) -> bool:
    return path.is_file() and any(
        path.name.endswith(suffix) for suffix in SOURCE_SUFFIXES
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


def main() -> int:
    oversized: list[tuple[int, int, pathlib.Path]] = []
    checked = 0
    largest: tuple[int, pathlib.Path] | None = None

    for root in SEARCH_ROOTS:
        for path in sorted(root.rglob("*")):
            if "_build" in path.parts or ".git" in path.parts:
                continue
            if not is_checked_source(path):
                continue
            checked += 1
            lines = line_count(path)
            if largest is None or lines > largest[0]:
                largest = (lines, path)
            violation = source_size_violation(path, lines)
            if violation is not None:
                oversized.append((*violation, path))

    if oversized:
        for lines, budget, path in oversized:
            rel = path.relative_to(REPO_ROOT)
            print(
                f"{rel}: {lines} lines exceeds the {budget}-line source budget",
                file=sys.stderr,
            )
        return 1

    largest_text = "none"
    if largest is not None:
        largest_text = f"{largest[1].relative_to(REPO_ROOT)} ({largest[0]} lines)"
    print(
        f"Source size budget ok; {checked} source files checked; "
        f"limit is {MAX_SOURCE_LINES} lines; "
        f"largest {largest_text}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
