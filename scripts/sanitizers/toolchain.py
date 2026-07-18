"""Compiler and isolated MoonBit toolchain support for sanitizer runs."""

from __future__ import annotations

import os
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path

from policy import asan_options, ubsan_options


COMPILE_FLAGS = (
    "-g",
    "-fsanitize=address,undefined",
    "-fno-omit-frame-pointer",
)
LSAN_EXIT_CODE = 86
REPO_ROOT = Path(__file__).resolve().parents[2]
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


def resolve_executable(candidate: str) -> str | None:
    if "/" in candidate:
        path = Path(candidate).expanduser()
        return (
            str(path.resolve())
            if path.is_file() and os.access(path, os.X_OK)
            else None
        )
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
        run_checked(
            [compiler, *COMPILE_FLAGS, str(clean_source), "-o", str(clean_binary)]
        )
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
        run_checked(
            [compiler, *COMPILE_FLAGS, str(leak_source), "-o", str(leak_binary)]
        )
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
