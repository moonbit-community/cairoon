#include "cairoon_test_vector_private.h"

cairo_status_t cairoon_test_draw_tagged_font_matrix_text(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.92, 0.95, 1.0);
  cairo_paint(cr);

  cairo_select_font_face(
    cr,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_matrix_t font_matrix;
  cairo_matrix_init(&font_matrix, 3.0, 0.7, -0.35, 3.8, 0.0, 0.0);
  cairo_set_font_matrix(cr, &font_matrix);

  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(
    cr,
    CAIRO_TAG_LINK,
    "uri='https://example.com/font-matrix'");
  cairo_move_to(cr, 1.1, 4.2);
  cairo_show_text(cr, "Mx");
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='font-matrix-dest' x=1 y=8");
  cairo_move_to(cr, 1.2, 8.4);
  cairo_text_path(cr, "Tx");
  cairo_set_source_rgba(cr, 0.1, 0.2, 0.8, 0.75);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_DEST);
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  return cairo_status(cr);
}
