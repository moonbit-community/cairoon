#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_revision_ledger(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Revision Ledger");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon backend oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "draft revision sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "final revision sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "revision,ledger,page,tag");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon revision ledger");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "RevisionLedger", "draft");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "RevisionLedger", "final");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Stage", "proposal");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Stage", "accepted");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Ephemeral", "remove-me");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Ephemeral", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Revision Ledger");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType RevisionLedger");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize RevisionLedger");
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

static cairo_status_t cairoon_test_pdf_revision_ledger_page_setup(
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

static cairo_status_t cairoon_test_revision_ledger_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_revision_ledger_draft(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.18, 0.34, 0.58, 0.82);
  cairo_rectangle(cr, 14.0, 40.0, 86.0, 24.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.96, 0.94, 0.82);
  cairo_move_to(cr, 18.0, 56.0);
  cairo_show_text(cr, "draft baseline");
  cairo_set_source_rgba(cr, 0.78, 0.28, 0.22, 0.68);
  cairo_arc(cr, 94.0, 78.0, 14.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_revision_ledger_review(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.08, 0.42, 0.28, 0.74);
  cairo_rectangle(cr, 18.0, 56.0, 92.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.02, 0.02, 0.02);
  cairo_move_to(cr, 22.0, 70.0);
  cairo_show_text(cr, "review overlay");
  cairo_set_source_rgba(cr, 0.64, 0.42, 0.16, 0.72);
  cairo_move_to(cr, 22.0, 84.0);
  cairo_line_to(cr, 64.0, 62.0);
  cairo_line_to(cr, 112.0, 84.0);
  cairo_stroke(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_revision_ledger_final(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.36, 0.20, 0.58, 0.72);
  cairo_rectangle(cr, 18.0, 44.0, 82.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.20, 0.52, 0.66, 0.72);
  cairo_rectangle(cr, 18.0, 68.0, 82.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.02, 0.02, 0.02);
  cairo_move_to(cr, 22.0, 58.0);
  cairo_show_text(cr, "accepted");
  cairo_move_to(cr, 22.0, 82.0);
  cairo_show_text(cr, "linked back");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_revision_ledger(
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
  int review_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_revision_ledger_page_setup(
      surface,
      124.0,
      104.0,
      "ledger-draft",
      CAIRO_PDF_OUTLINE_ROOT,
      "ledger draft",
      "page=1 pos=[12 28]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.95, 0.88);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/revision-ledger/draft'");
    cairo_move_to(cr, 12.0, 28.0);
    cairo_show_text(cr, "revision ledger");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "P", "");
    status = cairoon_test_draw_revision_ledger_draft(cr);
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
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
    status = cairoon_test_pdf_revision_ledger_page_setup(
      surface,
      136.0,
      104.0,
      "ledger-review",
      root_id,
      "ledger review",
      "page=2 pos=[18 70]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &review_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_revision_ledger_resize_non_svg(
      surface,
      kind,
      136.0,
      104.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='ledger-review' x=18 y=70");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_draw_revision_ledger_review(cr);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
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
    status = cairoon_test_pdf_revision_ledger_page_setup(
      surface,
      118.0,
      126.0,
      "ledger-final",
      review_id,
      "ledger final",
      "page=3 pos=[18 104]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_revision_ledger_resize_non_svg(
      surface,
      kind,
      118.0,
      126.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.92, 0.98, 0.94);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Table", "");
    cairo_tag_begin(cr, "TR", "");
    cairo_tag_begin(cr, "TD", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='ledger-review'");
    status = cairoon_test_draw_revision_ledger_final(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "TD");
    cairo_tag_end(cr, "TR");
    cairo_tag_end(cr, "Table");
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='ledger-final' x=18 y=104");
    cairo_tag_begin(cr, "P", "");
    cairo_move_to(cr, 18.0, 104.0);
    cairo_show_text(cr, "final marker");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
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

static cairo_status_t cairoon_test_render_backend_revision_ledger_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_revision_ledger(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_revision_ledger(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_revision_ledger_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 124.0, 104.0);
      return cairoon_test_render_backend_revision_ledger_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 124.0, 104.0);
      return cairoon_test_render_backend_revision_ledger_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 124.0, 104.0);
      return cairoon_test_render_backend_revision_ledger_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
