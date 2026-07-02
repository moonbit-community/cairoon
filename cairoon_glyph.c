#include "cairoon_private.h"

#include <stdint.h>
#include <stdlib.h>

cairo_status_t cairoon_glyphs_from_fields(
  uint32_t *indices,
  double *xs,
  double *ys,
  cairo_glyph_t **glyphs_out,
  int *count_out) {
  *glyphs_out = NULL;
  *count_out = 0;
  if (indices == NULL || xs == NULL || ys == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }

  int32_t count = (int32_t)Moonbit_array_length(indices);
  if ((int32_t)Moonbit_array_length(xs) != count ||
      (int32_t)Moonbit_array_length(ys) != count) {
    return CAIRO_STATUS_INVALID_SIZE;
  }
  if (count == 0) {
    return CAIRO_STATUS_SUCCESS;
  }

  if ((size_t)count > SIZE_MAX / sizeof(cairo_glyph_t)) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  cairo_glyph_t *glyphs =
    (cairo_glyph_t *)malloc((size_t)count * sizeof(cairo_glyph_t));
  if (glyphs == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }

  for (int32_t i = 0; i < count; i++) {
    glyphs[i].index = (unsigned long)indices[i];
    glyphs[i].x = xs[i];
    glyphs[i].y = ys[i];
  }

  *glyphs_out = glyphs;
  *count_out = (int)count;
  return CAIRO_STATUS_SUCCESS;
}

cairo_status_t cairoon_text_clusters_from_fields(
  int32_t *num_bytes,
  int32_t *num_glyphs,
  cairo_text_cluster_t **clusters_out,
  int *count_out) {
  *clusters_out = NULL;
  *count_out = 0;
  if (num_bytes == NULL || num_glyphs == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }

  int32_t count = (int32_t)Moonbit_array_length(num_bytes);
  if ((int32_t)Moonbit_array_length(num_glyphs) != count) {
    return CAIRO_STATUS_INVALID_SIZE;
  }
  if (count == 0) {
    return CAIRO_STATUS_SUCCESS;
  }

  if ((size_t)count > SIZE_MAX / sizeof(cairo_text_cluster_t)) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  cairo_text_cluster_t *clusters =
    (cairo_text_cluster_t *)malloc((size_t)count * sizeof(cairo_text_cluster_t));
  if (clusters == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }

  for (int32_t i = 0; i < count; i++) {
    clusters[i].num_bytes = num_bytes[i];
    clusters[i].num_glyphs = num_glyphs[i];
  }

  *clusters_out = clusters;
  *count_out = (int)count;
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_text_to_glyphs_status(CairoonTextToGlyphs *result) {
  if (result == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return result->status;
}

MOONBIT_FFI_EXPORT
int32_t *cairoon_text_to_glyphs_indices(CairoonTextToGlyphs *result) {
  if (result == NULL || result->status != CAIRO_STATUS_SUCCESS ||
      result->num_glyphs <= 0) {
    return moonbit_empty_int32_array;
  }
  int32_t *indices = moonbit_make_int32_array_raw(result->num_glyphs);
  for (int32_t i = 0; i < result->num_glyphs; i++) {
    indices[i] = (int32_t)(uint32_t)result->glyphs[i].index;
  }
  return indices;
}

MOONBIT_FFI_EXPORT
double *cairoon_text_to_glyphs_positions(CairoonTextToGlyphs *result) {
  if (result == NULL || result->status != CAIRO_STATUS_SUCCESS ||
      result->num_glyphs <= 0) {
    return moonbit_empty_double_array;
  }
  if (result->num_glyphs > INT32_MAX / 2) {
    return moonbit_empty_double_array;
  }
  int32_t count = result->num_glyphs * 2;
  double *positions = moonbit_make_double_array_raw(count);
  for (int32_t i = 0; i < result->num_glyphs; i++) {
    int32_t offset = i * 2;
    positions[offset] = result->glyphs[i].x;
    positions[offset + 1] = result->glyphs[i].y;
  }
  return positions;
}

MOONBIT_FFI_EXPORT
int32_t *cairoon_text_to_glyphs_clusters(CairoonTextToGlyphs *result) {
  if (result == NULL || result->status != CAIRO_STATUS_SUCCESS ||
      result->num_clusters <= 0) {
    return moonbit_empty_int32_array;
  }
  if (result->num_clusters > INT32_MAX / 2) {
    return moonbit_empty_int32_array;
  }
  int32_t count = result->num_clusters * 2;
  int32_t *values = moonbit_make_int32_array_raw(count);
  for (int32_t i = 0; i < result->num_clusters; i++) {
    int32_t offset = i * 2;
    values[offset] = result->clusters[i].num_bytes;
    values[offset + 1] = result->clusters[i].num_glyphs;
  }
  return values;
}

MOONBIT_FFI_EXPORT
cairo_text_cluster_flags_t cairoon_text_to_glyphs_flags(
  CairoonTextToGlyphs *result) {
  if (result == NULL || result->status != CAIRO_STATUS_SUCCESS) {
    return (cairo_text_cluster_flags_t)0;
  }
  return result->flags;
}
