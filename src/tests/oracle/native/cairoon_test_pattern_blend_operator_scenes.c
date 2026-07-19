#include "cairoon_test_private.h"

cairo_status_t cairoon_test_apply_gradient_surface_overlay_combo(
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
    cairo_matrix_init(&matrix, 0.58, -0.09, 0.16, 0.53, -1.80, 0.25);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(surface_pattern, CAIRO_FILTER_NEAREST);
    cairoon_test_pattern_set_dither(surface_pattern, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(surface_pattern, &matrix);
    status = cairo_pattern_status(surface_pattern);
  }

  cairo_pattern_t *radial = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    radial = cairo_pattern_create_radial(4.0, 4.0, 0.75, 12.0, 11.0, 8.0);
    status = cairo_pattern_status(radial);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(radial, 0.0, 0.98, 0.92, 0.18, 0.92);
    cairo_pattern_add_color_stop_rgba(radial, 0.42, 0.10, 0.72, 0.85, 0.68);
    cairo_pattern_add_color_stop_rgba(radial, 1.0, 0.04, 0.05, 0.12, 0.88);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.86, 0.12, -0.14, 0.79, 0.75, -1.10);
    cairo_pattern_set_extend(radial, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(radial, CAIRO_FILTER_GOOD);
    cairoon_test_pattern_set_dither(radial, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(radial, &matrix);
    status = cairo_pattern_status(radial);
  }

  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_linear(0.0, height, width, 0.0);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.05);
    cairo_pattern_add_color_stop_rgba(mask, 0.50, 1.0, 1.0, 1.0, 0.62);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.98);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.93, -0.08, 0.11, 0.84, -0.35, 0.70);
    cairo_pattern_set_extend(mask, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(mask, CAIRO_FILTER_GOOD);
    cairoon_test_pattern_set_dither(mask, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(mask, &matrix);
    status = cairo_pattern_status(mask);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.018, 0.030, 0.055);
    cairo_paint(cr);

    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    cairo_set_source(cr, surface_pattern);
    cairo_paint(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVERLAY);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, radial);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_pop_group_to_source(cr);
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
  if (surface_pattern != NULL) {
    cairo_pattern_destroy(surface_pattern);
  }
  cairo_surface_destroy(surface);
  return status;
}

cairo_status_t cairoon_test_apply_mesh_surface_soft_light_combo(
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
    cairo_matrix_init(&matrix, 0.64, 0.09, -0.12, 0.59, -0.90, 0.65);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(surface_pattern, CAIRO_FILTER_BILINEAR);
    cairoon_test_pattern_set_dither(surface_pattern, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(surface_pattern, &matrix);
    status = cairo_pattern_status(surface_pattern);
  }

  cairo_pattern_t *mesh = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mesh = cairo_pattern_create_mesh();
    status = cairo_pattern_status(mesh);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_mesh_pattern_begin_patch(mesh);
    cairo_mesh_pattern_move_to(mesh, 1.0, 1.0);
    cairo_mesh_pattern_curve_to(mesh, 5.0, -1.0, 13.0, 2.0, 15.0, 7.0);
    cairo_mesh_pattern_curve_to(mesh, 12.0, 14.0, 5.0, 16.0, 1.0, 11.0);
    cairo_mesh_pattern_curve_to(mesh, -1.0, 7.0, -1.0, 3.0, 1.0, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(mesh, 0, 0.92, 0.08, 0.12, 0.95);
    cairo_mesh_pattern_set_corner_color_rgba(mesh, 1, 0.08, 0.82, 0.32, 0.82);
    cairo_mesh_pattern_set_corner_color_rgba(mesh, 2, 0.10, 0.24, 0.95, 0.78);
    cairo_mesh_pattern_set_corner_color_rgba(mesh, 3, 0.95, 0.88, 0.10, 0.92);
    cairo_mesh_pattern_end_patch(mesh);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.87, -0.10, 0.13, 0.81, 0.20, 0.50);
    cairo_pattern_set_filter(mesh, CAIRO_FILTER_GOOD);
    cairoon_test_pattern_set_dither(mesh, CAIRO_DITHER_GOOD);
    cairo_pattern_set_matrix(mesh, &matrix);
    status = cairo_pattern_status(mesh);
  }

  cairo_pattern_t *linear = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    linear = cairo_pattern_create_linear(0.0, 3.0, width, height - 3.0);
    status = cairo_pattern_status(linear);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(linear, 0.0, 0.06, 0.08, 0.16, 0.88);
    cairo_pattern_add_color_stop_rgba(linear, 0.33, 0.86, 0.24, 0.14, 0.65);
    cairo_pattern_add_color_stop_rgba(linear, 0.66, 0.16, 0.84, 0.62, 0.72);
    cairo_pattern_add_color_stop_rgba(linear, 1.0, 0.98, 0.92, 0.25, 0.82);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.74, 0.05, -0.16, 0.88, -1.10, 1.50);
    cairo_pattern_set_extend(linear, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(linear, CAIRO_FILTER_BILINEAR);
    cairoon_test_pattern_set_dither(linear, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(linear, &matrix);
    status = cairo_pattern_status(linear);
  }

  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_radial(5.0, 12.0, 0.5, 11.0, 4.0, 9.0);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.08);
    cairo_pattern_add_color_stop_rgba(mask, 0.42, 1.0, 1.0, 1.0, 0.66);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.96);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.91, -0.06, 0.10, 0.83, 0.45, -0.55);
    cairo_pattern_set_extend(mask, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(mask, CAIRO_FILTER_GOOD);
    cairoon_test_pattern_set_dither(mask, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(mask, &matrix);
    status = cairo_pattern_status(mask);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.016, 0.020, 0.046);
    cairo_paint(cr);
    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    cairo_set_source(cr, mesh);
    cairo_paint(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOFT_LIGHT);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, surface_pattern);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_set_source(cr, linear);
    cairo_paint_with_alpha(cr, 0.72);
    cairo_pop_group_to_source(cr);
    cairo_mask(cr, mask);
    cairo_restore(cr);
    status = cairo_status(cr);
  }

  if (mask != NULL) {
    cairo_pattern_destroy(mask);
  }
  if (linear != NULL) {
    cairo_pattern_destroy(linear);
  }
  if (mesh != NULL) {
    cairo_pattern_destroy(mesh);
  }
  if (surface_pattern != NULL) {
    cairo_pattern_destroy(surface_pattern);
  }
  cairo_surface_destroy(surface);
  return status;
}

