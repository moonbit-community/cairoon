///|
pub fn Pattern::mesh() -> Pattern raise CairoError {
  let raw = @pattern_impl.create_mesh_raw()
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
pub fn Pattern::mesh_begin_patch(self : Pattern) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_begin_patch_raw(self.to_raw()))
}

///|
pub fn Pattern::mesh_end_patch(self : Pattern) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_end_patch_raw(self.to_raw()))
}

///|
pub fn Pattern::mesh_move_to(
  self : Pattern,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_move_to_raw(self.to_raw(), x, y))
}

///|
pub fn Pattern::mesh_line_to(
  self : Pattern,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_line_to_raw(self.to_raw(), x, y))
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
  check_pattern_status_raw(
    @pattern_impl.mesh_curve_to_raw(self.to_raw(), x1, y1, x2, y2, x3, y3),
  )
}

///|
pub fn Pattern::mesh_set_control_point(
  self : Pattern,
  point_num : Int,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.mesh_set_control_point_raw(self.to_raw(), point_num, x, y),
  )
}

///|
pub fn Pattern::mesh_set_corner_color_rgb(
  self : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.mesh_set_corner_color_rgb_raw(
      self.to_raw(),
      corner_num,
      red,
      green,
      blue,
    ),
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
  check_pattern_status_raw(
    @pattern_impl.mesh_set_corner_color_rgba_raw(
      self.to_raw(),
      corner_num,
      red,
      green,
      blue,
      alpha,
    ),
  )
}

///|
pub fn Pattern::mesh_get_patch_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_pattern_status_raw(
    @pattern_impl.mesh_get_patch_count_raw(self.to_raw(), count),
  )
  count.val
}

///|
pub fn Pattern::mesh_get_path(
  self : Pattern,
  patch_num : Int,
) -> Path raise CairoError {
  let status = Ref(0)
  let raw = @pattern_impl.mesh_get_path_raw(self.to_raw(), patch_num, status)
  check_pattern_status_raw(status.val)
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
  check_pattern_status_raw(
    @pattern_impl.mesh_get_control_point_raw(
      self.to_raw(),
      patch_num,
      point_num,
      x,
      y,
    ),
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
  check_pattern_status_raw(
    @pattern_impl.mesh_get_corner_color_rgba_raw(
      self.to_raw(),
      patch_num,
      corner_num,
      red,
      green,
      blue,
      alpha,
    ),
  )
  (red.val, green.val, blue.val, alpha.val)
}
