#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_flush(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_flush(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_mark_dirty(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_mark_dirty(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_mark_dirty_rectangle(
  CairoonSurface *surface,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_mark_dirty_rectangle(surface->ptr, x, y, width, height);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_device_offset(
  CairoonSurface *surface,
  double x_offset,
  double y_offset) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_set_device_offset(surface->ptr, x_offset, y_offset);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_get_device_offset(
  CairoonSurface *surface,
  double *x_offset,
  double *y_offset) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_get_device_offset(surface->ptr, x_offset, y_offset);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_device_scale(
  CairoonSurface *surface,
  double x_scale,
  double y_scale) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t transform;
  cairo_matrix_init_scale(&transform, x_scale, y_scale);
  status = cairo_matrix_invert(&transform);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_set_device_scale(surface->ptr, x_scale, y_scale);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_get_device_scale(
  CairoonSurface *surface,
  double *x_scale,
  double *y_scale) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_get_device_scale(surface->ptr, x_scale, y_scale);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_fallback_resolution(
  CairoonSurface *surface,
  double x_pixels_per_inch,
  double y_pixels_per_inch) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_set_fallback_resolution(
    surface->ptr,
    x_pixels_per_inch,
    y_pixels_per_inch);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_get_fallback_resolution(
  CairoonSurface *surface,
  double *x_pixels_per_inch,
  double *y_pixels_per_inch) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_get_fallback_resolution(
    surface->ptr,
    x_pixels_per_inch,
    y_pixels_per_inch);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_surface_has_show_text_glyphs(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_surface_has_show_text_glyphs(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_copy_page(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_copy_page(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_show_page(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_show_page(surface->ptr);
  return cairo_surface_status(surface->ptr);
}
