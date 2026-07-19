#!/usr/bin/env python3
"""Check cairoon's package layout migration rules."""

from __future__ import annotations

import pathlib
import sys


SCRIPT_ROOT = pathlib.Path(__file__).resolve().parent
if str(SCRIPT_ROOT) not in sys.path:
    sys.path.insert(0, str(SCRIPT_ROOT))

from project_layout.common import (
    NATIVE_TARGETS,
    PACKAGE_CONFIG_NAMES,
    SOURCE_SUFFIXES,
    STRICT_STUB_CFLAGS,
    count_files,
    count_recursive_files,
    is_public_root_file,
    is_source_like,
    read_filename_allowlist,
    read_native_stubs,
    read_native_targets,
)
from project_layout.counters import (
    check_layout_counters as _check_layout_counters,
    checked_package_count_paths as _checked_package_count_paths,
    require_layout_count as _require_layout_count,
)
from project_layout.metadata import (
    EXECUTABLE_MBT_CHECK_BLOCK,
    REFERENCE_DOC_INDEX_ENTRY,
    check_integration_fixture as _check_integration_fixture,
    check_public_package_root_freeze as _check_public_package_root_freeze,
    check_reference_docs as _check_reference_docs,
    check_root_freeze as _check_root_freeze,
    check_source_root as _check_source_root,
    markdown_level_two_section,
)
from project_layout.native import (
    check_ffi_native_targets as _check_ffi_native_targets,
    check_native_build_configuration as _check_native_build_configuration,
    check_native_package as _check_native_package,
    check_nested_c_files as _check_nested_c_files,
    check_nested_packages as _check_nested_packages,
    iter_production_ffi_files as _iter_production_ffi_files,
)


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "src"
TEST_PACKAGE_ROOT = PACKAGE_ROOT / "tests"
DOC_PACKAGE_DIR = PACKAGE_ROOT / "docs"
ROOT_README = REPO_ROOT / "README.md"
PUBLIC_README = PACKAGE_ROOT / "README.mbt.md"
ALLOWLIST = REPO_ROOT / "scripts" / "root-layout-allowlist.txt"
PUBLIC_ROOT_ALLOWLIST = REPO_ROOT / "scripts" / "public-package-root-allowlist.txt"
LAYOUT_DOC = REPO_ROOT / "PROJECT_LAYOUT.md"
MOON_MOD = REPO_ROOT / "moon.mod"
INTEGRATION_ROOT = REPO_ROOT / "integration"
INTEGRATION_WORKSPACE = INTEGRATION_ROOT / "moon.work"
CONSUMER_ROOT = INTEGRATION_ROOT / "consumer"
CONSUMER_MODULE = CONSUMER_ROOT / "moon.mod"
CONSUMER_PACKAGE = CONSUMER_ROOT / "src" / "contract"
CONSUMER_PACKAGE_CONFIG = CONSUMER_PACKAGE / "moon.pkg"
CONSUMER_SOURCES = tuple(
    CONSUMER_PACKAGE / name
    for name in (
        "image_render_test.mbt",
        "mapped_lifecycle_test.mbt",
        "value_error_test.mbt",
        "stream_helpers_test.mbt",
        "png_stream_test.mbt",
        "pdf_stream_test.mbt",
    )
)
NATIVE_PACKAGE_DIR = PACKAGE_ROOT / "native"
NATIVE_PACKAGE_CONFIG = NATIVE_PACKAGE_DIR / "moon.pkg"
CAIRO_BUILD_SCRIPT = REPO_ROOT / "scripts" / "build" / "cairo_config.py"
SANITIZER_PROBE_ROOT = REPO_ROOT / "scripts" / "sanitizers" / "probes"
COUNTED_PACKAGE_ROOTS = (
    PACKAGE_ROOT / "core",
    PACKAGE_ROOT / "internal",
)
REQUIRED_REFERENCE_DOCS = frozenset(
    {
        "backend_surfaces.mbt.md",
        "context.mbt.md",
        "enums.mbt.md",
        "font.mbt.md",
        "matrix.mbt.md",
        "path.mbt.md",
        "pattern.mbt.md",
        "region.mbt.md",
        "status_and_version.mbt.md",
        "surface.mbt.md",
        "value_types.mbt.md",
    }
)


def check_root_freeze(allowed: set[str]) -> list[str]:
    return _check_root_freeze(REPO_ROOT, allowed)


def check_public_package_root_freeze(allowed: set[str]) -> list[str]:
    return _check_public_package_root_freeze(PACKAGE_ROOT, allowed)


