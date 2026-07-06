#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_mesh(void) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_mesh(), NULL);
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
