#!/usr/bin/env python3
"""Run the native suite with real ASan, LSan, and UBSan instrumentation."""

from __future__ import annotations

import argparse
import os
import platform
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

from policy import (
    LEAK_MODES,
    asan_options,
    leak_detection_enabled,
    policy_description,
    ubsan_options,
)


COMPILE_FLAGS = (
    "-g",
    "-fsanitize=address,undefined",
    "-fno-omit-frame-pointer",
)
LSAN_EXIT_CODE = 86
REPO_ROOT = Path(__file__).resolve().parents[2]
RECORDING_SNAPSHOT_PROBE = (
    REPO_ROOT
    / "scripts"
    / "sanitizers"
    / "probes"
    / "cairo_recording_snapshot_probe.c"
)
RECORDING_SNAPSHOT_SUPPRESSION = (
    REPO_ROOT / "scripts" / "sanitizers" / "lsan-cairo-recording-snapshot.supp"
)
RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION = (
    REPO_ROOT
    / "scripts"
    / "sanitizers"
    / "lsan-cairo-recording-snapshot-stripped.supp"
)
RECORDING_SNAPSHOT_PACKAGES = frozenset(
    {"src/tests/oracle/vector_backend"}
)
RECORDING_SNAPSHOT_ALLOCATION_SIZES = frozenset({464, 584})
RECORDING_SNAPSHOT_VECTOR_ALLOCATIONS = 16
PDF_JBIG2_MISSING_PROBE = (
    REPO_ROOT
    / "scripts"
    / "sanitizers"
    / "probes"
    / "cairo_pdf_jbig2_missing_probe.c"
)
PDF_JBIG2_MISSING_SUPPRESSION = (
    REPO_ROOT / "scripts" / "sanitizers" / "lsan-cairo-pdf-jbig2-missing.supp"
)
PDF_JBIG2_MISSING_PACKAGES = frozenset({"src/tests/backend/pdf"})
PDF_JBIG2_MISSING_STATUS_SENTINEL = (
    "CAIROON_PDF_JBIG2_STATUS=JBIG2_GLOBAL_MISSING"
)
PDF_JBIG2_MISSING_PROFILES = frozenset(
    {
        (9, 988, 6, 948, 3, 40),
        (14, 2352, 10, 2284, 4, 68),
    }
)
CLEANUP_SOURCE = r"""
#include <stdlib.h>

extern void cairo_debug_reset_static_data(void) __attribute__((weak));
extern void FcFini(void) __attribute__((weak));

static void cairoon_sanitizer_cleanup(void) {
  if (cairo_debug_reset_static_data != NULL) {
    cairo_debug_reset_static_data();
  }
  if (FcFini != NULL) {
    FcFini();
  }
}

__attribute__((constructor))
static void cairoon_register_sanitizer_cleanup(void) {
  if (atexit(cairoon_sanitizer_cleanup) != 0) {
    abort();
  }
}
""".lstrip()


@dataclass(frozen=True)
class RecordingSnapshotLeak:
    allocation_size: int
    suppression_template: str
    suppression_path: Path


@dataclass(frozen=True)
class PdfJbig2MissingLeak:
    total_allocations: int
    total_bytes: int
    interchange_allocations: int
    interchange_bytes: int
    paginated_allocations: int
    paginated_bytes: int


def resolve_executable(candidate: str) -> str | None:
    if "/" in candidate:
        path = Path(candidate).expanduser()
        return str(path.resolve()) if path.is_file() and os.access(path, os.X_OK) else None
    found = shutil.which(candidate)
    return str(Path(found).resolve()) if found else None


def first_executable(candidates: list[str]) -> str | None:
    for candidate in candidates:
        if candidate and (resolved := resolve_executable(candidate)):
            return resolved
    return None


