#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_article_thread(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Article Thread");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon backend oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "draft article thread");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "final article thread");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "article,thread,aside,note");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon article thread");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_custom_metadata(surface, "Thread", "draft");
      cairo_pdf_surface_set_custom_metadata(surface, "Thread", "final");
      cairo_pdf_surface_set_custom_metadata(surface, "Transient", "drop-me");
      cairo_pdf_surface_set_custom_metadata(surface, "Transient", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Article Thread");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType ArticleThread");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize ArticleThread");
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

static cairo_status_t cairoon_test_pdf_article_thread_page_setup(
  cairo_surface_t *surface,
  double width,
  double height,
  const char *label,
  int parent_id,
  const char *title,
  const char *link_attributes,
  cairo_pdf_outline_flags_t flags,
  int *outline_id) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
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

static cairo_status_t cairoon_test_article_thread_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_article_thread_intro(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.10, 0.36, 0.62, 0.78);
  cairo_rectangle(cr, 14.0, 34.0, 96.0, 20.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.96, 0.86);
  cairo_move_to(cr, 18.0, 48.0);
  cairo_show_text(cr, "article intro");
  cairo_set_source_rgba(cr, 0.70, 0.22, 0.30, 0.62);
  cairo_arc(cr, 106.0, 70.0, 12.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_article_thread_aside(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.14, 0.48, 0.30, 0.76);
  cairo_rectangle(cr, 18.0, 48.0, 108.0, 20.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.02, 0.02, 0.02);
  cairo_move_to(cr, 22.0, 62.0);
  cairo_show_text(cr, "aside note");
  cairo_set_source_rgba(cr, 0.70, 0.48, 0.14, 0.70);
  cairo_move_to(cr, 22.0, 80.0);
  cairo_line_to(cr, 70.0, 58.0);
  cairo_line_to(cr, 124.0, 80.0);
  cairo_stroke(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_article_thread_figure(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.44, 0.24, 0.62, 0.72);
  cairo_rectangle(cr, 20.0, 40.0, 86.0, 22.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.18, 0.54, 0.66, 0.72);
  cairo_rectangle(cr, 20.0, 70.0, 86.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.02, 0.02, 0.02);
  cairo_move_to(cr, 24.0, 55.0);
  cairo_show_text(cr, "figure");
  cairo_move_to(cr, 24.0, 84.0);
  cairo_show_text(cr, "caption");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_article_thread(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 10.0);

  int intro_id = CAIRO_PDF_OUTLINE_ROOT;
  int note_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_article_thread_page_setup(
      surface,
      132.0,
      96.0,
      "article-intro",
      CAIRO_PDF_OUTLINE_ROOT,
      "article intro",
      "page=1 pos=[12 28]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &intro_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.97, 0.91);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Art", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/article-thread/intro'");
    cairo_move_to(cr, 12.0, 28.0);
    cairo_show_text(cr, "article thread");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_draw_article_thread_intro(cr);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Art");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_article_thread_page_setup(
      surface,
      144.0,
      108.0,
      "article-note",
      intro_id,
      "article note",
      "page=2 pos=[20 68]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &note_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_article_thread_resize_non_svg(
      surface,
      kind,
      144.0,
      108.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='article-thread-note' x=20 y=68");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Art", "");
    cairo_tag_begin(cr, "BlockQuote", "");
    cairo_tag_begin(cr, "Note", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_draw_article_thread_aside(cr);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Note");
    cairo_tag_end(cr, "BlockQuote");
    cairo_tag_end(cr, "Art");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_article_thread_page_setup(
      surface,
      126.0,
      116.0,
      "article-figure",
      note_id,
      "article figure",
      "page=3 pos=[20 98]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_article_thread_resize_non_svg(
      surface,
      kind,
      126.0,
      116.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.92, 0.98, 0.95);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Art", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='article-thread-note'");
    status = cairoon_test_draw_article_thread_figure(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_begin(cr, "Caption", "");
    cairo_move_to(cr, 20.0, 98.0);
    cairo_show_text(cr, "article caption");
    cairo_tag_end(cr, "Caption");
    cairo_tag_end(cr, "Figure");
    cairo_tag_begin(cr, "Reference", "");
    cairo_move_to(cr, 20.0, 108.0);
    cairo_show_text(cr, "see article note");
    cairo_tag_end(cr, "Reference");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Art");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_article_thread_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_article_thread(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_article_thread(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_article_thread_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      surface = cairo_pdf_surface_create(name, 132.0, 96.0);
      return cairoon_test_render_backend_article_thread_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 132.0, 96.0);
      return cairoon_test_render_backend_article_thread_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 132.0, 96.0);
      return cairoon_test_render_backend_article_thread_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
