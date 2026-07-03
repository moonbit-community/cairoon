#include "cairoon_private.h"

#if CAIRO_HAS_SCRIPT_SURFACE
#include <cairo-script.h>
#else
typedef enum {
  CAIRO_SCRIPT_MODE_ASCII = 0,
  CAIRO_SCRIPT_MODE_BINARY = 1
} cairo_script_mode_t;
#endif

cairo_status_t cairoon_device_status(CairoonDevice *device) {
  if (device == NULL || device->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_device_status(device->ptr);
}

static cairo_status_t cairoon_script_device_require(CairoonDevice *device) {
  cairo_status_t status = cairoon_device_status(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  if (cairo_device_get_type(device->ptr) != CAIRO_DEVICE_TYPE_SCRIPT) {
    return CAIRO_STATUS_DEVICE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

static cairo_status_t cairoon_recording_surface_require(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#ifdef CAIRO_HAS_RECORDING_SURFACE
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_RECORDING) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
CairoonDevice *cairoon_script_device_create(
  moonbit_bytes_t filename,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SCRIPT_SURFACE
  if (filename == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_device_wrap_owned(NULL);
  }
  cairo_device_t *device = cairo_script_create((const char *)filename);
  if (device == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_device_wrap_owned(NULL);
  }
  *status_out = cairo_device_status(device);
  return cairoon_device_wrap_owned(device);
#else
  (void)filename;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_device_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonDevice *cairoon_script_device_create_for_stream(
  CairoonStreamWriteCallback callback,
  void *arg,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_SCRIPT_SURFACE
  void *state = cairoon_stream_state_new(callback, arg, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_device_wrap_owned(NULL);
  }

  cairo_device_t *device =
    cairo_script_create_for_stream(cairoon_stream_write, state);
  if (device == NULL) {
    cairoon_stream_state_destroy(state);
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_device_wrap_owned(NULL);
  }
  *status_out = cairo_device_status(device);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    cairoon_stream_state_destroy(state);
    return cairoon_device_wrap_owned(device);
  }
  *status_out = cairoon_stream_attach_device(device, state);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    cairo_device_destroy(device);
    return cairoon_device_wrap_owned(NULL);
  }
  return cairoon_device_wrap_owned(device);
#else
  (void)callback;
  if (arg != NULL) {
    moonbit_decref(arg);
  }
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_device_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_device_equal(CairoonDevice *device, CairoonDevice *other) {
  if (device == NULL || other == NULL || device->ptr == NULL ||
      other->ptr == NULL) {
    return 0;
  }
  return device->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_device_hash(CairoonDevice *device) {
  if (device == NULL || device->ptr == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)device->ptr;
}

MOONBIT_FFI_EXPORT
cairo_device_type_t cairoon_device_get_type(
  CairoonDevice *device,
  cairo_status_t *status_out) {
  *status_out = cairoon_device_status(device);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return CAIRO_DEVICE_TYPE_SCRIPT;
  }
  return cairo_device_get_type(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_device_finish(CairoonDevice *device) {
  cairo_status_t status = cairoon_device_status(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_finish(device->ptr);
  return cairo_device_status(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_device_flush(CairoonDevice *device) {
  cairo_status_t status = cairoon_device_status(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_flush(device->ptr);
  return cairo_device_status(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_device_acquire(CairoonDevice *device) {
  cairo_status_t status = cairoon_device_status(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_device_acquire(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_device_release(CairoonDevice *device) {
  cairo_status_t status = cairoon_device_status(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_release(device->ptr);
  return cairo_device_status(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_script_mode_t cairoon_script_device_get_mode(
  CairoonDevice *device,
  cairo_status_t *status_out) {
  *status_out = cairoon_script_device_require(device);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return CAIRO_SCRIPT_MODE_ASCII;
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  return cairo_script_get_mode(device->ptr);
#else
  return CAIRO_SCRIPT_MODE_ASCII;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_script_device_set_mode(
  CairoonDevice *device,
  cairo_script_mode_t mode) {
  cairo_status_t status = cairoon_script_device_require(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  cairo_script_set_mode(device->ptr, mode);
#else
  (void)mode;
#endif
  return cairo_device_status(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_script_device_write_comment(
  CairoonDevice *device,
  moonbit_bytes_t comment) {
  cairo_status_t status = cairoon_script_device_require(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (comment == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  cairo_script_write_comment(device->ptr, (const char *)comment, -1);
#endif
  return cairo_device_status(device->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_script_device_from_recording_surface(
  CairoonDevice *device,
  CairoonSurface *surface) {
  cairo_status_t status = cairoon_script_device_require(device);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_recording_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  return cairo_script_from_recording_surface(device->ptr, surface->ptr);
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_script_surface_create(
  CairoonDevice *device,
  cairo_content_t content,
  double width,
  double height,
  cairo_status_t *status_out) {
  *status_out = cairoon_script_device_require(device);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  cairo_surface_t *surface =
    cairo_script_surface_create(device->ptr, content, width, height);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)content;
  (void)width;
  (void)height;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_script_surface_create_for_target(
  CairoonDevice *device,
  CairoonSurface *target,
  cairo_status_t *status_out) {
  *status_out = cairoon_script_device_require(device);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairoon_surface_status(target);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
#if CAIRO_HAS_SCRIPT_SURFACE
  cairo_surface_t *surface =
    cairo_script_surface_create_for_target(device->ptr, target->ptr);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonDevice *cairoon_surface_get_device(
  CairoonSurface *surface,
  int32_t *has_device,
  cairo_status_t *status_out) {
  *has_device = 0;
  *status_out = cairoon_surface_status(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_device_wrap_owned(NULL);
  }
  cairo_device_t *device = cairo_surface_get_device(surface->ptr);
  *status_out = cairo_surface_status(surface->ptr);
  if (*status_out != CAIRO_STATUS_SUCCESS || device == NULL) {
    return cairoon_device_wrap_owned(NULL);
  }
  *has_device = 1;
  *status_out = cairo_device_status(device);
  return cairoon_device_wrap_borrowed(device);
}
