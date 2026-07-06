#include "cairoon_test_private.h"

cairo_status_t cairoon_test_apply_surface_pattern_combo(
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
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.75, 0.2, -0.25, 0.8, -1.0, 0.5);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.125, 0.125, 0.125);
    cairo_paint(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
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

cairo_status_t cairoon_test_apply_linear_pattern_combo(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_linear(0.0, 0.0, 4.0, 0.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 0.0, 0.0, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 0.5, 0.0, 1.0, 0.0, 0.75);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.0, 0.0, 1.0, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.6, 0.1, -0.2, 0.9, -2.0, 1.0);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.125, 0.125, 0.125);
    cairo_paint(cr);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_apply_radial_pattern_combo(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern =
    cairo_pattern_create_radial(4.0, 4.0, 1.0, 11.0, 11.0, 6.5);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 0.0, 0.0, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 0.4, 0.0, 1.0, 0.0, 0.65);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.0, 0.0, 1.0, 0.9);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.8, -0.15, 0.25, 0.7, -1.5, 1.25);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REFLECT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_GOOD);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.125, 0.125, 0.125);
    cairo_paint(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_apply_surface_pattern_pad_bilinear(
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
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.55, 0.10, 0.20, 0.65, -1.25, -0.75);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.125, 0.125, 0.125);
    cairo_paint(cr);
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

cairo_status_t cairoon_test_apply_surface_pattern_none_matrix(
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
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.45, -0.05, 0.12, 0.50, -3.0, -2.0);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_NONE);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_NONE);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.08, 0.09, 0.10, 1.0);
    cairo_paint(cr);
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

cairo_status_t cairoon_test_apply_linear_pattern_pad_bilinear(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_linear(2.0, 0.0, 12.0, 16.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 0.95, 0.20, 0.05, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 0.30, 0.20, 0.85, 0.25, 0.80);
    cairo_pattern_add_color_stop_rgba(pattern, 0.75, 0.10, 0.20, 0.95, 0.65);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.98, 0.92, 0.25, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.70, -0.10, 0.15, 0.85, -1.0, 2.0);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_BEST);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.125, 0.125, 0.125);
    cairo_paint(cr);
    cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_apply_radial_pattern_repeat_bilinear(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern =
    cairo_pattern_create_radial(3.0, 3.0, 1.0, 9.0, 10.0, 5.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 0.95, 0.10, 0.10, 0.95);
    cairo_pattern_add_color_stop_rgba(pattern, 0.35, 0.15, 0.85, 0.25, 0.70);
    cairo_pattern_add_color_stop_rgba(pattern, 0.70, 0.10, 0.25, 0.95, 0.65);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.95, 0.95, 0.95, 0.90);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.65, 0.18, -0.12, 0.75, -2.25, 0.40);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_FAST);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.125, 0.125, 0.125);
    cairo_paint(cr);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_apply_surface_pattern_repeat_bilinear(
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
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.70, -0.18, 0.22, 0.58, -0.80, 1.35);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_BILINEAR);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_GOOD);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.05, 0.07, 0.09, 1.0);
    cairo_paint(cr);
    cairo_rectangle(cr, 1.0, 0.0, width - 2.0, height);
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

cairo_status_t cairoon_test_apply_linear_pattern_none_good(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern =
    cairo_pattern_create_linear(-2.0, 1.0, 14.0, 11.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 0.05, 0.10, 0.20, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 0.45, 0.10, 0.90, 0.80, 0.60);
    cairo_pattern_add_color_stop_rgba(pattern, 0.45, 0.95, 0.90, 0.20, 0.80);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.95, 0.10, 0.65, 0.95);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.85, 0.05, -0.18, 0.72, 2.5, -1.0);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_NONE);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_GOOD);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_NONE);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.12, 0.12, 0.14);
    cairo_paint(cr);
    cairo_rectangle(cr, 0.0, 1.0, width, height - 2.0);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

cairo_status_t cairoon_test_apply_radial_pattern_pad_good(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern =
    cairo_pattern_create_radial(2.0, 13.0, 0.5, 12.0, 4.0, 7.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 0.95, 0.25, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 0.25, 0.95, 0.30, 0.10, 0.75);
    cairo_pattern_add_color_stop_rgba(pattern, 0.80, 0.10, 0.20, 0.95, 0.65);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.02, 0.03, 0.08, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.78, -0.08, 0.16, 0.92, -0.60, 1.80);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_PAD);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_GOOD);
    cairo_pattern_set_dither(pattern, CAIRO_DITHER_DEFAULT);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.04, 0.05, 0.08);
    cairo_paint(cr);
    cairo_rectangle(cr, 2.0, 0.0, width - 2.0, height - 1.0);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}
