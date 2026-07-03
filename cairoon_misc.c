#include "cairoon_private.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>
#endif
#if CAIRO_HAS_PS_SURFACE
#include <cairo-ps.h>
#endif
#if CAIRO_HAS_SVG_SURFACE
#include <cairo-svg.h>
#endif

enum {
  CAIROON_TEST_VECTOR_PDF = 0,
  CAIROON_TEST_VECTOR_PS = 1,
  CAIROON_TEST_VECTOR_SVG = 2
};

enum {
  CAIROON_TEST_VECTOR_PAINT = 0,
  CAIROON_TEST_VECTOR_STROKE_LINE = 1,
  CAIROON_TEST_VECTOR_RECTANGLE = 2,
  CAIROON_TEST_VECTOR_BEZIER = 3,
  CAIROON_TEST_VECTOR_TRANSFORM = 4,
  CAIROON_TEST_VECTOR_LINEAR_GRADIENT = 5,
  CAIROON_TEST_VECTOR_RADIAL_GRADIENT = 6,
  CAIROON_TEST_VECTOR_TEXT_PATH = 7,
  CAIROON_TEST_VECTOR_SHOW_TEXT = 8,
  CAIROON_TEST_VECTOR_MULTI_PAGE = 9,
  CAIROON_TEST_VECTOR_CLIP = 10,
  CAIROON_TEST_VECTOR_DASH = 11,
  CAIROON_TEST_VECTOR_SURFACE_PATTERN = 12,
  CAIROON_TEST_VECTOR_MASK_SURFACE = 13,
  CAIROON_TEST_VECTOR_MESH_PATTERN = 14,
  CAIROON_TEST_VECTOR_PDF_URI_TAG = 15,
  CAIROON_TEST_VECTOR_PDF_DEST_TAG = 16,
  CAIROON_TEST_VECTOR_PDF_STRUCT_TAG = 17,
  CAIROON_TEST_VECTOR_PDF_DOCUMENT_FEATURES = 18
};

enum {
  CAIROON_TEST_IMAGE_BLUE_PAINT = 0,
  CAIROON_TEST_IMAGE_STROKE_LINE = 1,
  CAIROON_TEST_IMAGE_RECTANGLE = 2,
  CAIROON_TEST_IMAGE_BEZIER = 3,
  CAIROON_TEST_IMAGE_TRANSFORM = 4,
  CAIROON_TEST_IMAGE_RGBA_PAINT = 5,
  CAIROON_TEST_IMAGE_LINEAR_GRADIENT = 6,
  CAIROON_TEST_IMAGE_RADIAL_GRADIENT = 7,
  CAIROON_TEST_IMAGE_TEXT_PATH = 8,
  CAIROON_TEST_IMAGE_SHOW_TEXT = 9,
  CAIROON_TEST_IMAGE_GLYPH_PATH = 10,
  CAIROON_TEST_IMAGE_SHOW_GLYPHS = 11,
  CAIROON_TEST_IMAGE_SHOW_TEXT_GLYPHS = 12,
  CAIROON_TEST_IMAGE_SOURCE_SURFACE_OFFSET = 13,
  CAIROON_TEST_IMAGE_MASK_SURFACE_OFFSET = 14,
  CAIROON_TEST_IMAGE_RASTER_SOURCE_PATTERN = 15
};

typedef struct {
  unsigned char *data;
  size_t len;
} CairoonTestFile;

typedef struct {
  cairo_surface_t *source;
} CairoonTestRasterSource;

static int cairoon_test_read_file(
  const char *filename,
  CairoonTestFile *out) {
  out->data = NULL;
  out->len = 0;
  FILE *file = fopen(filename, "rb");
  if (file == NULL) {
    return 0;
  }
  if (fseek(file, 0, SEEK_END) != 0) {
    fclose(file);
    return 0;
  }
  long size = ftell(file);
  if (size < 0) {
    fclose(file);
    return 0;
  }
  if (fseek(file, 0, SEEK_SET) != 0) {
    fclose(file);
    return 0;
  }
  unsigned char *data = NULL;
  if (size > 0) {
    data = (unsigned char *)malloc((size_t)size);
    if (data == NULL) {
      fclose(file);
      return 0;
    }
    size_t read_len = fread(data, 1, (size_t)size, file);
    if (read_len != (size_t)size) {
      free(data);
      fclose(file);
      return 0;
    }
  }
  fclose(file);
  out->data = data;
  out->len = (size_t)size;
  return 1;
}

