#!/usr/bin/env python3
"""Check cairoon's package layout migration rules."""

from __future__ import annotations

import pathlib
import re
import sys


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
CONSUMER_PACKAGE = CONSUMER_ROOT / "src" / "smoke"
CONSUMER_PACKAGE_CONFIG = CONSUMER_PACKAGE / "moon.pkg"
CONSUMER_TEST = CONSUMER_PACKAGE / "consumer_smoke_test.mbt"
SOURCE_SUFFIXES = (".mbt.md", ".mbti", ".mbt", ".c", ".h")
PACKAGE_CONFIG_NAMES = {"moon.pkg"}
NATIVE_PACKAGE_DIR = PACKAGE_ROOT / "native"
NATIVE_PACKAGE_CONFIG = NATIVE_PACKAGE_DIR / "moon.pkg"
CAIRO_BUILD_SCRIPT = REPO_ROOT / "scripts" / "build" / "cairo_config.py"
SANITIZER_PROBE_ROOT = REPO_ROOT / "scripts" / "sanitizers" / "probes"
NATIVE_TARGETS = {"native"}
CAIRO_CFLAGS_VARIABLE = '"stub-cc-flags": "${build.CAIRO_CFLAGS}"'
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
EXECUTABLE_MBT_CHECK_BLOCK = re.compile(
    r"^```mbt[ \t]+check[ \t]*\r?\n(?P<body>.*?)^```[ \t]*$",
    re.MULTILINE | re.DOTALL,
)
REFERENCE_DOC_INDEX_ENTRY = re.compile(r"`(?P<path>src/docs/[^`\s]+\.mbt\.md)`")


def is_source_like(path: pathlib.Path) -> bool:
    name = path.name
    return any(name.endswith(suffix) for suffix in SOURCE_SUFFIXES)


def is_public_root_file(path: pathlib.Path) -> bool:
    return is_source_like(path) or path.name in PACKAGE_CONFIG_NAMES


def read_filename_allowlist(path: pathlib.Path, label: str) -> set[str]:
    allowed: set[str] = set()
    for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "/" in stripped or "\\" in stripped:
            raise ValueError(
                f"{path}:{line_no}: {label} allowlist entries must be filenames"
            )
        allowed.add(stripped)
    return allowed


def check_root_freeze(allowed: set[str]) -> list[str]:
    errors: list[str] = []
    root_source = {
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file() and is_source_like(path)
    }
    unexpected = sorted(root_source - allowed)
    if unexpected:
        errors.append(
            "new root source-like files are forbidden; move them into a package "
            "or update PROJECT_LAYOUT.md intentionally: " + ", ".join(unexpected)
        )
    stale = sorted(allowed - root_source)
    if stale:
        errors.append(
            "root source allowlist entries must be removed when files move; "
            "stale entries: " + ", ".join(stale)
        )
    return errors


