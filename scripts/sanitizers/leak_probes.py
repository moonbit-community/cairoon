"""Strict upstream-Cairo leak probes and package-scoped suppressions."""

from __future__ import annotations

import os
import re
import shlex
import subprocess
from dataclasses import dataclass
from pathlib import Path

from policy import asan_options, ubsan_options
from toolchain import (
    COMPILE_FLAGS,
    LSAN_EXIT_CODE,
    REPO_ROOT,
    first_executable,
    run_checked,
)


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


def lsan_options(suppression: Path | None = None) -> str:
    options = [f"exitcode={LSAN_EXIT_CODE}"]
    if suppression is not None:
        options.extend([f"suppressions={suppression}", "print_suppressions=1"])
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
    rows = (
        []
        if table is None
        else re.findall(
            r"^\s*(\d+)\s+(\d+)\s+(\S+)\s*$",
            table.group("rows"),
            flags=re.MULTILINE,
        )
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
    rows = (
        []
        if table is None
        else re.findall(
            r"^\s*(\d+)\s+(\d+)\s+(\S+)\s*$",
            table.group("rows"),
            flags=re.MULTILINE,
        )
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
