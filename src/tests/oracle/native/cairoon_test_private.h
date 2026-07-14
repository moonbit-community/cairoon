#ifndef CAIROON_TEST_PRIVATE_H
#define CAIROON_TEST_PRIVATE_H

#include "../../../native/cairoon_private.h"

#if CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>
#endif
#if CAIRO_HAS_PS_SURFACE
#include <cairo-ps.h>
#endif
#if CAIRO_HAS_SVG_SURFACE
#include <cairo-svg.h>
#endif

#if CAIRO_VERSION < CAIRO_VERSION_ENCODE(1, 18, 0)
#define CAIRO_DITHER_NONE 0
#define CAIRO_DITHER_DEFAULT 1
#define CAIRO_DITHER_FAST 2
#define CAIRO_DITHER_GOOD 3
#define CAIRO_DITHER_BEST 4
#endif

static inline void cairoon_test_pattern_set_dither(
  cairo_pattern_t *pattern,
  int32_t dither) {
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_pattern_set_dither(pattern, (cairo_dither_t)dither);
#else
  (void)pattern;
  (void)dither;
#endif
}

static inline void cairoon_test_context_set_hairline(
  cairo_t *cr,
  int32_t enabled) {
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 18, 0)
  cairo_set_hairline(cr, enabled);
#else
  (void)cr;
  (void)enabled;
#endif
}

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
cairo_status_t cairoon_test_paint_quad_surface(cairo_surface_t *surface);
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
cairo_status_t cairoon_test_apply_surface_pattern_pad_bilinear(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_surface_pattern_none_matrix(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_linear_pattern_pad_bilinear(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_radial_pattern_repeat_bilinear(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_surface_pattern_repeat_bilinear(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_linear_pattern_none_good(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_radial_pattern_pad_good(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_mesh_pattern_curve_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_pattern_stack_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_mesh_mask_group_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_surface_source_mask_group_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_surface_mask_screen_group_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_gradient_surface_overlay_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_mesh_surface_soft_light_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_difference_surface_stroke_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_radial_color_dodge_surface_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_linear_hsl_hue_surface_mask_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_linear_hsl_saturation_surface_group_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_radial_hsl_color_surface_mask_combo(
  cairo_t *cr,
  double width,
  double height);
cairo_status_t cairoon_test_apply_linear_hsl_luminosity_surface_mask_combo(
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

int32_t cairoon_raster_source_surface_owner_count(CairoonSurface *surface);

#endif
