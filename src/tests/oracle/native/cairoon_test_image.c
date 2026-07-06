#include "cairoon_test_private.h"

#include <string.h>

enum {
  CAIROON_TEST_IMAGE_BLUE_PAINT = 0,
  CAIROON_TEST_IMAGE_STROKE_LINE = 1,
  CAIROON_TEST_IMAGE_RECTANGLE = 2,
  CAIROON_TEST_IMAGE_BEZIER = 3,
  CAIROON_TEST_IMAGE_TRANSFORM = 4,
  CAIROON_TEST_IMAGE_RGBA_PAINT = 5,
  CAIROON_TEST_IMAGE_LINEAR_GRADIENT = 6,
  CAIROON_TEST_IMAGE_RADIAL_GRADIENT = 7,
  CAIROON_TEST_IMAGE_TEXT_PATH = 8,
  CAIROON_TEST_IMAGE_SHOW_TEXT = 9,
  CAIROON_TEST_IMAGE_GLYPH_PATH = 10,
  CAIROON_TEST_IMAGE_SHOW_GLYPHS = 11,
  CAIROON_TEST_IMAGE_SHOW_TEXT_GLYPHS = 12,
  CAIROON_TEST_IMAGE_SOURCE_SURFACE_OFFSET = 13,
  CAIROON_TEST_IMAGE_MASK_SURFACE_OFFSET = 14,
  CAIROON_TEST_IMAGE_RASTER_SOURCE_PATTERN = 15,
  CAIROON_TEST_IMAGE_DASHED_STROKE = 16,
  CAIROON_TEST_IMAGE_CLIP = 17,
  CAIROON_TEST_IMAGE_OPERATOR_CLEAR = 18,
  CAIROON_TEST_IMAGE_SURFACE_PATTERN_COMBO = 19,
  CAIROON_TEST_IMAGE_LINEAR_PATTERN_COMBO = 20,
  CAIROON_TEST_IMAGE_MESH_PATTERN = 21,
  CAIROON_TEST_IMAGE_GROUP_COMPOSITING = 22,
  CAIROON_TEST_IMAGE_MASK_PATTERN = 23,
  CAIROON_TEST_IMAGE_EVEN_ODD_FILL = 24,
  CAIROON_TEST_IMAGE_RADIAL_PATTERN_COMBO = 25,
  CAIROON_TEST_IMAGE_SURFACE_PATTERN_PAD_BILINEAR = 26,
  CAIROON_TEST_IMAGE_SURFACE_PATTERN_NONE_MATRIX = 27,
  CAIROON_TEST_IMAGE_LINEAR_PATTERN_PAD_BILINEAR = 28,
  CAIROON_TEST_IMAGE_RADIAL_PATTERN_REPEAT_BILINEAR = 29,
  CAIROON_TEST_IMAGE_SURFACE_PATTERN_REPEAT_BILINEAR = 30,
  CAIROON_TEST_IMAGE_LINEAR_PATTERN_NONE_GOOD = 31,
  CAIROON_TEST_IMAGE_RADIAL_PATTERN_PAD_GOOD = 32,
  CAIROON_TEST_IMAGE_MESH_PATTERN_CURVE_COMBO = 33,
  CAIROON_TEST_IMAGE_PATTERN_STACK_COMBO = 34,
  CAIROON_TEST_IMAGE_MESH_MASK_GROUP_COMBO = 35,
  CAIROON_TEST_IMAGE_SURFACE_SOURCE_MASK_GROUP_COMBO = 36
};

