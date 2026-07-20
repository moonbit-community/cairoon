#!/usr/bin/env python3
"""Tests for the publication archive validator."""

from __future__ import annotations

import unittest
import warnings
import zipfile

if __package__:
    from . import publication_archive_support as support
else:
    import publication_archive_support as support


FFI_OWNERSHIP_SUPPORT = support.FFI_OWNERSHIP_SUPPORT
EXPECTED_RELIABILITY_SUPPORT = support.EXPECTED_RELIABILITY_SUPPORT
EXPECTED_SANITIZER_SUPPORT = support.EXPECTED_SANITIZER_SUPPORT
EXPECTED_DOCUMENTATION_SUPPORT = support.EXPECTED_DOCUMENTATION_SUPPORT
VALID_MEMBERS = support.VALID_MEMBERS


class PublicationArchiveCheckerTests(support.PublicationArchiveTestCase):

    def test_valid_archive_passes(self) -> None:
        for relative in (
            ".github/workflows/ci.yml",
            ".mooncakes/cache/entry",
            "_build/native/object.o",
            "integration/consumer/moon.mod",
            "scripts/__pycache__/checker.pyc",
        ):
            ignored = self.source_root / relative
            ignored.parent.mkdir(parents=True, exist_ok=True)
            ignored.write_bytes(b"not publishable\n")
        self.write_archive({})

        errors, member_count = self.check()

        self.assertEqual(errors, [])
        self.assertEqual(member_count, len(VALID_MEMBERS))

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

    def test_product_source_set_and_payload_must_match(self) -> None:
        with self.subTest(mutation="altered MoonBit source"):
            self.write_archive({"src/matrix.mbt": b"// altered product source\n"})
            errors, _ = self.check()
            self.assertTrue(
                any(
                    "src/matrix.mbt" in error
                    and "does not match the verified source file" in error
                    for error in errors
                ),
                errors,
            )

        with self.subTest(mutation="missing C source"):
            members = dict(VALID_MEMBERS)
            del members["src/native/cairoon_objects.c"]
            self.write_archive(members, include_required=False)
            errors, _ = self.check()
            self.assertTrue(
                any(
                    "src/native/cairoon_objects.c" in error
                    and "missing verified source member" in error
                    for error in errors
                ),
                errors,
            )

        with self.subTest(mutation="missing archive validator support"):
            members = dict(VALID_MEMBERS)
            del members["scripts/tests/publication_archive_support.py"]
            self.write_archive(members, include_required=False)
            errors, _ = self.check()
            self.assertTrue(
                any(
                    "scripts/tests/publication_archive_support.py" in error
                    and "missing required publication member" in error
                    for error in errors
                ),
                errors,
            )

        with self.subTest(mutation="unverified extra source"):
            self.write_archive({"src/not-in-checkout.mbt": b"test only\n"})
            errors, _ = self.check()
            self.assertTrue(
                any(
                    "src/not-in-checkout.mbt" in error
                    and "has no verified source file" in error
                    for error in errors
                ),
                errors,
            )

        with self.subTest(mutation="unverified extra directory"):
            self.write_archive({"src/not-in-checkout/": b""})
            errors, _ = self.check()
            self.assertTrue(
                any(
                    "src/not-in-checkout" in error
                    and "has no verified source file" in error
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

    def test_reliability_and_documentation_support_is_required(self) -> None:
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

        self.assertEqual(
            self.checker.DOCUMENTATION_SUPPORT,
            EXPECTED_DOCUMENTATION_SUPPORT,
        )
        for member_name in EXPECTED_DOCUMENTATION_SUPPORT:
            with self.subTest(member_name=member_name, mutation="missing documentation"):
                members = dict(VALID_MEMBERS)
                del members[member_name]
                self.write_archive(members, include_required=False)

                errors, _ = self.check()

                self.assertTrue(
                    any(
                        member_name in error
                        and "missing required publication member" in error
                        for error in errors
                    ),
                    errors,
                )

            with self.subTest(member_name=member_name, mutation="altered documentation"):
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
