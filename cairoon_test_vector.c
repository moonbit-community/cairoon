#include "cairoon_test_vector_private.h"

static cairo_status_t cairoon_test_render_vector_surface(
  cairo_surface_t *surface,
  int32_t scene) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    return status;
  }

  cairo_t *ctx = cairo_create(surface);
  status = cairoon_test_draw_vector_scene(ctx, scene, 10.0, 10.0);
  cairo_destroy(ctx);

  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
}

static cairo_status_t cairoon_test_render_surface_page_surface(
  cairo_surface_t *surface,
  int32_t retain_first_page) {
  cairo_status_t status = cairo_surface_status(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    return status;
  }

  cairo_t *ctx = cairo_create(surface);
  cairo_set_source_rgb(ctx, 0.0, 0.0, 1.0);
  cairo_rectangle(ctx, 1.0, 1.0, 3.0, 8.0);
  cairo_fill(ctx);
  status = cairo_status(ctx);

  if (status == CAIRO_STATUS_SUCCESS) {
    if (retain_first_page) {
      cairo_surface_copy_page(surface);
    } else {
      cairo_surface_show_page(surface);
    }
    status = cairo_surface_status(surface);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(ctx, 1.0, 0.0, 0.0);
    cairo_rectangle(ctx, 1.0, 6.0, 8.0, 3.0);
    cairo_fill(ctx);
    status = cairo_status(ctx);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_surface_show_page(surface);
    status = cairo_surface_status(surface);
  }

  cairo_destroy(ctx);
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_vector_scene_oracle(
  int32_t kind,
  int32_t scene,
  moonbit_bytes_t filename) {
  const char *name = (const char *)filename;
  cairo_surface_t *surface = NULL;
  if (scene == CAIROON_TEST_VECTOR_BACKEND_STREAM_COMBO) {
    return cairoon_test_render_backend_stream_combo_features(kind, name);
  }
  if (scene == CAIROON_TEST_VECTOR_BACKEND_PAGE_COMBO) {
    return cairoon_test_render_backend_page_combo_features(kind, name);
  }

  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE
      if (scene == CAIROON_TEST_VECTOR_PDF_DOCUMENT_FEATURES) {
        return cairoon_test_render_pdf_document_features(name);
      }
      if (scene == CAIROON_TEST_VECTOR_PDF_TEXT_DOCUMENT_FEATURES) {
        return cairoon_test_render_pdf_text_document_features(name);
      }
      if (scene == CAIROON_TEST_VECTOR_PDF_PAGE_OPERATION_DOCUMENT_FEATURES) {
        return cairoon_test_render_pdf_page_operation_document_features(name);
      }
      surface = cairo_pdf_surface_create(name, 10.0, 10.0);
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon-vector-oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      return cairoon_test_render_vector_surface(surface, scene);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      if (scene == CAIROON_TEST_VECTOR_PS_DSC_FEATURES) {
        return cairoon_test_render_ps_dsc_features(name);
      }
      surface = cairo_ps_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_vector_surface(surface, scene);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      if (scene == CAIROON_TEST_VECTOR_SVG_UNIT_FEATURES) {
        return cairoon_test_render_svg_unit_features(name);
      }
      surface = cairo_svg_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_vector_surface(surface, scene);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_surface_page_oracle(
  int32_t kind,
  moonbit_bytes_t filename) {
  const char *name = (const char *)filename;
  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE
      surface = cairo_pdf_surface_create(name, 10.0, 10.0);
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon-vector-oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      return cairoon_test_render_surface_page_surface(surface, 1);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_surface_page_surface(surface, 1);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_surface_page_surface(surface, 1);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_surface_show_page_oracle(
  int32_t kind,
  moonbit_bytes_t filename) {
  const char *name = (const char *)filename;
  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE
      surface = cairo_pdf_surface_create(name, 10.0, 10.0);
      cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATOR,
        "cairoon-vector-oracle");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_CREATE_DATE,
        "2026-01-02T03:04:05+00:00");
      cairo_pdf_surface_set_metadata(
        surface,
        CAIRO_PDF_METADATA_MOD_DATE,
        "2026-01-02T03:04:05+00:00");
      return cairoon_test_render_surface_page_surface(surface, 0);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_PS:
#if CAIRO_HAS_PS_SURFACE
      surface = cairo_ps_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_surface_page_surface(surface, 0);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
      surface = cairo_svg_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_surface_page_surface(surface, 0);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_vector_oracle(
  int32_t kind,
  moonbit_bytes_t filename) {
  return cairoon_test_render_vector_scene_oracle(
    kind,
    CAIROON_TEST_VECTOR_PAINT,
    filename);
}
