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
PUBLIC_NATIVE_DIR = PACKAGE_ROOT / "native"


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


def check_test_packages() -> list[str]:
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

    if TEST_PACKAGE_ROOT.exists():
        for path in sorted(TEST_PACKAGE_ROOT.rglob("moon.pkg")):
            text = path.read_text(encoding="utf-8")
            generated_interface = path.parent / "pkg.generated.mbti"
            if not generated_interface.exists():
                errors.append(
                    f"{path.parent.relative_to(REPO_ROOT)}: missing "
                    "pkg.generated.mbti; run moon info --target native"
                )
            if '"caimeo/cairoon"' in text and '"cc-link-flags"' not in text:
                errors.append(
                    f"{path.relative_to(REPO_ROOT)}: external cairoon test "
                    "packages must carry Cairo cc-link-flags"
                )
    return errors


def read_public_native_stubs() -> set[str]:
    text = (PACKAGE_ROOT / "moon.pkg").read_text(encoding="utf-8")
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


def is_under(path: pathlib.Path, parent: pathlib.Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def check_nested_c_files() -> list[str]:
    errors: list[str] = []
    public_native_stubs = read_public_native_stubs()
    for entry in sorted(public_native_stubs):
        if not entry.startswith("native/"):
            errors.append(
                f"src/moon.pkg: native-stub entry {entry!r} must live under "
                "src/native/"
            )
        elif not (PACKAGE_ROOT / entry).exists():
            errors.append(f"src/moon.pkg: native-stub entry {entry!r} is missing")

    for path in sorted(REPO_ROOT.rglob("*")):
        if not path.is_file() or path.parent == REPO_ROOT:
            continue
        if path.suffix not in {".c", ".h"}:
            continue
        if ".git" in path.parts or "_build" in path.parts:
            continue
        if is_under(path, PUBLIC_NATIVE_DIR):
            if path.suffix == ".c":
                entry = path.relative_to(PACKAGE_ROOT).as_posix()
                if entry not in public_native_stubs:
                    errors.append(
                        f"{path.relative_to(REPO_ROOT)}: public native C files "
                        "must be listed in src/moon.pkg native-stub"
                    )
            continue
        if not (path.parent / "moon.pkg").exists():
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: nested C files must live beside "
                "the moon.pkg that owns their native-stub entry, or under "
                "src/native when owned by src/moon.pkg"
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
    errors.extend(check_test_packages())
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
