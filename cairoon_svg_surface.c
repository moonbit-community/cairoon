#include "cairoon_private.h"

#if CAIRO_HAS_SVG_SURFACE
#include <cairo-svg.h>
#endif

static cairo_status_t cairoon_svg_surface_require(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_SVG_SURFACE
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_SVG) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_svg_surface_create(
  int32_t has_filename,
  moonbit_bytes_t filename,
  double width_in_points,
  double height_in_points,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SVG_SURFACE
  if (has_filename && filename == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  const char *name = has_filename ? (const char *)filename : NULL;
  cairo_surface_t *surface =
    cairo_svg_surface_create(name, width_in_points, height_in_points);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)has_filename;
  (void)filename;
  (void)width_in_points;
  (void)height_in_points;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_svg_surface_create_for_stream(
  CairoonStreamWriteCallback callback,
  void *arg,
  double width_in_points,
  double height_in_points,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SVG_SURFACE
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface = cairo_svg_surface_create_for_stream(
    cairoon_stream_write,
    state,
    width_in_points,
    height_in_points);
  if (surface == NULL) {
    cairoon_stream_state_destroy(state);
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }

  status = cairoon_stream_attach(surface, state);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }

  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)callback;
  if (arg != NULL) {
    moonbit_decref(arg);
  }
  (void)width_in_points;
  (void)height_in_points;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_svg_get_version_count(cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SVG_SURFACE
  const cairo_svg_version_t *versions = NULL;
  int num_versions = 0;
  cairo_svg_get_versions(&versions, &num_versions);
  (void)versions;
  return (int32_t)num_versions;
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_svg_get_version(
  int32_t index,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SVG_SURFACE
  const cairo_svg_version_t *versions = NULL;
  int num_versions = 0;
  cairo_svg_get_versions(&versions, &num_versions);
  if (index < 0 || index >= num_versions) {
    *status_out = CAIRO_STATUS_INVALID_INDEX;
    return 0;
  }
  return (int32_t)versions[index];
#else
  (void)index;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_svg_version_to_string(
  int32_t version,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SVG_SURFACE
  const char *str = cairo_svg_version_to_string((cairo_svg_version_t)version);
  if (str == NULL) {
    *status_out = CAIRO_STATUS_INVALID_STATUS;
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_c_string(str);
#else
  (void)version;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return moonbit_make_bytes(0, 0);
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_svg_surface_restrict_to_version(
  CairoonSurface *surface,
  int32_t version) {
#if CAIRO_HAS_SVG_SURFACE
  cairo_status_t status = cairoon_svg_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_svg_surface_restrict_to_version(
    surface->ptr,
    (cairo_svg_version_t)version);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)version;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_svg_surface_get_document_unit(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out = cairoon_svg_surface_require(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
#if CAIRO_HAS_SVG_SURFACE
  return (int32_t)cairo_svg_surface_get_document_unit(surface->ptr);
#else
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_svg_surface_set_document_unit(
  CairoonSurface *surface,
  int32_t unit) {
#if CAIRO_HAS_SVG_SURFACE
  cairo_status_t status = cairoon_svg_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_svg_surface_set_document_unit(surface->ptr, (cairo_svg_unit_t)unit);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)unit;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
