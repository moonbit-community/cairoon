#include "cairoon_test_vector_private.h"

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_pdf_jpeg_mime_oracle(
  moonbit_bytes_t filename,
  moonbit_bytes_t payload) {
#if CAIRO_HAS_PDF_SURFACE && defined(CAIRO_HAS_MIME_SURFACE)
  if (filename == NULL || payload == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }
  int32_t payload_len = Moonbit_array_length(payload);
  if (payload_len < 0) {
    return CAIRO_STATUS_INVALID_SIZE;
  }

  cairo_surface_t *surface = cairo_pdf_surface_create(
    (const char *)filename,
    3.0,
    3.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
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
    status = cairo_surface_status(surface);
  }

  cairo_surface_t *image = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    image = cairo_image_surface_create(CAIRO_FORMAT_RGB24, 1, 1);
    status = cairo_surface_status(image);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_surface_set_mime_data(
      image,
      CAIRO_MIME_TYPE_JPEG,
      (const unsigned char *)payload,
      (unsigned long)payload_len,
      NULL,
      NULL);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_surface(cr, image, 0.0, 0.0);
    cairo_paint(cr);
    status = cairo_status(cr);
  }

  if (cr != NULL) {
    cairo_destroy(cr);
  }
  if (image != NULL) {
    cairo_surface_destroy(image);
  }
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
#else
  (void)filename;
  (void)payload;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_pdf_thumbnail_oracle(
  moonbit_bytes_t filename) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  if (filename == NULL) {
    return CAIRO_STATUS_INVALID_STRING;
  }

  cairo_surface_t *surface = cairo_pdf_surface_create(
    (const char *)filename,
    20.0,
    20.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
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
    cairo_pdf_surface_set_thumbnail_size(surface, 4, 4);
    status = cairo_surface_status(surface);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
    cairo_paint(cr);
    status = cairo_status(cr);
  }

  if (cr != NULL) {
    cairo_destroy(cr);
  }
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
#else
  (void)filename;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

cairo_status_t cairoon_test_render_pdf_document_features(
  const char *name) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_surface_t *surface = cairo_pdf_surface_create(name, 100.0, 100.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_TITLE,
      "Cairoon Combined Oracle");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_CREATOR,
      "cairoon-combined-oracle");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_CREATE_DATE,
      "2026-01-02T03:04:05+00:00");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_MOD_DATE,
      "2026-01-02T03:04:05+00:00");
    cairoon_test_pdf_surface_set_custom_metadata(
      surface,
      "ISBN",
      "978-0123456789");
    cairo_pdf_surface_set_page_label(surface, "intro");
    cairo_pdf_surface_add_outline(
      surface,
      CAIRO_PDF_OUTLINE_ROOT,
      "intro page",
      "page=1 pos=[10 20]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD);
    status = cairo_surface_status(surface);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/combined'");
    cairo_rectangle(cr, 10.0, 10.0, 80.0, 20.0);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);

    cairo_set_source_rgb(cr, 0.0, 0.5, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='combined-direct-dest'");
    cairo_rectangle(cr, 10.0, 40.0, 80.0, 20.0);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_LINK);

    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pdf_surface_set_page_label(surface, "details");
    cairo_pdf_surface_add_outline(
      surface,
      CAIRO_PDF_OUTLINE_ROOT,
      "details page",
      "page=2 pos=[10 60]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_tag_begin(
      cr,
      CAIRO_TAG_DEST,
      "name='combined-direct-dest' x=10 y=60");
    cairo_rectangle(cr, 10.0, 10.0, 80.0, 20.0);
    cairo_fill(cr);
    cairo_tag_end(cr, CAIRO_TAG_DEST);

    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_set_source_rgb(cr, 0.25, 0.25, 0.25);
    cairo_rectangle(cr, 10.0, 50.0, 80.0, 30.0);
    cairo_fill(cr);
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");

    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (cr != NULL) {
    cairo_destroy(cr);
  }
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
#else
  (void)name;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