def choose_compiler(requested: str | None, system: str) -> str:
    candidates = [requested or "", os.environ.get("CAIROON_ASAN_CC", "")]
    if system == "Darwin":
        candidates.extend(
            [
                "/opt/homebrew/opt/llvm/bin/clang",
                "/usr/local/opt/llvm/bin/clang",
            ]
        )
    candidates.extend(["clang", "cc"])
    compiler = first_executable(candidates)
    if compiler is None:
        raise RuntimeError("no sanitizer-capable C compiler found")
    return compiler


def choose_archiver(requested: str | None, system: str) -> str:
    candidates = [requested or "", os.environ.get("CAIROON_ASAN_AR", "")]
    if system == "Darwin":
        candidates.append("/usr/bin/ar")
    candidates.extend(["llvm-ar", "ar"])
    archiver = first_executable(candidates)
    if archiver is None:
        raise RuntimeError("no native archiver found")
    return archiver


def find_moon() -> str:
    moon = first_executable(["moon"])
    if moon is None:
        raise RuntimeError("moon is not on PATH")
    return moon


def find_moonbit_toolchain(moon: str) -> Path:
    toolchain = Path(moon).resolve().parent.parent
    runtime = toolchain / "lib" / "libmoonbitrun.o"
    if not runtime.is_file():
        raise RuntimeError(f"MoonBit allocator object not found: {runtime}")
    return toolchain


def run_checked(command: list[str], **kwargs: object) -> None:
    rendered = " ".join(shlex.quote(part) for part in command)
    print(f"+ {rendered}", flush=True)
    subprocess.run(command, check=True, **kwargs)


def validate_ubsan_probe(returncode: int, output: str) -> None:
    if returncode == 0 or "runtime error: signed integer overflow" not in output:
        raise RuntimeError(
            "UndefinedBehaviorSanitizer preflight did not detect an intentional "
            f"signed overflow; exit={returncode}\n{output}"
        )


