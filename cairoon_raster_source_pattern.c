#include "cairoon_private.h"

#include <limits.h>
#include <stdlib.h>

typedef struct {
  CairoonRasterSourceAcquireCallback acquire;
  void *acquire_arg;
  CairoonRasterSourceReleaseCallback release;
  void *release_arg;
} CairoonRasterSourceState;

typedef struct {
  CairoonSurface *surface;
  int32_t count;
} CairoonRasterSurfaceOwner;

static const cairo_user_data_key_t cairoon_raster_source_state_key;
static const cairo_user_data_key_t cairoon_raster_surface_owner_key;

static void cairoon_raster_surface_owner_destroy(void *owner_ptr) {
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)owner_ptr;
  if (owner == NULL) {
    return;
  }
  if (owner->surface != NULL) {
    moonbit_decref(owner->surface);
    owner->surface = NULL;
  }
  free(owner);
}

static void cairoon_raster_source_state_destroy(void *state_ptr) {
  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)state_ptr;
  if (state == NULL) {
    return;
  }
  if (state->acquire_arg != NULL) {
    moonbit_decref(state->acquire_arg);
    state->acquire_arg = NULL;
  }
  if (state->release_arg != NULL) {
    moonbit_decref(state->release_arg);
    state->release_arg = NULL;
  }
  free(state);
}

static cairo_status_t cairoon_pattern_require_raster_source(
  CairoonPattern *pattern) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_pattern_get_type(pattern->ptr) !=
      CAIRO_PATTERN_TYPE_RASTER_SOURCE) {
    return CAIRO_STATUS_PATTERN_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

static cairo_status_t cairoon_raster_surface_owner_retain(
  CairoonSurface *surface) {
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface->ptr,
      &cairoon_raster_surface_owner_key);

  if (owner != NULL) {
    if (owner->count == INT_MAX) {
      return CAIRO_STATUS_NO_MEMORY;
    }
    owner->count += 1;
    moonbit_decref(surface);
    return CAIRO_STATUS_SUCCESS;
  }

  owner = (CairoonRasterSurfaceOwner *)malloc(
    sizeof(CairoonRasterSurfaceOwner));
  if (owner == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  owner->surface = surface;
  owner->count = 1;

  cairo_status_t status = cairo_surface_set_user_data(
    surface->ptr,
    &cairoon_raster_surface_owner_key,
    owner,
    cairoon_raster_surface_owner_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    free(owner);
  }
  return status;
}

static void cairoon_raster_surface_owner_release(cairo_surface_t *surface) {
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface,
      &cairoon_raster_surface_owner_key);
  if (owner == NULL) {
    cairo_surface_destroy(surface);
    return;
  }

  if (owner->count > 1) {
    owner->count -= 1;
  } else {
    (void)cairo_surface_set_user_data(
      surface,
      &cairoon_raster_surface_owner_key,
      NULL,
      NULL);
  }
  cairo_surface_destroy(surface);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_test_raster_surface_owner_count(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return -1;
  }
  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface->ptr,
      &cairoon_raster_surface_owner_key);
  return owner == NULL ? 0 : owner->count;
}

static cairo_surface_t *cairoon_raster_source_acquire(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *target,
  const cairo_rectangle_int_t *extents) {
  cairo_pattern_t *callback_pattern = (cairo_pattern_t *)callback_data;
  if (callback_pattern == NULL) {
    callback_pattern = pattern;
  }
  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)cairo_pattern_get_user_data(
      callback_pattern,
      &cairoon_raster_source_state_key);
  if (state == NULL || state->acquire == NULL || target == NULL ||
      extents == NULL) {
    return NULL;
  }

  CairoonSurface *target_wrapper = cairoon_surface_wrap_borrowed(target);
  CairoonSurface *source_wrapper = state->acquire(
    target_wrapper,
    extents->x,
    extents->y,
    extents->width,
    extents->height,
    state->acquire_arg);
  moonbit_decref(target_wrapper);

  if (source_wrapper == NULL || source_wrapper->ptr == NULL) {
    if (source_wrapper != NULL) {
      moonbit_decref(source_wrapper);
    }
    return NULL;
  }

  if (cairoon_surface_status(source_wrapper) != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(source_wrapper);
    return NULL;
  }

  cairo_surface_t *source = source_wrapper->ptr;
  cairo_status_t status = cairoon_raster_surface_owner_retain(source_wrapper);
  if (status != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(source_wrapper);
    return NULL;
  }
  cairo_surface_reference(source);
  return source;
}

