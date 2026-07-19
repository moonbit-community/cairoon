"""Surface native and scoped-cleanup ownership guards."""

from __future__ import annotations

import pathlib
import re

from .source import (
    c_function_body,
    c_statement_is_unconditional,
    mbt_handler_body,
    mbt_method_body,
)


def check_surface_cleanup_order(native_root: pathlib.Path) -> list[str]:
    path = native_root / "cairoon_surface.c"
    text = path.read_text(encoding="utf-8")
    wrapper = "cairoon_surface_finish"
    body = c_function_body(text, wrapper)
    if body is None:
        return [f"{path}: cannot find complete body for '{wrapper}'"]

    errors: list[str] = []
    original_pattern = re.compile(
        r"^[ \t]*cairo_status_t\s+original_status\s*=\s*"
        r"cairo_surface_status\s*\(\s*surface->ptr\s*\)\s*;[ \t]*$",
        re.MULTILINE,
    )
    marker_pattern = re.compile(
        r"^[ \t]*cairo_status_t\s+marker_status\s*=\s*"
        r"CAIRO_STATUS_SUCCESS\s*;[ \t]*$",
        re.MULTILINE,
    )
    finish_pattern = re.compile(
        r"^[ \t]*cairo_surface_finish\s*\(\s*surface->ptr\s*\)\s*;[ \t]*$",
        re.MULTILINE,
    )
    finish_status_pattern = re.compile(
        r"^[ \t]*cairo_status_t\s+finish_status\s*=\s*"
        r"cairo_surface_status\s*\(\s*surface->ptr\s*\)\s*;[ \t]*$",
        re.MULTILINE,
    )
    release_pattern = re.compile(
        r"^[ \t]*(?:(?:cairo_status_t\s+)?data_status\s*=\s*)?"
        r"cairoon_image_surface_release_data\s*\(\s*surface->ptr\s*\)\s*;"
        r"[ \t]*$",
        re.MULTILINE,
    )

    statement_specs = (
        ("original status capture", original_pattern),
        ("marker status initialization", marker_pattern),
        ("cairo_surface_finish(surface->ptr)", finish_pattern),
        ("finish status capture", finish_status_pattern),
        ("retained image-data release", release_pattern),
    )
    matches: dict[str, re.Match[str]] = {}
    for description, pattern in statement_specs:
        found = list(pattern.finditer(body))
        if len(found) != 1:
            errors.append(
                f"{path}: '{wrapper}' must contain exactly one top-level "
                f"candidate for {description}"
            )
            continue
        matches[description] = found[0]
        if not c_statement_is_unconditional(body, found[0]):
            errors.append(
                f"{path}: '{wrapper}' must execute {description} "
                "unconditionally at function-body top level"
            )

    finish_match = matches.get("cairo_surface_finish(surface->ptr)")
    if finish_match is None:
        return [
            *errors,
            f"{path}: '{wrapper}' must call cairo_surface_finish(surface->ptr)",
        ]

    before_finish = body[: finish_match.start()]
    null_guard_pattern = (
        r"if\s*\(\s*surface\s*==\s*NULL\s*\|\|\s*"
        r"surface->ptr\s*==\s*NULL\s*\)\s*\{\s*"
        r"return\s+CAIRO_STATUS_NULL_POINTER\s*;\s*\}"
    )
    if not re.search(null_guard_pattern, before_finish):
        errors.append(
            f"{path}: '{wrapper}' must reject a null wrapper or pointer "
            "before cleanup"
        )
    if len(re.findall(r"\breturn\b", before_finish)) != 1:
        errors.append(
            f"{path}: '{wrapper}' may only return for a null pointer before "
            "cairo_surface_finish(surface->ptr)"
        )
    status_match = matches.get("original status capture")
    if status_match is None:
        errors.append(f"{path}: '{wrapper}' must capture sticky status before finish")
    elif re.search(r"\breturn\b", before_finish[status_match.start() :]):
        errors.append(
            f"{path}: '{wrapper}' must not let sticky status skip "
            "cairo_surface_finish(surface->ptr)"
        )

    release_match = matches.get("retained image-data release")
    if release_match is None:
        errors.append(
            f"{path}: '{wrapper}' must release retained image data after finish"
        )
    else:
        exact_release = re.fullmatch(
            r"[ \t]*cairo_status_t\s+data_status\s*=\s*"
            r"cairoon_image_surface_release_data\s*\(\s*surface->ptr\s*\)\s*;"
            r"[ \t]*",
            release_match.group(0),
        )
        if exact_release is None:
            errors.append(
                f"{path}: '{wrapper}' must capture retained image-data release "
                "status in data_status"
            )
        if release_match.start() > finish_match.end() and re.search(
            r"\breturn\b", body[finish_match.end() : release_match.start()]
        ):
            errors.append(
                f"{path}: '{wrapper}' must not return before releasing retained "
                "image data"
            )

        ordered_names = (
            "original status capture",
            "marker status initialization",
            "cairo_surface_finish(surface->ptr)",
            "finish status capture",
            "retained image-data release",
        )
        if all(name in matches for name in ordered_names):
            ordered = [matches[name] for name in ordered_names]
            order_is_valid = not any(
                current.start() >= following.start()
                for current, following in zip(ordered, ordered[1:])
            )
            if not order_is_valid:
                errors.append(
                    f"{path}: '{wrapper}' must capture statuses and perform "
                    "cleanup in order: original, marker, finish, finish status, "
                    "retained-data release"
                )
            else:
                original_match = matches["original status capture"]
                marker_match = matches["marker status initialization"]
                finish_status_match = matches["finish status capture"]
                if re.fullmatch(
                    rf"\s*{null_guard_pattern}\s*",
                    body[: original_match.start()],
                ) is None:
                    errors.append(
                        f"{path}: '{wrapper}' must begin with only the null "
                        "guard before original status capture"
                    )
                if body[original_match.end() : marker_match.start()].strip():
                    errors.append(
                        f"{path}: '{wrapper}' must initialize marker status "
                        "immediately after original status capture"
                    )
                marker_block = body[marker_match.end() : finish_match.start()]
                if re.fullmatch(
                    r"\s*if\s*\(\s*!\s*cairoon_surface_is_finished\s*\(\s*"
                    r"surface->ptr\s*\)\s*\)\s*\{\s*"
                    r"marker_status\s*=\s*cairo_surface_set_user_data\s*\(\s*"
                    r"surface->ptr\s*,\s*&cairoon_surface_finished_key\s*,\s*"
                    r"\(\s*void\s*\*\s*\)\s*"
                    r"&cairoon_surface_finished_sentinel\s*,\s*NULL\s*\)\s*;"
                    r"\s*\}\s*",
                    marker_block,
                ) is None:
                    errors.append(
                        f"{path}: '{wrapper}' must install the finished marker "
                        "with the exact guarded user-data block before cleanup"
                    )
                if body[finish_match.end() : finish_status_match.start()].strip():
                    errors.append(
                        f"{path}: '{wrapper}' must capture finish status "
                        "immediately after cairo_surface_finish"
                    )
                if body[finish_status_match.end() : release_match.start()].strip():
                    errors.append(
                        f"{path}: '{wrapper}' must release retained image data "
                        "immediately after finish status capture"
                    )

        if re.search(r"\b(?:goto|break|continue)\b", body[: release_match.start()]):
            errors.append(
                f"{path}: '{wrapper}' must not use control transfer before "
                "retained image-data release"
            )

        precedence = body[release_match.end() :]
        if not re.fullmatch(
            r"\s*"
            r"if\s*\(\s*original_status\s*!=\s*CAIRO_STATUS_SUCCESS\s*\)\s*"
            r"\{\s*return\s+original_status\s*;\s*\}\s*"
            r"if\s*\(\s*marker_status\s*!=\s*CAIRO_STATUS_SUCCESS\s*\)\s*"
            r"\{\s*return\s+marker_status\s*;\s*\}\s*"
            r"return\s+finish_status\s*==\s*CAIRO_STATUS_SUCCESS\s*\?\s*"
            r"data_status\s*:\s*finish_status\s*;\s*",
            precedence,
        ):
            errors.append(
                f"{path}: '{wrapper}' must preserve status precedence: "
                "original, marker, finish, then retained-data release"
            )
    return errors


