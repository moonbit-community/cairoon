#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_appendix_rubric(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Appendix Rubric");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon backend oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "draft appendix rubric");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "final appendix rubric");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "appendix,rubric,code,formula");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon appendix rubric");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_custom_metadata(surface, "Rubric", "draft");
      cairo_pdf_surface_set_custom_metadata(surface, "Rubric", "final");
      cairo_pdf_surface_set_custom_metadata(surface, "Obsolete", "drop-me");
      cairo_pdf_surface_set_custom_metadata(surface, "Obsolete", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Appendix Rubric");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType AppendixRubric");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize AppendixRubric");
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

static cairo_status_t cairoon_test_pdf_appendix_rubric_page_setup(
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

static cairo_status_t cairoon_test_appendix_rubric_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_appendix_index(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.18, 0.26, 0.58, 0.78);
  cairo_rectangle(cr, 16.0, 40.0, 92.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.96, 0.96, 0.88);
  cairo_move_to(cr, 20.0, 53.0);
  cairo_show_text(cr, "index link");
  cairo_set_source_rgba(cr, 0.58, 0.22, 0.36, 0.72);
  cairo_arc(cr, 104.0, 74.0, 12.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_appendix_code(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.20, 0.44, 0.34, 0.78);
  cairo_rectangle(cr, 18.0, 34.0, 104.0, 26.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.98, 0.88);
  cairo_move_to(cr, 22.0, 50.0);
  cairo_show_text(cr, "let score = 42");
  cairo_set_source_rgba(cr, 0.62, 0.38, 0.16, 0.76);
  cairo_rectangle(cr, 26.0, 70.0, 88.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 30.0, 83.0);
  cairo_show_text(cr, "x+y=z");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_appendix_bibliography(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.42, 0.25, 0.62, 0.74);
  cairo_rectangle(cr, 18.0, 32.0, 100.0, 22.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.18, 0.50, 0.62, 0.72);
  cairo_rectangle(cr, 18.0, 64.0, 100.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.98, 0.88);
  cairo_move_to(cr, 22.0, 47.0);
  cairo_show_text(cr, "figure caption");
  cairo_move_to(cr, 22.0, 77.0);
  cairo_show_text(cr, "bib entry");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_appendix_rubric(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 10.0);

  int index_id = CAIRO_PDF_OUTLINE_ROOT;
  int code_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_appendix_rubric_page_setup(
      surface,
      128.0,
      104.0,
      "appendix-index",
      CAIRO_PDF_OUTLINE_ROOT,
      "appendix index",
      "page=1 pos=[16 28]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &index_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.95, 0.94, 0.88);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Index", "");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/appendix-rubric'");
    cairo_move_to(cr, 16.0, 28.0);
    cairo_show_text(cr, "appendix rubric");
    status = cairoon_test_draw_appendix_index(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Reference");
    cairo_tag_end(cr, "Index");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_copy_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_appendix_rubric_page_setup(
      surface,
      142.0,
      116.0,
      "appendix-code",
      index_id,
      "appendix code",
      "page=2 pos=[18 48]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &code_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_appendix_rubric_resize_non_svg(
      surface,
      kind,
      142.0,
      116.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.96, 0.92);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='appendix-code' x=18 y=48");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Code", "");
    cairo_move_to(cr, 18.0, 28.0);
    cairo_show_text(cr, "code sample");
    cairo_tag_end(cr, "Code");
    cairo_tag_begin(cr, "Formula", "");
    status = cairoon_test_draw_appendix_code(cr);
    cairo_tag_end(cr, "Formula");
    cairo_tag_end(cr, "Sect");
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
    status = cairoon_test_pdf_appendix_rubric_page_setup(
      surface,
      150.0,
      96.0,
      "appendix-bibliography",
      code_id,
      "appendix bibliography",
      "page=3 pos=[18 40]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_appendix_rubric_resize_non_svg(
      surface,
      kind,
      150.0,
      96.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.92, 0.98);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, "Caption", "");
    cairo_move_to(cr, 18.0, 24.0);
    cairo_show_text(cr, "caption");
    cairo_tag_end(cr, "Caption");
    cairo_tag_begin(cr, "BlockQuote", "");
    cairo_tag_begin(cr, "BibEntry", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='appendix-code'");
    status = cairoon_test_draw_appendix_bibliography(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "BibEntry");
    cairo_tag_end(cr, "BlockQuote");
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
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

static cairo_status_t cairoon_test_render_backend_appendix_rubric_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_appendix_rubric(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_appendix_rubric(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_appendix_rubric_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      surface = cairo_pdf_surface_create(name, 128.0, 104.0);
      return cairoon_test_render_backend_appendix_rubric_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 128.0, 104.0);
      return cairoon_test_render_backend_appendix_rubric_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 128.0, 104.0);
      return cairoon_test_render_backend_appendix_rubric_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
