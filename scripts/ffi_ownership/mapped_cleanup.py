"""Mapped-image native and scoped-cleanup ownership guards."""

from __future__ import annotations

import pathlib
import re

from .source import c_function_body, mbt_method_body


def check_mapped_image_cleanup_order(native_root: pathlib.Path) -> list[str]:
    path = native_root / "cairoon_mapped_image_surface.c"
    text = path.read_text(encoding="utf-8")
    errors: list[str] = []
    helper = "cairoon_mapped_image_surface_unmap_internal"
    body = c_function_body(text, helper)
    if body is None:
        return [f"{path}: cannot find complete body for '{helper}'"]

    unmap_match = re.search(
        r"\bcairo_surface_unmap_image\s*\(\s*base\s*,\s*image\s*\)\s*;",
        body,
    )
    if unmap_match is None:
        errors.append(f"{path}: '{helper}' must unmap the captured base/image pair")
        return errors

    before_unmap = body[: unmap_match.start()]
    first_status = re.search(r"\bcairo_surface_status\s*\(", before_unmap)
    if first_status is None:
        errors.append(f"{path}: '{helper}' must capture sticky statuses before cleanup")
    elif re.search(r"\breturn\b", before_unmap[first_status.start() :]):
        errors.append(f"{path}: '{helper}' must not let sticky status skip unmap")

    after_unmap = body[unmap_match.end() :]
    clear_base = re.search(r"\bmapped->base\s*=\s*NULL\s*;", after_unmap)
    clear_image = re.search(r"\bmapped->mapped\s*=\s*NULL\s*;", after_unmap)
    decref = re.search(
        r"\bmoonbit_decref\s*\(\s*mapped->base_object\s*\)", after_unmap
    )
    if clear_base is None or clear_image is None or decref is None:
        errors.append(
            f"{path}: '{helper}' must clear both handles and release base_object "
            "after unmap"
        )

    wrappers = {
        "cairoon_surface_unmap_image": r"return\s+"
        + helper
        + r"\s*\(\s*mapped\s*,\s*surface->ptr\s*\)\s*;",
        "cairoon_mapped_image_surface_unmap": r"return\s+"
        + helper
        + r"\s*\(\s*mapped\s*,\s*NULL\s*\)\s*;",
    }
    for wrapper, call_pattern in wrappers.items():
        wrapper_body = c_function_body(text, wrapper)
        if wrapper_body is None:
            errors.append(f"{path}: cannot find complete body for '{wrapper}'")
            continue
        if re.search(call_pattern, wrapper_body) is None:
            errors.append(
                f"{path}: '{wrapper}' must delegate exact-once cleanup to '{helper}'"
            )
        if re.search(
            r"\bcairoon_(?:surface|mapped_image_surface)_status\s*\(",
            wrapper_body,
        ):
            errors.append(
                f"{path}: '{wrapper}' must not let a status precheck skip cleanup"
            )
    return errors


def check_mapped_image_scope_cleanup(package_root: pathlib.Path) -> list[str]:
    path = package_root / "mapped_image_surface.mbt"
    text = path.read_text(encoding="utf-8")
    method = "MappedImageSurface::with_unmapped"
    body = mbt_method_body(text, method)
    if body is None:
        return [f"{path}: cannot find complete body for '{method}'"]
    parts = body.split("} noraise {", maxsplit=1)
    if len(parts) != 2:
        return [f"{path}: '{method}' must have catch and noraise paths"]

    errors: list[str] = []
    error_path, success_path = parts
    raw_match = re.search(
        r"let\s+_\s*=\s*@surface_impl\.mapped_unmap_raw\s*\(\s*"
        r"self\.to_raw\s*\(\s*\)\s*\)",
        error_path,
    )
    raise_match = re.search(r"\braise\s+err\b", error_path)
    if raw_match is None:
        errors.append(
            f"{path}: '{method}' error path must attempt raw unmap and ignore "
            "cleanup status"
        )
    if re.search(r"\bself\.unmap\s*\(\s*\)", error_path):
        errors.append(
            f"{path}: '{method}' error path must not let checked unmap replace "
            "the closure error"
        )
    if raw_match is not None and (
        raise_match is None or raw_match.start() > raise_match.start()
    ):
        errors.append(
            f"{path}: '{method}' must attempt unmap before re-raising the "
            "closure error"
        )
    if re.search(r"\bself\.unmap\s*\(\s*\)", success_path) is None:
        errors.append(
            f"{path}: '{method}' success path must report checked unmap failures"
        )
    return errors
