#ifndef CAIROON_PRIVATE_H
#define CAIROON_PRIVATE_H

#include <cairo.h>
#include <moonbit.h>
#include <stdint.h>

typedef struct {
  cairo_surface_t *ptr;
} CairoonSurface;

typedef struct {
  cairo_device_t *ptr;
} CairoonDevice;

typedef struct {
  cairo_surface_t *base;
  cairo_surface_t *mapped;
  void *base_object;
} CairoonMappedImageSurface;

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

typedef struct {
  cairo_status_t status;
  cairo_glyph_t *glyphs;
  int32_t num_glyphs;
  cairo_text_cluster_t *clusters;
  int32_t num_clusters;
  cairo_text_cluster_flags_t flags;
} CairoonTextToGlyphs;

CairoonSurface *cairoon_surface_wrap_owned(cairo_surface_t *ptr);
CairoonSurface *cairoon_surface_wrap_borrowed(cairo_surface_t *ptr);
CairoonDevice *cairoon_device_wrap_owned(cairo_device_t *ptr);
CairoonDevice *cairoon_device_wrap_borrowed(cairo_device_t *ptr);
CairoonMappedImageSurface *cairoon_mapped_image_surface_wrap_owned(
  cairo_surface_t *base,
  cairo_surface_t *mapped,
  void *base_object);
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
CairoonTextToGlyphs *cairoon_text_to_glyphs_wrap_owned(
  cairo_status_t status,
  cairo_glyph_t *glyphs,
  int32_t num_glyphs,
  cairo_text_cluster_t *clusters,
  int32_t num_clusters,
  cairo_text_cluster_flags_t flags);

moonbit_bytes_t cairoon_copy_c_string(const char *str);
cairo_status_t cairoon_glyphs_from_fields(
  uint32_t *indices,
  double *xs,
  double *ys,
  cairo_glyph_t **glyphs_out,
  int *count_out);
cairo_status_t cairoon_text_clusters_from_fields(
  int32_t *num_bytes,
  int32_t *num_glyphs,
  cairo_text_cluster_t **clusters_out,
  int *count_out);

cairo_status_t cairoon_surface_status(CairoonSurface *surface);
cairo_status_t cairoon_device_status(CairoonDevice *device);
cairo_status_t cairoon_mapped_image_surface_status(CairoonMappedImageSurface *surface);
cairo_status_t cairoon_context_status(CairoonContext *ctx);
cairo_status_t cairoon_path_status(CairoonPath *path);
cairo_status_t cairoon_pattern_status(CairoonPattern *pattern);
cairo_status_t cairoon_font_options_status(CairoonFontOptions *options);
cairo_status_t cairoon_font_face_status(CairoonFontFace *font_face);
cairo_status_t cairoon_scaled_font_status(CairoonScaledFont *scaled_font);
cairo_status_t cairoon_region_status(CairoonRegion *region);

#endif
