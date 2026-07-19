#!/usr/bin/env python3
"""Tests for the publication archive validator."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
import warnings
import zipfile


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-publication-archive.py"
REPO_ROOT = CHECKER.parents[1]
FFI_OWNERSHIP_SUPPORT = (
    "scripts/check-ffi-ownership.py",
    "scripts/ffi_ownership/__init__.py",
    "scripts/ffi_ownership/device_cleanup.py",
    "scripts/ffi_ownership/mapped_cleanup.py",
    "scripts/ffi_ownership/source.py",
    "scripts/ffi_ownership/surface_cleanup.py",
)
EXPECTED_RELIABILITY_SUPPORT = frozenset(
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
EXPECTED_SANITIZER_SUPPORT = frozenset(
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
VALID_MEMBERS = {
    "COPYING": (REPO_ROOT / "COPYING").read_bytes(),
    "COPYING-LGPL-2.1": (REPO_ROOT / "COPYING-LGPL-2.1").read_bytes(),
    "COPYING-MPL-1.1": (REPO_ROOT / "COPYING-MPL-1.1").read_bytes(),
    "API_INVENTORY.md": (REPO_ROOT / "API_INVENTORY.md").read_bytes(),
    "CHANGELOG.md": (REPO_ROOT / "CHANGELOG.md").read_bytes(),
    "README.md": (REPO_ROOT / "README.md").read_bytes(),
    "moon.mod": (REPO_ROOT / "moon.mod").read_bytes(),
    "scripts/api/attribute_mappings.py": (
        REPO_ROOT / "scripts" / "api" / "attribute_mappings.py"
    ).read_bytes(),
    "scripts/api/method_mappings.py": (
        REPO_ROOT / "scripts" / "api" / "method_mappings.py"
    ).read_bytes(),
    "scripts/api/protocol_mappings.py": (
        REPO_ROOT / "scripts" / "api" / "protocol_mappings.py"
    ).read_bytes(),
    "scripts/api/pycairo-api-snapshot.json": (
        REPO_ROOT / "scripts" / "api" / "pycairo-api-snapshot.json"
    ).read_bytes(),
    "scripts/api/snapshot.py": (
        REPO_ROOT / "scripts" / "api" / "snapshot.py"
    ).read_bytes(),
    "scripts/build/cairo_config.py": b"# build config\n",
    "scripts/check-api-inventory.py": (
        REPO_ROOT / "scripts" / "check-api-inventory.py"
    ).read_bytes(),
    "scripts/check-publish-dry-run.py": (
        REPO_ROOT / "scripts" / "check-publish-dry-run.py"
    ).read_bytes(),
    "scripts/tests/test_publish_dry_run.py": (
        REPO_ROOT / "scripts" / "tests" / "test_publish_dry_run.py"
    ).read_bytes(),
    "scripts/check-external-owners.py": (
        REPO_ROOT / "scripts" / "check-external-owners.py"
    ).read_bytes(),
    "scripts/lifetime/owners.json": (
        REPO_ROOT / "scripts" / "lifetime" / "owners.json"
    ).read_bytes(),
    "src/README.mbt.md": (REPO_ROOT / "src" / "README.mbt.md").read_bytes(),
    "src/moon.pkg": b"",
    "src/pkg.generated.mbti": b"package example\n",
} | {
    member_name: (REPO_ROOT / member_name).read_bytes()
    for member_name in FFI_OWNERSHIP_SUPPORT
} | {
    member_name: (REPO_ROOT / member_name).read_bytes()
    for member_name in EXPECTED_RELIABILITY_SUPPORT
} | {
    member_name: (REPO_ROOT / member_name).read_bytes()
    for member_name in EXPECTED_SANITIZER_SUPPORT
}


def load_checker():
    spec = importlib.util.spec_from_file_location("check_publication_archive", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PublicationArchiveCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.archive = self.root / "publication.zip"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_archive(
        self,
        members: dict[str, bytes],
        *,
        include_required: bool = True,
    ) -> None:
        payloads = dict(VALID_MEMBERS) if include_required else {}
        payloads.update(members)
        with zipfile.ZipFile(self.archive, "w", zipfile.ZIP_STORED) as archive:
            for name, data in payloads.items():
                archive.writestr(name, data)

    def check(self) -> tuple[list[str], int]:
        return self.checker.check_archive(self.archive)

    def test_valid_archive_passes(self) -> None:
        self.write_archive({"src/a.mbt": b""})

        errors, member_count = self.check()

        self.assertEqual(errors, [])
        self.assertEqual(member_count, len(VALID_MEMBERS) + 1)

    def test_missing_license_file_fails(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["COPYING-MPL-1.1"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(any("COPYING-MPL-1.1" in error for error in errors), errors)

    def test_incorrect_license_text_fails(self) -> None:
        self.write_archive(
            {
                "COPYING-LGPL-2.1": (
                    b"GNU LESSER GENERAL PUBLIC LICENSE\n"
                    b"Version 2.1, February 1999\n"
                    b"truncated\n"
                )
            }
        )

        errors, _ = self.check()

        self.assertTrue(any("SHA-256" in error for error in errors), errors)

    def test_module_license_must_match_shipped_texts(self) -> None:
        self.write_archive({"moon.mod": b'license = "MIT"\n'})

        errors, _ = self.check()

        self.assertTrue(any("LGPL-2.1-only OR MPL-1.1" in error for error in errors), errors)

    def test_module_native_target_contract_is_required(self) -> None:
        self.write_archive(
            {
                "moon.mod": (
                    b'license = "LGPL-2.1-only OR MPL-1.1"\n'
                    b'preferred_target = "native"\n'
                )
            }
        )

        errors, _ = self.check()

        self.assertTrue(any("supported_targets" in error for error in errors), errors)

    def test_missing_changelog_fails(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["CHANGELOG.md"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(any("CHANGELOG.md" in error for error in errors), errors)

    def test_release_version_must_match_changelog(self) -> None:
        self.write_archive(
            {
                "moon.mod": (
                    b'name = "CAIMEOX/cairoon"\n'
                    b'version = "0.2.0"\n'
                    b'license = "LGPL-2.1-only OR MPL-1.1"\n'
                    b'preferred_target = "native"\n'
                    b'supported_targets = "native"\n'
                ),
                "CHANGELOG.md": b"## 0.1.0 - Initial preview\n",
                "README.md": b"moon add CAIMEOX/cairoon@0.2.0\n",
                "src/README.mbt.md": b"moon add CAIMEOX/cairoon@0.2.0\n",
            }
        )

        errors, _ = self.check()

        self.assertTrue(
            any("CHANGELOG.md" in error and "0.2.0" in error for error in errors),
            errors,
        )

    def test_release_version_must_match_install_docs(self) -> None:
        self.write_archive(
            {
                "moon.mod": (
                    b'name = "CAIMEOX/cairoon"\n'
                    b'version = "0.2.0"\n'
                    b'license = "LGPL-2.1-only OR MPL-1.1"\n'
                    b'preferred_target = "native"\n'
                    b'supported_targets = "native"\n'
                ),
                "CHANGELOG.md": b"## 0.2.0 - Unreleased\n",
                "README.md": b"moon add CAIMEOX/cairoon@0.1.0\n",
                "src/README.mbt.md": b"moon add CAIMEOX/cairoon@0.2.0\n",
            }
        )

        errors, _ = self.check()

        self.assertTrue(
            any("README.md" in error and "0.2.0" in error for error in errors),
            errors,
        )

    def test_module_dependency_prebuild_contract_is_required(self) -> None:
        self.write_archive(
            {
                "moon.mod": (
                    b'name = "CAIMEOX/cairoon"\n'
                    b'version = "0.2.0"\n'
                    b'license = "LGPL-2.1-only OR MPL-1.1"\n'
                    b'preferred_target = "native"\n'
                    b'supported_targets = "native"\n'
                ),
                "CHANGELOG.md": b"## 0.2.0 - Unreleased\n",
                "README.md": b"moon add CAIMEOX/cairoon@0.2.0\n",
                "src/README.mbt.md": b"moon add CAIMEOX/cairoon@0.2.0\n",
            }
        )

        errors, _ = self.check()

        self.assertTrue(
            any("--moonbit-unstable-prebuild" in error for error in errors),
            errors,
        )

    def test_missing_prebuild_script_fails(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["scripts/build/cairo_config.py"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(any("scripts/build/cairo_config.py" in error for error in errors), errors)

    def test_missing_publish_dry_run_tooling_fails(self) -> None:
        for member_name in (
            "scripts/check-publish-dry-run.py",
            "scripts/tests/test_publish_dry_run.py",
        ):
            with self.subTest(member_name=member_name):
                members = dict(VALID_MEMBERS)
                del members[member_name]
                self.write_archive(members, include_required=False)

                errors, _ = self.check()

                self.assertTrue(
                    any(member_name in error for error in errors),
                    errors,
                )

    def test_altered_publish_dry_run_tooling_fails(self) -> None:
        for member_name in (
            "scripts/check-publish-dry-run.py",
            "scripts/tests/test_publish_dry_run.py",
        ):
            with self.subTest(member_name=member_name):
                self.write_archive({member_name: b"# altered\n"})

                errors, _ = self.check()

                self.assertTrue(
                    any(
                        member_name in error and "does not match" in error
                        for error in errors
                    ),
                    errors,
                )

    def test_missing_api_snapshot_fails(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["scripts/api/pycairo-api-snapshot.json"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(
            any("scripts/api/pycairo-api-snapshot.json" in error for error in errors),
            errors,
        )

    def test_missing_api_mapping_support_fails(self) -> None:
        for member_name in (
            "scripts/api/attribute_mappings.py",
            "scripts/api/method_mappings.py",
            "scripts/api/protocol_mappings.py",
        ):
            with self.subTest(member_name=member_name):
                members = dict(VALID_MEMBERS)
                del members[member_name]
                self.write_archive(members, include_required=False)

                errors, _ = self.check()

                self.assertTrue(
                    any(member_name in error for error in errors),
                    errors,
                )

    def test_external_owner_support_is_required_and_exact(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["scripts/lifetime/owners.json"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(
            any("scripts/lifetime/owners.json" in error for error in errors),
            errors,
        )

        self.write_archive({"scripts/lifetime/owners.json": b"{}\n"})

        errors, _ = self.check()

        self.assertTrue(
            any("does not match the verified source file" in error for error in errors),
            errors,
        )

        self.write_archive({"scripts/check-external-owners.py": b"# altered\n"})

        errors, _ = self.check()

        self.assertTrue(
            any("does not match the verified source file" in error for error in errors),
            errors,
        )

    def test_ffi_ownership_support_is_required_and_exact(self) -> None:
        for member_name in FFI_OWNERSHIP_SUPPORT:
            with self.subTest(member_name=member_name, mutation="missing"):
                members = dict(VALID_MEMBERS)
                del members[member_name]
                self.write_archive(members, include_required=False)

                errors, _ = self.check()

                self.assertTrue(
                    any(member_name in error for error in errors),
                    errors,
                )

            with self.subTest(member_name=member_name, mutation="altered"):
                self.write_archive({member_name: b"# altered\n"})

                errors, _ = self.check()

                self.assertTrue(
                    any(
                        member_name in error
                        and "does not match the verified source file" in error
                        for error in errors
                    ),
                    errors,
                )

    def test_reliability_support_contract_is_declared(self) -> None:
        self.assertEqual(
            self.checker.RELIABILITY_SUPPORT,
            EXPECTED_RELIABILITY_SUPPORT,
        )
        for member_name in EXPECTED_RELIABILITY_SUPPORT:
            with self.subTest(member_name=member_name, mutation="missing"):
                members = dict(VALID_MEMBERS)
                del members[member_name]
                self.write_archive(members, include_required=False)

                errors, _ = self.check()

                self.assertTrue(any(member_name in error for error in errors), errors)

            with self.subTest(member_name=member_name, mutation="altered"):
                self.write_archive({member_name: b"# altered\n"})

                errors, _ = self.check()

                self.assertTrue(
                    any(
                        member_name in error
                        and "does not match the verified source file" in error
                        for error in errors
                    ),
                    errors,
                )

    def test_sanitizer_support_contract_is_declared(self) -> None:
        self.assertEqual(
            self.checker.SANITIZER_SUPPORT,
            EXPECTED_SANITIZER_SUPPORT,
        )
        for member_name in EXPECTED_SANITIZER_SUPPORT:
            with self.subTest(member_name=member_name, mutation="missing"):
                members = dict(VALID_MEMBERS)
                del members[member_name]
                self.write_archive(members, include_required=False)

                errors, _ = self.check()

                self.assertTrue(any(member_name in error for error in errors), errors)

            with self.subTest(member_name=member_name, mutation="altered"):
                self.write_archive({member_name: b"# altered\n"})

                errors, _ = self.check()

                self.assertTrue(
                    any(
                        member_name in error
                        and "does not match the verified source file" in error
                        for error in errors
                    ),
                    errors,
                )

    def test_duplicate_canonical_member_fails(self) -> None:
        self.write_archive({})
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            with zipfile.ZipFile(self.archive, "a", zipfile.ZIP_STORED) as archive:
                archive.writestr("./COPYING", VALID_MEMBERS["COPYING"])

        errors, _ = self.check()

        self.assertTrue(any("duplicate archive member" in error for error in errors), errors)

    def test_integration_fixture_fails(self) -> None:
        self.write_archive({"moon.mod": b"", "integration/consumer/moon.mod": b""})

        errors, _ = self.check()

        self.assertTrue(any("integration fixture" in error for error in errors), errors)

    def test_unsafe_parent_member_fails(self) -> None:
        self.write_archive({"moon.mod": b"", "../outside": b"bad"})

        errors, _ = self.check()

        self.assertTrue(any("unsafe archive member" in error for error in errors), errors)

    def test_empty_archive_fails(self) -> None:
        self.write_archive({}, include_required=False)

        errors, member_count = self.check()

        self.assertTrue(any("archive is empty" in error for error in errors), errors)
        self.assertEqual(member_count, 0)

    def test_crc_corruption_fails(self) -> None:
        self.write_archive({"src/a.mbt": b"uncorrupted payload"})
        with zipfile.ZipFile(self.archive) as archive:
            member = archive.getinfo("src/a.mbt")
        payload_offset = (
            member.header_offset
            + 30
            + len(member.filename.encode("utf-8"))
            + len(member.extra)
        )
        data = bytearray(self.archive.read_bytes())
        data[payload_offset] ^= 0xFF
        self.archive.write_bytes(data)

        errors, _ = self.check()

        self.assertTrue(errors)
        self.assertIn("CRC", " ".join(errors))


if __name__ == "__main__":
    unittest.main()
