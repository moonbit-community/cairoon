#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_bookmark_lattice(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Bookmark Lattice");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon backend oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon bookmark lattice");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "bookmark,lattice,tag,page");
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
        "BookmarkLattice",
        "outline-dest-copy");
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
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Bookmark Lattice");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType BookmarkLattice");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize BookmarkLattice");
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

static cairo_status_t cairoon_test_pdf_bookmark_lattice_page_setup(
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

static cairo_status_t cairoon_test_bookmark_lattice_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_bookmark_lattice_index(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.12, 0.22, 0.38);
  cairo_rectangle(cr, 16.0, 38.0, 92.0, 12.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.88, 0.92, 0.76);
  cairo_move_to(cr, 20.0, 47.0);
  cairo_show_text(cr, "detail");
  cairo_set_source_rgba(cr, 0.68, 0.26, 0.32, 0.82);
  cairo_rectangle(cr, 16.0, 60.0, 92.0, 12.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.96, 0.90, 0.78);
  cairo_move_to(cr, 20.0, 69.0);
  cairo_show_text(cr, "appendix");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_bookmark_lattice_detail(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.20, 0.46, 0.70, 0.80);
  cairo_arc(cr, 36.0, 54.0, 18.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.82, 0.64, 0.22, 0.78);
  cairo_rectangle(cr, 58.0, 38.0, 42.0, 32.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.02, 0.03, 0.04);
  cairo_move_to(cr, 20.0, 91.0);
  cairo_show_text(cr, "detail node");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_bookmark_lattice_appendix(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.28, 0.56, 0.34, 0.80);
  cairo_rectangle(cr, 20.0, 38.0, 78.0, 22.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.58, 0.22, 0.66, 0.62);
  cairo_move_to(cr, 28.0, 74.0);
  cairo_line_to(cr, 64.0, 44.0);
  cairo_line_to(cr, 98.0, 74.0);
  cairo_close_path(cr);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
  cairo_move_to(cr, 22.0, 94.0);
  cairo_show_text(cr, "appendix link");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_bookmark_lattice(
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
    status = cairoon_test_pdf_bookmark_lattice_page_setup(
      surface,
      128.0,
      118.0,
      "bookmark-index",
      CAIRO_PDF_OUTLINE_ROOT,
      "bookmark index",
      "page=1 pos=[14 28]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.94, 0.88);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_move_to(cr, 14.0, 28.0);
    cairo_show_text(cr, "bookmark lattice");
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "L", "");
    cairo_tag_begin(cr, "LI", "");
    cairo_tag_begin(cr, "Lbl", "");
    cairo_show_text(cr, "A");
    cairo_tag_end(cr, "Lbl");
    cairo_tag_begin(cr, "LBody", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='bookmark-detail'");
    status = cairoon_test_draw_bookmark_lattice_index(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "LBody");
    cairo_tag_end(cr, "LI");
    cairo_tag_end(cr, "L");
    cairo_tag_end(cr, "Sect");
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
    status = cairoon_test_pdf_bookmark_lattice_page_setup(
      surface,
      116.0,
      132.0,
      "bookmark-detail",
      root_id,
      "bookmark detail",
      "page=2 pos=[18 91]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_bookmark_lattice_resize_non_svg(
      surface,
      kind,
      116.0,
      132.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.95, 0.98);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='bookmark-detail' x=18 y=91");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_draw_bookmark_lattice_detail(cr);
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
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_bookmark_lattice_page_setup(
      surface,
      122.0,
      126.0,
      "bookmark-appendix",
      CAIRO_PDF_OUTLINE_ROOT,
      "bookmark appendix",
      "page=3 pos=[22 94]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_bookmark_lattice_resize_non_svg(
      surface,
      kind,
      122.0,
      126.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.98, 0.93, 0.88);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/bookmark-lattice'");
    status = cairoon_test_draw_bookmark_lattice_appendix(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_bookmark_lattice_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_bookmark_lattice(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_bookmark_lattice(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_bookmark_lattice_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 128.0, 118.0);
      return cairoon_test_render_backend_bookmark_lattice_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 128.0, 118.0);
      return cairoon_test_render_backend_bookmark_lattice_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 128.0, 118.0);
      return cairoon_test_render_backend_bookmark_lattice_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
