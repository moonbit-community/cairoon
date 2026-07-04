#include "cairoon_private.h"

#include <stdlib.h>
#include <string.h>

static const cairo_user_data_key_t cairoon_surface_finished_key;
static const int cairoon_surface_finished_sentinel = 1;

static void cairoon_free_user_data(void *user_data) {
  free(user_data);
}

cairo_status_t cairoon_surface_require_type(
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
