#ifndef CAIROON_TEST_VECTOR_PRIVATE_H
#define CAIROON_TEST_VECTOR_PRIVATE_H

#include "cairoon_test_private.h"

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
  CAIROON_TEST_VECTOR_GROUPED_GLYPH_TAG_MULTI_PAGE = 30,
  CAIROON_TEST_VECTOR_COPY_PAGE_RETAINED = 31,
  CAIROON_TEST_VECTOR_GLYPH_PATH = 32,
  CAIROON_TEST_VECTOR_SHOW_GLYPHS = 33,
  CAIROON_TEST_VECTOR_PDF_PAGE_OPERATION_DOCUMENT_FEATURES = 34,
  CAIROON_TEST_VECTOR_BACKEND_STREAM_COMBO = 35,
  CAIROON_TEST_VECTOR_BACKEND_PAGE_COMBO = 36,
  CAIROON_TEST_VECTOR_BACKEND_NESTED_TAGS = 37,
  CAIROON_TEST_VECTOR_BACKEND_PAGE_SEQUENCE = 38,
  CAIROON_TEST_VECTOR_BACKEND_TAG_MATRIX = 39,
  CAIROON_TEST_VECTOR_BACKEND_LIFECYCLE_MATRIX = 40,
  CAIROON_TEST_VECTOR_BACKEND_PAGE_TRANSITION = 41,
  CAIROON_TEST_VECTOR_BACKEND_STATE_STACK = 42,
  CAIROON_TEST_VECTOR_TAGGED_FONT_MATRIX_TEXT = 43,
  CAIROON_TEST_VECTOR_BACKEND_TEXT_STATE_SEQUENCE = 44,
  CAIROON_TEST_VECTOR_BACKEND_DEEP_TAG_TREE = 45,
  CAIROON_TEST_VECTOR_BACKEND_METADATA_OUTLINE = 46,
  CAIROON_TEST_VECTOR_BACKEND_PAGE_OPS = 47,
  CAIROON_TEST_VECTOR_BACKEND_TAG_METADATA = 48,
  CAIROON_TEST_VECTOR_BACKEND_STRUCTURE_SEQUENCE = 49,
  CAIROON_TEST_VECTOR_BACKEND_OUTLINE_SEQUENCE = 50,
  CAIROON_TEST_VECTOR_BACKEND_PATTERN_TAG = 51,
  CAIROON_TEST_VECTOR_BACKEND_ANNOTATION_SEQUENCE = 52,
  CAIROON_TEST_VECTOR_BACKEND_SEMANTIC_INDEX = 53,
  CAIROON_TEST_VECTOR_BACKEND_BOOKMARK_LATTICE = 54,
  CAIROON_TEST_VECTOR_BACKEND_REVISION_LEDGER = 55,
  CAIROON_TEST_VECTOR_BACKEND_ARTICLE_THREAD = 56,
  CAIROON_TEST_VECTOR_BACKEND_REVIEW_DOSSIER = 57,
  CAIROON_TEST_VECTOR_BACKEND_APPENDIX_RUBRIC = 58
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
cairo_status_t cairoon_test_draw_tagged_font_matrix_text(cairo_t *cr);
cairo_status_t cairoon_test_render_pdf_document_features(const char *name);
cairo_status_t cairoon_test_render_pdf_text_document_features(const char *name);
cairo_status_t cairoon_test_render_pdf_page_operation_document_features(
  const char *name);
cairo_status_t cairoon_test_render_backend_stream_combo_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_page_combo_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_nested_tag_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_page_sequence_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_tag_matrix_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_lifecycle_matrix_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_page_transition_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_state_stack_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_text_state_sequence_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_deep_tag_tree_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_metadata_outline_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_page_ops_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_tag_metadata_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_structure_sequence_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_outline_sequence_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_pattern_tag_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_annotation_sequence_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_semantic_index_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_bookmark_lattice_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_revision_ledger_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_article_thread_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_review_dossier_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_backend_appendix_rubric_features(
  int32_t kind,
  const char *name);
cairo_status_t cairoon_test_render_ps_dsc_features(const char *name);
cairo_status_t cairoon_test_render_svg_unit_features(const char *name);

#endif
