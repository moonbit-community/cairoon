#include "cairoon_test_vector_private.h"

#include <string.h>

cairo_status_t cairoon_test_draw_pdf_uri_tag(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/direct'");
  cairo_rectangle(cr, 1.0, 1.0, 8.0, 8.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_pdf_dest_tag(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='cairoon-direct-dest'");
  cairo_rectangle(cr, 1.0, 1.0, 3.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
  cairo_tag_begin(
    cr,
    CAIRO_TAG_DEST,
    "name='cairoon-direct-dest' x=6 y=6");
  cairo_rectangle(cr, 6.0, 6.0, 3.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_DEST);
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_pdf_struct_tag(cairo_t *cr) {
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "H1", "");
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_rectangle(cr, 1.0, 1.0, 8.0, 2.0);
  cairo_fill(cr);
  cairo_tag_end(cr, "H1");

  cairo_tag_begin(cr, "P", "");
  cairo_set_source_rgb(cr, 0.25, 0.25, 0.25);
  cairo_rectangle(cr, 1.0, 5.0, 8.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  return cairo_status(cr);
}

static void cairoon_test_select_pdf_tag_font(cairo_t *cr) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 12.0);
}

cairo_status_t cairoon_test_draw_pdf_uri_text_tag(cairo_t *cr) {
  cairoon_test_select_pdf_tag_font(cr);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/'");
  cairo_move_to(cr, 10.0, 20.0);
  cairo_show_text(cr, "example link");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_pdf_dest_text_tag(cairo_t *cr) {
  cairoon_test_select_pdf_tag_font(cr);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='cairoon-dest'");
  cairo_move_to(cr, 10.0, 20.0);
  cairo_show_text(cr, "jump to destination");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='cairoon-dest' x=10 y=60");
  cairo_move_to(cr, 10.0, 60.0);
  cairo_show_text(cr, "destination");
  cairo_tag_end(cr, CAIRO_TAG_DEST);
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_pdf_struct_text_tag(cairo_t *cr) {
  cairoon_test_select_pdf_tag_font(cr);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "H1", "");
  cairo_move_to(cr, 10.0, 20.0);
  cairo_show_text(cr, "Heading");
  cairo_tag_end(cr, "H1");
  cairo_tag_begin(cr, "P", "");
  cairo_move_to(cr, 10.0, 40.0);
  cairo_show_text(cr, "Paragraph");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_tagged_show_text_glyphs(cairo_t *cr) {
  const char *text = "a";
  int text_len = (int)strlen(text);
  cairo_glyph_t *glyphs = NULL;
  int num_glyphs = 0;
  cairo_text_cluster_t *clusters = NULL;
  int num_clusters = 0;
  cairo_text_cluster_flags_t flags = 0;

  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 4.0);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/text-glyphs'");

  cairo_status_t status = cairo_scaled_font_text_to_glyphs(
    cairo_get_scaled_font(cr),
    1.0,
    6.5,
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

  cairo_tag_end(cr, CAIRO_TAG_LINK);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(cr);
  }
  cairo_glyph_free(glyphs);
  cairo_text_cluster_free(clusters);
  return status;
}

cairo_status_t cairoon_test_draw_tagged_multi_page_text(cairo_t *cr) {
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 4.0);
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);

  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/multipage'");
  cairo_move_to(cr, 1.0, 4.0);
  cairo_show_text(cr, "one");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_show_page(cr);
  if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
    return cairo_status(cr);
  }

  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='cairoon-multi-dest'");
  cairo_move_to(cr, 1.0, 4.0);
  cairo_show_text(cr, "two");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='cairoon-multi-dest' x=1 y=7");
  cairo_move_to(cr, 1.0, 7.0);
  cairo_show_text(cr, "dst");
  cairo_tag_end(cr, CAIRO_TAG_DEST);

  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "P", "");
  cairo_move_to(cr, 1.0, 9.0);
  cairo_show_text(cr, "doc");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  cairo_show_page(cr);
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_mixed_tag_vector(cairo_t *cr) {
  cairo_save(cr);
  cairo_rectangle(cr, 0.5, 0.5, 9.0, 9.0);
  cairo_clip(cr);
  cairo_set_source_rgba(cr, 0.85, 0.9, 1.0, 1.0);
  cairo_paint(cr);
  cairo_restore(cr);

  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_set_line_width(cr, 0.75);
  double dashes[] = {1.0, 0.75};
  cairo_set_dash(cr, dashes, 2, 0.25);
  cairo_move_to(cr, 1.0, 1.0);
  cairo_line_to(cr, 9.0, 1.0);
  cairo_stroke(cr);
  cairo_set_dash(cr, NULL, 0, 0.0);

  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 3.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/mixed'");
  cairo_move_to(cr, 1.0, 3.5);
  cairo_show_text(cr, "mix");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='cairoon-mixed-dest'");
  cairo_rectangle(cr, 1.0, 5.0, 3.0, 2.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='cairoon-mixed-dest' x=7 y=8");
  cairo_arc(cr, 7.0, 8.0, 1.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_DEST);

  cairo_set_source_rgb(cr, 0.15, 0.15, 0.15);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "P", "");
  cairo_move_to(cr, 4.0, 9.0);
  cairo_show_text(cr, "doc");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_layered_multi_page(cairo_t *cr) {
  double dashes[] = {1.0, 0.75};

  cairo_save(cr);
  cairo_rectangle(cr, 0.75, 0.75, 8.5, 8.5);
  cairo_clip(cr);
  cairo_set_source_rgb(cr, 0.8, 0.9, 1.0);
  cairo_paint(cr);
  cairo_restore(cr);

  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_set_line_width(cr, 0.75);
  cairo_set_dash(cr, dashes, 2, 0.25);
  cairo_move_to(cr, 1.0, 1.0);
  cairo_line_to(cr, 9.0, 3.0);
  cairo_stroke(cr);
  cairo_set_dash(cr, NULL, 0, 0.0);

  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 3.0);
  cairo_move_to(cr, 1.0, 8.5);
  cairo_show_text(cr, "page one");
  cairo_show_page(cr);
  if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
    return cairo_status(cr);
  }

  cairo_status_t status = cairoon_test_apply_surface_pattern(cr, 10.0, 10.0);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_test_apply_mask_surface(cr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_show_page(cr);
  if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
    return cairo_status(cr);
  }

  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 3.0);

  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/layered'");
  cairo_move_to(cr, 1.0, 3.0);
  cairo_show_text(cr, "layered link");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "P", "");
  cairo_move_to(cr, 1.0, 7.0);
  cairo_show_text(cr, "layered doc");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");

  cairo_show_page(cr);
  return cairo_status(cr);
}

