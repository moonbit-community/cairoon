"""Device native and scoped-cleanup ownership guards."""

from __future__ import annotations

import pathlib
import re

from .source import c_function_body, mbt_method_body


DEVICE_CLEANUP_CALLS = {
    "cairoon_device_finish": "cairo_device_finish",
    "cairoon_device_release": "cairo_device_release",
}


def check_device_cleanup_order(native_root: pathlib.Path) -> list[str]:
    path = native_root / "cairoon_device.c"
    text = path.read_text(encoding="utf-8")
    errors: list[str] = []
    for wrapper, cleanup in DEVICE_CLEANUP_CALLS.items():
        body = c_function_body(text, wrapper)
        if body is None:
            errors.append(f"{path}: cannot find complete body for '{wrapper}'")
            continue
        cleanup_match = re.search(
            rf"\b{re.escape(cleanup)}\s*\(\s*device->ptr\s*\)\s*;", body
        )
        if cleanup_match is None:
            errors.append(f"{path}: '{wrapper}' must call {cleanup}(device->ptr)")
            continue
        before_cleanup = body[: cleanup_match.start()]
        after_cleanup = body[cleanup_match.end() :]
        if not re.search(
            r"if\s*\(\s*device\s*==\s*NULL\s*\|\|\s*"
            r"device->ptr\s*==\s*NULL\s*\)\s*\{\s*"
            r"return\s+CAIRO_STATUS_NULL_POINTER\s*;\s*\}",
            before_cleanup,
        ):
            errors.append(
                f"{path}: '{wrapper}' must reject a null wrapper or pointer "
                "before cleanup"
            )
        if len(re.findall(r"\breturn\b", before_cleanup)) != 1:
            errors.append(
                f"{path}: '{wrapper}' may only return for a null pointer "
                "before cleanup"
            )
        if re.search(r"\bcairo(?:on)?_device_status\s*\(", before_cleanup):
            errors.append(
                f"{path}: '{wrapper}' must not let sticky device status skip "
                f"{cleanup}(device->ptr)"
            )
        if not re.search(
            r"return\s+cairo_device_status\s*\(\s*device->ptr\s*\)\s*;",
            after_cleanup,
        ):
            errors.append(
                f"{path}: '{wrapper}' must report device status after cleanup"
            )
    return errors


def check_device_scope_cleanup(package_root: pathlib.Path) -> list[str]:
    path = package_root / "device.mbt"
    text = path.read_text(encoding="utf-8")
    errors: list[str] = []
    methods = {
        "Device::with_acquired": ("release_raw", "release"),
        "Device::with_finished": ("finish_raw", "finish"),
    }
    for method, (raw_cleanup, checked_cleanup) in methods.items():
        body = mbt_method_body(text, method)
        if body is None:
            errors.append(f"{path}: cannot find complete body for '{method}'")
            continue
        parts = body.split("} noraise {", maxsplit=1)
        if len(parts) != 2:
            errors.append(f"{path}: '{method}' must have catch and noraise paths")
            continue
        error_path, success_path = parts
        raw_match = re.search(
            rf"let\s+_\s*=\s*@device_impl\.{raw_cleanup}\s*\(\s*"
            r"self\.to_raw\s*\(\s*\)\s*\)",
            error_path,
        )
        raise_match = re.search(r"\braise\s+err\b", error_path)
        if raw_match is None:
            errors.append(
                f"{path}: '{method}' error path must attempt "
                f"@device_impl.{raw_cleanup} and ignore cleanup status"
            )
        if re.search(rf"\bself\.{checked_cleanup}\s*\(\s*\)", error_path):
            errors.append(
                f"{path}: '{method}' error path must not let checked "
                f"{checked_cleanup} replace the closure error"
            )
        if raw_match is not None and (
            raise_match is None or raw_match.start() > raise_match.start()
        ):
            errors.append(
                f"{path}: '{method}' must attempt cleanup before re-raising "
                "the closure error"
            )
        if not re.search(
            rf"\bself\.{checked_cleanup}\s*\(\s*\)", success_path
        ):
            errors.append(
                f"{path}: '{method}' success path must report checked "
                f"{checked_cleanup} failures"
            )
    return errors
