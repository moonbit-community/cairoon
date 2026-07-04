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
extern "C" fn pattern_create_mesh_ffi() -> Pattern = "cairoon_pattern_create_mesh"

///|
extern "C" fn pattern_create_raster_source_ffi(
  content : Content,
  width : Int,
  height : Int,
) -> Pattern = "cairoon_pattern_create_raster_source"

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
extern "C" fn pattern_get_extend_ffi(pattern : Pattern) -> Extend = "cairoon_pattern_get_extend"

///|
#borrow(pattern)
extern "C" fn pattern_set_extend_ffi(
  pattern : Pattern,
  extend : Extend,
) -> Status = "cairoon_pattern_set_extend"

///|
#borrow(pattern)
extern "C" fn pattern_get_filter_ffi(pattern : Pattern) -> Filter = "cairoon_pattern_get_filter"

///|
#borrow(pattern)
extern "C" fn pattern_set_filter_ffi(
  pattern : Pattern,
  filter : Filter,
) -> Status = "cairoon_pattern_set_filter"

///|
#borrow(pattern)
extern "C" fn pattern_get_dither_ffi(pattern : Pattern) -> Dither = "cairoon_pattern_get_dither"

///|
#borrow(pattern)
extern "C" fn pattern_set_dither_ffi(
  pattern : Pattern,
  dither : Dither,
) -> Status = "cairoon_pattern_set_dither"

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

///|
#borrow(pattern)
extern "C" fn mesh_pattern_begin_patch_ffi(pattern : Pattern) -> Status = "cairoon_mesh_pattern_begin_patch"

///|
#owned(acquire)
#borrow(pattern)
extern "C" fn raster_source_pattern_set_acquire_ffi(
  pattern : Pattern,
  call_acquire : FuncRef[
    (Surface, Int, Int, Int, Int, (Surface, RectangleInt) -> Surface) -> Surface,
  ],
  acquire : (Surface, RectangleInt) -> Surface,
) -> Status = "cairoon_raster_source_pattern_set_acquire"

///|
#owned(acquire, release)
#borrow(pattern)
extern "C" fn raster_source_pattern_set_acquire_with_release_ffi(
  pattern : Pattern,
  call_acquire : FuncRef[
    (Surface, Int, Int, Int, Int, (Surface, RectangleInt) -> Surface) -> Surface,
  ],
  acquire : (Surface, RectangleInt) -> Surface,
  call_release : FuncRef[(Surface, (Surface) -> Unit) -> Unit],
  release : (Surface) -> Unit,
) -> Status = "cairoon_raster_source_pattern_set_acquire_with_release"

///|
#owned(release)
#borrow(pattern)
extern "C" fn raster_source_pattern_set_release_ffi(
  pattern : Pattern,
  call_release : FuncRef[(Surface, (Surface) -> Unit) -> Unit],
  release : (Surface) -> Unit,
) -> Status = "cairoon_raster_source_pattern_set_release"

///|
#borrow(pattern)
extern "C" fn raster_source_pattern_clear_acquire_ffi(
  pattern : Pattern,
) -> Status = "cairoon_raster_source_pattern_clear_acquire"

///|
#borrow(pattern, has_acquire, has_release, status)
extern "C" fn raster_source_pattern_has_callbacks_ffi(
  pattern : Pattern,
  has_acquire : Ref[Int],
  has_release : Ref[Int],
  status : Ref[Status],
) -> Bool = "cairoon_raster_source_pattern_has_callbacks"

///|
#borrow(pattern, status)
extern "C" fn raster_source_pattern_get_acquire_callback_ffi(
  pattern : Pattern,
  status : Ref[Status],
) -> (Surface, RectangleInt) -> Surface = "cairoon_raster_source_pattern_get_acquire_callback"

///|
#borrow(pattern, status)
extern "C" fn raster_source_pattern_get_release_callback_ffi(
  pattern : Pattern,
  status : Ref[Status],
) -> (Surface) -> Unit = "cairoon_raster_source_pattern_get_release_callback"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_end_patch_ffi(pattern : Pattern) -> Status = "cairoon_mesh_pattern_end_patch"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_move_to_ffi(
  pattern : Pattern,
  x : Double,
  y : Double,
) -> Status = "cairoon_mesh_pattern_move_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_line_to_ffi(
  pattern : Pattern,
  x : Double,
  y : Double,
) -> Status = "cairoon_mesh_pattern_line_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_curve_to_ffi(
  pattern : Pattern,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Status = "cairoon_mesh_pattern_curve_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_control_point_ffi(
  pattern : Pattern,
  point_num : Int,
  x : Double,
  y : Double,
) -> Status = "cairoon_mesh_pattern_set_control_point"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_corner_color_rgb_ffi(
  pattern : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_mesh_pattern_set_corner_color_rgb"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_corner_color_rgba_ffi(
  pattern : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_mesh_pattern_set_corner_color_rgba"

///|
#borrow(pattern, count)
extern "C" fn mesh_pattern_get_patch_count_ffi(
  pattern : Pattern,
  count : Ref[Int],
) -> Status = "cairoon_mesh_pattern_get_patch_count"

///|
#borrow(pattern, status)
extern "C" fn mesh_pattern_get_path_ffi(
  pattern : Pattern,
  patch_num : Int,
  status : Ref[Status],
) -> Path = "cairoon_mesh_pattern_get_path"

///|
#borrow(pattern, x, y)
extern "C" fn mesh_pattern_get_control_point_ffi(
  pattern : Pattern,
  patch_num : Int,
  point_num : Int,
  x : Ref[Double],
  y : Ref[Double],
) -> Status = "cairoon_mesh_pattern_get_control_point"

///|
#borrow(pattern, red, green, blue, alpha)
extern "C" fn mesh_pattern_get_corner_color_rgba_ffi(
  pattern : Pattern,
  patch_num : Int,
  corner_num : Int,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_mesh_pattern_get_corner_color_rgba"
