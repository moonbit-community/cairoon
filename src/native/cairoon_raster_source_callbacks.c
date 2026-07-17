#include "cairoon_private.h"

#include <limits.h>
#include <stdlib.h>

struct CairoonRasterSourceState {
  CairoonRasterSourceAcquireCallback acquire;
  void *acquire_arg;
  CairoonRasterSourceReleaseCallback release;
  void *release_arg;
  struct CairoonRasterSourceState *pending_state;
  int32_t has_pending_state;
  int32_t active_acquisitions;
  int32_t callback_depth;
};

typedef struct {
  CairoonSurface *surface;
  int32_t count;
} CairoonRasterSurfaceOwner;

static const cairo_user_data_key_t cairoon_raster_source_state_key;
static const cairo_user_data_key_t cairoon_raster_surface_owner_key;

static cairo_status_t cairoon_raster_source_apply_pending_state(
  cairo_pattern_t *pattern,
  CairoonRasterSourceState *state);

static CAIROON_MOONBIT_FUNCREF_DISPATCH CairoonSurface *
cairoon_raster_source_call_acquire(
  CairoonRasterSourceAcquireCallback acquire,
  CairoonSurface *target,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height,
  void *arg) {
  return acquire(target, x, y, width, height, arg);
}

static CAIROON_MOONBIT_FUNCREF_DISPATCH void
cairoon_raster_source_call_release(
  CairoonRasterSourceReleaseCallback release,
  CairoonSurface *surface,
  void *arg) {
  release(surface, arg);
}

