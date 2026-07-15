#include <stddef.h>
#include <string.h>

#include <cairo.h>
#include <cairo-svg.h>
#include <fontconfig/fontconfig.h>

static cairo_status_t show_text_glyphs(
  cairo_t *ctx,
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
    cairo_get_scaled_font(ctx),
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
      ctx,
      text,
      text_len,
      glyphs,
      num_glyphs,
      clusters,
      num_clusters,
      flags);
    status = cairo_status(ctx);
  }
  cairo_glyph_free(glyphs);
  cairo_text_cluster_free(clusters);
  return status;
}

static cairo_status_t render_document(const char *filename) {
  cairo_surface_t *surface =
    cairo_svg_surface_create(filename, 10.0, 10.0);
  cairo_t *ctx = cairo_create(surface);

  cairo_save(ctx);
  cairo_push_group_with_content(ctx, CAIRO_CONTENT_COLOR_ALPHA);
  cairo_pattern_t *gradient = cairo_pattern_create_linear(0.0, 0.0, 10.0, 0.0);
  cairo_pattern_add_color_stop_rgba(gradient, 0.0, 1.0, 0.0, 0.0, 1.0);
  cairo_pattern_add_color_stop_rgba(gradient, 1.0, 0.0, 0.0, 1.0, 1.0);
  cairo_rectangle(ctx, 0.0, 0.0, 10.0, 10.0);
  cairo_set_source(ctx, gradient);
  cairo_fill(ctx);
  cairo_pattern_destroy(gradient);
  cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 0.45);
  cairo_arc(ctx, 5.0, 5.0, 3.0, 0.0, 6.283185307179586);
  cairo_fill(ctx);
  cairo_pattern_t *group = cairo_pop_group(ctx);
  cairo_translate(ctx, 1.0, 0.5);
  cairo_scale(ctx, 0.8, 0.8);
  cairo_set_source(ctx, group);
  cairo_paint_with_alpha(ctx, 0.65);
  cairo_pattern_destroy(group);
  cairo_restore(ctx);

  cairo_select_font_face(
    ctx,
    "serif",
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(ctx, 3.0);
  cairo_set_source_rgb(ctx, 0.0, 0.0, 0.0);
  cairo_tag_begin(
    ctx,
    CAIRO_TAG_LINK,
    "uri='https://example.com/grouped-glyphs'");
  cairo_status_t status = show_text_glyphs(ctx, 1.0, 6.5, "ffi");
  cairo_tag_end(ctx, CAIRO_TAG_LINK);
  cairo_show_page(ctx);

  cairo_set_source_rgb(ctx, 0.0, 0.35, 0.8);
  cairo_tag_begin(ctx, CAIRO_TAG_LINK, "dest='cairoon-grouped-dest'");
  cairo_rectangle(ctx, 1.0, 1.0, 4.0, 2.0);
  cairo_fill(ctx);
  cairo_tag_end(ctx, CAIRO_TAG_LINK);

  cairo_set_source_rgb(ctx, 0.85, 0.1, 0.1);
  cairo_tag_begin(
    ctx,
    CAIRO_TAG_DEST,
    "name='cairoon-grouped-dest' x=6 y=3");
  cairo_move_to(ctx, 6.0, 3.0);
  cairo_show_text(ctx, "dest");
  cairo_tag_end(ctx, CAIRO_TAG_DEST);

  cairo_set_source_rgb(ctx, 0.1, 0.1, 0.1);
  cairo_tag_begin(ctx, "Document", "");
  cairo_tag_begin(ctx, "Sect", "");
  cairo_tag_begin(ctx, "P", "");
  if (status == CAIRO_STATUS_SUCCESS) {
    status = show_text_glyphs(ctx, 1.0, 8.5, "doc");
  }
  cairo_tag_end(ctx, "P");
  cairo_tag_end(ctx, "Sect");
  cairo_tag_end(ctx, "Document");
  cairo_show_page(ctx);

  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_status(ctx);
  }
  cairo_destroy(ctx);
  cairo_surface_finish(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_surface_status(surface);
  }
  cairo_surface_destroy(surface);
  return status;
}

int main(void) {
  cairo_status_t status =
    render_document("/tmp/cairoon-recording-probe-first.svg");
  if (status == CAIRO_STATUS_SUCCESS) {
    status = render_document("/tmp/cairoon-recording-probe-second.svg");
  }
  cairo_debug_reset_static_data();
  FcFini();
  return status == CAIRO_STATUS_SUCCESS ? 0 : 1;
}
