///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn create_rgb_raw(
  red : Double,
  green : Double,
  blue : Double,
) -> RawPattern {
  ensure_native()
  pattern_create_rgb_ffi(red, green, blue)
}

///|
pub fn create_rgba_raw(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> RawPattern {
  ensure_native()
  pattern_create_rgba_ffi(red, green, blue, alpha)
}

///|
pub fn status_raw(pattern : RawPattern) -> Int {
  ensure_native()
  pattern_status_ffi(pattern)
}

///|
pub fn equal_raw(pattern : RawPattern, other : RawPattern) -> Bool {
  ensure_native()
  pattern_equal_ffi(pattern, other)
}

///|
pub fn hash_raw(pattern : RawPattern) -> UInt64 {
  ensure_native()
  pattern_hash_ffi(pattern)
}

///|
pub fn get_extend_raw(pattern : RawPattern) -> Int {
  ensure_native()
  pattern_get_extend_raw_ffi(pattern)
}

///|
pub fn set_extend_raw(pattern : RawPattern, extend_mode : Int) -> Int {
  ensure_native()
  pattern_set_extend_raw_ffi(pattern, extend_mode)
}

///|
pub fn get_filter_raw(pattern : RawPattern) -> Int {
  ensure_native()
  pattern_get_filter_raw_ffi(pattern)
}

///|
pub fn set_filter_raw(pattern : RawPattern, filter : Int) -> Int {
  ensure_native()
  pattern_set_filter_raw_ffi(pattern, filter)
}

///|
pub fn get_dither_raw(pattern : RawPattern, status : Ref[Int]) -> Int {
  ensure_native()
  pattern_get_dither_raw_ffi(pattern, status)
}

///|
pub fn set_dither_raw(pattern : RawPattern, dither : Int) -> Int {
  ensure_native()
  pattern_set_dither_raw_ffi(pattern, dither)
}

///|
pub fn get_matrix_raw(
  pattern : RawPattern,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int {
  ensure_native()
  pattern_get_matrix_ffi(pattern, xx, yx, xy, yy, x0, y0)
}

///|
pub fn set_matrix_raw(
  pattern : RawPattern,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Int {
  ensure_native()
  pattern_set_matrix_ffi(pattern, xx, yx, xy, yy, x0, y0)
}

///|
pub fn get_rgba_raw(
  pattern : RawPattern,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int {
  ensure_native()
  pattern_get_rgba_ffi(pattern, red, green, blue, alpha)
}
