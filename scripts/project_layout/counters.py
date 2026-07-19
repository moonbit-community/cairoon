"""Executable PROJECT_LAYOUT.md file-count audits."""

from __future__ import annotations

import pathlib
import re

from .common import count_files, count_recursive_files


def checked_package_count_paths(
    repo_root: pathlib.Path,
    package_root: pathlib.Path,
    counted_package_roots: tuple[pathlib.Path, ...],
) -> list[str]:
    """Return support/implementation package paths that need layout counters."""
    package_dirs: list[pathlib.Path] = []
    for root in counted_package_roots:
        if not root.exists():
            continue
        package_dirs.extend(
            path.parent
            for path in root.rglob("moon.pkg")
            if path.parent != package_root
        )
    return [
        str(path.relative_to(repo_root))
        for path in sorted(package_dirs, key=lambda item: item.relative_to(repo_root))
    ]


def require_layout_count(
    layout_doc: pathlib.Path,
    text: str,
    label: str,
    pattern: str,
    expected: dict[str, int],
) -> list[str]:
    match = re.search(pattern, text, re.DOTALL)
    if match is None:
        return [f"{layout_doc}: missing Current Layout counter for {label}"]

    errors: list[str] = []
    for name, value in expected.items():
        actual = int(match.group(name))
        if actual != value:
            errors.append(
                f"{layout_doc}: stale Current Layout counter for {label}: "
                f"{name} says {actual}, actual is {value}"
            )
    return errors


def check_layout_counters(
    repo_root: pathlib.Path,
    package_root: pathlib.Path,
    doc_package_dir: pathlib.Path,
    test_package_root: pathlib.Path,
    native_package_dir: pathlib.Path,
    layout_doc: pathlib.Path,
    counted_package_roots: tuple[pathlib.Path, ...],
) -> list[str]:
    text = layout_doc.read_text(encoding="utf-8")
    errors: list[str] = []

    errors.extend(
        require_layout_count(
            layout_doc,
            text,
            "direct src implementation files",
            r"- (?P<count>\d+) `\.mbt` implementation files directly in `src/`\.",
            {"count": count_files(package_root, "*.mbt")},
        )
    )
    errors.extend(
        require_layout_count(
            layout_doc,
            text,
            "executable reference package",
            r"- (?P<prelude>\d+) `\.mbt` prelude file and "
            r"(?P<docs>\d+) executable `\.mbt\.md` docs in `src/docs/`\.",
            {
                "prelude": count_files(doc_package_dir, "*.mbt"),
                "docs": count_files(doc_package_dir, "*.mbt.md"),
            },
        )
    )

    for rel_path in checked_package_count_paths(
        repo_root,
        package_root,
        counted_package_roots,
    ):
        package_dir = repo_root / rel_path
        escaped = re.escape(rel_path + "/")
        implementation_count = count_files(package_dir, "*.mbt") - count_files(
            package_dir,
            "*_test.mbt",
        )
        errors.extend(
            require_layout_count(
                layout_doc,
                text,
                rel_path,
                rf"- (?P<impl>\d+) `\.mbt` implementation files? and "
                rf"(?P<test>\d+) package-local `\*_test\.mbt` files? in\s+"
                rf"`{escaped}`\.",
                {
                    "impl": implementation_count,
                    "test": count_files(package_dir, "*_test.mbt"),
                },
            )
        )

    counter_specs = [
        (
            "native package MoonBit anchor",
            r"- (?P<count>\d+) native-package MoonBit anchor file in `src/native/`\.",
            {"count": count_files(native_package_dir, "*.mbt")},
        ),
        (
            "src tests",
            r"- (?P<count>\d+) `\*_test\.mbt` files under `src/tests/`",
            {"count": count_recursive_files(test_package_root, "*_test.mbt")},
        ),
        (
            "white-box tests",
            r"- (?P<count>\d+) white-box `\*_wbtest\.mbt` files in `src/`\.",
            {"count": count_files(package_root, "*_wbtest.mbt")},
        ),
        (
            "public C implementation files",
            r"- (?P<count>\d+) public C implementation files owned by "
            r"`src/native/moon\.pkg`\.",
            {"count": count_files(native_package_dir, "*.c")},
        ),
        (
            "public C headers",
            r"- (?P<count>\d+) public C header in `src/native/`\.",
            {"count": count_files(native_package_dir, "*.h")},
        ),
        (
            "oracle C implementation files",
            r"- (?P<count>\d+) oracle C implementation files in "
            r"`src/tests/oracle/native/`\.",
            {"count": count_files(test_package_root / "oracle/native", "*.c")},
        ),
        (
            "oracle C headers",
            r"- (?P<count>\d+) oracle C headers in `src/tests/oracle/native/`\.",
            {"count": count_files(test_package_root / "oracle/native", "*.h")},
        ),
        (
            "executable docs",
            r"- (?P<count>\d+) executable `\.mbt\.md` docs? in `src/`\.",
            {"count": count_files(package_root, "*.mbt.md")},
        ),
    ]
    for label, pattern, expected in counter_specs:
        errors.extend(
            require_layout_count(
                layout_doc,
                text,
                label,
                pattern,
                expected,
            )
        )

    return errors