static void cairoon_raster_source_finish_acquire(
  cairo_pattern_t *pattern,
  CairoonRasterSourceState *state,
  int32_t acquired) {
  if (acquired != 0) {
    state->active_acquisitions += 1;
  }
  state->callback_depth -= 1;
  if (state->callback_depth == 0 && state->active_acquisitions == 0) {
    (void)cairoon_raster_source_apply_pending_state(pattern, state);
  }
}

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
  if (state->pending_state != NULL) {
    cairoon_raster_source_state_destroy(state->pending_state);
    state->pending_state = NULL;
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

int32_t cairoon_raster_source_surface_owner_count(CairoonSurface *surface) {
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

  CairoonRasterSourceAcquireCallback acquire = state->acquire;
  void *acquire_arg = state->acquire_arg;
  if (state->callback_depth == INT_MAX) {
    return NULL;
  }
  state->callback_depth += 1;

  // FuncRef arguments are borrowed; this wrapper owns the call-scoped ref.
  CairoonSurface *target_wrapper = cairoon_surface_wrap_borrowed(target);
  if (acquire_arg != NULL) {
    moonbit_incref(acquire_arg);
  }
  CairoonSurface *source_wrapper = cairoon_raster_source_call_acquire(
    acquire,
    target_wrapper,
    extents->x,
    extents->y,
    extents->width,
    extents->height,
    acquire_arg);
  if (acquire_arg != NULL) {
    moonbit_decref(acquire_arg);
  }
  moonbit_decref(target_wrapper);

  if (source_wrapper == NULL || source_wrapper->ptr == NULL) {
    if (source_wrapper != NULL) {
      moonbit_decref(source_wrapper);
    }
    cairoon_raster_source_finish_acquire(callback_pattern, state, 0);
    return NULL;
  }

  if (cairoon_surface_status(source_wrapper) != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(source_wrapper);
    cairoon_raster_source_finish_acquire(callback_pattern, state, 0);
    return NULL;
  }

  if (state->active_acquisitions == INT_MAX) {
    moonbit_decref(source_wrapper);
    cairoon_raster_source_finish_acquire(callback_pattern, state, 0);
    return NULL;
  }

  cairo_surface_t *source = source_wrapper->ptr;
  cairo_status_t status = cairoon_raster_surface_owner_retain(source_wrapper);
  if (status != CAIRO_STATUS_SUCCESS) {
    moonbit_decref(source_wrapper);
    cairoon_raster_source_finish_acquire(callback_pattern, state, 0);
    return NULL;
  }
  cairo_surface_reference(source);
  cairoon_raster_source_finish_acquire(callback_pattern, state, 1);
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
  CairoonRasterSourceReleaseCallback release =
    state == NULL ? NULL : state->release;
  void *release_arg = state == NULL ? NULL : state->release_arg;
  CairoonSurface *owner_surface = owner == NULL ? NULL : owner->surface;
  if (state != NULL) {
    state->callback_depth += 1;
  }
  if (release != NULL && owner_surface != NULL) {
    moonbit_incref(owner_surface);
    if (release_arg != NULL) {
      moonbit_incref(release_arg);
    }
    cairoon_raster_source_call_release(release, owner_surface, release_arg);
    if (release_arg != NULL) {
      moonbit_decref(release_arg);
    }
    moonbit_decref(owner_surface);
  }
  cairoon_raster_surface_owner_release(surface);
  if (state != NULL) {
    if (state->active_acquisitions > 0) {
      state->active_acquisitions -= 1;
    }
    state->callback_depth -= 1;
    if (state->callback_depth == 0 && state->active_acquisitions == 0) {
      (void)cairoon_raster_source_apply_pending_state(
        callback_pattern,
        state);
    }
  }
}

static cairo_status_t cairoon_raster_source_install_state(
  cairo_pattern_t *pattern,
  CairoonRasterSourceState *state) {
  cairo_status_t status = cairo_pattern_set_user_data(
    pattern,
    &cairoon_raster_source_state_key,
    state,
    state == NULL ? NULL : cairoon_raster_source_state_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_raster_source_state_destroy(state);
    return status;
  }

  cairo_raster_source_pattern_set_callback_data(
    pattern,
    state == NULL ? NULL : pattern);
  cairo_raster_source_pattern_set_acquire(
    pattern,
    state == NULL || state->acquire == NULL ? NULL :
      cairoon_raster_source_acquire,
    // Always release surfaces retained by acquire, even without a user release
    // closure.
    state == NULL || (state->acquire == NULL && state->release == NULL) ? NULL :
      cairoon_raster_source_release);
  return cairo_pattern_status(pattern);
}

static cairo_status_t cairoon_raster_source_apply_pending_state(
  cairo_pattern_t *pattern,
  CairoonRasterSourceState *state) {
  if (state == NULL || state->has_pending_state == 0 ||
      state->callback_depth != 0 || state->active_acquisitions != 0) {
    return CAIRO_STATUS_SUCCESS;
  }

  CairoonRasterSourceState *pending_state = state->pending_state;
  state->pending_state = NULL;
  state->has_pending_state = 0;
  return cairoon_raster_source_install_state(pattern, pending_state);
}

CairoonRasterSourceState *cairoon_raster_source_state_new(
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
  state->pending_state = NULL;
  state->has_pending_state = 0;
  state->active_acquisitions = 0;
  state->callback_depth = 0;
  return state;
}

cairo_status_t cairoon_raster_source_pattern_set_state(
  CairoonPattern *pattern,
  CairoonRasterSourceState *state) {
  cairo_status_t status = cairoon_pattern_require_raster_source(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_raster_source_state_destroy(state);
    return status;
  }

  CairoonRasterSourceState *current_state =
    (CairoonRasterSourceState *)cairo_pattern_get_user_data(
      pattern->ptr,
      &cairoon_raster_source_state_key);
  if (current_state != NULL &&
      (current_state->callback_depth != 0 ||
       current_state->active_acquisitions != 0)) {
    if (current_state->pending_state != NULL) {
      cairoon_raster_source_state_destroy(current_state->pending_state);
    }
    current_state->pending_state = state;
    current_state->has_pending_state = 1;
    return CAIRO_STATUS_SUCCESS;
  }

  return cairoon_raster_source_install_state(pattern->ptr, state);
}

CairoonRasterSourceState *cairoon_raster_source_pattern_get_state(
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

int32_t cairoon_raster_source_state_has_acquire(
  CairoonRasterSourceState *state) {
  return state != NULL && state->acquire != NULL ? 1 : 0;
}

int32_t cairoon_raster_source_state_has_release(
  CairoonRasterSourceState *state) {
  return state != NULL && state->release != NULL ? 1 : 0;
}

void *cairoon_raster_source_state_get_acquire_arg(
  CairoonRasterSourceState *state) {
  if (state == NULL || state->acquire == NULL || state->acquire_arg == NULL) {
    return NULL;
  }
  moonbit_incref(state->acquire_arg);
  return state->acquire_arg;
}

void *cairoon_raster_source_state_get_release_arg(
  CairoonRasterSourceState *state) {
  if (state == NULL || state->release == NULL || state->release_arg == NULL) {
    return NULL;
  }
  moonbit_incref(state->release_arg);
  return state->release_arg;
}
