#!/usr/bin/env python3
"""Validate the exact archive produced by ``moon package``."""

from __future__ import annotations

import argparse
import hashlib
import pathlib
import re
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
RELIABILITY_SUPPORT = frozenset(
    {
        "scripts/check-reliability-ledger.py",
        "scripts/reliability/__init__.py",
        "scripts/reliability/ci_workflow.py",
        "scripts/reliability/evidence.py",
        "scripts/reliability/gates.py",
        "scripts/reliability/markdown.py",
        "scripts/matrix/Dockerfile",
        "scripts/matrix/run-lane.sh",
        "scripts/test-cairo-matrix.sh",
    }
)
SANITIZER_SUPPORT = frozenset(
    {
        "scripts/sanitizers/leak_probes.py",
        "scripts/sanitizers/lsan-cairo-pdf-jbig2-missing-stripped.supp",
        "scripts/sanitizers/lsan-cairo-pdf-jbig2-missing.supp",
        "scripts/sanitizers/lsan-cairo-recording-snapshot-stripped.supp",
        "scripts/sanitizers/lsan-cairo-recording-snapshot.supp",
        "scripts/sanitizers/policy.py",
        "scripts/sanitizers/probes/cairo_pdf_jbig2_missing_probe.c",
        "scripts/sanitizers/probes/cairo_recording_snapshot_probe.c",
        "scripts/sanitizers/run.py",
        "scripts/sanitizers/toolchain.py",
    }
)
REQUIRED_MEMBERS = frozenset(
    {
        "COPYING",
        "COPYING-LGPL-2.1",
        "COPYING-MPL-1.1",
        "API_INVENTORY.md",
        "CHANGELOG.md",
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
        "scripts/check-publication-archive.py",
        "scripts/check-publish-dry-run.py",
        "scripts/lifetime/owners.json",
        "scripts/tests/publication_archive_support.py",
        "scripts/tests/test_publication_archive.py",
        "scripts/tests/test_publish_dry_run.py",
        "src/README.mbt.md",
        "src/moon.pkg",
        "src/pkg.generated.mbti",
    }
) | FFI_OWNERSHIP_SUPPORT | RELIABILITY_SUPPORT | SANITIZER_SUPPORT
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
        'name = "CAIMEOX/cairoon"',
        'license = "LGPL-2.1-only OR MPL-1.1"',
        'repository = "https://github.com/moonbit-community/cairoon"',
        'preferred_target = "native"',
        'supported_targets = "native"',
        '"moonbitlang/x@',
        '"--moonbit-unstable-prebuild": "scripts/build/cairo_config.py"',
        'exclude: [ "integration" ]',
    ),
    "CHANGELOG.md": ("# Changelog",),
    "README.md": ("temporarily unstable",),
    "src/README.mbt.md": ("temporarily unstable",),
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
EXCLUDED_PUBLICATION_ROOTS = frozenset({"_build", "integration"})
EXCLUDED_PUBLICATION_PARTS = frozenset({"__pycache__"})
MODULE_NAME_RE = re.compile(r'^name\s*=\s*"([^"]+)"\s*$', re.MULTILINE)
MODULE_VERSION_RE = re.compile(r'^version\s*=\s*"([^"]+)"\s*$', re.MULTILINE)


def expected_publication_members(
    repo_root: pathlib.Path,
) -> dict[str, pathlib.Path]:
    expected: dict[str, pathlib.Path] = {}
    for top_level in repo_root.iterdir():
        if (
            top_level.name.startswith(".")
            or top_level.name in EXCLUDED_PUBLICATION_ROOTS
        ):
            continue
        candidates = (top_level,) if top_level.is_file() else top_level.rglob("*")
        for source in candidates:
            if not source.is_file():
                continue
            relative = source.relative_to(repo_root)
            if source.suffix == ".pyc" or any(
                part.startswith(".") or part in EXCLUDED_PUBLICATION_PARTS
                for part in relative.parts
            ):
                continue
            expected[relative.as_posix()] = source
    return expected


def check_release_contract(
    texts: dict[str, str],
    archive_path: pathlib.Path,
) -> list[str]:
    module_text = texts.get("moon.mod")
    if module_text is None:
        return []

    name_matches = MODULE_NAME_RE.findall(module_text)
    version_matches = MODULE_VERSION_RE.findall(module_text)
    errors: list[str] = []
    if len(name_matches) != 1:
        errors.append(
            f"{archive_path}: moon.mod must declare exactly one module name"
        )
    if len(version_matches) != 1:
        errors.append(
            f"{archive_path}: moon.mod must declare exactly one module version"
        )
    if len(name_matches) != 1 or len(version_matches) != 1:
        return errors

    module_name = name_matches[0]
    module_version = version_matches[0]
    changelog = texts.get("CHANGELOG.md")
    if changelog is not None:
        heading = re.compile(
            rf"^## \[?{re.escape(module_version)}\]? - ",
            re.MULTILINE,
        )
        if heading.search(changelog) is None:
            errors.append(
                f"{archive_path}: CHANGELOG.md must contain a release heading "
                f"for {module_version}"
            )

    install_command = f"moon add {module_name}@{module_version}"
    for readme in ("README.md", "src/README.mbt.md"):
        readme_text = texts.get(readme)
        if readme_text is not None and install_command not in readme_text:
            errors.append(
                f"{archive_path}: {readme} must install the packaged version "
                f"with {install_command!r}"
            )
    return errors


def check_archive(
    path: pathlib.Path,
    repo_root: pathlib.Path = REPO_ROOT,
) -> tuple[list[str], int]:
    errors: list[str] = []
    try:
        with zipfile.ZipFile(path) as archive:
            members = archive.infolist()
            bad_member = archive.testzip()
            canonical_members: dict[str, zipfile.ZipInfo] = {}
            required_texts: dict[str, str] = {}

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

            source_members = expected_publication_members(repo_root)
            archive_files = {
                name: member
                for name, member in canonical_members.items()
                if not member.is_dir()
            }
            for member_name in sorted(set(source_members) - set(archive_files)):
                errors.append(
                    f"{path}: missing verified source member {member_name!r}"
                )
            for member_name in sorted(set(canonical_members) - set(source_members)):
                errors.append(
                    f"{path}: archive member {member_name!r} has no verified "
                    "source file"
                )

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
                required_texts[member_name] = text
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

            errors.extend(check_release_contract(required_texts, path))

            for member_name in sorted(set(archive_files) & set(source_members)):
                member = archive_files[member_name]
                try:
                    archive_payload = archive.read(member)
                    source_payload = source_members[member_name].read_bytes()
                except (OSError, RuntimeError) as exc:
                    errors.append(
                        f"{path}: cannot compare publication member "
                        f"{member_name!r}: {exc}"
                    )
                    continue
                if archive_payload != source_payload:
                    errors.append(
                        f"{path}: publication member {member_name!r} does not match "
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
