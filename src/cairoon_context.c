#include "cairoon_private.h"

#include <stdlib.h>

MOONBIT_FFI_EXPORT
CairoonContext *cairoon_context_create(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return cairoon_context_wrap_owned(cairo_create(NULL), NULL);
  }
  return cairoon_context_wrap_owned(cairo_create(surface->ptr), surface);
}

MOONBIT_FFI_EXPORT
CairoonContext *cairoon_context_create_for_mapped_image(
  CairoonMappedImageSurface *surface,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_mapped_image_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_context_wrap_owned(cairo_create(NULL), NULL);
  }
  return cairoon_context_wrap_owned(cairo_create(surface->mapped), surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_status(CairoonContext *ctx) {
  if (ctx == NULL || ctx->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_context_equal(CairoonContext *ctx, CairoonContext *other) {
  if (ctx == NULL || other == NULL || ctx->ptr == NULL || other->ptr == NULL) {
    return 0;
  }
  return ctx->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_context_hash(CairoonContext *ctx) {
  if (ctx == NULL || ctx->ptr == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)ctx->ptr;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_save(CairoonContext *ctx) {
  cairo_save(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_restore(CairoonContext *ctx) {
  cairo_restore(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_tag_begin(
  CairoonContext *ctx,
  moonbit_bytes_t tag_name,
  moonbit_bytes_t attributes) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (tag_name == NULL || attributes == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_tag_begin(ctx->ptr, (const char *)tag_name, (const char *)attributes);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_tag_end(
  CairoonContext *ctx,
  moonbit_bytes_t tag_name) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (tag_name == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  cairo_tag_end(ctx->ptr, (const char *)tag_name);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_context_get_target(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface = cairo_get_target(ctx->ptr);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_borrowed_with_base(surface, ctx->target_surface);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_context_get_source(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  cairo_pattern_t *pattern = cairo_get_source(ctx->ptr);
  if (pattern == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  *status_out = cairo_pattern_status(pattern);
  return cairoon_pattern_wrap_borrowed(pattern);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_context_get_group_target(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }
  cairo_surface_t *surface = cairo_get_group_target(ctx->ptr);
  if (surface == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_surface_wrap_owned(NULL);
  }
  *status_out = cairo_surface_status(surface);
  return cairoon_surface_wrap_borrowed_with_base(surface, ctx);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_push_group(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_push_group(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_push_group_with_content(
  CairoonContext *ctx,
  cairo_content_t content) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_push_group_with_content(ctx->ptr, content);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_context_pop_group(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  cairo_pattern_t *pattern = cairo_pop_group(ctx->ptr);
  *status_out = cairo_status(ctx->ptr);
  if (pattern == NULL) {
    if (*status_out == CAIRO_STATUS_SUCCESS) {
      *status_out = CAIRO_STATUS_NO_MEMORY;
    }
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  if (*status_out == CAIRO_STATUS_SUCCESS) {
    *status_out = cairo_pattern_status(pattern);
  }
  return cairoon_pattern_wrap_owned(pattern, NULL);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_pop_group_to_source(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pop_group_to_source(ctx->ptr);
  return cairo_status(ctx->ptr);
}
