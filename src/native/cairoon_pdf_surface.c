#include "cairoon_private.h"

#if CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>
#endif

static cairo_status_t cairoon_pdf_surface_require(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_PDF_SURFACE
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_PDF) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

#if CAIRO_HAS_PDF_SURFACE
static int cairoon_pdf_version_is_supported(int32_t version) {
  const cairo_pdf_version_t *versions = NULL;
  int num_versions = 0;
  cairo_pdf_get_versions(&versions, &num_versions);
  for (int index = 0; index < num_versions; index++) {
    if ((int32_t)versions[index] == version) {
      return 1;
    }
  }
  return 0;
}
#endif

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_pdf_surface_create(
  int32_t has_filename,
  moonbit_bytes_t filename,
  double width_in_points,
  double height_in_points,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PDF_SURFACE
  if (has_filename && filename == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  const char *name = has_filename ? (const char *)filename : NULL;
  cairo_surface_t *surface =
    cairo_pdf_surface_create(name, width_in_points, height_in_points);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned(surface);
#else
  (void)has_filename;
  (void)filename;
  (void)width_in_points;
  (void)height_in_points;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_pdf_surface_create_for_stream(
  CairoonStreamWriteCallback callback,
  void *arg,
  double width_in_points,
  double height_in_points,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PDF_SURFACE
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  void *state = cairoon_stream_state_new(callback, arg, &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface = cairo_pdf_surface_create_for_stream(
    cairoon_stream_write,
    state,
    width_in_points,
    height_in_points);
  if (surface == NULL) {
    cairoon_stream_state_destroy(state);
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }

  status = cairo_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    cairoon_stream_state_destroy(state);
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }

  status = cairoon_stream_attach(surface, state);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    cairoon_stream_state_destroy(state);
    *status_out = status;
    return cairoon_surface_wrap_owned(NULL);
  }

  return cairoon_surface_wrap_owned(surface);
#else
  (void)callback;
  if (arg != NULL) {
    moonbit_decref(arg);
  }
  (void)width_in_points;
  (void)height_in_points;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_pdf_get_version_count(cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PDF_SURFACE
  const cairo_pdf_version_t *versions = NULL;
  int num_versions = 0;
  cairo_pdf_get_versions(&versions, &num_versions);
  (void)versions;
  return (int32_t)num_versions;
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_pdf_get_version(int32_t index, cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PDF_SURFACE
  const cairo_pdf_version_t *versions = NULL;
  int num_versions = 0;
  cairo_pdf_get_versions(&versions, &num_versions);
  if (index < 0 || index >= num_versions) {
    *status_out = CAIRO_STATUS_INVALID_INDEX;
    return 0;
  }
  return (int32_t)versions[index];
#else
  (void)index;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_pdf_version_to_string(
  int32_t version,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PDF_SURFACE
  if (version < 0) {
    *status_out = CAIRO_STATUS_INVALID_STATUS;
    return moonbit_make_bytes(0, 0);
  }
  const char *str = cairo_pdf_version_to_string((cairo_pdf_version_t)version);
  if (str == NULL) {
    *status_out = CAIRO_STATUS_INVALID_STATUS;
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_c_string(str);
#else
  (void)version;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return moonbit_make_bytes(0, 0);
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pdf_surface_restrict_to_version(
  CairoonSurface *surface,
  int32_t version) {
#if CAIRO_HAS_PDF_SURFACE
  cairo_status_t status = cairoon_pdf_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (!cairoon_pdf_version_is_supported(version)) {
    return CAIRO_STATUS_INVALID_STATUS;
  }
  cairo_pdf_surface_restrict_to_version(
    surface->ptr,
    (cairo_pdf_version_t)version);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)version;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pdf_surface_set_size(
  CairoonSurface *surface,
  double width_in_points,
  double height_in_points) {
#if CAIRO_HAS_PDF_SURFACE
  cairo_status_t status = cairoon_pdf_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pdf_surface_set_size(surface->ptr, width_in_points, height_in_points);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)width_in_points;
  (void)height_in_points;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pdf_surface_set_metadata(
  CairoonSurface *surface,
  int32_t metadata,
  moonbit_bytes_t value) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_status_t status = cairoon_pdf_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (value == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  if (metadata < (int32_t)CAIRO_PDF_METADATA_TITLE ||
      metadata > (int32_t)CAIRO_PDF_METADATA_MOD_DATE) {
    return CAIRO_STATUS_INVALID_STATUS;
  }
  cairo_pdf_surface_set_metadata(
    surface->ptr,
    (cairo_pdf_metadata_t)metadata,
    (const char *)value);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)metadata;
  (void)value;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pdf_surface_set_custom_metadata(
  CairoonSurface *surface,
  moonbit_bytes_t name,
  int32_t has_value,
  moonbit_bytes_t value) {
  cairo_status_t status = cairoon_pdf_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
  if (name == NULL || (has_value && value == NULL)) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  const char *raw_value = has_value ? (const char *)value : NULL;
  cairo_pdf_surface_set_custom_metadata(
    surface->ptr,
    (const char *)name,
    raw_value);
  return cairo_surface_status(surface->ptr);
#else
  (void)name;
  (void)has_value;
  (void)value;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pdf_surface_set_page_label(
  CairoonSurface *surface,
  moonbit_bytes_t label) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_status_t status = cairoon_pdf_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (label == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_pdf_surface_set_page_label(surface->ptr, (const char *)label);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)label;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pdf_surface_set_thumbnail_size(
  CairoonSurface *surface,
  int32_t width,
  int32_t height) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_status_t status = cairoon_pdf_surface_require(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pdf_surface_set_thumbnail_size(surface->ptr, width, height);
  return cairo_surface_status(surface->ptr);
#else
  (void)surface;
  (void)width;
  (void)height;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_pdf_surface_add_outline(
  CairoonSurface *surface,
  int32_t parent_id,
  moonbit_bytes_t title,
  moonbit_bytes_t link_attributes,
  int32_t flags,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  *status_out = cairoon_pdf_surface_require(surface);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  if (title == NULL || link_attributes == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return 0;
  }
  int added_id = cairo_pdf_surface_add_outline(
    surface->ptr,
    parent_id,
    (const char *)title,
    (const char *)link_attributes,
    (cairo_pdf_outline_flags_t)flags);
  *status_out = cairo_surface_status(surface->ptr);
  return (int32_t)added_id;
#else
  (void)surface;
  (void)parent_id;
  (void)title;
  (void)link_attributes;
  (void)flags;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}
