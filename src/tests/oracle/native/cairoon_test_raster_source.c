#include "cairoon_test_private.h"

MOONBIT_FFI_EXPORT
int32_t cairoon_test_raster_surface_owner_count(CairoonSurface *surface) {
  return cairoon_raster_source_surface_owner_count(surface);
}
