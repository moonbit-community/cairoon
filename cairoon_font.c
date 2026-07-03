#include "cairoon_private.h"

#include <stdint.h>
#include <stdlib.h>

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_font_options_create(void) {
  return cairoon_font_options_wrap_owned(cairo_font_options_create());
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_status(CairoonFontOptions *options) {
  if (options == NULL || options->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_font_options_copy(
  CairoonFontOptions *options,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *copy = cairo_font_options_copy(options->ptr);
  *status_out = cairo_font_options_status(copy);
  return cairoon_font_options_wrap_owned(copy);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_merge(
  CairoonFontOptions *options,
  CairoonFontOptions *other) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_font_options_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_merge(options->ptr, other->ptr);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_options_equal(
  CairoonFontOptions *options,
  CairoonFontOptions *other) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_options_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_font_options_equal(options->ptr, other->ptr) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_font_options_hash(CairoonFontOptions *options) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)cairo_font_options_hash(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_antialias_t cairoon_font_options_get_antialias(CairoonFontOptions *options) {
  return cairo_font_options_get_antialias(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_antialias(
  CairoonFontOptions *options,
  cairo_antialias_t antialias) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_antialias(options->ptr, antialias);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_subpixel_order_t cairoon_font_options_get_subpixel_order(CairoonFontOptions *options) {
  return cairo_font_options_get_subpixel_order(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_subpixel_order(
  CairoonFontOptions *options,
  cairo_subpixel_order_t subpixel_order) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_subpixel_order(options->ptr, subpixel_order);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_hint_style_t cairoon_font_options_get_hint_style(CairoonFontOptions *options) {
  return cairo_font_options_get_hint_style(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_hint_style(
  CairoonFontOptions *options,
  cairo_hint_style_t hint_style) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_hint_style(options->ptr, hint_style);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_hint_metrics_t cairoon_font_options_get_hint_metrics(CairoonFontOptions *options) {
  return cairo_font_options_get_hint_metrics(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_hint_metrics(
  CairoonFontOptions *options,
  cairo_hint_metrics_t hint_metrics) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_hint_metrics(options->ptr, hint_metrics);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_font_options_get_variations(
  CairoonFontOptions *options,
  int32_t *has_variations) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    *has_variations = 0;
    return moonbit_make_bytes(0, 0);
  }
  const char *variations = cairo_font_options_get_variations(options->ptr);
  if (variations == NULL) {
    *has_variations = 0;
    return moonbit_make_bytes(0, 0);
  }
  *has_variations = 1;
  return cairoon_copy_c_string(variations);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_variations(
  CairoonFontOptions *options,
  moonbit_bytes_t variations) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_variations(options->ptr, (const char *)variations);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_clear_variations(CairoonFontOptions *options) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_variations(options->ptr, NULL);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_color_mode_t cairoon_font_options_get_color_mode(CairoonFontOptions *options) {
  return cairo_font_options_get_color_mode(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_mode(
  CairoonFontOptions *options,
  cairo_color_mode_t color_mode) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_color_mode(options->ptr, color_mode);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
uint32_t cairoon_font_options_get_color_palette(CairoonFontOptions *options) {
  return (uint32_t)cairo_font_options_get_color_palette(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_palette(
  CairoonFontOptions *options,
  uint32_t palette_index) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_color_palette(options->ptr, (unsigned int)palette_index);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_custom_palette_color(
  CairoonFontOptions *options,
  uint32_t index,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_custom_palette_color(
    options->ptr,
    (unsigned int)index,
    red,
    green,
    blue,
    alpha);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_get_custom_palette_color(
  CairoonFontOptions *options,
  uint32_t index,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_font_options_get_custom_palette_color(
    options->ptr,
    (unsigned int)index,
    red,
    green,
    blue,
    alpha);
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_toy_font_face_create(
  moonbit_bytes_t family,
  cairo_font_slant_t slant,
  cairo_font_weight_t weight) {
  return cairoon_font_face_wrap_owned(
    cairo_toy_font_face_create((const char *)family, slant, weight));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_face_status(CairoonFontFace *font_face) {
  if (font_face == NULL || font_face->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_font_face_status(font_face->ptr);
}

static cairo_status_t cairoon_toy_font_face_status(CairoonFontFace *font_face) {
  cairo_status_t status = cairoon_font_face_status(font_face);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_font_face_get_type(font_face->ptr) != CAIRO_FONT_TYPE_TOY) {
    return CAIRO_STATUS_FONT_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_face_equal(
  CairoonFontFace *font_face,
  CairoonFontFace *other) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_face_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return font_face->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_font_face_hash(CairoonFontFace *font_face) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)(uintptr_t)font_face->ptr;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_toy_font_face_get_family(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  const char *family = cairo_toy_font_face_get_family(font_face->ptr);
  if (family == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_c_string(family);
}

MOONBIT_FFI_EXPORT
cairo_font_slant_t cairoon_toy_font_face_get_slant(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FONT_SLANT_NORMAL;
  }
  return cairo_toy_font_face_get_slant(font_face->ptr);
}

MOONBIT_FFI_EXPORT
cairo_font_weight_t cairoon_toy_font_face_get_weight(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FONT_WEIGHT_NORMAL;
  }
  return cairo_toy_font_face_get_weight(font_face->ptr);
}

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
  uint32_t *indices,
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

static cairo_scaled_font_t *cairoon_test_create_scaled_font_oracle(void) {
  cairo_font_face_t *font_face = cairo_toy_font_face_create(
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_BOLD);
  if (font_face == NULL) {
    return NULL;
  }
  if (cairo_font_face_status(font_face) != CAIRO_STATUS_SUCCESS) {
    cairo_font_face_destroy(font_face);
    return NULL;
  }

  cairo_font_options_t *options = cairo_font_options_create();
  if (options == NULL) {
    cairo_font_face_destroy(font_face);
    return NULL;
  }
  if (cairo_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    cairo_font_options_destroy(options);
    cairo_font_face_destroy(font_face);
    return NULL;
  }
  cairo_font_options_set_antialias(options, CAIRO_ANTIALIAS_GRAY);

  cairo_matrix_t font_matrix;
  cairo_matrix_t ctm;
  cairo_matrix_init(&font_matrix, 12.0, 0.0, 0.0, 12.0, 0.0, 0.0);
  cairo_matrix_init(&ctm, 2.0, 0.0, 0.0, 3.0, 5.0, 7.0);
  cairo_scaled_font_t *scaled_font = cairo_scaled_font_create(
    font_face,
    &font_matrix,
    &ctm,
    options);
  cairo_font_options_destroy(options);
  cairo_font_face_destroy(font_face);
  if (scaled_font == NULL ||
      cairo_scaled_font_status(scaled_font) != CAIRO_STATUS_SUCCESS) {
    if (scaled_font != NULL) {
      cairo_scaled_font_destroy(scaled_font);
    }
    return NULL;
  }
  return scaled_font;
}

static double *cairoon_test_font_extents_array(
  const cairo_font_extents_t *extents) {
  double *values = moonbit_make_double_array_raw(5);
  values[0] = extents->ascent;
  values[1] = extents->descent;
  values[2] = extents->height;
  values[3] = extents->max_x_advance;
  values[4] = extents->max_y_advance;
  return values;
}

static double *cairoon_test_text_extents_array(
  const cairo_text_extents_t *extents) {
  double *values = moonbit_make_double_array_raw(6);
  values[0] = extents->x_bearing;
  values[1] = extents->y_bearing;
  values[2] = extents->width;
  values[3] = extents->height;
  values[4] = extents->x_advance;
  values[5] = extents->y_advance;
  return values;
}

MOONBIT_FFI_EXPORT
double *cairoon_test_scaled_font_extents_oracle(
  int32_t kind,
  moonbit_bytes_t text) {
  cairo_scaled_font_t *scaled_font = cairoon_test_create_scaled_font_oracle();
  if (scaled_font == NULL) {
    return moonbit_empty_double_array;
  }

  if (kind == 0) {
    cairo_font_extents_t extents;
    cairo_scaled_font_extents(scaled_font, &extents);
    double *values = cairoon_test_font_extents_array(&extents);
    cairo_scaled_font_destroy(scaled_font);
    return values;
  }

  if (kind == 1) {
    if (text == NULL) {
      cairo_scaled_font_destroy(scaled_font);
      return moonbit_empty_double_array;
    }
    cairo_text_extents_t extents;
    cairo_scaled_font_text_extents(scaled_font, (const char *)text, &extents);
    double *values = cairoon_test_text_extents_array(&extents);
    cairo_scaled_font_destroy(scaled_font);
    return values;
  }

  if (kind == 2) {
    cairo_glyph_t glyphs[2] = {
      {0, 1.5, 2.5},
      {1, 10.0, 2.5},
    };
    cairo_text_extents_t extents;
    cairo_scaled_font_glyph_extents(scaled_font, glyphs, 2, &extents);
    double *values = cairoon_test_text_extents_array(&extents);
    cairo_scaled_font_destroy(scaled_font);
    return values;
  }

  cairo_scaled_font_destroy(scaled_font);
  return moonbit_empty_double_array;
}
