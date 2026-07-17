"""Parse and validate cairoon's pinned pycairo public-API snapshot."""

from __future__ import annotations

import ast
import hashlib
import json
import pathlib
from typing import Any


SNAPSHOT_FIELDS = {
    "schema_version",
    "upstream",
    "top_level",
    "methods",
    "constants",
    "enum_aliases",
}
SNAPSHOT_UPSTREAM_FIELDS = {"repository", "commit", "path", "sha256"}
EXPECTED_SNAPSHOT_COUNTS = {
    "top_level": 67,
    "methods": 259,
    "constants": 224,
    "enum_aliases": 178,
}
ApiShape = tuple[set[str], dict[str, set[str]], set[str], set[str]]


def parse_pycairo_api(stub_path: pathlib.Path) -> ApiShape:
    module = ast.parse(stub_path.read_text(encoding="utf-8"), filename=str(stub_path))
    top_level = {
        node.name
        for node in module.body
        if isinstance(node, (ast.ClassDef, ast.FunctionDef))
        and not node.name.startswith("_")
    }
    methods: dict[str, set[str]] = {}
    constants: set[str] = set()
    enum_aliases: set[str] = set()
    for node in module.body:
        if isinstance(node, ast.ClassDef):
            public_methods = {
                item.name
                for item in node.body
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef))
                and not item.name.startswith("_")
            }
            if public_methods:
                methods[node.name] = public_methods
        elif isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            if not node.target.id.startswith("_"):
                constants.add(node.target.id)
        elif isinstance(node, ast.Assign):
            public_names = {
                target.id
                for target in node.targets
                if isinstance(target, ast.Name) and not target.id.startswith("_")
            }
            constants.update(public_names)
            if (
                isinstance(node.value, ast.Attribute)
                and isinstance(node.value.value, ast.Name)
                and node.value.value.id in top_level
            ):
                enum_aliases.update(public_names)
    return top_level, methods, constants, enum_aliases


def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key {key!r}")
        result[key] = value
    return result


def sorted_string_set(owner: str, value: Any) -> set[str]:
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item for item in value
    ):
        raise ValueError(f"{owner} must be a list of non-empty strings")
    if len(value) != len(set(value)):
        raise ValueError(f"{owner} contains duplicate entries")
    if value != sorted(value):
        raise ValueError(f"{owner} must be sorted")
    return set(value)


def shape_counts(shape: ApiShape) -> dict[str, int]:
    top_level, methods, constants, enum_aliases = shape
    return {
        "top_level": len(top_level),
        "methods": sum(len(names) for names in methods.values()),
        "constants": len(constants),
        "enum_aliases": len(enum_aliases),
    }


def require_expected_counts(owner: pathlib.Path, shape: ApiShape) -> None:
    actual = shape_counts(shape)
    if actual != EXPECTED_SNAPSHOT_COUNTS:
        raise ValueError(
            f"{owner}: API snapshot counts are {actual!r}, "
            f"expected {EXPECTED_SNAPSHOT_COUNTS!r}"
        )