static cairo_status_t cairoon_test_draw_argb32_scene(
  cairo_t *cr,
  int32_t scene,
  double width,
  double height) {
  switch (scene) {
    case CAIROON_TEST_IMAGE_BLUE_PAINT:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_IMAGE_STROKE_LINE:
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_move_to(cr, 2.5, 2.5);
      cairo_line_to(cr, width - 2.5, height - 2.5);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_IMAGE_RECTANGLE:
      cairo_rectangle(cr, 2.0, 2.0, width - 6.0, height - 6.0);
      cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 0.75);
      cairo_fill_preserve(cr);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_IMAGE_BEZIER:
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_move_to(cr, 2.0, height - 2.0);
      cairo_curve_to(cr, 5.0, 1.0, width - 5.0, height - 1.0, width - 2.0, 2.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_IMAGE_TRANSFORM:
      cairo_translate(cr, width / 2.0, height / 2.0);
      cairo_rotate(cr, 0.25);
      cairo_scale(cr, 1.2, 0.8);
      cairo_rectangle(cr, -4.0, -3.0, 8.0, 6.0);
      cairo_set_source_rgb(cr, 1.0, 0.5, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_IMAGE_RGBA_PAINT:
      cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.5);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_IMAGE_LINEAR_GRADIENT:
      return cairoon_test_apply_linear_gradient(cr, width, height);
    case CAIROON_TEST_IMAGE_RADIAL_GRADIENT:
      return cairoon_test_apply_radial_gradient(cr, width, height);
    case CAIROON_TEST_IMAGE_TEXT_PATH:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 8.0);
      cairo_move_to(cr, 2.0, 10.0);
      cairo_text_path(cr, "Hi");
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_IMAGE_SHOW_TEXT:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 8.0);
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_move_to(cr, 2.0, 10.0);
      cairo_show_text(cr, "Hi");
      break;
    case CAIROON_TEST_IMAGE_GLYPH_PATH: {
      cairo_glyph_t glyph = {0, 2.0, 12.0};
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 12.0);
      cairo_glyph_path(cr, &glyph, 1);
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_fill(cr);
      break;
    }
    case CAIROON_TEST_IMAGE_SHOW_GLYPHS: {
      cairo_glyph_t glyph = {0, 2.0, 12.0};
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 12.0);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_show_glyphs(cr, &glyph, 1);
      break;
    }
    case CAIROON_TEST_IMAGE_SHOW_TEXT_GLYPHS: {
      const char *text = "a";
      int text_len = (int)strlen(text);
      cairo_glyph_t *glyphs = NULL;
      int num_glyphs = 0;
      cairo_text_cluster_t *clusters = NULL;
      int num_clusters = 0;
      cairo_text_cluster_flags_t flags = 0;

      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 12.0);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_status_t status = cairo_scaled_font_text_to_glyphs(
        cairo_get_scaled_font(cr),
        2.0,
        12.0,
        text,
        text_len,
        &glyphs,
        &num_glyphs,
        &clusters,
        &num_clusters,
        &flags);
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_show_text_glyphs(
          cr,
          text,
          text_len,
          glyphs,
          num_glyphs,
          clusters,
          num_clusters,
          flags);
        status = cairo_status(cr);
      }
      cairo_glyph_free(glyphs);
      cairo_text_cluster_free(clusters);
      return status;
    }
    case CAIROON_TEST_IMAGE_SOURCE_SURFACE_OFFSET: {
      cairo_surface_t *source =
        cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
      cairo_status_t status = cairo_surface_status(source);
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_t *source_cr = cairo_create(source);
        cairo_set_source_rgb(source_cr, 1.0, 0.0, 0.0);
        cairo_rectangle(source_cr, 0.0, 0.0, 1.0, 1.0);
        cairo_fill(source_cr);
        cairo_set_source_rgb(source_cr, 0.0, 1.0, 0.0);
        cairo_rectangle(source_cr, 1.0, 0.0, 1.0, 1.0);
        cairo_fill(source_cr);
        cairo_set_source_rgb(source_cr, 0.0, 0.0, 1.0);
        cairo_rectangle(source_cr, 0.0, 1.0, 1.0, 1.0);
        cairo_fill(source_cr);
        cairo_set_source_rgb(source_cr, 1.0, 1.0, 1.0);
        cairo_rectangle(source_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_fill(source_cr);
        status = cairo_status(source_cr);
        cairo_destroy(source_cr);
      }
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_set_source_surface(cr, source, 7.0, 6.0);
        cairo_paint(cr);
        status = cairo_status(cr);
      }
      cairo_surface_destroy(source);
      return status;
    }
    case CAIROON_TEST_IMAGE_MASK_SURFACE_OFFSET: {
      cairo_surface_t *mask =
        cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
      cairo_status_t status = cairo_surface_status(mask);
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_t *mask_cr = cairo_create(mask);
        cairo_set_source_rgba(mask_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_rectangle(mask_cr, 0.0, 0.0, 1.0, 1.0);
        cairo_fill(mask_cr);
        cairo_set_source_rgba(mask_cr, 1.0, 1.0, 1.0, 0.5);
        cairo_rectangle(mask_cr, 1.0, 0.0, 1.0, 1.0);
        cairo_fill(mask_cr);
        cairo_set_source_rgba(mask_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_rectangle(mask_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_fill(mask_cr);
        status = cairo_status(mask_cr);
        cairo_destroy(mask_cr);
      }
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
        cairo_mask_surface(cr, mask, 7.0, 6.0);
        status = cairo_status(cr);
      }
      cairo_surface_destroy(mask);
      return status;
    }
    case CAIROON_TEST_IMAGE_RASTER_SOURCE_PATTERN:
      return cairoon_test_apply_raster_source_pattern(cr, width, height);
    case CAIROON_TEST_IMAGE_DASHED_STROKE: {
      double dashes[] = {2.0, 2.0};
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
      cairo_set_dash(cr, dashes, 2, 0.0);
      cairo_move_to(cr, 2.0, height / 2.0);
      cairo_line_to(cr, width - 2.0, height / 2.0);
      cairo_stroke(cr);
      break;
    }
    case CAIROON_TEST_IMAGE_CLIP:
      cairo_rectangle(cr, 4.0, 4.0, width - 8.0, height - 8.0);
      cairo_clip(cr);
      cairo_set_source_rgb(cr, 0.0, 1.0, 0.0);
      cairo_paint(cr);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_rectangle(cr, 4.0, 4.0, 4.0, 4.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_IMAGE_OPERATOR_CLEAR:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
      cairo_rectangle(cr, 4.0, 4.0, 8.0, 8.0);
      cairo_fill(cr);
      cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
      cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.5);
      cairo_rectangle(cr, 0.0, 0.0, 8.0, 8.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_IMAGE_SURFACE_PATTERN_COMBO:
      return cairoon_test_apply_surface_pattern_combo(cr, width, height);
    case CAIROON_TEST_IMAGE_LINEAR_PATTERN_COMBO:
      return cairoon_test_apply_linear_pattern_combo(cr, width, height);
    case CAIROON_TEST_IMAGE_MESH_PATTERN:
      return cairoon_test_apply_mesh_pattern(cr);
    case CAIROON_TEST_IMAGE_GROUP_COMPOSITING:
      return cairoon_test_apply_group_compositing(cr, width, height);
    case CAIROON_TEST_IMAGE_MASK_PATTERN:
      return cairoon_test_apply_mask_pattern(cr, width, height);
    case CAIROON_TEST_IMAGE_EVEN_ODD_FILL:
      return cairoon_test_apply_even_odd_fill(cr, width, height);
    case CAIROON_TEST_IMAGE_RADIAL_PATTERN_COMBO:
      return cairoon_test_apply_radial_pattern_combo(cr, width, height);
    case CAIROON_TEST_IMAGE_SURFACE_PATTERN_PAD_BILINEAR:
      return cairoon_test_apply_surface_pattern_pad_bilinear(cr, width, height);
    case CAIROON_TEST_IMAGE_SURFACE_PATTERN_NONE_MATRIX:
      return cairoon_test_apply_surface_pattern_none_matrix(cr, width, height);
    case CAIROON_TEST_IMAGE_LINEAR_PATTERN_PAD_BILINEAR:
      return cairoon_test_apply_linear_pattern_pad_bilinear(cr, width, height);
    case CAIROON_TEST_IMAGE_RADIAL_PATTERN_REPEAT_BILINEAR:
      return cairoon_test_apply_radial_pattern_repeat_bilinear(
        cr,
        width,
        height);
    case CAIROON_TEST_IMAGE_SURFACE_PATTERN_REPEAT_BILINEAR:
      return cairoon_test_apply_surface_pattern_repeat_bilinear(
        cr,
        width,
        height);
    case CAIROON_TEST_IMAGE_LINEAR_PATTERN_NONE_GOOD:
      return cairoon_test_apply_linear_pattern_none_good(cr, width, height);
    case CAIROON_TEST_IMAGE_RADIAL_PATTERN_PAD_GOOD:
      return cairoon_test_apply_radial_pattern_pad_good(cr, width, height);
    case CAIROON_TEST_IMAGE_MESH_PATTERN_CURVE_COMBO:
      return cairoon_test_apply_mesh_pattern_curve_combo(cr, width, height);
    case CAIROON_TEST_IMAGE_PATTERN_STACK_COMBO:
      return cairoon_test_apply_pattern_stack_combo(cr, width, height);
    case CAIROON_TEST_IMAGE_MESH_MASK_GROUP_COMBO:
      return cairoon_test_apply_mesh_mask_group_combo(cr, width, height);
    case CAIROON_TEST_IMAGE_SURFACE_SOURCE_MASK_GROUP_COMBO:
      return cairoon_test_apply_surface_source_mask_group_combo(
        cr,
        width,
        height);
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
  return cairo_status(cr);
}

static moonbit_bytes_t cairoon_test_copy_image_bytes(cairo_surface_t *surface) {
  cairo_surface_flush(surface);
  int32_t height = cairo_image_surface_get_height(surface);
  int32_t stride = cairo_image_surface_get_stride(surface);
  if (height > 0 && stride > INT32_MAX / height) {
    return moonbit_make_bytes(0, 0);
  }
  int32_t len = stride * height;
  unsigned char *data = cairo_image_surface_get_data(surface);
  if (data == NULL || len < 0) {
    return moonbit_make_bytes(0, 0);
  }

  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  if (len > 0) {
    memcpy(bytes, data, (size_t)len);
  }
  return bytes;
}

static moonbit_bytes_t cairoon_test_render_argb32_scene_bytes(
  int32_t scene,
  int32_t width,
  int32_t height) {
  if (width < 0 || height < 0) {
    return moonbit_make_bytes(0, 0);
  }

  cairo_surface_t *surface =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
  if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    return moonbit_make_bytes(0, 0);
  }

  cairo_t *cr = cairo_create(surface);
  cairo_status_t status = cairoon_test_draw_argb32_scene(
    cr,
    scene,
    (double)width,
    (double)height);
  cairo_destroy(cr);
  if (status != CAIRO_STATUS_SUCCESS ||
      cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    return moonbit_make_bytes(0, 0);
  }

  moonbit_bytes_t bytes = cairoon_test_copy_image_bytes(surface);
  cairo_surface_destroy(surface);
  return bytes;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_test_argb32_scene_oracle(
  int32_t scene,
  int32_t width,
  int32_t height) {
  return cairoon_test_render_argb32_scene_bytes(scene, width, height);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_test_argb32_blue_paint_oracle(
  int32_t width,
  int32_t height) {
  return cairoon_test_render_argb32_scene_bytes(
    CAIROON_TEST_IMAGE_BLUE_PAINT,
    width,
    height);
}
