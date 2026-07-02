#include "cairoon_private.h"

#include <stdint.h>
#include <stdlib.h>

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_create(void) {
  return cairoon_region_wrap_owned(cairo_region_create());
}

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_create_rectangle(
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairoon_region_wrap_owned(cairo_region_create_rectangle(&rect));
}

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_create_rectangles(
  int32_t *xs,
  int32_t *ys,
  int32_t *widths,
  int32_t *heights,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (xs == NULL || ys == NULL || widths == NULL || heights == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_region_wrap_owned(NULL);
  }

  int32_t count = (int32_t)Moonbit_array_length(xs);
  if ((int32_t)Moonbit_array_length(ys) != count ||
      (int32_t)Moonbit_array_length(widths) != count ||
      (int32_t)Moonbit_array_length(heights) != count) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    return cairoon_region_wrap_owned(NULL);
  }

  if (count == 0) {
    return cairoon_region_wrap_owned(cairo_region_create());
  }

  if ((size_t)count > SIZE_MAX / sizeof(cairo_rectangle_int_t)) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_region_wrap_owned(NULL);
  }
  cairo_rectangle_int_t *rects =
    (cairo_rectangle_int_t *)malloc((size_t)count * sizeof(cairo_rectangle_int_t));
  if (rects == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_region_wrap_owned(NULL);
  }

  for (int32_t i = 0; i < count; i++) {
    rects[i].x = xs[i];
    rects[i].y = ys[i];
    rects[i].width = widths[i];
    rects[i].height = heights[i];
  }
  cairo_region_t *region = cairo_region_create_rectangles(rects, count);
  free(rects);
  if (region == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_region_wrap_owned(NULL);
  }
  *status_out = cairo_region_status(region);
  return cairoon_region_wrap_owned(region);
}

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_copy(CairoonRegion *region) {
  if (region == NULL || region->ptr == NULL) {
    return cairoon_region_wrap_owned(NULL);
  }
  return cairoon_region_wrap_owned(cairo_region_copy(region->ptr));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_status(CairoonRegion *region) {
  if (region == NULL || region->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_get_extents(
  CairoonRegion *region,
  int32_t *x,
  int32_t *y,
  int32_t *width,
  int32_t *height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect;
  cairo_region_get_extents(region->ptr, &rect);
  *x = rect.x;
  *y = rect.y;
  *width = rect.width;
  *height = rect.height;
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_num_rectangles(CairoonRegion *region) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_region_num_rectangles(region->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_get_rectangle(
  CairoonRegion *region,
  int32_t index,
  int32_t *x,
  int32_t *y,
  int32_t *width,
  int32_t *height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect;
  cairo_region_get_rectangle(region->ptr, index, &rect);
  *x = rect.x;
  *y = rect.y;
  *width = rect.width;
  *height = rect.height;
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_is_empty(CairoonRegion *region) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS) {
    return 1;
  }
  return cairo_region_is_empty(region->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_contains_point(CairoonRegion *region, int32_t x, int32_t y) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_region_contains_point(region->ptr, x, y);
}

MOONBIT_FFI_EXPORT
cairo_region_overlap_t cairoon_region_contains_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_contains_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_equal(CairoonRegion *region, CairoonRegion *other) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS ||
      cairoon_region_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_region_equal(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_translate(CairoonRegion *region, int32_t dx, int32_t dy) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_region_translate(region->ptr, dx, dy);
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_intersect(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_intersect(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_intersect_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_intersect_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_subtract(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_subtract(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_subtract_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_subtract_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_union(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_union(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_union_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_union_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_xor(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_xor(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_xor_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_xor_rectangle(region->ptr, &rect);
}
