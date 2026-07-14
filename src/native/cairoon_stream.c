#include "cairoon_private.h"

#include <limits.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  CairoonStreamWriteCallback callback;
  void *arg;
  cairo_status_t status;
  int32_t defer_errors;
} CairoonStreamState;

typedef struct {
  CairoonStreamReadCallback callback;
  void *arg;
} CairoonStreamReadState;

static const cairo_user_data_key_t cairoon_stream_state_key;

void cairoon_stream_state_destroy(void *state_ptr) {
  CairoonStreamState *state = (CairoonStreamState *)state_ptr;
  if (state == NULL) {
    return;
  }
  if (state->arg != NULL) {
    moonbit_decref(state->arg);
    state->arg = NULL;
  }
  free(state);
}

void *cairoon_stream_state_new(
  CairoonStreamWriteCallback callback,
  void *arg,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (callback == NULL) {
    if (arg != NULL) {
      moonbit_decref(arg);
    }
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }

  CairoonStreamState *state =
    (CairoonStreamState *)malloc(sizeof(CairoonStreamState));
  if (state == NULL) {
    if (arg != NULL) {
      moonbit_decref(arg);
    }
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return NULL;
  }

  state->callback = callback;
  state->arg = arg;
  state->status = CAIRO_STATUS_SUCCESS;
  state->defer_errors = 0;
  return state;
}

void *cairoon_stream_state_new_deferred(
  CairoonStreamWriteCallback callback,
  void *arg,
  cairo_status_t *status_out) {
  CairoonStreamState *state = (CairoonStreamState *)cairoon_stream_state_new(
    callback,
    arg,
    status_out);
  if (state != NULL) {
    state->defer_errors = 1;
  }
  return state;
}

cairo_status_t cairoon_stream_state_status(void *state_ptr) {
  CairoonStreamState *state = (CairoonStreamState *)state_ptr;
  if (state == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return state->status;
}

cairo_status_t cairoon_stream_write(
  void *closure,
  const unsigned char *data,
  unsigned int length) {
  CairoonStreamState *state = (CairoonStreamState *)closure;
  if (state == NULL || state->callback == NULL) {
    return CAIRO_STATUS_WRITE_ERROR;
  }
  if (length > (unsigned int)INT_MAX) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  if (state->defer_errors && state->status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_STATUS_SUCCESS;
  }

  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)length, 0);
  if (length > 0) {
    if (data == NULL) {
      moonbit_decref(bytes);
      return CAIRO_STATUS_NULL_POINTER;
    }
    memcpy(bytes, data, (size_t)length);
  }

  moonbit_incref(bytes);
  if (state->arg != NULL) {
    moonbit_incref(state->arg);
  }
  cairo_status_t status = (cairo_status_t)state->callback(bytes, state->arg);
  if (state->arg != NULL) {
    moonbit_decref(state->arg);
  }
  moonbit_decref(bytes);
  if (status < CAIRO_STATUS_SUCCESS || status >= CAIRO_STATUS_LAST_STATUS) {
    status = CAIRO_STATUS_WRITE_ERROR;
  }
  if (state->defer_errors && status != CAIRO_STATUS_SUCCESS) {
    state->status = status;
    return CAIRO_STATUS_SUCCESS;
  }
  return status;
}

cairo_status_t cairoon_stream_attach(cairo_surface_t *surface, void *state) {
  if (surface == NULL) {
    cairoon_stream_state_destroy(state);
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_set_user_data(
    surface,
    &cairoon_stream_state_key,
    state,
    cairoon_stream_state_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_stream_state_destroy(state);
  }
  return status;
}

cairo_status_t cairoon_stream_attach_device(cairo_device_t *device, void *state) {
  if (device == NULL) {
    cairoon_stream_state_destroy(state);
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_device_set_user_data(
    device,
    &cairoon_stream_state_key,
    state,
    cairoon_stream_state_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairoon_stream_state_destroy(state);
  }
  return status;
}

void cairoon_stream_read_state_destroy(void *state_ptr) {
  CairoonStreamReadState *state = (CairoonStreamReadState *)state_ptr;
  if (state == NULL) {
    return;
  }
  if (state->arg != NULL) {
    moonbit_decref(state->arg);
    state->arg = NULL;
  }
  free(state);
}

void *cairoon_stream_read_state_new(
  CairoonStreamReadCallback callback,
  void *arg,
  cairo_status_t *status_out) {
  *status_out = CAIRO_STATUS_SUCCESS;
  if (callback == NULL) {
    if (arg != NULL) {
      moonbit_decref(arg);
    }
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return NULL;
  }

  CairoonStreamReadState *state =
    (CairoonStreamReadState *)malloc(sizeof(CairoonStreamReadState));
  if (state == NULL) {
    if (arg != NULL) {
      moonbit_decref(arg);
    }
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return NULL;
  }

  state->callback = callback;
  state->arg = arg;
  return state;
}

cairo_status_t cairoon_stream_read(
  void *closure,
  unsigned char *data,
  unsigned int length) {
  CairoonStreamReadState *state = (CairoonStreamReadState *)closure;
  if (state == NULL || state->callback == NULL) {
    return CAIRO_STATUS_READ_ERROR;
  }
  if (length > (unsigned int)INT_MAX) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  if (length > 0 && data == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }

  if (state->arg != NULL) {
    moonbit_incref(state->arg);
  }
  moonbit_bytes_t bytes = state->callback((int32_t)length, state->arg);
  if (state->arg != NULL) {
    moonbit_decref(state->arg);
  }
  if (bytes == NULL) {
    return CAIRO_STATUS_READ_ERROR;
  }

  uint32_t actual = Moonbit_array_length(bytes);
  if (actual != length) {
    moonbit_decref(bytes);
    return CAIRO_STATUS_READ_ERROR;
  }
  if (length > 0) {
    memcpy(data, bytes, (size_t)length);
  }
  moonbit_decref(bytes);
  return CAIRO_STATUS_SUCCESS;
}
