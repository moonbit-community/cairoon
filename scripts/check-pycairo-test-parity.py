#!/usr/bin/env python3
"""Check pycairo family tests against cairoon's executable evidence ledgers."""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import pathlib
import re
import sys
from typing import Any


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PYCAIRO_SOURCE_MARKER = pathlib.PurePosixPath("cairo/__init__.pyi")
TEST_DECLARATION = re.compile(r'^test\s+"([^"\\]*(?:\\.[^"\\]*)*)"\s*\{', re.MULTILINE)
COMMIT_HASH = re.compile(r"^[0-9a-f]{40}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
LEDGER_FIELDS = {
    "schema_version",
    "family",
    "runtime_root",
    "upstream",
    "type_error_policy",
    "type_error_tests",
    "tests",
}
MAPPING_FIELDS = {"runtime", "static_api", "static_absent", "adaptation"}


class DuplicateKeyError(ValueError):
    pass


def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate JSON key {key!r}")
        result[key] = value
    return result


def load_ledger(path: pathlib.Path) -> dict[str, Any]:
    value = json.loads(
        path.read_text(encoding="utf-8"),
        object_pairs_hook=reject_duplicate_keys,
    )
    if not isinstance(value, dict):
        raise ValueError("ledger root must be a JSON object")
    return value


def is_pytest_type_error_assertion(node: ast.AST) -> bool:
    if not isinstance(node, ast.Call):
        return False
    if not isinstance(node.func, ast.Attribute) or node.func.attr != "raises":
        return False
    return any(
        isinstance(child, ast.Name) and child.id == "TypeError"
        for argument in node.args
        for child in ast.walk(argument)
    )


def upstream_tests(path: pathlib.Path) -> tuple[set[str], set[str]]:
    module = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    tests: set[str] = set()
    type_error_tests: set[str] = set()
    for node in module.body:
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue
        if not node.name.startswith("test_"):
            continue
        tests.add(node.name)
        if any(is_pytest_type_error_assertion(child) for child in ast.walk(node)):
            type_error_tests.add(node.name)
    return tests, type_error_tests


def moonbit_test_anchors(
    runtime_root: pathlib.Path,
    repo_root: pathlib.Path,
) -> set[str]:
    if not runtime_root.is_dir():
        raise ValueError("runtime_root is not a directory")
    anchors: set[str] = set()
    for path in sorted(runtime_root.rglob("*.mbt")):
        relative = path.relative_to(repo_root).as_posix()
        text = path.read_text(encoding="utf-8")
        for match in TEST_DECLARATION.finditer(text):
            anchors.add(f"{relative}::{match.group(1)}")
    return anchors


def string_list(
    owner: str,
    value: Any,
    errors: list[str],
    *,
    required: bool,
    allow_empty: bool = False,
) -> list[str]:
    if value is None and not required:
        return []
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item.strip() for item in value
    ):
        errors.append(f"{owner}: must be a list of non-empty strings")
        return []
    if required and not allow_empty and not value:
        errors.append(f"{owner}: must not be empty")
    if len(value) != len(set(value)):
        errors.append(f"{owner}: contains duplicate entries")
    return value


def relative_ledger_path(
    owner: str,
    value: Any,
    errors: list[str],
) -> pathlib.PurePosixPath | None:
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{owner}: must be a non-empty relative path")
        return None
    path = pathlib.PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        errors.append(f"{owner}: must not be absolute or contain '..'")
        return None
    return path


