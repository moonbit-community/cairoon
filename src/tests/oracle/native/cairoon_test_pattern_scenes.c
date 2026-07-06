#include "cairoon_test_private.h"

cairo_status_t cairoon_test_apply_linear_gradient(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_linear(0.0, 0.0, width, 0.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 0.0, 0.0, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.0, 0.0, 1.0, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}
cairo_status_t cairoon_test_apply_radial_gradient(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_radial(
    width / 2.0,
    height / 2.0,
    1.0,
    width / 2.0,
    height / 2.0,
    width / 2.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 1.0, 1.0, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.0, 0.0, 0.0, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_paint_quad_surface(
  cairo_surface_t *surface) {
  cairo_t *ctx = cairo_create(surface);
  cairo_status_t status = cairo_status(ctx);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(ctx, 1.0, 0.0, 0.0);
    cairo_rectangle(ctx, 0.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgb(ctx, 0.0, 1.0, 0.0);
    cairo_rectangle(ctx, 1.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgb(ctx, 0.0, 0.0, 1.0);
    cairo_rectangle(ctx, 0.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgb(ctx, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    status = cairo_status(ctx);
  }
  cairo_destroy(ctx);
  return status;
}

cairo_status_t cairoon_test_apply_surface_pattern(
  cairo_t *cr,
  double width,
  double height) {
  cairo_surface_t *surface =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_paint_quad_surface(surface);
  }

  cairo_pattern_t *pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }

  if (pattern != NULL) {
    cairo_pattern_destroy(pattern);
  }
  cairo_surface_destroy(surface);
  return status;
}
