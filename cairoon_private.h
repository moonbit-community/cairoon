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
  cairo_device_t *ptr;
} CairoonDevice;

typedef struct {
  cairo_surface_t *base;
  cairo_surface_t *mapped;
  void *base_object;
} CairoonMappedImageSurface;

typedef struct {
  cairo_surface_t *surface;
  uint8_t *data;
  int32_t len;
  CairoonMappedImageSurface *mapped_object;
  void *surface_object;
} CairoonImageData;

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

typedef int32_t (*CairoonStreamWriteCallback)(moonbit_bytes_t data, void *arg);
typedef moonbit_bytes_t (*CairoonStreamReadCallback)(int32_t length, void *arg);
typedef CairoonSurface *(*CairoonRasterSourceAcquireCallback)(
  CairoonSurface *target,
  int32_t x,
  int32_t y,
  int32_t width,
  int32_t height,
  void *arg);
typedef void (*CairoonRasterSourceReleaseCallback)(
  CairoonSurface *surface,
  void *arg);
typedef struct CairoonRasterSourceState CairoonRasterSourceState;

CairoonSurface *cairoon_surface_wrap_owned(cairo_surface_t *ptr);
CairoonSurface *cairoon_surface_wrap_owned_with_base(
  cairo_surface_t *ptr,
  void *base);
CairoonSurface *cairoon_surface_wrap_borrowed(cairo_surface_t *ptr);
CairoonSurface *cairoon_surface_wrap_borrowed_with_base(
  cairo_surface_t *ptr,
  void *base);
CairoonDevice *cairoon_device_wrap_owned(cairo_device_t *ptr);
CairoonDevice *cairoon_device_wrap_borrowed(cairo_device_t *ptr);
CairoonMappedImageSurface *cairoon_mapped_image_surface_wrap_owned(
  cairo_surface_t *base,
  cairo_surface_t *mapped,
  void *base_object);
CairoonImageData *cairoon_image_data_wrap(
  cairo_surface_t *surface,
  uint8_t *data,
  int32_t len,
  CairoonMappedImageSurface *mapped_object,
  void *surface_object);
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

void *cairoon_stream_state_new(
  CairoonStreamWriteCallback callback,
  void *arg,
  cairo_status_t *status_out);
cairo_status_t cairoon_stream_write(
  void *closure,
  const unsigned char *data,
  unsigned int length);
cairo_status_t cairoon_stream_attach(cairo_surface_t *surface, void *state);
cairo_status_t cairoon_stream_attach_device(cairo_device_t *device, void *state);
void cairoon_stream_state_destroy(void *state);
void *cairoon_stream_read_state_new(
  CairoonStreamReadCallback callback,
  void *arg,
  cairo_status_t *status_out);
cairo_status_t cairoon_stream_read(
  void *closure,
  unsigned char *data,
  unsigned int length);
void cairoon_stream_read_state_destroy(void *state);

CairoonRasterSourceState *cairoon_raster_source_state_new(
  CairoonRasterSourceAcquireCallback acquire,
  void *acquire_arg,
  CairoonRasterSourceReleaseCallback release,
  void *release_arg,
  cairo_status_t *status_out);
cairo_status_t cairoon_raster_source_pattern_set_state(
  CairoonPattern *pattern,
  CairoonRasterSourceState *state);
CairoonRasterSourceState *cairoon_raster_source_pattern_get_state(
  CairoonPattern *pattern,
  cairo_status_t *status_out);
int32_t cairoon_raster_source_state_has_acquire(
  CairoonRasterSourceState *state);
int32_t cairoon_raster_source_state_has_release(
  CairoonRasterSourceState *state);
void *cairoon_raster_source_state_get_acquire_arg(
  CairoonRasterSourceState *state);
void *cairoon_raster_source_state_get_release_arg(
  CairoonRasterSourceState *state);

moonbit_bytes_t cairoon_copy_c_string(const char *str);
cairo_status_t cairoon_test_apply_linear_gradient(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_radial_gradient(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_surface_pattern(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_surface_pattern_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_linear_pattern_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_radial_pattern_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_group_compositing(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_mask_pattern(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_even_odd_fill(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_raster_source_pattern(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_mask_surface(cairo_t *cr);
cairo_status_t cairoon_test_apply_mesh_pattern(cairo_t *cr);
cairo_status_t cairoon_glyphs_from_fields(
  uint64_t *indices,
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
cairo_status_t cairoon_surface_require_type(
  CairoonSurface *surface,
  cairo_surface_type_t type);
moonbit_bytes_t cairoon_copy_image_surface_data(
  cairo_surface_t *surface,
  cairo_status_t *status_out);
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