static void cairoon_test_free_file(CairoonTestFile *file) {
  free(file->data);
  file->data = NULL;
  file->len = 0;
}

static int cairoon_test_starts_with(
  const unsigned char *data,
  size_t len,
  const char *prefix) {
  size_t prefix_len = strlen(prefix);
  return len >= prefix_len && memcmp(data, prefix, prefix_len) == 0;
}

static int cairoon_test_starts_with_at(
  const unsigned char *data,
  size_t len,
  size_t pos,
  const char *prefix) {
  size_t prefix_len = strlen(prefix);
  return pos <= len &&
    len - pos >= prefix_len &&
    memcmp(data + pos, prefix, prefix_len) == 0;
}

static int cairoon_test_skip_digits_after_prefix(
  const unsigned char *data,
  size_t len,
  size_t *pos,
  const char *prefix) {
  if (!cairoon_test_starts_with_at(data, len, *pos, prefix)) {
    return 0;
  }
  *pos += strlen(prefix);
  size_t digit_start = *pos;
  while (*pos < len && isdigit(data[*pos])) {
    *pos += 1;
  }
  return *pos > digit_start;
}

static int cairoon_test_files_equal_svg_normalized(
  const CairoonTestFile *left,
  const CairoonTestFile *right) {
  size_t left_pos = 0;
  size_t right_pos = 0;
  while (left_pos < left->len && right_pos < right->len) {
    size_t left_after_source = left_pos;
    size_t right_after_source = right_pos;
    if (
      cairoon_test_skip_digits_after_prefix(
        left->data,
        left->len,
        &left_after_source,
        "source-") &&
      cairoon_test_skip_digits_after_prefix(
        right->data,
        right->len,
        &right_after_source,
        "source-")) {
      left_pos = left_after_source;
      right_pos = right_after_source;
      continue;
    }
    if (left->data[left_pos] != right->data[right_pos]) {
      return 0;
    }
    left_pos += 1;
    right_pos += 1;
  }
  return left_pos == left->len && right_pos == right->len;
}

static int cairoon_test_next_normalized_line(
  int32_t kind,
  const unsigned char *data,
  size_t len,
  size_t *pos,
  const unsigned char **line,
  size_t *line_len) {
  while (*pos < len) {
    size_t start = *pos;
    while (*pos < len && data[*pos] != '\n') {
      *pos += 1;
    }
    if (*pos < len) {
      *pos += 1;
    }
    size_t current_len = *pos - start;
    if (
      kind == CAIROON_TEST_VECTOR_PS &&
      cairoon_test_starts_with(data + start, current_len, "%%CreationDate:")) {
      continue;
    }
    *line = data + start;
    *line_len = current_len;
    return 1;
  }
  return 0;
}

static int cairoon_test_files_equal_normalized(
  int32_t kind,
  const CairoonTestFile *left,
  const CairoonTestFile *right) {
  if (kind == CAIROON_TEST_VECTOR_SVG) {
    return cairoon_test_files_equal_svg_normalized(left, right);
  }
  if (kind != CAIROON_TEST_VECTOR_PS) {
    return left->len == right->len &&
      (left->len == 0 || memcmp(left->data, right->data, left->len) == 0);
  }

  size_t left_pos = 0;
  size_t right_pos = 0;
  for (;;) {
    const unsigned char *left_line = NULL;
    const unsigned char *right_line = NULL;
    size_t left_len = 0;
    size_t right_len = 0;
    int left_has_line = cairoon_test_next_normalized_line(
      kind, left->data, left->len, &left_pos, &left_line, &left_len);
    int right_has_line = cairoon_test_next_normalized_line(
      kind, right->data, right->len, &right_pos, &right_line, &right_len);
    if (!left_has_line || !right_has_line) {
      return left_has_line == right_has_line;
    }
    if (left_len != right_len || memcmp(left_line, right_line, left_len) != 0) {
      return 0;
    }
  }
}

