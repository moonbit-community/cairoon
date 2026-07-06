#!/usr/bin/env python3
"""Check cairoon's package layout migration rules."""

from __future__ import annotations

import pathlib
import re
import sys


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "src"
TEST_PACKAGE_ROOT = PACKAGE_ROOT / "tests"
ALLOWLIST = REPO_ROOT / "scripts" / "root-layout-allowlist.txt"
LAYOUT_DOC = REPO_ROOT / "PROJECT_LAYOUT.md"
MOON_MOD = REPO_ROOT / "moon.mod"
SOURCE_SUFFIXES = (".mbt.md", ".mbti", ".mbt", ".c", ".h")
NATIVE_PACKAGE_DIR = PACKAGE_ROOT / "native"
NATIVE_PACKAGE_CONFIG = NATIVE_PACKAGE_DIR / "moon.pkg"


def is_source_like(path: pathlib.Path) -> bool:
    name = path.name
    return any(name.endswith(suffix) for suffix in SOURCE_SUFFIXES)


def read_allowlist() -> set[str]:
    allowed: set[str] = set()
    for line_no, line in enumerate(ALLOWLIST.read_text(encoding="utf-8").splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "/" in stripped or "\\" in stripped:
            raise ValueError(
                f"{ALLOWLIST}:{line_no}: root allowlist entries must be filenames"
            )
        allowed.add(stripped)
    return allowed


def check_root_freeze(allowed: set[str]) -> list[str]:
    errors: list[str] = []
    root_source = sorted(
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file() and is_source_like(path)
    )
    unexpected = [name for name in root_source if name not in allowed]
    if unexpected:
        errors.append(
            "new root source-like files are forbidden; move them into a package "
            "or update PROJECT_LAYOUT.md intentionally: " + ", ".join(unexpected)
        )
    return errors


def check_source_root() -> list[str]:
    errors: list[str] = []
    if not (PACKAGE_ROOT / "moon.pkg").exists():
        errors.append("src/moon.pkg: missing public package config")
    if (REPO_ROOT / "moon.pkg").exists():
        errors.append("moon.pkg: root package config is forbidden; use src/moon.pkg")
    if not (PACKAGE_ROOT / "pkg.generated.mbti").exists():
        errors.append("src/pkg.generated.mbti: missing generated public interface")
    moon_mod = MOON_MOD.read_text(encoding="utf-8") if MOON_MOD.exists() else ""
    if 'source = "src"' not in moon_mod:
        errors.append('moon.mod: missing source = "src"')
    if 'readme = "src/README.mbt.md"' not in moon_mod:
        errors.append('moon.mod: readme must point at src/README.mbt.md')
    return errors


def check_native_package() -> list[str]:
    errors: list[str] = []
    public_config = PACKAGE_ROOT / "moon.pkg"
    public_text = (
        public_config.read_text(encoding="utf-8") if public_config.exists() else ""
    )
    if '"native-stub"' in public_text:
        errors.append(
            "src/moon.pkg: public package must not own native-stub entries; "
            "put public C glue in src/native/moon.pkg"
        )
    if '"caimeo/cairoon/native"' not in public_text:
        errors.append(
            "src/moon.pkg: public package must import caimeo/cairoon/native "
            "so public FFI declarations link against the native stub package"
        )
    if not NATIVE_PACKAGE_CONFIG.exists():
        errors.append("src/native/moon.pkg: missing native-stub package config")
    return errors


def check_nested_packages() -> list[str]:
    errors: list[str] = []
    root_tests = REPO_ROOT / "tests"
    if root_tests.exists():
        forbidden = [
            path.relative_to(REPO_ROOT)
            for path in root_tests.rglob("*")
            if path.is_file() and (path.name == "moon.pkg" or is_source_like(path))
        ]
        if forbidden:
            errors.append(
                "root tests are outside moon.mod source = \"src\"; move them under "
                "src/tests: " + ", ".join(str(path) for path in sorted(forbidden))
            )

    for path in sorted(PACKAGE_ROOT.rglob("moon.pkg")):
        if path.parent == PACKAGE_ROOT:
            continue
        text = path.read_text(encoding="utf-8")
        generated_interface = path.parent / "pkg.generated.mbti"
        if not generated_interface.exists():
            errors.append(
                f"{path.parent.relative_to(REPO_ROOT)}: missing "
                "pkg.generated.mbti; run moon info --target native"
            )
        if '"caimeo/cairoon"' in text and '"cc-link-flags"' not in text:
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: external cairoon packages "
                "must carry Cairo cc-link-flags"
            )
    return errors


def read_native_stubs(package_config: pathlib.Path) -> set[str]:
    text = package_config.read_text(encoding="utf-8")
    marker = '"native-stub"'
    start = text.find(marker)
    if start == -1:
        return set()
    open_bracket = text.find("[", start)
    close_bracket = text.find("]", open_bracket)
    if open_bracket == -1 or close_bracket == -1:
        return set()
    block = text[open_bracket:close_bracket]
    return set(re.findall(r'"([^"]+\.c)"', block))


def check_nested_c_files() -> list[str]:
    errors: list[str] = []
    native_stubs_by_package: dict[pathlib.Path, set[str]] = {}

    for path in sorted(REPO_ROOT.rglob("*")):
        if not path.is_file() or path.parent == REPO_ROOT:
            continue
        if path.suffix not in {".c", ".h"}:
            continue
        if ".git" in path.parts or "_build" in path.parts:
            continue
        owner_config = path.parent / "moon.pkg"
        if not owner_config.exists():
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: C source/header files must "
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
                f"{path.relative_to(REPO_ROOT)}: C files must be listed in "
                f"{owner_config.relative_to(REPO_ROOT)} native-stub"
            )

    for owner_config, native_stubs in sorted(native_stubs_by_package.items()):
        for entry in sorted(native_stubs):
            if "/" in entry or "\\" in entry:
                errors.append(
                    f"{owner_config.relative_to(REPO_ROOT)}: native-stub entry "
                    f"{entry!r} must be a file beside its owning moon.pkg"
                )
                continue
            if not (owner_config.parent / entry).exists():
                errors.append(
                    f"{owner_config.relative_to(REPO_ROOT)}: native-stub entry "
                    f"{entry!r} is missing"
                )
    if NATIVE_PACKAGE_CONFIG.exists():
        public_stubs = read_native_stubs(NATIVE_PACKAGE_CONFIG)
        if not public_stubs:
            errors.append("src/native/moon.pkg: missing native-stub entries")
        for path in sorted(NATIVE_PACKAGE_DIR.glob("*.c")):
            if path.name not in public_stubs:
                errors.append(
                    f"{path.relative_to(REPO_ROOT)}: public C glue must be "
                    "owned by src/native/moon.pkg native-stub"
                )
    return errors


def main() -> int:
    errors: list[str] = []
    if not LAYOUT_DOC.exists():
        errors.append(f"{LAYOUT_DOC}: missing package layout plan")
    if not ALLOWLIST.exists():
        errors.append(f"{ALLOWLIST}: missing root source allowlist")
    if not MOON_MOD.exists():
        errors.append(f"{MOON_MOD}: missing module config")
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    try:
        allowed = read_allowlist()
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    errors.extend(check_root_freeze(allowed))
    errors.extend(check_source_root())
    errors.extend(check_native_package())
    errors.extend(check_nested_packages())
    errors.extend(check_nested_c_files())
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    current = {
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file() and is_source_like(path) and path.name in allowed
    }
    print(
        "Project layout ok; "
        f"{len(current)} allowlisted root source files remain"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
