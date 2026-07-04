#include "cairoon_private.h"

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
