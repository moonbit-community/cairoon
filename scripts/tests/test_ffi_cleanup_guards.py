#!/usr/bin/env python3
"""Tests for executable Surface cleanup-order guards."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-ffi-ownership.py"

VALID_NATIVE_BODY = """
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t original_status = cairo_surface_status(surface->ptr);
  cairo_status_t marker_status = CAIRO_STATUS_SUCCESS;
  if (!cairoon_surface_is_finished(surface->ptr)) {
    marker_status = cairo_surface_set_user_data(
      surface->ptr,
      &cairoon_surface_finished_key,
      (void *)&cairoon_surface_finished_sentinel,
      NULL);
  }
  cairo_surface_finish(surface->ptr);
  cairo_status_t finish_status = cairo_surface_status(surface->ptr);
  cairo_status_t data_status = cairoon_image_surface_release_data(surface->ptr);
  if (original_status != CAIRO_STATUS_SUCCESS) {
    return original_status;
  }
  if (marker_status != CAIRO_STATUS_SUCCESS) {
    return marker_status;
  }
  return finish_status == CAIRO_STATUS_SUCCESS ? data_status : finish_status;
"""


def load_checker():
    spec = importlib.util.spec_from_file_location("check_ffi_ownership", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SurfaceCleanupGuardTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temp_dir.name)
        self.package_root = self.root / "src"
        self.native_root = self.package_root / "native"
        self.native_root.mkdir(parents=True)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check_native(self, body: str) -> list[str]:
        source = (
            "cairo_status_t cairoon_surface_finish(CairoonSurface *surface) {\n"
            f"{body}\n"
            "}\n"
        )
        (self.native_root / "cairoon_surface.c").write_text(
            source, encoding="utf-8"
        )
        with mock.patch.object(self.checker, "NATIVE_ROOT", self.native_root):
            return self.checker.check_surface_cleanup_order()

    def check_scope(self, body: str) -> list[str]:
        source = (
            "pub fn[T] Surface::with_finished("
            "self : Surface, f : () -> T raise CairoError"
            ") -> T raise CairoError {\n"
            f"{body}\n"
            "}\n"
        )
        (self.package_root / "surface.mbt").write_text(source, encoding="utf-8")
        with mock.patch.object(self.checker, "PACKAGE_ROOT", self.package_root):
            return self.checker.check_surface_scope_cleanup()

    def test_native_cleanup_order_passes(self) -> None:
        errors = self.check_native(VALID_NATIVE_BODY)

        self.assertEqual(errors, [])

    def test_native_cleanup_rejects_an_early_return(self) -> None:
        errors = self.check_native(
            """
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  if (cairo_surface_status(surface->ptr) != CAIRO_STATUS_SUCCESS) {
    return cairo_surface_status(surface->ptr);
  }
  cairo_surface_finish(surface->ptr);
  return cairoon_image_surface_release_data(surface->ptr);
"""
        )

        self.assertTrue(any("may only return" in error for error in errors), errors)

    def test_native_cleanup_rejects_conditional_or_reordered_cleanup(self) -> None:
        cases = {
            "missing release": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_status_t data_status = "
                    "cairoon_image_surface_release_data(surface->ptr);\n",
                    "  cairo_status_t data_status = CAIRO_STATUS_SUCCESS;\n",
                ),
                "retained image data",
            ),
            "return between cleanup calls": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_status_t finish_status = "
                    "cairo_surface_status(surface->ptr);\n",
                    "  cairo_status_t finish_status = "
                    "cairo_surface_status(surface->ptr);\n"
                    "  return finish_status;\n",
                ),
                "must not return before",
            ),
            "goto skips finish": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_surface_finish(surface->ptr);\n",
                    "  if (original_status != CAIRO_STATUS_SUCCESS) "
                    "goto after_finish;\n"
                    "  cairo_surface_finish(surface->ptr);\n"
                    "after_finish:\n",
                ),
                "control transfer",
            ),
            "missing finished marker": (
                VALID_NATIVE_BODY.replace(
                    "  if (!cairoon_surface_is_finished(surface->ptr)) {\n"
                    "    marker_status = cairo_surface_set_user_data(\n"
                    "      surface->ptr,\n"
                    "      &cairoon_surface_finished_key,\n"
                    "      (void *)&cairoon_surface_finished_sentinel,\n"
                    "      NULL);\n"
                    "  }\n",
                    "",
                ),
                "finished marker",
            ),
            "conditional finish": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_surface_finish(surface->ptr);\n",
                    "  if (original_status == CAIRO_STATUS_SUCCESS)\n"
                    "    cairo_surface_finish(surface->ptr);\n",
                ),
                "unconditionally",
            ),
            "release before finish": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_surface_finish(surface->ptr);\n"
                    "  cairo_status_t finish_status = "
                    "cairo_surface_status(surface->ptr);\n"
                    "  cairo_status_t data_status = "
                    "cairoon_image_surface_release_data(surface->ptr);\n",
                    "  cairo_status_t data_status = "
                    "cairoon_image_surface_release_data(surface->ptr);\n"
                    "  cairo_surface_finish(surface->ptr);\n"
                    "  cairo_status_t finish_status = "
                    "cairo_surface_status(surface->ptr);\n",
                ),
                "cleanup in order",
            ),
            "finish status captured too early": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_surface_finish(surface->ptr);\n"
                    "  cairo_status_t finish_status = "
                    "cairo_surface_status(surface->ptr);\n",
                    "  cairo_status_t finish_status = "
                    "cairo_surface_status(surface->ptr);\n"
                    "  cairo_surface_finish(surface->ptr);\n",
                ),
                "cleanup in order",
            ),
            "conditional release": (
                VALID_NATIVE_BODY.replace(
                    "  cairo_status_t data_status = "
                    "cairoon_image_surface_release_data(surface->ptr);\n",
                    "  if (finish_status == CAIRO_STATUS_SUCCESS)\n"
                    "    cairoon_image_surface_release_data(surface->ptr);\n"
                    "  cairo_status_t data_status = CAIRO_STATUS_SUCCESS;\n",
                ),
                "unconditionally",
            ),
            "reversed status precedence": (
                VALID_NATIVE_BODY.replace(
                    "  if (original_status != CAIRO_STATUS_SUCCESS) {\n"
                    "    return original_status;\n"
                    "  }\n"
                    "  if (marker_status != CAIRO_STATUS_SUCCESS) {\n"
                    "    return marker_status;\n"
                    "  }\n",
                    "  if (marker_status != CAIRO_STATUS_SUCCESS) {\n"
                    "    return marker_status;\n"
                    "  }\n"
                    "  if (original_status != CAIRO_STATUS_SUCCESS) {\n"
                    "    return original_status;\n"
                    "  }\n",
                ),
                "status precedence",
            ),
        }
        for name, (body, expected) in cases.items():
            with self.subTest(name=name):
                errors = self.check_native(body)
                self.assertTrue(any(expected in error for error in errors), errors)

    def test_scoped_cleanup_order_passes(self) -> None:
        errors = self.check_scope(
            """
  try f() catch {
    err => {
      let _ = @surface_impl.finish_raw(self.to_raw())
      raise err
    }
  } noraise {
    value => {
      self.finish()
      value
    }
  }