static cairo_status_t cairoon_test_apply_linear_gradient(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_linear(0.0, 0.0, width, 0.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 0.0, 0.0, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.0, 0.0, 1.0, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

static cairo_status_t cairoon_test_apply_radial_gradient(
  cairo_t *cr,
  double width,
  double height) {
  cairo_pattern_t *pattern = cairo_pattern_create_radial(
    width / 2.0,
    height / 2.0,
    1.0,
    width / 2.0,
    height / 2.0,
    width / 2.0);
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_add_color_stop_rgba(pattern, 0.0, 1.0, 1.0, 1.0, 1.0);
    cairo_pattern_add_color_stop_rgba(pattern, 1.0, 0.0, 0.0, 0.0, 1.0);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

static cairo_status_t cairoon_test_paint_quad_surface(
  cairo_surface_t *surface) {
  cairo_t *ctx = cairo_create(surface);
  cairo_status_t status = cairo_status(ctx);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(ctx, 1.0, 0.0, 0.0);
    cairo_rectangle(ctx, 0.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgb(ctx, 0.0, 1.0, 0.0);
    cairo_rectangle(ctx, 1.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgb(ctx, 0.0, 0.0, 1.0);
    cairo_rectangle(ctx, 0.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgb(ctx, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    status = cairo_status(ctx);
  }
  cairo_destroy(ctx);
  return status;
}

static cairo_status_t cairoon_test_apply_surface_pattern(
  cairo_t *cr,
  double width,
  double height) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_paint_quad_surface(surface);
  }

  cairo_pattern_t *pattern = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    pattern = cairo_pattern_create_for_surface(surface);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }

  if (pattern != NULL) {
    cairo_pattern_destroy(pattern);
  }
  cairo_surface_destroy(surface);
  return status;
}

static cairo_surface_t *cairoon_test_raster_source_acquire(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *target,
  const cairo_rectangle_int_t *extents) {
  (void)pattern;
  (void)target;
  (void)extents;
  CairoonTestRasterSource *state =
    (CairoonTestRasterSource *)callback_data;
  if (state == NULL || state->source == NULL) {
    return NULL;
  }
  return cairo_surface_reference(state->source);
}

static void cairoon_test_raster_source_release(
  cairo_pattern_t *pattern,
  void *callback_data,
  cairo_surface_t *surface) {
  (void)pattern;
  (void)callback_data;
  cairo_surface_destroy(surface);
}

static cairo_status_t cairoon_test_apply_raster_source_pattern(
  cairo_t *cr,
  double width,
  double height) {
  cairo_surface_t *source =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(source);
  if (status == CAIRO_STATUS_SUCCESS) {
    status = cairoon_test_paint_quad_surface(source);
  }

  cairo_pattern_t *pattern = NULL;
  CairoonTestRasterSource state = {source};
  if (status == CAIRO_STATUS_SUCCESS) {
    pattern = cairo_pattern_create_raster_source(
      NULL,
      CAIRO_CONTENT_COLOR_ALPHA,
      2,
      2);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_raster_source_pattern_set_callback_data(pattern, &state);
    cairo_raster_source_pattern_set_acquire(
      pattern,
      cairoon_test_raster_source_acquire,
      cairoon_test_raster_source_release);
    cairo_pattern_set_extend(pattern, CAIRO_EXTEND_REPEAT);
    cairo_pattern_set_filter(pattern, CAIRO_FILTER_NEAREST);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, width, height);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }

  if (pattern != NULL) {
    cairo_pattern_destroy(pattern);
  }
  cairo_surface_destroy(source);
  return status;
}

static cairo_status_t cairoon_test_apply_mask_surface(cairo_t *cr) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
  cairo_status_t status = cairo_surface_status(surface);
  cairo_t *ctx = NULL;
  if (status == CAIRO_STATUS_SUCCESS) {
    ctx = cairo_create(surface);
    status = cairo_status(ctx);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 0.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 0.5);
    cairo_rectangle(ctx, 1.0, 0.0, 1.0, 1.0);
    cairo_fill(ctx);
    cairo_set_source_rgba(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_rectangle(ctx, 1.0, 1.0, 1.0, 1.0);
    cairo_fill(ctx);
    status = cairo_status(ctx);
  }
  if (ctx != NULL) {
    cairo_destroy(ctx);
  }

  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_mask_surface(cr, surface, 4.0, 4.0);
    status = cairo_status(cr);
  }
  cairo_surface_destroy(surface);
  return status;
}

static cairo_status_t cairoon_test_apply_mesh_pattern(cairo_t *cr) {
  cairo_pattern_t *pattern = cairo_pattern_create_mesh();
  cairo_status_t status = cairo_pattern_status(pattern);
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_mesh_pattern_begin_patch(pattern);
    cairo_mesh_pattern_move_to(pattern, 0.0, 0.0);
    cairo_mesh_pattern_line_to(pattern, 10.0, 0.0);
    cairo_mesh_pattern_line_to(pattern, 10.0, 10.0);
    cairo_mesh_pattern_line_to(pattern, 0.0, 10.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 0, 1.0, 0.0, 0.0, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 1, 0.0, 1.0, 0.0, 1.0);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 2, 0.0, 0.0, 1.0, 0.75);
    cairo_mesh_pattern_set_corner_color_rgba(pattern, 3, 1.0, 1.0, 0.0, 1.0);
    cairo_mesh_pattern_end_patch(pattern);
    status = cairo_pattern_status(pattern);
  }
  if (status == CAIRO_STATUS_SUCCESS) {
    cairo_rectangle(cr, 0.0, 0.0, 10.0, 10.0);
    cairo_set_source(cr, pattern);
    cairo_fill(cr);
    status = cairo_status(cr);
  }
  cairo_pattern_destroy(pattern);
  return status;
}