def check_public_package_root_freeze(allowed: set[str]) -> list[str]:
    errors: list[str] = []
    direct_source = {
        path.name
        for path in PACKAGE_ROOT.iterdir()
        if path.is_file() and is_public_root_file(path)
    }
    unexpected = sorted(direct_source - allowed)
    if unexpected:
        errors.append(
            "new source-like files directly under src/ are forbidden; place "
            "implementation, tests, docs, or generated interfaces in a "
            "subpackage, or update PROJECT_LAYOUT.md intentionally: "
            + ", ".join(unexpected)
        )
    stale = sorted(allowed - direct_source)
    if stale:
        errors.append(
            "public package root allowlist entries must be removed in the same "
            "commit that moves files out of src/; stale entries: "
            + ", ".join(stale)
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
    target_markers = (
        ("preferred_target", 'preferred_target = "native"'),
        ("supported_targets", 'supported_targets = "native"'),
    )
    for field, marker in target_markers:
        if (
            re.search(
                rf"^{field}\s*=\s*\"native\"\s*$", moon_mod, re.MULTILINE
            )
            is None
        ):
            errors.append(f"moon.mod: missing {marker}")
    if 'source = "src"' not in moon_mod:
        errors.append('moon.mod: missing source = "src"')
    if 'readme = "src/README.mbt.md"' not in moon_mod:
        errors.append('moon.mod: readme must point at src/README.mbt.md')
    exclude_match = re.search(
        r"exclude\s*:\s*\[(?P<entries>[^\]]*)\]", moon_mod, re.DOTALL
    )
    if exclude_match is None or '"integration"' not in exclude_match.group(
        "entries"
    ):
        errors.append(
            'moon.mod: publishing must exclude the integration consumer fixture'
        )
    return errors


def markdown_level_two_section(text: str, title: str) -> str | None:
    heading = re.search(
        rf"^##[ \t]+{re.escape(title)}[ \t]*$", text, re.MULTILINE
    )
    if heading is None:
        return None
    remainder = text[heading.end() :]
    next_heading = re.search(r"^##(?:[ \t]+|$)", remainder, re.MULTILINE)
    if next_heading is None:
        return remainder
    return remainder[: next_heading.start()]


def check_reference_docs() -> list[str]:
    errors: list[str] = []
    if not DOC_PACKAGE_DIR.is_dir():
        return [f"{DOC_PACKAGE_DIR}: missing executable reference package"]

    for support_name in ("moon.pkg", "prelude.mbt"):
        support_path = DOC_PACKAGE_DIR / support_name
        if not support_path.is_file():
            errors.append(f"{support_path}: missing documentation package support file")

    docs = {
        path.name: path
        for path in DOC_PACKAGE_DIR.glob("*.mbt.md")
        if path.is_file()
    }
    for name in sorted(REQUIRED_REFERENCE_DOCS - docs.keys()):
        errors.append(f"{DOC_PACKAGE_DIR / name}: missing required reference document")

    readmes = ((ROOT_README, "repository"), (PUBLIC_README, "public package"))
    readme_indexes: dict[pathlib.Path, set[str]] = {}
    for path, label in readmes:
        if path.is_file():
            text = path.read_text(encoding="utf-8")
            section = markdown_level_two_section(text, "Documentation")
            if section is None:
                errors.append(
                    f"{path}: {label} README is missing a Documentation section"
                )
            else:
                readme_indexes[path] = {
                    match.group("path")
                    for match in REFERENCE_DOC_INDEX_ENTRY.finditer(section)
                }
        else:
            errors.append(f"{path}: missing {label} README documentation index")

    for name, path in sorted(docs.items()):
        text = path.read_text(encoding="utf-8")
        if re.search(r"^#\s+\S", text, re.MULTILINE) is None:
            errors.append(f"{path}: reference document must have a level-one title")
        executable_blocks = EXECUTABLE_MBT_CHECK_BLOCK.finditer(text)
        if not any(match.group("body").strip() for match in executable_blocks):
            errors.append(f"{path}: reference document must contain executable mbt check")
        relative_path = f"src/docs/{name}"
        marker = f"`{relative_path}`"
        for readme_path, label in readmes:
            if (
                readme_path in readme_indexes
                and relative_path not in readme_indexes[readme_path]
            ):
                errors.append(
                    f"{readme_path}: {label} documentation index is missing {marker}"
                )

    return errors


def check_integration_fixture() -> list[str]:
    errors: list[str] = []
    required_files = (
        INTEGRATION_WORKSPACE,
        CONSUMER_MODULE,
        CONSUMER_PACKAGE_CONFIG,
        CONSUMER_TEST,
    )
    for path in required_files:
        if not path.exists():
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: missing downstream consumer fixture file"
            )
    if errors:
        return errors

    workspace = INTEGRATION_WORKSPACE.read_text(encoding="utf-8")
    workspace_members = set(re.findall(r'"([^"]+)"', workspace))
    if workspace_members != {"..", "./consumer"}:
        errors.append(
            "integration/moon.work: members must be exactly the relative "
            "cairoon root and isolated consumer module"
        )

    root_module = MOON_MOD.read_text(encoding="utf-8")
    version_match = re.search(r'^version\s*=\s*"([^"]+)"', root_module, re.MULTILINE)
    if version_match is None:
        errors.append("moon.mod: missing module version for consumer dependency check")
        expected_dependency = None
    else:
        expected_dependency = (
            f'"CAIMEOX/cairoon@{version_match.group(1)}"'
        )

    consumer_module = CONSUMER_MODULE.read_text(encoding="utf-8")
    module_markers = (
        'name = "cairoon-integration/consumer"',
        'preferred_target = "native"',
        'supported_targets = "native"',
        'source = "src"',
    )
    for marker in module_markers:
        if marker not in consumer_module:
            errors.append(
                f"integration/consumer/moon.mod: missing required marker {marker!r}"
            )
    if expected_dependency is not None and expected_dependency not in consumer_module:
        errors.append(
            "integration/consumer/moon.mod: cairoon dependency version must "
            f"match the root module ({expected_dependency})"
        )

    consumer_package = CONSUMER_PACKAGE_CONFIG.read_text(encoding="utf-8")
    if '"CAIMEOX/cairoon"' not in consumer_package:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: must import the public "
            "CAIMEOX/cairoon package"
        )
    cairoon_imports = set(
        re.findall(r'"(CAIMEOX/cairoon[^"]*)"', consumer_package)
    )
    if cairoon_imports != {"CAIMEOX/cairoon"}:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: must use only the public "
            "CAIMEOX/cairoon package, not implementation subpackages"
        )
    if 'for "test"' not in consumer_package:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: the fixture import must "
            "remain test-scoped"
        )
    if '"cc-link-flags"' in consumer_package:
        errors.append(
            "integration/consumer/src/smoke/moon.pkg: consumer must rely on "
            "cairoon's propagated native link configuration, not repeat "
            "cc-link-flags"
        )
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
    if '"CAIMEOX/cairoon/native"' not in public_text:
        errors.append(
            "src/moon.pkg: public package must import CAIMEOX/cairoon/native "
            "so public FFI declarations link against the native stub package"
        )
    if not NATIVE_PACKAGE_CONFIG.exists():
        errors.append("src/native/moon.pkg: missing native-stub package config")
    return errors


