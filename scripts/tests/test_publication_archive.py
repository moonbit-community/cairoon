#!/usr/bin/env python3
"""Tests for the publication archive validator."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
import zipfile


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-publication-archive.py"


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

    def write_archive(self, members: dict[str, bytes]) -> None:
        with zipfile.ZipFile(self.archive, "w", zipfile.ZIP_STORED) as archive:
            for name, data in members.items():
                archive.writestr(name, data)

    def check(self) -> tuple[list[str], int]:
        return self.checker.check_archive(self.archive)

    def test_valid_archive_passes(self) -> None:
        self.write_archive({"moon.mod": b'name = "example/module"\n', "src/a.mbt": b""})

        errors, member_count = self.check()

        self.assertEqual(errors, [])
        self.assertEqual(member_count, 2)

    def test_integration_fixture_fails(self) -> None:
        self.write_archive({"moon.mod": b"", "integration/consumer/moon.mod": b""})

        errors, _ = self.check()

        self.assertTrue(any("integration fixture" in error for error in errors), errors)

    def test_unsafe_parent_member_fails(self) -> None:
        self.write_archive({"moon.mod": b"", "../outside": b"bad"})

        errors, _ = self.check()

        self.assertTrue(any("unsafe archive member" in error for error in errors), errors)

    def test_empty_archive_fails(self) -> None:
        self.write_archive({})

        errors, member_count = self.check()

        self.assertTrue(any("archive is empty" in error for error in errors), errors)
        self.assertEqual(member_count, 0)

    def test_crc_corruption_fails(self) -> None:
        self.write_archive({"moon.mod": b"uncorrupted payload"})
        with zipfile.ZipFile(self.archive) as archive:
            member = archive.getinfo("moon.mod")
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
