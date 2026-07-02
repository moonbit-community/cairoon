#include "cairoon_private.h"

#include <string.h>

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_image_surface_create(cairo_format_t format, int32_t width, int32_t height) {
  return cairoon_surface_wrap_owned(cairo_image_surface_create(format, width, height));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_status(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_finish(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_finish(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_flush(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_flush(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_copy_page(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_copy_page(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_show_page(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_show_page(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_width(CairoonSurface *surface) {
  return cairo_image_surface_get_width(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_height(CairoonSurface *surface) {
  return cairo_image_surface_get_height(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_stride(CairoonSurface *surface) {
  return cairo_image_surface_get_stride(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_format_t cairoon_image_surface_get_format(CairoonSurface *surface) {
  return cairo_image_surface_get_format(surface->ptr);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_image_surface_copy_data(CairoonSurface *surface) {
  cairo_surface_flush(surface->ptr);
  unsigned char *data = cairo_image_surface_get_data(surface->ptr);
  int32_t height = cairo_image_surface_get_height(surface->ptr);
  int32_t stride = cairo_image_surface_get_stride(surface->ptr);
  int32_t len = height * stride;
  if (data == NULL || len <= 0) {
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, data, (size_t)len);
  return bytes;
}

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_surface_get_font_options(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *options = cairo_font_options_create();
  status = cairo_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(options);
  }
  cairo_surface_get_font_options(surface->ptr, options);
  *status_out = cairo_font_options_status(options);
  return cairoon_font_options_wrap_owned(options);
}

