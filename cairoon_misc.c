#include "cairoon_private.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>
#endif

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
