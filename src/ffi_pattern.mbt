///|
extern "C" fn pattern_create_rgb_ffi(
  red : Double,
  green : Double,
  blue : Double,
) -> Pattern = "cairoon_pattern_create_rgb"

///|
extern "C" fn pattern_create_rgba_ffi(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Pattern = "cairoon_pattern_create_rgba"

///|
extern "C" fn pattern_create_linear_ffi(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> Pattern = "cairoon_pattern_create_linear"

///|
extern "C" fn pattern_create_radial_ffi(
  cx0 : Double,
  cy0 : Double,
  radius0 : Double,
  cx1 : Double,
  cy1 : Double,
  radius1 : Double,
) -> Pattern = "cairoon_pattern_create_radial"

///|
#borrow(surface)
extern "C" fn pattern_create_for_surface_ffi(surface : Surface) -> Pattern = "cairoon_pattern_create_for_surface"

///|
#borrow(pattern)
extern "C" fn pattern_status_ffi(pattern : Pattern) -> Status = "cairoon_pattern_status"

///|
#borrow(pattern, other)
extern "C" fn pattern_equal_ffi(pattern : Pattern, other : Pattern) -> Bool = "cairoon_pattern_equal"

///|
#borrow(pattern)
extern "C" fn pattern_hash_ffi(pattern : Pattern) -> UInt64 = "cairoon_pattern_hash"

///|
#borrow(pattern, status)
extern "C" fn pattern_get_surface_ffi(
  pattern : Pattern,
  status : Ref[Status],
) -> Surface = "cairoon_pattern_get_surface"

///|
#borrow(pattern)
extern "C" fn pattern_get_extend_raw_ffi(pattern : Pattern) -> Int = "cairoon_pattern_get_extend_raw"

///|
#borrow(pattern)
extern "C" fn pattern_set_extend_ffi(
  pattern : Pattern,
  extend_mode : Extend,
) -> Status = "cairoon_pattern_set_extend"

///|
#borrow(pattern)
extern "C" fn pattern_set_extend_raw_ffi(
  pattern : Pattern,
  extend_mode : Int,
) -> Status = "cairoon_pattern_set_extend_raw"

///|
#borrow(pattern)
extern "C" fn pattern_get_filter_raw_ffi(pattern : Pattern) -> Int = "cairoon_pattern_get_filter_raw"

///|
#borrow(pattern)
extern "C" fn pattern_set_filter_ffi(
  pattern : Pattern,
  filter : Filter,
) -> Status = "cairoon_pattern_set_filter"

///|
#borrow(pattern)
extern "C" fn pattern_set_filter_raw_ffi(
  pattern : Pattern,
  filter : Int,
) -> Status = "cairoon_pattern_set_filter_raw"

///|
#borrow(pattern)
extern "C" fn pattern_get_dither_raw_ffi(pattern : Pattern) -> Int = "cairoon_pattern_get_dither_raw"

///|
#borrow(pattern)
extern "C" fn pattern_set_dither_ffi(
  pattern : Pattern,
  dither : Dither,
) -> Status = "cairoon_pattern_set_dither"

///|
#borrow(pattern)
extern "C" fn pattern_set_dither_raw_ffi(
  pattern : Pattern,
  dither : Int,
) -> Status = "cairoon_pattern_set_dither_raw"

///|
#borrow(pattern, xx, yx, xy, yy, x0, y0)
extern "C" fn pattern_get_matrix_ffi(
  pattern : Pattern,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_pattern_get_matrix"

///|
#borrow(pattern)
extern "C" fn pattern_set_matrix_ffi(
  pattern : Pattern,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_pattern_set_matrix"

///|
#borrow(pattern, red, green, blue, alpha)
extern "C" fn pattern_get_rgba_ffi(
  pattern : Pattern,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_pattern_get_rgba"

///|
#borrow(pattern)
extern "C" fn pattern_add_color_stop_rgb_ffi(
  pattern : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_pattern_add_color_stop_rgb"

///|
#borrow(pattern)
extern "C" fn pattern_add_color_stop_rgba_ffi(
  pattern : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_pattern_add_color_stop_rgba"

///|
#borrow(pattern, count)
extern "C" fn pattern_get_color_stop_count_ffi(
  pattern : Pattern,
  count : Ref[Int],
) -> Status = "cairoon_pattern_get_color_stop_count"

///|
#borrow(pattern, offset, red, green, blue, alpha)
extern "C" fn pattern_get_color_stop_rgba_ffi(
  pattern : Pattern,
  index : Int,
  offset : Ref[Double],
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_pattern_get_color_stop_rgba"

///|
#borrow(pattern, x0, y0, x1, y1)
extern "C" fn pattern_get_linear_points_ffi(
  pattern : Pattern,
  x0 : Ref[Double],
  y0 : Ref[Double],
  x1 : Ref[Double],
  y1 : Ref[Double],
) -> Status = "cairoon_pattern_get_linear_points"

///|
#borrow(pattern, cx0, cy0, radius0, cx1, cy1, radius1)
extern "C" fn pattern_get_radial_circles_ffi(
  pattern : Pattern,
  cx0 : Ref[Double],
  cy0 : Ref[Double],
  radius0 : Ref[Double],
  cx1 : Ref[Double],
  cy1 : Ref[Double],
  radius1 : Ref[Double],
) -> Status = "cairoon_pattern_get_radial_circles"
