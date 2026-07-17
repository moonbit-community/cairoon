#!/usr/bin/env python3
"""Emit Moon's native build configuration for the local Cairo installation."""

from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import sys
from collections.abc import Callable, Mapping
from typing import NamedTuple, TextIO


MINIMUM_CAIRO_VERSION = (1, 15, 10)
NATIVE_PACKAGE = "CAIMEOX/cairoon/native"
VERSION_PATTERN = re.compile(r"^(\d+)\.(\d+)\.(\d+)(?:\D.*)?$")


class CairoConfigError(RuntimeError):
    """Raised when the local Cairo development package cannot be configured."""


class CairoConfig(NamedTuple):
    version: tuple[int, int, int]
    cflags: tuple[str, ...]
    link_flags: tuple[str, ...]


Runner = Callable[..., subprocess.CompletedProcess[str]]


def parse_version(raw: str) -> tuple[int, int, int]:
    match = VERSION_PATTERN.fullmatch(raw.strip())
    if match is None:
        raise CairoConfigError(f"invalid Cairo version from pkg-config: {raw!r}")
    major, minor, micro = match.groups()
    return int(major), int(minor), int(micro)


def _run_pkg_config(
    pkg_config: str,
    option: str,
    environ: Mapping[str, str],
    runner: Runner,
) -> str:
    command = [pkg_config, option, "cairo"]
    try:
        completed = runner(
            command,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=dict(environ),
        )
    except OSError as exc:
        raise CairoConfigError(f"cannot execute {pkg_config!r}: {exc}") from exc
    if completed.returncode != 0:
        detail = completed.stderr.strip() or completed.stdout.strip()
        if not detail:
            detail = f"{pkg_config} {option} cairo exited {completed.returncode}"
        raise CairoConfigError(detail)
    return completed.stdout.strip()


def _split_flags(raw: str, label: str) -> tuple[str, ...]:
    try:
        return tuple(shlex.split(raw))
    except ValueError as exc:
        raise CairoConfigError(f"invalid {label} from pkg-config: {exc}") from exc


def discover_cairo(
    *,
    environ: Mapping[str, str],
    runner: Runner = subprocess.run,
) -> CairoConfig:
    pkg_config = environ.get("PKG_CONFIG", "pkg-config")
    if not pkg_config:
        raise CairoConfigError("PKG_CONFIG must name a pkg-config executable")

    version = parse_version(
        _run_pkg_config(pkg_config, "--modversion", environ, runner)
    )
    if version < MINIMUM_CAIRO_VERSION:
        found = ".".join(str(part) for part in version)
        raise CairoConfigError(
            f"Cairo 1.15.10 or newer is required; pkg-config found {found}"
        )

    cflags = _split_flags(
        _run_pkg_config(pkg_config, "--cflags", environ, runner),
        "Cairo compiler flags",
    )
    link_flags = _split_flags(
        _run_pkg_config(pkg_config, "--libs", environ, runner),
        "Cairo linker flags",
    )
    if not link_flags:
        raise CairoConfigError("pkg-config --libs cairo returned no linker flags")
    return CairoConfig(version=version, cflags=cflags, link_flags=link_flags)


def build_output(config: CairoConfig) -> dict[str, object]:
    return {
        "vars": {"CAIRO_CFLAGS": shlex.join(config.cflags)},
        "link_configs": [
            {
                "package": NATIVE_PACKAGE,
                "link_flags": shlex.join(config.link_flags),
            }
        ],
    }


def main(
    *,
    stdin: TextIO = sys.stdin,
    stdout: TextIO = sys.stdout,
    stderr: TextIO = sys.stderr,
    environ: Mapping[str, str] = os.environ,
) -> int:
    try:
        payload = json.load(stdin)
        if not isinstance(payload, dict):
            raise CairoConfigError("pre-build input must be a JSON object")
        protocol_env = payload.get("env", environ)
        if not isinstance(protocol_env, dict) or not all(
            isinstance(key, str) and isinstance(value, str)
            for key, value in protocol_env.items()
        ):
            raise CairoConfigError("pre-build env must map strings to strings")
        config = discover_cairo(environ=protocol_env)
        json.dump(build_output(config), stdout, sort_keys=True, separators=(",", ":"))
        stdout.write("\n")
        return 0
    except (CairoConfigError, json.JSONDecodeError) as exc:
        print(f"cairoon build configuration failed: {exc}", file=stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
