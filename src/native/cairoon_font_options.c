#include "cairoon_private.h"

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
int32_t cairoon_font_options_get_antialias_raw(CairoonFontOptions *options) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_ANTIALIAS_DEFAULT;
  }
  return (int32_t)cairo_font_options_get_antialias(options->ptr);
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
cairo_status_t cairoon_font_options_set_antialias_raw(
  CairoonFontOptions *options,
  int32_t antialias) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_antialias(options->ptr, (cairo_antialias_t)antialias);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_options_get_subpixel_order_raw(CairoonFontOptions *options) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_SUBPIXEL_ORDER_DEFAULT;
  }
  return (int32_t)cairo_font_options_get_subpixel_order(options->ptr);
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
cairo_status_t cairoon_font_options_set_subpixel_order_raw(
  CairoonFontOptions *options,
  int32_t subpixel_order) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_subpixel_order(
    options->ptr,
    (cairo_subpixel_order_t)subpixel_order);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_options_get_hint_style_raw(CairoonFontOptions *options) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_HINT_STYLE_DEFAULT;
  }
  return (int32_t)cairo_font_options_get_hint_style(options->ptr);
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
cairo_status_t cairoon_font_options_set_hint_style_raw(
  CairoonFontOptions *options,
  int32_t hint_style) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_hint_style(options->ptr, (cairo_hint_style_t)hint_style);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_options_get_hint_metrics_raw(CairoonFontOptions *options) {
  if (cairoon_font_options_status(options) != CAIRO_STATUS_SUCCESS) {
    return CAIRO_HINT_METRICS_DEFAULT;
  }
  return (int32_t)cairo_font_options_get_hint_metrics(options->ptr);
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
cairo_status_t cairoon_font_options_set_hint_metrics_raw(
  CairoonFontOptions *options,
  int32_t hint_metrics) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  cairo_font_options_set_hint_metrics(
    options->ptr,
    (cairo_hint_metrics_t)hint_metrics);
  return cairo_font_options_status(options->ptr);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_font_options_get_variations(
  CairoonFontOptions *options,
  int32_t *has_variations,
  cairo_status_t *status_out) {
  *status_out = cairoon_font_options_status(options);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    *has_variations = 0;
    return moonbit_make_bytes(0, 0);
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 16, 0)
  const char *variations = cairo_font_options_get_variations(options->ptr);
  if (variations == NULL) {
    *has_variations = 0;
    return moonbit_make_bytes(0, 0);
  }
  *has_variations = 1;
  return cairoon_copy_c_string(variations);
#else
  *has_variations = 0;
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return moonbit_make_bytes(0, 0);
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_variations(
  CairoonFontOptions *options,
  moonbit_bytes_t variations) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 16, 0)
  cairo_font_options_set_variations(options->ptr, (const char *)variations);
  return cairo_font_options_status(options->ptr);
#else
  (void)variations;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_clear_variations(CairoonFontOptions *options) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 16, 0)
  cairo_font_options_set_variations(options->ptr, NULL);
  return cairo_font_options_status(options->ptr);
#else
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_options_get_color_mode_raw(
  CairoonFontOptions *options,
  cairo_status_t *status_out) {
  *status_out = cairoon_font_options_status(options);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  return (int32_t)cairo_font_options_get_color_mode(options->ptr);
#else
  *status_out = CAIRO_STATUS_INVALID_STATUS;
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_mode(
  CairoonFontOptions *options,
  int32_t color_mode) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_font_options_set_color_mode(options->ptr, (cairo_color_mode_t)color_mode);
  return cairo_font_options_status(options->ptr);
#else
  (void)color_mode;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_mode_raw(
  CairoonFontOptions *options,
  int32_t color_mode) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_font_options_set_color_mode(options->ptr, (cairo_color_mode_t)color_mode);
  return cairo_font_options_status(options->ptr);
#else
  (void)color_mode;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
uint32_t cairoon_font_options_get_color_palette(
  CairoonFontOptions *options,
  cairo_status_t *status_out) {
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  *status_out = cairoon_font_options_status(options);
  if (*status_out != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint32_t)cairo_font_options_get_color_palette(options->ptr);
#else
  *status_out = cairoon_font_options_status(options);
  if (*status_out == CAIRO_STATUS_SUCCESS) {
    *status_out = CAIRO_STATUS_INVALID_STATUS;
  }
  return 0;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_set_color_palette(
  CairoonFontOptions *options,
  uint32_t palette_index) {
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_font_options_set_color_palette(options->ptr, (unsigned int)palette_index);
  return cairo_font_options_status(options->ptr);
#else
  (void)palette_index;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
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
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_font_options_set_custom_palette_color(
    options->ptr,
    (unsigned int)index,
    red,
    green,
    blue,
    alpha);
  return cairo_font_options_status(options->ptr);
#else
  (void)index;
  (void)red;
  (void)green;
  (void)blue;
  (void)alpha;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_options_get_custom_palette_color(
  CairoonFontOptions *options,
  uint32_t index,
  double *red,
  double *green,
  double *blue,
  double *alpha) {
  *red = 0.0;
  *green = 0.0;
  *blue = 0.0;
  *alpha = 0.0;
  cairo_status_t status = cairoon_font_options_status(options);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  return cairo_font_options_get_custom_palette_color(
    options->ptr,
    (unsigned int)index,
    red,
    green,
    blue,
    alpha);
#else
  (void)index;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
