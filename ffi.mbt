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

///|
#borrow(ctx)
extern "C" fn context_clip_ffi(ctx : Context) -> Status = "cairoon_context_clip"

///|
#borrow(ctx)
extern "C" fn context_clip_preserve_ffi(ctx : Context) -> Status = "cairoon_context_clip_preserve"

///|
#borrow(ctx)
extern "C" fn context_reset_clip_ffi(ctx : Context) -> Status = "cairoon_context_reset_clip"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_clip_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_clip_extents"

///|
#borrow(ctx, result)
extern "C" fn context_in_clip_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_clip"

///|
#borrow(ctx, status)
extern "C" fn context_copy_clip_rectangle_list_ffi(
  ctx : Context,
  status : Ref[Status],
) -> FixedArray[Double] = "cairoon_context_copy_clip_rectangle_list"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_fill_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_fill_extents"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_stroke_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_stroke_extents"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_path_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_path_extents"

///|
#borrow(ctx, result)
extern "C" fn context_in_fill_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_fill"

///|
#borrow(ctx, result)
extern "C" fn context_in_stroke_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_stroke"

///|
#borrow(ctx)
extern "C" fn context_set_source_rgb_ffi(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_context_set_source_rgb"

///|
#borrow(ctx)
extern "C" fn context_set_source_rgba_ffi(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_context_set_source_rgba"

///|
#borrow(ctx, pattern)
extern "C" fn context_set_source_ffi(
  ctx : Context,
  pattern : Pattern,
) -> Status = "cairoon_context_set_source"

///|
#borrow(ctx, surface)
extern "C" fn context_set_source_surface_ffi(
  ctx : Context,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_set_source_surface"

///|
#borrow(ctx)
extern "C" fn context_paint_ffi(ctx : Context) -> Status = "cairoon_context_paint"

///|
#borrow(ctx)
extern "C" fn context_paint_with_alpha_ffi(
  ctx : Context,
  alpha : Double,
) -> Status = "cairoon_context_paint_with_alpha"

///|
#borrow(ctx, pattern)
extern "C" fn context_mask_ffi(ctx : Context, pattern : Pattern) -> Status = "cairoon_context_mask"

///|
#borrow(ctx, surface)
extern "C" fn context_mask_surface_ffi(
  ctx : Context,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_mask_surface"

///|
#borrow(ctx)
extern "C" fn context_fill_ffi(ctx : Context) -> Status = "cairoon_context_fill"

///|
#borrow(ctx)
extern "C" fn context_fill_preserve_ffi(ctx : Context) -> Status = "cairoon_context_fill_preserve"

///|
#borrow(ctx)
extern "C" fn context_stroke_ffi(ctx : Context) -> Status = "cairoon_context_stroke"

///|
#borrow(ctx)
extern "C" fn context_stroke_preserve_ffi(ctx : Context) -> Status = "cairoon_context_stroke_preserve"

///|
#borrow(ctx)
extern "C" fn context_copy_page_ffi(ctx : Context) -> Status = "cairoon_context_copy_page"

///|
#borrow(ctx)
extern "C" fn context_show_page_ffi(ctx : Context) -> Status = "cairoon_context_show_page"
