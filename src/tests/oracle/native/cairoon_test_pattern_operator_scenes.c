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

cairo_status_t cairoon_test_apply_linear_hsl_hue_surface_mask_combo(
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
    cairo_surface_set_device_offset(surface, -0.40, 0.35);
    status = cairo_surface_status(surface);
  }

  cairo_pattern_t *surface_pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    surface_pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(surface_pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.72, -0.16, 0.12, 0.68, -1.00, 0.45);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(surface_pattern, CAIRO_FILTER_GOOD);
    cairo_pattern_set_dither(surface_pattern, CAIRO_DITHER_NONE);
    cairo_pattern_set_matrix(surface_pattern, &matrix);
    status = cairo_pattern_status(surface_pattern);
  }

  cairo_pattern_t *linear = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    linear = cairo_pattern_create_linear(0.0, height, width, 0.0);
    status = cairo_pattern_status(linear);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(linear, 0.0, 0.95, 0.12, 0.08, 0.86);
    cairo_pattern_add_color_stop_rgba(linear, 0.38, 0.10, 0.86, 0.42, 0.74);
    cairo_pattern_add_color_stop_rgba(linear, 0.72, 0.10, 0.22, 0.92, 0.80);
    cairo_pattern_add_color_stop_rgba(linear, 1.0, 0.92, 0.90, 0.18, 0.88);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.90, 0.12, -0.18, 0.84, 1.20, -0.60);
    cairo_pattern_set_extend(linear, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(linear, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(linear, CAIRO_DITHER_GOOD);
    cairo_pattern_set_matrix(linear, &matrix);
    status = cairo_pattern_status(linear);
  }

  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_radial(
      width * 0.50,
      height * 0.50,
      1.0,
      width * 0.50,
      height * 0.50,
      8.5);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.08);
    cairo_pattern_add_color_stop_rgba(mask, 0.45, 1.0, 1.0, 1.0, 0.72);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.96);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.88, -0.08, 0.10, 0.92, -0.35, 0.25);
    cairo_pattern_set_extend(mask, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(mask, CAIRO_FILTER_GOOD);
    cairo_pattern_set_dither(mask, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(mask, &matrix);
    status = cairo_pattern_status(mask);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.025, 0.025, 0.055);
    cairo_paint(cr);
    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_push_group(cr);
    cairo_set_source(cr, surface_pattern);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_HSL_HUE);
    cairo_set_source(cr, linear);
    cairo_move_to(cr, 1.0, height - 2.0);
    cairo_curve_to(
      cr,
      width * 0.30,
      1.0,
      width * 0.70,
      height - 1.0,
      width - 1.0,
      2.0);
    cairo_line_to(cr, width - 2.0, height - 2.0);
    cairo_close_path(cr);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 0.16);
    cairo_rectangle(cr, 2.0, 2.0, width - 4.0, 3.0);
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

cairo_status_t cairoon_test_apply_linear_hsl_saturation_surface_group_combo(
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
    cairo_surface_set_device_offset(surface, 0.35, 0.15);
    status = cairo_surface_status(surface);
  }

  cairo_pattern_t *surface_pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    surface_pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(surface_pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.68, 0.14, -0.10, 0.74, -0.55, -0.35);
    cairo_pattern_set_extend(surface_pattern, CAIRO_EXTEND_PAD);
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
    cairo_pattern_add_color_stop_rgba(linear, 0.0, 0.92, 0.12, 0.84, 0.82);
    cairo_pattern_add_color_stop_rgba(linear, 0.30, 0.12, 0.70, 0.95, 0.78);
    cairo_pattern_add_color_stop_rgba(linear, 0.68, 0.90, 0.84, 0.12, 0.74);
    cairo_pattern_add_color_stop_rgba(linear, 1.0, 0.18, 0.94, 0.26, 0.86);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.78, -0.14, 0.16, 0.86, 0.70, -0.90);
    cairo_pattern_set_extend(linear, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(linear, CAIRO_FILTER_GOOD);
    cairo_pattern_set_dither(linear, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(linear, &matrix);
    status = cairo_pattern_status(linear);
  }

  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_radial(
      width * 0.50,
      height * 0.50,
      1.25,
      width * 0.50,
      height * 0.50,
      7.75);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.18);
    cairo_pattern_add_color_stop_rgba(mask, 0.42, 1.0, 1.0, 1.0, 0.78);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.92);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.84, 0.06, -0.12, 0.88, 0.25, -0.15);
    cairo_pattern_set_extend(mask, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(mask, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(mask, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(mask, &matrix);
    status = cairo_pattern_status(mask);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.030, 0.028, 0.060);
    cairo_paint(cr);
    cairo_save(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_clip(cr);
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    cairo_set_source(cr, surface_pattern);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_HSL_SATURATION);
    cairo_set_source(cr, linear);
    cairo_arc(
      cr,
      width * 0.52,
      height * 0.47,
      6.6,
      0.0,
      6.283185307179586);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    cairo_set_source_rgba(cr, 0.08, 0.08, 0.14, 0.30);
    cairo_rectangle(cr, 2.0, 10.0, width - 4.0, 3.0);
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
