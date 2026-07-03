#include "cairoon_private.h"

#include <string.h>

static void cairoon_surface_finalize(void *self) {
  CairoonSurface *surface = (CairoonSurface *)self;
  if (surface->ptr != NULL) {
    cairo_surface_destroy(surface->ptr);
    surface->ptr = NULL;
  }
  if (surface->base != NULL) {
    moonbit_decref(surface->base);
    surface->base = NULL;
  }
}

static void cairoon_device_finalize(void *self) {
  CairoonDevice *device = (CairoonDevice *)self;
  if (device->ptr != NULL) {
    cairo_device_destroy(device->ptr);
    device->ptr = NULL;
  }
}

static void cairoon_mapped_image_surface_finalize(void *self) {
  CairoonMappedImageSurface *surface = (CairoonMappedImageSurface *)self;
  if (surface->mapped != NULL) {
    cairo_surface_unmap_image(surface->base, surface->mapped);
    surface->base = NULL;
    surface->mapped = NULL;
  }
  if (surface->base_object != NULL) {
    moonbit_decref(surface->base_object);
    surface->base_object = NULL;
  }
}

static void cairoon_image_data_finalize(void *self) {
  CairoonImageData *data = (CairoonImageData *)self;
  data->surface = NULL;
  data->data = NULL;
  data->len = 0;
  data->mapped_object = NULL;
  if (data->surface_object != NULL) {
    moonbit_decref(data->surface_object);
    data->surface_object = NULL;
  }
}

static void cairoon_context_finalize(void *self) {
  CairoonContext *ctx = (CairoonContext *)self;
  if (ctx->ptr != NULL) {
    cairo_destroy(ctx->ptr);
    ctx->ptr = NULL;
  }
  if (ctx->target_surface != NULL) {
    moonbit_decref(ctx->target_surface);
    ctx->target_surface = NULL;
  }
}

static void cairoon_path_finalize(void *self) {
  CairoonPath *path = (CairoonPath *)self;
  if (path->ptr != NULL) {
    cairo_path_destroy(path->ptr);
    path->ptr = NULL;
  }
}

static void cairoon_pattern_finalize(void *self) {
  CairoonPattern *pattern = (CairoonPattern *)self;
  if (pattern->ptr != NULL) {
    cairo_pattern_destroy(pattern->ptr);
    pattern->ptr = NULL;
  }
  if (pattern->base != NULL) {
    moonbit_decref(pattern->base);
    pattern->base = NULL;
  }
}

static void cairoon_font_options_finalize(void *self) {
  CairoonFontOptions *options = (CairoonFontOptions *)self;
  if (options->ptr != NULL) {
    cairo_font_options_destroy(options->ptr);
    options->ptr = NULL;
  }
}

static void cairoon_font_face_finalize(void *self) {
  CairoonFontFace *font_face = (CairoonFontFace *)self;
  if (font_face->ptr != NULL) {
    cairo_font_face_destroy(font_face->ptr);
    font_face->ptr = NULL;
  }
}

static void cairoon_scaled_font_finalize(void *self) {
  CairoonScaledFont *scaled_font = (CairoonScaledFont *)self;
  if (scaled_font->ptr != NULL) {
    cairo_scaled_font_destroy(scaled_font->ptr);
    scaled_font->ptr = NULL;
  }
}

static void cairoon_region_finalize(void *self) {
  CairoonRegion *region = (CairoonRegion *)self;
  if (region->ptr != NULL) {
    cairo_region_destroy(region->ptr);
    region->ptr = NULL;
  }
}

static void cairoon_text_to_glyphs_finalize(void *self) {
  CairoonTextToGlyphs *result = (CairoonTextToGlyphs *)self;
  if (result->glyphs != NULL) {
    cairo_glyph_free(result->glyphs);
    result->glyphs = NULL;
  }
  if (result->clusters != NULL) {
    cairo_text_cluster_free(result->clusters);
    result->clusters = NULL;
  }
}

CairoonSurface *cairoon_surface_wrap_owned_with_base(
  cairo_surface_t *ptr,
  void *base) {
  CairoonSurface *surface = (CairoonSurface *)moonbit_make_external_object(
    cairoon_surface_finalize, sizeof(CairoonSurface));
  surface->ptr = ptr;
  surface->base = base;
  if (base != NULL) {
    moonbit_incref(base);
  }
  return surface;
}

CairoonSurface *cairoon_surface_wrap_owned(cairo_surface_t *ptr) {
  return cairoon_surface_wrap_owned_with_base(ptr, NULL);
}

CairoonSurface *cairoon_surface_wrap_borrowed(cairo_surface_t *ptr) {
  if (ptr != NULL) {
    cairo_surface_reference(ptr);
  }
  return cairoon_surface_wrap_owned(ptr);
}

CairoonSurface *cairoon_surface_wrap_borrowed_with_base(
  cairo_surface_t *ptr,
  void *base) {
  if (ptr != NULL) {
    cairo_surface_reference(ptr);
  }
  return cairoon_surface_wrap_owned_with_base(ptr, base);
}

CairoonDevice *cairoon_device_wrap_owned(cairo_device_t *ptr) {
  CairoonDevice *device = (CairoonDevice *)moonbit_make_external_object(
    cairoon_device_finalize, sizeof(CairoonDevice));
  device->ptr = ptr;
  return device;
}

