#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
CairoonMappedImageSurface *cairoon_surface_map_to_image(
  CairoonSurface *surface,
  int32_t has_extents,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_mapped_image_surface_wrap_owned(NULL, NULL, NULL);
  }

  cairo_rectangle_int_t extents = {x, y, width, height};
  cairo_surface_t *mapped = cairo_surface_map_to_image(
    surface->ptr,
    has_extents ? &extents : NULL);
  if (mapped == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_mapped_image_surface_wrap_owned(NULL, NULL, NULL);
  }

  *status_out = cairo_surface_status(mapped);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(mapped);
    return cairoon_mapped_image_surface_wrap_owned(NULL, NULL, NULL);
  }
  return cairoon_mapped_image_surface_wrap_owned(surface->ptr, mapped, surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mapped_image_surface_status(
  CairoonMappedImageSurface *surface) {
  if (surface == NULL || surface->mapped == NULL) {
    return CAIRO_STATUS_SURFACE_FINISHED;
  }
  return cairo_surface_status(surface->mapped);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_unmap_image(
  CairoonSurface *surface,
  CairoonMappedImageSurface *mapped) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_mapped_image_surface_status(mapped);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (mapped->base != surface->ptr) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  cairo_surface_unmap_image(surface->ptr, mapped->mapped);
  mapped->base = NULL;
  mapped->mapped = NULL;
  if (mapped->base_object != NULL) {
    moonbit_decref(mapped->base_object);
    mapped->base_object = NULL;
  }
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mapped_image_surface_unmap(
  CairoonMappedImageSurface *mapped) {
  cairo_status_t status = cairoon_mapped_image_surface_status(mapped);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_unmap_image(mapped->base, mapped->mapped);
  if (mapped->base_object != NULL) {
    moonbit_decref(mapped->base_object);
    mapped->base_object = NULL;
  }
  mapped->base = NULL;
  mapped->mapped = NULL;
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_mapped_image_surface_flush(
  CairoonMappedImageSurface *surface) {
  cairo_status_t status = cairoon_mapped_image_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_flush(surface->mapped);
  return cairo_surface_status(surface->mapped);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_mapped_image_surface_get_width(
  CairoonMappedImageSurface *surface) {
  if (cairoon_mapped_image_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_image_surface_get_width(surface->mapped);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_mapped_image_surface_get_height(
  CairoonMappedImageSurface *surface) {
  if (cairoon_mapped_image_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_image_surface_get_height(surface->mapped);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_mapped_image_surface_get_stride(
  CairoonMappedImageSurface *surface) {
  if (cairoon_mapped_image_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_image_surface_get_stride(surface->mapped);
}

MOONBIT_FFI_EXPORT
cairo_format_t cairoon_mapped_image_surface_get_format(
  CairoonMappedImageSurface *surface) {
  if (cairoon_mapped_image_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FORMAT_INVALID;
  }
  return cairo_image_surface_get_format(surface->mapped);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_mapped_image_surface_copy_data(
  CairoonMappedImageSurface *surface) {
  if (cairoon_mapped_image_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  return cairoon_copy_image_surface_data(surface->mapped, &status);
}
