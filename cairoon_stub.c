#include <cairo.h>
#include <moonbit.h>
#include <stdint.h>
#include <string.h>

typedef struct {
  cairo_surface_t *ptr;
} CairoonSurface;

typedef struct {
  cairo_t *ptr;
  void *target_surface;
} CairoonContext;

typedef struct {
  cairo_path_t *ptr;
} CairoonPath;

typedef struct {
  cairo_pattern_t *ptr;
  void *base;
} CairoonPattern;

typedef struct {
  cairo_font_options_t *ptr;
} CairoonFontOptions;

typedef struct {
  cairo_font_face_t *ptr;
} CairoonFontFace;

typedef struct {
  cairo_scaled_font_t *ptr;
} CairoonScaledFont;

typedef struct {
  cairo_region_t *ptr;
} CairoonRegion;

cairo_status_t cairoon_pattern_status(CairoonPattern *pattern);
cairo_status_t cairoon_font_options_status(CairoonFontOptions *options);
cairo_status_t cairoon_font_face_status(CairoonFontFace *font_face);
cairo_status_t cairoon_scaled_font_status(CairoonScaledFont *scaled_font);
cairo_status_t cairoon_region_status(CairoonRegion *region);

static void cairoon_surface_finalize(void *self) {
  CairoonSurface *surface = (CairoonSurface *)self;
  if (surface->ptr != NULL) {
    cairo_surface_destroy(surface->ptr);
    surface->ptr = NULL;
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

static CairoonSurface *cairoon_surface_wrap_owned(cairo_surface_t *ptr) {
  CairoonSurface *surface = (CairoonSurface *)moonbit_make_external_object(
    cairoon_surface_finalize, sizeof(CairoonSurface));
  surface->ptr = ptr;
  return surface;
}

static CairoonSurface *cairoon_surface_wrap_borrowed(cairo_surface_t *ptr) {
  if (ptr != NULL) {
    cairo_surface_reference(ptr);
  }
  return cairoon_surface_wrap_owned(ptr);
}

static CairoonContext *cairoon_context_wrap_owned(cairo_t *ptr, void *target_surface) {
  CairoonContext *ctx = (CairoonContext *)moonbit_make_external_object(
    cairoon_context_finalize, sizeof(CairoonContext));
  ctx->ptr = ptr;
  ctx->target_surface = target_surface;
  if (target_surface != NULL) {
    moonbit_incref(target_surface);
  }
  return ctx;
}

static CairoonPath *cairoon_path_wrap_owned(cairo_path_t *ptr) {
  CairoonPath *path = (CairoonPath *)moonbit_make_external_object(
    cairoon_path_finalize, sizeof(CairoonPath));
  path->ptr = ptr;
  return path;
}

static CairoonPattern *cairoon_pattern_wrap_owned(cairo_pattern_t *ptr, void *base) {
  CairoonPattern *pattern = (CairoonPattern *)moonbit_make_external_object(
    cairoon_pattern_finalize, sizeof(CairoonPattern));
  pattern->ptr = ptr;
  pattern->base = base;
  if (base != NULL) {
    moonbit_incref(base);
  }
  return pattern;
}

static CairoonPattern *cairoon_pattern_wrap_borrowed(cairo_pattern_t *ptr) {
  if (ptr != NULL) {
    cairo_pattern_reference(ptr);
  }
  return cairoon_pattern_wrap_owned(ptr, NULL);
}

static CairoonFontOptions *cairoon_font_options_wrap_owned(cairo_font_options_t *ptr) {
  CairoonFontOptions *options = (CairoonFontOptions *)moonbit_make_external_object(
    cairoon_font_options_finalize, sizeof(CairoonFontOptions));
  options->ptr = ptr;
  return options;
}

static CairoonFontFace *cairoon_font_face_wrap_owned(cairo_font_face_t *ptr) {
  CairoonFontFace *font_face = (CairoonFontFace *)moonbit_make_external_object(
    cairoon_font_face_finalize, sizeof(CairoonFontFace));
  font_face->ptr = ptr;
  return font_face;
}

static CairoonFontFace *cairoon_font_face_wrap_borrowed(cairo_font_face_t *ptr) {
  if (ptr != NULL) {
    cairo_font_face_reference(ptr);
  }
  return cairoon_font_face_wrap_owned(ptr);
}

static CairoonScaledFont *cairoon_scaled_font_wrap_owned(cairo_scaled_font_t *ptr) {
  CairoonScaledFont *scaled_font = (CairoonScaledFont *)moonbit_make_external_object(
    cairoon_scaled_font_finalize, sizeof(CairoonScaledFont));
  scaled_font->ptr = ptr;
  return scaled_font;
}

static CairoonScaledFont *cairoon_scaled_font_wrap_borrowed(cairo_scaled_font_t *ptr) {
  if (ptr != NULL) {
    cairo_scaled_font_reference(ptr);
  }
  return cairoon_scaled_font_wrap_owned(ptr);
}

static CairoonRegion *cairoon_region_wrap_owned(cairo_region_t *ptr) {
  CairoonRegion *region = (CairoonRegion *)moonbit_make_external_object(
    cairoon_region_finalize, sizeof(CairoonRegion));
  region->ptr = ptr;
  return region;
}

static moonbit_bytes_t cairoon_copy_c_string(const char *str) {
  if (str == NULL) {
    return moonbit_make_bytes(0, 0);
  }
  int32_t len = (int32_t)strlen(str);
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, str, (size_t)len);
  return bytes;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_version_string(void) {
  return cairoon_copy_c_string(cairo_version_string());
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_status_to_string(cairo_status_t status) {
  return cairoon_copy_c_string(cairo_status_to_string(status));
}

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_font_options_create(void) {
  return cairoon_font_options_wrap_owned(cairo_font_options_create());
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_status(CairoonFontOptions *options) {
  if (options == NULL || options->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_font_options_copy(
  CairoonFontOptions *options,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *copy = cairo_font_options_copy(options->ptr);
  *status_out = cairo_font_options_status(copy);
  return cairoon_font_options_wrap_owned(copy);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_merge(
  CairoonFontOptions *options,
  CairoonFontOptions *other) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_font_options_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_merge(options->ptr, other->ptr);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_options_equal(
  CairoonFontOptions *options,
  CairoonFontOptions *other) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_options_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_font_options_equal(options->ptr, other->ptr) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_font_options_hash(CairoonFontOptions *options) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)cairo_font_options_hash(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_antialias_t cairoon_font_options_get_antialias(CairoonFontOptions *options) {
  return cairo_font_options_get_antialias(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_antialias(
  CairoonFontOptions *options,
  cairo_antialias_t antialias) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_antialias(options->ptr, antialias);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_subpixel_order_t cairoon_font_options_get_subpixel_order(CairoonFontOptions *options) {
  return cairo_font_options_get_subpixel_order(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_subpixel_order(
  CairoonFontOptions *options,
  cairo_subpixel_order_t subpixel_order) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_subpixel_order(options->ptr, subpixel_order);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_hint_style_t cairoon_font_options_get_hint_style(CairoonFontOptions *options) {
  return cairo_font_options_get_hint_style(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_hint_style(
  CairoonFontOptions *options,
  cairo_hint_style_t hint_style) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_hint_style(options->ptr, hint_style);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_hint_metrics_t cairoon_font_options_get_hint_metrics(CairoonFontOptions *options) {
  return cairo_font_options_get_hint_metrics(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_hint_metrics(
  CairoonFontOptions *options,
  cairo_hint_metrics_t hint_metrics) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_hint_metrics(options->ptr, hint_metrics);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_font_options_get_variations(
  CairoonFontOptions *options,
  int32_t *has_variations) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    *has_variations = 0;
    return moonbit_make_bytes(0, 0);
  }
  const char *variations = cairo_font_options_get_variations(options->ptr);
  if (variations == NULL) {
    *has_variations = 0;
    return moonbit_make_bytes(0, 0);
  }
  *has_variations = 1;
  return cairoon_copy_c_string(variations);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_variations(
  CairoonFontOptions *options,
  moonbit_bytes_t variations) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_variations(options->ptr, (const char *)variations);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_clear_variations(CairoonFontOptions *options) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_variations(options->ptr, NULL);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_color_mode_t cairoon_font_options_get_color_mode(CairoonFontOptions *options) {
  return cairo_font_options_get_color_mode(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_mode(
  CairoonFontOptions *options,
  cairo_color_mode_t color_mode) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_color_mode(options->ptr, color_mode);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
uint32_t cairoon_font_options_get_color_palette(CairoonFontOptions *options) {
  return (uint32_t)cairo_font_options_get_color_palette(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_palette(
  CairoonFontOptions *options,
  uint32_t palette_index) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_color_palette(options->ptr, (unsigned int)palette_index);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_custom_palette_color(
  CairoonFontOptions *options,
  uint32_t index,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_custom_palette_color(
    options->ptr,
    (unsigned int)index,
    red,
    green,
    blue,
    alpha);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_get_custom_palette_color(
  CairoonFontOptions *options,
  uint32_t index,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_font_options_get_custom_palette_color(
    options->ptr,
    (unsigned int)index,
    red,
    green,
    blue,
    alpha);
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_toy_font_face_create(
  moonbit_bytes_t family,
  cairo_font_slant_t slant,
  cairo_font_weight_t weight) {
  return cairoon_font_face_wrap_owned(
    cairo_toy_font_face_create((const char *)family, slant, weight));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_face_status(CairoonFontFace *font_face) {
  if (font_face == NULL || font_face->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_font_face_status(font_face->ptr);
}

static cairo_status_t cairoon_toy_font_face_status(CairoonFontFace *font_face) {
  cairo_status_t status = cairoon_font_face_status(font_face);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_font_face_get_type(font_face->ptr) != CAIRO_FONT_TYPE_TOY) {
    return CAIRO_STATUS_FONT_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_face_equal(
  CairoonFontFace *font_face,
  CairoonFontFace *other) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_face_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return font_face->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_font_face_hash(CairoonFontFace *font_face) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)(uintptr_t)font_face->ptr;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_toy_font_face_get_family(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  const char *family = cairo_toy_font_face_get_family(font_face->ptr);
  if (family == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_c_string(family);
}

MOONBIT_FFI_EXPORT
cairo_font_slant_t cairoon_toy_font_face_get_slant(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FONT_SLANT_NORMAL;
  }
  return cairo_toy_font_face_get_slant(font_face->ptr);
}

MOONBIT_FFI_EXPORT
cairo_font_weight_t cairoon_toy_font_face_get_weight(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FONT_WEIGHT_NORMAL;
  }
  return cairo_toy_font_face_get_weight(font_face->ptr);
}

MOONBIT_FFI_EXPORT
CairoonScaledFont *cairoon_scaled_font_create(
  CairoonFontFace *font_face,
  double font_xx,
  double font_yx,
  double font_xy,
  double font_yy,
  double font_x0,
  double font_y0,
  double ctm_xx,
  double ctm_yx,
  double ctm_xy,
  double ctm_yy,
  double ctm_x0,
  double ctm_y0,
  CairoonFontOptions *options) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  cairo_matrix_t font_matrix;
  cairo_matrix_t ctm;
  cairo_matrix_init(
    &font_matrix,
    font_xx,
    font_yx,
    font_xy,
    font_yy,
    font_x0,
    font_y0);
  cairo_matrix_init(&ctm, ctm_xx, ctm_yx, ctm_xy, ctm_yy, ctm_x0, ctm_y0);
  return cairoon_scaled_font_wrap_owned(
    cairo_scaled_font_create(font_face->ptr, &font_matrix, &ctm, options->ptr));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_status(CairoonScaledFont *scaled_font) {
  if (scaled_font == NULL || scaled_font->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_scaled_font_equal(
  CairoonScaledFont *scaled_font,
  CairoonScaledFont *other) {
  if (cairoon_scaled_font_status(scaled_font) != CAIRO_STATUS_SUCCESS ||
      cairoon_scaled_font_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return scaled_font->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_scaled_font_hash(CairoonScaledFont *scaled_font) {
  if (cairoon_scaled_font_status(scaled_font) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)(uintptr_t)scaled_font->ptr;
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_scaled_font_get_font_face(
  CairoonScaledFont *scaled_font,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  cairo_font_face_t *font_face = cairo_scaled_font_get_font_face(scaled_font->ptr);
  if (font_face == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_font_face_wrap_owned(NULL);
  }
  *status_out = cairo_font_face_status(font_face);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  return cairoon_font_face_wrap_borrowed(font_face);
}

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_scaled_font_get_font_options(
  CairoonScaledFont *scaled_font,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *options = cairo_font_options_create();
  status = cairo_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(options);
  }
  cairo_scaled_font_get_font_options(scaled_font->ptr, options);
  *status_out = cairo_font_options_status(options);
  return cairoon_font_options_wrap_owned(options);
}

static cairo_status_t cairoon_scaled_font_get_matrix(
  CairoonScaledFont *scaled_font,
  void (*get_matrix)(cairo_scaled_font_t *, cairo_matrix_t *),
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  get_matrix(scaled_font->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_get_font_matrix(
  CairoonScaledFont *scaled_font,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  return cairoon_scaled_font_get_matrix(
    scaled_font, cairo_scaled_font_get_font_matrix, xx, yx, xy, yy, x0, y0);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_get_ctm(
  CairoonScaledFont *scaled_font,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  return cairoon_scaled_font_get_matrix(
    scaled_font, cairo_scaled_font_get_ctm, xx, yx, xy, yy, x0, y0);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_get_scale_matrix(
  CairoonScaledFont *scaled_font,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  return cairoon_scaled_font_get_matrix(
    scaled_font, cairo_scaled_font_get_scale_matrix, xx, yx, xy, yy, x0, y0);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_extents(
  CairoonScaledFont *scaled_font,
  double *ascent,
  double *descent,
  double *height,
  double *max_x_advance,
  double *max_y_advance) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_extents_t extents;
  cairo_scaled_font_extents(scaled_font->ptr, &extents);
  *ascent = extents.ascent;
  *descent = extents.descent;
  *height = extents.height;
  *max_x_advance = extents.max_x_advance;
  *max_y_advance = extents.max_y_advance;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_scaled_font_text_extents(
  CairoonScaledFont *scaled_font,
  moonbit_bytes_t text,
  double *x_bearing,
  double *y_bearing,
  double *width,
  double *height,
  double *x_advance,
  double *y_advance) {
  cairo_status_t status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_text_extents_t extents;
  cairo_scaled_font_text_extents(scaled_font->ptr, (const char *)text, &extents);
  *x_bearing = extents.x_bearing;
  *y_bearing = extents.y_bearing;
  *width = extents.width;
  *height = extents.height;
  *x_advance = extents.x_advance;
  *y_advance = extents.y_advance;
  return cairo_scaled_font_status(scaled_font->ptr);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_image_surface_create(cairo_format_t format, int32_t width, int32_t height) {
  return cairoon_surface_wrap_owned(cairo_image_surface_create(format, width, height));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_status(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_finish(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_finish(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_flush(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_flush(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_copy_page(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_copy_page(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_surface_show_page(CairoonSurface *surface) {
  cairo_status_t status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_surface_show_page(surface->ptr);
  return cairo_surface_status(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_width(CairoonSurface *surface) {
  return cairo_image_surface_get_width(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_height(CairoonSurface *surface) {
  return cairo_image_surface_get_height(surface->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_image_surface_get_stride(CairoonSurface *surface) {
  return cairo_image_surface_get_stride(surface->ptr);
}

MOONBIT_FFI_EXPORT
cairo_format_t cairoon_image_surface_get_format(CairoonSurface *surface) {
  return cairo_image_surface_get_format(surface->ptr);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_image_surface_copy_data(CairoonSurface *surface) {
  cairo_surface_flush(surface->ptr);
  unsigned char *data = cairo_image_surface_get_data(surface->ptr);
  int32_t height = cairo_image_surface_get_height(surface->ptr);
  int32_t stride = cairo_image_surface_get_stride(surface->ptr);
  int32_t len = height * stride;
  if (data == NULL || len <= 0) {
    return moonbit_make_bytes(0, 0);
  }
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, data, (size_t)len);
  return bytes;
}

MOONBIT_FFI_EXPORT
CairoonFontOptions *cairoon_surface_get_font_options(
  CairoonSurface *surface,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *options = cairo_font_options_create();
  status = cairo_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(options);
  }
  cairo_surface_get_font_options(surface->ptr, options);
  *status_out = cairo_font_options_status(options);
  return cairoon_font_options_wrap_owned(options);
}

MOONBIT_FFI_EXPORT
CairoonContext *cairoon_context_create(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return cairoon_context_wrap_owned(cairo_create(NULL), NULL);
  }
  return cairoon_context_wrap_owned(cairo_create(surface->ptr), surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_status(CairoonContext *ctx) {
  if (ctx == NULL || ctx->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_status(ctx->ptr);
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
  return cairoon_surface_wrap_borrowed(surface);
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
CairoonFontOptions *cairoon_context_get_font_options(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(NULL);
  }
  cairo_font_options_t *options = cairo_font_options_create();
  status = cairo_font_options_status(options);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_options_wrap_owned(options);
  }
  cairo_get_font_options(ctx->ptr, options);
  *status_out = cairo_font_options_status(options);
  return cairoon_font_options_wrap_owned(options);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_options(
  CairoonContext *ctx,
  CairoonFontOptions *options) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_options(ctx->ptr, options->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_context_get_font_face(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  cairo_font_face_t *font_face = cairo_get_font_face(ctx->ptr);
  if (font_face == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_font_face_wrap_owned(NULL);
  }
  *status_out = cairo_font_face_status(font_face);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_font_face_wrap_owned(NULL);
  }
  return cairoon_font_face_wrap_borrowed(font_face);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_face(
  CairoonContext *ctx,
  CairoonFontFace *font_face) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_font_face_status(font_face);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_face(ctx->ptr, font_face->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_face_default(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_face(ctx->ptr, NULL);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_select_font_face(
  CairoonContext *ctx,
  moonbit_bytes_t family,
  cairo_font_slant_t slant,
  cairo_font_weight_t weight) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_select_font_face(ctx->ptr, (const char *)family, slant, weight);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_matrix(
  CairoonContext *ctx,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_set_font_matrix(ctx->ptr, &matrix);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_get_font_matrix(
  CairoonContext *ctx,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_get_font_matrix(ctx->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_font_size(CairoonContext *ctx, double size) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_font_size(ctx->ptr, size);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_font_extents(
  CairoonContext *ctx,
  double *ascent,
  double *descent,
  double *height,
  double *max_x_advance,
  double *max_y_advance) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_extents_t extents;
  cairo_font_extents(ctx->ptr, &extents);
  *ascent = extents.ascent;
  *descent = extents.descent;
  *height = extents.height;
  *max_x_advance = extents.max_x_advance;
  *max_y_advance = extents.max_y_advance;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonScaledFont *cairoon_context_get_scaled_font(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  cairo_scaled_font_t *scaled_font = cairo_get_scaled_font(ctx->ptr);
  if (scaled_font == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  *status_out = cairo_scaled_font_status(scaled_font);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return cairoon_scaled_font_wrap_owned(NULL);
  }
  return cairoon_scaled_font_wrap_borrowed(scaled_font);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_scaled_font(
  CairoonContext *ctx,
  CairoonScaledFont *scaled_font) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_scaled_font_status(scaled_font);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_scaled_font(ctx->ptr, scaled_font->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_scale(CairoonContext *ctx, double sx, double sy) {
  cairo_scale(ctx->ptr, sx, sy);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_translate(CairoonContext *ctx, double tx, double ty) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_translate(ctx->ptr, tx, ty);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rotate(CairoonContext *ctx, double radians) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rotate(ctx->ptr, radians);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_transform(
  CairoonContext *ctx,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_transform(ctx->ptr, &matrix);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_matrix(
  CairoonContext *ctx,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_set_matrix(ctx->ptr, &matrix);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_get_matrix(
  CairoonContext *ctx,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_get_matrix(ctx->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_identity_matrix(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_identity_matrix(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_user_to_device(
  CairoonContext *ctx,
  double x,
  double y,
  double *out_x,
  double *out_y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_user_to_device(ctx->ptr, &x, &y);
  *out_x = x;
  *out_y = y;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_user_to_device_distance(
  CairoonContext *ctx,
  double dx,
  double dy,
  double *out_dx,
  double *out_dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_user_to_device_distance(ctx->ptr, &dx, &dy);
  *out_dx = dx;
  *out_dy = dy;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_device_to_user(
  CairoonContext *ctx,
  double x,
  double y,
  double *out_x,
  double *out_y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_to_user(ctx->ptr, &x, &y);
  *out_x = x;
  *out_y = y;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_device_to_user_distance(
  CairoonContext *ctx,
  double dx,
  double dy,
  double *out_dx,
  double *out_dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_device_to_user_distance(ctx->ptr, &dx, &dy);
  *out_dx = dx;
  *out_dy = dy;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_line_width(CairoonContext *ctx, double width) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_line_width(ctx->ptr, width);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double cairoon_context_get_line_width(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0.0;
  }
  return cairo_get_line_width(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_line_cap(CairoonContext *ctx, cairo_line_cap_t cap) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_line_cap(ctx->ptr, cap);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_line_cap_t cairoon_context_get_line_cap(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_LINE_CAP_BUTT;
  }
  return cairo_get_line_cap(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_line_join(CairoonContext *ctx, cairo_line_join_t join) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_line_join(ctx->ptr, join);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_line_join_t cairoon_context_get_line_join(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_LINE_JOIN_MITER;
  }
  return cairo_get_line_join(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_fill_rule(CairoonContext *ctx, cairo_fill_rule_t fill_rule) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_fill_rule(ctx->ptr, fill_rule);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_fill_rule_t cairoon_context_get_fill_rule(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FILL_RULE_WINDING;
  }
  return cairo_get_fill_rule(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_operator(CairoonContext *ctx, cairo_operator_t operator_) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_operator(ctx->ptr, operator_);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_operator_t cairoon_context_get_operator(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_OPERATOR_OVER;
  }
  return cairo_get_operator(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_antialias(CairoonContext *ctx, cairo_antialias_t antialias) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_antialias(ctx->ptr, antialias);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_antialias_t cairoon_context_get_antialias(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_ANTIALIAS_DEFAULT;
  }
  return cairo_get_antialias(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_tolerance(CairoonContext *ctx, double tolerance) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_tolerance(ctx->ptr, tolerance);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double cairoon_context_get_tolerance(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0.0;
  }
  return cairo_get_tolerance(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_miter_limit(CairoonContext *ctx, double limit) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_miter_limit(ctx->ptr, limit);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double cairoon_context_get_miter_limit(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0.0;
  }
  return cairo_get_miter_limit(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_dash(CairoonContext *ctx, double *dashes, double offset) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  int32_t count = (int32_t)Moonbit_array_length(dashes);
  cairo_set_dash(ctx->ptr, dashes, count, offset);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_context_get_dash_count(CairoonContext *ctx) {
  if (cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_get_dash_count(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double *cairoon_context_get_dash(CairoonContext *ctx, double *offset) {
  int32_t count = cairoon_context_get_dash_count(ctx);
  *offset = 0.0;
  if (count <= 0 || cairoon_context_status(ctx) != CAIRO_STATUS_SUCCESS) {
    return moonbit_empty_double_array;
  }
  double *dashes = moonbit_make_double_array_raw(count);
  cairo_get_dash(ctx->ptr, dashes, offset);
  return dashes;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_move_to(CairoonContext *ctx, double x, double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_move_to(ctx->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rel_move_to(CairoonContext *ctx, double dx, double dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rel_move_to(ctx->ptr, dx, dy);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_line_to(CairoonContext *ctx, double x, double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_line_to(ctx->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rel_line_to(CairoonContext *ctx, double dx, double dy) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rel_line_to(ctx->ptr, dx, dy);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_curve_to(
  CairoonContext *ctx,
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_curve_to(ctx->ptr, x1, y1, x2, y2, x3, y3);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rel_curve_to(
  CairoonContext *ctx,
  double dx1,
  double dy1,
  double dx2,
  double dy2,
  double dx3,
  double dy3) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rel_curve_to(ctx->ptr, dx1, dy1, dx2, dy2, dx3, dy3);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_rectangle(
  CairoonContext *ctx,
  double x,
  double y,
  double width,
  double height) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle(ctx->ptr, x, y, width, height);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_arc(
  CairoonContext *ctx,
  double xc,
  double yc,
  double radius,
  double angle1,
  double angle2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_arc(ctx->ptr, xc, yc, radius, angle1, angle2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_arc_negative(
  CairoonContext *ctx,
  double xc,
  double yc,
  double radius,
  double angle1,
  double angle2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_arc_negative(ctx->ptr, xc, yc, radius, angle1, angle2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_close_path(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_close_path(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_new_path(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_new_path(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_new_sub_path(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_new_sub_path(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_get_current_point(CairoonContext *ctx, double *x, double *y) {
  *x = 0.0;
  *y = 0.0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_get_current_point(ctx->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_has_current_point(CairoonContext *ctx, int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_has_current_point(ctx->ptr) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonPath *cairoon_context_copy_path(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_path_wrap_owned(NULL);
  }

  cairo_path_t *path = cairo_copy_path(ctx->ptr);
  if (path == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_path_wrap_owned(NULL);
  }
  *status_out = path->status;
  return cairoon_path_wrap_owned(path);
}

MOONBIT_FFI_EXPORT
CairoonPath *cairoon_context_copy_path_flat(CairoonContext *ctx, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_path_wrap_owned(NULL);
  }

  cairo_path_t *path = cairo_copy_path_flat(ctx->ptr);
  if (path == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return cairoon_path_wrap_owned(NULL);
  }
  *status_out = path->status;
  return cairoon_path_wrap_owned(path);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_append_path(CairoonContext *ctx, CairoonPath *path) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (path == NULL || path->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  if (path->ptr->status != CAIRO_STATUS_SUCCESS) {
    return path->ptr->status;
  }
  cairo_append_path(ctx->ptr, path->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_clip(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_clip(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_clip_preserve(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_clip_preserve(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_reset_clip(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_reset_clip(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_clip_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_clip_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
double *cairoon_context_copy_clip_rectangle_list(
  CairoonContext *ctx,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_context_status(ctx);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_empty_double_array;
  }

  cairo_rectangle_list_t *list = cairo_copy_clip_rectangle_list(ctx->ptr);
  if (list == NULL) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    return moonbit_empty_double_array;
  }

  *status_out = list->status;
  if (list->status != CAIRO_STATUS_SUCCESS || list->num_rectangles <= 0) {
    cairo_rectangle_list_destroy(list);
    return moonbit_empty_double_array;
  }
  if (list->num_rectangles > INT32_MAX / 4) {
    *status_out = CAIRO_STATUS_NO_MEMORY;
    cairo_rectangle_list_destroy(list);
    return moonbit_empty_double_array;
  }

  int32_t value_count = list->num_rectangles * 4;
  double *values = moonbit_make_double_array_raw(value_count);
  for (int32_t i = 0; i < list->num_rectangles; i++) {
    cairo_rectangle_t rectangle = list->rectangles[i];
    int32_t offset = i * 4;
    values[offset] = rectangle.x;
    values[offset + 1] = rectangle.y;
    values[offset + 2] = rectangle.width;
    values[offset + 3] = rectangle.height;
  }
  cairo_rectangle_list_destroy(list);
  return values;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_fill_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_fill_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_stroke_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_stroke_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_path_extents(
  CairoonContext *ctx,
  double *x1,
  double *y1,
  double *x2,
  double *y2) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_path_extents(ctx->ptr, x1, y1, x2, y2);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_in_clip(
  CairoonContext *ctx,
  double x,
  double y,
  int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_in_clip(ctx->ptr, x, y) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_in_fill(
  CairoonContext *ctx,
  double x,
  double y,
  int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_in_fill(ctx->ptr, x, y) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_in_stroke(
  CairoonContext *ctx,
  double x,
  double y,
  int32_t *result) {
  *result = 0;
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *result = cairo_in_stroke(ctx->ptr, x, y) ? 1 : 0;
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source_rgb(
  CairoonContext *ctx,
  double red,
  double green,
  double blue) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source_rgb(ctx->ptr, red, green, blue);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source_rgba(
  CairoonContext *ctx,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source_rgba(ctx->ptr, red, green, blue, alpha);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_set_source(CairoonContext *ctx, CairoonPattern *pattern) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_set_source(ctx->ptr, pattern->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_paint(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_paint(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_paint_with_alpha(CairoonContext *ctx, double alpha) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_paint_with_alpha(ctx->ptr, alpha);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_mask(CairoonContext *ctx, CairoonPattern *pattern) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mask(ctx->ptr, pattern->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_mask_surface(
  CairoonContext *ctx,
  CairoonSurface *surface,
  double x,
  double y) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_mask_surface(ctx->ptr, surface->ptr, x, y);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_fill(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_fill(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_fill_preserve(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_fill_preserve(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_stroke(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_stroke(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_stroke_preserve(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_stroke_preserve(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_copy_page(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_copy_page(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_context_show_page(CairoonContext *ctx) {
  cairo_status_t status = cairoon_context_status(ctx);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_show_page(ctx->ptr);
  return cairo_status(ctx->ptr);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_rgb(double red, double green, double blue) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_rgb(red, green, blue), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_rgba(
  double red,
  double green,
  double blue,
  double alpha) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_rgba(red, green, blue, alpha), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_linear(double x0, double y0, double x1, double y1) {
  return cairoon_pattern_wrap_owned(cairo_pattern_create_linear(x0, y0, x1, y1), NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_radial(
  double cx0,
  double cy0,
  double radius0,
  double cx1,
  double cy1,
  double radius1) {
  return cairoon_pattern_wrap_owned(
    cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1),
    NULL);
}

MOONBIT_FFI_EXPORT
CairoonPattern *cairoon_pattern_create_for_surface(CairoonSurface *surface) {
  if (surface == NULL || surface->ptr == NULL) {
    return cairoon_pattern_wrap_owned(NULL, NULL);
  }
  return cairoon_pattern_wrap_owned(cairo_pattern_create_for_surface(surface->ptr), surface);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_status(CairoonPattern *pattern) {
  if (pattern == NULL || pattern->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_pattern_get_surface(
  CairoonPattern *pattern,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }

  cairo_surface_t *surface = NULL;
  status = cairo_pattern_get_surface(pattern->ptr, &surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS || surface == NULL) {
    return cairoon_surface_wrap_owned(NULL);
  }

  status = cairo_surface_status(surface);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return cairoon_surface_wrap_owned(NULL);
  }

  return cairoon_surface_wrap_borrowed(surface);
}

MOONBIT_FFI_EXPORT
cairo_extend_t cairoon_pattern_get_extend(CairoonPattern *pattern) {
  return cairo_pattern_get_extend(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_extend(CairoonPattern *pattern, cairo_extend_t extend) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_set_extend(pattern->ptr, extend);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_filter_t cairoon_pattern_get_filter(CairoonPattern *pattern) {
  return cairo_pattern_get_filter(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_filter(CairoonPattern *pattern, cairo_filter_t filter) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_set_filter(pattern->ptr, filter);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_dither_t cairoon_pattern_get_dither(CairoonPattern *pattern) {
  return cairo_pattern_get_dither(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_dither(CairoonPattern *pattern, cairo_dither_t dither) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_set_dither(pattern->ptr, dither);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_matrix(
  CairoonPattern *pattern,
  double *xx,
  double *yx,
  double *xy,
  double *yy,
  double *x0,
  double *y0) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_pattern_get_matrix(pattern->ptr, &matrix);
  *xx = matrix.xx;
  *yx = matrix.yx;
  *xy = matrix.xy;
  *yy = matrix.yy;
  *x0 = matrix.x0;
  *y0 = matrix.y0;
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_set_matrix(
  CairoonPattern *pattern,
  double xx,
  double yx,
  double xy,
  double yy,
  double x0,
  double y0) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_matrix_t matrix;
  cairo_matrix_init(&matrix, xx, yx, xy, yy, x0, y0);
  cairo_pattern_set_matrix(pattern->ptr, &matrix);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_rgba(
  CairoonPattern *pattern,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_rgba(pattern->ptr, red, green, blue, alpha);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_add_color_stop_rgb(
  CairoonPattern *pattern,
  double offset,
  double red,
  double green,
  double blue) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_add_color_stop_rgb(pattern->ptr, offset, red, green, blue);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_add_color_stop_rgba(
  CairoonPattern *pattern,
  double offset,
  double red,
  double green,
  double blue,
  double alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_pattern_add_color_stop_rgba(pattern->ptr, offset, red, green, blue, alpha);
  return cairo_pattern_status(pattern->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_color_stop_count(CairoonPattern *pattern, int32_t *count) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  int cairo_count = 0;
  status = cairo_pattern_get_color_stop_count(pattern->ptr, &cairo_count);
  *count = (int32_t)cairo_count;
  return status;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_color_stop_rgba(
  CairoonPattern *pattern,
  int32_t index,
  double *offset,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_color_stop_rgba(pattern->ptr, index, offset, red, green, blue, alpha);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_linear_points(
  CairoonPattern *pattern,
  double *x0,
  double *y0,
  double *x1,
  double *y1) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_linear_points(pattern->ptr, x0, y0, x1, y1);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_pattern_get_radial_circles(
  CairoonPattern *pattern,
  double *cx0,
  double *cy0,
  double *radius0,
  double *cx1,
  double *cy1,
  double *radius1) {
  cairo_status_t status = cairoon_pattern_status(pattern);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_pattern_get_radial_circles(pattern->ptr, cx0, cy0, radius0, cx1, cy1, radius1);
}

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_create(void) {
  return cairoon_region_wrap_owned(cairo_region_create());
}

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_create_rectangle(
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairoon_region_wrap_owned(cairo_region_create_rectangle(&rect));
}

MOONBIT_FFI_EXPORT
CairoonRegion *cairoon_region_copy(CairoonRegion *region) {
  if (region == NULL || region->ptr == NULL) {
    return cairoon_region_wrap_owned(NULL);
  }
  return cairoon_region_wrap_owned(cairo_region_copy(region->ptr));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_status(CairoonRegion *region) {
  if (region == NULL || region->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_get_extents(
  CairoonRegion *region,
  int32_t *x,
  int32_t *y,
  int32_t *width,
  int32_t *height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect;
  cairo_region_get_extents(region->ptr, &rect);
  *x = rect.x;
  *y = rect.y;
  *width = rect.width;
  *height = rect.height;
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_num_rectangles(CairoonRegion *region) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_region_num_rectangles(region->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_get_rectangle(
  CairoonRegion *region,
  int32_t index,
  int32_t *x,
  int32_t *y,
  int32_t *width,
  int32_t *height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect;
  cairo_region_get_rectangle(region->ptr, index, &rect);
  *x = rect.x;
  *y = rect.y;
  *width = rect.width;
  *height = rect.height;
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_is_empty(CairoonRegion *region) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS) {
    return 1;
  }
  return cairo_region_is_empty(region->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_contains_point(CairoonRegion *region, int32_t x, int32_t y) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_region_contains_point(region->ptr, x, y);
}

MOONBIT_FFI_EXPORT
cairo_region_overlap_t cairoon_region_contains_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_contains_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_region_equal(CairoonRegion *region, CairoonRegion *other) {
  if (cairoon_region_status(region) != CAIRO_STATUS_SUCCESS ||
      cairoon_region_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return cairo_region_equal(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_translate(CairoonRegion *region, int32_t dx, int32_t dy) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_region_translate(region->ptr, dx, dy);
  return cairo_region_status(region->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_intersect(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_intersect(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_intersect_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_intersect_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_subtract(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_subtract(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_subtract_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_subtract_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_union(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_union(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_union_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_union_rectangle(region->ptr, &rect);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_xor(CairoonRegion *region, CairoonRegion *other) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  status = cairoon_region_status(other);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return cairo_region_xor(region->ptr, other->ptr);
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_region_xor_rectangle(
  CairoonRegion *region,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height) {
  cairo_status_t status = cairoon_region_status(region);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_rectangle_int_t rect = { x, y, width, height };
  return cairo_region_xor_rectangle(region->ptr, &rect);
}
