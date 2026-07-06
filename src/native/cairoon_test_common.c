#include "cairoon_private.h"

typedef struct {
  cairo_surface_t *source;
} CairoonTestRasterSource;

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

static cairo_status_t cairoon_test_paint_quad_surface(
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

cairo_status_t cairoon_test_apply_group_compositing(
  cairo_t *cr,
  double width,
  double height) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.25);
  cairo_paint(cr);
  cairo_status_t status = cairo_status(cr);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.8);
    cairo_rectangle(cr, 2.0, 2.0, width - 5.0, height - 6.0);
    cairo_fill(cr);
    cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 0.55);
    cairo_rectangle(cr, 5.0, 5.0, width - 7.0, height - 7.0);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pop_group_to_source(cr);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_paint_with_alpha(cr, 0.6);
    status = cairo_status(cr);
  }
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

cairo_status_t cairoon_test_apply_even_odd_fill(
  cairo_t *cr,
  double width,
  double height) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.25);
  cairo_paint(cr);
  cairo_status_t status = cairo_status(cr);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_fill_rule(cr, CAIRO_FILL_RULE_EVEN_ODD);
    cairo_rectangle(cr, 2.0, 2.0, width - 4.0, height - 4.0);
    cairo_rectangle(cr, 5.0, 5.0, width - 10.0, height - 10.0);
    cairo_set_source_rgba(cr, 0.0, 0.85, 0.25, 0.9);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  return status;
}

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

cairo_status_t cairoon_test_apply_mask_surface(cairo_t *cr) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  cairo_t *ctx = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    ctx = cairo_create(surface);
    status = cairo_status(ctx);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 0.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 0.5);
    cairo_rectangle(ctx, 1.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    status = cairo_status(ctx);
  }
  if (ctx != NULL) {
    cairo_destroy(ctx);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_mask_surface(cr, surface, 4.0, 4.0);
    status = cairo_status(cr);
  }
  cairo_surface_destroy(surface);
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
