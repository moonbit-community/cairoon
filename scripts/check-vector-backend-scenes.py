#!/usr/bin/env python3
"""Check that backend vector oracle scenes stay fully wired."""

from __future__ import annotations

import pathlib
import re
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
HEADER = REPO_ROOT / "src/tests/oracle/native/cairoon_test_vector_private.h"
C_DISPATCH = REPO_ROOT / "src/tests/oracle/native/cairoon_test_vector.c"
STREAM_ORACLE = (
    REPO_ROOT / "src/tests/oracle/vector_backend/surface_stream_oracle_test.mbt"
)
NATIVE_DIR = REPO_ROOT / "src/tests/oracle/native"
NATIVE_PKG = NATIVE_DIR / "moon.pkg"
API_INVENTORY = REPO_ROOT / "API_INVENTORY.md"


def read_text(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def backend_scenes() -> list[tuple[str, int]]:
    text = read_text(HEADER)
    scenes = [
        (name, int(scene_id))
        for name, scene_id in re.findall(
            r"(CAIROON_TEST_VECTOR_BACKEND_[A-Z0-9_]+)\s*=\s*(\d+)", text
        )
    ]
    return sorted(scenes, key=lambda scene: scene[1])


def check_duplicate_scene_ids(scenes: list[tuple[str, int]]) -> list[str]:
    errors: list[str] = []
    seen: dict[int, str] = {}
    for name, scene_id in scenes:
        existing = seen.get(scene_id)
        if existing is not None:
            errors.append(
                f"{HEADER}: backend scene id {scene_id} is used by both "
                f"{existing} and {name}"
            )
        seen[scene_id] = name
    return errors


def check_c_dispatch(scenes: list[tuple[str, int]]) -> list[str]:
    text = read_text(C_DISPATCH)
    errors: list[str] = []
    for name, _ in scenes:
        if f"if (scene == {name})" not in text:
            errors.append(f"{C_DISPATCH}: missing direct C dispatch for {name}")
    return errors


def check_stream_match(scenes: list[tuple[str, int]]) -> list[str]:
    text = read_text(STREAM_ORACLE)
    errors: list[str] = []
    for name, scene_id in scenes:
        if not re.search(rf"^\s*{scene_id}\s*=>\s*\{{", text, re.MULTILINE):
            errors.append(
                f"{STREAM_ORACLE}: missing stream renderer match arm for "
                f"{name} ({scene_id})"
            )
    return errors


def parse_int_list(body: str) -> set[int]:
    return {int(value) for value in re.findall(r"\d+", body)}


def check_stream_scene_list(scenes: list[tuple[str, int]]) -> list[str]:
    text = read_text(STREAM_ORACLE)
    scene_ids = {scene_id for _, scene_id in scenes}
    lists = [
        parse_int_list(body)
        for body in re.findall(r"for\s+(?:\n\s*)?scene\s+in\s+\[([^\]]+)\]", text)
    ]
    backend_lists = [ids for ids in lists if scene_ids & ids]
    if not backend_lists:
        return [f"{STREAM_ORACLE}: no backend stream-oracle scene list found"]

    aggregate = set().union(*backend_lists)
    missing = sorted(scene_ids - aggregate)
    if missing:
        return [
            f"{STREAM_ORACLE}: backend stream-oracle scene list is missing "
            f"{', '.join(str(scene_id) for scene_id in missing)}"
        ]
    return []


def check_native_stubs() -> list[str]:
    text = read_text(NATIVE_PKG)
    listed = set(re.findall(r'"([^"]+\.c)"', text))
    errors: list[str] = []

    for stub in sorted(listed):
        if not (NATIVE_DIR / stub).exists():
            errors.append(f"{NATIVE_PKG}: listed native stub does not exist: {stub}")

    for source in sorted(NATIVE_DIR.glob("cairoon_test_backend_*.c")):
        if source.name not in listed:
            errors.append(
                f"{NATIVE_PKG}: backend native stub is not listed: {source.name}"
            )

    return errors


def backend_slice_section() -> str:
    text = read_text(API_INVENTORY)
    marker = "## Backend Differential Slices"
    try:
        return text.split(marker, 1)[1].split("\n## ", 1)[0]
    except IndexError:
        return ""


def check_inventory_rows(scenes: list[tuple[str, int]]) -> list[str]:
    section = backend_slice_section()
    errors: list[str] = []
    if not section:
        return [f"{API_INVENTORY}: missing Backend Differential Slices section"]

    for name, scene_id in scenes:
        if f"Scene {scene_id}" not in section:
            errors.append(
                f"{API_INVENTORY}: Backend Differential Slices is missing "
                f"Scene {scene_id} evidence for {name}"
            )
    return errors


def main() -> int:
    scenes = backend_scenes()
    errors: list[str] = []

    if not scenes:
        errors.append(f"{HEADER}: no backend vector scenes found")
    else:
        errors.extend(check_duplicate_scene_ids(scenes))
        errors.extend(check_c_dispatch(scenes))
        errors.extend(check_stream_match(scenes))
        errors.extend(check_stream_scene_list(scenes))
        errors.extend(check_inventory_rows(scenes))

    errors.extend(check_native_stubs())

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    stub_count = len(re.findall(r'"([^"]+\.c)"', read_text(NATIVE_PKG)))
    print(
        f"Vector backend scene wiring ok; {len(scenes)} scenes checked; "
        f"{stub_count} native stubs checked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
