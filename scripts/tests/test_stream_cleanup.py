#!/usr/bin/env python3
"""Tests for native stream constructor cleanup-order guards."""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest


CHECKER = pathlib.Path(__file__).resolve().parents[1] / "check-stream-cleanup.py"


def load_checker():
    spec = importlib.util.spec_from_file_location("check_stream_cleanup", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


SURFACE_TEMPLATE = """
CairoonSurface *FUNCTION(void) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  void *state = cairoon_stream_state_new(callback, arg, &status);
  cairo_surface_t *surface = create(cairoon_stream_write, state);
  if (surface == NULL) {
    cairoon_stream_state_destroy(state);
    return cairoon_surface_wrap_owned(NULL);
  }
  status = cairo_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    cairoon_stream_state_destroy(state);
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }
  status = cairoon_stream_attach(surface, state);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    cairoon_stream_state_destroy(state);
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }
  return cairoon_surface_wrap_owned(surface);
}
"""

STREAM_TEMPLATE = """
cairo_status_t cairoon_stream_attach(cairo_surface_t *surface, void *state) {
  if (surface == NULL) return CAIRO_STATUS_NULL_POINTER;
  return cairo_surface_set_user_data(
    surface, &cairoon_stream_state_key, state, cairoon_stream_state_destroy);
}
cairo_status_t cairoon_stream_attach_device(cairo_device_t *device, void *state) {
  if (device == NULL) return CAIRO_STATUS_NULL_POINTER;
  return cairo_device_set_user_data(
    device, &cairoon_stream_state_key, state, cairoon_stream_state_destroy);
}
"""

DEVICE_TEMPLATE = """
CairoonDevice *cairoon_script_device_create_for_stream(void) {
  void *state = cairoon_stream_state_new(callback, arg, status_out);
  cairo_device_t *device = create(cairoon_stream_write, state);
  if (device == NULL) {
    cairoon_stream_state_destroy(state);
    return cairoon_device_wrap_owned(NULL);
  }
  *status_out = cairo_device_status(device);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    cairo_device_destroy(device);
    cairoon_stream_state_destroy(state);
    return cairoon_device_wrap_owned(NULL);
  }
  *status_out = cairoon_stream_attach_device(device, state);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    cairo_device_destroy(device);
    cairoon_stream_state_destroy(state);
    return cairoon_device_wrap_owned(NULL);
  }
  return cairoon_device_wrap_owned(device);
}
"""


class StreamCleanupGuardTests(unittest.TestCase):
    def setUp(self) -> None:
        self.checker = load_checker()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.native_root = pathlib.Path(self.temp_dir.name)
        (self.native_root / "cairoon_stream.c").write_text(
            STREAM_TEMPLATE, encoding="utf-8"
        )
        for filename, function_name in self.checker.SURFACE_CONSTRUCTORS:
            (self.native_root / filename).write_text(
                SURFACE_TEMPLATE.replace("FUNCTION", function_name),
                encoding="utf-8",
            )
        (self.native_root / "cairoon_device.c").write_text(
            DEVICE_TEMPLATE, encoding="utf-8"
        )

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def check(self) -> list[str]:
        return self.checker.check_stream_cleanup(self.native_root)

    def test_valid_cleanup_order_passes(self) -> None:
        self.assertEqual(self.check(), [])

    def test_attach_helper_must_not_consume_state_on_failure(self) -> None:
        path = self.native_root / "cairoon_stream.c"
        source = path.read_text(encoding="utf-8").replace(
            "if (surface == NULL) return CAIRO_STATUS_NULL_POINTER;",
            "if (surface == NULL) {\n"
            "  cairoon_stream_state_destroy(state);\n"
            "  return CAIRO_STATUS_NULL_POINTER;\n"
            "}",
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("owned by its caller" in error for error in errors), errors)

    def test_attach_helper_must_call_cairo_user_data_setter(self) -> None:
        path = self.native_root / "cairoon_stream.c"
        source = path.read_text(encoding="utf-8").replace(
            "return cairo_surface_set_user_data(\n"
            "    surface, &cairoon_stream_state_key, state, "
            "cairoon_stream_state_destroy);",
            "return CAIRO_STATUS_SUCCESS;",
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("transfer state" in error for error in errors), errors)

    def test_attach_helper_requires_stream_state_destroyer(self) -> None:
        path = self.native_root / "cairoon_stream.c"
        source = path.read_text(encoding="utf-8").replace(
            "return cairo_device_set_user_data(\n"
            "    device, &cairoon_stream_state_key, state, "
            "cairoon_stream_state_destroy);",
            "return cairo_device_set_user_data(\n"
            "    device, &cairoon_stream_state_key, state, wrong_destroy);",
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("transfer state" in error for error in errors), errors)

    def test_surface_attach_failure_rejects_reversed_cleanup(self) -> None:
        path = self.native_root / "cairoon_svg_surface.c"
        source = path.read_text(encoding="utf-8").replace(
            "cairo_surface_destroy(surface);\n    cairoon_stream_state_destroy(state);",
            "cairoon_stream_state_destroy(state);\n    cairo_surface_destroy(surface);",
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("native producer" in error for error in errors), errors)

    def test_surface_constructor_requires_pre_attach_status_cleanup(self) -> None:
        path = self.native_root / "cairoon_pdf_surface.c"
        source = path.read_text(encoding="utf-8").replace(
            "status = cairo_surface_status(surface);",
            "status = CAIRO_STATUS_SUCCESS;",
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("native-status failure" in error for error in errors), errors)

    def test_surface_status_failure_must_immediately_follow_status_read(self) -> None:
        path = self.native_root / "cairoon_ps_surface.c"
        source = path.read_text(encoding="utf-8").replace(
            "  if (status != CAIRO_STATUS_SUCCESS) {\n"
            "    cairo_surface_destroy(surface);\n"
            "    cairoon_stream_state_destroy(state);\n"
            "    *status_out = status;\n"
            "    return cairoon_surface_wrap_owned(NULL);\n"
            "  }\n"
            "  status = cairoon_stream_attach(surface, state);",
            "  status = cairoon_stream_attach(surface, state);",
            1,
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("native-status failure" in error for error in errors), errors)

    def test_device_status_failure_rejects_reversed_cleanup(self) -> None:
        path = self.native_root / "cairoon_device.c"
        source = path.read_text(encoding="utf-8").replace(
            "cairo_device_destroy(device);\n    cairoon_stream_state_destroy(state);",
            "cairoon_stream_state_destroy(state);\n    cairo_device_destroy(device);",
            1,
        )
        path.write_text(source, encoding="utf-8")

        errors = self.check()

        self.assertTrue(any("native producer" in error for error in errors), errors)


if __name__ == "__main__":
    unittest.main()
