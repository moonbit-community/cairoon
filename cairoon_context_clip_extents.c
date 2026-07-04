#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_clip(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_clip(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_clip_preserve(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_clip_preserve(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_reset_clip(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_reset_clip(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_clip_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_clip_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double *cairoon_context_copy_clip_rectangle_list(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_empty_double_array;
  }

  cairo_rectangle_list_t *list = cairo_copy_clip_rectangle_list(ctx->ptr);
  if (list == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return moonbit_empty_double_array;
  }

  *status_out = list->status;
  if (list->status != CAIRO_STATUS_SUCCESS || list->num_rectangles <= 0) {
    cairo_rectangle_list_destroy(list);
    return moonbit_empty_double_array;
  }
  if (list->num_rectangles > INT32_MAX / 4) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    cairo_rectangle_list_destroy(list);
    return moonbit_empty_double_array;
  }

  int32_t value_count = list->num_rectangles * 4;
  double *values = moonbit_make_double_array_raw(value_count);
  for (int32_t i = 0; i < list->num_rectangles; i++) {
    cairo_rectangle_t rectangle = list->rectangles[i];
    int32_t offset = i * 4;
    values[offset] = rectangle.x;
    values[offset + 1] = rectangle.y;
    values[offset + 2] = rectangle.width;
    values[offset + 3] = rectangle.height;
  }
  cairo_rectangle_list_destroy(list);
  return values;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_fill_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_fill_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_stroke_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_stroke_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_path_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_path_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_in_clip(
  CairoonContext *ctx,
  double x,
  double y,
  int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_in_clip(ctx->ptr, x, y) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_in_fill(
  CairoonContext *ctx,
  double x,
  double y,
  int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_in_fill(ctx->ptr, x, y) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_in_stroke(
  CairoonContext *ctx,
  double x,
  double y,
  int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_in_stroke(ctx->ptr, x, y) ? 1 : 0;
  return cairo_status(ctx->ptr);
}
