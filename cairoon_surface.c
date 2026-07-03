#include "cairoon_private.h"

#include <stdlib.h>
#include <string.h>

static const cairo_user_data_key_t cairoon_image_surface_data_key;
static const cairo_user_data_key_t cairoon_surface_finished_key;
static const int cairoon_surface_finished_sentinel = 1;

static void cairoon_decref_user_data(void *user_data) {
  if (user_data != NULL) {
    moonbit_decref(user_data);
  }
}

static void cairoon_free_user_data(void *user_data) {
  free(user_data);
}

static cairo_status_t cairoon_surface_store_user_data(
  cairo_surface_t *surface,
  void *data) {
  return cairo_surface_set_user_data(
    surface,
    &cairoon_image_surface_data_key,
    data,
    cairoon_decref_user_data);
}

static moonbit_bytes_t cairoon_copy_image_surface_data(
  cairo_surface_t *surface,
  cairo_status_t *status_out) {
  cairo_surface_flush(surface);
  *status_out = cairo_surface_status(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  unsigned char *data = cairo_image_surface_get_data(surface);
  int32_t height = cairo_image_surface_get_height(surface);
  int32_t stride = cairo_image_surface_get_stride(surface);
  int64_t len = (int64_t)height * (int64_t)stride;
  *status_out = cairo_surface_status(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  if (data == NULL || len <= 0) {
    return moonbit_make_bytes(0, 0);
  }
  if (len > INT32_MAX) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)len, 0);
  memcpy(bytes, data, (size_t)len);
  return bytes;
}

static cairo_status_t cairoon_surface_require_type(
  CairoonSurface *surface,
  cairo_surface_type_t type) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_surface_get_type(surface->ptr) != type) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

