#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_raster_source(
  cairo_content_t content,
  int32_t width,
  int32_t height) {
  return cairoon_pattern_wrap_owned(
    cairo_pattern_create_raster_source(NULL, content, width, height),
    NULL);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_set_acquire(
  CairoonPattern *pattern,
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  CairoonRasterSourceState *state = cairoon_raster_source_state_new(
    acquire,
    acquire_arg,
    NULL,
    NULL,
    &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairoon_raster_source_pattern_set_state(pattern, state);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_set_acquire_with_release(
  CairoonPattern *pattern,
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg,
  CairoonRasterSourceReleaseCallback release,
  void *release_arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  CairoonRasterSourceState *state = cairoon_raster_source_state_new(
    acquire,
    acquire_arg,
    release,
    release_arg,
    &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairoon_raster_source_pattern_set_state(pattern, state);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_set_release(
  CairoonPattern *pattern,
  CairoonRasterSourceReleaseCallback release,
  void *release_arg) {
  cairo_status_t status = CAIRO_STATUS_SUCCESS;
  CairoonRasterSourceState *state = cairoon_raster_source_state_new(
    NULL,
    NULL,
    release,
    release_arg,
    &status);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairoon_raster_source_pattern_set_state(pattern, state);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_raster_source_pattern_clear_acquire(
  CairoonPattern *pattern) {
  return cairoon_raster_source_pattern_set_state(pattern, NULL);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_raster_source_pattern_has_callbacks(
  CairoonPattern *pattern,
  int32_t *has_acquire,
  int32_t *has_release,
  cairo_status_t *status_out) {
  *has_acquire = 0;
  *has_release = 0;
  CairoonRasterSourceState *state =
    cairoon_raster_source_pattern_get_state(pattern, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS || state == NULL) {
    return 0;
  }
  *has_acquire = cairoon_raster_source_state_has_acquire(state);
  *has_release = cairoon_raster_source_state_has_release(state);
  return 1;
}

MOONBIT_FFI_EXPORT
void *cairoon_raster_source_pattern_get_acquire_callback(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  CairoonRasterSourceState *state =
    cairoon_raster_source_pattern_get_state(pattern, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return NULL;
  }
  void *arg = cairoon_raster_source_state_get_acquire_arg(state);
  if (arg == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }
  return arg;
}

MOONBIT_FFI_EXPORT
void *cairoon_raster_source_pattern_get_release_callback(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  CairoonRasterSourceState *state =
    cairoon_raster_source_pattern_get_state(pattern, status_out);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return NULL;
  }
  void *arg = cairoon_raster_source_state_get_release_arg(state);
  if (arg == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }
  return arg;
}
