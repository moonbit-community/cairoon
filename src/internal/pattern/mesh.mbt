///|
pub fn create_mesh_raw() -> RawPattern {
  ensure_native()
  pattern_create_mesh_ffi()
}

///|
pub fn mesh_begin_patch_raw(pattern : RawPattern) -> Int {
  ensure_native()
  mesh_pattern_begin_patch_ffi(pattern)
}

///|
pub fn mesh_end_patch_raw(pattern : RawPattern) -> Int {
  ensure_native()
  mesh_pattern_end_patch_ffi(pattern)
}

///|
pub fn mesh_move_to_raw(pattern : RawPattern, x : Double, y : Double) -> Int {
  ensure_native()
  mesh_pattern_move_to_ffi(pattern, x, y)
}

///|
pub fn mesh_line_to_raw(pattern : RawPattern, x : Double, y : Double) -> Int {
  ensure_native()
  mesh_pattern_line_to_ffi(pattern, x, y)
}

///|
pub fn mesh_curve_to_raw(
  pattern : RawPattern,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Int {
  ensure_native()
  mesh_pattern_curve_to_ffi(pattern, x1, y1, x2, y2, x3, y3)
}

///|
pub fn mesh_set_control_point_raw(
  pattern : RawPattern,
  point_num : Int,
  x : Double,
  y : Double,
) -> Int {
  ensure_native()
  mesh_pattern_set_control_point_ffi(pattern, point_num, x, y)
}

///|
pub fn mesh_set_corner_color_rgb_raw(
  pattern : RawPattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
) -> Int {
  ensure_native()
  mesh_pattern_set_corner_color_rgb_ffi(pattern, corner_num, red, green, blue)
}

///|
pub fn mesh_set_corner_color_rgba_raw(
  pattern : RawPattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int {
  ensure_native()
  mesh_pattern_set_corner_color_rgba_ffi(
    pattern, corner_num, red, green, blue, alpha,
  )
}

///|
pub fn mesh_get_patch_count_raw(pattern : RawPattern, count : Ref[Int]) -> Int {
  ensure_native()
  mesh_pattern_get_patch_count_ffi(pattern, count)
}

///|
pub fn mesh_get_path_raw(
  pattern : RawPattern,
  patch_num : Int,
  status : Ref[Int],
) -> @path_impl.RawPath {
  ensure_native()
  mesh_pattern_get_path_ffi(pattern, patch_num, status)
}

///|
pub fn mesh_get_control_point_raw(
  pattern : RawPattern,
  patch_num : Int,
  point_num : Int,
  x : Ref[Double],
  y : Ref[Double],
) -> Int {
  ensure_native()
  mesh_pattern_get_control_point_ffi(pattern, patch_num, point_num, x, y)
}

///|
pub fn mesh_get_corner_color_rgba_raw(
  pattern : RawPattern,
  patch_num : Int,
  corner_num : Int,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int {
  ensure_native()
  mesh_pattern_get_corner_color_rgba_ffi(
    pattern, patch_num, corner_num, red, green, blue, alpha,
  )
}
