#!/usr/bin/env python3
"""Audit intentional uncovered lines in the public cairoon package."""

from __future__ import annotations

import argparse
import pathlib
import re
import subprocess
import sys
from collections.abc import Sequence
from typing import NamedTuple


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
LEDGER = REPO_ROOT / "scripts" / "public-coverage-exceptions.tsv"
PACKAGE = "CAIMEOX/cairoon"

FUNCTION_RE = re.compile(
    r"^\s*(?:pub(?:\([^)]*\))?\s+)?fn(?:\[[^]]+\])?\s+"
    r"([A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)?)"
)
FILE_RE = re.compile(r"^(\d+) uncovered line\(s\) in (.+):$")
UNCOVERED_RE = re.compile(r"^\s*(\d+)\s+(.*?)\s*<-- UNCOVERED\s*$")
UNCOVERED_MARKER_RE = re.compile(r"<--\s*UNCOVERED\b")
ALLOWED_CATEGORIES = {
    "backend-dependent-output",
    "defensive-native-value",
    "linked-cairo-version",
    "native-result-invariant",
    "platform-backend",
    "platform-status",
}
SCOPE_TERM_RE = re.compile(r"^cairo(>=|==|!=|<)(\d+)\.(\d+)\.(\d+)$")
Version = tuple[int, int, int]
ScopeTerm = tuple[str, Version]
ScopeExpression = tuple[tuple[ScopeTerm, ...], ...]


class CoverageKey(NamedTuple):
    path: str
    symbol: str
    code: str


class CoverageException(NamedTuple):
    key: CoverageKey
    category: str
    reason: str
    scope: str = "all"


def normalize_code(code: str) -> str:
    return " ".join(code.strip().split())


def is_public_facade_source(relative: str) -> bool:
    path = pathlib.PurePosixPath(relative)
    return path.parent == pathlib.PurePosixPath("src") and path.suffix == ".mbt"


def safe_source_path(root: pathlib.Path, relative: str) -> pathlib.Path:
    root = root.resolve()
    source = (root / relative).resolve()
    if not source.is_relative_to(root):
        raise ValueError(f"coverage path escapes repository: {relative!r}")
    return source


def enclosing_symbol(lines: Sequence[str], line_no: int) -> str:
    for index in range(line_no - 1, -1, -1):
        match = FUNCTION_RE.match(lines[index])
        if match:
            return match.group(1)
    raise ValueError(f"line {line_no} has no enclosing MoonBit function")


def parse_coverage_report(report: str, root: pathlib.Path) -> list[CoverageKey]:
    current_path: str | None = None
    declared_count = 0
    parsed_count = 0
    source_cache: dict[str, list[str]] = {}
    actual: list[CoverageKey] = []

    def validate_section() -> None:
        if current_path is not None and parsed_count != declared_count:
            raise ValueError(
                f"{current_path}: coverage heading declares {declared_count} "
                f"uncovered lines but parsed {parsed_count}"
            )

    for report_line in report.splitlines():
        file_match = FILE_RE.match(report_line)
        if file_match:
            validate_section()
            declared_count = int(file_match.group(1))
            current_path = file_match.group(2)
            parsed_count = 0
            continue

        uncovered_match = UNCOVERED_RE.match(report_line)
        if not uncovered_match:
            if UNCOVERED_MARKER_RE.search(report_line):
                raise ValueError(f"malformed uncovered source line: {report_line!r}")
            continue
        if current_path is None:
            raise ValueError("uncovered source line appeared before a file heading")
        if not is_public_facade_source(current_path):
            raise ValueError(
                f"coverage report path is outside public facade: {current_path!r}"
            )

        line_no = int(uncovered_match.group(1))
        report_code = normalize_code(uncovered_match.group(2))
        if current_path not in source_cache:
            source = safe_source_path(root, current_path)
            source_cache[current_path] = source.read_text(encoding="utf-8").splitlines()
        lines = source_cache[current_path]
        if line_no < 1 or line_no > len(lines):
            raise ValueError(f"{current_path}:{line_no}: line is outside the source file")
        source_code = normalize_code(lines[line_no - 1])
        if source_code != report_code:
            raise ValueError(
                f"{current_path}:{line_no}: report/source mismatch: "
                f"{report_code!r} != {source_code!r}"
            )
        actual.append(
            CoverageKey(
                current_path,
                enclosing_symbol(lines, line_no),
                source_code,
            )
        )
        parsed_count += 1

    validate_section()
    if len(actual) != len(set(actual)):
        raise ValueError("coverage report contains duplicate stable keys")
    return actual


def parse_ledger(path: pathlib.Path = LEDGER) -> list[CoverageException]:
    entries: list[CoverageException] = []
    seen: set[CoverageKey] = set()
    for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        fields = line.split("\t")
        if len(fields) != 6:
            raise ValueError(
                f"{path}:{line_no}: expected six tab-separated fields, got {len(fields)}"
            )
        relative, symbol, code, category, scope, reason = fields
        key = CoverageKey(relative, symbol, normalize_code(code))
        if key in seen:
            raise ValueError(f"{path}:{line_no}: duplicate coverage key {format_key(key)}")
        seen.add(key)
        entries.append(CoverageException(key, category, reason.strip(), scope))
    return entries


def format_key(key: CoverageKey) -> str:
    return f"{key.path}::{key.symbol}::{key.code}"


