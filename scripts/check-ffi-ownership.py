#!/usr/bin/env python3
"""Check cairoon raw C FFI declarations for ownership annotations."""

from __future__ import annotations

import pathlib
import re
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "src"
TEST_PACKAGE_ROOT = PACKAGE_ROOT / "tests"
NATIVE_ROOT = PACKAGE_ROOT / "native"
PUBLIC_FACADE_CALLBACK_SYMBOLS = {
    "cairoon_image_surface_create_from_png_stream",
    "cairoon_pdf_surface_create_for_stream",
    "cairoon_ps_surface_create_for_stream",
    "cairoon_raster_source_pattern_clear_acquire",
    "cairoon_raster_source_pattern_get_acquire_callback",
    "cairoon_raster_source_pattern_get_release_callback",
    "cairoon_raster_source_pattern_has_callbacks",
    "cairoon_raster_source_pattern_set_acquire",
    "cairoon_raster_source_pattern_set_acquire_with_release",
    "cairoon_raster_source_pattern_set_release",
    "cairoon_surface_write_to_png_stream",
    "cairoon_svg_surface_create_for_stream",
}
DIRECT_CAIRO_SYMBOLS = {
    "cairo_format_stride_for_width",
    "cairo_version",
}
OBJECT_TYPES = {
    "Device",
    "FontFace",
    "FontOptions",
    "Path",
    "Region",
    "ScaledFont",
    "Surface",
}
RAW_OBJECT_TYPES = {
    "RawContext",
    "RawDevice",
    "RawFontFace",
    "RawFontOptions",
    "RawImageData",
    "RawMappedImageSurface",
    "RawPath",
    "RawPattern",
    "RawRegion",
    "RawScaledFont",
    "RawSurface",
    "RawTextToGlyphs",
}
DEVICE_CLEANUP_CALLS = {
    "cairoon_device_finish": "cairo_device_finish",
    "cairoon_device_release": "cairo_device_release",
}


def split_top_level(text: str) -> list[str]:
    parts: list[str] = []
    start = 0
    paren_depth = 0
    bracket_depth = 0
    for index, char in enumerate(text):
        if char == "(":
            paren_depth += 1
        elif char == ")":
            paren_depth -= 1
        elif char == "[":
            bracket_depth += 1
        elif char == "]":
            bracket_depth -= 1
        elif char == "," and paren_depth == 0 and bracket_depth == 0:
            part = text[start:index].strip()
            if part:
                parts.append(part)
            start = index + 1
    tail = text[start:].strip()
    if tail:
        parts.append(tail)
    return parts


