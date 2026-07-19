#!/usr/bin/env python3
"""Validate the exact archive produced by ``moon package``."""

from __future__ import annotations

import argparse
import hashlib
import pathlib
import sys
import zipfile


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
FFI_OWNERSHIP_SUPPORT = frozenset(
    {
        "scripts/check-ffi-ownership.py",
        "scripts/ffi_ownership/__init__.py",
        "scripts/ffi_ownership/device_cleanup.py",
        "scripts/ffi_ownership/mapped_cleanup.py",
        "scripts/ffi_ownership/source.py",
        "scripts/ffi_ownership/surface_cleanup.py",
    }
)
REQUIRED_MEMBERS = frozenset(
    {
        "COPYING",
        "COPYING-LGPL-2.1",
        "COPYING-MPL-1.1",
        "API_INVENTORY.md",
        "README.md",
        "moon.mod",
        "scripts/api/attribute_mappings.py",
        "scripts/api/method_mappings.py",
        "scripts/api/protocol_mappings.py",
        "scripts/api/pycairo-api-snapshot.json",
        "scripts/api/snapshot.py",
        "scripts/build/cairo_config.py",
        "scripts/check-api-inventory.py",
        "scripts/check-external-owners.py",
        "scripts/lifetime/owners.json",
        "src/README.mbt.md",
        "src/moon.pkg",
        "src/pkg.generated.mbti",
    }
) | FFI_OWNERSHIP_SUPPORT
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
    "moon.mod": (
        'license = "LGPL-2.1-only OR MPL-1.1"',
        'preferred_target = "native"',
        'supported_targets = "native"',
    ),
    "scripts/api/pycairo-api-snapshot.json": (
        '"schema_version": 2',
        '"path": "cairo/__init__.pyi"',
        '"protocols": {',
        '"attributes": {',
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
SOURCE_IDENTICAL_MEMBERS = frozenset(
    {
        "API_INVENTORY.md",
        "scripts/api/attribute_mappings.py",
        "scripts/api/method_mappings.py",
        "scripts/api/protocol_mappings.py",
        "scripts/api/pycairo-api-snapshot.json",
        "scripts/api/snapshot.py",
        "scripts/check-api-inventory.py",
        "scripts/check-external-owners.py",
        "scripts/lifetime/owners.json",
    }
) | FFI_OWNERSHIP_SUPPORT


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

            for member_name in SOURCE_IDENTICAL_MEMBERS:
                member = canonical_members.get(member_name)
                if member is None:
                    continue
                if member.is_dir():
                    errors.append(
                        f"{path}: required member {member_name!r} is a directory"
                    )
                    continue
                try:
                    archive_payload = archive.read(member)
                    source_payload = (REPO_ROOT / member_name).read_bytes()
                except (OSError, RuntimeError) as exc:
                    errors.append(
                        f"{path}: cannot compare required member "
                        f"{member_name!r}: {exc}"
                    )
                    continue
                if archive_payload != source_payload:
                    errors.append(
                        f"{path}: required member {member_name!r} does not match "
                        "the verified source file"
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