def validate(
    *,
    repo_root: pathlib.Path,
    upstream_root: pathlib.Path,
    ledger_path: pathlib.Path,
    public_api: str,
    require_source: bool,
) -> tuple[list[str], str, int, int, int, int, str]:
    errors: list[str] = []
    try:
        ledger = load_ledger(ledger_path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        return ([f"{ledger_path}: {exc}"], ledger_path.stem, 0, 0, 0, 0, "invalid")

    for field in sorted(set(ledger) - LEDGER_FIELDS):
        errors.append(f"{ledger_path}: unknown field {field!r}")
    if ledger.get("schema_version") != 1:
        errors.append(f"{ledger_path}: schema_version must be 1")

    family = ledger.get("family")
    if not isinstance(family, str) or not family.strip():
        errors.append(f"{ledger_path}: family must be a non-empty string")
        family = ledger_path.stem

    runtime_relative = relative_ledger_path(
        f"{ledger_path}: runtime_root",
        ledger.get("runtime_root"),
        errors,
    )
    if runtime_relative is not None and runtime_relative.parts[:2] != ("src", "tests"):
        errors.append(f"{ledger_path}: runtime_root must be below src/tests")
        runtime_relative = None
    runtime_root = repo_root.joinpath(*runtime_relative.parts) if runtime_relative else repo_root

    upstream = ledger.get("upstream")
    if not isinstance(upstream, dict):
        errors.append(f"{ledger_path}: upstream must be an object")
        upstream = {}
    repository = upstream.get("repository")
    if not isinstance(repository, str) or not repository.startswith("https://"):
        errors.append(f"{ledger_path}: upstream.repository must be an HTTPS URL")
    commit = upstream.get("commit")
    if not isinstance(commit, str) or COMMIT_HASH.fullmatch(commit) is None:
        errors.append(f"{ledger_path}: upstream.commit must be a 40-character lowercase hash")
    source_relative = relative_ledger_path(
        f"{ledger_path}: upstream.path",
        upstream.get("path"),
        errors,
    )
    upstream_path = (
        upstream_root.joinpath(*source_relative.parts)
        if source_relative is not None
        else upstream_root
    )
    expected_digest = upstream.get("sha256")
    if not isinstance(expected_digest, str) or SHA256.fullmatch(expected_digest) is None:
        errors.append(f"{ledger_path}: upstream.sha256 must be a lowercase SHA-256 digest")
        expected_digest = ""
    expected_count = upstream.get("test_count")
    if not isinstance(expected_count, int) or isinstance(expected_count, bool):
        errors.append(f"{ledger_path}: upstream.test_count must be an integer")
        expected_count = -1

    policy = ledger.get("type_error_policy")
    if not isinstance(policy, str) or not policy.strip():
        errors.append(f"{ledger_path}: type_error_policy must be a non-empty string")

    mappings = ledger.get("tests")
    if not isinstance(mappings, dict):
        errors.append(f"{ledger_path}: tests must be an object")
        mappings = {}
    mapped_names = set(mappings)
    if expected_count != len(mapped_names):
        errors.append(
            f"{ledger_path}: upstream.test_count is {expected_count}, "
            f"but the ledger maps {len(mapped_names)} tests"
        )

    type_error_list = string_list(
        f"{ledger_path}: type_error_tests",
        ledger.get("type_error_tests"),
        errors,
        required=True,
        allow_empty=True,
    )
    mapped_type_errors = set(type_error_list)
    for name in sorted(mapped_type_errors - mapped_names):
        errors.append(f"{ledger_path}: type_error_tests contains unmapped test {name!r}")

    source_mode = "snapshot"
    if upstream_path.is_file():
        source_mode = "source"
        actual_digest = hashlib.sha256(upstream_path.read_bytes()).hexdigest()
        if actual_digest != expected_digest:
            errors.append(
                f"{upstream_path}: SHA-256 drift; expected {expected_digest}, "
                f"got {actual_digest}"
            )
        try:
            actual_names, actual_type_errors = upstream_tests(upstream_path)
        except (OSError, SyntaxError) as exc:
            errors.append(f"{upstream_path}: cannot parse upstream tests: {exc}")
            actual_names, actual_type_errors = set(), set()
        for name in sorted(actual_names - mapped_names):
            errors.append(f"{upstream_path}: upstream {family} test {name!r} is unmapped")
        for name in sorted(mapped_names - actual_names):
            errors.append(f"{ledger_path}: mapped test {name!r} is absent upstream")
        for name in sorted(actual_type_errors - mapped_type_errors):
            errors.append(f"{upstream_path}: TypeError test {name!r} lacks a typed mapping")
        for name in sorted(mapped_type_errors - actual_type_errors):
            errors.append(f"{ledger_path}: stale TypeError mapping for {name!r}")
    elif require_source:
        source_mode = "missing"
        errors.append(
            f"{upstream_path}: detected pycairo source checkout is missing "
            "the ledger upstream file"
        )

    try:
        runtime_anchors = moonbit_test_anchors(runtime_root, repo_root)
    except (OSError, ValueError) as exc:
        errors.append(f"{runtime_root}: cannot enumerate MoonBit tests: {exc}")
        runtime_anchors = set()

    used_runtime: set[str] = set()
    used_static: set[str] = set()
    required_absent: set[str] = set()
    for name, mapping in sorted(mappings.items()):
        owner = f"{ledger_path}: tests.{name}"
        if not isinstance(name, str) or not name.startswith("test_"):
            errors.append(f"{owner}: mapping key must start with test_")
        if not isinstance(mapping, dict):
            errors.append(f"{owner}: mapping must be an object")
            continue
        for field in sorted(set(mapping) - MAPPING_FIELDS):
            errors.append(f"{owner}: unknown field {field!r}")
        runtime = string_list(
            f"{owner}.runtime",
            mapping.get("runtime"),
            errors,
            required=True,
        )
        static_api = string_list(
            f"{owner}.static_api",
            mapping.get("static_api"),
            errors,
            required=False,
        )
        static_absent = string_list(
            f"{owner}.static_absent",
            mapping.get("static_absent"),
            errors,
            required=False,
        )
        adaptation = mapping.get("adaptation")
        if adaptation is not None and (
            not isinstance(adaptation, str) or not adaptation.strip()
        ):
            errors.append(f"{owner}.adaptation: must be a non-empty string")
        if name in mapped_type_errors and not static_api and not static_absent:
            errors.append(f"{owner}: requires static_api or static_absent evidence")
        for anchor in runtime:
            used_runtime.add(anchor)
            if anchor not in runtime_anchors:
                errors.append(f"{owner}: missing MoonBit runtime test anchor {anchor!r}")
        for anchor in static_api:
            used_static.add(anchor)
            if anchor not in public_api:
                errors.append(f"{owner}: missing public API anchor {anchor!r}")
        for anchor in static_absent:
            required_absent.add(anchor)
            if anchor in public_api:
                errors.append(f"{owner}: forbidden public API anchor {anchor!r} is present")

    return (
        errors,
        family,
        len(mapped_names),
        len(used_runtime),
        len(used_static),
        len(required_absent),
        source_mode,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=pathlib.Path, default=REPO_ROOT)
    parser.add_argument(
        "--upstream-root",
        type=pathlib.Path,
    )
    parser.add_argument("--ledger", type=pathlib.Path, action="append")
    parser.add_argument(
        "--ledger-dir",
        type=pathlib.Path,
    )
    parser.add_argument("--public-api", type=pathlib.Path)
    parser.add_argument(
        "--require-source",
        action="store_true",
        help="fail instead of using ledger snapshots when upstream files are absent",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    upstream_root = (args.upstream_root or repo_root.parent).resolve()
    ledger_dir = (args.ledger_dir or repo_root / "scripts/parity").resolve()
    public_api_path = (args.public_api or repo_root / "src/pkg.generated.mbti").resolve()
    source_marker = upstream_root.joinpath(*PYCAIRO_SOURCE_MARKER.parts)
    require_source = args.require_source or source_marker.is_file()
    ledger_paths = (
        [path.resolve() for path in args.ledger]
        if args.ledger
        else sorted(ledger_dir.glob("*.json"))
    )
    if not ledger_paths:
        print(f"{ledger_dir}: no parity ledgers found", file=sys.stderr)
        return 1
    try:
        public_api = public_api_path.read_text(encoding="utf-8")
    except OSError as exc:
        print(f"{public_api_path}: cannot read public API: {exc}", file=sys.stderr)
        return 1

    errors: list[str] = []
    summaries: list[tuple[str, int, int, int, int, str]] = []
    seen_families: set[str] = set()
    for ledger_path in ledger_paths:
        result = validate(
            repo_root=repo_root,
            upstream_root=upstream_root,
            ledger_path=ledger_path,
            public_api=public_api,
            require_source=require_source,
        )
        ledger_errors, family, tests, runtime, static, absent, mode = result
        errors.extend(ledger_errors)
        if family in seen_families:
            errors.append(f"{ledger_path}: duplicate parity family {family!r}")
        seen_families.add(family)
        summaries.append((family, tests, runtime, static, absent, mode))

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    for family, tests, runtime, static, absent, mode in summaries:
        suffix = (
            "verified against pycairo source"
            if mode == "source"
            else "using pinned snapshot"
        )
        print(
            f"{family} parity ledger covers {tests} upstream tests, "
            f"{runtime} MoonBit runtime anchors, {static} required static API "
            f"anchors, and {absent} forbidden static API anchors; {suffix}"
        )
    if len(summaries) > 1:
        total_tests = sum(summary[1] for summary in summaries)
        print(
            f"Pycairo parity ledgers cover {total_tests} upstream tests "
            f"across {len(summaries)} families"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
