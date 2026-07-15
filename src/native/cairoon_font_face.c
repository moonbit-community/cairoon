#include "cairoon_private.h"

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_toy_font_face_create(
  moonbit_bytes_t family,
  cairo_font_slant_t slant,
  cairo_font_weight_t weight) {
  return cairoon_font_face_wrap_owned(
    cairo_toy_font_face_create((const char *)family, slant, weight));
}

MOONBIT_FFI_EXPORT
CairoonFontFace *cairoon_toy_font_face_create_raw(
  moonbit_bytes_t family,
  int32_t slant,
  int32_t weight) {
  return cairoon_font_face_wrap_owned(
    cairo_toy_font_face_create(
      (const char *)family,
      (cairo_font_slant_t)slant,
      (cairo_font_weight_t)weight));
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_font_face_status(CairoonFontFace *font_face) {
  if (font_face == NULL || font_face->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return cairo_font_face_status(font_face->ptr);
}

static cairo_status_t cairoon_toy_font_face_status(CairoonFontFace *font_face) {
  cairo_status_t status = cairoon_font_face_status(font_face);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (cairo_font_face_get_type(font_face->ptr) != CAIRO_FONT_TYPE_TOY) {
    return CAIRO_STATUS_FONT_TYPE_MISMATCH;
  }
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_font_face_equal(
  CairoonFontFace *font_face,
  CairoonFontFace *other) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS ||
      cairoon_font_face_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return font_face->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_font_face_hash(CairoonFontFace *font_face) {
  if (cairoon_font_face_status(font_face) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)(uintptr_t)font_face->ptr;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_toy_font_face_get_family(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  const char *family = cairo_toy_font_face_get_family(font_face->ptr);
  if (family == NULL) {
    *status_out = CAIRO_STATUS_NULL_POINTER;
    return moonbit_make_bytes(0, 0);
  }
  return cairoon_copy_c_string(family);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_toy_font_face_get_slant_raw(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FONT_SLANT_NORMAL;
  }
  return (int32_t)cairo_toy_font_face_get_slant(font_face->ptr);
}

MOONBIT_FFI_EXPORT
int32_t cairoon_toy_font_face_get_weight_raw(
  CairoonFontFace *font_face,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_toy_font_face_status(font_face);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return CAIRO_FONT_WEIGHT_NORMAL;
  }
  return (int32_t)cairo_toy_font_face_get_weight(font_face->ptr);
}