static int cairoon_surface_is_finished(cairo_surface_t *surface) {
  return cairo_surface_get_user_data(
    surface,
    &cairoon_surface_finished_key) != NULL;
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_image_surface_create(cairo_format_t format, int32_t width, int32_t height) {
  return cairoon_surface_wrap_owned(cairo_image_surface_create(format, width, height));
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_image_surface_create_for_data(
  uint8_t *data,
  cairo_format_t format,
  int32_t width,
  int32_t height,
  int32_t stride,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (data == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  if (width < 0 || height < 0) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    moonbit_decref(data);
    return cairoon_surface_wrap_owned(NULL);
  }
  if (stride < 0) {
    *status_out = CAIRO_STATUS_INVALID_STRIDE;
    moonbit_decref(data);
    return cairoon_surface_wrap_owned(NULL);
  }

  int64_t required = (int64_t)height * (int64_t)stride;
  int64_t available = (int64_t)Moonbit_array_length(data);
  if (required > available) {
    *status_out = CAIRO_STATUS_INVALID_SIZE;
    moonbit_decref(data);
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface =
    cairo_image_surface_create_for_data(data, format, width, height, stride);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    moonbit_decref(data);
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(data);
    return cairoon_surface_wrap_owned(surface);
  }
  *status_out = cairoon_surface_store_user_data(surface, data);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    moonbit_decref(data);
    return cairoon_surface_wrap_owned(NULL);
  }
  return cairoon_surface_wrap_owned(surface);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_image_surface_create_from_png(
  moonbit_bytes_t filename,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (filename == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
#if CAIRO_HAS_PNG_FUNCTIONS
  cairo_surface_t *surface =
    cairo_image_surface_create_from_png((const char *)filename);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  *status_out = CAIRO_STATUS_PNG_ERROR;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_image_surface_create_from_png_stream(
  CairoonStreamReadCallback callback,
  void *arg,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PNG_FUNCTIONS
  void *state = cairoon_stream_read_state_new(callback, arg, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface =
    cairo_image_surface_create_from_png_stream(cairoon_stream_read, state);
  cairoon_stream_read_state_destroy(state);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)callback;
  if (arg != NULL) {
    moonbit_decref(arg);
  }
  *status_out = CAIRO_STATUS_PNG_ERROR;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_recording_surface_create(
  cairo_content_t content,
  int32_t has_extents,
  double x,
  double y,
  double width,
  double height,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#ifdef CAIRO_HAS_RECORDING_SURFACE
  cairo_rectangle_t extents = {x, y, width, height};
  cairo_surface_t *surface = cairo_recording_surface_create(
    content,
    has_extents ? &extents : NULL);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)content;
  (void)has_extents;
  (void)x;
  (void)y;
  (void)width;
  (void)height;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_create_similar(
  CairoonSurface *other,
  cairo_content_t content,
  int32_t width,
  int32_t height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(other);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface =
    cairo_surface_create_similar(other->ptr, content, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_create_similar_image(
  CairoonSurface *other,
  cairo_format_t format,
  int32_t width,
  int32_t height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(other);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface =
    cairo_surface_create_similar_image(other->ptr, format, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_create_for_rectangle(
  CairoonSurface *target,
  double x,
  double y,
  double width,
  double height,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(target);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface =
    cairo_surface_create_for_rectangle(target->ptr, x, y, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned_with_base(surface, target);
}

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
cairo_status_t cairoon_surface_status(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairoon_surface_is_finished(surface->ptr)) {
    return CAIRO_STATUS_SURFACE_FINISHED;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_surface_equal(CairoonSurface *surface, CairoonSurface *other) {
  if (surface == NULL || other == NULL || surface->ptr == NULL ||
      other->ptr == NULL) {
    return 0;
  }
  return surface->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_surface_hash(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)surface->ptr;
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
cairo_content_t cairoon_surface_get_content(CairoonSurface *surface) {
  if (cairoon_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_CONTENT_COLOR_ALPHA;
  }
  return cairo_surface_get_content(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_surface_type_t cairoon_surface_get_type(CairoonSurface *surface) {
  if (cairoon_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_SURFACE_TYPE_IMAGE;
  }
  return cairo_surface_get_type(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_write_to_png(
  CairoonSurface *surface,
  moonbit_bytes_t filename) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (filename == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
#if CAIRO_HAS_PNG_FUNCTIONS
  return cairo_surface_write_to_png(surface->ptr, (const char *)filename);
#else
  return CAIRO_STATUS_PNG_ERROR;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_write_to_png_stream(
  CairoonSurface *surface,
  CairoonStreamWriteCallback callback,
  void *arg) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    if (arg != NULL) {
      moonbit_decref(arg);
    }
    return status;
  }
#if CAIRO_HAS_PNG_FUNCTIONS
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairo_surface_write_to_png_stream(
    surface->ptr,
    cairoon_stream_write,
    state);
  cairoon_stream_state_destroy(state);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_surface_status(surface->ptr);
#else
  (void)callback;
  if (arg != NULL) {
    moonbit_decref(arg);
  }
  return CAIRO_STATUS_PNG_ERROR;
#endif
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

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_finish(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairoon_surface_is_finished(surface->ptr)) {
    return CAIRO_STATUS_SUCCESS;
  }
  status = cairo_surface_set_user_data(
    surface->ptr,
    &cairoon_surface_finished_key,
    (void *)&cairoon_surface_finished_sentinel,
    NULL);
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
cairo_status_t cairoon_surface_mark_dirty(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_mark_dirty(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_mark_dirty_rectangle(
  CairoonSurface *surface,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_mark_dirty_rectangle(surface->ptr, x, y, width, height);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_recording_surface_ink_extents(
  CairoonSurface *surface,
  double *x0,
  double *y0,
  double *width,
  double *height) {
#ifdef CAIRO_HAS_RECORDING_SURFACE
  cairo_status_t status =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_RECORDING);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_recording_surface_ink_extents(
    surface->ptr,
    x0,
    y0,
    width,
    height);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)x0;
  (void)y0;
  (void)width;
  (void)height;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_recording_surface_get_extents(
  CairoonSurface *surface,
  int32_t *has_extents,
  double *x,
  double *y,
  double *width,
  double *height) {
  *has_extents = 0;
#ifdef CAIRO_HAS_RECORDING_SURFACE
  cairo_status_t status =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_RECORDING);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_t extents;
  cairo_bool_t result = cairo_recording_surface_get_extents(
    surface->ptr,
    &extents);
  if (result) {
    *has_extents = 1;
    *x = extents.x;
    *y = extents.y;
    *width = extents.width;
    *height = extents.height;
  }
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)x;
  (void)y;
  (void)width;
  (void)height;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_device_offset(
  CairoonSurface *surface,
  double x_offset,
  double y_offset) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_set_device_offset(surface->ptr, x_offset, y_offset);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_get_device_offset(
  CairoonSurface *surface,
  double *x_offset,
  double *y_offset) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_get_device_offset(surface->ptr, x_offset, y_offset);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_device_scale(
  CairoonSurface *surface,
  double x_scale,
  double y_scale) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t transform;
  cairo_matrix_init_scale(&transform, x_scale, y_scale);
  status = cairo_matrix_invert(&transform);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_set_device_scale(surface->ptr, x_scale, y_scale);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_get_device_scale(
  CairoonSurface *surface,
  double *x_scale,
  double *y_scale) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_get_device_scale(surface->ptr, x_scale, y_scale);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_set_fallback_resolution(
  CairoonSurface *surface,
  double x_pixels_per_inch,
  double y_pixels_per_inch) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_set_fallback_resolution(
    surface->ptr,
    x_pixels_per_inch,
    y_pixels_per_inch);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_get_fallback_resolution(
  CairoonSurface *surface,
  double *x_pixels_per_inch,
  double *y_pixels_per_inch) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_get_fallback_resolution(
    surface->ptr,
    x_pixels_per_inch,
    y_pixels_per_inch);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_surface_has_show_text_glyphs(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_surface_has_show_text_glyphs(surface->ptr);
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
int32_t cairoon_image_surface_get_width(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_IMAGE);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_image_surface_get_width(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_height(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_IMAGE);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_image_surface_get_height(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_stride(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_IMAGE);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_image_surface_get_stride(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_format_t cairoon_image_surface_get_format(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_IMAGE);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FORMAT_INVALID;
  }
  return cairo_image_surface_get_format(surface->ptr);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_image_surface_copy_data(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  *status_out =
    cairoon_surface_require_type(surface, CAIRO_SURFACE_TYPE_IMAGE);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_image_surface_data(surface->ptr, status_out);
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
