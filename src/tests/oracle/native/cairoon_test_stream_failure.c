#include "cairoon_test_private.h"

#if CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>
#endif
#if CAIRO_HAS_PS_SURFACE
#include <cairo-ps.h>
#endif
#if CAIRO_HAS_SCRIPT_SURFACE
#include <cairo-script.h>
#endif
#if CAIRO_HAS_SVG_SURFACE
#include <cairo-svg.h>
#endif

static cairo_surface_t *cairoon_test_stream_surface_create(
  int32_t kind,
  void *state,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  switch (kind) {
    case 0:
#if CAIRO_HAS_PDF_SURFACE
      return cairo_pdf_surface_create_for_stream(
        cairoon_stream_write,
        state,
        4.0,
        4.0);
#else
      *status_out = CAIRO_STATUS_INVALID_STATUS;
      return NULL;
#endif
    case 1:
#if CAIRO_HAS_PS_SURFACE
      return cairo_ps_surface_create_for_stream(
        cairoon_stream_write,
        state,
        4.0,
        4.0);
#else
      *status_out = CAIRO_STATUS_INVALID_STATUS;
      return NULL;
#endif
    case 2:
#if CAIRO_HAS_SVG_SURFACE
      return cairo_svg_surface_create_for_stream(
        cairoon_stream_write,
        state,
        4.0,
        4.0);
#else
      *status_out = CAIRO_STATUS_INVALID_STATUS;
      return NULL;
#endif
    default:
      *status_out = CAIRO_STATUS_INVALID_STATUS;
      return NULL;
  }
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_stream_surface_attach_failure(
  int32_t kind,
  CairoonStreamWriteCallback callback,
  void *arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (state == NULL) {
    return status;
  }

  cairo_surface_t *surface =
    cairoon_test_stream_surface_create(kind, state, &status);
  if (surface == NULL) {
    cairoon_stream_state_destroy(state);
    return status;
  }
  status = cairo_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    cairoon_stream_state_destroy(state);
    return status;
  }

  status = cairoon_stream_write(state, NULL, 0);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    cairoon_stream_state_destroy(state);
    return status;
  }
  cairoon_stream_surface_cleanup_failure(surface, state);
  return CAIRO_STATUS_NO_MEMORY;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_stream_device_attach_failure(
  CairoonStreamWriteCallback callback,
  void *arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (state == NULL) {
    return status;
  }

#if CAIRO_HAS_SCRIPT_SURFACE
  cairo_device_t *device =
    cairo_script_create_for_stream(cairoon_stream_write, state);
  if (device == NULL) {
    cairoon_stream_state_destroy(state);
    return CAIRO_STATUS_NO_MEMORY;
  }
  status = cairo_device_status(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_device_destroy(device);
    cairoon_stream_state_destroy(state);
    return status;
  }

  status = cairoon_stream_write(state, NULL, 0);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_device_destroy(device);
    cairoon_stream_state_destroy(state);
    return status;
  }
  cairoon_stream_device_cleanup_failure(device, state);
  return CAIRO_STATUS_NO_MEMORY;
#else
  cairoon_stream_state_destroy(state);
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
