#include "cairoon_test_private.h"

cairo_status_t cairoon_test_apply_mesh_pattern_curve_combo(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_mesh();
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_mesh_pattern_begin_patch(pattern);
    cairo_mesh_pattern_move_to(pattern, 1.0, 1.0);
    cairo_mesh_pattern_curve_to(pattern, 6.0, -2.0, 12.0, 4.0, 14.0, 2.0);
    cairo_mesh_pattern_curve_to(pattern, 15.0, 7.0, 11.0, 14.0, 8.0, 15.0);
    cairo_mesh_pattern_curve_to(pattern, 3.0, 13.0, -1.0, 9.0, 1.0, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 0, 0.95, 0.10, 0.05, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 1, 0.10, 0.85, 0.20, 0.85);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 2, 0.10, 0.20, 0.95, 0.75);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 3, 0.95, 0.90, 0.10, 1.0);
    cairo_mesh_pattern_set_control_point(pattern, 0, 4.0, 3.0);
    cairo_mesh_pattern_set_control_point(pattern, 1, 11.0, 2.0);
    cairo_mesh_pattern_end_patch(pattern);

    cairo_mesh_pattern_begin_patch(pattern);
    cairo_mesh_pattern_move_to(pattern, 4.0, 4.0);
    cairo_mesh_pattern_line_to(pattern, 14.0, 6.0);
    cairo_mesh_pattern_line_to(pattern, 10.0, 14.0);
    cairo_mesh_pattern_line_to(pattern, 2.0, 10.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 0, 0.00, 0.00, 0.00, 0.60);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 1, 1.00, 1.00, 1.00, 0.40);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 2, 0.95, 0.20, 0.70, 0.65);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 3, 0.20, 0.95, 0.95, 0.70);
    cairo_mesh_pattern_end_patch(pattern);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.90, 0.10, -0.08, 0.85, 0.50, -0.50);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.03, 0.04, 0.08);
    cairo_paint(cr);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_apply_pattern_stack_combo(
  cairo_t *cr,
  double width,
  double height) {
  cairo_surface_t *surface =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_paint_quad_surface(surface);
  }

  cairo_pattern_t *surface_pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    surface_pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(surface_pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.50, 0.18, -0.16, 0.62, -1.40, 0.90);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(surface_pattern, CAIRO_FILTER_NEAREST);
    cairo_pattern_set_dither(surface_pattern, CAIRO_DITHER_GOOD);
    cairo_pattern_set_matrix(surface_pattern, &matrix);
    status = cairo_pattern_status(surface_pattern);
  }

  cairo_pattern_t *linear = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    linear = cairo_pattern_create_linear(0.0, 0.0, width, height);
    status = cairo_pattern_status(linear);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(linear, 0.0, 0.90, 0.12, 0.05, 0.95);
    cairo_pattern_add_color_stop_rgba(linear, 0.40, 0.10, 0.80, 0.35, 0.70);
    cairo_pattern_add_color_stop_rgba(linear, 1.0, 0.08, 0.18, 0.95, 0.85);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.82, -0.12, 0.20, 0.74, -0.60, 1.40);
    cairo_pattern_set_extend(linear, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(linear, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(linear, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(linear, &matrix);
    status = cairo_pattern_status(linear);
  }

  cairo_pattern_t *radial = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    radial = cairo_pattern_create_radial(4.0, 12.0, 0.75, 13.0, 3.0, 7.0);
    status = cairo_pattern_status(radial);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(radial, 0.0, 1.0, 0.95, 0.20, 1.0);
    cairo_pattern_add_color_stop_rgba(radial, 0.55, 0.90, 0.10, 0.60, 0.68);
    cairo_pattern_add_color_stop_rgba(radial, 1.0, 0.02, 0.04, 0.12, 1.0);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.76, 0.08, -0.18, 0.88, 1.25, -0.75);
    cairo_pattern_set_extend(radial, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(radial, CAIRO_FILTER_GOOD);
    cairo_pattern_set_dither(radial, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(radial, &matrix);
    status = cairo_pattern_status(radial);
  }

  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_linear(0.0, height, width, 0.0);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.0);
    cairo_pattern_add_color_stop_rgba(mask, 0.45, 1.0, 1.0, 1.0, 0.45);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.95);
    status = cairo_pattern_status(mask);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.02, 0.03, 0.06);
    cairo_paint(cr);

    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_set_source(cr, surface_pattern);
    cairo_paint(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_ATOP);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, linear);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_restore(cr);

    cairo_save(cr);
    cairo_rectangle(cr, 3.0, 2.0, width - 6.0, height - 4.0);
    cairo_clip(cr);
    cairo_set_source(cr, radial);
    cairo_paint(cr);
    cairo_restore(cr);

    cairo_save(cr);
    cairo_rectangle(cr, 2.0, 3.0, width - 4.0, height - 6.0);
    cairo_clip(cr);
    cairo_set_source_rgba(cr, 1.0, 0.65, 0.10, 0.85);
    cairo_mask(cr, mask);
    cairo_restore(cr);

    status = cairo_status(cr);
  }

  if (mask != NULL) {
    cairo_pattern_destroy(mask);
  }
  if (radial != NULL) {
    cairo_pattern_destroy(radial);
  }
  if (linear != NULL) {
    cairo_pattern_destroy(linear);
  }
  if (surface_pattern != NULL) {
    cairo_pattern_destroy(surface_pattern);
  }
  cairo_surface_destroy(surface);
  return status;
}

cairo_status_t cairoon_test_apply_mask_pattern(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *mask =
    cairo_pattern_create_linear(0.0, 0.0, width, height);
  cairo_status_t status = cairo_pattern_status(mask);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.0);
    cairo_pattern_add_color_stop_rgba(mask, 0.45, 1.0, 1.0, 1.0, 0.35);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 1.0);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.25);
    cairo_paint(cr);
    cairo_rectangle(cr, 2.0, 2.0, width - 4.0, height - 4.0);
    cairo_clip(cr);
    cairo_set_source_rgba(cr, 1.0, 0.25, 0.0, 0.9);
    cairo_mask(cr, mask);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(mask);
  return status;
}
