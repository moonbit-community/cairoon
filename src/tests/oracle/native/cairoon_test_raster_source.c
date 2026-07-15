#include "cairoon_test_private.h"

MOONBIT_FFI_EXPORT
int32_t cairoon_test_raster_surface_owner_count(CairoonSurface *surface) {
  return cairoon_raster_source_surface_owner_count(surface);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_test_surface_reference_count(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return -1;
  }
  return (int32_t)cairo_surface_get_reference_count(surface->ptr);
}