static cairo_status_t cairoon_test_draw_pdf_uri_tag(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "uri='https://example.com/direct'");
  cairo_rectangle(cr, 1.0, 1.0, 8.0, 8.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_LINK);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_pdf_dest_tag(cairo_t *cr) {
  cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
  cairo_tag_begin(cr, CAIRO_TAG_LINK, "dest='cairoon-direct-dest'");
  cairo_rectangle(cr, 1.0, 1.0, 3.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_LINK);

  cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
  cairo_tag_begin(
    cr,
    CAIRO_TAG_DEST,
    "name='cairoon-direct-dest' x=6 y=6");
  cairo_rectangle(cr, 6.0, 6.0, 3.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, CAIRO_TAG_DEST);
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_draw_pdf_struct_tag(cairo_t *cr) {
  cairo_tag_begin(cr, "Document", "");
  cairo_tag_begin(cr, "Sect", "");
  cairo_tag_begin(cr, "H1", "");
  cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
  cairo_rectangle(cr, 1.0, 1.0, 8.0, 2.0);
  cairo_fill(cr);
  cairo_tag_end(cr, "H1");

  cairo_tag_begin(cr, "P", "");
  cairo_set_source_rgb(cr, 0.25, 0.25, 0.25);
  cairo_rectangle(cr, 1.0, 5.0, 8.0, 3.0);
  cairo_fill(cr);
  cairo_tag_end(cr, "P");
  cairo_tag_end(cr, "Sect");
  cairo_tag_end(cr, "Document");
  return cairo_status(cr);
}

static cairo_status_t cairoon_test_render_pdf_document_features(
  const char *name) {
#if CAIRO_HAS_PDF_SURFACE && CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 6)
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
    cairo_pdf_surface_set_custom_metadata(
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

static cairo_status_t cairoon_test_draw_vector_scene(
  cairo_t *cr,
  int32_t scene,
  double width,
  double height) {
  switch (scene) {
    case CAIROON_TEST_VECTOR_PAINT:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_VECTOR_STROKE_LINE:
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.5);
      cairo_move_to(cr, 1.5, 1.5);
      cairo_line_to(cr, width - 1.5, height - 1.5);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_VECTOR_RECTANGLE:
      cairo_rectangle(cr, 2.0, 2.0, width - 4.0, height - 4.0);
      cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 0.75);
      cairo_fill_preserve(cr);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_VECTOR_BEZIER:
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.25);
      cairo_move_to(cr, 1.0, height - 1.0);
      cairo_curve_to(
        cr,
        3.0,
        1.0,
        width - 3.0,
        height - 1.0,
        width - 1.0,
        1.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_VECTOR_TRANSFORM:
      cairo_translate(cr, width / 2.0, height / 2.0);
      cairo_rotate(cr, 0.25);
      cairo_scale(cr, 1.2, 0.8);
      cairo_rectangle(cr, -3.0, -2.0, 6.0, 4.0);
      cairo_set_source_rgb(cr, 1.0, 0.5, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_VECTOR_LINEAR_GRADIENT:
      return cairoon_test_apply_linear_gradient(cr, width, height);
    case CAIROON_TEST_VECTOR_RADIAL_GRADIENT:
      return cairoon_test_apply_radial_gradient(cr, width, height);
    case CAIROON_TEST_VECTOR_TEXT_PATH:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 4.0);
      cairo_move_to(cr, 1.0, 6.5);
      cairo_text_path(cr, "Hi");
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_VECTOR_SHOW_TEXT:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 4.0);
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_move_to(cr, 1.0, 6.5);
      cairo_show_text(cr, "Hi");
      break;
    case CAIROON_TEST_VECTOR_MULTI_PAGE:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      cairo_show_page(cr);
      if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
        return cairo_status(cr);
      }
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_paint(cr);
      cairo_show_page(cr);
      break;
    case CAIROON_TEST_VECTOR_CLIP:
      cairo_rectangle(cr, 1.0, 1.0, width - 2.0, height - 2.0);
      cairo_clip(cr);
      cairo_set_source_rgb(cr, 0.0, 1.0, 0.0);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_VECTOR_DASH: {
      double dashes[] = {1.0, 1.5};
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 1.0);
      cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
      cairo_set_dash(cr, dashes, 2, 0.5);
      cairo_move_to(cr, 1.0, height / 2.0);
      cairo_line_to(cr, width - 1.0, height / 2.0);
      cairo_stroke(cr);
      break;
    }
    case CAIROON_TEST_VECTOR_SURFACE_PATTERN:
      return cairoon_test_apply_surface_pattern(cr, width, height);
    case CAIROON_TEST_VECTOR_MASK_SURFACE:
      return cairoon_test_apply_mask_surface(cr);
    case CAIROON_TEST_VECTOR_MESH_PATTERN:
      return cairoon_test_apply_mesh_pattern(cr);
    case CAIROON_TEST_VECTOR_PDF_URI_TAG:
      return cairoon_test_draw_pdf_uri_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_DEST_TAG:
      return cairoon_test_draw_pdf_dest_tag(cr);
    case CAIROON_TEST_VECTOR_PDF_STRUCT_TAG:
      return cairoon_test_draw_pdf_struct_tag(cr);
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
  return cairo_status(cr);
}

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

