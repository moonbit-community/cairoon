#ifndef CAIROON_PRIVATE_H
#define CAIROON_PRIVATE_H

#include <cairo.h>
#include <moonbit.h>
#include <stdint.h>

typedef struct {
  cairo_surface_t *ptr;
  void *base;
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

CairoonSurface *cairoon_surface_wrap_owned(cairo_surface_t *ptr);
CairoonSurface *cairoon_surface_wrap_owned_with_base(cairo_surface_t *ptr, void *base);
CairoonSurface *cairoon_surface_wrap_borrowed(cairo_surface_t *ptr);
CairoonContext *cairoon_context_wrap_owned(cairo_t *ptr, void *target_surface);
CairoonPath *cairoon_path_wrap_owned(cairo_path_t *ptr);
CairoonPattern *cairoon_pattern_wrap_owned(cairo_pattern_t *ptr, void *base);
CairoonPattern *cairoon_pattern_wrap_borrowed(cairo_pattern_t *ptr);
CairoonFontOptions *cairoon_font_options_wrap_owned(cairo_font_options_t *ptr);
CairoonFontFace *cairoon_font_face_wrap_owned(cairo_font_face_t *ptr);
CairoonFontFace *cairoon_font_face_wrap_borrowed(cairo_font_face_t *ptr);
CairoonScaledFont *cairoon_scaled_font_wrap_owned(cairo_scaled_font_t *ptr);
CairoonScaledFont *cairoon_scaled_font_wrap_borrowed(cairo_scaled_font_t *ptr);
CairoonRegion *cairoon_region_wrap_owned(cairo_region_t *ptr);

moonbit_bytes_t cairoon_copy_c_string(const char *str);

cairo_status_t cairoon_surface_status(CairoonSurface *surface);
cairo_status_t cairoon_context_status(CairoonContext *ctx);
cairo_status_t cairoon_path_status(CairoonPath *path);
cairo_status_t cairoon_pattern_status(CairoonPattern *pattern);
cairo_status_t cairoon_font_options_status(CairoonFontOptions *options);
cairo_status_t cairoon_font_face_status(CairoonFontFace *font_face);
cairo_status_t cairoon_scaled_font_status(CairoonScaledFont *scaled_font);
cairo_status_t cairoon_region_status(CairoonRegion *region);

#endif
