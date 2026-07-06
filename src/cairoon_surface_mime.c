#include "cairoon_private.h"

#include <stdlib.h>
#include <string.h>

static void cairoon_free_user_data(void *user_data) {
  free(user_data);
}
MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_mime_data(
  CairoonSurface *surface,
  moonbit_bytes_t mime_type,
  moonbit_bytes_t data) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (mime_type == NULL || data == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }

  int32_t len = Moonbit_array_length(data);
  size_t alloc_len = len > 0 ? (size_t)len : 1;
  unsigned char *copy = malloc(alloc_len);
  if (copy == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  if (len > 0) {
    memcpy(copy, data, (size_t)len);
  }

  status = cairo_surface_set_mime_data(
    surface->ptr,
    (const char *)mime_type,
    copy,
    (unsigned long)len,
    cairoon_free_user_data,
    copy);
  if (status != CAIRO_STATUS_SUCCESS) {
    free(copy);
  }
  return status;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_clear_mime_data(
  CairoonSurface *surface,
  moonbit_bytes_t mime_type) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (mime_type == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_surface_set_mime_data(
    surface->ptr,
    (const char *)mime_type,
    NULL,
    0,
    NULL,
    NULL);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_surface_get_mime_data(
  CairoonSurface *surface,
  moonbit_bytes_t mime_type,
  int32_t *has_data,
  cairo_status_t *status_out) {
  *has_data = 0;
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  if (mime_type == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return moonbit_make_bytes(0, 0);
  }

  const unsigned char *data = NULL;
  unsigned long len = 0;
  cairo_surface_get_mime_data(
    surface->ptr,
    (const char *)mime_type,
    &data,
    &len);
  *status_out = cairo_surface_status(surface->ptr);
  if (*status_out != CAIRO_STATUS_SUCCESS || data == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  if (len > (unsigned long)INT32_MAX) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    return moonbit_make_bytes(0, 0);
  }

  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)len, 0);
  if (len > 0) {
    memcpy(bytes, data, (size_t)len);
  }
  *has_data = 1;
  return bytes;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_surface_supports_mime_type(
  CairoonSurface *surface,
  moonbit_bytes_t mime_type,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  if (mime_type == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return 0;
  }
  int32_t supported = cairo_surface_supports_mime_type(
    surface->ptr,
    (const char *)mime_type);
  *status_out = cairo_surface_status(surface->ptr);
  return supported;
}
