#include "cairoon_test_vector_private.h"

cairo_status_t cairoon_test_render_ps_dsc_features(const char *name) {
#if CAIRO_HAS_PS_SURFACE
  cairo_surface_t *surface = cairo_ps_surface_create(name, 12.0, 12.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_ps_surface_restrict_to_level(surface, CAIRO_PS_LEVEL_2);
    cairo_ps_surface_dsc_begin_setup(surface);
    cairo_ps_surface_dsc_comment(surface, "%%Title: Cairoon PS Combined");
    cairo_ps_surface_dsc_comment(
      surface,
      "%%IncludeFeature: *MediaColor White");
    cairo_ps_surface_dsc_begin_page_setup(surface);
    cairo_ps_surface_dsc_comment(surface, "%%IncludeFeature: *PageSize A4");
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
    cairo_ps_surface_dsc_begin_page_setup(surface);
    cairo_ps_surface_dsc_comment(
      surface,
      "%%IncludeFeature: *MediaType Plain");
    status = cairo_surface_status(surface);
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
