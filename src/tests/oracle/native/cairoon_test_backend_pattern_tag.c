#include "cairoon_test_vector_private.h"

#include <string.h>

static cairo_status_t cairoon_test_pattern_tag_show_text_glyphs(
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

static cairo_status_t cairoon_test_pattern_tag_create_pattern(
  cairo_pattern_t **pattern_out) {
  *pattern_out = NULL;

  cairo_surface_t *image = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 14, 14);
  cairo_status_t status = cairo_surface_status(image);
  cairo_t *image_cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    image_cr = cairo_create(image);
    status = cairo_status(image_cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(image_cr, 0.94, 0.90, 0.78);
    cairo_paint(image_cr);
    cairo_set_source_rgba(image_cr, 0.12, 0.44, 0.76, 0.80);
    cairo_rectangle(image_cr, 1.0, 1.0, 6.0, 12.0);
    cairo_fill(image_cr);
    cairo_set_source_rgba(image_cr, 0.82, 0.18, 0.22, 0.70);
    cairo_arc(image_cr, 9.5, 5.5, 4.0, 0.0, 6.283185307179586);
    cairo_fill(image_cr);
    cairo_set_source_rgba(image_cr, 0.08, 0.34, 0.20, 0.75);
    cairo_rectangle(image_cr, 7.0, 9.0, 6.0, 4.0);
    cairo_fill(image_cr);
    status = cairo_status(image_cr);
  }

  cairo_pattern_t *pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    pattern = cairo_pattern_create_for_surface(image);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_matrix_t matrix;
    cairo_matrix_init(&matrix, 0.75, 0.12, -0.18, 0.85, -6.0, 2.0);
    cairo_pattern_set_matrix(pattern, &matrix);
    status = cairo_pattern_status(pattern);
  }

  if (image_cr != NULL) {
    cairo_destroy(image_cr);
  }
  cairo_surface_destroy(image);
  if (status == CAIRO_STATUS_SUCCESS) {
    *pattern_out = pattern;
  } else if (pattern != NULL) {
    cairo_pattern_destroy(pattern);
  }
  return status;
}

static cairo_status_t cairoon_test_draw_pattern_tag_pattern(cairo_t *cr) {
  cairo_pattern_t *pattern = NULL;
  cairo_status_t status = cairoon_test_pattern_tag_create_pattern(&pattern);
  cairo_pattern_t *mask = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    mask = cairo_pattern_create_radial(66.0, 55.0, 4.0, 66.0, 55.0, 56.0);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.96);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 0.12);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_save(cr);
    cairo_rectangle(cr, 14.0, 34.0, 96.0, 54.0);
    cairo_clip(cr);
    cairo_set_source(cr, pattern);
    cairo_mask(cr, mask);
    cairo_restore(cr);
    status = cairo_status(cr);
  }

  if (mask != NULL) {
    cairo_pattern_destroy(mask);
  }
  if (pattern != NULL) {
    cairo_pattern_destroy(pattern);
  }
  return status;
}

static cairo_status_t cairoon_test_configure_backend_pattern_tag(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Pattern Tag Matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "pattern tags with font matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_KEYWORDS,
        "pattern,tag,font,matrix");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon pattern tag");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_custom_metadata(
        surface,
        "PatternTag",
        "surface-pattern-font-matrix");
      cairo_pdf_surface_set_custom_metadata(surface, "Scratch", "drop-me");
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
      cairo_ps_surface_dsc_comment(
        surface,
        "%%Title: Cairoon Pattern Tag Matrix");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType PatternTag");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize PatternTag");
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

static cairo_status_t cairoon_test_pdf_pattern_tag_page_setup(
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

static cairo_status_t cairoon_test_pattern_tag_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_backend_pattern_tag(
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
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_pattern_tag_page_setup(
      surface,
      132.0,
      112.0,
      "pattern-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "pattern cover",
      "page=1 pos=[12 28]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.95, 0.96, 0.90);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/pattern-tag/cover'");
    cairo_move_to(cr, 12.0, 28.0);
    cairo_show_text(cr, "pattern tag cover");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "P");
    cairo_tag_begin(cr, "Figure", "");
    status = cairoon_test_draw_pattern_tag_pattern(cr);
    cairo_tag_end(cr, "Figure");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_pattern_tag_page_setup(
      surface,
      120.0,
      138.0,
      "pattern-dest",
      root_id,
      "pattern destination",
      "page=2 pos=[16 72]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_pattern_tag_resize_non_svg(surface, kind, 120.0, 138.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.92, 0.94, 0.98);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.10, 0.36, 0.54);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='pattern-tag-dest' x=16 y=72");
    cairo_arc(cr, 32.0, 54.0, 16.0, 0.0, 6.283185307179586);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_tag_end(cr, "Figure");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='pattern-tag-dest'");
    cairo_move_to(cr, 16.0, 72.0);
    cairo_show_text(cr, "pattern destination");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_pattern_tag_page_setup(
      surface,
      96.0,
      120.0,
      "pattern-final",
      CAIRO_PDF_OUTLINE_ROOT,
      "pattern final",
      "page=3 pos=[12 78]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_pattern_tag_resize_non_svg(surface, kind, 96.0, 120.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.97, 0.92, 0.88);
    cairo_paint(cr);
    cairo_set_source_rgba(cr, 0.36, 0.18, 0.52, 0.50);
    cairo_rectangle(cr, 12.0, 84.0, 62.0, 20.0);
    cairo_fill(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_matrix_t font_matrix;
    cairo_matrix_init(&font_matrix, 7.8, 0.35, -0.28, 8.6, 0.0, 0.0);
    cairo_set_font_matrix(cr, &font_matrix);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Div", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/pattern-tag/final'");
    status = cairoon_test_pattern_tag_show_text_glyphs(
      cr,
      12.0,
      78.0,
      "pattern glyph");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Div");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_pattern_tag_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_pattern_tag(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_pattern_tag(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_pattern_tag_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      surface = cairo_pdf_surface_create(name, 132.0, 112.0);
      return cairoon_test_render_backend_pattern_tag_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 132.0, 112.0);
      return cairoon_test_render_backend_pattern_tag_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 132.0, 112.0);
      return cairoon_test_render_backend_pattern_tag_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
