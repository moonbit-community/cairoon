#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_tag_attributes(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Tag Attribute Matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon tag attribute matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
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
        "%%Title: Cairoon Tag Attribute Matrix");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType TagAttributes");
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

static void cairoon_test_tag_attribute_text(
  cairo_t *cr,
  double x,
  double y,
  const char *text) {
  cairo_move_to(cr, x, y);
  cairo_show_text(cr, text);
}

static cairo_status_t cairoon_test_draw_backend_tag_attributes(cairo_t *cr) {
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 8.0);

  cairo_set_source_rgb(cr, 0.96, 0.97, 1.0);
  cairo_paint(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_CONTENT,
    "tag_name='H1' id='tag-attribute-heading'");
  cairoon_test_tag_attribute_text(cr, 10.0, 16.0, "tag attribute matrix");
  cairo_tag_end(cr, CAIRO_TAG_CONTENT);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_CONTENT,
    "tag_name='P' id='tag-attribute-body'");
  cairoon_test_tag_attribute_text(cr, 10.0, 104.0, "content reference body");
  cairo_tag_end(cr, CAIRO_TAG_CONTENT);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "rect=[10 28 52 12 72 28 58 12] "
    "uri='https://example.com/tag-attributes'");
  cairoon_test_tag_attribute_text(cr, 12.0, 36.0, "uri rect one");
  cairoon_test_tag_attribute_text(cr, 74.0, 36.0, "uri rect two");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "rect=[10 48 52 10] dest='tag-attribute-target'");
  cairoon_test_tag_attribute_text(cr, 12.0, 55.0, "named target");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "rect=[72 48 58 10] page=2 pos=[18 44]");
  cairoon_test_tag_attribute_text(cr, 74.0, 55.0, "page position");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "rect=[10 66 52 10] file='external.pdf' page=3 pos=[12 34]");
  cairoon_test_tag_attribute_text(cr, 12.0, 73.0, "file page");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "rect=[72 66 58 10] file='external.pdf' dest='appendix'");
  cairoon_test_tag_attribute_text(cr, 74.0, 73.0, "file destination");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "rect=[10 84 52 10] dest='tag-attribute-extent'");
  cairoon_test_tag_attribute_text(cr, 12.0, 91.0, "extent target");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "H1", "");
  cairo_tag_begin(
    cr,
    CAIRO_TAG_CONTENT_REF,
    "ref='tag-attribute-heading'");
  cairo_tag_end(cr, CAIRO_TAG_CONTENT_REF);
  cairo_tag_end(cr, "H1");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "P", "");
  cairo_tag_begin(cr, CAIRO_TAG_CONTENT_REF, "ref='tag-attribute-body'");
  cairo_tag_end(cr, CAIRO_TAG_CONTENT_REF);
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  cairo_surface_show_page(cairo_get_target(cr));

  cairo_set_source_rgb(cr, 0.94, 1.0, 0.95);
  cairo_paint(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_tag_begin(
    cr,
    CAIRO_TAG_DEST,
    "name='tag-attribute-target' x=18 y=44 internal");
  cairoon_test_tag_attribute_text(cr, 18.0, 44.0, "internal destination");
  cairo_tag_end(cr, CAIRO_TAG_DEST);
  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='tag-attribute-extent'");
  cairoon_test_tag_attribute_text(cr, 18.0, 72.0, "extent destination");
  cairo_tag_end(cr, CAIRO_TAG_DEST);
  cairo_surface_show_page(cairo_get_target(cr));
  return cairo_status(cr);
#else
  (void)cr;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

static cairo_status_t cairoon_test_render_backend_tag_attribute_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_tag_attributes(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_tag_attributes(cr);
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

cairo_status_t cairoon_test_render_backend_tag_attribute_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE
      surface = cairo_pdf_surface_create(name, 144.0, 120.0);
      return cairoon_test_render_backend_tag_attribute_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 144.0, 120.0);
      return cairoon_test_render_backend_tag_attribute_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 144.0, 120.0);
      return cairoon_test_render_backend_tag_attribute_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
