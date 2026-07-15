///|
type RawPattern

///|
#borrow(surface)
extern "C" fn pattern_create_for_surface_ffi(
  surface : @surface_impl.RawSurface,
) -> RawPattern = "cairoon_pattern_create_for_surface"

///|
#borrow(pattern, status)
extern "C" fn pattern_get_surface_ffi(
  pattern : RawPattern,
  status : Ref[Int],
) -> @surface_impl.RawSurface = "cairoon_pattern_get_surface"

///|
extern "C" fn pattern_create_raster_source_ffi(
  content : Int,
  width : Int,
  height : Int,
) -> RawPattern = "cairoon_pattern_create_raster_source"

///|
extern "C" fn pattern_create_rgb_ffi(
  red : Double,
  green : Double,
  blue : Double,
) -> RawPattern = "cairoon_pattern_create_rgb"

///|
extern "C" fn pattern_create_rgba_ffi(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> RawPattern = "cairoon_pattern_create_rgba"

///|
extern "C" fn pattern_create_linear_ffi(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> RawPattern = "cairoon_pattern_create_linear"

///|
extern "C" fn pattern_create_radial_ffi(
  cx0 : Double,
  cy0 : Double,
  radius0 : Double,
  cx1 : Double,
  cy1 : Double,
  radius1 : Double,
) -> RawPattern = "cairoon_pattern_create_radial"

///|
#borrow(pattern)
extern "C" fn pattern_status_ffi(pattern : RawPattern) -> Int = "cairoon_pattern_status"

///|
#borrow(pattern, other)
extern "C" fn pattern_equal_ffi(
  pattern : RawPattern,
  other : RawPattern,
) -> Bool = "cairoon_pattern_equal"

///|
#borrow(pattern)
extern "C" fn pattern_hash_ffi(pattern : RawPattern) -> UInt64 = "cairoon_pattern_hash"

///|
#borrow(pattern)
extern "C" fn pattern_get_extend_raw_ffi(pattern : RawPattern) -> Int = "cairoon_pattern_get_extend_raw"

///|
#borrow(pattern)
extern "C" fn pattern_set_extend_raw_ffi(
  pattern : RawPattern,
  extend_mode : Int,
) -> Int = "cairoon_pattern_set_extend_raw"

///|
#borrow(pattern)
extern "C" fn pattern_get_filter_raw_ffi(pattern : RawPattern) -> Int = "cairoon_pattern_get_filter_raw"

///|
#borrow(pattern)
extern "C" fn pattern_set_filter_raw_ffi(
  pattern : RawPattern,
  filter : Int,
) -> Int = "cairoon_pattern_set_filter_raw"

///|
#borrow(pattern, status)
extern "C" fn pattern_get_dither_raw_ffi(
  pattern : RawPattern,
  status : Ref[Int],
) -> Int = "cairoon_pattern_get_dither_raw"

///|
#borrow(pattern)
extern "C" fn pattern_set_dither_raw_ffi(
  pattern : RawPattern,
  dither : Int,
) -> Int = "cairoon_pattern_set_dither_raw"

///|
#borrow(pattern, xx, yx, xy, yy, x0, y0)
extern "C" fn pattern_get_matrix_ffi(
  pattern : RawPattern,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int = "cairoon_pattern_get_matrix"

///|
#borrow(pattern)
extern "C" fn pattern_set_matrix_ffi(
  pattern : RawPattern,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Int = "cairoon_pattern_set_matrix"

///|
#borrow(pattern, red, green, blue, alpha)
extern "C" fn pattern_get_rgba_ffi(
  pattern : RawPattern,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int = "cairoon_pattern_get_rgba"

///|
#borrow(pattern)
extern "C" fn pattern_add_color_stop_rgb_ffi(
  pattern : RawPattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Int = "cairoon_pattern_add_color_stop_rgb"

///|
#borrow(pattern)
extern "C" fn pattern_add_color_stop_rgba_ffi(
  pattern : RawPattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int = "cairoon_pattern_add_color_stop_rgba"

///|
#borrow(pattern, count)
extern "C" fn pattern_get_color_stop_count_ffi(
  pattern : RawPattern,
  count : Ref[Int],
) -> Int = "cairoon_pattern_get_color_stop_count"

///|
#borrow(pattern, offset, red, green, blue, alpha)
extern "C" fn pattern_get_color_stop_rgba_ffi(
  pattern : RawPattern,
  index : Int,
  offset : Ref[Double],
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int = "cairoon_pattern_get_color_stop_rgba"

///|
#borrow(pattern, x0, y0, x1, y1)
extern "C" fn pattern_get_linear_points_ffi(
  pattern : RawPattern,
  x0 : Ref[Double],
  y0 : Ref[Double],
  x1 : Ref[Double],
  y1 : Ref[Double],
) -> Int = "cairoon_pattern_get_linear_points"

///|
#borrow(pattern, cx0, cy0, radius0, cx1, cy1, radius1)
extern "C" fn pattern_get_radial_circles_ffi(
  pattern : RawPattern,
  cx0 : Ref[Double],
  cy0 : Ref[Double],
  radius0 : Ref[Double],
  cx1 : Ref[Double],
  cy1 : Ref[Double],
  radius1 : Ref[Double],
) -> Int = "cairoon_pattern_get_radial_circles"
