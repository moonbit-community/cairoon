#include "cairoon_private.h"

#include <stdlib.h>

MOONBIT_FFI_EXPORT
CairoonContext *cairoon_context_create(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return cairoon_context_wrap_owned(cairo_create(NULL), NULL);
  }
  return cairoon_context_wrap_owned(cairo_create(surface->ptr), surface);
}

MOONBIT_FFI_EXPORT
CairoonContext *cairoon_context_create_for_mapped_image(
  CairoonMappedImageSurface *surface,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_mapped_image_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_context_wrap_owned(cairo_create(NULL), NULL);
  }
  return cairoon_context_wrap_owned(cairo_create(surface->mapped), surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_status(CairoonContext *ctx) {
  if (ctx == NULL || ctx->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_save(CairoonContext *ctx) {
  cairo_save(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_restore(CairoonContext *ctx) {
  cairo_restore(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_tag_begin(
  CairoonContext *ctx,
  moonbit_bytes_t tag_name,
  moonbit_bytes_t attributes) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (tag_name == NULL || attributes == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_tag_begin(ctx->ptr, (const char *)tag_name, (const char *)attributes);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_tag_end(
  CairoonContext *ctx,
  moonbit_bytes_t tag_name) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (tag_name == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_tag_end(ctx->ptr, (const char *)tag_name);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_context_get_target(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface = cairo_get_target(ctx->ptr);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_borrowed_with_base(surface, ctx->target_surface);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_context_get_source(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  cairo_pattern_t *pattern = cairo_get_source(ctx->ptr);
  if (pattern == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  *status_out = cairo_pattern_status(pattern);
  return cairoon_pattern_wrap_borrowed(pattern);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_context_get_group_target(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface = cairo_get_group_target(ctx->ptr);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_borrowed_with_base(surface, ctx->target_surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_push_group(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_push_group(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_push_group_with_content(
  CairoonContext *ctx,
  cairo_content_t content) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_push_group_with_content(ctx->ptr, content);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_context_pop_group(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  cairo_pattern_t *pattern = cairo_pop_group(ctx->ptr);
  *status_out = cairo_status(ctx->ptr);
  if (pattern == NULL) {
    if (*status_out == CAIRO_STATUS_SUCCESS) {
      *status_out = CAIRO_STATUS_NO_MEMORY;
    }
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  if (*status_out == CAIRO_STATUS_SUCCESS) {
    *status_out = cairo_pattern_status(pattern);
  }
  return cairoon_pattern_wrap_owned(pattern, NULL);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_pop_group_to_source(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pop_group_to_source(ctx->ptr);
  return cairo_status(ctx->ptr);
}

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
cairo_status_t cairoon_context_select_font_face(
  CairoonContext *ctx,
  moonbit_bytes_t family,
  cairo_font_slant_t slant,
  cairo_font_weight_t weight) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_select_font_face(ctx->ptr, (const char *)family, slant, weight);
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
  uint32_t *indices,
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
  uint32_t *indices,
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
  uint32_t *indices,
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
  uint32_t *indices,
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

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source_rgb(
  CairoonContext *ctx,
  double red,
  double green,
  double blue) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source_rgb(ctx->ptr, red, green, blue);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source_rgba(
  CairoonContext *ctx,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source_rgba(ctx->ptr, red, green, blue, alpha);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source(CairoonContext *ctx, CairoonPattern *pattern) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source(ctx->ptr, pattern->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source_surface(
  CairoonContext *ctx,
  CairoonSurface *surface,
  double x,
  double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source_surface(ctx->ptr, surface->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_paint(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_paint(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_paint_with_alpha(CairoonContext *ctx, double alpha) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_paint_with_alpha(ctx->ptr, alpha);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_mask(CairoonContext *ctx, CairoonPattern *pattern) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mask(ctx->ptr, pattern->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_mask_surface(
  CairoonContext *ctx,
  CairoonSurface *surface,
  double x,
  double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mask_surface(ctx->ptr, surface->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_fill(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_fill(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_fill_preserve(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_fill_preserve(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_stroke(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_stroke(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_stroke_preserve(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_stroke_preserve(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_copy_page(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_copy_page(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_show_page(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_show_page(ctx->ptr);
  return cairo_status(ctx->ptr);
}