def check_source_root() -> list[str]:
    return _check_source_root(REPO_ROOT, PACKAGE_ROOT, MOON_MOD)


def check_reference_docs() -> list[str]:
    return _check_reference_docs(
        DOC_PACKAGE_DIR,
        ROOT_README,
        PUBLIC_README,
        REQUIRED_REFERENCE_DOCS,
    )


def check_integration_fixture() -> list[str]:
    return _check_integration_fixture(
        REPO_ROOT,
        MOON_MOD,
        INTEGRATION_WORKSPACE,
        CONSUMER_MODULE,
        CONSUMER_PACKAGE_CONFIG,
        CONSUMER_SOURCES,
    )


def check_native_package() -> list[str]:
    return _check_native_package(PACKAGE_ROOT, NATIVE_PACKAGE_CONFIG)


def check_native_build_configuration() -> list[str]:
    return _check_native_build_configuration(
        REPO_ROOT,
        PACKAGE_ROOT,
        MOON_MOD,
        CAIRO_BUILD_SCRIPT,
        CONSUMER_PACKAGE_CONFIG,
        STRICT_STUB_CFLAGS,
    )


def check_nested_packages() -> list[str]:
    return _check_nested_packages(REPO_ROOT, PACKAGE_ROOT)


def iter_production_ffi_files() -> list[pathlib.Path]:
    return _iter_production_ffi_files(PACKAGE_ROOT, TEST_PACKAGE_ROOT)


def check_ffi_native_targets() -> list[str]:
    return _check_ffi_native_targets(
        REPO_ROOT,
        PACKAGE_ROOT,
        TEST_PACKAGE_ROOT,
        NATIVE_TARGETS,
    )


def checked_package_count_paths() -> list[str]:
    return _checked_package_count_paths(
        REPO_ROOT,
        PACKAGE_ROOT,
        COUNTED_PACKAGE_ROOTS,
    )


def require_layout_count(
    text: str,
    label: str,
    pattern: str,
    expected: dict[str, int],
) -> list[str]:
    return _require_layout_count(LAYOUT_DOC, text, label, pattern, expected)


def check_layout_counters() -> list[str]:
    return _check_layout_counters(
        REPO_ROOT,
        PACKAGE_ROOT,
        DOC_PACKAGE_DIR,
        TEST_PACKAGE_ROOT,
        NATIVE_PACKAGE_DIR,
        LAYOUT_DOC,
        COUNTED_PACKAGE_ROOTS,
    )


def check_nested_c_files() -> list[str]:
    return _check_nested_c_files(
        REPO_ROOT,
        NATIVE_PACKAGE_DIR,
        NATIVE_PACKAGE_CONFIG,
        SANITIZER_PROBE_ROOT,
    )


def main() -> int:
    errors: list[str] = []
    if not LAYOUT_DOC.exists():
        errors.append(f"{LAYOUT_DOC}: missing package layout plan")
    if not ALLOWLIST.exists():
        errors.append(f"{ALLOWLIST}: missing root source allowlist")
    if not PUBLIC_ROOT_ALLOWLIST.exists():
        errors.append(f"{PUBLIC_ROOT_ALLOWLIST}: missing public package root allowlist")
    if not MOON_MOD.exists():
        errors.append(f"{MOON_MOD}: missing module config")
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    try:
        root_allowed = read_filename_allowlist(ALLOWLIST, "root")
        public_root_allowed = read_filename_allowlist(
            PUBLIC_ROOT_ALLOWLIST,
            "public package root",
        )
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    errors.extend(check_root_freeze(root_allowed))
    errors.extend(check_public_package_root_freeze(public_root_allowed))
    errors.extend(check_source_root())
    errors.extend(check_reference_docs())
    errors.extend(check_integration_fixture())
    errors.extend(check_native_package())
    errors.extend(check_native_build_configuration())
    errors.extend(check_layout_counters())
    errors.extend(check_nested_packages())
    errors.extend(check_nested_c_files())
    errors.extend(check_ffi_native_targets())
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    current = {
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file() and is_source_like(path) and path.name in root_allowed
    }
    public_current = {
        path.name
        for path in PACKAGE_ROOT.iterdir()
        if path.is_file()
        and is_public_root_file(path)
        and path.name in public_root_allowed
    }
    print(
        "Project layout ok; "
        f"{len(current)} allowlisted root source files remain; "
        f"{len(public_current)} grandfathered public package root files remain"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
