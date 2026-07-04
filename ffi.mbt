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
extern "C" fn context_scale_ffi(
  ctx : Context,
  sx : Double,
  sy : Double,
) -> Status = "cairoon_context_scale"

///|
#borrow(ctx)
extern "C" fn context_translate_ffi(
  ctx : Context,
  tx : Double,
  ty : Double,
) -> Status = "cairoon_context_translate"

///|
#borrow(ctx)
extern "C" fn context_rotate_ffi(ctx : Context, radians : Double) -> Status = "cairoon_context_rotate"

///|
#borrow(ctx)
extern "C" fn context_transform_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_transform"

///|
#borrow(ctx)
extern "C" fn context_set_matrix_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_set_matrix"

///|
#borrow(ctx, xx, yx, xy, yy, x0, y0)
extern "C" fn context_get_matrix_ffi(
  ctx : Context,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_context_get_matrix"

///|
#borrow(ctx)
extern "C" fn context_identity_matrix_ffi(ctx : Context) -> Status = "cairoon_context_identity_matrix"

///|
#borrow(ctx, out_x, out_y)
extern "C" fn context_user_to_device_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Status = "cairoon_context_user_to_device"

///|
#borrow(ctx, out_dx, out_dy)
extern "C" fn context_user_to_device_distance_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Status = "cairoon_context_user_to_device_distance"

///|
#borrow(ctx, out_x, out_y)
extern "C" fn context_device_to_user_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Status = "cairoon_context_device_to_user"

///|
#borrow(ctx, out_dx, out_dy)
extern "C" fn context_device_to_user_distance_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Status = "cairoon_context_device_to_user_distance"

///|
#borrow(ctx)
extern "C" fn context_set_line_width_ffi(
  ctx : Context,
  width : Double,
) -> Status = "cairoon_context_set_line_width"

///|
#borrow(ctx)
extern "C" fn context_get_line_width_ffi(ctx : Context) -> Double = "cairoon_context_get_line_width"

///|
#borrow(ctx)
extern "C" fn context_set_hairline_ffi(
  ctx : Context,
  set_hairline : Bool,
) -> Status = "cairoon_context_set_hairline"

///|
#borrow(ctx)
extern "C" fn context_get_hairline_ffi(ctx : Context) -> Bool = "cairoon_context_get_hairline"

///|
#borrow(ctx)
extern "C" fn context_set_line_cap_ffi(ctx : Context, cap : LineCap) -> Status = "cairoon_context_set_line_cap"

///|
#borrow(ctx)
extern "C" fn context_get_line_cap_ffi(ctx : Context) -> LineCap = "cairoon_context_get_line_cap"

///|
#borrow(ctx)
extern "C" fn context_set_line_join_ffi(
  ctx : Context,
  join : LineJoin,
) -> Status = "cairoon_context_set_line_join"

///|
#borrow(ctx)
extern "C" fn context_get_line_join_ffi(ctx : Context) -> LineJoin = "cairoon_context_get_line_join"

///|
#borrow(ctx)
extern "C" fn context_set_fill_rule_ffi(
  ctx : Context,
  fill_rule : FillRule,
) -> Status = "cairoon_context_set_fill_rule"

///|
#borrow(ctx)
extern "C" fn context_get_fill_rule_ffi(ctx : Context) -> FillRule = "cairoon_context_get_fill_rule"

///|
#borrow(ctx)
extern "C" fn context_set_operator_ffi(
  ctx : Context,
  operator : Operator,
) -> Status = "cairoon_context_set_operator"

///|
#borrow(ctx)
extern "C" fn context_get_operator_ffi(ctx : Context) -> Operator = "cairoon_context_get_operator"

///|
#borrow(ctx)
extern "C" fn context_set_antialias_ffi(
  ctx : Context,
  antialias : Antialias,
) -> Status = "cairoon_context_set_antialias"

///|
#borrow(ctx)
extern "C" fn context_get_antialias_ffi(ctx : Context) -> Antialias = "cairoon_context_get_antialias"

///|
#borrow(ctx)
extern "C" fn context_set_tolerance_ffi(
  ctx : Context,
  tolerance : Double,
) -> Status = "cairoon_context_set_tolerance"

///|
#borrow(ctx)
extern "C" fn context_get_tolerance_ffi(ctx : Context) -> Double = "cairoon_context_get_tolerance"

///|
#borrow(ctx)
extern "C" fn context_set_miter_limit_ffi(
  ctx : Context,
  limit : Double,
) -> Status = "cairoon_context_set_miter_limit"

///|
#borrow(ctx)
extern "C" fn context_get_miter_limit_ffi(ctx : Context) -> Double = "cairoon_context_get_miter_limit"

///|
#borrow(ctx, dashes)
extern "C" fn context_set_dash_ffi(
  ctx : Context,
  dashes : FixedArray[Double],
  offset : Double,
) -> Status = "cairoon_context_set_dash"

///|
#borrow(ctx)
extern "C" fn context_get_dash_count_ffi(ctx : Context) -> Int = "cairoon_context_get_dash_count"

///|
#borrow(ctx, offset)
extern "C" fn context_get_dash_ffi(
  ctx : Context,
  offset : Ref[Double],
) -> FixedArray[Double] = "cairoon_context_get_dash"

///|
#borrow(ctx)
extern "C" fn context_move_to_ffi(
  ctx : Context,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_move_to"

///|
#borrow(ctx)
extern "C" fn context_rel_move_to_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
) -> Status = "cairoon_context_rel_move_to"

///|
#borrow(ctx)
extern "C" fn context_line_to_ffi(
  ctx : Context,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_line_to"

///|
#borrow(ctx)
extern "C" fn context_rel_line_to_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
) -> Status = "cairoon_context_rel_line_to"

///|
#borrow(ctx)
extern "C" fn context_curve_to_ffi(
  ctx : Context,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Status = "cairoon_context_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rel_curve_to_ffi(
  ctx : Context,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Status = "cairoon_context_rel_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rectangle_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Status = "cairoon_context_rectangle"

///|
#borrow(ctx)
extern "C" fn context_arc_ffi(
  ctx : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Status = "cairoon_context_arc"

///|
#borrow(ctx)
extern "C" fn context_arc_negative_ffi(
  ctx : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Status = "cairoon_context_arc_negative"

///|
#borrow(ctx)
extern "C" fn context_close_path_ffi(ctx : Context) -> Status = "cairoon_context_close_path"

///|
#borrow(ctx)
extern "C" fn context_new_path_ffi(ctx : Context) -> Status = "cairoon_context_new_path"

///|
#borrow(ctx)
extern "C" fn context_new_sub_path_ffi(ctx : Context) -> Status = "cairoon_context_new_sub_path"

///|
#borrow(ctx, x, y)
extern "C" fn context_get_current_point_ffi(
  ctx : Context,
  x : Ref[Double],
  y : Ref[Double],
) -> Status = "cairoon_context_get_current_point"

///|
#borrow(ctx, result)
extern "C" fn context_has_current_point_ffi(
  ctx : Context,
  result : Ref[Int],
) -> Status = "cairoon_context_has_current_point"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Path = "cairoon_context_copy_path"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_flat_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Path = "cairoon_context_copy_path_flat"

///|
#borrow(ctx, path)
extern "C" fn context_append_path_ffi(ctx : Context, path : Path) -> Status = "cairoon_context_append_path"

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