cairo_status_t cairoon_test_apply_difference_surface_stroke_combo(
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
    cairo_surface_set_device_offset(surface, -0.35, 0.40);
    status = cairo_surface_status(surface);
  }

  cairo_pattern_t *surface_pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    surface_pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(surface_pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.46, 0.12, -0.10, 0.54, -1.50, 0.35);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(surface_pattern, CAIRO_FILTER_BILINEAR);
    cairoon_test_pattern_set_dither(surface_pattern, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(surface_pattern, &matrix);
    status = cairo_pattern_status(surface_pattern);
  }

  cairo_pattern_t *linear = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    linear = cairo_pattern_create_linear(width, 0.0, 0.0, height);
    status = cairo_pattern_status(linear);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(linear, 0.0, 0.04, 0.07, 0.14, 0.94);
    cairo_pattern_add_color_stop_rgba(linear, 0.38, 0.92, 0.32, 0.10, 0.72);
    cairo_pattern_add_color_stop_rgba(linear, 0.72, 0.18, 0.78, 0.58, 0.68);
    cairo_pattern_add_color_stop_rgba(linear, 1.0, 0.90, 0.92, 0.24, 0.86);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.88, -0.09, 0.16, 0.82, -0.45, 1.05);
    cairo_pattern_set_extend(linear, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(linear, CAIRO_FILTER_GOOD);
    cairoon_test_pattern_set_dither(linear, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(linear, &matrix);
    status = cairo_pattern_status(linear);
  }

  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_radial(3.0, 13.0, 0.5, 12.0, 4.0, 8.5);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.04);
    cairo_pattern_add_color_stop_rgba(mask, 0.48, 1.0, 1.0, 1.0, 0.64);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.98);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.90, 0.07, -0.12, 0.85, 0.30, -0.65);
    cairo_pattern_set_extend(mask, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(mask, CAIRO_FILTER_GOOD);
    cairoon_test_pattern_set_dither(mask, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(mask, &matrix);
    status = cairo_pattern_status(mask);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    double dashes[] = {3.0, 1.5};

    cairo_set_source_rgb(cr, 0.018, 0.022, 0.050);
    cairo_paint(cr);
    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    cairo_set_source(cr, linear);
    cairo_paint(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_DIFFERENCE);
    cairo_set_line_width(cr, 3.0);
    cairo_set_line_join(cr, CAIRO_LINE_JOIN_ROUND);
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_SQUARE);
    cairo_set_dash(cr, dashes, 2, 0.75);
    cairo_set_source(cr, surface_pattern);
    cairo_move_to(cr, 2.0, 4.0);
    cairo_curve_to(cr, 6.0, -1.0, 10.0, 17.0, 14.0, 11.0);
    cairo_stroke(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_rectangle(cr, 2.0, 2.0, width - 4.0, height - 4.0);
    cairo_set_source_rgba(cr, 0.90, 0.25, 0.55, 0.45);
    cairo_fill(cr);
    cairo_pop_group_to_source(cr);
    cairo_mask(cr, mask);
    cairo_restore(cr);
    status = cairo_status(cr);
  }

  if (mask != NULL) {
    cairo_pattern_destroy(mask);
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