"""
        )

        self.assertEqual(errors, [])

    def test_scoped_cleanup_rejects_checked_error_cleanup(self) -> None:
        errors = self.check_scope(
            """
  try f() catch {
    err => {
      self.finish()
      raise err
    }
  } noraise {
    value => {
      self.finish()
      value
    }
  }
"""
        )

        self.assertTrue(any("checked finish" in error for error in errors), errors)

    def test_scoped_cleanup_rejects_wrong_order_or_unchecked_success(self) -> None:
        cases = {
            "cleanup after raise": (
                """
  try f() catch {
    err => {
      raise err
      let _ = @surface_impl.finish_raw(self.to_raw())
    }
  } noraise {
    value => {
      self.finish()
      value
    }
  }
""",
                "before re-raising",
            ),
            "unchecked success": (
                """
  try f() catch {
    err => {
      let _ = @surface_impl.finish_raw(self.to_raw())
      raise err
    }
  } noraise {
    value => {
      value
    }
  }
""",
                "checked finish",
            ),
            "conditional error cleanup": (
                """
  try f() catch {
    err => {
      if false {
        let _ = @surface_impl.finish_raw(self.to_raw())
      }
      raise err
    }
  } noraise {
    value => {
      self.finish()
      value
    }
  }
""",
                "unconditionally",
            ),
        }
        for name, (body, expected) in cases.items():
            with self.subTest(name=name):
                errors = self.check_scope(body)
                self.assertTrue(any(expected in error for error in errors), errors)


class CleanupModuleBoundaryTests(unittest.TestCase):
    def test_cli_wrappers_delegate_with_the_owning_source_root(self) -> None:
        checker = load_checker()
        cases = (
            ("check_device_cleanup_order", "_check_device_cleanup_order", "NATIVE_ROOT"),
            ("check_device_scope_cleanup", "_check_device_scope_cleanup", "PACKAGE_ROOT"),
            ("check_surface_cleanup_order", "_check_surface_cleanup_order", "NATIVE_ROOT"),
            ("check_surface_scope_cleanup", "_check_surface_scope_cleanup", "PACKAGE_ROOT"),
            (
                "check_mapped_image_cleanup_order",
                "_check_mapped_image_cleanup_order",
                "NATIVE_ROOT",
            ),
            (
                "check_mapped_image_scope_cleanup",
                "_check_mapped_image_scope_cleanup",
                "PACKAGE_ROOT",
            ),
        )
        for wrapper_name, delegate_name, root_name in cases:
            with self.subTest(wrapper=wrapper_name):
                sentinel = [wrapper_name]
                with mock.patch.object(
                    checker,
                    delegate_name,
                    return_value=sentinel,
                ) as delegate:
                    wrapper = getattr(checker, wrapper_name)
                    self.assertIs(wrapper(), sentinel)
                    delegate.assert_called_once_with(getattr(checker, root_name))


if __name__ == "__main__":
    unittest.main()
