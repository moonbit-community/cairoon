#include "cairoon_private.h"

#include <stdlib.h>

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_context_get_font_options(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *options = cairo_font_options_create();
  status = cairo_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(options);
  }
  cairo_get_font_options(ctx->ptr, options);
  *status_out = cairo_font_options_status(options);
  return cairoon_font_options_wrap_owned(options);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_options(
  CairoonContext *ctx,
  CairoonFontOptions *options) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_options(ctx->ptr, options->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_context_get_font_face(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  cairo_font_face_t *font_face = cairo_get_font_face(ctx->ptr);
  if (font_face == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_font_face_wrap_owned(NULL);
  }
  *status_out = cairo_font_face_status(font_face);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  return cairoon_font_face_wrap_borrowed(font_face);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_face(
  CairoonContext *ctx,
  CairoonFontFace *font_face) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_font_face_status(font_face);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_face(ctx->ptr, font_face->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_face_default(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_face(ctx->ptr, NULL);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_select_font_face_raw(
  CairoonContext *ctx,
  moonbit_bytes_t family,
  int32_t slant,
  int32_t weight) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_select_font_face(
    ctx->ptr,
    (const char *)family,
    (cairo_font_slant_t)slant,
    (cairo_font_weight_t)weight);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_matrix(
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
  cairo_set_font_matrix(ctx->ptr, &matrix);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_get_font_matrix(
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
  cairo_get_font_matrix(ctx->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_size(CairoonContext *ctx, double size) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_size(ctx->ptr, size);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_font_extents(
  CairoonContext *ctx,
  double *ascent,
  double *descent,
  double *height,
  double *max_x_advance,
  double *max_y_advance) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_extents_t extents;
  cairo_font_extents(ctx->ptr, &extents);
  *ascent = extents.ascent;
  *descent = extents.descent;
  *height = extents.height;
  *max_x_advance = extents.max_x_advance;
  *max_y_advance = extents.max_y_advance;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_show_text(
  CairoonContext *ctx,
  moonbit_bytes_t text) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (text == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_show_text(ctx->ptr, (const char *)text);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_text_extents(
  CairoonContext *ctx,
  moonbit_bytes_t text,
  double *x_bearing,
  double *y_bearing,
  double *width,
  double *height,
  double *x_advance,
  double *y_advance) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (text == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_text_extents_t extents;
  cairo_text_extents(ctx->ptr, (const char *)text, &extents);
  *x_bearing = extents.x_bearing;
  *y_bearing = extents.y_bearing;
  *width = extents.width;
  *height = extents.height;
  *x_advance = extents.x_advance;
  *y_advance = extents.y_advance;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_text_path(
  CairoonContext *ctx,
  moonbit_bytes_t text) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (text == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_text_path(ctx->ptr, (const char *)text);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_glyph_extents(
  CairoonContext *ctx,
  uint64_t *indices,
  double *xs,
  double *ys,
  double *x_bearing,
  double *y_bearing,
  double *width,
  double *height,
  double *x_advance,
  double *y_advance) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_glyph_t *glyphs = NULL;
  int count = 0;
  status = cairoon_glyphs_from_fields(indices, xs, ys, &glyphs, &count);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_text_extents_t extents;
  cairo_glyph_extents(ctx->ptr, glyphs, count, &extents);
  free(glyphs);
  *x_bearing = extents.x_bearing;
  *y_bearing = extents.y_bearing;
  *width = extents.width;
  *height = extents.height;
  *x_advance = extents.x_advance;
  *y_advance = extents.y_advance;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_glyph_path(
  CairoonContext *ctx,
  uint64_t *indices,
  double *xs,
  double *ys) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_glyph_t *glyphs = NULL;
  int count = 0;
  status = cairoon_glyphs_from_fields(indices, xs, ys, &glyphs, &count);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_glyph_path(ctx->ptr, glyphs, count);
  free(glyphs);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_show_glyphs(
  CairoonContext *ctx,
  uint64_t *indices,
  double *xs,
  double *ys) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_glyph_t *glyphs = NULL;
  int count = 0;
  status = cairoon_glyphs_from_fields(indices, xs, ys, &glyphs, &count);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_show_glyphs(ctx->ptr, glyphs, count);
  free(glyphs);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_show_text_glyphs(
  CairoonContext *ctx,
  moonbit_bytes_t text,
  uint64_t *indices,
  double *xs,
  double *ys,
  int32_t *cluster_num_bytes,
  int32_t *cluster_num_glyphs,
  cairo_text_cluster_flags_t flags) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (text == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }

  cairo_glyph_t *glyphs = NULL;
  int glyph_count = 0;
  status = cairoon_glyphs_from_fields(indices, xs, ys, &glyphs, &glyph_count);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }

  cairo_text_cluster_t *clusters = NULL;
  int cluster_count = 0;
  status = cairoon_text_clusters_from_fields(
    cluster_num_bytes, cluster_num_glyphs, &clusters, &cluster_count);
  if (status != CAIRO_STATUS_SUCCESS) {
    free(glyphs);
    return status;
  }

  cairo_show_text_glyphs(
    ctx->ptr,
    (const char *)text,
    -1,
    glyphs,
    glyph_count,
    clusters,
    cluster_count,
    flags);
  free(glyphs);
  free(clusters);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonScaledFont *cairoon_context_get_scaled_font(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  cairo_scaled_font_t *scaled_font = cairo_get_scaled_font(ctx->ptr);
  if (scaled_font == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  *status_out = cairo_scaled_font_status(scaled_font);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  return cairoon_scaled_font_wrap_borrowed(scaled_font);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_scaled_font(
  CairoonContext *ctx,
  CairoonScaledFont *scaled_font) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_scaled_font(ctx->ptr, scaled_font->ptr);
  return cairo_status(ctx->ptr);
}