static cairo_status_t cairoon_test_draw_argb32_scene(
  cairo_t *cr,
  int32_t scene,
  double width,
  double height) {
  switch (scene) {
    case CAIROON_TEST_IMAGE_BLUE_PAINT:
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_IMAGE_STROKE_LINE:
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_move_to(cr, 2.5, 2.5);
      cairo_line_to(cr, width - 2.5, height - 2.5);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_IMAGE_RECTANGLE:
      cairo_rectangle(cr, 2.0, 2.0, width - 6.0, height - 6.0);
      cairo_set_source_rgba(cr, 0.0, 1.0, 0.0, 0.75);
      cairo_fill_preserve(cr);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_IMAGE_BEZIER:
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_set_line_width(cr, 2.0);
      cairo_move_to(cr, 2.0, height - 2.0);
      cairo_curve_to(cr, 5.0, 1.0, width - 5.0, height - 1.0, width - 2.0, 2.0);
      cairo_stroke(cr);
      break;
    case CAIROON_TEST_IMAGE_TRANSFORM:
      cairo_translate(cr, width / 2.0, height / 2.0);
      cairo_rotate(cr, 0.25);
      cairo_scale(cr, 1.2, 0.8);
      cairo_rectangle(cr, -4.0, -3.0, 8.0, 6.0);
      cairo_set_source_rgb(cr, 1.0, 0.5, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_IMAGE_RGBA_PAINT:
      cairo_set_source_rgba(cr, 1.0, 0.0, 0.0, 0.5);
      cairo_paint(cr);
      break;
    case CAIROON_TEST_IMAGE_LINEAR_GRADIENT:
      return cairoon_test_apply_linear_gradient(cr, width, height);
    case CAIROON_TEST_IMAGE_RADIAL_GRADIENT:
      return cairoon_test_apply_radial_gradient(cr, width, height);
    case CAIROON_TEST_IMAGE_TEXT_PATH:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 8.0);
      cairo_move_to(cr, 2.0, 10.0);
      cairo_text_path(cr, "Hi");
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_fill(cr);
      break;
    case CAIROON_TEST_IMAGE_SHOW_TEXT:
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 8.0);
      cairo_set_source_rgb(cr, 0.0, 0.0, 0.0);
      cairo_move_to(cr, 2.0, 10.0);
      cairo_show_text(cr, "Hi");
      break;
    case CAIROON_TEST_IMAGE_GLYPH_PATH: {
      cairo_glyph_t glyph = {0, 2.0, 12.0};
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 12.0);
      cairo_glyph_path(cr, &glyph, 1);
      cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
      cairo_fill(cr);
      break;
    }
    case CAIROON_TEST_IMAGE_SHOW_GLYPHS: {
      cairo_glyph_t glyph = {0, 2.0, 12.0};
      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 12.0);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_show_glyphs(cr, &glyph, 1);
      break;
    }
    case CAIROON_TEST_IMAGE_SHOW_TEXT_GLYPHS: {
      const char *text = "a";
      int text_len = (int)strlen(text);
      cairo_glyph_t *glyphs = NULL;
      int num_glyphs = 0;
      cairo_text_cluster_t *clusters = NULL;
      int num_clusters = 0;
      cairo_text_cluster_flags_t flags = 0;

      cairo_select_font_face(
        cr,
        "serif",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL);
      cairo_set_font_size(cr, 12.0);
      cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
      cairo_status_t status = cairo_scaled_font_text_to_glyphs(
        cairo_get_scaled_font(cr),
        2.0,
        12.0,
        text,
        text_len,
        &glyphs,
        &num_glyphs,
        &clusters,
        &num_clusters,
        &flags);
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_show_text_glyphs(
          cr,
          text,
          text_len,
          glyphs,
          num_glyphs,
          clusters,
          num_clusters,
          flags);
        status = cairo_status(cr);
      }
      cairo_glyph_free(glyphs);
      cairo_text_cluster_free(clusters);
      return status;
    }
    case CAIROON_TEST_IMAGE_SOURCE_SURFACE_OFFSET: {
      cairo_surface_t *source =
        cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
      cairo_status_t status = cairo_surface_status(source);
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_t *source_cr = cairo_create(source);
        cairo_set_source_rgb(source_cr, 1.0, 0.0, 0.0);
        cairo_rectangle(source_cr, 0.0, 0.0, 1.0, 1.0);
        cairo_fill(source_cr);
        cairo_set_source_rgb(source_cr, 0.0, 1.0, 0.0);
        cairo_rectangle(source_cr, 1.0, 0.0, 1.0, 1.0);
        cairo_fill(source_cr);
        cairo_set_source_rgb(source_cr, 0.0, 0.0, 1.0);
        cairo_rectangle(source_cr, 0.0, 1.0, 1.0, 1.0);
        cairo_fill(source_cr);
        cairo_set_source_rgb(source_cr, 1.0, 1.0, 1.0);
        cairo_rectangle(source_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_fill(source_cr);
        status = cairo_status(source_cr);
        cairo_destroy(source_cr);
      }
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_set_source_surface(cr, source, 7.0, 6.0);
        cairo_paint(cr);
        status = cairo_status(cr);
      }
      cairo_surface_destroy(source);
      return status;
    }
    case CAIROON_TEST_IMAGE_MASK_SURFACE_OFFSET: {
      cairo_surface_t *mask =
        cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 2, 2);
      cairo_status_t status = cairo_surface_status(mask);
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_t *mask_cr = cairo_create(mask);
        cairo_set_source_rgba(mask_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_rectangle(mask_cr, 0.0, 0.0, 1.0, 1.0);
        cairo_fill(mask_cr);
        cairo_set_source_rgba(mask_cr, 1.0, 1.0, 1.0, 0.5);
        cairo_rectangle(mask_cr, 1.0, 0.0, 1.0, 1.0);
        cairo_fill(mask_cr);
        cairo_set_source_rgba(mask_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_rectangle(mask_cr, 1.0, 1.0, 1.0, 1.0);
        cairo_fill(mask_cr);
        status = cairo_status(mask_cr);
        cairo_destroy(mask_cr);
      }
      if (status == CAIRO_STATUS_SUCCESS) {
        cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
        cairo_mask_surface(cr, mask, 7.0, 6.0);
        status = cairo_status(cr);
      }
      cairo_surface_destroy(mask);
      return status;
    }
    case CAIROON_TEST_IMAGE_RASTER_SOURCE_PATTERN:
      return cairoon_test_apply_raster_source_pattern(cr, width, height);
    default:
      return CAIRO_STATUS_INVALID_STATUS;
  }
  return cairo_status(cr);
}

