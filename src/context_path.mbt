///|
pub fn Context::move_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(context_move_to_ffi(self, x, y))
}

///|
pub fn Context::rel_move_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_status(context_rel_move_to_ffi(self, dx, dy))
}

///|
pub fn Context::line_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_status(context_line_to_ffi(self, x, y))
}

///|
pub fn Context::rel_line_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_status(context_rel_line_to_ffi(self, dx, dy))
}

///|
pub fn Context::curve_to(
  self : Context,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Unit raise CairoError {
  check_status(context_curve_to_ffi(self, x1, y1, x2, y2, x3, y3))
}

///|
pub fn Context::rel_curve_to(
  self : Context,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Unit raise CairoError {
  check_status(context_rel_curve_to_ffi(self, dx1, dy1, dx2, dy2, dx3, dy3))
}

///|
pub fn Context::rectangle(
  self : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit raise CairoError {
  check_status(context_rectangle_ffi(self, x, y, width, height))
}

///|
pub fn Context::arc(
  self : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Unit raise CairoError {
  check_status(context_arc_ffi(self, xc, yc, radius, angle1, angle2))
}

///|
pub fn Context::arc_negative(
  self : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Unit raise CairoError {
  check_status(context_arc_negative_ffi(self, xc, yc, radius, angle1, angle2))
}

///|
pub fn Context::close_path(self : Context) -> Unit raise CairoError {
  check_status(context_close_path_ffi(self))
}

///|
pub fn Context::new_path(self : Context) -> Unit raise CairoError {
  check_status(context_new_path_ffi(self))
}

///|
pub fn Context::new_sub_path(self : Context) -> Unit raise CairoError {
  check_status(context_new_sub_path_ffi(self))
}

///|
pub fn Context::get_current_point(
  self : Context,
) -> (Double, Double) raise CairoError {
  point_from_context_output((x, y) => context_get_current_point_ffi(self, x, y))
}

///|
pub fn Context::has_current_point(self : Context) -> Bool raise CairoError {
  let result = Ref(0)
  check_status(context_has_current_point_ffi(self, result))
  result.val != 0
}

///|
pub fn Context::copy_path(self : Context) -> Path raise CairoError {
  let status = Ref(Success)
  let path = context_copy_path_ffi(self, status)
  check_status(status.val)
  path
}

///|
pub fn Context::copy_path_flat(self : Context) -> Path raise CairoError {
  let status = Ref(Success)
  let path = context_copy_path_flat_ffi(self, status)
  check_status(status.val)
  path
}

///|
pub fn Context::append_path(
  self : Context,
  path : Path,
) -> Unit raise CairoError {
  check_status(context_append_path_ffi(self, path))
}

///|
