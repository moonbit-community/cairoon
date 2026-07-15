#!/usr/bin/env python3
"""Validate the exact archive produced by ``moon package``."""

from __future__ import annotations

import argparse
import pathlib
import sys
import zipfile


def check_archive(path: pathlib.Path) -> tuple[list[str], int]:
    errors: list[str] = []
    try:
        with zipfile.ZipFile(path) as archive:
            members = archive.infolist()
            bad_member = archive.testzip()
    except (OSError, RuntimeError, zipfile.BadZipFile) as exc:
        return [f"{path}: invalid publication archive: {exc}"], 0

    if not members:
        errors.append(f"{path}: publication archive is empty")
    if bad_member is not None:
        errors.append(f"{path}: CRC check failed for {bad_member!r}")

    for member in members:
        normalized = member.filename.replace("\\", "/")
        member_path = pathlib.PurePosixPath(normalized)
        parts = tuple(part for part in member_path.parts if part not in ("", "."))
        if member_path.is_absolute() or ".." in parts:
            errors.append(f"{path}: unsafe archive member {member.filename!r}")
            continue
        if parts and parts[0] == "integration":
            errors.append(
                f"{path}: integration fixture leaked into {member.filename!r}"
            )

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
