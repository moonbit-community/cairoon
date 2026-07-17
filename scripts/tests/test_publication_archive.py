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
VALID_MEMBERS = {
    "COPYING": (REPO_ROOT / "COPYING").read_bytes(),
    "COPYING-LGPL-2.1": (REPO_ROOT / "COPYING-LGPL-2.1").read_bytes(),
    "COPYING-MPL-1.1": (REPO_ROOT / "COPYING-MPL-1.1").read_bytes(),
    "README.md": b"# example\n",
    "moon.mod": (
        b'license = "LGPL-2.1-only OR MPL-1.1"\n'
        b'preferred_target = "native"\n'
        b'supported_targets = "native"\n'
    ),
    "scripts/api/pycairo-api-snapshot.json": (
        REPO_ROOT / "scripts" / "api" / "pycairo-api-snapshot.json"
    ).read_bytes(),
    "scripts/build/cairo_config.py": b"# build config\n",
    "src/README.mbt.md": b"# example\n",
    "src/moon.pkg": b"",
    "src/pkg.generated.mbti": b"package example\n",
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

    def test_missing_prebuild_script_fails(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["scripts/build/cairo_config.py"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(any("scripts/build/cairo_config.py" in error for error in errors), errors)

    def test_missing_api_snapshot_fails(self) -> None:
        members = dict(VALID_MEMBERS)
        del members["scripts/api/pycairo-api-snapshot.json"]
        self.write_archive(members, include_required=False)

        errors, _ = self.check()

        self.assertTrue(
            any("scripts/api/pycairo-api-snapshot.json" in error for error in errors),
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
