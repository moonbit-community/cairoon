#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_page_sequence(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Page Sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon sequence author");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "page sequence metadata");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "sequence,pages,metadata");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon page sequence");
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
        "Sequence",
        "copy-show-copy-show");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Phase", "initial");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Phase", "updated");
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
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Page Sequence");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType Plain");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize Letter");
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

static cairo_status_t cairoon_test_pdf_sequence_page_setup(
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

static cairo_status_t cairoon_test_sequence_resize_non_pdf(
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
  return CAIRO_STATUS_SUCCESS;
}

static cairo_status_t cairoon_test_draw_backend_page_sequence(
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
    status = cairoon_test_pdf_sequence_page_setup(
      surface,
      132.0,
      96.0,
      "sequence-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "sequence cover",
      "page=1 pos=[12 20]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.95, 1.0);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/page-sequence'");
    cairo_move_to(cr, 12.0, 20.0);
    cairo_show_text(cr, "sequence cover");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_set_source_rgb(cr, 0.10, 0.35, 0.75);
    cairo_rectangle(cr, 12.0, 34.0, 44.0, 22.0);
    cairo_fill(cr);
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_sequence_page_setup(
      surface,
      96.0,
      132.0,
      "sequence-retained",
      root_id,
      "sequence retained overlay",
      "page=2 pos=[12 54]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_sequence_resize_non_pdf(surface, kind, 96.0, 132.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.85, 0.10, 0.12, 0.70);
    cairo_rectangle(cr, 12.0, 48.0, 64.0, 24.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.05, 0.05, 0.05);
    cairo_move_to(cr, 12.0, 82.0);
    cairo_show_text(cr, "retained overlay");
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_sequence_page_setup(
      surface,
      132.0,
      96.0,
      "sequence-fresh",
      root_id,
      "sequence fresh copy",
      "page=3 pos=[12 32]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_sequence_resize_non_pdf(surface, kind, 132.0, 96.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.92, 0.86);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.10, 0.45, 0.20);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='page-sequence-dest'");
    cairo_arc(cr, 34.0, 34.0, 14.0, 0.0, 6.283185307179586);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_move_to(cr, 12.0, 66.0);
    cairo_show_text(cr, "fresh copy");
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_sequence_page_setup(
      surface,
      72.0,
      120.0,
      "sequence-final",
      CAIRO_PDF_OUTLINE_ROOT,
      "sequence final",
      "page=4 pos=[8 28]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_sequence_resize_non_pdf(surface, kind, 72.0, 120.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='page-sequence-dest' x=8 y=28");
    cairo_move_to(cr, 8.0, 28.0);
    cairo_show_text(cr, "final destination");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Div", "");
    cairo_tag_begin(cr, "P", "");
    cairo_move_to(cr, 8.0, 54.0);
    cairo_show_text(cr, "final structure");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Div");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }
  return status;
}

static cairo_status_t cairoon_test_render_backend_page_sequence_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_page_sequence(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_page_sequence(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_page_sequence_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 132.0, 96.0);
      return cairoon_test_render_backend_page_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 132.0, 96.0);
      return cairoon_test_render_backend_page_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 132.0, 96.0);
      return cairoon_test_render_backend_page_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
