#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_accessibility_index(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Accessibility Index");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon accessibility index");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "tagged index metadata");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "accessibility,index,outline,tags");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon accessibility index");
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
        "AccessibilityIndex",
        "accessibility-index-64");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Draft", "remove-me");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Draft", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%Title: Cairoon Accessibility Index");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType AccessibilityIndex");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize AccessibilityIndex");
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      cairo_svg_surface_restrict_to_version(surface, CAIRO_SVG_VERSION_1_2);
      cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_PX);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

static cairo_status_t cairoon_test_pdf_accessibility_index_page_setup(
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

static cairo_status_t cairoon_test_accessibility_index_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_accessibility_overview(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.12, 0.30, 0.58, 0.84);
  cairo_rectangle(cr, 14.0, 30.0, 88.0, 22.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.94, 0.82, 0.28, 0.78);
  cairo_rectangle(cr, 24.0, 58.0, 58.0, 10.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.05, 0.05, 0.05);
  cairo_move_to(cr, 18.0, 24.0);
  cairo_show_text(cr, "access index");
  cairo_move_to(cr, 26.0, 66.0);
  cairo_show_text(cr, "summary");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_accessibility_terms(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.22, 0.52, 0.44, 0.86);
  cairo_rectangle(cr, 18.0, 34.0, 104.0, 24.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.72, 0.20, 0.54, 0.64);
  cairo_arc(cr, 118.0, 74.0, 10.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 24.0, 50.0);
  cairo_show_text(cr, "terms");
  cairo_move_to(cr, 30.0, 78.0);
  cairo_show_text(cr, "alpha beta");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_accessibility_notes(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.50, 0.24, 0.66, 0.82);
  cairo_rectangle(cr, 16.0, 30.0, 94.0, 26.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.24, 0.54, 0.78, 0.68);
  cairo_rectangle(cr, 32.0, 64.0, 76.0, 12.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.96, 0.88);
  cairo_move_to(cr, 24.0, 47.0);
  cairo_show_text(cr, "note");
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 36.0, 72.0);
  cairo_show_text(cr, "caption");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_accessibility_index(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 10.0);

  int root_id = CAIRO_PDF_OUTLINE_ROOT;
  int terms_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_accessibility_index_page_setup(
      surface,
      118.0,
      86.0,
      "access-overview",
      CAIRO_PDF_OUTLINE_ROOT,
      "accessibility overview",
      "page=1 pos=[18 24]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.97, 0.95, 0.89);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/accessibility/index'");
    status = cairoon_test_draw_accessibility_overview(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "L", "");
    cairo_tag_begin(cr, "LI", "");
    cairo_tag_begin(cr, "Lbl", "");
    cairo_move_to(cr, 18.0, 74.0);
    cairo_show_text(cr, "1");
    cairo_tag_end(cr, "Lbl");
    cairo_tag_begin(cr, "LBody", "");
    cairo_move_to(cr, 28.0, 74.0);
    cairo_show_text(cr, "overview");
    cairo_tag_end(cr, "LBody");
    cairo_tag_end(cr, "LI");
    cairo_tag_end(cr, "L");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_accessibility_index_page_setup(
      surface,
      142.0,
      104.0,
      "access-terms",
      root_id,
      "term index",
      "page=2 pos=[24 50]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &terms_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_accessibility_index_resize_non_svg(
      surface,
      kind,
      142.0,
      104.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.89, 0.96, 0.94);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='access-terms' x=24 y=50");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Index", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_draw_accessibility_terms(cr);
    cairo_tag_end(cr, "Span");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='access-notes'");
    cairo_move_to(cr, 72.0, 88.0);
    cairo_show_text(cr, "notes");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Reference");
    cairo_tag_end(cr, "Index");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_accessibility_index_page_setup(
      surface,
      128.0,
      96.0,
      "access-notes",
      terms_id,
      "accessibility notes",
      "page=3 pos=[22 48]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_accessibility_index_resize_non_svg(
      surface,
      kind,
      128.0,
      96.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.91, 0.97);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='access-notes' x=22 y=48");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Note", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, "Caption", "");
    status = cairoon_test_draw_accessibility_notes(cr);
    cairo_tag_end(cr, "Caption");
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Note");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
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

static cairo_status_t cairoon_test_render_backend_accessibility_index_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_accessibility_index(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_accessibility_index(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_accessibility_index_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 118.0, 86.0);
      return cairoon_test_render_backend_accessibility_index_surface(
        surface,
        kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 118.0, 86.0);
      return cairoon_test_render_backend_accessibility_index_surface(
        surface,
        kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 118.0, 86.0);
      return cairoon_test_render_backend_accessibility_index_surface(
        surface,
        kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
