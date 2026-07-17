#!/usr/bin/env python3
"""Validate the exact archive produced by ``moon package``."""

from __future__ import annotations

import argparse
import hashlib
import pathlib
import sys
import zipfile


REQUIRED_MEMBERS = frozenset(
    {
        "COPYING",
        "COPYING-LGPL-2.1",
        "COPYING-MPL-1.1",
        "README.md",
        "moon.mod",
        "scripts/api/pycairo-api-snapshot.json",
        "scripts/build/cairo_config.py",
        "src/README.mbt.md",
        "src/moon.pkg",
        "src/pkg.generated.mbti",
    }
)
REQUIRED_TEXT_MARKERS = {
    "COPYING": (
        "COPYING-LGPL-2.1",
        "COPYING-MPL-1.1",
        "SPDX-License-Identifier: LGPL-2.1-only OR MPL-1.1",
    ),
    "COPYING-LGPL-2.1": (
        "GNU LESSER GENERAL PUBLIC LICENSE",
        "Version 2.1, February 1999",
    ),
    "COPYING-MPL-1.1": (
        "MOZILLA PUBLIC LICENSE",
        "Version 1.1",
    ),
    "moon.mod": ('license = "LGPL-2.1-only OR MPL-1.1"',),
    "scripts/api/pycairo-api-snapshot.json": (
        '"schema_version": 1',
        '"path": "cairo/__init__.pyi"',
    ),
}
REQUIRED_SHA256 = {
    "COPYING-LGPL-2.1": (
        "d80c9d084ebfb50ea1ed91bfbc2410d6ce542097a32c43b00781b83adcb8c77f"
    ),
    "COPYING-MPL-1.1": (
        "53692a2ed6c6a2c6ec9b32dd0b820dfae91e0a1fcdf625ca9ed0bdf8705fcc4f"
    ),
}


def check_archive(path: pathlib.Path) -> tuple[list[str], int]:
    errors: list[str] = []
    try:
        with zipfile.ZipFile(path) as archive:
            members = archive.infolist()
            bad_member = archive.testzip()
            canonical_members: dict[str, zipfile.ZipInfo] = {}

            for member in members:
                normalized = member.filename.replace("\\", "/")
                member_path = pathlib.PurePosixPath(normalized)
                parts = tuple(part for part in member_path.parts if part not in ("", "."))
                if member_path.is_absolute() or ".." in parts:
                    errors.append(f"{path}: unsafe archive member {member.filename!r}")
                    continue
                canonical = "/".join(parts)
                if canonical in canonical_members:
                    errors.append(f"{path}: duplicate archive member {canonical!r}")
                    continue
                canonical_members[canonical] = member
                if parts and parts[0] == "integration":
                    errors.append(
                        f"{path}: integration fixture leaked into {member.filename!r}"
                    )

            missing = sorted(REQUIRED_MEMBERS - set(canonical_members))
            for member_name in missing:
                errors.append(f"{path}: missing required publication member {member_name!r}")

            for member_name, markers in REQUIRED_TEXT_MARKERS.items():
                member = canonical_members.get(member_name)
                if member is None:
                    continue
                if member.is_dir():
                    errors.append(f"{path}: required member {member_name!r} is a directory")
                    continue
                try:
                    payload = archive.read(member)
                    text = payload.decode("utf-8")
                except (OSError, RuntimeError, UnicodeDecodeError) as exc:
                    errors.append(f"{path}: cannot read required member {member_name!r}: {exc}")
                    continue
                for marker in markers:
                    if marker not in text:
                        errors.append(
                            f"{path}: required member {member_name!r} is missing "
                            f"marker {marker!r}"
                        )
                expected_digest = REQUIRED_SHA256.get(member_name)
                if expected_digest is not None:
                    actual_digest = hashlib.sha256(payload).hexdigest()
                    if actual_digest != expected_digest:
                        errors.append(
                            f"{path}: required member {member_name!r} has SHA-256 "
                            f"{actual_digest}, expected {expected_digest}"
                        )
    except (OSError, RuntimeError, zipfile.BadZipFile) as exc:
        return [f"{path}: invalid publication archive: {exc}"], 0

    if not members:
        errors.append(f"{path}: publication archive is empty")
    if bad_member is not None:
        errors.append(f"{path}: CRC check failed for {bad_member!r}")

    return errors, len(members)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=pathlib.Path)
    args = parser.parse_args()

    errors, member_count = check_archive(args.archive)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print(
        "Publication archive integrity and contents ok; "
        f"{member_count} members checked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
