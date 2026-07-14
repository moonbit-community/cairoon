#include "cairoon_test_private.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
  CAIROON_TEST_VECTOR_PS = 1,
  CAIROON_TEST_VECTOR_SVG = 2
};

typedef struct {
  unsigned char *data;
  size_t len;
} CairoonTestFile;

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
  static const char *generated_id_prefixes[] = {
    "source-",
    "surface",
    "image"
  };
  size_t left_pos = 0;
  size_t right_pos = 0;
  while (left_pos < left->len && right_pos < right->len) {
    int skipped_generated_id = 0;
    for (size_t i = 0;
         i < sizeof(generated_id_prefixes) / sizeof(generated_id_prefixes[0]);
         i++) {
      size_t left_after_id = left_pos;
      size_t right_after_id = right_pos;
      if (
        cairoon_test_skip_digits_after_prefix(
          left->data,
          left->len,
          &left_after_id,
          generated_id_prefixes[i]) &&
        cairoon_test_skip_digits_after_prefix(
          right->data,
          right->len,
          &right_after_id,
          generated_id_prefixes[i])) {
        left_pos = left_after_id;
        right_pos = right_after_id;
        skipped_generated_id = 1;
        break;
      }
    }
    if (skipped_generated_id) {
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
int32_t cairoon_test_vector_file_equals_bytes(
  int32_t kind,
  moonbit_bytes_t filename,
  moonbit_bytes_t bytes) {
  CairoonTestFile file;
  if (!cairoon_test_read_file((const char *)filename, &file)) {
    return 0;
  }
  CairoonTestFile memory = {
    .data = (unsigned char *)bytes,
    .len = (size_t)Moonbit_array_length(bytes)
  };
  int32_t equal = cairoon_test_files_equal_normalized(kind, &file, &memory);
  cairoon_test_free_file(&file);
  return equal;
}
