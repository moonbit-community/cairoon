///|
extern "C" fn pattern_create_mesh_ffi() -> RawPattern = "cairoon_pattern_create_mesh"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_begin_patch_ffi(pattern : RawPattern) -> Int32 = "cairoon_mesh_pattern_begin_patch"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_end_patch_ffi(pattern : RawPattern) -> Int32 = "cairoon_mesh_pattern_end_patch"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_move_to_ffi(
  pattern : RawPattern,
  x : Double,
  y : Double,
) -> Int32 = "cairoon_mesh_pattern_move_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_line_to_ffi(
  pattern : RawPattern,
  x : Double,
  y : Double,
) -> Int32 = "cairoon_mesh_pattern_line_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_curve_to_ffi(
  pattern : RawPattern,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Int32 = "cairoon_mesh_pattern_curve_to"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_control_point_ffi(
  pattern : RawPattern,
  point_num : Int32,
  x : Double,
  y : Double,
) -> Int32 = "cairoon_mesh_pattern_set_control_point"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_corner_color_rgb_ffi(
  pattern : RawPattern,
  corner_num : Int32,
  red : Double,
  green : Double,
  blue : Double,
) -> Int32 = "cairoon_mesh_pattern_set_corner_color_rgb"

///|
#borrow(pattern)
extern "C" fn mesh_pattern_set_corner_color_rgba_ffi(
  pattern : RawPattern,
  corner_num : Int32,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int32 = "cairoon_mesh_pattern_set_corner_color_rgba"

///|
#borrow(pattern, count)
extern "C" fn mesh_pattern_get_patch_count_ffi(
  pattern : RawPattern,
  count : Ref[Int32],
) -> Int32 = "cairoon_mesh_pattern_get_patch_count"

///|
#borrow(pattern, status)
extern "C" fn mesh_pattern_get_path_ffi(
  pattern : RawPattern,
  patch_num : Int32,
  status : Ref[Int32],
) -> @path_impl.RawPath = "cairoon_mesh_pattern_get_path"

///|
#borrow(pattern, x, y)
extern "C" fn mesh_pattern_get_control_point_ffi(
  pattern : RawPattern,
  patch_num : Int32,
  point_num : Int32,
  x : Ref[Double],
  y : Ref[Double],
) -> Int32 = "cairoon_mesh_pattern_get_control_point"

///|
#borrow(pattern, red, green, blue, alpha)
extern "C" fn mesh_pattern_get_corner_color_rgba_ffi(
  pattern : RawPattern,
  patch_num : Int32,
  corner_num : Int32,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int32 = "cairoon_mesh_pattern_get_corner_color_rgba"
