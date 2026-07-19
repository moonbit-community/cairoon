"""Shared source and package-config parsing for project-layout audits."""

from __future__ import annotations

import pathlib
import re


SOURCE_SUFFIXES = (".mbt.md", ".mbti", ".mbt", ".c", ".h")
PACKAGE_CONFIG_NAMES = {"moon.pkg"}
NATIVE_TARGETS = {"native"}
STRICT_STUB_CFLAGS = (
    '"stub-cc-flags": "${build.CAIRO_CFLAGS} '
    '-std=c11 -Wall -Wextra -Wpedantic -Werror"'
)


def is_source_like(path: pathlib.Path) -> bool:
    name = path.name
    return any(name.endswith(suffix) for suffix in SOURCE_SUFFIXES)


def is_public_root_file(path: pathlib.Path) -> bool:
    return is_source_like(path) or path.name in PACKAGE_CONFIG_NAMES


def read_filename_allowlist(path: pathlib.Path, label: str) -> set[str]:
    allowed: set[str] = set()
    for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "/" in stripped or "\\" in stripped:
            raise ValueError(
                f"{path}:{line_no}: {label} allowlist entries must be filenames"
            )
        allowed.add(stripped)
    return allowed


def read_native_stubs(package_config: pathlib.Path) -> set[str]:
    text = package_config.read_text(encoding="utf-8")
    marker = '"native-stub"'
    start = text.find(marker)
    if start == -1:
        return set()
    open_bracket = text.find("[", start)
    close_bracket = text.find("]", open_bracket)
    if open_bracket == -1 or close_bracket == -1:
        return set()
    block = text[open_bracket:close_bracket]
    return set(re.findall(r'"([^"]+\.c)"', block))


def read_native_targets(package_config: pathlib.Path) -> dict[str, set[str]]:
    text = package_config.read_text(encoding="utf-8")
    return {
        name: set(re.findall(r'"([^"]+)"', targets))
        for name, targets in re.findall(
            r'"([^"]+\.mbt)"\s*:\s*\[([^\]]*)\]',
            text,
        )
    }


def count_files(path: pathlib.Path, pattern: str) -> int:
    return sum(1 for child in path.glob(pattern) if child.is_file())


def count_recursive_files(path: pathlib.Path, pattern: str) -> int:
    return sum(1 for child in path.rglob(pattern) if child.is_file())
