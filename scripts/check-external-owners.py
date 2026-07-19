#!/usr/bin/env python3
"""Enforce one native finalizer and sanitizer stress path per raw owner."""

from __future__ import annotations

import json
import pathlib
import re
import sys
from typing import Any


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
LEDGER = REPO_ROOT / "scripts" / "lifetime" / "owners.json"
OBJECTS_C = "src/native/cairoon_objects.c"
LEDGER_KEYS = {
    "raw_type",
    "ffi_path",
    "c_struct",
    "finalizer",
    "release_anchors",
    "stress_path",
    "stress_test",
    "stress_helper",
    "allocation_anchor",
    "forbidden_stress_anchors",
}
RAW_TYPE_RE = re.compile(
    r"^[ \t]*type[ \t]+(Raw[A-Za-z0-9_]+)\b[^\r\n]*$",
    re.M,
)
FINALIZER_RE = re.compile(r"\bstatic\s+void\s+(cairoon_[a-z0-9_]+_finalize)\s*\(")
ALLOCATION_RE = re.compile(
    r"moonbit_make_external_object\s*\(\s*"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*,\s*"
    r"sizeof\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)\s*\)",
    re.S,
)


def mask_noncode(source: str, *, mask_literals: bool) -> str:
    """Blank comments and optionally literals without moving source offsets."""
    masked = list(source)
    index = 0
    quote: str | None = None
    while index < len(source):
        char = source[index]
        if quote is not None:
            if mask_literals and char not in "\r\n":
                masked[index] = " "
            if char == "\\" and index + 1 < len(source):
                index += 1
                if mask_literals and source[index] not in "\r\n":
                    masked[index] = " "
            elif char == quote:
                quote = None
            index += 1
            continue
        if source.startswith("//", index):
            while index < len(source) and source[index] not in "\r\n":
                masked[index] = " "
                index += 1
            continue
        if source.startswith("/*", index):
            comment_depth = 0
            while index < len(source):
                if source.startswith("/*", index):
                    comment_depth += 1
                    masked[index] = " "
                    if index + 1 < len(source):
                        masked[index + 1] = " "
                    index += 2
                    continue
                if source.startswith("*/", index):
                    comment_depth -= 1
                    masked[index] = " "
                    if index + 1 < len(source):
                        masked[index + 1] = " "
                    index += 2
                    if comment_depth == 0:
                        break
                    continue
                if source[index] not in "\r\n":
                    masked[index] = " "
                index += 1
            continue
        if source.startswith(("#|", "$|"), index):
            while index < len(source) and source[index] not in "\r\n":
                masked[index] = " "
                index += 1
            continue
        if char in {'"', "'"}:
            quote = char
            if mask_literals:
                masked[index] = " "
        index += 1
    return "".join(masked)


