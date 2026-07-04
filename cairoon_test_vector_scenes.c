#include "cairoon_test_vector_private.h"

cairo_status_t cairoon_test_draw_vector_scene(
  cairo_t *cr,
  int32_t scene,
  double width,
  double height) {
  switch (scene) {
    case CAIROON_TEST_VECTOR_PAINT:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_VECTOR_STROKE_LINE:
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.5);
      cairo_move_to(cr, 1.5, 1.5);
      cairo_line_to(cr, width - 1.5, height - 1.5);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_VECTOR_RECTANGLE:
      cairo_rectangle(cr, 2.0, 2.0, width - 4.0, height - 4.0);
      cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 0.75);
      cairo_fill_preserve(cr);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_VECTOR_BEZIER:
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.25);
      cairo_move_to(cr, 1.0, height - 1.0);
      cairo_curve_to(
        cr,
        3.0,
        1.0,
        width - 3.0,
        height - 1.0,
        width - 1.0,
        1.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_VECTOR_TRANSFORM:
      cairo_translate(cr, width / 2.0, height / 2.0);
      cairo_rotate(cr, 0.25);
      cairo_scale(cr, 1.2, 0.8);
      cairo_rectangle(cr, -3.0, -2.0, 6.0, 4.0);
      cairo_set_source_rgb(cr, 1.0, 0.5, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_VECTOR_LINEAR_GRADIENT:
      return cairoon_test_apply_linear_gradient(cr, width, height);
    case CAIROON_TEST_VECTOR_RADIAL_GRADIENT:
      return cairoon_test_apply_radial_gradient(cr, width, height);
    case CAIROON_TEST_VECTOR_TEXT_PATH:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 4.0);
      cairo_move_to(cr, 1.0, 6.5);
      cairo_text_path(cr, "Hi");
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_VECTOR_SHOW_TEXT:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 4.0);
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_move_to(cr, 1.0, 6.5);
      cairo_show_text(cr, "Hi");
      break;
    case CAIROON_TEST_VECTOR_MULTI_PAGE:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      cairo_show_page(cr);
      if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
        return cairo_status(cr);
      }
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_paint(cr);
      cairo_show_page(cr);
      break;
    case CAIROON_TEST_VECTOR_CLIP:
      cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
      cairo_clip(cr);
      cairo_set_source_rgb(cr, 0.0, 1.0, 0.0);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_VECTOR_DASH: {
      double dashes[] = {1.0, 1.5};
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.0);
      cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
      cairo_set_dash(cr, dashes, 2, 0.5);
      cairo_move_to(cr, 1.0, height / 2.0);
      cairo_line_to(cr, width - 1.0, height / 2.0);
      cairo_stroke(cr);
      break;
    }
    case CAIROON_TEST_VECTOR_SURFACE_PATTERN:
      return cairoon_test_apply_surface_pattern(cr, width, height);
    case CAIROON_TEST_VECTOR_MASK_SURFACE:
      return cairoon_test_apply_mask_surface(cr);
    case CAIROON_TEST_VECTOR_MESH_PATTERN:
      return cairoon_test_apply_mesh_pattern(cr);
    case CAIROON_TEST_VECTOR_PDF_URI_TAG:
      return cairoon_test_draw_pdf_uri_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_DEST_TAG:
      return cairoon_test_draw_pdf_dest_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_STRUCT_TAG:
      return cairoon_test_draw_pdf_struct_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_URI_TEXT_TAG:
      return cairoon_test_draw_pdf_uri_text_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_DEST_TEXT_TAG:
      return cairoon_test_draw_pdf_dest_text_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_STRUCT_TEXT_TAG:
      return cairoon_test_draw_pdf_struct_text_tag(cr);
    case CAIROON_TEST_VECTOR_TAGGED_MULTI_PAGE_TEXT:
      return cairoon_test_draw_tagged_multi_page_text(cr);
    case CAIROON_TEST_VECTOR_MIXED_TAG_VECTOR:
      return cairoon_test_draw_mixed_tag_vector(cr);
    case CAIROON_TEST_VECTOR_LAYERED_MULTI_PAGE:
      return cairoon_test_draw_layered_multi_page(cr);
    case CAIROON_TEST_VECTOR_WIDE_MULTI_PAGE_TAG_VECTOR:
      return cairoon_test_draw_wide_multi_page_tag_vector(cr);
    case CAIROON_TEST_VECTOR_TAGGED_SHOW_TEXT_GLYPHS:
      return cairoon_test_draw_tagged_show_text_glyphs(cr);
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
  return cairo_status(cr);
}