def source_anchor_count(key: CoverageKey, root: pathlib.Path) -> int:
    source = safe_source_path(root, key.path)
    if not source.is_file():
        return 0
    lines = source.read_text(encoding="utf-8").splitlines()
    count = 0
    for line_no, line in enumerate(lines, 1):
        if normalize_code(line) != key.code:
            continue
        if enclosing_symbol(lines, line_no) == key.symbol:
            count += 1
    return count


def parse_scope(scope: str) -> ScopeExpression | None:
    if scope == "all":
        return None
    alternatives: list[tuple[ScopeTerm, ...]] = []
    for clause in scope.split("|"):
        terms: list[ScopeTerm] = []
        for term in clause.split(","):
            match = SCOPE_TERM_RE.fullmatch(term)
            if match is None:
                raise ValueError(f"unknown version scope {scope!r}")
            operator = match.group(1)
            version: Version = tuple(
                int(component) for component in match.groups()[1:]
            )
            terms.append((operator, version))
        alternatives.append(tuple(terms))
    return tuple(alternatives)


def scope_applies(scope: str, cairo_version: tuple[int, int, int]) -> bool:
    parsed = parse_scope(scope)
    if parsed is None:
        return True

    def term_applies(term: ScopeTerm) -> bool:
        operator, threshold = term
        if operator == "<":
            return cairo_version < threshold
        if operator == ">=":
            return cairo_version >= threshold
        if operator == "==":
            return cairo_version == threshold
        return cairo_version != threshold

    return any(all(term_applies(term) for term in clause) for clause in parsed)


def check_ledger(
    entries: Sequence[CoverageException],
    root: pathlib.Path = REPO_ROOT,
) -> list[str]:
    errors: list[str] = []
    seen: set[CoverageKey] = set()
    for entry in entries:
        key = entry.key
        if key in seen:
            errors.append(f"duplicate coverage key: {format_key(key)}")
        seen.add(key)
        if entry.category not in ALLOWED_CATEGORIES:
            errors.append(
                f"{format_key(key)}: unknown exception category {entry.category!r}"
            )
        try:
            parse_scope(entry.scope)
        except ValueError as error:
            errors.append(f"{format_key(key)}: {error}")
        if len(entry.reason) < 20:
            errors.append(f"{format_key(key)}: exception reason is not substantive")
        if not is_public_facade_source(key.path):
            errors.append(f"{format_key(key)}: source is outside public facade src/*.mbt")
            continue
        try:
            anchor_count = source_anchor_count(key, root)
        except (OSError, ValueError) as error:
            errors.append(f"{format_key(key)}: cannot validate source anchor: {error}")
            continue
        if anchor_count == 0:
            errors.append(f"{format_key(key)}: source anchor no longer exists")
        elif anchor_count > 1:
            errors.append(
                f"{format_key(key)}: source anchor is not unique ({anchor_count} matches)"
            )
    return errors


def compare_coverage(
    actual: Sequence[CoverageKey],
    expected: Sequence[CoverageException],
) -> list[str]:
    actual_keys = set(actual)
    expected_keys = {entry.key for entry in expected}
    errors = [
        f"unexpected uncovered line: {format_key(key)}"
        for key in sorted(actual_keys - expected_keys)
    ]
    errors.extend(
        f"stale coverage exception: {format_key(key)}"
        for key in sorted(expected_keys - actual_keys)
    )
    return errors


def parse_cairo_version(raw: str) -> tuple[int, int, int]:
    match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)(?:[.-].*)?", raw.strip())
    if match is None:
        raise ValueError(f"invalid Cairo version from pkg-config: {raw.strip()!r}")
    return tuple(int(component) for component in match.groups())


def linked_cairo_version() -> tuple[int, int, int]:
    completed = subprocess.run(
        ["pkg-config", "--modversion", "cairo"],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if completed.returncode != 0:
        detail = completed.stderr.strip() or "pkg-config failed without diagnostics"
        raise RuntimeError(f"cannot determine linked Cairo version: {detail}")
    return parse_cairo_version(completed.stdout)


def active_exceptions(
    entries: Sequence[CoverageException],
    cairo_version: tuple[int, int, int],
) -> list[CoverageException]:
    return [entry for entry in entries if scope_applies(entry.scope, cairo_version)]


def analyze_coverage() -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["moon", "coverage", "analyze", "-p", PACKAGE],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def print_errors(errors: Sequence[str]) -> None:
    for error in errors:
        print(error, file=sys.stderr)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--analyze",
        action="store_true",
        help="run instrumented MoonBit tests and compare actual uncovered lines",
    )
    args = parser.parse_args()

    try:
        entries = parse_ledger()
        errors = check_ledger(entries)
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1
    if errors:
        print_errors(errors)
        return 1

    if not args.analyze:
        print(f"Public coverage ledger ok; {len(entries)} source anchors are current")
        return 0

    try:
        cairo_version = linked_cairo_version()
        expected = active_exceptions(entries, cairo_version)
    except (RuntimeError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1

    completed = analyze_coverage()
    if completed.returncode != 0:
        sys.stdout.write(completed.stdout)
        sys.stderr.write(completed.stderr)
        return completed.returncode
    try:
        actual = parse_coverage_report(completed.stdout, REPO_ROOT)
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 1
    errors = compare_coverage(actual, expected)
    if errors:
        print_errors(errors)
        return 1
    print(
        f"Public package coverage ok; {len(actual)} intentional uncovered lines "
        f"match the Cairo {'.'.join(str(part) for part in cairo_version)} profile"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
