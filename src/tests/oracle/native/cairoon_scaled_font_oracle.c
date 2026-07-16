#include "cairoon_test_private.h"

#include <limits.h>
#include <stdlib.h>

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

typedef struct {
  cairo_status_t status;
  cairo_glyph_t *glyphs;
  int num_glyphs;
  cairo_text_cluster_t *clusters;
  int num_clusters;
  cairo_text_cluster_flags_t flags;
} CairoonTestTextToGlyphs;

static CairoonTestTextToGlyphs cairoon_test_text_to_glyphs_oracle_run(
  double x,
  double y,
  moonbit_bytes_t text) {
  CairoonTestTextToGlyphs result = {
    CAIRO_STATUS_NO_MEMORY,
    NULL,
    0,
    NULL,
    0,
    (cairo_text_cluster_flags_t)0,
  };
  cairo_scaled_font_t *scaled_font = cairoon_test_create_scaled_font_oracle();
  if (scaled_font == NULL) {
    return result;
  }
  if (text == NULL) {
    result.status = CAIRO_STATUS_NULL_POINTER;
    cairo_scaled_font_destroy(scaled_font);
    return result;
  }

  result.status = cairo_scaled_font_text_to_glyphs(
    scaled_font,
    x,
    y,
    (const char *)text,
    -1,
    &result.glyphs,
    &result.num_glyphs,
    &result.clusters,
    &result.num_clusters,
    &result.flags);
  cairo_scaled_font_destroy(scaled_font);
  return result;
}

