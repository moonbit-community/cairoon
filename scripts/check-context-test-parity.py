#!/usr/bin/env python3
"""Check pycairo Context tests against cairoon's executable evidence ledger."""

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
DEFAULT_LEDGER = REPO_ROOT / "scripts" / "context-test-parity.json"
DEFAULT_UPSTREAM = REPO_ROOT.parent / "tests" / "test_context.py"
DEFAULT_CONTEXT_TESTS = REPO_ROOT / "src" / "tests" / "context"
DEFAULT_PUBLIC_API = REPO_ROOT / "src" / "pkg.generated.mbti"
TEST_DECLARATION = re.compile(r'^test\s+"([^"\\]*(?:\\.[^"\\]*)*)"\s*\{', re.MULTILINE)
COMMIT_HASH = re.compile(r"^[0-9a-f]{40}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")


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
    return any(isinstance(argument, ast.Name) and argument.id == "TypeError" for argument in node.args)


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
    context_tests: pathlib.Path,
    repo_root: pathlib.Path,
) -> set[str]:
    anchors: set[str] = set()
    for path in sorted(context_tests.rglob("*.mbt")):
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
) -> list[str]:
    if value is None and not required:
        return []
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item.strip() for item in value
    ):
        errors.append(f"{owner}: must be a list of non-empty strings")
        return []
    if required and not value:
        errors.append(f"{owner}: must not be empty")
    if len(value) != len(set(value)):
        errors.append(f"{owner}: contains duplicate entries")
    return value


def validate(
    *,
    repo_root: pathlib.Path,
    ledger_path: pathlib.Path,
    upstream_path: pathlib.Path,
    context_tests: pathlib.Path,
    public_api_path: pathlib.Path,
) -> tuple[list[str], int, int, int, str]:
    errors: list[str] = []
    try:
        ledger = load_ledger(ledger_path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        return ([f"{ledger_path}: {exc}"], 0, 0, 0, "invalid")

    if ledger.get("schema_version") != 1:
        errors.append(f"{ledger_path}: schema_version must be 1")

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
    source_path = upstream.get("path")
    if not isinstance(source_path, str) or source_path != "tests/test_context.py":
        errors.append(f"{ledger_path}: upstream.path must be tests/test_context.py")
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
    )
    mapped_type_errors = set(type_error_list)
    for name in sorted(mapped_type_errors - mapped_names):
        errors.append(f"{ledger_path}: type_error_tests contains unmapped test {name!r}")

    source_mode = "snapshot"
    if upstream_path.exists():
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
            errors.append(f"{upstream_path}: upstream Context test {name!r} is unmapped")
        for name in sorted(mapped_names - actual_names):
            errors.append(f"{ledger_path}: mapped test {name!r} is absent upstream")
        for name in sorted(actual_type_errors - mapped_type_errors):
            errors.append(f"{upstream_path}: TypeError test {name!r} lacks a typed mapping")
        for name in sorted(mapped_type_errors - actual_type_errors):
            errors.append(f"{ledger_path}: stale TypeError mapping for {name!r}")

    try:
        runtime_anchors = moonbit_test_anchors(context_tests, repo_root)
    except (OSError, ValueError) as exc:
        errors.append(f"{context_tests}: cannot enumerate MoonBit tests: {exc}")
        runtime_anchors = set()
    try:
        public_api = public_api_path.read_text(encoding="utf-8")
    except OSError as exc:
        errors.append(f"{public_api_path}: cannot read public API: {exc}")
        public_api = ""

    used_runtime: set[str] = set()
    used_static: set[str] = set()
    allowed_fields = {"runtime", "static_api", "adaptation"}
    for name, mapping in sorted(mappings.items()):
        owner = f"{ledger_path}: tests.{name}"
        if not isinstance(name, str) or not name.startswith("test_"):
            errors.append(f"{owner}: mapping key must start with test_")
        if not isinstance(mapping, dict):
            errors.append(f"{owner}: mapping must be an object")
            continue
        for field in sorted(set(mapping) - allowed_fields):
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
        adaptation = mapping.get("adaptation")
        if adaptation is not None and (
            not isinstance(adaptation, str) or not adaptation.strip()
        ):
            errors.append(f"{owner}.adaptation: must be a non-empty string")
        if name in mapped_type_errors and not static_api:
            errors.append(f"{owner}: requires at least one static_api anchor")
        for anchor in runtime:
            used_runtime.add(anchor)
            if anchor not in runtime_anchors:
                errors.append(f"{owner}: missing MoonBit runtime test anchor {anchor!r}")
        for anchor in static_api:
            used_static.add(anchor)
            if anchor not in public_api:
                errors.append(f"{owner}: missing public API anchor {anchor!r}")

    return (
        errors,
        len(mapped_names),
        len(used_runtime),
        len(used_static),
        source_mode,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=pathlib.Path, default=REPO_ROOT)
    parser.add_argument("--ledger", type=pathlib.Path, default=DEFAULT_LEDGER)
    parser.add_argument("--upstream", type=pathlib.Path, default=DEFAULT_UPSTREAM)
    parser.add_argument(
        "--context-tests",
        type=pathlib.Path,
        default=DEFAULT_CONTEXT_TESTS,
    )
    parser.add_argument("--public-api", type=pathlib.Path, default=DEFAULT_PUBLIC_API)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    errors, tests, runtime, static, mode = validate(
        repo_root=args.repo_root.resolve(),
        ledger_path=args.ledger.resolve(),
        upstream_path=args.upstream.resolve(),
        context_tests=args.context_tests.resolve(),
        public_api_path=args.public_api.resolve(),
    )
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    suffix = "verified against pycairo source" if mode == "source" else "using pinned snapshot"
    print(
        f"Context parity ledger covers {tests} upstream Context tests, "
        f"{runtime} MoonBit runtime anchors, and {static} static API anchors; {suffix}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
