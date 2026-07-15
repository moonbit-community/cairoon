///|
pub fn Pattern::mesh() -> Pattern raise CairoError {
  let pattern = pattern_create_mesh_ffi()
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::mesh_begin_patch(self : Pattern) -> Unit raise CairoError {
  check_status(mesh_pattern_begin_patch_ffi(self))
}

///|
pub fn Pattern::mesh_end_patch(self : Pattern) -> Unit raise CairoError {
  check_status(mesh_pattern_end_patch_ffi(self))
}

///|
pub fn Pattern::mesh_move_to(
  self : Pattern,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(mesh_pattern_move_to_ffi(self, x, y))
}

///|
pub fn Pattern::mesh_line_to(
  self : Pattern,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(mesh_pattern_line_to_ffi(self, x, y))
}

///|
pub fn Pattern::mesh_curve_to(
  self : Pattern,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Unit raise CairoError {
  check_status(mesh_pattern_curve_to_ffi(self, x1, y1, x2, y2, x3, y3))
}

///|
pub fn Pattern::mesh_set_control_point(
  self : Pattern,
  point_num : Int,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(mesh_pattern_set_control_point_ffi(self, point_num, x, y))
}

///|
pub fn Pattern::mesh_set_corner_color_rgb(
  self : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_status(
    mesh_pattern_set_corner_color_rgb_ffi(self, corner_num, red, green, blue),
  )
}

///|
pub fn Pattern::mesh_set_corner_color_rgba(
  self : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_status(
    mesh_pattern_set_corner_color_rgba_ffi(
      self, corner_num, red, green, blue, alpha,
    ),
  )
}

///|
pub fn Pattern::mesh_get_patch_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_status(mesh_pattern_get_patch_count_ffi(self, count))
  count.val
}

///|
pub fn Pattern::mesh_get_path(
  self : Pattern,
  patch_num : Int,
) -> Path raise CairoError {
  let status = Ref(Success)
  let raw = mesh_pattern_get_path_ffi(self, patch_num, status)
  check_status(status.val)
  check_path_status_raw(@path_impl.status_raw(raw))
  Path::from_raw(raw)
}

///|
pub fn Pattern::mesh_get_control_point(
  self : Pattern,
  patch_num : Int,
  point_num : Int,
) -> (Double, Double) raise CairoError {
  let x = Ref(0.0)
  let y = Ref(0.0)
  check_status(
    mesh_pattern_get_control_point_ffi(self, patch_num, point_num, x, y),
  )
  (x.val, y.val)
}

///|
pub fn Pattern::mesh_get_corner_color_rgba(
  self : Pattern,
  patch_num : Int,
  corner_num : Int,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_status(
    mesh_pattern_get_corner_color_rgba_ffi(
      self, patch_num, corner_num, red, green, blue, alpha,
    ),
  )
  (red.val, green.val, blue.val, alpha.val)
}
