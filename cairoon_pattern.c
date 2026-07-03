#include "cairoon_private.h"

#include <limits.h>
#include <stdlib.h>

typedef struct {
  CairoonRasterSourceAcquireCallback acquire;
  void *acquire_arg;
  CairoonRasterSourceReleaseCallback release;
  void *release_arg;
} CairoonRasterSourceState;

typedef struct {
  CairoonSurface *surface;
  int32_t count;
} CairoonRasterSurfaceOwner;

static const cairo_user_data_key_t cairoon_raster_source_state_key;
static const cairo_user_data_key_t cairoon_raster_surface_owner_key;

static void cairoon_raster_surface_owner_destroy(void *owner_ptr) {
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)owner_ptr;
  if (owner == NULL) {
    return;
  }
  if (owner->surface != NULL) {
    moonbit_decref(owner->surface);
    owner->surface = NULL;
  }
  free(owner);
}

static void cairoon_raster_source_state_destroy(void *state_ptr) {
  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)state_ptr;
  if (state == NULL) {
    return;
  }
  if (state->acquire_arg != NULL) {
    moonbit_decref(state->acquire_arg);
    state->acquire_arg = NULL;
  }
  if (state->release_arg != NULL) {
    moonbit_decref(state->release_arg);
    state->release_arg = NULL;
  }
  free(state);
}

static cairo_status_t cairoon_pattern_require_raster_source(
  CairoonPattern *pattern) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_pattern_get_type(pattern->ptr) !=
      CAIRO_PATTERN_TYPE_RASTER_SOURCE) {
    return CAIRO_STATUS_PATTERN_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

static cairo_status_t cairoon_raster_surface_owner_retain(
  CairoonSurface *surface) {
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface->ptr,
      &cairoon_raster_surface_owner_key);

  if (owner != NULL) {
    if (owner->count == INT_MAX) {
      return CAIRO_STATUS_NO_MEMORY;
    }
    owner->count += 1;
    moonbit_decref(surface);
    return CAIRO_STATUS_SUCCESS;
  }

  owner = (CairoonRasterSurfaceOwner *)malloc(
    sizeof(CairoonRasterSurfaceOwner));
  if (owner == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  owner->surface = surface;
  owner->count = 1;

  cairo_status_t status = cairo_surface_set_user_data(
    surface->ptr,
    &cairoon_raster_surface_owner_key,
    owner,
    cairoon_raster_surface_owner_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    free(owner);
  }
  return status;
}

static void cairoon_raster_surface_owner_release(cairo_surface_t *surface) {
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface,
      &cairoon_raster_surface_owner_key);
  if (owner == NULL) {
    cairo_surface_destroy(surface);
    return;
  }

  if (owner->count > 1) {
    owner->count -= 1;
  } else {
    (void)cairo_surface_set_user_data(
      surface,
      &cairoon_raster_surface_owner_key,
      NULL,
      NULL);
  }
  cairo_surface_destroy(surface);
}

static cairo_surface_t *cairoon_raster_source_acquire(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *target,
  const cairo_rectangle_int_t *extents) {
  cairo_pattern_t *callback_pattern = (cairo_pattern_t *)callback_data;
  if (callback_pattern == NULL) {
    callback_pattern = pattern;
  }
  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)cairo_pattern_get_user_data(
      callback_pattern,
      &cairoon_raster_source_state_key);
  if (state == NULL || state->acquire == NULL || target == NULL ||
      extents == NULL) {
    return NULL;
  }

  CairoonSurface *target_wrapper = cairoon_surface_wrap_borrowed(target);
  CairoonSurface *source_wrapper = state->acquire(
    target_wrapper,
    extents->x,
    extents->y,
    extents->width,
    extents->height,
    state->acquire_arg);
  moonbit_decref(target_wrapper);

  if (source_wrapper == NULL || source_wrapper->ptr == NULL) {
    if (source_wrapper != NULL) {
      moonbit_decref(source_wrapper);
    }
    return NULL;
  }

  cairo_surface_t *source = source_wrapper->ptr;
  if (cairo_surface_status(source) != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(source_wrapper);
    return NULL;
  }

  cairo_status_t status = cairoon_raster_surface_owner_retain(source_wrapper);
  if (status != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(source_wrapper);
    return NULL;
  }
  cairo_surface_reference(source);
  return source;
}

