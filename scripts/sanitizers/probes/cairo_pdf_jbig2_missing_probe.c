#include <stddef.h>
#include <stdio.h>

#include <cairo.h>
#include <cairo-pdf.h>

#if defined(__GNUC__) || defined(__clang__)
#define CAIROON_PROBE_NOINLINE __attribute__((noinline))
#else
#define CAIROON_PROBE_NOINLINE
#endif

static cairo_status_t discard_output(
  void *closure,
  const unsigned char *data,
  unsigned int length) {
  (void)closure;
  (void)data;
  (void)length;
  return CAIRO_STATUS_SUCCESS;
}

static CAIROON_PROBE_NOINLINE cairo_surface_t *
cairoon_probe_pdf_surface_create_for_stream(void) {
  return cairo_pdf_surface_create_for_stream(discard_output, NULL, 8.0, 8.0);
}

static CAIROON_PROBE_NOINLINE void cairoon_probe_surface_finish(
  cairo_surface_t *surface) {
  cairo_surface_finish(surface);
}

static cairo_status_t render_missing_global(void) {
  static const unsigned char jbig2[] = {
    0x00, 0x00, 0x00, 0x01, 0x30, 0x00, 0x01, 0x00,
    0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x01, 0x00,
    0x00, 0x00, 0x01, 0x00, 0x00,
  };
  static const unsigned char global_id[] = "shared-jbig2-id";

  cairo_surface_t *pdf = cairoon_probe_pdf_surface_create_for_stream();
  cairo_surface_t *image = cairo_image_surface_create(CAIRO_FORMAT_A1, 1, 1);
  cairo_status_t status = cairo_surface_set_mime_data(
    image,
    CAIRO_MIME_TYPE_JBIG2,
    jbig2,
    sizeof(jbig2),
    NULL,
    NULL);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_surface_set_mime_data(
      image,
      CAIRO_MIME_TYPE_JBIG2_GLOBAL_ID,
      global_id,
      sizeof(global_id) - 1,
      NULL,
      NULL);
  }

  cairo_t *ctx = cairo_create(pdf);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_surface(ctx, image, 0.0, 0.0);
    cairo_paint(ctx);
    status = cairo_status(ctx);
  }
  cairo_destroy(ctx);
  cairo_surface_destroy(image);

  cairoon_probe_surface_finish(pdf);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairo_surface_status(pdf);
  }
  cairo_surface_destroy(pdf);
  return status;
}

int main(void) {
  cairo_status_t status = render_missing_global();
  cairo_debug_reset_static_data();
  if (status != CAIRO_STATUS_JBIG2_GLOBAL_MISSING) {
    fprintf(stderr, "CAIROON_PDF_JBIG2_STATUS=%d\n", (int)status);
    fflush(stderr);
    return 1;
  }
  fputs("CAIROON_PDF_JBIG2_STATUS=JBIG2_GLOBAL_MISSING\n", stderr);
  fflush(stderr);
  return 0;
}