def check_native_build_configuration() -> list[str]:
    errors: list[str] = []
    if not CAIRO_BUILD_SCRIPT.is_file():
        errors.append(
            f"{CAIRO_BUILD_SCRIPT.relative_to(REPO_ROOT)}: missing Cairo "
            "pre-build configuration script"
        )

    moon_mod = MOON_MOD.read_text(encoding="utf-8") if MOON_MOD.exists() else ""
    prebuild = re.search(
        r'"--moonbit-unstable-prebuild"\s*:\s*'
        r'"scripts/build/cairo_config\.py"',
        moon_mod,
    )
    if prebuild is None:
        errors.append(
            "moon.mod: --moonbit-unstable-prebuild must point to "
            "scripts/build/cairo_config.py"
        )

    configs = sorted(PACKAGE_ROOT.rglob("moon.pkg"))
    if CONSUMER_PACKAGE_CONFIG.exists():
        configs.append(CONSUMER_PACKAGE_CONFIG)
    for path in configs:
        text = path.read_text(encoding="utf-8")
        try:
            relative = path.relative_to(REPO_ROOT)
        except ValueError:
            relative = path
        if '"cc-link-flags"' in text:
            errors.append(
                f"{relative}: cc-link-flags must come only from the module "
                "Cairo build script"
            )
        if '"native-stub"' in text:
            if CAIRO_CFLAGS_VARIABLE not in text:
                errors.append(
                    f"{relative}: native-stub packages must use "
                    '"stub-cc-flags": "${build.CAIRO_CFLAGS}"'
                )
        elif '"stub-cc-flags"' in text:
            errors.append(
                f"{relative}: stub-cc-flags are forbidden without native-stub"
            )
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


