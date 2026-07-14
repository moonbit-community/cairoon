#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_configure_backend_state_stack(
  cairo_surface_t *surface,
  int32_t kind) {
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_TITLE,
        "Cairoon State Stack");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_SUBJECT,
        "clip group mask state stack");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon state stack");
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
        "StateStack",
        "clip-group-mask");
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
      cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon State Stack");
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *MediaColor StateBlue");
      cairo_ps_surface_dsc_begin_page_setup(surface);
      cairo_ps_surface_dsc_comment(
        surface,
        "%%IncludeFeature: *PageSize StateStack");
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      cairo_svg_surface_restrict_to_version(surface, CAIRO_SVG_VERSION_1_2);
      cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_CM);
      return cairo_surface_status(surface);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

static cairo_status_t cairoon_test_pdf_state_stack_page_setup(
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

static cairo_status_t cairoon_test_state_stack_resize_non_svg(
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

static cairo_status_t cairoon_test_draw_state_stack_surface_pattern(
  cairo_t *cr) {
  cairo_save(cr);
  cairo_rectangle(cr, 8.0, 10.0, 104.0, 52.0);
  cairo_clip(cr);
  cairo_translate(cr, 8.0, 10.0);
  cairo_scale(cr, 10.4, 5.2);
  cairo_status_t status = cairoon_test_apply_surface_pattern(cr, 10.0, 10.0);
  cairo_restore(cr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_state_stack_group(cairo_t *cr) {
  cairo_save(cr);
  cairo_rectangle(cr, 10.0, 12.0, 92.0, 58.0);
  cairo_clip(cr);
  cairo_set_source_rgb(cr, 0.05, 0.07, 0.18);
  cairo_paint(cr);
  cairo_status_t status = cairo_status(cr);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 0.95, 0.20, 0.18, 0.76);
    cairo_rectangle(cr, 16.0, 20.0, 58.0, 30.0);
    cairo_fill(cr);
    cairo_set_source_rgba(cr, 0.10, 0.78, 0.46, 0.58);
    cairo_arc(cr, 66.0, 48.0, 20.0, 0.0, 6.283185307179586);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pop_group_to_source(cr);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_paint_with_alpha(cr, 0.72);
    status = cairo_status(cr);
  }
  cairo_restore(cr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_state_stack_mask(cairo_t *cr) {
  cairo_pattern_t *mask =
    cairo_pattern_create_linear(12.0, 18.0, 108.0, 86.0);
  cairo_status_t status = cairo_pattern_status(mask);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(mask, 0.0, 1.0, 1.0, 1.0, 0.0);
    cairo_pattern_add_color_stop_rgba(mask, 0.45, 1.0, 1.0, 1.0, 0.48);
    cairo_pattern_add_color_stop_rgba(mask, 1.0, 1.0, 1.0, 1.0, 1.0);
    status = cairo_pattern_status(mask);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_save(cr);
    cairo_rectangle(cr, 12.0, 18.0, 96.0, 64.0);
    cairo_clip(cr);
    cairo_set_source_rgba(cr, 0.10, 0.30, 0.92, 0.92);
    cairo_mask(cr, mask);
    status = cairo_status(cr);
    cairo_restore(cr);
    if (status == CAIRO_STATUS_SUCCESS) {
      status = cairo_status(cr);
    }
  }
  cairo_pattern_destroy(mask);
  return status;
}

static cairo_status_t cairoon_test_draw_backend_state_stack(
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
  int group_id = CAIRO_PDF_OUTLINE_ROOT;
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  if (kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_state_stack_page_setup(
      surface,
      140.0,
      90.0,
      "state-clip",
      CAIRO_PDF_OUTLINE_ROOT,
      "state clip",
      "page=1 pos=[12 76]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD,
      &root_id);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.92, 0.96, 1.0);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    status = cairoon_test_draw_state_stack_surface_pattern(cr);
    cairo_tag_end(cr, "Figure");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(
      cr,
      CAIRO_TAG_LINK,
      "uri='https://example.com/state/clip'");
    cairo_move_to(cr, 12.0, 76.0);
    cairo_show_text(cr, "clipped source pattern");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
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

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_state_stack_page_setup(
      surface,
      120.0,
      100.0,
      "state-group",
      root_id,
      "state group",
      "page=2 pos=[14 26]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC,
      &group_id);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_state_stack_resize_non_svg(surface, kind, 120.0, 100.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "Figure", "");
    status = cairoon_test_draw_state_stack_group(cr);
    cairo_tag_end(cr, "Figure");
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='state-mask-dest'");
    cairo_set_source_rgba(cr, 0.95, 0.75, 0.20, 0.82);
    cairo_rectangle(cr, 14.0, 76.0, 82.0, 12.0);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_copy_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS && kind == CAIROON_TEST_VECTOR_PDF) {
    status = cairoon_test_pdf_state_stack_page_setup(
      surface,
      120.0,
      100.0,
      "state-mask",
      group_id,
      "state mask",
      "page=3 pos=[18 88]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN,
      NULL);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_state_stack_resize_non_svg(surface, kind, 120.0, 100.0);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_state_stack_mask(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='state-mask-dest' x=18 y=88");
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_tag_begin(cr, "Span", "");
    cairo_move_to(cr, 18.0, 88.0);
    cairo_show_text(cr, "masked destination");
    cairo_tag_end(cr, "Span");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  return status;
}

static cairo_status_t cairoon_test_render_backend_state_stack_surface(
  cairo_surface_t *surface,
  int32_t kind) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_configure_backend_state_stack(surface, kind);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_draw_backend_state_stack(surface, cr, kind);
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

cairo_status_t cairoon_test_render_backend_state_stack_features(
  int32_t kind,
  const char *name) {
  if (name == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
      surface = cairo_pdf_surface_create(name, 140.0, 90.0);
      return cairoon_test_render_backend_state_stack_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 140.0, 90.0);
      return cairoon_test_render_backend_state_stack_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 140.0, 90.0);
      return cairoon_test_render_backend_state_stack_surface(surface, kind);
#else
      return CAIRO_STATUS_INVALID_STATUS;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}