cairo_status_t cairoon_test_render_pdf_text_document_features(
  const char *name) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_surface_t *surface = cairo_pdf_surface_create(name, 100.0, 100.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_TITLE,
      "Cairoon Combined");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_CREATOR,
      "cairoon combined test");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_CREATE_DATE,
      "2026-01-02T03:04:05+00:00");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_MOD_DATE,
      "2026-01-02T03:04:05+00:00");
    cairoon_test_pdf_surface_set_custom_metadata(
      surface,
      "ISBN",
      "978-0123456789");
    cairo_pdf_surface_set_page_label(surface, "intro");
    cairo_pdf_surface_add_outline(
      surface,
      CAIRO_PDF_OUTLINE_ROOT,
      "intro page",
      "page=1 pos=[10 20]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN | CAIRO_PDF_OUTLINE_FLAG_BOLD);
    status = cairo_surface_status(surface);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_select_font_face(
      cr,
      "serif",
      CAIRO_FONT_SLANT_NORMAL,
      CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, 12.0);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/combined'");
    cairo_move_to(cr, 10.0, 20.0);
    cairo_show_text(cr, "combined intro");
    cairo_tag_end(cr, CAIRO_TAG_LINK);
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pdf_surface_set_page_label(surface, "details");
    cairo_pdf_surface_add_outline(
      surface,
      CAIRO_PDF_OUTLINE_ROOT,
      "details page",
      "page=2 pos=[10 60]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='combined-dest' x=10 y=60");
    cairo_move_to(cr, 10.0, 60.0);
    cairo_show_text(cr, "destination");
    cairo_tag_end(cr, CAIRO_TAG_DEST);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_move_to(cr, 10.0, 80.0);
    cairo_show_text(cr, "combined structure");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");
    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (cr != NULL) {
    cairo_destroy(cr);
  }
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
#else
  (void)name;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}

cairo_status_t cairoon_test_render_pdf_page_operation_document_features(
  const char *name) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 15, 10)
  cairo_surface_t *surface = cairo_pdf_surface_create(name, 100.0, 100.0);
  cairo_status_t status = cairo_surface_status(surface);

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pdf_surface_restrict_to_version(surface, CAIRO_PDF_VERSION_1_4);
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_TITLE,
      "Cairoon Page Ops");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_CREATOR,
      "cairoon page ops test");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_CREATE_DATE,
      "2026-01-02T03:04:05+00:00");
    cairo_pdf_surface_set_metadata(
      surface,
      CAIRO_PDF_METADATA_MOD_DATE,
      "2026-01-02T03:04:05+00:00");
    cairoon_test_pdf_surface_set_custom_metadata(surface, "Case", "copy-show");
    cairo_pdf_surface_set_page_label(surface, "copy-intro");
    cairo_pdf_surface_add_outline(
      surface,
      CAIRO_PDF_OUTLINE_ROOT,
      "copy intro",
      "page=1 pos=[10 20]",
      CAIRO_PDF_OUTLINE_FLAG_OPEN);
    status = cairo_surface_status(surface);
  }

  cairo_t *cr = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    cr = cairo_create(surface);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_select_font_face(
      cr,
      "serif",
      CAIRO_FONT_SLANT_NORMAL,
      CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size(cr, 12.0);
    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/page-op'");
    cairo_move_to(cr, 10.0, 20.0);
    cairo_show_text(cr, "copy intro");
    cairo_tag_end(cr, CAIRO_TAG_LINK);

    cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='page-op-dest'");
    cairo_move_to(cr, 10.0, 40.0);
    cairo_show_text(cr, "jump");
    cairo_tag_end(cr, CAIRO_TAG_LINK);

    cairo_copy_page(cr);
    status = cairo_status(cr);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pdf_surface_set_page_label(surface, "copy-details");
    cairo_pdf_surface_add_outline(
      surface,
      CAIRO_PDF_OUTLINE_ROOT,
      "copy details",
      "page=2 pos=[10 60]",
      CAIRO_PDF_OUTLINE_FLAG_ITALIC);
    status = cairo_surface_status(surface);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 0.8, 0.0, 0.0);
    cairo_tag_begin(cr, CAIRO_TAG_DEST, "name='page-op-dest' x=10 y=60");
    cairo_move_to(cr, 10.0, 60.0);
    cairo_show_text(cr, "destination");
    cairo_tag_end(cr, CAIRO_TAG_DEST);

    cairo_set_source_rgb(cr, 0.1, 0.1, 0.1);
    cairo_tag_begin(cr, "Document", "");
    cairo_tag_begin(cr, "Sect", "");
    cairo_tag_begin(cr, "P", "");
    cairo_move_to(cr, 10.0, 80.0);
    cairo_show_text(cr, "retained copy page");
    cairo_tag_end(cr, "P");
    cairo_tag_end(cr, "Sect");
    cairo_tag_end(cr, "Document");

    cairo_show_page(cr);
    status = cairo_status(cr);
  }

  if (cr != NULL) {
    cairo_destroy(cr);
  }
  cairo_surface_finish(surface);
  cairo_status_t surface_status = cairo_surface_status(surface);
  cairo_surface_destroy(surface);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  return surface_status;
#else
  (void)name;
  return CAIRO_STATUS_INVALID_STATUS;
#endif
}