static void cairoon_test_text_to_glyphs_oracle_release(
  CairoonTestTextToGlyphs *result) {
  if (result->glyphs != NULL) {
    cairo_glyph_free(result->glyphs);
    result->glyphs = NULL;
  }
  if (result->clusters != NULL) {
    cairo_text_cluster_free(result->clusters);
    result->clusters = NULL;
  }
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_scaled_font_text_to_glyphs_status_oracle(
  double x,
  double y,
  moonbit_bytes_t text) {
  CairoonTestTextToGlyphs result =
    cairoon_test_text_to_glyphs_oracle_run(x, y, text);
  cairo_status_t status = result.status;
  cairoon_test_text_to_glyphs_oracle_release(&result);
  return status;
}

MOONBIT_FFI_EXPORT
uint64_t *cairoon_test_scaled_font_text_to_glyphs_indices_oracle(
  double x,
  double y,
  moonbit_bytes_t text) {
  CairoonTestTextToGlyphs result =
    cairoon_test_text_to_glyphs_oracle_run(x, y, text);
  if (result.status != CAIRO_STATUS_SUCCESS || result.num_glyphs <= 0 ||
      result.glyphs == NULL) {
    cairoon_test_text_to_glyphs_oracle_release(&result);
    return (uint64_t *)moonbit_empty_int64_array;
  }
  uint64_t *indices =
    (uint64_t *)moonbit_make_int64_array_raw((int32_t)result.num_glyphs);
  for (int i = 0; i < result.num_glyphs; i++) {
    indices[i] = (uint64_t)result.glyphs[i].index;
  }
  cairoon_test_text_to_glyphs_oracle_release(&result);
  return indices;
}

MOONBIT_FFI_EXPORT
double *cairoon_test_scaled_font_text_to_glyphs_positions_oracle(
  double x,
  double y,
  moonbit_bytes_t text) {
  CairoonTestTextToGlyphs result =
    cairoon_test_text_to_glyphs_oracle_run(x, y, text);
  if (result.status != CAIRO_STATUS_SUCCESS || result.num_glyphs <= 0 ||
      result.num_glyphs > INT32_MAX / 2 || result.glyphs == NULL) {
    cairoon_test_text_to_glyphs_oracle_release(&result);
    return moonbit_empty_double_array;
  }
  int32_t count = (int32_t)result.num_glyphs * 2;
  double *positions = moonbit_make_double_array_raw(count);
  for (int i = 0; i < result.num_glyphs; i++) {
    int offset = i * 2;
    positions[offset] = result.glyphs[i].x;
    positions[offset + 1] = result.glyphs[i].y;
  }
  cairoon_test_text_to_glyphs_oracle_release(&result);
  return positions;
}

MOONBIT_FFI_EXPORT
int32_t *cairoon_test_scaled_font_text_to_glyphs_clusters_oracle(
  double x,
  double y,
  moonbit_bytes_t text) {
  CairoonTestTextToGlyphs result =
    cairoon_test_text_to_glyphs_oracle_run(x, y, text);
  if (result.status != CAIRO_STATUS_SUCCESS || result.num_clusters <= 0 ||
      result.num_clusters > INT32_MAX / 2 || result.clusters == NULL) {
    cairoon_test_text_to_glyphs_oracle_release(&result);
    return moonbit_empty_int32_array;
  }
  int32_t count = (int32_t)result.num_clusters * 2;
  int32_t *clusters = moonbit_make_int32_array_raw(count);
  for (int i = 0; i < result.num_clusters; i++) {
    int offset = i * 2;
    clusters[offset] = result.clusters[i].num_bytes;
    clusters[offset + 1] = result.clusters[i].num_glyphs;
  }
  cairoon_test_text_to_glyphs_oracle_release(&result);
  return clusters;
}

MOONBIT_FFI_EXPORT
cairo_text_cluster_flags_t cairoon_test_scaled_font_text_to_glyphs_flags_oracle(
  double x,
  double y,
  moonbit_bytes_t text) {
  CairoonTestTextToGlyphs result =
    cairoon_test_text_to_glyphs_oracle_run(x, y, text);
  cairo_text_cluster_flags_t flags = result.flags;
  cairoon_test_text_to_glyphs_oracle_release(&result);
  return flags;
}

typedef struct {
  int32_t cluster_outputs_null;
} CairoonTestClusterProbe;

static cairo_user_data_key_t cairoon_test_cluster_probe_key;

static cairo_status_t cairoon_test_cluster_probe_text_to_glyphs(
  cairo_scaled_font_t *scaled_font,
  const char *utf8,
  int utf8_len,
  cairo_glyph_t **glyphs,
  int *num_glyphs,
  cairo_text_cluster_t **clusters,
  int *num_clusters,
  cairo_text_cluster_flags_t *cluster_flags) {
  (void)utf8;
  cairo_font_face_t *font_face = cairo_scaled_font_get_font_face(scaled_font);
  CairoonTestClusterProbe *probe = (CairoonTestClusterProbe *)
    cairo_font_face_get_user_data(font_face, &cairoon_test_cluster_probe_key);
  if (probe == NULL) {
    return CAIRO_STATUS_USER_FONT_ERROR;
  }
  probe->cluster_outputs_null =
    clusters == NULL && num_clusters == NULL && cluster_flags == NULL;

  cairo_glyph_t *new_glyphs = cairo_glyph_allocate(1);
  if (new_glyphs == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  new_glyphs[0].index = 1;
  new_glyphs[0].x = 0.0;
  new_glyphs[0].y = 0.0;
  *glyphs = new_glyphs;
  *num_glyphs = 1;

  if (clusters != NULL) {
    if (num_clusters == NULL || cluster_flags == NULL) {
      return CAIRO_STATUS_USER_FONT_ERROR;
    }
    cairo_text_cluster_t *new_clusters = cairo_text_cluster_allocate(1);
    if (new_clusters == NULL) {
      return CAIRO_STATUS_NO_MEMORY;
    }
    new_clusters[0].num_bytes = utf8_len;
    new_clusters[0].num_glyphs = 1;
    *clusters = new_clusters;
    *num_clusters = 1;
    *cluster_flags = (cairo_text_cluster_flags_t)0;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
CairoonScaledFont *cairoon_test_scaled_font_cluster_probe_create(void) {
  cairo_font_face_t *font_face = cairo_user_font_face_create();
  if (font_face == NULL ||
      cairo_font_face_status(font_face) != CAIRO_STATUS_SUCCESS) {
    if (font_face != NULL) {
      cairo_font_face_destroy(font_face);
    }
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  CairoonTestClusterProbe *probe =
    (CairoonTestClusterProbe *)malloc(sizeof(CairoonTestClusterProbe));
  if (probe == NULL) {
    cairo_font_face_destroy(font_face);
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  probe->cluster_outputs_null = -1;
  cairo_status_t status = cairo_font_face_set_user_data(
    font_face,
    &cairoon_test_cluster_probe_key,
    probe,
    free);
  if (status != CAIRO_STATUS_SUCCESS) {
    free(probe);
    cairo_font_face_destroy(font_face);
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  cairo_user_font_face_set_text_to_glyphs_func(
    font_face,
    cairoon_test_cluster_probe_text_to_glyphs);

  cairo_font_options_t *options = cairo_font_options_create();
  cairo_matrix_t identity;
  cairo_matrix_init_identity(&identity);
  cairo_scaled_font_t *scaled_font = cairo_scaled_font_create(
    font_face,
    &identity,
    &identity,
    options);
  cairo_font_options_destroy(options);
  cairo_font_face_destroy(font_face);
  return cairoon_scaled_font_wrap_owned(scaled_font);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_test_scaled_font_cluster_probe_observation(
  CairoonScaledFont *scaled_font) {
  if (scaled_font == NULL || scaled_font->ptr == NULL) {
    return -1;
  }
  cairo_font_face_t *font_face =
    cairo_scaled_font_get_font_face(scaled_font->ptr);
  CairoonTestClusterProbe *probe = (CairoonTestClusterProbe *)
    cairo_font_face_get_user_data(font_face, &cairoon_test_cluster_probe_key);
  return probe == NULL ? -1 : probe->cluster_outputs_null;
}
