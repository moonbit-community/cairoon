#include "cairoon_private.h"

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

MOONBIT_FFI_EXPORT
CairoonTextToGlyphs *cairoon_test_scaled_font_text_to_glyphs_oracle(
  double x,
  double y,
  moonbit_bytes_t text) {
  cairo_scaled_font_t *scaled_font = cairoon_test_create_scaled_font_oracle();
  if (scaled_font == NULL) {
    return cairoon_text_to_glyphs_wrap_owned(
      CAIRO_STATUS_NO_MEMORY, NULL, 0, NULL, 0, (cairo_text_cluster_flags_t)0);
  }
  if (text == NULL) {
    cairo_scaled_font_destroy(scaled_font);
    return cairoon_text_to_glyphs_wrap_owned(
      CAIRO_STATUS_NULL_POINTER, NULL, 0, NULL, 0, (cairo_text_cluster_flags_t)0);
  }

  cairo_glyph_t *glyphs = NULL;
  int num_glyphs = 0;
  cairo_text_cluster_t *clusters = NULL;
  int num_clusters = 0;
  cairo_text_cluster_flags_t flags = (cairo_text_cluster_flags_t)0;
  cairo_status_t status = cairo_scaled_font_text_to_glyphs(
    scaled_font,
    x,
    y,
    (const char *)text,
    -1,
    &glyphs,
    &num_glyphs,
    &clusters,
    &num_clusters,
    &flags);
  cairo_scaled_font_destroy(scaled_font);
  return cairoon_text_to_glyphs_wrap_owned(
    status, glyphs, (int32_t)num_glyphs, clusters, (int32_t)num_clusters, flags);
}
