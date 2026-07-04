#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_line_width(CairoonContext *ctx, double width) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_line_width(ctx->ptr, width);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double cairoon_context_get_line_width(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0.0;
  }
  return cairo_get_line_width(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_hairline(CairoonContext *ctx, int32_t set_hairline) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_hairline(ctx->ptr, set_hairline);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_context_get_hairline(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_get_hairline(ctx->ptr) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_line_cap(CairoonContext *ctx, cairo_line_cap_t cap) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_line_cap(ctx->ptr, cap);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_line_cap_t cairoon_context_get_line_cap(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_LINE_CAP_BUTT;
  }
  return cairo_get_line_cap(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_line_join(CairoonContext *ctx, cairo_line_join_t join) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_line_join(ctx->ptr, join);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_line_join_t cairoon_context_get_line_join(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_LINE_JOIN_MITER;
  }
  return cairo_get_line_join(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_fill_rule(CairoonContext *ctx, cairo_fill_rule_t fill_rule) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_fill_rule(ctx->ptr, fill_rule);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_fill_rule_t cairoon_context_get_fill_rule(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FILL_RULE_WINDING;
  }
  return cairo_get_fill_rule(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_operator(CairoonContext *ctx, cairo_operator_t operator_) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_operator(ctx->ptr, operator_);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_operator_t cairoon_context_get_operator(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_OPERATOR_OVER;
  }
  return cairo_get_operator(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_antialias(CairoonContext *ctx, cairo_antialias_t antialias) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_antialias(ctx->ptr, antialias);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_antialias_t cairoon_context_get_antialias(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_ANTIALIAS_DEFAULT;
  }
  return cairo_get_antialias(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_tolerance(CairoonContext *ctx, double tolerance) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_tolerance(ctx->ptr, tolerance);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double cairoon_context_get_tolerance(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0.0;
  }
  return cairo_get_tolerance(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_miter_limit(CairoonContext *ctx, double limit) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_miter_limit(ctx->ptr, limit);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double cairoon_context_get_miter_limit(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0.0;
  }
  return cairo_get_miter_limit(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_dash(CairoonContext *ctx, double *dashes, double offset) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  int32_t count = (int32_t)Moonbit_array_length(dashes);
  cairo_set_dash(ctx->ptr, dashes, count, offset);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_context_get_dash_count(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_get_dash_count(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double *cairoon_context_get_dash(CairoonContext *ctx, double *offset) {
  int32_t count = cairoon_context_get_dash_count(ctx);
  *offset = 0.0;
  if (count <= 0 || cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return moonbit_empty_double_array;
  }
  double *dashes = moonbit_make_double_array_raw(count);
  cairo_get_dash(ctx->ptr, dashes, offset);
  return dashes;
}
