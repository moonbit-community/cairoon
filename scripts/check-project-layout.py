#!/usr/bin/env python3
"""Check cairoon's package layout migration rules."""

from __future__ import annotations

import pathlib
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
ALLOWLIST = REPO_ROOT / "scripts" / "root-layout-allowlist.txt"
LAYOUT_DOC = REPO_ROOT / "PROJECT_LAYOUT.md"
SOURCE_SUFFIXES = (".mbt.md", ".mbti", ".mbt", ".c", ".h")


def is_source_like(path: pathlib.Path) -> bool:
    name = path.name
    return any(name.endswith(suffix) for suffix in SOURCE_SUFFIXES)


def read_allowlist() -> set[str]:
    allowed: set[str] = set()
    for line_no, line in enumerate(ALLOWLIST.read_text(encoding="utf-8").splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "/" in stripped or "\\" in stripped:
            raise ValueError(
                f"{ALLOWLIST}:{line_no}: root allowlist entries must be filenames"
            )
        allowed.add(stripped)
    return allowed


def check_root_freeze(allowed: set[str]) -> list[str]:
    errors: list[str] = []
    root_source = sorted(
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file() and is_source_like(path)
    )
    unexpected = [name for name in root_source if name not in allowed]
    if unexpected:
        errors.append(
            "new root source-like files are forbidden; move them into a package "
            "or update PROJECT_LAYOUT.md intentionally: " + ", ".join(unexpected)
        )
    return errors


def check_nested_c_files() -> list[str]:
    errors: list[str] = []
    for path in sorted(REPO_ROOT.rglob("*")):
        if not path.is_file() or path.parent == REPO_ROOT:
            continue
        if path.suffix not in {".c", ".h"}:
            continue
        if ".git" in path.parts or "_build" in path.parts:
            continue
        if not (path.parent / "moon.pkg").exists():
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: nested C files must live beside "
                "the moon.pkg that owns their native-stub entry"
            )
    return errors


def main() -> int:
    errors: list[str] = []
    if not LAYOUT_DOC.exists():
        errors.append(f"{LAYOUT_DOC}: missing package layout plan")
    if not ALLOWLIST.exists():
        errors.append(f"{ALLOWLIST}: missing root source allowlist")
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    try:
        allowed = read_allowlist()
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    errors.extend(check_root_freeze(allowed))
    errors.extend(check_nested_c_files())
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    current = {
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file() and is_source_like(path) and path.name in allowed
    }
    print(
        "Project layout ok; "
        f"{len(current)} grandfathered root source files remain"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
