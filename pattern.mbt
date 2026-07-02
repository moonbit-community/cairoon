///|
pub fn Pattern::solid_rgb(
  red : Double,
  green : Double,
  blue : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_rgb_ffi(red, green, blue)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::solid_rgba(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_rgba_ffi(red, green, blue, alpha)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::linear(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_linear_ffi(x0, y0, x1, y1)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::radial(
  cx0 : Double,
  cy0 : Double,
  radius0 : Double,
  cx1 : Double,
  cy1 : Double,
  radius1 : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_radial_ffi(cx0, cy0, radius0, cx1, cy1, radius1)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::for_surface(surface : Surface) -> Pattern raise CairoError {
  let pattern = pattern_create_for_surface_ffi(surface)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::get_surface(self : Pattern) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = pattern_get_surface_ffi(self, status)
  check_status(status.val)
  surface
}

///|
pub fn Pattern::status(self : Pattern) -> Status {
  pattern_status_ffi(self)
}

///|
pub fn Pattern::get_extend(self : Pattern) -> Extend raise CairoError {
  check_status(pattern_status_ffi(self))
  pattern_get_extend_ffi(self)
}

///|
pub fn Pattern::set_extend(
  self : Pattern,
  extend : Extend,
) -> Unit raise CairoError {
  check_status(pattern_set_extend_ffi(self, extend))
}

///|
pub fn Pattern::get_filter(self : Pattern) -> Filter raise CairoError {
  check_status(pattern_status_ffi(self))
  pattern_get_filter_ffi(self)
}

///|
pub fn Pattern::set_filter(
  self : Pattern,
  filter : Filter,
) -> Unit raise CairoError {
  check_status(pattern_set_filter_ffi(self, filter))
}

///|
pub fn Pattern::get_dither(self : Pattern) -> Dither raise CairoError {
  check_status(pattern_status_ffi(self))
  pattern_get_dither_ffi(self)
}

///|
pub fn Pattern::set_dither(
  self : Pattern,
  dither : Dither,
) -> Unit raise CairoError {
  check_status(pattern_set_dither_ffi(self, dither))
}

///|
pub fn Pattern::get_matrix(self : Pattern) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_status(pattern_get_matrix_ffi(self, xx, yx, xy, yy, x0, y0))
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
pub fn Pattern::set_matrix(
  self : Pattern,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_status(
    pattern_set_matrix_ffi(
      self,
      matrix.xx,
      matrix.yx,
      matrix.xy,
      matrix.yy,
      matrix.x0,
      matrix.y0,
    ),
  )
}

///|
pub fn Pattern::get_rgba(
  self : Pattern,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_status(pattern_get_rgba_ffi(self, red, green, blue, alpha))
  (red.val, green.val, blue.val, alpha.val)
}

///|
pub fn Pattern::add_color_stop_rgb(
  self : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_status(pattern_add_color_stop_rgb_ffi(self, offset, red, green, blue))
}

///|
pub fn Pattern::add_color_stop_rgba(
  self : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_status(
    pattern_add_color_stop_rgba_ffi(self, offset, red, green, blue, alpha),
  )
}

///|
pub fn Pattern::get_color_stop_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_status(pattern_get_color_stop_count_ffi(self, count))
  count.val
}

///|
pub fn Pattern::get_color_stop_rgba(
  self : Pattern,
  index : Int,
) -> (Double, Double, Double, Double, Double) raise CairoError {
  let offset = Ref(0.0)
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_status(
    pattern_get_color_stop_rgba_ffi(
      self, index, offset, red, green, blue, alpha,
    ),
  )
  (offset.val, red.val, green.val, blue.val, alpha.val)
}

///|
pub fn Pattern::get_color_stops_rgba(
  self : Pattern,
) -> Array[(Double, Double, Double, Double, Double)] raise CairoError {
  let stops = []
  for index in 0..<self.get_color_stop_count() {
    stops.push(self.get_color_stop_rgba(index))
  }
  stops
}

///|
pub fn Pattern::get_linear_points(
  self : Pattern,
) -> (Double, Double, Double, Double) raise CairoError {
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let x1 = Ref(0.0)
  let y1 = Ref(0.0)
  check_status(pattern_get_linear_points_ffi(self, x0, y0, x1, y1))
  (x0.val, y0.val, x1.val, y1.val)
}

///|
pub fn Pattern::get_radial_circles(
  self : Pattern,
) -> (Double, Double, Double, Double, Double, Double) raise CairoError {
  let cx0 = Ref(0.0)
  let cy0 = Ref(0.0)
  let radius0 = Ref(0.0)
  let cx1 = Ref(0.0)
  let cy1 = Ref(0.0)
  let radius1 = Ref(0.0)
  check_status(
    pattern_get_radial_circles_ffi(self, cx0, cy0, radius0, cx1, cy1, radius1),
  )
  (cx0.val, cy0.val, radius0.val, cx1.val, cy1.val, radius1.val)
}
