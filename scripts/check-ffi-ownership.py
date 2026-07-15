#!/usr/bin/env python3
"""Check cairoon raw C FFI declarations for ownership annotations."""

from __future__ import annotations

import pathlib
import re
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "src"
TEST_PACKAGE_ROOT = PACKAGE_ROOT / "tests"
OBJECT_TYPES = {
    "Device",
    "FontFace",
    "FontOptions",
    "Path",
    "Region",
    "ScaledFont",
    "Surface",
}
RAW_OBJECT_TYPES = {
    "RawContext",
    "RawDevice",
    "RawFontFace",
    "RawFontOptions",
    "RawImageData",
    "RawMappedImageSurface",
    "RawPath",
    "RawPattern",
    "RawRegion",
    "RawScaledFont",
    "RawSurface",
    "RawTextToGlyphs",
}


def split_top_level(text: str) -> list[str]:
    parts: list[str] = []
    start = 0
    paren_depth = 0
    bracket_depth = 0
    for index, char in enumerate(text):
        if char == "(":
            paren_depth += 1
        elif char == ")":
            paren_depth -= 1
        elif char == "[":
            bracket_depth += 1
        elif char == "]":
            bracket_depth -= 1
        elif char == "," and paren_depth == 0 and bracket_depth == 0:
            part = text[start:index].strip()
            if part:
                parts.append(part)
            start = index + 1
    tail = text[start:].strip()
    if tail:
        parts.append(tail)
    return parts


def parameter_list(signature: str) -> str:
    match = re.search(r'\bfn\s+[A-Za-z0-9_]+\s*\(', signature)
    if match is None:
        raise ValueError("cannot find extern function parameter list")
    start = signature.find("(", match.start())
    depth = 0
    for index in range(start, len(signature)):
        char = signature[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return signature[start + 1 : index]
    raise ValueError("unterminated extern function parameter list")


def parse_annotation(line: str) -> tuple[str, set[str]] | None:
    stripped = line.strip()
    match = re.match(r"#(borrow|owned)\(([^)]*)\)$", stripped)
    if match is None:
        return None
    names = {name.strip() for name in match.group(2).split(",") if name.strip()}
    return match.group(1), names


def parse_params(signature: str) -> dict[str, str]:
    params: dict[str, str] = {}
    for part in split_top_level(parameter_list(signature)):
        if ":" not in part:
            continue
        name, type_ = part.split(":", 1)
        params[name.strip()] = " ".join(type_.split())
    return params


def requires_annotation(type_: str) -> bool:
    head = re.split(r"[\s\[\(]", type_, maxsplit=1)[0]
    base = head.rsplit(".", maxsplit=1)[-1]
    if base in OBJECT_TYPES or base in RAW_OBJECT_TYPES:
        return True
    return (
        "Bytes" in type_
        or "String" in type_
        or "Ref[" in type_
        or "FixedArray[" in type_
        or "FuncRef[" in type_
        or "->" in type_
    )


def collect_extern(lines: list[str], start: int) -> tuple[str, int]:
    parts = []
    index = start
    while index < len(lines):
        parts.append(lines[index].strip())
        if "=" in lines[index]:
            break
        index += 1
    return " ".join(parts), index


def check_file(path: pathlib.Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    pending: list[tuple[int, str, set[str]]] = []
    errors: list[str] = []
    index = 0
    while index < len(lines):
        stripped = lines[index].strip()
        if stripped == "///|":
            pending = []
        else:
            parsed = parse_annotation(stripped)
            if parsed is not None:
                kind, names = parsed
                pending.append((index + 1, kind, names))
            elif 'extern "C" fn' in stripped:
                signature, end = collect_extern(lines, index)
                try:
                    params = parse_params(signature)
                except ValueError as exc:
                    errors.append(f"{path}:{index + 1}: {exc}")
                    index = end
                    continue
                annotated = set()
                for _, _, names in pending:
                    annotated.update(names)
                for name, type_ in params.items():
                    if requires_annotation(type_) and name not in annotated:
                        errors.append(
                            f"{path}:{index + 1}: parameter '{name}' of type "
                            f"'{type_}' needs #borrow or #owned"
                        )
                for line_no, kind, names in pending:
                    for name in names:
                        if name not in params:
                            errors.append(
                                f"{path}:{line_no}: #{kind} references unknown "
                                f"parameter '{name}'"
                            )
                pending = []
                index = end
        index += 1
    return errors


def extern_symbols(path: pathlib.Path) -> list[tuple[str, int]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    symbols: list[tuple[str, int]] = []
    index = 0
    while index < len(lines):
        if 'extern "C" fn' not in lines[index]:
            index += 1
            continue
        signature, end = collect_extern(lines, index)
        match = re.search(r'=\s*"([^"]+)"', signature)
        if match is not None:
            symbols.append((match.group(1), index + 1))
        index = end + 1
    return symbols


def iter_production_ffi_files() -> list[pathlib.Path]:
    return [
        path
        for path in sorted(PACKAGE_ROOT.rglob("ffi*.mbt"))
        if TEST_PACKAGE_ROOT not in path.parents
    ]


def main() -> int:
    errors: list[str] = []
    files = iter_production_ffi_files()
    declarations: dict[str, list[str]] = {}
    for path in files:
        errors.extend(check_file(path))
        for symbol, line_no in extern_symbols(path):
            declarations.setdefault(symbol, []).append(f"{path}:{line_no}")
    for symbol, locations in sorted(declarations.items()):
        if len(locations) > 1:
            errors.append(
                f"C symbol '{symbol}' is declared more than once: "
                + ", ".join(locations)
            )
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(
        "FFI ownership annotations and C symbol uniqueness ok in "
        f"{len(files)} production files"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
