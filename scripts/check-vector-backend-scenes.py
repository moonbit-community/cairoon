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
TAG_ATTRIBUTE_C = NATIVE_DIR / "cairoon_test_backend_tag_attributes.c"
TAG_ATTRIBUTE_MOONBIT = (
    REPO_ROOT
    / "src/tests/oracle/vector_backend/surface_stream_tag_attributes_test.mbt"
)
TAG_ATTRIBUTE_REQUIREMENTS = {
    "URI link": (
        "uri='https://example.com/tag-attributes'",
        "uri='https://example.com/tag-attributes'",
    ),
    "multi-rectangle link": (
        "rect=[10 28 52 12 72 28 58 12]",
        "rect=[10 28 52 12 72 28 58 12]",
    ),
    "named destination link": (
        "dest='tag-attribute-target'",
        "dest='tag-attribute-target'",
    ),
    "page-position link": (
        "page=2 pos=[18 44]",
        "page=2 pos=[18 44]",
    ),
    "file page-position link": (
        "file='external.pdf' page=3 pos=[12 34]",
        "file='external.pdf' page=3 pos=[12 34]",
    ),
    "file destination link": (
        "file='external.pdf' dest='appendix'",
        "file='external.pdf' dest='appendix'",
    ),
    "internal destination": (
        "name='tag-attribute-target' x=18 y=44 internal",
        "name='tag-attribute-target' x=18 y=44 internal",
    ),
    "extent-derived destination": (
        "name='tag-attribute-extent'",
        "name='tag-attribute-extent'",
    ),
    "content tag": (
        "tag_name='H1' id='tag-attribute-heading'",
        "tag_name='H1' id='tag-attribute-heading'",
    ),
    "content reference": (
        "ref='tag-attribute-heading'",
        "ref='tag-attribute-heading'",
    ),
}
TAG_ATTRIBUTE_RUNTIME_TESTS = (
    "tag attribute matrix invalid attributes map to TagError",
    "backend tag attribute matrix stream output matches file output after normalization",
    "backend tag attribute matrix file output matches direct cairo C oracle",
    "backend tag attribute matrix output contains stable markers",
    "ps svg backend tag attribute matrix omits pdf tag metadata",
)


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


def check_tag_attribute_coverage() -> list[str]:
    errors: list[str] = []
    try:
        c_text = read_text(TAG_ATTRIBUTE_C)
    except OSError as exc:
        return [f"{TAG_ATTRIBUTE_C}: cannot read tag attribute C oracle: {exc}"]
    try:
        moonbit_text = read_text(TAG_ATTRIBUTE_MOONBIT)
    except OSError as exc:
        return [
            f"{TAG_ATTRIBUTE_MOONBIT}: cannot read tag attribute MoonBit tests: {exc}"
        ]

    for feature, (c_anchor, moonbit_anchor) in TAG_ATTRIBUTE_REQUIREMENTS.items():
        if c_anchor not in c_text:
            errors.append(
                f"{TAG_ATTRIBUTE_C}: missing direct C tag evidence for {feature!r}: "
                f"{c_anchor!r}"
            )
        if moonbit_anchor not in moonbit_text:
            errors.append(
                f"{TAG_ATTRIBUTE_MOONBIT}: missing MoonBit tag evidence for "
                f"{feature!r}: {moonbit_anchor!r}"
            )

    for test_name in TAG_ATTRIBUTE_RUNTIME_TESTS:
        if f'test "{test_name}"' not in moonbit_text:
            errors.append(
                f"{TAG_ATTRIBUTE_MOONBIT}: missing tag runtime test {test_name!r}"
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
    errors.extend(check_tag_attribute_coverage())

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    stub_count = len(re.findall(r'"([^"]+\.c)"', read_text(NATIVE_PKG)))
    print(
        f"Vector backend scene wiring ok; {len(scenes)} scenes checked; "
        f"{stub_count} native stubs checked; "
        f"{len(TAG_ATTRIBUTE_REQUIREMENTS)} tag requirements checked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
