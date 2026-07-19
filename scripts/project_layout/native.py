"""Native package ownership, build, and FFI target layout audits."""

from __future__ import annotations

import pathlib
import re

from .common import (
    is_source_like,
    read_native_stubs,
    read_native_targets,
)


def check_native_package(
    package_root: pathlib.Path,
    native_package_config: pathlib.Path,
) -> list[str]:
    errors: list[str] = []
    public_config = package_root / "moon.pkg"
    public_text = (
        public_config.read_text(encoding="utf-8") if public_config.exists() else ""
    )
    if '"native-stub"' in public_text:
        errors.append(
            "src/moon.pkg: public package must not own native-stub entries; "
            "put public C glue in src/native/moon.pkg"
        )
    if '"CAIMEOX/cairoon/native"' not in public_text:
        errors.append(
            "src/moon.pkg: public package must import CAIMEOX/cairoon/native "
            "so public FFI declarations link against the native stub package"
        )
    if not native_package_config.exists():
        errors.append("src/native/moon.pkg: missing native-stub package config")
    return errors


def check_native_build_configuration(
    repo_root: pathlib.Path,
    package_root: pathlib.Path,
    moon_mod: pathlib.Path,
    cairo_build_script: pathlib.Path,
    consumer_package_config: pathlib.Path,
    strict_stub_cflags: str,
) -> list[str]:
    errors: list[str] = []
    if not cairo_build_script.is_file():
        errors.append(
            f"{cairo_build_script.relative_to(repo_root)}: missing Cairo "
            "pre-build configuration script"
        )

    moon_mod_text = moon_mod.read_text(encoding="utf-8") if moon_mod.exists() else ""
    prebuild = re.search(
        r'"--moonbit-unstable-prebuild"\s*:\s*'
        r'"scripts/build/cairo_config\.py"',
        moon_mod_text,
    )
    if prebuild is None:
        errors.append(
            "moon.mod: --moonbit-unstable-prebuild must point to "
            "scripts/build/cairo_config.py"
        )

    configs = sorted(package_root.rglob("moon.pkg"))
    if consumer_package_config.exists():
        configs.append(consumer_package_config)
    for path in configs:
        text = path.read_text(encoding="utf-8")
        try:
            relative = path.relative_to(repo_root)
        except ValueError:
            relative = path
        if '"cc-link-flags"' in text:
            errors.append(
                f"{relative}: cc-link-flags must come only from the module "
                "Cairo build script"
            )
        if '"native-stub"' in text:
            if strict_stub_cflags not in text:
                errors.append(
                    f"{relative}: native-stub packages must use exact strict "
                    f"C flags {strict_stub_cflags}"
                )
        elif '"stub-cc-flags"' in text:
            errors.append(
                f"{relative}: stub-cc-flags are forbidden without native-stub"
            )
    return errors


def check_nested_packages(
    repo_root: pathlib.Path,
    package_root: pathlib.Path,
) -> list[str]:
    errors: list[str] = []
    root_tests = repo_root / "tests"
    if root_tests.exists():
        forbidden = [
            path.relative_to(repo_root)
            for path in root_tests.rglob("*")
            if path.is_file() and (path.name == "moon.pkg" or is_source_like(path))
        ]
        if forbidden:
            errors.append(
                'root tests are outside moon.mod source = "src"; move them under '
                "src/tests: " + ", ".join(str(path) for path in sorted(forbidden))
            )

    for path in sorted(package_root.rglob("moon.pkg")):
        if path.parent == package_root:
            continue
        generated_interface = path.parent / "pkg.generated.mbti"
        if not generated_interface.exists():
            errors.append(
                f"{path.parent.relative_to(repo_root)}: missing "
                "pkg.generated.mbti; run moon info --target native"
            )
    return errors


def iter_production_ffi_files(
    package_root: pathlib.Path,
    test_package_root: pathlib.Path,
) -> list[pathlib.Path]:
    return [
        path
        for path in sorted(package_root.rglob("ffi*.mbt"))
        if test_package_root not in path.parents
    ]


