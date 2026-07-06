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
