///|
type Surface

///|
type Device

///|
type MappedImageSurface

///|
type ImageData

///|
type Context

///|
type Pattern

///|
type FontOptions

///|
type FontFace

///|
type ScaledFont

///|
type Path

///|
type Region

///|
priv type TextToGlyphsNative

///|
extern "C" fn cairo_version_ffi() -> Int = "cairo_version"

///|
extern "C" fn cairo_version_string_ffi() -> Bytes = "cairoon_version_string"

///|
#borrow(filename)
extern "C" fn test_file_size_ffi(filename : Bytes) -> Int = "cairoon_test_file_size"

///|
#borrow(filename, needle)
extern "C" fn test_file_contains_ffi(filename : Bytes, needle : Bytes) -> Bool = "cairoon_test_file_contains"

///|
#borrow(filename)
extern "C" fn test_render_vector_oracle_ffi(
  kind : Int,
  filename : Bytes,
) -> Status = "cairoon_test_render_vector_oracle"

///|
#borrow(filename)
extern "C" fn test_render_vector_scene_oracle_ffi(
  kind : Int,
  scene : Int,
  filename : Bytes,
) -> Status = "cairoon_test_render_vector_scene_oracle"

///|
#borrow(filename)
extern "C" fn test_render_surface_page_oracle_ffi(
  kind : Int,
  filename : Bytes,
) -> Status = "cairoon_test_render_surface_page_oracle"

///|
#borrow(filename)
extern "C" fn test_render_surface_show_page_oracle_ffi(
  kind : Int,
  filename : Bytes,
) -> Status = "cairoon_test_render_surface_show_page_oracle"

///|
#borrow(filename, payload)
extern "C" fn test_render_pdf_jpeg_mime_oracle_ffi(
  filename : Bytes,
  payload : Bytes,
) -> Status = "cairoon_test_render_pdf_jpeg_mime_oracle"

///|
#borrow(filename)
extern "C" fn test_render_pdf_thumbnail_oracle_ffi(filename : Bytes) -> Status = "cairoon_test_render_pdf_thumbnail_oracle"

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

///|
extern "C" fn test_argb32_blue_paint_oracle_ffi(
  width : Int,
  height : Int,
) -> Bytes = "cairoon_test_argb32_blue_paint_oracle"

///|
extern "C" fn test_argb32_scene_oracle_ffi(
  scene : Int,
  width : Int,
  height : Int,
) -> Bytes = "cairoon_test_argb32_scene_oracle"

///|
#borrow(surface)
extern "C" fn test_raster_surface_owner_count_ffi(surface : Surface) -> Int = "cairoon_test_raster_surface_owner_count"

///|
fn init {
  ignore(test_file_size_ffi)
  ignore(test_file_contains_ffi)
  ignore(test_render_vector_oracle_ffi)
  ignore(test_render_vector_scene_oracle_ffi)
  ignore(test_render_surface_page_oracle_ffi)
  ignore(test_render_surface_show_page_oracle_ffi)
  ignore(test_render_pdf_jpeg_mime_oracle_ffi)
  ignore(test_render_pdf_thumbnail_oracle_ffi)
  ignore(test_vector_files_equal_ffi)
  ignore(test_vector_file_equals_bytes_ffi)
  ignore(test_argb32_blue_paint_oracle_ffi)
  ignore(test_argb32_scene_oracle_ffi)
  ignore(test_raster_surface_owner_count_ffi)
}

///|
extern "C" fn status_to_string_ffi(status : Status) -> Bytes = "cairoon_status_to_string"
