#include "cairoon_test_vector_private.h"

#include <string.h>

static cairo_status_t cairoon_test_tag_matrix_show_text_glyphs(
  cairo_t *cr,
  double x,
  double y,
  const char *text) {
  int text_len = (int)strlen(text);
  cairo_glyph_t *glyphs = NULL;
  int num_glyphs = 0;
  cairo_text_cluster_t *clusters = NULL;
  int num_clusters = 0;
  cairo_text_cluster_flags_t flags = 0;

  cairo_status_t status = cairo_scaled_font_text_to_glyphs(
    cairo_get_scaled_font(cr),
    x,
    y,
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

static cairo_status_t cairoon_test_configure_backend_tag_matrix(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Tag Matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon matrix author");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "nested tags with resized pages");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "matrix,nested,sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon tag matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairoon_test_pdf_surface_set_custom_metadata(
        surface,
        "Matrix",
        "nested-resized-tags");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Phase", "draft");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Phase", "published");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", "remove-me");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Tag Matrix");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType MatrixPlain");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize Matrix");
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      cairo_svg_surface_restrict_to_version(surface, CAIRO_SVG_VERSION_1_2);
      cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_PT);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

static cairo_status_t cairoon_test_pdf_tag_matrix_page_setup(
  cairo_surface_t *surface,
  double width,
  double height,
  const char *label,
  int parent_id,
  const char *title,
  const char *link_attributes,
  cairo_pdf_outline_flags_t flags,
  int *outline_id) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_pdf_surface_set_size(surface, width, height);
  cairo_pdf_surface_set_page_label(surface, label);
  int id = cairo_pdf_surface_add_outline(
    surface,
    parent_id,
    title,
    link_attributes,
    flags);
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS && outline_id != NULL) {
    *outline_id = id;
  }
  return status;
#else
  (void)surface;
  (void)width;
  (void)height;
  (void)label;
  (void)parent_id;
  (void)title;
  (void)link_attributes;
  (void)flags;
  (void)outline_id;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

static cairo_status_t cairoon_test_tag_matrix_resize_non_pdf(
  cairo_surface_t *surface,
  int32_t kind,
  double width,
  double height) {
  if (kind == CAIROON_TEST_VECTOR_PS) {
#if CAIRO_HAS_PS_SURFACE
    cairo_ps_surface_set_size(surface, width, height);
    return cairo_surface_status(surface);
#else
    return CAIRO_STATUS_INVALID_STATUS;
#endif
  }
  (void)surface;
  (void)width;
  (void)height;
  return CAIRO_STATUS_SUCCESS;
}

static cairo_status_t cairoon_test_draw_backend_tag_matrix(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 12.0);

  int root_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_matrix_page_setup(
      surface,
      144.0,
      108.0,
      "matrix-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "matrix cover",
      "page=1 pos=[14 24]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.94, 1.0);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/tag-matrix'");
    cairo_move_to(cr, 14.0, 24.0);
    cairo_show_text(cr, "matrix cover");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "Figure", "");
    cairo_set_source_rgb(cr, 0.12, 0.42, 0.74);
    cairo_rectangle(cr, 14.0, 40.0, 54.0, 24.0);
    cairo_fill(cr);
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_matrix_page_setup(
      surface,
      108.0,
      144.0,
      "matrix-retained",
      root_id,
      "matrix retained child",
      "page=2 pos=[14 58]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_tag_matrix_resize_non_pdf(surface, kind, 108.0, 144.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.86, 0.12, 0.16, 0.62);
    cairo_rectangle(cr, 14.0, 52.0, 70.0, 28.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.05, 0.05, 0.05);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='matrix-dest'");
    cairo_move_to(cr, 14.0, 92.0);
    cairo_show_text(cr, "retained matrix link");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_matrix_page_setup(
      surface,
      144.0,
      108.0,
      "matrix-nested",
      root_id,
      "matrix nested child",
      "page=3 pos=[16 32]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_tag_matrix_resize_non_pdf(surface, kind, 144.0, 108.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.92, 0.86);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.10, 0.45, 0.20);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='matrix-dest' x=16 y=32");
    cairo_arc(cr, 28.0, 32.0, 14.0, 0.0, 6.283185307179586);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "L", "");
    cairo_tag_begin(cr, "LI", "");
    cairo_tag_begin(cr, "LBody", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_tag_matrix_show_text_glyphs(
      cr,
      16.0,
      72.0,
      "matrix glyph");
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "LBody");
    cairo_tag_end(cr, "LI");
    cairo_tag_end(cr, "L");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_matrix_page_setup(
      surface,
      90.0,
      132.0,
      "matrix-final",
      CAIRO_PDF_OUTLINE_ROOT,
      "matrix final",
      "page=4 pos=[10 40]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_tag_matrix_resize_non_pdf(surface, kind, 90.0, 132.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.15, 0.22, 0.80, 0.55);
    cairo_rectangle(cr, 10.0, 86.0, 62.0, 24.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Div", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/tag-matrix/final'");
    cairo_move_to(cr, 10.0, 40.0);
    cairo_show_text(cr, "matrix final");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Div");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }
  return status;
}

static cairo_status_t cairoon_test_render_backend_tag_matrix_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_tag_matrix(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_tag_matrix(surface, cr, kind);
  }

  if (cr != NULL) {
    cairo_destroy(cr);
  }
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
}

cairo_status_t cairoon_test_render_backend_tag_matrix_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 144.0, 108.0);
      return cairoon_test_render_backend_tag_matrix_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 144.0, 108.0);
      return cairoon_test_render_backend_tag_matrix_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 144.0, 108.0);
      return cairoon_test_render_backend_tag_matrix_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
