///|
pub fn Context::move_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.move_to_raw(self.to_raw(), x, y))
}

///|
pub fn Context::rel_move_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.rel_move_to_raw(self.to_raw(), dx, dy))
}

///|
pub fn Context::line_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.line_to_raw(self.to_raw(), x, y))
}

///|
pub fn Context::rel_line_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.rel_line_to_raw(self.to_raw(), dx, dy))
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
  check_context_status_raw(
    @context_impl.curve_to_raw(self.to_raw(), x1, y1, x2, y2, x3, y3),
  )
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
  check_context_status_raw(
    @context_impl.rel_curve_to_raw(self.to_raw(), dx1, dy1, dx2, dy2, dx3, dy3),
  )
}

///|
pub fn Context::rectangle(
  self : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.rectangle_raw(self.to_raw(), x, y, width, height),
  )
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
  check_context_status_raw(
    @context_impl.arc_raw(self.to_raw(), xc, yc, radius, angle1, angle2),
  )
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
  check_context_status_raw(
    @context_impl.arc_negative_raw(
      self.to_raw(),
      xc,
      yc,
      radius,
      angle1,
      angle2,
    ),
  )
}

///|
pub fn Context::close_path(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.close_path_raw(self.to_raw()))
}

///|
pub fn Context::new_path(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.new_path_raw(self.to_raw()))
}

///|
pub fn Context::new_sub_path(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.new_sub_path_raw(self.to_raw()))
}

///|
pub fn Context::get_current_point(
  self : Context,
) -> (Double, Double) raise CairoError {
  point_from_context_output((x, y) => {
    @context_impl.get_current_point_raw(self.to_raw(), x, y)
  })
}

///|
pub fn Context::has_current_point(self : Context) -> Bool raise CairoError {
  let result = Ref(0)
  check_context_status_raw(
    @context_impl.has_current_point_raw(self.to_raw(), result),
  )
  result.val != 0
}

///|
pub fn Context::copy_path(self : Context) -> Path raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.copy_path_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  Path::from_raw(raw)
}

///|
pub fn Context::copy_path_flat(self : Context) -> Path raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.copy_path_flat_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  Path::from_raw(raw)
}

///|
pub fn Context::append_path(
  self : Context,
  path : Path,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.append_path_raw(self.to_raw(), path.to_raw()),
  )
}