cairo_status_t cairoon_test_draw_wide_multi_page_tag_vector(cairo_t *cr) {
  cairo_save(cr);
  cairo_rectangle(cr, 0.75, 0.75, 8.5, 8.5);
  cairo_clip(cr);
  cairo_set_source_rgb(cr, 0.9, 0.92, 1.0);
  cairo_paint(cr);
  cairo_restore(cr);

  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 3.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/wide'");
  cairo_move_to(cr, 1.0, 4.0);
  cairo_show_text(cr, "wide uri");
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_show_page(cr);
  if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
    return cairo_status(cr);
  }

  cairo_status_t status = cairoon_test_apply_surface_pattern(cr, 10.0, 10.0);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='cairoon-wide-dest'");
  cairo_rectangle(cr, 1.0, 1.0, 4.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  cairo_show_page(cr);
  if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
    return cairo_status(cr);
  }

  cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='cairoon-wide-dest' x=1 y=5");
  cairo_arc(cr, 2.0, 5.0, 1.0, 0.0, 6.283185307179586);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_DEST);

  cairo_set_source_rgb(cr, 0.1, 0.1, 0.1);
  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 3.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "P", "");
  cairo_move_to(cr, 1.0, 8.5);
  cairo_show_text(cr, "wide doc");
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  cairo_show_page(cr);
  return cairo_status(cr);
}