def read_native_targets(package_config: pathlib.Path) -> dict[str, set[str]]:
    text = package_config.read_text(encoding="utf-8")
    return {
        name: set(re.findall(r'"([^"]+)"', targets))
        for name, targets in re.findall(
            r'"([^"]+\.mbt)"\s*:\s*\[([^\]]*)\]',
            text,
        )
    }


def iter_production_ffi_files() -> list[pathlib.Path]:
    return [
        path
        for path in sorted(PACKAGE_ROOT.rglob("ffi*.mbt"))
        if TEST_PACKAGE_ROOT not in path.parents
    ]


def check_ffi_native_targets() -> list[str]:
    errors: list[str] = []
    targets_by_package: dict[pathlib.Path, dict[str, set[str]]] = {}
    seen_by_package: dict[pathlib.Path, set[str]] = {}

    for path in iter_production_ffi_files():
        package_config = path.parent / "moon.pkg"
        if not package_config.exists():
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: raw FFI files must live beside "
                "a moon.pkg that gates them to the native target"
            )
            continue
        if package_config not in targets_by_package:
            targets_by_package[package_config] = read_native_targets(package_config)
        targets = targets_by_package[package_config].get(path.name)
        seen_by_package.setdefault(package_config, set()).add(path.name)
        if targets != NATIVE_TARGETS:
            rel_config = package_config.relative_to(REPO_ROOT)
            errors.append(
                f"{path.relative_to(REPO_ROOT)}: production raw FFI files must "
                f"be listed in {rel_config} targets as [ \"native\" ]"
            )

    for package_config, entries in sorted(targets_by_package.items()):
        for name, targets in sorted(entries.items()):
            if not name.startswith("ffi") or not name.endswith(".mbt"):
                continue
            if targets != NATIVE_TARGETS:
                continue
            if name in seen_by_package.get(package_config, set()):
                continue
            errors.append(
                f"{package_config.relative_to(REPO_ROOT)}: native target entry "
                f"{name!r} is missing beside its owning moon.pkg"
            )
    return errors


def count_files(path: pathlib.Path, pattern: str) -> int:
    return sum(1 for child in path.glob(pattern) if child.is_file())


def count_recursive_files(path: pathlib.Path, pattern: str) -> int:
    return sum(1 for child in path.rglob(pattern) if child.is_file())


def checked_package_count_paths() -> list[str]:
    """Return support/implementation package paths that need layout counters."""
    package_dirs: list[pathlib.Path] = []
    for root in COUNTED_PACKAGE_ROOTS:
        if not root.exists():
            continue
        package_dirs.extend(
            path.parent
            for path in root.rglob("moon.pkg")
            if path.parent != PACKAGE_ROOT
        )
    return [
        str(path.relative_to(REPO_ROOT))
        for path in sorted(package_dirs, key=lambda item: item.relative_to(REPO_ROOT))
    ]


def require_layout_count(
    text: str,
    label: str,
    pattern: str,
    expected: dict[str, int],
) -> list[str]:
    match = re.search(pattern, text, re.DOTALL)
    if match is None:
        return [f"{LAYOUT_DOC}: missing Current Layout counter for {label}"]

    errors: list[str] = []
    for name, value in expected.items():
        actual = int(match.group(name))
        if actual != value:
            errors.append(
                f"{LAYOUT_DOC}: stale Current Layout counter for {label}: "
                f"{name} says {actual}, actual is {value}"
            )
    return errors


