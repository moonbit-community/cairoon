#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_attachment_index(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Attachment Index");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon attachment index");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "attachment index metadata");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "attachment,index,audit");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon attachment index");
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
        "AttachmentSet",
        "attachment-index-62");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", "drop-me");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Attachment Index");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType AttachmentIndex");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize AttachmentIndex");
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

static cairo_status_t cairoon_test_pdf_attachment_index_page_setup(
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

static cairo_status_t cairoon_test_attachment_index_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_attachment_index_badge(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.10, 0.42, 0.70, 0.85);
  cairo_rectangle(cr, 14.0, 38.0, 74.0, 18.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.97, 0.88);
  cairo_move_to(cr, 18.0, 51.0);
  cairo_show_text(cr, "attachment index");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_attachment_index_detail(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.22, 0.58, 0.34, 0.80);
  cairo_rectangle(cr, 18.0, 34.0, 92.0, 26.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.72, 0.22, 0.38, 0.64);
  cairo_arc(cr, 112.0, 72.0, 9.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 24.0, 50.0);
  cairo_show_text(cr, "attachment detail");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_attachment_index(
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
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_attachment_index_page_setup(
      surface,
      124.0,
      96.0,
      "attachments",
      CAIRO_PDF_OUTLINE_ROOT,
      "attachment index",
      "page=1 pos=[14 28]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.97, 0.92);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Index", "");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/attachment/index'");
    cairo_move_to(cr, 14.0, 28.0);
    cairo_show_text(cr, "attachments");
    status = cairoon_test_draw_attachment_index_badge(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Reference");
    cairo_tag_end(cr, "Index");
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

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_attachment_index_page_setup(
      surface,
      136.0,
      104.0,
      "attachment-detail",
      root_id,
      "attachment detail",
      "page=2 pos=[18 60]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_attachment_index_resize_non_svg(
      surface,
      kind,
      136.0,
      104.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.94, 0.98);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='attachment-detail' x=18 y=60");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, "Caption", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='attachment-detail'");
    status = cairoon_test_draw_attachment_index_detail(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Caption");
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
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

static cairo_status_t cairoon_test_render_backend_attachment_index_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_attachment_index(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_attachment_index(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_attachment_index_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 124.0, 96.0);
      return cairoon_test_render_backend_attachment_index_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 124.0, 96.0);
      return cairoon_test_render_backend_attachment_index_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 124.0, 96.0);
      return cairoon_test_render_backend_attachment_index_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
