#include "cairoon_private.h"

static cairo_status_t cairoon_recording_surface_require_type_allow_finished(
  CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_RECORDING) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_recording_surface_create(
  cairo_content_t content,
  int32_t has_extents,
  double x,
  double y,
  double width,
  double height,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#ifdef CAIRO_HAS_RECORDING_SURFACE
  cairo_rectangle_t extents = {x, y, width, height};
  cairo_surface_t *surface = cairo_recording_surface_create(
    content,
    has_extents ? &extents : NULL);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)content;
  (void)has_extents;
  (void)x;
  (void)y;
  (void)width;
  (void)height;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_recording_surface_ink_extents(
  CairoonSurface *surface,
  double *x0,
  double *y0,
  double *width,
  double *height) {
#ifdef CAIRO_HAS_RECORDING_SURFACE
  cairo_status_t status =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_RECORDING);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_recording_surface_ink_extents(
    surface->ptr,
    x0,
    y0,
    width,
    height);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)x0;
  (void)y0;
  (void)width;
  (void)height;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_recording_surface_get_extents(
  CairoonSurface *surface,
  int32_t *has_extents,
  double *x,
  double *y,
  double *width,
  double *height) {
  *has_extents = 0;
#ifdef CAIRO_HAS_RECORDING_SURFACE
  cairo_status_t status =
    cairoon_recording_surface_require_type_allow_finished(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_t extents;
  cairo_bool_t result = cairo_recording_surface_get_extents(
    surface->ptr,
    &extents);
  if (result) {
    *has_extents = 1;
    *x = extents.x;
    *y = extents.y;
    *width = extents.width;
    *height = extents.height;
  }
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)x;
  (void)y;
  (void)width;
  (void)height;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