def check_ffi_native_targets(
    repo_root: pathlib.Path,
    package_root: pathlib.Path,
    test_package_root: pathlib.Path,
    native_targets: set[str],
) -> list[str]:
    errors: list[str] = []
    targets_by_package: dict[pathlib.Path, dict[str, set[str]]] = {}
    seen_by_package: dict[pathlib.Path, set[str]] = {}

    for path in iter_production_ffi_files(package_root, test_package_root):
        package_config = path.parent / "moon.pkg"
        if not package_config.exists():
            errors.append(
                f"{path.relative_to(repo_root)}: raw FFI files must live beside "
                "a moon.pkg that gates them to the native target"
            )
            continue
        if package_config not in targets_by_package:
            targets_by_package[package_config] = read_native_targets(package_config)
        targets = targets_by_package[package_config].get(path.name)
        seen_by_package.setdefault(package_config, set()).add(path.name)
        if targets != native_targets:
            rel_config = package_config.relative_to(repo_root)
            errors.append(
                f"{path.relative_to(repo_root)}: production raw FFI files must "
                f"be listed in {rel_config} targets as [ \"native\" ]"
            )

    for package_config, entries in sorted(targets_by_package.items()):
        for name, targets in sorted(entries.items()):
            if not name.startswith("ffi") or not name.endswith(".mbt"):
                continue
            if targets != native_targets:
                continue
            if name in seen_by_package.get(package_config, set()):
                continue
            errors.append(
                f"{package_config.relative_to(repo_root)}: native target entry "
                f"{name!r} is missing beside its owning moon.pkg"
            )
    return errors


def check_nested_c_files(
    repo_root: pathlib.Path,
    native_package_dir: pathlib.Path,
    native_package_config: pathlib.Path,
    sanitizer_probe_root: pathlib.Path,
) -> list[str]:
    errors: list[str] = []
    native_stubs_by_package: dict[pathlib.Path, set[str]] = {}

    for path in sorted(repo_root.rglob("*")):
        if not path.is_file() or path.parent == repo_root:
            continue
        if path.suffix not in {".c", ".h"}:
            continue
        if any(part in {".git", ".mooncakes", "_build"} for part in path.parts):
            continue
        if path.parent == sanitizer_probe_root and path.name.endswith("_probe.c"):
            continue
        owner_config = path.parent / "moon.pkg"
        if not owner_config.exists():
            errors.append(
                f"{path.relative_to(repo_root)}: C source/header files must "
                "live beside the moon.pkg that owns their native-stub entry"
            )
            continue
        if path.suffix == ".h":
            continue
        if owner_config not in native_stubs_by_package:
            native_stubs_by_package[owner_config] = read_native_stubs(owner_config)
        entry = path.name
        if entry not in native_stubs_by_package[owner_config]:
            errors.append(
                f"{path.relative_to(repo_root)}: C files must be listed in "
                f"{owner_config.relative_to(repo_root)} native-stub"
            )

    for owner_config, native_stubs in sorted(native_stubs_by_package.items()):
        for entry in sorted(native_stubs):
            if "/" in entry or "\\" in entry:
                errors.append(
                    f"{owner_config.relative_to(repo_root)}: native-stub entry "
                    f"{entry!r} must be a file beside its owning moon.pkg"
                )
                continue
            if not (owner_config.parent / entry).exists():
                errors.append(
                    f"{owner_config.relative_to(repo_root)}: native-stub entry "
                    f"{entry!r} is missing"
                )
    if native_package_config.exists():
        public_stubs = read_native_stubs(native_package_config)
        if not public_stubs:
            errors.append("src/native/moon.pkg: missing native-stub entries")
        for path in sorted(native_package_dir.glob("*.c")):
            if path.name not in public_stubs:
                errors.append(
                    f"{path.relative_to(repo_root)}: public C glue must be "
                    "owned by src/native/moon.pkg native-stub"
                )
    return errors
