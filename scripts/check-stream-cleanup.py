#!/usr/bin/env python3
"""Enforce callback-state ownership on native stream constructor failures."""

from __future__ import annotations

import pathlib
import re
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
NATIVE_ROOT = REPO_ROOT / "src" / "native"
SURFACE_CONSTRUCTORS = (
    ("cairoon_pdf_surface.c", "cairoon_pdf_surface_create_for_stream"),
    ("cairoon_ps_surface.c", "cairoon_ps_surface_create_for_stream"),
    ("cairoon_svg_surface.c", "cairoon_svg_surface_create_for_stream"),
)


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
    match = re.search(rf"\b{re.escape(name)}\s*\([^;{{]*\)\s*\{{", source, re.S)
    if match is None:
        return None
    brace = source.find("{", match.start())
    return extract_braced(source, brace)


def block_after(body: str, marker: str, condition: str) -> str | None:
    match = re.search(
        rf"{re.escape(marker)}\s*{re.escape(condition)}\s*\{{",
        body,
        re.S,
    )
    if match is None:
        return None
    brace = match.end() - 1
    return extract_braced(body, brace)


def condition_block(body: str, condition: str) -> str | None:
    match = re.search(rf"{re.escape(condition)}\s*\{{", body, re.S)
    if match is None:
        return None
    return extract_braced(body, match.end() - 1)


def require_order(
    block: str | None,
    markers: tuple[str, ...],
    location: str,
) -> list[str]:
    if block is None:
        return [f"{location}: required failure block is missing"]
    positions = [block.find(marker) for marker in markers]
    missing = [marker for marker, position in zip(markers, positions) if position < 0]
    if missing:
        return [f"{location}: failure block is missing {marker!r}" for marker in missing]
    if positions != sorted(positions):
        return [
            f"{location}: cleanup must destroy the native producer before "
            "releasing its stream state"
        ]
    return []


def check_cleanup_helpers(native_root: pathlib.Path) -> list[str]:
    path = native_root / "cairoon_stream.c"
    source = path.read_text(encoding="utf-8")
    errors: list[str] = []
    helpers = (
        (
            "cairoon_stream_surface_cleanup_failure",
            "surface",
            "cairo_surface_destroy(surface);",
        ),
        (
            "cairoon_stream_device_cleanup_failure",
            "device",
            "cairo_device_destroy(device);",
        ),
    )
    for name, producer, destroy in helpers:
        body = extract_function(source, name)
        location = f"{path}:{name}"
        if body is None:
            errors.append(f"{location}: missing shared failure cleanup helper")
            continue
        guard = condition_block(body, f"if ({producer} != NULL)")
        if guard is None or destroy not in guard:
            errors.append(
                f"{location}: must null-check and destroy the native producer"
            )
        errors.extend(
            require_order(
                body,
                (destroy, "cairoon_stream_state_destroy(state);"),
                location,
            )
        )
    return errors


def check_attach_helpers(native_root: pathlib.Path) -> list[str]:
    path = native_root / "cairoon_stream.c"
    source = path.read_text(encoding="utf-8")
    errors: list[str] = []
    helpers = (
        (
            "cairoon_stream_attach",
            "cairo_surface_set_user_data",
            "surface",
        ),
        (
            "cairoon_stream_attach_device",
            "cairo_device_set_user_data",
            "device",
        ),
    )
    for name, setter, producer in helpers:
        body = extract_function(source, name)
        if body is None:
            errors.append(f"{path}: missing {name}")
            continue
        if re.search(r"\bcairoon_stream_state_destroy\s*\(\s*state\s*\)", body):
            errors.append(
                f"{path}: {name} must leave state owned by its caller on failure"
            )
        transfer = re.search(
            rf"\breturn\s+{setter}\s*\(\s*{producer}\s*,\s*"
            r"&cairoon_stream_state_key\s*,\s*state\s*,\s*"
            r"cairoon_stream_state_destroy\s*\)\s*;",
            body,
            re.S,
        )
        if transfer is None:
            errors.append(
                f"{path}: {name} must return the Cairo user-data attachment "
                "status and transfer state with cairoon_stream_state_destroy"
            )
    return errors


