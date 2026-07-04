#ifndef CAIROON_TEST_VECTOR_PRIVATE_H
#define CAIROON_TEST_VECTOR_PRIVATE_H

#include "cairoon_private.h"

#if CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>
#endif
#if CAIRO_HAS_PS_SURFACE
#include <cairo-ps.h>
#endif
#if CAIRO_HAS_SVG_SURFACE
#include <cairo-svg.h>
#endif

enum {
  CAIROON_TEST_VECTOR_PDF = 0,
  CAIROON_TEST_VECTOR_PS = 1,
  CAIROON_TEST_VECTOR_SVG = 2
};

enum {
  CAIROON_TEST_VECTOR_PAINT = 0,
  CAIROON_TEST_VECTOR_STROKE_LINE = 1,
  CAIROON_TEST_VECTOR_RECTANGLE = 2,
  CAIROON_TEST_VECTOR_BEZIER = 3,
  CAIROON_TEST_VECTOR_TRANSFORM = 4,
  CAIROON_TEST_VECTOR_LINEAR_GRADIENT = 5,
  CAIROON_TEST_VECTOR_RADIAL_GRADIENT = 6,
  CAIROON_TEST_VECTOR_TEXT_PATH = 7,
  CAIROON_TEST_VECTOR_SHOW_TEXT = 8,
  CAIROON_TEST_VECTOR_MULTI_PAGE = 9,
  CAIROON_TEST_VECTOR_CLIP = 10,
  CAIROON_TEST_VECTOR_DASH = 11,
  CAIROON_TEST_VECTOR_SURFACE_PATTERN = 12,
  CAIROON_TEST_VECTOR_MASK_SURFACE = 13,
  CAIROON_TEST_VECTOR_MESH_PATTERN = 14,
  CAIROON_TEST_VECTOR_PDF_URI_TAG = 15,
  CAIROON_TEST_VECTOR_PDF_DEST_TAG = 16,
  CAIROON_TEST_VECTOR_PDF_STRUCT_TAG = 17,
  CAIROON_TEST_VECTOR_PDF_DOCUMENT_FEATURES = 18,
  CAIROON_TEST_VECTOR_PS_DSC_FEATURES = 19,
  CAIROON_TEST_VECTOR_SVG_UNIT_FEATURES = 20,
  CAIROON_TEST_VECTOR_PDF_TEXT_DOCUMENT_FEATURES = 21,
  CAIROON_TEST_VECTOR_PDF_URI_TEXT_TAG = 22,
  CAIROON_TEST_VECTOR_PDF_DEST_TEXT_TAG = 23,
  CAIROON_TEST_VECTOR_PDF_STRUCT_TEXT_TAG = 24,
  CAIROON_TEST_VECTOR_TAGGED_MULTI_PAGE_TEXT = 25,
  CAIROON_TEST_VECTOR_MIXED_TAG_VECTOR = 26,
  CAIROON_TEST_VECTOR_LAYERED_MULTI_PAGE = 27,
  CAIROON_TEST_VECTOR_WIDE_MULTI_PAGE_TAG_VECTOR = 28,
  CAIROON_TEST_VECTOR_TAGGED_SHOW_TEXT_GLYPHS = 29,
  CAIROON_TEST_VECTOR_GROUPED_GLYPH_TAG_MULTI_PAGE = 30
};

cairo_status_t cairoon_test_draw_vector_scene(
  cairo_t *cr,
  int32_t scene,
  double width,
  double height);
cairo_status_t cairoon_test_draw_pdf_uri_tag(cairo_t *cr);
cairo_status_t cairoon_test_draw_pdf_dest_tag(cairo_t *cr);
cairo_status_t cairoon_test_draw_pdf_struct_tag(cairo_t *cr);
cairo_status_t cairoon_test_draw_pdf_uri_text_tag(cairo_t *cr);
cairo_status_t cairoon_test_draw_pdf_dest_text_tag(cairo_t *cr);
cairo_status_t cairoon_test_draw_pdf_struct_text_tag(cairo_t *cr);
cairo_status_t cairoon_test_draw_tagged_multi_page_text(cairo_t *cr);
cairo_status_t cairoon_test_draw_mixed_tag_vector(cairo_t *cr);
cairo_status_t cairoon_test_draw_layered_multi_page(cairo_t *cr);
cairo_status_t cairoon_test_draw_wide_multi_page_tag_vector(cairo_t *cr);
cairo_status_t cairoon_test_draw_tagged_show_text_glyphs(cairo_t *cr);
cairo_status_t cairoon_test_draw_grouped_glyph_tag_multi_page(cairo_t *cr);
cairo_status_t cairoon_test_render_pdf_document_features(const char *name);
cairo_status_t cairoon_test_render_pdf_text_document_features(const char *name);
cairo_status_t cairoon_test_render_ps_dsc_features(const char *name);
cairo_status_t cairoon_test_render_svg_unit_features(const char *name);

#endif