def check_layout_counters() -> list[str]:
    text = LAYOUT_DOC.read_text(encoding="utf-8")
    errors: list[str] = []

    errors.extend(
        require_layout_count(
            text,
            "direct src implementation files",
            r"- (?P<count>\d+) `\.mbt` implementation files directly in `src/`\.",
            {"count": count_files(PACKAGE_ROOT, "*.mbt")},
        )
    )
    errors.extend(
        require_layout_count(
            text,
            "executable reference package",
            r"- (?P<prelude>\d+) `\.mbt` prelude file and "
            r"(?P<docs>\d+) executable `\.mbt\.md` docs in `src/docs/`\.",
            {
                "prelude": count_files(DOC_PACKAGE_DIR, "*.mbt"),
                "docs": count_files(DOC_PACKAGE_DIR, "*.mbt.md"),
            },
        )
    )

    for rel_path in checked_package_count_paths():
        package_dir = REPO_ROOT / rel_path
        escaped = re.escape(rel_path + "/")
        implementation_count = count_files(package_dir, "*.mbt") - count_files(
            package_dir,
            "*_test.mbt",
        )
        errors.extend(
            require_layout_count(
                text,
                rel_path,
                rf"- (?P<impl>\d+) `\.mbt` implementation files? and "
                rf"(?P<test>\d+) package-local `\*_test\.mbt` files? in\s+"
                rf"`{escaped}`\.",
                {
                    "impl": implementation_count,
                    "test": count_files(package_dir, "*_test.mbt"),
                },
            )
        )

    counter_specs = [
        (
            "native package MoonBit anchor",
            r"- (?P<count>\d+) native-package MoonBit anchor file in `src/native/`\.",
            {"count": count_files(NATIVE_PACKAGE_DIR, "*.mbt")},
        ),
        (
            "src tests",
            r"- (?P<count>\d+) `\*_test\.mbt` files under `src/tests/`",
            {"count": count_recursive_files(TEST_PACKAGE_ROOT, "*_test.mbt")},
        ),
        (
            "white-box tests",
            r"- (?P<count>\d+) white-box `\*_wbtest\.mbt` files in `src/`\.",
            {"count": count_files(PACKAGE_ROOT, "*_wbtest.mbt")},
        ),
        (
            "public C implementation files",
            r"- (?P<count>\d+) public C implementation files owned by "
            r"`src/native/moon\.pkg`\.",
            {"count": count_files(NATIVE_PACKAGE_DIR, "*.c")},
        ),
        (
            "public C headers",
            r"- (?P<count>\d+) public C header in `src/native/`\.",
            {"count": count_files(NATIVE_PACKAGE_DIR, "*.h")},
        ),
        (
            "oracle C implementation files",
            r"- (?P<count>\d+) oracle C implementation files in "
            r"`src/tests/oracle/native/`\.",
            {"count": count_files(TEST_PACKAGE_ROOT / "oracle/native", "*.c")},
        ),
        (
            "oracle C headers",
            r"- (?P<count>\d+) oracle C headers in `src/tests/oracle/native/`\.",
            {"count": count_files(TEST_PACKAGE_ROOT / "oracle/native", "*.h")},
        ),
        (
            "executable docs",
            r"- (?P<count>\d+) executable `\.mbt\.md` docs? in `src/`\.",
            {"count": count_files(PACKAGE_ROOT, "*.mbt.md")},
        ),
    ]
    for label, pattern, expected in counter_specs:
        errors.extend(require_layout_count(text, label, pattern, expected))

    return errors


def check_nested_c_files() -> list[str]:
    errors: list[str] = []
    native_stubs_by_package: dict[pathlib.Path, set[str]] = {}

    for path in sorted(REPO_ROOT.rglob("*")):
        if not path.is_file() or path.parent == REPO_ROOT:
            continue
        if path.suffix not in {".c", ".h"}:
            continue
        if any(part in {".git", ".mooncakes", "_build"} for part in path.parts):
            continue
        if path.parent == SANITIZER_PROBE_ROOT and path.name.endswith("_probe.c"):
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
            PUBLIC_ROOT_ALLOWLIST, "public package root"
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
