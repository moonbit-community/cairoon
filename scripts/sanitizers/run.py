#!/usr/bin/env python3
"""Run the native suite with real ASan, LSan, and UBSan instrumentation."""

from __future__ import annotations

import argparse
import os
import platform
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

from leak_probes import (
    PDF_JBIG2_MISSING_PACKAGES,
    PDF_JBIG2_MISSING_PROBE,
    PDF_JBIG2_MISSING_PROFILES,
    PDF_JBIG2_MISSING_STATUS_SENTINEL,
    PDF_JBIG2_MISSING_STRIPPED_SUPPRESSION,
    PDF_JBIG2_MISSING_SUPPRESSION,
    RECORDING_SNAPSHOT_ALLOCATION_SIZES,
    RECORDING_SNAPSHOT_PACKAGES,
    RECORDING_SNAPSHOT_PROBE,
    RECORDING_SNAPSHOT_STRIPPED_SUPPRESSION,
    RECORDING_SNAPSHOT_SUPPRESSION,
    RECORDING_SNAPSHOT_VECTOR_ALLOCATIONS,
    PdfJbig2MissingLeak,
    RecordingSnapshotLeak,
    classify_pdf_jbig2_missing_probe,
    classify_recording_snapshot_probe,
    lsan_options,
    probe_pdf_jbig2_missing_leak,
    probe_recording_snapshot_leak,
    validate_pdf_jbig2_suppression_usage,
    validate_suppression_usage,
)
from policy import (
    LEAK_MODES,
    asan_options,
    leak_detection_enabled,
    policy_description,
    ubsan_options,
)
from toolchain import (
    CLEANUP_SOURCE,
    COMPILE_FLAGS,
    LSAN_EXIT_CODE,
    REPO_ROOT,
    choose_archiver,
    choose_compiler,
    compiler_preflight,
    create_cleanup_object,
    create_compiler_wrapper,
    create_shadow_toolchain,
    empty_allocator_object,
    find_moon,
    find_moonbit_toolchain,
    first_executable,
    resolve_executable,
    run_checked,
    validate_ubsan_probe,
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
        cleanup_object = (
            create_cleanup_object(work, compiler) if leaks_enabled else None
        )
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
                        pdf_jbig2_leak.suppression_path
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