static void cairoon_raster_source_release(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *surface) {
  cairo_pattern_t *callback_pattern = (cairo_pattern_t *)callback_data;
  if (callback_pattern == NULL) {
    callback_pattern = pattern;
  }
  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)cairo_pattern_get_user_data(
      callback_pattern,
      &cairoon_raster_source_state_key);
  if (surface == NULL) {
    return;
  }

  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface,
      &cairoon_raster_surface_owner_key);
  if (state != NULL && state->release != NULL && owner != NULL &&
      owner->surface != NULL) {
    state->release(owner->surface, state->release_arg);
  }
  cairoon_raster_surface_owner_release(surface);
}

static CairoonRasterSourceState *cairoon_raster_source_state_new(
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg,
  CairoonRasterSourceReleaseCallback release,
  void *release_arg,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (acquire == NULL) {
    if (acquire_arg != NULL) {
      moonbit_decref(acquire_arg);
    }
    if (release_arg != NULL) {
      moonbit_decref(release_arg);
    }
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }

  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)malloc(sizeof(CairoonRasterSourceState));
  if (state == NULL) {
    if (acquire_arg != NULL) {
      moonbit_decref(acquire_arg);
    }
    if (release_arg != NULL) {
      moonbit_decref(release_arg);
    }
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return NULL;
  }

  state->acquire = acquire;
  state->acquire_arg = acquire_arg;
  state->release = release;
  state->release_arg = release_arg;
  return state;
}

static cairo_status_t cairoon_raster_source_pattern_set_state(
  CairoonPattern *pattern,
  CairoonRasterSourceState *state) {
  cairo_status_t status = cairoon_pattern_require_raster_source(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_raster_source_state_destroy(state);
    return status;
  }

  status = cairo_pattern_set_user_data(
    pattern->ptr,
    &cairoon_raster_source_state_key,
    state,
    state == NULL ? NULL : cairoon_raster_source_state_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_raster_source_state_destroy(state);
    return status;
  }

  cairo_raster_source_pattern_set_callback_data(
    pattern->ptr,
    state == NULL ? NULL : pattern->ptr);
  cairo_raster_source_pattern_set_acquire(
    pattern->ptr,
    state == NULL ? NULL : cairoon_raster_source_acquire,
    state == NULL ? NULL : cairoon_raster_source_release);
  return cairo_pattern_status(pattern->ptr);
}