def load_api_snapshot(path: pathlib.Path) -> tuple[ApiShape, str]:
    try:
        payload = json.loads(
            path.read_text(encoding="utf-8"),
            object_pairs_hook=reject_duplicate_keys,
        )
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        raise ValueError(f"{path}: invalid API snapshot: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValueError(f"{path}: API snapshot root must be an object")
    if set(payload) != SNAPSHOT_FIELDS:
        raise ValueError(
            f"{path}: API snapshot fields must be {sorted(SNAPSHOT_FIELDS)!r}"
        )
    if payload.get("schema_version") != 1:
        raise ValueError(f"{path}: API snapshot schema_version must be 1")

    upstream = payload.get("upstream")
    if not isinstance(upstream, dict) or set(upstream) != SNAPSHOT_UPSTREAM_FIELDS:
        raise ValueError(
            f"{path}: upstream fields must be {sorted(SNAPSHOT_UPSTREAM_FIELDS)!r}"
        )
    if upstream.get("repository") != "https://github.com/pygobject/pycairo":
        raise ValueError(f"{path}: unexpected upstream repository")
    commit = upstream.get("commit")
    if (
        not isinstance(commit, str)
        or len(commit) != 40
        or any(char not in "0123456789abcdef" for char in commit)
    ):
        raise ValueError(f"{path}: upstream commit must be a lowercase Git hash")
    if upstream.get("path") != "cairo/__init__.pyi":
        raise ValueError(f"{path}: upstream path must be 'cairo/__init__.pyi'")
    expected_digest = upstream.get("sha256")
    if (
        not isinstance(expected_digest, str)
        or len(expected_digest) != 64
        or any(char not in "0123456789abcdef" for char in expected_digest)
    ):
        raise ValueError(f"{path}: upstream sha256 must be a lowercase digest")

    top_level = sorted_string_set(f"{path}: top_level", payload.get("top_level"))
    constants = sorted_string_set(f"{path}: constants", payload.get("constants"))
    enum_aliases = sorted_string_set(
        f"{path}: enum_aliases", payload.get("enum_aliases")
    )
    methods_value = payload.get("methods")
    if not isinstance(methods_value, dict):
        raise ValueError(f"{path}: methods must be an object")
    if list(methods_value) != sorted(methods_value):
        raise ValueError(f"{path}: method classes must be sorted")
    methods = {
        class_name: sorted_string_set(
            f"{path}: methods.{class_name}", method_names
        )
        for class_name, method_names in methods_value.items()
        if isinstance(class_name, str) and class_name
    }
    if len(methods) != len(methods_value):
        raise ValueError(f"{path}: method class names must be non-empty strings")
    if not set(methods).issubset(top_level):
        raise ValueError(f"{path}: method classes must be public top-level APIs")
    if not enum_aliases.issubset(constants):
        raise ValueError(f"{path}: enum_aliases must be a subset of constants")
    shape = top_level, methods, constants, enum_aliases
    require_expected_counts(path, shape)
    return shape, expected_digest


def write_api_snapshot(
    stub_path: pathlib.Path,
    snapshot_path: pathlib.Path,
    upstream_commit: str,
) -> ApiShape:
    if (
        len(upstream_commit) != 40
        or any(char not in "0123456789abcdef" for char in upstream_commit)
    ):
        raise ValueError("upstream commit must be a 40-character lowercase Git hash")
    shape = parse_pycairo_api(stub_path)
    require_expected_counts(stub_path, shape)
    top_level, methods, constants, enum_aliases = shape
    payload = {
        "schema_version": 1,
        "upstream": {
            "repository": "https://github.com/pygobject/pycairo",
            "commit": upstream_commit,
            "path": "cairo/__init__.pyi",
            "sha256": hashlib.sha256(stub_path.read_bytes()).hexdigest(),
        },
        "top_level": sorted(top_level),
        "methods": {
            class_name: sorted(method_names)
            for class_name, method_names in sorted(methods.items())
        },
        "constants": sorted(constants),
        "enum_aliases": sorted(enum_aliases),
    }
    snapshot_path.parent.mkdir(parents=True, exist_ok=True)
    snapshot_path.write_text(
        json.dumps(payload, indent=2, ensure_ascii=True) + "\n",
        encoding="utf-8",
    )
    return shape


def load_pycairo_api(
    stub_path: pathlib.Path,
    snapshot_path: pathlib.Path,
) -> ApiShape:
    snapshot_shape, expected_digest = load_api_snapshot(snapshot_path)
    if not stub_path.is_file():
        return snapshot_shape
    actual_digest = hashlib.sha256(stub_path.read_bytes()).hexdigest()
    if actual_digest != expected_digest:
        raise ValueError(
            f"{stub_path}: SHA-256 drift; expected {expected_digest}, "
            f"got {actual_digest}"
        )
    source_shape = parse_pycairo_api(stub_path)
    if source_shape != snapshot_shape:
        raise ValueError(f"{stub_path}: parsed API differs from {snapshot_path}")
    return source_shape