static moonbit_bytes_t cairoon_test_copy_image_bytes(cairo_surface_t *surface) {
  cairo_surface_flush(surface);
  int32_t height = cairo_image_surface_get_height(surface);
  int32_t stride = cairo_image_surface_get_stride(surface);
  if (height > 0 && stride > INT32_MAX / height) {
    return moonbit_make_bytes(0, 0);
  }
  int32_t len = stride * height;
  unsigned char *data = cairo_image_surface_get_data(surface);
  if (data == NULL || len < 0) {
    return moonbit_make_bytes(0, 0);
  }

  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  if (len > 0) {
    memcpy(bytes, data, (size_t)len);
  }
  return bytes;
}

static moonbit_bytes_t cairoon_test_render_argb32_scene_bytes(
  int32_t scene,
  int32_t width,
  int32_t height) {
  if (width < 0 || height < 0) {
    return moonbit_make_bytes(0, 0);
  }

  cairo_surface_t *surface =
    cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
  if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    return moonbit_make_bytes(0, 0);
  }

  cairo_t *cr = cairo_create(surface);
  cairo_status_t status = cairoon_test_draw_argb32_scene(
    cr,
    scene,
    (double)width,
    (double)height);
  cairo_destroy(cr);
  if (status != CAIRO_STATUS_SUCCESS ||
      cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    return moonbit_make_bytes(0, 0);
  }

  moonbit_bytes_t bytes = cairoon_test_copy_image_bytes(surface);
  cairo_surface_destroy(surface);
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
int32_t cairoon_test_file_size(moonbit_bytes_t filename) {
  FILE *file = fopen((const char *)filename, "rb");
  if (file == NULL) {
    return -1;
  }
  if (fseek(file, 0, SEEK_END) != 0) {
    fclose(file);
    return -1;
  }
  long size = ftell(file);
  fclose(file);
  if (size < 0) {
    return -1;
  }
  if (size > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)size;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_test_file_contains(
  moonbit_bytes_t filename,
  moonbit_bytes_t needle) {
  int32_t needle_len = Moonbit_array_length(needle);
  if (needle_len == 0) {
    return 1;
  }
  int32_t size = cairoon_test_file_size(filename);
  if (size < needle_len) {
    return 0;
  }

  FILE *file = fopen((const char *)filename, "rb");
  if (file == NULL) {
    return 0;
  }
  unsigned char *data = (unsigned char *)malloc((size_t)size);
  if (data == NULL) {
    fclose(file);
    return 0;
  }
  size_t read_len = fread(data, 1, (size_t)size, file);
  fclose(file);
  if (read_len < (size_t)needle_len) {
    free(data);
    return 0;
  }

  int32_t found = 0;
  for (size_t i = 0; i + (size_t)needle_len <= read_len; i++) {
    if (memcmp(data + i, needle, (size_t)needle_len) == 0) {
      found = 1;
      break;
    }
  }
  free(data);
  return found;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_test_render_vector_scene_oracle(
  int32_t kind,
  int32_t scene,
  moonbit_bytes_t filename) {
  const char *name = (const char *)filename;
  cairo_surface_t *surface = NULL;
  switch (kind) {
    case CAIROON_TEST_VECTOR_PDF:
#if CAIRO_HAS_PDF_SURFACE
      if (scene == CAIROON_TEST_VECTOR_PDF_DOCUMENT_FEATURES) {
        return cairoon_test_render_pdf_document_features(name);
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
      surface = cairo_ps_surface_create(name, 10.0, 10.0);
      return cairoon_test_render_vector_surface(surface, scene);
#else
      return CAIRO_STATUS_SURFACE_TYPE_MISMATCH;
#endif
    case CAIROON_TEST_VECTOR_SVG:
#if CAIRO_HAS_SVG_SURFACE
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
cairo_status_t cairoon_test_render_vector_oracle(
  int32_t kind,
  moonbit_bytes_t filename) {
  return cairoon_test_render_vector_scene_oracle(
    kind,
    CAIROON_TEST_VECTOR_PAINT,
    filename);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_test_vector_files_equal(
  int32_t kind,
  moonbit_bytes_t left_filename,
  moonbit_bytes_t right_filename) {
  CairoonTestFile left;
  CairoonTestFile right;
  if (!cairoon_test_read_file((const char *)left_filename, &left)) {
    return 0;
  }
  if (!cairoon_test_read_file((const char *)right_filename, &right)) {
    cairoon_test_free_file(&left);
    return 0;
  }
  int32_t equal = cairoon_test_files_equal_normalized(kind, &left, &right);
  cairoon_test_free_file(&left);
  cairoon_test_free_file(&right);
  return equal;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_test_argb32_scene_oracle(
  int32_t scene,
  int32_t width,
  int32_t height) {
  return cairoon_test_render_argb32_scene_bytes(scene, width, height);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_test_argb32_blue_paint_oracle(
  int32_t width,
  int32_t height) {
  return cairoon_test_render_argb32_scene_bytes(
    CAIROON_TEST_IMAGE_BLUE_PAINT,
    width,
    height);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_compile_feature_flag(int32_t feature) {
  switch (feature) {
    case 0:
#ifdef CAIRO_HAS_ATSUI_FONT
      return 1;
#else
      return 0;
#endif
    case 1:
#ifdef CAIRO_HAS_FT_FONT
      return 1;
#else
      return 0;
#endif
    case 2:
#ifdef CAIRO_HAS_GLITZ_SURFACE
      return 1;
#else
      return 0;
#endif
    case 3:
#ifdef CAIRO_HAS_IMAGE_SURFACE
      return 1;
#else
      return 0;
#endif
    case 4:
#ifdef CAIRO_HAS_MIME_SURFACE
      return 1;
#else
      return 0;
#endif
    case 5:
#ifdef CAIRO_HAS_PDF_SURFACE
      return 1;
#else
      return 0;
#endif
    case 6:
#ifdef CAIRO_HAS_PNG_FUNCTIONS
      return 1;
#else
      return 0;
#endif
    case 7:
#ifdef CAIRO_HAS_PS_SURFACE
      return 1;
#else
      return 0;
#endif
    case 8:
#ifdef CAIRO_HAS_QUARTZ_SURFACE
      return 1;
#else
      return 0;
#endif
    case 9:
#ifdef CAIRO_HAS_RECORDING_SURFACE
      return 1;
#else
      return 0;
#endif
    case 10:
#ifdef CAIRO_HAS_SCRIPT_SURFACE
      return 1;
#else
      return 0;
#endif
    case 11:
#ifdef CAIRO_HAS_SVG_SURFACE
      return 1;
#else
      return 0;
#endif
    case 12:
#ifdef CAIRO_HAS_TEE_SURFACE
      return 1;
#else
      return 0;
#endif
    case 13:
#ifdef CAIRO_HAS_USER_FONT
      return 1;
#else
      return 0;
#endif
    case 14:
#ifdef CAIRO_HAS_WIN32_FONT
      return 1;
#else
      return 0;
#endif
    case 15:
#ifdef CAIRO_HAS_WIN32_SURFACE
      return 1;
#else
      return 0;
#endif
    case 16:
#ifdef CAIRO_HAS_XCB_SURFACE
      return 1;
#else
      return 0;
#endif
    case 17:
#ifdef CAIRO_HAS_XLIB_SURFACE
      return 1;
#else
      return 0;
#endif
    case 18:
#ifdef CAIRO_HAS_DWRITE_FONT
      return 1;
#else
      return 0;
#endif
    default:
      return 0;
  }
}

MOONBIT_FFI_EXPORT
int32_t cairoon_compile_int_constant(int32_t constant) {
  switch (constant) {
    case 0:
      return CAIRO_VERSION;
    case 1:
      return CAIRO_VERSION_MAJOR;
    case 2:
      return CAIRO_VERSION_MINOR;
    case 3:
      return CAIRO_VERSION_MICRO;
    case 4:
#ifdef CAIRO_PDF_OUTLINE_ROOT
      return CAIRO_PDF_OUTLINE_ROOT;
#else
      return 0;
#endif
    case 5:
#if CAIRO_VERSION >= CAIRO_VERSION_ENCODE(1, 17, 8)
      return CAIRO_COLOR_PALETTE_DEFAULT;
#else
      return 0;
#endif
    case 6:
      return CAIRO_FORMAT_INVALID;
    default:
      return 0;
  }
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_compile_string_constant(int32_t constant) {
  const char *value = "";
  switch (constant) {
    case 0:
      value = CAIRO_VERSION_STRING;
      break;
    case 1:
      value = CAIRO_MIME_TYPE_JP2;
      break;
    case 2:
      value = CAIRO_MIME_TYPE_JPEG;
      break;
    case 3:
      value = CAIRO_MIME_TYPE_PNG;
      break;
    case 4:
      value = CAIRO_MIME_TYPE_URI;
      break;
    case 5:
      value = CAIRO_MIME_TYPE_UNIQUE_ID;
      break;
    case 6:
      value = CAIRO_MIME_TYPE_CCITT_FAX;
      break;
    case 7:
      value = CAIRO_MIME_TYPE_CCITT_FAX_PARAMS;
      break;
    case 8:
      value = CAIRO_MIME_TYPE_EPS;
      break;
    case 9:
      value = CAIRO_MIME_TYPE_EPS_PARAMS;
      break;
    case 10:
      value = CAIRO_MIME_TYPE_JBIG2;
      break;
    case 11:
      value = CAIRO_MIME_TYPE_JBIG2_GLOBAL;
      break;
    case 12:
      value = CAIRO_MIME_TYPE_JBIG2_GLOBAL_ID;
      break;
    case 13:
      value = CAIRO_TAG_DEST;
      break;
    case 14:
      value = CAIRO_TAG_LINK;
      break;
    case 15:
      value = CAIRO_TAG_CONTENT;
      break;
    case 16:
      value = CAIRO_TAG_CONTENT_REF;
      break;
    default:
      break;
  }
  return cairoon_copy_c_string(value);
}
