#include "cairoon_test_vector_private.h"

cairo_status_t cairoon_test_render_svg_unit_features(const char *name) {
#if CAIRO_HAS_SVG_SURFACE
  cairo_surface_t *surface = cairo_svg_surface_create(name, 12.0, 12.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_svg_surface_restrict_to_version(surface, CAIRO_SVG_VERSION_1_2);
    cairo_svg_surface_set_document_unit(surface, CAIRO_SVG_UNIT_PX);
    status = cairo_surface_status(surface);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
    cairo_paint(cr);
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_paint(cr);
    cairo_show_page(cr);
    status = cairo_status(cr);
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
#else
  (void)name;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
