#include "cairoon_private.h"

#if CAIRO_HAS_TEE_SURFACE
#include <cairo-tee.h>
#endif
#include <stdlib.h>

typedef struct CairoonTeeTargetNode {
  CairoonSurface *object;
  cairo_surface_t *ptr;
  struct CairoonTeeTargetNode *next;
} CairoonTeeTargetNode;

typedef struct {
  CairoonTeeTargetNode *head;
} CairoonTeeTargets;

static const cairo_user_data_key_t cairoon_tee_targets_key;

static void cairoon_tee_targets_destroy(void *data) {
  CairoonTeeTargets *targets = (CairoonTeeTargets *)data;
  if (targets == NULL) {
    return;
  }
  CairoonTeeTargetNode *node = targets->head;
  while (node != NULL) {
    CairoonTeeTargetNode *next = node->next;
    if (node->object != NULL) {
      moonbit_decref(node->object);
    }
    free(node);
    node = next;
  }
  free(targets);
}

static cairo_status_t cairoon_tee_surface_status(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_status_t status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_HAS_TEE_SURFACE
  if (cairo_surface_get_type(surface->ptr) != CAIRO_SURFACE_TYPE_TEE) {
    return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

#if CAIRO_HAS_TEE_SURFACE
static cairo_status_t cairoon_tee_get_targets(
  cairo_surface_t *surface,
  CairoonTeeTargets **targets_out) {
  CairoonTeeTargets *targets =
    (CairoonTeeTargets *)cairo_surface_get_user_data(
      surface,
      &cairoon_tee_targets_key);
  if (targets != NULL) {
    *targets_out = targets;
    return CAIRO_STATUS_SUCCESS;
  }

  targets = (CairoonTeeTargets *)calloc(1, sizeof(CairoonTeeTargets));
  if (targets == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  cairo_status_t status = cairo_surface_set_user_data(
    surface,
    &cairoon_tee_targets_key,
    targets,
    cairoon_tee_targets_destroy);
  if (status != CAIRO_STATUS_SUCCESS) {
    free(targets);
    return status;
  }
  *targets_out = targets;
  return CAIRO_STATUS_SUCCESS;
}

static cairo_status_t cairoon_tee_retain_target(
  cairo_surface_t *tee,
  CairoonSurface *target) {
  CairoonTeeTargets *targets = NULL;
  cairo_status_t status = cairoon_tee_get_targets(tee, &targets);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }

  CairoonTeeTargetNode *node =
    (CairoonTeeTargetNode *)malloc(sizeof(CairoonTeeTargetNode));
  if (node == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  node->object = target;
  node->ptr = target->ptr;
  node->next = targets->head;
  targets->head = node;
  moonbit_incref(target);
  return CAIRO_STATUS_SUCCESS;
}

static void cairoon_tee_release_one_target(
  cairo_surface_t *tee,
  cairo_surface_t *target) {
  CairoonTeeTargets *targets =
    (CairoonTeeTargets *)cairo_surface_get_user_data(
      tee,
      &cairoon_tee_targets_key);
  if (targets == NULL) {
    return;
  }

  CairoonTeeTargetNode **link = &targets->head;
  while (*link != NULL) {
    CairoonTeeTargetNode *node = *link;
    if (node->ptr == target) {
      *link = node->next;
      if (node->object != NULL) {
        moonbit_decref(node->object);
      }
      free(node);
      return;
    }
    link = &node->next;
  }
}

static void *cairoon_tee_base_for_indexed_surface(
  CairoonSurface *tee,
  cairo_surface_t *indexed) {
  if (tee->base != NULL) {
    CairoonSurface *base = (CairoonSurface *)tee->base;
    if (base->ptr == indexed) {
      return base;
    }
  }

  CairoonTeeTargets *targets =
    (CairoonTeeTargets *)cairo_surface_get_user_data(
      tee->ptr,
      &cairoon_tee_targets_key);
  for (CairoonTeeTargetNode *node = targets == NULL ? NULL : targets->head;
       node != NULL;
       node = node->next) {
    if (node->ptr == indexed) {
      return node->object;
    }
  }
  return tee;
}
#endif

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_tee_surface_create(
  CairoonSurface *primary,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(primary);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
#if CAIRO_HAS_TEE_SURFACE
  cairo_surface_t *surface = cairo_tee_surface_create(primary->ptr);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_owned_with_base(surface, primary);
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_tee_surface_add(
  CairoonSurface *surface,
  CairoonSurface *target) {
  cairo_status_t status = cairoon_tee_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_surface_status(target);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  /* The retained-target list stores MoonBit wrappers; self-targeting would
   * make the tee wrapper keep itself alive forever. */
  if (surface->ptr == target->ptr) {
    return CAIRO_STATUS_INVALID_STATUS;
  }
#if CAIRO_HAS_TEE_SURFACE
  cairo_tee_surface_add(surface->ptr, target->ptr);
  status = cairo_surface_status(surface->ptr);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_tee_retain_target(surface->ptr, target);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_tee_surface_remove(surface->ptr, target->ptr);
  }
  return status;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_tee_surface_remove(
  CairoonSurface *surface,
  CairoonSurface *target) {
  cairo_status_t status = cairoon_tee_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_surface_status(target);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  /* Match add: do not let a tee surface operate on itself as a retained
   * target. */
  if (surface->ptr == target->ptr) {
    return CAIRO_STATUS_INVALID_STATUS;
  }
#if CAIRO_HAS_TEE_SURFACE
  cairo_tee_surface_remove(surface->ptr, target->ptr);
  status = cairo_surface_status(surface->ptr);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairoon_tee_release_one_target(surface->ptr, target->ptr);
  }
  return status;
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_tee_surface_index(
  CairoonSurface *surface,
  int32_t index,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_tee_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  if (index < 0) {
    *status_out = CAIRO_STATUS_INVALID_INDEX;
    return cairoon_surface_wrap_owned(NULL);
  }
#if CAIRO_HAS_TEE_SURFACE
  cairo_surface_t *indexed =
    cairo_tee_surface_index(surface->ptr, (unsigned int)index);
  if (indexed == NULL) {
    *status_out = cairo_surface_status(surface->ptr);
    if (*status_out == CAIRO_STATUS_SUCCESS) {
      *status_out = CAIRO_STATUS_INVALID_INDEX;
    }
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(indexed);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  return cairoon_surface_wrap_borrowed_with_base(
    indexed,
    cairoon_tee_base_for_indexed_surface(surface, indexed));
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return cairoon_surface_wrap_owned(NULL);
#endif
}
