#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_semantic_index(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Semantic Index");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "toc quote caption tags");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon semantic index");
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
        "SemanticIndex",
        "toc-caption-note");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Transient", "remove-me");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Transient", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Semantic Index");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType SemanticIndex");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize SemanticIndex");
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

static cairo_status_t cairoon_test_pdf_semantic_index_page_setup(
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

static cairo_status_t cairoon_test_semantic_index_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_semantic_toc(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.10, 0.22, 0.42);
  for (int i = 0; i < 3; i++) {
    double y = 44.0 + (double)i * 18.0;
    cairo_rectangle(cr, 18.0, y - 8.0, 78.0, 11.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.95, 0.96, 0.86);
    cairo_move_to(cr, 22.0, y);
    cairo_show_text(cr, i == 0 ? "quote" : (i == 1 ? "figure" : "note"));
    cairo_set_source_rgb(cr, 0.10, 0.22, 0.42);
  }
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_semantic_quote(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.66, 0.20, 0.25, 0.78);
  cairo_rectangle(cr, 18.0, 38.0, 88.0, 26.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 24.0, 54.0);
  cairo_show_text(cr, "quoted text");
  cairo_set_source_rgba(cr, 0.18, 0.46, 0.64, 0.72);
  cairo_arc(cr, 96.0, 86.0, 14.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_semantic_figure(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.20, 0.55, 0.30, 0.78);
  cairo_rectangle(cr, 22.0, 28.0, 74.0, 36.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.98, 0.74, 0.20, 0.82);
  cairo_move_to(cr, 32.0, 56.0);
  cairo_line_to(cr, 58.0, 34.0);
  cairo_line_to(cr, 86.0, 56.0);
  cairo_close_path(cr);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.02, 0.02, 0.02);
  cairo_move_to(cr, 24.0, 86.0);
  cairo_show_text(cr, "caption link");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_semantic_index(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 11.0);

  int root_id = CAIRO_PDF_OUTLINE_ROOT;
  int quote_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_semantic_index_page_setup(
      surface,
      132.0,
      120.0,
      "semantic-toc",
      CAIRO_PDF_OUTLINE_ROOT,
      "semantic toc",
      "page=1 pos=[16 26]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.94, 0.88);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_move_to(cr, 16.0, 26.0);
    cairo_show_text(cr, "semantic index");
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "TOC", "");
    cairo_tag_begin(cr, "TOCI", "");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='semantic-quote'");
    status = cairoon_test_draw_semantic_toc(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Reference");
    cairo_tag_end(cr, "TOCI");
    cairo_tag_end(cr, "TOC");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_semantic_index_page_setup(
      surface,
      126.0,
      124.0,
      "semantic-quote",
      root_id,
      "semantic quote",
      "page=2 pos=[18 86]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &quote_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_semantic_index_resize_non_svg(
      surface,
      kind,
      126.0,
      124.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.88, 0.94, 0.98);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='semantic-quote' x=18 y=86");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Art", "");
    cairo_tag_begin(cr, "BlockQuote", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_draw_semantic_quote(cr);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "BlockQuote");
    cairo_tag_begin(cr, "NonStruct", "");
    cairo_tag_begin(cr, "Note", "");
    cairo_move_to(cr, 20.0, 102.0);
    cairo_show_text(cr, "aside note");
    cairo_tag_end(cr, "Note");
    cairo_tag_end(cr, "NonStruct");
    cairo_tag_end(cr, "Art");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_semantic_index_page_setup(
      surface,
      134.0,
      112.0,
      "semantic-figure",
      quote_id,
      "semantic figure",
      "page=3 pos=[22 86]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_semantic_index_resize_non_svg(
      surface,
      kind,
      134.0,
      112.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.98, 0.92, 0.86);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, "Caption", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/semantic-index/figure'");
    status = cairoon_test_draw_semantic_figure(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Caption");
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_semantic_index_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_semantic_index(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_semantic_index(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_semantic_index_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 132.0, 120.0);
      return cairoon_test_render_backend_semantic_index_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 132.0, 120.0);
      return cairoon_test_render_backend_semantic_index_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 132.0, 120.0);
      return cairoon_test_render_backend_semantic_index_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
