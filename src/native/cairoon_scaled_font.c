#include "cairoon_private.h"

#include <stdlib.h>

MOONBIT_FFI_EXPORT
CairoonScaledFont *cairoon_scaled_font_create(
  CairoonFontFace *font_face,
  double font_xx,
  double font_yx,
  double font_xy,
  double font_yy,
  double font_x0,
  double font_y0,
  double ctm_xx,
  double ctm_yx,
  double ctm_xy,
  double ctm_yy,
  double ctm_x0,
  double ctm_y0,
  CairoonFontOptions *options) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  cairo_matrix_t font_matrix;
  cairo_matrix_t ctm;
  cairo_matrix_init(
    &font_matrix,
    font_xx,
    font_yx,
    font_xy,
    font_yy,
    font_x0,
    font_y0);
  cairo_matrix_init(&ctm, ctm_xx, ctm_yx, ctm_xy, ctm_yy, ctm_x0, ctm_y0);
  return cairoon_scaled_font_wrap_owned(
    cairo_scaled_font_create(font_face->ptr, &font_matrix, &ctm, options->ptr));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_status(CairoonScaledFont *scaled_font) {
  if (scaled_font == NULL || scaled_font->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_scaled_font_equal(
  CairoonScaledFont *scaled_font,
  CairoonScaledFont *other) {
  if (cairoon_scaled_font_status(scaled_font) != CAIRO_STATUS_SUCCESS ||
      cairoon_scaled_font_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return scaled_font->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_scaled_font_hash(CairoonScaledFont *scaled_font) {
  if (cairoon_scaled_font_status(scaled_font) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)(uintptr_t)scaled_font->ptr;
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_scaled_font_get_font_face(
  CairoonScaledFont *scaled_font,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  cairo_font_face_t *font_face = cairo_scaled_font_get_font_face(scaled_font->ptr);
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
CairoonFontOptions *cairoon_scaled_font_get_font_options(
  CairoonScaledFont *scaled_font,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
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
  cairo_scaled_font_get_font_options(scaled_font->ptr, options);
  *status_out = cairo_font_options_status(options);
  return cairoon_font_options_wrap_owned(options);
}

static cairo_status_t cairoon_scaled_font_get_matrix(
  CairoonScaledFont *scaled_font,
  void (*get_matrix)(cairo_scaled_font_t *, cairo_matrix_t *),
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  get_matrix(scaled_font->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_get_font_matrix(
  CairoonScaledFont *scaled_font,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  return cairoon_scaled_font_get_matrix(
    scaled_font, cairo_scaled_font_get_font_matrix, xx, yx, xy, yy, x0, y0);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_get_ctm(
  CairoonScaledFont *scaled_font,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  return cairoon_scaled_font_get_matrix(
    scaled_font, cairo_scaled_font_get_ctm, xx, yx, xy, yy, x0, y0);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_get_scale_matrix(
  CairoonScaledFont *scaled_font,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  return cairoon_scaled_font_get_matrix(
    scaled_font, cairo_scaled_font_get_scale_matrix, xx, yx, xy, yy, x0, y0);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_extents(
  CairoonScaledFont *scaled_font,
  double *ascent,
  double *descent,
  double *height,
  double *max_x_advance,
  double *max_y_advance) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_extents_t extents;
  cairo_scaled_font_extents(scaled_font->ptr, &extents);
  *ascent = extents.ascent;
  *descent = extents.descent;
  *height = extents.height;
  *max_x_advance = extents.max_x_advance;
  *max_y_advance = extents.max_y_advance;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_text_extents(
  CairoonScaledFont *scaled_font,
  moonbit_bytes_t text,
  double *x_bearing,
  double *y_bearing,
  double *width,
  double *height,
  double *x_advance,
  double *y_advance) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_text_extents_t extents;
  cairo_scaled_font_text_extents(scaled_font->ptr, (const char *)text, &extents);
  *x_bearing = extents.x_bearing;
  *y_bearing = extents.y_bearing;
  *width = extents.width;
  *height = extents.height;
  *x_advance = extents.x_advance;
  *y_advance = extents.y_advance;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_glyph_extents(
  CairoonScaledFont *scaled_font,
  uint64_t *indices,
  double *xs,
  double *ys,
  double *x_bearing,
  double *y_bearing,
  double *width,
  double *height,
  double *x_advance,
  double *y_advance) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
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
  cairo_scaled_font_glyph_extents(scaled_font->ptr, glyphs, count, &extents);
  free(glyphs);
  *x_bearing = extents.x_bearing;
  *y_bearing = extents.y_bearing;
  *width = extents.width;
  *height = extents.height;
  *x_advance = extents.x_advance;
  *y_advance = extents.y_advance;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
CairoonTextToGlyphs *cairoon_scaled_font_text_to_glyphs(
  CairoonScaledFont *scaled_font,
  double x,
  double y,
  moonbit_bytes_t text) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_text_to_glyphs_wrap_owned(
      status, NULL, 0, NULL, 0, (cairo_text_cluster_flags_t)0);
  }
  if (text == NULL) {
    return cairoon_text_to_glyphs_wrap_owned(
      CAIRO_STATUS_NULL_POINTER, NULL, 0, NULL, 0, (cairo_text_cluster_flags_t)0);
  }

  cairo_glyph_t *glyphs = NULL;
  int num_glyphs = 0;
  cairo_text_cluster_t *clusters = NULL;
  int num_clusters = 0;
  cairo_text_cluster_flags_t flags = (cairo_text_cluster_flags_t)0;
  status = cairo_scaled_font_text_to_glyphs(
    scaled_font->ptr,
    x,
    y,
    (const char *)text,
    -1,
    &glyphs,
    &num_glyphs,
    &clusters,
    &num_clusters,
    &flags);
  return cairoon_text_to_glyphs_wrap_owned(
    status, glyphs, (int32_t)num_glyphs, clusters, (int32_t)num_clusters, flags);
}