static CairoonRasterSourceState *cairoon_raster_source_pattern_get_state(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  *status_out = cairoon_pattern_require_raster_source(pattern);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return NULL;
  }
  return (CairoonRasterSourceState *)cairo_pattern_get_user_data(
    pattern->ptr,
    &cairoon_raster_source_state_key);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_rgb(double red, double green, double blue) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_rgb(red, green, blue), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_rgba(
  double red,
  double green,
  double blue,
  double alpha) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_rgba(red, green, blue, alpha), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_linear(double x0, double y0, double x1, double y1) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_linear(x0, y0, x1, y1), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_radial(
  double cx0,
  double cy0,
  double radius0,
  double cx1,
  double cy1,
  double radius1) {
  return cairoon_pattern_wrap_owned(
    cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1),
    NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_mesh(void) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_mesh(), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_raster_source(
  cairo_content_t content,
  int32_t width,
  int32_t height) {
  return cairoon_pattern_wrap_owned(
    cairo_pattern_create_raster_source(NULL, content, width, height),
    NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_for_surface(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  return cairoon_pattern_wrap_owned(cairo_pattern_create_for_surface(surface->ptr), surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_status(CairoonPattern *pattern) {
  if (pattern == NULL || pattern->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_pattern_equal(CairoonPattern *pattern, CairoonPattern *other) {
  if (pattern == NULL || other == NULL || pattern->ptr == NULL ||
      other->ptr == NULL) {
    return 0;
  }
  return pattern->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_pattern_hash(CairoonPattern *pattern) {
  if (pattern == NULL || pattern->ptr == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)pattern->ptr;
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_pattern_get_surface(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface = NULL;
  status = cairo_pattern_get_surface(pattern->ptr, &surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS || surface == NULL) {
    return cairoon_surface_wrap_owned(NULL);
  }

  status = cairo_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }

  return cairoon_surface_wrap_borrowed(surface);
}

MOONBIT_FFI_EXPORT
cairo_extend_t cairoon_pattern_get_extend(CairoonPattern *pattern) {
  return cairo_pattern_get_extend(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_extend(CairoonPattern *pattern, cairo_extend_t extend) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_set_extend(pattern->ptr, extend);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_filter_t cairoon_pattern_get_filter(CairoonPattern *pattern) {
  return cairo_pattern_get_filter(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_filter(CairoonPattern *pattern, cairo_filter_t filter) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_set_filter(pattern->ptr, filter);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_dither_t cairoon_pattern_get_dither(CairoonPattern *pattern) {
  return cairo_pattern_get_dither(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_dither(CairoonPattern *pattern, cairo_dither_t dither) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_set_dither(pattern->ptr, dither);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_matrix(
  CairoonPattern *pattern,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_pattern_get_matrix(pattern->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_matrix(
  CairoonPattern *pattern,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_pattern_set_matrix(pattern->ptr, &matrix);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_rgba(
  CairoonPattern *pattern,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_rgba(pattern->ptr, red, green, blue, alpha);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_add_color_stop_rgb(
  CairoonPattern *pattern,
  double offset,
  double red,
  double green,
  double blue) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_add_color_stop_rgb(pattern->ptr, offset, red, green, blue);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_add_color_stop_rgba(
  CairoonPattern *pattern,
  double offset,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_add_color_stop_rgba(pattern->ptr, offset, red, green, blue, alpha);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_color_stop_count(CairoonPattern *pattern, int32_t *count) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  int cairo_count = 0;
  status = cairo_pattern_get_color_stop_count(pattern->ptr, &cairo_count);
  *count = (int32_t)cairo_count;
  return status;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_color_stop_rgba(
  CairoonPattern *pattern,
  int32_t index,
  double *offset,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_color_stop_rgba(pattern->ptr, index, offset, red, green, blue, alpha);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_linear_points(
  CairoonPattern *pattern,
  double *x0,
  double *y0,
  double *x1,
  double *y1) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_linear_points(pattern->ptr, x0, y0, x1, y1);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_radial_circles(
  CairoonPattern *pattern,
  double *cx0,
  double *cy0,
  double *radius0,
  double *cx1,
  double *cy1,
  double *radius1) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_radial_circles(pattern->ptr, cx0, cy0, radius0, cx1, cy1, radius1);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_begin_patch(CairoonPattern *pattern) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mesh_pattern_begin_patch(pattern->ptr);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_set_acquire(
  CairoonPattern *pattern,
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  CairoonRasterSourceState *state = cairoon_raster_source_state_new(
    acquire,
    acquire_arg,
    NULL,
    NULL,
    &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairoon_raster_source_pattern_set_state(pattern, state);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_set_acquire_with_release(
  CairoonPattern *pattern,
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg,
  CairoonRasterSourceReleaseCallback release,
  void *release_arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  CairoonRasterSourceState *state = cairoon_raster_source_state_new(
    acquire,
    acquire_arg,
    release,
    release_arg,
    &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairoon_raster_source_pattern_set_state(pattern, state);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_clear_acquire(
  CairoonPattern *pattern) {
  return cairoon_raster_source_pattern_set_state(pattern, NULL);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_raster_source_pattern_has_acquire(
  CairoonPattern *pattern,
  int32_t *has_release,
  cairo_status_t *status_out) {
  *has_release = 0;
  CairoonRasterSourceState *state =
    cairoon_raster_source_pattern_get_state(pattern, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS || state == NULL ||
      state->acquire == NULL) {
    return 0;
  }
  *has_release = state->release == NULL ? 0 : 1;
  return 1;
}

MOONBIT_FFI_EXPORT
void *cairoon_raster_source_pattern_get_acquire_callback(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  CairoonRasterSourceState *state =
    cairoon_raster_source_pattern_get_state(pattern, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return NULL;
  }
  if (state == NULL || state->acquire == NULL ||
      state->acquire_arg == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }
  moonbit_incref(state->acquire_arg);
  return state->acquire_arg;
}

MOONBIT_FFI_EXPORT
void *cairoon_raster_source_pattern_get_release_callback(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  CairoonRasterSourceState *state =
    cairoon_raster_source_pattern_get_state(pattern, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return NULL;
  }
  if (state == NULL || state->release == NULL ||
      state->release_arg == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }
  moonbit_incref(state->release_arg);
  return state->release_arg;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_end_patch(CairoonPattern *pattern) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mesh_pattern_end_patch(pattern->ptr);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_move_to(
  CairoonPattern *pattern,
  double x,
  double y) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mesh_pattern_move_to(pattern->ptr, x, y);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_line_to(
  CairoonPattern *pattern,
  double x,
  double y) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mesh_pattern_line_to(pattern->ptr, x, y);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_curve_to(
  CairoonPattern *pattern,
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mesh_pattern_curve_to(pattern->ptr, x1, y1, x2, y2, x3, y3);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_set_control_point(
  CairoonPattern *pattern,
  int32_t point_num,
  double x,
  double y) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (point_num < 0) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  cairo_mesh_pattern_set_control_point(
    pattern->ptr,
    (unsigned int)point_num,
    x,
    y);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_set_corner_color_rgb(
  CairoonPattern *pattern,
  int32_t corner_num,
  double red,
  double green,
  double blue) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (corner_num < 0) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  cairo_mesh_pattern_set_corner_color_rgb(
    pattern->ptr,
    (unsigned int)corner_num,
    red,
    green,
    blue);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_set_corner_color_rgba(
  CairoonPattern *pattern,
  int32_t corner_num,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (corner_num < 0) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  cairo_mesh_pattern_set_corner_color_rgba(
    pattern->ptr,
    (unsigned int)corner_num,
    red,
    green,
    blue,
    alpha);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_get_patch_count(
  CairoonPattern *pattern,
  int32_t *count) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  unsigned int cairo_count = 0;
  status = cairo_mesh_pattern_get_patch_count(pattern->ptr, &cairo_count);
  *count = (int32_t)cairo_count;
  return status;
}

MOONBIT_FFI_EXPORT
CairoonPath *cairoon_mesh_pattern_get_path(
  CairoonPattern *pattern,
  int32_t patch_num,
  cairo_status_t *status_out) {
  *status_out = cairoon_pattern_status(pattern);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_path_wrap_owned(NULL);
  }
  if (patch_num < 0) {
    *status_out = CAIRO_STATUS_INVALID_INDEX;
    return cairoon_path_wrap_owned(NULL);
  }
  cairo_path_t *path =
    cairo_mesh_pattern_get_path(pattern->ptr, (unsigned int)patch_num);
  if (path == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_path_wrap_owned(NULL);
  }
  *status_out = path->status;
  return cairoon_path_wrap_owned(path);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_get_control_point(
  CairoonPattern *pattern,
  int32_t patch_num,
  int32_t point_num,
  double *x,
  double *y) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (patch_num < 0 || point_num < 0) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  return cairo_mesh_pattern_get_control_point(
    pattern->ptr,
    (unsigned int)patch_num,
    (unsigned int)point_num,
    x,
    y);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mesh_pattern_get_corner_color_rgba(
  CairoonPattern *pattern,
  int32_t patch_num,
  int32_t corner_num,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (patch_num < 0 || corner_num < 0) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  return cairo_mesh_pattern_get_corner_color_rgba(
    pattern->ptr,
    (unsigned int)patch_num,
    (unsigned int)corner_num,
    red,
    green,
    blue,
    alpha);
}
