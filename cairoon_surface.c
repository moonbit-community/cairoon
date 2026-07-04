#include "cairoon_private.h"
static const cairo_user_data_key_t cairoon_surface_finished_key;
static const int cairoon_surface_finished_sentinel = 1;

cairo_status_t cairoon_surface_require_type(
  CairoonSurface *surface,
  cairo_surface_type_t type) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_surface_get_type(surface->ptr) != type) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

static int cairoon_surface_is_finished(cairo_surface_t *surface) {
  return cairo_surface_get_user_data(
    surface,
    &cairoon_surface_finished_key) != NULL;
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_create_similar(
  CairoonSurface *other,
  cairo_content_t content,
  int32_t width,
  int32_t height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(other);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface =
    cairo_surface_create_similar(other->ptr, content, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_create_similar_image(
  CairoonSurface *other,
  cairo_format_t format,
  int32_t width,
  int32_t height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(other);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface =
    cairo_surface_create_similar_image(other->ptr, format, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_create_for_rectangle(
  CairoonSurface *target,
  double x,
  double y,
  double width,
  double height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(target);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface =
    cairo_surface_create_for_rectangle(target->ptr, x, y, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned_with_base(surface, target);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_status(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairoon_surface_is_finished(surface->ptr)) {
    return CAIRO_STATUS_SURFACE_FINISHED;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_surface_equal(CairoonSurface *surface, CairoonSurface *other) {
  if (surface == NULL || other == NULL || surface->ptr == NULL ||
      other->ptr == NULL) {
    return 0;
  }
  return surface->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_surface_hash(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)surface->ptr;
}

MOONBIT_FFI_EXPORT
cairo_content_t cairoon_surface_get_content(CairoonSurface *surface) {
  if (cairoon_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_CONTENT_COLOR_ALPHA;
  }
  return cairo_surface_get_content(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_surface_type_t cairoon_surface_get_type(CairoonSurface *surface) {
  if (cairoon_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_SURFACE_TYPE_IMAGE;
  }
  return cairo_surface_get_type(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_finish(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairoon_surface_is_finished(surface->ptr)) {
    return CAIRO_STATUS_SUCCESS;
  }
  status = cairo_surface_set_user_data(
    surface->ptr,
    &cairoon_surface_finished_key,
    (void *)&cairoon_surface_finished_sentinel,
    NULL);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_finish(surface->ptr);
  return cairo_surface_status(surface->ptr);
}