def check_surface_scope_cleanup(package_root: pathlib.Path) -> list[str]:
    path = package_root / "surface.mbt"
    text = path.read_text(encoding="utf-8")
    method = "Surface::with_finished"
    body = mbt_method_body(text, method)
    if body is None:
        return [f"{path}: cannot find complete body for '{method}'"]
    parts = body.split("} noraise {", maxsplit=1)
    if len(parts) != 2:
        return [f"{path}: '{method}' must have catch and noraise paths"]

    error_path, success_path = parts
    catch_body = mbt_handler_body(error_path, "err")
    success_body = mbt_handler_body(success_path, "value")
    if catch_body is None or success_body is None:
        return [f"{path}: '{method}' must have err and value handler blocks"]

    errors: list[str] = []
    raw_match = re.search(
        r"let\s+_\s*=\s*@surface_impl\.finish_raw\s*\(\s*"
        r"self\.to_raw\s*\(\s*\)\s*\)",
        catch_body,
    )
    raise_match = re.search(r"\braise\s+err\b", catch_body)
    if raw_match is None:
        errors.append(
            f"{path}: '{method}' error path must attempt raw finish and ignore "
            "cleanup status"
        )
    if re.search(r"\bself\.finish\s*\(\s*\)", catch_body):
        errors.append(
            f"{path}: '{method}' error path must not let checked finish replace "
            "the closure error"
        )
    if raw_match is not None and (
        raise_match is None or raw_match.start() > raise_match.start()
    ):
        errors.append(
            f"{path}: '{method}' must attempt finish before re-raising the "
            "closure error"
        )
    if re.fullmatch(
        r"\s*let\s+_\s*=\s*@surface_impl\.finish_raw\s*\(\s*"
        r"self\.to_raw\s*\(\s*\)\s*\)\s*raise\s+err\s*",
        catch_body,
    ) is None:
        errors.append(
            f"{path}: '{method}' error path must unconditionally execute raw "
            "finish first and then re-raise the closure error"
        )
    if re.search(r"\bself\.finish\s*\(\s*\)", success_body) is None:
        errors.append(
            f"{path}: '{method}' success path must report checked finish failures"
        )
    if re.fullmatch(
        r"\s*self\.finish\s*\(\s*\)\s*value\s*",
        success_body,
    ) is None:
        errors.append(
            f"{path}: '{method}' success path must unconditionally execute "
            "checked finish before returning the closure value"
        )
    return errors