CairoonDevice *cairoon_device_wrap_borrowed(cairo_device_t *ptr) {
  if (ptr != NULL) {
    cairo_device_reference(ptr);
  }
  return cairoon_device_wrap_owned(ptr);
}

CairoonMappedImageSurface *cairoon_mapped_image_surface_wrap_owned(
  cairo_surface_t *base,
  cairo_surface_t *mapped,
  void *base_object) {
  CairoonMappedImageSurface *surface =
    (CairoonMappedImageSurface *)moonbit_make_external_object(
      cairoon_mapped_image_surface_finalize,
      sizeof(CairoonMappedImageSurface));
  surface->base = base;
  surface->mapped = mapped;
  surface->base_object = base_object;
  if (base_object != NULL) {
    moonbit_incref(base_object);
  }
  return surface;
}

CairoonImageData *cairoon_image_data_wrap(
  cairo_surface_t *surface,
  uint8_t *data,
  int32_t len,
  CairoonMappedImageSurface *mapped_object,
  void *surface_object) {
  CairoonImageData *view = (CairoonImageData *)moonbit_make_external_object(
    cairoon_image_data_finalize, sizeof(CairoonImageData));
  view->surface = surface;
  view->data = data;
  view->len = len;
  view->mapped_object = mapped_object;
  view->surface_object = surface_object;
  if (surface_object != NULL) {
    moonbit_incref(surface_object);
  }
  return view;
}

CairoonContext *cairoon_context_wrap_owned(cairo_t *ptr, void *target_surface) {
  CairoonContext *ctx = (CairoonContext *)moonbit_make_external_object(
    cairoon_context_finalize, sizeof(CairoonContext));
  ctx->ptr = ptr;
  ctx->target_surface = target_surface;
  if (target_surface != NULL) {
    moonbit_incref(target_surface);
  }
  return ctx;
}

CairoonPath *cairoon_path_wrap_owned(cairo_path_t *ptr) {
  CairoonPath *path = (CairoonPath *)moonbit_make_external_object(
    cairoon_path_finalize, sizeof(CairoonPath));
  path->ptr = ptr;
  return path;
}

CairoonPattern *cairoon_pattern_wrap_owned(cairo_pattern_t *ptr, void *base) {
  CairoonPattern *pattern = (CairoonPattern *)moonbit_make_external_object(
    cairoon_pattern_finalize, sizeof(CairoonPattern));
  pattern->ptr = ptr;
  pattern->base = base;
  if (base != NULL) {
    moonbit_incref(base);
  }
  return pattern;
}

CairoonPattern *cairoon_pattern_wrap_borrowed(cairo_pattern_t *ptr) {
  if (ptr != NULL) {
    cairo_pattern_reference(ptr);
  }
  return cairoon_pattern_wrap_owned(ptr, NULL);
}

CairoonFontOptions *cairoon_font_options_wrap_owned(cairo_font_options_t *ptr) {
  CairoonFontOptions *options = (CairoonFontOptions *)moonbit_make_external_object(
    cairoon_font_options_finalize, sizeof(CairoonFontOptions));
  options->ptr = ptr;
  return options;
}

CairoonFontFace *cairoon_font_face_wrap_owned(cairo_font_face_t *ptr) {
  CairoonFontFace *font_face = (CairoonFontFace *)moonbit_make_external_object(
    cairoon_font_face_finalize, sizeof(CairoonFontFace));
  font_face->ptr = ptr;
  return font_face;
}

CairoonFontFace *cairoon_font_face_wrap_borrowed(cairo_font_face_t *ptr) {
  if (ptr != NULL) {
    cairo_font_face_reference(ptr);
  }
  return cairoon_font_face_wrap_owned(ptr);
}

CairoonScaledFont *cairoon_scaled_font_wrap_owned(cairo_scaled_font_t *ptr) {
  CairoonScaledFont *scaled_font = (CairoonScaledFont *)moonbit_make_external_object(
    cairoon_scaled_font_finalize, sizeof(CairoonScaledFont));
  scaled_font->ptr = ptr;
  return scaled_font;
}

CairoonScaledFont *cairoon_scaled_font_wrap_borrowed(cairo_scaled_font_t *ptr) {
  if (ptr != NULL) {
    cairo_scaled_font_reference(ptr);
  }
  return cairoon_scaled_font_wrap_owned(ptr);
}

CairoonRegion *cairoon_region_wrap_owned(cairo_region_t *ptr) {
  CairoonRegion *region = (CairoonRegion *)moonbit_make_external_object(
    cairoon_region_finalize, sizeof(CairoonRegion));
  region->ptr = ptr;
  return region;
}

CairoonTextToGlyphs *cairoon_text_to_glyphs_wrap_owned(
  cairo_status_t status,
  cairo_glyph_t *glyphs,
  int32_t num_glyphs,
  cairo_text_cluster_t *clusters,
  int32_t num_clusters,
  cairo_text_cluster_flags_t flags) {
  CairoonTextToGlyphs *result =
    (CairoonTextToGlyphs *)moonbit_make_external_object(
      cairoon_text_to_glyphs_finalize,
      sizeof(CairoonTextToGlyphs));
  result->status = status;
  result->glyphs = glyphs;
  result->num_glyphs = num_glyphs;
  result->clusters = clusters;
  result->num_clusters = num_clusters;
  result->flags = flags;
  return result;
}

moonbit_bytes_t cairoon_copy_c_string(const char *str) {
  if (str == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  int32_t len = (int32_t)strlen(str);
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, str, (size_t)len);
  return bytes;
}
