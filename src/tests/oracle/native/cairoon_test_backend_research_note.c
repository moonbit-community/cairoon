#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_research_note(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Research Note");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon backend oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "draft research note");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "final research note");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "research,note,table,artifact");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon research note");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_custom_metadata(surface, "Review", "alpha");
      cairo_pdf_surface_set_custom_metadata(surface, "Review", "accepted");
      cairo_pdf_surface_set_custom_metadata(surface, "Scratch", "remove-me");
      cairo_pdf_surface_set_custom_metadata(surface, "Scratch", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Research Note");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType ResearchNote");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize ResearchNote");
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

static cairo_status_t cairoon_test_pdf_research_note_page_setup(
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

static cairo_status_t cairoon_test_research_note_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_research_abstract(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.16, 0.36, 0.48, 0.78);
  cairo_rectangle(cr, 16.0, 42.0, 92.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.96, 0.96, 0.88);
  cairo_move_to(cr, 20.0, 55.0);
  cairo_show_text(cr, "abstract link");
  cairo_set_source_rgba(cr, 0.60, 0.30, 0.18, 0.74);
  cairo_arc(cr, 108.0, 78.0, 12.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_research_table(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.22, 0.46, 0.34, 0.78);
  cairo_rectangle(cr, 18.0, 34.0, 108.0, 40.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.96, 0.88);
  cairo_move_to(cr, 24.0, 48.0);
  cairo_show_text(cr, "metric");
  cairo_move_to(cr, 78.0, 48.0);
  cairo_show_text(cr, "value");
  cairo_set_source_rgba(cr, 0.86, 0.72, 0.28, 0.86);
  cairo_rectangle(cr, 22.0, 56.0, 48.0, 14.0);
  cairo_rectangle(cr, 74.0, 56.0, 48.0, 14.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 25.0, 67.0);
  cairo_show_text(cr, "ffi");
  cairo_move_to(cr, 78.0, 67.0);
  cairo_show_text(cr, "ok");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_research_note(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.48, 0.28, 0.58, 0.76);
  cairo_rectangle(cr, 18.0, 32.0, 110.0, 22.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.18, 0.52, 0.62, 0.74);
  cairo_rectangle(cr, 26.0, 64.0, 94.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.98, 0.88);
  cairo_move_to(cr, 22.0, 47.0);
  cairo_show_text(cr, "artifact figure");
  cairo_move_to(cr, 30.0, 77.0);
  cairo_show_text(cr, "see table");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_research_note(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 10.0);

  int abstract_id = CAIRO_PDF_OUTLINE_ROOT;
  int table_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_research_note_page_setup(
      surface,
      132.0,
      108.0,
      "research-abstract",
      CAIRO_PDF_OUTLINE_ROOT,
      "research abstract",
      "page=1 pos=[18 30]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &abstract_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.96, 0.92);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_move_to(cr, 18.0, 30.0);
    cairo_show_text(cr, "research note");
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/research-note'");
    status = cairoon_test_draw_research_abstract(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
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
    status = cairoon_test_pdf_research_note_page_setup(
      surface,
      144.0,
      118.0,
      "research-table",
      abstract_id,
      "research table",
      "page=2 pos=[20 52]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &table_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_research_note_resize_non_svg(
      surface,
      kind,
      144.0,
      118.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.95, 0.98);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='research-table' x=20 y=52");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Table", "");
    cairo_tag_begin(cr, "TR", "");
    cairo_tag_begin(cr, "TH", "");
    cairo_move_to(cr, 20.0, 28.0);
    cairo_show_text(cr, "table header");
    cairo_tag_end(cr, "TH");
    cairo_tag_begin(cr, "TD", "");
    status = cairoon_test_draw_research_table(cr);
    cairo_tag_end(cr, "TD");
    cairo_tag_end(cr, "TR");
    cairo_tag_end(cr, "Table");
    cairo_tag_begin(cr, "L", "");
    cairo_tag_begin(cr, "LI", "");
    cairo_tag_begin(cr, "Lbl", "");
    cairo_move_to(cr, 22.0, 94.0);
    cairo_show_text(cr, "1");
    cairo_tag_end(cr, "Lbl");
    cairo_tag_begin(cr, "LBody", "");
    cairo_move_to(cr, 34.0, 94.0);
    cairo_show_text(cr, "stable");
    cairo_tag_end(cr, "LBody");
    cairo_tag_end(cr, "LI");
    cairo_tag_end(cr, "L");
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
    status = cairoon_test_pdf_research_note_page_setup(
      surface,
      150.0,
      98.0,
      "research-note",
      table_id,
      "research artifact",
      "page=3 pos=[22 44]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_research_note_resize_non_svg(
      surface,
      kind,
      150.0,
      98.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.95, 0.93, 0.98);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Note", "");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='research-table'");
    cairo_move_to(cr, 22.0, 24.0);
    cairo_show_text(cr, "research note");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Reference");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, "Caption", "");
    cairo_move_to(cr, 22.0, 88.0);
    cairo_show_text(cr, "artifact caption");
    cairo_tag_end(cr, "Caption");
    status = cairoon_test_draw_research_note(cr);
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Note");
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

static cairo_status_t cairoon_test_render_backend_research_note_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_research_note(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_research_note(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_research_note_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      surface = cairo_pdf_surface_create(name, 132.0, 108.0);
      return cairoon_test_render_backend_research_note_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 132.0, 108.0);
      return cairoon_test_render_backend_research_note_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 132.0, 108.0);
      return cairoon_test_render_backend_research_note_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
