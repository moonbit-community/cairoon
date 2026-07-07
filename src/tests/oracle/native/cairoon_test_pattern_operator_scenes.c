#include "cairoon_test_private.h"

cairo_status_t cairoon_test_apply_radial_color_dodge_surface_combo(
  cairo_t *cr,
  double width,
  double height) {
  cairo_surface_t *surface =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_paint_quad_surface(surface);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_set_device_offset(surface, 0.25, -0.30);
    status = cairo_surface_status(surface);
  }

  cairo_pattern_t *surface_pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    surface_pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(surface_pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.62, 0.18, -0.14, 0.58, -0.75, 0.20);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(surface_pattern, CAIRO_FILTER_NEAREST);
    cairo_pattern_set_dither(surface_pattern, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(surface_pattern, &matrix);
    status = cairo_pattern_status(surface_pattern);
  }

  cairo_pattern_t *radial = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    radial = cairo_pattern_create_radial(2.5, 2.0, 0.4, 12.5, 13.5, 7.5);
    status = cairo_pattern_status(radial);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(radial, 0.0, 0.95, 0.95, 0.15, 0.88);
    cairo_pattern_add_color_stop_rgba(radial, 0.45, 0.15, 0.90, 0.80, 0.70);
    cairo_pattern_add_color_stop_rgba(radial, 1.0, 0.80, 0.10, 0.95, 0.82);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.82, -0.10, 0.18, 0.76, -1.20, 0.80);
    cairo_pattern_set_extend(radial, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(radial, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(radial, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(radial, &matrix);
    status = cairo_pattern_status(radial);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.035, 0.030, 0.070);
    cairo_paint(cr);
    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, surface_pattern);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_COLOR_DODGE);
    cairo_set_source(cr, radial);
    cairo_arc(cr, width / 2.0, height * 0.55, 7.0, 0.0, 6.283185307179586);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_set_source_rgba(cr, 0.02, 0.03, 0.06, 0.35);
    cairo_rectangle(cr, 0.0, 0.0, width, 3.0);
    cairo_fill(cr);
    cairo_restore(cr);
    status = cairo_status(cr);
  }

  if (radial != NULL) {
    cairo_pattern_destroy(radial);
  }
  if (surface_pattern != NULL) {
    cairo_pattern_destroy(surface_pattern);
  }
  cairo_surface_destroy(surface);
  return status;
}
