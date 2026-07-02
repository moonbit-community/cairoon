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
