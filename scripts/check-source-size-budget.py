#!/usr/bin/env python3
"""Keep cairoon source files small enough to review and split."""

from __future__ import annotations

import pathlib
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
MAX_SOURCE_LINES = 900
SOURCE_SUFFIXES = (".mbt", ".mbt.md", ".c", ".h", ".py", ".sh")
SEARCH_ROOTS = (REPO_ROOT / "src", REPO_ROOT / "scripts")


def is_checked_source(path: pathlib.Path) -> bool:
    return path.is_file() and any(
        path.name.endswith(suffix) for suffix in SOURCE_SUFFIXES
    )


def line_count(path: pathlib.Path) -> int:
    return len(path.read_text(encoding="utf-8").splitlines())


def main() -> int:
    oversized: list[tuple[int, pathlib.Path]] = []
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
            if lines > MAX_SOURCE_LINES:
                oversized.append((lines, path))

    if oversized:
        for lines, path in oversized:
            rel = path.relative_to(REPO_ROOT)
            print(
                f"{rel}: {lines} lines exceeds the {MAX_SOURCE_LINES}-line source budget",
                file=sys.stderr,
            )
        return 1

    largest_text = "none"
    if largest is not None:
        largest_text = f"{largest[1].relative_to(REPO_ROOT)} ({largest[0]} lines)"
    print(
        f"Source size budget ok; {checked} source files checked; largest {largest_text}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
