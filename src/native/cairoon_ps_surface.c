#include "cairoon_private.h"

#if CAIRO_HAS_PS_SURFACE
#include <cairo-ps.h>
#endif

static cairo_status_t cairoon_ps_surface_require(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_PS_SURFACE
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_PS) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_ps_surface_create(
  int32_t has_filename,
  moonbit_bytes_t filename,
  double width_in_points,
  double height_in_points,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PS_SURFACE
  if (has_filename && filename == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  const char *name = has_filename ? (const char *)filename : NULL;
  cairo_surface_t *surface =
    cairo_ps_surface_create(name, width_in_points, height_in_points);
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
CairoonSurface *cairoon_ps_surface_create_for_stream(
  CairoonStreamWriteCallback callback,
  void *arg,
  double width_in_points,
  double height_in_points,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface = cairo_ps_surface_create_for_stream(
    cairoon_stream_write,
    state,
    width_in_points,
    height_in_points);
  if (surface == NULL) {
    cairoon_stream_state_destroy(state);
    *status_out = CAIRO_STATUS_NO_MEMORY;
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
int32_t cairoon_ps_get_level_count(cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PS_SURFACE
  const cairo_ps_level_t *levels = NULL;
  int num_levels = 0;
  cairo_ps_get_levels(&levels, &num_levels);
  (void)levels;
  return (int32_t)num_levels;
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_ps_get_level(int32_t index, cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PS_SURFACE
  const cairo_ps_level_t *levels = NULL;
  int num_levels = 0;
  cairo_ps_get_levels(&levels, &num_levels);
  if (index < 0 || index >= num_levels) {
    *status_out = CAIRO_STATUS_INVALID_INDEX;
    return 0;
  }
  return (int32_t)levels[index];
#else
  (void)index;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_ps_level_to_string(
  int32_t level,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PS_SURFACE
  const char *str = cairo_ps_level_to_string((cairo_ps_level_t)level);
  if (str == NULL) {
    *status_out = CAIRO_STATUS_INVALID_STATUS;
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_c_string(str);
#else
  (void)level;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return moonbit_make_bytes(0, 0);
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_ps_surface_restrict_to_level(
  CairoonSurface *surface,
  int32_t level) {
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = cairoon_ps_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_ps_surface_restrict_to_level(surface->ptr, (cairo_ps_level_t)level);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)level;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_ps_surface_get_eps(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out = cairoon_ps_surface_require(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
#if CAIRO_HAS_PS_SURFACE
  return cairo_ps_surface_get_eps(surface->ptr);
#else
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_ps_surface_set_eps(
  CairoonSurface *surface,
  int32_t eps) {
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = cairoon_ps_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_ps_surface_set_eps(surface->ptr, eps != 0);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)eps;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_ps_surface_set_size(
  CairoonSurface *surface,
  double width_in_points,
  double height_in_points) {
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = cairoon_ps_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_ps_surface_set_size(surface->ptr, width_in_points, height_in_points);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)width_in_points;
  (void)height_in_points;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_ps_surface_dsc_begin_setup(CairoonSurface *surface) {
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = cairoon_ps_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_ps_surface_dsc_begin_setup(surface->ptr);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_ps_surface_dsc_begin_page_setup(
  CairoonSurface *surface) {
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = cairoon_ps_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_ps_surface_dsc_begin_page_setup(surface->ptr);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_ps_surface_dsc_comment(
  CairoonSurface *surface,
  moonbit_bytes_t comment) {
#if CAIRO_HAS_PS_SURFACE
  cairo_status_t status = cairoon_ps_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (comment == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_ps_surface_dsc_comment(surface->ptr, (const char *)comment);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)comment;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
