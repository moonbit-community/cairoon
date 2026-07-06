#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_move_to(CairoonContext *ctx, double x, double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_move_to(ctx->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rel_move_to(CairoonContext *ctx, double dx, double dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rel_move_to(ctx->ptr, dx, dy);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_line_to(CairoonContext *ctx, double x, double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_line_to(ctx->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rel_line_to(CairoonContext *ctx, double dx, double dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rel_line_to(ctx->ptr, dx, dy);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_curve_to(
  CairoonContext *ctx,
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_curve_to(ctx->ptr, x1, y1, x2, y2, x3, y3);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rel_curve_to(
  CairoonContext *ctx,
  double dx1,
  double dy1,
  double dx2,
  double dy2,
  double dx3,
  double dy3) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rel_curve_to(ctx->ptr, dx1, dy1, dx2, dy2, dx3, dy3);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rectangle(
  CairoonContext *ctx,
  double x,
  double y,
  double width,
  double height) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle(ctx->ptr, x, y, width, height);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_arc(
  CairoonContext *ctx,
  double xc,
  double yc,
  double radius,
  double angle1,
  double angle2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_arc(ctx->ptr, xc, yc, radius, angle1, angle2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_arc_negative(
  CairoonContext *ctx,
  double xc,
  double yc,
  double radius,
  double angle1,
  double angle2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_arc_negative(ctx->ptr, xc, yc, radius, angle1, angle2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_close_path(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_close_path(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_new_path(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_new_path(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_new_sub_path(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_new_sub_path(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_get_current_point(CairoonContext *ctx, double *x, double *y) {
  *x = 0.0;
  *y = 0.0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_get_current_point(ctx->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_has_current_point(CairoonContext *ctx, int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_has_current_point(ctx->ptr) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonPath *cairoon_context_copy_path(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_path_wrap_owned(NULL);
  }

  cairo_path_t *path = cairo_copy_path(ctx->ptr);
  if (path == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_path_wrap_owned(NULL);
  }
  *status_out = path->status;
  return cairoon_path_wrap_owned(path);
}

MOONBIT_FFI_EXPORT
CairoonPath *cairoon_context_copy_path_flat(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_path_wrap_owned(NULL);
  }

  cairo_path_t *path = cairo_copy_path_flat(ctx->ptr);
  if (path == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_path_wrap_owned(NULL);
  }
  *status_out = path->status;
  return cairoon_path_wrap_owned(path);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_append_path(CairoonContext *ctx, CairoonPath *path) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (path == NULL || path->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  if (path->ptr->status != CAIRO_STATUS_SUCCESS) {
    return path->ptr->status;
  }
  cairo_append_path(ctx->ptr, path->ptr);
  return cairo_status(ctx->ptr);
}
