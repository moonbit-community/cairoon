#include "cairoon_private.h"

#include <string.h>

static cairo_surface_t *cairoon_image_data_current_surface(
  CairoonImageData *view) {
  if (view == NULL) {
    return NULL;
  }
  if (view->mapped_object != NULL) {
    view->surface = view->mapped_object->mapped;
  }
  return view->surface;
}

static cairo_status_t cairoon_image_data_access_status(
  CairoonImageData *view) {
  cairo_surface_t *surface = cairoon_image_data_current_surface(view);
  if (view == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  if (surface == NULL) {
    return CAIRO_STATUS_SURFACE_FINISHED;
  }
  cairo_status_t status = cairo_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (view->len > 0 && view->data == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
CairoonImageData *cairoon_image_surface_get_data(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out = cairoon_surface_status(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_IMAGE) {
    *status_out = CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }

  cairo_surface_flush(surface->ptr);
  *status_out = cairo_surface_status(surface->ptr);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }

  int32_t height = cairo_image_surface_get_height(surface->ptr);
  int32_t stride = cairo_image_surface_get_stride(surface->ptr);
  int64_t len = (int64_t)height * (int64_t)stride;
  if (len < 0 || len > INT32_MAX) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }

  uint8_t *data = cairo_image_surface_get_data(surface->ptr);
  if (data == NULL && len > 0) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }
  return cairoon_image_data_wrap(surface->ptr, data, (int32_t)len, NULL, surface);
}

MOONBIT_FFI_EXPORT
CairoonImageData *cairoon_mapped_image_surface_get_data(
  CairoonMappedImageSurface *mapped,
  cairo_status_t *status_out) {
  *status_out = cairoon_mapped_image_surface_status(mapped);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }
  if (cairo_surface_get_type(mapped->mapped) != CAIRO_SURFACE_TYPE_IMAGE) {
    *status_out = CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }

  cairo_surface_flush(mapped->mapped);
  *status_out = cairo_surface_status(mapped->mapped);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }

  int32_t height = cairo_image_surface_get_height(mapped->mapped);
  int32_t stride = cairo_image_surface_get_stride(mapped->mapped);
  int64_t len = (int64_t)height * (int64_t)stride;
  if (len < 0 || len > INT32_MAX) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }

  uint8_t *data = cairo_image_surface_get_data(mapped->mapped);
  if (data == NULL && len > 0) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_image_data_wrap(NULL, NULL, 0, NULL, NULL);
  }
  return cairoon_image_data_wrap(
    mapped->mapped,
    data,
    (int32_t)len,
    mapped,
    mapped);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_image_data_status(CairoonImageData *view) {
  return cairoon_image_data_access_status(view);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_data_length(CairoonImageData *view) {
  if (view == NULL) {
    return 0;
  }
  return view->len;
}

MOONBIT_FFI_EXPORT
uint8_t cairoon_image_data_get(
  CairoonImageData *view,
  int32_t index,
  cairo_status_t *status_out) {
  *status_out = cairoon_image_data_access_status(view);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  if (index < 0 || index >= view->len) {
    *status_out = CAIRO_STATUS_INVALID_INDEX;
    return 0;
  }
  return view->data[index];
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_image_data_set(
  CairoonImageData *view,
  int32_t index,
  uint8_t value) {
  cairo_status_t status = cairoon_image_data_access_status(view);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (index < 0 || index >= view->len) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  view->data[index] = value;
  cairo_surface_t *surface = cairoon_image_data_current_surface(view);
  cairo_surface_mark_dirty(surface);
  return cairo_surface_status(surface);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_image_data_copy(
  CairoonImageData *view,
  cairo_status_t *status_out) {
  *status_out = cairoon_image_data_access_status(view);
  if (*status_out != CAIRO_STATUS_SUCCESS || view->len <= 0) {
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t bytes = moonbit_make_bytes(view->len, 0);
  memcpy(bytes, view->data, (size_t)view->len);
  return bytes;
}
