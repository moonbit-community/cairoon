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
extern "C" fn compile_feature_flag_ffi(feature : Int) -> Bool = "cairoon_compile_feature_flag"

///|
extern "C" fn compile_int_constant_ffi(constant : Int) -> Int = "cairoon_compile_int_constant"

///|
extern "C" fn compile_string_constant_ffi(constant : Int) -> Bytes = "cairoon_compile_string_constant"

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
#borrow(text)
extern "C" fn test_scaled_font_extents_oracle_ffi(
  kind : Int,
  text : Bytes,
) -> FixedArray[Double] = "cairoon_test_scaled_font_extents_oracle"

///|
#borrow(text)
extern "C" fn test_scaled_font_text_to_glyphs_oracle_ffi(
  x : Double,
  y : Double,
  text : Bytes,
) -> TextToGlyphsNative = "cairoon_test_scaled_font_text_to_glyphs_oracle"

///|
#borrow(surface)
extern "C" fn test_raster_surface_owner_count_ffi(surface : Surface) -> Int = "cairoon_test_raster_surface_owner_count"

///|
fn init {
  ignore(compile_feature_flag_ffi)
  ignore(compile_int_constant_ffi)
  ignore(compile_string_constant_ffi)
  ignore(test_file_size_ffi)
  ignore(test_file_contains_ffi)
  ignore(test_render_vector_oracle_ffi)
  ignore(test_render_vector_scene_oracle_ffi)
  ignore(test_render_surface_page_oracle_ffi)
  ignore(test_render_surface_show_page_oracle_ffi)
  ignore(test_vector_files_equal_ffi)
  ignore(test_vector_file_equals_bytes_ffi)
  ignore(test_argb32_blue_paint_oracle_ffi)
  ignore(test_argb32_scene_oracle_ffi)
  ignore(test_scaled_font_extents_oracle_ffi)
  ignore(test_scaled_font_text_to_glyphs_oracle_ffi)
  ignore(test_raster_surface_owner_count_ffi)
}

///|
extern "C" fn status_to_string_ffi(status : Status) -> Bytes = "cairoon_status_to_string"
