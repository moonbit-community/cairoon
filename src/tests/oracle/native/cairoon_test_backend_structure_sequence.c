#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_structure_sequence(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon Structure Sequence");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "retained pages and structure tags");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon structure sequence");
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
        "StructureSeq",
        "retained-copy-show");
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
        "%%Title: Cairoon Structure Sequence");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaType StructureSeq");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize StructureSeq");
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

static cairo_status_t cairoon_test_pdf_structure_sequence_setup(
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

static cairo_status_t cairoon_test_structure_sequence_resize_non_svg(
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

static void cairoon_test_draw_structure_sequence_cover(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.90, 0.94, 0.98);
  cairo_paint(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Part", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "L", "");
  cairo_tag_begin(cr, "LI", "");
  cairo_tag_begin(cr, "Lbl", "");
  cairo_move_to(cr, 12.0, 24.0);
  cairo_show_text(cr, "1");
  cairo_tag_end(cr, "Lbl");
  cairo_tag_begin(cr, "LBody", "");
  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "uri='https://example.com/structure/cover'");
  cairo_move_to(cr, 24.0, 24.0);
  cairo_show_text(cr, "structure sequence cover");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_tag_end(cr, "LBody");
  cairo_tag_end(cr, "LI");
  cairo_tag_end(cr, "L");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Part");
  cairo_tag_end(cr, "Document");
}

static void cairoon_test_draw_structure_sequence_table(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.08, 0.35, 0.62, 0.65);
  cairo_rectangle(cr, 16.0, 34.0, 84.0, 24.0);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='structure-sequence-dest' x=16 y=72");
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "Table", "");
  cairo_tag_begin(cr, "TR", "");
  cairo_tag_begin(cr, "TH", "");
  cairo_move_to(cr, 16.0, 72.0);
  cairo_show_text(cr, "sequence heading");
  cairo_tag_end(cr, "TH");
  cairo_tag_begin(cr, "TD", "");
  cairo_tag_begin(cr, "P", "");
  cairo_move_to(cr, 16.0, 84.0);
  cairo_show_text(cr, "sequence retained table");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "TD");
  cairo_tag_end(cr, "TR");
  cairo_tag_end(cr, "Table");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  cairo_tag_end(cr, CAIRO_TAG_DEST);
}

static void cairoon_test_draw_structure_sequence_figure(cairo_t *cr) {
  cairo_set_source_rgba(cr, 0.78, 0.16, 0.20, 0.58);
  cairo_arc(cr, 92.0, 48.0, 14.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "Figure", "");
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='structure-sequence-dest'");
  cairo_move_to(cr, 18.0, 78.0);
  cairo_show_text(cr, "sequence figure link");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_tag_end(cr, "Figure");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
}

static void cairoon_test_draw_structure_sequence_final(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.96, 0.92, 0.84);
  cairo_paint(cr);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "P", "");
  cairo_tag_begin(cr, "Span", "");
  cairo_move_to(cr, 12.0, 68.0);
  cairo_show_text(cr, "structure sequence final");
  cairo_tag_end(cr, "Span");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
}

static cairo_status_t cairoon_test_draw_backend_structure_sequence(
  cairo_surface_t *surface,
  cairo_t *cr,
  int32_t kind) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 9.0);

  int root_id = CAIRO_PDF_OUTLINE_ROOT;
  int retained_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_structure_sequence_setup(
      surface,
      116.0,
      90.0,
      "seq-cover",
      CAIRO_PDF_OUTLINE_ROOT,
      "structure sequence cover",
      "page=1 pos=[12 24]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_structure_sequence_cover(cr);
    cairo_surface_copy_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_structure_sequence_setup(
      surface,
      128.0,
      96.0,
      "seq-retained",
      root_id,
      "structure sequence retained",
      "page=2 pos=[16 72]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &retained_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_structure_sequence_resize_non_svg(
      surface,
      kind,
      128.0,
      96.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_structure_sequence_table(cr);
    cairo_copy_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_structure_sequence_setup(
      surface,
      128.0,
      96.0,
      "seq-context-copy",
      retained_id,
      "structure sequence context copy",
      "page=3 pos=[18 78]",
      CAIRO_PDF_OUTLINE_FLAG_BOLD,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_structure_sequence_resize_non_svg(
      surface,
      kind,
      128.0,
      96.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_structure_sequence_figure(cr);
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_structure_sequence_setup(
      surface,
      96.0,
      108.0,
      "seq-final",
      root_id,
      "structure sequence final",
      "page=4 pos=[12 68]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_structure_sequence_resize_non_svg(
      surface,
      kind,
      96.0,
      108.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_test_draw_structure_sequence_final(cr);
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_structure_sequence_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_structure_sequence(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_structure_sequence(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_structure_sequence_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 116.0, 90.0);
      return cairoon_test_render_backend_structure_sequence_surface(
        surface,
        kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 116.0, 90.0);
      return cairoon_test_render_backend_structure_sequence_surface(
        surface,
        kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 116.0, 90.0);
      return cairoon_test_render_backend_structure_sequence_surface(
        surface,
        kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
