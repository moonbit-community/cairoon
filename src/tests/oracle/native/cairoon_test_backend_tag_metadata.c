#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_tag_metadata(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Tag Metadata Matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "tag metadata page transitions");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon tag metadata");
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
        "TagMeta",
        "tag-metadata-page-transitions");
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
      cairo_ps_surface_dsc_comment(
        surface,
        "%%Title: Cairoon Tag Metadata Matrix");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType TagMeta");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize TagMeta");
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

static cairo_status_t cairoon_test_pdf_tag_metadata_setup(
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

static cairo_status_t cairoon_test_tag_metadata_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_backend_tag_metadata(
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
  int overlay_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_metadata_setup(
      surface,
      120.0,
      96.0,
      "tagmeta-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "tag metadata cover",
      "page=1 pos=[12 24]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.93, 0.95, 0.99);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/tag-meta/cover'");
    cairo_move_to(cr, 12.0, 24.0);
    cairo_show_text(cr, "tag metadata cover");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_set_source_rgba(cr, 0.15, 0.38, 0.70, 0.70);
    cairo_rectangle(cr, 12.0, 36.0, 74.0, 22.0);
    cairo_fill(cr);
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_metadata_setup(
      surface,
      140.0,
      96.0,
      "tagmeta-overlay",
      root_id,
      "tag metadata overlay",
      "page=2 pos=[18 78]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &overlay_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_tag_metadata_resize_non_svg(
      surface,
      kind,
      140.0,
      96.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.85, 0.20, 0.25, 0.55);
    cairo_rectangle(cr, 18.0, 44.0, 82.0, 24.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='tag-meta-dest' x=18 y=78");
    cairo_move_to(cr, 18.0, 78.0);
    cairo_show_text(cr, "tag metadata destination");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Document");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='tag-meta-dest'");
    cairo_set_source_rgba(cr, 0.12, 0.50, 0.32, 0.72);
    cairo_arc(cr, 108.0, 58.0, 12.0, 0.0, 6.283185307179586);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_tag_metadata_setup(
      surface,
      100.0,
      120.0,
      "tagmeta-final",
      overlay_id,
      "tag metadata final",
      "page=3 pos=[14 88]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_tag_metadata_resize_non_svg(
      surface,
      kind,
      100.0,
      120.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.93, 0.84);
    cairo_paint(cr);
    cairo_save(cr);
    cairo_rectangle(cr, 8.0, 12.0, 82.0, 84.0);
    cairo_clip(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/tag-meta/final'");
    cairo_move_to(cr, 14.0, 88.0);
    cairo_show_text(cr, "tag metadata final");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_restore(cr);
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_tag_metadata_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_tag_metadata(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_tag_metadata(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_tag_metadata_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 120.0, 96.0);
      return cairoon_test_render_backend_tag_metadata_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 120.0, 96.0);
      return cairoon_test_render_backend_tag_metadata_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 120.0, 96.0);
      return cairoon_test_render_backend_tag_metadata_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
