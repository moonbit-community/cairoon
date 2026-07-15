///|
pub fn create_linear_raw(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> RawPattern {
  ensure_native()
  pattern_create_linear_ffi(x0, y0, x1, y1)
}

///|
pub fn create_radial_raw(
  cx0 : Double,
  cy0 : Double,
  radius0 : Double,
  cx1 : Double,
  cy1 : Double,
  radius1 : Double,
) -> RawPattern {
  ensure_native()
  pattern_create_radial_ffi(cx0, cy0, radius0, cx1, cy1, radius1)
}

///|
pub fn add_color_stop_rgb_raw(
  pattern : RawPattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Int {
  ensure_native()
  pattern_add_color_stop_rgb_ffi(pattern, offset, red, green, blue)
}

///|
pub fn add_color_stop_rgba_raw(
  pattern : RawPattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int {
  ensure_native()
  pattern_add_color_stop_rgba_ffi(pattern, offset, red, green, blue, alpha)
}

///|
pub fn get_color_stop_count_raw(pattern : RawPattern, count : Ref[Int]) -> Int {
  ensure_native()
  pattern_get_color_stop_count_ffi(pattern, count)
}

///|
pub fn get_color_stop_rgba_raw(
  pattern : RawPattern,
  index : Int,
  offset : Ref[Double],
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int {
  ensure_native()
  pattern_get_color_stop_rgba_ffi(
    pattern, index, offset, red, green, blue, alpha,
  )
}

///|
pub fn get_linear_points_raw(
  pattern : RawPattern,
  x0 : Ref[Double],
  y0 : Ref[Double],
  x1 : Ref[Double],
  y1 : Ref[Double],
) -> Int {
  ensure_native()
  pattern_get_linear_points_ffi(pattern, x0, y0, x1, y1)
}

///|
pub fn get_radial_circles_raw(
  pattern : RawPattern,
  cx0 : Ref[Double],
  cy0 : Ref[Double],
  radius0 : Ref[Double],
  cx1 : Ref[Double],
  cy1 : Ref[Double],
  radius1 : Ref[Double],
) -> Int {
  ensure_native()
  pattern_get_radial_circles_ffi(pattern, cx0, cy0, radius0, cx1, cy1, radius1)
}
