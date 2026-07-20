"""Shared fixtures for publication archive validator tests."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
import zipfile


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-publication-archive.py"
REPO_ROOT = CHECKER.parents[1]
FFI_OWNERSHIP_SUPPORT = frozenset(
    {
        "scripts/check-ffi-ownership.py",
        "scripts/ffi_ownership/__init__.py",
        "scripts/ffi_ownership/borrowed_returns.py",
        "scripts/ffi_ownership/device_cleanup.py",
        "scripts/ffi_ownership/mapped_cleanup.py",
        "scripts/ffi_ownership/source.py",
        "scripts/ffi_ownership/surface_cleanup.py",
    }
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
EXPECTED_DOCUMENTATION_SUPPORT = (
    frozenset(
        {
            "API_INVENTORY.md",
            "AUDIT.md",
            "TESTING.md",
            "docs/api-audit/README.md",
            "docs/audit/README.md",
            "docs/testing/README.md",
            "scripts/check-source-size-budget.py",
            "scripts/tests/test_source_size_budget.py",
        }
    )
    | frozenset(f"docs/api-audit/history-{index:02d}.md" for index in range(1, 3))
    | frozenset(f"docs/audit/history-{index:02d}.md" for index in range(1, 9))
    | frozenset(f"docs/testing/history-{index:02d}.md" for index in range(1, 10))
)
VALID_MEMBER_NAMES = frozenset(
    {
        "COPYING",
        "COPYING-LGPL-2.1",
        "COPYING-MPL-1.1",
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
        "src/matrix.mbt",
        "src/moon.pkg",
        "src/native/cairoon_objects.c",
        "src/pkg.generated.mbti",
    }
) | FFI_OWNERSHIP_SUPPORT | EXPECTED_RELIABILITY_SUPPORT | EXPECTED_SANITIZER_SUPPORT | EXPECTED_DOCUMENTATION_SUPPORT
VALID_MEMBERS = {
    member_name: (REPO_ROOT / member_name).read_bytes()
    for member_name in VALID_MEMBER_NAMES
}


def load_checker():
    spec = importlib.util.spec_from_file_location("check_publication_archive", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PublicationArchiveTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.archive = self.root / "publication.zip"
        self.source_root = self.root / "checkout"
        for name, data in VALID_MEMBERS.items():
            source = self.source_root / name
            source.parent.mkdir(parents=True, exist_ok=True)
            source.write_bytes(data)

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
        return self.checker.check_archive(self.archive, self.source_root)
