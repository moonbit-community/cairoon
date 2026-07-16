#include "cairoon_test_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_surface_poison_with_invalid_fallback(
  CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }

  cairo_surface_set_fallback_resolution(surface->ptr, 0.0, 72.0);
  return cairo_surface_status(surface->ptr);
}
