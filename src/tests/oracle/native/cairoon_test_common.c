#include "cairoon_test_private.h"

cairo_status_t cairoon_test_apply_group_compositing(
  cairo_t *cr,
  double width,
  double height) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.25);
  cairo_paint(cr);
  cairo_status_t status = cairo_status(cr);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_push_group_with_content(cr, CAIRO_CONTENT_COLOR_ALPHA);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.8);
    cairo_rectangle(cr, 2.0, 2.0, width - 5.0, height - 6.0);
    cairo_fill(cr);
    cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 0.55);
    cairo_rectangle(cr, 5.0, 5.0, width - 7.0, height - 7.0);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pop_group_to_source(cr);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_paint_with_alpha(cr, 0.6);
    status = cairo_status(cr);
  }
  return status;
}
cairo_status_t cairoon_test_apply_even_odd_fill(
  cairo_t *cr,
  double width,
  double height) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.25);
  cairo_paint(cr);
  cairo_status_t status = cairo_status(cr);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_fill_rule(cr, CAIRO_FILL_RULE_EVEN_ODD);
    cairo_rectangle(cr, 2.0, 2.0, width - 4.0, height - 4.0);
    cairo_rectangle(cr, 5.0, 5.0, width - 10.0, height - 10.0);
    cairo_set_source_rgba(cr, 0.0, 0.85, 0.25, 0.9);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  return status;
}

cairo_status_t cairoon_test_apply_mask_surface(cairo_t *cr) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  cairo_t *ctx = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    ctx = cairo_create(surface);
    status = cairo_status(ctx);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 0.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 0.5);
    cairo_rectangle(ctx, 1.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    status = cairo_status(ctx);
  }
  if (ctx != NULL) {
    cairo_destroy(ctx);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_mask_surface(cr, surface, 4.0, 4.0);
    status = cairo_status(cr);
  }
  cairo_surface_destroy(surface);
  return status;
}
