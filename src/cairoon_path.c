#include "cairoon_private.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static cairo_status_t cairoon_path_validate_segment(
  cairo_path_data_t *data,
  int32_t remaining) {
  int32_t length = data[0].header.length;
  if (length <= 0 || length > remaining) {
    return CAIRO_STATUS_INVALID_PATH_DATA;
  }
  switch (data[0].header.type) {
  case CAIRO_PATH_MOVE_TO:
  case CAIRO_PATH_LINE_TO:
    return length == 2 ? CAIRO_STATUS_SUCCESS : CAIRO_STATUS_INVALID_PATH_DATA;
  case CAIRO_PATH_CURVE_TO:
    return length == 4 ? CAIRO_STATUS_SUCCESS : CAIRO_STATUS_INVALID_PATH_DATA;
  case CAIRO_PATH_CLOSE_PATH:
    return length == 1 ? CAIRO_STATUS_SUCCESS : CAIRO_STATUS_INVALID_PATH_DATA;
  default:
    return CAIRO_STATUS_INVALID_PATH_DATA;
  }
}

static cairo_status_t cairoon_path_format_segment(
  cairo_path_data_t *data,
  char **out,
  int32_t *out_len) {
  int32_t len = 0;
  switch (data[0].header.type) {
  case CAIRO_PATH_MOVE_TO:
    len = snprintf(
      NULL,
      0,
      "move_to %f %f",
      data[1].point.x,
      data[1].point.y);
    break;
  case CAIRO_PATH_LINE_TO:
    len = snprintf(
      NULL,
      0,
      "line_to %f %f",
      data[1].point.x,
      data[1].point.y);
    break;
  case CAIRO_PATH_CURVE_TO:
    len = snprintf(
      NULL,
      0,
      "curve_to %f %f %f %f %f %f",
      data[1].point.x,
      data[1].point.y,
      data[2].point.x,
      data[2].point.y,
      data[3].point.x,
      data[3].point.y);
    break;
  case CAIRO_PATH_CLOSE_PATH:
    len = (int32_t)strlen("close path");
    break;
  default:
    return CAIRO_STATUS_INVALID_PATH_DATA;
  }
  if (len < 0) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  char *piece = (char *)malloc((size_t)len + 1);
  if (piece == NULL) {
    return CAIRO_STATUS_NO_MEMORY;
  }
  switch (data[0].header.type) {
  case CAIRO_PATH_MOVE_TO:
    snprintf(
      piece,
      (size_t)len + 1,
      "move_to %f %f",
      data[1].point.x,
      data[1].point.y);
    break;
  case CAIRO_PATH_LINE_TO:
    snprintf(
      piece,
      (size_t)len + 1,
      "line_to %f %f",
      data[1].point.x,
      data[1].point.y);
    break;
  case CAIRO_PATH_CURVE_TO:
    snprintf(
      piece,
      (size_t)len + 1,
      "curve_to %f %f %f %f %f %f",
      data[1].point.x,
      data[1].point.y,
      data[2].point.x,
      data[2].point.y,
      data[3].point.x,
      data[3].point.y);
    break;
  case CAIRO_PATH_CLOSE_PATH:
    memcpy(piece, "close path", (size_t)len + 1);
    break;
  default:
    free(piece);
    return CAIRO_STATUS_INVALID_PATH_DATA;
  }
  *out = piece;
  *out_len = len;
  return CAIRO_STATUS_SUCCESS;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_path_status(CairoonPath *path) {
  if (path == NULL || path->ptr == NULL) {
    return CAIRO_STATUS_NULL_POINTER;
  }
  return path->ptr->status;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_path_equal(CairoonPath *path, CairoonPath *other) {
  if (cairoon_path_status(path) != CAIRO_STATUS_SUCCESS ||
      cairoon_path_status(other) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return path->ptr == other->ptr ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t cairoon_path_hash(CairoonPath *path) {
  if (cairoon_path_status(path) != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return (uint64_t)(uintptr_t)path->ptr;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_path_num_data(CairoonPath *path, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_path_status(path);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  return path->ptr->num_data;
}

MOONBIT_FFI_EXPORT
int32_t cairoon_path_num_segments(CairoonPath *path, cairo_status_t *status_out) {
  cairo_status_t status = cairoon_path_status(path);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return 0;
  }
  int32_t count = 0;
  for (int32_t i = 0; i < path->ptr->num_data;) {
    cairo_path_data_t *data = &path->ptr->data[i];
    status = cairoon_path_validate_segment(data, path->ptr->num_data - i);
    if (status != CAIRO_STATUS_SUCCESS) {
      *status_out = status;
      return 0;
    }
    i += data[0].header.length;
    count += 1;
  }
  return count;
}

MOONBIT_FFI_EXPORT
cairo_status_t cairoon_path_get_data(
  CairoonPath *path,
  int32_t data_index,
  cairo_path_data_type_t *type,
  int32_t *length,
  double *x1,
  double *y1,
  double *x2,
  double *y2,
  double *x3,
  double *y3) {
  *type = CAIRO_PATH_CLOSE_PATH;
  *length = 0;
  *x1 = 0.0;
  *y1 = 0.0;
  *x2 = 0.0;
  *y2 = 0.0;
  *x3 = 0.0;
  *y3 = 0.0;
  cairo_status_t status = cairoon_path_status(path);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  if (data_index < 0 || data_index >= path->ptr->num_data) {
    return CAIRO_STATUS_INVALID_INDEX;
  }
  cairo_path_data_t *data = &path->ptr->data[data_index];
  status = cairoon_path_validate_segment(data, path->ptr->num_data - data_index);
  if (status != CAIRO_STATUS_SUCCESS) {
    return status;
  }
  *type = data[0].header.type;
  *length = data[0].header.length;
  switch (data[0].header.type) {
  case CAIRO_PATH_MOVE_TO:
  case CAIRO_PATH_LINE_TO:
    *x1 = data[1].point.x;
    *y1 = data[1].point.y;
    return CAIRO_STATUS_SUCCESS;
  case CAIRO_PATH_CURVE_TO:
    *x1 = data[1].point.x;
    *y1 = data[1].point.y;
    *x2 = data[2].point.x;
    *y2 = data[2].point.y;
    *x3 = data[3].point.x;
    *y3 = data[3].point.y;
    return CAIRO_STATUS_SUCCESS;
  case CAIRO_PATH_CLOSE_PATH:
    return CAIRO_STATUS_SUCCESS;
  default:
    return CAIRO_STATUS_INVALID_PATH_DATA;
  }
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t cairoon_path_to_string(
  CairoonPath *path,
  cairo_status_t *status_out) {
  cairo_status_t status = cairoon_path_status(path);
  *status_out = status;
  if (status != CAIRO_STATUS_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }

  int32_t piece_count = 0;
  int32_t total_len = 0;
  for (int32_t i = 0; i < path->ptr->num_data;) {
    cairo_path_data_t *data = &path->ptr->data[i];
    status = cairoon_path_validate_segment(data, path->ptr->num_data - i);
    if (status != CAIRO_STATUS_SUCCESS) {
      *status_out = status;
      return moonbit_make_bytes(0, 0);
    }
    char *piece = NULL;
    int32_t piece_len = 0;
    status = cairoon_path_format_segment(data, &piece, &piece_len);
    if (status != CAIRO_STATUS_SUCCESS) {
      *status_out = status;
      return moonbit_make_bytes(0, 0);
    }
    if (piece_count > 0) {
      total_len += 1;
    }
    total_len += piece_len;
    free(piece);
    i += data[0].header.length;
    piece_count += 1;
  }

  moonbit_bytes_t bytes = moonbit_make_bytes(total_len, 0);
  char *out = (char *)bytes;
  int32_t pos = 0;
  piece_count = 0;
  for (int32_t i = 0; i < path->ptr->num_data;) {
    cairo_path_data_t *data = &path->ptr->data[i];
    char *piece = NULL;
    int32_t piece_len = 0;
    status = cairoon_path_format_segment(data, &piece, &piece_len);
    if (status != CAIRO_STATUS_SUCCESS) {
      free(piece);
      *status_out = status;
      return moonbit_make_bytes(0, 0);
    }
    if (piece_count > 0) {
      out[pos] = '\n';
      pos += 1;
    }
    memcpy(out + pos, piece, (size_t)piece_len);
    pos += piece_len;
    free(piece);
    i += data[0].header.length;
    piece_count += 1;
  }
  return bytes;
}
