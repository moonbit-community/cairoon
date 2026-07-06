///|
fn checked_path_bytes(path : String) -> Bytes {
  @utf8.encode(path)
}

///|
fn init {
  ignore(@native.oracle_native_anchor())
}

///|
fn vector_backend_invalid_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.check_status(@cairoon.InvalidStatus)
  @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
}

///|
#borrow(filename)
extern "C" fn test_file_size_ffi(filename : Bytes) -> Int = "cairoon_test_file_size"

///|
#borrow(filename, needle)
extern "C" fn test_file_contains_ffi(filename : Bytes, needle : Bytes) -> Bool = "cairoon_test_file_contains"

///|
#borrow(filename)
extern "C" fn test_render_vector_scene_oracle_ffi(
  kind : Int,
  scene : Int,
  filename : Bytes,
) -> @cairoon.Status = "cairoon_test_render_vector_scene_oracle"

///|
#borrow(filename)
extern "C" fn test_render_surface_page_oracle_ffi(
  kind : Int,
  filename : Bytes,
) -> @cairoon.Status = "cairoon_test_render_surface_page_oracle"

///|
#borrow(filename)
extern "C" fn test_render_surface_show_page_oracle_ffi(
  kind : Int,
  filename : Bytes,
) -> @cairoon.Status = "cairoon_test_render_surface_show_page_oracle"

///|
#borrow(filename, payload)
extern "C" fn test_render_pdf_jpeg_mime_oracle_ffi(
  filename : Bytes,
  payload : Bytes,
) -> @cairoon.Status = "cairoon_test_render_pdf_jpeg_mime_oracle"

///|
#borrow(filename)
extern "C" fn test_render_pdf_thumbnail_oracle_ffi(
  filename : Bytes,
) -> @cairoon.Status = "cairoon_test_render_pdf_thumbnail_oracle"

///|
#borrow(left_filename, right_filename)
extern "C" fn test_vector_files_equal_ffi(
  kind : Int,
  left_filename : Bytes,
  right_filename : Bytes,
) -> Bool = "cairoon_test_vector_files_equal"

///|
#borrow(filename, bytes)
extern "C" fn test_vector_file_equals_bytes_ffi(
  kind : Int,
  filename : Bytes,
  bytes : Bytes,
) -> Bool = "cairoon_test_vector_file_equals_bytes"