def check_surface_constructor(
    path: pathlib.Path,
    function_name: str,
) -> list[str]:
    source = path.read_text(encoding="utf-8")
    body = extract_function(source, function_name)
    if body is None:
        return [f"{path}: missing {function_name}"]

    status_marker = "status = cairo_surface_status(surface);"
    status_block = block_after(
        body,
        status_marker,
        "if (status != CAIRO_STATUS_SUCCESS)",
    )
    attach_marker = "status = cairoon_stream_attach(surface, state);"
    attach_block = block_after(
        body,
        attach_marker,
        "if (status != CAIRO_STATUS_SUCCESS)",
    )
    null_block = condition_block(body, "if (surface == NULL)")
    cleanup = "cairoon_stream_surface_cleanup_failure(surface, state);"
    failure_return = "return cairoon_surface_wrap_owned(NULL);"
    errors: list[str] = []
    errors.extend(
        require_order(
            null_block,
            (cleanup, "*status_out = CAIRO_STATUS_NO_MEMORY;", failure_return),
            f"{path}:{function_name} null-surface failure",
        )
    )
    errors.extend(
        require_order(
            status_block,
            (cleanup, "*status_out = status;", failure_return),
            f"{path}:{function_name} native-status failure",
        )
    )
    errors.extend(
        require_order(
            attach_block,
            (cleanup, "*status_out = status;", failure_return),
            f"{path}:{function_name} attach failure",
        )
    )
    if body.count(cleanup) != 3:
        errors.append(
            f"{path}:{function_name}: all three pre-transfer failures must use "
            "the shared Surface cleanup helper"
        )
    if body.find(status_marker) > body.find(attach_marker) >= 0:
        errors.append(f"{path}:{function_name}: native status must be checked before attach")
    return errors


def check_device_constructor(native_root: pathlib.Path) -> list[str]:
    path = native_root / "cairoon_device.c"
    source = path.read_text(encoding="utf-8")
    name = "cairoon_script_device_create_for_stream"
    body = extract_function(source, name)
    if body is None:
        return [f"{path}: missing {name}"]

    status_block = block_after(
        body,
        "*status_out = cairo_device_status(device);",
        "if (*status_out != CAIRO_STATUS_SUCCESS)",
    )
    attach_block = block_after(
        body,
        "*status_out = cairoon_stream_attach_device(device, state);",
        "if (*status_out != CAIRO_STATUS_SUCCESS)",
    )
    null_block = condition_block(body, "if (device == NULL)")
    cleanup = "cairoon_stream_device_cleanup_failure(device, state);"
    failure_return = "return cairoon_device_wrap_owned(NULL);"
    errors: list[str] = []
    errors.extend(
        require_order(
            null_block,
            (cleanup, "*status_out = CAIRO_STATUS_NO_MEMORY;", failure_return),
            f"{path}:{name} null-device failure",
        )
    )
    for label, block in (("native-status", status_block), ("attach", attach_block)):
        errors.extend(
            require_order(
                block,
                (cleanup, failure_return),
                f"{path}:{name} {label} failure",
            )
        )
    if body.count(cleanup) != 3:
        errors.append(
            f"{path}:{name}: all three pre-transfer failures must use the "
            "shared Device cleanup helper"
        )
    return errors


def check_stream_cleanup(native_root: pathlib.Path = NATIVE_ROOT) -> list[str]:
    errors = check_cleanup_helpers(native_root)
    errors.extend(check_attach_helpers(native_root))
    for filename, function_name in SURFACE_CONSTRUCTORS:
        errors.extend(check_surface_constructor(native_root / filename, function_name))
    errors.extend(check_device_constructor(native_root))
    return errors


def main() -> int:
    errors = check_stream_cleanup()
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print("Stream constructor cleanup order and callback-state ownership ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