def compiler_preflight(compiler: str, leaks_enabled: bool) -> None:
    with tempfile.TemporaryDirectory(prefix="cairoon-asan-probe-") as raw_dir:
        work = Path(raw_dir)
        clean_source = work / "clean.c"
        clean_binary = work / "clean"
        clean_source.write_text("int main(void) { return 0; }\n", encoding="ascii")
        run_checked([compiler, *COMPILE_FLAGS, str(clean_source), "-o", str(clean_binary)])
        clean_env = os.environ.copy()
        clean_env["ASAN_OPTIONS"] = asan_options(False)
        clean_env["UBSAN_OPTIONS"] = ubsan_options()
        run_checked([str(clean_binary)], env=clean_env)

        undefined_source = work / "undefined.c"
        undefined_binary = work / "undefined"
        undefined_source.write_text(
            "#include <limits.h>\n"
            "int main(void) { volatile int value = INT_MAX; return value + 1; }\n",
            encoding="ascii",
        )
        run_checked(
            [
                compiler,
                *COMPILE_FLAGS,
                str(undefined_source),
                "-o",
                str(undefined_binary),
            ]
        )
        undefined_probe = subprocess.run(
            [str(undefined_binary)],
            env=clean_env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        validate_ubsan_probe(undefined_probe.returncode, undefined_probe.stdout)
        print(
            "UndefinedBehaviorSanitizer preflight detected the intentional "
            "signed overflow.",
            flush=True,
        )

        if not leaks_enabled:
            return

        leak_source = work / "leak.c"
        leak_binary = work / "leak"
        leak_source.write_text(
            "#include <stdlib.h>\n"
            "int main(void) { volatile void *p = malloc(64); return p == 0; }\n",
            encoding="ascii",
        )
        run_checked([compiler, *COMPILE_FLAGS, str(leak_source), "-o", str(leak_binary)])
        leak_env = os.environ.copy()
        leak_env["ASAN_OPTIONS"] = asan_options(True)
        leak_env["LSAN_OPTIONS"] = f"exitcode={LSAN_EXIT_CODE}"
        probe = subprocess.run(
            [str(leak_binary)],
            env=leak_env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        if probe.returncode != LSAN_EXIT_CODE or "LeakSanitizer" not in probe.stdout:
            raise RuntimeError(
                "LeakSanitizer preflight did not detect an intentional leak; "
                f"exit={probe.returncode}\n{probe.stdout}"
            )
        print("LeakSanitizer preflight detected the intentional leak.", flush=True)


def lsan_options(suppression: Path | None = None) -> str:
    options = [f"exitcode={LSAN_EXIT_CODE}"]
    if suppression is not None:
        options.extend(
            [f"suppressions={suppression}", "print_suppressions=1"]
        )
    return ":".join(options)


def classify_recording_snapshot_probe(
    returncode: int,
    output: str,
) -> RecordingSnapshotLeak | None:
    if returncode == 0 and "LeakSanitizer" not in output:
        return None

    summary = re.search(
        r"SUMMARY: AddressSanitizer: (?P<bytes>\d+) byte\(s\) leaked in "
        r"(?P<count>\d+) allocation\(s\)\.",
        output,
    )
    direct_leaks = re.findall(
        r"Direct leak of (?P<bytes>\d+) byte\(s\) in 1 object\(s\) "
        r"allocated from:\n(?P<stack>.*?)(?=\nDirect leak of |\nSUMMARY:)",
        output,
        flags=re.DOTALL,
    )
    sizes = [int(size) for size, _ in direct_leaks]
    stacks = [stack for _, stack in direct_leaks]
    symbolized = all(
        "in _cairo_recording_surface_snapshot" in stack for stack in stacks
    )
    stripped = all(
        "in render_document " in stack
        and "in cairo_surface_destroy" in stack
        and "in cairo_pattern_destroy" in stack
        and "in cairo_restore" in stack
        for stack in stacks
    )
    expected = (
        returncode == LSAN_EXIT_CODE
        and "ERROR: LeakSanitizer: detected memory leaks" in output
        and len(direct_leaks) == 2
        and len(set(sizes)) == 1
        and sizes[0] in RECORDING_SNAPSHOT_ALLOCATION_SIZES
        and (symbolized or stripped)
        and "Indirect leak of " not in output
        and summary is not None
        and summary.group("count") == "2"
        and int(summary.group("bytes")) == sum(sizes)
    )
    if not expected:
        raise RuntimeError(
            "standalone Cairo recording-snapshot probe produced an unknown "
            f"sanitizer signature; exit={returncode}\n{output}"
        )
    if symbolized:
        return RecordingSnapshotLeak(
            allocation_size=sizes[0],
            suppression_template="_cairo_recording_surface_snapshot",
            suppression_path=RECORDING_SNAPSHOT_SUPPRESSION,
        )
    return RecordingSnapshotLeak(
        allocation_size=sizes[0],
        suppression_template="cairo_restore",
        suppression_path=RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION,
    )


def probe_recording_snapshot_leak(
    compiler: str,
    directory: Path,
) -> RecordingSnapshotLeak | None:
    if not RECORDING_SNAPSHOT_PROBE.is_file():
        raise RuntimeError(
            f"standalone Cairo probe not found: {RECORDING_SNAPSHOT_PROBE}"
        )
    pkg_config = first_executable(["pkg-config"])
    if pkg_config is None:
        raise RuntimeError("pkg-config is required for the standalone Cairo probe")
    flags = subprocess.run(
        [pkg_config, "--cflags", "--libs", "cairo", "fontconfig"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    ).stdout
    binary = directory / "cairo-recording-snapshot-probe"
    run_checked(
        [
            compiler,
            *COMPILE_FLAGS,
            str(RECORDING_SNAPSHOT_PROBE),
            "-o",
            str(binary),
            *shlex.split(flags),
        ]
    )
    env = os.environ.copy()
    env["ASAN_OPTIONS"] = asan_options(True)
    env["UBSAN_OPTIONS"] = ubsan_options()
    env["LSAN_OPTIONS"] = lsan_options()
    result = subprocess.run(
        [str(binary)],
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    affected = classify_recording_snapshot_probe(result.returncode, result.stdout)
    if affected is not None:
        print(
            "Standalone C probe confirmed Cairo's recording-snapshot leak; "
            f"the {affected.suppression_template!r} suppression will apply only "
            "to the vector oracle package.",
            flush=True,
        )
    else:
        print(
            "Standalone C probe is clean; no upstream leak suppression is active.",
            flush=True,
        )
    return affected


def classify_pdf_jbig2_missing_probe(
    returncode: int,
    output: str,
) -> PdfJbig2MissingLeak | None:
    if output.count(PDF_JBIG2_MISSING_STATUS_SENTINEL) != 1:
        raise RuntimeError(
            "standalone Cairo PDF JBIG2-missing probe did not emit exactly one "
            f"expected status sentinel; exit={returncode}\n{output}"
        )
    if returncode == 0 and "LeakSanitizer" not in output:
        return None

    summary = re.search(
        r"SUMMARY: AddressSanitizer: (?P<bytes>\d+) byte\(s\) leaked in "
        r"(?P<count>\d+) allocation\(s\)\.",
        output,
    )
    blocks = re.findall(
        r"(?:Direct|Indirect) leak of (?P<bytes>\d+) byte\(s\) in "
        r"(?P<count>\d+) object\(s\) allocated from:\n"
        r"(?P<stack>.*?)(?=\n(?:Direct|Indirect) leak of |\nSUMMARY:)",
        output,
        flags=re.DOTALL,
    )
    interchange_allocations = 0
    interchange_bytes = 0
    paginated_allocations = 0
    paginated_bytes = 0
    unknown_stack = False
    for size_text, count_text, stack in blocks:
        size = int(size_text)
        count = int(count_text)
        if "in _cairo_pdf_interchange_init" in stack:
            interchange_allocations += count
            interchange_bytes += size * count
        elif "in _cairo_paginated_surface_finish" in stack:
            paginated_allocations += count
            paginated_bytes += size * count
        else:
            unknown_stack = True

    total_allocations = interchange_allocations + paginated_allocations
    total_bytes = interchange_bytes + paginated_bytes
    signature = (
        total_allocations,
        total_bytes,
        interchange_allocations,
        interchange_bytes,
        paginated_allocations,
        paginated_bytes,
    )
    expected = (
        returncode == LSAN_EXIT_CODE
        and "ERROR: LeakSanitizer: detected memory leaks" in output
        and not unknown_stack
        and bool(blocks)
        and summary is not None
        and int(summary.group("count")) == total_allocations
        and int(summary.group("bytes")) == total_bytes
        and signature in PDF_JBIG2_MISSING_PROFILES
    )
    if not expected:
        raise RuntimeError(
            "standalone Cairo PDF JBIG2-missing probe produced an unknown "
            f"sanitizer signature; exit={returncode}\n{output}"
        )
    return PdfJbig2MissingLeak(*signature)


def probe_pdf_jbig2_missing_leak(
    compiler: str,
    directory: Path,
) -> PdfJbig2MissingLeak | None:
    if not PDF_JBIG2_MISSING_PROBE.is_file():
        raise RuntimeError(
            f"standalone Cairo probe not found: {PDF_JBIG2_MISSING_PROBE}"
        )
    pkg_config = first_executable(["pkg-config"])
    if pkg_config is None:
        raise RuntimeError("pkg-config is required for the standalone Cairo probe")
    flags = subprocess.run(
        [pkg_config, "--cflags", "--libs", "cairo"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    ).stdout
    binary = directory / "cairo-pdf-jbig2-missing-probe"
    run_checked(
        [
            compiler,
            *COMPILE_FLAGS,
            str(PDF_JBIG2_MISSING_PROBE),
            "-o",
            str(binary),
            *shlex.split(flags),
        ]
    )
    env = os.environ.copy()
    env["ASAN_OPTIONS"] = asan_options(True)
    env["UBSAN_OPTIONS"] = ubsan_options()
    env["LSAN_OPTIONS"] = lsan_options()
    result = subprocess.run(
        [str(binary)],
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    affected = classify_pdf_jbig2_missing_probe(result.returncode, result.stdout)
    if affected is not None:
        print(
            "Standalone C probe confirmed Cairo's PDF JBIG2-missing leak; "
            "two exact suppressions will apply only to the PDF backend test "
            "package.",
            flush=True,
        )
    else:
        print(
            "Standalone Cairo PDF JBIG2-missing probe is clean; no related "
            "suppression is active.",
            flush=True,
        )
    return affected


def create_cleanup_object(directory: Path, compiler: str) -> Path:
    source = directory / "sanitizer-cleanup.c"
    output = directory / "sanitizer-cleanup.o"
    source.write_text(CLEANUP_SOURCE, encoding="ascii")
    run_checked([compiler, *COMPILE_FLAGS, "-c", str(source), "-o", str(output)])
    return output


def create_compiler_wrapper(
    directory: Path,
    compiler: str,
    cleanup_object: Path | None = None,
) -> Path:
    wrapper = directory / "asan-cc"
    flags = " ".join(shlex.quote(flag) for flag in COMPILE_FLAGS)
    command = f"{shlex.quote(compiler)} {flags}"
    if cleanup_object is None:
        script = f'#!/bin/sh\nexec {command} "$@"\n'
    else:
        cleanup = shlex.quote(str(cleanup_object))
        script = (
            "#!/bin/sh\n"
            'for arg in "$@"; do\n'
            '  case "$arg" in\n'
            f'    -c|-E|-S|-M|-MM) exec {command} "$@" ;;\n'
            "  esac\n"
            "done\n"
            f'exec {command} "$@" {cleanup}\n'
        )
    wrapper.write_text(script, encoding="ascii")
    wrapper.chmod(0o755)
    return wrapper


def empty_allocator_object(compiler: str, directory: Path) -> Path:
    source = directory / "empty-runtime.c"
    output = directory / "empty-runtime.o"
    source.write_text("/* Let ASan own malloc/free interception. */\n", encoding="ascii")
    run_checked([compiler, "-c", str(source), "-o", str(output)])
    return output


def create_shadow_toolchain(
    source: Path,
    directory: Path,
    allocator_object: Path,
) -> Path:
    shadow = directory / "moon-toolchain"
    shadow.mkdir()
    for entry in source.iterdir():
        if entry.name == "lib":
            continue
        (shadow / entry.name).symlink_to(entry, target_is_directory=entry.is_dir())

    source_lib = source / "lib"
    shadow_lib = shadow / "lib"
    shadow_lib.mkdir()
    for entry in source_lib.iterdir():
        if entry.name in {"libmoonbitrun.o", ".cairoon-sanitizer.lock"}:
            continue
        (shadow_lib / entry.name).symlink_to(
            entry,
            target_is_directory=entry.is_dir(),
        )
    shutil.copy2(allocator_object, shadow_lib / "libmoonbitrun.o")
    return shadow


def validate_suppression_usage(
    output: str,
    leak: RecordingSnapshotLeak,
) -> None:
    table = re.search(
        r"Suppressions used:\n\s*count\s+bytes\s+template\n"
        r"(?P<rows>.*?)\n-+",
        output,
        flags=re.DOTALL,
    )
    rows = [] if table is None else re.findall(
        r"^\s*(\d+)\s+(\d+)\s+(\S+)\s*$",
        table.group("rows"),
        flags=re.MULTILINE,
    )
    expected = [
        (
            str(RECORDING_SNAPSHOT_VECTOR_ALLOCATIONS),
            str(leak.allocation_size * RECORDING_SNAPSHOT_VECTOR_ALLOCATIONS),
            leak.suppression_template,
        )
    ]
    if rows != expected:
        raise RuntimeError(
            "vector oracle used an unexpected leak suppression set; "
            f"expected={expected!r}, actual={rows!r}\n{output}"
        )


def validate_pdf_jbig2_suppression_usage(
    output: str,
    leak: PdfJbig2MissingLeak,
) -> None:
    table = re.search(
        r"Suppressions used:\n\s*count\s+bytes\s+template\n"
        r"(?P<rows>.*?)\n-+",
        output,
        flags=re.DOTALL,
    )
    rows = [] if table is None else re.findall(
        r"^\s*(\d+)\s+(\d+)\s+(\S+)\s*$",
        table.group("rows"),
        flags=re.MULTILINE,
    )
    expected = {
        "_cairo_pdf_interchange_init": (
            str(leak.interchange_allocations),
            str(leak.interchange_bytes),
        ),
        "_cairo_paginated_surface_finish": (
            str(leak.paginated_allocations),
            str(leak.paginated_bytes),
        ),
    }
    actual = {template: (count, size) for count, size, template in rows}
    if len(rows) != len(actual) or actual != expected:
        raise RuntimeError(
            "PDF backend used an unexpected leak suppression set; "
            f"expected={expected!r}, actual={actual!r}\n{output}"
        )


def moon_test_command(
    moon: str,
    package: str | None,
    test_filter: str | None,
    verbose: bool,
) -> list[str]:
    command = [moon, "test"]
    if package is not None:
        command.append(package)
    command.extend(["--target", "native", "--deny-warn"])
    if test_filter is not None:
        command.extend(["--filter", test_filter])
    if verbose:
        command.append("-v")
    return command


def discover_packages(repo_root: Path = REPO_ROOT) -> list[str]:
    source_root = repo_root / "src"
    return sorted(
        path.parent.relative_to(repo_root).as_posix()
        for path in source_root.rglob("moon.pkg")
    )


def normalize_package(package: str) -> str:
    normalized = Path(package).as_posix().rstrip("/")
    return normalized[2:] if normalized.startswith("./") else normalized


def run_suite(
    moon: str,
    compiler: str,
    archiver: str,
    toolchain: Path,
    leaks_enabled: bool,
    package: str | None,
    test_filter: str | None,
    verbose: bool,
) -> int:
    result = 1
    cleanup_failed = False

    with tempfile.TemporaryDirectory(prefix="cairoon-sanitizer-") as raw_dir:
        work = Path(raw_dir)
        snapshot_leak = (
            probe_recording_snapshot_leak(compiler, work)
            if leaks_enabled
            else None
        )
        pdf_jbig2_leak = (
            probe_pdf_jbig2_missing_leak(compiler, work)
            if leaks_enabled
            else None
        )
        cleanup_object = create_cleanup_object(work, compiler) if leaks_enabled else None
        wrapper = create_compiler_wrapper(work, compiler, cleanup_object)
        replacement = empty_allocator_object(compiler, work)
        shadow_toolchain = create_shadow_toolchain(toolchain, work, replacement)
        env = os.environ.copy()
        env["MOON_CC"] = str(wrapper)
        env["MOON_AR"] = archiver
        env["MOON_TOOLCHAIN_ROOT"] = str(shadow_toolchain)
        env["ASAN_OPTIONS"] = asan_options(leaks_enabled)
        env["UBSAN_OPTIONS"] = ubsan_options()
        if leaks_enabled:
            env["LSAN_OPTIONS"] = lsan_options()
        else:
            env.pop("LSAN_OPTIONS", None)

        if package is None:
            if test_filter is not None:
                raise RuntimeError("--filter requires --package for sanitizer runs")
            targets = [(candidate, None) for candidate in discover_packages()]
        else:
            targets = [(normalize_package(package), test_filter)]

        try:
            print(
                "Using isolated MoonBit toolchain with sanitizer-owned allocator: "
                f"{shadow_toolchain}",
                flush=True,
            )
            run_checked([moon, "clean"], cwd=REPO_ROOT, env=env)
            result = 0
            for target, target_filter in targets:
                command_env = env.copy()
                recording_suppressed = (
                    snapshot_leak is not None
                    and target in RECORDING_SNAPSHOT_PACKAGES
                )
                pdf_jbig2_suppressed = (
                    pdf_jbig2_leak is not None
                    and target in PDF_JBIG2_MISSING_PACKAGES
                )
                if recording_suppressed and pdf_jbig2_suppressed:
                    raise RuntimeError(
                        f"package {target!r} requested incompatible suppressions"
                    )
                suppressed = recording_suppressed or pdf_jbig2_suppressed
                if recording_suppressed:
                    command_env["LSAN_OPTIONS"] = lsan_options(
                        snapshot_leak.suppression_path
                    )
                elif pdf_jbig2_suppressed:
                    command_env["LSAN_OPTIONS"] = lsan_options(
                        PDF_JBIG2_MISSING_SUPPRESSION
                    )
                command = moon_test_command(
                    moon,
                    target,
                    target_filter,
                    verbose,
                )
                print(
                    "+ " + " ".join(shlex.quote(part) for part in command),
                    flush=True,
                )
                if suppressed:
                    completed = subprocess.run(
                        command,
                        cwd=REPO_ROOT,
                        env=command_env,
                        text=True,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT,
                    )
                    print(completed.stdout, end="", flush=True)
                    result = completed.returncode
                    if (
                        result == 0
                        and target_filter is None
                        and recording_suppressed
                    ):
                        validate_suppression_usage(completed.stdout, snapshot_leak)
                    elif (
                        result == 0
                        and target_filter is None
                        and pdf_jbig2_suppressed
                    ):
                        validate_pdf_jbig2_suppression_usage(
                            completed.stdout,
                            pdf_jbig2_leak,
                        )
                else:
                    result = subprocess.run(
                        command,
                        cwd=REPO_ROOT,
                        env=command_env,
                    ).returncode
                if result != 0:
                    break
        finally:
            cleanup = subprocess.run([moon, "clean"], cwd=REPO_ROOT, env=env)
            cleanup_failed = cleanup.returncode != 0

    return result if result != 0 else (1 if cleanup_failed else 0)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Run cairoon's complete native test suite under ASan/LSan/UBSan"
        )
    )
    parser.add_argument("--cc", help="sanitizer-capable compiler")
    parser.add_argument("--ar", help="native archiver")
    parser.add_argument("--package", help="run one package during local diagnosis")
    parser.add_argument(
        "--filter",
        help="run tests matching one MoonBit test filter; requires --package",
    )
    parser.add_argument(
        "--leaks",
        choices=LEAK_MODES,
        default=os.environ.get("CAIROON_SANITIZER_LEAKS", "auto"),
        help="LSan policy; auto enables it only on Linux",
    )
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    system = platform.system()
    if system not in {"Darwin", "Linux"}:
        raise RuntimeError(f"unsupported sanitizer platform: {system}")
    leaks_enabled = leak_detection_enabled(args.leaks, system)
    compiler = choose_compiler(args.cc, system)
    archiver = choose_archiver(args.ar, system)
    moon = find_moon()
    toolchain = find_moonbit_toolchain(moon)

    print(f"Sanitizer compiler: {compiler}")
    print(f"Sanitizer archiver: {archiver}")
    print(f"Sanitizer policy: {policy_description(system, leaks_enabled)}")
    compiler_preflight(compiler, leaks_enabled)

    return run_suite(
        moon,
        compiler,
        archiver,
        toolchain,
        leaks_enabled,
        args.package,
        args.filter,
        args.verbose,
    )


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"sanitizer error: {error}", file=sys.stderr)
        raise SystemExit(1)
