#include "cairoon_test_private.h"

typedef struct {
  cairo_surface_t *source;
} CairoonTestRasterSource;

static cairo_surface_t *cairoon_test_raster_source_acquire(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *target,
  const cairo_rectangle_int_t *extents) {
  (void)pattern;
  (void)target;
  (void)extents;
  CairoonTestRasterSource *state =
    (CairoonTestRasterSource *)callback_data;
  if (state == NULL || state->source == NULL) {
    return NULL;
  }
  return cairo_surface_reference(state->source);
}

static void cairoon_test_raster_source_release(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *surface) {
  (void)pattern;
  (void)callback_data;
  cairo_surface_destroy(surface);
}

cairo_status_t cairoon_test_apply_raster_source_pattern(
  cairo_t *cr,
  double width,
  double height) {
  cairo_surface_t *source =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(source);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_paint_quad_surface(source);
  }

  cairo_pattern_t *pattern = NULL;
  CairoonTestRasterSource state = {source};
  if (status == CAIRO_STATUS_SUCCESS) {
    pattern = cairo_pattern_create_raster_source(
      NULL,
      CAIRO_CONTENT_COLOR_ALPHA,
      2,
      2);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_raster_source_pattern_set_callback_data(pattern, &state);
    cairo_raster_source_pattern_set_acquire(
      pattern,
      cairoon_test_raster_source_acquire,
      cairoon_test_raster_source_release);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }

  if (pattern != NULL) {
    cairo_pattern_destroy(pattern);
  }
  cairo_surface_destroy(source);
  return status;
}

cairo_status_t cairoon_test_apply_mesh_pattern(cairo_t *cr) {
  cairo_pattern_t *pattern = cairo_pattern_create_mesh();
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_mesh_pattern_begin_patch(pattern);
    cairo_mesh_pattern_move_to(pattern, 0.0, 0.0);
    cairo_mesh_pattern_line_to(pattern, 10.0, 0.0);
    cairo_mesh_pattern_line_to(pattern, 10.0, 10.0);
    cairo_mesh_pattern_line_to(pattern, 0.0, 10.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 0, 1.0, 0.0, 0.0, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 1, 0.0, 1.0, 0.0, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 2, 0.0, 0.0, 1.0, 0.75);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 3, 1.0, 1.0, 0.0, 1.0);
    cairo_mesh_pattern_end_patch(pattern);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, 10.0, 10.0);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}
