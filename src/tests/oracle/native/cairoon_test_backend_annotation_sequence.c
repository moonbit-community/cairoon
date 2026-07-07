#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_annotation_sequence(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Annotation Sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "list table outline tags");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon annotation sequence");
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
        "AnnotationSequence",
        "list-table-outline");
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
        "%%Title: Cairoon Annotation Sequence");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType AnnotationSequence");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize AnnotationSequence");
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

static cairo_status_t cairoon_test_pdf_annotation_sequence_page_setup(
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

static cairo_status_t cairoon_test_annotation_sequence_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_annotation_card(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.17, 0.32, 0.66, 0.86);
  cairo_rectangle(cr, 14.0, 34.0, 88.0, 44.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.96, 0.82, 0.20, 0.70);
  cairo_arc(cr, 86.0, 56.0, 18.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.04, 0.09, 0.18, 0.72);
  cairo_rectangle(cr, 22.0, 44.0, 50.0, 10.0);
  cairo_fill(cr);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_annotation_list(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.12, 0.24, 0.34);
  for (int i = 0; i < 3; i++) {
    double y = 34.0 + (double)i * 22.0;
    cairo_rectangle(cr, 18.0, y, 10.0, 10.0);
    cairo_fill(cr);
    cairo_move_to(cr, 36.0, y + 9.0);
    cairo_show_text(cr, i == 0 ? "alpha link" : (i == 1 ? "beta dest" : "gamma table"));
  }
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_annotation_table(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.84, 0.24, 0.18, 0.78);
  cairo_rectangle(cr, 18.0, 36.0, 88.0, 12.0);
  cairo_fill(cr);
  cairo_set_source_rgba(cr, 0.18, 0.54, 0.28, 0.72);
  cairo_rectangle(cr, 18.0, 52.0, 88.0, 16.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_move_to(cr, 24.0, 46.0);
  cairo_show_text(cr, "tag table");
  cairo_move_to(cr, 24.0, 64.0);
  cairo_show_text(cr, "final link");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_backend_annotation_sequence(
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
  int list_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_annotation_sequence_page_setup(
      surface,
      128.0,
      118.0,
      "annot-intro",
      CAIRO_PDF_OUTLINE_ROOT,
      "annotation intro",
      "page=1 pos=[14 24]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.94, 0.96, 0.90);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Part", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "H1", "");
    cairo_move_to(cr, 14.0, 24.0);
    cairo_show_text(cr, "annotation intro");
    cairo_tag_end(cr, "H1");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/annotation-sequence/intro'");
    status = cairoon_test_draw_annotation_card(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Part");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_annotation_sequence_page_setup(
      surface,
      118.0,
      130.0,
      "annot-list",
      root_id,
      "annotation list",
      "page=2 pos=[18 104]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &list_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_annotation_sequence_resize_non_svg(
      surface,
      kind,
      118.0,
      130.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.90, 0.95, 0.98);
    cairo_paint(cr);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='annotation-list' x=18 y=104");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "L", "");
    for (int i = 0; i < 3; i++) {
      cairo_tag_begin(cr, "LI", "");
      cairo_tag_begin(cr, "Lbl", "");
      cairo_tag_end(cr, "Lbl");
      cairo_tag_begin(cr, "LBody", "");
      cairo_tag_end(cr, "LBody");
      cairo_tag_end(cr, "LI");
    }
    status = cairoon_test_draw_annotation_list(cr);
    cairo_tag_end(cr, "L");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_annotation_sequence_page_setup(
      surface,
      124.0,
      110.0,
      "annot-table",
      list_id,
      "annotation table",
      "page=3 pos=[18 92]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_annotation_sequence_resize_non_svg(
      surface,
      kind,
      124.0,
      110.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.98, 0.92, 0.88);
    cairo_paint(cr);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Table", "");
    cairo_tag_begin(cr, "TR", "");
    cairo_tag_begin(cr, "TH", "");
    cairo_tag_end(cr, "TH");
    cairo_tag_end(cr, "TR");
    cairo_tag_begin(cr, "TR", "");
    cairo_tag_begin(cr, "TD", "");
    status = cairoon_test_draw_annotation_table(cr);
    cairo_tag_end(cr, "TD");
    cairo_tag_end(cr, "TR");
    cairo_tag_end(cr, "Table");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='annotation-list'");
    cairo_move_to(cr, 18.0, 92.0);
    cairo_show_text(cr, "return to list");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
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

static cairo_status_t cairoon_test_render_backend_annotation_sequence_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_annotation_sequence(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_annotation_sequence(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_annotation_sequence_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
      surface = cairo_pdf_surface_create(name, 128.0, 118.0);
      return cairoon_test_render_backend_annotation_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 128.0, 118.0);
      return cairoon_test_render_backend_annotation_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 128.0, 118.0);
      return cairoon_test_render_backend_annotation_sequence_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
