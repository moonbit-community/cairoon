#include "cairoon_test_vector_private.h"

#include <string.h>

static cairo_status_t cairoon_test_lifecycle_show_text_glyphs(
  cairo_t *cr,
  double x,
  double y,
  const char *text) {
  int text_len = (int)strlen(text);
  cairo_glyph_t *glyphs = NULL;
  int num_glyphs = 0;
  cairo_text_cluster_t *clusters = NULL;
  int num_clusters = 0;
  cairo_text_cluster_flags_t flags = 0;

  cairo_status_t status = cairo_scaled_font_text_to_glyphs(
    cairo_get_scaled_font(cr),
    x,
    y,
    text,
    text_len,
    &glyphs,
    &num_glyphs,
    &clusters,
    &num_clusters,
    &flags);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_text_glyphs(
      cr,
      text,
      text_len,
      glyphs,
      num_glyphs,
      clusters,
      num_clusters,
      flags);
    status = cairo_status(cr);
  }

  cairo_glyph_free(glyphs);
  cairo_text_cluster_free(clusters);
  return status;
}

static cairo_status_t cairoon_test_configure_backend_lifecycle_matrix(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Lifecycle Matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_AUTHOR,
        "cairoon lifecycle author");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "page lifecycle matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "lifecycle,copy,show,tags");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon lifecycle matrix");
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
        "Lifecycle",
        "copy-copy-show-show");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Stage", "warmup");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Stage", "settled");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", "drop-me");
      cairoon_test_pdf_surface_set_custom_metadata(surface, "Scratch", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_2);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Lifecycle Matrix");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaColor Ivory");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize Lifecycle");
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      cairo_svg_surface_restrict_to_version(surface, CAIRO_SVG_VERSION_1_2);
      cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_MM);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

static cairo_status_t cairoon_test_pdf_lifecycle_page_setup(
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

static cairo_status_t cairoon_test_lifecycle_resize_non_pdf(
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

static cairo_status_t cairoon_test_draw_backend_lifecycle_matrix(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 11.0);

  int root_id = CAIRO_PDF_OUTLINE_ROOT;
  int retained_id = CAIRO_PDF_OUTLINE_ROOT;
  int fresh_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_lifecycle_page_setup(
      surface,
      150.0,
      110.0,
      "life-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "life cover",
      "page=1 pos=[16 24]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.91, 0.96, 0.98);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/lifecycle/cover'");
    cairo_move_to(cr, 16.0, 24.0);
    cairo_show_text(cr, "lifecycle cover");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "Figure", "");
    cairo_set_source_rgb(cr, 0.12, 0.40, 0.72);
    cairo_rectangle(cr, 16.0, 42.0, 58.0, 26.0);
    cairo_fill(cr);
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_lifecycle_page_setup(
      surface,
      150.0,
      110.0,
      "life-retained-copy",
      root_id,
      "life retained copy",
      "page=2 pos=[18 76]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &retained_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_lifecycle_resize_non_pdf(surface, kind, 150.0, 110.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.86, 0.16, 0.18, 0.58);
    cairo_rectangle(cr, 18.0, 58.0, 74.0, 24.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.04, 0.04, 0.04);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='life-dest-a'");
    cairo_move_to(cr, 18.0, 88.0);
    cairo_show_text(cr, "retained copy link");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_lifecycle_page_setup(
      surface,
      96.0,
      150.0,
      "life-retained-second",
      retained_id,
      "life retained second",
      "page=3 pos=[18 82]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_lifecycle_resize_non_pdf(surface, kind, 96.0, 150.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.12, 0.22, 0.76, 0.50);
    cairo_rectangle(cr, 20.0, 100.0, 52.0, 20.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='life-dest-a' x=18 y=82");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Art", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    cairo_move_to(cr, 18.0, 82.0);
    cairo_show_text(cr, "retained destination");
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Art");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_lifecycle_page_setup(
      surface,
      120.0,
      120.0,
      "life-fresh",
      CAIRO_PDF_OUTLINE_ROOT,
      "life fresh root",
      "page=4 pos=[12 38]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &fresh_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_lifecycle_resize_non_pdf(surface, kind, 120.0, 120.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.96, 0.93, 0.86);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "L", "");
    cairo_tag_begin(cr, "LI", "");
    cairo_tag_begin(cr, "Lbl", "");
    cairo_move_to(cr, 12.0, 34.0);
    cairo_show_text(cr, "1.");
    cairo_tag_end(cr, "Lbl");
    cairo_tag_begin(cr, "LBody", "");
    cairo_tag_begin(cr, "Span", "");
    status = cairoon_test_lifecycle_show_text_glyphs(
      cr,
      26.0,
      34.0,
      "fresh glyph run");
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "LBody");
    cairo_tag_end(cr, "LI");
    cairo_tag_end(cr, "L");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_lifecycle_page_setup(
      surface,
      80.0,
      140.0,
      "life-final",
      fresh_id,
      "life final child",
      "page=5 pos=[10 44]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_lifecycle_resize_non_pdf(surface, kind, 80.0, 140.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.12, 0.54, 0.32, 0.70);
    cairo_rectangle(cr, 10.0, 94.0, 54.0, 22.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Table", "");
    cairo_tag_begin(cr, "TR", "");
    cairo_tag_begin(cr, "TD", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/lifecycle/final'");
    cairo_move_to(cr, 10.0, 44.0);
    cairo_show_text(cr, "final table cell");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='life-dest-final' x=10 y=66");
    cairo_move_to(cr, 10.0, 66.0);
    cairo_show_text(cr, "final destination");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_tag_end(cr, "TD");
    cairo_tag_end(cr, "TR");
    cairo_tag_end(cr, "Table");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }
  return status;
}

static cairo_status_t cairoon_test_render_backend_lifecycle_matrix_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_lifecycle_matrix(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_lifecycle_matrix(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_lifecycle_matrix_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 150.0, 110.0);
      return cairoon_test_render_backend_lifecycle_matrix_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 150.0, 110.0);
      return cairoon_test_render_backend_lifecycle_matrix_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 150.0, 110.0);
      return cairoon_test_render_backend_lifecycle_matrix_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
