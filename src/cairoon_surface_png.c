#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_write_to_png(
  CairoonSurface *surface,
  moonbit_bytes_t filename) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (filename == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
#if CAIRO_HAS_PNG_FUNCTIONS
  return cairo_surface_write_to_png(surface->ptr, (const char *)filename);
#else
  return CAIRO_STATUS_PNG_ERROR;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_write_to_png_stream(
  CairoonSurface *surface,
  CairoonStreamWriteCallback callback,
  void *arg) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    if (arg != NULL) {
      moonbit_decref(arg);
    }
    return status;
  }
#if CAIRO_HAS_PNG_FUNCTIONS
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairo_surface_write_to_png_stream(
    surface->ptr,
    cairoon_stream_write,
    state);
  cairoon_stream_state_destroy(state);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_surface_status(surface->ptr);
#else
  (void)callback;
  if (arg != NULL) {
    moonbit_decref(arg);
  }
  return CAIRO_STATUS_PNG_ERROR;
#endif
}
