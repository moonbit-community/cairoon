#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_navigation_map(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Navigation Map");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon navigation map");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "navigation map metadata");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "navigation,map,toc");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon navigation map");
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
        "NavigationSet",
        "navigation-map-63");
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
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Navigation Map");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType NavigationMap");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize NavigationMap");
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

static cairo_status_t cairoon_test_pdf_navigation_map_page_setup(
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

static cairo_status_t cairoon_test_navigation_map_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_navigation_map_toc(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.18, 0.36, 0.68, 0.82);
  cairo_rectangle(cr, 14.0, 36.0, 92.0, 20.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.92, 0.76, 0.24, 0.76);
  cairo_rectangle(cr, 22.0, 62.0, 72.0, 10.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 18.0, 29.0);
  cairo_show_text(cr, "navigation map");
  cairo_move_to(cr, 26.0, 70.0);
  cairo_show_text(cr, "toc entry");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_navigation_map_detail(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.18, 0.55, 0.42, 0.84);
  cairo_rectangle(cr, 18.0, 34.0, 102.0, 26.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.68, 0.20, 0.52, 0.66);
  cairo_arc(cr, 120.0, 76.0, 10.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.98, 0.96, 0.88);
  cairo_rectangle(cr, 26.0, 70.0, 54.0, 14.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 24.0, 51.0);
  cairo_show_text(cr, "route detail");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_navigation_map(
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
    status = cairoon_test_pdf_navigation_map_page_setup(
      surface,
      132.0,
      98.0,
      "navigation-map",
      CAIRO_PDF_OUTLINE_ROOT,
      "navigation map",
      "page=1 pos=[16 30]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.94, 0.88);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "TOC", "");
    cairo_tag_begin(cr, "TOCI", "");
    cairo_tag_begin(cr, "Reference", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/navigation/map'");
    status = cairoon_test_draw_navigation_map_toc(cr);
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
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_navigation_map_page_setup(
      surface,
      148.0,
      108.0,
      "navigation-detail",
      root_id,
      "navigation detail",
      "page=2 pos=[20 62]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_navigation_map_resize_non_svg(
      surface,
      kind,
      148.0,
      108.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.88, 0.95, 0.96);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='navigation-detail' x=20 y=62");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Div", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, "Caption", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='navigation-detail'");
    status = cairoon_test_draw_navigation_map_detail(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Caption");
    cairo_tag_end(cr, "Figure");
    cairo_tag_begin(cr, "Code", "");
    cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
    cairo_move_to(cr, 31.0, 80.0);
    cairo_show_text(cr, "x+y");
    cairo_tag_end(cr, "Code");
    cairo_tag_begin(cr, "Formula", "");
    cairo_move_to(cr, 86.0, 80.0);
    cairo_show_text(cr, "f(x)");
    cairo_tag_end(cr, "Formula");
    cairo_tag_end(cr, "Div");
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

static cairo_status_t cairoon_test_render_backend_navigation_map_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_navigation_map(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_navigation_map(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_navigation_map_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 132.0, 98.0);
      return cairoon_test_render_backend_navigation_map_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 132.0, 98.0);
      return cairoon_test_render_backend_navigation_map_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 132.0, 98.0);
      return cairoon_test_render_backend_navigation_map_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
