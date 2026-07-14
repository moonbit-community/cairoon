#!/usr/bin/env python3
"""Tests for vector backend scene and tag-coverage wiring checks."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-vector-backend-scenes.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_vector_backend_scenes", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class VectorBackendSceneCheckerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.c_source = self.root / "tag_attributes.c"
        self.moonbit_source = self.root / "tag_attributes.mbt"
        self.stream_oracle = self.root / "stream_oracle.mbt"

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def write_complete_sources(self) -> None:
        c_anchors = [
            pair[0] for pair in self.checker.TAG_ATTRIBUTE_REQUIREMENTS.values()
        ]
        moonbit_anchors = [
            pair[1] for pair in self.checker.TAG_ATTRIBUTE_REQUIREMENTS.values()
        ]
        moonbit_anchors.extend(
            f'test "{name}"' for name in self.checker.TAG_ATTRIBUTE_RUNTIME_TESTS
        )
        self.c_source.write_text("\n".join(c_anchors), encoding="utf-8")
        self.moonbit_source.write_text("\n".join(moonbit_anchors), encoding="utf-8")

    def check_coverage(self) -> list[str]:
        with (
            mock.patch.object(self.checker, "TAG_ATTRIBUTE_C", self.c_source),
            mock.patch.object(
                self.checker,
                "TAG_ATTRIBUTE_MOONBIT",
                self.moonbit_source,
            ),
        ):
            return self.checker.check_tag_attribute_coverage()

    def test_complete_tag_attribute_matrix_passes(self) -> None:
        self.write_complete_sources()

        self.assertEqual(self.check_coverage(), [])

    def test_missing_direct_c_tag_attribute_fails(self) -> None:
        self.write_complete_sources()
        missing_feature = "content reference"
        missing_anchor = self.checker.TAG_ATTRIBUTE_REQUIREMENTS[missing_feature][0]
        self.c_source.write_text(
            self.c_source.read_text(encoding="utf-8").replace(missing_anchor, ""),
            encoding="utf-8",
        )

        errors = self.check_coverage()

        self.assertTrue(any(missing_feature in error for error in errors), errors)

    def test_missing_runtime_test_fails(self) -> None:
        self.write_complete_sources()
        missing_test = self.checker.TAG_ATTRIBUTE_RUNTIME_TESTS[0]
        self.moonbit_source.write_text(
            self.moonbit_source.read_text(encoding="utf-8").replace(
                f'test "{missing_test}"',
                "",
            ),
            encoding="utf-8",
        )

        errors = self.check_coverage()

        self.assertTrue(any(missing_test in error for error in errors), errors)

    def check_stream_scene_list(
        self,
        source: str,
        scenes: list[tuple[str, int]],
    ) -> list[str]:
        self.stream_oracle.write_text(source, encoding="utf-8")
        with mock.patch.object(
            self.checker,
            "STREAM_ORACLE",
            self.stream_oracle,
        ):
            return self.checker.check_stream_scene_list(scenes)

    def test_named_scene_list_with_conditional_push_passes(self) -> None:
        source = """
let scenes = [35]
if cairo_version >= 11800 {
  scenes.push(66)
}
for scene in scenes {
  ignore(scene)
}
"""

        errors = self.check_stream_scene_list(
            source,
            [("BASE", 35), ("CAIRO_1_18", 66)],
        )

        self.assertEqual(errors, [])

    def test_named_scene_list_missing_conditional_scene_fails(self) -> None:
        source = """
let scenes = [35]
for scene in scenes {
  ignore(scene)
}
"""

        errors = self.check_stream_scene_list(
            source,
            [("BASE", 35), ("CAIRO_1_18", 66)],
        )

        self.assertTrue(any("66" in error for error in errors), errors)


if __name__ == "__main__":
    unittest.main()
