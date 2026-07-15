#!/usr/bin/env python3
"""Audit substantive MoonBit doc comments on cairoon's public API."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import pathlib
import re
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "src"
DEBT_LEDGER = REPO_ROOT / "scripts" / "public-docs-debt.txt"
REEXPORTED_SOURCES = (PACKAGE_ROOT / "core" / "glyph" / "glyph.mbt",)

FUNCTION_RE = re.compile(
    r"^pub\s+fn(?:\[[^]]+\])?\s+"
    r"([A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)?)\s*\("
)
VALUE_RE = re.compile(r"^pub\s+(?:const|let)\s+([A-Za-z_][A-Za-z0-9_]*)\b")
TYPE_RE = re.compile(
    r"^pub(?:\(all\))?\s+(?:enum|struct|type|suberror|trait)\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\b"
)
DEBT_ENTRY_RE = re.compile(
    r"^[^\t]+\t[A-Za-z_][A-Za-z0-9_]*"
    r"(?:::[A-Za-z_][A-Za-z0-9_]*)?$"
)


@dataclass(frozen=True)
class PublicItem:
    path: pathlib.Path
    symbol: str
    line: int
    documented: bool

    @property
    def key(self) -> str:
        return f"{self.path.as_posix()}\t{self.symbol}"


def public_sources() -> list[pathlib.Path]:
    return sorted(PACKAGE_ROOT.glob("*.mbt")) + list(REEXPORTED_SOURCES)


def declaration_symbol(line: str) -> str | None:
    stripped = line.strip()
    for pattern in (FUNCTION_RE, VALUE_RE, TYPE_RE):
        match = pattern.match(stripped)
        if match is not None:
            return match.group(1)
    return None


def has_substantive_doc(lines: list[str], declaration_index: int) -> bool:
    index = declaration_index - 1
    while index >= 0 and lines[index].lstrip().startswith("#"):
        index -= 1

    found_doc_line = False
    while index >= 0 and lines[index].lstrip().startswith("///"):
        content = lines[index].lstrip()[3:].strip()
        if content not in {"", "|"}:
            found_doc_line = True
        index -= 1
    return found_doc_line


def public_items(
    path: pathlib.Path,
    repo_root: pathlib.Path = REPO_ROOT,
) -> list[PublicItem]:
    lines = path.read_text(encoding="utf-8").splitlines()
    relative = path.relative_to(repo_root)
    items: list[PublicItem] = []
    for index, line in enumerate(lines):
        symbol = declaration_symbol(line)
        if symbol is None:
            continue
        items.append(
            PublicItem(
                path=relative,
                symbol=symbol,
                line=index + 1,
                documented=has_substantive_doc(lines, index),
            )
        )
    return items


def all_public_items() -> list[PublicItem]:
    return [item for path in public_sources() for item in public_items(path)]


def read_debt_ledger(path: pathlib.Path = DEBT_LEDGER) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    if not path.is_file():
        return [], [f"missing public documentation debt ledger: {path}"]
    entries = [
        line
        for raw_line in path.read_text(encoding="utf-8").splitlines()
        if (line := raw_line.strip()) and not line.startswith("#")
    ]
    if entries != sorted(entries):
        errors.append("public documentation debt ledger must be sorted")
    duplicates = sorted({entry for entry in entries if entries.count(entry) > 1})
    if duplicates:
        errors.append("duplicate public documentation debt entries: " + ", ".join(duplicates))
    malformed = sorted(entry for entry in entries if DEBT_ENTRY_RE.fullmatch(entry) is None)
    if malformed:
        errors.append("malformed public documentation debt entries: " + ", ".join(malformed))
    return entries, errors


def check_debt(items: list[PublicItem], entries: list[str]) -> list[str]:
    undocumented = {item.key for item in items if not item.documented}
    ledger = set(entries)
    errors: list[str] = []
    missing = sorted(undocumented - ledger)
    stale = sorted(ledger - undocumented)
    if missing:
        errors.append(
            "undocumented public declarations missing from debt ledger: "
            + ", ".join(missing)
        )
    if stale:
        errors.append(
            "stale public documentation debt entries: " + ", ".join(stale)
        )
    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--print-undocumented",
        action="store_true",
        help="print the exact sorted debt ledger body without validating it",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    items = all_public_items()
    undocumented = sorted(item.key for item in items if not item.documented)
    if args.print_undocumented:
        print("\n".join(undocumented))
        return 0

    entries, errors = read_debt_ledger()
    errors.extend(check_debt(items, entries))
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(
        "Public documentation ledger covers "
        f"{len(items) - len(undocumented)} documented declarations and "
        f"{len(undocumented)} exact debt entries across {len(public_sources())} files"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
