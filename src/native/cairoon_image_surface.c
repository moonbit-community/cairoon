#include "cairoon_private.h"

#include <string.h>

static const cairo_user_data_key_t cairoon_image_surface_data_key;

static void cairoon_decref_user_data(void *user_data) {
  if (user_data != NULL) {
    moonbit_decref(user_data);
  }
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

cairo_status_t cairoon_image_surface_release_data(cairo_surface_t *surface) {
  if (surface == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  if (cairo_surface_get_user_data(surface, &cairoon_image_surface_data_key) ==
      NULL) {
    return CAIRO_STATUS_SUCCESS;
  }
  return cairo_surface_set_user_data(
    surface,
    &cairoon_image_surface_data_key,
    NULL,
    NULL);
}

moonbit_bytes_t cairoon_copy_image_surface_data(
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
int32_t cairoon_image_surface_has_data_user_data(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return 0;
  }
  return cairo_surface_get_user_data(
    surface->ptr,
    &cairoon_image_surface_data_key) != NULL;
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
