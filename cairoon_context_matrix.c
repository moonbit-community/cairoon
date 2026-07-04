#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_scale(CairoonContext *ctx, double sx, double sy) {
  cairo_scale(ctx->ptr, sx, sy);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_translate(CairoonContext *ctx, double tx, double ty) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_translate(ctx->ptr, tx, ty);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rotate(CairoonContext *ctx, double radians) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rotate(ctx->ptr, radians);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_transform(
  CairoonContext *ctx,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_transform(ctx->ptr, &matrix);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_matrix(
  CairoonContext *ctx,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_set_matrix(ctx->ptr, &matrix);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_get_matrix(
  CairoonContext *ctx,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_get_matrix(ctx->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_identity_matrix(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_identity_matrix(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_user_to_device(
  CairoonContext *ctx,
  double x,
  double y,
  double *out_x,
  double *out_y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_user_to_device(ctx->ptr, &x, &y);
  *out_x = x;
  *out_y = y;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_user_to_device_distance(
  CairoonContext *ctx,
  double dx,
  double dy,
  double *out_dx,
  double *out_dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_user_to_device_distance(ctx->ptr, &dx, &dy);
  *out_dx = dx;
  *out_dy = dy;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_device_to_user(
  CairoonContext *ctx,
  double x,
  double y,
  double *out_x,
  double *out_y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_to_user(ctx->ptr, &x, &y);
  *out_x = x;
  *out_y = y;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_device_to_user_distance(
  CairoonContext *ctx,
  double dx,
  double dy,
  double *out_dx,
  double *out_dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_to_user_distance(ctx->ptr, &dx, &dy);
  *out_dx = dx;
  *out_dy = dy;
  return cairo_status(ctx->ptr);
}