def parameter_list(signature: str) -> str:
    match = re.search(r'\bfn\s+[A-Za-z0-9_]+\s*\(', signature)
    if match is None:
        raise ValueError("cannot find extern function parameter list")
    start = signature.find("(", match.start())
    depth = 0
    for index in range(start, len(signature)):
        char = signature[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return signature[start + 1 : index]
    raise ValueError("unterminated extern function parameter list")


def parse_annotation(line: str) -> tuple[str, set[str]] | None:
    stripped = line.strip()
    match = re.match(r"#(borrow|owned)\(([^)]*)\)$", stripped)
    if match is None:
        return None
    names = {name.strip() for name in match.group(2).split(",") if name.strip()}
    return match.group(1), names


def parse_params(signature: str) -> dict[str, str]:
    params: dict[str, str] = {}
    for part in split_top_level(parameter_list(signature)):
        if ":" not in part:
            continue
        name, type_ = part.split(":", 1)
        params[name.strip()] = " ".join(type_.split())
    return params


def requires_annotation(type_: str) -> bool:
    head = re.split(r"[\s\[\(]", type_, maxsplit=1)[0]
    base = head.rsplit(".", maxsplit=1)[-1]
    if base in OBJECT_TYPES or base in RAW_OBJECT_TYPES:
        return True
    return (
        "Bytes" in type_
        or "String" in type_
        or "Ref[" in type_
        or "FixedArray[" in type_
        or "FuncRef[" in type_
        or "->" in type_
    )


def collect_extern(lines: list[str], start: int) -> tuple[str, int]:
    parts = []
    index = start
    while index < len(lines):
        parts.append(lines[index].strip())
        if "=" in lines[index]:
            break
        index += 1
    return " ".join(parts), index


def check_file(path: pathlib.Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    pending: list[tuple[int, str, set[str]]] = []
    errors: list[str] = []
    index = 0
    while index < len(lines):
        stripped = lines[index].strip()
        if stripped == "///|":
            pending = []
        else:
            parsed = parse_annotation(stripped)
            if parsed is not None:
                kind, names = parsed
                pending.append((index + 1, kind, names))
            elif 'extern "C" fn' in stripped:
                signature, end = collect_extern(lines, index)
                try:
                    params = parse_params(signature)
                except ValueError as exc:
                    errors.append(f"{path}:{index + 1}: {exc}")
                    index = end
                    continue
                annotated = set()
                for _, _, names in pending:
                    annotated.update(names)
                for name, type_ in params.items():
                    if requires_annotation(type_) and name not in annotated:
                        errors.append(
                            f"{path}:{index + 1}: parameter '{name}' of type "
                            f"'{type_}' needs #borrow or #owned"
                        )
                for line_no, kind, names in pending:
                    for name in names:
                        if name not in params:
                            errors.append(
                                f"{path}:{line_no}: #{kind} references unknown "
                                f"parameter '{name}'"
                            )
                pending = []
                index = end
        index += 1
    return errors


def extern_symbols(path: pathlib.Path) -> list[tuple[str, int]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    symbols: list[tuple[str, int]] = []
    index = 0
    while index < len(lines):
        if 'extern "C" fn' not in lines[index]:
            index += 1
            continue
        signature, end = collect_extern(lines, index)
        match = re.search(r'=\s*"([^"]+)"', signature)
        if match is not None:
            symbols.append((match.group(1), index + 1))
        index = end + 1
    return symbols


def iter_production_ffi_files() -> list[pathlib.Path]:
    return [
        path
        for path in sorted(PACKAGE_ROOT.rglob("ffi*.mbt"))
        if TEST_PACKAGE_ROOT not in path.parents
    ]


def native_export_symbols() -> dict[str, list[str]]:
    exports: dict[str, list[str]] = {}
    pattern = re.compile(r"\bMOONBIT_FFI_EXPORT\b(.*?\{)", re.DOTALL)
    for path in sorted(NATIVE_ROOT.glob("*.c")):
        text = path.read_text(encoding="utf-8")
        for match in pattern.finditer(text):
            names = re.findall(r"\b(cairoon_[A-Za-z0-9_]+)\s*\(", match.group(1))
            if not names:
                continue
            line_no = text.count("\n", 0, match.start()) + 1
            exports.setdefault(names[-1], []).append(f"{path}:{line_no}")
    return exports


def braced_body(text: str, start: int) -> str | None:
    depth = 0
    for index in range(start, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[start + 1 : index]
    return None


def c_function_body(text: str, symbol: str) -> str | None:
    match = re.search(rf"\b{re.escape(symbol)}\s*\([^{{]*\)\s*{{", text)
    if match is None:
        return None
    return braced_body(text, text.find("{", match.start()))


def mbt_method_body(text: str, symbol: str) -> str | None:
    match = re.search(
        rf"^\s*pub\s+fn(?:\[[^]]+\])?\s+{re.escape(symbol)}\s*\(",
        text,
        re.MULTILINE,
    )
    if match is None:
        return None
    start = text.find("{", match.end())
    if start < 0:
        return None
    return braced_body(text, start)


def check_device_cleanup_order() -> list[str]:
    path = NATIVE_ROOT / "cairoon_device.c"
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
            errors.append(
                f"{path}: '{wrapper}' must call {cleanup}(device->ptr)"
            )
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


def check_device_scope_cleanup() -> list[str]:
    path = PACKAGE_ROOT / "device.mbt"
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
        if re.search(
            rf"\bself\.{checked_cleanup}\s*\(\s*\)", error_path
        ):
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


def check_mapped_image_cleanup_order() -> list[str]:
    path = NATIVE_ROOT / "cairoon_mapped_image_surface.c"
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
        errors.append(
            f"{path}: '{helper}' must unmap the captured base/image pair"
        )
        return errors

    before_unmap = body[: unmap_match.start()]
    first_status = re.search(r"\bcairo_surface_status\s*\(", before_unmap)
    if first_status is None:
        errors.append(
            f"{path}: '{helper}' must capture sticky statuses before cleanup"
        )
    elif re.search(r"\breturn\b", before_unmap[first_status.start() :]):
        errors.append(
            f"{path}: '{helper}' must not let sticky status skip unmap"
        )

    after_unmap = body[unmap_match.end() :]
    clear_base = re.search(r"\bmapped->base\s*=\s*NULL\s*;", after_unmap)
    clear_image = re.search(r"\bmapped->mapped\s*=\s*NULL\s*;", after_unmap)
    decref = re.search(r"\bmoonbit_decref\s*\(\s*mapped->base_object\s*\)", after_unmap)
    if clear_base is None or clear_image is None or decref is None:
        errors.append(
            f"{path}: '{helper}' must clear both handles and release base_object "
            "after unmap"
        )

    wrappers = {
        "cairoon_surface_unmap_image": r"return\s+" + helper
        + r"\s*\(\s*mapped\s*,\s*surface->ptr\s*\)\s*;",
        "cairoon_mapped_image_surface_unmap": r"return\s+" + helper
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
        if re.search(r"\bcairoon_(?:surface|mapped_image_surface)_status\s*\(", wrapper_body):
            errors.append(
                f"{path}: '{wrapper}' must not let a status precheck skip cleanup"
            )
    return errors


def check_mapped_image_scope_cleanup() -> list[str]:
    path = PACKAGE_ROOT / "mapped_image_surface.mbt"
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


def main() -> int:
    errors: list[str] = []
    errors.extend(check_device_cleanup_order())
    errors.extend(check_device_scope_cleanup())
    errors.extend(check_mapped_image_cleanup_order())
    errors.extend(check_mapped_image_scope_cleanup())
    files = iter_production_ffi_files()
    declarations: dict[str, list[str]] = {}
    for path in files:
        errors.extend(check_file(path))
        for symbol, line_no in extern_symbols(path):
            declarations.setdefault(symbol, []).append(f"{path}:{line_no}")
    for symbol, locations in sorted(declarations.items()):
        if len(locations) > 1:
            errors.append(
                f"C symbol '{symbol}' is declared more than once: "
                + ", ".join(locations)
            )
    root_symbols = {
        symbol
        for path in files
        if path.parent == PACKAGE_ROOT
        for symbol, _ in extern_symbols(path)
    }
    extra_root_symbols = root_symbols - PUBLIC_FACADE_CALLBACK_SYMBOLS
    missing_root_symbols = PUBLIC_FACADE_CALLBACK_SYMBOLS - root_symbols
    if extra_root_symbols:
        errors.append(
            "public facade declares non-callback C symbols: "
            + ", ".join(sorted(extra_root_symbols))
        )
    if missing_root_symbols:
        errors.append(
            "public facade callback allowlist is stale; missing declarations: "
            + ", ".join(sorted(missing_root_symbols))
        )

    exports = native_export_symbols()
    for symbol, locations in sorted(exports.items()):
        if len(locations) > 1:
            errors.append(
                f"C symbol '{symbol}' is exported more than once: "
                + ", ".join(locations)
            )
    declared_symbols = set(declarations)
    local_declared_symbols = declared_symbols - DIRECT_CAIRO_SYMBOLS
    exported_symbols = set(exports)
    missing_exports = local_declared_symbols - exported_symbols
    dead_exports = exported_symbols - local_declared_symbols
    if missing_exports:
        errors.append(
            "production externs lack MOONBIT_FFI_EXPORT definitions: "
            + ", ".join(sorted(missing_exports))
        )
    if dead_exports:
        errors.append(
            "native stubs export undeclared production symbols: "
            + ", ".join(sorted(dead_exports))
        )
    unknown_direct_symbols = DIRECT_CAIRO_SYMBOLS - declared_symbols
    if unknown_direct_symbols:
        errors.append(
            "direct libcairo symbol allowlist is stale: "
            + ", ".join(sorted(unknown_direct_symbols))
        )
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(
        "FFI ownership, facade boundary, and C export parity ok for "
        f"{len(local_declared_symbols)} native symbols plus "
        f"{len(DIRECT_CAIRO_SYMBOLS)} direct libcairo symbols in "
        f"{len(files)} production files"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
