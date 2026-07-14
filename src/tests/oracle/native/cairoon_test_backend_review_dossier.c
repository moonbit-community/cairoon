#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_review_dossier(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Review Dossier");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "draft review dossier");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "final review dossier");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "review,dossier,toc,list,table");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon review dossier");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Dossier", "draft");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Dossier", "final");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", "drop-me");
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
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Review Dossier");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType ReviewDossier");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize ReviewDossier");
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

static cairo_status_t cairoon_test_pdf_review_dossier_page_setup(
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

static cairo_status_t cairoon_test_review_dossier_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_review_dossier_index(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.18, 0.34, 0.52, 0.78);
  for (int i = 0; i < 2; i++) {
    double y = 46.0 + (double)i * 22.0;
    cairo_rectangle(cr, 18.0, y - 10.0, 96.0, 14.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.96, 0.96, 0.88);
    cairo_move_to(cr, 22.0, y);
    cairo_show_text(cr, i == 0 ? "decision list" : "evidence table");
    cairo_set_source_rgba(cr, 0.18, 0.34, 0.52, 0.78);
  }
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_review_dossier_list(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.58, 0.24, 0.28, 0.76);
  cairo_rectangle(cr, 18.0, 34.0, 100.0, 34.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.96, 0.88);
  cairo_move_to(cr, 24.0, 48.0);
  cairo_show_text(cr, "1");
  cairo_move_to(cr, 38.0, 48.0);
  cairo_show_text(cr, "accept");
  cairo_move_to(cr, 24.0, 62.0);
  cairo_show_text(cr, "2");
  cairo_move_to(cr, 38.0, 62.0);
  cairo_show_text(cr, "follow up");
  cairo_set_source_rgba(cr, 0.18, 0.50, 0.34, 0.74);
  cairo_arc(cr, 104.0, 86.0, 14.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_review_dossier_table(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.20, 0.42, 0.62, 0.76);
  cairo_rectangle(cr, 18.0, 32.0, 106.0, 44.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.96, 0.88);
  cairo_move_to(cr, 24.0, 48.0);
  cairo_show_text(cr, "item");
  cairo_move_to(cr, 72.0, 48.0);
  cairo_show_text(cr, "state");
  cairo_set_source_rgba(cr, 0.94, 0.74, 0.22, 0.84);
  cairo_rectangle(cr, 22.0, 56.0, 44.0, 14.0);
  cairo_rectangle(cr, 70.0, 56.0, 44.0, 14.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 25.0, 67.0);
  cairo_show_text(cr, "api");
  cairo_move_to(cr, 74.0, 67.0);
  cairo_show_text(cr, "ok");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_review_dossier(
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
  int list_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_review_dossier_page_setup(
      surface,
      140.0,
      112.0,
      "review-index",
      CAIRO_PDF_OUTLINE_ROOT,
      "review index",
      "page=1 pos=[18 28]",
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
    cairo_move_to(cr, 18.0, 28.0);
    cairo_show_text(cr, "review dossier");
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "TOC", "");
    cairo_tag_begin(cr, "TOCI", "");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='review-list'");
    status = cairoon_test_draw_review_dossier_index(cr);
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
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_review_dossier_page_setup(
      surface,
      132.0,
      118.0,
      "review-list",
      root_id,
      "review list",
      "page=2 pos=[20 44]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &list_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_review_dossier_resize_non_svg(
      surface,
      kind,
      132.0,
      118.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.96, 0.92);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='review-list' x=20 y=44");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "L", "");
    cairo_tag_begin(cr, "LI", "");
    cairo_tag_begin(cr, "Lbl", "");
    cairo_move_to(cr, 22.0, 82.0);
    cairo_show_text(cr, "labels");
    cairo_tag_end(cr, "Lbl");
    cairo_tag_begin(cr, "LBody", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/review-dossier'");
    status = cairoon_test_draw_review_dossier_list(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
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
    cairo_copy_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_review_dossier_page_setup(
      surface,
      136.0,
      110.0,
      "review-table",
      list_id,
      "review table",
      "page=3 pos=[18 86]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_review_dossier_resize_non_svg(
      surface,
      kind,
      136.0,
      110.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.92, 0.98);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Table", "");
    cairo_tag_begin(cr, "TR", "");
    cairo_tag_begin(cr, "TH", "");
    cairo_move_to(cr, 20.0, 88.0);
    cairo_show_text(cr, "table header");
    cairo_tag_end(cr, "TH");
    cairo_tag_begin(cr, "TD", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='review-list'");
    status = cairoon_test_draw_review_dossier_table(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "TD");
    cairo_tag_end(cr, "TR");
    cairo_tag_end(cr, "Table");
    cairo_tag_begin(cr, "NonStruct", "");
    cairo_tag_begin(cr, "Note", "");
    cairo_move_to(cr, 20.0, 100.0);
    cairo_show_text(cr, "review note");
    cairo_tag_end(cr, "Note");
    cairo_tag_end(cr, "NonStruct");
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

static cairo_status_t cairoon_test_render_backend_review_dossier_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_review_dossier(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_review_dossier(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_review_dossier_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 140.0, 112.0);
      return cairoon_test_render_backend_review_dossier_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 140.0, 112.0);
      return cairoon_test_render_backend_review_dossier_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 140.0, 112.0);
      return cairoon_test_render_backend_review_dossier_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