def extract_braced(source: str, brace: int) -> str | None:
    depth = 0
    for index in range(brace, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[brace + 1 : index]
    return None


def extract_function(source: str, name: str) -> str | None:
    match = re.search(rf"\bfn\s+{re.escape(name)}\s*\([^{{]*\)\s*[^{{]*\{{", source)
    if match is None:
        match = re.search(
            rf"\bstatic\s+void\s+{re.escape(name)}\s*\([^{{]*\)\s*\{{",
            source,
        )
    if match is None:
        return None
    return extract_braced(source, source.find("{", match.start()))


def extract_test(source: str, structure: str, name: str) -> str | None:
    pattern = re.compile(rf'\btest\s+"{re.escape(name)}"\s*\{{')
    for match in pattern.finditer(source):
        if structure[match.start() : match.start() + 4] != "test":
            continue
        brace = source.rfind("{", match.start(), match.end())
        if brace >= 0 and structure[brace] == "{":
            return extract_braced(structure, brace)
    return None


def brace_depth_at(source: str, position: int) -> int:
    depth = 0
    for char in source[:position]:
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
    return depth


def has_top_level_match(source: str, pattern: re.Pattern[str]) -> bool:
    return any(
        brace_depth_at(source, match.start()) == 0
        for match in pattern.finditer(source)
    )


def loop_bodies(source: str) -> list[tuple[int, str]]:
    loops: list[tuple[int, str]] = []
    for match in re.finditer(r"\bfor\s+\w+\s+in\s+0\.\.<([0-9_]+)\s*\{", source):
        if brace_depth_at(source, match.start()) != 0:
            continue
        body = extract_braced(source, source.find("{", match.start()))
        if body is not None:
            loops.append((int(match.group(1).replace("_", "")), body))
    return loops


def safe_relative_path(repo_root: pathlib.Path, value: str) -> pathlib.Path | None:
    relative = pathlib.PurePosixPath(value)
    if relative.is_absolute() or ".." in relative.parts or not relative.parts:
        return None
    return repo_root.joinpath(*relative.parts)


def discover_raw_types(repo_root: pathlib.Path) -> dict[str, list[str]]:
    found: dict[str, list[str]] = {}
    source_root = repo_root / "src"
    if not source_root.is_dir():
        return found
    for path in sorted(source_root.rglob("ffi*.mbt")):
        relative_source = path.relative_to(source_root)
        if relative_source.parts and relative_source.parts[0] == "tests":
            continue
        source = mask_noncode(
            path.read_text(encoding="utf-8"),
            mask_literals=True,
        )
        relative = path.relative_to(repo_root).as_posix()
        for raw_type in RAW_TYPE_RE.findall(source):
            found.setdefault(raw_type, []).append(relative)
    return found


def discover_allocations(
    repo_root: pathlib.Path,
) -> dict[str, list[tuple[str, str]]]:
    found: dict[str, list[tuple[str, str]]] = {}
    native_root = repo_root / "src" / "native"
    if not native_root.is_dir():
        return found
    for path in sorted(native_root.rglob("*.c")):
        source = mask_noncode(
            path.read_text(encoding="utf-8"),
            mask_literals=True,
        )
        relative = path.relative_to(repo_root).as_posix()
        for finalizer, c_struct in ALLOCATION_RE.findall(source):
            found.setdefault(finalizer, []).append((relative, c_struct))
    return found


def load_ledger(path: pathlib.Path) -> tuple[dict[str, Any] | None, list[str]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return None, [f"{path}: cannot load owner ledger: {exc}"]
    if not isinstance(payload, dict):
        return None, [f"{path}: owner ledger must be a JSON object"]
    expected = {"schema_version", "minimum_iterations", "owners"}
    if set(payload) != expected:
        return None, [
            f"{path}: top-level keys must be exactly {sorted(expected)!r}"
        ]
    if payload["schema_version"] != 2:
        return None, [f"{path}: schema_version must be 2"]
    minimum = payload["minimum_iterations"]
    if not isinstance(minimum, int) or isinstance(minimum, bool) or minimum < 1000:
        return None, [f"{path}: minimum_iterations must be an integer >= 1000"]
    if not isinstance(payload["owners"], list):
        return None, [f"{path}: owners must be an array"]
    return payload, []


def expected_owner_names(raw_type: str) -> tuple[str, str]:
    owner_name = raw_type.removeprefix("Raw")
    first_pass = re.sub(r"(.)([A-Z][a-z]+)", r"\1_\2", owner_name)
    snake_name = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", first_pass).lower()
    return f"Cairoon{owner_name}", f"cairoon_{snake_name}_finalize"


def check_external_owners(
    repo_root: pathlib.Path = REPO_ROOT,
    ledger_path: pathlib.Path | None = None,
) -> list[str]:
    ledger_path = ledger_path or repo_root / "scripts" / "lifetime" / "owners.json"
    payload, errors = load_ledger(ledger_path)
    if payload is None:
        return errors

    rows: list[dict[str, Any]] = []
    for index, raw_row in enumerate(payload["owners"]):
        location = f"{ledger_path}:owners[{index}]"
        if not isinstance(raw_row, dict):
            errors.append(f"{location}: owner entry must be an object")
            continue
        if set(raw_row) != LEDGER_KEYS:
            errors.append(
                f"{location}: keys must be exactly {sorted(LEDGER_KEYS)!r}"
            )
            continue
        string_keys = LEDGER_KEYS - {
            "release_anchors",
            "forbidden_stress_anchors",
        }
        if any(
            not isinstance(raw_row[key], str)
            or not raw_row[key].strip()
            or raw_row[key] != raw_row[key].strip()
            for key in string_keys
        ):
            errors.append(
                f"{location}: every scalar owner field must be a trimmed non-empty string"
            )
            continue
        release_anchors = raw_row["release_anchors"]
        if (
            not isinstance(release_anchors, list)
            or not release_anchors
            or any(
                not isinstance(anchor, str)
                or not anchor.strip()
                or anchor != anchor.strip()
                for anchor in release_anchors
            )
            or len(set(release_anchors)) != len(release_anchors)
        ):
            errors.append(
                f"{location}: release_anchors must be a non-empty unique string array"
            )
            continue
        forbidden_stress_anchors = raw_row["forbidden_stress_anchors"]
        if (
            not isinstance(forbidden_stress_anchors, list)
            or any(
                not isinstance(anchor, str)
                or not anchor.strip()
                or anchor != anchor.strip()
                for anchor in forbidden_stress_anchors
            )
            or len(set(forbidden_stress_anchors))
            != len(forbidden_stress_anchors)
        ):
            errors.append(
                f"{location}: forbidden_stress_anchors must be a unique "
                "trimmed string array"
            )
            continue
        rows.append(raw_row)

    raw_types = discover_raw_types(repo_root)
    for raw_type, paths in raw_types.items():
        if len(paths) != 1:
            errors.append(
                f"{raw_type}: raw owner type must have one declaration; found {paths!r}"
            )

    row_types = [row["raw_type"] for row in rows]
    row_finalizers = [row["finalizer"] for row in rows]
    row_structs = [row["c_struct"] for row in rows]
    for duplicate_kind, values in (
        ("raw owner", row_types),
        ("finalizer", row_finalizers),
        ("C payload struct", row_structs),
    ):
        duplicates = sorted({value for value in values if values.count(value) > 1})
        for value in duplicates:
            errors.append(f"duplicate {duplicate_kind} ledger entry: {value}")

    discovered_types = set(raw_types)
    ledger_types = set(row_types)
    for raw_type in sorted(discovered_types - ledger_types):
        errors.append(f"missing ledger owner for {raw_type}")
    for raw_type in sorted(ledger_types - discovered_types):
        errors.append(f"stale ledger owner {raw_type}")

    objects_path = repo_root / OBJECTS_C
    try:
        objects_source = mask_noncode(
            objects_path.read_text(encoding="utf-8"),
            mask_literals=True,
        )
    except OSError as exc:
        errors.append(f"{objects_path}: cannot read native owner source: {exc}")
        return errors
    discovered_finalizers = set(FINALIZER_RE.findall(objects_source))
    ledger_finalizers = set(row_finalizers)
    for finalizer in sorted(discovered_finalizers - ledger_finalizers):
        errors.append(f"missing ledger entry for native finalizer {finalizer}")
    for finalizer in sorted(ledger_finalizers - discovered_finalizers):
        errors.append(f"stale native finalizer ledger entry {finalizer}")

    allocations = discover_allocations(repo_root)
    allocation_finalizers = set(allocations)
    for finalizer in sorted(allocation_finalizers - ledger_finalizers):
        errors.append(
            f"missing ledger entry for external-object allocator {finalizer}"
        )
    for finalizer in sorted(ledger_finalizers - allocation_finalizers):
        errors.append(f"{finalizer}: no external-object allocation found")

    minimum = payload["minimum_iterations"]
    for row in rows:
        raw_type = row["raw_type"]
        declared_paths = raw_types.get(raw_type, [])
        if declared_paths != [row["ffi_path"]]:
            errors.append(
                f"{raw_type}: ffi_path {row['ffi_path']!r} does not match "
                f"declaration {declared_paths!r}"
            )

        expected_struct, expected_finalizer = expected_owner_names(raw_type)
        if row["c_struct"] != expected_struct:
            errors.append(
                f"{raw_type}: C payload must be {expected_struct}, "
                f"found {row['c_struct']}"
            )
        if row["finalizer"] != expected_finalizer:
            errors.append(
                f"{raw_type}: finalizer must be {expected_finalizer}, "
                f"found {row['finalizer']}"
            )

        finalizer_body = extract_function(objects_source, row["finalizer"])
        if finalizer_body is None:
            errors.append(f"{raw_type}: missing finalizer {row['finalizer']}")
        else:
            for release_anchor in row["release_anchors"]:
                if release_anchor not in finalizer_body:
                    errors.append(
                        f"{raw_type}: finalizer {row['finalizer']} is missing "
                        f"release anchor {release_anchor!r}"
                    )

        expected_allocation = (OBJECTS_C, row["c_struct"])
        owner_allocations = allocations.get(row["finalizer"], [])
        if expected_allocation not in owner_allocations:
            errors.append(
                f"{raw_type}: no external-object allocation pairs "
                f"{row['finalizer']} with sizeof({row['c_struct']})"
            )
        unexpected_allocations = sorted(
            set(owner_allocations) - {expected_allocation}
        )
        if unexpected_allocations:
            errors.append(
                f"{raw_type}: external-object allocations must use only "
                f"{OBJECTS_C} and sizeof({row['c_struct']}); found "
                f"{unexpected_allocations!r}"
            )

        stress_path = safe_relative_path(repo_root, row["stress_path"])
        if stress_path is None:
            errors.append(f"{raw_type}: unsafe stress_path {row['stress_path']!r}")
            continue
        if not stress_path.name.endswith("_test.mbt"):
            errors.append(
                f"{raw_type}: stress_path must name an executable *_test.mbt file"
            )
            continue
        expected_root = (repo_root / "src" / "tests" / "lifetime").resolve()
        try:
            stress_path.resolve().relative_to(expected_root)
        except (OSError, ValueError):
            errors.append(
                f"{raw_type}: stress_path must live under src/tests/lifetime"
            )
            continue
        try:
            raw_stress_source = stress_path.read_text(encoding="utf-8")
            stress_names = mask_noncode(raw_stress_source, mask_literals=False)
            stress_structure = mask_noncode(raw_stress_source, mask_literals=True)
        except OSError as exc:
            errors.append(f"{raw_type}: cannot read stress_path: {exc}")
            continue
        if not (stress_path.parent / "moon.pkg").is_file():
            errors.append(
                f"{raw_type}: stress_path must be beside its owning moon.pkg"
            )

        test_body = extract_test(
            stress_names,
            stress_structure,
            row["stress_test"],
        )
        if test_body is None:
            errors.append(
                f"{raw_type}: missing stress test {row['stress_test']!r}"
            )
        else:
            helper_call = re.compile(rf"\b{re.escape(row['stress_helper'])}\s*\(")
            eligible = [
                count
                for count, body in loop_bodies(test_body)
                if count >= minimum and has_top_level_match(body, helper_call)
            ]
            if not eligible:
                errors.append(
                    f"{raw_type}: stress test must call {row['stress_helper']} "
                    f"inside a loop of at least {minimum} iterations"
                )

        helper_body = extract_function(stress_structure, row["stress_helper"])
        if helper_body is None:
            errors.append(
                f"{raw_type}: missing stress helper {row['stress_helper']}"
            )
        else:
            allocation_pattern = re.compile(re.escape(row["allocation_anchor"]))
            if not has_top_level_match(helper_body, allocation_pattern):
                errors.append(
                    f"{raw_type}: stress helper {row['stress_helper']} must reach "
                    f"allocation anchor {row['allocation_anchor']!r} unconditionally"
                )
            for forbidden_anchor in row["forbidden_stress_anchors"]:
                if re.search(re.escape(forbidden_anchor), helper_body):
                    errors.append(
                        f"{raw_type}: stress helper {row['stress_helper']} contains "
                        f"forbidden stress anchor {forbidden_anchor!r}"
                    )

    return errors


def main() -> int:
    errors = check_external_owners()
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    payload, _ = load_ledger(LEDGER)
    assert payload is not None
    finalizer_only_paths = sum(
        bool(owner["forbidden_stress_anchors"])
        for owner in payload["owners"]
    )
    print(
        "External owner lifetime evidence ok; "
        f"{len(payload['owners'])} raw owners have exact allocator, finalizer, "
        f"release, and {payload['minimum_iterations']}-iteration stress evidence; "
        f"{finalizer_only_paths} stress path bans explicit release"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
