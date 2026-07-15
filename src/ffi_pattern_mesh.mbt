///|
extern "C" fn pattern_create_mesh_ffi() -> Pattern = "cairoon_pattern_create_mesh"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_begin_patch_ffi(pattern : Pattern) -> Status = "cairoon_mesh_pattern_begin_patch"

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
) -> @path_impl.RawPath = "cairoon_mesh_pattern_get_path"

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
