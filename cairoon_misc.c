#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_version_string(void) {
  return cairoon_copy_c_string(cairo_version_string());
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_status_to_string(cairo_status_t status) {
  return cairoon_copy_c_string(cairo_status_to_string(status));
}

