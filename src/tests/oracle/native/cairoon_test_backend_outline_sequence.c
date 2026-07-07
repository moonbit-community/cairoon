#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_outline_sequence(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Outline Sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "outline sequence page operations");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon outline sequence");
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
        "OutlineSeq",
        "context-surface-page-ops");
      cairo_pdf_surface_set_custom_metadata(surface, "OutlineScratch", "drop");
      cairo_pdf_surface_set_custom_metadata(surface, "OutlineScratch", NULL);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_3);
      cairo_ps_surface_set_eps(surface, 0);
      cairo_ps_surface_dsc_begin_setup(surface);
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon Outline Sequence");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType OutlineSeq");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize OutlineSeq");
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

static cairo_status_t cairoon_test_pdf_outline_sequence_page(
  cairo_surface_t *surface,
  const char *label,
  int parent_id,
  const char *title,
  const char *attributes,
  cairo_pdf_outline_flags_t flags,
  int *outline_id) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
  cairo_pdf_surface_set_page_label(surface, label);
  int id = cairo_pdf_surface_add_outline(
    surface,
    parent_id,
    title,
    attributes,
    flags);
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS && outline_id != NULL) {
    *outline_id = id;
  }
  return status;
#else
  (void)surface;
  (void)label;
  (void)parent_id;
  (void)title;
  (void)attributes;
  (void)flags;
  (void)outline_id;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

static cairo_status_t cairoon_test_resize_outline_sequence_surface(
  cairo_surface_t *surface,
  int32_t kind,
  double width,
  double height) {
  if (kind == CAIROON_TEST_VECTOR_PDF) {
#if CAIRO_HAS_PDF_SURFACE
    cairo_pdf_surface_set_size(surface, width, height);
#endif
  } else if (kind == CAIROON_TEST_VECTOR_PS) {
#if CAIRO_HAS_PS_SURFACE
    cairo_ps_surface_set_size(surface, width, height);
#endif
  }
  return cairo_surface_status(surface);
}

static void cairoon_test_draw_outline_sequence_cover(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.88, 0.94, 0.99);
  cairo_paint(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "uri='https://example.com/outline-sequence'");
  cairo_move_to(cr, 10.0, 26.0);
  cairo_show_text(cr, "outline sequence cover");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  cairo_set_source_rgb(cr, 0.15, 0.38, 0.66);
  cairo_rectangle(cr, 10.0, 42.0, 78.0, 24.0);
  cairo_fill(cr);
}

static void cairoon_test_draw_outline_sequence_branch(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.96, 0.92, 0.84);
  cairo_paint(cr);
  cairo_set_source_rgba(cr, 0.76, 0.18, 0.22, 0.70);
  cairo_rectangle(cr, 16.0, 34.0, 82.0, 22.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(
    cr,
    CAIRO_TAG_DEST,
    "name='outline-sequence-dest' x=16 y=72");
  cairo_move_to(cr, 16.0, 72.0);
  cairo_show_text(cr, "outline sequence branch");
  cairo_tag_end(cr, CAIRO_TAG_DEST);
}

static void cairoon_test_draw_outline_sequence_final(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.91, 0.96, 0.90);
  cairo_paint(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "Figure", "");
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='outline-sequence-dest'");
  cairo_move_to(cr, 12.0, 66.0);
  cairo_show_text(cr, "outline sequence final link");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_tag_end(cr, "Figure");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  cairo_set_source_rgb(cr, 0.24, 0.50, 0.28);
  cairo_arc(cr, 78.0, 38.0, 14.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
}

static cairo_status_t cairoon_test_draw_backend_outline_sequence(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 9.5);

  int root_id = CAIRO_PDF_OUTLINE_ROOT;
  int branch_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_outline_sequence_page(
      surface,
      "outline-seq-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "outline sequence cover",
      "page=1 pos=[10 26]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_outline_sequence_cover(cr);
    cairo_copy_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_resize_outline_sequence_surface(
      surface,
      kind,
      132.0,
      92.0);
  }
  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_outline_sequence_page(
      surface,
      "outline-seq-branch",
      root_id,
      "outline sequence branch",
      "page=2 pos=[16 72]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &branch_id);
  }
  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_outline_sequence_page(
      surface,
      "outline-seq-branch",
      root_id,
      "outline sequence sibling",
      "page=2 pos=[72 34]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD | CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_outline_sequence_branch(cr);
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_resize_outline_sequence_surface(
      surface,
      kind,
      108.0,
      102.0);
  }
  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_outline_sequence_page(
      surface,
      "outline-seq-final",
      branch_id,
      "outline sequence final",
      "page=3 pos=[12 66]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD |
        CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_outline_sequence_final(cr);
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_outline_sequence_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_outline_sequence(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_outline_sequence(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_outline_sequence_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      surface = cairo_pdf_surface_create(name, 112.0, 88.0);
      return cairoon_test_render_backend_outline_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 112.0, 88.0);
      return cairoon_test_render_backend_outline_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 112.0, 88.0);
      return cairoon_test_render_backend_outline_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