static void cairoon_raster_source_release(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *surface) {
  cairo_pattern_t *callback_pattern = (cairo_pattern_t *)callback_data;
  if (callback_pattern == NULL) {
    callback_pattern = pattern;
  }
  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)cairo_pattern_get_user_data(
      callback_pattern,
      &cairoon_raster_source_state_key);
  if (surface == NULL) {
    return;
  }

  CairoonRasterSurfaceOwner *owner =
    (CairoonRasterSurfaceOwner *)cairo_surface_get_user_data(
      surface,
      &cairoon_raster_surface_owner_key);
  if (state != NULL && state->release != NULL && owner != NULL &&
      owner->surface != NULL) {
    state->release(owner->surface, state->release_arg);
  }
  cairoon_raster_surface_owner_release(surface);
}

static CairoonRasterSourceState *cairoon_raster_source_state_new(
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg,
  CairoonRasterSourceReleaseCallback release,
  void *release_arg,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (acquire == NULL && release == NULL) {
    if (acquire_arg != NULL) {
      moonbit_decref(acquire_arg);
    }
    if (release_arg != NULL) {
      moonbit_decref(release_arg);
    }
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }

  CairoonRasterSourceState *state =
    (CairoonRasterSourceState *)malloc(sizeof(CairoonRasterSourceState));
  if (state == NULL) {
    if (acquire_arg != NULL) {
      moonbit_decref(acquire_arg);
    }
    if (release_arg != NULL) {
      moonbit_decref(release_arg);
    }
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return NULL;
  }

  state->acquire = acquire;
  state->acquire_arg = acquire_arg;
  state->release = release;
  state->release_arg = release_arg;
  return state;
}

static cairo_status_t cairoon_raster_source_pattern_set_state(
  CairoonPattern *pattern,
  CairoonRasterSourceState *state) {
  cairo_status_t status = cairoon_pattern_require_raster_source(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_raster_source_state_destroy(state);
    return status;
  }

  status = cairo_pattern_set_user_data(
    pattern->ptr,
    &cairoon_raster_source_state_key,
    state,
    state == NULL ? NULL : cairoon_raster_source_state_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_raster_source_state_destroy(state);
    return status;
  }

  cairo_raster_source_pattern_set_callback_data(
    pattern->ptr,
    state == NULL ? NULL : pattern->ptr);
  cairo_raster_source_pattern_set_acquire(
    pattern->ptr,
    state == NULL || state->acquire == NULL ? NULL :
      cairoon_raster_source_acquire,
    // Always release surfaces retained by acquire, even without a user release
    // closure.
    state == NULL || (state->acquire == NULL && state->release == NULL) ? NULL :
      cairoon_raster_source_release);
  return cairo_pattern_status(pattern->ptr);
}

static CairoonRasterSourceState *cairoon_raster_source_pattern_get_state(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  *status_out = cairoon_pattern_require_raster_source(pattern);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return NULL;
  }
  return (CairoonRasterSourceState *)cairo_pattern_get_user_data(
    pattern->ptr,
    &cairoon_raster_source_state_key);
}

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
  *has_acquire = state->acquire == NULL ? 0 : 1;
  *has_release = state->release == NULL ? 0 : 1;
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
  if (state == NULL || state->acquire == NULL ||
      state->acquire_arg == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }
  moonbit_incref(state->acquire_arg);
  return state->acquire_arg;
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
  if (state == NULL || state->release == NULL ||
      state->release_arg == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }
  moonbit_incref(state->release_arg);
  return state->release_arg;
}
